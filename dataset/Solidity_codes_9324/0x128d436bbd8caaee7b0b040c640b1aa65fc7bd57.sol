
pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _tmpmint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _tmpburn(address account, uint256 amount, uint256 addtotal) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.add(addtotal).sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
}

contract PauserRole is Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

contract Pausable is Context, PauserRole {

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

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract ERC20Pausable is ERC20, Pausable {

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {

        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {

        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {

        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {

        return super.decreaseAllowance(spender, subtractedValue);
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract MinterRole is Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(_msgSender());
    }

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract OwnerRole is Context {

    using Roles for Roles.Role;

    event OwnerAdded(address indexed account);
    event OwnerRemoved(address indexed account);

    Roles.Role private _owners;

    constructor () internal {
        _addOwner(_msgSender());
    }

    modifier onlyOwner() {

        require(isOwner(_msgSender()), "OwnerRole: caller does not have the Owner role");
        _;
    }

    function isOwner(address account) public view returns (bool) {

        return _owners.has(account);
    }

    function addOwner(address account) public onlyOwner {

        _addOwner(account);
    }

    function renounceOwner() public {

        _removeOwner(_msgSender());
    }

    function _addOwner(address account) internal {

        _owners.add(account);
        emit OwnerAdded(account);
    }

    function _removeOwner(address account) internal {

        _owners.remove(account);
        emit OwnerRemoved(account);
    }
}

contract OneEUR is ERC20, ERC20Pausable, OwnerRole, MinterRole {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string private _name; //includes serial number in bonds
    string private _symbol; //includes serial number in bonds
    uint8 private _decimals; //=5
    int32 private _serial; //-1 for 1EUR base token
    uint256 private _bondedSupply; // funds in bonds
    uint32 private _bondPrice; // price of 1EUR bond (6 decimal places), 1000000=1EUR
    uint40 private _bondBuyStart; // start of subscription
    uint40 private _bondBuyEnd; // end of subscription
    uint40 private _bondMature; // maturity date
    string private _www; // web page for more info on how to buy and sell 1EUR

    mapping (address => uint256) private _minterAllowances;
    address[] private _bonds;

    constructor () public {
        _name = "1EUR stablecoin";
        _symbol = "1EUR";
        _decimals = 6;
        _serial =  -1;
    }
    function init(string calldata _newname,string calldata _newsymbol,uint8 _newdecimals,int32 _newserial,uint256 _limit,uint32 _price,uint40 _start, uint40 _end,uint40 _mature) external returns (bool) {

	require(bytes(_name).length == 0);
	_name=_newname;
	_symbol=_newsymbol;
	_decimals=_newdecimals;
	_serial=_newserial;
	_bondPrice=_price;
	_bondBuyStart=_start;
	_bondBuyEnd=_end;
	_bondMature=_mature;
	_addOwner(_msgSender());
	_addMinter(_msgSender());
	_minterApprove(_msgSender(),_limit);
	return true;
    }
    function name() public view returns (string memory) {

        return _name;
    }
    function symbol() public view returns (string memory) {

        return _symbol;
    }
    function decimals() public view returns (uint) {

        return _decimals;
    }
    function serialNumber() public view returns (int) {

        return _serial;
    }
    function circulatingSupply() public view returns (uint) {

        return totalSupply().sub(_bondedSupply);
    }
    function bondPrice() public view returns (uint) {

        return _bondPrice;
    }
    function bondBuyStart() public view returns (uint) {

        return _bondBuyStart;
    }
    function bondBuyEnd() public view returns (uint) {

        return _bondBuyEnd;
    }
    function bondMature() public view returns (uint) {

        return _bondMature;
    }
    function www() public view returns (string memory) {

        return _www;
    }
    function bondAddress(uint256 n) public view returns (address) {

        return _bonds[n];
    }
    function myBond(uint256 n,address owner) public view returns (int) {

	for (uint i=n; i < _bonds.length; i++) {
          OneEUR nbond = OneEUR(address(_bonds[i]));
          if(nbond.balanceOf(owner)>0){
            return int(i);}}
        return -1; // no bonds with assets
    }
    function myMatureBond(uint256 n,address owner) public view returns (int) {
	for (uint i=n; i < _bonds.length; i++) {
          OneEUR nbond = OneEUR(address(_bonds[i]));
          if(nbond.balanceOf(owner)>0 && nbond.bondMature()<block.timestamp){
            return int(i);}}
        return -1; // no mature bond available
    }
    function activeBond(uint256 n) public view returns (int) {
	for (uint i=n; i < _bonds.length; i++) {
          OneEUR nbond = OneEUR(address(_bonds[i]));
          if(nbond.bondBuyStart()<block.timestamp && block.timestamp<nbond.bondBuyEnd()){
            return int(i);}}
        return -1;
    }
    function bondTotalSupply() public view returns (uint256 num,uint256 total) {
	for (num=0; num < _bonds.length; num++) {
          OneEUR nbond = OneEUR(address(_bonds[num]));
          total+=nbond.totalSupply();}
    }
    function bondDetails(uint256 n) public view returns (
          address bondaddress,
          uint256 bondsbought,
          uint256 bondsavailable,
          uint256 bondprice,
          uint256 bondbuystart,
          uint256 bondbuyend,
          uint256 bondmature,
          string memory status ) {
        bondaddress = _bonds[n];
        OneEUR nbond = OneEUR(bondaddress);
        bondsbought = nbond.totalSupply(); 
        bondsavailable = nbond.minterAllowance(address(this)); 
        bondprice = nbond.bondPrice();
        bondbuystart = nbond.bondBuyStart();
        bondbuyend = nbond.bondBuyEnd();
        bondmature = nbond.bondMature();
        if(bondbuystart==0){
          status='error';}
        else if(bondbuystart>block.timestamp){
          status='waiting';}
        else if(bondbuyend>block.timestamp){
          status='active';}
        else if(bondmature>block.timestamp){
          status='immature';}
        else{
          status='mature';}
    }
    function bondAvailable(uint256 n) public view returns (uint256) {
        OneEUR nbond = OneEUR(address(_bonds[n]));
        if(nbond.bondBuyStart()<block.timestamp && block.timestamp<nbond.bondBuyEnd()){
          return nbond.minterAllowance(address(this)); }
        return 0;
    }
    function buyBond(uint256 n, uint256 amount) external whenNotPaused {
        OneEUR nbond = OneEUR(address(_bonds[n]));
        bool success = nbond.wrapTo(_msgSender(),amount,0);
        require(success);
        uint256 price = amount.mul(nbond.bondPrice()).div(1000000); 
        _tmpburn(_msgSender(),price,amount);
        _bondedSupply+=amount;
    }
    function redeemBond(uint256 n) external whenNotPaused {
        OneEUR nbond = OneEUR(address(_bonds[n]));
        uint256 amount = nbond.unwrapAll(_msgSender());
        require(amount>0);
        _tmpmint(_msgSender(), amount);
        _bondedSupply-= amount;
    }
    function setWww(string calldata newwww) external onlyOwner returns (bool) {
    	_www=newwww;
    	return true;
    }
    function deployBond(uint limit,uint price,uint numweeks) external onlyMinter returns (address bondaddress) {
	require(_bondBuyStart==0, "OneEUR: no bonds on bond");
	require(limit>0, "OneEUR: bond size must be > 0");
        require(price<1000000 && price>100000, "OneEUR: discount must be < 90%");
        require(numweeks>3, "OneEUR: bond must mature at least 4 weeks");
        uint start=block.timestamp+1 weeks;
        uint end=start+1 weeks;
        uint mature=end+numweeks*1 weeks;
        _minterApprove(_msgSender(), _minterAllowances[_msgSender()].sub(limit.mul(1000000-price).div(1000000), "OneEUR: bond parameters exceed minterAllowance"));
	bytes20 targetBytes = bytes20(address(this));
	assembly {
	  let clone := mload(0x40)
	  mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
	  mstore(add(clone, 0x14), targetBytes)
	  mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
	  bondaddress := create(0, clone, 0x37)
	}
	emit newBond(address(bondaddress));
	OneEUR nbond = OneEUR(address(bondaddress));
	bool success = nbond.init(string(abi.encodePacked("1EUR Zero-Coupon Bond [",uint2str(_bonds.length),"]")),string(abi.encodePacked("1EURb",uint2str(_bonds.length))),uint8(_decimals),int32(_bonds.length),limit,uint32(price),uint40(start),uint40(end),uint40(mature));
	require(success);
	_bonds.push(address(bondaddress));
    }
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
    function wrapTo(address owner, uint256 amount, uint256 txid) external onlyMinter whenNotPaused returns (bool) {
        require(_bondBuyStart==0 || (_bondBuyStart<block.timestamp && block.timestamp<_bondBuyEnd), "OneEUR: bond subscription not active");
        emit Wrap(owner, txid, amount);
        _mint(owner, amount);
        _minterApprove(_msgSender(), _minterAllowances[_msgSender()].sub(amount, "OneEUR: minted amount exceeds minterAllowance"));
        return true;
    }
    function unwrap(uint256 amount, uint256 ibanhash) external whenNotPaused {
        require(_bondBuyStart==0, "OneEUR: no unwrap on bond");
        emit Unwrap(_msgSender(), ibanhash, amount);
        _burn(_msgSender(), amount);
    }
    function unwrapFrom(address owner, uint256 amount, uint256 ibanhash) external whenNotPaused {
        require(_bondBuyStart==0, "OneEUR: no unwrap on bond");
        emit Unwrap(owner, ibanhash, amount);
        _burnFrom(owner, amount);
    }
    function unwrapAll(address owner) external onlyMinter whenNotPaused returns (uint256 amount) {
        require(_bondBuyStart>0, "OneEUR: this is not a bond");
        require(_bondMature<block.timestamp, "OneEUR: bond not mature yet");
        amount=balanceOf(owner);
        require(amount>0);
        emit Unwrap(owner, 0, amount);
        _burn(owner, amount);
    }
    function minterAllowance(address minter) public view returns (uint256) {
        return _minterAllowances[minter];
    }
    function minterApprove(address minter, uint256 amount) external onlyOwner {
        _minterApprove(minter, amount);
    }
    function increaseMinterAllowance(address minter, uint256 addedValue) external onlyOwner {
        _minterApprove(minter, _minterAllowances[minter].add(addedValue));
    }
    function decreaseMinterAllowance(address minter, uint256 subtractedValue) external onlyOwner returns (bool) {
        _minterApprove(minter, _minterAllowances[minter].sub(subtractedValue, "OneEUR: decreased minterAllowance below zero"));
        return true;
    }
    function _minterApprove(address minter, uint256 amount) internal {
        require(isMinter(minter), "OneEUR: minter approve for non-minting address");
        _minterAllowances[minter] = amount;
        emit MinterApproval(minter, amount);
    }
    function isMinter(address account) public view returns (bool) {
        return MinterRole.isMinter(account) || isOwner(account);
    }
    function removeMinter(address account) external onlyOwner {
        _minterApprove(account, 0);
        _removeMinter(account);
    }
    function isPauser(address account) public view returns (bool) {
        return PauserRole.isPauser(account) || isOwner(account);
    }
    function removePauser(address account) external onlyOwner {
        _removePauser(account);
    }
    function exec(address _to,bytes calldata _data) payable external onlyOwner returns (bool, bytes memory) {
        return _to.call.value(msg.value)(_data);
    }
    function reclaimEther() external onlyOwner {
        _msgSender().transfer(address(this).balance);
    }
    function reclaimToken(IERC20 _token) external onlyOwner {
        uint256 balance = _token.balanceOf(address(this));
        _token.safeTransfer(_msgSender(), balance);
    }

    event Wrap(address indexed to, uint256 indexed txid, uint256 amount);
    event Unwrap(address indexed from, uint256 indexed ibanhash, uint256 amount);
    event MinterApproval(address indexed minter, uint256 amount);
    event newBond(address bondaddress);
}