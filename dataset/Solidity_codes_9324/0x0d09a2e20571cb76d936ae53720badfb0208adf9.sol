
pragma solidity ^0.4.25;


contract ERC20 {

    function totalSupply() public constant returns (uint supply);

    function balanceOf(address _owner) public constant returns (uint balance);

    function transfer(address _to, uint _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

    function approve(address _spender, uint _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint remaining);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Owned {

    address public owner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {

        if (msg.sender != owner) revert();
        _;
    }

    modifier onlyOwnerOrTokenTraderWithSameOwner {

        if (msg.sender != owner && TokenTrader(msg.sender).owner() != owner) revert();
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


contract TokenTrader is Owned {


    address public asset;       // address of token
    uint256 public buyPrice;    // contract buys lots of token at this price
    uint256 public sellPrice;   // contract sells lots at this price
    uint256 public units;       // lot size (token-wei)

    bool public buysTokens;     // is contract buying
    bool public sellsTokens;    // is contract selling

    event ActivatedEvent(bool buys, bool sells);
    event MakerDepositedEther(uint256 amount);
    event MakerWithdrewAsset(uint256 tokens);
    event MakerTransferredAsset(address toTokenTrader, uint256 tokens);
    event MakerWithdrewERC20Token(address tokenAddress, uint256 tokens);
    event MakerWithdrewEther(uint256 ethers);
    event MakerTransferredEther(address toTokenTrader, uint256 ethers);
    event TakerBoughtAsset(address indexed buyer, uint256 ethersSent,
        uint256 ethersReturned, uint256 tokensBought);
    event TakerSoldAsset(address indexed seller, uint256 amountOfTokensToSell,
        uint256 tokensSold, uint256 etherValueOfTokensSold);

    constructor (
        address _asset,
        uint256 _buyPrice,
        uint256 _sellPrice,
        uint256 _units,
        bool    _buysTokens,
        bool    _sellsTokens
    ) public {
        asset       = _asset;
        buyPrice    = _buyPrice;
        sellPrice   = _sellPrice;
        units       = _units;
        buysTokens  = _buysTokens;
        sellsTokens = _sellsTokens;
        emit ActivatedEvent(buysTokens, sellsTokens);
    }

    function activate (
        bool _buysTokens,
        bool _sellsTokens
    ) public onlyOwner {
        buysTokens  = _buysTokens;
        sellsTokens = _sellsTokens;
        emit ActivatedEvent(buysTokens, sellsTokens);
    }

    function makerDepositEther() public payable onlyOwnerOrTokenTraderWithSameOwner {

        emit MakerDepositedEther(msg.value);
    }

    function makerWithdrawAsset(uint256 tokens) public onlyOwner returns (bool) {

        emit MakerWithdrewAsset(tokens);
        return ERC20(asset).transfer(owner, tokens);
    }

    function makerTransferAsset(
        TokenTrader toTokenTrader,
        uint256 tokens
    ) public onlyOwner returns (bool) {

        if (owner != toTokenTrader.owner() || asset != toTokenTrader.asset()) {
            revert();
        }
        emit MakerTransferredAsset(toTokenTrader, tokens);
        return ERC20(asset).transfer(toTokenTrader, tokens);
    }

    function makerWithdrawERC20Token(
        address tokenAddress,
        uint256 tokens
    ) public onlyOwner returns (bool) {

        emit MakerWithdrewERC20Token(tokenAddress, tokens);
        return ERC20(tokenAddress).transfer(owner, tokens);
    }

    function makerWithdrawEther(uint256 ethers) public onlyOwner returns (bool) {

        address addr = this;
        if (addr.balance >= ethers) {
            emit MakerWithdrewEther(ethers);
            return owner.send(ethers);
        }
    }

    function makerTransferEther(
        TokenTrader toTokenTrader,
        uint256 ethers
    ) public onlyOwner returns (bool) {

        if (owner != toTokenTrader.owner() || asset != toTokenTrader.asset()) {
            revert();
        }
        address addr = this;
        if (addr.balance >= ethers) {
            emit MakerTransferredEther(toTokenTrader, ethers);
            toTokenTrader.makerDepositEther.value(ethers)();
        }
    }

    function takerBuyAsset() public payable {

        if (sellsTokens || msg.sender == owner) {
            uint order    = msg.value / sellPrice;
            uint can_sell = ERC20(asset).balanceOf(address(this)) / units;
            uint256 change = 0;
            if (msg.value > (can_sell * sellPrice)) {
                change  = msg.value - (can_sell * sellPrice);
                order = can_sell;
            }
            if (change > 0) {
                if (!msg.sender.send(change)) revert();
            }
            if (order > 0) {
                if (!ERC20(asset).transfer(msg.sender, order * units)) revert();
            }
            emit TakerBoughtAsset(msg.sender, msg.value, change, order * units);
        }
        else if (!msg.sender.send(msg.value)) revert();
    }

    function takerSellAsset(uint256 amountOfTokensToSell) public {

        if (buysTokens || msg.sender == owner) {
            address addr = this;
            uint256 can_buy = addr.balance / buyPrice;
            uint256 order = amountOfTokensToSell / units;
            if (order > can_buy) order = can_buy;
            if (order > 0) {
                if (!ERC20(asset).transferFrom(msg.sender, address(this), order * units)) revert();
                if (!msg.sender.send(order * buyPrice)) revert();
            }
            emit TakerSoldAsset(msg.sender, amountOfTokensToSell, order * units, order * buyPrice);
        }
    }

    function () public payable {
        takerBuyAsset();
    }
}

contract TokenTraderFactory is Owned {


    event TradeListing(address indexed ownerAddress, address indexed tokenTraderAddress,
        address indexed asset, uint256 buyPrice, uint256 sellPrice, uint256 units,
        bool buysTokens, bool sellsTokens);
    event OwnerWithdrewERC20Token(address indexed tokenAddress, uint256 tokens);

    mapping(address => bool) _verify;

    uint256 internal accountCount = 0;
    mapping(address => address) internal addressLinkedList;

    function list() public view returns (address[]) {

        address[] memory addrs = new address[](accountCount);

        uint256 i = 0;
        address current = addressLinkedList[0];
        while (current != 0) {
            addrs[i] = current;
            current = addressLinkedList[current];
            i++;
        }

        return addrs;
    }

    function verify(address tradeContract) public constant returns (
        bool    valid,
        address owner,
        address asset,
        uint256 buyPrice,
        uint256 sellPrice,
        uint256 units,
        bool    buysTokens,
        bool    sellsTokens
    ) {

        valid = _verify[tradeContract];
        if (valid) {
            TokenTrader t = TokenTrader(tradeContract);
            owner         = t.owner();
            asset         = t.asset();
            buyPrice      = t.buyPrice();
            sellPrice     = t.sellPrice();
            units         = t.units();
            buysTokens    = t.buysTokens();
            sellsTokens   = t.sellsTokens();
        }
    }

    function createTradeContract(
        address asset,
        uint256 buyPrice,
        uint256 sellPrice,
        uint256 units,
        bool    buysTokens,
        bool    sellsTokens
    ) public returns (address trader) {

        if (asset == 0x0) revert();
        ERC20(asset).allowance(msg.sender, this);
        if (buyPrice <= 0 || sellPrice <= 0) revert();
        if (buyPrice >= sellPrice) revert();
        if (units <= 0) revert();

        trader = new TokenTrader(
            asset,
            buyPrice,
            sellPrice,
            units,
            buysTokens,
            sellsTokens);
        _verify[trader] = true;
        addToList(trader);
        TokenTrader(trader).transferOwnership(msg.sender);
        emit TradeListing(msg.sender, trader, asset, buyPrice, sellPrice, units, buysTokens, sellsTokens);
    }

    function ownerWithdrawERC20Token(address tokenAddress, uint256 tokens) public onlyOwner returns (bool) {

        emit OwnerWithdrewERC20Token(tokenAddress, tokens);
        return ERC20(tokenAddress).transfer(owner, tokens);
    }

    function () public {
        revert();
    }

    function addToList(address addr) internal {

        addressLinkedList[addr] = addressLinkedList[0x0];
        addressLinkedList[0x0] = addr;
        accountCount++;
    }

    function removeFromList(address addr) internal {

        uint16 i = 0;
        bool found = false;
        address parent;
        address current = addressLinkedList[0];
        while (true) {
            if (addressLinkedList[current] == addr) {
                parent = current;
                found = true;
                break;
            }
            current = addressLinkedList[current];

            if (i++ > accountCount) break;
        }

        require(found, "Account was not found to remove.");

        addressLinkedList[parent] = addressLinkedList[addressLinkedList[parent]];
        delete addressLinkedList[addr];

        accountCount--;
    }

    function ensureInList(address addr) internal {

        bool found = false;
        address current = addressLinkedList[0];
        while (current != 0) {
            if (current == addr) {
                found = true;
                break;
            }
            current = addressLinkedList[current];
        }
        if (!found) {
            addToList(addr);
        }
    }
}