


pragma solidity ^0.7.0;

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




pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.7.0;

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




pragma solidity ^0.7.0;

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




pragma solidity ^0.7.0;




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




pragma solidity ^0.7.0;

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



pragma solidity 0.7.6;




contract BTCPriceBet is AccessControl {

  using SafeMath for uint256;

  bool paused;
    
  uint8 constant public PRIZE_PERCENTAGE = 30;
  uint64 constant private PRICE_MAX = 10e9; //  < 1M
  uint256 constant private INITIAL_BET_DURATION = 10 minutes;
  uint256 constant private BET_ALLOWED_DURATION = 50 minutes;
  bytes32 constant private PRICE_FEED_ROLE = "PRICE_FEED_ROLE";
  bytes32 constant private OWNER_ROLE = "OWNER";
  
  uint256 public betEth;
  uint256 public betTokens;

  uint256 public ongoingRound;
  uint256 public roundStartedAt;
  uint256 public roundDuration;

  address public token;

  struct Bet {
    address account;
    uint256 timestamp;
    uint64 price;
  }
  
  struct HistoryBet {
    bool isEth;
    uint256 timestamp;
    uint64 price;
  }
  
  mapping(address => mapping(address => HistoryBet[])) private betHistory; //  token => (address => HistoryBet[])
  mapping(address => uint64[]) public pricesUsed;   //  token => price[], 0x0 - ETH
  mapping(address => mapping(uint256 => mapping(uint256 => Bet[]))) private betsForRound;   //  token => (round => (price => Bet)), 0x0 - ETH
  mapping(address => mapping(address => uint256)) private lastRoundWithBetMade; //  token => (address => round), 0x0 - ETH
  mapping(address => uint256) public betsNumber;    //  token => bets, 0x0 - ETH

  mapping(address => mapping(address => uint256)) private prizeWithdrawn;   //  token => (address => amount), 0x0 - ETH
  mapping(address => mapping(address => uint256)) private prizeToWithdraw;  //  token => (address => amount), 0x0 - ETH

  mapping(address => mapping(uint256 => uint64[4])) private priceAndWinningPricesForRound;  //  token => uint64[], 0x0 - ETH
  
  mapping(address => uint256) private devFee;   //  token => fee
  
  event BetMade();
  event RoundFinished();

  constructor(address _token, address _priceFeed) {
    require(_token != address(0), "Wrong token");
    require(_priceFeed != address(0), "Wrong PRICE_FEED_ROLE");

    token = _token;
    betEth = 2e16;  //  0.02 ETH
    betTokens = 10e2; //  1000
    roundDuration = 1 hours;
    roundStartedAt = block.timestamp;
    ongoingRound = 1;
      
    _setupRole(PRICE_FEED_ROLE, _priceFeed);
    _setupRole(OWNER_ROLE, msg.sender);
    _setRoleAdmin(OWNER_ROLE, OWNER_ROLE);
  }
  
  function makeBet(address _token, uint64[] calldata _prices) external payable {

    require(!paused, "Paused");
    require(_token == address(0) || _token == token, "Wrong token");
    
    uint256 pricesNumber = _prices.length;
    require(pricesNumber > 0, "Wrong prices num");
    
    require(block.timestamp < roundStartedAt.add(BET_ALLOWED_DURATION), "No more bets");

    if (block.timestamp <= roundStartedAt.add(INITIAL_BET_DURATION)) {
        if (lastRoundWithBetMade[_token][msg.sender] != ongoingRound) {
             lastRoundWithBetMade[_token][msg.sender] = ongoingRound;   
        }
    } else {
      require(lastRoundWithBetMade[_token][msg.sender] == ongoingRound, "Not allowed to bet");
    }

    if (_token == address(0)) {
      require(msg.value == betEth.mul(pricesNumber), "Wrong betEth");
    } else {
      require(msg.value == 0, "Remove eth value");
      IERC20(token).transferFrom(msg.sender, address(this), betTokens.mul(pricesNumber));
    }
    
    for(uint256 i = 0; i < pricesNumber; i ++) {
        uint64 price = _prices[i];
        require((price > 0) && (price < PRICE_MAX), "Wrong price");
        
        if (betsForRound[_token][ongoingRound][price].length == 0) {
          pricesUsed[_token].push(price);
        }
    
        betsForRound[_token][ongoingRound][price].push(Bet(msg.sender, block.timestamp, price));
        betHistory[_token][msg.sender].push(HistoryBet(_token == address(0), block.timestamp, price));
    }
        
    betsNumber[_token] = betsNumber[_token].add(pricesNumber);
    emit BetMade();
  }

  function finishRound(uint64 _price, uint64[3] memory _winnerPricesETH, uint64[3] memory _winnerPricesToken) external {

    require(hasRole(PRICE_FEED_ROLE, msg.sender), "Not PRICE_FEED_ROLE");
    require(block.timestamp > roundStartedAt.add(roundDuration), "Not finished yet");

    priceAndWinningPricesForRound[address(0)][ongoingRound][0] = _price;
    priceAndWinningPricesForRound[token][ongoingRound][0] = _price;
    
    uint256 betsEth = betsNumber[address(0)].mul(betEth);
    uint256 betsToken = betsNumber[token].mul(betTokens);

    uint256 prizeEth = betsEth.mul(PRIZE_PERCENTAGE).div(100);
    uint256 prizeToken = betsToken.mul(PRIZE_PERCENTAGE).div(100);
    
    uint256 prizeUsedEth;
    uint256 prizeUsedToken;
    
    for (uint8 i = 0; i < _winnerPricesETH.length; i++) {
      if (betsForRound[address(0)][ongoingRound][_winnerPricesETH[i]].length > 0) {
        address winner = betsForRound[address(0)][ongoingRound][_winnerPricesETH[i]][0].account;
        prizeToWithdraw[address(0)][winner] = prizeToWithdraw[address(0)][winner].add(prizeEth);
        priceAndWinningPricesForRound[address(0)][ongoingRound][i+1] = _winnerPricesETH[i];
        prizeUsedEth = prizeUsedEth.add(prizeEth);
      }

      if (betsForRound[token][ongoingRound][_winnerPricesToken[i]].length > 0) {
        address winner = betsForRound[token][ongoingRound][_winnerPricesToken[i]][0].account;
        prizeToWithdraw[token][winner] = prizeToWithdraw[token][winner].add(prizeToken);
        priceAndWinningPricesForRound[token][ongoingRound][i+1] = _winnerPricesToken[i];
        prizeUsedToken = prizeUsedToken.add(prizeToken);
      }
    }
    
    if (betsEth > 0) {
      if (prizeUsedEth == prizeEth) {
        address winner = betsForRound[address(0)][ongoingRound][_winnerPricesETH[0]][0].account;
        prizeToWithdraw[address(0)][winner] = prizeToWithdraw[address(0)][winner].add(prizeEth.mul(2));
        prizeUsedEth = prizeUsedEth.mul(3);
      }
      devFee[address(0)] = devFee[address(0)].add(betsEth.sub(prizeUsedEth));
    }
    
    if (betsToken > 0) {
      if (prizeUsedToken == prizeToken) {
        address winner = betsForRound[token][ongoingRound][_winnerPricesToken[0]][0].account;
        prizeToWithdraw[token][winner] = prizeToWithdraw[token][winner].add(prizeToken.mul(2));
        prizeUsedToken = prizeUsedToken.mul(3);
      }
      devFee[token] = devFee[token].add(betsToken.sub(prizeUsedToken));  
    }

    delete pricesUsed[address(0)];
    delete pricesUsed[token];
    
    delete betsNumber[address(0)];
    delete betsNumber[token];
    
    ongoingRound = ongoingRound.add(1);
    roundStartedAt = block.timestamp;
    
    emit RoundFinished();
  }


  function withdrawPrize(address _token) external {

    uint256 prize = getPrizeToWithdraw(_token);
    require(prize > 0, "No prize");

    if (_token == address(0)) {
      msg.sender.transfer(prize);
    } else {
      require(IERC20(_token).transfer(msg.sender, prize), "Transfer failed");
    }

    delete prizeToWithdraw[_token][msg.sender];
    prizeWithdrawn[_token][msg.sender] = prizeWithdrawn[_token][msg.sender].add(prize);
  }
  
  function getPrizeToWithdraw(address _token) public view returns(uint256) {

    require(_token == address(0) || _token == token, "Wrong token");
    
    return prizeToWithdraw[_token][msg.sender];
  }
  
  function getPrizeWithdrawn(address _token) external view returns(uint256) {

    require(_token == address(0) || _token == token, "Wrong token");

    return prizeWithdrawn[_token][msg.sender];
  }

  function withdrawDevFee(address _token) external {

    uint256 fee = getDevFee(_token);
    require(fee > 0, "No fee");
    delete devFee[_token];

    if (_token == address(0)) {
      msg.sender.transfer(fee);
    } else {
      require(IERC20(_token).transfer(msg.sender, fee), "Transfer failed");
    }
  }

  function getDevFee(address _token) public view returns(uint256) {

    require(hasRole(OWNER_ROLE, msg.sender), "Not OWNER_ROLE");
    require(_token == address(0) || _token == token, "Wrong token");
    
    return devFee[_token];
  }

  function getPricesUsed(address _token) external view returns (uint64[] memory) {

    require(_token == address(0) || _token == token, "Wrong token");

    return pricesUsed[_token];
  }

  function getPriceAndWinningPricesForRound(address _token, uint256 _round) external view returns(uint64[4] memory) {

    require(_token == address(0) || _token == token, "Wrong token");
    require(_round < ongoingRound, "Wrong round");

    return priceAndWinningPricesForRound[_token][_round];
  }
  
  function getBetsForRoundForPrice(address _token, uint256 _round, uint64 _price) view external returns(address[] memory, uint256[] memory, uint64[] memory) {

    require(_token == address(0) || _token == token, "Wrong token");
    require((_price > 0) && (_price < PRICE_MAX), "Wrong price");
    
    Bet[] storage bets = betsForRound[_token][_round][_price];
    uint256 betsLength = bets.length;
      
    address[] memory accounts = new address[](betsLength);
    uint256[] memory timestamps = new uint256[](betsLength);
    uint64[] memory prices = new uint64[](betsLength);
      
    for (uint256 i = 0; i < betsLength; i ++) {
      accounts[i] = bets[i].account;
      timestamps[i] = bets[i].timestamp;
      prices[i] = bets[i].price;
    }
      
    return (accounts, timestamps, prices);
  }
  
  function getLastRoundWithBetMade(address _token) view external returns (uint256) {

      require(_token == address(0) || _token == token, "Wrong token");
      
      return lastRoundWithBetMade[_token][msg.sender];
  }
  
  function getBetHistoryCountFor(address _token) view external returns (uint256) {

    return betHistory[_token][msg.sender].length;   
  }
  
  function getBetHistoryFor(address _token, uint256 _idxStart, uint256 _idxEnd) view external returns (bool[] memory, uint256[] memory, uint64[] memory) {

    HistoryBet[] storage bets = betHistory[_token][msg.sender];
    uint256 betsLength = bets.length;
    
    if (betsLength == 0) {
        return(new bool[](0), new uint256[](0), new uint64[](0));
    }
    
    uint256 start = 0;
    uint256 end = betsLength.sub(1);
    
    if (_idxEnd > 0) {
        require(_idxStart < _idxEnd && _idxEnd < betsLength, "Wrong idxs");
        
        start = _idxStart;
        end = _idxEnd;
    }
    
    uint256 arrLength = end.sub(start).add(1);
      
    bool[] memory isEth = new bool[](arrLength);
    uint256[] memory timestamps = new uint256[](arrLength);
    uint64[] memory prices = new uint64[](arrLength);
          
    for (uint256 i = start; i <= end; i ++) {
      isEth[i] = bets[i].isEth;
      timestamps[i] = bets[i].timestamp;
      prices[i] = bets[i].price;
    }
          
    return (isEth, timestamps, prices);   
  }


  function updateBet(bool _isToken, uint256 _value) external {

    require(hasRole(OWNER_ROLE, msg.sender), "Not OWNER_ROLE");
    require(_value > 0, "Wrong bet value");

    (_isToken) ? betTokens = _value : betEth = _value;
  }

  function updateRoundDuration(uint256 _duration) external {

    require(hasRole(OWNER_ROLE, msg.sender), "Not OWNER_ROLE");
    require(_duration > 0, "Wrong duration");

    roundDuration = _duration;
  }

  function setPaused(bool _isPaused) external {

    require(hasRole(OWNER_ROLE, msg.sender), "Not OWNER_ROLE");

    paused = _isPaused;
  }

  function kill() external {

    require(hasRole(OWNER_ROLE, msg.sender), "Not OWNER_ROLE");
    selfdestruct(payable(msg.sender));
  }
}