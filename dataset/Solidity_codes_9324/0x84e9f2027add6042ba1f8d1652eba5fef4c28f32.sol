

pragma solidity ^0.5.0;

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
}


pragma solidity ^0.5.0;

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
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.5;

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
}


pragma solidity ^0.5.0;




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
}


pragma solidity ^0.5.0;

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
}


pragma solidity ^0.5.0;






contract Crowdsale is Context, ReentrancyGuard {

    modifier onlyHuman {

        if (_isHuman()) {
            _;
        }
    }

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private _token;

    address payable private _platformWallet;
    address payable private _priceTokenBackingWallet;
    address payable private _investBoxWallet;
    address payable private _otherWallet;

    uint256 private _rate;

    uint256 private _weiRaised;

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    constructor (
        address payable platformWallet,
        address payable priceTokenBackingWallet,
        address payable investBoxWallet,
        address payable otherWallet,
        IERC20 token
    )
    public
    {
        require(platformWallet != address(0), "Crowdsale: platformWallet is the zero address");
        require(priceTokenBackingWallet != address(0), "Crowdsale: priceTokenBackingWallet is the zero address");
        require(investBoxWallet != address(0), "Crowdsale: investBoxWallet is the zero address");
        require(otherWallet != address(0), "Crowdsale: otherWallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");

        _platformWallet = platformWallet;
        _priceTokenBackingWallet = priceTokenBackingWallet;
        _investBoxWallet = investBoxWallet;
        _otherWallet = otherWallet;
        _token = token;
    }

    function () external onlyHuman payable {
        buyTokens(_msgSender());
    }

    function _isContract() view internal returns(bool) {

        return msg.sender != tx.origin;
    }

    function _isHuman() view internal returns(bool) {

        return !_isContract();
    }

    function token() public view returns (IERC20) {

        return _token;
    }

    function platformWallet() public view returns (address payable) {

        return _platformWallet;
    }

    function rate() public view returns (uint256) {

        return _rate;
    }

    function setRate(uint256 stageRate) internal {

        _rate = stageRate;
    }

    function weiRaised() public view returns (uint256) {

        return _weiRaised;
    }

    function buyTokens(address beneficiary) public nonReentrant onlyHuman payable {

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

    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal {

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

        uint256 sum = msg.value;
        uint256 platformSum = sum.div(100).mul(25);
        uint256 backingSum = sum.div(100).mul(7);
        uint256 investBoxSum = sum.div(100).mul(10);
        uint256 buyoutSum = sum.div(100).mul(20);
        uint256 otherSum = sum.sub(platformSum).sub(backingSum).sub(investBoxSum).sub(buyoutSum);

        _platformWallet.transfer(platformSum);
        _priceTokenBackingWallet.transfer(backingSum);
        _investBoxWallet.transfer(investBoxSum);
        _otherWallet.transfer(otherSum);
    }
}


pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;



contract StatCrowdsale is Crowdsale {

    struct partDist {   // A structural unit indicating whether the address to which this unit belongs is involved in the distribution of unsold tokens at each stage
        uint256 sumWei;     // the amount of wei spent by the address in the stage
        uint256 sumHpa;     // the amount of tokens acquired by the address at the stage
        bool part;          // true if the address is involved in the distribution of unsold tokens
    }

    struct stageStat {          // Stage statistics unit
        uint256 tokensSold;         // The number of tokens sold at the stage
        uint256 numPurchases;       // Number of purchases per stage
        uint256 tokensUnsold;       // The number of unsold tokens at the stage
        uint256 numBuyersDist;      // The number of participants in the distribution of unsold tokens at the stage
        mapping (address => partDist) partsDist;    // indicates whether the address is involved in the distribution of unsold tokens at each stage
        uint256 start;              // Stage Start Time (in timestamp)
        uint256 end;                // Stage End Time (in timestamp)
    }

    struct buyerStat {              //Buyer Statistics unit
        buyerReferral[] referrals;      // Array of referral addresses for this customer
        uint256 numReferrals;           // Number of customer referrals
        mapping (uint256 => bool) stagesPartDist;   // Stages in which a given buyer is involved in the distribution of unsold tokens
        purchase[] purchases;           // Purchase statistics
        uint256 numPurchases;           // Number of purchases
    }

    struct buyerReferral {      // The structural unit of statistics on referrals for the buyer
        address referral;           // Referral Address
        uint256 referralSum;        // The amount of tokens brought by a referral
        uint256 referralEth;        // The amount of ether (in wei) that the referral brought
    }

    struct purchase {       // Purchase Statistics Unit
        uint256 stage;          // Stage at which the purchase was made
        uint256 price;          // The price for the token at which the purchase was made
        uint256 sumEth;         // Amount of spent ether (in wei)
        uint256 sumHpa;         // Amount of purchased tokens
        uint256 time;           // Purchase time
    }

    stageStat[15] internal _stagesStats;
    mapping (address => buyerStat) internal buyersStats;

    constructor () public {
        setStageStat(0,0,0,0,0);
        setStageStat(1,0,0,50000 ether,0);
        setStageStat(2,0,0,500000 ether,0);
        setStageStat(3,0,0,2500000 ether,0);
        setStageStat(4,0,0,7500000 ether,0);
        setStageStat(5,0,0,15000000 ether,0);
        setStageStat(6,0,0,22500000 ether,0);
        setStageStat(7,0,0,10000000 ether,0);
        setStageStat(8,0,0,5000000 ether,0);
        setStageStat(9,0,0,3000000 ether,0);
        setStageStat(10,0,0,1000000 ether,0);
        setStageStat(11,0,0,500004 ether,0);
        setStageStat(12,0,0,200004 ether,0);
        setStageStat(13,0,0,100002 ether,0);
        setStageStat(14,0,0,50000 ether,0);
    }

    function setStageStat(
        uint256 stageNumber,
        uint256 tokensSold,
        uint256 numPurchases,
        uint256 tokensUnsold,
        uint256 numBuyersDist
    )
    internal
    {

        _stagesStats[stageNumber] = stageStat({
            tokensSold: tokensSold,
            numPurchases: numPurchases,
            tokensUnsold: tokensUnsold,
            numBuyersDist: numBuyersDist,
            start: 0,
            end: 0
            });
    }

    function viewStageStat(uint256 s) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {

        stageStat memory _stat = _stagesStats[s];
        return (_stat.tokensSold, _stat.numPurchases, _stat.tokensUnsold, _stat.numBuyersDist, _stat.start, _stat.end);
    }

    function setStageStartTime(uint256 stageNumber, uint256 time) internal {

        _stagesStats[stageNumber].start = time;
    }

    function setStageEndTime(uint256 stageNumber, uint256 time) internal {

        _stagesStats[stageNumber].end = time;
    }

    function addReferralStat(address referer, address referral, uint256 sum, uint256 sumEth) internal {

        buyersStats[referer].referrals.push(buyerReferral({
            referral: referral,
            referralSum: sum,
            referralEth: sumEth
            }));
        buyersStats[referer].numReferrals = buyersStats[referer].numReferrals.add(1);
    }

    function getBuyerStagePartDistInfo(uint256 stage, address buyer) public view returns (uint256, uint256, bool) {

        return (
        _stagesStats[stage].partsDist[buyer].sumWei,
        _stagesStats[stage].partsDist[buyer].sumHpa,
        _stagesStats[stage].partsDist[buyer].part
        );
    }

    function getMyInfo() public view returns (uint256, buyerReferral[] memory, uint256, purchase[] memory) {

        address buyer = msg.sender;
        return (
        buyersStats[buyer].numReferrals,
        buyersStats[buyer].referrals,
        buyersStats[buyer].numPurchases,
        buyersStats[buyer].purchases
        );
    }
}


pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}


pragma solidity ^0.5.0;

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
}


pragma solidity ^0.5.0;



contract MinterRole is Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}


pragma solidity ^0.5.0;



contract ERC20Mintable is ERC20, MinterRole {

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }
}


pragma solidity ^0.5.0;



contract MintedCrowdsale is Crowdsale {

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {

        require(
            ERC20Mintable(address(token())).mint(beneficiary, tokenAmount),
            "MintedCrowdsale: minting failed"
        );
    }
}


pragma solidity ^0.5.0;




contract ReferralCrowdsale is StatCrowdsale, MintedCrowdsale {

    uint256 private _refPercent;

    constructor (uint256 startPercent) public {
        require(startPercent > 0, "ReferralCrowdsale: percentage must be greater than zero");

        _refPercent = startPercent;
    }

    function refPercent() public view returns (uint256) {

        return _refPercent;
    }

    function setRefPercent(uint256 stageRefPercent) internal {

        _refPercent = stageRefPercent;
    }

    function bytesToAddress(bytes memory source) internal pure returns(address) {

        uint result;
        uint mul = 1;
        for(uint i = 20; i > 0; i--) {
            result += uint8(source[i-1])*mul;
            mul = mul*256;
        }
        return address(result);
    }

    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal {


        uint256 tokens = _getTokenAmount(weiAmount);

        if(msg.data.length == 20) {
            address referer = bytesToAddress(bytes(msg.data));
            address payable refererPayable = address(uint160(referer));
            require(referer != beneficiary, "Referral crowdsale: The beneficiary cannot be a referer");
            require(referer != msg.sender, "Referral crowdsale: The sender cannot be a referer");
            require(referer != address(0), "Referral crowdsale: referer is the zero address");
            uint refererTokens = tokens.mul(_refPercent).div(100);
            uint256 refSum = weiAmount.div(100).mul(10);
            emit TokensPurchased(_msgSender(), beneficiary, 0, refererTokens);
            addReferralStat(referer, beneficiary, refererTokens, refSum);
            _deliverTokens(referer, refererTokens);
            refererPayable.transfer(refSum);
        }
    }
}


pragma solidity ^0.5.0;




contract StagesCrowdsale is ReferralCrowdsale, Ownable {

    using SafeMath for uint256;

    uint256 private _currentStage;

    struct stage {                  // Structural Unit of Stage Parameters
        uint256 rate;
        uint256 cap;
        uint256 refPercent;
        uint256 unsoldDistPercent;
        uint256 minEthDist;
        uint256 minHpaDist;
        uint256 period;
    }

    stage[15] internal _stages;

    event CloseStage(uint256 stage, uint256 time);
    event OpenStage(uint256 stage, uint256 time);

    constructor () public ReferralCrowdsale(5) {
        setStage(0,0,0,0,0,0,0,0);
        setStage(1,100000000,500 szabo,5,0,0,0,0);
        setStage(2,10000000,50500 szabo,5,0,0,0,0);
        setStage(3,1000000,2550500 szabo,7,0,0,0,0);
        setStage(4,100000,77550500 szabo,10,0,0,0,0);
        setStage(5,10000,1577550500 szabo,15,0,0,0,0);
        setStage(6,1000,24077550500 szabo,20,0,0,0,0);
        setStage(7,200,74077550500 szabo,25,0,0,0,10 days);
        setStage(8,100,124077550500 szabo,30,3,10 ether,1000 ether,10 days);
        setStage(9,50,184077550500 szabo,35,5,7 ether,350 ether,10 days);
        setStage(10,25,224077550500 szabo,40,7,5 ether,125 ether,10 days);
        setStage(11,12,265744550500 szabo,45,10,3 ether,36 ether,10 days);
        setStage(12,6,299078550500 szabo,50,15,2 ether,12 ether,10 days);
        setStage(13,3,332412550500 szabo,70,20,1 ether,3 ether,10 days);
        setStage(14,2,357412550500 szabo,100,40,200 finney,400 finney,10 days);

        _currentStage = 1;
        setRefPercent(_stages[_currentStage].refPercent);
        setRate(_stages[_currentStage].rate);
        setStageStartTime(_currentStage, now);
    }

    function currentStage() public view returns (uint256) {

        return _currentStage;
    }

    function setStage(
        uint256 stageNumber,
        uint256 rate,
        uint256 cap,
        uint256 refPercent,
        uint256 unsoldDistPercent,
        uint256 minEthDist,
        uint256 minHpaDist,
        uint256 period
    )
    internal
    {

        _stages[stageNumber] = stage({
            rate: rate,
            cap: cap,
            refPercent: refPercent,
            unsoldDistPercent: unsoldDistPercent,
            minEthDist: minEthDist,
            minHpaDist: minHpaDist,
            period: period
            });
    }

    function remStageTime() public view returns (uint256) {

        if (_stages[_currentStage].period > 0) {
            return _stages[_currentStage].period - (now - _stagesStats[_currentStage].start);
        } else {
            return 0;
        }
    }

    function closeCurrentStage() internal {

        emit CloseStage(_currentStage, now);
        setStageEndTime(_currentStage, now);
    }

    function openNewStage() internal {

        _currentStage = _currentStage.add(1);
        setRefPercent(_stages[_currentStage].refPercent);
        setRate(_stages[_currentStage].rate);
        emit OpenStage(_currentStage, now);
        setStageStartTime(_currentStage, now);
    }

    function viewStage(uint256 s) public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {

        stage memory _stage = _stages[s];
        return (_stage.rate, _stage.cap, _stage.refPercent, _stage.unsoldDistPercent, _stage.minEthDist, _stage.minHpaDist, _stage.period);
    }

    function stageCapReached() public view returns (bool) {

        return weiRaised() >= _stages[_currentStage].cap;
    }

    function stageTiming(uint256 stageNumber) public view returns (uint256, uint256) {

        return (_stagesStats[stageNumber].start, _stagesStats[stageNumber].end);
    }

    function isOpen() public view returns (bool) {

        uint256 numStages = _stages.length.sub(1);
        if (_currentStage == numStages) {
            if (_stagesStats[_currentStage].end > 0) {
                return false;
            }
            if (_stages[_currentStage].period > 0) {
                if (_stagesStats[_currentStage].start + _stages[_currentStage].period <= now) {
                    return false;
                }
            }
            if (weiRaised() == _stages[_currentStage].cap) {
                return false;
            }
        }
        return true;
    }

    function hasClosed() public view returns (bool) {

        return !isOpen();
    }

    function checkEndStage() internal returns (bool) {

        if (_stagesStats[_currentStage].end > 0) {
            return true;
        }
        if (_stages[_currentStage].period > 0) {
            if (_stagesStats[_currentStage].start + _stages[_currentStage].period <= now) {
                closeCurrentStage();
                return true;
            }
        }
        if (weiRaised() == _stages[_currentStage].cap) {
            closeCurrentStage();
            return true;
        }
        return false;
    }

    function manualyCloseCurrentStage() public onlyOwner returns (bool) {

        if (checkEndStage()) {
            if (isOpen()) {
                openNewStage();
            }
            return true;
        }
        return false;
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        super._preValidatePurchase(beneficiary, weiAmount);
        require(isOpen(), "StagesCrowdsale: Final stage completed. Crowdsale already closed");
        require(weiRaised().add(weiAmount) <= _stages[_currentStage].cap, "StagesCrowdsale: stage cap exceeded");
        require(weiAmount <= _stages[_currentStage].cap.div(5), "StagesCrowdsale: cannot buy more than 20% stage cap");
    }

    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal {

        super._postValidatePurchase(beneficiary, weiAmount);
        if (checkEndStage()) {
            if (isOpen()) {
                openNewStage();
            }
        }
    }

    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {

        super._updatePurchasingState(beneficiary, weiAmount);
        uint256 tokens = _getTokenAmount(weiAmount);
        setCurrentStageStat(beneficiary, weiAmount, tokens);
        setPurchaseStat(beneficiary, weiAmount, tokens);
    }

    function setCurrentStageStat(address beneficiary, uint256 weiAmount, uint256 tokens) internal {

        _stagesStats[_currentStage].tokensSold = _stagesStats[_currentStage].tokensSold.add(tokens);
        _stagesStats[_currentStage].numPurchases = _stagesStats[_currentStage].numPurchases.add(1);
        _stagesStats[_currentStage].tokensUnsold = _stagesStats[_currentStage].tokensUnsold.sub(tokens);
        if (_stages[_currentStage].unsoldDistPercent > 0) {
            _stagesStats[_currentStage].partsDist[beneficiary].sumWei = _stagesStats[_currentStage].partsDist[beneficiary].sumWei.add(weiAmount);
            _stagesStats[_currentStage].partsDist[beneficiary].sumHpa = _stagesStats[_currentStage].partsDist[beneficiary].sumHpa.add(tokens);
            if (
                _stagesStats[_currentStage].partsDist[beneficiary].sumWei >= _stages[_currentStage].minEthDist &&
                _stagesStats[_currentStage].partsDist[beneficiary].sumHpa >= _stages[_currentStage].minHpaDist
            ) {
                if (!_stagesStats[_currentStage].partsDist[beneficiary].part) {
                    _stagesStats[_currentStage].numBuyersDist = _stagesStats[_currentStage].numBuyersDist.add(1);
                }
                _stagesStats[_currentStage].partsDist[beneficiary].part = true;
                buyersStats[beneficiary].stagesPartDist[_currentStage] = true;
            }
        }
    }

    function setPurchaseStat(address beneficiary, uint256 weiAmount, uint256 tokens) internal {

        uint256 hpa = 1 ether;
        uint256 price = hpa.div(rate());
        buyersStats[beneficiary].purchases.push(purchase({
            stage: _currentStage,
            price: price,
            sumEth: weiAmount,
            sumHpa: tokens,
            time: now
            }));
        buyersStats[beneficiary].numPurchases = buyersStats[beneficiary].numPurchases.add(1);
    }

    function getThisBalance() public view returns (uint256) {

        return address(this).balance;
    }
}


pragma solidity ^0.5.0;



contract DistCrowdsale is StagesCrowdsale {

    uint256 private _unsoldTokens;  // Total unsold tokens
    uint256 private _numStages;     // Total number of stages
    uint256 private _distTokens;    // Total number of tokens received during distribution (requested tokens)
    bool private _calcDone = false; // Have tokens been calculated for distribution?

    struct stagesUnsoldTokens {     // A structural unit containing information on the distribution of unsold tokens by stages
        uint256 stage;                  // The stage for which information is contained in the structural unit
        uint256 percent;                // The percentage of allocated unsold tokens for distribution at this stage
        uint256 stageUnsoldTokens;      // Unsold tokens at this stage
        uint256 distTokens;             // The number of tokens allocated to each participant who has fulfilled the requirement to receive unsold tokens
    }

    mapping (uint256 => stagesUnsoldTokens) _stagesDistTokens;
    mapping (address => uint256) collectedUnsoldTokens;

    event DistCalculation(uint256 unsoldTokens, uint256 time);

    constructor () public {
        _numStages = _stages.length.sub(1);
    }

    function viewStageDistTokens(uint256 s) public view returns (uint256, uint256, uint256) {

        stagesUnsoldTokens memory _dist = _stagesDistTokens[s];
        return (_dist.percent, _dist.stageUnsoldTokens, _dist.distTokens);
    }

    function getDistTokens() public view returns(uint) {

        return _distTokens;
    }

    function getUnsoldTokens() public view returns(uint) {

        return _unsoldTokens;
    }

    function getBuyerCollectedUnsoldTokens(address buyer) public view returns (uint256) {

        return collectedUnsoldTokens[buyer];
    }

    function sumUnsoldTokens() internal {

        require(hasClosed(), "DistCrowdsale: Crowdsale not complete");
        uint256 unsoldTokens;
        for (uint256 i = 1; i <= _numStages; i++) {
            unsoldTokens = unsoldTokens.add(_stagesStats[i].tokensUnsold);
            _stagesDistTokens[i].percent = _stages[i].unsoldDistPercent;
        }
        _unsoldTokens = unsoldTokens;
    }

    function calcDistUnsoldTokens() internal {

        require(hasClosed(), "DistCrowdsale: Crowdsale not complete");
        require(_unsoldTokens > 0, "DistCrowdsale: The number of unsold tokens should not be zero");
        for (uint256 i = 1; i <= _numStages; i++) {
            if (_stages[i].unsoldDistPercent > 0) {
                _stagesDistTokens[i].stage = i;
                _stagesDistTokens[i].stageUnsoldTokens = _unsoldTokens.div(100).mul(_stagesDistTokens[i].percent);
                if (_stagesStats[i].numBuyersDist > 0) {
                    _stagesDistTokens[i].distTokens = _stagesDistTokens[i].stageUnsoldTokens.div(_stagesStats[i].numBuyersDist);
                }
            }
        }
    }

    function distCalc() external onlyHuman {

        require(hasClosed(), "DistCrowdsale: Crowdsale not complete");
        require(!_calcDone, "DistCrowdsale: Calculation complete");
        sumUnsoldTokens();
        emit DistCalculation(_unsoldTokens, now);
        calcDistUnsoldTokens();
        _calcDone = true;
    }

    function withdrawalUnsoldTokens(address beneficiary) external onlyHuman {

        require(hasClosed(), "DistCrowdsale: Crowdsale not complete");
        require(_calcDone, "DistCrowdsale: Calculation not complete");
        uint256 tokensSend = 0;
        for (uint256 i = 1; i <= _numStages; i++) {
            if (buyersStats[beneficiary].stagesPartDist[i]) {
                tokensSend = tokensSend.add(_stagesDistTokens[i].distTokens);
                buyersStats[beneficiary].stagesPartDist[i] = false;
            }
        }
        _distTokens = _distTokens.add(tokensSend);
        collectedUnsoldTokens[beneficiary] = tokensSend;

        emit TokensPurchased(_msgSender(), beneficiary, 0, tokensSend);
        _processPurchase(beneficiary, tokensSend);
    }
}


pragma solidity ^0.5.0;



contract BuybackCrowdsale is DistCrowdsale {

    uint256 private _buybackBalance;    // ETH balance for redemption of tokens
    uint256 private _buybackPrice;      // Token buyback price
    uint256 private _timeCalc;          // Price calculation time

    uint256 private _timeBuybackEnd;

    address private _burnAddress;       // Address for burning purchased tokens
    bool private _calcDone = false;     // The parameter determining whether the price was calculated

    struct buyerBuyback {       // The structure of accounting statistics of token buyback operations
        address beneficiary;        // ETH receiving address
        uint256 tokenAmount;        // Token Amount
        uint256 price;              // Calculated Token Buyback Price
        uint256 sumEther;           // Amount ETH
        uint256 time;               // Operation time
    }

    mapping (address => buyerBuyback[]) buyersBuybacks;

    event BuybackCalculation(uint256 buybackBalance, uint256 buybackPrice, uint256 timeCalc, uint256 timeBuybackEnd);

    event Buyback(address indexed beneficiary, uint256 amount, uint256 sumEther, uint256 time);

    event Withdrawal(address indexed ownerAddress, uint256 amount, uint256 time);

    constructor (address burnAddress) public {
        _timeBuybackEnd = 180 days;
        _burnAddress = burnAddress;
    }

    function getBuybackBalance() public view returns (uint256) {

        return _buybackBalance;
    }

    function getBuybackPrice() public view returns (uint256) {

        return _buybackPrice;
    }

    function getTimeCalc() public view returns (uint256) {

        return _timeCalc;
    }

    function getTimeBuyback() public view returns (uint256) {

        return _timeBuybackEnd;
    }

    function getBuyerBuybacks(address buyer) public view returns (buyerBuyback[] memory) {

        return buyersBuybacks[buyer];
    }

    function buybackCalc() external onlyHuman {

        require(hasClosed(), "BuybackCrowdsale: Crowdsale not complete");
        require(!_calcDone, "BuybackCrowdsale: Calculation complete");
        _buybackBalance = address(this).balance;
        require(_buybackBalance > 0, "BuybackCrowdsale: Contract ETH should not be zero");
        _buybackPrice = _buybackBalance.div(token().totalSupply().div(10 ether));
        _calcDone = true;
        _timeCalc = now;
        emit BuybackCalculation(_buybackBalance, _buybackPrice, _timeCalc, _timeCalc.add(_timeBuybackEnd));
    }

    function buyback(address payable beneficiary, uint256 hpaAmount) external onlyHuman {

        require(hasClosed(), "BuybackCrowdsale: Crowdsale not complete");
        require(_calcDone, "BuybackCrowdsale: Calculation not complete");
        require(address(this).balance > 0, "BuybackCrowdsale: Contract ETH should not be zero");
        require(beneficiary != address(0), "BuybackCrowdsale: Beneficiary is the zero address");
        require(hpaAmount >= 1 ether, "BuybackCrowdsale: You must specify at least one token");
        require(token().balanceOf(beneficiary) >= hpaAmount, "BuybackCrowdsale: Missing HPA token amount");

        uint256 sumEther = hpaAmount.div(1 ether).mul(_buybackPrice);
        require(address(this).balance >= sumEther, "BuybackCrowdsale: There is not enough ether on the contract for this transaction. Specify fewer tokens");
        buyersBuybacks[msg.sender].push(buyerBuyback({
            beneficiary: beneficiary,
            tokenAmount: hpaAmount,
            price: _buybackPrice,
            sumEther: sumEther,
            time: now
            }));
        _buybackBalance = _buybackBalance.sub(sumEther);
        emit Buyback(beneficiary, hpaAmount, sumEther, now);
        token().transferFrom(msg.sender, _burnAddress, hpaAmount);
        beneficiary.transfer(sumEther);
    }

    function withdrawal(address payable ownerAddress) external onlyOwner {

        require(hasClosed(), "BuybackCrowdsale: Crowdsale not complete");
        require(_calcDone, "BuybackCrowdsale: Calculation not complete");
        require(now > _timeCalc.add(_timeBuybackEnd), "BuybackCrowdsale: Buyback not complete");
        require(ownerAddress != address(0), "BuybackCrowdsale: ownerAddress is the zero address");

        emit Withdrawal(ownerAddress, address(this).balance, now);
        ownerAddress.transfer(address(this).balance);
    }
}


pragma solidity ^0.5.0;


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


pragma solidity ^0.5.0;



contract HighlyProfitableAnonymousToken is ERC20Mintable, ERC20Detailed {

    constructor () public ERC20Detailed("Highly Profitable Anonymous Token", "HPA", 18) {
    }
}


pragma solidity ^0.5.0;




contract HpaCrowdsale is BuybackCrowdsale {

    uint256 private _platformTokens = 100000; // Tokens issued for the needs of the platform

    uint256 private _withdrawalTokensTime = 30 days;
    address payable initPlatformWallet = 0x4B536E67f532ea3129881266eC8B1D562D7B89E8;
    address payable initPriceTokenBackingWallet = 0x4830121fb404b279D8354D99468D723bcaf69702;
    address payable initInvestBoxWallet = 0x0Ee5bb8371A2605Fe5D46a915650CDDb745372cf;
    address payable initOtherWallet = 0x0450080ba40cb9c27326304749064cd628E967E5;
    address initBurnAddress = 0x0000000000000000000000000000000000000001;

    constructor ()
    public
    Crowdsale(
        initPlatformWallet,
        initPriceTokenBackingWallet,
        initInvestBoxWallet,
        initOtherWallet,
        new  HighlyProfitableAnonymousToken()
    )
    BuybackCrowdsale(initBurnAddress)
    {
        uint256 tokenAmount = _platformTokens.mul(1 ether);
        emit TokensPurchased(_msgSender(), address(this), 0, tokenAmount);
        _processPurchase(address(this), tokenAmount);
    }

    function withdrawalPlatformTokens(address payable ownerAddress) external onlyOwner {

        require(hasClosed(), "HpaCrowdsale: Crowdsale not complete");
        require(now > _stagesStats[14].end.add(_withdrawalTokensTime), "HpaCrowdsale: Please wait");
        require(ownerAddress != address(0), "HpaCrowdsale: ownerAddress is the zero address");

        token().transfer(ownerAddress, _platformTokens.mul(1 ether));
    }
}