pragma solidity 0.6.12;



interface ICurveGauge {

    function deposit(uint256) external;

    function balanceOf(address) external view returns (uint256);

    function withdraw(uint256) external;

    function claim_rewards() external;

    function reward_tokens(uint256) external view returns(address);//v2

    function rewarded_token() external view returns(address);//v1

    function lp_token() external view returns(address);

}

interface ICurveVoteEscrow {

    function create_lock(uint256, uint256) external;

    function increase_amount(uint256) external;

    function increase_unlock_time(uint256) external;

    function withdraw() external;

    function smart_wallet_checker() external view returns (address);

    function commit_smart_wallet_checker(address) external;

    function apply_smart_wallet_checker() external;

}

interface IWalletChecker {

    function check(address) external view returns (bool);

    function approveWallet(address) external;

    function dao() external view returns (address);

}

interface IVoting{

    function vote(uint256, bool, bool) external; //voteId, support, executeIfDecided

    function getVote(uint256) external view returns(bool,bool,uint64,uint64,uint64,uint64,uint256,uint256,uint256,bytes memory); 

    function vote_for_gauge_weights(address,uint256) external;

}

interface IMinter{

    function mint(address) external;

}

interface IStaker{

    function deposit(address, address) external returns (bool);

    function withdraw(address) external returns (uint256);

    function withdraw(address, address, uint256) external returns (bool);

    function withdrawAll(address, address) external returns (bool);

    function createLock(uint256, uint256) external returns(bool);

    function increaseAmount(uint256) external returns(bool);

    function increaseTime(uint256) external returns(bool);

    function release() external returns(bool);

    function claimCrv(address) external returns (uint256);

    function claimRewards(address) external returns(bool);

    function claimFees(address,address) external returns (uint256);

    function setStashAccess(address, bool) external returns (bool);

    function vote(uint256,address,bool) external returns(bool);

    function voteGaugeWeight(address,uint256) external returns(bool);

    function balanceOfPool(address) external view returns (uint256);

    function operator() external view returns (address);

    function execute(address _to, uint256 _value, bytes calldata _data) external returns (bool, bytes memory);

    function setVote(bytes32 hash, bool valid) external;

    function migrate(address to) external;

}

interface IRewards{

    function stake(address, uint256) external;

    function stakeFor(address, uint256) external;

    function withdraw(address, uint256) external;

    function exit(address) external;

    function getReward(address) external;

    function queueNewRewards(uint256) external;

    function notifyRewardAmount(uint256) external;

    function addExtraReward(address) external;

    function extraRewardsLength() external view returns (uint256);

    function stakingToken() external view returns (address);

    function rewardToken() external view returns(address);

    function earned(address account) external view returns (uint256);

}

interface IStash{

    function stashRewards() external returns (bool);

    function processStash() external returns (bool);

    function claimRewards() external returns (bool);

    function initialize(uint256 _pid, address _operator, address _staker, address _gauge, address _rewardFactory) external;

}

interface IFeeDistributor {

    function claimToken(address user, address token) external returns (uint256);

    function claimTokens(address user, address[] calldata tokens) external returns (uint256[] memory);

    function getTokenTimeCursor(address token) external view returns (uint256);

}

interface ITokenMinter{

    function mint(address,uint256) external;

    function burn(address,uint256) external;

}

interface IDeposit{

    function isShutdown() external view returns(bool);

    function balanceOf(address _account) external view returns(uint256);

    function totalSupply() external view returns(uint256);

    function poolInfo(uint256) external view returns(address,address,address,address,address, bool);

    function rewardClaimed(uint256,address,uint256) external;

    function withdrawTo(uint256,uint256,address) external;

    function claimRewards(uint256,address) external returns(bool);

    function rewardArbitrator() external returns(address);

    function setGaugeRedirect(uint256 _pid) external returns(bool);

    function owner() external returns(address);

    function deposit(uint256 _pid, uint256 _amount, bool _stake) external returns(bool);

}

interface ICrvDeposit{

    function deposit(uint256, bool) external;

    function lockIncentive() external view returns(uint256);

}

interface IRewardFactory{

    function setAccess(address,bool) external;

    function CreateCrvRewards(uint256,address,address) external returns(address);

    function CreateTokenRewards(address,address,address) external returns(address);

    function activeRewardCount(address) external view returns(uint256);

    function addActiveReward(address,uint256) external returns(bool);

    function removeActiveReward(address,uint256) external returns(bool);

}

interface IStashFactory{

    function CreateStash(uint256,address,address,uint256) external returns(address);

}

interface ITokenFactory{

    function CreateDepositToken(address) external returns(address);

}

interface IPools{

    function addPool(address _lptoken, address _gauge, uint256 _stashVersion) external returns(bool);

    function forceAddPool(address _lptoken, address _gauge, uint256 _stashVersion) external returns(bool);

    function shutdownPool(uint256 _pid) external returns(bool);

    function poolInfo(uint256) external view returns(address,address,address,address,address,bool);

    function poolLength() external view returns (uint256);

    function gaugeMap(address) external view returns(bool);

    function setPoolManager(address _poolM) external;

}

interface IVestedEscrow{

    function fund(address[] calldata _recipient, uint256[] calldata _amount) external returns(bool);

}

interface IRewardDeposit {

    function addReward(address, uint256) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.2 <0.8.0;

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.6.0 <0.8.0;


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
}// MIT
pragma solidity 0.6.12;


contract ArbitratorVault{

    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public operator;
    address public immutable depositor;


    constructor(address _depositor)public
    {
        operator = msg.sender;
        depositor = _depositor;
    }

    function setOperator(address _op) external {

        require(msg.sender == operator, "!auth");
        operator = _op;
    }

    function distribute(address _token, uint256[] calldata _toPids, uint256[] calldata _amounts) external {

       require(msg.sender == operator, "!auth");

       for(uint256 i = 0; i < _toPids.length; i++){
        (,,,,address stashAddress,bool shutdown) = IDeposit(depositor).poolInfo(_toPids[i]);

        require(shutdown==false,"pool closed");

        IERC20(_token).safeTransfer(stashAddress, _amounts[i]);
       }
    }

}// MIT
pragma solidity 0.6.12;


contract VoterProxy {

    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public mintr;
    address public immutable crv;
    address public immutable crvBpt;

    address public immutable escrow;
    address public gaugeController;
    address public rewardDeposit;
    address public withdrawer;

    address public owner;
    address public operator;
    address public depositor;
    
    mapping (address => bool) private stashPool;
    mapping (address => bool) private protectedTokens;
    mapping (bytes32 => bool) private votes;

    bytes4 constant internal EIP1271_MAGIC_VALUE = 0x1626ba7e;

    event VoteSet(bytes32 hash, bool valid);

    constructor(
        address _mintr,
        address _crv,
        address _crvBpt,
        address _escrow,
        address _gaugeController
    ) public {
        mintr = _mintr; 
        crv = _crv;
        crvBpt = _crvBpt;
        escrow = _escrow;
        gaugeController = _gaugeController;
        owner = msg.sender;

        protectedTokens[_crv] = true;
        protectedTokens[_crvBpt] = true;
    }

    function getName() external pure returns (string memory) {

        return "BalancerVoterProxy";
    }

    function setOwner(address _owner) external {

        require(msg.sender == owner, "!auth");
        owner = _owner;
    }

    function setRewardDeposit(address _withdrawer, address _rewardDeposit) external {

        require(msg.sender == owner, "!auth");
        withdrawer = _withdrawer;
        rewardDeposit = _rewardDeposit;
    }

    function setSystemConfig(address _gaugeController, address _mintr) external returns (bool) {

        require(msg.sender == owner, "!auth");
        gaugeController = _gaugeController;
        mintr = _mintr;
        return true;
    }

    function setOperator(address _operator) external {

        require(msg.sender == owner, "!auth");
        require(operator == address(0) || IDeposit(operator).isShutdown() == true, "needs shutdown");
        
        operator = _operator;
    }

    function setDepositor(address _depositor) external {

        require(msg.sender == owner, "!auth");

        depositor = _depositor;
    }

    function setStashAccess(address _stash, bool _status) external returns(bool){

        require(msg.sender == operator, "!auth");
        if(_stash != address(0)){
            stashPool[_stash] = _status;
        }
        return true;
    }

    function setVote(bytes32 _hash, bool _valid) external {

        require(msg.sender == operator, "!auth");
        votes[_hash] = _valid;
        emit VoteSet(_hash, _valid);
    }

    function isValidSignature(bytes32 _hash, bytes memory) public view returns (bytes4) {

        if(votes[_hash]) {
            return EIP1271_MAGIC_VALUE;
        } else {
            return 0xffffffff;
        }  
    }

    function deposit(address _token, address _gauge) external returns(bool){

        require(msg.sender == operator, "!auth");
        if(protectedTokens[_token] == false){
            protectedTokens[_token] = true;
        }
        if(protectedTokens[_gauge] == false){
            protectedTokens[_gauge] = true;
        }
        uint256 balance = IERC20(_token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(_token).safeApprove(_gauge, 0);
            IERC20(_token).safeApprove(_gauge, balance);
            ICurveGauge(_gauge).deposit(balance);
        }
        return true;
    }

    function withdraw(IERC20 _asset) external returns (uint256 balance) {

        require(msg.sender == withdrawer, "!auth");
        require(protectedTokens[address(_asset)] == false, "protected");

        balance = _asset.balanceOf(address(this));
        _asset.safeApprove(rewardDeposit, 0);
        _asset.safeApprove(rewardDeposit, balance);
        IRewardDeposit(rewardDeposit).addReward(address(_asset), balance);
        return balance;
    }

    function withdraw(address _token, address _gauge, uint256 _amount) public returns(bool){

        require(msg.sender == operator, "!auth");
        uint256 _balance = IERC20(_token).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_gauge, _amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
        IERC20(_token).safeTransfer(msg.sender, _amount);
        return true;
    }

    function withdrawAll(address _token, address _gauge) external returns(bool){

        require(msg.sender == operator, "!auth");
        uint256 amount = balanceOfPool(_gauge).add(IERC20(_token).balanceOf(address(this)));
        withdraw(_token, _gauge, amount);
        return true;
    }

    function _withdrawSome(address _gauge, uint256 _amount) internal returns (uint256) {

        ICurveGauge(_gauge).withdraw(_amount);
        return _amount;
    }
    
    
    function createLock(uint256 _value, uint256 _unlockTime) external returns(bool){

        require(msg.sender == depositor, "!auth");
        IERC20(crvBpt).safeApprove(escrow, 0);
        IERC20(crvBpt).safeApprove(escrow, _value);
        ICurveVoteEscrow(escrow).create_lock(_value, _unlockTime);
        return true;
    }
  
    function increaseAmount(uint256 _value) external returns(bool){

        require(msg.sender == depositor, "!auth");
        IERC20(crvBpt).safeApprove(escrow, 0);
        IERC20(crvBpt).safeApprove(escrow, _value);
        ICurveVoteEscrow(escrow).increase_amount(_value);
        return true;
    }

    function increaseTime(uint256 _value) external returns(bool){

        require(msg.sender == depositor, "!auth");
        ICurveVoteEscrow(escrow).increase_unlock_time(_value);
        return true;
    }

    function release() external returns(bool){

        require(msg.sender == depositor, "!auth");
        ICurveVoteEscrow(escrow).withdraw();
        return true;
    }

    function vote(uint256 _voteId, address _votingAddress, bool _support) external returns(bool){

        require(msg.sender == operator, "!auth");
        IVoting(_votingAddress).vote(_voteId,_support,false);
        return true;
    }

    function voteGaugeWeight(address _gauge, uint256 _weight) external returns(bool){

        require(msg.sender == operator, "!auth");

        IVoting(gaugeController).vote_for_gauge_weights(_gauge, _weight);
        return true;
    }

    function claimCrv(address _gauge) external returns (uint256){

        require(msg.sender == operator, "!auth");
        
        uint256 _balance = 0;
        try IMinter(mintr).mint(_gauge){
            _balance = IERC20(crv).balanceOf(address(this));
            IERC20(crv).safeTransfer(operator, _balance);
        }catch{}

        return _balance;
    }

    function claimRewards(address _gauge) external returns(bool){
        require(msg.sender == operator, "!auth");
        ICurveGauge(_gauge).claim_rewards();
        return true;
    }

    function claimFees(address _distroContract, address _token) external returns (uint256){
        require(msg.sender == operator, "!auth");
        IFeeDistributor(_distroContract).claimToken(address(this), _token);
        uint256 _balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(operator, _balance);
        return _balance;
    }    

    function balanceOfPool(address _gauge) public view returns (uint256) {
        return ICurveGauge(_gauge).balanceOf(address(this));
    }

    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external returns (bool, bytes memory) {
        require(msg.sender == operator,"!auth");

        (bool success, bytes memory result) = _to.call{value:_value}(_data);
        require(success, "!success");

        return (success, result);
    }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


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

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT
pragma solidity 0.6.12;



contract DepositToken is ERC20 {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public operator;

    constructor(
        address _operator,
        address _lptoken,
        string memory _namePostfix,
        string memory _symbolPrefix
    )
        public
        ERC20(
             string(
                abi.encodePacked(ERC20(_lptoken).name(), _namePostfix)
            ),
            string(abi.encodePacked(_symbolPrefix, ERC20(_lptoken).symbol()))
        )
    {
        operator =  _operator;
    }
    
    function mint(address _to, uint256 _amount) external {
        require(msg.sender == operator, "!authorized");
        
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external {
        require(msg.sender == operator, "!authorized");
        
        _burn(_from, _amount);
    }

}// MIT
pragma solidity 0.6.12;


contract TokenFactory {
    using Address for address;

    address public immutable operator;
    string public namePostfix;
    string public symbolPrefix;

    event DepositTokenCreated(address token, address lpToken);

    constructor(
        address _operator,
        string memory _namePostfix,
        string memory _symbolPrefix
    ) public {
        operator = _operator;
        namePostfix = _namePostfix;
        symbolPrefix = _symbolPrefix;
    }

    function CreateDepositToken(address _lptoken) external returns(address){
        require(msg.sender == operator, "!authorized");

        DepositToken dtoken = new DepositToken(operator,_lptoken,namePostfix,symbolPrefix);
        emit DepositTokenCreated(address(dtoken), _lptoken);
        return address(dtoken);
    }
}// MIT
pragma solidity 0.6.12;

interface IProxyFactory {
    function clone(address _target) external returns(address);
}// MIT
pragma solidity 0.6.12;


contract StashFactoryV2 {
    using Address for address;

    bytes4 private constant rewarded_token = 0x16fa50b1; //rewarded_token()
    bytes4 private constant reward_tokens = 0x54c49fe9; //reward_tokens(uint256)
    bytes4 private constant rewards_receiver = 0x01ddabf1; //rewards_receiver(address)

    address public immutable operator;
    address public immutable rewardFactory;
    address public immutable proxyFactory;

    address public v1Implementation;
    address public v2Implementation;
    address public v3Implementation;

    event StashCreated(address stash, uint256 stashVersion);

    constructor(address _operator, address _rewardFactory, address _proxyFactory) public {
        operator = _operator;
        rewardFactory = _rewardFactory;
        proxyFactory = _proxyFactory;
    }

    function setImplementation(address _v1, address _v2, address _v3) external{
        require(msg.sender == IDeposit(operator).owner(),"!auth");

        v1Implementation = _v1;
        v2Implementation = _v2;
        v3Implementation = _v3;
    }

    function CreateStash(uint256 _pid, address _gauge, address _staker, uint256 _stashVersion) external returns(address){
        require(msg.sender == operator, "!authorized");
        require(_gauge != address(0), "!gauge");

        if(_stashVersion == uint256(3) && IsV3(_gauge)){
            require(v3Implementation!=address(0),"0 impl");
            address stash = IProxyFactory(proxyFactory).clone(v3Implementation);
            IStash(stash).initialize(_pid,operator,_staker,_gauge,rewardFactory);
            emit StashCreated(stash, _stashVersion);
            return stash;
        }else if(_stashVersion == uint256(1) && IsV1(_gauge)){
            require(v1Implementation!=address(0),"0 impl");
            address stash = IProxyFactory(proxyFactory).clone(v1Implementation);
            IStash(stash).initialize(_pid,operator,_staker,_gauge,rewardFactory);
            emit StashCreated(stash, _stashVersion);
            return stash;
        }else if(_stashVersion == uint256(2) && !IsV3(_gauge) && IsV2(_gauge)){
            require(v2Implementation!=address(0),"0 impl");
            address stash = IProxyFactory(proxyFactory).clone(v2Implementation);
            IStash(stash).initialize(_pid,operator,_staker,_gauge,rewardFactory);
            emit StashCreated(stash, _stashVersion);
            return stash;
        }
        bool isV1 = IsV1(_gauge);
        bool isV2 = IsV2(_gauge);
        bool isV3 = IsV3(_gauge);
        require(!isV1 && !isV2 && !isV3,"stash version mismatch");
        return address(0);
    }

    function IsV1(address _gauge) private returns(bool){
        bytes memory data = abi.encode(rewarded_token);
        (bool success,) = _gauge.call(data);
        return success;
    }

    function IsV2(address _gauge) private returns(bool){
        bytes memory data = abi.encodeWithSelector(reward_tokens,uint256(0));
        (bool success,) = _gauge.call(data);
        return success;
    }

    function IsV3(address _gauge) private returns(bool){
        bytes memory data = abi.encodeWithSelector(rewards_receiver,address(0));
        (bool success,) = _gauge.call(data);
        return success;
    }
}// MIT
pragma solidity 0.6.12;



contract RewardHook{
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;


    address public immutable stash;
    address public immutable rewardToken;


    constructor(address _stash, address _reward) public {
        stash = _stash;
        rewardToken = _reward;
    }


    function onRewardClaim() external{

        uint256 bal = IERC20(rewardToken).balanceOf(address(this));

        IERC20(rewardToken).safeTransfer(stash,bal);
    }
}// MIT
pragma solidity 0.6.12;

library MathUtil {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}// MIT
pragma solidity 0.6.12;




abstract contract VirtualBalanceWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IDeposit public immutable deposits;

    constructor(address deposit_) internal {
        deposits = IDeposit(deposit_);
    }

    function totalSupply() public view returns (uint256) {
        return deposits.totalSupply();
    }

    function balanceOf(address account) public view returns (uint256) {
        return deposits.balanceOf(account);
    }
}

contract VirtualBalanceRewardPool is VirtualBalanceWrapper {
    using SafeERC20 for IERC20;
    
    IERC20 public immutable rewardToken;
    uint256 public constant duration = 7 days;

    address public immutable operator;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public queuedRewards = 0;
    uint256 public currentRewards = 0;
    uint256 public historicalRewards = 0;
    uint256 public constant newRewardRatio = 830;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(
        address deposit_,
        address reward_,
        address op_
    ) public VirtualBalanceWrapper(deposit_) {
        rewardToken = IERC20(reward_);
        operator = op_;
    }


    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return MathUtil.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function stake(address _account, uint256 amount)
        external
        updateReward(_account)
    {
        require(msg.sender == address(deposits), "!authorized");
        emit Staked(_account, amount);
    }

    function withdraw(address _account, uint256 amount)
        public
        updateReward(_account)
    {
        require(msg.sender == address(deposits), "!authorized");

        emit Withdrawn(_account, amount);
    }

    function getReward(address _account) public updateReward(_account){
        uint256 reward = earned(_account);
        if (reward > 0) {
            rewards[_account] = 0;
            rewardToken.safeTransfer(_account, reward);
            emit RewardPaid(_account, reward);
        }
    }

    function getReward() external{
        getReward(msg.sender);
    }

    function donate(uint256 _amount) external returns(bool){
        IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
        queuedRewards = queuedRewards.add(_amount);
    }

    function queueNewRewards(uint256 _rewards) external{
        require(msg.sender == operator, "!authorized");

        _rewards = _rewards.add(queuedRewards);

        if (block.timestamp >= periodFinish) {
            notifyRewardAmount(_rewards);
            queuedRewards = 0;
            return;
        }

        uint256 elapsedTime = block.timestamp.sub(periodFinish.sub(duration));
        uint256 currentAtNow = rewardRate * elapsedTime;
        uint256 queuedRatio = currentAtNow.mul(1000).div(_rewards);
        if(queuedRatio < newRewardRatio){
            notifyRewardAmount(_rewards);
            queuedRewards = 0;
        }else{
            queuedRewards = _rewards;
        }
    }

    function notifyRewardAmount(uint256 reward)
        internal
        updateReward(address(0))
    {
        historicalRewards = historicalRewards.add(reward);
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(duration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            reward = reward.add(leftover);
            rewardRate = reward.div(duration);
        }
        currentRewards = reward;
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(duration);
        emit RewardAdded(reward);
    }
}// MIT
pragma solidity 0.6.12;




contract BaseRewardPool {
     using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public immutable rewardToken;
    IERC20 public immutable stakingToken;
    uint256 public constant duration = 7 days;

    address public immutable operator;
    address public immutable rewardManager;

    uint256 public immutable pid;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public queuedRewards = 0;
    uint256 public currentRewards = 0;
    uint256 public historicalRewards = 0;
    uint256 public constant newRewardRatio = 830;
    uint256 private _totalSupply;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) private _balances;

    address[] public extraRewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor(
        uint256 pid_,
        address stakingToken_,
        address rewardToken_,
        address operator_,
        address rewardManager_
    ) public {
        pid = pid_;
        stakingToken = IERC20(stakingToken_);
        rewardToken = IERC20(rewardToken_);
        operator = operator_;
        rewardManager = rewardManager_;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function extraRewardsLength() external view returns (uint256) {
        return extraRewards.length;
    }

    function addExtraReward(address _reward) external returns(bool){
        require(msg.sender == rewardManager, "!authorized");
        require(_reward != address(0),"!reward setting");
        
        if(extraRewards.length >= 12){
            return false;
        }
        
        extraRewards.push(_reward);
        return true;
    }
    function clearExtraRewards() external{
        require(msg.sender == rewardManager, "!authorized");
        delete extraRewards;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return MathUtil.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function stake(uint256 _amount)
        public 
        returns(bool)
    {
        _processStake(_amount, msg.sender);

        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit Staked(msg.sender, _amount);

        return true;
    }

    function stakeAll() external returns(bool){
        uint256 balance = stakingToken.balanceOf(msg.sender);
        stake(balance);
        return true;
    }

    function stakeFor(address _for, uint256 _amount)
        public
        returns(bool)
    {
        _processStake(_amount, _for);

        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        emit Staked(_for, _amount);
        
        return true;
    }

    function _processStake(uint256 _amount, address _receiver) internal updateReward(_receiver) {
        require(_amount > 0, 'RewardPool : Cannot stake 0');
        
        for(uint i=0; i < extraRewards.length; i++){
            IRewards(extraRewards[i]).stake(_receiver, _amount);
        }

        _totalSupply = _totalSupply.add(_amount);
        _balances[_receiver] = _balances[_receiver].add(_amount);
    }

    function withdraw(uint256 amount, bool claim)
        public
        updateReward(msg.sender)
        returns(bool)
    {
        require(amount > 0, 'RewardPool : Cannot withdraw 0');

        for(uint i=0; i < extraRewards.length; i++){
            IRewards(extraRewards[i]).withdraw(msg.sender, amount);
        }

        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);

        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
     
        if(claim){
            getReward(msg.sender,true);
        }

        return true;
    }

    function withdrawAll(bool claim) external{
        withdraw(_balances[msg.sender],claim);
    }

    function withdrawAndUnwrap(uint256 amount, bool claim) public returns(bool){
        _withdrawAndUnwrapTo(amount, msg.sender, msg.sender);
        if(claim){
            getReward(msg.sender,true);
        }
        return true;
    }

    function _withdrawAndUnwrapTo(uint256 amount, address from, address receiver) internal updateReward(from) returns(bool){
        for(uint i=0; i < extraRewards.length; i++){
            IRewards(extraRewards[i]).withdraw(from, amount);
        }
        
        _totalSupply = _totalSupply.sub(amount);
        _balances[from] = _balances[from].sub(amount);

        IDeposit(operator).withdrawTo(pid,amount,receiver);
        emit Withdrawn(from, amount);

        return true;
    }

    function withdrawAllAndUnwrap(bool claim) external{
        withdrawAndUnwrap(_balances[msg.sender],claim);
    }

    function getReward(address _account, bool _claimExtras) public updateReward(_account) returns(bool){
        uint256 reward = earned(_account);
        if (reward > 0) {
            rewards[_account] = 0;
            rewardToken.safeTransfer(_account, reward);
            IDeposit(operator).rewardClaimed(pid, _account, reward);
            emit RewardPaid(_account, reward);
        }

        if(_claimExtras){
            for(uint i=0; i < extraRewards.length; i++){
                IRewards(extraRewards[i]).getReward(_account);
            }
        }
        return true;
    }

    function getReward() external returns(bool){
        getReward(msg.sender,true);
        return true;
    }

    function donate(uint256 _amount) external returns(bool){
        IERC20(rewardToken).safeTransferFrom(msg.sender, address(this), _amount);
        queuedRewards = queuedRewards.add(_amount);
    }

    function processIdleRewards() external {
        if (block.timestamp >= periodFinish && queuedRewards > 0) {
            notifyRewardAmount(queuedRewards);
            queuedRewards = 0;
        }
    }

    function queueNewRewards(uint256 _rewards) external returns(bool){
        require(msg.sender == operator, "!authorized");

        _rewards = _rewards.add(queuedRewards);

        if (block.timestamp >= periodFinish) {
            notifyRewardAmount(_rewards);
            queuedRewards = 0;
            return true;
        }

        uint256 elapsedTime = block.timestamp.sub(periodFinish.sub(duration));
        uint256 currentAtNow = rewardRate * elapsedTime;
        uint256 queuedRatio = currentAtNow.mul(1000).div(_rewards);

        if(queuedRatio < newRewardRatio){
            notifyRewardAmount(_rewards);
            queuedRewards = 0;
        }else{
            queuedRewards = _rewards;
        }
        return true;
    }

    function notifyRewardAmount(uint256 reward)
        internal
        updateReward(address(0))
    {
        historicalRewards = historicalRewards.add(reward);
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(duration);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            reward = reward.add(leftover);
            rewardRate = reward.div(duration);
        }
        currentRewards = reward;
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(duration);
        emit RewardAdded(reward);
    }
}