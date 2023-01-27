
pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;

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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;


interface IAccessControlUpgradeable {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

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
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");

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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
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
}// MIT

pragma solidity ^0.8.0;

library ECDSAUpgradeable {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}pragma solidity >=0.6.0;

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity >=0.8.0;


abstract contract Manageable is AccessControlUpgradeable {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    modifier onlyManager() {
        require(
            hasRole(MANAGER_ROLE, msg.sender),
            "Caller is not a manager"
        );
        _;
    }

    function setupRole(bytes32 role, address account) external onlyManager {
        _setupRole(role, account);
    }

    function isManager(address account) external view returns (bool) {
        return hasRole(MANAGER_ROLE, account);
    }
}// MIT

pragma solidity >=0.8.0;


abstract contract Migrateable is AccessControlUpgradeable {
    bytes32 public constant MIGRATOR_ROLE = keccak256("MIGRATOR_ROLE");

    modifier onlyMigrator() {
        require(
            hasRole(MIGRATOR_ROLE, msg.sender),
            "Caller is not a migrator"
        );
        _;
    }
}// MIT
pragma solidity >=0.8.0;


contract Vesting is AccessControlUpgradeable, Manageable, Migrateable {

    event ItemCreated(address indexed token, uint256 amount);
    event BonusWithdrawn(address indexed vester, string name, uint256 amount);
    event VesterCreated(address indexed vester, string name, uint256 amount);
    event InitialWithdrawn(address indexed vester, string name, uint256 amount);
    event UnlockWithdrawn(address indexed vester, string name, uint256 amount, uint256 count);

    struct AddMultipleVesters {
        string[] _name;
        address[] _vester;
        uint104[] _amount;
        uint8[] _percentInitialAmount;
        uint8[] _percentAmountPerWithdraw;
        uint8[] _percentBonus;
    }

    struct Vested {
        uint104 amount;
        uint104 totalWithdrawn;
        uint8 percentInitial;
        uint8 percentAmountPerWithdraw;
        uint8 percentBonus;
        uint8 withdrawals;
        uint8 status;
        bool bonusWithdrawn;
    }

    struct Item {
        address token;
        string name;
        uint256 amount;
        uint256 startTime;
        uint256 cliffTime;
        uint256 timeBetweenUnlocks;
        uint256 bonusUnlockTime;
        address signer;
    }

    struct VestedItem {
        Vested record;
        Item item;
        bool withdrawRemainder;
        bool canceled;
    }

    mapping(address => mapping(string => Vested)) public records;
    mapping(address => string[]) userVests;
    mapping(string => Item) public items;
    string[] internal names;

    mapping(string => bool) public withdrawRemainder;
    mapping(string => bool) public canceled;

    function addItem(
        address _token,
        string memory _name,
        uint256 _amount,
        uint256 _startTime,
        uint256 _cliffTime,
        uint256 _timeBetweenUnlocks,
        uint256 _bonusUnlockTime,
        address _signer
    ) external onlyManager {

        require(items[_name].amount == 0, 'VESTING: Item already exists');

        TransferHelper.safeTransferFrom(address(_token), msg.sender, address(this), _amount);

        names.push(_name);
        items[_name] = Item({
            token: _token,
            name: _name,
            amount: _amount,
            startTime: _startTime,
            cliffTime: _cliffTime,
            timeBetweenUnlocks: _timeBetweenUnlocks,
            bonusUnlockTime: _bonusUnlockTime,
            signer: _signer
        });

        emit ItemCreated(_token, _amount);
    }

    function editItem(
        string memory _name,
        uint256 _startTime,
        uint256 _cliffTime,
        uint256 _timeBetweenUnlocks,
        uint256 _bonusUnlockTime
    ) external onlyManager {

        require(items[_name].amount != 0, 'VESTING: Item does not exist');

        if (_startTime != 0) items[_name].startTime = _startTime;
        if (_cliffTime != 0) items[_name].cliffTime = _cliffTime;
        if (_timeBetweenUnlocks != 0) items[_name].timeBetweenUnlocks = _timeBetweenUnlocks;
        if (_bonusUnlockTime != 0) items[_name].bonusUnlockTime = _bonusUnlockTime;
    }

    function setCanceled(string memory _name, bool _canceled) external onlyManager {

        canceled[_name] = _canceled;
    }

    function setWithdrawRemainder(string memory _name, bool _remainder) external onlyManager {

        withdrawRemainder[_name] = _remainder;
    }

    function withdrawTokens(address _token, address _to) external onlyManager {

        IERC20(_token).transfer(_to, IERC20(_token).balanceOf(address(this)));
    }

    function addTokenToItem(
        string memory _name,
        address _token,
        uint256 _amount
    ) external onlyManager {

        require(items[_name].amount != 0, 'VESTING: Item does not exist');
        TransferHelper.safeTransferFrom(address(_token), msg.sender, address(this), _amount);
        items[_name].amount += _amount;
    }

    function addVester(
        string memory _name,
        address _vester,
        uint8 _percentInitialAmount,
        uint8 _percentAmountPerWithdraw,
        uint8 _percentBonus,
        uint104 _amount
    ) internal {

        require(records[_vester][_name].amount == 0, 'VESTING: Record already exists');
        require(items[_name].amount != 0, 'VESTING: Item does not exist');

        userVests[_vester].push(_name);
        records[_vester][_name] = Vested({
            amount: _amount,
            totalWithdrawn: 0,
            percentAmountPerWithdraw: _percentAmountPerWithdraw,
            percentInitial: _percentInitialAmount,
            percentBonus: _percentBonus,
            withdrawals: 0,
            status: 0,
            bonusWithdrawn: false
        });

        emit VesterCreated(_vester, _name, _amount);
    }

    function addMultipleVesters(AddMultipleVesters calldata vester) external onlyManager {

        for (uint256 i = 0; i < vester._name.length; i++) {
            addVester(
                vester._name[i],
                vester._vester[i],
                vester._percentInitialAmount[i],
                vester._percentAmountPerWithdraw[i],
                vester._percentBonus[i],
                vester._amount[i]
            );
        }
    }

    function addVesterCryptography(
        bytes memory signature,
        string memory _name,
        uint8 _percentInitialAmount,
        uint8 _percentAmountPerWithdraw,
        uint8 _percentBonus,
        uint104 _amount
    ) external {

        bytes32 messageHash =
            sha256(
                abi.encode(
                    _name,
                    _percentInitialAmount,
                    _percentAmountPerWithdraw,
                    _percentBonus,
                    _amount,
                    msg.sender
                )
            );
        bool recovered = ECDSAUpgradeable.recover(messageHash, signature) == items[_name].signer;

        require(recovered == true, 'VESTING: Record not found');

        addVester(
            _name,
            msg.sender,
            _percentInitialAmount,
            _percentAmountPerWithdraw,
            _percentBonus,
            _amount
        );

        if (items[_name].startTime < block.timestamp) {
            withdraw(_name);
        }
    }

    function withdraw(string memory name) public {

        require(canceled[name] == false, 'VESTING: Vesting has been canceled');

        Item memory record = items[name];
        Vested storage userRecord = records[msg.sender][name];
        require(userRecord.amount != 0, 'VESTING: User Record does not exist');
        require(userRecord.totalWithdrawn < userRecord.amount, 'VESTING: Exceeds allowed amount');
        uint256 amountToWithdraw;
        uint256 totalAmountToWithdraw;

        if (withdrawRemainder[name]) {
            uint256 leftToWithdraw = userRecord.amount - userRecord.totalWithdrawn;

            userRecord.totalWithdrawn = userRecord.amount;

            IERC20(record.token).transfer(msg.sender, leftToWithdraw);

            bonus(name);

            emit UnlockWithdrawn(msg.sender, name, leftToWithdraw, userRecord.withdrawals);
            return;
        }

        if (userRecord.withdrawals == 0) {
            userRecord.withdrawals++;
            require(record.startTime < block.timestamp, 'VESTING: Has not begun yet');

            amountToWithdraw =
                (uint256(userRecord.percentInitial) * uint256(userRecord.amount)) /
                100;

            userRecord.totalWithdrawn += uint104(amountToWithdraw);
            require(
                userRecord.totalWithdrawn <= userRecord.amount,
                'VESTING: Exceeds allowed amount'
            );

            totalAmountToWithdraw = amountToWithdraw;

            emit InitialWithdrawn(msg.sender, name, amountToWithdraw);
        }

        if (
            record.startTime + record.cliffTime < block.timestamp &&
            userRecord.percentInitial != 100
        ) {


            uint256 maxNumberOfWithdrawals =
                userRecord.percentAmountPerWithdraw == 0
                    ? 1
                    : ((100 - userRecord.percentInitial) / userRecord.percentAmountPerWithdraw); //example for 15% initial and 17% for 5 months, the max number will end up being 6

            uint256 numberOfAllowedWithdrawals =
                ((block.timestamp - (record.startTime + record.cliffTime)) /
                    record.timeBetweenUnlocks) + 1; // add one for initial withdraw

            numberOfAllowedWithdrawals = numberOfAllowedWithdrawals < maxNumberOfWithdrawals
                ? numberOfAllowedWithdrawals
                : maxNumberOfWithdrawals;

            if (
                numberOfAllowedWithdrawals >= userRecord.withdrawals &&
                record.timeBetweenUnlocks != 0
            ) {
                uint256 withdrawalsToPay = numberOfAllowedWithdrawals - userRecord.withdrawals + 1;

                amountToWithdraw =
                    ((uint256(userRecord.percentAmountPerWithdraw) * uint256(userRecord.amount)) /
                        100) *
                    withdrawalsToPay;

                userRecord.totalWithdrawn += uint104(amountToWithdraw);
                userRecord.withdrawals += uint8(withdrawalsToPay);

                totalAmountToWithdraw += amountToWithdraw;

                emit UnlockWithdrawn(msg.sender, name, amountToWithdraw, userRecord.withdrawals);
            }
        }
        IERC20(record.token).transfer(msg.sender, totalAmountToWithdraw);
    }

    function bonus(string memory name) public {

        require(canceled[name] == false, 'VESTING: Vesting has been canceled');

        Item memory record = items[name];
        Vested storage userRecord = records[msg.sender][name];

        require(userRecord.bonusWithdrawn == false, 'VESTING: Bonus already withdrawn');

        if (!withdrawRemainder[name]) {
            require(record.bonusUnlockTime < block.timestamp, 'VESTING: Bonus is not unlocked yet');
        }

        userRecord.bonusWithdrawn = true;

        IERC20(record.token).transfer(
            msg.sender,
            (uint256(userRecord.percentBonus) * uint256(userRecord.amount)) / 100
        );

        emit BonusWithdrawn(
            msg.sender,
            name,
            (uint256(userRecord.percentBonus) * uint256(userRecord.amount)) / 100
        );
    }

    function getNamesLength() public view returns (uint256) {

        return names.length;
    }

    function getNames(uint256 from, uint256 to) public view returns (string[] memory) {

        string[] memory _names = new string[](to - from);

        uint256 count = 0;
        for (uint256 i = from; i < to; i++) {
            _names[count] = names[i];
            count++;
        }

        return _names;
    }

    function getItems(uint256 from, uint256 to) public view returns (Item[] memory) {

        Item[] memory _items = new Item[](to - from);

        uint256 count = 0;
        for (uint256 i = from; i < to; i++) {
            _items[count] = items[names[i]];
            count++;
        }

        return _items;
    }

    function getAllItems() public view returns (Item[] memory) {

        uint256 length = getNamesLength();

        Item[] memory _items = new Item[](length);

        for (uint256 i = 0; i < length; i++) {
            _items[i] = items[names[i]];
        }

        return _items;
    }

    function getUserVestsLength(address user) public view returns (uint256) {

        return userVests[user].length;
    }

    function getUserItems(
        address user,
        uint256 from,
        uint256 to
    ) public view returns (VestedItem[] memory) {

        VestedItem[] memory _items = new VestedItem[](to - from);
        string[] memory keys = userVests[user];

        uint256 count = 0;
        for (uint256 i = from; i < to; i++) {
            _items[count].item = items[keys[i]];
            _items[count].record = records[user][keys[i]];
            _items[count].canceled = canceled[keys[i]];
            _items[count].withdrawRemainder = withdrawRemainder[keys[i]];
            count++;
        }

        return _items;
    }

    function initialize(address _manager, address _migrator) external initializer {

        _setupRole(MANAGER_ROLE, _manager);
        _setupRole(MIGRATOR_ROLE, _migrator);
    }
}