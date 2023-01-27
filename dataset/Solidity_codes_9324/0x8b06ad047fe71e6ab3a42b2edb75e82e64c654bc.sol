
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

pragma solidity ^0.8.0;

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity ^0.8.4;


interface IPLBTStaking {


    function getStakedTokens(address _address) external view returns (uint256);


    function setReward(uint256 _amountWETH, uint256 _amountWBTC) external;


    function changeTreasury(address _treasury) external;

}//Unlicense
pragma solidity ^0.8.4;

interface IDAO {

 
    function getLockedTokens(address staker) external view returns(uint256 locked);

    
    function getAvailableTokens(address staker) external view returns(uint256 locked);


}// MIT
pragma solidity ^0.8.4;


contract PLBTStaking is IPLBTStaking, AccessControl, ReentrancyGuard {

    using SafeERC20 for IERC20;

    struct Staker {
        uint256 amount; // amount of tokens currently staked to the contract
        uint256 rewardGained; // increases every time staker unstakes their tokens. used to keep track of how much user earned before unstaking
        uint256 rewardMissed; // increases every time staker stakes more tokens. used to keep track of how much user missed before staking
        uint256 distributed; // total amount of reward tokens earned by the staker
    }
    
    struct StakingInfo {
        uint256 _startTime; // staking start time
        uint256 _distributionTime; // period, over which _rewardTotal should be distributed
        uint256 _rewardTotalWBTC;
        uint256 _rewardTotalWETH;
        uint256 _totalStaked; // total amount of tokens currently staked on the contract
        uint256 _producedWETH; // total amount of produced wETH rewards
        uint256 _producedWBTC; // total amount of produced wBTC rewards
        address _PLBTAddress; // address of staking token
        address _wETHAddress; // address of reward token
        address _wBTCAddress; // address of reward token
    }


    mapping(address => Staker) private stakers;

    bytes32 public TREASURY_ROLE = keccak256("TREASURY_ROLE");

    address treasury;

    IERC20 private PLBT;

    IERC20 private wBTC;
    IERC20 private wETH;

    uint256 public rewardTotal; // total reward over distribution time
    uint256 public allProduced; // variable used to store value of produced rewards before changing rewardTotal
    uint256 public totalStaked; // total amount of currently staked tokens
    uint256 public totalDistributed; // total amount of tokens earned by stakers
    uint256 public totalWBTC; // total rewards in wBTC distributed over distibutionTime
    uint256 public totalWETH; // total rewards in wETH distributed over distributionTime
    uint256 public totalProducedWETH; // total produced rewards in wETH
    uint256 public totalProducedWBTC; // total produced rewards in wBTC

    uint256 private producedTime; // variable used  to store time when rewardTotal is changed
    uint256 private startTime; // staking's start time
    uint256 private immutable distributionTime; // period, over which rewardTotal is distributed
    uint256 private tokensPerStake; // reward token per staked token
    uint256 private rewardProduced; // total amount of produced reward tokens
    bool private initialized; //shows if staking is initialized
    
    IDAO private DAO; // DAO contract

    event Staked(uint256 amount, uint256 time, address indexed sender);

    event Claimed(uint256 amountWETH, uint amountWBTC, uint256 time, address indexed sender);

    event Unstaked(uint256 amount, uint256 time, address indexed sender);

   
    constructor(uint256 _distributionTime  ){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(TREASURY_ROLE, DEFAULT_ADMIN_ROLE);
        distributionTime = _distributionTime;
    }

    function initialize(uint256 _startTime, address _wETH, address _wBTC, address _PLBT, address _addressDAO, address _treasury) external  onlyRole(DEFAULT_ADMIN_ROLE){

        require(
            !initialized,
            "Staking: contract already initialized"
        );
        require(
            _startTime >= block.timestamp, 
            "Staking: current time greater than startTime"
        );
        startTime = _startTime;
        producedTime = _startTime;
        wETH = IERC20(_wETH);
        wBTC = IERC20(_wBTC);
        PLBT = IERC20(_PLBT);
        DAO = IDAO(_addressDAO);
        treasury = _treasury;
        _setupRole(TREASURY_ROLE, treasury);
        _setupRole(DEFAULT_ADMIN_ROLE, _addressDAO);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
        initialized = true;
    }

    function sweep() external onlyRole(TREASURY_ROLE){

        uint256 amountWETH = wETH.balanceOf(address(this));
        uint256 amountWBTC = wBTC.balanceOf(address(this));
        wETH.safeTransfer(treasury, amountWETH);
        wBTC.safeTransfer(treasury, amountWBTC);
    }

    function changeTreasury(address _treasury) external override onlyRole(DEFAULT_ADMIN_ROLE){

        revokeRole(TREASURY_ROLE, treasury);
        treasury = _treasury;
        grantRole(TREASURY_ROLE, treasury);
    }

    function setReward(uint256 _amountWETH, uint256 _amountWBTC) external  override onlyRole(DEFAULT_ADMIN_ROLE) {

        allProduced = produced();
        producedTime = block.timestamp;
        totalWBTC = _amountWBTC;
        totalWETH = _amountWETH;
        rewardTotal = _amountWETH + _amountWBTC;
    }

    function calcReward(address _staker, uint256 _tps) private view returns (uint256 reward)
    {

        Staker storage staker = stakers[_staker];
        reward = staker.amount*_tps/1e20 + staker.rewardGained - staker.distributed - staker.rewardMissed;
        return reward;
    }

    function produced() private view returns (uint256) {

        return allProduced + rewardTotal*(block.timestamp - producedTime)/distributionTime;
    }
    
    function update() private {

        uint256 rewardProducedAtNow = produced();
        if (rewardProducedAtNow > rewardProduced) {
            uint256 producedNew = rewardProducedAtNow - rewardProduced;
            if (totalStaked > 0) {
                tokensPerStake = tokensPerStake+producedNew*1e20/totalStaked;
            }
            rewardProduced += producedNew;
        }
    }

    function stake(uint256 _amount) external {

        require(
            block.timestamp > startTime,
            "Staking: staking time has not come yet"
        );
        require(
            _amount > 0,
            "Staking: stake amount should be greater than 0"
        );
        Staker storage staker = stakers[msg.sender];
        PLBT.safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
        staker.rewardMissed += _amount*tokensPerStake/1e20;
        totalStaked += _amount;
        staker.amount += _amount;
        update();
        emit Staked(_amount, block.timestamp, msg.sender);
    }

    function unstake(uint256 _amount) external  nonReentrant {

        require(
            _amount > 0,
            "Staking: unstake amount should be greater than 0"
        );
        Staker storage staker = stakers[msg.sender];
        uint256 locked = DAO.getLockedTokens(msg.sender);
        uint256 unstakable = staker.amount - locked;
        require(
             _amount <= unstakable, //staker can't unstake tokens used for voting
            "Staking: Not enough tokens to unstake"
        );
        update();

        staker.rewardGained += _amount*tokensPerStake/1e20;
        staker.amount  -= _amount;
        totalStaked -= _amount;

        PLBT.safeTransfer(msg.sender, _amount);

        emit Unstaked(_amount, block.timestamp, msg.sender);
    }

    function claim() external  nonReentrant returns (uint256 wETHReward, uint256 wBTCReward) {

        if (totalStaked > 0) {
            update();
        }
        uint256 reward = calcReward(msg.sender, tokensPerStake);
        require(reward > 0, "Staking: Nothing to claim");
        
        Staker storage staker = stakers[msg.sender];
        staker.distributed += reward;
        totalDistributed += reward;

        wETHReward  = (reward*totalWETH)/(rewardTotal);
        wBTCReward = (reward*totalWBTC)/(rewardTotal);
        wETH.safeTransfer(msg.sender, wETHReward);
        wBTC.safeTransfer(msg.sender, wBTCReward);
        emit Claimed(wETHReward, wBTCReward, block.timestamp, msg.sender);
        return  (wETHReward, wBTCReward);
    }

    function getStakingInfo() external view returns (StakingInfo memory info_) {

        uint256 producedAtNow = produced();
        uint256 producedWETH = (producedAtNow*totalWETH)/rewardTotal;
        uint256 producedWBTC = (producedAtNow*totalWBTC)/rewardTotal;
        info_ = StakingInfo({
            _startTime: startTime,
            _distributionTime: distributionTime,
            _rewardTotalWBTC: totalWBTC,
            _rewardTotalWETH: totalWETH,
            _totalStaked: totalStaked,
            _producedWETH: producedWETH,
            _producedWBTC: producedWBTC,
            _PLBTAddress: address(PLBT),
            _wETHAddress: address(wETH),
            _wBTCAddress: address(wBTC)
        });
        return info_;
    }

    function getInfoByAddress(address _address) external view returns (
        uint256 staked_,
        uint256 claimWETH_,
        uint256 claimWBTC_
    ){

        Staker storage staker = stakers[_address];
        staked_ = staker.amount;
        uint256 _tps = tokensPerStake;
        if (totalStaked > 0) {
            uint256 rewardProducedAtNow = produced();
            if (rewardProducedAtNow > rewardProduced) {
                uint256 producedNew = rewardProducedAtNow - rewardProduced;
                _tps = _tps + producedNew*1e20/totalStaked;
            }
        }
        uint256 reward = calcReward(_address, _tps);
        claimWETH_  = (reward*totalWETH)/rewardTotal;
        claimWBTC_ = (reward*totalWBTC)/rewardTotal;
        return (staked_, claimWETH_, claimWBTC_);
    }

    function getStakedTokens(address _address) external view override returns (uint256){

        return stakers[_address].amount;
    }
}