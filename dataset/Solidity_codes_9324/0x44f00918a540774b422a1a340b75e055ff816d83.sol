pragma solidity 0.6.4;

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
pragma solidity 0.6.4;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);//from address(0) for minting

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity 0.6.4;

interface HEX {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);//from address(0) for minting

    event Approval(address indexed owner, address indexed spender, uint256 value);

   function stakeStart(uint256 newStakedHearts, uint256 newStakedDays) external;

   function stakeEnd(uint256 stakeIndex, uint40 stakeIdParam) external;

   function stakeCount(address stakerAddr) external view returns (uint256);

   function stakeLists(address owner, uint256 stakeIndex) external view returns (uint40, uint72, uint72, uint16, uint16, uint16, bool);

   function currentDay() external view returns (uint256);

   function dailyDataRange(uint256 beginDay, uint256 endDay) external view returns (uint256[] memory);

   function globalInfo() external view returns (uint256[13] memory);


}
pragma solidity 0.6.4;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}//HEXMONEY.sol

pragma solidity 0.6.4;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface UniswapFactoryInterface {

    function createExchange(address token) external returns (address exchange);

    function getExchange(address token) external view returns (address exchange);

    function getToken(address exchange) external view returns (address token);

    function getTokenWithId(uint256 tokenId) external view returns (address token);

    function initializeFactory(address template) external;

}

interface UniswapExchangeInterface {

    function tokenAddress() external view returns (address token);

    function factoryAddress() external view returns (address factory);

    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);

    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);

    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);

    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);

    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);

    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);

    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);

    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);

    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);

    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);

    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);

    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);

    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);

    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);

    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);

    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);

    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);

    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);

    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);

}


contract TokenEvents {


    event TokenFreeze(
        address indexed user,
        uint value
    );

    event TokenUnfreeze(
        address indexed user,
        uint value
    );

    event Transform (
        uint hexAmt,
        uint hxyAmt,
        address indexed transformer
    );

    event FounderLock (
        uint hxyAmt,
        uint timestamp
    );

    event FounderUnlock (
        uint hxyAmt,
        uint timestamp
    );
}

contract HEXMONEY is IERC20, TokenEvents {


    using SafeMath for uint256;
    using SafeERC20 for HEXMONEY;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    address internal uniFactory = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    address internal uniETHHEX = 0x05cDe89cCfa0adA8C88D5A23caaa79Ef129E7883;
    address public uniETHHXY = address(0);
    UniswapExchangeInterface internal uniHEXInterface = UniswapExchangeInterface(uniETHHEX);
    UniswapExchangeInterface internal uniHXYInterface;
    UniswapFactoryInterface internal uniFactoryInterface = UniswapFactoryInterface(uniFactory);
    address internal hexAddress = 0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39;
    HEX internal hexInterface = HEX(hexAddress);
    bool public roomActive;
    uint public roundCap = 0;
    uint public roundTransformed = 0;
    uint public totalHeartsTransformed = 0;
    uint public totalHXYTransformed = 0;
    uint public distributable = 0;
    uint public unlockLvl = 0;
    uint public lockStartTimestamp = 0;
    uint public lockDayLength = 1825;//5 years (10% released every 6 months)
    uint public lockedTokens = 0;
    uint private allLocked = 0;

    bool public mintBlock;//disables any more tokens ever being minted once _totalSupply reaches _maxSupply
    uint public mintRatio = 1000; //1000 for 0.1% (1 HXY for every 1000 HEX)
    uint public minFreezeDayLength = 7; // min days to freeze
    uint internal daySeconds = 86400; // seconds in a day
    uint public totalFrozen = 0;
    mapping (address => uint) public tokenFrozenBalances;//balance of HXY frozen mapped by user

    uint256 public _maxSupply = 6000000000000000;// max supply @ 60M
    uint256 internal _totalSupply;
    string public constant name = "HEX Money";
    string public constant symbol = "HXY";
    uint public constant decimals = 8;

    address payable internal MULTISIG = 0x35C7a87EbC3E9fBfd2a31579c70f0A2A8D4De4c5;
    address payable internal FOUNDER = 0xc61f905832aE9FB6Ef5BaD8CF6e5b8B5aE1DF026;
    address payable internal KYLE = 0xD30BC4859A79852157211E6db19dE159673a67E2;
    address payable internal MICHAEL = 0xe551072153c02fa33d4903CAb0435Fb86F1a80cb;
    address payable internal SWIFT = 0x7251FFB72C77221D16e6e04c9CD309EfFd0F940D;
    address payable internal MARCO = 0xbf1984B12878c6A25f0921535c76C05a60bdEf39;
    uint public donationGasLimit = 21000;
    bool private locked;
    address payable internal MARK = 0x35e9034f47cc00b8A9b555fC1FDB9598b2c245fD;
    address payable internal JARED = 0x5eCb4D3B4b451b838242c3CF8404ef18f5C486aB;
    address payable internal LOUIS = 0x454f203260a74C0A8B5c0a78fbA5B4e8B31dCC63;
    address payable internal DONATOR = 0x723e82Eb1A1b419Fb36e9bD65E50A979cd13d341;
    address payable internal KEVIN = 0x3487b398546C9b757921df6dE78EC308203f5830;
    address payable internal AMIRIS = 0x406D1fC98D231aD69807Cd41d4D6F8273401354f;
    address payable internal ANGEL = 0xF80A891c1A7600dDd84b1F9d54E0b092610Ed804;
    address[] public minterAddresses;// future contracts to enable minting of HXY relative to HEX 1000:1

    mapping(address => bool) admins;
    mapping(address => bool) minters;
    mapping (address => Frozen) public frozen;

    struct Frozen{
        uint freezeStartTimestamp;
    }
    
    modifier onlyMultisig(){

        require(msg.sender == MULTISIG, "not authorized");
        _;
    }

    modifier onlyAdmins(){

        require(admins[msg.sender], "not an admin");
        _;
    }

    modifier onlyMinters(){

        require(minters[msg.sender], "not a minter");
        _;
    }
    
    modifier synchronized {

        require(!locked, "Sync lock");
        locked = true;
        _;
        locked = false;
    }

    constructor() public {
        admins[FOUNDER] = true;
        admins[KYLE] = true;
        admins[MARCO] = true;
        admins[SWIFT] = true;
        admins[MICHAEL] = true;
        admins[msg.sender] = true;
        mintFounderTokens(_maxSupply.mul(20).div(100));//20% of max supply
        uniETHHXY = uniFactoryInterface.createExchange(address(this));
        uniHXYInterface = UniswapExchangeInterface(uniETHHXY);
    }

    receive() external payable{
        donate();
    }

    function _initialLiquidity()
        public
        payable
        onlyAdmins
        synchronized
    {

        require(msg.value >= 0.001 ether, "eth value too low");
        uint heartsForEth = uniHEXInterface.getEthToTokenInputPrice(msg.value);//price of eth value in hex
        uint hxy = heartsForEth / mintRatio;
        _mint(address(this), hxy);//mint tokens to this contract
        this.safeApprove(uniETHHXY, hxy);//approve uni exchange contract
        uniHXYInterface.addLiquidity{value:msg.value}(0, hxy, (now + 15 minutes)); //send tokens and eth to uni as liquidity*/
    }
    
    
    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
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

        uint256 amt = amount;
        require(account != address(0), "ERC20: mint to the zero address");
        if(!mintBlock){
            if(_totalSupply < _maxSupply){
                if(_totalSupply.add(amt) > _maxSupply){
                    amt = _maxSupply.sub(_totalSupply);
                    _totalSupply = _maxSupply;
                    mintBlock = true;
                }
                else{
                    _totalSupply = _totalSupply.add(amt);
                }
                _balances[account] = _balances[account].add(amt);
                emit Transfer(address(0), account, amt);
            }
        }
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
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
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount, "ERC20: burn amount exceeds allowance"));
    }

    event Transfer(address indexed from, address indexed to, uint256 value);//from address(0) for minting

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function mintFounderTokens(uint tokens)
        internal
        synchronized
        returns(bool)
    {

        require(tokens <= _maxSupply.mul(20).div(100), "founder tokens cannot be over 20%");
        address minter = FOUNDER;

        _mint(minter, tokens/2);//mint HXY
        _mint(address(this), tokens/2);//mint HXY to be locked for 5 years, 10% unlocked every 6 months
        lock(tokens/2);
        return true;
    }

    function lock(uint tokens)
        internal
    {

        lockStartTimestamp = now;
        lockedTokens = tokens;
        allLocked = tokens;
        emit FounderLock(tokens, lockStartTimestamp);
    }

    function unlock()
        public
        onlyAdmins
        synchronized
    {

        uint sixMonths = lockDayLength/10;
        require(unlockLvl < 10, "token unlock complete");
        require(lockStartTimestamp.add(sixMonths.mul(daySeconds)) <= now, "tokens cannot be unlocked yet");//must be at least over 6 months
        uint value = allLocked/10;
        if(lockStartTimestamp.add((sixMonths).mul(daySeconds)) <= now && unlockLvl == 0){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 2).mul(daySeconds)) <= now && unlockLvl == 1){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 3).mul(daySeconds)) <= now && unlockLvl == 2){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 4).mul(daySeconds)) <= now && unlockLvl == 3){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value); 
        }
        else if(lockStartTimestamp.add((sixMonths * 5).mul(daySeconds)) <= now && unlockLvl == 4){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 6).mul(daySeconds)) <= now && unlockLvl == 5){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value); 
        }
        else if(lockStartTimestamp.add((sixMonths * 7).mul(daySeconds)) <= now && unlockLvl == 6){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 8).mul(daySeconds)) <= now && unlockLvl == 7)
        {
            unlockLvl++;     
            lockedTokens = lockedTokens.sub(value);      
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 9).mul(daySeconds)) <= now && unlockLvl == 8){
            unlockLvl++;
            lockedTokens = lockedTokens.sub(value);
            transfer(FOUNDER, value);
        }
        else if(lockStartTimestamp.add((sixMonths * 10).mul(daySeconds)) <= now && unlockLvl == 9){
            unlockLvl++;
            if(lockedTokens >= value){
                lockedTokens = lockedTokens.sub(value);
            }
            else{
                value = lockedTokens;
                lockedTokens = 0;
            }
            transfer(FOUNDER, value);
        }
        else{
            revert();
        }
        emit FounderUnlock(value, now);
    }

    function FreezeTokens(uint amt)
        public
    {

        require(amt > 0, "zero input");
        require(tokenBalance() >= amt, "Error: insufficient balance");//ensure user has enough funds
        if(isFreezeFinished()){
            UnfreezeTokens();//unfreezes all currently froze tokens + profit
        }
        tokenFrozenBalances[msg.sender] = tokenFrozenBalances[msg.sender].add(amt);
        totalFrozen = totalFrozen.add(amt);
        frozen[msg.sender].freezeStartTimestamp = now;
        _transfer(msg.sender, address(this), amt);//make transfer
        emit TokenFreeze(msg.sender, amt);
    }

    function UnfreezeTokens()
        public
        synchronized
    {

        require(tokenFrozenBalances[msg.sender] > 0,"Error: unsufficient frozen balance");//ensure user has enough locked funds
        require(isFreezeFinished(), "tokens cannot be unlocked yet. min 7 day freeze");
        uint amt = tokenFrozenBalances[msg.sender];
        _mint(msg.sender, calcFreezingRewards());//mint HXY - total unfrozen / 1000 * minFreezeDayLength + days past
        tokenFrozenBalances[msg.sender] = 0;
        frozen[msg.sender].freezeStartTimestamp = 0;
        totalFrozen = totalFrozen.sub(amt);
        _transfer(address(this), msg.sender, amt);//make transfer
        emit TokenUnfreeze(msg.sender, amt);
    }

    function calcFreezingRewards()
        public
        view
        returns(uint)
    {

        return (tokenFrozenBalances[msg.sender].div(mintRatio) * minFreezeDayLength + daysPastMinFreezeLength());
    }
    
    function daysPastMinFreezeLength()
        public
        view
        returns(uint)
    {

        uint daysPast = now.sub(frozen[msg.sender].freezeStartTimestamp).div(daySeconds);
        if(daysPast >= minFreezeDayLength){
            return daysPast - minFreezeDayLength;// returns 0 if under 1 day passed
        }
        else{
            return 0;
        }
    }

    function transformHEX(uint hearts, address ref)//Approval needed
        public
        synchronized
    {

        require(roomActive, "transform room not active");
        require(hexInterface.transferFrom(msg.sender, address(this), hearts), "Transfer failed");//send hex from user to contract
        uint HXY = hearts / mintRatio;//HXY tokens to mint
        if(ref != address(0))//ref
        {
            require(roundCap >= roundTransformed.add(HXY.add(HXY.div(10))), "round supply cap reached");
            require(roundCap < _maxSupply.sub(totalSupply()), "round cap exeeds remaining maxSupply, reduce roundCap");
            roundTransformed += HXY.add(HXY.div(10));
            totalHXYTransformed += HXY.add(HXY.div(10));
            totalHeartsTransformed += hearts;
            _mint(ref, HXY.div(10));
        }
        else{//no ref
            require(roundCap >= roundTransformed.add(HXY), "round supply cap reached");
            require(roundCap < _maxSupply.sub(totalSupply()), "round cap exeeds remaining maxSupply, reduce roundCap");
            roundTransformed += HXY;
            totalHXYTransformed += HXY;
            totalHeartsTransformed += hearts;
        }
        _mint(msg.sender, HXY);//mint HXY - 0.1% of total heart value @ 1 HXY for 1000 HEX
        distributable += hearts;
        emit Transform(hearts, HXY, msg.sender);
    }
    
    function mintHXY(uint hearts, address receiver)
        public
        onlyMinters
        returns(bool)
    {

        uint amt = hearts.div(mintRatio);
        address minter = receiver;
        _mint(minter, amt);//mint HXY - 0.1% of total heart value @ 1 HXY for 1000 HEX
        return true;
    }


    function addMinter(address minter)
        public
        onlyMultisig
        returns (bool)
    {        

        minters[minter] = true;
        minterAddresses.push(minter);
        return true;
    }

    function toggleRoundActive(uint percentSupplyCap)
        public
        onlyAdmins
    {

        require(percentSupplyCap < (100 - (_totalSupply.mul(100).div(_maxSupply))), "percentage supplied to high");
        if(!roomActive){
            roomActive = true;
            roundCap = _maxSupply.mul(percentSupplyCap).div(100);
            roundTransformed = 0;
        }
        else{
            roomActive = false;
        }
    }


    function totalFrozenTokenBalance()
        public
        view
        returns (uint256)
    {

        return totalFrozen;
    }

    function tokenBalance()
        public
        view
        returns (uint256)
    {

        return balanceOf(msg.sender);
    }

    function isFreezeFinished()
        public
        view
        returns(bool)
    {

        if(frozen[msg.sender].freezeStartTimestamp == 0){
            return false;
        }
        else{
           return frozen[msg.sender].freezeStartTimestamp.add((minFreezeDayLength).mul(daySeconds)) <= now;               
        }

    }
    
    
    function distributeTransformedHex () public {
        require(distributable > 99, "balance too low to distribute");
        uint256 percent = distributable.div(100);
        uint teamPercent = percent.mul(20);
        hexInterface.transfer(LOUIS, teamPercent.div(7));
        hexInterface.transfer(AMIRIS, teamPercent.div(7));
        hexInterface.transfer(MARK, teamPercent.div(7));
        hexInterface.transfer(KEVIN, teamPercent.div(7));
        hexInterface.transfer(DONATOR, teamPercent.div(7));
        hexInterface.transfer(JARED, teamPercent.div(7));
        hexInterface.transfer(KYLE, teamPercent.div(7));
        hexInterface.transfer(MARCO, percent.mul(15));
        hexInterface.transfer(SWIFT, percent.mul(10));
        hexInterface.transfer(ANGEL, percent.mul(20));
        hexInterface.transfer(MICHAEL, percent.mul(15));
        hexInterface.transfer(FOUNDER, percent.mul(20));//10% HXY liquidity allocation + 10% overflow
        distributable = 0;
    }
    
    function donate() public payable {

        require(msg.value > 0);
        bool success = false;
        uint256 balance = msg.value;
        uint256 percent = balance.div(100);
        uint teamPercent = percent.mul(20);
        (success, ) =  LOUIS.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  AMIRIS.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  MARK.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  KEVIN.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  DONATOR.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  JARED.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  KYLE.call{value:teamPercent.div(7)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  MARCO.call{value:percent.mul(15)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  SWIFT.call{value:percent.mul(10)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  ANGEL.call{value:percent.mul(20)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  MICHAEL.call{value:percent.mul(15)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
        (success, ) =  FOUNDER.call{value:percent.mul(20)}{gas:donationGasLimit}('');
        require(success, "Transfer failed");
    }

    function setDonateGasLimit(uint gasLimit)
        public
        onlyAdmins
    {

        donationGasLimit = gasLimit;
    }
}
