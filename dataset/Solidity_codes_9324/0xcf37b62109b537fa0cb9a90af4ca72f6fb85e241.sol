
pragma solidity >=0.8.0;




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




interface IFrax {

  function COLLATERAL_RATIO_PAUSER() external view returns (bytes32);

  function DEFAULT_ADMIN_ADDRESS() external view returns (address);

  function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

  function addPool(address pool_address ) external;

  function allowance(address owner, address spender ) external view returns (uint256);

  function approve(address spender, uint256 amount ) external returns (bool);

  function balanceOf(address account ) external view returns (uint256);

  function burn(uint256 amount ) external;

  function burnFrom(address account, uint256 amount ) external;

  function collateral_ratio_paused() external view returns (bool);

  function controller_address() external view returns (address);

  function creator_address() external view returns (address);

  function decimals() external view returns (uint8);

  function decreaseAllowance(address spender, uint256 subtractedValue ) external returns (bool);

  function eth_usd_consumer_address() external view returns (address);

  function eth_usd_price() external view returns (uint256);

  function frax_eth_oracle_address() external view returns (address);

  function frax_info() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256);

  function frax_pools(address ) external view returns (bool);

  function frax_pools_array(uint256 ) external view returns (address);

  function frax_price() external view returns (uint256);

  function frax_step() external view returns (uint256);

  function fxs_address() external view returns (address);

  function fxs_eth_oracle_address() external view returns (address);

  function fxs_price() external view returns (uint256);

  function genesis_supply() external view returns (uint256);

  function getRoleAdmin(bytes32 role ) external view returns (bytes32);

  function getRoleMember(bytes32 role, uint256 index ) external view returns (address);

  function getRoleMemberCount(bytes32 role ) external view returns (uint256);

  function globalCollateralValue() external view returns (uint256);

  function global_collateral_ratio() external view returns (uint256);

  function grantRole(bytes32 role, address account ) external;

  function hasRole(bytes32 role, address account ) external view returns (bool);

  function increaseAllowance(address spender, uint256 addedValue ) external returns (bool);

  function last_call_time() external view returns (uint256);

  function minting_fee() external view returns (uint256);

  function name() external view returns (string memory);

  function owner_address() external view returns (address);

  function pool_burn_from(address b_address, uint256 b_amount ) external;

  function pool_mint(address m_address, uint256 m_amount ) external;

  function price_band() external view returns (uint256);

  function price_target() external view returns (uint256);

  function redemption_fee() external view returns (uint256);

  function refreshCollateralRatio() external;

  function refresh_cooldown() external view returns (uint256);

  function removePool(address pool_address ) external;

  function renounceRole(bytes32 role, address account ) external;

  function revokeRole(bytes32 role, address account ) external;

  function setController(address _controller_address ) external;

  function setETHUSDOracle(address _eth_usd_consumer_address ) external;

  function setFRAXEthOracle(address _frax_oracle_addr, address _weth_address ) external;

  function setFXSAddress(address _fxs_address ) external;

  function setFXSEthOracle(address _fxs_oracle_addr, address _weth_address ) external;

  function setFraxStep(uint256 _new_step ) external;

  function setMintingFee(uint256 min_fee ) external;

  function setOwner(address _owner_address ) external;

  function setPriceBand(uint256 _price_band ) external;

  function setPriceTarget(uint256 _new_price_target ) external;

  function setRedemptionFee(uint256 red_fee ) external;

  function setRefreshCooldown(uint256 _new_cooldown ) external;

  function setTimelock(address new_timelock ) external;

  function symbol() external view returns (string memory);

  function timelock_address() external view returns (address);

  function toggleCollateralRatio() external;

  function totalSupply() external view returns (uint256);

  function transfer(address recipient, uint256 amount ) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount ) external returns (bool);

  function weth_address() external view returns (address);

}




interface IFxs {

  function DEFAULT_ADMIN_ROLE() external view returns(bytes32);

  function FRAXStablecoinAdd() external view returns(address);

  function FXS_DAO_min() external view returns(uint256);

  function allowance(address owner, address spender) external view returns(uint256);

  function approve(address spender, uint256 amount) external returns(bool);

  function balanceOf(address account) external view returns(uint256);

  function burn(uint256 amount) external;

  function burnFrom(address account, uint256 amount) external;

  function checkpoints(address, uint32) external view returns(uint32 fromBlock, uint96 votes);

  function decimals() external view returns(uint8);

  function decreaseAllowance(address spender, uint256 subtractedValue) external returns(bool);

  function genesis_supply() external view returns(uint256);

  function getCurrentVotes(address account) external view returns(uint96);

  function getPriorVotes(address account, uint256 blockNumber) external view returns(uint96);

  function getRoleAdmin(bytes32 role) external view returns(bytes32);

  function getRoleMember(bytes32 role, uint256 index) external view returns(address);

  function getRoleMemberCount(bytes32 role) external view returns(uint256);

  function grantRole(bytes32 role, address account) external;

  function hasRole(bytes32 role, address account) external view returns(bool);

  function increaseAllowance(address spender, uint256 addedValue) external returns(bool);

  function mint(address to, uint256 amount) external;

  function name() external view returns(string memory);

  function numCheckpoints(address) external view returns(uint32);

  function oracle_address() external view returns(address);

  function owner_address() external view returns(address);

  function pool_burn_from(address b_address, uint256 b_amount) external;

  function pool_mint(address m_address, uint256 m_amount) external;

  function renounceRole(bytes32 role, address account) external;

  function revokeRole(bytes32 role, address account) external;

  function setFRAXAddress(address frax_contract_address) external;

  function setFXSMinDAO(uint256 min_FXS) external;

  function setOracle(address new_oracle) external;

  function setOwner(address _owner_address) external;

  function setTimelock(address new_timelock) external;

  function symbol() external view returns(string memory);

  function timelock_address() external view returns(address);

  function toggleVotes() external;

  function totalSupply() external view returns(uint256);

  function trackingVotes() external view returns(bool);

  function transfer(address recipient, uint256 amount) external returns(bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

}




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

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}




contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor (address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}




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




interface IFraxAMOMinter {

  function FRAX() external view returns(address);

  function FXS() external view returns(address);

  function acceptOwnership() external;

  function addAMO(address amo_address, bool sync_too) external;

  function allAMOAddresses() external view returns(address[] memory);

  function allAMOsLength() external view returns(uint256);

  function amoProfit(address amo_address) external view returns(int256);

  function amos(address) external view returns(bool);

  function amos_array(uint256) external view returns(address);

  function burnFXS(uint256 amount) external;

  function burnFraxFromAMO(uint256 frax_amount) external;

  function burnFxsFromAMO(uint256 fxs_amount) external;

  function col_idx() external view returns(uint256);

  function collatDollarBalance() external view returns(uint256);

  function collatDollarBalanceStored() external view returns(uint256);

  function collat_borrow_cap() external view returns(int256);

  function collat_borrowed_balances(address) external view returns(int256);

  function collat_borrowed_sum() external view returns(int256);

  function collateral_address() external view returns(address);

  function collateral_token() external view returns(address);

  function custodian_address() external view returns(address);

  function fraxDollarBalanceStored() external view returns(uint256);

  function giveCollatToAMO(address destination_amo, uint256 collat_amount) external;

  function min_cr() external view returns(uint256);

  function mintFraxForAMO(address destination_amo, uint256 frax_amount) external;

  function mint_balances(address) external view returns(int256);

  function mint_cap() external view returns(int256);

  function mint_sum() external view returns(int256);

  function missing_decimals() external view returns(uint256);

  function nominateNewOwner(address _owner) external;

  function nominatedOwner() external view returns(address);

  function override_collat_balance() external view returns(bool);

  function override_collat_balance_amount() external view returns(uint256);

  function owner() external view returns(address);

  function pool() external view returns(address);

  function receiveCollatFromAMO(uint256 usdc_amount) external;

  function recoverERC20(address tokenAddress, uint256 tokenAmount) external;

  function removeAMO(address amo_address, bool sync_too) external;

  function setCustodian(address _custodian_address) external;

  function setFraxPool(address _pool_address) external;

  function setMinimumCollateralRatio(uint256 _min_cr) external;

  function setMintCap(uint256 _mint_cap) external;

  function setOverrideCollatBalance(bool _state, uint256 _balance) external;

  function setTimelock(address new_timelock) external;

  function syncDollarBalances() external;

  function timelock_address() external view returns(address);

  function unspentProfitGlobal() external view returns(int256);

}




abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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







 
contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor (string memory __name, string memory __symbol) public {
        _name = __name;
        _symbol = __symbol;
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

    function burn(uint256 amount) public virtual {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {

        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
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

    function _burnFrom(address account, uint256 amount) internal virtual {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}















contract FraxPoolV3 is Owned {
    using SafeMath for uint256;


    address public timelock_address;
    address public custodian_address; // Custodian is an EOA (or msig) with pausing privileges only, in case of an emergency
    IFrax private FRAX = IFrax(0x853d955aCEf822Db058eb8505911ED77F175b99e);
    IFxs private FXS = IFxs(0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0);
    mapping(address => bool) public amo_minter_addresses; // minter address -> is it enabled
    AggregatorV3Interface public priceFeedFRAXUSD = AggregatorV3Interface(0xB9E1E3A9feFf48998E45Fa90847ed4D467E8BcfD);
    AggregatorV3Interface public priceFeedFXSUSD = AggregatorV3Interface(0x6Ebc52C8C1089be9eB3945C4350B68B8E4C2233f);
    uint256 private chainlink_frax_usd_decimals;
    uint256 private chainlink_fxs_usd_decimals;

    address[] public collateral_addresses;
    string[] public collateral_symbols;
    uint256[] public missing_decimals; // Number of decimals needed to get to E18. collateral index -> missing_decimals
    uint256[] public pool_ceilings; // Total across all collaterals. Accounts for missing_decimals
    uint256[] public collateral_prices; // Stores price of the collateral, if price is paused
    mapping(address => uint256) public collateralAddrToIdx; // collateral addr -> collateral index
    mapping(address => bool) public enabled_collaterals; // collateral address -> is it enabled
    
    mapping (address => uint256) public redeemFXSBalances;
    mapping (address => mapping(uint256 => uint256)) public redeemCollateralBalances; // Address -> collateral index -> balance
    uint256[] public unclaimedPoolCollateral; // collateral index -> balance
    uint256 public unclaimedPoolFXS;
    mapping (address => uint256) public lastRedeemed; // Collateral independent
    uint256 public redemption_delay = 2; // Number of blocks to wait before being able to collectRedemption()
    uint256 public redeem_price_threshold = 990000; // $0.99
    uint256 public mint_price_threshold = 1010000; // $1.01
    
    mapping(uint256 => uint256) public bbkHourlyCum; // Epoch hour ->  Collat out in that hour (E18)
    uint256 public bbkMaxColE18OutPerHour = 1000e18;

    mapping(uint256 => uint256) public rctHourlyCum; // Epoch hour ->  FXS out in that hour
    uint256 public rctMaxFxsOutPerHour = 1000e18;

    uint256[] private minting_fee;
    uint256[] private redemption_fee;
    uint256[] private buyback_fee;
    uint256[] private recollat_fee;
    uint256 public bonus_rate; // Bonus rate on FXS minted during recollateralize(); 6 decimals of precision, set to 0.75% on genesis
    
    uint256 private constant PRICE_PRECISION = 1e6;

    bool[] private mintPaused; // Collateral-specific
    bool[] private redeemPaused; // Collateral-specific
    bool[] private recollateralizePaused; // Collateral-specific
    bool[] private buyBackPaused; // Collateral-specific


    modifier onlyByOwnGov() {
        require(msg.sender == timelock_address || msg.sender == owner, "Not owner or timelock");
        _;
    }

    modifier onlyByOwnGovCust() {
        require(msg.sender == timelock_address || msg.sender == owner || msg.sender == custodian_address, "Not owner, tlck, or custd");
        _;
    }

    modifier onlyAMOMinters() {
        require(amo_minter_addresses[msg.sender], "Not an AMO Minter");
        _;
    }

    modifier collateralEnabled(uint256 col_idx) {
        require(enabled_collaterals[collateral_addresses[col_idx]], "Collateral disabled");
        _;
    }
 
    
    constructor (
        address _pool_manager_address,
        address _custodian_address,
        address _timelock_address,
        address[] memory _collateral_addresses,
        uint256[] memory _pool_ceilings,
        uint256[] memory _initial_fees
    ) Owned(_pool_manager_address){
        timelock_address = _timelock_address;
        custodian_address = _custodian_address;

        collateral_addresses = _collateral_addresses;
        for (uint256 i = 0; i < _collateral_addresses.length; i++){ 
            collateralAddrToIdx[_collateral_addresses[i]] = i;

            enabled_collaterals[_collateral_addresses[i]] = false;

            missing_decimals.push(uint256(18).sub(ERC20(_collateral_addresses[i]).decimals()));

            collateral_symbols.push(ERC20(_collateral_addresses[i]).symbol());

            unclaimedPoolCollateral.push(0);

            collateral_prices.push(PRICE_PRECISION);

            minting_fee.push(_initial_fees[0]);
            redemption_fee.push(_initial_fees[1]);
            buyback_fee.push(_initial_fees[2]);
            recollat_fee.push(_initial_fees[3]);

            mintPaused.push(false);
            redeemPaused.push(false);
            recollateralizePaused.push(false);
            buyBackPaused.push(false);
        }

        pool_ceilings = _pool_ceilings;

        chainlink_frax_usd_decimals = priceFeedFRAXUSD.decimals();
        chainlink_fxs_usd_decimals = priceFeedFXSUSD.decimals();
    }

    
    struct CollateralInformation {
        uint256 index;
        string symbol;
        address col_addr;
        bool is_enabled;
        uint256 missing_decs;
        uint256 price;
        uint256 pool_ceiling;
        bool mint_paused;
        bool redeem_paused;
        bool recollat_paused;
        bool buyback_paused;
        uint256 minting_fee;
        uint256 redemption_fee;
        uint256 buyback_fee;
        uint256 recollat_fee;
    }


    function collateral_information(address collat_address) external view returns (CollateralInformation memory return_data){
        require(enabled_collaterals[collat_address], "Invalid collateral");

        uint256 idx = collateralAddrToIdx[collat_address];
        
        return_data = CollateralInformation(
            idx, // [0]
            collateral_symbols[idx], // [1]
            collat_address, // [2]
            enabled_collaterals[collat_address], // [3]
            missing_decimals[idx], // [4]
            collateral_prices[idx], // [5]
            pool_ceilings[idx], // [6]
            mintPaused[idx], // [7]
            redeemPaused[idx], // [8]
            recollateralizePaused[idx], // [9]
            buyBackPaused[idx], // [10]
            minting_fee[idx], // [11]
            redemption_fee[idx], // [12]
            buyback_fee[idx], // [13]
            recollat_fee[idx] // [14]
        );
    }

    function allCollaterals() external view returns (address[] memory) {
        return collateral_addresses;
    }

    function getFRAXPrice() public view returns (uint256) {
        ( , int price, , , ) = priceFeedFRAXUSD.latestRoundData();
        return uint256(price).mul(PRICE_PRECISION).div(10 ** chainlink_frax_usd_decimals);
    }

    function getFXSPrice() public view returns (uint256) {
        ( , int price, , , ) = priceFeedFXSUSD.latestRoundData();
        return uint256(price).mul(PRICE_PRECISION).div(10 ** chainlink_fxs_usd_decimals);
    }

    function getFRAXInCollateral(uint256 col_idx, uint256 frax_amount) public view returns (uint256) {
        return frax_amount.mul(PRICE_PRECISION).div(10 ** missing_decimals[col_idx]).div(collateral_prices[col_idx]);
    }

    function freeCollatBalance(uint256 col_idx) public view returns (uint256) {
        return ERC20(collateral_addresses[col_idx]).balanceOf(address(this)).sub(unclaimedPoolCollateral[col_idx]);
    }

    function collatDollarBalance() external view returns (uint256 balance_tally) {
        balance_tally = 0;

        for (uint256 i = 0; i < collateral_addresses.length; i++){ 
            balance_tally += freeCollatBalance(i).mul(10 ** missing_decimals[i]).mul(collateral_prices[i]).div(PRICE_PRECISION);
        }

    }

    function comboCalcBbkRct(uint256 cur, uint256 max, uint256 theo) internal pure returns (uint256) {
        if (cur >= max) {
            return 0;
        }
        else {
            uint256 available = max.sub(cur);

            if (theo >= available) {
                return available;
            }
            else {
                return theo;
            }
        } 
    }

    function buybackAvailableCollat() public view returns (uint256) {
        uint256 total_supply = FRAX.totalSupply();
        uint256 global_collateral_ratio = FRAX.global_collateral_ratio();
        uint256 global_collat_value = FRAX.globalCollateralValue();

        if (global_collateral_ratio > PRICE_PRECISION) global_collateral_ratio = PRICE_PRECISION; // Handles an overcollateralized contract with CR > 1
        uint256 required_collat_dollar_value_d18 = (total_supply.mul(global_collateral_ratio)).div(PRICE_PRECISION); // Calculates collateral needed to back each 1 FRAX with $1 of collateral at current collat ratio
        
        if (global_collat_value > required_collat_dollar_value_d18) {
            uint256 theoretical_bbk_amt = global_collat_value.sub(required_collat_dollar_value_d18);

            uint256 current_hr_bbk = bbkHourlyCum[curEpochHr()];

            return comboCalcBbkRct(current_hr_bbk, bbkMaxColE18OutPerHour, theoretical_bbk_amt);
        }
        else return 0;
    }

    function recollatTheoColAvailableE18() public view returns (uint256) {
        uint256 frax_total_supply = FRAX.totalSupply();
        uint256 effective_collateral_ratio = FRAX.globalCollateralValue().mul(PRICE_PRECISION).div(frax_total_supply); // Returns it in 1e6
        
        uint256 desired_collat_e24 = (FRAX.global_collateral_ratio()).mul(frax_total_supply);
        uint256 effective_collat_e24 = effective_collateral_ratio.mul(frax_total_supply);

        if (effective_collat_e24 >= desired_collat_e24) return 0;
        else {
            return (desired_collat_e24.sub(effective_collat_e24)).div(PRICE_PRECISION);
        }
    }

    function recollatAvailableFxs() public view returns (uint256) {
        uint256 fxs_price = getFXSPrice();

        uint256 recollat_theo_available_e18 = recollatTheoColAvailableE18();

        uint256 fxs_theo_out = recollat_theo_available_e18.mul(PRICE_PRECISION).div(fxs_price);

        uint256 current_hr_rct = rctHourlyCum[curEpochHr()];

        return comboCalcBbkRct(current_hr_rct, rctMaxFxsOutPerHour, fxs_theo_out);
    }

    function curEpochHr() public view returns (uint256) {
        return (block.timestamp / 3600); // Truncation desired
    }


     function mintFrax(
        uint256 col_idx, 
        uint256 frax_amt,
        uint256 frax_out_min,
        bool one_to_one_override
    ) external collateralEnabled(col_idx) returns (
        uint256 total_frax_mint, 
        uint256 collat_needed, 
        uint256 fxs_needed
    ) {
        require(mintPaused[col_idx] == false, "Minting is paused");

        require(getFRAXPrice() >= mint_price_threshold, "Frax price too low");

        uint256 global_collateral_ratio = FRAX.global_collateral_ratio();

        if (one_to_one_override || global_collateral_ratio >= PRICE_PRECISION) { 
            collat_needed = getFRAXInCollateral(col_idx, frax_amt);
            fxs_needed = 0;
        } else if (global_collateral_ratio == 0) { 
            collat_needed = 0;
            fxs_needed = frax_amt.mul(PRICE_PRECISION).div(getFXSPrice());
        } else { 
            uint256 frax_for_collat = frax_amt.mul(global_collateral_ratio).div(PRICE_PRECISION);
            uint256 frax_for_fxs = frax_amt.sub(frax_for_collat);
            collat_needed = getFRAXInCollateral(col_idx, frax_for_collat);
            fxs_needed = frax_for_fxs.mul(PRICE_PRECISION).div(getFXSPrice());
        }

        total_frax_mint = (frax_amt.mul(PRICE_PRECISION.sub(minting_fee[col_idx]))).div(PRICE_PRECISION);

        require((frax_out_min <= total_frax_mint), "FRAX slippage");
        require(freeCollatBalance(col_idx).add(collat_needed) <= pool_ceilings[col_idx], "Pool ceiling");

        FXS.pool_burn_from(msg.sender, fxs_needed);
        TransferHelper.safeTransferFrom(collateral_addresses[col_idx], msg.sender, address(this), collat_needed);

        FRAX.pool_mint(msg.sender, total_frax_mint);
    }

    function redeemFrax(
        uint256 col_idx, 
        uint256 frax_amount, 
        uint256 fxs_out_min, 
        uint256 col_out_min
    ) external collateralEnabled(col_idx) returns (
        uint256 collat_out, 
        uint256 fxs_out
    ) {
        require(redeemPaused[col_idx] == false, "Redeeming is paused");

        require(getFRAXPrice() <= redeem_price_threshold, "Frax price too high");

        uint256 global_collateral_ratio = FRAX.global_collateral_ratio();
        uint256 frax_after_fee = (frax_amount.mul(PRICE_PRECISION.sub(redemption_fee[col_idx]))).div(PRICE_PRECISION);

        if(global_collateral_ratio >= PRICE_PRECISION) { 
            collat_out = frax_after_fee
                            .mul(collateral_prices[col_idx])
                            .div(10 ** (6 + missing_decimals[col_idx])); // PRICE_PRECISION + missing decimals
            fxs_out = 0;
        } else if (global_collateral_ratio == 0) { 
            fxs_out = frax_after_fee
                            .mul(PRICE_PRECISION)
                            .div(getFXSPrice());
            collat_out = 0;
        } else { 
            collat_out = frax_after_fee
                            .mul(global_collateral_ratio)
                            .mul(collateral_prices[col_idx])
                            .div(10 ** (12 + missing_decimals[col_idx])); // PRICE_PRECISION ^2 + missing decimals
            fxs_out = frax_after_fee
                            .mul(PRICE_PRECISION.sub(global_collateral_ratio))
                            .div(getFXSPrice()); // PRICE_PRECISIONS CANCEL OUT
        }

        require(collat_out <= (ERC20(collateral_addresses[col_idx])).balanceOf(address(this)).sub(unclaimedPoolCollateral[col_idx]), "Insufficient pool collateral");
        require(collat_out >= col_out_min, "Collateral slippage");
        require(fxs_out >= fxs_out_min, "FXS slippage");

        redeemCollateralBalances[msg.sender][col_idx] = redeemCollateralBalances[msg.sender][col_idx].add(collat_out);
        unclaimedPoolCollateral[col_idx] = unclaimedPoolCollateral[col_idx].add(collat_out);

        redeemFXSBalances[msg.sender] = redeemFXSBalances[msg.sender].add(fxs_out);
        unclaimedPoolFXS = unclaimedPoolFXS.add(fxs_out);

        lastRedeemed[msg.sender] = block.number;

        FRAX.pool_burn_from(msg.sender, frax_amount);
        FXS.pool_mint(address(this), fxs_out);
    }

    function collectRedemption(uint256 col_idx) external returns (uint256 fxs_amount, uint256 collateral_amount) {
        require(redeemPaused[col_idx] == false, "Redeeming is paused");
        require((lastRedeemed[msg.sender].add(redemption_delay)) <= block.number, "Too soon");
        bool sendFXS = false;
        bool sendCollateral = false;

        if(redeemFXSBalances[msg.sender] > 0){
            fxs_amount = redeemFXSBalances[msg.sender];
            redeemFXSBalances[msg.sender] = 0;
            unclaimedPoolFXS = unclaimedPoolFXS.sub(fxs_amount);
            sendFXS = true;
        }
        
        if(redeemCollateralBalances[msg.sender][col_idx] > 0){
            collateral_amount = redeemCollateralBalances[msg.sender][col_idx];
            redeemCollateralBalances[msg.sender][col_idx] = 0;
            unclaimedPoolCollateral[col_idx] = unclaimedPoolCollateral[col_idx].sub(collateral_amount);
            sendCollateral = true;
        }

        if(sendFXS){
            TransferHelper.safeTransfer(address(FXS), msg.sender, fxs_amount);
        }
        if(sendCollateral){
            TransferHelper.safeTransfer(collateral_addresses[col_idx], msg.sender, collateral_amount);
        }
    }

    function buyBackFxs(uint256 col_idx, uint256 fxs_amount, uint256 col_out_min) external collateralEnabled(col_idx) returns (uint256 col_out) {
        require(buyBackPaused[col_idx] == false, "Buyback is paused");
        uint256 fxs_price = getFXSPrice();
        uint256 available_excess_collat_dv = buybackAvailableCollat();

        require(available_excess_collat_dv > 0, "Insuf Collat Avail For BBK");

        uint256 fxs_dollar_value_d18 = fxs_amount.mul(fxs_price).div(PRICE_PRECISION);
        require(fxs_dollar_value_d18 <= available_excess_collat_dv, "Insuf Collat Avail For BBK");

        uint256 collateral_equivalent_d18 = fxs_dollar_value_d18.mul(PRICE_PRECISION).div(collateral_prices[col_idx]);
        col_out = collateral_equivalent_d18.div(10 ** missing_decimals[col_idx]); // In its natural decimals()

        col_out = (col_out.mul(PRICE_PRECISION.sub(buyback_fee[col_idx]))).div(PRICE_PRECISION);

        require(col_out >= col_out_min, "Collateral slippage");

        FXS.pool_burn_from(msg.sender, fxs_amount);
        TransferHelper.safeTransfer(collateral_addresses[col_idx], msg.sender, col_out);

        bbkHourlyCum[curEpochHr()] += collateral_equivalent_d18;
    }

    function recollateralize(uint256 col_idx, uint256 collateral_amount, uint256 fxs_out_min) external collateralEnabled(col_idx) returns (uint256 fxs_out) {
        require(recollateralizePaused[col_idx] == false, "Recollat is paused");
        uint256 collateral_amount_d18 = collateral_amount * (10 ** missing_decimals[col_idx]);
        uint256 fxs_price = getFXSPrice();

        uint256 fxs_actually_available = recollatAvailableFxs();

        fxs_out = collateral_amount_d18.mul(PRICE_PRECISION.add(bonus_rate).sub(recollat_fee[col_idx])).div(fxs_price);

        require(fxs_out <= fxs_actually_available, "Insuf FXS Avail For RCT");

        require(fxs_out >= fxs_out_min, "FXS slippage");

        require(freeCollatBalance(col_idx).add(collateral_amount) <= pool_ceilings[col_idx], "Pool ceiling");

        TransferHelper.safeTransferFrom(collateral_addresses[col_idx], msg.sender, address(this), collateral_amount);
        FXS.pool_mint(msg.sender, fxs_out);

        rctHourlyCum[curEpochHr()] += fxs_out;
    }

    function amoMinterBorrow(uint256 collateral_amount) external onlyAMOMinters {
        uint256 minter_col_idx = IFraxAMOMinter(msg.sender).col_idx();

        TransferHelper.safeTransfer(collateral_addresses[minter_col_idx], msg.sender, collateral_amount);
    }


    function toggleMRBR(uint256 col_idx, uint8 tog_idx) external onlyByOwnGovCust {
        if (tog_idx == 0) mintPaused[col_idx] = !mintPaused[col_idx];
        else if (tog_idx == 1) redeemPaused[col_idx] = !redeemPaused[col_idx];
        else if (tog_idx == 2) buyBackPaused[col_idx] = !buyBackPaused[col_idx];
        else if (tog_idx == 3) recollateralizePaused[col_idx] = !recollateralizePaused[col_idx];

        emit MRBRToggled(col_idx, tog_idx);
    }


    function addAMOMinter(address amo_minter_addr) external onlyByOwnGov {
        require(amo_minter_addr != address(0), "Zero address detected");

        uint256 collat_val_e18 = IFraxAMOMinter(amo_minter_addr).collatDollarBalance();
        require(collat_val_e18 >= 0, "Invalid AMO");

        amo_minter_addresses[amo_minter_addr] = true;

        emit AMOMinterAdded(amo_minter_addr);
    }

    function removeAMOMinter(address amo_minter_addr) external onlyByOwnGov {
        amo_minter_addresses[amo_minter_addr] = false;
        
        emit AMOMinterRemoved(amo_minter_addr);
    }

    function setCollateralPrice(uint256 col_idx, uint256 _new_price) external onlyByOwnGov {
        collateral_prices[col_idx] = _new_price;

        emit CollateralPriceSet(col_idx, _new_price);
    }

    function toggleCollateral(uint256 col_idx) external onlyByOwnGov {
        address col_address = collateral_addresses[col_idx];
        enabled_collaterals[col_address] = !enabled_collaterals[col_address];

        emit CollateralToggled(col_idx, enabled_collaterals[col_address]);
    }

    function setPoolCeiling(uint256 col_idx, uint256 new_ceiling) external onlyByOwnGov {
        pool_ceilings[col_idx] = new_ceiling;

        emit PoolCeilingSet(col_idx, new_ceiling);
    }

    function setFees(uint256 col_idx, uint256 new_mint_fee, uint256 new_redeem_fee, uint256 new_buyback_fee, uint256 new_recollat_fee) external onlyByOwnGov {
        minting_fee[col_idx] = new_mint_fee;
        redemption_fee[col_idx] = new_redeem_fee;
        buyback_fee[col_idx] = new_buyback_fee;
        recollat_fee[col_idx] = new_recollat_fee;

        emit FeesSet(col_idx, new_mint_fee, new_redeem_fee, new_buyback_fee, new_recollat_fee);
    }

    function setPoolParameters(uint256 new_bonus_rate, uint256 new_redemption_delay) external onlyByOwnGov {
        bonus_rate = new_bonus_rate;
        redemption_delay = new_redemption_delay;
        emit PoolParametersSet(new_bonus_rate, new_redemption_delay);
    }

    function setPriceThresholds(uint256 new_mint_price_threshold, uint256 new_redeem_price_threshold) external onlyByOwnGov {
        mint_price_threshold = new_mint_price_threshold;
        redeem_price_threshold = new_redeem_price_threshold;
        emit PriceThresholdsSet(new_mint_price_threshold, new_redeem_price_threshold);
    }

    function setBbkRctPerHour(uint256 _bbkMaxColE18OutPerHour, uint256 _rctMaxFxsOutPerHour) external onlyByOwnGov {
        bbkMaxColE18OutPerHour = _bbkMaxColE18OutPerHour;
        rctMaxFxsOutPerHour = _rctMaxFxsOutPerHour;
        emit BbkRctPerHourSet(_bbkMaxColE18OutPerHour, _rctMaxFxsOutPerHour);
    }

    function setOracles(address _frax_usd_chainlink_addr, address _fxs_usd_chainlink_addr) external onlyByOwnGov {
        priceFeedFRAXUSD = AggregatorV3Interface(_frax_usd_chainlink_addr);
        priceFeedFXSUSD = AggregatorV3Interface(_fxs_usd_chainlink_addr);

        chainlink_frax_usd_decimals = priceFeedFRAXUSD.decimals();
        chainlink_fxs_usd_decimals = priceFeedFXSUSD.decimals();
        
        emit OraclesSet(_frax_usd_chainlink_addr, _fxs_usd_chainlink_addr);
    }

    function setCustodian(address new_custodian) external onlyByOwnGov {
        custodian_address = new_custodian;

        emit CustodianSet(new_custodian);
    }

    function setTimelock(address new_timelock) external onlyByOwnGov {
        timelock_address = new_timelock;

        emit TimelockSet(new_timelock);
    }

    event CollateralToggled(uint256 col_idx, bool new_state);
    event PoolCeilingSet(uint256 col_idx, uint256 new_ceiling);
    event FeesSet(uint256 col_idx, uint256 new_mint_fee, uint256 new_redeem_fee, uint256 new_buyback_fee, uint256 new_recollat_fee);
    event PoolParametersSet(uint256 new_bonus_rate, uint256 new_redemption_delay);
    event PriceThresholdsSet(uint256 new_bonus_rate, uint256 new_redemption_delay);
    event BbkRctPerHourSet(uint256 bbkMaxColE18OutPerHour, uint256 rctMaxFxsOutPerHour);
    event AMOMinterAdded(address amo_minter_addr);
    event AMOMinterRemoved(address amo_minter_addr);
    event OraclesSet(address frax_usd_chainlink_addr, address fxs_usd_chainlink_addr);
    event CustodianSet(address new_custodian);
    event TimelockSet(address new_timelock);
    event MRBRToggled(uint256 col_idx, uint8 tog_idx);
    event CollateralPriceSet(uint256 col_idx, uint256 new_price);
}




interface IFraxPool {
    function minting_fee() external returns (uint256);
    function redeemCollateralBalances(address addr) external returns (uint256);
    function redemption_fee() external returns (uint256);
    function buyback_fee() external returns (uint256);
    function recollat_fee() external returns (uint256);
    function collatDollarBalance() external returns (uint256);
    function availableExcessCollatDV() external returns (uint256);
    function getCollateralPrice() external returns (uint256);
    function setCollatETHOracle(address _collateral_weth_oracle_address, address _weth_address) external;
    function mint1t1FRAX(uint256 collateral_amount, uint256 FRAX_out_min) external;
    function mintAlgorithmicFRAX(uint256 fxs_amount_d18, uint256 FRAX_out_min) external;
    function mintFractionalFRAX(uint256 collateral_amount, uint256 fxs_amount, uint256 FRAX_out_min) external;
    function redeem1t1FRAX(uint256 FRAX_amount, uint256 COLLATERAL_out_min) external;
    function redeemFractionalFRAX(uint256 FRAX_amount, uint256 FXS_out_min, uint256 COLLATERAL_out_min) external;
    function redeemAlgorithmicFRAX(uint256 FRAX_amount, uint256 FXS_out_min) external;
    function collectRedemption() external;
    function recollateralizeFRAX(uint256 collateral_amount, uint256 FXS_out_min) external;
    function buyBackFXS(uint256 FXS_amount, uint256 COLLATERAL_out_min) external;
    function toggleMinting() external;
    function toggleRedeeming() external;
    function toggleRecollateralize() external;
    function toggleBuyBack() external;
    function toggleCollateralPrice(uint256 _new_price) external;
    function setPoolParameters(uint256 new_ceiling, uint256 new_bonus_rate, uint256 new_redemption_delay, uint256 new_mint_fee, uint256 new_redeem_fee, uint256 new_buyback_fee, uint256 new_recollat_fee) external;
    function setTimelock(address new_timelock) external;
    function setOwner(address _owner_address) external;
}



pragma experimental ABIEncoderV2;

interface IAMO {
    function dollarBalances() external view returns (uint256 frax_val_e18, uint256 collat_val_e18);
}















contract FraxAMOMinter is Owned {


    IFrax public FRAX = IFrax(0x853d955aCEf822Db058eb8505911ED77F175b99e);
    IFxs public FXS = IFxs(0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0);
    ERC20 public collateral_token;
    FraxPoolV3 public pool = FraxPoolV3(0x2fE065e6FFEf9ac95ab39E5042744d695F560729);
    IFraxPool public old_pool = IFraxPool(0x1864Ca3d47AaB98Ee78D11fc9DCC5E7bADdA1c0d);
    address public timelock_address;
    address public custodian_address;

    address public collateral_address;
    uint256 public col_idx;

    address[] public amos_array;
    mapping(address => bool) public amos; // Mapping is also used for faster verification

    uint256 private constant PRICE_PRECISION = 1e6;

    int256 public collat_borrow_cap = int256(10000000e6);

    int256 public frax_mint_cap = int256(100000000e18);
    int256 public fxs_mint_cap = int256(100000000e18);

    uint256 public min_cr = 810000;

    mapping(address => int256) public frax_mint_balances; // Amount of FRAX the contract minted, by AMO
    int256 public frax_mint_sum = 0; // Across all AMOs

    mapping(address => int256) public fxs_mint_balances; // Amount of FXS the contract minted, by AMO
    int256 public fxs_mint_sum = 0; // Across all AMOs

    mapping(address => int256) public collat_borrowed_balances; // Amount of collateral the contract borrowed, by AMO
    int256 public collat_borrowed_sum = 0; // Across all AMOs

    uint256 public fraxDollarBalanceStored = 0;

    uint256 public missing_decimals;
    uint256 public collatDollarBalanceStored = 0;

    mapping(address => int256[2]) public correction_offsets_amos;

    
    constructor (
        address _owner_address,
        address _custodian_address,
        address _timelock_address,
        address _collateral_address,
        address _pool_address
    ) Owned(_owner_address) {
        custodian_address = _custodian_address;
        timelock_address = _timelock_address;

        pool = FraxPoolV3(_pool_address);

        collateral_address = _collateral_address;
        col_idx = pool.collateralAddrToIdx(_collateral_address);
        collateral_token = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        missing_decimals = uint(18) - collateral_token.decimals();
    }


    modifier onlyByOwnGov() {
        require(msg.sender == timelock_address || msg.sender == owner, "Not owner or timelock");
        _;
    }

    modifier validAMO(address amo_address) {
        require(amos[amo_address], "Invalid AMO");
        _;
    }


    function collatDollarBalance() external view returns (uint256) {
        (, uint256 collat_val_e18) = dollarBalances();
        return collat_val_e18;
    }

    function dollarBalances() public view returns (uint256 frax_val_e18, uint256 collat_val_e18) {
        frax_val_e18 = fraxDollarBalanceStored;
        collat_val_e18 = collatDollarBalanceStored;
    }

    function allAMOAddresses() external view returns (address[] memory) {
        return amos_array;
    }

    function allAMOsLength() external view returns (uint256) {
        return amos_array.length;
    }

    function fraxTrackedGlobal() external view returns (int256) {
        return int256(fraxDollarBalanceStored) - frax_mint_sum - (collat_borrowed_sum * int256(10 ** missing_decimals));
    }

    function fraxTrackedAMO(address amo_address) external view returns (int256) {
        (uint256 frax_val_e18, ) = IAMO(amo_address).dollarBalances();
        int256 frax_val_e18_corrected = int256(frax_val_e18) + correction_offsets_amos[amo_address][0];
        return frax_val_e18_corrected - frax_mint_balances[amo_address] - ((collat_borrowed_balances[amo_address]) * int256(10 ** missing_decimals));
    }


    function syncDollarBalances() public {
        uint256 total_frax_value_d18 = 0;
        uint256 total_collateral_value_d18 = 0; 
        for (uint i = 0; i < amos_array.length; i++){ 
            address amo_address = amos_array[i];
            if (amo_address != address(0)){
                (uint256 frax_val_e18, uint256 collat_val_e18) = IAMO(amo_address).dollarBalances();
                total_frax_value_d18 += uint256(int256(frax_val_e18) + correction_offsets_amos[amo_address][0]);
                total_collateral_value_d18 += uint256(int256(collat_val_e18) + correction_offsets_amos[amo_address][1]);
            }
        }
        fraxDollarBalanceStored = total_frax_value_d18;
        collatDollarBalanceStored = total_collateral_value_d18;
    }


    function oldPoolRedeem(uint256 frax_amount) external onlyByOwnGov {
        uint256 redemption_fee = old_pool.redemption_fee();
        uint256 col_price_usd = old_pool.getCollateralPrice();
        uint256 global_collateral_ratio = FRAX.global_collateral_ratio();
        uint256 redeem_amount_E6 = ((frax_amount * (uint256(1e6) - redemption_fee)) / 1e6) / (10 ** missing_decimals);
        uint256 expected_collat_amount = (redeem_amount_E6 * global_collateral_ratio) / 1e6;
        expected_collat_amount = (expected_collat_amount * 1e6) / col_price_usd;

        require((collat_borrowed_sum + int256(expected_collat_amount)) <= collat_borrow_cap, "Borrow cap");
        collat_borrowed_sum += int256(expected_collat_amount);

        FRAX.pool_mint(address(this), frax_amount);

        FRAX.approve(address(old_pool), frax_amount);
        old_pool.redeemFractionalFRAX(frax_amount, 0, 0);
    }

    function oldPoolCollectAndGive(address destination_amo) external onlyByOwnGov validAMO(destination_amo) {
        uint256 collat_amount = old_pool.redeemCollateralBalances(address(this));
        
        old_pool.collectRedemption();

        collat_borrowed_balances[destination_amo] += int256(collat_amount);

        TransferHelper.safeTransfer(collateral_address, destination_amo, collat_amount);

        syncDollarBalances();
    }



    function mintFraxForAMO(address destination_amo, uint256 frax_amount) external onlyByOwnGov validAMO(destination_amo) {
        int256 frax_amt_i256 = int256(frax_amount);

        require((frax_mint_sum + frax_amt_i256) <= frax_mint_cap, "Mint cap reached");
        frax_mint_balances[destination_amo] += frax_amt_i256;
        frax_mint_sum += frax_amt_i256;

        uint256 current_collateral_E18 = FRAX.globalCollateralValue();
        uint256 cur_frax_supply = FRAX.totalSupply();
        uint256 new_frax_supply = cur_frax_supply + frax_amount;
        uint256 new_cr = (current_collateral_E18 * PRICE_PRECISION) / new_frax_supply;
        require(new_cr >= min_cr, "CR would be too low");

        FRAX.pool_mint(destination_amo, frax_amount);

        syncDollarBalances();
    }

    function burnFraxFromAMO(uint256 frax_amount) external validAMO(msg.sender) {
        int256 frax_amt_i256 = int256(frax_amount);

        FRAX.pool_burn_from(msg.sender, frax_amount);

        frax_mint_balances[msg.sender] -= frax_amt_i256;
        frax_mint_sum -= frax_amt_i256;

        syncDollarBalances();
    }


    function mintFxsForAMO(address destination_amo, uint256 fxs_amount) external onlyByOwnGov validAMO(destination_amo) {
        int256 fxs_amt_i256 = int256(fxs_amount);

        require((fxs_mint_sum + fxs_amt_i256) <= fxs_mint_cap, "Mint cap reached");
        fxs_mint_balances[destination_amo] += fxs_amt_i256;
        fxs_mint_sum += fxs_amt_i256;

        FXS.pool_mint(destination_amo, fxs_amount);

        syncDollarBalances();
    }

    function burnFxsFromAMO(uint256 fxs_amount) external validAMO(msg.sender) {
        int256 fxs_amt_i256 = int256(fxs_amount);

        FXS.pool_burn_from(msg.sender, fxs_amount);

        fxs_mint_balances[msg.sender] -= fxs_amt_i256;
        fxs_mint_sum -= fxs_amt_i256;

        syncDollarBalances();
    }


    function giveCollatToAMO(
        address destination_amo,
        uint256 collat_amount
    ) external onlyByOwnGov validAMO(destination_amo) {
        int256 collat_amount_i256 = int256(collat_amount);

        require((collat_borrowed_sum + collat_amount_i256) <= collat_borrow_cap, "Borrow cap");
        collat_borrowed_balances[destination_amo] += collat_amount_i256;
        collat_borrowed_sum += collat_amount_i256;

        pool.amoMinterBorrow(collat_amount);

        TransferHelper.safeTransfer(collateral_address, destination_amo, collat_amount);

        syncDollarBalances();
    }

    function receiveCollatFromAMO(uint256 usdc_amount) external validAMO(msg.sender) {
        int256 collat_amt_i256 = int256(usdc_amount);

        TransferHelper.safeTransferFrom(collateral_address, msg.sender, address(pool), usdc_amount);

        collat_borrowed_balances[msg.sender] -= collat_amt_i256;
        collat_borrowed_sum -= collat_amt_i256;

        syncDollarBalances();
    }


    function addAMO(address amo_address, bool sync_too) public onlyByOwnGov {
        require(amo_address != address(0), "Zero address detected");

        (uint256 frax_val_e18, uint256 collat_val_e18) = IAMO(amo_address).dollarBalances();
        require(frax_val_e18 >= 0 && collat_val_e18 >= 0, "Invalid AMO");

        require(amos[amo_address] == false, "Address already exists");
        amos[amo_address] = true; 
        amos_array.push(amo_address);

        frax_mint_balances[amo_address] = 0;
        fxs_mint_balances[amo_address] = 0;
        collat_borrowed_balances[amo_address] = 0;

        correction_offsets_amos[amo_address][0] = 0;
        correction_offsets_amos[amo_address][1] = 0;

        if (sync_too) syncDollarBalances();

        emit AMOAdded(amo_address);
    }

    function removeAMO(address amo_address, bool sync_too) public onlyByOwnGov {
        require(amo_address != address(0), "Zero address detected");
        require(amos[amo_address] == true, "Address nonexistant");
        
        delete amos[amo_address];

        for (uint i = 0; i < amos_array.length; i++){ 
            if (amos_array[i] == amo_address) {
                amos_array[i] = address(0); // This will leave a null in the array and keep the indices the same
                break;
            }
        }

        if (sync_too) syncDollarBalances();

        emit AMORemoved(amo_address);
    }

    function setTimelock(address new_timelock) external onlyByOwnGov {
        require(new_timelock != address(0), "Timelock address cannot be 0");
        timelock_address = new_timelock;
    }

    function setCustodian(address _custodian_address) external onlyByOwnGov {
        require(_custodian_address != address(0), "Custodian address cannot be 0");        
        custodian_address = _custodian_address;
    }

    function setFraxMintCap(uint256 _frax_mint_cap) external onlyByOwnGov {
        frax_mint_cap = int256(_frax_mint_cap);
    }

    function setFxsMintCap(uint256 _fxs_mint_cap) external onlyByOwnGov {
        fxs_mint_cap = int256(_fxs_mint_cap);
    }

    function setCollatBorrowCap(uint256 _collat_borrow_cap) external onlyByOwnGov {
        collat_borrow_cap = int256(_collat_borrow_cap);
    }

    function setMinimumCollateralRatio(uint256 _min_cr) external onlyByOwnGov {
        min_cr = _min_cr;
    }

    function setAMOCorrectionOffsets(address amo_address, int256 frax_e18_correction, int256 collat_e18_correction) external onlyByOwnGov {
        correction_offsets_amos[amo_address][0] = frax_e18_correction;
        correction_offsets_amos[amo_address][1] = collat_e18_correction;

        syncDollarBalances();
    }

    function setFraxPool(address _pool_address) external onlyByOwnGov {
        pool = FraxPoolV3(_pool_address);

        require(pool.collateralAddrToIdx(collateral_address) == col_idx, "col_idx mismatch");
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyByOwnGov {
        TransferHelper.safeTransfer(tokenAddress, owner, tokenAmount);
        
        emit Recovered(tokenAddress, tokenAmount);
    }

    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyByOwnGov returns (bool, bytes memory) {
        (bool success, bytes memory result) = _to.call{value:_value}(_data);
        return (success, result);
    }


    event AMOAdded(address amo_address);
    event AMORemoved(address amo_address);
    event Recovered(address token, uint256 amount);
}