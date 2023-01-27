
pragma solidity >=0.8.0;




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




interface IFraxAMOMinter {

  function FRAX() external view returns(address);

  function FXS() external view returns(address);

  function acceptOwnership() external;

  function addAMO(address amo_address, bool sync_too) external;

  function allAMOAddresses() external view returns(address[] memory);

  function allAMOsLength() external view returns(uint256);

  function amos(address) external view returns(bool);

  function amos_array(uint256) external view returns(address);

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

  function correction_offsets_amos(address, uint256) external view returns(int256);

  function custodian_address() external view returns(address);

  function dollarBalances() external view returns(uint256 frax_val_e18, uint256 collat_val_e18);

  function fraxDollarBalanceStored() external view returns(uint256);

  function fraxTrackedAMO(address amo_address) external view returns(int256);

  function fraxTrackedGlobal() external view returns(int256);

  function frax_mint_balances(address) external view returns(int256);

  function frax_mint_cap() external view returns(int256);

  function frax_mint_sum() external view returns(int256);

  function fxs_mint_balances(address) external view returns(int256);

  function fxs_mint_cap() external view returns(int256);

  function fxs_mint_sum() external view returns(int256);

  function giveCollatToAMO(address destination_amo, uint256 collat_amount) external;

  function min_cr() external view returns(uint256);

  function mintFraxForAMO(address destination_amo, uint256 frax_amount) external;

  function mintFxsForAMO(address destination_amo, uint256 fxs_amount) external;

  function missing_decimals() external view returns(uint256);

  function nominateNewOwner(address _owner) external;

  function nominatedOwner() external view returns(address);

  function oldPoolCollectAndGive(address destination_amo) external;

  function oldPoolRedeem(uint256 frax_amount) external;

  function old_pool() external view returns(address);

  function owner() external view returns(address);

  function pool() external view returns(address);

  function receiveCollatFromAMO(uint256 usdc_amount) external;

  function recoverERC20(address tokenAddress, uint256 tokenAmount) external;

  function removeAMO(address amo_address, bool sync_too) external;

  function setAMOCorrectionOffsets(address amo_address, int256 frax_e18_correction, int256 collat_e18_correction) external;

  function setCollatBorrowCap(uint256 _collat_borrow_cap) external;

  function setCustodian(address _custodian_address) external;

  function setFraxMintCap(uint256 _frax_mint_cap) external;

  function setFraxPool(address _pool_address) external;

  function setFxsMintCap(uint256 _fxs_mint_cap) external;

  function setMinimumCollateralRatio(uint256 _min_cr) external;

  function setTimelock(address new_timelock) external;

  function syncDollarBalances() external;

  function timelock_address() external view returns(address);

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















contract FraxLiquidityBridger is Owned {
    using SafeERC20 for ERC20;


    IFrax public FRAX = IFrax(0x853d955aCEf822Db058eb8505911ED77F175b99e);
    IFxs public FXS = IFxs(0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0);
    ERC20 public collateral_token;
    IFraxAMOMinter public amo_minter;
    
    string public name;

    uint256 private constant PRICE_PRECISION = 1e6;

    address private amo_minter_address;

    address public collateral_address;
    uint256 public col_idx;

    address public timelock_address;

    address[3] public bridge_addresses;
    address public destination_address_override;
    string public non_evm_destination_address;

    uint256 public frax_bridged;
    uint256 public fxs_bridged;
    uint256 public collat_bridged;

    uint256 public missing_decimals;


    modifier onlyByOwnGov() {
        require(msg.sender == owner || msg.sender == timelock_address, "Not owner or timelock");
        _;
    }


    constructor (
        address _owner,
        address _timelock_address,
        address _amo_minter_address,
        address[3] memory _bridge_addresses,
        address _destination_address_override,
        string memory _non_evm_destination_address,
        string memory _name
    ) Owned(_owner) {
        timelock_address = _timelock_address;

        bridge_addresses = _bridge_addresses;
        destination_address_override = _destination_address_override;
        non_evm_destination_address = _non_evm_destination_address;

        name = _name;

        amo_minter_address = _amo_minter_address;
        amo_minter = IFraxAMOMinter(_amo_minter_address);

        collateral_address = amo_minter.collateral_address();
        col_idx = amo_minter.col_idx();
        collateral_token = ERC20(collateral_address);
        missing_decimals = amo_minter.missing_decimals();
    }


    function getTokenType(address token_address) public view returns (uint256) {
        if (token_address == address(FRAX)) return 0;
        else if (token_address == address(FXS)) return 1;
        else if (token_address == address(collateral_token)) return 2;

        revert("getTokenType: Invalid token");
    }

    function showTokenBalances() public view returns (uint256[3] memory tkn_bals) {
        tkn_bals[0] = FRAX.balanceOf(address(this)); // FRAX
        tkn_bals[1] = FXS.balanceOf(address(this)); // FXS
        tkn_bals[2] = collateral_token.balanceOf(address(this)); // Collateral
    }

    function showAllocations() public view returns (uint256[10] memory allocations) {

        uint256[3] memory tkn_bals = showTokenBalances();

        allocations[0] = tkn_bals[0]; // Unbridged FRAX
        allocations[1] = frax_bridged; // Bridged FRAX
        allocations[2] = allocations[0] + allocations[1]; // Total FRAX

        allocations[3] = tkn_bals[1]; // Unbridged FXS
        allocations[4] = fxs_bridged; // Bridged FXS
        allocations[5] = allocations[3] + allocations[4]; // Total FXS

        allocations[6] = tkn_bals[2] * (10 ** missing_decimals); // Unbridged Collateral, in E18
        allocations[7] = collat_bridged * (10 ** missing_decimals); // Bridged Collateral, in E18
        allocations[8] = allocations[6] + allocations[7]; // Total Collateral, in E18
    
        allocations[9] = allocations[2] + allocations[8];
    }

    function collatDollarBalance() public view returns (uint256) {
        (, uint256 col_bal) = dollarBalances();
        return col_bal;
    }

    function dollarBalances() public view returns (uint256 frax_val_e18, uint256 collat_val_e18) {
        uint256[10] memory allocations = showAllocations();

        uint256 frax_portion_with_cr = (allocations[2] * FRAX.global_collateral_ratio()) / PRICE_PRECISION;

        uint256 collat_portion = allocations[8];

        frax_val_e18 = allocations[2] + allocations[8];

        collat_val_e18 = collat_portion + frax_portion_with_cr;
    }


    function bridge(address token_address, uint256 token_amount) external onlyByOwnGov {
        uint256 token_type = getTokenType(token_address); 

        address address_to_send_to = address(this);

        if (destination_address_override != address(0)) address_to_send_to = destination_address_override;

        _bridgingLogic(token_type, address_to_send_to, token_amount);
        
        if (token_type == 0){
            frax_bridged += token_amount;
        }
        else if (token_type == 1){
            fxs_bridged += token_amount;
        }
        else {
            collat_bridged += token_amount;
        }
    }

    function _bridgingLogic(uint256 token_type, address address_to_send_to, uint256 token_amount) internal virtual {
        revert("Need bridging logic");
    }

    function burnFRAX(uint256 frax_amount) public onlyByOwnGov {
        FRAX.approve(amo_minter_address, frax_amount);
        amo_minter.burnFraxFromAMO(frax_amount);

        if (frax_amount >= frax_bridged) frax_bridged = 0;
        else {
            frax_bridged -= frax_amount;
        }
    }

    function burnFXS(uint256 fxs_amount) public onlyByOwnGov {
        FXS.approve(amo_minter_address, fxs_amount);
        amo_minter.burnFxsFromAMO(fxs_amount);

        if (fxs_amount >= fxs_bridged) fxs_bridged = 0;
        else {
            fxs_bridged -= fxs_amount;
        }
    }

    function giveCollatBack(uint256 collat_amount) external onlyByOwnGov {
        collateral_token.approve(amo_minter_address, collat_amount);
        amo_minter.receiveCollatFromAMO(collat_amount);

        if (collat_amount >= collat_bridged) collat_bridged = 0;
        else {
            collat_bridged -= collat_amount;
        }
    }

    
    function setTimelock(address _new_timelock) external onlyByOwnGov {
        timelock_address = _new_timelock;
    }

    function setBridgeInfo(
        address _frax_bridge_address, 
        address _fxs_bridge_address, 
        address _collateral_bridge_address, 
        address _destination_address_override, 
        string memory _non_evm_destination_address
    ) external onlyByOwnGov {
        require(
            _frax_bridge_address != address(0) && 
            _fxs_bridge_address != address(0) &&
            _collateral_bridge_address != address(0)
        , "Invalid bridge address");

        bridge_addresses = [_frax_bridge_address, _fxs_bridge_address, _collateral_bridge_address];
        
        destination_address_override = _destination_address_override;

        non_evm_destination_address = _non_evm_destination_address;
        
        emit BridgeInfoChanged(_frax_bridge_address, _fxs_bridge_address, _collateral_bridge_address, _destination_address_override, _non_evm_destination_address);
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyByOwnGov {
        TransferHelper.safeTransfer(tokenAddress, owner, tokenAmount);
        emit RecoveredERC20(tokenAddress, tokenAmount);
    }

    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyByOwnGov returns (bool, bytes memory) {
        (bool success, bytes memory result) = _to.call{value:_value}(_data);
        return (success, result);
    }


    event RecoveredERC20(address token, uint256 amount);
    event BridgeInfoChanged(address frax_bridge_address, address fxs_bridge_address, address collateral_bridge_address, address destination_address_override, string non_evm_destination_address);
}




interface IERC20Locker {
  function admin() external view returns (address);
  function adminDelegatecall(address target, bytes memory data) external returns (bytes memory);
  function adminPause(uint256 flags) external;
  function adminReceiveEth() external;
  function adminSendEth(address destination, uint256 amount) external;
  function adminSstore(uint256 key, uint256 value) external;
  function adminTransfer(address token, address destination, uint256 amount) external;
  function lockToken(address ethToken, uint256 amount, string memory accountId) external;
  function minBlockAcceptanceHeight_() external view returns (uint64);
  function nearTokenFactory_() external view returns (bytes memory);
  function paused() external view returns (uint256);
  function prover_() external view returns (address);
  function tokenFallback(address _from, uint256 _value, bytes memory _data) external pure;
  function unlockToken(bytes memory proofData, uint64 proofBlockHeight) external;
  function usedProofs_(bytes32) external view returns (bool);
}





contract FraxLiquidityBridger_AUR_Rainbow is FraxLiquidityBridger {

    string public accountID = "";

    constructor (
        address _owner,
        address _timelock_address,
        address _amo_minter_address,
        address[3] memory _bridge_addresses,
        address _destination_address_override,
        string memory _non_evm_destination_address,
        string memory _name
    ) 
    FraxLiquidityBridger(_owner, _timelock_address, _amo_minter_address, _bridge_addresses, _destination_address_override, _non_evm_destination_address, _name)
    {}

    function setAccountID(string memory _accountID, bool override_tolower) external onlyByOwnGov {
        if (override_tolower){
            accountID = _accountID;
        }
        else {
            accountID = _toLower(_accountID);
        }
    }

    function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }


    function _bridgingLogic(uint256 token_type, address address_to_send_to, uint256 token_amount) internal override {
        require(bytes(accountID).length > 0, "Need to set accountID");

        if (token_type == 0){

            ERC20(address(FRAX)).approve(bridge_addresses[token_type], token_amount);

            IERC20Locker(bridge_addresses[token_type]).lockToken(address(FRAX), token_amount, accountID);
        }
        else if (token_type == 1) {

            ERC20(address(FXS)).approve(bridge_addresses[token_type], token_amount);

            IERC20Locker(bridge_addresses[token_type]).lockToken(address(FXS), token_amount, accountID);
        }
        else {

            ERC20(collateral_address).approve(bridge_addresses[token_type], token_amount);

            IERC20Locker(bridge_addresses[token_type]).lockToken(collateral_address, token_amount, accountID);
        }
    }

}