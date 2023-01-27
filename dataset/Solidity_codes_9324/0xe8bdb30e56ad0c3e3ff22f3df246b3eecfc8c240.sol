
pragma solidity 0.6.6;



library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
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




library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}





library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}









library SafeMathDivRoundUp {

    using SafeMath for uint256;

    function divRoundUp(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        require(b > 0, errorMessage);
        return ((a - 1) / b) + 1;
    }

    function divRoundUp(uint256 a, uint256 b) internal pure returns (uint256) {

        return divRoundUp(a, b, "SafeMathDivRoundUp: modulo by zero");
    }
}


abstract contract UseSafeMath {
    using SafeMath for uint256;
    using SafeMathDivRoundUp for uint256;
    using SafeMath for uint64;
    using SafeMathDivRoundUp for uint64;
    using SafeMath for uint16;
    using SignedSafeMath for int256;
    using SafeCast for uint256;
    using SafeCast for int256;
}





interface AuctionTimeControlInterface {

    enum TimeControlFlag {
        BEFORE_AUCTION_FLAG,
        ACCEPTING_BIDS_PERIOD_FLAG,
        REVEALING_BIDS_PERIOD_FLAG,
        RECEIVING_SBT_PERIOD_FLAG,
        AFTER_AUCTION_FLAG
    }

    function listAuction(uint256 timestamp)
        external
        view
        returns (bytes32[] memory);


    function getTimeControlFlag(bytes32 auctionID)
        external
        view
        returns (TimeControlFlag);


    function isInPeriod(bytes32 auctionID, TimeControlFlag flag)
        external
        view
        returns (bool);


    function isAfterPeriod(bytes32 auctionID, TimeControlFlag flag)
        external
        view
        returns (bool);

}






interface AuctionInterface is AuctionTimeControlInterface {

    event LogStartAuction(
        bytes32 indexed auctionID,
        bytes32 bondID,
        uint256 auctionedAmount
    );

    event LogCancelBid(
        bytes32 indexed auctionID,
        address indexed bidder,
        bytes32 secret,
        uint256 returnedIDOLAmount
    );

    event LogAuctionResult(
        bytes32 indexed auctionID,
        address indexed bidder,
        uint256 SBTAmountOfReward,
        uint256 IDOLAmountOfPayment,
        uint256 IDOLAmountOfChange
    );

    event LogCloseAuction(
        bytes32 indexed auctionID,
        bool isLast,
        bytes32 nextAuctionID
    );

    function ongoingAuctionSBTTotal(bytes32 auctionID)
        external
        view
        returns (uint64 ongoingSBTAmountE8);


    function startAuction(
        bytes32 bondID,
        uint64 auctionAmount,
        bool isEmergency
    ) external returns (bytes32 auctonID);


    function cancelBid(bytes32 auctionID, bytes32 secret)
        external
        returns (uint64 returnedIDOLAmount);


    function makeAuctionResult(
        bytes32 auctionID,
        uint64 myLowestPrice,
        uint64[] calldata winnerBids,
        uint64[] calldata loserBids
    )
        external
        returns (
            uint64 winnerAmount,
            uint64 toPay,
            uint64 IDOLAmountOfChange
        );


    function closeAuction(bytes32 auctionID)
        external
        returns (bool isLast, bytes32 nextAuctionID);


    function receiveUnrevealedBidDistribution(bytes32 auctionID, bytes32 secret)
        external
        returns (bool success);


    function getCurrentAuctionID(bytes32 bondID)
        external
        view
        returns (bytes32 auctionID);


    function generateAuctionID(bytes32 bondID, uint256 auctionCount)
        external
        pure
        returns (bytes32 auctionID);


    function listBondIDFromAuctionID(bytes32[] calldata auctionIDs)
        external
        view
        returns (bytes32[] memory bondIDs);


    function getAuctionStatus(bytes32 auctionID)
        external
        view
        returns (
            uint256 closingTime,
            uint64 auctionAmount,
            uint64 rewardedAmount,
            uint64 totalSBTAmountBid,
            bool isEmergency,
            bool doneFinalizeWinnerAmount,
            bool doneSortPrice,
            uint64 lowestBidPriceDeadLine,
            uint64 highestBidPriceDeadLine,
            uint64 totalSBTAmountPaidForUnrevealed
        );


    function getWeeklyAuctionStatus(uint256 weekNumber)
        external
        view
        returns (uint256[] memory weeklyAuctionStatus);


    function calcWinnerAmount(
        bytes32 auctionID,
        address sender,
        uint64[] calldata winnerBids
    ) external view returns (uint64 winnerAmount);


    function calcBillAndCheckLoserBids(
        bytes32 auctionID,
        address sender,
        uint64 winnerAmountInput,
        uint64 myLowestPrice,
        uint64[] calldata myLoseBids
    ) external view returns (uint64 paymentAmount);


    function getAuctionCount(bytes32 bondID)
        external
        view
        returns (uint256 auctionCount);

}





abstract contract Time {
    function _getBlockTimestampSec()
        internal
        view
        returns (uint256 unixtimesec)
    {
        unixtimesec = now; // solium-disable-line security/no-block-members
    }
}







contract AuctionTimeControl is Time, AuctionTimeControlInterface {

    uint256 internal immutable MIN_NORMAL_AUCTION_PERIOD;
    uint256 internal immutable MIN_EMERGENCY_AUCTION_PERIOD;
    uint256 internal immutable NORMAL_AUCTION_REVEAL_SPAN;
    uint256 internal immutable EMERGENCY_AUCTION_REVEAL_SPAN;
    uint256 internal immutable AUCTION_WITHDRAW_SPAN;
    uint256 internal immutable EMERGENCY_AUCTION_WITHDRAW_SPAN;

    TimeControlFlag internal constant BEFORE_AUCTION_FLAG = TimeControlFlag
        .BEFORE_AUCTION_FLAG;
    TimeControlFlag internal constant ACCEPTING_BIDS_PERIOD_FLAG = TimeControlFlag
        .ACCEPTING_BIDS_PERIOD_FLAG;
    TimeControlFlag internal constant REVEALING_BIDS_PERIOD_FLAG = TimeControlFlag
        .REVEALING_BIDS_PERIOD_FLAG;
    TimeControlFlag internal constant RECEIVING_SBT_PERIOD_FLAG = TimeControlFlag
        .RECEIVING_SBT_PERIOD_FLAG;
    TimeControlFlag internal constant AFTER_AUCTION_FLAG = TimeControlFlag
        .AFTER_AUCTION_FLAG;

    mapping(bytes32 => bool) public isAuctionEmergency;

    mapping(bytes32 => uint256) public auctionClosingTime;

    mapping(uint256 => bytes32[]) internal _weeklyAuctionList;

    constructor(
        uint256 minNormalAuctionPeriod,
        uint256 minEmergencyAuctionPeriod,
        uint256 normalAuctionRevealSpan,
        uint256 emergencyAuctionRevealSpan,
        uint256 auctionWithdrawSpan,
        uint256 emergencyAuctionWithdrawSpan
    ) public {
        MIN_NORMAL_AUCTION_PERIOD = minNormalAuctionPeriod;
        MIN_EMERGENCY_AUCTION_PERIOD = minEmergencyAuctionPeriod;
        NORMAL_AUCTION_REVEAL_SPAN = normalAuctionRevealSpan;
        EMERGENCY_AUCTION_REVEAL_SPAN = emergencyAuctionRevealSpan;
        AUCTION_WITHDRAW_SPAN = auctionWithdrawSpan;
        EMERGENCY_AUCTION_WITHDRAW_SPAN = emergencyAuctionWithdrawSpan;
    }

    function listAuction(uint256 weekNumber)
        public
        override
        view
        returns (bytes32[] memory)
    {

        return _weeklyAuctionList[weekNumber];
    }

    function getTimeControlFlag(bytes32 auctionID)
        public
        override
        view
        returns (TimeControlFlag)
    {

        uint256 closingTime = auctionClosingTime[auctionID];

        bool isEmergency = isAuctionEmergency[auctionID];
        uint256 revealSpan = NORMAL_AUCTION_REVEAL_SPAN;
        uint256 withdrawSpan = AUCTION_WITHDRAW_SPAN;
        if (isEmergency) {
            revealSpan = EMERGENCY_AUCTION_REVEAL_SPAN;
            withdrawSpan = EMERGENCY_AUCTION_WITHDRAW_SPAN;
        }

        uint256 nowTime = _getBlockTimestampSec();
        if (closingTime == 0) {
            return BEFORE_AUCTION_FLAG;
        } else if (nowTime <= closingTime) {
            return ACCEPTING_BIDS_PERIOD_FLAG;
        } else if (nowTime < closingTime + revealSpan) {
            return REVEALING_BIDS_PERIOD_FLAG;
        } else if (nowTime < closingTime + revealSpan + withdrawSpan) {
            return RECEIVING_SBT_PERIOD_FLAG;
        } else {
            return AFTER_AUCTION_FLAG;
        }
    }

    function isInPeriod(bytes32 auctionID, TimeControlFlag flag)
        public
        override
        view
        returns (bool)
    {

        return getTimeControlFlag(auctionID) == flag;
    }

    function isAfterPeriod(bytes32 auctionID, TimeControlFlag flag)
        public
        override
        view
        returns (bool)
    {

        return getTimeControlFlag(auctionID) >= flag;
    }

    function _setAuctionClosingTime(bytes32 auctionID, bool isEmergency)
        internal
    {

        uint256 closingTime;

        if (isEmergency) {
            closingTime =
                ((_getBlockTimestampSec() +
                    MIN_EMERGENCY_AUCTION_PERIOD +
                    5 minutes -
                    1) / 5 minutes) *
                (5 minutes);
        } else {
            closingTime =
                ((_getBlockTimestampSec() +
                    MIN_NORMAL_AUCTION_PERIOD +
                    1 hours -
                    1) / 1 hours) *
                (1 hours);
        }
        _setAuctionClosingTime(auctionID, isEmergency, closingTime);
    }

    function _setAuctionClosingTime(
        bytes32 auctionID,
        bool isEmergency,
        uint256 closingTime
    ) internal {

        isAuctionEmergency[auctionID] = isEmergency;
        auctionClosingTime[auctionID] = closingTime;
        uint256 weekNumber = closingTime / (1 weeks);
        _weeklyAuctionList[weekNumber].push(auctionID);
    }
}





interface BondMakerInterface {

    event LogNewBond(
        bytes32 indexed bondID,
        address bondTokenAddress,
        uint64 stableStrikePrice,
        bytes32 fnMapID
    );

    event LogNewBondGroup(uint256 indexed bondGroupID);

    event LogIssueNewBonds(
        uint256 indexed bondGroupID,
        address indexed issuer,
        uint256 amount
    );

    event LogReverseBondToETH(
        uint256 indexed bondGroupID,
        address indexed owner,
        uint256 amount
    );

    event LogExchangeEquivalentBonds(
        address indexed owner,
        uint256 indexed inputBondGroupID,
        uint256 indexed outputBondGroupID,
        uint256 amount
    );

    event LogTransferETH(
        address indexed from,
        address indexed to,
        uint256 value
    );

    function registerNewBond(uint256 maturity, bytes calldata fnMap)
        external
        returns (
            bytes32 bondID,
            address bondTokenAddress,
            uint64 solidStrikePrice,
            bytes32 fnMapID
        );


    function registerNewBondGroup(
        bytes32[] calldata bondIDList,
        uint256 maturity
    ) external returns (uint256 bondGroupID);


    function issueNewBonds(uint256 bondGroupID)
        external
        payable
        returns (uint256 amount);


    function reverseBondToETH(uint256 bondGroupID, uint256 amount)
        external
        returns (bool success);


    function exchangeEquivalentBonds(
        uint256 inputBondGroupID,
        uint256 outputBondGroupID,
        uint256 amount,
        bytes32[] calldata exceptionBonds
    ) external returns (bool);


    function liquidateBond(uint256 bondGroupID, uint256 oracleHintID) external;


    function getBond(bytes32 bondID)
        external
        view
        returns (
            address bondAddress,
            uint256 maturity,
            uint64 solidStrikePrice,
            bytes32 fnMapID
        );


    function getFnMap(bytes32 fnMapID)
        external
        view
        returns (bytes memory fnMap);


    function getBondGroup(uint256 bondGroupID)
        external
        view
        returns (bytes32[] memory bondIDs, uint256 maturity);


    function generateBondID(uint256 maturity, bytes calldata functionHash)
        external
        pure
        returns (bytes32 bondID);

}






abstract contract UseBondMaker {
    BondMakerInterface internal immutable _bondMakerContract;

    constructor(address contractAddress) public {
        require(
            contractAddress != address(0),
            "contract should be non-zero address"
        );
        _bondMakerContract = BondMakerInterface(payable(contractAddress));
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






interface StableCoinInterface is IERC20 {

    event LogIsAcceptableSBT(bytes32 indexed bondID, bool isAcceptable);

    event LogMintIDOL(
        bytes32 indexed bondID,
        address indexed owner,
        bytes32 poolID,
        uint256 obtainIDOLAmount,
        uint256 poolIDOLAmount
    );

    event LogBurnIDOL(
        bytes32 indexed bondID, // poolID?
        address indexed owner,
        uint256 burnIDOLAmount,
        uint256 unlockSBTAmount
    );

    event LogReturnLockedPool(
        bytes32 indexed poolID,
        address indexed owner,
        uint64 backIDOLAmount
    );

    event LogLambda(
        bytes32 indexed poolID,
        uint64 settledAverageAuctionPrice,
        uint256 totalSupply,
        uint256 lockedSBTValue
    );

    function getPoolInfo(bytes32 poolID)
        external
        view
        returns (
            uint64 lockedSBTTotal,
            uint64 unlockedSBTTotal,
            uint64 lockedPoolIDOLTotal,
            uint64 burnedIDOLTotal,
            uint64 soldSBTTotalInAuction,
            uint64 paidIDOLTotalInAuction,
            uint64 settledAverageAuctionPrice,
            bool isAllAmountSoldInAuction
        );


    function solidValueTotal() external view returns (uint256 solidValue);


    function isAcceptableSBT(bytes32 bondID) external returns (bool ok);


    function mint(
        bytes32 bondID,
        address recipient,
        uint64 lockAmount
    )
        external
        returns (
            bytes32 poolID,
            uint64 obtainIDOLAmount,
            uint64 poolIDOLAmount
        );


    function burnFrom(address account, uint256 amount) external;


    function unlockSBT(bytes32 bondID, uint64 burnAmount)
        external
        returns (uint64 rewardSBT);


    function startAuctionOnMaturity(bytes32 bondID) external;


    function startAuctionByMarket(bytes32 bondID) external;


    function setSettledAverageAuctionPrice(
        bytes32 bondID,
        uint64 totalPaidIDOL,
        uint64 SBTAmount,
        bool isLast
    ) external;


    function calcSBT2IDOL(uint256 solidBondAmount)
        external
        view
        returns (uint256 IDOLAmount);


    function returnLockedPool(bytes32[] calldata poolIDs)
        external
        returns (uint64 IDOLAmount);


    function returnLockedPoolTo(bytes32[] calldata poolIDs, address account)
        external
        returns (uint64 IDOLAmount);


    function generatePoolID(bytes32 bondID, uint64 count)
        external
        pure
        returns (bytes32 poolID);


    function getCurrentPoolID(bytes32 bondID)
        external
        view
        returns (bytes32 poolID);


    function getLockedPool(address user, bytes32 poolID)
        external
        view
        returns (uint64, uint64);

}






abstract contract UseStableCoin {
    StableCoinInterface internal immutable _IDOLContract;

    constructor(address contractAddress) public {
        require(
            contractAddress != address(0),
            "contract should be non-zero address"
        );
        _IDOLContract = StableCoinInterface(contractAddress);
    }

    function _transferIDOLFrom(
        address from,
        address to,
        uint256 amount
    ) internal {
        _IDOLContract.transferFrom(from, to, amount);
    }

    function _transferIDOL(address to, uint256 amount) internal {
        _IDOLContract.transfer(to, amount);
    }

    function _transferIDOL(
        address to,
        uint256 amount,
        string memory errorMessage
    ) internal {
        require(_IDOLContract.balanceOf(address(this)) >= amount, errorMessage);
        _IDOLContract.transfer(to, amount);
    }
}






interface AuctionSecretInterface {

        function auctionSecret(
        bytes32 auctionID,
        bytes32 secret
    ) external view returns (
        address sender,
        uint64 amount,
        uint64 IDOLamount
    );

}

abstract contract AuctionSecret is AuctionSecretInterface {
    struct Secret {
        address sender;
        uint64 amount;
        uint64 IDOLamount;
    }
    mapping(bytes32 => mapping(bytes32 => Secret)) public override auctionSecret;

    function _setSecret(
        bytes32 auctionID,
        bytes32 secret,
        address sender,
        uint64 amount,
        uint64 IDOLamount
    ) internal returns (bool) {
        require(
            auctionSecret[auctionID][secret].sender == address(0),
            "Secret already exists"
        );
        require(sender != address(0), "the zero address cannot set secret");
        auctionSecret[auctionID][secret] = Secret({
            sender: sender,
            amount: amount,
            IDOLamount: IDOLamount
        });
        return true;
    }

    function _removeSecret(bytes32 auctionID, bytes32 secret)
        internal
        returns (bool)
    {
        delete auctionSecret[auctionID][secret];
        return true;
    }
}





interface AuctionBoardInterface is AuctionSecretInterface {

    event LogBidMemo(
        bytes32 indexed auctionID,
        address indexed bidder,
        bytes memo
    );

    event LogInsertBoard(
        bytes32 indexed auctionID,
        address indexed bidder,
        uint64 bidPrice,
        uint64 boardIndex,
        uint64 targetSBTAmount
    );

    event LogAuctionInfoDiff(
        bytes32 indexed auctionID,
        uint64 settledAmount,
        uint64 paidIDOL,
        uint64 rewardedSBT
    );

    function bidWithMemo(
        bytes32 auctionID,
        bytes32 secret,
        uint64 totalSBTAmountBid,
        bytes calldata memo
    ) external returns (uint256 depositedIDOLAmount);


    function revealBids(
        bytes32 auctionID,
        uint64[] calldata bids,
        uint64 random
    ) external;


    function sortBidPrice(bytes32 auctionID, uint64[] calldata sortedPrice)
        external;


    function makeEndInfo(bytes32 auctionID) external;


    function calcBill(
        bytes32 auctionID,
        uint64 winnerAmount,
        uint64 myLowestPrice
    ) external view returns (uint64 paymentAmount);


    function getUnsortedBidPrice(bytes32 auctionID)
        external
        view
        returns (uint64[] memory bidPriceList);


    function getSortedBidPrice(bytes32 auctionID)
        external
        view
        returns (uint64[] memory bidPriceList);


    function getEndInfo(bytes32 auctionID)
        external
        view
        returns (
            uint64 price,
            uint64 boardIndex,
            uint64 loseSBTAmount,
            uint64 auctionEndPriceWinnerSBTAmount
        );


    function getBidderStatus(bytes32 auctionID, address bidder)
        external
        view
        returns (uint64 toBack, bool isIDOLReturned);


    function getBoard(
        bytes32 auctionID,
        uint64 price,
        uint64 boardIndex
    ) external view returns (address bidder, uint64 amount);


    function getBoardStatus(bytes32 auctionID)
        external
        view
        returns (uint64[] memory boardStatus);


    function generateMultiSecret(
        bytes32 auctionID,
        uint64[] calldata bids,
        uint64 random
    ) external pure returns (bytes32 secret);


    function discretizeBidPrice(uint64 price)
        external
        pure
        returns (uint64 discretizedPrice);


    function auctionDisposalInfo(bytes32 auctionID) external view returns (
        uint64 solidStrikePriceIDOLForUnrevealedE8,
        uint64 solidStrikePriceIDOLForRestWinnersE8,
        bool isEndInfoCreated,
        bool isForceToFinalizeWinnerAmountTriggered,
        bool isPriceSorted
    );


    function removeSecret(
        bytes32 auctionID,
        bytes32 secret,
        uint64 subtractAmount
    ) external;


    function auctionRevealInfo(bytes32 auctionID) external view returns (
        uint64 totalSBTAmountBid,
        uint64 totalIDOLSecret,
        uint64 totalIDOLRevealed,
        uint16 auctionPriceCount
    );


    function auctionBoard(
        bytes32 auctionID,
        uint64 bidPrice,
        uint256 boardIndex
    ) external view returns (
        uint64 bidAmount,
        address bidder
    );


    function auctionParticipantInfo(
        bytes32 auctionID,
        address participant
    ) external view returns (
        uint64 auctionLockedIDOLAmountE8,
        uint16 bidCount
    );


    function auctionInfo(
        bytes32 auctionID
    ) external view returns (
        uint64 auctionSettledTotalE8,
        uint64 auctionRewardedTotalE8,
        uint64 auctionPaidTotalE8
    );


    function updateAuctionInfo(
        bytes32 auctionID,
        uint64 settledAmountE8,
        uint64 paidIDOLE8,
        uint64 rewardedSBTE8
    ) external;


    function deleteParticipantInfo(
        bytes32 auctionID,
        address participant
    ) external;

}






abstract contract UseAuctionBoard {
    AuctionBoardInterface internal immutable _auctionBoardContract;

    constructor(address contractAddress) public {
        require(
            contractAddress != address(0),
            "contract should be non-zero address"
        );
        _auctionBoardContract = AuctionBoardInterface(contractAddress);
    }
}





interface OracleInterface {

    function alive() external view returns (bool);


    function latestId() external returns (uint256);


    function latestPrice() external returns (uint256);


    function latestTimestamp() external returns (uint256);


    function getPrice(uint256 id) external returns (uint256);


    function getTimestamp(uint256 id) external returns (uint256);


    function getVolatility() external returns (uint256);

}






abstract contract UseOracle {
    OracleInterface internal _oracleContract;

    constructor(address contractAddress) public {
        require(
            contractAddress != address(0),
            "contract should be non-zero address"
        );
        _oracleContract = OracleInterface(contractAddress);
    }

    function _getOracleData()
        internal
        returns (uint256 rateETH2USDE8, uint256 volatilityE8)
    {
        rateETH2USDE8 = _oracleContract.latestPrice();
        volatilityE8 = _oracleContract.getVolatility();

        return (rateETH2USDE8, volatilityE8);
    }

    function _getPriceOn(uint256 timestamp, uint256 hintID)
        internal
        returns (uint256 rateETH2USDE8)
    {
        uint256 latestID = _oracleContract.latestId();
        require(
            latestID != 0,
            "system error: the ID of oracle data should not be zero"
        );

        require(hintID != 0, "the hint ID must not be zero");
        uint256 id = hintID;
        if (hintID > latestID) {
            id = latestID;
        }

        require(
            _oracleContract.getTimestamp(id) > timestamp,
            "there is no price data after maturity"
        );

        id--;
        while (id != 0) {
            if (_oracleContract.getTimestamp(id) <= timestamp) {
                break;
            }
            id--;
        }

        return _oracleContract.getPrice(id + 1);
    }
}





interface TransferETHInterface {

    receive() external payable;

    event LogTransferETH(
        address indexed from,
        address indexed to,
        uint256 value
    );
}







interface BondTokenInterface is TransferETHInterface, IERC20 {

    event LogExpire(
        uint128 rateNumerator,
        uint128 rateDenominator,
        bool firstTime
    );

    function mint(address account, uint256 amount)
        external
        returns (bool success);


    function expire(uint128 rateNumerator, uint128 rateDenominator)
        external
        returns (bool firstTime);


    function burn(uint256 amount) external returns (bool success);


    function burnAll() external returns (uint256 amount);


    function isMinter(address account) external view returns (bool minter);


    function getRate()
        external
        view
        returns (uint128 rateNumerator, uint128 rateDenominator);

}














contract Auction is
    UseSafeMath,
    AuctionInterface,
    AuctionTimeControl,
    UseStableCoin,
    UseBondMaker,
    UseAuctionBoard
{

    using Math for uint256;

    uint64 internal constant NO_SKIP_BID = uint64(-1);
    uint64 internal constant SKIP_RECEIVING_WIN_BIDS = uint64(-2);
    uint256 internal constant POOL_AUCTION_COUNT_PADDING = 10**8;

    mapping(bytes32 => uint256) internal _bondIDAuctionCount;

    mapping(bytes32 => bytes32) public auctionID2BondID;

    struct AuctionConfig {
        uint64 ongoingAuctionSBTTotalE8;
        uint64 lowestBidPriceDeadLineE8;
        uint64 highestBidPriceDeadLineE8;
        uint64 totalSBTAmountPaidForUnrevealedE8;
    }
    mapping(bytes32 => AuctionConfig) internal _auctionConfigList;

    constructor(
        address bondMakerAddress,
        address IDOLAddress,
        address auctionBoardAddress,
        uint256 minNormalAuctionPeriod,
        uint256 minEmergencyAuctionPeriod,
        uint256 normalAuctionRevealSpan,
        uint256 emergencyAuctionRevealSpan,
        uint256 auctionWithdrawSpan,
        uint256 emergencyAuctionWithdrawSpan
    )
        public
        AuctionTimeControl(
            minNormalAuctionPeriod,
            minEmergencyAuctionPeriod,
            normalAuctionRevealSpan,
            emergencyAuctionRevealSpan,
            auctionWithdrawSpan,
            emergencyAuctionWithdrawSpan
        )
        UseBondMaker(bondMakerAddress)
        UseStableCoin(IDOLAddress)
        UseAuctionBoard(auctionBoardAddress)
    {}

    function startAuction(
        bytes32 bondID,
        uint64 auctionAmount,
        bool isEmergency
    ) external override returns (bytes32) {

        require(
            msg.sender == address(_IDOLContract),
            "caller must be IDOL contract"
        );
        return _startAuction(bondID, auctionAmount, isEmergency);
    }

    function _startAuction(
        bytes32 bondID,
        uint64 auctionAmount,
        bool isEmergency
    ) internal returns (bytes32) {

        (, , uint256 solidStrikePriceE4, ) = _bondMakerContract.getBond(bondID);
        uint256 strikePriceIDOL = _IDOLContract.calcSBT2IDOL(
            solidStrikePriceE4.mul(10**8)
        );

        uint256 auctionCount = _bondIDAuctionCount[bondID].add(1);
        _bondIDAuctionCount[bondID] = auctionCount;
        bytes32 auctionID = getCurrentAuctionID(bondID);
        require(
            isInPeriod(auctionID, BEFORE_AUCTION_FLAG),
            "the auction has been held"
        );

        uint256 betaCount = auctionCount.mod(POOL_AUCTION_COUNT_PADDING).min(9);

        auctionID2BondID[auctionID] = bondID;

        _setAuctionClosingTime(auctionID, isEmergency);

        {
            AuctionConfig memory auctionConfig = _auctionConfigList[auctionID];
            auctionConfig.ongoingAuctionSBTTotalE8 = auctionAmount;
            auctionConfig.lowestBidPriceDeadLineE8 = _auctionBoardContract
                .discretizeBidPrice(
                strikePriceIDOL
                    .mul(10 - betaCount)
                    .divRoundUp(10**(1 + 8))
                    .mul(10**8)
                    .toUint64()
            );
            auctionConfig.highestBidPriceDeadLineE8 = _auctionBoardContract
                .discretizeBidPrice(
                strikePriceIDOL.divRoundUp(10**8).mul(10**8).toUint64()
            );
            _auctionConfigList[auctionID] = auctionConfig;
        }

        emit LogStartAuction(auctionID, bondID, auctionAmount);

        return auctionID;
    }

    function calcWinnerAmount(
        bytes32 auctionID,
        address sender,
        uint64[] memory winnerBids
    ) public override view returns (uint64) {

        uint256 totalBidAmount;

        (
            uint64 endPrice,
            uint64 endBoardIndex,
            uint64 loseSBTAmount,

        ) = _auctionBoardContract.getEndInfo(auctionID);

        uint64 bidPrice;
        uint64 boardIndex;
        {
            (, , bool isEndInfoCreated, , ) = _auctionBoardContract
                .auctionDisposalInfo(auctionID);
            require(isEndInfoCreated, "the end info has not been made yet");
        }

        for (uint256 i = 0; i < winnerBids.length; i += 2) {
            if (i != 0) {
                require(
                    bidPrice > winnerBids[i] ||
                        (bidPrice == winnerBids[i] &&
                            boardIndex < winnerBids[i + 1]),
                    "winner bids are not sorted"
                );
            }
            bidPrice = winnerBids[i];
            boardIndex = winnerBids[i + 1];
            (uint64 bidAmount, address bidder) = _auctionBoardContract
                .auctionBoard(auctionID, bidPrice, boardIndex);
            require(bidder == sender, "this bid is not yours");

            totalBidAmount = totalBidAmount.add(bidAmount);
            if (endPrice == bidPrice) {
                if (boardIndex == endBoardIndex) {
                    totalBidAmount = totalBidAmount.sub(loseSBTAmount);
                } else {
                    require(
                        boardIndex < endBoardIndex,
                        "this bid does not win"
                    );
                }
            } else {
                require(endPrice < bidPrice, "this bid does not win");
            }
        }

        return totalBidAmount.toUint64();
    }

    function calcBillAndCheckLoserBids(
        bytes32 auctionID,
        address sender,
        uint64 winnerAmountInput,
        uint64 myLowestPrice,
        uint64[] memory myLoseBids
    ) public override view returns (uint64) {

        uint256 winnerAmount = winnerAmountInput;
        uint256 toPaySkip = 0;

        if (
            myLowestPrice != NO_SKIP_BID &&
            myLowestPrice != SKIP_RECEIVING_WIN_BIDS
        ) {
            bool myLowestVerify = false;
            for (uint256 i = 0; i < myLoseBids.length; i += 2) {
                uint64 price = myLoseBids[i];
                if (price == myLowestPrice) {
                    myLowestVerify = true;
                    break;
                }
            }

            require(
                myLowestVerify,
                "myLowestPrice must be included in myLoseBids"
            );
        }

        for (uint256 i = 0; i < myLoseBids.length; i += 2) {
            uint64 price = myLoseBids[i];
            uint64 boardIndex = myLoseBids[i + 1];

            if (i != 0) {
                require(
                    price < myLoseBids[i - 2] ||
                        (price == myLoseBids[i - 2] &&
                            boardIndex > myLoseBids[i - 1]),
                    "myLoseBids is not sorted"
                );
            }
            {
                (
                    uint64 endPrice,
                    uint64 endBoardIndex,
                    uint64 loseSBTAmount,

                ) = _auctionBoardContract.getEndInfo(auctionID);

                if (price == endPrice) {
                    if (boardIndex == endBoardIndex) {
                        require(
                            loseSBTAmount != 0,
                            "myLoseBids includes the bid which is same as endInfo with no lose SBT amount"
                        );


                        if (myLowestPrice <= price) {
                            winnerAmount = winnerAmount.add(loseSBTAmount);
                            toPaySkip = toPaySkip.add(
                                price.mul(loseSBTAmount).div(10**8)
                            );
                            continue;
                        }
                    } else {
                        require(
                            boardIndex > endBoardIndex,
                            "myLoseBids includes the bid whose bid index is less than that of endInfo"
                        );
                    }
                } else {
                    require(
                        price < endPrice,
                        "myLoseBids includes the bid whose price is more than that of endInfo"
                    );
                }
            }

            (uint64 bidAmount, address bidder) = _auctionBoardContract
                .auctionBoard(auctionID, price, boardIndex);
            require(
                bidder == sender,
                "myLoseBids includes the bid whose owner is not the sender"
            );

            if (myLowestPrice <= price) {
                winnerAmount = winnerAmount.add(bidAmount);
                toPaySkip = toPaySkip.add(price.mul(bidAmount).div(10**8));
            }
        }

        if (myLowestPrice == SKIP_RECEIVING_WIN_BIDS) {
            (uint64 endPrice, , , ) = _auctionBoardContract.getEndInfo(
                auctionID
            );
            return
                endPrice
                    .mul(winnerAmount)
                    .divRoundUp(10**8)
                    .sub(toPaySkip)
                    .toUint64();
        }

        return
            _auctionBoardContract
                .calcBill(auctionID, winnerAmount.toUint64(), myLowestPrice)
                .sub(toPaySkip)
                .toUint64();
    }

    function makeAuctionResult(
        bytes32 auctionID,
        uint64 myLowestPrice,
        uint64[] memory winnerBids,
        uint64[] memory loserBids
    )
        public
        override
        returns (
            uint64,
            uint64,
            uint64
        )
    {

        (
            uint64 auctionLockedIDOLAmountE8,
            uint16 bidCount
        ) = _auctionBoardContract.auctionParticipantInfo(auctionID, msg.sender);

        require(auctionLockedIDOLAmountE8 != 0, "This process is already done");

        {
            (
                uint64 endPrice,
                uint64 endBoardIndex,
                uint64 loseSBTAmount,
                uint64 auctionEndPriceWinnerSBTAmount
            ) = _auctionBoardContract.getEndInfo(auctionID);
            (address endBidder, ) = _auctionBoardContract.getBoard(
                auctionID,
                endPrice,
                endBoardIndex
            );
            require(
                winnerBids.length.div(2) + loserBids.length.div(2) ==
                    bidCount +
                        (
                            (msg.sender == endBidder &&
                                loseSBTAmount != 0 &&
                                auctionEndPriceWinnerSBTAmount != 0)
                                ? 1
                                : 0
                        ),
                "must submit all of your bids"
            );
        }

        uint64 winnerAmount = calcWinnerAmount(
            auctionID,
            msg.sender,
            winnerBids
        );

        uint64 toPay;
        TimeControlFlag timeFlag = getTimeControlFlag(auctionID);

        if (timeFlag == RECEIVING_SBT_PERIOD_FLAG) {
            toPay = calcBillAndCheckLoserBids(
                auctionID,
                msg.sender,
                winnerAmount,
                myLowestPrice,
                loserBids
            );
        } else {
            require(
                timeFlag > RECEIVING_SBT_PERIOD_FLAG,
                "has not been the receiving period yet"
            );
            toPay = calcBillAndCheckLoserBids(
                auctionID,
                msg.sender,
                winnerAmount,
                SKIP_RECEIVING_WIN_BIDS,
                loserBids
            );
        }

        if (toPay > auctionLockedIDOLAmountE8) {
            require(
                toPay.sub(auctionLockedIDOLAmountE8) < 10**8,
                "system error: does not ignore too big error for spam protection"
            );
            toPay = auctionLockedIDOLAmountE8;
        }
        uint64 IDOLAmountOfChange = auctionLockedIDOLAmountE8 - toPay;

        _auctionBoardContract.deleteParticipantInfo(auctionID, msg.sender);
        _transferIDOL(msg.sender, IDOLAmountOfChange);

        _auctionBoardContract.updateAuctionInfo(
            auctionID,
            0,
            toPay,
            winnerAmount
        );
        _distributeToWinners(auctionID, winnerAmount);

        emit LogAuctionResult(
            auctionID,
            msg.sender,
            winnerAmount,
            toPay,
            IDOLAmountOfChange
        );

        return (winnerAmount, toPay, IDOLAmountOfChange);
    }

    function closeAuction(bytes32 auctionID)
        public
        override
        returns (bool, bytes32)
    {

        (uint64 auctionSettledTotalE8, , ) = _auctionBoardContract.auctionInfo(
            auctionID
        );
        require(
            isInPeriod(auctionID, AFTER_AUCTION_FLAG),
            "This function is not allowed to execute in this period"
        );

        uint64 ongoingAuctionSBTTotal = _auctionConfigList[auctionID]
            .ongoingAuctionSBTTotalE8;
        require(ongoingAuctionSBTTotal != 0, "already closed");
        bytes32 bondID = auctionID2BondID[auctionID];

        {
            (, , bool isEndInfoCreated, , ) = _auctionBoardContract
                .auctionDisposalInfo(auctionID);
            require(isEndInfoCreated, "has not set end info");
        }

        _forceToFinalizeWinnerAmount(auctionID);

        uint256 nextAuctionAmount = ongoingAuctionSBTTotal.sub(
            auctionSettledTotalE8,
            "allocated SBT amount for auction never becomes lower than reward total"
        );

        bool isLast = nextAuctionAmount == 0;
        _publishSettledAverageAuctionPrice(auctionID, isLast);

        bytes32 nextAuctionID = bytes32(0);
        if (isLast) {
            _bondIDAuctionCount[bondID] = _bondIDAuctionCount[bondID]
                .div(POOL_AUCTION_COUNT_PADDING)
                .add(1)
                .mul(POOL_AUCTION_COUNT_PADDING);
        } else {
            nextAuctionID = _startAuction(
                bondID,
                nextAuctionAmount.toUint64(),
                true
            );
        }
        delete _auctionConfigList[auctionID].ongoingAuctionSBTTotalE8;

        emit LogCloseAuction(auctionID, isLast, nextAuctionID);

        return (isLast, nextAuctionID);
    }

    function _calcUnrevealedBidDistribution(
        uint64 ongoingAmount,
        uint64 totalIDOLAmountUnrevealed,
        uint64 totalSBTAmountPaidForUnrevealed,
        uint64 solidStrikePriceIDOL,
        uint64 IDOLAmountDeposited
    )
        internal
        pure
        returns (uint64 receivingSBTAmount, uint64 returnedIDOLAmount)
    {

        uint64 totalSBTAmountUnrevealed = totalIDOLAmountUnrevealed
            .mul(10**8)
            .div(solidStrikePriceIDOL, "system error: Oracle has a problem")
            .toUint64();

        uint64 totalLeftSBTAmountForUnrevealed = uint256(
            totalSBTAmountUnrevealed
        )
            .min(ongoingAmount)
            .sub(totalSBTAmountPaidForUnrevealed)
            .toUint64();

        uint256 expectedReceivingSBTAmount = IDOLAmountDeposited.mul(10**8).div(
            solidStrikePriceIDOL,
            "system error: Oracle has a problem"
        );

        if (expectedReceivingSBTAmount <= totalLeftSBTAmountForUnrevealed) {
            receivingSBTAmount = expectedReceivingSBTAmount.toUint64();
            returnedIDOLAmount = 0;
        } else if (totalLeftSBTAmountForUnrevealed == 0) {
            receivingSBTAmount = 0;
            returnedIDOLAmount = IDOLAmountDeposited;
        } else {
            receivingSBTAmount = totalLeftSBTAmountForUnrevealed;
            returnedIDOLAmount = IDOLAmountDeposited
                .sub(
                totalLeftSBTAmountForUnrevealed
                    .mul(solidStrikePriceIDOL)
                    .divRoundUp(10**8)
            )
                .toUint64();
        }

        return (receivingSBTAmount, returnedIDOLAmount);
    }

    function receiveUnrevealedBidDistribution(bytes32 auctionID, bytes32 secret)
        public
        override
        returns (bool)
    {

        (
            uint64 solidStrikePriceIDOL,
            ,
            bool isEndInfoCreated,
            ,

        ) = _auctionBoardContract.auctionDisposalInfo(auctionID);
        require(
            isEndInfoCreated,
            "EndInfo hasn't been made. This Function has not been allowed yet."
        );

        (address secOwner, , uint64 IDOLAmountDeposited) = _auctionBoardContract
            .auctionSecret(auctionID, secret);
        require(secOwner == msg.sender, "ownership of the bid is required");

        (
            ,
            uint64 totalIDOLSecret,
            uint64 totalIDOLAmountRevealed,

        ) = _auctionBoardContract.auctionRevealInfo(auctionID);
        uint64 totalIDOLAmountUnrevealed = totalIDOLSecret
            .sub(totalIDOLAmountRevealed)
            .toUint64();

        uint64 receivingSBTAmount;
        uint64 returnedIDOLAmount;
        uint64 totalSBTAmountPaidForUnrevealed;
        {
            AuctionConfig memory auctionConfig = _auctionConfigList[auctionID];
            totalSBTAmountPaidForUnrevealed = auctionConfig
                .totalSBTAmountPaidForUnrevealedE8;

            (
                receivingSBTAmount,
                returnedIDOLAmount
            ) = _calcUnrevealedBidDistribution(
                auctionConfig.ongoingAuctionSBTTotalE8,
                totalIDOLAmountUnrevealed,
                totalSBTAmountPaidForUnrevealed,
                solidStrikePriceIDOL,
                IDOLAmountDeposited
            );
        }

        _auctionConfigList[auctionID]
            .totalSBTAmountPaidForUnrevealedE8 = totalSBTAmountPaidForUnrevealed
            .add(receivingSBTAmount)
            .toUint64();
        _auctionBoardContract.removeSecret(auctionID, secret, 0);

        _distributeToWinners(auctionID, receivingSBTAmount);
        _IDOLContract.transfer(secOwner, returnedIDOLAmount);

        return true;
    }

    function cancelBid(bytes32 auctionID, bytes32 secret)
        public
        override
        returns (uint64)
    {

        require(
            isInPeriod(auctionID, ACCEPTING_BIDS_PERIOD_FLAG),
            "it is not the time to accept bids"
        );
        (address owner, , uint64 IDOLamount) = _auctionBoardContract
            .auctionSecret(auctionID, secret);
        require(owner == msg.sender, "you are not the bidder for the secret");
        _auctionBoardContract.removeSecret(auctionID, secret, IDOLamount);
        _transferIDOL(
            owner,
            IDOLamount,
            "system error: try to cancel bid, but cannot return iDOL"
        );

        emit LogCancelBid(auctionID, owner, secret, IDOLamount);

        return IDOLamount;
    }

    function getCurrentAuctionID(bytes32 bondID)
        public
        override
        view
        returns (bytes32)
    {

        uint256 count = _bondIDAuctionCount[bondID];
        return generateAuctionID(bondID, count);
    }

    function generateAuctionID(bytes32 bondID, uint256 count)
        public
        override
        pure
        returns (bytes32)
    {

        return keccak256(abi.encode(bondID, count));
    }

    function _distributeToWinners(bytes32 auctionID, uint64 receivingBondAmount)
        internal
        returns (uint64)
    {

        (address solidBondAddress, , , ) = _getBondFromAuctionID(auctionID);
        require(solidBondAddress != address(0), "the bond is not registered");

        BondTokenInterface solidBondContract = BondTokenInterface(
            payable(solidBondAddress)
        );
        solidBondContract.transfer(msg.sender, receivingBondAmount);
    }

    function _publishSettledAverageAuctionPrice(bytes32 auctionID, bool isLast)
        internal
    {

        bytes32 bondID = auctionID2BondID[auctionID];
        (
            ,
            uint64 auctionRewardedTotalE8,
            uint64 auctionPaidTotalE8
        ) = _auctionBoardContract.auctionInfo(auctionID);

        _transferIDOL(
            address(_IDOLContract),
            auctionPaidTotalE8,
            "system error: cannot transfer iDOL from auction contract to iDOL contract"
        );

        _IDOLContract.setSettledAverageAuctionPrice(
            bondID,
            auctionPaidTotalE8,
            auctionRewardedTotalE8,
            isLast
        );
    }

    function _forceToFinalizeWinnerAmount(bytes32 auctionID) internal {

        (
            uint64 auctionSettledTotalE8,
            uint64 auctionRewardedTotalE8,

        ) = _auctionBoardContract.auctionInfo(auctionID);

        if (_auctionBoardContract.getSortedBidPrice(auctionID).length == 0) {
            return;
        }

        (uint256 burnIDOLRate, , , ) = _auctionBoardContract.getEndInfo(
            auctionID
        );

        uint256 _totalSBTForRestWinners = auctionSettledTotalE8.sub(
            auctionRewardedTotalE8,
            "system error: allocated SBT amount for auction never becomes lower than reward total at any point"
        );

        uint256 burnIDOL = _totalSBTForRestWinners.mul(burnIDOLRate).div(10**8);

        _auctionBoardContract.updateAuctionInfo(
            auctionID,
            _totalSBTForRestWinners.toUint64(),
            burnIDOL.toUint64(),
            _totalSBTForRestWinners.toUint64()
        );
    }

    function _getBondFromAuctionID(bytes32 auctionID)
        internal
        view
        returns (
            address erc20Address,
            uint256 maturity,
            uint64 solidStrikePrice,
            bytes32 fnMapID
        )
    {

        bytes32 bondID = auctionID2BondID[auctionID];
        return _bondMakerContract.getBond(bondID);
    }

    function listBondIDFromAuctionID(bytes32[] memory auctionIDs)
        public
        override
        view
        returns (bytes32[] memory bondIDs)
    {

        bondIDs = new bytes32[](auctionIDs.length);
        for (uint256 i = 0; i < auctionIDs.length; i++) {
            bondIDs[i] = auctionID2BondID[auctionIDs[i]];
        }
    }

    function getAuctionStatus(bytes32 auctionID)
        public
        override
        view
        returns (
            uint256 closingTime,
            uint64 auctionAmount,
            uint64 rewardedAmount,
            uint64 totalSBTAmountBid,
            bool isEmergency,
            bool doneFinalizeWinnerAmount,
            bool doneSortPrice,
            uint64 lowestBidPriceDeadLine,
            uint64 highestBidPriceDeadLine,
            uint64 totalSBTAmountPaidForUnrevealed
        )
    {

        closingTime = auctionClosingTime[auctionID].toUint64();
        AuctionConfig memory auctionConfig = _auctionConfigList[auctionID];
        auctionAmount = auctionConfig.ongoingAuctionSBTTotalE8;
        lowestBidPriceDeadLine = auctionConfig.lowestBidPriceDeadLineE8;
        highestBidPriceDeadLine = auctionConfig.highestBidPriceDeadLineE8;
        totalSBTAmountPaidForUnrevealed = auctionConfig
            .totalSBTAmountPaidForUnrevealedE8;
        (, rewardedAmount, ) = _auctionBoardContract.auctionInfo(auctionID);
        (totalSBTAmountBid, , , ) = _auctionBoardContract.auctionRevealInfo(
            auctionID
        );
        isEmergency = isAuctionEmergency[auctionID];
        (, , , doneFinalizeWinnerAmount, doneSortPrice) = _auctionBoardContract
            .auctionDisposalInfo(auctionID);
    }

    function getWeeklyAuctionStatus(uint256 weekNumber)
        external
        override
        view
        returns (uint256[] memory weeklyAuctionStatus)
    {

        bytes32[] memory auctions = listAuction(weekNumber);
        weeklyAuctionStatus = new uint256[](auctions.length.mul(6));
        for (uint256 i = 0; i < auctions.length; i++) {
            (
                uint256 closingTime,
                uint64 auctionAmount,
                uint64 rewardedAmount,
                uint64 totalSBTAmountBid,
                bool isEmergency,
                bool doneFinalizeWinnerAmount,
                bool doneSortPrice,
                ,
                ,

            ) = getAuctionStatus(auctions[i]);
            uint8 auctionStatusCode = (isEmergency ? 1 : 0) << 2;
            auctionStatusCode += (doneFinalizeWinnerAmount ? 1 : 0) << 1;
            auctionStatusCode += doneSortPrice ? 1 : 0;
            weeklyAuctionStatus[i * 6] = closingTime;
            weeklyAuctionStatus[i * 6 + 1] = auctionAmount;
            weeklyAuctionStatus[i * 6 + 2] = rewardedAmount;
            weeklyAuctionStatus[i * 6 + 3] = totalSBTAmountBid;
            weeklyAuctionStatus[i * 6 + 4] = auctionStatusCode;
            weeklyAuctionStatus[i * 6 + 5] = uint256(auctions[i]);
        }
    }

    function ongoingAuctionSBTTotal(bytes32 auctionID)
        external
        override
        view
        returns (uint64 ongoingSBTAmountE8)
    {

        AuctionConfig memory auctionConfig = _auctionConfigList[auctionID];
        return auctionConfig.ongoingAuctionSBTTotalE8;
    }

    function getAuctionCount(bytes32 bondID)
        external
        override
        view
        returns (uint256 auctionCount)
    {

        return _bondIDAuctionCount[bondID];
    }
}