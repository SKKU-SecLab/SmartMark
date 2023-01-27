
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













contract TokenTrackerAMO is Owned {
    using SafeMath for uint256;


    IFraxAMOMinter private amo_minter;
    AggregatorV3Interface private priceFeedETHUSD;

    address[] public tracked_addresses;
    mapping(address => bool) public is_address_tracked; // tracked address => is tracked
    mapping(address => address[]) public tokens_for_address; // tracked address => tokens to track

    mapping(address => OracleInfo) public oracle_info; // token address => info
    uint256 public chainlink_eth_usd_decimals;

    address public timelock_address;
    address public custodian_address;

    uint256 private constant PRICE_PRECISION = 1e6;
    uint256 private constant EXTRA_PRECISION = 1e6;

    
    struct OracleInfo {
        address token_address;
        string description;
        address aggregator_address;
        uint256 other_side_type; // 0: USD, 1: ETH
        uint256 decimals;
    }

    
    constructor (
        address _owner_address,
        address _amo_minter_address,
        address[] memory _initial_tracked_addresses,
        OracleInfo[] memory _initial_oracle_infos
    ) Owned(_owner_address) {
        amo_minter = IFraxAMOMinter(_amo_minter_address);

        custodian_address = amo_minter.custodian_address();
        timelock_address = amo_minter.timelock_address();

        priceFeedETHUSD = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        chainlink_eth_usd_decimals = priceFeedETHUSD.decimals();

        for (uint256 i = 0; i < _initial_oracle_infos.length; i++){ 
            OracleInfo memory thisOracleInfo = _initial_oracle_infos[i];
            _setOracleInfo(thisOracleInfo.token_address, thisOracleInfo.aggregator_address, thisOracleInfo.other_side_type);
        }

        for (uint256 i = 0; i < _initial_tracked_addresses.length; i++){ 
            address tracked_addr = _initial_tracked_addresses[i];
            tracked_addresses.push(tracked_addr);
            is_address_tracked[tracked_addr] = true;

            for (uint256 j = 0; j < _initial_oracle_infos.length; j++){ 
                OracleInfo memory thisOracleInfo = _initial_oracle_infos[j];
                tokens_for_address[tracked_addr].push(thisOracleInfo.token_address);
            }
        }


    }


    modifier onlyByOwnGov() {
        require(msg.sender == timelock_address || msg.sender == owner, "Not owner or timelock");
        _;
    }

    modifier onlyByOwnGovCust() {
        require(msg.sender == timelock_address || msg.sender == owner || msg.sender == custodian_address, "Not owner, tlck, or custd");
        _;
    }

    modifier onlyByMinter() {
        require(msg.sender == address(amo_minter), "Not minter");
        _;
    }


    function showAllocations() public view returns (uint256[1] memory allocations) {
        allocations[0] = getTotalValue(); // Total Value
    }

    function dollarBalances() public view returns (uint256 frax_val_e18, uint256 collat_val_e18) {
        frax_val_e18 = getTotalValue();
        collat_val_e18 = frax_val_e18;
    }

    function mintedBalance() public view returns (int256) {
        return amo_minter.frax_mint_balances(address(this));
    }

    function allTrackedAddresses() public view returns (address[] memory) {
        return tracked_addresses;
    }

    function allTokensForAddress(address tracked_address) public view returns (address[] memory) {
        return tokens_for_address[tracked_address];
    }

    function getETHPrice() public view returns (uint256) {
        ( , int price, , , ) = priceFeedETHUSD.latestRoundData();
        return uint256(price).mul(PRICE_PRECISION).div(10 ** chainlink_eth_usd_decimals);
    }

    function getPrice(address token_address) public view returns (uint256 raw_price, uint256 precise_price) {
        OracleInfo memory thisOracle = oracle_info[token_address];

        ( , int price, , , ) = AggregatorV3Interface(thisOracle.aggregator_address).latestRoundData();
        uint256 price_u256 = uint256(price);

        if (thisOracle.other_side_type == 1) price_u256 = (price_u256 * getETHPrice()) / PRICE_PRECISION;

        raw_price = (price_u256 * PRICE_PRECISION) / (uint256(10) ** thisOracle.decimals);

        precise_price = (price_u256 * PRICE_PRECISION * EXTRA_PRECISION) / (uint256(10) ** thisOracle.decimals);
    }

    function getValueInAddress(address tracked_address) public view returns (uint256 value_usd_e18) {
        require(is_address_tracked[tracked_address], "Address not being tracked");

        value_usd_e18 = (tracked_address.balance * getETHPrice()) / PRICE_PRECISION;

        address[] memory tracked_token_arr = tokens_for_address[tracked_address];
        for (uint i = 0; i < tracked_token_arr.length; i++){ 
            address the_token_addr = tracked_token_arr[i];
            if (the_token_addr != address(0)) {
                ( , uint256 precise_price) = getPrice(the_token_addr);
                uint256 missing_decimals = uint256(18) - ERC20(the_token_addr).decimals();
                value_usd_e18 += (((ERC20(the_token_addr).balanceOf(tracked_address) * (10 ** missing_decimals)) * precise_price) / (PRICE_PRECISION * EXTRA_PRECISION));
            }
        }
    }

    function getTotalValue() public view returns (uint256 value_usd_e18) {
        value_usd_e18 = 0;

        for (uint i = 0; i < tracked_addresses.length; i++){ 
            if (tracked_addresses[i] != address(0)) {
                value_usd_e18 += getValueInAddress(tracked_addresses[i]);
            }
        }
    }
   

    function setAMOMinter(address _amo_minter_address) external onlyByOwnGov {
        amo_minter = IFraxAMOMinter(_amo_minter_address);

        custodian_address = amo_minter.custodian_address();
        timelock_address = amo_minter.timelock_address();

        require(custodian_address != address(0) && timelock_address != address(0), "Invalid custodian or timelock");
    }


    function _setOracleInfo(address token_address, address aggregator_address, uint256 other_side_type) internal {
        oracle_info[token_address] = OracleInfo(
            token_address,
            AggregatorV3Interface(aggregator_address).description(),
            aggregator_address,
            other_side_type,
            uint256(AggregatorV3Interface(aggregator_address).decimals())
        );
    }

    function setOracleInfo(address token_address, address aggregator_address, uint256 other_side_type) public onlyByOwnGov {
        _setOracleInfo(token_address, aggregator_address, other_side_type);
    }


    function toggleTrackedAddress(address tracked_address) public onlyByOwnGov {
        is_address_tracked[tracked_address] = !is_address_tracked[tracked_address];
    }

    function addTrackedAddress(address tracked_address) public onlyByOwnGov {
        for (uint i = 0; i < tracked_addresses.length; i++){ 
            if (tracked_addresses[i] == tracked_address) {
                revert("Address already present");
            }
        }

        is_address_tracked[tracked_address] = true;
        tracked_addresses.push(tracked_address);
    }

    function removeTrackedAddress(address tracked_address) public onlyByOwnGov {
        is_address_tracked[tracked_address] = false;

        for (uint i = 0; i < tracked_addresses.length; i++){ 
            if (tracked_addresses[i] == tracked_address) {
                tracked_addresses[i] = address(0); // This will leave a null in the array and keep the indices the same

                delete tokens_for_address[tracked_address];
                break;
            }
        }
    }


    function addTokenForAddress(address tracked_address, address token_address) public onlyByOwnGov {
        require(oracle_info[token_address].decimals > 0, "Add Oracle info first");

        address[] memory tracked_token_arr = tokens_for_address[tracked_address];
        for (uint i = 0; i < tracked_token_arr.length; i++){ 
            if (tracked_token_arr[i] == tracked_address) {
                revert("Token already present");
            }
        }

        tokens_for_address[tracked_address].push(token_address);
    }

    function removeTokenForAddress(address tracked_address, address token_address) public onlyByOwnGov {
        address[] memory tracked_token_arr = tokens_for_address[tracked_address];

        for (uint i = 0; i < tracked_token_arr.length; i++){ 
            if (tracked_token_arr[i] == token_address) {
                tokens_for_address[tracked_address][i] = address(0); // This will leave a null in the array and keep the indices the same
                break;
            }
        }
    }


    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyByOwnGov {
        TransferHelper.safeTransfer(address(tokenAddress), msg.sender, tokenAmount);
    }

    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyByOwnGov returns (bool, bytes memory) {
        (bool success, bytes memory result) = _to.call{value:_value}(_data);
        return (success, result);
    }

}