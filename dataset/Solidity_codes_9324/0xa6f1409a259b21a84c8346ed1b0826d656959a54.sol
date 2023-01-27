
pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT
pragma solidity >=0.4.22 <0.8.0;


interface IYearn is IERC20 {
  function calcPoolValueInToken() external view returns (uint256);
  function deposit(uint256 _amount) external;
  function withdraw(uint256 _shares) external;
}// MIT
pragma solidity >=0.4.22 <0.8.0;


interface IYvault is IERC20 {
  function balance() external view returns (uint256);
  function deposit(uint256 _amount) external;
  function withdraw(uint256 _shares) external;
}// MIT
pragma solidity 0.7.6;

interface IDaoVault {
  function totalSupply() external view returns (uint256);
  function balanceOf(address _address) external view returns (uint256); 
}// MIT
pragma solidity 0.7.6;



contract YearnFarmerTUSDv2 is ERC20, Ownable {

  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  IERC20 public token;
  IYearn public earn;
  IYvault public vault;
  uint256 private constant MAX_UNIT = 2**256 - 2;
  mapping (address => uint256) private earnDepositBalance;
  mapping (address => uint256) private vaultDepositBalance;
  uint256 public pool;

  address public treasuryWallet = 0x59E83877bD248cBFe392dbB5A8a29959bcb48592;
  address public communityWallet = 0xdd6c35aFF646B2fB7d8A8955Ccbe0994409348d0;

  uint256[] public networkFeeTier2 = [50000e18+1, 100000e18]; // Represent [tier2 minimun, tier2 maximun], initial value represent Tier 2 from 50001 to 100000
  uint256 public customNetworkFeeTier = 1000000e18;

  uint256 public constant DENOMINATOR = 10000;
  uint256[] public networkFeePercentage = [100, 75, 50]; // Represent [Tier 1, Tier 2, Tier 3], initial value represent [1%, 0.75%, 0.5%]
  uint256 public customNetworkFeePercentage = 25;
  uint256 public profileSharingFeePercentage = 1000;
  uint256 public constant treasuryFee = 5000; // 50% on profile sharing fee
  uint256 public constant communityFee = 5000; // 50% on profile sharing fee

  bool public isVesting;
  IDaoVault public daoVault;

  event SetTreasuryWallet(address indexed oldTreasuryWallet, address indexed newTreasuryWallet);
  event SetCommunityWallet(address indexed oldCommunityWallet, address indexed newCommunityWallet);
  event SetNetworkFeeTier2(uint256[] oldNetworkFeeTier2, uint256[] newNetworkFeeTier2);
  event SetNetworkFeePercentage(uint256[] oldNetworkFeePercentage, uint256[] newNetworkFeePercentage);
  event SetCustomNetworkFeeTier(uint256 indexed oldCustomNetworkFeeTier, uint256 indexed newCustomNetworkFeeTier);
  event SetCustomNetworkFeePercentage(uint256 indexed oldCustomNetworkFeePercentage, uint256 indexed newCustomNetworkFeePercentage);
  event SetProfileSharingFeePercentage(uint256 indexed oldProfileSharingFeePercentage, uint256 indexed newProfileSharingFeePercentage);

  constructor(address _token, address _earn, address _vault)
    ERC20("Yearn Farmer v2 TUSD", "yfTUSDv2") {
      _setupDecimals(18);
      
      token = IERC20(_token);
      earn = IYearn(_earn);
      vault = IYvault(_vault);

      _approvePooling();
  }

  function setVault(address _address) external onlyOwner {
    require(address(daoVault) == address(0), "Vault set");

    daoVault = IDaoVault(_address);
  }

  function setTreasuryWallet(address _treasuryWallet) external onlyOwner {
    address oldTreasuryWallet = treasuryWallet;
    treasuryWallet = _treasuryWallet;
    emit SetTreasuryWallet(oldTreasuryWallet, _treasuryWallet);
  }

  function setCommunityWallet(address _communityWallet) external onlyOwner {
    address oldCommunityWallet = communityWallet;
    communityWallet = _communityWallet;
    emit SetCommunityWallet(oldCommunityWallet, _communityWallet);
  }

  function setNetworkFeeTier2(uint256[] calldata _networkFeeTier2) external onlyOwner {
    require(_networkFeeTier2[0] != 0, "Minimun amount cannot be 0");
    require(_networkFeeTier2[1] > _networkFeeTier2[0], "Maximun amount must greater than minimun amount");
    uint256[] memory oldNetworkFeeTier2 = networkFeeTier2;
    networkFeeTier2 = _networkFeeTier2;
    emit SetNetworkFeeTier2(oldNetworkFeeTier2, _networkFeeTier2);
  }

  function setNetworkFeePercentage(uint256[] calldata _networkFeePercentage) external onlyOwner {
    require(
      _networkFeePercentage[0] < 4000 &&
      _networkFeePercentage[1] < 4000 &&
      _networkFeePercentage[2] < 4000, "Network fee percentage cannot be more than 40%"
    );

    uint256[] memory oldNetworkFeePercentage = networkFeePercentage;
    networkFeePercentage = _networkFeePercentage;
    emit SetNetworkFeePercentage(oldNetworkFeePercentage, _networkFeePercentage);
  }

  function setCustomNetworkFeeTier(uint256 _customNetworkFeeTier) external onlyOwner {
    require(_customNetworkFeeTier > networkFeeTier2[1], "Custom network fee tier must greater than tier 2");

    uint256 oldCustomNetworkFeeTier = customNetworkFeeTier;
    customNetworkFeeTier = _customNetworkFeeTier;
    emit SetCustomNetworkFeeTier(oldCustomNetworkFeeTier, _customNetworkFeeTier);
  }

  function setCustomNetworkFeePercentage(uint256 _percentage) public onlyOwner {
    require(_percentage < networkFeePercentage[2], "Custom network fee percentage cannot be more than tier 2");

    uint256 oldCustomNetworkFeePercentage = customNetworkFeePercentage;
    customNetworkFeePercentage = _percentage;
    emit SetCustomNetworkFeePercentage(oldCustomNetworkFeePercentage, _percentage);
  }

  function setProfileSharingFeePercentage(uint256 _percentage) public onlyOwner {
    require(_percentage < 4000, "Profile sharing fee percentage cannot be more than 40%");

    uint256 oldProfileSharingFeePercentage = profileSharingFeePercentage;
    profileSharingFeePercentage = _percentage;
    emit SetProfileSharingFeePercentage(oldProfileSharingFeePercentage, _percentage);
  }

  function _approvePooling() private {
    uint256 earnAllowance = token.allowance(address(this), address(earn));
    if (earnAllowance == uint256(0)) {
      token.safeApprove(address(earn), MAX_UNIT);
    }
    uint256 vaultAllowance = token.allowance(address(this), address(vault));
    if (vaultAllowance == uint256(0)) {
      token.safeApprove(address(vault), MAX_UNIT);
    }
  }

  function getEarnDepositBalance(address _address) external view returns (uint256 result) {
    result = isVesting ? 0 : earnDepositBalance[_address];
  }

  function getVaultDepositBalance(address _address) external view returns (uint256 result) {
    result = isVesting ? 0 : vaultDepositBalance[_address];
  }

  function deposit(uint256[] memory _amounts) public {
    require(!isVesting, "Contract in vesting state");
    require(msg.sender == address(daoVault), "Only can call from Vault");
    require(_amounts[0] > 0 || _amounts[1] > 0, "Amount must > 0");
    
    uint256 _earnAmount = _amounts[0];
    uint256 _vaultAmount = _amounts[1];
    uint256 _depositAmount = _earnAmount.add(_vaultAmount);
    token.safeTransferFrom(tx.origin, address(this), _depositAmount);

    uint256 _earnNetworkFee;
    uint256 _vaultNetworkFee;
    uint256 _networkFeePercentage;
    if (_depositAmount < networkFeeTier2[0]) {
      _networkFeePercentage = networkFeePercentage[0];
    } else if (_depositAmount >= networkFeeTier2[0] && _depositAmount <= networkFeeTier2[1]) {
      _networkFeePercentage = networkFeePercentage[1];
    } else if (_depositAmount >= customNetworkFeeTier) {
      _networkFeePercentage = customNetworkFeePercentage;
    } else {
      _networkFeePercentage = networkFeePercentage[2];
    }

    if (_earnAmount > 0) {
      _earnNetworkFee = _earnAmount.mul(_networkFeePercentage).div(DENOMINATOR);
      _earnAmount = _earnAmount.sub(_earnNetworkFee);
      earn.deposit(_earnAmount);
      earnDepositBalance[tx.origin] = earnDepositBalance[tx.origin].add(_earnAmount);
    }

    if (_vaultAmount > 0) {
      _vaultNetworkFee = _vaultAmount.mul(_networkFeePercentage).div(DENOMINATOR);
      _vaultAmount = _vaultAmount.sub(_vaultNetworkFee);
      vault.deposit(_vaultAmount);
      vaultDepositBalance[tx.origin] = vaultDepositBalance[tx.origin].add(_vaultAmount);
    }

    uint _totalNetworkFee = _earnNetworkFee.add(_vaultNetworkFee);
    token.safeTransfer(treasuryWallet, _totalNetworkFee.mul(treasuryFee).div(DENOMINATOR));
    token.safeTransfer(communityWallet, _totalNetworkFee.mul(treasuryFee).div(DENOMINATOR));

    uint256 _totalAmount = _earnAmount.add(_vaultAmount);
    uint256 _shares;
    _shares = totalSupply() == 0 ? _totalAmount : _totalAmount.mul(totalSupply()).div(pool);
    _mint(address(daoVault), _shares);
    pool = pool.add(_totalAmount);
  }

  function withdraw(uint256[] memory _shares) external {
    require(!isVesting, "Contract in vesting state");
    require(msg.sender == address(daoVault), "Only can call from Vault");

    if (_shares[0] > 0) {
      _withdrawEarn(_shares[0]);
    }

    if (_shares[1] > 0) {
      _withdrawVault(_shares[1]);
    }
  }

  function _withdrawEarn(uint256 _shares) private {
    uint256 _d = pool.mul(_shares).div(totalSupply()); // Initial Deposit Amount
    require(earnDepositBalance[tx.origin] >= _d, "Insufficient balance");
    uint256 _earnShares = (_d.mul(earn.totalSupply())).div(earn.calcPoolValueInToken()); // Find earn shares based on deposit amount 
    uint256 _r = ((earn.calcPoolValueInToken()).mul(_earnShares)).div(earn.totalSupply()); // Actual earn withdraw amount

    earn.withdraw(_earnShares);
    earnDepositBalance[tx.origin] = earnDepositBalance[tx.origin].sub(_d);
    
    _burn(address(daoVault), _shares);
    pool = pool.sub(_d);

    if (_r > _d) {
      uint256 _p = _r.sub(_d); // Profit
      uint256 _fee = _p.mul(profileSharingFeePercentage).div(DENOMINATOR);
      token.safeTransfer(tx.origin, _r.sub(_fee));
      token.safeTransfer(treasuryWallet, _fee.mul(treasuryFee).div(DENOMINATOR));
      token.safeTransfer(communityWallet, _fee.mul(communityFee).div(DENOMINATOR));
    } else {
      token.safeTransfer(tx.origin, _r);
    }
  }

  function _withdrawVault(uint256 _shares) private {
    uint256 _d = pool.mul(_shares).div(totalSupply()); // Initial Deposit Amount
    require(vaultDepositBalance[tx.origin] >= _d, "Insufficient balance");
    uint256 _vaultShares = (_d.mul(vault.totalSupply())).div(vault.balance()); // Find vault shares based on deposit amount 
    uint256 _r = ((vault.balance()).mul(_vaultShares)).div(vault.totalSupply()); // Actual vault withdraw amount

    vault.withdraw(_vaultShares);
    vaultDepositBalance[tx.origin] = vaultDepositBalance[tx.origin].sub(_d);

    _burn(address(daoVault), _shares);
    pool = pool.sub(_d);

    if (_r > _d) {
      uint256 _p = _r.sub(_d); // Profit
      uint256 _fee = _p.mul(profileSharingFeePercentage).div(DENOMINATOR);
      token.safeTransfer(tx.origin, _r.sub(_fee));
      token.safeTransfer(treasuryWallet, _fee.mul(treasuryFee).div(DENOMINATOR));
      token.safeTransfer(communityWallet, _fee.mul(communityFee).div(DENOMINATOR));
    } else {
      token.safeTransfer(tx.origin, _r);
    }
  }

  function vesting() external onlyOwner {
    require(!isVesting, "Already in vesting state");

    isVesting = true;
    uint256 _earnBalance = earn.balanceOf(address(this));
    uint256 _vaultBalance = vault.balanceOf(address(this));
    if (_earnBalance > 0) {
      earn.withdraw(_earnBalance);
    }
    if (_vaultBalance > 0) {
      vault.withdraw(_vaultBalance);
    }

    uint256 balance_ = token.balanceOf(address(this));
    if (balance_ > pool) {
      uint256 _profit = balance_.sub(pool);
      uint256 _fee = _profit.mul(profileSharingFeePercentage).div(DENOMINATOR);
      token.safeTransfer(treasuryWallet, _fee.mul(treasuryFee).div(DENOMINATOR));
      token.safeTransfer(communityWallet, _fee.mul(communityFee).div(DENOMINATOR));
    }
    pool = 0;
  }

  function getSharesValue(address _address) external view returns (uint256) {
    if (!isVesting) {
      return 0;
    } else {
      uint256 _shares = daoVault.balanceOf(_address);
      if (_shares > 0) {
        return token.balanceOf(address(this)).mul(_shares).div(daoVault.totalSupply());
      } else {
        return 0;
      }
    }
  }

  function refund(uint256 _shares) external {
    require(isVesting, "Not in vesting state");
    require(msg.sender == address(daoVault), "Only can call from Vault");

    uint256 _refundAmount = token.balanceOf(address(this)).mul(_shares).div(daoVault.totalSupply());
    token.safeTransfer(tx.origin, _refundAmount);
    _burn(address(daoVault), _shares);
  }

  function approveMigrate() external onlyOwner {
    require(isVesting, "Not in vesting state");

    if (token.allowance(address(this), address(daoVault)) == 0) {
      token.safeApprove(address(daoVault), MAX_UNIT);
    }
  }
}