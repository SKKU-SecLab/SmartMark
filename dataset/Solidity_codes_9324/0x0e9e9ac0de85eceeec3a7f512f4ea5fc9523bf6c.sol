

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
}


pragma solidity ^0.5.0;




contract WhitelistedRole is Context, WhitelistAdminRole {

    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {

        require(isWhitelisted(_msgSender()), "WhitelistedRole: caller does not have the Whitelisted role");
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {

        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {

        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {

        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {

        _removeWhitelisted(_msgSender());
    }

    function _addWhitelisted(address account) internal {

        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {

        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}


pragma solidity 0.5.11;




contract WhitelistExtension is Ownable, WhitelistedRole {


    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    modifier whenNotPaused() {

        require(!_paused, "paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "not paused");
        _;
    }

    constructor() public {
        _paused = false;
    }

    function pause() public onlyWhitelistAdmin whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyWhitelistAdmin whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }

    function updateWhitelistedAdmins(
        address[] calldata admins,
        bool isAdd
    )
        external onlyOwner
    {

        for(uint256 i = 0; i < admins.length; i++) {
            if (isAdd) {
                if (!isWhitelistAdmin(admins[i])) _addWhitelistAdmin(admins[i]);
            } else {
                if (isWhitelistAdmin(admins[i])) _removeWhitelistAdmin(admins[i]);
            }
        }
    }

    function updateWhitelistedUsers(
        address[] calldata users,
        bool isAdd
    )
        external onlyWhitelistAdmin 
    {

        for(uint256 i = 0; i < users.length; i++) {
            if (isAdd) {
                if (!isWhitelisted(users[i])) _addWhitelisted(users[i]);
            } else {
                if (isWhitelisted(users[i])) _removeWhitelisted(users[i]);
            }
        }
    }

    function isPaused() external view returns (bool) {

        return _paused;
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
}


pragma solidity ^0.5.0;



contract TimedCrowdsale is Crowdsale {

    using SafeMath for uint256;

    uint256 private _openingTime;
    uint256 private _closingTime;

    event TimedCrowdsaleExtended(uint256 prevClosingTime, uint256 newClosingTime);

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
}


pragma solidity ^0.5.0;



contract FinalizableCrowdsale is TimedCrowdsale {

    using SafeMath for uint256;

    bool private _finalized;

    event CrowdsaleFinalized();

    constructor () internal {
        _finalized = false;
    }

    function finalized() public view returns (bool) {

        return _finalized;
    }

    function finalize() public {

        require(!_finalized, "FinalizableCrowdsale: already finalized");
        require(hasClosed(), "FinalizableCrowdsale: not closed");

        _finalized = true;

        _finalization();
        emit CrowdsaleFinalized();
    }

    function _finalization() internal {

    }
}


pragma solidity 0.5.11;







contract SeedSwap is WhitelistExtension, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeMath for uint80;

    IERC20  public constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    uint256 public constant MAX_UINT_80 = 2**79 - 1;
    uint256 public constant HARD_CAP = 320 ether;
    uint256 public constant MIN_INDIVIDUAL_CAP = 1 ether;
    uint256 public constant MAX_INDIVIDUAL_CAP = 10 ether;
    uint256 public constant WITHDRAWAL_DEADLINE = 180 days;
    uint256 public constant SAFE_DISTRIBUTE_NUMBER = 150; // safe to distribute to 150 users at once
    uint256 public constant DISTRIBUTE_PERIOD_UNIT = 1 days;

    IERC20  public saleToken;
    uint256 public saleStartTime = 1609693200;  // 00:00:00, 4 Jan 2021 GMT+7
    uint256 public saleEndTime = 1610384340;    // 23:59:00, 11 Jan 2021 GMT+7
    uint256 public saleRate = 25000;            // 1 eth = 25,000 token

    address payable public ethRecipient;
    struct TotalSwappedData {
        uint128 eAmount;
        uint128 tAmount;
    }
    TotalSwappedData public totalData;
    uint256 public totalDistributedToken = 0;

    struct SwapData {
        address user;
        uint80 eAmount; // eth amount
        uint80 tAmount; // token amount
        uint80 dAmount; // distributed token amount
        uint16 daysID;
    }

    SwapData[] public listSwaps;

    mapping(address => uint256[]) public userSwapData;
    mapping(address => address) public userTokenRecipient;

    event SwappedEthToTea(
        address indexed trader,
        uint256 indexed ethAmount,
        uint256 indexed teaAmount,
        uint256 blockTimestamp,
        uint16 daysID
    );
    event UpdateSaleTimes(
        uint256 indexed newStartTime,
        uint256 newEndTime
    );
    event UpdateSaleRate(uint256 indexed newSaleRate);
    event UpdateEthRecipient(address indexed newRecipient);
    event Distributed(
        address indexed user,
        address indexed recipient,
        uint256 dAmount,
        uint256 indexed percentage,
        uint256 timestamp
    );
    event SelfWithdrawToken(
        address indexed sender,
        address indexed recipient,
        uint256 indexed dAmount,
        uint256 timestamp
    );
    event EmergencyOwnerWithdraw(
        address indexed sender,
        IERC20 indexed token,
        uint256 amount
    );
    event UpdatedTokenRecipient(
        address user,
        address recipient
    );

    modifier whenNotStarted() {

        require(block.timestamp < saleStartTime, "already started");
        _;
    }

    modifier whenNotEnded() {

        require(block.timestamp <= saleEndTime, "already ended");
        _;
    }

    modifier whenEnded() {

        require(block.timestamp > saleEndTime, "not ended yet");
        _;
    }

    modifier onlyValidPercentage(uint256 percentage) {

        require(0 < percentage && percentage <= 100, "percentage out of range");
        _;
    }

    modifier onlyCanSwap(uint256 ethAmount) {

        require(ethAmount > 0, "onlyCanSwap: amount is 0");
        uint256 timestamp = block.timestamp;
        require(timestamp >= saleStartTime, "onlyCanSwap: not started yet");
        require(timestamp <= saleEndTime, "onlyCanSwap: already ended");
        require(totalData.eAmount < HARD_CAP, "onlyCanSwap: HARD_CAP reached");
        address sender = msg.sender;
        require(isWhitelisted(sender), "onlyCanSwap: sender is not whitelisted");
        (uint80 userEthAmount, ,) = _getUserSwappedAmount(sender);
        uint256 totalEthAmount = ethAmount.add(uint256(userEthAmount));
        require(
            totalEthAmount >= MIN_INDIVIDUAL_CAP,
            "onlyCanSwap: eth amount is lower than min individual cap"
        );
        require(
            totalEthAmount <= MAX_INDIVIDUAL_CAP,
            "onlyCapSwap: max individual cap reached"
        );
        _;
    }

    constructor(address payable _owner, IERC20 _token) public {
        require(_token != IERC20(0), "constructor: invalid token");
        assert(saleStartTime < saleEndTime);

        saleToken = _token;
        ethRecipient = _owner;

        if (msg.sender != _owner) {
            _addWhitelistAdmin(_owner);
            transferOwnership(_owner);
        }
    }

    function () external payable {
        swapEthToToken();
    }


    function updateSaleTimes(uint256 _newStartTime, uint256 _newEndTime)
        external whenNotStarted onlyOwner
    {

        if (_newStartTime != 0) saleStartTime = _newStartTime;
        if (_newEndTime != 0) saleEndTime = _newEndTime;
        require(saleStartTime < saleEndTime, "Times: invalid start and end time");
        require(block.timestamp < saleStartTime, "Times: invalid start time");
        emit UpdateSaleTimes(saleStartTime, saleEndTime);
    }

    function updateSaleRate(uint256 _newsaleRate)
        external whenNotEnded onlyOwner
    {

        require(
            _newsaleRate < MAX_UINT_80 / MAX_INDIVIDUAL_CAP,
            "Rates: new rate is out of range"
        );
        require(_newsaleRate >= saleRate / 2, "Rates: new rate too low");
        require(_newsaleRate <= saleRate * 3 / 2, "Rates: new rate too high");

        saleRate = _newsaleRate;
        emit UpdateSaleRate(_newsaleRate);
    }

    function updateEthRecipientAddress(address payable _newRecipient)
        external onlyOwner
    {

        require(_newRecipient != address(0), "Receipient: invalid eth recipient address");
        ethRecipient = _newRecipient;
        emit UpdateEthRecipient(_newRecipient);
    }

    function swapEthToToken()
        public payable
        nonReentrant
        whenNotPaused
        onlyCanSwap(msg.value)
        returns (uint256 tokenAmount)
    {

        address sender = msg.sender;
        uint256 ethAmount = msg.value;
        tokenAmount = _getTokenAmount(ethAmount);

        uint256 daysID = (block.timestamp - saleStartTime) / DISTRIBUTE_PERIOD_UNIT;
        assert(daysID < 2**16); // should have only few days for presale
        SwapData memory _swapData = SwapData({
            user: sender,
            eAmount: uint80(ethAmount),
            tAmount: uint80(tokenAmount),
            dAmount: uint80(0),
            daysID: uint16(daysID)
        });
        listSwaps.push(_swapData);
        userSwapData[sender].push(listSwaps.length - 1);

        TotalSwappedData memory swappedData = totalData;
        totalData = TotalSwappedData({
            eAmount: swappedData.eAmount + uint128(ethAmount),
            tAmount: swappedData.tAmount + uint128(tokenAmount)
        });

        ethRecipient.transfer(ethAmount);

        emit SwappedEthToTea(sender, ethAmount, tokenAmount, block.timestamp, uint16(daysID));
    }


    function distributeAll(uint256 percentage, uint16 daysID)
        external onlyWhitelistAdmin whenEnded whenNotPaused onlyValidPercentage(percentage)
        returns (uint256 totalAmount)
    {

        for(uint256 i = 0; i < listSwaps.length; i++) {
            if (listSwaps[i].daysID == daysID) {
                totalAmount += _distributedToken(i, percentage);
            }
        }
        totalDistributedToken = totalDistributedToken.add(totalAmount);
    }

    function distributeBatch(uint256 percentage, uint256[] calldata ids)
        external onlyWhitelistAdmin whenEnded whenNotPaused onlyValidPercentage(percentage)
        returns (uint256 totalAmount)
    {

        uint256 len = listSwaps.length;
        for(uint256 i = 0; i < ids.length; i++) {
            require(ids[i] < len, "Distribute: invalid id");
            if (i > 0) require(ids[i - 1] < ids[i], "Distribute: indices are not in order");
            totalAmount += _distributedToken(ids[i], percentage);
        }
        totalDistributedToken = totalDistributedToken.add(totalAmount);
    }


    function selfWithdrawToken() external returns (uint256 tokenAmount) {

        require(
            block.timestamp > WITHDRAWAL_DEADLINE + saleEndTime,
            "Emergency: not open for emergency withdrawal"
        );
        address sender = msg.sender;
        (, uint80 tAmount, uint80 dAmount) = _getUserSwappedAmount(sender);
        tokenAmount = tAmount.sub(dAmount);
        require(tokenAmount > 0, "Emergency: user has claimed all tokens");
        require(
            tokenAmount <= saleToken.balanceOf(address(this)),
            "Emergency: not enough token to distribute"
        );

        uint256[] memory ids = userSwapData[sender];
        for(uint256 i = 0; i < ids.length; i++) {
            assert(listSwaps[ids[i]].user == sender);
            listSwaps[ids[i]].dAmount = listSwaps[ids[i]].tAmount;
        }
        totalDistributedToken = totalDistributedToken.add(tokenAmount);
        address recipient = _transferToken(sender, tokenAmount);
        emit SelfWithdrawToken(sender, recipient, tokenAmount, block.timestamp);
    }

    function emergencyOwnerWithdraw(IERC20 token, uint256 amount) external onlyOwner {

        if (token == ETH_ADDRESS) {
            msg.sender.transfer(amount);
        } else {
            token.safeTransfer(msg.sender, amount);
        }
        emit EmergencyOwnerWithdraw(msg.sender, token, amount);
    }

    function updateUserTokenRecipient(address user, address recipient) external onlyOwner {

        require(recipient != address(0), "invalid recipient");
        userTokenRecipient[user] = recipient;
        emit UpdatedTokenRecipient(user, recipient);
    }

    function getNumberSwaps() external view returns (uint256) {

        return listSwaps.length;
    }

    function getAllSwaps()
        external view
        returns (
            address[] memory users,
            uint80[] memory ethAmounts,
            uint80[] memory tokenAmounts,
            uint80[] memory distributedAmounts,
            uint16[] memory daysIDs
        )
    {

        uint256 len = listSwaps.length;
        users = new address[](len);
        ethAmounts = new uint80[](len);
        tokenAmounts = new uint80[](len);
        distributedAmounts = new uint80[](len);
        daysIDs = new uint16[](len);

        for(uint256 i = 0; i < len; i++) {
            SwapData memory data = listSwaps[i];
            users[i] = data.user;
            ethAmounts[i] = data.eAmount;
            tokenAmounts[i] = data.tAmount;
            distributedAmounts[i] = data.dAmount;
            daysIDs[i] = data.daysID;
        }
    }

    function getUserSwapData(address user)
        external view 
        returns (
            address tokenRecipient,
            uint256 totalEthAmount,
            uint80 totalTokenAmount,
            uint80 distributedAmount,
            uint80 remainingAmount,
            uint80[] memory ethAmounts,
            uint80[] memory tokenAmounts,
            uint80[] memory distributedAmounts,
            uint16[] memory daysIDs
        )
    {

        tokenRecipient = _getRecipient(user);
        (totalEthAmount, totalTokenAmount, distributedAmount) = _getUserSwappedAmount(user);
        remainingAmount = totalTokenAmount - distributedAmount;

        uint256[] memory swapDataIDs = userSwapData[user];
        ethAmounts = new uint80[](swapDataIDs.length);
        tokenAmounts = new uint80[](swapDataIDs.length);
        distributedAmounts = new uint80[](swapDataIDs.length);
        daysIDs = new uint16[](swapDataIDs.length);

        for(uint256 i = 0; i < swapDataIDs.length; i++) {
            ethAmounts[i] = listSwaps[swapDataIDs[i]].eAmount;
            tokenAmounts[i] = listSwaps[swapDataIDs[i]].tAmount;
            distributedAmounts[i] = listSwaps[swapDataIDs[i]].dAmount;
            daysIDs[i] = listSwaps[swapDataIDs[i]].daysID;
        }
    }

    function getData()
        external view
        returns(
            uint256 _startTime,
            uint256 _endTime,
            uint256 _rate,
            address _ethRecipient,
            uint128 _tAmount,
            uint128 _eAmount,
            uint256 _hardcap
        )
    {

        _startTime = saleStartTime;
        _endTime = saleEndTime;
        _rate = saleRate;
        _ethRecipient = ethRecipient;
        _tAmount = totalData.tAmount;
        _eAmount = totalData.eAmount;
        _hardcap = HARD_CAP;
    }

    function estimateDistributedAllData(
        uint80 percentage,
        uint16 daysID
    )
        external view
        whenEnded
        whenNotPaused
        onlyValidPercentage(percentage)
        returns(
            bool isSafe,
            uint256 totalUsers,
            uint256 totalDistributingAmount,
            uint256[] memory selectedIds,
            address[] memory users,
            address[] memory recipients,
            uint80[] memory distributingAmounts,
            uint16[] memory daysIDs
        )
    {

        totalUsers = 0;
        for(uint256 i = 0; i < listSwaps.length; i++) {
            if (listSwaps[i].daysID == daysID && listSwaps[i].tAmount > listSwaps[i].dAmount) {
                totalUsers += 1;
            }
        }

        selectedIds = new uint256[](totalUsers);
        users = new address[](totalUsers);
        recipients = new address[](totalUsers);
        distributingAmounts = new uint80[](totalUsers);
        daysIDs = new uint16[](totalUsers);

        uint256 counter = 0;
        for(uint256 i = 0; i < listSwaps.length; i++) {
            SwapData memory data = listSwaps[i];
            if (listSwaps[i].daysID == daysID && listSwaps[i].tAmount > listSwaps[i].dAmount) {
                selectedIds[counter] = i;
                users[counter] = data.user;
                recipients[counter] = _getRecipient(data.user);
                distributingAmounts[counter] = data.tAmount * percentage / 100;
                require(
                    distributingAmounts[counter] + data.dAmount <= data.tAmount,
                    "Estimate: total distribute more than 100%"
                );
                daysIDs[counter] = listSwaps[i].daysID;
                totalDistributingAmount += distributingAmounts[counter];
                counter += 1;
            }
        }
        require(
            totalDistributingAmount <= saleToken.balanceOf(address(this)),
            "Estimate: not enough token balance"
        );
        isSafe = totalUsers <= SAFE_DISTRIBUTE_NUMBER;
    }

    function estimateDistributedBatchData(
        uint80 percentage,
        uint256[] calldata ids
    )
        external view
        whenEnded
        whenNotPaused
        onlyValidPercentage(percentage)
        returns(
            bool isSafe,
            uint256 totalUsers,
            uint256 totalDistributingAmount,
            uint256[] memory selectedIds,
            address[] memory users,
            address[] memory recipients,
            uint80[] memory distributingAmounts,
            uint16[] memory daysIDs
        )
    {

        totalUsers = 0;
        for(uint256 i = 0; i < ids.length; i++) {
            require(ids[i] < listSwaps.length, "Estimate: id out of range");
            if (i > 0) require(ids[i] > ids[i - 1], "Estimate: duplicated ids");
            if (listSwaps[i].tAmount > listSwaps[i].dAmount) totalUsers += 1;
        }
        selectedIds = new uint256[](totalUsers);
        users = new address[](totalUsers);
        recipients = new address[](totalUsers);
        distributingAmounts = new uint80[](totalUsers);
        daysIDs = new uint16[](totalUsers);

        uint256 counter = 0;
        for(uint256 i = 0; i < ids.length; i++) {
            if (listSwaps[i].tAmount <= listSwaps[i].dAmount) continue;
            SwapData memory data = listSwaps[ids[i]];
            selectedIds[counter] = ids[i];
            users[counter] = data.user;
            recipients[counter] = _getRecipient(data.user);
            distributingAmounts[counter] = data.tAmount * percentage / 100;
            require(
                distributingAmounts[counter] + data.dAmount <= data.tAmount,
                "Estimate: total distribute more than 100%"
            );
            totalDistributingAmount += distributingAmounts[counter];
            daysIDs[counter] = listSwaps[i].daysID;
            counter += 1;
        }
        require(
            totalDistributingAmount <= saleToken.balanceOf(address(this)),
            "Estimate: not enough token balance"
        );
        isSafe = totalUsers <= SAFE_DISTRIBUTE_NUMBER;
    }

    function _distributedToken(uint256 id, uint256 percentage)
        internal
        returns (uint256 distributingAmount)
    {

        SwapData memory data = listSwaps[id];
        distributingAmount = uint256(data.tAmount).mul(percentage).div(100);
        require(
            distributingAmount.add(data.dAmount) <= data.tAmount,
            "Distribute: total distribute more than 100%"
        );
        assert (distributingAmount > 0);
        require(
            distributingAmount <= saleToken.balanceOf(address(this)),
            "Distribute: not enough token to distribute"
        );
        listSwaps[id].dAmount += uint80(distributingAmount);
        address recipient = _transferToken(data.user, distributingAmount);
        emit Distributed(data.user, recipient, distributingAmount, percentage, block.timestamp);
    }

    function _transferToken(address user, uint256 amount) internal returns (address recipient) {

        recipient = _getRecipient(user);
        assert(recipient != address(0));
        saleToken.safeTransfer(recipient, amount);
    }

    function _getRecipient(address user) internal view returns(address recipient) {

        recipient = userTokenRecipient[user];
        if (recipient == address(0)) {
            recipient = user;
        }
    }

    function _getTokenAmount(uint256 ethAmount) internal view returns (uint256) {

        return ethAmount.mul(saleRate);
    }

    function _getUserSwappedAmount(address sender)
        internal view returns(
            uint80 eAmount,
            uint80 tAmount,
            uint80 dAmount
        )
    {

        uint256[] memory ids = userSwapData[sender];
        for(uint256 i = 0; i < ids.length; i++) {
            SwapData memory data = listSwaps[ids[i]];
            eAmount += data.eAmount;
            tAmount += data.tAmount;
            dAmount += data.dAmount;
        }
    }
}