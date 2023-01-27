

pragma solidity ^0.8.1;
pragma experimental ABIEncoderV2;

interface IKeep3rV1Quote {

    struct LiquidityParams {
        uint sReserveA;
        uint sReserveB;
        uint uReserveA;
        uint uReserveB;
        uint sLiquidity;
        uint uLiquidity;
    }
    
    struct QuoteParams {
        uint quoteOut;
        uint amountOut;
        uint currentOut;
        uint sTWAP;
        uint uTWAP;
        uint sCUR;
        uint uCUR;
    }
    
    function assetToUsd(address tokenIn, uint amountIn, uint granularity) external returns (QuoteParams memory q, LiquidityParams memory l);

    function assetToEth(address tokenIn, uint amountIn, uint granularity) external view returns (QuoteParams memory q, LiquidityParams memory l);

    function ethToUsd(uint amountIn, uint granularity) external view returns (QuoteParams memory q, LiquidityParams memory l);

    function pairFor(address tokenA, address tokenB) external pure returns (address sPair, address uPair);

    function sPairFor(address tokenA, address tokenB) external pure returns (address sPair);

    function uPairFor(address tokenA, address tokenB) external pure returns (address uPair);

    function getLiquidity(address tokenA, address tokenB) external view returns (LiquidityParams memory l);

    function assetToAsset(address tokenIn, uint amountIn, address tokenOut, uint granularity) external view returns (QuoteParams memory q, LiquidityParams memory l);

}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

}
library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {

        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Synth {

    using SafeERC20 for IERC20;
    
    address public immutable exchange;
    address public immutable token;

    string public name;

    string public symbol;

    uint8 public decimals;

    uint public totalSupply = 0;

    mapping(address => mapping (address => uint)) internal allowances;
    mapping(address => uint) internal balances;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint chainId,address verifyingContract)");
    bytes32 public immutable DOMAINSEPARATOR;

    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint value,uint nonce,uint deadline)");

    mapping (address => uint) public nonces;

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    event Transfer(address indexed from, address indexed to, uint amount);
    
    event Approval(address indexed owner, address indexed spender, uint amount);
    
    constructor (address _token) {
        token = _token;
        name = string(abi.encodePacked("Synthetic", IERC20(_token).name()));
        symbol = string(abi.encodePacked("s", IERC20(_token).symbol()));
        decimals = IERC20(_token).decimals();
        
        exchange = msg.sender;
        DOMAINSEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), _getChainId(), address(this)));
    }
    
    function mint(address dst, uint amount) external {

        require(msg.sender == exchange);
        totalSupply += amount;
        balances[dst] += amount;
        emit Transfer(address(0), dst, amount);
    }
    
    function burn(address dst, uint amount) external {

        require(msg.sender == exchange);
        totalSupply -= amount;
        balances[dst] -= amount;
        emit Transfer(dst, address(0), amount);
    }

    function allowance(address account, address spender) external view returns (uint) {

        return allowances[account][spender];
    }

    function approve(address spender, uint amount) external returns (bool) {

        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function permit(address owner, address spender, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {

        bytes32 structHash = keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, nonces[owner]++, deadline));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAINSEPARATOR, structHash));
        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "permit: signature");
        require(signatory == owner, "permit: unauthorized");
        require(block.timestamp <= deadline, "permit: expired");

        allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) external view returns (uint) {

        return balances[account];
    }

    function transfer(address dst, uint amount) external returns (bool) {

        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    function transferFrom(address src, address dst, uint amount) external returns (bool) {

        address spender = msg.sender;
        uint spenderAllowance = allowances[src][spender];

        if (spender != src && spenderAllowance != type(uint).max) {
            uint newAllowance = spenderAllowance - amount;
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function _transferTokens(address src, address dst, uint amount) internal {

        balances[src] -= amount;
        balances[dst] += amount;
        
        emit Transfer(src, dst, amount);
    }

    function _getChainId() internal view returns (uint) {

        uint chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}

contract SynthetixExchange  {

    
    address public governance;
    address public pendingGovernance;
    
    mapping(address => address) synths;
    
    IKeep3rV1Quote public constant exchange = IKeep3rV1Quote(0xAa1D14BE4b3Fa42CbBF3C3f61c6F2c57fAF559DF);
    
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    
    constructor() {
        governance = msg.sender;
    }
    
    function setGovernance(address _gov) external {

        require(msg.sender == governance);
        pendingGovernance = _gov;
    } 
    
    function acceptGovernance() external {

        require(msg.sender == pendingGovernance);
        governance = pendingGovernance;
    }
    
    function deploySynth(address token) external {

        require(msg.sender == governance);
        require(synths[token] == address(0));
        synths[token] = address(new Synth(token));
    }
    
    function mint(address token, address recipient, uint amount) external {

        require(msg.sender == governance);
        Synth(synths[token]).mint(recipient, amount);
    }
    
    function swap(address tokenIn, uint amountIn, address tokenOut, address recipient) external returns (uint) {

        (IKeep3rV1Quote.QuoteParams memory q,) = exchange.assetToAsset(tokenIn, amountIn, tokenOut, 2);
        Synth(synths[tokenIn]).burn(msg.sender, amountIn);
        Synth(synths[tokenOut]).mint(recipient, q.quoteOut);
        emit Swap(msg.sender, amountIn, 0, 0, q.quoteOut, recipient);
        return q.quoteOut;
    }
}