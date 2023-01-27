

pragma solidity ^0.7.1;

interface ISaffronBase {

  enum Tranche {S, AA, A, SAA, SA}
  enum LPTokenType {dsec, principal}

  struct TrancheUint256 {
    uint256 S;
    uint256 AA;
    uint256 A;
    uint256 SAA;
    uint256 SA;
  }
}


pragma solidity ^0.7.1;

interface ISaffronStrategy {

  function deploy_all_capital() external;

  function select_adapter_for_liquidity_removal() external returns(address);

  function add_adapter(address adapter_address) external;

  function add_pool(address pool_address) external;

  function delete_adapters() external;

  function set_governance(address to) external;

  function get_adapter_address(uint256 adapter_index) external view returns(address);

}


pragma solidity ^0.7.1;

interface ISaffronPool is ISaffronBase {

  function add_liquidity(uint256 amount, Tranche tranche) external;

  function remove_liquidity(address v1_dsec_token_address, uint256 dsec_amount, address v1_principal_token_address, uint256 principal_amount) external;

  function hourly_strategy(address adapter_address) external;

  function get_governance() external view returns(address);

  function get_base_asset_address() external view returns(address);

  function get_strategy_address() external view returns(address);

  function delete_adapters() external;

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
  address public team_address;         // Team SFI address
  uint256 public pool_principal;       // Current principal balance (added minus removed)
  uint256 public pool_interest;        // Current interest balance (redeemable by dsec tokens)
  uint256 public tranche_A_multiplier; // Current yield multiplier for tranche A

  bool public _shutdown = false; // v0 shutdown the pool after the final capital deploy to prevent burning funds

  address public best_adapter_address;              // Current best adapter selected by strategy
  uint256 public adapter_total_principal;           // v0: only one adapter
  ISaffronAdapter[] private adapters;               // v1: list of adapters
  mapping(address=>uint256) private adapter_index;  // v1: adapter contract address lookup for array indexes

  ISaffronStrategy private strategy;

  struct epoch_params {
    uint256 start_date;       // Time when the activity cycle begins (set to blocktime at contract deployment)
    uint256 duration;         // Duration of epoch
  }

  epoch_params public epoch_cycle = epoch_params({
    start_date: 1604239200, // 11/01/2020 @ 2:00pm (UTC)
    duration: 2 weeks       // 1210000 seconds
  });

  uint256[] public epoch_principal;               // Total principal owned by the pool (all tranches)
  mapping(uint256=>bool) public epoch_wound_down; // True if epoch has been wound down already (governance)

  address[3][] public dsec_token_addresses;      // Address for each dsec token
  address[3][] public principal_token_addresses; // Address for each principal token
  uint256[5][] public tranche_total_dsec;        // Total dsec (tokens + vdsec)
  uint256[5][] public tranche_total_principal;   // Total outstanding principal tokens
  uint256[3][] public tranche_total_vdsec_AA;    // Total AA vdsec
  uint256[3][] public tranche_total_vdsec_A;     // Total A vdsec
  uint256[5][] public tranche_interest_earned;   // Interest earned (calculated at wind_down_epoch)
  uint256[5][] public tranche_SFI_earned;        // Total SFI earned (minted at wind_down_epoch)

  TrancheUint256 public TRANCHE_SFI_MULTIPLIER = TrancheUint256({
    S:   10,
    AA:  80,
    A:   10,
    SAA: 0,
    SA:  0
  });

  TrancheUint256 private eternal_unutilized_balances; // Unutilized balance (in base assets) for each tranche (assets held in this pool + assets held in platforms)
  TrancheUint256 private eternal_utilized_balances;   // Balance for each tranche that is not held within this pool but instead held on a platform via an adapter

  struct SaffronV1TokenInfo {
    bool        exists;
    uint256     epoch;
    Tranche     tranche;
    LPTokenType token_type;
  }
  mapping(address=>SaffronV1TokenInfo) private saffron_v1_token_info;

  constructor(address _strategy, address _base_asset, address _SFI_address, address _team_address) {
    governance = msg.sender;
    base_asset_address = _base_asset;
    strategy = ISaffronStrategy(_strategy);
    SFI_address = _SFI_address;
    tranche_A_multiplier = 3;
    team_address = _team_address;
  }

  function new_epoch(uint256 epoch, address[] memory saffron_v1_dsec_token_addresses, address[] memory saffron_v1_principal_token_addresses) public {
    require(tranche_total_principal.length == epoch, "improper new epoch");

    epoch_principal.push(0);
    tranche_total_dsec.push([0,0,0,0,0]);
    tranche_total_principal.push([0,0,0,0,0]);
    tranche_total_vdsec_AA.push([0,0,0]);
    tranche_total_vdsec_A.push([0,0,0]);
    tranche_interest_earned.push([0,0,0,0,0]);
    tranche_SFI_earned.push([0,0,0,0,0]);

    dsec_token_addresses.push([       // Address for each dsec token
      saffron_v1_dsec_token_addresses[uint256(Tranche.S)],
      saffron_v1_dsec_token_addresses[uint256(Tranche.AA)],
      saffron_v1_dsec_token_addresses[uint256(Tranche.A)]
    ]);

    principal_token_addresses.push([  // Address for each principal token
      saffron_v1_principal_token_addresses[uint256(Tranche.S)],
      saffron_v1_principal_token_addresses[uint256(Tranche.AA)],
      saffron_v1_principal_token_addresses[uint256(Tranche.A)]
    ]);

    saffron_v1_token_info[saffron_v1_dsec_token_addresses[uint256(Tranche.S)]] = SaffronV1TokenInfo({
      exists: true,
      epoch: epoch,
      tranche: Tranche.S,
      token_type: LPTokenType.dsec
    });

    saffron_v1_token_info[saffron_v1_dsec_token_addresses[uint256(Tranche.AA)]] = SaffronV1TokenInfo({
      exists: true,
      epoch: epoch,
      tranche: Tranche.AA,
      token_type: LPTokenType.dsec
    });

    saffron_v1_token_info[saffron_v1_dsec_token_addresses[uint256(Tranche.A)]] = SaffronV1TokenInfo({
      exists: true,
      epoch: epoch,
      tranche: Tranche.A,
      token_type: LPTokenType.dsec
    });

    saffron_v1_token_info[saffron_v1_principal_token_addresses[uint256(Tranche.S)]] = SaffronV1TokenInfo({
      exists: true,
      epoch: epoch,
      tranche: Tranche.S,
      token_type: LPTokenType.principal
    });

    saffron_v1_token_info[saffron_v1_principal_token_addresses[uint256(Tranche.AA)]] = SaffronV1TokenInfo({
      exists: true,
      epoch: epoch,
      tranche: Tranche.AA,
      token_type: LPTokenType.principal
    });

    saffron_v1_token_info[saffron_v1_principal_token_addresses[uint256(Tranche.A)]] = SaffronV1TokenInfo({
      exists: true,
      epoch: epoch,
      tranche: Tranche.A,
      token_type: LPTokenType.principal
    });
  }

  event DsecGeneration(uint256 time_remaining, uint256 amount, uint256 dsec, address dsec_address, uint256 epoch, uint256 tranche, address user_address, address principal_token_addr);
  event AddLiquidity(uint256 new_pool_principal, uint256 new_epoch_principal, uint256 new_eternal_balance, uint256 new_tranche_principal, uint256 new_tranche_dsec);
  function add_liquidity(uint256 amount, Tranche tranche) external override {
    require(!_shutdown, "pool shutdown");
    require(tranche == Tranche.S, "tranche S only"); // v0: can't add to any tranche other than the S tranche
    uint256 epoch = get_current_epoch();

    require(amount != 0, "can't add 0");
    require(epoch == 0, "v0: must be epoch 0 only"); // v0: can't add liquidity after epoch 0

    uint256 dsec = amount.mul(get_seconds_until_epoch_end(epoch));

    pool_principal = pool_principal.add(amount);                 // Add DAI to principal totals
    epoch_principal[epoch] = epoch_principal[epoch].add(amount); // Add DAI total balance for epoch
    if (tranche == Tranche.S) eternal_unutilized_balances.S = eternal_unutilized_balances.S.add(amount); // Add to eternal balance of S tranche

    tranche_total_dsec[epoch][uint256(tranche)] = tranche_total_dsec[epoch][uint256(tranche)].add(dsec);
    tranche_total_principal[epoch][uint256(tranche)] = tranche_total_principal[epoch][uint256(tranche)].add(amount);

    IERC20(base_asset_address).safeTransferFrom(msg.sender, address(this), amount);

    SaffronLPBalanceToken(dsec_token_addresses[epoch][uint256(tranche)]).mint(msg.sender, dsec);

    SaffronLPBalanceToken(principal_token_addresses[epoch][uint256(tranche)]).mint(msg.sender, amount);

    emit DsecGeneration(get_seconds_until_epoch_end(epoch), amount, dsec, dsec_token_addresses[epoch][uint256(tranche)], epoch, uint256(tranche), msg.sender, principal_token_addresses[epoch][uint256(tranche)]);
    emit AddLiquidity(pool_principal, epoch_principal[epoch], eternal_unutilized_balances.S, tranche_total_principal[epoch][uint256(tranche)], tranche_total_dsec[epoch][uint256(tranche)]);
  }


  event WindDownEpochSFI(uint256 previous_epoch, uint256 S_SFI, uint256 AA_SFI, uint256 A_SFI);
  event WindDownEpochState(uint256 epoch, uint256 tranche_S_interest, uint256 tranche_AA_interest, uint256 tranche_A_interest, uint256 tranche_SFI_earnings_S, uint256 tranche_SFI_earnings_AA, uint256 tranche_SFI_earnings_A);
  event WindDownEpochInterest(uint256 adapter_holdings, uint256 adapter_total_principal, uint256 epoch_interest_rate, uint256 epoch_principal, uint256 epoch_interest, uint256 tranche_A_interest, uint256 tranche_AA_interest);
  struct WindDownVars {
    uint256 previous_epoch;
    uint256 SFI_rewards;
    uint256 epoch_interest;
    uint256 tranche_AA_interest;
    uint256 tranche_A_interest;
    uint256 tranche_S_share_of_AA_interest;
    uint256 tranche_S_share_of_A_interest;
    uint256 tranche_S_interest;
  }
  function wind_down_epoch(uint256 epoch) public {
    require(!epoch_wound_down[epoch], "epoch already wound down");
    uint256 current_epoch = get_current_epoch();
    require(epoch < current_epoch, "cannot wind down future epoch");
    WindDownVars memory wind_down = WindDownVars({
      previous_epoch: 0,
      SFI_rewards: 0,
      epoch_interest: 0,
      tranche_AA_interest: 0,
      tranche_A_interest: 0,
      tranche_S_share_of_AA_interest: 0,
      tranche_S_share_of_A_interest: 0,
      tranche_S_interest: 0
    });
    wind_down.previous_epoch = current_epoch - 1;
    require(block.timestamp >= get_epoch_end(wind_down.previous_epoch), "can't call before epoch ended");

    wind_down.SFI_rewards = (30000 * 1 ether) >> epoch; // v1: add plateau for ongoing generation
    TrancheUint256 memory tranche_SFI_earnings = TrancheUint256({
      S:   TRANCHE_SFI_MULTIPLIER.S  * wind_down.SFI_rewards / 100,
      AA:  TRANCHE_SFI_MULTIPLIER.AA * wind_down.SFI_rewards / 100,
      A:   TRANCHE_SFI_MULTIPLIER.A  * wind_down.SFI_rewards / 100,
      SAA: 0, SA: 0
    });

    emit WindDownEpochSFI(wind_down.previous_epoch, tranche_SFI_earnings.S, tranche_SFI_earnings.AA, tranche_SFI_earnings.A);

    ISaffronAdapter adapter = ISaffronAdapter(best_adapter_address);
    wind_down.epoch_interest = adapter.get_interest(adapter_total_principal);
    pool_interest = pool_interest.add(wind_down.epoch_interest);

    wind_down.tranche_A_interest  = wind_down.epoch_interest.mul(tranche_A_multiplier.mul(1 ether)/(tranche_A_multiplier + 1)) / 1 ether;
    wind_down.tranche_AA_interest = wind_down.epoch_interest - wind_down.tranche_A_interest;
    emit WindDownEpochInterest(adapter.get_holdings(), adapter_total_principal, (((wind_down.epoch_interest.add(epoch_principal[epoch])).mul(1 ether)).div(epoch_principal[epoch])), epoch_principal[epoch], wind_down.epoch_interest, wind_down.tranche_A_interest, wind_down.tranche_AA_interest);

    wind_down.tranche_S_share_of_AA_interest = (tranche_total_vdsec_AA[epoch][uint256(Tranche.S)].div(tranche_total_dsec[epoch][uint256(Tranche.AA)])).mul(wind_down.tranche_AA_interest);
    wind_down.tranche_S_share_of_A_interest  = (tranche_total_vdsec_A[epoch][uint256(Tranche.S)].div(tranche_total_dsec[epoch][uint256(Tranche.A)])).mul(wind_down.tranche_A_interest);
    wind_down.tranche_S_interest  = wind_down.tranche_S_share_of_AA_interest.add(wind_down.tranche_S_share_of_A_interest);
    wind_down.tranche_AA_interest = wind_down.tranche_AA_interest.sub(wind_down.tranche_S_share_of_AA_interest);
    wind_down.tranche_A_interest  = wind_down.tranche_A_interest.sub(wind_down.tranche_S_share_of_A_interest);

    tranche_interest_earned[epoch][uint256(Tranche.S)]  = wind_down.tranche_S_interest;  // v0: Tranche S owns all interest
    tranche_interest_earned[epoch][uint256(Tranche.AA)] = wind_down.tranche_AA_interest; // v0: Should always be 0
    tranche_interest_earned[epoch][uint256(Tranche.A)]  = wind_down.tranche_A_interest;  // v0: Should always be 0

    emit WindDownEpochState(epoch, wind_down.tranche_S_interest, wind_down.tranche_AA_interest, wind_down.tranche_A_interest, uint256(tranche_SFI_earnings.S), uint256(tranche_SFI_earnings.AA), uint256(tranche_SFI_earnings.A));

    tranche_SFI_earned[epoch][uint256(Tranche.S)]  = tranche_SFI_earnings.S.add(tranche_total_vdsec_AA[epoch][uint256(Tranche.S)].div(tranche_total_dsec[epoch][uint256(Tranche.AA)]).mul(tranche_SFI_earnings.AA)).add(tranche_total_vdsec_A[epoch][uint256(Tranche.S)].div(tranche_total_dsec[epoch][uint256(Tranche.A)]).mul(tranche_SFI_earnings.A));
    tranche_SFI_earned[epoch][uint256(Tranche.AA)] = tranche_SFI_earnings.AA.sub(tranche_total_vdsec_AA[epoch][uint256(Tranche.S)].div(tranche_total_dsec[epoch][uint256(Tranche.AA)]).mul(tranche_SFI_earnings.AA));
    tranche_SFI_earned[epoch][uint256(Tranche.A)]  = tranche_SFI_earnings.A.sub(tranche_total_vdsec_A[epoch][uint256(Tranche.S)].div(tranche_total_dsec[epoch][uint256(Tranche.A)]).mul(tranche_SFI_earnings.A));

    emit WindDownEpochState(epoch, wind_down.tranche_S_interest, wind_down.tranche_AA_interest, wind_down.tranche_A_interest, uint256(tranche_SFI_earned[epoch][uint256(Tranche.S)]), uint256(tranche_SFI_earned[epoch][uint256(Tranche.AA)]), uint256(tranche_SFI_earned[epoch][uint256(Tranche.A)]));
    epoch_wound_down[epoch] = true;

    SFI(SFI_address).mint_SFI(address(this), wind_down.SFI_rewards);
    delete wind_down;

    uint256 team_sfi = (10000 * 1 ether) >> epoch; // v1: add plateau for ongoing generation
    SFI(SFI_address).mint_SFI(team_address, team_sfi);
  }

  event RemoveLiquidityDsec(uint256 dsec_percent, uint256 interest_owned, uint256 SFI_owned);
  event RemoveLiquidityPrincipal(uint256 principal);
  function remove_liquidity(address v1_dsec_token_address, uint256 dsec_amount, address v1_principal_token_address, uint256 principal_amount) external override {
    require(dsec_amount > 0 || principal_amount > 0, "can't remove 0");
    ISaffronAdapter best_adapter = ISaffronAdapter(best_adapter_address);
    uint256 interest_owned;
    uint256 SFI_owned;
    uint256 dsec_percent;

    if (v1_dsec_token_address != address(0x0) && dsec_amount > 0) {
      SaffronV1TokenInfo memory sv1_info = saffron_v1_token_info[v1_dsec_token_address];
      require(sv1_info.exists, "balance token lookup failed");
      require(sv1_info.tranche == Tranche.S, "v0: tranche must be S");

      uint256 token_epoch = sv1_info.epoch;
      require(sv1_info.token_type == LPTokenType.dsec, "bad dsec address");
      require(token_epoch == 0, "v0: bal token epoch must be 1");
      require(epoch_wound_down[token_epoch], "can't remove from wound up epoch");

      dsec_percent = dsec_amount.mul(1 ether).div(tranche_total_dsec[token_epoch][uint256(Tranche.S)]);
      interest_owned = tranche_interest_earned[token_epoch][uint256(Tranche.S)].mul(dsec_percent) / 1 ether;
      SFI_owned = tranche_SFI_earned[token_epoch][uint256(Tranche.S)].mul(dsec_percent) / 1 ether;

      tranche_interest_earned[token_epoch][uint256(Tranche.S)] = tranche_interest_earned[token_epoch][uint256(Tranche.S)].sub(interest_owned);
      tranche_SFI_earned[token_epoch][uint256(Tranche.S)] = tranche_SFI_earned[token_epoch][uint256(Tranche.S)].sub(SFI_owned);
      tranche_total_dsec[token_epoch][uint256(Tranche.S)] = tranche_total_dsec[token_epoch][uint256(Tranche.S)].sub(dsec_amount);
      pool_interest = pool_interest.sub(interest_owned);
    }

    if (v1_principal_token_address != address(0x0) && principal_amount > 0) {
      SaffronV1TokenInfo memory sv1_info = saffron_v1_token_info[v1_principal_token_address];
      require(sv1_info.exists, "balance token info lookup failed");
      require(sv1_info.tranche == Tranche.S, "v0: tranche must be S");

      uint256 token_epoch = sv1_info.epoch;
      require(sv1_info.token_type == LPTokenType.principal, "bad balance token address");
      require(token_epoch == 0, "v0: bal token epoch must be 1");
      require(epoch_wound_down[token_epoch], "can't remove from wound up epoch");

      tranche_total_principal[token_epoch][uint256(Tranche.S)] = tranche_total_principal[token_epoch][uint256(Tranche.S)].sub(principal_amount);
      epoch_principal[token_epoch] = epoch_principal[token_epoch].sub(principal_amount);
      pool_principal = pool_principal.sub(principal_amount);
      adapter_total_principal = adapter_total_principal.sub(principal_amount);
    }

    if (v1_dsec_token_address != address(0x0) && dsec_amount > 0) {
      SaffronLPBalanceToken sbt = SaffronLPBalanceToken(v1_dsec_token_address);
      require(sbt.balanceOf(msg.sender) >= dsec_amount, "insufficient dsec balance");
      sbt.burn(msg.sender, dsec_amount);
      best_adapter.return_capital(interest_owned, msg.sender);
      IERC20(SFI_address).safeTransfer(msg.sender, SFI_owned);
      emit RemoveLiquidityDsec(dsec_percent, interest_owned, SFI_owned);
    }
    if (v1_principal_token_address != address(0x0) && principal_amount > 0) {
      SaffronLPBalanceToken sbt = SaffronLPBalanceToken(v1_principal_token_address);
      require(sbt.balanceOf(msg.sender) >= principal_amount, "insufficient principal balance");
      sbt.burn(msg.sender, principal_amount);
      best_adapter.return_capital(principal_amount, msg.sender);
      emit RemoveLiquidityPrincipal(principal_amount);
    }

    require((v1_dsec_token_address != address(0x0) && dsec_amount > 0) || (v1_principal_token_address != address(0x0) && principal_amount > 0), "no action performed");
  }

  event StrategicDeploy(address adapter_address, uint256 amount, uint256 epoch);
  function hourly_strategy(address adapter_address) external override {
    require(msg.sender == address(strategy), "must be strategy");
    require(!_shutdown, "pool shutdown");
    uint256 epoch = get_current_epoch();
    best_adapter_address = adapter_address;
    ISaffronAdapter best_adapter = ISaffronAdapter(adapter_address);
    uint256 amount = IERC20(base_asset_address).balanceOf(address(this));

    uint256 new_A_amount = eternal_unutilized_balances.S / (tranche_A_multiplier+1);
    uint256 new_AA_amount = eternal_unutilized_balances.S - new_A_amount;

    eternal_unutilized_balances.S = 0;
    eternal_utilized_balances.AA = eternal_utilized_balances.AA.add(new_AA_amount);
    eternal_utilized_balances.A = eternal_utilized_balances.A.add(new_A_amount);

    tranche_total_vdsec_AA[epoch][uint256(Tranche.S)] = tranche_total_vdsec_AA[epoch][uint256(Tranche.S)].add(get_seconds_until_epoch_end(epoch).mul(new_AA_amount)); // Total AA vdsec owned by tranche S
    tranche_total_vdsec_A[epoch][uint256(Tranche.S)]  = tranche_total_vdsec_A[epoch][uint256(Tranche.S)].add(get_seconds_until_epoch_end(epoch).mul(new_A_amount));   // Total A vdsec owned by tranche S

    tranche_total_dsec[epoch][uint256(Tranche.AA)] = tranche_total_dsec[epoch][uint256(Tranche.AA)].add(get_seconds_until_epoch_end(epoch).mul(new_AA_amount)); // Total dsec for tranche AA
    tranche_total_dsec[epoch][uint256(Tranche.A)]  = tranche_total_dsec[epoch][uint256(Tranche.A)].add(get_seconds_until_epoch_end(epoch).mul(new_A_amount));   // Total dsec for tranche A

    tranche_total_principal[epoch][uint256(Tranche.AA)] = tranche_total_principal[epoch][uint256(Tranche.AA)].add(new_AA_amount); // Add total principal for AA
    tranche_total_principal[epoch][uint256(Tranche.A)]  = tranche_total_principal[epoch][uint256(Tranche.A)].add(new_A_amount);   // Add total principal for A

    emit StrategicDeploy(adapter_address, amount, epoch);

    adapter_total_principal = adapter_total_principal.add(amount);
    IERC20(base_asset_address).safeTransfer(adapter_address, amount);
    best_adapter.deploy_capital(amount);
  }

  function shutdown() external override {
    require(msg.sender == address(strategy), "must be strategy");
    require(block.timestamp > get_epoch_end(0) - 1 days, "trying to shutdown too early");
    _shutdown = true;
  }

  function set_governance(address to) external override {
    require(msg.sender == governance, "must be governance");
    governance = to;
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

  function get_epoch_cycle_params() external view override returns (uint256, uint256) {
    return (epoch_cycle.start_date, epoch_cycle.duration);
  }

  function get_base_asset_address() external override view returns (address) {
    return base_asset_address;
  }

  function get_governance() external override view returns (address) {
    return governance;
  }

  function get_strategy_address() external override view returns (address) {
    return address(strategy);
  }

  function delete_adapters() external override {
    require(msg.sender == governance, "must be governance");
    delete adapters;
  }

  event ErcSwept(address who, address to, address token, uint256 amount);
  function erc_sweep(address _token, address _to) public {
    require(msg.sender == governance, "must be governance");
    require(_token != base_asset_address, "cannot sweep pool assets");

    IERC20 tkn = IERC20(_token);
    uint256 tBal = tkn.balanceOf(address(this));
    tkn.safeTransfer(_to, tBal);

    emit ErcSwept(msg.sender, _to, _token, tBal);
  }
}