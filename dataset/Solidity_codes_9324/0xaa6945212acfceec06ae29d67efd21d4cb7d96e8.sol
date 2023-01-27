
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity ^0.6.0;

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
}// MIT

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
}// MIT
pragma solidity ^0.6.0;

interface IDepositaryBalanceView {

    function decimals() external view returns(uint256);


    function balance() external view returns(uint256);

}// MIT
pragma solidity ^0.6.0;

interface IUpdatable {

    function lastUpdateBlockNumber() external view returns (uint256);

}// MIT
pragma solidity ^0.6.0;


contract AccessControl is Ownable {

    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private allowed;

    event AccessAllowed(address member);

    event AccessDenied(address member);

    function allowAccess(address member) external onlyOwner {

        require(!allowed.contains(member), "AccessControl::allowAccess: member already allowed");

        allowed.add(member);
        emit AccessAllowed(member);
    }

    function denyAccess(address member) external onlyOwner {

        require(allowed.contains(member), "AccessControl::denyAccess: member already denied");

        allowed.remove(member);
        emit AccessDenied(member);
    }

    function accessList() external view returns (address[] memory) {

        address[] memory result = new address[](allowed.length());

        for (uint256 i = 0; i < allowed.length(); i++) {
            result[i] = allowed.at(i);
        }

        return result;
    }

    modifier onlyAllowed() {

        require(allowed.contains(_msgSender()) || _msgSender() == owner(), "AccessControl: caller is not allowed");
        _;
    }
}// MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


contract RealAssetDepositaryBalanceView is IDepositaryBalanceView, IUpdatable, AccessControl {

    using SafeMath for uint256;

    struct Proof {
        string data;
        string signature;
    }

    struct Asset {
        string id;
        uint256 amount;
        uint256 price;
        uint256 updatedBlockAt;
    }

    uint256 public maxSize;

    uint256 public override decimals = 6;

    Asset[] public portfolio;

    mapping(string => uint256) internal portfolioIndex;

    event AssetUpdated(string id, uint256 updatedAt, Proof proof);

    event AssetRemoved(string id);

    constructor(uint256 _decimals, uint256 _maxSize) public {
        decimals = _decimals;
        maxSize = _maxSize;
    }

    function size() public view returns (uint256) {

        return portfolio.length;
    }

    function assets() external view returns (Asset[] memory) {

        Asset[] memory result = new Asset[](size());

        for (uint256 i = 0; i < size(); i++) {
            result[i] = portfolio[i];
        }

        return result;
    }

    function lastUpdateBlockNumber() external view override returns (uint256) {

        uint256 result;

        for (uint256 i = 0; i < size(); i++) {
            result = portfolio[i].updatedBlockAt > result ? portfolio[i].updatedBlockAt : result;
        }

        return result;
    }

    function put(
        string calldata id,
        uint256 amount,
        uint256 price,
        uint256 updatedAt,
        string calldata proofData,
        string calldata proofSignature
    ) external onlyAllowed {

        require(size() < maxSize, "RealAssetDepositaryBalanceView::put: too many assets");

        uint256 valueIndex = portfolioIndex[id];
        if (valueIndex != 0) {
            portfolio[valueIndex.sub(1)] = Asset(id, amount, price, block.number);
        } else {
            portfolio.push(Asset(id, amount, price, block.number));
            portfolioIndex[id] = size();
        }
        emit AssetUpdated(id, updatedAt, Proof(proofData, proofSignature));
    }

    function remove(string calldata id) external onlyAllowed {

        uint256 valueIndex = portfolioIndex[id];
        require(valueIndex != 0, "RealAssetDepositaryBalanceView::remove: asset already removed");

        uint256 toDeleteIndex = valueIndex.sub(1);
        uint256 lastIndex = size().sub(1);
        Asset memory lastValue = portfolio[lastIndex];
        portfolio[toDeleteIndex] = lastValue;
        portfolioIndex[lastValue.id] = toDeleteIndex.add(1);
        portfolio.pop();
        delete portfolioIndex[id];

        emit AssetRemoved(id);
    }

    function balance() external view override returns (uint256) {

        uint256 result;

        for (uint256 i = 0; i < size(); i++) {
            result = result.add(portfolio[i].amount.mul(portfolio[i].price));
        }

        return result;
    }
}