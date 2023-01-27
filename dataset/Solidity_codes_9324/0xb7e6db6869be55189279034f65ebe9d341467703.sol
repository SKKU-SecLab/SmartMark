pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.5;

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
}pragma solidity ^0.5.0;


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
}pragma solidity ^0.5.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}pragma solidity ^0.5.0;


contract Crowdsale is Context, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private _token;

    address payable private _wallet;

    uint256 private _rate;

    uint256 private _weiRaised;

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    constructor (uint256 rate, address payable wallet, IERC20 token) public {
        require(rate > 0, "Crowdsale: rate is 0");
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");

        _rate = rate;
        _wallet = wallet;
        _token = token;
    }

    function () external payable {
        buyTokens(_msgSender());
    }

    function token() public view returns (IERC20) {

        return _token;
    }

    function wallet() public view returns (address payable) {

        return _wallet;
    }

    function rate() public view returns (uint256) {

        return _rate;
    }

    function weiRaised() public view returns (uint256) {

        return _weiRaised;
    }

    function buyTokens(address beneficiary) public nonReentrant payable {

        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        uint256 tokens = _getTokenAmount(weiAmount);

        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }

    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

    }

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {

        _token.safeTransfer(beneficiary, tokenAmount);
    }

    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {

        _deliverTokens(beneficiary, tokenAmount);
    }

    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {

    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

        return weiAmount.mul(_rate);
    }

    function _forwardFunds() internal {

        _wallet.transfer(msg.value);
    }
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}pragma solidity ^0.5.0;


contract WhitelistAdminRole is Context {

    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(_msgSender());
    }

    modifier onlyWhitelistAdmin() {

        require(isWhitelistAdmin(_msgSender()), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {

        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {

        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {

        _removeWhitelistAdmin(_msgSender());
    }

    function _addWhitelistAdmin(address account) internal {

        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {

        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}pragma solidity ^0.5.0;


contract TimedCrowdsale is Crowdsale, WhitelistAdminRole {

    using SafeMath for uint256;

    uint256 private _openingTime;
    uint256 private _closingTime;

    event TimedCrowdsaleExtended(uint256 prevClosingTime, uint256 newClosingTime);
    event TimedCrowdsaleClosed();

    modifier onlyWhileOpen {

        require(isOpen(), "TimedCrowdsale: not open");
        _;
    }

    constructor (uint256 openingTime, uint256 closingTime) public {
        require(openingTime >= block.timestamp, "TimedCrowdsale: opening time is before current time");
        require(closingTime > openingTime, "TimedCrowdsale: opening time is not before closing time");

        _openingTime = openingTime;
        _closingTime = closingTime;
    }

    function openingTime() public view returns (uint256) {

        return _openingTime;
    }

    function closingTime() public view returns (uint256) {

        return _closingTime;
    }

    function isOpen() public view returns (bool) {

        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    function closeCrowdsale() public onlyWhitelistAdmin {

        require(isOpen(), "TimedCrowdsale: is not open yet");
        _closingTime = block.timestamp;
        emit TimedCrowdsaleClosed();
    }

    function hasClosed() public view returns (bool) {

        return block.timestamp > _closingTime;
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen view {

        super._preValidatePurchase(beneficiary, weiAmount);
    }

    function _extendTime(uint256 newClosingTime) internal {

        require(!hasClosed(), "TimedCrowdsale: already closed");
        require(newClosingTime > _closingTime, "TimedCrowdsale: new closing time is before current closing time");

        emit TimedCrowdsaleExtended(_closingTime, newClosingTime);
        _closingTime = newClosingTime;
    }
}// MIT
pragma solidity ^0.5.0;


contract WithrawableCrowdsale is Crowdsale, WhitelistAdminRole, TimedCrowdsale {

    address public burnAddr = 0x000000000000000000000000000000000000dEaD;

    function _forwardFunds() internal {

    }

    function withdrawETH(uint256 amount) public onlyWhitelistAdmin {

        msg.sender.transfer(amount);
    }

    function burnUnsold(uint256 amount) public onlyWhitelistAdmin {

        require(hasClosed(), "WithrawableCrowdsale: crowdsale is not closed yet");
        require(amount <= token().balanceOf(address(this)), "WithrawableCrowdsale: amount is bigger than tokens left");
        token().transfer(burnAddr, amount);
    }
}// MIT
pragma solidity ^0.5.0;


contract ReferralsCrowdsale is Crowdsale, WhitelistAdminRole {

    using SafeMath for uint256;

    uint private _percent = 10;
    uint private _increasedPercent = 20;
    uint256 private _increaseThreshold = 20 ether;
    uint256 private _cap;
    uint256 private _totalEarned;

    bool public referralsEnabled = false;

    struct Referral {
        address addr; // Who used the referral
        address referrer;
        uint256 earned; // How much tokens earned
        bool isActive;
    }

    struct Referrer {
        address addr; // The referral address, used by others to associate with it
        uint percent;
        uint256 earnedTokens; // Total tokens earned
        uint256 earnedEth; // accumulated 10% from all referral purchases
        uint num; // Total referrals
        address[] addresses; // Keys for the map
        mapping(address => ReferrerRef) earnings; // Referral -> earned
    }

    struct ReferrerRef {
        address addr;
        uint256 earned;
        uint256 earnedEth;
        uint timestamp;
    }

    mapping(address => Referrer) private _referrers;
    mapping(address => Referral) private _referrals;

    event ReferralEarned(address indexed beneficiary, address indexed from, uint256 amount);
    event ReferralActive(address indexed beneficiary, bool isActive);
    event NotEnoughReferralFunds(uint256 tried, uint256 remaining);

    function refTokensRemaining() public view returns (uint256) {

        return _cap.sub(_totalEarned);
    }

    function setReferrerPercent(address referrer, uint percent) public onlyWhitelistAdmin {

        require(percent > 0, "ReferralsCrowdsale: percent is zero");
        _referrers[referrer].percent = percent;
    }

    function setReferralsCap(uint256 cap) public onlyWhitelistAdmin {

        require(cap > 0, "ReferralsCrowdsale: cap is zero");
        require(cap > _totalEarned, "ReferralsCrowdsale: cap is less than already earned");
        _cap = cap;
    }

    function enableReferrals() public onlyWhitelistAdmin {

        referralsEnabled = true;
    }

    function disableReferrals() public onlyWhitelistAdmin {

        referralsEnabled = false;
    }

    function getReferralStats(address addr) public view returns (address, bool, address, uint, uint256) {

        Referral storage ref = _referrals[addr];
        uint percent = ref.isActive ? _percent : 0;

        return (ref.addr, ref.isActive, ref.referrer, percent, ref.earned);
    }

    function buyTokensWithReferral(address beneficiary, address referral) public payable {

        require(referralsEnabled == true, "ReferralsCrowdsale: referrals are disabled");
        require(_cap > 0, "ReferralsCrowdsale: cap is not set");
        require(referral != address(0), "ReferralsCrowdsale: referral is the zero address");
        require(referral != msg.sender, "ReferralsCrowdsale: referral can't be the sender address");

        Referral storage userReferral = _referrals[msg.sender];
        if (!userReferral.isActive || referral != userReferral.referrer) {
            userReferral.addr = msg.sender;
            userReferral.referrer = referral;
            userReferral.isActive = true;

            emit ReferralActive(msg.sender, userReferral.isActive);
        }

        buyTokens(beneficiary);
    }

    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {

        super._updatePurchasingState(beneficiary, weiAmount);

        if (!referralsEnabled) {
            return;
        }

        Referral storage currentReferral = _referrals[msg.sender];
        if (!currentReferral.isActive) {
            return;
        }

        Referrer storage referrer = _referrers[currentReferral.referrer];
        referrer.percent = referrer.percent > 0 ? referrer.percent : _percent;

        uint256 amount = _getTokenAmount(weiAmount);
        uint256 referralBonus = amount.mul(_percent).div(100);

        uint256 referrerBonusEth = weiAmount.mul(referrer.percent).div(100);
        uint256 referrerBonus = _getTokenAmount(referrerBonusEth);

        uint256 totalBonus = referralBonus.add(referrerBonus);

        if (totalBonus > _cap.sub(_totalEarned)) {
            emit NotEnoughReferralFunds(totalBonus, _cap.sub(_totalEarned));
            return;
        }
        _totalEarned = _totalEarned.add(totalBonus);

        currentReferral.earned = currentReferral.earned.add(referralBonus);

        if (referrer.earnings[msg.sender].addr == address(0)) {
            referrer.addr = currentReferral.referrer;
            referrer.addresses.push(msg.sender);
            referrer.num += 1;
        }

        referrer.earnedTokens = referrer.earnedTokens.add(referrerBonus);
        referrer.earnedEth = referrer.earnedEth.add(referrerBonusEth);
        if (referrer.earnedEth > _increaseThreshold) {
            referrer.percent = _increasedPercent;
        }
        _referrers[currentReferral.referrer] = referrer;

        ReferrerRef storage referrerRef = referrer.earnings[msg.sender];
        referrerRef.addr = msg.sender;
        referrerRef.earned = referrerRef.earned.add(referrerBonus);
        referrerRef.earnedEth = referrerRef.earnedEth.add(referrerBonusEth);
        referrerRef.timestamp = block.timestamp;
        _referrers[currentReferral.referrer].earnings[msg.sender] = referrerRef;

        _processPurchase(msg.sender, referralBonus);
        emit ReferralEarned(msg.sender, currentReferral.referrer, referralBonus);

        _processPurchase(referrer.addr, referrerBonus);
        emit ReferralEarned(referrer.addr, msg.sender, referrerBonus);
    }

    function getReferrerStats(address referrer) public view
    returns (
        uint,
        uint,
        uint256,
        uint256,
        uint[] memory,
        address[] memory,
        uint256[] memory,
        uint256[] memory
    ) {

        Referrer storage state = _referrers[referrer];
        uint percent = state.percent > 0 ? state.percent : _percent;

        address[] memory addrs = new address[](state.num);
        uint256[] memory earnedTokens = new uint256[](state.num);
        uint256[] memory earnedEth = new uint256[](state.num);
        uint[] memory timestamps = new uint[](state.num);

        for (uint i = 0; i < state.num; i++) {
            address refAddr = state.addresses[i];
            ReferrerRef storage ref = state.earnings[refAddr];
            addrs[i] = ref.addr;
            earnedTokens[i] = ref.earned;
            earnedEth[i] = ref.earnedEth;
            timestamps[i] = ref.timestamp;
        }

        return (state.num, percent, state.earnedTokens, state.earnedEth, timestamps, addrs, earnedTokens, earnedEth);
    }
}// MIT
pragma solidity ^0.5.0;


contract IndividualCrowdsale is Crowdsale {

    using SafeMath for uint256;

    mapping(address => uint256) private _contributions;
    uint public contributorsCount;

    uint256 public individualCap = 50e18;

    function getContribution(address beneficiary) public view returns (uint256) {

        return _contributions[beneficiary];
    }

    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {

        super._updatePurchasingState(beneficiary, weiAmount);

        if (_contributions[beneficiary] == 0) {
            contributorsCount += 1;
        }

        _contributions[beneficiary] = _contributions[beneficiary].add(weiAmount);

        require(_contributions[beneficiary] < individualCap, "IndividualCrowdsale: contributions cap is reached");
    }
}// MIT
pragma solidity ^0.5.0;


contract WhitelistCrowdsale is Crowdsale, WhitelistAdminRole {

    address public whitelister;
    bool public whitelistEnabled = true;

    constructor(address _whitelister) public {
        whitelister = _whitelister;
    }

    function isWhitelisted(address _address) external view returns (bool) {

    	return IWhitelister(whitelister).whitelisted(_address);
    }

    function validateWhitelisted(address beneficiary) internal view returns (bool) {

        return !whitelistEnabled || this.isWhitelisted(beneficiary);
    }

    function toggleWhitelistEnabled() external onlyWhitelistAdmin {

        whitelistEnabled = !whitelistEnabled;
    }
}

interface IWhitelister {

    function whitelisted(address _address) external view returns (bool);

}// MIT
pragma solidity ^0.5.0;


contract RoundsCrowdsale is Crowdsale, WhitelistAdminRole, TimedCrowdsale, WhitelistCrowdsale {

    using SafeMath for uint256;

    struct Round {
        bool isOpen;
        uint n;
        uint256 rate;
        uint bonusPercent;
        uint contributors;
        uint256 raised;
        uint256 tokensLeft;
    }

    uint256 public contributionCap = 20 ether;
    uint public currentRound;

    uint256 constant _roundTokensLeftThreshold = 80 ether;

    uint private _roundsCount;
    mapping(uint => Round) private _rounds;
    mapping(address => mapping(uint => uint256)) private _contributions;

    event RoundOpened(uint n);
    event RoundBonusEarned(address beneficiary, uint256 amount);

    constructor(uint roundsCount, uint256 cap, uint256 initRate, uint256 rateDecrement) public {
        require(roundsCount > 0, "RoundsCrowdsale: roundsCount is 0");
        require(cap > 0, "RoundsCrowdsale: cap is 0");

        _roundsCount = roundsCount;

        uint[2] memory bonuses = [uint(10), 5];

        for (uint i = 0; i < _roundsCount; i++) {
            _rounds[i].tokensLeft = cap;
            _rounds[i].rate = initRate.sub(rateDecrement.mul(i));
            _rounds[i].bonusPercent = bonuses[i];
        }

        currentRound = 0;
        _rounds[currentRound].isOpen = super.isOpen();
    }

    function isOpen() public view returns (bool) {

        bool crowdsaleIsOpen = super.isOpen();
        bool roundIsOpen = _rounds[currentRound].isOpen || (crowdsaleIsOpen && currentRound == 0);
        return crowdsaleIsOpen && roundIsOpen;
    }

    function closeRound() public onlyWhitelistAdmin {

        _rounds[currentRound].isOpen = false;
        if (currentRound < _roundsCount - 1) {
            currentRound += 1;
            _rounds[currentRound].isOpen = true;
            emit RoundOpened(currentRound);
        }
    }

    function openRound(uint n) public onlyWhitelistAdmin {

        _rounds[currentRound].isOpen = false;
        _rounds[n].isOpen = true;
    }

    function rate() public view returns (uint256) {

        revert("IncreasingPriceCrowdsale: rate() called");
    }

    function getRoundsContributions(address beneficiary) public view returns (uint256[] memory) {

        uint256[] memory contributions = new uint256[](_roundsCount);
        for (uint i = 0; i < _roundsCount; i++) {
            contributions[i] = _contributions[beneficiary][i];
        }

        return contributions;
    }

    function getCurrentRate() public view returns (uint256) {

        if (!isOpen()) {
            return 0;
        }

        return _rounds[currentRound].rate;
    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

        uint256 currentRate = getCurrentRate();
        return currentRate.mul(weiAmount);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen view {

        super._preValidatePurchase(beneficiary, weiAmount);

        if (currentRound == 0) {
            require(validateWhitelisted(beneficiary) == true, 'RoundsCrowdsale: first round is only for whitelisted addresses');
        }

        Round storage round = _rounds[currentRound];
        uint256 tokens = _getTokenAmount(weiAmount);
        uint256 bonusTokens = round.bonusPercent > 0 ? tokens.mul(round.bonusPercent).div(100) : 0;

        require(tokens.add(bonusTokens) <= round.tokensLeft, "RoundsCrowdsale: round cap exceeded");
    }

    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {

        super._updatePurchasingState(beneficiary, weiAmount);

        if (currentRound == 0 && !_rounds[currentRound].isOpen && super.isOpen()) {
            _rounds[currentRound].isOpen = true;
        }

        Round storage round = _rounds[currentRound];
        round.raised = round.raised.add(weiAmount);

        uint256 tokens = _getTokenAmount(weiAmount);

        if (_contributions[msg.sender][currentRound] == 0) {
            round.contributors += 1;
        }

        _contributions[msg.sender][currentRound] = _contributions[msg.sender][currentRound].add(weiAmount);
        require(_contributions[msg.sender][currentRound] < contributionCap, "RoundsCrowdsale: individual contributions cap exceeded");

        uint256 bonusTokens = 0;
        if (round.bonusPercent > 0) {
            bonusTokens = tokens.mul(round.bonusPercent).div(100);
            _processPurchase(msg.sender, bonusTokens);
            emit RoundBonusEarned(msg.sender, bonusTokens);
        }

        round.tokensLeft = round.tokensLeft.sub(tokens).sub(bonusTokens);
        if (round.tokensLeft <= _roundTokensLeftThreshold) {
            round.isOpen = false;
        }

        if (!round.isOpen && currentRound < _roundsCount - 1) {
            currentRound += 1;
            _rounds[currentRound].isOpen = true;

            emit RoundOpened(currentRound);
        }
    }

    function getRounds() public view
    returns (
        uint[] memory,
        bool[] memory,
        uint256[] memory,
        uint[] memory,
        uint[] memory,
        uint256[] memory,
        uint256[] memory
    ) {

        uint[] memory n = new uint[](_roundsCount);
        bool[] memory openings = new bool[](_roundsCount);
        uint256[] memory rates = new uint256[](_roundsCount);
        uint[] memory bonuses = new uint[](_roundsCount);
        uint[] memory contributors = new uint[](_roundsCount);
        uint256[] memory raised = new uint256[](_roundsCount);
        uint256[] memory tokensLeft = new uint256[](_roundsCount);

        for (uint i = 0; i < _roundsCount; i++) {
            Round storage round = _rounds[i];
            n[i] = i;
            openings[i] = super.isOpen() && round.isOpen;
            rates[i] = round.rate;
            bonuses[i] = round.bonusPercent;
            contributors[i] = round.contributors;
            raised[i] = round.raised;
            tokensLeft[i] = round.tokensLeft;
        }

        return (n, openings, rates, bonuses, contributors, raised, tokensLeft);
    }
}pragma solidity ^0.5.0;

contract Secondary is Context {

    address private _primary;

    event PrimaryTransferred(
        address recipient
    );

    constructor () internal {
        address msgSender = _msgSender();
        _primary = msgSender;
        emit PrimaryTransferred(msgSender);
    }

    modifier onlyPrimary() {

        require(_msgSender() == _primary, "Secondary: caller is not the primary account");
        _;
    }

    function primary() public view returns (address) {

        return _primary;
    }

    function transferPrimary(address recipient) public onlyPrimary {

        require(recipient != address(0), "Secondary: new primary is the zero address");
        _primary = recipient;
        emit PrimaryTransferred(recipient);
    }
}pragma solidity ^0.5.0;


contract PostDeliveryCrowdsale is WhitelistAdminRole, TimedCrowdsale {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    __unstable__TokenVault private _vault;

    constructor() public {
        _vault = new __unstable__TokenVault();
    }

    function withdrawTokens(address beneficiary) public {

        require(hasClosed(), "PostDeliveryCrowdsale: not closed");
        uint256 amount = _balances[beneficiary];
        require(amount > 0, "PostDeliveryCrowdsale: beneficiary is not due any tokens");

        _balances[beneficiary] = 0;
        _vault.transfer(token(), beneficiary, amount);
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function getVaultAddress() public view onlyWhitelistAdmin returns (address) {

        return address(_vault);
    }

    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {

        _balances[beneficiary] = _balances[beneficiary].add(tokenAmount);
        _deliverTokens(address(_vault), tokenAmount);
    }
}

contract __unstable__TokenVault is Secondary {

    function transfer(IERC20 token, address to, uint256 amount) public onlyPrimary {

        token.transfer(to, amount);
    }
}// MIT
pragma solidity ^0.5.0;


contract MinMaxCrowdsale is Crowdsale, WhitelistAdminRole {

    using SafeMath for uint256;

    uint256 private _minContribution = 1e17;
    uint256 private _maxContribution = 10e18;

    function getContributionLimits() public view returns (uint256, uint256) {

        return (_minContribution, _maxContribution);
    }

    function setMinContribution(uint256 min) public onlyWhitelistAdmin {

        require(min > 0, 'MinMaxCrowdsale: min is 0');
        require(_maxContribution > min, 'MinMaxCrowdsale: max is less than min');
        _minContribution = min;
    }

    function setMaxContribution(uint256 max) public onlyWhitelistAdmin {

        require(max > 0, 'MinMaxCrowdsale: max is 0');
        require(max > _minContribution, 'MinMaxCrowdsale: max is less than min');
        _maxContribution = max;
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        super._preValidatePurchase(beneficiary, weiAmount);
        require(weiAmount >= _minContribution, "MinMaxCrowdsale: weiAmount is less than allowed minimum");
        require(weiAmount <= _maxContribution, "MinMaxCrowdsale: weiAmount is bigger than allowed maximum");
    }
}// MIT
pragma solidity ^0.5.0;


contract BoostCrowdsale is
Ownable,
Crowdsale,
WhitelistAdminRole,
TimedCrowdsale,
WhitelistCrowdsale,
WithrawableCrowdsale,
MinMaxCrowdsale,
PostDeliveryCrowdsale,
RoundsCrowdsale,
ReferralsCrowdsale,
IndividualCrowdsale
{

    using SafeMath for uint256;

    uint constant ROUNDS = 2;
    uint256 constant ROUND_CAP = 300000 ether;
    uint256 constant INIT_RATE = 650;
    uint256 constant RATE_DECREMENT = 150;

    constructor(
        IERC20 token,
        uint256 openingTime,
        uint256 closingTime,
        address whitelister
    )
    Crowdsale(INIT_RATE, msg.sender, token)
    WhitelistCrowdsale(whitelister)
    RoundsCrowdsale(ROUNDS, ROUND_CAP, INIT_RATE, RATE_DECREMENT)
    TimedCrowdsale(openingTime, closingTime)
    public {}
}