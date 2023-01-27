
pragma solidity 0.7.6;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: ETH transfer failed');
    }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function decimals() external view returns (uint8);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    
 
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity 0.7.6;

abstract contract Ownable is Context {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}// MIT
pragma solidity 0.7.6;

contract Metadata {

    struct TokenMetadata {
        address routerAddress;
        string imageUrl;
        bool isAdded;
    }

    mapping(address => TokenMetadata) public tokenMeta;

    function updateMeta(
        address _tokenAddress,
        address _routerAddress,
        string memory _imageUrl
    ) internal {

        if (_tokenAddress != address(0)) {
            tokenMeta[_tokenAddress] = TokenMetadata({
                routerAddress: _routerAddress,
                imageUrl: _imageUrl,
                isAdded: true
            });
        }
    }

    function updateMetaURL(address _tokenAddress, string memory _imageUrl)
        internal
    {

        TokenMetadata storage meta = tokenMeta[_tokenAddress];
        require(meta.isAdded, "Invalid token address");

        meta.imageUrl = _imageUrl;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity 0.7.6;


contract Crowdsale is ReentrancyGuard, Ownable, Metadata {

    using SafeMath for uint256;

    IERC20 public token;

    uint256 public tokenRemainingForSale;

    mapping(address => bool) public validInputToken;

    mapping(address => uint256) public inputTokenRate;

    IERC20[] private inputToken;

    uint256 public vestingStart;

    uint256 public crowdsaleStartTime;

    uint256 public crowdsaleEndTime;

    uint256 public vestingEnd;

    uint256 public crowdsaleTokenAllocated;

    uint256 public cliffDuration;

    uint256 public maxUserAllocation;

    mapping(address => uint256) public vestedAmount;

    mapping(address => uint256) public totalDrawn;

    mapping(address => uint256) public lastDrawnAt;

    mapping(address => bool) public whitelistedAddress;

    bool public whitelistingEnabled;

    bool public initialized;

    event TokenPurchase(
        address indexed investor,
        uint256 investedAmount,
        uint256 indexed tokenPurchased,
        IERC20 indexed inputToken,
        uint256 tokenRemaining
    );

    event DrawDown(
        address indexed _investor,
        uint256 _amount,
        uint256 indexed drawnTime
    );

    event CrowdsaleEndedManually(uint256 indexed crowdsaleEndedManuallyAt);

    event FundsWithdrawn(
        address indexed beneficiary,
        IERC20 indexed _token,
        uint256 amount
    );

    event Whitelisted(address[] user);

    event MaxAllocationUpdated(uint256 indexed newAllocation);

    event URLUpdated(string _tokenUrl);

    event TokenRateUpdated(address inputToken, uint256 rate);

    event WhitelistingEnabled();

    constructor() {
        initialized = true;
    }

    function init(bytes memory _encodedData) external {

        require(initialized == false, "Contract already initialized");
        IERC20[] memory inputTokens;
        bytes memory _crowdsaleTimings;
        bytes memory _whitelist;
        uint256[] memory _rate;
        string memory tokenURL;
        (
            token,
            crowdsaleTokenAllocated,
            inputTokens,
            _rate,
            _crowdsaleTimings
        ) = abi.decode(
            _encodedData,
            (IERC20, uint256, IERC20[], uint256[], bytes)
        );

        (, , , , , _whitelist, owner, tokenURL) = abi.decode(
            _encodedData,
            (
                IERC20,
                uint256,
                IERC20[],
                uint256[],
                bytes,
                bytes,
                address,
                string
            )
        );

        TransferHelper.safeTransferFrom(
            address(token),
            msg.sender,
            address(this),
            crowdsaleTokenAllocated
        );

        updateMeta(address(token), address(0), tokenURL);
        for (uint256 i = 0; i < inputTokens.length; i++) {
            inputToken.push(inputTokens[i]);
            validInputToken[address(inputTokens[i])] = true;
            inputTokenRate[address(inputTokens[i])] = _rate[i];
            updateMeta(address(inputTokens[i]), address(0), "");
        }
        (
            crowdsaleStartTime,
            crowdsaleEndTime,
            vestingStart,
            vestingEnd,
            cliffDuration
        ) = abi.decode(
            _crowdsaleTimings,
            (uint128, uint128, uint128, uint128, uint128)
        );

        tokenRemainingForSale = crowdsaleTokenAllocated;
        address[] memory _whitelistedAddress;
        (whitelistingEnabled, _whitelistedAddress) = abi.decode(
            _whitelist,
            (bool, address[])
        );
        if (_whitelistedAddress.length > 0 && whitelistingEnabled) {
            whitelistUsers(_whitelistedAddress);
        }

        initialized = true;
    }

    modifier isCrowdsaleOver() {

        require(
            _getNow() >= crowdsaleEndTime && crowdsaleEndTime != 0,
            "Crowdsale Not Ended Yet"
        );
        _;
    }

    function updateTokenURL(address tokenAddress, string memory _url)
        external
        onlyOwner
    {

        updateMetaURL(tokenAddress, _url);
        emit URLUpdated(_url);
    }

    function updateInputTokenRate(address _inputToken, uint256 _rate)
        external
        onlyOwner
    {

        require(
            _getNow() < crowdsaleStartTime,
            "Cannot update token rate after crowdsale is started"
        );

        inputTokenRate[_inputToken] = _rate;

        emit TokenRateUpdated(_inputToken, _rate);
    }

    function purchaseToken(IERC20 _inputToken, uint256 _inputTokenAmount)
        external
    {

        if (whitelistingEnabled) {
            require(whitelistedAddress[msg.sender], "User is not whitelisted");
        }
        require(_getNow() >= crowdsaleStartTime, "Crowdsale isnt started yet");
        require(
            validInputToken[address(_inputToken)],
            "Unsupported Input token"
        );
        if (crowdsaleEndTime != 0) {
            require(_getNow() < crowdsaleEndTime, "Crowdsale Ended");
        }

        uint8 inputTokenDecimals = _inputToken.decimals();
        uint256 tokenPurchased = inputTokenDecimals >= 18
            ? _inputTokenAmount.mul(inputTokenRate[address(_inputToken)]).mul(
                10**(inputTokenDecimals - 18)
            )
            : _inputTokenAmount.mul(inputTokenRate[address(_inputToken)]).mul(
                10**(18 - inputTokenDecimals)
            );

        uint8 tokenDecimal = token.decimals();
        tokenPurchased = tokenDecimal >= 36
            ? tokenPurchased.mul(10**(tokenDecimal - 36))
            : tokenPurchased.div(10**(36 - tokenDecimal));

        if (maxUserAllocation != 0)
            require(
                vestedAmount[msg.sender].add(tokenPurchased) <=
                    maxUserAllocation,
                "User Exceeds personal hardcap"
            );

        require(
            tokenPurchased <= tokenRemainingForSale,
            "Exceeding purchase amount"
        );

        TransferHelper.safeTransferFrom(
            address(_inputToken),
            msg.sender,
            address(this),
            _inputTokenAmount
        );

        tokenRemainingForSale = tokenRemainingForSale.sub(tokenPurchased);
        _updateVestingSchedule(msg.sender, tokenPurchased);

        emit TokenPurchase(
            msg.sender,
            _inputTokenAmount,
            tokenPurchased,
            _inputToken,
            tokenRemainingForSale
        );
    }

    function _updateVestingSchedule(address _investor, uint256 _amount)
        internal
    {

        require(_investor != address(0), "Beneficiary cannot be empty");
        require(_amount > 0, "Amount cannot be empty");

        vestedAmount[_investor] = vestedAmount[_investor].add(_amount);
    }

    function vestingScheduleForBeneficiary(address _investor)
        external
        view
        returns (
            uint256 _amount,
            uint256 _totalDrawn,
            uint256 _lastDrawnAt,
            uint256 _remainingBalance,
            uint256 _availableForDrawDown
        )
    {

        return (
            vestedAmount[_investor],
            totalDrawn[_investor],
            lastDrawnAt[_investor],
            vestedAmount[_investor].sub(totalDrawn[_investor]),
            _availableDrawDownAmount(_investor)
        );
    }

    function availableDrawDownAmount(address _investor)
        external
        view
        returns (uint256 _amount)
    {

        return _availableDrawDownAmount(_investor);
    }

    function _availableDrawDownAmount(address _investor)
        internal
        view
        returns (uint256 _amount)
    {

        if (_getNow() <= vestingStart.add(cliffDuration) || vestingStart == 0) {
            return 0;
        }

        if (_getNow() > vestingEnd) {
            return vestedAmount[_investor].sub(totalDrawn[_investor]);
        }


        uint256 timeLastDrawnOrStart = lastDrawnAt[_investor] == 0
            ? vestingStart
            : lastDrawnAt[_investor];

        uint256 timePassedSinceLastInvocation = _getNow().sub(
            timeLastDrawnOrStart
        );

        uint256 drawDownRate = (vestedAmount[_investor].mul(1e18)).div(
            vestingEnd.sub(vestingStart)
        );
        uint256 amount = (timePassedSinceLastInvocation.mul(drawDownRate)).div(
            1e18
        );

        return amount;
    }

    function drawDown() external isCrowdsaleOver nonReentrant {

        _drawDown(msg.sender);
    }

    function _drawDown(address _investor) internal {

        require(
            vestedAmount[_investor] > 0,
            "There is no schedule currently in flight"
        );

        uint256 amount = _availableDrawDownAmount(_investor);
        require(amount > 0, "No allowance left to withdraw");

        lastDrawnAt[_investor] = _getNow();

        totalDrawn[_investor] = totalDrawn[_investor].add(amount);

        require(
            totalDrawn[_investor] <= vestedAmount[_investor],
            "Safety Mechanism - Drawn exceeded Amount Vested"
        );

        TransferHelper.safeTransfer(address(token), _investor, amount);

        emit DrawDown(_investor, amount, _getNow());
    }

    function _getNow() internal view returns (uint256) {

        return block.timestamp;
    }

    function getContractTokenBalance(IERC20 _token)
        public
        view
        returns (uint256)
    {

        return _token.balanceOf(address(this));
    }

    function remainingBalance(address _investor)
        external
        view
        returns (uint256)
    {

        return vestedAmount[_investor].sub(totalDrawn[_investor]);
    }

    function endCrowdsale(
        uint256 _vestingStartTime,
        uint256 _vestingEndTime,
        uint256 _cliffDurationInSecs
    ) external onlyOwner {

        require(
            crowdsaleEndTime == 0,
            "Crowdsale would end automatically after endTime"
        );
        crowdsaleEndTime = _getNow();
        require(
            _vestingStartTime >= crowdsaleEndTime,
            "Start time should >= Crowdsale EndTime"
        );
        require(
            _vestingEndTime > _vestingStartTime.add(_cliffDurationInSecs),
            "End Time should after the cliffPeriod"
        );

        vestingStart = _vestingStartTime;
        vestingEnd = _vestingEndTime;
        cliffDuration = _cliffDurationInSecs;
        if (tokenRemainingForSale != 0) {
            withdrawFunds(token, tokenRemainingForSale); //when crowdsaleEnds withdraw unsold tokens to the owner
        }
        emit CrowdsaleEndedManually(crowdsaleEndTime);
    }

    function withdrawFunds(IERC20 _token, uint256 amount)
        public
        isCrowdsaleOver
        onlyOwner
    {

        require(
            getContractTokenBalance(_token) >= amount,
            "the contract doesnt have tokens"
        );

        TransferHelper.safeTransfer(address(_token), msg.sender, amount);

        emit FundsWithdrawn(msg.sender, _token, amount);
    }

    function enableWhitelisting() external onlyOwner {

        whitelistingEnabled = true;
        emit WhitelistingEnabled();
    }

    function whitelistUsers(address[] memory users) public onlyOwner {

        for (uint256 i = 0; i < users.length; i++) {
            require(whitelistingEnabled, "Whitelisting is not enabled");
            whitelistedAddress[users[i]] = true;
        }
        emit Whitelisted(users);
    }

    function updateMaxUserAllocation(uint256 _maxUserAllocation)
        external
        onlyOwner
    {

        maxUserAllocation = _maxUserAllocation;
        emit MaxAllocationUpdated(_maxUserAllocation);
    }

    function getValidInputTokens() external view returns (IERC20[] memory) {

        return inputToken;
    }
}