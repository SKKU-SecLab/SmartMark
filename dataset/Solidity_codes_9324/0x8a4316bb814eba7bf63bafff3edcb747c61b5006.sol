


pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}


pragma solidity ^0.6.0;

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
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

        _callOptionalReturn(
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
        _callOptionalReturn(
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
        _callOptionalReturn(
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


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

pragma solidity 0.6.12;

interface IOracle {

    function update() external;


    function consult(address _token, uint256 _amountIn)
        external
        view
        returns (uint144 amountOut);


    function twap(address _token, uint256 _amountIn)
        external
        view
        returns (uint144 _amountOut);

}

pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;

contract Node {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public gldm;
    address public oracle;
    uint256[] public tierAllocPoints = [1, 1, 1];
    uint256[] public tierAmounts = [0.8 ether, 8 ether, 80 ether];
    struct User {
        uint256 total_deposits;
        uint256 total_claims;
        uint256 last_distPoints;
    }

    event CreateNode(uint256 timestamp, address account, uint256 num);

    address private dev;

    mapping(address => User) public users;
    mapping(address => mapping(uint256 => uint256)) public nodes;
    mapping(uint256 => uint256) public totalNodes;
    mapping(address => bool) public whitelist;
    address[] public userIndices;

    uint256 public total_deposited;
    uint256 public total_claimed;
    uint256 public total_rewards;
    uint256 public totalDistributePoints;

    uint256 public maxReturnPercent = 144;
    uint256 public dailyRewardP = 15;
    uint256 public rewardPerSec =
        tierAmounts[0].mul(dailyRewardP).div(1000).div(24 * 3600);
    uint256 public lastDripTime;

    uint256 public startTime;
    bool public enabled;
    uint256 public constant MULTIPLIER = 10e18;
    uint256 public nodesLimit = 1000;
    bool public isWhitelist = true;

    uint256 public claimFeeBelow = 20;
    uint256 public claimFeeAbove = 10;

    constructor(
        uint256 _startTime,
        address _gldm,
        address _oracle
    ) public {
        gldm = IERC20(_gldm);
        oracle = _oracle;

        lastDripTime = _startTime > block.timestamp
            ? _startTime
            : block.timestamp;
        startTime = _startTime;
        enabled = true;
        dev = msg.sender;
    }

    receive() external payable {
        revert("Do not send Ether.");
    }

    modifier onlyDev() {

        require(msg.sender == dev, "Caller is not the dev!");
        _;
    }

    function setClaimFee(uint256 _below, uint256 _above) external onlyDev {

        claimFeeBelow = _below;
        claimFeeAbove = _above;
    }

    function setDailyRewardPercent(uint256 _p) external onlyDev {

        dailyRewardP = _p;
        rewardPerSec = tierAmounts[0].mul(dailyRewardP).div(1000).div(
            24 * 3600
        );
    }

    function addWhitelist(address[] memory _list) external onlyDev {

        for (uint256 i = 0; i < _list.length; i++) {
            whitelist[_list[i]] = true;
        }
    }

    function removeWhitelist(address[] memory _list) external onlyDev {

        for (uint256 i = 0; i < _list.length; i++) {
            whitelist[_list[i]] = false;
        }
    }

    function setIsWhitelist(bool _f) external onlyDev {

        isWhitelist = _f;
    }

    function changeDev(address payable newDev) external onlyDev {

        require(newDev != address(0), "Zero address");
        dev = newDev;
    }

    function setStartTime(uint256 _startTime) external onlyDev {

        startTime = _startTime;
    }

    function setEnabled(bool _enabled) external onlyDev {

        enabled = _enabled;
    }

    function setLastDripTime(uint256 timestamp) external onlyDev {

        lastDripTime = timestamp;
    }

    function setMaxReturnPercent(uint256 percent) external onlyDev {

        maxReturnPercent = percent;
    }

    function setTierValues(
        uint256[] memory _tierAllocPoints,
        uint256[] memory _tierAmounts
    ) external onlyDev {

        require(
            _tierAllocPoints.length == _tierAmounts.length,
            "Length mismatch"
        );
        tierAllocPoints = _tierAllocPoints;
        tierAmounts = _tierAmounts;
    }

    function setUser(address _addr, User memory _user) external onlyDev {

        total_deposited = total_deposited.sub(users[_addr].total_deposits).add(
            _user.total_deposits
        );
        total_claimed = total_claimed.sub(users[_addr].total_claims).add(
            _user.total_claims
        );
        users[_addr].total_deposits = _user.total_deposits;
        users[_addr].total_claims = _user.total_claims;
    }

    function setNodes(address _user, uint256[] memory _nodes) external onlyDev {

        for (uint256 i = 0; i < _nodes.length; i++) {
            totalNodes[i] = totalNodes[i].sub(nodes[_user][i]).add(_nodes[i]);
            nodes[_user][i] = _nodes[i];
        }
    }
    function setNodeLimit(uint256 _limit) external onlyDev {

        nodesLimit = _limit;
    }

    function totalAllocPoints() public view returns (uint256) {

        uint256 total = 0;
        for (uint256 i = 0; i < tierAllocPoints.length; i++) {
            total = total.add(tierAllocPoints[i].mul(totalNodes[i]));
        }
        return total;
    }

    function allocPoints(address account) public view returns (uint256) {

        uint256 total = 0;
        for (uint256 i = 0; i < tierAllocPoints.length; i++) {
            total = total.add(tierAllocPoints[i].mul(nodes[account][i]));
        }
        return total;
    }

    function getDistributionRewards(address account)
        public
        view
        returns (uint256)
    {

        if (isMaxPayout(account)) return 0;

        uint256 newDividendPoints = totalDistributePoints.sub(
            users[account].last_distPoints
        );
        uint256 distribute = allocPoints(account).mul(newDividendPoints);
        return distribute > total_rewards ? total_rewards : distribute;
    }

    function getTotalRewards(address _sender) public view returns (uint256) {

        if (users[_sender].total_deposits == 0) return 0;

        uint256 rewards = getDistributionRewards(_sender).add(
            getRewardDrip().mul(allocPoints(_sender))
        );
        uint256 totalClaims = users[_sender].total_claims;
        uint256 maxPay = maxPayout(_sender);

        return
            totalClaims.add(rewards) > maxPay
                ? maxPay.sub(totalClaims)
                : rewards;
    }
    function dripRewards() public {

        uint256 drip = getRewardDrip();

        if (drip > 0) {
            _disperse(drip);
            lastDripTime = block.timestamp;
        }
    }

    function getRewardDrip() public view returns (uint256) {

        if (lastDripTime < block.timestamp) {
            uint256 poolBalance = getBalancePool();
            uint256 secondsPassed = block.timestamp.sub(lastDripTime);
            uint256 drip = secondsPassed.mul(rewardPerSec);

            if (drip > poolBalance) {
                drip = poolBalance;
            }

            return drip;
        }
        return 0;
    }
    function _disperse(uint256 amount) internal {

        if (amount > 0) {
            totalDistributePoints = totalDistributePoints.add(amount);
            total_rewards = total_rewards.add(amount.mul(totalAllocPoints()));
        }
    }

    function create(uint256 nodeTier, uint256 numNodes) external {

        address _sender = msg.sender;
        if (isWhitelist) require(whitelist[_sender], "Not in whitelist");
        require(
            totalNodes[nodeTier] + numNodes <= nodesLimit,
            "Node count exceeds"
        );
        require(enabled && block.timestamp >= startTime, "Disabled");

        if (users[_sender].total_deposits == 0) {
            userIndices.push(_sender); // New user
            users[_sender].last_distPoints = totalDistributePoints;
        }
        if (users[_sender].total_deposits != 0 && isMaxPayout(_sender)) {
            users[_sender].last_distPoints = totalDistributePoints;
        }

        uint256 tierPrice = tierAmounts[nodeTier].mul(numNodes);

        require(gldm.balanceOf(_sender) >= tierPrice, "Insufficient balance");
        require(
            gldm.allowance(_sender, address(this)) >= tierPrice,
            "Insufficient allowance"
        );
        gldm.safeTransferFrom(_sender, address(this), tierPrice);

        users[_sender].total_deposits = users[_sender].total_deposits.add(
            tierPrice
        );

        total_deposited = total_deposited.add(tierPrice);

        nodes[_sender][nodeTier] = nodes[_sender][nodeTier].add(numNodes);
        totalNodes[nodeTier] = totalNodes[nodeTier].add(numNodes);

        emit CreateNode(block.timestamp, _sender, numNodes);
    }

    function claim() public {

        dripRewards();

        address _sender = msg.sender;
        uint256 _rewards = getTotalRewards(_sender);

        if (_rewards > 0) {
            total_rewards = total_rewards.sub(_rewards);
            uint256 totalClaims = users[_sender].total_claims;
            uint256 maxPay = maxPayout(_sender);
            if (totalClaims.add(_rewards) > maxPay) {
                _rewards = maxPay.sub(totalClaims);
            }
            users[_sender].total_claims = users[_sender].total_claims.add(
                _rewards
            );
            total_claimed = total_claimed.add(_rewards);

            uint256 feeP;
            if (getGLDMPrice() > MULTIPLIER) feeP = claimFeeAbove;
            else feeP = claimFeeBelow;
            uint256 fee = _rewards.mul(feeP).div(100);
            _rewards = _rewards.sub(fee);

            IERC20(gldm).safeTransfer(_sender, _rewards);
            IERC20(gldm).safeTransfer(dev, fee);

            users[_sender].last_distPoints = totalDistributePoints;
        }
    }

    function _compound(uint256 nodeTier, uint256 numNodes) internal {

        address _sender = msg.sender;
        if (isWhitelist) require(whitelist[_sender], "Not in whitelist");
        require(
            totalNodes[nodeTier] + numNodes <= nodesLimit,
            "Node count exceeds"
        );
        require(enabled && block.timestamp >= startTime, "Disabled");

        if (users[_sender].total_deposits == 0) {
            userIndices.push(_sender); // New user
            users[_sender].last_distPoints = totalDistributePoints;
        }
        if (users[_sender].total_deposits != 0 && isMaxPayout(_sender)) {
            users[_sender].last_distPoints = totalDistributePoints;
        }

        uint256 tierPrice = tierAmounts[nodeTier].mul(numNodes);

        require(gldm.balanceOf(_sender) >= tierPrice, "Insufficient balance");
        require(
            gldm.allowance(_sender, address(this)) >= tierPrice,
            "Insufficient allowance"
        );
        gldm.safeTransferFrom(_sender, address(this), tierPrice);

        users[_sender].total_deposits = users[_sender].total_deposits.add(
            tierPrice
        );

        total_deposited = total_deposited.add(tierPrice);

        nodes[_sender][nodeTier] = nodes[_sender][nodeTier].add(numNodes);
        totalNodes[nodeTier] = totalNodes[nodeTier].add(numNodes);

        emit CreateNode(block.timestamp, _sender, numNodes);
    }

    function compound() public {

        uint256 rewardsPending = getTotalRewards(msg.sender);
        require(rewardsPending >= tierAmounts[0], "Not enough to compound");
        uint256 numPossible = rewardsPending.div(tierAmounts[0]);
        claim();
        _compound(0, numPossible);
    }

    function maxPayout(address _sender) public view returns (uint256) {

        return users[_sender].total_deposits.mul(maxReturnPercent).div(100);
    }

    function isMaxPayout(address _sender) public view returns (bool) {

        return users[_sender].total_claims >= maxPayout(_sender);
    }

    function getGLDMPrice() public view returns (uint256 gldmPrice) {

        try IOracle(oracle).consult(address(gldm), 1e18) returns (
            uint144 price
        ) {
            return uint256(price);
        } catch {
            revert("Treasury: failed to consult gldm price from the oracle");
        }
    }

    function getDayDripEstimate(address _user) external view returns (uint256) {

        return
            allocPoints(_user) > 0 && !isMaxPayout(_user)
                ? rewardPerSec.mul(86400).mul(allocPoints(_user)).div(
                    MULTIPLIER
                )
                : 0;
    }

    function total_users() external view returns (uint256) {

        return userIndices.length;
    }

    function numNodes(address _sender, uint256 _nodeId)
        external
        view
        returns (uint256)
    {

        return nodes[_sender][_nodeId];
    }

    function getNodes(address _sender)
        external
        view
        returns (uint256[] memory)
    {

        uint256[] memory userNodes = new uint256[](tierAllocPoints.length);
        for (uint256 i = 0; i < tierAllocPoints.length; i++) {
            userNodes[i] = userNodes[i].add(nodes[_sender][i]);
        }
        return userNodes;
    }

    function getTotalNodes() external view returns (uint256[] memory) {

        uint256[] memory totals = new uint256[](tierAllocPoints.length);
        for (uint256 i = 0; i < tierAllocPoints.length; i++) {
            totals[i] = totals[i].add(totalNodes[i]);
        }
        return totals;
    }

    function getBalance() public view returns (uint256) {

        return IERC20(gldm).balanceOf(address(this));
    }

    function getBalancePool() public view returns (uint256) {

        return getBalance().sub(total_rewards);
    }

    function emergencyWithdraw(IERC20 token, uint256 amnt) external onlyDev {

        token.safeTransfer(dev, amnt);
    }
}