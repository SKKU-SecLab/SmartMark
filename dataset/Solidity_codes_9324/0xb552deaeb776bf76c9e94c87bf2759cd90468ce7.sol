



pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}


pragma solidity 0.8.4;



library Roles {

    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

abstract contract SignerRole is Context {
    using Roles for Roles.Role;

    event SignerAdded(address indexed account);
    event SignerRemoved(address indexed account);

    Roles.Role private _signers;

    constructor () {
        _addSigner(_msgSender());
    }

    modifier onlySigner() {
        require(isSigner(_msgSender()), "SignerRole: caller does not have the Signer role");
        _;
    }

    function isSigner(address account) public view returns (bool) {
        return _signers.has(account);
    }

    function addSigner(address account) public onlySigner {
        _addSigner(account);
    }

    function renounceSigner() public {
        _removeSigner(_msgSender());
    }

    function _addSigner(address account) internal {
        _signers.add(account);
        emit SignerAdded(account);
    }

    function _removeSigner(address account) internal {
        _signers.remove(account);
        emit SignerRemoved(account);
    }
}


interface IUniswapV2Router {

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);


    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);


    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);


    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);


    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);


    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline) external payable returns (uint[] memory amounts);

}

contract TopBridge is Ownable, SignerRole {

    using SafeMath for uint256;

    address stableTokenAddress;
    uint8 public decimals;
    address weth;
    address routerAddress;
    uint256 fee;
    uint256 MAX_UINT256 = ~uint256(0);

    mapping(bytes32 => bool) pays;


    constructor(address _stableAddr, address _weth, address _router, uint256 _fee) {
        stableTokenAddress = _stableAddr;
        decimals = IERC20Metadata(_stableAddr).decimals();
        weth = _weth;
        routerAddress = _router;
        IERC20(_stableAddr).approve(_router, MAX_UINT256);
        fee = _fee;
    }

    function setFee(uint256 _fee) external onlyOwner {

        fee = _fee;
    }

    function setRouterAddress(address routerAddr) external onlyOwner {

        routerAddress = routerAddr;
    }

    function setStableToken(address tokenAddr) external onlyOwner {

        stableTokenAddress = tokenAddr;
        decimals = IERC20Metadata(tokenAddr).decimals();
    }

    event REQ(address indexed _user, address indexed _sourceToken, address indexed _destToken, uint _amount, uint _toChain);
    event PAY(address indexed _user, address indexed _destToken, uint _amount, bytes32 _txhash, uint _fromChain);

    function isContract(address addr) internal view returns (bool) {

        uint size;
        assembly {size := extcodesize(addr)}
        return size > 0;
    }

    function swap(address[] calldata pairs, address destTokenAddr, uint value, uint toChain) payable external {

        require(isContract(msg.sender) == false, "Anti Bot");
        uint len = pairs.length;
        address sourceTokenAddr = pairs[0];
        require(pairs[len - 1] == stableTokenAddress, "No supported Path");
        IERC20 sourceToken = IERC20(sourceTokenAddr);
        uint256 amount;
        if (msg.value > 0 && pairs[0] == weth && pairs[len - 1] == stableTokenAddress) {
            amount = msg.value;
            uint[] memory amounts = IUniswapV2Router(routerAddress).swapExactETHForTokens{value : amount}(0, pairs, address(this), block.timestamp.add(15 minutes));
            emit REQ(msg.sender, weth, destTokenAddr, amounts[amounts.length - 1], toChain);
        } else {
            uint256 obalance = sourceToken.balanceOf(address(this));
            if (sourceToken.transferFrom(msg.sender, address(this), value)) {
                amount = sourceToken.balanceOf(address(this)).sub(obalance);
            }
            if (sourceTokenAddr == stableTokenAddress) {
                emit REQ(msg.sender, sourceTokenAddr, destTokenAddr, amount, toChain);
            } else {
                sourceToken.approve(routerAddress, amount);
                uint[] memory amounts = IUniswapV2Router(routerAddress).swapExactTokensForTokens(amount, 0, pairs, address(this), block.timestamp.add(15 minutes));
                emit REQ(msg.sender, sourceTokenAddr, destTokenAddr, amounts[1], toChain);
            }
        }
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32)
    {

        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
    }

    function withdraw(uint256 amount) external onlyOwner {

        IERC20(stableTokenAddress).transfer(_msgSender(), amount);
    }

    function sendToken(IERC20 token, address to, uint256 amount) external onlyOwner {

        token.transfer(to, amount);
    }

    function sendEther(address payable to, uint256 amount) external onlyOwner {

        to.transfer(amount);
    }

    struct SigData {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }


    function _payToAddress(address _user, uint256 amount, address[] calldata pairs) internal returns (uint256){

        uint256 last = pairs.length - 1;
        if (pairs[last] != stableTokenAddress) {
            if (pairs[last] != weth) {
                return IUniswapV2Router(routerAddress).swapExactTokensForTokens(amount, 0, pairs, _user, block.timestamp.add(15 minutes))[last];
            } else {
                return IUniswapV2Router(routerAddress).swapExactTokensForETH(amount, 0, pairs, _user, block.timestamp.add(15 minutes))[last];
            }
        }
        if (IERC20(pairs[last]).transfer(_user, amount)) {
            return amount;
        }
        return 0;
    }

    function payWithPermit(
        address _user,
        address _sourceToken,
        address[] calldata pairs,
        uint _amount,
        uint8 _decimals,
        uint256 _fromChain,
        uint256 _toChain,
        bytes32 _txhash,
        SigData calldata sig)
    external {

        require(block.chainid == _toChain, "ChainId");
        require(isContract(msg.sender) != true, "Anti Bot");
        require(pairs[0] == stableTokenAddress, "unsupported pair");
        address _destToken = pairs[pairs.length - 1];
        bytes32 hash = keccak256(abi.encodePacked(this, _user, _sourceToken, _destToken, _amount, _decimals, _fromChain, _toChain, _txhash));
        require(pays[hash] != true, "Already Executed");
        require(isSigner(ecrecover(toEthSignedMessageHash(hash), sig.v, sig.r, sig.s)), "Incorrect Signer");
        uint256 _fee = 10 ** decimals;
        if (msg.sender != _user) {
            require(isSigner(msg.sender), "Anti Bot");
            _fee += fee;
        }
        uint256 toSwapAmount = _amount.mul(10 ** decimals).div(10 ** _decimals);
        toSwapAmount = toSwapAmount.sub(_fee);
        pays[hash] = true;
        uint256 amount = _payToAddress(_user, toSwapAmount, pairs);
        require(amount > 0, "pay error");
        emit PAY(_user, _destToken, amount, _txhash, _fromChain);
    }

    function getChainId() view public returns (uint256) {

        return block.chainid;
    }

    receive() external payable {}

    fallback() external payable {}

}

library SafeMath {


    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}