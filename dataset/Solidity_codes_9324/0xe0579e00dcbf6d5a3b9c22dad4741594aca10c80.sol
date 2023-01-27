pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function migrateMint(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// UNLICENSED
pragma solidity ^0.8.0;

interface IToken {

  function bridgeMint(address to, uint amount) external returns (bool);

  function bridgeBurn(address owner, uint amount) external returns (bool);

}// MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT
pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT
pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// UNLICENSED
pragma solidity ^0.8.0;


contract BridgeBase is Ownable, Pausable {

  address public admin;
  IToken public token;
  mapping(address => mapping(uint => bool)) public processedNonces;

  enum Step { Burn, Mint }
  event Transfer(
    address from,
    address to,
    string operation,
    uint amount,
    uint date,
    uint nonce,
    bytes signature,
    Step indexed step
  );

  constructor(address _token) {
    admin = msg.sender;
    token = IToken(_token);
  }

  function setAdmin(address new_admin) external onlyOwner {

    require(new_admin != address(0), "zero address not allowed");
    admin = new_admin;
  }

  function burn(address to, uint amount, uint nonce, bytes calldata signature) external virtual {}


  function mint(
    address from, 
    address to, 
    uint amount, 
    uint nonce,
    bytes calldata signature
  ) external virtual {}


  function pauseContract() external virtual onlyOwner {

      _pause();
  }
  
  function unPauseContract() external virtual onlyOwner {

      _unpause();
  }

  function _beforeTokenTransfer() internal virtual {}


  function prefixed(bytes32 hash) internal pure returns (bytes32) {

    return keccak256(abi.encodePacked(
      '\x19Ethereum Signed Message:\n32', 
      hash
    ));
  }

  function recoverSigner(bytes32 message, bytes memory sig)
    internal
    pure
    returns (address)
  {

    uint8 v;
    bytes32 r;
    bytes32 s;
  
    (v, r, s) = splitSignature(sig);
  
    return ecrecover(message, v, r, s);
  }

  function splitSignature(bytes memory sig)
    internal
    pure
    returns (uint8, bytes32, bytes32)
  {

    require(sig.length == 65);
  
    bytes32 r;
    bytes32 s;
    uint8 v;
  
    assembly {
        r := mload(add(sig, 32))
        s := mload(add(sig, 64))
        v := byte(0, mload(add(sig, 96)))
    }
  
    return (v, r, s);
  }
}// UNLICENSED
pragma solidity ^0.8.0;


contract BridgeEth is BridgeBase {

  constructor(address token) BridgeBase(token) {}

  function burn(address to, uint amount, uint nonce, bytes calldata signature) external virtual override {

    _beforeTokenTransfer();
    bytes32 message = prefixed(keccak256(abi.encodePacked(
      msg.sender,
      to,
      'ETH-BURN',
      amount,
      nonce
    )));  
    require(recoverSigner(message, signature) == admin, 'wrong signature');
    require(processedNonces[msg.sender][nonce] == false, 'transfer already processed');
    processedNonces[msg.sender][nonce] = true;
    token.bridgeBurn(msg.sender, amount);
    emit Transfer(
      msg.sender,
      to,
      'ETH-BURN',
      amount,
      block.timestamp,
      nonce,
      signature,
      Step.Burn
    );
  }

  function mint(
    address from, 
    address to,
    uint amount, 
    uint nonce,
    bytes calldata signature
  ) external virtual override {

    _beforeTokenTransfer();
    bytes32 message = prefixed(keccak256(abi.encodePacked(
      from, 
      to,
      'ETH-MINT',
      amount,
      nonce
    )));
    require(recoverSigner(message, signature) == admin, 'wrong signature');
    require(processedNonces[from][nonce] == false, 'transfer already processed');
    processedNonces[from][nonce] = true;
    token.bridgeMint(to, amount);
    emit Transfer(
      from,
      to,
      'ETH-MINT',
      amount,
      block.timestamp,
      nonce,
      signature,
      Step.Mint
    );
  }

  function _beforeTokenTransfer() internal override { 

      require(!paused(), "ERC20Pausable: token transfer while contract paused");
  }
}