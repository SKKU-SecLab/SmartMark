



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}






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
}





interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}





interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
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
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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




interface IERC20 {

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


    function burn(uint256 amount) external;


    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ERC20{

  function deposit() external payable;

  function withdraw(uint256 amount) external;

}


library Address {

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



contract FontStaking is AccessControl {


    using SafeMath for uint;    
    using SafeMath for uint8;
    using SafeMath for uint16;    
    using SafeMath for uint256;    
    using SafeERC20 for IERC20;



    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    ERC20 weth;


    address ownerAddress; //Main admin of this contract

    uint256 taxFee = 400; // 1 = 0.01% for premature unstake
    address font_token_address = 0x4C25Bdf026Ea05F32713F00f73Ca55857Fbf6342; //token address of the font
    uint256 public maxSnapshotLifetime = 259200; // 3 days Max freshness of snapshot before reward distribution
    uint256 public minSnapshotInterval = 7776000; //3 months this is used for both snapshot and reward distribution
    uint256 public minStakeTime = 7776000; //90 days in second
    uint256 public minStakeAmount = 500 * (10**18); // Minimum eligible fonts for staking 
    
    
    IERC20 public FONT_ERC20; //Font token address

    bool public stakingPaused; //Status of staking 
    uint256 public totalTaxAmount = 0; //Total tax accumulated, subjected to reset from 0 on burn 
    uint256 public lastRewardTime = 0; //time stamp of last time reward distributed 
    uint256 public stakeCounter; //Current stake ID. Counter
    uint256 public totalStaked = 0; //Total $FONTs currently staked
    uint256 public lastSnapshotTime; //Last time the snapshot made

    uint256 firstUnclaimedStakeId = 1;    

    uint256 totalEligibleFontsForRewards = 0; //This resets often

    mapping (address => bool) private excludedAccount; 

    mapping (address => uint256) public usersStake; 

    struct RewardToken { 
        uint256 minBalance; //Minimum balance to send rewards / No use of spending 1$ to 1000 people. 
        bool status; //current status or this erc token
    }
    mapping (address => uint256) public rewardTokens;
    
        struct TT {
            address a;
            bool b;
        }    

    struct stakingInfo {
        uint256 amount;
        uint256 lockedTime;
        uint256 unstakeTime;
        uint256 duration;
        address user;
        bool claimed;
    }
    mapping(uint256 => stakingInfo) private StakeMap; 


    mapping(address => uint256[]) private userStakeIds;


    mapping (uint256 => mapping(address => uint256)) public SnapShot; //User balance based on the snapshot 
    mapping (uint256 => address[]) private SnapShotUsers; //list of eligible users per snapshot 

    mapping (address => mapping(address => uint256)) public UserRewardBalance;


    constructor(address _font_token_address, address _weth)  {
        stakeCounter = 1;
        FONT_ERC20 = IERC20(_font_token_address); 
        ownerAddress = msg.sender;
        stakingPaused = false;
        _setupRole(ADMIN_ROLE, msg.sender); // Assign admin role to contract creator

        weth = ERC20(_weth);

    }

    event LogStake(address _address, uint256 _stake_id, uint256 amount); 
    function stake(uint256 _amount) public {

        require(!stakingPaused, 'Paused');
        require(_amount > minStakeAmount, 'Minimum');

        uint256 _stake_id = stakeCounter;

        usersStake[msg.sender] += _amount; //usersStake[msg.sender].add(_amount);
        

        StakeMap[_stake_id].amount = _amount;
        StakeMap[_stake_id].claimed = false;
        StakeMap[_stake_id].lockedTime = block.timestamp;
        StakeMap[_stake_id].duration = minStakeTime;
        StakeMap[_stake_id].user = msg.sender;
        
        userStakeIds[msg.sender].push(_stake_id);

        totalStaked += _amount;

        stakeCounter++;
        
        FONT_ERC20.safeTransferFrom(msg.sender, address(this), _amount);
        
        emit LogStake(msg.sender, _stake_id,  _amount);
    }
    
    event UnStaked(address _address, uint256 _stake_id, uint256 amount, uint256 _tax);
    function unStake(uint256 _stake_id) external {

        require(StakeMap[_stake_id].user == msg.sender, 'Denied');
        require(!StakeMap[_stake_id].claimed, 'Claimed');
        require(usersStake[msg.sender] > 0, 'No balance');

        uint256 _amount = StakeMap[_stake_id].amount; //@todo no need this variable
        uint256 _taxfee = 0;

        if((StakeMap[_stake_id].lockedTime + StakeMap[_stake_id].duration) > block.timestamp) {
            _taxfee = _amount.mul(taxFee).div(10**4);
            totalTaxAmount += _taxfee;// totalTaxAmount.add(_taxfee);
        }
        
        usersStake[msg.sender] -= _amount;// usersStake[msg.sender].sub(_amount);
        
        StakeMap[_stake_id].claimed = true;
        StakeMap[_stake_id].unstakeTime = block.timestamp;
        
        totalStaked -= _amount; //totalStaked.sub(_amount);      

        FONT_ERC20.safeTransfer(msg.sender, (_amount.sub(_taxfee)));

        emit UnStaked(msg.sender, _stake_id, _amount, _taxfee);
    }

    function getStakeByID(uint256 _stake_id) external view returns (stakingInfo memory) {

        return StakeMap[_stake_id];
    }

    function pauseStaking() external {

      require(hasRole(ADMIN_ROLE, msg.sender), "Denied");
      stakingPaused = true;
    }

    function unpauseStaking() external {

      require(hasRole(ADMIN_ROLE, msg.sender), "Denied");
      stakingPaused = false;
    }    


    
    event changedTaxFee(uint256);
    function setTaxFees(uint256 _fees) external {

        require(hasRole(ADMIN_ROLE, msg.sender), "Denied");
        require(_fees > 0, "0");
        taxFee = _fees;
        emit changedTaxFee(_fees);
    }

    event ChangedMinStakeRequired(uint256);
    function setMinStakeRequired(uint256 _amount) external {

        require(hasRole(ADMIN_ROLE, msg.sender), "Denied");
        minStakeAmount = _amount * (10**18);
        emit ChangedMinStakeRequired(_amount);
    }

    event KickedStake(uint256);
    function kickStake(uint256 _stake_id) external {

        require(hasRole(ADMIN_ROLE, msg.sender), "Denied");
        require(!StakeMap[_stake_id].claimed, 'Claimed');
        require(StakeMap[_stake_id].amount > 0, 'No Stake Amount');
        require(totalStaked > 0, 'No FONT Balance');
        
        usersStake[StakeMap[_stake_id].user] -= StakeMap[_stake_id].amount;
        
        StakeMap[_stake_id].claimed = true;
        StakeMap[_stake_id].unstakeTime = block.timestamp;
        
        totalStaked -= StakeMap[_stake_id].amount;// totalStaked.sub(StakeMap[_stake_id].amount);      

        FONT_ERC20.safeTransfer(StakeMap[_stake_id].user, StakeMap[_stake_id].amount);

        emit KickedStake(_stake_id);
    }
    
    event accountExcluded(address);
    function excludeAccount(address _address) external {

        require(hasRole(ADMIN_ROLE, msg.sender), "Denied");
        excludedAccount[_address] = true;
        emit accountExcluded(_address);
    }

    event accountIncluded(address);
    function includeAccount(address _address) external {

        require(hasRole(ADMIN_ROLE, msg.sender), "Denied");
        excludedAccount[_address] = false;
        emit accountIncluded(_address);
    }

    function setFirstUnclaimedStakeId(uint256 _id) external {

        require(hasRole(ADMIN_ROLE, msg.sender), "Denied");
        firstUnclaimedStakeId = _id;
    }

    event EditRewardToken(address _address, uint256 _minBalance);
    function editRewardToken(address _address, uint256 _minBalance) external {

        require(hasRole(ADMIN_ROLE, msg.sender), "Denied");
        rewardTokens[_address] = _minBalance;
        emit EditRewardToken(_address, _minBalance);        
    }        

    event FontBurned(uint256 amount);
    function burnFont() external {

        uint256 _totalTaxAmount = totalTaxAmount;
        totalTaxAmount = 0;
        FONT_ERC20.burn(_totalTaxAmount);
        emit FontBurned(totalTaxAmount);
    }

    function withdrawErc20(address _token, uint256 _amount) public {

        require(msg.sender == ownerAddress, "Denied");
        require(_token != font_token_address, "FONT");
        IERC20(_token).transfer(msg.sender, _amount);
    }    

    function editFontErcAddress(address _address) external {

        require(msg.sender == ownerAddress, "Denied");
        font_token_address = _address;
    }

    event TimingsChanged(uint256, uint256, uint256);
    function setTimings(uint256 _maxSnapshotLifetime, uint256 _minSnapshotInterval, uint256 _minStakeTime) external {

        require(msg.sender == ownerAddress, "Denied");
        maxSnapshotLifetime = _maxSnapshotLifetime; //3 days default
        minSnapshotInterval = _minSnapshotInterval; //90 days defualt 
        minStakeTime = _minStakeTime; //90 days default 
        emit TimingsChanged(_maxSnapshotLifetime, _minSnapshotInterval, _minStakeTime);
    }

    function getStakeByUser(address _address) external view returns (uint256) {

        return usersStake[_address];
    }

    function getStakeidsByUser(address _address) external view returns (uint256[] memory) {

        return userStakeIds[_address];
    }

    function getCurrentRewardShare(address _user) external view returns (uint256) {

        return SnapShot[lastSnapshotTime][_user];
    }

    function getUserRewardBalance(address _token, address _user) external view returns (uint256) {

        return UserRewardBalance[_user][_token];
    }

    function getTaxFee() external view returns (uint256) {

        return taxFee;
    }

    function getTotalEligibleFontsForRewards() external view returns (uint256) {

        return totalEligibleFontsForRewards;
    }

    function getlastSnapshotTime() external view returns (uint256) {

        return lastSnapshotTime;
    }

    function getSnapShotUsers(uint256 _snapshotTime) external view returns (address[] memory) {

        return SnapShotUsers[_snapshotTime];
    }


    function calculateTax(uint256 _amount) internal view returns (uint256) {

        return _amount.mul(taxFee).div(10**4);
    }
    
    receive() external payable {
        weth.deposit{value: msg.value}();
    }
    

    event SnapShoted(uint256, uint256);
    function takeSnapshot() external {

        require(hasRole(ADMIN_ROLE, msg.sender), "Denied");

        uint256 _blockTimestamp = block.timestamp;
        require(lastSnapshotTime < (_blockTimestamp - minSnapshotInterval), "Wait"); //@done
        uint256 _totalEligibleFontsForRewards = 0;
        
        stakingInfo storage _StakeMap;

        for(uint256 i = firstUnclaimedStakeId; i < stakeCounter; i++) {
            _StakeMap = StakeMap[i];
            if(!_StakeMap.claimed && (_StakeMap.lockedTime + _StakeMap.duration < _blockTimestamp)) { //@done date
                _totalEligibleFontsForRewards += _StakeMap.amount;
                if(SnapShot[_blockTimestamp][_StakeMap.user] == 0) {
                    SnapShotUsers[_blockTimestamp].push(_StakeMap.user);
                }
                SnapShot[_blockTimestamp][_StakeMap.user] += _StakeMap.amount;
            }
        }

        lastSnapshotTime = _blockTimestamp;
        totalEligibleFontsForRewards = _totalEligibleFontsForRewards;
        emit SnapShoted(lastSnapshotTime, totalEligibleFontsForRewards);
    }

    event RewardsDistributed(uint256, uint256);
    function DistributeRewards(address[] memory _tokens) external {

        require(hasRole(ADMIN_ROLE, msg.sender), "Denied");

        uint256 _blockTimestamp = block.timestamp;

        require(lastRewardTime < (_blockTimestamp - minSnapshotInterval), 'wait'); //@done        
        require(lastSnapshotTime > (_blockTimestamp - maxSnapshotLifetime), 'SnapShot'); //@done 
        require(totalEligibleFontsForRewards > 0, '0 stake'); //@done
        
        uint256 _token_balance = 0;
        address __address;
        uint256 _totalEligibleFontsForRewards = totalEligibleFontsForRewards;
        uint256 _min_token_balance = 0;
        address[] memory _SnapShotUsers = SnapShotUsers[lastSnapshotTime];

        mapping (address => uint256) storage _SnapShot = SnapShot[lastSnapshotTime];

        for(uint256 i = 0; i < _tokens.length; i++ ) {
            _min_token_balance = rewardTokens[_tokens[i]];
            if(_min_token_balance > 0) {
                _token_balance = IERC20(_tokens[i]).balanceOf(address(this));
                if(_token_balance >= _min_token_balance) { 
                    for(uint256 _user = 0; _user < _SnapShotUsers.length; _user++) { 
                        __address = _SnapShotUsers[_user];
                        UserRewardBalance[__address][_tokens[i]] += (_SnapShot[__address].mul(_token_balance).div(_totalEligibleFontsForRewards));
                    } //take all the users in current snapshop
                }
            } //check if reward token is enabled and its not font token 

        } // Main for loop

        lastRewardTime = _blockTimestamp;

        emit RewardsDistributed(_tokens.length, SnapShotUsers[lastSnapshotTime].length);

    }

    event RewardClaimed(address, uint256);
    function claimRewards(address[] memory _tokens) public {

        uint256 _amount = 0;
        for(uint256 i = 0; i < _tokens.length; i++ ) {
            _amount = UserRewardBalance[msg.sender][_tokens[i]];
            if(_amount > 0) {
                UserRewardBalance[msg.sender][_tokens[i]] = 0;
                IERC20(_tokens[i]).safeTransfer(msg.sender, _amount);
            }
        }
        emit RewardClaimed(msg.sender, block.timestamp);
    }


             
    
}