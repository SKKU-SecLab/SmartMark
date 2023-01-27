
pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

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
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

pragma solidity ^0.8.0;

contract Events {

    event LockedEgg(
        uint256 eggId,
        address indexed owner,
        uint256 startTimestamp,
        uint256 endTimestamp
    );

    event OpenedEgg(
        uint256 eggId,
        address indexed owner
    );

    event ClosedEgg(
        uint256 eggId,
        address indexed owner
    );

    event DepositedErc20IntoEgg(
        uint256 eggId,
        address indexed owner,
        address indexed erc20Token,
        uint256 amount
    );

    event WithdrewErc20FromEgg(
        uint256 eggId,
        address indexed owner,
        address indexed erc20Token,
        uint256 amount,
        address indexed to
    );

    event SentErc20(
        uint256 fromEggId,
        address indexed owner,
        address indexed erc20Token,
        uint256 amount,
        uint256 toEggId
    );

    event DepositedErc721IntoEgg(
        uint256 eggId,
        address indexed owner,
        address indexed erc721Token,
        uint256 tokenId
    );

    event WithdrewErc721FromEgg(
        uint256 eggId,
        address indexed owner,
        address indexed erc721Token,
        uint256 tokenId,
        address indexed to
    );

    event SentErc721(
        uint256 fromEggId,
        address indexed owner,
        address indexed erc721Token,
        uint256 tokenId,
        uint256 toEggId
    );

    event DepositedErc1155IntoEgg(
        uint256 eggId,
        address indexed owner,
        address indexed erc1155Token,
        uint256 tokenId,
        uint256 amount
    );

    event WithdrewErc1155FromEgg(
        uint256 eggId,
        address indexed owner,
        address indexed erc1155Token,
        uint256 tokenId,
        uint256 amount,
        address indexed to
    );

    event SentErc1155(
        uint256 fromEggId,
        address indexed owner,
        address indexed erc1155Token,
        uint256 tokenId,
        uint256 amount,
        uint256 toEggId
    );

    event SwapedErc20(
        address indexed owner,
        uint256 eggId,
        address inToken,
        uint256 inAmount,
        address outToken,
        address indexed to
    );

    event SwapedErc721(
        address indexed owner,
        uint256 eggId,
        address inToken,
        uint256 inId,
        address outToken,
        address indexed to
    );

    event SwapedErc1155(
        address indexed owner,
        uint256 eggId,
        address inToken,
        uint256 inId,
        uint256 inAmount,
        address outToken,
        uint256 outId,
        address indexed to
    );
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}

pragma solidity ^0.8.0;


interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

interface IERC721 {

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function totalSupply() external view returns (uint256);

    function exists(uint256 tokenId) external view returns (bool);

    function approve(address to, uint256 tokenId) external;

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function mintCreature() external returns (uint256 creatureId);

}

interface IERC1155 {

    function setApprovalForAll(address operator, bool approved) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

}

interface ISwap {

    function swapErc20(
        uint256 eggId,
        address inToken,
        uint256 inAmount,
        address outToken,
        uint8 router,
        address to
    ) external;

    function swapErc721(
        uint256 eggId,
        address inToken,
        uint256 inId,
        address outToken,
        uint8 router,
        address to
    ) external;

    function swapErc1155(
        uint256 eggId,
        address inToken,
        uint256 inId,
        uint256 inAmount,
        address outToken,
        uint256 outId,
        uint8 router,
        address to
    ) external;

}

contract ApymonPack is ERC165, IERC1155Receiver, IERC721Receiver, Context, Events, Ownable {


    struct Token {
        uint8 tokenType; // 1: ERC20, 2: ERC721, 3: ERC1155
        address tokenAddress;
    }

    uint8 private constant TOKEN_TYPE_ERC20 = 1;
    uint8 private constant TOKEN_TYPE_ERC721 = 2;
    uint8 private constant TOKEN_TYPE_ERC1155 = 3;

    uint256 private constant MAX_EGG_SUPPLY = 6400;

    mapping(uint256 => mapping(address => uint256)) private _insideERC20TokenBalances;

    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) private _insideERC1155TokenBalances;

    mapping(uint256 => Token[]) private _insideTokens;

    mapping(uint256 => mapping(address => uint256[])) private _insideTokenIds;

    mapping(uint256 => uint256) private _lockedTimestamp;

    mapping(uint256 => bool) private _opened;

    IERC721 public _apymon;

    bool public _enableClose;
    ISwap public _swap;

    modifier onlyEggOwner(uint256 eggId) {

        require(_apymon.exists(eggId));
        require(_apymon.ownerOf(eggId) == msg.sender);
        _;
    }

    modifier unlocked(uint256 eggId) {

        require(
            _lockedTimestamp[eggId] == 0 ||
            _lockedTimestamp[eggId] < block.timestamp
        );
        _;
    }

    modifier opened(uint256 eggId) {

        require(isOpened(eggId));
        _;
    }

    constructor(
        address apymon
    ) {
        _apymon = IERC721(apymon);
        _enableClose = false;
    }


    function existsId(
        uint256 eggId,
        address token,
        uint256 id
    ) public view returns (bool) {

        uint256[] memory ids = _insideTokenIds[eggId][token];

        for (uint256 i; i < ids.length; i++) {
            if (ids[i] == id) {
                return true;
            }
        }

        return false;
    }

    function isLocked(
        uint256 eggId
    ) external view returns (bool locked, uint256 endTime) {

        if (
            _lockedTimestamp[eggId] == 0 ||
            _lockedTimestamp[eggId] < block.timestamp
        ) {
            locked = false;
        } else {
            locked = true;
            endTime = _lockedTimestamp[eggId];
        }
    }

    function isOpened(
        uint256 eggId
    ) public view returns (bool) {

        return _opened[eggId];
    }

    function isClaimedCreature(
        uint256 eggId
    ) public view returns (bool) {

        return _apymon.exists(eggId + MAX_EGG_SUPPLY);
    }

    function getInsideTokensCount(
        uint256 eggId
    ) public view opened(eggId) returns (
        uint256 erc20Len,
        uint256 erc721Len,
        uint256 erc1155Len
    ) {

        Token[] memory tokens = _insideTokens[eggId];
        for (uint256 i; i < tokens.length; i++) {
            Token memory token = tokens[i];
            if (token.tokenType == TOKEN_TYPE_ERC20) {
                erc20Len += 1;
            }
            if (token.tokenType == TOKEN_TYPE_ERC721) {
                erc721Len += 1;
            }
            if (token.tokenType == TOKEN_TYPE_ERC1155) {
                erc1155Len += 1;
            }
        }
    }

    function getTokens(
        uint256 eggId
    ) external view opened(eggId) returns (
        uint8[] memory tokenTypes,
        address[] memory tokenAddresses
    ) {

        Token[] memory tokens = _insideTokens[eggId];
        
        tokenTypes = new uint8[](tokens.length);
        tokenAddresses = new address[](tokens.length);

        for (uint256 i; i < tokens.length; i++) {
            tokenTypes[i] = tokens[i].tokenType;
            tokenAddresses[i] = tokens[i].tokenAddress;
        }        
    }

    function getERC20Tokens(
        uint256 eggId
    ) public view opened(eggId) returns (
        address[] memory addresses,
        uint256[] memory tokenBalances
    ) {

        Token[] memory tokens = _insideTokens[eggId];
        (
            uint256 erc20Len,
            ,
        ) = getInsideTokensCount(eggId);
        
        tokenBalances = new uint256[](erc20Len);
        addresses = new address[](erc20Len);
        uint256 j;

        for (uint256 i; i < tokens.length; i++) {
            Token memory token = tokens[i];
            if (token.tokenType == TOKEN_TYPE_ERC20) {
                addresses[j] = token.tokenAddress;
                tokenBalances[j] = _insideERC20TokenBalances[eggId][token.tokenAddress];
                j++;
            }
        }        
    }

    function getERC721Tokens(
        uint256 eggId
    ) public view opened(eggId) returns (
        address[] memory addresses,
        uint256[] memory tokenBalances
    ) {

        Token[] memory tokens = _insideTokens[eggId];
        (
            ,
            uint256 erc721Len
            ,
        ) = getInsideTokensCount(eggId);
        
        tokenBalances = new uint256[](erc721Len);
        addresses = new address[](erc721Len);
        uint256 j;

        for (uint256 i; i < tokens.length; i++) {
            Token memory token = tokens[i];
            if (token.tokenType == TOKEN_TYPE_ERC721) {
                addresses[j] = token.tokenAddress;
                tokenBalances[j] = _insideTokenIds[eggId][token.tokenAddress].length;
                j++;
            }
        }
    }

    function getERC721OrERC1155Ids(
        uint256 eggId,
        address insideToken
    ) public view opened(eggId) returns (uint256[] memory) {

        return _insideTokenIds[eggId][insideToken];
    }

    function getERC1155Tokens(
        uint256 eggId
    ) public view opened(eggId) returns (address[] memory addresses) {

        Token[] memory tokens = _insideTokens[eggId];
        (
            ,
            ,
            uint256 erc1155Len
        ) = getInsideTokensCount(eggId);
        
        addresses = new address[](erc1155Len);
        uint256 j;

        for (uint256 i; i < tokens.length; i++) {
            Token memory token = tokens[i];
            if (token.tokenType == TOKEN_TYPE_ERC1155) {
                addresses[j] = token.tokenAddress;
                j++;
            }
        }
    }

    function getERC1155TokenBalances(
        uint256 eggId,
        address insideToken,
        uint256[] memory tokenIds
    ) public view opened(eggId) returns (uint256[] memory tokenBalances) {

        tokenBalances = new uint256[](tokenIds.length);
        for (uint256 i; i < tokenIds.length; i++) {
            tokenBalances[i] = _insideERC1155TokenBalances[eggId][insideToken][tokenIds[i]];
        }
    }


    function lockEgg(
        uint256 eggId,
        uint256 timeInSeconds
    ) external onlyEggOwner(eggId) opened(eggId) unlocked(eggId) {

        _lockedTimestamp[eggId] = block.timestamp + timeInSeconds;
        emit LockedEgg(
            eggId,
            msg.sender,
            block.timestamp,
            block.timestamp + timeInSeconds
        );
    }

    function setEnableClose(bool enabled) external onlyOwner {

        _enableClose = enabled;
    }

    function setSwap(address swap) external onlyOwner {

        _swap = ISwap(swap);
    }

    function openEgg(
        uint256 eggId,
        bool isClaimCreature
    ) external onlyEggOwner(eggId) {

        _opened[eggId] = true;
        emit OpenedEgg(
            eggId,
            msg.sender
        );

        if (isClaimCreature && !isClaimedCreature(eggId)) {
            claimCreature(eggId);
        }
    }

    function closeEgg(
        uint256 eggId
    ) external onlyEggOwner(eggId) {

        require(_enableClose == true);
        _opened[eggId] = false;
        emit ClosedEgg(
            eggId,
            msg.sender
        );
    }

    function depositErc20IntoEgg(
        uint256 eggId,
        address[] memory tokens,
        uint256[] memory amounts
    ) external {

        require(
            tokens.length > 0 &&
            tokens.length == amounts.length
        );

        for (uint256 i; i < tokens.length; i++) {
            require(tokens[i] != address(0));
            IERC20 iToken = IERC20(tokens[i]);

            uint256 prevBalance = iToken.balanceOf(address(this));
            iToken.transferFrom(
                msg.sender,
                address(this),
                amounts[i]
            );
            uint256 receivedAmount = iToken.balanceOf(address(this)) - prevBalance;

            _increaseInsideTokenBalance(
                eggId,
                TOKEN_TYPE_ERC20,
                tokens[i],
                receivedAmount
            );

            if (isOpened(eggId)) {
                emit DepositedErc20IntoEgg(
                    eggId,
                    msg.sender,
                    tokens[i],
                    receivedAmount
                );
            }
        }
    }

    function withdrawErc20FromEgg(
        uint256 eggId,
        address[] memory tokens,
        uint256[] memory amounts,
        address to
    ) public onlyEggOwner(eggId) unlocked(eggId) opened(eggId) {

        require(
            tokens.length > 0 &&
            tokens.length == amounts.length
        );

        for (uint256 i; i < tokens.length; i++) {
            require(tokens[i] != address(0));
            IERC20 iToken = IERC20(tokens[i]);

            iToken.transfer(to, amounts[i]);

            _decreaseInsideTokenBalance(
                eggId,
                TOKEN_TYPE_ERC20,
                tokens[i],
                amounts[i]
            );
            emit WithdrewErc20FromEgg(
                eggId,
                msg.sender,
                tokens[i],
                amounts[i],
                to
            );
        }
    }

    function sendErc20(
        uint256 fromEggId,
        address[] memory tokens,
        uint256[] memory amounts,
        uint256 toEggId
    ) public onlyEggOwner(fromEggId) unlocked(fromEggId) opened(fromEggId) {

        require(fromEggId != toEggId);
        require(
            tokens.length > 0 &&
            tokens.length == amounts.length
        );

        for (uint256 i; i < tokens.length; i++) {
            require(tokens[i] != address(0));
            require(_apymon.exists(toEggId));

            _decreaseInsideTokenBalance(
                fromEggId,
                TOKEN_TYPE_ERC20,
                tokens[i],
                amounts[i]
            );

            _increaseInsideTokenBalance(
                toEggId,
                TOKEN_TYPE_ERC20,
                tokens[i],
                amounts[i]
            );

            emit SentErc20(
                fromEggId,
                msg.sender,
                tokens[i],
                amounts[i],
                toEggId
            );
        }
    }

    function depositErc721IntoEgg(
        uint256 eggId,
        address token,
        uint256[] memory tokenIds
    ) external {

        require(token != address(0));

        for (uint256 i; i < tokenIds.length; i++) {
            require(
                token != address(this) ||
                (token == address(this) && eggId != tokenIds[i])
            );
            IERC721 iToken = IERC721(token);
            
            iToken.safeTransferFrom(
                msg.sender,
                address(this),
                tokenIds[i]
            );

            _putInsideTokenId(
                eggId,
                token,
                tokenIds[i]
            );

            if (isOpened(eggId)) {
                emit DepositedErc721IntoEgg(
                    eggId,
                    msg.sender,
                    token,
                    tokenIds[i]
                );
            }
        }
    }

    function withdrawErc721FromEgg(
        uint256 eggId,
        address token,
        uint256[] memory tokenIds,
        address to
    ) public onlyEggOwner(eggId) unlocked(eggId) opened(eggId) {

        require(token != address(0));
        IERC721 iToken = IERC721(token);

        for (uint256 i; i < tokenIds.length; i++) {
            address tokenOwner = iToken.ownerOf(tokenIds[i]);

            require(tokenOwner == address(this));

            iToken.safeTransferFrom(
                tokenOwner,
                to,
                tokenIds[i]
            );

            _popInsideTokenId(
                eggId,
                token,
                tokenIds[i]
            );

            emit WithdrewErc721FromEgg(
                eggId,
                msg.sender,
                token,
                tokenIds[i],
                to
            );
        }
    }

    function sendErc721(
        uint256 fromEggId,
        address token,
        uint256[] memory tokenIds,
        uint256 toEggId
    ) public onlyEggOwner(fromEggId) unlocked(fromEggId) opened(fromEggId) {

        require(fromEggId != toEggId);
        require(token != address(0));
        require(_apymon.exists(toEggId));

        for (uint256 i; i < tokenIds.length; i++) {
            _popInsideTokenId(
                fromEggId,
                token,
                tokenIds[i]
            );

            _putInsideTokenId(
                toEggId,
                token,
                tokenIds[i]
            );

            emit SentErc721(
                fromEggId,
                msg.sender,
                token,
                tokenIds[i],
                toEggId
            );
        }
    }

    function depositErc1155IntoEgg(
        uint256 eggId,
        address token,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) external {

        require(token != address(0));
        IERC1155 iToken = IERC1155(token);

        for (uint256 i; i < tokenIds.length; i++) {
            iToken.safeTransferFrom(
                msg.sender,
                address(this),
                tokenIds[i],
                amounts[i],
                bytes("")
            );

            _putInsideTokenIdForERC1155(
                eggId,
                token,
                tokenIds[i]
            );

            _increaseInsideERC1155TokenBalance(
                eggId,
                TOKEN_TYPE_ERC1155,
                token,
                tokenIds[i],
                amounts[i]
            );

            if (isOpened(eggId)) {
                emit DepositedErc1155IntoEgg(
                    eggId,
                    msg.sender,
                    token,
                    tokenIds[i],
                    amounts[i]
                );
            }
        }
    }

    function withdrawErc1155FromEgg(
        uint256 eggId,
        address token,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        address to
    ) public onlyEggOwner(eggId) unlocked(eggId) opened(eggId) {

        require(token != address(0));
        IERC1155 iToken = IERC1155(token);

        for (uint256 i; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            uint256 amount = amounts[i];

            iToken.safeTransferFrom(
                address(this),
                to,
                tokenId,
                amount,
                bytes("")
            );

            _decreaseInsideERC1155TokenBalance(
                eggId,
                token,
                tokenId,
                amount
            );

            _popInsideTokenIdForERC1155(
                eggId,
                token,
                tokenId
            );

            _popERC1155FromEgg(
                eggId,
                token,
                tokenId
            );
            emit WithdrewErc1155FromEgg(
                eggId,
                msg.sender,
                token,
                tokenId,
                amount,
                to
            );
        }
    }

    function sendErc1155(
        uint256 fromEggId,
        address token,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        uint256 toEggId
    ) public onlyEggOwner(fromEggId) unlocked(fromEggId) opened(fromEggId) {

        require(fromEggId != toEggId);
        require(token != address(0));
        require(_apymon.exists(toEggId));

        for (uint256 i; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            uint256 amount = amounts[i];

            _decreaseInsideERC1155TokenBalance(
                fromEggId,
                token,
                tokenId,
                amount
            );

            _increaseInsideERC1155TokenBalance(
                toEggId,
                TOKEN_TYPE_ERC1155,
                token,
                tokenId,
                amount
            );

            _popInsideTokenIdForERC1155(
                fromEggId,
                token,
                tokenId
            );

            _putInsideTokenIdForERC1155(
                toEggId,
                token,
                tokenId
            );

            _popERC1155FromEgg(
                fromEggId,
                token,
                tokenId
            );
            emit SentErc1155(
                fromEggId,
                msg.sender,
                token,
                tokenId,
                amount,
                toEggId
            );
        }
    }

    function withdrawAll(
        uint256 eggId,
        address to
    ) external {

        require(to != address(0));
        (address[] memory erc20Addresses, uint256[] memory erc20Balances) = getERC20Tokens(eggId);
        withdrawErc20FromEgg(
            eggId,
            erc20Addresses,
            erc20Balances,
            to
        );

        (address[] memory erc721Addresses, ) = getERC721Tokens(eggId);
        for (uint256 a; a < erc721Addresses.length; a++) {
            uint256[] memory ids = getERC721OrERC1155Ids(
                eggId,
                erc721Addresses[a]
            );
            withdrawErc721FromEgg(
                eggId,
                erc721Addresses[a],
                ids,
                to
            );
        }

        address[] memory erc1155Addresses = getERC1155Tokens(eggId);
        for (uint256 a; a < erc1155Addresses.length; a++) {
            uint256[] memory ids = getERC721OrERC1155Ids(
                eggId,
                erc1155Addresses[a]
            );
            uint256[] memory tokenBalances = getERC1155TokenBalances(
                eggId,
                erc1155Addresses[a],
                ids
            );
            withdrawErc1155FromEgg(
                eggId,
                erc1155Addresses[a],
                ids,
                tokenBalances,
                to
            );
        }
    }

    function sendAll(
        uint256 fromEggId,
        uint256 toEggId
    ) external {

        (
            address[] memory erc20Addresses,
            uint256[] memory erc20Balances
        ) = getERC20Tokens(fromEggId);
        sendErc20(
            fromEggId,
            erc20Addresses,
            erc20Balances,
            toEggId
        );

        (
            address[] memory erc721Addresses
            ,
        ) = getERC721Tokens(fromEggId);
        for (uint256 a; a < erc721Addresses.length; a++) {
            uint256[] memory ids = getERC721OrERC1155Ids(
                fromEggId,
                erc721Addresses[a]
            );
            sendErc721(
                fromEggId,
                erc721Addresses[a],
                ids,
                toEggId
            );
        }

        address[] memory erc1155Addresses = getERC1155Tokens(fromEggId);
        for (uint256 a; a < erc1155Addresses.length; a++) {
            uint256[] memory ids = getERC721OrERC1155Ids(
                fromEggId,
                erc1155Addresses[a]
            );
            uint256[] memory tokenBalances = getERC1155TokenBalances(
                fromEggId,
                erc1155Addresses[a],
                ids
            );
            sendErc1155(
                fromEggId,
                erc1155Addresses[a],
                ids,
                tokenBalances,
                toEggId
            );
        }
    }
    
    function increaseInsideTokenBalance(
        uint256 eggId,
        uint8 tokenType,
        address token,
        uint256 amount
    ) external {

        require(msg.sender != address(0));
        require(msg.sender == address(_apymon));

        _increaseInsideTokenBalance(
            eggId,
            tokenType,
            token,
            amount
        );
    }

    function claimCreature(
        uint256 eggId
    ) public onlyEggOwner(eggId) {

        uint256 creatureId = _apymon.mintCreature();

        _putInsideTokenId(
            eggId,
            address(_apymon),
            creatureId
        );

        emit DepositedErc721IntoEgg(
            eggId,
            address(this),
            address(_apymon),
            creatureId
        );
    }

    function swapErc20(
        uint256 eggId,
        address inToken,
        uint256 inAmount,
        address outToken,
        uint8 router,
        address to
    ) external onlyEggOwner(eggId) unlocked(eggId) opened(eggId) {

        require(address(_swap) != address(0));
        require(_insideERC20TokenBalances[eggId][inToken] >= inAmount);

        IERC20(inToken).approve(address(_swap), inAmount);

        _swap.swapErc20(
            eggId,
            inToken,
            inAmount,
            outToken,
            router,
            to
        );
        emit SwapedErc20(
            msg.sender,
            eggId,
            inToken,
            inAmount,
            outToken,
            to
        );

        _decreaseInsideTokenBalance(
            eggId,
            TOKEN_TYPE_ERC20,
            inToken,
            inAmount
        );
    }

    function swapErc721(
        uint256 eggId,
        address inToken,
        uint256 inId,
        address outToken,
        uint8 router,
        address to
    ) external onlyEggOwner(eggId) unlocked(eggId) opened(eggId) {

        require(address(_swap) != address(0));
        require(existsId(eggId, inToken, inId));
        
        IERC721(inToken).approve(address(_swap), inId);

        _swap.swapErc721(
            eggId,
            inToken,
            inId,
            outToken,
            router,
            to
        );
        emit SwapedErc721(
            msg.sender,
            eggId,
            inToken,
            inId,
            outToken,
            to
        );

        _popInsideTokenId(
            eggId,
            inToken,
            inId
        );
    }

    function swapErc1155(
        uint256 eggId,
        address inToken,
        uint256 inId,
        uint256 inAmount,
        address outToken,
        uint256 outId,
        uint8 router,
        address to
    ) external onlyEggOwner(eggId) unlocked(eggId) opened(eggId) {

        require(address(_swap) != address(0));
        require(existsId(eggId, inToken, inId));
        require(
            _insideERC1155TokenBalances[eggId][inToken][inId] >= inAmount
        );

        IERC1155(inToken).setApprovalForAll(address(_swap), true);

        _swap.swapErc1155(
            eggId,
            inToken,
            inId,
            inAmount,
            outToken,
            outId,
            router,
            to
        );
        emit SwapedErc1155(
            msg.sender,
            eggId,
            inToken,
            inId,
            inAmount,
            outToken,
            outId,
            to
        );

        _decreaseInsideERC1155TokenBalance(
            eggId,
            inToken,
            inId,
            inAmount
        );

        _popInsideTokenIdForERC1155(
            eggId,
            inToken,
            inId
        );

        _popERC1155FromEgg(
            eggId,
            inToken,
            inId
        );
    }

    function _popERC1155FromEgg(
        uint256 eggId,
        address token,
        uint256 tokenId
    ) private {

        uint256[] memory ids = _insideTokenIds[eggId][token];
        if (
            _insideERC1155TokenBalances[eggId][token][tokenId] == 0 && 
            ids.length == 0
        ) {
            delete _insideERC1155TokenBalances[eggId][token][tokenId];
            delete _insideTokenIds[eggId][token];
            _popTokenFromEgg(
                eggId,
                TOKEN_TYPE_ERC1155,
                token
            );
        }
    }
    
    function _increaseInsideTokenBalance(
        uint256 eggId,
        uint8 tokenType,
        address token,
        uint256 amount
    ) private {

        _insideERC20TokenBalances[eggId][token] += amount;
        _putTokenIntoEgg(
            eggId,
            tokenType,
            token
        );
    }

    function _increaseInsideERC1155TokenBalance(
        uint256 eggId,
        uint8 tokenType,
        address token,
        uint256 tokenId,
        uint256 amount
    ) private {

        _insideERC1155TokenBalances[eggId][token][tokenId] += amount;
        _putTokenIntoEgg(
            eggId,
            tokenType,
            token
        );
    }

    function _decreaseInsideTokenBalance(
        uint256 eggId,
        uint8 tokenType,
        address token,
        uint256 amount
    ) private {

        require(_insideERC20TokenBalances[eggId][token] >= amount);
        _insideERC20TokenBalances[eggId][token] -= amount;
        if (_insideERC20TokenBalances[eggId][token] == 0) {
            delete _insideERC20TokenBalances[eggId][token];
            _popTokenFromEgg(
                eggId,
                tokenType,
                token
            );
        }
    }

    function _decreaseInsideERC1155TokenBalance(
        uint256 eggId,
        address token,
        uint256 tokenId,
        uint256 amount
    ) private {

        require(_insideERC1155TokenBalances[eggId][token][tokenId] >= amount);
        _insideERC1155TokenBalances[eggId][token][tokenId] -= amount;
    }

    function _putInsideTokenId(
        uint256 eggId,
        address token,
        uint256 tokenId
    ) private {

        uint256[] storage ids = _insideTokenIds[eggId][token];
        ids.push(tokenId);
    }

    function _putInsideTokenIdForERC1155(
        uint256 eggId,
        address token,
        uint256 tokenId
    ) private {

        uint256[] storage ids = _insideTokenIds[eggId][token];
        bool isExist;
        for (uint256 i; i < ids.length; i++) {
            if (ids[i] == tokenId) {
                isExist = true;
            }
        }
        if (!isExist) {
            ids.push(tokenId);
        }
    }

    function _popInsideTokenId(
        uint256 eggId,
        address token,
        uint256 tokenId
    ) private {

        uint256[] storage ids = _insideTokenIds[eggId][token];
        for (uint256 i; i < ids.length; i++) {
            if (ids[i] == tokenId) {
                ids[i] = ids[ids.length - 1];
                ids.pop();
            }
        }

        if (ids.length == 0) {
            delete _insideTokenIds[eggId][token];
        }
    }

    function _popInsideTokenIdForERC1155(
        uint256 eggId,
        address token,
        uint256 tokenId
    ) private {

        uint256 tokenBalance = _insideERC1155TokenBalances[eggId][token][tokenId];
        if (tokenBalance <= 0) {
            delete _insideERC1155TokenBalances[eggId][token][tokenId];
            _popInsideTokenId(
                eggId,
                token,
                tokenId
            );
        }
    }

    function _putTokenIntoEgg(
        uint256 eggId,
        uint8 tokenType,
        address tokenAddress
    ) private {

        Token[] storage tokens = _insideTokens[eggId];
        bool exists = false;
        for (uint256 i; i < tokens.length; i++) {
            if (
                tokens[i].tokenType == tokenType &&
                tokens[i].tokenAddress == tokenAddress
            ) {
                exists = true;
                break;
            }
        }

        if (!exists) {
            tokens.push(Token({
                tokenType: tokenType,
                tokenAddress: tokenAddress
            }));
        }
    }

    function _popTokenFromEgg(
        uint256 eggId,
        uint8 tokenType,
        address tokenAddress
    ) private {

        Token[] storage tokens = _insideTokens[eggId];
        for (uint256 i; i < tokens.length; i++) {
            if (
                tokens[i].tokenType == tokenType &&
                tokens[i].tokenAddress == tokenAddress
            ) {
                tokens[i] = tokens[tokens.length - 1];
                tokens.pop();
                break;
            }
        }

        if (tokens.length == 0) {
            delete _insideTokens[eggId];
        }
    }
   
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns(bytes4) {

        return 0xf23a6e61;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns(bytes4) {

        return 0xbc197c81;
    }
}
