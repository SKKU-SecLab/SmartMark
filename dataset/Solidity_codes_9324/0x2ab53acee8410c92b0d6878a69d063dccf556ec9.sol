
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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
}

pragma solidity ^0.8.0;



contract ParmaNodesV3 is Ownable {
    using SafeMath for uint256;

    uint256 public nodesLimit;
    uint256 public nodeCost;
    uint256 public claimFee;
    address private _LPAddress;

    bool public nodesPaused = false;
    uint256 public totalNodes;

    IERC20 public parmaToken = IERC20(0x1A2933fbA0c6e959c9A2D2c933f3f8AD4aa9f06e);
    Reward public dailyReward;
    
    struct User {
        address addr;
        uint256 created;
        uint256 lastCreated;
        uint256 nodePools;
    }

    struct Node {
        uint256 id;
        uint256 amount;
        string name;
        string description;
        uint256 created;
        uint256 timestamp;
        uint256 reward;
    }

    struct Reward {
        uint256 reward;
        uint256 updated;
    }

    mapping(address => mapping(uint256 => Node)) public nodes;
    mapping(address => User) public user;

    constructor() {
        nodesLimit = 100;
        nodeCost = uint256(2000000).mul(1e18);
        dailyReward = Reward({reward: uint256(16666).mul(1e18), updated: block.timestamp});
        claimFee = 5;
        _LPAddress = address(0x8cda2065f49be9A1DEd69B7c7D60Db8759D22322);
    }

    modifier nodeExists(address creator, uint256 nodeId) {
        require(nodes[creator][nodeId].id > 0, "This node does not exists.");
        _;
    }

    function userNode(address creator, uint256 nodeId) public view nodeExists(creator, nodeId) returns (Node memory) {
        return nodes[creator][nodeId];
    }

    function rewardCheck(address creator, uint256 nodeId) public view nodeExists(creator, nodeId) returns (bool) {
        return nodes[creator][nodeId].reward == dailyReward.reward;
    }
    
    function nodeEarned(address creator, uint256 nodeId) public view nodeExists(creator, nodeId) returns (uint256) {
        Node memory node = nodes[creator][nodeId];
        uint256 nodeStart = node.timestamp;
        uint256 reward = node.reward;

        uint256 nodeAge = block.timestamp / 1 seconds - nodeStart / 1 seconds;

        if (dailyReward.reward < reward) {
            uint256 updatedTime = block.timestamp / 1 seconds - dailyReward.updated / 1 seconds;
            nodeAge -= updatedTime;
        }

        uint256 rewardPerSec = reward.div(86400);
        uint256 earnedPerSec = rewardPerSec.mul(nodeAge);

        return earnedPerSec;
    }

    function createNodes(string memory name, string memory desc, uint256 amount) external {
        require(!nodesPaused, "Nodes are currently paused.");

        if (user[msg.sender].addr != msg.sender) {
            user[msg.sender] = User({
                addr: msg.sender,
                created: 0,
                lastCreated: 0,
                nodePools: 0
            });
        }

        require(user[msg.sender].created + amount <= nodesLimit, "The node amount exceeds your limit.");

        uint256 totalCost = nodeCost.mul(amount);
        uint256 nodeId = (user[msg.sender].lastCreated).add(1);
        nodes[msg.sender][nodeId] = Node({
            id: nodeId,
            amount: amount,
            name: name,
            description: desc,
            created: block.timestamp,
            timestamp: block.timestamp,
            reward: dailyReward.reward
        });

        totalNodes += amount;
        user[msg.sender].created += amount;
        user[msg.sender].nodePools += 1;
        user[msg.sender].lastCreated = nodeId;
        

        require(parmaToken.balanceOf(msg.sender) > totalCost, "Insufficient Funds in wallet");

        uint256 lpFee = totalCost.mul(10).div(100);

        parmaToken.transferFrom(msg.sender, address(this), totalCost.sub(lpFee));
        parmaToken.transferFrom(msg.sender, _LPAddress, lpFee);
    }

    function createNodesFor(address[] memory addresses, uint256[] memory amounts, string memory name, string memory desc) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addy = addresses[i];
            uint256 amt = amounts[i];

            if (user[addy].addr != addy) {
                user[addy] = User({
                    addr: addy,
                    created: 0,
                    lastCreated: 0,
                    nodePools: 0
                });
            }

            require(user[addy].created + amt <= nodesLimit, "The node amount exceeds your limit.");

            uint256 nodeId = (user[addy].lastCreated).add(1);
            nodes[addy][nodeId] = Node({
                id: nodeId,
                amount: amt,
                name: name,
                description: desc,
                created: block.timestamp,
                timestamp: block.timestamp,
                reward: dailyReward.reward
            });

            totalNodes += amt;
            user[addy].created += amt;
            user[addy].nodePools += 1;
            user[addy].lastCreated = nodeId;
        }
    }

    function claimEarnings() external {
        require(!nodesPaused, "Nodes are currently paused.");

        uint256 totalClaim;
        for (uint256 i = 1; i < user[msg.sender].nodePools + 1; i++) {
            uint256 reward = nodeEarned(msg.sender, i);
            uint256 totalReward = reward.mul(nodes[msg.sender][i].amount);

            nodes[msg.sender][i].reward = dailyReward.reward;
            nodes[msg.sender][i].timestamp = block.timestamp;

            totalClaim += totalReward;
        }

        uint256 feeAmt = totalClaim.mul(claimFee).div(100);
        totalClaim -= feeAmt;

        parmaToken.transfer(msg.sender, totalClaim);
        parmaToken.transfer(_LPAddress, feeAmt);
    }

    function setNodesLimit(uint256 limit) external onlyOwner {
        nodesLimit = limit;
    }

    function updateDailyReward(uint256 reward) external onlyOwner {
        dailyReward.reward = reward.mul(1e18);
        dailyReward.updated = block.timestamp;
    }

    function updateNodeCost(uint256 cost) external onlyOwner {
        nodeCost = cost.mul(1e18);
    }

    function setClaimFee(uint256 fee) external onlyOwner {
        claimFee = fee;
    }

    function setNodesPaused(bool onoff) external onlyOwner {
        nodesPaused = onoff;
    }

    function emergencyWithdrawToken(IERC20 token) external onlyOwner() {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function emergencyWithdrawTokenAmount(IERC20 token, uint256 amount) external onlyOwner() {
        token.transfer(msg.sender, amount);
    }

    function setLPAddress(address addr) external onlyOwner {
        _LPAddress = addr;
    }
}