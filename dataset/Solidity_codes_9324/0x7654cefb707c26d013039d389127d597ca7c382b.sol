
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableClone is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function init(address initialOwner) internal {
    require(_owner == address(0), 'Contract is already initialized');
    _owner = initialOwner;
    emit OwnershipTransferred(address(0), initialOwner);
  }

  constructor() {
    address msgSender = _msgSender();
    init(msgSender);
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), 'caller is not the owner');
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), 'new owner is null address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}// MIT

pragma solidity ^0.8.0;

interface ISaleable {

  function processSale(uint256 offeringId, address buyer, uint256 price) external;


  function getSellersFor(uint256 offeringId) external view returns (address[] memory sellers);


  event SellerAdded(address indexed seller, uint256 indexed offeringId);
  event SellerRemoved(address indexed seller, uint256 indexed offeringId);
}// MIT
pragma solidity ^0.8.0;

library BinaryDecoder {

    function increment(uint bufferIdx, uint offset, uint amount) internal pure returns (uint, uint) {

      offset+=amount;
      return (bufferIdx + (offset / 32), offset % 32);
    }

    function decodeUint8(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint8, uint, uint) {

      uint8 result = 0;
      result |= uint8(buffers[bufferIdx][offset]);
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      return (result, bufferIdx, offset);
    }

    function decodeUint16(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint16, uint, uint) {

      uint result = 0;
      if (offset % 32 < 31) {
        return decodeUint16Aligned(buffers, bufferIdx, offset);
      }

      result |= uint(uint8(buffers[bufferIdx][offset])) << 8;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset]));
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      return (uint16(result), bufferIdx, offset);
    }

    function decodeUint16Aligned(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint16, uint, uint) {

      uint result = 0;
      result |= uint(uint8(buffers[bufferIdx][offset])) << 8;
      result |= uint(uint8(buffers[bufferIdx][offset + 1]));
      (bufferIdx, offset) = increment(bufferIdx, offset, 2);
      return (uint16(result), bufferIdx, offset);
    }

    function decodeUint32(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint32, uint, uint) {

      if (offset % 32 < 29) {
        return decodeUint32Aligned(buffers, bufferIdx, offset);
      }

      uint result = 0;
      result |= uint(uint8(buffers[bufferIdx][offset])) << 24;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 16;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 8;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset]));
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      return (uint32(result), bufferIdx, offset);
    }

    function decodeUint32Aligned(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint32, uint, uint) {

      uint result = 0;
      result |= uint(uint8(buffers[bufferIdx][offset])) << 24;
      result |= uint(uint8(buffers[bufferIdx][offset + 1])) << 16;
      result |= uint(uint8(buffers[bufferIdx][offset + 2])) << 8;
      result |= uint(uint8(buffers[bufferIdx][offset + 3]));
      (bufferIdx, offset) = increment(bufferIdx, offset, 4);
      return (uint32(result), bufferIdx, offset);
    }

    function decodeUint64(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint64, uint, uint) {

      if (offset % 32 < 25) {
        return decodeUint64Aligned(buffers, bufferIdx, offset);
      }

      uint result = 0;
      result |= uint(uint8(buffers[bufferIdx][offset])) << 56;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 48;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 40;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 32;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 24;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 16;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset])) << 8;
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      result |= uint(uint8(buffers[bufferIdx][offset]));
      (bufferIdx, offset) = increment(bufferIdx, offset, 1);
      return (uint64(result), bufferIdx, offset);
    }

    function decodeUint64Aligned(bytes32[0xFFFF] storage buffers, uint bufferIdx, uint offset) internal view returns (uint64, uint, uint) {

      uint result = 0;
      result |= uint(uint8(buffers[bufferIdx][offset])) << 56;
      result |= uint(uint8(buffers[bufferIdx][offset + 1])) << 48;
      result |= uint(uint8(buffers[bufferIdx][offset + 2])) << 40;
      result |= uint(uint8(buffers[bufferIdx][offset + 3])) << 32;
      result |= uint(uint8(buffers[bufferIdx][offset + 4])) << 24;
      result |= uint(uint8(buffers[bufferIdx][offset + 5])) << 16;
      result |= uint(uint8(buffers[bufferIdx][offset + 6])) << 8;
      result |= uint(uint8(buffers[bufferIdx][offset + 7]));
      (bufferIdx, offset) = increment(bufferIdx, offset, 8);
      return (uint64(result), bufferIdx, offset);
    }
}// MIT

pragma solidity ^0.8.0;




contract VFAuctions is AccessControl {

  struct Listing {
    uint16    template;
    uint16    consigner;
    uint16    offeringId;
  }

  struct ListingTemplate {
    uint64    openTime;
    uint16    startOffsetMin;
    uint16    endOffsetMin;
    uint16    startPriceTenFinnies;
    uint16    priceReductionTenFinnies;
  }

  address[] internal consigners;
  bytes32[0xFFFF] internal listings;
  bytes32[0xFFFF] internal templates;
  uint256 internal numListings;
  mapping (uint256 => bool) internal listingPurchased;
  address payable public benefactor;

  string public name;

  event ListingPurchased(uint256 indexed listingId, uint16 index, address buyer, uint256 price);

  constructor(string memory _name) {
    name = _name;
    benefactor = payable(msg.sender);
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  uint256 constant private TEN_FINNY_TO_WEI = 10000000000000000;

  function calculateCurrentPrice(ListingTemplate memory template) internal view returns (uint256) {

    uint256 currentTime = block.timestamp;
    uint256 delta = uint256(template.priceReductionTenFinnies) * TEN_FINNY_TO_WEI;
    uint256 startPrice = uint256(template.startPriceTenFinnies) * TEN_FINNY_TO_WEI;
    uint64 startTime = template.openTime + (uint64(template.startOffsetMin) * 60);
    uint64 endTime = template.openTime + (uint64(template.endOffsetMin) * 60);

    if (currentTime >= endTime) {
      return startPrice - delta;
    } else if (currentTime <= startTime) {
      return startPrice;
    }


    uint256 reduction =
      SafeMath.div(SafeMath.mul(delta, currentTime - startTime ), endTime - startTime);
    return startPrice - reduction;
  }

  function calculateCurrentPrice(uint256 listingId) public view returns (uint256) {

    require(numListings >= listingId, 'No such listing');
    Listing memory listing = decodeListing(uint16(listingId));
    ListingTemplate memory template = decodeTemplate(listing.template);
    return calculateCurrentPrice(template);
  }

  function bid(
    uint256 listingId
  ) public payable {

    require(listingPurchased[listingId] == false, 'listing sold out');
    require(numListings >= listingId, 'No such listing');
    Listing memory listing = decodeListing(uint16(listingId));
    ListingTemplate memory template = decodeTemplate(listing.template);

    uint256 currentPrice = calculateCurrentPrice(template);
    require(msg.value >= currentPrice, 'Wrong price');
    ISaleable(consigners[listing.consigner]).processSale(listing.offeringId, msg.sender, currentPrice);
    listingPurchased[listingId] = true;

    emit ListingPurchased(listingId, listing.offeringId, msg.sender, currentPrice);

    if (currentPrice < msg.value) {
      Address.sendValue(payable(msg.sender), msg.value - currentPrice);
    }
  }

  function addConsigners( address[] memory newConsigners ) public onlyRole(DEFAULT_ADMIN_ROLE) {

    for (uint idx = 0; idx < newConsigners.length; idx++) {
      consigners.push(newConsigners[idx]);
    }
  }

  function addListings( bytes32[] calldata newListings, uint offset, uint length) public onlyRole(DEFAULT_ADMIN_ROLE) {

    uint idx = 0;
    while(idx < newListings.length) {
      listings[offset + idx] = newListings[idx];
      idx++;
    }
    numListings = length;
  }

  function addListingTemplates( bytes32[] calldata newTemplates, uint offset) public onlyRole(DEFAULT_ADMIN_ROLE) {

    uint idx = 0;
    while(idx < newTemplates.length) {
      templates[offset + idx] = newTemplates[idx];
      idx++;
    }
  }

  struct OutputListing {
    uint16   listingId;
    address  consigner;
    uint16[] soldOfferingIds;
    uint16[] availableOfferingIds;
    uint256  startPrice;
    uint256  endPrice;
    uint64   startTime;
    uint64   endTime;
    uint64   openTime;
  }

  function getListingsLength() public view returns (uint) {

    return numListings;
  }

  function getListings(uint16 start, uint16 length) public view returns (OutputListing[] memory) {

    require(start < numListings, 'out of range');
    uint256 remaining = numListings - start;
    uint256 actualLength = remaining < length ? remaining : length;
    OutputListing[] memory result = new OutputListing[](actualLength);

    for (uint16 idx = 0; idx < actualLength; idx++) {
      uint16 listingId = start + idx;
      Listing memory listing = decodeListing(listingId);
      ListingTemplate memory template = decodeTemplate(listing.template);
      bool isPurchased = listingPurchased[listingId];

      result[idx].listingId   = listingId;
      result[idx].consigner   = consigners[listing.consigner];

      if (isPurchased) {
        result[idx].soldOfferingIds = new uint16[](1);
        result[idx].availableOfferingIds = new uint16[](0);
        result[idx].soldOfferingIds[0] = listing.offeringId;
      } else {
        result[idx].soldOfferingIds = new uint16[](0);
        result[idx].availableOfferingIds = new uint16[](1);
        result[idx].availableOfferingIds[0] = listing.offeringId;
      }

      uint256 reduction = uint256(template.priceReductionTenFinnies) * TEN_FINNY_TO_WEI;
      uint256 startPrice = uint256(template.startPriceTenFinnies)  * TEN_FINNY_TO_WEI;
      uint64 startTime = template.openTime + (uint64(template.startOffsetMin) * 60);
      uint64 endTime = template.openTime + (uint64(template.endOffsetMin) * 60);

      result[idx].startPrice  = startPrice;
      result[idx].endPrice    = startPrice - reduction;
      result[idx].startTime   = startTime;
      result[idx].endTime     = endTime;
      result[idx].openTime   = template.openTime;
    }

    return result;
  }

  function getBufferIndexAndOffset(uint index, uint stride) internal pure returns (uint, uint) {

    uint offset = index * stride;
    return (offset / 32, offset % 32);
  }

  function decodeListing(uint16 idx) internal view returns (Listing memory) {

    (uint bufferIndex, uint offset) = getBufferIndexAndOffset(idx, 6);
    Listing memory result;

    (result.template,bufferIndex,offset) = BinaryDecoder.decodeUint16Aligned(listings, bufferIndex, offset);
    (result.consigner,bufferIndex,offset) = BinaryDecoder.decodeUint16Aligned(listings, bufferIndex, offset);
    (result.offeringId,bufferIndex,offset) = BinaryDecoder.decodeUint16Aligned(listings, bufferIndex, offset);

    return result;
  }

  function decodeTemplate(uint16 idx) internal view returns (ListingTemplate memory) {

    (uint bufferIndex, uint offset) = getBufferIndexAndOffset(idx, 16);
    ListingTemplate memory result;

    (result.openTime,bufferIndex,offset) = BinaryDecoder.decodeUint64Aligned(templates, bufferIndex, offset);
    (result.startOffsetMin,bufferIndex,offset) = BinaryDecoder.decodeUint16Aligned(templates, bufferIndex, offset);
    (result.endOffsetMin,bufferIndex,offset) = BinaryDecoder.decodeUint16Aligned(templates, bufferIndex, offset);
    (result.startPriceTenFinnies,bufferIndex,offset) = BinaryDecoder.decodeUint16Aligned(templates, bufferIndex, offset);
    (result.priceReductionTenFinnies,bufferIndex,offset) = BinaryDecoder.decodeUint16Aligned(templates, bufferIndex, offset);

    return result;
  }

  function withdraw() public {

    require(msg.sender == benefactor || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), 'not authorized');
    uint amount = address(this).balance;
    require(amount > 0, 'no balance');

    Address.sendValue(benefactor, amount);
  }

  function setBenefactor(address payable newBenefactor, bool sendBalance) public onlyRole(DEFAULT_ADMIN_ROLE) {

    require(benefactor != newBenefactor, 'already set');
    uint amount = address(this).balance;
    address payable oldBenefactor = benefactor;
    benefactor = newBenefactor;

    if (sendBalance && amount > 0) {
      Address.sendValue(oldBenefactor, amount);
    }
  }
}