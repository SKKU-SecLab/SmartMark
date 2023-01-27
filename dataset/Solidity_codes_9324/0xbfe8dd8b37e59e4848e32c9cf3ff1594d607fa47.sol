

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


pragma solidity ^0.5.2;

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



pragma solidity 0.5.7;




contract TimeLockUpgrade is
    Ownable
{

    using SafeMath for uint256;


    uint256 public timeLockPeriod;

    mapping(bytes32 => uint256) public timeLockedUpgrades;


    event UpgradeRegistered(
        bytes32 _upgradeHash,
        uint256 _timestamp
    );


    modifier timeLockUpgrade() {

        if (timeLockPeriod == 0) {
            _;

            return;
        }

        bytes32 upgradeHash = keccak256(
            abi.encodePacked(
                msg.data
            )
        );

        uint256 registrationTime = timeLockedUpgrades[upgradeHash];

        if (registrationTime == 0) {
            timeLockedUpgrades[upgradeHash] = block.timestamp;

            emit UpgradeRegistered(
                upgradeHash,
                block.timestamp
            );

            return;
        }

        require(
            block.timestamp >= registrationTime.add(timeLockPeriod),
            "TimeLockUpgrade: Time lock period must have elapsed."
        );

        timeLockedUpgrades[upgradeHash] = 0;

        _;
    }


    function setTimeLockPeriod(
        uint256 _timeLockPeriod
    )
        external
        onlyOwner
    {

        require(
            _timeLockPeriod > timeLockPeriod,
            "TimeLockUpgrade: New period must be greater than existing"
        );

        timeLockPeriod = _timeLockPeriod;
    }
}



pragma solidity 0.5.7;





contract UnrestrictedTimeLockUpgrade is
    TimeLockUpgrade
{


    event RemoveRegisteredUpgrade(
        bytes32 indexed _upgradeHash
    );


    function removeRegisteredUpgradeInternal(
        bytes32 _upgradeHash
    )
        internal
    {

        require(
            timeLockedUpgrades[_upgradeHash] != 0,
            "TimeLockUpgradeV2.removeRegisteredUpgrade: Upgrade hash must be registered"
        );

        timeLockedUpgrades[_upgradeHash] = 0;

        emit RemoveRegisteredUpgrade(
            _upgradeHash
        );
    }
}



pragma solidity 0.5.7;




contract LimitOneUpgrade is
    UnrestrictedTimeLockUpgrade
{


    mapping(address => bytes32) public upgradeIdentifier;


    modifier limitOneUpgrade(address _upgradeAddress) {

        if (timeLockPeriod > 0) {
            bytes32 upgradeHash = keccak256(msg.data);

            if (upgradeIdentifier[_upgradeAddress] != 0) {
                require(
                    upgradeIdentifier[_upgradeAddress] == upgradeHash,
                    "Another update already in progress."
                );

                upgradeIdentifier[_upgradeAddress] = 0;

            } else {
                upgradeIdentifier[_upgradeAddress] = upgradeHash;
            }
        }
        _;
    }

    function removeRegisteredUpgradeInternal(
        address _upgradeAddress,
        bytes32 _upgradeHash
    )
        internal
    {

        require(
            upgradeIdentifier[_upgradeAddress] == _upgradeHash,
            "Passed upgrade hash does not match upgrade address."
        );

        UnrestrictedTimeLockUpgrade.removeRegisteredUpgradeInternal(_upgradeHash);

        upgradeIdentifier[_upgradeAddress] = 0;
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





contract WhiteList is
    Ownable,
    TimeLockUpgrade
{

    using AddressArrayUtils for address[];


    address[] public addresses;
    mapping(address => bool) public whiteList;


    event AddressAdded(
        address _address
    );

    event AddressRemoved(
        address _address
    );


    constructor(
        address[] memory _initialAddresses
    )
        public
    {
        for (uint256 i = 0; i < _initialAddresses.length; i++) {
            address addressToAdd = _initialAddresses[i];

            addresses.push(addressToAdd);
            whiteList[addressToAdd] = true;
        }
    }


    function addAddress(
        address _address
    )
        external
        onlyOwner
        timeLockUpgrade
    {

        require(
            !whiteList[_address],
            "WhiteList.addAddress: Address has already been whitelisted."
        );

        addresses.push(_address);

        whiteList[_address] = true;

        emit AddressAdded(
            _address
        );
    }

    function removeAddress(
        address _address
    )
        external
        onlyOwner
    {

        require(
            whiteList[_address],
            "WhiteList.removeAddress: Address is not current whitelisted."
        );

        addresses = addresses.remove(_address);

        whiteList[_address] = false;

        emit AddressRemoved(
            _address
        );
    }

    function validAddresses()
        external
        view
        returns (address[] memory)
    {

        return addresses;
    }

    function areValidAddresses(
        address[] calldata _addresses
    )
        external
        view
        returns (bool)
    {

        for (uint256 i = 0; i < _addresses.length; i++) {
            if (!whiteList[_addresses[i]]) {
                return false;
            }
        }

        return true;
    }
}



pragma solidity 0.5.7;


interface ISocialAllocator {


    function determineNewAllocation(
        uint256 _targetBaseAssetAllocation
    )
        external
        returns (ISetToken);


    function calculateCollateralSetValue(
        ISetToken _collateralSet
    )
        external
        view
        returns(uint256);

}



pragma solidity 0.5.7;



library SocialTradingLibrary {


    struct PoolInfo {
        address trader;                 // Address allowed to make admin and allocation decisions
        ISocialAllocator allocator;     // Allocator used to make collateral Sets, defines asset pair being used
        uint256 currentAllocation;      // Current base asset allocation of tradingPool
        uint256 newEntryFee;            // New fee percentage to change to after time lock passes, defaults to 0
        uint256 feeUpdateTimestamp;     // Timestamp when fee update process can be finalized, defaults to maxUint256
    }
}



pragma solidity 0.5.7;











contract SocialTradingManager is
    WhiteList
{

    using SafeMath for uint256;


    event TradingPoolCreated(
        address indexed trader,
        ISocialAllocator indexed allocator,
        address indexed tradingPool,
        uint256 startingAllocation
    );

    event AllocationUpdate(
        address indexed tradingPool,
        uint256 oldAllocation,
        uint256 newAllocation
    );

    event NewTrader(
        address indexed tradingPool,
        address indexed oldTrader,
        address indexed newTrader
    );


    modifier onlyTrader(IRebalancingSetTokenV2 _tradingPool) {

        require(
            msg.sender == trader(_tradingPool),
            "Sender must be trader"
        );
        _;
    }


    uint256 public constant REBALANCING_SET_NATURAL_UNIT = 1e8;
    uint public constant ONE_PERCENT = 1e16;
    uint256 constant public MAXIMUM_ALLOCATION = 1e18;


    ICore public core;
    address public factory;
    mapping(address => SocialTradingLibrary.PoolInfo) public pools;

    uint256 public maxEntryFee;
    uint256 public feeUpdateTimelock;

    constructor(
        ICore _core,
        address _factory,
        address[] memory _whiteListedAllocators,
        uint256 _maxEntryFee,
        uint256 _feeUpdateTimelock
    )
        public
        WhiteList(_whiteListedAllocators)
    {
        core = _core;
        factory = _factory;

        maxEntryFee = _maxEntryFee;
        feeUpdateTimelock = _feeUpdateTimelock;
    }


    function createTradingPool(
        ISocialAllocator _tradingPairAllocator,
        uint256 _startingBaseAssetAllocation,
        uint256 _startingUSDValue,
        bytes32 _name,
        bytes32 _symbol,
        bytes calldata _rebalancingSetCallData
    )
        external
    {

        validateCreateTradingPool(_tradingPairAllocator, _startingBaseAssetAllocation, _rebalancingSetCallData);

        ISetToken collateralSet = _tradingPairAllocator.determineNewAllocation(
            _startingBaseAssetAllocation
        );

        uint256[] memory unitShares = new uint256[](1);

        uint256 collateralValue = _tradingPairAllocator.calculateCollateralSetValue(
            collateralSet
        );

        unitShares[0] = _startingUSDValue.mul(REBALANCING_SET_NATURAL_UNIT).div(collateralValue);

        address[] memory components = new address[](1);
        components[0] = address(collateralSet);

        address tradingPool = core.createSet(
            factory,
            components,
            unitShares,
            REBALANCING_SET_NATURAL_UNIT,
            _name,
            _symbol,
            _rebalancingSetCallData
        );

        pools[tradingPool].trader = msg.sender;
        pools[tradingPool].allocator = _tradingPairAllocator;
        pools[tradingPool].currentAllocation = _startingBaseAssetAllocation;
        pools[tradingPool].feeUpdateTimestamp = 0;

        emit TradingPoolCreated(
            msg.sender,
            _tradingPairAllocator,
            tradingPool,
            _startingBaseAssetAllocation
        );
    }

    function updateAllocation(
        IRebalancingSetTokenV2 _tradingPool,
        uint256 _newAllocation,
        bytes calldata _liquidatorData
    )
        external
        onlyTrader(_tradingPool)
    {

        validateAllocationUpdate(_tradingPool, _newAllocation);

        ISetToken nextSet = allocator(_tradingPool).determineNewAllocation(
            _newAllocation
        );

        _tradingPool.startRebalance(address(nextSet), _liquidatorData);

        emit AllocationUpdate(
            address(_tradingPool),
            currentAllocation(_tradingPool),
            _newAllocation
        );

        pools[address(_tradingPool)].currentAllocation = _newAllocation;
    }

    function initiateEntryFeeChange(
        IRebalancingSetTokenV2 _tradingPool,
        uint256 _newEntryFee
    )
        external
        onlyTrader(_tradingPool)
    {

        validateNewEntryFee(_newEntryFee);

        pools[address(_tradingPool)].feeUpdateTimestamp = block.timestamp.add(feeUpdateTimelock);
        pools[address(_tradingPool)].newEntryFee = _newEntryFee;
    }

    function finalizeEntryFeeChange(
        IRebalancingSetTokenV2 _tradingPool
    )
        external
        onlyTrader(_tradingPool)
    {

        require(
            feeUpdateTimestamp(_tradingPool) != 0,
            "SocialTradingManager.finalizeSetFeeRecipient: Must initiate fee change first."
        );

        require(
            block.timestamp >= feeUpdateTimestamp(_tradingPool),
            "SocialTradingManager.finalizeSetFeeRecipient: Time lock period must elapse to update fees."
        );

        pools[address(_tradingPool)].feeUpdateTimestamp = 0;

        _tradingPool.setEntryFee(newEntryFee(_tradingPool));

        pools[address(_tradingPool)].newEntryFee = 0;
    }

    function setTrader(
        IRebalancingSetTokenV2 _tradingPool,
        address _newTrader
    )
        external
        onlyTrader(_tradingPool)
    {

        emit NewTrader(
            address(_tradingPool),
            trader(_tradingPool),
            _newTrader
        );

        pools[address(_tradingPool)].trader = _newTrader;
    }

    function setLiquidator(
        IRebalancingSetTokenV2 _tradingPool,
        ILiquidator _newLiquidator
    )
        external
        onlyTrader(_tradingPool)
    {

        _tradingPool.setLiquidator(_newLiquidator);
    }

    function setFeeRecipient(
        IRebalancingSetTokenV2 _tradingPool,
        address _newFeeRecipient
    )
        external
        onlyTrader(_tradingPool)
    {

        _tradingPool.setFeeRecipient(_newFeeRecipient);
    }


    function validateCreateTradingPool(
        ISocialAllocator _tradingPairAllocator,
        uint256 _startingBaseAssetAllocation,
        bytes memory _rebalancingSetCallData
    )
        internal
        view
    {

        validateAllocationAmount(_startingBaseAssetAllocation);

        validateManagerAddress(_rebalancingSetCallData);

        require(
            whiteList[address(_tradingPairAllocator)],
            "SocialTradingManager.validateCreateTradingPool: Passed allocator is not valid."
        );
    }

    function validateAllocationUpdate(
        IRebalancingSetTokenV2 _tradingPool,
        uint256 _newAllocation
    )
        internal
        view
    {

        validateAllocationAmount(_newAllocation);

        uint256 currentAllocationValue = currentAllocation(_tradingPool);
        require(
            !(currentAllocationValue == MAXIMUM_ALLOCATION && _newAllocation == MAXIMUM_ALLOCATION) &&
            !(currentAllocationValue == 0 && _newAllocation == 0),
            "SocialTradingManager.validateAllocationUpdate: Invalid allocation"
        );

        uint256 lastRebalanceTimestamp = _tradingPool.lastRebalanceTimestamp();
        uint256 rebalanceInterval = _tradingPool.rebalanceInterval();
        require(
            block.timestamp >= lastRebalanceTimestamp.add(rebalanceInterval),
            "SocialTradingManager.validateAllocationUpdate: Rebalance interval not elapsed"
        );

        require(
            _tradingPool.rebalanceState() == RebalancingLibrary.State.Default,
            "SocialTradingManager.validateAllocationUpdate: State must be in Default"
        );
    }

    function validateAllocationAmount(
        uint256 _allocation
    )
        internal
        view
    {

        require(
            _allocation <= MAXIMUM_ALLOCATION,
            "Passed allocation must not exceed 100%."
        );

        require(
            _allocation.mod(ONE_PERCENT) == 0,
            "Passed allocation must be multiple of 1%."
        );
    }

    function validateNewEntryFee(
        uint256 _entryFee
    )
        internal
        view
    {

        require(
            _entryFee <= maxEntryFee,
            "SocialTradingManager.validateNewEntryFee: Passed entry fee must not exceed maxEntryFee."
        );
    }

    function validateManagerAddress(
        bytes memory _rebalancingSetCallData
    )
        internal
        view
    {

        address manager;

        assembly {
            manager := mload(add(_rebalancingSetCallData, 32))   // manager slot
        }

        require(
            manager == address(this),
            "SocialTradingManager.validateCallDataArgs: Passed manager address is not this address."
        );
    }

    function allocator(IRebalancingSetTokenV2 _tradingPool) internal view returns (ISocialAllocator) {

        return pools[address(_tradingPool)].allocator;
    }

    function trader(IRebalancingSetTokenV2 _tradingPool) internal view returns (address) {

        return pools[address(_tradingPool)].trader;
    }

    function currentAllocation(IRebalancingSetTokenV2 _tradingPool) internal view returns (uint256) {

        return pools[address(_tradingPool)].currentAllocation;
    }

    function feeUpdateTimestamp(IRebalancingSetTokenV2 _tradingPool) internal view returns (uint256) {

        return pools[address(_tradingPool)].feeUpdateTimestamp;
    }

    function newEntryFee(IRebalancingSetTokenV2 _tradingPool) internal view returns (uint256) {

        return pools[address(_tradingPool)].newEntryFee;
    }
}



pragma solidity 0.5.7;
pragma experimental "ABIEncoderV2";







contract SocialTradingManagerV2 is
    SocialTradingManager,
    LimitOneUpgrade
{

    constructor(
        ICore _core,
        address _factory,
        address[] memory _whiteListedAllocators,
        uint256 _maxEntryFee,
        uint256 _feeUpdateTimelock
    )
        public
        SocialTradingManager(
            _core,
            _factory,
            _whiteListedAllocators,
            _maxEntryFee,
            _feeUpdateTimelock
        )
    {}


    function adjustFee(
        address _tradingPool,
        bytes calldata _newFeeCallData
    )
        external
        onlyTrader(IRebalancingSetTokenV2(_tradingPool))
        limitOneUpgrade(_tradingPool)
        timeLockUpgrade
    {

        IRebalancingSetTokenV3(_tradingPool).adjustFee(_newFeeCallData);
    }

    function removeRegisteredUpgrade(
        address _tradingPool,
        bytes32 _upgradeHash
    )
        external
        onlyTrader(IRebalancingSetTokenV2(_tradingPool))
    {

        LimitOneUpgrade.removeRegisteredUpgradeInternal(_tradingPool, _upgradeHash);
    }
}