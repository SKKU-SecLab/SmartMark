
pragma solidity >=0.8.0;




abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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
}







 
contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor (string memory __name, string memory __symbol) public {
        _name = __name;
        _symbol = __symbol;
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

    function burn(uint256 amount) public virtual {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {

        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
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

    function _burnFrom(address account, uint256 amount) internal virtual {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}






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
}




contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor (address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}






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
}

interface IWalletChecker {
    function check(address) external view returns (bool);
}

interface IVoting{
    function vote(uint256, bool, bool) external; //voteId, support, executeIfDecided
    function getVote(uint256) external view returns(bool,bool,uint64,uint64,uint64,uint64,uint256,uint256,uint256,bytes memory); 
    function vote_for_gauge_weights(address,uint256) external;
}

interface IMinter{
    function mint(address) external;
}

interface IRegistry{
    function get_registry() external view returns(address);
    function get_address(uint256 _id) external view returns(address);
    function gauge_controller() external view returns(address);
    function get_lp_token(address) external view returns(address);
    function get_gauges(address) external view returns(address[10] memory,uint128[10] memory);
}

interface IStaker{
    function deposit(address, address) external;
    function withdraw(address) external;
    function withdraw(address, address, uint256) external;
    function withdrawAll(address, address) external;
    function createLock(uint256, uint256) external;
    function increaseAmount(uint256) external;
    function increaseTime(uint256) external;
    function release() external;
    function claimCrv(address) external returns (uint256);
    function claimRewards(address) external;
    function claimFees(address,address) external;
    function setStashAccess(address, bool) external;
    function vote(uint256,address,bool) external;
    function voteGaugeWeight(address,uint256) external;
    function balanceOfPool(address) external view returns (uint256);
    function operator() external view returns (address);
    function execute(address _to, uint256 _value, bytes calldata _data) external returns (bool, bytes memory);
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

interface IFeeDistro{
  function checkpoint_token() external;
  function ve_for_at(address _user, uint256 _timestamp) external view returns(uint256);
  function checkpoint_total_supply() external;
  function claim() external returns(uint256);
  function claim(address _addr) external returns(uint256);
  function claim_many(address[20] memory _receivers) external returns(bool);
  function burn(address _coin) external returns(bool);
  function commit_admin(address _addr) external;
  function apply_admin() external;
  function toggle_allow_checkpoint_token() external;
  function kill_me() external;
  function recover_balance(address _coin) external returns(bool);
  function start_time() external view returns(uint256);
  function time_cursor() external view returns(uint256);
  function time_cursor_of(address arg0) external view returns(uint256);
  function user_epoch_of(address arg0) external view returns(uint256);
  function last_token_time() external view returns(uint256);
  function tokens_per_week(uint256 arg0) external view returns(uint256);
  function voting_escrow() external view returns(address);
  function token() external view returns(address);
  function total_received() external view returns(uint256);
  function token_last_balance() external view returns(uint256);
  function ve_supply(uint256 arg0) external view returns(uint256);
  function admin() external view returns(address);
  function future_admin() external view returns(address);
  function can_checkpoint_token() external view returns(bool);
  function emergency_return() external view returns(address);
  function is_killed() external view returns(bool);
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
}

interface ICrvDeposit{
    function deposit(uint256, bool) external;
    function lockIncentive() external view returns(uint256);
}

interface IRewardFactory{
    function setAccess(address,bool) external;
    function CreateCrvRewards(uint256,address) external returns(address);
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















contract CurveVoterProxy is Owned {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant mintr = address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);
    address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);

    address public constant escrow = address(0x5f3b5DfEb7B28CDbD7FAba78963EE202a494e2A2);
    address public constant gaugeController = address(0x2F50D538606Fa9EDD2B11E2446BEb18C9D5846bB);
    IFeeDistro public feeDistroDefault = IFeeDistro(0xA464e6DCda8AC41e03616F95f4BC98a13b8922Dc);
    
    address public operator;
    address public depositor;



    constructor(
        address _owner,
        address _operator,
        address _depositor
    ) Owned(_owner) {
        operator = _operator;
        depositor = _depositor;
    }


    modifier onlyOperator() {
        require(msg.sender == operator, "Not operator");
        _;
    }

    modifier onlyDepositor() {
        require(msg.sender == depositor, "Not depositor");
        _;
    }


    function getName() external pure returns (string memory) {
        return "CurveVoterProxy";
    }

    function balanceOfPool(address _gauge) public view returns (uint256) {
        return ICurveGauge(_gauge).balanceOf(address(this));
    }


    function _withdrawSome(address _gauge, uint256 _amount) internal returns (uint256) {
        ICurveGauge(_gauge).withdraw(_amount);
        return _amount;
    }


    function setOperator(address _operator) external onlyOwner {
        operator = _operator;
    }

    function setDepositor(address _depositor) external onlyOwner {
        depositor = _depositor;
    }

    function setFeeDistroDefault(address _fee_distro_default) external onlyOwner {
        feeDistroDefault = IFeeDistro(_fee_distro_default);
    }


    function deposit(address _token, address _gauge) external onlyOperator returns (bool) {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(_token).safeApprove(_gauge, 0);
            IERC20(_token).safeApprove(_gauge, balance);
            ICurveGauge(_gauge).deposit(balance);
        }
        return true;
    }

    function withdraw(address _token, address _gauge, uint256 _amount) public onlyOperator returns (bool) {
        uint256 _balance = IERC20(_token).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_gauge, _amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
        IERC20(_token).safeTransfer(msg.sender, _amount);
        return true;
    }

    function withdrawAll(address _token, address _gauge) external onlyOperator returns (bool) {
        uint256 amount = balanceOfPool(_gauge).add(IERC20(_token).balanceOf(address(this)));
        withdraw(_token, _gauge, amount);
        return true;
    }

    function vote(uint256 _voteId, address _votingAddress, bool _support) external onlyOperator returns (bool) {
        IVoting(_votingAddress).vote(_voteId, _support, false);
        return true;
    }

    function voteGaugeWeight(address _gauge, uint256 _weight) public onlyOperator returns (bool) {
        IVoting(gaugeController).vote_for_gauge_weights(_gauge, _weight);
        return true;
    }

    function voteGaugeWeightMany(address[] memory _gauges, uint256[] memory _weights) external onlyOperator returns (bool) {
        for (uint256 i = 0; i < _gauges.length; i++){
            voteGaugeWeight(_gauges[i], _weights[i]);
        }
        
        return true;
    }

    function claimCrv(address _gauge) public onlyOperator returns (uint256) {
        uint256 _balance = 0;
        try IMinter(mintr).mint(_gauge){
            _balance = IERC20(crv).balanceOf(address(this));
        } catch {

        }

        return _balance;
    }

    function claimCrvMany(address[] memory _gauges) external onlyOperator returns (uint256[] memory balances) {
        for (uint256 i = 0; i < _gauges.length; i++){
           balances[i] = claimCrv(_gauges[i]);
        }
    }

    function claimRewards(address _gauge) public onlyOperator returns (bool) {
        ICurveGauge(_gauge).claim_rewards();
        return true;
    }

    function claimRewardsMany(address[] memory _gauges) external onlyOperator returns (bool) {
        for (uint256 i = 0; i < _gauges.length; i++){
           claimRewards(_gauges[i]);
        }
        return true;
    }

    function claimEverything(address[] memory _gauges) external onlyOperator returns (bool) {
        address p = address(this);
        feeDistroDefault.claim_many([p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p]);

        for (uint256 i = 0; i < _gauges.length; i++){
           claimCrv(_gauges[i]);
           claimRewards(_gauges[i]);
        }
        return true;
    }

    function claimFees(address _distroContract, address _token, uint256 arr_length) public onlyOperator returns (uint256) {
        address p = address(this);
        IFeeDistro(_distroContract).claim_many([p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p, p]);
        uint256 _balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(operator, _balance);
        return _balance;
    }  

    function recoverManyERC20s(address[] memory tokenAddresses, uint256[] memory tokenAmounts, bool withdraw_entire_balance) external onlyOperator { 
        for (uint256 i = 0; i < tokenAddresses.length; i++){
            uint256 balance_to_use = withdraw_entire_balance ? IERC20(tokenAddresses[i]).balanceOf(address(this)) : tokenAmounts[i];
            IERC20(tokenAddresses[i]).safeTransfer(operator, balance_to_use);
        }
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOperator {
        TransferHelper.safeTransfer(address(tokenAddress), msg.sender, tokenAmount);
    }

    function recoverERC20All(address tokenAddress) external onlyOperator {
        uint256 tkn_bal = ERC20(tokenAddress).balanceOf(address(this));
        TransferHelper.safeTransfer(address(tokenAddress), msg.sender, tkn_bal);
    }

    function execute(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOperator returns (bool, bytes memory) {
        (bool success, bytes memory result) = _to.call{value:_value}(_data);

        return (success, result);
    }


    function createLock(uint256 _value, uint256 _unlockTime) external onlyDepositor returns (bool) {
        IERC20(crv).safeApprove(escrow, 0);
        IERC20(crv).safeApprove(escrow, _value);
        ICurveVoteEscrow(escrow).create_lock(_value, _unlockTime);
        return true;
    }

    function increaseAmount(uint256 _value) external onlyDepositor returns (bool) {
        IERC20(crv).safeApprove(escrow, 0);
        IERC20(crv).safeApprove(escrow, _value);
        ICurveVoteEscrow(escrow).increase_amount(_value);
        return true;
    }

    function increaseTime(uint256 _value) external onlyDepositor returns (bool) {
        ICurveVoteEscrow(escrow).increase_unlock_time(_value);
        return true;
    }

    function release() external onlyDepositor returns (bool) {
        ICurveVoteEscrow(escrow).withdraw();
        return true;
    }
}