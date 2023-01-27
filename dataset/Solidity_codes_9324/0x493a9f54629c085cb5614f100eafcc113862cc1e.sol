


pragma solidity ^0.5.2;
pragma experimental "ABIEncoderV2";

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.2;

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
}



pragma solidity 0.5.7;


library BoundsLibrary {

    struct Bounds {
        uint256 lower;
        uint256 upper;
    }

    function isValid(Bounds memory _bounds) internal pure returns(bool) {

        return _bounds.upper >= _bounds.lower;
    }

    function isWithin(Bounds memory _bounds, uint256 _value) internal pure returns(bool) {

        return _value >= _bounds.lower && _value <= _bounds.upper;
    }

    function isOutside(Bounds memory _bounds, uint256 _value) internal pure returns(bool) {

        return _value < _bounds.lower || _value > _bounds.upper;
    }
}


pragma solidity ^0.5.2;

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



pragma solidity 0.5.7;


library AddressArrayUtils {


    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {

        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (0, false);
    }

    function contains(address[] memory A, address a) internal pure returns (bool) {

        bool isIn;
        (, isIn) = indexOf(A, a);
        return isIn;
    }

    function extend(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        uint256 aLength = A.length;
        uint256 bLength = B.length;
        address[] memory newAddresses = new address[](aLength + bLength);
        for (uint256 i = 0; i < aLength; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = 0; j < bLength; j++) {
            newAddresses[aLength + j] = B[j];
        }
        return newAddresses;
    }

    function append(address[] memory A, address a) internal pure returns (address[] memory) {

        address[] memory newAddresses = new address[](A.length + 1);
        for (uint256 i = 0; i < A.length; i++) {
            newAddresses[i] = A[i];
        }
        newAddresses[A.length] = a;
        return newAddresses;
    }

    function intersect(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 newLength = 0;
        for (uint256 i = 0; i < length; i++) {
            if (contains(B, A[i])) {
                includeMap[i] = true;
                newLength++;
            }
        }
        address[] memory newAddresses = new address[](newLength);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

    function union(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        address[] memory leftDifference = difference(A, B);
        address[] memory rightDifference = difference(B, A);
        address[] memory intersection = intersect(A, B);
        return extend(leftDifference, extend(intersection, rightDifference));
    }

    function difference(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 count = 0;
        for (uint256 i = 0; i < length; i++) {
            address e = A[i];
            if (!contains(B, e)) {
                includeMap[i] = true;
                count++;
            }
        }
        address[] memory newAddresses = new address[](count);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

    function pop(address[] memory A, uint256 index)
        internal
        pure
        returns (address[] memory, address)
    {

        uint256 length = A.length;
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }

    function remove(address[] memory A, address a)
        internal
        pure
        returns (address[] memory)
    {

        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert();
        } else {
            (address[] memory _A,) = pop(A, index);
            return _A;
        }
    }

    function hasDuplicate(address[] memory A) internal pure returns (bool) {

        if (A.length == 0) {
            return false;
        }
        for (uint256 i = 0; i < A.length - 1; i++) {
            for (uint256 j = i + 1; j < A.length; j++) {
                if (A[i] == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

    function isEqual(address[] memory A, address[] memory B) internal pure returns (bool) {

        if (A.length != B.length) {
            return false;
        }
        for (uint256 i = 0; i < A.length; i++) {
            if (A[i] != B[i]) {
                return false;
            }
        }
        return true;
    }
}



pragma solidity 0.5.7;


interface IOracle {


    function read()
        external
        view
        returns (uint256);

}



pragma solidity 0.5.7;


interface ICore {

    function transferProxy()
        external
        view
        returns (address);


    function vault()
        external
        view
        returns (address);


    function exchangeIds(
        uint8 _exchangeId
    )
        external
        view
        returns (address);


    function validSets(address)
        external
        view
        returns (bool);


    function validModules(address)
        external
        view
        returns (bool);


    function validPriceLibraries(
        address _priceLibrary
    )
        external
        view
        returns (bool);


    function issue(
        address _set,
        uint256 _quantity
    )
        external;


    function issueTo(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;


    function issueInVault(
        address _set,
        uint256 _quantity
    )
        external;


    function redeem(
        address _set,
        uint256 _quantity
    )
        external;


    function redeemTo(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;


    function redeemInVault(
        address _set,
        uint256 _quantity
    )
        external;


    function redeemAndWithdrawTo(
        address _set,
        address _to,
        uint256 _quantity,
        uint256 _toExclude
    )
        external;


    function batchDeposit(
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;


    function batchWithdraw(
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;


    function deposit(
        address _token,
        uint256 _quantity
    )
        external;


    function withdraw(
        address _token,
        uint256 _quantity
    )
        external;


    function internalTransfer(
        address _token,
        address _to,
        uint256 _quantity
    )
        external;


    function createSet(
        address _factory,
        address[] calldata _components,
        uint256[] calldata _units,
        uint256 _naturalUnit,
        bytes32 _name,
        bytes32 _symbol,
        bytes calldata _callData
    )
        external
        returns (address);


    function depositModule(
        address _from,
        address _to,
        address _token,
        uint256 _quantity
    )
        external;


    function withdrawModule(
        address _from,
        address _to,
        address _token,
        uint256 _quantity
    )
        external;


    function batchDepositModule(
        address _from,
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;


    function batchWithdrawModule(
        address _from,
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external;


    function issueModule(
        address _owner,
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external;


    function redeemModule(
        address _burnAddress,
        address _incrementAddress,
        address _set,
        uint256 _quantity
    )
        external;


    function batchIncrementTokenOwnerModule(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;


    function batchDecrementTokenOwnerModule(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;


    function batchTransferBalanceModule(
        address[] calldata _tokens,
        address _from,
        address _to,
        uint256[] calldata _quantities
    )
        external;


    function transferModule(
        address _token,
        uint256 _quantity,
        address _from,
        address _to
    )
        external;


    function batchTransferModule(
        address[] calldata _tokens,
        uint256[] calldata _quantities,
        address _from,
        address _to
    )
        external;

}



pragma solidity 0.5.7;

interface ISetToken {



    function naturalUnit()
        external
        view
        returns (uint256);


    function getComponents()
        external
        view
        returns (address[] memory);


    function getUnits()
        external
        view
        returns (uint256[] memory);


    function tokenIsComponent(
        address _tokenAddress
    )
        external
        view
        returns (bool);


    function mint(
        address _issuer,
        uint256 _quantity
    )
        external;


    function burn(
        address _from,
        uint256 _quantity
    )
        external;


    function transfer(
        address to,
        uint256 value
    )
        external;

}



pragma solidity 0.5.7;


library RebalancingLibrary {



    enum State { Default, Proposal, Rebalance, Drawdown }


    struct AuctionPriceParameters {
        uint256 auctionStartTime;
        uint256 auctionTimeToPivot;
        uint256 auctionStartPrice;
        uint256 auctionPivotPrice;
    }

    struct BiddingParameters {
        uint256 minimumBid;
        uint256 remainingCurrentSets;
        uint256[] combinedCurrentUnits;
        uint256[] combinedNextSetUnits;
        address[] combinedTokenArray;
    }
}



pragma solidity 0.5.7;



interface IRebalancingSetToken {


    function auctionLibrary()
        external
        view
        returns (address);


    function totalSupply()
        external
        view
        returns (uint256);


    function proposalStartTime()
        external
        view
        returns (uint256);


    function lastRebalanceTimestamp()
        external
        view
        returns (uint256);


    function rebalanceInterval()
        external
        view
        returns (uint256);


    function rebalanceState()
        external
        view
        returns (RebalancingLibrary.State);


    function startingCurrentSetAmount()
        external
        view
        returns (uint256);


    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);


    function propose(
        address _nextSet,
        address _auctionLibrary,
        uint256 _auctionTimeToPivot,
        uint256 _auctionStartPrice,
        uint256 _auctionPivotPrice
    )
        external;


    function naturalUnit()
        external
        view
        returns (uint256);


    function currentSet()
        external
        view
        returns (address);


    function nextSet()
        external
        view
        returns (address);


    function unitShares()
        external
        view
        returns (uint256);


    function burn(
        address _from,
        uint256 _quantity
    )
        external;


    function placeBid(
        uint256 _quantity
    )
        external
        returns (address[] memory, uint256[] memory, uint256[] memory);


    function getCombinedTokenArrayLength()
        external
        view
        returns (uint256);


    function getCombinedTokenArray()
        external
        view
        returns (address[] memory);


    function getFailedAuctionWithdrawComponents()
        external
        view
        returns (address[] memory);


    function getAuctionPriceParameters()
        external
        view
        returns (uint256[] memory);


    function getBiddingParameters()
        external
        view
        returns (uint256[] memory);


    function getBidPrice(
        uint256 _quantity
    )
        external
        view
        returns (uint256[] memory, uint256[] memory);


}



pragma solidity 0.5.7;



library Rebalance {


    struct TokenFlow {
        address[] addresses;
        uint256[] inflow;
        uint256[] outflow;
    }

    function composeTokenFlow(
        address[] memory _addresses,
        uint256[] memory _inflow,
        uint256[] memory _outflow
    )
        internal
        pure
        returns(TokenFlow memory)
    {

        return TokenFlow({addresses: _addresses, inflow: _inflow, outflow: _outflow });
    }

    function decomposeTokenFlow(TokenFlow memory _tokenFlow)
        internal
        pure
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {

        return (_tokenFlow.addresses, _tokenFlow.inflow, _tokenFlow.outflow);
    }

    function decomposeTokenFlowToBidPrice(TokenFlow memory _tokenFlow)
        internal
        pure
        returns (uint256[] memory, uint256[] memory)
    {

        return (_tokenFlow.inflow, _tokenFlow.outflow);
    }

    function getTokenFlows(
        IRebalancingSetToken _rebalancingSetToken,
        uint256 _quantity
    )
        internal
        view
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {

        address[] memory combinedTokenArray = _rebalancingSetToken.getCombinedTokenArray();

        (
            uint256[] memory inflowArray,
            uint256[] memory outflowArray
        ) = _rebalancingSetToken.getBidPrice(_quantity);

        return (combinedTokenArray, inflowArray, outflowArray);
    }
}



pragma solidity 0.5.7;



library SetMath {

    using SafeMath for uint256;


    function setToComponent(
        uint256 _setQuantity,
        uint256 _componentUnit,
        uint256 _naturalUnit
    )
        internal
        pure
        returns(uint256)
    {

        return _setQuantity.mul(_componentUnit).div(_naturalUnit);
    }

    function componentToSet(
        uint256 _componentQuantity,
        uint256 _componentUnit,
        uint256 _naturalUnit
    )
        internal
        pure
        returns(uint256)
    {

        return _componentQuantity.mul(_naturalUnit).div(_componentUnit);
    }
}



pragma solidity 0.5.7;










contract Auction {

    using SafeMath for uint256;
    using AddressArrayUtils for address[];

    struct Setup {
        uint256 maxNaturalUnit;
        uint256 minimumBid;
        uint256 startTime;
        uint256 startingCurrentSets;
        uint256 remainingCurrentSets;
        address[] combinedTokenArray;
        uint256[] combinedCurrentSetUnits;
        uint256[] combinedNextSetUnits;
    }

    uint256 constant private CURVE_DENOMINATOR = 10 ** 18;


    function initializeAuction(
        Setup storage _auction,
        ISetToken _currentSet,
        ISetToken _nextSet,
        uint256 _startingCurrentSetQuantity
    )
        internal
    {

        _auction.maxNaturalUnit = Math.max(
            _currentSet.naturalUnit(),
            _nextSet.naturalUnit()
        );

        _auction.startingCurrentSets = _startingCurrentSetQuantity;
        _auction.remainingCurrentSets = _startingCurrentSetQuantity;
        _auction.startTime = block.timestamp;
        _auction.combinedTokenArray = getCombinedTokenArray(_currentSet, _nextSet);
        _auction.combinedCurrentSetUnits = calculateCombinedUnitArray(_auction, _currentSet);
        _auction.combinedNextSetUnits = calculateCombinedUnitArray(_auction, _nextSet);
    }

    function reduceRemainingCurrentSets(Setup storage _auction, uint256 _quantity) internal {

        _auction.remainingCurrentSets = _auction.remainingCurrentSets.sub(_quantity);
    }

    function validateBidQuantity(Setup storage _auction, uint256 _quantity) internal view {

        require(
            _quantity.mod(_auction.minimumBid) == 0,
            "Auction.validateBidQuantity: Must bid multiple of minimum bid"
        );

        require(
            _quantity <= _auction.remainingCurrentSets,
            "Auction.validateBidQuantity: Bid exceeds remaining current sets"
        );
    }

    function validateAuctionCompletion(Setup storage _auction) internal view {

        require(
            !hasBiddableQuantity(_auction),
            "Auction.settleRebalance: Rebalance not completed"
        );
    }

    function hasBiddableQuantity(Setup storage _auction) internal view returns(bool) {

        return _auction.remainingCurrentSets >= _auction.minimumBid;
    }

    function isAuctionActive(Setup storage _auction) internal view returns(bool) {

        return _auction.startTime > 0;
    }

    function calculateTokenFlow(
        Setup storage _auction,
        uint256 _quantity,
        uint256 _price
    )
        internal
        view
        returns (Rebalance.TokenFlow memory)
    {

        uint256 unitsMultiplier = _quantity.div(_auction.maxNaturalUnit);

        address[] memory memCombinedTokenArray = _auction.combinedTokenArray;

        uint256 combinedTokenCount = memCombinedTokenArray.length;
        uint256[] memory inflowUnitArray = new uint256[](combinedTokenCount);
        uint256[] memory outflowUnitArray = new uint256[](combinedTokenCount);

        for (uint256 i = 0; i < combinedTokenCount; i++) {
            (
                inflowUnitArray[i],
                outflowUnitArray[i]
            ) = calculateInflowOutflow(
                _auction.combinedCurrentSetUnits[i],
                _auction.combinedNextSetUnits[i],
                unitsMultiplier,
                _price
            );
        }

        return Rebalance.composeTokenFlow(memCombinedTokenArray, inflowUnitArray, outflowUnitArray);
    }

    function getCombinedTokenArray(
        ISetToken _currentSet,
        ISetToken _nextSet
    )
        internal
        view
        returns(address[] memory)
    {

        address[] memory currentSetComponents = _currentSet.getComponents();
        address[] memory nextSetComponents = _nextSet.getComponents();
        return currentSetComponents.union(nextSetComponents);
    }

    function calculateInflowOutflow(
        uint256 _currentUnit,
        uint256 _nextSetUnit,
        uint256 _unitsMultiplier,
        uint256 _price
    )
        internal
        pure
        returns (uint256, uint256)
    {

        uint256 inflowUnit;
        uint256 outflowUnit;

        if (_nextSetUnit.mul(CURVE_DENOMINATOR) > _currentUnit.mul(_price)) {
            inflowUnit = _unitsMultiplier.mul(
                _nextSetUnit.mul(CURVE_DENOMINATOR).sub(_currentUnit.mul(_price))
            ).div(_price);

            outflowUnit = 0;
        } else {
            outflowUnit = _unitsMultiplier.mul(
                _currentUnit.mul(_price).sub(_nextSetUnit.mul(CURVE_DENOMINATOR))
            ).div(_price);

            inflowUnit = 0;
        }

        return (inflowUnit, outflowUnit);
    }


    function calculateCombinedUnitArray(
        Setup storage _auction,
        ISetToken _set
    )
        internal
        view
        returns (uint256[] memory)
    {

        address[] memory combinedTokenArray = _auction.combinedTokenArray;
        uint256[] memory combinedUnits = new uint256[](combinedTokenArray.length);
        for (uint256 i = 0; i < combinedTokenArray.length; i++) {
            combinedUnits[i] = calculateCombinedUnit(
                _set,
                _auction.maxNaturalUnit,
                combinedTokenArray[i]
            );
        }

        return combinedUnits;
    }

    function calculateCombinedUnit(
        ISetToken _setToken,
        uint256 _maxNaturalUnit,
        address _component
    )
        private
        view
        returns (uint256)
    {

        (
            uint256 indexCurrent,
            bool isComponent
        ) = _setToken.getComponents().indexOf(_component);

        if (isComponent) {
            return calculateTransferValue(
                _setToken.getUnits()[indexCurrent],
                _setToken.naturalUnit(),
                _maxNaturalUnit
            );
        }

        return 0;
    }

    function calculateTransferValue(
        uint256 _unit,
        uint256 _naturalUnit,
        uint256 _maxNaturalUnit
    )
        private
        pure
        returns (uint256)
    {

        return SetMath.setToComponent(_maxNaturalUnit, _unit, _naturalUnit);
    }
}



pragma solidity 0.5.7;




interface ILiquidator {



    function startRebalance(
        ISetToken _currentSet,
        ISetToken _nextSet,
        uint256 _startingCurrentSetQuantity,
        bytes calldata _liquidatorData
    )
        external;


    function getBidPrice(
        address _set,
        uint256 _quantity
    )
        external
        view
        returns (Rebalance.TokenFlow memory);


    function placeBid(
        uint256 _quantity
    )
        external
        returns (Rebalance.TokenFlow memory);



    function settleRebalance()
        external;


    function endFailedRebalance() external;



    function auctionPriceParameters(address _set)
        external
        view
        returns (RebalancingLibrary.AuctionPriceParameters memory);



    function hasRebalanceFailed(address _set) external view returns (bool);

    function minimumBid(address _set) external view returns (uint256);

    function startingCurrentSets(address _set) external view returns (uint256);

    function remainingCurrentSets(address _set) external view returns (uint256);

    function getCombinedCurrentSetUnits(address _set) external view returns (uint256[] memory);

    function getCombinedNextSetUnits(address _set) external view returns (uint256[] memory);

    function getCombinedTokenArray(address _set) external view returns (address[] memory);

}



pragma solidity 0.5.7;

interface IOracleWhiteList {



    function oracleWhiteList(
        address _tokenAddress
    )
        external
        view
        returns (address);


    function areValidAddresses(
        address[] calldata _addresses
    )
        external
        view
        returns (bool);


    function getOracleAddressesByToken(
        address[] calldata _tokenAddresses
    )
        external
        view
        returns (address[] memory);


    function getOracleAddressByToken(
        address _token
    )
        external
        view
        returns (address);

}



pragma solidity 0.5.7;






contract LinearAuction is Auction {

    using SafeMath for uint256;

    struct State {
        Auction.Setup auction;
        uint256 endTime;
        uint256 startPrice;
        uint256 endPrice;
    }

    uint256 public auctionPeriod; // Length in seconds of auction

    constructor(
        uint256 _auctionPeriod
    )
        public
    {
        auctionPeriod = _auctionPeriod;
    }


    function initializeLinearAuction(
        State storage _linearAuction,
        ISetToken _currentSet,
        ISetToken _nextSet,
        uint256 _startingCurrentSetQuantity
    )
        internal
    {

        initializeAuction(
            _linearAuction.auction,
            _currentSet,
            _nextSet,
            _startingCurrentSetQuantity
        );

        uint256 minimumBid = calculateMinimumBid(_linearAuction.auction, _currentSet, _nextSet);

        require(
            _startingCurrentSetQuantity.div(minimumBid) >= 100,
            "LinearAuction.initializeAuction: Minimum bid must be less than or equal to 1% of collateral."
        );

        _linearAuction.auction.minimumBid = minimumBid;

        _linearAuction.startPrice = calculateStartPrice(_linearAuction.auction, _currentSet, _nextSet);
        _linearAuction.endPrice = calculateEndPrice(_linearAuction.auction, _currentSet, _nextSet);

        _linearAuction.endTime = block.timestamp.add(auctionPeriod);
    }


    function getTokenFlow(
        State storage _linearAuction,
        uint256 _quantity
    )
        internal
        view
        returns (Rebalance.TokenFlow memory)
    {

        return Auction.calculateTokenFlow(
            _linearAuction.auction,
            _quantity,
            getPrice(_linearAuction)
        );
    }

    function hasAuctionFailed(State storage _linearAuction) internal view returns(bool) {

        bool endTimeExceeded = block.timestamp >= _linearAuction.endTime;
        bool setsNotAuctioned = hasBiddableQuantity(_linearAuction.auction);

        return (endTimeExceeded && setsNotAuctioned);
    }

    function getPrice(State storage _linearAuction) internal view returns (uint256) {

        uint256 elapsed = block.timestamp.sub(_linearAuction.auction.startTime);

        if (elapsed >= auctionPeriod) {
            return _linearAuction.endPrice;
        } else {
            uint256 range = _linearAuction.endPrice.sub(_linearAuction.startPrice);
            uint256 elapsedPrice = elapsed.mul(range).div(auctionPeriod);

            return _linearAuction.startPrice.add(elapsedPrice);
        }
    }

    function calculateMinimumBid(
        Setup storage _auction,
        ISetToken _currentSet,
        ISetToken _nextSet
    )
        internal
        view
        returns (uint256);


    function calculateStartPrice(
        Auction.Setup storage _auction,
        ISetToken _currentSet,
        ISetToken _nextSet
    )
        internal
        view
        returns(uint256);


    function calculateEndPrice(
        Auction.Setup storage _auction,
        ISetToken _currentSet,
        ISetToken _nextSet
    )
        internal
        view
        returns(uint256);

}



pragma solidity 0.5.7;



library CommonMath {

    using SafeMath for uint256;

    uint256 public constant SCALE_FACTOR = 10 ** 18;
    uint256 public constant MAX_UINT_256 = 2 ** 256 - 1;

    function scaleFactor()
        internal
        pure
        returns (uint256)
    {

        return SCALE_FACTOR;
    }

    function maxUInt256()
        internal
        pure
        returns (uint256)
    {

        return MAX_UINT_256;
    }

    function scale(
        uint256 a
    )
        internal
        pure
        returns (uint256)
    {

        return a.mul(SCALE_FACTOR);
    }

    function deScale(
        uint256 a
    )
        internal
        pure
        returns (uint256)
    {

        return a.div(SCALE_FACTOR);
    }

    function safePower(
        uint256 a,
        uint256 pow
    )
        internal
        pure
        returns (uint256)
    {

        require(a > 0);

        uint256 result = 1;
        for (uint256 i = 0; i < pow; i++){
            uint256 previousResult = result;

            result = previousResult.mul(a);
        }

        return result;
    }

    function divCeil(uint256 a, uint256 b)
        internal
        pure
        returns(uint256)
    {

        return a.mod(b) > 0 ? a.div(b).add(1) : a.div(b);
    }

    function getPartialAmount(
        uint256 _principal,
        uint256 _numerator,
        uint256 _denominator
    )
        internal
        pure
        returns (uint256)
    {

        uint256 remainder = mulmod(_principal, _numerator, _denominator);

        if (remainder == 0) {
            return _principal.mul(_numerator).div(_denominator);
        }

        uint256 errPercentageTimes1000000 = remainder.mul(1000000).div(_numerator.mul(_principal));

        require(
            errPercentageTimes1000000 < 1000,
            "CommonMath.getPartialAmount: Rounding error exceeds bounds"
        );

        return _principal.mul(_numerator).div(_denominator);
    }

    function ceilLog10(
        uint256 _value
    )
        internal
        pure
        returns (uint256)
    {

        require (
            _value > 0,
            "CommonMath.ceilLog10: Value must be greater than zero."
        );

        if (_value == 1) return 0;

        uint256 x = _value - 1;

        uint256 result = 0;

        if (x >= 10 ** 64) {
            x /= 10 ** 64;
            result += 64;
        }
        if (x >= 10 ** 32) {
            x /= 10 ** 32;
            result += 32;
        }
        if (x >= 10 ** 16) {
            x /= 10 ** 16;
            result += 16;
        }
        if (x >= 10 ** 8) {
            x /= 10 ** 8;
            result += 8;
        }
        if (x >= 10 ** 4) {
            x /= 10 ** 4;
            result += 4;
        }
        if (x >= 100) {
            x /= 100;
            result += 2;
        }
        if (x >= 10) {
            result += 1;
        }

        return result + 1;
    }
}


pragma solidity ^0.5.2;

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.2;


contract ERC20Detailed is IERC20 {

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
}



pragma solidity 0.5.7;

interface IFeeCalculator {



    function initialize(
        bytes calldata _feeCalculatorData
    )
        external;


    function getFee()
        external
        view
        returns(uint256);


    function updateAndGetFee()
        external
        returns(uint256);


    function adjustFee(
        bytes calldata _newFeeData
    )
        external;

}



pragma solidity 0.5.7;






interface IRebalancingSetTokenV2 {


    function totalSupply()
        external
        view
        returns (uint256);


    function liquidator()
        external
        view
        returns (ILiquidator);


    function lastRebalanceTimestamp()
        external
        view
        returns (uint256);


    function rebalanceStartTime()
        external
        view
        returns (uint256);


    function startingCurrentSetAmount()
        external
        view
        returns (uint256);


    function rebalanceInterval()
        external
        view
        returns (uint256);


    function getAuctionPriceParameters() external view returns (uint256[] memory);


    function getBiddingParameters() external view returns (uint256[] memory);


    function rebalanceState()
        external
        view
        returns (RebalancingLibrary.State);


    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);


    function manager()
        external
        view
        returns (address);


    function feeRecipient()
        external
        view
        returns (address);


    function entryFee()
        external
        view
        returns (uint256);


    function rebalanceFee()
        external
        view
        returns (uint256);


    function rebalanceFeeCalculator()
        external
        view
        returns (IFeeCalculator);


    function initialize(
        bytes calldata _rebalanceFeeCalldata
    )
        external;


    function setLiquidator(
        ILiquidator _newLiquidator
    )
        external;


    function setFeeRecipient(
        address _newFeeRecipient
    )
        external;


    function setEntryFee(
        uint256 _newEntryFee
    )
        external;


    function startRebalance(
        address _nextSet,
        bytes calldata _liquidatorData

    )
        external;


    function settleRebalance()
        external;


    function naturalUnit()
        external
        view
        returns (uint256);


    function currentSet()
        external
        view
        returns (ISetToken);


    function nextSet()
        external
        view
        returns (ISetToken);


    function unitShares()
        external
        view
        returns (uint256);


    function placeBid(
        uint256 _quantity
    )
        external
        returns (address[] memory, uint256[] memory, uint256[] memory);


    function getBidPrice(
        uint256 _quantity
    )
        external
        view
        returns (uint256[] memory, uint256[] memory);


    function name()
        external
        view
        returns (string memory);


    function symbol()
        external
        view
        returns (string memory);

}



pragma solidity 0.5.7;












library SetUSDValuation {

    using SafeMath for uint256;
    using AddressArrayUtils for address[];

    uint256 constant public SET_FULL_UNIT = 10 ** 18;



    function calculateRebalancingSetValue(
        address _rebalancingSetTokenAddress,
        IOracleWhiteList _oracleWhitelist
    )
        internal
        view
        returns (uint256)
    {

        IRebalancingSetTokenV2 rebalancingSetToken = IRebalancingSetTokenV2(_rebalancingSetTokenAddress);

        uint256 unitShares = rebalancingSetToken.unitShares();
        uint256 naturalUnit = rebalancingSetToken.naturalUnit();
        ISetToken currentSet = rebalancingSetToken.currentSet();

        uint256 collateralValue = calculateSetTokenDollarValue(
            currentSet,
            _oracleWhitelist
        );

        return collateralValue.mul(unitShares).div(naturalUnit);
    }

    function calculateSetTokenDollarValue(
        ISetToken _set,
        IOracleWhiteList _oracleWhitelist
    )
        internal
        view
        returns (uint256)
    {

        uint256 setDollarAmount = 0;

        address[] memory components = _set.getComponents();
        uint256[] memory units = _set.getUnits();
        uint256 naturalUnit = _set.naturalUnit();

        for (uint256 i = 0; i < components.length; i++) {
            address currentComponent = components[i];

            address oracle = _oracleWhitelist.getOracleAddressByToken(currentComponent);
            uint256 price = IOracle(oracle).read();
            uint256 decimals = ERC20Detailed(currentComponent).decimals();

            uint256 tokenDollarValue = calculateTokenAllocationAmountUSD(
                price,
                naturalUnit,
                units[i],
                decimals
            );

            setDollarAmount = setDollarAmount.add(tokenDollarValue);
        }

        return setDollarAmount;
    }

    function calculateTokenAllocationAmountUSD(
        uint256 _tokenPrice,
        uint256 _naturalUnit,
        uint256 _unit,
        uint256 _tokenDecimal
    )
        internal
        pure
        returns (uint256)
    {

        uint256 tokenFullUnit = 10 ** _tokenDecimal;

        uint256 componentUnitsInFullToken = SetMath.setToComponent(
            SET_FULL_UNIT,
            _unit,
            _naturalUnit
        );

        uint256 allocationUSDValue = _tokenPrice
            .mul(componentUnitsInFullToken)
            .div(tokenFullUnit);

        require(
            allocationUSDValue > 0,
            "SetUSDValuation.calculateTokenAllocationAmountUSD: Value must be > 0"
        );

        return allocationUSDValue;
    }
}



pragma solidity 0.5.7;










library LiquidatorUtils {

    using SafeMath for uint256;
    using CommonMath for uint256;


    function calculateRebalanceVolume(
        ISetToken _currentSet,
        ISetToken _nextSet,
        IOracleWhiteList _oracleWhiteList,
        uint256 _currentSetQuantity
    )
        internal
        view
        returns (uint256)
    {

        uint256 currentSetValue = SetUSDValuation.calculateSetTokenDollarValue(
            _currentSet,
            _oracleWhiteList
        );

        address allocationAsset = _currentSet.getComponents()[0];
        uint256 currentSetAllocation = calculateAssetAllocation(
            _currentSet,
            _oracleWhiteList,
            allocationAsset
        );

        uint256 nextSetAllocation = calculateAssetAllocation(
            _nextSet,
            _oracleWhiteList,
            allocationAsset
        );

        uint256 allocationChange = currentSetAllocation > nextSetAllocation ?
            currentSetAllocation.sub(nextSetAllocation) :
            nextSetAllocation.sub(currentSetAllocation);

        return currentSetValue.mul(_currentSetQuantity).deScale().mul(allocationChange).deScale();
    }

    function calculateAssetAllocation(
        ISetToken _setToken,
        IOracleWhiteList _oracleWhiteList,
        address _asset
    )
        internal
        view
        returns (uint256)
    {

        address[] memory components = _setToken.getComponents();

        (
            uint256 assetIndex,
            bool isInSet
        ) = AddressArrayUtils.indexOf(components, _asset);

        if (isInSet && components.length > 1) {
            uint256 setNaturalUnit = _setToken.naturalUnit();
            uint256[] memory setUnits = _setToken.getUnits();

            uint256 assetValue;
            uint256 setValue = 0;
            for (uint256 i = 0; i < components.length; i++) {
                address currentComponent = components[i];

                address oracle = _oracleWhiteList.getOracleAddressByToken(currentComponent);
                uint256 price = IOracle(oracle).read();
                uint256 decimals = ERC20Detailed(currentComponent).decimals();

                uint256 componentValue = SetUSDValuation.calculateTokenAllocationAmountUSD(
                    price,
                    setNaturalUnit,
                    setUnits[i],
                    decimals
                );

                setValue = setValue.add(componentValue);
                if (i == assetIndex) {assetValue = componentValue;}
            }

            return assetValue.scale().div(setValue);
        } else {
            return isInSet ? CommonMath.scaleFactor() : 0;
        }
    }
}



pragma solidity 0.5.7;






interface IRebalancingSetTokenV3 {


    function totalSupply()
        external
        view
        returns (uint256);


    function liquidator()
        external
        view
        returns (ILiquidator);


    function lastRebalanceTimestamp()
        external
        view
        returns (uint256);


    function rebalanceStartTime()
        external
        view
        returns (uint256);


    function startingCurrentSetAmount()
        external
        view
        returns (uint256);


    function rebalanceInterval()
        external
        view
        returns (uint256);


    function rebalanceFailPeriod()
        external
        view
        returns (uint256);


    function getAuctionPriceParameters() external view returns (uint256[] memory);


    function getBiddingParameters() external view returns (uint256[] memory);


    function rebalanceState()
        external
        view
        returns (RebalancingLibrary.State);


    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);


    function manager()
        external
        view
        returns (address);


    function feeRecipient()
        external
        view
        returns (address);


    function entryFee()
        external
        view
        returns (uint256);


    function rebalanceFee()
        external
        view
        returns (uint256);


    function rebalanceFeeCalculator()
        external
        view
        returns (IFeeCalculator);


    function initialize(
        bytes calldata _rebalanceFeeCalldata
    )
        external;


    function setLiquidator(
        ILiquidator _newLiquidator
    )
        external;


    function setFeeRecipient(
        address _newFeeRecipient
    )
        external;


    function setEntryFee(
        uint256 _newEntryFee
    )
        external;


    function startRebalance(
        address _nextSet,
        bytes calldata _liquidatorData

    )
        external;


    function settleRebalance()
        external;


    function actualizeFee()
        external;


    function adjustFee(
        bytes calldata _newFeeData
    )
        external;


    function naturalUnit()
        external
        view
        returns (uint256);


    function currentSet()
        external
        view
        returns (ISetToken);


    function nextSet()
        external
        view
        returns (ISetToken);


    function unitShares()
        external
        view
        returns (uint256);


    function placeBid(
        uint256 _quantity
    )
        external
        returns (address[] memory, uint256[] memory, uint256[] memory);


    function getBidPrice(
        uint256 _quantity
    )
        external
        view
        returns (uint256[] memory, uint256[] memory);


    function name()
        external
        view
        returns (string memory);


    function symbol()
        external
        view
        returns (string memory);

}



pragma solidity 0.5.7;











contract TwoAssetPriceBoundedLinearAuction is LinearAuction {

    using SafeMath for uint256;
    using CommonMath for uint256;

    struct AssetInfo {
        uint256 price;
        uint256 fullUnit;
    }

    uint256 constant private CURVE_DENOMINATOR = 10 ** 18;
    uint256 constant private ONE = 1;
    uint256 constant private MIN_SPOT_TOKEN_FLOW_SCALED = 10 ** 21;

    IOracleWhiteList public oracleWhiteList;
    uint256 public rangeStart; // Percentage below FairValue to begin auction at
    uint256 public rangeEnd;  // Percentage above FairValue to end auction at

    constructor(
        IOracleWhiteList _oracleWhiteList,
        uint256 _auctionPeriod,
        uint256 _rangeStart,
        uint256 _rangeEnd
    )
        public
        LinearAuction(_auctionPeriod)
    {
        oracleWhiteList = _oracleWhiteList;
        rangeStart = _rangeStart;
        rangeEnd = _rangeEnd;
    }


    function validateTwoAssetPriceBoundedAuction(
        ISetToken _currentSet,
        ISetToken _nextSet
    )
        internal
        view
    {

        address[] memory combinedTokenArray = Auction.getCombinedTokenArray(_currentSet, _nextSet);
        require(
            combinedTokenArray.length == 2,
            "TwoAssetPriceBoundedLinearAuction: Only two components are allowed."
        );

        require(
            oracleWhiteList.areValidAddresses(combinedTokenArray),
            "TwoAssetPriceBoundedLinearAuction: Passed token does not have matching oracle."
        );
    }

    function calculateMinimumBid(
        Auction.Setup storage _auction,
        ISetToken _currentSet,
        ISetToken _nextSet
    )
        internal
        view
        returns (uint256)
    {

        AssetInfo memory assetOne = getAssetInfo(_auction.combinedTokenArray[0]);
        AssetInfo memory assetTwo = getAssetInfo(_auction.combinedTokenArray[1]);

        uint256 spotPrice = calculateSpotPrice(assetOne.price, assetTwo.price);

        uint256 auctionFairValue = convertAssetPairPriceToAuctionPrice(
            _auction,
            spotPrice,
            assetOne.fullUnit,
            assetTwo.fullUnit
        );

        uint256 minimumBidMultiplier = 0;
        for (uint8 i = 0; i < _auction.combinedTokenArray.length; i++) {
            (
                uint256 tokenInflowScaled,
                uint256 tokenOutflowScaled
            ) = Auction.calculateInflowOutflow(
                _auction.combinedCurrentSetUnits[i],
                _auction.combinedNextSetUnits[i],
                ONE.scale(),
                auctionFairValue
            );

            uint256 tokenFlowScaled = Math.max(tokenInflowScaled, tokenOutflowScaled);

            uint256 currentMinBidMultiplier = MIN_SPOT_TOKEN_FLOW_SCALED.divCeil(tokenFlowScaled);
            minimumBidMultiplier = currentMinBidMultiplier > minimumBidMultiplier ?
                currentMinBidMultiplier :
                minimumBidMultiplier;
        }

        return _auction.maxNaturalUnit.mul(minimumBidMultiplier);
    }

    function calculateStartPrice(
        Auction.Setup storage _auction,
        ISetToken _currentSet,
        ISetToken _nextSet
    )
        internal
        view
        returns(uint256)
    {

        AssetInfo memory assetOne = getAssetInfo(_auction.combinedTokenArray[0]);
        AssetInfo memory assetTwo = getAssetInfo(_auction.combinedTokenArray[1]);

        uint256 spotPrice = calculateSpotPrice(assetOne.price, assetTwo.price);

        bool isTokenFlowIncreasing = isTokenFlowIncreasing(
            _auction,
            spotPrice,
            assetOne.fullUnit,
            assetTwo.fullUnit
        );

        uint256 startPairPrice;
        if (isTokenFlowIncreasing) {
            startPairPrice = spotPrice.mul(CommonMath.scaleFactor().sub(rangeStart)).deScale();
        } else {
            startPairPrice = spotPrice.mul(CommonMath.scaleFactor().add(rangeStart)).deScale();
        }

        return convertAssetPairPriceToAuctionPrice(
            _auction,
            startPairPrice,
            assetOne.fullUnit,
            assetTwo.fullUnit
        );
    }

    function calculateEndPrice(
        Auction.Setup storage _auction,
        ISetToken _currentSet,
        ISetToken _nextSet
    )
        internal
        view
        returns(uint256)
    {

        AssetInfo memory assetOne = getAssetInfo(_auction.combinedTokenArray[0]);
        AssetInfo memory assetTwo = getAssetInfo(_auction.combinedTokenArray[1]);

        uint256 spotPrice = calculateSpotPrice(assetOne.price, assetTwo.price);

        bool isTokenFlowIncreasing = isTokenFlowIncreasing(
            _auction,
            spotPrice,
            assetOne.fullUnit,
            assetTwo.fullUnit
        );

        uint256 endPairPrice;
        if (isTokenFlowIncreasing) {
            endPairPrice = spotPrice.mul(CommonMath.scaleFactor().add(rangeEnd)).deScale();
        } else {
            endPairPrice = spotPrice.mul(CommonMath.scaleFactor().sub(rangeEnd)).deScale();
        }

        return convertAssetPairPriceToAuctionPrice(
            _auction,
            endPairPrice,
            assetOne.fullUnit,
            assetTwo.fullUnit
        );
    }


    function isTokenFlowIncreasing(
        Auction.Setup storage _auction,
        uint256 _spotPrice,
        uint256 _assetOneFullUnit,
        uint256 _assetTwoFullUnit
    )
        private
        view
        returns (bool)
    {

        uint256 auctionFairValue = convertAssetPairPriceToAuctionPrice(
            _auction,
            _spotPrice,
            _assetOneFullUnit,
            _assetTwoFullUnit
        );

        return _auction.combinedNextSetUnits[0].mul(CURVE_DENOMINATOR) >
            _auction.combinedCurrentSetUnits[0].mul(auctionFairValue);
    }

    function convertAssetPairPriceToAuctionPrice(
        Auction.Setup storage _auction,
        uint256 _targetPrice,
        uint256 _assetOneFullUnit,
        uint256 _assetTwoFullUnit
    )
        private
        view
        returns (uint256)
    {

        uint256 calcNumerator = _auction.combinedNextSetUnits[1].mul(CURVE_DENOMINATOR).scale().div(_assetTwoFullUnit).add(
            _targetPrice.mul(_auction.combinedNextSetUnits[0]).mul(CURVE_DENOMINATOR).div(_assetOneFullUnit)
        );

        uint256 calcDenominator = _auction.combinedCurrentSetUnits[1].scale().scale().div(_assetTwoFullUnit).add(
           _targetPrice.mul(_auction.combinedCurrentSetUnits[0]).scale().div(_assetOneFullUnit)
        );

        return calcNumerator.scale().div(calcDenominator);
    }

    function getAssetInfo(address _asset) private view returns(AssetInfo memory) {

        address assetOracle = oracleWhiteList.getOracleAddressByToken(_asset);
        uint256 assetPrice = IOracle(assetOracle).read();

        uint256 decimals = ERC20Detailed(_asset).decimals();

        return AssetInfo({
            price: assetPrice,
            fullUnit: CommonMath.safePower(10, decimals)
        });
    }

    function calculateSpotPrice(uint256 _assetOnePrice, uint256 _assetTwoPrice) private view returns(uint256) {

        return _assetOnePrice.scale().div(_assetTwoPrice);
    }
}



pragma solidity 0.5.7;














contract TWAPAuction is TwoAssetPriceBoundedLinearAuction {

    using SafeMath for uint256;
    using CommonMath for uint256;
    using AddressArrayUtils for address[];
    using BoundsLibrary for BoundsLibrary.Bounds;


    struct TWAPState {
        LinearAuction.State chunkAuction;   // Current chunk auction state
        uint256 orderSize;                  // Beginning amount of currentSets
        uint256 orderRemaining;             // Amount of current Sets not auctioned or being auctioned
        uint256 lastChunkAuctionEnd;        // Time of last chunk auction end
        uint256 chunkAuctionPeriod;         // Time between chunk auctions
        uint256 chunkSize;                  // Amount of current Sets in a full chunk auction
    }

    struct TWAPLiquidatorData {
        uint256 chunkSizeValue;             // Currency value of rebalance volume in each chunk (18 decimal)
        uint256 chunkAuctionPeriod;         // Time between chunk auctions
    }

    struct AssetPairVolumeBounds {
        address assetOne;                   // Address of first asset in pair
        address assetTwo;                   // Address of second asset in pair
        BoundsLibrary.Bounds bounds;        // Chunk size volume bounds for asset pair
    }


    uint256 constant public AUCTION_COMPLETION_BUFFER = 2e16;


    mapping(address => mapping(address => BoundsLibrary.Bounds)) public chunkSizeWhiteList;
    uint256 public expectedChunkAuctionLength;


    constructor(
        IOracleWhiteList _oracleWhiteList,
        uint256 _auctionPeriod,
        uint256 _rangeStart,
        uint256 _rangeEnd,
        AssetPairVolumeBounds[] memory _assetPairVolumeBounds
    )
        public
        TwoAssetPriceBoundedLinearAuction(
            _oracleWhiteList,
            _auctionPeriod,
            _rangeStart,
            _rangeEnd
        )
    {
        require(
            _rangeEnd >= AUCTION_COMPLETION_BUFFER,
            "TWAPAuction.constructor: Passed range end must exceed completion buffer."
        );

        require(
            _rangeEnd <= 1e18 && _rangeStart <= 1e18,
            "TWAPAuction.constructor: Range bounds must be less than 100%."
        );

        for (uint256 i = 0; i < _assetPairVolumeBounds.length; i++) {
            BoundsLibrary.Bounds memory bounds = _assetPairVolumeBounds[i].bounds;

            require(
                bounds.lower <= bounds.upper,
                "TWAPAuction.constructor: Passed asset pair bounds are invalid."
            );

            address assetOne = _assetPairVolumeBounds[i].assetOne;
            address assetTwo = _assetPairVolumeBounds[i].assetTwo;

            require(
                chunkSizeWhiteList[assetOne][assetTwo].upper == 0,
                "TWAPAuction.constructor: Asset pair volume bounds must be unique."
            );

            chunkSizeWhiteList[assetOne][assetTwo] = bounds;
            chunkSizeWhiteList[assetTwo][assetOne] = bounds;
        }

        require(
            _auctionPeriod < -uint256(1) / (_rangeStart + AUCTION_COMPLETION_BUFFER),
            "TWAPAuction.constructor: Auction period too long."
        );

        expectedChunkAuctionLength = _auctionPeriod * (_rangeStart + AUCTION_COMPLETION_BUFFER) /
            (_rangeStart + _rangeEnd);

        require(
            expectedChunkAuctionLength > 0,
            "TWAPAuction.constructor: Expected auction length must exceed 0."
        );
    }


    function initializeTWAPAuction(
        TWAPState storage _twapAuction,
        ISetToken _currentSet,
        ISetToken _nextSet,
        uint256 _startingCurrentSetQuantity,
        uint256 _chunkSizeValue,
        uint256 _chunkAuctionPeriod
    )
        internal
    {

        LinearAuction.initializeLinearAuction(
            _twapAuction.chunkAuction,
            _currentSet,
            _nextSet,
            _startingCurrentSetQuantity
        );

        uint256 rebalanceVolume = LiquidatorUtils.calculateRebalanceVolume(
            _currentSet,
            _nextSet,
            oracleWhiteList,
            _startingCurrentSetQuantity
        );

        uint256 chunkSize = calculateChunkSize(
            _startingCurrentSetQuantity,
            rebalanceVolume,
            _chunkSizeValue
        );

        uint256 minBid = _twapAuction.chunkAuction.auction.minimumBid;
        uint256 normalizedChunkSize = chunkSize.div(minBid).mul(minBid);
        uint256 totalOrderSize = _startingCurrentSetQuantity.div(minBid).mul(minBid);

        _twapAuction.chunkAuction.auction.startingCurrentSets = normalizedChunkSize;
        _twapAuction.chunkAuction.auction.remainingCurrentSets = normalizedChunkSize;

        _twapAuction.orderSize = totalOrderSize;
        _twapAuction.orderRemaining = totalOrderSize.sub(normalizedChunkSize);
        _twapAuction.chunkSize = normalizedChunkSize;
        _twapAuction.lastChunkAuctionEnd = 0;
        _twapAuction.chunkAuctionPeriod = _chunkAuctionPeriod;
    }

    function auctionNextChunk(
        TWAPState storage _twapAuction
    )
        internal
    {

        uint256 totalRemainingSets = _twapAuction.orderRemaining.add(
            _twapAuction.chunkAuction.auction.remainingCurrentSets
        );

        uint256 nextChunkAuctionSize = Math.min(_twapAuction.chunkSize, totalRemainingSets);

        overwriteChunkAuctionState(_twapAuction, nextChunkAuctionSize);
        _twapAuction.orderRemaining = totalRemainingSets.sub(nextChunkAuctionSize);
    }


    function overwriteChunkAuctionState(
        TWAPState storage _twapAuction,
        uint256 _chunkAuctionSize
    )
        internal
    {

        _twapAuction.chunkAuction.auction.startingCurrentSets = _chunkAuctionSize;
        _twapAuction.chunkAuction.auction.remainingCurrentSets = _chunkAuctionSize;
        _twapAuction.chunkAuction.auction.startTime = block.timestamp;
        _twapAuction.chunkAuction.endTime = block.timestamp.add(auctionPeriod);

        _twapAuction.chunkAuction.startPrice = calculateStartPrice(
            _twapAuction.chunkAuction.auction,
            ISetToken(address(0)),
            ISetToken(address(0))
        );
        _twapAuction.chunkAuction.endPrice = calculateEndPrice(
            _twapAuction.chunkAuction.auction,
            ISetToken(address(0)),
            ISetToken(address(0))
        );
    }

    function validateLiquidatorData(
        ISetToken _currentSet,
        ISetToken _nextSet,
        uint256 _startingCurrentSetQuantity,
        uint256 _chunkSizeValue,
        uint256 _chunkAuctionPeriod
    )
        internal
        view
    {

        uint256 rebalanceVolume = LiquidatorUtils.calculateRebalanceVolume(
            _currentSet,
            _nextSet,
            oracleWhiteList,
            _startingCurrentSetQuantity
        );

        BoundsLibrary.Bounds memory volumeBounds = getVolumeBoundsFromCollateral(_currentSet, _nextSet);

        validateTWAPParameters(
            _chunkSizeValue,
            _chunkAuctionPeriod,
            rebalanceVolume,
            volumeBounds
        );
    }

    function validateTWAPParameters(
        uint256 _chunkSizeValue,
        uint256 _chunkAuctionPeriod,
        uint256 _rebalanceVolume,
        BoundsLibrary.Bounds memory _assetPairVolumeBounds
    )
        internal
        view
    {

        require(
            _assetPairVolumeBounds.isWithin(_chunkSizeValue),
            "TWAPAuction.validateTWAPParameters: Passed chunk size must be between bounds."
        );

        uint256 numChunkAuctions = _rebalanceVolume.divCeil(_chunkSizeValue);
        uint256 expectedTWAPAuctionTime = numChunkAuctions.mul(expectedChunkAuctionLength)
            .add(numChunkAuctions.sub(1).mul(_chunkAuctionPeriod));

        uint256 rebalanceFailPeriod = IRebalancingSetTokenV3(msg.sender).rebalanceFailPeriod();

        require(
            expectedTWAPAuctionTime < rebalanceFailPeriod,
            "TWAPAuction.validateTWAPParameters: Expected auction duration exceeds allowed length."
        );
    }

    function validateNextChunkAuction(
        TWAPState storage _twapAuction
    )
        internal
        view
    {

        Auction.validateAuctionCompletion(_twapAuction.chunkAuction.auction);

        require(
            isRebalanceActive(_twapAuction),
            "TWAPState.validateNextChunkAuction: TWAPAuction is finished."
        );

        require(
            _twapAuction.lastChunkAuctionEnd.add(_twapAuction.chunkAuctionPeriod) <= block.timestamp,
            "TWAPState.validateNextChunkAuction: Not enough time elapsed from last chunk auction end."
        );
    }

    function isRebalanceActive(
        TWAPState storage _twapAuction
    )
        internal
        view
        returns (bool)
    {

        uint256 totalRemainingSets = calculateTotalSetsRemaining(_twapAuction);

        return totalRemainingSets >= _twapAuction.chunkAuction.auction.minimumBid;
    }

    function calculateChunkSize(
        uint256 _totalSetAmount,
        uint256 _rebalanceVolume,
        uint256 _chunkSizeValue
    )
        internal
        view
        returns (uint256)
    {

        if (_rebalanceVolume.div(_chunkSizeValue) >= 1) {
            return _totalSetAmount.mul(_chunkSizeValue).div(_rebalanceVolume);
        } else {
            return _totalSetAmount;
        }
    }

    function calculateTotalSetsRemaining(TWAPAuction.TWAPState storage _twapAuction)
        internal
        view
        returns (uint256)
    {

        return _twapAuction.orderRemaining.add(_twapAuction.chunkAuction.auction.remainingCurrentSets);
    }

    function getVolumeBoundsFromCollateral(
        ISetToken _currentSet,
        ISetToken _nextSet
    )
        internal
        view
        returns (BoundsLibrary.Bounds memory)
    {

        address[] memory currentSetComponents = _currentSet.getComponents();
        address[] memory nextSetComponents = _nextSet.getComponents();

        address firstComponent = currentSetComponents [0];
        address secondComponent = currentSetComponents.length > 1 ? currentSetComponents [1] :
            nextSetComponents [0] != firstComponent ? nextSetComponents [0] : nextSetComponents [1];

        return chunkSizeWhiteList[firstComponent][secondComponent];
    }

    function parseLiquidatorData(
        bytes memory _liquidatorData
    )
        internal
        pure
        returns (uint256, uint256)
    {

        return abi.decode(_liquidatorData, (uint256, uint256));
    }
}



pragma solidity 0.5.7;



contract AuctionGetters {


    function minimumBid(address _set) external view returns (uint256) {

        return auction(_set).minimumBid;
    }

    function remainingCurrentSets(address _set) external view returns (uint256) {

        return auction(_set).remainingCurrentSets;
    }

    function startingCurrentSets(address _set) external view returns (uint256) {

        return auction(_set).startingCurrentSets;
    }

    function getCombinedTokenArray(address _set) external view returns (address[] memory) {

        return auction(_set).combinedTokenArray;
    }

    function getCombinedCurrentSetUnits(address _set) external view returns (uint256[] memory) {

        return auction(_set).combinedCurrentSetUnits;
    }

    function getCombinedNextSetUnits(address _set) external view returns (uint256[] memory) {

        return auction(_set).combinedNextSetUnits;
    }

    function auction(address _set) internal view returns(Auction.Setup storage);

}



pragma solidity 0.5.7;





contract TWAPAuctionGetters is AuctionGetters {

    using SafeMath for uint256;

    function getOrderSize(address _set) external view returns (uint256) {

        return twapAuction(_set).orderSize;
    }

    function getOrderRemaining(address _set) external view returns (uint256) {

        return twapAuction(_set).orderRemaining;
    }

    function getChunkSize(address _set) external view returns (uint256) {

        return twapAuction(_set).chunkSize;
    }

    function getChunkAuctionPeriod(address _set) external view returns (uint256) {

        return twapAuction(_set).chunkAuctionPeriod;
    }

    function getLastChunkAuctionEnd(address _set) external view returns (uint256) {

        return twapAuction(_set).lastChunkAuctionEnd;
    }

    function twapAuction(address _set) internal view returns(TWAPAuction.TWAPState storage);

}



pragma solidity 0.5.7;
















contract TWAPLiquidator is
    ILiquidator,
    TWAPAuction,
    TWAPAuctionGetters,
    Ownable
{

    using SafeMath for uint256;

    event ChunkAuctionIterated(
        address indexed rebalancingSetToken,
        uint256 orderRemaining,
        uint256 startingCurrentSets
    );

    event ChunkSizeBoundUpdated(
        address assetOne,
        address assetTwo,
        uint256 lowerBound,
        uint256 upperBound
    );

    ICore public core;
    string public name;
    mapping(address => TWAPAuction.TWAPState) public auctions;

    modifier onlyValidSet() {

        require(
            core.validSets(msg.sender),
            "TWAPLiquidator: Invalid or disabled proposed SetToken address"
        );
        _;
    }

    constructor(
        ICore _core,
        IOracleWhiteList _oracleWhiteList,
        uint256 _auctionPeriod,
        uint256 _rangeStart,
        uint256 _rangeEnd,
        TWAPAuction.AssetPairVolumeBounds[] memory _assetPairVolumeBounds,
        string memory _name
    )
        public
        TWAPAuction(
            _oracleWhiteList,
            _auctionPeriod,
            _rangeStart,
            _rangeEnd,
            _assetPairVolumeBounds
        )
    {
        core = _core;
        name = _name;
    }


    function startRebalance(
        ISetToken _currentSet,
        ISetToken _nextSet,
        uint256 _startingCurrentSetQuantity,
        bytes calldata _liquidatorData
    )
        external
        onlyValidSet
    {

        TwoAssetPriceBoundedLinearAuction.validateTwoAssetPriceBoundedAuction(
            _currentSet,
            _nextSet
        );

        (
            uint256 chunkAuctionValue,
            uint256 chunkAuctionPeriod
        ) = TWAPAuction.parseLiquidatorData(_liquidatorData);

        TWAPAuction.validateLiquidatorData(
            _currentSet,
            _nextSet,
            _startingCurrentSetQuantity,
            chunkAuctionValue,
            chunkAuctionPeriod
        );

        TWAPAuction.initializeTWAPAuction(
            auctions[msg.sender],
            _currentSet,
            _nextSet,
            _startingCurrentSetQuantity,
            chunkAuctionValue,
            chunkAuctionPeriod
        );
    }

    function placeBid(
        uint256 _quantity
    )
        external
        onlyValidSet
        returns (Rebalance.TokenFlow memory)
    {

        Auction.validateBidQuantity(auction(msg.sender), _quantity);

        Auction.reduceRemainingCurrentSets(auction(msg.sender), _quantity);

        if (!hasBiddableQuantity(auction(msg.sender))) {
            twapAuction(msg.sender).lastChunkAuctionEnd = block.timestamp;
        }

        return getBidPrice(msg.sender, _quantity);
    }

    function iterateChunkAuction(address _set) external {

        TWAPAuction.TWAPState storage twapAuction = twapAuction(_set);
        validateNextChunkAuction(twapAuction);

        auctionNextChunk(twapAuction);

        emit ChunkAuctionIterated(
            _set,
            twapAuction.orderRemaining,
            twapAuction.chunkAuction.auction.startingCurrentSets
        );
    }

    function settleRebalance() external onlyValidSet {

        require(
            !(TWAPAuction.isRebalanceActive(twapAuction(msg.sender))),
            "TWAPLiquidator: Rebalance must be complete"
        );

        clearAuctionState(msg.sender);
    }

    function endFailedRebalance() external onlyValidSet {

        clearAuctionState(msg.sender);
    }

    function getBidPrice(
        address _set,
        uint256 _quantity
    )
        public
        view
        returns (Rebalance.TokenFlow memory)
    {

        return LinearAuction.getTokenFlow(chunkAuction(_set), _quantity);
    }

    function setChunkSizeBounds(
        address _assetOne,
        address _assetTwo,
        BoundsLibrary.Bounds memory _assetPairVolumeBounds
    )
        public
        onlyOwner
    {

        require(
            BoundsLibrary.isValid(_assetPairVolumeBounds),
            "TWAPLiquidator: Bounds invalid"
        );

        chunkSizeWhiteList[_assetOne][_assetTwo] = _assetPairVolumeBounds;
        chunkSizeWhiteList[_assetTwo][_assetOne] = _assetPairVolumeBounds;

        emit ChunkSizeBoundUpdated(
            _assetOne,
            _assetTwo,
            _assetPairVolumeBounds.lower,
            _assetPairVolumeBounds.upper
        );
    }


    function hasRebalanceFailed(address _set) external view returns (bool) {

        return LinearAuction.hasAuctionFailed(chunkAuction(_set));
    }

    function auctionPriceParameters(address _set)
        external
        view
        returns (RebalancingLibrary.AuctionPriceParameters memory)
    {

        return RebalancingLibrary.AuctionPriceParameters({
            auctionStartTime: auction(_set).startTime,
            auctionTimeToPivot: auctionPeriod,
            auctionStartPrice: chunkAuction(_set).startPrice,
            auctionPivotPrice: chunkAuction(_set).endPrice
        });
    }

    function getTotalSetsRemaining(address _set) external view returns (uint256) {

        return TWAPAuction.calculateTotalSetsRemaining(twapAuction(_set));
    }

    function getLiquidatorData(
        uint256 _chunkSize,
        uint256 _chunkAuctionPeriod
    )
        external
        view
        returns(bytes memory)
    {

        return abi.encode(_chunkSize, _chunkAuctionPeriod);
    }


    function clearAuctionState(address _set) internal {

        delete auctions[_set];
    }

    function twapAuction(address _set) internal view returns(TWAPAuction.TWAPState storage) {

        return auctions[_set];
    }

    function chunkAuction(address _set) internal view returns(LinearAuction.State storage) {

        return twapAuction(_set).chunkAuction;
    }

    function auction(address _set) internal view returns(Auction.Setup storage) {

        return chunkAuction(_set).auction;
    }
}