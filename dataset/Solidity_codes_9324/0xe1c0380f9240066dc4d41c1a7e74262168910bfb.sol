
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

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    uint256[49] private __gap;
}// MIT

pragma solidity 0.8.3;



interface IAdminControl is IERC165 {


    event AdminApproved(address indexed account, address indexed sender);
    event AdminRevoked(address indexed account, address indexed sender);

    function getAdmins() external view returns (address[] memory);


    function approveAdmin(address admin) external;


    function revokeAdmin(address admin) external;


    function isAdmin(address admin) external view returns (bool);


}// MIT

pragma solidity 0.8.3;



abstract contract AdminControlUpgradeable is OwnableUpgradeable, IAdminControl, ERC165 {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _admins;

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IAdminControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    modifier adminRequired() {
        require(owner() == msg.sender || _admins.contains(msg.sender), "AdminControl: Must be owner or admin");
        _;
    }   

    function getAdmins() external view override returns (address[] memory admins) {
        admins = new address[](_admins.length());
        for (uint i = 0; i < _admins.length(); i++) {
            admins[i] = _admins.at(i);
        }
        return admins;
    }

    function approveAdmin(address admin) external override onlyOwner {
        if (!_admins.contains(admin)) {
            emit AdminApproved(admin, msg.sender);
            _admins.add(admin);
        }
    }

    function revokeAdmin(address admin) external override onlyOwner {
        if (_admins.contains(admin)) {
            emit AdminRevoked(admin, msg.sender);
            _admins.remove(admin);
        }
    }

    function isAdmin(address admin) public override view returns (bool) {
        return (owner() == admin || _admins.contains(admin));
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

pragma solidity 0.8.3;



interface INFT2ERC20RateEngine is IERC165 {

    function getRate(uint256 totalSupply, address tokenContract, uint256[] calldata args, string calldata spec) external view returns (uint256);


}// MIT

pragma solidity 0.8.3;



abstract contract NFT2ERC20RateEngine is ERC165, INFT2ERC20RateEngine {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(INFT2ERC20RateEngine).interfaceId
            || super.supportsInterface(interfaceId);
    }
}// File: contracts\libs\RealMath.sol

pragma solidity ^0.8.0;


library RealMath {


    uint256 private constant BONE           = 10 ** 18;
    uint256 private constant MIN_BPOW_BASE  = 1 wei;
    uint256 private constant MAX_BPOW_BASE  = (2 * BONE) - 1 wei;
    uint256 private constant BPOW_PRECISION = BONE / 10 ** 10;
    uint256 public constant BPOW_PRECISION2 = BONE / 10 ** 10;

    function rtoi(uint256 a)
        internal
        pure 
        returns (uint256)
    {

        return a / BONE;
    }

    function rfloor(uint256 a)
        internal
        pure
        returns (uint256)
    {

        return rtoi(a) * BONE;
    }

    function radd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        uint256 c = a + b;

        require(c >= a, "ERR_ADD_OVERFLOW");
        
        return c;
    }

    function rsub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        (uint256 c, bool flag) = rsubSign(a, b);

        require(!flag, "ERR_SUB_UNDERFLOW");

        return c;
    }

    function rsubSign(uint256 a, uint256 b)
        internal
        pure
        returns (uint256, bool)
    {

        if (a >= b) {
            return (a - b, false);

        } else {
            return (b - a, true);
        }
    }

    function rmul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        uint256 c0 = a * b;

        require(a == 0 || c0 / a == b, "ERR_MUL_OVERFLOW");

        uint256 c1 = c0 + (BONE / 2);

        require(c1 >= c0, "ERR_MUL_OVERFLOW");

        return c1 / BONE;
    }

    function rdiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        require(b != 0, "ERR_DIV_ZERO");

        uint256 c0 = a * BONE;

        require(a == 0 || c0 / a == BONE, "ERR_DIV_INTERNAL");

        uint256 c1 = c0 + (b / 2);

        require(c1 >= c0, "ERR_DIV_INTERNAL");

        return c1 / b;
    }

    function rpowi(uint256 a, uint256 n)
        internal
        pure
        returns (uint256)
    {

        uint256 z = n % 2 != 0 ? a : BONE;

        for (n /= 2; n != 0; n /= 2) {
            a = rmul(a, a);

            if (n % 2 != 0) {
                z = rmul(z, a);
            }
        }

        return z;
    }

    function rpow(uint256 base, uint256 exp)
        internal
        pure
        returns (uint256)
    {

        require(base >= MIN_BPOW_BASE, "ERR_BPOW_BASE_TOO_LOW");
        require(base <= MAX_BPOW_BASE, "ERR_BPOW_BASE_TOO_HIGH");

        uint256 whole = rfloor(exp);   
        uint256 remain = rsub(exp, whole);

        uint256 wholePow = rpowi(base, rtoi(whole));

        if (remain == 0) {
            return wholePow;
        }

        uint256 partialResult = rpowApprox(base, remain, BPOW_PRECISION);

        return rmul(wholePow, partialResult);
    }

    function rpowApprox(uint256 base, uint256 exp, uint256 precision)
        internal
        pure
        returns (uint256)
    {

        (uint256 x, bool xneg) = rsubSign(base, BONE);

        uint256 a = exp;
        uint256 term = BONE;
        uint256 sum = term;

        bool negative = false;

        for (uint256 i = 1; term >= precision; i++) {
            uint256 bigK = i * BONE;

            (uint256 c, bool cneg) = rsubSign(a, rsub(bigK, BONE));

            term = rmul(term, rmul(c, x));
            term = rdiv(term, bigK);

            if (term == 0) break;

            if (xneg) negative = !negative;
            if (cneg) negative = !negative;

            if (negative) {
                sum = rsub(sum, term);

            } else {
                sum = radd(sum, term);
            }
        }

        return sum;
    }

}// MIT

pragma solidity 0.8.3;



interface IASHRateEngineCore is INFT2ERC20RateEngine {


    event Enabled(address indexed admin, bool enabled);
    event ContractRateClassUpdate(address indexed admin, address indexed contract_, uint8 rateClass);
    event ContractTokenRateClassUpdate(address indexed admin, address indexed contract_, uint256 indexed tokenId, uint8 rateClass);

    function updateEnabled(bool enabled) external;


    function updateRateClass(address[] calldata contracts, uint8[] calldata rateClasses) external;


    function updateRateClass(address[] calldata contracts, uint256[] calldata tokenIds, uint8[] calldata rateClasses) external;


}// MIT

pragma solidity 0.8.3;





abstract contract ASHRateEngineCore is NFT2ERC20RateEngine, IASHRateEngineCore {
    using Address for address;
    using RealMath for uint256;

    mapping(address => uint8) private _contractRateClass;

    mapping(address => mapping(uint256 => uint8)) private _contractTokenRateClass;

    bool private _enabled;

    bytes32 internal constant _erc721bytes32 = keccak256(bytes('erc721'));
    bytes32 internal constant _erc1155bytes32 = keccak256(bytes('erc1155'));

    uint256 private constant CLASS1_EXP = 500000000000000000;
    uint256 private constant CLASS2_EXP = 125000000000000000;
    uint256 private constant CLASS1_BASE = 1000000000000000000000;
    uint256 private constant CLASS2_BASE = 2000000000000000000;
    uint256 private constant HALVING = 5000000000000000000000000;

    function _updateEnabled(bool enabled) internal {
        if (_enabled != enabled) {
            _enabled = enabled;
            emit Enabled(msg.sender, enabled);
        }
    }

    function _updateRateClass(address[] calldata contracts, uint8[] calldata rateClasses) internal {
        require(contracts.length == rateClasses.length, "ASHRateEngine: Mismatched input lengths");
        for (uint i=0; i<contracts.length; i++) {
            require(contracts[i].isContract(), "ASHRateEngine: token addresses must be contracts");
            require(rateClasses[i] < 3, "ASHRateEngine: Invalid rate class provided");
            if (_contractRateClass[contracts[i]] != rateClasses[i]) {
                _contractRateClass[contracts[i]] = rateClasses[i];
                emit ContractRateClassUpdate(msg.sender, contracts[i], rateClasses[i]);
            }
        }
    }

    function _updateRateClass(address[] calldata contracts, uint256[] calldata tokenIds, uint8[] calldata rateClasses) internal {
        require(contracts.length == tokenIds.length && contracts.length == rateClasses.length, "ASHRateEngine: Mismatched input lengths");
        for (uint i=0; i<contracts.length; i++) {
            require(contracts[i].isContract(), "ASHRateEngine: token addresses must be contracts");
            require(rateClasses[i] < 3, "ASHRateEngine: Invalid rate class provided");
            if (_contractTokenRateClass[contracts[i]][tokenIds[i]] != rateClasses[i]) {
                _contractTokenRateClass[contracts[i]][tokenIds[i]] = rateClasses[i];
                emit ContractTokenRateClassUpdate(msg.sender, contracts[i], tokenIds[i], rateClasses[i]);
            }
        }
    }

    function getRate(uint256 totalSupply, address tokenContract, uint256[] calldata args, string calldata spec) external view override returns (uint256) {
        require(_enabled, "ASHRateEngine: Disabled");

        bytes32 specbytes32 = keccak256(bytes(spec));

        if (specbytes32 == _erc721bytes32) {
            require(args.length == 1, "ASHRateEngine: Invalid arguments");
        } else if (specbytes32 == _erc1155bytes32) {
            require(args.length >= 2 && args[1] == 1, "ASHRateEngine: Only single ERC1155's supported");
        } else {
            revert("ASHRateEngine: Only ERC721 and ERC1155 currently supported");
        }

        uint8 rateClass = _contractTokenRateClass[tokenContract][args[0]];
        if (rateClass == 0) {
           rateClass = _contractRateClass[tokenContract];
        }
        require(rateClass != 0, "ASHRateEngine: Rate class for token not configured");


        if (rateClass == 1) {
            return CLASS1_EXP.rpow(totalSupply.rdiv(HALVING)).rmul(CLASS1_BASE);
        } else if (rateClass == 2) {
            return CLASS2_EXP.rpow(totalSupply.rdiv(HALVING)).rmul(CLASS2_BASE);
        }

        revert("Rate class for token not configured.");
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, NFT2ERC20RateEngine) returns (bool) {
        return interfaceId == type(IASHRateEngineCore).interfaceId
            || super.supportsInterface(interfaceId);
    }

}// MIT

pragma solidity 0.8.3;




contract ASHRateEngineUpgradeable is ASHRateEngineCore, AdminControlUpgradeable {


    function supportsInterface(bytes4 interfaceId) public view virtual override(ASHRateEngineCore, AdminControlUpgradeable) returns (bool) {

        return ASHRateEngineCore.supportsInterface(interfaceId) || AdminControlUpgradeable.supportsInterface(interfaceId);
    }

    function initialize() public initializer {

        __Ownable_init();
    }

    function updateEnabled(bool enabled) external override adminRequired {

        _updateEnabled(enabled);
    }

    function updateRateClass(address[] calldata contracts, uint8[] calldata rateClasses) external override adminRequired {

        _updateRateClass(contracts, rateClasses);
    }

    function updateRateClass(address[] calldata contracts, uint256[] calldata tokenIds, uint8[] calldata rateClasses) external override adminRequired {

        _updateRateClass(contracts, tokenIds, rateClasses);
    }

}