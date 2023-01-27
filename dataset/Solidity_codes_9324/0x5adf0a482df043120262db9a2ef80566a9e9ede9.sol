

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
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

pragma solidity >=0.6.2 <0.8.0;

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
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
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

pragma solidity ^0.7.4;

interface IPriceConsumerV3 {
    function getLatestPrice() external view returns (int);
}

interface IUniswapV2Router02 {
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
      external
      payable
      returns (uint[] memory amounts);
      
    function WETH() external returns (address); 
    
    function getAmountsIn(uint amountOut, address[] memory path) external view returns (uint[] memory amounts);
}


contract NexenPlatform is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    enum RequestState {None, LenderCreated, BorrowerCreated, Cancelled, Matched, Closed, Expired, Disabled}
    enum Currency {DAI, USDT, ETH}
    
    IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    
    IPriceConsumerV3 public priceConsumerDAI;
    IPriceConsumerV3 public priceConsumerUSDT;
    
    IERC20 public nexenToken;
    
    ERC20 daiToken = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); 
    ERC20 usdtToken = ERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    
    bool public paused = false;
    bool public genesisPhase = false;
    uint256 public amountToReward = 1000 * 10 ** 18;
    
    uint public lenderFee = 1; //1%
    uint public borrowerFee = 1; //1%
    
    mapping(uint256 => uint256) public interests;

    mapping(address => uint256) public depositedDAI;
    mapping(address => uint256) public depositedUSDT;
    mapping(address => uint256) public depositedWEI;
    
    uint256 public daiFees;
    uint256 public usdtFees;
    uint256 public ethFees;
    
    struct Request {
        RequestState state;
        address payable borrower;
        address payable lender;
        Currency currency;
        uint256 cryptoAmount;
        uint256 durationInDays;
        uint256 expireIfNotMatchedOn;
        uint256 ltv;
        uint256 weiAmount;
        uint256 daiVsWeiCurrentPrice;
        uint256 usdtVsWeiCurrentPrice;
        uint256 lendingFinishesOn;
    }
    
    mapping (uint256 => Request) public requests;
    
    event OpenRequest(uint256 requestId, address indexed borrower, address indexed lender, uint256 cryptoAmount, uint256 durationInDays, uint256 expireIfNotMatchedOn, uint256 ltv, uint256 weiAmount, uint256 daiVsWeiCurrentPrice, uint256 usdtVsWeiCurrentPrice, uint256 lendingFinishesOn, RequestState state, Currency currency);
    event RequestMatchedBorrower(uint256 requestId, address indexed borrower, address indexed lender, uint256 cryptoAmount, uint256 weiAmount, uint256 daiVsWeiCurrentPrice, uint256 usdtVsWeiCurrentPrice);
    event RequestMatchedLender(uint256 requestId, address indexed borrower, address indexed lender, uint256 cryptoAmount);
    event RequestCancelled(uint256 requestId, address indexed borrower, address indexed lender, RequestState state, uint256 weiAmount, uint256 cryptoAmount);
    event RequestFinishedForLender(uint256 requestId, address indexed lender, uint256 daiToTransfer, uint256 totalLenderFee);
    event RequestFinishedForBorrower(uint256 requestId, address indexed borrower, uint256 daiToTransfer, uint256 weiAmount, uint256 totalBorrowerFee);
    event CollateralSoldBorrower(uint256 requestId, address indexed borrower, uint256 weiAmount, uint256 amountSold, uint256 daiToTransfer, uint256 weiRecovered, uint256 totalBorrowerFee);
    event CollateralSoldLender(uint256 requestId, address indexed lender, uint256 weiAmount, uint256 amountSold, uint256 tokenToTransfer, uint256 tokenRecovered, uint256 totalLenderFee);
    event CoinDeposited(address indexed caller, uint256 value, Currency currency);
    event CoinWithdrawn(address indexed caller, uint256 value, Currency currency);

    receive() external payable {
        
    }

    constructor(IPriceConsumerV3 _priceConsumerDAI, IPriceConsumerV3 _priceConsumerUSDT) {
        priceConsumerDAI = _priceConsumerDAI;
        priceConsumerUSDT = _priceConsumerUSDT;
        
        interests[20] = 4;
        interests[40] = 6;
        interests[60] = 8;
    }
    
    function createRequest(bool lend, uint256 cryptoAmount, uint256 durationInDays, uint256 expireIfNotMatchedOn, uint256 ltv, Currency currency) public payable {
        require(currency == Currency.USDT || currency == Currency.DAI, "Invalid currency");
        require(expireIfNotMatchedOn > block.timestamp, "Invalid expiration date");
        require(!paused, "The contract is paused");

        if (currency == Currency.USDT) {
            require(cryptoAmount >= 100 * 10 ** 6, "Minimum amount is 100 USDT");
        } else {
            require(cryptoAmount >= 100 * 10 ** 18, "Minimum amount is 100 DAI");
        }
        
        Request memory r;
        (r.cryptoAmount, r.durationInDays, r.expireIfNotMatchedOn, r.currency) = (cryptoAmount, durationInDays, expireIfNotMatchedOn, currency);
        
        if (lend) {
            r.lender = msg.sender;
            r.state = RequestState.LenderCreated;
            
            if (currency == Currency.USDT) {
                require(depositedUSDT[msg.sender] >= r.cryptoAmount, "Not enough USDT deposited");
                depositedUSDT[msg.sender] -= r.cryptoAmount;
            } else {
                require(depositedDAI[msg.sender] >= r.cryptoAmount, "Not enough DAI deposited");
                depositedDAI[msg.sender] -= r.cryptoAmount;
            }
        } else {
            require(interests[ltv] > 0, 'Invalid LTV');
            
            r.borrower = msg.sender;
            r.state = RequestState.BorrowerCreated;
            r.ltv = ltv;
            
            if (currency == Currency.USDT) {
                r.usdtVsWeiCurrentPrice = uint256(priceConsumerUSDT.getLatestPrice());
                r.weiAmount = calculateWeiAmountForUSDT(r.cryptoAmount, ltv, r.usdtVsWeiCurrentPrice);
            } else {
                r.daiVsWeiCurrentPrice = uint256(priceConsumerDAI.getLatestPrice());
                r.weiAmount = calculateWeiAmountForDAI(r.cryptoAmount, ltv, r.daiVsWeiCurrentPrice);
            }

            if (msg.value > r.weiAmount) {
                msg.sender.transfer(msg.value - r.weiAmount);
            }
            else if (msg.value < r.weiAmount) {
                require(depositedWEI[msg.sender] > (r.weiAmount - msg.value), "Not enough ETH deposited");
                depositedWEI[msg.sender] = depositedWEI[msg.sender] - r.weiAmount + msg.value;
            }
        }

        uint256 requestId = uint256(keccak256(abi.encodePacked(r.borrower, r.lender, r.cryptoAmount, r.durationInDays, r.expireIfNotMatchedOn, r.ltv, r.currency)));
        
        require(requests[requestId].state == RequestState.None, 'Request already exists');
        
        requests[requestId] = r;

        emit OpenRequest(requestId, r.borrower, r.lender, r.cryptoAmount, r.durationInDays, r.expireIfNotMatchedOn, r.ltv, r.weiAmount, r.daiVsWeiCurrentPrice, r.usdtVsWeiCurrentPrice, r.lendingFinishesOn, r.state, r.currency);
    }
    
    function matchRequestAsLender(uint256 requestId) public {
        Request storage r = requests[requestId];
        require(r.state == RequestState.BorrowerCreated, 'Invalid request');
        require(r.expireIfNotMatchedOn > block.timestamp, 'Request expired');
        require(r.borrower != msg.sender, 'You cannot match yourself');

        r.lender = msg.sender;
        r.lendingFinishesOn = getExpirationAfter(r.durationInDays);
        r.state = RequestState.Matched;
        
        if (r.currency == Currency.DAI) {
            require(depositedDAI[msg.sender] >= r.cryptoAmount, "Not enough DAI deposited");
            depositedDAI[msg.sender] = depositedDAI[msg.sender].sub(r.cryptoAmount);
            depositedDAI[r.borrower] = depositedDAI[r.borrower].add(r.cryptoAmount);
        } else {
            require(depositedUSDT[msg.sender] >= r.cryptoAmount, "Not enough USDT deposited");
            depositedUSDT[msg.sender] = depositedUSDT[msg.sender].sub(r.cryptoAmount);
            depositedUSDT[r.borrower] = depositedUSDT[r.borrower].add(r.cryptoAmount);
        }
        
        if (genesisPhase) {
            require(nexenToken.transfer(msg.sender, amountToReward), 'Could not transfer tokens');
            require(nexenToken.transfer(r.borrower, amountToReward), 'Could not transfer tokens');
        }
        
        emit RequestMatchedLender(requestId, r.borrower, r.lender, r.cryptoAmount);
    }
    
    function matchRequestAsBorrower(uint256 requestId, uint256 ltv) public {
        Request storage r = requests[requestId];
        require(r.state == RequestState.LenderCreated, 'Invalid request');
        require(r.expireIfNotMatchedOn > block.timestamp, 'Request expired');
        require(r.lender != msg.sender, 'You cannot match yourself');

        r.borrower = msg.sender;
        r.lendingFinishesOn = getExpirationAfter(r.durationInDays);
        r.state = RequestState.Matched;
        
        r.ltv = ltv;
        
        if (r.currency == Currency.DAI) {
            r.daiVsWeiCurrentPrice = uint256(priceConsumerDAI.getLatestPrice());
            r.weiAmount = calculateWeiAmountForDAI(r.cryptoAmount, r.ltv, r.daiVsWeiCurrentPrice);
            depositedDAI[r.borrower] = depositedDAI[r.borrower].add(r.cryptoAmount);
        } else {
            r.usdtVsWeiCurrentPrice = uint256(priceConsumerUSDT.getLatestPrice());
            r.weiAmount = calculateWeiAmountForUSDT(r.cryptoAmount, r.ltv, r.usdtVsWeiCurrentPrice);
            depositedUSDT[r.borrower] = depositedUSDT[r.borrower].add(r.cryptoAmount);
        }
        
        require(depositedWEI[msg.sender] > r.weiAmount, "Not enough WEI");
        depositedWEI[msg.sender] = depositedWEI[msg.sender].sub(r.weiAmount);

        if (genesisPhase) {
            require(nexenToken.transfer(msg.sender, amountToReward), 'Could not transfer tokens');
            require(nexenToken.transfer(r.lender, amountToReward), 'Could not transfer tokens');
        }

        emit RequestMatchedBorrower(requestId, r.borrower, r.lender, r.cryptoAmount, r.weiAmount, r.daiVsWeiCurrentPrice, r.usdtVsWeiCurrentPrice);
    }
    
    function cancelRequest(uint256 requestId) public {
        Request storage r = requests[requestId];
        require(r.state == RequestState.BorrowerCreated || r.state == RequestState.LenderCreated);
        
        r.state = RequestState.Cancelled;

        if (msg.sender == r.borrower) {
            depositedWEI[msg.sender] += r.weiAmount;
        } else if (msg.sender == r.lender) {
            if (r.currency == Currency.DAI) {
                depositedDAI[msg.sender] += r.cryptoAmount;
            } else {
                depositedUSDT[msg.sender] += r.cryptoAmount;
            }
        } else {
            revert();
        }

        emit RequestCancelled(requestId, r.borrower, r.lender, r.state, r.weiAmount, r.cryptoAmount);
    }
    
    function finishRequest(uint256 _requestId) public {
        Request storage r = requests[_requestId];
        require(r.state == RequestState.Matched, "State needs to be Matched");
        
        require(msg.sender == r.borrower, 'Only borrower can call this');

        r.state = RequestState.Closed;
        
        uint256 cryptoToTransfer = getInterest(r.ltv, r.cryptoAmount).add(r.cryptoAmount);
        
        uint256 totalLenderFee = computeLenderFee(r.cryptoAmount);
        uint256 totalBorrowerFee = computeBorrowerFee(r.weiAmount);
        ethFees = ethFees.add(totalBorrowerFee);

        if (r.currency == Currency.DAI) {
            require(depositedDAI[r.borrower] >= cryptoToTransfer, "Not enough DAI deposited");
            daiFees = daiFees.add(totalLenderFee);
            depositedDAI[r.lender] += cryptoToTransfer.sub(totalLenderFee);
            depositedDAI[r.borrower] -= cryptoToTransfer;
        } else {
            require(depositedUSDT[r.borrower] >= cryptoToTransfer, "Not enough USDT deposited");
            usdtFees = daiFees.add(totalLenderFee);
            depositedUSDT[r.lender] += cryptoToTransfer.sub(totalLenderFee);
            depositedUSDT[r.borrower] -= cryptoToTransfer;
        }

        depositedWEI[r.borrower] += r.weiAmount.sub(totalBorrowerFee);
        
        emit RequestFinishedForLender(_requestId, r.lender, cryptoToTransfer.sub(totalLenderFee), totalLenderFee);
        emit RequestFinishedForBorrower(_requestId, r.borrower, cryptoToTransfer, r.weiAmount.sub(totalBorrowerFee), totalBorrowerFee);
    }
    
    function expireNonFullfiledRequest(uint256 _requestId) public {
        Request storage r = requests[_requestId];

        require(r.state == RequestState.Matched, "State needs to be Matched");
        require(msg.sender == r.lender, "Only lender can call this");
        require(block.timestamp > r.lendingFinishesOn, "Request not finished yet");
        
        r.state = RequestState.Expired;
        
        burnCollateral(_requestId, r);
    }
    
    function burnCollateral(uint256 _requestId, Request storage r) internal {

        uint256 cryptoToTransfer = getInterest(r.ltv, r.cryptoAmount).add(r.cryptoAmount);
        
        uint256[] memory amounts = sellCollateralInUniswap(cryptoToTransfer, r.weiAmount, r.currency);
        
        uint256 dust = r.weiAmount.sub(amounts[0]);
        
        uint256 totalLenderFee = computeLenderFee(r.cryptoAmount);
        uint256 totalBorrowerFee = computeBorrowerFee(r.weiAmount);

        if (totalBorrowerFee > dust) {
            totalBorrowerFee = dust;
        }
        
        if (r.currency == Currency.DAI) {
            daiFees = daiFees.add(totalLenderFee);
            depositedDAI[r.lender] += cryptoToTransfer.sub(totalLenderFee);
        } else {
            usdtFees = usdtFees.add(totalLenderFee);
            depositedUSDT[r.lender] += cryptoToTransfer.sub(totalLenderFee);
        }

        ethFees = ethFees.add(totalBorrowerFee);
        depositedWEI[r.borrower] += dust.sub(totalBorrowerFee);
        
        emit CollateralSoldBorrower(_requestId, r.borrower, r.weiAmount, amounts[0], cryptoToTransfer, dust.sub(totalBorrowerFee), totalBorrowerFee);
        emit CollateralSoldLender(_requestId, r.lender, r.weiAmount, amounts[0], cryptoToTransfer, cryptoToTransfer.sub(totalLenderFee), totalLenderFee);
    }
    
    function sellCollateralInUniswap(uint256 tokensToTransfer, uint256 weiAmount, Currency currency) internal returns (uint256[] memory)  {
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        
        if (currency == Currency.DAI) {
            path[1] = address(daiToken);
        } else {
            path[1] = address(usdtToken);
        }
        
        return uniswapRouter.swapETHForExactTokens{value:weiAmount}(tokensToTransfer, path, address(this), block.timestamp);
    }

    function canBurnCollateralForDAI(uint256 requestId, uint256 daiVsWeiCurrentPrice) public view returns (bool) {
        Request memory r = requests[requestId];
        
        uint256 howMuchEthTheUserCanGet = r.cryptoAmount.mul(daiVsWeiCurrentPrice).div(1e18);
        uint256 eigthyPercentOfCollateral = r.weiAmount.mul(8).div(10);
        
        return howMuchEthTheUserCanGet > eigthyPercentOfCollateral;
    }    

    function canBurnCollateralForUSDT(uint256 requestId, uint256 usdtVsWeiCurrentPrice) public view returns (bool) {
        Request memory r = requests[requestId];
        
        uint256 howMuchEthTheUserCanGet = r.cryptoAmount.mul(usdtVsWeiCurrentPrice).div(1e6);
        uint256 eigthyPercentOfCollateral = r.weiAmount.mul(8).div(10);
        
        return howMuchEthTheUserCanGet > eigthyPercentOfCollateral;
    }    
    
    function calculateWeiAmountForDAI(uint256 _daiAmount, uint256 _ltv, uint256 _daiVsWeiCurrentPrice) public pure returns (uint256) {
        return _daiAmount.mul(100).div(_ltv).mul(_daiVsWeiCurrentPrice).div(1e18);
    }

    function calculateWeiAmountForUSDT(uint256 _usdtAmount, uint256 _ltv, uint256 _usdtVsWeiCurrentPrice) public pure returns (uint256) {
        return _usdtAmount.mul(100).div(_ltv).mul(_usdtVsWeiCurrentPrice).div(1e6);
    }

    function calculateCollateralForDAI(uint256 daiAmount, uint256 ltv) public view returns (uint256) {
        uint256 daiVsWeiCurrentPrice = uint256(priceConsumerDAI.getLatestPrice());
        return calculateWeiAmountForDAI(daiAmount, ltv, daiVsWeiCurrentPrice);
    }
    
    function calculateCollateralForUSDT(uint256 usdtAmount, uint256 ltv) public view returns (uint256) {
        uint256 usdtVsWeiCurrentPrice = uint256(priceConsumerUSDT.getLatestPrice());
        return calculateWeiAmountForUSDT(usdtAmount, ltv, usdtVsWeiCurrentPrice);
    }
    
    function getLatestDAIVsWeiPrice() public view returns (uint256) {
        return uint256(priceConsumerDAI.getLatestPrice());
    }

    function getLatestUSDTVsWeiPrice() public view returns (uint256) {
        return uint256(priceConsumerUSDT.getLatestPrice());
    }
    
    function getInterest(uint256 _ltv, uint256 _amount) public view returns (uint256) {
        require(interests[_ltv] > 0, "invalid LTV");
        return _amount.mul(interests[_ltv]).div(100);
    }
    
    function computeLenderFee(uint256 _value) public view returns (uint256) {
        return _value.mul(lenderFee).div(100); 
    }

    function computeBorrowerFee(uint256 _value) public view returns (uint256) {
        return _value.mul(borrowerFee).div(100); 
    }
    
    function getExpirationAfter(uint256 amountOfDays) public view returns (uint256) {
        return block.timestamp.add(amountOfDays.mul(1 days));
    }
    
    
    function withdrawUSDT(uint256 _amount) public {
        require(depositedUSDT[msg.sender] >= _amount, "Not enough USDT deposited");
        require(ERC20(usdtToken).balanceOf(address(this)) >= _amount, "Not enough balance in contract");
        
        depositedUSDT[msg.sender] = depositedUSDT[msg.sender].sub(_amount);
        ERC20(usdtToken).safeTransfer(msg.sender, _amount);
        
        emit CoinWithdrawn(msg.sender, _amount, Currency.USDT);
    }

    function withdrawDAI(uint256 _amount) public {
        require(depositedDAI[msg.sender] >= _amount, "Not enough DAI deposited");
        require(daiToken.balanceOf(address(this)) >= _amount, "Not enough balance in contract");
        
        depositedDAI[msg.sender] = depositedDAI[msg.sender].sub(_amount);
        require(daiToken.transfer(msg.sender, _amount));
        
        emit CoinWithdrawn(msg.sender, _amount, Currency.DAI);
    }
    
    function withdrawETH(uint256 _amount) public {
        require(depositedWEI[msg.sender] >= _amount, "Not enough ETH deposited");
        require(address(this).balance >= _amount, "Not enough balance in contract");
        
        depositedWEI[msg.sender] = depositedWEI[msg.sender].sub(_amount);
        msg.sender.transfer(_amount);
        
        emit CoinWithdrawn(msg.sender, _amount, Currency.ETH);
    }
    
        function _updateNexenTokenAddress(IERC20 _nexenToken) public onlyOwner {
        nexenToken = _nexenToken;
    }

    function depositETH() public payable {
        require(msg.value > 10000000000000000, 'Minimum is 0.01 ETH');
        depositedWEI[msg.sender] += msg.value;

        emit CoinDeposited(msg.sender, msg.value, Currency.ETH);
    }

    function depositDAI(uint256 _amount) public {
        require(IERC20(daiToken).transferFrom(msg.sender, address(this), _amount), "Couldn't take the DAI from the sender");
        depositedDAI[msg.sender] += _amount;

        emit CoinDeposited(msg.sender, _amount, Currency.DAI);
    }
    
    
    function depositUSDT(uint256 _amount) public {
        ERC20(usdtToken).safeTransferFrom(msg.sender, address(this), _amount);
        depositedUSDT[msg.sender] += _amount;
        
        emit CoinDeposited(msg.sender, _amount, Currency.USDT);
    }
    
        
    function _expireRequest(uint256 _requestId) public onlyOwner {
        Request storage r = requests[_requestId];

        require(r.state == RequestState.Matched, "State needs to be Matched");
        
        if (r.currency == Currency.DAI) {
            uint256 daiVsWeiCurrentPrice = uint256(priceConsumerDAI.getLatestPrice());
            require(canBurnCollateralForDAI(_requestId, daiVsWeiCurrentPrice), "We cannot burn the collateral");
        } else {
            uint256 usdtVsWeiCurrentPrice = uint256(priceConsumerUSDT.getLatestPrice());
            require(canBurnCollateralForUSDT(_requestId, usdtVsWeiCurrentPrice), "We cannot burn the collateral");
        }
        
        r.state = RequestState.Disabled;

        burnCollateral(_requestId, r);
    }
    
    function _setInterest(uint256 _ltv, uint256 _interest) public onlyOwner {
        interests[_ltv] = _interest;
    }
    
    function _withdrawFees(Currency currency) public onlyOwner {
        if (currency == Currency.ETH) {
            uint256 amount = ethFees;
            ethFees = 0;
            msg.sender.transfer(amount);
        } else if (currency == Currency.USDT) {
            uint256 amount = usdtFees;
            usdtFees = 0;
            ERC20(usdtToken).safeTransfer(msg.sender, amount);
        } else { 
            uint256 amount = daiFees;
            daiFees = 0;
            require(daiToken.transfer(msg.sender, amount), "Transfer failed");
        }
    }
    
    function _setGenesisPhase(IERC20 _nexenToken, bool _genesisPhase, uint256 _amountToReward) public onlyOwner {
        nexenToken = _nexenToken;
        genesisPhase = _genesisPhase;
        amountToReward = _amountToReward;
    }
    
    function _setPaused(bool _paused) public onlyOwner {
        paused = _paused;
    }
    
    function _recoverNexenTokens(uint256 _amount) public onlyOwner {
        require(nexenToken.transfer(msg.sender, _amount), 'Could not transfer tokens');
    }
    
    function requestInfo(uint256 requestId) public view  returns (uint256 _tradeId, RequestState _state, address _borrower, address _lender, uint256 _cryptoAmount, uint256 _durationInDays, uint256 _expireIfNotMatchedOn, uint256 _ltv, uint256 _weiAmount, uint256 _tokenVsWeiCurrentPrice, uint256 _lendingFinishesOn, Currency currency) {
        Request storage r = requests[requestId];
        uint256 tokenVsWeiCurrentPrice = r.daiVsWeiCurrentPrice;
        if (r.currency == Currency.USDT) {
            tokenVsWeiCurrentPrice = r.usdtVsWeiCurrentPrice;
        }
        return (requestId, r.state, r.borrower, r.lender, r.cryptoAmount, r.durationInDays, r.expireIfNotMatchedOn, r.ltv, r.weiAmount, tokenVsWeiCurrentPrice, r.lendingFinishesOn, r.currency);
    }
}