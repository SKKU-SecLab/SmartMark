

pragma solidity >=0.5.0;

interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}



pragma solidity >=0.5.0 <0.9.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;


            bytes32 accountHash
         = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }


}



pragma solidity >=0.5.0 <0.9.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity >=0.5.0 <0.9.0;



library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}



pragma solidity >=0.5.0 <0.9.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor() public {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}




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

}



pragma solidity >=0.5.0 <0.9.0;

contract Context {

    function _msgSender() internal view returns (address) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        return msg.data;
    }
}




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
}



pragma solidity =0.8.4;







contract QuaiCohortFarming is AccessControl, ReentrancyGuard {

    using SafeERC20 for IERC20;

    bytes32 public constant SUB_ADMIN_ROLE = keccak256("SUB_ADMIN_ROLE");
    address public immutable stakedToken;
    uint256 public numberStakingRewards;
    uint256 public totalSupplies;
    uint256 public accrualBlockTimestamp;
    mapping(uint256 => uint256) public rewardIndex;
    mapping(address => mapping(uint256 => uint256)) public supplierRewardIndex; 
    mapping(address => uint256) public supplyAmount;
    mapping(uint256 => address) public rewardTokenAddresses;
    mapping(uint256 => uint256) public rewardSpeeds;
    mapping(uint256 => uint256) public rewardPeriodFinishes;
    mapping(uint256 => uint256) public unwithdrawnAccruedRewards;    
    mapping(address => mapping(uint256 => uint256)) public accruedReward;

    uint256 public stakedTokenRewardIndex = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    uint256 public stakedTokenYearlyReturn;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);

    modifier onlyAdmins() {

        require (hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(SUB_ADMIN_ROLE, msg.sender), "only admin");
        _;
    }

    constructor(
        address _stakedToken,
        uint256 _numberStakingRewards,
        address[] memory _rewardTokens,
        uint256[] memory _rewardPeriodFinishes,
        address masterAdmin,
        address[] memory subAdmins) 
        {
        require(_stakedToken != address(0));
        require(_rewardTokens.length == _numberStakingRewards, "bad _rewardTokens input");
        require(_rewardPeriodFinishes.length == _numberStakingRewards, "bad _rewardPeriodFinishes input");
        stakedToken = _stakedToken;
        numberStakingRewards = _numberStakingRewards;
        for (uint256 i = 0; i < _numberStakingRewards; i++) {
            require(_rewardTokens[i] != address(0));
            require(_rewardPeriodFinishes[i] > block.timestamp, "cannot set rewards to finish in past");
            if (_rewardTokens[i] == _stakedToken) {
                stakedTokenRewardIndex = i;
            }
            rewardTokenAddresses[i] = _rewardTokens[i];
            rewardPeriodFinishes[i] = _rewardPeriodFinishes[i];
        }
        _grantRole(DEFAULT_ADMIN_ROLE, masterAdmin);
        for (uint256 i = 0; i < subAdmins.length; i++) {
            _grantRole(SUB_ADMIN_ROLE, subAdmins[i]);
        }
    }

    function getClaimableRewards(uint256 rewardTokenIndex) external view returns(uint256) {

        return getUserClaimableRewards(msg.sender, rewardTokenIndex);
    }

    function getUserClaimableRewards(address user, uint256 rewardTokenIndex) public view returns(uint256) {

        require(rewardTokenIndex <= numberStakingRewards, "Invalid reward token");
        uint256 rewardIndexToUse = rewardIndex[rewardTokenIndex];
        if (block.timestamp > accrualBlockTimestamp && totalSupplies != 0) {
            uint256 rewardSpeed = rewardSpeeds[rewardTokenIndex];
            if (rewardSpeed != 0 && accrualBlockTimestamp < rewardPeriodFinishes[rewardTokenIndex]) {
                uint256 blockTimestampDelta = (min(block.timestamp, rewardPeriodFinishes[rewardTokenIndex]) - accrualBlockTimestamp);
                uint256 accrued = (rewardSpeeds[rewardTokenIndex] * blockTimestampDelta);
                IERC20 token = IERC20(rewardTokenAddresses[rewardTokenIndex]);
                uint256 contractTokenBalance = token.balanceOf(address(this));
                if (rewardTokenIndex == stakedTokenRewardIndex) {
                    contractTokenBalance = (contractTokenBalance > totalSupplies) ? (contractTokenBalance - totalSupplies) : 0;
                }
                uint256 remainingToDistribute = (contractTokenBalance > unwithdrawnAccruedRewards[rewardTokenIndex]) ? (contractTokenBalance - unwithdrawnAccruedRewards[rewardTokenIndex]) : 0;
                if (accrued > remainingToDistribute) {
                    accrued = remainingToDistribute;
                }
                uint256 accruedPerStakedToken = (accrued * 1e36) / totalSupplies;
                rewardIndexToUse += accruedPerStakedToken;
            }
        }
        uint256 rewardIndexDelta = rewardIndexToUse - (supplierRewardIndex[user][rewardTokenIndex]);
        uint256 claimableReward = ((rewardIndexDelta * supplyAmount[user]) / 1e36) + accruedReward[user][rewardTokenIndex];
        return claimableReward;
    }

    function getUserDepositedFraction(address user) external view returns(uint256) {

        if (totalSupplies == 0) {
            return 0;
        } else {
            return (supplyAmount[user] * 1e18) / totalSupplies; 
        }
    }

    function getRemainingTokens(uint256 rewardTokenIndex) external view returns(uint256) {

        if (rewardPeriodFinishes[rewardTokenIndex] <= block.timestamp) {
            return 0;
        } else {
            uint256 amount = (rewardPeriodFinishes[rewardTokenIndex] - block.timestamp) * rewardSpeeds[rewardTokenIndex];
            uint256 bal = IERC20(rewardTokenAddresses[rewardTokenIndex]).balanceOf(address(this));
            uint256 totalOwed = unwithdrawnAccruedRewards[rewardTokenIndex];
            uint256 rewardSpeed = rewardSpeeds[rewardTokenIndex];
            if (rewardSpeed != 0 && accrualBlockTimestamp < rewardPeriodFinishes[rewardTokenIndex]) {
                uint256 blockTimestampDelta = (min(block.timestamp, rewardPeriodFinishes[rewardTokenIndex]) - accrualBlockTimestamp);
                uint256 accrued = (rewardSpeeds[rewardTokenIndex] * blockTimestampDelta);
                uint256 remainingToDistribute = (bal > totalOwed) ? (bal - totalOwed) : 0;
                if (accrued > remainingToDistribute) {
                    accrued = remainingToDistribute;
                }
                totalOwed += accrued;
            }
            if (rewardTokenIndex == stakedTokenRewardIndex) {
                totalOwed += totalSupplies;
                if (bal > totalOwed) {
                    return (bal - totalOwed);
                } else {
                    return 0;
                }
            }
            if (bal > totalOwed) {
                bal -= totalOwed;
            } else {
                bal = 0;
            }
            return min(amount, bal);
        }
    }

    function lastTimeRewardApplicable(uint256 rewardTokenIndex) public view returns (uint256) {

        return min(block.timestamp, rewardPeriodFinishes[rewardTokenIndex]);
    }

    function deposit(uint256 amount) external nonReentrant {

        IERC20 token = IERC20(stakedToken);
        uint256 contractBalance = token.balanceOf(address(this));
        token.safeTransferFrom(msg.sender, address(this), amount);
        uint256 depositedAmount = token.balanceOf(address(this)) - contractBalance;
        distributeReward(msg.sender);
        totalSupplies += depositedAmount;
        supplyAmount[msg.sender] += depositedAmount;
        autoUpdateStakedTokenRewardSpeed();

    }

    function withdraw(uint amount) public nonReentrant {

        require(amount <= supplyAmount[msg.sender], "Too large withdrawal");
        distributeReward(msg.sender);
        supplyAmount[msg.sender] -= amount;
        totalSupplies -= amount;
        IERC20 token = IERC20(stakedToken);
        autoUpdateStakedTokenRewardSpeed();
        token.safeTransfer(msg.sender, amount);
    }

    function exit() external {

        withdraw(supplyAmount[msg.sender]);
        claimRewards();
    }

    function claimRewards() public nonReentrant {

        distributeReward(msg.sender);
        for (uint256 i = 0; i < numberStakingRewards; i++) {
            uint256 amount = accruedReward[msg.sender][i];
            claimErc20(i, msg.sender, amount);
        }
    }

    function setRewardSpeed(uint256 rewardTokenIndex, uint256 speed) external onlyAdmins {

        if (accrualBlockTimestamp != 0) {
            accrueReward();
        }
        rewardSpeeds[rewardTokenIndex] = speed;
    }

    function setRewardPeriodFinish(uint256 rewardTokenIndex, uint256 rewardPeriodFinish) external onlyAdmins {

        require(rewardPeriodFinish > block.timestamp, "cannot set rewards to finish in past");
        rewardPeriodFinishes[rewardTokenIndex] = rewardPeriodFinish;
    }

    function setStakedTokenYearlyReturn(uint256 _stakedTokenYearlyReturn) external onlyAdmins {

        stakedTokenYearlyReturn = _stakedTokenYearlyReturn;
        autoUpdateStakedTokenRewardSpeed();
    }

    function setStakedTokenRewardIndex(uint256 _stakedTokenRewardIndex) external onlyAdmins {

        require(rewardTokenAddresses[_stakedTokenRewardIndex] == stakedToken, "can only set for stakedToken");
        stakedTokenRewardIndex = _stakedTokenRewardIndex;
        autoUpdateStakedTokenRewardSpeed();
    }

    function addNewRewardToken(address rewardTokenAddress) external onlyAdmins {

        require(rewardTokenAddress != address(0), "Cannot set zero address");
        numberStakingRewards += 1;
        rewardTokenAddresses[numberStakingRewards - 1] = rewardTokenAddress;
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {

        require(tokenAddress != address(stakedToken), "Cannot withdraw the staked token");
        IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function accrueReward() internal {

        if (block.timestamp == accrualBlockTimestamp) {
            return;
        } else if (totalSupplies == 0) {
            accrualBlockTimestamp = block.timestamp;
            return;
        }
        for (uint256 i = 0; i < numberStakingRewards; i += 1) {
            uint256 rewardSpeed = rewardSpeeds[i];
            if (rewardSpeed == 0 || accrualBlockTimestamp >= rewardPeriodFinishes[i]) {
                continue;
            }
            uint256 blockTimestampDelta = (min(block.timestamp, rewardPeriodFinishes[i]) - accrualBlockTimestamp);
            uint256 accrued = (rewardSpeeds[i] * blockTimestampDelta);

            IERC20 token = IERC20(rewardTokenAddresses[i]);
            uint256 contractTokenBalance = token.balanceOf(address(this));
            if (i == stakedTokenRewardIndex) {
                contractTokenBalance = (contractTokenBalance > totalSupplies) ? (contractTokenBalance - totalSupplies) : 0;
            }
            uint256 remainingToDistribute = (contractTokenBalance > unwithdrawnAccruedRewards[i]) ? (contractTokenBalance - unwithdrawnAccruedRewards[i]) : 0;
            if (accrued > remainingToDistribute) {
                accrued = remainingToDistribute;
                rewardSpeeds[i] = 0;
            }
            unwithdrawnAccruedRewards[i] += accrued;

            uint256 accruedPerStakedToken = (accrued * 1e36) / totalSupplies;
            rewardIndex[i] += accruedPerStakedToken;
        }
        accrualBlockTimestamp = block.timestamp;
    }

    function distributeReward(address recipient) internal {

        accrueReward();
        for (uint256 i = 0; i < numberStakingRewards; i += 1) {
            uint256 rewardIndexDelta = (rewardIndex[i] - supplierRewardIndex[recipient][i]);
            uint256 accruedAmount = (rewardIndexDelta * supplyAmount[recipient]) / 1e36;
            accruedReward[recipient][i] += accruedAmount;
            supplierRewardIndex[recipient][i] = rewardIndex[i];
        }
    }

    function claimErc20(uint256 rewardTokenIndex, address recipient, uint256 amount) internal {

        require(accruedReward[recipient][rewardTokenIndex] <= amount, "Not enough accrued rewards");
        IERC20 token = IERC20(rewardTokenAddresses[rewardTokenIndex]);
        accruedReward[recipient][rewardTokenIndex] -= amount;
        unwithdrawnAccruedRewards[rewardTokenIndex] -= min(unwithdrawnAccruedRewards[rewardTokenIndex], amount);
        token.safeTransfer(recipient, amount);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function autoUpdateStakedTokenRewardSpeed() internal {

        if (rewardPeriodFinishes[stakedTokenRewardIndex] <= block.timestamp) {
            rewardSpeeds[stakedTokenRewardIndex] = 0;
        } else {
            uint256 newRewardSpeed = totalSupplies * stakedTokenYearlyReturn / (31536000 * 1e18);
            rewardSpeeds[stakedTokenRewardIndex] = newRewardSpeed;
        }
    }
}