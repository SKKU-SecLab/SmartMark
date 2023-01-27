
pragma solidity 0.6.11; 
pragma experimental ABIEncoderV2;




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


library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }
    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }
    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) { // Equivalent to contains(set, value)
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            bytes32 lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }
    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }
    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }
    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }
    struct AddressSet {
        Set _inner;
    }
    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }
    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }
    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }
    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }
    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }
    struct UintSet {
        Set _inner;
    }
    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }
    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }
    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
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


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;
    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }
    mapping (bytes32 => RoleData) private _roles;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");
        _grantRole(role, account);
    }
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");
        _revokeRole(role, account);
    }
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");
        _revokeRole(role, account);
    }
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }
    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }
    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


contract ContractGuard {

    mapping(uint256 => mapping(address => bool)) private _status;
    function checkSameOriginReentranted() internal view returns (bool) {

        return _status[block.number][tx.origin];
    }
    function checkSameSenderReentranted() internal view returns (bool) {

        return _status[block.number][msg.sender];
    }
    modifier onlyOneBlock() {

        require(
            !checkSameOriginReentranted(),
            'ContractGuard: one block, one function'
        );
        require(
            !checkSameSenderReentranted(),
            'ContractGuard: one block, one function'
        );
        _;
        _status[block.number][tx.origin] = true;
        _status[block.number][msg.sender] = true;
    }
}



interface IERC20Detail is IERC20 {

    function decimals() external view returns (uint8);

}




interface IShareToken is IERC20 {  

    function pool_mint(address m_address, uint256 m_amount) external; 

    function pool_burn_from(address b_address, uint256 b_amount) external; 

    function burn(uint256 amount) external;

}


interface IUniswapPairOracle { 

    function getPairToken(address token) external view returns(address);

    function containsToken(address token) external view returns(bool);

    function getSwapTokenReserve(address token) external view returns(uint256);

    function update() external returns(bool);

    function consult(address token, uint amountIn) external view returns (uint amountOut);

}



interface IUSEStablecoin {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function owner_address() external returns (address);

    function creator_address() external returns (address);

    function timelock_address() external returns (address); 

    function genesis_supply() external returns (uint256); 

    function refresh_cooldown() external returns (uint256);

    function price_target() external returns (uint256);

    function price_band() external returns (uint256);

    function DEFAULT_ADMIN_ADDRESS() external returns (address);

    function COLLATERAL_RATIO_PAUSER() external returns (bytes32);

    function collateral_ratio_paused() external returns (bool);

    function last_call_time() external returns (uint256);

    function USEDAIOracle() external returns (IUniswapPairOracle);

    function USESharesOracle() external returns (IUniswapPairOracle); 

    function use_pools(address a) external view returns (bool);

    function global_collateral_ratio() external view returns (uint256);

    function use_price() external view returns (uint256);

    function share_price()  external view returns (uint256);

    function share_price_in_use()  external view returns (uint256); 

    function globalCollateralValue() external view returns (uint256);

    function refreshCollateralRatio() external;

    function swapCollateralAmount() external view returns(uint256);

    function pool_mint(address m_address, uint256 m_amount) external;

    function pool_burn_from(address b_address, uint256 b_amount) external;

    function burn(uint256 amount) external;

}




contract USEPoolAlgo {

    using SafeMath for uint256;
    uint256 public constant PRICE_PRECISION = 1e6;
    uint256 public constant COLLATERAL_RATIO_PRECISION = 1e6;
    struct MintFU_Params {
        uint256 shares_price_usd; 
        uint256 col_price_usd;
        uint256 shares_amount;
        uint256 collateral_amount;
        uint256 col_ratio;
    }
    struct BuybackShares_Params {
        uint256 excess_collateral_dollar_value_d18;
        uint256 shares_price_usd;
        uint256 col_price_usd;
        uint256 shares_amount;
    }
    function calcMint1t1USE(uint256 col_price, uint256 collateral_amount_d18) public pure returns (uint256) {

        return (collateral_amount_d18.mul(col_price)).div(1e6);
    } 
    function calcMintFractionalUSE(MintFU_Params memory params) public pure returns (uint256,uint256, uint256) {

          (uint256 mint_amount1, uint256 collateral_need_d18_1, uint256 shares_needed1) = calcMintFractionalWithCollateral(params);
          (uint256 mint_amount2, uint256 collateral_need_d18_2, uint256 shares_needed2) = calcMintFractionalWithShare(params);
          if(mint_amount1 > mint_amount2){
              return (mint_amount2,collateral_need_d18_2,shares_needed2);
          }else{
              return (mint_amount1,collateral_need_d18_1,shares_needed1);
          }
    }
    function calcMintFractionalWithCollateral(MintFU_Params memory params) public pure returns (uint256,uint256, uint256) {

        uint256 c_dollar_value_d18_with_precision = params.collateral_amount.mul(params.col_price_usd);
        uint256 c_dollar_value_d18 = c_dollar_value_d18_with_precision.div(1e6); 
        uint calculated_shares_dollar_value_d18 = 
                    (c_dollar_value_d18_with_precision.div(params.col_ratio))
                    .sub(c_dollar_value_d18);
        uint calculated_shares_needed = calculated_shares_dollar_value_d18.mul(1e6).div(params.shares_price_usd);
        return (
            c_dollar_value_d18.add(calculated_shares_dollar_value_d18),
            params.collateral_amount,
            calculated_shares_needed
        );
    }
    function calcMintFractionalWithShare(MintFU_Params memory params) public pure returns (uint256,uint256, uint256) {

        uint256 shares_dollar_value_d18_with_precision = params.shares_amount.mul(params.shares_price_usd);
        uint256 shares_dollar_value_d18 = shares_dollar_value_d18_with_precision.div(1e6); 
        uint calculated_collateral_dollar_value_d18 = 
                    shares_dollar_value_d18_with_precision.mul(params.col_ratio)
                    .div(COLLATERAL_RATIO_PRECISION.sub(params.col_ratio)).div(1e6); 
        uint calculated_collateral_needed = calculated_collateral_dollar_value_d18.mul(1e6).div(params.col_price_usd);
        return (
            shares_dollar_value_d18.add(calculated_collateral_dollar_value_d18),
            calculated_collateral_needed,
            params.shares_amount
        );
    }
    function calcRedeem1t1USE(uint256 col_price_usd, uint256 use_amount) public pure returns (uint256) {

        return use_amount.mul(1e6).div(col_price_usd);
    }
    function calcBuyBackShares(BuybackShares_Params memory params) public pure returns (uint256) {

        require(params.excess_collateral_dollar_value_d18 > 0, "No excess collateral to buy back!");
        uint256 shares_dollar_value_d18 = params.shares_amount.mul(params.shares_price_usd).div(1e6);
        require(shares_dollar_value_d18 <= params.excess_collateral_dollar_value_d18, "You are trying to buy back more than the excess!");
        uint256 collateral_equivalent_d18 = shares_dollar_value_d18.mul(1e6).div(params.col_price_usd);
        return (
            collateral_equivalent_d18
        );
    }
    function recollateralizeAmount(uint256 total_supply, uint256 global_collateral_ratio, uint256 global_collat_value) public pure returns (uint256) {

        uint256 target_collat_value = total_supply.mul(global_collateral_ratio).div(1e6); // We want 18 decimals of precision so divide by 1e6; total_supply is 1e18 and global_collateral_ratio is 1e6
        return target_collat_value.sub(global_collat_value); // If recollateralization is not needed, throws a subtraction underflow
    }
    function calcRecollateralizeUSEInner(
        uint256 collateral_amount, 
        uint256 col_price,
        uint256 global_collat_value,
        uint256 frax_total_supply,
        uint256 global_collateral_ratio
    ) public pure returns (uint256, uint256) {

        uint256 collat_value_attempted = collateral_amount.mul(col_price).div(1e6);
        uint256 effective_collateral_ratio = global_collat_value.mul(1e6).div(frax_total_supply); //returns it in 1e6
        uint256 recollat_possible = (global_collateral_ratio.mul(frax_total_supply).sub(frax_total_supply.mul(effective_collateral_ratio))).div(1e6);
        uint256 amount_to_recollat;
        if(collat_value_attempted <= recollat_possible){
            amount_to_recollat = collat_value_attempted;
        } else {
            amount_to_recollat = recollat_possible;
        }
        return (amount_to_recollat.mul(1e6).div(col_price), amount_to_recollat);
    }
}


abstract contract USEPool is USEPoolAlgo,ContractGuard,AccessControl {
    using SafeMath for uint256;
    IERC20Detail public collateral_token;
    address public collateral_address;
    address public owner_address;
    address public community_address;
    address public use_contract_address;
    address public shares_contract_address;
    address public timelock_address;
    IShareToken private SHARE;
    IUSEStablecoin private USE; 
    uint256 public minting_tax_base;
    uint256 public minting_tax_multiplier; 
    uint256 public minting_required_reserve_ratio;
    uint256 public redemption_gcr_adj = PRECISION;   // PRECISION/PRECISION = 1
    uint256 public redemption_tax_base;
    uint256 public redemption_tax_multiplier;
    uint256 public redemption_tax_exponent;
    uint256 public redemption_required_reserve_ratio = 800000;
    uint256 public buyback_tax;
    uint256 public recollat_tax;
    uint256 public community_rate_ratio = 15000;
    uint256 public community_rate_in_use;
    uint256 public community_rate_in_share;
    mapping (address => uint256) public redeemSharesBalances;
    mapping (address => uint256) public redeemCollateralBalances;
    uint256 public unclaimedPoolCollateral;
    uint256 public unclaimedPoolShares;
    mapping (address => uint256) public lastRedeemed;
    uint256 public constant PRECISION = 1e6;  
    uint256 public constant RESERVE_RATIO_PRECISION = 1e6;    
    uint256 public constant COLLATERAL_RATIO_MAX = 1e6;
    uint256 public immutable missing_decimals;
    uint256 public pool_ceiling = 10000000000e18;
    uint256 public pausedPrice = 0;
    uint256 public bonus_rate = 5000;
    uint256 public redemption_delay = 2;
    uint256 public global_use_supply_adj = 1000e18;  //genesis_supply
    bytes32 public constant MINT_PAUSER = keccak256("MINT_PAUSER");
    bytes32 public constant REDEEM_PAUSER = keccak256("REDEEM_PAUSER");
    bytes32 public constant BUYBACK_PAUSER = keccak256("BUYBACK_PAUSER");
    bytes32 public constant RECOLLATERALIZE_PAUSER = keccak256("RECOLLATERALIZE_PAUSER");
    bytes32 public constant COLLATERAL_PRICE_PAUSER = keccak256("COLLATERAL_PRICE_PAUSER");
    bytes32 public constant COMMUNITY_RATER = keccak256("COMMUNITY_RATER");
    bool public mintPaused = false;
    bool public redeemPaused = false;
    bool public recollateralizePaused = false;
    bool public buyBackPaused = false;
    bool public collateralPricePaused = false;
    event UpdateOracleBonus(address indexed user,bool bonus1, bool bonus2);
    modifier onlyByOwnerOrGovernance() {
        require(msg.sender == timelock_address || msg.sender == owner_address, "You are not the owner or the governance timelock");
        _;
    }
    modifier notRedeemPaused() {
        require(redeemPaused == false, "Redeeming is paused");
        require(redemptionOpened() == true,"Redeeming is closed");
        _;
    }
    modifier notMintPaused() {
        require(mintPaused == false, "Minting is paused");
        require(mintingOpened() == true,"Minting is closed");
        _;
    }
    constructor(
        address _use_contract_address,
        address _shares_contract_address,
        address _collateral_address,
        address _creator_address,
        address _timelock_address,
        address _community_address
    ) public {
        USE = IUSEStablecoin(_use_contract_address);
        SHARE = IShareToken(_shares_contract_address);
        use_contract_address = _use_contract_address;
        shares_contract_address = _shares_contract_address;
        collateral_address = _collateral_address;
        timelock_address = _timelock_address;
        owner_address = _creator_address;
        community_address = _community_address;
        collateral_token = IERC20Detail(_collateral_address); 
        missing_decimals = uint(18).sub(collateral_token.decimals());
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        grantRole(MINT_PAUSER, timelock_address);
        grantRole(REDEEM_PAUSER, timelock_address);
        grantRole(RECOLLATERALIZE_PAUSER, timelock_address);
        grantRole(BUYBACK_PAUSER, timelock_address);
        grantRole(COLLATERAL_PRICE_PAUSER, timelock_address);
        grantRole(COMMUNITY_RATER, _community_address);
    }
    function collatDollarBalance() public view returns (uint256) {
        uint256 collateral_amount = collateral_token.balanceOf(address(this)).sub(unclaimedPoolCollateral);
        uint256 collat_usd_price = collateralPricePaused == true ? pausedPrice : getCollateralPrice();
        return collateral_amount.mul(10 ** missing_decimals).mul(collat_usd_price).div(PRICE_PRECISION); 
    }
    function availableExcessCollatDV() public view returns (uint256) {      
        uint256 total_supply = USE.totalSupply().sub(global_use_supply_adj);       
        uint256 global_collat_value = USE.globalCollateralValue();
        uint256 global_collateral_ratio = USE.global_collateral_ratio();
        if (global_collateral_ratio > COLLATERAL_RATIO_PRECISION) {
            global_collateral_ratio = COLLATERAL_RATIO_PRECISION; 
        }
        uint256 required_collat_dollar_value_d18 = (total_supply.mul(global_collateral_ratio)).div(COLLATERAL_RATIO_PRECISION);
        if (global_collat_value > required_collat_dollar_value_d18) {
           return global_collat_value.sub(required_collat_dollar_value_d18);
        }
        return 0;
    }
    function getCollateralPrice() public view virtual returns (uint256);
    function getCollateralAmount()   public view  returns (uint256){
        return collateral_token.balanceOf(address(this)).sub(unclaimedPoolCollateral);
    }
    function requiredReserveRatio() public view returns(uint256){
        uint256 pool_collateral_amount = getCollateralAmount();
        uint256 swap_collateral_amount = USE.swapCollateralAmount();
        require(swap_collateral_amount>0,"swap collateral is empty?");
        return pool_collateral_amount.mul(RESERVE_RATIO_PRECISION).div(swap_collateral_amount);
    }
    function mintingOpened() public view returns(bool){ 
        return  (requiredReserveRatio() >= minting_required_reserve_ratio);
    }
    function redemptionOpened() public view returns(bool){
        return  (requiredReserveRatio() >= redemption_required_reserve_ratio);
    }
    function mintingTax() public view returns(uint256){
        uint256 _dynamicTax =  minting_tax_multiplier.mul(requiredReserveRatio()).div(RESERVE_RATIO_PRECISION); 
        return  minting_tax_base + _dynamicTax;       
    }
    function dynamicRedemptionTax(uint256 ratio,uint256 multiplier,uint256 exponent) public pure returns(uint256){        
        return multiplier.mul(RESERVE_RATIO_PRECISION**exponent).div(ratio**exponent);
    }
    function redemptionTax() public view returns(uint256){
        uint256 _dynamicTax =dynamicRedemptionTax(requiredReserveRatio(),redemption_tax_multiplier,redemption_tax_exponent);
        return  redemption_tax_base + _dynamicTax;       
    } 
    function updateOraclePrice() public { 
        IUniswapPairOracle _useDaiOracle = USE.USEDAIOracle();
        IUniswapPairOracle _useSharesOracle = USE.USESharesOracle();
        bool _bonus1 = _useDaiOracle.update();
        bool _bonus2 = _useSharesOracle.update(); 
        if(_bonus1 || _bonus2){
            emit UpdateOracleBonus(msg.sender,_bonus1,_bonus2);
        }
    }
    function mint1t1USE(uint256 collateral_amount, uint256 use_out_min) external onlyOneBlock notMintPaused { 
        updateOraclePrice();       
        uint256 collateral_amount_d18 = collateral_amount * (10 ** missing_decimals);
        require(USE.global_collateral_ratio() >= COLLATERAL_RATIO_MAX, "Collateral ratio must be >= 1");
        require(getCollateralAmount().add(collateral_amount) <= pool_ceiling, "[Pool's Closed]: Ceiling reached");
        (uint256 use_amount_d18) = calcMint1t1USE(
            getCollateralPrice(),
            collateral_amount_d18
        ); //1 USE for each $1 worth of collateral
        community_rate_in_use  =  community_rate_in_use.add(use_amount_d18.mul(community_rate_ratio).div(PRECISION));
        use_amount_d18 = (use_amount_d18.mul(uint(1e6).sub(mintingTax()))).div(1e6); //remove precision at the end
        require(use_out_min <= use_amount_d18, "Slippage limit reached");
        collateral_token.transferFrom(msg.sender, address(this), collateral_amount);
        USE.pool_mint(msg.sender, use_amount_d18);  
    }
    function mintFractionalUSE(uint256 collateral_amount, uint256 shares_amount, uint256 use_out_min) external onlyOneBlock notMintPaused {
        updateOraclePrice();
        uint256 share_price = USE.share_price();
        uint256 global_collateral_ratio = USE.global_collateral_ratio();
        require(global_collateral_ratio < COLLATERAL_RATIO_MAX && global_collateral_ratio > 0, "Collateral ratio needs to be between .000001 and .999999");
        require(getCollateralAmount().add(collateral_amount) <= pool_ceiling, "Pool ceiling reached, no more USE can be minted with this collateral");
        uint256 collateral_amount_d18 = collateral_amount * (10 ** missing_decimals);
        MintFU_Params memory input_params = MintFU_Params(
            share_price,
            getCollateralPrice(),
            shares_amount,
            collateral_amount_d18,
            global_collateral_ratio
        );
        (uint256 mint_amount,uint256 collateral_need_d18, uint256 shares_needed) = calcMintFractionalUSE(input_params);
        community_rate_in_use  =  community_rate_in_use.add(mint_amount.mul(community_rate_ratio).div(PRECISION));
        mint_amount = (mint_amount.mul(uint(1e6).sub(mintingTax()))).div(1e6);
        require(use_out_min <= mint_amount, "Slippage limit reached");
        require(shares_needed <= shares_amount, "Not enough Shares inputted");
        uint256 collateral_need = collateral_need_d18.div(10 ** missing_decimals);
        SHARE.pool_burn_from(msg.sender, shares_needed);
        collateral_token.transferFrom(msg.sender, address(this), collateral_need);
        USE.pool_mint(msg.sender, mint_amount);      
    }
    function redeem1t1USE(uint256 use_amount, uint256 COLLATERAL_out_min) external onlyOneBlock notRedeemPaused {
        updateOraclePrice();
        require(USE.global_collateral_ratio() == COLLATERAL_RATIO_MAX, "Collateral ratio must be == 1");
        uint256 use_amount_precision = use_amount.div(10 ** missing_decimals);
        (uint256 collateral_needed) = calcRedeem1t1USE(
            getCollateralPrice(),
            use_amount_precision
        );
        community_rate_in_use  =  community_rate_in_use.add(use_amount.mul(community_rate_ratio).div(PRECISION));
        collateral_needed = (collateral_needed.mul(uint(1e6).sub(redemptionTax()))).div(1e6);
        require(collateral_needed <= getCollateralAmount(), "Not enough collateral in pool");
        require(COLLATERAL_out_min <= collateral_needed, "Slippage limit reached");
        redeemCollateralBalances[msg.sender] = redeemCollateralBalances[msg.sender].add(collateral_needed);
        unclaimedPoolCollateral = unclaimedPoolCollateral.add(collateral_needed);
        lastRedeemed[msg.sender] = block.number;
        USE.pool_burn_from(msg.sender, use_amount); 
        require(redemptionOpened() == true,"Redeem amount too large !");
    }
    function redeemFractionalUSE(uint256 use_amount, uint256 shares_out_min, uint256 COLLATERAL_out_min) external onlyOneBlock notRedeemPaused {
        updateOraclePrice();
        uint256 global_collateral_ratio = USE.global_collateral_ratio();
        require(global_collateral_ratio < COLLATERAL_RATIO_MAX && global_collateral_ratio > 0, "Collateral ratio needs to be between .000001 and .999999");
        global_collateral_ratio = global_collateral_ratio.mul(redemption_gcr_adj).div(PRECISION);
        uint256 use_amount_post_tax = (use_amount.mul(uint(1e6).sub(redemptionTax()))).div(PRICE_PRECISION);
        uint256 shares_dollar_value_d18 = use_amount_post_tax.sub(use_amount_post_tax.mul(global_collateral_ratio).div(PRICE_PRECISION));
        uint256 shares_amount = shares_dollar_value_d18.mul(PRICE_PRECISION).div(USE.share_price());
        uint256 use_amount_precision = use_amount_post_tax.div(10 ** missing_decimals);
        uint256 collateral_dollar_value = use_amount_precision.mul(global_collateral_ratio).div(PRICE_PRECISION);
        uint256 collateral_amount = collateral_dollar_value.mul(PRICE_PRECISION).div(getCollateralPrice());
        require(collateral_amount <= getCollateralAmount(), "Not enough collateral in pool");
        require(COLLATERAL_out_min <= collateral_amount, "Slippage limit reached [collateral]");
        require(shares_out_min <= shares_amount, "Slippage limit reached [Shares]");
        community_rate_in_use  =  community_rate_in_use.add(use_amount.mul(community_rate_ratio).div(PRECISION));
        redeemCollateralBalances[msg.sender] = redeemCollateralBalances[msg.sender].add(collateral_amount);
        unclaimedPoolCollateral = unclaimedPoolCollateral.add(collateral_amount);
        redeemSharesBalances[msg.sender] = redeemSharesBalances[msg.sender].add(shares_amount);
        unclaimedPoolShares = unclaimedPoolShares.add(shares_amount);
        lastRedeemed[msg.sender] = block.number;
        USE.pool_burn_from(msg.sender, use_amount);
        SHARE.pool_mint(address(this), shares_amount);
        require(redemptionOpened() == true,"Redeem amount too large !");
    }
    function collectRedemption() external onlyOneBlock{        
        require((lastRedeemed[msg.sender].add(redemption_delay)) <= block.number, "Must wait for redemption_delay blocks before collecting redemption");
        bool sendShares = false;
        bool sendCollateral = false;
        uint sharesAmount;
        uint CollateralAmount;
        if(redeemSharesBalances[msg.sender] > 0){
            sharesAmount = redeemSharesBalances[msg.sender];
            redeemSharesBalances[msg.sender] = 0;
            unclaimedPoolShares = unclaimedPoolShares.sub(sharesAmount);
            sendShares = true;
        }
        if(redeemCollateralBalances[msg.sender] > 0){
            CollateralAmount = redeemCollateralBalances[msg.sender];
            redeemCollateralBalances[msg.sender] = 0;
            unclaimedPoolCollateral = unclaimedPoolCollateral.sub(CollateralAmount);
            sendCollateral = true;
        }
        if(sendShares == true){
            SHARE.transfer(msg.sender, sharesAmount);
        }
        if(sendCollateral == true){
            collateral_token.transfer(msg.sender, CollateralAmount);
        }
    }
    function recollateralizeUSE(uint256 collateral_amount, uint256 shares_out_min) external onlyOneBlock {
        require(recollateralizePaused == false, "Recollateralize is paused");
        updateOraclePrice();
        uint256 collateral_amount_d18 = collateral_amount * (10 ** missing_decimals);
        uint256 share_price = USE.share_price();
        uint256 use_total_supply = USE.totalSupply().sub(global_use_supply_adj);
        uint256 global_collateral_ratio = USE.global_collateral_ratio();
        uint256 global_collat_value = USE.globalCollateralValue();
        (uint256 collateral_units, uint256 amount_to_recollat) = calcRecollateralizeUSEInner(
            collateral_amount_d18,
            getCollateralPrice(),
            global_collat_value,
            use_total_supply,
            global_collateral_ratio
        ); 
        uint256 collateral_units_precision = collateral_units.div(10 ** missing_decimals);
        uint256 shares_paid_back = amount_to_recollat.mul(uint(1e6).add(bonus_rate).sub(recollat_tax)).div(share_price);
        require(shares_out_min <= shares_paid_back, "Slippage limit reached");
        community_rate_in_share =  community_rate_in_share.add(shares_paid_back.mul(community_rate_ratio).div(PRECISION));
        collateral_token.transferFrom(msg.sender, address(this), collateral_units_precision);
        SHARE.pool_mint(msg.sender, shares_paid_back);
    }
    function buyBackShares(uint256 shares_amount, uint256 COLLATERAL_out_min) external onlyOneBlock {
        require(buyBackPaused == false, "Buyback is paused");
        updateOraclePrice();
        uint256 share_price = USE.share_price();
        BuybackShares_Params memory input_params = BuybackShares_Params(
            availableExcessCollatDV(),
            share_price,
            getCollateralPrice(),
            shares_amount
        );
        (uint256 collateral_equivalent_d18) = (calcBuyBackShares(input_params)).mul(uint(1e6).sub(buyback_tax)).div(1e6);
        uint256 collateral_precision = collateral_equivalent_d18.div(10 ** missing_decimals);
        require(COLLATERAL_out_min <= collateral_precision, "Slippage limit reached");
        community_rate_in_share  =  community_rate_in_share.add(shares_amount.mul(community_rate_ratio).div(PRECISION));
        SHARE.pool_burn_from(msg.sender, shares_amount);
        collateral_token.transfer(msg.sender, collateral_precision);
    }
    function toggleMinting() external {
        require(hasRole(MINT_PAUSER, msg.sender));
        mintPaused = !mintPaused;
    }
    function toggleRedeeming() external {
        require(hasRole(REDEEM_PAUSER, msg.sender));
        redeemPaused = !redeemPaused;
    }
    function toggleRecollateralize() external {
        require(hasRole(RECOLLATERALIZE_PAUSER, msg.sender));
        recollateralizePaused = !recollateralizePaused;
    }
    function toggleBuyBack() external {
        require(hasRole(BUYBACK_PAUSER, msg.sender));
        buyBackPaused = !buyBackPaused;
    }
    function toggleCollateralPrice(uint256 _new_price) external {
        require(hasRole(COLLATERAL_PRICE_PAUSER, msg.sender));
        if(collateralPricePaused == false){
            pausedPrice = _new_price;
        } else {
            pausedPrice = 0;
        }
        collateralPricePaused = !collateralPricePaused;
    }
    function toggleCommunityInSharesRate(uint256 _rate) external{
        require(community_rate_in_share>0,"No SHARE rate");
        require(hasRole(COMMUNITY_RATER, msg.sender));
        uint256 _amount_rate = community_rate_in_share.mul(_rate).div(PRECISION);
        community_rate_in_share = community_rate_in_share.sub(_amount_rate);
        SHARE.pool_mint(msg.sender,_amount_rate);  
    }
    function toggleCommunityInUSERate(uint256 _rate) external{
        require(community_rate_in_use>0,"No USE rate");
        require(hasRole(COMMUNITY_RATER, msg.sender));
        uint256 _amount_rate_use = community_rate_in_use.mul(_rate).div(PRECISION);        
        community_rate_in_use = community_rate_in_use.sub(_amount_rate_use);
        uint256 _share_price_use = USE.share_price_in_use();
        uint256 _amount_rate = _amount_rate_use.mul(PRICE_PRECISION).div(_share_price_use);
        SHARE.pool_mint(msg.sender,_amount_rate);  
    }
    function setPoolParameters(uint256 new_ceiling, 
                               uint256 new_bonus_rate, 
                               uint256 new_redemption_delay, 
                               uint256 new_buyback_tax, 
                               uint256 new_recollat_tax,
                               uint256 use_supply_adj) external onlyByOwnerOrGovernance {
        pool_ceiling = new_ceiling;
        bonus_rate = new_bonus_rate;
        redemption_delay = new_redemption_delay; 
        buyback_tax = new_buyback_tax;
        recollat_tax = new_recollat_tax;
        global_use_supply_adj = use_supply_adj;
    }
    function setMintingParameters(uint256 _ratioLevel,
                                  uint256 _tax_base,
                                  uint256 _tax_multiplier) external onlyByOwnerOrGovernance{
        minting_required_reserve_ratio = _ratioLevel;
        minting_tax_base = _tax_base;
        minting_tax_multiplier = _tax_multiplier;
    }
    function setRedemptionParameters(uint256 _ratioLevel,
                                     uint256 _tax_base,
                                     uint256 _tax_multiplier,
                                     uint256 _tax_exponent,
                                     uint256 _redeem_gcr_adj) external onlyByOwnerOrGovernance{
        redemption_required_reserve_ratio = _ratioLevel;
        redemption_tax_base = _tax_base;
        redemption_tax_multiplier = _tax_multiplier;
        redemption_tax_exponent = _tax_exponent;
        redemption_gcr_adj = _redeem_gcr_adj;
    }
    function setTimelock(address new_timelock) external onlyByOwnerOrGovernance {
        timelock_address = new_timelock;
    }
    function setOwner(address _owner_address) external onlyByOwnerOrGovernance {
        owner_address = _owner_address;
    }
    function setCommunityParameters(address _community_address,uint256 _ratio) external onlyByOwnerOrGovernance {
        community_address = _community_address;
        community_rate_ratio = _ratio;
    } 
}


contract USEPoolDAI is USEPool {

    address public DAI_address;
    constructor(
        address _use_contract_address,
        address _shares_contract_address,
        address _collateral_address,
        address _creator_address, 
        address _timelock_address,
        address _community_address
    ) 
    USEPool(_use_contract_address, _shares_contract_address, _collateral_address, _creator_address, _timelock_address,_community_address)
    public {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        DAI_address = _collateral_address;
    }
    function getCollateralPrice() public view override returns (uint256) {

        if(collateralPricePaused == true){
            return pausedPrice;
        } else { 
            return 1 * PRICE_PRECISION; 
        }
    } 
}