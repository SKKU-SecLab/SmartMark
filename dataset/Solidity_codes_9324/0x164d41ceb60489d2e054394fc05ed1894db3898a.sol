
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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
}// MIT

pragma solidity ^0.8.0;

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
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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
}// MIT

pragma solidity ^0.8.0;


library EnumerableMap {

    using EnumerableSet for EnumerableSet.Bytes32Set;


    struct Map {
        EnumerableSet.Bytes32Set _keys;

        mapping (bytes32 => bytes32) _values;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {

        map._values[key] = value;
        return map._keys.add(key);
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        delete map._values[key];
        return map._keys.remove(key);
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._keys.contains(key);
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._keys.length();
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        bytes32 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {

        bytes32 value = map._values[key];
        if (value == bytes32(0)) {
            return (_contains(map, key), bytes32(0));
        } else {
            return (true, value);
        }
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), "EnumerableMap: nonexistent key");
        return value;
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {

        bytes32 value = map._values[key];
        require(value != 0 || _contains(map, key), errorMessage);
        return value;
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {

        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint160(uint256(value))));
    }

    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {

        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity 0.8.3;

struct DPAConfig {
    uint256 ceiling;
    uint256 floor;
    uint256 collectionId;
    address paymentToken;
    address payee;
    uint256 endBlock;
    address[] tokens;
    uint256[] tokenAmounts;
}

struct DPA {
    uint256 id;
    uint256 ceiling;
    uint256 floor;
    uint256 absoluteDecay;
    uint256 collectionId;
    address paymentToken;
    address payee;
    uint256 startBlock;
    uint256 endBlock;
    bool stopped;
    address winner;
    uint256 winningBlock;
    uint256 winningPrice;
    address[] tokens;
    uint256[] tokenAmounts;
}

interface IDescendingPriceAuction {

    event AuctionCreated(
        uint256 indexed id,
        uint256 indexed collectionId,
        address indexed auctioneer
    );
    event CollectionCreated(uint256 id, address owner);
    event CollectionTransfer(uint256 id, address from, address to);
    event AuctionStopped(uint256 indexed id, uint256 price);
    event AuctionWon(
        uint256 indexed id,
        uint256 price,
        address paymentToken,
        address indexed winner
    );

    function getAuction(uint256 _id) external view returns (DPA memory);


    function totalAuctions() external view returns (uint256);


    function totalCollections() external view returns (uint256);


    function collectionLength(uint256 _id) external view returns (uint256);


    function neerGroupLength(address _neer) external view returns (uint256);


    function auctionOfNeerByIndex(address _neer, uint256 i)
        external
        view
        returns (uint256);


    function auctionOfCollByIndex(uint256 _id, uint256 i)
        external
        view
        returns (uint256);


    function createAuction(DPAConfig memory _auction)
        external
        returns (uint256);


    function stopAuction(uint256 _id) external;


    function bid(uint256 _id) external;


    function getCurrentPrice(uint256 _id) external view returns (uint256);


    function createCollection() external returns (uint256);


    function transferCollection(address _to, uint256 _id) external;

}// MIT

pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;


contract DescendingPriceAuction is IDescendingPriceAuction, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    mapping(uint256 => DPA) private auctions;
    EnumerableMap.UintToAddressMap private collections;
    EnumerableMap.UintToAddressMap private auctioneers;
    Counters.Counter private collectionCount;
    Counters.Counter private auctionCount;

    mapping(address => EnumerableSet.UintSet) private _byNeer;

    mapping(uint256 => EnumerableSet.UintSet) private _byColl;

    constructor() {
        auctionCount.increment();
        collectionCount.increment();
    }

    function _msgSender() internal view returns (address) {

        return msg.sender;
    }

    modifier onlyAuctioneer(uint256 _id) {

        (bool success, address neer) = auctioneers.tryGet(_id);
        require(success, "non-existent-auction");
        require(_msgSender() == neer, "caller-not-auctioneer");
        _;
    }

    modifier onlyCollectionOwner(uint256 _id) {

        if (_id != 0) {
            (bool success, address owner) = collections.tryGet(_id);
            require(success, "non-existent-collection");
            require(_msgSender() == owner, "caller-not-collection-owner");
        }
        _;
    }

    function getAuction(uint256 _id)
        external
        view
        override
        returns (DPA memory)
    {

        return auctions[_id];
    }

    function totalAuctions() external view override returns (uint256) {

        return auctioneers.length();
    }

    function totalCollections() external view override returns (uint256) {

        return collections.length();
    }

    function collectionLength(uint256 _id)
        external
        view
        override
        returns (uint256)
    {

        return _byColl[_id].length();
    }

    function neerGroupLength(address _neer)
        external
        view
        override
        returns (uint256)
    {

        return _byNeer[_neer].length();
    }

    function auctionOfNeerByIndex(address _neer, uint256 i)
        external
        view
        override
        returns (uint256)
    {

        return _byNeer[_neer].at(i);
    }

    function auctionOfCollByIndex(uint256 _id, uint256 i)
        external
        view
        override
        returns (uint256)
    {

        return _byColl[_id].at(i);
    }

    function _auctionExists(uint256 _auctionId)
        internal
        view
        virtual
        returns (bool)
    {

        return auctioneers.contains(_auctionId);
    }

    function createAuction(DPAConfig memory _auction)
        external
        override
        onlyCollectionOwner(_auction.collectionId)
        nonReentrant
        returns (uint256)
    {

        require(_auction.endBlock > block.number, "end-block-passed");
        require(_auction.ceiling != 0, "start-price-zero");
        require(_auction.ceiling >= _auction.floor, "invalid-pricing");
        require(_auction.paymentToken != address(0x0), "invalid-payment-token");
        require(_auction.payee != address(0x0), "invalid-payee");
        require(_auction.tokens.length != 0, "no-line-items");
        require(
            _auction.tokens.length == _auction.tokenAmounts.length,
            "improper-line-items"
        );
        require(_auction.tokens.length < 8, "too-many-line-items");
        return _createAuction(_auction);
    }

    function _createAuction(DPAConfig memory _auction)
        internal
        returns (uint256)
    {

        _pullTokens(_auction.tokens, _auction.tokenAmounts);
        uint256 id = auctionCount.current();
        uint256 decay =
            _calulateAbsoluteDecay(
                _auction.ceiling,
                _auction.floor,
                block.number,
                _auction.endBlock
            );
        auctions[id] = DPA({
            id: id,
            ceiling: _auction.ceiling,
            floor: _auction.floor,
            absoluteDecay: decay,
            collectionId: _auction.collectionId,
            paymentToken: _auction.paymentToken,
            payee: _auction.payee,
            startBlock: block.number,
            endBlock: _auction.endBlock,
            stopped: false,
            winner: address(0x0),
            winningBlock: 0,
            winningPrice: 0,
            tokens: _auction.tokens,
            tokenAmounts: _auction.tokenAmounts
        });
        address neer = _msgSender();
        auctioneers.set(id, neer);
        _byNeer[neer].add(id);
        _byColl[_auction.collectionId].add(id);
        auctionCount.increment();
        emit AuctionCreated(id, _auction.collectionId, neer);
        return id;
    }

    function _pullTokens(address[] memory tokens, uint256[] memory amounts)
        internal
    {

        for (uint256 i = 0; i < tokens.length; i++) {
            _pullToken(tokens[i], amounts[i]);
        }
    }

    function _pullToken(address _token, uint256 _amount) internal {

        require(_amount != 0, "invalid-token-amount");
        _safeTransferFromExact(_token, _msgSender(), address(this), _amount);
    }

    function _sendTokens(
        address recipient,
        address[] memory tokens,
        uint256[] memory amounts
    ) internal {

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).safeTransfer(recipient, amounts[i]);
        }
    }

    function stopAuction(uint256 _id)
        external
        override
        onlyAuctioneer(_id)
        nonReentrant
    {

        DPA storage auction = auctions[_id];
        require(
            auction.winner == address(0x0) && !auction.stopped,
            "cant-be-stopped"
        );
        _sendTokens(_msgSender(), auction.tokens, auction.tokenAmounts);
        auctions[_id].stopped = true;
        emit AuctionStopped(
            _id,
            _getCurrentPrice(
                auction.absoluteDecay,
                auction.floor,
                auction.endBlock,
                block.number
            )
        );
    }

    function bid(uint256 _id) external override nonReentrant {

        require(_auctionExists(_id), "no-such-auction-id");
        DPA storage auction = auctions[_id];
        require(auction.winner == address(0x0), "auction-has-ended");
        require(!auction.stopped, "auction-has-been-stopped");
        uint256 price =
            _getCurrentPrice(
                auction.absoluteDecay,
                auction.floor,
                auction.endBlock,
                block.number
            );
        address bidder = _msgSender();
        _safeTransferFromExact(
            auction.paymentToken,
            bidder,
            auction.payee,
            price
        );
        _sendTokens(bidder, auction.tokens, auction.tokenAmounts);
        auction.stopped = true;
        auction.winner = bidder;
        auction.winningBlock = block.number;
        auction.winningPrice = price;
        auctions[_id] = auction;
        emit AuctionWon(_id, price, auction.paymentToken, bidder);
    }

    function getCurrentPrice(uint256 _id)
        external
        view
        override
        returns (uint256)
    {

        require(_auctionExists(_id), "no-such-auction-id");
        DPA storage a = auctions[_id];
        return
            _getCurrentPrice(
                a.absoluteDecay,
                a.floor,
                a.endBlock,
                block.number
            );
    }

    function _getCurrentPrice(
        uint256 m,
        uint256 f,
        uint256 e,
        uint256 t
    ) internal pure returns (uint256 p) {

        if (t > e) return f;
        if (m == 0) return f;
        p = f + (m * (e - t)) / 1e18;
    }

    function _calulateAbsoluteDecay(
        uint256 c,
        uint256 f,
        uint256 s,
        uint256 e
    ) internal pure returns (uint256) {

        require(e > s, "invalid-ramp");
        require(c >= f, "price-not-descending-or-const");
        return ((c - f) * 1e18) / (e - s);
    }

    function _safeTransferFromExact(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal {

        IERC20 token = IERC20(_token);
        uint256 before = token.balanceOf(_to);
        token.safeTransferFrom(_from, _to, _amount);
        require(
            token.balanceOf(_to) - before == _amount,
            "not-enough-transferred"
        );
    }

    function createCollection()
        external
        override
        nonReentrant
        returns (uint256)
    {

        uint256 id = collectionCount.current();
        address owner = _msgSender();
        collections.set(id, owner);
        collectionCount.increment();
        emit CollectionCreated(id, owner);
        return id;
    }

    function transferCollection(address _to, uint256 _id)
        external
        override
        onlyCollectionOwner(_id)
        nonReentrant
    {

        collections.set(_id, _to);
        emit CollectionTransfer(_id, _msgSender(), _to);
    }
}