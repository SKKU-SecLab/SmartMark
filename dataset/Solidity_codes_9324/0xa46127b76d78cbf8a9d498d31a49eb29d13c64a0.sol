
pragma solidity ^0.6.0;


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
}



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

}






contract ERC20Helper  {
    event TransferOut(uint256 Amount, address To, address Token);
    event TransferIn(uint256 Amount, address From, address Token);
    modifier TestAllownce(
        address _token,
        address _owner,
        uint256 _amount
    ) {
        require(
            ERC20(_token).allowance(_owner, address(this)) >= _amount,
            "no allowance"
        );
        _;
    }

    function TransferToken(
        address _Token,
        address _Reciver,
        uint256 _Amount
    ) internal {
        uint256 OldBalance = CheckBalance(_Token, address(this));
        emit TransferOut(_Amount, _Reciver, _Token);
        ERC20(_Token).transfer(_Reciver, _Amount);
        require(
            (SafeMath.add(CheckBalance(_Token, address(this)), _Amount)) == OldBalance
                ,
            "recive wrong amount of tokens"
        );
    }

    function CheckBalance(address _Token, address _Subject)
        internal
        view
        returns (uint256)
    {
        return ERC20(_Token).balanceOf(_Subject);
    }

    function TransferInToken(
        address _Token,
        address _Subject,
        uint256 _Amount
    ) internal TestAllownce(_Token, _Subject, _Amount) {
        require(_Amount > 0);
        uint256 OldBalance = CheckBalance(_Token, address(this));
        ERC20(_Token).transferFrom(_Subject, address(this), _Amount);
        emit TransferIn(_Amount, _Subject, _Token);
        require(
            (SafeMath.add(OldBalance, _Amount)) ==
                CheckBalance(_Token, address(this)),
            "recive wrong amount of tokens"
        );
    }

    function ApproveAllowanceERC20(
        address _Token,
        address _Subject,
        uint256 _Amount
    ) internal {
        require(_Amount > 0);
        ERC20(_Token).approve(_Subject, _Amount);
    }
}




abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}





contract GovManager is Ownable {
    address public GovernerContract;

    modifier onlyOwnerOrGov() {
        require(msg.sender == owner() || msg.sender == GovernerContract, "Authorization Error");
        _;
    }

    function setGovernerContract(address _address) external onlyOwnerOrGov{
        GovernerContract = _address;
    }

    constructor() public {
        GovernerContract = address(0);
    }
}





contract PozBenefit is GovManager {
    constructor() public {
        PozFee = 15; // *10000
        PozTimer = 1000; // *10000
    
    }

    uint256 public PozFee; // the fee for the first part of the pool
    uint256 public PozTimer; //the timer for the first part fo the pool
    
    modifier PercentCheckOk(uint256 _percent) {
        if (_percent < 10000) _;
        else revert("Not in range");
    }
    modifier LeftIsBigger(uint256 _left, uint256 _right) {
        if (_left > _right) _;
        else revert("Not bigger");
    }

    function SetPozTimer(uint256 _pozTimer)
        public
        onlyOwnerOrGov
        PercentCheckOk(_pozTimer)
    {
        PozTimer = _pozTimer;
    }

    
}





contract ETHHelper is Ownable {
    constructor() public {
        IsPayble = false;
    }

    modifier ReceivETH(uint256 msgValue, address msgSender, uint256 _MinETHInvest) {
        require(msgValue >= _MinETHInvest, "Send ETH to invest");
        emit TransferInETH(msgValue, msgSender);
        _;
    }

    receive() external payable {
        if (!IsPayble) revert();
    }

    event TransferOutETH(uint256 Amount, address To);
    event TransferInETH(uint256 Amount, address From);

    bool public IsPayble;
 
    function SwitchIsPayble() public onlyOwner {
        IsPayble = !IsPayble;
    }

    function TransferETH(address payable _Reciver, uint256 _ammount) internal {
        emit TransferOutETH(_ammount, _Reciver);
        uint256 beforeBalance = address(_Reciver).balance;
        _Reciver.transfer(_ammount);
        require(
            SafeMath.add(beforeBalance, _ammount) == address(_Reciver).balance,
            "The transfer did not complite"
        );
    }
 
}



interface IWhiteList {
    function Check(address _Subject, uint256 _Id) external view returns(uint);
    function Register(address _Subject,uint256 _Id,uint256 _Amount) external;
    function IsNeedRegister(uint256 _Id) external view returns(bool);
    function LastRoundRegister(address _Subject,uint256 _Id) external;
}





abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
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










contract Manageable is ETHHelper, ERC20Helper, PozBenefit, Pausable  {
    constructor() public {
        Fee = 20; // *10000
        MaxDuration = 60 * 60 * 24 * 30 * 6; // half year
        MinETHInvest = 10000; // for percent calc
        MaxETHInvest = 100 * 10**18; // 100 eth per wallet
    }

    mapping(address => uint256) FeeMap;
    uint256 public Fee; //the fee for the pool
    uint256 public MinDuration; //the minimum duration of a pool, in seconds
    uint256 public MaxDuration; //the maximum duration of a pool from the creation, in seconds
    uint256 public PoolPrice;
    uint256 public MinETHInvest;
    uint256 public MaxETHInvest;
    uint256 public MinERC20Invest;
    uint256 public MaxERC20Invest;
    address public WhiteList_Address; //The address of the Whitelist contract
    address public Benefit_Address;

    bool public IsTokenFilterOn;
    uint256 public TokenWhitelistId;
    uint256 public MCWhitelistId; // Main Coin WhiteList ID

    address public LockedDealAddress;
    bool public UseLockedDealForTlp;

    function SwapTokenFilter() public onlyOwner {
        IsTokenFilterOn = !IsTokenFilterOn;
    }

    function setTokenWhitelistId(uint256 _whiteListId) external onlyOwnerOrGov{
        TokenWhitelistId = _whiteListId;
    }

    function setMCWhitelistId(uint256 _whiteListId) external onlyOwnerOrGov{
        MCWhitelistId = _whiteListId;
    }

    function IsValidToken(address _address) public view returns (bool) {
        return !IsTokenFilterOn || (IWhiteList(WhiteList_Address).Check(_address, TokenWhitelistId) > 0);
    }

    function IsERC20Maincoin(address _address) public view returns (bool) {
        return !IsTokenFilterOn || IWhiteList(WhiteList_Address).Check(_address, MCWhitelistId) > 0;
    }
    
    function SetWhiteList_Address(address _WhiteList_Address) public onlyOwnerOrGov {
        WhiteList_Address = _WhiteList_Address;
    }

    function SetBenefit_Address(address _benefitAddress) public onlyOwnerOrGov {
        Benefit_Address = _benefitAddress;
    }

    function SetMinMaxETHInvest(uint256 _MinETHInvest, uint256 _MaxETHInvest)
        public
        onlyOwnerOrGov
    {
        MinETHInvest = _MinETHInvest;
        MaxETHInvest = _MaxETHInvest;
    }
    function SetMinMaxERC20Invest(uint256 _MinERC20Invest, uint256 _MaxERC20Invest)
        public
        onlyOwnerOrGov
    {
        MinERC20Invest = _MinERC20Invest;
        MaxERC20Invest = _MaxERC20Invest;
    }

    function SetMinMaxDuration(uint256 _minDuration, uint256 _maxDuration)
        public
        onlyOwnerOrGov
    {
        MinDuration = _minDuration;
        MaxDuration = _maxDuration;
    }

    function SetPoolPrice(uint256 _PoolPrice) public onlyOwnerOrGov {
        PoolPrice = _PoolPrice;
    }

    function SetFee(uint256 _fee)
        public
        onlyOwnerOrGov
        PercentCheckOk(_fee)
        LeftIsBigger(_fee, PozFee)
    {
        Fee = _fee;
    }

    function SetPOZFee(uint256 _fee)
        public
        onlyOwnerOrGov
        PercentCheckOk(_fee)
        LeftIsBigger(Fee, _fee)
    {
        PozFee = _fee;
    }

    function SetLockedDealAddress(address lockedDeal) public onlyOwnerOrGov {
        LockedDealAddress = lockedDeal;
    }

    function SwitchLockedDealForTlp() public onlyOwnerOrGov {
        UseLockedDealForTlp = !UseLockedDealForTlp;
    }

    function isUsingLockedDeal() public view returns(bool) {
        return UseLockedDealForTlp && LockedDealAddress != address(0x0);
    }

    function pause() public onlyOwnerOrGov {
        _pause();
    }

    function unpause() public onlyOwnerOrGov {
        _unpause();
    }
    
}






contract Pools is Manageable {
    event NewPool(address token, uint256 id);
    event FinishPool(uint256 id);
    event PoolUpdate(uint256 id);

    constructor() public {
    }

    uint256 public poolsCount; // the ids of the pool
    mapping(uint256 => Pool) pools; //the id of the pool with the data
    mapping(address => uint256[]) poolsMap; //the address and all of the pools id's
    struct Pool {
        PoolBaseData BaseData;
        PoolMoreData MoreData;
    }
    struct PoolBaseData {
        address Token; //the address of the erc20 toke for sale
        address Creator; //the project owner
        uint256 FinishTime; //Until what time the pool is active
        uint256 Rate; //for eth Wei, in token, by the decemal. the cost of 1 token
        uint256 POZRate; //the rate for the until OpenForAll, if the same as Rate , OpenForAll = StartTime .
        address Maincoin; // on adress.zero = ETH
        uint256 StartAmount; //The total amount of the tokens for sale
    }
    struct PoolMoreData {
        uint64 LockedUntil; // true - the investors getting the tokens after the FinishTime. false - intant deal
        uint256 Lefttokens; // the ammount of tokens left for sale
        uint256 StartTime; // the time the pool open //TODO Maybe Delete this?
        uint256 OpenForAll; // The Time that all investors can invest
        uint256 UnlockedTokens; //for locked pools
        uint256 WhiteListId; // 0 is turn off, the Id of the whitelist from the contract.
        bool TookLeftOvers; //The Creator took the left overs after the pool finished
        bool Is21DecimalRate; //If true, the rate will be rate*10^-21
    }

    function isPoolLocked(uint256 _id) public view returns(bool){
        return pools[_id].MoreData.LockedUntil > now;
    }

    function CreatePool(
        address _Token, //token to sell address
        uint256 _FinishTime, //Until what time the pool will work
        uint256 _Rate, //the rate of the trade
        uint256 _POZRate, //the rate for POZ Holders, how much each token = main coin
        uint256 _StartAmount, //Total amount of the tokens to sell in the pool
        uint64 _LockedUntil, //False = DSP or True = TLP
        address _MainCoin, // address(0x0) = ETH, address of main token
        bool _Is21Decimal, //focus the for smaller tokens.
        uint256 _Now, //Start Time - can be 0 to not change current flow
        uint256 _WhiteListId // the Id of the Whitelist contract, 0 For turn-off
    ) public payable whenNotPaused {
        require(msg.value >= PoolPrice, "Need to pay for the pool");
        require(IsValidToken(_Token), "Need Valid ERC20 Token"); //check if _Token is ERC20
        require(
            _MainCoin == address(0x0) || IsERC20Maincoin(_MainCoin),
            "Main coin not in list"
        );
        require(_FinishTime  < SafeMath.add(MaxDuration, now), "Pool duration can't be that long");
        require(_LockedUntil < SafeMath.add(MaxDuration, now) , "Locked value can't be that long");
        require(
            _Rate <= _POZRate,
            "POZ holders need to have better price (or the same)"
        );
        require(_POZRate > 0, "It will not work");
        if (_Now < now) _Now = now;
        require(
            SafeMath.add(now, MinDuration) <= _FinishTime,
            "Need more then MinDuration"
        ); // check if the time is OK
        TransferInToken(_Token, msg.sender, _StartAmount);
        uint256 Openforall =
            (_WhiteListId == 0) 
                ? _Now //and this
                : SafeMath.add(
                    SafeMath.div(
                        SafeMath.mul(SafeMath.sub(_FinishTime, _Now), PozTimer),
                        10000
                    ),
                    _Now
                );
        pools[poolsCount] = Pool(
            PoolBaseData(
                _Token,
                msg.sender,
                _FinishTime,
                _Rate,
                _POZRate,
                _MainCoin,
                _StartAmount
            ),
            PoolMoreData(
                _LockedUntil,
                _StartAmount,
                _Now,
                Openforall,
                0,
                _WhiteListId,
                false,
                _Is21Decimal
            )
        );
        poolsMap[msg.sender].push(poolsCount);
        emit NewPool(_Token, poolsCount);
        poolsCount = SafeMath.add(poolsCount, 1); //joke - overflowfrom 0 on int256 = 1.16E77
    }
}




contract PoolsData is Pools {
    enum PoolStatus {Created, Open, PreMade, OutOfstock, Finished, Close} //the status of the pools

    modifier isPoolId(uint256 _id) {
        require(_id < poolsCount, "Invalid Pool ID");
        _;
    }

    function GetMyPoolsId() public view returns (uint256[] memory) {
        return poolsMap[msg.sender];
    }

    function GetPoolBaseData(uint256 _Id)
        public
        view
        isPoolId(_Id)
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            pools[_Id].BaseData.Token,
            pools[_Id].BaseData.Creator,
            pools[_Id].BaseData.FinishTime,
            pools[_Id].BaseData.Rate,
            pools[_Id].BaseData.POZRate,
            pools[_Id].BaseData.StartAmount
        );
    }

    function GetPoolMoreData(uint256 _Id)
        public
        view
        isPoolId(_Id)
        returns (
            uint64,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        return (
            pools[_Id].MoreData.LockedUntil,
            pools[_Id].MoreData.Lefttokens,
            pools[_Id].MoreData.StartTime,
            pools[_Id].MoreData.OpenForAll,
            pools[_Id].MoreData.UnlockedTokens,
            pools[_Id].MoreData.Is21DecimalRate
        );
    }

    function GetPoolExtraData(uint256 _Id)
        public
        view
        isPoolId(_Id)
        returns (
            bool,
            uint256,
            address
        )
    {
        return (
            pools[_Id].MoreData.TookLeftOvers,
            pools[_Id].MoreData.WhiteListId,
            pools[_Id].BaseData.Maincoin
        );
    }

    function IsReadyWithdrawLeftOvers(uint256 _PoolId)
        public
        view
        isPoolId(_PoolId)
        returns (bool)
    {
        return
            pools[_PoolId].BaseData.FinishTime <= now &&
            pools[_PoolId].MoreData.Lefttokens > 0 &&
            !pools[_PoolId].MoreData.TookLeftOvers;
    }

    function WithdrawLeftOvers(uint256 _PoolId) public isPoolId(_PoolId) returns (bool) {
        if (IsReadyWithdrawLeftOvers(_PoolId)) {
            pools[_PoolId].MoreData.TookLeftOvers = true;
            TransferToken(
                pools[_PoolId].BaseData.Token,
                pools[_PoolId].BaseData.Creator,
                pools[_PoolId].MoreData.Lefttokens
            );
            return true;
        }
        return false;
    }

    function GetPoolStatus(uint256 _id)
        public
        view
        isPoolId(_id)
        returns (PoolStatus)
    {
        if (now < pools[_id].MoreData.StartTime) return PoolStatus.PreMade;
        if (
            now < pools[_id].MoreData.OpenForAll &&
            pools[_id].MoreData.Lefttokens > 0
        ) {
            return (PoolStatus.Created);
        }
        if (
            now >= pools[_id].MoreData.OpenForAll &&
            pools[_id].MoreData.Lefttokens > 0 &&
            now < pools[_id].BaseData.FinishTime
        ) {
            return (PoolStatus.Open);
        }
        if (
            pools[_id].MoreData.Lefttokens == 0 &&
            isPoolLocked(_id) &&
            now < pools[_id].BaseData.FinishTime
        ) //no tokens on locked pool, got time
        {
            return (PoolStatus.OutOfstock);
        }
        if (
            pools[_id].MoreData.Lefttokens == 0 && !isPoolLocked(_id)
        ) //no tokens on direct pool
        {
            return (PoolStatus.Close);
        }
        if (
            now >= pools[_id].BaseData.FinishTime &&
            !isPoolLocked(_id)
        ) {
            if (pools[_id].MoreData.TookLeftOvers) return (PoolStatus.Close);
            return (PoolStatus.Finished);
        }
        if (
            (pools[_id].MoreData.TookLeftOvers ||
                pools[_id].MoreData.Lefttokens == 0) &&
            (pools[_id].MoreData.UnlockedTokens +
                pools[_id].MoreData.Lefttokens ==
                pools[_id].BaseData.StartAmount)
        ) return (PoolStatus.Close);
        return (PoolStatus.Finished);
    }
}



interface IPOZBenefit {
    function IsPOZHolder(address _Subject) external view returns(bool);
}


interface ILockedDeal {
    function CreateNewPool(address _Token, uint64 _FinishTime, uint256 _StartAmount, address _Owner) external returns(uint256);
    function WithdrawToken(uint256 _PoolId) external returns(bool);
}







contract Invest is PoolsData {
    event NewInvestorEvent(uint256 Investor_ID, address Investor_Address, uint256 LockedDeal_ID);

    modifier CheckTime(uint256 _Time) {
        require(now >= _Time, "Pool not open yet");
        _;
    }

    modifier validateSender(){
        require(
            msg.sender == tx.origin && !isContract(msg.sender),
            "Some thing wrong with the msgSender"
        );
        _;
    }

    constructor() public {
    }

    uint256 internal TotalInvestors;
    mapping(uint256 => Investor) Investors;
    mapping(address => uint256[]) InvestorsMap;
    struct Investor {
        uint256 Poolid; //the id of the pool, he got the rate info and the token, check if looked pool
        address InvestorAddress; //
        uint256 MainCoin; //the amount of the main coin invested (eth/dai), calc with rate
        uint256 InvestTime; //the time that investment made
    }

    function getTotalInvestor() external view returns(uint256){
        return TotalInvestors;
    }
    
    function InvestETH(uint256 _PoolId)
        external
        payable
        ReceivETH(msg.value, msg.sender, MinETHInvest)
        whenNotPaused
        CheckTime(pools[_PoolId].MoreData.StartTime)
        isPoolId(_PoolId)
        validateSender()
    {
        require(pools[_PoolId].BaseData.Maincoin == address(0x0), "Pool is only for ETH");
        uint256 ThisInvestor = NewInvestor(msg.sender, msg.value, _PoolId);
        uint256 Tokens = CalcTokens(_PoolId, msg.value, msg.sender);
        
        TokenAllocate(_PoolId, ThisInvestor, Tokens);

        uint256 EthMinusFee =
            SafeMath.div(
                SafeMath.mul(msg.value, SafeMath.sub(10000, CalcFee(_PoolId))),
                10000
            );
        TransferETH(payable(pools[_PoolId].BaseData.Creator), EthMinusFee); 
        RegisterInvest(_PoolId, Tokens);
    }

    function InvestERC20(uint256 _PoolId, uint256 _Amount)
        external
        whenNotPaused
        CheckTime(pools[_PoolId].MoreData.StartTime)
        isPoolId(_PoolId)
        validateSender()
    {
        require(
            pools[_PoolId].BaseData.Maincoin != address(0x0),
            "Pool is for ETH, use InvestETH"
        );
        TransferInToken(pools[_PoolId].BaseData.Maincoin, msg.sender, _Amount);
        uint256 ThisInvestor = NewInvestor(msg.sender, _Amount, _PoolId);
        uint256 Tokens = CalcTokens(_PoolId, _Amount, msg.sender);

        TokenAllocate(_PoolId, ThisInvestor, Tokens);

        uint256 RegularFeePay =
            SafeMath.div(SafeMath.mul(_Amount, CalcFee(_PoolId)), 10000);

        uint256 RegularPaymentMinusFee = SafeMath.sub(_Amount, RegularFeePay);
        FeeMap[pools[_PoolId].BaseData.Maincoin] = SafeMath.add(
            FeeMap[pools[_PoolId].BaseData.Maincoin],
            RegularFeePay
        );
        TransferToken(
            pools[_PoolId].BaseData.Maincoin,
            pools[_PoolId].BaseData.Creator,
            RegularPaymentMinusFee
        ); // send money to project owner - the fee stays on contract
        RegisterInvest(_PoolId, Tokens);
    }

    function TokenAllocate(uint256 _PoolId, uint256 _ThisInvestor, uint256 _Tokens) internal {
        uint256 lockedDealId;
        if (isPoolLocked(_PoolId)) {
            require(isUsingLockedDeal(), "Cannot invest in TLP without LockedDeal");
            (address tokenAddress,,,,,) = GetPoolBaseData(_PoolId);
            (uint64 lockedUntil,,,,,) = GetPoolMoreData(_PoolId);
            ApproveAllowanceERC20(tokenAddress, LockedDealAddress, _Tokens);
            lockedDealId = ILockedDeal(LockedDealAddress).CreateNewPool(tokenAddress, lockedUntil, _Tokens, msg.sender);
        } else {
            TransferToken(pools[_PoolId].BaseData.Token, Investors[_ThisInvestor].InvestorAddress, _Tokens);
        }
        emit NewInvestorEvent(_ThisInvestor, Investors[_ThisInvestor].InvestorAddress, lockedDealId);
    }

    function RegisterInvest(uint256 _PoolId, uint256 _Tokens) internal {
        pools[_PoolId].MoreData.Lefttokens = SafeMath.sub(
            pools[_PoolId].MoreData.Lefttokens,
            _Tokens
        );
        if (pools[_PoolId].MoreData.Lefttokens == 0) emit FinishPool(_PoolId);
        else emit PoolUpdate(_PoolId);
    }

    function NewInvestor(
        address _Sender,
        uint256 _Amount,
        uint256 _Pid
    ) internal returns (uint256) {
        Investors[TotalInvestors] = Investor(
            _Pid,
            _Sender,
            _Amount,
            block.timestamp
        );
        InvestorsMap[msg.sender].push(TotalInvestors);
        TotalInvestors = SafeMath.add(TotalInvestors, 1);
        return SafeMath.sub(TotalInvestors, 1);
    }

    function CalcTokens(
        uint256 _Pid,
        uint256 _Amount,
        address _Sender
    ) internal returns (uint256) {
        uint256 msgValue = _Amount;
        uint256 result = 0;
        if (GetPoolStatus(_Pid) == PoolStatus.Created) {
            IsWhiteList(_Sender, pools[_Pid].MoreData.WhiteListId, _Amount);
            result = SafeMath.mul(msgValue, pools[_Pid].BaseData.POZRate);
        }
        if (GetPoolStatus(_Pid) == PoolStatus.Open) {
            (,,address _mainCoin) = GetPoolExtraData(_Pid);
            if(_mainCoin == address(0x0)){
                require(
                    msgValue >= MinETHInvest && msgValue <= MaxETHInvest,
                    "Investment amount not valid"
                );
            } else {
                require(
                    msgValue >= MinERC20Invest && msgValue <= MaxERC20Invest,
                    "Investment amount not valid"
                );
            }
            require(VerifyPozHolding(_Sender), "Only POZ holder can invest");
            LastRegisterWhitelist(_Sender, pools[_Pid].MoreData.WhiteListId);
            result = SafeMath.mul(msgValue, pools[_Pid].BaseData.Rate);
        }
        if (result >= 10**21) {
            if (pools[_Pid].MoreData.Is21DecimalRate) {
                result = SafeMath.div(result, 10**21);
            }
            require(
                result <= pools[_Pid].MoreData.Lefttokens,
                "Not enough tokens in the pool"
            );
            return result;
        }
        revert("Wrong pool status to CalcTokens");
    }

    function VerifyPozHolding(address _Sender) internal view returns(bool){
        if(Benefit_Address == address(0)) return true;
        return IPOZBenefit(Benefit_Address).IsPOZHolder(_Sender);
    }

    function LastRegisterWhitelist(address _Sender,uint256 _Id) internal returns(bool) {
        if (_Id == 0) return true; //turn-off
        IWhiteList(WhiteList_Address).LastRoundRegister(_Sender, _Id);
        return true;
    }

    function CalcFee(uint256 _Pid) internal view returns (uint256) {
        if (GetPoolStatus(_Pid) == PoolStatus.Created) {
            return PozFee;
        }
        if (GetPoolStatus(_Pid) == PoolStatus.Open) {
            return Fee;
        }
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function IsWhiteList(
        address _Investor,
        uint256 _Id,
        uint256 _Amount
    ) internal returns (bool) {
        if (_Id == 0) return true; //turn-off
        IWhiteList(WhiteList_Address).Register(_Investor, _Id, _Amount); //will revert if fail
        return true;
    }
}





contract InvestorData is Invest {
    
    function GetMyInvestmentIds() public view returns (uint256[] memory) {
        return InvestorsMap[msg.sender];
    }

    function GetInvestmentData(uint256 _id)
        public
        view
        returns (
            uint256,
            address,
            uint256,
            uint256
        )
    {
        return (
            Investors[_id].Poolid,
            Investors[_id].InvestorAddress,
            Investors[_id].MainCoin,
            Investors[_id].InvestTime
        );
    }
}




contract ThePoolz is InvestorData {
    constructor() public {    }

    function WithdrawETHFee(address payable _to) public onlyOwner {
        _to.transfer(address(this).balance); // keeps only fee eth on contract //To Do need to take 16% to burn!!!
    }

    function WithdrawERC20Fee(address _Token, address _to) public onlyOwner {
        uint256 temp = FeeMap[_Token];
        FeeMap[_Token] = 0;
        TransferToken(_Token, _to, temp);
    }
    
}