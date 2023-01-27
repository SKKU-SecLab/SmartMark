

pragma solidity ^0.8.0;


interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}


abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}


library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}


interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


interface IMoverUBTStakePoolV2 {

    function getBaseAsset() external view returns(address);


    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function getDepositBalance(address account) external view returns(uint256);


    function borrowToStake(uint256 amount) external returns (uint256);

    function returnInvested(uint256 amount) external;


    function harvestYield(uint256 amount) external;

}


interface IUBTStakingNode {

    function reclaimAmount() external view returns(uint256);


    function reclaimFunds(uint256 amount) external;

}


contract MoverUBTStakePoolV2 is AccessControlUpgradeable, IMoverUBTStakePoolV2 {

    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public constant FINMGMT_ROLE = keccak256("FINMGMT_ROLE");

    event EmergencyTransferSet(
        address indexed token,
        address indexed destination,
        uint256 amount
    );
    event EmergencyTransferExecute(
        address indexed token,
        address indexed destination,
        uint256 amount
    );
    address private emergencyTransferToken;
    address private emergencyTransferDestination;
    uint256 private emergencyTransferTimestamp;
    uint256 private emergencyTransferAmount;

    address public baseAsset;

    uint256 public totalAssetAmount;

    uint256 public totalShareAmount;

    mapping(address => uint256) public shares;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(
        address indexed account,
        uint256 amount
    );

    event YieldRealized(uint256 amount);

    bool depositsEnabled;

	uint256 public profitFee;
    address public feeHolder;

    uint256 public inceptionTimestamp; // inception timestamp

    function initialize(address _baseAsset) public initializer {

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(FINMGMT_ROLE, _msgSender());

        baseAsset = _baseAsset;
        totalShareAmount = 1e6;
        totalAssetAmount = 1e6;
        depositsEnabled = true;
		profitFee = 0;

        inceptionTimestamp = block.timestamp;
    }

    function getBaseAsset() public view override returns (address) {

        return baseAsset;
    }

    function getDepositBalance(address _beneficiary)
        public
        override
        view
        returns (uint256)
    {

        return shares[_beneficiary].mul(baseAssetPerShare()).div(1e18);
    }

    function baseAssetPerShare() public view returns (uint256) {

        return totalAssetAmount.mul(1e18).div(totalShareAmount);
    }

    function setDepositsEnabled(bool _enabled) public {

        require(hasRole(FINMGMT_ROLE, msg.sender), "finmgmt only");
        depositsEnabled = _enabled;
    }

    function deposit(uint256 _amount)
        public
        override
    {

        require(depositsEnabled, "deposits disabled");

        IERC20Upgradeable(baseAsset).safeTransferFrom(msg.sender, address(this), _amount);

        uint256 assetPerShare = baseAssetPerShare();
        uint256 sharesToDeposit = _amount.mul(1e18).div(assetPerShare);
        totalShareAmount = totalShareAmount.add(sharesToDeposit);
        totalAssetAmount = totalAssetAmount.add(_amount);
        shares[msg.sender] = shares[msg.sender].add(sharesToDeposit);

        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) public override {

        uint256 sharesAvailable = shares[msg.sender];
        uint256 assetPerShare = baseAssetPerShare();
        uint256 assetsAvailable = sharesAvailable.mul(assetPerShare).div(1e18);
        require(_amount <= assetsAvailable, "requested amount exceeds balance");

        uint256 currentBalance = IERC20Upgradeable(baseAsset).balanceOf(address(this));
        if (currentBalance >= _amount) {
            performWithdraw(msg.sender, _amount);
            return;
        }

        uint256 amountToReclaim = _amount.sub(currentBalance);
        uint256 reclaimedFunds = retrieveFunds(amountToReclaim);
        
        require(reclaimedFunds >= amountToReclaim, "cannot reclaim funds");
        performWithdraw(msg.sender, _amount);
    }

    function performWithdraw(
        address _beneficiary,
        uint256 _amount
    ) internal {

        uint256 sharesToWithdraw =
            _amount.mul(1e18).div(baseAssetPerShare());

        require(
            sharesToWithdraw <= shares[_beneficiary],
            "requested pool share exceeded"
        );

        IERC20Upgradeable(baseAsset).safeTransfer(_beneficiary, _amount);

        shares[_beneficiary] = shares[_beneficiary].sub(sharesToWithdraw);
        totalShareAmount = totalShareAmount.sub(sharesToWithdraw);
        totalAssetAmount = totalAssetAmount.sub(_amount);

        emit Withdraw(_beneficiary, _amount);
    }

    function harvestYield(uint256 _amountYield) public override {

        IERC20Upgradeable(baseAsset).safeTransferFrom(
            msg.sender,
            address(this),
            _amountYield
        );

		uint256 amountFee = _amountYield.mul(profitFee).div(1e18);

		if (amountFee > 0 && feeHolder != address(0)) {
			IERC20Upgradeable(baseAsset).transfer(feeHolder, amountFee);
    		_amountYield = _amountYield.sub(amountFee);
		}

        totalAssetAmount = totalAssetAmount.add(_amountYield);

        emit YieldRealized(_amountYield);
    }

	function setFeeHolderAddress(address _address) public {

	    require(hasRole(FINMGMT_ROLE, msg.sender), "finmgmt only");
        feeHolder = _address;
	}

	function setProfitFee(uint256 _fee) public {

	    require(hasRole(FINMGMT_ROLE, msg.sender), "finmgmt only");
		require(_fee <= 1e18, "fee >1.0");
        profitFee = _fee;
	}

    function getDailyAPY() public view returns (uint256) {

        uint256 secondsFromInception = block.timestamp.sub(inceptionTimestamp);

        return
            baseAssetPerShare()
                .sub(1e18)
                .mul(100) // substract starting share/baseAsset value 1.0 (1e18) and multiply by 100 to get percent value
                .mul(86400)
                .div(secondsFromInception); // fractional representation of how many days passed
    }

    function emergencyTransferTimelockSet(
        address _token,
        address _destination,
        uint256 _amount
    ) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        emergencyTransferTimestamp = block.timestamp;
        emergencyTransferToken = _token;
        emergencyTransferDestination = _destination;
        emergencyTransferAmount = _amount;

        emit EmergencyTransferSet(_token, _destination, _amount);
    }

    function emergencyTransferExecute() public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        require(
            block.timestamp > emergencyTransferTimestamp + 24 * 3600,
            "timelock too early"
        );
        require(
            block.timestamp < emergencyTransferTimestamp + 72 * 3600,
            "timelock too late"
        );

        IERC20Upgradeable(emergencyTransferToken).safeTransfer(
            emergencyTransferDestination,
            emergencyTransferAmount
        );

        emit EmergencyTransferExecute(
            emergencyTransferToken,
            emergencyTransferDestination,
            emergencyTransferAmount
        );
        emergencyTransferTimestamp = 0;
        emergencyTransferToken = address(0);
        emergencyTransferDestination = address(0);
        emergencyTransferAmount = 0;
    }

    IUBTStakingNode[] public stakeNodeContracts;
    mapping(address => uint256) public stakeNodeContractsStatuses;

    event UBTStaked(address indexed stakeNodeContract, uint256 amount);
    event UBTUnstaked(address indexed stakeNodeContract, uint256 amount);
    event UBTReclaimed(address indexed stakeNodeContract, uint256 amount);

    function addStakingNode(address _address) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        stakeNodeContracts.push(IUBTStakingNode(_address));
        stakeNodeContractsStatuses[_address] = 1;
    }

    function setStakingNodeStatus(address _address, uint256 _status) public {

        require(hasRole(FINMGMT_ROLE, msg.sender), "finmgmt only");
        stakeNodeContractsStatuses[_address] = _status;
    }

    function removeStakingNodeContract(uint256 index) public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "admin only");
        stakeNodeContractsStatuses[address(stakeNodeContracts[index])] = 0;
        stakeNodeContracts[index] = stakeNodeContracts[stakeNodeContracts.length-1];
        stakeNodeContracts.pop();
    }

    function borrowToStake(uint256 _amount) public override returns (uint256) {

        require(
            stakeNodeContractsStatuses[msg.sender] == 1,
            "active invest proxy only"
        );

        IERC20Upgradeable(baseAsset).safeTransfer(msg.sender, _amount);

        emit UBTStaked(msg.sender, _amount);
        return _amount;
    }

    function returnInvested(uint256 _amount) public override {

        require(stakeNodeContractsStatuses[msg.sender] > 0, "invest proxy only"); // statuses 1 (active) or 2 (withdraw only) are ok

        IERC20Upgradeable(baseAsset).safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );

        emit UBTUnstaked(msg.sender, _amount);
    }

    function retrieveFunds(uint256 _amount) internal returns (uint256) {

        uint256 amountTotal = 0;

        uint256 length = stakeNodeContracts.length;
        uint256[] memory amounts = new uint256[](length);
        uint256[] memory indexes = new uint256[](length);

        for (uint256 i; i < length; i++) {
            amounts[i] = stakeNodeContracts[i].reclaimAmount();
            if (
                amounts[i] >= _amount &&
                stakeNodeContractsStatuses[address(stakeNodeContracts[i])] > 0
            ) {
                stakeNodeContracts[i].reclaimFunds(_amount);
                emit UBTReclaimed(address(stakeNodeContracts[i]), _amount);
                return _amount;
            }
            indexes[i] = i;
            amountTotal = amountTotal.add(amounts[i]);
        }

        require (amountTotal > _amount, "insufficient UBT");

        for (uint256 i = length - 1; i >= 0; i--) {
            uint256 picked = amounts[i];
            uint256 pickedIndex = indexes[i];
            uint256 j = i + 1;
            while ((j < length) && (amounts[j] > picked)) {
                amounts[j - 1] = amounts[j];
                indexes[j - 1] = indexes[j];
                j++;
            }
            amounts[j - 1] = picked;
            indexes[j - 1] = pickedIndex;
            if (i == 0) {
                break; // uint256 won't be negative
            }
        }

        uint256 totalReclaimed = 0;
        for (uint256 i = 0; i < length; i++) {
            uint256 amountToWithdraw = amounts[i];
            if (amountToWithdraw > _amount.sub(totalReclaimed)) {
                amountToWithdraw = _amount.sub(totalReclaimed);
            }
            stakeNodeContracts[indexes[i]].reclaimFunds(amountToWithdraw);
            totalReclaimed = totalReclaimed.add(amountToWithdraw);
            emit UBTReclaimed(address(stakeNodeContracts[indexes[i]]), amountToWithdraw);
            if (totalReclaimed >= _amount) {
                break;
            }
        }
        return totalReclaimed;
    }
}