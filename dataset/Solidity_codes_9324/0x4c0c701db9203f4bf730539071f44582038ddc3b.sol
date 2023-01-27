

pragma solidity 0.5.15;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity 0.5.15;


contract ERC20 {

    using SafeMath for uint256;

    string public name;
    string public symbol;
    string public desc;
    uint8 public decimals;

    mapping (address => uint256) _balances;

    mapping (address => mapping (address => uint256)) _allowances;

    uint256 _totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed TokenOwner, address indexed spender, uint256 value);

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address TokenOwner, address spender) public view returns (uint256) {

        return _allowances[TokenOwner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        require(_allowances[sender][msg.sender] >= amount, "ERC20: Not enough in deligation");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: Not Enough balance");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address TokenOwner, address spender, uint256 value) internal {

        require(TokenOwner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[TokenOwner][spender] = value;
        emit Approval(TokenOwner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}


pragma solidity 0.5.15;

contract Owner {


    address public OwnerAddress;

    modifier isOwner(){

        require( msg.sender == OwnerAddress);
        _;
    }

    function changeOwner ( address _newAddress )
        isOwner
        public
        returns ( bool )
    {
        OwnerAddress = _newAddress;
        return true;
    }

}


pragma solidity 0.5.15;



contract IBTCToken is ERC20 , Owner{


    address public TAddr;

    modifier isTreasury(){

        require(msg.sender == TAddr);
        _;
    }

    constructor(  )
        public
    {
        name = "IBTC Blockchain";
        symbol = "IBTC";
        desc = "IBTC Blockchain";
        decimals = 18;
        OwnerAddress = msg.sender;
    }

    function setTreasury ( address _TAddres )
        isOwner
        public
        returns ( bool )
    {
        TAddr = _TAddres;
        return true;
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function mint(address recipient, uint256 amount)
        isTreasury
        public
        returns (bool result )
    {

        _mint( recipient , amount );
        result = true;
    }

    function transfer(address recipient, uint256 amount)
        public
        returns (bool result )
    {

        _transfer(msg.sender, recipient , amount );
        result = true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        require(_allowances[sender][msg.sender] >= amount, "ERC20: Not enough in deligation");
        _transfer(msg.sender, recipient , amount );
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }


    function allowance(address TokenOwner, address spender) public view returns (uint256) {

        return _allowances[TokenOwner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

}


pragma solidity 0.5.15;


contract Treasury_ds is Owner {

    using SafeMath for uint256;

    bool public contractState;

    IBTCToken Token;

    address public TokenAddr;

    address payable public Owner1;

    address payable public Owner2;

    address masterAddr;

    uint256 public Rate;

    bool public enabled;

    mapping ( uint256 => LLimit ) public Levels;

    struct LLimit{
        uint256 percent;
        uint256 salesLimit;
        uint256 bonus;
    }

    uint256 public MaxLevel;

    mapping ( address => address ) public PCTree;

    mapping ( address => userData ) public userLevel;

    struct userData{
        uint256 level;
        uint256 sales;
        uint256 share;
        uint256 bonus;
    }

    modifier isInActive(){

        require(contractState == false);
        _;
    }

    modifier isActive(){

        require(contractState == true);
        _;
    }

    modifier isSameLength ( uint256 _s1 , uint256 _s2 ){

        require(_s1 == _s2);
        _;
    }

    modifier isVaildClaim( uint256 _amt ){

        require( userLevel[msg.sender].share >= _amt );
        _;
    }

    modifier isVaildReferer( address _ref ){

        require( userLevel[_ref].level != 0 );
        _;
    }

    modifier isSaleClose ( uint256 _amt ){

        require( enabled == true );
        _;
    }

    modifier isValidTOwner(){

        require(( Owner1 == msg.sender ) || (Owner2 == msg.sender));
        _;
    }

    event puchaseEvent( address indexed _buyer , address indexed _referer , uint256 _value , uint256 _tokens );

    event claimEvent( address indexed _buyer ,  uint256 _value , uint256 _pendingShare );

    event eventSetAccount( address indexed _child , address indexed _parent , uint256 _sales , uint256 _bonus , uint256 _level );
}


pragma solidity 0.5.15;


contract Treasury is Treasury_ds{



    constructor( address _TAddr )
        public
    {
        Token = IBTCToken( _TAddr );
        TokenAddr = _TAddr;
        OwnerAddress = msg.sender;
        contractState = false;
    }

    function setLevels( uint256[] memory _percent , uint256[] memory _salesLimit , uint256[] memory _bonus )
        public
        isSameLength( _salesLimit.length , _percent.length )
        isInActive
        isOwner
    {

        MaxLevel = _salesLimit.length;
        for (uint i=0; i<_salesLimit.length; i++) {
            Levels[i+1] = LLimit( _percent[i] ,_salesLimit[i] , _bonus[i] );
        }
    }

    function setAccount ( address _child , address _parent , uint256 _sales )
        isInActive
        isOwner
        public
        returns ( bool )
    {
        PCTree[_child] = _parent;
        userLevel[ _child ].sales = _sales;
        for ( uint i= 1 ; i <= MaxLevel ; i++) {
            if( Levels[i].salesLimit < _sales ){
                userLevel[ _child ].bonus = Levels[i].bonus;
                userLevel[ _child ].level = i;
            }
        }
        emit eventSetAccount( _child , _parent , _sales , userLevel[ _child ].bonus , userLevel[ _child ].level );
        return true;
    }

    function setupTreasury ( uint256 _rate , address payable _owner1 , address payable _owner2 )
        isInActive
        isOwner
        public
        returns ( bool )
    {
        enabled = true;
        Rate = _rate;
        masterAddr = address(this);
        PCTree[masterAddr] = address(0);
        Owner1 = _owner1;
        Owner2 = _owner2;
        userLevel[masterAddr].level = MaxLevel;
        contractState = true;
        return true;
    }

    function calcRate ( uint256 _value )
        public
        view
        returns ( uint256 )
    {
        return _value.mul( 10**18 ).div( Rate );
    }

    function LoopFx ( address _addr , uint256 _token ,  uint256 _value , uint256 _shareRatio )
        internal
        returns ( uint256 value )
    {
        userLevel[ _addr ].sales = userLevel[ _addr ].sales.add( _token );
        if( _shareRatio < Levels[ userLevel[ _addr ].level ].percent ){
            uint256 diff = Levels[ userLevel[ _addr ].level ].percent.sub(_shareRatio);
            userLevel[ _addr ].share = userLevel[ _addr ].share.add( _value.mul(diff).div(10000) );
            value = Levels[ userLevel[ _addr ].level ].percent;
        }else if( _shareRatio == Levels[ userLevel[ _addr ].level ].percent ){
            value = Levels[ userLevel[ _addr ].level ].percent;
        }
        return value;
    }

    function LevelChange ( address _addr )
        internal
    {
        uint256 curLevel = userLevel[_addr ].level;
        while( curLevel <= MaxLevel){
            if( ( userLevel[ _addr ].sales < Levels[ curLevel ].salesLimit ) ){
                break;
            }else{
                userLevel[_addr].bonus = Levels[ curLevel ].bonus;
                userLevel[_addr ].level = curLevel;
            }
            curLevel = curLevel.add(1);
        }
    }

    function purchase ( address _referer )
        isActive
        isVaildReferer( _referer )
        payable
        public
        returns ( bool )
    {
        address Parent;
        uint256 cut = 0;
        uint256 tokens = calcRate(msg.value);
        uint256 lx = 0;
        bool overflow = false;
        iMint( msg.sender , tokens);
        if( userLevel[ msg.sender ].level == 0 ){
            userLevel[ msg.sender ].level = 1;
        }
        if( PCTree[msg.sender] == address(0)){
            Parent = _referer;
            PCTree[msg.sender] = Parent;
        }else{
            Parent = PCTree[msg.sender];
        }
        while( lx < 100 ){
            lx = lx.add(1);
            cut = LoopFx( Parent , tokens , msg.value , cut );
            LevelChange( Parent );
            if( PCTree[ Parent ] == address(0)){
                break;
            }
            Parent = PCTree[ Parent ];
            if( lx == 100){
                overflow = true;
            }
        }
        if( overflow ){
            cut = LoopFx( masterAddr , tokens , msg.value , cut );
        }
        emit puchaseEvent( msg.sender , PCTree[msg.sender] , msg.value , tokens );
        return true;
    }

    function iMint ( address _addr , uint256 _value )
        isSaleClose( _value )
        internal
    {
        Token.mint( _addr , _value );
    }

    function claim (uint256 _amt)
        isActive
        isVaildClaim( _amt )
        payable
        public
        returns ( bool )
    {
        userLevel[ msg.sender ].share = userLevel[ msg.sender ].share.sub( _amt );
        Token.mint( msg.sender , userLevel[ msg.sender ].bonus );
        userLevel[ msg.sender ].bonus = 0;
        msg.sender.transfer( _amt );
        emit claimEvent( msg.sender , _amt , userLevel[ msg.sender ].share );
        return true;
    }

    function claimOwner ()
        isActive
        isValidTOwner
        public
        payable
        returns ( bool )
    {
        uint256 _amt  = userLevel[ address(this) ].share.div(2);
        userLevel[ address(this) ].share = 0;
        Owner1.transfer( _amt );
        Owner2.transfer( _amt );
        emit claimEvent( Owner1 , _amt , userLevel[ address(this) ].share );
        emit claimEvent( Owner2 , _amt , userLevel[ address(this) ].share );
        return true;
    }

    function setRate ( uint256 _rate )
        isOwner
        public
        returns ( bool )
    {
        Rate = _rate;
        return true;
    }

    function enableSales ( )
        isOwner
        public
        returns ( bool )
    {
        enabled = true;
        return true;
    }
    function disableSales ( )
        isOwner
        public
        returns ( bool )
    {
        enabled = false;
        return true;
    }

    function viewStatus( address _addr )
        view
        public
        returns ( uint256 _level , uint256 _sales , uint256 _claim , uint256 _bonus )
    {

        _level = userLevel[ _addr ].level;
        _sales = userLevel[ _addr ].sales;
        _claim = userLevel[ _addr ].share;
        _bonus = userLevel[ _addr ].bonus;
    }

    function checkRef ( address _ref)
        public
        view
        returns ( bool )
    {
        return ( userLevel[_ref].level != 0 );
    }

}