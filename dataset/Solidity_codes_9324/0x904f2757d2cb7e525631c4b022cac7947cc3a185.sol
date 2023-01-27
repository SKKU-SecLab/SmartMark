
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

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


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


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

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

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

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.1;

library Address {

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
}// BUSL-1.1

pragma solidity ^0.8.0;

interface IMintNFT {

    function mintFor(address to, uint64 numTokens) external;


    function transferBundle(
        address to,
        uint256 startingIndex,
        uint64 numTokens
    ) external;

}// BUSL-1.1

pragma solidity ^0.8.0;

interface ILandPiece {

    function mintFor(address to, uint8 id) external;

}// BUSL-1.1

pragma solidity ^0.8.4;


struct SupportedToken {
    IERC20 tokenAddress;
    uint256 conversionRate;
    uint8 tokenId;
    string symbol;
    bool initialized;
    bool supported;
}

struct BundleInfo {
    uint256 index;
    uint8 nr;
    uint64 quantity;
}

contract MintManager is
    Initializable,
    OwnableUpgradeable,
    IERC721Receiver,
    ERC1155Holder
{

    uint256 public price;

    IMintNFT public rabbyAddress;
    IMintNFT public owlAddress;
    IERC1155 public bundleAddress;
    ILandPiece public landPieceAddress;
    uint256 public base;

    mapping(uint8 => BundleInfo) public bundles;

    uint16 public NR_OF_SUPPORTED_TOKEN;
    mapping(uint8 => SupportedToken) public supportedToken;

    bool public publicMint;
    bool public whitelistMint;
    address public dummy;

    bytes32 public allowRoot;
    mapping(address => uint8) public whitelistClaims;
    bytes32 public bundleRoot;
    address public receiver;

    function initialize(
        IMintNFT _rabby,
        IMintNFT _owl,
        IERC1155 _bundle,
        ILandPiece _land
    ) public initializer {

        __Ownable_init();
        rabbyAddress = _rabby;
        owlAddress = _owl;
        bundleAddress = _bundle;
        landPieceAddress = _land;
        bundles[0].index = 100;
        bundles[1].index = 400;
        bundles[2].index = 670;
        bundles[3].index = 1010;
        bundles[0].nr = 60;
        bundles[1].nr = 27;
        bundles[2].nr = 17;
        bundles[3].nr = 15;
        bundles[0].quantity = 5;
        bundles[1].quantity = 10;
        bundles[2].quantity = 20;
        bundles[3].quantity = 50;
        base = 1e16;
    }

    function mintWhitelist(uint8 num, bytes32[] calldata _proof)
        external
        payable
    {

        require(msg.value >= calculatePrice(num, 0));
        require(whitelistClaims[msg.sender] <= 25 - num);
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_proof, allowRoot, leaf));
        require(whitelistMint);

        rabbyAddress.mintFor(msg.sender, num);
        whitelistClaims[msg.sender] += num;
    }

    function mintBundleWhitelist(uint8 id, bytes32[] calldata _proof)
        external
        payable
    {

        require(msg.value >= calculatePriceBundle(id, 0));
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_proof, bundleRoot, leaf));
        require(whitelistMint);

        _mintBundle(id, msg.sender);
    }

    function mintBundleWhitelistByCustomToken(
        uint8 id,
        uint256 amount,
        uint8 tokenIndex,
        bytes32[] calldata _proof
    ) external payable {

        require(supportedToken[tokenIndex].initialized);
        require(amount >= calculatePriceBundle(id, tokenIndex));
        require(whitelistMint);
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_proof, bundleRoot, leaf));
        IERC20(supportedToken[tokenIndex].tokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount
        );

        _mintBundle(id, msg.sender);
    }

    function mintWhitelistByCustomToken(
        uint256 amount,
        uint8 num,
        uint8 tokenIndex,
        bytes32[] calldata _proof
    ) external {

        require(supportedToken[tokenIndex].initialized);
        require(amount >= calculatePrice(num, tokenIndex));
        require(whitelistMint);

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_proof, allowRoot, leaf));

        IERC20(supportedToken[tokenIndex].tokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        rabbyAddress.mintFor(msg.sender, num);
        whitelistClaims[msg.sender] += num;
    }

    function mintByCustomToken(
        uint256 amount,
        uint8 num,
        uint8 tokenIndex
    ) external {

        require(supportedToken[tokenIndex].initialized);
        require(amount >= calculatePrice(num, tokenIndex));
        require(publicMint);

        IERC20(supportedToken[tokenIndex].tokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        rabbyAddress.mintFor(msg.sender, num);
    }

    function mint(uint8 num) external payable {

        require(msg.value >= calculatePrice(num, 0));
        require(publicMint);
        rabbyAddress.mintFor(msg.sender, num);
    }

    function redeemBundle(uint8 id) external {

        bundleAddress.safeTransferFrom(msg.sender, dummy, id, 1, "");

        rabbyAddress.transferBundle(
            msg.sender,
            bundles[id].index,
            bundles[id].quantity
        );
        bundles[id].index += bundles[id].quantity;

        if (id == 3) {
            owlAddress.mintFor(msg.sender, 1);
        }

        if (id >= 2) {
            landPieceAddress.mintFor(msg.sender, 1);
        }
    }

    function buyBundle(uint8 id) external payable {

        require(msg.value >= calculatePriceBundle(id, 0));
        require(publicMint);
        _mintBundle(id, msg.sender);
    }

    function presaleBundle(uint8 id, address to) external onlyOwner {

        _mintBundle(id, to);
    }

    function buyBundleByCustomToken(
        uint8 id,
        uint256 amount,
        uint8 tokenIndex
    ) external {

        require(supportedToken[tokenIndex].initialized);
        require(amount >= calculatePriceBundle(id, tokenIndex));
        require(publicMint);
        IERC20(supportedToken[tokenIndex].tokenAddress).transferFrom(
            msg.sender,
            address(this),
            amount
        );
        _mintBundle(id, msg.sender);
    }

    function calculatePriceBundle(uint8 id, uint8 tokenIndex)
        public
        view
        returns (uint256)
    {

        if (tokenIndex == 0) {
            return price * base * bundles[id].quantity;
        } else {
            return
                ((price * base * bundles[id].quantity) *
                    supportedToken[tokenIndex].conversionRate) / 10**3;
        }
    }

    function calculatePrice(uint64 num, uint8 tokenIndex)
        public
        view
        returns (uint256)
    {

        if (tokenIndex == 0) {
            return price * base * num;
        } else {
            return
                ((price * base * num) *
                    supportedToken[tokenIndex].conversionRate) / 10**3;
        }
    }


    function totalRabbyMinted() public view returns (uint256) {

        return
            IERC721Enumerable(address(rabbyAddress)).totalSupply() -
            (uint256(bundles[0].nr) * 5) -
            (uint256(bundles[1].nr) * 10) -
            (uint256(bundles[2].nr) * 20) -
            (uint256(bundles[3].nr) * 50);
    }


    function _mintBundle(uint8 id, address to) private {

        bundleAddress.safeTransferFrom(address(this), to, id, 1, "");
        bundles[id].nr--;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }


    function setRoot(bytes32 _root) public onlyOwner {

        allowRoot = _root;
    }

    function setBundleRoot(bytes32 _root) public onlyOwner {

        bundleRoot = _root;
    }

    function setPrice(uint256 _price) public onlyOwner {

        price = _price;
    }

    function setDummy(address _dummy) public onlyOwner {

        dummy = _dummy;
    }

    function withdraw() public payable onlyOwner {

        require(payable(receiver).send(msg.value));
    }

    function setReceiver(address _receiver) public onlyOwner {

        receiver = _receiver;
    }

    function setNftAddress(IMintNFT _rabby) public onlyOwner {

        rabbyAddress = _rabby;
    }

    function setOwlAddress(IMintNFT _owl) public onlyOwner {

        owlAddress = _owl;
    }

    function setBundleAddress(IERC1155 _bundleAddress) public onlyOwner {

        bundleAddress = _bundleAddress;
    }

    function setLandAddress(ILandPiece _landAddress) public onlyOwner {

        landPieceAddress = _landAddress;
    }

    function setSupportedToken(
        uint8 tokenId,
        IERC20 tokenAddress,
        uint256 conversionRate,
        string calldata symbol
    ) public onlyOwner {

        require(tokenId > 0, "should put tokenId > 0");
        if (!supportedToken[tokenId].initialized) {
            NR_OF_SUPPORTED_TOKEN++;
        }
        supportedToken[tokenId].initialized = true;
        supportedToken[tokenId].supported = true;
        supportedToken[tokenId].tokenAddress = tokenAddress;
        supportedToken[tokenId].conversionRate = conversionRate;
        supportedToken[tokenId].symbol = symbol;
        supportedToken[tokenId].tokenId = tokenId;
    }

    function turnOffSupportedToken(uint8 tokenId) public onlyOwner {

        require(tokenId > 0, "should put tokenId > 0");
        require(supportedToken[tokenId].initialized == true);
        supportedToken[tokenId].supported = false;
    }

    function turnOnSupportedToken(uint8 tokenId) public onlyOwner {

        require(tokenId > 0, "should put tokenId > 0");
        require(supportedToken[tokenId].initialized == true);
        supportedToken[tokenId].supported = true;
    }

    function toggleWhitelist() public onlyOwner {

        whitelistMint = !whitelistMint;
    }

    function togglePublicMint() public onlyOwner {

        publicMint = !publicMint;
    }
}