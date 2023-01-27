


pragma solidity ^0.7.1;

interface ISaffronBase {

  enum Tranche {S, AA, A}
  enum LPTokenType {dsec, principal}

  struct TrancheUint256 {
    uint256 S;
    uint256 AA;
    uint256 A;
  }

  struct epoch_params {
    uint256 start_date;       // Time when the platform launched
    uint256 duration;         // Duration of epoch
  }
}



pragma solidity ^0.7.1;


interface ISaffronStrategy is ISaffronBase{

  function deploy_all_capital() external;

  function select_adapter_for_liquidity_removal() external returns(address);

  function add_adapter(address adapter_address) external;

  function add_pool(address pool_address) external;

  function delete_adapters() external;

  function set_governance(address to) external;

  function get_adapter_address(uint256 adapter_index) external view returns(address);

  function set_pool_SFI_reward(uint256 poolIndex, uint256 reward) external;

}



pragma solidity ^0.7.1;

interface ISaffronPool is ISaffronBase {

  function add_liquidity(uint256 amount, Tranche tranche) external;

  function remove_liquidity(address v1_dsec_token_address, uint256 dsec_amount, address v1_principal_token_address, uint256 principal_amount) external;

  function get_base_asset_address() external view returns(address);

  function hourly_strategy(address adapter_address) external;

  function wind_down_epoch(uint256 epoch, uint256 amount_sfi) external;

  function set_governance(address to) external;

  function get_epoch_cycle_params() external view returns (uint256, uint256);

  function shutdown() external;

}



pragma solidity ^0.7.1;

interface ISaffronAdapter is ISaffronBase {

    function deploy_capital(uint256 amount) external;

    function return_capital(uint256 base_asset_amount, address to) external;

    function approve_transfer(address addr,uint256 amount) external;

    function get_base_asset_address() external view returns(address);

    function set_base_asset(address addr) external;

    function get_holdings() external returns(uint256);

    function get_interest(uint256 principal) external returns(uint256);

    function set_governance(address to) external;

}



pragma solidity ^0.7.1;

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



pragma solidity ^0.7.1;

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



pragma solidity ^0.7.1;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.7.1;

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



pragma solidity ^0.7.1;





contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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



pragma solidity ^0.7.1;




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



pragma solidity ^0.7.1;



contract SFI is ERC20 {
  using SafeERC20 for IERC20;

  address public governance;
  address public SFI_minter;
  uint256 public MAX_TOKENS = 100000 ether;

  constructor (string memory name, string memory symbol) ERC20(name, symbol) {
    governance = msg.sender;
  }

  function mint_SFI(address to, uint256 amount) public {
    require(msg.sender == SFI_minter, "must be SFI_minter");
    require(this.totalSupply() + amount < MAX_TOKENS, "cannot mint more than MAX_TOKENS");
    _mint(to, amount);
  }

  function set_minter(address to) external {
    require(msg.sender == governance, "must be governance");
    SFI_minter = to;
  }

  function set_governance(address to) external {
    require(msg.sender == governance, "must be governance");
    governance = to;
  }

  event ErcSwept(address who, address to, address token, uint256 amount);
  function erc_sweep(address _token, address _to) public {
    require(msg.sender == governance, "must be governance");

    IERC20 tkn = IERC20(_token);
    uint256 tBal = tkn.balanceOf(address(this));
    tkn.safeTransfer(_to, tBal);

    emit ErcSwept(msg.sender, _to, _token, tBal);
  }
}



pragma solidity ^0.7.1;


contract SaffronLPBalanceToken is ERC20 {
  address public pool_address;

  constructor (string memory name, string memory symbol) ERC20(name, symbol) {
    pool_address = msg.sender;
  }

  function mint(address to, uint256 amount) public {
    require(msg.sender == pool_address, "must be pool");
    _mint(to, amount);
  }

  function burn(address account, uint256 amount) public {
    require(msg.sender == pool_address, "must be pool");
    _burn(account, amount);
  }

  function set_governance(address to) external {
    require(msg.sender == pool_address, "must be pool");
    pool_address = to;
  }
}



pragma solidity ^0.7.1;










contract SaffronPool is ISaffronPool {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  address public governance;           // Governance (v3: add off-chain/on-chain governance)
  address public base_asset_address;   // Base asset managed by the pool (DAI, USDT, YFI...)
  address public SFI_address;          // SFI token
  uint256 public pool_principal;       // Current principal balance (added minus removed)
  uint256 public pool_interest;        // Current interest balance (redeemable by dsec tokens)
  uint256 public tranche_A_multiplier; // Current yield multiplier for tranche A
  uint256 public SFI_ratio;            // Ratio of base asset to SFI necessary to join tranche A

  bool public _shutdown = false;       // v0, v1: shutdown the pool after the final capital deploy to prevent burning funds

  address public best_adapter_address;              // Current best adapter selected by strategy
  uint256 public adapter_total_principal;           // v0, v1: only one adapter
  ISaffronAdapter[] private adapters;               // v2: list of adapters
  mapping(address=>uint256) private adapter_index;  // v1: adapter contract address lookup for array indexes

  address public strategy;

  epoch_params public epoch_cycle = epoch_params({
    start_date: 1604239200,   // 11/01/2020 @ 2:00pm (UTC)
    duration:   14 days       // 1210000 seconds
  });

  uint256[] public epoch_principal;               // Total principal owned by the pool (all tranches)
  mapping(uint256=>bool) public epoch_wound_down; // True if epoch has been wound down already (governance)

  address[3][] public dsec_token_addresses;         // Address for each dsec token
  address[3][] public principal_token_addresses;    // Address for each principal token
  uint256[3][] public tranche_total_dsec;           // Total dsec (tokens + vdsec)
  uint256[3][] public tranche_total_principal;      // Total outstanding principal tokens
  uint256[3][] public tranche_total_utilized;       // Total utilized balance in each tranche
  uint256[3][] public tranche_total_unutilized;     // Total unutilized balance in each tranche
  uint256[3][] public tranche_S_virtual_utilized;   // Total utilized virtual balance taken from tranche S (first index unused)
  uint256[3][] public tranche_S_virtual_unutilized; // Total unutilized virtual balance taken from tranche S (first index unused)
  uint256[3][] public tranche_interest_earned;      // Interest earned (calculated at wind_down_epoch)
  uint256[3][] public tranche_SFI_earned;           // Total SFI earned (minted at wind_down_epoch)

  TrancheUint256 public TRANCHE_SFI_MULTIPLIER = TrancheUint256({
    S:   90000,
    AA:  0,
    A:   10000
  });


  struct SaffronLPTokenInfo {
    bool        exists;
    uint256     epoch;
    Tranche     tranche;
    LPTokenType token_type;
  }
  mapping(address=>SaffronLPTokenInfo) private saffron_LP_token_info;

  constructor(address _strategy, address _base_asset, address _SFI_address, uint256 _SFI_ratio, bool epoch_cycle_reset) {
    governance = msg.sender;
    base_asset_address = _base_asset;
    strategy = _strategy;
    SFI_address = _SFI_address;
    tranche_A_multiplier = 10; // v1: start enhanced yield at 10X
    SFI_ratio = _SFI_ratio;    // v1: constant ratio
    epoch_cycle.duration = (epoch_cycle_reset ? 20 minutes : 14 days); // Make testing previous epochs easier
    epoch_cycle.start_date = (epoch_cycle_reset ? (block.timestamp) - (4 * epoch_cycle.duration) : 1604239200); // Make testing previous epochs easier
  }

  function new_epoch(uint256 epoch, address[] memory saffron_LP_dsec_token_addresses, address[] memory saffron_LP_principal_token_addresses) public {
    require(tranche_total_principal.length == epoch, "improper new epoch");
    require(governance == msg.sender, "must be governance");

    epoch_principal.push(0);
    tranche_total_dsec.push([0,0,0]);
    tranche_total_principal.push([0,0,0]);
    tranche_total_utilized.push([0,0,0]);
    tranche_total_unutilized.push([0,0,0]);
    tranche_S_virtual_utilized.push([0,0,0]);
    tranche_S_virtual_unutilized.push([0,0,0]);
    tranche_interest_earned.push([0,0,0]);
    tranche_SFI_earned.push([0,0,0]);

    dsec_token_addresses.push([       // Address for each dsec token
      saffron_LP_dsec_token_addresses[uint256(Tranche.S)],
      saffron_LP_dsec_token_addresses[uint256(Tranche.AA)],
      saffron_LP_dsec_token_addresses[uint256(Tranche.A)]
    ]);

    principal_token_addresses.push([  // Address for each principal token
      saffron_LP_principal_token_addresses[uint256(Tranche.S)],
      saffron_LP_principal_token_addresses[uint256(Tranche.AA)],
      saffron_LP_principal_token_addresses[uint256(Tranche.A)]
    ]);

    saffron_LP_token_info[saffron_LP_dsec_token_addresses[uint256(Tranche.S)]] = SaffronLPTokenInfo({
      exists: true,
      epoch: epoch,
      tranche: Tranche.S,
      token_type: LPTokenType.dsec
    });

    saffron_LP_token_info[saffron_LP_dsec_token_addresses[uint256(Tranche.AA)]] = SaffronLPTokenInfo({
      exists: true,
      epoch: epoch,
      tranche: Tranche.AA,
      token_type: LPTokenType.dsec
    });

    saffron_LP_token_info[saffron_LP_dsec_token_addresses[uint256(Tranche.A)]] = SaffronLPTokenInfo({
      exists: true,
      epoch: epoch,
      tranche: Tranche.A,
      token_type: LPTokenType.dsec
    });

    saffron_LP_token_info[saffron_LP_principal_token_addresses[uint256(Tranche.S)]] = SaffronLPTokenInfo({
      exists: true,
      epoch: epoch,
      tranche: Tranche.S,
      token_type: LPTokenType.principal
    });

    saffron_LP_token_info[saffron_LP_principal_token_addresses[uint256(Tranche.AA)]] = SaffronLPTokenInfo({
      exists: true,
      epoch: epoch,
      tranche: Tranche.AA,
      token_type: LPTokenType.principal
    });

    saffron_LP_token_info[saffron_LP_principal_token_addresses[uint256(Tranche.A)]] = SaffronLPTokenInfo({
      exists: true,
      epoch: epoch,
      tranche: Tranche.A,
      token_type: LPTokenType.principal
    });
  }

  struct BalanceVars {
    uint256 deposit;  // User deposit
    uint256 capacity; // Capacity for user's intended tranche
    uint256 change;   // Change from deposit - capacity

    uint256 consumed; // Total consumed
    uint256 utilized_consumed;
    uint256 unutilized_consumed;
    uint256 available_utilized;
    uint256 available_unutilized;
  }
  event TrancheBalance(uint256 tranche, uint256 amount, uint256 deposit, uint256 capacity, uint256 change, uint256 consumed, uint256 utilized_consumed, uint256 unutilized_consumed, uint256 available_utilized, uint256 available_unutilized);
  event DsecGeneration(uint256 time_remaining, uint256 amount, uint256 dsec, address dsec_address, uint256 epoch, uint256 tranche, address user_address, address principal_token_addr);
  event AddLiquidity(uint256 new_pool_principal, uint256 new_epoch_principal, uint256 new_eternal_balance, uint256 new_tranche_principal, uint256 new_tranche_dsec);
  function add_liquidity(uint256 amount, Tranche tranche) external override {
    require(!_shutdown, "pool shutdown");
    require(tranche == Tranche.S || tranche == Tranche.A, "v1: can't add_liquidity into AA tranche");
    uint256 epoch = get_current_epoch();
    require(amount != 0, "can't add 0");
    require(epoch == 17, "v1.17: only epoch 17 only");
    BalanceVars memory bv = BalanceVars({
      deposit: 0,
      capacity: 0,
      change: 0,
      consumed: 0,
      utilized_consumed: 0,
      unutilized_consumed: 0,
      available_utilized: 0,
      available_unutilized: 0
    });
    (bv.available_utilized, bv.available_unutilized) = get_available_S_balances();

    if (tranche == Tranche.S) {
      tranche_total_unutilized[epoch][uint256(Tranche.S)] = tranche_total_unutilized[epoch][uint256(Tranche.S)].add(amount);
      bv.deposit = amount;
    }
    if (tranche == Tranche.A) {
      bv.capacity = (bv.available_utilized.add(bv.available_unutilized)).div(tranche_A_multiplier);
      bv.deposit  = (amount < bv.capacity) ? amount : bv.capacity;
      bv.consumed = bv.deposit.mul(tranche_A_multiplier);
      if (bv.consumed <= bv.available_utilized) {
        bv.utilized_consumed = bv.consumed;
      } else {
        bv.utilized_consumed = bv.available_utilized;
        bv.unutilized_consumed = bv.consumed.sub(bv.utilized_consumed);
        tranche_S_virtual_unutilized[epoch][uint256(Tranche.AA)] = tranche_S_virtual_unutilized[epoch][uint256(Tranche.AA)].add(bv.unutilized_consumed);
      }
      tranche_S_virtual_utilized[epoch][uint256(Tranche.AA)] = tranche_S_virtual_utilized[epoch][uint256(Tranche.AA)].add(bv.utilized_consumed);
      if (bv.deposit < amount) bv.change = amount.sub(bv.deposit);
    }

    uint256 dsec = bv.deposit.mul(get_seconds_until_epoch_end(epoch));

    pool_principal = pool_principal.add(bv.deposit);                 // Add DAI to principal totals
    epoch_principal[epoch] = epoch_principal[epoch].add(bv.deposit); // Add DAI total balance for epoch

    tranche_total_dsec[epoch][uint256(tranche)] = tranche_total_dsec[epoch][uint256(tranche)].add(dsec);
    tranche_total_principal[epoch][uint256(tranche)] = tranche_total_principal[epoch][uint256(tranche)].add(bv.deposit);

    IERC20(base_asset_address).safeTransferFrom(msg.sender, address(this), bv.deposit);
    if (tranche == Tranche.A) IERC20(SFI_address).safeTransferFrom(msg.sender, address(this), bv.deposit * 1 ether / SFI_ratio);

    SaffronLPBalanceToken(dsec_token_addresses[epoch][uint256(tranche)]).mint(msg.sender, dsec);

    SaffronLPBalanceToken(principal_token_addresses[epoch][uint256(tranche)]).mint(msg.sender, bv.deposit);

    emit TrancheBalance(uint256(tranche), bv.deposit, bv.deposit, bv.capacity, bv.change, bv.consumed, bv.utilized_consumed, bv.unutilized_consumed, bv.available_utilized, bv.available_unutilized);
    emit DsecGeneration(get_seconds_until_epoch_end(epoch), bv.deposit, dsec, dsec_token_addresses[epoch][uint256(tranche)], epoch, uint256(tranche), msg.sender, principal_token_addresses[epoch][uint256(tranche)]);
    emit AddLiquidity(pool_principal, epoch_principal[epoch], 0, tranche_total_principal[epoch][uint256(tranche)], tranche_total_dsec[epoch][uint256(tranche)]);
  }


  event WindDownEpochSFI(uint256 previous_epoch, uint256 S_SFI, uint256 AA_SFI, uint256 A_SFI);
  event WindDownEpochState(uint256 epoch, uint256 tranche_S_interest, uint256 tranche_AA_interest, uint256 tranche_A_interest, uint256 tranche_SFI_earnings_S, uint256 tranche_SFI_earnings_AA, uint256 tranche_SFI_earnings_A);
  struct WindDownVars {
    uint256 previous_epoch;
    uint256 epoch_interest;
    uint256 epoch_dsec;
    uint256 tranche_A_interest_ratio;
    uint256 tranche_A_interest;
    uint256 tranche_S_interest;
  }

  function wind_down_epoch(uint256 epoch, uint256 amount_sfi) public override {
    require(msg.sender == strategy, "must be strategy");
    require(!epoch_wound_down[epoch], "epoch already wound down");
    uint256 current_epoch = get_current_epoch();
    require(epoch < current_epoch, "cannot wind down future epoch");
    WindDownVars memory wind_down = WindDownVars({
      previous_epoch: 0,
      epoch_interest: 0,
      epoch_dsec: 0,
      tranche_A_interest_ratio: 0,
      tranche_A_interest: 0,
      tranche_S_interest: 0
    });
    wind_down.previous_epoch = current_epoch - 1;
    require(block.timestamp >= get_epoch_end(wind_down.previous_epoch), "can't call before epoch ended");

    tranche_SFI_earned[epoch][uint256(Tranche.S)]  = TRANCHE_SFI_MULTIPLIER.S.mul(amount_sfi).div(100000);
    tranche_SFI_earned[epoch][uint256(Tranche.AA)] = TRANCHE_SFI_MULTIPLIER.AA.mul(amount_sfi).div(100000);
    tranche_SFI_earned[epoch][uint256(Tranche.A)]  = TRANCHE_SFI_MULTIPLIER.A.mul(amount_sfi).div(100000);

    emit WindDownEpochSFI(wind_down.previous_epoch, tranche_SFI_earned[epoch][uint256(Tranche.S)], tranche_SFI_earned[epoch][uint256(Tranche.AA)], tranche_SFI_earned[epoch][uint256(Tranche.A)]);


    ISaffronAdapter adapter = ISaffronAdapter(best_adapter_address);
    wind_down.epoch_interest = adapter.get_interest(adapter_total_principal);
    pool_interest = pool_interest.add(wind_down.epoch_interest);

    wind_down.epoch_dsec = tranche_total_dsec[epoch][uint256(Tranche.S)].add(tranche_total_dsec[epoch][uint256(Tranche.A)]);
    wind_down.tranche_A_interest_ratio = tranche_total_dsec[epoch][uint256(Tranche.A)].mul(1 ether).div(wind_down.epoch_dsec);

    wind_down.tranche_A_interest = (wind_down.epoch_interest.mul(wind_down.tranche_A_interest_ratio).div(1 ether)).mul(tranche_A_multiplier);
    wind_down.tranche_S_interest = wind_down.epoch_interest.sub(wind_down.tranche_A_interest);

    tranche_interest_earned[epoch][uint256(Tranche.S)]  = wind_down.tranche_S_interest;
    tranche_interest_earned[epoch][uint256(Tranche.AA)] = 0;
    tranche_interest_earned[epoch][uint256(Tranche.A)]  = wind_down.tranche_A_interest;

    emit WindDownEpochState(epoch, wind_down.tranche_S_interest, 0, wind_down.tranche_A_interest, uint256(tranche_SFI_earned[epoch][uint256(Tranche.S)]), uint256(tranche_SFI_earned[epoch][uint256(Tranche.AA)]), uint256(tranche_SFI_earned[epoch][uint256(Tranche.A)]));
    epoch_wound_down[epoch] = true;
    delete wind_down;
  }

  event RemoveLiquidityDsec(uint256 dsec_percent, uint256 interest_owned, uint256 SFI_owned);
  event RemoveLiquidityPrincipal(uint256 principal);
  function remove_liquidity(address dsec_token_address, uint256 dsec_amount, address principal_token_address, uint256 principal_amount) external override {
    require(dsec_amount > 0 || principal_amount > 0, "can't remove 0");
    ISaffronAdapter best_adapter = ISaffronAdapter(best_adapter_address);
    uint256 interest_owned;
    uint256 SFI_earn;
    uint256 SFI_return;
    uint256 dsec_percent;

    if (dsec_token_address != address(0x0) && dsec_amount > 0) {
      SaffronLPTokenInfo memory token_info = saffron_LP_token_info[dsec_token_address];
      require(token_info.exists, "balance token lookup failed");
      SaffronLPBalanceToken sbt = SaffronLPBalanceToken(dsec_token_address);
      require(sbt.balanceOf(msg.sender) >= dsec_amount, "insufficient dsec balance");

      uint256 token_epoch = token_info.epoch;
      require(token_info.token_type == LPTokenType.dsec, "bad dsec address");
      require(token_epoch == 17, "v1.17: bal token epoch must be 17");
      require(epoch_wound_down[token_epoch], "can't remove from wound up epoch");
      uint256 tranche_dsec = tranche_total_dsec[token_epoch][uint256(token_info.tranche)];

      dsec_percent = (tranche_dsec == 0) ? 0 : dsec_amount.mul(1 ether).div(tranche_dsec);
      interest_owned = tranche_interest_earned[token_epoch][uint256(token_info.tranche)].mul(dsec_percent) / 1 ether;
      SFI_earn = tranche_SFI_earned[token_epoch][uint256(token_info.tranche)].mul(dsec_percent) / 1 ether;

      tranche_interest_earned[token_epoch][uint256(token_info.tranche)] = tranche_interest_earned[token_epoch][uint256(token_info.tranche)].sub(interest_owned);
      tranche_SFI_earned[token_epoch][uint256(token_info.tranche)] = tranche_SFI_earned[token_epoch][uint256(token_info.tranche)].sub(SFI_earn);
      tranche_total_dsec[token_epoch][uint256(token_info.tranche)] = tranche_total_dsec[token_epoch][uint256(token_info.tranche)].sub(dsec_amount);
      pool_interest = pool_interest.sub(interest_owned);
    }

    if (principal_token_address != address(0x0) && principal_amount > 0) {
      SaffronLPTokenInfo memory token_info = saffron_LP_token_info[principal_token_address];
      require(token_info.exists, "balance token info lookup failed");
      SaffronLPBalanceToken sbt = SaffronLPBalanceToken(principal_token_address);
      require(sbt.balanceOf(msg.sender) >= principal_amount, "insufficient principal balance");

      uint256 token_epoch = token_info.epoch;
      require(token_info.token_type == LPTokenType.principal, "bad balance token address");
      require(token_epoch == 17, "v1.17: bal token epoch must be 17");
      require(epoch_wound_down[token_epoch], "can't remove from wound up epoch");

      tranche_total_principal[token_epoch][uint256(token_info.tranche)] = tranche_total_principal[token_epoch][uint256(token_info.tranche)].sub(principal_amount);
      epoch_principal[token_epoch] = epoch_principal[token_epoch].sub(principal_amount);
      pool_principal = pool_principal.sub(principal_amount);
      adapter_total_principal = adapter_total_principal.sub(principal_amount);
      if (token_info.tranche == Tranche.A) SFI_return = principal_amount * 1 ether / SFI_ratio;
    }

    if (dsec_token_address != address(0x0) && dsec_amount > 0) {
      SaffronLPBalanceToken sbt = SaffronLPBalanceToken(dsec_token_address);
      require(sbt.balanceOf(msg.sender) >= dsec_amount, "insufficient dsec balance");
      sbt.burn(msg.sender, dsec_amount);
      if (interest_owned > 0) {
        best_adapter.return_capital(interest_owned, msg.sender);
      }
      IERC20(SFI_address).safeTransfer(msg.sender, SFI_earn);
      emit RemoveLiquidityDsec(dsec_percent, interest_owned, SFI_earn);
    }
    if (principal_token_address != address(0x0) && principal_amount > 0) {
      SaffronLPBalanceToken sbt = SaffronLPBalanceToken(principal_token_address);
      require(sbt.balanceOf(msg.sender) >= principal_amount, "insufficient principal balance");
      sbt.burn(msg.sender, principal_amount);
      best_adapter.return_capital(principal_amount, msg.sender);
      IERC20(SFI_address).safeTransfer(msg.sender, SFI_return);
      emit RemoveLiquidityPrincipal(principal_amount);
    }

    require((dsec_token_address != address(0x0) && dsec_amount > 0) || (principal_token_address != address(0x0) && principal_amount > 0), "no action performed");
  }

  event StrategicDeploy(address adapter_address, uint256 amount, uint256 epoch);
  function hourly_strategy(address adapter_address) external override {
    require(msg.sender == strategy, "must be strategy");
    require(!_shutdown, "pool shutdown");
    uint256 epoch = get_current_epoch();
    best_adapter_address = adapter_address;
    ISaffronAdapter best_adapter = ISaffronAdapter(adapter_address);
    uint256 amount = IERC20(base_asset_address).balanceOf(address(this));

    tranche_total_utilized[epoch][uint256(Tranche.S)] = tranche_total_utilized[epoch][uint256(Tranche.S)].add(tranche_total_unutilized[epoch][uint256(Tranche.S)]);
    tranche_total_utilized[epoch][uint256(Tranche.A)] = tranche_total_utilized[epoch][uint256(Tranche.A)].add(tranche_total_unutilized[epoch][uint256(Tranche.A)]);
    tranche_S_virtual_utilized[epoch][uint256(Tranche.AA)] = tranche_S_virtual_utilized[epoch][uint256(Tranche.AA)].add(tranche_S_virtual_unutilized[epoch][uint256(Tranche.AA)]);

    tranche_total_unutilized[epoch][uint256(Tranche.S)] = 0;
    tranche_total_unutilized[epoch][uint256(Tranche.A)] = 0;
    tranche_S_virtual_unutilized[epoch][uint256(Tranche.AA)] = 0;

    adapter_total_principal = adapter_total_principal.add(amount);
    emit StrategicDeploy(adapter_address, amount, epoch);

    IERC20(base_asset_address).safeTransfer(adapter_address, amount);
    best_adapter.deploy_capital(amount);
  }

  function shutdown() external override {
    require(msg.sender == strategy || msg.sender == governance, "must be strategy");
    require(block.timestamp > get_epoch_end(1) - 1 days, "trying to shutdown too early");
    _shutdown = true;
  }

  function set_governance(address to) external override {
    require(msg.sender == governance, "must be governance");
    governance = to;
  }

  function set_best_adapter(address to) external {
    require(msg.sender == governance, "must be governance");
    best_adapter_address = to;
  }

  function get_epoch_end(uint256 epoch) public view returns (uint256) {
    return epoch_cycle.start_date.add(epoch.add(1).mul(epoch_cycle.duration));
  }

  function get_current_epoch() public view returns (uint256) {
    require(block.timestamp > epoch_cycle.start_date, "before epoch 0");
    return (block.timestamp - epoch_cycle.start_date) / epoch_cycle.duration;
  }

  function get_seconds_until_epoch_end(uint256 epoch) public view returns (uint256) {
    return epoch_cycle.start_date.add(epoch.add(1).mul(epoch_cycle.duration)).sub(block.timestamp);
  }

  function get_available_S_balances() public view returns(uint256, uint256) {
    uint256 epoch = get_current_epoch();
    uint256 AA_A_utilized = tranche_S_virtual_utilized[epoch][uint256(Tranche.A)].add(tranche_S_virtual_utilized[epoch][uint256(Tranche.AA)]);
    uint256 AA_A_unutilized = tranche_S_virtual_unutilized[epoch][uint256(Tranche.A)].add(tranche_S_virtual_unutilized[epoch][uint256(Tranche.AA)]);
    uint256 S_utilized = tranche_total_utilized[epoch][uint256(Tranche.S)];
    uint256 S_unutilized = tranche_total_unutilized[epoch][uint256(Tranche.S)];
    return ((S_utilized > AA_A_utilized ? S_utilized - AA_A_utilized : 0), (S_unutilized > AA_A_unutilized ? S_unutilized - AA_A_unutilized : 0));
  }

  function get_epoch_cycle_params() external view override returns (uint256, uint256) {
    return (epoch_cycle.start_date, epoch_cycle.duration);
  }

  function get_base_asset_address() external view override returns(address) {
    return base_asset_address;
  }

  function delete_adapters() external {
    require(msg.sender == governance, "must be governance");
    require(block.timestamp > get_epoch_end(17) + 10 weeks, "too soon");
    delete adapters;
  }

  event ErcSwept(address who, address to, address token, uint256 amount);
  function erc_sweep(address _token, address _to) public {
    require(msg.sender == governance, "must be governance");
    require(_token != base_asset_address && _token != SFI_address, "cannot sweep pool assets");

    IERC20 tkn = IERC20(_token);
    uint256 tBal = tkn.balanceOf(address(this));
    tkn.safeTransfer(_to, tBal);

    emit ErcSwept(msg.sender, _to, _token, tBal);
  }

  event Swept(address who, address to, uint256 sfiBal, uint256 baseBal);
  function sweep(address _to) public {
    require(msg.sender == governance, "must be governance");

    IERC20 tkn = IERC20(address(SFI_address));
    uint256 sfiBal = tkn.balanceOf(address(this));
    tkn.safeTransfer(_to, sfiBal);

    IERC20 base = IERC20(address(base_asset_address));
    uint256 baseBal = base.balanceOf(address(this));
    base.safeTransfer(_to, baseBal);

    emit Swept(msg.sender, _to, sfiBal, baseBal);
  }

  function set_strategy(address to) external {
    require(msg.sender == governance, "must be governance");
    strategy = to;
  }
}