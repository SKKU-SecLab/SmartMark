
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IVerifier {
  function verifyProof(bytes calldata proof, uint[] calldata pubSignals) external view returns (bool);
}// MIT

pragma solidity ^0.8.0;



contract PoofBase {
  using SafeMath for uint256;

  IVerifier public depositVerifier;
  IVerifier public withdrawVerifier;
  IVerifier public inputRootVerifier;
  IVerifier public outputRootVerifier;
  IVerifier public treeUpdateVerifier;

  mapping(bytes32 => bool) public accountNullifiers;

  uint256 public accountCount;
  uint256 public constant ACCOUNT_ROOT_HISTORY_SIZE = 100;
  bytes32[ACCOUNT_ROOT_HISTORY_SIZE] public accountRoots;

  event NewAccount(bytes32 commitment, bytes32 nullifier, bytes encryptedAccount, uint256 index);

  struct TreeUpdateArgs {
    bytes32 oldRoot;
    bytes32 newRoot;
    bytes32 leaf;
    uint256 pathIndices;
  }

  struct AccountUpdate {
    bytes32 inputRoot;
    bytes32 inputNullifierHash;
    bytes32 inputAccountHash;
    bytes32 outputRoot;
    uint256 outputPathIndices;
    bytes32 outputCommitment;
    bytes32 outputAccountHash;
  }

  struct DepositExtData {
    bytes encryptedAccount;
  }

  struct DepositArgs {
    uint256 amount;
    uint256 debt;
    uint256 unitPerUnderlying;
    bytes32 extDataHash;
    DepositExtData extData;
    AccountUpdate account;
  }

  struct WithdrawExtData {
    uint256 fee;
    address recipient;
    address relayer;
    bytes encryptedAccount;
  }

  struct WithdrawArgs {
    uint256 amount;
    uint256 debt;
    uint256 unitPerUnderlying;
    bytes32 extDataHash;
    WithdrawExtData extData;
    AccountUpdate account;
  }

  constructor(
    IVerifier[5] memory _verifiers,
    bytes32 _accountRoot
  ) {
    accountRoots[0] = _accountRoot;
    depositVerifier = _verifiers[0];
    withdrawVerifier = _verifiers[1];
    inputRootVerifier = _verifiers[2];
    outputRootVerifier = _verifiers[3];
    treeUpdateVerifier = _verifiers[4];
  }

  function toDynamicArray(uint256[3] memory arr) internal pure returns (uint256[] memory) {
    uint256[] memory res = new uint256[](3);
    uint256 length = arr.length;
    for (uint i = 0; i < length; i++) {
      res[i] = arr[i];
    }
    return res;
  }

  function toDynamicArray(uint256[4] memory arr) internal pure returns (uint256[] memory) {
    uint256[] memory res = new uint256[](4);
    uint256 length = arr.length;
    for (uint i = 0; i < length; i++) {
      res[i] = arr[i];
    }
    return res;
  }

  function toDynamicArray(uint256[5] memory arr) internal pure returns (uint256[] memory) {
    uint256[] memory res = new uint256[](5);
    uint256 length = arr.length;
    for (uint i = 0; i < length; i++) {
      res[i] = arr[i];
    }
    return res;
  }

  function toDynamicArray(uint256[6] memory arr) internal pure returns (uint256[] memory) {
    uint256[] memory res = new uint256[](6);
    uint256 length = arr.length;
    for (uint i = 0; i < length; i++) {
      res[i] = arr[i];
    }
    return res;
  }

  function beforeDeposit(
    bytes[3] memory _proofs,
    DepositArgs memory _args,
    bytes memory _treeUpdateProof,
    TreeUpdateArgs memory _treeUpdateArgs
  ) internal {
    validateAccountUpdate(_args.account, _treeUpdateProof, _treeUpdateArgs);
    require(_args.extDataHash == keccak248(abi.encode(_args.extData)), "Incorrect external data hash");
    require(_args.unitPerUnderlying >= unitPerUnderlying(), "Underlying per unit is overstated");
    require(
      depositVerifier.verifyProof(
        _proofs[0],
        toDynamicArray([
          uint256(_args.amount),
          uint256(_args.debt),
          uint256(_args.unitPerUnderlying),
          uint256(_args.extDataHash),
          uint256(_args.account.inputAccountHash),
          uint256(_args.account.outputAccountHash)
        ])
      ),
      "Invalid deposit proof"
    );
    require(
      inputRootVerifier.verifyProof(
        _proofs[1],
        toDynamicArray([
          uint256(_args.account.inputRoot),
          uint256(_args.account.inputNullifierHash),
          uint256(_args.account.inputAccountHash)
        ])
      ),
      "Invalid input root proof"
    );
    require(
      outputRootVerifier.verifyProof(
        _proofs[2],
        toDynamicArray([
          uint256(_args.account.inputRoot),
          uint256(_args.account.outputRoot),
          uint256(_args.account.outputPathIndices),
          uint256(_args.account.outputCommitment),
          uint256(_args.account.outputAccountHash)
        ])
      ),
      "Invalid output root proof"
    );

    accountNullifiers[_args.account.inputNullifierHash] = true;
    insertAccountRoot(_args.account.inputRoot == getLastAccountRoot() ? _args.account.outputRoot : _treeUpdateArgs.newRoot);

    emit NewAccount(
      _args.account.outputCommitment,
      _args.account.inputNullifierHash,
      _args.extData.encryptedAccount,
      accountCount - 1
    );
  }

  function beforeWithdraw(
    bytes[3] memory _proofs,
    WithdrawArgs memory _args,
    bytes memory _treeUpdateProof,
    TreeUpdateArgs memory _treeUpdateArgs
  ) internal {
    validateAccountUpdate(_args.account, _treeUpdateProof, _treeUpdateArgs);
    require(_args.extDataHash == keccak248(abi.encode(_args.extData)), "Incorrect external data hash");
    require(_args.amount < 2**248, "Amount value out of range");
    require(_args.debt < 2**248, "Debt value out of range");
    require(_args.amount >= _args.extData.fee, "Amount should be >= than fee");
    require(_args.unitPerUnderlying >= unitPerUnderlying(), "Underlying per unit is overstated");
    require(
      withdrawVerifier.verifyProof(
        _proofs[0],
        toDynamicArray([
          uint256(_args.amount),
          uint256(_args.debt),
          uint256(_args.unitPerUnderlying),
          uint256(_args.extDataHash),
          uint256(_args.account.inputAccountHash),
          uint256(_args.account.outputAccountHash)
        ])
      ),
      "Invalid withdrawal proof"
    );
    require(
      inputRootVerifier.verifyProof(
        _proofs[1],
        toDynamicArray([
          uint256(_args.account.inputRoot),
          uint256(_args.account.inputNullifierHash),
          uint256(_args.account.inputAccountHash)
        ])
      ),
      "Invalid input root proof"
    );
    require(
      outputRootVerifier.verifyProof(
        _proofs[2],
        toDynamicArray([
          uint256(_args.account.inputRoot),
          uint256(_args.account.outputRoot),
          uint256(_args.account.outputPathIndices),
          uint256(_args.account.outputCommitment),
          uint256(_args.account.outputAccountHash)
        ])
      ),
      "Invalid output root proof"
    );

    insertAccountRoot(_args.account.inputRoot == getLastAccountRoot() ? _args.account.outputRoot : _treeUpdateArgs.newRoot);
    accountNullifiers[_args.account.inputNullifierHash] = true;

    emit NewAccount(
      _args.account.outputCommitment,
      _args.account.inputNullifierHash,
      _args.extData.encryptedAccount,
      accountCount - 1
    );
  }


  function isKnownAccountRoot(bytes32 _root, uint256 _index) public view returns (bool) {
    return _root != 0 && accountRoots[_index % ACCOUNT_ROOT_HISTORY_SIZE] == _root;
  }

  function getLastAccountRoot() public view returns (bytes32) {
    return accountRoots[accountCount % ACCOUNT_ROOT_HISTORY_SIZE];
  }

  function unitPerUnderlying() public view virtual returns (uint256) {
    return 1;
  }


  function keccak248(bytes memory _data) internal pure returns (bytes32) {
    return keccak256(_data) & 0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
  }

  function validateTreeUpdate(
    bytes memory _proof,
    TreeUpdateArgs memory _args,
    bytes32 _commitment
  ) internal view {
    require(_proof.length > 0, "Outdated account merkle root");
    require(_args.oldRoot == getLastAccountRoot(), "Outdated tree update merkle root");
    require(_args.leaf == _commitment, "Incorrect commitment inserted");
    require(_args.pathIndices == accountCount, "Incorrect account insert index");
    require(
      treeUpdateVerifier.verifyProof(
        _proof,
        toDynamicArray([uint256(_args.oldRoot), uint256(_args.newRoot), uint256(_args.leaf), uint256(_args.pathIndices)])
      ),
      "Invalid tree update proof"
    );
  }

  function validateAccountUpdate(
    AccountUpdate memory _account,
    bytes memory _treeUpdateProof,
    TreeUpdateArgs memory _treeUpdateArgs
  ) internal view {
    require(!accountNullifiers[_account.inputNullifierHash], "Outdated account state");
    if (_account.inputRoot != getLastAccountRoot()) {
      require(isKnownAccountRoot(_account.inputRoot, _account.outputPathIndices), "Invalid account root");
      validateTreeUpdate(_treeUpdateProof, _treeUpdateArgs, _account.outputCommitment);
    } else {
      require(_account.outputPathIndices == accountCount, "Incorrect account insert index");
    }
  }

  function insertAccountRoot(bytes32 _root) internal {
    accountRoots[++accountCount % ACCOUNT_ROOT_HISTORY_SIZE] = _root;
  }
}// MIT

pragma solidity ^0.8.0;



contract PoofVal is PoofBase {
  using SafeMath for uint256;

  constructor(
    IVerifier[5] memory _verifiers,
    bytes32 _accountRoot
  ) PoofBase(_verifiers, _accountRoot) {}

  function deposit(bytes[3] memory _proofs, DepositArgs memory _args) external payable virtual {
    require(_args.debt == 0, "Cannot use debt for depositing");
    deposit(_proofs, _args, new bytes(0), TreeUpdateArgs(0, 0, 0, 0));
  }

  function deposit(
    bytes[3] memory _proofs,
    DepositArgs memory _args,
    bytes memory _treeUpdateProof,
    TreeUpdateArgs memory _treeUpdateArgs
  ) public payable virtual {
    beforeDeposit(_proofs, _args, _treeUpdateProof, _treeUpdateArgs);
    require(msg.value == _args.amount, "Specified amount must equal msg.value");
  }

  function withdraw(bytes[3] memory _proofs, WithdrawArgs memory _args) external virtual {
    require(_args.debt == 0, "Cannot use debt for withdrawing");
    withdraw(_proofs, _args, new bytes(0), TreeUpdateArgs(0, 0, 0, 0));
  }

  function withdraw(
    bytes[3] memory _proofs,
    WithdrawArgs memory _args,
    bytes memory _treeUpdateProof,
    TreeUpdateArgs memory _treeUpdateArgs
  ) public virtual {
    beforeWithdraw(_proofs, _args, _treeUpdateProof, _treeUpdateArgs);
    uint256 amount = _args.amount.sub(_args.extData.fee, "Amount should be greater than fee");
    if (amount > 0) {
      (bool ok, ) = _args.extData.recipient.call{value: amount}("");
      require(ok, "Failed to send amount to recipient");
    }
    if (_args.extData.fee > 0) {
      (bool ok, ) = _args.extData.relayer.call{value: _args.extData.fee}("");
      require(ok, "Failed to send fee to relayer");
    }
  }
}// MIT

pragma solidity ^0.8.0;


interface IWERC20Val is IERC20 {
  function wrap() payable external;

  function unwrap(uint256 debtAmount) external;

  function underlyingToDebt(uint256 underlyingAmount) external view returns (uint256);

  function debtToUnderlying(uint256 debtAmount) external view returns (uint256);

  function underlyingBalanceOf(address owner) external view returns (uint256);
}// MIT

pragma solidity ^0.8.0;



contract PoofValLendable is PoofVal {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  IWERC20Val public debtToken;

  constructor(
    IWERC20Val _debtToken,
    IVerifier[5] memory _verifiers,
    bytes32 _accountRoot
  ) PoofVal(_verifiers, _accountRoot) {
    debtToken = _debtToken;
  }

  function deposit(bytes[3] memory _proofs, DepositArgs memory _args) external payable override {
    deposit(_proofs, _args, new bytes(0), TreeUpdateArgs(0, 0, 0, 0));
  }

  function deposit(
    bytes[3] memory _proofs,
    DepositArgs memory _args,
    bytes memory _treeUpdateProof,
    TreeUpdateArgs memory _treeUpdateArgs
  ) public payable override {
    beforeDeposit(_proofs, _args, _treeUpdateProof, _treeUpdateArgs);
    uint256 underlyingAmount = debtToken.debtToUnderlying(_args.amount);
    require(msg.value >= underlyingAmount, "Specified amount must equal msg.value");
    debtToken.wrap{value: underlyingAmount}();
    (bool ok, ) = 
      msg.sender.call{value: address(this).balance}(""); 
    require(ok, "Failed to refund leftover balance to caller");
  }

  function withdraw(bytes[3] memory _proofs, WithdrawArgs memory _args) external override {
    withdraw(_proofs, _args, new bytes(0), TreeUpdateArgs(0, 0, 0, 0));
  }

  function withdraw(
    bytes[3] memory _proofs,
    WithdrawArgs memory _args,
    bytes memory _treeUpdateProof,
    TreeUpdateArgs memory _treeUpdateArgs
  ) public override {
    beforeWithdraw(_proofs, _args, _treeUpdateProof, _treeUpdateArgs);
    require(_args.amount >= _args.extData.fee, "Fee cannot be greater than amount");
    uint256 underlyingAmount = debtToken.debtToUnderlying(_args.amount.sub(_args.extData.fee));
    uint256 underlyingFeeAmount = debtToken.debtToUnderlying(_args.extData.fee);
    debtToken.unwrap(_args.amount);

    if (underlyingAmount > 0) {
      (bool ok, ) = _args.extData.recipient.call{value: underlyingAmount}("");
      require(ok, "Failed to send amount to recipient");
    }
    if (underlyingFeeAmount > 0) {
      (bool ok, ) = _args.extData.relayer.call{value: underlyingFeeAmount}("");
      require(ok, "Failed to send fee to relayer");
    }
  }

  function unitPerUnderlying() public view override returns (uint256) {
    return debtToken.underlyingToDebt(1);
  }

  receive() external payable {}
}// MIT

pragma solidity ^0.8.0;



contract PoofValMintableLendable is PoofValLendable, ERC20 {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  constructor(
    string memory _tokenName,
    string memory _tokenSymbol,
    IWERC20Val _debtToken,
    IVerifier[5] memory _verifiers,
    bytes32 _accountRoot
  ) ERC20(_tokenName, _tokenSymbol) PoofValLendable(_debtToken, _verifiers, _accountRoot) {}

  function burn(bytes[3] memory _proofs, DepositArgs memory _args) external {
    burn(_proofs, _args, new bytes(0), TreeUpdateArgs(0, 0, 0, 0));
  }

  function burn(
    bytes[3] memory _proofs,
    DepositArgs memory _args,
    bytes memory _treeUpdateProof,
    TreeUpdateArgs memory _treeUpdateArgs
  ) public {
    beforeDeposit(_proofs, _args, _treeUpdateProof, _treeUpdateArgs);
    require(_args.amount == 0, "Cannot use amount for burning");
    _burn(msg.sender, _args.debt);
  }

  function mint(bytes[3] memory _proofs, WithdrawArgs memory _args) external {
    mint(_proofs, _args, new bytes(0), TreeUpdateArgs(0, 0, 0, 0));
  }

  function mint(
    bytes[3] memory _proofs,
    WithdrawArgs memory _args,
    bytes memory _treeUpdateProof,
    TreeUpdateArgs memory _treeUpdateArgs
  ) public {
    beforeWithdraw(_proofs, _args, _treeUpdateProof, _treeUpdateArgs);
    require(_args.amount == _args.extData.fee, "Amount can only be used for fee");
    if (_args.amount > 0) {
      uint256 underlyingFeeAmount = debtToken.debtToUnderlying(_args.extData.fee);
      debtToken.unwrap(_args.amount);
      if (underlyingFeeAmount > 0) {
        (bool ok, ) = _args.extData.relayer.call{value: underlyingFeeAmount}("");
        require(ok, "Failed to send fee to relayer");
      }
    }
    if (_args.debt > 0) {
      _mint(_args.extData.recipient, _args.debt);
    }
  }

  function underlyingBalanceOf(address owner) external view returns (uint256) {
    uint256 balanceOf = balanceOf(owner);
    return debtToken.debtToUnderlying(balanceOf);
  }
}