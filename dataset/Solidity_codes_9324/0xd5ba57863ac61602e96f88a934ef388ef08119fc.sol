

pragma solidity >=0.6.0 <0.8.0;



library EnumerableSetUpgradeable {


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


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
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


pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}


abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
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
    uint256[49] private __gap;
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


interface IHolyPoolV2 {

    function getBaseAsset() external view returns(address);


    function depositOnBehalf(address beneficiary, uint256 amount) external;

    function depositOnBehalfDirect(address beneficiary, uint256 amount) external;

    function withdraw(address beneficiary, uint256 amount) external;


    function borrowToInvest(uint256 amount) external returns(uint256);

    function returnInvested(uint256 amountCapitalBody) external;


    function harvestYield(uint256 amount) external; // pool would transfer amount tokens from caller as it's profits

}


interface IHolyWing {

    function executeSwap(address tokenFrom, address tokenTo, uint256 amount, bytes calldata data) external returns(uint256);

}


interface IHolyWingV2 {

    function executeSwap(address tokenFrom, address tokenTo, uint256 amount, bytes calldata data) payable external returns(uint256);


    function executeSwapDirect(address beneficiary, address tokenFrom, address tokenTo, uint256 amount, uint256 fee, bytes calldata data) payable external returns(uint256);

}


interface IHolyRedeemer {

}


interface ISmartTreasury {

    function spendBonus(address _account, uint256 _amount) external;

    function depositOnBehalf(address _account, uint _tokenMoveAmount, uint _tokenMoveEthAmount) external;

    function claimAndBurnOnBehalf(address _beneficiary, uint256 _amount) external;

}


interface IBurnable {

    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external; 

}


interface IChainLinkFeed {

  function latestAnswer() external view returns (int256);

}


abstract contract SafeAllowanceReset {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  function resetAllowanceIfNeeded(IERC20 _token, address _spender, uint256 _amount) internal {
    uint256 allowance = _token.allowance(address(this), _spender);
    if (allowance < _amount) {
      uint256 newAllowance = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
      IERC20(_token).safeIncreaseAllowance(address(_spender), newAllowance.sub(allowance));
    }
  }
}



contract HolyHandV6 is AccessControlUpgradeable, SafeAllowanceReset {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address payable;

    uint256 private constant ALLOWANCE_SIZE =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    address private constant ETH_TOKEN_ADDRESS =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 public depositFee;
    uint256 public exchangeFee;
    uint256 public withdrawFee;

    IHolyWing private exchangeProxyContract;

    address private yieldDistributorAddress;

    event TokenSwap(
        address indexed tokenFrom,
        address indexed tokenTo,
        address sender,
        uint256 amountFrom,
        uint256 expectedMinimumReceived,
        uint256 amountReceived
    );

    event FeeChanged(string indexed name, uint256 value);

    event EmergencyTransfer(
        address indexed token,
        address indexed destination,
        uint256 amount
    );

    function initialize() public initializer {

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        depositFee = 0;
        exchangeFee = 0;
        withdrawFee = 0;
    }

    function setExchangeProxy(address _exchangeProxyContract) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        exchangeProxyContract = IHolyWing(_exchangeProxyContract);
    }

    function setYieldDistributor(
        address _tokenAddress,
        address _distributorAddress
    ) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        yieldDistributorAddress = _distributorAddress;
        resetAllowanceIfNeeded(
            IERC20(_tokenAddress),
            _distributorAddress,
            ALLOWANCE_SIZE
        );
    }

    function depositToPool(
        address _poolAddress,
        address _token,
        uint256 _amount,
        uint256 _expectedMinimumReceived,
        bytes memory _convertData
    ) public payable {

        depositToPoolOnBehalf(msg.sender, _poolAddress, _token, _amount, _expectedMinimumReceived, _convertData);
    }

    function depositToPoolOnBehalf(
        address _beneficiary,
        address _poolAddress,
        address _token,
        uint256 _amount,
        uint256 _expectedMinimumReceived,
        bytes memory _convertData
    ) internal {

        IHolyPoolV2 holyPool = IHolyPoolV2(_poolAddress);
        IERC20 poolToken = IERC20(holyPool.getBaseAsset());

        if (address(poolToken) == _token) {

            if (depositFee == 0) {

                IERC20(_token).safeTransferFrom(
                    _beneficiary,
                    _poolAddress,
                    _amount
                );

                holyPool.depositOnBehalfDirect(_beneficiary, _amount);
                return;
            }

            IERC20(_token).safeTransferFrom(_beneficiary, address(this), _amount);

            resetAllowanceIfNeeded(poolToken, _poolAddress, _amount);

            uint256 feeAmount = _amount.mul(depositFee).div(1e18);
            holyPool.depositOnBehalf(_beneficiary, _amount.sub(feeAmount));
            return;
        }

        if (_token != ETH_TOKEN_ADDRESS) {
            IERC20(_token).safeTransferFrom(
                _beneficiary,
                address(exchangeProxyContract),
                _amount
            );
        }

        if (depositFee > 0) {
            uint256 amountReceived =
                IHolyWingV2(address(exchangeProxyContract)).executeSwapDirect{value: msg.value}(
                    address(this),
                    _token,
                    address(poolToken),
                    _amount,
                    exchangeFee,
                    _convertData
                );
            require(
                amountReceived >= _expectedMinimumReceived,
                "minimum swap amount not met"
            );
            uint256 feeAmount = amountReceived.mul(depositFee).div(1e18);
            amountReceived = amountReceived.sub(feeAmount);

            resetAllowanceIfNeeded(poolToken, _poolAddress, _amount);

            holyPool.depositOnBehalf(_beneficiary, amountReceived);
        } else {
            uint256 amountReceived =
                IHolyWingV2(address(exchangeProxyContract)).executeSwapDirect{value: msg.value}(
                    _poolAddress,
                    _token,
                    address(poolToken),
                    _amount,
                    exchangeFee,
                    _convertData
                );
            require(
                amountReceived >= _expectedMinimumReceived,
                "minimum swap amount not met"
            );
            holyPool.depositOnBehalfDirect(_beneficiary, amountReceived);
        }
    }

    function withdrawFromPool(address _poolAddress, uint256 _amount) public {

        withdrawFromPoolOnBehalf(msg.sender, _poolAddress, _amount);
    }

    function withdrawFromPoolOnBehalf(address _beneficiary, address _poolAddress, uint256 _amount) internal {

        IHolyPoolV2 holyPool = IHolyPoolV2(_poolAddress);
        IERC20 poolToken = IERC20(holyPool.getBaseAsset());
        uint256 amountBefore = poolToken.balanceOf(address(this));
        holyPool.withdraw(_beneficiary, _amount);
        uint256 withdrawnAmount =
            poolToken.balanceOf(address(this)).sub(amountBefore);

        if (withdrawFee > 0) {
            uint256 feeAmount = withdrawnAmount.mul(withdrawFee).div(1e18);
            poolToken.safeTransfer(_beneficiary, withdrawnAmount.sub(feeAmount));
        } else {
            poolToken.safeTransfer(_beneficiary, withdrawnAmount);
        }
    }

    function setDepositFee(uint256 _depositFee) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        depositFee = _depositFee;
        emit FeeChanged("deposit", _depositFee);
    }

    function setExchangeFee(uint256 _exchangeFee) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        exchangeFee = _exchangeFee;
        emit FeeChanged("exchange", _exchangeFee);
    }

    function setWithdrawFee(uint256 _withdrawFee) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        withdrawFee = _withdrawFee;
        emit FeeChanged("withdraw", _withdrawFee);
    }

    function setTransferFee(uint256 _transferFee) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        transferFee = _transferFee;
        emit FeeChanged("transfer", _transferFee);
    }

        function executeSwap(
        address _tokenFrom,
        address _tokenTo,
        uint256 _amountFrom,
        uint256 _expectedMinimumReceived,
        bytes memory _convertData
    ) public payable {

        executeSwapOnBehalf(msg.sender, _tokenFrom, _tokenTo, _amountFrom, _expectedMinimumReceived, _convertData);
    }

    function executeSwapOnBehalf(
        address _beneficiary,
        address _tokenFrom,
        address _tokenTo,
        uint256 _amountFrom,
        uint256 _expectedMinimumReceived,
        bytes memory _convertData
    ) internal {

        require(_tokenFrom != _tokenTo, "same tokens provided");

        if (_tokenFrom != ETH_TOKEN_ADDRESS) {
            IERC20(_tokenFrom).safeTransferFrom(
                _beneficiary,
                address(exchangeProxyContract),
                _amountFrom
            );
        }
        uint256 amountReceived =
            IHolyWingV2(address(exchangeProxyContract)).executeSwapDirect{value: msg.value}(
                _beneficiary,
                _tokenFrom,
                _tokenTo,
                _amountFrom,
                exchangeFee,
                _convertData
            );
        require(
            amountReceived >= _expectedMinimumReceived,
            "minimum swap amount not met"
        );
    }

    receive() external payable {}

    function claimFees(address _token, uint256 _amount) public {

        require(
            msg.sender == yieldDistributorAddress,
            "yield distributor only"
        );
        if (_token != ETH_TOKEN_ADDRESS) {
            IERC20(_token).safeTransfer(msg.sender, _amount);
        } else {
            payable(msg.sender).sendValue(_amount);
        }
    }

    function emergencyTransfer(
        address _token,
        address _destination,
        uint256 _amount
    ) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        if (_token != ETH_TOKEN_ADDRESS) {
            IERC20(_token).safeTransfer(_destination, _amount);
        } else {
            payable(_destination).sendValue(_amount);
        }
        emit EmergencyTransfer(_token, _destination, _amount);
    }


    bytes32 public constant TRUSTED_EXECUTION_ROLE = keccak256("TRUSTED_EXECUTION");  // trusted execution wallets

    address smartTreasury;
    address tokenMoveAddress;
    address tokenMoveEthLPAddress;

    uint256 public transferFee;

    function setSmartTreasury(address _smartTreasury) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        smartTreasury = _smartTreasury;
    }

    function setTreasuryTokens(address _tokenMoveAddress, address _tokenMoveEthLPAddress) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        tokenMoveAddress = _tokenMoveAddress;
        tokenMoveEthLPAddress = _tokenMoveEthLPAddress;
    }

    function depositToTreasury(uint _tokenMoveAmount, uint _tokenMoveEthAmount) public {

        if (_tokenMoveAmount > 0) {
            IERC20(tokenMoveAddress).safeTransferFrom(msg.sender, smartTreasury, _tokenMoveAmount);
        }
        if (_tokenMoveEthAmount > 0) {
            IERC20(tokenMoveEthLPAddress).safeTransferFrom(msg.sender, smartTreasury, _tokenMoveEthAmount);
        }
        ISmartTreasury(smartTreasury).depositOnBehalf(msg.sender, _tokenMoveAmount, _tokenMoveEthAmount);
    }

    function claimAndBurn(uint _amount) public {

        ISmartTreasury(smartTreasury).claimAndBurnOnBehalf(msg.sender, _amount);
        IBurnable(tokenMoveAddress).burnFrom(msg.sender, _amount);
    }

    function executeSendOnBehalf(address _beneficiary, address _token, address _destination, uint256 _amount, uint256 _bonus) public {

        require(hasRole(TRUSTED_EXECUTION_ROLE, msg.sender), "trusted executor only");

        ISmartTreasury(smartTreasury).spendBonus(_beneficiary, priceCorrection(_bonus));

        if (transferFee == 0) {
            IERC20(_token).safeTransferFrom(_beneficiary, _destination, _amount);
        } else {
            uint256 feeAmount = _amount.mul(transferFee).div(1e18);
            IERC20(_token).safeTransferFrom(_beneficiary, address(this), _amount);
            IERC20(_token).safeTransfer(_destination, _amount.sub(feeAmount));
        }
    }

    function executeDepositOnBehalf(address _beneficiary, address _token, address _pool, uint256 _amount, uint256 _expectedMinimumReceived, bytes memory _convertData, uint256 _bonus) public {

        require(hasRole(TRUSTED_EXECUTION_ROLE, msg.sender), "trusted executor only");

        ISmartTreasury(smartTreasury).spendBonus(_beneficiary, priceCorrection(_bonus));

        depositToPoolOnBehalf(_beneficiary, _pool, _token, _amount, _expectedMinimumReceived, _convertData);
    }

    function executeWithdrawOnBehalf(address _beneficiary, address _pool, uint256 _amount, uint256 _bonus) public {

        require(hasRole(TRUSTED_EXECUTION_ROLE, msg.sender), "trusted executor only");

        ISmartTreasury(smartTreasury).spendBonus(_beneficiary, priceCorrection(_bonus));

        withdrawFromPoolOnBehalf(_beneficiary, _pool, _amount);
    }
    
    function executeSwapOnBehalf(address _beneficiary, address _tokenFrom, address _tokenTo, uint256 _amountFrom, uint256 _expectedMinimumReceived, bytes memory _convertData, uint256 _bonus) public {

        require(hasRole(TRUSTED_EXECUTION_ROLE, msg.sender), "trusted executor only");

        ISmartTreasury(smartTreasury).spendBonus(_beneficiary, priceCorrection(_bonus));

        executeSwapOnBehalf(_beneficiary, _tokenFrom, _tokenTo, _amountFrom, _expectedMinimumReceived, _convertData);
    }

    
    address private USDCUSD_FEED_ADDRESS;

    function setUSDCPriceFeed(address _feed) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        USDCUSD_FEED_ADDRESS = _feed;
    }

    function priceCorrection(uint256 _bonus) internal view returns(uint256) {

        if (USDCUSD_FEED_ADDRESS != address(0)) {
            return _bonus.mul(1e8).div(uint256(IChainLinkFeed(USDCUSD_FEED_ADDRESS).latestAnswer()));
        }
        return _bonus;
    }


    event CardTopup(address indexed account, address token, uint256 valueToken, uint256 valueUSDC);

    address private CARD_PARTNER_ADDRESS;
    address private CARD_TOPUP_TOKEN;

    function setCardPartnerAddress(address _addr) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        CARD_PARTNER_ADDRESS = _addr;
    }

    function setCardTopupToken(address _addr) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        CARD_TOPUP_TOKEN = _addr;
    }

    function cardTopUp(
        address _beneficiary,
        address _token,
        uint256 _amount,
        uint256 _expectedMinimumReceived,
        bytes memory _convertData
    ) public payable {

        if (CARD_TOPUP_TOKEN == _token) {
            IERC20(_token).safeTransferFrom(
                _beneficiary,
                CARD_PARTNER_ADDRESS,
                _amount
            );

            emit CardTopup(_beneficiary, _token, _amount, _amount);
            return;
        }

        if (_token != ETH_TOKEN_ADDRESS) {
            IERC20(_token).safeTransferFrom(
                _beneficiary,
                address(exchangeProxyContract),
                _amount
            );
        }

        uint256 amountReceived =
            IHolyWingV2(address(exchangeProxyContract)).executeSwapDirect{value: msg.value}(
                CARD_PARTNER_ADDRESS,
                _token,
                CARD_TOPUP_TOKEN,
                _amount,
                exchangeFee,
                _convertData
            );

        require(
            amountReceived >= _expectedMinimumReceived,
            "minimum swap amount not met"
        );

        emit CardTopup(_beneficiary, _token, _amount, amountReceived);
    }

    event BridgeTx(address indexed beneficiary, address token, uint256 amount, address target, address relayTarget);

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {

        require(_length + 31 >= _length, "slice_overflow");
        require(_start + _length >= _start, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
                case 0 {
                    tempBytes := mload(0x40)

                    let lengthmod := and(_length, 31)

                    let mc := add(
                        add(tempBytes, lengthmod),
                        mul(0x20, iszero(lengthmod))
                    )
                    let end := add(mc, _length)

                    for {
                        let cc := add(
                            add(
                                add(_bytes, lengthmod),
                                mul(0x20, iszero(lengthmod))
                            ),
                            _start
                        )
                    } lt(mc, end) {
                        mc := add(mc, 0x20)
                        cc := add(cc, 0x20)
                    } {
                        mstore(mc, mload(cc))
                    }

                    mstore(tempBytes, _length)

                    mstore(0x40, and(add(mc, 31), not(31)))
                }
                default {
                    tempBytes := mload(0x40)
                    mstore(tempBytes, 0)

                    mstore(0x40, add(tempBytes, 0x20))
                }
        }

        return tempBytes;
    }

    function bridgeAsset(address _token, uint256 _amount, bytes memory _bridgeTxData, address _relayTarget) public {

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        bridgeAssetDirect(_token, _amount, _bridgeTxData, _relayTarget);
    }

    function bridgeAssetDirect(address _token, uint256 _amount, bytes memory _bridgeTxData, address _relayTarget) internal {

        address targetAddress;
        bytes memory callData = slice(_bridgeTxData, 20, _bridgeTxData.length - 20);
        assembly {
            targetAddress := mload(add(_bridgeTxData, add(0x14, 0)))
        }

        require(targetAddress == 0x6571d6be3d8460CF5F7d6711Cd9961860029D85F, "unknown bridge");

        resetAllowanceIfNeeded(
            IERC20(_token),
            targetAddress,
            _amount
        );

        (bool success, ) = targetAddress.call(callData);
        require(success, "BRIDGE_CALL_FAILED");

        emit BridgeTx(msg.sender, _token, _amount, targetAddress, _relayTarget);
    }

    function swapBridgeAsset(address _tokenFrom, address _tokenTo, uint256 _amountFrom, uint256 _expectedMinimumReceived, bytes memory _convertData, bytes memory _bridgeTxData, address _relayTarget, uint256 _minToMint, uint256 _minDy) public payable {

        require(_tokenFrom != _tokenTo, "same tokens provided");

        if (_tokenFrom != ETH_TOKEN_ADDRESS) {
            IERC20(_tokenFrom).safeTransferFrom(
                msg.sender,
                address(exchangeProxyContract),
                _amountFrom
            );
        }
        uint256 amountReceived =
            IHolyWingV2(address(exchangeProxyContract)).executeSwapDirect{value: msg.value}(
                address(this),
                _tokenFrom,
                _tokenTo,
                _amountFrom,
                exchangeFee,
                _convertData
            );
        require(
            amountReceived >= _expectedMinimumReceived,
            "minimum swap amount not met"
        );

        assembly {
            mstore(add(_bridgeTxData, 184), _minToMint)
            mstore(add(_bridgeTxData, 312), _minDy)
            mstore(add(_bridgeTxData, 440), amountReceived)
        }

        bridgeAssetDirect(_tokenTo, amountReceived, _bridgeTxData, _relayTarget);
    }

    function withdrawAndBridgeAsset(address _beneficiary, address _poolAddress, uint256 _amount, bytes memory _bridgeTxData) public {

        require(hasRole(TRUSTED_EXECUTION_ROLE, msg.sender), "trusted executor only");

        IHolyPoolV2 assetPool = IHolyPoolV2(_poolAddress);
        address poolToken = assetPool.getBaseAsset();
        uint256 amountBefore = IERC20(poolToken).balanceOf(address(this));
        assetPool.withdraw(_beneficiary, _amount);
        uint256 withdrawnAmount = IERC20(poolToken).balanceOf(address(this)).sub(amountBefore);

        if (withdrawFee > 0) {
            uint256 feeAmount = withdrawnAmount.mul(withdrawFee).div(1e18);
            bridgeAssetDirect(poolToken, withdrawnAmount.sub(feeAmount), _bridgeTxData, address(0));
        } else {
            bridgeAssetDirect(poolToken, withdrawnAmount, _bridgeTxData, address(0));
        }
    }
}