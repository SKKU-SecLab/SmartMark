


pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {

        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}




library DecimalMath {

    using SafeMath for uint256;

    uint256 internal constant ONE = 10**18;
    uint256 internal constant ONE2 = 10**36;

    function mulFloor(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(d) / (10**18);
    }

    function mulCeil(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(d).divCeil(10**18);
    }

    function divFloor(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(10**18).div(d);
    }

    function divCeil(uint256 target, uint256 d) internal pure returns (uint256) {

        return target.mul(10**18).divCeil(d);
    }

    function reciprocalFloor(uint256 target) internal pure returns (uint256) {

        return uint256(10**36).div(target);
    }

    function reciprocalCeil(uint256 target) internal pure returns (uint256) {

        return uint256(10**36).divCeil(target);
    }

    function powFloor(uint256 target, uint256 e) internal pure returns (uint256) {

        if (e == 0) {
            return 10 ** 18;
        } else if (e == 1) {
            return target;
        } else {
            uint p = powFloor(target, e.div(2));
            p = p.mul(p) / (10**18);
            if (e % 2 == 1) {
                p = p.mul(target) / (10**18);
            }
            return p;
        }
    }
}



contract Ownable {

    address public _OWNER_;
    address public _NEW_OWNER_;


    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier onlyOwner() {

        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }


    constructor() internal {
        _OWNER_ = msg.sender;
        emit OwnershipTransferred(address(0), _OWNER_);
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {

        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() external {

        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}



interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}



library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {



        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



interface IDVM {

    function init(
        address maintainer,
        address baseTokenAddress,
        address quoteTokenAddress,
        uint256 lpFeeRate,
        address mtFeeRateModel,
        uint256 i,
        uint256 k,
        bool isOpenTWAP
    ) external;


    function _BASE_TOKEN_() external returns (address);


    function _QUOTE_TOKEN_() external returns (address);


    function _MT_FEE_RATE_MODEL_() external returns (address);


    function getVaultReserve() external returns (uint256 baseReserve, uint256 quoteReserve);


    function sellBase(address to) external returns (uint256);


    function sellQuote(address to) external returns (uint256);


    function buyShares(address to) external returns (uint256,uint256,uint256);


    function addressToShortString(address _addr) external pure returns (string memory);


    function getMidPrice() external view returns (uint256 midPrice);


    function sellShares(
        uint256 shareAmount,
        address to,
        uint256 baseMinAmount,
        uint256 quoteMinAmount,
        bytes calldata data,
        uint256 deadline
    ) external  returns (uint256 baseAmount, uint256 quoteAmount);


}



contract InitializableOwnable {

    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;


    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier notInitialized() {

        require(!_INITIALIZED_, "DODO_INITIALIZED");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }


    function initOwner(address newOwner) public notInitialized {

        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {

        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}



interface ICloneFactory {

    function clone(address prototype) external returns (address proxy);

}


contract CloneFactory is ICloneFactory {

    function clone(address prototype) external override returns (address proxy) {

        bytes20 targetBytes = bytes20(prototype);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            proxy := create(0, clone, 0x37)
        }
        return proxy;
    }
}




interface IDVMFactory {

    function createDODOVendingMachine(
        address baseToken,
        address quoteToken,
        uint256 lpFeeRate,
        uint256 i,
        uint256 k,
        bool isOpenTWAP
    ) external returns (address newVendingMachine);

}


contract DVMFactory is InitializableOwnable {


    address public immutable _CLONE_FACTORY_;
    address public immutable _DEFAULT_MT_FEE_RATE_MODEL_;
    address public _DEFAULT_MAINTAINER_;
    address public _DVM_TEMPLATE_;


    mapping(address => mapping(address => address[])) public _REGISTRY_;
    mapping(address => address[]) public _USER_REGISTRY_;


    event NewDVM(
        address baseToken,
        address quoteToken,
        address creator,
        address dvm
    );

    event RemoveDVM(address dvm);


    constructor(
        address cloneFactory,
        address dvmTemplate,
        address defaultMaintainer,
        address defaultMtFeeRateModel
    ) public {
        _CLONE_FACTORY_ = cloneFactory;
        _DVM_TEMPLATE_ = dvmTemplate;
        _DEFAULT_MAINTAINER_ = defaultMaintainer;
        _DEFAULT_MT_FEE_RATE_MODEL_ = defaultMtFeeRateModel;
    }

    function createDODOVendingMachine(
        address baseToken,
        address quoteToken,
        uint256 lpFeeRate,
        uint256 i,
        uint256 k,
        bool isOpenTWAP
    ) external returns (address newVendingMachine) {

        newVendingMachine = ICloneFactory(_CLONE_FACTORY_).clone(_DVM_TEMPLATE_);
        {
            IDVM(newVendingMachine).init(
                _DEFAULT_MAINTAINER_,
                baseToken,
                quoteToken,
                lpFeeRate,
                _DEFAULT_MT_FEE_RATE_MODEL_,
                i,
                k,
                isOpenTWAP
            );
        }
        _REGISTRY_[baseToken][quoteToken].push(newVendingMachine);
        _USER_REGISTRY_[tx.origin].push(newVendingMachine);
        emit NewDVM(baseToken, quoteToken, tx.origin, newVendingMachine);
    }


    function updateDvmTemplate(address _newDVMTemplate) external onlyOwner {

        _DVM_TEMPLATE_ = _newDVMTemplate;
    }
    
    function updateDefaultMaintainer(address _newMaintainer) external onlyOwner {

        _DEFAULT_MAINTAINER_ = _newMaintainer;
    }

    function addPoolByAdmin(
        address creator,
        address baseToken, 
        address quoteToken,
        address pool
    ) external onlyOwner {

        _REGISTRY_[baseToken][quoteToken].push(pool);
        _USER_REGISTRY_[creator].push(pool);
        emit NewDVM(baseToken, quoteToken, creator, pool);
    }

    function removePoolByAdmin(
        address creator,
        address baseToken, 
        address quoteToken,
        address pool
    ) external onlyOwner {

        address[] memory registryList = _REGISTRY_[baseToken][quoteToken];
        for (uint256 i = 0; i < registryList.length; i++) {
            if (registryList[i] == pool) {
                registryList[i] = registryList[registryList.length - 1];
                break;
            }
        }
        _REGISTRY_[baseToken][quoteToken] = registryList;
        _REGISTRY_[baseToken][quoteToken].pop();
        address[] memory userRegistryList = _USER_REGISTRY_[creator];
        for (uint256 i = 0; i < userRegistryList.length; i++) {
            if (userRegistryList[i] == pool) {
                userRegistryList[i] = userRegistryList[userRegistryList.length - 1];
                break;
            }
        }
        _USER_REGISTRY_[creator] = userRegistryList;
        _USER_REGISTRY_[creator].pop();
        emit RemoveDVM(pool);
    }


    function getDODOPool(address baseToken, address quoteToken)
        external
        view
        returns (address[] memory machines)
    {

        return _REGISTRY_[baseToken][quoteToken];
    }

    function getDODOPoolBidirection(address token0, address token1)
        external
        view
        returns (address[] memory baseToken0Machines, address[] memory baseToken1Machines)
    {

        return (_REGISTRY_[token0][token1], _REGISTRY_[token1][token0]);
    }

    function getDODOPoolByUser(address user)
        external
        view
        returns (address[] memory machines)
    {

        return _USER_REGISTRY_[user];
    }
}



contract ReentrancyGuard {

    bool private _ENTERED_;

    modifier preventReentrant() {

        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
}




interface IPermissionManager {

    function initOwner(address) external;


    function isAllowed(address) external view returns (bool);

}

contract PermissionManager is InitializableOwnable {

    bool public _WHITELIST_MODE_ON_;

    mapping(address => bool) internal _whitelist_;
    mapping(address => bool) internal _blacklist_;

    function isAllowed(address account) external view returns (bool) {

        if (_WHITELIST_MODE_ON_) {
            return _whitelist_[account];
        } else {
            return !_blacklist_[account];
        }
    }

    function openBlacklistMode() external onlyOwner {

        _WHITELIST_MODE_ON_ = false;
    }

    function openWhitelistMode() external onlyOwner {

        _WHITELIST_MODE_ON_ = true;
    }

    function addToWhitelist(address account) external onlyOwner {

        _whitelist_[account] = true;
    }

    function removeFromWhitelist(address account) external onlyOwner {

        _whitelist_[account] = false;
    }

    function addToBlacklist(address account) external onlyOwner {

        _blacklist_[account] = true;
    }

    function removeFromBlacklist(address account) external onlyOwner {

        _blacklist_[account] = false;
    }
}




interface IFeeRateImpl {

    function getFeeRate(address pool, address trader) external view returns (uint256);

}

interface IFeeRateModel {

    function getFeeRate(address trader) external view returns (uint256);

}

contract FeeRateModel is InitializableOwnable {

    address public feeRateImpl;

    function setFeeProxy(address _feeRateImpl) public onlyOwner {

        feeRateImpl = _feeRateImpl;
    }
    
    function getFeeRate(address trader) external view returns (uint256) {

        if(feeRateImpl == address(0))
            return 0;
        return IFeeRateImpl(feeRateImpl).getFeeRate(msg.sender,trader);
    }
}




contract CPStorage is InitializableOwnable, ReentrancyGuard {

    using SafeMath for uint256;

    
    uint256 internal constant _SETTLEMENT_EXPIRE_ = 86400 * 7;
    uint256 internal constant _SETTEL_FUND_ = 200 finney;
    bool public _IS_OPEN_TWAP_ = false;
    bool public _IS_OVERCAP_STOP = false;

    bool public _FORCE_STOP_ = false;


    uint256 public _PHASE_BID_STARTTIME_;
    uint256 public _PHASE_BID_ENDTIME_;
    uint256 public _PHASE_CALM_ENDTIME_;
    uint256 public _SETTLED_TIME_;
    bool public _SETTLED_;


    IERC20 public _BASE_TOKEN_;
    IERC20 public _QUOTE_TOKEN_;


    uint256 public _TOTAL_BASE_;
    uint256 public _POOL_QUOTE_CAP_;


    uint256 public _QUOTE_RESERVE_;

    uint256 public _UNUSED_BASE_;
    uint256 public _UNUSED_QUOTE_;

    uint256 public _TOTAL_SHARES_;
    mapping(address => uint256) internal _SHARES_;
    mapping(address => bool) public _CLAIMED_QUOTE_;

    address public _POOL_FACTORY_;
    address public _POOL_;
    uint256 public _POOL_FEE_RATE_;
    uint256 public _AVG_SETTLED_PRICE_;


    address public _MAINTAINER_;
    IFeeRateModel public _MT_FEE_RATE_MODEL_;
    IPermissionManager public _BIDDER_PERMISSION_;


    uint256 public _K_;
    uint256 public _I_;


    uint256 public _TOTAL_LP_AMOUNT_;
    uint256 public _FREEZE_DURATION_;
    uint256 public _VESTING_DURATION_;
    uint256 public _CLIFF_RATE_;

    uint256 public _TOKEN_CLAIM_DURATION_;
    uint256 public _TOKEN_VESTING_DURATION_;
    uint256 public _TOKEN_CLIFF_RATE_;
    mapping(address => uint256) public _CLAIMED_BASE_TOKEN_;

    modifier isNotForceStop() {

        require(!_FORCE_STOP_, "FORCE_STOP");
        _;
    }

    modifier phaseBid() {

        require(
            block.timestamp >= _PHASE_BID_STARTTIME_ && block.timestamp < _PHASE_BID_ENDTIME_,
            "NOT_PHASE_BID"
        );
        _;
    }

    modifier phaseCalm() {

        require(
            block.timestamp >= _PHASE_BID_ENDTIME_ && block.timestamp < _PHASE_CALM_ENDTIME_,
            "NOT_PHASE_CALM"
        );
        _;
    }

    modifier phaseBidOrCalm() {

        require(
            block.timestamp >= _PHASE_BID_STARTTIME_ && block.timestamp < _PHASE_CALM_ENDTIME_,
            "NOT_PHASE_BID_OR_CALM"
        );
        _;
    }

    modifier phaseSettlement() {

        require(block.timestamp >= _PHASE_CALM_ENDTIME_, "NOT_PHASE_EXE");
        _;
    }

    modifier phaseVesting() {

        require(_SETTLED_, "NOT_VESTING");
        _;
    }

    function forceStop() external onlyOwner {

        require(block.timestamp < _PHASE_BID_STARTTIME_, "CP_ALREADY_STARTED");
        _FORCE_STOP_ = true;
        _TOTAL_BASE_ = 0;
        uint256 baseAmount = _BASE_TOKEN_.balanceOf(address(this));
        _BASE_TOKEN_.transfer(_OWNER_, baseAmount);
    }
}



library DODOMath {

    using SafeMath for uint256;

    function _GeneralIntegrate(
        uint256 V0,
        uint256 V1,
        uint256 V2,
        uint256 i,
        uint256 k
    ) internal pure returns (uint256) {

        require(V0 > 0, "TARGET_IS_ZERO");
        uint256 fairAmount = i.mul(V1.sub(V2)); // i*delta
        if (k == 0) {
            return fairAmount.div(DecimalMath.ONE);
        }
        uint256 V0V0V1V2 = DecimalMath.divFloor(V0.mul(V0).div(V1), V2);
        uint256 penalty = DecimalMath.mulFloor(k, V0V0V1V2); // k(V0^2/V1/V2)
        return DecimalMath.ONE.sub(k).add(penalty).mul(fairAmount).div(DecimalMath.ONE2);
    }

    function _SolveQuadraticFunctionForTarget(
        uint256 V1,
        uint256 delta,
        uint256 i,
        uint256 k
    ) internal pure returns (uint256) {

        if (V1 == 0) {
            return 0;
        }
        if (k == 0) {
            return V1.add(DecimalMath.mulFloor(i, delta));
        }
        uint256 sqrt;
        uint256 ki = (4 * k).mul(i);
        if (ki == 0) {
            sqrt = DecimalMath.ONE;
        } else if ((ki * delta) / ki == delta) {
            sqrt = (ki * delta).div(V1).add(DecimalMath.ONE2).sqrt();
        } else {
            sqrt = ki.div(V1).mul(delta).add(DecimalMath.ONE2).sqrt();
        }
        uint256 premium =
            DecimalMath.divFloor(sqrt.sub(DecimalMath.ONE), k * 2).add(DecimalMath.ONE);
        return DecimalMath.mulFloor(V1, premium);
    }

    function _SolveQuadraticFunctionForTrade(
        uint256 V0,
        uint256 V1,
        uint256 delta,
        uint256 i,
        uint256 k
    ) internal pure returns (uint256) {

        require(V0 > 0, "TARGET_IS_ZERO");
        if (delta == 0) {
            return 0;
        }

        if (k == 0) {
            return DecimalMath.mulFloor(i, delta) > V1 ? V1 : DecimalMath.mulFloor(i, delta);
        }

        if (k == DecimalMath.ONE) {
            uint256 temp;
            uint256 idelta = i.mul(delta);
            if (idelta == 0) {
                temp = 0;
            } else if ((idelta * V1) / idelta == V1) {
                temp = (idelta * V1).div(V0.mul(V0));
            } else {
                temp = delta.mul(V1).div(V0).mul(i).div(V0);
            }
            return V1.mul(temp).div(temp.add(DecimalMath.ONE));
        }

        uint256 part2 = k.mul(V0).div(V1).mul(V0).add(i.mul(delta)); // kQ0^2/Q1-i*deltaB
        uint256 bAbs = DecimalMath.ONE.sub(k).mul(V1); // (1-k)Q1

        bool bSig;
        if (bAbs >= part2) {
            bAbs = bAbs - part2;
            bSig = false;
        } else {
            bAbs = part2 - bAbs;
            bSig = true;
        }
        bAbs = bAbs.div(DecimalMath.ONE);

        uint256 squareRoot =
            DecimalMath.mulFloor(
                DecimalMath.ONE.sub(k).mul(4),
                DecimalMath.mulFloor(k, V0).mul(V0)
            ); // 4(1-k)kQ0^2
        squareRoot = bAbs.mul(bAbs).add(squareRoot).sqrt(); // sqrt(b*b+4(1-k)kQ0*Q0)

        uint256 denominator = DecimalMath.ONE.sub(k).mul(2); // 2(1-k)
        uint256 numerator;
        if (bSig) {
            numerator = squareRoot.sub(bAbs);
        } else {
            numerator = bAbs.add(squareRoot);
        }

        uint256 V2 = DecimalMath.divCeil(numerator, denominator);
        if (V2 > V1) {
            return 0;
        } else {
            return V1 - V2;
        }
    }
}




library PMMPricing {

    using SafeMath for uint256;

    enum RState {ONE, ABOVE_ONE, BELOW_ONE}

    struct PMMState {
        uint256 i;
        uint256 K;
        uint256 B;
        uint256 Q;
        uint256 B0;
        uint256 Q0;
        RState R;
    }


    function sellBaseToken(PMMState memory state, uint256 payBaseAmount)
        internal
        pure
        returns (uint256 receiveQuoteAmount, RState newR)
    {

        if (state.R == RState.ONE) {
            receiveQuoteAmount = _ROneSellBaseToken(state, payBaseAmount);
            newR = RState.BELOW_ONE;
        } else if (state.R == RState.ABOVE_ONE) {
            uint256 backToOnePayBase = state.B0.sub(state.B);
            uint256 backToOneReceiveQuote = state.Q.sub(state.Q0);
            if (payBaseAmount < backToOnePayBase) {
                receiveQuoteAmount = _RAboveSellBaseToken(state, payBaseAmount);
                newR = RState.ABOVE_ONE;
                if (receiveQuoteAmount > backToOneReceiveQuote) {
                    receiveQuoteAmount = backToOneReceiveQuote;
                }
            } else if (payBaseAmount == backToOnePayBase) {
                receiveQuoteAmount = backToOneReceiveQuote;
                newR = RState.ONE;
            } else {
                receiveQuoteAmount = backToOneReceiveQuote.add(
                    _ROneSellBaseToken(state, payBaseAmount.sub(backToOnePayBase))
                );
                newR = RState.BELOW_ONE;
            }
        } else {
            receiveQuoteAmount = _RBelowSellBaseToken(state, payBaseAmount);
            newR = RState.BELOW_ONE;
        }
    }

    function sellQuoteToken(PMMState memory state, uint256 payQuoteAmount)
        internal
        pure
        returns (uint256 receiveBaseAmount, RState newR)
    {

        if (state.R == RState.ONE) {
            receiveBaseAmount = _ROneSellQuoteToken(state, payQuoteAmount);
            newR = RState.ABOVE_ONE;
        } else if (state.R == RState.ABOVE_ONE) {
            receiveBaseAmount = _RAboveSellQuoteToken(state, payQuoteAmount);
            newR = RState.ABOVE_ONE;
        } else {
            uint256 backToOnePayQuote = state.Q0.sub(state.Q);
            uint256 backToOneReceiveBase = state.B.sub(state.B0);
            if (payQuoteAmount < backToOnePayQuote) {
                receiveBaseAmount = _RBelowSellQuoteToken(state, payQuoteAmount);
                newR = RState.BELOW_ONE;
                if (receiveBaseAmount > backToOneReceiveBase) {
                    receiveBaseAmount = backToOneReceiveBase;
                }
            } else if (payQuoteAmount == backToOnePayQuote) {
                receiveBaseAmount = backToOneReceiveBase;
                newR = RState.ONE;
            } else {
                receiveBaseAmount = backToOneReceiveBase.add(
                    _ROneSellQuoteToken(state, payQuoteAmount.sub(backToOnePayQuote))
                );
                newR = RState.ABOVE_ONE;
            }
        }
    }


    function _ROneSellBaseToken(PMMState memory state, uint256 payBaseAmount)
        internal
        pure
        returns (
            uint256 // receiveQuoteToken
        )
    {

        return
            DODOMath._SolveQuadraticFunctionForTrade(
                state.Q0,
                state.Q0,
                payBaseAmount,
                state.i,
                state.K
            );
    }

    function _ROneSellQuoteToken(PMMState memory state, uint256 payQuoteAmount)
        internal
        pure
        returns (
            uint256 // receiveBaseToken
        )
    {

        return
            DODOMath._SolveQuadraticFunctionForTrade(
                state.B0,
                state.B0,
                payQuoteAmount,
                DecimalMath.reciprocalFloor(state.i),
                state.K
            );
    }


    function _RBelowSellQuoteToken(PMMState memory state, uint256 payQuoteAmount)
        internal
        pure
        returns (
            uint256 // receiveBaseToken
        )
    {

        return
            DODOMath._GeneralIntegrate(
                state.Q0,
                state.Q.add(payQuoteAmount),
                state.Q,
                DecimalMath.reciprocalFloor(state.i),
                state.K
            );
    }

    function _RBelowSellBaseToken(PMMState memory state, uint256 payBaseAmount)
        internal
        pure
        returns (
            uint256 // receiveQuoteToken
        )
    {

        return
            DODOMath._SolveQuadraticFunctionForTrade(
                state.Q0,
                state.Q,
                payBaseAmount,
                state.i,
                state.K
            );
    }


    function _RAboveSellBaseToken(PMMState memory state, uint256 payBaseAmount)
        internal
        pure
        returns (
            uint256 // receiveQuoteToken
        )
    {

        return
            DODOMath._GeneralIntegrate(
                state.B0,
                state.B.add(payBaseAmount),
                state.B,
                state.i,
                state.K
            );
    }

    function _RAboveSellQuoteToken(PMMState memory state, uint256 payQuoteAmount)
        internal
        pure
        returns (
            uint256 // receiveBaseToken
        )
    {

        return
            DODOMath._SolveQuadraticFunctionForTrade(
                state.B0,
                state.B,
                payQuoteAmount,
                DecimalMath.reciprocalFloor(state.i),
                state.K
            );
    }


    function adjustedTarget(PMMState memory state) internal pure {

        if (state.R == RState.BELOW_ONE) {
            state.Q0 = DODOMath._SolveQuadraticFunctionForTarget(
                state.Q,
                state.B.sub(state.B0),
                state.i,
                state.K
            );
        } else if (state.R == RState.ABOVE_ONE) {
            state.B0 = DODOMath._SolveQuadraticFunctionForTarget(
                state.B,
                state.Q.sub(state.Q0),
                DecimalMath.reciprocalFloor(state.i),
                state.K
            );
        }
    }

    function getMidPrice(PMMState memory state) internal pure returns (uint256) {

        if (state.R == RState.BELOW_ONE) {
            uint256 R = DecimalMath.divFloor(state.Q0.mul(state.Q0).div(state.Q), state.Q);
            R = DecimalMath.ONE.sub(state.K).add(DecimalMath.mulFloor(state.K, R));
            return DecimalMath.divFloor(state.i, R);
        } else {
            uint256 R = DecimalMath.divFloor(state.B0.mul(state.B0).div(state.B), state.B);
            R = DecimalMath.ONE.sub(state.K).add(DecimalMath.mulFloor(state.K, R));
            return DecimalMath.mulFloor(state.i, R);
        }
    }
}



interface IDODOCallee {

    function DVMSellShareCall(
        address sender,
        uint256 burnShareAmount,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external;


    function DVMFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external;


    function DPPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external;


    function DSPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external;


    function CPCancelCall(
        address sender,
        uint256 amount,
        bytes calldata data
    ) external;


	function CPClaimBidCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external;


    function NFTRedeemCall(
        address payable assetTo,
        uint256 quoteAmount,
        bytes calldata
    ) external;

}




contract CPFunding is CPStorage {

    using SafeERC20 for IERC20;
    
    
    event Bid(address to, uint256 amount, uint256 fee);
    event Cancel(address to,uint256 amount);
    event Settle();

    
    modifier isBidderAllow(address bidder) {

        require(_BIDDER_PERMISSION_.isAllowed(bidder), "BIDDER_NOT_ALLOWED");
        if(_IS_OVERCAP_STOP) {
            require(_QUOTE_TOKEN_.balanceOf(address(this)) <= _POOL_QUOTE_CAP_, "ALREADY_OVER_CAP");
        }
        _;
    }

    function bid(address to) external isNotForceStop phaseBid preventReentrant isBidderAllow(to) {

        uint256 input = _getQuoteInput();
        uint256 mtFee = DecimalMath.mulFloor(input, _MT_FEE_RATE_MODEL_.getFeeRate(to));
        _transferQuoteOut(_MAINTAINER_, mtFee);
        _mintShares(to, input.sub(mtFee));
        _sync();
        emit Bid(to, input, mtFee);
    }

    function cancel(address to, uint256 amount, bytes calldata data) external phaseBidOrCalm preventReentrant {

        require(_SHARES_[msg.sender] >= amount, "SHARES_NOT_ENOUGH");
        _burnShares(msg.sender, amount);
        _transferQuoteOut(to, amount);
        _sync();

        if(data.length > 0){
            IDODOCallee(to).CPCancelCall(msg.sender,amount,data);
        }

        emit Cancel(msg.sender,amount);
    }

    function _mintShares(address to, uint256 amount) internal {

        _SHARES_[to] = _SHARES_[to].add(amount);
        _TOTAL_SHARES_ = _TOTAL_SHARES_.add(amount);
    }

    function _burnShares(address from, uint256 amount) internal {

        _SHARES_[from] = _SHARES_[from].sub(amount);
        _TOTAL_SHARES_ = _TOTAL_SHARES_.sub(amount);
    }


    function settle() external isNotForceStop phaseSettlement preventReentrant {

        _settle();

        (uint256 poolBase, uint256 poolQuote, uint256 poolI, uint256 unUsedBase, uint256 unUsedQuote) = getSettleResult();
        _UNUSED_BASE_ = unUsedBase;
        _UNUSED_QUOTE_ = unUsedQuote;

        address _poolBaseToken;
        address _poolQuoteToken;

        if (_UNUSED_BASE_ > poolBase) {
            _poolBaseToken = address(_QUOTE_TOKEN_);
            _poolQuoteToken = address(_BASE_TOKEN_);
        } else {
            _poolBaseToken = address(_BASE_TOKEN_);
            _poolQuoteToken = address(_QUOTE_TOKEN_);
        }

        _POOL_ = IDVMFactory(_POOL_FACTORY_).createDODOVendingMachine(
            _poolBaseToken,
            _poolQuoteToken,
            _POOL_FEE_RATE_,
            poolI,
            DecimalMath.ONE,
            _IS_OPEN_TWAP_
        );

        uint256 avgPrice = unUsedBase == 0 ? _I_ : DecimalMath.divCeil(poolQuote, unUsedBase);
        _AVG_SETTLED_PRICE_ = avgPrice;

        _transferBaseOut(_POOL_, poolBase);
        _transferQuoteOut(_POOL_, poolQuote);

        (_TOTAL_LP_AMOUNT_, ,) = IDVM(_POOL_).buyShares(address(this));

        msg.sender.transfer(_SETTEL_FUND_);

        emit Settle();
    }

    function emergencySettle() external isNotForceStop phaseSettlement preventReentrant {

        require(block.timestamp >= _PHASE_CALM_ENDTIME_.add(_SETTLEMENT_EXPIRE_), "NOT_EMERGENCY");
        _settle();
        _UNUSED_QUOTE_ = _QUOTE_TOKEN_.balanceOf(address(this));
    }

    function _settle() internal {

        require(!_SETTLED_, "ALREADY_SETTLED");
        _SETTLED_ = true;
        _SETTLED_TIME_ = block.timestamp;
    }


    function getSettleResult() public view returns (uint256 poolBase, uint256 poolQuote, uint256 poolI, uint256 unUsedBase, uint256 unUsedQuote) {

        poolQuote = _QUOTE_TOKEN_.balanceOf(address(this));
        if (poolQuote > _POOL_QUOTE_CAP_) {
            poolQuote = _POOL_QUOTE_CAP_;
        }
        (uint256 soldBase,) = PMMPricing.sellQuoteToken(_getPMMState(), poolQuote);
        poolBase = _TOTAL_BASE_.sub(soldBase);

        unUsedQuote = _QUOTE_TOKEN_.balanceOf(address(this)).sub(poolQuote);
        unUsedBase = _BASE_TOKEN_.balanceOf(address(this)).sub(poolBase);


        uint256 avgPrice = unUsedBase == 0 ? _I_ : DecimalMath.divCeil(poolQuote, unUsedBase);
        uint256 baseDepth = DecimalMath.mulFloor(avgPrice, poolBase);

        if (poolQuote == 0) {
            poolI = _I_;
        } else if (unUsedBase== poolBase) {
            poolI = 1;
        } else if (unUsedBase < poolBase) {
            uint256 ratio = DecimalMath.ONE.sub(DecimalMath.divFloor(poolQuote, baseDepth));
            poolI = avgPrice.mul(ratio).mul(ratio).divCeil(DecimalMath.ONE2);
        } else if (unUsedBase > poolBase) {
            uint256 ratio = DecimalMath.ONE.sub(DecimalMath.divCeil(baseDepth, poolQuote));
            poolI = ratio.mul(ratio).div(avgPrice);
        }
    }

    function _getPMMState() internal view returns (PMMPricing.PMMState memory state) {

        state.i = _I_;
        state.K = _K_;
        state.B = _TOTAL_BASE_;
        state.Q = 0;
        state.B0 = state.B;
        state.Q0 = 0;
        state.R = PMMPricing.RState.ONE;
    }

    function getExpectedAvgPrice() external view returns (uint256) {

        require(!_SETTLED_, "ALREADY_SETTLED");
        (uint256 poolBase, uint256 poolQuote, , , ) = getSettleResult();
        return DecimalMath.divCeil(poolQuote, _BASE_TOKEN_.balanceOf(address(this)).sub(poolBase));
    }


    function _getQuoteInput() internal view returns (uint256 input) {

        return _QUOTE_TOKEN_.balanceOf(address(this)).sub(_QUOTE_RESERVE_);
    }


    function _sync() internal {

        uint256 quoteBalance = _QUOTE_TOKEN_.balanceOf(address(this));
        if (quoteBalance != _QUOTE_RESERVE_) {
            _QUOTE_RESERVE_ = quoteBalance;
        }
    }


    function _transferBaseOut(address to, uint256 amount) internal {

        if (amount > 0) {
            _BASE_TOKEN_.safeTransfer(to, amount);
        }
    }

    function _transferQuoteOut(address to, uint256 amount) internal {

        if (amount > 0) {
            _QUOTE_TOKEN_.safeTransfer(to, amount);
        }
    }

    function getShares(address user) external view returns (uint256) {

        return _SHARES_[user];
    }
}





contract CPVesting is CPFunding {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    
    event ClaimBaseToken(address user, uint256 baseAmount);
    event ClaimQuoteToken(address user, uint256 quoteAmount);
    event ClaimLP(uint256 amount);



    modifier afterSettlement() {

        require(_SETTLED_, "NOT_SETTLED");
        _;
    }

    modifier afterFreeze() {

        require(_SETTLED_ && block.timestamp >= _SETTLED_TIME_.add(_FREEZE_DURATION_), "FREEZED");
        _;
    }

    modifier afterClaimFreeze() {

        require(_SETTLED_ && block.timestamp >= _SETTLED_TIME_.add(_TOKEN_CLAIM_DURATION_), "CLAIM_FREEZED");
        _;
    }


    function bidderClaim(address to, bytes calldata data) external {

        if(_SETTLED_) {
            _claimQuoteToken(to, data);
        }

        if(_SETTLED_ && block.timestamp >= _SETTLED_TIME_.add(_TOKEN_CLAIM_DURATION_)) {
            _claimBaseToken(to);
        }
    }

    function _claimQuoteToken(address to,bytes calldata data) internal {

        if(_CLAIMED_QUOTE_[msg.sender]) return;

        _CLAIMED_QUOTE_[msg.sender] = true;

		uint256 quoteAmount = _UNUSED_QUOTE_.mul(_SHARES_[msg.sender]).div(_TOTAL_SHARES_);

        _transferQuoteOut(to, quoteAmount);

		if(data.length>0){
			IDODOCallee(to).CPClaimBidCall(msg.sender,0,quoteAmount,data);
		}

        emit ClaimQuoteToken(msg.sender, quoteAmount);
    }

    function _claimBaseToken(address to) internal {

        uint256 claimableBaseAmount = getClaimableBaseToken(msg.sender);
        _CLAIMED_BASE_TOKEN_[msg.sender] = _CLAIMED_BASE_TOKEN_[msg.sender].add(claimableBaseAmount);
        _transferBaseOut(to, claimableBaseAmount);
        emit ClaimBaseToken(msg.sender, claimableBaseAmount);
    }

    function getClaimableBaseToken(address user) public view afterClaimFreeze returns (uint256) {

        uint256 baseTotalAmount = _UNUSED_BASE_.mul(_SHARES_[user]).div(_TOTAL_SHARES_);

        uint256 remainingBaseToken = DecimalMath.mulFloor(
            getRemainingBaseTokenRatio(block.timestamp),
            baseTotalAmount
        );
        return baseTotalAmount.sub(remainingBaseToken).sub(_CLAIMED_BASE_TOKEN_[user]);
    }

    function getRemainingBaseTokenRatio(uint256 timestamp) public view afterClaimFreeze returns (uint256) {

        uint256 timePast = timestamp.sub(_SETTLED_TIME_.add(_TOKEN_CLAIM_DURATION_));
        if (timePast < _TOKEN_VESTING_DURATION_) {
            uint256 remainingTime = _TOKEN_VESTING_DURATION_.sub(timePast);
            return DecimalMath.ONE.sub(_TOKEN_CLIFF_RATE_).mul(remainingTime).div(_TOKEN_VESTING_DURATION_);
        } else {
            return 0;
        }
    }


    function claimLPToken() external onlyOwner afterFreeze {

        uint256 lpAmount = getClaimableLPToken();
        IERC20(_POOL_).safeTransfer(_OWNER_, lpAmount);
        emit ClaimLP(lpAmount);
    }

    function getClaimableLPToken() public view afterFreeze returns (uint256) {

        uint256 remainingLPToken = DecimalMath.mulFloor(
            getRemainingLPRatio(block.timestamp),
            _TOTAL_LP_AMOUNT_
        );
        return IERC20(_POOL_).balanceOf(address(this)).sub(remainingLPToken);
    }

    function getRemainingLPRatio(uint256 timestamp) public view afterFreeze returns (uint256) {

        uint256 timePast = timestamp.sub(_SETTLED_TIME_.add(_FREEZE_DURATION_));
        if (timePast < _VESTING_DURATION_) {
            uint256 remainingTime = _VESTING_DURATION_.sub(timePast);
            return DecimalMath.ONE.sub(_CLIFF_RATE_).mul(remainingTime).div(_VESTING_DURATION_);
        } else {
            return 0;
        }
    }
}




contract CP is CPVesting {

    using SafeMath for uint256;

    receive() external payable {
        require(_INITIALIZED_ == false, "WE_NOT_SAVE_ETH_AFTER_INIT");
    }

    function init(
        address[] calldata addressList,
        uint256[] calldata timeLine,
        uint256[] calldata valueList,
        bool[] calldata switches //0 isOverCapStop 1 isOpenTWAP
    ) external {


        require(addressList.length == 7, "LIST_LENGTH_WRONG");

        initOwner(addressList[0]);
        _MAINTAINER_ = addressList[1];
        _BASE_TOKEN_ = IERC20(addressList[2]);
        _QUOTE_TOKEN_ = IERC20(addressList[3]);
        _BIDDER_PERMISSION_ = IPermissionManager(addressList[4]);
        _MT_FEE_RATE_MODEL_ = IFeeRateModel(addressList[5]);
        _POOL_FACTORY_ = addressList[6];


        require(timeLine.length == 7, "LIST_LENGTH_WRONG");

        _PHASE_BID_STARTTIME_ = timeLine[0];
        _PHASE_BID_ENDTIME_ = _PHASE_BID_STARTTIME_.add(timeLine[1]);
        _PHASE_CALM_ENDTIME_ = _PHASE_BID_ENDTIME_.add(timeLine[2]);

        _FREEZE_DURATION_ = timeLine[3];
        _VESTING_DURATION_ = timeLine[4];
        _TOKEN_CLAIM_DURATION_ = timeLine[5];
        _TOKEN_VESTING_DURATION_ = timeLine[6];
        require(block.timestamp <= _PHASE_BID_STARTTIME_, "TIMELINE_WRONG");


        require(valueList.length == 6, "LIST_LENGTH_WRONG");

        _POOL_QUOTE_CAP_ = valueList[0];
        _K_ = valueList[1];
        _I_ = valueList[2];
        _CLIFF_RATE_ = valueList[3];
        _TOKEN_CLIFF_RATE_ = valueList[4];
        _POOL_FEE_RATE_ = valueList[5];

        require(_I_ > 0 && _I_ <= 1e36, "I_VALUE_WRONG");
        require(_K_ <= 1e18, "K_VALUE_WRONG");
        require(_CLIFF_RATE_ <= 1e18, "CLIFF_RATE_WRONG");
        require(_TOKEN_CLIFF_RATE_ <= 1e18, "TOKEN_CLIFF_RATE_WRONG");

        _TOTAL_BASE_ = _BASE_TOKEN_.balanceOf(address(this));

        require(switches.length == 2, "SWITCHES_LENGTH_WRONG");

        _IS_OVERCAP_STOP = switches[0];
        _IS_OPEN_TWAP_ = switches[1];

        require(address(this).balance == _SETTEL_FUND_, "SETTLE_FUND_NOT_MATCH");
    }


    function version() virtual external pure returns (string memory) {

        return "CP 2.0.0";
    }

    
    function getCpInfoHelper(address user) external view returns (
        bool isSettled,
        uint256 settledTime,
        uint256 claimableBaseToken,
        uint256 claimedBaseToken,
        bool isClaimedQuoteToken,
        uint256 claimableQuoteToken,
        address pool,
        uint256 claimableLpToken,
        uint256 myShares,
        bool isOverCapStop
    ) {

        isSettled = _SETTLED_;
        settledTime = _SETTLED_TIME_;
        if(_SETTLED_ && block.timestamp >= _SETTLED_TIME_.add(_TOKEN_CLAIM_DURATION_)) {
            claimableBaseToken = getClaimableBaseToken(user);
            claimedBaseToken = _CLAIMED_BASE_TOKEN_[user];
        }else {
            claimableBaseToken = 0;
            claimedBaseToken = 0;
        }

        if(_SETTLED_) {
            if(_CLAIMED_QUOTE_[msg.sender]) {
                isClaimedQuoteToken = true;
                claimableQuoteToken = 0;
            } else {
                isClaimedQuoteToken = false;
                claimableQuoteToken = _UNUSED_QUOTE_.mul(_SHARES_[user]).div(_TOTAL_SHARES_);
            }
        } else {
            isClaimedQuoteToken = false;
            claimableQuoteToken = 0;
        }

        pool = _POOL_;

        if(_SETTLED_ && block.timestamp >= _SETTLED_TIME_.add(_FREEZE_DURATION_)) {
            if(user == _OWNER_) {
                claimableLpToken = getClaimableLPToken();
            }else {
                claimableLpToken = 0;
            }
        }else {
            claimableLpToken = 0;
        }

        myShares = _SHARES_[user];

        isOverCapStop = _IS_OVERCAP_STOP;
    }
}