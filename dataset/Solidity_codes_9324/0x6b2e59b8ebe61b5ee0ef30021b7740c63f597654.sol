

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

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    function decimals() external view returns (uint8);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.2;

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


pragma solidity ^0.6.0;

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

    function decimals() public view override returns (uint8) {

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

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

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

    function governance() public view returns (address) {

        return _owner;
    }

    modifier onlyGovernance() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferGovernance(address newOwner) internal virtual onlyGovernance {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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


pragma solidity ^0.6.6;

interface LendingPoolAddressesProvider {

    function getLendingPool() external view returns (address);

    function getLendingPoolCore() external view returns (address);

}

interface LendingPool {

    function deposit(address, uint256, uint16) external;

}

interface aTokenContract is IERC20 {

    function redeem(uint256 _amount) external;

}

interface StabilizeStakingPool {

    function notifyRewardAmount(uint256) external;

}

interface StabilizePriceOracle {

    function getPrice(address _address) external view returns (uint256);

}

interface UniswapRouter {

    function WETH() external pure returns (address); // Get address for WETH

    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external returns (uint[] memory);

}

contract zpaToken is ERC20("Stabilize Proxy Aave USDT Token", "zpa-USDT"), Ownable {

    using SafeERC20 for IERC20;

    uint256 constant divisionFactor = 100000;
    
    uint256 public maxFee = 100; // 100 = 0.1%, 100000 = 100%, max fee restricted in contract is 10%
    uint256 public minFee = 20; // 20 = 0.02%
    
    uint256 public percentStakers = 50000; // 50% of WETH goes to stakers, can be changed
    
    address public aaveProviderAddress = 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8;
    LendingPoolAddressesProvider aaveProvider;
    IERC20 private _underlyingAsset; // Token of the deposited asset
    aTokenContract private _aToken; // The aToken returned to this contract by depositing
    address public treasuryAddress;
    address public stakingAddress; // Address to the STBZ staking pool
    StabilizePriceOracle private oracleContract; // A reference to the price oracle contract
    
    address constant uniswapRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); //Address of Uniswap Router v2
    
    event Wrapped(address indexed user, uint256 amount);
    event Unwrapped(address indexed user, uint256 amount, uint256 fee);
    
    constructor (IERC20 _asset, aTokenContract _aavetoken, address _treasury, address _staking, StabilizePriceOracle _oracle) public {
        _underlyingAsset = _asset;
        _aToken = _aavetoken;
        treasuryAddress = _treasury;
        stakingAddress = _staking;
        oracleContract = _oracle;
        aaveProvider = LendingPoolAddressesProvider(aaveProviderAddress); // Load the lending address provider
        _setupDecimals(_aToken.decimals());
    }

    function underlyingAsset() public view returns (address) {

        return address(_underlyingAsset);
    }
    
    function totalPrincipalAndInterest() public view returns (uint256) {

        return _aToken.balanceOf(address(this)); // This will be the same balance as all deposited plus interest earned
    } 
    
    function pricePerToken() external view returns (uint256) {

        if(totalSupply() == 0){
            return 1e18; // Shown in Wei units
        }else{
            return uint256(1e18).mul(totalPrincipalAndInterest()).div(totalSupply());
        }
    }
    
    function calculateWithdrawFee() public view returns (uint256) {

        if(maxFee == 0){return 0;} // Bypass if there is no fee
        uint256 price = oracleContract.getPrice(underlyingAsset());
        if(price == 0){
            price = 1e18; // Default price is $1
        }
        uint256 highPrice = 1020000000000000000; // 1.02
        uint256 lowPrice = 980000000000000000; // 0.98
        uint256 fee = 0;
        if(price >= highPrice){
            fee = minFee;
        }else if(price <= lowPrice){
            fee = maxFee;
        }else{
            uint256 feeRange = maxFee.sub(minFee);
            uint256 priceRange = highPrice.sub(lowPrice);
            uint256 diff = price.sub(lowPrice).mul(feeRange).div(priceRange); // The difference between the current price and the minimum
            fee = maxFee.sub(diff);
        }
        return fee;
    }
    
    function deposit(uint256 amount) public {

        require(amount > 0, "Cannot deposit 0");
        _underlyingAsset.safeTransferFrom(_msgSender(), address(this), amount); // Transfer stablecoin to this address
        
        LendingPool lendingPool = LendingPool(aaveProvider.getLendingPool()); // Get the lending pool
        _underlyingAsset.safeApprove(aaveProvider.getLendingPoolCore(), amount);
        
        uint256 total = totalPrincipalAndInterest();
        uint256 _underlyingBalance = _underlyingAsset.balanceOf(address(this));
        lendingPool.deposit(underlyingAsset(), amount, 0); // Last field is referral code, there is none
        uint256 movedBalance = _underlyingBalance.sub(_underlyingAsset.balanceOf(address(this)));
        require(movedBalance == amount, "Aave failed to properly move the entire amount");
        
        uint256 mintAmount = amount;
        if(totalSupply() > 0){
            mintAmount = amount.mul(totalSupply()).div(total); // Our share of the total
        }
        _mint(_msgSender(),mintAmount); // Now mint new zpa-token to the depositor
        
        emit Wrapped(_msgSender(), amount);
    }
    
    function redeem(uint256 amount) public {

        require(amount > 0, "Cannot withdraw 0");
        require(totalSupply() > 0, "No value redeemable");
        uint256 tokenTotal = totalSupply();
        _burn(_msgSender(),amount); // Burn the amount, will fail if user doesn't have enough

        uint256 withdrawAmount = totalPrincipalAndInterest().mul(amount).div(tokenTotal);
        uint256 _underlyingBalance = _underlyingAsset.balanceOf(address(this)); // Get the underlying asset amount in contract
        _aToken.redeem(withdrawAmount); // Burn the aTokens to redeem the underlying asset 1:1
        uint256 movedBalance = _underlyingAsset.balanceOf(address(this)).sub(_underlyingBalance);
        require(movedBalance >= withdrawAmount, "Aave failed to properly move the entire amount"); // Should be equal at least
        
        uint256 fee = calculateWithdrawFee();
        fee = withdrawAmount.mul(fee).div(divisionFactor);
        withdrawAmount = withdrawAmount.sub(fee);
        
        _underlyingAsset.safeTransfer(_msgSender(), withdrawAmount);
        
        
        if(fee > 0){
            UniswapRouter router = UniswapRouter(uniswapRouterAddress);
            IERC20 weth = IERC20(router.WETH());
            swapUniswap(address(_underlyingAsset), address(weth), fee);
            if(weth.balanceOf(address(this)) > 0){
                uint256 stakersAmount = weth.balanceOf(address(this)).mul(percentStakers).div(divisionFactor);
                uint256 treasuryAmount = weth.balanceOf(address(this)).sub(stakersAmount);
                if(treasuryAmount > 0){
                    weth.safeTransfer(treasuryAddress, treasuryAmount);
                }
                if(stakersAmount > 0){
                    if(stakingAddress != address(0)){
                        weth.safeTransfer(stakingAddress, stakersAmount);
                        StabilizeStakingPool(stakingAddress).notifyRewardAmount(stakersAmount);                                
                    }else{
                        weth.safeTransfer(treasuryAddress, stakersAmount);
                    }
                }
            }
        }
        
        emit Unwrapped(_msgSender(), withdrawAmount, fee);
    }
    
    function swapUniswap(address _from, address _to, uint256 _sellAmount) internal {

        require(_to != address(0));

        address[] memory path;
        UniswapRouter router = UniswapRouter(uniswapRouterAddress);
        address weth = router.WETH();

        if (_from == weth || _to == weth) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            path = new address[](3);
            path[0] = _from;
            path[1] = weth;
            path[2] = _to;
        }

        IERC20(_from).safeApprove(address(router), 0); // Some tokens require this to be set to 0 first
        IERC20(_from).safeApprove(address(router), _sellAmount);
        router.swapExactTokensForTokens(_sellAmount, 1, path, address(this), now.add(60));
    }
    
    
    
    uint256 private _timelockStart; // The start of the timelock to change governance variables
    uint256 private _timelockType; // The function that needs to be changed
    uint256 constant _timelockDuration = 86400; // Timelock is 24 hours
    
    uint256[2] private _timelock_data;
    address private _timelock_address;
    
    modifier timelockConditionsMet(uint256 _type) {

        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0; // Reset the type once the timelock is used
        if(totalSupply() > 0){
            require(now >= _timelockStart + _timelockDuration, "Timelock time not met");
        }
        _;
    }
    
    function startGovernanceChange(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 1;
        _timelock_address = _address;       
    }
    
    function finishGovernanceChange() external onlyGovernance timelockConditionsMet(1) {

        transferGovernance(_timelock_address);
    }
    
    function startChangeFeeRates(uint256 _max, uint256 _min) external onlyGovernance {

        require(_max <= 10000,"Fee can never be greater than 10%");
        require(_min <= _max,"Min fee must be less than or equal to max fee");
        _timelockStart = now;
        _timelockType = 2;
        _timelock_data[0] = _max;
        _timelock_data[1] = _min;
    }
    
    function finishChangeFeeRates() external onlyGovernance timelockConditionsMet(2) {

        maxFee = _timelock_data[0];
        minFee = _timelock_data[1];
    }
    
    function startChangeTreasury(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 3;
        _timelock_address = _address;
    }
    
    function finishChangeTreasury() external onlyGovernance timelockConditionsMet(3) {

        treasuryAddress = _timelock_address;
    }
    
    function startChangeStakingPool(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 4;
        _timelock_address = _address;
    }
    
    function finishChangeStakingPool() external onlyGovernance timelockConditionsMet(4) {

        stakingAddress = _timelock_address;
    }
    
    function startChangePriceOracle(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 5;
        _timelock_address = _address;
    }
    
    function finishChangePriceOracle() external onlyGovernance timelockConditionsMet(5) {

        oracleContract = StabilizePriceOracle(_timelock_address);
    }
    
    function startChangeStakersPercent(uint256 _percent) external onlyGovernance {

        require(_percent <= 100000,"Percent cannot be greater than 100%");
        _timelockStart = now;
        _timelockType = 6;
        _timelock_data[0] = _percent;
    }
    
    function finishChangeStakersPercent() external onlyGovernance timelockConditionsMet(6) {

        percentStakers = _timelock_data[0];
    }

}