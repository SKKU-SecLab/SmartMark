pragma solidity >=0.5.0 <0.7.0;


contract Enum {

    enum Operation {
        Call,
        DelegateCall
    }
}
pragma solidity >=0.5.0 <0.7.0;

interface IProxy {

    function masterCopy() external view returns (address);

}

contract GnosisSafeProxy {


    address internal masterCopy;

    constructor(address _masterCopy)
        public
    {
        require(_masterCopy != address(0), "Invalid master copy address provided");
        masterCopy = _masterCopy;
    }

    function ()
        external
        payable
    {
        assembly {
            let masterCopy := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
            if eq(calldataload(0), 0xa619486e00000000000000000000000000000000000000000000000000000000) {
                mstore(0, masterCopy)
                return(0, 0x20)
            }
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(gas, masterCopy, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            if eq(success, 0) { revert(0, returndatasize()) }
            return(0, returndatasize())
        }
    }
}
pragma solidity >=0.5.0 <0.7.0;


contract SelfAuthorized {

    modifier authorized() {

        require(msg.sender == address(this), "Method can only be called from this contract");
        _;
    }
}
pragma solidity >=0.5.0 <0.7.0;


contract Executor {


    function execute(address to, uint256 value, bytes memory data, Enum.Operation operation, uint256 txGas)
        internal
        returns (bool success)
    {

        if (operation == Enum.Operation.Call)
            success = executeCall(to, value, data, txGas);
        else if (operation == Enum.Operation.DelegateCall)
            success = executeDelegateCall(to, data, txGas);
        else
            success = false;
    }

    function executeCall(address to, uint256 value, bytes memory data, uint256 txGas)
        internal
        returns (bool success)
    {

        assembly {
            success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)
        }
    }

    function executeDelegateCall(address to, bytes memory data, uint256 txGas)
        internal
        returns (bool success)
    {

        assembly {
            success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)
        }
    }
}
pragma solidity >=0.5.0 <0.7.0;


contract MasterCopy is SelfAuthorized {


    event ChangedMasterCopy(address masterCopy);

    address private masterCopy;

    function changeMasterCopy(address _masterCopy)
        public
        authorized
    {

        require(_masterCopy != address(0), "Invalid master copy address provided");
        masterCopy = _masterCopy;
        emit ChangedMasterCopy(_masterCopy);
    }
}
pragma solidity >=0.5.0 <0.7.0;


contract Module is MasterCopy {


    ModuleManager public manager;

    modifier authorized() {

        require(msg.sender == address(manager), "Method can only be called from manager");
        _;
    }

    function setManager()
        internal
    {

        require(address(manager) == address(0), "Manager has already been set");
        manager = ModuleManager(msg.sender);
    }
}
pragma solidity >=0.5.0 <0.7.0;


contract ModuleManager is SelfAuthorized, Executor {


    event EnabledModule(Module module);
    event DisabledModule(Module module);
    event ExecutionFromModuleSuccess(address indexed module);
    event ExecutionFromModuleFailure(address indexed module);

    address internal constant SENTINEL_MODULES = address(0x1);

    mapping (address => address) internal modules;

    function setupModules(address to, bytes memory data)
        internal
    {

        require(modules[SENTINEL_MODULES] == address(0), "Modules have already been initialized");
        modules[SENTINEL_MODULES] = SENTINEL_MODULES;
        if (to != address(0))
            require(executeDelegateCall(to, data, gasleft()), "Could not finish initialization");
    }

    function enableModule(Module module)
        public
        authorized
    {

        require(address(module) != address(0) && address(module) != SENTINEL_MODULES, "Invalid module address provided");
        require(modules[address(module)] == address(0), "Module has already been added");
        modules[address(module)] = modules[SENTINEL_MODULES];
        modules[SENTINEL_MODULES] = address(module);
        emit EnabledModule(module);
    }

    function disableModule(Module prevModule, Module module)
        public
        authorized
    {

        require(address(module) != address(0) && address(module) != SENTINEL_MODULES, "Invalid module address provided");
        require(modules[address(prevModule)] == address(module), "Invalid prevModule, module pair provided");
        modules[address(prevModule)] = modules[address(module)];
        modules[address(module)] = address(0);
        emit DisabledModule(module);
    }

    function execTransactionFromModule(address to, uint256 value, bytes memory data, Enum.Operation operation)
        public
        returns (bool success)
    {

        require(msg.sender != SENTINEL_MODULES && modules[msg.sender] != address(0), "Method can only be called from an enabled module");
        success = execute(to, value, data, operation, gasleft());
        if (success) emit ExecutionFromModuleSuccess(msg.sender);
        else emit ExecutionFromModuleFailure(msg.sender);
    }

    function execTransactionFromModuleReturnData(address to, uint256 value, bytes memory data, Enum.Operation operation)
        public
        returns (bool success, bytes memory returnData)
    {

        success = execTransactionFromModule(to, value, data, operation);
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, add(returndatasize(), 0x20)))
            mstore(ptr, returndatasize())
            returndatacopy(add(ptr, 0x20), 0, returndatasize())
            returnData := ptr
        }
    }

    function isModuleEnabled(Module module)
        public
        view
        returns (bool)
    {

        return SENTINEL_MODULES != address(module) && modules[address(module)] != address(0);
    }

    function getModules()
        public
        view
        returns (address[] memory)
    {

        (address[] memory array,) = getModulesPaginated(SENTINEL_MODULES, 10);
        return array;
    }

    function getModulesPaginated(address start, uint256 pageSize)
        public
        view
        returns (address[] memory array, address next)
    {

        array = new address[](pageSize);

        uint256 moduleCount = 0;
        address currentModule = modules[start];
        while(currentModule != address(0x0) && currentModule != SENTINEL_MODULES && moduleCount < pageSize) {
            array[moduleCount] = currentModule;
            currentModule = modules[currentModule];
            moduleCount++;
        }
        next = currentModule;
        assembly {
            mstore(array, moduleCount)
        }
    }
}
pragma solidity >=0.5.0 <0.7.0;

contract OwnerManager is SelfAuthorized {


    event AddedOwner(address owner);
    event RemovedOwner(address owner);
    event ChangedThreshold(uint256 threshold);

    address internal constant SENTINEL_OWNERS = address(0x1);

    mapping(address => address) internal owners;
    uint256 ownerCount;
    uint256 internal threshold;

    function setupOwners(address[] memory _owners, uint256 _threshold)
        internal
    {

        require(threshold == 0, "Owners have already been setup");
        require(_threshold <= _owners.length, "Threshold cannot exceed owner count");
        require(_threshold >= 1, "Threshold needs to be greater than 0");
        address currentOwner = SENTINEL_OWNERS;
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0) && owner != SENTINEL_OWNERS, "Invalid owner address provided");
            require(owners[owner] == address(0), "Duplicate owner address provided");
            owners[currentOwner] = owner;
            currentOwner = owner;
        }
        owners[currentOwner] = SENTINEL_OWNERS;
        ownerCount = _owners.length;
        threshold = _threshold;
    }

    function addOwnerWithThreshold(address owner, uint256 _threshold)
        public
        authorized
    {

        require(owner != address(0) && owner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[owner] == address(0), "Address is already an owner");
        owners[owner] = owners[SENTINEL_OWNERS];
        owners[SENTINEL_OWNERS] = owner;
        ownerCount++;
        emit AddedOwner(owner);
        if (threshold != _threshold)
            changeThreshold(_threshold);
    }

    function removeOwner(address prevOwner, address owner, uint256 _threshold)
        public
        authorized
    {

        require(ownerCount - 1 >= _threshold, "New owner count needs to be larger than new threshold");
        require(owner != address(0) && owner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[prevOwner] == owner, "Invalid prevOwner, owner pair provided");
        owners[prevOwner] = owners[owner];
        owners[owner] = address(0);
        ownerCount--;
        emit RemovedOwner(owner);
        if (threshold != _threshold)
            changeThreshold(_threshold);
    }

    function swapOwner(address prevOwner, address oldOwner, address newOwner)
        public
        authorized
    {

        require(newOwner != address(0) && newOwner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[newOwner] == address(0), "Address is already an owner");
        require(oldOwner != address(0) && oldOwner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[prevOwner] == oldOwner, "Invalid prevOwner, owner pair provided");
        owners[newOwner] = owners[oldOwner];
        owners[prevOwner] = newOwner;
        owners[oldOwner] = address(0);
        emit RemovedOwner(oldOwner);
        emit AddedOwner(newOwner);
    }

    function changeThreshold(uint256 _threshold)
        public
        authorized
    {

        require(_threshold <= ownerCount, "Threshold cannot exceed owner count");
        require(_threshold >= 1, "Threshold needs to be greater than 0");
        threshold = _threshold;
        emit ChangedThreshold(threshold);
    }

    function getThreshold()
        public
        view
        returns (uint256)
    {

        return threshold;
    }

    function isOwner(address owner)
        public
        view
        returns (bool)
    {

        return owner != SENTINEL_OWNERS && owners[owner] != address(0);
    }

    function getOwners()
        public
        view
        returns (address[] memory)
    {

        address[] memory array = new address[](ownerCount);

        uint256 index = 0;
        address currentOwner = owners[SENTINEL_OWNERS];
        while(currentOwner != SENTINEL_OWNERS) {
            array[index] = currentOwner;
            currentOwner = owners[currentOwner];
            index ++;
        }
        return array;
    }
}
pragma solidity >=0.5.0 <0.7.0;


contract FallbackManager is SelfAuthorized {


    bytes32 internal constant FALLBACK_HANDLER_STORAGE_SLOT = 0x6c9a6c4a39284e37ed1cf53d337577d14212a4870fb976a4366c693b939918d5;

    function internalSetFallbackHandler(address handler) internal {

        bytes32 slot = FALLBACK_HANDLER_STORAGE_SLOT;
        assembly {
            sstore(slot, handler)
        }
    }

    function setFallbackHandler(address handler)
        public
        authorized
    {

        internalSetFallbackHandler(handler);
    }

    function ()
        external
        payable
    {
        if (msg.value > 0 || msg.data.length == 0) {
            return;
        }
        bytes32 slot = FALLBACK_HANDLER_STORAGE_SLOT;
        address handler;
        assembly {
            handler := sload(slot)
        }

        if (handler != address(0)) {
            assembly {
                calldatacopy(0, 0, calldatasize())
                let success := call(gas, handler, 0, 0, calldatasize(), 0, 0)
                returndatacopy(0, 0, returndatasize())
                if eq(success, 0) { revert(0, returndatasize()) }
                return(0, returndatasize())
            }
        }
    }
}pragma solidity >=0.5.0 <0.7.0;


contract SignatureDecoder {

    
    function recoverKey (
        bytes32 messageHash,
        bytes memory messageSignature,
        uint256 pos
    )
        internal
        pure
        returns (address)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = signatureSplit(messageSignature, pos);
        return ecrecover(messageHash, v, r, s);
    }

    function signatureSplit(bytes memory signatures, uint256 pos)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {

        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }
}
pragma solidity >=0.5.0 <0.7.0;


contract SecuredTokenTransfer {


    function transferToken (
        address token,
        address receiver,
        uint256 amount
    )
        internal
        returns (bool transferred)
    {
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", receiver, amount);
        assembly {
            let success := call(sub(gas, 10000), token, 0, add(data, 0x20), mload(data), 0, 0)
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, returndatasize()))
            returndatacopy(ptr, 0, returndatasize())
            switch returndatasize()
            case 0 { transferred := success }
            case 0x20 { transferred := iszero(or(iszero(success), iszero(mload(ptr)))) }
            default { transferred := 0 }
        }
    }
}
pragma solidity >=0.5.0 <0.7.0;

contract ISignatureValidatorConstants {

    bytes4 constant internal EIP1271_MAGIC_VALUE = 0x20c13b0b;
}

contract ISignatureValidator is ISignatureValidatorConstants {


    function isValidSignature(
        bytes memory _data,
        bytes memory _signature)
        public
        view
        returns (bytes4);

}pragma solidity >=0.5.0 <0.7.0;

library GnosisSafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }


  function max(uint256 a, uint256 b) internal pure returns (uint256) {

    return a >= b ? a : b;
  }
}pragma solidity >=0.5.0 <0.7.0;

contract GnosisSafe
    is MasterCopy, ModuleManager, OwnerManager, SignatureDecoder, SecuredTokenTransfer, ISignatureValidatorConstants, FallbackManager {


    using GnosisSafeMath for uint256;

    string public constant NAME = "Gnosis Safe";
    string public constant VERSION = "1.2.0";

    bytes32 private constant DOMAIN_SEPARATOR_TYPEHASH = 0x035aff83d86937d35b32e04f0ddc6ff469290eef2f1b692d8a815c89404d4749;

    bytes32 private constant SAFE_TX_TYPEHASH = 0xbb8310d486368db6bd6f849402fdd73ad53d316b5a4b2644ad6efe0f941286d8;

    bytes32 private constant SAFE_MSG_TYPEHASH = 0x60b3cbf8b4a223d68d641b3b6ddf9a298e7f33710cf3d3a9d1146b5a6150fbca;

    event ApproveHash(
        bytes32 indexed approvedHash,
        address indexed owner
    );
    event SignMsg(
        bytes32 indexed msgHash
    );
    event ExecutionFailure(
        bytes32 txHash, uint256 payment
    );
    event ExecutionSuccess(
        bytes32 txHash, uint256 payment
    );

    uint256 public nonce;
    bytes32 public domainSeparator;
    mapping(bytes32 => uint256) public signedMessages;
    mapping(address => mapping(bytes32 => uint256)) public approvedHashes;

    constructor() public {
        threshold = 1;
    }

    function setup(
        address[] calldata _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    )
        external
    {

        require(domainSeparator == 0, "Domain Separator already set!");
        domainSeparator = keccak256(abi.encode(DOMAIN_SEPARATOR_TYPEHASH, this));
        setupOwners(_owners, _threshold);
        if (fallbackHandler != address(0)) internalSetFallbackHandler(fallbackHandler);
        setupModules(to, data);

        if (payment > 0) {
            handlePayment(payment, 0, 1, paymentToken, paymentReceiver);
        }
    }

    function execTransaction(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes calldata signatures
    )
        external
        payable
        returns (bool success)
    {

        bytes32 txHash;
        {
            bytes memory txHashData = encodeTransactionData(
                to, value, data, operation, // Transaction info
                safeTxGas, baseGas, gasPrice, gasToken, refundReceiver, // Payment info
                nonce
            );
            nonce++;
            txHash = keccak256(txHashData);
            checkSignatures(txHash, txHashData, signatures, true);
        }
        require(gasleft() >= (safeTxGas * 64 / 63).max(safeTxGas + 2500) + 500, "Not enough gas to execute safe transaction");
        {
            uint256 gasUsed = gasleft();
            success = execute(to, value, data, operation, gasPrice == 0 ? (gasleft() - 2500) : safeTxGas);
            gasUsed = gasUsed.sub(gasleft());
            uint256 payment = 0;
            if (gasPrice > 0) {
                payment = handlePayment(gasUsed, baseGas, gasPrice, gasToken, refundReceiver);
            }
            if (success) emit ExecutionSuccess(txHash, payment);
            else emit ExecutionFailure(txHash, payment);
        }
    }

    function handlePayment(
        uint256 gasUsed,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver
    )
        private
        returns (uint256 payment)
    {

        address payable receiver = refundReceiver == address(0) ? tx.origin : refundReceiver;
        if (gasToken == address(0)) {
            payment = gasUsed.add(baseGas).mul(gasPrice < tx.gasprice ? gasPrice : tx.gasprice);
            require(receiver.send(payment), "Could not pay gas costs with ether");
        } else {
            payment = gasUsed.add(baseGas).mul(gasPrice);
            require(transferToken(gasToken, receiver, payment), "Could not pay gas costs with token");
        }
    }

    function checkSignatures(bytes32 dataHash, bytes memory data, bytes memory signatures, bool consumeHash)
        internal
    {

        uint256 _threshold = threshold;
        require(_threshold > 0, "Threshold needs to be defined!");
        require(signatures.length >= _threshold.mul(65), "Signatures data too short");
        address lastOwner = address(0);
        address currentOwner;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 i;
        for (i = 0; i < _threshold; i++) {
            (v, r, s) = signatureSplit(signatures, i);
            if (v == 0) {
                currentOwner = address(uint256(r));

                require(uint256(s) >= _threshold.mul(65), "Invalid contract signature location: inside static part");

                require(uint256(s).add(32) <= signatures.length, "Invalid contract signature location: length not present");

                uint256 contractSignatureLen;
                assembly {
                    contractSignatureLen := mload(add(add(signatures, s), 0x20))
                }
                require(uint256(s).add(32).add(contractSignatureLen) <= signatures.length, "Invalid contract signature location: data not complete");

                bytes memory contractSignature;
                assembly {
                    contractSignature := add(add(signatures, s), 0x20)
                }
                require(ISignatureValidator(currentOwner).isValidSignature(data, contractSignature) == EIP1271_MAGIC_VALUE, "Invalid contract signature provided");
            } else if (v == 1) {
                currentOwner = address(uint256(r));
                require(msg.sender == currentOwner || approvedHashes[currentOwner][dataHash] != 0, "Hash has not been approved");
                if (consumeHash && msg.sender != currentOwner) {
                    approvedHashes[currentOwner][dataHash] = 0;
                }
            } else if (v > 30) {
                currentOwner = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash)), v - 4, r, s);
            } else {
                currentOwner = ecrecover(dataHash, v, r, s);
            }
            require (
                currentOwner > lastOwner && owners[currentOwner] != address(0) && currentOwner != SENTINEL_OWNERS,
                "Invalid owner provided"
            );
            lastOwner = currentOwner;
        }
    }

    function requiredTxGas(address to, uint256 value, bytes calldata data, Enum.Operation operation)
        external
        authorized
        returns (uint256)
    {

        uint256 startGas = gasleft();
        require(execute(to, value, data, operation, gasleft()));
        uint256 requiredGas = startGas - gasleft();
        revert(string(abi.encodePacked(requiredGas)));
    }

    function approveHash(bytes32 hashToApprove)
        external
    {

        require(owners[msg.sender] != address(0), "Only owners can approve a hash");
        approvedHashes[msg.sender][hashToApprove] = 1;
        emit ApproveHash(hashToApprove, msg.sender);
    }

    function signMessage(bytes calldata _data)
        external
        authorized
    {

        bytes32 msgHash = getMessageHash(_data);
        signedMessages[msgHash] = 1;
        emit SignMsg(msgHash);
    }

    function isValidSignature(bytes calldata _data, bytes calldata _signature)
        external
        returns (bytes4)
    {

        bytes32 messageHash = getMessageHash(_data);
        if (_signature.length == 0) {
            require(signedMessages[messageHash] != 0, "Hash not approved");
        } else {
            checkSignatures(messageHash, _data, _signature, false);
        }
        return EIP1271_MAGIC_VALUE;
    }

    function getMessageHash(
        bytes memory message
    )
        public
        view
        returns (bytes32)
    {

        bytes32 safeMessageHash = keccak256(
            abi.encode(SAFE_MSG_TYPEHASH, keccak256(message))
        );
        return keccak256(
            abi.encodePacked(byte(0x19), byte(0x01), domainSeparator, safeMessageHash)
        );
    }

    function encodeTransactionData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    )
        public
        view
        returns (bytes memory)
    {

        bytes32 safeTxHash = keccak256(
            abi.encode(SAFE_TX_TYPEHASH, to, value, keccak256(data), operation, safeTxGas, baseGas, gasPrice, gasToken, refundReceiver, _nonce)
        );
        return abi.encodePacked(byte(0x19), byte(0x01), domainSeparator, safeTxHash);
    }

    function getTransactionHash(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    )
        public
        view
        returns (bytes32)
    {

        return keccak256(encodeTransactionData(to, value, data, operation, safeTxGas, baseGas, gasPrice, gasToken, refundReceiver, _nonce));
    }
}
pragma solidity 0.5.12;


contract CPKFactoryCustom {

    event ProxyCreation(GnosisSafeProxy proxy);

    function proxyCreationCode() external pure returns (bytes memory) {

        return type(GnosisSafeProxy).creationCode;
    }

    function createProxyAndExecTransaction(
        address masterCopy,
        uint256 saltNonce,
        address fallbackHandler,
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    )
        external
        payable
        returns (bool execTransactionSuccess)
    {

        GnosisSafe proxy;
        bytes memory deploymentData = abi.encodePacked(
            type(GnosisSafeProxy).creationCode,
            abi.encode(masterCopy)
        );
        bytes32 salt = keccak256(abi.encode(msg.sender, saltNonce));

        assembly {
            proxy := create2(0x0, add(0x20, deploymentData), mload(deploymentData), salt)
        }
        require(address(proxy) != address(0), "create2 call failed");

        {
            address[] memory tmp = new address[](1);
            tmp[0] = address(this);

            proxy.setup(
                tmp,  // [CPKFactory]
                1,
                address(0),
                "",
                fallbackHandler,
                address(0),
                0,
                address(0)
            );
        }

        execTransactionSuccess = proxy.execTransaction.value(msg.value)(
            to,
            value,
            data,
            operation,
            0,
            0,
            0,
            address(0),
            address(0),
            abi.encodePacked(uint(address(this)), uint(0), uint8(1))
        );
        require(execTransactionSuccess, "CPKFactoryCustom.create.execTransaction: failed");

        execTransactionSuccess = proxy.execTransaction(
            address(proxy), 0,
            abi.encodeWithSignature(
                "swapOwner(address,address,address)",
                address(1),  // prevOwner in linked list (SENTINEL)
                address(this),  // oldOwner (CPKFactory)
                msg.sender  // newOwner (User/msg.sender)
            ),
            Enum.Operation.Call,
            0,
            0,
            0,
            address(0),
            address(0),
            abi.encodePacked(uint(address(this)), uint(0), uint8(1))
        );
        require(execTransactionSuccess, "CPKFactoryCustom.create.swapOwner: failed");

        emit ProxyCreation(GnosisSafeProxy(address(proxy)));
   }
}pragma solidity >=0.5.0 <0.7.0;


contract CreateAndAddModules {


    function enableModule(Module module)
        public
    {

        revert();
    }

    function createAndAddModules(address proxyFactory, bytes memory data)
        public
    {

        uint256 length = data.length;
        Module module;
        uint256 i = 0;
        while (i < length) {
            assembly {
                let createBytesLength := mload(add(0x20, add(data, i)))
                let createBytes := add(0x40, add(data, i))

                let output := mload(0x40)
                if eq(delegatecall(gas, proxyFactory, createBytes, createBytesLength, output, 0x20), 0) { revert(0, 0) }
                module := and(mload(output), 0xffffffffffffffffffffffffffffffffffffffff)

                i := add(i, add(0x20, mul(div(add(createBytesLength, 0x1f), 0x20), 0x20)))
            }
            this.enableModule(module);
        }
    }
}
pragma solidity >=0.5.0 <0.7.0;


contract CreateCall {

    event ContractCreation(address newContract);

    function performCreate2(uint256 value, bytes memory deploymentData, bytes32 salt) public returns(address newContract) {

        assembly {
            newContract := create2(value, add(0x20, deploymentData), mload(deploymentData), salt)
        }
        require(newContract != address(0), "Could not deploy contract");
        emit ContractCreation(newContract);
    }

    function performCreate(uint256 value, bytes memory deploymentData) public returns(address newContract) {

        assembly {
            newContract := create(value, add(deploymentData, 0x20), mload(deploymentData))
        }
        require(newContract != address(0), "Could not deploy contract");
        emit ContractCreation(newContract);
    }
}pragma solidity >=0.5.0 <0.7.0;

interface ERC1155TokenReceiver {

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);


    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);       

}pragma solidity >=0.5.0 <0.7.0;

interface ERC721TokenReceiver {

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);

}pragma solidity >=0.5.0 <0.7.0;

interface ERC777TokensRecipient {

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

}pragma solidity >=0.5.0 <0.7.0;


contract DefaultCallbackHandler is ERC1155TokenReceiver, ERC777TokensRecipient, ERC721TokenReceiver {


    string public constant NAME = "Default Callback Handler";
    string public constant VERSION = "1.0.0";

    function onERC1155Received(address, address, uint256, uint256, bytes calldata)
        external
        returns(bytes4)
    {

        return 0xf23a6e61;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        returns(bytes4)
    {

        return 0xbc197c81;
    }

    function onERC721Received(address, address, uint256, bytes calldata)
        external
        returns(bytes4)
    {

        return 0x150b7a02;
    }

    function tokensReceived(address, address, address, uint256, bytes calldata, bytes calldata) external {

    }

}pragma solidity >=0.5.0 <0.7.0;


contract DelegateConstructorProxy is GnosisSafeProxy {


    constructor(address _masterCopy, bytes memory initializer) GnosisSafeProxy(_masterCopy)
        public
    {
        if (initializer.length > 0) {
            assembly {
                let masterCopy := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
                let success := delegatecall(sub(gas, 10000), masterCopy, add(initializer, 0x20), mload(initializer), 0, 0)
                let ptr := mload(0x40)
                returndatacopy(ptr, 0, returndatasize())
                if eq(success, 0) { revert(ptr, returndatasize()) }
            }
        }
    }
}
pragma solidity >=0.5.0 <0.7.0;


contract EtherPaymentFallback {


    function ()
        external
        payable
    {

    }
}
pragma solidity ^0.5.3;

interface IProxyCreationCallback {

    function proxyCreated(GnosisSafeProxy proxy, address _mastercopy, bytes calldata initializer, uint256 saltNonce) external;

}
pragma solidity ^0.5.3;

contract GnosisSafeProxyFactory {


    event ProxyCreation(GnosisSafeProxy proxy);

    function createProxy(address masterCopy, bytes memory data)
        public
        returns (GnosisSafeProxy proxy)
    {

        proxy = new GnosisSafeProxy(masterCopy);
        if (data.length > 0)
            assembly {
                if eq(call(gas, proxy, 0, add(data, 0x20), mload(data), 0, 0), 0) { revert(0, 0) }
            }
        emit ProxyCreation(proxy);
    }

    function proxyRuntimeCode() public pure returns (bytes memory) {

        return type(GnosisSafeProxy).runtimeCode;
    }

    function proxyCreationCode() public pure returns (bytes memory) {

        return type(GnosisSafeProxy).creationCode;
    }

    function deployProxyWithNonce(address _mastercopy, bytes memory initializer, uint256 saltNonce)
        internal
        returns (GnosisSafeProxy proxy)
    {

        bytes32 salt = keccak256(abi.encodePacked(keccak256(initializer), saltNonce));
        bytes memory deploymentData = abi.encodePacked(type(GnosisSafeProxy).creationCode, uint256(_mastercopy));
        assembly {
            proxy := create2(0x0, add(0x20, deploymentData), mload(deploymentData), salt)
        }
        require(address(proxy) != address(0), "Create2 call failed");
    }

    function createProxyWithNonce(address _mastercopy, bytes memory initializer, uint256 saltNonce)
        public
        returns (GnosisSafeProxy proxy)
    {

        proxy = deployProxyWithNonce(_mastercopy, initializer, saltNonce);
        if (initializer.length > 0)
            assembly {
                if eq(call(gas, proxy, 0, add(initializer, 0x20), mload(initializer), 0, 0), 0) { revert(0,0) }
            }
        emit ProxyCreation(proxy);
    }

    function createProxyWithCallback(address _mastercopy, bytes memory initializer, uint256 saltNonce, IProxyCreationCallback callback)
        public
        returns (GnosisSafeProxy proxy)
    {

        uint256 saltNonceWithCallback = uint256(keccak256(abi.encodePacked(saltNonce, callback)));
        proxy = createProxyWithNonce(_mastercopy, initializer, saltNonceWithCallback);
        if (address(callback) != address(0))
            callback.proxyCreated(proxy, _mastercopy, initializer, saltNonce);
    }

    function calculateCreateProxyWithNonceAddress(address _mastercopy, bytes calldata initializer, uint256 saltNonce)
        external
        returns (GnosisSafeProxy proxy)
    {

        proxy = deployProxyWithNonce(_mastercopy, initializer, saltNonce);
        revert(string(abi.encodePacked(proxy)));
    }

}
pragma solidity >=0.5.0 <0.7.0;


contract MultiSend {


    bytes32 constant private GUARD_VALUE = keccak256("multisend.guard.bytes32");

    bytes32 guard;

    constructor() public {
        guard = GUARD_VALUE;
    }

    function multiSend(bytes memory transactions)
        public
    {

        require(guard != GUARD_VALUE, "MultiSend should only be called via delegatecall");
        assembly {
            let length := mload(transactions)
            let i := 0x20
            for { } lt(i, length) { } {
                let operation := shr(0xf8, mload(add(transactions, i)))
                let to := shr(0x60, mload(add(transactions, add(i, 0x01))))
                let value := mload(add(transactions, add(i, 0x15)))
                let dataLength := mload(add(transactions, add(i, 0x35)))
                let data := add(transactions, add(i, 0x55))
                let success := 0
                switch operation
                case 0 { success := call(gas, to, value, data, dataLength, 0, 0) }
                case 1 { success := delegatecall(gas, to, data, dataLength, 0, 0) }
                if eq(success, 0) { revert(0, 0) }
                i := add(i, add(0x55, dataLength))
            }
        }
    }
}
pragma solidity >=0.5.0 <0.7.0;

contract PayingProxy is DelegateConstructorProxy, SecuredTokenTransfer {


    constructor(address _masterCopy, bytes memory initializer, address payable funder, address paymentToken, uint256 payment)
        DelegateConstructorProxy(_masterCopy, initializer)
        public
    {
        if (payment > 0) {
            if (paymentToken == address(0)) {
                require(funder.send(payment), "Could not pay safe creation with ether");
            } else {
                require(transferToken(paymentToken, funder, payment), "Could not pay safe creation with token");
            }
        }
    }
}
