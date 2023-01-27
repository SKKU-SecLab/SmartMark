pragma solidity ^0.6.0;

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
pragma solidity 0.6.6;

interface ITorro {



  function initializeCustom(address dao_, address factory_, uint256 supply_) external;



  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


  function decimals() external pure returns (uint8);


  function totalSupply() external view returns (uint256);


  function holdersCount() external view returns (uint256);


  function holders() external view returns (address[] memory);


  function balanceOf(address sender_) external view returns (uint256);


  function stakedOf(address sender_) external view returns (uint256);


  function totalOf(address sender_) external view returns (uint256);


  function allowance(address owner_, address spender_) external view returns (uint256);


  function unstakedSupply() external view returns (uint256);


  function stakedSupply() external view returns (uint256);



  function transfer(address recipient_, uint256 amount_) external returns (bool);


  function approve(address spender_, uint256 amount_) external returns (bool);


  function approveDao(address owner_, uint256 amount_) external returns (bool);


  function transferFrom(address owner_, address recipient_, uint256 amount_) external returns (bool);


  function increaseAllowance(address spender_, uint256 addedValue_) external returns (bool);


  function decreaseAllowance(address spender_, uint256 subtractedValue_) external returns (bool);


  function stake(uint256 amount_) external returns (bool);


  function unstake(uint256 amount_) external returns (bool);


  function addBenefits(uint256 amount_) external;


  function setDaoFactoryAddresses(address dao_, address factory_) external;


  function setPause(bool paused_) external;


  function setWhitelistAddress(address whitelistAddress_) external;


  function burn(uint256 amount_) external;

}
pragma solidity 0.6.6;

interface ITorroDao {



  enum DaoFunction { BUY, SELL, ADD_LIQUIDITY, REMOVE_LIQUIDITY, ADD_ADMIN, REMOVE_ADMIN, INVEST, WITHDRAW }

  
  function initializeCustom(
    address torroToken_,
    address governingToken_,
    address factory_,
    address creator_,
    uint256 maxCost_,
    uint256 executeMinPct_,
    uint256 votingMinHours_,
    bool isPublic_,
    bool hasAdmins_
  ) external;



  function daoCreator() external view returns (address);


  function voteWeight() external view returns (uint256);


  function votesOf(address sender_) external view returns (uint256);


  function tokenAddress() external view returns (address);


  function holdings() external view returns (address[] memory);


  function liquidities() external view returns (address[] memory);


  function liquidityToken(address token_) external view returns (address);


  function liquidityHoldings() external view returns (address[] memory, address[] memory);


  function admins() external view returns (address[] memory);


  function tokenBalance(address token_) external view returns (uint256);


  function liquidityBalance(address token_) external view returns (uint256);


  function availableBalance() external view returns (uint256);


  function maxCost() external view returns (uint256);


  function executeMinPct() external view returns (uint256);


  function votingMinHours() external view returns (uint256);


  function isPublic() external view returns (bool);


  function hasAdmins() external view returns (bool);


  function getProposalIds() external view returns (uint256[] memory);


  function getProposal(uint256 id_) external view returns (
    address proposalAddress,
    address investTokenAddress,
    DaoFunction daoFunction,
    uint256 amount,
    address creator,
    uint256 endLifetime,
    uint256 votesFor,
    uint256 votesAgainst,
    bool executed
  );


  function canVote(uint256 id_, address sender_) external view returns (bool);


  function canRemove(uint256 id_, address sender_) external view returns (bool);


  function canExecute(uint256 id_, address sender_) external view returns (bool);


  function isAdmin(address sender_) external view returns (bool);



  function addHoldingsAddresses(address[] calldata tokens_) external;


  function addLiquidityAddresses(address[] calldata tokens_) external;


  function propose(address proposalAddress_, address investTokenAddress_, DaoFunction daoFunction_, uint256 amount_, uint256 hoursLifetime_) external;


  function unpropose(uint256 id_) external;


  function vote(uint256[] calldata ids_, bool[] calldata votes_) external;


  function execute(uint256 id_) external;


  function buy() external payable;


  function sell(uint256 amount_) external;



  function setFactoryAddress(address factory_) external;


  function setVoteWeightDivider(uint256 weight_) external;


  function setRouter(address router_) external;


  function setSpendDivider(uint256 divider_) external;


  function migrate(address newDao_) external;


}// "UNLICENSED"
pragma solidity 0.6.6;

interface ITorroFactory {


  function mainToken() external view returns (address);


  function mainDao() external view returns (address);


  function isDao(address dao_) external view returns (bool);


  function claimBenefits(uint256 amount_) external;


  function addBenefits(address recipient_, uint256 amount_) external;

  
  function depositBenefits(address token_) external payable;

}
pragma solidity 0.6.6;


contract CloneFactory {


  function createClone(address target) internal returns (address result) {

    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
      mstore(add(clone, 0x14), targetBytes)
      mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
      result := create(0, clone, 0x37)
    }
  }

  function isClone(address target, address query) internal view returns (bool result) {

    bytes20 targetBytes = bytes20(target);
    assembly {
      let clone := mload(0x40)
      mstore(clone, 0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000)
      mstore(add(clone, 0xa), targetBytes)
      mstore(add(clone, 0x1e), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

      let other := add(clone, 0x40)
      extcodecopy(query, other, 0, 0x2d)
      result := and(
        eq(mload(clone), mload(other)),
        eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
      )
    }
  }
}
pragma solidity 0.6.6;



contract TorroFactory is ITorroFactory, CloneFactory {

  using EnumerableSet for EnumerableSet.AddressSet;

  uint256 private constant _customSupply = 1e22;
  address private _owner;
  address private _torroToken;
  address private _torroDao;
  mapping (address => uint256) private _benefits;
  mapping (address => address) private _pools;
  EnumerableSet.AddressSet private _poolTokens;
  uint256 _createPrice;
  uint256 _minMaxCost;
  
  event ClaimBenefits(address indexed owner);

	event PoolCreated(address indexed token, address indexed dao);

  constructor(address torroToken_, address torroDao_) public {
    _owner = msg.sender;
    _torroToken = torroToken_;
    _torroDao = torroDao_;
    _createPrice = 2 * 10**17;
    _minMaxCost = 1 ether;
  }

  modifier onlyOwner() {

    require(_owner == msg.sender);
    _;
  }

  function poolTokens() public view returns (address[] memory) {

    uint256 length = _poolTokens.length();
    address[] memory poolTokenAddresses = new address[](length);
    for (uint256 i = 0; i < length; i++) {
      poolTokenAddresses[i] = _poolTokens.at(i);
    }
    return poolTokenAddresses;
  }

  function poolDao(address token_) public view returns (address) {

    return _pools[token_];
  }

  function poolTokensForHolder(address holder_) public view returns (address[] memory) {

    uint256 length = _poolTokens.length();
    if (length == 0) {
      return new address[](0);
    }
    address[] memory poolTokenAddresses = new address[](length);
    uint256 pointer = 0;
    for (uint256 i = 0; i < length; i++) {
      address token = _poolTokens.at(i);
      if (token != address(0x0)) {
        address dao = _pools[token];
        if ((ITorro(token).totalOf(holder_) > 0) || ITorroDao(dao).isPublic() || ITorroDao(dao).daoCreator() == holder_) {
          poolTokenAddresses[pointer++] = token;
        }
      }
    }
    return poolTokenAddresses;
  }

  function mainToken() public view override returns (address) {

    return _torroToken;
  }

  function mainDao() public view override returns (address) {

    return _torroDao;
  }

  
  function isDao(address dao_) public view override returns (bool) {

    if (dao_ == _torroDao) {
      return true;
    }
    uint256 length = _poolTokens.length();
    for (uint256 i = 0; i < length; i++) {
      if (dao_ == _pools[_poolTokens.at(i)]) {
        return true;
      }
    }

    return false;
  }

  function price() public view returns (uint256) {

    return _createPrice;
  }

  function benefitsOf(address sender_) public view returns (uint256) {

    return _benefits[sender_];
  }

  function create(uint256 maxCost_, uint256 executeMinPct_, uint256 votingMinHours_, bool isPublic_, bool hasAdmins_) public payable {

    require(msg.value == _createPrice);
    require(maxCost_ >= _minMaxCost);
    
    address tokenProxy = createClone(_torroToken);
    address daoProxy = createClone(_torroDao);

    ITorroDao(daoProxy).initializeCustom(_torroToken, tokenProxy, address(this), msg.sender, maxCost_, executeMinPct_, votingMinHours_, isPublic_, hasAdmins_);
    ITorro(tokenProxy).initializeCustom(daoProxy, address(this), _customSupply);

    _poolTokens.add(tokenProxy);
    _pools[tokenProxy] = daoProxy;
    
    payable(_owner).transfer(msg.value);

    emit PoolCreated(tokenProxy, daoProxy);
  }

  function claimBenefits(uint256 amount_) public override {

    require(amount_ <= address(this).balance);
    uint256 amount = _benefits[msg.sender];
    require(amount_ >= amount);

    _benefits[msg.sender] = amount - amount_;
    
    payable(msg.sender).transfer(amount_);

    emit ClaimBenefits(msg.sender);
  }

  function addBenefits(address recipient_, uint256 amount_) public override {

    require(_torroToken == msg.sender || _poolTokens.contains(msg.sender));
    _benefits[recipient_] = _benefits[recipient_] + amount_;
  }

  function depositBenefits(address token_) public override payable {

    if (token_ == _torroToken) {
      require(msg.sender == _torroDao);
    } else {
      require(_poolTokens.contains(token_) && msg.sender == _pools[token_]);
    }
  }

  function migrate(address token_) public onlyOwner {

    ITorroDao currentDao = ITorroDao(_pools[token_]);
    address daoProxy = createClone(_torroDao);
    ITorroDao(daoProxy).initializeCustom(
      _torroToken,
      token_,
      address(this),
      currentDao.daoCreator(),
      currentDao.maxCost(),
      currentDao.executeMinPct(),
      currentDao.votingMinHours(),
      currentDao.isPublic(),
      currentDao.hasAdmins()
    );

    _pools[token_] = daoProxy;

    ITorro(token_).setDaoFactoryAddresses(daoProxy, address(this));
  }

  function setPrice(uint256 price_) public onlyOwner {

    _createPrice = price_;
  }

  function setMinMaxCost(uint256 cost_) public onlyOwner {

    _minMaxCost = cost_;
  }

  function transferOwnership(address newOwner_) public onlyOwner {

    _owner = newOwner_;
  }

  function setNewDao(address torroDao_) public onlyOwner {

    _torroDao = torroDao_;
  }
}