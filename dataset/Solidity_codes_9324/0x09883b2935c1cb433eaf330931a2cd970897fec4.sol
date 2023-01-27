
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

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
}// MIT

pragma solidity ^0.6.2;

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
}// MIT

pragma solidity >=0.4.24 <0.7.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity ^0.6.0;


contract ERC20Initializable is Context, Initializable, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initializeERC20(string memory name, string memory symbol) public initializer {

        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    constructor (string memory name, string memory symbol) public {
        initializeERC20(name, symbol);
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

}// MIT

pragma solidity ^0.6.0;


abstract contract ERC20Burnable is Context, ERC20Initializable {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}// MIT

pragma solidity ^0.6.0;


contract OwnableWithAccept is Context, Initializable {
    address private _owner;
    address private _nextOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initializeOwner() public initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    constructor () internal {
        initializeOwner();
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
        _nextOwner = newOwner;
    }

    function acceptOwnership() public virtual {
        require(_msgSender() == _nextOwner, "you are not next owner");
        emit OwnershipTransferred(_owner, _nextOwner);
        _owner = _nextOwner;
        _nextOwner = address(0);
    }

    function getNextOwner() public view returns (address) {
        if (_msgSender() == _nextOwner || _msgSender() == owner()) {
            return _nextOwner;
        }
        return address(0);
    }
}// MIT
pragma solidity ^0.6.0;


contract PaletteToken is OwnableWithAccept, ERC20Burnable {
    enum ProposalStatus { Running, Pass, NotPass }

    struct Proposal {
        address proposer;
        uint256 mintAmount;
        uint256 lockedAmount;
        uint startTime;
        uint depositEndTime;
        uint votingEndTime;
        ProposalStatus status;
        string desc;
    }

    uint public proposalID;
    address public lockProxy;
    bytes public receiver;
    uint64 public ccID;
    bool public isFreezed;
    uint public duration;
    uint public durationLimit;
   
    mapping(uint => mapping(address=>uint256)) public stakeTable;
    mapping(uint => uint256) public stakeCounter;
    mapping(uint => mapping(address => uint256)) public voteBox;
    mapping(uint => uint256) public voteCounter;
    mapping(uint => Proposal) public proposals;
    mapping(address => uint[]) internal whoseProposals;
    mapping(address => uint[]) internal deposited;
    mapping(address => mapping(uint => uint)) depositedIndex;

    event Vote(address indexed voter, uint indexed proposalID, uint256 amount);
    event CancelVote(address indexed voter, uint indexed proposalID, uint256 amount);
    event ProposalPass(uint indexed proposalID, uint256 value);
    event ProposalFail(uint indexed proposalID, uint256 totalVote , uint256 limitToPass);
    event ProposalMake(uint indexed proposalID, address indexed sender, uint256 mintAmount, uint startTime, uint depositEndTime, uint votingEndTime, uint256 lockedAmount, string desc);
    event Deposit(address indexed from, uint indexed proposalID, uint256 amount);
    event Withdraw(address indexed from, uint indexed proposalID, uint256 amount);

    modifier whenNotFreezed() {
        require(!isFreezed, "you can not call this func when contract is freezed");
        _;
    }

    modifier whenFreezed() {
        require(isFreezed, "you can only call this func when contract is freezed");
        _;
    }

    function initialize() public initializer {
        initializeOwner();
        initializeERC20("Palette Token", "PLT");
        _mint(_msgSender(), 1000000000 * 10 ** uint256(decimals()));
        isFreezed = true;
        duration = 2 weeks;
        proposalID = 1;
        durationLimit = 1 days;
    }

    constructor() public ERC20Initializable("Palette Token", "PLT") {
        initialize();
    }

    function setLockProxy(address newLockProxy) public onlyOwner whenFreezed {
        lockProxy = newLockProxy;
    }

    function setPaletteReceiver(bytes memory newReceiver) public onlyOwner whenFreezed {
        receiver = newReceiver;
    }

    function setCrossChainID(uint64 chainID) public onlyOwner whenFreezed {
        ccID = chainID;
    }

    function freeze() public onlyOwner whenNotFreezed {
        isFreezed = true;
    }

    function unFreeze() public onlyOwner whenFreezed {
        require(lockProxy != address(0), "lock proxy is not set");
        require(receiver.length > 0, "palette operator is not set");
        require(ccID > 0, "palette chain id is zero");
        isFreezed = false;
    }

    function setDuration(uint _duration) public onlyOwner {
        require(_duration >= durationLimit, "at least one day");
        duration = _duration;
    }

    function setDurationLimit(uint limit) public onlyOwner {
        durationLimit = limit;
    }

    function acceptOwnership() override public {
        address nextOwner = getNextOwner();
        require(nextOwner != address(0), "get zero next owner");
        require(_msgSender() == nextOwner, "you are not next owner");
        
        address old = owner();
        uint256 bal = balanceOf(old);
        _transfer(old, nextOwner, bal);
        super.acceptOwnership();

        uint[] memory ids = deposited[old];
        uint len = ids.length;
        if (len > 0) {
            for (uint index = 0; index < len; index++) {
                uint k = ids[index];
                if (depositedIndex[nextOwner][k] == 0) {
                    deposited[nextOwner].push(k);
                    depositedIndex[nextOwner][k] = deposited[nextOwner].length;
                }
                stakeTable[k][nextOwner] = stakeTable[k][old];
                voteBox[k][nextOwner] = voteBox[k][old];
                delete stakeTable[k][old];
                delete voteBox[k][old];
                delete depositedIndex[old][k];
            }
            delete deposited[old];
        }

        ids = getHisProposals(old);
        if (ids.length > 0) {
            for (uint index = 0; index < ids.length; index++) {
                proposals[ids[index]].proposer = nextOwner;
                whoseProposals[nextOwner].push(ids[index]);
            }
            delete whoseProposals[old];
        }
    }

    function makeProposal(uint256 mintAmount, string memory desc, uint startTime) public whenNotFreezed returns (uint256) {
        require(bytes(desc).length <= 128, "length of description must be less than 128");
        uint256 deposit = totalSupply().div(100);
        uint256 bal = balanceOf(_msgSender());
        require(bal >= deposit, "you need to lock one percent PLT of total supply to create a proposal which you don't have.");
        require(mintAmount > 0, "mintAmount must be greater than 0");

        if (startTime < now) {
            startTime = now;
        }

        Proposal memory p;
        p.mintAmount = mintAmount;
        p.startTime = startTime;
        p.depositEndTime = startTime + duration;
        p.votingEndTime = startTime + 2 * duration;
        p.desc = desc;
        p.status = ProposalStatus.Running;
        p.proposer = _msgSender();
        p.lockedAmount = deposit;

        proposals[proposalID] = p;
        whoseProposals[_msgSender()].push(proposalID);
        require(transfer(address(this), deposit), "failed to lock your PLT to contract");
        emit ProposalMake(proposalID, _msgSender(), mintAmount, startTime, p.depositEndTime, p.votingEndTime, p.lockedAmount, desc);
        proposalID++;

        return proposalID - 1;
    }

    function deposit(uint id, uint256 amount) public whenNotFreezed {
        require(amount > 0, "amount must bigger than zero");
        require(proposalID > id, "this proposal is not exist!");
        
        Proposal memory p = proposals[id];
        require(p.startTime <= now, "this proposal is not start yet");
        require(p.depositEndTime > now, "this proposal is out of stake duration");

        uint256 bal = balanceOf(_msgSender());
        require(bal >= amount, "your PLT is not enough to lock");

        require(transfer(address(this), amount), "failed to lock your PLT to contract");
        stakeTable[id][_msgSender()] = stakeTable[id][_msgSender()].add(amount);
        stakeCounter[id] = stakeCounter[id].add(amount);
        if (depositedIndex[_msgSender()][id] == 0) {
            deposited[_msgSender()].push(id);
            depositedIndex[_msgSender()][id] = deposited[_msgSender()].length;
        }

        emit Deposit(_msgSender(), id, amount);
    }

    function vote(uint id, uint256 amount) public whenNotFreezed {
        require(proposalID > id, "this proposal is not exist!");
        require(amount > 0, "amount must bigger than zero");
        require(stakeCounter[id] > totalSupply().div(10), "no need to vote because of the locked amount is less than 10% PLT");

        Proposal memory p = proposals[id];
        require(now >= p.depositEndTime, "this proposal is not start yet");
        require(now < p.votingEndTime, "this proposal is already out of vote duration");
        require(stakeTable[id][_msgSender()] >= amount, "you locked stake is not enough to vote in this amount");

        voteBox[id][_msgSender()] = voteBox[id][_msgSender()].add(amount);
        voteCounter[id] = voteCounter[id].add(amount);
        stakeTable[id][_msgSender()] = stakeTable[id][_msgSender()].sub(amount);

        emit Vote(_msgSender(), id, amount);
    }

    function cancelVote(uint id, uint256 amount) public whenNotFreezed {
        require(proposalID > id, "this proposal is not exist!");
        Proposal memory p = proposals[id];
        require(now >= p.depositEndTime, "vote of this proposal is not start yet");
        require(now < p.votingEndTime, "this proposal is already out of vote duration");
        require(voteBox[id][_msgSender()] >= amount, "you voted stake is not enough for this amount");

        voteBox[id][_msgSender()] = voteBox[id][_msgSender()].sub(amount);
        voteCounter[id] = voteCounter[id].sub(amount);
        stakeTable[id][_msgSender()] = stakeTable[id][_msgSender()].add(amount);

        emit CancelVote(_msgSender(), id, amount);
    }

    function excuteProposal(uint id) public whenNotFreezed {
        require(proposalID > id, "this proposal is not exist!");
        require(lockProxy != address(0), "lock proxy is zero address");
        require(ccID != 0, "cross chain ID of Palette Chain is zero");
        require(receiver.length > 0, "palette operator is zero address");

        Proposal memory p = proposals[id];
        require(p.votingEndTime < now, "it's still in voting");
        require(p.status == ProposalStatus.Running, "proposal is not running");
       
        _transfer(address(this), p.proposer, p.lockedAmount);
        uint256 limit = stakeCounter[id].mul(2).div(3) + 1;
        if (voteCounter[id] < limit || stakeCounter[id] < totalSupply().div(10)) {
            proposals[id].status = ProposalStatus.NotPass;
            emit ProposalFail(id, voteCounter[id], limit);
            return;
        }

        proposals[id].status = ProposalStatus.Pass;
        
        _mint(address(this), p.mintAmount);
        emit ProposalPass(id, p.mintAmount);
        
        delete voteCounter[id];
        delete stakeCounter[id];

        _approve(address(this), lockProxy, p.mintAmount);

        bool ok;
        bytes memory res;
        bytes memory checkAsset = abi.encodeWithSignature("assetHashMap(address,uint64)", address(this), ccID);
        (ok, res) = lockProxy.call(checkAsset);
        require(ok, "failed to call assetHashMap()");
        require(res.length > 64, "no asset binded for PLT");

        bytes memory lock = abi.encodeWithSignature("lock(address,uint64,bytes,uint256)", address(this), ccID, receiver, p.mintAmount);
        (ok, ) = lockProxy.call(lock);
        require(ok, "failed to call lock() of lock proxy contract");
    } 

    function withdraw(uint id) public whenNotFreezed { 
        require(proposalID > id, "this proposal is not exist!");
        Proposal memory p = proposals[id];
        require(p.status != ProposalStatus.Running, "you can not unlock your stake until proposal is excuted. ");
        require(p.votingEndTime < now, "it's still in voting");

        uint256 amt = stakeTable[id][_msgSender()].add(voteBox[id][_msgSender()]);
        require(amt > 0, "you have no stake for this proposal");

        _transfer(address(this), _msgSender(), amt);
        delete stakeTable[id][_msgSender()];
        delete voteBox[id][_msgSender()];
        
        uint idx = depositedIndex[_msgSender()][id] - 1;
        uint last = deposited[_msgSender()].length - 1;
        uint lastID = deposited[_msgSender()][last];
        deposited[_msgSender()][idx] = lastID;
        deposited[_msgSender()].pop();
        depositedIndex[_msgSender()][lastID] = idx;
        delete depositedIndex[_msgSender()][id];

        emit Withdraw(_msgSender(), id, amt);
    }

    function isGoodToVote(uint id) public view returns (bool) {
        if (proposalID <= id) {
            return false;
        }
        Proposal memory p = proposals[id];
        return p.votingEndTime > now && p.depositEndTime <= now;
    }

    function isGoodToDeposit(uint id) public view returns (bool) {
        if (proposalID <= id) {
            return false;
        }
        Proposal memory p = proposals[id];
        return p.depositEndTime > now && p.startTime <= now;
    }

    function myTotalStake(uint id) public view returns (uint256) {
        return stakeTable[id][_msgSender()].add(voteBox[id][_msgSender()]);
    }

    function getHisProposals(address he) public view returns (uint[] memory) {
        return whoseProposals[he];
    }

    function getHisDepositedID(address he) public view returns (uint[] memory) {
        return deposited[he];
    }
}