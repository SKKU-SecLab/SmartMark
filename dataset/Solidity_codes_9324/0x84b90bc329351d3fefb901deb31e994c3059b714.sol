
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract OwnableClone is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function init ( address initialOwner ) internal {
        require(_owner == address(0), "Contract is already initialized");
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    constructor () {
        address msgSender = _msgSender();
        init(msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "OwnableClone: caller is not the owner");
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

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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


abstract contract RevenueSplit {

    struct RevenueShare {
        address payable receiver;
        uint256 share;
    }

    uint256 public totalShares;
    RevenueShare[] public receiverInfos;

    function receiverExists(address receiver) internal view returns (bool) {
        for (uint256 idx = 0; idx < receiverInfos.length; idx++) {
            if (receiverInfos[idx].receiver == receiver) {
                return true;
            }
        }

        return false;
    }

    function authorizeRevenueChange(address receiver, bool add) virtual internal;

    function addRevenueSplit(address payable receiver, uint256 share) public {
        authorizeRevenueChange(receiver, true);
        require(!receiverExists(receiver), "Receiver Already Registered");
        receiverInfos.push();
        uint256 newIndex = receiverInfos.length - 1;

        receiverInfos[newIndex].receiver = receiver;
        receiverInfos[newIndex].share = share;
        totalShares += share;
    }

    function removeRevenueSplit(address receiver) public {
        authorizeRevenueChange(receiver, false);
        require(receiverExists(receiver), "Receiver not Registered");

        for (uint256 idx = 0; idx < receiverInfos.length; idx++) {
            if (receiverInfos[idx].receiver == receiver) {
                totalShares -= receiverInfos[idx].share;

                if (idx < receiverInfos.length - 1) {
                    receiverInfos[idx] = receiverInfos[receiverInfos.length - 1];
                }
                break;
            }
        }

        receiverInfos.pop();
    }

    function processRevenue(uint256 totalAmount, address payable defaultRecipient) internal {
        if (totalShares == 0) {
            Address.sendValue(defaultRecipient, totalAmount);
            return;
        }

        uint256 remainingAmount = totalAmount;
        RevenueShare[] memory payments = new RevenueShare[](receiverInfos.length);

        for( uint256 idx = 0; idx < receiverInfos.length; idx ++) {
            uint256 thisShare = SafeMath.div(SafeMath.mul(totalAmount, receiverInfos[idx].share), totalShares);
            require(thisShare <= remainingAmount, "Error splitting revenue");
            remainingAmount = remainingAmount - thisShare;
            payments[idx].receiver = receiverInfos[idx].receiver;
            payments[idx].share = thisShare;
        }

        uint256 nextIdx = 0;
        while (remainingAmount > 0) {
            payments[nextIdx % payments.length].share = payments[nextIdx % payments.length].share + 1;
            remainingAmount = remainingAmount - 1;
            nextIdx = nextIdx + 1;
        }

        for( uint256 idx = 0; idx < payments.length; idx ++) {
            Address.sendValue(payments[idx].receiver, payments[idx].share);
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract SalesHistory {


    struct HistoryEntry {
        address tokenAddress;
        uint256 offeringId;
        address buyer;
        address recipient;
        uint256 price;
        uint256 timestamp;
    }

    HistoryEntry[] allSales;

    function getSales(uint256 start, uint256 length) public view returns (HistoryEntry[] memory sales) {

        require(start < allSales.length);
        uint256 remaining = allSales.length - start;
        uint256 actualLength = remaining < length ? remaining : length;
        sales = new HistoryEntry[](actualLength);

        for (uint256 idx = 0; idx < actualLength; idx++) {
            sales[idx] = allSales[idx+start];
        }

        return sales;
    }

    function postSale(address tokenAddress, uint256 offeringId, address buyer, address recipient, uint256 price, uint256 timestamp) internal {

        allSales.push();
        uint256 idx = allSales.length - 1;
        allSales[idx].tokenAddress = tokenAddress;
        allSales[idx].offeringId = offeringId;
        allSales[idx].buyer = buyer;
        allSales[idx].recipient = recipient;
        allSales[idx].price = price;
        allSales[idx].timestamp = timestamp;
    }
}// MIT

pragma solidity ^0.8.0;

interface ISaleable {

    function processSale( uint256 offeringId, address buyer ) external;

    function getSellersFor( uint256 offeringId ) external view returns ( address [] memory sellers);

 
    event SaleProcessed(address indexed seller, uint256 indexed offeringId, address buyer);
    event SellerAdded(address indexed seller, uint256 indexed offeringId);
    event SellerRemoved(address indexed seller, uint256 indexed offeringId);
}// MIT

pragma solidity ^0.8.0;




contract ExternalAuthSales is OwnableClone, RevenueSplit, SalesHistory {

    using EnumerableSet for EnumerableSet.UintSet;

    struct Listing {
        address tokenAddress;
        uint256 offeringId;
        mapping (address => bool) authorizers;
        mapping(uint64 => bool) consumedNonces;
    }

    mapping(uint256 => Listing) public listingsById;
    uint256 internal nextListingId;
    EnumerableSet.UintSet currentListingIds;

    string public name;

    event ListingPurchased( address indexed authorizer, uint256 indexed listingId, address buyer, address recipient );
    event ListingAdded(uint256 indexed listingId, address tokenAddress, uint256 offeringId);
    event ListingAuthorizerAdded(uint256 indexed listingId, address authorizer);
    event ListingAuthorizerRemoved(uint256 indexed listingId, address authorizer);
    event ListingRemoved(uint256 indexed listingId);

 	constructor(string memory _name, address _owner) {
        _init(_name, _owner);
    }

    function _init(string memory _name, address _owner) internal {

        name = _name;
        nextListingId = 0;
        transferOwnership(_owner);
    }

    function init(string memory _name, address _owner) public {

        require(owner() == address(0), "already initialized");
        OwnableClone.init(msg.sender);
        _init(_name, _owner);
    }

    function purchase(uint256 listingId, address _recipient, uint64 expiration, uint256 price, uint64 nonce, bytes memory signature) public payable {

        require(currentListingIds.contains(listingId), "No such listing");
        require(expiration >= block.timestamp, "Bearer token expired");
        require(price == msg.value, "Price does not match payment");

        bytes memory packedBearerToken = abi.encode(address(this), listingId, expiration, price, nonce);
        bytes32 bearerTokenHash = keccak256(packedBearerToken);
        bytes32 signedMessageHash = ECDSA.toEthSignedMessageHash(bearerTokenHash);
        address signer = ECDSA.recover(signedMessageHash, signature);

        Listing storage listing = listingsById[listingId];

        require(listing.authorizers[signer], string(abi.encodePacked("Signer is not authorized to sell this listing: ", Strings.toHexString(uint160(signer)))));
        
        ISaleable(listing.tokenAddress).processSale(listing.offeringId, _recipient);

        processRevenue(msg.value, payable(owner()));

        postSale(listing.tokenAddress, listing.offeringId, msg.sender, _recipient, price, block.timestamp);
        emit ListingPurchased(signer, listingId, msg.sender, _recipient);
	}

    function addListing(address tokenAddress, uint256 offeringId) public onlyOwner {

        uint256 idx = nextListingId++;
        listingsById[idx].tokenAddress = tokenAddress;
        listingsById[idx].offeringId = offeringId;

        currentListingIds.add(idx);
        emit ListingAdded(idx, tokenAddress, offeringId);
    }

    function removeListing(uint256 listingId) public onlyOwner {

        require(currentListingIds.contains(listingId), "No such listing");
        delete(listingsById[listingId]);
        
        currentListingIds.remove(listingId);
        emit ListingRemoved(listingId);
    }

    function addAuthorizer(uint256 listingId, address authorizer) public onlyOwner {

        require(currentListingIds.contains(listingId), "No such listing");
        Listing storage listing = listingsById[listingId];

        require(!listing.authorizers[authorizer], "Authorizer already added");
        listing.authorizers[authorizer] = true;

        emit ListingAuthorizerAdded(listingId, authorizer);
    }

    function removeAuthorizer(uint256 listingId, address authorizer) public onlyOwner {

        require(currentListingIds.contains(listingId), "No such listing");
        Listing storage listing = listingsById[listingId];

        require(listing.authorizers[authorizer], "Authorizer not added");
        delete(listing.authorizers[authorizer]);

        emit ListingAuthorizerRemoved(listingId, authorizer);
    }

    function clearNonces(uint256 listingId, uint64[] memory nonces) public onlyOwner {

        require(currentListingIds.contains(listingId), "No such listing");
        Listing storage listing = listingsById[listingId];
        for (uint idx = 0; idx < nonces.length; idx++) {
            delete(listing.consumedNonces[nonces[idx]]);
        }
    }

    function authorizeRevenueChange(address, bool) virtual internal override {

        require(msg.sender == owner(), "only owner can change revenue split");
    }

}