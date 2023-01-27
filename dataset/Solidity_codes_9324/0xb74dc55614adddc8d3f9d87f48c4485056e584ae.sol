
pragma solidity >=0.6.0 <0.8.0;

library Create2 {

    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address) {

        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {

        return computeAddress(salt, bytecodeHash, address(this));
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {

        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(uint160(uint256(_data)));
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

pragma solidity >=0.6.0 <0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback () external payable virtual {
        _fallback();
    }

    receive () external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract BeaconProxy is Proxy {

    bytes32 private constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    constructor(address beacon, bytes memory data) public payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _setBeacon(beacon, data);
    }

    function _beacon() internal view virtual returns (address beacon) {

        bytes32 slot = _BEACON_SLOT;
        assembly {
            beacon := sload(slot)
        }
    }

    function _implementation() internal view virtual override returns (address) {

        return IBeacon(_beacon()).implementation();
    }

    function _setBeacon(address beacon, bytes memory data) internal virtual {

        require(
            Address.isContract(beacon),
            "BeaconProxy: beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(beacon).implementation()),
            "BeaconProxy: beacon implementation is not a contract"
        );
        bytes32 slot = _BEACON_SLOT;

        assembly {
            sstore(slot, beacon)
        }

        if (data.length > 0) {
            Address.functionDelegateCall(_implementation(), data, "BeaconProxy: function call failed");
        }
    }
}// Apache-2.0

pragma solidity >=0.6.0 <0.8.0;


interface ProxySetter {

    function getBeacon() external view returns (address);

}

contract ClonableBeaconProxy is BeaconProxy {

    constructor() public BeaconProxy(ProxySetter(msg.sender).getBeacon(), "") {}
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library Create2Upgradeable {

    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address) {

        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {

        return computeAddress(salt, bytecodeHash, address(this));
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {

        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(uint160(uint256(_data)));
    }
}// Apache-2.0


pragma solidity ^0.6.11;


abstract contract TokenAddressHandler {
    mapping(address => address) public customL2Token;

    function isCustomToken(address l1Token) public view returns (bool) {
        return customL2Token[l1Token] != address(0);
    }

    function getCreate2Salt(address l1Token, address l2TemplateERC20)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(l1Token, l2TemplateERC20));
    }

    function calculateL2ERC20TokenAddress(
        address l1Token,
        address l2TemplateERC20,
        address l2ArbTokenBridgeAddress,
        bytes32 cloneableProxyHash
    ) internal view returns (address) {
        bytes32 salt = getCreate2Salt(l1Token, l2TemplateERC20);
        return Create2Upgradeable.computeAddress(salt, cloneableProxyHash, l2ArbTokenBridgeAddress);
    }

    function calculateL2TokenAddress(
        address l1Token,
        address l2TemplateERC20,
        address l2ArbTokenBridgeAddress,
        bytes32 cloneableProxyHash
    ) internal view returns (address) {
        address customTokenAddress = customL2Token[l1Token];

        if (customTokenAddress != address(0)) {
            return customTokenAddress;
        } else {
            return
                calculateL2ERC20TokenAddress(
                    l1Token,
                    l2TemplateERC20,
                    l2ArbTokenBridgeAddress,
                    cloneableProxyHash
                );
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;


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
}// Apache-2.0


pragma solidity ^0.6.11;

interface IEthERC20Bridge {
    event ActivateCustomToken(uint256 indexed seqNum, address indexed l1Address, address l2Address);

    event DeployToken(uint256 indexed seqNum, address indexed l1Address);

    event WithdrawRedirected(
        address indexed user,
        address indexed to,
        address erc20,
        uint256 amount,
        uint256 indexed exitNum,
        bool madeExternalCall
    );

    event WithdrawExecuted(
        address indexed initialDestination,
        address indexed destination,
        address erc20,
        uint256 amount,
        uint256 indexed exitNum
    );

    event DepositToken(
        address indexed destination,
        address sender,
        uint256 indexed seqNum,
        uint256 value,
        address indexed tokenAddress
    );

    function hasTriedDeploy(address erc20) external view returns (bool);

    function registerCustomL2Token(
        address l2CustomTokenAddress,
        uint256 maxSubmissionCost,
        uint256 maxGas,
        uint256 gasPriceBid,
        address refundAddress
    ) external payable returns (uint256);

    function withdrawFromL2(
        uint256 exitNum,
        address erc20,
        address initialDestination,
        uint256 amount
    ) external;

    function deposit(
        address erc20,
        address destination,
        uint256 amount,
        uint256 maxSubmissionCost,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes calldata callHookData
    ) external payable returns (uint256 seqNum, uint256 depositCalldataLength);

    function getDepositCalldata(
        address erc20,
        address destination,
        address sender,
        uint256 amount,
        bytes calldata callHookData
    ) external view returns (bool isDeployed, bytes memory depositCalldata);

    function transferExitAndCall(
        address initialDestination,
        address erc20,
        uint256 amount,
        uint256 exitNum,
        address to,
        bytes calldata data
    ) external;

    function calculateL2TokenAddress(address erc20) external view returns (address);
}

interface IExitTransferCallReceiver {
    function onExitTransfered(
        address sender,
        uint256 amount,
        address erc20,
        bytes calldata data
    ) external returns (bytes4);
}// Apache-2.0


pragma solidity ^0.6.11;


interface IArbTokenBridge {
    event MintAndCallTriggered(
        bool success,
        address indexed sender,
        address indexed dest,
        uint256 amount,
        bytes callHookData
    );

    event WithdrawToken(
        uint256 withdrawalId,
        address indexed l1Address,
        uint256 amount,
        address indexed destination,
        uint256 indexed exitNum
    );

    event TokenCreated(address indexed l1Address, address indexed l2Address);

    event CustomTokenRegistered(address indexed l1Address, address indexed l2Address);

    event TokenMinted(
        address l1Address,
        address indexed l2Address,
        address indexed sender,
        address indexed dest,
        uint256 amount,
        bool usedCallHook
    );

    event TokenMigrated(address indexed l1Address, address indexed account, uint256 amount);


    function mintFromL1(
        address l1ERC20,
        address sender,
        address dest,
        uint256 amount,
        bytes calldata deployData,
        bytes calldata callHookData
    ) external;

    function customTokenRegistered(address l1Address, address l2Address) external;


    function migrate(
        address l1ERC20,
        address sender,
        address destination,
        uint256 amount
    ) external;

    function withdraw(
        address l1ERC20,
        address sender,
        address destination,
        uint256 amount
    ) external returns (uint256);

    function calculateL2TokenAddress(address l1ERC20) external view returns (address);
}// Apache-2.0


pragma solidity ^0.6.11;

interface IBridge {
    event MessageDelivered(
        uint256 indexed messageIndex,
        bytes32 indexed beforeInboxAcc,
        address inbox,
        uint8 kind,
        address sender,
        bytes32 messageDataHash
    );

    function deliverMessageToInbox(
        uint8 kind,
        address sender,
        bytes32 messageDataHash
    ) external payable returns (uint256);

    function executeCall(
        address destAddr,
        uint256 amount,
        bytes calldata data
    ) external returns (bool success, bytes memory returnData);

    function setInbox(address inbox, bool enabled) external;

    function setOutbox(address inbox, bool enabled) external;


    function activeOutbox() external view returns (address);

    function allowedInboxes(address inbox) external view returns (bool);

    function allowedOutboxes(address outbox) external view returns (bool);

    function inboxAccs(uint256 index) external view returns (bytes32);

    function messageCount() external view returns (uint256);
}// Apache-2.0


pragma solidity ^0.6.11;

interface IMessageProvider {
    event InboxMessageDelivered(uint256 indexed messageNum, bytes data);

    event InboxMessageDeliveredFromOrigin(uint256 indexed messageNum);
}// Apache-2.0


pragma solidity ^0.6.11;


interface IInbox is IMessageProvider {
    function sendL2Message(bytes calldata messageData) external returns (uint256);

    function sendUnsignedTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        uint256 nonce,
        address destAddr,
        uint256 amount,
        bytes calldata data
    ) external returns (uint256);

    function sendContractTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        address destAddr,
        uint256 amount,
        bytes calldata data
    ) external returns (uint256);

    function sendL1FundedUnsignedTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        uint256 nonce,
        address destAddr,
        bytes calldata data
    ) external payable returns (uint256);

    function sendL1FundedContractTransaction(
        uint256 maxGas,
        uint256 gasPriceBid,
        address destAddr,
        bytes calldata data
    ) external payable returns (uint256);

    function createRetryableTicket(
        address destAddr,
        uint256 arbTxCallValue,
        uint256 maxSubmissionCost,
        address submissionRefundAddress,
        address valueRefundAddress,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes calldata data
    ) external payable returns (uint256);

    function depositEth(uint256 maxSubmissionCost) external payable returns (uint256);

    function bridge() external view returns (IBridge);
}// Apache-2.0


pragma solidity ^0.6.11;

interface IOutbox {
    event OutboxEntryCreated(
        uint256 indexed batchNum,
        uint256 outboxIndex,
        bytes32 outputRoot,
        uint256 numInBatch
    );
    event OutBoxTransactionExecuted(
        address indexed destAddr,
        address indexed l2Sender,
        uint256 indexed outboxIndex,
        uint256 transactionIndex
    );

    function l2ToL1Sender() external view returns (address);

    function l2ToL1Block() external view returns (uint256);

    function l2ToL1EthBlock() external view returns (uint256);

    function l2ToL1Timestamp() external view returns (uint256);

    function processOutgoingMessages(bytes calldata sendsData, uint256[] calldata sendLengths)
        external;
}pragma solidity >=0.4.21 <0.7.0;

interface ArbSys {
    function arbOSVersion() external pure returns (uint);

    function arbChainID() external view returns(uint);

    function arbBlockNumber() external view returns (uint);

    function withdrawEth(address destination) external payable returns(uint);

    function sendTxToL1(address destination, bytes calldata calldataForL1) external payable returns(uint);

    function getTransactionCount(address account) external view returns(uint256);

    function getStorageAt(address account, uint256 index) external view returns (uint256);

    function isTopLevelCall() external view returns (bool);

    event EthWithdrawal(address indexed destAddr, uint amount);

    event L2ToL1Transaction(address caller, address indexed destination, uint indexed uniqueId,
                            uint indexed batchNumber, uint indexInBatch,
                            uint arbBlockNum, uint ethBlockNum, uint timestamp,
                            uint callvalue, bytes data);
}// Apache-2.0


pragma solidity ^0.6.11;


contract BuddyDeployer {
    constructor() public {}

    event Deployed(address indexed _sender, address indexed _contract, uint256 indexed withdrawalId, bool _success);

    function executeBuddyDeploy(bytes memory contractInitCode) external payable {
        require(tx.origin == msg.sender, "Function cant be called by L2 contract");

        address user = msg.sender;
        uint256 salt = uint256(user);
        address addr;
        bool success;
        assembly {
            addr := create2(
                callvalue(), // wei sent in call
                add(contractInitCode, 0x20), // skip 32 bytes from rlp encoding length of bytearray
                mload(contractInitCode),
                salt
            )
            success := not(iszero(extcodesize(addr)))
        }

        bytes memory calldataForL1 =
            abi.encodeWithSelector(L1Buddy.finalizeBuddyDeploy.selector, success);
        uint256 withdrawalId = ArbSys(100).sendTxToL1(user, calldataForL1);
        emit Deployed(user, addr, withdrawalId, success);
    }
}// Apache-2.0


pragma solidity ^0.6.11;

library BuddyUtil {
    function calculateL2Address(
        address _deployer,
        address _l1Address,
        bytes32 _codeHash
    )
        internal
        pure
        returns (address)
    {
        bytes32 salt = bytes32(uint256(_l1Address));
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                _deployer,
                salt,
                _codeHash
            )
        );
        return address(uint160(uint256(hash)));
    }
}// Apache-2.0


pragma solidity ^0.6.11;



abstract contract L1Buddy {
    enum L2Connection {
        Null, // 0
        Initiated, // 1
        Complete // 2
    }

    L2Connection public l2Connection;
    BuddyDeployer public l2Deployer;
    IInbox public inbox;
    address public l2Buddy;
    bytes32 public codeHash;

    event DeployBuddyContract(uint256 indexed seqNum, address l2Address);
    modifier onlyIfConnected {
        require(l2Connection == L2Connection.Complete, "Not connected");
        _;
    }

    modifier onlyL2Buddy {
        require(l2Buddy != address(0), "l2 buddy not set");
        IOutbox outbox = IOutbox(inbox.bridge().activeOutbox());
        require(l2Buddy == outbox.l2ToL1Sender(), "Not from l2 buddy");
        _;
    }

    constructor(address _inbox, address _l2Deployer) public {
        l2Connection = L2Connection.Null;
        inbox = IInbox(_inbox);
        l2Deployer = BuddyDeployer(_l2Deployer);
    }

    function initiateBuddyDeploy(
        uint256 maxSubmissionCost,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes memory contractInitCode
    ) public payable returns (uint256) {
        require(l2Connection != L2Connection.Complete, "already connected");
        require(
            codeHash == bytes32(0) || codeHash == keccak256(contractInitCode),
            "Only retry if same deploy code"
        );
        bytes memory data =
            abi.encodeWithSelector(BuddyDeployer.executeBuddyDeploy.selector, contractInitCode);

        codeHash = keccak256(contractInitCode);
        l2Buddy = BuddyUtil.calculateL2Address(address(l2Deployer), address(this), codeHash);
        l2Connection = L2Connection.Initiated;
        uint256 seqNum =
            inbox.createRetryableTicket{ value: msg.value }(
                address(l2Deployer),
                0,
                maxSubmissionCost,
                msg.sender,
                msg.sender,
                maxGas,
                gasPriceBid,
                data
            );
        emit DeployBuddyContract(seqNum, l2Buddy);
        return seqNum;
    }

    function finalizeBuddyDeploy(bool success) external {
        require(l2Connection == L2Connection.Initiated, "Connection not in initiated state");
        IOutbox outbox = IOutbox(inbox.bridge().activeOutbox());
        require(outbox.l2ToL1Sender() == address(l2Deployer), "Wrong L2 address triggering outbox");

        if (success) {
            handleDeploySuccess();
        } else {
            handleDeployFail();
        }
    }

    function handleDeploySuccess() internal virtual {
        l2Connection = L2Connection.Complete;
    }

    function handleDeployFail() internal virtual;
}// Apache-2.0


pragma solidity ^0.6.11;

abstract contract WhitelistConsumer {
    address public whitelist;

    event WhitelistSourceUpdated(address newSource);

    modifier onlyWhitelisted {
        if (whitelist != address(0)) {
            require(Whitelist(whitelist).isAllowed(msg.sender), "NOT_WHITELISTED");
        }
        _;
    }

    function updateWhitelistSource(address newSource) external {
        require(msg.sender == whitelist, "NOT_FROM_LIST");
        whitelist = newSource;
        emit WhitelistSourceUpdated(newSource);
    }
}

contract Whitelist {
    address public owner;
    mapping(address => bool) public isAllowed;

    event OwnerUpdated(address newOwner);
    event WhitelistUpgraded(address newWhitelist, address[] targets);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "ONLY_OWNER");
        _;
    }

    function setOwner(address newOwner) external onlyOwner {
        owner = newOwner;
        emit OwnerUpdated(newOwner);
    }

    function setWhitelist(address[] memory user, bool[] memory val) external onlyOwner {
        require(user.length == val.length, "INVALID_INPUT");

        for (uint256 i = 0; i < user.length; i++) {
            isAllowed[user[i]] = val[i];
        }
    }

    function triggerConsumers(address newWhitelist, address[] memory targets) external onlyOwner {
        for (uint256 i = 0; i < targets.length; i++) {
            WhitelistConsumer(targets[i]).updateWhitelistSource(newWhitelist);
        }
        emit WhitelistUpgraded(newWhitelist, targets);
    }
}// Apache-2.0


pragma solidity ^0.6.11;







contract EthERC20Bridge is IEthERC20Bridge, WhitelistConsumer, TokenAddressHandler {
    using SafeERC20 for IERC20;
    using Address for address;

    address internal constant USED_ADDRESS = address(0x01);

    mapping(bytes32 => address) public redirectedExits;

    address private l2TemplateERC20;
    bytes32 private cloneableProxyHash;

    address public l2ArbTokenBridgeAddress;
    IInbox public inbox;
    address public owner;

    mapping(address => bool) public override hasTriedDeploy;

    modifier onlyL2Address {
        IOutbox outbox = IOutbox(inbox.bridge().activeOutbox());
        require(l2ArbTokenBridgeAddress == outbox.l2ToL1Sender(), "Not from l2 buddy");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "ONLY_OWNER");
        _;
    }

    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

    function initialize(
        address _inbox,
        address _l2TemplateERC20,
        address _l2ArbTokenBridgeAddress,
        address _owner,
        address _whitelist
    ) external payable {
        require(address(l2TemplateERC20) == address(0), "already initialized");
        l2TemplateERC20 = _l2TemplateERC20;

        l2ArbTokenBridgeAddress = _l2ArbTokenBridgeAddress;
        inbox = IInbox(_inbox);
        cloneableProxyHash = keccak256(type(ClonableBeaconProxy).creationCode);
        owner = _owner;
        WhitelistConsumer.whitelist = _whitelist;
    }

    function _registerCustomL2Token(
        address l1CustomTokenAddress,
        address l2CustomTokenAddress,
        uint256 maxSubmissionCost,
        uint256 maxGas,
        uint256 gasPriceBid,
        address refundAddress,
        uint256 value
    ) internal returns (uint256) {
        require(
            !TokenAddressHandler.isCustomToken(l1CustomTokenAddress) ||
                TokenAddressHandler.customL2Token[l1CustomTokenAddress] == l2CustomTokenAddress,
            "Cannot register a different custom token address"
        );
        TokenAddressHandler.customL2Token[l1CustomTokenAddress] = l2CustomTokenAddress;

        bytes memory data =
            abi.encodeWithSelector(
                IArbTokenBridge.customTokenRegistered.selector,
                l1CustomTokenAddress,
                l2CustomTokenAddress
            );
        uint256 seqNum =
            inbox.createRetryableTicket{ value: value }(
                l2ArbTokenBridgeAddress,
                0,
                maxSubmissionCost,
                refundAddress,
                refundAddress,
                maxGas,
                gasPriceBid,
                data
            );
        emit ActivateCustomToken(seqNum, l1CustomTokenAddress, l2CustomTokenAddress);
        return seqNum;
    }

    function registerCustomL2Token(
        address l2CustomTokenAddress,
        uint256 maxSubmissionCost,
        uint256 maxGas,
        uint256 gasPriceBid,
        address refundAddress
    ) external payable override onlyWhitelisted returns (uint256) {
        return
            _registerCustomL2Token(
                msg.sender,
                l2CustomTokenAddress,
                maxSubmissionCost,
                maxGas,
                gasPriceBid,
                refundAddress,
                msg.value
            );
    }

    function forceRegisterCustomL2Token(
        address l1CustomTokenAddress,
        address l2CustomTokenAddress,
        uint256 maxSubmissionCost,
        uint256 maxGas,
        uint256 gasPriceBid,
        address refundAddress
    ) external payable onlyOwner returns (uint256) {
        return
            _registerCustomL2Token(
                l1CustomTokenAddress,
                l2CustomTokenAddress,
                maxSubmissionCost,
                maxGas,
                gasPriceBid,
                refundAddress,
                msg.value
            );
    }

    function transferExitAndCall(
        address initialDestination,
        address erc20,
        uint256 amount,
        uint256 exitNum,
        address to,
        bytes calldata data
    ) external override onlyWhitelisted {
        bytes32 withdrawData = encodeWithdrawal(exitNum, initialDestination, erc20, amount);
        address redirectedAddress = redirectedExits[withdrawData];
        require(redirectedAddress != USED_ADDRESS, "ALREADY_EXITED");

        address expectedSender =
            redirectedAddress == address(0) ? initialDestination : redirectedAddress;
        require(msg.sender == expectedSender, "EXPECTED_SENDER");

        redirectedExits[withdrawData] = to;

        if (data.length > 0) {
            require(to.isContract(), "TO_NOT_CONTRACT");
            bytes4 res =
                IExitTransferCallReceiver(to).onExitTransfered(expectedSender, amount, erc20, data);
            require(
                res == IExitTransferCallReceiver.onExitTransfered.selector,
                "EXTERNAL_CALL_FAIL"
            );
        }

        emit WithdrawRedirected(expectedSender, to, erc20, amount, exitNum, data.length > 0);
    }

    function withdrawFromL2(
        uint256 exitNum,
        address erc20,
        address initialDestination,
        uint256 amount
    ) external override onlyL2Address {
        bytes32 withdrawData = encodeWithdrawal(exitNum, initialDestination, erc20, amount);
        address exitAddress = redirectedExits[withdrawData];
        redirectedExits[withdrawData] = USED_ADDRESS;
        address dest = exitAddress != address(0) ? exitAddress : initialDestination;
        IERC20(erc20).safeTransfer(dest, amount);

        emit WithdrawExecuted(initialDestination, dest, erc20, amount, exitNum);
    }

    function callStatic(address targetContract, bytes4 targetFunction)
        internal
        view
        returns (bytes memory)
    {
        (bool success, bytes memory res) =
            targetContract.staticcall(abi.encodeWithSelector(targetFunction));
        return res;
    }

    function getDepositCalldata(
        address erc20,
        address sender,
        address destination,
        uint256 amount,
        bytes calldata callHookData
    ) public view override returns (bool isDeployed, bytes memory depositCalldata) {
        isDeployed = hasTriedDeploy[erc20];

        bytes memory deployData = "";
        if (!isDeployed && !TokenAddressHandler.isCustomToken(erc20)) {
            deployData = abi.encode(
                callStatic(erc20, ERC20.name.selector),
                callStatic(erc20, ERC20.symbol.selector),
                callStatic(erc20, ERC20.decimals.selector)
            );
        }

        depositCalldata = abi.encodeWithSelector(
            IArbTokenBridge.mintFromL1.selector,
            erc20,
            sender,
            destination,
            amount,
            deployData,
            callHookData
        );

        return (isDeployed, depositCalldata);
    }

    function deposit(
        address erc20,
        address destination,
        uint256 amount,
        uint256 maxSubmissionCost,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes calldata callHookData
    )
        external
        payable
        override
        onlyWhitelisted
        returns (uint256 seqNum, uint256 depositCalldataLength)
    {
        IERC20(erc20).safeTransferFrom(msg.sender, address(this), amount);

        bytes memory depositCalldata;
        {
            bool isDeployed;
            (isDeployed, depositCalldata) = getDepositCalldata(
                erc20,
                msg.sender,
                destination,
                amount,
                callHookData
            );

            if (!isDeployed) {
                hasTriedDeploy[erc20] = true;
            }
        }
        seqNum = inbox.createRetryableTicket{ value: msg.value }(
            l2ArbTokenBridgeAddress,
            0,
            maxSubmissionCost,
            msg.sender,
            msg.sender,
            maxGas,
            gasPriceBid,
            depositCalldata
        );

        emit DepositToken(destination, msg.sender, seqNum, amount, erc20);
        return (seqNum, depositCalldata.length);
    }

    function encodeWithdrawal(
        uint256 exitNum,
        address initialDestination,
        address erc20,
        uint256 amount
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(exitNum, initialDestination, erc20, amount));
    }

    function calculateL2TokenAddress(address erc20) public view override returns (address) {
        return
            TokenAddressHandler.calculateL2TokenAddress(
                erc20,
                l2TemplateERC20,
                l2ArbTokenBridgeAddress,
                cloneableProxyHash
            );
    }
}