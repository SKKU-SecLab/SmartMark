
pragma solidity ^0.4.19;
contract Bursa {


  address private ceo;
  address private admin;
  address public updateAvailable;
  mapping (address => mapping (uint256 => address)) private willsellUser;
  mapping (address => mapping (uint256 => uint256)) private willsellPrice;
  mapping (address => mapping (uint256 => uint256)) private willsellAmount;
  mapping (address => mapping (uint256 => address)) private willbuyUser;
  mapping (address => mapping (uint256 => uint256)) private willbuyPrice;
  mapping (address => mapping (uint256 => uint256)) private willbuyAmount;
  event Trade(uint256 amount, address token, uint256 price_each, address buyer, address seller);


  function Bursa() public {

    admin = msg.sender;
    ceo = msg.sender;
  }
  function() public payable {
    if (updateAvailable != 0) revert();
    funds[msg.sender] += msg.value;
  }
  function deposit() public payable returns (bool) {

    if (updateAvailable != 0) revert();
    funds[msg.sender] += msg.value;
    return true;
  }


  function buy(uint256 amount, address token, uint256 max_price_each, uint256 ask_order, address frontend_refund) public payable returns (bool) {

    if (msg.value != 0) funds[msg.sender] += msg.value;
    if ((willsellPrice[token][ask_order] > max_price_each && max_price_each != 0)
      || amount == 0
      || token == 0
      || token == address(this)
      || ask_order == 0
      || funds[msg.sender] <= 1e15
    ) revert();
    address buyer = msg.sender;
    address seller = willsellUser[token][ask_order];
    if (buyer == seller) {
      if (amount >= willsellAmount[token][ask_order]) {
        willsellAmount[token][ask_order] = 0;
        return true;
      }
      willsellAmount[token][ask_order] -= amount;
      return true;
    }
    uint256 volume = willsellVolume(token, ask_order);
    if (amount > volume) {
      if (volume == 0) {
        willsellAmount[token][ask_order] = 0;
        return false;
      }
      amount = volume;
    }
    uint256 pay = willsellPrice[token][ask_order] * amount / 1e18;
    uint256 fee;
    if (pay > 1e16 && traded[msg.sender]) {
      if (frontend_refund == 0 || frontend_refund == msg.sender) {
        fee = 7e14;
      }
      else fee = 1e15;
    } // else fee = 0
    if (pay + fee > funds[msg.sender]) {
      pay = funds[msg.sender] - fee;
      amount = pay * 1e18 / willsellPrice[token][ask_order];
    }
    if (!Bursa(token).transferFrom(seller, buyer, amount)) return false;
    funds[seller] = funds[seller] + pay;
    funds[buyer] = funds[buyer] - pay - fee;
    if (fee == 1e15) funds[frontend_refund] = funds[frontend_refund] + 3e14;
    if (traded[msg.sender] == false) {
      funds[ceo] = funds[ceo] + pay / 20;
      traded[msg.sender] = true;
    }
    if (amount == volume) {
      willsellAmount[token][ask_order] = 0;
    }
    else willsellAmount[token][ask_order] -= amount;
    Trade(amount, token, willsellPrice[token][ask_order], buyer, seller);
    return true;
  }


  function sell(uint256 amount, address token, uint256 min_price_each, uint256 bid_order, address frontend_refund) public payable returns (bool) {

    if (msg.value != 0) funds[msg.sender] += msg.value;
    if (willbuyPrice[token][bid_order] < min_price_each
      || amount == 0
      || token == 0
      || token == address(this)
      || bid_order == 0
    ) revert();
    address buyer = willbuyUser[token][bid_order];
    address seller = msg.sender;
    if (buyer == seller) {
      if (amount >= willbuyAmount[token][bid_order]) {
        willbuyAmount[token][bid_order] = 0;
        return true;
      }
      willbuyAmount[token][bid_order] -= amount;
      return true;
    }
    uint256 volume = willbuyVolume(token, bid_order);
    if (amount > volume) {
      if (volume == 0) {
        willbuyAmount[token][bid_order] = 0;
        return false;
      }
      amount = volume;
    }
    uint256 pay = willbuyPrice[token][bid_order] * amount / 1e18;
    uint256 fee;
    if (pay > 1e16 && traded[msg.sender]) {
      if (frontend_refund == 0 || frontend_refund == msg.sender) {
        fee = 7e14;
      }
      else fee = 1e15;
    } // else fee = 0
    if (!Bursa(token).transferFrom(seller, buyer, amount)) return false;
    funds[buyer] = funds[buyer] - pay;
    funds[seller] = funds[seller] + pay - fee;
    if (fee == 1e15) funds[frontend_refund] = funds[frontend_refund] + 3e14;
    if (traded[msg.sender] == false) {
      funds[ceo] = funds[ceo] + pay / 20;
      traded[msg.sender] = true;
    }
    if (amount == volume) {
      willbuyAmount[token][bid_order] = 0;
    }
    else willbuyAmount[token][bid_order] -= amount;
    Trade(amount, token, willbuyPrice[token][bid_order], buyer, seller);
    return true;
  }


  function willbuy(uint256 amount, address token, uint256 price_each, uint256 bid_order_spot) public payable returns (bool) {

    if (msg.value != 0) funds[msg.sender] += msg.value;
    if (updateAvailable != 0
      || amount == 0
      || token == 0
      || token == address(this)
      || price_each == 0
      || bid_order_spot == 0
    ) revert();
    while (willbuyAmount[token][bid_order_spot] != 0 && funds[willbuyUser[token][bid_order_spot]] != 0) ++bid_order_spot;
    willbuyUser[token][bid_order_spot] = msg.sender;
    willbuyPrice[token][bid_order_spot] = price_each;
    willbuyAmount[token][bid_order_spot] = amount;
    return true;
  }
  function willsell(uint256 amount, address token, uint256 price_each, uint256 ask_order_spot) public payable returns (bool) {

    if (msg.value != 0) funds[msg.sender] += msg.value;
    if (updateAvailable != 0
      || amount == 0
      || token == 0
      || token == address(this)
      || price_each == 0
      || ask_order_spot == 0
    ) revert();
    while (willsellAmount[token][ask_order_spot] != 0) {
      address user = willsellUser[token][ask_order_spot];
      uint256 balanceSeller = Bursa(token).balanceOf(user);
      if (balanceSeller == 0) break;
      uint256 allowanceSeller = Bursa(token).allowance(user, address(this));
      if (allowanceSeller == 0) break;
      ++ask_order_spot;
    }
    willsellUser[token][ask_order_spot] = msg.sender;
    willsellPrice[token][ask_order_spot] = price_each;
    willsellAmount[token][ask_order_spot] = amount;
    return true;
  }
  function withdraw(uint256 amount) public {

    if (funds[msg.sender] < amount || amount == 0) amount = funds[msg.sender];
    funds[msg.sender] -= amount;
    msg.sender.transfer(amount);
  }



  function name() constant public returns (string) {

    if (updateAvailable != 0) return "BURSA DEX (deactivated)";
    return "BURSA DEX";
  }
  function balanceOf(address user)
  constant public returns (uint256 balance) {

    return funds[user];
  }
  function balanceApprovedForToken(address token, address user)
  constant public returns (uint256 amount) {

    if (token == 0 || token == address(this)) return funds[user];
    amount = Bursa(token).balanceOf(user);
    uint256 allowance = Bursa(token).allowance(user, address(this));
    if (amount > allowance) amount = allowance;
    return amount;
  }


  function findBestAsk(address token, uint256 min_trade_amount) public
  constant returns (uint256 ask_order, uint256 volume, uint256 price) {

    price = (uint256)(-1);
    uint256 i=1;
    while (willsellUser[token][i] != 0) {
      if (willsellPrice[token][i] < price && willsellAmount[token][i] != 0) {
        volume = willsellVolume(token, i);
        if (volume >= min_trade_amount && volume >= 1e15 * 1e18 / (willsellPrice[token][i] + 1)) {
          price = willsellPrice[token][i];
          ask_order = i;
        }
      }
      ++i;
    }
    if (ask_order == 0) return (0,0,0);
    return;
  }
  function findBestBid(address token, uint256 min_trade_amount) public
  constant returns (uint256 bid_order, uint256 volume, uint256 price) {

    uint256 i=1;
    while (willbuyUser[token][i] != 0) {
      if (willbuyPrice[token][i] > price && willbuyAmount[token][i] != 0) {
        volume = willbuyVolume(token, i);
        if (volume >= min_trade_amount && volume >= 1e15 * 1e18 / (willbuyPrice[token][i] + 1)) {
          price = willbuyPrice[token][i];
          bid_order = i;
        }
      }
      ++i;
    }
    if (bid_order == 0) return (0,0,0);
    return;
  }

  function willbuyFindSpot(address token) public
  constant returns (uint256 bid_order_spot) {

    Bursa(token).symbol();
    uint256 i=1;
    while (willbuyAmount[token][i] >= 1e15 * 1e18 / (willbuyPrice[token][i] + 1) && funds[willbuyUser[token][i]] != 0) ++i;
    return i;
  }
  function willsellFindSpot(address token) public
  constant returns (uint256 ask_order_spot) {

    Bursa(token).symbol();
    uint256 i=1;
    while (willsellAmount[token][i] >= 1e15 * 1e18 / (willsellPrice[token][i] + 1)) {
      uint256 balanceSeller = Bursa(token).balanceOf(willsellUser[token][i]);
      if (balanceSeller == 0) return i;
      uint256 allowanceSeller = Bursa(token).allowance(willsellUser[token][i], address(this));
      if (allowanceSeller == 0) return i;
      ++i;
    }
    return i;
  }



  function willbuyInfo(address token, uint256 bid_order) public
  constant returns (address user, uint256 price, uint256 amount) {

    user = willbuyUser[token][bid_order];
    price = willbuyPrice[token][bid_order];
    amount = willbuyAmount[token][bid_order];
    uint256 pay = price * amount / 1e18;
    if (pay > funds[user]) {
      pay = funds[user];
      amount = pay * 1e18 / price;
    }
    return;
  }
  function willbuyVolume(address token, uint256 bid_order) private
  constant returns (uint256) {

    uint256 amount = willbuyAmount[token][bid_order];
    address user = willbuyUser[token][bid_order];
    if (amount == 0 || funds[user] == 0) return 0;
    uint256 price = willbuyPrice[token][bid_order];
    uint256 pay = price * amount / 1e18;
    if (pay > funds[user]) {
      pay = funds[user];
      amount = pay * 1e18 / price;
    }
    return amount;
  }

  function willsellInfo(address token, uint256 ask_order) public
  constant returns (address user, uint256 price, uint256 amount) {

    user = willsellUser[token][ask_order];
    price = willsellPrice[token][ask_order];
    amount = willsellAmount[token][ask_order];
    uint256 balanceSeller = Bursa(token).balanceOf(user);
    uint256 allowanceSeller = Bursa(token).allowance(user, address(this));
    if (balanceSeller > allowanceSeller) balanceSeller = allowanceSeller;
    if (amount > balanceSeller) amount = balanceSeller;
    return;
  }
  function willsellVolume(address token, uint256 ask_order) private
  constant returns (uint256) {

    uint256 amount = willsellAmount[token][ask_order];
    if (amount == 0) return 0;
    address user = willsellUser[token][ask_order];
    uint256 balanceSeller = Bursa(token).balanceOf(user);
    if (balanceSeller == 0) return 0;
    uint256 allowanceSeller = Bursa(token).allowance(user, address(this));
    if (allowanceSeller == 0) return 0;
    if (balanceSeller > allowanceSeller) balanceSeller = allowanceSeller;
    if (amount > balanceSeller) amount = balanceSeller;
    return amount;
  }



  function symbol() constant public returns (string) {

    if (updateAvailable != 0) return "exBURSA";
    return "BURSA";
  }
  function decimals() constant public returns (uint256) {

    return 18;
  }
  function totalSupply() constant public returns (uint256 supply) {

    return this.balance;
  }
  function transfer(address _to, uint256 _value) public returns (bool success) {

    if (_value > funds[msg.sender]) _value = funds[msg.sender];
    funds[msg.sender] -= _value;
    funds[_to] += _value;
    Transfer(msg.sender, _to, _value);
    return true;
  }
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

    if (_value > funds[msg.sender]) _value = funds[msg.sender];
    if (_value > approved[_from][msg.sender]) _value = approved[_from][msg.sender];
    funds[_from] -= _value;
    funds[_to] += _value;
    approved[_from][msg.sender] -= _value;
    Transfer(_from, _to, _value);
    return true;
  }
  function approve(address _spender, uint256 _value) public returns (bool success) {

    if (_spender == address(this)) return true;
    approved[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
  function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {

    if (_spender == address(this)) return balanceOf(_owner);
    return approved[_owner][_spender];
  }
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  mapping (address => mapping (address => uint256)) private approved;
  mapping (address => uint256) private funds;
  mapping (address => bool) private traded;



  function refundLostToken(address token, address user) public {

    if (msg.sender != admin && msg.sender != ceo) return;
    uint256 amount = Bursa(token).balanceOf(address(this));
    Bursa(token).transfer(user, amount);
  }
  function rollUpdate(address _updateAvailable) public {

    if (msg.sender == admin || msg.sender == ceo) updateAvailable = _updateAvailable;
  }
  function assignCEO(address _ceo) public {

    if (msg.sender == admin) {
      ceo = _ceo;
    }
    else if (msg.sender == ceo) {
      admin = ceo;
      ceo = _ceo;
    }
  }

}