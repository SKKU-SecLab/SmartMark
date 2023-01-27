
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

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

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

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT
pragma solidity >0.8.0;


library NftTokenHandler {

  bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
  bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

  function isOwner(
      address nftContract, 
      uint256 tokenId, 
      address account 
  ) internal view returns (bool) {


      if(IERC165(nftContract).supportsInterface(_INTERFACE_ID_ERC721)) {
        return IERC721(nftContract).ownerOf(tokenId) == account;
      }

      if(IERC165(nftContract).supportsInterface(_INTERFACE_ID_ERC1155)) {
        return IERC1155(nftContract).balanceOf(account, tokenId) > 0;
      }

      return false;

  }

  function isApproved(
      address nftContract, 
      uint256 tokenId, 
      address owner, 
      address operator
    ) internal view returns (bool) {


      if(IERC165(nftContract).supportsInterface(_INTERFACE_ID_ERC721)) {
        return IERC721(nftContract).getApproved(tokenId) == operator;
      }

      if(IERC165(nftContract).supportsInterface(_INTERFACE_ID_ERC1155)) {
        return IERC1155(nftContract).isApprovedForAll(owner, operator);
      }

      return false;
    }

  function transfer(
      address nftContract, 
      uint256 tokenId, 
      address from, 
      address to, 
      bytes memory data 
    ) internal {


      if(IERC165(nftContract).supportsInterface(_INTERFACE_ID_ERC721)) {
        return IERC721(nftContract).safeTransferFrom(from, to, tokenId);
      }

      if(IERC165(nftContract).supportsInterface(_INTERFACE_ID_ERC1155)) {
        return IERC1155(nftContract).safeTransferFrom(from, to, tokenId, 1, data);
      }

      revert("Unidentified NFT contract.");
    }
}// MIT


contract NftMarket is AccessControl, ReentrancyGuard, Pausable {

  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  using SafeMath for uint256;
  address private serviceAccount;
  address private dealerOneTimeOperator;
  address public dealerContract;

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(ADMIN_ROLE, msg.sender);
    serviceAccount = msg.sender;
    dealerOneTimeOperator = msg.sender;
  }

  function alterServiceAccount(address account) public onlyRole(ADMIN_ROLE) {

    serviceAccount = account;
  }

  function alterDealerContract(address _dealerContract) public {

    require(msg.sender == dealerOneTimeOperator, "Permission Denied.");
    dealerOneTimeOperator = address(0);
    dealerContract = _dealerContract;
  }

  event Deal (
    address currency,
    address indexed nftContract,
    uint256 tokenId,
    address seller,
    address buyer,
    uint256 price,
    uint256 comission,
    uint256 roality,
    uint256 dealTime,
    bytes32 indexed tokenIndex,
    bytes32 indexed dealIndex
  );

  function pause() public onlyRole(ADMIN_ROLE) {

    _pause();
  }

  function unpause() public onlyRole(ADMIN_ROLE) {

    _unpause();
  }
  
  function indexToken(address nftContract, uint256 tokenId) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(nftContract, tokenId));
  }

  function indexDeal(bytes32 tokenIndex, address seller, address buyer, uint256 dealTime) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(tokenIndex, seller, buyer, dealTime));
  }

  function isMoneyApproved(IERC20 money, address account, uint256 amount) public view returns (bool) {

    if (money.allowance(account, address(this)) >= amount) return true;
    if (money.balanceOf(account) >= amount) return true;
    return false;
  }

  function isNftApproved(address nftContract, uint256 tokenId, address owner) public view returns (bool) {

    return NftTokenHandler.isApproved(nftContract, tokenId, owner, address(this));
  }

  function _dealPayments(
    uint256 price,
    uint256 comission,
    uint256 roality
  ) private pure returns (uint256[3] memory) {


    uint256 serviceFee = price
      .mul(comission).div(1000);

    uint256 roalityFee = roality > 0 ? 
      price.mul(roality).div(1000) : 0;

    uint256 sellerEarned = price
      .sub(serviceFee)
      .sub(roalityFee);

    return [sellerEarned, serviceFee, roalityFee];
  }

  function _payByPayable(address[3] memory receivers, uint256[3] memory payments) private {

      
    if(payments[0] > 0) payable(receivers[0]).transfer(payments[0]); // seller : sellerEarned
    if(payments[1] > 0) payable(receivers[1]).transfer(payments[1]); // serviceAccount : serviceFee
    if(payments[2] > 0) payable(receivers[2]).transfer(payments[2]); // roalityAccount : roalityFee
      
  }

  function _payByERC20(
    address erc20Contract, 
    address buyer,
    uint256 price,
    address[3] memory receivers, 
    uint256[3] memory payments) private {

    
    IERC20 money = IERC20(erc20Contract);
    require(money.balanceOf(buyer) >= price, "Buyer doesn't have enough money to pay.");
    require(money.allowance(buyer, address(this)) >= price, "Buyer allowance isn't enough.");

    money.transferFrom(buyer, address(this), price);
    if(payments[0] > 0) money.transfer(receivers[0], payments[0]); // seller : sellerEarned
    if(payments[0] > 0) money.transfer(receivers[1], payments[1]); // serviceAccount : serviceFee
    if(payments[0] > 0) money.transfer(receivers[2], payments[2]); // roalityAccount : roalityFee

  }

  function deal(
    address erc20Contract,
    address nftContract,
    uint256 tokenId,
    address seller,
    address buyer,
    uint256 price,
    uint256 comission,
    uint256 roality,
    address roalityAccount,
    bytes32 dealIndex
  ) 
    public 
    nonReentrant 
    whenNotPaused
    payable
  {

    require(msg.sender == dealerContract, "Permission Denied.");
    require(isNftApproved(nftContract, tokenId, seller), "Doesn't have approval of this token.");
    
    uint256[3] memory payments = _dealPayments(price, comission, roality);
    
    if(erc20Contract == address(0) && msg.value > 0) {
      require(msg.value == price, "Payment amount incorrect.");
      _payByPayable([seller, serviceAccount, roalityAccount], payments);
    } else {
      _payByERC20(erc20Contract, buyer, price, [seller, serviceAccount, roalityAccount], payments);
    }

    NftTokenHandler.transfer(nftContract, tokenId, seller, buyer, abi.encodePacked(dealIndex));
    
    emit Deal(
      erc20Contract,
      nftContract,
      tokenId,
      seller,
      buyer,
      price,
      payments[1],
      payments[2],
      block.timestamp,
      indexToken(nftContract, tokenId),
      dealIndex
    );
  }

}