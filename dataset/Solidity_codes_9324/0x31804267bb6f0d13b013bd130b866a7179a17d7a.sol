
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

pragma solidity ^0.8.0;

library Address {

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

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

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
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
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
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


interface IAccessControlEnumerable {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}

abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}// MIT

pragma solidity ^0.8.0;


library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {

        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {

        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        bytes memory encodedParams = abi.encodeWithSelector(IERC165(account).supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;

interface IRevest {

    event FNFTTimeLockMinted(
        address indexed asset,
        address indexed from,
        uint indexed fnftId,
        uint endTime,
        uint[] quantities,
        FNFTConfig fnftConfig
    );

    event FNFTValueLockMinted(
        address indexed primaryAsset,
        address indexed from,
        uint indexed fnftId,
        address compareTo,
        address oracleDispatch,
        uint[] quantities,
        FNFTConfig fnftConfig
    );

    event FNFTAddressLockMinted(
        address indexed asset,
        address indexed from,
        uint indexed fnftId,
        address trigger,
        uint[] quantities,
        FNFTConfig fnftConfig
    );

    event FNFTWithdrawn(
        address indexed from,
        uint indexed fnftId,
        uint indexed quantity
    );

    event FNFTSplit(
        address indexed from,
        uint[] indexed newFNFTId,
        uint[] indexed proportions,
        uint quantity
    );

    event FNFTUnlocked(
        address indexed from,
        uint indexed fnftId
    );

    event FNFTMaturityExtended(
        address indexed from,
        uint indexed fnftId,
        uint indexed newExtendedTime
    );

    event FNFTAddionalDeposited(
        address indexed from,
        uint indexed newFNFTId,
        uint indexed quantity,
        uint amount
    );

    struct FNFTConfig {
        address asset; // The token being stored
        address pipeToContract; // Indicates if FNFT will pipe to another contract
        uint depositAmount; // How many tokens
        uint depositMul; // Deposit multiplier
        uint split; // Number of splits remaining
        uint depositStopTime; //
        bool maturityExtension; // Maturity extensions remaining
        bool isMulti; //
        bool nontransferrable; // False by default (transferrable) //
    }

    struct TokenTracker {
        uint lastBalance;
        uint lastMul;
    }

    enum LockType {
        DoesNotExist,
        TimeLock,
        ValueLock,
        AddressLock
    }

    struct LockParam {
        address addressLock;
        uint timeLockExpiry;
        LockType lockType;
        ValueLock valueLock;
    }

    struct Lock {
        address addressLock;
        LockType lockType;
        ValueLock valueLock;
        uint timeLockExpiry;
        uint creationTime;
        bool unlocked;
    }

    struct ValueLock {
        address asset;
        address compareTo;
        address oracle;
        uint unlockValue;
        bool unlockRisingEdge;
    }

    function mintTimeLock(
        uint endTime,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable returns (uint);


    function mintValueLock(
        address primaryAsset,
        address compareTo,
        uint unlockValue,
        bool unlockRisingEdge,
        address oracleDispatch,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable returns (uint);


    function mintAddressLock(
        address trigger,
        bytes memory arguments,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable returns (uint);


    function withdrawFNFT(uint tokenUID, uint quantity) external;


    function unlockFNFT(uint tokenUID) external;


    function splitFNFT(
        uint fnftId,
        uint[] memory proportions,
        uint quantity
    ) external returns (uint[] memory newFNFTIds);


    function depositAdditionalToFNFT(
        uint fnftId,
        uint amount,
        uint quantity
    ) external returns (uint);


    function setFlatWeiFee(uint wethFee) external;


    function setERC20Fee(uint erc20) external;


    function getFlatWeiFee() external returns (uint);


    function getERC20Fee() external returns (uint);



}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;

interface IAddressRegistry {


    function initialize(
        address lock_manager_,
        address liquidity_,
        address revest_token_,
        address token_vault_,
        address revest_,
        address fnft_,
        address metadata_,
        address admin_,
        address rewards_
    ) external;


    function getAdmin() external view returns (address);


    function setAdmin(address admin) external;


    function getLockManager() external view returns (address);


    function setLockManager(address manager) external;


    function getTokenVault() external view returns (address);


    function setTokenVault(address vault) external;


    function getRevestFNFT() external view returns (address);


    function setRevestFNFT(address fnft) external;


    function getMetadataHandler() external view returns (address);


    function setMetadataHandler(address metadata) external;


    function getRevest() external view returns (address);


    function setRevest(address revest) external;


    function getDEX(uint index) external view returns (address);


    function setDex(address dex) external;


    function getRevestToken() external view returns (address);


    function setRevestToken(address token) external;


    function getRewardsHandler() external view returns(address);


    function setRewardsHandler(address esc) external;


    function getAddress(bytes32 id) external view returns (address);


    function getLPs() external view returns (address);


    function setLPs(address liquidToken) external;


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface ILockManager {


    function createLock(uint fnftId, IRevest.LockParam memory lock) external returns (uint);


    function getLock(uint lockId) external view returns (IRevest.Lock memory);


    function fnftIdToLockId(uint fnftId) external view returns (uint);


    function fnftIdToLock(uint fnftId) external view returns (IRevest.Lock memory);


    function pointFNFTToLock(uint fnftId, uint lockId) external;


    function lockTypes(uint tokenId) external view returns (IRevest.LockType);


    function unlockFNFT(uint fnftId, address sender) external returns (bool);


    function getLockMaturity(uint fnftId) external view returns (bool);

}// GNU-GPL v3.0 or later

pragma solidity ^0.8.0;

interface IInterestHandler  {


    function registerDeposit(uint fnftId) external;


    function getPrincipal(uint fnftId) external view returns (uint);


    function getInterest(uint fnftId) external view returns (uint);


    function getAmountToWithdraw(uint fnftId) external view returns (uint);


    function getUnderlyingToken(uint fnftId) external view returns (address);


    function getUnderlyingValue(uint fnftId) external view returns (uint);


    function getPrincipalDetail(uint historic, uint amount, address asset) external view returns (uint);


    function getInterestDetail(uint historic, uint amount, address asset) external view returns (uint);


    function getUnderlyingTokenDetail(address asset) external view returns (address);


    function getInterestRate(address asset) external view returns (uint);


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface ITokenVault {


    function createFNFT(
        uint fnftId,
        IRevest.FNFTConfig memory fnftConfig,
        uint quantity,
        address from
    ) external;


    function withdrawToken(
        uint fnftId,
        uint quantity,
        address user
    ) external;


    function depositToken(
        uint fnftId,
        uint amount,
        uint quantity
    ) external;


    function cloneFNFTConfig(IRevest.FNFTConfig memory old) external returns (IRevest.FNFTConfig memory);


    function mapFNFTToToken(
        uint fnftId,
        IRevest.FNFTConfig memory fnftConfig
    ) external;


    function handleMultipleDeposits(
        uint fnftId,
        uint newFNFTId,
        uint amount
    ) external;


    function splitFNFT(
        uint fnftId,
        uint[] memory newFNFTIds,
        uint[] memory proportions,
        uint quantity
    ) external;


    function getFNFT(uint fnftId) external view returns (IRevest.FNFTConfig memory);

    function getFNFTCurrentValue(uint fnftId) external view returns (uint);

    function getNontransferable(uint fnftId) external view returns (bool);

    function getSplitsRemaining(uint fnftId) external view returns (uint);

}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;

interface IRewardsHandler {


    struct UserBalance {
        uint allocPoint; // Allocation points
        uint lastMul;
    }

    function receiveFee(address token, uint amount) external;


    function updateLPShares(uint fnftId, uint newShares) external;


    function updateBasicShares(uint fnftId, uint newShares) external;


    function getAllocPoint(uint fnftId, address token, bool isBasic) external view returns (uint);


    function claimRewards(uint fnftId, address caller) external returns (uint);


    function setStakingContract(address stake) external;


    function getRewards(uint fnftId, address token) external view returns (uint);

}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;

interface IOracleDispatch {


    function updateOracle(address asset, address compareTo) external returns (bool);


    function pokeOracle(address asset, address compareTo) external returns (bool);


    function initializeOracle(address asset, address compareTo) external returns (bool);


    function getValueOfAsset(
        address asset,
        address compareTo,
        bool risingEdge
    )  external view returns (uint);


    function oracleNeedsUpdates(address asset, address compareTo) external view returns (bool);


    function oracleNeedsPoking(address asset, address compareTo) external view returns (bool);


    function oracleNeedsInitialization(address asset, address compareTo) external view returns (bool);


    function canOracleBeCreatedForRoute(address asset, address compareTo) external view returns (bool);


    function getTimePeriodAfterPoke(address asset, address compareTo) external view returns (uint);


    function getOracleForPair(address asset, address compareTo) external view returns (address);


    function getPairHasOracle(address asset, address compareTo) external view returns (bool);


    function getInstantPrice(address asset, address compareTo) external view returns (uint);

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
}// UNLICENSED

pragma solidity ^0.8.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);


    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);


    function allPairs(uint) external view returns (address pair);


    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;


    function setFeeToSetter(address) external;

}// GNU-GPL v3.0 or later

pragma solidity ^0.8.0;


interface IRegistryProvider {

    function setAddressRegistry(address revest) external;


    function getAddressRegistry() external view returns (address);

}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;



interface IOutputReceiver is IRegistryProvider, IERC165 {


    function receiveRevestOutput(
        uint fnftId,
        address asset,
        address payable owner,
        uint quantity
    ) external;


    function getCustomMetadata(uint fnftId) external view returns (string memory);


    function getValue(uint fnftId) external view returns (uint);


    function getAsset(uint fnftId) external view returns (address);


    function getOutputDisplayValues(uint fnftId) external view returns (bytes memory);


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface IAddressLock is IRegistryProvider, IERC165{


    function createLock(uint fnftId, uint lockId, bytes memory arguments) external;


    function updateLock(uint fnftId, uint lockId, bytes memory arguments) external;


    function isUnlockable(uint fnftId, uint lockId) external view returns (bool);


    function getDisplayValues(uint fnftId, uint lockId) external view returns (bytes memory);


    function getMetadata() external view returns (string memory);


    function needsUpdate() external view returns (bool);

}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface IRevestToken is IERC20 {


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface IFNFTHandler  {

    function mint(address account, uint id, uint amount, bytes memory data) external;


    function mintBatchRec(address[] memory recipients, uint[] memory quantities, uint id, uint newSupply, bytes memory data) external;


    function mintBatch(address to, uint[] memory ids, uint[] memory amounts, bytes memory data) external;


    function setURI(string memory newuri) external;


    function burn(address account, uint id, uint amount) external;


    function burnBatch(address account, uint[] memory ids, uint[] memory amounts) external;


    function getBalance(address tokenHolder, uint id) external view returns (uint);


    function getSupply(uint fnftId) external view returns (uint);


    function getNextId() external view returns (uint);

}// GNU-GPL v3.0 or later

pragma solidity ^0.8.0;



contract RevestAccessControl is Ownable {

    IAddressRegistry internal addressesProvider;
    address addressProvider;

    constructor(address provider) Ownable() {
        addressesProvider = IAddressRegistry(provider);
        addressProvider = provider;
    }

    modifier onlyRevest() {

        require(_msgSender() != address(0), "E004");
        require(
                _msgSender() == addressesProvider.getLockManager() ||
                _msgSender() == addressesProvider.getRewardsHandler() ||
                _msgSender() == addressesProvider.getTokenVault() ||
                _msgSender() == addressesProvider.getRevest() ||
                _msgSender() == addressesProvider.getRevestToken(),
            "E016"
        );
        _;
    }

    modifier onlyRevestController() {

        require(_msgSender() != address(0), "E004");
        require(_msgSender() == addressesProvider.getRevest(), "E017");
        _;
    }

    modifier onlyTokenVault() {

        require(_msgSender() != address(0), "E004");
        require(_msgSender() == addressesProvider.getTokenVault(), "E017");
        _;
    }

    function setAddressRegistry(address registry) external onlyOwner {

        addressesProvider = IAddressRegistry(registry);
    }

    function getAdmin() internal view returns (address) {

        return addressesProvider.getAdmin();
    }

    function getRevest() internal view returns (IRevest) {

        return IRevest(addressesProvider.getRevest());
    }

    function getRevestToken() internal view returns (IRevestToken) {

        return IRevestToken(addressesProvider.getRevestToken());
    }

    function getLockManager() internal view returns (ILockManager) {

        return ILockManager(addressesProvider.getLockManager());
    }

    function getTokenVault() internal view returns (ITokenVault) {

        return ITokenVault(addressesProvider.getTokenVault());
    }

    function getUniswapV2() internal view returns (IUniswapV2Factory) {

        return IUniswapV2Factory(addressesProvider.getDEX(0));
    }

    function getFNFTHandler() internal view returns (IFNFTHandler) {

        return IFNFTHandler(addressesProvider.getRevestFNFT());
    }

    function getRewardsHandler() internal view returns (IRewardsHandler) {

        return IRewardsHandler(addressesProvider.getRewardsHandler());
    }
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
}// GNU-GPL v3.0 or later

pragma solidity ^0.8.0;


contract RevestReentrancyGuard is ReentrancyGuard {


    uint private constant MAX_INT = 0xFFFFFFFFFFFFFFFF;
    uint private currentId = MAX_INT;

    modifier revestNonReentrant(uint fnftId) {

        require(fnftId != currentId, "E052");

        currentId = fnftId;

        _;

        currentId = MAX_INT;
    }
}// UNLICENSED


pragma solidity ^0.8.0;

interface IUnicryptV2Locker {

    event onDeposit(address lpToken, address user, uint amount, uint lockDate, uint unlockDate);
    event onWithdraw(address lpToken, uint amount);

    function lockLPToken(
        address _lpToken,
        uint _amount,
        uint _unlock_date,
        address payable _referral,
        bool _fee_in_eth,
        address payable _withdrawer
    ) external payable;


    function relock(
        address _lpToken,
        uint _index,
        uint _lockID,
        uint _unlock_date
    ) external;


    function withdraw(
        address _lpToken,
        uint _index,
        uint _lockID,
        uint _amount
    ) external;


    function incrementLock(
        address _lpToken,
        uint _index,
        uint _lockID,
        uint _amount
    ) external;


    function splitLock(
        address _lpToken,
        uint _index,
        uint _lockID,
        uint _amount
    ) external payable;


    function transferLockOwnership(
        address _lpToken,
        uint _index,
        uint _lockID,
        address payable _newOwner
    ) external;


    function migrate(
        address _lpToken,
        uint _index,
        uint _lockID,
        uint _amount
    ) external;


    function getNumLocksForToken(address _lpToken) external view returns (uint);


    function getNumLockedTokens() external view returns (uint);


    function getLockedTokenAtIndex(uint _index) external view returns (address);


    function getUserNumLockedTokens(address _user) external view returns (uint);


    function getUserLockedTokenAtIndex(address _user, uint _index) external view returns (address);


    function getUserNumLocksForToken(address _user, address _lpToken) external view returns (uint);


    function getUserLockForTokenAtIndex(
        address _user,
        address _lpToken,
        uint _index
    )
        external
        view
        returns (
            uint,
            uint,
            uint,
            uint,
            uint,
            address
        );


    function tokenLocks(address asset, uint _lockID)
        external
        returns (
            uint lockDate,
            uint amount,
            uint initialAmount,
            uint unlockDate,
            uint lockID,
            address owner
        );

}// GNU-GPL v3.0 or later

pragma solidity ^0.8.0;

interface IWETH {


    function deposit() external payable;


}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using Address for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][account] = accountBalance - amount;
            }
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}// GNU-GPL v3.0 or later

pragma solidity ^0.8.0;

interface IMetadataHandler {


    function getTokenURI(uint fnftId) external view returns (string memory );


    function setTokenURI(uint fnftId, string memory _uri) external;


    function getRenderTokenURI(
        uint tokenId,
        address owner
    ) external view returns (
        string memory baseRenderURI,
        string[] memory parameters
    );


    function setRenderTokenURI(
        uint tokenID,
        string memory baseRenderURI
    ) external;


}// GNU-GPL v3.0 or later

pragma solidity ^0.8.0;


contract FNFTHandler is ERC1155, AccessControl, RevestAccessControl, IFNFTHandler {


    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    mapping(uint => uint) public supply;
    uint public fnftsCreated = 0;

    constructor(address provider) ERC1155("") RevestAccessControl(provider) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override (AccessControl, ERC1155) returns (bool) {

        return super.supportsInterface(interfaceId);
    }

    function mint(address account, uint id, uint amount, bytes memory data) external override onlyRevestController {

        supply[id] += amount;
        _mint(account, id, amount, data);
        fnftsCreated += 1;
    }

    function mintBatchRec(address[] calldata recipients, uint[] calldata quantities, uint id, uint newSupply, bytes memory data) external override onlyRevestController {

        supply[id] += newSupply;
        for(uint i = 0; i < quantities.length; i++) {
            _mint(recipients[i], id, quantities[i], data);
        }
        fnftsCreated += 1;
    }

    function mintBatch(address to, uint[] memory ids, uint[] memory amounts, bytes memory data) external override onlyRevestController {

        _mintBatch(to, ids, amounts, data);
    }

    function setURI(string memory newuri) external override onlyRevestController {

        _setURI(newuri);
    }

    function burn(address account, uint id, uint amount) external override onlyRevestController {

        supply[id] -= amount;
        _burn(account, id, amount);
    }

    function burnBatch(address account, uint[] memory ids, uint[] memory amounts) external override onlyRevestController {

        _burnBatch(account, ids, amounts);
    }

    function getBalance(address account, uint id) external view override returns (uint) {

        return balanceOf(account, id);
    }

    function getSupply(uint fnftId) public view override returns (uint) {

        return supply[fnftId];
    }

    function getNextId() public view override returns (uint) {

        return fnftsCreated;
    }



    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint[] memory ids,
        uint[] memory amounts,
        bytes memory data
    ) internal override {

        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        if (from != address(0) && to != address(0)) {
            address vault = addressesProvider.getTokenVault();
            bool canTransfer = !ITokenVault(vault).getNontransferable(ids[0]);
            if(ids.length > 1) {
                uint iterator = 0;
                while (canTransfer && iterator < ids.length) {
                    canTransfer = !ITokenVault(vault).getNontransferable(ids[iterator]);
                    iterator += 1;
                }
            }
            require(canTransfer, "E046");
        }
    }

    function uri(uint fnftId) public view override returns (string memory) {

        return IMetadataHandler(addressesProvider.getMetadataHandler()).getTokenURI(fnftId);
    }

    function renderTokenURI(
        uint tokenId,
        address owner
    ) public view returns (
        string memory baseRenderURI,
        string[] memory parameters
    ) {

        return IMetadataHandler(addressesProvider.getMetadataHandler()).getRenderTokenURI(tokenId, owner);
    }

}// GNU-GPL v3.0 or later

pragma solidity ^0.8.0;


contract RevestRemap is IRevest, AccessControlEnumerable, RevestAccessControl, RevestReentrancyGuard {

    using SafeERC20 for IERC20;
    using ERC165Checker for address;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes4 public constant ADDRESS_LOCK_INTERFACE_ID = type(IAddressLock).interfaceId;

    address immutable WETH;

    uint public erc20Fee = 0; // out of 1000
    uint private constant erc20multiplierPrecision = 1000;
    uint public flatWeiFee = 0;
    uint private constant MAX_INT = 2**256 - 1;
    mapping(address => bool) private approved;

    constructor(address provider, address weth) RevestAccessControl(provider) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        WETH = weth;
    }


    function mintTimeLock(
        uint endTime,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable override returns (uint) {

        uint fnftId = getFNFTHandler().getNextId();
        {
            IRevest.LockParam memory timeLock;
            timeLock.lockType = IRevest.LockType.TimeLock;
            timeLock.timeLockExpiry = endTime;
            getLockManager().createLock(fnftId, timeLock);
        }
        doMint(recipients, quantities, fnftId, fnftConfig, msg.value);

        emit FNFTTimeLockMinted(fnftConfig.asset, _msgSender(), fnftId, endTime, quantities, fnftConfig);

        return fnftId;
    }

    function mintValueLock(
        address primaryAsset,
        address compareTo,
        uint unlockValue,
        bool unlockRisingEdge,
        address oracleDispatch,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable override returns (uint) {

        uint fnftId = getFNFTHandler().getNextId();
        {
            IRevest.LockParam memory valueLock;
            valueLock.lockType = IRevest.LockType.ValueLock;
            valueLock.valueLock.unlockRisingEdge = unlockRisingEdge;
            valueLock.valueLock.unlockValue = unlockValue;
            valueLock.valueLock.asset = primaryAsset;
            valueLock.valueLock.compareTo = compareTo;
            valueLock.valueLock.oracle = oracleDispatch;

            getLockManager().createLock(fnftId, valueLock);
        }

        doMint(recipients, quantities, fnftId, fnftConfig, msg.value);

        emit FNFTValueLockMinted(primaryAsset,  _msgSender(), fnftId, compareTo, oracleDispatch, quantities, fnftConfig);

        return fnftId;
    }

    function mintAddressLock(
        address trigger,
        bytes memory arguments,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable override returns (uint) {

        uint fnftId = getFNFTHandler().getNextId();

        {
            IRevest.LockParam memory addressLock;
            addressLock.addressLock = trigger;
            addressLock.lockType = IRevest.LockType.AddressLock;
            uint lockId = getLockManager().createLock(fnftId, addressLock);

            if(trigger.supportsInterface(ADDRESS_LOCK_INTERFACE_ID)) {
                IAddressLock(trigger).createLock(fnftId, lockId, arguments);
            }
        }
        doMint(recipients, quantities, fnftId, fnftConfig, msg.value);

        emit FNFTAddressLockMinted(fnftConfig.asset, _msgSender(), fnftId, trigger, quantities, fnftConfig);

        return fnftId;
    }

    function withdrawFNFT(uint fnftId, uint quantity) external override revestNonReentrant(fnftId) {

        address fnftHandler = addressesProvider.getRevestFNFT();
        require(quantity <= IFNFTHandler(fnftHandler).getSupply(fnftId), "E022");
        require(quantity <= IFNFTHandler(fnftHandler).getBalance(_msgSender(), fnftId), "E006");
        require(IFNFTHandler(fnftHandler).getBalance(_msgSender(), fnftId) > 0, "E032");

        IRevest.LockType lockType = getLockManager().lockTypes(fnftId);
        require(lockType != IRevest.LockType.DoesNotExist, "E007");
        require(getLockManager().unlockFNFT(fnftId, _msgSender()),
            lockType == IRevest.LockType.TimeLock ? "E010" :
            lockType == IRevest.LockType.ValueLock ? "E018" : "E019");
        burn(_msgSender(), fnftId, quantity);
        getTokenVault().withdrawToken(fnftId, quantity, _msgSender());

        emit FNFTWithdrawn(_msgSender(), fnftId, quantity);
    }

    function unlockFNFT(uint fnftId) external override {

        IRevest.LockType lock = getLockManager().lockTypes(fnftId);
        require(lock == IRevest.LockType.AddressLock || lock == IRevest.LockType.ValueLock, "E008");
        require(getLockManager().unlockFNFT(fnftId, _msgSender()), "E056");

        emit FNFTUnlocked(_msgSender(), fnftId);
    }

    function splitFNFT(
        uint fnftId,
        uint[] memory proportions,
        uint quantity
    ) external override returns (uint[] memory) {

        require(getFNFTHandler().getBalance(_msgSender(), fnftId) > 0, "E032");
        require(getTokenVault().getSplitsRemaining(fnftId) > 0, "E023");
        uint[] memory newFNFTIds = new uint[](proportions.length);
        uint start = getFNFTHandler().getNextId();
        uint lockId = getLockManager().fnftIdToLockId(fnftId);
        getFNFTHandler().burn(_msgSender(), fnftId, quantity);
        for(uint i = 0; i < proportions.length; i++) {
            newFNFTIds[i] = start + i;
            getFNFTHandler().mint(_msgSender(), newFNFTIds[i], quantity, "");
            getLockManager().pointFNFTToLock(newFNFTIds[i], lockId);
        }
        getTokenVault().splitFNFT(fnftId, newFNFTIds, proportions, quantity);

        emit FNFTSplit(_msgSender(), newFNFTIds, proportions, quantity);

        return newFNFTIds;
    }

    function extendFNFTMaturity(
        uint fnftId,
        uint endTime
    ) external returns (uint) {

        uint supply = getFNFTHandler().getSupply(fnftId);
        uint balance = getFNFTHandler().getBalance(_msgSender(), fnftId);

        require(fnftId < getFNFTHandler().getNextId(), "E007");
        require(balance == supply, "E022");
        require(getTokenVault().getFNFT(fnftId).maturityExtension &&
            getLockManager().lockTypes(fnftId) == IRevest.LockType.TimeLock, "E029");
        require(getLockManager().fnftIdToLock(fnftId).timeLockExpiry < endTime, "E030");

        IRevest.LockParam memory lock;
        lock.lockType = IRevest.LockType.TimeLock;
        lock.timeLockExpiry = endTime;

        getLockManager().createLock(fnftId, lock);

        emit FNFTMaturityExtended(_msgSender(), fnftId, endTime);

        return fnftId;
    }

    function remapFNFTs(uint[] memory fnftIds, address newStaking) external onlyOwner {

        address vault = addressesProvider.getTokenVault();
        for(uint i = 0; i < fnftIds.length; i++) {
            uint id = fnftIds[i];
            IRevest.FNFTConfig memory config = ITokenVault(vault).getFNFT(id);
            config.pipeToContract = newStaking;
            ITokenVault(vault).mapFNFTToToken(id, config);
        }
    }


    function depositAdditionalToFNFT(
        uint fnftId,
        uint amount,
        uint quantity
    ) external override returns (uint) {

        IRevest.FNFTConfig memory fnft = getTokenVault().getFNFT(fnftId);
        require(fnftId < getFNFTHandler().getNextId(), "E007");
        require(fnft.isMulti, "E034");
        require(fnft.depositStopTime < block.timestamp || fnft.depositStopTime == 0, "E035");
        require(quantity > 0, "E070");

        address vault = addressesProvider.getTokenVault();
        address handler = addressesProvider.getRevestFNFT();
        address lockHandler = addressesProvider.getLockManager();

        bool createNewSeries = false;
        {
            uint supply = IFNFTHandler(handler).getSupply(fnftId);

            uint balance = IFNFTHandler(handler).getBalance(_msgSender(), fnftId);

            if (quantity > balance) {
                require(quantity == supply, "E069");
            }
            else if (quantity < balance || balance < supply) {
                createNewSeries = true;
            }
        }

        uint totalERC20Fee = erc20Fee * quantity * amount / erc20multiplierPrecision;
        if(totalERC20Fee > 0) {
            IERC20(fnft.asset).safeTransferFrom(_msgSender(), addressesProvider.getAdmin(), totalERC20Fee);
        }

        uint lockId = ILockManager(lockHandler).fnftIdToLockId(fnftId);

        uint newFNFTId;
        if(createNewSeries) {
            newFNFTId = IFNFTHandler(handler).getNextId();
            ILockManager(lockHandler).pointFNFTToLock(newFNFTId, lockId);
            burn(_msgSender(), fnftId, quantity);
            IFNFTHandler(handler).mint(_msgSender(), newFNFTId, quantity, "");
        } else {
            newFNFTId = 0; // Signals to handleMultipleDeposits()
        }

        ITokenVault(vault).depositToken(fnftId, amount, quantity);
        if(fnft.asset != address(0)){
            IERC20(fnft.asset).safeTransferFrom(_msgSender(), vault, quantity * amount);
        }

        ITokenVault(vault).handleMultipleDeposits(fnftId, newFNFTId, fnft.depositAmount + amount);

        emit FNFTAddionalDeposited(_msgSender(), newFNFTId, quantity, amount);

        return newFNFTId;
    }

    function getAddressesProvider() external view returns (IAddressRegistry) {

        return addressesProvider;
    }


    function doMint(
        address[] memory recipients,
        uint[] memory quantities,
        uint fnftId,
        IRevest.FNFTConfig memory fnftConfig,
        uint weiValue
    ) internal {

        bool isSingular;
        uint totalQuantity = quantities[0];
        {
            uint rec = recipients.length;
            uint quant = quantities.length;
            require(rec == quant, "recipients and quantities arrays must match");
            isSingular = rec == 1;
            if(!isSingular) {
                for(uint i = 1; i < quant; i++) {
                    totalQuantity += quantities[i];
                }
            }
            require(totalQuantity > 0, "E003");
        }

        address vault = addressesProvider.getTokenVault();

        if(weiValue > 0) {
            IWETH(WETH).deposit{value: weiValue}();
        }

        if(flatWeiFee > 0) {
            require(weiValue >= flatWeiFee, "E005");
            address reward = addressesProvider.getRewardsHandler();
            if(!approved[reward]) {
                IERC20(WETH).approve(reward, MAX_INT);
                approved[reward] = true;
            }
            IRewardsHandler(reward).receiveFee(WETH, flatWeiFee);
        }

        {
            uint totalERC20Fee = erc20Fee * totalQuantity * fnftConfig.depositAmount / erc20multiplierPrecision;
            if(totalERC20Fee > 0) {
                IERC20(fnftConfig.asset).safeTransferFrom(_msgSender(), addressesProvider.getAdmin(), totalERC20Fee);
            }
        }
        weiValue -= flatWeiFee;
        if(weiValue > 0) {
            require(fnftConfig.asset == WETH, "E053");
            require(weiValue >= fnftConfig.depositAmount, "E015");
        }

        ITokenVault(vault).createFNFT(fnftId, fnftConfig, totalQuantity, _msgSender());

        if(fnftConfig.asset != address(0)){
            IERC20(fnftConfig.asset).safeTransferFrom(_msgSender(), vault, totalQuantity * fnftConfig.depositAmount);
        }
        if(!isSingular) {
            getFNFTHandler().mintBatchRec(recipients, quantities, fnftId, totalQuantity, '');
        } else {
            getFNFTHandler().mint(recipients[0], fnftId, quantities[0], '');
        }

    }

    function burn(
        address account,
        uint id,
        uint amount
    ) internal {

        address fnftHandler = addressesProvider.getRevestFNFT();
        require(IFNFTHandler(fnftHandler).getSupply(id) - amount >= 0, "E025");
        IFNFTHandler(fnftHandler).burn(account, id, amount);
    }

    function setFlatWeiFee(uint wethFee) external override onlyOwner {

        flatWeiFee = wethFee;
    }

    function setERC20Fee(uint erc20) external override onlyOwner {

        erc20Fee = erc20;
    }

    function getFlatWeiFee() external view override returns (uint) {

        return flatWeiFee;
    }

    function getERC20Fee() external view override returns (uint) {

        return erc20Fee;
    }
}