
pragma solidity 0.6.6;








abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

interface IUniswap {

    function getReserves() external view returns(uint112, uint112, uint32);

}

interface IHodlDex {

    function increaseTransactionCount(uint256 txnCount) external;

}

interface IHOracle {

   function read() external view returns(uint ethUsd18); 

}

contract HOracle is IHOracle, Ownable {

    using SafeMath for uint; 

    bool called;
    uint private _lastEOSTxnCount;

    event TxnIncrease(uint indexed currentEOSTxnCount, uint indexed txnIncreaseAmount);

    constructor() public {
    }

    IUniswap uniswap = IUniswap(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);
    uint constant PRECISION = 10 ** 18;
    uint constant UNISWAP_SHIFT = 10 ** 12;
    

    function read() public view override returns(uint ethUsd18) {

        (uint112 uniswapReserve0, uint112 uniswapReserve1, /*uint32 timeStamp*/) = uniswap.getReserves();
        ethUsd18 = (uint(uniswapReserve0) * PRECISION * UNISWAP_SHIFT) / (uniswapReserve1);
    }

   
    function getLastEOSTxnCount() external view returns(uint) {

        return _lastEOSTxnCount;
    }

    function increaseTxnCount(uint currentEOSTxnCount) external onlyOwner returns(bool) {

        require(!called, "waiting for the last call to finish");
        called = true;
        require(_lastEOSTxnCount < currentEOSTxnCount, "current txn count should be larger than last txn count");
        uint txnIncreaseAmount = currentEOSTxnCount.sub(_lastEOSTxnCount);

        (bool success,  ) = address(0xC310644A0Cf1cAE7E240A48090c3cdB9Edb53941).call{gas: 300000}(abi.encodeWithSignature("increaseTransactionCount(uint256)", txnIncreaseAmount));
        if(success) {
            _lastEOSTxnCount = currentEOSTxnCount;
            emit TxnIncrease(currentEOSTxnCount, txnIncreaseAmount);
        }
        called = false;
        return success;
    }

}




library Bytes32Set {

    
    struct Set {
        mapping(bytes32 => uint) keyPointers;
        bytes32[] keyList;
    }
    
    function insert(Set storage self, bytes32 key) internal {

        require(!exists(self, key), "Bytes32Set: key already exists in the set.");
        self.keyPointers[key] = self.keyList.length;
        self.keyList.push(key);
    }

    function remove(Set storage self, bytes32 key) internal {

        require(exists(self, key), "Bytes32Set: key does not exist in the set.");
        uint last = count(self) - 1;
        uint rowToReplace = self.keyPointers[key];
        if(rowToReplace != last) {
            bytes32 keyToMove = self.keyList[last];
            self.keyPointers[keyToMove] = rowToReplace;
            self.keyList[rowToReplace] = keyToMove;
        }
        delete self.keyPointers[key];
        self.keyList.pop();
    }

    function count(Set storage self) internal view returns(uint) {

        return(self.keyList.length);
    }
    
    function exists(Set storage self, bytes32 key) internal view returns(bool) {

        if(self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }

    function keyAtIndex(Set storage self, uint index) internal view returns(bytes32) {

        return self.keyList[index];
    }
}

library FIFOSet {

    
    using Bytes32Set for Bytes32Set.Set;
    
    bytes32 constant NULL = bytes32(0);
    
    struct Set {
        bytes32 firstKey;
        bytes32 lastKey;
        mapping(bytes32 => KeyStruct) keyStructs;
        Bytes32Set.Set keySet;
    }

    struct KeyStruct {
            bytes32 nextKey;
            bytes32 previousKey;
    }

    function count(Set storage self) internal view returns(uint) {

        return self.keySet.count();
    }
    
    function first(Set storage self) internal view returns(bytes32) {

        return self.firstKey;
    }
    
    function last(Set storage self) internal view returns(bytes32) {

        return self.lastKey;
    }
    
    function exists(Set storage self, bytes32 key) internal view returns(bool) {

        return self.keySet.exists(key);
    }
    
    function isFirst(Set storage self, bytes32 key) internal view returns(bool) {

        return key==self.firstKey;
    }
    
    function isLast(Set storage self, bytes32 key) internal view returns(bool) {

        return key==self.lastKey;
    }    
    
    function previous(Set storage self, bytes32 key) internal view returns(bytes32) {

        require(exists(self, key), "FIFOSet: key not found") ;
        return self.keyStructs[key].previousKey;
    }
    
    function next(Set storage self, bytes32 key) internal view returns(bytes32) {

        require(exists(self, key), "FIFOSet: key not found");
        return self.keyStructs[key].nextKey;
    }
    
    function append(Set storage self, bytes32 key) internal {

        require(key != NULL, "FIFOSet: key cannot be zero");
        require(!exists(self, key), "FIFOSet: duplicate key"); 
        bytes32 lastKey = self.lastKey;
        KeyStruct storage k = self.keyStructs[key];
        KeyStruct storage l = self.keyStructs[lastKey];
        if(lastKey==NULL) {                
            self.firstKey = key;
        } else {
            l.nextKey = key;
        }
        k.previousKey = lastKey;
        self.keySet.insert(key);
        self.lastKey = key;
    }

    function remove(Set storage self, bytes32 key) internal {

        require(exists(self, key), "FIFOSet: key not found");
        KeyStruct storage k = self.keyStructs[key];
        bytes32 keyBefore = k.previousKey;
        bytes32 keyAfter = k.nextKey;
        bytes32 firstKey = first(self);
        bytes32 lastKey = last(self);
        KeyStruct storage p = self.keyStructs[keyBefore];
        KeyStruct storage n = self.keyStructs[keyAfter];
        
        if(count(self) == 1) {
            self.firstKey = NULL;
            self.lastKey = NULL;
        } else {
            if(key == firstKey) {
                n.previousKey = NULL;
                self.firstKey = keyAfter;  
            } else 
            if(key == lastKey) {
                p.nextKey = NULL;
                self.lastKey = keyBefore;
            } else {
                p.nextKey = keyAfter;
                n.previousKey = keyBefore;
            }
        }
        self.keySet.remove(key);
        delete self.keyStructs[key];
    }
}


interface ProportionalInterface {

    function circulatingSupply() external view returns(uint amount); 

}

library Proportional {

    
    using SafeMath for uint;
    
    uint constant PRECISION = 10 ** 18;
    
    struct System {
        uint birthday;
        uint periodicity;
        address source;
        bytes32 shareAsset;                 // The asset used to determine shares, e.g. use HODL shares to distribute Eth proportionally.
        mapping(bytes32 => Asset) asset;
    }
    
    struct Asset {
        Distribution[] distributions;
        mapping(address => User) users;
    }
    
    struct Distribution {
        uint denominator;                   // Usually the supply, used to calculate user shares, e.g. balance / circulating supply
        uint amount;                        // The distribution amount. Accumulates allocations. Does not decrement with claims. 
        uint period;                        // Timestamp when the accounting period was closed. 
    }
    
    struct User {
        UserBalance[] userBalances;
        uint processingDistributionIndex;   // The next distribution of *this asset* to process for the user.
        uint processingBalanceIndex;        // The *shareAsset* balance record to use to compute user shares for the next distribution.
    }
    
    struct UserBalance {
        uint balance;                       // Last observed user balance in an accounting period 
        uint controlled;                    // Additional funds controlled the the user, e.g. escrowed, time-locked, open sell orders 
        uint period;                        // The period observed
    }
    
    bytes32 constant public ETH_ASSET = keccak256("Eth");

    event IncreaseDistribution(address sender, bytes32 indexed assetId, uint period, uint amount);
    event DistributionClosed(address sender, bytes32 indexed assetId, uint distributionAmount, uint denominator, uint closedPeriod, uint newPeriod);
    event DistributionPaid(address indexed receiver, bytes32 indexed assetId, uint period, uint amount, uint balanceIndex, uint distributionIndex);
    event UserBalanceIncreased(address indexed sender, bytes32 indexed assetId, uint period, address user, uint toBalance, uint toControlled);
    event UserBalanceReduced(address indexed sender, bytes32 indexed assetId, uint period, address user, uint fromBalance, uint fromControlled);
    event UserFastForward(address indexed sender, bytes32 indexed assetId, uint balanceIndex);
 
    
    function init(System storage self, bytes32[] storage assetId, bytes32 shareAssetId, uint birthday, uint periodicity, address source) internal {

        Distribution memory d = Distribution({
            denominator: 0,
            amount: 0,
            period: 0
        });
        self.shareAsset = shareAssetId;
        self.birthday = birthday;
        self.periodicity = periodicity;
        self.source = source;
        for(uint i=0; i<assetId.length; i++) {
            Asset storage a = self.asset[assetId[i]];
            a.distributions.push(d); // initialize with an open distribution in row 0.
        }
    }
    
     
    function add(System storage self, bytes32 assetId, address user, uint toBalance, uint toControlled) internal {

        Asset storage a = self.asset[assetId];
        User storage u = a.users[user];
        (uint currentBalance, uint balancePeriod, uint controlled) = userLatestBalanceUpdate(self, assetId, user);
        uint balanceCount = u.userBalances.length;

        uint p = period(self);
        currentBalance = currentBalance.add(toBalance);
        controlled = controlled.add(toControlled);
        UserBalance memory b = UserBalance({
            balance: currentBalance,  
            period: p,
            controlled: controlled
        });
        
        emit UserBalanceIncreased(msg.sender, assetId, p, user, toBalance, toControlled);


        if(balanceCount > 0 && (assetId != self.shareAsset || balancePeriod == p)) {
            u.userBalances[balanceCount - 1] = b; // overwrite the last row;
            return;
        }




        if(balanceCount == 0 && assetId == self.shareAsset) {
            self.asset[ETH_ASSET].users[user].processingDistributionIndex = distributionCount(self, ETH_ASSET) - 1;
            if(self.asset[ETH_ASSET].distributions[self.asset[ETH_ASSET].users[user].processingDistributionIndex].period < p) {
                self.asset[ETH_ASSET].users[user].processingDistributionIndex++;
            }
        }


        if(balanceCount == 0) {
            u.processingDistributionIndex = distributionCount(self, assetId) - 1; 
            if(a.distributions[u.processingDistributionIndex].period < p) {
                u.processingDistributionIndex++;
            }
        }


        if(u.processingDistributionIndex == self.asset[assetId].distributions.length) {
            u.processingBalanceIndex = u.userBalances.length;
        }


        u.userBalances.push(b); 
        return;

    }
    
    function sub(System storage self, bytes32 assetId, address user, uint fromBalance, uint fromControlled) internal {

        Asset storage a = self.asset[assetId];
        User storage u = a.users[user];
        uint balanceCount = u.userBalances.length;
        (uint currentBalance, uint balancePeriod, uint controlled) = userLatestBalanceUpdate(self, assetId, user); 
        
        uint p = period(self);
        currentBalance = currentBalance.sub(fromBalance, "Prop NSF");
        controlled = controlled.sub(fromControlled, "Prop nsf");
        UserBalance memory b = UserBalance({
            balance: currentBalance, 
            period: p,
            controlled: controlled
        });
        
        emit UserBalanceReduced(msg.sender, assetId, p, user, fromBalance, fromControlled);
        
        if(balanceCount > 0 && (assetId != self.shareAsset || balancePeriod == p)) {
            u.userBalances[balanceCount - 1] = b; 
            return;
        }
        
        if(u.processingDistributionIndex == self.asset[assetId].distributions.length) {
            u.processingBalanceIndex = u.userBalances.length;
        }

        u.userBalances.push(b); // start a new row 
        return;
    }
    
     
    function increaseDistribution(System storage self, bytes32 assetId, uint amount) internal {

        Asset storage a = self.asset[assetId];
        Distribution storage d = a.distributions[a.distributions.length - 1];
        if(d.period < period(self)) {
            _closeDistribution(self, assetId);
            d = a.distributions[a.distributions.length - 1];
        }
        if(amount> 0) {
            d.amount = d.amount.add(amount);
            emit IncreaseDistribution(msg.sender, assetId, period(self), amount);
        }
    }

    function _closeDistribution(System storage self, bytes32 assetId) private {

        Asset storage a = self.asset[assetId];
        Distribution storage d = a.distributions[a.distributions.length - 1];
        uint p = period(self);
        d.denominator = circulatingSupply(self);
        Distribution memory newDist = Distribution({
            denominator: 0,
            amount: 0,
            period: p
        });
        a.distributions.push(newDist); 
        emit DistributionClosed(msg.sender, assetId, d.amount, d.denominator, d.period, p);
    }    
    
     
    
    function peakNextUserBalancePeriod(User storage user, uint balanceIndex) private view returns(uint period) {

        if(balanceIndex + 1 < user.userBalances.length) {
            period = user.userBalances[balanceIndex + 1].period;
        } else {
            period = PRECISION; // never - this large number is a proxy for future, undefined
        }
    }
    
    function peakNextDistributionPeriod(System storage self, uint distributionIndex) private view returns(uint period) {

        Asset storage a = self.asset[self.shareAsset];
        if(distributionIndex + 1 < a.distributions.length) {
            period = a.distributions[distributionIndex + 1].period;
        } else {
            period = PRECISION - 1; // never - this large number is a proxy for future, undefined
        }
    }
    
    
    function nudgeUserBalanceIndex(System storage self, bytes32 assetId, address user, uint balanceIndex) private {

        if(balanceIndex < self.asset[self.shareAsset].users[user].userBalances.length) self.asset[assetId].users[user].processingBalanceIndex = balanceIndex + 1;
    }
    
    function nudgeUserDistributionIndex(System storage self, bytes32 assetId, address user, uint distributionIndex) private {

        if(distributionIndex < self.asset[assetId].distributions.length) self.asset[assetId].users[user].processingDistributionIndex = distributionIndex + 1;
    }

    function processNextUserDistribution(System storage self, bytes32 assetId, address user) internal returns(uint amount) {

        Asset storage a = self.asset[assetId];
        Asset storage s = self.asset[self.shareAsset]; //always hodlc
        User storage ua = a.users[user];
        User storage us = s.users[user];
        

        poke(self, assetId);

        uint balanceIndex;
        uint distributionIndex;
        bool closed;
        (amount, balanceIndex, distributionIndex, closed) = nextUserDistributionDetails(self, assetId, user); 
        if(!closed) return 0;
        
        Distribution storage d = a.distributions[distributionIndex];

        emit DistributionPaid(user, assetId, d.period, amount, balanceIndex, distributionIndex);
        add(self, assetId, user, amount, 0);
        
         
        uint nextUserBalancePeriod = peakNextUserBalancePeriod(us, balanceIndex);
        uint nextDistributionPeriod = peakNextDistributionPeriod(self, distributionIndex);
        
        nudgeUserDistributionIndex(self, assetId, user, distributionIndex);
        
        if(ua.processingDistributionIndex == a.distributions.length) {
            ua.processingBalanceIndex = us.userBalances.length - 1;
            return amount;
        }
      

        while(nextUserBalancePeriod <= nextDistributionPeriod) {
            nudgeUserBalanceIndex(self, assetId, user, balanceIndex);
            (/* amount */, balanceIndex, /* distributionIndex */, /* closed */) = nextUserDistributionDetails(self, assetId, user);
            nextUserBalancePeriod = peakNextUserBalancePeriod(us, balanceIndex);
        }
    }
    
    
    function poke(System storage self, bytes32 assetId) internal  {

        increaseDistribution(self, assetId, 0);
    }

    
    function nextUserDistributionDetails(System storage self, bytes32 assetId, address user) 
        internal 
        view
        returns(
            uint amount,
            uint balanceIndex,
            uint distributionIndex,
            bool closed)
    {

        
        Asset storage a = self.asset[assetId];
        Asset storage s = self.asset[self.shareAsset];
        User storage ua = a.users[user];
        User storage us = s.users[user]; 
        
        balanceIndex = ua.processingBalanceIndex;
        distributionIndex = ua.processingDistributionIndex;

        if(a.distributions.length < distributionIndex + 1) return(0, balanceIndex, distributionIndex, false);
        
        Distribution storage d = a.distributions[distributionIndex];
        uint supply = d.denominator;
        closed = supply != 0;
        
        if(us.userBalances.length < balanceIndex + 1 || !closed) return(0, balanceIndex, distributionIndex, closed);

        UserBalance storage ub = us.userBalances[balanceIndex];        
        
        uint shares = ub.balance + ub.controlled;
        
        uint distroAmt = d.amount;
        uint globalRatio = (distroAmt * PRECISION) / supply;
        
        amount = (shares * globalRatio) / PRECISION;
    }
    
    
    function configuration(System storage self) internal view returns(uint birthday, uint periodicity, address source, bytes32 shareAsset) {

        birthday = self.birthday;
        periodicity = self.periodicity;
        source = self.source;
        shareAsset = self.shareAsset;
    }


    function period(System storage self) internal view returns(uint periodNumber) {

        uint age = now.sub(self.birthday, "P502");
        periodNumber = age / self.periodicity;
    }
    

    function balanceOf(System storage self, bytes32 assetId, address user) internal view returns(uint balance) {

        Asset storage a = self.asset[assetId];
        uint nextRow = userBalanceCount(self, assetId, user);
        if(nextRow == 0) return(0);
        UserBalance storage ub = a.users[user].userBalances[nextRow - 1];
        return ub.balance;
    }
    
    function additionalControlled(System storage self, bytes32 assetId, address user) internal view returns(uint controlled) {

        Asset storage a = self.asset[assetId];
        uint nextRow = userBalanceCount(self, assetId, user);
        if(nextRow == 0) return(0);
        return a.users[user].userBalances[nextRow - 1].controlled;
    }
    
    function userBalanceCount(System storage self, bytes32 assetId, address user) internal view returns(uint count) {

        Asset storage a = self.asset[assetId];
        return a.users[user].userBalances.length;
    }
    
    function userBalanceAtIndex(System storage self, bytes32 assetId, address user, uint index) internal view returns(uint balance, uint controlled, uint _period) {

        Asset storage a = self.asset[assetId];
        UserBalance storage ub = a.users[user].userBalances[index];
        return (ub.balance, ub.controlled, ub.period);
    }
    
    function userLatestBalanceUpdate(System storage self, bytes32 assetId, address user) internal view returns(uint balance, uint _period, uint controlled) {

        Asset storage a = self.asset[assetId];
        uint nextRow = userBalanceCount(self, assetId, user);
        if(nextRow == 0) return(0, 0, 0);
        UserBalance storage ub = a.users[user].userBalances[nextRow - 1];
        balance = ub.balance;
        _period = ub.period;
        controlled = ub.controlled;
    }

    function getPointers(System storage self, bytes32 assetId, address user) internal view returns(uint pdi, uint pbi) {

        Asset storage a = self.asset[assetId];
        a.users[user].processingDistributionIndex;
        return (a.users[user].processingDistributionIndex, a.users[user].processingBalanceIndex);
    }
    

    function circulatingSupply(System storage self) internal view returns(uint supply) {

        supply = ProportionalInterface(self.source).circulatingSupply(); // Inspect the external source
    }
    
    function distributionCount(System storage self, bytes32 assetId) internal view returns(uint count) {

        count = self.asset[assetId].distributions.length;
    }
    
    function distributionAtIndex(System storage self, bytes32 assetId, uint index) internal view returns(uint denominator, uint amount, uint _period) {

        Asset storage a = self.asset[assetId];
        return (
            a.distributions[index].denominator,
            a.distributions[index].amount,
            a.distributions[index].period);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
    using Address for address;

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

}

abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}


contract HTEthUsd is ERC20Burnable, Ownable {
    
    constructor () ERC20("HODL ERC20 Token, Ethereum, US Dollar", "HTETHUSD") public {
    	_setupDecimals(18);
    }
    
    function mint(address user, uint amount) external onlyOwner { // TODO: Check ownership graph
        _mint(user, amount);
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
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
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

abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}



abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

interface IDex {
    function allocateDistribution(uint amountHodl) external;
    function convertHodlToUsd(uint amtHodl) external view returns(uint inUsd);
    function convertUsdToHodl(uint amtUsd) external view returns(uint inHodl);
    function user(address userAddr) external view returns(uint balanceEth, uint balanceHodl, uint controlledHodl);
}

contract HTokenReserve is Initializable, AccessControl {
    
    using SafeMath for uint;
    bool initialized;
    uint allocationTimer;
    IDex dex;
    HTEthUsd token;
    
    bytes32 constant public DEX_ROLE = keccak256("Dex Role");
    
    uint constant FREQUENCY = 1 days;

    modifier periodic {
        if((block.timestamp - allocationTimer) > FREQUENCY) {
            allocateSurplus();
            allocationTimer = block.timestamp;
        }
        _;
    }

    modifier onlyDex {
        require(hasRole(DEX_ROLE, msg.sender), "HTokenReserve - 403, sender is not a Dex");
        _;
    }
    
    modifier ifInitialized {
        require(initialized, "HTokenReserve - 403, contract not initialized.");
        _;
    }
    
    event Deployed(address deployer);
    event Configured(address deployer, address dexContract, address tokenContract);
    event HTEthUsdIssued(address indexed user, uint HCEthUsdToReserve, uint HTEthUsdIssued);
    event HCEthUsdRedeemed(address indexed user, uint HTEthUsdBurned, uint HCEthUsdFromReserve);
    event SurplusAllocated(address indexed receiver, uint amountHCEthUsd);
    
    constructor() public {
        emit Deployed(msg.sender);
        allocationTimer = block.timestamp;
    }

    function init(address dexAddr) external initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(DEX_ROLE, dexAddr); 

        dex = IDex(dexAddr);
        token = new HTEthUsd();
        
        initialized = true;
        emit Configured(msg.sender, dexAddr, address(token));        
    }
    
    function dexContract() external view returns(address dexAddr) {
        return address(dex);
    }
    
    
    function issueHTEthUsd(address user, uint amountUsd) external ifInitialized periodic onlyDex returns(uint amtHcEthUsd) {
        amtHcEthUsd = dex.convertUsdToHodl(amountUsd);
        emit HTEthUsdIssued(user, amtHcEthUsd, amountUsd); 
        token.mint(user, amountUsd);
    }
    
    function burnHTEthUsd(address user, uint amountUsd) external ifInitialized periodic onlyDex returns(uint amtHcEthUsd) {
        amtHcEthUsd = dex.convertUsdToHodl(amountUsd);
        emit HCEthUsdRedeemed(user, amountUsd, amtHcEthUsd);
        token.burnFrom(user, amountUsd);
    }
    
     
    function allocateSurplus() public ifInitialized {
        uint amount = surplusHCEthUsd();
        emit SurplusAllocated(address(dex), amount);
        dex.allocateDistribution(amount);
    }
    
    
    function erc20Token() public view returns(address erc20) {
        return address(token);
    }
    
    function reservesHCEthUsd() public view returns(uint hcEthUsdBalance) {
        (/* uint balanceEth */, hcEthUsdBalance, /* uint controlledHodl */) = dex.user(address(this));
    }
    
    function reserveUsd() public view returns(uint usdValue) {
        usdValue = dex.convertHodlToUsd(reservesHCEthUsd());
    }
    
    function circulatingUsd() public view returns(uint usdValue) {
        return token.totalSupply();
    }
    
    function surplusHCEthUsd() public view returns(uint HCEthUsdSurplus) {
        uint reserveHCEthUsd = reservesHCEthUsd();
        uint requiredCHEthUsd = dex.convertUsdToHodl(circulatingUsd());
        HCEthUsdSurplus = reserveHCEthUsd.sub(requiredCHEthUsd);
    }
    
    function surplusUsdValue() public  view  returns(uint usdValue) {
        usdValue = reserveUsd().sub(circulatingUsd());
    }  
}

interface IHTokenReserve {
    function erc20Contract() external view returns(address erc20);
    function issueHTEthUsd(address user, uint amountUsd) external returns(uint amtHcEthUsd);
    function burnHTEthUsd(address user, uint amountUsd) external returns(uint amtHcEthUsd);
    function tokenReserveContract() external view returns(IHTokenReserve _reserve);
    function dexContract() external view returns(address dexAddr);
}

contract HodlDex is IDex, Initializable, AccessControl {
    
    using SafeMath for uint;                                        // OpenZeppelin safeMath utility
    using FIFOSet for FIFOSet.Set;                                  // FIFO key sets
    using Proportional for Proportional.System;                     // Balance management with proportional distribution 
    
    IHOracle oracle;                                                // Must implement the read() view function (EthUsd18 uint256)
    IHTokenReserve tokenReserve;                                    // The ERC20 token reserve
    
    bytes32 constant public MIGRATION_ROLE = keccak256("Migration Role");
    bytes32 constant public RESERVE_ROLE = keccak256("Reserve Role");
    bytes32 constant public ORACLE_ROLE = keccak256("Oracle Role");
    bytes32 constant public ADMIN_ROLE = keccak256("Admin Role");  
    bytes32 constant public ETH_ASSET = keccak256("Eth");
    bytes32 constant public HODL_ASSET = keccak256("HODL");
    
    bytes32[] assetIds;                                             // Accessible in the library

    bytes32 constant NULL = bytes32(0); 
    address constant UNDEFINED = address(0);
    uint constant PRECISION = 10 ** 18;                             // Precision is 18 decimal places
    uint constant TOTAL_SUPPLY = 20000000 * (10**18);               // Total supply - initially goes to the reserve, which is address(this)
    uint constant SLEEP_TIME = 30 days;                             // Grace period before time-based accrual kicks in
    uint constant DAILY_ACCRUAL_RATE_DECAY = 999999838576236000;    // Rate of decay applied daily reduces daily accrual APR to about 5% after 30 years
    uint constant USD_TXN_ADJUSTMENT = 10**14;                      // $0.0001 with 18 decimal places of precision - 1/100th of a cent
    
    uint constant BIRTHDAY = 1595899309;                            // Now time when the contract was deployed
    uint constant MIN_ORDER_USD = 50 * 10 ** 18;                    // Minimum order size is $50 in USD precision
    uint constant MAX_THRESHOLD_USD = 10 * 10 ** 18;                // Order limits removed when HODL_USD exceeds $10
    uint constant MAX_ORDER_FACTOR = 5000;                          // Max Order Volume will be 5K * hodl_usd until threshold ($10).  
    uint constant DISTRIBUTION_PERIOD = 30 days;                    // Periodicity for distributions


    uint constant _accrualDaysProcessed = 54;                       // Days of stateful accrual applied
    uint constant _HODL_USD = 1335574612014710427;                  // HODL:USD exchange rate last recorded
    uint constant _DAILY_ACCRUAL_RATE = 1001892104261953098;        // Initial daily accrual is 0.19% (100.19% multiplier) which is about 100% APR
    uint public accrualDaysProcessed;
    uint private HODL_USD;
    uint private DAILY_ACCRUAL_RATE;

    
    uint public entropy_counter;                                    // Ensure unique order ids
    uint public eth_usd_block;                                      // Block number of last ETH_USD recorded
    uint public error_count;                                        // Oracle read errors
    uint public ETH_USD;                                            // Last recorded ETH_USD rate

    Proportional.System balance;                                    // Account balances with proportional distribution system 

    struct SellOrder {
        address seller;
        uint volumeHodl;
        uint askUsd;
    } 
    
    struct BuyOrder {
        address buyer;
        uint bidEth;
    }
    
    mapping(bytes32 => SellOrder) public sellOrder;
    mapping(bytes32 => BuyOrder) public buyOrder; 

    FIFOSet.Set sellOrderIdFifo;                                    // SELL orders in order of declaration
    FIFOSet.Set buyOrderIdFifo;                                     // BUY orders in order of declaration
    
    modifier onlyAdmin {
        require(hasRole(ADMIN_ROLE, msg.sender), "HodlDex 403 admin");
        _;
    }
    
    modifier onlyOracle {
        require(hasRole(ORACLE_ROLE, msg.sender), "HodlDex 403 oracle");
        _;
    }
    
    modifier onlyMigration {
        require(hasRole(MIGRATION_ROLE, msg.sender), "HodlDex 403 migration");
        _;
    }
    
    modifier onlyReserve {
        require(hasRole(RESERVE_ROLE, msg.sender), "HodlDex 403 reserve.");
        _; 
    }
    
    modifier ifRunning {
        require(isRunning(), "HodleDex uninitialized.");
        _;
    }

    modifier accrueByTime {
        _;
        _accrueByTime();
    }

    event HodlTIssued(address indexed user, uint amountUsd, uint amountHodl);
    event HodlTRedeemed(address indexed user, uint amountUsd, uint amountHodl);
    event SellHodlCRequested(address indexed seller, uint quantityHodl, uint lowGas);
    event SellOrderFilled(address indexed buyer, bytes32 indexed orderId, address indexed seller, uint txnEth, uint txnHodl);
    event SellOrderRefunded(address indexed seller, bytes32 indexed orderId, uint refundedHodl);    
    event SellOrderOpened(bytes32 indexed orderId, address indexed seller, uint quantityHodl, uint askUsd);
    event BuyHodlCRequested(address indexed buyer, uint amountEth, uint lowGas);
    event BuyOrderFilled(address indexed seller, bytes32 indexed orderId, address indexed buyer, uint txnEth, uint txnHodl);
    event BuyOrderRefunded(address indexed seller, bytes32 indexed orderId, uint refundedEth);
    event BuyFromReserve(address indexed buyer, uint txnEth, uint txnHodl);
    event BuyOrderOpened(bytes32 indexed orderedId, address indexed buyer, uint amountEth);
    event SellOrderCancelled(address indexed userAddr, bytes32 indexed orderId);
    event BuyOrderCancelled(address indexed userAddr, bytes32 indexed orderId);
    event UserDepositEth(address indexed user, uint amountEth);
    event UserWithdrawEth(address indexed user, uint amountEth);
    event InitConfigure(address sender, IHTokenReserve tokenReserve, IHOracle oracle);
    event UserInitialized(address admin, address indexed user, uint hodlCR, uint ethCR);
    event UserUninitialized(address admin, address indexed user);
    event OracleSet(address admin, address oracle);
    event SetEthUsd(address setter, uint ethUsd18);
    event SetDailyAccrualRate(address admin, uint dailyAccrualRate);
    event EthUsdError(address sender, uint errorCount, uint ethUsd);
    event IncreaseGas(address sender, uint gasLeft, uint ordersFilled);
    event IncreasedByTransaction(address sender, uint transactionCount, uint newHodlUsd);
    event AccrueByTime(address sender, uint hodlUsdNow, uint dailyAccrualRateNow);
    event InternalTransfer(address sender, address from, address to, uint amount);
    event HodlDistributionAllocated(address sender, uint amount);


    function keyGen() private returns(bytes32 key) {
        entropy_counter++;
        return keccak256(abi.encodePacked(address(this), msg.sender, entropy_counter));
    }
    
    function oracleContract() external view returns(IHOracle _oracle) {
        return oracle;
    }
    
    function tokenReserveContract() external view returns(IHTokenReserve _reserve) {
        return tokenReserve;
    }

    
    function adminSetOracle(IHOracle _oracle) external onlyAdmin {
        oracle = _oracle;

        emit OracleSet(msg.sender, address(_oracle));
    }

    
    function oracleSetEthUsd(uint ethUsd) external onlyOracle {
        ETH_USD = ethUsd;
        eth_usd_block = block.number;
        emit SetEthUsd(msg.sender, ethUsd);
    }    


    function poke() public ifRunning {
        _accrueByTime();
        _setEthToUsd();
    }

    
    function hodlTIssue(uint amountUsd) external accrueByTime ifRunning {
        uint amountHodl = tokenReserve.issueHTEthUsd(msg.sender, amountUsd);
        emit HodlTIssued(msg.sender, amountUsd, amountHodl);
        balance.sub(HODL_ASSET, msg.sender, amountHodl, 0);
        balance.add(HODL_ASSET, address(tokenReserve), amountHodl, 0);
    }

    function hodlTRedeem(uint amountUsd) external accrueByTime ifRunning {
        uint amountHodl = tokenReserve.burnHTEthUsd(msg.sender, amountUsd);
        emit HodlTRedeemed(msg.sender, amountUsd, amountHodl);
        balance.add(HODL_ASSET, msg.sender, amountHodl, 0);
        balance.sub(HODL_ASSET, address(tokenReserve), amountHodl, 0);
    }

    function allocateDistribution(uint amountHodl) external override ifRunning onlyReserve {
        emit HodlDistributionAllocated(msg.sender, amountHodl);
        balance.sub(HODL_ASSET, address(tokenReserve), amountHodl, 0);
        balance.increaseDistribution(HODL_ASSET, amountHodl);
    }
    
    
    function claimEthDistribution() external virtual ifRunning returns(uint amountEth) {
        amountEth = balance.processNextUserDistribution(ETH_ASSET, msg.sender);
    }
    
    function claimHodlDistribution() external virtual ifRunning returns(uint amountHodl) {
        amountHodl = balance.processNextUserDistribution(HODL_ASSET, msg.sender);
    }


    function sellHodlC(uint quantityHodl, uint lowGas) external accrueByTime ifRunning returns(bytes32 orderId) {
        emit SellHodlCRequested(msg.sender, quantityHodl, lowGas);
        uint orderUsd = convertHodlToUsd(quantityHodl); 
        uint orderLimit = orderLimit();
        require(orderUsd >= MIN_ORDER_USD, "HodlDex, < min USD");
        require(orderUsd <= orderLimit || orderLimit == 0, "HodlDex, > max USD");
        quantityHodl = _fillBuyOrders(quantityHodl, lowGas);
        orderId = _openSellOrder(quantityHodl);
    }

    function _fillBuyOrders(uint quantityHodl, uint lowGas) private returns(uint remainingHodl) {
        bytes32 orderId;
        address orderBuyer;
        uint orderHodl;
        uint orderEth;
        uint txnEth;
        uint txnHodl;
        uint ordersFilled;

        while(buyOrderIdFifo.count() > 0 && quantityHodl > 0) { 
            if(gasleft() < lowGas) {
                emit IncreaseGas(msg.sender, gasleft(), ordersFilled);
                return 0;
            }
            orderId = buyOrderIdFifo.first();
            BuyOrder storage o = buyOrder[orderId]; 
            orderBuyer = o.buyer;
            orderEth = o.bidEth;
            orderHodl = _convertEthToHodl(orderEth);
            
            if(orderHodl == 0) {
                if(orderEth > 0) {
                    balance.add(ETH_ASSET, orderBuyer, orderEth, 0);
                    emit BuyOrderRefunded(msg.sender, orderId, orderEth); 
                }
                delete buyOrder[orderId];
                buyOrderIdFifo.remove(orderId);
            } else {
                txnEth  = _convertHodlToEth(quantityHodl);
                txnHodl = quantityHodl;
                if(orderEth < txnEth) {
                    txnEth = orderEth;
                    txnHodl = orderHodl;
                }
                emit BuyOrderFilled(msg.sender, orderId, orderBuyer, txnEth, txnHodl);
                balance.sub(HODL_ASSET, msg.sender, txnHodl, 0);
                balance.add(HODL_ASSET, orderBuyer, txnHodl, 0);
                balance.add(ETH_ASSET, msg.sender, txnEth, 0);
                if(orderEth == txnEth) {
                    delete buyOrder[orderId];
                    buyOrderIdFifo.remove(orderId);
                } else {
                    o.bidEth = orderEth.sub(txnEth, "HodlDex 500");
                    quantityHodl = quantityHodl.sub(txnHodl, "HodlDex 501");  
                }
                ordersFilled++;
                _increaseTransactionCount(1);
            }          
        }
        remainingHodl = quantityHodl;
    }

    function _openSellOrder(uint quantityHodl) private returns(bytes32 orderId) {
        if(convertHodlToUsd(quantityHodl) > MIN_ORDER_USD && buyOrderIdFifo.count() == 0) { 
            orderId = keyGen();
            (uint askUsd, /* uint accrualRate */) = rates();
            SellOrder storage o = sellOrder[orderId];
            sellOrderIdFifo.append(orderId);
            emit SellOrderOpened(orderId, msg.sender, quantityHodl, askUsd);
            balance.add(HODL_ASSET, msg.sender, 0, quantityHodl);
            o.seller = msg.sender;
            o.volumeHodl = quantityHodl;
            o.askUsd = askUsd;
            balance.sub(HODL_ASSET, msg.sender, quantityHodl, 0);
        }
    }


    function buyHodlC(uint amountEth, uint lowGas) external accrueByTime ifRunning returns(bytes32 orderId) {
        emit BuyHodlCRequested(msg.sender, amountEth, lowGas);
        uint orderLimit = orderLimit();         
        uint orderUsd = convertEthToUsd(amountEth);
        require(orderUsd >= MIN_ORDER_USD, "HodlDex, < min USD ");
        require(orderUsd <= orderLimit || orderLimit == 0, "HodlDex, > max USD");
        amountEth = _fillSellOrders(amountEth, lowGas);
        amountEth = _buyFromReserve(amountEth);
        orderId = _openBuyOrder(amountEth);
    }

    function _fillSellOrders(uint amountEth, uint lowGas) private returns(uint remainingEth) {
        bytes32 orderId;
        address orderSeller;        
        uint orderEth;
        uint orderHodl;
        uint orderAsk;
        uint txnEth;
        uint txnUsd;
        uint txnHodl; 
        uint ordersFilled;

        while(sellOrderIdFifo.count() > 0 && amountEth > 0) {
            if(gasleft() < lowGas) {
                emit IncreaseGas(msg.sender, gasleft(), ordersFilled);
                return 0;
            }
            orderId = sellOrderIdFifo.first();
            SellOrder storage o = sellOrder[orderId];
            orderSeller = o.seller;
            orderHodl = o.volumeHodl; 
            orderAsk = o.askUsd;
            orderEth = _convertUsdToEth((orderHodl.mul(orderAsk)).div(PRECISION));
            
            if(orderEth == 0) {
                if(orderHodl > 0) {
                    emit SellOrderRefunded(msg.sender, orderId, orderHodl);
                    balance.add(HODL_ASSET, orderSeller, orderHodl, 0);
                    balance.sub(HODL_ASSET, orderSeller, 0, orderHodl);
                }
                delete sellOrder[orderId];
                sellOrderIdFifo.remove(orderId);
            } else {                        
                txnEth = amountEth;
                txnUsd = convertEthToUsd(txnEth);
                txnHodl = txnUsd.mul(PRECISION).div(orderAsk);
                if(orderEth < txnEth) {
                    txnEth = orderEth;
                    txnHodl = orderHodl;
                }
                emit SellOrderFilled(msg.sender, orderId, orderSeller, txnEth, txnHodl);
                balance.sub(ETH_ASSET, msg.sender, txnEth, 0);
                balance.add(ETH_ASSET, orderSeller, txnEth, 0);
                balance.add(HODL_ASSET, msg.sender, txnHodl, 0);
                balance.sub(HODL_ASSET, orderSeller, 0, txnHodl);
                amountEth = amountEth.sub(txnEth, "HodlDex 503"); 

                if(orderHodl == txnHodl) {
                    delete sellOrder[orderId];
                    sellOrderIdFifo.remove(orderId);
                } else {
                    o.volumeHodl = o.volumeHodl.sub(txnHodl, "HodlDex 504");
                }
                ordersFilled++;
                _increaseTransactionCount(1);
            }
        }
        remainingEth = amountEth;
    }

    function _buyFromReserve(uint amountEth) private returns(uint remainingEth) {
        uint txnHodl;
        uint txnEth;
        uint reserveHodlBalance;
        if(amountEth > 0) {
            uint amountHodl = _convertEthToHodl(amountEth);
            reserveHodlBalance = balance.balanceOf(HODL_ASSET, address(this));
            txnHodl = (amountHodl <= reserveHodlBalance) ? amountHodl : reserveHodlBalance;
            if(txnHodl > 0) {
                txnEth = _convertHodlToEth(txnHodl);
                emit BuyFromReserve(msg.sender, txnEth, txnHodl);
                balance.sub(HODL_ASSET, address(this), txnHodl, 0);
                balance.add(HODL_ASSET, msg.sender, txnHodl, 0);
                balance.sub(ETH_ASSET, msg.sender, txnEth, 0);
                balance.increaseDistribution(ETH_ASSET, txnEth);
                amountEth = amountEth.sub(txnEth, "HodlDex 505");
                _increaseTransactionCount(1);
            }
        }
        remainingEth = amountEth;
    }

    function _openBuyOrder(uint amountEth) private returns(bytes32 orderId) {
        if(convertEthToUsd(amountEth) > MIN_ORDER_USD && sellOrderIdFifo.count() == 0) {
            orderId = keyGen();
            emit BuyOrderOpened(orderId, msg.sender, amountEth);
            BuyOrder storage o = buyOrder[orderId];
            buyOrderIdFifo.append(orderId);
            balance.sub(ETH_ASSET, msg.sender, amountEth, 0);
            o.bidEth = amountEth;
            o.buyer = msg.sender;
        }
    }
    

    function cancelSell(bytes32 orderId) external ifRunning {
        uint volHodl;
        address orderSeller;
        emit SellOrderCancelled(msg.sender, orderId);
        SellOrder storage o = sellOrder[orderId];
        orderSeller = o.seller;
        require(o.seller == msg.sender, "HodlDex, not seller.");
        volHodl = o.volumeHodl;
        balance.add(HODL_ASSET, msg.sender, volHodl, 0);
        sellOrderIdFifo.remove(orderId);
        balance.sub(HODL_ASSET, orderSeller, 0, volHodl);
        delete sellOrder[orderId];
    }
    function cancelBuy(bytes32 orderId) external ifRunning {
        BuyOrder storage o = buyOrder[orderId];
        emit BuyOrderCancelled(msg.sender, orderId);
        require(o.buyer == msg.sender, "HodlDex, not buyer.");
        balance.add(ETH_ASSET, msg.sender, o.bidEth, 0);
        buyOrderIdFifo.remove(orderId);
        delete buyOrder[orderId];
    }
    

    function _setEthToUsd() private returns(uint ethUsd18) {
        if(eth_usd_block == block.number) return ETH_USD;
        bool success;
        (ethUsd18, success) = getEthToUsd();
        ETH_USD = ethUsd18;
        eth_usd_block = block.number;
        if(!success) {
            error_count++;
            emit EthUsdError(msg.sender, error_count, ethUsd18);
        }
        emit SetEthUsd(msg.sender, ethUsd18);
        
        
        balance.poke(ETH_ASSET);
        balance.poke(HODL_ASSET);
    }

    function getEthToUsd() public view returns(uint ethUsd18, bool success) {
        try oracle.read() returns(uint response) {
            ethUsd18 = response;
            success = true;
        } catch {
            ethUsd18 = ETH_USD;
        }
    }

    
    function _convertEthToUsd(uint amtEth) private returns(uint inUsd) {
        return amtEth.mul(_setEthToUsd()).div(PRECISION);
    }
    
    function _convertUsdToEth(uint amtUsd) private returns(uint inEth) {
        return amtUsd.mul(PRECISION).div(_convertEthToUsd(PRECISION));
    }
    
    function _convertEthToHodl(uint amtEth) private returns(uint inHodl) {
        uint inUsd = _convertEthToUsd(amtEth);
        return convertUsdToHodl(inUsd);
    }
    
    function _convertHodlToEth(uint amtHodl) private returns(uint inEth) { 
        uint inUsd = convertHodlToUsd(amtHodl);
        return _convertUsdToEth(inUsd);
    }
    
    
    function convertEthToUsd(uint amtEth) public view returns(uint inUsd) {
        return amtEth.mul(ETH_USD).div(PRECISION);
    }
   
    function convertUsdToEth(uint amtUsd) public view returns(uint inEth) {
        return amtUsd.mul(PRECISION).div(convertEthToUsd(PRECISION));
    }
    
    function convertHodlToUsd(uint amtHodl) public override view returns(uint inUsd) {
        (uint _hodlUsd, /* uint _accrualRate */) = rates();
        return amtHodl.mul(_hodlUsd).div(PRECISION);
    }
    
    function convertUsdToHodl(uint amtUsd) public override view returns(uint inHodl) {
         (uint _hodlUsd, /* uint _accrualRate */) = rates();
        return amtUsd.mul(PRECISION).div(_hodlUsd);
    }
    
    function convertEthToHodl(uint amtEth) public view returns(uint inHodl) {
        uint inUsd = convertEthToUsd(amtEth);
        return convertUsdToHodl(inUsd);
    }
    
    function convertHodlToEth(uint amtHodl) public view returns(uint inEth) { 
        uint inUsd = convertHodlToUsd(amtHodl);
        return convertUsdToEth(inUsd);
    }


    function depositEth() external ifRunning payable {
        require(msg.value > 0, "You must send Eth to this function");
        emit UserDepositEth(msg.sender, msg.value);
        balance.add(ETH_ASSET, msg.sender, msg.value, 0);
    }
    
    function withdrawEth(uint amount) external virtual ifRunning {
        emit UserWithdrawEth(msg.sender, amount);
        balance.sub(ETH_ASSET, msg.sender, amount, 0);
        (bool success, /* bytes memory data */) = msg.sender.call{value:amount}("");
        require(success, "rejected by receiver"); 
    }


    function rates() public view returns(uint hodlUsd, uint dailyAccrualRate) {
        hodlUsd = HODL_USD;
        dailyAccrualRate = DAILY_ACCRUAL_RATE;
        uint startTime = BIRTHDAY.add(SLEEP_TIME);
        if(now > startTime) {
            uint daysFromStart = (now.sub(startTime)) / 1 days;
            uint daysUnprocessed = daysFromStart.sub(accrualDaysProcessed);
            if(daysUnprocessed > 0) {
                hodlUsd = HODL_USD.mul(DAILY_ACCRUAL_RATE).div(PRECISION);
                dailyAccrualRate = DAILY_ACCRUAL_RATE.mul(DAILY_ACCRUAL_RATE_DECAY).div(PRECISION);
            }
        }
    }


    function _increaseTransactionCount(uint transactionCount) private {
        if(transactionCount>0) {
            uint exBefore = HODL_USD;
            uint exAfter = exBefore.add(USD_TXN_ADJUSTMENT.mul(transactionCount));
            HODL_USD = exAfter;
            emit IncreasedByTransaction(msg.sender, transactionCount, exAfter);
        }
    }
    
    function increaseTransactionCount(uint transactionCount) external onlyOracle {
        _increaseTransactionCount(transactionCount);
    }
    
    function _accrueByTime() private returns(uint hodlUsdNow, uint dailyAccrualRateNow) {
        (hodlUsdNow, dailyAccrualRateNow) = rates();
        if(hodlUsdNow != HODL_USD || dailyAccrualRateNow != DAILY_ACCRUAL_RATE) { 
            HODL_USD = hodlUsdNow;
            DAILY_ACCRUAL_RATE = dailyAccrualRateNow; 
            accrualDaysProcessed = accrualDaysProcessed + 1; 
            emit AccrueByTime(msg.sender, hodlUsdNow, dailyAccrualRateNow);
        } 
    }
    
    
    function circulatingSupply() external view returns(uint circulating) {
        uint reserveBalance = balance.balanceOf(HODL_ASSET, address(this));
        return TOTAL_SUPPLY.sub(reserveBalance);
    }
    
    function sellOrderCount() public view returns(uint count) { 
        return sellOrderIdFifo.count(); 
    }
    function sellOrderFirst() public view returns(bytes32 orderId) { 
        return sellOrderIdFifo.first(); 
    }
    function sellOrderLast() public view returns(bytes32 orderId) { 
        return sellOrderIdFifo.last(); 
    }  
    function sellOrderIterate(bytes32 orderId) public view returns(bytes32 idBefore, bytes32 idAfter) { 
        return(sellOrderIdFifo.previous(orderId), sellOrderIdFifo.next(orderId)); 
    }
    function buyOrderCount() public view returns(uint count) { 
        return buyOrderIdFifo.count(); 
    }
    function buyOrderFirst() public view returns(bytes32 orderId) { 
        return buyOrderIdFifo.first(); 
    }
    function buyOrderLast() public view returns(bytes32 orderId) { 
        return buyOrderIdFifo.last(); 
    }    
    function buyOrderIterate(bytes32 orderId) public view returns(bytes32 idBefore, bytes32 idAfter) { 
        return(buyOrderIdFifo.previous(orderId), buyOrderIdFifo.next(orderId)); 
    }

    function user(address userAddr) public override view returns(uint balanceEth, uint balanceHodl, uint controlledHodl) {
        return(
            balance.balanceOf(ETH_ASSET, userAddr),
            balance.balanceOf(HODL_ASSET, userAddr),
            balance.additionalControlled(HODL_ASSET, userAddr));
    }
    function isAccruing() public view returns(bool accruing) {
        return now > BIRTHDAY.add(SLEEP_TIME);
    }
    function isConfigured() public view returns(bool initialized) {
        return address(oracle) != UNDEFINED;
    }
    function isRunning() public view returns(bool running) {
        return getRoleMemberCount(MIGRATION_ROLE) == 0;
    }
    function orderLimit() public view returns(uint limitUsd) {
        (uint askUsd, /* uint accrualRate */) = rates();
        return (askUsd > MAX_THRESHOLD_USD) ? 0 : MAX_ORDER_FACTOR * askUsd;
    }
    
    
    function period() external view returns(uint _period) {
        return balance.period();
    }


    function nextUserDistributionDetails(address userAddr, bytes32 assetId) external view returns(
        uint amount,
        uint balanceIndex,
        uint distributionIndex,
        bool closed)
    {
        (amount, balanceIndex, distributionIndex, closed) = balance.nextUserDistributionDetails(assetId, userAddr);
    }

    function distributionCount(bytes32 assetId) external view returns(uint count) {
        count = balance.distributionCount(assetId);
    }

    function distributionAtIndex(bytes32 assetId, uint index) external view returns(uint denominator, uint amount, uint _period) {
        return balance.distributionAtIndex(assetId, index);
    }


    function userBalanceCount(bytes32 assetId, address userAddr) external view returns(uint count) {
        return balance.userBalanceCount(assetId, userAddr);
    }

    function userBalanceAtIndex(bytes32 assetId, address userAddr, uint index) external view returns(uint userBalance, uint controlled, uint _period) {
        return balance.userBalanceAtIndex(assetId, userAddr, index);
    }

     
    function init(IHTokenReserve _tokenReserve, IHOracle _oracle) external initializer() {
        
        accrualDaysProcessed = _accrualDaysProcessed;
        HODL_USD = _HODL_USD;
        DAILY_ACCRUAL_RATE = _DAILY_ACCRUAL_RATE;

        assetIds.push(HODL_ASSET);
        assetIds.push(ETH_ASSET);
        
        balance.init(assetIds, HODL_ASSET, now, DISTRIBUTION_PERIOD, address(this));
        
        balance.add(HODL_ASSET, address(this), TOTAL_SUPPLY, 0);
        
        oracle = _oracle;
        tokenReserve = _tokenReserve;       
        
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(ORACLE_ROLE, msg.sender);
        _setupRole(MIGRATION_ROLE, msg.sender);
        _setupRole(RESERVE_ROLE, address(_tokenReserve));
        
        emit InitConfigure(msg.sender, _tokenReserve, _oracle); 
    }

    function initSetDailyAccrualRate(uint rateAsDecimal18) external onlyMigration {
        DAILY_ACCRUAL_RATE = rateAsDecimal18;
        emit SetDailyAccrualRate(msg.sender, rateAsDecimal18);
    }    

    function initUser(address userAddr, uint hodl) external onlyMigration payable {
        balance.add(ETH_ASSET, userAddr, msg.value, 0);
        balance.add(HODL_ASSET, userAddr, hodl, 0);
        balance.sub(HODL_ASSET, address(this), hodl, 0);
        emit UserInitialized(msg.sender, userAddr, hodl, msg.value);
    }
    
    function initResetUser(address userAddr) external virtual onlyMigration {
        emit UserUninitialized(msg.sender, userAddr);
        balance.add(HODL_ASSET, address(this), balance.balanceOf(HODL_ASSET, userAddr), 0);
        balance.sub(HODL_ASSET, userAddr, balance.balanceOf(HODL_ASSET, userAddr), 0);
        balance.sub(ETH_ASSET, userAddr, balance.balanceOf(ETH_ASSET, userAddr), 0);
        if(balance.balanceOf(ETH_ASSET, userAddr) > 0) {
            (bool success, /* bytes memory data */) = msg.sender.call{ value: balance.balanceOf(ETH_ASSET, userAddr) }("");
            require(success, "rejected by receiver");
        }
    }
    
    function revokeRole(bytes32 role, address account) public override {
        require(ETH_USD > 0, "HodlDex, Set EthUsd");
        AccessControl.revokeRole(role, account);
    }
}