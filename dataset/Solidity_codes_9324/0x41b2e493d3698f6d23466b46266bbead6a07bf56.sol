
pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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
pragma solidity 0.7.4;



contract Constants {

    IERC20 constant ETH = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
}
pragma solidity 0.7.4;


interface IUserWallet {

    function params(bytes32 _key) external view returns(bytes32);

    function owner() external view returns(address payable);

    function demandETH(address payable _recepient, uint _amount) external;

    function demandERC20(IERC20 _token, address _recepient, uint _amount) external;

    function demandAll(IERC20[] calldata _tokens, address payable _recepient) external;

    function demand(address payable _target, uint _value, bytes memory _data) 
        external returns(bool, bytes memory);

}
pragma solidity 0.7.4;


interface IBuyBurner {

    function approveExchange(IERC20[] calldata _tokens) external;

    receive() payable external;
    function buyBurn(IERC20[] calldata _tokens) external;

}
pragma solidity 0.7.4;

library ParamsLib {

    function toBytes32(address _self) internal pure returns(bytes32) {

        return bytes32(uint(_self));
    }

    function toAddress(bytes32 _self) internal pure returns(address payable) {

        return address(uint(_self));
    }
}
pragma solidity 0.7.4;


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

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;


library ExtraMath {

    using SafeMath for uint;

    function divCeil(uint _a, uint _b) internal pure returns(uint) {

        if (_a.mod(_b) > 0) {
            return (_a / _b).add(1);
        }
        return _a / _b;
    }
}

contract Wallet2Wallet is AccessControl, Constants {

    using SafeERC20 for IERC20;
    using SafeMath for uint;
    using ExtraMath for uint;
    using ParamsLib for *;

    bytes32 constant public EXECUTOR_ROLE = bytes32('Executor');
    uint constant public EXTRA_GAS = 15000; // SLOAD * 2, Event, CALL, CALL with value, calc.
    uint constant public GAS_SAVE = 30000;
    uint constant public HUNDRED_PERCENT = 10000; // 100.00%
    uint constant public MAX_FEE_PERCENT = 50; // 0.50%
    IBuyBurner immutable public TOKEN_BURNER;

    address payable public gasFeeCollector;
    mapping(IERC20 => uint) public fees;

    struct Request {
        IUserWallet user;
        IERC20 tokenFrom;
        uint amountFrom;
        IERC20 tokenTo;
        uint minAmountTo;
        uint fee;
        bool copyToWalletOwner;
        uint txGasLimit;
        address target;
        address approveTarget;
        bytes callData;
    }

    struct RequestETHForTokens {
        IUserWallet user;
        uint amountFrom;
        IERC20 tokenTo;
        uint minAmountTo;
        uint fee;
        bool copyToWalletOwner;
        uint txGasLimit;
        address payable target;
        bytes callData;
    }

    struct RequestTokensForETH {
        IUserWallet user;
        IERC20 tokenFrom;
        uint amountFrom;
        uint minAmountTo;
        uint fee;
        bool copyToWalletOwner;
        uint txGasLimit;
        address target;
        address approveTarget;
        bytes callData;
    }

    event Error(bytes _error);

    modifier onlyOwner() {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'Only owner');
        _;
    }

    modifier onlyExecutor() {

        require(hasRole(EXECUTOR_ROLE, _msgSender()), 'Only Executor');
        _;
    }

    modifier onlyThis() {

        require(_msgSender() == address(this), 'Only this contract');
        _;
    }

    modifier checkFee(uint _feePercent) {

        require(_feePercent <= MAX_FEE_PERCENT, 'Fee is too high');
        _;
    }

    constructor(IBuyBurner _tokenBurner) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(EXECUTOR_ROLE, _msgSender());
        gasFeeCollector = payable(_msgSender());
        TOKEN_BURNER = _tokenBurner;
    }

    function updateGasFeeCollector(address payable _address) external onlyOwner() {

        require(_address != address(0), 'Not zero address required');
        gasFeeCollector = _address;
    }

    receive() payable external {}

    function makeSwap(Request memory _request)
    external onlyExecutor() checkFee(_request.fee) returns(bool, bytes memory _reason) {

        require(address(_request.user).balance >= (_request.txGasLimit * tx.gasprice),
            'Not enough ETH in UserWallet');

        bool _result = false;
        try this._execute{gas: gasleft().sub(GAS_SAVE)}(_request) {
            _result = true;
        } catch (bytes memory _error) { _reason = _error; }
        if (!_result) {
            emit Error(_reason);
        }
        _chargeFee(_request.user, _request.txGasLimit);
        return (_result, _reason);
    }

    function makeSwapETHForTokens(RequestETHForTokens memory _request)
    external onlyExecutor() checkFee(_request.fee) returns(bool, bytes memory _reason) {

        require(address(_request.user).balance >= ((_request.txGasLimit * tx.gasprice) + _request.amountFrom),
            'Not enough ETH in UserWallet');

        bool _result = false;
        try this._executeETHForTokens{gas: gasleft().sub(GAS_SAVE)}(_request) {
            _result = true;
        } catch (bytes memory _error) { _reason = _error; }
        if (!_result) {
            emit Error(_reason);
        }
        _chargeFee(_request.user, _request.txGasLimit);
        return (_result, _reason);
    }

    function makeSwapTokensForETH(RequestTokensForETH memory _request)
    external onlyExecutor() checkFee(_request.fee) returns(bool, bytes memory _reason) {

        require(address(_request.user).balance >= (_request.txGasLimit * tx.gasprice),
            'Not enough ETH in UserWallet');

        bool _result = false;
        try this._executeTokensForETH{gas: gasleft().sub(GAS_SAVE)}(_request) {
            _result = true;
        } catch (bytes memory _error) { _reason = _error; }
        if (!_result) {
            emit Error(_reason);
        }
        _chargeFee(_request.user, _request.txGasLimit);
        return (_result, _reason);
    }

    function _require(bool _success, bytes memory _reason) internal pure {

        if (_success) {
            return;
        }
        assembly {
            revert(add(_reason, 32), mload(_reason))
        }
    }

    function _execute(Request memory _request) external onlyThis() {

        _request.user.demandERC20(_request.tokenFrom, address(this), _request.amountFrom);
        _request.tokenFrom.safeApprove(_request.approveTarget, _request.amountFrom);

        (bool _success, bytes memory _reason) = _request.target.call(_request.callData);
        _require(_success, _reason);
        uint _balanceThis = _request.tokenTo.balanceOf(address(this));
        require(_balanceThis >= _request.minAmountTo, 'Less than minimum received');
        uint _userGetsAmount = _saveFee(_request.tokenTo, _balanceThis, _request.fee);
        address _userGetsTo = _swapTo(_request.user, _request.copyToWalletOwner);
        _request.tokenTo.safeTransfer(_userGetsTo, _userGetsAmount);
    }

    function _executeETHForTokens(RequestETHForTokens memory _request) external onlyThis() {

        _request.user.demandETH(address(this), _request.amountFrom);

        (bool _success, bytes memory _reason) = _request.target.call{value: _request.amountFrom}(_request.callData);
        _require(_success, _reason);
        uint _balanceThis = _request.tokenTo.balanceOf(address(this));
        require(_balanceThis >= _request.minAmountTo, 'Less than minimum received');
        uint _userGetsAmount = _saveFee(_request.tokenTo, _balanceThis, _request.fee);
        address _userGetsTo = _swapTo(_request.user, _request.copyToWalletOwner);
        _request.tokenTo.safeTransfer(_userGetsTo, _userGetsAmount);
    }

    function _executeTokensForETH(RequestTokensForETH memory _request) external onlyThis() {

        _request.user.demandERC20(_request.tokenFrom, address(this), _request.amountFrom);
        _request.tokenFrom.safeApprove(_request.approveTarget, _request.amountFrom);

        (bool _success, bytes memory _reason) = _request.target.call(_request.callData);
        _require(_success, _reason);
        uint _balanceThis = address(this).balance;
        require(_balanceThis >= _request.minAmountTo, 'Less than minimum received');
        uint _userGetsAmount = _saveFee(ETH, _balanceThis, _request.fee);
        address payable _userGetsTo = _swapTo(_request.user, _request.copyToWalletOwner);
        _userGetsTo.transfer(_userGetsAmount);
    }

    function _saveFee(IERC20 _token, uint _amount, uint _feePercent) internal returns(uint) {

        if (_feePercent == 0) {
            return _amount;
        }
        uint _fee = _amount.mul(_feePercent).divCeil(HUNDRED_PERCENT);
        fees[_token] = fees[_token].add(_fee);
        return _amount.sub(_fee);
    }

    function _chargeFee(IUserWallet _user, uint _txGasLimit) internal {

        uint _txCost = (_txGasLimit - gasleft() + EXTRA_GAS) * tx.gasprice;
        _user.demandETH(gasFeeCollector, _txCost);
    }

    function _swapTo(IUserWallet _user, bool _copyToWalletOwner) internal view returns(address payable) {

        if (_copyToWalletOwner) {
           return _user.owner();
        }
        return payable(address(_user));
    }

    function sendFeeForBurning(IERC20[] calldata _tokens) external {

        for (uint _i = 0; _i < _tokens.length; _i++) {
            IERC20 _token = _tokens[_i];
            uint _fee = fees[_token];
            fees[_token] = 0;
            if (_token == ETH) {
                payable(TOKEN_BURNER).transfer(_fee);
            } else {
                _token.safeTransfer(address(TOKEN_BURNER), _fee);
            }
        }
    }

    function collectTokens(IERC20 _token, uint _amount, address _to)
    external onlyOwner() {

        uint _fees = fees[_token];
        if (_token == ETH) {
            require(address(this).balance.sub(_fees) >= _amount, 'Insufficient extra ETH');
            payable(_to).transfer(_amount);
        } else {
            require(_token.balanceOf(address(this)).sub(_fees) >= _amount, 'Insufficient extra tokens');
            _token.safeTransfer(_to, _amount);
        }
    }
}
pragma solidity 0.7.4;

contract MinimalProxyFactory {

    function _deployBytecode(address _prototype) internal pure returns(bytes memory) {

        return abi.encodePacked(
            hex'602d600081600a8239f3363d3d373d3d3d363d73',
            _prototype,
            hex'5af43d82803e903d91602b57fd5bf3'
        );
    }

    function _deploy(address _prototype, bytes32 _salt) internal returns(address payable _result) {

        bytes memory _bytecode = _deployBytecode(_prototype);
        assembly {
            _result := create2(0, add(_bytecode, 32), mload(_bytecode), _salt)
        }
        return _result;
    }
}
