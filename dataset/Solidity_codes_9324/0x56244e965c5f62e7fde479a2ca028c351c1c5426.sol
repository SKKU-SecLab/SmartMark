
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT
pragma solidity 0.8.12;


interface ICollectionV3 { 


    function initialize(   
        string memory uri,
        uint256 _total,
        uint256 _whitelistedStartTime,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _amount,
        uint256 _percent,
        address _admin,
        address _facAddress
    )external;


    function __CollectionV3_init_unchained(
        string memory uri,
        uint256 _total,
        uint256 _whitelistedStartTime,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _amount,
        uint256 _percent,
        address _admin,
        address _facAddress
    ) external;


    function addExternalAddresses(address _token,address _stone,address _treasure) external ;


    function recoverToken(address _token) external;

  
    function changeOnlyWhitelisted(bool _status) external ;


    function buy(address buyer, uint256 _id) external;


    function mint(address to, uint256 _id) external;


    function mintBatch( address to, uint256[] memory ids, uint256[] memory amount_) external ;


    function addPayees(address[] memory payees_, uint256[] memory sharePerc_) external;


    function _addPayee(address account, uint256 sharePerc_) external;


    function release() external;


    function getAmountPer(uint256 sharePerc) external view returns (uint256);


    function calcPerc(uint256 _amount, uint256 _percent) external pure returns (uint256);


    function calcTrasAndShare() external view returns (uint256, uint256);


    function setStarTime(uint256 _starTime) external;  


    function setEndTime(uint256 _endTime)external;


    function setWhiteListUser(address _addr) external;


    function setBatchWhiteListUser(address[] calldata _addr) external;


    function setAmount(uint256 _amount) external;


    function delShare(address account) external;


    function totalReleased() external view returns (uint256);


    function released(address account) external view returns (uint256);


    function shares(address account) external view returns (uint256);


    function allShares() external view returns (address[] memory);

}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity 0.8.12;

interface AggregatorInterface {

  function latestAnswer() external view returns (int256 answer);

}// MIT
pragma solidity 0.8.12;


contract MysteryDrop is ReentrancyGuard {

    using EnumerableSet for EnumerableSet.UintSet;
    using Counters for Counters.Counter;


    event CollectionsTiersSet(Tiers tier, address collection, uint256[] ids);
    event MysteryBoxDropped(
        Tiers tier,
        address collection,
        uint256 id,
        address user
    );
    event MysteryBoxCC(Tiers tier, address user, string purchaseId);


    modifier onlyAdmin() {

        require(msg.sender == admin, "Only Admin");
        _;
    }

    modifier onlyAuthorized() {

        require(authorizedAddresses[msg.sender], "Not Authorized");
        _;
    }

    modifier isStarted() {

        require(startTime <= block.timestamp && endTime > block.timestamp, "Drop has not started yet!");
        _;
    }

   


    enum Tiers {
        TierOne,
        TierTwo,
        TierThree
    }

    EnumerableSet.UintSet private firstDeckIndexes;
    EnumerableSet.UintSet private secondDeckIndexes;
    EnumerableSet.UintSet private thirdDeckIndexes;

    Counters.Counter public firstDeckIndexCounter;
    Counters.Counter public secondDeckIndexCounter;
    Counters.Counter public thirdDeckIndexCounter;

    bytes[] public firstDeck;
    bytes[] public secondDeck;
    bytes[] public thirdDeck;

    address admin;
    uint256 public startTime;
    uint256 public endTime;
    mapping(Tiers => uint256) public tierPrices;
    mapping(address => uint256) private cardNumbers;
    mapping(address => bool) private authorizedAddresses;
    IERC20 ern;
    AggregatorInterface ernOracleAddr;

    uint32 public firstDeckLimit = 0;
    uint32 public secondDeckLimit = 0;
    uint32 public thirdDeckLimit = 0;


    constructor(IERC20 _ern, AggregatorInterface _ernOracle) {
        ern = _ern;
        ernOracleAddr = _ernOracle;
        admin = msg.sender;
        startTime = 0;
        endTime = 0;
    }



    function getPrice() public view returns (uint256) {

        return uint256(ernOracleAddr.latestAnswer());
    }

    function computeErnAmount(uint256 _subscriptionPrice, uint256 _ernPrice)
        public
        pure
        returns (uint256)
    {

        uint256 result = (_subscriptionPrice * 10**18) / _ernPrice;
        return result;
    }

    function _getRandom(uint256 gamerange, uint256 seed)
        internal
        view
        virtual
        returns (uint256)
    {

        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp +
                            block.difficulty +
                            uint256(
                                keccak256(abi.encodePacked(block.coinbase))
                            ) +
                            seed
                    )
                )
            ) % gamerange;
    }

    function getAvailable(Tiers _tier) public view returns (uint256) {

        if (_tier == Tiers.TierOne) {
            return firstDeckIndexes.length();
        } else if (_tier == Tiers.TierTwo) {
            return secondDeckIndexes.length();
        } else if (_tier == Tiers.TierThree) {
            return thirdDeckIndexes.length();
        }
        return 0;
    }



    function setCollection(
        Tiers _tier,
        address _collection,
        uint256[] calldata _ids
    ) external onlyAdmin {

        uint256 length = _ids.length;
        for (uint16 i = 0; i < length; ) {
            _setCollection(_tier, _collection, _ids[i]);
            unchecked {
                ++i;
            }
        }
        emit CollectionsTiersSet(_tier, _collection, _ids);
    }

    function setCollectionsBatch(
        Tiers _tier,
        address[] calldata _collections,
        uint256[] calldata _ids
    ) external onlyAdmin {

        uint256 last;
        for (uint256 j = 0; j < _collections.length; j++) {
            for (
                uint256 i = last;
                i < last + cardNumbers[_collections[j]];
                i++
            ) {
                _setCollection(_tier, _collections[j], _ids[i]);
            }
            last += cardNumbers[_collections[j]];
        }
    }

    function resetTierDeck(Tiers _tier) external onlyAdmin {

        if (_tier == Tiers.TierOne) {
            firstDeck = new bytes[](0);
            firstDeckIndexCounter._value = 0;
            for (
                uint256 i = 0;
                i < firstDeckIndexes._inner._values.length;
                i++
            ) {
                firstDeckIndexes._inner._indexes[
                    firstDeckIndexes._inner._values[i]
                ] = 0;
            }
            firstDeckIndexes._inner._values = new bytes32[](0);
        } else if (_tier == Tiers.TierTwo) {
            secondDeck = new bytes[](0);
            secondDeckIndexCounter._value = 0;
            for (
                uint256 i = 0;
                i < secondDeckIndexes._inner._values.length;
                i++
            ) {
                secondDeckIndexes._inner._indexes[
                    secondDeckIndexes._inner._values[i]
                ] = 0;
            }
            secondDeckIndexes._inner._values = new bytes32[](0);
        } else if (_tier == Tiers.TierThree) {
            thirdDeck = new bytes[](0);
            thirdDeckIndexCounter._value = 0;
            for (
                uint256 i = 0;
                i < thirdDeckIndexes._inner._values.length;
                i++
            ) {
                thirdDeckIndexes._inner._indexes[
                    thirdDeckIndexes._inner._values[i]
                ] = 0;
            }
            thirdDeckIndexes._inner._values = new bytes32[](0);
        } else revert("wrong parameter!");
    }

    function tierPricesSet(Tiers[] memory _tiers, uint256[] memory _prices)
        external
        onlyAdmin
    {

        for (uint8 i = 0; i < _tiers.length; i++) {
            tierPrices[_tiers[i]] = _prices[i];
        }
    }

    function setCardNumbers(
        address[] calldata _collections,
        uint256[] calldata numberofIds
    ) external onlyAdmin {

        for (uint256 i = 0; i < _collections.length; i++) {
            cardNumbers[_collections[i]] = numberofIds[i];
        }
    }
    function setAuthorizedAddr(address _addr) external onlyAdmin{

        authorizedAddresses[_addr] = true;
    }

    function removeAuthorizedAddr(address _addr) external onlyAdmin{

        authorizedAddresses[_addr] = false;
    }
    

   function buyCreditMysteryBox(address _user, Tiers _tier, string calldata _purchaseId) external onlyAuthorized {

        _buy(_user, _tier);
        emit MysteryBoxCC(_tier, _user, _purchaseId);
    }


    function buyMysteryBox(Tiers _tier) external isStarted nonReentrant {

        uint256 _ernAmount = _buy(msg.sender, _tier);
        ern.transferFrom(msg.sender, address(this), _ernAmount);
    }

    function setTimestamps(uint256 _start, uint256 _end) external onlyAdmin {

        startTime = _start;
        endTime = _end;
    }

    function withdrawFundsPartially(uint256 _amount, address _to)
        external
        onlyAdmin
    {

        require(
            ern.balanceOf(address(this)) >= _amount,
            "Amount exceeded ern balance"
        );
        ern.transfer(_to, _amount);
    }

    function withdrawAllFunds(address _to) external onlyAdmin {

        uint256 _balance = ern.balanceOf(address(this));
        ern.transfer(_to, _balance);
    }

    function setDeckMaxLimit(uint32 first, uint32 second, uint32 third) external onlyAdmin {

        firstDeckLimit = first;
        secondDeckLimit = second;
        thirdDeckLimit = third;
    }

    function setAdmin(address _admin) external onlyAdmin {

       require(_admin != address(0), "Not allowed to renounce admin");
       admin = _admin;
    }



    function _buy(address _user, Tiers _tier) internal returns (uint256) {

        uint256 _ernPrice = getPrice();
        uint256 ernAmount;
        uint256 random;
        uint256 index;
        address _contract;
        uint256 _id;
        if (_tier == Tiers.TierOne) {
            require(
                firstDeckIndexes.length() > 0,
                "There is no card left in Tier 1!"
            );
            ernAmount = computeErnAmount(tierPrices[Tiers.TierOne], _ernPrice);
            random = _getRandom(firstDeckIndexes.length(), _ernPrice);
            index = firstDeckIndexes.at(random);
            firstDeckIndexes.remove(index);
            (_contract, _id) = abi.decode(firstDeck[index], (address, uint256));
        } else if (_tier == Tiers.TierTwo) {
            require(
                secondDeckIndexes.length() > 0,
                "There is no card left in Tier 2!"
            );
            ernAmount = computeErnAmount(tierPrices[Tiers.TierTwo], _ernPrice);
            random = _getRandom(secondDeckIndexes.length(), _ernPrice);
            index = secondDeckIndexes.at(random);
            secondDeckIndexes.remove(index);
            (_contract, _id) = abi.decode(
                secondDeck[index],
                (address, uint256)
            );
        } else if (_tier == Tiers.TierThree) {
            require(
                thirdDeckIndexes.length() > 0,
                "There is no card left in Tier 3!"
            );
            ernAmount = computeErnAmount(
                tierPrices[Tiers.TierThree],
                _ernPrice
            );
            random = _getRandom(thirdDeckIndexes.length(), _ernPrice);
            index = thirdDeckIndexes.at(random);
            thirdDeckIndexes.remove(index);
            (_contract, _id) = abi.decode(thirdDeck[index], (address, uint256));
        } else {
            revert("Wrong Tier Parameter!");
        }

        ICollectionV3(_contract).mint(_user, _id);
        emit MysteryBoxDropped(_tier, _contract, _id, _user);
        return ernAmount;
    }

    function _setCollection(
        Tiers _tier,
        address _collection,
        uint256 _id
    ) internal {

        if (_tier == Tiers.TierOne) {
            require(firstDeck.length <= firstDeckLimit, "More than Tier Limit!");
            firstDeck.push(abi.encode(_collection, _id));
            firstDeckIndexes.add(firstDeckIndexCounter.current());
            firstDeckIndexCounter.increment();
        } else if (_tier == Tiers.TierTwo) {
            require(secondDeck.length <= secondDeckLimit, "More than Tier Limit!");
            secondDeck.push(abi.encode(_collection, _id));
            secondDeckIndexes.add(secondDeckIndexCounter.current());
            secondDeckIndexCounter.increment();
        } else if (_tier == Tiers.TierThree) {
            require(thirdDeck.length <= thirdDeckLimit, "More than Tier Limit!");
            thirdDeck.push(abi.encode(_collection, _id));
            thirdDeckIndexes.add(thirdDeckIndexCounter.current());
            thirdDeckIndexCounter.increment();
        } else {
            revert("Wrong Tier Parameter!");
        }
    }
}