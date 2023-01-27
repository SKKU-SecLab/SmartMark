

pragma solidity 0.8.6;

interface IVaultController {

  function depositsEnabled() external view returns(bool);

  function depositLimit(address _vault) external view returns(uint);

  function setRebalancer(address _rebalancer) external;

  function rebalancer() external view returns(address);

}

interface IVaultRebalancer {

  function unload(address _vault, address _pair, uint _amount) external;

  function distributeIncome(address _vault) external;

}

interface IERC20 {

  function totalSupply() external view returns (uint);

  function balanceOf(address account) external view returns (uint);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint);

  function approve(address spender, uint amount) external returns (bool);

  function mint(address account, uint amount) external;

  function burn(address account, uint amount) external;

  function transferFrom(address sender, address recipient, uint amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract ERC20 {


  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);

  mapping (address => uint) public balanceOf;
  mapping (address => mapping (address => uint)) public allowance;

  string public name;
  string public symbol;
  uint8  public decimals;
  uint   public totalSupply;

  constructor(
    string memory _name,
    string memory _symbol,
    uint8 _decimals
  ) {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    require(_decimals > 0, "decimals");
  }

  function transfer(address _recipient, uint _amount) external returns (bool) {

    _transfer(msg.sender, _recipient, _amount);
    return true;
  }

  function approve(address _spender, uint _amount) external returns (bool) {

    _approve(msg.sender, _spender, _amount);
    return true;
  }

  function transferFrom(address _sender, address _recipient, uint _amount) external returns (bool) {

    require(allowance[_sender][msg.sender] >= _amount, "ERC20: insufficient approval");
    _transfer(_sender, _recipient, _amount);
    _approve(_sender, msg.sender, allowance[_sender][msg.sender] - _amount);
    return true;
  }

  function _transfer(address _sender, address _recipient, uint _amount) internal virtual {

    require(_sender != address(0), "ERC20: transfer from the zero address");
    require(_recipient != address(0), "ERC20: transfer to the zero address");
    require(balanceOf[_sender] >= _amount, "ERC20: insufficient funds");

    balanceOf[_sender] -= _amount;
    balanceOf[_recipient] += _amount;
    emit Transfer(_sender, _recipient, _amount);
  }

  function _mint(address _account, uint _amount) internal {

    require(_account != address(0), "ERC20: mint to the zero address");

    totalSupply += _amount;
    balanceOf[_account] += _amount;
    emit Transfer(address(0), _account, _amount);
  }

  function _burn(address _account, uint _amount) internal {

    require(_account != address(0), "ERC20: burn from the zero address");

    balanceOf[_account] -= _amount;
    totalSupply -= _amount;
    emit Transfer(_account, address(0), _amount);
  }

  function _approve(address _owner, address _spender, uint _amount) internal {

    require(_owner != address(0), "ERC20: approve from the zero address");
    require(_spender != address(0), "ERC20: approve to the zero address");

    allowance[_owner][_spender] = _amount;
    emit Approval(_owner, _spender, _amount);
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

library Math {


  function max(uint256 a, uint256 b) internal pure returns (uint256) {

    return a >= b ? a : b;
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256) {

    return a < b ? a : b;
  }

  function average(uint256 a, uint256 b) internal pure returns (uint256) {

    return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
  }

  function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b + (a % b == 0 ? 0 : 1);
  }
}

contract ReentrancyGuard {

  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  constructor () {
    _status = _NOT_ENTERED;
  }

  modifier nonReentrant() {

    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    _status = _ENTERED;
    _;
    _status = _NOT_ENTERED;
  }
}

interface IWETH {

  function deposit() external payable;

  function withdraw(uint wad) external;

  function balanceOf(address account) external view returns (uint);

  function transfer(address recipient, uint amount) external returns (bool);

  function approve(address spender, uint amount) external returns (bool);

}

library SafeERC20 {


    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract TransferHelper {


  using SafeERC20 for IERC20;

  IWETH internal constant WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

  function _safeTransferFrom(address _token, address _sender, uint _amount) internal virtual {

    require(_amount > 0, "TransferHelper: amount must be > 0");
    IERC20(_token).safeTransferFrom(_sender, address(this), _amount);
  }

  function _safeTransfer(address _token, address _recipient, uint _amount) internal virtual {

    require(_amount > 0, "TransferHelper: amount must be > 0");
    IERC20(_token).safeTransfer(_recipient, _amount);
  }

  function _wethWithdrawTo(address _to, uint _amount) internal virtual {

    require(_amount > 0, "TransferHelper: amount must be > 0");
    require(_to != address(0), "TransferHelper: invalid recipient");

    WETH.withdraw(_amount);
    (bool success, ) = _to.call { value: _amount }(new bytes(0));
    require(success, 'TransferHelper: ETH transfer failed');
  }

  function _depositWeth() internal {

    require(msg.value > 0, "TransferHelper: amount must be > 0");
    WETH.deposit { value: msg.value }();
  }
}



contract Vault is TransferHelper, ReentrancyGuard, ERC20("X", "X", 18) {


  uint private constant DISTRIBUTION_PERIOD = 45_800; // ~ 7 days

  address public vaultController;
  address public underlying;

  bool private initialized;
  uint private rewardPerToken;
  uint private lastAccrualBlock;
  uint private lastIncomeBlock;
  uint private rewardRateStored;

  mapping (address => uint) private rewardSnapshot;

  event Claim(address indexed account, uint amount);
  event NewIncome(uint addAmount, uint rewardRate);
  event NewRebalancer(address indexed rebalancer);
  event Deposit(uint amount);
  event Withdraw(uint amount);

  modifier onlyRebalancer() {

    require(msg.sender == address(rebalancer()), "Vault: caller is not the rebalancer");
    _;
  }

  receive() external payable {}

  function initialize(
    address       _vaultController,
    address       _underlying,
    string memory _name,
    string memory _symbol,
    uint8         _decimals
  ) external {


    require(initialized != true, "Vault: already intialized");
    initialized = true;

    vaultController = _vaultController;
    underlying      = _underlying;

    require(_decimals > 0, "Vault: decimals");
    name     = _name;
    symbol   = _symbol;
    decimals = _decimals;
  }

  function depositETH(address _account) external payable nonReentrant {

    _checkEthVault();
    _depositWeth();
    _deposit(_account, msg.value);
  }

  function deposit(
    address _account,
    uint    _amount
  ) external nonReentrant {

    _safeTransferFrom(underlying, msg.sender, _amount);
    _deposit(_account, _amount);
  }

  function withdraw(uint _amount) external nonReentrant {

    _withdraw(msg.sender, _amount);
    _safeTransfer(underlying, msg.sender, _amount);
  }

  function withdrawAll() external nonReentrant {

    uint amount = _withdrawAll(msg.sender);
    _safeTransfer(underlying, msg.sender, amount);
  }

  function withdrawAllETH() external nonReentrant {

    _checkEthVault();
    uint amount = _withdrawAll(msg.sender);
    _wethWithdrawTo(msg.sender, amount);
  }

  function withdrawETH(uint _amount) external nonReentrant {

    _checkEthVault();
    _withdraw(msg.sender, _amount);
    _wethWithdrawTo(msg.sender, _amount);
  }

  function withdrawFrom(
    address _source,
    uint    _amount
  ) external nonReentrant {

    _withdrawFrom(_source, _amount);
    _safeTransfer(underlying, msg.sender, _amount);
  }

  function withdrawFromETH(
    address _source,
    uint    _amount
  ) external nonReentrant {

    _checkEthVault();
    _withdrawFrom(_source, _amount);
    _wethWithdrawTo(msg.sender, _amount);
  }

  function claim(address _account) public {

    _accrue();
    uint pendingReward = pendingAccountReward(_account);

    if(pendingReward > 0) {
      _mint(_account, pendingReward);
      emit Claim(_account, pendingReward);
    }

    rewardSnapshot[_account] = rewardPerToken;
  }

  function addIncome(uint _addAmount) external onlyRebalancer {

    _accrue();
    _safeTransferFrom(underlying, msg.sender, _addAmount);

    uint blocksElapsed  = Math.min(DISTRIBUTION_PERIOD, block.number - lastIncomeBlock);
    uint unvestedIncome = rewardRateStored * (DISTRIBUTION_PERIOD - blocksElapsed);

    rewardRateStored = (unvestedIncome + _addAmount) / DISTRIBUTION_PERIOD;
    lastIncomeBlock  = block.number;

    emit NewIncome(_addAmount, rewardRateStored);
  }

  function pushToken(
    address _token,
    uint    _amount
  ) external onlyRebalancer {

    _safeTransfer(_token, address(rebalancer()), _amount);
  }

  function pendingAccountReward(address _account) public view returns(uint) {

    uint pedingRewardPerToken = rewardPerToken + _pendingRewardPerToken();
    uint rewardPerTokenDelta  = pedingRewardPerToken - rewardSnapshot[_account];
    return rewardPerTokenDelta * balanceOf[_account] / 1e18;
  }

  function rewardRate() public view returns(uint) {

    uint blocksElapsed = block.number - lastIncomeBlock;

    if (blocksElapsed < DISTRIBUTION_PERIOD) {
      return rewardRateStored;
    } else {
      return 0;
    }
  }

  function rebalancer() public view returns(IVaultRebalancer) {

    return IVaultRebalancer(IVaultController(vaultController).rebalancer());
  }

  function _accrue() internal {

    rewardPerToken  += _pendingRewardPerToken();
    lastAccrualBlock = block.number;
  }

  function _deposit(address _account, uint _amount) internal {

    _checkDepositLimit();
    claim(_account);
    _mint(_account, _amount);
    emit Deposit(_amount);
  }

  function _withdraw(address _account, uint _amount) internal {

    claim(_account);
    _burn(msg.sender, _amount);
    emit Withdraw(_amount);
  }

  function _withdrawAll(address _account) internal returns(uint) {

    claim(_account);
    uint amount = balanceOf[_account];
    _burn(_account, amount);
    emit Withdraw(amount);

    return amount;
  }

  function _withdrawFrom(address _source, uint _amount) internal {

    uint selfBalance = IERC20(underlying).balanceOf(address(this));
    require(selfBalance < _amount, "Vault: unload not required");
    rebalancer().unload(address(this), _source, _amount - selfBalance);
    _withdraw(msg.sender, _amount);
  }

  function _transfer(
    address _sender,
    address _recipient,
    uint    _amount
  ) internal override {

    claim(_sender);
    claim(_recipient);
    super._transfer(_sender, _recipient, _amount);
  }

  function _pendingRewardPerToken() internal view returns(uint) {

    if (lastAccrualBlock == 0 || totalSupply == 0) {
      return 0;
    }

    uint blocksElapsed = block.number - lastAccrualBlock;
    return blocksElapsed * rewardRate() * 1e18 / totalSupply;
  }

  function _checkEthVault() internal view {

    require(
      underlying == address(WETH),
      "Vault: not ETH vault"
    );
  }

  function _checkDepositLimit() internal view {


    IVaultController vController = IVaultController(vaultController);
    uint depositLimit = vController.depositLimit(address(this));

    require(vController.depositsEnabled(), "Vault: deposits disabled");

    if (depositLimit > 0) {
      require(totalSupply <= depositLimit, "Vault: deposit limit reached");
    }
  }
}