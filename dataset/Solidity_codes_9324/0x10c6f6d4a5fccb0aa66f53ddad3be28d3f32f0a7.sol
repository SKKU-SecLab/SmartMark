

pragma solidity ^0.6.0;

interface IBEP20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function symbol() external view returns (string memory);


    function name() external view returns (string memory);


    function getOwner() external view returns (address);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address _owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.6.0;
interface IBEP20Mintable is IBEP20 {

    function mint(address to, uint256 amount) external;

    function transferOwnership(address newOwner) external;

}





pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}





pragma solidity >=0.6.2 <0.8.0;

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





pragma solidity ^0.6.0;
library SafeBEP20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeBEP20: decreased allowance below zero"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}





pragma solidity ^0.6.0;

interface IReferral {

    function recordReferral(address user, address referrer) external;


    function recordReferralCommission(address referrer, uint256 commission) external;


    function getReferrer(address user) external view returns (address);

}





pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}





pragma solidity ^0.6.0;
contract Referral is IReferral, Ownable {

    using SafeBEP20 for IBEP20;

    mapping(address => bool) public operators;
    mapping(address => address) public referrers; // user address => referrer address
    mapping(address => uint256) public referralsCount; // referrer address => referrals count
    mapping(address => uint256) public totalReferralCommissions; // referrer address => total referral commissions

    event ReferralRecorded(address indexed user, address indexed referrer);
    event ReferralCommissionRecorded(address indexed referrer, uint256 commission);
    event OperatorUpdated(address indexed operator, bool indexed status);

    modifier onlyOperator {

        require(operators[msg.sender], "Operator: caller is not the operator");
        _;
    }

    function recordReferral(address _user, address _referrer) public override onlyOperator {

        if (_user != address(0)
            && _referrer != address(0)
            && _user != _referrer
            && referrers[_user] == address(0)
        ) {
            referrers[_user] = _referrer;
            referralsCount[_referrer] += 1;
            emit ReferralRecorded(_user, _referrer);
        }
    }

    function recordReferralCommission(address _referrer, uint256 _commission) public override onlyOperator {

        if (_referrer != address(0) && _commission > 0) {
            totalReferralCommissions[_referrer] += _commission;
            emit ReferralCommissionRecorded(_referrer, _commission);
        }
    }

    function getReferrer(address _user) public override view returns (address) {

        return referrers[_user];
    }

    function updateOperator(address _operator, bool _status) external onlyOwner {

        operators[_operator] = _status;
        emit OperatorUpdated(_operator, _status);
    }

    function drainBEP20Token(IBEP20 _token, uint256 _amount, address _to) external onlyOwner {

        _token.safeTransfer(_to, _amount);
    }
}





pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}





pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





pragma solidity >=0.6.2 <0.8.0;

interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}





pragma solidity >=0.6.0 <0.8.0;

interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}





pragma solidity >=0.6.0 <0.8.0;

abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}





pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}





pragma solidity >=0.6.0 <0.8.0;

contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}





pragma solidity ^0.6.0;
contract Reserve is Ownable {

    function safeTransfer(IBEP20 rewardToken, address _to, uint256 _amount) external onlyOwner {

        uint256 tokenBal = rewardToken.balanceOf(address(this));
        if (_amount > tokenBal) {
            rewardToken.transfer(_to, tokenBal);
        } else {
            rewardToken.transfer(_to, _amount);
        }
    }
}

contract IslandInuStaking is Ownable, ERC1155Holder {

    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 rewardLockedUp;  // Reward locked up.
        uint256 nextHarvestUntil; // When can the user harvest again.
    }

    struct PoolInfo {
        IBEP20 stakedToken;
        IBEP20 rewardToken;
        uint256 stakedAmount;
        uint256 rewardSupply;
        uint256 tokenPerBlock;
        uint256 lastRewardBlock;
        uint256 accTokenPerShare;
        uint16 depositFeeBP;
        uint256 minDeposit;
        uint256 harvestInterval;  // Harvest interval in seconds
        uint256 nftId;
        uint256 minNft;
        bool lockDeposit;
    }

    IERC1155 public nft;
    Reserve public rewardReserve;
    address public devaddr;
    uint256 public devReward;
    uint256 public constant BONUS_MULTIPLIER = 1;
    uint256 public constant MAXIMUM_HARVEST_INTERVAL = 14 days;
    address public feeAddress;
    
    mapping(address => mapping(address => bool)) poolExists;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    address public setup;
    uint256 public startBlock;
    bool public paused = true;
    bool public initialized = false;

    modifier onlyOwnerAndSetup() {

        require(owner() == _msgSender() || setup == _msgSender(), "IslandInuStaking: caller is not the owner or setup");
        _;
    }
    
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardLockedUp(address indexed user, uint256 indexed pid, uint256 amountLockedUp);
    event ReferralCommissionPaid(address indexed user, address indexed referrer, uint256 commissionAmount);

    constructor() public {
        setup = msg.sender;
        devaddr = msg.sender;
        feeAddress = msg.sender;
        devReward = 0;
        startBlock = 0;
        rewardReserve = new Reserve();

        add(
            10000e9,
            IBEP20(0xe9fba30fF18D305feA49836939eACA55f26C019c),
            IBEP20(0xe9fba30fF18D305feA49836939eACA55f26C019c),
            0,
            0,
            0,
            0,
            0
        );
    }
    
    function initialize() public onlyOwner {

        require(!initialized,"IslandInuStaking: Farming already started!");
        initialized = true;
        paused = false;
        startBlock = block.number;
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            poolInfo[pid].lastRewardBlock = startBlock;
        }
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function depositRewardToken(uint256 poolId, uint256 amount) external {

        PoolInfo storage pool = poolInfo[poolId];

        uint256 initialBalance = pool.rewardToken.balanceOf(address(rewardReserve));
        pool.rewardToken.transferFrom(msg.sender, address(rewardReserve), amount);
        uint256 finalBalance = pool.rewardToken.balanceOf(address(rewardReserve));
        pool.rewardSupply = pool.rewardSupply.add(finalBalance.sub(initialBalance));
    }

    function add(uint256 _tokenPerBlock, IBEP20 _stakedToken, IBEP20 _rewardToken, uint16 _depositFeeBP, uint256 _minDeposit, uint256 _harvestInterval, uint256 _nftId, uint256 _minNft) public onlyOwnerAndSetup {

        require(poolInfo.length <= 1000, "IslandInuStaking: Pool Length Full!");
        require(!poolExists[address(_stakedToken)][address(_rewardToken)], "IslandInuStaking: Pool Already Exists!");
        require(_depositFeeBP <= 10000, "IslandInuStaking: invalid deposit fee basis points");
        require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "IslandInuStaking: invalid harvest interval");
        
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        poolInfo.push(PoolInfo({
            stakedToken: _stakedToken,
            rewardToken: _rewardToken,
            stakedAmount: 0,
            rewardSupply: 0,
            tokenPerBlock: _tokenPerBlock,
            lastRewardBlock: lastRewardBlock,
            accTokenPerShare: 0,
            depositFeeBP: _depositFeeBP,
            minDeposit: _minDeposit,
            harvestInterval: _harvestInterval,
            nftId: _nftId,
            minNft: _minNft,
            lockDeposit: false
        }));
        poolExists[address(_stakedToken)][address(_rewardToken)] = true;
    }

    function set(uint256 _pid, uint256 _tokenPerBlock, uint16 _depositFeeBP, uint256 _minDeposit, uint256 _harvestInterval) public onlyOwnerAndSetup {

        require(_depositFeeBP <= 10000, "IslandInuStaking: invalid deposit fee basis points");
        require(_harvestInterval <= MAXIMUM_HARVEST_INTERVAL, "IslandInuStaking: invalid harvest interval");
        
        poolInfo[_pid].tokenPerBlock = _tokenPerBlock;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
        poolInfo[_pid].minDeposit = _minDeposit;
        poolInfo[_pid].harvestInterval = _harvestInterval;
    }

    function getMultiplier(uint256 _from, uint256 _to) public pure returns (uint256) {

        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    function pendingToken(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accTokenPerShare;
        if (block.number > pool.lastRewardBlock && pool.stakedAmount != 0 && pool.rewardSupply > 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 tokenReward = multiplier.mul(pool.tokenPerBlock);
            accTokenPerShare = accTokenPerShare.add(tokenReward.mul(1e12).div(pool.stakedAmount));
        }
        return user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt);
    }

    function canHarvest(uint256 _pid, address _user) public view returns (bool) {

        UserInfo storage user = userInfo[_pid][_user];
        return block.timestamp >= user.nextHarvestUntil;
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 tokenBalance = pool.stakedAmount; 
        if (tokenBalance == 0 || pool.tokenPerBlock == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 tokenReward = multiplier.mul(pool.tokenPerBlock);
        uint256 _devReward = tokenReward.mul(devReward).div(10000);
        uint256 rewardTokenSupply = pool.rewardSupply;
        if(rewardTokenSupply >= tokenReward.add(_devReward) && _devReward > 0) {
            rewardReserve.safeTransfer(pool.rewardToken, devaddr, _devReward);
            pool.accTokenPerShare = pool.accTokenPerShare.add(tokenReward.mul(1e12).div(tokenBalance));
            pool.rewardSupply = pool.rewardSupply.sub(tokenReward.add(_devReward));
        } else if(rewardTokenSupply > 0){
            pool.accTokenPerShare = pool.accTokenPerShare.add(rewardTokenSupply.mul(1e12).div(tokenBalance));
            pool.rewardSupply = 0;
        }
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {

        require(paused == false, "IslandInuStaking: Paused!");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        if(user.amount == 0 && address(nft) != address(0) && pool.minNft > 0) {
            nft.safeTransferFrom(msg.sender, address(this), pool.nftId, pool.minNft, "");
        }
        require(!pool.lockDeposit, "IslandInuStaking: Deposit Locked!");
        updatePool(_pid);
        payOrLockupPendingToken(_pid);
        if(_amount > 0) {
            uint256 initialBalance = pool.stakedToken.balanceOf(address(this));
            pool.stakedToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint256 finalBalance = pool.stakedToken.balanceOf(address(this));
            uint256 delta = finalBalance.sub(initialBalance);
            require(pool.stakedToken.balanceOf(msg.sender) >= poolInfo[_pid].minDeposit,"IslandInuStaking: Not Enough Required Staking Tokens!");
            if(pool.depositFeeBP > 0){
                uint256 depositFee = _amount.mul(pool.depositFeeBP).div(10000);
                pool.stakedToken.safeTransfer(feeAddress, depositFee);
                user.amount = user.amount.add(delta).sub(depositFee);
                pool.stakedAmount = pool.stakedAmount.add(delta).sub(depositFee);
            } else {
                user.amount = user.amount.add(delta);
                pool.stakedAmount = pool.stakedAmount.add(delta);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "IslandInuStaking: withdraw not good");
        updatePool(_pid);
        payOrLockupPendingToken(_pid);
        if(address(nft) != address(0) && pool.minNft > 0) {
            nft.safeTransferFrom(address(this), msg.sender, pool.nftId, pool.minNft, "");
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.stakedAmount = pool.stakedAmount.sub(_amount);
            pool.stakedToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function payOrLockupPendingToken(uint256 _pid) internal {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        if (user.nextHarvestUntil == 0) {
            user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);
        }

        uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(user.rewardDebt);
        if (canHarvest(_pid, msg.sender)) {
            if (pending > 0 || user.rewardLockedUp > 0) {
                uint256 totalRewards = pending.add(user.rewardLockedUp);

                user.rewardLockedUp = 0;
                user.nextHarvestUntil = block.timestamp.add(pool.harvestInterval);

                rewardReserve.safeTransfer(pool.rewardToken, msg.sender, totalRewards);
            }
        } else if (pending > 0) {
            user.rewardLockedUp = user.rewardLockedUp.add(pending);
            emit RewardLockedUp(msg.sender, _pid, pending);
        }
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        user.rewardLockedUp = 0;
        user.nextHarvestUntil = 0;
        pool.stakedToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    function emergencyAdminWithdraw(uint256 _pid) public onlyOwner {

        PoolInfo storage pool = poolInfo[_pid];
        pool.rewardToken.transfer(owner(), pool.rewardToken.balanceOf(address(this)));
        rewardReserve.safeTransfer(pool.rewardToken, owner(), pool.rewardToken.balanceOf(address(rewardReserve)));
        pool.accTokenPerShare = 0;
        pool.tokenPerBlock = 0;
        pool.lastRewardBlock = block.number;
    }

    function setNFT(IERC1155 _nft) external onlyOwnerAndSetup {

        nft = _nft;
    }

    function updateDevReward(uint _devReward) public onlyOwner {

        devReward = _devReward;
    }

    function dev(address _devaddr) public {

        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    function setFeeAddress(address _feeAddress) public {

        require(msg.sender == feeAddress, "IslandInuStaking: FORBIDDEN");
        feeAddress = _feeAddress;
    }

    function updateSetup(address _setup) public onlyOwnerAndSetup {

        setup = _setup;
    }

    function updatePaused(bool _value) public onlyOwner {

        paused = _value;
    }

    function setLockDeposit(uint pid, bool locked) public onlyOwnerAndSetup {

        poolInfo[pid].lockDeposit = locked;
    }
}