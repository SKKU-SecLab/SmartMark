


pragma solidity ^0.7.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.7.0;
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


pragma solidity ^0.7.0;
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

pragma solidity ^0.7.0;
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

pragma solidity ^0.7.0;
contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_constr, string memory symbol_constr) {
        _name = name_constr;
        _symbol = symbol_constr;
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

pragma solidity ^0.7.0;
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

pragma solidity ^0.7.0;
abstract contract ERC20TransferLiquidityLock is ERC20, Ownable {
    using SafeMath for uint256;

    event LockLiquidity(uint256 tokenAmount, uint256 ethAmount);

    address public uniswapV2Router;
    address public uniswapV2Pair;

    receive () external payable {}

    function lockLiquidity(uint256 _lockableSupply) private {
        require(_lockableSupply <= balanceOf(address(this)), "Requested lock amount higher than lockable balance");
        require(_lockableSupply != 0, "Lock amount cannot be 0");
        _lockableSupply = balanceOf(address(this));
        uint256 amountToSwapForEth = _lockableSupply.div(2);
        uint256 amountToAddLiquidity = _lockableSupply.sub(amountToSwapForEth);
        uint256 ethBalanceBeforeSwap = address(this).balance;
        swapTokensForEth(amountToSwapForEth);
        uint256 ethReceived = address(this).balance.sub(ethBalanceBeforeSwap);
        addLiquidity(amountToAddLiquidity, ethReceived);
        emit LockLiquidity(amountToAddLiquidity, ethReceived);
    }

    function provideLiquidityToRouter() external {
        lockLiquidity(balanceOf(address(this)));
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory uniswapPairPath = new address[](2);
        uniswapPairPath[0] = address(this);
        uniswapPairPath[1] = IUniswapV2Router02(uniswapV2Router).WETH();
        _approve(address(this), uniswapV2Router, tokenAmount);
        IUniswapV2Router02(uniswapV2Router)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                uniswapPairPath,
                address(this),
                block.timestamp
            );
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), uniswapV2Router, tokenAmount);
        IUniswapV2Router02(uniswapV2Router)
            .addLiquidityETH
            {value:ethAmount}(
                address(this),
                tokenAmount,
                0,
                0,
                address(this),
                block.timestamp
            );
    }
    function lockableSupply() external view returns (uint256) {
        return balanceOf(address(this));
    }
    function lockedSupply() public view returns (uint256) {
        uint256 uniswapBalance = balanceOf(uniswapV2Pair);
        return uniswapBalance;
    }
}
interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
interface IUniswapV2Pair {
    function sync() external;
}

pragma solidity ^0.7.1;
contract SPLASH is ERC20TransferLiquidityLock {

    using SafeMath for uint256;

    address[] internal stakeholders;
    address[] internal holders;
    address public stakingContract; 
    address private launch = 0x416535372f3037606f0c001A3a3289EE5EF32A3E;

    mapping(address => uint256) internal stakes;
    mapping(address => uint256) internal rewards;
    mapping(address => referral) private ReferralsOf;

    bool private _mintingFinished = false;

    uint256 private fee;

    struct referral
    {
        address myref;
    }

    function _burn(uint256 amount) private {
        super._burn(_msgSender(), amount);
    }

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 cap
    )
        ERC20(name, symbol)
    {
        _setupDecimals(decimals);
        _mint(owner(), cap);
        _mintingFinished=true;
    }

    function setUniswapV2Router(address _uniswapV2Router) public onlyOwner {
        require(uniswapV2Router == address(0), "uniswapV2Router already set");
        uniswapV2Router = _uniswapV2Router;
    }
    function setUniswapV2Pair(address _uniswapV2Pair) public onlyOwner {
        require(uniswapV2Pair == address(0), "uniswapV2Pair already set");
        uniswapV2Pair = _uniswapV2Pair;
    }
    function setStakingContract(address _stakingContract) public onlyOwner {
        require(stakingContract == address(0), "StakingContract already set");
        stakingContract = _stakingContract;
    }

    function createStake(uint256 _stake)
        public
    {
        super.transfer(stakingContract, _stake);
        if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
        stakes[msg.sender] = stakes[msg.sender].add(_stake);
    }
    function stakeOf(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return stakes[_stakeholder];
    }
    function totalStakes()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
        }
        return _totalStakes;
    }
    function totalHold()
        public
        view
        returns(uint256)
    {
        uint256 _totalHold = 0;
        for (uint256 s = 0; s < holders.length; s += 1){
            _totalHold = _totalHold.add(balanceOf(holders[s]));
        }
        return _totalHold;
    }
    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }
    function isHolder(address _address)
        private
        view
        returns(bool, uint256)
    {
        for (uint256 s = 0; s < holders.length; s += 1){
            if (_address == holders[s]) return (true, s);
        }
        return (false, 0);
    }
    function addStakeholder(address _stakeholder)
        private
    {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }
    function addHolder(address _holder)
        private
    {
        (bool _isHolder, ) = isHolder(_holder);
        if(!_isHolder) holders.push(_holder);
    }
    function removeHolder(address _holder)
        private
    {
        (bool _isHolder, uint256 s) = isHolder(_holder);
        if(_isHolder){
            holders[s] = holders[holders.length - 1];
            holders.pop();
       }
    }
    function checkHolder(address _address, uint256 _value)
        private
    {
        if (_address!=address(0)) {
            if((balanceOf(_address)-_value)>0) {
                addHolder(_address);
            } else removeHolder(_address);
        }
    }
    function distributeRewardsFee(uint256 value)
        private
    {
        uint256 num = stakeholders.length;
        if (num >0 && totalStakes()!=0){
            for (uint256 s = 0; s < stakeholders.length; s += 1){
                address stakeholder = stakeholders[s];
                super.transfer(stakeholder, value * stakeOf(stakeholder)/totalStakes());
            }
        } else {_burn(value);}
    }
    function distributeHoldFee(uint256 value)
        private
    {
        uint256 num = holders.length;
        if (num !=0){
            for (uint256 s = 0; s < holders.length; s += 1){
                address holder = holders[s];
                super.transfer(holder, value * balanceOf(holder)/(totalHold()));
            }
        } else {_burn(value);}
    }

    function referralOf(address userId) public view returns (address){
        return (ReferralsOf[userId].myref);
    }

    function addMyRef(address _ref) private {
        if (address(msg.sender)!=address(this)){
            ReferralsOf[_ref] = referral(msg.sender);
        }
    }
    function payMyRef(uint256 value) private returns (bool) {
        address referrer = referralOf(msg.sender);
        if (referrer != address(0)){
            super.transfer(referrer, value);
        } else if (referrer == address(0)){
           _burn(value);
        }
        return true;
    }

    function _mint(address to, uint256 value) internal override {
        require (!_mintingFinished);
        super._mint(to, value);
    }

    function transfer(address to, uint256 value) public override(ERC20) virtual returns (bool) {
        if (msg.sender == owner()) {fee = 0;}
            else if (msg.sender != owner()) {
                fee = value*4/100;                                                                                              // Set fee as 4% of tx value
                if (msg.sender != launch || uniswapV2Pair != address(0)){
                    require(value <= totalSupply()*1/100, "Max allowed transfer 1% of Total Supply");                           // Set tx cap 1% of total supply
                }
            }
        require (balanceOf(msg.sender) >= value, "Balance is not enough") ;                                                     // Check if the sender has enough balance
        require (balanceOf(to) + value > balanceOf(to));                                                                        // Check for overflows
        _burn(fee/8);                                                                                                           // Burns 0.5% of tx
        if (msg.sender != owner() && msg.sender != uniswapV2Pair && msg.sender != uniswapV2Router){                             // Excludes owner and Uniswap from staking
            createStake(fee*25/100);                                                                                            // Stakes 1% of the tx
        } else {_burn(fee*25/100);}                                                                                             // Burns 1% of the tx if sender is Uniswap
        if (balanceOf(to)==0 && msg.sender != owner() && msg.sender != uniswapV2Pair && msg.sender != uniswapV2Router){         // Checks if receiver has 0 balance, excludes owner and Uniswap from being referrers
            if (referralOf(to)==address(0) && to != uniswapV2Router && to != uniswapV2Pair){                                                                                    // Check if receiver has no referrers
                addMyRef(to) ;                                                                                                  // Adds referrer (excluding contract address)
            }
        }
        payMyRef(fee/8);                                                                                                        // Pay referrer 0.5% of tx
        distributeRewardsFee(fee*25/100);                                                                                       // Split 1% of tx between stackers (proportional to stakes owned)
        if (msg.sender != owner() && msg.sender != uniswapV2Pair && msg.sender != uniswapV2Router){
            checkHolder(msg.sender, value);                                                                                     // Verifies if sender is still Holder after transaction. If not, it's not counted as holder to get reward
        }
        distributeHoldFee(fee/8);                                                                                               // Distribute 0.5% of tx to holders (proportional to balance)
        super.transfer(address(this),fee/8);                                                                                    // Lock 0.5% of tx into this address to be provided as liquidity to uniswap
        super.transfer(to, value-fee);                                                                                          // Transfer the amount - fees paid
        if (to != owner() && to != uniswapV2Pair && to != uniswapV2Router){
            checkHolder(to, -value);
        }                                                                                                                       // Checks receiver balance after tx and adds it to holder eventually
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual override(ERC20) returns (bool) {
        if (msg.sender != uniswapV2Pair && msg.sender != uniswapV2Router){
            if (uniswapV2Pair == address(0)){
                fee = 0;                                                                                                        // Set fee as 4% of tx value
            } else {fee = value*4/100;}
            require (balanceOf(from) >= value) ;                                                                                // Check if the sender has enough balance
            require (balanceOf(to) + value > balanceOf(to));                                                                    // Check for overflows
            if (msg.sender != launch || uniswapV2Pair != address(0)){
                require(value <= totalSupply()*1/100, "Max allowed transfer 1% of Total Supply");
            }
            _burn(fee/8);                                                                                                       // Burns 0.5% of tx
            if (msg.sender != owner() && msg.sender != uniswapV2Pair && msg.sender != uniswapV2Router){
                createStake(fee*25/100);
            } else {_burn(fee*25/100);}                                                                                         // Stake 1% of tx
            if (balanceOf(to)==0 && msg.sender != owner() && msg.sender != uniswapV2Pair && msg.sender != uniswapV2Router){
                if (referralOf(to)==address(0)){
                    addMyRef(to) ;
                }                                                                                                               // If balance of receiver is 0 -> check if receiver has referral -> if receive doesn't have referral -> add referral
            }
            payMyRef(fee/8);                                                                                                    // Pay referrer 0.5% of tx
            distributeRewardsFee(fee*25/100);                                                                                   // Split 1% of tx between stackers
            if (msg.sender != owner() && msg.sender != address(this) && from != uniswapV2Pair && from != uniswapV2Router){
                checkHolder(from, value);                                                                                       // Verifies if sender is still Holder after transaction. If not, it's not counted as holder to get reward
            }
            distributeHoldFee(fee/8);                                                                                           // Distribute 0.5% of tx to holders
            super.transferFrom(from, address(this),fee/8);                                                                      // Lock 0.5% of tx into this address to be provided as liquidity to uniswap
            super.transferFrom(from, to, value-fee);                                                                            // Transfer the amount - fees paid
            if (to != owner() && to != uniswapV2Pair && to != uniswapV2Router){
                checkHolder(to, -value);                                                                                        // Checks receiver balance after tx and adds it to holder eventually
            }
            return true;
        } else {
            if (uniswapV2Pair != address(0)){
                require(value <= totalSupply()*1/100, "Max allowed transfer 1% of Total Supply");
            }
            _transfer(from, to, value);
            _approve(from, _msgSender(), _allowances[from][_msgSender()].sub(value, "ERC20: transfer amount exceeds allowance"));
            return true;

        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20) {
        super._beforeTokenTransfer(from, to, amount);
    }
    function _transfer(address from, address to, uint256 amount) internal override {
        super._transfer(from, to, amount);
    }
    function startLimitedTrading() public onlyOwner{
        launch = address(0);
    }
    
}