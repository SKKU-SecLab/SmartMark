
pragma solidity 0.6.6;




library AddressSet {

    
    struct Set {
        mapping(address => uint) keyPointers;
        address[] keyList;
    }

    function insert(Set storage self, address key) internal {

        require(!exists(self, key), "AddressSet: key already exists in the set.");
        self.keyPointers[key] = self.keyList.length;
        self.keyList.push(key);
    }

    function remove(Set storage self, address key) internal {

        require(exists(self, key), "AddressSet: key does not exist in the set.");
        uint last = count(self) - 1;
        uint rowToReplace = self.keyPointers[key];
        if(rowToReplace != last) {
            address keyToMove = self.keyList[last];
            self.keyPointers[keyToMove] = rowToReplace;
            self.keyList[rowToReplace] = keyToMove;
        }
        delete self.keyPointers[key];
        self.keyList.pop;
    }

    function count(Set storage self) internal view returns(uint) {

        return(self.keyList.length);
    }

    function exists(Set storage self, address key) internal view returns(bool) {

        if(self.keyList.length == 0) return false;
        return self.keyList[self.keyPointers[key]] == key;
    }

    function keyAtIndex(Set storage self, uint index) internal view returns(address) {

        return self.keyList[index];
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

    
    using SafeMath for uint;
    using Bytes32Set for Bytes32Set.Set;
    
    bytes32 constant NULL = bytes32(0);
    
    struct FIFO {
        bytes32 firstKey;
        bytes32 lastKey;
        mapping(bytes32 => KeyStruct) keyStructs;
        Bytes32Set.Set keySet;
    }

    struct KeyStruct {
            bytes32 nextKey;
            bytes32 previousKey;
    }

    function count(FIFO storage self) internal view returns(uint) {

        return self.keySet.count();
    }
    
    function first(FIFO storage self) internal view returns(bytes32) {

        return self.firstKey;
    }
    
    function last(FIFO storage self) internal view returns(bytes32) {

        return self.lastKey;
    }
    
    function exists(FIFO storage self, bytes32 key) internal view returns(bool) {

        return self.keySet.exists(key);
    }
    
    function isFirst(FIFO storage self, bytes32 key) internal view returns(bool) {

        return key==self.firstKey;
    }
    
    function isLast(FIFO storage self, bytes32 key) internal view returns(bool) {

        return key==self.lastKey;
    }    
    
    function previous(FIFO storage self, bytes32 key) internal view returns(bytes32) {

        require(exists(self, key), "FIFOSet: key not found") ;
        return self.keyStructs[key].previousKey;
    }
    
    function next(FIFO storage self, bytes32 key) internal view returns(bytes32) {

        require(exists(self, key), "FIFOSet: key not found");
        return self.keyStructs[key].nextKey;
    }
    
    function append(FIFO storage self, bytes32 key) internal {

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

    function remove(FIFO storage self, bytes32 key) internal {

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




contract Context {

    constructor () internal { }

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
}

interface Maker {

    function read() external view returns(uint);

}

contract HodlDex is Ownable {

    
    using Address for address payable;                              // OpenZeppelin address utility
    using SafeMath for uint;                                        // OpenZeppelin safeMath utility
    using Bytes32Set for Bytes32Set.Set;                            // Unordered key sets
    using AddressSet for AddressSet.Set;                            // Unordered address sets
    using FIFOSet for FIFOSet.FIFO;                                 // FIFO key sets
    
    Maker maker = Maker(0x729D19f657BD0614b4985Cf1D82531c67569197B);// EthUsd price Oracle

    bytes32 constant NULL = bytes32(0); 
    uint constant HODL_PRECISION = 10 ** 10;                        // HODL token decimal places
    uint constant USD_PRECISION = 10 ** 18;                         // Precision for HODL:USD
    uint constant TOTAL_SUPPLY = 20000000 * (10**10);               // Total supply - initially goes to the reserve, which is address(this)
    uint constant SLEEP_TIME = 30 days;                             // Grace period before time-based accrual kicks in
    uint constant DAILY_ACCRUAL_RATE_DECAY = 999999838576236000;    // Rate of decay applied daily reduces daily accrual APR to about 5% after 30 years
    uint constant USD_TXN_ADJUSTMENT = 10**14;                      // $0.0001 with 18 decimal places of precision - 1/100th of a cent
    
    uint public BIRTHDAY;                                           // Now time when the contract was deployed
    uint public minOrderUsd = 50 * 10 ** 18;                        // Minimum order size is $50 in USD precision
    uint public maxOrderUsd = 500 * 10 ** 18;                       // Maximum order size is $500 is USD precision
    uint public maxThresholdUsd = 10 * 10 ** 18;                    // Order limits removed when HODL_USD exceeds $10
    uint public maxDistributionUsd = 250 * 10 ** 18;                // Maximum distribution value
    uint public accrualDaysProcessed;                               // Days of stateful accrual applied
    uint public distributionNext;                                   // Next distribution to process cursor
    uint public entropyCounter;                                     // Tally of unique order IDs and distributions generated 
    uint public distributionDelay = 1 days;                         // Reserve sale distribution delay

    IERC20 token;                                                   // The HODL ERC20 tradable token 
 

    uint private HODL_USD;                                          // HODL:USD exchange rate last recorded
    uint private DAILY_ACCRUAL_RATE = 1001900837677230000;          // Initial daily accrual is 0.19% (100.19% multiplier) which is about 100% APR     
    
    struct User {
        FIFOSet.FIFO sellOrderIdFifo;                               // User sell orders in no particular order
        FIFOSet.FIFO buyOrderIdFifo;                                // User buy orders in no particular order
        uint balanceEth;
        uint balanceHodl;
    }   
    struct SellOrder {
        address seller;
        uint volumeHodl;
        uint askUsd;
    }    
    struct BuyOrder {
        address buyer;
        uint bidEth;
    }
    struct Distribution {
        uint amountEth;
        uint timeStamp;
    }
    
    mapping(address => User) userStruct;
    mapping(bytes32 => SellOrder) public sellOrder;
    mapping(bytes32 => BuyOrder) public buyOrder; 

    FIFOSet.FIFO sellOrderIdFifo;                                   // SELL orders in order of declaration
    FIFOSet.FIFO buyOrderIdFifo;                                    // BUY orders in order of declaration
    AddressSet.Set hodlerAddrSet;                                   // Users with a HODL balance > 0 in no particular order
    Distribution[] public distribution;                             // Pending distributions in order of declaration
    
    modifier ifRunning {

        require(isRunning(), "Contact is not initialized.");
        _;
    }
    
    modifier distribute {

        uint distroEth;
        if(distribution.length > distributionNext) {
            Distribution storage d = distribution[distributionNext];
            if(d.timeStamp.add(distributionDelay) < now) {
                uint entropy = uint(keccak256(abi.encodePacked(entropyCounter, HODL_USD, maker.read(), blockhash(block.number))));
                uint luckyWinnerRow = entropy % hodlerAddrSet.count();
                address winnerAddr = hodlerAddrSet.keyAtIndex(luckyWinnerRow);
                User storage w = userStruct[winnerAddr];
                if(convertEthToUsd(d.amountEth) > maxDistributionUsd) {
                    distroEth = convertUsdToEth(maxDistributionUsd);
                    d.amountEth = d.amountEth.sub(distroEth);
                } else {
                    distroEth = d.amountEth;
                    delete distribution[distributionNext];
                    distributionNext = distributionNext.add(1);
                }
                w.balanceEth = w.balanceEth.add(distroEth);
                entropyCounter++;
                emit DistributionAwarded(msg.sender, distributionNext, winnerAddr, distroEth);
            }
        }
        _;
    }

    modifier accrueByTime {

        _accrueByTime();
        _;
    }
    
    event DistributionAwarded(address processor, uint indexed index, address indexed recipient, uint amount);
    event Deployed(address admin);
    event HodlTIssued(address indexed user, uint amount);
    event HodlTRedeemed(address indexed user, uint amount);
    event SellHodlC(address indexed seller, uint quantityHodl, uint lowGas);
    event SellOrderFilled(address indexed buyer, bytes32 indexed orderId, address indexed seller, uint txnEth, uint txnHodl);
    event SellOrderOpened(bytes32 indexed orderId, address indexed seller, uint quantityHodl, uint askUsd);
    event BuyHodlC(address indexed buyer, uint amountEth, uint lowGas);
    event BuyOrderFilled(address indexed seller, bytes32 indexed orderId, address indexed buyer, uint txnEth, uint txnHodl);
    event BuyOrderRefunded(address indexed seller, bytes32 indexed orderId, uint refundedEth);
    event BuyFromReserve(address indexed buyer, uint txnEth, uint txnHodl);
    event BuyOrderOpened(bytes32 indexed orderedId, address indexed buyer, uint amountEth);
    event SellOrderCancelled(address indexed userAddr, bytes32 indexed orderId);
    event BuyOrderCancelled(address indexed userAddr, bytes32 indexed orderId);
    event UserDepositEth(address indexed user, uint amountEth);
    event UserWithdrawEth(address indexed user, uint amountEth);
    event UserInitialized(address admin, address indexed user, uint hodlCR, uint ethCR);
    event UserUninitialized(address admin, address indexed user, uint hodlDB, uint ethDB);
    event PriceSet(address admin, uint hodlUsd);
    event TokenSet(address admin, address hodlToken);
    event MakerSet(address admin, address maker);
    
    constructor() public {
        userStruct[address(this)].balanceHodl = TOTAL_SUPPLY;
        BIRTHDAY = now;
        emit Deployed(msg.sender);
    }

    function keyGen() private returns(bytes32 key) {

        entropyCounter++;
        return keccak256(abi.encodePacked(address(this), msg.sender, entropyCounter));
    }


    function poke() external distribute ifRunning {

        _accrueByTime();
    }


    function hodlTIssue(uint amount) external distribute accrueByTime ifRunning {

        User storage u = userStruct[msg.sender];
        User storage t = userStruct[address(token)];
        u.balanceHodl = u.balanceHodl.sub(amount);
        t.balanceHodl = t.balanceHodl.add(amount);
        _pruneHodler(msg.sender);
        token.transfer(msg.sender, amount);
        emit HodlTIssued(msg.sender, amount);
    }

    function hodlTRedeem(uint amount) external distribute accrueByTime ifRunning {

        User storage u = userStruct[msg.sender];
        User storage t = userStruct[address(token)];
        u.balanceHodl = u.balanceHodl.add(amount);
        t.balanceHodl = t.balanceHodl.sub(amount);
        _makeHodler(msg.sender);
        token.transferFrom(msg.sender, address(this), amount);
        emit HodlTRedeemed(msg.sender, amount);
    }


    function sellHodlC(uint quantityHodl, uint lowGas) external accrueByTime distribute ifRunning returns(bytes32 orderId) {

        emit SellHodlC(msg.sender, quantityHodl, lowGas);
        uint orderUsd = convertHodlToUsd(quantityHodl); 
        uint orderLimit = orderLimit();
        require(orderUsd >= minOrderUsd, "Sell order is less than minimum USD value");
        require(orderUsd <= orderLimit || orderLimit == 0, "Order exceeds USD limit");
        quantityHodl = _fillBuyOrders(quantityHodl, lowGas);
        orderId = _openSellOrder(quantityHodl);
        _pruneHodler(msg.sender);
    }

    function _fillBuyOrders(uint quantityHodl, uint lowGas) private returns(uint remainingHodl) {

        User storage u = userStruct[msg.sender];
        address buyerAddr;
        bytes32 buyId;
        uint orderHodl;
        uint orderEth;
        uint txnEth;
        uint txnHodl;

        while(buyOrderIdFifo.count() > 0 && quantityHodl > 0) { //
            if(gasleft() < lowGas) return 0;
            buyId = buyOrderIdFifo.first();
            BuyOrder storage o = buyOrder[buyId]; 
            buyerAddr = o.buyer;
            User storage b = userStruct[o.buyer];
            
            orderEth = o.bidEth;
            orderHodl = convertEthToHodl(orderEth);
            if(orderHodl == 0) {
                if(orderEth > 0) {
                    b.balanceEth = b.balanceEth.add(orderEth);
                    emit BuyOrderRefunded(msg.sender, buyId, orderEth); 
                }
                delete buyOrder[buyId];
                buyOrderIdFifo.remove(buyId);
                b.buyOrderIdFifo.remove(buyId);                   
            } else {
                txnEth  = convertHodlToEth(quantityHodl);
                txnHodl = quantityHodl;
                if(orderEth < txnEth) {
                    txnEth = orderEth;
                    txnHodl = orderHodl;
                }
                u.balanceHodl = u.balanceHodl.sub(txnHodl, "Insufficient Hodl for computed order volume");
                b.balanceHodl = b.balanceHodl.add(txnHodl);
                u.balanceEth = u.balanceEth.add(txnEth);
                o.bidEth = o.bidEth.sub(txnEth, "500 - Insufficient ETH for computed order volume");
                quantityHodl = quantityHodl.sub(txnHodl, "500 - Insufficient order Hodl remaining to fill order");  
                _makeHodler(buyerAddr);
                _accrueByTransaction();
                emit BuyOrderFilled(msg.sender, buyId, o.buyer, txnEth, txnHodl);
            }          
        }
        remainingHodl = quantityHodl;
    }

    function _openSellOrder(uint quantityHodl) private returns(bytes32 orderId) {

        User storage u = userStruct[msg.sender];
        if(convertHodlToUsd(quantityHodl) > minOrderUsd && buyOrderIdFifo.count() == 0) { 
            orderId = keyGen();
            (uint askUsd, /*uint accrualRate*/) = rates();
            SellOrder storage o = sellOrder[orderId];
            sellOrderIdFifo.append(orderId);
            u.sellOrderIdFifo.append(orderId);           
            o.seller = msg.sender;
            o.volumeHodl = quantityHodl;
            o.askUsd = askUsd;
            u.balanceHodl = u.balanceHodl.sub(quantityHodl, "Insufficient Hodl to open sell order");
            emit SellOrderOpened(orderId, msg.sender, quantityHodl, askUsd);
        }
    }


    function buyHodlC(uint amountEth, uint lowGas) external accrueByTime distribute ifRunning returns(bytes32 orderId) {

        emit BuyHodlC(msg.sender, amountEth, lowGas);
        uint orderLimit = orderLimit();         
        uint orderUsd = convertEthToUsd(amountEth);
        require(orderUsd >= minOrderUsd, "Buy order is less than minimum USD value");
        require(orderUsd <= orderLimit || orderLimit == 0, "Order exceeds USD limit");
        amountEth = _fillSellOrders(amountEth, lowGas);
        amountEth = _buyFromReserve(amountEth);
        orderId = _openBuyOrder(amountEth);
        _makeHodler(msg.sender);
    }

    function _fillSellOrders(uint amountEth, uint lowGas) private returns(uint remainingEth) {

        User storage u = userStruct[msg.sender];
        address sellerAddr;
        bytes32 sellId;
        uint orderEth;
        uint orderHodl;
        uint txnEth;
        uint txnHodl; 

        while(sellOrderIdFifo.count() > 0 && amountEth > 0) {
            if(gasleft() < lowGas) return 0;
            sellId = sellOrderIdFifo.first();
            SellOrder storage o = sellOrder[sellId];
            sellerAddr = o.seller;
            User storage s = userStruct[sellerAddr];
            
            orderHodl = o.volumeHodl; 
            orderEth = convertHodlToEth(orderHodl);
            txnEth = amountEth;
            txnHodl = convertEthToHodl(txnEth);
            if(orderEth < txnEth) {
                txnEth = orderEth;
                txnHodl = orderHodl;
            }
            u.balanceEth = u.balanceEth.sub(txnEth, "Insufficient funds to buy from sell order");
            s.balanceEth = s.balanceEth.add(txnEth);
            u.balanceHodl = u.balanceHodl.add(txnHodl);
            o.volumeHodl = o.volumeHodl.sub(txnHodl, "500 - order has insufficient Hodl for computed volume");
            amountEth = amountEth.sub(txnEth, "500 - overspent buy order"); 
            _accrueByTransaction();
            emit SellOrderFilled(msg.sender, sellId, o.seller, txnEth, txnHodl);
            if(o.volumeHodl == 0) {
                delete sellOrder[sellId];
                sellOrderIdFifo.remove(sellId);
                s.sellOrderIdFifo.remove(sellId);
                _pruneHodler(sellerAddr); 
            }      
        }
        remainingEth = amountEth;
    }
    
    function _buyFromReserve(uint amountEth) private returns(uint remainingEth) {

        uint txnHodl;
        uint txnEth;
        if(amountEth > 0) {
            Distribution memory d;
            User storage u = userStruct[msg.sender];
            User storage r = userStruct[address(this)];
            txnHodl = (convertEthToHodl(amountEth) <= r.balanceHodl) ? convertEthToHodl(amountEth) : r.balanceHodl;
            if(txnHodl > 0) {
                txnEth = convertHodlToEth(txnHodl);
                r.balanceHodl = r.balanceHodl.sub(txnHodl, "500 - reserve has insufficient Hodl for computed volume");
                u.balanceHodl = u.balanceHodl.add(txnHodl);
                u.balanceEth = u.balanceEth.sub(txnEth, "Insufficient funds to buy from reserve");            
                d.amountEth = txnEth;
                d.timeStamp = now;
                distribution.push(d);
                amountEth = amountEth.sub(txnEth, "500 - buy order has insufficient ETH to complete reserve purchase");
                _accrueByTransaction();    
                emit BuyFromReserve(msg.sender, txnEth, txnHodl);
            }
        }
        remainingEth = amountEth;
    }

    function _openBuyOrder(uint amountEth) private returns(bytes32 orderId) {

        User storage u = userStruct[msg.sender];
        if(convertEthToUsd(amountEth) > minOrderUsd && sellOrderIdFifo.count() == 0) {
            orderId = keyGen();
            BuyOrder storage o = buyOrder[orderId];
            buyOrderIdFifo.append(orderId);
            u.buyOrderIdFifo.append(orderId);
            u.balanceEth = u.balanceEth.sub(amountEth, "Insufficient funds to open buy order");
            o.bidEth = amountEth;
            o.buyer = msg.sender;
            emit BuyOrderOpened(orderId, msg.sender, amountEth);
        }
    }
    

    function cancelSell(bytes32 orderId) external accrueByTime distribute ifRunning {

        SellOrder storage o = sellOrder[orderId];
        User storage u = userStruct[o.seller];
        require(o.seller == msg.sender, "Sender is not the seller.");
        u.balanceHodl = u.balanceHodl.add(o.volumeHodl);
        u.sellOrderIdFifo.remove(orderId);
        sellOrderIdFifo.remove(orderId);
        emit SellOrderCancelled(msg.sender, orderId);
    }
    function cancelBuy(bytes32 orderId) external distribute accrueByTime ifRunning {

        BuyOrder storage o = buyOrder[orderId];
        User storage u = userStruct[o.buyer];
        require(o.buyer == msg.sender, "Sender is not the buyer.");
        u.balanceEth = u.balanceEth.add(o.bidEth);
        u.buyOrderIdFifo.remove(orderId);
        buyOrderIdFifo.remove(orderId);
        emit BuyOrderCancelled(msg.sender, orderId);
    }

    
    function convertEthToUsd(uint amtEth) public view returns(uint inUsd) {

        inUsd = amtEth.mul(maker.read()).div(USD_PRECISION);
    }
    function convertUsdToEth(uint amtUsd) public view returns(uint inEth) {

        inEth = amtUsd.mul(USD_PRECISION).div(convertEthToUsd(USD_PRECISION));
    }
    function convertHodlToUsd(uint amtHodl) public view returns(uint inUsd) {

        (uint _hodlUsd, /*uint _accrualRate*/) = rates();
        inUsd = amtHodl.mul(_hodlUsd).div(HODL_PRECISION);
    }
    function convertUsdToHodl(uint amtUsd) public view returns(uint inHodl) {

         (uint _hodlUsd, /*uint _accrualRate*/) = rates();
        inHodl = amtUsd.mul(HODL_PRECISION).div(_hodlUsd);
    }
    function convertEthToHodl(uint amtEth) public view returns(uint inHodl) {

        uint inUsd = convertEthToUsd(amtEth);
        inHodl = convertUsdToHodl(inUsd);
    }
    function convertHodlToEth(uint amtHodl) public view returns(uint inEth) { 

        uint inUsd = convertHodlToUsd(amtHodl);
        inEth = convertUsdToEth(inUsd);
    }


    function depositEth() external accrueByTime distribute ifRunning payable {

        require(msg.value > 0, "You must send Eth to this function");
        User storage u = userStruct[msg.sender];
        u.balanceEth = u.balanceEth.add(msg.value);
        emit UserDepositEth(msg.sender, msg.value);
    }   
    function withdrawEth(uint amount) external accrueByTime distribute ifRunning {

        User storage u = userStruct[msg.sender];
        u.balanceEth = u.balanceEth.sub(amount);
        emit UserWithdrawEth(msg.sender, amount);  
        msg.sender.sendValue(amount); 
    }


    function rates() public view returns(uint hodlUsd, uint dailyAccrualRate) {

        hodlUsd = HODL_USD;
        dailyAccrualRate = DAILY_ACCRUAL_RATE;
        uint startTime = BIRTHDAY.add(SLEEP_TIME);
        if(now > startTime) {
            uint daysFromStart = (now.sub(startTime)) / 1 days;
            uint daysUnprocessed = daysFromStart.sub(accrualDaysProcessed);
            if(daysUnprocessed > 0) {
                hodlUsd = HODL_USD.mul(DAILY_ACCRUAL_RATE).div(USD_PRECISION);
                dailyAccrualRate = DAILY_ACCRUAL_RATE.mul(DAILY_ACCRUAL_RATE_DECAY).div(USD_PRECISION);
            }
        }
    }


    function _accrueByTransaction() private {

        HODL_USD = HODL_USD.add(USD_TXN_ADJUSTMENT);
    }    
    function _accrueByTime() private returns(uint hodlUsdNow, uint dailyAccrualRateNow) {

        (hodlUsdNow, dailyAccrualRateNow) = rates();
        if(hodlUsdNow != HODL_USD || dailyAccrualRateNow != DAILY_ACCRUAL_RATE) { 
            HODL_USD = hodlUsdNow;
            DAILY_ACCRUAL_RATE = dailyAccrualRateNow; 
            accrualDaysProcessed = accrualDaysProcessed.add(1);  
        } 
    }
    

    function _makeHodler(address user) private {

        User storage u = userStruct[user];
        if(convertHodlToUsd(u.balanceHodl) >= minOrderUsd) {
            if(!hodlerAddrSet.exists(user)) hodlerAddrSet.insert(user);   
        }
    }    
    function _pruneHodler(address user) private {

        User storage u = userStruct[user];
        if(convertHodlToUsd(u.balanceHodl) < minOrderUsd) {
            if(hodlerAddrSet.exists(user)) hodlerAddrSet.remove(user);
        }
    }
    
    
    function contractBalanceEth() public view returns(uint ineth) { return address(this).balance; }


    function distributionsLength() public view returns(uint row) { return distribution.length; }

    
    function hodlerCount() public view returns(uint count) { return hodlerAddrSet.count(); }

    function hodlerAtIndex(uint index) public view returns(address userAddr) { return hodlerAddrSet.keyAtIndex(index); }    

    
    function sellOrderCount() public view returns(uint count) { return sellOrderIdFifo.count(); }

    function sellOrderFirst() public view returns(bytes32 orderId) { return sellOrderIdFifo.first(); }

    function sellOrderLast() public view returns(bytes32 orderId) { return sellOrderIdFifo.last(); }  

    function sellOrderIterate(bytes32 orderId) public view returns(bytes32 idBefore, bytes32 idAfter) { return (sellOrderIdFifo.previous(orderId), sellOrderIdFifo.next(orderId)); }

    function buyOrderCount() public view returns(uint count) { return buyOrderIdFifo.count(); }

    function buyOrderFirst() public view returns(bytes32 orderId) { return buyOrderIdFifo.first(); }

    function buyOrderLast() public view returns(bytes32 orderId) { return buyOrderIdFifo.last(); }    

    function buyOrderIterate(bytes32 orderId) public view returns(bytes32 ifBefore, bytes32 idAfter) { return(buyOrderIdFifo.previous(orderId), buyOrderIdFifo.next(orderId)); }


    function userSellOrderCount(address userAddr) public view returns(uint count) { return userStruct[userAddr].sellOrderIdFifo.count(); }

    function userSellOrderFirst(address userAddr) public view returns(bytes32 orderId) { return userStruct[userAddr].sellOrderIdFifo.first(); }

    function userSellOrderLast(address userAddr) public view returns(bytes32 orderId) { return userStruct[userAddr].sellOrderIdFifo.last(); }  

    function userSellOrderIterate(address userAddr, bytes32 orderId) public view  returns(bytes32 idBefore, bytes32 idAfter) { return(userStruct[userAddr].sellOrderIdFifo.previous(orderId), userStruct[userAddr].sellOrderIdFifo.next(orderId)); }

    function userBuyOrderCount(address userAddr) public view returns(uint count) { return userStruct[userAddr].buyOrderIdFifo.count(); }

    function userBuyOrderFirst(address userAddr) public view returns(bytes32 orderId) { return userStruct[userAddr].buyOrderIdFifo.first(); }

    function userBuyOrderLast(address userAddr) public view returns(bytes32 orderId) { return userStruct[userAddr].buyOrderIdFifo.last(); }

    function userBuyOrderIdFifo(address userAddr, bytes32 orderId) public view  returns(bytes32 idBefore, bytes32 idAfter) { return(userStruct[userAddr].buyOrderIdFifo.previous(orderId), userStruct[userAddr].buyOrderIdFifo.next(orderId)); }

     
    function user(address userAddr) public view returns(uint balanceEth, uint balanceHodl) {

        User storage u = userStruct[userAddr];
        return(u.balanceEth, u.balanceHodl);
    }
    function isAccruing() public view returns(bool accruing) {

        return now > BIRTHDAY.add(SLEEP_TIME);
    }
    function isRunning() public view returns(bool running) {

        return owner() == address(0);
    }
    function orderLimit() public view returns(uint limitUsd) {

        (uint askUsd, /*uint accrualRate*/) = rates();
        return (askUsd > maxThresholdUsd) ? 0 : maxOrderUsd;
    }
    function makerAddr() public view returns(address) {

        return address(maker);
    }
    function hodlTAddr() public view returns(address) {

        return address(token);
    }
    

    function initUser(address userAddr, uint hodl) external onlyOwner payable {

        User storage u = userStruct[userAddr];
        User storage r = userStruct[address(this)];
        u.balanceEth  = u.balanceEth.add(msg.value);
        u.balanceHodl = u.balanceHodl.add(hodl);
        r.balanceHodl = r.balanceHodl.sub(hodl);
        _makeHodler(userAddr);
        emit UserInitialized(msg.sender, userAddr, hodl, msg.value);
    }
    function initResetUser(address userAddr) external onlyOwner {

        User storage u = userStruct[userAddr];
        User storage r = userStruct[address(this)];
        r.balanceHodl = r.balanceHodl.add(u.balanceHodl);
        if(u.balanceEth > 0) msg.sender.transfer(u.balanceEth);
        emit UserUninitialized(msg.sender, userAddr, u.balanceHodl, u.balanceEth);
        delete userStruct[userAddr];
        _pruneHodler(userAddr);
    }
    function initSetHodlTAddress(IERC20 hodlToken) external onlyOwner {

        token = IERC20(hodlToken);
        emit TokenSet(msg.sender, address(token));
    }
    function initSetHodlUsd(uint price) external onlyOwner {

        HODL_USD = price;
        emit PriceSet(msg.sender, price);
    }
    function initSetMaker(address _maker) external onlyOwner {

        maker = Maker(_maker);
        emit MakerSet(msg.sender, _maker);
    }
    function renounceOwnership() public override onlyOwner {

        require(token.balanceOf(address(this)) == TOTAL_SUPPLY, "Assign the HoldT supply to this contract before trading starts");
        Ownable.renounceOwnership();
    }
}