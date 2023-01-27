



pragma solidity ^0.5.16;

contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {

        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


interface IAddressResolver {

    function getAddress(bytes32 name) external view returns (address);


    function getPynth(bytes32 key) external view returns (address);


    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address);

}


interface IPynth {

    function currencyKey() external view returns (bytes32);


    function transferablePynths(address account) external view returns (uint);


    function transferAndSettle(address to, uint value) external returns (bool);


    function transferFromAndSettle(
        address from,
        address to,
        uint value
    ) external returns (bool);


    function burn(address account, uint amount) external;


    function issue(address account, uint amount) external;

}


interface IIssuer {

    function anyPynthOrPERIRateIsInvalid() external view returns (bool anyRateInvalid);


    function availableCurrencyKeys() external view returns (bytes32[] memory);


    function availablePynthCount() external view returns (uint);


    function availablePynths(uint index) external view returns (IPynth);


    function canBurnPynths(address account) external view returns (bool);


    function collateral(address account) external view returns (uint);


    function collateralisationRatio(address issuer) external view returns (uint);


    function collateralisationRatioAndAnyRatesInvalid(address _issuer)
        external
        view
        returns (uint cratio, bool anyRateIsInvalid);


    function debtBalanceOf(address issuer, bytes32 currencyKey) external view returns (uint debtBalance);


    function issuanceRatio() external view returns (uint);


    function lastIssueEvent(address account) external view returns (uint);


    function maxIssuablePynths(address issuer) external view returns (uint maxIssuable);


    function minimumStakeTime() external view returns (uint);


    function remainingIssuablePynths(address issuer)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        );


    function pynths(bytes32 currencyKey) external view returns (IPynth);


    function getPynths(bytes32[] calldata currencyKeys) external view returns (IPynth[] memory);


    function pynthsByAddress(address pynthAddress) external view returns (bytes32);


    function totalIssuedPynths(bytes32 currencyKey, bool excludeEtherCollateral) external view returns (uint);


    function transferablePeriFinanceAndAnyRateIsInvalid(address account, uint balance)
        external
        view
        returns (uint transferable, bool anyRateIsInvalid);


    function issuePynths(address from, uint amount) external;


    function issuePynthsOnBehalf(
        address issueFor,
        address from,
        uint amount
    ) external;


    function issueMaxPynths(address from) external;


    function issueMaxPynthsOnBehalf(address issueFor, address from) external;


    function stakeUSDCAndIssuePynths(
        address from,
        uint usdcStakeAmount,
        uint issueAmount
    ) external;


    function stakeUSDCAndIssueMaxPynths(address from, uint usdcStakeAmount) external;


    function burnPynths(address from, uint amount) external;


    function burnPynthsOnBehalf(
        address burnForAddress,
        address from,
        uint amount
    ) external;


    function burnPynthsToTarget(address from) external;


    function burnPynthsToTargetOnBehalf(address burnForAddress, address from) external;


    function unstakeUSDCAndBurnPynths(
        address from,
        uint usdcUnstakeAmount,
        uint burnAmount
    ) external;


    function unstakeUSDCToMaxAndBurnPynths(address from, uint burnAmount) external;


    function liquidateDelinquentAccount(
        address account,
        uint pusdAmount,
        address liquidator
    ) external returns (uint totalRedeemed, uint amountToLiquidate);

}






contract AddressResolver is Owned, IAddressResolver {

    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}


    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {

        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            bytes32 name = names[i];
            address destination = destinations[i];
            repository[name] = destination;
            emit AddressImported(name, destination);
        }
    }


    function rebuildCaches(MixinResolver[] calldata destinations) external {

        for (uint i = 0; i < destinations.length; i++) {
            destinations[i].rebuildCache();
        }
    }


    function areAddressesImported(bytes32[] calldata names, address[] calldata destinations) external view returns (bool) {

        for (uint i = 0; i < names.length; i++) {
            if (repository[names[i]] != destinations[i]) {
                return false;
            }
        }
        return true;
    }

    function getAddress(bytes32 name) external view returns (address) {

        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address) {

        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    function getPynth(bytes32 key) external view returns (address) {

        IIssuer issuer = IIssuer(repository["Issuer"]);
        require(address(issuer) != address(0), "Cannot find Issuer address");
        return address(issuer.pynths(key));
    }


    event AddressImported(bytes32 name, address destination);
}



contract ReadProxy is Owned {

    address public target;

    constructor(address _owner) public Owned(_owner) {}

    function setTarget(address _target) external onlyOwner {

        target = _target;
        emit TargetUpdated(target);
    }

    function() external {
        assembly {
            calldatacopy(0, 0, calldatasize)

            let result := staticcall(gas, sload(target_slot), 0, calldatasize, 0, 0)
            returndatacopy(0, 0, returndatasize)

            if iszero(result) {
                revert(0, returndatasize)
            }
            return(0, returndatasize)
        }
    }

    event TargetUpdated(address newTarget);
}






contract MixinResolver {

    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    constructor(address _resolver) internal {
        resolver = AddressResolver(_resolver);
    }


    function combineArrays(bytes32[] memory first, bytes32[] memory second)
        internal
        pure
        returns (bytes32[] memory combination)
    {

        combination = new bytes32[](first.length + second.length);

        for (uint i = 0; i < first.length; i++) {
            combination[i] = first[i];
        }

        for (uint j = 0; j < second.length; j++) {
            combination[first.length + j] = second[j];
        }
    }


    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {}


    function rebuildCache() public {

        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            address destination =
                resolver.requireAndGetAddress(name, string(abi.encodePacked("Resolver missing target: ", name)));
            addressCache[name] = destination;
            emit CacheUpdated(name, destination);
        }
    }


    function isResolverCached() external view returns (bool) {

        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            if (resolver.getAddress(name) != addressCache[name] || addressCache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }


    function requireAndGetAddress(bytes32 name) internal view returns (address) {

        address _foundAddress = addressCache[name];
        require(_foundAddress != address(0), string(abi.encodePacked("Missing address: ", name)));
        return _foundAddress;
    }


    event CacheUpdated(bytes32 name, address destination);
}


contract LimitedSetup {

    uint public setupExpiryTime;

    constructor(uint setupDuration) internal {
        setupExpiryTime = now + setupDuration;
    }

    modifier onlyDuringSetup {

        require(now < setupExpiryTime, "Can only perform this action during setup");
        _;
    }
}


pragma experimental ABIEncoderV2;

library VestingEntries {

    struct VestingEntry {
        uint64 endTime;
        uint256 escrowAmount;
    }
    struct VestingEntryWithID {
        uint64 endTime;
        uint256 escrowAmount;
        uint256 entryID;
    }
}

interface IRewardEscrowV2 {

    function balanceOf(address account) external view returns (uint);


    function numVestingEntries(address account) external view returns (uint);


    function totalEscrowedAccountBalance(address account) external view returns (uint);


    function totalVestedAccountBalance(address account) external view returns (uint);


    function getVestingQuantity(address account, uint256[] calldata entryIDs) external view returns (uint);


    function getVestingSchedules(
        address account,
        uint256 index,
        uint256 pageSize
    ) external view returns (VestingEntries.VestingEntryWithID[] memory);


    function getAccountVestingEntryIDs(
        address account,
        uint256 index,
        uint256 pageSize
    ) external view returns (uint256[] memory);


    function getVestingEntryClaimable(address account, uint256 entryID) external view returns (uint);


    function getVestingEntry(address account, uint256 entryID) external view returns (uint64, uint256);


    function vest(uint256[] calldata entryIDs) external;


    function createEscrowEntry(
        address beneficiary,
        uint256 deposit,
        uint256 duration
    ) external;


    function appendVestingEntry(
        address account,
        uint256 quantity,
        uint256 duration
    ) external;


    function migrateVestingSchedule(address _addressToMigrate) external;


    function migrateAccountEscrowBalances(
        address[] calldata accounts,
        uint256[] calldata escrowBalances,
        uint256[] calldata vestedBalances
    ) external;


    function startMergingWindow() external;


    function mergeAccount(address accountToMerge, uint256[] calldata entryIDs) external;


    function nominateAccountToMerge(address account) external;


    function accountMergingIsOpen() external view returns (bool);


    function importVestingEntries(
        address account,
        uint256 escrowedAmount,
        VestingEntries.VestingEntry[] calldata vestingEntries
    ) external;


    function burnForMigration(address account, uint256[] calldata entryIDs)
        external
        returns (uint256 escrowedAccountBalance, VestingEntries.VestingEntry[] memory vestingEntries);

}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}




library SafeDecimalMath {

    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    uint public constant UNIT = 10**uint(decimals);

    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    function unit() external pure returns (uint) {

        return UNIT;
    }

    function preciseUnit() external pure returns (uint) {

        return PRECISE_UNIT;
    }

    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, UNIT);
    }

    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {

        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {

        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }
}


interface IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint);


    function balanceOf(address owner) external view returns (uint);


    function allowance(address owner, address spender) external view returns (uint);


    function transfer(address to, uint value) external returns (bool);


    function approve(address spender, uint value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}


interface IFeePool {


    function FEE_ADDRESS() external view returns (address);


    function feesAvailable(address account) external view returns (uint, uint);


    function feePeriodDuration() external view returns (uint);


    function isFeesClaimable(address account) external view returns (bool);


    function targetThreshold() external view returns (uint);


    function totalFeesAvailable() external view returns (uint);


    function totalRewardsAvailable() external view returns (uint);


    function claimFees() external returns (bool);


    function claimOnBehalf(address claimingForAddress) external returns (bool);


    function closeCurrentFeePeriod() external;


    function appendAccountIssuanceRecord(
        address account,
        uint lockedAmount,
        uint debtEntryIndex,
        bytes32 currencyKey
    ) external;


    function recordFeePaid(uint pUSDAmount) external;


    function setRewardsToDistribute(uint amount) external;

}


interface IVirtualPynth {

    function balanceOfUnderlying(address account) external view returns (uint);


    function rate() external view returns (uint);


    function readyToSettle() external view returns (bool);


    function secsLeftInWaitingPeriod() external view returns (uint);


    function settled() external view returns (bool);


    function pynth() external view returns (IPynth);


    function settle(address account) external;

}


interface IPeriFinance {

    function anyPynthOrPERIRateIsInvalid() external view returns (bool anyRateInvalid);


    function availableCurrencyKeys() external view returns (bytes32[] memory);


    function availablePynthCount() external view returns (uint);


    function availablePynths(uint index) external view returns (IPynth);


    function collateral(address account) external view returns (uint);


    function collateralisationRatio(address issuer) external view returns (uint);


    function debtBalanceOf(address issuer, bytes32 currencyKey) external view returns (uint);


    function isWaitingPeriod(bytes32 currencyKey) external view returns (bool);


    function maxIssuablePynths(address issuer) external view returns (uint maxIssuable);


    function remainingIssuablePynths(address issuer)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        );


    function pynths(bytes32 currencyKey) external view returns (IPynth);


    function pynthsByAddress(address pynthAddress) external view returns (bytes32);


    function totalIssuedPynths(bytes32 currencyKey) external view returns (uint);


    function totalIssuedPynthsExcludeEtherCollateral(bytes32 currencyKey) external view returns (uint);


    function transferablePeriFinance(address account) external view returns (uint transferable);


    function burnPynths(uint amount) external;


    function burnPynthsOnBehalf(address burnForAddress, uint amount) external;


    function burnPynthsToTarget() external;


    function burnPynthsToTargetOnBehalf(address burnForAddress) external;


    function exchange(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);


    function exchangeOnBehalf(
        address exchangeForAddress,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);


    function exchangeWithTracking(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address originator,
        bytes32 trackingCode
    ) external returns (uint amountReceived);


    function exchangeOnBehalfWithTracking(
        address exchangeForAddress,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address originator,
        bytes32 trackingCode
    ) external returns (uint amountReceived);


    function exchangeWithVirtual(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        bytes32 trackingCode
    ) external returns (uint amountReceived, IVirtualPynth vPynth);


    function issueMaxPynths() external;


    function issuePynths(uint amount) external;


    function issuePynthsOnBehalf(address issueForAddress, uint amount) external;


    function issueMaxPynthsOnBehalf(address issueForAddress) external;


    function stakeUSDCAndIssuePynths(uint usdcStakeAmount, uint issueAmount) external;


    function stakeUSDCAndIssueMaxPynths(uint usdcStakingAmount) external;


    function unstakeUSDCAndBurnPynths(uint usdcUnstakeAmount, uint burnAmount) external;


    function unstakeUSDCToMaxAndBurnPynths(uint burnAmount) external;


    function mint() external returns (bool);


    function settle(bytes32 currencyKey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntries
        );


    function liquidateDelinquentAccount(address account, uint pusdAmount) external returns (bool);



    function mintSecondary(address account, uint amount) external;


    function mintSecondaryRewards(uint amount) external;


    function burnSecondary(address account, uint amount) external;

}








contract BaseRewardEscrowV2 is Owned, IRewardEscrowV2, LimitedSetup(8 weeks), MixinResolver {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    mapping(address => mapping(uint256 => VestingEntries.VestingEntry)) public vestingSchedules;

    mapping(address => uint256[]) public accountVestingEntryIDs;

    uint256 public nextEntryId;

    mapping(address => uint256) public totalEscrowedAccountBalance;

    mapping(address => uint256) public totalVestedAccountBalance;

    mapping(address => address) public nominatedReceiver;

    uint256 public totalEscrowedBalance;

    uint public max_duration = 2 * 52 weeks; // Default max 2 years duration

    uint public maxAccountMergingDuration = 4 weeks; // Default 4 weeks is max


    uint public accountMergingDuration = 1 weeks;

    uint public accountMergingStartTime;


    bytes32 private constant CONTRACT_PERIFINANCE = "PeriFinance";
    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_FEEPOOL = "FeePool";


    constructor(address _owner, address _resolver) public Owned(_owner) MixinResolver(_resolver) {
        nextEntryId = 1;
    }


    function feePool() internal view returns (IFeePool) {

        return IFeePool(requireAndGetAddress(CONTRACT_FEEPOOL));
    }

    function periFinance() internal view returns (IPeriFinance) {

        return IPeriFinance(requireAndGetAddress(CONTRACT_PERIFINANCE));
    }

    function issuer() internal view returns (IIssuer) {

        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER));
    }

    function _notImplemented() internal pure {

        revert("Cannot be run on this layer");
    }


    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {

        addresses = new bytes32[](3);
        addresses[0] = CONTRACT_PERIFINANCE;
        addresses[1] = CONTRACT_FEEPOOL;
        addresses[2] = CONTRACT_ISSUER;
    }

    function balanceOf(address account) public view returns (uint) {

        return totalEscrowedAccountBalance[account];
    }

    function numVestingEntries(address account) external view returns (uint) {

        return accountVestingEntryIDs[account].length;
    }

    function getVestingEntry(address account, uint256 entryID) external view returns (uint64 endTime, uint256 escrowAmount) {

        endTime = vestingSchedules[account][entryID].endTime;
        escrowAmount = vestingSchedules[account][entryID].escrowAmount;
    }

    function getVestingSchedules(
        address account,
        uint256 index,
        uint256 pageSize
    ) external view returns (VestingEntries.VestingEntryWithID[] memory) {

        uint256 endIndex = index + pageSize;

        if (endIndex <= index) {
            return new VestingEntries.VestingEntryWithID[](0);
        }

        if (endIndex > accountVestingEntryIDs[account].length) {
            endIndex = accountVestingEntryIDs[account].length;
        }

        uint256 n = endIndex - index;
        VestingEntries.VestingEntryWithID[] memory vestingEntries = new VestingEntries.VestingEntryWithID[](n);
        for (uint256 i; i < n; i++) {
            uint256 entryID = accountVestingEntryIDs[account][i + index];

            VestingEntries.VestingEntry memory entry = vestingSchedules[account][entryID];

            vestingEntries[i] = VestingEntries.VestingEntryWithID({
                endTime: uint64(entry.endTime),
                escrowAmount: entry.escrowAmount,
                entryID: entryID
            });
        }
        return vestingEntries;
    }

    function getAccountVestingEntryIDs(
        address account,
        uint256 index,
        uint256 pageSize
    ) external view returns (uint256[] memory) {

        uint256 endIndex = index + pageSize;

        if (endIndex > accountVestingEntryIDs[account].length) {
            endIndex = accountVestingEntryIDs[account].length;
        }
        if (endIndex <= index) {
            return new uint256[](0);
        }

        uint256 n = endIndex - index;
        uint256[] memory page = new uint256[](n);
        for (uint256 i; i < n; i++) {
            page[i] = accountVestingEntryIDs[account][i + index];
        }
        return page;
    }

    function getVestingQuantity(address account, uint256[] calldata entryIDs) external view returns (uint total) {

        for (uint i = 0; i < entryIDs.length; i++) {
            VestingEntries.VestingEntry memory entry = vestingSchedules[account][entryIDs[i]];

            if (entry.escrowAmount != 0) {
                uint256 quantity = _claimableAmount(entry);

                total = total.add(quantity);
            }
        }
    }

    function getVestingEntryClaimable(address account, uint256 entryID) external view returns (uint) {

        VestingEntries.VestingEntry memory entry = vestingSchedules[account][entryID];
        return _claimableAmount(entry);
    }

    function _claimableAmount(VestingEntries.VestingEntry memory _entry) internal view returns (uint256) {

        uint256 quantity;
        if (_entry.escrowAmount != 0) {
            quantity = block.timestamp >= _entry.endTime ? _entry.escrowAmount : 0;
        }
        return quantity;
    }



    function vest(uint256[] calldata entryIDs) external {

        uint256 total;
        for (uint i = 0; i < entryIDs.length; i++) {
            VestingEntries.VestingEntry storage entry = vestingSchedules[msg.sender][entryIDs[i]];

            if (entry.escrowAmount != 0) {
                uint256 quantity = _claimableAmount(entry);

                if (quantity > 0) {
                    entry.escrowAmount = 0;
                }

                total = total.add(quantity);
            }
        }

        if (total != 0) {
            _transferVestedTokens(msg.sender, total);
        }
    }

    function createEscrowEntry(
        address beneficiary,
        uint256 deposit,
        uint256 duration
    ) external {

        require(beneficiary != address(0), "Cannot create escrow with address(0)");

        require(IERC20(address(periFinance())).transferFrom(msg.sender, address(this), deposit), "token transfer failed");

        _appendVestingEntry(beneficiary, deposit, duration);
    }

    function appendVestingEntry(
        address account,
        uint256 quantity,
        uint256 duration
    ) external onlyFeePool {

        _appendVestingEntry(account, quantity, duration);
    }

    function _transferVestedTokens(address _account, uint256 _amount) internal {

        _reduceAccountEscrowBalances(_account, _amount);
        totalVestedAccountBalance[_account] = totalVestedAccountBalance[_account].add(_amount);
        IERC20(address(periFinance())).transfer(_account, _amount);
        emit Vested(_account, block.timestamp, _amount);
    }

    function _reduceAccountEscrowBalances(address _account, uint256 _amount) internal {

        totalEscrowedBalance = totalEscrowedBalance.sub(_amount);
        totalEscrowedAccountBalance[_account] = totalEscrowedAccountBalance[_account].sub(_amount);
    }


    function accountMergingIsOpen() public view returns (bool) {

        return accountMergingStartTime.add(accountMergingDuration) > block.timestamp;
    }

    function startMergingWindow() external onlyOwner {

        accountMergingStartTime = block.timestamp;
        emit AccountMergingStarted(accountMergingStartTime, accountMergingStartTime.add(accountMergingDuration));
    }

    function setAccountMergingDuration(uint256 duration) external onlyOwner {

        require(duration <= maxAccountMergingDuration, "exceeds max merging duration");
        accountMergingDuration = duration;
        emit AccountMergingDurationUpdated(duration);
    }

    function setMaxAccountMergingWindow(uint256 duration) external onlyOwner {

        maxAccountMergingDuration = duration;
        emit MaxAccountMergingDurationUpdated(duration);
    }

    function setMaxEscrowDuration(uint256 duration) external onlyOwner {

        max_duration = duration;
        emit MaxEscrowDurationUpdated(duration);
    }

    function nominateAccountToMerge(address account) external {

        require(account != msg.sender, "Cannot nominate own account to merge");
        require(accountMergingIsOpen(), "Account merging has ended");
        require(issuer().debtBalanceOf(msg.sender, "pUSD") == 0, "Cannot merge accounts with debt");
        nominatedReceiver[msg.sender] = account;
        emit NominateAccountToMerge(msg.sender, account);
    }

    function mergeAccount(address accountToMerge, uint256[] calldata entryIDs) external {

        require(accountMergingIsOpen(), "Account merging has ended");
        require(issuer().debtBalanceOf(accountToMerge, "pUSD") == 0, "Cannot merge accounts with debt");
        require(nominatedReceiver[accountToMerge] == msg.sender, "Address is not nominated to merge");

        uint256 totalEscrowAmountMerged;
        for (uint i = 0; i < entryIDs.length; i++) {
            VestingEntries.VestingEntry memory entry = vestingSchedules[accountToMerge][entryIDs[i]];

            if (entry.escrowAmount != 0) {
                vestingSchedules[msg.sender][entryIDs[i]] = entry;

                totalEscrowAmountMerged = totalEscrowAmountMerged.add(entry.escrowAmount);

                accountVestingEntryIDs[msg.sender].push(entryIDs[i]);

                delete vestingSchedules[accountToMerge][entryIDs[i]];
            }
        }

        totalEscrowedAccountBalance[accountToMerge] = totalEscrowedAccountBalance[accountToMerge].sub(
            totalEscrowAmountMerged
        );
        totalEscrowedAccountBalance[msg.sender] = totalEscrowedAccountBalance[msg.sender].add(totalEscrowAmountMerged);

        emit AccountMerged(accountToMerge, msg.sender, totalEscrowAmountMerged, entryIDs, block.timestamp);
    }

    function _addVestingEntry(address account, VestingEntries.VestingEntry memory entry) internal returns (uint) {

        uint entryID = nextEntryId;
        vestingSchedules[account][entryID] = entry;

        accountVestingEntryIDs[account].push(entryID);

        nextEntryId = nextEntryId.add(1);

        return entryID;
    }


    function migrateVestingSchedule(address) external {

        _notImplemented();
    }

    function migrateAccountEscrowBalances(
        address[] calldata,
        uint256[] calldata,
        uint256[] calldata
    ) external {

        _notImplemented();
    }


    function burnForMigration(address, uint[] calldata) external returns (uint256, VestingEntries.VestingEntry[] memory) {

        _notImplemented();
    }

    function importVestingEntries(
        address,
        uint256,
        VestingEntries.VestingEntry[] calldata
    ) external {

        _notImplemented();
    }


    function _appendVestingEntry(
        address account,
        uint256 quantity,
        uint256 duration
    ) internal {

        require(quantity != 0, "Quantity cannot be zero");
        require(duration > 0 && duration <= max_duration, "Cannot escrow with 0 duration OR above max_duration");

        totalEscrowedBalance = totalEscrowedBalance.add(quantity);

        require(
            totalEscrowedBalance <= IERC20(address(periFinance())).balanceOf(address(this)),
            "Must be enough balance in the contract to provide for the vesting entry"
        );

        uint endTime = block.timestamp + duration;

        totalEscrowedAccountBalance[account] = totalEscrowedAccountBalance[account].add(quantity);

        uint entryID = nextEntryId;
        vestingSchedules[account][entryID] = VestingEntries.VestingEntry({endTime: uint64(endTime), escrowAmount: quantity});

        accountVestingEntryIDs[account].push(entryID);

        nextEntryId = nextEntryId.add(1);

        emit VestingEntryCreated(account, block.timestamp, quantity, duration, entryID);
    }

    modifier onlyFeePool() {

        require(msg.sender == address(feePool()), "Only the FeePool can perform this action");
        _;
    }

    event Vested(address indexed beneficiary, uint time, uint value);
    event VestingEntryCreated(address indexed beneficiary, uint time, uint value, uint duration, uint entryID);
    event MaxEscrowDurationUpdated(uint newDuration);
    event MaxAccountMergingDurationUpdated(uint newDuration);
    event AccountMergingDurationUpdated(uint newDuration);
    event AccountMergingStarted(uint time, uint endTime);
    event AccountMerged(
        address indexed accountToMerge,
        address destinationAddress,
        uint escrowAmountMerged,
        uint[] entryIDs,
        uint time
    );
    event NominateAccountToMerge(address indexed account, address destination);
}


interface IRewardEscrow {

    function balanceOf(address account) external view returns (uint);


    function numVestingEntries(address account) external view returns (uint);


    function totalEscrowedAccountBalance(address account) external view returns (uint);


    function totalVestedAccountBalance(address account) external view returns (uint);


    function getVestingScheduleEntry(address account, uint index) external view returns (uint[2] memory);


    function getNextVestingIndex(address account) external view returns (uint);


    function appendVestingEntry(address account, uint quantity) external;


    function vest() external;

}


interface ISystemStatus {

    struct Status {
        bool canSuspend;
        bool canResume;
    }

    struct Suspension {
        bool suspended;
        uint248 reason;
    }

    function accessControl(bytes32 section, address account) external view returns (bool canSuspend, bool canResume);


    function requireSystemActive() external view;


    function requireIssuanceActive() external view;


    function requireExchangeActive() external view;


    function requireExchangeBetweenPynthsAllowed(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view;


    function requirePynthActive(bytes32 currencyKey) external view;


    function requirePynthsActive(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view;


    function systemSuspension() external view returns (bool suspended, uint248 reason);


    function issuanceSuspension() external view returns (bool suspended, uint248 reason);


    function exchangeSuspension() external view returns (bool suspended, uint248 reason);


    function pynthExchangeSuspension(bytes32 currencyKey) external view returns (bool suspended, uint248 reason);


    function pynthSuspension(bytes32 currencyKey) external view returns (bool suspended, uint248 reason);


    function getPynthExchangeSuspensions(bytes32[] calldata pynths)
        external
        view
        returns (bool[] memory exchangeSuspensions, uint256[] memory reasons);


    function getPynthSuspensions(bytes32[] calldata pynths)
        external
        view
        returns (bool[] memory suspensions, uint256[] memory reasons);


    function suspendPynth(bytes32 currencyKey, uint256 reason) external;


    function updateAccessControl(
        bytes32 section,
        address account,
        bool canSuspend,
        bool canResume
    ) external;

}






contract RewardEscrowV2 is BaseRewardEscrowV2 {

    mapping(address => uint256) public totalBalancePendingMigration;

    uint public migrateEntriesThresholdAmount = SafeDecimalMath.unit() * 1000; // Default 1000 PERI


    bytes32 private constant CONTRACT_PERIFINANCE_BRIDGE_OPTIMISM = "PeriFinanceBridgeToOptimism";
    bytes32 private constant CONTRACT_REWARD_ESCROW = "RewardEscrow";
    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";


    constructor(address _owner, address _resolver) public BaseRewardEscrowV2(_owner, _resolver) {}


    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {

        bytes32[] memory existingAddresses = BaseRewardEscrowV2.resolverAddressesRequired();
        bytes32[] memory newAddresses = new bytes32[](3);
        newAddresses[0] = CONTRACT_PERIFINANCE_BRIDGE_OPTIMISM;
        newAddresses[1] = CONTRACT_REWARD_ESCROW;
        newAddresses[2] = CONTRACT_SYSTEMSTATUS;
        return combineArrays(existingAddresses, newAddresses);
    }

    function periFinanceBridgeToOptimism() internal view returns (address) {

        return requireAndGetAddress(CONTRACT_PERIFINANCE_BRIDGE_OPTIMISM);
    }

    function oldRewardEscrow() internal view returns (IRewardEscrow) {

        return IRewardEscrow(requireAndGetAddress(CONTRACT_REWARD_ESCROW));
    }

    function systemStatus() internal view returns (ISystemStatus) {

        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS));
    }


    uint internal constant TIME_INDEX = 0;
    uint internal constant QUANTITY_INDEX = 1;


    function setMigrateEntriesThresholdAmount(uint amount) external onlyOwner {

        migrateEntriesThresholdAmount = amount;
        emit MigrateEntriesThresholdAmountUpdated(amount);
    }

    function migrateVestingSchedule(address addressToMigrate) external systemActive {

        require(totalBalancePendingMigration[addressToMigrate] > 0, "No escrow migration pending");
        require(totalEscrowedAccountBalance[addressToMigrate] > 0, "Address escrow balance is 0");

        if (totalBalancePendingMigration[addressToMigrate] <= migrateEntriesThresholdAmount) {
            _importVestingEntry(
                addressToMigrate,
                VestingEntries.VestingEntry({
                    endTime: uint64(block.timestamp),
                    escrowAmount: totalBalancePendingMigration[addressToMigrate]
                })
            );

            delete totalBalancePendingMigration[addressToMigrate];
        } else {
            uint numEntries = oldRewardEscrow().numVestingEntries(addressToMigrate);

            for (uint i = 1; i <= numEntries; i++) {
                uint[2] memory vestingSchedule = oldRewardEscrow().getVestingScheduleEntry(addressToMigrate, numEntries - i);

                uint time = vestingSchedule[TIME_INDEX];
                uint amount = vestingSchedule[QUANTITY_INDEX];

                if (time < block.timestamp) {
                    break;
                }

                _importVestingEntry(
                    addressToMigrate,
                    VestingEntries.VestingEntry({endTime: uint64(time), escrowAmount: amount})
                );

                totalBalancePendingMigration[addressToMigrate] = totalBalancePendingMigration[addressToMigrate].sub(amount);
            }
        }
    }

    function importVestingSchedule(address[] calldata accounts, uint256[] calldata escrowAmounts)
        external
        onlyDuringSetup
        onlyOwner
    {

        require(accounts.length == escrowAmounts.length, "Account and escrowAmounts Length mismatch");

        for (uint i = 0; i < accounts.length; i++) {
            address addressToMigrate = accounts[i];
            uint256 escrowAmount = escrowAmounts[i];

            require(totalEscrowedAccountBalance[addressToMigrate] > 0, "Address escrow balance is 0");
            require(totalBalancePendingMigration[addressToMigrate] > 0, "No escrow migration pending");

            _importVestingEntry(
                addressToMigrate,
                VestingEntries.VestingEntry({endTime: uint64(block.timestamp), escrowAmount: escrowAmount})
            );

            totalBalancePendingMigration[addressToMigrate] = totalBalancePendingMigration[addressToMigrate].sub(
                escrowAmount
            );

            emit ImportedVestingSchedule(addressToMigrate, block.timestamp, escrowAmount);
        }
    }

    function migrateAccountEscrowBalances(
        address[] calldata accounts,
        uint256[] calldata escrowBalances,
        uint256[] calldata vestedBalances
    ) external onlyDuringSetup onlyOwner {

        require(accounts.length == escrowBalances.length, "Number of accounts and balances don't match");
        require(accounts.length == vestedBalances.length, "Number of accounts and vestedBalances don't match");

        for (uint i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            uint escrowedAmount = escrowBalances[i];
            uint vestedAmount = vestedBalances[i];

            require(totalBalancePendingMigration[account] == 0, "Account migration is pending already");

            totalEscrowedBalance = totalEscrowedBalance.add(escrowedAmount);

            totalEscrowedAccountBalance[account] = totalEscrowedAccountBalance[account].add(escrowedAmount);
            totalVestedAccountBalance[account] = totalVestedAccountBalance[account].add(vestedAmount);

            totalBalancePendingMigration[account] = escrowedAmount;

            emit MigratedAccountEscrow(account, escrowedAmount, vestedAmount, now);
        }
    }

    function _importVestingEntry(address account, VestingEntries.VestingEntry memory entry) internal {

        uint entryID = BaseRewardEscrowV2._addVestingEntry(account, entry);

        emit ImportedVestingEntry(account, entryID, entry.escrowAmount, entry.endTime);
    }


    function burnForMigration(address account, uint[] calldata entryIDs)
        external
        onlyPeriFinanceBridge
        returns (uint256 escrowedAccountBalance, VestingEntries.VestingEntry[] memory vestingEntries)
    {

        require(entryIDs.length > 0, "Entry IDs required");

        vestingEntries = new VestingEntries.VestingEntry[](entryIDs.length);

        for (uint i = 0; i < entryIDs.length; i++) {
            VestingEntries.VestingEntry storage entry = vestingSchedules[account][entryIDs[i]];

            if (entry.escrowAmount > 0) {
                vestingEntries[i] = entry;

                escrowedAccountBalance = escrowedAccountBalance.add(entry.escrowAmount);

                delete vestingSchedules[account][entryIDs[i]];
            }
        }

        if (escrowedAccountBalance > 0) {
            _reduceAccountEscrowBalances(account, escrowedAccountBalance);
            IERC20(address(periFinance())).transfer(periFinanceBridgeToOptimism(), escrowedAccountBalance);
        }

        emit BurnedForMigrationToL2(account, entryIDs, escrowedAccountBalance, block.timestamp);

        return (escrowedAccountBalance, vestingEntries);
    }


    modifier onlyPeriFinanceBridge() {

        require(msg.sender == periFinanceBridgeToOptimism(), "Can only be invoked by PeriFinanceBridgeToOptimism contract");
        _;
    }

    modifier systemActive() {

        systemStatus().requireSystemActive();
        _;
    }

    event MigratedAccountEscrow(address indexed account, uint escrowedAmount, uint vestedAmount, uint time);
    event ImportedVestingSchedule(address indexed account, uint time, uint escrowAmount);
    event BurnedForMigrationToL2(address indexed account, uint[] entryIDs, uint escrowedAmountMigrated, uint time);
    event ImportedVestingEntry(address indexed account, uint entryID, uint escrowAmount, uint endTime);
    event MigrateEntriesThresholdAmountUpdated(uint newAmount);
}