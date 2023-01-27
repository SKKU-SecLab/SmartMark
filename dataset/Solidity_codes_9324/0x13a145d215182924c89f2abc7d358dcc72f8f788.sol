

pragma solidity 0.6.2;


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

        (bool success, ) = recipient.call{ value: amount }("");
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

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

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

contract ReentrancyGuard {

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
}

interface IFlashLoanReceiver {
    function executeOperation(address _reserve, uint256 _amount, uint256 _fee, bytes calldata _params) external;
}

library EthAddressLib {

    function ethAddress() internal pure returns(address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }
}

contract UnilendFDonation {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    uint public defaultReleaseRate;
    bool public disableSetCore;
    mapping(address => uint) public releaseRate;
    mapping(address => uint) public lastReleased;
    address public core;
    
    constructor() public {
        core = msg.sender;
        defaultReleaseRate = 11574074074075; // ~1% / day
    }
    
    
    modifier onlyCore {
        require(
            core == msg.sender,
            "Not Permitted"
        );
        _;
    }
    
    
    event NewDonation(address indexed donator, uint amount);
    event Released(address indexed to, uint amount);
    event ReleaseRate(address indexed token, uint rate);
    
    
    
    function balanceOfToken(address _token) external view returns(uint) {
        return IERC20(_token).balanceOf(address(this));
    }
    
    function getReleaseRate(address _token) public view returns (uint) {
        if(releaseRate[_token] > 0){
            return releaseRate[_token];
        } 
        else {
            return defaultReleaseRate;
        }
    }
    
    function getCurrentRelease(address _token, uint timestamp) public view returns (uint availRelease){
        uint tokenBalance = IERC20(_token).balanceOf( address(this) );
        
        uint remainingRate = ( timestamp.sub( lastReleased[_token] ) ).mul( getReleaseRate(_token) );
        uint maxRate = 100 * 10**18;
        
        if(remainingRate > maxRate){ remainingRate = maxRate; }
        availRelease = ( tokenBalance.mul( remainingRate )).div(10**20);
    }
    
    
    function donate(address _token, uint amount) external returns(bool) {
        require(amount > 0, "Amount can't be zero");
        releaseTokens(_token);
        
        IERC20(_token).safeTransferFrom(msg.sender, address(this), amount);
        
        emit NewDonation(msg.sender, amount);
        
        return true;
    }
    
    function disableSetNewCore() external onlyCore {
        require(!disableSetCore, "Already disabled");
        disableSetCore = true;
    }
    
    function setCoreAddress(address _newAddress) external onlyCore {
        require(!disableSetCore, "SetCoreAddress disabled");
        core = _newAddress;
    }
    
    function setReleaseRate(address _token, uint _newRate) external onlyCore {
        releaseTokens(_token);
        
        releaseRate[_token] = _newRate;
        
        emit ReleaseRate(_token, _newRate);
    }
    
    function releaseTokens(address _token) public {
        uint tokenBalance = IERC20(_token).balanceOf( address(this) );
        
        if(tokenBalance > 0){
            uint remainingRate = ( block.timestamp.sub( lastReleased[_token] ) ).mul( getReleaseRate(_token) );
            uint maxRate = 100 * 10**18;
            
            lastReleased[_token] = block.timestamp;
            
            if(remainingRate > maxRate){ remainingRate = maxRate; }
            uint totalReleased = ( tokenBalance.mul( remainingRate )).div(10**20);
            
            if(totalReleased > 0){
                IERC20(_token).safeTransfer(core, totalReleased);
                
                emit Released(core, totalReleased);
            }
        } 
        else {
            lastReleased[_token] = block.timestamp;
        }
    }
}

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

contract UFlashLoanPool is ERC20 {
    using SafeMath for uint256;
    
    address public token;
    address payable public core;
    
    
    constructor(
        address _token,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) public {
        token = _token;
        
        core = payable(msg.sender);
    }
    
    modifier onlyCore {
        require(
            core == msg.sender,
            "Not Permitted"
        );
        _;
    }
    
    
    
    function calculateShare(uint _totalShares, uint _totalAmount, uint _amount) internal pure returns (uint){
        if(_totalShares == 0){
            return Math.sqrt(_amount.mul( _amount ));
        } else {
            return (_amount).mul( _totalShares ).div( _totalAmount );
        }
    }
    
    function getShareValue(uint _totalAmount, uint _totalSupply, uint _amount) internal pure returns (uint){
        return ( _amount.mul(_totalAmount) ).div( _totalSupply );
    }
    
    function getShareByValue(uint _totalAmount, uint _totalSupply, uint _valueAmount) internal pure returns (uint){
        return ( _valueAmount.mul(_totalSupply) ).div( _totalAmount );
    }
    
    
    function deposit(address _recipient, uint amount) external onlyCore returns(uint) {
        uint _totalSupply = totalSupply();
        
        uint tokenBalance;
        if(EthAddressLib.ethAddress() == token){
            tokenBalance = address(core).balance;
        } 
        else {
            tokenBalance = IERC20(token).balanceOf(core);
        }
        
        uint ntokens = calculateShare(_totalSupply, tokenBalance.sub(amount), amount);
        
        require(ntokens > 0, 'Insufficient Liquidity Minted');
        
        _mint(_recipient, ntokens);
        
        return ntokens;
    }
    
    
    function redeem(address _recipient, uint tok_amount) external onlyCore returns(uint) {
        require(tok_amount > 0, 'Insufficient Liquidity Burned');
        require(balanceOf(_recipient) >= tok_amount, "Balance Exceeds Requested");
        
        uint tokenBalance;
        if(EthAddressLib.ethAddress() == token){
            tokenBalance = address(core).balance;
        } 
        else {
            tokenBalance = IERC20(token).balanceOf(core);
        }
        
        uint poolAmount = getShareValue(tokenBalance, totalSupply(), tok_amount);
        
        require(tokenBalance >= poolAmount, "Not enough Liquidity");
        
        _burn(_recipient, tok_amount);
        
        return poolAmount;
    }
    
    
    function redeemUnderlying(address _recipient, uint amount) external onlyCore returns(uint) {
        uint tokenBalance;
        if(EthAddressLib.ethAddress() == token){
            tokenBalance = address(core).balance;
        } 
        else {
            tokenBalance = IERC20(token).balanceOf(core);
        }
        
        uint tok_amount = getShareByValue(tokenBalance, totalSupply(), amount);
        
        require(tok_amount > 0, 'Insufficient Liquidity Burned');
        require(balanceOf(_recipient) >= tok_amount, "Balance Exceeds Requested");
        require(tokenBalance >= amount, "Not enough Liquidity");
        
        _burn(_recipient, tok_amount);
        
        return tok_amount;
    }
    
    
    function balanceOfUnderlying(address _address, uint timestamp) public view returns (uint _bal) {
        uint _balance = balanceOf(_address);
        
        if(_balance > 0){
            uint tokenBalance;
            if(EthAddressLib.ethAddress() == token){
                tokenBalance = address(core).balance;
            } 
            else {
                tokenBalance = IERC20(token).balanceOf(core);
            }
            
            address donationAddress = UnilendFlashLoanCore( core ).donationAddress();
            uint _balanceDonation = UnilendFDonation( donationAddress ).getCurrentRelease(token, timestamp);
            uint _totalPoolAmount = tokenBalance.add(_balanceDonation);
            
            _bal = getShareValue(_totalPoolAmount, totalSupply(), _balance);
        } 
    }
    
    
    function poolBalanceOfUnderlying(uint timestamp) public view returns (uint _bal) {
        uint tokenBalance;
        if(EthAddressLib.ethAddress() == token){
            tokenBalance = address(core).balance;
        } 
        else {
            tokenBalance = IERC20(token).balanceOf(core);
        }
        
        if(tokenBalance > 0){
            address donationAddress = UnilendFlashLoanCore( core ).donationAddress();
            uint _balanceDonation = UnilendFDonation( donationAddress ).getCurrentRelease(token, timestamp);
            uint _totalPoolAmount = tokenBalance.add(_balanceDonation);
            
            _bal = _totalPoolAmount;
        } 
    }
}

contract UnilendFlashLoanCore is Context, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    
    address public admin;
    address payable public distributorAddress;
    address public donationAddress;
    
    mapping(address => address) public Pools;
    mapping(address => address) public Assets;
    uint public poolLength;
    
    
    uint256 private FLASHLOAN_FEE_TOTAL = 5;
    uint256 private FLASHLOAN_FEE_PROTOCOL = 3000;
    
    
    constructor() public {
        admin = msg.sender;
    }
    
    
    event FlashLoan(
        address indexed _target,
        address indexed _reserve,
        uint256 _amount,
        uint256 _totalFee,
        uint256 _protocolFee,
        uint256 _timestamp
    );
    
    event PoolCreated(address indexed token, address pool, uint);
    
    event RedeemUnderlying(
        address indexed _reserve,
        address indexed _user,
        uint256 _amount,
        uint256 _timestamp
    );
    
    event Deposit(
        address indexed _reserve,
        address indexed _user,
        uint256 _amount,
        uint256 _timestamp
    );
    
    modifier onlyAdmin {
        require(
            admin == msg.sender,
            "The caller must be a admin"
        );
        _;
    }
    
    modifier onlyAmountGreaterThanZero(uint256 _amount) {
        require(_amount > 0, "Amount must be greater than 0");
        _;
    }
    
    receive() payable external {}
    
    function getFlashLoanFeesInBips() public view returns (uint256, uint256) {
        return (FLASHLOAN_FEE_TOTAL, FLASHLOAN_FEE_PROTOCOL);
    }
    
    function getPools(address[] calldata _reserves) external view returns (address[] memory) {
        address[] memory _addresss = new address[](_reserves.length);
        address[] memory _reserves_ = _reserves;
        
        for (uint i=0; i<_reserves_.length; i++) {
            _addresss[i] = Pools[_reserves_[i]];
        }
        
        return _addresss;
    }
    
    
    function balanceOfUnderlying(address _reserve, address _address, uint timestamp) public view returns (uint _bal) {
        if(Pools[_reserve] != address(0)){
            _bal = UFlashLoanPool(Pools[_reserve]).balanceOfUnderlying(_address, timestamp);
        }
    }
    
    function poolBalanceOfUnderlying(address _reserve, uint timestamp) public view returns (uint _bal) {
        if(Pools[_reserve] != address(0)){
            _bal = UFlashLoanPool(Pools[_reserve]).poolBalanceOfUnderlying(timestamp);
        }
    }
    
    
    function setAdmin(address _admin) external onlyAdmin {
        require(_admin != address(0), "UnilendV1: ZERO ADDRESS");
        admin = _admin;
    }
    
    function setDistributorAddress(address payable _address) external onlyAdmin {
        require(_address != address(0), "UnilendV1: ZERO ADDRESS");
        distributorAddress = _address;
    }
    
    function setDonationDisableNewCore() external onlyAdmin {
        UnilendFDonation(donationAddress).disableSetNewCore();
    }
    
    function setDonationCoreAddress(address _newAddress) external onlyAdmin {
        require(_newAddress != address(0), "UnilendV1: ZERO ADDRESS");
        UnilendFDonation(donationAddress).setCoreAddress(_newAddress);
    }
    
    function setDonationReleaseRate(address _reserve, uint _newRate) external onlyAdmin {
        require(_reserve != address(0), "UnilendV1: ZERO ADDRESS");
        UnilendFDonation(donationAddress).setReleaseRate(_reserve, _newRate);
    }
    
    function setFlashLoanFeesInBips(uint _newFeeTotal, uint _newFeeProtocol) external onlyAdmin returns (bool) {
        require(_newFeeTotal > 0 && _newFeeTotal < 10000, "UnilendV1: INVALID TOTAL FEE RANGE");
        require(_newFeeProtocol > 0 && _newFeeProtocol < 10000, "UnilendV1: INVALID PROTOCOL FEE RANGE");
        
        FLASHLOAN_FEE_TOTAL = _newFeeTotal;
        FLASHLOAN_FEE_PROTOCOL = _newFeeProtocol;
        
        return true;
    }
    

    function transferToUser(address _reserve, address payable _user, uint256 _amount) internal {
        require(_user != address(0), "UnilendV1: USER ZERO ADDRESS");
        
        if (_reserve != EthAddressLib.ethAddress()) {
            ERC20(_reserve).safeTransfer(_user, _amount);
        } else {
            (bool result, ) = _user.call{value: _amount, gas: 50000}("");
            require(result, "Transfer of ETH failed");
        }
    }
    
    function transferFlashLoanProtocolFeeInternal(address _token, uint256 _amount) internal {
        if (_token != EthAddressLib.ethAddress()) {
            ERC20(_token).safeTransfer(distributorAddress, _amount);
        } else {
            (bool result, ) = distributorAddress.call{value: _amount, gas: 50000}("");
            require(result, "Transfer of ETH failed");
        }
    }
    
    
    function flashLoan(address _receiver, address _reserve, uint256 _amount, bytes calldata _params)
        external
        nonReentrant
        onlyAmountGreaterThanZero(_amount)
    {
        uint256 availableLiquidityBefore = _reserve == EthAddressLib.ethAddress()
            ? address(this).balance
            : IERC20(_reserve).balanceOf(address(this));

        require(
            availableLiquidityBefore >= _amount,
            "There is not enough liquidity available to borrow"
        );

        (uint256 totalFeeBips, uint256 protocolFeeBips) = getFlashLoanFeesInBips();
        uint256 amountFee = _amount.mul(totalFeeBips).div(10000);

        uint256 protocolFee = amountFee.mul(protocolFeeBips).div(10000);
        require(
            amountFee > 0 && protocolFee > 0,
            "The requested amount is too small for a flashLoan."
        );

        IFlashLoanReceiver receiver = IFlashLoanReceiver(_receiver);

        transferToUser(_reserve, payable(_receiver), _amount);

        receiver.executeOperation(_reserve, _amount, amountFee, _params);

        uint256 availableLiquidityAfter = _reserve == EthAddressLib.ethAddress()
            ? address(this).balance
            : IERC20(_reserve).balanceOf(address(this));

        require(
            availableLiquidityAfter == availableLiquidityBefore.add(amountFee),
            "The actual balance of the protocol is inconsistent"
        );
        
        transferFlashLoanProtocolFeeInternal(_reserve, protocolFee);

        emit FlashLoan(_receiver, _reserve, _amount, amountFee, protocolFee, block.timestamp);
    }
    
    
    
    
    
    function deposit(address _reserve, uint _amount) external 
        payable
        nonReentrant
        onlyAmountGreaterThanZero(_amount)
    returns(uint mintedTokens) {
        require(Pools[_reserve] != address(0), 'UnilendV1: POOL NOT FOUND');
        
        UnilendFDonation(donationAddress).releaseTokens(_reserve);
        
        address _user = msg.sender;
        
        if (_reserve != EthAddressLib.ethAddress()) {
            require(msg.value == 0, "User is sending ETH along with the ERC20 transfer.");
            
            uint reserveBalance = IERC20(_reserve).balanceOf(address(this));
            
            ERC20(_reserve).safeTransferFrom(_user, address(this), _amount);
            
            _amount = ( IERC20(_reserve).balanceOf(address(this)) ).sub(reserveBalance);
        } else {
            require(msg.value >= _amount, "The amount and the value sent to deposit do not match");

            if (msg.value > _amount) {
                uint256 excessAmount = msg.value.sub(_amount);
                
                (bool result, ) = _user.call{value: excessAmount, gas: 50000}("");
                require(result, "Transfer of ETH failed");
            }
        }
        
        mintedTokens = UFlashLoanPool(Pools[_reserve]).deposit(msg.sender, _amount);
        
        emit Deposit(_reserve, msg.sender, _amount, block.timestamp);
    }
    
    
    function redeem(address _reserve, uint _amount) external returns(uint redeemTokens) {
        require(Pools[_reserve] != address(0), 'UnilendV1: POOL NOT FOUND');
        
        UnilendFDonation(donationAddress).releaseTokens(_reserve);
        
        redeemTokens = UFlashLoanPool(Pools[_reserve]).redeem(msg.sender, _amount);
        
        transferToUser(_reserve, payable(msg.sender), redeemTokens);
        
        emit RedeemUnderlying(_reserve, msg.sender, redeemTokens, block.timestamp);
    }
    
    function redeemUnderlying(address _reserve, uint _amount) external returns(uint token_amount) {
        require(Pools[_reserve] != address(0), 'UnilendV1: POOL NOT FOUND');
        
        UnilendFDonation(donationAddress).releaseTokens(_reserve);
        
        token_amount = UFlashLoanPool(Pools[_reserve]).redeemUnderlying(msg.sender, _amount);
        
        transferToUser(_reserve, payable(msg.sender), _amount);
        
        emit RedeemUnderlying(_reserve, msg.sender, _amount, block.timestamp);
    }
    
    
    
    function createPool(address _reserve) public returns (address) {
        require(Pools[_reserve] == address(0), 'UnilendV1: POOL ALREADY CREATED');
        
        ERC20 asset = ERC20(_reserve);
        
        string memory uTokenName;
        string memory uTokenSymbol;
        
        if(_reserve == EthAddressLib.ethAddress()){
            uTokenName = string(abi.encodePacked("UnilendV1 - ETH"));
            uTokenSymbol = string(abi.encodePacked("uETH"));
        } 
        else {
            uTokenName = string(abi.encodePacked("UnilendV1 - ", asset.name()));
            uTokenSymbol = string(abi.encodePacked("u", asset.symbol()));
        }
        
        UFlashLoanPool _poolMeta = new UFlashLoanPool(_reserve, uTokenName, uTokenSymbol);
        
        address _poolAddress = address(_poolMeta);
        
        Pools[_reserve] = _poolAddress;
        Assets[_poolAddress] = _reserve;
        
        poolLength++;
        
        emit PoolCreated(_reserve, _poolAddress, poolLength);
        
        return _poolAddress;
    }
    
    function createDonationContract() external returns (address) {
        require(donationAddress == address(0), 'UnilendV1: DONATION ADDRESS ALREADY CREATED');
        
        UnilendFDonation _donationMeta = new UnilendFDonation();
        donationAddress = address(_donationMeta);
        
        return donationAddress;
    }
}