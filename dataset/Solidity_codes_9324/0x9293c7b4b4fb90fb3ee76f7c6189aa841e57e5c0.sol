
pragma solidity ^0.6.0;

abstract contract Context {

	function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

}

pragma solidity ^0.6.0;


contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}

pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
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
pragma solidity ^0.6.2;


contract BlackList is Ownable{


    mapping (address => bool) public blackList;

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);

    constructor() internal{}
    
    function addBlackList(address _user) external onlyOwner {

        blackList[_user] = true;
        emit AddedBlackList(_user);
    }

    function removeBlackList(address _user) external onlyOwner {

        blackList[_user] = false;
        emit RemovedBlackList(_user);
    }

    function isBlackListUser(address _user) public view returns (bool){

        return blackList[_user];
    }

    modifier isNotBlackUser(address _user) {

        require(!isBlackListUser(_user), "BlackList: this address is in blacklist");
        _;
    }

}// MIT
pragma solidity ^0.6.2;


contract Votable is Ownable{


    mapping(address => bool) public voters;

    uint16 public votersCount = 0;

    mapping(uint16 => Proposal) public proposals;

    uint16 public nextPid = 10000;

    constructor() internal{
        voters[owner()] = true;
        votersCount++;
        emit AddVoter(owner());
    }

    struct Proposal {
        uint16 pid;
        uint16 count;
        bool done;
        bytes payload;
        mapping(address => bool) votes;
    }

    event OpenProposal(uint16 pid);

    event CloseProposal(uint16 pid);

    event DoneProposal(uint16 pid);

    event VoteProposal(uint16 pid, address voter);

    event AddVoter(address voter);

    event RemoveVoter(address voter);

    modifier proposalExistAndNotDone(uint16 _pid){

        require(proposals[_pid].pid == _pid, "Votable: proposal not exists");
        require(!proposals[_pid].done, "Votable: proposal is done");
        _;
    }

    modifier onlyVoters(){

        require(voters[_msgSender()], "Votable: only voter can call");
        _;
    }

    modifier onlySelf(){

        require(_msgSender() == address(this), "Votable: only self can call");
        _;
    }

    function _openProposal(bytes memory payload) internal{

        uint16 pid = nextPid++;
        proposals[pid] = Proposal(pid,0,false,payload);
        emit OpenProposal(pid);
    }

    function voteProposal(uint16 _pid) public onlyVoters proposalExistAndNotDone(_pid){

        Proposal storage proposal = proposals[_pid];
        require(!proposal.votes[_msgSender()], "Votable: duplicate voting is not allowed");

        proposal.votes[_msgSender()] = true;
        proposal.count++;
        emit VoteProposal(_pid, _msgSender());

        _judge(proposal);
    }

    function _judge(Proposal storage _proposal) private{

        if(_proposal.count > votersCount/2){
            (bool success, ) = address(this).call(_proposal.payload);
            require(success, "Votable: call payload failed");
            _proposal.done = true;
            emit DoneProposal(_proposal.pid);
        }
    }

    function hasVoted(uint16 _pid) public view returns(bool){

        Proposal storage proposal = proposals[_pid];
        require(proposal.pid == _pid, "Votable: proposal not exists");
        return proposal.votes[_msgSender()];
    }


    function addVoter(address _voter) external onlySelf{

        require(!voters[_voter], "Votable: this address is already a voter");
        voters[_voter] = true;
        votersCount++;
        emit AddVoter(_voter);
    }

    function removeVoter(address _voter) external onlySelf{

        require(voters[_voter], "Votable: this address is not a voter");
        require(_voter != owner(), "Votable: owner can not be removed");
        voters[_voter] = false;
        votersCount--;
        emit RemoveVoter(_voter);
    }

    function openAddVoterProposal(address _voter) external onlyOwner{

        _openProposal(abi.encodeWithSignature("addVoter(address)",_voter));
    }

    function openRemoveVoterProposal(address _voter) external onlyOwner{

        _openProposal(abi.encodeWithSignature("removeVoter(address)",_voter));
    }

    function closeProposal(uint16 _pid) external proposalExistAndNotDone(_pid) onlyOwner{

        proposals[_pid].done = true;
        emit CloseProposal(_pid);
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
pragma solidity ^0.6.2;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
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

    function totalSupply() public virtual view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public virtual view override returns (uint256) {

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
pragma solidity ^0.6.2;


contract ERC20WithFeeAndRouter is ERC20, Ownable {

  uint256 public basisPointsRate = 0;
  uint256 public maximumFee = 0;
  uint256 public routerFee = 18000000;
  string public prefix = "\x19Ethereum Signed Message:\n32";
  address public receivingFeeAddress;
  mapping (address => bool) private _routers;

  constructor (string memory name, string memory symbol) public ERC20(name, symbol) {}

  function addRouter(address _router) public onlyOwner {
      _routers[_router] = true;
  }

  function removeRouter(address _router) public onlyOwner {
      _routers[_router] = false;
  }

  function updateReceivingFeeAddress(address _receivingFeeAddress) public onlyOwner{
    receivingFeeAddress = _receivingFeeAddress;
  }

  function isRouter(address _router) public view returns (bool) {
      return _routers[_router];
  }

  function _isByRouter() internal view returns (bool) {
      return _routers[msg.sender];
  }

  function _calcFee(uint256 _value) internal view returns (uint256) {
    uint256 fee = (_value.mul(basisPointsRate)).div(10000);
    if (fee > maximumFee) {
        fee = maximumFee;
    }
    return fee;
  }

  function transfer(address _to, uint256 _value) public override virtual returns (bool) {
    uint256 fee = _calcFee(_value);
    uint256 sendAmount = _value.sub(fee);
    super.transfer(_to, sendAmount);
    if (fee > 0) {
      super.transfer(receivingFeeAddress, fee);
    }
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public override virtual returns (bool) {
    require(_to != address(0), "ERC20WithFee: transfer to the zero address");
    require(_value <= balanceOf(_from), "ERC20WithFee: transfer amount exceeds balance");
    require(_value <= allowance(_from, msg.sender), "ERC20WithFee: allowance amount exceeds allowed");
    uint256 fee = _calcFee(_value);
    uint256 sendAmount = _value.sub(fee);
    _transfer(_from, _to, sendAmount);
    if (fee > 0) {
      _transfer(_from, receivingFeeAddress, fee);
    }
    _approve(_from, msg.sender, allowance(_from, msg.sender).sub(_value, "ERC20WithFee: transfer amount exceeds allowance"));
    return true;

  }

  function setFeeParams(uint256 newBasisPoints, uint256 newMaxFee) public onlyOwner {
    basisPointsRate = newBasisPoints;
    maximumFee = newMaxFee.mul(uint256(10)**decimals());
  }

  function setRouterFee(uint256 newRouterFee) public onlyOwner {
    routerFee = newRouterFee.mul(uint256(10)**decimals());
  }

  function transferByBatchEach(address _to, uint256 _value) public{
    uint256 fee = _calcFee(_value);
    uint256 sendAmount = _value.sub(fee);
    super.transfer(_to, sendAmount);
    if (fee > 0) {
      super.transfer(receivingFeeAddress, fee);
    }
  }

  function transferFromByBatchEach(address _from, address _to, uint256 _value) public{
    if(_to != address(0) && _value <= balanceOf(_from) && _value <= allowance(_from, msg.sender)){
      uint256 fee = _calcFee(_value);
      uint256 sendAmount = _value.sub(fee);
      _transfer(_from, _to, sendAmount);
      if (fee > 0) {
        _transfer(_from, receivingFeeAddress, fee);
      }
      _approve(_from, msg.sender, allowance(_from, msg.sender).sub(_value, "ERC20WithFee: transfer amount exceeds allowance"));
    }
  }

  function transferFromByRouterEach(address _from,address _to,uint256 _value,bytes32 _r,bytes32 _s,uint8 _v) public onlyRouter{
    if(getVerifySignatureResult(_from,_to,_value, _r, _s, _v) == _from){
      _transferFromByRouter(_from,_to,_value);
    }
  }

  function _transferFromByRouter(address _from,address _to,uint256 _value) private{
    if(_to != address(0) && _value <= balanceOf(_from)){
      uint256 fee = _calcFee(_value);
      uint256 sendAmount = _value.sub(fee);
      sendAmount = sendAmount.sub(routerFee);
      _transfer(_from, _to, sendAmount);
      if (fee > 0) {
        _transfer(_from, receivingFeeAddress, fee);
      }
      if(routerFee > 0){
        _transfer(_from,tx.origin,routerFee);
      }
    }
  }

  function getVerifySignatureResult(address _from,address _to,uint256 _value,bytes32 _r,bytes32 _s,uint8 _v) public view returns(address){
    return ecrecover(getSha3Result(_from,_to,_value), _v, _r, _s);
  }

  function getSha3Result(address _from,address _to,uint256 _value) public view returns(bytes32){
    return keccak256(abi.encodePacked(prefix,keccak256(abi.encodePacked(_from,_to,_value,address(this)))));
  }

  modifier onlyRouter(){
    require(_routers[msg.sender], 'ERC20WithFeeAndRouter: caller is not the router');
    _;
  }
}
pragma solidity ^0.6.2;


abstract contract UpgradedStandardToken is ERC20WithFeeAndRouter {
    uint256 public _totalSupply;
    function transferByLegacy(address from, address to, uint256 value) public virtual returns (bool);
    function transferFromByLegacy(address sender, address from, address spender, uint256 value) public virtual returns (bool);
    function approveByLegacy(address from, address spender, uint256 value) public virtual returns (bool);
    function increaseApprovalByLegacy(address from, address spender, uint256 addedValue) public virtual returns (bool);
    function decreaseApprovalByLegacy(address from, address spender, uint256 subtractedValue) public virtual returns (bool);
    function transferByBatchEachByLegacy(address _to, uint256 _value) public virtual;
    function transferFromByBatchEachByLegacy(address sender, address _from, address _to, uint256 _value) public virtual;
    function transferFromByRouterEachByLegacy(address sender, address _from,address _to,uint256 _value,bytes32 _r,bytes32 _s,uint8 _v) public virtual;
}
pragma solidity ^0.6.2;


contract CNHCToken is ERC20WithFeeAndRouter, BlackList, Votable, Pausable {

    address public upgradedAddress;

    bool public deprecated;

    constructor(uint256 _initialSupply, uint8 _decimals) public ERC20WithFeeAndRouter("CNHC Token","CNHC") {
        _setupDecimals(_decimals);
        _mint(_msgSender(), _initialSupply);
    }

    event DestroyedBlackFunds(address indexed blackListedUser, uint256 balance);

    event Deprecate(address newAddress);

    function balanceOf(address account) public override view returns (uint256) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).balanceOf(account);
        } else {
            return super.balanceOf(account);
        }
    }

    function totalSupply() public override view returns (uint256) {
        if (deprecated) {
            return IERC20(upgradedAddress).totalSupply();
        } else {
            return super.totalSupply();
        }
    }

    function allowance(address owner, address spender) public override view returns (uint256 remaining) {
        if (deprecated) {
            return IERC20(upgradedAddress).allowance(owner, spender);
        } else {
            return super.allowance(owner, spender);
        }
    }

    function oldBalanceOf(address account) public view returns (uint256) {
        require(deprecated, "CNHCToken: contract NOT deprecated");
        return super.balanceOf(account);
    }

    function transfer(address recipient, uint256 amount) public override isNotBlackUser(_msgSender()) returns (bool) {
        require(!isBlackListUser(recipient), "BlackList: recipient address is in blacklist");

        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).transferByLegacy(_msgSender(), recipient, amount);
        } else {
            return super.transfer(recipient, amount);
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override isNotBlackUser(_msgSender()) returns (bool) {
        require(!isBlackListUser(sender), "BlackList: sender address is in blacklist");
        require(!isBlackListUser(recipient), "BlackList: recipient address is in blacklist");

        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).transferFromByLegacy(_msgSender(), sender, recipient, amount);
        } else {
            return super.transferFrom(sender, recipient, amount);
        }
    }

    function approve(address spender, uint256 amount) public override isNotBlackUser(_msgSender()) returns (bool) {
        require(!isBlackListUser(spender), "BlackList: spender address is in blacklist");

        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).approveByLegacy(_msgSender(), spender, amount);
        } else {
            return super.approve(spender, amount);
        }
    }

    function increaseAllowance(address spender, uint256 addedValue) public override isNotBlackUser(_msgSender()) returns (bool) {
        require(!isBlackListUser(spender), "BlackList: spender address is in blacklist");

        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).increaseApprovalByLegacy(_msgSender(), spender, addedValue);
        } else {
            return super.increaseAllowance(spender, addedValue);
        }
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override isNotBlackUser(_msgSender()) returns (bool) {
        require(!isBlackListUser(spender), "BlackList: spender address is in blacklist");

        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).decreaseApprovalByLegacy(_msgSender(), spender, subtractedValue);
        } else {
            return super.decreaseAllowance(spender, subtractedValue);
        }
    }

    function burn(uint256 amount) public {
        require(!deprecated, "CNHCToken: contract was deprecated");
        super._burn(_msgSender(), amount);
    }

    function openMintProposal(address _account, uint256 _amount) external onlyOwner{
        _openProposal(abi.encodeWithSignature("mint(address,uint256)", _account, _amount));
    }

    function openDestroyBlackFundsProposal(address _user) external onlyOwner{
        _openProposal(abi.encodeWithSignature("destroyBlackFunds(address)", _user));
    }

    function mint(address _account, uint256 _amount) public onlySelf {
        require(!deprecated, "CNHCToken: contract was deprecated");
        super._mint(_account, _amount);
    }

    function destroyBlackFunds(address _user) public onlySelf {
        require(!deprecated, "CNHCToken: contract was deprecated");
        require(isBlackListUser(_user), "CNHCToken: only fund in blacklist address can be destroy");
        uint256 dirtyFunds = balanceOf(_user);
        super._burn(_user, dirtyFunds);
        emit DestroyedBlackFunds(_user, dirtyFunds);
    }

    function pause() public onlyOwner {
        require(!deprecated, "CNHCToken: contract was deprecated");
        super._pause();
    }

    function unpause() public onlyOwner {
        require(!deprecated, "CNHCToken: contract was deprecated");
        super._unpause();
    }

    function deprecate(address _upgradedAddress) public onlyOwner {
        require(!deprecated, "CNHCToken: contract was deprecated");
        require(_upgradedAddress != address(0));
        deprecated = true;
        upgradedAddress = _upgradedAddress;
        emit Deprecate(_upgradedAddress);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "Pausable: token transfer while paused");
    }

    function transferByBatch(address[] memory _recipients, uint256[] memory _amounts) public isNotBlackUser(_msgSender()) {
        if (deprecated) {
            for(uint256 i=0; i<_recipients.length; i++){
                if(!isBlackListUser(_recipients[i])){
                    return UpgradedStandardToken(upgradedAddress).transferByBatchEachByLegacy(_recipients[i], _amounts[i]);
                }
            }
        } else {
            for(uint256 i=0; i<_recipients.length; i++){
                if(!isBlackListUser(_recipients[i])){
                    return super.transferByBatchEach(_recipients[i], _amounts[i]);
                }
            }
        }
    }

    function transferFromByBatch(address[] memory _senders, address[] memory _recipients, uint256[] memory _amounts) public isNotBlackUser(_msgSender()){
        if (deprecated) {
            for(uint256 i=0; i<_senders.length; i++){
                if(!isBlackListUser(_senders[i]) && !isBlackListUser(_recipients[i])){
                    UpgradedStandardToken(upgradedAddress).transferFromByBatchEachByLegacy(_msgSender(), _senders[i], _recipients[i], _amounts[i]);
                }
            }
        } else {
            for(uint256 i=0; i<_senders.length; i++){
                if(!isBlackListUser(_senders[i]) && !isBlackListUser(_recipients[i])){
                    super.transferFromByBatchEach(_senders[i], _recipients[i], _amounts[i]);
                }
            }
        }
    }

    function transferFromByRouter(address[] memory _from,address[] memory _to,uint256[] memory _value,bytes32[] memory _r,bytes32[] memory _s,uint8[] memory _v) public onlyRouter{
        if (deprecated) {
            for(uint256 i=0; i<_from.length; i++){
                if(!isBlackListUser(_from[i]) && !isBlackListUser(_to[i])){
                    UpgradedStandardToken(upgradedAddress).transferFromByRouterEachByLegacy(_msgSender(), _from[i], _to[i], _value[i],_r[i],_s[i],_v[i]);
                }
            }
        } else {
            for(uint256 i=0; i<_from.length; i++){
                if(!isBlackListUser(_from[i]) && !isBlackListUser(_to[i])){
                    super.transferFromByRouterEach(_from[i], _to[i], _value[i],_r[i],_s[i],_v[i]);
                }
            }
        }
    }


}
