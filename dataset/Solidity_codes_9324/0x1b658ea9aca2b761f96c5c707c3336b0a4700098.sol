
pragma solidity 0.5.12;
pragma experimental ABIEncoderV2;

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

contract Context {

    constructor () internal { }

    function _msgSender() internal view  returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view  returns (bytes memory) {

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

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view  returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view  returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public   returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view   returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public   returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public   returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal  {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal  {

        require(account != address(0), "ERC20: mint to the zero address");


        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal  {

        require(account != address(0), "ERC20: burn from the zero address");


        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal  {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

   
}

contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public  {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public  {

        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
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

contract ERC20Mintable is ERC20, MinterRole {

    function mint(address account, uint256 amount) public onlyMinter returns (bool) {

        _mint(account, amount);
        return true;
    }
}

contract DyDAI is ERC20,ERC20Burnable,ERC20Mintable {

    string public constant name = "DyDAI Token";
    string public constant symbol = "DyDAI";
    uint8 public constant decimals = 18;
    constructor() public 
    {

    }
}
library Account {

    struct Info {
        address owner;
        uint256 number;
    }
}

library Types {

    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }

    enum AssetDenomination {
        Wei, // the amount is denominated in wei
        Par  // the amount is denominated in par
    }

    enum AssetReference {
        Delta, // the amount is given as a delta from the current value
        Target // the amount is given as an exact number to end up at
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }
}

library Actions {

    enum ActionType {
        Deposit,   // supply tokens
        Withdraw  // borrow tokens TODO why comment is borrow?
    }

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        Types.AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }
}

contract SoloMargin {

    struct OperatorArg {
        address operator;
        bool trusted;
    }
    
    function operate(Account.Info[] calldata accounts, Actions.ActionArgs[] calldata actions) external;

    function getAccountWei(Account.Info calldata account, uint256 marketId) external view returns (Types.Wei memory);

    function setOperators(OperatorArg[] calldata args) external;

    
}

contract DyDAIImpl {

    using SafeMath for uint256;

    DyDAI internal DyDAItoken;
    address internal sm;
    ERC20 internal DAIToken;
    
    Account.Info[] internal accounts;
    Actions.ActionArgs[] internal actions;
  
    uint256 private _rate=1000000000000000000; 
    
    address payable public  owner;

    modifier onlyOwner() {

        require (msg.sender == owner);
        _;
    }

    constructor (address DyDAItokenAddr,address DAITokenAddr,address soloMargin) public {
        owner = msg.sender;
        require(soloMargin != address(0), "soloMargin is the zero address");
        require(DyDAItokenAddr != address(0), "DyDAItoken is the zero address");
        require(DAITokenAddr != address(0), "DAIToken is the zero address");
        sm=soloMargin;
        DyDAItoken = DyDAI(DyDAItokenAddr);
        DAIToken = ERC20(DAITokenAddr);
    }
    
    function () external payable {  //fallback function
        
    }
  
    function token() public view returns (address) {

        return address(DyDAItoken);
    }

    function rate() public view returns (uint256) {

        return _rate;
    }
    
    function updateRate() public {

        uint256 totalDyDAISupply=totalDyDAIMinted();
        uint256 totalDAIBalance=contractDAIBalance();
        if(totalDyDAISupply>0 && totalDAIBalance>0){
           _rate=(totalDAIBalance.mul(10**18)).div(totalDyDAISupply);
        }
        else if(totalDyDAISupply==0 || totalDAIBalance==0){
          _rate=1000000000000000000;
        }
        rate();
    }
    
    function totalDyDAIMinted() public view returns(uint256){

        return DyDAItoken.totalSupply();
    }
    
    function contractDAIBalance() public view returns(uint256){

         Account.Info memory contractAccount =Account.Info({
            owner:address(this),
            number:0
        });
        return SoloMargin(sm).getAccountWei(contractAccount,3).value;
    }

    function _preValidateData(address beneficiary, uint256 Amount) internal pure 
    {

        require(beneficiary != address(0), "Beneficiary is the zero address");
        require(Amount != 0, "Amount is 0");
    }
    
    function buyTokens(uint256 DAIAmount) external   
    {

        address sender= msg.sender;
        _preValidateData(sender,DAIAmount);
        require(DAIToken.balanceOf(sender)>=DAIAmount,"Insufficient Balance");
        DAIToken.transferFrom(sender,address(this),DAIAmount);
        DAIToken.approve(sm,DAIAmount);
        uint256 allowance = DAIToken.allowance(address(this), sm);
        require(allowance>=DAIAmount,"Contract not allowed to spend required DAI Amount");
        
        updateRate();
        uint256 tokens = (DAIAmount.mul(10**18)).div(_rate);

        operate(address(this),DAIAmount,true);
        require(ERC20Mintable(address(token())).mint(sender, tokens),"Minting failed"); //Minting DyDAI Token
    }
    
    
    function sellTokens(uint256 tokenAmount) external 
    {

        address sender= msg.sender;
        _preValidateData(sender,tokenAmount);
        require(DyDAItoken.balanceOf(sender)>=tokenAmount,"Insufficient Balance");
        uint256 burnallowance = DyDAItoken.allowance(sender, address(this));
        require(burnallowance>=tokenAmount,"Insufficient Burn Allowance");
        updateRate();
        DyDAItoken.burnFrom(sender,tokenAmount);
        uint256 initialDAIAmount=(tokenAmount.mul(_rate)).div(10**18);// calculate dai amount to be return
        operate(address(this),initialDAIAmount,false);
        uint256 finalDAIAmount=(initialDAIAmount.div(1000)).mul(995);//returning dai to user after deducting 0.5% fees
        DAIToken.transfer(sender,finalDAIAmount);
    }

    function operate(address user, uint256 amount, bool isDeposit) internal
    {

        bytes memory data;
        Account.Info memory account =Account.Info({
            owner:user,
            number:0
        });
        Actions.ActionArgs memory action = Actions.ActionArgs({
            actionType: isDeposit ? Actions.ActionType.Deposit : Actions.ActionType.Withdraw,
            amount: Types.AssetAmount({
                sign: isDeposit,
                denomination: Types.AssetDenomination.Wei,
                ref: Types.AssetReference.Delta,
                value: amount
            }),
            primaryMarketId: 3,
            otherAddress: user,
            accountId: 0,
            secondaryMarketId: 0,
            otherAccountId: 0,
            data: data
        });

        if (accounts.length > 0) {
            accounts[0] = account;
            actions[0] = action;
        } else {
            accounts.push(account);
            actions.push(action);
        }

        SoloMargin(sm).operate(accounts, actions);
    }
    
    function withdrawDAI() onlyOwner external returns(bool) 
    {

        uint256 Balance=DAIToken.balanceOf(address(this));
        require(Balance>0);
        DAIToken.transfer(owner,Balance);
    }
    
    function kill() external onlyOwner {    //self destruct the code and transfer all contract balance to owner

        selfdestruct(owner);
    }
}