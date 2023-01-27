pragma solidity ^0.4.22;


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b > 0); // Solidity automatically throws when dividing by 0
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
}
pragma solidity ^0.4.22;

contract Oly {

  using SafeMath for uint256;

  string public constant name = "Etherpoly Dollars"; 
  string public constant symbol = "OLY"; 
  uint8 public constant decimals = 3;

  uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals));
  mapping(address => uint256) balances;
  mapping(uint256 => uint256) lastUpdate;
  mapping (address => mapping (address => uint256)) internal allowed;
  uint256 public totalSupply_;
  uint256 private dateCreated;
  address private polyAddress;

   constructor (address _polyAddress) public {
    polyAddress = _polyAddress;
    dateCreated = now - 2 hours;
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }


    modifier onlyPayloadSize(uint size) {

    assert(msg.data.length >= size * 32 + 4);
    _;
  }

    modifier onlyPoly() {

    require (msg.sender == polyAddress);
    _;
  }

 
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);



  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

 
  function transfer(address _to, uint256 _value) public onlyPayloadSize(2) returns (bool) {

    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }


  function balanceOf(address _owner) public view returns (uint256 balance) {

    return balances[_owner];
  }




  function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public onlyPayloadSize(2) returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }


  function allowance(address _owner, address _spender) public view returns (uint256) {

    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint _addedValue) public onlyPayloadSize(2) returns (bool) {

    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public onlyPayloadSize(2) returns (bool) {

    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }


  function polyUpdateRevenues(address _tokenOwner, uint256 _tokenId, uint256 _revenues) external onlyPoly() returns (uint256) {

    require(_tokenOwner != address(0));
    require (_revenues > 0);

    if (lastUpdate[_tokenId] > 0) {
      uint256 _timePassed = now - lastUpdate[_tokenId];
      _timePassed /= 3600;
    }
    else { 
      _timePassed = now - dateCreated;
      _timePassed /= 3600;
    }

    if (_timePassed >= 1 && _timePassed < 100000) {
      uint256 _cumulatedRevenues = _revenues * _timePassed; 
      lastUpdate[_tokenId] = now;
      uint256 _newTotalSupply = totalSupply_.add(_cumulatedRevenues);
      uint256 _newBalance = balances[_tokenOwner].add(_cumulatedRevenues);

      totalSupply_ = _newTotalSupply;
      balances[_tokenOwner] = _newBalance;

      emit Transfer(0x0, _tokenOwner, _cumulatedRevenues);
      return _cumulatedRevenues;
      
    } else return 0;

  }


  function polyTransfer(address _from, address _to, uint256 _value) external onlyPoly() {

    require(_from != address(0));
    require(_value <= balances[_from]);
    require (_value > 0);
    require(_to != _from);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(_from, _to, _value);
  }


}
pragma solidity ^0.4.22;

contract ERC721Token {

  using SafeMath for uint256;

  string public constant name = "Etherpoly"; 
  string public constant symbol = "POLY"; 
  uint8 public constant decimals = 0;
  uint256 private constant olyDecimals = 10 ** 3;

  uint256 public totalTokens;

  uint256 public tokensIndex;

  address private creator;

  address private olyAddress;

  uint256 public totalUsersBalance;

  mapping (address => uint256) private usersBalance; 

  mapping (uint256 => address) private tokenOwner;

  mapping (uint256 => address) private tokenApprovals;

  mapping (address => uint256[]) private ownedTokens;

  mapping(uint256 => uint256) private ownedTokensIndex;

  struct CityStruct {
    bytes32 name;
    bytes16 country;
    uint32 pop;
    int32 lat;
    int32 long;
    uint8 upgType;
    uint32 finneyValue;
    uint64 olyValue;
  }

  struct CountryStruct {
    uint32 pop;
    uint64 gdp;
  }

  mapping(uint256 => CityStruct) public CityDB;

  mapping (bytes16 => CountryStruct) public Countries;

  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event Upgrade(uint256 indexed _tokenId, uint8 _upgradeType);

  modifier onlyCreator() {

    require(creator == msg.sender);
    _;
  }

  modifier onlyOwnerOf(uint256 _tokenId) {

    require(ownerOf(_tokenId) == msg.sender);
    _;
  }

  modifier cityExists(uint256 _tokenId) {

  require(CityDB[_tokenId].pop > 0);
  _;
}

  function() public payable {}

  function totalSupply() public view returns (uint256) {

    return totalTokens;
  }


  function balanceOf(address _owner) public view returns (uint256) {

    return ownedTokens[_owner].length;
  }

  function tokensOf(address _owner) public view returns (uint256[]) {

    return ownedTokens[_owner];
  }

  function ownerOf(uint256 _tokenId) public view returns (address) {

    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  function approvedFor(uint256 _tokenId) public view returns (address) {

    return tokenApprovals[_tokenId];
  }

  function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {

    require(_to != address(this));
    clearApprovalAndTransfer(msg.sender, _to, _tokenId);
  }

  function buyTokenWei(uint256 _tokenId) public payable cityExists (_tokenId) {

 
    address _tokenOwner = ownerOf(_tokenId);
    require (CityDB[_tokenId].finneyValue != 0);
    uint256 _weiValue = CityDB[_tokenId].finneyValue;
    _weiValue = _weiValue.mul(1000000000000000);
    require (msg.value >= _weiValue);
    require (msg.sender != _tokenOwner);

    uint256 _hourlyRevenues = getCityRevenuesValue(_tokenId);
    Oly olyInstance = Oly(olyAddress);  
    olyInstance.polyUpdateRevenues(_tokenOwner, _tokenId, _hourlyRevenues);

    uint256 updateValueCom = msg.value;
    updateValueCom = updateValueCom.mul(95);
    updateValueCom = updateValueCom.div(100);


    usersBalance[_tokenOwner] = usersBalance[_tokenOwner].add(updateValueCom); 
    totalUsersBalance = totalUsersBalance.add(updateValueCom);

    clearApprovalAndTransfer(_tokenOwner, msg.sender, _tokenId);

    CityDB[_tokenId].finneyValue = 0;
    CityDB[_tokenId].olyValue = 0;  
  }

  function setTokenFinneyValue(uint32 _amount, uint256 _tokenId) public onlyOwnerOf(_tokenId) cityExists (_tokenId) {

    CityDB[_tokenId].finneyValue = _amount;
  }

  function setTokenOlyValue(uint64 _amount, uint256 _tokenId) public onlyOwnerOf(_tokenId) cityExists (_tokenId) {

    CityDB[_tokenId].olyValue = _amount;
  }

  function getUsersBalance(address _addr) public view returns (uint256 userBalance) {

    userBalance = usersBalance[_addr];
    return userBalance;
  } 

  function withdrawUsers() external payable returns(uint256 paidUserBalance) {

    uint256 _userBalance = usersBalance[msg.sender];
    address _contractAddr = this;
    require(_userBalance != 0);
    require(_contractAddr.balance >= _userBalance);

    usersBalance[msg.sender] = 0;
    totalUsersBalance = totalUsersBalance.sub(_userBalance);

    assert(msg.sender.send(_userBalance));
    return _userBalance;
  }

  function withdrawContract() external payable onlyCreator() {

    address _contractAddr = this;
    uint256 _contractBalance = _contractAddr.balance;
    _contractBalance = _contractBalance.sub(totalUsersBalance);
    require(_contractBalance > 0);
    creator.transfer(_contractBalance);
  }

  function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) cityExists (_tokenId) {

    address owner = ownerOf(_tokenId);
    require(_to != owner);
    if (approvedFor(_tokenId) != 0 || _to != 0) {
      tokenApprovals[_tokenId] = _to;
      emit Approval(owner, _to, _tokenId);
    }
  }

  function takeOwnership(uint256 _tokenId) public {

    require(isApprovedFor(msg.sender, _tokenId));
    clearApprovalAndTransfer(ownerOf(_tokenId), msg.sender, _tokenId);
  }

  function _mintCity(address _to, bytes32 _name, bytes16 _country, uint32 _pop, int32 _lat, int32 _long, uint32 _finney, uint64 _oly) public {

    require(_to != address(0));
    require(_pop > 0);
    require(Countries[_country].gdp != 0);
    uint256 _tokenId = tokensIndex;
    require (CityDB[_tokenId].name == "");

    CityDB[_tokenId] = CityStruct (_name, _country, _pop, _lat, _long, 0, _finney, _oly);
    addToken(_to, _tokenId);
    tokensIndex = tokensIndex.add(1);
    emit Transfer(0x0, _to, _tokenId);

  }

  function _burn(uint256 _tokenId) onlyOwnerOf(_tokenId) cityExists (_tokenId) public {

    if (approvedFor(_tokenId) != 0) {
      clearApproval(msg.sender, _tokenId);
    }
    removeToken(msg.sender, _tokenId);

    CityDB[_tokenId].name = '';
    CityDB[_tokenId].country = '';
    CityDB[_tokenId].pop = 0;
    CityDB[_tokenId].lat = 0;
    CityDB[_tokenId].long = 0;
    CityDB[_tokenId].upgType = 0;
    CityDB[_tokenId].finneyValue= 0;
    CityDB[_tokenId].olyValue = 0;
    emit Transfer(msg.sender, 0x0, _tokenId);
  }


  function isApprovedFor(address _owner, uint256 _tokenId) internal view returns (bool) {

    return approvedFor(_tokenId) == _owner;
  }

  function clearApprovalAndTransfer(address _from, address _to, uint256 _tokenId) internal {

    require(_to != address(0));
    require(_to != ownerOf(_tokenId));
    require(ownerOf(_tokenId) == _from);

    clearApproval(_from, _tokenId);
    removeToken(_from, _tokenId);
    addToken(_to, _tokenId);
    emit Transfer(_from, _to, _tokenId);
  }

  function clearApproval(address _owner, uint256 _tokenId) private {

    require(ownerOf(_tokenId) == _owner);
    tokenApprovals[_tokenId] = 0;
    emit Approval(_owner, 0, _tokenId);
  }

  function addToken(address _to, uint256 _tokenId) private {

    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    uint256 length = balanceOf(_to);
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
    totalTokens = totalTokens.add(1);
  }

  function removeToken(address _from, uint256 _tokenId) private {

    require(ownerOf(_tokenId) == _from);

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = balanceOf(_from).sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    tokenOwner[_tokenId] = 0;
    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;

    ownedTokens[_from].length--;
    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
    totalTokens = totalTokens.sub(1);
  }

  constructor () public payable {

  creator = msg.sender;

  Countries["United States"] = CountryStruct (323100000,18570);
  Countries["China"] = CountryStruct (1379000000,11200);
  Countries["France"] = CountryStruct (66900000,2465);
  Countries["South Korea"] = CountryStruct (51107797,1411);
  Countries["Japan"] = CountryStruct (126194685,4884);
  Countries["Germany"] = CountryStruct (81365343,3652);
  Countries["United Kingdom"] = CountryStruct (65861628,2565);
  Countries["India"] = CountryStruct (1355621800,2439);
  Countries["Brazil"] = CountryStruct (213202329,2081);
  Countries["Italy"] = CountryStruct (59932451,1921);
  Countries["Canada"] = CountryStruct (36991986,1640);
  Countries["Russia"] = CountryStruct (146466710,1469);
  Countries["Australia"] = CountryStruct (25039715,1390);
  Countries["Spain"] = CountryStruct (45878041,1307);
  Countries["Mexico"] = CountryStruct (131951936,1142);
  Countries["Indonesia"] = CountryStruct (266895567,1011);
  Countries["Turkey"] = CountryStruct (82491371,841);
  Countries["Netherlands"] = CountryStruct (17090565,824);
  Countries["Switzerland"] = CountryStruct (8573481,681);
  Countries["Saudi Arabia"] = CountryStruct (33645897,679);
  Countries["Argentina"] = CountryStruct (44684737,620);
  Countries["Taiwan"] = CountryStruct (23591604,571);
  Countries["Sweden"] = CountryStruct (10008633,542);
  Countries["Poland"] = CountryStruct (38639940,510);
  Countries["Belgium"] = CountryStruct (11510188,492);
  Countries["Thailand"] = CountryStruct (68684785,438);
  Countries["Iran"] = CountryStruct (81938060,428);
  Countries["Austria"] = CountryStruct (25039734,409);
  Countries["Egypt"] = CountryStruct (97187207,408);
  Countries["Nigeria"] = CountryStruct (22176294,395);
  Countries["Norway"] = CountryStruct (5397619,392);
  Countries["UAE"] = CountryStruct (9542843,379);
  Countries["Israel"] = CountryStruct (8446249,348);
  Countries["South Africa"] = CountryStruct (56175824,344);
  Countries["Hong Kong"] = CountryStruct (7455354,334);
  Countries["Ireland"] = CountryStruct (4728945,326);
  Countries["Denmark"] = CountryStruct (5736458,324);
  Countries["Malaysia"] = CountryStruct (31637840,310);
  Countries["Colombia"] = CountryStruct (49571747,307);
  Countries["Singapore"] = CountryStruct (5921295,306);
  Countries["Pakistan"] = CountryStruct (200195156,304);
  Countries["Chile"] = CountryStruct (18487758,263);
  Countries["Finland"] = CountryStruct (5581914,251);
  Countries["Vietnam"] = CountryStruct (96392488,216);
  Countries["Venezuela"] = CountryStruct (32347707,215);
  Countries["Portugal"] = CountryStruct (10224152,212);
  Countries["Peru"] = CountryStruct (32543775,210);
  Countries["Romania"] = CountryStruct (19078379,205);
  Countries["Greece"] = CountryStruct (10833357,204);
  Countries["New Zealand"] = CountryStruct (4618946,201);
  Countries["Iraq"] = CountryStruct (39880904,193);
  Countries["Qatar"] = CountryStruct (2562082,166);
  Countries["Hungary"] = CountryStruct (9768789,132);
  Countries["Kuwait"] = CountryStruct (4457395,118);
  Countries["Morocco"] = CountryStruct (35280000,111);
  Countries["Ukraine"] = CountryStruct (42264829,104);
  Countries["Puerto Rico"] = CountryStruct (3667634,103);
  Countries["Lebanon"] = CountryStruct (6927630,53);
  Countries["Cote d'Ivoire"] = CountryStruct (24244054,40);
  Countries["Uganda"] = CountryStruct (42672478,26);
  Countries["Iceland"] = CountryStruct (336002,25);

  _mintCity(msg.sender, "New York City", "United States", 8537673, 4073000, -7394000, 31710, 34245881000);
  _mintCity(msg.sender, "Los Angeles", "United States", 3971883, 3405000, -11824000, 14750, 15931949000);
}


    function setOlyAddress(address _contractAddress) public onlyCreator() returns (bool _successful) {

      olyAddress = _contractAddress;
      return true;
    }

    function getOlyTotalSupply() public view returns (uint256 _totalSupply) {

      Oly olyInstance = Oly(olyAddress);
      return olyInstance.totalSupply();
    }


    function getCityRevenuesValue(uint256 _tokenId) public view cityExists(_tokenId) returns (uint256 _hourlyBoostedRevenues) {

      uint32 _cityPop = CityDB[_tokenId].pop;
      
      require (_cityPop != 0);

      bytes16 _cityCountry = CityDB[_tokenId].country;
      uint64 _countryGDP = Countries[_cityCountry].gdp;
      uint256 _cityUpgType = CityDB[_tokenId].upgType;
      uint8 _upgPercent = 100;
      uint256 _upgBaseBonus = 0; 

      if (_cityUpgType == 1) {
          _upgPercent = 125;
          _upgBaseBonus = 0;
      } else if (_cityUpgType == 2) {
          _upgPercent = 150;
          _upgBaseBonus = 0; 
      } else if (_cityUpgType == 3) {
          _upgPercent = 115;
          _upgBaseBonus = 6944444 * olyDecimals;
      } else if (_cityUpgType == 4) {
          _upgPercent = 100;
          _upgBaseBonus = 13888889 * olyDecimals;
      } 
      uint256 _baseDivider = 100000000;
      uint256 _hourlyRevenues = _cityPop * _countryGDP * olyDecimals; 
      _hourlyBoostedRevenues = _hourlyRevenues * _upgPercent / 100 + _upgBaseBonus;
      _hourlyBoostedRevenues = _hourlyBoostedRevenues.div(_baseDivider);

    }

    function getUpgradeCost(uint256 _tokenId, uint8 _upgradeType) public view cityExists(_tokenId) returns (uint256 _upgradeCost) {

      require (_upgradeType <= 4);
      bytes16 _cityCountry = CityDB[_tokenId].country;
      uint256 _countryGDP = Countries[_cityCountry].gdp;

        if (_upgradeType == 0) {
          _upgradeCost = 0;
        } else {
            uint8 _upgPercent = 100;
            uint256 _upgBaseBonus = 0; 
            uint256 _upgBaseCost = 0;

            if (_upgradeType == 1) {
                _upgPercent = 125;
                _upgBaseBonus = 0;
                _upgBaseCost = _countryGDP / 10 * olyDecimals; 
            } else if (_upgradeType == 2) {
                _upgPercent = 150;
                _upgBaseBonus = 0; 
                _upgBaseCost = _countryGDP / 5 * olyDecimals;
            } else if (_upgradeType == 3) {
                _upgPercent = 115;
                _upgBaseBonus = 50 * olyDecimals;
                _upgBaseCost = _countryGDP / 8 * olyDecimals; 
            } else if (_upgradeType == 4) {
                _upgPercent = 100;
                _upgBaseBonus = 100 * olyDecimals;
                _upgBaseCost = _countryGDP / 15 * olyDecimals; 
            } 

            uint256 _revenues = getCityRevenuesValue(_tokenId) * 24 * 30;
            uint256 _boostedRevenues = _revenues * _upgPercent;
            _boostedRevenues = _boostedRevenues.div(100);
            _boostedRevenues += _upgBaseBonus;
            _upgradeCost = _boostedRevenues - _revenues + _upgBaseCost;

        }
    }


  function olyUpdateRevenues(uint256 _tokenId) public onlyOwnerOf(_tokenId) cityExists(_tokenId) {

    require (CityDB[_tokenId].name != "");

    address _tokenOwner = ownerOf(_tokenId);
    uint256 _hourlyRevenues = getCityRevenuesValue(_tokenId);

    Oly olyInstance = Oly(olyAddress);  
    olyInstance.polyUpdateRevenues(_tokenOwner, _tokenId, _hourlyRevenues);
  }
  
  function olyBuyToken(uint256 _tokenId) public cityExists(_tokenId) {

    require (CityDB[_tokenId].name != "");
    require (CityDB[_tokenId].olyValue != 0);

    address _tokenOwner = ownerOf(_tokenId);
    address _tokenBuyer = msg.sender;
    require (_tokenOwner != _tokenBuyer);
    
    uint256 _cityValue = CityDB[_tokenId].olyValue;

    uint256 _hourlyRevenues = getCityRevenuesValue(_tokenId);
    Oly olyInstance = Oly(olyAddress);  
    olyInstance.polyUpdateRevenues(_tokenOwner, _tokenId, _hourlyRevenues);

    olyInstance.polyTransfer(_tokenBuyer, _tokenOwner, _cityValue);
    
    clearApprovalAndTransfer(_tokenOwner, _tokenBuyer, _tokenId);

    CityDB[_tokenId].finneyValue = 0;
    CityDB[_tokenId].olyValue = 0;  
    
  }

   function olyUpgradeCity(uint256 _tokenId, uint8 _upgradeType) public onlyOwnerOf(_tokenId) cityExists(_tokenId) {

    require (CityDB[_tokenId].name != '');
    require (_upgradeType <= 4);
    require (CityDB[_tokenId].upgType != _upgradeType);

    address _tokenOwner = ownerOf(_tokenId);
    uint256 _upgCost = getUpgradeCost(_tokenId, _upgradeType);
    require (_upgCost >= 1);

    Oly olyInstance = Oly(olyAddress);  
    olyUpdateRevenues(_tokenId);

    olyInstance.polyTransfer(_tokenOwner, 0x0, _upgCost);

    CityDB[_tokenId].upgType = _upgradeType;
    emit Upgrade(_tokenId, _upgradeType);
    
  }

  function olyGetBalance(address _tokenOwner) public view returns (uint256) {

    Oly olyInstance = Oly(olyAddress);  
    return olyInstance.balanceOf(_tokenOwner);
  }

}