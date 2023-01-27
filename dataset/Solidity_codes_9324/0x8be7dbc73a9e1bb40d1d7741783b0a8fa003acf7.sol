
pragma solidity 0.8.9;

library SafeMath {

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
}




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

    function toString(bytes32 value) internal pure returns (string memory) {

        uint8 i = 0;
        while(i < 32 && value[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && value[i] != 0; i++) {
            bytesArray[i] = value[i];
        }
        return string(bytesArray);
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
}




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
}




interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}




interface IRoleContainerRoot {

    function ROOT_ROLE() external view returns (bytes32);

}




interface IRoleContainerAdmin {

    function ADMIN_ROLE() external view returns (bytes32);

}




abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}



abstract contract ERC165Storage is ERC165 {
    mapping(bytes4 => bool) private _supportedInterfaces;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId) || _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}



abstract contract AccessControl is Context, ERC165Storage, IAccessControl, IRoleContainerAdmin {
    bytes32 public constant ROOT_ROLE = "Root";

    bytes32 public constant ADMIN_ROLE = "Admin";

    bytes32 public constant MANAGER_ROLE = "Manager";

    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    constructor() {
        _registerInterface(type(IAccessControl).interfaceId);

        _setupRole(ROOT_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _msgSender());
        _setRoleAdmin(MANAGER_ROLE, ROOT_ROLE);
    }

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
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
                        Strings.toString(role)
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

    function _setupRole(bytes32 role, address account) private {
        _grantRole(role, account);
        _setRoleAdmin(role, ROOT_ROLE);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}




interface IPausable {

    event Paused(address account);

    event Unpaused(address account);
    
    function paused() external view returns (bool);


    function pause() external;


    function unpause() external;

}




interface IRoleContainerPauser {

    function PAUSER_ROLE() external view returns (bytes32);

}



contract Pausable is AccessControl, IPausable, IRoleContainerPauser {

    bytes32 public constant PAUSER_ROLE = "Pauser";

    bool private _paused;

    constructor () {
        _registerInterface(type(IPausable).interfaceId);

        _setRoleAdmin(PAUSER_ROLE, ROOT_ROLE);

        _paused = true;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
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
   
    function _beforePause() internal virtual {

    }

    function _beforeUnpause() internal virtual {

    }

    function pause() external onlyRole(PAUSER_ROLE) whenNotPaused {

        _beforePause();
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) whenPaused {

        _beforeUnpause();
        _unpause();
    }
}




interface IWithdrawable {

    event Withdrawal(address to, string reason);
    event WithdrawalERC20(address asset, address to, string reason);
    event WithdrawalERC721(address asset, uint256[] ids, address to, string reason);
    event WithdrawalERC1155(address asset, uint256[] ids, address to, string reason);

    function withdraw(address payable to, string calldata reason) external;


    function withdrawERC20(address asset, address to, string calldata reason) external;


    function withdrawERC721(address asset, uint256[] calldata ids, address to, string calldata reason) external;


    function withdrawERC1155(address asset, uint256[] calldata ids, address to, string calldata reason) external;

}



abstract contract RequirementsChecker {
    uint256 internal constant inf = type(uint256).max;

    function _requireNonZeroAddress(address _address, string memory paramName) internal pure {
        require(_address != address(0), string(abi.encodePacked(paramName, ": cannot use zero address")));
    }

    function _requireArrayData(address[] memory _array, string memory paramName) internal pure {
        require(_array.length != 0, string(abi.encodePacked(paramName, ": cannot be empty")));
    }

    function _requireArrayData(uint256[] memory _array, string memory paramName) internal pure {
        require(_array.length != 0, string(abi.encodePacked(paramName, ": cannot be empty")));
    }

    function _requireStringData(string memory _string, string memory paramName) internal pure {
        require(bytes(_string).length != 0, string(abi.encodePacked(paramName, ": cannot be empty")));
    }

    function _requireSameLengthArrays(address[] memory _array1, uint256[] memory _array2, string memory paramName1, string memory paramName2) internal pure {
        require(_array1.length == _array2.length, string(abi.encodePacked(paramName1, ", ", paramName2, ": lengths must be equal")));
    }

    function _requireInRange(uint256 value, uint256 minValue, uint256 maxValue, string memory paramName) internal pure {
        string memory maxValueString = maxValue == inf ? "inf" : Strings.toString(maxValue);
        require(minValue <= value && (maxValue == inf || value <= maxValue), string(abi.encodePacked(paramName, ": must be in [", Strings.toString(minValue), "..", maxValueString, "] range")));
    }
}



interface IERC721Receiver is IERC165 {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}



abstract contract ERC721Holder is ERC165Storage, IERC721Receiver {

    constructor() {
        _registerInterface(type(IERC721Receiver).interfaceId);
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}



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

}



interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}



contract ERC1155Holder is ERC165Storage, IERC1155Receiver {


    constructor() {
        _registerInterface(type(IERC1155Receiver).interfaceId);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}



interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}



abstract contract Withdrawable is AccessControl, RequirementsChecker, ERC721Holder, ERC1155Holder, IWithdrawable {

    constructor () {
        _registerInterface(type(IWithdrawable).interfaceId);
    }

    function withdraw(address payable to, string calldata reason) external onlyRole(ADMIN_ROLE) {
        _requireNonZeroAddress(to, "to");
        _requireStringData(reason, "reason");
        _beforeWithdrawal(to);

        (bool success,) = to.call{value: address(this).balance}("");
        require(success, "Withdraw failed");
        emit Withdrawal(to, reason);
    }

    function withdrawERC20(address asset, address to, string calldata reason) external onlyRole(ADMIN_ROLE) {
        _requireNonZeroAddress(asset, "asset");
        _requireNonZeroAddress(to, "to");
        _requireStringData(reason, "reason");
        _beforeWithdrawalERC20(asset, to);

        IERC20 token = IERC20(asset);        
        token.transfer(to, token.balanceOf(address(this)));
        emit WithdrawalERC20(asset, to, reason);
    }

    function withdrawERC721(address asset, uint256[] calldata ids, address to, string calldata reason) external onlyRole(ADMIN_ROLE) {
        _requireNonZeroAddress(asset, "asset");
        _requireNonZeroAddress(to, "to");
        _requireArrayData(ids, "ids");
        _requireStringData(reason, "reason");
        _beforeWithdrawalERC721(asset, ids, to);

        IERC721 token = IERC721(asset);
        for(uint i = 0; i < ids.length; i++)
            token.safeTransferFrom(address(this), to, ids[i], "");
        emit WithdrawalERC721(asset, ids, to, reason);
    }

    function withdrawERC1155(address asset, uint256[] calldata ids, address to, string calldata reason) external onlyRole(ADMIN_ROLE) {
        _requireNonZeroAddress(asset, "asset");
        _requireNonZeroAddress(to, "to");
        _requireArrayData(ids, "ids");
        _requireStringData(reason, "reason");
        _beforeWithdrawalERC1155(asset, ids, to);

        IERC1155 token = IERC1155(asset);

        address[] memory addresses = new address[](ids.length);
        for(uint i = 0; i < ids.length; i++)
            addresses[i] = address(this); // actually only this one, but multiple times to call balanceOfBatch

        uint256[] memory balances = token.balanceOfBatch(addresses, ids);
        token.safeBatchTransferFrom(address(this), to, ids, balances, "");
        emit WithdrawalERC1155(asset, ids, to, reason);
    }

    function _beforeWithdrawal(address to) internal virtual {
    }

    function _beforeWithdrawalERC20(address asset, address to) internal virtual {
    }

    function _beforeWithdrawalERC721(address asset, uint256[] calldata ids, address to) internal virtual {
    }

    function _beforeWithdrawalERC1155(address asset, uint256[] calldata ids, address to) internal virtual {
    }
}




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
}



interface IFearWolf is IAccessControl {

    function setInitialOwner(address initialOwner, uint256 wolvesCount) external;

    function DISTRIBUTOR_ROLE() external view returns (bytes32);

}

contract FearWolfDistributor is AccessControl, Pausable, Withdrawable, ReentrancyGuard {

    using SafeMath for uint256;
    using Strings for uint256;

    event PresaleWolvesPerAccountLimitChanged(uint256 presaleWolvesPerAccountLimit);
    event BatchMintingLimitChanged(uint256 batchMintingLimit);
    event DatesChanged(uint256 whitelistedPresaleStart, uint256 publicPresaleStart, uint256 saleStart, uint256 claimingStart);
    event PricesChanged(uint256 presalePrice, uint256 salePriceMax, uint256 salePriceMin);
    event DutchAuctionParametersChanged(uint256 dutchAuctionStep, uint256 dutchAuctionStepDuration);
    event WolvesCountChanged(uint256 presaleWolvesCount, uint256 saleWolvesCount, uint256 giftWolvesCount);
    event FearWolfContractAddressSet(address fearWolfContractAddress);
    event WolvesReserved(address indexed account, uint256 amount);
    event WolvesClaimed(address indexed account, uint256 amount);
    event WolvesBought(address indexed account, uint256 price, uint256 amount);
    event WolvesGifted(address indexed account, uint256 amount);


    uint256 public presaleWolvesPerAccountLimit = 5;

    uint256 public batchMintingLimit = 10;

    uint256 public totalWolvesReserved;
    uint256 public totalWolvesBought;

    uint256 public whitelistedPresaleStart;
    uint256 public publicPresaleStart;
    uint256 public saleStart;
    uint256 public claimingStart;

    uint256 public presalePrice = 1 * 10 ** 17; // 0.10 ETH
    uint256 public salePriceMax = 2 * 10 ** 17; // 0.20 ETH
    uint256 public salePriceMin = 18 * 10 ** 16; // 0.18 ETH

    uint256 public dutchAuctionStep = 1 * 10 ** 15;
    uint256 public dutchAuctionStepDuration = 2 hours;

    uint256 public initialPresaleWolvesCount = 2000;
    uint256 public initialSaleWolvesCount = 4000;
    uint256 private presaleWolvesCount = 2000;
    uint256 private saleWolvesCount = 4000;
    uint256 private giftWolvesCount = 66;

    address public fearWolfContractAddress;
    IFearWolf private fearWolfContract;

    mapping (address => uint256) private wolvesReserved;

    mapping (address => uint256) private wolvesBought;

    mapping (address => bool) private claimed;

    mapping (address => bool) private whitelisted;


    constructor() {
        whitelistedPresaleStart = block.timestamp + 7 days;
        publicPresaleStart = whitelistedPresaleStart + 4 days;
        saleStart = whitelistedPresaleStart + 7 days;
        claimingStart = whitelistedPresaleStart + 14 days;
    }

    function _beforeUnpause() internal view virtual override {

        require(fearWolfContractAddress != address(0), "FEAR Wolf contract must be set before unpausing");
        require(fearWolfContract.hasRole(fearWolfContract.DISTRIBUTOR_ROLE(), address(this)), "Distributor role missing");
    }

    function getMyWhitelistedStatus() external view returns (bool) {

        return whitelisted[_msgSender()];
    }

    function getMyNumberOfWolvesReserved() external view returns (uint256) {

        return wolvesReserved[_msgSender()];
    }

    function getMyNumberOfWolvesClaimed() external view returns (uint256) {

        return claimed[_msgSender()] ? wolvesReserved[_msgSender()] : 0;
    }

    function getMyNumberOfWolvesBought() external view returns (uint256) {

        return wolvesBought[_msgSender()];
    }

    function getPresaleWolvesAvailable() external view returns (uint256) {

        if (block.timestamp < saleStart)
            return presaleWolvesCount;
        else
            return 0;
    }

    function getPublicSaleWolvesAvailable() external view returns (uint256) {

        if (block.timestamp < saleStart)
            return saleWolvesCount;
        else
            return presaleWolvesCount + saleWolvesCount; // unsold INO Sale wolves are added to wolves available for sale
    }

    function getGiftWolvesAvailable() external view returns (uint256) {

        return giftWolvesCount;
    }

    function getCurrentPrice() public view returns (uint256) {

        if (block.timestamp < saleStart)
            return salePriceMax;

        uint256 stepsCount = (block.timestamp - saleStart) / dutchAuctionStepDuration;
        if (stepsCount < (salePriceMax - salePriceMin) / dutchAuctionStep)
            return salePriceMax - stepsCount * dutchAuctionStep;
        else
            return salePriceMin;
    }


    function reserveWolves(uint256 wolvesCount) external payable whenNotPaused nonReentrant {

        address caller = _msgSender();

        require(block.timestamp >= whitelistedPresaleStart, "INO phase is not active yet");
        require(block.timestamp < saleStart, "INO phase is over");
        require(block.timestamp >= publicPresaleStart || whitelisted[caller], "Only whitelisted users can reserve a wolf now");

        require(tx.origin == caller, "Contracts are not allowed");
        require(wolvesCount > 0, "Cannot reserve zero wolves");
        require(presaleWolvesCount >= wolvesCount, "Not enough wolves available for reservation");
        require(wolvesReserved[caller] + wolvesCount <= presaleWolvesPerAccountLimit, "Amount of wolves to reserve exceeds INO wolves per account limit");

        require(msg.value >= wolvesCount.mul(presalePrice), "Insufficient ETH sent");
        require(msg.value <= wolvesCount.mul(presalePrice), "Too much ETH sent");
        
        presaleWolvesCount -= wolvesCount;
        totalWolvesReserved += wolvesCount;
        wolvesReserved[caller] += wolvesCount;

        emit WolvesReserved(caller, wolvesCount);
    }

    function claimWolves() external whenNotPaused nonReentrant {

        address caller = _msgSender();
        uint256 wolvesCount = wolvesReserved[caller];

        require(block.timestamp >= claimingStart, "Claiming is not active yet");
        require(wolvesCount > 0, "You don't have any wolves reserved");
        require(!claimed[caller], "You have claimed your wolves already");
        
        claimed[caller] = true;
        fearWolfContract.setInitialOwner(caller, wolvesCount);
        emit WolvesClaimed(caller, wolvesCount);
    }

    function buyWolves(uint256 wolvesCount) external payable whenNotPaused nonReentrant {

        address caller = _msgSender();
        uint256 price = getCurrentPrice();

        require(block.timestamp >= saleStart, "Public sale is not active yet");
        require(tx.origin == caller, "Contracts are not allowed");
        require(wolvesCount > 0, "Cannot buy zero wolves");
        require(presaleWolvesCount + saleWolvesCount >= wolvesCount, "Not enough wolves available for buying");
        require(wolvesCount <= batchMintingLimit, string(abi.encodePacked("Cannot buy more than ", batchMintingLimit.toString(), " at once")));
        require(msg.value >= wolvesCount.mul(price), "Insufficient ETH sent");

        if (presaleWolvesCount > 0) {
            saleWolvesCount += presaleWolvesCount;
            presaleWolvesCount = 0;
        }

        saleWolvesCount -= wolvesCount;
        totalWolvesBought += wolvesCount;
        wolvesBought[caller] += wolvesCount;

        fearWolfContract.setInitialOwner(caller, wolvesCount);
        emit WolvesBought(caller, price, wolvesCount);
    }


    function setDates(uint256 _whitelistedPresaleStart, uint256 _publicPresaleStart, uint256 _saleStart, uint256 _claimingStart) external onlyRole(MANAGER_ROLE) {

        require(block.timestamp < whitelistedPresaleStart ||
                        (whitelistedPresaleStart == _whitelistedPresaleStart
                        && publicPresaleStart == _publicPresaleStart), "Too late, presale is already active");
        require(block.timestamp < saleStart, "Too late, sale is already active");
        require((block.timestamp < _whitelistedPresaleStart || whitelistedPresaleStart == _whitelistedPresaleStart)
                && (block.timestamp < _publicPresaleStart || publicPresaleStart == _publicPresaleStart)
                && block.timestamp < _saleStart
                && block.timestamp < _claimingStart, "Cannot set timestamps to the past");
        require(_whitelistedPresaleStart < _publicPresaleStart
                && _publicPresaleStart < _saleStart
                && _saleStart < _claimingStart, "Wrong timestamps order");

        whitelistedPresaleStart = _whitelistedPresaleStart;
        publicPresaleStart = _publicPresaleStart;
        saleStart = _saleStart;
        claimingStart = _claimingStart;
        emit DatesChanged(whitelistedPresaleStart, publicPresaleStart, saleStart, claimingStart);
    }
    function setPrices(uint256 _presalePrice, uint256 _salePriceMax, uint256 _salePriceMin) external onlyRole(MANAGER_ROLE) {

        require(block.timestamp < whitelistedPresaleStart || _presalePrice == presalePrice, "Too late, presale is already active");
        require(block.timestamp < saleStart, "Too late, sale is already active");
        require(_salePriceMax >= _salePriceMin, "Wrong max/min sale prices order");
        presalePrice = _presalePrice;
        salePriceMax = _salePriceMax;
        salePriceMin = _salePriceMin;
        emit PricesChanged(presalePrice, salePriceMax, salePriceMin);
    }
    function setPresaleWolvesPerAccountLimit(uint256 _presaleWolvesPerAccountLimit) external onlyRole(MANAGER_ROLE) {

        require(block.timestamp < whitelistedPresaleStart, "Too late, presale is already active");
        require(_presaleWolvesPerAccountLimit <= batchMintingLimit, "Cannot set presaleWolvesPerAccountLimit greater than batchMintingLimit");
        presaleWolvesPerAccountLimit = _presaleWolvesPerAccountLimit;
        emit PresaleWolvesPerAccountLimitChanged(presaleWolvesPerAccountLimit);
    }
    function setBatchMintingLimit(uint256 _batchMintingLimit) external onlyRole(MANAGER_ROLE) {

        require(block.timestamp < saleStart, "Too late, sale is already active");
        require(presaleWolvesPerAccountLimit <= _batchMintingLimit, "Cannot set batchMintingLimit less than presaleWolvesPerAccountLimit");
        batchMintingLimit = _batchMintingLimit;
        emit BatchMintingLimitChanged(batchMintingLimit);
    }
    function setDutchAuctionParameters(uint256 _dutchAuctionStep, uint256 _dutchAuctionStepDuration) external onlyRole(MANAGER_ROLE) {

        require(block.timestamp < saleStart, "Too late, sale is already active");
        dutchAuctionStep = _dutchAuctionStep;
        dutchAuctionStepDuration = _dutchAuctionStepDuration;
        emit DutchAuctionParametersChanged(dutchAuctionStep, dutchAuctionStepDuration);
    }
    function setWolvesCount(uint256 _presaleWolvesCount, uint256 _saleWolvesCount, uint256 _giftWolvesCount) external onlyRole(MANAGER_ROLE) {

        require(block.timestamp < whitelistedPresaleStart || initialPresaleWolvesCount == _presaleWolvesCount, "Too late, presale is already active");
        require(block.timestamp < saleStart, "Too late, sale is already active");

        presaleWolvesCount = _presaleWolvesCount;
        initialPresaleWolvesCount = _presaleWolvesCount;
        saleWolvesCount = _saleWolvesCount;
        initialSaleWolvesCount = _saleWolvesCount;
        giftWolvesCount = _giftWolvesCount;
        emit WolvesCountChanged(presaleWolvesCount, saleWolvesCount, giftWolvesCount);
    }
    function setFearWolfContractAddress(address _address) external onlyRole(MANAGER_ROLE) {

        require(block.timestamp < whitelistedPresaleStart, "Too late, presale is already active");
        require(_address != address(0), "Cannot set zero address");
        fearWolfContractAddress = _address;
        fearWolfContract = IFearWolf(fearWolfContractAddress);
        emit FearWolfContractAddressSet(fearWolfContractAddress);
    }

    function addWhitelistedAddress(address _address) external onlyRole(ADMIN_ROLE) {

        whitelisted[_address] = true;
    }

    function addWhitelistedAddresses(address[] calldata _addresses) external onlyRole(ADMIN_ROLE) {

        for (uint i = 0; i < _addresses.length; i++)
            whitelisted[_addresses[i]] = true;
    }

    function giftWolves(address _address, uint256 wolvesCount) external whenNotPaused nonReentrant onlyRole(ADMIN_ROLE) {

        require(giftWolvesCount >= wolvesCount, "Not enough wolves left to gift");
        require(wolvesCount <= batchMintingLimit, string(abi.encodePacked("Cannot gift more than ", batchMintingLimit.toString(), " at once")));
        giftWolvesCount -= wolvesCount;
        fearWolfContract.setInitialOwner(_address, wolvesCount);
        emit WolvesGifted(_address, wolvesCount);
    }
}