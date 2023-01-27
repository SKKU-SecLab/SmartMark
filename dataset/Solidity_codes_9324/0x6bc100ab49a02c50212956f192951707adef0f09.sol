

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;


contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "unauthorized");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

        require(b != 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        return divCeil(a, b, "SafeMath: division by zero");
    }

    function divCeil(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);

        if (a == 0) {
            return 0;
        }
        uint256 c = ((a - 1) / b) + 1;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }

    function min256(uint256 _a, uint256 _b) internal pure returns (uint256) {

        return _a < _b ? _a : _b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract IERC20 {

    string public name;
    uint8 public decimals;
    string public symbol;
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function approve(address _spender, uint256 _value) public returns (bool);

    function transfer(address _to, uint256 _value) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library EnumerableBytes32Set {


    struct Bytes32Set {
        mapping (bytes32 => uint256) index;
        bytes32[] values;
    }

    function addAddress(Bytes32Set storage set, address addrvalue)
        internal
        returns (bool)
    {

        bytes32 value;
        assembly {
            value := addrvalue
        }
        return addBytes32(set, value);
    }

    function addBytes32(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        if (!contains(set, value)){
            set.index[value] = set.values.push(value);
            return true;
        } else {
            return false;
        }
    }

    function removeAddress(Bytes32Set storage set, address addrvalue)
        internal
        returns (bool)
    {

        bytes32 value;
        assembly {
            value := addrvalue
        }
        return removeBytes32(set, value);
    }

    function removeBytes32(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        if (contains(set, value)){
            uint256 toDeleteIndex = set.index[value] - 1;
            uint256 lastIndex = set.values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set.values[lastIndex];

                set.values[toDeleteIndex] = lastValue;
                set.index[lastValue] = toDeleteIndex + 1; // All indexes are 1-based
            }

            delete set.index[value];

            set.values.pop();

            return true;
        } else {
            return false;
        }
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {

        return set.index[value] != 0;
    }

    function containsAddress(Bytes32Set storage set, address addrvalue)
        internal
        view
        returns (bool)
    {

        bytes32 value;
        assembly {
            value := addrvalue
        }
        return set.index[value] != 0;
    }

    function enumerate(Bytes32Set storage set, uint256 start, uint256 count)
        internal
        view
        returns (bytes32[] memory output)
    {

        uint256 end = start + count;
        require(end >= start, "addition overflow");
        end = set.values.length < end ? set.values.length : end;
        if (end == 0 || start >= end) {
            return output;
        }

        output = new bytes32[](end-start);
        for (uint256 i = start; i < end; i++) {
            output[i-start] = set.values[i];
        }
        return output;
    }

    function length(Bytes32Set storage set)
        internal
        view
        returns (uint256)
    {

        return set.values.length;
    }

    function get(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {

        return set.values[index];
    }

    function getAddress(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (address)
    {

        bytes32 value = set.values[index];
        address addrvalue;
        assembly {
            addrvalue := value
        }
        return addrvalue;
    }
}

contract StakingState is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableBytes32Set for EnumerableBytes32Set.Bytes32Set;

    uint256 public constant initialCirculatingSupply = 1030000000e18 - 889389933e18;
    address internal constant ZERO_ADDRESS = address(0);

    address public BZRX;
    address public vBZRX;
    address public LPToken;

    address public implementation;

    bool public isInit;
    bool public isActive;

    mapping(address => uint256) internal _totalSupplyPerToken;                      // token => value
    mapping(address => mapping(address => uint256)) internal _balancesPerToken;     // token => account => value
    mapping(address => mapping(address => uint256)) internal _checkpointPerToken;   // token => account => value

    mapping(address => address) public delegate;                                    // user => delegate
    mapping(address => mapping(address => uint256)) public repStakedPerToken;       // token => user => value
    mapping(address => bool) public reps;                                           // user => isActive

    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;                      // user => value
    mapping(address => uint256) public rewards;                                     // user => value

    EnumerableBytes32Set.Bytes32Set internal repStakedSet;

    uint256 public lastUpdateTime;
    uint256 public periodFinish;
    uint256 public rewardRate;
}

interface ILoanPool {

    function tokenPrice()
        external
        view
        returns (uint256 price);


    function borrowInterestRate()
        external
        view
        returns (uint256);


    function totalAssetSupply()
        external
        view
        returns (uint256);


    function assetBalanceOf(
        address _owner)
        external
        view
        returns (uint256);

}

contract StakingInterim is StakingState {


    ILoanPool public constant iBZRX = ILoanPool(0x18240BD9C07fA6156Ce3F3f61921cC82b2619157);

    struct RepStakedTokens {
        address wallet;
        bool isActive;
        uint256 BZRX;
        uint256 vBZRX;
        uint256 LPToken;
    }

    event Staked(
        address indexed user,
        address indexed token,
        address indexed delegate,
        uint256 amount
    );

    event DelegateChanged(
        address indexed user,
        address indexed oldDelegate,
        address indexed newDelegate
    );

    event RewardAdded(
        uint256 indexed reward,
        uint256 duration
    );

    modifier checkActive() {

        require(isActive, "not active");
        _;
    }
 
    function init(
        address _BZRX,
        address _vBZRX,
        address _LPToken,
        bool _isActive)
        external
        onlyOwner
    {

        require(!isInit, "already init");
        
        BZRX = _BZRX;
        vBZRX = _vBZRX;
        LPToken = _LPToken;

        isActive = _isActive;

        isInit = true;
    }

    function setActive(
        bool _isActive)
        public
        onlyOwner
    {

        require(isInit, "not init");
        isActive = _isActive;
    }

    function rescueToken(
        IERC20 token,
        address receiver,
        uint256 amount)
        external
        onlyOwner
        returns (uint256 withdrawAmount)
    {

        withdrawAmount = token.balanceOf(address(this));
        if (withdrawAmount > amount) {
            withdrawAmount = amount;
        }
        if (withdrawAmount != 0) {
            token.safeTransfer(
                receiver,
                withdrawAmount
            );
        }
    }

    function stake(
        address[] memory tokens,
        uint256[] memory values)
        public
    {

        stakeWithDelegate(
            tokens,
            values,
            ZERO_ADDRESS
        );
    }

    function stakeWithDelegate(
        address[] memory tokens,
        uint256[] memory values,
        address delegateToSet)
        public
        checkActive
        updateReward(msg.sender)
    {

        require(tokens.length == values.length, "count mismatch");

        address currentDelegate = _setDelegate(delegateToSet);

        address token;
        uint256 stakeAmount;
        uint256 stakeable;
        for (uint256 i = 0; i < tokens.length; i++) {
            token = tokens[i];
            require(token == BZRX || token == vBZRX || token == LPToken, "invalid token");

            stakeAmount = values[i];
            stakeable = stakeableByAsset(token, msg.sender);

            if (stakeAmount == 0 || stakeable == 0) {
                continue;
            }
            if (stakeAmount > stakeable) {
                stakeAmount = stakeable;
            }

            _balancesPerToken[token][msg.sender] = _balancesPerToken[token][msg.sender].add(stakeAmount);
            _totalSupplyPerToken[token] = _totalSupplyPerToken[token].add(stakeAmount);

            emit Staked(
                msg.sender,
                token,
                currentDelegate,
                stakeAmount
            );

            repStakedPerToken[currentDelegate][token] = repStakedPerToken[currentDelegate][token]
                .add(stakeAmount);
        }
    }

    function setRepActive(
        bool _isActive)
        public
    {

        reps[msg.sender] = _isActive;
        if (_isActive) {
            repStakedSet.addAddress(msg.sender);
        }
    }

    function getRepVotes(
        uint256 start,
        uint256 count)
        external
        view
        returns (RepStakedTokens[] memory repStakedArr)
    {

        uint256 end = start.add(count).min256(repStakedSet.length());
        if (start >= end) {
            return repStakedArr;
        }
        count = end-start;

        uint256 idx = count;
        address wallet;
        repStakedArr = new RepStakedTokens[](idx);
        for (uint256 i = --end; i >= start; i--) {
            wallet = repStakedSet.getAddress(i);
            repStakedArr[count-(idx--)] = RepStakedTokens({
                wallet: wallet,
                isActive: reps[wallet],
                BZRX: repStakedPerToken[wallet][BZRX],
                vBZRX: repStakedPerToken[wallet][vBZRX],
                LPToken: repStakedPerToken[wallet][LPToken]
            });

            if (i == 0) {
                break;
            }
        }

        if (idx != 0) {
            count -= idx;
            assembly {
                mstore(repStakedArr, count)
            }
        }
    }

    function lastTimeRewardApplicable()
        public
        view
        returns (uint256)
    {

        return periodFinish
            .min256(_getTimestamp());
    }

    modifier updateReward(address account) {

        uint256 _rewardsPerToken = rewardsPerToken();
        rewardPerTokenStored = _rewardsPerToken;

        lastUpdateTime = lastTimeRewardApplicable();

        if (account != address(0)) {
            rewards[account] = _earned(account, _rewardsPerToken);
            userRewardPerTokenPaid[account] = _rewardsPerToken;
        }

        _;
    }

    function rewardsPerToken()
        public
        view
        returns (uint256)
    {

        uint256 totalSupplyBZRX = totalSupplyByAssetNormed(BZRX);
        uint256 totalSupplyVBZRX = totalSupplyByAssetNormed(vBZRX);
        uint256 totalSupplyLPToken = totalSupplyByAssetNormed(LPToken);

        uint256 totalTokens = totalSupplyBZRX
            .add(totalSupplyVBZRX)
            .add(totalSupplyLPToken);

        if (totalTokens == 0) {
            return rewardPerTokenStored;
        }

        return rewardPerTokenStored.add(
            lastTimeRewardApplicable()
                .sub(lastUpdateTime)
                .mul(rewardRate)
                .mul(1e18)
                .div(totalTokens)
        );
    }

    function earned(
        address account)
        public
        view
        returns (uint256)
    {

        return _earned(
            account,
            rewardsPerToken()
        );
    }

    function _earned(
        address account,
        uint256 _rewardsPerToken)
        internal
        view
        returns (uint256)
    {

        uint256 bzrxBalance = balanceOfByAssetNormed(BZRX, account);
        uint256 vbzrxBalance = balanceOfByAssetNormed(vBZRX, account);
        uint256 lptokenBalance = balanceOfByAssetNormed(LPToken, account);

        uint256 totalTokens = bzrxBalance
            .add(vbzrxBalance)
            .add(lptokenBalance);

        return totalTokens
            .mul(_rewardsPerToken.sub(userRewardPerTokenPaid[account]))
            .div(1e18)
            .add(rewards[account]);
    }

    function notifyRewardAmount(
        uint256 reward,
        uint256 duration)
        external
        onlyOwner
        updateReward(address(0))
    {

        require(isInit, "not init");

        if (periodFinish != 0) {
            if (_getTimestamp() >= periodFinish) {
                rewardRate = reward
                    .div(duration);
            } else {
                uint256 remaining = periodFinish
                    .sub(_getTimestamp());
                uint256 leftover = remaining
                    .mul(rewardRate);
                rewardRate = reward
                    .add(leftover)
                    .div(duration);
            }

            lastUpdateTime = _getTimestamp();
            periodFinish = _getTimestamp()
                .add(duration);
        } else {
            rewardRate = reward
                .div(duration);
            lastUpdateTime = _getTimestamp();
            periodFinish = _getTimestamp()
                .add(duration);
        }

        emit RewardAdded(
            reward,
            duration
        );
    }

    function stakeableByAsset(
        address token,
        address account)
        public
        view
        returns (uint256)
    {

        uint256 walletBalance = IERC20(token).balanceOf(account);

        uint256 stakedBalance = _balancesPerToken[token][account];

        return walletBalance > stakedBalance ?
            walletBalance - stakedBalance :
            0;
    }

    function balanceOfByAssetWalletAware(
        address token,
        address account)
        public
        view
        returns (uint256 balance)
    {

        uint256 walletBalance = IERC20(token).balanceOf(account);

        balance = _balancesPerToken[token][account]
            .min256(walletBalance);

        if (token == BZRX) {
            balance = balance
                .add(iBZRX.assetBalanceOf(account));
        }
    }

    function balanceOfByAsset(
        address token,
        address account)
        public
        view
        returns (uint256 balance)
    {

        balance = _balancesPerToken[token][account];
        if (token == BZRX) {
            balance = balance
                .add(iBZRX.assetBalanceOf(account));
        }
    }

    function balanceOfByAssetNormed(
        address token,
        address account)
        public
        view
        returns (uint256)
    {

        if (token == LPToken) {
            uint256 lptokenBalance = totalSupplyByAsset(LPToken);
            if (lptokenBalance != 0) {
                return totalSupplyByAssetNormed(LPToken)
                    .mul(balanceOfByAsset(LPToken, account))
                    .div(lptokenBalance);
            }
        } else {
            return balanceOfByAsset(token, account);
        }
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {

        return totalSupplyByAsset(BZRX)
            .add(totalSupplyByAsset(vBZRX))
            .add(totalSupplyByAsset(LPToken));
    }

    function totalSupplyNormed()
        public
        view
        returns (uint256)
    {

        return totalSupplyByAssetNormed(BZRX)
            .add(totalSupplyByAssetNormed(vBZRX))
            .add(totalSupplyByAssetNormed(LPToken));
    }

    function totalSupplyByAsset(
        address token)
        public
        view
        returns (uint256 supply)
    {

        supply = _totalSupplyPerToken[token];
        if (token == BZRX) {
            supply = supply
                .add(iBZRX.totalAssetSupply());
        }
    }

    function totalSupplyByAssetNormed(
        address token)
        public
        view
        returns (uint256)
    {

        if (token == LPToken) {
            uint256 circulatingSupply = initialCirculatingSupply; // + VBZRX.totalVested();
            
            return totalSupplyByAsset(LPToken) != 0 ?
                circulatingSupply - totalSupplyByAsset(BZRX) :
                0;
        } else {
            return totalSupplyByAsset(token);
        }
    }

    function _setDelegate(
        address delegateToSet)
        internal
        returns (address currentDelegate)
    {

        currentDelegate = delegate[msg.sender];
        if (currentDelegate != ZERO_ADDRESS) {
            require(delegateToSet == ZERO_ADDRESS || delegateToSet == currentDelegate, "delegate already set");
        } else {
            if (delegateToSet == ZERO_ADDRESS) {
                delegateToSet = msg.sender;
            }
            delegate[msg.sender] = delegateToSet;

            emit DelegateChanged(
                msg.sender,
                currentDelegate,
                delegateToSet
            );

            currentDelegate = delegateToSet;
        }
    }

    function _getTimestamp()
        internal
        view
        returns (uint256)
    {

        return block.timestamp;
    }
}