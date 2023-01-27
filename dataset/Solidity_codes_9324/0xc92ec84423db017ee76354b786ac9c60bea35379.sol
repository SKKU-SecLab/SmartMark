
pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;

interface WETH9 {

    function deposit() external payable;

    function withdraw(uint wad) external;


    function totalSupply() external view returns (uint);


    function approve(address guy, uint wad) external returns (bool);


    function transfer(address dst, uint wad) external returns (bool);


    function transferFrom(address src, address dst, uint wad)
        external
        returns (bool);

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


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
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


library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract SafeCast {

    function safe128(uint256 n)
        internal
        pure
        returns (uint128)
    {

        require(n < 2**128, "safe128");
        return uint128(n);
    }

    function safe32(uint256 n)
        internal
        pure
        returns (uint32)
    {

        require(n < 2**32, "safe32");
        return uint32(n);
    }
}
contract CoverRate is SafeCast {

    using SafeMath for uint256;


    uint128 constant PERCENT = 100;

    uint128 constant BASE = 10 ** 18;

    uint128 constant SECONDS_IN_A_YEAR = 60 * 60 * 24 * 365;

    uint128 constant BYTE = 8;


    uint64 rate_storage;


    function intialize_rate(
        uint64 coefficients
    )
        internal
    {

        uint256 sumOfCoefficients = 0;
        for (
            uint256 actual_coefficients = coefficients;
            actual_coefficients != 0;
            actual_coefficients >>= BYTE
        ) {
            sumOfCoefficients += actual_coefficients % 256;
        }
        require(
            sumOfCoefficients == PERCENT,
            "must sum to 100"
        );

        rate_storage = coefficients;
    }


    function getInterestRate(
        uint128 utilized,
        uint128 total
    )
        public
        view
        returns (uint128)
    {

        if (utilized == 0) {
            return 0;
        }
        if (utilized > total) {
            return BASE;
        }

        uint256 coefficients = rate_storage;
        uint256 result = uint8(coefficients) * BASE;
        coefficients >>= BYTE;

        uint256 polynomial = uint256(BASE).mul(utilized) / total;

        while (true) {
            uint256 coefficient = uint256(uint8(coefficients));

            if (coefficient != 0) {
                result += coefficient * polynomial;

                if (coefficient == coefficients) {
                    break;
                }
            }

            polynomial = polynomial * polynomial / BASE;

            coefficients >>= BYTE;
        }

        return uint128(result / (SECONDS_IN_A_YEAR * PERCENT));
    }

    function getCoefficients()
        public
        view
        returns (uint128[] memory)
    {

        uint128[] memory result = new uint128[](8);

        uint128 numCoefficients = 0;
        for (
            uint128 coefficients = rate_storage;
            coefficients != 0;
            coefficients >>= BYTE
        ) {
            result[numCoefficients] = coefficients % 256;
            numCoefficients++;
        }

        assembly {
            mstore(result, numCoefficients)
        }

        return result;
    }
}


contract CoverPricing is CoverRate {



    function price(uint128 coverageAmount, uint128 duration, uint128 utilized, uint128 reserves)
        public
        view
        returns (uint128)
    {

        return _price(coverageAmount, duration, utilized, reserves);
    }


    function _price(uint128 coverageAmount, uint128 duration, uint128 utilized, uint128 reserves)
        internal
        view
        returns (uint128)
    {

        require(duration <= 86400*14, "duration > max duration");
        uint128 new_util = safe128(uint256(utilized).add(coverageAmount));
        uint128 rate = getInterestRate(new_util, reserves);

        uint128 coverage_price = uint128(uint256(coverageAmount).mul(rate).mul(duration).div(BASE));

        return coverage_price;
    }
}

contract UmbrellaMetaPool is CoverPricing {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event NewProtection(string indexed concept, uint128 amount, uint32 duration, uint128 coverage_price);
    event ProvideCoverage(address indexed provider, uint128 amount);
    event ArbiterPaid(uint256 amount);
    event CreatorPaid(uint256 amount);
    event Withdraw(address indexed provider, uint256 amount);
    event Claim(address indexed holder, uint256 indexed pid, uint256 payout);
    event ClaimPremiums(address indexed claimer, uint256 premiums_claimed);
    event Swept(uint256 indexed pid, uint128 premiums_paid);

    modifier hasArbiter() {

        require(arbSet, "!arbSet");
        _;
    }

    modifier onlyArbiter() {

        require(msg.sender == arbiter, "!arbiter");
        _;
    }

    function updateGlobalTPS() internal {

      uint256 timestamp = block.timestamp;

      uint256 newGlobalTokenSecondsProvided = (timestamp - lastUpdatedTPS).mul(reserves);
      totalProtectionSeconds = totalProtectionSeconds.add(newGlobalTokenSecondsProvided);
      lastUpdatedTPS = safe32(timestamp);
    }

    function updateTokenSecondsProvided(address account) internal {

      uint256 timestamp = block.timestamp;
      uint256 newTokenSecondsProvided = (timestamp - providers[account].lastUpdate).mul(providers[account].shares);

      providers[account].totalTokenSecondsProvided = providers[account].totalTokenSecondsProvided.add(newTokenSecondsProvided);
      providers[account].lastUpdate = safe32(timestamp);

      uint256 newGlobalTokenSecondsProvided = (timestamp - lastUpdatedTPS).mul(reserves);
      totalProtectionSeconds = totalProtectionSeconds.add(newGlobalTokenSecondsProvided);
      lastUpdatedTPS = safe32(timestamp);
    }



    uint128 public constant MAX_RESERVES = 1000 * 10**18;

    uint128 public constant LOCKUP_PERIOD = 60 * 60 * 24 * 7;
    uint128 public constant WITHDRAW_GRACE_PERIOD = 60 * 60 * 24 * 14;

    WETH9 public constant WETH = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    bool private initialized;
    bool public arbSet;
    bool private accepted;

    string[] public coveredConcepts;
    string public description;
    address public payToken;
    uint128 public utilized;
    uint128 public reserves;
    uint128 public totalShares;
    uint128 public minPay;
    uint32 public lastUpdatedTPS;
    uint256 public totalProtectionSeconds;
    uint256 public premiumsAccum;

    uint128 public creatorFee;
    uint128 public creatorFees;
    address public creator;

    uint128 public arbiterFee;
    uint128 public arbiterFees;
    address public arbiter;

    uint128 public rollover;

    Protection[] public protections;

    uint32[][] public claimTimes;


    mapping ( address => ProtectionProvider ) public providers;

    mapping ( address => uint256[] ) public protectionsForAddress;

    enum Status { Active, Swept, Claimed }

    struct ProtectionProvider {
      uint256 totalTokenSecondsProvided;
      uint256 premiumIndex;
      uint128 shares;
      uint32 lastUpdate;
      uint32 lastProvide;
      uint32 withdrawInitiated;
    }

    struct Protection {
        uint128 coverageAmount;
        uint128 paid;
        address holder;
        uint32 start;
        uint32 expiry;
        uint8 conceptIndex;
        Status status;
    }


    function initialize(
        address payToken_,
        uint64 coefficients,
        uint128 creatorFee_,
        uint128 arbiterFee_,
        uint128 rollover_,
        uint128 minPay_,
        string[] memory coveredConcepts_,
        string memory description_,
        address creator_,
        address arbiter_
    )
        public
    {

        require(!initialized, "initialized");
        initialized = true;
        require(coveredConcepts_.length < 16, "too many concepts");


        intialize_rate(coefficients);

        payToken         = payToken_;
        arbiterFee       = arbiterFee_;
        creatorFee       = creatorFee_;
        rollover         = rollover_;
        coveredConcepts  = coveredConcepts_;
        description      = description_;
        creator          = creator_;
        arbiter          = arbiter_;
        minPay           = minPay_;
        claimTimes       = new uint32[][](coveredConcepts_.length);

        if (creator_ == arbiter_) {
            arbSet = true;
            accepted = true;
        }
    }


    function getConcepts()
        public
        view
        returns (string[] memory)
    {

        string[] memory concepts = coveredConcepts;
        return concepts;
    }

    function getPids(address who)
        public
        view
        returns (uint256[] memory)
    {

        uint256[] memory pids = protectionsForAddress[who];
        return pids;
    }

    function getProtectionInfo(uint256 pid)
        public
        view
        returns (Protection memory)
    {

        return protections[pid];
    }

    function currentProviderTPS(address who)
        public
        view
        returns (uint256)
    {

        uint256 timestamp = block.timestamp;
        uint256 newTokenSecondsProvided = (timestamp - providers[who].lastUpdate).mul(providers[who].shares);
        return providers[who].totalTokenSecondsProvided.add(newTokenSecondsProvided);
    }

    function currentTotalTPS()
        public
        view
        returns (uint256)
    {

        uint256 timestamp = block.timestamp;
        uint256 newGlobalTokenSecondsProvided = (timestamp - lastUpdatedTPS).mul(reserves);
        return totalProtectionSeconds.add(newGlobalTokenSecondsProvided);
    }

    function currentPrice(uint128 coverageAmount, uint128 duration)
        public
        view
        returns (uint256)
    {

        return _price(coverageAmount, duration, utilized, reserves);
    }



    function buyProtection(
        uint8 conceptIndex,
        uint128 coverageAmount,
        uint128 duration,
        uint128 maxPay,
        uint256 deadline
    )
        public
        payable
        hasArbiter
    {

        require(block.timestamp <= deadline,               "buy:!deadline");
        require(   conceptIndex <  coveredConcepts.length, "buy:!conceptIndex");

        uint128 coverage_price = _price(coverageAmount, duration, utilized, reserves);

        require(uint256(utilized).add(coverageAmount) <= reserves, "buy: overutilized");
        require(coverage_price >= minPay && coverage_price <= maxPay, "buy:!pay");

        protections.push(
          Protection({
              coverageAmount: coverageAmount,
              paid: coverage_price,
              holder: msg.sender,
              start: safe32(block.timestamp),
              expiry: safe32(block.timestamp + duration),
              conceptIndex: conceptIndex,
              status: Status.Active
          })
        );

        protectionsForAddress[msg.sender].push(protections.length - 1);

        utilized = safe128(uint256(utilized).add(coverageAmount));

        if (payToken == address(WETH) && msg.value > 0) {
            uint256 remainder = msg.value.sub(coverage_price, "buy:underpayment");
            WETH.deposit.value(coverage_price)();

            if (remainder > 0) {
                msg.sender.transfer(remainder);
            }
        } else {
            require(msg.value == 0, "buy:payToken !WETH");
            IERC20(payToken).safeTransferFrom(msg.sender, address(this), coverage_price);
        }

        emit NewProtection(coveredConcepts[conceptIndex], coverageAmount, safe32(duration), coverage_price);
    }

    function isSettlable(uint256 pid)
        public
        view
        returns (bool)
    {

        Protection memory protection = protections[pid];
        if (protection.status != Status.Active) {
            return false;
        }
        return _hasSettlement(protection.conceptIndex, protection.start, protection.expiry);
    }

    function _hasSettlement(uint32 index, uint32 start, uint32 expiry)
        internal
        view
        returns (bool)
    {

        uint32[] memory claimTimesForIndex = claimTimes[index];
        if (claimTimesForIndex.length == 0) {
            return false;
        }
        if (start > claimTimesForIndex[claimTimesForIndex.length - 1]) {
            return false;
        }
        if (expiry < claimTimesForIndex[0]) {
            return false;
        }
        for (uint32 i = 0; i < claimTimesForIndex.length; i++) {
            if (start > claimTimesForIndex[i]) {
                continue;
            }

            if (expiry >= claimTimesForIndex[i]) {
                return true;
            } else {
                return false;
            }
        }
    }


    function claim(uint256 pid)
        public
    {

        updateGlobalTPS();
        Protection storage protection = protections[pid];
        require(
            protection.holder == msg.sender,
            "claim:!owner"
        );

        require(protection.status == Status.Active, "claim:!active");
        require(_hasSettlement(protection.conceptIndex, protection.start, protection.expiry), "claim:!settlement");

        protection.status = Status.Claimed;

        utilized = uint128(uint256(utilized).sub(protection.coverageAmount));
        reserves = uint128(uint256(reserves).sub(protection.coverageAmount));

        uint256 payout = uint256(protection.coverageAmount).add(protection.paid);
        IERC20(payToken).safeTransfer(protection.holder, payout);
        emit Claim(protection.holder, pid, payout);
    }



    function balanceOf(address who)
        public
        view
        returns (uint256)
    {

        return providers[who].shares;
    }

    function balanceOfUnderlying(address who)
        public
        view
        returns (uint256)
    {

        uint256 shares = providers[who].shares;
        return shares.mul(reserves).div(totalShares);
    }

    function provideCoverage(
        uint128 amount
    )
        public
        hasArbiter
    {

        updateTokenSecondsProvided(msg.sender);
        require(amount > 0, "provide:amount 0");
        _claimPremiums();
        enter(amount);
        require(reserves <= MAX_RESERVES, "provide:max reserves");
        IERC20(payToken).safeTransferFrom(msg.sender, address(this), amount);
        emit ProvideCoverage(msg.sender, amount);
    }

    function initiateWithdraw()
        public
    {

        if (
          block.timestamp > providers[msg.sender].withdrawInitiated + WITHDRAW_GRACE_PERIOD
          || providers[msg.sender].lastProvide + LOCKUP_PERIOD > providers[msg.sender].withdrawInitiated + WITHDRAW_GRACE_PERIOD
        ) {
            providers[msg.sender].withdrawInitiated = safe32(block.timestamp);
        }
    }

    function withdrawUnderlying(uint128 amount)
        public
    {

        updateTokenSecondsProvided(msg.sender);
        uint128 asShares = uint128(uint256(amount).mul(totalShares).div(reserves));
        _withdraw(asShares);
    }

    function withdraw(uint128 amount)
        public
    {

        updateTokenSecondsProvided(msg.sender);
        _withdraw(amount);
    }

    function _withdraw(uint128 asShares)
        internal
    {

        require(        providers[msg.sender].withdrawInitiated + LOCKUP_PERIOD <  block.timestamp, "withdraw:locked");
        require(              providers[msg.sender].lastProvide + LOCKUP_PERIOD <  block.timestamp, "withdraw:locked2");
        require(providers[msg.sender].withdrawInitiated + WITHDRAW_GRACE_PERIOD >= block.timestamp, "withdraw:expired");

        _claimPremiums();

        uint128 underlying = exit(asShares);
        require(reserves >= utilized, "withdraw:!liquidity");
        if (providers[msg.sender].shares == 0) {
            providers[msg.sender].totalTokenSecondsProvided = 0;
        }
        IERC20(payToken).safeTransfer(msg.sender, underlying);
        emit Withdraw(msg.sender, underlying);
    }

    function enter(uint128 underlying)
        internal
    {

        providers[msg.sender].lastProvide = safe32(block.timestamp);
        uint128 res = reserves;
        uint128 ts = totalShares;
        if (ts == 0 || res == 0) {
            providers[msg.sender].shares = safe128(uint256(providers[msg.sender].shares).add(underlying));
            totalShares = safe128(uint256(totalShares).add(underlying));
        }  else {
            uint128 asShares = safe128(uint256(underlying).mul(ts).div(res));
            providers[msg.sender].shares = safe128(uint256(providers[msg.sender].shares).add(asShares));
            totalShares = safe128(uint256(ts).add(asShares));
        }
        reserves = safe128(uint256(res).add(underlying));
    }

    function exit(uint128 asShares)
        internal
        returns (uint128)
    {

        uint128 res = reserves;
        uint128 ts = totalShares;
        providers[msg.sender].shares = uint128(uint256(providers[msg.sender].shares).sub(asShares));
        totalShares = uint128(uint256(ts).sub(asShares));
        uint128 underlying = uint128(uint256(asShares).mul(res).div(ts));
        reserves = uint128(uint256(res).sub(underlying));
        return underlying;
    }

    function claimPremiums()
        public
    {

        updateTokenSecondsProvided(msg.sender);
        _claimPremiums();
    }

    function _claimPremiums()
        internal
    {

        uint256 ttsp = providers[msg.sender].totalTokenSecondsProvided;
        if (ttsp > 0) {
            uint256 claimable = _claimablePremiums(providers[msg.sender].premiumIndex, ttsp, totalProtectionSeconds);

            if (claimable == 0) {
                return;
            }

            providers[msg.sender].premiumIndex = premiumsAccum;

            IERC20(payToken).safeTransfer(msg.sender, claimable);
            emit ClaimPremiums(msg.sender, claimable);
        } else {
            providers[msg.sender].premiumIndex = premiumsAccum;
        }
    }

    function claimablePremiums(address who)
        public
        view
        returns (uint256)
    {

        uint256 timestamp = block.timestamp;
        uint256 newTokenSecondsProvided = (timestamp - providers[who].lastUpdate).mul(providers[who].shares);
        uint256 whoTPS = providers[who].totalTokenSecondsProvided.add(newTokenSecondsProvided);
        uint256 newTTPS = (timestamp - lastUpdatedTPS).mul(reserves);
        uint256 globalTPS = totalProtectionSeconds.add(newTTPS);
        return _claimablePremiums(providers[who].premiumIndex, whoTPS, globalTPS);
    }

    function _claimablePremiums(uint256 index, uint256 providerTPS, uint256 globalTPS)
        internal
        view
        returns (uint256)
    {

        return premiumsAccum
                  .sub(index)
                  .mul(providerTPS)
                  .div(totalProtectionSeconds);
    }

    function sweepPremiums(uint256[] memory pids)
        public
    {

        updateGlobalTPS();
        uint pidsLength = pids.length;
        uint128 totalSweptCoverage;
        uint128 totalPaid;
        for (uint256 i = 0; i < pidsLength; i++) {
            (uint128 coverageAmount, uint128 paid) = _sweep(pids[i]);
            totalSweptCoverage = safe128(uint256(totalSweptCoverage).add(coverageAmount));
            totalPaid          = safe128(uint256(totalPaid).add(paid));
        }
        _update(totalSweptCoverage, totalPaid);
    }

    function sweep(uint256 pid)
        public
    {

        updateGlobalTPS();
        (uint128 coverageAmount, uint128 paid) = _sweep(pid);
        _update(coverageAmount, paid);
    }

    function _sweep(uint256 pid)
        internal
        returns (uint128, uint128)
    {

        Protection storage protection = protections[pid];

        require(                       protection.status == Status.Active,                "Sweep:!active");
        require(                   protection.expiry + 86400*7 <  block.timestamp,        "Sweep:!expired");
        require(!_hasSettlement(protection.conceptIndex, protection.start, protection.expiry), "Sweep:!settlment");

        protection.status = Status.Swept;
        emit Swept(pid, protection.paid);
        return (protection.coverageAmount, protection.paid);
    }

    function _update(uint128 coverageRemoved, uint128 premiumsPaid)
        internal
    {

        utilized = uint128(uint256(utilized).sub(coverageRemoved));
        uint256 arbFees;
        uint256 createFees;
        uint256 rollovers;
        if (arbiterFee > 0) {
            arbFees = uint256(premiumsPaid).mul(arbiterFee).div(BASE);
            arbiterFees = safe128(uint256(arbiterFees).add(arbFees)); // pay arbiter
        }
        if (creatorFee > 0) {
            createFees = uint256(premiumsPaid).mul(creatorFee).div(BASE);
            creatorFees = safe128(uint256(creatorFees).add(createFees)); // pay creator
        }
        if (rollover > 0) {
            rollovers = uint256(premiumsPaid).mul(rollover).div(BASE);
            reserves = safe128(uint256(reserves).add(rollovers)); // rollover some % of premiums into reserves
        }

        premiumsAccum = premiumsAccum.add(premiumsPaid - arbFees - createFees - rollovers);
    }


    function _setSettling(uint8 conceptIndex, uint32 settleTime, bool needs_sort)
        public
        onlyArbiter
    {

        require(conceptIndex < coveredConcepts.length, "setSettling:!index");
        require(  settleTime < block.timestamp,        "setSettling:!settleTime");
        if (!needs_sort && claimTimes[conceptIndex].length > 0) {
            uint32 last = claimTimes[conceptIndex][claimTimes[conceptIndex].length - 1];
            require(settleTime > last, "setSettling:!settleTime");
        }
        claimTimes[conceptIndex].push(settleTime);
        if (needs_sort) {
            uint256 lastIndex = claimTimes[conceptIndex].length - 1;
            quickSort(claimTimes[conceptIndex], int(0), int(lastIndex));
        }
    }

    function _acceptArbiter()
        public
        onlyArbiter
    {

        require(!accepted, "acceptArb:accepted");
        arbSet = true;
        accepted = true;
    }

    function _getArbiterFees()
        public
        onlyArbiter
    {

        uint128 a_fees = arbiterFees;
        arbiterFees = 0;
        IERC20(payToken).safeTransfer(arbiter, a_fees);
        emit ArbiterPaid(a_fees);
    }

    function _abdicate()
        public
        onlyArbiter
    {

        arbSet = false;
    }

    function _getCreatorFees()
        public
    {

        require(msg.sender == creator, "!creator");
        uint128 c_fees = creatorFees;
        creatorFees = 0;
        IERC20(payToken).safeTransfer(creator, c_fees);
        emit CreatorPaid(c_fees);
    }



    function quickSort(uint32[] storage arr, int left, int right) internal {

        int i = left;
        int j = right;
        if (i == j) return;
        uint32 pivot = arr[uint32(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint32(i)] < pivot) i++;
            while (pivot < arr[uint32(j)]) j--;
            if (i <= j) {
                (arr[uint32(i)], arr[uint32(j)]) = (arr[uint32(j)], arr[uint32(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }

}