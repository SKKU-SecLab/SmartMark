


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint);


    function balanceOf(address account) external view returns (uint);


    function transfer(address recipient, uint amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}



pragma solidity ^0.6.0;

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint) {

        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {

        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }

    function mul(uint a, uint b) internal pure returns (uint) {

        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {

        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }

    function mod(uint a, uint b) internal pure returns (uint) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint amount) internal {

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

    function functionCallWithValue(address target, bytes memory data, uint value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint weiValue, string memory errorMessage) private returns (bytes memory) {

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



pragma solidity ^0.6.0;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint;
    using Address for address;

    mapping (address => uint) private _balances;

    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;

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

    function totalSupply() public view override returns (uint) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint) {

        return _balances[account];
    }

    function transfer(address recipient, uint amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint amount) internal virtual { }

}



pragma solidity ^0.6.0;




library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint value) internal {
        uint newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint value) internal {
        uint newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.6.0;

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IHegicOptions {
    event Create(
        uint indexed id,
        address indexed account,
        uint totalFee
    );

    event Exercise(uint indexed id, uint profit);
    event Expire(uint indexed id, uint premium);
    enum State {Inactive, Active, Exercised, Expired}
    enum OptionType {Invalid, Put, Call}

    struct Option {
        State state;
        uint lockID;
        address payable holder;
        uint strike;
        uint amount;
        uint lockedAmount;
        uint premium;
        uint expiration;
        OptionType optionType;
    }

    function options(uint) external view returns (
        State state,
        uint lockID,
        address payable holder,
        uint strike,
        uint amount,
        uint lockedAmount,
        uint premium,
        uint expiration,
        OptionType optionType
    );
}

interface IUniswapV2SlidingOracle {
    function quote(address tokenIn, uint amountIn, address tokenOut, uint granularity) external view returns (uint amountOut);
}

interface ICurveFi {
    function get_virtual_price() external view returns (uint);

    function add_liquidity(
        uint[3] calldata amounts,
        uint min_mint_amount
    ) external;
}
interface IyVault {
    function getPricePerFullShare() external view returns (uint);
    function depositAll() external;
    function balanceOf(address owner) external view returns (uint);
}

interface IHegicERCPool {
    function lock(uint id, uint amount, uint premium) external;
    function unlock(uint id) external;
    function send(uint id, address payable to, uint amount) external;
    function getNextID() external view returns (uint);
    function RESERVE() external view returns (address);
}


pragma solidity 0.6.12;




contract HegicOptions is Ownable, IHegicOptions {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    Option[] public override options;
    uint public impliedVolRate;
    uint public optionCollateralizationRatio = 100;
    uint internal contractCreationTimestamp;
    
    
    uint internal constant IV_DECIMALS = 1e8;
    IUniswapV2SlidingOracle public constant ORACLE = IUniswapV2SlidingOracle(0xCA2E2df6A7a7Cf5bd19D112E8568910a6C2D3885);
    uint8 constant public GRANULARITY = 8;
    
    IERC20 constant public DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 constant public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 constant public USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address constant public WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    
    ICurveFi constant public CURVE = ICurveFi(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);
    IyVault constant public YEARN = IyVault(0x9cA85572E6A3EbF24dEDd195623F188735A5179f);
    IERC20 constant public CRV3 = IERC20(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);
    address immutable public ASSET;
    uint immutable public ONE;
    IHegicERCPool immutable public POOL;
    
    uint public cummulativeStrike;
    uint public cummulativeAmount;
    uint public cummulativeCalls;
    uint public cummulativePuts;
    
    constructor(
        IHegicERCPool _pool,
        address _asset
    ) public {
        POOL = _pool;
        ASSET = _asset;
        ONE = uint(10)**ERC20(_asset).decimals();
        impliedVolRate = 4500;
        contractCreationTimestamp = block.timestamp;
    }

    function setImpliedVolRate(uint value) external onlyOwner {
        require(value >= 1000, "ImpliedVolRate limit is too small");
        impliedVolRate = value;
    }

    function setOptionCollaterizationRatio(uint value) external onlyOwner {
        require(50 <= value && value <= 100, "wrong value");
        optionCollateralizationRatio = value;
    }
    
    function quote(address tokenIn, uint amountIn) public view returns (uint minOut) {
        if (tokenIn != WETH) {
            amountIn = ORACLE.quote(tokenIn, amountIn, WETH, GRANULARITY);
        }
        minOut = ORACLE.quote(WETH, amountIn, address(DAI), GRANULARITY);
    }
    
    function create(
        address asset,
        uint period,
        uint amount, // amount of the underlying asset (address, amountIn)
        uint strike, // price in DAI as per quote(address, uint)
        uint maxFee,
        OptionType optionType
    ) external returns (uint optionID)  {
        require(
            asset == address(DAI) || asset == address(USDC) || asset == address(USDT), 
            "invalid asset"
        );
        require(
            optionType == OptionType.Call || optionType == OptionType.Put,
            "Wrong option type"
        );
        require(period >= 1 days, "Period is too short");
        require(period <= 4 weeks, "Period is too long");
        
        cummulativeAmount = cummulativeAmount.add(amount);
        cummulativeStrike = cummulativeStrike.add(strike.mul(amount));
        
        uint amountInDAI = quote(ASSET, amount);
        
        if (optionType == OptionType.Call) {
            cummulativeCalls = cummulativeCalls.add(amountInDAI);
        } else  {
            cummulativePuts = cummulativePuts.add(amountInDAI);
        }
        
        (uint total,, uint strikeFee, ) =
            fees(period, amountInDAI, strike, optionType);
        
        uint _fee = convertDAI2Asset(asset, total);
        
        require(amount > strikeFee, "price difference is too large");
        require(_fee < maxFee, "fee exceeds max fee");
        optionID = options.length;
        
        IERC20(asset).safeTransferFrom(msg.sender, address(this), _fee);
        convertToY3P();

        Option memory option = Option(
            State.Active, // state
            POOL.getNextID(), // lockID
            msg.sender, // holder
            strike,
            amount,
            DAI2Y3P(amountInDAI),
            YEARN.balanceOf(address(this)), // premium
            block.timestamp + period, // expiration
            optionType
        );

        
        
        options.push(option);
        POOL.lock(option.lockID, option.lockedAmount, option.premium);

        emit Create(optionID, msg.sender, total);
    }
    
    function convertDAI2Asset(address asset, uint total) public view returns (uint) {
        return total.mul(ERC20(asset).decimals()).div(ERC20(address(DAI)).decimals());
    }

    function transfer(uint optionID, address payable newHolder) external {
        Option storage option = options[optionID];

        require(newHolder != address(0), "new holder address is zero");
        require(option.expiration >= block.timestamp, "Option has expired");
        require(option.holder == msg.sender, "Wrong msg.sender");
        require(option.state == State.Active, "Only active option could be transferred");

        option.holder = newHolder;
    }

    function exercise(uint optionID) external {
        Option storage option = options[optionID];

        require(option.expiration >= block.timestamp, "Option has expired");
        require(option.holder == msg.sender, "Wrong msg.sender");
        require(option.state == State.Active, "Wrong state");

        option.state = State.Exercised;
        uint profit = _payProfit(optionID);
        
        cummulativeStrike = cummulativeStrike.sub(option.strike);
        cummulativeAmount = cummulativeAmount.sub(option.amount);
        if (option.optionType == OptionType.Call) {
            cummulativeCalls = cummulativeCalls.sub(option.lockedAmount);
        } else if (option.optionType == OptionType.Put) {
            cummulativePuts = cummulativePuts.sub(option.lockedAmount);
        }

        emit Exercise(optionID, profit);
    }

    function unlockAll(uint[] calldata optionIDs) external {
        uint arrayLength = optionIDs.length;
        uint _cummulativeStrike;
        uint _cummulativeAmount;
        uint _cummulativeCalls; 
        uint _cummulativePuts;
        
        for (uint i = 0; i < arrayLength; i++) {
            (uint _strike, uint _amount, uint _calls, uint _puts) = _unlock(optionIDs[i]);
            _cummulativeStrike = _cummulativeStrike.add(_strike);
            _cummulativeAmount = _cummulativeAmount.add(_amount);
            _cummulativeCalls = _cummulativeCalls.add(_calls);
            _cummulativePuts = _cummulativePuts.add(_puts);
        }
        
        cummulativeStrike = cummulativeStrike.sub(_cummulativeStrike);
        cummulativeAmount = cummulativeAmount.sub(_cummulativeAmount);
        cummulativeCalls = cummulativeCalls.sub(_cummulativeCalls);
        cummulativePuts = cummulativePuts.sub(_cummulativePuts);
    }

    function approve() public {
        IERC20(POOL.RESERVE()).safeApprove(address(POOL), uint(0));
        
        DAI.safeApprove(address(CURVE), uint(0));
        USDT.safeApprove(address(CURVE), uint(0));
        USDC.safeApprove(address(CURVE), uint(0));
        CRV3.safeApprove(address(YEARN), uint(0));
        
        IERC20(POOL.RESERVE()).safeApprove(address(POOL), uint(-1));
        
        DAI.safeApprove(address(CURVE), uint(-1));
        USDT.safeApprove(address(CURVE), uint(-1));
        USDC.safeApprove(address(CURVE), uint(-1));
        CRV3.safeApprove(address(YEARN), uint(-1));
    }

    function fees(
        uint period,
        uint amount,
        uint strike,
        OptionType optionType
    )
        public
        view
        returns (
            uint total,
            uint settlementFee,
            uint strikeFee,
            uint periodFee
        )
    {
        uint currentPrice = quote(ASSET, ONE);
        uint _avgStrike = cummulativeStrike == 0 ? currentPrice : cummulativeStrike.div(cummulativeAmount);
        if (optionType == OptionType.Put) {
            currentPrice = currentPrice.add(currentPrice).sub(_avgStrike);
        } else if (optionType == OptionType.Call) {
            currentPrice = currentPrice.add(_avgStrike).sub(currentPrice);
        }
        settlementFee = getSettlementFee(amount);
        periodFee = getPeriodFee(amount, period, strike, currentPrice, optionType);
        strikeFee = getStrikeFee(amount, strike, currentPrice, optionType);
        total = periodFee.add(strikeFee).add(settlementFee);
        if (optionType == OptionType.Put && cummulativePuts > 0) {
            total = total.mul(cummulativePuts).div((cummulativePuts.add(cummulativeCalls)).div(2));
        } else if (cummulativeCalls > 0) {
            total = total.mul(cummulativeCalls).div((cummulativePuts.add(cummulativeCalls)).div(2));
        }
    }

    function unlock(uint optionID) external {
        (uint _strike, uint _amount, uint _calls, uint _puts) = _unlock(optionID);
        cummulativeStrike = cummulativeStrike.sub(_strike);
        cummulativeAmount = cummulativeAmount.sub(_amount);
        cummulativeCalls = cummulativeCalls.sub(_calls);
        cummulativePuts = cummulativePuts.sub(_puts);
    }
    
    function _unlock(uint optionID) internal returns (uint _strike, uint _amount, uint _calls, uint _puts) {
        Option storage option = options[optionID];
        require(option.expiration < block.timestamp, "Option has not expired yet");
        require(option.state == State.Active, "Option is not active");
        option.state = State.Expired;
        POOL.unlock(optionID);
        _strike = _strike.add(option.strike);
        _amount = _amount.add(option.amount);
        if (option.optionType == OptionType.Call) {
            _calls = _calls.add(option.lockedAmount);
        } else if (option.optionType == OptionType.Put) {
            _puts = _puts.add(option.lockedAmount);
        }
        
        emit Expire(optionID, option.premium);
    }
    
    function price() external view returns (uint) {
        return quote(ASSET, ONE);
    }

    function getSettlementFee(uint amount)
        internal
        pure
        returns (uint fee)
    {
        return amount / 100;
    }

    function getPeriodFee(
        uint amount,
        uint period,
        uint strike,
        uint currentPrice,
        OptionType optionType
    ) internal view returns (uint fee) {
        if (optionType == OptionType.Put)
            return amount
                .mul(sqrt(period))
                .mul(impliedVolRate)
                .mul(strike)
                .div(currentPrice)
                .div(IV_DECIMALS);
        else
            return amount
                .mul(sqrt(period))
                .mul(impliedVolRate)
                .mul(currentPrice)
                .div(strike)
                .div(IV_DECIMALS);
    }

    function getStrikeFee(
        uint amount,
        uint strike,
        uint currentPrice,
        OptionType optionType
    ) internal pure returns (uint fee) {
        if (strike > currentPrice && optionType == OptionType.Put)
            return strike.sub(currentPrice).mul(amount).div(currentPrice);
        if (strike < currentPrice && optionType == OptionType.Call)
            return currentPrice.sub(strike).mul(amount).div(currentPrice);
        return 0;
    }

    function _payProfit(uint optionID)
        internal
        returns (uint profit)
    {
        Option memory option = options[optionID];
        uint currentPrice = quote(ASSET, ONE);
        if (option.optionType == OptionType.Call) {
            require(option.strike <= currentPrice, "Current price is too low");
            profit = currentPrice.sub(option.strike).mul(option.amount);
        } else {
            require(option.strike >= currentPrice, "Current price is too high");
            profit = option.strike.sub(currentPrice).mul(option.amount);
        }
        if (profit > option.lockedAmount)
            profit = option.lockedAmount;
            
        profit = DAI2Y3P(profit);
        POOL.send(option.lockID, option.holder, profit);
    }
    
    function DAI2Y3P(uint amount) public view returns (uint _yearn) {
        uint _curve = amount.mul(1e18).div(CURVE.get_virtual_price());
        _yearn = _curve.mul(1e18).div(YEARN.getPricePerFullShare());
    }
    
    function convertToY3P() internal {
        CURVE.add_liquidity([DAI.balanceOf(address(this)), USDC.balanceOf(address(this)), USDT.balanceOf(address(this))], 0);
        YEARN.depositAll();
    }

    function sqrt(uint x) private pure returns (uint result) {
        result = x;
        uint k = x.div(2).add(1);
        while (k < result) (result, k) = (k, x.div(k).add(k).div(2));
    }
}