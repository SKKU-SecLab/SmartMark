
pragma solidity 0.8.0;




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




library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
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




abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}






abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}



interface ISwapContractMin {

    function getCurrentPriceLP() external view returns (uint256);


    function getDepositFeeRate(address _token, uint256 _amountOfFloat)
        external
        view
        returns (uint256);


    function getFloatReserve(address _tokenA, address _tokenB)
        external
        view
        returns (uint256 reserveA, uint256 reserveB);

}











contract ChefLinkMaki is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    ISwapContractMin public immutable swapContract;
    IERC20 public immutable rewardToken;
    IERC20 public immutable stakedToken;
    address public immutable BTCT_ADDR;
    uint256 public accTokenPerShare;
    uint256 public bonusEndBlock;
    uint256 public startBlock;
    uint256 public lastRewardBlock;
    uint256 public rewardPerBlock;
    uint256 public defaultRewardPerBlock;
    uint256 public maxRewardPerBlock;
    bool public isDynamic = true;
    bool public isDynamicBTC;
    bool public isDynamicBTCT;
    uint256 public latestTilt;
    uint256 public totalStaked;
    mapping(address => UserInfo) public userInfo;

    struct UserInfo {
        uint256 amount; // How many staked tokens the user has provided
        uint256 rewardDebt; // Reward debt
    }

    event AdminTokenRecovery(address tokenRecovered, uint256 amount);
    event Deposit(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event EmergencyRewardWithdraw(uint256 amount);
    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
    event NewRewardPerBlock(uint256 rewardPerBlock);
    event NewPoolLimit(uint256 poolLimitPerUser);
    event RewardsStop(uint256 blockNumber);
    event Withdraw(address indexed user, uint256 amount);

    constructor(
        IERC20 _stakedToken,
        IERC20 _rewardToken,
        ISwapContractMin _swapContract,
        address _btct,
        uint256 _rewardPerBlock,
        uint256 _maxRewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) public {
        stakedToken = _stakedToken;
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        defaultRewardPerBlock = rewardPerBlock;
        require(_maxRewardPerBlock >= _rewardPerBlock);
        maxRewardPerBlock = _maxRewardPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;
        lastRewardBlock = startBlock;
        swapContract = _swapContract;
        BTCT_ADDR = _btct;
    }

    function deposit(uint256 _amount) external nonReentrant {

        UserInfo storage user = userInfo[msg.sender];
        _updatePool();

        if (user.amount != 0) {
            uint256 pending = user.amount.mul(accTokenPerShare).div(1e12).sub(
                user.rewardDebt
            );
            if (pending > 0) {
                rewardToken.safeTransfer(address(msg.sender), pending);
            }
        }

        if (_amount != 0) {
            user.amount = user.amount.add(_amount);
            stakedToken.safeTransferFrom(
                address(msg.sender),
                address(this),
                _amount
            );
        }

        user.rewardDebt = user.amount.mul(accTokenPerShare).div(1e12);
        totalStaked = totalStaked.add(_amount);
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external nonReentrant {

        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Amount to withdraw too high");

        _updatePool();

        uint256 pending = user.amount.mul(accTokenPerShare).div(1e12).sub(
            user.rewardDebt
        );

        if (_amount != 0) {
            user.amount = user.amount.sub(_amount);
            stakedToken.safeTransfer(address(msg.sender), _amount);
        }

        if (pending != 0) {
            rewardToken.safeTransfer(address(msg.sender), pending);
        }

        user.rewardDebt = user.amount.mul(accTokenPerShare).div(1e12);
        totalStaked = totalStaked.sub(_amount);
        emit Withdraw(msg.sender, _amount);
    }

    function emergencyWithdraw() external nonReentrant {

        UserInfo storage user = userInfo[msg.sender];
        uint256 amountToTransfer = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;

        if (amountToTransfer != 0) {
            stakedToken.safeTransfer(address(msg.sender), amountToTransfer);
        }
        totalStaked = totalStaked.sub(amountToTransfer);

        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {

        rewardToken.safeTransfer(address(msg.sender), _amount);
        emit EmergencyRewardWithdraw(_amount);
    }

    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyOwner
    {

        require(
            _tokenAddress != address(stakedToken),
            "Cannot be staked token"
        );
        require(
            _tokenAddress != address(rewardToken),
            "Cannot be reward token"
        );

        IERC20(_tokenAddress).safeTransfer(address(msg.sender), _tokenAmount);

        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);
    }

    function stopReward() external onlyOwner {

        bonusEndBlock = block.number;
    }

    function updateRewardPerBlock(
        uint256 _rewardPerBlock,
        uint256 _maxRewardPerBlock,
        bool _isDynamic
    ) external onlyOwner {

        require(_rewardPerBlock >= 1e17);
        require(_rewardPerBlock <= 3e18);
        require(_maxRewardPerBlock >= _rewardPerBlock);
        _updatePool();
        rewardPerBlock = _rewardPerBlock;
        defaultRewardPerBlock = rewardPerBlock;
        maxRewardPerBlock = _maxRewardPerBlock;
        isDynamic = _isDynamic;
        if (!_isDynamic) {
            isDynamicBTC = false;
            isDynamicBTCT = false;
        }
        emit NewRewardPerBlock(_rewardPerBlock);
    }

    function updateStartAndEndBlocks(
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) external onlyOwner {

        require(block.number < startBlock, "Pool has started");
        require(
            _startBlock < _bonusEndBlock,
            "New startBlock must be lower than new endBlock"
        );
        require(
            block.number < _startBlock,
            "New startBlock must be higher than current block"
        );

        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;

        lastRewardBlock = startBlock;

        emit NewStartAndEndBlocks(_startBlock, _bonusEndBlock);
    }


    function updateEndBlocks(uint256 _bonusEndBlock) external onlyOwner {

        require(
            block.number < _bonusEndBlock,
            "New bonusEndBlock must be higher than current height"
        );
        bonusEndBlock = _bonusEndBlock;
    }

    function pendingReward(address _user) external view returns (uint256) {

        UserInfo storage user = userInfo[_user];
        uint256 stakedTokenSupply = totalStaked;
        if (block.number > lastRewardBlock && stakedTokenSupply != 0) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
            uint256 tokenReward = multiplier.mul(rewardPerBlock);
            uint256 adjustedTokenPerShare = accTokenPerShare.add(
                tokenReward.mul(1e12).div(stakedTokenSupply)
            );
            return
                user.amount.mul(adjustedTokenPerShare).div(1e12).sub(
                    user.rewardDebt
                );
        } else {
            return
                user.amount.mul(accTokenPerShare).div(1e12).sub(
                    user.rewardDebt
                );
        }
    }

    function _updatePool() internal {

        if (block.number <= lastRewardBlock) {
            return;
        }
        uint256 stakedTokenSupply = stakedToken.balanceOf(address(this));

        if (stakedTokenSupply == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
        uint256 tokenReward = multiplier.mul(rewardPerBlock);
        accTokenPerShare = accTokenPerShare.add(
            tokenReward.mul(1e12).div(stakedTokenSupply)
        );
        if (isDynamic) _updateRewardPerBlock();
        lastRewardBlock = block.number;
    }


    function getExpectedRewardPerBlock(address _token, uint256 _amountOfFloat)
        public
        view
        returns (
            uint256 updatedRewards,
            uint256 reserveBTC,
            uint256 reserveBTCT,
            uint256 tilt
        )
    {

        uint256 blocks = block.number - lastRewardBlock != 0
            ? block.number.sub(lastRewardBlock)
            : 1;

        if (blocks > 50) blocks = 50;

        updatedRewards = rewardPerBlock;
        (reserveBTC, reserveBTCT) = swapContract.getFloatReserve(
            address(0),
            BTCT_ADDR
        );

        require(_token == address(0x0) || _token == BTCT_ADDR);

        if (_token == address(0x0)) reserveBTC = reserveBTC.add(_amountOfFloat);
        else reserveBTCT = reserveBTCT.add(_amountOfFloat);

        tilt = (reserveBTC >= reserveBTCT)
            ? reserveBTC.sub(reserveBTCT)
            : reserveBTCT.sub(reserveBTC);

        if ((isDynamicBTC || isDynamicBTCT) && isDynamic)
            if (latestTilt > tilt) {
                updatedRewards = rewardPerBlock.add(
                    latestTilt.sub(tilt).mul(1e10).div(blocks)
                ); // moved == decimals 8
            } else {
                if (tilt.sub(latestTilt).mul(1e10) <= rewardPerBlock)
                    updatedRewards = rewardPerBlock.sub(
                        tilt.sub(latestTilt).mul(1e10).div(blocks)
                    ); // moved == decimals 8
                else updatedRewards = defaultRewardPerBlock;
            }

        if (updatedRewards >= maxRewardPerBlock) {
            updatedRewards = maxRewardPerBlock;
        }
        if (updatedRewards <= defaultRewardPerBlock) {
            updatedRewards = defaultRewardPerBlock;
        }
        return (updatedRewards, reserveBTC, reserveBTCT, tilt);
    }

    function _updateRewardPerBlock() internal {

        (
            uint256 updatedRewards,
            uint256 reserveBTC,
            uint256 reserveBTCT,
            uint256 tilt
        ) = getExpectedRewardPerBlock(address(0x0), 0); // check the current numbers.

        rewardPerBlock = updatedRewards;

        if (reserveBTC >= reserveBTCT && isDynamicBTC) {
            isDynamicBTC = false;
            rewardPerBlock = defaultRewardPerBlock;
        }

        if (reserveBTCT >= reserveBTC && isDynamicBTCT) {
            isDynamicBTCT = false;
            rewardPerBlock = defaultRewardPerBlock;
        }

        uint256 feesForDepositBTC = swapContract.getDepositFeeRate(
            address(0x0),
            0
        );
        uint256 feesForDepositBTCT = swapContract.getDepositFeeRate(
            BTCT_ADDR,
            0
        );

        if (feesForDepositBTC != 0) {
            isDynamicBTCT = true;
        }
        if (feesForDepositBTCT != 0) {
            isDynamicBTC = true;
        }
        latestTilt = tilt;
    }

    function _getMultiplier(uint256 _from, uint256 _to)
        internal
        view
        returns (uint256)
    {

        if (_to <= bonusEndBlock) {
            return _to.sub(_from);
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock.sub(_from);
        }
    }
}