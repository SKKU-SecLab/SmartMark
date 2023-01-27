
pragma solidity ^0.5.0;

contract UniswapExchangeInterface {

    function tokenAddress() external view returns (address token);

    function factoryAddress() external view returns (address factory);

    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);

    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);

    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);

    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);

    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);

    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);

    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);

    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);

    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);

    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);

    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);

    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);

    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);

    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);

    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);

    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);

    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);

    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function setup(address token_addr) external;

}

contract ERC20Interface {

    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (string memory);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract RebalanceUniswap is Ownable {


    uint256 UINT256_MAX = 2**256 - 1;

    constructor(address[] memory tokenAddresses, address[] memory exchangeAddresses, uint numberOfTokens) public {
        for (uint i = 0; i<numberOfTokens; i++) {
            approveExchange(tokenAddresses[i], exchangeAddresses[i]);
        }
    }

    function approveExchange(address tokenAddress, address exchangeAddress) public onlyOwner {

        ERC20Interface token = ERC20Interface(tokenAddress);
        token.approve(exchangeAddress, UINT256_MAX);
    }

    function getAllowance(address tokenAddress, address exchangeAddress) public view onlyOwner {

        ERC20Interface token = ERC20Interface(tokenAddress);
        token.allowance(address(this), exchangeAddress);
    }

    function swap(
        address[] memory e2tTo, uint[] memory e2tAmount, uint e2tLen,
        address[] memory t2tFromToken, address[] memory t2tFromExchange, uint[] memory t2tAmount, address[] memory t2tToToken, uint t2tLen,
        address[] memory t2eFromToken, address[] memory t2eFromExchange, uint[] memory t2eAmount, uint t2eLen
    ) public payable {

        UniswapExchangeInterface fx;
        ERC20Interface token;
        for (uint i = 0; i<e2tLen; i++) {
            fx = UniswapExchangeInterface(e2tTo[i]);
            fx.ethToTokenTransferInput.value(e2tAmount[i])(1, 1739591241, msg.sender);
        }

        for (uint i = 0; i<t2tLen; i++) {
            token = ERC20Interface(t2tFromToken[i]);
            token.transferFrom(msg.sender, address(this), t2tAmount[i]);
            fx = UniswapExchangeInterface(t2tFromExchange[i]);
            fx.tokenToTokenTransferInput(t2tAmount[i], 1, 1, 1739591241, msg.sender, t2tToToken[i]);
        }

        for (uint i = 0; i<t2eLen; i++) {
            token = ERC20Interface(t2eFromToken[i]);
            token.transferFrom(msg.sender, address(this), t2eAmount[i]);
            fx = UniswapExchangeInterface(t2eFromExchange[i]);
            fx.tokenToEthTransferInput(t2eAmount[i], 1, 1739591241, msg.sender);
        }
    }
}