
            

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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





pragma solidity 0.6.12;

interface IControllerAdminInterface {

    event MarketAdded(
        address iToken,
        uint256 collateralFactor,
        uint256 borrowFactor,
        uint256 supplyCapacity,
        uint256 borrowCapacity,
        uint256 distributionFactor
    );

    function _addMarket(
        address _iToken,
        uint256 _collateralFactor,
        uint256 _borrowFactor,
        uint256 _supplyCapacity,
        uint256 _borrowCapacity,
        uint256 _distributionFactor
    ) external;


    event NewPriceOracle(address oldPriceOracle, address newPriceOracle);

    function _setPriceOracle(address newOracle) external;


    event NewCloseFactor(
        uint256 oldCloseFactorMantissa,
        uint256 newCloseFactorMantissa
    );

    function _setCloseFactor(uint256 newCloseFactorMantissa) external;


    event NewLiquidationIncentive(
        uint256 oldLiquidationIncentiveMantissa,
        uint256 newLiquidationIncentiveMantissa
    );

    function _setLiquidationIncentive(uint256 newLiquidationIncentiveMantissa)
        external;


    event NewCollateralFactor(
        address iToken,
        uint256 oldCollateralFactorMantissa,
        uint256 newCollateralFactorMantissa
    );

    function _setCollateralFactor(
        address iToken,
        uint256 newCollateralFactorMantissa
    ) external;


    event NewBorrowFactor(
        address iToken,
        uint256 oldBorrowFactorMantissa,
        uint256 newBorrowFactorMantissa
    );

    function _setBorrowFactor(address iToken, uint256 newBorrowFactorMantissa)
        external;


    event NewBorrowCapacity(
        address iToken,
        uint256 oldBorrowCapacity,
        uint256 newBorrowCapacity
    );

    function _setBorrowCapacity(address iToken, uint256 newBorrowCapacity)
        external;


    event NewSupplyCapacity(
        address iToken,
        uint256 oldSupplyCapacity,
        uint256 newSupplyCapacity
    );

    function _setSupplyCapacity(address iToken, uint256 newSupplyCapacity)
        external;


    event NewPauseGuardian(address oldPauseGuardian, address newPauseGuardian);

    function _setPauseGuardian(address newPauseGuardian) external;


    event MintPaused(address iToken, bool paused);

    function _setMintPaused(address iToken, bool paused) external;


    function _setAllMintPaused(bool paused) external;


    event RedeemPaused(address iToken, bool paused);

    function _setRedeemPaused(address iToken, bool paused) external;


    function _setAllRedeemPaused(bool paused) external;


    event BorrowPaused(address iToken, bool paused);

    function _setBorrowPaused(address iToken, bool paused) external;


    function _setAllBorrowPaused(bool paused) external;


    event TransferPaused(bool paused);

    function _setTransferPaused(bool paused) external;


    event SeizePaused(bool paused);

    function _setSeizePaused(bool paused) external;


    function _setiTokenPaused(address iToken, bool paused) external;


    function _setProtocolPaused(bool paused) external;


    event NewRewardDistributor(
        address oldRewardDistributor,
        address _newRewardDistributor
    );

    function _setRewardDistributor(address _newRewardDistributor) external;

}

interface IControllerPolicyInterface {

    function beforeMint(
        address iToken,
        address account,
        uint256 mintAmount
    ) external;


    function afterMint(
        address iToken,
        address minter,
        uint256 mintAmount,
        uint256 mintedAmount
    ) external;


    function beforeRedeem(
        address iToken,
        address redeemer,
        uint256 redeemAmount
    ) external;


    function afterRedeem(
        address iToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemedAmount
    ) external;


    function beforeBorrow(
        address iToken,
        address borrower,
        uint256 borrowAmount
    ) external;


    function afterBorrow(
        address iToken,
        address borrower,
        uint256 borrowedAmount
    ) external;


    function beforeRepayBorrow(
        address iToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external;


    function afterRepayBorrow(
        address iToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external;


    function beforeLiquidateBorrow(
        address iTokenBorrowed,
        address iTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external;


    function afterLiquidateBorrow(
        address iTokenBorrowed,
        address iTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repaidAmount,
        uint256 seizedAmount
    ) external;


    function beforeSeize(
        address iTokenBorrowed,
        address iTokenCollateral,
        address liquidator,
        address borrower,
        uint256 seizeAmount
    ) external;


    function afterSeize(
        address iTokenBorrowed,
        address iTokenCollateral,
        address liquidator,
        address borrower,
        uint256 seizedAmount
    ) external;


    function beforeTransfer(
        address iToken,
        address from,
        address to,
        uint256 amount
    ) external;


    function afterTransfer(
        address iToken,
        address from,
        address to,
        uint256 amount
    ) external;


    function beforeFlashloan(
        address iToken,
        address to,
        uint256 amount
    ) external;


    function afterFlashloan(
        address iToken,
        address to,
        uint256 amount
    ) external;

}

interface IControllerAccountEquityInterface {

    function calcAccountEquity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function liquidateCalculateSeizeTokens(
        address iTokenBorrowed,
        address iTokenCollateral,
        uint256 actualRepayAmount
    ) external view returns (uint256);

}

interface IControllerAccountInterface {

    function hasEnteredMarket(address account, address iToken)
        external
        view
        returns (bool);


    function getEnteredMarkets(address account)
        external
        view
        returns (address[] memory);


    event MarketEntered(address iToken, address account);

    function enterMarkets(address[] calldata iTokens)
        external
        returns (bool[] memory);


    function enterMarketFromiToken(address _market, address _account) external;


    event MarketExited(address iToken, address account);

    function exitMarkets(address[] calldata iTokens)
        external
        returns (bool[] memory);


    event BorrowedAdded(address iToken, address account);

    event BorrowedRemoved(address iToken, address account);

    function hasBorrowed(address account, address iToken)
        external
        view
        returns (bool);


    function getBorrowedAssets(address account)
        external
        view
        returns (address[] memory);

}

interface IControllerInterface is
    IControllerAdminInterface,
    IControllerPolicyInterface,
    IControllerAccountEquityInterface,
    IControllerAccountInterface
{

    function isController() external view returns (bool);


    function getAlliTokens() external view returns (address[] memory);


    function hasiToken(address _iToken) external view returns (bool);


    function rewardDistributor() external returns (address);

}




            

pragma solidity 0.6.12;

interface IInterestRateModelInterface {

    function isInterestRateModel() external view returns (bool);


    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256);


    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveRatio
    ) external view returns (uint256);

}




            

pragma solidity 0.6.12;


interface IiToken {

    function isSupported() external returns (bool);


    function isiToken() external returns (bool);


    function mint(address recipient, uint256 mintAmount) external;


    function mintForSelfAndEnterMarket(uint256 mintAmount) external;


    function redeem(address from, uint256 redeemTokens) external;


    function redeemUnderlying(address from, uint256 redeemAmount) external;


    function borrow(uint256 borrowAmount) external;


    function repayBorrow(uint256 repayAmount) external;


    function repayBorrowBehalf(address borrower, uint256 repayAmount) external;


    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        address iTokenCollateral
    ) external;


    function flashloan(
        address recipient,
        uint256 loanAmount,
        bytes memory data
    ) external;


    function seize(
        address _liquidator,
        address _borrower,
        uint256 _seizeTokens
    ) external;


    function updateInterest() external returns (bool);


    function controller() external view returns (address);


    function exchangeRateCurrent() external returns (uint256);


    function exchangeRateStored() external view returns (uint256);


    function totalBorrowsCurrent() external returns (uint256);


    function totalBorrows() external view returns (uint256);


    function borrowBalanceCurrent(address _user) external returns (uint256);


    function borrowBalanceStored(address _user) external view returns (uint256);


    function borrowIndex() external view returns (uint256);


    function getAccountSnapshot(address _account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function borrowRatePerBlock() external view returns (uint256);


    function supplyRatePerBlock() external view returns (uint256);


    function getCash() external view returns (uint256);



    function _setNewReserveRatio(uint256 _newReserveRatio) external;


    function _setNewFlashloanFeeRatio(uint256 _newFlashloanFeeRatio) external;


    function _setNewProtocolFeeRatio(uint256 _newProtocolFeeRatio) external;


    function _setController(IControllerInterface _newController) external;


    function _setInterestRateModel(
        IInterestRateModelInterface _newInterestRateModel
    ) external;


    function _withdrawReserves(uint256 _withdrawAmount) external;

}




            

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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




            

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




            

pragma solidity 0.6.12;


library SafeRatioMath {

    using SafeMathUpgradeable for uint256;

    uint256 private constant BASE = 10**18;
    uint256 private constant DOUBLE = 10**36;

    function divup(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x.add(y.sub(1)).div(y);
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x.mul(y).div(BASE);
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x.mul(BASE).div(y);
    }

    function rdivup(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x.mul(BASE).add(y.sub(1)).div(y);
    }

    function tmul(
        uint256 x,
        uint256 y,
        uint256 z
    ) internal pure returns (uint256 result) {

        result = x.mul(y).mul(z).div(DOUBLE);
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 base
    ) internal pure returns (uint256 z) {

        assembly {
            switch x
                case 0 {
                    switch n
                        case 0 {
                            z := base
                        }
                        default {
                            z := 0
                        }
                }
                default {
                    switch mod(n, 2)
                        case 0 {
                            z := base
                        }
                        default {
                            z := x
                        }
                    let half := div(base, 2) // for rounding.

                    for {
                        n := div(n, 2)
                    } n {
                        n := div(n, 2)
                    } {
                        let xx := mul(x, x)
                        if iszero(eq(div(xx, x), x)) {
                            revert(0, 0)
                        }
                        let xxRound := add(xx, half)
                        if lt(xxRound, xx) {
                            revert(0, 0)
                        }
                        x := div(xxRound, base)
                        if mod(n, 2) {
                            let zx := mul(z, x)
                            if and(
                                iszero(iszero(x)),
                                iszero(eq(div(zx, x), z))
                            ) {
                                revert(0, 0)
                            }
                            let zxRound := add(zx, half)
                            if lt(zxRound, zx) {
                                revert(0, 0)
                            }
                            z := div(zxRound, base)
                        }
                    }
                }
        }
    }
}




            

pragma solidity 0.6.12;

contract Ownable {

    address payable public owner;

    address payable public pendingOwner;

    event NewOwner(address indexed previousOwner, address indexed newOwner);
    event NewPendingOwner(
        address indexed oldPendingOwner,
        address indexed newPendingOwner
    );

    modifier onlyOwner() {

        require(owner == msg.sender, "onlyOwner: caller is not the owner");
        _;
    }

    function __Ownable_init() internal {

        owner = msg.sender;
        emit NewOwner(address(0), msg.sender);
    }

    function _setPendingOwner(address payable newPendingOwner)
        external
        onlyOwner
    {

        require(
            newPendingOwner != address(0) && newPendingOwner != pendingOwner,
            "_setPendingOwner: New owenr can not be zero address and owner has been set!"
        );

        address oldPendingOwner = pendingOwner;

        pendingOwner = newPendingOwner;

        emit NewPendingOwner(oldPendingOwner, newPendingOwner);
    }

    function _acceptOwner() external {

        require(
            msg.sender == pendingOwner,
            "_acceptOwner: Only for pending owner!"
        );

        address oldOwner = owner;
        address oldPendingOwner = pendingOwner;

        owner = pendingOwner;

        pendingOwner = address(0);

        emit NewOwner(oldOwner, owner);
        emit NewPendingOwner(oldPendingOwner, pendingOwner);
    }

    uint256[50] private __gap;
}




            
pragma solidity 0.6.12;

abstract contract Initializable {
    bool private _initialized;

    modifier initializer() {
        require(
            !_initialized,
            "Initializable: contract is already initialized"
        );

        _;

        _initialized = true;
    }
}




            

pragma solidity 0.6.12;

interface IRewardDistributor {

    function _setRewardToken(address newRewardToken) external;


    event NewRewardToken(address oldRewardToken, address newRewardToken);

    function _addRecipient(address _iToken, uint256 _distributionFactor)
        external;


    event NewRecipient(address iToken, uint256 distributionFactor);

    event Paused(bool paused);

    function _pause() external;


    function _unpause(uint256 _borrowSpeed, uint256 _supplySpeed) external;


    event GlobalDistributionSpeedsUpdated(
        uint256 borrowSpeed,
        uint256 supplySpeed
    );

    function _setGlobalDistributionSpeeds(
        uint256 borrowSpeed,
        uint256 supplySpeed
    ) external;


    event DistributionSpeedsUpdated(
        address iToken,
        uint256 borrowSpeed,
        uint256 supplySpeed
    );

    function updateDistributionSpeed() external;


    event NewDistributionFactor(
        address iToken,
        uint256 oldDistributionFactorMantissa,
        uint256 newDistributionFactorMantissa
    );

    function _setDistributionFactors(
        address[] calldata iToken,
        uint256[] calldata distributionFactors
    ) external;


    function updateDistributionState(address _iToken, bool _isBorrow) external;


    function updateReward(
        address _iToken,
        address _account,
        bool _isBorrow
    ) external;


    function updateRewardBatch(
        address[] memory _holders,
        address[] memory _iTokens
    ) external;


    function claimReward(address[] memory _holders, address[] memory _iTokens)
        external;


    function claimAllReward(address[] memory _holders) external;


    event RewardDistributed(
        address iToken,
        address account,
        uint256 amount,
        uint256 accountIndex
    );
}




            

pragma solidity 0.6.12;


interface IPriceOracle {

    function getUnderlyingPrice(address _iToken)
        external
        view
        returns (uint256);


    function getUnderlyingPriceAndStatus(address _iToken)
        external
        view
        returns (uint256, bool);

}




            

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSetUpgradeable {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
}




            

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity 0.6.12;




contract Controller is Initializable, Ownable, IControllerInterface {

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using SafeRatioMath for uint256;
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    EnumerableSetUpgradeable.AddressSet internal iTokens;

    struct Market {
        uint256 collateralFactorMantissa;
        uint256 borrowFactorMantissa;
        uint256 borrowCapacity;
        uint256 supplyCapacity;
        bool mintPaused;
        bool redeemPaused;
        bool borrowPaused;
    }

    mapping(address => Market) public markets;

    struct AccountData {
        EnumerableSetUpgradeable.AddressSet collaterals;
        EnumerableSetUpgradeable.AddressSet borrowed;
    }

    mapping(address => AccountData) internal accountsData;

    address public priceOracle;

    uint256 public closeFactorMantissa;

    uint256 internal constant closeFactorMinMantissa = 0.05e18; // 0.05

    uint256 internal constant closeFactorMaxMantissa = 0.9e18; // 0.9

    uint256 public liquidationIncentiveMantissa;

    uint256 internal constant liquidationIncentiveMinMantissa = 1.0e18; // 1.0

    uint256 internal constant liquidationIncentiveMaxMantissa = 1.5e18; // 1.5

    uint256 internal constant collateralFactorMaxMantissa = 1e18; // 1.0

    uint256 internal constant borrowFactorMaxMantissa = 1e18; // 1.0

    address public pauseGuardian;

    bool public transferPaused;

    bool public seizePaused;

    address public override rewardDistributor;

    modifier checkPauser(bool _paused) {

        require(
            msg.sender == owner || (msg.sender == pauseGuardian && _paused),
            "Only owner and guardian can pause and only owner can unpause"
        );

        _;
    }

    function initialize() external initializer {

        __Ownable_init();
    }


    function isController() external view override returns (bool) {

        return true;
    }


    function _addMarket(
        address _iToken,
        uint256 _collateralFactor,
        uint256 _borrowFactor,
        uint256 _supplyCapacity,
        uint256 _borrowCapacity,
        uint256 _distributionFactor
    ) external override onlyOwner {

        require(IiToken(_iToken).isSupported(), "Token is not supported");
    
        require(
            IiToken(_iToken).controller() == address(this),
            "Token's controller is not this one"
        );

        require(iTokens.add(_iToken), "Token has already been listed");

        require(
            _collateralFactor <= collateralFactorMaxMantissa,
            "Collateral factor invalid"
        );

        require(
            _borrowFactor > 0 && _borrowFactor <= borrowFactorMaxMantissa,
            "Borrow factor invalid"
        );

        require(
            IPriceOracle(priceOracle).getUnderlyingPrice(_iToken) != 0,
            "Underlying price is unavailable"
        );

        markets[_iToken] = Market({
            collateralFactorMantissa: _collateralFactor,
            borrowFactorMantissa: _borrowFactor,
            borrowCapacity: _borrowCapacity,
            supplyCapacity: _supplyCapacity,
            mintPaused: false,
            redeemPaused: false,
            borrowPaused: false
        });

        IRewardDistributor(rewardDistributor)._addRecipient(
            _iToken,
            _distributionFactor
        );

        emit MarketAdded(
            _iToken,
            _collateralFactor,
            _borrowFactor,
            _supplyCapacity,
            _borrowCapacity,
            _distributionFactor
        );
    }

    function _setPriceOracle(address _newOracle) external override onlyOwner {

        address _oldOracle = priceOracle;
        require(
            _newOracle != address(0) && _newOracle != _oldOracle,
            "Oracle address invalid"
        );
        priceOracle = _newOracle;
        emit NewPriceOracle(_oldOracle, _newOracle);
    }

    function _setCloseFactor(uint256 _newCloseFactorMantissa)
        external
        override
        onlyOwner
    {

        require(
            _newCloseFactorMantissa >= closeFactorMinMantissa &&
                _newCloseFactorMantissa <= closeFactorMaxMantissa,
            "Close factor invalid"
        );

        uint256 _oldCloseFactorMantissa = closeFactorMantissa;
        closeFactorMantissa = _newCloseFactorMantissa;
        emit NewCloseFactor(_oldCloseFactorMantissa, _newCloseFactorMantissa);
    }

    function _setLiquidationIncentive(uint256 _newLiquidationIncentiveMantissa)
        external
        override
        onlyOwner
    {

        require(
            _newLiquidationIncentiveMantissa >=
                liquidationIncentiveMinMantissa &&
                _newLiquidationIncentiveMantissa <=
                liquidationIncentiveMaxMantissa,
            "Liquidation incentive invalid"
        );

        uint256 _oldLiquidationIncentiveMantissa = liquidationIncentiveMantissa;
        liquidationIncentiveMantissa = _newLiquidationIncentiveMantissa;

        emit NewLiquidationIncentive(
            _oldLiquidationIncentiveMantissa,
            _newLiquidationIncentiveMantissa
        );
    }

    function _setCollateralFactor(
        address _iToken,
        uint256 _newCollateralFactorMantissa
    ) external override onlyOwner {

        _checkiTokenListed(_iToken);

        require(
            _newCollateralFactorMantissa <= collateralFactorMaxMantissa,
            "Collateral factor invalid"
        );

        require(
            IPriceOracle(priceOracle).getUnderlyingPrice(_iToken) != 0,
            "Failed to set collateral factor, underlying price is unavailable"
        );

        Market storage _market = markets[_iToken];
        uint256 _oldCollateralFactorMantissa = _market.collateralFactorMantissa;
        _market.collateralFactorMantissa = _newCollateralFactorMantissa;

        emit NewCollateralFactor(
            _iToken,
            _oldCollateralFactorMantissa,
            _newCollateralFactorMantissa
        );
    }

    function _setBorrowFactor(address _iToken, uint256 _newBorrowFactorMantissa)
        external
        override
        onlyOwner
    {

        _checkiTokenListed(_iToken);

        require(
            _newBorrowFactorMantissa > 0 &&
                _newBorrowFactorMantissa <= borrowFactorMaxMantissa,
            "Borrow factor invalid"
        );

        require(
            IPriceOracle(priceOracle).getUnderlyingPrice(_iToken) != 0,
            "Failed to set borrow factor, underlying price is unavailable"
        );

        Market storage _market = markets[_iToken];
        uint256 _oldBorrowFactorMantissa = _market.borrowFactorMantissa;
        _market.borrowFactorMantissa = _newBorrowFactorMantissa;

        emit NewBorrowFactor(
            _iToken,
            _oldBorrowFactorMantissa,
            _newBorrowFactorMantissa
        );
    }

    function _setBorrowCapacity(address _iToken, uint256 _newBorrowCapacity)
        external
        override
        onlyOwner
    {

        _checkiTokenListed(_iToken);

        Market storage _market = markets[_iToken];
        uint256 oldBorrowCapacity = _market.borrowCapacity;
        _market.borrowCapacity = _newBorrowCapacity;

        emit NewBorrowCapacity(_iToken, oldBorrowCapacity, _newBorrowCapacity);
    }

    function _setSupplyCapacity(address _iToken, uint256 _newSupplyCapacity)
        external
        override
        onlyOwner
    {

        _checkiTokenListed(_iToken);

        Market storage _market = markets[_iToken];
        uint256 oldSupplyCapacity = _market.supplyCapacity;
        _market.supplyCapacity = _newSupplyCapacity;

        emit NewSupplyCapacity(_iToken, oldSupplyCapacity, _newSupplyCapacity);
    }

    function _setPauseGuardian(address _newPauseGuardian)
        external
        override
        onlyOwner
    {

        address _oldPauseGuardian = pauseGuardian;

        require(
            _newPauseGuardian != address(0) &&
                _newPauseGuardian != _oldPauseGuardian,
            "Pause guardian address invalid"
        );

        pauseGuardian = _newPauseGuardian;

        emit NewPauseGuardian(_oldPauseGuardian, _newPauseGuardian);
    }

    function _setAllMintPaused(bool _paused)
        external
        override
        checkPauser(_paused)
    {

        EnumerableSetUpgradeable.AddressSet storage _iTokens = iTokens;
        uint256 _len = _iTokens.length();

        for (uint256 i = 0; i < _len; i++) {
            _setMintPausedInternal(_iTokens.at(i), _paused);
        }
    }

    function _setMintPaused(address _iToken, bool _paused)
        external
        override
        checkPauser(_paused)
    {

        _checkiTokenListed(_iToken);

        _setMintPausedInternal(_iToken, _paused);
    }

    function _setMintPausedInternal(address _iToken, bool _paused) internal {

        markets[_iToken].mintPaused = _paused;
        emit MintPaused(_iToken, _paused);
    }

    function _setAllRedeemPaused(bool _paused)
        external
        override
        checkPauser(_paused)
    {

        EnumerableSetUpgradeable.AddressSet storage _iTokens = iTokens;
        uint256 _len = _iTokens.length();

        for (uint256 i = 0; i < _len; i++) {
            _setRedeemPausedInternal(_iTokens.at(i), _paused);
        }
    }

    function _setRedeemPaused(address _iToken, bool _paused)
        external
        override
        checkPauser(_paused)
    {

        _checkiTokenListed(_iToken);

        _setRedeemPausedInternal(_iToken, _paused);
    }

    function _setRedeemPausedInternal(address _iToken, bool _paused) internal {

        markets[_iToken].redeemPaused = _paused;
        emit RedeemPaused(_iToken, _paused);
    }

    function _setAllBorrowPaused(bool _paused)
        external
        override
        checkPauser(_paused)
    {

        EnumerableSetUpgradeable.AddressSet storage _iTokens = iTokens;
        uint256 _len = _iTokens.length();

        for (uint256 i = 0; i < _len; i++) {
            _setBorrowPausedInternal(_iTokens.at(i), _paused);
        }
    }

    function _setBorrowPaused(address _iToken, bool _paused)
        external
        override
        checkPauser(_paused)
    {

        _checkiTokenListed(_iToken);

        _setBorrowPausedInternal(_iToken, _paused);
    }

    function _setBorrowPausedInternal(address _iToken, bool _paused) internal {

        markets[_iToken].borrowPaused = _paused;
        emit BorrowPaused(_iToken, _paused);
    }

    function _setTransferPaused(bool _paused)
        external
        override
        checkPauser(_paused)
    {

        _setTransferPausedInternal(_paused);
    }

    function _setTransferPausedInternal(bool _paused) internal {

        transferPaused = _paused;
        emit TransferPaused(_paused);
    }

    function _setSeizePaused(bool _paused)
        external
        override
        checkPauser(_paused)
    {

        _setSeizePausedInternal(_paused);
    }

    function _setSeizePausedInternal(bool _paused) internal {

        seizePaused = _paused;
        emit SeizePaused(_paused);
    }

    function _setiTokenPaused(address _iToken, bool _paused)
        external
        override
        checkPauser(_paused)
    {

        _checkiTokenListed(_iToken);

        _setiTokenPausedInternal(_iToken, _paused);
    }

    function _setiTokenPausedInternal(address _iToken, bool _paused) internal {

        Market storage _market = markets[_iToken];

        _market.mintPaused = _paused;
        emit MintPaused(_iToken, _paused);

        _market.redeemPaused = _paused;
        emit RedeemPaused(_iToken, _paused);

        _market.borrowPaused = _paused;
        emit BorrowPaused(_iToken, _paused);
    }

    function _setProtocolPaused(bool _paused)
        external
        override
        checkPauser(_paused)
    {

        EnumerableSetUpgradeable.AddressSet storage _iTokens = iTokens;
        uint256 _len = _iTokens.length();

        for (uint256 i = 0; i < _len; i++) {
            address _iToken = _iTokens.at(i);

            _setiTokenPausedInternal(_iToken, _paused);
        }

        _setTransferPausedInternal(_paused);
        _setSeizePausedInternal(_paused);
    }

    function _setRewardDistributor(address _newRewardDistributor)
        external
        override
        onlyOwner
    {

        address _oldRewardDistributor = rewardDistributor;
        require(
            _newRewardDistributor != address(0) &&
                _newRewardDistributor != _oldRewardDistributor,
            "Reward Distributor address invalid"
        );

        rewardDistributor = _newRewardDistributor;
        emit NewRewardDistributor(_oldRewardDistributor, _newRewardDistributor);
    }


    function beforeMint(
        address _iToken,
        address _minter,
        uint256 _mintAmount
    ) external override {

        _checkiTokenListed(_iToken);

        Market storage _market = markets[_iToken];
        require(!_market.mintPaused, "Token mint has been paused");

        uint256 _totalSupplyUnderlying =
            IERC20Upgradeable(_iToken).totalSupply().rmul(
                IiToken(_iToken).exchangeRateStored()
            );
        require(
            _totalSupplyUnderlying.add(_mintAmount) <= _market.supplyCapacity,
            "Token supply capacity reached"
        );

        IRewardDistributor(rewardDistributor).updateDistributionState(
            _iToken,
            false
        );
        IRewardDistributor(rewardDistributor).updateReward(
            _iToken,
            _minter,
            false
        );
    }

    function afterMint(
        address _iToken,
        address _minter,
        uint256 _mintAmount,
        uint256 _mintedAmount
    ) external override {

        _iToken;
        _minter;
        _mintAmount;
        _mintedAmount;
    }

    function beforeRedeem(
        address _iToken,
        address _redeemer,
        uint256 _redeemAmount
    ) external virtual override {


        require(!markets[_iToken].redeemPaused, "Token redeem has been paused");

        _redeemAllowed(_iToken, _redeemer, _redeemAmount);

        IRewardDistributor(rewardDistributor).updateDistributionState(
            _iToken,
            false
        );
        IRewardDistributor(rewardDistributor).updateReward(
            _iToken,
            _redeemer,
            false
        );
    }

    function afterRedeem(
        address _iToken,
        address _redeemer,
        uint256 _redeemAmount,
        uint256 _redeemedUnderlying
    ) external virtual override {

        _iToken;
        _redeemer;
        _redeemAmount;
        _redeemedUnderlying;
    }

    function beforeBorrow(
        address _iToken,
        address _borrower,
        uint256 _borrowAmount
    ) external virtual override {

        _checkiTokenListed(_iToken);

        Market storage _market = markets[_iToken];
        require(!_market.borrowPaused, "Token borrow has been paused");

        if (!hasBorrowed(_borrower, _iToken)) {
            require(msg.sender == _iToken, "sender must be iToken");

            _addToBorrowed(_borrower, _iToken);
        }

        (, uint256 _shortfall, , ) =
            calcAccountEquityWithEffect(_borrower, _iToken, 0, _borrowAmount);

        require(_shortfall == 0, "Account has some shortfall");

        uint256 _totalBorrows = IiToken(_iToken).totalBorrows();
        require(
            _totalBorrows.add(_borrowAmount) <= _market.borrowCapacity,
            "Token borrow capacity reached"
        );

        IRewardDistributor(rewardDistributor).updateDistributionState(
            _iToken,
            true
        );
        IRewardDistributor(rewardDistributor).updateReward(
            _iToken,
            _borrower,
            true
        );
    }

    function afterBorrow(
        address _iToken,
        address _borrower,
        uint256 _borrowedAmount
    ) external virtual override {

        _iToken;
        _borrower;
        _borrowedAmount;
    }

    function beforeRepayBorrow(
        address _iToken,
        address _payer,
        address _borrower,
        uint256 _repayAmount
    ) external override {

        _checkiTokenListed(_iToken);

        IRewardDistributor(rewardDistributor).updateDistributionState(
            _iToken,
            true
        );
        IRewardDistributor(rewardDistributor).updateReward(
            _iToken,
            _borrower,
            true
        );

        _payer;
        _repayAmount;
    }

    function afterRepayBorrow(
        address _iToken,
        address _payer,
        address _borrower,
        uint256 _repayAmount
    ) external override {

        _checkiTokenListed(_iToken);

        if (IiToken(_iToken).borrowBalanceStored(_borrower) == 0) {
            require(msg.sender == _iToken, "sender must be iToken");

            _removeFromBorrowed(_borrower, _iToken);
        }

        _payer;
        _repayAmount;
    }

    function beforeLiquidateBorrow(
        address _iTokenBorrowed,
        address _iTokenCollateral,
        address _liquidator,
        address _borrower,
        uint256 _repayAmount
    ) external override {

        require(
            iTokens.contains(_iTokenBorrowed) &&
                iTokens.contains(_iTokenCollateral),
            "Tokens have not been listed"
        );

        (, uint256 _shortfall, , ) = calcAccountEquity(_borrower);

        require(_shortfall > 0, "Account does not have shortfall");

        uint256 _borrowBalance =
            IiToken(_iTokenBorrowed).borrowBalanceStored(_borrower);
        uint256 _maxRepay = _borrowBalance.rmul(closeFactorMantissa);

        require(_repayAmount <= _maxRepay, "Repay exceeds max repay allowed");

        _liquidator;
    }

    function afterLiquidateBorrow(
        address _iTokenBorrowed,
        address _iTokenCollateral,
        address _liquidator,
        address _borrower,
        uint256 _repaidAmount,
        uint256 _seizedAmount
    ) external override {

        _iTokenBorrowed;
        _iTokenCollateral;
        _liquidator;
        _borrower;
        _repaidAmount;
        _seizedAmount;

    }

    function beforeSeize(
        address _iTokenCollateral,
        address _iTokenBorrowed,
        address _liquidator,
        address _borrower,
        uint256 _seizeAmount
    ) external override {

        require(!seizePaused, "Seize has been paused");

        require(
            iTokens.contains(_iTokenBorrowed) &&
                iTokens.contains(_iTokenCollateral),
            "Tokens have not been listed"
        );

        require(
            IiToken(_iTokenBorrowed).controller() ==
                IiToken(_iTokenCollateral).controller(),
            "Controller mismatch between Borrowed and Collateral"
        );

        IRewardDistributor(rewardDistributor).updateDistributionState(
            _iTokenCollateral,
            false
        );

        IRewardDistributor(rewardDistributor).updateReward(
            _iTokenCollateral,
            _liquidator,
            false
        );
        IRewardDistributor(rewardDistributor).updateReward(
            _iTokenCollateral,
            _borrower,
            false
        );

        _seizeAmount;
    }

    function afterSeize(
        address _iTokenCollateral,
        address _iTokenBorrowed,
        address _liquidator,
        address _borrower,
        uint256 _seizedAmount
    ) external override {

        _iTokenBorrowed;
        _iTokenCollateral;
        _liquidator;
        _borrower;
        _seizedAmount;
    }

    function beforeTransfer(
        address _iToken,
        address _from,
        address _to,
        uint256 _amount
    ) external override {


        require(!transferPaused, "Transfer has been paused");

        _redeemAllowed(_iToken, _from, _amount);

        IRewardDistributor(rewardDistributor).updateDistributionState(
            _iToken,
            false
        );

        IRewardDistributor(rewardDistributor).updateReward(
            _iToken,
            _from,
            false
        );
        IRewardDistributor(rewardDistributor).updateReward(_iToken, _to, false);
    }

    function afterTransfer(
        address _iToken,
        address _from,
        address _to,
        uint256 _amount
    ) external override {

        _iToken;
        _from;
        _to;
        _amount;
    }

    function beforeFlashloan(
        address _iToken,
        address _to,
        uint256 _amount
    ) external override {

        require(!markets[_iToken].borrowPaused, "Token borrow has been paused");

        _checkiTokenListed(_iToken);

        _to;
        _amount;

        IRewardDistributor(rewardDistributor).updateDistributionState(
            _iToken,
            true
        );
    }

    function afterFlashloan(
        address _iToken,
        address _to,
        uint256 _amount
    ) external override {

        _iToken;
        _to;
        _amount;
    }


    function _redeemAllowed(
        address _iToken,
        address _redeemer,
        uint256 _amount
    ) private view {

        _checkiTokenListed(_iToken);

        if (!accountsData[_redeemer].collaterals.contains(_iToken)) {
            return;
        }

        (, uint256 _shortfall, , ) =
            calcAccountEquityWithEffect(_redeemer, _iToken, _amount, 0);

        require(_shortfall == 0, "Account has some shortfall");
    }

    function _checkiTokenListed(address _iToken) internal view {

        require(iTokens.contains(_iToken), "Token has not been listed");
    }


    function calcAccountEquity(address _account)
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        return calcAccountEquityWithEffect(_account, address(0), 0, 0);
    }

    struct AccountEquityLocalVars {
        uint256 sumCollateral;
        uint256 sumBorrowed;
        uint256 iTokenBalance;
        uint256 borrowBalance;
        uint256 exchangeRateMantissa;
        uint256 underlyingPrice;
        uint256 collateralValue;
        uint256 borrowValue;
    }

    function calcAccountEquityWithEffect(
        address _account,
        address _tokenToEffect,
        uint256 _redeemAmount,
        uint256 _borrowAmount
    )
        internal
        view
        virtual
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        AccountEquityLocalVars memory _local;
        AccountData storage _accountData = accountsData[_account];

        uint256 _len = _accountData.collaterals.length();
        for (uint256 i = 0; i < _len; i++) {
            IiToken _token = IiToken(_accountData.collaterals.at(i));

            _local.iTokenBalance = IERC20Upgradeable(address(_token)).balanceOf(
                _account
            );
            _local.exchangeRateMantissa = _token.exchangeRateStored();

            if (_tokenToEffect == address(_token) && _redeemAmount > 0) {
                _local.iTokenBalance = _local.iTokenBalance.sub(_redeemAmount);
            }

            _local.underlyingPrice = IPriceOracle(priceOracle)
                .getUnderlyingPrice(address(_token));

            require(
                _local.underlyingPrice != 0,
                "Invalid price to calculate account equity"
            );

            _local.collateralValue = _local
                .iTokenBalance
                .mul(_local.underlyingPrice)
                .rmul(_local.exchangeRateMantissa)
                .rmul(markets[address(_token)].collateralFactorMantissa);

            _local.sumCollateral = _local.sumCollateral.add(
                _local.collateralValue
            );
        }

        _len = _accountData.borrowed.length();
        for (uint256 i = 0; i < _len; i++) {
            IiToken _token = IiToken(_accountData.borrowed.at(i));

            _local.borrowBalance = _token.borrowBalanceStored(_account);

            if (_tokenToEffect == address(_token) && _borrowAmount > 0) {
                _local.borrowBalance = _local.borrowBalance.add(_borrowAmount);
            }

            _local.underlyingPrice = IPriceOracle(priceOracle)
                .getUnderlyingPrice(address(_token));

            require(
                _local.underlyingPrice != 0,
                "Invalid price to calculate account equity"
            );

            _local.borrowValue = _local
                .borrowBalance
                .mul(_local.underlyingPrice)
                .rdiv(markets[address(_token)].borrowFactorMantissa);

            _local.sumBorrowed = _local.sumBorrowed.add(_local.borrowValue);
        }

        return
            _local.sumCollateral > _local.sumBorrowed
                ? (
                    _local.sumCollateral - _local.sumBorrowed,
                    uint256(0),
                    _local.sumCollateral,
                    _local.sumBorrowed
                )
                : (
                    uint256(0),
                    _local.sumBorrowed - _local.sumCollateral,
                    _local.sumCollateral,
                    _local.sumBorrowed
                );
    }

    function liquidateCalculateSeizeTokens(
        address _iTokenBorrowed,
        address _iTokenCollateral,
        uint256 _actualRepayAmount
    ) external view virtual override returns (uint256 _seizedTokenCollateral) {

        uint256 _priceBorrowed =
            IPriceOracle(priceOracle).getUnderlyingPrice(_iTokenBorrowed);
        uint256 _priceCollateral =
            IPriceOracle(priceOracle).getUnderlyingPrice(_iTokenCollateral);
        require(
            _priceBorrowed != 0 && _priceCollateral != 0,
            "Borrowed or Collateral asset price is invalid"
        );

        uint256 _valueRepayPlusIncentive =
            _actualRepayAmount.mul(_priceBorrowed).rmul(
                liquidationIncentiveMantissa
            );

        uint256 _exchangeRateMantissa =
            IiToken(_iTokenCollateral).exchangeRateStored();

        _seizedTokenCollateral = _valueRepayPlusIncentive
            .rdiv(_exchangeRateMantissa)
            .div(_priceCollateral);
    }


    function getEnteredMarkets(address _account)
        external
        view
        override
        returns (address[] memory _accountCollaterals)
    {

        AccountData storage _accountData = accountsData[_account];

        uint256 _len = _accountData.collaterals.length();
        _accountCollaterals = new address[](_len);
        for (uint256 i = 0; i < _len; i++) {
            _accountCollaterals[i] = _accountData.collaterals.at(i);
        }
    }

    function enterMarkets(address[] calldata _iTokens)
        external
        override
        returns (bool[] memory _results)
    {

        uint256 _len = _iTokens.length;

        _results = new bool[](_len);
        for (uint256 i = 0; i < _len; i++) {
            _results[i] = _enterMarket(_iTokens[i], msg.sender);
        }
    }

    function _enterMarket(address _iToken, address _account)
        internal
        returns (bool)
    {

        if (!iTokens.contains(_iToken)) {
            return false;
        }

        if (accountsData[_account].collaterals.add(_iToken)) {
            emit MarketEntered(_iToken, _account);
        }

        return true;
    }

    function enterMarketFromiToken(address _market, address _account)
        external
        override
    {

        _checkiTokenListed(msg.sender);

        require(
            _enterMarket(_market, _account),
            "enterMarketFromiToken: Only can enter a listed market!"
        );
    }

    function hasEnteredMarket(address _account, address _iToken)
        external
        view
        override
        returns (bool)
    {

        return accountsData[_account].collaterals.contains(_iToken);
    }

    function exitMarkets(address[] calldata _iTokens)
        external
        override
        returns (bool[] memory _results)
    {

        uint256 _len = _iTokens.length;
        _results = new bool[](_len);
        for (uint256 i = 0; i < _len; i++) {
            _results[i] = _exitMarket(_iTokens[i], msg.sender);
        }
    }

    function _exitMarket(address _iToken, address _account)
        internal
        returns (bool)
    {

        if (!iTokens.contains(_iToken)) {
            return true;
        }

        if (!accountsData[_account].collaterals.contains(_iToken)) {
            return true;
        }

        uint256 _balance = IERC20Upgradeable(_iToken).balanceOf(_account);

        _redeemAllowed(_iToken, _account, _balance);

        accountsData[_account].collaterals.remove(_iToken);

        emit MarketExited(_iToken, _account);

        return true;
    }

    function getBorrowedAssets(address _account)
        external
        view
        override
        returns (address[] memory _borrowedAssets)
    {

        AccountData storage _accountData = accountsData[_account];

        uint256 _len = _accountData.borrowed.length();
        _borrowedAssets = new address[](_len);
        for (uint256 i = 0; i < _len; i++) {
            _borrowedAssets[i] = _accountData.borrowed.at(i);
        }
    }

    function _addToBorrowed(address _account, address _iToken) internal {

        if (accountsData[_account].borrowed.add(_iToken)) {
            emit BorrowedAdded(_iToken, _account);
        }
    }

    function hasBorrowed(address _account, address _iToken)
        public
        view
        override
        returns (bool)
    {

        return accountsData[_account].borrowed.contains(_iToken);
    }

    function _removeFromBorrowed(address _account, address _iToken) internal {

        if (accountsData[_account].borrowed.remove(_iToken)) {
            emit BorrowedRemoved(_iToken, _account);
        }
    }


    function getAlliTokens()
        public
        view
        override
        returns (address[] memory _alliTokens)
    {

        EnumerableSetUpgradeable.AddressSet storage _iTokens = iTokens;

        uint256 _len = _iTokens.length();
        _alliTokens = new address[](_len);
        for (uint256 i = 0; i < _len; i++) {
            _alliTokens[i] = _iTokens.at(i);
        }
    }

    function hasiToken(address _iToken) public view override returns (bool) {

        return iTokens.contains(_iToken);
    }
}