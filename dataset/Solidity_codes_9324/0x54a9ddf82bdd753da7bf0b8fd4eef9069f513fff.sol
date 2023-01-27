

pragma solidity ^0.5.0;

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
}


pragma solidity ^0.5.0;


contract WhitelistAdminRole {

    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {

        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {

        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {

        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {

        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {

        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {

        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;



library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}


pragma solidity >=0.4.14 <0.6.0;






contract TermDeposit is WhitelistAdminRole {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event DoDeposit(address indexed depositor, uint256 amount);
    event Withdraw(address indexed depositor, uint256 amount);
    event AddReferral(address indexed depositor, address indexed referrer, uint256 amount);
    event GetReferralBonus(address indexed depositor, uint256 amount);
    event Drain(address indexed admin);
    event Goodbye(address indexed admin, uint256 amount);

    uint256 public constant MIN_DEPOSIT = 100 * 1e18;  // => 100 QKC.
    bytes4 public constant TERM_3MO = "3mo";
    bytes4 public constant TERM_6MO = "6mo";
    bytes4 public constant TERM_9MO = "9mo";
    bytes4 public constant TERM_12MO = "12mo";

    struct FeatureFlag {
        uint8 version;
        bool enableInterest;
        bool enableReferralBonus;
        bool enableDepositLimit;
    }

    struct TermDepositInfo {
        uint256 depositDeadline;
        uint256 duration;
        uint256 interestBp;
        uint256 totalDepositAllowed;
        uint256 totalReceived;
        mapping (address => Deposit[]) deposits;
        uint256 totalReferralAmount;
        uint256 referralBonusRateBp;
        mapping (address => Referral) referrals;
    }

    struct Deposit {
        uint256 amount;
        uint256 depositAt;
        uint256 withdrawAt;
    }

    struct Referral {
        uint256 amount;
        uint256 withdrawAt;
    }

    mapping (bytes4 => TermDepositInfo) private _termDeposits;
    IERC20 private _token;
    FeatureFlag private _featureFlags;

    uint256 public referralBonusLockUntil;
    bytes4[] public allTerms = [TERM_3MO, TERM_6MO, TERM_9MO, TERM_12MO];

    constructor(uint256 depositDeadline, IERC20 token, uint8 version) public {
        require(depositDeadline > 0, "should have sensible argument");

        processFeatureFlag(version);

        uint256 monthInSec = 2635200;
        _token = token;

        _termDeposits[TERM_3MO] = TermDepositInfo({
            depositDeadline: depositDeadline,
            duration: 3 * monthInSec,
            interestBp: 250,
            totalDepositAllowed: (10 ** 7) * 1e18,
            totalReceived: 0,
            referralBonusRateBp: 22,
            totalReferralAmount: 0
        });

        _termDeposits[TERM_6MO] = TermDepositInfo({
            depositDeadline: depositDeadline,
            duration: 6 * monthInSec,
            interestBp: 550,
            totalDepositAllowed: (10 ** 7) * 1e18,
            totalReceived: 0,
            referralBonusRateBp: 45,
            totalReferralAmount: 0
        });

        _termDeposits[TERM_9MO] = TermDepositInfo({
            depositDeadline: depositDeadline,
            duration: 9 * monthInSec,
            interestBp: 1000,
            totalDepositAllowed: (10 ** 7) * 1e18,
            totalReceived: 0,
            referralBonusRateBp: 80,
            totalReferralAmount: 0
        });

        _termDeposits[TERM_12MO] = TermDepositInfo({
            depositDeadline: depositDeadline,
            duration: 12 * monthInSec,
            interestBp: 1300,
            totalDepositAllowed: (10 ** 7) * 1e18,
            totalReceived: 0,
            referralBonusRateBp: 100,
            totalReferralAmount: 0
        });

        referralBonusLockUntil = depositDeadline;
    }

    function processFeatureFlag(uint8 version) private {

        require(version <= 2, "should only allow version <= 2");
        _featureFlags.version = version;
        if (version > 0) {
            _featureFlags.enableDepositLimit = true;
        }
        if (version > 1) {
            _featureFlags.enableInterest = true;
            _featureFlags.enableReferralBonus = true;
        }
    }

    function token() public view returns (IERC20) {

        return _token;
    }

    function featureFlagVersion() public view returns (uint8) {

        return _featureFlags.version;
    }

    function getTermDepositInfo(bytes4 term) public view returns (uint256[7] memory) {

        TermDepositInfo memory info = _termDeposits[term];
        require(info.duration > 0, "should be a valid term");
        return [
            info.depositDeadline,
            info.duration,
            info.interestBp,
            info.totalDepositAllowed,
            info.totalReceived,
            info.referralBonusRateBp,
            info.totalReferralAmount
        ];
    }

    function deposit(bytes4 term, uint256 amount, address referrer) public {

        require(amount >= MIN_DEPOSIT, "should have amount >= minimum");
        require(referrer != msg.sender, "should not have self as the referrer");
        TermDepositInfo storage info = _termDeposits[term];
        require(info.duration > 0, "should be a valid term");
        require(now <= info.depositDeadline, "should deposit before the deadline");
        if (_featureFlags.enableDepositLimit) {
            require(
                info.totalReceived.add(amount) <= info.totalDepositAllowed,
                "should not exceed deposit limit"
            );
        }
        if (!_featureFlags.enableReferralBonus) {
            require(referrer == address(0), "should not allow referrer per FF");
        }

        Deposit[] storage deposits = info.deposits[msg.sender];
        deposits.push(Deposit({
            amount: amount,
            depositAt: now,
            withdrawAt: 0
        }));
        info.totalReceived = info.totalReceived.add(amount);
        emit DoDeposit(msg.sender, amount);

        if (referrer != address(0)) {
            Referral storage referral = info.referrals[referrer];
            referral.amount = referral.amount.add(amount);
            info.totalReferralAmount = info.totalReferralAmount.add(amount);
            emit AddReferral(msg.sender, referrer, amount);
        }

        _token.safeTransferFrom(msg.sender, address(this), amount);
    }

    function getDepositAmount(
        address depositor,
        bytes4[] memory terms,
        bool withdrawable,
        bool withInterests
    ) public view returns (uint256[] memory)
    {

        if (!_featureFlags.enableInterest) {
            require(!withInterests, "should not allow querying interests per FF");
        }
        uint256[] memory ret = new uint256[](terms.length);
        for (uint256 i = 0; i < terms.length; i++) {
            TermDepositInfo storage info = _termDeposits[terms[i]];
            require(info.duration > 0, "should be a valid term");
            Deposit[] memory deposits = info.deposits[depositor];

            uint256 total = 0;
            for (uint256 j = 0; j < deposits.length; j++) {
                uint256 lockUntil = deposits[j].depositAt.add(info.duration);
                if (deposits[j].withdrawAt == 0) {
                    if (!withdrawable || now >= lockUntil) {
                        total = total.add(deposits[j].amount);
                    }
                }
            }
            if (withInterests) {
                total = total.add(total.mul(info.interestBp).div(10000));
            }
            ret[i] = total;
        }
        return ret;
    }

    function getDepositDetails(
        address depositor,
        bytes4 term
    ) public view returns (uint256[] memory, uint256[] memory, uint256[] memory)
    {

        TermDepositInfo storage info = _termDeposits[term];
        require(info.duration > 0, "should be a valid term");
        Deposit[] memory deposits = info.deposits[depositor];

        uint256[] memory amounts = new uint256[](deposits.length);
        uint256[] memory depositTs = new uint256[](deposits.length);
        uint256[] memory withdrawTs = new uint256[](deposits.length);
        for (uint256 i = 0; i < deposits.length; i++) {
            amounts[i] = deposits[i].amount;
            depositTs[i] = deposits[i].depositAt;
            withdrawTs[i] = deposits[i].withdrawAt;
        }
        return (amounts, depositTs, withdrawTs);
    }

    function withdraw(bytes4 term) public returns (bool) {

        TermDepositInfo storage info = _termDeposits[term];
        require(info.duration > 0, "should be a valid term");
        Deposit[] storage deposits = info.deposits[msg.sender];

        uint256 total = 0;
        for (uint256 i = 0; i < deposits.length; i++) {
            uint256 lockUntil = deposits[i].depositAt.add(info.duration);
            if (deposits[i].withdrawAt == 0 && now >= lockUntil) {
                total = total.add(deposits[i].amount);
                deposits[i].withdrawAt = now;
            }
        }

        if (total == 0) {
            return false;
        }

        info.totalReceived = info.totalReceived.sub(total);
        if (_featureFlags.enableInterest) {
            total = total.add(total.mul(info.interestBp).div(10000));
        }
        emit Withdraw(msg.sender, total);

        _token.safeTransfer(msg.sender, total);
        return true;
    }

    function calculateReferralBonus(
        address depositor, bytes4[] memory terms
    ) public view returns (uint256[] memory, uint256)
    {

        require(_featureFlags.enableReferralBonus, "should only support querying referral per FF");
        uint256 bonus = 0;
        uint256[] memory amounts = new uint256[](terms.length);
        for (uint256 i = 0; i < terms.length; i++) {
            TermDepositInfo storage info = _termDeposits[terms[i]];
            require(info.duration > 0, "should be a valid term");

            Referral memory r = info.referrals[depositor];
            if (r.amount > 0 && r.withdrawAt == 0) {
                bonus = bonus.add(r.amount.mul(info.referralBonusRateBp).div(10000));
            }
            amounts[i] = r.amount;
        }
        return (amounts, bonus);
    }

    function getReferralBonus(bytes4[] memory terms) public {

        require(
            _featureFlags.enableReferralBonus,
            "should only support retrieving referral bonus per FF"
        );
        require(now >= referralBonusLockUntil, "should only allow referral bonus after unlocked");

        uint256 bonus = 0;
        for (uint256 i = 0; i < terms.length; i++) {
            TermDepositInfo storage info = _termDeposits[terms[i]];
            require(info.duration > 0, "should be a valid term");

            Referral storage r = info.referrals[msg.sender];
            if (r.amount > 0 && r.withdrawAt == 0) {
                bonus = bonus.add(r.amount.mul(info.referralBonusRateBp).div(10000));
                r.withdrawAt = now;
                info.totalReferralAmount = info.totalReferralAmount.sub(r.amount);
            }
        }
        emit GetReferralBonus(msg.sender, bonus);
        _token.safeTransfer(msg.sender, bonus);
    }

    function updateDepositDeadline(
        bytes4 term,
        uint256 newDepositDeadline
    ) public onlyWhitelistAdmin
    {

        TermDepositInfo storage info = _termDeposits[term];
        require(info.duration > 0, "should be a valid term");
        info.depositDeadline = newDepositDeadline;
    }

    function updateReferralBonusLockTime(uint256 newTime) public onlyWhitelistAdmin {

        referralBonusLockUntil = newTime;
    }

    function calculateTotalPayout(bytes4[] memory terms) public view returns (uint256[3] memory) {

        uint256[3] memory ret;
        for (uint256 i = 0; i < terms.length; i++) {
            TermDepositInfo memory info = _termDeposits[terms[i]];
            require(info.duration > 0, "should be a valid term");
            ret[0] = ret[0].add(info.totalReceived);
            if (_featureFlags.enableInterest) {
                ret[1] = ret[1].add(info.totalReceived.mul(info.interestBp).div(10000));
            }
            if (_featureFlags.enableReferralBonus) {
                ret[2] = ret[2].add(info.totalReferralAmount.mul(info.referralBonusRateBp).div(10000));
            }
        }
        return ret;
    }

    function drainSurplusTokens() external onlyWhitelistAdmin {

        for (uint256 i = 0; i < allTerms.length; i++) {
            bytes4 term = allTerms[i];
            TermDepositInfo memory info = _termDeposits[term];
            require(now > info.depositDeadline, "should pass the deposit deadline");
        }
        emit Drain(msg.sender);

        uint256[3] memory payouts = calculateTotalPayout(allTerms);
        uint256 currentAmount = _token.balanceOf(address(this));
        uint256 neededAmount = payouts[0].add(payouts[1]).add(payouts[2]);
        if (currentAmount > neededAmount) {
            uint256 surplus = currentAmount.sub(neededAmount);
            _token.safeTransfer(msg.sender, surplus);
        }
    }

    function goodbye() external onlyWhitelistAdmin {

        for (uint256 i = 0; i < allTerms.length; i++) {
            bytes4 term = allTerms[i];
            TermDepositInfo memory info = _termDeposits[term];
            require(now > info.depositDeadline, "should pass the deposit deadline");
            require(info.totalReceived < 1000 * 1e18, "should have small enough deposits");
        }
        uint256 tokenAmount = _token.balanceOf(address(this));
        emit Goodbye(msg.sender, tokenAmount);
        if (tokenAmount > 0) {
            _token.safeTransfer(msg.sender, tokenAmount);
        }
        selfdestruct(msg.sender);
    }
}