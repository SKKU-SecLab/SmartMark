


pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



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

}



pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}



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

}



pragma solidity >=0.7.0;

interface IERC1155Views {


    function totalSupply(uint256 itemId) external view returns (uint256);


    function name(uint256 itemId) external view returns (string memory);


    function symbol(uint256 itemId) external view returns (string memory);


    function decimals(uint256 itemId) external view returns (uint256);


    function uri(uint256 itemId) external view returns (string memory);

}



pragma solidity >=0.7.0;
pragma abicoder v2;


struct Header {
    address host;
    string name;
    string symbol;
    string uri;
}

struct CreateItem {
    Header header;
    bytes32 collectionId;
    uint256 id;
    address[] accounts;
    uint256[] amounts;
}

interface Item is IERC1155, IERC1155Views {


    event CollectionItem(bytes32 indexed fromCollectionId, bytes32 indexed toCollectionId, uint256 indexed itemId);

    function name() external view returns(string memory);

    function symbol() external view returns(string memory);

    function decimals() external view returns(uint256);


    function burn(address account, uint256 itemId, uint256 amount) external;

    function burnBatch(address account, uint256[] calldata itemIds, uint256[] calldata amounts) external;


    function burn(address account, uint256 itemId, uint256 amount, bytes calldata data) external;

    function burnBatch(address account, uint256[] calldata itemIds, uint256[] calldata amounts, bytes calldata data) external;


    function mintItems(CreateItem[] calldata items) external returns(uint256[] memory itemIds);

    function setItemsCollection(uint256[] calldata itemIds, bytes32[] calldata collectionIds) external returns(bytes32[] memory oldCollectionIds);

    function setItemsMetadata(uint256[] calldata itemIds, Header[] calldata newValues) external returns(Header[] memory oldValues);


    function interoperableOf(uint256 itemId) external view returns(address);

}



pragma solidity >=0.7.0;
interface IDeckPresto is IERC721Receiver, IERC1155Receiver {


    function data() external view returns(address prestoAddress, address erc721DeckWrapper, address erc1155DeckWrapper);


    function buyAndUnwrap(PrestoOperation calldata operation, bool isERC721, bytes[] calldata payload) external payable returns(uint256 outputAmount);


    function wrapAndSell721(address tokenAddress, uint256[] calldata tokenIds, bool[] calldata reserve, PrestoOperation[] calldata operations) external returns(uint256[] memory outputAmounts);

}

struct PrestoOperation {

    address inputTokenAddress;
    uint256 inputTokenAmount;

    address ammPlugin;
    address[] liquidityPoolAddresses;
    address[] swapPath;
    bool enterInETH;
    bool exitInETH;

    uint256[] tokenMins;

    address[] receivers;
    uint256[] receiversPercentages;
}

interface IPrestoUniV3 {


    function execute(PrestoOperation[] memory operations) external payable returns(uint256[] memory outputAmounts);

}



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

}



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
}


pragma solidity >=0.7.0;

interface ILazyInitCapableElement is IERC165 {


    function lazyInit(bytes calldata lazyInitData) external returns(bytes memory initResponse);

    function initializer() external view returns(address);


    event Host(address indexed from, address indexed to);

    function host() external view returns(address);

    function setHost(address newValue) external returns(address oldValue);


    function subjectIsAuthorizedFor(address subject, address location, bytes4 selector, bytes calldata payload, uint256 value) external view returns(bool);

}



pragma solidity >=0.7.0;
//pragma abicoder v2;


interface IItemProjection is Item, ILazyInitCapableElement {


    function mainInterface() external view returns(address);


    function collectionId() external view returns(bytes32);

    function uri() external view returns(string memory);

    function plainUri() external view returns(string memory);

    function itemPlainUri(uint256 itemId) external view returns(string memory);

    function setHeader(Header calldata value) external returns(Header memory oldValue);


    function toInteroperableInterfaceAmount(uint256 amount, uint256 itemId, address account) external view returns(uint256);

    function toMainInterfaceAmount(uint256 amount, uint256 itemId) external view returns(uint256);

}



pragma solidity >=0.7.0;

interface IERC721DeckWrapper is IItemProjection {


    function reserveTimeInBlocks() external view returns(uint256);


    function reserveData(address tokenAddress, uint256 tokenId) external view returns(address unwrapper, uint256 timeout);


    function unlockReserves(address[] calldata tokenAddresses, uint256[] calldata tokenIds) external;


    function mintItems(CreateItem[] calldata createItemsInput, bool[] calldata reserveArray) external returns(uint256[] memory itemIds);


    event Token(address indexed tokenAddress, uint256 indexed tokenId, uint256 indexed itemId);

    function itemIdOf(address tokenAddress) external view returns(uint256);


    function source(uint256 itemId) external view returns(address tokenAddress);

}



pragma solidity >=0.7.0;

interface IERC1155DeckWrapper is IItemProjection {


    function reserveTimeInBlocks() external view returns(uint256);


    function reserveData(bytes32 reserveDataKey) external view returns(address unwrapper, uint256 timeout, uint256 amount);


    event ReserveData(address from, address indexed tokenAddress, uint256 indexed tokenId, uint256 amount, uint256 timeout, bytes32 indexed reserveDataKey);

    event ReserveDataUnlocked(address indexed from, bytes32 indexed reserveDataKey, address tokenAddress, uint256 tokenId, address unwrapper, uint256 amount, uint256 timeout);

    function unlockReserves(address[] calldata owners, address[] calldata tokenAddresses, uint256[] calldata tokenIds, uint256[] calldata amounts) external;


    function mintItems(CreateItem[] calldata createItemsInput, bool[] calldata reserveArray) external returns(uint256[] memory itemIds);


    event Token(address indexed tokenAddress, uint256 indexed tokenId, uint256 indexed itemId);

    function itemIdOf(address tokenAddress, uint256 tokenId) external view returns(uint256);


    function source(uint256 itemId) external view returns(address tokenAddress, bytes32 tokenKey);

}



pragma solidity >=0.7.0;






contract DeckPresto is IDeckPresto {


    address private immutable _prestoAddress;
    address private immutable _erc721DeckWrapper;
    address private immutable _erc1155DeckWrapper;

    constructor(address prestoAddress, address erc721DeckWrapper, address erc1155DeckWrapper) {
        _prestoAddress = prestoAddress;
        _erc721DeckWrapper = erc721DeckWrapper;
        _erc1155DeckWrapper = erc1155DeckWrapper;
    }

    function supportsInterface(bytes4) external override pure returns (bool) {

        return true;
    }

    function data() external override view returns(address prestoAddress, address erc721DeckWrapper, address erc1155DeckWrapper) {

        prestoAddress = _prestoAddress;
        erc721DeckWrapper = _erc721DeckWrapper;
        erc1155DeckWrapper = _erc1155DeckWrapper;
    }

    function buyAndUnwrap(PrestoOperation calldata operation, bool isERC721, bytes[] calldata payload) external override payable returns(uint256 outputAmount) {

        uint256 itemId = uint160(operation.swapPath[operation.swapPath.length - 1]);
        require(operation.ammPlugin != address(0), "amm");
        require(operation.liquidityPoolAddresses.length > 0, "amm");

        PrestoOperation[] memory operations = new PrestoOperation[](1);
        operations[0] = PrestoOperation({
            inputTokenAddress : address(0),
            inputTokenAmount : msg.value,
            ammPlugin : operation.ammPlugin,
            liquidityPoolAddresses : operation.liquidityPoolAddresses,
            swapPath : operation.swapPath,
            enterInETH : true,
            exitInETH : false,
            tokenMins : operation.tokenMins,
            receivers : _asSingleArray(address(this)),
            receiversPercentages : new uint256[](0)
        });
        outputAmount = IPrestoUniV3(_prestoAddress).execute{value : msg.value}(operations)[0];
        require(operations[0].tokenMins.length == 0 || outputAmount >= operations[0].tokenMins[0], "slippage");

        uint256[] memory itemIds = new uint256[](payload.length);
        uint256[] memory outputAmounts = new uint256[](payload.length);

        for(uint256 i = 0; i < itemIds.length; i++) {
            itemIds[i] = itemId;
            outputAmounts[i] = outputAmount >= 1e18 ? 1e18 : outputAmount;
        }

        Item(isERC721 ? _erc721DeckWrapper : _erc1155DeckWrapper).burnBatch(address(this), itemIds, outputAmounts, abi.encode(payload));

        uint256 balance = address(this).balance;
        if(balance > 0) {
            payable(msg.sender).transfer(balance);
        }
        IERC20 token = IERC20(address(uint160(itemId)));
        balance = token.balanceOf(address(this));
        if(balance > 0) {
            token.transfer(msg.sender, balance);
        }
    }

    function wrapAndSell721(address tokenAddress, uint256[] calldata tokenIds, bool[] memory reserve, PrestoOperation[] calldata operations) external override returns(uint256[] memory outputAmounts) {

        for(uint256 i = 0; i < tokenIds.length; i++) {
            IERC721(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenIds[i]);
        }
        return _wrapAndSell721(msg.sender, tokenAddress, tokenIds, reserve, operations, false);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata payload
    ) external override returns (bytes4) {

        if(operator == address(this)) {
            return this.onERC721Received.selector;
        }
        (bool[] memory reserve, PrestoOperation[] memory operations, bool simulation) = abi.decode(payload, (bool[], PrestoOperation[], bool));
        _wrapAndSell721(from, msg.sender, _asSingleArray(tokenId), reserve, operations, simulation);
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata payload
    ) external override returns (bytes4) {

        _wrapAndSell1155(from, msg.sender, _asSingleArray(id), _asSingleArray(value), payload);
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata payload
    ) external override returns (bytes4) {

        _wrapAndSell1155(from, msg.sender, ids, values, payload);
        return this.onERC1155BatchReceived.selector;
    }

    function _wrapAndSell721(address from, address tokenAddress, uint256[] memory tokenIds, bool[] memory reserve, PrestoOperation[] memory operations, bool simulation) private returns(uint256[] memory outputAmounts) {

        IERC721(tokenAddress).setApprovalForAll(_erc721DeckWrapper, true);
        CreateItem[] memory createItems;
        uint256 itemId = IERC721DeckWrapper(_erc721DeckWrapper).itemIdOf(tokenAddress);
        (operations, createItems) = _prepareWrapAndSell(tokenAddress, tokenIds, operations, itemId);
        IERC721DeckWrapper(_erc721DeckWrapper).mintItems(createItems, reserve);
        outputAmounts = _sellAfterWrap(from, itemId, operations, simulation);
    }

    function _wrapAndSell1155(address from, address tokenAddress, uint256[] memory tokenIds, uint256[] memory values, bytes memory payload) private returns(uint256[] memory outputAmounts) {

        (bool[] memory reserve, PrestoOperation[] memory operations, bool simulation) = abi.decode(payload, (bool[], PrestoOperation[], bool));
        uint256 itemId = IERC1155DeckWrapper(_erc1155DeckWrapper).itemIdOf(tokenAddress, tokenIds[0]);
        (operations,) = _prepareWrapAndSell(tokenAddress, tokenIds, operations, itemId);
        bytes[] memory arr = new bytes[](tokenIds.length);
        for(uint256 i = 0; i < arr.length; i++) {
            arr[i] = abi.encode(_asSingleArray(values[i]), new address[](0), i < reserve.length ? reserve[i] : false);
        }
        IERC1155(tokenAddress).safeBatchTransferFrom(address(this), _erc1155DeckWrapper, tokenIds, values, abi.encode(arr));
        outputAmounts = _sellAfterWrap(from, itemId, operations, simulation);
    }

    function _prepareWrapAndSell(address tokenAddress, uint256[] memory tokenIds, PrestoOperation[] memory operations, uint256 itemId) private view returns(PrestoOperation[] memory elaboratedOperations, CreateItem[] memory createItems) {

        require(tokenAddress != address(0) && tokenIds.length > 0 && operations.length == tokenIds.length && itemId != 0, "invalid input");
        elaboratedOperations = new PrestoOperation[](1);
        elaboratedOperations[0] = operations[0];
        createItems = new CreateItem[](tokenIds.length);
        uint256 totalAmount = 0;
        uint256 tokenMins = 0;
        address[] memory receiver = _asSingleArray(address(this));
        require(elaboratedOperations[0].ammPlugin != address(0), "amm");
        require(elaboratedOperations[0].liquidityPoolAddresses.length > 0, "amm");
        elaboratedOperations[0].inputTokenAddress = address(uint160(itemId));
        elaboratedOperations[0].swapPath[elaboratedOperations[0].swapPath.length - 1] = address(0);
        elaboratedOperations[0].enterInETH = false;
        elaboratedOperations[0].exitInETH = true;
        for(uint256 i = 0; i < tokenIds.length; i++) {
            require(operations[i].inputTokenAmount > 0, "amount");
            totalAmount += operations[i].inputTokenAmount;
            tokenMins += operations[i].tokenMins[0];
            createItems[i] = CreateItem(Header(address(0), "", "", ""), bytes32(uint256(uint160(tokenAddress))), tokenIds[i], receiver, _asSingleArray(operations[i].inputTokenAmount));
        }
        require(totalAmount > 0, "amount");
        elaboratedOperations[0].inputTokenAmount = totalAmount;
        elaboratedOperations[0].tokenMins = _asSingleArray(tokenMins);
    }

    function _sellAfterWrap(address from, uint256 itemId, PrestoOperation[] memory operations, bool simulation) private returns(uint256[] memory outputAmounts) {

        IERC20 token = IERC20(address(uint160(itemId)));
        token.approve(_prestoAddress, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        outputAmounts = IPrestoUniV3(_prestoAddress).execute(operations);
        for(uint256 i = 0; i < outputAmounts.length; i++) {
            require(operations[i].tokenMins.length == 0 || outputAmounts[i] >= operations[i].tokenMins[0], "slippage");
        }
        uint256 postBalance = token.balanceOf(address(this));
        if(postBalance > 0) {
            token.transfer(from, postBalance);
        }
        if(simulation) {
            revert(string(abi.encode(outputAmounts)));
        }
    }

    function _asSingleArray(address addr) private pure returns(address[] memory arr) {

        arr = new address[](1);
        arr[0] = addr;
    }

    function _asSingleArray(uint256 num) private pure returns(uint256[] memory arr) {

        arr = new uint256[](1);
        arr[0] = num;
    }
}