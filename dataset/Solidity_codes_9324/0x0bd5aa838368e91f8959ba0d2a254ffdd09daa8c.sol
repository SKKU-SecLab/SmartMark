

pragma solidity >=0.7.2;
pragma experimental ABIEncoderV2;


interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}

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

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
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

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

enum OptionType {Invalid, Put, Call}

enum PurchaseMethod {Invalid, Contract, ZeroEx}

struct OptionTerms {
    address underlying;
    address strikeAsset;
    address collateralAsset;
    uint256 expiry;
    uint256 strikePrice;
    OptionType optionType;
    address paymentToken;
}

interface IProtocolAdapter {

    event Purchased(
        address indexed caller,
        string indexed protocolName,
        address indexed underlying,
        uint256 amount,
        uint256 optionID
    );

    event Exercised(
        address indexed caller,
        address indexed options,
        uint256 indexed optionID,
        uint256 amount,
        uint256 exerciseProfit
    );

    function protocolName() external pure returns (string memory);


    function nonFungible() external pure returns (bool);


    function purchaseMethod() external pure returns (PurchaseMethod);


    function optionsExist(OptionTerms calldata optionTerms)
        external
        view
        returns (bool);


    function getOptionsAddress(OptionTerms calldata optionTerms)
        external
        view
        returns (address);


    function premium(OptionTerms calldata optionTerms, uint256 purchaseAmount)
        external
        view
        returns (uint256 cost);


    function exerciseProfit(
        address options,
        uint256 optionID,
        uint256 amount
    ) external view returns (uint256 profit);


    function canExercise(
        address options,
        uint256 optionID,
        uint256 amount
    ) external view returns (bool);


    function purchase(
        OptionTerms calldata optionTerms,
        uint256 amount,
        uint256 maxCost
    ) external payable returns (uint256 optionID);


    function exercise(
        address options,
        uint256 optionID,
        uint256 amount,
        address recipient
    ) external payable;


    function createShort(OptionTerms calldata optionTerms, uint256 amount)
        external
        returns (uint256);


    function closeShort() external returns (uint256);

}

enum HegicOptionType {Invalid, Put, Call}

enum State {Inactive, Active, Exercised, Expired}

interface IHegicOptions {

    event Create(
        uint256 indexed id,
        address indexed account,
        uint256 settlementFee,
        uint256 totalFee
    );

    event Exercise(uint256 indexed id, uint256 profit);
    event Expire(uint256 indexed id, uint256 premium);

    function options(uint256)
        external
        view
        returns (
            State state,
            address payable holder,
            uint256 strike,
            uint256 amount,
            uint256 lockedAmount,
            uint256 premium,
            uint256 expiration,
            HegicOptionType optionType
        );


    function create(
        uint256 period,
        uint256 amount,
        uint256 strike,
        HegicOptionType optionType
    ) external payable returns (uint256 optionID);


    function exercise(uint256 optionID) external;


    function priceProvider() external view returns (address);

}

interface IHegicETHOptions is IHegicOptions {

    function fees(
        uint256 period,
        uint256 amount,
        uint256 strike,
        HegicOptionType optionType
    )
        external
        view
        returns (
            uint256 total,
            uint256 settlementFee,
            uint256 strikeFee,
            uint256 periodFee
        );

}

interface IHegicBTCOptions is IHegicOptions {

    function fees(
        uint256 period,
        uint256 amount,
        uint256 strike,
        HegicOptionType optionType
    )
        external
        view
        returns (
            uint256 total,
            uint256 totalETH,
            uint256 settlementFee,
            uint256 strikeFee,
            uint256 periodFee
        );

}

interface IHegicRewards {

  function hegic() external view returns (IERC20);

  function hegicOptions() external view returns (IHegicOptions);

  function rewardsRate() external view returns (uint256);

  function rewardedOptions(uint optionId) external view returns(bool);

  function getReward(uint optionId) external;

}

interface ISwapPair {

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

}

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256) external;


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}

contract HegicAdapter is IProtocolAdapter {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string private constant _name = "HEGIC";
    bool private constant _nonFungible = true;
    address public immutable ethAddress;
    address public constant wethAddress =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public immutable wbtcAddress;
    IHegicETHOptions public immutable ethOptions;
    IHegicBTCOptions public immutable wbtcOptions;
    ISwapPair public immutable ethWbtcPair;

    constructor(
        address _ethOptions,
        address _wbtcOptions,
        address _ethAddress,
        address _wbtcAddress,
        address _ethWbtcPair
    ) {
        ethOptions = IHegicETHOptions(_ethOptions);
        wbtcOptions = IHegicBTCOptions(_wbtcOptions);
        ethAddress = _ethAddress;
        wbtcAddress = _wbtcAddress;
        ethWbtcPair = ISwapPair(_ethWbtcPair);
    }

    receive() external payable {}

    function protocolName() public pure override returns (string memory) {

        return _name;
    }

    function nonFungible() external pure override returns (bool) {

        return _nonFungible;
    }

    function purchaseMethod() external pure override returns (PurchaseMethod) {

        return PurchaseMethod.Contract;
    }

    function optionsExist(OptionTerms calldata optionTerms)
        external
        view
        override
        returns (bool)
    {

        return
            optionTerms.underlying == ethAddress ||
            optionTerms.underlying == wbtcAddress;
    }

    function getOptionsAddress(OptionTerms calldata optionTerms)
        external
        view
        override
        returns (address)
    {

        if (optionTerms.underlying == ethAddress) {
            return address(ethOptions);
        } else if (optionTerms.underlying == wbtcAddress) {
            return address(wbtcOptions);
        }
        require(false, "No options found");
    }

    function premium(OptionTerms memory optionTerms, uint256 purchaseAmount)
        public
        view
        override
        returns (uint256 cost)
    {

        require(
            block.timestamp < optionTerms.expiry,
            "Cannot purchase after expiry"
        );

        uint256 period = optionTerms.expiry.sub(block.timestamp);
        uint256 scaledStrikePrice =
            scaleDownStrikePrice(optionTerms.strikePrice);

        if (optionTerms.underlying == ethAddress) {
            require(
                optionTerms.underlying == optionTerms.paymentToken,
                "!invalid paymentToken"
            );
            (cost, , , ) = ethOptions.fees(
                period,
                purchaseAmount,
                scaledStrikePrice,
                HegicOptionType(uint8(optionTerms.optionType))
            );
        } else if (optionTerms.underlying == wbtcAddress) {
            uint256 costWBTC;
            (costWBTC, cost, , , ) = wbtcOptions.fees(
                period,
                purchaseAmount,
                scaledStrikePrice,
                HegicOptionType(uint8(optionTerms.optionType))
            );
            if (optionTerms.paymentToken == wbtcAddress) {
                cost = costWBTC;
            }
        } else {
            revert("No matching underlying");
        }
    }

    function exerciseProfit(
        address optionsAddress,
        uint256 optionID,
        uint256
    ) public view override returns (uint256 profit) {

        require(
            optionsAddress == address(ethOptions) ||
                optionsAddress == address(wbtcOptions),
            "optionsAddress must match either ETH or WBTC options"
        );
        IHegicOptions options = IHegicOptions(optionsAddress);

        AggregatorV3Interface priceProvider =
            AggregatorV3Interface(options.priceProvider());
        (, int256 latestPrice, , , ) = priceProvider.latestRoundData();
        uint256 currentPrice = uint256(latestPrice);

        (
            ,
            ,
            uint256 strike,
            uint256 amount,
            uint256 lockedAmount,
            ,
            ,
            HegicOptionType optionType
        ) = options.options(optionID);

        if (optionType == HegicOptionType.Call) {
            if (currentPrice >= strike) {
                profit = currentPrice.sub(strike).mul(amount).div(currentPrice);
            } else {
                profit = 0;
            }
        } else {
            if (currentPrice <= strike) {
                profit = strike.sub(currentPrice).mul(amount).div(currentPrice);
            } else {
                profit = 0;
            }
        }
        if (profit > lockedAmount) profit = lockedAmount;
    }

    function canExercise(
        address options,
        uint256 optionID,
        uint256 amount
    ) public view override returns (bool) {

        bool matchOptionsAddress =
            options == address(ethOptions) || options == address(wbtcOptions);

        (State state, , , , , , uint256 expiration, ) =
            IHegicOptions(options).options(optionID);
        amount = 0;

        uint256 profit = exerciseProfit(options, optionID, amount);

        return
            matchOptionsAddress &&
            expiration >= block.timestamp &&
            state == State.Active &&
            profit > 0;
    }

    function purchase(
        OptionTerms calldata optionTerms,
        uint256 amount,
        uint256 maxCost
    ) external payable override returns (uint256 optionID) {

        require(
            block.timestamp < optionTerms.expiry,
            "Cannot purchase after expiry"
        );

        uint256 scaledStrikePrice =
            scaleDownStrikePrice(optionTerms.strikePrice);
        uint256 period = optionTerms.expiry.sub(block.timestamp);
        IHegicOptions options = getHegicOptions(optionTerms.underlying);

        if (msg.value == 0) {
            OptionTerms memory optionTermsWithETH = optionTerms;
            optionTermsWithETH.paymentToken = ethAddress;
            uint256 cost = premium(optionTermsWithETH, amount);

            require(
                optionTerms.paymentToken == wbtcAddress,
                "Invalid paymentToken or msg.value"
            );
            uint256 costWBTC = _getAmountsIn(cost);
            require(maxCost >= costWBTC, "MaxCost is too low");
            _swapWBTCToETH(costWBTC, cost);
        }

        optionID = options.create{value: address(this).balance}(
            period,
            amount,
            scaledStrikePrice,
            HegicOptionType(uint8(optionTerms.optionType))
        );

        emit Purchased(
            msg.sender,
            _name,
            optionTerms.underlying,
            msg.value,
            optionID
        );
    }

    function exercise(
        address optionsAddress,
        uint256 optionID,
        uint256 amount,
        address account
    ) external payable override {

        require(
            optionsAddress == address(ethOptions) ||
                optionsAddress == address(wbtcOptions),
            "optionsAddress must match either ETH or WBTC options"
        );

        IHegicOptions options = IHegicOptions(optionsAddress);

        uint256 profit = exerciseProfit(optionsAddress, optionID, amount);

        options.exercise(optionID);

        if (optionsAddress == address(ethOptions)) {
            (bool success, ) = account.call{value: profit}("");
            require(success, "Failed transfer");
        } else {
            IERC20 wbtc = IERC20(wbtcAddress);
            wbtc.safeTransfer(account, profit);
        }

        emit Exercised(account, optionsAddress, optionID, amount, profit);
    }

    function _swapWBTCToETH(uint256 costWBTC, uint256 costETH) internal {

        IERC20(wbtcAddress).safeTransferFrom(
            msg.sender,
            address(ethWbtcPair),
            costWBTC
        ); // send WBTC directly to the Uniswap Pair (requires approval of WBTC)
        uint256 amount0Out;
        uint256 amount1Out;
        (amount0Out, amount1Out) = (uint256(0), costETH); // in case we change tokens (currently using WETH<>WBTC pair) this should be reviewed
        ethWbtcPair.swap(amount0Out, amount1Out, address(this), "");
        IWETH(wethAddress).withdraw(costETH); // unwrapping ETH. It would not be required if options are paid using WETH
    }

    function _getAmountsIn(uint256 amountOut)
        internal
        view
        returns (uint256 amountIn)
    {

        uint256 reserveIn;
        uint256 reserveOut;
        (uint256 reserve0, uint256 reserve1, ) = ethWbtcPair.getReserves();
        (reserveIn, reserveOut) = (reserve0, reserve1);
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );

        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function rewardsClaimable(
        address rewardsAddress,
        uint256[] calldata optionIDs
    ) external view returns (uint256 rewardsAmount) {

        IHegicRewards rewardsContract = IHegicRewards(rewardsAddress);
        IHegicOptions hegicOptions = rewardsContract.hegicOptions();
        uint256 rewardsRate = rewardsContract.rewardsRate();

        uint256 i = 0;

        while (i < optionIDs.length && optionIDs[i] > 0) {
            (, , , uint256 _amount, , uint256 _premium, , ) =
                hegicOptions.options(optionIDs[i]);
            if (!rewardsContract.rewardedOptions(optionIDs[i])) {
                rewardsAmount = rewardsAmount.add(
                    _amount.div(100).add(_premium).mul(rewardsRate).div(1e8)
                );
            }
            i += 1;
        }
    }

    function claimRewards(address rewardsAddress, uint256[] calldata optionIDs)
        external
        returns (uint256 rewardsAmount)
    {

        IHegicRewards rewardsContract = IHegicRewards(rewardsAddress);
        IERC20 hegicToken = rewardsContract.hegic();

        uint256 i = 0;

        uint256 balanceBefore = hegicToken.balanceOf(address(this));

        while (i < optionIDs.length && optionIDs[i] > 0) {
            try rewardsContract.getReward(optionIDs[i]) {} catch {}
            i += 1;
        }

        uint256 balanceAfter = hegicToken.balanceOf(address(this));

        rewardsAmount = balanceAfter.sub(balanceBefore);
        require(rewardsAmount > 0, "No rewards to claim");
        hegicToken.safeTransfer(msg.sender, rewardsAmount);
    }

    function createShort(OptionTerms memory, uint256)
        external
        pure
        override
        returns (uint256)
    {

        return 0;
    }

    function closeShort() external pure override returns (uint256) {

        return 0;
    }

    function getHegicOptions(address underlying)
        private
        view
        returns (IHegicOptions)
    {

        if (underlying == ethAddress) {
            return ethOptions;
        } else if (underlying == wbtcAddress) {
            return wbtcOptions;
        }
        require(false, "No matching options contract");
    }

    function scaleDownStrikePrice(uint256 strikePrice)
        private
        pure
        returns (uint256)
    {

        return strikePrice.div(10**10);
    }
}