

pragma solidity 0.6.12;

contract safeMathModule {

    uint256 constant one = 1 ether;

    function expDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return safeDiv( safeMul(a, one), b);
    }
    function expMul(uint256 a, uint256 b) internal pure returns (uint256) {

        return safeDiv( safeMul(a, b), one);
    }
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addtion overflow");
        return c;
    }
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(a >= b, "SafeMath: subtraction overflow");
        return a - b;
    }
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {

        if(a == 0) { return 0;}
        uint256 c = a * b;
        require( (c/a) == b, "SafeMath: multiplication overflow");
        return c;
    }
    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return (a/b);
    }
}


pragma solidity 0.6.12;

contract ERC20 {

    string symbol;
    string name;
    uint8 decimals = 18;
    uint256 public totalSupply = 1000 * 1e9 * 1e18; // token amount: 1000 Bilions

    address public owner;

    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    modifier onlyOwner() {

        require(msg.sender == owner, "only owner");
        _;
    }

    event Transfer(address, address, uint256);
    event Approval(address, address, uint256);

    constructor (string memory _name, string memory _symbol) public {

        owner = msg.sender;

        name = _name;
        symbol = _symbol;
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {


        require(balances[msg.sender] >= _amount, "insuficient sender's balance");
        require(_amount > 0, "requested amount must be positive");
        require(balances[_to] + _amount > balances[_to], "receiver's balance overflows");

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to,uint256 _amount) public returns (bool success) {


        require(balances[_from] >= _amount, "insuficient sender's balance");
        require(allowed[_from][msg.sender] >= _amount, "not allowed transfer");
        require(_amount > 0, "requested amount must be positive");
        require(balances[_to] + _amount > balances[_to], "receiver's balance overflows");

        balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(_from, _to, _amount);

        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }
}

contract BFCtoken is ERC20 {

    constructor() public ERC20 ("Bifrost", "BFC") {}
}

contract LPtoken is ERC20 {

    constructor() public ERC20 ("BFC-ETH", "LP") {}
}

contract BiFitoken is ERC20 {

    constructor() public ERC20 ("BiFi", "BiFi") {}
}


pragma solidity 0.6.12;


contract storageModule {

    address public owner;
    address public pendingOwner;

    bool public claimLock;
    bool public withdrawLock;

    uint256 public rewardPerBlock;
    uint256 public decrementUnitPerBlock;
    uint256 public rewardLane;

    uint256 public lastBlockNum;
    uint256 public totalDeposited;

    ERC20 public lpErc; ERC20 public rewardErc;

    mapping(address => Account) public accounts;

    uint256 public passedPoint;
    RewardVelocityPoint[] public registeredPoints;

    struct Account {
        uint256 deposited;
        uint256 pointOnLane;
        uint256 rewardAmount;
    }

    struct RewardVelocityPoint {
        uint256 blockNumber;
        uint256 rewardPerBlock;
        uint256 decrementUnitPerBlock;
    }

    struct UpdateRewardLaneModel {
        uint256 len; uint256 tmpBlockDelta;

        uint256 memPassedPoint; uint256 tmpPassedPoint;

        uint256 memThisBlockNum;
        uint256 memLastBlockNum; uint256 tmpLastBlockNum;

        uint256 memTotalDeposit;

        uint256 memRewardLane; uint256 tmpRewardLane;
        uint256 memRewardPerBlock; uint256 tmpRewardPerBlock;

        uint256 memDecrementUnitPerBlock; uint256 tmpDecrementUnitPerBlock;
    }
}


pragma solidity 0.6.12;

contract eventModule {

    event Deposit(address userAddr, uint256 amount, uint256 userDeposit, uint256 totalDeposit);
    event Withdraw(address userAddr, uint256 amount, uint256 userDeposit, uint256 totalDeposit);
    event Claim(address userAddr, uint256 amount);
    event UpdateRewardParams(uint256 atBlockNumber, uint256 rewardPerBlock, uint256 decrementUnitPerBlock);


    event ClaimLock(bool lock);
    event WithdrawLock(bool lock);
    event OwnershipTransfer(address from, address to);

    event SetRewardParams(uint256 rewardPerBlock, uint256 decrementUnitPerBlock);
    event RegisterRewardParams(uint256 atBlockNumber, uint256 rewardPerBlock, uint256 decrementUnitPerBlock);
    event DeleteRegisterRewardParams(uint256 index, uint256 atBlockNumber, uint256 rewardPerBlock, uint256 decrementUnitPerBlock, uint256 arrayLen);
}


pragma solidity 0.6.12;




contract internalModule is storageModule, eventModule, safeMathModule {

    function _deposit(address userAddr, uint256 amount) internal {

        Account memory user = accounts[userAddr];
        uint256 totalDeposit = totalDeposited;

        user.deposited = safeAdd(user.deposited, amount);
        accounts[userAddr].deposited = user.deposited;
        totalDeposit = safeAdd(totalDeposited, amount);
        totalDeposited = totalDeposit;

        if(amount > 0) {
            emit Deposit(userAddr, amount, user.deposited, totalDeposit);
            require( lpErc.transferFrom(msg.sender, address(this), amount), "token error" );
        }
    }

    function _withdraw(address userAddr, uint256 amount) internal {

        Account memory user = accounts[userAddr];
        uint256 totalDeposit = totalDeposited;
        require(user.deposited >= amount, "not enough user Deposit");

        user.deposited = safeSub(user.deposited, amount);
        accounts[userAddr].deposited = user.deposited;
        totalDeposit = safeSub(totalDeposited, amount);
        totalDeposited = totalDeposit;

        if(amount > 0) {
            emit Withdraw(userAddr, amount, user.deposited, totalDeposit);
            require( lpErc.transfer(userAddr, amount), "token error" );
        }
    }

    function _redeemAll(address userAddr) internal {

        Account memory user = accounts[userAddr];

        uint256 newRewardLane = _updateRewardLane();

        uint256 distance = safeSub(newRewardLane, user.pointOnLane);
        uint256 rewardAmount = expMul(user.deposited, distance);

        if(user.pointOnLane != newRewardLane) accounts[userAddr].pointOnLane = newRewardLane;
        if(rewardAmount != 0) accounts[userAddr].rewardAmount = safeAdd(user.rewardAmount, rewardAmount);
    }

    function _rewardClaim(address userAddr) internal {

        Account memory user = accounts[userAddr];

        if(user.rewardAmount != 0) {
            uint256 amount = user.rewardAmount;
            accounts[userAddr].rewardAmount = 0;

            emit Claim(userAddr, amount);
            require(rewardErc.transfer(userAddr, amount), "token error" );
        }
    }

    function _updateRewardLane() internal returns (uint256) {

        UpdateRewardLaneModel memory vars;

        vars.len = registeredPoints.length;
        vars.memTotalDeposit = totalDeposited;

        vars.tmpPassedPoint = vars.memPassedPoint = passedPoint;

        vars.memThisBlockNum = block.number;
        vars.tmpLastBlockNum = vars.memLastBlockNum = lastBlockNum;

        vars.tmpRewardLane = vars.memRewardLane = rewardLane;
        vars.tmpRewardPerBlock = vars.memRewardPerBlock = rewardPerBlock;
        vars.tmpDecrementUnitPerBlock = vars.memDecrementUnitPerBlock = decrementUnitPerBlock;

        for(uint256 i=vars.memPassedPoint; i<vars.len; i++) {
            RewardVelocityPoint memory point = registeredPoints[i];

            if(vars.tmpLastBlockNum < point.blockNumber && point.blockNumber <= vars.memThisBlockNum) {
                vars.tmpPassedPoint = i+1;
                vars.tmpBlockDelta = safeSub(point.blockNumber, vars.tmpLastBlockNum);
                (vars.tmpRewardLane, vars.tmpRewardPerBlock) =
                _calcNewRewardLane(
                    vars.tmpRewardLane,
                    vars.memTotalDeposit,
                    vars.tmpRewardPerBlock,
                    vars.tmpDecrementUnitPerBlock,
                    vars.tmpBlockDelta);

                vars.tmpLastBlockNum = point.blockNumber;
                vars.tmpRewardPerBlock = point.rewardPerBlock;
                vars.tmpDecrementUnitPerBlock = point.decrementUnitPerBlock;
                emit UpdateRewardParams(point.blockNumber, point.rewardPerBlock, point.decrementUnitPerBlock);
            } else {
                break;
            }
        }

        if( vars.tmpLastBlockNum < vars.memThisBlockNum ) {
            vars.tmpBlockDelta = safeSub(vars.memThisBlockNum, vars.tmpLastBlockNum);
            vars.tmpLastBlockNum = vars.memThisBlockNum;
            (vars.tmpRewardLane, vars.tmpRewardPerBlock) =
            _calcNewRewardLane(
                vars.tmpRewardLane,
                vars.memTotalDeposit,
                vars.tmpRewardPerBlock,
                vars.tmpDecrementUnitPerBlock,
                vars.tmpBlockDelta);
        }

        if(vars.memLastBlockNum != vars.tmpLastBlockNum) lastBlockNum = vars.tmpLastBlockNum;
        if(vars.memPassedPoint != vars.tmpPassedPoint) passedPoint = vars.tmpPassedPoint;
        if(vars.memRewardLane != vars.tmpRewardLane) rewardLane = vars.tmpRewardLane;
        if(vars.memRewardPerBlock != vars.tmpRewardPerBlock) rewardPerBlock = vars.tmpRewardPerBlock;
        if(vars.memDecrementUnitPerBlock != vars.tmpDecrementUnitPerBlock) decrementUnitPerBlock = vars.tmpDecrementUnitPerBlock;

        return vars.tmpRewardLane;
    }

    function _calcNewRewardLane(
        uint256 _rewardLane,
        uint256 _totalDeposit,
        uint256 _rewardPerBlock,
        uint256 _decrementUnitPerBlock,
        uint256 delta) internal pure returns (uint256, uint256) {

            uint256 executableDelta;
            if(_decrementUnitPerBlock != 0) {
                executableDelta = safeDiv(_rewardPerBlock, _decrementUnitPerBlock);
                if(delta > executableDelta) delta = executableDelta;
                else executableDelta = 0;
            }

            uint256 distance;
            if(_totalDeposit != 0) {
                distance = expMul( _sequencePartialSumAverage(_rewardPerBlock, delta, _decrementUnitPerBlock), safeMul( expDiv(one, _totalDeposit), delta) );
                _rewardLane = safeAdd(_rewardLane, distance);
            }

            if(executableDelta != 0) _rewardPerBlock = 0;
            else _rewardPerBlock = _getNewRewardPerBlock(_rewardPerBlock, _decrementUnitPerBlock, delta);

            return (_rewardLane, _rewardPerBlock);
    }

    function _registerRewardVelocity(uint256 _blockNumber, uint256 _rewardPerBlock, uint256 _decrementUnitPerBlock) internal {

        RewardVelocityPoint memory varPoint = RewardVelocityPoint(_blockNumber, _rewardPerBlock, _decrementUnitPerBlock);
        emit RegisterRewardParams(_blockNumber, _rewardPerBlock, _decrementUnitPerBlock);
        registeredPoints.push(varPoint);
    }

    function _deleteRegisteredRewardVelocity(uint256 _index) internal {

        uint256 len = registeredPoints.length;
        require(len != 0 && _index < len, "error: no elements in registeredPoints");

        RewardVelocityPoint memory point = registeredPoints[_index];
        emit DeleteRegisterRewardParams(_index, point.blockNumber, point.rewardPerBlock, point.decrementUnitPerBlock, len-1);
        for(uint256 i=_index; i<len-1; i++) {
            registeredPoints[i] = registeredPoints[i+1];
        }
        registeredPoints.pop();
     }

    function _setParams(uint256 _rewardPerBlock, uint256 _decrementUnitPerBlock) internal {

        emit SetRewardParams(_rewardPerBlock, _decrementUnitPerBlock);
        rewardPerBlock = _rewardPerBlock;
        decrementUnitPerBlock = _decrementUnitPerBlock;
    }

    function _sequencePartialSumAverage(uint256 a, uint256 n, uint256 d) internal pure returns (uint256) {

        if (n > 0)
            return safeDiv(safeSub( safeMul(2,a), safeMul( safeSub(n,1), d) ), 2);
        else
            return 0;
    }

    function _getNewRewardPerBlock(uint256 before, uint256 dec, uint256 delta) internal pure returns (uint256) {

        return safeSub(before, safeMul(dec, delta));
    }

    function _setClaimLock(bool lock) internal {

        emit ClaimLock(lock);
        claimLock = lock;
    }

    function _setWithdrawLock(bool lock) internal {

        emit WithdrawLock(lock);
        withdrawLock = lock;
    }

    function _setOwner(address newOwner) internal {

        require(newOwner != address(0), "owner zero address");
        emit OwnershipTransfer(owner, newOwner);
        owner = newOwner;
    }

    function _setPendingOwner(address _pendingOwner) internal {

        require(_pendingOwner != address(0), "pending owner zero address");
        pendingOwner = _pendingOwner;
    }
}


pragma solidity 0.6.12;


contract viewModule is internalModule {

    function marketInformation(uint256 _fromBlockNumber, uint256 _toBlockNumber) external view returns (
        uint256 rewardStartBlockNumber,
        uint256 distributedAmount,
        uint256 totalDeposit,
        uint256 poolRate
        )
    {

        if(rewardPerBlock == 0) rewardStartBlockNumber = registeredPoints[0].blockNumber;
        else rewardStartBlockNumber = registeredPoints[0].blockNumber;

        distributedAmount = _redeemAllView(address(0));

        totalDeposit = totalDeposited;

        poolRate = getPoolRate(address(0), _fromBlockNumber, _toBlockNumber);

        return (
            rewardStartBlockNumber,
            distributedAmount,
            totalDeposit,
            poolRate
        );
    }

    function userInformation(address userAddr, uint256 _fromBlockNumber, uint256 _toBlockNumber) external view returns (
        uint256 stakedTokenAmount,
        uint256 rewardStartBlockNumber,
        uint256 claimStartBlockNumber,
        uint256 earnedTokenAmount,
        uint256 poolRate
        )
    {

        Account memory user = accounts[userAddr];

        stakedTokenAmount = user.deposited;

        if(rewardPerBlock == 0) rewardStartBlockNumber = registeredPoints[0].blockNumber;
        else rewardStartBlockNumber = registeredPoints[0].blockNumber;

        earnedTokenAmount = _redeemAllView(userAddr);

        poolRate = getPoolRate(userAddr, _fromBlockNumber, _toBlockNumber);

        return (stakedTokenAmount, rewardStartBlockNumber, claimStartBlockNumber, earnedTokenAmount, poolRate);
    }

    function modelInfo() external view returns (uint256, uint256, uint256, uint256, uint256) {

        return (rewardPerBlock, decrementUnitPerBlock, rewardLane, lastBlockNum, totalDeposited);
    }

    function getParams() external view returns (uint256, uint256, uint256, uint256) {

        return (rewardPerBlock, rewardLane, lastBlockNum, totalDeposited);
    }

    function getRegisteredPointLength() external view returns (uint256) {

        return registeredPoints.length;
    }

    function getRegisteredPoint(uint256 index) external view returns (uint256, uint256, uint256) {

        RewardVelocityPoint memory point = registeredPoints[index];
        return (point.blockNumber, point.rewardPerBlock, point.decrementUnitPerBlock);
    }

    function userInfo(address userAddr) external view returns (uint256, uint256, uint256) {

        Account memory user = accounts[userAddr];
        uint256 earnedRewardAmount = _redeemAllView(userAddr);

        return (user.deposited, user.pointOnLane, earnedRewardAmount);
    }

    function distributionInfo() external view returns (uint256, uint256, uint256) {

        uint256 totalDistributedRewardAmount_now = _distributedRewardAmountView();
        return (rewardPerBlock, decrementUnitPerBlock, totalDistributedRewardAmount_now);
    }

    function _distributedRewardAmountView() internal view returns (uint256) {

        return _redeemAllView( address(0) );
    }

    function _redeemAllView(address userAddr) internal view returns (uint256) {

        Account memory user;
        uint256 newRewardLane;
        if( userAddr != address(0) ) {
            user = accounts[userAddr];
            newRewardLane = _updateRewardLaneView(lastBlockNum);
        } else {
            user = Account(totalDeposited, 0, 0);
            newRewardLane = _updateRewardLaneView(0);
        }

        uint256 distance = safeSub(newRewardLane, user.pointOnLane);
        uint256 rewardAmount = expMul(user.deposited, distance);

        return safeAdd(user.rewardAmount, rewardAmount);
    }

    function _updateRewardLaneView(uint256 fromBlockNumber) internal view returns (uint256) {

        UpdateRewardLaneModel memory vars;

        vars.len = registeredPoints.length;
        vars.memTotalDeposit = totalDeposited;

        if(fromBlockNumber == 0){
            vars.tmpPassedPoint = vars.memPassedPoint = 0;

            vars.memThisBlockNum = block.number;
            vars.tmpLastBlockNum = vars.memLastBlockNum = 0;
            vars.tmpRewardLane = vars.memRewardLane = 0;
            vars.tmpRewardPerBlock = vars.memRewardPerBlock = 0;
            vars.tmpDecrementUnitPerBlock = vars.memDecrementUnitPerBlock = 0;
        } else {
            vars.tmpPassedPoint = vars.memPassedPoint = passedPoint;
            vars.memThisBlockNum = block.number;
            vars.tmpLastBlockNum = vars.memLastBlockNum = fromBlockNumber;

            vars.tmpRewardLane = vars.memRewardLane = rewardLane;
            vars.tmpRewardPerBlock = vars.memRewardPerBlock = rewardPerBlock;
            vars.tmpDecrementUnitPerBlock = vars.memDecrementUnitPerBlock = decrementUnitPerBlock;
        }

        for(uint256 i=vars.memPassedPoint; i<vars.len; i++) {
            RewardVelocityPoint memory point = registeredPoints[i];
            if(vars.tmpLastBlockNum < point.blockNumber && point.blockNumber <= vars.memThisBlockNum) {
                vars.tmpPassedPoint = i+1;
                vars.tmpBlockDelta = safeSub(point.blockNumber, vars.tmpLastBlockNum);
                (vars.tmpRewardLane, vars.tmpRewardPerBlock) =
                _calcNewRewardLane(
                    vars.tmpRewardLane,
                    vars.memTotalDeposit,
                    vars.tmpRewardPerBlock,
                    vars.tmpDecrementUnitPerBlock,
                    vars.tmpBlockDelta);

                vars.tmpLastBlockNum = point.blockNumber;
                vars.tmpRewardPerBlock = point.rewardPerBlock;
                vars.tmpDecrementUnitPerBlock = point.decrementUnitPerBlock;
            } else {
                break;
            }
        }

        if(vars.memThisBlockNum > vars.tmpLastBlockNum) {
            vars.tmpBlockDelta = safeSub(vars.memThisBlockNum, vars.tmpLastBlockNum);
            vars.tmpLastBlockNum = vars.memThisBlockNum;
            (vars.tmpRewardLane, vars.tmpRewardPerBlock) =
            _calcNewRewardLane(
                vars.tmpRewardLane,
                vars.memTotalDeposit,
                vars.tmpRewardPerBlock,
                vars.tmpDecrementUnitPerBlock,
                vars.tmpBlockDelta);
        }
        return vars.tmpRewardLane;
    }
    function getPoolRate(address userAddr, uint256 fromBlockNumber, uint256 toBlockNumber) internal view returns (uint256) {

        UpdateRewardLaneModel memory vars;

        vars.len = registeredPoints.length;
        vars.memTotalDeposit = totalDeposited;

        vars.tmpLastBlockNum = vars.memLastBlockNum = fromBlockNumber;
        (vars.memPassedPoint, vars.memRewardPerBlock, vars.memDecrementUnitPerBlock) = getParamsByBlockNumber(fromBlockNumber);
        vars.tmpPassedPoint = vars.memPassedPoint;
        vars.tmpRewardPerBlock = vars.memRewardPerBlock;
        vars.tmpDecrementUnitPerBlock = vars.memDecrementUnitPerBlock;

        vars.memThisBlockNum = toBlockNumber;
        vars.tmpRewardLane = vars.memRewardLane = 0;

        for(uint256 i=vars.memPassedPoint; i<vars.len; i++) {
            RewardVelocityPoint memory point = registeredPoints[i];

            if(vars.tmpLastBlockNum < point.blockNumber && point.blockNumber <= vars.memThisBlockNum) {
                vars.tmpPassedPoint = i+1;
                vars.tmpBlockDelta = safeSub(point.blockNumber, vars.tmpLastBlockNum);
                (vars.tmpRewardLane, vars.tmpRewardPerBlock) =
                _calcNewRewardLane(
                    vars.tmpRewardLane,
                    vars.memTotalDeposit,
                    vars.tmpRewardPerBlock,
                    vars.tmpDecrementUnitPerBlock,
                    vars.tmpBlockDelta);

                vars.tmpLastBlockNum = point.blockNumber;
                vars.tmpRewardPerBlock = point.rewardPerBlock;
                vars.tmpDecrementUnitPerBlock = point.decrementUnitPerBlock;

            } else {
                break;
            }
        }

        if(vars.memThisBlockNum > vars.tmpLastBlockNum) {
            vars.tmpBlockDelta = safeSub(vars.memThisBlockNum, vars.tmpLastBlockNum);
            vars.tmpLastBlockNum = vars.memThisBlockNum;
            (vars.tmpRewardLane, vars.tmpRewardPerBlock) =
            _calcNewRewardLane(
                vars.tmpRewardLane,
                vars.memTotalDeposit,
                vars.tmpRewardPerBlock,
                vars.tmpDecrementUnitPerBlock,
                vars.tmpBlockDelta);
        }

        Account memory user;
        if( userAddr != address(0) ) user = accounts[userAddr];
        else user = Account(vars.memTotalDeposit, 0, 0);

        return safeDiv(expMul(user.deposited, vars.tmpRewardLane), safeSub(toBlockNumber, fromBlockNumber));
    }

    function getParamsByBlockNumber(uint256 _blockNumber) internal view returns (uint256, uint256, uint256) {

        uint256 _rewardPerBlock; uint256 _decrement;
        uint256 i;

        uint256 tmpthisPoint;

        uint256 pointLength = registeredPoints.length;
        if( pointLength > 0 ) {
            for(i = 0; i < pointLength; i++) {
                RewardVelocityPoint memory point = registeredPoints[i];
                if(_blockNumber >= point.blockNumber && 0 != point.blockNumber) {
                    tmpthisPoint = i;
                    _rewardPerBlock = point.rewardPerBlock;
                    _decrement = point.decrementUnitPerBlock;
                } else if( 0 == point.blockNumber ) continue;
                else break;
            }
        }
        RewardVelocityPoint memory point = registeredPoints[tmpthisPoint];
        _rewardPerBlock = point.rewardPerBlock;
        _decrement = point.decrementUnitPerBlock;
        if(_blockNumber > point.blockNumber) {
            _rewardPerBlock = safeSub(_rewardPerBlock, safeMul(_decrement, safeSub(_blockNumber, point.blockNumber) ) );
        }
        return (i, _rewardPerBlock, _decrement);
    }

    function getUserPoolRate(address userAddr, uint256 fromBlockNumber, uint256 toBlockNumber) external view returns (uint256) {

        return getPoolRate(userAddr, fromBlockNumber, toBlockNumber);
    }

    function getModelPoolRate(uint256 fromBlockNumber, uint256 toBlockNumber) external view returns (uint256) {

        return getPoolRate(address(0), fromBlockNumber, toBlockNumber);
    }
}


pragma solidity 0.6.12;


contract externalModule is viewModule {

    modifier onlyOwner() {

        require(msg.sender == owner, "onlyOwner: external function access control!");
        _;
    }
    modifier checkClaimLocked() {

        require(!claimLock, "error: claim Locked");
        _;
    }
    modifier checkWithdrawLocked() {

        require(!withdrawLock, "error: withdraw Locked");
        _;
    }

    function setERC(address erc20Addr) external onlyOwner {

        lpErc = ERC20(erc20Addr);
    }

    function setRE(address erc20Addr) external onlyOwner {

        rewardErc = ERC20(erc20Addr);
    }

    function setParam(uint256 _rewardPerBlock, uint256 _decrementUnitPerBlock) onlyOwner external {

        _setParams(_rewardPerBlock, _decrementUnitPerBlock);
    }

    function modelFinish(uint256 amount) external onlyOwner {

        if( amount != 0) {
            require( rewardErc.transfer(owner, amount), "token error" );
        }
        else {
            require( rewardErc.transfer(owner, rewardErc.balanceOf(address(this))), "token error" );
        }
        delete totalDeposited;
        delete rewardPerBlock;
        delete decrementUnitPerBlock;
        delete rewardLane;
        delete totalDeposited;
        delete registeredPoints;
    }

    function retrieveRewardAmount(uint256 amount) external onlyOwner {

        if( amount != 0) {
            require( rewardErc.transfer(owner, amount), "token error");
        }
        else {
            require( rewardErc.transfer(owner, rewardErc.balanceOf(address(this))), "token error");
        }
    }

    function deposit(uint256 amount) external {

        address userAddr = msg.sender;
        _redeemAll(userAddr);
        _deposit(userAddr, amount);
    }

    function depositTo(address userAddr, uint256 amount) external {

        _redeemAll(userAddr);
        _deposit(userAddr, amount);
    }

    function withdraw(uint256 amount) checkWithdrawLocked external {

        address userAddr = msg.sender;
        _redeemAll(userAddr);
        _withdraw(userAddr, amount);
    }

    function rewardClaim() checkClaimLocked external {

        address userAddr = msg.sender;
        _redeemAll(userAddr);
        _rewardClaim(userAddr);
    }
    function rewardClaimTo(address userAddr) checkClaimLocked external {

        _redeemAll(userAddr);
        _rewardClaim(userAddr);
    }

    function setClaimLock(bool lock) onlyOwner external {

        _setClaimLock(lock);
    }
    function setWithdrawLock(bool lock) onlyOwner external {

        _setWithdrawLock(lock);
    }

    function ownershipTransfer(address newPendingOwner) onlyOwner external {

        _setPendingOwner(newPendingOwner);
    }

    function acceptOwnership() external {

        address sender = msg.sender;
        require(sender == pendingOwner, "msg.sender != pendingOwner");
        _setOwner(sender);
    }

    function registerRewardVelocity(uint256 _blockNumber, uint256 _rewardPerBlock, uint256 _decrementUnitPerBlock) onlyOwner public {

        require(_blockNumber > block.number, "new Reward params should register earlier");
        require(registeredPoints.length == 0 || _blockNumber > registeredPoints[registeredPoints.length-1].blockNumber, "Earilier velocity points are already set.");
        _registerRewardVelocity(_blockNumber, _rewardPerBlock, _decrementUnitPerBlock);
    }
    function deleteRegisteredRewardVelocity(uint256 _index) onlyOwner external {

        require(_index >= passedPoint, "Reward velocity point already passed.");
        _deleteRegisteredRewardVelocity(_index);
    }

    function setRewardVelocity(uint256 _rewardPerBlock, uint256 _decrementUnitPerBlock) onlyOwner external {

        _updateRewardLane();
        _setParams(_rewardPerBlock, _decrementUnitPerBlock);
    }
}


pragma solidity 0.6.12;


contract DistributionModelV3 is externalModule {

    constructor(address _owner, address _lpErc, address _rewardErc) public {
        owner = _owner;
        lpErc = ERC20(_lpErc);
        rewardErc = ERC20(_rewardErc);
        lastBlockNum = block.number;
    }
}

contract BFCModel is DistributionModelV3 {

    constructor(address _owner, address _lpErc, address _rewardErc, uint256 _start)
    DistributionModelV3(_owner, _lpErc, _rewardErc) public {
        _registerRewardVelocity(_start, 0x3935413a1cdd90ff, 0x62e9bea75f);
    }
}

contract BFCETHModel is DistributionModelV3 {

    constructor(address _owner, address _lpErc, address _rewardErc, uint256 _start)
    DistributionModelV3(_owner, _lpErc, _rewardErc) public {
        _registerRewardVelocity(_start, 0xe4d505786b744b3f, 0x18ba6fb966b);
    }
}

contract BiFiETHModel is DistributionModelV3 {

    constructor(address _owner, address _lpErc, address _rewardErc, uint256 _start)
    DistributionModelV3(_owner, _lpErc, _rewardErc) public {
        _registerRewardVelocity(_start, 0x11e0a46e285a68955, 0x1ee90ba90c4);
    }
}


pragma solidity 0.6.12;


contract BFCETHSushiSwapReward is DistributionModelV3 {

    constructor(uint256 start, uint256 reward_per_block, uint256 dec_per_block)
        DistributionModelV3(
            0x359903041dE93c69828F911aeB0BE29CC9ccc58b, //ower
            0x281Df7fc89294C84AfA2A21FfEE8f6807F9C9226, //swap_pool_token(BFCETH_Sushi)
            0x2791BfD60D232150Bff86b39B7146c0eaAA2BA81  //reward_token(bifi)
        ) public {
        _registerRewardVelocity(start, reward_per_block, dec_per_block);
        pendingOwner = msg.sender;
    }
}

contract BiFiETHSushiSwapReward is DistributionModelV3 {

    constructor(uint256 start, uint256 reward_per_block, uint256 dec_per_block)
    DistributionModelV3(
        0x359903041dE93c69828F911aeB0BE29CC9ccc58b, //owner
        0x0beC54c89a7d9F15C4e7fAA8d47ADEdF374462eD, //swap_pool_token(BiFiETH_Sushi)
        0x2791BfD60D232150Bff86b39B7146c0eaAA2BA81  //reward_token(bifi)
    ) public {
        _registerRewardVelocity(start, reward_per_block, dec_per_block);
        pendingOwner = msg.sender;
    }
}