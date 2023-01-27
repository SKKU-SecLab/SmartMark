
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

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
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
pragma solidity = 0.8.13;


contract ShirtumStakeV2 is AccessControl, ReentrancyGuard, Pausable {


    using Strings for uint256;

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    event Deposit(uint256 indexed depositId, address indexed user, uint256 amount, uint256 rewards,
                uint256 unlockTime,uint256 apr);
    event Withdraw(uint256 indexed depositId, address indexed user, uint256 amount);
    event Restake(uint256 indexed depositId, address indexed user);

    struct Deposits {
        address user;
        uint256 amount;
        uint256 rewards;
        uint256 total;
        uint256 apr;
        uint256 unlockTime;
        bool withdrawn;
    }

    struct LockingPeriod {
        uint256 lockingTime; //Time to lock the funds (expressed in days)
        uint256 value; //APR
        bool enabled;
    }    

    uint256 public depositId;
    
    uint256[] public allDepositIds;

    mapping (address => uint256[]) public depositsByAddress;
    
    mapping (uint256 => Deposits) public lockedDeposits;

    uint256 public periodsId;
    uint256[] public allPeriodsIds;
    
    mapping (uint256 => LockingPeriod) public lockingPeriods;
                 
    address public token;

    uint256 public availableRewards;

    uint256 public adminWidrawUnlockTime;

    bool public restakeEnabled;

    constructor (address _token,uint256[] memory _lockingPeriods,uint256[] memory intrestRates ) {
        require(_token != address(0x0), 'Shirtum Stake V2: Address must be different to zero address');
        require(_lockingPeriods.length == intrestRates.length, "Shirtum Stake V2: Amounts length must be equals to locking periods length");

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OWNER_ROLE,msg.sender);
        
        token = _token;

        adminWidrawUnlockTime = block.timestamp + 365 days;

        for (uint256 i=0; i<_lockingPeriods.length; i++)
        {
            addLockingPeriod(_lockingPeriods[i], intrestRates[i]);            
        }
    }

    function balanceOf(address user) public view returns (uint256 balance) {

        uint256[] memory ids = depositsByAddress[user];
        for (uint256 i; i < ids.length;i++){
            balance += lockedDeposits[ids[i]].total;
        }

        return balance;
    }

    function validateLockinPeriod(uint256 periodId) internal view{

        require(lockingPeriodExistsById(periodId),"Shirtum Stake V2: locking period doesn't exists");
        require(lockingPeriods[periodId].enabled,"Shirtum Stake V2: locking period is not enabled");
    }

    function validateRewards(uint256 amount,uint256 periodId) internal view returns(uint256 rewards){

        rewards = calculateRewards(amount, periodId);        
        require(availableRewards >= rewards,'Shirtum Stake V2: insuficient funds to pay required rewards');
        return rewards;
    }

    function calculateRewards(uint256 amount, uint256 periodId) public view returns(uint256 rewards){

        uint intrestRate = lockingPeriods[periodId].value;
        uint lockingTime =  lockingPeriods[periodId].lockingTime;
        return (amount * intrestRate * lockingTime) / (100 * 365);
    }

    function stake(uint256 amount,uint256 periodId) public nonReentrant whenNotPaused{        

        validateLockinPeriod(periodId);
        uint256 rewards = validateRewards(amount, periodId);
        uint256 _id = depositId++;
        
        lockedDeposits[_id].user = msg.sender;
        lockedDeposits[_id].amount = amount;
        lockedDeposits[_id].rewards = rewards;
        lockedDeposits[_id].total = amount + rewards;
        lockedDeposits[_id].apr = lockingPeriods[periodId].value;
        lockedDeposits[_id].unlockTime = block.timestamp + (lockingPeriods[periodId].lockingTime * 1 days);
        lockedDeposits[_id].withdrawn = false;

        allDepositIds.push(_id);
        depositsByAddress[msg.sender].push(_id);

        availableRewards -= rewards;

        require(
        IERC20(token).transferFrom(msg.sender, address(this), amount),
        "Shirtum Stake V2: Unable to transfer the tokens"
        );
        emit Deposit(_id,msg.sender, amount,rewards,lockedDeposits[_id].unlockTime,lockingPeriods[periodId].value);
    }

    function restake(uint256 _id,uint256 periodId) public nonReentrant{

        require(restakeEnabled,"Shirtum Stake V2: restake is not enabled");
        validateLockinPeriod(periodId);
        require(!lockedDeposits[_id].withdrawn, "Shirtum Stake V2: Locked token has been already withdrawn");
        require(msg.sender == lockedDeposits[_id].user, "Shirtum Stake V2: Sender is not the owner of the deposit");
                
        uint256 amount = lockedDeposits[_id].total;
        
        uint256 rewards = validateRewards(amount, periodId);
        
        uint256 unlockTime = lockedDeposits[_id].unlockTime > block.timestamp ? lockedDeposits[_id].unlockTime : block.timestamp;

        lockedDeposits[_id].total += rewards;
        lockedDeposits[_id].unlockTime = unlockTime + (lockingPeriods[periodId].lockingTime * 1 days);

        availableRewards -= rewards; 

        emit Deposit(_id,msg.sender, amount,rewards,lockedDeposits[_id].unlockTime,lockingPeriods[periodId].value);
        emit Restake(_id,msg.sender);
    }

    function withdraw(uint256 _id) public nonReentrant{

        require(block.timestamp >= lockedDeposits[_id].unlockTime, "Shirtum Stake V2: Unlock time has not arrived");
        require(msg.sender == lockedDeposits[_id].user, "Shirtum Stake V2: Sender is not the owner of the deposit");
        require(!lockedDeposits[_id].withdrawn, "Shirtum Stake V2: deposit has been already withdrawn");
        
        lockedDeposits[_id].withdrawn = true;        
                        
        uint256 totalByAddress = depositsByAddress[lockedDeposits[_id].user].length;
        for (uint256 i = 0; i < totalByAddress; i++) {
            if (depositsByAddress[lockedDeposits[_id].user][i] == _id) {
                depositsByAddress[lockedDeposits[_id].user][i] = depositsByAddress[lockedDeposits[_id].user][totalByAddress - 1];
                depositsByAddress[lockedDeposits[_id].user].pop();
                break;
            }
        }
        
        require(
            IERC20(token).transfer(msg.sender, lockedDeposits[_id].total),
            "Shirtun Stake V2: Unable to transfer the tokens"
        );
        
        emit Withdraw(_id,msg.sender, lockedDeposits[_id].total);
    }

    function transferRewardFunds(uint256 amount) public nonReentrant{

        availableRewards += amount;
        IERC20(token).transferFrom(msg.sender, address(this), amount);
    }

    function adminWithdraw(uint256 amount,address withdrawalWallet) public onlyRole(OWNER_ROLE){

        require(amount <= availableRewards,"Shirtum Stake V2: can only withdraw upto available rewards balance");
        require(block.timestamp >= adminWidrawUnlockTime,"Shirtum Stake V2: it's not possible to withdraw befor unlock time");
        require(withdrawalWallet != address(0x0), 'Shirtum Stake V2: Address must be different to zero address');

        availableRewards -= amount;
        IERC20(token).transfer(withdrawalWallet, amount);
    }

    function lockingPeriodExists(uint256 lockingTime) internal view returns(bool){

        for (uint256 i;i<allPeriodsIds.length;i++){
            if (lockingPeriods[i].lockingTime == lockingTime){
                return true;
            }
        }
        return false;
    }

    function lockingPeriodExistsById(uint256 periodId) internal view returns(bool){

        return lockingPeriods[periodId].lockingTime > 0;
    }

    function toggleLockingPeriodStatus(uint256 periodId) public onlyRole(OWNER_ROLE){

        require(lockingPeriodExistsById(periodId),"Shirtum Stake V2: locking period doesn't exists");

        lockingPeriods[periodId].enabled = !lockingPeriods[periodId].enabled;
    }

    function addLockingPeriod (uint256 lockingTime, uint256 intrestRate) public onlyRole(OWNER_ROLE){
        require(lockingTime > 0, "Shirtum Stake V2: staking period must be greater than 0");
        require(!lockingPeriodExists(lockingTime),"Shirtum Stake V2: locking period already exists");        
        
        uint256 periodId = periodsId++;        

        lockingPeriods[periodId].lockingTime = lockingTime;
        lockingPeriods[periodId].value = intrestRate;
        lockingPeriods[periodId].enabled = true;

        allPeriodsIds.push(periodId);
    }

    function updateLockingPeriod (uint256 periodId,uint256 lockingTime, uint256 intrestRate) public onlyRole(OWNER_ROLE){
        require(lockingTime > 0, "Shirtum Stake V2: locking time must be greater than 0");
        require(lockingPeriodExistsById(periodId),"Shirtum Stake V2: locking period doesn't exists");        
        
        if (lockingPeriodExists(lockingTime) && lockingPeriods[periodId].lockingTime != lockingTime){
            revert("Locking time already exists for another locking period");
        }

        lockingPeriods[periodId].lockingTime = lockingTime;
        lockingPeriods[periodId].value = intrestRate;
    }

    function getAllLockingPeriodsDetails() view external returns (string[] memory arr)
    {

        arr = new string[](allPeriodsIds.length);
        for (uint256 i;i<allPeriodsIds.length;i++){                        
            arr[i] = string(abi.encodePacked(i.toString(),";",
                            lockingPeriods[i].lockingTime.toString(),";",
                            lockingPeriods[i].value.toString(),";",
                            lockingPeriods[i].enabled ? (uint256(1).toString()) : uint256(0).toString()));
        }
        return arr;
    }

    function getAllLockingPeriodsIds() view external returns (uint256[] memory)
    {

        return allPeriodsIds;
    }

    function getLockingPeriodsDetails(uint256 _id) view external returns (uint256 lockingTime, uint256 value,bool enabled)
    {

        return (
            lockingPeriods[_id].lockingTime,
            lockingPeriods[_id].value,
            lockingPeriods[_id].enabled
        );
    }

    function getAllDepositIds() external view returns (uint256[] memory)
    {

        return allDepositIds;
    }
    
    function getDepositDetails(uint256 _id) external view returns (address _user, uint256 _amount, 
    uint256 _rewards, uint256 _total, uint256 _apr,uint256 _unlockTime, bool _withdrawn)
    {

        return (            
            lockedDeposits[_id].user,
            lockedDeposits[_id].amount,
            lockedDeposits[_id].rewards,
            lockedDeposits[_id].total,
            lockedDeposits[_id].apr,
            lockedDeposits[_id].unlockTime,
            lockedDeposits[_id].withdrawn
        );
    }
    
    function getDepositsByAddress(address _address) view public returns (uint256[] memory)
    {

        return depositsByAddress[_address];
    }

    function pause() public onlyRole(OWNER_ROLE) {

        _pause();
    }

    function unpause() public onlyRole(OWNER_ROLE) {

        _unpause();
    }

    function toggleRestakeEnabledStatus() public onlyRole(OWNER_ROLE){

        restakeEnabled = !restakeEnabled;
    }

    receive () external payable {
      revert();
    }
}