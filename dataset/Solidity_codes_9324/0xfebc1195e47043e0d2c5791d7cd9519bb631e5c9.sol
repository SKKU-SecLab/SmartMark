


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

}



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


pragma solidity ^0.8.0;

contract EightDAOToken is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public startReleaseTime = 1678204800;
    struct Workflow {
        uint256[] releaseTimes;
        uint256 index;
        uint256 unlockPoint;
    }
    uint256 workflowNonce = 0;
    bool public lockEnable = true;
    mapping(uint256 => Workflow) private workflows;
    struct Task {
        uint256 releaseTime;
    }
    uint256 public maxSupply = 10000000 * 1e18;
    mapping(address => uint256[]) private walletWorkflows;
    mapping(address => uint256) public lockedAmount;

    event CreateTasks(
        uint256 workeflowId,
        uint256 releaseTime,
        uint256 unlockPoint
    );
    event JoinWorkflow(address wallet, uint256 workeflowId, uint256 index);
    event LeaveWorkflow(address wallet, uint256 workeflowId, uint256 index);

    constructor() ERC20("8DAO TOKEN", "8DAO") {}

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        if (lockedAmount[owner] > 0) {
            checkTaskAndAdvanceTask(owner);
            require(
                canTransferAmount(owner) >= amount,
                "Transfer amount exceed the locked amount"
            );
        }
        _transfer(owner, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        if (lockedAmount[from] > 0) {
            checkTaskAndAdvanceTask(from);

            require(
                canTransferAmount(from) >= amount,
                "Transfer amount exceed the locked amount"
            );
        }
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function walletInfo(address wallet)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256[] memory
        )
    {
        return (
            balanceOf(wallet),
            canTransferAmount(wallet),
            releasedAmount(wallet),
            lockedAmount[wallet],
            _joinedWorkflows(wallet)
        );
    }

    function canTransferAmount(address wallet) public view returns (uint256) {
        uint256 balance = balanceOf(wallet);
        if (lockEnable && lockedAmount[wallet] > 0) {
            uint256 unlockedAmount = releasedAmount(wallet);
            if (lockedAmount[wallet] >= unlockedAmount) {
                uint256 remainLockedAmount = lockedAmount[wallet].sub(
                    unlockedAmount
                );
                return
                    remainLockedAmount >= balance
                        ? 0
                        : balance.sub(remainLockedAmount);
            }
        }
        return balanceOf(wallet);
    }

    function _now() public view returns (uint256) {
        return block.timestamp;
    }

    function getWorkflow(uint256 workflowId)
        external
        view
        returns (
            uint256[] memory,
            uint256,
            uint256
        )
    {
        return (
            workflows[workflowId].releaseTimes,
            workflows[workflowId].index,
            workflows[workflowId].unlockPoint
        );
    }

    function releasedAmount(address wallet) public view returns (uint256) {
        if (!lockEnable) {
            return lockedAmount[wallet];
        }
        if (startReleaseTime > block.timestamp) {
            return 0;
        }
        if (walletWorkflows[wallet].length < 1) {
            return 0;
        }
        uint256 unlocked = 0;
        for (uint256 i = 0; i < walletWorkflows[wallet].length; i++) {
            uint256 workeflowId = walletWorkflows[wallet][i];
            uint256 currentIndex = workflows[workeflowId].index;

            for (
                uint256 index = workflows[workeflowId].index;
                index < workflows[workeflowId].releaseTimes.length;
                index++
            ) {
                if (
                    index == workflows[workeflowId].releaseTimes.length - 1 ||
                    workflows[workeflowId].releaseTimes[index] > block.timestamp
                ) {
                    currentIndex = (index > 0) ? index - 1 : 0;
                    break;
                }
            }
            unlocked = unlocked.add(
                lockedAmount[wallet]
                    .mul(
                        (currentIndex + 1).mul(
                            workflows[workeflowId].unlockPoint
                        )
                    )
                    .div(100000)
            );
        }
        return unlocked;
    }

    function _joinedWorkflows(address wallet)
        public
        view
        returns (uint256[] memory)
    {
        return walletWorkflows[wallet];
    }

    function _setStartRelaseTime(uint256 _startTime) public onlyOwner {
        startReleaseTime = _startTime;
    }

    function _setWorkflowRole1(
        address[] memory wallets,
        uint256[] memory lockAmounts,
        uint256[] memory workeflowIds
    ) public onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            address wallet = wallets[i];
            if (lockedAmount[wallet] != lockAmounts[i]) {
                lockedAmount[wallet] = lockAmounts[i];
            }
            if (walletWorkflows[wallet].length > 0) {
                delete walletWorkflows[wallet];
            }
            for (uint256 j = 0; j < workeflowIds.length; j++) {
                require(
                    workflows[workeflowIds[j]].releaseTimes.length > 0,
                    "workflow not exist"
                );

                walletWorkflows[wallet].push(workeflowIds[j]);
            }
        }
    }

    function _mintWithSetRole(
        address[] memory wallets,
        uint256[] memory lockAmounts,
        uint256[] memory workeflowIds
    ) public onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            address wallet = wallets[i];
            if (lockedAmount[wallet] != lockAmounts[i]) {
                lockedAmount[wallet] = lockAmounts[i];
            }
            if (walletWorkflows[wallet].length > 0) {
                delete walletWorkflows[wallet];
            }
            for (uint256 j = 0; j < workeflowIds.length; j++) {
                require(
                    workflows[workeflowIds[j]].releaseTimes.length > 0,
                    "workflow not exist"
                );

                walletWorkflows[wallet].push(workeflowIds[j]);
            }
            mint(wallet, lockAmounts[i]);
        }
    }

    function _setWorkflowRole2(
        address[] memory wallets,
        uint256 lockAmount,
        uint256[] memory workeflowIds
    ) public onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            address wallet = wallets[i];
            if (lockedAmount[wallet] != lockAmount) {
                lockedAmount[wallet] = lockAmount;
            }
            if (walletWorkflows[wallet].length > 0) {
                delete walletWorkflows[wallet];
            }
            for (uint256 j = 0; j < workeflowIds.length; j++) {
                require(
                    workflows[workeflowIds[j]].releaseTimes.length > 0,
                    "workflow not exist"
                );

                walletWorkflows[wallet].push(workeflowIds[j]);
            }
        }
    }

    function _setLock(bool _lock) public onlyOwner {
        lockEnable = _lock;
    }

    function _unlock(address wallet) public onlyOwner {
        lockedAmount[wallet] = 0;
    }

    function _createWorkflow(
        uint256[] memory _releaseTimes,
        uint256 _unlockPoint
    ) public onlyOwner {
        workflows[workflowNonce].unlockPoint = _unlockPoint;
        for (uint256 i = 0; i < _releaseTimes.length; i++) {
            if (i > 0) {
                require(_releaseTimes[i] > _releaseTimes[i - 1]);
            }
            workflows[workflowNonce].releaseTimes.push(_releaseTimes[i]);
            emit CreateTasks(workflowNonce, _releaseTimes[i], _unlockPoint);
        }
        workflowNonce++;
    }

    function _deleteWorkflow(uint256 workflowId) public onlyOwner {
        delete workflows[workflowId];
    }

    function mint(address _to, uint256 _amount)
        public
        onlyOwner
        returns (bool)
    {
        require(totalSupply() + _amount <= maxSupply);
        _mint(_to, _amount);
        return true;
    }

    function checkTaskAndAdvanceTask(address wallet) public {
        if (!lockEnable) {
            return;
        }
        if (startReleaseTime > block.timestamp) {
            return;
        }
        if (walletWorkflows[wallet].length <= 0) {
            return;
        }

        for (uint256 i = 0; i < walletWorkflows[wallet].length; i++) {
            uint256 workeflowId = walletWorkflows[wallet][i];
            uint256 currentWorkflowIndex = workflows[workeflowId].index;

            for (
                uint256 index = workflows[workeflowId].index;
                index < workflows[workeflowId].releaseTimes.length;
                index++
            ) {
                if (
                    index == workflows[workeflowId].releaseTimes.length - 1 ||
                    workflows[workeflowId].releaseTimes[index] > block.timestamp
                ) {
                    currentWorkflowIndex = (index > 0) ? index - 1 : 0;
                    break;
                }
            }
            if (currentWorkflowIndex > workflows[workeflowId].index) {
                workflows[workeflowId].index = currentWorkflowIndex;
            }
        }
        return;
    }
}