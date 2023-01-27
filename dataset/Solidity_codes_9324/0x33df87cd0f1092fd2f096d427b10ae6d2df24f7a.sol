
pragma solidity ^0.5.15;
pragma experimental ABIEncoderV2;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface UniswapPair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
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

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

contract UniHelper{

    using SafeMath for uint256;

    uint256 internal constant ONE = 10**18;

    function _mintLPToken(
        UniswapPair uniswap_pair,
        IERC20 token0,
        IERC20 token1,
        uint256 amount_token1,
        address token1_source
    ) internal {

        (uint256 reserve0, uint256 reserve1, ) = uniswap_pair
            .getReserves();
        uint256 quoted = quote(reserve0, reserve1);

        uint256 amount_token0 = quoted.mul(amount_token1).div(ONE);

        token0.transfer(address(uniswap_pair), amount_token0);
        token1.transfer(address(uniswap_pair), amount_token1);
        UniswapPair(uniswap_pair).mint(address(this));
    }

    function _burnLPToken(UniswapPair uniswap_pair, address destination) internal {

        uniswap_pair.transfer(
            address(uniswap_pair),
            uniswap_pair.balanceOf(address(this))
        );
        UniswapPair(uniswap_pair).burn(destination);
    }

    function quote(uint256 purchaseAmount, uint256 saleAmount)
        internal
        view
        returns (uint256)
    {

        return purchaseAmount.mul(ONE).div(saleAmount);
    }

}

contract YamGoverned {

    event NewGov(address oldGov, address newGov);
    event NewPendingGov(address oldPendingGov, address newPendingGov);

    address public gov;
    address public pendingGov;

    modifier onlyGov {

        require(msg.sender == gov, "!gov");
        _;
    }

    function _setPendingGov(address who)
        public
        onlyGov
    {

        address old = pendingGov;
        pendingGov = who;
        emit NewPendingGov(old, who);
    }

    function _acceptGov()
        public
    {

        require(msg.sender == pendingGov, "!pendingGov");
        address oldgov = gov;
        gov = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldgov, gov);
    }
}

contract YamSubGoverned is YamGoverned {

    event SubGovModified(
        address account,
        bool isSubGov
    );
    mapping(address => bool) public isSubGov;

    modifier onlyGovOrSubGov() {

        require(msg.sender == gov || isSubGov[msg.sender]);
        _;
    }

    function setIsSubGov(address subGov, bool _isSubGov)
        public
        onlyGov
    {

        isSubGov[subGov] = _isSubGov;
        emit SubGovModified(subGov, _isSubGov);
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
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
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library Babylonian {

    function sqrt(uint y) internal pure returns (uint z) {

        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;
    uint private constant Q112 = uint(1) << RESOLUTION;
    uint private constant Q224 = Q112 << RESOLUTION;

    function encode(uint112 x) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(x) << RESOLUTION);
    }

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {

        return uq144x112(uint256(x) << RESOLUTION);
    }

    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {

        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {

        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {

        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    function decode(uq112x112 memory self) internal pure returns (uint112) {

        return uint112(self._x >> RESOLUTION);
    }

    function decode144(uq144x112 memory self) internal pure returns (uint144) {

        return uint144(self._x >> RESOLUTION);
    }

    function reciprocal(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        require(self._x != 0, 'FixedPoint: ZERO_RECIPROCAL');
        return uq112x112(uint224(Q224 / self._x));
    }

    function sqrt(uq112x112 memory self) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x)) << 56));
    }
}

library UniswapV2OracleLibrary {

    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {

        return uint32(block.timestamp % 2 ** 32);
    }

    function currentCumulativePrices(
        address pair,
        bool isToken0
    ) internal view returns (uint priceCumulative, uint32 blockTimestamp) {

        blockTimestamp = currentBlockTimestamp();
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = UniswapPair(pair).getReserves();
        if (isToken0) {
          priceCumulative = UniswapPair(pair).price0CumulativeLast();

          if (blockTimestampLast != blockTimestamp) {
              uint32 timeElapsed = blockTimestamp - blockTimestampLast;
              priceCumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
          }
        } else {
          priceCumulative = UniswapPair(pair).price1CumulativeLast();
          if (blockTimestampLast != blockTimestamp) {
              uint32 timeElapsed = blockTimestamp - blockTimestampLast;
              priceCumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
          }
        }

    }
}


contract TWAPBoundedUSTONKSAPR {

    using SafeMath for uint256;

    uint256 internal constant BASE = 10**18;

    uint256 internal constant ONE = 10**18;

    UniswapPair internal uniswap_pair =
        UniswapPair(0xEdf187890Af846bd59f560827EBD2091C49b75Df);

    IERC20 internal constant USDC =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    IERC20 internal constant USTONKS_APR =
        IERC20(0xEC58d3aefc9AAa2E0036FA65F70d569f49D9d1ED);

    uint32 internal block_timestamp_last;

    uint256 internal price_cumulative_last;

    uint256 internal constant MIN_TWAP_TIME = 60 * 60; // 1 hour

    uint256 internal constant MAX_TWAP_TIME = 120 * 60; // 2 hours

    uint256 internal constant TWAP_BOUNDS = 5 * 10**15;

    function quote(uint256 purchaseAmount, uint256 saleAmount)
        internal
        view
        returns (uint256)
    {

        return purchaseAmount.mul(ONE).div(saleAmount);
    }

    function bounds(uint256 uniswap_quote) internal view returns (uint256) {

        uint256 minimum = uniswap_quote.mul(BASE.sub(TWAP_BOUNDS)).div(BASE);
        return minimum;
    }

    function bounds_max(uint256 uniswap_quote) internal view returns (uint256) {

        uint256 maximum = uniswap_quote.mul(BASE.add(TWAP_BOUNDS)).div(BASE);
        return maximum;
    }


    function withinBounds(uint256 purchaseAmount, uint256 saleAmount)
        internal
        
        returns (bool)
    {

        uint256 uniswap_quote = consult();
        uint256 quoted = quote(purchaseAmount, saleAmount);
        uint256 minimum = bounds(uniswap_quote);
        uint256 maximum = bounds_max(uniswap_quote);

        return quoted > minimum && quoted < maximum;
    }

    function update_twap() public {

        (uint256 sell_token_priceCumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(
                address(uniswap_pair),
                false
            );
        uint32 timeElapsed = blockTimestamp - block_timestamp_last; // overflow is impossible

        require(timeElapsed >= MIN_TWAP_TIME, "OTC: MIN_TWAP_TIME NOT ELAPSED");

        price_cumulative_last = sell_token_priceCumulative;

        block_timestamp_last = blockTimestamp;
    }

    function consult() internal view returns (uint256) {

        (uint256 sell_token_priceCumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(
                address(uniswap_pair),
                false
            );
        uint32 timeElapsed = blockTimestamp - block_timestamp_last; // overflow is impossible

        uint256 priceAverageSell =
            uint256(
                uint224(
                    (sell_token_priceCumulative - price_cumulative_last) /
                        timeElapsed
                )
            );

        uint256 purchasePrice;
        if (priceAverageSell > uint192(-1)) {
            purchasePrice = (priceAverageSell >> 112) * ONE;
        } else {
            purchasePrice = (priceAverageSell * ONE) >> 112;
        }
        return purchasePrice;
    }

    modifier timeBoundsCheck() {

        uint256 elapsed_since_update = block.timestamp - block_timestamp_last;
        require(
            block.timestamp - block_timestamp_last < MAX_TWAP_TIME,
            "Cumulative price snapshot too old"
        );
        require(
            block.timestamp - block_timestamp_last > MIN_TWAP_TIME,
            "Cumulative price snapshot too new"
        );
        _;
    }
}

interface SynthMinter {

    struct Unsigned {
        uint256 rawValue;
    }
    struct PositionData {
        Unsigned tokensOutstanding;
        uint256 withdrawalRequestPassTimestamp;
        Unsigned withdrawalRequestAmount;
        Unsigned rawCollateral;
        uint256 transferPositionRequestPassTimestamp;
    }

    function create(
        Unsigned calldata collateralAmount,
        Unsigned calldata numTokens
    ) external;



    function redeem(Unsigned calldata debt_amount) external returns(Unsigned memory);


    function withdraw(Unsigned calldata collateral_amount) external;


    function positions(address account) external returns (PositionData memory);


    function settleExpired() external returns (Unsigned memory);


    function expire() external;

}

interface VAULT {

    function withdraw(uint256 amount) external;


    function balanceOf(address user) external returns (uint256);

}

interface CURVE_WITHDRAWER {

    function remove_liquidity_one_coin(
        uint256 amount,
        int128 coin,
        uint256 min
    ) external;

}

contract USTONKSAPRFarming is TWAPBoundedUSTONKSAPR, UniHelper, YamSubGoverned {

    enum ACTION {ENTER, EXIT}

    constructor(address gov_) public {
        gov = gov_;
    }

    SynthMinter minter =
        SynthMinter(0x4F1424Cef6AcE40c0ae4fc64d74B734f1eAF153C);

    bool completed = true;

    ACTION action;

    address internal constant RESERVES =
        address(0x97990B693835da58A281636296D2Bf02787DEa17);

    VAULT internal constant YUSD =
        VAULT(0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c);
    CURVE_WITHDRAWER internal constant Y_DEPOSIT =
        CURVE_WITHDRAWER(0xbBC81d23Ea2c3ec7e56D39296F0cbB648873a5d3);
    IERC20 internal constant YCRV =
        IERC20(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);


    function _mint(uint256 collateral_amount, uint256 mint_amount) internal {

        USDC.approve(address(minter), uint256(-1));

        minter.create(
            SynthMinter.Unsigned(collateral_amount),
            SynthMinter.Unsigned(mint_amount)
        );
    }

    function _repayAndWithdraw() internal {

        USTONKS_APR.approve(address(minter), uint256(-1));
        SynthMinter.PositionData memory position =
            minter.positions(address(this));
        uint256 ustonksBalance = USTONKS_APR.balanceOf(address(this));
        if (ustonksBalance >= position.tokensOutstanding.rawValue) {
            minter.redeem(position.tokensOutstanding);
        } else {
            minter.redeem(
                SynthMinter.Unsigned(
                    position.tokensOutstanding.rawValue - ustonksBalance <=
                        5 * 10**6
                        ? position.tokensOutstanding.rawValue - 5 * 10**6
                        : ustonksBalance
                )
            );
        }
    }


    function enter() public timeBoundsCheck {

        require(action == ACTION.ENTER, "Wrong action");
        require(!completed, "Action completed");
        uint256 ustonksReserves;
        uint256 usdcReserves;
        (usdcReserves, ustonksReserves, ) = uniswap_pair.getReserves();
        require(
            withinBounds(usdcReserves, ustonksReserves),
            "Market rate is outside bounds"
        );
        YUSD.withdraw(YUSD.balanceOf(address(this)));
        uint256 ycrvBalance = YCRV.balanceOf(address(this));
        YCRV.approve(address(Y_DEPOSIT), ycrvBalance);
        Y_DEPOSIT.remove_liquidity_one_coin(ycrvBalance, 1, 1);
        uint256 usdcBalance = USDC.balanceOf(address(this));

        uint256 collateral_amount = (usdcBalance * 2) / 3;
        uint256 mint_amount =
            (collateral_amount * ustonksReserves) / usdcReserves / 4;
        _mint(collateral_amount, mint_amount);

        _mintLPToken(uniswap_pair, USDC, USTONKS_APR, mint_amount, RESERVES);

        USDC.transfer(address(RESERVES), USDC.balanceOf(address(this)));
        completed = true;
    }

    function exit() public timeBoundsCheck {

        require(action == ACTION.EXIT);
        require(!completed, "Action completed");
        uint256 ustonksReserves;
        uint256 usdcReserves;
        (usdcReserves, ustonksReserves, ) = uniswap_pair.getReserves();
        require(
            withinBounds(usdcReserves, ustonksReserves),
            "Market rate is outside bounds"
        );

        _burnLPToken(uniswap_pair, address(this));

        _repayAndWithdraw();

        USDC.transfer(RESERVES, USDC.balanceOf(address(this)));
        uint256 ustonksBalance = USTONKS_APR.balanceOf(address(this));
        if (ustonksBalance > 0) {
            USTONKS_APR.transfer(RESERVES, ustonksBalance);
        }
        completed = true;
    }

    function _approveEnter() public onlyGovOrSubGov {

        completed = false;
        action = ACTION.ENTER;
    }

    function _approveExit() public onlyGovOrSubGov {

        completed = false;
        action = ACTION.EXIT;
    }


    function _redeem(uint256 debt_to_pay) public onlyGovOrSubGov {

        minter.redeem(SynthMinter.Unsigned(debt_to_pay));
    }

    function _withdrawCollateral(uint256 amount_to_withdraw)
        public
        onlyGovOrSubGov
    {

        minter.withdraw(SynthMinter.Unsigned(amount_to_withdraw));
    }

    function _settleExpired() public onlyGovOrSubGov {

        minter.settleExpired();
    }

    function masterFallback(address target, bytes memory data)
        public
        onlyGovOrSubGov
    {

        target.call.value(0)(data);
    }

    function _getTokenFromHere(address token) public onlyGovOrSubGov {

        IERC20 t = IERC20(token);
        t.transfer(RESERVES, t.balanceOf(address(this)));
    }
}