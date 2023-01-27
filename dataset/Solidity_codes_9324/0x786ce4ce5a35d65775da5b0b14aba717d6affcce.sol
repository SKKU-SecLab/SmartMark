pragma solidity 0.8.11;

contract JaxOwnable {


  address public owner;
  address public new_owner;
  uint public new_owner_locktime;
  
  event Set_New_Owner(address newOwner, uint newOwnerLocktime);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {

      require(owner == msg.sender, "JaxOwnable: caller is not the owner");
      _;
  }

  function setNewOwner(address newOwner) external onlyOwner {

    require(newOwner != address(0x0), "New owner cannot be zero address");
    new_owner = newOwner;
    new_owner_locktime = block.timestamp + 2 days;
    emit Set_New_Owner(newOwner, new_owner_locktime);
  }

  function updateOwner() external {

    require(msg.sender == new_owner, "Only new owner");
    require(block.timestamp >= new_owner_locktime, "New admin is not unlocked yet");
    _transferOwnership(new_owner);
    new_owner = address(0x0);
  }

  function renounceOwnership() external onlyOwner {

    _transferOwnership(address(0));
  }

  function _transferOwnership(address newOwner) internal virtual {

    address oldOwner = owner;
    owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}// MIT

pragma solidity 0.8.11;

contract JaxProtection {


    struct RunProtection {
        bytes32 data_hash;
        uint64 request_timestamp;
        address sender;
        bool executed;
    }

    mapping(bytes4 => RunProtection) run_protection_info;

    event Request_Update(bytes4 sig, bytes data);

    function _runProtection() internal returns(bool) {

        RunProtection storage protection = run_protection_info[msg.sig];
        bytes32 data_hash = keccak256(msg.data);
        if(data_hash != protection.data_hash || protection.sender != msg.sender) {
            protection.sender = msg.sender;
            protection.data_hash = data_hash;
            protection.request_timestamp = uint64(block.timestamp);
            protection.executed = false;
            emit Request_Update(msg.sig, msg.data);
            return false;
        }
        require(!protection.executed, "Already executed");
        require(block.timestamp >= uint(protection.request_timestamp) + 2 days, "Running is Locked");
        protection.executed = true;
        return true;
    }

    modifier runProtection() {

        if(_runProtection()) {
            _;
        }
    }
}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}// MIT

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}// MIT

pragma solidity 0.8.11;

interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function getOwner() external view returns (address);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function mint(address account, uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity 0.8.11;


interface IPancakeFactory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;


    function INIT_CODE_PAIR_HASH() external view returns (bytes32);

}


interface IPancakePair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}

interface IPancakeRouter01 {

    function factory() external view returns (address);

    function WETH() external view returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}// MIT

pragma solidity 0.8.11;


contract JaxStakeAdmin is JaxOwnable, Initializable, JaxProtection {

    
    IERC20 public wjxn;
    IERC20 public usdt;

    JaxProtection jaxProtection;
    IPancakeRouter01 router;

    uint public min_unlocked_deposit_amount;
    uint public max_unlocked_deposit_amount;

    uint public min_locked_deposit_amount;
    uint public max_locked_deposit_amount;

    uint public collateral_ratio;

    uint public referral_ratio;

    uint public wjxn_default_discount_ratio;

    uint public minimum_wjxn_price; // 1e18

    uint[] public lock_plans;
    uint[] public apys;

    uint public max_unlocked_stake_amount;

    uint public max_locked_stake_amount;

    bool public is_deposit_freezed;

    address[] public referrers;
    mapping(uint => bool) public referrer_status;
    mapping(address => uint) public referrer_to_ids;

    event Set_Stake_APY(uint plan, uint amount);
    event Set_Collateral_Ratio(uint collateral_ratio);
    event Set_Minimum_Wjxn_Price(uint price);
    event Set_Referral_Ratio(uint ratio);
    event Set_Wjxn_Default_Discount_Ratio(uint ratio);
    event Set_Max_Unlocked_Stake_Amount(uint amount);
    event Set_Max_Locked_Stake_Amount(uint amount);
    event Set_Unlocked_Deposit_Amount_Limit(uint min_amount, uint max_amount);
    event Set_Locked_Deposit_Amount_Limit(uint min_amount, uint max_amount);
    event Freeze_Deposit(bool flag);
    event Add_Referrers(address[] referrers);
    event Delete_Referrers(uint[] referrer_ids);
    event Withdraw_By_Admin(address token, uint amount);

    modifier checkZeroAddress(address account) {

        require(account != address(0x0), "Only non-zero address");
        _;
    }

    function initialize(IERC20 _wjxn, IERC20 _usdt, IPancakeRouter01 _router) external initializer 
        checkZeroAddress(address(_wjxn)) checkZeroAddress(address(_usdt)) checkZeroAddress(address(_router))
    {

        wjxn = _wjxn;
        usdt = _usdt;

        router = _router;

        uint decimals = 10 ** usdt.decimals();

        min_unlocked_deposit_amount = 1 * decimals;  // 1 USDT
        max_unlocked_deposit_amount = 1000 * decimals; // 1K USDT

        min_locked_deposit_amount = 100 * decimals; // 100 USDT
        max_locked_deposit_amount = 1e6 * decimals; // 1M USDT

        collateral_ratio = 150; // 150%

        referral_ratio = 1.25 * 1e6; //1.25 % 8 decimals

        wjxn_default_discount_ratio = 10; // 10%

        minimum_wjxn_price = 1.5 * 1e18;

        lock_plans = [360 days, 90 days, 180 days, 270 days, 360 days];
        apys = [20, 24, 28, 32, 36];

        max_unlocked_stake_amount = 1e6 * decimals; //  1M USDT

        max_locked_stake_amount = 1e7 * decimals; // 10M USDT

        is_deposit_freezed = false;

        referrers.push(address(0));

        _transferOwnership(msg.sender);
    }

    function set_stake_apy(uint plan, uint apy) external onlyOwner runProtection {

        if(plan == 0) {
            require(apy >= 1 && apy <= 24, "Invalid apy");
        }
        else {
            require(apy >= 12 && apy <= 36, "Invalid apy");
        }
        apys[plan] = apy;
        emit Set_Stake_APY(plan, apy);
    }

    function set_collateral_ratio(uint _collateral_ratio) external onlyOwner runProtection {

        require(_collateral_ratio >= 100 && _collateral_ratio <= 200, "Collateral ratio should be 100% - 200%");
        collateral_ratio = _collateral_ratio;
        emit Set_Collateral_Ratio(_collateral_ratio);
    }

    function get_wjxn_price() public view returns(uint) {

        uint dex_price = _get_wjxn_dex_price();
        if(dex_price < minimum_wjxn_price)
            return minimum_wjxn_price;
        return dex_price;
    }

    function _get_wjxn_dex_price() internal view returns(uint) {

        address pairAddress = IPancakeFactory(router.factory()).getPair(address(wjxn), address(usdt));
        (uint res0, uint res1,) = IPancakePair(pairAddress).getReserves();
        res0 *= 10 ** (18 - IERC20(IPancakePair(pairAddress).token0()).decimals());
        res1 *= 10 ** (18 - IERC20(IPancakePair(pairAddress).token1()).decimals());
        if(IPancakePair(pairAddress).token0() == address(usdt)) {
            if(res1 > 0)
                return 1e18 * res0 / res1;
        } 
        else {
            if(res0 > 0)
                return 1e18 * res1 / res0;
        }
        return 0;
    }


    function set_minimum_wjxn_price(uint price) external onlyOwner runProtection {

        require(price >= 1.5 * 1e18, "Minimum wjxn price should be above 1.5 USD");
        minimum_wjxn_price = price;
        emit Set_Minimum_Wjxn_Price(price);
    }

    function set_wjxn_default_discount_ratio(uint ratio) external onlyOwner runProtection {

        require(ratio >= 10 && ratio <= 30, "Discount ratio should be 10% - 30%");
        wjxn_default_discount_ratio = ratio;
        emit Set_Wjxn_Default_Discount_Ratio(ratio);
    }

    function _add_referrer(address referrer) internal checkZeroAddress(referrer) {

        uint referrer_id = referrer_to_ids[referrer];
        if( referrer_id == 0) {
            referrer_id = referrers.length;
            referrers.push(referrer);
            referrer_to_ids[referrer] = referrer_id;
        }
        referrer_status[referrer_id] = true;
    }

    function add_referrers(address[] memory _referrers) external onlyOwner runProtection {

        uint i = 0;
        for(; i < _referrers.length; i += 1) {
            _add_referrer(_referrers[i]);
        }
        emit Add_Referrers(_referrers);
    }

    function delete_referrers(uint[] memory _referrer_ids) external onlyOwner runProtection {

        uint i = 0;
        for(; i < _referrer_ids.length; i += 1) {
            referrer_status[_referrer_ids[i]] = false;
        }
        emit Delete_Referrers(_referrer_ids);
    }

    function set_referral_ratio(uint ratio) external onlyOwner runProtection {

        require(ratio >= 0.25 * 1e6 && ratio <= 1.25 * 1e6, "Referral ratio should be 0.25% ~ 1.25%");
        referral_ratio = ratio;
        emit Set_Referral_Ratio(ratio);
    }

    function freeze_deposit(bool flag) external onlyOwner runProtection {

        is_deposit_freezed = flag;
        emit Freeze_Deposit(flag);
    }

    function set_unlocked_stake_amount_limit(uint max_amount) external onlyOwner runProtection {

        max_unlocked_stake_amount = max_amount;
        emit Set_Max_Unlocked_Stake_Amount(max_amount);
    }

    function set_locked_stake_amount_limit(uint max_amount) external onlyOwner runProtection {

        require(max_amount >= _usdt_decimals(1e6), "Max amount >= 1M USD");
        max_locked_stake_amount = max_amount;
        emit Set_Max_Locked_Stake_Amount(max_amount);
    }

    function set_unlocked_deposit_amount_limit(uint min_amount, uint max_amount) external onlyOwner runProtection {

        require(min_amount >= _usdt_decimals(1) && min_amount <= _usdt_decimals(100), "1 USD <= Min amount <= 100 USD");
        require(max_amount <= _usdt_decimals(1e4), "Max amount <= 10K USD");
        min_unlocked_deposit_amount = min_amount;
        max_unlocked_deposit_amount = max_amount;
        emit Set_Unlocked_Deposit_Amount_Limit(min_amount, max_amount);
    }

    function set_locked_deposit_amount_limit(uint min_amount, uint max_amount) external onlyOwner runProtection {

        require(min_amount >= _usdt_decimals(100), "Min amount >= 100 USD");
        require(max_amount >= _usdt_decimals(1e4), "Max amount >= 10K USD");
        min_locked_deposit_amount = min_amount;
        max_locked_deposit_amount = max_amount;
        emit Set_Locked_Deposit_Amount_Limit(min_amount, max_amount);
    }

    function _usdt_decimals(uint amount) internal view returns(uint) {

        return amount * (10 ** usdt.decimals());
    }
}