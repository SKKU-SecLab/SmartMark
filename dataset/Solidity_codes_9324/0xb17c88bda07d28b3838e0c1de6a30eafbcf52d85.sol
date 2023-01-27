
pragma solidity ^0.7.1;


interface IErc223 {

    function totalSupply() external view returns (uint);


    function balanceOf(address who) external view returns (uint);


    function transfer(address to, uint value) external returns (bool ok);

    function transfer(address to, uint value, bytes memory data) external returns (bool ok);

    
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}


interface IErc223ReceivingContract {

    function tokenFallback(address _from, uint _value, bytes memory _data) external returns (bool ok);

}


interface IErc20 {

    function totalSupply() external view returns (uint);

    function balanceOf(address tokenOwner) external view returns (uint balance);

    function transfer(address to, uint tokens) external returns (bool success);


    function allowance(address tokenOwner, address spender) external view returns (uint remaining);

    function approve(address spender, uint tokens) external returns (bool success);

    function transferFrom(address from, address to, uint tokens) external returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}




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
}



interface IShyftCacheGraph {

    function getTrustChannelManagerAddress() external view returns(address result);


    function compileCacheGraph(address _identifiedAddress, uint16 _idx) external;


    function getKycCanSend( address _senderIdentifiedAddress,
                            address _receiverIdentifiedAddress,
                            uint256 _amount,
                            uint256 _bip32X_type,
                            bool _requiredConsentFromAllParties,
                            bool _payForDirty) external returns (uint8 result);


    function getActiveConsentedTrustChannelBitFieldForPair( address _senderIdentifiedAddress,
                                                            address _receiverIdentifiedAddress) external returns (uint32 result);


    function getActiveTrustChannelBitFieldForPair(  address _senderIdentifiedAddress,
                                                    address _receiverIdentifiedAddress) external returns (uint32 result);


    function getActiveConsentedTrustChannelRoutePossible(   address _firstAddress,
                                                            address _secondAddress,
                                                            address _trustChannelAddress) external view returns (bool result);


    function getActiveTrustChannelRoutePossible(address _firstAddress,
                                                address _secondAddress,
                                                address _trustChannelAddress) external view returns (bool result);


    function getRelativeTrustLevelOnlyClean(address _senderIdentifiedAddress,
                                            address _receiverIdentifiedAddress,
                                            uint256 _amount,
                                            uint256 _bip32X_type,
                                            bool _requiredConsentFromAllParties,
                                            bool _requiredActive) external returns (int16 relativeTrustLevel, int16 externalTrustLevel);


    function calculateRelativeTrustLevel(   uint32 _trustChannelIndex,
                                            uint256 _foundChannelRulesBitField,
                                            address _senderIdentifiedAddress,
                                            address _receiverIdentifiedAddress,
                                            uint256 _amount,
                                            uint256 _bip32X_type,
                                            bool _requiredConsentFromAllParties,
                                            bool _requiredActive) external returns(int16 relativeTrustLevel, int16 externalTrustLevel);

}



interface IShyftKycContractRegistry  {

    function isShyftKycContract(address _addr) external view returns (bool result);

    function getCurrentContractAddress() external view returns (address);

    function getContractAddressOfVersion(uint _version) external view returns (address);

    function getContractVersionOfAddress(address _address) external view returns (uint256 result);


    function getAllTokenLocations(address _addr, uint256 _bip32X_type) external view returns (bool[] memory resultLocations, uint256 resultNumFound);

    function getAllTokenLocationsAndBalances(address _addr, uint256 _bip32X_type) external view returns (bool[] memory resultLocations, uint256[] memory resultBalances, uint256 resultNumFound, uint256 resultTotalBalance);

}




contract TokenConstants {





    uint256 constant TestNetTokenOffset = 2**128;
    uint256 constant PrivateNetTokenOffset = 2**192;

    uint256 constant ShyftTokenType = 7341;
    uint256 constant EtherTokenType = 60;
    uint256 constant EtherClassicTokenType = 61;
    uint256 constant RootstockTokenType = 30;

    uint256 constant BridgeTownTokenType = TestNetTokenOffset + 0;

    uint256 constant GoerliTokenType = 5;
    uint256 constant KovanTokenType = 42;
    uint256 constant RinkebyTokenType = 4;
    uint256 constant RopstenTokenType = 3;

    uint256 constant KottiTokenType = 6;

    uint256 constant RootstockTestnetTokenType = 31;

    bool constant IsTestnet = false;
    bool constant IsPrivatenet = false;
}
// pragma experimental ABIEncoderV2;











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
}






abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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
}









interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}





library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}



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
}











interface IShyftKycContract is IErc20, IErc223ReceivingContract {

    function balanceOf(address tokenOwner) external view override returns (uint balance);

    function totalSupply() external view override returns (uint);

    function transfer(address to, uint tokens) external override returns (bool success);


    function getShyftCacheGraphAddress() external view returns (address result);


    function getNativeTokenType() external view returns (uint256 result);


    function withdrawNative(address payable _to, uint256 _value) external returns (bool ok);

    function withdrawToExternalContract(address _to, uint256 _value, uint256 _gasAmount) external returns (bool ok);

    function withdrawToShyftKycContract(address _shyftKycContractAddress, address _to, uint256 _value) external returns (bool ok);


    function mintBip32X(address _to, uint256 _amount, uint256 _bip32X_type) external;

    function burnFromBip32X(address _account, uint256 _amount, uint256 _bip32X_type) external;


    function migrateFromKycContract(address _to) external payable returns(bool result);

    function updateContract(address _addr) external returns (bool);


    function transferBip32X(address _to, uint256 _value, uint256 _bip32X_type) external returns (bool result);

    function allowanceBip32X(address _tokenOwner, address _spender, uint256 _bip32X_type) external view returns (uint remaining);

    function approveBip32X(address _spender, uint _tokens, uint256 _bip32X_type) external returns (bool success);

    function transferFromBip32X(address _from, address _to, uint _tokens, uint256 _bip32X_type) external returns (bool success);


    function transferFromErc20TokenToBip32X(address _erc20ContractAddress, uint256 _value) external returns (bool ok);

    function withdrawTokenBip32XToErc20(address _erc20ContractAddress, address _to, uint256 _value) external returns (bool ok);


    function getBalanceBip32X(address _identifiedAddress, uint256 _bip32X_type) external view returns (uint256 balance);

    function getTotalSupplyBip32X(uint256 _bip32X_type) external view returns (uint256 balance);


    function getBip32XTypeForContractAddress(address _contractAddress) external view returns (uint256 bip32X_type);


    function kycSend(address _identifiedAddress, uint256 _amount, uint256 _bip32X_type, bool _requiredConsentFromAllParties, bool _payForDirty) external returns (uint8 result);


    function getOnlyAcceptsKycInput(address _identifiedAddress) external view returns (bool result);

    function getOnlyAcceptsKycInputPermanently(address _identifiedAddress) external view returns (bool result);

}




contract ShyftKycContract is IShyftKycContract, TokenConstants, AccessControl {

    event EVT_migrateToKycContract(address indexed updatedShyftKycContractAddress, uint256 updatedContractBalance, address indexed kycContractAddress, address indexed to, uint256 _amount);
    event EVT_migrateFromContract(address indexed sendingKycContract, uint256 totalSupplyBip32X, uint256 msgValue, uint256 thisBalance);

    event EVT_receivedNativeBalance(address indexed _from, uint256 _value);

    event EVT_WithdrawToAddress(address _from, address _to, uint256 _value);
    event EVT_WithdrawToExternalContract(address _from, address _to, uint256 _value);
    event EVT_WithdrawToShyftKycContract(address _from, address _to, uint256 _value);

    event EVT_TransferAndMintBip32X(address contractAddress, address msgSender, uint256 value, uint256 indexed bip32X_type);

    event EVT_TransferAndBurnBip32X(address contractAddress, address msgSender, address to, uint256 value, uint256 indexed bip32X_type);

    event EVT_TransferBip32X(address indexed from, address indexed to, uint256 tokens, uint256 indexed bip32X_type);

    event EVT_ApprovalBip32X(address indexed tokenOwner, address indexed spender, uint256 tokens, uint256 indexed bip32X_type);

    event EVT_Erc223TokenFallback(address _from, uint256 _value, bytes _data);

    event EVT_setV1EmergencyResponder(address _emergencyResponder);

    event EVT_redeemIncorrectlySentAsset(address indexed _destination, uint256 _amount);

    event EVT_UpgradeFromV1(address indexed _originAddress, address indexed _userAddress, uint256 _value);

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(uint256 => uint256) totalSupplyBip32X;
    mapping(address => mapping(uint256 => uint256)) balances;
    mapping(address => mapping(address => mapping(uint256 => uint256))) allowed;

    mapping(address => bool) autoUpgradeEnabled;
    mapping(address => bool) onlyAcceptsKycInput;
    mapping(address => bool) lockOnlyAcceptsKycInputPermanently;

    bool locked;

    bool public hasBeenUpdated;
    address public updatedShyftKycContractAddress;
    address public shyftKycContractRegistryAddress;

    address public shyftCacheGraphAddress = address(0);

    bytes4 constant shyftKycContractSig = bytes4(keccak256("fromShyftKycContract(address,address,uint256,uint256)")); // function signature

    bool public byfrostOrigin;
    bool public setByfrostOrigin;

    address public owner;
    uint256 nativeBip32X_type;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public v1TotalUpgradeAmount;

    address public emergencyResponder;


    address public machineConsentHelperAddress;



    constructor(uint256 _nativeBip32X_type) {
        owner = msg.sender;

        nativeBip32X_type = _nativeBip32X_type;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }


    function getNativeTokenType() public override view returns (uint256 result) {

        return nativeBip32X_type;
    }


    function setByfrostNetwork(uint256 _tokenAmount, uint256 _bip32X_type, address _distributionContract) public returns (uint8 result) {

        if (msg.sender == owner) {
            if (setByfrostOrigin == false) {
                byfrostOrigin = true;
                setByfrostOrigin = true;

                balances[_distributionContract][_bip32X_type] = balances[_distributionContract][_bip32X_type].add(_tokenAmount);
                totalSupplyBip32X[_bip32X_type] = totalSupplyBip32X[_bip32X_type].add(_tokenAmount);

                return 2;
            } else {
                return 1;
            }
        } else {
            return 0;
        }
    }


    function setPrimaryNetwork() public returns (uint8 result) {

        if (msg.sender == owner) {
            if (setByfrostOrigin == false) {
                setByfrostOrigin = true;

                return 2;
            } else {
                return 1;
            }
        } else {
            return 0;
        }
    }

    function removeOwner() public returns (bool) {

        require(msg.sender == owner, "not owner");

        owner = address(0);
        return true;
    }


    function setShyftCacheGraphAddress(address _shyftCacheGraphAddress) public returns (uint8 result) {

        require(_shyftCacheGraphAddress != address(0), "address cannot be zero");
        if (owner == msg.sender) {
            shyftCacheGraphAddress = _shyftCacheGraphAddress;

            return 1;
        } else {
            return 0;
        }
    }

    function getShyftCacheGraphAddress() public view override returns (address result) {

        return shyftCacheGraphAddress;
    }



    function kycSend(address _identifiedAddress, uint256 _amount, uint256 _bip32X_type, bool _requiredConsentFromAllParties, bool _payForDirty) public override returns (uint8 result) {

        if (balances[msg.sender][_bip32X_type] >= _amount) {
            if (onlyAcceptsKycInput[_identifiedAddress] == false || (onlyAcceptsKycInput[_identifiedAddress] == true && _requiredConsentFromAllParties == true)) {
                IShyftCacheGraph shyftCacheGraph = IShyftCacheGraph(shyftCacheGraphAddress);

                uint8 kycCanSendResult = shyftCacheGraph.getKycCanSend(msg.sender, _identifiedAddress, _amount, _bip32X_type, _requiredConsentFromAllParties, _payForDirty);

                if (kycCanSendResult == 3) {
                    balances[msg.sender][_bip32X_type] = balances[msg.sender][_bip32X_type].sub(_amount);
                    balances[_identifiedAddress][_bip32X_type] = balances[_identifiedAddress][_bip32X_type].add(_amount);

                    return 3;
                } else {
                    return 2;
                }
            } else {
                return 1;
            }
        } else {
            return 0;
        }
    }




    modifier mutex() {

        require(locked == false, "mutex failed :: already locked");

        locked = true;
        _;
        locked = false;
    }


    function updateContract(address _addr) public override returns (bool) {

        require(msg.sender == shyftKycContractRegistryAddress, "message sender must by registry contract");
        require(hasBeenUpdated == false, "contract has already been updated");
        require(_addr != address(0), "new kyc contract address cannot equal zero");

        hasBeenUpdated = true;
        updatedShyftKycContractAddress = _addr;
        return true;
    }


    function setShyftKycContractRegistryAddress(address _addr) public returns (bool) {

        require(msg.sender == owner, "not owner");
        require(_addr != address(0), "kyc registry address cannot equal zero");
        require(shyftKycContractRegistryAddress == address(0), "kyc registry address must not have already been set");

        shyftKycContractRegistryAddress = _addr;
        return true;
    }


    function withdrawAllNative(address payable _to) public returns (uint) {

        uint _bal = balances[msg.sender][nativeBip32X_type];
        withdrawNative(_to, _bal);
        return _bal;
    }


    function getBalanceBip32X(address _identifiedAddress, uint256 _bip32X_type) public view override returns (uint256 balance) {

        return balances[_identifiedAddress][_bip32X_type];
    }


    function getTotalSupplyBip32X(uint256 _bip32X_type) public view override returns (uint256 balance) {

        return totalSupplyBip32X[_bip32X_type];
    }


    function getBip32XTypeForContractAddress(address _contractAddress) public view override returns (uint256 bip32X_type) {

        return uint256(keccak256(abi.encodePacked(nativeBip32X_type, _contractAddress)));
    }


    receive() external payable {
        if (hasBeenUpdated && autoUpgradeEnabled[msg.sender]) {

            if (msg.sender != address(this)) {
                require(onlyAcceptsKycInput[msg.sender] == false, "must send to recipient via trust channel");

                uint256 existingSenderBalance = balances[msg.sender][nativeBip32X_type];

                balances[msg.sender][nativeBip32X_type] = 0;
                totalSupplyBip32X[nativeBip32X_type] = totalSupplyBip32X[nativeBip32X_type].sub(existingSenderBalance);

                bool didTransferSender = migrateToKycContract(updatedShyftKycContractAddress, msg.sender, existingSenderBalance.add(msg.value));

                if (didTransferSender == true) {

                } else {
                    revert("error in migration to kyc contract [user-origin]");
                }
            } else {


                uint256 existingOriginBalance = balances[tx.origin][nativeBip32X_type];

                balances[tx.origin][nativeBip32X_type] = 0;
                totalSupplyBip32X[nativeBip32X_type] = totalSupplyBip32X[nativeBip32X_type].sub(existingOriginBalance);


                bool didTransferOrigin = migrateToKycContract(updatedShyftKycContractAddress, tx.origin, existingOriginBalance.add(msg.value));

                if (didTransferOrigin == true) {

                } else {
                    revert("error in migration to updated contract [self-origin]");
                }
            }
        } else {
            if (msg.sender != address(this) && onlyAcceptsKycInput[msg.sender] == true) {
                revert("must send to recipient via trust channel");
            }

            balances[msg.sender][nativeBip32X_type] = balances[msg.sender][nativeBip32X_type].add(msg.value);
            totalSupplyBip32X[nativeBip32X_type] = totalSupplyBip32X[nativeBip32X_type].add(msg.value);

            emit EVT_receivedNativeBalance(msg.sender, msg.value);
        }
    }


    function migrateToKycContract(address _kycContractAddress, address _to, uint256 _amount) internal returns (bool result) {


        IShyftKycContract updatedKycContract = IShyftKycContract(updatedShyftKycContractAddress);

        emit EVT_migrateToKycContract(updatedShyftKycContractAddress, address(updatedShyftKycContractAddress).balance, _kycContractAddress, _to, _amount);

        bool transferResult = updatedKycContract.migrateFromKycContract{value: _amount, gas: 100000}(_to);

        if (transferResult == true) {
            return true;
        } else {
            return false;
        }
    }


    function migrateFromKycContract(address _to) public payable override returns (bool result) {




        require(totalSupplyBip32X[nativeBip32X_type].add(msg.value) <= address(this).balance, "could not migrate funds due to insufficient backing balance");

        bool doContinue = true;

        IShyftKycContractRegistry contractRegistry = IShyftKycContractRegistry(shyftKycContractRegistryAddress);

        if (contractRegistry.isShyftKycContract(address(msg.sender)) == false) {
            doContinue = false;
        } else {
            if (contractRegistry.getContractVersionOfAddress(address(msg.sender)) > contractRegistry.getContractVersionOfAddress(address(this))) {
                doContinue = false;
            }
        }

        if (onlyAcceptsKycInput[_to] == true) {
            doContinue = false;
        }

        if (doContinue == true) {
            emit EVT_migrateFromContract(msg.sender, totalSupplyBip32X[nativeBip32X_type], msg.value, address(this).balance);

            balances[_to][nativeBip32X_type] = balances[_to][nativeBip32X_type].add(msg.value);
            totalSupplyBip32X[nativeBip32X_type] = totalSupplyBip32X[nativeBip32X_type].add(msg.value);

            return true;
        } else {
            revert("kyc contract is not in registry, or must use trust channels");
        }
    }


    function setOnlyAcceptsKycInput(bool _onlyAcceptsKycInputValue) public returns (bool result) {

        if (lockOnlyAcceptsKycInputPermanently[msg.sender] == false) {
            onlyAcceptsKycInput[msg.sender] = _onlyAcceptsKycInputValue;

            return true;
        } else {

            return false;
        }
    }


    function setLockOnlyAcceptsKycInputPermanently() public returns (bool result) {

        if (lockOnlyAcceptsKycInputPermanently[msg.sender] == false) {
            lockOnlyAcceptsKycInputPermanently[msg.sender] = true;
            return true;
        } else {
            return false;
        }
    }


    function setMachineConsentHelperAddress(address _machineConsentHelperAddress) public returns (bool result) {

        require(msg.sender == owner, "not owner");
        require(_machineConsentHelperAddress != address(0), "machine consent helper address cannot equal zero");
        require(machineConsentHelperAddress == address(0), "machine consent helper address must not have already been set");

        machineConsentHelperAddress = _machineConsentHelperAddress;

        return true;
    }


    function lockContractToOnlyAcceptsKycInputPermanently(address _contractAddress) public returns (bool result) {

        if (msg.sender == machineConsentHelperAddress) {
            if (isContractAddress(_contractAddress)) {
                onlyAcceptsKycInput[_contractAddress] = true;
                lockOnlyAcceptsKycInputPermanently[_contractAddress] = true;

                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }


    function getOnlyAcceptsKycInput(address _identifiedAddress) public view override returns (bool result) {

        return onlyAcceptsKycInput[_identifiedAddress];
    }


    function getOnlyAcceptsKycInputPermanently(address _identifiedAddress) public view override returns (bool result) {

        return lockOnlyAcceptsKycInputPermanently[_identifiedAddress];
    }





    function upgradeNativeTokens(uint256 _value) mutex public returns (uint256 result) {

        if (hasBeenUpdated == true) {
            if (balances[msg.sender][nativeBip32X_type] >= _value) {
                autoUpgradeEnabled[msg.sender] = true;

                bool withdrawResult = _withdrawToShyftKycContract(updatedShyftKycContractAddress, msg.sender, _value);
                if (withdrawResult == true) {
                    result = 3;
                } else {
                    result = 2;
                }
            } else {
                result = 1;
            }
        } else {
            result = 0;
        }
    }


    function setAutoUpgrade(bool _autoUpgrade) public {

        autoUpgradeEnabled[msg.sender] = _autoUpgrade;
    }

    function isContractAddress(address _potentialContractAddress) internal returns (bool result) {

        uint codeLength;

        assembly {
            codeLength := extcodesize(_potentialContractAddress)
        }

        if (codeLength == 0) {
            return false;
        } else {
            return true;
        }
    }



    function withdrawNative(address payable _to, uint256 _value) mutex public override returns (bool ok) {

        if (balances[msg.sender][nativeBip32X_type] >= _value) {
            if (isContractAddress(_to) == false) {
                balances[msg.sender][nativeBip32X_type] = balances[msg.sender][nativeBip32X_type].sub(_value);
                totalSupplyBip32X[nativeBip32X_type] = totalSupplyBip32X[nativeBip32X_type].sub(_value);


                _to.transfer(_value);

                emit EVT_WithdrawToAddress(msg.sender, _to, _value);
                ok = true;
            } else {
                ok = false;
            }
        } else {
            ok = false;
        }
    }


    function withdrawToExternalContract(address _to, uint256 _value, uint256 _gasAmount) mutex public override returns (bool ok) {

        if (balances[msg.sender][nativeBip32X_type] >= _value) {
            if (isContractAddress(_to)) {
                balances[msg.sender][nativeBip32X_type] = balances[msg.sender][nativeBip32X_type].sub(_value);
                totalSupplyBip32X[nativeBip32X_type] = totalSupplyBip32X[nativeBip32X_type].sub(_value);


                (bool success, ) = _to.call{value: _value, gas: _gasAmount}("");

                if (success == true) {
                    emit EVT_WithdrawToExternalContract(msg.sender, _to, _value);

                    ok = true;
                } else {
                    revert("could not withdraw to an external contract");
                }
            } else {
                ok = false;
            }
        } else {
            ok = false;
        }
    }


    function withdrawToShyftKycContract(address _shyftKycContractAddress, address _to, uint256 _value) mutex public override returns (bool ok) {

        return _withdrawToShyftKycContract(_shyftKycContractAddress, _to, _value);
    }

    function _withdrawToShyftKycContract(address _shyftKycContractAddress, address _to, uint256 _value) internal returns (bool ok) {

        if (balances[msg.sender][nativeBip32X_type] >= _value) {
            if (isContractAddress(_shyftKycContractAddress) == true) {
                IShyftKycContractRegistry contractRegistry = IShyftKycContractRegistry(shyftKycContractRegistryAddress);

                if (contractRegistry.isShyftKycContract(_shyftKycContractAddress) == true) {
                    IShyftKycContract receivingShyftKycContract = IShyftKycContract(_shyftKycContractAddress);

                    if (receivingShyftKycContract.getOnlyAcceptsKycInput(_to) == false) {
                        balances[msg.sender][nativeBip32X_type] = balances[msg.sender][nativeBip32X_type].sub(_value);
                        totalSupplyBip32X[nativeBip32X_type] = totalSupplyBip32X[nativeBip32X_type].sub(_value);

                        if (receivingShyftKycContract.migrateFromKycContract{gas: 120000, value: _value}(_to) == false) {
                            revert("could not migrate from shyft kyc contract");
                        }

                        emit EVT_WithdrawToShyftKycContract(msg.sender, _to, _value);

                        ok = true;
                    } else {
                        ok = false;
                    }
                } else {
                    ok = false;
                }
            } else {
                ok = false;
            }
        } else {
            ok = false;
        }
    }



    function tokenFallback(address _from, uint _value, bytes memory _data) mutex public override returns (bool ok) {
        require(onlyAcceptsKycInput[_from] == false, "recipient address must not require only kyc'd input");

        IShyftKycContractRegistry contractRegistry = IShyftKycContractRegistry(shyftKycContractRegistryAddress);

        if (shyftKycContractRegistryAddress != address(0) && contractRegistry.isShyftKycContract(address(msg.sender)) == true) {
            if (contractRegistry.getContractVersionOfAddress(address(msg.sender)) == 0) {

                bytes4 tokenSig;

                if (_data.length >= 4) {
                    tokenSig = bytes4(uint32(bytes4(bytes1(_data[3])) >> 24) + uint32(bytes4(bytes1(_data[2])) >> 16) + uint32(bytes4(bytes1(_data[1])) >> 8) + uint32(bytes4(bytes1(_data[0]))));
                }

                if (tokenSig != shyftKycContractSig) {
                    balances[_from][ShyftTokenType] = balances[_from][ShyftTokenType].add(_value);
                    totalSupplyBip32X[ShyftTokenType] = totalSupplyBip32X[ShyftTokenType].add(_value);

                    v1TotalUpgradeAmount = v1TotalUpgradeAmount.add(_value);

                    emit EVT_TransferAndMintBip32X(msg.sender, _from, _value, ShyftTokenType);
                    emit EVT_UpgradeFromV1(msg.sender, _from, _value);

                    ok = true;
                } else {
                    revert("cannot process a withdrawToExternalContract event from the v0 contract.");
                }

            } else {
                revert("cannot process fallback from Shyft Kyc Contract of a revision not equal to 0, in this version of Shyft Core");
            }
        }
    }



    function balanceOf(address _who) public view override returns (uint) {
        return balances[_who][ShyftTokenType];
    }


    function name() public pure returns (string memory _name) {
        return "Shyft [ Wrapped ]";
    }


    function symbol() public pure returns (string memory _symbol) {
        return "SHFT";
    }


    function decimals() public pure returns (uint8 _decimals) {
        return 18;
    }


    function totalSupply() public view override returns (uint256 result) {
        return getTotalSupplyBip32X(ShyftTokenType);
    }


    function transfer(address _to, uint256 _value) public override returns (bool ok) {
        if (onlyAcceptsKycInput[_to] == false && balances[msg.sender][ShyftTokenType] >= _value) {
            balances[msg.sender][ShyftTokenType] = balances[msg.sender][ShyftTokenType].sub(_value);

            balances[_to][ShyftTokenType] = balances[_to][ShyftTokenType].add(_value);

            emit Transfer(msg.sender, _to, _value);

            return true;
        } else {
            return false;
        }
    }


    function allowance(address _tokenOwner, address _spender) public view override returns (uint remaining) {
       return allowed[_tokenOwner][_spender][ShyftTokenType];
    }



    function approve(address _spender, uint _tokens) public override returns (bool success) {
        allowed[msg.sender][_spender][ShyftTokenType] = _tokens;


        emit Approval(msg.sender, _spender, _tokens);

        return true;
    }


    function transferFrom(address _from, address _to, uint _tokens) public override returns (bool success) {
        if (onlyAcceptsKycInput[_to] == false && allowed[_from][msg.sender][ShyftTokenType] >= _tokens && balances[_from][ShyftTokenType] >= _tokens) {
            allowed[_from][msg.sender][ShyftTokenType] = allowed[_from][msg.sender][ShyftTokenType].sub(_tokens);

            balances[_from][ShyftTokenType] = balances[_from][ShyftTokenType].sub(_tokens);
            balances[_to][ShyftTokenType] = balances[_to][ShyftTokenType].add(_tokens);

            emit Transfer(_from, _to, _tokens);
            emit Approval(_from, msg.sender, allowed[_from][msg.sender][ShyftTokenType]);

            return true;
        } else {
            return false;
        }
    }



    function mint(address _to, uint256 _amount) public {
        require(_to != address(0), "ShyftKycContract: mint to the zero address");
        require(hasRole(MINTER_ROLE, msg.sender), "ShyftKycContract: must have minter role to mint");


        if (onlyAcceptsKycInput[_to] == true) {
            if (shyftCacheGraphAddress != address(0)) {
                IShyftCacheGraph shyftCacheGraph = IShyftCacheGraph(shyftCacheGraphAddress);

                uint8 kycCanSendResult = shyftCacheGraph.getKycCanSend(msg.sender, _to, _amount, ShyftTokenType, true, false);

                if (kycCanSendResult == 3) {
                } else {
                    revert("ShyftKycContract: mint to KYC only address within Trust Channel groupings");
                }
            } else {
                revert("ShyftKycContract: mint to KYC only address within Trust Channel groupings");
            }
        }

        totalSupplyBip32X[ShyftTokenType] = totalSupplyBip32X[ShyftTokenType].add(_amount);
        balances[_to][ShyftTokenType] = balances[_to][ShyftTokenType].add(_amount);

        emit Transfer(address(0), _to, _amount);
    }


    function burnFrom(address _account, uint256 _amount) public {
        require(_account != address(0), "ShyftKycContract: burn from the zero address");
        uint256 currentAllowance = allowed[_account][msg.sender][ShyftTokenType];
        require(currentAllowance >= _amount, "ShyftKycContract: burn amount exceeds allowance");
        uint256 accountBalance = balances[_account][ShyftTokenType];
        require(accountBalance >= _amount, "ShyftKycContract: burn amount exceeds balance");

        allowed[_account][msg.sender][ShyftTokenType] = currentAllowance.sub(_amount);

        emit Approval(_account, msg.sender, allowed[_account][msg.sender][ShyftTokenType]);

        balances[_account][ShyftTokenType] = accountBalance.sub(_amount);
        totalSupplyBip32X[ShyftTokenType] = totalSupplyBip32X[ShyftTokenType].sub(_amount);

        emit Transfer(_account, address(0), _amount);
    }



    function mintBip32X(address _to, uint256 _amount, uint256 _bip32X_type) public override {
        require(_to != address(0), "ShyftKycContract: mint to the zero address");
        require(hasRole(MINTER_ROLE, msg.sender), "ShyftKycContract: must have minter role to mint");


        if (onlyAcceptsKycInput[_to] == true) {
            if (shyftCacheGraphAddress != address(0)) {
                IShyftCacheGraph shyftCacheGraph = IShyftCacheGraph(shyftCacheGraphAddress);

                uint8 kycCanSendResult = shyftCacheGraph.getKycCanSend(msg.sender, _to, _amount, _bip32X_type, true, false);

                if (kycCanSendResult == 3) {
                } else {
                    revert("ShyftKycContract: mint to KYC only address within Trust Channel groupings");
                }
            } else {
                revert("ShyftKycContract: mint to KYC only address within Trust Channel groupings");
            }
        }

        totalSupplyBip32X[_bip32X_type] = totalSupplyBip32X[_bip32X_type].add(_amount);
        balances[_to][_bip32X_type] = balances[_to][_bip32X_type].add(_amount);


        emit EVT_TransferBip32X(address(0), _to, _amount, _bip32X_type);
    }


    function burnFromBip32X(address _account, uint256 _amount, uint256 _bip32X_type) public override {
        require(_account != address(0), "ShyftKycContract: burn from the zero address");
        uint256 currentAllowance = allowed[_account][msg.sender][_bip32X_type];
        require(currentAllowance >= _amount, "ShyftKycContract: burn amount exceeds allowance");
        uint256 accountBalance = balances[_account][_bip32X_type];
        require(accountBalance >= _amount, "ShyftKycContract: burn amount exceeds balance");

        allowed[_account][msg.sender][_bip32X_type] = currentAllowance.sub(_amount);

        emit EVT_ApprovalBip32X(_account, msg.sender, allowed[_account][msg.sender][_bip32X_type], _bip32X_type);

        balances[_account][_bip32X_type] = accountBalance.sub(_amount);
        totalSupplyBip32X[_bip32X_type] = totalSupplyBip32X[_bip32X_type].sub(_amount);

        emit EVT_TransferBip32X(_account, address(0), _amount, _bip32X_type);
    }



    function transferBip32X(address _to, uint256 _value, uint256 _bip32X_type) public override returns (bool result) {
        require(onlyAcceptsKycInput[_to] == false, "recipient must not only accept kyc'd input");
        require(balances[msg.sender][_bip32X_type] >= _value, "not enough balance");

        balances[msg.sender][_bip32X_type] = balances[msg.sender][_bip32X_type].sub(_value);
        balances[_to][_bip32X_type] = balances[_to][_bip32X_type].add(_value);

        emit EVT_TransferBip32X(msg.sender, _to, _value, _bip32X_type);
        return true;
    }


    function allowanceBip32X(address _tokenOwner, address _spender, uint256 _bip32X_type) public view override returns (uint remaining) {
        return allowed[_tokenOwner][_spender][_bip32X_type];
    }



    function approveBip32X(address _spender, uint _tokens, uint256 _bip32X_type) public override returns (bool success) {
        allowed[msg.sender][_spender][_bip32X_type] = _tokens;


        emit EVT_ApprovalBip32X(msg.sender, _spender, _tokens, _bip32X_type);

        return true;
    }


    function transferFromBip32X(address _from, address _to, uint _tokens, uint256 _bip32X_type) public override returns (bool success) {
        if (onlyAcceptsKycInput[_to] == false && allowed[_from][msg.sender][_bip32X_type] >= _tokens && balances[_from][ShyftTokenType] >= _tokens) {
            allowed[_from][msg.sender][_bip32X_type] = allowed[_from][msg.sender][_bip32X_type].sub(_tokens);

            balances[_from][_bip32X_type] = balances[_from][_bip32X_type].sub(_tokens);
            balances[_to][_bip32X_type] = balances[_to][_bip32X_type].add(_tokens);

            emit EVT_TransferBip32X(_from, _to, _tokens, _bip32X_type);
            emit EVT_ApprovalBip32X(_from, msg.sender, allowed[_from][msg.sender][_bip32X_type], _bip32X_type);

            return true;
        } else {
            return false;
        }
    }



    function transferFromErc20TokenToBip32X(address _erc20ContractAddress, uint256 _value) mutex public override returns (bool ok) {
        require(_erc20ContractAddress != address(this), "cannot transfer from this contract");

        require(onlyAcceptsKycInput[msg.sender] == false, "recipient must not only accept kyc'd input");

        IERC20 erc20Contract = IERC20(_erc20ContractAddress);

        if (erc20Contract.allowance(msg.sender, address(this)) >= _value) {
            erc20Contract.safeTransferFrom(msg.sender, address(this), _value);

            uint256 bip32X_type = uint256(keccak256(abi.encodePacked(nativeBip32X_type, _erc20ContractAddress)));
            balances[msg.sender][bip32X_type] = balances[msg.sender][bip32X_type].add(_value);
            totalSupplyBip32X[bip32X_type] = totalSupplyBip32X[bip32X_type].add(_value);

            emit EVT_TransferAndMintBip32X(_erc20ContractAddress, msg.sender, _value, bip32X_type);

            ok = true;
        } else {
        }
    }


    function withdrawTokenBip32XToErc20(address _erc20ContractAddress, address _to, uint256 _value) mutex public override returns (bool ok) {
        uint256 bip32X_type = uint256(keccak256(abi.encodePacked(nativeBip32X_type, _erc20ContractAddress)));

        require(balances[msg.sender][bip32X_type] >= _value, "not enough balance");

        balances[msg.sender][bip32X_type] = balances[msg.sender][bip32X_type].sub(_value);
        totalSupplyBip32X[bip32X_type] = totalSupplyBip32X[bip32X_type].sub(_value);

        IERC20 erc20Contract = IERC20(_erc20ContractAddress);

        erc20Contract.safeTransfer(_to, _value);

        emit EVT_TransferAndBurnBip32X(_erc20ContractAddress, msg.sender, _to, _value, bip32X_type);

        ok = true;
    }





    function setV1EmergencyErc20RedemptionResponder(address _emergencyResponder) public returns(uint8 result) {
        if (msg.sender == owner) {
            emergencyResponder = _emergencyResponder;

            emit EVT_setV1EmergencyResponder(_emergencyResponder);
            return 1;
        } else {
            return 0;
        }
    }


    function getIncorrectlySentAssetsBalance() public view returns(uint256 result) {
        IShyftKycContractRegistry contractRegistry = IShyftKycContractRegistry(shyftKycContractRegistryAddress);

        address ethMarch26KycContractAddress = contractRegistry.getContractAddressOfVersion(0);

        if (ethMarch26KycContractAddress != address(0)) {

            IERC20 march26Erc20 = IERC20(ethMarch26KycContractAddress);

            uint256 currentBalance = march26Erc20.balanceOf(address(this));

            uint256 incorrectlySentAssetBalance = currentBalance.sub(v1TotalUpgradeAmount);

            return incorrectlySentAssetBalance;
        } else {
            return 0;
        }
    }


    function responderRedeemIncorrectlySentAssets(address _destination, uint256 _amount) public returns(uint8 result) {
        if (msg.sender == emergencyResponder) {
            IShyftKycContractRegistry contractRegistry = IShyftKycContractRegistry(shyftKycContractRegistryAddress);

            address ethMarch26KycContractAddress = contractRegistry.getContractAddressOfVersion(0);

            if (ethMarch26KycContractAddress != address(0)) {
                IERC20 march26Erc20 = IERC20(ethMarch26KycContractAddress);

                uint256 currentBalance = march26Erc20.balanceOf(address(this));

                uint256 incorrectlySentAssetBalance = currentBalance.sub(v1TotalUpgradeAmount);

                if (_amount <= incorrectlySentAssetBalance) {
                    bool success = march26Erc20.transfer(_destination, _amount);

                    if (success == true) {
                        emit EVT_redeemIncorrectlySentAsset(_destination, _amount);

                        return 4;
                    } else {
                        revert("erc20 transfer event did not succeed");
                    }
                } else {
                    return 2;
                }
            } else {
                return 1;
            }
        } else {
            return 0;
        }
    }
}