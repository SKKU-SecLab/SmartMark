pragma solidity ^0.7.0;

interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity ^0.7.0;

interface IQueryEngine {

    function getPrice(address contractAddress, bytes memory data) external view returns (bytes memory);

    function queryAllPrices(bytes memory script, uint256[] memory inputLocations) external view returns (bytes memory);

    function query(bytes memory script, uint256[] memory inputLocations) external view returns (uint256);

}// MIT
pragma solidity ^0.7.0;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction underflow");
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

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

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

pragma solidity >=0.6.2 <0.8.0;

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
pragma solidity ^0.7.0;


library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


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
}// Unlicense
pragma solidity ^0.7.0;

library BytesLib {

    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {

        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {

        assembly {
            let fslot := sload(_preBytes.slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                sstore(
                    _preBytes.slot,
                    add(
                        fslot,
                        add(
                            mul(
                                div(
                                    mload(add(_postBytes, 0x20)),
                                    exp(0x100, sub(32, mlength))
                                ),
                                exp(0x100, sub(32, newlength))
                            ),
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes.slot, add(mul(newlength, 2), 1))


                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes.slot, add(mul(newlength, 2), 1))

                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
        internal
        pure
        returns (bytes memory)
    {

        require(_bytes.length >= (_start + _length), "Read out of bounds");

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

        require(_bytes.length >= (_start + 20), "Read out of bounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {

        require(_bytes.length >= (_start + 1), "Read out of bounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {

        require(_bytes.length >= (_start + 2), "Read out of bounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {

        require(_bytes.length >= (_start + 4), "Read out of bounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {

        require(_bytes.length >= (_start + 8), "Read out of bounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {

        require(_bytes.length >= (_start + 12), "Read out of bounds");
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {

        require(_bytes.length >= (_start + 16), "Read out of bounds");
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {

        require(_bytes.length >= (_start + 32), "Read out of bounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {

        require(_bytes.length >= (_start + 32), "Read out of bounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {

        bool success = true;

        assembly {
            let length := mload(_preBytes)

            switch eq(length, mload(_postBytes))
            case 1 {
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    if iszero(eq(mload(mc), mload(cc))) {
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {

        bool success = true;

        assembly {
            let fslot := sload(_preBytes.slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            switch eq(slength, mlength)
            case 1 {
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            success := 0
                        }
                    }
                    default {
                        let cb := 1

                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }
}// MIT
pragma solidity ^0.7.0;


abstract contract CalldataEditor {
    using BytesLib for bytes;

    function uint256At(bytes memory data, uint256 location) pure internal returns (uint256 result) {
        assembly {
            result := mload(add(data, add(0x20, location)))
        }
    }

    function addressAt(bytes memory data, uint256 location) pure internal returns (address result) {
        uint256 word = uint256At(data, location);
        assembly {
            result := div(and(word, 0xffffffffffffffffffffffffffffffffffffffff000000000000000000000000),
                          0x1000000000000000000000000)
        }
    }

    function locationOf(bytes memory data, uint256 location) pure internal returns (uint256 result) {
        assembly {
            result := add(data, add(0x20, location))
        }
    }
    
    function replaceDataAt(bytes memory original, bytes memory newBytes, uint256 location) pure internal {
        assembly {
            mstore(add(add(original, location), 0x20), mload(add(newBytes, 0x20)))
        }
    }

    function getRevertMsg(bytes memory res) internal pure returns (string memory) {
        if (res.length < 68) return 'Call failed for unknown reason';
        bytes memory revertData = res.slice(4, res.length - 4); // Remove the selector which is the first 4 bytes
        return abi.decode(revertData, (string)); // All that remains is the revert string
    }
}// MIT

pragma solidity ^0.7.0;

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
pragma solidity ^0.7.0;



abstract contract Trader is ReentrancyGuard, AccessControl, CalldataEditor {
    using BytesLib for bytes;

    IQueryEngine public queryEngine;

    bytes32 public constant TRADER_ROLE = keccak256("TRADER_ROLE");

    modifier onlyTrader() {
        require(hasRole(TRADER_ROLE, msg.sender), "Trader must have TRADER role");
        _;
    }

    modifier mustBeProfitable(uint256 ethRequested) {
        uint256 contractBalanceBefore = address(this).balance;
        require(contractBalanceBefore >= ethRequested, "Not enough ETH in contract");
        _;
        require(address(this).balance >= contractBalanceBefore, "missing ETH");
    }

    modifier notExpired(uint256 deadlineBlock) {
        require(deadlineBlock >= block.number, "trade expired");
        _;
    }

    modifier onTime(uint256 minTimestamp, uint256 maxTimestamp) {
        require(maxTimestamp >= block.timestamp, "trade too late");
        require(minTimestamp <= block.timestamp, "trade too early");
        _;
    }

    function isTrader(address addressToCheck) external view returns (bool) {
        return hasRole(TRADER_ROLE, addressToCheck);
    }

    function makeTrade(
        bytes memory executeScript,
        uint256 ethValue
    ) public onlyTrader nonReentrant mustBeProfitable(ethValue) {
        execute(executeScript, ethValue);
    }

    function makeTrade(
        bytes memory executeScript,
        uint256 ethValue,
        uint256 blockDeadline
    ) public onlyTrader nonReentrant notExpired(blockDeadline) mustBeProfitable(ethValue) {
        execute(executeScript, ethValue);
    }

    function makeTrade(
        bytes memory executeScript,
        uint256 ethValue,
        uint256 minTimestamp,
        uint256 maxTimestamp
    ) public onlyTrader nonReentrant onTime(minTimestamp, maxTimestamp) mustBeProfitable(ethValue) {
        execute(executeScript, ethValue);
    }

    function makeTrade(
        bytes memory queryScript,
        uint256[] memory queryInputLocations,
        bytes memory executeScript,
        uint256[] memory executeInputLocations,
        uint256 targetPrice,
        uint256 ethValue
    ) public onlyTrader nonReentrant mustBeProfitable(ethValue) {
        bytes memory prices = queryEngine.queryAllPrices(queryScript, queryInputLocations);
        require(prices.toUint256(prices.length - 32) >= targetPrice, "Not profitable");
        for(uint i = 0; i < executeInputLocations.length; i++) {
            replaceDataAt(executeScript, prices.slice(i*32, 32), executeInputLocations[i]);
        }
        execute(executeScript, ethValue);
    }

    function makeTrade(
        bytes memory queryScript,
        uint256[] memory queryInputLocations,
        bytes memory executeScript,
        uint256[] memory executeInputLocations,
        uint256 targetPrice,
        uint256 ethValue,
        uint256 blockDeadline
    ) public onlyTrader nonReentrant notExpired(blockDeadline) mustBeProfitable(ethValue) {
        bytes memory prices = queryEngine.queryAllPrices(queryScript, queryInputLocations);
        require(prices.toUint256(prices.length - 32) >= targetPrice, "Not profitable");
        for(uint i = 0; i < executeInputLocations.length; i++) {
            replaceDataAt(executeScript, prices.slice(i*32, 32), executeInputLocations[i]);
        }
        execute(executeScript, ethValue);
    }

    function makeTrade(
        bytes memory queryScript,
        uint256[] memory queryInputLocations,
        bytes memory executeScript,
        uint256[] memory executeInputLocations,
        uint256 targetPrice,
        uint256 ethValue,
        uint256 minTimestamp,
        uint256 maxTimestamp
    ) public onlyTrader nonReentrant onTime(minTimestamp, maxTimestamp) mustBeProfitable(ethValue) {
        bytes memory prices = queryEngine.queryAllPrices(queryScript, queryInputLocations);
        require(prices.toUint256(prices.length - 32) >= targetPrice, "Not profitable");
        for(uint i = 0; i < executeInputLocations.length; i++) {
            replaceDataAt(executeScript, prices.slice(i*32, 32), executeInputLocations[i]);
        }
        execute(executeScript, ethValue);
    }

    function execute(bytes memory script, uint256 ethValue) internal {
        uint256 location = 0;
        while (location < script.length) {
            address contractAddress = addressAt(script, location);
            uint256 calldataLength = uint256At(script, location + 0x14);
            uint256 calldataStart = location + 0x14 + 0x20;
            bytes memory callData = script.slice(calldataStart, calldataLength);
            if(location == 0) {
                callMethod(contractAddress, callData, ethValue);
            }
            else {
                callMethod(contractAddress, callData, 0);
            }
            location += (0x14 + 0x20 + calldataLength);
        }
    }

    function callMethod(address contractToCall, bytes memory data, uint256 ethValue) internal {
        bool success;
        bytes memory returnData;
        address payable contractAddress = payable(contractToCall);
        if(ethValue > 0) {
            (success, returnData) = contractAddress.call{value: ethValue}(data);
        } else {
            (success, returnData) = contractAddress.call(data);
        }
        if (!success) {
            string memory revertMsg = getRevertMsg(returnData);
            revert(revertMsg);
        }
    }
}// MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;



contract Dispatcher is AccessControl, Trader {

    using SafeMath for uint256;

    using BytesLib for bytes;

    using SafeERC20 for IERC20;

    uint8 public version;

    bytes32 public constant MANAGE_LP_ROLE = keccak256("MANAGE_LP_ROLE");

    bytes32 public constant WHITELISTED_LP_ROLE = keccak256("WHITELISTED_LP_ROLE");

    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");  

    bytes32 public constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");    

    uint256 public MAX_LIQUIDITY;

    uint256 public totalLiquidity;

    mapping(address => uint256) public lpBalances;

    modifier onlyLPManager() {

        require(hasRole(MANAGE_LP_ROLE, msg.sender), "Caller must have MANAGE_LP role");
        _;
    }

    modifier onlyApprover() {

        require(hasRole(APPROVER_ROLE, msg.sender), "Caller must have APPROVER role");
        _;
    }

    modifier onlyWithdrawer() {

        require(hasRole(WITHDRAW_ROLE, msg.sender), "Caller must have WITHDRAW role");
        _;
    }

    modifier onlyWhitelistedLP() {

        if(getRoleMemberCount(WHITELISTED_LP_ROLE) > 0) {
            require(hasRole(WHITELISTED_LP_ROLE, msg.sender), "Caller must have WHITELISTED_LP role");
        }
        _;
    }

    event MaxLiquidityUpdated(address indexed asset, uint256 indexed newAmount, uint256 oldAmount);

    event LiquidityProvided(address indexed asset, address indexed provider, uint256 amount);

    event LiquidityRemoved(address indexed asset, address indexed provider, uint256 amount);

    constructor(
        uint8 _version,
        address _queryEngine,
        address _roleManager,
        address _lpManager,
        address _withdrawer,
        address _trader,
        address _supplier,
        uint256 _initialMaxLiquidity,
        address[] memory _lpWhitelist
    ) {
        version = _version;
        queryEngine = IQueryEngine(_queryEngine);
        _setupRole(MANAGE_LP_ROLE, _lpManager);
        _setRoleAdmin(WHITELISTED_LP_ROLE, MANAGE_LP_ROLE);
        _setupRole(WITHDRAW_ROLE, _withdrawer);
        _setupRole(TRADER_ROLE, _trader);
        _setupRole(APPROVER_ROLE, _supplier);
        _setupRole(APPROVER_ROLE, _withdrawer);
        _setupRole(DEFAULT_ADMIN_ROLE, _roleManager);
        MAX_LIQUIDITY = _initialMaxLiquidity;
        for(uint i; i < _lpWhitelist.length; i++) {
            _setupRole(WHITELISTED_LP_ROLE, _lpWhitelist[i]);
        }
    }

    receive() external payable {}
    
    fallback() external payable {}

    function isApprover(address addressToCheck) external view returns(bool) {

        return hasRole(APPROVER_ROLE, addressToCheck);
    }

    function isWithdrawer(address addressToCheck) external view returns(bool) {

        return hasRole(WITHDRAW_ROLE, addressToCheck);
    }

    function isLPManager(address addressToCheck) external view returns(bool) {

        return hasRole(MANAGE_LP_ROLE, addressToCheck);
    }

    function isWhitelistedLP(address addressToCheck) external view returns(bool) {

        return hasRole(WHITELISTED_LP_ROLE, addressToCheck);
    }

    function tokenAllowAll(
        address[] memory tokensToApprove, 
        address spender
    ) external onlyApprover {

        for(uint i = 0; i < tokensToApprove.length; i++) {
            IERC20 token = IERC20(tokensToApprove[i]);
            if (token.allowance(address(this), spender) != uint256(-1)) {
                token.safeApprove(spender, uint256(-1));
            }
        }
    }

    function tokenAllow(
        address[] memory tokensToApprove, 
        uint256[] memory approvalAmounts, 
        address spender
    ) external onlyApprover {

        require(tokensToApprove.length == approvalAmounts.length, "not same length");
        for(uint i = 0; i < tokensToApprove.length; i++) {
            IERC20 token = IERC20(tokensToApprove[i]);
            if (token.allowance(address(this), spender) != uint256(-1)) {
                token.safeApprove(spender, approvalAmounts[i]);
            }
        }
    }

    function rescueTokens(address[] calldata tokens, uint256 amount) external onlyWithdrawer {

        for (uint i = 0; i < tokens.length; i++) {
            IERC20 token = IERC20(tokens[i]);
            uint256 withdrawalAmount;
            uint256 tokenBalance = token.balanceOf(address(this));
            uint256 tokenAllowance = token.allowance(address(this), msg.sender);
            if (amount == 0) {
                if (tokenBalance > tokenAllowance) {
                    withdrawalAmount = tokenAllowance;
                } else {
                    withdrawalAmount = tokenBalance;
                }
            } else {
                require(tokenBalance >= amount, "Contract balance too low");
                require(tokenAllowance >= amount, "Increase token allowance");
                withdrawalAmount = amount;
            }
            token.safeTransferFrom(address(this), msg.sender, withdrawalAmount);
        }
    }

    function setMaxETHLiquidity(uint256 newMax) external onlyLPManager {

        emit MaxLiquidityUpdated(address(0), newMax, MAX_LIQUIDITY);
        MAX_LIQUIDITY = newMax;
    }

    function provideETHLiquidity() external payable onlyWhitelistedLP {

        require(totalLiquidity.add(msg.value) <= MAX_LIQUIDITY, "amount exceeds max liquidity");
        totalLiquidity = totalLiquidity.add(msg.value);
        lpBalances[msg.sender] = lpBalances[msg.sender].add(msg.value);
        emit LiquidityProvided(address(0), msg.sender, msg.value);
    }

    function removeETHLiquidity(uint256 amount) external {

        require(lpBalances[msg.sender] >= amount, "amount exceeds liquidity provided");
        require(totalLiquidity.sub(amount) >= 0, "amount exceeds total liquidity");
        require(address(this).balance.sub(amount) >= 0, "amount exceeds contract balance");
        lpBalances[msg.sender] = lpBalances[msg.sender].sub(amount);
        totalLiquidity = totalLiquidity.sub(amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Could not withdraw ETH");
        emit LiquidityRemoved(address(0), msg.sender, amount);
    }

    function withdrawEth(uint256 amount) external onlyWithdrawer {

        uint256 withdrawalAmount;
        uint256 withdrawableBalance = address(this).balance.sub(totalLiquidity);
        if (amount == 0) {
            withdrawalAmount = withdrawableBalance;
        } else {
            require(withdrawableBalance >= amount, "amount exceeds withdrawable balance");
            withdrawalAmount = amount;
        }
        (bool success, ) = msg.sender.call{value: withdrawalAmount}("");
        require(success, "Could not withdraw ETH");
    }

    function estimateQueryCost(bytes memory script, uint256[] memory inputLocations) public {

        queryEngine.queryAllPrices(script, inputLocations);
    }
}// MIT
pragma solidity ^0.7.0;


contract DispatcherFactory is AccessControl {

    using EnumerableSet for EnumerableSet.AddressSet;

    uint8 public version = 2;

    bytes32 public constant DISPATCHER_ADMIN_ROLE = keccak256("DISPATCHER_ADMIN_ROLE");

    EnumerableSet.AddressSet private dispatchersSet;

    event DispatcherCreated(
        address indexed dispatcher,
        uint8 indexed version, 
        address queryEngine,
        address roleManager,
        address lpManager,
        address withdrawer,
        address trader,
        address supplier,
        uint256 initialMaxLiquidity,
        bool lpWhitelist
    );

    event DispatcherAdded(address indexed dispatcher);

    event DispatcherRemoved(address indexed dispatcher);

    modifier onlyAdmin() {

        require(hasRole(DISPATCHER_ADMIN_ROLE, msg.sender), "Caller must have DISPATCHER_ADMIN role");
        _;
    }

    constructor(
        address _roleAdmin,
        address _dispatcherAdmin
    ) {
        _setupRole(DISPATCHER_ADMIN_ROLE, _dispatcherAdmin);
        _setupRole(DEFAULT_ADMIN_ROLE, _roleAdmin);
    }

    function createNewDispatcher(
        address queryEngine,
        address roleManager,
        address lpManager,
        address withdrawer,
        address trader,
        address supplier,
        uint256 initialMaxLiquidity,
        address[] memory lpWhitelist
    ) external onlyAdmin returns (
        address dispatcher
    ) {

        Dispatcher newDispatcher = new Dispatcher(
            version,
            queryEngine,
            roleManager,
            lpManager,
            withdrawer,
            trader,
            supplier,
            initialMaxLiquidity,
            lpWhitelist
        );

        dispatcher = address(newDispatcher);
        dispatchersSet.add(dispatcher);

        emit DispatcherCreated(
            dispatcher,
            version,
            queryEngine,
            roleManager,
            lpManager,
            withdrawer,
            trader,
            supplier,
            initialMaxLiquidity,
            lpWhitelist.length > 0 ? true : false
        );
    }

    function addDispatchers(address[] memory dispatcherContracts) external onlyAdmin {

        for(uint i = 0; i < dispatcherContracts.length; i++) {
            dispatchersSet.add(dispatcherContracts[i]);
            emit DispatcherAdded(dispatcherContracts[i]);
        }
    }

    function removeDispatchers(address[] memory dispatcherContracts) external onlyAdmin {

        for(uint i = 0; i < dispatcherContracts.length; i++) {
            dispatchersSet.remove(dispatcherContracts[i]);
            emit DispatcherRemoved(dispatcherContracts[i]);
        }
    }

    function dispatchers() external view returns (address[] memory) {

        uint256 dispatchersLength = dispatchersSet.length();
        address[] memory dispatchersArray = new address[](dispatchersLength);
        for(uint i = 0; i < dispatchersLength; i++) {
            dispatchersArray[i] = dispatchersSet.at(i);
        }
        return dispatchersArray;
    }

    function exists(address dispatcherContract) external view returns (bool) {

        return dispatchersSet.contains(dispatcherContract);
    }

    function numDispatchers() external view returns (uint256) {

        return dispatchersSet.length();
    }
}