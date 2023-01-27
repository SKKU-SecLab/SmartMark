pragma solidity 0.8.11;

interface ISwap {

    function mintTo(uint256 amount, address recipient) external returns (bool);


    function burn(uint256 amount) external returns (bool);

}// Apache-2.0
pragma solidity 0.8.11;

interface IProxyInitialize {

    function initialize(
        string calldata name,
        string calldata symbol,
        uint8 decimals,
        uint256 amount,
        bool mintable,
        address owner
    ) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}// MIT

pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

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

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.2;


abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1967Proxy is Proxy, ERC1967Upgrade {

    constructor(address _logic, bytes memory _data) payable {
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _upgradeToAndCall(_logic, _data, false);
    }

    function _implementation() internal view virtual override returns (address impl) {

        return ERC1967Upgrade._getImplementation();
    }
}// MIT

pragma solidity ^0.8.0;


contract TransparentUpgradeableProxy is ERC1967Proxy {

    constructor(
        address _logic,
        address admin_,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        assert(_ADMIN_SLOT == bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        _changeAdmin(admin_);
    }

    modifier ifAdmin() {

        if (msg.sender == _getAdmin()) {
            _;
        } else {
            _fallback();
        }
    }

    function admin() external ifAdmin returns (address admin_) {

        admin_ = _getAdmin();
    }

    function implementation() external ifAdmin returns (address implementation_) {

        implementation_ = _implementation();
    }

    function changeAdmin(address newAdmin) external virtual ifAdmin {

        _changeAdmin(newAdmin);
    }

    function upgradeTo(address newImplementation) external ifAdmin {

        _upgradeToAndCall(newImplementation, bytes(""), false);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable ifAdmin {

        _upgradeToAndCall(newImplementation, data, true);
    }

    function _admin() internal view virtual returns (address) {

        return _getAdmin();
    }

    function _beforeFallback() internal virtual override {

        require(msg.sender != _getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}// Apache-2.0
pragma solidity 0.8.11;


contract BEP20UpgradeableProxy is TransparentUpgradeableProxy {

    constructor(
        address logic,
        address admin,
        bytes memory data
    ) TransparentUpgradeableProxy(logic, admin, data) {}
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
}// Apache-2.0
pragma solidity 0.8.11;



contract StreamCoinCrossChainSwap is Context {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    mapping(address => address) public swapMapping2BSC;
    mapping(address => address) public swapMappingFrmBSC;
    mapping(bytes32 => bool) public filledBSCTx;

    address payable public owner;
    address public superAdmin;
    address payable public feeReceiver;
    address public gen20ProxyAdmin;
    address public gen20Implementation;
    uint256 public swapFee;
    uint256 public feePercentageInStream;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event SuperAdminChanged(
        address indexed previousSuperAdmin,
        address indexed newSuperAdmin
    );
    event FeeReceiverUpdated(
        address indexed prevFeeReceiver,
        address indexed newFeeReceiver
    );
    event SwapPairCreated(
        bytes32 indexed bscRegisterTxHash,
        address indexed gen20Addr,
        address indexed bep20Addr,
        string symbol,
        string name,
        uint8 decimals
    );
    event SwapStarted(
        address indexed gen20Addr,
        address indexed bep20Addr,
        address indexed fromAddr,
        uint256 amount,
        uint256 feeAmount,
        uint256 feeInStream,
        string chain
    );
    event SwapFilled(
        address indexed bep20Addr,
        bytes32 indexed bscTxHash,
        address indexed toAddress,
        uint256 amount,
        string chain
    );

    constructor(
        address gen20Impl,
        uint256 fee_Native,
        uint256 fee_PerStream,
        address payable fee_Receiver,
        address gen20ProxyAdminAddr,
        address super_Admin
    ) {
        gen20Implementation = gen20Impl;
        swapFee = fee_Native;
        feePercentageInStream = fee_PerStream;
        feeReceiver = fee_Receiver;
        owner = payable(msg.sender);
        gen20ProxyAdmin = gen20ProxyAdminAddr;
        superAdmin = super_Admin;
    }

    modifier onlyOwner() {

        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlySuperAdmin() {

        require(
            superAdmin == _msgSender(),
            "Super Admin: caller is not the super admin"
        );
        _;
    }

    modifier notContract() {

        require(!isContract(msg.sender), "contract is not allowed to swap");
        _;
    }

    modifier noProxy() {

        require(msg.sender == tx.origin, "no proxy is allowed");
        _;
    }

    function isContract(address addr) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function renounceOwnership() public onlySuperAdmin {

        emit OwnershipTransferred(owner, address(0));
        owner = payable(0);
    }

    function transferOwnership(address payable newOwner) public onlySuperAdmin {

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function changeSuperAdmin(address newSuperAdmin) public onlySuperAdmin {

        require(
            newSuperAdmin != address(0),
            "Super Admin: new super admin is the zero address"
        );
        emit SuperAdminChanged(superAdmin, newSuperAdmin);
        superAdmin = newSuperAdmin;
    }

    function changeFeeReceiver(address payable newFeeReceiver)
        public
        onlySuperAdmin
    {

        require(
            newFeeReceiver != address(0),
            "Fee Receiver: new fee receiver address is zero "
        );
        emit FeeReceiverUpdated(feeReceiver, newFeeReceiver);
        feeReceiver = newFeeReceiver;
    }

    function setSwapFee(uint256 fee) external onlyOwner {

        swapFee = fee;
    }

    function setSwapFeePercentageOfSTRM(uint256 _feePerStream)
        external
        onlyOwner
    {

        require(
            _feePerStream < 100000000000000000000,
            "feePercentageInStream: Greater than 100 %"
        );
        feePercentageInStream = _feePerStream;
    }

    function createSwapPair(
        bytes32 bscTxHash,
        address bep20Addr,
        string calldata name,
        string calldata symbol,
        uint8 decimals
    ) external onlyOwner returns (address) {

        require(
            swapMapping2BSC[bep20Addr] == address(0x0),
            "duplicated swap pair"
        );

        BEP20UpgradeableProxy proxyToken = new BEP20UpgradeableProxy(
            gen20Implementation,
            gen20ProxyAdmin,
            ""
        );
        IProxyInitialize token = IProxyInitialize(address(proxyToken));
        token.initialize(name, symbol, decimals, 0, true, address(this));

        swapMapping2BSC[bep20Addr] = address(token);
        swapMappingFrmBSC[address(token)] = bep20Addr;

        emit SwapPairCreated(
            bscTxHash,
            address(token),
            bep20Addr,
            symbol,
            name,
            decimals
        );
        return address(token);
    }

    function fillSwap(
        bytes32 requestSwapTxHash,
        address bep20Addr,
        address toAddress,
        uint256 amount,
        string calldata chain
    ) external onlyOwner returns (bool) {

        require(!filledBSCTx[requestSwapTxHash], "bsc tx filled already");
        address genTokenAddr = swapMapping2BSC[bep20Addr];
        require(genTokenAddr != address(0x0), "no swap pair for this token");
        require(amount > 0, "Amount should be greater than 0");

        ISwap(genTokenAddr).mintTo(amount, toAddress);
        filledBSCTx[requestSwapTxHash] = true;
        emit SwapFilled(
            genTokenAddr,
            requestSwapTxHash,
            toAddress,
            amount,
            chain
        );

        return true;
    }

    function swapToken(
        address gen20Addr,
        uint256 amount,
        string calldata chain
    ) external payable notContract noProxy returns (bool) {

        address bep20Addr = swapMappingFrmBSC[gen20Addr];
        require(bep20Addr != address(0x0), "no swap pair for this token");
        require(msg.value >= swapFee, "swap fee is not enough");
        require(amount > 0, "Amount should be greater than 0");
        require(
            feePercentageInStream < 100000000000000000000,
            "feePercentageInStream: Greater than 100 %"
        );

        uint256 feeAmountInStrm = 0;
        if (feePercentageInStream > 0) {
            feeAmountInStrm = amount.mul(feePercentageInStream);
            feeAmountInStrm = feeAmountInStrm.div(100000000000000000000);
            amount = amount.sub(feeAmountInStrm);
            IERC20(gen20Addr).safeTransferFrom(
                msg.sender,
                feeReceiver,
                feeAmountInStrm
            );
        }

        if (msg.value != 0) {
            owner.transfer(msg.value);
        }
        IERC20(gen20Addr).safeTransferFrom(msg.sender, address(this), amount);
        ISwap(gen20Addr).burn(amount);

        emit SwapStarted(
            gen20Addr,
            bep20Addr,
            msg.sender,
            amount,
            msg.value,
            feeAmountInStrm,
            chain
        );
        return true;
    }
}