
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

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

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
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

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

interface ILockDexPair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}

struct LockingPeriod {
    uint64 lockedEpoch;
    uint64 unlockEpoch;
    uint256 amount;
}

interface IMigratorLDX {

    function migrate(address token) external returns (address);

}

interface ILockDexReward {

    function payReward(address _lpToken, address _user, LockingPeriod[] memory _lockingPeriods, uint64 _lastRewardEpoch) external returns (uint);

    function pendingReward(address _lpToken, LockingPeriod[] memory _lockingPeriods, uint64 _lastRewardEpoch) external view returns (uint);

    function availablePair(address _lpToken) external view returns (bool);

}

contract LockDexMaster is Ownable() {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event onDeposit(address indexed token, address indexed user, uint256 amount, uint64 lockedEpoch, uint64 unlockEpoch);
    event onWithdraw(address indexed token, address indexed user, uint256 amount);

    struct UserTokenInfo {
        uint256 deposited; // incremented on successful deposit
        uint256 withdrawn; // incremented on successful withdrawl
        LockingPeriod[] lockingPeriods; // added to on successful deposit
        uint64 lastRewardEpoch;
        uint256 totalRewardPaid; // total paid LDX reward
    }

    mapping(address => mapping(address => UserTokenInfo)) tokenUserMap;

    struct LiquidityTokenomics {
        uint64[] epochs;
        mapping (uint64 => uint256) releaseMap; // map epoch -> amount withdrawable
    }

    mapping(address => LiquidityTokenomics) tokenEpochMap;

    mapping(address => bool) public lockedTokenLookup;

    address[] public tokens;

    mapping(address => bool) public greyList;

    mapping(address => bool) public usersLookup;

    address[] public users;

    mapping(address => bool) public blockedPair;

    address public lockDexRouter02;

    ILockDexReward public lockDexReward;

    IMigratorLDX public migrator;

    bool public started;

    function lockTokenForUser(address token, address user, uint256 amount, uint64 unlock_date) internal {

        require(unlock_date < 10000000000, 'Enter an unix timestamp in seconds, not miliseconds');
        uint64 _unlockEpoch = uint64(block.timestamp) < unlock_date ? unlock_date : 0;
        LiquidityTokenomics storage liquidityTokenomics = tokenEpochMap[token];

        if (!lockedTokenLookup[token]) {
            tokens.push(token);
            lockedTokenLookup[token] = true;
        }
        if (!usersLookup[user]) {
            users.push(user);
            usersLookup[user] = true;
        }

        if (liquidityTokenomics.releaseMap[_unlockEpoch] > 0) {
            liquidityTokenomics.releaseMap[_unlockEpoch] = liquidityTokenomics.releaseMap[_unlockEpoch].add(amount);
        } else {
            liquidityTokenomics.epochs.push(_unlockEpoch);
            liquidityTokenomics.releaseMap[_unlockEpoch] = amount;
        }
        UserTokenInfo storage uto = tokenUserMap[token][user];
        uto.deposited = uto.deposited.add(amount);
        LockingPeriod[] storage lockingPeriod = uto.lockingPeriods;
        lockingPeriod.push(LockingPeriod(uint64(block.timestamp), _unlockEpoch, amount));

        emit onDeposit(token, user, amount, uint64(block.timestamp), _unlockEpoch);
    }

    function depositToken(address token, uint256 amount, uint64 unlock_date) external {

        require(started, 'not started!');
        require(msg.sender == tx.origin || greyList[msg.sender], 'not grey listed!');
        require(blockedPair[token] == false, 'blocked!');
        require(amount > 0, 'Your attempting to trasfer 0 tokens');
        require(lockDexReward.availablePair(token) == true, "invalid pair");

        uint256 allowance = IERC20(token).allowance(msg.sender, address(this));
        require(allowance >= amount, 'You need to set a higher allowance');

        require(IERC20(token).transferFrom(msg.sender, address(this), amount), 'Transfer failed');
        lockTokenForUser(token, msg.sender, amount, unlock_date);
    }

    function mintAndLockTokenForUser(address token, address user, uint64 unlock_date) external returns(uint256) {

        require(msg.sender == lockDexRouter02, "not router!");

        ILockDexPair pair = ILockDexPair(token);
        uint256 oldBalance = pair.balanceOf(address(this));
        pair.mint(address(this));
        uint256 amount = pair.balanceOf(address(this)) - oldBalance;

        lockTokenForUser(token, user, amount, unlock_date);
        return amount;
    }

    function withdrawToken(address token, uint256 amount) external {

        require(amount > 0, 'Your attempting to withdraw 0 tokens');
        require(msg.sender == tx.origin || greyList[msg.sender], 'not grey listed!');
        payRewardForUser(token, msg.sender);

        UserTokenInfo storage uto = tokenUserMap[token][msg.sender];
        LockingPeriod[] storage periods = uto.lockingPeriods;
        LiquidityTokenomics storage liquidityTokenomics = tokenEpochMap[token];
        mapping (uint64 => uint256) storage releaseMap = liquidityTokenomics.releaseMap;
        uint64[] storage epochs = liquidityTokenomics.epochs;
        uint256 availableAmount = 0;
        uint64 currentEpoch = uint64(block.timestamp);

        for (uint i = 1; i <= periods.length; i += 1) {
            if (periods[i - 1].unlockEpoch <= currentEpoch) {
                LockingPeriod storage period = periods[i - 1];
                uint64 unlockEpoch = period.unlockEpoch;
                availableAmount += period.amount;
                releaseMap[unlockEpoch] = releaseMap[unlockEpoch].sub(period.amount);

                if (releaseMap[unlockEpoch] == 0 && availableAmount <= amount) {
                    for (uint j = 0; j < epochs.length; j += 1) {
                        if (epochs[j] == unlockEpoch) {
                            epochs[j] = epochs[epochs.length - 1];
                            epochs.pop();
                            break;
                        }
                    }
                }
                if (availableAmount > amount) {
                    period.amount = availableAmount.sub(amount);
                    releaseMap[unlockEpoch] = releaseMap[unlockEpoch].add(period.amount);
                    break;
                } else {
                    LockingPeriod storage lastPeriod = periods[periods.length - 1];
                    period.amount = lastPeriod.amount;
                    period.lockedEpoch = lastPeriod.lockedEpoch;
                    period.unlockEpoch = lastPeriod.unlockEpoch;
                    periods.pop();

                    if (availableAmount == amount) {
                        break;
                    } else {
                        i -= 1;
                    }
                }
            }
        }

        require(availableAmount >= amount, "insufficient withdrawable amount");
        uto.withdrawn = uto.withdrawn.add(amount);
        require(IERC20(token).transfer(msg.sender, amount), 'Transfer failed');

        emit onWithdraw(token, msg.sender, amount);
    }

    function getWithdrawableBalance(address token, address user) external view returns (uint256) {

        UserTokenInfo storage uto = tokenUserMap[token][address(user)];
        uint arrayLength = uto.lockingPeriods.length;
        uint256 withdrawable = 0;
        for (uint i = 0; i < arrayLength; i += 1) {
            LockingPeriod storage lockingPeriod = uto.lockingPeriods[i];
            if (lockingPeriod.unlockEpoch <= uint64(block.timestamp)) {
                withdrawable = withdrawable.add(lockingPeriod.amount);
            }
        }
        return withdrawable;
    }

    function getUserTokenInfo (address token, address user) external view returns (uint256, uint256, uint64, uint256) {
        UserTokenInfo storage uto = tokenUserMap[address(token)][address(user)];
        return (uto.deposited, uto.withdrawn, uto.lastRewardEpoch, uto.lockingPeriods.length);
    }

    function getUserLockingAtIndex (address token, address user, uint index) external view returns (uint64, uint64, uint256) {
        UserTokenInfo storage uto = tokenUserMap[address(token)][address(user)];
        LockingPeriod storage lockingPeriod = uto.lockingPeriods[index];
        return (lockingPeriod.lockedEpoch, lockingPeriod.unlockEpoch, lockingPeriod.amount);
    }

    function getTokenReleaseInfo (address token) external view returns (uint256, uint256) {
        LiquidityTokenomics storage liquidityTokenomics = tokenEpochMap[address(token)];
        ILockDexPair pair = ILockDexPair(token);
        uint balance = pair.balanceOf(address(this));
        return (balance, liquidityTokenomics.epochs.length);
    }

    function getTokenReleaseAtIndex (address token, uint index) external view returns (uint256, uint256) {
        LiquidityTokenomics storage liquidityTokenomics = tokenEpochMap[address(token)];
        uint64 epoch = liquidityTokenomics.epochs[index];
        uint256 amount = liquidityTokenomics.releaseMap[epoch];
        return (epoch, amount);
    }

    function lockedTokensLength() external view returns (uint) {

        return tokens.length;
    }

    function payRewardForUser(address token, address user) internal {

        if (blockedPair[token] == true) {
            return;
        }
        UserTokenInfo storage uto = tokenUserMap[token][user];
        LockingPeriod[] storage periods = uto.lockingPeriods;

        uint256 reward = lockDexReward.payReward(token, user, periods, uto.lastRewardEpoch);
        uto.lastRewardEpoch = uint64(block.timestamp);

        uto.totalRewardPaid += reward;
    }

    function payReward(address token) external {

        require(msg.sender == tx.origin || greyList[msg.sender], 'not grey listed!');
        payRewardForUser(token, msg.sender);
    }

    function pendingReward(address token, address user) external view returns (uint) {

        UserTokenInfo storage uto = tokenUserMap[token][user];
        LockingPeriod[] storage periods = uto.lockingPeriods;
        return lockDexReward.pendingReward(token, periods, uto.lastRewardEpoch);
    }

    function setGreyList(address _contract, bool allow) external onlyOwner {

        greyList[_contract] = allow;
    }

    function setMigrator(IMigratorLDX _migrator) external onlyOwner {

        migrator = _migrator;
    }

    function setReward(ILockDexReward _reward) external onlyOwner {

        lockDexReward = _reward;
    }

    function migrate(address lpToken) external {

        require(address(migrator) != address(0), "migrate: no migrator");
        require(lockedTokenLookup[lpToken], "not locked!");

        uint256 bal = IERC20(lpToken).balanceOf(address(this));
        address newLpToken;
        if (bal > 0) {
            IERC20(lpToken).safeApprove(address(migrator), bal);
            newLpToken = migrator.migrate(lpToken);
            require(bal == IERC20(newLpToken).balanceOf(address(this)), "migrate: bad");
        }
        for (uint i = 0; i < users.length; i += 1) {
            address user = users[i];
            tokenUserMap[newLpToken][user] = tokenUserMap[lpToken][user];
            delete tokenUserMap[lpToken][user];
        }

        tokenEpochMap[newLpToken] = tokenEpochMap[lpToken];
        mapping (uint64 => uint256) storage releaseMap = tokenEpochMap[newLpToken].releaseMap;
        uint64[] storage epochs = tokenEpochMap[newLpToken].epochs;
        for (uint j = 0; j < epochs.length; j += 1) {
            releaseMap[epochs[j]] = tokenEpochMap[lpToken].releaseMap[epochs[j]];
        }
        delete tokenEpochMap[lpToken];
        lockedTokenLookup[lpToken] = false;
        lockedTokenLookup[newLpToken] = true;

        for (uint i = 0; i < tokens.length; i += 1) {
            if (tokens[i] == lpToken) {
                tokens[i] = newLpToken;
            }
        }
    }

    function setRouter02(address _lockDexRouter02) external onlyOwner {

        lockDexRouter02 = _lockDexRouter02;
    }

    function blockPair(address _token, bool _blocked) external onlyOwner {

        blockedPair[_token] = _blocked;
    }

    function start() external onlyOwner {

        started = true;
    }
}