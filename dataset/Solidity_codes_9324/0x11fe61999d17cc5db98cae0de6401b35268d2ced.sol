




pragma solidity ^0.8.0;


library SafeMath {

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}



pragma solidity ^0.8.0;

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



pragma solidity ^0.8.0;



library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



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
}



pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}



pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.8.0;




interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
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
}



pragma solidity ^0.8.0;

interface TokenInterface{

    function burnFrom(address _from, uint _amount) external;

    function mintTo(address _to, uint _amount) external;

}




pragma solidity ^0.8.0;






contract Staking is AccessControl {


    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    TokenInterface private fundamenta;  
    


    bytes32 public constant _STAKING = keccak256("_STAKING");
    bytes32 public constant _RESCUE = keccak256("_RESCUE");
    bytes32 public constant _ADMIN = keccak256("_ADMIN");

    
    uint public stakeCalc;
    uint public stakeCap;
    uint public rewardsWindow;
    uint public stakeLockMultiplier;
    bool public stakingOff;
    bool public paused;
    bool public emergencyWDoff;
    address private defaultAdmin = 0x82Ab0c69b6548e6Fd61365FeCc3256BcF70dc448;
    

    address[] internal stakeholders;
    mapping(address => uint) internal stakes;
    mapping(address => uint) internal rewards;
    mapping(address => uint) internal lastWithdraw;
    
    
    event StakeCreated(address _stakeholder, uint _stakes, uint _blockHeight);
    event rewardsCompunded(address _stakeholder, uint _rewardsAdded, uint _blockHeight);
    event StakeRemoved(address _stakeholder, uint _stakes, uint rewards, uint _blockHeight);
    event RewardsWithdrawn(address _stakeholder, uint _rewards, uint blockHeight);
    event TokensRescued (address _pebcak, address _ERC20, uint _ERC20Amount, uint _blockHeightRescued);
    event ETHRescued (address _pebcak, uint _ETHAmount, uint _blockHeightRescued);


    constructor(){
        stakingOff = true;
        emergencyWDoff = true;
        stakeCalc = 500;
        stakeCap = 3e22;
        rewardsWindow = 6500;
        stakeLockMultiplier = 2;
        _setupRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    
    function setAddress(TokenInterface _token) public {

        require(hasRole(_ADMIN, msg.sender));
        fundamenta = _token;
    }
    

    modifier pause() {

        require(!paused, "TokenStaking: Contract is Paused");
        _;
    }

    modifier stakeToggle() {

        require(!stakingOff, "TokenStaking: Staking is not currently active");
        _;
    }
    
    modifier emergency() {

        require(!emergencyWDoff, "TokenStaking: Emergency Withdraw is not enabled");
        _;
    }



    function createStake(uint _stake) public pause stakeToggle {

        require(rewardsAccrued() == 0);
        rewards[msg.sender] = rewards[msg.sender].add(rewardsAccrued());
        if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
        stakes[msg.sender] = stakes[msg.sender].add(_stake);
        fundamenta.burnFrom(msg.sender, _stake);
        require(stakes[msg.sender] <= stakeCap, "TokenStaking: Can't Stake More than allowed moneybags"); 
        lastWithdraw[msg.sender] = block.number;
        emit StakeCreated(msg.sender, _stake, block.number);
    }
    
    
    function removeStake(uint _stake) public pause {

        uint unlockWindow = rewardsWindow.mul(stakeLockMultiplier);
        require(block.number >= lastWithdraw[msg.sender].add(unlockWindow), "TokenStaking: FMTA has not been staked for long enough");
        rewards[msg.sender] = rewards[msg.sender].add(rewardsAccrued());
        uint totalAccrued;
        if(stakes[msg.sender] == 0 && _stake != 0 ) {
            revert("TokenStaking: You don't have any tokens staked");
        }else if (stakes[msg.sender] != 0 && _stake != 0) {
            totalAccrued = rewardsAccrued().add(_stake);
            fundamenta.mintTo(msg.sender, totalAccrued);
            stakes[msg.sender] = stakes[msg.sender].sub(_stake);
            lastWithdraw[msg.sender] = block.number;
        }
        
        if (stakes[msg.sender] == 0) {
            removeStakeholder(msg.sender);
        }
        emit StakeRemoved(msg.sender, _stake, totalAccrued, block.number);
    }
    
    
    function rewardsAccrued() public view returns (uint) {

        uint multiplier = block.number.sub(lastWithdraw[msg.sender]).div(rewardsWindow);
        uint _rewardsAccrued = calculateReward(msg.sender).mul(multiplier);
        return _rewardsAccrued;
        
    }
    
     
    function withdrawReward() public pause stakeToggle {

        rewards[msg.sender] = rewards[msg.sender].add(rewardsAccrued());
        if(lastWithdraw[msg.sender] == 0) {
           revert("TokenStaking: You cannot withdraw if you hve never staked");
        } else if (lastWithdraw[msg.sender] != 0){
            require(block.number > lastWithdraw[msg.sender].add(rewardsWindow), "TokenStaking: It hasn't been enough time since your last withdrawl");
            fundamenta.mintTo(msg.sender, rewardsAccrued());
            lastWithdraw[msg.sender] = block.number;
            emit RewardsWithdrawn(msg.sender, rewardsAccrued(), block.number);
        }
    }
    
    
    function compoundRewards() public pause stakeToggle {

        rewards[msg.sender] = rewards[msg.sender].add(rewardsAccrued());
        if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
        stakes[msg.sender] = stakes[msg.sender].add(rewardsAccrued());
        require(stakes[msg.sender] <= stakeCap, "TokenStaking: Can't Stake More than allowed moneybags"); 
        lastWithdraw[msg.sender] = block.number;
        emit rewardsCompunded(msg.sender, rewardsAccrued(), block.number);
    }
    
    
    function emergencyWithdrawRewardAndStakes() public emergency {

        rewards[msg.sender] = rewards[msg.sender].add(rewardsAccrued());
        fundamenta.mintTo(msg.sender, rewardsAccrued().add(stakes[msg.sender]));
        stakes[msg.sender] = stakes[msg.sender].sub(stakes[msg.sender]);
        removeStakeholder(msg.sender);
    }
    
    
    function lastWdHeight() public view returns (uint) {

        return lastWithdraw[msg.sender];
    }
    
    
    function stakeUnlockWindow() external view returns (uint) {

        uint unlockWindow = rewardsWindow.mul(stakeLockMultiplier);
        uint stakeWindow = lastWithdraw[msg.sender].add(unlockWindow);
        return stakeWindow;
    }
    
    
    function setStakeMultiplier(uint _newMultiplier) public pause stakeToggle {

        require(hasRole(_STAKING, msg.sender));
        stakeLockMultiplier = _newMultiplier;
    }
    
    
    function stakeOf (address _stakeholder) public view returns(uint) {
        return stakes[_stakeholder];
    }
    
    
    function totalStakes() public view returns(uint) {

        uint _totalStakes = 0;
        for (uint s = 0; s < stakeholders.length; s += 1) {
            _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
        }
        
        return _totalStakes;
    }
    

    function isStakeholder(address _address) public view returns(bool, uint) {

        for (uint s = 0; s < stakeholders.length; s += 1) {
            if (_address == stakeholders[s]) return (true, s);
        }
        
        return (false, 0);
    }
    
    
    function addStakeholder(address _stakeholder) internal pause stakeToggle {

        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }
    
    
    function removeStakeholder(address _stakeholder) internal {

        (bool _isStakeholder, uint s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        }
    }
    
    function getStakeholders() public view returns (uint _numOfStakeholders){

        return stakeholders.length;
    }
    
    function getByIndex(uint i) public view returns (address) {

    return stakeholders[i];
}
    
    
    function totalRewardsOf(address _stakeholder) external view returns(uint) {

        return rewards[_stakeholder];
    }
    
    
    function totalRewardsPaid() external view returns(uint) {

        uint _totalRewards = 0;
        for (uint s = 0; s < stakeholders.length; s += 1){
            _totalRewards = _totalRewards.add(rewards[stakeholders[s]]);
        }
        
        return _totalRewards;
    }
    
    
    function setStakeCalc(uint _stakeCalc) external pause stakeToggle {

        require(hasRole(_STAKING, msg.sender));
        stakeCalc = _stakeCalc;
    }
    
    
    function setStakeCap(uint _stakeCap) external pause stakeToggle {

        require(hasRole(_STAKING, msg.sender));
        stakeCap = _stakeCap;
    }
    
    
    function stakeOff(bool _stakingOff) public {

        require(hasRole(_STAKING, msg.sender));
        stakingOff = _stakingOff;
    }
    
    
    function setRewardsWindow(uint _newWindow) external pause stakeToggle {

        require(hasRole(_STAKING, msg.sender));
        rewardsWindow = _newWindow;
    }
    
    
    function calculateReward(address _stakeholder) public view returns(uint) {

        return stakes[_stakeholder] / stakeCalc;
    }
    
    
    function setEmergencyWDoff(bool _emergencyWD) external {

        require(hasRole(_ADMIN, msg.sender));
        emergencyWDoff = _emergencyWD;
    }
    



    function setPaused(bool _paused) external {

        require(hasRole(_ADMIN, msg.sender));
        paused = _paused;
    }
    
    
    function mistakenERC20DepositRescue(address _ERC20, address _pebcak, uint _ERC20Amount) public {

        require(hasRole(_RESCUE, msg.sender),"TokenStaking: Message Sender must be _RESCUE");
        IERC20(_ERC20).safeTransfer(_pebcak, _ERC20Amount);
        emit TokensRescued (_pebcak, _ERC20, _ERC20Amount, block.number);
    }

    function mistakenDepositRescue(address payable _pebcak, uint _etherAmount) public {

        require(hasRole(_RESCUE, msg.sender),"TokenStaking: Message Sender must be _RESCUE");
        _pebcak.transfer(_etherAmount);
        emit ETHRescued (_pebcak, _etherAmount, block.number);
    }

}