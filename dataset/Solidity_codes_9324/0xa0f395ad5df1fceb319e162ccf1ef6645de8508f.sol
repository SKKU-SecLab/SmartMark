pragma solidity >=0.6.11;

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
}// Be name Khoda


interface IDEUSToken {

    function setDEIAddress(address dei_contract_address) external;

    function mint(address to, uint256 amount) external;


    function pool_mint(address m_address, uint256 m_amount) external;


    function pool_burn_from(address b_address, uint256 b_amount) external;


    function toggleVotes() external;



    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);



    function getCurrentVotes(address account) external view returns (uint96);


    function getPriorVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint96);

}



interface IDEIStablecoin {


    function totalSupply() external view returns (uint256);


    function global_collateral_ratio() external view returns (uint256);

	
    function verify_price(bytes32 sighash, bytes[] calldata sigs) external view returns (bool);


	function dei_info(uint256 eth_usd_price, uint256 eth_collat_price)
		external
		view
		returns (
			uint256,
			uint256,
			uint256
		);


	function globalCollateralValue(uint256[] memory collat_usd_price) external view returns (uint256);


	function refreshCollateralRatio(uint256 dei_price_cur, uint256 expireBlock, bytes[] calldata sigs) external;


	function pool_burn_from(address b_address, uint256 b_amount) external;


	function pool_mint(address m_address, uint256 m_amount) external;


	function addPool(address pool_address) external;


	function removePool(address pool_address) external;


	function setDEIStep(uint256 _new_step) external;


	function setPriceTarget(uint256 _new_price_target) external;


	function setRefreshCooldown(uint256 _new_cooldown) external;


	function setDEUSAddress(address _deus_address) external;


	function setPriceBand(uint256 _price_band) external;

	
    function toggleCollateralRatio() external;

}

pragma solidity >=0.6.11;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT
pragma solidity >=0.6.11;

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
}// MIT
pragma solidity >=0.6.11;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity >=0.6.11 <0.9.0;

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
}// MIT
pragma solidity >=0.6.11;



 
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

}// MIT

pragma solidity >=0.6.11;

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
        return _add(set._inner, bytes32(bytes20(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(bytes20(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(bytes20(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(bytes20(_at(set._inner, index)));
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
}// MIT

pragma solidity >=0.6.11;


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00; //bytes32(uint256(0x4B437D01b575618140442A4975db38850e3f8f5f) << 96);

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
}// Be name Khoda

pragma solidity >=0.8.0;

contract DEIPoolLibrary {

    uint256 private constant PRICE_PRECISION = 1e6;

    constructor() {}

    struct MintFD_Params {
        uint256 deus_price_usd; 
        uint256 col_price_usd;
        uint256 collateral_amount;
        uint256 col_ratio;
    }

    struct BuybackDEUS_Params {
        uint256 excess_collateral_dollar_value_d18;
        uint256 deus_price_usd;
        uint256 col_price_usd;
        uint256 DEUS_amount;
    }


    function calcMint1t1DEI(uint256 col_price, uint256 collateral_amount_d18) public pure returns (uint256) {
        return (collateral_amount_d18 * col_price) / (1e6);
    }

    function calcMintAlgorithmicDEI(uint256 deus_price_usd, uint256 deus_amount_d18) public pure returns (uint256) {
        return (deus_amount_d18 * deus_price_usd) / (1e6);
    }

    function calcMintFractionalDEI(MintFD_Params memory params) public pure returns (uint256, uint256) {
        uint256 c_dollar_value_d18;
        
        {    
            c_dollar_value_d18 = (params.collateral_amount * params.col_price_usd) / (1e6);

        }
        uint calculated_deus_dollar_value_d18 = ((c_dollar_value_d18 * (1e6)) / params.col_ratio) - c_dollar_value_d18;

        uint calculated_deus_needed = (calculated_deus_dollar_value_d18 * (1e6)) / params.deus_price_usd;

        return (
            c_dollar_value_d18 + calculated_deus_dollar_value_d18,
            calculated_deus_needed
        );
    }

    function calcRedeem1t1DEI(uint256 col_price_usd, uint256 DEI_amount) public pure returns (uint256) {
        return (DEI_amount * (1e6)) / col_price_usd;
    }

    function calcBuyBackDEUS(BuybackDEUS_Params memory params) public pure returns (uint256) {
        require(params.excess_collateral_dollar_value_d18 > 0, "No excess collateral to buy back!");

        uint256 deus_dollar_value_d18 = (params.DEUS_amount * (params.deus_price_usd)) / (1e6);
        require(deus_dollar_value_d18 <= params.excess_collateral_dollar_value_d18, "You are trying to buy back more than the excess!");

        uint256 collateral_equivalent_d18 = (deus_dollar_value_d18 * (1e6)) / params.col_price_usd;

        return collateral_equivalent_d18;

    }


    function recollateralizeAmount(uint256 total_supply, uint256 global_collateral_ratio, uint256 global_collat_value) public pure returns (uint256) {
        uint256 target_collat_value = (total_supply * global_collateral_ratio) / (1e6); // We want 18 decimals of precision so divide by 1e6; total_supply is 1e18 and global_collateral_ratio is 1e6
        return target_collat_value - global_collat_value; // If recollateralization is not needed, throws a subtraction underflow
    }

    function calcRecollateralizeDEIInner(
        uint256 collateral_amount, 
        uint256 col_price,
        uint256 global_collat_value,
        uint256 dei_total_supply,
        uint256 global_collateral_ratio
    ) public pure returns (uint256, uint256) {
        uint256 collat_value_attempted = (collateral_amount * col_price) / (1e6);
        uint256 effective_collateral_ratio = (global_collat_value * (1e6)) / dei_total_supply; //returns it in 1e6
        uint256 recollat_possible = (global_collateral_ratio * dei_total_supply - (dei_total_supply * effective_collateral_ratio)) / (1e6);

        uint256 amount_to_recollat;
        if(collat_value_attempted <= recollat_possible){
            amount_to_recollat = collat_value_attempted;
        } else {
            amount_to_recollat = recollat_possible;
        }

        return ((amount_to_recollat * (1e6)) / col_price, amount_to_recollat);

    }

}


pragma solidity ^0.8.0;
pragma abicoder v2;




contract DEIPool is AccessControl {

    struct RecollateralizeDEI {
		uint256 collateral_amount;
		uint256 pool_collateral_price;
		uint256[] collateral_price;
		uint256 deus_current_price;
		uint256 expireBlock;
		bytes[] sigs;
    }


	ERC20 private collateral_token;
	address private collateral_address;

	address private dei_contract_address;
	address private deus_contract_address;

	uint256 public minting_fee;
	uint256 public redemption_fee;
	uint256 public buyback_fee;
	uint256 public recollat_fee;

	mapping(address => uint256) public redeemDEUSBalances;
	mapping(address => uint256) public redeemCollateralBalances;
	uint256 public unclaimedPoolCollateral;
	uint256 public unclaimedPoolDEUS;
	mapping(address => uint256) public lastRedeemed;

	uint256 private constant PRICE_PRECISION = 1e6;
	uint256 private constant COLLATERAL_RATIO_PRECISION = 1e6;
	uint256 private constant COLLATERAL_RATIO_MAX = 1e6;

	uint256 private immutable missing_decimals;

	uint256 public pool_ceiling = 0;

	uint256 public pausedPrice = 0;

	uint256 public bonus_rate = 7500;

	uint256 public redemption_delay = 2;

	uint256 public daoShare = 0;

	DEIPoolLibrary poolLibrary;

	bytes32 private constant MINT_PAUSER = keccak256("MINT_PAUSER");
	bytes32 private constant REDEEM_PAUSER = keccak256("REDEEM_PAUSER");
	bytes32 private constant BUYBACK_PAUSER = keccak256("BUYBACK_PAUSER");
	bytes32 private constant RECOLLATERALIZE_PAUSER = keccak256("RECOLLATERALIZE_PAUSER");
    bytes32 public constant TRUSTY_ROLE = keccak256("TRUSTY_ROLE");
	bytes32 public constant DAO_SHARE_COLLECTOR = keccak256("DAO_SHARE_COLLECTOR");
	bytes32 public constant PARAMETER_SETTER_ROLE = keccak256("PARAMETER_SETTER_ROLE");

	bool public mintPaused = false;
	bool public redeemPaused = false;
	bool public recollateralizePaused = false;
	bool public buyBackPaused = false;


	modifier onlyByTrusty() {
		require(
			hasRole(TRUSTY_ROLE, msg.sender),
			"POOL::you are not trusty"
		);
		_;
	}

	modifier notRedeemPaused() {
		require(redeemPaused == false, "POOL::Redeeming is paused");
		_;
	}

	modifier notMintPaused() {
		require(mintPaused == false, "POOL::Minting is paused");
		_;
	}


	constructor(
		address _dei_contract_address,
		address _deus_contract_address,
		address _collateral_address,
		address _trusty_address,
		address _admin_address,
		uint256 _pool_ceiling,
		address _library
	) {
		require(
			(_dei_contract_address != address(0)) &&
				(_deus_contract_address != address(0)) &&
				(_collateral_address != address(0)) &&
				(_trusty_address != address(0)) &&
				(_admin_address != address(0)) &&
				(_library != address(0)),
			"POOL::Zero address detected"
		);
		poolLibrary = DEIPoolLibrary(_library);
		dei_contract_address = _dei_contract_address;
		deus_contract_address = _deus_contract_address;
		collateral_address = _collateral_address;
		collateral_token = ERC20(_collateral_address);
		pool_ceiling = _pool_ceiling;
		missing_decimals = uint256(18) - collateral_token.decimals();

		_setupRole(DEFAULT_ADMIN_ROLE, _admin_address);
		_setupRole(MINT_PAUSER, _trusty_address);
		_setupRole(REDEEM_PAUSER, _trusty_address);
		_setupRole(RECOLLATERALIZE_PAUSER, _trusty_address);
		_setupRole(BUYBACK_PAUSER, _trusty_address);
        _setupRole(TRUSTY_ROLE, _trusty_address);
        _setupRole(TRUSTY_ROLE, _trusty_address);
        _setupRole(PARAMETER_SETTER_ROLE, _trusty_address);
	}


	function collatDollarBalance(uint256 collat_usd_price) public view returns (uint256) {
		return ((collateral_token.balanceOf(address(this)) - unclaimedPoolCollateral) * (10**missing_decimals) * collat_usd_price) / (PRICE_PRECISION);
	}

	function availableExcessCollatDV(uint256[] memory collat_usd_price) public view returns (uint256) {
		uint256 total_supply = IDEIStablecoin(dei_contract_address).totalSupply();
		uint256 global_collateral_ratio = IDEIStablecoin(dei_contract_address).global_collateral_ratio();
		uint256 global_collat_value = IDEIStablecoin(dei_contract_address).globalCollateralValue(collat_usd_price);

		if (global_collateral_ratio > COLLATERAL_RATIO_PRECISION)
			global_collateral_ratio = COLLATERAL_RATIO_PRECISION; // Handles an overcollateralized contract with CR > 1
		uint256 required_collat_dollar_value_d18 = (total_supply * global_collateral_ratio) / (COLLATERAL_RATIO_PRECISION); // Calculates collateral needed to back each 1 DEI with $1 of collateral at current collat ratio
		if (global_collat_value > required_collat_dollar_value_d18)
			return global_collat_value - required_collat_dollar_value_d18;
		else return 0;
	}

	function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }


	function mint1t1DEI(uint256 collateral_amount, uint256 collateral_price, uint256 expireBlock, bytes[] calldata sigs)
		external
		notMintPaused
		returns (uint256 dei_amount_d18)
	{

		require(
			IDEIStablecoin(dei_contract_address).global_collateral_ratio() >= COLLATERAL_RATIO_MAX,
			"Collateral ratio must be >= 1"
		);
		require(
			collateral_token.balanceOf(address(this)) - unclaimedPoolCollateral +  collateral_amount <= pool_ceiling,
			"[Pool's Closed]: Ceiling reached"
		);

		require(expireBlock >= block.number, "POOL::mint1t1DEI: signature is expired");
        bytes32 sighash = keccak256(abi.encodePacked(collateral_address, collateral_price, expireBlock, getChainID()));
		require(IDEIStablecoin(dei_contract_address).verify_price(sighash, sigs), "POOL::mint1t1DEI: invalid signatures");

		uint256 collateral_amount_d18 = collateral_amount * (10**missing_decimals);
		dei_amount_d18 = poolLibrary.calcMint1t1DEI(
			collateral_price,
			collateral_amount_d18
		); //1 DEI for each $1 worth of collateral

		dei_amount_d18 = (dei_amount_d18 * (uint256(1e6) - minting_fee)) / 1e6; //remove precision at the end

		TransferHelper.safeTransferFrom(
			address(collateral_token),
			msg.sender,
			address(this),
			collateral_amount
		);

		daoShare += dei_amount_d18 *  minting_fee / 1e6;
		IDEIStablecoin(dei_contract_address).pool_mint(msg.sender, dei_amount_d18);
	}

	function mintAlgorithmicDEI(
		uint256 deus_amount_d18,
		uint256 deus_current_price,
		uint256 expireBlock,
		bytes[] calldata sigs
	) external notMintPaused returns (uint256 dei_amount_d18) {
		require(
			IDEIStablecoin(dei_contract_address).global_collateral_ratio() == 0,
			"Collateral ratio must be 0"
		);
		require(expireBlock >= block.number, "POOL::mintAlgorithmicDEI: signature is expired.");
		bytes32 sighash = keccak256(abi.encodePacked(deus_contract_address, deus_current_price, expireBlock, getChainID()));
		require(IDEIStablecoin(dei_contract_address).verify_price(sighash, sigs), "POOL::mintAlgorithmicDEI: invalid signatures");

		dei_amount_d18 = poolLibrary.calcMintAlgorithmicDEI(
			deus_current_price, // X DEUS / 1 USD
			deus_amount_d18
		);

		dei_amount_d18 = (dei_amount_d18 * (uint256(1e6) - (minting_fee))) / (1e6);
		daoShare += dei_amount_d18 *  minting_fee / 1e6;

		IDEUSToken(deus_contract_address).pool_burn_from(msg.sender, deus_amount_d18);
		IDEIStablecoin(dei_contract_address).pool_mint(msg.sender, dei_amount_d18);
	}

	function mintFractionalDEI(
		uint256 collateral_amount,
		uint256 deus_amount,
		uint256 collateral_price,
		uint256 deus_current_price,
		uint256 expireBlock,
		bytes[] calldata sigs
	) external notMintPaused returns (uint256 mint_amount) {
		uint256 global_collateral_ratio = IDEIStablecoin(dei_contract_address).global_collateral_ratio();
		require(
			global_collateral_ratio < COLLATERAL_RATIO_MAX && global_collateral_ratio > 0,
			"Collateral ratio needs to be between .000001 and .999999"
		);
		require(
			collateral_token.balanceOf(address(this)) - unclaimedPoolCollateral + collateral_amount <= pool_ceiling,
			"Pool ceiling reached, no more DEI can be minted with this collateral"
		);

		require(expireBlock >= block.number, "POOL::mintFractionalDEI: signature is expired.");
		bytes32 sighash = keccak256(abi.encodePacked(collateral_address, collateral_price, deus_contract_address, deus_current_price, expireBlock, getChainID()));
		require(IDEIStablecoin(dei_contract_address).verify_price(sighash, sigs), "POOL::mintFractionalDEI: invalid signatures");

		DEIPoolLibrary.MintFD_Params memory input_params;

		{
			uint256 collateral_amount_d18 = collateral_amount * (10**missing_decimals);
			input_params = DEIPoolLibrary.MintFD_Params(
											deus_current_price,
											collateral_price,
											collateral_amount_d18,
											global_collateral_ratio
										);
		}						

		uint256 deus_needed;
		(mint_amount, deus_needed) = poolLibrary.calcMintFractionalDEI(input_params);
		require(deus_needed <= deus_amount, "Not enough DEUS inputted");
		
		mint_amount = (mint_amount * (uint256(1e6) - minting_fee)) / (1e6);

		IDEUSToken(deus_contract_address).pool_burn_from(msg.sender, deus_needed);
		TransferHelper.safeTransferFrom(
			address(collateral_token),
			msg.sender,
			address(this),
			collateral_amount
		);

		daoShare += mint_amount *  minting_fee / 1e6;
		IDEIStablecoin(dei_contract_address).pool_mint(msg.sender, mint_amount);
	}

	function redeem1t1DEI(uint256 DEI_amount, uint256 collateral_price, uint256 expireBlock, bytes[] calldata sigs)
		external
		notRedeemPaused
	{
		require(
			IDEIStablecoin(dei_contract_address).global_collateral_ratio() == COLLATERAL_RATIO_MAX,
			"Collateral ratio must be == 1"
		);

		require(expireBlock >= block.number, "POOL::mintAlgorithmicDEI: signature is expired.");
        bytes32 sighash = keccak256(abi.encodePacked(collateral_address, collateral_price, expireBlock, getChainID()));
		require(IDEIStablecoin(dei_contract_address).verify_price(sighash, sigs), "POOL::redeem1t1DEI: invalid signatures");

		uint256 DEI_amount_precision = DEI_amount / (10**missing_decimals);
		uint256 collateral_needed = poolLibrary.calcRedeem1t1DEI(
			collateral_price,
			DEI_amount_precision
		);

		collateral_needed = (collateral_needed * (uint256(1e6) - redemption_fee)) / (1e6);
		require(
			collateral_needed <= collateral_token.balanceOf(address(this)) - unclaimedPoolCollateral,
			"Not enough collateral in pool"
		);

		redeemCollateralBalances[msg.sender] = redeemCollateralBalances[msg.sender] + collateral_needed;
		unclaimedPoolCollateral = unclaimedPoolCollateral + collateral_needed;
		lastRedeemed[msg.sender] = block.number;

		daoShare += DEI_amount * redemption_fee / 1e6;
		IDEIStablecoin(dei_contract_address).pool_burn_from(msg.sender, DEI_amount);
	}

	function redeemFractionalDEI(
		uint256 DEI_amount,
		uint256 collateral_price, 
		uint256 deus_current_price,
		uint256 expireBlock,
		bytes[] calldata sigs
	) external notRedeemPaused {
		uint256 global_collateral_ratio = IDEIStablecoin(dei_contract_address).global_collateral_ratio();
		require(
			global_collateral_ratio < COLLATERAL_RATIO_MAX && global_collateral_ratio > 0,
			"POOL::redeemFractionalDEI: Collateral ratio needs to be between .000001 and .999999"
		);

		require(expireBlock >= block.number, "DEI::redeemFractionalDEI: signature is expired");
		bytes32 sighash = keccak256(abi.encodePacked(collateral_address, collateral_price, deus_contract_address, deus_current_price, expireBlock, getChainID()));
		require(IDEIStablecoin(dei_contract_address).verify_price(sighash, sigs), "POOL::redeemFractionalDEI: invalid signatures");

		uint256 deus_amount;
		uint256 collateral_amount;
		{
			uint256 col_price_usd = collateral_price;

			uint256 DEI_amount_post_fee = (DEI_amount * (uint256(1e6) - redemption_fee)) / (PRICE_PRECISION);

			uint256 deus_dollar_value_d18 = DEI_amount_post_fee - ((DEI_amount_post_fee * global_collateral_ratio) / (PRICE_PRECISION));
			deus_amount = deus_dollar_value_d18 * (PRICE_PRECISION) / (deus_current_price);

			uint256 DEI_amount_precision = DEI_amount_post_fee / (10**missing_decimals);
			uint256 collateral_dollar_value = (DEI_amount_precision * global_collateral_ratio) / PRICE_PRECISION;
			collateral_amount = (collateral_dollar_value * PRICE_PRECISION) / (col_price_usd);
		}
		require(
			collateral_amount <= collateral_token.balanceOf(address(this)) - unclaimedPoolCollateral,
			"Not enough collateral in pool"
		);

		redeemCollateralBalances[msg.sender] = redeemCollateralBalances[msg.sender] + collateral_amount;
		unclaimedPoolCollateral = unclaimedPoolCollateral + collateral_amount;

		redeemDEUSBalances[msg.sender] = redeemDEUSBalances[msg.sender] + deus_amount;
		unclaimedPoolDEUS = unclaimedPoolDEUS + deus_amount;

		lastRedeemed[msg.sender] = block.number;

		daoShare += DEI_amount * redemption_fee / 1e6;
		IDEIStablecoin(dei_contract_address).pool_burn_from(msg.sender, DEI_amount);
		IDEUSToken(deus_contract_address).pool_mint(address(this), deus_amount);
	}

	function redeemAlgorithmicDEI(
		uint256 DEI_amount,
		uint256 deus_current_price,
		uint256 expireBlock,
		bytes[] calldata sigs
	) external notRedeemPaused {
		require(IDEIStablecoin(dei_contract_address).global_collateral_ratio() == 0, "POOL::redeemAlgorithmicDEI: Collateral ratio must be 0");

		require(expireBlock >= block.number, "DEI::redeemAlgorithmicDEI: signature is expired.");
		bytes32 sighash = keccak256(abi.encodePacked(deus_contract_address, deus_current_price, expireBlock, getChainID()));
		require(IDEIStablecoin(dei_contract_address).verify_price(sighash, sigs), "POOL::redeemAlgorithmicDEI: invalid signatures");

		uint256 deus_dollar_value_d18 = DEI_amount;

		deus_dollar_value_d18 = (deus_dollar_value_d18 * (uint256(1e6) - redemption_fee)) / 1e6; //apply fees

		uint256 deus_amount = (deus_dollar_value_d18 * (PRICE_PRECISION)) / deus_current_price;

		redeemDEUSBalances[msg.sender] = redeemDEUSBalances[msg.sender] + deus_amount;
		unclaimedPoolDEUS = unclaimedPoolDEUS + deus_amount;

		lastRedeemed[msg.sender] = block.number;

		daoShare += DEI_amount * redemption_fee / 1e6;
		IDEIStablecoin(dei_contract_address).pool_burn_from(msg.sender, DEI_amount);
		IDEUSToken(deus_contract_address).pool_mint(address(this), deus_amount);
	}

	function collectRedemption() external {
		require(
			(lastRedeemed[msg.sender] + redemption_delay) <= block.number,
			"POOL::collectRedemption: Must wait for redemption_delay blocks before collecting redemption"
		);
		bool sendDEUS = false;
		bool sendCollateral = false;
		uint256 DEUSAmount = 0;
		uint256 CollateralAmount = 0;

		if (redeemDEUSBalances[msg.sender] > 0) {
			DEUSAmount = redeemDEUSBalances[msg.sender];
			redeemDEUSBalances[msg.sender] = 0;
			unclaimedPoolDEUS = unclaimedPoolDEUS - DEUSAmount;

			sendDEUS = true;
		}

		if (redeemCollateralBalances[msg.sender] > 0) {
			CollateralAmount = redeemCollateralBalances[msg.sender];
			redeemCollateralBalances[msg.sender] = 0;
			unclaimedPoolCollateral = unclaimedPoolCollateral - CollateralAmount;
			sendCollateral = true;
		}

		if (sendDEUS) {
			TransferHelper.safeTransfer(address(deus_contract_address), msg.sender, DEUSAmount);
		}
		if (sendCollateral) {
			TransferHelper.safeTransfer(
				address(collateral_token),
				msg.sender,
				CollateralAmount
			);
		}
	}

	function recollateralizeDEI(RecollateralizeDEI memory inputs) external {
		require(recollateralizePaused == false, "POOL::recollateralizeDEI: Recollateralize is paused");

		require(inputs.expireBlock >= block.number, "POOL::recollateralizeDEI: signature is expired.");
		bytes32 sighash = keccak256(abi.encodePacked(
                                        collateral_address, 
                                        inputs.collateral_price,
                                        deus_contract_address, 
                                        inputs.deus_current_price, 
                                        inputs.expireBlock,
										getChainID()
                                    ));
		require(IDEIStablecoin(dei_contract_address).verify_price(sighash, inputs.sigs), "POOL::recollateralizeDEI: invalid signatures");

		uint256 collateral_amount_d18 = inputs.collateral_amount * (10**missing_decimals);

		uint256 dei_total_supply = IDEIStablecoin(dei_contract_address).totalSupply();
		uint256 global_collateral_ratio = IDEIStablecoin(dei_contract_address).global_collateral_ratio();
		uint256 global_collat_value = IDEIStablecoin(dei_contract_address).globalCollateralValue(inputs.collateral_price);

		(uint256 collateral_units, uint256 amount_to_recollat) = poolLibrary.calcRecollateralizeDEIInner(
																				collateral_amount_d18,
																				inputs.collateral_price[inputs.collateral_price.length - 1], // pool collateral price exist in last index
																				global_collat_value,
																				dei_total_supply,
																				global_collateral_ratio
																			);

		uint256 collateral_units_precision = collateral_units / (10**missing_decimals);

		uint256 deus_paid_back = (amount_to_recollat * (uint256(1e6) + bonus_rate - recollat_fee)) / inputs.deus_current_price;

		TransferHelper.safeTransferFrom(
			address(collateral_token),
			msg.sender,
			address(this),
			collateral_units_precision
		);
		IDEUSToken(deus_contract_address).pool_mint(msg.sender, deus_paid_back);
	}

	function buyBackDEUS(
		uint256 DEUS_amount,
		uint256[] memory collateral_price,
		uint256 deus_current_price,
		uint256 expireBlock,
		bytes[] calldata sigs
	) external {
		require(buyBackPaused == false, "POOL::buyBackDEUS: Buyback is paused");
		require(expireBlock >= block.number, "DEI::buyBackDEUS: signature is expired.");
		bytes32 sighash = keccak256(abi.encodePacked(
										collateral_address,
										collateral_price,
										deus_contract_address,
										deus_current_price,
										expireBlock,
										getChainID()));
		require(IDEIStablecoin(dei_contract_address).verify_price(sighash, sigs), "POOL::buyBackDEUS: invalid signatures");

		DEIPoolLibrary.BuybackDEUS_Params memory input_params = DEIPoolLibrary.BuybackDEUS_Params(
													availableExcessCollatDV(collateral_price),
													deus_current_price,
													collateral_price[collateral_price.length - 1], // pool collateral price exist in last index
													DEUS_amount
												);

		uint256 collateral_equivalent_d18 = (poolLibrary.calcBuyBackDEUS(input_params) * (uint256(1e6) - buyback_fee)) / (1e6);
		uint256 collateral_precision = collateral_equivalent_d18 / (10**missing_decimals);

		IDEUSToken(deus_contract_address).pool_burn_from(msg.sender, DEUS_amount);
		TransferHelper.safeTransfer(
			address(collateral_token),
			msg.sender,
			collateral_precision
		);
	}


	function collectDaoShare(uint256 amount, address to) external {
		require(hasRole(DAO_SHARE_COLLECTOR, msg.sender));
		require(amount <= daoShare, "amount<=daoShare");
		IDEIStablecoin(dei_contract_address).pool_mint(to, amount);
		daoShare -= amount;

		emit daoShareCollected(amount, to);
	}

	function emergencyWithdrawERC20(address token, uint amount, address to) external onlyByTrusty {
		IERC20(token).transfer(to, amount);
	}

	function toggleMinting() external {
		require(hasRole(MINT_PAUSER, msg.sender));
		mintPaused = !mintPaused;

		emit MintingToggled(mintPaused);
	}

	function toggleRedeeming() external {
		require(hasRole(REDEEM_PAUSER, msg.sender));
		redeemPaused = !redeemPaused;

		emit RedeemingToggled(redeemPaused);
	}

	function toggleRecollateralize() external {
		require(hasRole(RECOLLATERALIZE_PAUSER, msg.sender));
		recollateralizePaused = !recollateralizePaused;

		emit RecollateralizeToggled(recollateralizePaused);
	}

	function toggleBuyBack() external {
		require(hasRole(BUYBACK_PAUSER, msg.sender));
		buyBackPaused = !buyBackPaused;

		emit BuybackToggled(buyBackPaused);
	}

	function setPoolParameters(
		uint256 new_ceiling,
		uint256 new_bonus_rate,
		uint256 new_redemption_delay,
		uint256 new_mint_fee,
		uint256 new_redeem_fee,
		uint256 new_buyback_fee,
		uint256 new_recollat_fee
	) external {
		require(hasRole(PARAMETER_SETTER_ROLE, msg.sender), "POOL: Caller is not PARAMETER_SETTER_ROLE");
		pool_ceiling = new_ceiling;
		bonus_rate = new_bonus_rate;
		redemption_delay = new_redemption_delay;
		minting_fee = new_mint_fee;
		redemption_fee = new_redeem_fee;
		buyback_fee = new_buyback_fee;
		recollat_fee = new_recollat_fee;

		emit PoolParametersSet(
			new_ceiling,
			new_bonus_rate,
			new_redemption_delay,
			new_mint_fee,
			new_redeem_fee,
			new_buyback_fee,
			new_recollat_fee
		);
	}


	event PoolParametersSet(
		uint256 new_ceiling,
		uint256 new_bonus_rate,
		uint256 new_redemption_delay,
		uint256 new_mint_fee,
		uint256 new_redeem_fee,
		uint256 new_buyback_fee,
		uint256 new_recollat_fee
	);
	event daoShareCollected(uint256 daoShare, address to);
	event MintingToggled(bool toggled);
	event RedeemingToggled(bool toggled);
	event RecollateralizeToggled(bool toggled);
	event BuybackToggled(bool toggled);
}


pragma solidity >=0.6.11;


contract Pool_USDC is DEIPool {
    address public USDC_address;
    constructor(
        address _dei_contract_address,
        address _deus_contract_address,
        address _collateral_address,
        address _trusty_address,
        address _admin_address,
        uint256 _pool_ceiling,
        address _library
    ) 
    DEIPool(_dei_contract_address, _deus_contract_address, _collateral_address, _trusty_address, _admin_address, _pool_ceiling, _library)
    public {
        require(_collateral_address != address(0), "Zero address detected");

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        USDC_address = _collateral_address;
    }
}

