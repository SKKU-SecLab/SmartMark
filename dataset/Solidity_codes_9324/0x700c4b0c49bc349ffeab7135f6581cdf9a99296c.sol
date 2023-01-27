
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// GPL-3.0
pragma solidity 0.8.4;

interface ICVNXGovernance {
    enum PollType {PROPOSAL, EXECUTIVE, EVENT, PRIVATE}
    enum PollStatus {PENDING, APPROVED, REJECTED, DRAW}
    enum VoteType {FOR, AGAINST}

    struct Poll {
        uint64 pollDeadline;
        uint64 pollStopped;
        PollType pollType;
        address pollOwner;
        string pollInfo;
        uint256 forWeight;
        uint256 againstWeight;
    }

    struct Vote {
        VoteType voteType;
        uint256 voteWeight;
    }

    function getIsAvailableToCreate() external view returns (bool);

    function setIsAvailableToCreate() external;

    function createProposalPoll(uint64 _pollDeadline, string memory _pollInfo) external;

    function createExecutivePoll(uint64 _pollDeadline, string memory _pollInfo) external;

    function createEventPoll(uint64 _pollDeadline, string memory _pollInfo) external;

    function createPrivatePoll(
        uint64 _pollDeadline,
        string memory _pollInfo,
        address[] memory _verifiedAddresses
    ) external;

    function vote(
        uint256 _pollNum,
        VoteType _voteType,
        uint256 _voteWeight
    ) external;

    function unlockTokensInPoll(uint256 _pollNum) external;

    function stopPoll(uint256 _pollNum) external;

    function getPollStatus(uint256 _pollNum) external view returns (uint256, PollStatus);

    function getPollExpirationTime(uint256 _pollNum) external view returns (uint64);

    function getPollStopTime(uint256 _pollNum) external view returns (uint64);

    function getPollHistory(address _voter) external view returns (bool[] memory);

    function getPollInfoForVoter(uint256 _pollNum, address _voter) external view returns (Vote memory);

    function getIfUserHasVoted(uint256 _pollNum, address _voter) external view returns (bool);

    function getLockedAmount(address _voter) external view returns (uint256);

    function getPollLockedAmount(uint256 _pollNum, address _voter) external view returns (uint256);
}// GPL-3.0
pragma solidity 0.8.4;


interface ICVNX is IERC20 {
    function mint(address _account, uint256 _amount) external;

    function lock(address _tokenOwner, uint256 _tokenAmount) external;

    function unlock(address _tokenOwner, uint256 _tokenAmount) external;

    function swap(uint256 _amount) external returns (bool);

    function transferStuckERC20(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external;

    function setCvnxGovernanceContract(address _address) external;

    function setLimit(uint256 _percent, uint256 _limitAmount, uint256 _period) external;

    function addFromWhitelist(address _newAddress) external;

    function removeFromWhitelist(address _oldAddress) external;

    function addToWhitelist(address _newAddress) external;

    function removeToWhitelist(address _oldAddress) external;

    function changeLimitActivityStatus() external;
}// GPL-3.0
pragma solidity 0.8.4;


contract CVNX is ICVNX, ERC20("CVNX", "CVNX"), Ownable {
    event TokenLocked(uint256 indexed amount, address tokenOwner);
    event TokenUnlocked(uint256 indexed amount, address tokenOwner);

    ICVNXGovernance public cvnxGovernanceContract;
    IERC20Metadata public cvnContract;

    struct Limit {
        uint256 percent;
        uint256 limitAmount;
        uint256 period;
    }

    Limit public limit;
    bool public isLimitsActive;
    mapping(address => uint256) public addressToEndLockTimestamp;
    mapping(address => bool) public fromLimitWhitelist;
    mapping(address => bool) public toLimitWhitelist;

    mapping(address => uint256) public lockedAmount;

    constructor(address _cvnContract) {
        uint256 _toMint = 15000000000000000000000000;

        _mint(msg.sender, _toMint);
        approve(address(this), _toMint);

        cvnContract = IERC20Metadata(_cvnContract);
    }

    modifier onlyGovContract() {
        require(msg.sender == address(cvnxGovernanceContract), "[E-31] - Not a governance contract.");
        _;
    }

    function lock(address _tokenOwner, uint256 _tokenAmount) external override onlyGovContract {
        require(_tokenAmount > 0, "[E-41] - The amount to be locked must be greater than zero.");

        uint256 _balance = balanceOf(_tokenOwner);
        uint256 _toLock = lockedAmount[_tokenOwner] + _tokenAmount;

        require(_toLock <= _balance, "[E-42] - Not enough token on account.");
        lockedAmount[_tokenOwner] = _toLock;

        emit TokenLocked(_tokenAmount, _tokenOwner);
    }

    function unlock(address _tokenOwner, uint256 _tokenAmount) external override onlyGovContract {
        uint256 _lockedAmount = lockedAmount[_tokenOwner];

        if (_tokenAmount > _lockedAmount) {
            _tokenAmount = _lockedAmount;
        }

        lockedAmount[_tokenOwner] = _lockedAmount - _tokenAmount;

        emit TokenUnlocked(_tokenAmount, _tokenOwner);
    }

    function swap(uint256 _amount) external override returns (bool) {
        cvnContract.transferFrom(msg.sender, 0x4e07dc9D1aBCf1335d1EaF4B2e28b45d5892758E, _amount);

        uint256 _newAmount = _amount * (10 ** (decimals() - cvnContract.decimals()));
        this.transferFrom(owner(), msg.sender, _newAmount);
        return true;
    }

    function transferStuckERC20(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external override onlyOwner {
        require(_token.transfer(_to, _amount), "[E-56] - Transfer failed.");
    }

    function setCvnxGovernanceContract(address _address) external override onlyOwner {
        if (address(cvnxGovernanceContract) != address(0)) {
            require(!cvnxGovernanceContract.getIsAvailableToCreate(), "[E-92] - Old governance contract still active.");
        }

        cvnxGovernanceContract = ICVNXGovernance(_address);
    }

    function mint(address _account, uint256 _amount) external override onlyOwner {
        require(totalSupply() + _amount <= 60000000000000000000000000, "[E-71] - Can't mint more.");
        _mint(_account, _amount);
    }

    function setLimit(uint256 _percent, uint256 _limitAmount, uint256 _period) external override onlyOwner {
        require(_percent <= getDecimals(), "[E-89] - Percent should be less than 1.");
        require(_percent > 0, "[E-90] - Percent can't be a zero.");
        require(_limitAmount > 0, "[E-90] - Limit amount can't be a zero.");

        limit.percent = _percent;
        limit.limitAmount = _limitAmount;
        limit.period = _period;
    }

    function addFromWhitelist(address _newAddress) external override onlyOwner {
        fromLimitWhitelist[_newAddress] = true;
    }

    function removeFromWhitelist(address _oldAddress) external override onlyOwner {
        fromLimitWhitelist[_oldAddress] = false;
    }

    function addToWhitelist(address _newAddress) external override onlyOwner {
        toLimitWhitelist[_newAddress] = true;
    }

    function removeToWhitelist(address _oldAddress) external override onlyOwner {
        toLimitWhitelist[_oldAddress] = false;
    }

    function changeLimitActivityStatus() external override onlyOwner {
        isLimitsActive = !isLimitsActive;
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override {
        if (_from != address(0)) {
            uint256 _availableAmount = balanceOf(_from) - lockedAmount[_from];
            require(_availableAmount >= _amount, "[E-61] - Transfer amount exceeds available tokens.");

            if (isLimitsActive && fromLimitWhitelist[_from] == false && toLimitWhitelist[_to] == false) {
                require(block.timestamp > addressToEndLockTimestamp[_from], "[E-62] - Tokens are locked until the end of the period.");
                require(_amount <= limit.limitAmount, "[E-63] - The maximum limit has been reached.");
                require(_amount <= _availableAmount * limit.percent / getDecimals(), "[E-64] - The maximum limit has been reached.");

                addressToEndLockTimestamp[_from] = block.timestamp + limit.period;
            }
        }
    }

    function getDecimals() private pure returns (uint256) {
        return 10 ** 27;
    }
}// GPL-3.0
pragma solidity 0.8.4;


contract CVNXGovernance is ICVNXGovernance, Ownable {
    CVNX private cvnx;

    event PollCreated(uint256 indexed pollNum);

    event PollVoted(address voterAddress, VoteType indexed voteType, uint256 indexed voteWeight);

    event PollStop(uint256 indexed pollNum, uint256 indexed stopTimestamp);

    Poll[] public polls;

    mapping(uint256 => mapping(address => Vote)) public voted;

    mapping(uint256 => mapping(address => bool)) public isTokenLockedInPoll;

    mapping(uint256 => mapping(address => bool)) public verifiedToVote;

    bool private isAvailableToCreate = true;

    constructor(address _cvnxTokenAddress) {
        cvnx = CVNX(_cvnxTokenAddress);
    }

    function getIsAvailableToCreate() external view override returns (bool) {
        return isAvailableToCreate;
    }

    function setIsAvailableToCreate() external override onlyOwner() {
        isAvailableToCreate = !isAvailableToCreate;
    }

    modifier onlyWithBalanceNoLess(uint256 _minimalBalance) {
        require(cvnx.balanceOf(msg.sender) > _minimalBalance, "[E-34] - Your balance is too low.");
        _;
    }

    function createProposalPoll(uint64 _pollDeadline, string memory _pollInfo) external override {
        _createPoll(PollType.PROPOSAL, _pollDeadline, _pollInfo);
    }

    function createExecutivePoll(uint64 _pollDeadline, string memory _pollInfo) external override onlyOwner {
        _createPoll(PollType.EXECUTIVE, _pollDeadline, _pollInfo);
    }

    function createEventPoll(uint64 _pollDeadline, string memory _pollInfo) external override onlyOwner {
        _createPoll(PollType.EVENT, _pollDeadline, _pollInfo);
    }

    function createPrivatePoll(
        uint64 _pollDeadline,
        string memory _pollInfo,
        address[] memory _verifiedAddresses
    ) external override onlyOwner {
        uint256 _verifiedAddressesCount = _verifiedAddresses.length;
        require(_verifiedAddressesCount > 1, "[E-35] - Verified addresses not set.");

        uint256 _pollNum = _createPoll(PollType.PRIVATE, _pollDeadline, _pollInfo);

        for (uint256 i = 0; i < _verifiedAddressesCount; i++) {
            verifiedToVote[_pollNum][_verifiedAddresses[i]] = true;
        }
    }

    function vote(
        uint256 _pollNum,
        VoteType _voteType,
        uint256 _voteWeight
    ) external override onlyWithBalanceNoLess(10000000000000000000) {
        require(polls[_pollNum].pollStopped > block.timestamp, "[E-37] - Poll ended.");

        if (polls[_pollNum].pollType == PollType.PRIVATE) {
            require(verifiedToVote[_pollNum][msg.sender] == true, "[E-38] - You are not verify to vote in this poll.");
        }

        cvnx.lock(msg.sender, _voteWeight);
        isTokenLockedInPoll[_pollNum][msg.sender] = true;

        uint256 _voterVoteWeightBefore = voted[_pollNum][msg.sender].voteWeight;

        if (_voterVoteWeightBefore > 0) {
            require(
                voted[_pollNum][msg.sender].voteType == _voteType,
                "[E-39] - The voice type does not match the first one."
            );
        } else {
            voted[_pollNum][msg.sender].voteType = _voteType;
        }

        voted[_pollNum][msg.sender].voteWeight = _voterVoteWeightBefore + _voteWeight;

        if (_voteType == VoteType.FOR) {
            polls[_pollNum].forWeight += _voteWeight;
        } else {
            polls[_pollNum].againstWeight += _voteWeight;
        }

        emit PollVoted(msg.sender, _voteType, _voteWeight);
    }

    function unlockTokensInPoll(uint256 _pollNum) external override {
        require(polls[_pollNum].pollStopped <= block.timestamp, "[E-81] - Poll is not ended.");
        require(isTokenLockedInPoll[_pollNum][msg.sender] == true, "[E-82] - Tokens not locked for this poll.");

        isTokenLockedInPoll[_pollNum][msg.sender] = false;

        cvnx.unlock(msg.sender, voted[_pollNum][msg.sender].voteWeight);
    }

    function stopPoll(uint256 _pollNum) external override {
        require(
            owner() == msg.sender || polls[_pollNum].pollOwner == msg.sender,
            "[E-91] - Not a contract or poll owner."
        );
        require(block.timestamp < polls[_pollNum].pollDeadline, "[E-92] - Poll ended.");

        polls[_pollNum].pollStopped = uint64(block.timestamp);

        emit PollStop(_pollNum, block.timestamp);
    }

    function getPollStatus(uint256 _pollNum) external view override returns (uint256, PollStatus) {
        if (polls[_pollNum].pollStopped > block.timestamp) {
            return (_pollNum, PollStatus.PENDING);
        }

        uint256 _forWeight = polls[_pollNum].forWeight;
        uint256 _againstWeight = polls[_pollNum].againstWeight;

        if (_forWeight > _againstWeight) {
            return (_pollNum, PollStatus.APPROVED);
        } else if (_forWeight < _againstWeight) {
            return (_pollNum, PollStatus.REJECTED);
        } else {
            return (_pollNum, PollStatus.DRAW);
        }
    }

    function getPollExpirationTime(uint256 _pollNum) external view override returns (uint64) {
        return polls[_pollNum].pollDeadline;
    }

    function getPollStopTime(uint256 _pollNum) external view override returns (uint64) {
        return polls[_pollNum].pollStopped;
    }

    function getPollHistory(address _voter) external view override returns (bool[] memory) {
        uint256 _pollsCount = polls.length;
        bool[] memory _pollNums = new bool[](_pollsCount);

        for (uint256 i = 0; i < _pollsCount; i++) {
            if (voted[i][_voter].voteWeight > 0) {
                _pollNums[i] = true;
            }
        }

        return _pollNums;
    }

    function getPollInfoForVoter(uint256 _pollNum, address _voter) external view override returns (Vote memory) {
        return voted[_pollNum][_voter];
    }

    function getIfUserHasVoted(uint256 _pollNum, address _voter) external view override returns (bool) {
        return voted[_pollNum][_voter].voteWeight > 0;
    }

    function getLockedAmount(address _voter) external view override returns (uint256) {
        return cvnx.lockedAmount(_voter);
    }

    function getPollLockedAmount(uint256 _pollNum, address _voter) external view override returns (uint256) {
        if (isTokenLockedInPoll[_pollNum][_voter]) {
            return voted[_pollNum][_voter].voteWeight;
        } else {
            return 0;
        }
    }

    function _createPoll(
        PollType _pollType,
        uint64 _pollDeadline,
        string memory _pollInfo
    ) private onlyWithBalanceNoLess(0) returns (uint256) {
        require(_pollDeadline > block.timestamp, "[E-41] - The deadline must be longer than the current time.");
        require(isAvailableToCreate, "[E-42] - Possibility to create new poll is disabled.");

        Poll memory _poll = Poll(_pollDeadline, _pollDeadline, _pollType, msg.sender, _pollInfo, 0, 0);

        uint256 _pollNum = polls.length;
        polls.push(_poll);

        emit PollCreated(_pollNum);

        return _pollNum;
    }
}