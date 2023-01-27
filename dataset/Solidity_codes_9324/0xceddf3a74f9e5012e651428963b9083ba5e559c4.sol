
pragma solidity ^0.6.2;

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

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

contract FX99 is ERC20("FX99", "XCIX") {
    address public wallet_99_strong_hand = 0xdCD272B4e7597640f20287a1D6D525f4d0034394;
    uint256 public initialPrice = 0.001 szabo;
    uint256 public increment = 0.001 szabo;
    uint256 public minPurchase = 1 ether;
    uint256 public reinvestFee = 10;
    uint256 public transferFee = 10;
    uint256 public withdrawFee = 10;
    uint256 public referrerFee = 5;
    uint256 public buyFee = 10;
    uint256 public sellFee = 10;
    uint256 public dividendsPerShare;
    uint256 public start;
    uint256 constant internal magnitude = 1 ether;
    mapping (address => address) public referrer;
    mapping (address => uint256) public referralEarnings;
    mapping (address => int256) public dividendsPayouts;

    event Reinvest(address _member, uint256 _ether, uint256 _tokens);
    event Withdraw(address _member, uint256 _ether);
    event Buy(address _member, uint256 _ether, uint256 _tokens, address _referrer);
    event Sell(address _member, uint256 _ether, uint256 _tokens);

    constructor () public {
        start = now;
    }

    function getDividends(address _member)
        public
        view
        returns(uint256)
    {
        uint256 _balance = balanceOf(_member);
        uint256 _dividends = (uint256)((int256)(_balance.mul(dividendsPerShare)) - dividendsPayouts[_member])
        .div(magnitude);
        uint256 _contractBalance = address(this).balance;

        if (_dividends > _contractBalance) return _contractBalance;
        return _dividends;
    }

    function reinvest()
        public
        returns(uint256)
    {
        uint256 _ether = getDividends(msg.sender);

        dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender] 
            + (int256)(_ether.mul(magnitude));

        _ether = _ether
        .add(referralEarnings[msg.sender]);
        referralEarnings[msg.sender] = 0;

        uint256 _fee = _ether.mul(reinvestFee).div(100);
        uint256 _reinvest = _ether.sub(_fee);

        uint256 _tokens = ethToTokens(_reinvest);

        require (_tokens >= minPurchase, 
            'Token equivalent amount should not be less than 1 token');

        dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender]
            + (int256)(dividendsPerShare.mul(_tokens));

        emit Reinvest(msg.sender, _ether, _tokens);
        _mint(msg.sender, _tokens);

        uint256 _supply = totalSupply();
        if (_supply > 0) {
            dividendsPerShare = dividendsPerShare
            .add(_fee.mul(magnitude).div(_supply));
        } else {
            dividendsPerShare = 0;
        }        
    }








    function withdraw()
        public
        returns(bool)
    {
        uint256 _ether = getDividends(msg.sender);
        dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender] 
            + (int256)(_ether.mul(magnitude));

        _ether = _ether
        .add(referralEarnings[msg.sender]);
        referralEarnings[msg.sender] = 0;

        uint256 _fee = _ether.mul(withdrawFee).div(100);
        uint256 _withdraw = _ether.sub(_fee);

        uint256 _tokens = ethToTokens(_withdraw);

        require (_tokens >= minPurchase, 
            'Token equivalent amount should not be less than 1 token');

        emit Withdraw(msg.sender, _ether);

        payable(wallet_99_strong_hand).transfer(_fee);
        payable(msg.sender).transfer(_withdraw);
        return true;
    }

    function transfer(address _recipient, uint256 _amount) public override returns (bool) {
        require (_amount >= minPurchase, 
            'Token amount should not be less than 1 token');
        require (_amount <= balanceOf(msg.sender), 
            'Token amount should not be greater than balance');
        uint256 _fee = _amount.mul(transferFee).div(100);
        uint256 _tokens = _amount.sub(_fee);

        dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender]
            - (int256)(dividendsPerShare.mul(_amount));
        dividendsPayouts[_recipient] = dividendsPayouts[_recipient]
            + (int256)(dividendsPerShare.mul(_tokens));

        _burn(msg.sender, _fee);

        dividendsPerShare = dividendsPerShare
        .add(tokensToEth(_fee).mul(magnitude).div(totalSupply()));
        return super.transfer(_recipient, _tokens);
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool) {
        require (_amount >= minPurchase, 
            'Token amount should not be less than 1 token');
        require (_amount <= balanceOf(_sender), 
            'Token amount should not be greater than balance');
        uint256 _fee = _amount.mul(transferFee).div(100);
        uint256 _tokens = _amount.sub(_fee);

        dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender]
            - (int256)(dividendsPerShare.mul(_amount));
        dividendsPayouts[_recipient] = dividendsPayouts[_recipient]
            + (int256)(dividendsPerShare.mul(_tokens));

        _burn(_sender, _fee);

        dividendsPerShare = dividendsPerShare
        .add(tokensToEth(_fee).mul(magnitude).div(totalSupply()));
        return super.transferFrom(_sender, _recipient, _tokens);
    }    
    
    receive() payable external {
        purchase(msg.value, address(0));
    }

    function buy(address _referrer) payable external {
        purchase(msg.value, _referrer);
    }

    function purchase(uint256 _amount, address _referrer) internal {
        require (msg.sender != _referrer, 'You can not be your referrer');
        uint256 _refFee = _amount.mul(referrerFee).div(100);
        uint256 _buyFee = _amount.mul(buyFee).div(100);
        uint256 _totalFee = _refFee.add(_buyFee);
        if (referrer[msg.sender] == address(0)
            && _referrer != address(0)
            && balanceOf(_referrer) >= 99 ether) {
            referrer[msg.sender] = _referrer;
            referralEarnings[_referrer] = referralEarnings[_referrer]
            .add(_refFee);
        } else {
            _buyFee = _totalFee;
        }
        
        uint256 _tokens = ethToTokens(_amount.sub(_totalFee));

        require (_tokens >= minPurchase, 
            'Tokens amount should not be less than 1 token');

        emit Buy(msg.sender, _amount, _tokens, _referrer);

        _mint(msg.sender, _tokens);
        uint256 _supply = totalSupply();

        uint256 _extra = _buyFee
        .mul(magnitude)
        .div(_supply);

        if (dividendsPerShare > 0) {
            dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender]
            + (int256)(dividendsPerShare.mul(_tokens));
        }

        dividendsPerShare = dividendsPerShare
        .add(_extra);
    }

    function sell(uint256 _tokens) external {
        require (_tokens >= minPurchase, 
            'Tokens amount should not be less than 1 token');
        require (_tokens <= balanceOf(msg.sender), 
            'Not enough tokens');
        uint256 _amount = tokensToEth(_tokens);
        uint256 _fee = _amount.mul(sellFee).div(100);

        emit Sell(msg.sender, _amount, _tokens);

        _burn(msg.sender, _tokens);

        dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender] 
            - (int256)(dividendsPerShare.mul(_tokens));

        uint256 _supply = totalSupply();

        if (_supply > 0) { 
            dividendsPerShare = dividendsPerShare
            .add(_fee.mul(magnitude).div(_supply));
        } else {
            dividendsPerShare = 0;
            dividendsPayouts[msg.sender] = dividendsPayouts[msg.sender]
                - (int256)(_fee.mul(magnitude));
        }

        payable(msg.sender)
        .transfer(_amount.sub(_fee));
    }

    function getCurrentPrice () public view returns(uint256) {
        uint256 supply = totalSupply();
        uint256 supplyInt = supply.div(1 ether);
        return supplyInt.mul(increment).add(initialPrice);
    }

    function ethToTokens(uint256 _ether)
        public
        view
        returns(uint256)
    {
        uint256 eth = _ether;
        uint256 supply = totalSupply();
        uint256 supplyInt = supply.div(1 ether);
        uint256 supplyFract = supply.sub(supplyInt.mul(1 ether));
        uint256 currentPrice = supplyInt.mul(increment).add(initialPrice);
        uint256 tokens;
        uint256 tempTokens = eth.mul(1 ether).div(currentPrice);

        if (tempTokens < supplyFract) {
            return tempTokens;
        }

        tokens = tokens.add(supplyFract);

        eth = eth.sub(supplyFract.mul(currentPrice).div(1 ether));
        if (supplyFract > 0) {
            currentPrice = currentPrice.add(increment);
        }
        tempTokens = eth.mul(1 ether).div(currentPrice);

        if (tempTokens <= 1 ether) {
            return tokens.add(tempTokens);
        }

        uint256 d = currentPrice.mul(2)
        .sub(increment);
        d = d.mul(d);
        d = d.add(increment.mul(eth).mul(8));

        uint256 sqrtD = sqrt(d);
        
        tempTokens = increment
        .add(sqrtD)
        .sub(currentPrice.mul(2));

        tempTokens = tempTokens
        .mul(1 ether)
        .div(increment.mul(2));

        tokens = tokens.add(tempTokens);

        return tokens;
    }
    
     function tokensToEth(uint256 _tokens)
        public
        view
        returns(uint256)
    {
        uint256 tokens = _tokens;
        uint256 supply = totalSupply();
        if (tokens > supply) return 0;
        uint256 supplyInt = supply.div(1 ether);
        uint256 supplyFract = supply.sub(supplyInt.mul(1 ether, '1'));
        uint256 currentPrice = supplyInt.mul(increment).add(initialPrice);
        uint256 eth;

        if (tokens < supplyFract) {
            return tokens.mul(currentPrice).div(1 ether);
        }

        eth = eth.add(supplyFract.mul(currentPrice).div(1 ether));
        tokens = tokens.sub(supplyFract);

        if (supplyFract > 0) {
            currentPrice = currentPrice.sub(increment);
        }

        if (tokens <= 1 ether) {
            return eth.add(tokens.mul(currentPrice).div(1 ether));
        }

        uint256 tokensInt = tokens.div(1 ether);
        uint256 tokensFract;
        if (tokensInt > 1) {
            tokensFract = tokens.sub(tokensInt.mul(1 ether));
        }

        uint256 tempEth = currentPrice
        .mul(2)
        .sub(increment.mul(tokensInt.sub(1)));

        tempEth = tempEth
        .mul(tokensInt)
        .div(2);

        eth = eth.add(tempEth);

        currentPrice = currentPrice.sub(increment.mul(tokensInt));
        eth = eth
        .add(currentPrice.mul(tokensFract).div(1 ether));
        return eth;
    }
    
    function sqrt(uint x) public pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function contractBalance() 
        public
        view
        returns(uint256)
    {
        return address(this).balance;
    }
}