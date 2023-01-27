

pragma solidity 0.7.1;
pragma experimental ABIEncoderV2;


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

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

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

contract ExchangeSwapV4 is AccessControl, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeMath for uint;

    bytes32 public constant EXECUTOR_ROLE = bytes32('Executor');

    address payable public feeCollector;
    mapping(address => uint) public coverFees;
    uint public totalFees;

    struct Request {
        address user;
        IERC20 tokenFrom;
        uint amountFrom;
        IERC20 tokenTo;
        uint minAmountTo;
        uint txGasLimit;
        address target;
        bytes callData;
    }

    struct RequestETHForTokens {
        address user;
        uint amountFrom;
        IERC20 tokenTo;
        uint minAmountTo;
        uint txGasLimit;
        address payable target;
        bytes callData;
    }

    struct RequestTokensForETH {
        address payable user;
        IERC20 tokenFrom;
        uint amountFrom;
        uint minAmountTo;
        uint txGasLimit;
        address target;
        bytes callData;
    }

    modifier onlyOwner() {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Only owner');
        _;
    }

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(EXECUTOR_ROLE, _msgSender());
        feeCollector = payable(_msgSender());
    }

    function updateFeeCollector(address payable _address) external nonReentrant() onlyOwner() {

        require(_address != address(0), 'Not zero address required');
        feeCollector = _address;
    }

    receive() payable external {}

    function depositETH() payable external {

        address sender = _msgSender();
        coverFees[sender] = coverFees[sender].add(msg.value);
        totalFees = totalFees.add(msg.value);
    }

    function withdraw() external {

        address payable sender = _msgSender();
        uint amount = coverFees[sender];
        require(amount > 0, 'Nothing to withdraw');
        coverFees[sender] = 0;
        totalFees = totalFees.sub(amount);
        sender.transfer(amount);
    }

    function makeSwap(Request memory _request) external nonReentrant() returns(bool) {

        require(hasRole(EXECUTOR_ROLE, _msgSender()), 'Only Executor');
        require(coverFees[_request.user] >= ((_request.txGasLimit + 5000) * tx.gasprice),
            'Cover fees deposit required');

        bool _result = true;
        try this._execute{gas: gasleft().sub(20000)}(_request) {} catch {
            _result = false;
        }
        _chargeFee(_request.user, _request.txGasLimit);
        return _result;
    }

    function makeSwapETHForTokens(RequestETHForTokens memory _request) external nonReentrant() returns(bool) {
        require(hasRole(EXECUTOR_ROLE, _msgSender()), 'Only Executor');
        require(coverFees[_request.user] >=
            (((_request.txGasLimit + 5000) * tx.gasprice + _request.amountFrom)),
            'Cover fees deposit required');

        bool _result = true;
        try this._executeETHForTokens{gas: gasleft().sub(20000)}(_request) {} catch {
            _result = false;
        }
        _chargeFee(_request.user, _request.txGasLimit);
        return _result;
    }

    function makeSwapTokensForETH(RequestTokensForETH memory _request) external nonReentrant() returns(bool) {
        require(hasRole(EXECUTOR_ROLE, _msgSender()), 'Only Executor');
        require(coverFees[_request.user] >= ((_request.txGasLimit + 5000) * tx.gasprice),
            'Cover fees deposit required');

        bool _result = true;
        try this._executeTokensForETH{gas: gasleft().sub(20000)}(_request) {} catch {
            _result = false;
        }
        _chargeFee(_request.user, _request.txGasLimit);
        return _result;
    }

    function _execute(Request memory _request) external {
        require(_msgSender() == address(this), 'Only this contract');
        _request.tokenFrom.safeTransferFrom(_request.user, address(this), _request.amountFrom);
        _request.tokenFrom.safeApprove(_request.target, _request.amountFrom);

        uint _balanceBefore = _request.tokenTo.balanceOf(_request.user);
        (bool _success, ) = _request.target.call(_request.callData);
        require(_success, 'Call failed');
        uint _balanceThis = _request.tokenTo.balanceOf(address(this));
        if (_balanceThis > 0) {
            _request.tokenTo.safeTransfer(_request.user, _balanceThis);
        }
        uint _balanceAfter = _request.tokenTo.balanceOf(_request.user);

        require(_balanceAfter.sub(_balanceBefore) >= _request.minAmountTo, 'Less than minimum received');
    }

    function _executeETHForTokens(RequestETHForTokens memory _request) external {
        require(_msgSender() == address(this), 'Only this contract');
        uint _balance = coverFees[_request.user];
        require(_balance >= _request.amountFrom, 'Insufficient funds');
        coverFees[_request.user] = coverFees[_request.user].sub(_request.amountFrom);
        totalFees = totalFees.sub(_request.amountFrom);

        uint _balanceBefore = _request.tokenTo.balanceOf(_request.user);
        (bool _success, ) = _request.target.call{value: _request.amountFrom}(_request.callData);
        require(_success, 'Call failed');
        uint _balanceThis = _request.tokenTo.balanceOf(address(this));
        if (_balanceThis > 0) {
            _request.tokenTo.safeTransfer(_request.user, _balanceThis);
        }
        uint _balanceAfter = _request.tokenTo.balanceOf(_request.user);

        require(_balanceAfter.sub(_balanceBefore) >= _request.minAmountTo, 'Less than minimum received');
    }

    function _executeTokensForETH(RequestTokensForETH memory _request) external {
        require(_msgSender() == address(this), 'Only this contract');
        _request.tokenFrom.safeTransferFrom(_request.user, address(this), _request.amountFrom);
        _request.tokenFrom.safeApprove(_request.target, _request.amountFrom);

        uint _balanceBefore = _request.user.balance;
        (bool _success, ) = _request.target.call(_request.callData);
        require(_success, 'Call failed');
        uint _balanceThis = address(this).balance;
        if (_balanceThis > totalFees) {
            _request.user.transfer(_balanceThis.sub(totalFees));
        }
        uint _balanceAfter = _request.user.balance;

        require(_balanceAfter.sub(_balanceBefore) >= _request.minAmountTo, 'Less than minimum received');
    }

    function _chargeFee(address _user, uint _txGasLimit) internal {
        uint _txCost = (_txGasLimit - gasleft() + 15000) * tx.gasprice;
        coverFees[_user] = coverFees[_user].sub(_txCost);
        totalFees = totalFees.sub(_txCost);
        feeCollector.transfer(_txCost);
    }

    function collectTokens(IERC20 _token, uint _amount, address _to)
    external nonReentrant() onlyOwner() {
        _token.transfer(_to, _amount);
    }

    function collectETH(uint _amount, address payable _to)
    external nonReentrant() onlyOwner() {
        require(address(this).balance.sub(totalFees) >= _amount, 'Insufficient extra ETH');
        _to.transfer(_amount);
    }
}