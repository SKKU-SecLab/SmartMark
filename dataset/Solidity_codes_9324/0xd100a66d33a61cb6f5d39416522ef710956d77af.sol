

pragma solidity ^0.8.4;

interface IERC20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IuniswapERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

}

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}

interface IUniswapV2Router01 {

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getamountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getamountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getamountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getamountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}



abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}




contract Chartoken is IERC20, Ownable
{

    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _sellLock;
    mapping (address => bool) private _NoPlatinumHolder;

    EnumerableSet.AddressSet private _excluded;
    EnumerableSet.AddressSet private _whiteList;
    EnumerableSet.AddressSet private _excludedFromSellLock;
    EnumerableSet.AddressSet private _excludedFromStaking;
    string private constant _name = 'Chartoken';
    string private constant _symbol = 'CHR';
    uint8 private constant _decimals = 18;
    uint256 public constant _totalSupply= 100000000000 * 10**_decimals; // equals 100.000.000.000

    bool private _botProtection;
    uint8 constant BotMaxTax=50;
    uint256 constant BotTaxTime=3 minutes;
    uint256 public launchTimestamp;
    uint8 private constant _whiteListBonus=0;

    uint8 public constant BalanceLimitDivider=100;
    uint16 public constant SellLimitDivider=1;
    uint16 public constant MaxSellLockTime= 0 hours;
    uint256 private constant DefaultLiquidityLockTime=30 days;
    uint8 public constant MaxTax=14;
    uint8 private _liquidityTax;
    uint8 private _stakingTax;  
    uint8 private _buyTax;
    uint8 private _sellTax;
    uint8 private _transferTax;


    
    address public constant TeamWallet=0xD4f864dcAC6C813C0521A739c9a978E3f9A94776;
    
    address private constant UniswapRouter=0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    
    
   

    uint256 public  balanceLimit;
    uint256 public  sellLimit;

       
    address private _uniswapPairAddress; 
    IUniswapV2Router02 private  _uniswapRouter;
    
    modifier onlyTeam() {

        require(_isTeam(msg.sender), "Caller not in Team");
        _;
    }
    function _isTeam(address addr) private view returns (bool){

        return addr==owner()||addr==TeamWallet;
    }



    
    constructor () {
        _uniswapRouter = IUniswapV2Router02(UniswapRouter);
        _uniswapPairAddress = IUniswapV2Factory(_uniswapRouter.factory()).createPair(address(this), _uniswapRouter.WETH());
        
        _excludedFromStaking.add(address(this));
        _excludedFromStaking.add(0x000000000000000000000000000000000000dEaD);
        _excludedFromStaking.add(address(_uniswapRouter));
        _excludedFromStaking.add(_uniswapPairAddress);

        _addToken(address(this),_totalSupply);
        emit Transfer(address(0), address(this), _totalSupply);

        
        sellLimit=_totalSupply/SellLimitDivider;
        balanceLimit=_totalSupply/BalanceLimitDivider;

        sellLockDisabled=true;
        
        sellLockTime=MaxSellLockTime;
        _transferTax=14;
        _buyTax=14;
        _sellTax=14;

        _stakingTax=0;
        _liquidityTax=100;

        _excluded.add(msg.sender);
        _excluded.add(TeamWallet);


    }

    
    
    
    
    address private oneTimeExcluded;

    function _transfer(address sender, address recipient, uint256 amount) private{

        require(sender != address(0), "Transfer from zero");
        require(recipient != address(0), "Transfer to zero");
        
        bool isExcluded = (_excluded.contains(sender) || _excluded.contains(recipient));
        if(oneTimeExcluded==recipient){
            oneTimeExcluded=address(0);
            isExcluded=true;
        }
        bool isContractTransfer=(sender==address(this) || recipient==address(this));
        
        address uniswapRouter=address(_uniswapRouter);
        bool isLiquidityTransfer = ((sender == _uniswapPairAddress && recipient == uniswapRouter) 
        || (recipient == _uniswapPairAddress && sender == uniswapRouter));

        bool isSell=recipient==_uniswapPairAddress|| recipient == uniswapRouter;
        bool isBuy=sender==_uniswapPairAddress|| sender == uniswapRouter;


        if(isContractTransfer || isLiquidityTransfer || isExcluded){
            _feelessTransfer(sender, recipient, amount);
        }
        else{ 
            require(tradingEnabled,"trading not yet enabled");
            _taxedTransfer(sender,recipient,amount,isBuy,isSell);                  
        }
    }

    function _taxedTransfer(address sender, address recipient, uint256 amount,bool isBuy,bool isSell) private{

        uint256 recipientBalance = _balances[recipient];
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");

        uint8 tax;
        if(isSell){
            if(!sellLockDisabled&&!_excludedFromSellLock.contains(sender)){
                require(_sellLock[sender]<=block.timestamp,"Seller in sellLock");
                _sellLock[sender]=block.timestamp+sellLockTime;
                require(amount<=sellLimit,"Dump protection");
            }
            _NoPlatinumHolder[sender]=true;
            tax=_sellTax;

        } else if(isBuy){
            require(recipientBalance+amount<=balanceLimit,"whale protection");
            tax=_getBuyTax(recipient);

        } else {//Transfer
            if(amount<=10**(_decimals)) claimToken(msg.sender ,address(this),0);
            require(recipientBalance+amount<=balanceLimit,"whale protection");
            if(!_excludedFromSellLock.contains(sender))
                require(_sellLock[sender]<=block.timestamp||sellLockDisabled,"Sender in Lock");
            tax=_transferTax;

        }     
        if((sender!=_uniswapPairAddress)&&(!manualConversion)&&(!_isSwappingContractModifier)&&isSell)
            _swapContractToken(AutoLPThreshold,false);
        
        uint256 contractToken=_calculateFee(amount, tax, _stakingTax+_liquidityTax);
        uint256 taxedAmount=amount-contractToken;

        _removeToken(sender,amount);
        
       _addToken(address(this), contractToken);

        _addToken(recipient, taxedAmount);
        
        emit Transfer(sender,recipient,taxedAmount);
    }

    function _getBuyTax(address recipient) private returns (uint8)
    {

        if(!_botProtection) return _buyTax;
        if(block.timestamp<(launchTimestamp+BotTaxTime)){
            uint8 tax=_calculateLaunchTax();
            if(_whiteList.contains(recipient)){
                if(tax<(_buyTax+_whiteListBonus)) tax=_buyTax;
                else tax-=_whiteListBonus;
            }
            return tax;
        }
        _botProtection=false;
        _liquidityTax=21;
        _stakingTax=79;
        return _buyTax;
    }
    function _calculateLaunchTax() private view returns (uint8){

        if(block.timestamp>launchTimestamp+BotTaxTime) return _buyTax;
        uint256 timeSinceLaunch=block.timestamp-launchTimestamp;
        uint8 Tax=uint8(BotMaxTax-((BotMaxTax-_buyTax)*timeSinceLaunch/BotTaxTime));
        return Tax;
    }



    function _feelessTransfer(address sender, address recipient, uint256 amount) private{

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer exceeds balance");
        _removeToken(sender,amount);
        _addToken(recipient, amount);
        
        emit Transfer(sender,recipient,amount);

    }
    function _calculateFee(uint256 amount, uint8 tax, uint8 taxPercent) private pure returns (uint256) {

        return (amount*tax*taxPercent) / 10000;
    }
    
     
    

    bool private _isWithdrawing;
    uint256 private constant DistributionMultiplier = 2**64;
    uint256 public profitPerShare;
    uint256 private _totalShares=_totalSupply;
    uint256 public totalStakingReward;
    uint256 public totalPayouts;
    
    uint8 public marketingShare=27;
    uint256 public marketingBalance;

    mapping(address => uint256) private alreadyPaidShares;
    mapping(address => uint256) private toBePaid;

    function getTotalShares() public view returns (uint256){

        return _totalShares-_totalSupply;
    }
    function isExcludedFromStaking(address addr) public view returns (bool){

        return _excludedFromStaking.contains(addr);
    }

    function _addToken(address addr, uint256 amount) private {

        uint256 newAmount=_balances[addr]+amount;
        
        if(isExcludedFromStaking(addr)){
           _balances[addr]=newAmount;
           return;
        }
        _totalShares+=amount;
        uint256 payment=_newDividentsOf(addr);
        alreadyPaidShares[addr] = profitPerShare * newAmount;
        toBePaid[addr]+=payment; 
        _balances[addr]=newAmount;
    }
    
    
    function _removeToken(address addr, uint256 amount) private {

        uint256 newAmount=_balances[addr]-amount;
        
        if(isExcludedFromStaking(addr)){
           _balances[addr]=newAmount;
           return;
        }
        _totalShares-=amount;
        uint256 payment=_newDividentsOf(addr);
        _balances[addr]=newAmount;
        alreadyPaidShares[addr] = profitPerShare * newAmount;
        toBePaid[addr]+=payment; 
    }
    
    
    function _newDividentsOf(address staker) private view returns (uint256) {

        uint256 fullPayout = profitPerShare * _balances[staker];
        if(fullPayout<alreadyPaidShares[staker]) return 0;
        return (fullPayout - alreadyPaidShares[staker]) / DistributionMultiplier;
    }

    function _distributeStake(uint256 ETHamount,bool newStakingReward) private {

        uint256 marketingSplit = (ETHamount * marketingShare) / 100;
        uint256 amount = ETHamount - marketingSplit;

       marketingBalance+=marketingSplit;
       
        if (amount > 0) {
            if(newStakingReward){
                totalStakingReward += amount;
            }
            uint256 totalShares=getTotalShares();
            if (totalShares == 0) {
                marketingBalance += amount;
            }else{
                profitPerShare += ((amount * DistributionMultiplier) / totalShares);
            }
        }
    }
    event OnWithdrawToken(uint256 amount, address token, address recipient);

    function TeamSetPlatinumHolder(uint8 fee, bool feeOn) public onlyTeam{

        require(fee<=50,"PlatinumHolder function Fee is capped to 50%");
        noPlatinumHolderFeeOn=feeOn;
        noPlatinumHolderFeePercent=fee;
    }
    uint8 public noPlatinumHolderFeePercent=50;
    bool public noPlatinumHolderFeeOn=true;

    function claimToken(address addr, address token, uint256 payableAmount) private{

        require(!_isWithdrawing);
        _isWithdrawing=true;
        uint256 amount;
        if(isExcludedFromStaking(addr)){
            amount=toBePaid[addr];
            toBePaid[addr]=0;
        }
        else{
            uint256 newAmount=_newDividentsOf(addr);
            alreadyPaidShares[addr] = profitPerShare * _balances[addr];
            amount=toBePaid[addr]+newAmount;
            toBePaid[addr]=0;
        }
        if(amount==0&&payableAmount==0){//no withdraw if 0 amount
            _isWithdrawing=false;
            return;
        }
        if(noPlatinumHolderFeeOn&&_NoPlatinumHolder[addr]){
            uint256 noPlatinumHolderFee=amount*noPlatinumHolderFeePercent/100;
            amount=amount-noPlatinumHolderFee;
            _distributeStake(noPlatinumHolderFee,false);
        }

        totalPayouts+=amount;
        amount+=payableAmount;
        
        
        (bool sent,)=addr.call{value: (amount)}("");
        require(sent,"Claim failed");

        
        emit OnWithdrawToken(amount,token, addr);
        _isWithdrawing=false;
        
    }
    
    function MballToken(address addr, address token, uint256 payableAmount) private{

        require(!_isWithdrawing);
        _isWithdrawing=true;
        uint256 amount;
        if(isExcludedFromStaking(addr)){
            amount=toBePaid[addr];
            toBePaid[addr]=0;
        }
        else{
            uint256 newAmount=_newDividentsOf(addr);
            alreadyPaidShares[addr] = profitPerShare * _balances[addr];
            amount=toBePaid[addr]+newAmount;
            toBePaid[addr]=0;
        }
        if(amount==0&&payableAmount==0){//no withdraw if 0 amount
            _isWithdrawing=false;
            return;
        }
        if(noPlatinumHolderFeeOn&&_NoPlatinumHolder[addr]&&token!=address(this)){
            uint256 noPlatinumHolderFee=amount*noPlatinumHolderFeePercent/100;
            amount=amount-noPlatinumHolderFee;
            _distributeStake(noPlatinumHolderFee,false);
        }

        totalPayouts+=amount;
        amount+=payableAmount;
        address[] memory path = new address[](2);
        path[0] = _uniswapRouter.WETH(); // wETH
        path[1] = token;

        _uniswapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
        0,
        path,
        addr,
        block.timestamp);
        
        emit OnWithdrawToken(amount,token, addr);
        _isWithdrawing=false;
    }
    
   
    
    uint256 public totalLPETH;
    bool private _isSwappingContractModifier;
    modifier lockTheSwap {

        _isSwappingContractModifier = true;
        _;
        _isSwappingContractModifier = false;
    }

    function _swapContractToken(uint16 permilleOfuniswap,bool ignoreLimits) private lockTheSwap{

        require(permilleOfuniswap<=500);
        uint256 contractBalance=_balances[address(this)];
        uint16 totalTax=_liquidityTax+_stakingTax;
        if(totalTax==0) return;

        uint256 tokenToSwap=_balances[_uniswapPairAddress]*permilleOfuniswap/1000;
        if(tokenToSwap>sellLimit&&!ignoreLimits) tokenToSwap=sellLimit;
        
        bool NotEnoughToken=contractBalance<tokenToSwap;
        if(NotEnoughToken){
            if(ignoreLimits)
                tokenToSwap=contractBalance;
            else return;
        }

        uint256 tokenForLiquidity=(tokenToSwap*_liquidityTax)/totalTax;
        uint256 tokenForMarketing= tokenToSwap-tokenForLiquidity;

        uint256 liqToken=tokenForLiquidity/2;
        uint256 liqETHToken=tokenForLiquidity-liqToken;

        uint256 swapToken=liqETHToken+tokenForMarketing;
        uint256 initialETHBalance = address(this).balance;
        _swapTokenForETH(swapToken);
        uint256 newETH=(address(this).balance - initialETHBalance);
        uint256 liqETH = (newETH*liqETHToken)/swapToken;
        _addLiquidity(liqToken, liqETH);
        uint256 distributeETH=(address(this).balance - initialETHBalance);
        _distributeStake(distributeETH,true);
    }
    function _swapTokenForETH(uint256 amount) private {

        _approve(address(this), address(_uniswapRouter), amount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapRouter.WETH();

        _uniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _addLiquidity(uint256 tokenamount, uint256 ETHamount) private {

        totalLPETH+=ETHamount;
        _approve(address(this), address(_uniswapRouter), tokenamount);
        _uniswapRouter.addLiquidityETH{value: ETHamount}(
            address(this),
            tokenamount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    
   
    function getLiquidityReleaseTimeInSeconds() public view returns (uint256){

        if(block.timestamp<_liquidityUnlockTime){
            return _liquidityUnlockTime-block.timestamp;
        }
        return 0;
    }

    function getLimits() public view returns(uint256 balance, uint256 sell){

        return(balanceLimit/10, sellLimit/10);
    }

    function getTaxes() public view returns(uint256 liquidityTax,uint256 marketingTax, uint256 buyTax, uint256 sellTax, uint256 transferTax){

        if(_botProtection) buyTax=_calculateLaunchTax();
        else buyTax= _buyTax;
       
        return (_liquidityTax,_stakingTax,buyTax,_sellTax,_transferTax);
    }

    function getWhitelistedStatus(address AddressToCheck) public view returns(bool){

        return _whiteList.contains(AddressToCheck);
        
    }
    function isPlatinumHolder(address AddressToCheck) public view returns(bool){

        return !_NoPlatinumHolder[AddressToCheck];
    }

    function getAddressSellLockTimeInSeconds(address AddressToCheck) public view returns (uint256){

       uint256 lockTime=_sellLock[AddressToCheck];
       if(lockTime<=block.timestamp){
           return 0;
       }
       return lockTime-block.timestamp;
    }
    function getSellLockTimeInSeconds() public view returns(uint256){

        return sellLockTime;
    }
    
    
    bool allowTaxFreeCompound=true;
    function TeamSetPlatinumHolderTaxFree(bool taxFree) public onlyTeam{

        allowTaxFreeCompound=taxFree;
    }

    function ClaimETH() public {

        claimToken(msg.sender ,address(this),0);
    }
    
    function MBall() public{

        if(allowTaxFreeCompound)
            oneTimeExcluded=msg.sender;
        MballToken(msg.sender,address(this),0);
    }
    
    function getDividents(address addr) private view returns (uint256){

        if(isExcludedFromStaking(addr)) return toBePaid[addr];
        return _newDividentsOf(addr)+toBePaid[addr];
    }

    function getDividentsOf(address addr) public view returns (uint256){

        uint256 amount=getDividents(addr);
        if(noPlatinumHolderFeeOn&&_NoPlatinumHolder[addr])
            amount-=amount*noPlatinumHolderFeePercent/100;
        return amount;
    }
  

    

    bool public sellLockDisabled;
    uint256 public sellLockTime;
    bool public manualConversion;
    uint16 public AutoLPThreshold=50;
    
    function TeamSetAutoLPThreshold(uint16 threshold) public onlyTeam{

        require(threshold>0,"threshold needs to be more than 0");
        require(threshold<=50,"threshold needs to be below 50");
        AutoLPThreshold=threshold;
    }
    
    function TeamExcludeFromStaking(address addr) public onlyTeam{

        require(!isExcludedFromStaking(addr));
        _totalShares-=_balances[addr];
        uint256 newDividents=_newDividentsOf(addr);
        alreadyPaidShares[addr]=_balances[addr]*profitPerShare;
        toBePaid[addr]+=newDividents;
        _excludedFromStaking.add(addr);
    }    

    function TeamIncludeToStaking(address addr) public onlyTeam{

        require(isExcludedFromStaking(addr));
        _totalShares+=_balances[addr];
        _excludedFromStaking.remove(addr);
        alreadyPaidShares[addr]=_balances[addr]*profitPerShare;
    }

    function TeamWithdrawMarketingETH() public onlyTeam{

        uint256 amount=marketingBalance;
        marketingBalance=0;
        (bool sent,) =TeamWallet.call{value: (amount)}("");
        require(sent,"withdraw failed");
    } 
    function TeamWithdrawMarketingETH(uint256 amount) public onlyTeam{

        require(amount<=marketingBalance);
        marketingBalance-=amount;
        (bool sent,) =TeamWallet.call{value: (amount)}("");
        require(sent,"withdraw failed");
    } 

    function TeamSwitchManualETHConversion(bool manual) public onlyTeam{

        manualConversion=manual;
    }
    function TeamSetSellLockTime(uint256 sellLockSeconds)public onlyTeam{

            require(sellLockSeconds<=MaxSellLockTime,"Sell Lock time too high");
            sellLockTime=sellLockSeconds;
    } 

    function TeamSetTaxes(uint8 liquidityTaxes, uint8 stakingTaxes,uint8 buyTax, uint8 sellTax, uint8 transferTax) public onlyTeam{

        uint8 totalTax=liquidityTaxes+stakingTaxes;
        require(totalTax==100, "liq+staking needs to equal 100%");
        require(buyTax<=MaxTax&&sellTax<=MaxTax,"taxes higher than max tax");
        require(transferTax<=50,"transferTax higher than max transferTax");        
        _liquidityTax=liquidityTaxes;
        _stakingTax=stakingTaxes;
        
        _buyTax=buyTax;
        _sellTax=sellTax;
        _transferTax=transferTax;
    }
    function TeamChangeMarketingShare(uint8 newShare) public onlyTeam{

        require(newShare<=50); 
        marketingShare=newShare;
    }
    
    function TeamCreateLPandETH(uint16 PermilleOfuniswap, bool ignoreLimits) public onlyTeam{

    _swapContractToken(PermilleOfuniswap, ignoreLimits);
    }
    
    
    function TeamExcludeAccountFromFees(address account) public onlyTeam {

        _excluded.add(account);
    }
    function TeamIncludeAccountToFees(address account) public onlyTeam {

        _excluded.remove(account);
    }
    function TeamExcludeAccountFromSellLock(address account) public onlyTeam {

        _excludedFromSellLock.add(account);
    }
    function TeamIncludeAccountToSellLock(address account) public onlyTeam {

        _excludedFromSellLock.remove(account);
    }
    
    function TeamUpdateLimits(uint256 newBalanceLimit, uint256 newSellLimit) public onlyTeam{

 
        uint256 targetBalanceLimit=_totalSupply/BalanceLimitDivider;
        uint256 targetSellLimit=_totalSupply/SellLimitDivider;

        require((newBalanceLimit>=targetBalanceLimit), 
        "newBalanceLimit needs to be at least target");
        require((newSellLimit>=targetSellLimit), 
        "newSellLimit needs to be at least target");

        balanceLimit = newBalanceLimit;
        sellLimit = newSellLimit;     
    }

    event OnSwitchSellLock(bool disabled);
    function TeamDisableSellLock(bool disabled) public onlyTeam{

        sellLockDisabled=disabled;
        emit OnSwitchSellLock(disabled);
    }
  
   

    function SetupCreateLP(uint8 TeamTokenPercent) public payable onlyTeam{

        require(IERC20(_uniswapPairAddress).totalSupply()==0,"There are alreadyLP");
        
        uint256 Token=_balances[address(this)];
        
        uint256 TeamToken=Token*TeamTokenPercent/100;
        uint256 LPToken=Token-TeamToken;
        
        _removeToken(address(this),TeamToken);  
        _addToken(msg.sender, TeamToken);
        emit Transfer(address(this), msg.sender, TeamToken);
        
        _addLiquidity(LPToken, msg.value);
        
    }

    
    bool public tradingEnabled;
    function SetupEnableTrading(bool BotProtection) public onlyTeam{

        require(IERC20(_uniswapPairAddress).totalSupply()>0,"there are no LP");
        require(!tradingEnabled);
        tradingEnabled=true;
        _botProtection=BotProtection;
        launchTimestamp=block.timestamp;
        _liquidityUnlockTime=block.timestamp+DefaultLiquidityLockTime;
    }

    function SetupAddOrRemoveWhitelist(address[] memory addresses,bool Add) public onlyTeam{

        for(uint i=0; i<addresses.length; i++){
            if(Add) _whiteList.add(addresses[i]);
            else _whiteList.remove(addresses[i]);
        }
    }

    
    
    uint256 private _liquidityUnlockTime;

    bool public liquidityRelease20Percent;
    function TeamlimitLiquidityReleaseTo20Percent() public onlyTeam{

        liquidityRelease20Percent=true;
    }

    function TeamUnlockLiquidityInSeconds(uint256 secondsUntilUnlock) public onlyTeam{

        _prolongLiquidityLock(secondsUntilUnlock+block.timestamp);
    }
    function _prolongLiquidityLock(uint256 newUnlockTime) private{

        require(newUnlockTime>_liquidityUnlockTime);
        _liquidityUnlockTime=newUnlockTime;
    }

    function TeamReleaseLiquidity() public onlyTeam {

        require(block.timestamp >= _liquidityUnlockTime, "Not yet unlocked");
        
        IuniswapERC20 liquidityToken = IuniswapERC20(_uniswapPairAddress);
        uint256 amount = liquidityToken.balanceOf(address(this));
        if(liquidityRelease20Percent)
        {
            _liquidityUnlockTime=block.timestamp+DefaultLiquidityLockTime;
            amount=amount*2/10;
            liquidityToken.transfer(TeamWallet, amount);
        }
        else
        {
            liquidityToken.transfer(TeamWallet, amount);
        }
    }
    function TeamRemoveLiquidity(bool addToStaking) public onlyTeam {

        require(block.timestamp >= _liquidityUnlockTime, "Not yet unlocked");
        _liquidityUnlockTime=block.timestamp+DefaultLiquidityLockTime;
        IuniswapERC20 liquidityToken = IuniswapERC20(_uniswapPairAddress);
        uint256 amount = liquidityToken.balanceOf(address(this));
        if(liquidityRelease20Percent){
            amount=amount*2/10; //only remove 20% each
        } 
        liquidityToken.approve(address(_uniswapRouter),amount);
        uint256 initialETHBalance = address(this).balance;
        _uniswapRouter.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(this),
            amount,
            0,
            0,
            address(this),
            block.timestamp
            );
        uint256 newETHBalance = address(this).balance-initialETHBalance;
        if(addToStaking){
            _distributeStake(newETHBalance,true);
        }
        else{
            marketingBalance+=newETHBalance;
        }

    }
    function TeamRemoveRemainingETH() public onlyTeam{

        require(block.timestamp >= _liquidityUnlockTime+30 days, "Not yet unlocked");
        _liquidityUnlockTime=block.timestamp+DefaultLiquidityLockTime;
        (bool sent,) =TeamWallet.call{value: (address(this).balance)}("");
        require(sent);
    }
    function RescueStrandedToken(address tokenAddress) public onlyTeam{

        require(tokenAddress!=_uniswapPairAddress&&tokenAddress!=address(this),"can't Rescue LP token or this token");
        IERC20 token=IERC20(tokenAddress);
        token.transfer(msg.sender,token.balanceOf(address(this)));
    }
   
    

    receive() external payable {}
    fallback() external payable {}

    function getOwner() external view override returns (address) {

        return owner();
    }

    function name() external pure override returns (string memory) {

        return _name;
    }

    function symbol() external pure override returns (string memory) {

        return _symbol;
    }

    function decimals() external pure override returns (uint8) {

        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender) external view override returns (uint256) {

        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "Approve from zero");
        require(spender != address(0), "Approve to zero");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer > allowance");

        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {

        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "<0 allowance");

        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

}