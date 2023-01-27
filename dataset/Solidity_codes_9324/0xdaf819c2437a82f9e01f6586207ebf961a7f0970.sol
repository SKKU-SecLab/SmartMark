
pragma solidity ^0.5.16;

contract FeeTo {

    address public owner;
    address public feeRecipient;

    struct TokenAllowState {
        bool    allowed;
        uint128 disallowCount;
    }
    mapping(address => TokenAllowState) public tokenAllowStates;

    struct PairAllowState {
        uint128 token0DisallowCount;
        uint128 token1DisallowCount;
    }
    mapping(address => PairAllowState) public pairAllowStates;

    constructor(address owner_) public {
        owner = owner_;
    }

    function setOwner(address owner_) public {

        require(msg.sender == owner, 'FeeTo::setOwner: not allowed');
        owner = owner_;
    }

    function setFeeRecipient(address feeRecipient_) public {

        require(msg.sender == owner, 'FeeTo::setFeeRecipient: not allowed');
        feeRecipient = feeRecipient_;
    }

    function updateTokenAllowState(address token, bool allowed) public {

        require(msg.sender == owner, 'FeeTo::updateTokenAllowState: not allowed');
        TokenAllowState storage tokenAllowState = tokenAllowStates[token];
        if (allowed != tokenAllowState.allowed) {
            tokenAllowState.allowed = allowed;
            if (tokenAllowState.disallowCount == 0) {
                tokenAllowState.disallowCount = 1;
            } else if (allowed == false) {
                tokenAllowState.disallowCount += 1;
            }
        }
    }

    function updateTokenAllowStates(address[] memory tokens, bool allowed) public {

        for (uint i; i < tokens.length; i++) {
            updateTokenAllowState(tokens[i], allowed);
        }
    }

    function renounce(address pair) public returns (uint value) {

        PairAllowState storage pairAllowState = pairAllowStates[pair];
        TokenAllowState storage token0AllowState = tokenAllowStates[IUniswapV2Pair(pair).token0()];
        TokenAllowState storage token1AllowState = tokenAllowStates[IUniswapV2Pair(pair).token1()];

        if (
            token0AllowState.allowed == false ||
            token1AllowState.allowed == false ||
            token0AllowState.disallowCount > pairAllowState.token0DisallowCount ||
            token1AllowState.disallowCount > pairAllowState.token1DisallowCount
        ) {
            value = IUniswapV2Pair(pair).balanceOf(address(this));
            if (value > 0) {
                assert(IUniswapV2Pair(pair).transfer(pair, value));
                IUniswapV2Pair(pair).burn(pair);
            }

            if (token0AllowState.allowed) {
                pairAllowState.token0DisallowCount = token0AllowState.disallowCount;
            }
            if (token1AllowState.allowed) {
                pairAllowState.token1DisallowCount = token1AllowState.disallowCount;
            }
        }
    }

    function claim(address pair) public returns (uint value) {

        PairAllowState storage pairAllowState = pairAllowStates[pair];
        TokenAllowState storage token0AllowState = tokenAllowStates[IUniswapV2Pair(pair).token0()];
        TokenAllowState storage token1AllowState = tokenAllowStates[IUniswapV2Pair(pair).token1()];

        if (
            token0AllowState.allowed &&
            token1AllowState.allowed &&
            token0AllowState.disallowCount == pairAllowState.token0DisallowCount &&
            token1AllowState.disallowCount == pairAllowState.token1DisallowCount &&
            feeRecipient != address(0)
        ) {
            value = IUniswapV2Pair(pair).balanceOf(address(this));
            if (value > 0) {
                assert(IUniswapV2Pair(pair).transfer(feeRecipient, value));
            }
        }
    }
}

interface IUniswapV2Pair {

    function token0() external view returns (address);

    function token1() external view returns (address);

    function balanceOf(address owner) external view returns (uint);

    function transfer(address to, uint value) external returns (bool);

    function burn(address to) external returns (uint amount0, uint amount1);

}