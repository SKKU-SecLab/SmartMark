


pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);


  function description() external view returns (string memory);


  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}




pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity ^0.8.0;



library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}




pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



pragma solidity 0.8.4;








contract ExenoTokenIco is
    Ownable,
    Pausable,
    ReentrancyGuard
{

    using SafeERC20 for IERC20;

    uint256 public immutable startDate;

    IERC20 public immutable token;

    AggregatorV3Interface public immutable priceFeed;

    address payable public immutable wallet;

    uint256 public cashRaised;

    uint256 public totalTokensPurchased;

    uint256 public totalBeneficiaries;
    
    mapping(address => uint256) public tokenPurchases;

    mapping(address => uint256) public cashPayments;

    uint256 public preIcoRate;

    uint256 public icoRate;

    uint256 public immutable minCap;

    uint256 public immutable maxCap;

    uint256 public constant PRE_ICO_LIMIT = 50 * 1000 * 1000 ether;

    uint256 public constant TOTAL_ICO_LIMIT = 75 * 1000 * 1000 ether;

    Stage public currentStage;

    enum Stage { PreICO, ICO, PostICO }
    
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint16 indexed saleCode,
        uint256 cashAmount,
        uint256 tokenAmount
    );

    event NextStage(
        Stage previousStage,
        Stage currentStage
    );

    event UpdateRates(
        uint256 newPreIcoRate,
        uint256 newIcoRate
    );

    event ForwardCash(
        uint256 value
    );

    modifier validAddress(address a) {

        require(a != address(0),
            "ExenoTokenIco: address cannot be zero");
        require(a != address(this),
            "ExenoTokenIco: invalid address");
        _;
    }

    constructor(
        IERC20 _token,
        AggregatorV3Interface _priceFeed,
        uint256 _preIcoRate,
        uint256 _icoRate,
        uint256 _minCap,
        uint256 _maxCap,
        address payable _wallet,
        uint256 _startDate
    )
        validAddress(_wallet)
    {
        assert(PRE_ICO_LIMIT < TOTAL_ICO_LIMIT);

        require(_preIcoRate > 0,
            "ExenoTokenIco: _preIcoRate needs to be above zero");
        
        require(_icoRate > _preIcoRate,
            "ExenoTokenIco: _icoRate needs to be above _preIcoRate");
        
        require(_minCap > 0,
            "ExenoTokenIco: _minCap needs to be above zero");

        require(_maxCap > _minCap,
            "ExenoTokenIco: _maxCap needs to be above _minCap");

        require(_startDate >= block.timestamp,
            "ExenoTokenIco: _startDate should be a date in the future");
        
        token = _token;
        priceFeed = _priceFeed;
        preIcoRate = _preIcoRate;
        icoRate = _icoRate;
        minCap = _minCap;
        maxCap = _maxCap;
        wallet = _wallet;
        startDate = _startDate;
        currentStage = Stage.PreICO;
    }

    function _setStage(Stage newStage)
        internal
    {

        emit NextStage(currentStage, newStage);
        currentStage = newStage;
    }

    function _buyTokens(address beneficiary, uint16 saleCode)
        internal whenNotPaused nonReentrant
    {

        require(block.timestamp >= startDate,
            "ExenoTokenIco: sale has not started yet");
        
        require(currentStage == Stage.PreICO || currentStage == Stage.ICO,
            "ExenoTokenIco: buying tokens is only allowed in preICO and ICO");

        if (currentStage == Stage.PreICO) {
            assert(totalTokensPurchased < PRE_ICO_LIMIT);
        } else if (currentStage == Stage.ICO) {
            assert(totalTokensPurchased < TOTAL_ICO_LIMIT);
        }

        uint256 cashAmount = msg.value;
        require(cashAmount > 0,
            "ExenoTokenIco: invalid value");

        (uint256 tokenAmount,) = convertFromCashAmount(cashAmount);

        require(token.balanceOf(wallet) >= tokenAmount,
            "ExenoTokenIco: not enough balance on the wallet account");

        require(token.allowance(wallet, address(this)) >= tokenAmount,
            "ExenoTokenIco: not enough allowance from the wallet account");

        uint256 existingPayment = cashPayments[beneficiary];
        uint256 newPayment = existingPayment + cashAmount;

        uint256 existingPurchase = tokenPurchases[beneficiary];
        uint256 newPurchase = existingPurchase + tokenAmount;

        require(newPurchase >= minCap,
            "ExenoTokenIco: purchase is below min cap");

        require(newPurchase <= maxCap,
            "ExenoTokenIco: purchase is above max cap");

        cashRaised += cashAmount;
        totalTokensPurchased += tokenAmount;

        cashPayments[beneficiary] = newPayment;
        tokenPurchases[beneficiary] = newPurchase;

        if (existingPurchase == 0) {
            totalBeneficiaries += 1;
        }

        token.safeTransferFrom(wallet, beneficiary, tokenAmount);

        emit TokenPurchase(msg.sender, beneficiary, saleCode, cashAmount, tokenAmount);

        if (currentStage == Stage.PreICO
        && totalTokensPurchased >= PRE_ICO_LIMIT) {
            _setStage(Stage.ICO);
        } else if (currentStage == Stage.ICO
        && totalTokensPurchased >= TOTAL_ICO_LIMIT) {
            _setStage(Stage.PostICO);
        }
    }

    receive()
        external payable
    {
        _buyTokens(msg.sender, 0);
    }

    function buyTokens(address beneficiary, uint16 saleCode)
        external payable validAddress(beneficiary)
    {

        _buyTokens(beneficiary, saleCode);
    }

    function pause()
        external onlyOwner
    {

        _pause();
    }

    function unpause()
        external onlyOwner
    {

        _unpause();
    }

    function nextStage()
        external onlyOwner
    {

        require(currentStage == Stage.PreICO || currentStage == Stage.ICO,
            "ExenoTokenIco: changing stage is only allowed in preICO and ICO");

        if (currentStage == Stage.PreICO) {
            _setStage(Stage.ICO);
        } else if (currentStage == Stage.ICO) {
            _setStage(Stage.PostICO);
        }
    }

    function updateRates(uint256 newPreIcoRate, uint256 newIcoRate)
        external onlyOwner
    {

        require(currentStage == Stage.PreICO || currentStage == Stage.ICO,
            "ExenoTokenIco: updating rates is only allowed in preICO and ICO");
        
        require(newPreIcoRate > 0 && newPreIcoRate < newIcoRate,
            "ExenoTokenIco: preICO rate needs to be lower than ICO rate");
        
        preIcoRate = newPreIcoRate;
        icoRate = newIcoRate;
        emit UpdateRates(newPreIcoRate, newIcoRate);
    }

    function forwardCash()
        external onlyOwner
    {

        uint256 balance = address(this).balance;
        require(balance > 0,
            "ExenoTokenIco: there no cash to forward");
        Address.sendValue(wallet, balance);
        emit ForwardCash(balance);
    }

    function currentRate()
        public view returns(uint256)
    {

        uint256 rate = 0;
        if (currentStage == Stage.PreICO) {
            rate = preIcoRate;
        } else if (currentStage == Stage.ICO) {
            rate = icoRate;
        }
        return rate;
    }

    function getLatestPrice()
        public view returns(uint256 price, uint8 decimals)
    {

        (, int256 answer, , ,) = priceFeed.latestRoundData();
        price = uint256(answer);
        decimals = priceFeed.decimals();
    }

    function checkAvailableFunds()
        external view returns(uint256, uint256)
    {

        return (token.balanceOf(wallet), token.allowance(wallet, address(this)));
    }

    function convertFromCashAmount(uint256 cashAmount)
        public view returns(uint256 tokenAmount, uint256 usdValue)
    {

        (uint256 price, uint8 decimals) = getLatestPrice();
        uint256 rate = currentRate();
        tokenAmount = cashAmount * price * 10**4 / rate / 10**decimals;
        usdValue = cashAmount * price / 10**decimals;
    }

    function convertFromTokenAmount(uint256 tokenAmount)
        external view returns(uint256 cashAmount, uint256 usdValue)
    {

        (uint256 price, uint8 decimals) = getLatestPrice();
        uint256 rate = currentRate();
        cashAmount = tokenAmount * 10**decimals * rate / price / 10**4;
        usdValue = tokenAmount * rate / 10**4;
    }

    function convertFromUSDValue(uint256 usdValue)
        external view returns(uint256 tokenAmount, uint256 cashAmount)
    {

        (uint256 price, uint8 decimals) = getLatestPrice();
        uint256 rate = currentRate();
        tokenAmount = usdValue * 10**4 / rate;
        cashAmount = usdValue * 10**decimals / price;
    }

}