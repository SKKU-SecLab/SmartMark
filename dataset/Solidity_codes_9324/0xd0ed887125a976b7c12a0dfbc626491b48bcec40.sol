
pragma solidity 0.6.7; // optimization runs: 200, evm version: istanbul


interface ERC1271Interface {

  function isValidSignature(
    bytes calldata data, bytes calldata signatures
  ) external view returns (bytes4 magicValue);

}


interface EtherizedInterface {

  function triggerCall(
    address target, uint256 value, bytes calldata data
  ) external returns (bool success, bytes memory returnData);

}


interface EtherizerV1Interface {

  event TriggeredCall(
    address indexed from,
    address indexed to,
    uint256 value,
    bytes data,
    bytes returnData
  );
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function triggerCallFrom(
    EtherizedInterface from,
    address payable to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success, bytes memory returnData);

  function approve(
    address spender, uint256 value
  ) external returns (bool success);

  function increaseAllowance(
    address spender, uint256 addedValue
  ) external returns (bool success);

  function decreaseAllowance(
    address spender, uint256 subtractedValue
  ) external returns (bool success);

  function modifyAllowanceViaMetaTransaction(
    address owner,
    address spender,
    uint256 value,
    bool increase,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external returns (bool success);

  function cancelAllowanceModificationMetaTransaction(
    address owner,
    address spender,
    uint256 value,
    bool increase,
    uint256 expiration,
    bytes32 salt
  ) external returns (bool success);


  function getMetaTransactionMessageHash(
    bytes4 functionSelector,
    bytes calldata arguments,
    uint256 expiration,
    bytes32 salt
  ) external view returns (bytes32 digest, bool valid);

  function balanceOf(address account) external view returns (uint256 amount);

  function allowance(
    address owner, address spender
  ) external view returns (uint256 amount);

}


library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

    return c;
  }
}


contract EtherizerV1 is EtherizerV1Interface {

  using SafeMath for uint256;

  mapping (address => mapping (address => uint256)) private _allowances;

  mapping (bytes32 => bool) private _invalidMetaTxHashes;

  function triggerCallFrom(
    EtherizedInterface owner,
    address payable recipient,
    uint256 amount,
    bytes calldata data
  ) external override returns (bool success, bytes memory returnData) {

    uint256 callerAllowance = _allowances[address(owner)][msg.sender];

    require(callerAllowance != 0, "No allowance set for caller.");

    if (callerAllowance != uint256(-1)) {
      require(callerAllowance >= amount, "Insufficient allowance.");
      _approve(
          address(owner), msg.sender, callerAllowance - amount
      ); // overflow safe (condition has already been checked).
    }

    (success, returnData) = owner.triggerCall(recipient, amount, data);
    require(success, "Triggered call did not return successfully.");

    emit TriggeredCall(address(owner), recipient, amount, data, returnData);
  }

  function approve(
    address spender, uint256 value
  ) external override returns (bool success) {

    _approve(msg.sender, spender, value);
    success = true;
  }

  function increaseAllowance(
    address spender, uint256 addedValue
  ) external override returns (bool success) {

    _approve(
      msg.sender, spender, _allowances[msg.sender][spender].add(addedValue)
    );
    success = true;
  }

  function decreaseAllowance(
    address spender, uint256 subtractedValue
  ) external override returns (bool success) {

    _approve(
      msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue)
    );
    success = true;
  }

  function modifyAllowanceViaMetaTransaction(
    address owner,
    address spender,
    uint256 value,
    bool increase,
    uint256 expiration,
    bytes32 salt,
    bytes calldata signatures
  ) external override returns (bool success) {

    require(expiration == 0 || now <= expiration, "Meta-transaction expired.");

    bytes memory context = abi.encodePacked(
      address(this),
      this.modifyAllowanceViaMetaTransaction.selector,
      expiration,
      salt,
      abi.encode(owner, spender, value, increase)
    );
    _validateMetaTransaction(owner, context, signatures);

    uint256 currentAllowance = _allowances[owner][spender];
    uint256 newAllowance = (
      increase ? currentAllowance.add(value) : currentAllowance.sub(value)
    );

    _approve(owner, spender, newAllowance);
    success = true;
  }

  function cancelAllowanceModificationMetaTransaction(
    address owner,
    address spender,
    uint256 value,
    bool increase,
    uint256 expiration,
    bytes32 salt
  ) external override returns (bool success) {

    require(expiration == 0 || now <= expiration, "Meta-transaction expired.");
    require(
      msg.sender == owner || msg.sender == spender,
      "Only owner or spender may cancel a given meta-transaction."
    );

    bytes memory context = abi.encodePacked(
      address(this),
      this.modifyAllowanceViaMetaTransaction.selector,
      expiration,
      salt,
      abi.encode(owner, spender, value, increase)
    );

    bytes32 messageHash = keccak256(context);

    require(
      !_invalidMetaTxHashes[messageHash], "Meta-transaction already invalid."
    );
    _invalidMetaTxHashes[messageHash] = true;

    success = true;
  }

  function getMetaTransactionMessageHash(
    bytes4 functionSelector,
    bytes calldata arguments,
    uint256 expiration,
    bytes32 salt
  ) external view override returns (bytes32 messageHash, bool valid) {

    messageHash = keccak256(
      abi.encodePacked(
        address(this), functionSelector, expiration, salt, arguments
      )
    );

    valid = (
      !_invalidMetaTxHashes[messageHash] && (
        expiration == 0 || now <= expiration
      )
    );
  }

  function balanceOf(
    address account
  ) external view override returns (uint256 amount) {

    amount = account.balance;
  }

  function allowance(
    address owner, address spender
  ) external view override returns (uint256 etherAllowance) {

    etherAllowance = _allowances[owner][spender];
  }

  function _approve(address owner, address spender, uint256 value) private {

    require(owner != address(0), "ERC20: approve for the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = value;
    emit Approval(owner, spender, value);
  }

  function _validateMetaTransaction(
    address owner, bytes memory context, bytes memory signatures
  ) private {

    bytes32 messageHash = keccak256(context);

    require(
      !_invalidMetaTxHashes[messageHash], "Meta-transaction no longer valid."
    );
    _invalidMetaTxHashes[messageHash] = true;

    bytes32 digest = keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
    );

    bytes memory data = abi.encode(digest, context);
    bytes4 magic = ERC1271Interface(owner).isValidSignature(data, signatures);
    require(magic == bytes4(0x20c13b0b), "Invalid signatures.");
  }
}