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




contract ERC20Custom is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 private _totalSupply;

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
}// GPL-2.0-or-later
pragma solidity >=0.6.11;

contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
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
}// MIT
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


pragma solidity ^0.8.0;

library ECDSA {
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// Be name Khoda

pragma solidity >=0.6.12;


contract Oracle is AccessControl {
	using ECDSA for bytes32;

	bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");
	bytes32 public constant TRUSTY_ROLE = keccak256("TRUSTY_ROLE");

	uint256 minimumRequiredSignature;

	event MinimumRequiredSignatureSet(uint256 minimumRequiredSignature);

	constructor(address _admin, uint256 _minimumRequiredSignature, address _trusty_address) {
		require(_admin != address(0), "ORACLE::constructor: Zero address detected");
		_setupRole(DEFAULT_ADMIN_ROLE, _admin);
		_setupRole(TRUSTY_ROLE, _trusty_address);
		minimumRequiredSignature = _minimumRequiredSignature;
	}

	function verify(bytes32 hash, bytes[] calldata sigs)
		public
		view
		returns (bool)
	{
		address lastOracle;
		for (uint256 index = 0; index < minimumRequiredSignature; ++index) {
			address oracle = hash.recover(sigs[index]);
			require(hasRole(ORACLE_ROLE, oracle), "ORACLE::verify: Signer is not valid");
			require(oracle > lastOracle, "ORACLE::verify: Signers are same");
			lastOracle = oracle;
		}
		return true;
	}

	function setMinimumRequiredSignature(uint256 _minimumRequiredSignature)
		public
	{
		require(
			hasRole(TRUSTY_ROLE, msg.sender),
			"ORACLE::setMinimumRequiredSignature: You are not a setter"
		);
		minimumRequiredSignature = _minimumRequiredSignature;

		emit MinimumRequiredSignatureSet(_minimumRequiredSignature);
	}
}

pragma solidity >=0.6.11;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
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
}// MIT
pragma solidity >=0.6.11;

interface IUniswapV2Pair {
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












    
}// Be name Khoda

pragma solidity ^0.8.7;





contract ReserveTracker is AccessControl {

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

	uint256 private PRICE_PRECISION = 1e6;

	address private dei_contract_address;
	address private deus_contract_address;

	address[] public deus_pairs_array;

	mapping(address => bool) public deus_pairs;

	uint256 public deus_reserves;


	modifier onlyByOwnerOrGovernance() {
		require(hasRole(OWNER_ROLE, msg.sender), "Caller is not owner");
		_;
	}


	constructor(
		address _dei_contract_address,
		address _deus_contract_address
	) {
		dei_contract_address = _dei_contract_address;
		deus_contract_address = _deus_contract_address;
		_setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
		_setupRole(OWNER_ROLE, msg.sender);
	}


	function getDEUSReserves() public view returns (uint256) {
		uint256 total_deus_reserves = 0;

		for (uint i = 0; i < deus_pairs_array.length; i++){ 
			if (deus_pairs_array[i] != address(0)){
				if(IUniswapV2Pair(deus_pairs_array[i]).token0() == deus_contract_address) {
					(uint reserves0, , ) = IUniswapV2Pair(deus_pairs_array[i]).getReserves();
					total_deus_reserves = total_deus_reserves + reserves0;
				} else if (IUniswapV2Pair(deus_pairs_array[i]).token1() == deus_contract_address) {
					( , uint reserves1, ) = IUniswapV2Pair(deus_pairs_array[i]).getReserves();
					total_deus_reserves = total_deus_reserves + reserves1;
				}
			}
		}

		return total_deus_reserves;
	}

	function addDEUSPair(address pair_address) public onlyByOwnerOrGovernance {
		require(deus_pairs[pair_address] == false, "Address already exists");
		deus_pairs[pair_address] = true; 
		deus_pairs_array.push(pair_address);
	}

	function removeDEUSPair(address pair_address) public onlyByOwnerOrGovernance {
		require(deus_pairs[pair_address] == true, "Address nonexistant");
		
		delete deus_pairs[pair_address];

		for (uint i = 0; i < deus_pairs_array.length; i++){ 
			if (deus_pairs_array[i] == pair_address) {
				deus_pairs_array[i] = address(0); // This will leave a null in the array and keep the indices the same
				break;
			}
		}
	}
}


pragma solidity ^0.8.0;





contract DEIStablecoin is ERC20Custom, AccessControl {
	using ECDSA for bytes32;

	enum PriceChoice {
		DEI,
		DEUS
	}
	address public oracle;
	string public symbol;
	string public name;
	uint8 public constant decimals = 18;
	address public creator_address;
	address public deus_address;
	uint256 public constant genesis_supply = 10000e18; // genesis supply is 10k on Mainnet. This is to help with establishing the Uniswap pools, as they need liquidity
	address public reserve_tracker_address;

	address[] public dei_pools_array;

	mapping(address => bool) public dei_pools;

	uint256 private constant PRICE_PRECISION = 1e6;

	uint256 public global_collateral_ratio; // 6 decimals of precision, e.g. 924102 = 0.924102
	uint256 public dei_step; // Amount to change the collateralization ratio by upon refreshCollateralRatio()
	uint256 public refresh_cooldown; // Seconds to wait before being able to run refreshCollateralRatio() again
	uint256 public price_band; // The bound above and below the price target at which the refreshCollateralRatio() will not change the collateral ratio

	bytes32 public constant COLLATERAL_RATIO_PAUSER = keccak256("COLLATERAL_RATIO_PAUSER");
	bytes32 public constant TRUSTY_ROLE = keccak256("TRUSTY_ROLE");
	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
	bool public collateral_ratio_paused = false;


	uint256 public growth_ratio;
	uint256 public GR_top_band;
	uint256 public GR_bottom_band;

	uint256 public DEI_top_band;
	uint256 public DEI_bottom_band;

	bool public use_growth_ratio;
	bool public FIP_6;



	modifier onlyCollateralRatioPauser() {
		require(hasRole(COLLATERAL_RATIO_PAUSER, msg.sender), "DEI: you are not the collateral ratio pauser");
		_;
	}

	modifier onlyPoolsOrMinters() {
		require(
			dei_pools[msg.sender] == true ||
			hasRole(MINTER_ROLE, msg.sender),
			"DEI: you are not minter"
		);
		_;
	}

	modifier onlyPools() {
		require(
			dei_pools[msg.sender] == true,
			"DEI: only dei pools can call this function"
		);
		_;
	}

	modifier onlyByTrusty() {
		require(
			hasRole(TRUSTY_ROLE, msg.sender),
			"DEI: you are not the owner"
		);
		_;
	}


	constructor(
		string memory _name,
		string memory _symbol,
		address _creator_address,
		address _trusty_address
	){
		require(
			_creator_address != address(0),
			"DEI: zero address detected."
		);
		name = _name;
		symbol = _symbol;
		creator_address = _creator_address;
		_setupRole(DEFAULT_ADMIN_ROLE, _trusty_address);
		_mint(creator_address, genesis_supply);
		_setupRole(COLLATERAL_RATIO_PAUSER, creator_address);
		dei_step = 2500; // 6 decimals of precision, equal to 0.25%
		global_collateral_ratio = 800000; // Dei system starts off fully collateralized (6 decimals of precision)
		refresh_cooldown = 300; // Refresh cooldown period is set to 5 minutes (300 seconds) at genesis
		price_band = 5000; // Collateral ratio will not adjust if between $0.995 and $1.005 at genesis
		_setupRole(TRUSTY_ROLE, _trusty_address);

		GR_top_band = 1000;
		GR_bottom_band = 1000; 
	}


	function verify_price(bytes32 sighash, bytes[] calldata sigs)
		public
		view
		returns (bool)
	{
		return Oracle(oracle).verify(sighash.toEthSignedMessageHash(), sigs);
	}

	function dei_info(uint256[] memory collat_usd_price)
		public
		view
		returns (
			uint256,
			uint256,
			uint256
		)
	{
		return (
			totalSupply(), // totalSupply()
			global_collateral_ratio, // global_collateral_ratio()
			globalCollateralValue(collat_usd_price) // globalCollateralValue
		);
	}

	function globalCollateralValue(uint256[] memory collat_usd_price) public view returns (uint256) {
		uint256 total_collateral_value_d18 = 0;

		for (uint256 i = 0; i < dei_pools_array.length; i++) {
			if (dei_pools_array[i] != address(0)) {
				total_collateral_value_d18 = total_collateral_value_d18 + DEIPool(dei_pools_array[i]).collatDollarBalance(collat_usd_price[i]);
			}
		}
		return total_collateral_value_d18;
	}

	function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }


	uint256 public last_call_time; // Last time the refreshCollateralRatio function was called

	function refreshCollateralRatio(uint deus_price, uint dei_price, uint256 expire_block, bytes[] calldata sigs) external {
		require(collateral_ratio_paused == false, "DEI::Collateral Ratio has been paused");
		uint256 time_elapsed = (block.timestamp) - last_call_time;
		require(time_elapsed >= refresh_cooldown, "DEI::Internal cooldown not passed");
		uint256 deus_reserves = ReserveTracker(reserve_tracker_address).getDEUSReserves();

		bytes32 sighash = keccak256(abi.encodePacked(
										deus_address,
										deus_price,
										address(this),
										dei_price,
										expire_block,
                                    	getChainID()
                                    ));

		verify_price(sighash, sigs);

		uint256 deus_liquidity = deus_reserves * deus_price; // Has 6 decimals of precision

		uint256 dei_supply = totalSupply();

		uint256 new_growth_ratio = deus_liquidity / dei_supply; // (E18 + E6) / E18

		if(FIP_6){
			require(dei_price > DEI_top_band || dei_price < DEI_bottom_band, "DEI::Use refreshCollateralRatio when DEI is outside of peg");
		}

		if(dei_price > DEI_top_band){
			global_collateral_ratio = global_collateral_ratio - dei_step;
		} else if (dei_price < DEI_bottom_band){
			global_collateral_ratio = global_collateral_ratio + dei_step;

		} else if(use_growth_ratio){
			if(new_growth_ratio > growth_ratio * (1e6 + GR_top_band) / 1e6){
				global_collateral_ratio = global_collateral_ratio - dei_step;
			} else if (new_growth_ratio < growth_ratio * (1e6 - GR_bottom_band) / 1e6){
				global_collateral_ratio = global_collateral_ratio + dei_step;
			}
		}

		growth_ratio = new_growth_ratio;
		last_call_time = block.timestamp;

		if(global_collateral_ratio > 1e6){
			global_collateral_ratio = 1e6;
		}

		emit CollateralRatioRefreshed(global_collateral_ratio);

	}

	function useGrowthRatio(bool _use_growth_ratio) external onlyByTrusty {
		use_growth_ratio = _use_growth_ratio;

		emit UseGrowthRatioSet(_use_growth_ratio);
	}

	function setGrowthRatioBands(uint256 _GR_top_band, uint256 _GR_bottom_band) external onlyByTrusty {
		GR_top_band = _GR_top_band;
		GR_bottom_band = _GR_bottom_band;
		emit GrowthRatioBandSet( _GR_top_band, _GR_bottom_band);
	}

	function setPriceBands(uint256 _top_band, uint256 _bottom_band) external onlyByTrusty {
		DEI_top_band = _top_band;
		DEI_bottom_band = _bottom_band;

		emit PriceBandSet(_top_band, _bottom_band);
	}

	function activateFIP6(bool _activate) external onlyByTrusty {
		FIP_6 = _activate;

		emit FIP_6Set(_activate);
	}

	function pool_burn_from(address b_address, uint256 b_amount)
		public
		onlyPools
	{
		super._burnFrom(b_address, b_amount);
		emit DEIBurned(b_address, msg.sender, b_amount);
	}

	function pool_mint(address m_address, uint256 m_amount) public onlyPoolsOrMinters {
		super._mint(m_address, m_amount);
		emit DEIMinted(msg.sender, m_address, m_amount);
	}

	function addPool(address pool_address)
		public
		onlyByTrusty
	{
		require(pool_address != address(0), "DEI::addPool: Zero address detected");
		require(dei_pools[pool_address] == false, "DEI::addPool: Address already exists");

		dei_pools[pool_address] = true;
		dei_pools_array.push(pool_address);

		emit PoolAdded(pool_address);
	}

	function removePool(address pool_address)
		public
		onlyByTrusty
	{
		require(pool_address != address(0), "DEI::removePool: Zero address detected");

		require(dei_pools[pool_address] == true, "DEI::removePool: Address nonexistant");

		delete dei_pools[pool_address];

		for (uint256 i = 0; i < dei_pools_array.length; i++) {
			if (dei_pools_array[i] == pool_address) {
				dei_pools_array[i] = address(0); // This will leave a null in the array and keep the indices the same
				break;
			}
		}

		emit PoolRemoved(pool_address);
	}
	
	function setOracle(address _oracle)
		public
		onlyByTrusty
	{
		oracle = _oracle;

		emit OracleSet(_oracle);
	}

	function setDEIStep(uint256 _new_step)
		public
		onlyByTrusty
	{
		dei_step = _new_step;

		emit DEIStepSet(_new_step);
	}

	function setReserveTracker(address _reserve_tracker_address)
		external
		onlyByTrusty
	{		
		reserve_tracker_address = _reserve_tracker_address;

		emit ReserveTrackerSet(_reserve_tracker_address);
	}

	function setRefreshCooldown(uint256 _new_cooldown)
		public
		onlyByTrusty
	{
		refresh_cooldown = _new_cooldown;

		emit RefreshCooldownSet(_new_cooldown);
	}

	function setDEUSAddress(address _deus_address)
		public
		onlyByTrusty
	{
		require(_deus_address != address(0), "DEI::setDEUSAddress: Zero address detected");

		deus_address = _deus_address;

		emit DEUSAddressSet(_deus_address);
	}

	function toggleCollateralRatio()
		public
		onlyCollateralRatioPauser 
	{
		collateral_ratio_paused = !collateral_ratio_paused;

		emit CollateralRatioToggled(collateral_ratio_paused);
	}


	event DEIBurned(address indexed from, address indexed to, uint256 amount);
	event DEIMinted(address indexed from, address indexed to, uint256 amount);
	event CollateralRatioRefreshed(uint256 global_collateral_ratio);
	event PoolAdded(address pool_address);
	event PoolRemoved(address pool_address);
	event DEIStepSet(uint256 new_step);
	event RefreshCooldownSet(uint256 new_cooldown);
	event DEUSAddressSet(address deus_address);
	event PriceBandSet(uint256 top_band, uint256 bottom_band);
	event CollateralRatioToggled(bool collateral_ratio_paused);
	event OracleSet(address oracle);
	event ReserveTrackerSet(address reserve_tracker_address);
	event UseGrowthRatioSet( bool use_growth_ratio);
	event FIP_6Set(bool activate);
	event GrowthRatioBandSet(uint256 GR_top_band, uint256 GR_bottom_band);
}


pragma solidity ^0.8.0;





contract DEUSToken is ERC20Custom, AccessControl {


    string public symbol;
    string public name;
    uint8 public constant decimals = 18;

    uint256 public constant genesis_supply = 166670e18; // 166670 is printed upon genesis

    DEIStablecoin private DEI;

    bool public trackingVotes = true; // Tracking votes (only change if need to disable votes)

    struct Checkpoint {
        uint32 fromBlock;
        uint96 votes;
    }

    mapping(address => mapping(uint32 => Checkpoint)) public checkpoints;

    mapping(address => uint32) public numCheckpoints;

    bytes32 public constant TRUSTY_ROLE = keccak256("TRUSTY_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");


    modifier onlyPoolsOrMinters() {
        require(
            DEI.dei_pools(msg.sender) == true || hasRole(MINTER_ROLE, msg.sender),
            "DEUS: Only dei pools or minters are allowed to do this operation"
        );
        _;
    }

    modifier onlyPools() {
        require(
            DEI.dei_pools(msg.sender) == true,
            "DEUS: Only dei pools are allowed to do this operation"
        );
        _;
    }

    modifier onlyByTrusty() {
        require(hasRole(TRUSTY_ROLE, msg.sender), "DEUS: You are not trusty");
        _;
    }


    constructor(
        string memory _name,
        string memory _symbol,
        address _creator_address,
        address _trusty_address
    ) {
        require(_creator_address != address(0), "DEUS::constructor: zero address detected");  
        name = _name;
        symbol = _symbol;
        _setupRole(DEFAULT_ADMIN_ROLE, _trusty_address);
        _setupRole(TRUSTY_ROLE, _trusty_address);
        _mint(_creator_address, genesis_supply);

        _writeCheckpoint(_creator_address, 0, 0, uint96(genesis_supply));
    }


    function setDEIAddress(address dei_contract_address)
        external
        onlyByTrusty
    {
        require(dei_contract_address != address(0), "DEUS::setDEIAddress: Zero address detected");

        DEI = DEIStablecoin(dei_contract_address);

        emit DEIAddressSet(dei_contract_address);
    }

    function mint(address to, uint256 amount) public onlyPoolsOrMinters {
        _mint(to, amount);
    }

    function pool_mint(address m_address, uint256 m_amount) external onlyPoolsOrMinters {
        if (trackingVotes) {
            uint32 srcRepNum = numCheckpoints[address(this)];
            uint96 srcRepOld = srcRepNum > 0
                ? checkpoints[address(this)][srcRepNum - 1].votes
                : 0;
            uint96 srcRepNew = add96(
                srcRepOld,
                uint96(m_amount),
                "DEUS::pool_mint: new votes overflows"
            );
            _writeCheckpoint(address(this), srcRepNum, srcRepOld, srcRepNew); // mint new votes
            trackVotes(address(this), m_address, uint96(m_amount));
        }

        super._mint(m_address, m_amount);
        emit DEUSMinted(address(this), m_address, m_amount);
    }

    function pool_burn_from(address b_address, uint256 b_amount)
        external
        onlyPools
    {
        if (trackingVotes) {
            trackVotes(b_address, address(this), uint96(b_amount));
            uint32 srcRepNum = numCheckpoints[address(this)];
            uint96 srcRepOld = srcRepNum > 0
                ? checkpoints[address(this)][srcRepNum - 1].votes
                : 0;
            uint96 srcRepNew = sub96(
                srcRepOld,
                uint96(b_amount),
                "DEUS::pool_burn_from: new votes underflows"
            );
            _writeCheckpoint(address(this), srcRepNum, srcRepOld, srcRepNew); // burn votes
        }

        super._burnFrom(b_address, b_amount);
        emit DEUSBurned(b_address, address(this), b_amount);
    }

    function toggleVotes() external onlyByTrusty {
        trackingVotes = !trackingVotes;
    }


    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        if (trackingVotes) {
            trackVotes(_msgSender(), recipient, uint96(amount));
        }

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        if (trackingVotes) {
            trackVotes(sender, recipient, uint96(amount));
        }

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()] - amount
        );

        return true;
    }


    function getCurrentVotes(address account) external view returns (uint96) {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint256 blockNumber)
        public
        view
        returns (uint96)
    {
        require(
            blockNumber < block.number,
            "DEUS::getPriorVotes: not yet determined"
        );

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }


    function trackVotes(
        address srcRep,
        address dstRep,
        uint96 amount
    ) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint96 srcRepOld = srcRepNum > 0
                    ? checkpoints[srcRep][srcRepNum - 1].votes
                    : 0;
                uint96 srcRepNew = sub96(
                    srcRepOld,
                    amount,
                    "DEUS::_moveVotes: vote amount underflows"
                );
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint96 dstRepOld = dstRepNum > 0
                    ? checkpoints[dstRep][dstRepNum - 1].votes
                    : 0;
                uint96 dstRepNew = add96(
                    dstRepOld,
                    amount,
                    "DEUS::_moveVotes: vote amount overflows"
                );
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address voter,
        uint32 nCheckpoints,
        uint96 oldVotes,
        uint96 newVotes
    ) internal {
        uint32 blockNumber = safe32(
            block.number,
            "DEUS::_writeCheckpoint: block number exceeds 32 bits"
        );

        if (
            nCheckpoints > 0 &&
            checkpoints[voter][nCheckpoints - 1].fromBlock == blockNumber
        ) {
            checkpoints[voter][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[voter][nCheckpoints] = Checkpoint(
                blockNumber,
                newVotes
            );
            numCheckpoints[voter] = nCheckpoints + 1;
        }

        emit VoterVotesChanged(voter, oldVotes, newVotes);
    }

    function safe32(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint32)
    {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage)
        internal
        pure
        returns (uint96)
    {
        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {
        require(b <= a, errorMessage);
        return a - b;
    }


    event VoterVotesChanged(
        address indexed voter,
        uint256 previousBalance,
        uint256 newBalance
    );
    event DEUSBurned(address indexed from, address indexed to, uint256 amount);
    event DEUSMinted(address indexed from, address indexed to, uint256 amount);
    event DEIAddressSet(address addr);
}

