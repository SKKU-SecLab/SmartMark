pragma solidity ^0.6.9;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(),"Not Owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0),"Zero address not allowed");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.6.9;

library EnumerableSet {


    struct AddressSet {
        address[] _values;

        mapping (address => uint256) _indexes;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        if (!contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            address lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return set._indexes[value] != 0;
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return set._values.length;
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }
}
pragma solidity ^0.6.9;



interface IGovernanceProxy {

    function governance() external returns(address);    // Voting contract address

}

interface IGovernance {

    function addPremintedWallet(address wallet) external returns(bool);

}

interface  IGateway {

    function getChannelsNumber() external view returns(uint256);

}

interface IERC20Token {

    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

}

interface IAuctionLiquidity {

    function redemptionFromEscrow(address[] calldata _path, uint256 _amount, address payable _sender) external returns (bool);

}

interface ISmartSwapP2P {

    function sendTokenFormEscrow(address token, uint amount, address payable sender) external; 

}

interface IAuctionRegistery {

    function getAddressOf(bytes32 _contractName) external view returns (address payable);

}

interface ICurrencyPrices {

    function getCurrencyPrice(address _which) external view returns (uint256);

}

contract AuctionRegistery is Ownable {

    bytes32 internal constant SMART_SWAP_P2P = "SMART_SWAP_P2P";
    bytes32 internal constant LIQUIDITY = "LIQUIDITY";
    bytes32 internal constant CURRENCY = "CURRENCY";
    IAuctionRegistery public contractsRegistry;
    IAuctionLiquidity public liquidityContract;
    ISmartSwapP2P public smartswapContract;
    ICurrencyPrices public currencyPricesContract;

    function updateRegistery(address _address) external onlyOwner returns (bool)
    {

        require(_address != address(0),"Zero address");
        contractsRegistry = IAuctionRegistery(_address);
        _updateAddresses();
        return true;
    }

    function getAddressOf(bytes32 _contractName)
        internal
        view
        returns (address payable)
    {

        return contractsRegistry.getAddressOf(_contractName);
    }


    function _updateAddresses() internal {

        liquidityContract = IAuctionLiquidity(getAddressOf(LIQUIDITY));
        smartswapContract = ISmartSwapP2P(getAddressOf(SMART_SWAP_P2P));
        currencyPricesContract = ICurrencyPrices(getAddressOf(CURRENCY));
    }

     function updateAddresses() external returns (bool) {

        _updateAddresses();
        return true;
    }
}

contract Escrow is AuctionRegistery {

    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 internal constant DECIMAL_NOMINATOR = 10**18;
    uint256 internal constant BUYBACK = 1 << 251;
    uint256 internal constant SMARTSWAP_P2P = 1 << 252;
    IERC20Token public tokenContract;
    address public governanceContract;  // public Governance contract address
    address payable public companyWallet;
    address payable public gatewayContract;

    struct Order {
        address payable seller;
        address payable buyer;
        uint256 sellValue;  // how many token sell
        address wantToken;  // which token want to receive
        uint256 wantValue;  // the value want to receive
        uint256 status;     // 1 - created, 2 - completed; 3 - canceled; 4 -restricted
        address confirmatory;   // the address third person who confirm transaction, if order is restricted.
    }

    Order[] orders;
    
    struct Unpaid {
        uint256 soldValue;
        uint256 value;
    }

    struct Group {
        uint256 rate;
        EnumerableSet.AddressSet wallets;
        uint256 restriction;    // bitmap, where 1 allows to use that channel (1 << channel ID)
        mapping(uint256 => uint256) onSale; // total amount of tokens on sale in group by channel (Channel => Value)
        mapping(uint256 => uint256) soldUnpaid; // total amount of sold tokens but still not spitted pro-rata in group by channel (Channel => Value)
        mapping(uint256 => EnumerableSet.AddressSet) addressesOnChannel;   // list of address on the Liquidity channel
        mapping(uint256 => mapping(address => Unpaid)) unpaid;  // ETH / ERC20 tokens ready to split pro-rata (ETH = address(0))
    }

    Group[] groups;
    mapping(address => uint256) public inGroup;   // Wallet to Group mapping. 0 - wallet not added, 1+ - group id (1-based)
    mapping(uint256 => uint256) public totalOnSale;     // total token amount on sale by channel
    mapping(address => mapping(uint256 => uint256)) public onSale;  // How many tokens the wallet want to sell (Wallet => Channel => Value)
    mapping(address => uint256) public goals;   // The amount in USD (decimals = 9), that investor should receive before splitting liquidity with others members

    uint256 public totalSupply;
    mapping(address => uint256) balances;
    mapping(address => uint256) balancesETH;    // In case ETH sands failed, user can withdraw ETH using withdraw function

    event Transfer(address indexed from, address indexed to, uint256 value);
    event TransferGateway(address indexed to, uint256 indexed channelId, uint256 value);
    event GroupRate(uint256 indexed groupId, uint256 rate);
    event PutOnSale(address indexed from, uint256 value);
    event RemoveFromSale(address indexed from, uint256 value);
    event PaymentFromGateway(uint256 indexed channelId, address indexed token, uint256 value, uint256 soldValue);
    event SellOrder(address indexed seller, address indexed buyer, uint256 value, address wantToken, uint256 wantValue, uint256 indexed orderId);
    event RestrictedOrder(address indexed seller, address indexed buyer, uint256 value, address wantToken, uint256 wantValue, uint256 indexed orderId, address confirmatory);
    event ReceivedETH(address indexed from, uint256 value);

    modifier onlyCompany() {

        require(companyWallet == msg.sender,"Not Company");
        _;
    }

    modifier onlyGateway() {

        require(gatewayContract == msg.sender,"Not Gateway");
        _;
    }

    constructor(address payable _companyWallet) public {
        _nonZeroAddress(_companyWallet);
        companyWallet = _companyWallet;
        uint256[4] memory groupRate = [uint256(100),0,0,0];
        for (uint i = 0; i < 4; i++) {
            groups.push();
            groups[i].rate = groupRate[i];
        }
        groups[0].restriction = 1; // allow company to use Gateway supply channel (0)
        orders.push();  // order ID starts from 1. Zero order ID means - no order
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function setTokenContract(IERC20Token newAddress) external onlyOwner {

        require(newAddress != IERC20Token(0) && tokenContract == IERC20Token(0),"Change address not allowed");
        tokenContract = newAddress;
    }

    function setGatewayContract(address payable newAddress) external onlyOwner {

        _nonZeroAddress(newAddress);
        gatewayContract = newAddress;
    }

    function setGovernanceContract(address payable newAddress) external onlyOwner {

        _nonZeroAddress(newAddress);
        governanceContract = newAddress;
    }

    function updateCompanyAddress(address payable newAddress) external onlyCompany {

        require(inGroup[newAddress] == 0, "Wallet already added");
        _nonZeroAddress(newAddress);
        balances[newAddress] = balances[companyWallet];
        groups[0].wallets.remove(companyWallet);    // remove from company group
        inGroup[companyWallet] = 0;
        balances[companyWallet] = 0;
        uint channels = _getChannelsNumber();
        for (uint i = 0; i < channels; i++) {   // exclude channel 0. It allow company to wire tokens for Gateway supply
            if (onSale[companyWallet][i] > 0) {
                onSale[newAddress][i] = onSale[companyWallet][i];
                onSale[companyWallet][i] = 0;
                groups[0].addressesOnChannel[i].add(newAddress);
                groups[0].addressesOnChannel[i].remove(companyWallet);
            }
        }
        _addPremintedWallet(newAddress, 0); // add company wallet to the company group.
        companyWallet = newAddress;
    }


    function init() external onlyOwner {

        require(inGroup[companyWallet] == 0, "Already init");
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance > 0, "No pre-minted tokens");
        balances[companyWallet] = balance; //Transfer all pre-minted tokens to company wallet.
        _addPremintedWallet(companyWallet, 0); // add company wallet to the company group.
        totalSupply = safeAdd(totalSupply, balance);
        emit Transfer(address(0), companyWallet, balance);
    }

    function setGroupRestriction(uint256 groupId, uint256 restriction) external onlyOwner {

        groups[groupId].restriction = restriction;
    }

    function getGroupDetails(uint256 groupId) external view returns(uint256 rate, uint256 membersNumber, uint256 restriction) {

        return (groups[groupId].rate, groups[groupId].wallets.length(), groups[groupId].restriction);
    }

    function getGroupsNumber() external view returns(uint256 number) {

        return groups.length;
    }

    function getGroupMembers(uint256 groupId) external view returns(address[] memory wallets) {

        return groups[groupId].wallets._values;
    }
    
    function moveToGroup(address wallet, uint256 toGroup) external onlyOwner {

        require(goals[wallet] == 0, "Wallet with goal can't be moved");
        _moveToGroup(wallet, toGroup, false);
    }

    function addGroup(uint256 rate) external onlyOwner {

        uint256 groupId = groups.length;
        groups.push();
        groups[groupId].rate = rate;
        emit GroupRate(groupId, rate);
    }

    function changeGroupRate(uint256 groupId, uint256 rate) external onlyOwner {

        groups[groupId].rate = rate;
        emit GroupRate(groupId, rate);
    }

    function getAddressesOnChannel(uint256 groupId, uint256 channelId) external view returns(address[] memory wallets) {

        return groups[groupId].addressesOnChannel[channelId]._values;
    }

    function createWallet(address newWallet, uint256 groupId, uint256 value, uint256 goal) external onlyCompany returns(bool){

        require(inGroup[newWallet] == 0, "Wallet already added");
        if (goal != 0) {
            require(groupId == 1, "Wallet with goal disallowed");
            goals[newWallet] = goal;
        }
        _addPremintedWallet(newWallet, groupId);
        return _transfer(newWallet, value);
    }

    function depositFee(uint256 value) external {

        require(tokenContract.transferFrom(msg.sender, address(this), value),"Transfer failed");
        balances[companyWallet] = safeAdd(balances[companyWallet], value);
        totalSupply = safeAdd(totalSupply, value);
        emit Transfer(msg.sender, address(this), value);
    }
    
    function transfer(address to, uint256 value) external returns (bool) {

        require(inGroup[to] != 0, "Wallet not added");
        uint256 groupId = _getGroupId(msg.sender);
        require(groups[groupId].restriction != 0,"Group is restricted");
        return _transfer(to, value);
    }

    function transferRestricted(address to, uint256 value, address confirmatory) external {

        _nonZeroAddress(confirmatory);
        require(inGroup[to] != 0, "Wallet not added");
        require(msg.sender != confirmatory && to != confirmatory, "Wrong confirmatory address");
        _restrictedOrder(value, address(0), 0, payable(to), confirmatory);   // Create restricted order where wantValue = 0.
    }

    function balanceOf(address _who) public view returns (uint256 balance) {

        return balances[_who];
    }

    function redemption(address[] calldata path, uint256 value) external {

        require(balances[msg.sender] >= value, "Not enough balance");
        uint256 groupId = _getGroupId(msg.sender);
        require(groups[groupId].restriction & BUYBACK > 0, "BuyBack disallowed");
        balances[msg.sender] = safeSub(balances[msg.sender], value);
        tokenContract.approve(address(liquidityContract), value);
        totalSupply = safeSub(totalSupply, value);
        require(liquidityContract.redemptionFromEscrow(path, value, msg.sender), "Redemption failed");
    }

    function samartswapP2P(uint256 value) external {

        require(balances[msg.sender] >= value, "Not enough balance");
        uint256 groupId = _getGroupId(msg.sender);
        require(groups[groupId].restriction & SMARTSWAP_P2P > 0, "SmartSwap P2P disallowed");
        balances[msg.sender] = safeSub(balances[msg.sender], value);
        totalSupply = safeSub(totalSupply, value);
        tokenContract.approve(address(smartswapContract), value);
        smartswapContract.sendTokenFormEscrow(address(tokenContract), value, msg.sender);
    }

    function canceledP2P(address user, uint256 value) external returns(bool) {

        require(tokenContract.transferFrom(msg.sender, address(this), value),"Cancel P2P failed");
        balances[user] = safeAdd(balances[user], value);
        totalSupply = safeAdd(totalSupply, value);
        return true;
    }

    function sellToken(uint256 sellValue, address wantToken, uint256 wantValue, address payable buyer) external {

        require(sellValue > 0, "Zero sell value");
        require(balances[msg.sender] >= sellValue, "Not enough balance");
        require(inGroup[buyer] != 0, "Wallet not added");        
        uint256 groupId = _getGroupId(msg.sender);
        require(groups[groupId].restriction != 0,"Group is restricted");
        balances[msg.sender] = safeSub(balances[msg.sender], sellValue);
        uint256 orderId = orders.length;
        orders.push(Order(msg.sender, buyer, sellValue, wantToken, wantValue, 1, address(0)));
        emit SellOrder(msg.sender, buyer, sellValue, wantToken, wantValue, orderId);
    }

    function sellTokenRestricted(uint256 sellValue, address wantToken, uint256 wantValue, address payable buyer, address confirmatory) external {

        _nonZeroAddress(confirmatory);
        require(inGroup[buyer] != 0, "Wallet not added");
        require(balances[msg.sender] >= sellValue, "Not enough balance");
        require(msg.sender != confirmatory && buyer != confirmatory, "Wrong confirmatory address");
        _restrictedOrder(sellValue, wantToken, wantValue, buyer, confirmatory);
    }


    function confirmOrder(uint256 orderId) external {

        Order storage o = orders[orderId];
        require(o.confirmatory == msg.sender, "Not a confirmatory");
        if (o.wantValue == 0) { // if it's simple transfer, complete it immediately.
            balances[o.buyer] = safeAdd(balances[o.buyer], o.sellValue);
            o.status = 2;   // complete
        }
        else {
            o.status = 1;   // remove restriction
        }
    }

    function cancelOrder(uint256 orderId) external {

        Order storage o = orders[orderId];
        require(msg.sender == o.seller || msg.sender == o.buyer, "You can't cancel");
        require(o.status == 1 || o.status == 4, "Wrong order"); // user can cancel restricted order too.
        balances[o.seller] = safeAdd(balances[o.seller], o.sellValue);
        o.status = 3;   // cancel
    }

    function getOrder(uint256 orderId) external view returns(
        address seller,
        address buyer,
        uint256 sellValue,
        address wantToken,
        uint256 wantValue,
        uint256 status,
        address confirmatory)
    {

        Order storage o = orders[orderId];
        return (o.seller, o.buyer, o.sellValue, o.wantToken, o.wantValue, o.status, o.confirmatory);
    }

    function getOrdersNumber() external view returns(uint256 number) {

        return orders.length;
    }

    function getLastAvailableOrder() external view returns(uint256 orderId)
    {

        uint len = orders.length;
        while(len > 0) {
            len--;
            Order storage o = orders[len];
            if (o.status == 1 && (o.seller == msg.sender || o.buyer == msg.sender)) {
                return len;
            }
        }
        return 0; // No orders available
    }

    function getLastOrderToConfirm() external view returns(uint256 orderId) {

        uint len = orders.length;
        while(len > 0) {
            len--;
            Order storage o = orders[len];
            if (o.status == 4 && o.confirmatory == msg.sender) {
                return len;
            }
        }
        return 0;
    }

    function buyOrder(uint256 orderId) external payable {

        require(inGroup[msg.sender] != 0, "Wallet not added");
        Order storage o = orders[orderId];
        require(msg.sender == o.buyer, "Wrong buyer");
        require(o.status == 1, "Wrong order status");
        if (o.wantValue > 0) {
            if (o.wantToken == address(0)) {
                require(msg.value == o.wantValue, "Wrong value");
                o.seller.transfer(msg.value);
            }
            else {
                require(IERC20Token(o.wantToken).transferFrom(msg.sender, o.seller, o.wantValue), "Not enough value");
            }
        }
        balances[msg.sender] = safeAdd(balances[msg.sender], o.sellValue);
        o.status = 2;   // complete
    }

    function putOnSale(uint256 value, uint256 channelId) external {

        require(balances[msg.sender] >= value, "Not enough balance");
        uint256 groupId = _getGroupId(msg.sender);
        require(groups[groupId].restriction & (1 << channelId) > 0, "Liquidity channel disallowed");
        require(groups[groupId].soldUnpaid[channelId] == 0, "There is unpaid giveaways");
        balances[msg.sender] = safeSub(balances[msg.sender], value);
        totalSupply = safeSub(totalSupply, value);
        groups[groupId].addressesOnChannel[channelId].add(msg.sender);  // the case that wallet already in list, checks in add function
        onSale[msg.sender][channelId] = safeAdd(onSale[msg.sender][channelId], value);
        totalOnSale[channelId] = safeAdd(totalOnSale[channelId], value);
        groups[groupId].onSale[channelId] = safeAdd(groups[groupId].onSale[channelId], value);
        emit PutOnSale(msg.sender, value);
    }

    function removeFromSale(uint256 value, uint256 channelId) external {

        if (onSale[msg.sender][channelId] < value) {
            value = onSale[msg.sender][channelId];
        }
        require(totalOnSale[channelId] >= value, "Not enough on sale");
        uint groupId = _getGroupId(msg.sender);
        require(groups[groupId].soldUnpaid[channelId] == 0, "There is unpaid giveaways");
        onSale[msg.sender][channelId] = safeSub(onSale[msg.sender][channelId], value);
        totalOnSale[channelId] = safeSub(totalOnSale[channelId], value);
        balances[msg.sender] = safeAdd(balances[msg.sender], value);
        totalSupply = safeAdd(totalSupply, value);
        groups[groupId].onSale[channelId] = safeSub(groups[groupId].onSale[channelId], value);

        if (onSale[msg.sender][channelId] == 0) {
            groups[groupId].addressesOnChannel[channelId].remove(msg.sender);
        }
        emit RemoveFromSale(msg.sender, value);
    }

    function transferToGateway(uint256 value, uint256 channelId) external onlyGateway returns(uint256 send){

        send = value;
        if(totalOnSale[channelId] < value)
            send = totalOnSale[channelId];
        totalOnSale[channelId] = safeSub(totalOnSale[channelId], send);
        tokenContract.approve(gatewayContract, send);
        emit TransferGateway(gatewayContract, channelId, send);
    }

    function transferFromGateway(uint256 value, uint256 channelId) external onlyGateway {

        totalOnSale[channelId] = safeAdd(totalOnSale[channelId], value);
        emit TransferGateway(address(this), channelId, value);
    }

    function paymentFromGateway(uint256 channelId, address token, uint256 value, uint256 soldValue) external payable onlyGateway {

        uint256 len = groups.length;
        uint256[] memory groupPart = new uint256[](len);
        uint256[] memory groupOnSale = new uint256[](len);
        bool[] memory groupHasOnSale = new bool[](len);
        uint256[] memory groupRate = new uint256[](len);
        uint256 totalRateNew;
        uint256 restNew = soldValue;

        for (uint i = 0; i < len; i++) {
            groupOnSale[i] = safeSub(groups[i].onSale[channelId], groups[i].soldUnpaid[channelId]);
            if (groupOnSale[i] > 0) {
                groupHasOnSale[i] = true;
                groupRate[i] = groups[i].rate;
                totalRateNew += groupRate[i];
            }
        }
        
        uint256 part;
        while (restNew > 0) {
            uint256 restValue = restNew;
            uint256 totalRate = totalRateNew;
            for (uint i = 0; i < len; i++) {
                if (groupHasOnSale[i]) {
                    if (restNew < len) part = restNew; // if rest value less then calculation error use it all
                    else part = (restValue*groupRate[i]/totalRate);
                    groupPart[i] += part;
                    if (groupPart[i] > groupOnSale[i]) {
                        part = part - (groupPart[i]-groupOnSale[i]);    // part that rest
                        groupPart[i] = groupOnSale[i];
                        groupHasOnSale[i] = false; // group on-sale fulfilled
                        totalRateNew = totalRate - groupRate[i];
                    }
                    restNew -= part;
                }
            }
        }

        for (uint i = 0; i < len; i++) {
            if (groupOnSale[i] > 0) {
                groups[i].soldUnpaid[channelId] += groupPart[i];    // total sold tokens and unpaid (unsplit) by channel
                groups[i].unpaid[channelId][token].soldValue += groupPart[i]; // sold tokens by payment tokens and channel
                groups[i].unpaid[channelId][token].value += (groupPart[i] * value / soldValue); //unpaid tokens by channel 
            }
        }
        emit PaymentFromGateway(channelId, token, value, soldValue);
    }

    function getUnpaidGroups(uint256 channelId) external view returns (uint256[] memory unpaidSold){

        uint256 len = groups.length;
        unpaidSold = new uint256[](len);
        for (uint i = 0; i<len; i++) {
            unpaidSold[i] = groups[i].soldUnpaid[channelId];
        }
    }

    function splitProrata(uint256 channelId, address token, uint256 groupId) external {

        if (groupId == 1) _splitForGoals(channelId, token, groupId);    // split among Investors with goal 
        else _splitProrata(channelId, token, groupId);
    }

    function splitProrataAll(uint256 channelId, address token) external {

        uint256 len = groups.length;
        for (uint i = 0; i < len; i++) {
            if (i == 1) _splitForGoals(channelId, token, i);    // split among Investors with goal 
            else _splitProrata(channelId, token, i);
        }
    }

    struct SplitValues {
        uint256 soldValue;
        uint256 value;
        uint256 total;
        uint256 soldRest;
        uint256 valueRest;
        uint256 userPart;
        uint256 userValue;
    }

    function _splitProrata(uint256 channelId, address token, uint256 groupId) internal {

        Group storage g = groups[groupId];
        SplitValues memory v;
        v.soldValue = g.unpaid[channelId][token].soldValue;
        if (v.soldValue == 0) return; // no unpaid tokens
        v.value = g.unpaid[channelId][token].value;
        v.total = g.onSale[channelId];
        if (v.total == 0) return; // no tokens onSale

        g.onSale[channelId] = safeSub(v.total, v.soldValue);
        g.soldUnpaid[channelId] = safeSub(g.soldUnpaid[channelId], v.soldValue);
        delete g.unpaid[channelId][token].value;
        delete g.unpaid[channelId][token].soldValue;

        EnumerableSet.AddressSet storage sellers = g.addressesOnChannel[channelId];

        v.soldRest = v.soldValue;
        v.valueRest = v.value;
        while (v.soldRest != 0 ) {
            uint256 addrNum = sellers.length();
            uint256 divider = v.total * addrNum * 2;
            uint256 j = addrNum;
            while (j != 0 && v.soldRest != 0) {
                j--;
                address payable user = payable(sellers.at(j));
                uint256 amount = onSale[user][channelId];
                if (v.soldRest < 10000) v.userPart = v.soldRest;    // very small value
                else v.userPart = v.soldValue * (amount * addrNum + v.total) / divider;
                if (v.userPart >= amount) {
                    v.userPart = amount;
                    sellers.remove(user);
                }
                v.soldRest = safeSub(v.soldRest, v.userPart);
                onSale[user][channelId] = safeSub(amount, v.userPart);
                if (v.soldRest != 0) v.userValue = v.userPart * v.value / v.soldValue;
                else v.userValue = v.valueRest; // If all tokens split send the rest value
                v.valueRest = safeSub(v.valueRest, v.userValue);
                if (token == address(0)) {
                    if (!user.send(v.userValue))
                        balancesETH[user] = v.userValue;
                }
                else {
                    IERC20Token(token).transfer(user, v.userValue);
                }
            }
            v.total = v.total + v.soldRest - v.soldValue;
            v.soldValue = v.soldRest;
            v.value = v.valueRest;
        }
    }

    function _splitForGoals(uint256 channelId, address token, uint256 groupId) internal {

        Group storage g = groups[groupId];
        SplitValues memory v;
        v.soldValue = g.unpaid[channelId][token].soldValue;
        if (v.soldValue == 0) return; // no unpaid tokens
        v.value = g.unpaid[channelId][token].value;
        v.total = g.onSale[channelId];
        if (v.total == 0) return; // no tokens onSale

        EnumerableSet.AddressSet storage sellers = g.addressesOnChannel[channelId];
        uint256 addrNum = sellers.length();
        uint256 price = currencyPricesContract.getCurrencyPrice(token);

        v.soldRest = v.soldValue;
        uint256 j = addrNum;
        while (j != 0) {
            j--;
            address payable user = payable(sellers.at(j));
            uint256 amount = onSale[user][channelId];

            if (j == 0) v.userPart = v.soldRest;    // the last member get the rest
            else v.userPart = v.soldValue * amount / v.total;
            if (v.userPart >= amount) {
                v.userPart = amount;
            }
            v.soldRest = safeSub(v.soldRest, v.userPart);
            onSale[user][channelId] = safeSub(amount, v.userPart);

            v.userValue = v.userPart * v.value / v.soldValue;
            uint256 userValueUSD = v.userValue * price / DECIMAL_NOMINATOR;
            if (userValueUSD >= goals[user]) {
                goals[user] = 0;
                _moveToGroup(user, 2, true);  // move user with fulfilled goal to the Main group (2).
            }
            else {
                goals[user] = goals[user] - userValueUSD;
            }
            if (token == address(0)) {
                if (!user.send(v.userValue))
                    balancesETH[user] = v.userValue;
            }
            else {
                IERC20Token(token).transfer(user, v.userValue);
            }
        }
        g.onSale[channelId] = safeSub(v.total + v.soldRest, v.soldValue);
        g.soldUnpaid[channelId] = safeSub(g.soldUnpaid[channelId], v.soldValue);
        delete g.unpaid[channelId][token].value;
        delete g.unpaid[channelId][token].soldValue;
    }

    function withdraw() external {

        require(balancesETH[msg.sender] > 0, "No ETH");
        msg.sender.transfer(balancesETH[msg.sender]);
    }

    function _moveToGroup(address wallet, uint256 toGroup, bool allowUnpaid) internal {

        uint256 from = _getGroupId(wallet);
        require(from != toGroup, "Already in this group");
        inGroup[wallet] = toGroup + 1;  // change wallet's group id (1-based)
        groups[toGroup].wallets.add(wallet);
        groups[from].wallets.remove(wallet);
        uint channels = _getChannelsNumber();
        for (uint i = 1; i < channels; i++) {   // exclude channel 0. It allow company to wire tokens for Gateway supply
            if (onSale[wallet][i] > 0) {
                require(groups[from].soldUnpaid[i] == 0 || allowUnpaid, "There is unpaid giveaways");
                groups[from].onSale[i] = safeSub(groups[from].onSale[i], onSale[wallet][i]);
                groups[toGroup].onSale[i] = safeAdd(groups[toGroup].onSale[i], onSale[wallet][i]);
                groups[from].addressesOnChannel[i].remove(wallet);
                groups[toGroup].addressesOnChannel[i].add(wallet);
            }
        }
    }

    function _transfer(address to, uint256 value) internal returns (bool) {

        _nonZeroAddress(to);
        require(balances[msg.sender] >= value, "Not enough balance");
        balances[msg.sender] = safeSub(balances[msg.sender], value);
        balances[to] = safeAdd(balances[to], value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function _restrictedOrder(uint256 sellValue, address wantToken, uint256 wantValue, address payable buyer, address confirmatory) internal {

        require(sellValue > 0, "Zero sell value");
        balances[msg.sender] = safeSub(balances[msg.sender], sellValue);
        uint256 orderId = orders.length;
        orders.push(Order(msg.sender, buyer, sellValue, wantToken, wantValue, 4, confirmatory));  //add restricted order
        emit RestrictedOrder(msg.sender, buyer, sellValue, wantToken, wantValue, orderId, confirmatory);
    }
    function _getGroupId(address wallet) internal view returns(uint256 groupId) {

        groupId = inGroup[wallet];
        require(groupId > 0, "Wallet not added");
        groupId--;  // from 1-based to 0-based index
    }

    function _addPremintedWallet(address wallet, uint256 groupId) internal {

        require(groupId < groups.length, "Wrong group");
        IGovernance(governanceContract).addPremintedWallet(wallet);
        inGroup[wallet] = groupId + 1;    // groupId + 1 (0 - mean that wallet not added)
        groups[groupId].wallets.add(wallet);  // add to the group
    }

    function _getChannelsNumber() internal view returns (uint256 channelsNumber) {

        return IGateway(gatewayContract).getChannelsNumber();
    }

    function _nonZeroAddress(address addr) internal pure {

        require(addr != address(0), "Zero address");
    }

    receive() external payable {
        emit ReceivedETH(msg.sender, msg.value);
    }
}