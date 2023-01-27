
pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library StringsUpgradeable {

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}//Unlicense
pragma solidity 0.7.3;

contract BabelConstant {

  uint256 constant MAX_GENESIS = 98;
  uint256 constant MAX_ONE_BUY = 2;

  uint256 constant SALE_TIMESTAMP = 1619974800;
  uint256 constant REVEAL_TIMESTAMP = 1621184400;

  bytes32 constant provenance = 0xb448568b1a29d7f2c77860bfe48f041f128e394e720fc27b91be3991005b7164;
}//Unlicense
pragma solidity 0.7.3;




interface IERC20BurnableUpgradeable is IERC20Upgradeable{

  function burn(uint256 amount) external;

}
contract BabelGenesisMetadataImplementation is OwnableUpgradeable, BabelConstant{


  using SafeMathUpgradeable for uint256;
  using StringsUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20BurnableUpgradeable;


  struct Ape {
    string name;              // Cannot overlap, max 25.
    string message;           // Can overlap, max 50.
    uint256 level;            // Ape's level
    uint256 coordLattitude;   // -90 ~ 90   => 0 ~ 180  => 0 ~ 180,000
    uint256 coordLongitude;   // -180 ~ 180 => 0 ~ 360  => 0 ~ 360,000
    uint256 coordElevation;   // 0 ~ 55,757,930,000     => 0 ~ 55,757,930,000,000
    uint256 coordTimestamp;   // when did the ape move here
    uint256 themeId;          //
  }

  event StartIndexFinalized(address finalizer, uint256 startIndex);
  event AddArtForToken(uint256 indexed id, string uri);
  event RemoveArtForToken(uint256 indexed id, string uri);
  event ArtUpdatedForToken(uint256 indexed id, string uri);

  event NameChange(uint256 tokenId, string newName);
  event MsgChange(uint256 tokenId, string newName);

  string public uriBeforeReveal;
  string public baseUri;
  uint256 public startingIndexBlock;
  uint256 public startingIndex;
  bool revealFlag;

  address public babelGenesis;
  address public babelTheme;
  address public babelToken;

  mapping (uint256 => Ape) public apeData;
  mapping (string => bool) public isNameReserved;

  mapping (uint256 => mapping(bytes32 => bool)) public availableURIs;
  mapping (uint256 => string) public tokenSpecificURI;

  uint256 public NAME_CHANGE_PRICE;
  uint256 public MSG_CHANGE_PRICE;
  uint256 public LOC_CHANGE_PRICE;

  modifier onlyNFTOwner(uint256 id) {

    require(msg.sender == IERC721Upgradeable(babelGenesis).ownerOf(id), "Caller is not the owner of NFT");
    _;
  }

  modifier onlyNFTContract() {

    require(msg.sender == babelGenesis, "Caller is not the NFT contract");
    _;
  }

  constructor() {}

  function initialize(address _bg, address _bt) public initializer {

    __Ownable_init();
    babelGenesis = _bg;
    babelToken = _bt;
    NAME_CHANGE_PRICE = 365 * (10 ** 18);
    MSG_CHANGE_PRICE = 365 * (10 ** 18);
    LOC_CHANGE_PRICE = 365 * (10 ** 18);
  }

  function setBaseURI(string memory _baseUri) onlyOwner public {

    baseUri = _baseUri;
  }

  function setUriBeforeReveal(string memory _newUriBeforeReveal) onlyOwner public {

    uriBeforeReveal = _newUriBeforeReveal;
  }


  function tokenURI(uint256 tokenId) public view virtual returns (string memory) {

    string memory base = baseUri;
    if(!revealFlag || bytes(base).length == 0){
      return uriBeforeReveal;
    } else {
      if(bytes(tokenSpecificURI[tokenId]).length == 0){
        uint256 finalQueryId = tokenId;
        if( tokenId <= MAX_GENESIS && tokenId > 0 ){
            finalQueryId = ((tokenId.add(startingIndex)) % MAX_GENESIS).add(1);
            return string(abi.encodePacked(base, finalQueryId.toString()));
        } else {
          return "NOT DEFINED.";
        }
      } else {
        return tokenSpecificURI[tokenId];
      }
    }
  }

  function addArtForToken(uint256 id, string memory newArtUri) public onlyOwner {

    availableURIs[id][bytes32(keccak256(bytes(newArtUri)))] = true;
    emit AddArtForToken(id, newArtUri);
  }

  function removeArtForToken(uint256 id, string memory newArtUri) public onlyOwner {

    availableURIs[id][bytes32(keccak256(bytes(newArtUri)))] = false;
    emit RemoveArtForToken(id, newArtUri);
  }

  function switchToArtForToken(uint256 id, string memory newArtUri) public onlyNFTOwner(id) {

    if(bytes(newArtUri).length != 0) {
      require(availableURIs[id][bytes32(keccak256(bytes(newArtUri)))], "Specified URI is not available for this token");
      tokenSpecificURI[id] = newArtUri;
    } else {
      tokenSpecificURI[id] = "";
    }
    emit ArtUpdatedForToken(id, newArtUri);
  }

  function changeLocation(uint256 id, uint256 lattitude, uint256 longtitude, uint256 elevation) public onlyNFTOwner(id) {

    IERC20BurnableUpgradeable(babelToken).safeTransferFrom(msg.sender, address(this), LOC_CHANGE_PRICE);
    IERC20BurnableUpgradeable(babelToken).burn(LOC_CHANGE_PRICE);

    require(lattitude  <= 180000, "lattitude out of range");
    require(longtitude <= 360000, "longtitude out of range");
    require(elevation  <= 55757930000000, "elevation out of range");

    apeData[id].coordLattitude = lattitude;
    apeData[id].coordLongitude = longtitude;
    apeData[id].coordElevation = elevation;
    apeData[id].coordTimestamp = block.timestamp;
  }

  function changeTheme(uint256 id, uint256 themeId) public onlyNFTOwner(id) {

    revert(" More to come :) ");
  }

  function changeName(uint256 id, string memory _name) public onlyNFTOwner(id) {

    require(checkValidName(_name), "Name is not valid");
    require(isNameReserved[toLower(_name)] == false, "Name already reserved");

    IERC20BurnableUpgradeable(babelToken).transferFrom(msg.sender, address(this), NAME_CHANGE_PRICE);
    if (bytes(apeData[id].name).length > 0) {
      toggleReserveName(apeData[id].name, false);
    }
    toggleReserveName(_name, true);
    apeData[id].name = _name;
    IERC20BurnableUpgradeable(babelToken).burn(NAME_CHANGE_PRICE);
    emit NameChange(id, _name);
  }

  function checkValidName(string memory _name) public pure returns(bool) {

    bytes memory b = bytes(_name);
    if(b.length < 1) return false;
    if(b.length > 25) return false; // Cannot be longer than 25 characters
    if(b[0] == 0x20) return false; // Leading space
    if (b[b.length - 1] == 0x20) return false; // Trailing space

    bytes1 lastChar = b[0];

    for(uint i; i<b.length; i++){
      bytes1 char = b[i];

      if (char == 0x20 && lastChar == 0x20) return false; // Cannot contain continous spaces

      if(
        !(char >= 0x30 && char <= 0x39) && //9-0
        !(char >= 0x41 && char <= 0x5A) && //A-Z
        !(char >= 0x61 && char <= 0x7A) && //a-z
        !(char == 0x20) //space
      )
        return false;

      lastChar = char;
    }

    return true;
  }

  function changeMessage(uint256 id, string memory _msg) public onlyNFTOwner(id) {

    require(checkValidMessage(_msg), "Name is not valid");
    IERC20BurnableUpgradeable(babelToken).transferFrom(msg.sender, address(this), MSG_CHANGE_PRICE);
    apeData[id].message = _msg;
    IERC20BurnableUpgradeable(babelToken).burn(MSG_CHANGE_PRICE);
    emit MsgChange(id, _msg);
  }

  function checkValidMessage(string memory _name) public view returns(bool) {

    bytes memory b = bytes(_name);
    if(b.length < 1) return false;
    if(b.length > 280) return false; // Cannot be longer than 280 characters

    for(uint i; i<b.length; i++){
      bytes1 char = b[i];

      if(
        !(char >= 0x30 && char <= 0x39) && //9-0
        !(char >= 0x41 && char <= 0x5A) && //A-Z
        !(char >= 0x61 && char <= 0x7A) && //a-z
        !(char >= 0x20 && char <= 0x29)
      )
        return false;

    }
    return true;
  }

  function toggleReserveName(string memory str, bool isReserve) internal {

    isNameReserved[toLower(str)] = isReserve;
  }

  function toLower(string memory str) public pure returns (string memory){

    bytes memory bStr = bytes(str);
    bytes memory bLower = new bytes(bStr.length);
    for (uint i = 0; i < bStr.length; i++) {
      if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
        bLower[i] = bytes1(uint8(bStr[i]) + 32);
      } else {
        bLower[i] = bStr[i];
      }
    }
    return string(bLower);
  }

  function checkUpdateStartingIndexBlock(bool soldOut) public onlyNFTContract {

    if (startingIndexBlock == 0 && (soldOut || block.timestamp >= REVEAL_TIMESTAMP)) {
      startingIndexBlock = block.number;
    }
  }

  function finalizeStartingIndex() public {

    require(startingIndex == 0, "Starting index is already set");
    require(startingIndexBlock != 0, "Starting index block must be set");

    startingIndex = uint(blockhash(startingIndexBlock)) % MAX_GENESIS;
    if (block.number.sub(startingIndexBlock) > 255) {
        startingIndex = uint(blockhash(block.number-1)) % MAX_GENESIS;
    }
    if (startingIndex == 0) {
        startingIndex = startingIndex.add(1);
    }

    emit StartIndexFinalized(msg.sender, startingIndex);
  }

  function reveal() public onlyOwner {

    revealFlag = true;
  }

}