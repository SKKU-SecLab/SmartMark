pragma solidity ^0.8.0;

interface BridgeAdminInterface {

    event SetDepositContracts(
        uint256 indexed chainId,
        address indexed l2DepositContract,
        address indexed l2MessengerContract
    );
    event SetCrossDomainAdmin(uint256 indexed chainId, address indexed newAdmin);
    event SetRelayIdentifier(bytes32 indexed identifier);
    event SetOptimisticOracleLiveness(uint32 indexed liveness);
    event SetProposerBondPct(uint64 indexed proposerBondPct);
    event WhitelistToken(uint256 chainId, address indexed l1Token, address indexed l2Token, address indexed bridgePool);
    event SetMinimumBridgingDelay(uint256 indexed chainId, uint64 newMinimumBridgingDelay);
    event DepositsEnabled(uint256 indexed chainId, address indexed l2Token, bool depositsEnabled);
    event BridgePoolsAdminTransferred(address[] bridgePools, address indexed newAdmin);
    event SetLpFeeRate(address indexed bridgePool, uint64 newLpFeeRatePerSecond);

    function finder() external view returns (address);


    struct DepositUtilityContracts {
        address depositContract; // L2 deposit contract where cross-chain relays originate.
        address messengerContract; // L1 helper contract that can send a message to the L2 with the mapped network ID.
    }

    function depositContracts(uint256) external view returns (DepositUtilityContracts memory);


    struct L1TokenRelationships {
        mapping(uint256 => address) l2Tokens; // L2 Chain Id to l2Token address.
        address bridgePool;
    }

    function whitelistedTokens(address, uint256) external view returns (address l2Token, address bridgePool);


    function optimisticOracleLiveness() external view returns (uint32);


    function proposerBondPct() external view returns (uint64);


    function identifier() external view returns (bytes32);

}// MIT

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
}// AGPL-3.0-only
pragma solidity ^0.8.0;


interface BridgePoolInterface {

    function l1Token() external view returns (IERC20);


    function changeAdmin(address newAdmin) external;


    function setLpFeeRatePerSecond(uint64 _newLpFeeRatePerSecond) external;


    function setRelaysEnabled(bool _relaysEnabled) external;

}// AGPL-3.0-only
pragma solidity ^0.8.0;


abstract contract OptimisticOracleInterface {
    enum State {
        Invalid, // Never requested.
        Requested, // Requested, no other actions taken.
        Proposed, // Proposed, but not expired or disputed yet.
        Expired, // Proposed, not disputed, past liveness.
        Disputed, // Disputed, but no DVM price returned yet.
        Resolved, // Disputed and DVM price is available.
        Settled // Final price has been set in the contract (can get here from Expired or Resolved).
    }

    struct Request {
        address proposer; // Address of the proposer.
        address disputer; // Address of the disputer.
        IERC20 currency; // ERC20 token used to pay rewards and fees.
        bool settled; // True if the request is settled.
        bool refundOnDispute; // True if the requester should be refunded their reward on dispute.
        int256 proposedPrice; // Price that the proposer submitted.
        int256 resolvedPrice; // Price resolved once the request is settled.
        uint256 expirationTime; // Time at which the request auto-settles without a dispute.
        uint256 reward; // Amount of the currency to pay to the proposer on settlement.
        uint256 finalFee; // Final fee to pay to the Store upon request to the DVM.
        uint256 bond; // Bond that the proposer and disputer must pay on top of the final fee.
        uint256 customLiveness; // Custom liveness value set by the requester.
    }

    uint256 public constant ancillaryBytesLimit = 8192;

    function requestPrice(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        IERC20 currency,
        uint256 reward
    ) external virtual returns (uint256 totalBond);

    function setBond(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        uint256 bond
    ) external virtual returns (uint256 totalBond);

    function setRefundOnDispute(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external virtual;

    function setCustomLiveness(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        uint256 customLiveness
    ) external virtual;

    function proposePriceFor(
        address proposer,
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        int256 proposedPrice
    ) public virtual returns (uint256 totalBond);

    function proposePrice(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        int256 proposedPrice
    ) external virtual returns (uint256 totalBond);

    function disputePriceFor(
        address disputer,
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) public virtual returns (uint256 totalBond);

    function disputePrice(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external virtual returns (uint256 totalBond);

    function settleAndGetPrice(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external virtual returns (int256);

    function settle(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external virtual returns (uint256 payout);

    function getRequest(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) public view virtual returns (Request memory);

    function getState(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) public view virtual returns (State);

    function hasPrice(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) public view virtual returns (bool);

    function stampAncillaryData(bytes memory ancillaryData, address requester)
        public
        view
        virtual
        returns (bytes memory);
}// AGPL-3.0-only
pragma solidity ^0.8.0;


abstract contract SkinnyOptimisticOracleInterface {
    struct Request {
        address proposer; // Address of the proposer.
        address disputer; // Address of the disputer.
        IERC20 currency; // ERC20 token used to pay rewards and fees.
        bool settled; // True if the request is settled.
        int256 proposedPrice; // Price that the proposer submitted.
        int256 resolvedPrice; // Price resolved once the request is settled.
        uint256 expirationTime; // Time at which the request auto-settles without a dispute.
        uint256 reward; // Amount of the currency to pay to the proposer on settlement.
        uint256 finalFee; // Final fee to pay to the Store upon request to the DVM.
        uint256 bond; // Bond that the proposer and disputer must pay on top of the final fee.
        uint256 customLiveness; // Custom liveness value set by the requester.
    }

    uint256 public constant ancillaryBytesLimit = 8192;

    function requestPrice(
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        IERC20 currency,
        uint256 reward,
        uint256 bond,
        uint256 customLiveness
    ) external virtual returns (uint256 totalBond);

    function proposePriceFor(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request,
        address proposer,
        int256 proposedPrice
    ) public virtual returns (uint256 totalBond);

    function proposePrice(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request,
        int256 proposedPrice
    ) external virtual returns (uint256 totalBond);

    function requestAndProposePriceFor(
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        IERC20 currency,
        uint256 reward,
        uint256 bond,
        uint256 customLiveness,
        address proposer,
        int256 proposedPrice
    ) external virtual returns (uint256 totalBond);

    function disputePriceFor(
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request,
        address disputer,
        address requester
    ) public virtual returns (uint256 totalBond);

    function disputePrice(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) external virtual returns (uint256 totalBond);

    function settle(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) external virtual returns (uint256 payout, int256 resolvedPrice);

    function getState(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) external virtual returns (OptimisticOracleInterface.State);

    function hasPrice(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) public virtual returns (bool);

    function stampAncillaryData(bytes memory ancillaryData, address requester)
        public
        pure
        virtual
        returns (bytes memory);
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library SignedSafeMath {

    function mul(int256 a, int256 b) internal pure returns (int256) {

        return a * b;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        return a - b;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        return a + b;
    }
}// AGPL-3.0-only
pragma solidity ^0.8.0;


library FixedPoint {

    using SafeMath for uint256;
    using SignedSafeMath for int256;

    uint256 private constant FP_SCALING_FACTOR = 10**18;

    struct Unsigned {
        uint256 rawValue;
    }

    function fromUnscaledUint(uint256 a) internal pure returns (Unsigned memory) {

        return Unsigned(a.mul(FP_SCALING_FACTOR));
    }

    function isEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue == fromUnscaledUint(b).rawValue;
    }

    function isEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue == b.rawValue;
    }

    function isGreaterThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue > b.rawValue;
    }

    function isGreaterThan(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue > fromUnscaledUint(b).rawValue;
    }

    function isGreaterThan(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue > b.rawValue;
    }

    function isGreaterThanOrEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue >= b.rawValue;
    }

    function isGreaterThanOrEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue >= fromUnscaledUint(b).rawValue;
    }

    function isGreaterThanOrEqual(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue >= b.rawValue;
    }

    function isLessThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue < b.rawValue;
    }

    function isLessThan(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue < fromUnscaledUint(b).rawValue;
    }

    function isLessThan(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue < b.rawValue;
    }

    function isLessThanOrEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue <= b.rawValue;
    }

    function isLessThanOrEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue <= fromUnscaledUint(b).rawValue;
    }

    function isLessThanOrEqual(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue <= b.rawValue;
    }

    function min(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return a.rawValue < b.rawValue ? a : b;
    }

    function max(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return a.rawValue > b.rawValue ? a : b;
    }

    function add(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.add(b.rawValue));
    }

    function add(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return add(a, fromUnscaledUint(b));
    }

    function sub(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.sub(b.rawValue));
    }

    function sub(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return sub(a, fromUnscaledUint(b));
    }

    function sub(uint256 a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return sub(fromUnscaledUint(a), b);
    }

    function mul(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(b.rawValue) / FP_SCALING_FACTOR);
    }

    function mul(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(b));
    }

    function mulCeil(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        uint256 mulRaw = a.rawValue.mul(b.rawValue);
        uint256 mulFloor = mulRaw / FP_SCALING_FACTOR;
        uint256 mod = mulRaw.mod(FP_SCALING_FACTOR);
        if (mod != 0) {
            return Unsigned(mulFloor.add(1));
        } else {
            return Unsigned(mulFloor);
        }
    }

    function mulCeil(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(b));
    }

    function div(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(FP_SCALING_FACTOR).div(b.rawValue));
    }

    function div(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.div(b));
    }

    function div(uint256 a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return div(fromUnscaledUint(a), b);
    }

    function divCeil(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        uint256 aScaled = a.rawValue.mul(FP_SCALING_FACTOR);
        uint256 divFloor = aScaled.div(b.rawValue);
        uint256 mod = aScaled.mod(b.rawValue);
        if (mod != 0) {
            return Unsigned(divFloor.add(1));
        } else {
            return Unsigned(divFloor);
        }
    }

    function divCeil(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return divCeil(a, fromUnscaledUint(b));
    }

    function pow(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory output) {

        output = fromUnscaledUint(1);
        for (uint256 i = 0; i < b; i = i.add(1)) {
            output = mul(output, a);
        }
    }

    int256 private constant SFP_SCALING_FACTOR = 10**18;

    struct Signed {
        int256 rawValue;
    }

    function fromSigned(Signed memory a) internal pure returns (Unsigned memory) {

        require(a.rawValue >= 0, "Negative value provided");
        return Unsigned(uint256(a.rawValue));
    }

    function fromUnsigned(Unsigned memory a) internal pure returns (Signed memory) {

        require(a.rawValue <= uint256(type(int256).max), "Unsigned too large");
        return Signed(int256(a.rawValue));
    }

    function fromUnscaledInt(int256 a) internal pure returns (Signed memory) {

        return Signed(a.mul(SFP_SCALING_FACTOR));
    }

    function isEqual(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue == fromUnscaledInt(b).rawValue;
    }

    function isEqual(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue == b.rawValue;
    }

    function isGreaterThan(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue > b.rawValue;
    }

    function isGreaterThan(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue > fromUnscaledInt(b).rawValue;
    }

    function isGreaterThan(int256 a, Signed memory b) internal pure returns (bool) {

        return fromUnscaledInt(a).rawValue > b.rawValue;
    }

    function isGreaterThanOrEqual(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue >= b.rawValue;
    }

    function isGreaterThanOrEqual(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue >= fromUnscaledInt(b).rawValue;
    }

    function isGreaterThanOrEqual(int256 a, Signed memory b) internal pure returns (bool) {

        return fromUnscaledInt(a).rawValue >= b.rawValue;
    }

    function isLessThan(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue < b.rawValue;
    }

    function isLessThan(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue < fromUnscaledInt(b).rawValue;
    }

    function isLessThan(int256 a, Signed memory b) internal pure returns (bool) {

        return fromUnscaledInt(a).rawValue < b.rawValue;
    }

    function isLessThanOrEqual(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue <= b.rawValue;
    }

    function isLessThanOrEqual(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue <= fromUnscaledInt(b).rawValue;
    }

    function isLessThanOrEqual(int256 a, Signed memory b) internal pure returns (bool) {

        return fromUnscaledInt(a).rawValue <= b.rawValue;
    }

    function min(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return a.rawValue < b.rawValue ? a : b;
    }

    function max(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return a.rawValue > b.rawValue ? a : b;
    }

    function add(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.add(b.rawValue));
    }

    function add(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return add(a, fromUnscaledInt(b));
    }

    function sub(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.sub(b.rawValue));
    }

    function sub(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return sub(a, fromUnscaledInt(b));
    }

    function sub(int256 a, Signed memory b) internal pure returns (Signed memory) {

        return sub(fromUnscaledInt(a), b);
    }

    function mul(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.mul(b.rawValue) / SFP_SCALING_FACTOR);
    }

    function mul(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.mul(b));
    }

    function mulAwayFromZero(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        int256 mulRaw = a.rawValue.mul(b.rawValue);
        int256 mulTowardsZero = mulRaw / SFP_SCALING_FACTOR;
        int256 mod = mulRaw % SFP_SCALING_FACTOR;
        if (mod != 0) {
            bool isResultPositive = isLessThan(a, 0) == isLessThan(b, 0);
            int256 valueToAdd = isResultPositive ? int256(1) : int256(-1);
            return Signed(mulTowardsZero.add(valueToAdd));
        } else {
            return Signed(mulTowardsZero);
        }
    }

    function mulAwayFromZero(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.mul(b));
    }

    function div(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.mul(SFP_SCALING_FACTOR).div(b.rawValue));
    }

    function div(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.div(b));
    }

    function div(int256 a, Signed memory b) internal pure returns (Signed memory) {

        return div(fromUnscaledInt(a), b);
    }

    function divAwayFromZero(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        int256 aScaled = a.rawValue.mul(SFP_SCALING_FACTOR);
        int256 divTowardsZero = aScaled.div(b.rawValue);
        int256 mod = aScaled % b.rawValue;
        if (mod != 0) {
            bool isResultPositive = isLessThan(a, 0) == isLessThan(b, 0);
            int256 valueToAdd = isResultPositive ? int256(1) : int256(-1);
            return Signed(divTowardsZero.add(valueToAdd));
        } else {
            return Signed(divTowardsZero);
        }
    }

    function divAwayFromZero(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return divAwayFromZero(a, fromUnscaledInt(b));
    }

    function pow(Signed memory a, uint256 b) internal pure returns (Signed memory output) {

        output = fromUnscaledInt(1);
        for (uint256 i = 0; i < b; i = i.add(1)) {
            output = mul(output, a);
        }
    }
}// AGPL-3.0-only
pragma solidity ^0.8.0;


interface StoreInterface {

    function payOracleFees() external payable;


    function payOracleFeesErc20(address erc20Address, FixedPoint.Unsigned calldata amount) external;


    function computeRegularFee(
        uint256 startTime,
        uint256 endTime,
        FixedPoint.Unsigned calldata pfc
    ) external view returns (FixedPoint.Unsigned memory regularFee, FixedPoint.Unsigned memory latePenalty);


    function computeFinalFee(address currency) external view returns (FixedPoint.Unsigned memory);

}// AGPL-3.0-only
pragma solidity ^0.8.0;

interface FinderInterface {

    function changeImplementationAddress(bytes32 interfaceName, address implementationAddress) external;


    function getImplementationAddress(bytes32 interfaceName) external view returns (address);

}// AGPL-3.0-only
pragma solidity ^0.8.0;

library OracleInterfaces {

    bytes32 public constant Oracle = "Oracle";
    bytes32 public constant IdentifierWhitelist = "IdentifierWhitelist";
    bytes32 public constant Store = "Store";
    bytes32 public constant FinancialContractsAdmin = "FinancialContractsAdmin";
    bytes32 public constant Registry = "Registry";
    bytes32 public constant CollateralWhitelist = "CollateralWhitelist";
    bytes32 public constant OptimisticOracle = "OptimisticOracle";
    bytes32 public constant Bridge = "Bridge";
    bytes32 public constant GenericHandler = "GenericHandler";
    bytes32 public constant SkinnyOptimisticOracle = "SkinnyOptimisticOracle";
}

library OptimisticOracleConstraints {

    uint256 public constant ancillaryBytesLimit = 8192;
}// AGPL-3.0-only
pragma solidity ^0.8.0;

library AncillaryData {

    function toUtf8Bytes32Bottom(bytes32 bytesIn) private pure returns (bytes32) {

        unchecked {
            uint256 x = uint256(bytesIn);

            x = x & 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
            x = (x | (x * 2**64)) & 0x0000000000000000ffffffffffffffff0000000000000000ffffffffffffffff;
            x = (x | (x * 2**32)) & 0x00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff;
            x = (x | (x * 2**16)) & 0x0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff;
            x = (x | (x * 2**8)) & 0x00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff;
            x = (x | (x * 2**4)) & 0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;

            uint256 h = (x & 0x0808080808080808080808080808080808080808080808080808080808080808) / 8;
            uint256 i = (x & 0x0404040404040404040404040404040404040404040404040404040404040404) / 4;
            uint256 j = (x & 0x0202020202020202020202020202020202020202020202020202020202020202) / 2;
            x = x + (h & (i | j)) * 0x27 + 0x3030303030303030303030303030303030303030303030303030303030303030;

            return bytes32(x);
        }
    }

    function toUtf8Bytes(bytes32 bytesIn) internal pure returns (bytes memory) {

        return abi.encodePacked(toUtf8Bytes32Bottom(bytesIn >> 128), toUtf8Bytes32Bottom(bytesIn));
    }

    function toUtf8BytesAddress(address x) internal pure returns (bytes memory) {

        return
            abi.encodePacked(toUtf8Bytes32Bottom(bytes32(bytes20(x)) >> 128), bytes8(toUtf8Bytes32Bottom(bytes20(x))));
    }

    function toUtf8BytesUint(uint256 x) internal pure returns (bytes memory) {

        if (x == 0) {
            return "0";
        }
        uint256 j = x;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (x != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(x - (x / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            x /= 10;
        }
        return bstr;
    }

    function appendKeyValueBytes32(
        bytes memory currentAncillaryData,
        bytes memory key,
        bytes32 value
    ) internal pure returns (bytes memory) {

        bytes memory prefix = constructPrefix(currentAncillaryData, key);
        return abi.encodePacked(currentAncillaryData, prefix, toUtf8Bytes(value));
    }

    function appendKeyValueAddress(
        bytes memory currentAncillaryData,
        bytes memory key,
        address value
    ) internal pure returns (bytes memory) {

        bytes memory prefix = constructPrefix(currentAncillaryData, key);
        return abi.encodePacked(currentAncillaryData, prefix, toUtf8BytesAddress(value));
    }

    function appendKeyValueUint(
        bytes memory currentAncillaryData,
        bytes memory key,
        uint256 value
    ) internal pure returns (bytes memory) {

        bytes memory prefix = constructPrefix(currentAncillaryData, key);
        return abi.encodePacked(currentAncillaryData, prefix, toUtf8BytesUint(value));
    }

    function constructPrefix(bytes memory currentAncillaryData, bytes memory key) internal pure returns (bytes memory) {

        if (currentAncillaryData.length > 0) {
            return abi.encodePacked(",", key, ":");
        } else {
            return abi.encodePacked(key, ":");
        }
    }
}// AGPL-3.0-only
pragma solidity ^0.8.0;

contract Timer {

    uint256 private currentTime;

    constructor() {
        currentTime = block.timestamp; // solhint-disable-line not-rely-on-time
    }

    function setCurrentTime(uint256 time) external {

        currentTime = time;
    }

    function getCurrentTime() public view returns (uint256) {

        return currentTime;
    }
}// AGPL-3.0-only
pragma solidity ^0.8.0;


abstract contract Testable {
    address public timerAddress;

    constructor(address _timerAddress) {
        timerAddress = _timerAddress;
    }

    modifier onlyIfTest {
        require(timerAddress != address(0x0));
        _;
    }

    function setCurrentTime(uint256 time) external onlyIfTest {
        Timer(timerAddress).setCurrentTime(time);
    }

    function getCurrentTime() public view virtual returns (uint256) {
        if (timerAddress != address(0x0)) {
            return Timer(timerAddress).getCurrentTime();
        } else {
            return block.timestamp; // solhint-disable-line not-rely-on-time
        }
    }
}// AGPL-3.0-only
pragma solidity ^0.8.0;

contract Lockable {

    bool private _notEntered;

    constructor() {
        _notEntered = true;
    }

    modifier nonReentrant() {

        _preEntranceCheck();
        _preEntranceSet();
        _;
        _postEntranceReset();
    }

    modifier nonReentrantView() {

        _preEntranceCheck();
        _;
    }

    function _preEntranceCheck() internal view {

        require(_notEntered, "ReentrancyGuard: reentrant call");
    }

    function _preEntranceSet() internal {

        _notEntered = false;
    }

    function _postEntranceReset() internal {

        _notEntered = true;
    }
}// This contract is taken from Uniswaps's multi call implementation (https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/base/Multicall.sol)
pragma solidity ^0.8.0;

contract MultiCaller {

    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results) {

        require(msg.value == 0, "Only multicall with 0 value");
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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
}// AGPL-3.0-only
pragma solidity ^0.8.0;





interface WETH9Like {
    function withdraw(uint256 wad) external;

    function deposit() external payable;
}

contract BridgePool is MultiCaller, Testable, BridgePoolInterface, ERC20, Lockable {
    using SafeERC20 for IERC20;
    using FixedPoint for FixedPoint.Unsigned;
    using Address for address;

    IERC20 public override l1Token;

    uint32 public numberOfRelays;

    uint256 public liquidReserves;

    int256 public utilizedReserves;

    uint256 public pendingReserves;

    bool public isWethPool;

    bool public relaysEnabled = true;

    uint64 public lpFeeRatePerSecond;

    uint32 public lastLpFeeUpdate;

    uint64 public proposerBondPct;
    uint32 public optimisticOracleLiveness;

    uint256 l1TokenFinalFee;

    uint256 public undistributedLpFees;

    uint256 public bonds;

    BridgeAdminInterface public bridgeAdmin;

    StoreInterface public store;
    SkinnyOptimisticOracleInterface public optimisticOracle;

    bytes32 public identifier;

    enum RelayState { Uninitialized, Pending, Finalized }

    struct DepositData {
        uint256 chainId;
        uint64 depositId;
        address payable l1Recipient;
        address l2Sender;
        uint256 amount;
        uint64 slowRelayFeePct;
        uint64 instantRelayFeePct;
        uint32 quoteTimestamp;
    }

    struct RelayData {
        RelayState relayState;
        address slowRelayer;
        uint32 relayId;
        uint64 realizedLpFeePct;
        uint32 priceRequestTime;
        uint256 proposerBond;
        uint256 finalFee;
    }

    mapping(bytes32 => bytes32) public relays;

    mapping(bytes32 => address) public instantRelays;

    event LiquidityAdded(uint256 amount, uint256 lpTokensMinted, address indexed liquidityProvider);
    event LiquidityRemoved(uint256 amount, uint256 lpTokensBurnt, address indexed liquidityProvider);
    event DepositRelayed(
        bytes32 indexed depositHash,
        DepositData depositData,
        RelayData relay,
        bytes32 relayAncillaryDataHash
    );
    event RelaySpedUp(bytes32 indexed depositHash, address indexed instantRelayer, RelayData relay);

    event RelayDisputed(bytes32 indexed depositHash, bytes32 indexed relayHash, address indexed disputer);
    event RelayCanceled(bytes32 indexed depositHash, bytes32 indexed relayHash, address indexed disputer);
    event RelaySettled(bytes32 indexed depositHash, address indexed caller, RelayData relay);
    event BridgePoolAdminTransferred(address oldAdmin, address newAdmin);
    event RelaysEnabledSet(bool newRelaysEnabled);
    event LpFeeRateSet(uint64 newLpFeeRatePerSecond);

    modifier onlyBridgeAdmin() {
        require(msg.sender == address(bridgeAdmin), "Caller not bridge admin");
        _;
    }

    modifier onlyIfRelaysEnabld() {
        require(relaysEnabled, "Relays are disabled");
        _;
    }

    constructor(
        string memory _lpTokenName,
        string memory _lpTokenSymbol,
        address _bridgeAdmin,
        address _l1Token,
        uint64 _lpFeeRatePerSecond,
        bool _isWethPool,
        address _timer
    ) Testable(_timer) ERC20(_lpTokenName, _lpTokenSymbol) {
        require(bytes(_lpTokenName).length != 0 && bytes(_lpTokenSymbol).length != 0, "Bad LP token name or symbol");
        bridgeAdmin = BridgeAdminInterface(_bridgeAdmin);
        l1Token = IERC20(_l1Token);
        lastLpFeeUpdate = uint32(getCurrentTime());
        lpFeeRatePerSecond = _lpFeeRatePerSecond;
        isWethPool = _isWethPool;

        syncUmaEcosystemParams(); // Fetch OptimisticOracle and Store addresses and L1Token finalFee.
        syncWithBridgeAdminParams(); // Fetch ProposerBondPct OptimisticOracleLiveness, Identifier from the BridgeAdmin.

        emit LpFeeRateSet(lpFeeRatePerSecond);
    }


    function addLiquidity(uint256 l1TokenAmount) public payable nonReentrant() {
        require((isWethPool && msg.value == l1TokenAmount) || msg.value == 0, "Bad add liquidity Eth value");

        uint256 lpTokensToMint = (l1TokenAmount * 1e18) / _exchangeRateCurrent();
        _mint(msg.sender, lpTokensToMint);
        liquidReserves += l1TokenAmount;

        if (msg.value > 0 && isWethPool) WETH9Like(address(l1Token)).deposit{ value: msg.value }();
        else l1Token.safeTransferFrom(msg.sender, address(this), l1TokenAmount);

        emit LiquidityAdded(l1TokenAmount, lpTokensToMint, msg.sender);
    }

    function removeLiquidity(uint256 lpTokenAmount, bool sendEth) public nonReentrant() {
        require(!sendEth || isWethPool, "Cant send eth");
        uint256 l1TokensToReturn = (lpTokenAmount * _exchangeRateCurrent()) / 1e18;

        require(liquidReserves >= (pendingReserves + l1TokensToReturn), "Utilization too high to remove");

        _burn(msg.sender, lpTokenAmount);
        liquidReserves -= l1TokensToReturn;

        if (sendEth) _unwrapWETHTo(payable(msg.sender), l1TokensToReturn);
        else l1Token.safeTransfer(msg.sender, l1TokensToReturn);

        emit LiquidityRemoved(l1TokensToReturn, lpTokenAmount, msg.sender);
    }


    function relayAndSpeedUp(DepositData memory depositData, uint64 realizedLpFeePct)
        public
        onlyIfRelaysEnabld()
        nonReentrant()
    {
        uint32 priceRequestTime = uint32(getCurrentTime());

        require(
            depositData.slowRelayFeePct <= 0.25e18 &&
                depositData.instantRelayFeePct <= 0.25e18 &&
                realizedLpFeePct <= 0.5e18,
            "Invalid fees"
        );

        bytes32 depositHash = _getDepositHash(depositData);

        require(relays[depositHash] == bytes32(0), "Pending relay exists");

        uint256 proposerBond = _getProposerBond(depositData.amount);

        RelayData memory relayData =
            RelayData({
                relayState: RelayState.Pending,
                slowRelayer: msg.sender,
                relayId: numberOfRelays++, // Note: Increment numberOfRelays at the same time as setting relayId to its current value.
                realizedLpFeePct: realizedLpFeePct,
                priceRequestTime: priceRequestTime,
                proposerBond: proposerBond,
                finalFee: l1TokenFinalFee
            });
        bytes32 relayHash = _getRelayHash(depositData, relayData);
        relays[depositHash] = _getRelayDataHash(relayData);

        bytes32 instantRelayHash = _getInstantRelayHash(depositHash, relayData);
        require(
            instantRelays[instantRelayHash] == address(0),
            "Relay cannot be sped up"
        );

        require(liquidReserves - pendingReserves >= depositData.amount, "Insufficient pool balance");

        uint256 totalBond = proposerBond + l1TokenFinalFee;

        uint256 feesTotal =
            _getAmountFromPct(
                relayData.realizedLpFeePct + depositData.slowRelayFeePct + depositData.instantRelayFeePct,
                depositData.amount
            );
        uint256 recipientAmount = depositData.amount - feesTotal;

        bonds += totalBond;
        pendingReserves += depositData.amount; // Book off maximum liquidity used by this relay in the pending reserves.

        instantRelays[instantRelayHash] = msg.sender;

        l1Token.safeTransferFrom(msg.sender, address(this), recipientAmount + totalBond);

        if (isWethPool) {
            _unwrapWETHTo(depositData.l1Recipient, recipientAmount);
        } else l1Token.safeTransfer(depositData.l1Recipient, recipientAmount);

        emit DepositRelayed(depositHash, depositData, relayData, relayHash);
        emit RelaySpedUp(depositHash, msg.sender, relayData);
    }

    function disputeRelay(DepositData memory depositData, RelayData memory relayData) public nonReentrant() {
        require(relayData.priceRequestTime + optimisticOracleLiveness > getCurrentTime(), "Past liveness");
        require(relayData.relayState == RelayState.Pending, "Not disputable");
        bytes32 depositHash = _getDepositHash(depositData);
        _validateRelayDataHash(depositHash, relayData);

        bytes32 relayHash = _getRelayHash(depositData, relayData);

        bool success =
            _requestProposeDispute(
                relayData.slowRelayer,
                msg.sender,
                relayData.proposerBond,
                relayData.finalFee,
                _getRelayAncillaryData(relayHash)
            );

        bonds -= relayData.finalFee + relayData.proposerBond;
        pendingReserves -= depositData.amount;
        delete relays[depositHash];
        if (success) emit RelayDisputed(depositHash, _getRelayDataHash(relayData), msg.sender);
        else emit RelayCanceled(depositHash, _getRelayDataHash(relayData), msg.sender);
    }

    function relayDeposit(DepositData memory depositData, uint64 realizedLpFeePct)
        public
        onlyIfRelaysEnabld()
        nonReentrant()
    {
        require(
            depositData.slowRelayFeePct <= 0.25e18 &&
                depositData.instantRelayFeePct <= 0.25e18 &&
                realizedLpFeePct <= 0.5e18,
            "Invalid fees"
        );

        bytes32 depositHash = _getDepositHash(depositData);

        require(relays[depositHash] == bytes32(0), "Pending relay exists");

        uint32 priceRequestTime = uint32(getCurrentTime());

        uint256 proposerBond = _getProposerBond(depositData.amount);

        RelayData memory relayData =
            RelayData({
                relayState: RelayState.Pending,
                slowRelayer: msg.sender,
                relayId: numberOfRelays++, // Note: Increment numberOfRelays at the same time as setting relayId to its current value.
                realizedLpFeePct: realizedLpFeePct,
                priceRequestTime: priceRequestTime,
                proposerBond: proposerBond,
                finalFee: l1TokenFinalFee
            });
        relays[depositHash] = _getRelayDataHash(relayData);

        bytes32 relayHash = _getRelayHash(depositData, relayData);

        require(liquidReserves - pendingReserves >= depositData.amount, "Insufficient pool balance");

        uint256 totalBond = proposerBond + l1TokenFinalFee;
        pendingReserves += depositData.amount; // Book off maximum liquidity used by this relay in the pending reserves.
        bonds += totalBond;

        l1Token.safeTransferFrom(msg.sender, address(this), totalBond);
        emit DepositRelayed(depositHash, depositData, relayData, relayHash);
    }

    function speedUpRelay(DepositData memory depositData, RelayData memory relayData) public nonReentrant() {
        bytes32 depositHash = _getDepositHash(depositData);
        _validateRelayDataHash(depositHash, relayData);
        bytes32 instantRelayHash = _getInstantRelayHash(depositHash, relayData);
        require(
            getCurrentTime() < relayData.priceRequestTime + optimisticOracleLiveness &&
                relayData.relayState == RelayState.Pending &&
                instantRelays[instantRelayHash] == address(0),
            "Relay cannot be sped up"
        );
        instantRelays[instantRelayHash] = msg.sender;

        uint256 feesTotal =
            _getAmountFromPct(
                relayData.realizedLpFeePct + depositData.slowRelayFeePct + depositData.instantRelayFeePct,
                depositData.amount
            );
        uint256 recipientAmount = depositData.amount - feesTotal;
        if (isWethPool) {
            l1Token.safeTransferFrom(msg.sender, address(this), recipientAmount);
            _unwrapWETHTo(depositData.l1Recipient, recipientAmount);
        } else l1Token.safeTransferFrom(msg.sender, depositData.l1Recipient, recipientAmount);

        emit RelaySpedUp(depositHash, msg.sender, relayData);
    }

    function settleRelay(DepositData memory depositData, RelayData memory relayData) public nonReentrant() {
        bytes32 depositHash = _getDepositHash(depositData);
        _validateRelayDataHash(depositHash, relayData);
        require(relayData.relayState == RelayState.Pending, "Already settled");
        uint32 expirationTime = relayData.priceRequestTime + optimisticOracleLiveness;
        require(expirationTime <= getCurrentTime(), "Not settleable yet");

        require(
            msg.sender == relayData.slowRelayer || getCurrentTime() > expirationTime + 15 minutes,
            "Not slow relayer"
        );

        relays[depositHash] = _getRelayDataHash(
            RelayData({
                relayState: RelayState.Finalized,
                slowRelayer: relayData.slowRelayer,
                relayId: relayData.relayId,
                realizedLpFeePct: relayData.realizedLpFeePct,
                priceRequestTime: relayData.priceRequestTime,
                proposerBond: relayData.proposerBond,
                finalFee: relayData.finalFee
            })
        );


        uint256 instantRelayerOrRecipientAmount =
            depositData.amount -
                _getAmountFromPct(relayData.realizedLpFeePct + depositData.slowRelayFeePct, depositData.amount);

        bytes32 instantRelayHash = _getInstantRelayHash(depositHash, relayData);
        address instantRelayer = instantRelays[instantRelayHash];

        if (isWethPool && instantRelayer == address(0)) {
            _unwrapWETHTo(depositData.l1Recipient, instantRelayerOrRecipientAmount);
        } else
            l1Token.safeTransfer(
                instantRelayer != address(0) ? instantRelayer : depositData.l1Recipient,
                instantRelayerOrRecipientAmount
            );

        uint256 slowRelayerReward = _getAmountFromPct(depositData.slowRelayFeePct, depositData.amount);
        uint256 totalBond = relayData.finalFee + relayData.proposerBond;
        if (relayData.slowRelayer == msg.sender)
            l1Token.safeTransfer(relayData.slowRelayer, slowRelayerReward + totalBond);
        else {
            l1Token.safeTransfer(relayData.slowRelayer, totalBond);
            l1Token.safeTransfer(msg.sender, slowRelayerReward);
        }

        uint256 totalReservesSent = instantRelayerOrRecipientAmount + slowRelayerReward;

        pendingReserves -= depositData.amount;
        liquidReserves -= totalReservesSent;
        utilizedReserves += int256(totalReservesSent);
        bonds -= totalBond;
        _updateAccumulatedLpFees();
        _allocateLpFees(_getAmountFromPct(relayData.realizedLpFeePct, depositData.amount));

        emit RelaySettled(depositHash, msg.sender, relayData);

        delete instantRelays[instantRelayHash];
    }

    function sync() public nonReentrant() {
        _sync();
    }

    function exchangeRateCurrent() public nonReentrant() returns (uint256) {
        return _exchangeRateCurrent();
    }

    function liquidityUtilizationCurrent() public nonReentrant() returns (uint256) {
        return _liquidityUtilizationPostRelay(0);
    }

    function liquidityUtilizationPostRelay(uint256 relayedAmount) public nonReentrant() returns (uint256) {
        return _liquidityUtilizationPostRelay(relayedAmount);
    }

    function getLiquidityUtilization(uint256 relayedAmount)
        public
        nonReentrant()
        returns (uint256 utilizationCurrent, uint256 utilizationPostRelay)
    {
        return (_liquidityUtilizationPostRelay(0), _liquidityUtilizationPostRelay(relayedAmount));
    }

    function syncUmaEcosystemParams() public nonReentrant() {
        FinderInterface finder = FinderInterface(bridgeAdmin.finder());
        optimisticOracle = SkinnyOptimisticOracleInterface(
            finder.getImplementationAddress(OracleInterfaces.SkinnyOptimisticOracle)
        );

        store = StoreInterface(finder.getImplementationAddress(OracleInterfaces.Store));
        l1TokenFinalFee = store.computeFinalFee(address(l1Token)).rawValue;
    }

    function syncWithBridgeAdminParams() public nonReentrant() {
        proposerBondPct = bridgeAdmin.proposerBondPct();
        optimisticOracleLiveness = bridgeAdmin.optimisticOracleLiveness();
        identifier = bridgeAdmin.identifier();
    }


    function changeAdmin(address _newAdmin) public override onlyBridgeAdmin() nonReentrant() {
        bridgeAdmin = BridgeAdminInterface(_newAdmin);
        emit BridgePoolAdminTransferred(msg.sender, _newAdmin);
    }

    function setLpFeeRatePerSecond(uint64 _newLpFeeRatePerSecond) public override onlyBridgeAdmin() nonReentrant() {
        lpFeeRatePerSecond = _newLpFeeRatePerSecond;
        emit LpFeeRateSet(lpFeeRatePerSecond);
    }

    function setRelaysEnabled(bool _relaysEnabled) public override onlyBridgeAdmin() nonReentrant() {
        relaysEnabled = _relaysEnabled;
        emit RelaysEnabledSet(_relaysEnabled);
    }


    function getAccumulatedFees() public view nonReentrantView() returns (uint256) {
        return _getAccumulatedFees();
    }

    function getRelayAncillaryData(DepositData memory depositData, RelayData memory relayData)
        public
        view
        nonReentrantView()
        returns (bytes memory)
    {
        return _getRelayAncillaryData(_getRelayHash(depositData, relayData));
    }


    function _liquidityUtilizationPostRelay(uint256 relayedAmount) internal returns (uint256) {
        _sync(); // Fetch any balance changes due to token bridging finalization and factor them in.

        uint256 flooredUtilizedReserves = utilizedReserves > 0 ? uint256(utilizedReserves) : 0;
        uint256 numerator = relayedAmount + pendingReserves + flooredUtilizedReserves;
        uint256 denominator = liquidReserves + flooredUtilizedReserves;

        if (denominator == 0) return 1e18;

        return (numerator * 1e18) / denominator;
    }

    function _sync() internal {
        uint256 l1TokenBalance = l1Token.balanceOf(address(this)) - bonds;
        if (l1TokenBalance > liquidReserves) {
            utilizedReserves -= int256(l1TokenBalance - liquidReserves);
            liquidReserves = l1TokenBalance;
        }
    }

    function _exchangeRateCurrent() internal returns (uint256) {
        if (totalSupply() == 0) return 1e18; // initial rate is 1 pre any mint action.

        _updateAccumulatedLpFees(); // Accumulate all allocated fees from the last time this method was called.
        _sync(); // Fetch any balance changes due to token bridging finalization and factor them in.

        int256 numerator = int256(liquidReserves) + utilizedReserves - int256(undistributedLpFees);
        return (uint256(numerator) * 1e18) / totalSupply();
    }

    function _getRelayAncillaryData(bytes32 relayHash) private pure returns (bytes memory) {
        return AncillaryData.appendKeyValueBytes32("", "relayHash", relayHash);
    }

    function _getRelayHash(DepositData memory depositData, RelayData memory relayData) private view returns (bytes32) {
        return keccak256(abi.encode(depositData, relayData.relayId, relayData.realizedLpFeePct, address(l1Token)));
    }

    function _getRelayDataHash(RelayData memory relayData) private pure returns (bytes32) {
        return keccak256(abi.encode(relayData));
    }

    function _validateRelayDataHash(bytes32 depositHash, RelayData memory relayData) private view {
        require(
            relays[depositHash] == _getRelayDataHash(relayData),
            "Hashed relay params do not match existing relay hash for deposit"
        );
    }

    function _getInstantRelayHash(bytes32 depositHash, RelayData memory relayData) private pure returns (bytes32) {
        return keccak256(abi.encode(depositHash, relayData.realizedLpFeePct));
    }

    function _getAccumulatedFees() internal view returns (uint256) {
        uint256 possibleUnpaidFees =
            (undistributedLpFees * lpFeeRatePerSecond * (getCurrentTime() - lastLpFeeUpdate)) / (1e18);
        return possibleUnpaidFees < undistributedLpFees ? possibleUnpaidFees : undistributedLpFees;
    }

    function _updateAccumulatedLpFees() internal {
        uint256 unallocatedAccumulatedFees = _getAccumulatedFees();

        undistributedLpFees = undistributedLpFees - unallocatedAccumulatedFees;

        lastLpFeeUpdate = uint32(getCurrentTime());
    }

    function _allocateLpFees(uint256 allocatedLpFees) internal {
        undistributedLpFees += allocatedLpFees;
        utilizedReserves += int256(allocatedLpFees);
    }

    function _getAmountFromPct(uint64 percent, uint256 amount) private pure returns (uint256) {
        return (percent * amount) / 1e18;
    }

    function _getProposerBond(uint256 amount) private view returns (uint256) {
        return _getAmountFromPct(proposerBondPct, amount);
    }

    function _getDepositHash(DepositData memory depositData) private view returns (bytes32) {
        return keccak256(abi.encode(depositData, address(l1Token)));
    }

    function _requestProposeDispute(
        address proposer,
        address disputer,
        uint256 proposerBond,
        uint256 finalFee,
        bytes memory customAncillaryData
    ) private returns (bool) {
        uint256 totalBond = finalFee + proposerBond;
        l1Token.safeApprove(address(optimisticOracle), totalBond);
        try
            optimisticOracle.requestAndProposePriceFor(
                identifier,
                uint32(getCurrentTime()),
                customAncillaryData,
                IERC20(l1Token),
                0,
                proposerBond,
                optimisticOracleLiveness,
                proposer,
                int256(1e18)
            )
        returns (uint256 bondSpent) {
            if (bondSpent < totalBond) {
                uint256 refund = totalBond - bondSpent;
                l1Token.safeTransfer(proposer, refund);
                l1Token.safeApprove(address(optimisticOracle), 0);
                totalBond = bondSpent;
            }
        } catch {
            l1Token.safeTransfer(proposer, totalBond);
            l1Token.safeApprove(address(optimisticOracle), 0);

            return false;
        }

        SkinnyOptimisticOracleInterface.Request memory request =
            SkinnyOptimisticOracleInterface.Request({
                proposer: proposer,
                disputer: address(0),
                currency: IERC20(l1Token),
                settled: false,
                proposedPrice: int256(1e18),
                resolvedPrice: 0,
                expirationTime: getCurrentTime() + optimisticOracleLiveness,
                reward: 0,
                finalFee: totalBond - proposerBond,
                bond: proposerBond,
                customLiveness: uint256(optimisticOracleLiveness)
            });

        l1Token.safeTransferFrom(msg.sender, address(this), totalBond);
        l1Token.safeApprove(address(optimisticOracle), totalBond);
        optimisticOracle.disputePriceFor(
            identifier,
            uint32(getCurrentTime()),
            customAncillaryData,
            request,
            disputer,
            address(this)
        );

        return true;
    }

    function _unwrapWETHTo(address payable to, uint256 amount) internal {
        if (address(to).isContract()) {
            l1Token.safeTransfer(to, amount);
        } else {
            WETH9Like(address(l1Token)).withdraw(amount);
            to.transfer(amount);
        }
    }

    receive() external payable {}
}

contract BridgePoolProd is BridgePool {
    constructor(
        string memory _lpTokenName,
        string memory _lpTokenSymbol,
        address _bridgeAdmin,
        address _l1Token,
        uint64 _lpFeeRatePerSecond,
        bool _isWethPool,
        address _timer
    ) BridgePool(_lpTokenName, _lpTokenSymbol, _bridgeAdmin, _l1Token, _lpFeeRatePerSecond, _isWethPool, _timer) {}

    function getCurrentTime() public view virtual override returns (uint256) {
        return block.timestamp;
    }
}