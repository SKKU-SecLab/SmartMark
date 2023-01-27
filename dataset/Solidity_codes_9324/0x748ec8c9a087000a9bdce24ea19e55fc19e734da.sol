


pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
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
}




pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

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



pragma solidity ^0.8.4;




contract AngryMining is ReentrancyGuard{

    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 reward;
    }
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. ANGRYs to distribute per block.
        uint256 lastRewardBlock; // Last block number that ANGRYs distribution occurs.
        uint256 accAngryPerShare; // Accumulated ANGRYs per share, times 1e12. See below.
        uint256 stakeAmount;
    }
    struct PoolItem {
        uint256 pid;
        uint256 allocPoint;
        address lpToken;
    }
    struct BonusPeriod{
        uint256 beginBlock;
        uint256 endBlock;
    }
    struct LpMiningInfo{
        uint256 pid;
        address lpToken;
        uint256 amount;
        uint256 reward;
    }
    bool public bInited;
    address public owner;
    IERC20 public angryToken;
    uint256 public angryPerBlock;
    uint256 public constant BONUS_MULTIPLIER = 2;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint;
    BonusPeriod[] public bonusPeriods;
    mapping(address => bool) public executorList;
    address[5] public adminList;
    mapping(string => bool) public usedUUIDs;
    
    event ExecutorAdd(address _newAddr);
    event ExecutorDel(address _oldAddr);
    event BonusPeriodAdd(uint256 _beginBlock, uint256 _endBlock);
    event LpDeposit(address indexed user, uint256 indexed pid, uint256 amount);
    event LpWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event PoolAdd(uint256 _allocPoint, address indexed _lpToken, uint256 _pid);
    event PoolChange(uint256 indexed pid, uint256 _allocPoint);
    event LpMiningRewardHarvest(address _user, uint256 _pid, uint256 _amount);
    event AdminChange(address _oldAddr, address _newAddr);
    event RewardsPerBlockChange(uint256 _oldValue, uint256 _newValue);
    
    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }
    
    modifier onlyExecutor {

        require(executorList[msg.sender]);
        _;
    }
    
    modifier validPool(uint256 _pid) {

        require( _pid < poolInfo.length, "pool not exists!" );
        _;
    }
    
    modifier checkSig(string memory _uuid, bytes[] memory _sigs) {

        require( !usedUUIDs[_uuid], "UUID exists!" );
        bool[5] memory flags = [false,false,false,false,false];
        bytes32 hash = keccak256(abi.encodePacked(_uuid));
        for(uint256 i = 0;i < _sigs.length; i++){
            address signer = hash.recover(_sigs[i]);
            if(signer == adminList[0]){
                flags[0] = true;
            }else if(signer == adminList[1]){
                flags[1] = true;
            }else if(signer == adminList[2]){
                flags[2] = true;
            }else if(signer == adminList[3]){
                flags[3] = true;
            }else if(signer == adminList[4]){
                flags[4] = true;
            }
        }
        uint256 cnt = 0; 
        for(uint256 i = 0; i < 5; i++){
          if(flags[i]) cnt += 1;
        }
        usedUUIDs[_uuid] = true;
        require( cnt >= 3, "Not enough sigs!" );
        _;
    }
    
    constructor(address _angryTokenAddr, uint256 _angryPerBlock, address _admin1, address _admin2, address _admin3, address _admin4, address _admin5) {
        initialize(_angryTokenAddr, _angryPerBlock, _admin1, _admin2, _admin3, _admin4, _admin5);
    }
    
    function initialize(address _angryTokenAddr, uint256 _angryPerBlock, address _admin1, address _admin2, address _admin3, address _admin4, address _admin5) public {

        require(!bInited, "already Inited!");
        bInited = true;
        owner = msg.sender;
        executorList[msg.sender] = true;
        angryToken = IERC20(_angryTokenAddr);
        angryPerBlock = _angryPerBlock;
        adminList[0] = _admin1;
        adminList[1] = _admin2;
        adminList[2] = _admin3;
        adminList[3] = _admin4;
        adminList[4] = _admin5;
        emit ExecutorAdd(msg.sender);
    }
    
    function addExecutor(address _newExecutor) onlyOwner public {

        executorList[_newExecutor] = true;
        emit ExecutorAdd(_newExecutor);
    }
    
    function delExecutor(address _oldExecutor) onlyOwner public {

        executorList[_oldExecutor] = false;
        emit ExecutorDel(_oldExecutor);
    }
    
    function checkPoolDuplicate(IERC20 _lpToken) internal view {

        uint256 length = poolInfo.length;
        for(uint256 pid = 0; pid < length; ++pid){
            require( poolInfo[pid].lpToken != _lpToken, "duplicate pool!" );
        }
    }
    
    function addBonusPeriod(uint256 _beginBlock, uint256 _endBlock) public onlyExecutor {

        require( _beginBlock < _endBlock );
        uint256 length = bonusPeriods.length;
        for(uint256 i = 0;i < length; i++){
            require(_endBlock < bonusPeriods[i].beginBlock || _beginBlock > bonusPeriods[i].endBlock, "BO");
        }
        massUpdatePools();
        BonusPeriod memory bp;
        bp.beginBlock = _beginBlock;
        bp.endBlock = _endBlock;
        bonusPeriods.push(bp);
        emit BonusPeriodAdd(_beginBlock, _endBlock);
    }
    
    function addPool(
        uint256 _allocPoint,
        address _lpToken,
        string memory _uuid, 
        bytes[] memory _sigs
    ) public checkSig(_uuid, _sigs) {

        checkPoolDuplicate(IERC20(_lpToken));
        massUpdatePools();
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(
            PoolInfo({
                lpToken: IERC20(_lpToken),
                allocPoint: _allocPoint,
                lastRewardBlock: block.number,
                accAngryPerShare: 0,
                stakeAmount: 0
            })
        );
        emit PoolAdd(_allocPoint,_lpToken, poolInfo.length-1);
    }
    
    function changePool(
        uint256 _pid,
        uint256 _allocPoint,
        string memory _uuid, 
        bytes[] memory _sigs
    ) public validPool(_pid) checkSig(_uuid, _sigs) {

        require( _allocPoint > 0, "invalid allocPoint!" );
        massUpdatePools();
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        emit PoolChange(_pid, _allocPoint);
    }
    
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {

        uint256 bonusBeginBlock = 0;
        uint256 bonusEndBlock = 0;
        uint256 length = bonusPeriods.length;
        uint256 reward = 0;
        uint256 totalBlocks = _to - _from;
        uint256 bonusBlocks = 0;
    
        for(uint256 i = 0;i < length; i++){
            bonusBeginBlock = bonusPeriods[i].beginBlock;
            bonusEndBlock = bonusPeriods[i].endBlock;
            if (_to >= bonusBeginBlock && _from <= bonusEndBlock){
                uint256 a = _from > bonusBeginBlock ? _from : bonusBeginBlock;
                uint256 b = _to > bonusEndBlock ? bonusEndBlock : _to;
                if(b > a){
                    bonusBlocks += (b - a);
                    reward += (b - a) * BONUS_MULTIPLIER;
                }
            }
        }
        if(totalBlocks > bonusBlocks){
            reward += (totalBlocks - bonusBlocks);
        }
        return reward;
    }
    
    function getLpMiningReward(uint256 _pid, address _user)
        public
        validPool(_pid)
        view
        returns (uint256)
    {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accAngryPerShare = pool.accAngryPerShare;
        uint256 lpSupply = pool.stakeAmount;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 angryReward =
                multiplier * angryPerBlock * pool.allocPoint / totalAllocPoint;
            accAngryPerShare = accAngryPerShare + angryReward * (1e12) / lpSupply;
        }
        return user.amount * accAngryPerShare / (1e12) - user.rewardDebt + user.reward;
    }
    
    function getPoolList() public view returns(PoolItem[] memory _pools){

        uint256 length = poolInfo.length;
        _pools = new PoolItem[](length);
        for (uint256 pid = 0; pid < length; ++pid) {
            _pools[pid].pid = pid;
            _pools[pid].lpToken = address(poolInfo[pid].lpToken);
            _pools[pid].allocPoint = poolInfo[pid].allocPoint;
        }
    }
    
    function getPoolListArr() public view returns(uint256[] memory _pids,address[] memory _tokenAddrs, uint256[] memory _allocPoints){

        uint256 length = poolInfo.length;
        _pids = new uint256[](length);
        _tokenAddrs = new address[](length);
        _allocPoints = new uint256[](length);
        for (uint256 pid = 0; pid < length; ++pid) {
            _pids[pid] = pid;
            _tokenAddrs[pid] = address(poolInfo[pid].lpToken);
            _allocPoints[pid] = poolInfo[pid].allocPoint;
        }
    }
    
    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }
    
    function getAccountLpMinings(address _addr) public view returns(LpMiningInfo[] memory _infos){

        uint256 length = poolInfo.length;
        _infos = new LpMiningInfo[](length);
        for (uint256 pid = 0; pid < length; ++pid) {
            UserInfo storage user = userInfo[pid][_addr];
            _infos[pid].pid = pid;
            _infos[pid].lpToken = address(poolInfo[pid].lpToken);
            _infos[pid].amount = user.amount;
            _infos[pid].reward = getLpMiningReward(pid,_addr);
        }
    }
    
    function updatePool(uint256 _pid) public validPool(_pid) {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.stakeAmount;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 angryReward =
            multiplier * angryPerBlock * pool.allocPoint / totalAllocPoint;
        pool.accAngryPerShare = pool.accAngryPerShare + angryReward * (1e12) / lpSupply;
        pool.lastRewardBlock = block.number;
    }
    
    function depositLP(uint256 _pid, uint256 _amount) public nonReentrant validPool(_pid) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending =
                user.amount * pool.accAngryPerShare / (1e12) - user.rewardDebt;
            user.reward += pending;
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        pool.stakeAmount += _amount;
        user.amount = user.amount + _amount;
        user.rewardDebt = user.amount * pool.accAngryPerShare / (1e12);
        emit LpDeposit(msg.sender, _pid, _amount);
    }
    
    function withdrawLP(uint256 _pid, uint256 _amount) public nonReentrant validPool(_pid) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "AE");
        updatePool(_pid);
        uint256 pending =
            user.amount * pool.accAngryPerShare / (1e12) - user.rewardDebt;
        user.reward += pending;
        user.amount = user.amount - _amount;
        user.rewardDebt = user.amount * pool.accAngryPerShare / (1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        pool.stakeAmount -= _amount;
        if(user.amount == 0){
            safeAngryTransfer(msg.sender, user.reward);
            user.reward = 0;
        }
        emit LpWithdraw(msg.sender, _pid, _amount);
    }
    
    function harvestLpMiningReward(uint256 _pid) public nonReentrant validPool(_pid){

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending =
            user.amount * pool.accAngryPerShare / (1e12) - user.rewardDebt;
        user.reward += pending;
        user.rewardDebt = user.amount * pool.accAngryPerShare / (1e12);
        safeAngryTransfer(msg.sender, user.reward);
        emit LpMiningRewardHarvest(msg.sender, _pid, user.reward);
        user.reward = 0;
    }
    
    function safeAngryTransfer(address _to, uint256 _amount) internal {

        angryToken.safeTransfer(_to, _amount);
    }
    
    function getAdminList() public view returns (address[] memory _admins){

        _admins = new address[](adminList.length);
        for(uint256 i = 0; i < adminList.length; i++){
            _admins[i] = adminList[i];
        }
    }
    
    function changeAdmin(uint256 _index, address _newAddress, string memory _uuid, bytes[] memory _sigs) public checkSig(_uuid, _sigs) {

        require(_index < adminList.length, "index out of range!");
        emit AdminChange(adminList[_index], _newAddress);
        adminList[_index] = _newAddress;
    }
    
    function changeRewardsPerBlock(uint256 _angryPerBlock, string memory _uuid, bytes[] memory _sigs) public checkSig(_uuid, _sigs){

        emit RewardsPerBlockChange(angryPerBlock,_angryPerBlock);
        angryPerBlock = _angryPerBlock;
    }
}