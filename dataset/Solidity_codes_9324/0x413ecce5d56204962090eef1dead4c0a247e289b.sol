
pragma solidity >=0.6.0 <0.8.0;

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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity >=0.6.0 <0.8.0;


interface IEmergency {
    function emergencyWithdraw(IERC20 token) external ;
}// MIT
pragma solidity >=0.6.0 <0.8.0;


interface IEIP2612 is IERC20 {
  function DOMAIN_SEPARATOR() external view returns (bytes32);
  function nonces(address owner) external view returns (uint256);
  function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
}// MIT
pragma solidity >=0.6.0 <0.8.0;


interface ILon is IEmergency, IEIP2612 {
  function cap() external view returns(uint256);

  function mint(address to, uint256 amount) external; 

  function burn(uint256 amount) external;
}// MIT




pragma solidity >=0.6.0 <0.8.0;


contract ERC20ForUpgradeable is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function _initializeERC20 (string memory name_, string memory symbol_) internal {
        require(
            (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked(""))) &&
            (keccak256(abi.encodePacked(_symbol)) == keccak256(abi.encodePacked(""))),
            "ERC20 already initialized"
        );

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

abstract contract OwnableForUpgradeable {
    address public owner;
    address public nominatedOwner;

    function _initializeOwnable(address _owner) internal {
        require(owner == address(0), "Ownable already initialized");

        owner = _owner;
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "not nominated");
        emit OwnerChanged(owner, nominatedOwner);

        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    function renounceOwnership() external onlyOwner {
        emit OwnerChanged(owner, address(0));
        owner = address(0);
    }

    function nominateNewOwner(address newOwner) external onlyOwner {
        nominatedOwner = newOwner;
        emit OwnerNominated(newOwner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }

    event OwnerNominated(address indexed newOwner);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
}// MIT
pragma solidity >=0.6.0 <0.8.0;



contract LONStaking is ERC20ForUpgradeable, OwnableForUpgradeable, ReentrancyGuard, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for ILon;
    using SafeERC20 for IERC20;

    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    uint256 private constant BPS_MAX = 10000;

    ILon public lonToken;
    bytes32 public DOMAIN_SEPARATOR;
    uint256 public BPS_RAGE_EXIT_PENALTY;
    uint256 public COOLDOWN_SECONDS;
    uint256 public COOLDOWN_IN_DAYS;
    mapping(address => uint256) public nonces; // For EIP-2612 permit()
    mapping(address => uint256) public stakersCooldowns;


    event Staked(address indexed user, uint256 amount, uint256 share);
    event Cooldown(address indexed user);
    event Redeem(address indexed user, uint256 share, uint256 redeemAmount, uint256 penaltyAmount);
    event Recovered(address token, uint256 amount);
    event SetCooldownAndRageExitParam(uint256 coolDownInDays, uint256 bpsRageExitPenalty);


    function initialize(
        ILon _lonToken,
        address _owner,
        uint256 _COOLDOWN_IN_DAYS,
        uint256 _BPS_RAGE_EXIT_PENALTY
    ) external {
        lonToken = _lonToken;

        _initializeOwnable(_owner);
        _initializeERC20("Wrapped Tokenlon", "xLON");

        require(_COOLDOWN_IN_DAYS >= 1, "COOLDOWN_IN_DAYS less than 1 day");
        require(_BPS_RAGE_EXIT_PENALTY <= BPS_MAX, "BPS_RAGE_EXIT_PENALTY larger than BPS_MAX");
        COOLDOWN_IN_DAYS = _COOLDOWN_IN_DAYS;
        COOLDOWN_SECONDS = _COOLDOWN_IN_DAYS * 86400;
        BPS_RAGE_EXIT_PENALTY = _BPS_RAGE_EXIT_PENALTY;

        uint256 chainId ;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR =  keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name())),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }



    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    function setCooldownAndRageExitParam(uint256 _COOLDOWN_IN_DAYS, uint256 _BPS_RAGE_EXIT_PENALTY) public onlyOwner {
        require(_COOLDOWN_IN_DAYS >= 1, "COOLDOWN_IN_DAYS less than 1 day");
        require(_BPS_RAGE_EXIT_PENALTY <= BPS_MAX, "BPS_RAGE_EXIT_PENALTY larger than BPS_MAX");

        COOLDOWN_IN_DAYS = _COOLDOWN_IN_DAYS;
        COOLDOWN_SECONDS = _COOLDOWN_IN_DAYS * 86400;
        BPS_RAGE_EXIT_PENALTY = _BPS_RAGE_EXIT_PENALTY;
        emit SetCooldownAndRageExitParam(_COOLDOWN_IN_DAYS, _BPS_RAGE_EXIT_PENALTY);
    }



    function recoverERC20(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
        require(_tokenAddress != address(lonToken), "cannot withdraw lon token");
        IERC20(_tokenAddress).safeTransfer(owner, _tokenAmount);
        emit Recovered(_tokenAddress, _tokenAmount);
    }


    function cooldownRemainSeconds(address _account) external view returns (uint256) {
        uint256 cooldownTimestamp = stakersCooldowns[_account];
        if (
            (cooldownTimestamp == 0) ||
            (cooldownTimestamp.add(COOLDOWN_SECONDS) <= block.timestamp)
        ) return 0;

        return cooldownTimestamp.add(COOLDOWN_SECONDS).sub(block.timestamp);
    }

    function previewRageExit(address _account) external view returns (uint256 receiveAmount, uint256 penaltyAmount) {
        uint256 cooldownEndTimestamp = stakersCooldowns[_account].add(COOLDOWN_SECONDS);
        uint256 totalLon = lonToken.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        uint256 share = balanceOf(_account);
        uint256 userTotalAmount = share.mul(totalLon).div(totalShares);

        if (block.timestamp > cooldownEndTimestamp) {
            receiveAmount = userTotalAmount;
            penaltyAmount = 0;
        } else {
            uint256 timeDiffInDays = Math.min(
                COOLDOWN_IN_DAYS,
                (cooldownEndTimestamp.sub(block.timestamp)).div(86400).add(1)
            );
            uint256 penaltyShare = share.mul(timeDiffInDays).mul(BPS_RAGE_EXIT_PENALTY).div(BPS_MAX).div(COOLDOWN_IN_DAYS);
            receiveAmount = share.sub(penaltyShare).mul(totalLon).div(totalShares);
            penaltyAmount = userTotalAmount.sub(receiveAmount);
        }
    }


    function _getNextCooldownTimestamp(
        uint256 _fromCooldownTimestamp,
        uint256 _amountToReceive,
        address _toAddress,
        uint256 _toBalance
    ) internal returns (uint256) {
        uint256 toCooldownTimestamp = stakersCooldowns[_toAddress];
        if (toCooldownTimestamp == 0) {
            return 0;
        }

        uint256 fromCooldownTimestamp;
        if (_fromCooldownTimestamp == 0) {
            fromCooldownTimestamp = block.timestamp;
        } else {
            fromCooldownTimestamp = _fromCooldownTimestamp;
        }

        if (fromCooldownTimestamp <= toCooldownTimestamp) {
            return toCooldownTimestamp;
        } else {

            if (fromCooldownTimestamp.sub(toCooldownTimestamp) > COOLDOWN_SECONDS) {
                toCooldownTimestamp = fromCooldownTimestamp.sub(COOLDOWN_SECONDS);
            }

            toCooldownTimestamp = (
                _amountToReceive.mul(fromCooldownTimestamp).add(_toBalance.mul(toCooldownTimestamp))
            ).div(_amountToReceive.add(_toBalance));
            return toCooldownTimestamp;
        }
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _amount
    ) internal override whenNotPaused {
        uint256 balanceOfFrom = balanceOf(_from);
        uint256 balanceOfTo = balanceOf(_to);
        uint256 previousSenderCooldown = stakersCooldowns[_from];
        if (_from != _to) {
            stakersCooldowns[_to] = _getNextCooldownTimestamp(
                previousSenderCooldown,
                _amount,
                _to,
                balanceOfTo
            );
            if (balanceOfFrom == _amount && previousSenderCooldown != 0) {
                stakersCooldowns[_from] = 0;
            }
        }

        super._transfer(_from, _to, _amount);
    }

    function permit(address _owner, address _spender, uint256 _value, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) external {
        require(_owner != address(0), "owner is zero address");
        require(block.timestamp <= _deadline || _deadline == 0, "permit expired");

        bytes32 digest = keccak256(
            abi.encodePacked(
                uint16(0x1901),
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, _owner, _spender, _value, nonces[_owner]++, _deadline))
            )
        );

        require(_owner == ecrecover(digest, _v, _r, _s), "invalid signature");
        _approve(_owner, _spender, _value);
    }

    function _stake(address _account, uint256 _amount) internal {
        require(_amount > 0, "cannot stake 0 amount");

        uint256 totalLon = lonToken.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        uint256 share;
        if (totalShares == 0 || totalLon == 0) {
            share = _amount;
        } else {
            share = _amount.mul(totalShares).div(totalLon);
        }
        stakersCooldowns[_account] = _getNextCooldownTimestamp(
            block.timestamp,
            share,
            _account,
            balanceOf(_account)
        );

        _mint(_account, share);
        emit Staked(_account, _amount, share);
    }

    function stake(uint256 _amount) public nonReentrant whenNotPaused {
        _stake(msg.sender, _amount);
        lonToken.transferFrom(msg.sender, address(this), _amount);
    }

    function stakeWithPermit(uint256 _amount, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s) public nonReentrant whenNotPaused {
        _stake(msg.sender, _amount);
        lonToken.permit(msg.sender, address(this), _amount, _deadline, _v, _r, _s);
        lonToken.transferFrom(msg.sender, address(this), _amount);
    }

    function unstake() public {
        require(balanceOf(msg.sender) > 0, "no share to unstake");
        require(stakersCooldowns[msg.sender] == 0, "already unstake");

        stakersCooldowns[msg.sender] = block.timestamp;
        emit Cooldown(msg.sender);
    }

    function _redeem(uint256 _share, uint256 _penalty) internal {
        require(_share != 0, "cannot redeem 0 share");

        uint256 totalLon = lonToken.balanceOf(address(this));
        uint256 totalShares = totalSupply();

        uint256 userTotalAmount = _share.add(_penalty).mul(totalLon).div(totalShares);
        uint256 redeemAmount = _share.mul(totalLon).div(totalShares);
        uint256 penaltyAmount = userTotalAmount.sub(redeemAmount);
        _burn(msg.sender, _share.add(_penalty));
        if (balanceOf(msg.sender) == 0) {
            stakersCooldowns[msg.sender] = 0;
        }

        lonToken.transfer(msg.sender, redeemAmount);

        emit Redeem(msg.sender, _share, redeemAmount, penaltyAmount);
    }

    function redeem(uint256 _share) public nonReentrant {
        uint256 cooldownStartTimestamp = stakersCooldowns[msg.sender];
        require(cooldownStartTimestamp > 0, "not yet unstake");

        require(
            block.timestamp > cooldownStartTimestamp.add(COOLDOWN_SECONDS),
            "Still in cooldown"
        );

        _redeem(_share, 0);
    }

    function rageExit() public nonReentrant {
        uint256 cooldownStartTimestamp = stakersCooldowns[msg.sender];
        require(cooldownStartTimestamp > 0, "not yet unstake");

        uint256 cooldownEndTimestamp = cooldownStartTimestamp.add(COOLDOWN_SECONDS);
        uint256 share = balanceOf(msg.sender);
        if (block.timestamp > cooldownEndTimestamp) {
            _redeem(share, 0);
        } else {
            uint256 timeDiffInDays = Math.min(
                COOLDOWN_IN_DAYS,
                (cooldownEndTimestamp.sub(block.timestamp)).div(86400).add(1)
            );
            uint256 penalty = share.mul(timeDiffInDays).mul(BPS_RAGE_EXIT_PENALTY).div(BPS_MAX).div(COOLDOWN_IN_DAYS);
            _redeem(share.sub(penalty), penalty);
        }
    }
}