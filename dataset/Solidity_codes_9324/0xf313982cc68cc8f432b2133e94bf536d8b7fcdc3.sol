
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
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}/**
 *Submitted for verification at Etherscan.io on 2020-05-05
 */


pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);


    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );


    function price0CumulativeLast() external view returns (uint256);


    function price1CumulativeLast() external view returns (uint256);


    function kLast() external view returns (uint256);


    function mint(address to) external returns (uint256 liquidity);


    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


    function skim(address to) external;


    function sync() external;


    function initialize(address, address) external;

}// MIT
pragma solidity ^0.8.0;


contract Farm is AccessControl, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    address[] public tokenAddresses;

    struct RewardToken {
        uint256 initReward;
        uint256 startTime;
        uint256 rewardRate;
        uint256 duration;
        uint256 periodFinish;
        mapping(address => uint256) userRewardPerTokenPaid;
        mapping(address => uint256) rewards;
        uint256 rewardPerTokenStored;
        uint256 lastUpdateTime;
        bool initialized;
    }
    mapping(address => RewardToken) public rewardTokens;

    bytes32 public constant COLLECTION = bytes32(keccak256("COLLECTION_ROLE"));

    function initialize(
        address _rewardToken,
        uint256 _initReward,
        uint256 _startTime,
        uint256 _duration
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(
            _rewardToken != address(0),
            "StakingRewards: rewardToken cannot be null"
        );

        require(_initReward != 0, "StakingRewards: initreward cannot be null");
        require(_duration != 0, "StakingRewards: duration cannot be null");
        require(
            rewardTokens[_rewardToken].initialized == false,
            "already initialized"
        );

        RewardToken storage rewardToken = rewardTokens[_rewardToken];
        rewardToken.initReward = _initReward;
        rewardToken.startTime = _startTime;
        rewardToken.initialized = true;

        tokenAddresses.push(_rewardToken);
        rewardToken.duration = (_duration * 24 hours);

        _notifyRewardAmount(_rewardToken, _initReward);
    }

    uint256 private _totalSupply;
    mapping(address => uint256) public _balances;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    function updateReward(address account) internal {

        RewardToken storage rewardTokenStruct;
        uint256 len = tokenAddresses.length;
        for (uint256 i = 0; i < len; i++) {
            rewardTokenStruct = rewardTokens[tokenAddresses[i]];
            rewardTokenStruct.rewardPerTokenStored = rewardPerToken(
                tokenAddresses[i]
            );
            rewardTokenStruct.lastUpdateTime = lastTimeRewardApplicable(
                tokenAddresses[i]
            );
            if (account != address(0)) {
                rewardTokenStruct.rewards[account] = earned(
                    tokenAddresses[i],
                    account
                );
                rewardTokenStruct.userRewardPerTokenPaid[
                    account
                ] = rewardTokenStruct.rewardPerTokenStored;
            }
        }
    }

    function getRewardTokens() public view returns (address[] memory) {

        return tokenAddresses;
    }

    function lastTimeRewardApplicable(address rewardTokenAddress)
        public
        view
        returns (uint256)
    {

        return
            Math.min(
                block.timestamp,
                rewardTokens[rewardTokenAddress].periodFinish
            );
    }

    function rewardPerToken(address rewardTokenAddress)
        public
        view
        returns (uint256)
    {

        RewardToken storage rewardTokenStruct = rewardTokens[
            rewardTokenAddress
        ];
        if (_totalSupply == 0) {
            return rewardTokenStruct.rewardPerTokenStored;
        }
        return
            rewardTokenStruct.rewardPerTokenStored.add(
                lastTimeRewardApplicable(rewardTokenAddress)
                    .sub(rewardTokenStruct.lastUpdateTime)
                    .mul(rewardTokenStruct.rewardRate)
                    .mul(1e18)
                    .div(_totalSupply)
            );
    }

    function earned(address rewardTokenAddress, address account)
        public
        view
        returns (uint256)
    {

        RewardToken storage rewardTokenStruct = rewardTokens[
            rewardTokenAddress
        ];
        uint256 amount = _balances[account]
            .mul(
                rewardPerToken(rewardTokenAddress).sub(
                    rewardTokenStruct.userRewardPerTokenPaid[account]
                )
            )
            .div(1e36)
            .add(rewardTokenStruct.rewards[account]);

        return amount;
    }

    function claimReward(address rewardTokenAddress) external nonReentrant {

        updateReward(msg.sender);

        RewardToken storage rewardTokenStruct = rewardTokens[
            rewardTokenAddress
        ];
        uint256 reward = rewardTokenStruct.rewards[msg.sender];

        require(reward > 0, "you have no reward");

        IERC20 token = IERC20(rewardTokenAddress);

        require(token.transfer(msg.sender, reward), "Transfer error!");

        rewardTokenStruct.rewards[msg.sender] = 0;
        emit RewardPaid(msg.sender, reward);
    }

    function getReward(address rewardTokenAddress) internal nonReentrant {

        RewardToken storage rewardTokenStruct = rewardTokens[
            rewardTokenAddress
        ];
        uint256 reward = rewardTokenStruct.rewards[msg.sender];

        require(reward > 0, "you have no reward");

        IERC20 token = IERC20(rewardTokenAddress);

        require(token.transfer(msg.sender, reward), "Transfer error!");

        rewardTokenStruct.rewards[msg.sender] = 0;
        emit RewardPaid(msg.sender, reward);
    }

    function emergencyWithdraw(uint256 amount) external nonReentrant {

        require(amount > 0, "StakingRewards: Cannot withdraw 0");
        require(
            _balances[msg.sender] >= amount,
            "Insufficient amount for emergency Withdraw"
        );


        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _token.safeTransfer(msg.sender, amount);

        emit EmergencyWithdraw(msg.sender, amount);
    }

    function remove(uint256 index)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (address[] memory)
    {

        if (index >= tokenAddresses.length) return tokenAddresses;

        for (uint256 i = index; i < tokenAddresses.length - 1; i++) {
            tokenAddresses[i] = tokenAddresses[i + 1];
        }
        tokenAddresses.pop();
        return tokenAddresses;
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function _stake(uint256 _amount) private {

        _totalSupply = _totalSupply.add(_amount);
        _balances[msg.sender] = _balances[msg.sender].add(_amount);
    }

    function _withdraw(uint256 _amount) private {

        _totalSupply = _totalSupply.sub(_amount);
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
    }

    function _notifyRewardAmount(address rewardTokenAddress, uint256 reward)
        internal
    {

        updateReward(address(0));
        RewardToken storage rewardTokenStruct = rewardTokens[
            rewardTokenAddress
        ];
        rewardTokenStruct.rewardRate = reward.mul(1e18).div(
            rewardTokenStruct.duration
        );
        rewardTokenStruct.lastUpdateTime = block.timestamp;
        rewardTokenStruct.periodFinish = block.timestamp.add(
            rewardTokenStruct.duration
        );
        emit RewardAdded(reward);
    }

    function dailyRewardApy(address token) external view returns (uint256) {

        uint256 rate = rewardTokens[token].rewardRate;
        uint256 dailyReward = rate.div(1e18);
        return (dailyReward * 86400);
    }


    struct Staker {
        uint256 amount;
        uint256 lpAmount;
        uint256 lpToSepa;
        uint256 points;
        uint256 timestamp;
        bool isExist;
        bool farm;
        bool lp;
    }

    uint256 public total;
    uint256 immutable fixedConstantPerToken;
    bytes32 public constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");
    mapping(address => Staker) public stakers;
    IERC20 private _token = IERC20(address(0));

    event SenderDeposited(
        address indexed _sender,
        uint256 _amount,
        uint256 _timestamp
    );
    event SenderWithdrawed(
        address indexed _sender,
        uint256 _amount,
        uint256 _timestamp
    );
    event GivenPoints(address indexed _address, uint256 _point);
    event PaymentOccured(address indexed _buyer, uint256 _amount);

    constructor(
        IERC20 token,
        uint256 tokenMultiplier,
        address crowdsaleFactory
    ) {
        _token = token;
        fixedConstantPerToken = tokenMultiplier * 1e18;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(DEFAULT_ADMIN_ROLE, crowdsaleFactory);
    }

    function getTokenAddress() external view returns (address) {

        return address(_token);
    }

    function giveAway(address _address, uint256 points)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        stakers[_address].points = points;
        emit GivenPoints(_address, points);
    }

    function farmed(address sender) external view returns (uint256) {

        return (stakers[sender].amount);
    }

    function farmedStart(address sender) external view returns (uint256) {

        return (stakers[sender].timestamp);
    }

    function payment(address buyer, uint256 amount)
        external
        onlyRole(COLLECTION)
        returns (bool)
    {

        consolidate(buyer);
        Staker storage st = stakers[buyer];

        require(st.points > 0, "accrued points equal to 0");
        require(st.points >= amount, "Insufficient points!");

        st.points -= amount;

        emit PaymentOccured(buyer, amount);
        return true;
    }

    function getConsolidatedRewards(address buyer)
        external
        view
        returns (uint256)
    {

        return stakers[buyer].points;
    }

    function rewardedPoints(address staker) public view returns (uint256) {

        Staker storage st = stakers[staker];
        uint256 _seconds = block.timestamp.sub(st.timestamp);
        uint256 earnPerSec = fixedConstantPerToken / (60 * 60 * 24);
        uint256 result = (st.points +
            ((st.amount * earnPerSec) * _seconds) /
            1e18) + _rewardedPointsLp(staker);
        return result;
    }

    function consolidate(address staker) internal {

        uint256 points = rewardedPoints(staker);
        stakers[staker].points = points;
        stakers[staker].timestamp = block.timestamp;
    }

    function deposit(uint256 amount) external nonReentrant {

        require(amount > 0, "Insufficient amount");
        require(
            _token.balanceOf(msg.sender) >= amount,
            "Insufficient amount for deposit"
        );

        _setupRole(WITHDRAW_ROLE, msg.sender);
        address sender = msg.sender;
        _token.safeTransferFrom(sender, address(this), amount);
        consolidate(sender);

        total = total + amount;
        stakers[sender].amount += amount;
        stakers[sender].farm = true;

        updateReward(msg.sender);
        _stake(amount);

        emit SenderDeposited(sender, amount, block.timestamp);
    }

    function withdraw(uint256 amount) public {

        updateReward(msg.sender);
        address sender = msg.sender;

        require(amount > 0, "amount cannot be zero!");
        require(stakers[sender].amount >= amount, "Insufficient amount!");
        require(_token.transfer(address(sender), amount), "Transfer error!");

        consolidate(sender);
        stakers[sender].amount -= amount;
        if (stakers[sender].amount == 0) {
            stakers[sender].farm = false;
        }
        total = total - amount;
        _withdraw(amount);
        uint256 len = tokenAddresses.length;
        for (uint256 i = 0; i < len; i++) {
            uint256 reward = rewardTokens[tokenAddresses[i]].rewards[
                msg.sender
            ];
            if (reward > 0) {
                getReward(tokenAddresses[i]);
            }
        }

        emit SenderWithdrawed(sender, amount, block.timestamp);
    }


    IUniswapV2Pair uniPair;
    uint256 totalLp;

    event LpDeposited(
        address indexed _sender,
        uint256 _lpAmount,
        uint256 _sepaAmount,
        uint256 _timestamp
    );

    event LpWithdrawed(
        address indexed _sender,
        uint256 _lpAmount,
        uint256 _timestamp
    );

    function setUniswapPairAddress(address _sepaWethPair)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        uniPair = IUniswapV2Pair(_sepaWethPair);
    }

    function _calcSepaToken(uint256 lpAmount) private view returns (uint256) {

        uint256 userLpRatio = (lpAmount * (1e36)) / uniPair.totalSupply();
        (uint256 sepaReserve, , ) = uniPair.getReserves();
        uint256 sepaAmount = (userLpRatio * sepaReserve) / (1e36);
        return sepaAmount;
    }

    function _rewardedPointsLp(address staker) private view returns (uint256) {

        Staker storage st = stakers[staker];
        uint256 _seconds = block.timestamp.sub(st.timestamp);
        uint256 earnPerSec = fixedConstantPerToken / (60 * 60 * 24);
        return (((st.lpToSepa * earnPerSec) * _seconds) / 1e18) * 2;
    }

    function depositLp(uint256 lpAmount) external nonReentrant {

        require(lpAmount > 0, "Insufficient amount");
        require(
            uniPair.balanceOf(msg.sender) >= lpAmount,
            "Insufficient amount for deposit"
        );

        uint256 sepaAmount = _calcSepaToken(lpAmount);

        require(sepaAmount > 0, "Insufficient amount");

        address sender = msg.sender;

        uniPair.transferFrom(sender, address(this), lpAmount);
        consolidate(sender);

        totalLp += lpAmount;
        stakers[sender].lpToSepa += sepaAmount;
        stakers[sender].lpAmount += lpAmount;
        stakers[sender].lp = true;

        emit LpDeposited(sender, lpAmount, sepaAmount, block.timestamp);
    }

    function withdrawLp(uint256 lpAmount) public {

        address sender = msg.sender;

        require(lpAmount > 0, "amount cannot be zero!");
        require(stakers[sender].lpAmount >= lpAmount, "Insufficient amount!");
        require(uniPair.transfer(address(sender), lpAmount), "Transfer error!");

        consolidate(sender);
        stakers[sender].lpAmount -= lpAmount;

        if (stakers[sender].lpAmount == 0) {
            stakers[sender].lp = false;
            stakers[sender].lpToSepa = 0;
        } else {
            stakers[sender].lpToSepa = _calcSepaToken(stakers[sender].lpAmount);
        }

        totalLp = totalLp - lpAmount;

        emit LpWithdrawed(sender, lpAmount, block.timestamp);
    }
}