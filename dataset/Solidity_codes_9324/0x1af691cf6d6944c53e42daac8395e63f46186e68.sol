

pragma solidity 0.7.5;

interface IAvnStorage {

  event LogStoragePermissionUpdated(address indexed publisher, bool status);

  function setStoragePermission(address publisher, bool status) external;

  function storeT2TransactionId(uint256 _t2TransactionId) external;

  function storeT2TransactionIdAndRoot(uint256 _t2TransactionId, bytes32 rootHash) external;

  function confirmLeaf(bytes32 leafHash, bytes32[] memory merklePath) external view returns (bool);

}



pragma solidity 0.7.5;

interface IAvnFTScalingManager {

  event LogLifted(address indexed token, address indexed t1Address, bytes32 indexed t2PublicKey, uint256 amount, uint256 nonce);
  event LogLowered(address indexed token, address indexed t1Address, bytes32 indexed t2PublicKey, uint256 amount,
    bytes32 leafHash);

  function disableLift(bool _isDisabled) external;

  function lift(address erc20Contract, bytes32 t2PublicKey, uint256 amount) external;

  function lower(bytes calldata encodedLeaf, bytes32[] calldata merklePath) external;

  function confirmT2Transaction(bytes32 leafHash, bytes32[] memory merklePath) external view returns (bool);

  function retire() external;

}



pragma solidity 0.7.5;

interface IAvnFTTreasury {

  event LogFTTreasuryPermissionUpdated(address indexed treasurer, bool status);

  function setTreasurerPermission(address treasurer, bool status) external;

  function getTreasurers() external view returns(address[] memory);

  function unlockERC777Tokens(address token, uint256 amount, bytes calldata data) external;

  function unlockERC20Tokens(address token, uint256 amount) external;

}



pragma solidity 0.7.5;

interface IERC20 {

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function name() external view returns (string memory); // optional method - see eip spec

  function symbol() external view returns (string memory); // optional method - see eip spec

  function decimals() external view returns (uint8); // optional method - see eip spec

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

}



pragma solidity 0.7.5;

interface IERC777 {

  event Sent(address indexed operator, address indexed from, address indexed to, uint256 amount, bytes data,
      bytes operatorData);
  event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);
  event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);
  event AuthorizedOperator(address indexed operator,address indexed holder);
  event RevokedOperator(address indexed operator, address indexed holder);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function totalSupply() external view returns (uint256);

  function balanceOf(address holder) external view returns (uint256);

  function granularity() external view returns (uint256);

  function defaultOperators() external view returns (address[] memory);

  function isOperatorFor(address operator, address holder) external view returns (bool);

  function authorizeOperator(address operator) external;

  function revokeOperator(address operator) external;

  function send(address to, uint256 amount, bytes calldata data) external;

  function operatorSend(address from, address to, uint256 amount, bytes calldata data, bytes calldata operatorData) external;

  function burn(uint256 amount, bytes calldata data) external;

  function operatorBurn( address from, uint256 amount, bytes calldata data, bytes calldata operatorData) external;

}




pragma solidity >=0.6.0 <0.8.0;

interface IERC1820Registry {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(address account, bytes32 _interfaceHash, address implementer) external;


    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}




pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity 0.7.5;

contract Owned {


  address public owner = msg.sender;

  event LogOwnershipTransferred(address indexed owner, address indexed newOwner);

  modifier onlyOwner {

    require(msg.sender == owner, "Only owner");
    _;
  }

  function setOwner(address _owner)
    external
    onlyOwner
  {

    require(_owner != address(0), "Owner cannot be zero address");
    emit LogOwnershipTransferred(owner, _owner);
    owner = _owner;
  }
}



pragma solidity 0.7.5;









contract AvnFTScalingManager is IAvnFTScalingManager, Owned {

  using SafeMath for uint256;

  struct LeafData {
    bytes t2Data;
    bytes abiEncodedT2Data;
  }

  struct T1LowerData {
    address token;
    bytes32 fromT2PublicKey;
    bytes32 toT2PublicKey;
    uint256 amount;
    address t1LowerAddress;
  }

  IERC1820Registry constant internal ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
  bytes32 constant internal ERC777_TOKEN_HASH = 0xac7fbab5f54a3ca8194167523c6753bfeb96a445279294b6125b68cce2177054;
  bytes32 constant internal ERC777_TOKENS_RECIPIENT_HASH = 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

  bytes32 constant internal T2_BURN_PUBLIC_KEY = 0x000000000000000000000000000000000000000000000000000000000000dead;
  uint256 constant internal LIFT_LIMIT = type(uint128).max;

  IAvnStorage immutable public avnStorage;
  IAvnFTTreasury immutable public avnFTTreasury;

  uint256 public liftNonce;
  bool public liftDisabled;

  mapping (bytes32 => bool) public hasLowered;

  constructor(IAvnStorage _avnStorage, IAvnFTTreasury _avnFTTreasury)
  {
    ERC1820_REGISTRY.setInterfaceImplementer(address(this), ERC777_TOKENS_RECIPIENT_HASH, address(this));
    avnStorage = _avnStorage;
    avnFTTreasury = _avnFTTreasury;
  }

  modifier onlyWhenLiftEnabled() {

    require(!liftDisabled, "Lifting currently disabled");
    _;
  }

  function disableLift(bool _isDisabled)
    onlyOwner
    external
    override
  {

    liftDisabled = _isDisabled;
  }

  function lift(address _erc20Contract, bytes32 _t2PublicKey, uint256 _amount)
    onlyWhenLiftEnabled
    external
    override
  {

    require(_amount > 0, "Cannot lift zero ERC20 tokens");
    require(IERC20(_erc20Contract).balanceOf(address(avnFTTreasury)).add(_amount) <= LIFT_LIMIT, "Exceeds ERC20 lift limit");
    lockERC20TokensInTreasury(_erc20Contract, _amount);
    emit LogLifted(_erc20Contract, msg.sender, _t2PublicKey, _amount, ++liftNonce);
  }

  function lower(bytes calldata _encodedLeaf, bytes32[] calldata _merklePath)
    external
    override
  {

    bytes32 leafHash = keccak256(_encodedLeaf);
    require(avnStorage.confirmLeaf(leafHash, _merklePath), "Leaf or path invalid");
    require(!hasLowered[leafHash], "Already lowered");
    hasLowered[leafHash] = true;

    LeafData memory leafData;
    (leafData.t2Data, leafData.abiEncodedT2Data) = abi.decode(_encodedLeaf, (bytes, bytes));
    T1LowerData memory t1Data;
    (t1Data.token, t1Data.fromT2PublicKey, t1Data.toT2PublicKey, t1Data.amount, t1Data.t1LowerAddress) =
        abi.decode(leafData.abiEncodedT2Data, (address, bytes32, bytes32, uint256, address));
    require(t1Data.toT2PublicKey == T2_BURN_PUBLIC_KEY, "Must have burned to lower");

    if (ERC1820_REGISTRY.getInterfaceImplementer(t1Data.token, ERC777_TOKEN_HASH) == t1Data.token)
      unlockERC777TokensFromTreasury(t1Data.token, t1Data.t1LowerAddress, t1Data.amount, _encodedLeaf);
    else
      unlockERC20TokensFromTreasury(t1Data.token, t1Data.t1LowerAddress, t1Data.amount);

    emit LogLowered(t1Data.token, t1Data.t1LowerAddress, t1Data.fromT2PublicKey, t1Data.amount, leafHash);
  }

  function tokensReceived(address _operator, address _from, address _to, uint256 _amount, bytes calldata _data,
      bytes calldata /* _operatorData */)
    onlyWhenLiftEnabled
    external
  {

    if (_operator == address(this)) return; // This is an ERC20 lift operation - ignore
    if (_operator == address(avnFTTreasury)) return; // These are funds being unlocked by the treasury - ignore
    require(_amount > 0, "Cannot lift zero ERC777 tokens");
    require(_to == address(this), "Tokens must be sent to this contract");
    require(ERC1820_REGISTRY.getInterfaceImplementer(msg.sender, ERC777_TOKEN_HASH) == msg.sender, "Token must be registered");
    require(IERC777(msg.sender).balanceOf(address(avnFTTreasury)).add(_amount) <= LIFT_LIMIT, "Exceeds ERC777 lift limit");

    IERC777(msg.sender).send(address(avnFTTreasury), _amount, _data);
    emit LogLifted(msg.sender, _from, abi.decode(_data, (bytes32)), _amount, ++liftNonce);
  }

  function confirmT2Transaction(bytes32 _leafHash, bytes32[] memory _merklePath)
    external
    view
    override
    returns (bool)
  {

    return avnStorage.confirmLeaf(_leafHash, _merklePath);
  }

  function retire()
    onlyOwner
    external
    override
  {

    selfdestruct(payable(owner));
  }

  function unlockERC777TokensFromTreasury(address _erc777Contract, address _recipient, uint256 _amount, bytes memory _data)
    private
  {

    IAvnFTTreasury(avnFTTreasury).unlockERC777Tokens(_erc777Contract, _amount, _data);
    IERC777(_erc777Contract).send(_recipient, _amount, _data);
  }

  function unlockERC20TokensFromTreasury(address _erc20Contract, address _recipient, uint256 _amount)
    private
  {

    IAvnFTTreasury(avnFTTreasury).unlockERC20Tokens(_erc20Contract, _amount);
    assert(IERC20(_erc20Contract).transfer(_recipient, _amount));
  }

  function lockERC20TokensInTreasury(address _erc20Contract, uint256 _amount)
    private
  {

    IERC20 erc20Contract = IERC20(_erc20Contract);
    assert(erc20Contract.transferFrom(msg.sender, address(this), _amount));
    assert(erc20Contract.transfer(address(avnFTTreasury), _amount));
  }
}