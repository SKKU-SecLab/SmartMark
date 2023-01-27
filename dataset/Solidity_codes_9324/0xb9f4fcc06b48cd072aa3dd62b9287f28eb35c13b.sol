

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
}


pragma solidity ^0.5.0;





contract PostDeliveryCrowdsale is TimedCrowdsale {

    using SafeMath for uint256;
    uint contractCreationTime;
    uint monthTime =  2592000;
    uint public timeToWait;
    uint public initialEmission;
    uint public months;
    uint public lastFunctioncalled;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _totalClaimed;
    
    __unstable__TokenVault private _vault;

    constructor(uint _initialEmission, uint _timeToWait, uint _months) public {
        require(_timeToWait>0, "TimeToWait is 0");
        uint closingTime = closingTime();
        contractCreationTime = closingTime;
        initialEmission = _initialEmission;
        timeToWait = _timeToWait ;
        months = _months;
        _vault = new __unstable__TokenVault();
    }
    
    function currentRetractableTokens(address beneficiary) view public returns(uint){

        require(hasClosed(), "PostDeliveryCrowdsale: not closed");
        uint256 amount = _balances[beneficiary];
        uint realAmount;
        if(amount<=0){
            return 0;
        }
        uint since = block.timestamp - contractCreationTime;
        
        if(initialEmission==100){
            return amount;
        }
        
        else if((since/monthTime)< timeToWait){
            realAmount = ((initialEmission*(amount+_totalClaimed[beneficiary]))/100) - _totalClaimed[beneficiary];
            return realAmount;
        }
        
        else {
            uint restEmission = 100 - initialEmission;
            realAmount = ((initialEmission*(amount+_totalClaimed[beneficiary]))/100) + (restEmission*(amount + _totalClaimed[beneficiary])*((since/monthTime) + 1 - timeToWait)/months/100) - _totalClaimed[beneficiary];
            if(realAmount==0){
                return 0;
            }
            if(realAmount>_balances[beneficiary]){
                realAmount = _balances[beneficiary];
            }
            return realAmount;
        }
    }

   
    function withdrawTokens(address beneficiary) public {

        require(hasClosed(), "PostDeliveryCrowdsale: not closed");
        uint256 amount = _balances[beneficiary];
        uint realAmount;
        require(amount > 0, "PostDeliveryCrowdsale: beneficiary is not due any tokens");
        uint since = block.timestamp - contractCreationTime;
        
        if(initialEmission==100){
            _balances[beneficiary] = 0;
            _vault.transfer(token(), beneficiary, amount);
            _totalClaimed[beneficiary] += amount;
            lastFunctioncalled = 1;
        }
        
        else if((since/monthTime)< timeToWait){
            realAmount = ((initialEmission*amount)/100) - _totalClaimed[beneficiary];
            require(realAmount>0,"Current Retractable Amount 0");
            _balances[beneficiary] -= realAmount ;
            _vault.transfer(token(), beneficiary, realAmount);
            _totalClaimed[beneficiary] += realAmount;
            lastFunctioncalled =2;
            
        }
        
        else {
            uint restEmission = 100 - initialEmission;
            realAmount = ((initialEmission*(amount+_totalClaimed[beneficiary]))/100) + (restEmission*(amount + _totalClaimed[beneficiary])*((since/monthTime) + 1 - timeToWait)/months/100) - _totalClaimed[beneficiary];
            require(realAmount>0,"Current Retractable Amount 0");
            if(realAmount>_balances[beneficiary]){
                _totalClaimed[beneficiary] += _balances[beneficiary];
                realAmount = _balances[beneficiary];
                lastFunctioncalled = 3;
            }
            _balances[beneficiary] -= realAmount ;
            _vault.transfer(token(), beneficiary, realAmount);
            _totalClaimed[beneficiary] += realAmount;
            lastFunctioncalled = 4;
        }
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
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



pragma solidity ^0.5.0;



contract CappedCrowdsale is Crowdsale {

    using SafeMath for uint256;

    uint256 private _cap;

    constructor (uint256 cap) public {
        require(cap > 0, "CappedCrowdsale: cap is 0");
        _cap = cap;
    }

    function cap() public view returns (uint256) {

        return _cap;
    }

    function capReached() public view returns (bool) {

        return weiRaised() >= _cap;
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        super._preValidatePurchase(beneficiary, weiAmount);
        require(weiRaised().add(weiAmount) <= _cap, "CappedCrowdsale: cap exceeded");
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







interface UniswapRouter {

    function WETH() external pure returns (address);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);

}

contract IDO1 is Crowdsale, TimedCrowdsale, CappedCrowdsale, FinalizableCrowdsale, PostDeliveryCrowdsale{

    address payable treasury = address(0xc020B4B710B5c2264a5a52931933Ff3753f54897);
    address payable fee2address = address(0xE609192618aD9aC825B981fFECf3Dfd5E92E3cFB);
    string public name;
    IERC20 projectToken;
    UniswapRouter public UNIROUTER = UniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
      
    
    uint firstPhaseDuration;
    uint durationDays;
    
    IERC20 public wDarkPylon = IERC20(0x9E6Ca603238Fc4d1F0c49e7E4c6bcb793b1af8Ed);
    uint public minDPLN;

    uint public phaseEnd;
    uint public totalEnd;
    uint public weiCap;
    
    constructor(
        string memory _name,
        uint rate,
        address payable wallet,
        IERC20 _token,
        uint _startTimeEpoch,
        uint _firstPhaseDuration,
        uint _durationDays,
        uint _weiCap,
        uint _minDPLN,
        uint[] memory postd
        ) Crowdsale(rate, wallet, _token) PostDeliveryCrowdsale(postd[0], postd[1], postd[2]) CappedCrowdsale(_weiCap) TimedCrowdsale(_startTimeEpoch,_startTimeEpoch+(_durationDays*24*60*60)) FinalizableCrowdsale() public {
            require(_durationDays>_firstPhaseDuration,"Duration < First Phase");
            require(_minDPLN>=250000000000000000000, "minDPLN is less");
            minDPLN = _minDPLN;
            name = _name;
            firstPhaseDuration = _firstPhaseDuration;
            durationDays = _durationDays;
            weiCap = _weiCap;
            phaseEnd = _startTimeEpoch + (firstPhaseDuration*24*60*60);
            totalEnd = _startTimeEpoch + (durationDays*24*60*60);
            projectToken = _token;
        }
        
        function buyTokensfromTokens(address beneficiary, address _token, uint _amount) public{

            require(_amount>0, "Input Token Amount is 0");
            IERC20 token = IERC20(_token);
            token.transferFrom(msg.sender,address(this),_amount);
            address[] memory path = new address[](2);
            path[0] = _token;
            path[1] = UNIROUTER.WETH();
            token.approve(address(UNIROUTER),_amount);
            uint b1 = address(this).balance;
            UNIROUTER.swapExactTokensForETH(_amount, 0, path, address(this), block.timestamp+180);
            uint b2 = address(this).balance;
            uint finalAmount = b2.sub(b1);
            this.buyTokens.value(finalAmount)(beneficiary);
        }


        function _finalization() internal {

            uint projectBalanceLeft = projectToken.balanceOf(address(this));
            projectToken.transfer(wallet(),projectBalanceLeft);
            
            super._finalization();
        }
        
        function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

            require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
            require(weiAmount != 0, "Crowdsale: weiAmount is 0");

            uint wDLONBal = wDarkPylon.balanceOf(beneficiary);
            uint totalwDLON = wDarkPylon.totalSupply();
            
            if(phaseEnd>block.timestamp){
                require(wDLONBal >= minDPLN , "Min darkPYLON not available");
                require( ((weiAmount*10000)/weiCap)<((wDLONBal*10000)/totalwDLON), "Stake Percentage in DARK PYLON is low" );
            }
            
            require( wDLONBal>250000000000000000000 , "DLON less than 250");
            
            this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        }
        
        function _forwardFunds() internal {

            
            wallet().transfer((msg.value*98)/100);
            treasury.transfer(msg.value/100);
            fee2address.transfer(msg.value/100);
        }
        
        function () payable external{
  }
    
}



pragma solidity ^0.5.0;


contract idoFactory{

    
    mapping (uint => address) public IDOaddresses;
    uint public addressID;
    
    event IDOcreated(string name, uint rate, IERC20 token, uint variant, address IDOaddress);
    constructor() public {
        
    }
    
    function getTotalIDOs() public view returns(uint){

        return (addressID);
    }
    
    
    function releaseIDO(
        string memory name,
        uint variant,
        uint rate,
        address payable wallet,
        IERC20 token,
        uint _startTimeEpoch,
        uint _firstPhaseDuration,
        uint _durationDays,
        uint _weiCap,
        uint _initialEmission,
        uint _timeToWait,
        uint _months
        ) public{

        require( variant>0 , 'Select Correct Version');     
        require( variant<5 , 'Select Correct Version');
        
        if(variant==1){
            uint[] memory postd = new uint[](3);
            postd[0] = _initialEmission;
            postd[1] = _timeToWait;
            postd[2] = _months;
            IDO1 new1 = new IDO1( name, rate, wallet, token, _startTimeEpoch, _firstPhaseDuration, _durationDays, _weiCap, 250000000000000000000, postd);
            addressID += 1;
            IDOaddresses[addressID] = address(new1);
            
        }
        
        if(variant==2){
            uint[] memory postd = new uint[](3);
            postd[0] = _initialEmission;
            postd[1] = _timeToWait;
            postd[2] = _months;
            IDO1 new1 = new IDO1( name, rate, wallet, token, _startTimeEpoch, _firstPhaseDuration, _durationDays, _weiCap, 1000000000000000000000, postd);
            addressID += 1;
            IDOaddresses[addressID] = address(new1);
        }
        
        if(variant==3){
            uint[] memory postd = new uint[](3);
            postd[0] = _initialEmission;
            postd[1] = _timeToWait;
            postd[2] = _months;
            IDO1 new1 = new IDO1( name, rate, wallet, token, _startTimeEpoch, _firstPhaseDuration, _durationDays, _weiCap, 5000000000000000000000, postd);
            addressID += 1;
            IDOaddresses[addressID] = address(new1);
            
        }
        
        if(variant==4){
            uint[] memory postd = new uint[](3);
            postd[0] = _initialEmission;
            postd[1] = _timeToWait;
            postd[2] = _months;
            IDO1 new1 = new IDO1( name, rate, wallet, token, _startTimeEpoch, _firstPhaseDuration, _durationDays, _weiCap, 10000000000000000000000, postd);
            addressID += 1;
            IDOaddresses[addressID] = address(new1);
            
        }
        
        emit IDOcreated(name, rate, token, variant, IDOaddresses[addressID]);
        
    }
    
    
}