
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library CountersUpgradeable {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

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

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

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

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


library ERC165CheckerUpgradeable {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {

        return
            _supportsERC165Interface(account, type(IERC165Upgradeable).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {

        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        bytes memory encodedParams = abi.encodeWithSelector(IERC165Upgradeable.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.7;

abstract contract Constants {
    uint256 internal constant MIN_PRICE = 100;

    uint256 internal constant MIN_AUCTION_DURATION = 15 minutes;
    uint256 internal constant MAX_AUCTION_DURATION = 7 days;
    uint256 internal constant EXTENSION_DURATION = 15 minutes;
}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Upgradeable is IERC165Upgradeable {

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

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {

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

}// MIT

pragma solidity ^0.8.7;


error Not_Valid_Contract();

error Core_Amount_Is_Not_Valid_For_ERC721();

abstract contract Core {
    using ERC165CheckerUpgradeable for address;

    mapping(address => bool) internal _saleContractAllowlist;

    function _trasferNFT(
        address from,
        address to,
        address nftAddress,
        uint256 tokenId,
        uint256 amount
    ) internal {
        if (_isERC721(nftAddress)) {
            if (amount > 1) {
                revert Core_Amount_Is_Not_Valid_For_ERC721();
            }
            _transferERC721(from, to, nftAddress, tokenId);
        } else {
            _transferERC1155(from, to, nftAddress, tokenId, amount);
        }
    }

    function _addContractAllowlist(address contractAddress) internal {
        _saleContractAllowlist[contractAddress] = true;
    }

    function _transferERC1155(
        address from,
        address to,
        address nftAddress,
        uint256 tokenId,
        uint256 amount
    ) private {
        IERC1155Upgradeable(nftAddress).safeTransferFrom(
            from,
            to,
            tokenId,
            amount,
            ""
        );
    }

    function _transferERC721(
        address from,
        address to,
        address nftAddress,
        uint256 tokenId
    ) private {
        IERC721Upgradeable(nftAddress).safeTransferFrom(from, to, tokenId);
    }

    function _isERC721(address nftAddress) private view returns (bool) {
        return
            nftAddress.supportsInterface(type(IERC721Upgradeable).interfaceId);
    }

    function onERC721Received(
        address _operator,
        address,
        uint256,
        bytes calldata
    ) external view returns (bytes4) {
        if (_operator == address(this)) {
            return this.onERC721Received.selector;
        }
        return 0x0;
    }

    function onERC1155Received(
        address _operator,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external view returns (bytes4) {
        if (_operator == address(this)) {
            return this.onERC1155Received.selector;
        }
        return 0x0;
    }

    function onERC1155BatchReceived(
        address _operator,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external view returns (bytes4) {
        if (_operator == address(this)) {
            return this.onERC1155BatchReceived.selector;
        }

        return 0x0;
    }
}// MIT

pragma solidity ^0.8.7;



error Payment_Royalties_Make_More_Then_85_Precent();

error Payment_Royalties_Payees_Not_Equal_Shares_Lenght();

contract Payment is Constants {

    address internal _dissrupPayout;
    enum SaleType {
        DirectSale,
        AuctionSale
    }
    struct Royalty {
        address payee;
        uint256 share;
    }

    using ERC165CheckerUpgradeable for address;
    event PayToRoyalties(address payable[] payees, uint256[] shares);

    mapping(SaleType => mapping(uint256 => Royalty[]))
        internal _saleToRoyalties;

    function _setDissrupPayment(address dissrupPayout) internal virtual {

        _dissrupPayout = dissrupPayout;
    }

    function _splitPayment(
        address seller,
        uint256 price,
        SaleType saleType,
        uint256 saleId
    )
        internal
        returns (
            uint256 dissrupCut,
            uint256 sellerCut,
            address[] memory royaltiesPayees,
            uint256[] memory royaltiesCuts
        )
    {

        dissrupCut = (price * 15) / 100;

        payable(_dissrupPayout).transfer(dissrupCut);
        uint256 royaltiesTotalCut;
        (
            royaltiesTotalCut,
            royaltiesPayees,
            royaltiesCuts
        ) = _payToRoyaltiesIfExist(saleType, saleId, price);

        sellerCut = (price) - (dissrupCut + royaltiesTotalCut);

        payable(seller).transfer(sellerCut);
    }

    function _checkRoyalties(
        address[] calldata royaltiesPayees,
        uint256[] calldata royaltiesShares
    ) internal pure {

        uint256 totalShares;
        if (royaltiesPayees.length != royaltiesShares.length) {
            revert Payment_Royalties_Payees_Not_Equal_Shares_Lenght();
        }

        for (uint256 i = 0; i < royaltiesPayees.length; i++) {
            totalShares = totalShares + royaltiesShares[i];
        }
        if (totalShares > 85) {
            revert Payment_Royalties_Make_More_Then_85_Precent();
        }
    }

    function _setRoyalties(
        SaleType saleType,
        uint256 saleId,
        address[] calldata royaltiesPayees,
        uint256[] calldata royaltiesShares
    ) internal {

        for (uint256 i = 0; i < royaltiesPayees.length; i++) {
            Royalty memory royalty = Royalty({
                payee: royaltiesPayees[i],
                share: royaltiesShares[i]
            });

            _saleToRoyalties[saleType][saleId].push(royalty);
        }
    }

    function _payToRoyaltiesIfExist(
        SaleType saleType,
        uint256 saleId,
        uint256 price
    )
        private
        returns (
            uint256 royaltiesTotalCuts,
            address[] memory royaltiesPayees,
            uint256[] memory royaltiesCuts
        )
    {

        Royalty[] storage royalties = _saleToRoyalties[saleType][saleId];

        royaltiesCuts = new uint256[](royalties.length);
        royaltiesPayees = new address[](royalties.length);

        for (uint256 i = 0; i < royalties.length; i++) {
            Royalty memory royalty = royalties[i];

            uint256 cut = (price * royalty.share) / 100;

            royaltiesCuts[i] = cut;
            royaltiesPayees[i] = royalty.payee;
            royaltiesTotalCuts += cut;

            payable(royalty.payee).transfer(cut);
        }
    }
}// MIT

pragma solidity ^0.8.7;





error Direct_Sale_Price_Too_Low();
error Direct_Sale_Not_The_Owner(address msgSender, address seller);

error Direct_Sale_Amount_Cannot_Be_Zero();

error Direct_Sale_Contract_Address_Is_Not_Approved(address nftAddress);

error Direct_Sale_Not_A_Valid_Params_For_Buy();

error Direct_Sale_Required_Amount_To_Big_To_Buy();

error Direct_Sale_Buyer_Is_Not_Exist();

error Direct_Sale_Not_Enough_Ether_To_Buy();

abstract contract DirectSale is
    Constants,
    Core,
    Payment,
    ReentrancyGuardUpgradeable
{
    struct DirectSaleList {
        address seller;
        uint256 amount;
        uint256 price;
    }

    uint256 internal _directSaleId;

    mapping(address => mapping(uint256 => mapping(uint256 => DirectSaleList)))
        private _assetAndSaleIdToDirectSale;

    uint256[1000] private ______gap;

    event ListDirectSale(
        uint256 saleId,
        address indexed nftAddress,
        uint256 tokenId,
        address indexed seller,
        uint256 amount,
        uint256 price,
        address[] royaltiesPayees,
        uint256[] royaltiesShares
    );

    event UpdateDirectSale(
        uint256 saleId,
        address indexed nftAddress,
        uint256 tokenId,
        address indexed seller,
        uint256 price,
        address[] royaltiesPayees,
        uint256[] royaltiesShares
    );

    event CancelDirectSale(
        address indexed nftAddress,
        uint256 tokenId,
        uint256 saleId,
        address indexed seller
    );

    event BuyDirectSale(
        address indexed nftAddress,
        uint256 tokenId,
        uint256 saleId,
        uint256 amount,
        address indexed buyer,
        uint256 dissrupCut,
        address indexed seller,
        uint256 sellerCut,
        address[] royalties,
        uint256[] royaltiesCuts
    );

    function listDirectSale(
        address nftAddress,
        uint256 tokenId,
        uint256 amount,
        uint256 price,
        address[] calldata royaltiesPayees,
        uint256[] calldata royaltiesShares
    ) external nonReentrant {
        if (price < Constants.MIN_PRICE) {
            revert Direct_Sale_Price_Too_Low();
        }

        if (amount == 0) {
            revert Direct_Sale_Amount_Cannot_Be_Zero();
        }

        if (_saleContractAllowlist[nftAddress] == false) {
            revert Direct_Sale_Contract_Address_Is_Not_Approved(nftAddress);
        }
        if (royaltiesPayees.length > 0) {
            _checkRoyalties(royaltiesPayees, royaltiesShares);
        }

        DirectSaleList storage directSale = _assetAndSaleIdToDirectSale[
            nftAddress
        ][tokenId][++_directSaleId];

        address seller = msg.sender;

        _trasferNFT(seller, address(this), nftAddress, tokenId, amount);

        _setRoyalties(
            SaleType.DirectSale,
            _directSaleId,
            royaltiesPayees,
            royaltiesShares
        );

        directSale.seller = seller;
        directSale.amount = amount;
        directSale.price = price;

        emit ListDirectSale(
            _directSaleId,
            nftAddress,
            tokenId,
            seller,
            amount,
            price,
            royaltiesPayees,
            royaltiesShares
        );
    }

    function updateDirectSale(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId,
        uint256 price,
        address[] calldata royaltiesPayees,
        uint256[] calldata royaltiesShares
    ) external nonReentrant {
        DirectSaleList storage directSale = _assetAndSaleIdToDirectSale[
            nftAddress
        ][tokenId][saleId];

        address seller = directSale.seller;

        if (seller != msg.sender) {
            revert Direct_Sale_Not_The_Owner(msg.sender, seller);
        }

        if (price < MIN_PRICE) {
            revert Direct_Sale_Price_Too_Low();
        }

        directSale.price = price;

        if (royaltiesPayees.length > 0) {
            _checkRoyalties(royaltiesPayees, royaltiesShares);

            _setRoyalties(
                SaleType.DirectSale,
                saleId,
                royaltiesPayees,
                royaltiesShares
            );
        }
        emit UpdateDirectSale(
            saleId,
            nftAddress,
            tokenId,
            seller,
            price,
            royaltiesPayees,
            royaltiesShares
        );
    }

    function cancelDirectSale(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId
    ) external nonReentrant {
        DirectSaleList memory directSale = _assetAndSaleIdToDirectSale[
            nftAddress
        ][tokenId][saleId];

        if (msg.sender != directSale.seller) {
            revert Direct_Sale_Not_The_Owner(msg.sender, directSale.seller);
        }

        _trasferNFT(
            address(this),
            directSale.seller,
            nftAddress,
            tokenId,
            directSale.amount
        );

        _unlistDirect(nftAddress, tokenId, saleId);

        emit CancelDirectSale(nftAddress, tokenId, saleId, directSale.seller);
    }

    function buyDirectSale(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId,
        uint256 amount
    ) external payable nonReentrant {
        DirectSaleList storage directSale = _assetAndSaleIdToDirectSale[
            nftAddress
        ][tokenId][saleId];

        if (directSale.seller == address(0)) {
            revert Direct_Sale_Not_A_Valid_Params_For_Buy();
        }

        if (directSale.amount < amount) {
            revert Direct_Sale_Required_Amount_To_Big_To_Buy();
        }

        uint256 totalPrice = directSale.price * amount;
        address buyer = msg.sender;

        uint256 payment = msg.value;

        if (payment < totalPrice) {
            revert Direct_Sale_Not_Enough_Ether_To_Buy();
        }

        if (payment > totalPrice) {
            uint256 refund = payment - totalPrice;
            payable(buyer).transfer(refund);
        }

        _trasferNFT(address(this), buyer, nftAddress, tokenId, amount);

        directSale.amount = directSale.amount - amount;

        (
            uint256 dissrupCut,
            uint256 sellerCut,
            address[] memory royaltiesPayees,
            uint256[] memory royaltiesCuts
        ) = _splitPayment(
                directSale.seller,
                totalPrice,
                SaleType.DirectSale,
                saleId
            );

        emit BuyDirectSale(
            nftAddress,
            tokenId,
            saleId,
            amount,
            buyer,
            dissrupCut,
            directSale.seller,
            sellerCut,
            royaltiesPayees,
            royaltiesCuts
        );
        if (directSale.amount == 0) {
            _unlistDirect(nftAddress, tokenId, saleId);
        }
    }

    function _unlistDirect(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId
    ) private {
        delete _saleToRoyalties[SaleType.DirectSale][saleId];
        delete _assetAndSaleIdToDirectSale[nftAddress][tokenId][saleId];
    }
}// MIT

pragma solidity ^0.8.7;





error Auction_Sale_Contract_Address_Is_Not_Approved(address nftAddress);

error Auction_Sale_Amount_Cannot_Be_Zero();

error Auction_Sale_Price_Too_Low();

error Auction_Sale_Duration_Grater_Then_Max();

error Auction_Sale_Duration_Lower_Then_Min();

error Cannot_Update_Ongoing_Auction();

error Auction_Sale_Only_Seller_Can_Update();

error Cannot_Cancel_Ongoing_Auction();

error Auction_Sale_Only_Seller_Can_Cancel();

error Auction_Sale_Not_A_Valid_List();

error Auction_Sale_Already_Ended();

error Auction_Sale_Msg_Value_Lower_Then_Reserve_Price();

error Auction_Sale_Bid_Must_Be_Greater_Then(uint256 minimumBid);

error Auction_Sale_Seller_Cannot_Bid();

error Auction_Sale_Cannot_Settle_Onging_Auction();

abstract contract AuctionSale is
    Constants,
    Core,
    Payment,
    ReentrancyGuardUpgradeable
{
    struct AuctionSaleList {
        uint256 duration;
        uint256 extensionDuration;
        uint256 endTime;
        address bidder;
        uint256 bid;
        uint256 reservePrice;
        uint256 amount;
        address seller;
    }

    uint256 internal _auctionSaleId;

    mapping(address => mapping(uint256 => mapping(uint256 => AuctionSaleList)))
        private _assetAndSaleIdToAuctionSale;

    uint256[1000] private ______gap;

    event ListAuctionSale(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId,
        uint256 amount,
        uint256 duration,
        uint256 reservePrice,
        uint256 extensionDuration,
        address seller,
        address[] royaltiesPayees,
        uint256[] royaltiesShares
    );

    event CancelAuctionSale(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId,
        uint256 amount,
        address seller
    );
    event UpdateAuctionSale(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId,
        uint256 duration,
        uint256 reservePrice,
        address[] royaltiesPayees,
        uint256[] royaltiesShares
    );
    event Bid(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId,
        address lastBidder,
        uint256 lastBid,
        address newBidder,
        uint256 newBid,
        uint256 endtime
    );

    event Settle(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId,
        address winner,
        uint256 winnerBid,
        uint256 dissrupCut,
        address seller,
        uint256 sellerCut,
        address[] royaltiesPayees,
        uint256[] royaltiesCuts,
        address settler
    );

    function listAuctionSale(
        address nftAddress,
        uint256 tokenId,
        uint256 amount,
        uint256 duration,
        uint256 reservePrice,
        address[] calldata royaltiesPayees,
        uint256[] calldata royaltiesShares
    )
        external
        nonReentrant
        durationInLimits(duration)
        priceAboveMin(reservePrice)
    {
        if (_saleContractAllowlist[nftAddress] == false) {
            revert Auction_Sale_Contract_Address_Is_Not_Approved(nftAddress);
        }
        if (royaltiesPayees.length > 0) {
            _checkRoyalties(royaltiesPayees, royaltiesShares);
        }
        if (amount == 0) {
            revert Auction_Sale_Amount_Cannot_Be_Zero();
        }

        _trasferNFT(msg.sender, address(this), nftAddress, tokenId, amount);

        AuctionSaleList storage auctionSale = _assetAndSaleIdToAuctionSale[
            nftAddress
        ][tokenId][++_auctionSaleId];

        _setRoyalties(
            SaleType.AuctionSale,
            _auctionSaleId,
            royaltiesPayees,
            royaltiesShares
        );

        auctionSale.amount = amount;
        auctionSale.bidder = address(0);
        auctionSale.bid = 0;
        auctionSale.endTime = 0;
        auctionSale.extensionDuration = EXTENSION_DURATION;
        auctionSale.duration = duration;
        auctionSale.reservePrice = reservePrice;
        auctionSale.seller = msg.sender;

        emit ListAuctionSale(
            nftAddress,
            tokenId,
            _auctionSaleId,
            auctionSale.amount,
            auctionSale.duration,
            auctionSale.reservePrice,
            auctionSale.extensionDuration,
            auctionSale.seller,
            royaltiesPayees,
            royaltiesShares
        );
    }

    function updateAuctionSale(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId,
        uint256 duration,
        uint256 reservePrice,
        address[] calldata royaltiesPayees,
        uint256[] calldata royaltiesShares
    )
        external
        nonReentrant
        durationInLimits(duration)
        priceAboveMin(reservePrice)
    {
        AuctionSaleList storage auctionSale = _assetAndSaleIdToAuctionSale[
            nftAddress
        ][tokenId][saleId];
        if (auctionSale.seller == address(0)) {
            revert Auction_Sale_Not_A_Valid_List();
        }
        if (auctionSale.seller != msg.sender) {
            revert Auction_Sale_Only_Seller_Can_Update();
        }

        if (auctionSale.endTime != 0) {
            revert Cannot_Update_Ongoing_Auction();
        }
        if (royaltiesPayees.length > 0) {
            _checkRoyalties(royaltiesPayees, royaltiesShares);

            _setRoyalties(
                SaleType.AuctionSale,
                saleId,
                royaltiesPayees,
                royaltiesShares
            );
        }

        auctionSale.reservePrice = reservePrice;

        auctionSale.duration = duration;

        emit UpdateAuctionSale(
            nftAddress,
            tokenId,
            saleId,
            auctionSale.duration,
            reservePrice,
            royaltiesPayees,
            royaltiesShares
        );
    }

    function cancelAuctionSale(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId
    ) external nonReentrant {
        AuctionSaleList memory auctionSale = _assetAndSaleIdToAuctionSale[
            nftAddress
        ][tokenId][saleId];
        if (auctionSale.seller == address(0)) {
            revert Auction_Sale_Not_A_Valid_List();
        }
        if (auctionSale.seller != msg.sender) {
            revert Auction_Sale_Only_Seller_Can_Cancel();
        }
        if (auctionSale.endTime != 0) {
            revert Cannot_Cancel_Ongoing_Auction();
        }
        _trasferNFT(
            address(this),
            auctionSale.seller,
            nftAddress,
            tokenId,
            auctionSale.amount
        );

        _unlistAuction(nftAddress, tokenId, saleId);

        emit CancelAuctionSale(
            nftAddress,
            tokenId,
            saleId,
            auctionSale.amount,
            auctionSale.seller
        );
    }

    function bid(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId
    ) external payable nonReentrant {
        AuctionSaleList storage auctionSale = _assetAndSaleIdToAuctionSale[
            nftAddress
        ][tokenId][saleId];
        address lastBidder = auctionSale.bidder;
        uint256 lastBid = auctionSale.bid;

        if (auctionSale.seller == address(0)) {
            revert Auction_Sale_Not_A_Valid_List();
        }
        if (msg.sender == auctionSale.seller) {
            revert Auction_Sale_Seller_Cannot_Bid();
        }
        if (auctionSale.bidder == address(0)) {
            if (msg.value < auctionSale.reservePrice) {
                revert Auction_Sale_Msg_Value_Lower_Then_Reserve_Price();
            }

            auctionSale.bidder = msg.sender;
            auctionSale.bid = msg.value;

            auctionSale.endTime =
                uint256(block.timestamp) +
                auctionSale.duration;
        } else {
            if (auctionSale.endTime < block.timestamp) {
                revert Auction_Sale_Already_Ended();
            }

            uint256 minimumRasieForBid = _getMinBidForReserveAuction(
                auctionSale.bid
            );

            if (minimumRasieForBid > msg.value) {
                revert Auction_Sale_Bid_Must_Be_Greater_Then(
                    minimumRasieForBid
                );
            }
            if (
                auctionSale.endTime - block.timestamp <
                auctionSale.extensionDuration
            ) {
                auctionSale.endTime =
                    block.timestamp +
                    auctionSale.extensionDuration;
            }

            payable(lastBidder).transfer(lastBid);

            auctionSale.bidder = msg.sender;
            auctionSale.bid = msg.value;
        }

        emit Bid(
            nftAddress,
            tokenId,
            saleId,
            lastBidder,
            lastBid,
            auctionSale.bidder,
            auctionSale.bid,
            auctionSale.endTime
        );
    }

    function settle(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId
    ) external nonReentrant {
        AuctionSaleList memory auctionSale = _assetAndSaleIdToAuctionSale[
            nftAddress
        ][tokenId][saleId];
        address seller = auctionSale.seller;
        if (seller == address(0)) {
            revert Auction_Sale_Not_A_Valid_List();
        }
        if (auctionSale.endTime > block.timestamp) {
            revert Auction_Sale_Cannot_Settle_Onging_Auction();
        }
        address winner = auctionSale.bidder;
        uint256 winnerBid = auctionSale.bid;

        _trasferNFT(
            address(this),
            winner,
            nftAddress,
            tokenId,
            auctionSale.amount
        );

        (
            uint256 dissrupCut,
            uint256 sellerCut,
            address[] memory royaltiesPayees,
            uint256[] memory royaltiesCuts
        ) = _splitPayment(seller, winnerBid, SaleType.AuctionSale, saleId);

        _unlistAuction(nftAddress, tokenId, saleId);

        emit Settle(
            nftAddress,
            tokenId,
            saleId,
            winner,
            winnerBid,
            dissrupCut,
            seller,
            sellerCut,
            royaltiesPayees,
            royaltiesCuts,
            msg.sender
        );
    }

    function isAuctionEnded(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId
    ) public view returns (bool) {
        AuctionSaleList memory auctionSale = _assetAndSaleIdToAuctionSale[
            nftAddress
        ][tokenId][saleId];

        if (auctionSale.seller == address(0)) {
            revert Auction_Sale_Not_A_Valid_List();
        }
        return
            (auctionSale.endTime > 0) &&
            (auctionSale.endTime < block.timestamp);
    }

    function _unlistAuction(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId
    ) private {
        delete _saleToRoyalties[SaleType.AuctionSale][saleId];
        delete _assetAndSaleIdToAuctionSale[nftAddress][tokenId][saleId];
    }

    function getEndTimeForReserveAuction(
        address nftAddress,
        uint256 tokenId,
        uint256 saleId
    ) public view returns (uint256) {
        AuctionSaleList memory auctionSale = _assetAndSaleIdToAuctionSale[
            nftAddress
        ][tokenId][saleId];
        if (auctionSale.seller == address(0)) {
            revert Auction_Sale_Not_A_Valid_List();
        }
        return auctionSale.endTime;
    }

    function _getMinBidForReserveAuction(uint256 currentBid)
        private
        pure
        returns (uint256)
    {
        uint256 minimumIncrement = currentBid / 10;

        if (minimumIncrement < (0.1 ether)) {
            return currentBid + (0.1 ether);
        }
        return (currentBid + minimumIncrement);
    }

    modifier durationInLimits(uint256 duration) {
        if (duration > MAX_AUCTION_DURATION) {
            revert Auction_Sale_Duration_Grater_Then_Max();
        }
        if (duration < MIN_AUCTION_DURATION) {
            revert Auction_Sale_Duration_Lower_Then_Min();
        }
        _;
    }

    modifier priceAboveMin(uint256 price) {
        if (price < MIN_PRICE) {
            revert Auction_Sale_Price_Too_Low();
        }
        _;
    }
}// MIT

pragma solidity ^0.8.7;








error Marketplace_Only_Admin_Can_Access();

error Marketplace_Not_Valid_Contract_To_Add();

enum TokenStandard {
    ERC721,
    ERC1155
}

contract Marketplace is
    Initializable,
    DirectSale,
    AuctionSale,
    AccessControlUpgradeable
{

    using ERC165CheckerUpgradeable for address;
    event RegisterContract(
        address contractAddress,
        TokenStandard tokenStandard
    );

    event SetAdmin(address account);

    event SetDissrupPayment(address dissrupPayout);

    event RevokeAdmin(address account);

    uint256[1000] private ______gap;

    function initialize(address dissrupPayout) public initializer {

        __AccessControl_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        super._setDissrupPayment(dissrupPayout);
    }

    function addContractAllowlist(address contractAddress) external onlyAdmin {

        TokenStandard tokenStandard;
        if (contractAddress.supportsInterface(bytes4(0x80ac58cd))) {
            tokenStandard = TokenStandard.ERC721;

        } else if (contractAddress.supportsInterface(bytes4(0xd9b67a26))) {
            tokenStandard = TokenStandard.ERC1155;
        } else {
            revert Marketplace_Not_Valid_Contract_To_Add();
        }

        super._addContractAllowlist(contractAddress);

        emit RegisterContract(contractAddress, tokenStandard);
    }

    function setDissrupPayment(address dissrupPayout) external onlyAdmin {

        super._setDissrupPayment(dissrupPayout);

        emit SetDissrupPayment(dissrupPayout);
    }

    function setAdmin(address account) external onlyAdmin {

        _setupRole(DEFAULT_ADMIN_ROLE, account);

        emit SetAdmin(account);
    }

    function revokeAdmin(address account) external onlyAdmin {

        require(msg.sender != account, "Cannot remove yourself!");

        _revokeRole(DEFAULT_ADMIN_ROLE, account);

        emit RevokeAdmin(account);
    }

    modifier onlyAdmin() {

        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert Marketplace_Only_Admin_Can_Access();
        }
        _;
    }
}