
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity 0.8.9;

interface IStepVesting {

    function receiver() external returns (address);

    function claim() external;

}// MIT

pragma solidity 0.8.9;

pragma abicoder v1;


contract VestedToken is Ownable {

    using EnumerableSet for EnumerableSet.AddressSet;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event VestingRegistered(address indexed vesting, address indexed receiver);
    event VestingDeregistered(address indexed vesting, address indexed receiver);

    IERC20 public immutable inchToken;
    mapping (address => EnumerableSet.AddressSet) private _vestingsByReceiver;
    EnumerableSet.AddressSet private _receivers;
    mapping(address => uint256) private _vestingBalances;

    constructor(IERC20 _inchToken) {
        inchToken = _inchToken;
    }

    function name() external pure returns(string memory) {

        return "1INCH Token (Vested)";
    }

    function symbol() external pure returns(string memory) {

        return "v1INCH";
    }

    function decimals() external pure returns(uint8) {

        return 18;
    }

    function totalSupply() external view returns (uint256) {

        uint256 len = _receivers.length();
        uint256 _totalSupply;
        for (uint256 i = 0; i < len; i++) {
            _totalSupply += balanceOf(_receivers.at(i));
        }
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        EnumerableSet.AddressSet storage vestings = _vestingsByReceiver[account];
        uint256 len = vestings.length();
        uint256 balance;
        for (uint256 i = 0; i < len; i++) {
            balance += inchToken.balanceOf(vestings.at(i));
        }
        return balance;
    }

    function registerVestings(address[] calldata vestings) external onlyOwner {

        uint256 len = vestings.length;
        for (uint256 i = 0; i < len; i++) {
            address vesting = vestings[i];
            address receiver = IStepVesting(vesting).receiver();
            require(_vestingsByReceiver[receiver].add(vesting), "Vesting is already registered");
            _receivers.add(receiver);
            emit VestingRegistered(vesting, receiver);
            uint256 actualBalance = inchToken.balanceOf(vesting);
            require(actualBalance > 0, "Vesting is empty");
            _vestingBalances[vesting] = actualBalance;
            emit Transfer(address(0), receiver, actualBalance);
        }
    }

    function deregisterVestings(address[] calldata vestings) external onlyOwner {

        uint256 len = vestings.length;
        for (uint256 i = 0; i < len; i++) {
            address vesting = vestings[i];
            address receiver = IStepVesting(vesting).receiver();
            EnumerableSet.AddressSet storage receiverVestings = _vestingsByReceiver[receiver];
            require(receiverVestings.remove(vesting), "Vesting is not registered");
            if (receiverVestings.length() == 0) {
                require(_receivers.remove(receiver), "Receiver is already removed");
            }
            emit VestingDeregistered(vesting, receiver);
            uint256 storedBalance = _vestingBalances[vesting];
            if (storedBalance > 0) {
                emit Transfer(receiver, address(0), storedBalance);
                _vestingBalances[vesting] = 0;
            }
        }
    }

    function updateAllBalances() external {

        address[] memory receivers = _receivers.values();
        uint256 len = receivers.length;
        for(uint256 i = 0; i < len; i++) {
            updateBalances(_vestingsByReceiver[receivers[i]].values());
        }
    }

    function updateBalances(address[] memory vestings) public {

        uint256 len = vestings.length;
        for (uint256 i = 0; i < len; i++) {
            address vesting = vestings[i];
            address receiver = IStepVesting(vesting).receiver();
            uint256 actualBalance = inchToken.balanceOf(vesting);
            uint256 storedBalance = _vestingBalances[vesting];
            if (actualBalance < storedBalance) {
                _vestingBalances[vesting] = actualBalance;
                unchecked {
                    emit Transfer(receiver, address(0), storedBalance - actualBalance);
                }
            }
        }
    }
}