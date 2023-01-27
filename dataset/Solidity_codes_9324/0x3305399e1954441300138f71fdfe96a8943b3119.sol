pragma solidity 0.5.16;

contract IAffiliateRegistry {

    function setAffiliate(address member, address affiliate) public;

    function setAffiliateFeeFrac(address affiliate, uint256 fee) public;

    function setDefaultAffiliate(address affiliate) public;

    function getAffiliate(address member) public view returns (address);

    function getAffiliateFeeFrac(address affiliate) public view returns (uint256);

    function getDefaultAffiliate() public view returns (address);

}pragma solidity 0.5.16;

contract IWhitelist {

    function addAddressToWhitelist(address) public;

    function removeAddressFromWhitelist(address) public;

    function getWhitelisted(address) public view returns (bool);

}pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;



contract AffiliateRegistry is IAffiliateRegistry {

    uint256 public constant MAX_AFFILIATE_FEE = 3*(10**19);

    IWhitelist private systemParamsWhitelist;

    address private defaultAffiliate;
    mapping (address => address) private addressToAffiliate;
    mapping (address => uint256) private affiliateFeeFrac;

    event AffiliateSet(
        address member,
        address affiliate
    );

    event AffiliateFeeFracSet(
        address affiliate,
        uint256 feeFrac
    );

    constructor(IWhitelist _systemParamsWhitelist) public {
        systemParamsWhitelist = _systemParamsWhitelist;
    }

    modifier onlySystemParamsAdmin() {

        require(
            systemParamsWhitelist.getWhitelisted(msg.sender),
            "NOT_SYSTEM_PARAM_ADMIN"
        );
        _;
    }

    function setAffiliate(address member, address affiliate)
        public
        onlySystemParamsAdmin
    {

        require(
            affiliate != address(0),
            "AFFILIATE_ZERO_ADDRESS"
        );

        addressToAffiliate[member] = affiliate;
    }

    function setAffiliateFeeFrac(address affiliate, uint256 feeFrac)
        public
        onlySystemParamsAdmin
    {

        require(
            feeFrac < MAX_AFFILIATE_FEE,
            "AFFILIATE_FEE_TOO_HIGH"
        );

        affiliateFeeFrac[affiliate] = feeFrac;
    }

    function setDefaultAffiliate(address affiliate)
        public
        onlySystemParamsAdmin
    {

        require(
            affiliate != address(0),
            "AFFILIATE_ZERO_ADDRESS"
        );

        defaultAffiliate = affiliate;
    }

    function getAffiliate(address member)
        public
        view
        returns (address)
    {

        address affiliate = addressToAffiliate[member];
        if (affiliate == address(0)) {
            return defaultAffiliate;
        } else {
            return affiliate;
        }
    }

    function getAffiliateFeeFrac(address affiliate)
        public
        view
        returns (uint256)
    {

        return affiliateFeeFrac[affiliate];
    }

    function getDefaultAffiliate()
        public
        view
        returns (address)
    {

        return defaultAffiliate;
    }

}pragma solidity 0.5.16;


library LibOutcome {

    enum Outcome { VOID, OUTCOME_ONE, OUTCOME_TWO }
}pragma solidity ^0.5.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}pragma solidity ^0.5.0;


library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}pragma solidity 0.5.16;



library LibOrder {

    using SafeMath for uint256;

    uint256 public constant ODDS_PRECISION = 10**20;

    struct Order {
        bytes32 marketHash;
        address baseToken;
        uint256 totalBetSize;
        uint256 percentageOdds;
        uint256 expiry;
        uint256 salt;
        address maker;
        address executor;
        bool isMakerBettingOutcomeOne;
    }

    struct FillObject {
        Order[] orders;
        bytes[] makerSigs;
        uint256[] takerAmounts;
        uint256 fillSalt;
    }

    struct FillDetails {
        string action;
        string market;
        string betting;
        string stake;
        string odds;
        string returning;
        FillObject fills;
    }

    function getParamValidity(Order memory order)
        internal
        view
        returns (string memory)
    {

        if (order.totalBetSize == 0) {return "TOTAL_BET_SIZE_ZERO";}
        if (order.percentageOdds == 0 || order.percentageOdds >= ODDS_PRECISION) {return "INVALID_PERCENTAGE_ODDS";}
        if (order.expiry < now) {return "ORDER_EXPIRED";}
        if (order.baseToken == address(0)) {return "BASE_TOKEN";}
        return "OK";
    }

    function checkSignature(Order memory order, bytes memory makerSig)
        internal
        pure
        returns (bool)
    {

        bytes32 orderHash = getOrderHash(order);
        return ECDSA.recover(ECDSA.toEthSignedMessageHash(orderHash), makerSig) == order.maker;
    }

    function assertValidParams(Order memory order) internal view {

        require(
            order.totalBetSize > 0,
            "TOTAL_BET_SIZE_ZERO"
        );
        require(
            order.percentageOdds > 0 && order.percentageOdds < ODDS_PRECISION,
            "INVALID_PERCENTAGE_ODDS"
        );
        require(order.baseToken != address(0), "INVALID_BASE_TOKEN");
        require(order.expiry > now, "ORDER_EXPIRED");
    }

    function assertValidAsTaker(Order memory order, address taker, bytes memory makerSig) internal view {

        assertValidParams(order);
        require(
            checkSignature(order, makerSig),
            "SIGNATURE_MISMATCH"
        );
        require(order.maker != taker, "TAKER_NOT_MAKER");
    }

    function assertValidAsMaker(Order memory order, address sender) internal view {

        assertValidParams(order);
        require(order.maker == sender, "CALLER_NOT_MAKER");
    }

    function getOrderHash(Order memory order) internal pure returns (bytes32) {

        return keccak256(
            abi.encodePacked(
                order.marketHash,
                order.baseToken,
                order.totalBetSize,
                order.percentageOdds,
                order.expiry,
                order.salt,
                order.maker,
                order.executor,
                order.isMakerBettingOutcomeOne
            )
        );
    }

    function getOddsPrecision() internal pure returns (uint256) {

        return ODDS_PRECISION;
    }
}pragma solidity 0.5.16;


contract IFillOrder {

    function fillOrders(LibOrder.FillDetails memory, bytes memory) public;

    function metaFillOrders(
        LibOrder.FillDetails memory,
        address,
        bytes memory,
        bytes memory)
        public;

}pragma solidity 0.5.16;

contract IFeeSchedule {

    function getOracleFees(address) public view returns (uint256);

    function setOracleFee(address, uint256) public;

}pragma solidity 0.5.16;

contract ISystemParameters {

    function getOracleFeeRecipient() public view returns (address);

    function setNewOracleFeeRecipient(address) public;

}pragma solidity 0.5.16;

contract IOutcomeReporter {

    function getReportedOutcome(bytes32)
        public
        view
        returns (LibOutcome.Outcome);

    function getReportTime(bytes32) public view returns (uint256);

    function reportOutcome(bytes32, LibOutcome.Outcome) public;

    function reportOutcomes(bytes32[] memory, LibOutcome.Outcome[] memory)
        public;

}pragma solidity 0.5.16;



contract IEscrow {

    struct Eligibility {
        bool hasEligibility;
        LibOutcome.Outcome outcome;
        uint256 amount;
    }

    function getReturnAmount(bytes32, address, address, LibOutcome.Outcome) public view returns (uint256);

    function getStakedAmount(bytes32, address, address, LibOutcome.Outcome) public view returns (uint256);

    function settleBet(address, bytes32, address) public;

    function updateStakedAmount(bytes32, address, address, LibOutcome.Outcome, uint256) public;

    function increaseReturnAmount(bytes32, address, address, LibOutcome.Outcome, uint256) public;

    function isMarketRedeemable(bytes32) public view returns (bool);

    function getEligibility(address, bytes32, address) public view returns (Eligibility memory);

}pragma solidity ^0.5.0;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity 0.5.16;


contract Escrow is IEscrow {

    using SafeMath for uint256;

    ISystemParameters private systemParameters;
    IFillOrder private fillOrder;
    IOutcomeReporter private outcomeReporter;
    IFeeSchedule private feeSchedule;
    IAffiliateRegistry private affiliateRegistry;

    mapping(bytes32 => mapping(address => mapping(address => mapping(uint8 => uint256)))) returnAmounts;
    mapping(bytes32 => mapping(address => mapping(address => mapping(uint8 => uint256)))) stakedAmounts;

    struct BetFee {
        uint256 oracleFee;
        uint256 affiliateFee;
    }

    event BetSettled(
        address indexed owner,
        bytes32 indexed marketHash,
        address indexed baseToken,
        LibOutcome.Outcome outcome,
        uint256 settledAmount,
        uint256 oracleFeeAmount,
        uint256 affiliateFeeAmount
    );

    constructor(
        ISystemParameters _systemParameters,
        IFillOrder _fillOrder,
        IOutcomeReporter _outcomeReporter,
        IFeeSchedule _feeSchedule,
        IAffiliateRegistry _affiliateRegistry
    ) public {
        systemParameters = _systemParameters;
        fillOrder = _fillOrder;
        outcomeReporter = _outcomeReporter;
        feeSchedule = _feeSchedule;
        affiliateRegistry = _affiliateRegistry;
    }

    modifier onlyFillOrder() {

        require(msg.sender == address(fillOrder), "ONLY_FILL_ORDER");
        _;
    }

    modifier marketTokensRedeemable(bytes32 marketHash) {

        require(isMarketRedeemable(marketHash), "INVALID_REDEMPTION_TIME");
        _;
    }

    function settleBet(
        address owner,
        bytes32 marketHash,
        address baseTokenAddress
    ) public marketTokensRedeemable(marketHash) {

        IERC20 baseToken = IERC20(baseTokenAddress);
        LibOutcome.Outcome marketResult = outcomeReporter.getReportedOutcome(
            marketHash
        );
        uint256 outcomeOneEligibility = returnAmounts[marketHash][baseTokenAddress][owner][uint8(
            LibOutcome.Outcome.OUTCOME_ONE
        )];
        uint256 outcomeTwoEligibility = returnAmounts[marketHash][baseTokenAddress][owner][uint8(
            LibOutcome.Outcome.OUTCOME_TWO
        )];
        uint256 outcomeOneStake = stakedAmounts[marketHash][baseTokenAddress][owner][uint8(
            LibOutcome.Outcome.OUTCOME_ONE
        )];
        uint256 outcomeTwoStake = stakedAmounts[marketHash][baseTokenAddress][owner][uint8(
            LibOutcome.Outcome.OUTCOME_TWO
        )];
        BetFee memory betFees;
        uint256 payout;

        if (
            marketResult == LibOutcome.Outcome.OUTCOME_ONE &&
            outcomeOneEligibility > 0
        ) {
            uint256 profits = outcomeOneEligibility.sub(outcomeOneStake);
            betFees = settleFees(baseTokenAddress, owner, profits);
            payout = outcomeOneEligibility.sub(betFees.oracleFee).sub(
                betFees.affiliateFee
            );
            returnAmounts[marketHash][baseTokenAddress][owner][uint8(
                LibOutcome.Outcome.OUTCOME_ONE
            )] = 0;
        } else if (
            marketResult == LibOutcome.Outcome.OUTCOME_TWO &&
            outcomeTwoEligibility > 0
        ) {
            uint256 profits = outcomeTwoEligibility.sub(outcomeTwoStake);
            betFees = settleFees(baseTokenAddress, owner, profits);
            payout = outcomeTwoEligibility.sub(betFees.oracleFee).sub(
                betFees.affiliateFee
            );
            returnAmounts[marketHash][baseTokenAddress][owner][uint8(
                LibOutcome.Outcome.OUTCOME_TWO
            )] = 0;
        } else if (
            marketResult == LibOutcome.Outcome.VOID &&
            (outcomeOneStake > 0 || outcomeTwoStake > 0)
        ) {
            if (outcomeOneStake > 0) {
                payout = outcomeOneStake;
                stakedAmounts[marketHash][baseTokenAddress][owner][uint8(
                    LibOutcome.Outcome.OUTCOME_ONE
                )] = 0;
            }
            if (outcomeTwoStake > 0) {
                payout = payout.add(outcomeTwoStake);
                stakedAmounts[marketHash][baseTokenAddress][owner][uint8(
                    LibOutcome.Outcome.OUTCOME_TWO
                )] = 0;
            }
        } else {
            revert("MARKET_WRONG_RESOLUTION");
        }

        require(baseToken.transfer(owner, payout), "CANNOT_TRANSFER_ESCROW");

        emit BetSettled(
            owner,
            marketHash,
            baseTokenAddress,
            marketResult,
            payout,
            betFees.oracleFee,
            betFees.affiliateFee
        );
    }

    function updateStakedAmount(
        bytes32 marketHash,
        address baseToken,
        address user,
        LibOutcome.Outcome outcome,
        uint256 amount
    ) public onlyFillOrder {

        stakedAmounts[marketHash][baseToken][user][uint8(
            outcome
        )] = stakedAmounts[marketHash][baseToken][user][uint8(outcome)].add(
            amount
        );
    }

    function increaseReturnAmount(
        bytes32 marketHash,
        address baseToken,
        address user,
        LibOutcome.Outcome outcome,
        uint256 amount
    ) public onlyFillOrder {

        returnAmounts[marketHash][baseToken][user][uint8(
            outcome
        )] = returnAmounts[marketHash][baseToken][user][uint8(outcome)].add(
            amount
        );
    }

    function isMarketRedeemable(bytes32 marketHash) public view returns (bool) {

        uint256 reportTime = outcomeReporter.getReportTime(marketHash);
        if (reportTime > 0) {
            return now > reportTime;
        } else {
            return false;
        }
    }

    function getEligibility(
        address owner,
        bytes32 marketHash,
        address baseToken
    ) public view returns (Eligibility memory eligibility) {

        if (!isMarketRedeemable(marketHash)) {
            return
                Eligibility({
                    hasEligibility: false,
                    outcome: LibOutcome.Outcome.VOID,
                    amount: 0
                });
        }
        LibOutcome.Outcome marketResult = outcomeReporter.getReportedOutcome(
            marketHash
        );

        uint256 outcomeOneEligibility = returnAmounts[marketHash][baseToken][owner][uint8(
            LibOutcome.Outcome.OUTCOME_ONE
        )];
        uint256 outcomeTwoEligibility = returnAmounts[marketHash][baseToken][owner][uint8(
            LibOutcome.Outcome.OUTCOME_TWO
        )];
        uint256 outcomeOneStake = stakedAmounts[marketHash][baseToken][owner][uint8(
            LibOutcome.Outcome.OUTCOME_ONE
        )];
        uint256 outcomeTwoStake = stakedAmounts[marketHash][baseToken][owner][uint8(
            LibOutcome.Outcome.OUTCOME_TWO
        )];

        if (
            marketResult == LibOutcome.Outcome.OUTCOME_ONE &&
            outcomeOneEligibility > 0
        ) {
            return
                Eligibility({
                    hasEligibility: true,
                    outcome: LibOutcome.Outcome.OUTCOME_ONE,
                    amount: outcomeOneEligibility
                });
        } else if (
            marketResult == LibOutcome.Outcome.OUTCOME_TWO &&
            outcomeTwoEligibility > 0
        ) {
            return
                Eligibility({
                    hasEligibility: true,
                    outcome: LibOutcome.Outcome.OUTCOME_TWO,
                    amount: outcomeTwoEligibility
                });
        } else if (
            marketResult == LibOutcome.Outcome.VOID &&
            (outcomeOneStake > 0 || outcomeTwoStake > 0)
        ) {
            return
                Eligibility({
                    hasEligibility: true,
                    outcome: LibOutcome.Outcome.VOID,
                    amount: outcomeOneStake.add(outcomeTwoStake)
                });
        } else {
            return
                Eligibility({
                    hasEligibility: false,
                    outcome: LibOutcome.Outcome.VOID,
                    amount: 0
                });
        }
    }

    function getReturnAmount(
        bytes32 marketHash,
        address baseToken,
        address owner,
        LibOutcome.Outcome outcome
    ) public view returns (uint256) {

        return returnAmounts[marketHash][baseToken][owner][uint8(outcome)];
    }

    function getStakedAmount(
        bytes32 marketHash,
        address baseToken,
        address owner,
        LibOutcome.Outcome outcome
    ) public view returns (uint256) {

        return stakedAmounts[marketHash][baseToken][owner][uint8(outcome)];
    }

    function settleFees(address baseToken, address owner, uint256 profits)
        private
        returns (BetFee memory)
    {

        address affiliate = affiliateRegistry.getAffiliate(owner);
        uint256 affiliateFeeFrac = affiliateRegistry.getAffiliateFeeFrac(
            affiliate
        );

        uint256 oracleFee = settleOracleFee(baseToken, profits);
        uint256 affiliateFee = settleAffiliateFee(
            baseToken,
            profits,
            affiliate,
            affiliateFeeFrac
        );

        return BetFee({oracleFee: oracleFee, affiliateFee: affiliateFee});
    }

    function settleAffiliateFee(
        address baseToken,
        uint256 profits,
        address affiliate,
        uint256 affiliateFeeFrac
    ) private returns (uint256) {

        IERC20 token = IERC20(baseToken);
        uint256 affiliateFeeAmount = profits.mul(affiliateFeeFrac).div(
            LibOrder.getOddsPrecision()
        );
        if (affiliateFeeAmount > 0) {
            require(
                token.transfer(affiliate, affiliateFeeAmount),
                "CANNOT_TRANSFER_AFFILIATE_FEE"
            );
        }
        return affiliateFeeAmount;
    }

    function settleOracleFee(address baseToken, uint256 profits)
        private
        returns (uint256)
    {

        IERC20 token = IERC20(baseToken);
        uint256 oracleFee = feeSchedule.getOracleFees(baseToken);
        uint256 oracleFeeAmount = profits.mul(oracleFee).div(
            LibOrder.getOddsPrecision()
        );
        address oracleFeeRecipient = systemParameters.getOracleFeeRecipient();

        if (oracleFeeAmount > 0) {
            require(
                token.transfer(oracleFeeRecipient, oracleFeeAmount),
                "CANNOT_TRANSFER_FEE"
            );
        }
        return oracleFeeAmount;
    }
}pragma solidity 0.5.16;


contract Initializable {

    bool public initialized;

    modifier notInitialized() {

        require(!initialized, "ALREADY_INITIALIZED");
        _;
    }
}//solhint-disable

pragma solidity 0.5.16;

contract Migrations {

    address public owner;
    uint public last_completed_migration;

    constructor() public {
        owner = msg.sender;
    }

    modifier restricted() {

        if (msg.sender == owner) _;
    }

    function setCompleted(uint completed) public restricted {

        last_completed_migration = completed;
    }

    function upgrade(address new_address) public restricted {

        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}pragma solidity 0.5.16;


contract OutcomeReporter is IOutcomeReporter {

    using SafeMath for uint256;

    IWhitelist private outcomeReporterWhitelist;

    mapping(bytes32 => LibOutcome.Outcome) private reportedOutcomes;
    mapping(bytes32 => uint256) private reportTime;

    event OutcomeReported(bytes32 marketHash, LibOutcome.Outcome outcome);

    constructor(
        IWhitelist _outcomeReporterWhitelist
    ) public {
        outcomeReporterWhitelist = _outcomeReporterWhitelist;
    }

    modifier onlyOutcomeReporterAdmin() {

        require(
            outcomeReporterWhitelist.getWhitelisted(msg.sender),
            "NOT_OUTCOME_REPORTER_ADMIN"
        );
        _;
    }

    modifier notAlreadyReported(bytes32 marketHash) {

        require(
            reportTime[marketHash] == 0,
            "MARKET_ALREADY_REPORTED"
        );
        _;
    }

    function reportOutcome(bytes32 marketHash, LibOutcome.Outcome reportedOutcome)
        public
        onlyOutcomeReporterAdmin
        notAlreadyReported(marketHash)
    {

        reportedOutcomes[marketHash] = reportedOutcome;
        reportTime[marketHash] = now;

        emit OutcomeReported(marketHash, reportedOutcome);
    }

    function reportOutcomes(
        bytes32[] memory marketHashes,
        LibOutcome.Outcome[] memory outcomes
    ) public {

        uint256 marketHashesLength = marketHashes.length;
        for (uint256 i = 0; i < marketHashesLength; i++) {
            reportOutcome(marketHashes[i], outcomes[i]);
        }
    }

    function getReportedOutcome(bytes32 marketHash)
        public
        view
        returns (LibOutcome.Outcome)
    {

        return reportedOutcomes[marketHash];
    }

    function getReportTime(bytes32 marketHash) public view returns (uint256) {

        return reportTime[marketHash];
    }
}pragma solidity 0.5.16;



contract SystemParameters is ISystemParameters {

    address private oracleFeeRecipient;

    IWhitelist private systemParamsWhitelist;

    constructor(IWhitelist _systemParamsWhitelist) public {
        systemParamsWhitelist = _systemParamsWhitelist;
    }

    modifier onlySystemParamsAdmin() {

        require(
            systemParamsWhitelist.getWhitelisted(msg.sender),
            "NOT_SYSTEM_PARAM_ADMIN"
        );
        _;
    }

    function setNewOracleFeeRecipient(address newOracleFeeRecipient)
        public
        onlySystemParamsAdmin
    {

        oracleFeeRecipient = newOracleFeeRecipient;
    }

    function getOracleFeeRecipient() public view returns (address) {

        return oracleFeeRecipient;
    }
}pragma solidity 0.5.16;



library LibOrderAmounts {

    using SafeMath for uint256;

    struct OrderAmounts {
        uint256 takerAmount;
        uint256 takerEscrow;
        uint256 potSize;
    }

    function computeOrderAmounts(
        LibOrder.Order memory order,
        uint256 takerAmount
    )
        internal
        pure
        returns (LibOrderAmounts.OrderAmounts memory)
    {

        uint256 oddsPrecision = LibOrder.getOddsPrecision();
        uint256 potSize = takerAmount.mul(oddsPrecision).div(order.percentageOdds);
        uint256 takerEscrow = potSize.sub(takerAmount);

        return LibOrderAmounts.OrderAmounts({
            takerAmount: takerAmount,
            takerEscrow: takerEscrow,
            potSize: potSize
        });
    }

    function reduceOrderAmounts(
        LibOrderAmounts.OrderAmounts memory orderAmount1,
        LibOrderAmounts.OrderAmounts memory orderAmount2
    )
        internal
        pure
        returns (LibOrderAmounts.OrderAmounts memory)
    {

        return LibOrderAmounts.OrderAmounts({
            takerAmount: orderAmount1.takerAmount.add(orderAmount2.takerAmount),
            takerEscrow: orderAmount1.takerEscrow.add(orderAmount2.takerEscrow),
            potSize: orderAmount1.potSize.add(orderAmount2.potSize)
        });
    }

    function computeTotalOrderAmounts(
        LibOrder.Order[] memory makerOrders,
        uint256[] memory takerAmounts
    )
        internal
        pure
        returns (LibOrderAmounts.OrderAmounts memory)
    {

        LibOrderAmounts.OrderAmounts memory combinedOrderAmounts;
        uint256 makerOrdersLength = makerOrders.length;
        for (uint256 i = 0; i < makerOrdersLength; i++) {
            LibOrderAmounts.OrderAmounts memory orderAmounts = computeOrderAmounts(
                makerOrders[i],
                takerAmounts[i]
            );
            combinedOrderAmounts = reduceOrderAmounts(combinedOrderAmounts, orderAmounts);
        }
        return combinedOrderAmounts;
    }
}pragma solidity 0.5.16;


library LibString {


    function equals(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {

        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}pragma solidity 0.5.16;


contract IFills {

    function getFilled(bytes32) public view returns (uint256);

    function getCancelled(bytes32) public view returns (bool);

    function getFillHashSubmitted(bytes32) public view returns (bool);

    function orderHasSpace(LibOrder.Order memory, uint256)
        public
        view
        returns (bool);

    function remainingSpace(LibOrder.Order memory)
        public
        view
        returns (uint256);

    function isOrderCancelled(LibOrder.Order memory) public view returns (bool);

    function fill(LibOrder.Order memory, uint256) public returns (uint256);

    function cancel(LibOrder.Order memory) public;

    function setFillHashSubmitted(bytes32) public;

}pragma solidity 0.5.16;

contract ITokenTransferProxy {

    function transferFrom(address, address, address, uint256)
        public
        returns (bool);

}pragma solidity 0.5.16;


contract IReadOnlyValidator {

    function getOrderStatus(LibOrder.Order memory, bytes memory)
        public
        view
        returns (string memory);

    function getOrderStatusForTaker(
        LibOrder.Order memory,
        address,
        uint256,
        bytes memory)
        public view returns (string memory);

    function getCumulativeOrderStatusForTaker(
        LibOrder.Order[] memory,
        address,
        uint256[] memory,
        bytes[] memory)
        public view returns (string memory);

}pragma solidity 0.5.16;


contract IEIP712FillHasher {

    function getOrderHash(LibOrder.Order memory) public  pure returns (bytes32);

    function getOrdersArrayHash(LibOrder.Order[] memory) public  pure returns (bytes32);

    function getMakerSigsArrayHash(bytes[] memory) public  pure returns (bytes32);

    function getTakerAmountsArrayHash(uint256[] memory) public  pure returns (bytes32);

    function getFillObjectHash(LibOrder.FillObject memory) public  pure returns (bytes32);

    function getDetailsHash(LibOrder.FillDetails memory) public  view returns (bytes32);

    function getDomainHash() public  view returns (bytes32);

}pragma solidity 0.5.16;

contract IOrderValidator {

    function getOrderStatus(LibOrder.Order memory, bytes memory)
        public
        view
        returns (string memory);


    function getMultiOrderStatus(LibOrder.Order[] memory, bytes[] memory)
        public
        view
        returns (string[] memory);


    function getFillStatus(LibOrder.FillDetails memory, bytes memory, address)
        public
        view
        returns (string memory);


    function getMetaFillStatus(
        LibOrder.FillDetails memory,
        address,
        bytes memory,
        bytes memory)
        public view returns (string memory);

}pragma solidity 0.5.16;




contract OrderValidator is IOrderValidator {

    using LibOrder for LibOrder.Order;
    using LibString for string;
    using SafeMath for uint256;

    ITokenTransferProxy private proxy;
    IFills private fills;
    IFeeSchedule private feeSchedule;
    IEIP712FillHasher private eip712FillHasher;
    IOutcomeReporter private outcomeReporter;

    constructor(
        ITokenTransferProxy _proxy,
        IFills _fills,
        IFeeSchedule _feeSchedule,
        IEIP712FillHasher _eip712FillHasher,
        IOutcomeReporter _outcomeReporter
    ) public {
        proxy = _proxy;
        fills = _fills;
        feeSchedule = _feeSchedule;
        eip712FillHasher = _eip712FillHasher;
        outcomeReporter = _outcomeReporter;
    }

    function getOrderStatus(
        LibOrder.Order memory order,
        bytes memory makerSig
    )
        public
        view
        returns (string memory)
    {

        string memory baseMakerOrderStatus = getBaseOrderStatus(
            order,
            makerSig
        );
        if (!baseMakerOrderStatus.equals("OK")) {return baseMakerOrderStatus;}
        uint256 remainingSpace = fills.remainingSpace(order);
        if (remainingSpace == 0) {
            return "FULLY_FILLED";
        }
        LibOrderAmounts.OrderAmounts memory orderAmounts = LibOrderAmounts.computeOrderAmounts(
            order,
            remainingSpace
        );
        string memory allowanceBalanceValidity = getMakerAllowanceAndBalanceStatus(
            orderAmounts,
            order.baseToken,
            order.maker
        );
        return allowanceBalanceValidity;
    }

    function getMultiOrderStatus(
        LibOrder.Order[] memory orders,
        bytes[] memory makerSigs
    )
        public
        view
        returns (string[] memory)
    {

        string[] memory statuses = new string[](orders.length);

        for (uint256 i = 0; i < orders.length; i++) {
            statuses[i] = getOrderStatus(
                orders[i],
                makerSigs[i]
            );
        }

        return statuses;
    }

    function getFillStatus(
        LibOrder.FillDetails memory fillDetails,
        bytes memory executorSig,
        address taker
    )
        public
        view
        returns (string memory)
    {

        address executor = fillDetails.fills.orders[0].executor;
        if (executor != address(0)) {
            bytes32 fillHash = eip712FillHasher.getDetailsHash(fillDetails);

            if (fills.getFillHashSubmitted(fillHash)) {
                return "FILL_ALREADY_SUBMITTED";
            }

            if (ECDSA.recover(fillHash, executorSig) != executor) {
                return "EXECUTOR_SIGNATURE_MISMATCH";
            }
        }

        if (fillDetails.fills.orders.length > 1) {
            for (uint256 i = 1; i < fillDetails.fills.orders.length; i++) {
                if (fillDetails.fills.orders[i].executor != executor) {
                    return "INCONSISTENT_EXECUTORS";
                }
            }
        }

        return _getFillStatus(
            fillDetails.fills.orders,
            taker,
            fillDetails.fills.takerAmounts,
            fillDetails.fills.makerSigs
        );
    }

    function getMetaFillStatus(
        LibOrder.FillDetails memory fillDetails,
        address taker,
        bytes memory takerSig,
        bytes memory executorSig
    )
        public
        view
        returns (string memory)
    {

        bytes32 fillHash = eip712FillHasher.getDetailsHash(fillDetails);

        if (ECDSA.recover(fillHash, takerSig) != taker) {
            return "TAKER_SIGNATURE_MISMATCH";
        }

        if (fills.getFillHashSubmitted(fillHash)) {
            return "FILL_ALREADY_SUBMITTED";
        }

        address executor = fillDetails.fills.orders[0].executor;

        if (executor != address(0) &&
            ECDSA.recover(fillHash, executorSig) != executor) {
            return "EXECUTOR_SIGNATURE_MISMATCH";
        }

        if (fillDetails.fills.orders.length > 1) {
            for (uint256 i = 1; i < fillDetails.fills.orders.length; i++) {
                if (fillDetails.fills.orders[i].executor != executor) {
                    return "INCONSISTENT_EXECUTORS";
                }
            }
        }

        return _getFillStatus(
            fillDetails.fills.orders,
            taker,
            fillDetails.fills.takerAmounts,
            fillDetails.fills.makerSigs
        );
    }

    function _getFillStatus(
        LibOrder.Order[] memory makerOrders,
        address taker,
        uint256[] memory takerAmounts,
        bytes[] memory makerSigs
    )
        private
        view
        returns (string memory)
    {

        string memory baseMultiFillStatus = getBaseMultiFillStatus(
            makerOrders,
            taker,
            takerAmounts,
            makerSigs
        );
        if (!baseMultiFillStatus.equals("OK")) {
            return baseMultiFillStatus;
        }
        return getMultiAllowanceBalanceStatus(
            makerOrders,
            takerAmounts,
            taker
        );
    }

    function getBaseOrderStatus(
        LibOrder.Order memory order,
        bytes memory makerSig
    )
        private
        view
        returns (string memory)
    {

        string memory paramValidity = order.getParamValidity();
        if (paramValidity.equals("OK") == false) {return paramValidity;}
        if (outcomeReporter.getReportTime(order.marketHash) != 0) {
            return "MARKET_NOT_TRADEABLE";
        }
        if (order.checkSignature(makerSig) == false) {
            return "BAD_SIGNATURE";
        }
        if (fills.isOrderCancelled(order)) {
            return "CANCELLED";
        }
        return "OK";
    }

    function getMakerAllowanceAndBalanceStatus(
        LibOrderAmounts.OrderAmounts memory orderAmounts,
        address baseTokenAddress,
        address maker
    )
        private
        view
        returns (string memory)
    {

        IERC20 baseToken = IERC20(baseTokenAddress);
        if (baseToken.balanceOf(maker) < orderAmounts.takerAmount) {
            return "MAKER_INSUFFICIENT_BASE_TOKEN";
        }
        if (baseToken.allowance(maker, address(proxy)) < orderAmounts.takerAmount) {
            return "MAKER_INSUFFICIENT_BASE_TOKEN_ALLOWANCE";
        }
        return "OK";
    }

    function getMultiAllowanceBalanceStatus(
        LibOrder.Order[] memory makerOrders,
        uint256[] memory takerAmounts,
        address taker
    )
        private
        view
        returns (string memory)
    {

        address baseToken = makerOrders[0].baseToken;

        LibOrderAmounts.OrderAmounts memory totalOrderAmounts = LibOrderAmounts.computeTotalOrderAmounts(
            makerOrders,
            takerAmounts
        );

        for (uint256 i = 0; i < makerOrders.length; i++) {
            LibOrderAmounts.OrderAmounts memory individualOrderAmounts = LibOrderAmounts.computeOrderAmounts(
                makerOrders[i],
                takerAmounts[i]
            );
            string memory makerAllowanceBalanceValidity = getMakerAllowanceAndBalanceStatus(
                individualOrderAmounts,
                baseToken,
                makerOrders[i].maker
            );
            if (!makerAllowanceBalanceValidity.equals("OK")) {
                return makerAllowanceBalanceValidity;
            }
        }
        return getTakerAllowanceAndBalanceStatus(
            totalOrderAmounts,
            baseToken,
            taker
        );
    }

    function getBaseMultiFillStatus(
        LibOrder.Order[] memory makerOrders,
        address taker,
        uint256[] memory takerAmounts,
        bytes[] memory signatures
    )
        private
        view
        returns (string memory)
    {

        for (uint256 i = 0; i < makerOrders.length; i++) {
            if (makerOrders[i].marketHash != makerOrders[0].marketHash) {return "MARKETS_NOT_IDENTICAL";}
            if (makerOrders[i].baseToken != makerOrders[0].baseToken) {return "BASE_TOKENS_NOT_IDENTICAL";}
            string memory baseMakerOrderStatus = getBaseFillStatus(
                makerOrders[i],
                signatures[i],
                takerAmounts[i],
                taker
            );
            if (!baseMakerOrderStatus.equals("OK")) {return baseMakerOrderStatus;}
        }
        return "OK";
    }

    function getBaseFillStatus(
        LibOrder.Order memory order,
        bytes memory makerSig,
        uint256 takerAmount,
        address taker
    )
        private
        view
        returns (string memory)
    {

        if (takerAmount == 0) {return "TAKER_AMOUNT_NOT_POSITIVE";}
        string memory baseMakerOrderStatus = getBaseOrderStatus(
            order,
            makerSig
        );
        if (!baseMakerOrderStatus.equals("OK")) {return baseMakerOrderStatus;}
        if (taker == order.maker) {return "TAKER_NOT_MAKER";}
        if (!fills.orderHasSpace(order, takerAmount)) {return "INSUFFICIENT_SPACE";}
        return "OK";
    }

    function getTakerAllowanceAndBalanceStatus(
        LibOrderAmounts.OrderAmounts memory orderAmounts,
        address baseTokenAddress,
        address taker
    )
        private
        view
        returns (string memory)
    {

        IERC20 baseToken = IERC20(baseTokenAddress);
        if (baseToken.balanceOf(taker) < orderAmounts.takerEscrow) {
            return "TAKER_INSUFFICIENT_BASE_TOKEN";
        }
        if (baseToken.allowance(taker, address(proxy)) < orderAmounts.takerEscrow) {
            return "TAKER_INSUFFICIENT_BASE_TOKEN_ALLOWANCE";
        }
        return "OK";
    }
}pragma solidity 0.5.16;

contract ISuperAdminRole {

    function isSuperAdmin(address account) public view returns (bool);

    function addSuperAdmin(address account) public;

    function removeSuperAdmin(address account) public;

    function getSuperAdminCount() public view returns (uint256);

}pragma solidity 0.5.16;



contract Whitelist is IWhitelist {

    ISuperAdminRole internal superAdminRole;

    mapping (address => bool) public whitelisted;

    constructor(ISuperAdminRole _superAdminRole) public {
        superAdminRole = _superAdminRole;
    }

    modifier onlySuperAdmin(address operator) {

        require(
            superAdminRole.isSuperAdmin(operator),
            "NOT_A_SUPER_ADMIN"
        );
        _;
    }

    function addAddressToWhitelist(address operator)
        public
        onlySuperAdmin(msg.sender)
    {

        whitelisted[operator] = true;
    }

    function removeAddressFromWhitelist(address operator)
        public
        onlySuperAdmin(msg.sender)
    {

        whitelisted[operator] = false;
    }

    function getWhitelisted(address operator) public view returns (bool) {

        return whitelisted[operator];
    }
}pragma solidity 0.5.16;



contract OutcomeReporterWhitelist is Whitelist {

    constructor(ISuperAdminRole _superAdminRole) public Whitelist(_superAdminRole) {}
}pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));
        return role.bearer[account];
    }
}pragma solidity 0.5.16;



contract SuperAdminRole is ISuperAdminRole {

    using Roles for Roles.Role;
    using SafeMath for uint256;

    event SuperAdminAdded(address indexed account);
    event SuperAdminRemoved(address indexed account);

    Roles.Role private superAdmins;

    uint256 private superAdminCount;

    constructor() public {
        _addSuperAdmin(msg.sender);
    }

    modifier onlySuperAdmin() {

        require(isSuperAdmin(msg.sender), "NOT_SUPER_ADMIN");
        _;
    }

    function addSuperAdmin(address account) public onlySuperAdmin {

        _addSuperAdmin(account);
    }

    modifier atLeastOneSuperAdmin() {

        require(
            superAdminCount > 1,
            "LAST_SUPER_ADMIN"
        );
        _;
    }

    function removeSuperAdmin(address account)
        public
        onlySuperAdmin
        atLeastOneSuperAdmin
    {

        _removeSuperAdmin(account);
    }

    function _addSuperAdmin(address account) internal {

        superAdmins.add(account);
        superAdminCount = superAdminCount.add(1);
        emit SuperAdminAdded(account);
    }

    function _removeSuperAdmin(address account) internal {

        superAdmins.remove(account);
        superAdminCount = superAdminCount.sub(1);
        emit SuperAdminRemoved(account);
    }

    function getSuperAdminCount() public view returns (uint256) {

        return superAdminCount;
    }

    function isSuperAdmin(address account) public view returns (bool) {

        return superAdmins.has(account);
    }
}pragma solidity 0.5.16;



contract SystemParamsWhitelist is Whitelist {

    constructor(ISuperAdminRole _superAdminRole) public Whitelist(_superAdminRole) {}
}pragma solidity 0.5.16;


contract DAI {


    string  public constant name     = "Dai Stablecoin";
    string  public constant symbol   = "DAI";
    string  public constant version  = "1";
    uint8   public constant decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint)                      public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    mapping (address => uint)                      public nonces;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x);
    }

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH = 0xea2aa0a1be11a07ed86d755c93467f4f82362b452371d1ba94d1715123511acb;

    constructor(uint256 chainId_) public {
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            chainId_,
            address(this)
        ));
    }

    function transfer(address dst, uint wad) external returns (bool) {

        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public returns (bool)
    {

        require(balanceOf[src] >= wad, "Dai/insufficient-balance");
        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad, "Dai/insufficient-allowance");
            allowance[src][msg.sender] = sub(allowance[src][msg.sender], wad);
        }
        balanceOf[src] = sub(balanceOf[src], wad);
        balanceOf[dst] = add(balanceOf[dst], wad);
        emit Transfer(src, dst, wad);
        return true;
    }

    function burn(address usr, uint wad) external {

        require(balanceOf[usr] >= wad, "Dai/insufficient-balance");
        if (usr != msg.sender && allowance[usr][msg.sender] != uint(-1)) {
            require(allowance[usr][msg.sender] >= wad, "Dai/insufficient-allowance");
            allowance[usr][msg.sender] = sub(allowance[usr][msg.sender], wad);
        }
        balanceOf[usr] = sub(balanceOf[usr], wad);
        totalSupply    = sub(totalSupply, wad);
        emit Transfer(usr, address(0), wad);
    }

    function approve(address usr, uint wad) external returns (bool) {

        allowance[msg.sender][usr] = wad;
        emit Approval(msg.sender, usr, wad);
        return true;
    }

    function setBalance(address _target, uint256 _value) external {

        balanceOf[_target] = _value;
    }

    function permit(address holder, address spender, uint256 nonce, uint256 expiry,
                    bool allowed, uint8 v, bytes32 r, bytes32 s) external
    {

        bytes32 digest =
            keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH,
                                     holder,
                                     spender,
                                     nonce,
                                     expiry,
                                     allowed))
        ));

        require(holder != address(0), "Dai/invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "Dai/invalid-permit");
        require(expiry == 0 || now <= expiry, "Dai/permit-expired");
        require(nonce == nonces[holder]++, "Dai/invalid-nonce");
        uint wad = allowed ? uint(-1) : 0;
        allowance[holder][spender] = wad;
        emit Approval(holder, spender, wad);
    }
}pragma solidity 0.5.16;


contract DetailedToken {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}pragma solidity 0.5.16;



contract WETH is IERC20 {

    using SafeMath for uint256;

    string public constant name = "SportX WETH";
    string public constant symbol = "WETH";
    string public constant version = "1";
    uint8 public constant decimals = 18;
    bytes2 constant private EIP191_HEADER = 0x1901;
    bytes32 public constant EIP712_UNWRAP_TYPEHASH = keccak256("Unwrap(address holder,uint256 amount,uint256 nonce,uint256 expiry)");
    bytes32 public constant EIP712_PERMIT_TYPEHASH = keccak256(
        "Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool allowed)"
    );
    bytes32 public EIP712_DOMAIN_SEPARATOR;
    uint256 private _totalSupply;
    address public defaultOperator;
    address public defaultOperatorController;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    mapping (address => uint256) public unwrapNonces;
    mapping (address => uint256) public permitNonces;

    event Deposit(address indexed dst, uint256 amount);
    event Withdrawal(address indexed src, uint256 amount);

    constructor (address _operator, uint256 _chainId, address _defaultOperatorController) public {
        defaultOperator = _operator;
        defaultOperatorController = _defaultOperatorController;
        EIP712_DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                _chainId,
                address(this)
            )
        );
    }

    modifier onlyDefaultOperatorController() {

        require(
            msg.sender == defaultOperatorController,
            "ONLY_DEFAULT_OPERATOR_CONTROLLER"
        );
        _;
    }

    function() external payable {
        _deposit(msg.sender, msg.value);
    }

    function setDefaultOperator(address newDefaultOperator) external onlyDefaultOperatorController {

        defaultOperator = newDefaultOperator;
    }

    function metaWithdraw(
        address payable holder,
        uint256 amount,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {

        bytes32 digest = keccak256(
            abi.encodePacked(
                EIP191_HEADER,
                EIP712_DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        EIP712_UNWRAP_TYPEHASH,
                        holder,
                        amount,
                        nonce,
                        expiry
                    )
                )
            )
        );

        require(holder != address(0), "INVALID_HOLDER");
        require(holder == ecrecover(digest, v, r, s), "INVALID_SIGNATURE");
        require(expiry == 0 || now <= expiry, "META_WITHDRAW_EXPIRED");
        require(nonce == unwrapNonces[holder]++, "INVALID_NONCE");
        require(_balances[holder] >= amount, "INSUFFICIENT_BALANCE");

        _withdraw(holder, amount);
    }

    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                EIP712_DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        EIP712_PERMIT_TYPEHASH,
                        holder,
                        spender,
                        nonce,
                        expiry,
                        allowed
                    )
                )
            )
        );

        require(holder != address(0), "INVALID_HOLDER");
        require(holder == ecrecover(digest, v, r, s), "INVALID_SIGNATURE");
        require(expiry == 0 || now <= expiry, "PERMIT_EXPIRED");
        require(nonce == permitNonces[holder]++, "INVALID_NONCE");
        uint256 wad = allowed ? uint256(-1) : 0;
        _allowed[holder][spender] = wad;
        emit Approval(holder, spender, wad);
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0), "SPENDER_INVALID");

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0), "SPENDER_INVALID");

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0), "SPENDER_INVALID");

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function withdraw(uint256 amount) public {

        require(_balances[msg.sender] >= amount, "INSUFFICIENT_BALANCE");
        _withdraw(msg.sender, amount);
    }

    function _transfer(address from, address to, uint256 value) private {

        require(to != address(0), "SPENDER_INVALID");

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _withdraw(address payable holder, uint256 amount) private {

        _balances[holder] = _balances[holder].sub(amount);
        holder.transfer(amount);
        emit Withdrawal(holder, amount);
    }

    function _deposit(address sender, uint256 amount) private {

        _balances[sender] = _balances[sender].add(amount);
        uint256 senderAllowance = _allowed[sender][defaultOperator];
        if (senderAllowance == 0) {
            _allowed[sender][defaultOperator] = uint256(-1);
        }
        emit Deposit(sender, amount);
    }
}pragma solidity 0.5.16;



contract BaseFillOrder is Initializable {

    using LibOrder for LibOrder.Order;
    using SafeMath for uint256;

    ITokenTransferProxy internal proxy;
    IFills internal fills;
    IEscrow internal escrow;
    ISuperAdminRole internal superAdminRole;
    IOutcomeReporter internal outcomeReporter;

    event OrderFill(
        address indexed maker,
        bytes32 indexed marketHash,
        address indexed taker,
        uint256 newFilledAmount,
        bytes32 orderHash,
        bytes32 fillHash,
        LibOrder.Order order,
        LibOrderAmounts.OrderAmounts orderAmounts
    );

    constructor(ISuperAdminRole _superAdminRole) public Initializable() {
        superAdminRole = _superAdminRole;
    }

    function initialize(
        IFills _fills,
        IEscrow _escrow,
        ITokenTransferProxy _tokenTransferProxy,
        IOutcomeReporter _outcomeReporter
    )
        external
        notInitialized
        onlySuperAdmin(msg.sender)
    {

        fills = _fills;
        escrow = _escrow;
        proxy = _tokenTransferProxy;
        outcomeReporter = _outcomeReporter;
        initialized = true;
    }

    modifier onlySuperAdmin(address operator) {

        require(
            superAdminRole.isSuperAdmin(operator),
            "NOT_A_SUPER_ADMIN"
        );
        _;
    }

    function _fillSingleOrder(
        LibOrder.Order memory order,
        uint256 takerAmount,
        address taker,
        bytes32 fillHash
    )
        internal
    {

        LibOrderAmounts.OrderAmounts memory orderAmounts = LibOrderAmounts.computeOrderAmounts(
            order,
            takerAmount
        );

        updateOrderState(
            order,
            orderAmounts,
            taker,
            fillHash
        );
    }

    function updateOrderState(
        LibOrder.Order memory order,
        LibOrderAmounts.OrderAmounts memory orderAmounts,
        address taker,
        bytes32 fillHash
    )
        internal
    {

        uint256 newFillAmount = fills.fill(order, orderAmounts.takerAmount);

        settleOrderForMaker(
            order,
            orderAmounts
        );

        settleOrderForTaker(
            order,
            orderAmounts,
            taker
        );

        emit OrderFill(
            order.maker,
            order.marketHash,
            taker,
            newFillAmount,
            order.getOrderHash(),
            fillHash,
            order,
            orderAmounts
        );
    }

    function settleOrderForMaker(
        LibOrder.Order memory order,
        LibOrderAmounts.OrderAmounts memory orderAmounts
    )
        internal
    {

        updateMakerEligibility(
            order,
            orderAmounts
        );

        settleTransfersForMaker(
            order,
            orderAmounts
        );
    }

    function settleOrderForTaker(
        LibOrder.Order memory order,
        LibOrderAmounts.OrderAmounts memory orderAmounts,
        address taker
    )
        internal
    {

        updateTakerEligibility(
            order,
            orderAmounts,
            taker
        );

        settleTransfersForTaker(
            order,
            orderAmounts,
            taker
        );
    }

    function assertOrderValid(
        LibOrder.Order memory order,
        uint256 takerAmount,
        address taker,
        bytes memory makerSig
    )
        internal
        view
    {

        require(
            takerAmount > 0,
            "TAKER_AMOUNT_NOT_POSITIVE"
        );
        order.assertValidAsTaker(taker, makerSig);
        require(
            outcomeReporter.getReportTime(order.marketHash) == 0,
            "MARKET_NOT_TRADEABLE"
        );
        require(
            fills.orderHasSpace(order, takerAmount),
            "INSUFFICIENT_SPACE"
        );
    }

    function transferViaProxy(
        address token,
        address from,
        address to,
        uint256 value
    )
        internal
        returns (bool)
    {

        return proxy.transferFrom(token, from, to, value);
    }

    function updateTakerEligibility(
        LibOrder.Order memory order,
        LibOrderAmounts.OrderAmounts memory orderAmounts,
        address taker
    )
        private
    {

        if (order.isMakerBettingOutcomeOne) {
            escrow.increaseReturnAmount(
                order.marketHash,
                order.baseToken,
                taker,
                LibOutcome.Outcome.OUTCOME_TWO,
                orderAmounts.potSize
            );
            escrow.updateStakedAmount(
                order.marketHash,
                order.baseToken,
                taker,
                LibOutcome.Outcome.OUTCOME_TWO,
                orderAmounts.takerEscrow
            );
        } else {
            escrow.increaseReturnAmount(
                order.marketHash,
                order.baseToken,
                taker,
                LibOutcome.Outcome.OUTCOME_ONE,
                orderAmounts.potSize
            );
            escrow.updateStakedAmount(
                order.marketHash,
                order.baseToken,
                taker,
                LibOutcome.Outcome.OUTCOME_ONE,
                orderAmounts.takerEscrow
            );
        }
    }

    function updateMakerEligibility(
        LibOrder.Order memory order,
        LibOrderAmounts.OrderAmounts memory orderAmounts
    )
        private
    {

        if (order.isMakerBettingOutcomeOne) {
            escrow.increaseReturnAmount(
                order.marketHash,
                order.baseToken,
                order.maker,
                LibOutcome.Outcome.OUTCOME_ONE,
                orderAmounts.potSize
            );
            escrow.updateStakedAmount(
                order.marketHash,
                order.baseToken,
                order.maker,
                LibOutcome.Outcome.OUTCOME_ONE,
                orderAmounts.takerAmount
            );
        } else {
            escrow.increaseReturnAmount(
                order.marketHash,
                order.baseToken,
                order.maker,
                LibOutcome.Outcome.OUTCOME_TWO,
                orderAmounts.potSize
            );
            escrow.updateStakedAmount(
                order.marketHash,
                order.baseToken,
                order.maker,
                LibOutcome.Outcome.OUTCOME_TWO,
                orderAmounts.takerAmount
            );
        }
    }

    function settleTransfersForMaker(
        LibOrder.Order memory order,
        LibOrderAmounts.OrderAmounts memory orderAmounts
    )
        private
    {

        require(
            transferViaProxy(
                order.baseToken,
                order.maker,
                address(escrow),
                orderAmounts.takerAmount
            ),
            "CANNOT_TRANSFER_TAKER_ESCROW"
        );
    }

    function settleTransfersForTaker(
        LibOrder.Order memory order,
        LibOrderAmounts.OrderAmounts memory orderAmounts,
        address taker
    )
        private
    {

        require(
            transferViaProxy(
                order.baseToken,
                taker,
                address(escrow),
                orderAmounts.takerEscrow
            ),
            "CANNOT_TRANSFER_TAKER_ESCROW"
        );
    }
}pragma solidity 0.5.16;


contract ICancelOrder {

    function cancelOrder(LibOrder.Order memory order) public;

    function batchCancelOrders(LibOrder.Order[] memory makerOrders) public;

}pragma solidity 0.5.16;



contract CancelOrder is ICancelOrder, Initializable {

    using LibOrder for LibOrder.Order;
    using SafeMath for uint256;

    ISuperAdminRole private superAdminRole;
    IFills private fills;

    event OrderCancel(
        address indexed maker,
        bytes32 orderHash,
        LibOrder.Order order
    );

    constructor(ISuperAdminRole _superAdminRole) public Initializable() {
        superAdminRole = _superAdminRole;
    }

    modifier onlySuperAdmin(address operator) {

        require(
            superAdminRole.isSuperAdmin(operator),
            "NOT_A_SUPER_ADMIN"
        );
        _;
    }

    function initialize(IFills _fills)
        external
        notInitialized
        onlySuperAdmin(msg.sender)
    {

        fills = _fills;
        initialized = true;
    }

    function cancelOrder(LibOrder.Order memory order) public {

        assertCancelValid(order, msg.sender);
        fills.cancel(order);

        emit OrderCancel(
            order.maker,
            order.getOrderHash(),
            order
        );
    }

    function batchCancelOrders(LibOrder.Order[] memory makerOrders) public {

        uint256 makerOrdersLength = makerOrders.length;
        for (uint256 i = 0; i < makerOrdersLength; i++) {
            cancelOrder(makerOrders[i]);
        }
    }

    function assertCancelValid(
        LibOrder.Order memory order,
        address canceller
    )
        private
        view
    {

        require(
            order.executor == address(0),
            "EXECUTOR_CANNOT_BE_SET"
        );
        order.assertValidAsMaker(canceller);
        require(
            fills.remainingSpace(order) > 0,
            "INSUFFICIENT_SPACE"
        );
    }
}pragma solidity 0.5.16;



contract EIP712FillHasher {


    bytes2 constant private EIP191_HEADER = 0x1901;

    string constant private EIP712_DOMAIN_NAME = "SportX";

    string constant private EIP712_DOMAIN_VERSION = "1.0";

    bytes32 constant private EIP712_DOMAIN_SCHEMA_HASH = keccak256(
        abi.encodePacked(
            "EIP712Domain(",
            "string name,",
            "string version,",
            "uint256 chainId,",
            "address verifyingContract",
            ")"
        )
    );

    bytes constant private EIP712_DETAILS_STRING = abi.encodePacked(
        "Details(",
        "string action,",
        "string market,",
        "string betting,",
        "string stake,",
        "string odds,",
        "string returning,",
        "FillObject fills",
        ")"
    );

    bytes constant private EIP712_FILL_OBJECT_STRING = abi.encodePacked(
        "FillObject(",
        "Order[] orders,",
        "bytes[] makerSigs,",
        "uint256[] takerAmounts,",
        "uint256 fillSalt",
        ")"
    );

    bytes constant private EIP712_ORDER_STRING = abi.encodePacked(
        "Order(",
        "bytes32 marketHash,",
        "address baseToken,",
        "uint256 totalBetSize,",
        "uint256 percentageOdds,",
        "uint256 expiry,",
        "uint256 salt,",
        "address maker,",
        "address executor,",
        "bool isMakerBettingOutcomeOne",
        ")"
    );

    bytes32 constant private EIP712_ORDER_HASH = keccak256(
        abi.encodePacked(
            EIP712_ORDER_STRING
        )
    );

    bytes32 constant private EIP712_FILL_OBJECT_HASH = keccak256(
        abi.encodePacked(
            EIP712_FILL_OBJECT_STRING,
            EIP712_ORDER_STRING
        )
    );

    bytes32 constant private EIP712_DETAILS_HASH = keccak256(
        abi.encodePacked(
            EIP712_DETAILS_STRING,
            EIP712_FILL_OBJECT_STRING,
            EIP712_ORDER_STRING
        )
    );

    bytes32 public EIP712_DOMAIN_HASH;

    constructor(uint256 chainId) public {
        EIP712_DOMAIN_HASH = keccak256(
            abi.encode(
                EIP712_DOMAIN_SCHEMA_HASH,
                keccak256(bytes(EIP712_DOMAIN_NAME)),
                keccak256(bytes(EIP712_DOMAIN_VERSION)),
                chainId,
                address(this)
            )
        );
    }

    function getOrderHash(LibOrder.Order memory order)
        public
        pure
        returns (bytes32)
    {

        return keccak256(
            abi.encode(
                EIP712_ORDER_HASH,
                order.marketHash,
                order.baseToken,
                order.totalBetSize,
                order.percentageOdds,
                order.expiry,
                order.salt,
                order.maker,
                order.executor,
                order.isMakerBettingOutcomeOne
            )
        );
    }

    function getOrdersArrayHash(LibOrder.Order[] memory orders)
        public
        pure
        returns (bytes32)
    {

        bytes32[] memory ordersBytes = new bytes32[](orders.length);

        for (uint256 i = 0; i < orders.length; i++) {
            ordersBytes[i] = getOrderHash(orders[i]);
        }
        return keccak256(abi.encodePacked(ordersBytes));
    }

    function getMakerSigsArrayHash(bytes[] memory sigs)
        public
        pure
        returns (bytes32)
    {

        bytes32[] memory sigsBytes = new bytes32[](sigs.length);

        for (uint256 i = 0; i < sigs.length; i++) {
            sigsBytes[i] = keccak256(sigs[i]);
        }

        return keccak256(abi.encodePacked(sigsBytes));
    }

    function getFillObjectHash(LibOrder.FillObject memory fillObject)
        public
        pure
        returns (bytes32)
    {

        return keccak256(
            abi.encode(
                EIP712_FILL_OBJECT_HASH,
                getOrdersArrayHash(fillObject.orders),
                getMakerSigsArrayHash(fillObject.makerSigs),
                keccak256(abi.encodePacked(fillObject.takerAmounts)),
                fillObject.fillSalt
            )
        );
    }

    function getDetailsHash(LibOrder.FillDetails memory details)
        public
        view
        returns (bytes32)
    {

        bytes32 structHash = keccak256(
            abi.encode(
                EIP712_DETAILS_HASH,
                keccak256(bytes(details.action)),
                keccak256(bytes(details.market)),
                keccak256(bytes(details.betting)),
                keccak256(bytes(details.stake)),
                keccak256(bytes(details.odds)),
                keccak256(bytes(details.returning)),
                getFillObjectHash(details.fills)
            )
        );
        return keccak256(
            abi.encodePacked(
                EIP191_HEADER,
                EIP712_DOMAIN_HASH,
                structHash
            )
        );
    }

    function getDomainHash()
        public
        view
        returns (bytes32)
    {

        return EIP712_DOMAIN_HASH;
    }
}pragma solidity 0.5.16;



contract FeeSchedule is IFeeSchedule {


    IWhitelist private systemParamsWhitelist;

    mapping(address => uint256) private oracleFees; // the convention is 10**20 = 100%

    event NewOracleFee(
        address indexed token,
        uint256 feeFrac
    );

    constructor(IWhitelist _systemParamsWhitelist) public {
        systemParamsWhitelist = _systemParamsWhitelist;
    }

    modifier onlySystemParamsAdmin() {

        require(
            systemParamsWhitelist.getWhitelisted(msg.sender),
            "NOT_SYSTEM_PARAM_ADMIN"
        );
        _;
    }

    modifier underMaxOracleFee(uint256 feeFrac) {

        require(
            feeFrac < LibOrder.getOddsPrecision(),
            "ORACLE_FEE_TOO_HIGH"
        );
        _;
    }

    function getOracleFees(address token) public view returns (uint256) {

        return oracleFees[token];
    }

    function setOracleFee(address token, uint256 feeFrac)
        public
        onlySystemParamsAdmin
        underMaxOracleFee(feeFrac)
    {

        oracleFees[token] = feeFrac;

        emit NewOracleFee(
            token,
            feeFrac
        );
    }
}pragma solidity 0.5.16;



contract FillOrder is IFillOrder, BaseFillOrder {


    IEIP712FillHasher internal eip712FillHasher;

    constructor(ISuperAdminRole _superAdminRole, IEIP712FillHasher _eip712FillHasher) public BaseFillOrder(_superAdminRole) {
        eip712FillHasher = _eip712FillHasher;
    }

    function fillOrders(
        LibOrder.FillDetails memory fillDetails,
        bytes memory executorSig
    )
        public
    {

        address executor = fillDetails.fills.orders[0].executor;
        bytes32 fillHash;

        require(
            fillDetails.fills.orders.length == fillDetails.fills.takerAmounts.length &&
            fillDetails.fills.orders.length == fillDetails.fills.makerSigs.length,
            "INCORRECT_ARRAY_LENGTHS"
        );

        if (executor != address(0)) {
            fillHash = eip712FillHasher.getDetailsHash(fillDetails);

            require(
                fills.getFillHashSubmitted(fillHash) == false,
                "FILL_ALREADY_SUBMITTED"
            );

            require(
                ECDSA.recover(
                    fillHash,
                    executorSig
                ) == executor,
                "EXECUTOR_SIGNATURE_MISMATCH"
            );

            if (fillDetails.fills.orders.length > 1) {
                for (uint256 i = 1; i < fillDetails.fills.orders.length; i++) {
                    require(
                        fillDetails.fills.orders[i].executor == executor,
                        "INCONSISTENT_EXECUTORS"
                    );
                }
            }

            fills.setFillHashSubmitted(fillHash);
        }

        _fillOrders(
            fillDetails.fills.orders,
            fillDetails.fills.takerAmounts,
            fillDetails.fills.makerSigs,
            msg.sender,
            fillHash
        );

    }

    function metaFillOrders(
        LibOrder.FillDetails memory fillDetails,
        address taker,
        bytes memory takerSig,
        bytes memory executorSig
    )
        public
    {

        bytes32 fillHash = eip712FillHasher.getDetailsHash(fillDetails);

        require(
            ECDSA.recover(
                fillHash,
                takerSig
            ) == taker,
            "TAKER_SIGNATURE_MISMATCH"
        );

        require(
            fills.getFillHashSubmitted(fillHash) == false,
            "FILL_ALREADY_SUBMITTED"
        );

        address executor = fillDetails.fills.orders[0].executor;

        if (executor != address(0)) {
            require(
                msg.sender == executor,
                "SENDER_MUST_BE_EXECUTOR"
            );
            require(
                ECDSA.recover(
                    fillHash,
                    executorSig
                ) == executor,
                "EXECUTOR_SIGNATURE_MISMATCH"
            );
        }

        require(
            fillDetails.fills.orders.length == fillDetails.fills.takerAmounts.length &&
            fillDetails.fills.orders.length == fillDetails.fills.makerSigs.length,
            "INCORRECT_ARRAY_LENGTHS"
        );

        if (fillDetails.fills.orders.length > 1) {
            for (uint256 i = 1; i < fillDetails.fills.orders.length; i++) {
                require(
                    fillDetails.fills.orders[i].executor == executor,
                    "INCONSISTENT_EXECUTORS"
                );
            }
        }

        _fillOrders(
            fillDetails.fills.orders,
            fillDetails.fills.takerAmounts,
            fillDetails.fills.makerSigs,
            taker,
            fillHash
        );

        fills.setFillHashSubmitted(fillHash);
    }

    function _fillOrders(
        LibOrder.Order[] memory makerOrders,
        uint256[] memory takerAmounts,
        bytes[] memory makerSigs,
        address taker,
        bytes32 fillHash
    )
        private
    {

        bool areOrdersSimilar = areOrdersValidAndSimilar(
            makerOrders,
            takerAmounts,
            makerSigs,
            taker
        );

        if (areOrdersSimilar) {
            _fillSimilarOrders(
                makerOrders,
                takerAmounts,
                taker,
                fillHash
            );
        } else {
            for (uint256 i = 0; i < makerOrders.length; i++) {
                _fillSingleOrder(
                    makerOrders[i],
                    takerAmounts[i],
                    taker,
                    fillHash
                );
            }
        }
    }

    function _fillSimilarOrders(
        LibOrder.Order[] memory makerOrders,
        uint256[] memory takerAmounts,
        address taker,
        bytes32 fillHash
    )
        private
    {

        LibOrderAmounts.OrderAmounts memory totalOrderAmounts = LibOrderAmounts.computeTotalOrderAmounts(
            makerOrders,
            takerAmounts
        );

        settleOrderForTaker(
            makerOrders[0],
            totalOrderAmounts,
            taker
        );

        settleOrdersForMaker(
            makerOrders,
            takerAmounts,
            taker,
            fillHash
        );
    }

    function areOrdersValidAndSimilar(
        LibOrder.Order[] memory makerOrders,
        uint256[] memory takerAmounts,
        bytes[] memory makerSigs,
        address taker
    )
        private
        view
        returns (bool)
    {

        bool isMakerBettingOutcomeOne = makerOrders[0].isMakerBettingOutcomeOne;
        bytes32 marketHash = makerOrders[0].marketHash;
        address baseToken = makerOrders[0].baseToken;

        for (uint256 i = 0; i < makerOrders.length; i++) {
            assertOrderValid(
                makerOrders[i],
                takerAmounts[i],
                taker,
                makerSigs[i]
            );
        }

        if (makerOrders.length > 1) {
            for (uint256 i = 1; i < makerOrders.length; i++) {
                if (makerOrders[i].isMakerBettingOutcomeOne != isMakerBettingOutcomeOne ||
                    makerOrders[i].marketHash != marketHash ||
                    makerOrders[i].baseToken != baseToken
                ) {
                    return false;
                }
            }
        }
        return true;
    }

    function settleOrdersForMaker(
        LibOrder.Order[] memory makerOrders,
        uint256[] memory takerAmounts,
        address taker,
        bytes32 fillHash
    )
        private
    {

        for (uint256 i = 0; i < makerOrders.length; i++) {
            LibOrderAmounts.OrderAmounts memory orderAmounts = LibOrderAmounts.computeOrderAmounts(
                makerOrders[i],
                takerAmounts[i]
            );

            uint256 newFillAmount = fills.fill(makerOrders[i], orderAmounts.takerAmount);

            settleOrderForMaker(
                makerOrders[i],
                orderAmounts
            );

            emit OrderFill(
                makerOrders[i].maker,
                makerOrders[i].marketHash,
                taker,
                newFillAmount,
                makerOrders[i].getOrderHash(),
                fillHash,
                makerOrders[i],
                orderAmounts
            );
        }
    }
}pragma solidity 0.5.16;



contract Fills is IFills {

    using LibOrder for LibOrder.Order;
    using SafeMath for uint256;

    IFillOrder private fillOrder;
    ICancelOrder private cancelOrder;

    mapping(bytes32 => uint256) private filled;
    mapping(bytes32 => bool) private cancelled;
    mapping(bytes32 => bool) private fillHashSubmitted;

    modifier onlyFillOrder() {

        require(
            msg.sender == address(fillOrder),
            "ONLY_FILL_ORDER"
        );
        _;
    }

    modifier onlyCancelOrderContract() {

        require(
            msg.sender == address(cancelOrder),
            "ONLY_CANCEL_ORDER_CONTRACT"
        );
        _;
    }

    constructor(IFillOrder _fillOrder, ICancelOrder _cancelOrder) public {
        fillOrder = _fillOrder;
        cancelOrder = _cancelOrder;
    }

    function fill(
        LibOrder.Order memory order,
        uint256 amount
    )
        public
        onlyFillOrder
        returns (uint256)
    {

        bytes32 orderHash = order.getOrderHash();
        filled[orderHash] = filled[orderHash].add(amount);
        return filled[orderHash];
    }

    function cancel(LibOrder.Order memory order)
        public
        onlyCancelOrderContract
    {

        bytes32 orderHash = order.getOrderHash();
        cancelled[orderHash] = true;
    }

    function setFillHashSubmitted(bytes32 fillHash)
        public
        onlyFillOrder
    {

        fillHashSubmitted[fillHash] = true;
    }

    function getFilled(bytes32 orderHash) public view returns (uint256) {

        return filled[orderHash];
    }

    function getCancelled(bytes32 orderHash) public view returns (bool) {

        return cancelled[orderHash];
    }

    function getFillHashSubmitted(bytes32 orderHash) public view returns (bool) {

        return fillHashSubmitted[orderHash];
    }

    function orderHasSpace(
        LibOrder.Order memory order,
        uint256 takerAmount
    )
        public
        view
        returns (bool)
    {

        return takerAmount <= remainingSpace(order);
    }

    function remainingSpace(LibOrder.Order memory order)
        public
        view
        returns (uint256)
    {

        bytes32 orderHash = order.getOrderHash();
        if (cancelled[orderHash]) {
            return 0;
        } else {
            return order.totalBetSize.sub(filled[orderHash]);
        }
    }

    function isOrderCancelled(LibOrder.Order memory order)
        public
        view
        returns(bool)
    {

        bytes32 orderHash = order.getOrderHash();
        return cancelled[orderHash];
    }
}pragma solidity 0.5.16;



contract TokenTransferProxy is ITokenTransferProxy {


    IFillOrder private fillOrder;

    constructor (IFillOrder _fillOrder) public {
        fillOrder = _fillOrder;
    }

    modifier onlyFillOrder() {

        require(
            msg.sender == address(fillOrder),
            "ONLY_FILL_ORDER"
        );
        _;
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 value
    )
        public
        onlyFillOrder
        returns (bool)
    {

        return IERC20(token).transferFrom(from, to, value);
    }
}pragma solidity 0.5.16;

contract IDetailedTokenDAI {

    function name() public view returns (bytes32);

    function symbol() public view returns (bytes32);

    function decimals() public view returns (uint256);

}