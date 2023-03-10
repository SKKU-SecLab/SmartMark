
pragma solidity ^0.4.24;


interface ERC20_Interface {

  function totalSupply() external constant returns (uint);

  function balanceOf(address _owner) external constant returns (uint);

  function transfer(address _to, uint _amount) external returns (bool);

  function transferFrom(address _from, address _to, uint _amount) external returns (bool);

  function approve(address _spender, uint _amount) external returns (bool);

  function allowance(address _owner, address _spender) external constant returns (uint);

}


library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function min(uint a, uint b) internal pure returns (uint256) {

    return a < b ? a : b;
  }
}


contract Exchange{ 

    using SafeMath for uint256;


    
    struct Order {
        address maker;// the placer of the order
        uint price;// The price in wei
        uint amount;
        address asset;
    }

    struct ListAsset {
        uint price;
        uint amount;
        bool isLong;  
    }

    uint internal order_nonce;
    address public owner; //The owner of the market contract
    address[] public openDdaListAssets;
    address[] public openBooks;
    mapping (address => uint) public openDdaListIndex;
    mapping(address => mapping (address => uint)) public totalListed;//user to tokenamounts
    mapping(address => ListAsset) public listOfAssets;
    mapping(uint256 => Order) public orders;
    mapping(address =>  uint256[]) public forSale;
    mapping(uint256 => uint256) internal forSaleIndex;
    
    mapping (address => uint) internal openBookIndex;
    mapping(address => uint[]) public userOrders;
    mapping(uint => uint) internal userOrderIndex;
    mapping(address => bool) internal blacklist;
    

    event ListDDA(address _token, uint256 _amount, uint256 _price,bool _isLong);
    event BuyDDA(address _token,address _sender, uint256 _amount, uint256 _price);
    event UnlistDDA(address _token);
    event OrderPlaced(uint _orderID, address _sender,address _token, uint256 _amount, uint256 _price);
    event Sale(uint _orderID,address _sender,address _token, uint256 _amount, uint256 _price);
    event OrderRemoved(uint _orderID,address _sender,address _token, uint256 _amount, uint256 _price);

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    constructor() public{
        owner = msg.sender;
        openBooks.push(address(0));
        order_nonce = 1;
    }

    function list(address _tokenadd, uint256 _amount, uint256 _price) external {

        require(blacklist[msg.sender] == false);
        require(_price > 0);
        ERC20_Interface token = ERC20_Interface(_tokenadd);
        require(totalListed[msg.sender][_tokenadd] + _amount <= token.allowance(msg.sender,address(this)));
        if(forSale[_tokenadd].length == 0){
            forSale[_tokenadd].push(0);
            }
        forSaleIndex[order_nonce] = forSale[_tokenadd].length;
        forSale[_tokenadd].push(order_nonce);
        orders[order_nonce] = Order({
            maker: msg.sender,
            asset: _tokenadd,
            price: _price,
            amount:_amount
        });
        emit OrderPlaced(order_nonce,msg.sender,_tokenadd,_amount,_price);
        if(openBookIndex[_tokenadd] == 0 ){    
            openBookIndex[_tokenadd] = openBooks.length;
            openBooks.push(_tokenadd);
        }
        userOrderIndex[order_nonce] = userOrders[msg.sender].length;
        userOrders[msg.sender].push(order_nonce);
        totalListed[msg.sender][_tokenadd] += _amount;
        order_nonce += 1;
    }

    function listDda(address _asset, uint256 _amount, uint256 _price, bool _isLong) public onlyOwner() {

        require(blacklist[msg.sender] == false);
        ListAsset storage listing = listOfAssets[_asset];
        listing.price = _price;
        listing.amount= _amount;
        listing.isLong= _isLong;
        openDdaListIndex[_asset] = openDdaListAssets.length;
        openDdaListAssets.push(_asset);
        emit ListDDA(_asset,_amount,_price,_isLong);
        
    }

    function unlistDda(address _asset) public onlyOwner() {

        require(blacklist[msg.sender] == false);
        uint256 indexToDelete;
        uint256 lastAcctIndex;
        address lastAdd;
        ListAsset storage listing = listOfAssets[_asset];
        listing.price = 0;
        listing.amount= 0;
        listing.isLong= false;
        indexToDelete = openDdaListIndex[_asset];
        lastAcctIndex = openDdaListAssets.length.sub(1);
        lastAdd = openDdaListAssets[lastAcctIndex];
        openDdaListAssets[indexToDelete]=lastAdd;
        openDdaListIndex[lastAdd]= indexToDelete;
        openDdaListAssets.length--;
        openDdaListIndex[_asset] = 0;
        emit UnlistDDA(_asset);
    }

    function buyPerUnit(address _asset, uint256 _amount) external payable {

        require(blacklist[msg.sender] == false);
        ListAsset storage listing = listOfAssets[_asset];
        require(_amount <= listing.amount);
        uint totalPrice = _amount.mul(listing.price);
        require(msg.value == totalPrice);
        ERC20_Interface token = ERC20_Interface(_asset);
        if(token.allowance(owner,address(this)) >= _amount){
            assert(token.transferFrom(owner,msg.sender, _amount));
            owner.transfer(totalPrice);
            listing.amount= listing.amount.sub(_amount);
        }
        emit BuyDDA(_asset,msg.sender,_amount,totalPrice);
    }

    function unlist(uint256 _orderId) external{

        require(forSaleIndex[_orderId] > 0);
        Order memory _order = orders[_orderId];
        require(msg.sender== _order.maker || msg.sender == owner);
        unLister(_orderId,_order);
        emit OrderRemoved(_orderId,msg.sender,_order.asset,_order.amount,_order.price);
    }

    function buy(uint256 _orderId) external payable {

        Order memory _order = orders[_orderId];
        require(_order.price != 0 && _order.maker != address(0) && _order.asset != address(0) && _order.amount != 0);
        require(msg.value == _order.price);
        require(blacklist[msg.sender] == false);
        address maker = _order.maker;
        ERC20_Interface token = ERC20_Interface(_order.asset);
        if(token.allowance(_order.maker,address(this)) >= _order.amount){
            assert(token.transferFrom(_order.maker,msg.sender, _order.amount));
            maker.transfer(_order.price);
        }
        unLister(_orderId,_order);
        emit Sale(_orderId,msg.sender,_order.asset,_order.amount,_order.price);
    }

    function getOrder(uint256 _orderId) external view returns(address,uint,uint,address){

        Order storage _order = orders[_orderId];
        return (_order.maker,_order.price,_order.amount,_order.asset);
    }

    function setOwner(address _owner) public onlyOwner() {

        owner = _owner;
    }

    function blacklistParty(address _address, bool _motion) public onlyOwner() {

        blacklist[_address] = _motion;
    }

    function isBlacklist(address _address) public view returns(bool) {

        return blacklist[_address];
    }

    function getOrderCount(address _token) public constant returns(uint) {

        return forSale[_token].length;
    }

    function getBookCount() public constant returns(uint) {

        return openBooks.length;
    }

    function getOrders(address _token) public constant returns(uint[]) {

        return forSale[_token];
    }

    function getUserOrders(address _user) public constant returns(uint[]) {

        return userOrders[_user];
    }

    function getopenDdaListAssets() view public returns (address[]){

        return openDdaListAssets;
    }
    function getDdaListAssetInfo(address _assetAddress) public view returns(uint, uint, bool){

        return(listOfAssets[_assetAddress].price,listOfAssets[_assetAddress].amount,listOfAssets[_assetAddress].isLong);
    }

    function getTotalListed(address _owner, address _asset) public view returns (uint) {

       return totalListed[_owner][_asset]; 
    }

    function unLister(uint256 _orderId, Order _order) internal{

            uint256 tokenIndex;
            uint256 lastTokenIndex;
            address lastAdd;
            uint256  lastToken;
        totalListed[_order.maker][_order.asset] -= _order.amount;
        if(forSale[_order.asset].length == 2){
            tokenIndex = openBookIndex[_order.asset];
            lastTokenIndex = openBooks.length.sub(1);
            lastAdd = openBooks[lastTokenIndex];
            openBooks[tokenIndex] = lastAdd;
            openBookIndex[lastAdd] = tokenIndex;
            openBooks.length--;
            openBookIndex[_order.asset] = 0;
            forSale[_order.asset].length -= 2;
        }
        else{
            tokenIndex = forSaleIndex[_orderId];
            lastTokenIndex = forSale[_order.asset].length.sub(1);
            lastToken = forSale[_order.asset][lastTokenIndex];
            forSale[_order.asset][tokenIndex] = lastToken;
            forSaleIndex[lastToken] = tokenIndex;
            forSale[_order.asset].length--;
        }
        forSaleIndex[_orderId] = 0;
        orders[_orderId] = Order({
            maker: address(0),
            price: 0,
            amount:0,
            asset: address(0)
        });
        if(userOrders[_order.maker].length > 1){
            tokenIndex = userOrderIndex[_orderId];
            lastTokenIndex = userOrders[_order.maker].length.sub(1);
            lastToken = userOrders[_order.maker][lastTokenIndex];
            userOrders[_order.maker][tokenIndex] = lastToken;
            userOrderIndex[lastToken] = tokenIndex;
        }
        userOrders[_order.maker].length--;
        userOrderIndex[_orderId] = 0;
    }
}