
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

abstract contract Adminable is Context {
    address private _admin;

    event AdminshipTransferred(
        address indexed previousAdmin,
        address indexed newAdmin
    );

    constructor() {
        address msgSender = _msgSender();
        _admin = msgSender;
        emit AdminshipTransferred(address(0), msgSender);
    }

    function admin() public view virtual returns (address) {
        return _admin;
    }

    modifier onlyAdmin() {
        require(admin() == _msgSender(), "Adminable: caller is not the admin");
        _;
    }

    function _transferAdminship(address newAdmin) internal {
        require(
            newAdmin != address(0),
            "Adminable: new admin is the zero address"
        );
        emit AdminshipTransferred(_admin, newAdmin);
        _admin = newAdmin;
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
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

interface IERC20Short {

    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function mint(address to, uint256 amount) external;


    function burn(uint256 amount) external;

}// MIT
pragma solidity ^0.8.0;


abstract contract NetworksPreset {
    using SafeMath for uint256;

    uint256 public networkThis;
    uint256 public networksTotal;

    struct NetworkInfo {
        bool enabled;
        string description;
    }
    mapping(uint256 => NetworkInfo) public networkInfo;

    function isNetworkEnabled(uint256 netId) public view returns (bool) {
        return networkInfo[netId].enabled;
    }

    function _addNetwork(string memory description) internal {
        networkInfo[networksTotal].enabled = false;
        networkInfo[networksTotal].description = description;
        networksTotal = networksTotal.add(1);
    }

    function _setNetworkStatus(uint256 netId, bool status) internal {
        networkInfo[netId].enabled = status;
    }
}// MIT
pragma solidity ^0.8.0;


abstract contract TokensPreset {
    using SafeMath for uint256;

    uint256 public tokensTotal;

    struct TokenInfo {
        bool enabled;
        address token;
        string description;
        uint256 received;
        uint256 sent;
    }
    mapping(address => TokenInfo) public tokenInfo;
    mapping(uint256 => address) public tokenById;

    function isTokenEnabled(address token) public view returns (bool) {
        return tokenInfo[token].enabled;
    }

    function tokensUnaccounted(address token) public view returns (uint256) {
        uint256 balance = IERC20Short(token).balanceOf(address(this));
        uint256 received = tokenInfo[token].received;
        uint256 sent = tokenInfo[token].sent;
        return balance.sub(received.sub(sent));
    }

    function tokenBalance(address token) public view returns (uint256) {
        return IERC20Short(token).balanceOf(address(this));
    }

    function _addToken(address token, string memory description) internal {
        tokenInfo[token].enabled = false;
        tokenInfo[token].token = token;
        tokenInfo[token].description = description;
        tokenById[tokensTotal] = token;
        tokensTotal = tokensTotal.add(1);
    }

    function _setTokenStatus(address token, bool status) internal {
        tokenInfo[token].enabled = status;
    }
}// MIT
pragma solidity ^0.8.0;


contract CosmoFundErc20CrossChainSwap is
    Ownable,
    Adminable,
    Pausable,
    NetworksPreset,
    TokensPreset
{

    using SafeMath for uint256;
    bool public mintAndBurn;

    struct SwapInfo {
        bool enabled;
        uint256 received;
        uint256 sent;
    }
    mapping(uint256 => mapping(address => SwapInfo)) public swapInfo;

    event Swap(
        uint256 indexed netId,
        address indexed token,
        address indexed to,
        uint256 amount
    );
    event Withdrawn(
        uint256 indexed netId,
        address indexed token,
        address indexed to,
        uint256 amount
    );

    constructor(uint256 _networkThis, bool _mintAndBurn) {
        setup();
        networkThis = _networkThis;
        mintAndBurn = _mintAndBurn;
    }

    function setup() private {

        _addNetwork("Ethereum Mainnet");
        _addNetwork("Binance Smart Chain Mainnet");

        _addToken(
            0x27cd7375478F189bdcF55616b088BE03d9c4339c, // Ethereum Mainnet
            "Cosmo Token (COSMO)"
        );
        _addToken(
            0xB9FDc13F7f747bAEdCc356e9Da13Ab883fFa719B, // Ethereum Mainnet
            "CosmoMasks Power (CMP)"
        );
    }

    function swap(
        uint256 netId,
        address token,
        uint256 amount
    ) public whenNotPaused {

        swapCheckStatus(netId, token);

        address to = _msgSender();
        IERC20Short(token).transferFrom(to, address(this), amount);

        tokenInfo[token].received = tokenInfo[token].received.add(amount);
        swapInfo[netId][token].received = swapInfo[netId][token].received.add(
            amount
        );

        if (mintAndBurn) {
            IERC20Short(token).burn(amount);
        }

        emit Swap(netId, token, to, amount);
    }

    function swapFrom(
        uint256 netId,
        address token,
        address from,
        uint256 amount
    ) public whenNotPaused {

        swapCheckStatus(netId, token);

        address to = from;
        IERC20Short(token).transferFrom(to, address(this), amount);

        tokenInfo[token].received = tokenInfo[token].received.add(amount);
        swapInfo[netId][token].received = swapInfo[netId][token].received.add(
            amount
        );

        if (mintAndBurn) {
            IERC20Short(token).burn(amount);
        }

        emit Swap(netId, token, to, amount);
    }

    function swapWithPermit(
        uint256 netId,
        address token,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {

        swapCheckStatus(netId, token);

        address to = _msgSender();
        IERC20Short(token).permit(to, address(this), amount, deadline, v, r, s);
        IERC20Short(token).transferFrom(to, address(this), amount);

        tokenInfo[token].received = tokenInfo[token].received.add(amount);
        swapInfo[netId][token].received = swapInfo[netId][token].received.add(
            amount
        );

        if (mintAndBurn) {
            IERC20Short(token).burn(amount);
        }

        emit Swap(netId, token, to, amount);
    }

    function withdraw(
        uint256 netId,
        address token,
        address to,
        uint256 amount
    ) public onlyAdmin {

        if (mintAndBurn) {
            IERC20Short(token).mint(address(this), amount);
        }
        IERC20Short(token).transfer(to, amount);

        tokenInfo[token].sent = tokenInfo[token].sent.add(amount);
        swapInfo[netId][token].sent = swapInfo[netId][token].sent.add(amount);

        emit Withdrawn(netId, token, to, amount);
    }

    function addNetwork(string memory description) public onlyOwner {

        _addNetwork(description);
    }

    function setNetworkStatus(uint256 netId, bool status) public onlyOwner {

        _setNetworkStatus(netId, status);
    }

    function addToken(address token, string memory description)
        public
        onlyOwner
    {

        _addToken(token, description);
    }

    function setTokenStatus(address token, bool status) public onlyOwner {

        _setTokenStatus(token, status);
    }

    function setSwapStatus(
        uint256 netId,
        address token,
        bool status
    ) public onlyOwner returns (bool) {

        return swapInfo[netId][token].enabled = status;
    }

    function isSwapEnabled(uint256 netId, address token)
        public
        view
        returns (bool)
    {

        return swapInfo[netId][token].enabled;
    }

    function swapStatus(uint256 netId, address token)
        public
        view
        returns (bool)
    {

        if (paused()) return false;
        if (!isNetworkEnabled(netId)) return false;
        if (!isTokenEnabled(token)) return false;
        if (!isSwapEnabled(netId, token)) return false;
        return true;
    }

    function swapCheckStatus(uint256 netId, address token)
        public
        view
        returns (bool)
    {

        require(
            netId != networkThis,
            "Swap inside the same network is impossible"
        );
        require(
            isNetworkEnabled(netId),
            "Swap is not enabled for this network"
        );
        require(isTokenEnabled(token), "Swap is not enabled for this token");
        require(
            isSwapEnabled(netId, token),
            "Swap of this token for this network not enabled"
        );
        return true;
    }

    function pause() public onlyOwner {

        _pause();
    }

    function unpause() public onlyOwner {

        _unpause();
    }

    function withdrawUnaccountedTokens(address token) public onlyOwner {

        uint256 unaccounted;
        if (mintAndBurn) unaccounted = tokenBalance(token);
        else unaccounted = tokensUnaccounted(token);
        IERC20Short(token).transfer(_msgSender(), unaccounted);
    }

    function transferAdminship(address newAdmin) public virtual onlyOwner {

        _transferAdminship(newAdmin);
    }
}