
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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
}pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

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

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}// MIT

pragma solidity 0.8.3;

interface IVesperPool is IERC20 {

    function deposit() external payable;


    function deposit(uint256 _share) external;


    function multiTransfer(address[] memory _recipients, uint256[] memory _amounts) external returns (bool);


    function excessDebt(address _strategy) external view returns (uint256);


    function permit(
        address,
        address,
        uint256,
        uint256,
        uint8,
        bytes32,
        bytes32
    ) external;


    function poolRewards() external returns (address);


    function reportEarning(
        uint256 _profit,
        uint256 _loss,
        uint256 _payback
    ) external;


    function reportLoss(uint256 _loss) external;


    function resetApproval() external;


    function sweepERC20(address _fromToken) external;


    function withdraw(uint256 _amount) external;


    function withdrawETH(uint256 _amount) external;


    function whitelistedWithdraw(uint256 _amount) external;


    function governor() external view returns (address);


    function keepers() external view returns (address[] memory);


    function isKeeper(address _address) external view returns (bool);


    function maintainers() external view returns (address[] memory);


    function isMaintainer(address _address) external view returns (bool);


    function feeCollector() external view returns (address);


    function pricePerShare() external view returns (uint256);


    function strategy(address _strategy)
        external
        view
        returns (
            bool _active,
            uint256 _interestFee,
            uint256 _debtRate,
            uint256 _lastRebalance,
            uint256 _totalDebt,
            uint256 _totalLoss,
            uint256 _totalProfit,
            uint256 _debtRatio
        );


    function stopEverything() external view returns (bool);


    function token() external view returns (IERC20);


    function tokensHere() external view returns (uint256);


    function totalDebtOf(address _strategy) external view returns (uint256);


    function totalValue() external view returns (uint256);


    function withdrawFee() external view returns (uint256);


    function getPricePerShare() external view returns (uint256);

}// MIT

pragma solidity 0.8.3;


interface AaveLendingPoolAddressesProvider {

    function getLendingPool() external view returns (address);


    function getAddress(bytes32 id) external view returns (address);

}

interface AToken is IERC20 {

    function getIncentivesController() external view returns (address);

}

interface AaveIncentivesController {

    function getRewardsBalance(address[] calldata assets, address user) external view returns (uint256);


    function claimRewards(
        address[] calldata assets,
        uint256 amount,
        address to
    ) external returns (uint256);

}

interface AaveLendingPool {

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;


    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);


    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external;

}

interface AaveProtocolDataProvider {

    function getReserveTokensAddresses(address asset)
        external
        view
        returns (
            address aTokenAddress,
            address stableDebtTokenAddress,
            address variableDebtTokenAddress
        );


    function getReserveData(address asset)
        external
        view
        returns (
            uint256 availableLiquidity,
            uint256 totalStableDebt,
            uint256 totalVariableDebt,
            uint256 liquidityRate,
            uint256 variableBorrowRate,
            uint256 stableBorrowRate,
            uint256 averageStableBorrowRate,
            uint256 liquidityIndex,
            uint256 variableBorrowIndex,
            uint40 lastUpdateTimestamp
        );

}

interface StakedAave is IERC20 {

    function claimRewards(address to, uint256 amount) external;


    function cooldown() external;


    function stake(address onBehalfOf, uint256 amount) external;


    function redeem(address to, uint256 amount) external;


    function getTotalRewardsBalance(address staker) external view returns (uint256);


    function stakersCooldowns(address staker) external view returns (uint256);


    function COOLDOWN_SECONDS() external view returns (uint256);


    function UNSTAKE_WINDOW() external view returns (uint256);

}// MIT

pragma solidity 0.8.3;


library Account {

    enum Status {Normal, Liquid, Vapor}
    struct Info {
        address owner; // The address that owns the account
        uint256 number; // A nonce that allows a single address to control many accounts
    }
}

library Actions {

    enum ActionType {
        Deposit, // supply tokens
        Withdraw, // borrow tokens
        Transfer, // transfer balance between accounts
        Buy, // buy an amount of some token (publicly)
        Sell, // sell an amount of some token (publicly)
        Trade, // trade tokens against another account
        Liquidate, // liquidate an undercollateralized or expiring account
        Vaporize, // use excess tokens to zero-out a completely negative account
        Call // send arbitrary data to an address
    }

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        Types.AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }
}

library Types {

    enum AssetDenomination {
        Wei, // the amount is denominated in wei
        Par // the amount is denominated in par
    }

    enum AssetReference {
        Delta, // the amount is given as a delta from the current value
        Target // the amount is given as an exact number to end up at
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }
}

interface ISoloMargin {

    function getMarketTokenAddress(uint256 marketId) external view returns (address);


    function getNumMarkets() external view returns (uint256);


    function operate(Account.Info[] memory accounts, Actions.ActionArgs[] memory actions) external;

}

interface ICallee {


    function callFunction(
        address sender,
        Account.Info memory accountInfo,
        bytes memory data
    ) external;

}// MIT

pragma solidity 0.8.3;


abstract contract FlashLoanHelper {
    using SafeERC20 for IERC20;

    AaveLendingPoolAddressesProvider internal aaveAddressesProvider;

    address internal constant SOLO = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    uint256 public dyDxMarketId;
    bytes32 private constant AAVE_PROVIDER_ID = 0x0100000000000000000000000000000000000000000000000000000000000000;
    bool public isAaveActive = false;
    bool public isDyDxActive = false;

    constructor(address _aaveAddressesProvider) {
        require(_aaveAddressesProvider != address(0), "invalid-aave-provider");

        aaveAddressesProvider = AaveLendingPoolAddressesProvider(_aaveAddressesProvider);
    }

    function _updateAaveStatus(bool _status) internal {
        isAaveActive = _status;
    }

    function _updateDyDxStatus(bool _status, address _token) internal {
        if (_status) {
            dyDxMarketId = _getMarketIdFromTokenAddress(SOLO, _token);
        }
        isDyDxActive = _status;
    }

    function _approveToken(address _token, uint256 _amount) internal {
        IERC20(_token).safeApprove(SOLO, _amount);
        IERC20(_token).safeApprove(aaveAddressesProvider.getLendingPool(), _amount);
    }

    function _flashLoanLogic(bytes memory _data, uint256 _repayAmount) internal virtual;


    bool private awaitingFlash = false;

    function _doAaveFlashLoan(
        address _token,
        uint256 _amountDesired,
        bytes memory _data
    ) internal returns (uint256 _amount) {
        require(isAaveActive, "aave-flash-loan-is-not-active");
        AaveLendingPool _aaveLendingPool = AaveLendingPool(aaveAddressesProvider.getLendingPool());
        AaveProtocolDataProvider _aaveProtocolDataProvider =
            AaveProtocolDataProvider(aaveAddressesProvider.getAddress(AAVE_PROVIDER_ID));
        (uint256 _availableLiquidity, , , , , , , , , ) = _aaveProtocolDataProvider.getReserveData(_token);
        if (_amountDesired > _availableLiquidity) {
            _amountDesired = _availableLiquidity;
        }

        address[] memory assets = new address[](1);
        assets[0] = _token;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amountDesired;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        awaitingFlash = true;

        _aaveLendingPool.flashLoan(address(this), assets, amounts, modes, address(this), _data, 0);
        _amount = _amountDesired;
        awaitingFlash = false;
    }

    function executeOperation(
        address[] calldata, /*_assets*/
        uint256[] calldata _amounts,
        uint256[] calldata _premiums,
        address _initiator,
        bytes calldata _data
    ) external returns (bool) {
        require(msg.sender == aaveAddressesProvider.getLendingPool(), "!aave-pool");
        require(awaitingFlash, "invalid-flash-loan");
        require(_initiator == address(this), "invalid-initiator");

        uint256 _repayAmount = _amounts[0] + _premiums[0];
        _flashLoanLogic(_data, _repayAmount);
        return true;
    }



    function _doDyDxFlashLoan(
        address _token,
        uint256 _amountDesired,
        bytes memory _data
    ) internal returns (uint256 _amount) {
        require(isDyDxActive, "dydx-flash-loan-is-not-active");

        uint256 amountInSolo = IERC20(_token).balanceOf(SOLO);
        if (_amountDesired > amountInSolo) {
            _amountDesired = amountInSolo;
        }
        uint256 repayAmount = _amountDesired + 2;

        bytes memory _callData = abi.encode(_data, repayAmount);

        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

        operations[0] = _getWithdrawAction(dyDxMarketId, _amountDesired);
        operations[1] = _getCallAction(_callData);
        operations[2] = _getDepositAction(dyDxMarketId, repayAmount);

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        ISoloMargin(SOLO).operate(accountInfos, operations);
        _amount = _amountDesired;
    }

    function callFunction(
        address _sender,
        Account.Info memory, /* _account */
        bytes memory _callData
    ) external {
        (bytes memory _data, uint256 _repayAmount) = abi.decode(_callData, (bytes, uint256));
        require(msg.sender == SOLO, "!solo");
        require(_sender == address(this), "invalid-initiator");
        _flashLoanLogic(_data, _repayAmount);
    }

    function _getAccountInfo() internal view returns (Account.Info memory) {
        return Account.Info({owner: address(this), number: 1});
    }

    function _getMarketIdFromTokenAddress(address _solo, address token) internal view returns (uint256) {
        ISoloMargin solo = ISoloMargin(_solo);

        uint256 numMarkets = solo.getNumMarkets();

        address curToken;
        for (uint256 i = 0; i < numMarkets; i++) {
            curToken = solo.getMarketTokenAddress(i);

            if (curToken == token) {
                return i;
            }
        }

        revert("no-marketId-found-for-token");
    }

    function _getWithdrawAction(uint256 marketId, uint256 amount) internal view returns (Actions.ActionArgs memory) {
        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Withdraw,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }

    function _getCallAction(bytes memory data) internal view returns (Actions.ActionArgs memory) {
        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Call,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: 0
                }),
                primaryMarketId: 0,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: data
            });
    }

    function _getDepositAction(uint256 marketId, uint256 amount) internal view returns (Actions.ActionArgs memory) {
        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Deposit,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: true,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }

}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity 0.8.3;



interface ISwapManager {

    event OracleCreated(address indexed _sender, address indexed _newOracle, uint256 _period);

    function N_DEX() external view returns (uint256);


    function ROUTERS(uint256 i) external view returns (IUniswapV2Router02);


    function bestOutputFixedInput(
        address _from,
        address _to,
        uint256 _amountIn
    )
        external
        view
        returns (
            address[] memory path,
            uint256 amountOut,
            uint256 rIdx
        );


    function bestPathFixedInput(
        address _from,
        address _to,
        uint256 _amountIn,
        uint256 _i
    ) external view returns (address[] memory path, uint256 amountOut);


    function bestInputFixedOutput(
        address _from,
        address _to,
        uint256 _amountOut
    )
        external
        view
        returns (
            address[] memory path,
            uint256 amountIn,
            uint256 rIdx
        );


    function bestPathFixedOutput(
        address _from,
        address _to,
        uint256 _amountOut,
        uint256 _i
    ) external view returns (address[] memory path, uint256 amountIn);


    function safeGetAmountsOut(
        uint256 _amountIn,
        address[] memory _path,
        uint256 _i
    ) external view returns (uint256[] memory result);


    function unsafeGetAmountsOut(
        uint256 _amountIn,
        address[] memory _path,
        uint256 _i
    ) external view returns (uint256[] memory result);


    function safeGetAmountsIn(
        uint256 _amountOut,
        address[] memory _path,
        uint256 _i
    ) external view returns (uint256[] memory result);


    function unsafeGetAmountsIn(
        uint256 _amountOut,
        address[] memory _path,
        uint256 _i
    ) external view returns (uint256[] memory result);


    function comparePathsFixedInput(
        address[] memory pathA,
        address[] memory pathB,
        uint256 _amountIn,
        uint256 _i
    ) external view returns (address[] memory path, uint256 amountOut);


    function comparePathsFixedOutput(
        address[] memory pathA,
        address[] memory pathB,
        uint256 _amountOut,
        uint256 _i
    ) external view returns (address[] memory path, uint256 amountIn);


    function ours(address a) external view returns (bool);


    function oracleCount() external view returns (uint256);


    function oracleAt(uint256 idx) external view returns (address);


    function getOracle(
        address _tokenA,
        address _tokenB,
        uint256 _period,
        uint256 _i
    ) external view returns (address);


    function createOrUpdateOracle(
        address _tokenA,
        address _tokenB,
        uint256 _period,
        uint256 _i
    ) external returns (address oracleAddr);


    function consultForFree(
        address _from,
        address _to,
        uint256 _amountIn,
        uint256 _period,
        uint256 _i
    ) external view returns (uint256 amountOut, uint256 lastUpdatedAt);


    function consult(
        address _from,
        address _to,
        uint256 _amountIn,
        uint256 _period,
        uint256 _i
    )
        external
        returns (
            uint256 amountOut,
            uint256 lastUpdatedAt,
            bool updated
        );


    function updateOracles() external returns (uint256 updated, uint256 expected);


    function updateOracles(address[] memory _oracleAddrs) external returns (uint256 updated, uint256 expected);

}// MIT

pragma solidity 0.8.3;

interface CToken {

    function accrueInterest() external returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function balanceOfUnderlying(address owner) external returns (uint256);


    function borrowBalanceCurrent(address account) external returns (uint256);


    function borrowBalanceStored(address account) external view returns (uint256);


    function exchangeRateCurrent() external returns (uint256);


    function exchangeRateStored() external view returns (uint256);


    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function borrow(uint256 borrowAmount) external returns (uint256);


    function mint() external payable; // For ETH


    function mint(uint256 mintAmount) external returns (uint256); // For ERC20


    function redeem(uint256 redeemTokens) external returns (uint256);


    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);


    function repayBorrow() external payable; // For ETH


    function repayBorrow(uint256 repayAmount) external returns (uint256); // For ERC20


    function transfer(address user, uint256 amount) external returns (bool);


    function getCash() external view returns (uint256);


    function transferFrom(
        address owner,
        address user,
        uint256 amount
    ) external returns (bool);


    function underlying() external view returns (address);

}

interface Comptroller {

    function claimComp(address holder, address[] memory) external;


    function enterMarkets(address[] memory cTokens) external returns (uint256[] memory);


    function exitMarket(address cToken) external returns (uint256);


    function compAccrued(address holder) external view returns (uint256);


    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function markets(address market)
        external
        view
        returns (
            bool isListed,
            uint256 collateralFactorMantissa,
            bool isCompted
        );

}// MIT
pragma solidity 0.8.3;


interface IUniswapV3Oracle {

    function assetToEth(
        address _tokenIn,
        uint256 _amountIn,
        uint32 _twapPeriod
    ) external view returns (uint256 ethAmountOut);


    function ethToAsset(
        uint256 _ethAmountIn,
        address _tokenOut,
        uint32 _twapPeriod
    ) external view returns (uint256 amountOut);


    function assetToAsset(
        address _tokenIn,
        uint256 _amountIn,
        address _tokenOut,
        uint32 _twapPeriod
    ) external view returns (uint256 amountOut);


    function assetToAssetThruRoute(
        address _tokenIn,
        uint256 _amountIn,
        address _tokenOut,
        uint32 _twapPeriod,
        address _routeThruToken,
        uint24[2] memory _poolFees
    ) external view returns (uint256 amountOut);

}// MIT

pragma solidity 0.8.3;


interface TokenLike is IERC20 {

    function deposit() external payable;


    function withdraw(uint256) external;

}// MIT

pragma solidity 0.8.3;

interface IStrategy {

    function rebalance() external;


    function sweepERC20(address _fromToken) external;


    function withdraw(uint256 _amount) external;


    function feeCollector() external view returns (address);


    function isReservedToken(address _token) external view returns (bool);


    function keepers() external view returns (address[] memory);


    function migrate(address _newStrategy) external;


    function token() external view returns (address);


    function totalValue() external view returns (uint256);


    function totalValueCurrent() external returns (uint256);


    function pool() external view returns (address);

}// MIT

pragma solidity 0.8.3;


abstract contract Strategy is IStrategy, Context {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint256 internal constant MAX_UINT_VALUE = type(uint256).max;

    address internal WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IERC20 public immutable collateralToken;
    address public receiptToken;
    address public immutable override pool;
    address public override feeCollector;
    ISwapManager public swapManager;

    uint256 public oraclePeriod = 3600; // 1h
    uint256 public oracleRouterIdx = 0; // Uniswap V2
    uint256 public swapSlippage = 10000; // 100% Don't use oracles by default

    EnumerableSet.AddressSet private _keepers;

    event UpdatedFeeCollector(address indexed previousFeeCollector, address indexed newFeeCollector);
    event UpdatedSwapManager(address indexed previousSwapManager, address indexed newSwapManager);
    event UpdatedSwapSlippage(uint256 oldSwapSlippage, uint256 newSwapSlippage);
    event UpdatedOracleConfig(uint256 oldPeriod, uint256 newPeriod, uint256 oldRouterIdx, uint256 newRouterIdx);

    constructor(
        address _pool,
        address _swapManager,
        address _receiptToken
    ) {
        require(_pool != address(0), "pool-address-is-zero");
        require(_swapManager != address(0), "sm-address-is-zero");
        swapManager = ISwapManager(_swapManager);
        pool = _pool;
        collateralToken = IVesperPool(_pool).token();
        receiptToken = _receiptToken;
        require(_keepers.add(_msgSender()), "add-keeper-failed");
    }

    modifier onlyGovernor {
        require(_msgSender() == IVesperPool(pool).governor(), "caller-is-not-the-governor");
        _;
    }

    modifier onlyKeeper() {
        require(_keepers.contains(_msgSender()), "caller-is-not-a-keeper");
        _;
    }

    modifier onlyPool() {
        require(_msgSender() == pool, "caller-is-not-vesper-pool");
        _;
    }

    function addKeeper(address _keeperAddress) external onlyGovernor {
        require(_keepers.add(_keeperAddress), "add-keeper-failed");
    }

    function keepers() external view override returns (address[] memory) {
        return _keepers.values();
    }

    function migrate(address _newStrategy) external virtual override onlyPool {
        require(_newStrategy != address(0), "new-strategy-address-is-zero");
        require(IStrategy(_newStrategy).pool() == pool, "not-valid-new-strategy");
        _beforeMigration(_newStrategy);
        IERC20(receiptToken).safeTransfer(_newStrategy, IERC20(receiptToken).balanceOf(address(this)));
        collateralToken.safeTransfer(_newStrategy, collateralToken.balanceOf(address(this)));
    }

    function removeKeeper(address _keeperAddress) external onlyGovernor {
        require(_keepers.remove(_keeperAddress), "remove-keeper-failed");
    }

    function updateFeeCollector(address _feeCollector) external onlyGovernor {
        require(_feeCollector != address(0), "fee-collector-address-is-zero");
        require(_feeCollector != feeCollector, "fee-collector-is-same");
        emit UpdatedFeeCollector(feeCollector, _feeCollector);
        feeCollector = _feeCollector;
    }

    function updateSwapManager(address _swapManager) external onlyGovernor {
        require(_swapManager != address(0), "sm-address-is-zero");
        require(_swapManager != address(swapManager), "sm-is-same");
        emit UpdatedSwapManager(address(swapManager), _swapManager);
        swapManager = ISwapManager(_swapManager);
    }

    function updateSwapSlippage(uint256 _newSwapSlippage) external onlyGovernor {
        require(_newSwapSlippage <= 10000, "invalid-slippage-value");
        emit UpdatedSwapSlippage(swapSlippage, _newSwapSlippage);
        swapSlippage = _newSwapSlippage;
    }

    function updateOracleConfig(uint256 _newPeriod, uint256 _newRouterIdx) external onlyGovernor {
        require(_newRouterIdx < swapManager.N_DEX(), "invalid-router-index");
        if (_newPeriod == 0) _newPeriod = oraclePeriod;
        require(_newPeriod > 59, "invalid-oracle-period");
        emit UpdatedOracleConfig(oraclePeriod, _newPeriod, oracleRouterIdx, _newRouterIdx);
        oraclePeriod = _newPeriod;
        oracleRouterIdx = _newRouterIdx;
    }

    function approveToken() external onlyKeeper {
        _approveToken(0);
        _approveToken(MAX_UINT_VALUE);
    }

    function setupOracles() external onlyKeeper {
        _setupOracles();
    }

    function withdraw(uint256 _amount) external override onlyPool {
        _withdraw(_amount);
    }

    function rebalance() external virtual override onlyKeeper {
        (uint256 _profit, uint256 _loss, uint256 _payback) = _generateReport();
        IVesperPool(pool).reportEarning(_profit, _loss, _payback);
        _reinvest();
    }

    function sweepERC20(address _fromToken) external override onlyKeeper {
        require(feeCollector != address(0), "fee-collector-not-set");
        require(_fromToken != address(collateralToken), "not-allowed-to-sweep-collateral");
        require(!isReservedToken(_fromToken), "not-allowed-to-sweep");
        if (_fromToken == ETH) {
            Address.sendValue(payable(feeCollector), address(this).balance);
        } else {
            uint256 _amount = IERC20(_fromToken).balanceOf(address(this));
            IERC20(_fromToken).safeTransfer(feeCollector, _amount);
        }
    }

    function token() external view override returns (address) {
        return receiptToken;
    }

    function totalValue() public view virtual override returns (uint256 _value);

    function totalValueCurrent() external virtual override returns (uint256) {
        return totalValue();
    }

    function isReservedToken(address _token) public view virtual override returns (bool);

    function _beforeMigration(address _newStrategy) internal virtual;

    function _generateReport()
        internal
        virtual
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _payback
        )
    {
        uint256 _excessDebt = IVesperPool(pool).excessDebt(address(this));
        uint256 _totalDebt = IVesperPool(pool).totalDebtOf(address(this));
        _profit = _realizeProfit(_totalDebt);
        _loss = _realizeLoss(_totalDebt);
        _payback = _liquidate(_excessDebt);
    }

    function _calcAmtOutAfterSlippage(uint256 _amount, uint256 _slippage) internal pure returns (uint256) {
        return (_amount * (10000 - _slippage)) / (10000);
    }

    function _simpleOraclePath(address _from, address _to) internal view returns (address[] memory path) {
        if (_from == WETH || _to == WETH) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = WETH;
            path[2] = _to;
        }
    }

    function _consultOracle(
        address _from,
        address _to,
        uint256 _amt
    ) internal returns (uint256, bool) {
        for (uint256 i = 0; i < swapManager.N_DEX(); i++) {
            (bool _success, bytes memory _returnData) =
                address(swapManager).call(
                    abi.encodePacked(swapManager.consult.selector, abi.encode(_from, _to, _amt, oraclePeriod, i))
                );
            if (_success) {
                (uint256 rate, uint256 lastUpdate, ) = abi.decode(_returnData, (uint256, uint256, bool));
                if ((lastUpdate > (block.timestamp - oraclePeriod)) && (rate != 0)) return (rate, true);
                return (0, false);
            }
        }
        return (0, false);
    }

    function _getOracleRate(address[] memory path, uint256 _amountIn) internal returns (uint256 amountOut) {
        require(path.length > 1, "invalid-oracle-path");
        amountOut = _amountIn;
        bool isValid;
        for (uint256 i = 0; i < path.length - 1; i++) {
            (amountOut, isValid) = _consultOracle(path[i], path[i + 1], amountOut);
            require(isValid, "invalid-oracle-rate");
        }
    }

    function _safeSwap(
        address _from,
        address _to,
        uint256 _amountIn,
        uint256 _minAmountOut
    ) internal {
        (address[] memory path, uint256 amountOut, uint256 rIdx) =
            swapManager.bestOutputFixedInput(_from, _to, _amountIn);
        if (_minAmountOut == 0) _minAmountOut = 1;
        if (amountOut != 0) {
            swapManager.ROUTERS(rIdx).swapExactTokensForTokens(
                _amountIn,
                _minAmountOut,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function _claimRewardsAndConvertTo(address _toToken) internal virtual {}

    function _setupOracles() internal virtual {}


    function _withdraw(uint256 _amount) internal virtual;

    function _approveToken(uint256 _amount) internal virtual;

    function _liquidate(uint256 _excessDebt) internal virtual returns (uint256 _payback);

    function _realizeProfit(uint256 _totalDebt) internal virtual returns (uint256 _profit);

    function _realizeLoss(uint256 _totalDebt) internal virtual returns (uint256 _loss);

    function _reinvest() internal virtual;
}// GNU LGPLv3

pragma solidity 0.8.3;


contract CompoundLeverageStrategy is Strategy, FlashLoanHelper {

    using SafeERC20 for IERC20;

    string public NAME;
    string public constant VERSION = "4.0.0";

    uint256 internal constant MAX_BPS = 10_000; //100%
    uint256 public minBorrowRatio = 5_000; // 50%
    uint256 public maxBorrowRatio = 6_000; // 60%
    CToken internal cToken;
    IUniswapV3Oracle internal constant ORACLE = IUniswapV3Oracle(0x0F1f5A87f99f0918e6C81F16E59F3518698221Ff);
    uint32 internal constant TWAP_PERIOD = 3600;

    Comptroller public immutable comptroller;
    address public immutable rewardToken;
    address public rewardDistributor;

    event UpdatedBorrowRatio(
        uint256 previousMinBorrowRatio,
        uint256 newMinBorrowRatio,
        uint256 previousMaxBorrowRatio,
        uint256 newMaxBorrowRatio
    );

    constructor(
        address _pool,
        address _swapManager,
        address _comptroller,
        address _rewardDistributor,
        address _rewardToken,
        address _aaveAddressesProvider,
        address _receiptToken,
        string memory _name
    ) Strategy(_pool, _swapManager, _receiptToken) FlashLoanHelper(_aaveAddressesProvider) {
        NAME = _name;
        require(_comptroller != address(0), "comptroller-address-is-zero");
        comptroller = Comptroller(_comptroller);
        rewardToken = _rewardToken;

        require(_receiptToken != address(0), "cToken-address-is-zero");
        cToken = CToken(_receiptToken);

        require(_rewardDistributor != address(0), "invalid-reward-distributor-addr");
        rewardDistributor = _rewardDistributor;
    }

    function updateBorrowRatio(uint256 _minBorrowRatio, uint256 _maxBorrowRatio) external onlyGovernor {

        (, uint256 _collateralFactor, ) = comptroller.markets(address(cToken));
        require(_maxBorrowRatio < (_collateralFactor / 1e14), "invalid-max-borrow-limit");
        require(_maxBorrowRatio > _minBorrowRatio, "max-should-be-higher-than-min");
        emit UpdatedBorrowRatio(minBorrowRatio, _minBorrowRatio, maxBorrowRatio, _maxBorrowRatio);
        minBorrowRatio = _minBorrowRatio;
        maxBorrowRatio = _maxBorrowRatio;
    }

    function updateAaveStatus(bool _status) external onlyGovernor {

        _updateAaveStatus(_status);
    }

    function updateDyDxStatus(bool _status) external virtual onlyGovernor {

        _updateDyDxStatus(_status, address(collateralToken));
    }

    function totalValueCurrent() public override returns (uint256 _totalValue) {

        cToken.exchangeRateCurrent();
        _claimRewards();

        _totalValue = _calculateTotalValue(IERC20(rewardToken).balanceOf(address(this)));
    }

    function currentBorrowRatio() external view returns (uint256) {

        (uint256 _supply, uint256 _borrow) = getPosition();
        return _borrow == 0 ? 0 : (_borrow * MAX_BPS) / _supply;
    }

    function totalValue() public view virtual override returns (uint256 _totalValue) {

        _totalValue = _calculateTotalValue(_getRewardAccrued());
    }

    function isLossMaking() external returns (bool) {

        return totalValueCurrent() < IVesperPool(pool).totalDebtOf(address(this));
    }

    function isReservedToken(address _token) public view virtual override returns (bool) {

        return _token == address(cToken) || _token == rewardToken || _token == address(collateralToken);
    }

    function getPosition() public view returns (uint256 _supply, uint256 _borrow) {

        (, uint256 _cTokenBalance, uint256 _borrowBalance, uint256 _exchangeRate) =
            cToken.getAccountSnapshot(address(this));
        _supply = (_cTokenBalance * _exchangeRate) / 1e18;
        _borrow = _borrowBalance;
    }

    function _approveToken(uint256 _amount) internal virtual override {

        collateralToken.safeApprove(pool, _amount);
        collateralToken.safeApprove(address(cToken), _amount);
        for (uint256 i = 0; i < swapManager.N_DEX(); i++) {
            IERC20(rewardToken).safeApprove(address(swapManager.ROUTERS(i)), _amount);
        }
        FlashLoanHelper._approveToken(address(collateralToken), _amount);
    }

    function _beforeMigration(address _newStrategy) internal virtual override {

        require(IStrategy(_newStrategy).token() == address(cToken), "wrong-receipt-token");
        minBorrowRatio = 0;
        _reinvest();
    }

    function _calculateDesiredPosition(uint256 _amount, bool _isDeposit)
        internal
        returns (uint256 _position, bool _shouldRepay)
    {

        uint256 _totalSupply = cToken.balanceOfUnderlying(address(this));
        uint256 _currentBorrow = cToken.borrowBalanceStored(address(this));
        if (minBorrowRatio == 0) {
            return (_currentBorrow, true);
        }

        uint256 _supply = _totalSupply - _currentBorrow;

        uint256 _newSupply = _isDeposit ? _supply + _amount : _supply > _amount ? _supply - _amount : 0;

        uint256 _borrowUpperBound = (_newSupply * maxBorrowRatio) / (MAX_BPS - maxBorrowRatio);
        uint256 _borrowLowerBound = (_newSupply * minBorrowRatio) / (MAX_BPS - minBorrowRatio);

        if (_currentBorrow > _borrowUpperBound) {
            _shouldRepay = true;
            _position = _currentBorrow - _borrowLowerBound;
        } else if (_currentBorrow < _borrowLowerBound) {
            _shouldRepay = false;
            _position = _borrowLowerBound - _currentBorrow;
        }
    }

    function _getRewardAccrued() internal view virtual returns (uint256 _rewardAccrued) {

        _rewardAccrued = comptroller.compAccrued(address(this));
    }

    function _calculateTotalValue(uint256 _rewardAccrued) internal view returns (uint256 _totalValue) {

        uint256 _compAsCollateral;
        if (_rewardAccrued != 0) {
            (, _compAsCollateral, ) = swapManager.bestOutputFixedInput(
                rewardToken,
                address(collateralToken),
                _rewardAccrued
            );
        }
        (uint256 _supply, uint256 _borrow) = getPosition();
        _totalValue = _compAsCollateral + collateralToken.balanceOf(address(this)) + _supply - _borrow;
    }

    function _claimRewards() internal virtual {

        address[] memory _markets = new address[](1);
        _markets[0] = address(cToken);
        comptroller.claimComp(address(this), _markets);
    }

    function _claimRewardsAndConvertTo(address _toToken) internal override {

        _claimRewards();
        uint256 _rewardAmount = IERC20(rewardToken).balanceOf(address(this));
        if (_rewardAmount != 0) {
            _safeSwap(rewardToken, _toToken, _rewardAmount);
        }
    }

    function _generateReport()
        internal
        override
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _payback
        )
    {

        uint256 _excessDebt = IVesperPool(pool).excessDebt(address(this));
        (, , , , uint256 _totalDebt, , , uint256 _debtRatio) = IVesperPool(pool).strategy(address(this));

        _claimRewardsAndConvertTo(address(collateralToken));

        uint256 _supply = cToken.balanceOfUnderlying(address(this));
        uint256 _borrow = cToken.borrowBalanceStored(address(this));
        uint256 _investedCollateral = _supply - _borrow;

        uint256 _collateralHere = collateralToken.balanceOf(address(this));
        uint256 _totalCollateral = _investedCollateral + _collateralHere;

        uint256 _profitToWithdraw;

        if (_totalCollateral > _totalDebt) {
            _profit = _totalCollateral - _totalDebt;
            if (_collateralHere <= _profit) {
                _profitToWithdraw = _profit - _collateralHere;
            } else if (_collateralHere >= (_profit + _excessDebt)) {
                _payback = _excessDebt;
            } else {
                _payback = _collateralHere - _profit;
            }
        } else {
            _loss = _totalDebt - _totalCollateral;
        }

        uint256 _paybackToWithdraw = _excessDebt - _payback;
        uint256 _totalAmountToWithdraw = _paybackToWithdraw + _profitToWithdraw;
        if (_totalAmountToWithdraw != 0) {
            uint256 _withdrawn = _withdrawHere(_totalAmountToWithdraw);
            if (_withdrawn > _profitToWithdraw) {
                _payback += (_withdrawn - _profitToWithdraw);
            }
        }

        (_supply, _borrow) = getPosition();
        if (_debtRatio == 0 && _supply != 0 && _borrow == 0) {
            _redeemUnderlying(MAX_UINT_VALUE);
            _profit += _supply;
        }
    }

    function _adjustPosition(uint256 _adjustBy, bool _shouldRepay) internal returns (uint256 amount) {

        (uint256 _supply, uint256 _borrow) = getPosition();

        if (_borrow == 0 && _shouldRepay) {
            return 0;
        }

        (, uint256 collateralFactor, ) = comptroller.markets(address(cToken));

        if (_shouldRepay) {
            amount = _normalDeleverage(_adjustBy, _supply, _borrow, collateralFactor);
        } else {
            amount = _normalLeverage(_adjustBy, _supply, _borrow, collateralFactor);
        }
    }

    function _normalDeleverage(
        uint256 _maxDeleverage,
        uint256 _supply,
        uint256 _borrow,
        uint256 _collateralFactor
    ) internal returns (uint256 _deleveragedAmount) {

        uint256 _theoreticalSupply;

        if (_collateralFactor != 0) {
            _theoreticalSupply = (_borrow * 1e18) / _collateralFactor;
        }

        _deleveragedAmount = _supply - _theoreticalSupply;

        if (_deleveragedAmount >= _borrow) {
            _deleveragedAmount = _borrow;
        }
        if (_deleveragedAmount >= _maxDeleverage) {
            _deleveragedAmount = _maxDeleverage;
        }

        _redeemUnderlying(_deleveragedAmount);
        _repayBorrow(_deleveragedAmount);
    }

    function _normalLeverage(
        uint256 _maxLeverage,
        uint256 _supply,
        uint256 _borrow,
        uint256 _collateralFactor
    ) internal returns (uint256 _leveragedAmount) {

        uint256 theoreticalBorrow = (_supply * _collateralFactor) / 1e18;

        _leveragedAmount = theoreticalBorrow - _borrow;

        if (_leveragedAmount >= _maxLeverage) {
            _leveragedAmount = _maxLeverage;
        }
        _borrowCollateral(_leveragedAmount);
        _mint(collateralToken.balanceOf(address(this)));
    }

    function _reinvest() internal virtual override {

        uint256 _collateralBalance = collateralToken.balanceOf(address(this));
        (uint256 _position, bool _shouldRepay) = _calculateDesiredPosition(_collateralBalance, true);
        _mint(_collateralBalance);

        _position -= _doFlashLoan(_position, _shouldRepay);

        uint256 i = 0;
        while (_position > 0 && i <= 6) {
            _position -= _adjustPosition(_position, _shouldRepay);
            i++;
        }
    }

    function _withdraw(uint256 _amount) internal override {

        collateralToken.safeTransfer(pool, _withdrawHere(_amount));
    }

    function _withdrawHere(uint256 _amount) internal returns (uint256) {

        (uint256 _position, bool _shouldRepay) = _calculateDesiredPosition(_amount, false);
        if (_shouldRepay) {
            _position -= _doFlashLoan(_position, _shouldRepay);

            uint256 i = 0;
            while (_position > 0 && i <= 10) {
                _position -= _adjustPosition(_position, true);
                i++;
            }

            if (_position != 0) {
                (uint256 _supply, uint256 _borrow) = getPosition();

                uint256 _supplyToSupportBorrow;
                if (maxBorrowRatio != 0) {
                    _supplyToSupportBorrow = (_borrow * MAX_BPS) / maxBorrowRatio;
                }
                uint256 _redeemable = _supply - _supplyToSupportBorrow;
                if (_amount > _redeemable) {
                    _amount = _redeemable;
                }
            }
        }
        uint256 _collateralBefore = collateralToken.balanceOf(address(this));

        if (_amount > cToken.balanceOfUnderlying(address(this))) {
            _collateralBefore = 0;
            _claimRewardsAndConvertTo(address(collateralToken));
            _amount = _amount - collateralToken.balanceOf(address(this));
        }
        _redeemUnderlying(_amount);
        uint256 _collateralAfter = collateralToken.balanceOf(address(this));
        return _collateralAfter - _collateralBefore;
    }

    function _doFlashLoan(uint256 _flashAmount, bool _shouldRepay) internal returns (uint256) {

        uint256 _totalFlashAmount;
        if (isDyDxActive && _flashAmount > 0) {
            bytes memory _data = abi.encode(_flashAmount, _shouldRepay);
            _totalFlashAmount = _doDyDxFlashLoan(address(collateralToken), _flashAmount, _data);
            _flashAmount -= _totalFlashAmount;
        }
        if (isAaveActive && _shouldRepay && _flashAmount > 0) {
            bytes memory _data = abi.encode(_flashAmount, _shouldRepay);
            _totalFlashAmount += _doAaveFlashLoan(address(collateralToken), _flashAmount, _data);
        }
        return _totalFlashAmount;
    }

    function _flashLoanLogic(bytes memory _data, uint256 _repayAmount) internal override {

        (uint256 _amount, bool _deficit) = abi.decode(_data, (uint256, bool));
        uint256 _collateralHere = collateralToken.balanceOf(address(this));
        require(_collateralHere >= _amount, "FLASH_FAILED"); // to stop malicious calls

        if (_deficit) {
            _repayBorrow(_amount);
            _redeemUnderlying(_repayAmount);
        } else {
            _mint(_collateralHere);
            _borrowCollateral(_repayAmount);
        }
    }

    function _safeSwap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) internal virtual {

        uint256 _minAmountOut =
            swapSlippage != 10000
                ? _calcAmtOutAfterSlippage(
                    ORACLE.assetToAsset(_tokenIn, _amountIn, _tokenOut, TWAP_PERIOD),
                    swapSlippage
                )
                : 1;
        _safeSwap(_tokenIn, _tokenOut, _amountIn, _minAmountOut);
    }

    function _mint(uint256 _amount) internal virtual {

        require(cToken.mint(_amount) == 0, "supply-to-compound-failed");
    }

    function _redeemUnderlying(uint256 _amount) internal virtual {

        if (_amount == MAX_UINT_VALUE) {
            require(cToken.redeem(cToken.balanceOf(address(this))) == 0, "withdraw-from-compound-failed");
        } else {
            require(cToken.redeemUnderlying(_amount) == 0, "withdraw-from-compound-failed");
        }
    }

    function _borrowCollateral(uint256 _amount) internal virtual {

        require(cToken.borrow(_amount) == 0, "borrow-from-compound-failed");
    }

    function _repayBorrow(uint256 _amount) internal virtual {

        require(cToken.repayBorrow(_amount) == 0, "repay-to-compound-failed");
    }



    function _liquidate(uint256 _excessDebt) internal override returns (uint256 _payback) {}


    function _realizeProfit(uint256 _totalDebt) internal virtual override returns (uint256) {}


    function _realizeLoss(uint256 _totalDebt) internal view override returns (uint256 _loss) {}


}// MIT

pragma solidity 0.8.3;


contract CompoundLeverageStrategyETH is CompoundLeverageStrategy {

    constructor(
        address _pool,
        address _swapManager,
        address _comptroller,
        address _rewardDistributor,
        address _rewardToken,
        address _aaveAddressesProvider,
        address _receiptToken,
        string memory _name
    )
        CompoundLeverageStrategy(
            _pool,
            _swapManager,
            _comptroller,
            _rewardDistributor,
            _rewardToken,
            _aaveAddressesProvider,
            _receiptToken,
            _name
        )
    {}

    receive() external payable {
        require(msg.sender == address(cToken) || msg.sender == WETH, "not-allowed-to-send-ether");
    }

    function _mint(uint256 _amount) internal override {

        _withdrawETH(_amount);
        cToken.mint{value: _amount}();
    }

    function _redeemUnderlying(uint256 _amount) internal override {

        super._redeemUnderlying(_amount);
        _depositETH();
    }

    function _borrowCollateral(uint256 _amount) internal override {

        super._borrowCollateral(_amount);
        _depositETH();
    }

    function _repayBorrow(uint256 _amount) internal override {

        _withdrawETH(_amount);
        cToken.repayBorrow{value: _amount}();
    }

    function _depositETH() internal {

        TokenLike(WETH).deposit{value: address(this).balance}();
    }

    function _withdrawETH(uint256 _amount) internal {

        TokenLike(WETH).withdraw(_amount);
    }
}