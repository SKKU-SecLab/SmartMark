
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

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

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;



abstract contract Ownable is Context {
    address private _owner;
    address private _authorizedNewOwner;

    event OwnershipTransferAuthorization(address indexed authorizedAddress);
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

    function authorizedNewOwner() public view virtual returns (address) {
        return _authorizedNewOwner;
    }

    function authorizeOwnershipTransfer(address authorizedAddress) external onlyOwner {
        _authorizedNewOwner = authorizedAddress;
        emit OwnershipTransferAuthorization(_authorizedNewOwner);
    }

    function assumeOwnership() external {
        require(_msgSender() == _authorizedNewOwner, "Ownable: only the authorized new owner can accept ownership");
        emit OwnershipTransferred(_owner, _authorizedNewOwner);
        _owner = _authorizedNewOwner;
        _authorizedNewOwner = address(0);
    }

    function renounceOwnership(address confirmAddress) public virtual onlyOwner {
        require(confirmAddress == _owner, "Ownable: confirm address is wrong");
        emit OwnershipTransferred(_owner, address(0));
        _authorizedNewOwner = address(0);
        _owner = address(0);
    }
    
}// MIT

pragma solidity ^0.8.0;

contract MagicLampWalletStorage {

    struct Token {
        uint8 tokenType; // TOKEN_TYPE
        address tokenAddress;
    }

    uint8 internal constant _TOKEN_TYPE_ERC20 = 1;
    uint8 internal constant _TOKEN_TYPE_ERC721 = 2;
    uint8 internal constant _TOKEN_TYPE_ERC1155 = 3;
  
    mapping(address => mapping(uint256 => mapping(address => uint256[]))) internal _erc721ERC1155TokenIds;

    mapping(address => mapping(uint256 => mapping(address => uint256))) internal _erc20TokenBalances;

    mapping(address => mapping(uint256 => mapping(address => mapping(uint256 => uint256)))) internal _erc1155TokenBalances;

    mapping(address => mapping(uint256 => uint256)) internal _ethBalances;

    address public magicLampSwap;

    address[] public walletFeatureHosts;

    mapping(address => bool) public walletFeatureHosted;

    mapping(address => mapping(uint256 => Token[])) internal _tokens;

    mapping(address => mapping(uint256 => uint256)) internal _lockedTimestamps;
}// MIT

pragma solidity ^0.8.0;


contract MagicLampWalletBase is MagicLampWalletStorage, Ownable {

    using SafeMath for uint256;

    function _onlyWalletOwner(address host, uint256 id) internal view {

        require(walletFeatureHosted[host], "Unsupported host");
        require(
            IERC721(host).ownerOf(id) == _msgSender(),
            "Only wallet owner can call"
        );
    }

    function _exists(address host, uint256 id) internal view {

        require(walletFeatureHosted[host], "Unsupported host");
        require(IERC721(host).ownerOf(id) != address(0), "NFT does not exist");
    }

    function _unlocked(address host, uint256 id) internal view {

        require(_lockedTimestamps[host][id] <= block.timestamp, "Wallet is locked");
    }

    function _onlyWalletOwnerOrHost(address host, uint256 id) internal view {

        require(walletFeatureHosted[host], "Unsupported host");
        require(
            IERC721(host).ownerOf(id) == _msgSender() || host == _msgSender(),
            "Only wallet owner or host can call"
        );
    }

    function _putToken(address host, uint256 id, uint8 tokenType, address token) internal {

        Token[] storage tokens = _tokens[host][id];

        uint256 i = 0;
        for (; i < tokens.length && (tokens[i].tokenType != tokenType || tokens[i].tokenAddress != token); i++) {
        }

        if (i == tokens.length) {
            tokens.push(Token({tokenType: tokenType, tokenAddress: token}));
        }
    }

    function _popToken(address host, uint256 id, uint8 tokenType, address token) internal {

        Token[] storage tokens = _tokens[host][id];

        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].tokenType == tokenType && tokens[i].tokenAddress == token) {
                tokens[i] = tokens[tokens.length - 1];
                tokens.pop();
                if (tokens.length == 0) {
                    delete _tokens[host][id];
                }
                return;
            }
        }        
        require(false, "Not found token");
    }

    function _putTokenId(address host, uint256 id, uint8 tokenType, address token, uint256 tokenId) internal {

        if (_erc721ERC1155TokenIds[host][id][token].length == 0) {
            _putToken(host, id, tokenType, token);
        }
        _erc721ERC1155TokenIds[host][id][token].push(tokenId);
    }

    function _popTokenId(address host, uint256 id, uint8 tokenType, address token, uint256 tokenId) internal {

        uint256[] storage ids = _erc721ERC1155TokenIds[host][id][token];

        for (uint256 i = 0; i < ids.length; i++) {
            if (ids[i] == tokenId) {
                ids[i] = ids[ids.length - 1];
                ids.pop();
                if (ids.length == 0) {
                    delete _erc721ERC1155TokenIds[host][id][token];
                    _popToken(host, id, tokenType, token);
                }
                return;
            }
        }
        require(false, "Not found token id");
    }

    function _addERC20TokenBalance(address host, uint256 id, address token, uint256 amount) internal {

        if (amount == 0) return;
        if (_erc20TokenBalances[host][id][token] == 0) {
            _putToken(host, id, _TOKEN_TYPE_ERC20, token);
        }
        _erc20TokenBalances[host][id][token] = _erc20TokenBalances[host][id][token].add(amount);
    }

    function _subERC20TokenBalance(address host, uint256 id, address token, uint256 amount) internal {

        if (amount == 0) return;
        _erc20TokenBalances[host][id][token] = _erc20TokenBalances[host][id][token].sub(amount);
        if (_erc20TokenBalances[host][id][token] == 0) {
            _popToken(host, id, _TOKEN_TYPE_ERC20, token);
        }
    }

    function _addERC1155TokenBalance(address host, uint256 id, address token, uint256 tokenId, uint256 amount) internal {

        if (amount == 0) return;
        if (_erc1155TokenBalances[host][id][token][tokenId] == 0) {
            _putTokenId(host, id, _TOKEN_TYPE_ERC1155, token, tokenId);
        }
        _erc1155TokenBalances[host][id][token][tokenId] = _erc1155TokenBalances[host][id][token][tokenId].add(amount);
    }

    function _subERC1155TokenBalance(address host, uint256 id, address token, uint256 tokenId, uint256 amount) internal {

        if (amount == 0) return;
        _erc1155TokenBalances[host][id][token][tokenId] = _erc1155TokenBalances[host][id][token][tokenId].sub(amount);
        if (_erc1155TokenBalances[host][id][token][tokenId] == 0) {
            _popTokenId(host, id, _TOKEN_TYPE_ERC1155, token, tokenId);
        }
    }
}// MIT

pragma solidity ^0.8.0;

contract MagicLampWalletEvents {

    event MagicLampWalletSupported(
        address indexed host
    );

    event MagicLampWalletUnsupported(
        address indexed host
    );

    event MagicLampWalletSwapChanged(
        address indexed previousMagicLampSwap,
        address indexed newMagicLampSwap
    );

    event MagicLampWalletLocked(
        address indexed owner,
        address indexed host,
        uint256 id,
        uint256 startTimestamp,
        uint256 endTimestamp
    );

    event MagicLampWalletOpened(
        address indexed owner,
        address indexed host,
        uint256 id
    );

    event MagicLampWalletClosed(
        address indexed owner,
        address indexed host,
        uint256 id
    );

    event MagicLampWalletETHDeposited(
        address indexed owner,
        address indexed host,
        uint256 id,
        uint256 amount
    );

    event MagicLampWalletETHWithdrawn(
        address indexed owner,
        address indexed host,
        uint256 id,
        uint256 amount,
        address to
    );

    event MagicLampWalletETHTransferred(
        address indexed owner,
        address indexed host,
        uint256 id,
        uint256 amount,
        address indexed toHost,
        uint256 toId
    );

    event MagicLampWalletERC20Deposited(
        address indexed owner,
        address indexed host,
        uint256 id,
        address erc20Token,
        uint256 amount
    );

    event MagicLampWalletERC20Withdrawn(
        address indexed owner,
        address indexed host,
        uint256 id,
        address erc20Token,
        uint256 amount,
        address to
    );

    event MagicLampWalletERC20Transferred(
        address indexed owner,
        address indexed host,
        uint256 id,
        address erc20Token,
        uint256 amount,
        address indexed toHost,
        uint256 toId
    );

    event MagicLampWalletERC721Deposited(
        address indexed owner,
        address indexed host,
        uint256 id,
        address erc721Token,
        uint256 erc721TokenId
    );

    event MagicLampWalletERC721Withdrawn(
        address indexed owner,
        address indexed host,
        uint256 id,
        address erc721Token,
        uint256 erc721TokenId,
        address to
    );

    event MagicLampWalletERC721Transferred(
        address indexed owner,
        address indexed host,
        uint256 id,
        address erc721Token,
        uint256 erc721TokenId,
        address indexed toHost,
        uint256 toId
    );

    event MagicLampWalletERC1155Deposited(
        address indexed owner,
        address indexed host,
        uint256 id,
        address erc1155Token,
        uint256 erc1155TokenId,
        uint256 amount
    );

    event MagicLampWalletERC1155Withdrawn(
        address indexed owner,
        address indexed host,
        uint256 id,
        address erc1155Token,
        uint256 erc1155TokenId,
        uint256 amount,
        address indexed to
    );

    event MagicLampWalletERC1155Transferred(
        address indexed owner,
        address indexed host,
        uint256 id,
        address erc1155Token,
        uint256 erc1155TokenId,
        uint256 amount,
        address indexed toHost,
        uint256 toId
    );

    event MagicLampWalletERC20Swapped(
        address indexed owner,
        address indexed host,
        uint256 id,
        address inToken,
        uint256 inAmount,
        address outToken,
        uint256 outAmount,
        address indexed to
    );

    event MagicLampWalletERC721Swapped(
        address indexed owner,
        address indexed host,
        uint256 id,
        address inToken,
        uint256 inTokenId,
        address outToken,
        uint256 outTokenId,
        address indexed to
    );

    event MagicLampWalletERC1155Swapped(
        address indexed owner,
        address indexed host,
        uint256 id,
        address inToken,
        uint256 inTokenId,
        uint256 inAmount,
        address outToken,
        uint256 outTokenId,
        uint256 outTokenAmount,
        address indexed to
    );
    
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

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

}// MIT

pragma solidity ^0.8.0;


contract ERC165 is IERC165 {

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
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function burn(uint256 burnQuantity) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


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

}// MIT

pragma solidity ^0.8.0;



contract MagicLampWallet is MagicLampWalletBase, MagicLampWalletEvents, ERC165, IERC1155Receiver, IERC721Receiver {

    using SafeMath for uint256;

    function tokenTypeERC20() external pure returns (uint8) {

        return _TOKEN_TYPE_ERC20;
    }

    function tokenTypeERC721() external pure returns (uint8) {

        return _TOKEN_TYPE_ERC721;
    }

    function tokenTypeERC1155() external pure returns (uint8) {

        return _TOKEN_TYPE_ERC1155;
    }

    function isLocked(address host, uint256 id) external view returns (bool locked, uint256 endTime) {

        if (_lockedTimestamps[host][id] <= block.timestamp) {
            locked = false;
        } else {
            locked = true;
            endTime = _lockedTimestamps[host][id] - 1;
        }
    }

    function getTokensCount(address host, uint256 id)
    public view returns (uint256 ethCount, uint256 erc20Count, uint256 erc721Count, uint256 erc1155Count) {

        if (_ethBalances[host][id] > 0) {
            ethCount = 1;
        }

        Token[] memory tokens = _tokens[host][id];

        for (uint256 i = 0; i < tokens.length; i++) {
            Token memory token = tokens[i];
            if (token.tokenType == _TOKEN_TYPE_ERC20) {
                erc20Count++;
            } else if (token.tokenType == _TOKEN_TYPE_ERC721) {
                erc721Count++;
            } else if (token.tokenType == _TOKEN_TYPE_ERC1155) {
                erc1155Count++;
            }
        }
    }

    function getTokens(address host, uint256 id) 
    external view returns (uint8[] memory tokenTypes, address[] memory tokenAddresses) {

        Token[] memory tokens = _tokens[host][id];

        tokenTypes = new uint8[](tokens.length);
        tokenAddresses = new address[](tokens.length);

        for (uint256 i; i < tokens.length; i++) {
            tokenTypes[i] = tokens[i].tokenType;
            tokenAddresses[i] = tokens[i].tokenAddress;
        }
    }

    function support(address host) external onlyOwner {

        require(!walletFeatureHosted[host], "MagicLampWallet::support: already supported");

        walletFeatureHosts.push(host);
        walletFeatureHosted[host] = true;

        emit MagicLampWalletSupported(host);
    }

    function unsupport(address host) external onlyOwner {

        require(walletFeatureHosted[host], "MagicLampWallet::unsupport: not found");

        for (uint256 i = 0; i < walletFeatureHosts.length; i++) {
            if (walletFeatureHosts[i] == host) {
                walletFeatureHosts[i] = walletFeatureHosts[walletFeatureHosts.length - 1];
                walletFeatureHosts.pop();
                delete walletFeatureHosted[host];
                emit MagicLampWalletUnsupported(host);
                break;
            }
        }
    }

    function isSupported(address host) external view returns(bool) {

        return walletFeatureHosted[host];
    }

    function setMagicLampSwap(address newAddress) external onlyOwner {

        address priviousAddress = magicLampSwap;
        require(priviousAddress != newAddress, "MagicLampWallet::setMagicLampSwap: same address");

        magicLampSwap = newAddress;

        emit MagicLampWalletSwapChanged(priviousAddress, newAddress);
    }

    function lock(address host, uint256 id, uint256 timeInSeconds) external  {

        _onlyWalletOwner(host, id);
        _lockedTimestamps[host][id] = block.timestamp.add(timeInSeconds);

        emit MagicLampWalletLocked(_msgSender(), host, id, block.timestamp, _lockedTimestamps[host][id]);
    }

    function existsERC721ERC1155(address host, uint256 id, address token, uint256 tokenId) public view returns (bool) {

        uint256[] memory ids = _erc721ERC1155TokenIds[host][id][token];

        for (uint256 i = 0; i < ids.length; i++) {
            if (ids[i] == tokenId) {
                return true;
            }
        }

        return false;
    }

    function getETH(address host, uint256 id) 
    public view  returns (uint256 balance) {

        _exists(host, id);
        
        balance = _ethBalances[host][id];
    }

    function depositETH(address host, uint256 id, uint256 amount) external payable {

        _exists(host, id);
        require(amount > 0 && amount == msg.value, "MagicLampWallet::depositETH: invalid amount");
        
        _ethBalances[host][id] = _ethBalances[host][id].add(msg.value);

        emit MagicLampWalletETHDeposited(_msgSender(), host, id, msg.value);
    }

    function withdrawETH(address host, uint256 id, uint256 amount) public payable {

        _onlyWalletOwner(host, id);
        _unlocked(host, id);
        require(amount > 0 && amount <= address(this).balance);
        require(amount <= getETH(host, id));

        address to = IERC721(host).ownerOf(id);
        payable(to).transfer(amount);
        _ethBalances[host][id] = _ethBalances[host][id].sub(amount);

        emit MagicLampWalletETHWithdrawn(_msgSender(), host, id, amount, to);
    }

    function transferETH(address fromHost, uint256 fromId, uint256 amount, address toHost, uint256 toId) public  {

        _onlyWalletOwner(fromHost, fromId);
        _unlocked(fromHost, fromId);
        _exists(toHost, toId);
         require(fromHost != toHost || fromId != toId, "MagicLampWallet::transferETH: same wallet");	

        _ethBalances[fromHost][fromId] = _ethBalances[fromHost][fromId].sub(amount);	
        _ethBalances[toHost][toId] = _ethBalances[toHost][toId].add(amount);

        emit MagicLampWalletETHTransferred(_msgSender(), fromHost, fromId, amount, toHost, toId);
    }

    function getERC20Tokens(address host, uint256 id) 
    public view  returns (address[] memory addresses, uint256[] memory tokenBalances) {

        Token[] memory tokens = _tokens[host][id];
        (, uint256 erc20Count, , ) = getTokensCount(host, id);
        addresses = new address[](erc20Count);
        tokenBalances = new uint256[](erc20Count);
        uint256 j = 0;

        for (uint256 i = 0; i < tokens.length; i++) {
            Token memory token = tokens[i];
            if (token.tokenType == _TOKEN_TYPE_ERC20) {
                addresses[j] = token.tokenAddress;
                tokenBalances[j] = _erc20TokenBalances[host][id][token.tokenAddress];
                j++;
            }
        }
    }

    function getERC721Tokens(address host, uint256 id) 
    public view  returns (address[] memory addresses, uint256[] memory tokenBalances) {

        Token[] memory tokens = _tokens[host][id];
        (,, uint256 erc721Count, ) = getTokensCount(host, id);
        addresses = new address[](erc721Count);
        tokenBalances = new uint256[](erc721Count);
        uint256 j = 0;

        for (uint256 i = 0; i < tokens.length; i++) {
            Token memory token = tokens[i];
            if (token.tokenType == _TOKEN_TYPE_ERC721) {
                addresses[j] = token.tokenAddress;
                tokenBalances[j] = _erc721ERC1155TokenIds[host][id][token.tokenAddress].length;
                j++;
            }
        }
    }

    function getERC721ERC1155IDs(address host, uint256 id, address token) public view  returns (uint256[] memory) {

        return _erc721ERC1155TokenIds[host][id][token];
    }

    function getERC1155Tokens(address host, uint256 id) public view returns (address[] memory addresses) {

        Token[] memory tokens = _tokens[host][id];
        (,,, uint256 erc1155Count) = getTokensCount(host, id);

        addresses = new address[](erc1155Count);
        uint256 j = 0;

        for (uint256 i = 0; i < tokens.length; i++) {
            Token memory token = tokens[i];
            if (token.tokenType == _TOKEN_TYPE_ERC1155) {
                addresses[j] = token.tokenAddress;
                j++;
            }
        }
    }

    function getERC1155TokenBalances(address host, uint256 id, address token, uint256[] memory tokenIds)
    public view returns (uint256[] memory tokenBalances) {

        tokenBalances = new uint256[](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenBalances[i] = _erc1155TokenBalances[host][id][token][tokenIds[i]];
        }
    }

    function depositERC20(address host, uint256 id, address[] memory tokens, uint256[] memory amounts) external {

        _exists(host, id);
        require(tokens.length > 0 && tokens.length == amounts.length, "MagicLampWallet::depositERC20: invalid parameters");

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            uint256 prevBalance = token.balanceOf(address(this));
            token.transferFrom(_msgSender(), address(this), amounts[i]);
            uint256 receivedAmount = token.balanceOf(address(this)).sub(prevBalance);
            _addERC20TokenBalance(host, id, tokens[i], receivedAmount);

            emit MagicLampWalletERC20Deposited(_msgSender(), host, id, tokens[i], receivedAmount);
        }
    }

    function withdrawERC20(address host, uint256 id, address[] memory tokens, uint256[] memory amounts)
    public  {

        _onlyWalletOwner(host, id);
        _unlocked(host, id);
        require(tokens.length > 0 && tokens.length == amounts.length, "MagicLampWallet::withdrawERC20: invalid parameters");

        address to = IERC721(host).ownerOf(id);

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            token.transfer(to, amounts[i]);
            _subERC20TokenBalance(host, id, tokens[i], amounts[i]);

            emit MagicLampWalletERC20Withdrawn(_msgSender(), host, id, tokens[i], amounts[i], to);
        }
    }

    function transferERC20(address fromHost, uint256 fromId, address token, uint256 amount, address toHost, uint256 toId)
    public  {

        _onlyWalletOwner(fromHost, fromId);
        _unlocked(fromHost, fromId);
        _exists(toHost, toId);
        require(fromHost != toHost || fromId != toId, "MagicLampWallet::transferERC20: same wallet");
        
        _subERC20TokenBalance(fromHost, fromId, token, amount);	
        _addERC20TokenBalance(toHost, toId, token, amount);

        emit MagicLampWalletERC20Transferred(_msgSender(), fromHost, fromId, token, amount, toHost, toId);
    }

    function depositERC721(address host, uint256 id, address token, uint256[] memory tokenIds) external  {

        _exists(host, id);

        IERC721 iToken = IERC721(token);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(token != host || tokenIds[i] != id, "MagicLampWallet::depositERC721: self deposit");

            iToken.safeTransferFrom(_msgSender(), address(this), tokenIds[i]);
            _putTokenId(host, id, _TOKEN_TYPE_ERC721, token, tokenIds[i]);

            emit MagicLampWalletERC721Deposited(_msgSender(), host, id, token, tokenIds[i]);
        }
    }

    function withdrawERC721(address host, uint256 id, address token, uint256[] memory tokenIds)
    public {

        _onlyWalletOwner(host, id);
        _unlocked(host, id);
        
        IERC721 iToken = IERC721(token);
        address to = IERC721(host).ownerOf(id);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(iToken.ownerOf(tokenIds[i]) == address(this));
            iToken.safeTransferFrom(address(this), to, tokenIds[i]);
            _popTokenId(host, id, _TOKEN_TYPE_ERC721, token, tokenIds[i]);

            emit MagicLampWalletERC721Withdrawn(_msgSender(), host, id, token, tokenIds[i], to);
        }
    }

    function transferERC721(address fromHost, uint256 fromId, address token, uint256[] memory tokenIds, address toHost, uint256 toId) 
    public {

        _onlyWalletOwner(fromHost, fromId);
        _unlocked(fromHost, fromId);
        _exists(toHost, toId);
        require(fromHost != toHost || fromId != toId, "MagicLampWallet::transferERC721: same wallet");
        
        for (uint256 i = 0; i < tokenIds.length; i++) {	
            _popTokenId(fromHost, fromId, _TOKEN_TYPE_ERC721, token, tokenIds[i]);	
            _putTokenId(toHost, toId, _TOKEN_TYPE_ERC721, token, tokenIds[i]);

            emit MagicLampWalletERC721Transferred(_msgSender(), fromHost, fromId, token, tokenIds[i], toHost, toId);
        }
    }

    function depositERC1155(address host, uint256 id, address token, uint256[] memory tokenIds, uint256[] memory amounts) 
    external {

        _exists(host, id);
        IERC1155 iToken = IERC1155(token);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            iToken.safeTransferFrom(_msgSender(), address(this), tokenIds[i], amounts[i], bytes(""));
            _addERC1155TokenBalance(host, id, token, tokenIds[i], amounts[i]);

            emit MagicLampWalletERC1155Deposited(_msgSender(), host, id, token, tokenIds[i], amounts[i]);
        }
    }

    function withdrawERC1155(address host, uint256 id, address token, uint256[] memory tokenIds, uint256[] memory amounts)
    public {

        _onlyWalletOwner(host, id);
        _unlocked(host, id);
        IERC1155 iToken = IERC1155(token);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            uint256 amount = amounts[i];
            address to = IERC721(host).ownerOf(id);
            iToken.safeTransferFrom(address(this), to, tokenId, amount, bytes(""));
            _subERC1155TokenBalance(host, id, token, tokenId, amount);

            emit MagicLampWalletERC1155Withdrawn(_msgSender(), host, id, token, tokenId, amount, to);
        }
    }

    function transferERC1155(address fromHost, uint256 fromId, address token, uint256[] memory tokenIds, uint256[] memory amounts, address toHost, uint256 toId)
    public {

        _onlyWalletOwner(fromHost, fromId);
        _unlocked(fromHost, fromId); 
        require(fromHost != toHost || fromId != toId, "MagicLampWallet::transferERC1155: same wallet");
        
        for (uint256 i = 0; i < tokenIds.length; i++) {	
            uint256 tokenId = tokenIds[i];	
            uint256 amount = amounts[i];	
            _subERC1155TokenBalance(fromHost, fromId, token, tokenId, amount);	
            _addERC1155TokenBalance(toHost, toId, token, tokenId, amount);

            emit MagicLampWalletERC1155Transferred(_msgSender(), fromHost, fromId, token, tokenId, amount, toHost, toId);	
        }
    }

    function withdrawAll(address host, uint256 id) external {

        uint256 eth = getETH(host, id);
        if (eth > 0) {
            withdrawETH(host, id, eth);
        }

        (address[] memory erc20Addresses, uint256[] memory erc20Balances) = getERC20Tokens(host, id);
        if (erc20Addresses.length > 0) {
            withdrawERC20(host, id, erc20Addresses, erc20Balances);
        }

        (address[] memory erc721Addresses, ) = getERC721Tokens(host, id);
        for (uint256 a = 0; a < erc721Addresses.length; a++) {
            uint256[] memory ids = _erc721ERC1155TokenIds[host][id][erc721Addresses[a]];
            withdrawERC721(host, id, erc721Addresses[a], ids);
        }

        address[] memory erc1155Addresses = getERC1155Tokens(host, id);
        for (uint256 a = 0; a < erc1155Addresses.length; a++) {
            uint256[] memory ids = _erc721ERC1155TokenIds[host][id][erc1155Addresses[a]];
            uint256[] memory tokenBalances = getERC1155TokenBalances(host, id, erc1155Addresses[a], ids);
            withdrawERC1155(host, id, erc1155Addresses[a], ids, tokenBalances);
        }
    }

    function transferAll(address fromHost, uint256 fromId, address toHost, uint256 toId) external {

        {
            uint256 eth = getETH(fromHost, fromId);
            if (eth > 0) {
                transferETH(fromHost, fromId, eth, toHost, toId);
            }
        }

        {
            (address[] memory erc20Addresses, uint256[] memory erc20Balances ) = getERC20Tokens(fromHost, fromId);
            for(uint256 i = 0; i < erc20Addresses.length; i++){
                transferERC20(fromHost, fromId, erc20Addresses[i], erc20Balances[i], toHost, toId);
            }
        }

        {
            (address[] memory erc721Addresses, ) = getERC721Tokens(fromHost, fromId);
            for (uint256 a = 0; a < erc721Addresses.length; a++) {
                uint256[] memory ids = getERC721ERC1155IDs(fromHost, fromId, erc721Addresses[a]);
                transferERC721(fromHost, fromId, erc721Addresses[a], ids, toHost, toId);
            }
        }

        {
            address[] memory erc1155Addresses = getERC1155Tokens(fromHost, fromId);
            for (uint256 a = 0; a < erc1155Addresses.length; a++) {
                uint256[] memory ids = getERC721ERC1155IDs(fromHost, fromId, erc1155Addresses[a]);	
            uint256[] memory tokenBalances = getERC1155TokenBalances(fromHost, fromId, erc1155Addresses[a], ids);	
            transferERC1155(fromHost, fromId, erc1155Addresses[a], ids, tokenBalances, toHost, toId);
            }
        }
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {

        return this.onERC721Received.selector;
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure override returns (bytes4) {

        return 0xf23a6e61;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external pure override returns (bytes4) {

        return 0xbc197c81;
    }
}