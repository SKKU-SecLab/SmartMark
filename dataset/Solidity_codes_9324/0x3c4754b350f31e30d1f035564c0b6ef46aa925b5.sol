

pragma solidity 0.6.8;


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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

contract Account is Initializable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event Withdrawn(address indexed tokenAddress, address indexed targetAddress, uint256 amount);

    event Approved(address indexed tokenAddress, address indexed targetAddress, uint256 amount);

    event Invoked(address indexed targetAddress, uint256 value, bytes data);

    address public owner;
    mapping(address => bool) public admins;
    mapping(address => bool) public operators;

    function initialize(address _owner, address[] memory _initialAdmins) public initializer {

        owner = _owner;
        for (uint256 i = 0; i < _initialAdmins.length; i++) {
            admins[_initialAdmins[i]] = true;
        }
    }

    modifier onlyOperator() {

        require(isOperator(msg.sender), "not operator");
        _;
    }

    function transferOwnership(address _owner) public {

        require(msg.sender == owner, "not owner");
        owner = _owner;
    }

    function grantAdmin(address _account) public {

        require(msg.sender == owner, "not owner");
        require(!admins[_account], "already admin");

        admins[_account] = true;
    }

    function revokeAdmin(address _account) public {

        require(msg.sender == owner, "not owner");
        require(admins[_account], "not admin");

        admins[_account] = false;
    }

    function grantOperator(address _account) public {

        require(msg.sender == owner || admins[msg.sender], "not admin");
        require(!operators[_account], "already operator");

        operators[_account] = true;
    }

    function revokeOperator(address _account) public {

        require(msg.sender == owner || admins[msg.sender], "not admin");
        require(operators[_account], "not operator");

        operators[_account] = false;
    }

    receive() payable external {}

    function isOperator(address userAddress) public view returns (bool) {

        return userAddress == owner || admins[userAddress] || operators[userAddress];
    }

    function withdraw(address payable targetAddress, uint256 amount) public onlyOperator {

        targetAddress.transfer(amount);
        emit Withdrawn(address(-1), targetAddress, amount);
    }

    function withdrawToken(address tokenAddress, address targetAddress, uint256 amount) public onlyOperator {

        IERC20(tokenAddress).safeTransfer(targetAddress, amount);
        emit Withdrawn(tokenAddress, targetAddress, amount);
    }

    function withdrawTokenFallThrough(address tokenAddress, address targetAddress, uint256 amount) public onlyOperator {

        uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
        if (tokenBalance >= amount) {
            IERC20(tokenAddress).safeTransfer(targetAddress, amount);
            emit Withdrawn(tokenAddress, targetAddress, amount);
        } else {
            IERC20(tokenAddress).safeTransferFrom(owner, targetAddress, amount.sub(tokenBalance));
            IERC20(tokenAddress).safeTransfer(targetAddress, tokenBalance);
            emit Withdrawn(tokenAddress, targetAddress, amount);
        }
    }

    function approveToken(address tokenAddress, address targetAddress, uint256 amount) public onlyOperator {

        IERC20(tokenAddress).safeApprove(targetAddress, 0);
        if (amount > 0) {
            IERC20(tokenAddress).safeApprove(targetAddress, amount);
        }
        emit Approved(tokenAddress, targetAddress, amount);
    }

    function invoke(address target, uint256 value, bytes memory data) public onlyOperator returns (bytes memory result) {

        bool success;
        (success, result) = target.call{value: value}(data);
        if (!success) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
        emit Invoked(target, value, data);
    }
}

abstract contract Proxy {

  receive () payable external {
    _fallback();
  }

  fallback () payable external {
    _fallback();
  }

  function _implementation() internal virtual view returns (address);

  function _delegate(address implementation) internal {
    assembly {
      calldatacopy(0, 0, calldatasize())

      let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

      returndatacopy(0, 0, returndatasize())

      switch result
      case 0 { revert(0, returndatasize()) }
      default { return(0, returndatasize()) }
    }
  }

  function _willFallback() internal virtual {
  }

  function _fallback() internal {
    _willFallback();
    _delegate(_implementation());
  }
}

contract BaseUpgradeabilityProxy is Proxy {

    event Upgraded(address indexed implementation);

    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _implementation() internal override view returns (address impl) {

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _setImplementation(address newImplementation) internal {

        require(
            Address.isContract(newImplementation),
            "Implementation not set"
        );

        bytes32 slot = IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
        emit Upgraded(newImplementation);
    }
}

contract AdminUpgradeabilityProxy is BaseUpgradeabilityProxy {

  event AdminChanged(address previousAdmin, address newAdmin);


  bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

  constructor(address _logic, address _admin) public payable {
    assert(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1));
    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
    _setImplementation(_logic);
    _setAdmin(_admin);
  }

  modifier ifAdmin() {

    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  function admin() external ifAdmin returns (address) {

    return _admin();
  }

  function implementation() external ifAdmin returns (address) {

    return _implementation();
  }

  function changeAdmin(address newAdmin) external ifAdmin {

    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  function changeImplementation(address newImplementation) external ifAdmin {

    _setImplementation(newImplementation);
  }

  function _admin() internal view returns (address adm) {

    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  function _setAdmin(address newAdmin) internal {

    bytes32 slot = ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }
}

contract AccountFactory {


    event AccountCreated(address indexed userAddress, address indexed accountAddress);

    address public governance;
    address public accountBase;
    mapping(address => address) public accounts;

    constructor(address _accountBase) public {
        require(_accountBase != address(0x0), "account base not set");
        governance = msg.sender;
        accountBase = _accountBase;
    }

    function setAccountBase(address _accountBase) public {

        require(msg.sender == governance, "not governance");
        require(_accountBase != address(0x0), "account base not set");

        accountBase = _accountBase;
    }

    function setGovernance(address _governance) public {

        require(msg.sender == governance, "not governance");
        governance = _governance;
    }

    function createAccount(address[] memory _initialAdmins) public returns (Account) {

        AdminUpgradeabilityProxy proxy = new AdminUpgradeabilityProxy(accountBase, msg.sender);
        Account account = Account(address(proxy));
        account.initialize(msg.sender, _initialAdmins);
        accounts[msg.sender] = address(account);

        emit AccountCreated(msg.sender, address(account));

        return account;
    }
}

contract ReentrancyGuard {


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
}

interface IERC20Mintable is IERC20 {

    
    function mint(address _user, uint256 _amount) external;


}

interface IERC20MintableBurnable is IERC20Mintable {

    
    function burn(address _user, uint256 _amount) external;

}

contract ACoconutSwap is Initializable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokenSwapped(address indexed buyer, address indexed tokenSold, address indexed tokenBought, uint256 amountSold, uint256 amountBought);
    event Minted(address indexed provider, uint256 mintAmount, uint256[] amounts, uint256 feeAmount);
    event Redeemed(address indexed provider, uint256 redeemAmount, uint256[] amounts, uint256 feeAmount);
    event FeeCollected(address indexed feeRecipient, uint256 feeAmount);

    uint256 public constant feeDenominator = 10 ** 10;
    address[] public tokens;
    uint256[] public precisions; // 10 ** (18 - token decimals)
    uint256[] public balances; // Converted to 10 ** 18
    uint256 public mintFee; // Mint fee * 10**10
    uint256 public swapFee; // Swap fee * 10**10
    uint256 public redeemFee; // Redeem fee * 10**10
    address public feeRecipient;
    address public poolToken;
    uint256 public totalSupply; // The total amount of pool token minted by the swap.

    address public governance;
    mapping(address => bool) public admins;
    bool public paused;

    uint256 public initialA;

    function initialize(address[] memory _tokens, uint256[] memory _precisions, uint256[] memory _fees,
        address _poolToken, uint256 _A) public initializer {

        require(_tokens.length == _precisions.length, "input mismatch");
        require(_fees.length == 3, "no fees");
        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_tokens[i] != address(0x0), "token not set");
            require(_precisions[i] != 0, "precision not set");
            balances.push(0);
        }
        require(_poolToken != address(0x0), "pool token not set");

        governance = msg.sender;
        feeRecipient = msg.sender;
        tokens = _tokens;
        precisions = _precisions;
        mintFee = _fees[0];
        swapFee = _fees[1];
        redeemFee = _fees[2];
        poolToken = _poolToken;

        initialA = _A;

        paused = true;
    }

    function getA() public view returns (uint256) {

        return initialA;
    }

    function _getD(uint256[] memory _balances, uint256 _A) internal pure returns (uint256) {

        uint256 sum = 0;
        uint256 i = 0;
        uint256 Ann = _A;
        for (i = 0; i < _balances.length; i++) {
            sum = sum.add(_balances[i]);
            Ann = Ann.mul(_balances.length);
        }
        if (sum == 0)   return 0;

        uint256 prevD = 0;
        uint256 D = sum;
        for (i = 0; i < 255; i++) {
            uint256 pD = D;
            for (uint256 j = 0; j < _balances.length; j++) {
                pD = pD.mul(D).div(_balances[j].mul(_balances.length));
            }
            prevD = D;
            D = Ann.mul(sum).add(pD.mul(_balances.length)).mul(D).div(Ann.sub(1).mul(D).add(_balances.length.add(1).mul(pD)));
            if (D > prevD) {
                if (D - prevD <= 1) break;
            } else {
                if (prevD - D <= 1) break;
            }
        }

        return D;
    }

    function _getY(uint256[] memory _balances, uint256 _j, uint256 _D, uint256 _A) internal pure returns (uint256) {

        uint256 c = _D;
        uint256 S_ = 0;
        uint256 Ann = _A;
        uint256 i = 0;
        for (i = 0; i < _balances.length; i++) {
            Ann = Ann.mul(_balances.length);
            if (i == _j) continue;
            S_ = S_.add(_balances[i]);
            c = c.mul(_D).div(_balances[i].mul(_balances.length));
        }
        c = c.mul(_D).div(Ann.mul(_balances.length));
        uint256 b = S_.add(_D.div(Ann));
        uint256 prevY = 0;
        uint256 y = _D;

        for (i = 0; i < 255; i++) {
            prevY = y;
            y = y.mul(y).add(c).div(y.mul(2).add(b).sub(_D));
            if (y > prevY) {
                if (y - prevY <= 1) break;
            } else {
                if (prevY - y <= 1) break;
            }
        }

        return y;
    }

    function getMintAmount(uint256[] calldata _amounts) external view returns (uint256, uint256) {

        uint256[] memory _balances = balances;
        require(_amounts.length == _balances.length, "invalid amount");
        
        uint256 A = getA();
        uint256 oldD = totalSupply;
        uint256 i = 0;
        for (i = 0; i < _balances.length; i++) {
            if (_amounts[i] == 0)   continue;
            _balances[i] = _balances[i].add(_amounts[i].mul(precisions[i]));
        }
        uint256 newD = _getD(_balances, A);
        uint256 mintAmount = newD.sub(oldD);
        uint256 feeAmount = 0;

        if (mintFee > 0) {
            feeAmount = mintAmount.mul(mintFee).div(feeDenominator);
            mintAmount = mintAmount.sub(feeAmount);
        }

        return (mintAmount, feeAmount);
    }

    function mint(uint256[] calldata _amounts, uint256 _minMintAmount) external nonReentrant {

        uint256[] memory _balances = balances;
        require(!paused || admins[msg.sender], "paused");
        require(_balances.length == _amounts.length, "invalid amounts");

        uint256 A = getA();
        uint256 oldD = totalSupply;
        uint256 i = 0;
        for (i = 0; i < _balances.length; i++) {
            if (_amounts[i] == 0) {
                require(oldD > 0, "zero amount");
                continue;
            }
            _balances[i] = _balances[i].add(_amounts[i].mul(precisions[i]));
        }
        uint256 newD = _getD(_balances, A);
        uint256 mintAmount = newD.sub(oldD);

        uint256 fee = mintFee;
        uint256 feeAmount;
        if (fee > 0) {
            feeAmount = mintAmount.mul(fee).div(feeDenominator);
            mintAmount = mintAmount.sub(feeAmount);
        }
        require(mintAmount >= _minMintAmount, "fewer than expected");

        for (i = 0; i < _amounts.length; i++) {
            if (_amounts[i] == 0)    continue;
            balances[i] = _balances[i];
            IERC20(tokens[i]).safeTransferFrom(msg.sender, address(this), _amounts[i]);
        }
        totalSupply = newD;
        IERC20MintableBurnable(poolToken).mint(feeRecipient, feeAmount);
        IERC20MintableBurnable(poolToken).mint(msg.sender, mintAmount);

        emit Minted(msg.sender, mintAmount, _amounts, feeAmount);
    }

    function getSwapAmount(uint256 _i, uint256 _j, uint256 _dx) external view returns (uint256) {

        uint256[] memory _balances = balances;
        require(_i != _j, "same token");
        require(_i < _balances.length, "invalid in");
        require(_j < _balances.length, "invalid out");
        require(_dx > 0, "invalid amount");

        uint256 A = getA();
        uint256 D = totalSupply;
        _balances[_i] = _balances[_i].add(_dx.mul(precisions[_i]));
        uint256 y = _getY(_balances, _j, D, A);
        uint256 dy = _balances[_j].sub(y).sub(1).div(precisions[_j]);

        if (swapFee > 0) {
            dy = dy.sub(dy.mul(swapFee).div(feeDenominator));
        }

        return dy;
    }

    function swap(uint256 _i, uint256 _j, uint256 _dx, uint256 _minDy) external nonReentrant {

        uint256[] memory _balances = balances;
        require(!paused || admins[msg.sender], "paused");
        require(_i != _j, "same token");
        require(_i < _balances.length, "invalid in");
        require(_j < _balances.length, "invalid out");
        require(_dx > 0, "invalid amount");

        uint256 A = getA();
        uint256 D = totalSupply;
        _balances[_i] = _balances[_i].add(_dx.mul(precisions[_i]));
        uint256 y = _getY(_balances, _j, D, A);
        uint256 dy = _balances[_j].sub(y).sub(1).div(precisions[_j]);
        balances[_j] = y;
        balances[_i] = _balances[_i];

        uint256 fee = swapFee;
        if (fee > 0) {
            dy = dy.sub(dy.mul(fee).div(feeDenominator));
        }
        require(dy >= _minDy, "fewer than expected");

        IERC20(tokens[_i]).safeTransferFrom(msg.sender, address(this), _dx);
        IERC20(tokens[_j]).safeTransfer(msg.sender, dy);

        emit TokenSwapped(msg.sender, tokens[_i], tokens[_j], _dx, dy);
    }

    function getRedeemProportionAmount(uint256 _amount) external view returns (uint256[] memory, uint256) {

        uint256[] memory _balances = balances;
        require(_amount > 0, "zero amount");

        uint256 D = totalSupply;
        uint256[] memory amounts = new uint256[](_balances.length);
        uint256 feeAmount = 0;
        if (redeemFee > 0) {
            feeAmount = _amount.mul(redeemFee).div(feeDenominator);
            _amount = _amount.sub(feeAmount);
        }

        for (uint256 i = 0; i < _balances.length; i++) {
            amounts[i] = _balances[i].mul(_amount).div(D).div(precisions[i]);
        }

        return (amounts, feeAmount);
    }

    function redeemProportion(uint256 _amount, uint256[] calldata _minRedeemAmounts) external nonReentrant {

        uint256[] memory _balances = balances;
        require(!paused || admins[msg.sender], "paused");
        require(_amount > 0, "zero amount");
        require(_balances.length == _minRedeemAmounts.length, "invalid mins");

        uint256 D = totalSupply;
        uint256[] memory amounts = new uint256[](_balances.length);
        uint256 fee = redeemFee;
        uint256 feeAmount;
        if (fee > 0) {
            feeAmount = _amount.mul(fee).div(feeDenominator);
            IERC20(poolToken).safeTransferFrom(msg.sender, feeRecipient, feeAmount);
            _amount = _amount.sub(feeAmount);
        }

        for (uint256 i = 0; i < _balances.length; i++) {
            uint256 tokenAmount = _balances[i].mul(_amount).div(D);
            amounts[i] = tokenAmount.div(precisions[i]);
            require(amounts[i] >= _minRedeemAmounts[i], "fewer than expected");
            balances[i] = _balances[i].sub(tokenAmount);
            IERC20(tokens[i]).safeTransfer(msg.sender, amounts[i]);
        }

        totalSupply = D.sub(_amount);
        IERC20MintableBurnable(poolToken).burn(msg.sender, _amount);

        emit Redeemed(msg.sender, _amount.add(feeAmount), amounts, feeAmount);
    }

    function getRedeemSingleAmount(uint256 _amount, uint256 _i) external view returns (uint256, uint256) {

        uint256[] memory _balances = balances;
        require(_amount > 0, "zero amount");
        require(_i < _balances.length, "invalid token");

        uint256 A = getA();
        uint256 D = totalSupply;
        uint256 feeAmount = 0;
        if (redeemFee > 0) {
            feeAmount = _amount.mul(redeemFee).div(feeDenominator);
            _amount = _amount.sub(feeAmount);
        }
        uint256 y = _getY(_balances, _i, D.sub(_amount), A);
        uint256 dy = _balances[_i].sub(y).div(precisions[_i]);

        return (dy, feeAmount);
    }

    function redeemSingle(uint256 _amount, uint256 _i, uint256 _minRedeemAmount) external nonReentrant {

        uint256[] memory _balances = balances;
        require(!paused || admins[msg.sender], "paused");
        require(_amount > 0, "zero amount");
        require(_i < _balances.length, "invalid token");

        uint256 A = getA();
        uint256 D = totalSupply;
        uint256 fee = redeemFee;
        uint256 feeAmount = 0;
        if (fee > 0) {
            feeAmount = _amount.mul(fee).div(feeDenominator);
            IERC20(poolToken).safeTransferFrom(msg.sender, feeRecipient, feeAmount);
            _amount = _amount.sub(feeAmount);
        }

        uint256 y = _getY(_balances, _i, D.sub(_amount), A);
        uint256 dy = _balances[_i].sub(y).div(precisions[_i]);
        require(dy >= _minRedeemAmount, "fewer than expected");
        balances[_i] = y;
        uint256[] memory amounts = new uint256[](_balances.length);
        amounts[_i] = dy;
        IERC20(tokens[_i]).safeTransfer(msg.sender, dy);

        totalSupply = D.sub(_amount);
        IERC20MintableBurnable(poolToken).burn(msg.sender, _amount);

        emit Redeemed(msg.sender, _amount.add(feeAmount), amounts, feeAmount);
    }

    function getRedeemMultiAmount(uint256[] calldata _amounts) external view returns (uint256, uint256) {

        uint256[] memory _balances = balances;
        require(_amounts.length == balances.length, "length not match");
        
        uint256 A = getA();
        uint256 oldD = totalSupply;
        for (uint256 i = 0; i < _balances.length; i++) {
            if (_amounts[i] == 0)   continue;
            _balances[i] = _balances[i].sub(_amounts[i].mul(precisions[i]));
        }
        uint256 newD = _getD(_balances, A);

        uint256 redeemAmount = oldD.sub(newD);
        uint256 feeAmount = 0;
        if (redeemFee > 0) {
            redeemAmount = redeemAmount.mul(feeDenominator).div(feeDenominator.sub(redeemFee));
            feeAmount = redeemAmount.sub(oldD.sub(newD));
        }

        return (redeemAmount, feeAmount);
    }

    function redeemMulti(uint256[] calldata _amounts, uint256 _maxRedeemAmount) external nonReentrant {

        uint256[] memory _balances = balances;
        require(_amounts.length == balances.length, "length not match");
        require(!paused || admins[msg.sender], "paused");
        
        uint256 A = getA();
        uint256 oldD = totalSupply;
        uint256 i = 0;
        for (i = 0; i < _balances.length; i++) {
            if (_amounts[i] == 0)   continue;
            _balances[i] = _balances[i].sub(_amounts[i].mul(precisions[i]));
        }
        uint256 newD = _getD(_balances, A);

        uint256 redeemAmount = oldD.sub(newD);
        uint256 fee = redeemFee;
        uint256 feeAmount = 0;
        if (fee > 0) {
            redeemAmount = redeemAmount.mul(feeDenominator).div(feeDenominator.sub(fee));
            feeAmount = redeemAmount.sub(oldD.sub(newD));
            IERC20(poolToken).safeTransferFrom(msg.sender, feeRecipient, feeAmount);
        }
        require(redeemAmount <= _maxRedeemAmount, "more than expected");

        balances = _balances;
        uint256 burnAmount = redeemAmount.sub(feeAmount);
        totalSupply = oldD.sub(burnAmount);
        IERC20MintableBurnable(poolToken).burn(msg.sender, burnAmount);
        for (i = 0; i < _balances.length; i++) {
            if (_amounts[i] == 0)   continue;
            IERC20(tokens[i]).safeTransfer(msg.sender, _amounts[i]);
        }

        emit Redeemed(msg.sender, redeemAmount, _amounts, feeAmount);
    }

    function getPendingFeeAmount() external view returns (uint256) {

        uint256[] memory _balances = balances;
        uint256 A = getA();
        uint256 oldD = totalSupply;

        for (uint256 i = 0; i < _balances.length; i++) {
            _balances[i] = IERC20(tokens[i]).balanceOf(address(this)).mul(precisions[i]);
        }
        uint256 newD = _getD(_balances, A);

        return newD.sub(oldD);
    }

    function collectFee() external returns (uint256) {

        require(admins[msg.sender], "not admin");
        uint256[] memory _balances = balances;
        uint256 A = getA();
        uint256 oldD = totalSupply;

        for (uint256 i = 0; i < _balances.length; i++) {
            _balances[i] = IERC20(tokens[i]).balanceOf(address(this)).mul(precisions[i]);
        }
        uint256 newD = _getD(_balances, A);
        uint256 feeAmount = newD.sub(oldD);
        if (feeAmount == 0) return 0;

        balances = _balances;
        totalSupply = newD;
        address _feeRecipient = feeRecipient;
        IERC20MintableBurnable(poolToken).mint(_feeRecipient, feeAmount);

        emit FeeCollected(_feeRecipient, feeAmount);

        return feeAmount;
    }

    function setGovernance(address _governance) external {

        require(msg.sender == governance, "not governance");
        governance = _governance;
    }

    function setMintFee(uint256 _mintFee) external {

        require(msg.sender == governance, "not governance");
        mintFee = _mintFee;
    }

    function setSwapFee(uint256 _swapFee) external {

        require(msg.sender == governance, "not governance");
        swapFee = _swapFee;
    }

    function setRedeemFee(uint256 _redeemFee) external {

        require(msg.sender == governance, "not governance");
        redeemFee = _redeemFee;
    }

    function setFeeRecipient(address _feeRecipient) external {

        require(msg.sender == governance, "not governance");
        require(_feeRecipient != address(0x0), "fee recipient not set");
        feeRecipient = _feeRecipient;
    }

    function setPoolToken(address _poolToken) external {

        require(msg.sender == governance, "not governance");
        require(_poolToken != address(0x0), "pool token not set");
        poolToken = _poolToken;
    }

    function pause() external {

        require(msg.sender == governance, "not governance");
        require(!paused, "paused");

        paused = true;
    }

    function unpause() external {

        require(msg.sender == governance, "not governance");
        require(paused, "not paused");

        paused = false;
    }

    function setAdmin(address _account, bool _allowed) external {

        require(msg.sender == governance, "not governance");
        require(_account != address(0x0), "account not set");

        admins[_account] = _allowed;
    }
}

contract SwapApplication is Initializable {

    using SafeMath for uint256;

    address public governance;
    ACoconutSwap public swap;

    function initialize(address _swap) public initializer {

        require(_swap != address(0x0), "swap not set");
        
        governance = msg.sender;
        swap = ACoconutSwap(_swap);
    }

    function setGovernance(address _governance) public {

        require(msg.sender == governance, "not governance");
        governance = _governance;
    }

    function setSwap(address _swap) public {

        require(msg.sender == governance, "not governance");
        require(_swap != address(0x0), "swap not set");

        swap = ACoconutSwap(_swap);
    }

    modifier validAccount(address _account) {

        Account account = Account(payable(_account));
        require(account.owner() == msg.sender, "not owner");
        require(account.isOperator(address(this)), "not operator");
        _;
    }

    function mintToken(address _account, uint256[] memory _amounts, uint256 _minMintAmount) public validAccount(_account) {

        Account account = Account(payable(_account));
        for (uint256 i = 0; i < _amounts.length; i++) {
            account.approveToken(swap.tokens(i), address(swap), _amounts[i]);
        }

        bytes memory methodData = abi.encodeWithSignature("mint(uint256[],uint256)", _amounts, _minMintAmount);
        account.invoke(address(swap), 0, methodData);
    }

    function swapToken(address _account, uint256 _i, uint256 _j, uint256 _dx, uint256 _minDy) public validAccount(_account) {

        Account account = Account(payable(_account));
        account.approveToken(swap.tokens(_i), address(swap), _dx);

        bytes memory methodData = abi.encodeWithSignature("swap(uint256,uint256,uint256,uint256)", _i, _j, _dx, _minDy);
        account.invoke(address(swap), 0, methodData);
    }

    function redeemProportion(address _account, uint256 _amount, uint256[] memory _minRedeemAmounts) public validAccount(_account) {

        Account account = Account(payable(_account));
        account.approveToken(swap.poolToken(), address(swap), _amount);

        bytes memory methodData = abi.encodeWithSignature("redeemProportion(uint256,uint256[])", _amount, _minRedeemAmounts);
        account.invoke(address(swap), 0, methodData);
    }

    function redeemSingle(address _account, uint256 _amount, uint256 _i, uint256 _minRedeemAmount) public validAccount(_account) {

        Account account = Account(payable(_account));
        account.approveToken(swap.poolToken(), address(swap), _amount);

        bytes memory methodData = abi.encodeWithSignature("redeemSingle(uint256,uint256,uint256)", _amount, _i, _minRedeemAmount);
        account.invoke(address(swap), 0, methodData);
    }

    function redeemMulti(address _account, uint256[] memory _amounts, uint256 _maxRedeemAmount) public validAccount(_account) {

        Account account = Account(payable(_account));
        account.approveToken(swap.poolToken(), address(swap), _maxRedeemAmount);

        bytes memory methodData = abi.encodeWithSignature("redeemMulti(uint256[],uint256)", _amounts, _maxRedeemAmount);
        account.invoke(address(swap), 0, methodData);

        account.approveToken(swap.poolToken(), address(this), 0);
    }
}