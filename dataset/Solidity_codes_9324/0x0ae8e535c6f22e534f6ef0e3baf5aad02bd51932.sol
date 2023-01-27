




contract State {

    address payable admin;

    address token;

    address controller;

    struct Pool {
        address token;

        uint256 stakingBalance;
        uint256 stakedBalance;
    }

    struct User {
        uint256 stakingBalance;

        uint256 stakedBalance;

        uint256 pendingReward;
    }

    struct UnstakeRequest {
        address user;

        uint256 amount;

        bool processed;
    }

    Pool[] pools;
    mapping(uint256 => address[]) usersList;
    mapping(uint256 => mapping(address => User)) users;
    mapping(uint256 => UnstakeRequest[]) unstakeRequests;

    function getPoolsLength() public view returns(uint256) {

        return pools.length;
    }

    function getPool(uint256 _pool) public view returns(address) {

        return pools[_pool].token;
    }

    function getUsersListLength(uint256 _pool) public view returns(uint256) {

        return usersList[_pool].length;
    }

    function getUsersList(uint256 _pool) public view returns(address[] memory) {

        return usersList[_pool];
    }

    function getUser(uint256 _pool, address _user) public view returns(uint256 userStakingBalance, uint256 userStakedBalance, uint256 userPendingReward) {

        return (users[_pool][_user].stakingBalance, users[_pool][_user].stakedBalance, users[_pool][_user].pendingReward);
    }

    function getUnstakeRequestsLength(uint256 _pool) public view returns(uint256) {

        return unstakeRequests[_pool].length;
    }

    function getUnstakeRequest(uint256 _pool, uint256 _request) public view returns(address user, uint256 amount, bool processed) {

        return (unstakeRequests[_pool][_request].user, unstakeRequests[_pool][_request].amount, unstakeRequests[_pool][_request].processed);
    }
}






contract Storage {

    uint256[] marketingLevels;

    address[] accountList;

    mapping(address => address) referrals;

    mapping(address => bool) whitelistRoots;

    function getTotalAccount() public view returns(uint256) {

        return accountList.length;
    }

    function getAccountList() public view returns(address[] memory) {

        return accountList;
    }

    function getReferenceBy(address _child) public view returns(address) {

        return referrals[_child];
    }

    function getMarketingMaxLevel() public view returns(uint256) {

        return marketingLevels.length;
    }

    function getMarketingLevelValue(uint256 _level) public view returns(uint256) {

        return marketingLevels[_level];
    }

    function getReferenceParent(address _child, uint256 _level) public view returns(address) {

        uint i;
        address pointer = _child;

        while(i < marketingLevels.length) {
            pointer = referrals[pointer];

            if (i == _level) {
                return pointer;
            }

            i++;
        }

        return address(0);
    }

    function getWhiteListRoot(address _root) public view returns(bool) {

        return whitelistRoots[_root];
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





abstract contract Ownable is Context {
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







contract Controller is Storage, Ownable {

    event LinkCreated(address indexed addr, address indexed refer);

    constructor() public {
        marketingLevels.push(25e6); // 25%
        marketingLevels.push(20e6);
        marketingLevels.push(15e6);
        marketingLevels.push(10e6);
        marketingLevels.push(10e6);
        marketingLevels.push(10e6);
        marketingLevels.push(5e6);
        marketingLevels.push(5e6);
    }

    function register(address _refer) public {

        require(msg.sender != _refer, "ERROR: address cannot refer itself");
        require(referrals[msg.sender] == address(0), "ERROR: already set refer address");

        if (_refer != owner() && !getWhiteListRoot(_refer)) {
            require(referrals[_refer] != address(0), "ERROR: invalid refer address");
        }

        referrals[msg.sender] = _refer;

        emit LinkCreated(msg.sender, _refer);
    }

    function updateMarketingLevelValue(uint256 _level, uint256 _value) public onlyOwner {

        marketingLevels[_level] = _value;
    }

    function addWhiteListRoot(address _root) public onlyOwner {

        whitelistRoots[_root] = true;
    }
}





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






contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}






library ERC20Helper {
    function getDecimals(address addr) internal view returns(uint256) {
        ERC20 token = ERC20(addr);
        return token.decimals();
    }

    function getBalance(address addr, address user) internal view returns(uint256) {
        if (addr == address(0)) {
            return address(addr).balance;
        }

        ERC20 token = ERC20(addr);
        return token.balanceOf(user);
    }
}






contract Getters is State {
    using SafeMath for uint256;

    function getToken() public view returns(address) {
        return token;
    }

    function getAdmin() public view returns(address) {
        return admin;
    }

    function getController() public view returns(address) {
        return controller;
    }


    function getPoolBalance(uint256 _pool) public view returns(uint256) {
        return pools[_pool].stakingBalance + pools[_pool].stakedBalance;
    }

    function getPoolStakingBalance(uint256 _pool) public view returns(uint256) {
        return pools[_pool].stakingBalance;
    }

    function getPoolStakedBalance(uint256 _pool) public view returns(uint256) {
        return pools[_pool].stakedBalance;
    }

    function getPoolPendingReward(uint256 _pool) public view returns(uint256) {
        uint256 amount;
        for (uint256 i=0; i<usersList[_pool].length; i++) {
            address user = usersList[_pool][i];
            amount = amount.add(users[_pool][user].pendingReward);
        }
        return amount;
    }

    function getPoolPendingUnstake(uint256 _pool) public view returns(uint256) {
        uint256 amount;
        for (uint256 i=0; i<unstakeRequests[_pool].length; i++) {
            if (!unstakeRequests[_pool][i].processed) {
                amount = amount.add(unstakeRequests[_pool][i].amount);
            }
        }
        return amount;
    }



    function getUserBalance(uint256 _pool, address _user) public view returns(uint256) {
        return users[_pool][_user].stakingBalance + users[_pool][_user].stakedBalance;
    }

    function getUserStakingBalance(uint256 _pool, address _user) public view returns(uint256) {
        return users[_pool][_user].stakingBalance;
    }

    function getUserStakedBalance(uint256 _pool, address _user) public view returns(uint256) {
        return users[_pool][_user].stakedBalance;
    }

    function getUserPendingReward(uint256 _pool, address _user) public view returns(uint256) {
        return users[_pool][_user].pendingReward;
    }

    function getUserPendingUnstake(uint256 _pool, address _user) public view returns(uint256) {
        uint256 amount;
        for (uint256 i=0; i<unstakeRequests[_pool].length; i++) {
            if (unstakeRequests[_pool][i].user == _user && !unstakeRequests[_pool][i].processed) {
                amount = amount.add(unstakeRequests[_pool][i].amount);
            }
        }
        return amount;
    }

    function estimatePayout(uint256 _pool, uint256 _percent, uint256 _rate) public view returns(uint256) {
        uint256 estimateAmount;
        uint256 decimals = 18;
        if (_pool != 0) {
            decimals = ERC20Helper.getDecimals(pools[_pool].token);
        }

        for (uint256 i=0; i<usersList[_pool].length; i++) {
            address user = usersList[_pool][i];

            uint256 profitAmount = getUserStakedBalance(_pool, user)
                .mul(_percent)
                .mul(_rate)
                .div(100);
            profitAmount = profitAmount.mul(10**(18 - decimals)).div(1e12);

            estimateAmount = estimateAmount.add(profitAmount);

            Controller iController = Controller(controller);
            uint256 maxLevel = iController.getMarketingMaxLevel();
            uint256 level;
            while(level < maxLevel) {
                address parent = iController.getReferenceParent(user, level);
                if (parent == address(0)) break;

                if (getUserStakedBalance(_pool, parent) > 0) {
                    uint256 percent = iController.getMarketingLevelValue(level);
                    uint256 referProfitAmount = profitAmount.mul(percent).div(100).div(1e6);
                    estimateAmount = estimateAmount.add(referProfitAmount);
                }

                level++;
            }
        }

        return estimateAmount;
    }
}







contract Setters is Getters {
    using SafeMath for uint256;

    function setAdmin(address payable _admin) internal {
        admin = _admin;
    }

    function setController(address _controller) internal {
        controller = _controller;
    }

    function setToken(address _token) internal {
        token = _token;
    }

    function increaseUserStakingBalance(uint256 _pool, address _user, uint256 _amount) internal {
        users[_pool][_user].stakingBalance = users[_pool][_user].stakingBalance.add(_amount);

        increasePoolStakingBalance(_pool, _amount);
    }

    function decreaseUserStakingBalance(uint256 _pool, address _user, uint256 _amount) internal {
        users[_pool][_user].stakingBalance = users[_pool][_user].stakingBalance.sub(_amount);

        decreasePoolStakingBalance(_pool, _amount);
    }

    function increaseUserStakedBalance(uint256 _pool, address _user, uint256 _amount) internal {
        users[_pool][_user].stakedBalance = users[_pool][_user].stakedBalance.add(_amount);

        increasePoolStakedBalance(_pool, _amount);
    }

    function decreaseUserStakedBalance(uint256 _pool, address _user, uint256 _amount) internal {
        users[_pool][_user].stakedBalance = users[_pool][_user].stakedBalance.sub(_amount);

        decreasePoolStakedBalance(_pool, _amount);
    }

    function increaseUserPendingReward(uint256 _pool, address _user, uint256 _amount) internal {
        users[_pool][_user].pendingReward = users[_pool][_user].pendingReward.add(_amount);
    }

    function decreaseUserPendingReward(uint256 _pool, address _user, uint256 _amount) internal {
        users[_pool][_user].pendingReward = users[_pool][_user].pendingReward.sub(_amount);
    }

    function emptyUserPendingReward(uint256 _pool, address _user) internal {
        users[_pool][_user].pendingReward = 0;
    }

    function appendNewPool(address _token) internal {
            pools.push(Pool({
            token: _token,
            stakingBalance: 0,
            stakedBalance: 0
        }));
    }

    function increasePoolStakingBalance(uint256 _pool, uint256 _amount) internal {
        pools[_pool].stakingBalance = pools[_pool].stakingBalance.add(_amount);
    }

    function decreasePoolStakedBalance(uint256 _pool, uint256 _amount) internal {
        pools[_pool].stakedBalance = pools[_pool].stakedBalance.sub(_amount);
    }

    function increasePoolStakedBalance(uint256 _pool, uint256 _amount) internal {
        pools[_pool].stakedBalance = pools[_pool].stakedBalance.add(_amount);
    }

    function decreasePoolStakingBalance(uint256 _pool, uint256 _amount) internal {
        pools[_pool].stakingBalance = pools[_pool].stakingBalance.sub(_amount);
    }

    function setProcessedUnstakeRequest(uint256 _pool, uint256 _req) internal {
        unstakeRequests[_pool][_req].processed = true;
    }
}






library Constants {
    address constant BVA = address(0x10d88D7495cA381df1391229Bdb82D015b9Ad17D);
    address constant USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
}





library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}



pragma solidity 0.6.12;



contract SeedPool is Setters, Ownable {
    using SafeMath for uint256;

    event Stake(address indexed user, uint256 indexed pool, uint256 indexed amount);
    event Unstake(address indexed user, uint256 indexed pool, uint256 indexed amount);
    event Harvest(address indexed user, uint256 indexed pool, uint256 indexed amount);
    event Payout(address admin, uint256 indexed pool, uint256 indexed percent, uint256 indexed rate);

    event UnstakeProcessed(address admin, uint256 indexed pool, uint256 indexed amount);

    constructor(address payable _admin, address _controller) public {
        setAdmin(_admin);
        setToken(Constants.BVA);
        setController(_controller);

        appendNewPool(address(0));
        appendNewPool(Constants.USDT);
    }

    receive() external payable {
        require(msg.sender == admin, "ERROR: send ETH to contract is not allowed");
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "ERROR: only admin");
        _;
    }

    function payoutReference(uint256 _pool, address _child, uint256 _amount) internal returns(uint256) {
        uint256 totalPayout;
        Controller iController = Controller(controller);
        uint256 maxLevel = iController.getMarketingMaxLevel();
        uint256 level;
        while(level < maxLevel) {
            address parent = iController.getReferenceParent(_child, level);
            if (parent == address(0)) break;

            if (getUserStakedBalance(_pool, parent) > 0) {
                uint256 percent = iController.getMarketingLevelValue(level);
                uint256 referProfitAmount = _amount.mul(percent).div(100).div(1e6);

                increaseUserPendingReward(_pool, parent, referProfitAmount);
                totalPayout = totalPayout.add(referProfitAmount);
            }

            level++;
        }

        return totalPayout;
    }

    function stake(uint256 _pool, uint256 _value) public payable {
        if (_pool == 0) {
            increaseUserStakingBalance(_pool, msg.sender, msg.value);

            TransferHelper.safeTransferETH(admin, msg.value);

            emit Stake(msg.sender, _pool, msg.value);
        } else {
            TransferHelper.safeTransferFrom(pools[_pool].token, msg.sender, address(this), _value);
            TransferHelper.safeTransfer(pools[_pool].token, admin, _value);

            increaseUserStakingBalance(_pool, msg.sender, _value);

            emit Stake(msg.sender, _pool, _value);
        }

        bool isListed;
        for (uint256 i=0; i<usersList[_pool].length; i++) {
            if (usersList[_pool][i] == msg.sender) isListed = true;
        }

        if (!isListed) {
            usersList[_pool].push(msg.sender);
        }
    }

    function unstake(uint256 _pool, uint256 _value) public {
        uint256 stakedBalance = getUserStakedBalance(_pool, msg.sender);
        uint256 requestedAmount = getUserPendingUnstake(_pool, msg.sender);
        require(_value + requestedAmount <= stakedBalance, "ERROR: insufficient balance");

        unstakeRequests[_pool].push(UnstakeRequest({
            user: msg.sender,
            amount: _value,
            processed: false
        }));

        emit Unstake(msg.sender, _pool, _value);
    }

    function harvest(uint256 _pool) public {
        uint256 receiveAmount = getUserPendingReward(_pool, msg.sender);
        if (receiveAmount > 0) {
            TransferHelper.safeTransfer(token, msg.sender, receiveAmount);
            emptyUserPendingReward(_pool, msg.sender);
        }

        emit Harvest(msg.sender, _pool, receiveAmount);
    }

    function payout(uint256 _pool, uint256 _percent, uint256 _rate) public onlyAdmin {
        uint256 totalPayoutReward;
        uint256 decimals = 18;
        if (_pool != 0) {
            decimals = ERC20Helper.getDecimals(pools[_pool].token);
        }

        for (uint256 i=0; i<usersList[_pool].length; i++) {
            address user = usersList[_pool][i];

            uint256 profitAmount = getUserStakedBalance(_pool, user)
                .mul(_percent)
                .mul(_rate)
                .div(100);
            profitAmount = profitAmount.mul(10**(18 - decimals)).div(1e12);
            totalPayoutReward = totalPayoutReward.add(profitAmount);

            increaseUserPendingReward(_pool, user, profitAmount);

            increaseUserStakedBalance(_pool, user, getUserStakingBalance(_pool, user));
            decreaseUserStakingBalance(_pool, user, getUserStakingBalance(_pool, user));

            uint256 totalReferencePayout = payoutReference(_pool, user, profitAmount);
            totalPayoutReward = totalPayoutReward.add(totalReferencePayout);
        }

        TransferHelper.safeTransferFrom(token, msg.sender, address(this), totalPayoutReward);

        emit Payout(msg.sender, _pool, _percent, _rate);
    }

    function processUnstake(uint256 _pool, uint256 _amount) public payable onlyAdmin {
        if (_pool == 0) {
            uint256 tokenBalance = address(this).balance;

            for (uint256 i=0; i<unstakeRequests[_pool].length; i++) {
                if (unstakeRequests[_pool][i].amount <= tokenBalance && !unstakeRequests[_pool][i].processed) {
                    address user = unstakeRequests[_pool][i].user;
                    TransferHelper.safeTransferETH(user, unstakeRequests[_pool][i].amount);
                    tokenBalance = tokenBalance.sub(unstakeRequests[_pool][i].amount);
                    decreaseUserStakedBalance(_pool, user, unstakeRequests[_pool][i].amount);
                    setProcessedUnstakeRequest(_pool, i);
                }
            }

            emit UnstakeProcessed(msg.sender, _pool, msg.value);
        } else {
            TransferHelper.safeTransferFrom(pools[_pool].token, getAdmin(), address(this), _amount);
            uint256 tokenBalance = ERC20Helper.getBalance(pools[_pool].token, address(this));

            for (uint256 i=0; i<unstakeRequests[_pool].length; i++) {
                if (unstakeRequests[_pool][i].amount <= tokenBalance && !unstakeRequests[_pool][i].processed) {
                    address user = unstakeRequests[_pool][i].user;
                    TransferHelper.safeTransfer(pools[_pool].token, user, unstakeRequests[_pool][i].amount);
                    tokenBalance = tokenBalance.sub(unstakeRequests[_pool][i].amount);

                    decreaseUserStakedBalance(_pool, user, unstakeRequests[_pool][i].amount);
                    setProcessedUnstakeRequest(_pool, i);
                }
            }

            emit UnstakeProcessed(msg.sender, _pool, _amount);
        }
    }

    function emergencyGetToken(uint256 _pool) public onlyAdmin {
        if (_pool == 0) {
            TransferHelper.safeTransferETH(msg.sender, address(this).balance);
        } else {
            IERC20 token = IERC20(pools[_pool].token);
            TransferHelper.safeTransfer(pools[_pool].token, msg.sender, token.balanceOf(address(this)));
        }
    }

    function changeAdmin(address payable _admin) public onlyOwner {
        setAdmin(_admin);
    }

    function changeToken(address _token) public onlyOwner {
        setToken(_token);
    }

    function changeController(address _controller) public onlyOwner {
        setController(_controller);
    }
}