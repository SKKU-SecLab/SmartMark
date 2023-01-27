
pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

contract Events721 {

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

    event SwapedErc721(
        address indexed owner,
        uint256 eggId,
        address inToken,
        uint256 inId,
        address outToken,
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


interface IERC721 {

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function exists(uint256 tokenId) external view returns (bool);

    function approve(address to, uint256 tokenId) external;

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

}

interface IAPYMONPACK {

    function isLocked(uint256 eggId) external view returns (bool locked, uint256 endTime);

    function isOpened(uint256 eggId) external view returns (bool);

}

interface ISwap {

    function swapErc721(
        uint256 eggId,
        address inToken,
        uint256 inId,
        address outToken,
        uint8 router,
        address to
    ) external;

}

contract ApymonPack721 is ERC165, IERC721Receiver, Context, Events721, Ownable {


    mapping(uint256 => address[]) private _insideTokens;

    mapping(uint256 => mapping(address => uint256[])) private _insideTokenIds;

    IERC721 public _apymon;
    IAPYMONPACK public _apymonPack;

    ISwap public _swap;

    modifier onlyEggOwner(uint256 eggId) {

        require(_apymon.exists(eggId));
        require(_apymon.ownerOf(eggId) == msg.sender);
        _;
    }

    modifier unlocked(uint256 eggId) {

        (bool locked, ) = _apymonPack.isLocked(eggId);
        require(!locked, "Egg has been locked.");
        _;
    }

    modifier opened(uint256 eggId) {

        require(_apymonPack.isOpened(eggId), "Egg has been closed");
        _;
    }

    constructor() {
        _apymon = IERC721(0x9C008A22D71B6182029b694B0311486e4C0e53DB);
        _apymonPack = IAPYMONPACK(0x3dFCB488F6e96654e827Ab2aB10a463B9927d4f9);
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

    function getInsideTokensCount(
        uint256 eggId
    ) public view opened(eggId) returns (
        uint256 erc721Len
    ) {

        return _insideTokens[eggId].length;
    }

    function getERC721Tokens(
        uint256 eggId
    ) public view opened(eggId) returns (
        address[] memory addresses,
        uint256[] memory tokenBalances
    ) {

        address[] memory tokens = _insideTokens[eggId];
        uint256 erc721Len = tokens.length;
        
        tokenBalances = new uint256[](erc721Len);
        addresses = new address[](erc721Len);
        uint256 j;

        for (uint256 i; i < tokens.length; i++) {
            addresses[j] = tokens[i];
            tokenBalances[j] = _insideTokenIds[eggId][tokens[i]].length;
            j++;
        }
    }

    function getTokenIds(
        uint256 eggId,
        address insideToken
    ) public view opened(eggId) returns (uint256[] memory) {

        return _insideTokenIds[eggId][insideToken];
    }


    function setSwap(address swap) external onlyOwner {

        _swap = ISwap(swap);
    }

    function setApymonPack(address _pack) external onlyOwner {

        _apymonPack = IAPYMONPACK(_pack);
    }

    function depositErc721IntoEgg(
        uint256 eggId,
        address token,
        uint256[] memory tokenIds
    ) external {

        require(token != address(0));

        for (uint256 i; i < tokenIds.length; i++) {
            require(
                token != address(_apymon) ||
                (token == address(_apymon) && eggId != tokenIds[i])
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

            if (_apymonPack.isOpened(eggId)) {
                emit DepositedErc721IntoEgg(
                    eggId,
                    msg.sender,
                    token,
                    tokenIds[i]
                );
            }
        }

        _putTokenIntoEgg(
            eggId,
            token
        );
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

        uint256[] memory ids = _insideTokenIds[eggId][token];

        if (ids.length == 0) {
            _popTokenFromEgg(
                eggId,
                token
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

        uint256[] memory ids = _insideTokenIds[fromEggId][token];

        if (ids.length == 0) {
            _popTokenFromEgg(
                fromEggId,
                token
            );
        }

        _putTokenIntoEgg(
            toEggId,
            token
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

    function _putInsideTokenId(
        uint256 eggId,
        address token,
        uint256 tokenId
    ) private {

        uint256[] storage ids = _insideTokenIds[eggId][token];
        ids.push(tokenId);
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

    function _putTokenIntoEgg(
        uint256 eggId,
        address tokenAddress
    ) private {

        address[] storage tokens = _insideTokens[eggId];
        bool exists = false;
        for (uint256 i; i < tokens.length; i++) {
            if (tokens[i] == tokenAddress) {
                exists = true;
                break;
            }
        }

        if (!exists) {
            tokens.push(tokenAddress);
        }
    }

    function _popTokenFromEgg(
        uint256 eggId,
        address tokenAddress
    ) private {

        address[] storage tokens = _insideTokens[eggId];
        for (uint256 i; i < tokens.length; i++) {
            if (tokens[i] == tokenAddress) {
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
}
