

pragma solidity >=0.6.10 <0.9.0;

interface ISkaleDKG {


    struct Fp2Point {
        uint a;
        uint b;
    }

    struct G2Point {
        Fp2Point x;
        Fp2Point y;
    }

    struct Channel {
        bool active;
        uint n;
        uint startedBlockTimestamp;
        uint startedBlock;
    }

    struct ProcessDKG {
        uint numberOfBroadcasted;
        uint numberOfCompleted;
        bool[] broadcasted;
        bool[] completed;
    }

    struct ComplaintData {
        uint nodeToComplaint;
        uint fromNodeToComplaint;
        uint startComplaintBlockTimestamp;
        bool isResponse;
        bytes32 keyShare;
        G2Point sumOfVerVec;
    }

    struct KeyShare {
        bytes32[2] publicKey;
        bytes32 share;
    }
    
    event ChannelOpened(bytes32 schainHash);

    event ChannelClosed(bytes32 schainHash);

    event BroadcastAndKeyShare(
        bytes32 indexed schainHash,
        uint indexed fromNode,
        G2Point[] verificationVector,
        KeyShare[] secretKeyContribution
    );

    event AllDataReceived(bytes32 indexed schainHash, uint nodeIndex);

    event SuccessfulDKG(bytes32 indexed schainHash);

    event BadGuy(uint nodeIndex);

    event FailedDKG(bytes32 indexed schainHash);

    event NewGuy(uint nodeIndex);

    event ComplaintError(string error);

    event ComplaintSent(bytes32 indexed schainHash, uint indexed fromNodeIndex, uint indexed toNodeIndex);
    
    function alright(bytes32 schainHash, uint fromNodeIndex) external;

    function broadcast(
        bytes32 schainHash,
        uint nodeIndex,
        G2Point[] memory verificationVector,
        KeyShare[] memory secretKeyContribution
    )
        external;

    function complaintBadData(bytes32 schainHash, uint fromNodeIndex, uint toNodeIndex) external;

    function preResponse(
        bytes32 schainId,
        uint fromNodeIndex,
        G2Point[] memory verificationVector,
        G2Point[] memory verificationVectorMultiplication,
        KeyShare[] memory secretKeyContribution
    )
        external;

    function complaint(bytes32 schainHash, uint fromNodeIndex, uint toNodeIndex) external;

    function response(
        bytes32 schainHash,
        uint fromNodeIndex,
        uint secretNumber,
        G2Point memory multipliedShare
    )
        external;

    function openChannel(bytes32 schainHash) external;

    function deleteChannel(bytes32 schainHash) external;

    function setStartAlrightTimestamp(bytes32 schainHash) external;

    function setBadNode(bytes32 schainHash, uint nodeIndex) external;

    function finalizeSlashing(bytes32 schainHash, uint badNode) external;

    function getChannelStartedTime(bytes32 schainHash) external view returns (uint);

    function getChannelStartedBlock(bytes32 schainHash) external view returns (uint);

    function getNumberOfBroadcasted(bytes32 schainHash) external view returns (uint);

    function getNumberOfCompleted(bytes32 schainHash) external view returns (uint);

    function getTimeOfLastSuccessfulDKG(bytes32 schainHash) external view returns (uint);

    function getComplaintData(bytes32 schainHash) external view returns (uint, uint);

    function getComplaintStartedTime(bytes32 schainHash) external view returns (uint);

    function getAlrightStartedTime(bytes32 schainHash) external view returns (uint);

    function isChannelOpened(bytes32 schainHash) external view returns (bool);

    function isLastDKGSuccessful(bytes32 groupIndex) external view returns (bool);

    function isBroadcastPossible(bytes32 schainHash, uint nodeIndex) external view returns (bool);

    function isComplaintPossible(
        bytes32 schainHash,
        uint fromNodeIndex,
        uint toNodeIndex
    )
        external
        view
        returns (bool);

    function isAlrightPossible(bytes32 schainHash, uint nodeIndex) external view returns (bool);

    function isPreResponsePossible(bytes32 schainHash, uint nodeIndex) external view returns (bool);

    function isResponsePossible(bytes32 schainHash, uint nodeIndex) external view returns (bool);

    function isNodeBroadcasted(bytes32 schainHash, uint nodeIndex) external view returns (bool);

    function isAllDataReceived(bytes32 schainHash, uint nodeIndex) external view returns (bool);

    function checkAndReturnIndexInGroup(
        bytes32 schainHash,
        uint nodeIndex,
        bool revertCheck
    )
        external
        view
        returns (uint, bool);

    function isEveryoneBroadcasted(bytes32 schainHash) external view returns (bool);

    function hashData(
        KeyShare[] memory secretKeyContribution,
        G2Point[] memory verificationVector
    )
        external
        pure
        returns (bytes32);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;


interface IKeyStorage {


    struct KeyShare {
        bytes32[2] publicKey;
        bytes32 share;
    }
    
    function deleteKey(bytes32 schainHash) external;

    function initPublicKeyInProgress(bytes32 schainHash) external;

    function adding(bytes32 schainHash, ISkaleDKG.G2Point memory value) external;

    function finalizePublicKey(bytes32 schainHash) external;

    function getCommonPublicKey(bytes32 schainHash) external view returns (ISkaleDKG.G2Point memory);

    function getPreviousPublicKey(bytes32 schainHash) external view returns (ISkaleDKG.G2Point memory);

    function getAllPreviousPublicKeys(bytes32 schainHash) external view returns (ISkaleDKG.G2Point[] memory);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface IContractManager {

    event ContractUpgraded(string contractsName, address contractsAddress);

    function initialize() external;

    function setContractsAddress(string calldata contractsName, address newContractsAddress) external;

    function contracts(bytes32 nameHash) external view returns (address);

    function getDelegationPeriodManager() external view returns (address);

    function getBounty() external view returns (address);

    function getValidatorService() external view returns (address);

    function getTimeHelpers() external view returns (address);

    function getConstantsHolder() external view returns (address);

    function getSkaleToken() external view returns (address);

    function getTokenState() external view returns (address);

    function getPunisher() external view returns (address);

    function getContract(string calldata name) external view returns (address);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface IPermissions {

    function initialize(address contractManagerAddress) external;

}// MIT

pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


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

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface IAccessControlUpgradeableLegacy {

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    
    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

}// AGPL-3.0-only

pragma solidity ^0.8.7;



contract InitializableWithGap is Initializable {

    uint256[50] private ______gap;
}// MIT
pragma solidity ^0.8.7;


abstract contract AccessControlUpgradeableLegacy is InitializableWithGap, ContextUpgradeable, IAccessControlUpgradeableLegacy {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {


    }

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

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

    uint256[49] private __gap;
}// AGPL-3.0-only


pragma solidity 0.8.11;




contract Permissions is AccessControlUpgradeableLegacy, IPermissions {

    using AddressUpgradeable for address;
    
    IContractManager public contractManager;

    modifier onlyOwner() {

        require(_isOwner(), "Caller is not the owner");
        _;
    }

    modifier onlyAdmin() {

        require(_isAdmin(msg.sender), "Caller is not an admin");
        _;
    }

    modifier allow(string memory contractName) {

        require(
            contractManager.getContract(contractName) == msg.sender || _isOwner(),
            "Message sender is invalid");
        _;
    }

    modifier allowTwo(string memory contractName1, string memory contractName2) {

        require(
            contractManager.getContract(contractName1) == msg.sender ||
            contractManager.getContract(contractName2) == msg.sender ||
            _isOwner(),
            "Message sender is invalid");
        _;
    }

    modifier allowThree(string memory contractName1, string memory contractName2, string memory contractName3) {

        require(
            contractManager.getContract(contractName1) == msg.sender ||
            contractManager.getContract(contractName2) == msg.sender ||
            contractManager.getContract(contractName3) == msg.sender ||
            _isOwner(),
            "Message sender is invalid");
        _;
    }

    function initialize(address contractManagerAddress) public virtual override initializer {

        AccessControlUpgradeableLegacy.__AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setContractManager(contractManagerAddress);
    }

    function _isOwner() internal view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _isAdmin(address account) internal view returns (bool) {

        address skaleManagerAddress = contractManager.contracts(keccak256(abi.encodePacked("SkaleManager")));
        if (skaleManagerAddress != address(0)) {
            AccessControlUpgradeableLegacy skaleManager = AccessControlUpgradeableLegacy(skaleManagerAddress);
            return skaleManager.hasRole(keccak256("ADMIN_ROLE"), account) || _isOwner();
        } else {
            return _isOwner();
        }
    }

    function _setContractManager(address contractManagerAddress) private {

        require(contractManagerAddress != address(0), "ContractManager address is not set");
        require(contractManagerAddress.isContract(), "Address is not contract");
        contractManager = IContractManager(contractManagerAddress);
    }
}// AGPL-3.0-only


pragma solidity 0.8.11;


library Precompiled {


    function bigModExp(uint base, uint power, uint modulus) internal view returns (uint) {

        uint[6] memory inputToBigModExp;
        inputToBigModExp[0] = 32;
        inputToBigModExp[1] = 32;
        inputToBigModExp[2] = 32;
        inputToBigModExp[3] = base;
        inputToBigModExp[4] = power;
        inputToBigModExp[5] = modulus;
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(not(0), 5, inputToBigModExp, mul(6, 0x20), out, 0x20)
        }
        require(success, "BigModExp failed");
        return out[0];
    }

    function bn256ScalarMul(uint x, uint y, uint k) internal view returns (uint , uint ) {

        uint[3] memory inputToMul;
        uint[2] memory output;
        inputToMul[0] = x;
        inputToMul[1] = y;
        inputToMul[2] = k;
        bool success;
        assembly {
            success := staticcall(not(0), 7, inputToMul, 0x60, output, 0x40)
        }
        require(success, "Multiplication failed");
        return (output[0], output[1]);
    }

    function bn256Pairing(
        uint x1,
        uint y1,
        uint a1,
        uint b1,
        uint c1,
        uint d1,
        uint x2,
        uint y2,
        uint a2,
        uint b2,
        uint c2,
        uint d2)
        internal view returns (bool)
    {

        bool success;
        uint[12] memory inputToPairing;
        inputToPairing[0] = x1;
        inputToPairing[1] = y1;
        inputToPairing[2] = a1;
        inputToPairing[3] = b1;
        inputToPairing[4] = c1;
        inputToPairing[5] = d1;
        inputToPairing[6] = x2;
        inputToPairing[7] = y2;
        inputToPairing[8] = a2;
        inputToPairing[9] = b2;
        inputToPairing[10] = c2;
        inputToPairing[11] = d2;
        uint[1] memory out;
        assembly {
            success := staticcall(not(0), 8, inputToPairing, mul(12, 0x20), out, 0x20)
        }
        require(success, "Pairing check failed");
        return out[0] != 0;
    }
}// AGPL-3.0-only



pragma solidity 0.8.11;




library Fp2Operations {


    uint constant public P = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    function inverseFp2(ISkaleDKG.Fp2Point memory value) internal view returns (ISkaleDKG.Fp2Point memory result) {

        uint p = P;
        uint t0 = mulmod(value.a, value.a, p);
        uint t1 = mulmod(value.b, value.b, p);
        uint t2 = mulmod(p - 1, t1, p);
        if (t0 >= t2) {
            t2 = addmod(t0, p - t2, p);
        } else {
            t2 = (p - addmod(t2, p - t0, p)) % p;
        }
        uint t3 = Precompiled.bigModExp(t2, p - 2, p);
        result.a = mulmod(value.a, t3, p);
        result.b = (p - mulmod(value.b, t3, p)) % p;
    }

    function addFp2(ISkaleDKG.Fp2Point memory value1, ISkaleDKG.Fp2Point memory value2)
        internal
        pure
        returns (ISkaleDKG.Fp2Point memory)
    {

        return ISkaleDKG.Fp2Point({ a: addmod(value1.a, value2.a, P), b: addmod(value1.b, value2.b, P) });
    }

    function scalarMulFp2(ISkaleDKG.Fp2Point memory value, uint scalar)
        internal
        pure
        returns (ISkaleDKG.Fp2Point memory)
    {

        return ISkaleDKG.Fp2Point({ a: mulmod(scalar, value.a, P), b: mulmod(scalar, value.b, P) });
    }

    function minusFp2(ISkaleDKG.Fp2Point memory diminished, ISkaleDKG.Fp2Point memory subtracted) internal pure
        returns (ISkaleDKG.Fp2Point memory difference)
    {

        uint p = P;
        if (diminished.a >= subtracted.a) {
            difference.a = addmod(diminished.a, p - subtracted.a, p);
        } else {
            difference.a = (p - addmod(subtracted.a, p - diminished.a, p)) % p;
        }
        if (diminished.b >= subtracted.b) {
            difference.b = addmod(diminished.b, p - subtracted.b, p);
        } else {
            difference.b = (p - addmod(subtracted.b, p - diminished.b, p)) % p;
        }
    }

    function mulFp2(
        ISkaleDKG.Fp2Point memory value1,
        ISkaleDKG.Fp2Point memory value2
    )
        internal
        pure
        returns (ISkaleDKG.Fp2Point memory result)
    {

        uint p = P;
        ISkaleDKG.Fp2Point memory point = ISkaleDKG.Fp2Point({
            a: mulmod(value1.a, value2.a, p),
            b: mulmod(value1.b, value2.b, p)});
        result.a = addmod(
            point.a,
            mulmod(p - 1, point.b, p),
            p);
        result.b = addmod(
            mulmod(
                addmod(value1.a, value1.b, p),
                addmod(value2.a, value2.b, p),
                p),
            p - addmod(point.a, point.b, p),
            p);
    }

    function squaredFp2(ISkaleDKG.Fp2Point memory value) internal pure returns (ISkaleDKG.Fp2Point memory) {

        uint p = P;
        uint ab = mulmod(value.a, value.b, p);
        uint multiplication = mulmod(addmod(value.a, value.b, p), addmod(value.a, mulmod(p - 1, value.b, p), p), p);
        return ISkaleDKG.Fp2Point({ a: multiplication, b: addmod(ab, ab, p) });
    }

    function isEqual(
        ISkaleDKG.Fp2Point memory value1,
        ISkaleDKG.Fp2Point memory value2
    )
        internal
        pure
        returns (bool)
    {

        return value1.a == value2.a && value1.b == value2.b;
    }
}

library G1Operations {

    using Fp2Operations for ISkaleDKG.Fp2Point;

    function getG1Generator() internal pure returns (ISkaleDKG.Fp2Point memory) {

        return ISkaleDKG.Fp2Point({
            a: 1,
            b: 2
        });
    }

    function isG1Point(uint x, uint y) internal pure returns (bool) {

        uint p = Fp2Operations.P;
        return mulmod(y, y, p) == 
            addmod(mulmod(mulmod(x, x, p), x, p), 3, p);
    }

    function isG1(ISkaleDKG.Fp2Point memory point) internal pure returns (bool) {

        return isG1Point(point.a, point.b);
    }

    function checkRange(ISkaleDKG.Fp2Point memory point) internal pure returns (bool) {

        return point.a < Fp2Operations.P && point.b < Fp2Operations.P;
    }

    function negate(uint y) internal pure returns (uint) {

        return (Fp2Operations.P - y) % Fp2Operations.P;
    }

}


library G2Operations {

    using Fp2Operations for ISkaleDKG.Fp2Point;

    function doubleG2(ISkaleDKG.G2Point memory value)
        internal
        view
        returns (ISkaleDKG.G2Point memory result)
    {

        if (isG2Zero(value)) {
            return value;
        } else {
            ISkaleDKG.Fp2Point memory s =
                value.x.squaredFp2().scalarMulFp2(3).mulFp2(value.y.scalarMulFp2(2).inverseFp2());
            result.x = s.squaredFp2().minusFp2(value.x.addFp2(value.x));
            result.y = value.y.addFp2(s.mulFp2(result.x.minusFp2(value.x)));
            uint p = Fp2Operations.P;
            result.y.a = (p - result.y.a) % p;
            result.y.b = (p - result.y.b) % p;
        }
    }

    function addG2(
        ISkaleDKG.G2Point memory value1,
        ISkaleDKG.G2Point memory value2
    )
        internal
        view
        returns (ISkaleDKG.G2Point memory sum)
    {

        if (isG2Zero(value1)) {
            return value2;
        }
        if (isG2Zero(value2)) {
            return value1;
        }
        if (isEqual(value1, value2)) {
            return doubleG2(value1);
        }
        if (value1.x.isEqual(value2.x)) {
            sum.x.a = 0;
            sum.x.b = 0;
            sum.y.a = 1;
            sum.y.b = 0;
            return sum;
        }

        ISkaleDKG.Fp2Point memory s = value2.y.minusFp2(value1.y).mulFp2(value2.x.minusFp2(value1.x).inverseFp2());
        sum.x = s.squaredFp2().minusFp2(value1.x.addFp2(value2.x));
        sum.y = value1.y.addFp2(s.mulFp2(sum.x.minusFp2(value1.x)));
        uint p = Fp2Operations.P;
        sum.y.a = (p - sum.y.a) % p;
        sum.y.b = (p - sum.y.b) % p;
    }

    function getTWISTB() internal pure returns (ISkaleDKG.Fp2Point memory) {

        return ISkaleDKG.Fp2Point({
            a: 19485874751759354771024239261021720505790618469301721065564631296452457478373,
            b: 266929791119991161246907387137283842545076965332900288569378510910307636690
        });
    }

    function getG2Generator() internal pure returns (ISkaleDKG.G2Point memory) {

        return ISkaleDKG.G2Point({
            x: ISkaleDKG.Fp2Point({
                a: 10857046999023057135944570762232829481370756359578518086990519993285655852781,
                b: 11559732032986387107991004021392285783925812861821192530917403151452391805634
            }),
            y: ISkaleDKG.Fp2Point({
                a: 8495653923123431417604973247489272438418190587263600148770280649306958101930,
                b: 4082367875863433681332203403145435568316851327593401208105741076214120093531
            })
        });
    }

    function getG2Zero() internal pure returns (ISkaleDKG.G2Point memory) {

        return ISkaleDKG.G2Point({
            x: ISkaleDKG.Fp2Point({
                a: 0,
                b: 0
            }),
            y: ISkaleDKG.Fp2Point({
                a: 1,
                b: 0
            })
        });
    }

    function isG2Point(ISkaleDKG.Fp2Point memory x, ISkaleDKG.Fp2Point memory y) internal pure returns (bool) {

        if (isG2ZeroPoint(x, y)) {
            return true;
        }
        ISkaleDKG.Fp2Point memory squaredY = y.squaredFp2();
        ISkaleDKG.Fp2Point memory res = squaredY.minusFp2(
                x.squaredFp2().mulFp2(x)
            ).minusFp2(getTWISTB());
        return res.a == 0 && res.b == 0;
    }

    function isG2(ISkaleDKG.G2Point memory value) internal pure returns (bool) {

        return isG2Point(value.x, value.y);
    }

    function isG2ZeroPoint(
        ISkaleDKG.Fp2Point memory x,
        ISkaleDKG.Fp2Point memory y
    )
        internal
        pure
        returns (bool)
    {

        return x.a == 0 && x.b == 0 && y.a == 1 && y.b == 0;
    }

    function isG2Zero(ISkaleDKG.G2Point memory value) internal pure returns (bool) {

        return value.x.a == 0 && value.x.b == 0 && value.y.a == 1 && value.y.b == 0;
    }

    function isEqual(
        ISkaleDKG.G2Point memory value1,
        ISkaleDKG.G2Point memory value2
    )
        internal
        pure
        returns (bool)
    {

        return value1.x.isEqual(value2.x) && value1.y.isEqual(value2.y);
    }
}// AGPL-3.0-only


pragma solidity 0.8.11;



contract KeyStorage is Permissions, IKeyStorage {

    using Fp2Operations for ISkaleDKG.Fp2Point;
    using G2Operations for ISkaleDKG.G2Point;

    struct BroadcastedData {
        KeyShare[] secretKeyContribution;
        ISkaleDKG.G2Point[] verificationVector;
    }

    mapping(bytes32 => mapping(uint => BroadcastedData)) private _data;
    
    mapping(bytes32 => ISkaleDKG.G2Point) private _publicKeysInProgress;
    mapping(bytes32 => ISkaleDKG.G2Point) private _schainsPublicKeys;

    mapping(bytes32 => ISkaleDKG.G2Point[]) private _schainsNodesPublicKeys;

    mapping(bytes32 => ISkaleDKG.G2Point[]) private _previousSchainsPublicKeys;

    function deleteKey(bytes32 schainHash) external override allow("SkaleDKG") {

        _previousSchainsPublicKeys[schainHash].push(_schainsPublicKeys[schainHash]);
        delete _schainsPublicKeys[schainHash];
        delete _data[schainHash][0];
        delete _schainsNodesPublicKeys[schainHash];
    }

    function initPublicKeyInProgress(bytes32 schainHash) external override allow("SkaleDKG") {

        _publicKeysInProgress[schainHash] = G2Operations.getG2Zero();
    }

    function adding(bytes32 schainHash, ISkaleDKG.G2Point memory value) external override allow("SkaleDKG") {

        require(value.isG2(), "Incorrect g2 point");
        _publicKeysInProgress[schainHash] = value.addG2(_publicKeysInProgress[schainHash]);
    }

    function finalizePublicKey(bytes32 schainHash) external override allow("SkaleDKG") {

        if (!_isSchainsPublicKeyZero(schainHash)) {
            _previousSchainsPublicKeys[schainHash].push(_schainsPublicKeys[schainHash]);
        }
        _schainsPublicKeys[schainHash] = _publicKeysInProgress[schainHash];
        delete _publicKeysInProgress[schainHash];
    }

    function getCommonPublicKey(bytes32 schainHash) external view override returns (ISkaleDKG.G2Point memory) {

        return _schainsPublicKeys[schainHash];
    }

    function getPreviousPublicKey(bytes32 schainHash) external view override returns (ISkaleDKG.G2Point memory) {

        uint length = _previousSchainsPublicKeys[schainHash].length;
        if (length == 0) {
            return G2Operations.getG2Zero();
        }
        return _previousSchainsPublicKeys[schainHash][length - 1];
    }

    function getAllPreviousPublicKeys(bytes32 schainHash) external view override returns (ISkaleDKG.G2Point[] memory) {

        return _previousSchainsPublicKeys[schainHash];
    }

    function initialize(address contractsAddress) public override initializer {

        Permissions.initialize(contractsAddress);
    }

    function _isSchainsPublicKeyZero(bytes32 schainHash) private view returns (bool) {

        return _schainsPublicKeys[schainHash].x.a == 0 &&
            _schainsPublicKeys[schainHash].x.b == 0 &&
            _schainsPublicKeys[schainHash].y.a == 0 &&
            _schainsPublicKeys[schainHash].y.b == 0;
    }
}