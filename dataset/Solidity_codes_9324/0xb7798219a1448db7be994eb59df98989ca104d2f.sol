
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

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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
}// MIT

pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
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

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC2981Upgradeable is IERC165Upgradeable {

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

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


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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
pragma solidity ^0.8.4;

interface IMintable {

    function mintFor(
        address to,
        uint256 quantity,
        bytes calldata mintingBlob
    ) external;

}// Unlicensed
pragma solidity ~0.8.13;

interface IExtensionManager {

    function beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;


    function afterTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;


    function beforeTokenApprove(address _to, uint256 _tokenId) external;


    function afterTokenApprove(address _to, uint256 _tokenId) external;


    function beforeApproveAll(address _operator, bool _approved) external;


    function afterApproveAll(address _operator, bool _approved) external;


    function tokenURI(uint256 _tokenId) external view returns (string memory uri_);


    function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
        external
        view
        returns (address royaltyReceiver_, uint256 royaltyAmount_);


    function getPLOTData(uint256 _tokenId, bytes memory _in)
        external
        view
        returns (bytes memory out_);


    function setPLOTData(uint256 _tokenId, bytes memory _in) external returns (bytes memory out_);


    function payPLOTData(uint256 _tokenId, bytes memory _in)
        external
        payable
        returns (bytes memory out_);


    function getData(bytes memory _in) external view returns (bytes memory out_);


    function setData(bytes memory _in) external returns (bytes memory out_);


    function payData(bytes memory _in) external payable returns (bytes memory out_);

}// Unlicensed


interface IStoryversePlot is
    IERC2981Upgradeable,
    IERC721MetadataUpgradeable,
    IAccessControlUpgradeable,
    IMintable
{

    event ExtensionManagerSet(address indexed who, address indexed extensionManager);

    event IMXSet(address indexed who, address indexed imx);

    event AssetMinted(address to, uint256 tokenId, bytes blueprint);

    event BaseURISet(address indexed who);

    event FundsWithdrawn(address to, uint256 amount);

    function baseURI() external returns (string memory uri_);


    function extensionManager() external returns (IExtensionManager extensionManager_);


    function imx() external returns (address imx_);


    function blueprints(uint256 _tokenId) external returns (bytes memory blueprint_);


    function setExtensionManager(address _extensionManager) external;


    function safeMint(address _to, uint256 _tokenId) external;


    function setBaseURI(string calldata _uri) external;


    function getPLOTData(uint256 _tokenId, bytes memory _in) external returns (bytes memory out_);


    function setPLOTData(uint256 _tokenId, bytes memory _in) external returns (bytes memory out_);


    function payPLOTData(uint256 _tokenId, bytes memory _in)
        external
        payable
        returns (bytes memory out_);


    function getData(bytes memory _in) external returns (bytes memory out_);


    function setData(bytes memory _in) external returns (bytes memory out_);


    function payData(bytes memory _in) external payable returns (bytes memory out_);


    function transferOwnership(address newOwner) external;


    function setIMX(address _imx) external;


    function withdrawFunds(address payable _to, uint256 _amount) external;

}// Unlicensed
pragma solidity 0.8.13;


contract SaleCommon is AccessControl, ReentrancyGuard {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address public plot;

    event SaleAdded(address who, uint256 saleId);

    event SaleUpdated(address who, uint256 saleId);

    event Minted(address who, address to, uint256 quantity, uint256 amount);

    event FundsWithdrawn(address to, uint256 amount);

    constructor(address _plot) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);

        plot = _plot;
    }

    function checkTokenParameters(
        uint256 _volume,
        uint256 _presale,
        uint256 _tokenIndex
    ) internal pure {

        require(_volume > 0 && _volume < 2**10, "invalid volume");
        require(_presale < 2**2, "invalid presale");
        require(_tokenIndex < 2**32, "invalid token index");
    }

    function buildTokenId(
        uint256 _volume,
        uint256 _presale,
        uint256 _tokenIndex
    ) public view returns (uint256 tokenId_) {

        checkTokenParameters(_volume, _presale, _tokenIndex);

        uint256 superSecretSpice = uint256(
            keccak256(
                abi.encodePacked(
                    (0x4574c8c75d6e88acd28f7e467dac97b5c60c3838d9dad993900bdf402152228e ^
                        uint256(blockhash(block.number - 1))) + _tokenIndex
                )
            )
        ) & 0xffffffff;

        tokenId_ = (_volume << 245) | (_presale << 243) | (superSecretSpice << 211) | _tokenIndex;

        return tokenId_;
    }

    function decodeTokenId(uint256 _tokenId)
        external
        pure
        returns (
            uint256 volume_,
            uint256 presale_,
            uint256 superSecretSpice_,
            uint256 tokenIndex_
        )
    {

        volume_ = (_tokenId >> 245) & 0x3ff;
        presale_ = (_tokenId >> 243) & 0x3;
        superSecretSpice_ = (_tokenId >> 211) & 0xffffffff;
        tokenIndex_ = _tokenId & 0xffffffff;

        return (volume_, presale_, superSecretSpice_, tokenIndex_);
    }

    function withdrawFunds(address payable _to, uint256 _amount)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        nonReentrant
    {

        require(_amount <= address(this).balance, "not enough funds");
        _to.transfer(_amount);
        emit FundsWithdrawn(_to, _amount);
    }
}// MIT
pragma solidity 0.8.13;



contract ETHSale is AccessControl, SaleCommon {

    struct Sale {
        uint256 id;
        uint256 volume;
        uint256 presale;
        uint256 starttime; // to start immediately, set starttime = 0
        uint256 endtime;
        bool active;
        bytes32 merkleRoot; // Merkle root of the entrylist Merkle tree, 0x00 for non-merkle sale
        uint256 maxQuantity;
        uint256 price; // in Wei, where 10^18 Wei = 1 ETH
        uint256 startTokenIndex;
        uint256 maxPLOTs;
        uint256 mintedPLOTs;
    }

    Sale[] public sales;
    mapping(uint256 => mapping(address => uint256)) public minted; // sale ID => account => quantity

    constructor(address _plot) SaleCommon(_plot) {}

    function currentSale() public view returns (Sale memory) {

        require(sales.length > 0, "no current sale");
        return sales[sales.length - 1];
    }

    function currentSaleId() public view returns (uint256) {

        require(sales.length > 0, "no current sale");
        return sales.length - 1;
    }

    function isSafeTokenIdRange(uint256 _startTokenIndex, uint256 _maxPLOTs)
        external
        view
        returns (bool valid_)
    {

        return _isSafeTokenIdRange(_startTokenIndex, _maxPLOTs, sales.length);
    }

    function _checkSafeTokenIdRange(
        uint256 _startTokenIndex,
        uint256 _maxPLOTs,
        uint256 _maxSaleId
    ) internal view {

        require(
            _isSafeTokenIdRange(_startTokenIndex, _maxPLOTs, _maxSaleId),
            "overlapping token ID range"
        );
    }

    function _isSafeTokenIdRange(
        uint256 _startTokenIndex,
        uint256 _maxPLOTs,
        uint256 _maxSaleId
    ) internal view returns (bool valid_) {

        if (_maxPLOTs == 0) {
            return true;
        }

        for (uint256 i = 0; i < _maxSaleId; i++) {
            if (sales[i].mintedPLOTs == 0) {
                continue;
            }

            uint256 saleStartTokenIndex = sales[i].startTokenIndex;
            uint256 saleMintedPLOTs = sales[i].mintedPLOTs;

            if (_startTokenIndex < saleStartTokenIndex) {
                if (_startTokenIndex + _maxPLOTs - 1 >= saleStartTokenIndex) {
                    return false;
                }
            } else {
                if (_startTokenIndex <= saleStartTokenIndex + saleMintedPLOTs - 1) {
                    return false;
                }
            }
        }

        return true;
    }

    function addSale(
        uint256 _volume,
        uint256 _presale,
        uint256 _starttime,
        uint256 _endtime,
        bool _active,
        bytes32 _merkleRoot,
        uint256 _maxQuantity,
        uint256 _price,
        uint256 _startTokenIndex,
        uint256 _maxPLOTs
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {

        uint256 saleId = sales.length;

        checkTokenParameters(_volume, _presale, _startTokenIndex);

        _checkSafeTokenIdRange(_startTokenIndex, _maxPLOTs, saleId);

        Sale memory sale = Sale({
            id: saleId,
            volume: _volume,
            presale: _presale,
            starttime: _starttime,
            endtime: _endtime,
            active: _active,
            merkleRoot: _merkleRoot,
            maxQuantity: _maxQuantity,
            price: _price,
            startTokenIndex: _startTokenIndex,
            maxPLOTs: _maxPLOTs,
            mintedPLOTs: 0
        });

        sales.push(sale);

        emit SaleAdded(msg.sender, saleId);
    }

    function updateSale(
        uint256 _volume,
        uint256 _presale,
        uint256 _starttime,
        uint256 _endtime,
        bool _active,
        bytes32 _merkleRoot,
        uint256 _maxQuantity,
        uint256 _price,
        uint256 _startTokenIndex,
        uint256 _maxPLOTs
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {

        uint256 saleId = currentSaleId();

        checkTokenParameters(_volume, _presale, _startTokenIndex);
        _checkSafeTokenIdRange(_startTokenIndex, _maxPLOTs, saleId);

        Sale memory sale = Sale({
            id: saleId,
            volume: _volume,
            presale: _presale,
            starttime: _starttime,
            endtime: _endtime,
            active: _active,
            merkleRoot: _merkleRoot,
            maxQuantity: _maxQuantity,
            price: _price,
            startTokenIndex: _startTokenIndex,
            maxPLOTs: _maxPLOTs,
            mintedPLOTs: sales[saleId].mintedPLOTs
        });

        sales[saleId] = sale;

        emit SaleUpdated(msg.sender, saleId);
    }

    function updateSaleVolume(uint256 _volume) external onlyRole(DEFAULT_ADMIN_ROLE) {

        uint256 saleId = currentSaleId();

        checkTokenParameters(_volume, sales[saleId].presale, sales[saleId].startTokenIndex);

        sales[saleId].volume = _volume;
        emit SaleUpdated(msg.sender, saleId);
    }

    function updateSalePresale(uint256 _presale) external onlyRole(DEFAULT_ADMIN_ROLE) {

        uint256 saleId = currentSaleId();

        checkTokenParameters(sales[saleId].volume, _presale, sales[saleId].startTokenIndex);

        sales[saleId].presale = _presale;
        emit SaleUpdated(msg.sender, saleId);
    }

    function updateSaleStarttime(uint256 _starttime) external onlyRole(DEFAULT_ADMIN_ROLE) {

        uint256 saleId = currentSaleId();
        sales[saleId].starttime = _starttime;
        emit SaleUpdated(msg.sender, saleId);
    }

    function updateSaleEndtime(uint256 _endtime) external onlyRole(DEFAULT_ADMIN_ROLE) {

        uint256 saleId = currentSaleId();
        sales[saleId].endtime = _endtime;
        emit SaleUpdated(msg.sender, saleId);
    }

    function updateSaleActive(bool _active) external onlyRole(DEFAULT_ADMIN_ROLE) {

        uint256 saleId = currentSaleId();
        sales[saleId].active = _active;
        emit SaleUpdated(msg.sender, saleId);
    }

    function updateSaleMerkleRoot(bytes32 _merkleRoot) external onlyRole(DEFAULT_ADMIN_ROLE) {

        uint256 saleId = currentSaleId();
        sales[saleId].merkleRoot = _merkleRoot;
        emit SaleUpdated(msg.sender, saleId);
    }

    function updateSaleMaxQuantity(uint256 _maxQuantity) external onlyRole(DEFAULT_ADMIN_ROLE) {

        uint256 saleId = currentSaleId();
        sales[saleId].maxQuantity = _maxQuantity;
        emit SaleUpdated(msg.sender, saleId);
    }

    function updateSalePrice(uint256 _price) external onlyRole(DEFAULT_ADMIN_ROLE) {

        uint256 saleId = currentSaleId();
        sales[saleId].price = _price;
        emit SaleUpdated(msg.sender, saleId);
    }

    function updateSaleStartTokenIndex(uint256 _startTokenIndex)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        uint256 saleId = currentSaleId();

        _checkSafeTokenIdRange(_startTokenIndex, sales[saleId].maxPLOTs, saleId);
        checkTokenParameters(sales[saleId].volume, sales[saleId].presale, _startTokenIndex);

        sales[saleId].startTokenIndex = _startTokenIndex;
        emit SaleUpdated(msg.sender, saleId);
    }

    function updateSaleMaxPLOTs(uint256 _maxPLOTs) external onlyRole(DEFAULT_ADMIN_ROLE) {

        uint256 saleId = currentSaleId();

        _checkSafeTokenIdRange(sales[saleId].startTokenIndex, _maxPLOTs, saleId);

        sales[saleId].maxPLOTs = _maxPLOTs;
        emit SaleUpdated(msg.sender, saleId);
    }

    function _mintTo(
        address _to,
        uint256 _volume,
        uint256 _presale,
        uint256 _startTokenIndex,
        uint256 _quantity
    ) internal {

        require(_quantity > 0, "quantity must be greater than 0");

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 tokenIndex = _startTokenIndex + i;
            uint256 tokenId = buildTokenId(_volume, _presale, tokenIndex);

            IStoryversePlot(plot).safeMint(_to, tokenId);
        }

        emit Minted(msg.sender, _to, _quantity, msg.value);
    }

    function mintTo(address _to, uint256 _quantity) external payable nonReentrant {

        Sale memory sale = currentSale();

        require(sale.merkleRoot == bytes32(0), "merkle sale requires valid proof");

        require(sale.active, "sale is inactive");
        require(block.timestamp >= sale.starttime, "sale has not started");
        require(block.timestamp < sale.endtime, "sale has ended");

        require(msg.value == sale.price * _quantity, "incorrect payment for quantity and price");
        require(
            minted[sale.id][msg.sender] + _quantity <= sale.maxQuantity,
            "exceeds allowed quantity"
        );

        require(sale.mintedPLOTs + _quantity <= sale.maxPLOTs, "insufficient supply");

        sales[sale.id].mintedPLOTs += _quantity;
        minted[sale.id][msg.sender] += _quantity;

        _mintTo(
            _to,
            sale.volume,
            sale.presale,
            sale.startTokenIndex + sale.mintedPLOTs,
            _quantity
        );
    }

    function entryListMintTo(
        bytes32[] calldata _proof,
        uint256 _maxQuantity,
        address _to,
        uint256 _quantity
    ) external payable nonReentrant {

        Sale memory sale = currentSale();

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _maxQuantity));
        require(MerkleProof.verify(_proof, sale.merkleRoot, leaf), "invalid proof");

        require(sale.active, "sale is inactive");
        require(block.timestamp >= sale.starttime, "sale has not started");
        require(block.timestamp < sale.endtime, "sale has ended");

        require(msg.value == sale.price * _quantity, "incorrect payment for quantity and price");
        require(
            minted[sale.id][msg.sender] + _quantity <= Math.max(sale.maxQuantity, _maxQuantity),
            "exceeds allowed quantity"
        );

        require(sale.mintedPLOTs + _quantity <= sale.maxPLOTs, "insufficient supply");

        sales[sale.id].mintedPLOTs += _quantity;
        minted[sale.id][msg.sender] += _quantity;

        _mintTo(
            _to,
            sale.volume,
            sale.presale,
            sale.startTokenIndex + sale.mintedPLOTs,
            _quantity
        );
    }

    function adminSaleMintTo(address _to, uint256 _quantity) external onlyRole(MINTER_ROLE) {

        Sale memory sale = currentSale();

        require(sale.mintedPLOTs + _quantity <= sale.maxPLOTs, "insufficient supply");

        sales[sale.id].mintedPLOTs += _quantity;
        minted[sale.id][msg.sender] += _quantity;

        _mintTo(
            _to,
            sale.volume,
            sale.presale,
            sale.startTokenIndex + sale.mintedPLOTs,
            _quantity
        );
    }

    function adminMintTo(
        address _to,
        uint256 _volume,
        uint256 _presale,
        uint256 _startTokenIndex,
        uint256 _quantity
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {

        addSale(
            _volume,
            _presale,
            block.timestamp,
            block.timestamp,
            false,
            bytes32(0),
            0,
            2**256 - 1,
            _startTokenIndex,
            _quantity
        );

        sales[sales.length - 1].mintedPLOTs = _quantity;

        _mintTo(_to, _volume, _presale, _startTokenIndex, _quantity);
    }
}