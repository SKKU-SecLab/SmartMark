

pragma solidity 0.7.5;

interface IAvnFTTreasury {

  event LogFTTreasuryPermissionUpdated(address indexed treasurer, bool status);

  function setTreasurerPermission(address treasurer, bool status) external;

  function getTreasurers() external view returns(address[] memory);

  function unlockERC777Tokens(address token, uint256 amount, bytes calldata data) external;

  function unlockERC20Tokens(address token, uint256 amount) external;

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






contract AvnFTTreasury is IAvnFTTreasury, Owned {


  IERC1820Registry constant internal ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
  bytes32 constant internal ERC777_TOKENS_RECIPIENT_HASH = 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

  mapping (address => bool) public isPermitted;
  address[] public treasurers;

  modifier onlyPermitted() {

    require(isPermitted[msg.sender], "FT Treasury access not permitted");
    _;
  }

  constructor()
  {
    ERC1820_REGISTRY.setInterfaceImplementer(address(this), ERC777_TOKENS_RECIPIENT_HASH, address(this));
  }

  function setTreasurerPermission(address _treasurer, bool _status)
    onlyOwner
    external
    override
  {

    if (_status == isPermitted[_treasurer])
      return;
    else if (_status) {
      isPermitted[_treasurer] = true;
      treasurers.push(_treasurer);
    } else {
      isPermitted[_treasurer] = false;
      uint256 endTreasurer = treasurers.length - 1;
      for (uint256 i; i < endTreasurer; i++) {
        if (treasurers[i] == _treasurer) {
          treasurers[i] = treasurers[endTreasurer];
          break;
        }
      }
      treasurers.pop();
    }
    emit LogFTTreasuryPermissionUpdated(_treasurer, _status);
  }

  function getTreasurers()
    external
    view
    override
    returns (address[] memory)
  {

    return treasurers;
  }

  function tokensReceived(address _operator, address /*_from*/, address _to, uint256 /*_amount*/, bytes calldata /*_data*/,
      bytes calldata /* _operatorData */)
    external
    view
  {

    require(isPermitted[_operator], "Requires permission");
    assert(_to == address(this)); // will not reach this if permissions are handled correctly
  }

  function unlockERC777Tokens(address _token, uint256 _amount, bytes calldata _data)
    onlyPermitted
    external
    override
  {

    IERC777(_token).send(msg.sender, _amount, _data);
  }

  function unlockERC20Tokens(address _token, uint256 _amount)
    onlyPermitted
    external
    override
  {

    assert(IERC20(_token).transfer(msg.sender, _amount));
  }
}