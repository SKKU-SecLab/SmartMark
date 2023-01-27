
pragma solidity ^0.8.0;



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


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
}


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
}


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
}


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
}


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
}

interface IBridge {


    event OutboundTransferFinalized(uint256 toChainId, address token, address from, address to, uint256 amount, bytes data, bytes32 checkDigits);

    event InboundTransferFinalized(uint256 fromChainId, address token, address from, address to, uint256 amount, bytes data, bytes32 checkDigits);

    function outboundTransfer(uint256 _toChainId, address _token, address _to, uint256 _amount, bytes calldata _data) external payable returns (bytes memory);


    function inboundTransfer(uint256 _fromChainId, address _token, address _from, address _to, uint256 _amount, bytes calldata _data) external payable returns (bytes memory);



}

library AddressArray {


    using AddressArray for AddressArray.Addresses;

    struct Addresses {
        address[] _items;
    }

    function pushAddress(Addresses storage self, address element) internal {

        if (!exists(self, element)) {
            self._items.push(element);
        }
    }

    function removeAddress(Addresses storage self, address element) internal returns (bool) {

        for (uint i = 0; i < self.size(); i++) {
            if (self._items[i] == element) {
                self._items[i] = self._items[self.size() - 1];
                self._items.pop();
                return true;
            }
        }
        return false;
    }

    function getAddressAtIndex(Addresses storage self, uint256 index) internal view returns (address) {

        require(index < size(self), "the index is out of bounds");
        return self._items[index];
    }

    function size(Addresses storage self) internal view returns (uint256) {

        return self._items.length;
    }

    function exists(Addresses storage self, address element) internal view returns (bool) {

        for (uint i = 0; i < self.size(); i++) {
            if (self._items[i] == element) {
                return true;
            }
        }
        return false;
    }

    function getAllAddresses(Addresses storage self) internal view returns (address[] memory) {

        return self._items;
    }


}

abstract contract AbstractBridge is AccessControl, Initializable, IBridge {

    using SafeERC20 for IERC20;
    using AddressArray for AddressArray.Addresses;

    address constant ZERO_ADDR = address(0);
    address constant ETH_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    AddressArray.Addresses blockList;
    AddressArray.Addresses allowList;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    mapping(uint256 => bool) public chainSupported;


    event ChainSupportedSet(uint256 chainId, bool status);

    receive() external payable {}

    function _init() internal {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    function _getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly {chainId := chainid()}
        return chainId;
    }

    function _getBalanceInternal(address _target, address _reserve) internal view returns (uint256) {
        if (_reserve == ETH_ADDR) {
            return _target.balance;
        }
        return IERC20(_reserve).balanceOf(_target);
    }

    function _transferInternal(address _asset, address payable _to, uint _amount) internal {
        uint balance = _getBalanceInternal(address(this), _asset);
        require(balance >= _amount, "INSUFFICIENT_BALANCE");

        if (_asset == ETH_ADDR) {
            (bool success,) = _to.call{value : _amount}("");
            require(success == true, "Couldn't transfer ETH");
            return;
        }
        IERC20(_asset).safeTransfer(_to, _amount);
    }

    function tokenTransfer(address _asset, address payable _to, uint _amount) external onlyRole(ADMIN_ROLE) {
        _transferInternal(_asset, _to, _amount);
    }

    function addToBlockList(address _user) external onlyRole(ADMIN_ROLE) {
        blockList.pushAddress(_user);
    }

    function removeFromBlockList(address _user) external onlyRole(ADMIN_ROLE) {
        blockList.removeAddress(_user);
    }

    function getBlocklist() public view returns (address[] memory) {
        return blockList.getAllAddresses();
    }

    function addToAllowList(address _user) external onlyRole(ADMIN_ROLE) {
        allowList.pushAddress(_user);
    }

    function removeFromAllowList(address _user) external onlyRole(ADMIN_ROLE) {
        allowList.removeAddress(_user);
    }

    function getAllowList() public view returns (address[] memory) {
        return allowList.getAllAddresses();
    }

    function setChainSupported(uint256[] memory _chainIds, bool[] memory _status) external onlyRole(ADMIN_ROLE) {
        require(_chainIds.length == _status.length, "WRONG_LENGTH");
        for (uint256 i = 0; i < _chainIds.length; i++) {
            chainSupported[_chainIds[i]] = _status[i];
            emit ChainSupportedSet(_chainIds[i], _status[i]);
        }
    }

    function isTokenRouter() public view virtual returns (bool);

    function isTokenBridge() public view virtual returns (bool);

    function _getOutboundCalldata(
        uint256 _toChainId,
        address _token,
        address _from,
        address _to,
        uint256 _amount,
        bytes memory _data
    ) internal view virtual returns (bytes memory);


}

abstract contract AbstractTokenBridge is AbstractBridge {

    using AddressArray for AddressArray.Addresses;

    address public router;
    bool public outboundEnable;
    bool public inboundEnable;

    event StatusUpdated(string statusName, bool oldStatus, bool newStatus);

    function _initialize(address _router) internal {
        super._init();
        router = _router;
    }

    function isTokenRouter() public view override returns (bool){
        return false;
    }

    function isTokenBridge() public view override returns (bool){
        return true;
    }

    function setOutboundEnable(bool status) external onlyRole(ADMIN_ROLE) {
        bool oldStatus = outboundEnable;
        outboundEnable = status;
        emit StatusUpdated("outboundEnable", oldStatus, outboundEnable);
    }

    function setInboundEnable(bool status) external onlyRole(ADMIN_ROLE) {
        bool oldStatus = inboundEnable;
        inboundEnable = status;
        emit StatusUpdated("inboundEnable", oldStatus, inboundEnable);
    }

    function _getOutboundCheckDigits(
        uint256 _toChainId,
        address _token,
        address _from,
        address _to,
        uint256 _amount,
        bytes memory _data
    ) internal view virtual returns (bytes32) {

        bytes32 digest = keccak256(
            abi.encodePacked(
                "WePiggy Bridge",
                keccak256(abi.encode(address(this))),
                keccak256(abi.encode(_getChainId(), _toChainId, _token, _from, _to, _amount, _data))
            )
        );

        return digest;
    }

    function _getInboundCheckDigits(
        uint256 _fromChainId,
        address _token,
        address _from,
        address _to,
        uint256 _amount,
        bytes memory _data) internal view virtual returns (bytes32) {

        bytes32 digest = keccak256(
            abi.encodePacked(
                "WePiggy Bridge",
                keccak256(abi.encode(address(this))),
                keccak256(abi.encode(_fromChainId, _getChainId(), _token, _from, _to, _amount, _data))
            )
        );

        return digest;
    }


    function _parseOutboundData(bytes memory _data) internal view virtual returns (address _from, bytes memory _extraData){
        if (router == msg.sender) {
            (_from, _extraData) = abi.decode(_data, (address, bytes));
        } else {
            _from = msg.sender;
            _extraData = _data;
        }
    }

    function _parseInboundData(bytes memory _data) internal view virtual returns (bytes32 _checkDigits, bytes memory _extraData){
        (_checkDigits, _extraData) = abi.decode(_data, (bytes32, bytes));
    }

    function _getOutboundCalldata(
        uint256 _toChainId,
        address _token,
        address _from,
        address _to,
        uint256 _amount,
        bytes memory _data
    ) internal view virtual override returns (bytes memory) {
        return abi.encode(address(this), _data);
    }

    function outboundTransfer(
        uint256 _toChainId,
        address _token,
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) public payable virtual override returns (bytes memory) {

        require(outboundEnable, "OUTBOUND_DISABLE");
        require(chainSupported[_toChainId], "NOT_IN_CHAINSUPPORTED");

        (address _from, bytes memory _rawData) = _parseOutboundData(_data);
        require(blockList.exists(_from) == false, "SENDER_IN_BLOCKLIST");

        bytes memory _extraData = _getOutboundCalldata(_toChainId, _token, _from, _to, _amount, _rawData);
        bytes32 _checkDigits = _getOutboundCheckDigits(_toChainId, _token, _from, _to, _amount, _extraData);

        return abi.encode(_from, _rawData, _checkDigits);
    }

    function inboundTransfer(
        uint256 _fromChainId,
        address _token,
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) public payable virtual override returns (bytes memory) {

        require(inboundEnable, "INBOUND_DISABLE");
        require(chainSupported[_fromChainId], "NOT_IN_CHAINSUPPORTED");
        require(blockList.exists(_to) == false, "SENDER_IN_BLOCKLIST");

        (bytes32 _orgCheckDigits, bytes memory _rawData) = _parseInboundData(_data);
        bytes32 _checkDigits = _getInboundCheckDigits(_fromChainId, _token, _from, _to, _amount, _rawData);

        require(_orgCheckDigits == _checkDigits, "INCORRECT_CHECK_DIGITS");

        return abi.encode(_rawData, _checkDigits);
    }

}


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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract WPCBridge is AbstractTokenBridge {

    using SafeMath for uint256;
    using Address for address;

    address public wpc;

    function _initialize(address _wpc, address _router) internal {
        super._initialize(_router);
        wpc = _wpc;
    }

    function outboundTransfer(
        uint256 _toChainId,
        address _token,
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) public payable virtual override returns (bytes memory) {

        require(_token == wpc, "NOT_WPC");
        require(_to.isContract() == false, "NO_CONTRACT_TRANSFER_SUPPORT");

        bytes memory superRes = super.outboundTransfer(_toChainId, _token, _to, _amount, _data);
        (address _from,bytes memory _rawData,bytes32 _checkDigits) = abi.decode(superRes, (address, bytes, bytes32));

        _outboundEscrowTransfer(_token, msg.sender, _amount);


        emit OutboundTransferFinalized(_toChainId, _token, _from, _to, _amount, _rawData, _checkDigits);

        return bytes("");
    }


    function inboundTransfer(
        uint256 _fromChainId,
        address _token,
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) public payable virtual override onlyRole(ADMIN_ROLE) returns (bytes memory) {

        require(_token == wpc, "NOT_WPC");
        require(_to.isContract() == false, "NO_CONTRACT_TRANSFER_SUPPORT");

        bytes memory superRes = super.inboundTransfer(_fromChainId, _token, _from, _to, _amount, _data);
        (bytes memory _rawData,bytes32 _checkDigits) = abi.decode(superRes, (bytes, bytes32));

        _inboundEscrowTransfer(_token, _to, _amount);

        emit InboundTransferFinalized(_fromChainId, _token, _from, _to, _amount, _rawData, _checkDigits);

        return bytes("");
    }

    function _outboundEscrowTransfer(address _token, address _from, uint256 _amount) internal virtual;

    function _inboundEscrowTransfer(address _token, address _to, uint256 _amount) internal virtual;

    function _setWpc(address _wpc) public onlyRole(ADMIN_ROLE) {
        wpc = _wpc;
    }

    function _setRouter(address _router) public onlyRole(ADMIN_ROLE) {
        router = _router;
    }
}

contract WPCMainnetBridge is WPCBridge {


    using SafeERC20 for IERC20;

    function initialize(address _wpc, address _router) public initializer {

        super._initialize(_wpc, _router);
    }

    function _outboundEscrowTransfer(address _token, address _from, uint256 _amount) internal virtual override {

        IERC20(_token).safeTransferFrom(_from, address(this), _amount);
    }

    function _inboundEscrowTransfer(address _token, address _to, uint256 _amount) internal virtual override {

        IERC20(_token).safeTransfer(_to, _amount);
    }
}