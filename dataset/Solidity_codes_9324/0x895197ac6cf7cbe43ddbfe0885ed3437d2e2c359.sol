pragma solidity 0.8.11;

library LibPart {

    bytes32 public constant TYPE_HASH = keccak256("Part(address account,uint96 value)");

    struct Part {
        address payable account;
        uint96 value;
    }

    function hash(Part memory part) internal pure returns (bytes32) {

        return keccak256(abi.encode(TYPE_HASH, part.account, part.value));
    }
}// MIT
pragma solidity 0.8.11;


interface IRoyaltiesProvider {

    function getRoyalties(address token, uint tokenId) external returns (LibPart.Part[] memory, LibPart.Part[] memory);

}// MIT
pragma solidity 0.8.11;


interface IRoyaltiesProviderExternal {

    function getRoyalties(address token, uint tokenId) external returns (LibPart.Part[] memory);

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


abstract contract ERC165Storage is ERC165 {
    mapping(bytes4 => bool) private _supportedInterfaces;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId) || _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT
pragma solidity 0.8.11;

abstract contract HasSecondarySaleFees is ERC165Storage {
    struct Fee {
        address payable recipient;
        uint256 value;
    }

    mapping (uint256 => Fee[]) public fees;
    event SecondarySaleFees(uint256 tokenId, address[] recipients, uint[] bps);

    bytes4 private constant _INTERFACE_ID_FEES = 0xb7799584;
    constructor() {
        _registerInterface(_INTERFACE_ID_FEES);
    }

    function getFeeRecipients(uint256 id) external view returns (address payable[] memory) {
        Fee[] memory _fees = fees[id];
        address payable[] memory result = new address payable[](_fees.length);
        for (uint i = 0; i < _fees.length; i++) {
            result[i] = _fees[i].recipient;
        }
        return result;
    }

    function getFeeBps(uint256 id) external view returns (uint[] memory) {
        Fee[] memory _fees = fees[id];
        uint[] memory result = new uint[](_fees.length);
        for (uint i = 0; i < _fees.length; i++) {
            result[i] = _fees[i].value;
        }
        return result;
    }

}// MIT
pragma solidity 0.8.11;

interface IERC2981Royalties {

    function royaltyInfo(uint256 _tokenId, uint256 _value)
        external
        view
        returns (address _receiver, uint256 _royaltyAmount);

}// MIT
pragma solidity 0.8.11;


abstract contract ERC2981Royalties is ERC165Storage, IERC2981Royalties {
    struct RoyaltyInfo {
        address recipient;
        uint24 amount;
    }

    mapping(uint256 => RoyaltyInfo) internal _royalties;

    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    constructor() {
        _registerInterface(_INTERFACE_ID_ERC2981);
    }

    function _setTokenRoyalty(
        uint256 tokenId,
        address recipient,
        uint256 value
    ) internal {
        require(value <= 10000, "ERC2981Royalties: Too high");
        _royalties[tokenId] = RoyaltyInfo(recipient, uint24(value));
    }

    function royaltyInfo(uint256 tokenId, uint256 value)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        RoyaltyInfo memory royalties = _royalties[tokenId];
        receiver = royalties.recipient;
        royaltyAmount = (value * royalties.amount) / 10000;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
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


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT
pragma solidity 0.8.11;


contract RoyaltiesRegistry is IRoyaltiesProvider, OwnableUpgradeable {


    event RoyaltiesSetForToken(address indexed token, uint indexed tokenId, LibPart.Part[] royalties);
    event RoyaltiesSetForContract(address indexed token, LibPart.Part[] royalties);

    struct RoyaltiesSet {
        bool initialized;
        LibPart.Part[] royalties;
    }

    mapping(bytes32 => RoyaltiesSet) public royaltiesByTokenAndTokenId;
    mapping(address => RoyaltiesSet) public royaltiesByToken;
    mapping(address => address) public royaltiesProviders;

    bytes4 private constant _INTERFACE_ID_FEES = 0xb7799584;
    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    function __RoyaltiesRegistry_init() external initializer {

        __Ownable_init_unchained();
    }

    function setProviderByToken(address token, address provider) external {

        checkOwner(token);
        royaltiesProviders[token] = provider;
    }

    function setRoyaltiesByToken(address token, LibPart.Part[] memory royalties) external {

        checkOwner(token);
        uint sumRoyalties = 0;
        delete royaltiesByToken[token];
        for (uint i = 0; i < royalties.length; i++) {
            require(royalties[i].account != address(0x0), "RoyaltiesByToken recipient should be present");
            require(royalties[i].value != 0, "Royalty value for RoyaltiesByToken should be > 0");
            royaltiesByToken[token].royalties.push(royalties[i]);
            sumRoyalties += royalties[i].value;
        }
        require(sumRoyalties < 10000, "Set by token royalties sum more, than 100%");
        royaltiesByToken[token].initialized = true;
        emit RoyaltiesSetForContract(token, royalties);
    }

    function setRoyaltiesByTokenAndTokenId(address token, uint tokenId, LibPart.Part[] memory royalties) external {

        checkOwner(token);
        setRoyaltiesCacheByTokenAndTokenId(token, tokenId, royalties);
    }

    function checkOwner(address token) internal view {

        if ((owner() != _msgSender()) && (OwnableUpgradeable(token).owner() != _msgSender())) {
            revert("Token owner not detected");
        }
    }

    function getRoyalties(address token, uint tokenId) override external returns (LibPart.Part[] memory nftRoyalties, LibPart.Part[] memory collectionRoyalties) {

        RoyaltiesSet memory royaltiesSetCollection = royaltiesByToken[token];
        RoyaltiesSet memory royaltiesSetNFT = royaltiesByTokenAndTokenId[keccak256(abi.encode(token, tokenId))];

        if (royaltiesSetCollection.initialized) {
            collectionRoyalties = royaltiesSetCollection.royalties;
        }

        if (royaltiesSetNFT.initialized) {
            nftRoyalties = royaltiesSetNFT.royalties;
            return (nftRoyalties, collectionRoyalties);
        }

        (bool result, LibPart.Part[] memory resultRoyalties) = providerExtractor(token, tokenId);
        if (result == false) {
            resultRoyalties = royaltiesFromContract(token, tokenId);
        }
        setRoyaltiesCacheByTokenAndTokenId(token, tokenId, resultRoyalties);

        nftRoyalties = resultRoyalties;

        return (nftRoyalties, collectionRoyalties);
    }

    function setRoyaltiesCacheByTokenAndTokenId(address token, uint tokenId, LibPart.Part[] memory royalties) internal {

        uint sumRoyalties = 0;
        bytes32 key = keccak256(abi.encode(token, tokenId));
        delete royaltiesByTokenAndTokenId[key].royalties;
        for (uint i = 0; i < royalties.length; i++) {
            require(royalties[i].account != address(0x0), "RoyaltiesByTokenAndTokenId recipient should be present");
            require(royalties[i].value != 0, "Royalty value for RoyaltiesByTokenAndTokenId should be > 0");
            royaltiesByTokenAndTokenId[key].royalties.push(royalties[i]);
            sumRoyalties += royalties[i].value;
        }
        require(sumRoyalties < 10000, "Set by token and tokenId royalties sum more, than 100%");
        royaltiesByTokenAndTokenId[key].initialized = true;
        emit RoyaltiesSetForToken(token, tokenId, royalties);
    }

    function royaltiesFromContract(address token, uint tokenId) internal view returns (LibPart.Part[] memory) {

        if (IERC165Upgradeable(token).supportsInterface(_INTERFACE_ID_FEES)) {
            HasSecondarySaleFees hasFees = HasSecondarySaleFees(token);
            address payable[] memory recipients;
            try hasFees.getFeeRecipients(tokenId) returns (address payable[] memory recipientsResult) {
                recipients = recipientsResult;
            } catch {
                return new LibPart.Part[](0);
            }
            uint[] memory values;
            try hasFees.getFeeBps(tokenId) returns (uint[] memory feesResult) {
                values = feesResult;
            } catch {
                return new LibPart.Part[](0);
            }
            if (values.length != recipients.length) {
                return new LibPart.Part[](0);
            }
            LibPart.Part[] memory result = new LibPart.Part[](values.length);
            for (uint256 i = 0; i < values.length; i++) {
                result[i].value = uint96(values[i]);
                result[i].account = recipients[i];
            }
            return result;
        }
        if (IERC165Upgradeable(token).supportsInterface(_INTERFACE_ID_ERC2981)) {  
            ERC2981Royalties erc2981Royalties = ERC2981Royalties(token);

            address payable royaltyRecipient;
            uint96 royaltyValue;

            try erc2981Royalties.royaltyInfo(tokenId, 10000) returns (address recipient, uint256 value) {
                royaltyRecipient = payable(recipient);
                royaltyValue = uint96(value);
            } catch {
                return new LibPart.Part[](0);
            }

            if (royaltyRecipient == payable(address(0))) {
                return new LibPart.Part[](0);
            }

            LibPart.Part[] memory result = new LibPart.Part[](1);
            result[0].value = royaltyValue;
            result[0].account = royaltyRecipient;

            return result;
        }
        return new LibPart.Part[](0);
    }

    function providerExtractor(address token, uint tokenId) internal returns (bool result, LibPart.Part[] memory royalties) {

        result = false;
        address providerAddress = royaltiesProviders[token];
        if (providerAddress != address(0x0)) {
            IRoyaltiesProviderExternal provider = IRoyaltiesProviderExternal(providerAddress);
            try provider.getRoyalties(token, tokenId) returns (LibPart.Part[] memory royaltiesByProvider) {
                royalties = royaltiesByProvider;
                result = true;
            } catch {}
        }
    }

    function readCollectionRoyalties(address token) external view returns (LibPart.Part[] memory collectionRoyalties) {
        RoyaltiesSet memory royaltiesSetCollection = royaltiesByToken[token];

        if (royaltiesSetCollection.initialized) {
            collectionRoyalties = royaltiesSetCollection.royalties;
        }

        return collectionRoyalties;
    }

}