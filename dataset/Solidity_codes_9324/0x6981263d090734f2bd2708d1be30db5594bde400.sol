

pragma experimental ABIEncoderV2;



pragma solidity ^0.5.0;

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


library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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




interface ISyntheticToken {


    function symbolKey()
        external
        view
        returns (bytes32);


    function mint(
        address to,
        uint256 value
    )
        external;


    function burn(
        address to,
        uint256 value
    )
        external;


    function transferCollateral(
        address token,
        address to,
        uint256 value
    )
        external
        returns (bool);



}




interface IMintableToken {


    function mint(
        address to,
        uint256 value
    )
        external;


    function burn(
        address to,
        uint256 value
    )
        external;


}




library Math {

    using SafeMath for uint256;


    function getPartial(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (uint256)
    {

        return target.mul(numerator).div(denominator);
    }

    function to128(
        uint256 number
    )
        internal
        pure
        returns (uint128)
    {

        uint128 result = uint128(number);
        require(
            result == number,
            "Math: Unsafe cast to uint128"
        );
        return result;
    }

    function to96(
        uint256 number
    )
        internal
        pure
        returns (uint96)
    {

        uint96 result = uint96(number);
        require(
            result == number,
            "Math: Unsafe cast to uint96"
        );
        return result;
    }

    function to32(
        uint256 number
    )
        internal
        pure
        returns (uint32)
    {

        uint32 result = uint32(number);
        require(
            result == number,
            "Math: Unsafe cast to uint32"
        );
        return result;
    }

    function min(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return a < b ? a : b;
    }

    function max(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return a > b ? a : b;
    }
}



library Decimal {

    using SafeMath for uint256;


    uint256 constant BASE = 10**18;


    struct D256 {
        uint256 value;
    }


    function one()
        internal
        pure
        returns (D256 memory)
    {

        return D256({ value: BASE });
    }

    function onePlus(
        D256 memory d
    )
        internal
        pure
        returns (D256 memory)
    {

        return D256({ value: d.value.add(BASE) });
    }

    function mul(
        uint256 target,
        D256 memory d
    )
        internal
        pure
        returns (uint256)
    {

        return Math.getPartial(target, d.value, BASE);
    }

    function mul(
        D256 memory d1,
        D256 memory d2
    )
        internal
        pure
        returns (D256 memory)
    {

        return Decimal.D256({ value: Math.getPartial(d1.value, d2.value, BASE) });
    }

    function div(
        uint256 target,
        D256 memory d
    )
        internal
        pure
        returns (uint256)
    {

        return Math.getPartial(target, BASE, d.value);
    }

    function add(
        D256 memory d,
        uint256 amount
    )
        internal
        pure
        returns (D256 memory)
    {

        return D256({ value: d.value.add(amount) });
    }

    function sub(
        D256 memory d,
        uint256 amount
    )
        internal
        pure
        returns (D256 memory)
    {

        return D256({ value: d.value.sub(amount) });
    }

}



interface IOracle {


    function fetchCurrentPrice()
        external
        view
        returns (Decimal.D256 memory);


}




library TypesV1 {


    using Math for uint256;
    using SafeMath for uint256;


    enum AssetType {
        Collateral,
        Synthetic
    }


    struct MarketParams {
        Decimal.D256 collateralRatio;
        Decimal.D256 liquidationUserFee;
        Decimal.D256 liquidationArcFee;
    }

    struct Position {
        address owner;
        AssetType collateralAsset;
        AssetType borrowedAsset;
        Par collateralAmount;
        Par borrowedAmount;
    }

    struct RiskParams {
        uint256 collateralLimit;
        uint256 syntheticLimit;
        uint256 positionCollateralMinimum;
    }


    enum AssetDenomination {
        Wei, // the amount is denominated in wei
        Par  // the amount is denominated in par
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


    function oppositeAsset(
        AssetType assetType
    )
        internal
        pure
        returns (AssetType)
    {

        return assetType == AssetType.Collateral ? AssetType.Synthetic : AssetType.Collateral;
    }


    struct Par {
        bool sign; // true if positive
        uint128 value;
    }

    function zeroPar()
        internal
        pure
        returns (Par memory)
    {

        return Par({
            sign: false,
            value: 0
        });
    }

    function positiveZeroPar()
        internal
        pure
        returns (Par memory)
    {

        return Par({
            sign: true,
            value: 0
        });
    }

    function sub(
        Par memory a,
        Par memory b
    )
        internal
        pure
        returns (Par memory)
    {

        return add(a, negative(b));
    }

    function add(
        Par memory a,
        Par memory b
    )
        internal
        pure
        returns (Par memory)
    {

        Par memory result;
        if (a.sign == b.sign) {
            result.sign = a.sign;
            result.value = SafeMath.add(a.value, b.value).to128();
        } else {
            if (a.value >= b.value) {
                result.sign = a.sign;
                result.value = SafeMath.sub(a.value, b.value).to128();
            } else {
                result.sign = b.sign;
                result.value = SafeMath.sub(b.value, a.value).to128();
            }
        }
        return result;
    }

    function equals(
        Par memory a,
        Par memory b
    )
        internal
        pure
        returns (bool)
    {

        if (a.value == b.value) {
            if (a.value == 0) {
                return true;
            }
            return a.sign == b.sign;
        }
        return false;
    }

    function negative(
        Par memory a
    )
        internal
        pure
        returns (Par memory)
    {

        return Par({
            sign: !a.sign,
            value: a.value
        });
    }

    function isNegative(
        Par memory a
    )
        internal
        pure
        returns (bool)
    {

        return !a.sign && a.value > 0;
    }

    function isPositive(
        Par memory a
    )
        internal
        pure
        returns (bool)
    {

        return a.sign && a.value > 0;
    }

    function isZero(
        Par memory a
    )
        internal
        pure
        returns (bool)
    {

        return a.value == 0;
    }

}




library Storage {


    function load(
        bytes32 slot
    )
        internal
        view
        returns (bytes32)
    {

        bytes32 result;
        assembly {
            result := sload(slot)
        }
        return result;
    }

    function store(
        bytes32 slot,
        bytes32 value
    )
        internal
    {

        assembly {
            sstore(slot, value)
        }
    }
}


contract Adminable {

    bytes32 internal constant ADMIN_SLOT =
    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier onlyAdmin() {

        require(
            msg.sender == getAdmin(),
            "Adminable: caller is not admin"
        );
        _;
    }

    function getAdmin()
        public
        view
        returns (address)
    {

        return address(uint160(uint256(Storage.load(ADMIN_SLOT))));
    }
}


contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
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




contract StateV1 is Ownable {


    using Math for uint256;
    using SafeMath for uint256;
    using TypesV1 for TypesV1.Par;


    address public core;

    TypesV1.MarketParams public market;
    TypesV1.RiskParams public risk;

    IOracle public oracle;
    address public collateralAsset;
    address public syntheticAsset;

    uint256 public positionCount;
    uint256 public totalSupplied;

    mapping (uint256 => TypesV1.Position) public positions;


    event MarketParamsUpdated(TypesV1.MarketParams updatedMarket);
    event RiskParamsUpdated(TypesV1.RiskParams updatedParams);
    event OracleUpdated(address updatedOracle);


    constructor(
        address _core,
        address _collateralAsset,
        address _syntheticAsset,
        address _oracle,
        TypesV1.MarketParams memory _marketParams,
        TypesV1.RiskParams memory _riskParams
    )
        public
    {
        core = _core;
        collateralAsset = _collateralAsset;
        syntheticAsset = _syntheticAsset;

        setOracle(_oracle);
        setMarketParams(_marketParams);
        setRiskParams(_riskParams);
    }


    modifier onlyCore() {

        require(
            msg.sender == core,
            "StateV1: only core can call"
        );
        _;
    }


    function setOracle(
        address _oracle
    )
        public
        onlyOwner
    {

        require(
            _oracle != address(0),
            "StateV1: cannot set 0 for oracle address"
        );

        oracle = IOracle(_oracle);
        emit OracleUpdated(_oracle);
    }

    function setMarketParams(
        TypesV1.MarketParams memory _marketParams
    )
        public
        onlyOwner
    {

        market = _marketParams;
        emit MarketParamsUpdated(market);
    }

    function setRiskParams(
        TypesV1.RiskParams memory _riskParams
    )
        public
        onlyOwner
    {

        risk = _riskParams;
        emit RiskParamsUpdated(risk);
    }


    function updateTotalSupplied(
        uint256 amount
    )
        public
        onlyCore
    {

        totalSupplied = totalSupplied.add(amount);
    }

    function savePosition(
        TypesV1.Position memory position
    )
        public
        onlyCore
        returns (uint256)
    {

        uint256 idToAllocate = positionCount;
        positions[positionCount] = position;
        positionCount = positionCount.add(1);

        return idToAllocate;
    }

    function setAmount(
        uint256 id,
        TypesV1.AssetType asset,
        TypesV1.Par memory amount
    )
        public
        onlyCore
        returns (TypesV1.Position memory)
    {

        TypesV1.Position storage position = positions[id];

        if (position.collateralAsset == asset) {
            position.collateralAmount = amount;
        } else {
            position.borrowedAmount = amount;
        }

        return position;
    }

    function updatePositionAmount(
        uint256 id,
        TypesV1.AssetType asset,
        TypesV1.Par memory amount
    )
        public
        onlyCore
        returns (TypesV1.Position memory)
    {

        TypesV1.Position storage position = positions[id];

        if (position.collateralAsset == asset) {
            position.collateralAmount = position.collateralAmount.add(amount);
        } else {
            position.borrowedAmount = position.borrowedAmount.add(amount);
        }

        return position;
    }


    function getAddress(
        TypesV1.AssetType asset
    )
        public
        view
        returns (address)
    {

        return asset == TypesV1.AssetType.Collateral ?
            address(collateralAsset) :
            address(syntheticAsset);
    }

    function getPosition(
        uint256 id
    )
        public
        view
        returns (TypesV1.Position memory)
    {

        return positions[id];
    }

    function getCurrentPrice()
        public
        view
        returns (Decimal.D256 memory)
    {

        return oracle.fetchCurrentPrice();
    }


    function isCollateralized(
        TypesV1.Position memory position
    )
        public
        view
        returns (bool)
    {

        if (position.borrowedAmount.value == 0) {
            return true;
        }

        Decimal.D256 memory currentPrice = oracle.fetchCurrentPrice();

        (TypesV1.Par memory collateralDelta) = calculateCollateralDelta(
            position.borrowedAsset,
            position.collateralAmount,
            position.borrowedAmount,
            currentPrice
        );

        return collateralDelta.sign || collateralDelta.value == 0;
    }

    function calculateInverseAmount(
        TypesV1.AssetType asset,
        uint256 amount,
        Decimal.D256 memory price
    )
        public
        pure
        returns (uint256)
    {

        uint256 borrowRequired;

        if (asset == TypesV1.AssetType.Collateral) {
            borrowRequired = Decimal.mul(
                amount,
                price
            );
        } else if (asset == TypesV1.AssetType.Synthetic) {
            borrowRequired = Decimal.div(
                amount,
                price
            );
        }

        return borrowRequired;
    }

    function calculateInverseRequired(
        TypesV1.AssetType asset,
        uint256 amount,
        Decimal.D256 memory price
    )
        public
        view
        returns (TypesV1.Par memory)
    {


        uint256 inverseRequired = calculateInverseAmount(
            asset,
            amount,
            price
        );

        if (asset == TypesV1.AssetType.Collateral) {
            inverseRequired = Decimal.div(
                inverseRequired,
                market.collateralRatio
            );

        } else if (asset == TypesV1.AssetType.Synthetic) {
            inverseRequired = Decimal.mul(
                inverseRequired,
                market.collateralRatio
            );
        }

        return TypesV1.Par({
            sign: true,
            value: inverseRequired.to128()
        });
    }

    function calculateLiquidationPrice(
        TypesV1.AssetType asset
    )
        public
        view
        returns (Decimal.D256 memory)
    {

        Decimal.D256 memory result;
        Decimal.D256 memory currentPrice = oracle.fetchCurrentPrice();

        uint256 totalSpread = market.liquidationUserFee.value.add(
            market.liquidationArcFee.value
        );

        if (asset == TypesV1.AssetType.Collateral) {
            result = Decimal.sub(
                Decimal.one(),
                totalSpread
            );
        } else if (asset == TypesV1.AssetType.Synthetic) {
            result = Decimal.add(
                Decimal.one(),
                totalSpread
            );
        }

        result = Decimal.mul(
            currentPrice,
            result
        );

        return result;
    }

    function calculateCollateralDelta(
        TypesV1.AssetType borrowedAsset,
        TypesV1.Par memory parSupply,
        TypesV1.Par memory parBorrow,
        Decimal.D256 memory price
    )
        public
        view
        returns (TypesV1.Par memory)
    {

        TypesV1.Par memory collateralDelta;
        TypesV1.Par memory collateralRequired;

        if (borrowedAsset == TypesV1.AssetType.Collateral) {
            collateralRequired = calculateInverseRequired(
                borrowedAsset,
                parBorrow.value,
                price
            );
        } else if (borrowedAsset == TypesV1.AssetType.Synthetic) {
            collateralRequired = calculateInverseRequired(
                borrowedAsset,
                parBorrow.value,
                price
            );
        }

        collateralDelta = parSupply.sub(collateralRequired);

        return collateralDelta;
    }

    function totalLiquidationSpread()
        public
        view
        returns (Decimal.D256 memory)
    {

        return Decimal.D256({
            value: market.liquidationUserFee.value.add(
                market.liquidationArcFee.value
            )
        });
    }

    function calculateLiquidationSplit()
        public
        view
        returns (
            Decimal.D256 memory,
            Decimal.D256 memory
        )
    {

        Decimal.D256 memory total = Decimal.D256({
            value: market.liquidationUserFee.value.add(
                market.liquidationArcFee.value
            )
        });

        Decimal.D256 memory userRatio = Decimal.D256({
            value: Decimal.div(
                market.liquidationUserFee.value,
                total
            )
        });

        return (
            userRatio,
            Decimal.sub(
                Decimal.one(),
                userRatio.value
            )
        );
    }

}




contract StorageV1 {


    bool public paused;

    StateV1 public state;

}



contract CoreV4 is StorageV1, Adminable {



    using SafeMath for uint256;
    using Math for uint256;
    using TypesV1 for TypesV1.Par;


    enum Operation {
        Open,
        Borrow,
        Repay,
        Liquidate
    }

    struct OperationParams {
        uint256 id;
        uint256 amountOne;
        uint256 amountTwo;
    }


    event ActionOperated(
        uint8 operation,
        OperationParams params,
        TypesV1.Position updatedPosition
    );

    event ExcessTokensWithdrawn(
        address token,
        uint256 amount,
        address destination
    );

    event PauseStatusUpdated(
        bool value
    );


    constructor() public {
        paused = true;
    }

    function init(address _state)
        external
    {

        require(
            address(state) == address(0),
            "CoreV1.init(): cannot recall init"
        );

        state = StateV1(_state);
        paused = false;
    }


    function operateAction(
        Operation operation,
        OperationParams memory params
    )
        public
    {

        require(
            paused == false,
            "operateAction(): contracts cannot be paused"
        );

        TypesV1.Position memory operatedPosition;

        (
            uint256 collateralLimit,
            uint256 syntheticLimit,
            uint256 collateralMinimum
        ) = state.risk();

        if (operation == Operation.Open) {
            (operatedPosition, params.id) = openPosition(
                params.amountOne,
                params.amountTwo
            );

            require(
                params.amountOne >= collateralMinimum,
                "operateAction(): must exceed minimum collateral amount"
            );

        } else if (operation == Operation.Borrow) {
            operatedPosition = borrow(
                params.id,
                params.amountOne,
                params.amountTwo
            );
        } else if (operation == Operation.Repay) {
            operatedPosition = repay(
                params.id,
                params.amountOne,
                params.amountTwo
            );
        } else if (operation == Operation.Liquidate) {
            operatedPosition = liquidate(
                params.id
            );
        }

        IERC20 synthetic = IERC20(state.syntheticAsset());
        IERC20 collateralAsset = IERC20(state.collateralAsset());

        require(
            synthetic.totalSupply() <= syntheticLimit || syntheticLimit == 0,
            "operateAction(): synthetic supply cannot be greater than limit"
        );

        require(
            collateralAsset.balanceOf(address(synthetic)) <= collateralLimit || collateralLimit == 0,
            "operateAction(): collateral locked cannot be greater than limit"
        );

        require(
            operatedPosition.borrowedAmount.sign == false,
            "operateAction(): the protocol cannot be in debt to the user"
        );

        require(
            state.isCollateralized(operatedPosition) == true,
            "operateAction(): the operated position is undercollateralised"
        );

        emit ActionOperated(
            uint8(operation),
            params,
            operatedPosition
        );
    }

    function withdrawTokens(
        address token,
        address destination,
        uint256 amount
    )
        external
        onlyAdmin
    {

        SafeERC20.safeTransfer(
            IERC20(token),
            destination,
            amount
        );
    }

    function setPause(bool value)
        external
        onlyAdmin
    {

        paused = value;

        emit PauseStatusUpdated(value);
    }


    function openPosition(
        uint256 collateralAmount,
        uint256 borrowAmount
    )
        internal
        returns (TypesV1.Position memory, uint256)
    {



        TypesV1.Position memory newPosition = TypesV1.Position({
            owner: msg.sender,
            collateralAsset: TypesV1.AssetType.Collateral,
            borrowedAsset: TypesV1.AssetType.Synthetic,
            collateralAmount: TypesV1.positiveZeroPar(),
            borrowedAmount: TypesV1.zeroPar()
        });


        uint256 positionId = state.savePosition(newPosition);

        newPosition = borrow(
            positionId,
            collateralAmount,
            borrowAmount
        );

        return (
            newPosition,
            positionId
        );
    }

    function borrow(
        uint256 positionId,
        uint256 collateralAmount,
        uint256 borrowAmount
    )
        internal
        returns (TypesV1.Position memory)
    {




        TypesV1.Position memory position = state.getPosition(positionId);

        require(
            position.owner == msg.sender,
            "borrowPosition(): must be a valid position"
        );

        Decimal.D256 memory currentPrice = state.getCurrentPrice();

        position = state.updatePositionAmount(
            positionId,
            position.collateralAsset,
            TypesV1.Par({
                sign: true,
                value: collateralAmount.to128()
            })
        );

        state.updateTotalSupplied(collateralAmount);

        if (borrowAmount > 0) {
            TypesV1.Par memory newPar = position.borrowedAmount.add(
                TypesV1.Par({
                    sign: false,
                    value: borrowAmount.to128()
                })
            );

            if (newPar.value == 0) {
                newPar.sign = false;
            }

            position = state.setAmount(
                positionId,
                position.borrowedAsset,
                newPar
            );

            TypesV1.Par memory collateralRequired = state.calculateInverseRequired(
                position.borrowedAsset,
                position.borrowedAmount.value,
                currentPrice
            );

            require(
                position.collateralAmount.value >= collateralRequired.value,
                "borrowPosition(): not enough collateral provided"
            );
        }

        IERC20 syntheticAsset = IERC20(state.syntheticAsset());
        IERC20 collateralAsset = IERC20(state.collateralAsset());

        SafeERC20.safeTransferFrom(
            collateralAsset,
            msg.sender,
            address(syntheticAsset),
            collateralAmount
        );

        ISyntheticToken(address(syntheticAsset)).mint(
            msg.sender,
            borrowAmount
        );

        return position;
    }

    function repay(
        uint256 positionId,
        uint256 repayAmount,
        uint256 withdrawAmount
    )
        private
        returns (TypesV1.Position memory)
    {




        TypesV1.Position memory position = state.getPosition(positionId);

        Decimal.D256 memory currentPrice = state.getCurrentPrice();

        require(
            position.owner == msg.sender,
            "repay(): must be a valid position"
        );

        TypesV1.Par memory newPar = position.borrowedAmount.add(
            TypesV1.Par({
                sign: true,
                value: repayAmount.to128()
            })
        );

        position = state.setAmount(positionId, position.borrowedAsset, newPar);

        (TypesV1.Par memory collateralDelta) = state.calculateCollateralDelta(
            position.borrowedAsset,
            position.collateralAmount,
            position.borrowedAmount,
            currentPrice
        );

        require(
            withdrawAmount <= collateralDelta.value,
            "repay(): cannot withdraw more than you're allowed"
        );

        position = state.updatePositionAmount(
            positionId,
            position.collateralAsset,
            TypesV1.Par({
                sign: false,
                value: withdrawAmount.to128()
            })
        );

        ISyntheticToken synthetic = ISyntheticToken(state.syntheticAsset());
        IERC20 collateralAsset = IERC20(state.collateralAsset());

        synthetic.burn(
            msg.sender,
            repayAmount
        );

        bool transferResult = synthetic.transferCollateral(
            address(collateralAsset),
            msg.sender,
            withdrawAmount
        );

        require(
            transferResult == true,
            "repay(): collateral failed to transfer"
        );

        return position;
    }

    function liquidate(
        uint256 positionId
    )
        private
        returns (TypesV1.Position memory)
    {




        TypesV1.Position memory position = state.getPosition(positionId);

        require(
            position.owner != address(0),
            "liquidatePosition(): must be a valid position"
        );

        require(
            state.isCollateralized(position) == false,
            "liquidatePosition(): position is collateralised"
        );

        Decimal.D256 memory liquidationPrice = state.calculateLiquidationPrice(
            position.collateralAsset
        );

        (TypesV1.Par memory liquidationCollateralDelta) = state.calculateCollateralDelta(
            position.borrowedAsset,
            position.collateralAmount,
            position.borrowedAmount,
            liquidationPrice
        );

        liquidationCollateralDelta.value = Decimal.mul(
            liquidationCollateralDelta.value,
            Decimal.add(
                state.totalLiquidationSpread(),
                Decimal.one().value
            )
        ).to128();

        (TypesV1.Par memory liquidatorCollateralCost) = TypesV1.Par({
            sign: false,
            value: Decimal.mul(
                liquidationCollateralDelta.value,
                Decimal.sub(
                    Decimal.one(),
                    state.totalLiquidationSpread().value
                )
            ).to128()
        });

        if (liquidationCollateralDelta.value > position.collateralAmount.value) {
            liquidationCollateralDelta.value = position.collateralAmount.value;

            liquidatorCollateralCost.value = position.collateralAmount.value;
        }

        uint256 borrowToLiquidate = state.calculateInverseAmount(
            position.collateralAsset,
            liquidationCollateralDelta.value,
            liquidationPrice
        );

        TypesV1.Par memory newPar = position.borrowedAmount.add(
            TypesV1.Par({
                sign: true,
                value: borrowToLiquidate.to128()
            })
        );

        position = state.setAmount(positionId, position.borrowedAsset, newPar);

        position = state.updatePositionAmount(
            positionId,
            position.collateralAsset,
            liquidationCollateralDelta
        );

        address borrowAddress = state.getAddress(position.borrowedAsset);

        require(
            IERC20(borrowAddress).balanceOf(msg.sender) >= borrowToLiquidate,
            "liquidatePosition(): msg.sender not enough of borrowed asset to liquidate"
        );

        _settleLiquidation(
            borrowToLiquidate,
            liquidationCollateralDelta,
            liquidatorCollateralCost
        );

        return position;
    }

    function _settleLiquidation(
        uint256 borrowToLiquidate,
        TypesV1.Par memory liquidationCollateralDelta,
        TypesV1.Par memory liquidatorCollateralCost
    )
        private
    {

        ISyntheticToken synthetic = ISyntheticToken(
            state.syntheticAsset()
        );

        IERC20 collateralAsset = IERC20(state.collateralAsset());

        (
            Decimal.D256 memory userSplit,
            Decimal.D256 memory arcSplit
        ) = state.calculateLiquidationSplit();

        synthetic.burn(
            msg.sender,
            borrowToLiquidate
        );

        TypesV1.Par memory collateralProfit = liquidationCollateralDelta.sub(
            liquidatorCollateralCost
        );

        uint256 arcProfit = Decimal.mul(
            collateralProfit.value,
            arcSplit
        );

        bool userTransferResult = synthetic.transferCollateral(
            address(collateralAsset),
            msg.sender,
            uint256(liquidationCollateralDelta.value).sub(arcProfit)
        );

        require(
            userTransferResult == true,
            "liquidate(): collateral failed to transfer to user"
        );

        bool arcTransferResult = synthetic.transferCollateral(
            address(collateralAsset),
            address(this),
            arcProfit
        );

        require(
            arcTransferResult == true,
            "liquidate(): collateral failed to transfer to arc"
        );
    }

}