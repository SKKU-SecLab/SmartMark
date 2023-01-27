
pragma solidity ^0.8.0;

interface Structs {

	struct Provider {
		uint16 chainId;
		uint16 governanceChainId;
		bytes32 governanceContract;
	}

	struct GuardianSet {
		address[] keys;
		uint32 expirationTime;
	}

	struct Signature {
		bytes32 r;
		bytes32 s;
		uint8 v;
		uint8 guardianIndex;
	}

	struct VM {
		uint8 version;
		uint32 timestamp;
		uint32 nonce;
		uint16 emitterChainId;
		bytes32 emitterAddress;
		uint64 sequence;
		uint8 consistencyLevel;
		bytes payload;

		uint32 guardianSetIndex;
		Signature[] signatures;

		bytes32 hash;
	}
}// contracts/State.sol

pragma solidity ^0.8.0;


contract Events {

    event LogGuardianSetChanged(
        uint32 oldGuardianIndex,
        uint32 newGuardianIndex
    );

    event LogMessagePublished(
        address emitter_address,
        uint32 nonce,
        bytes payload
    );
}

contract Storage {

    struct WormholeState {
        Structs.Provider provider;

        mapping(uint32 => Structs.GuardianSet) guardianSets;

        uint32 guardianSetIndex;

        uint32 guardianSetExpiry;

        mapping(address => uint64) sequences;

        mapping(bytes32 => bool) consumedGovernanceActions;

        mapping(address => bool) initializedImplementations;

        uint256 messageFee;
    }
}

contract State {

    Storage.WormholeState _state;
}// contracts/Getters.sol

pragma solidity ^0.8.0;


contract Getters is State {

    function getGuardianSet(uint32 index) public view returns (Structs.GuardianSet memory) {

        return _state.guardianSets[index];
    }

    function getCurrentGuardianSetIndex() public view returns (uint32) {

        return _state.guardianSetIndex;
    }

    function getGuardianSetExpiry() public view returns (uint32) {

        return _state.guardianSetExpiry;
    }

    function governanceActionIsConsumed(bytes32 hash) public view returns (bool) {

        return _state.consumedGovernanceActions[hash];
    }

    function isInitialized(address impl) public view returns (bool) {

        return _state.initializedImplementations[impl];
    }

    function chainId() public view returns (uint16) {

        return _state.provider.chainId;
    }

    function governanceChainId() public view returns (uint16){

        return _state.provider.governanceChainId;
    }

    function governanceContract() public view returns (bytes32){

        return _state.provider.governanceContract;
    }

    function messageFee() public view returns (uint256) {

        return _state.messageFee;
    }

    function nextSequence(address emitter) public view returns (uint64) {

        return _state.sequences[emitter];
    }
}// Unlicense
pragma solidity >=0.8.0 <0.9.0;


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

        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");

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
                mstore(tempBytes, 0)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {

        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {

        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {

        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {

        require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {

        require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {

        require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {

        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {

        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
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
}// contracts/GovernanceStructs.sol

pragma solidity ^0.8.0;


contract GovernanceStructs {

    using BytesLib for bytes;

    enum GovernanceAction {
        UpgradeContract,
        UpgradeGuardianset
    }

    struct ContractUpgrade {
        bytes32 module;
        uint8 action;
        uint16 chain;

        address newContract;
    }

    struct GuardianSetUpgrade {
        bytes32 module;
        uint8 action;
        uint16 chain;

        Structs.GuardianSet newGuardianSet;
        uint32 newGuardianSetIndex;
    }

    struct SetMessageFee {
        bytes32 module;
        uint8 action;
        uint16 chain;

        uint256 messageFee;
    }

    struct TransferFees {
        bytes32 module;
        uint8 action;
        uint16 chain;

        uint256 amount;
        bytes32 recipient;
    }

    function parseContractUpgrade(bytes memory encodedUpgrade) public pure returns (ContractUpgrade memory cu) {

        uint index = 0;

        cu.module = encodedUpgrade.toBytes32(index);
        index += 32;

        cu.action = encodedUpgrade.toUint8(index);
        index += 1;

        require(cu.action == 1, "invalid ContractUpgrade");

        cu.chain = encodedUpgrade.toUint16(index);
        index += 2;

        cu.newContract = address(uint160(uint256(encodedUpgrade.toBytes32(index))));
        index += 32;

        require(encodedUpgrade.length == index, "invalid ContractUpgrade");
    }

    function parseGuardianSetUpgrade(bytes memory encodedUpgrade) public pure returns (GuardianSetUpgrade memory gsu) {

        uint index = 0;

        gsu.module = encodedUpgrade.toBytes32(index);
        index += 32;

        gsu.action = encodedUpgrade.toUint8(index);
        index += 1;

        require(gsu.action == 2, "invalid GuardianSetUpgrade");

        gsu.chain = encodedUpgrade.toUint16(index);
        index += 2;

        gsu.newGuardianSetIndex = encodedUpgrade.toUint32(index);
        index += 4;

        uint8 guardianLength = encodedUpgrade.toUint8(index);
        index += 1;

        gsu.newGuardianSet = Structs.GuardianSet({
            keys : new address[](guardianLength),
            expirationTime : 0
        });

        for(uint i = 0; i < guardianLength; i++) {
            gsu.newGuardianSet.keys[i] = encodedUpgrade.toAddress(index);
            index += 20;
        }

        require(encodedUpgrade.length == index, "invalid GuardianSetUpgrade");
    }

    function parseSetMessageFee(bytes memory encodedSetMessageFee) public pure returns (SetMessageFee memory smf) {

        uint index = 0;

        smf.module = encodedSetMessageFee.toBytes32(index);
        index += 32;

        smf.action = encodedSetMessageFee.toUint8(index);
        index += 1;

        require(smf.action == 3, "invalid SetMessageFee");

        smf.chain = encodedSetMessageFee.toUint16(index);
        index += 2;

        smf.messageFee = encodedSetMessageFee.toUint256(index);
        index += 32;

        require(encodedSetMessageFee.length == index, "invalid SetMessageFee");
    }

    function parseTransferFees(bytes memory encodedTransferFees) public pure returns (TransferFees memory tf) {

        uint index = 0;

        tf.module = encodedTransferFees.toBytes32(index);
        index += 32;

        tf.action = encodedTransferFees.toUint8(index);
        index += 1;

        require(tf.action == 4, "invalid TransferFees");

        tf.chain = encodedTransferFees.toUint16(index);
        index += 2;

        tf.amount = encodedTransferFees.toUint256(index);
        index += 32;

        tf.recipient = encodedTransferFees.toBytes32(index);
        index += 32;

        require(encodedTransferFees.length == index, "invalid TransferFees");
    }
}// contracts/Messages.sol

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;



contract Messages is Getters {

    using BytesLib for bytes;

    function parseAndVerifyVM(bytes calldata encodedVM) public view returns (Structs.VM memory vm, bool valid, string memory reason) {

        vm = parseVM(encodedVM);
        (valid, reason) = verifyVM(vm);
    }

    function verifyVM(Structs.VM memory vm) public view returns (bool valid, string memory reason) {

        Structs.GuardianSet memory guardianSet = getGuardianSet(vm.guardianSetIndex);

        if(guardianSet.keys.length == 0){
            return (false, "invalid guardian set");
        }
        if(vm.guardianSetIndex != getCurrentGuardianSetIndex() && guardianSet.expirationTime < block.timestamp){
            return (false, "guardian set has expired");
        }
        if(((guardianSet.keys.length * 10 / 3) * 2) / 10 + 1 > vm.signatures.length){
            return (false, "no quorum");
        }

        (bool signaturesValid, string memory invalidReason) = verifySignatures(vm.hash, vm.signatures, guardianSet);
        if(!signaturesValid){
            return (false, invalidReason);
        }

        return (true, "");
    }

    function verifySignatures(bytes32 hash, Structs.Signature[] memory signatures, Structs.GuardianSet memory guardianSet) public pure returns (bool valid, string memory reason) {

        uint8 lastIndex = 0;
        for (uint i = 0; i < signatures.length; i++) {
            Structs.Signature memory sig = signatures[i];

            require(i == 0 || sig.guardianIndex > lastIndex, "signature indices must be ascending");
            lastIndex = sig.guardianIndex;

            if(ecrecover(hash, sig.v, sig.r, sig.s) != guardianSet.keys[sig.guardianIndex]){
                return (false, "VM signature invalid");
            }
        }
        return (true, "");
    }

    function parseVM(bytes memory encodedVM) public pure virtual returns (Structs.VM memory vm) {

        uint index = 0;

        vm.version = encodedVM.toUint8(index);
        index += 1;
        require(vm.version == 1, "VM version incompatible");

        vm.guardianSetIndex = encodedVM.toUint32(index);
        index += 4;

        uint256 signersLen = encodedVM.toUint8(index);
        index += 1;
        vm.signatures = new Structs.Signature[](signersLen);
        for (uint i = 0; i < signersLen; i++) {
            vm.signatures[i].guardianIndex = encodedVM.toUint8(index);
            index += 1;

            vm.signatures[i].r = encodedVM.toBytes32(index);
            index += 32;
            vm.signatures[i].s = encodedVM.toBytes32(index);
            index += 32;
            vm.signatures[i].v = encodedVM.toUint8(index) + 27;
            index += 1;
        }

        bytes memory body = encodedVM.slice(index, encodedVM.length - index);
        vm.hash = keccak256(abi.encodePacked(keccak256(body)));

        vm.timestamp = encodedVM.toUint32(index);
        index += 4;

        vm.nonce = encodedVM.toUint32(index);
        index += 4;

        vm.emitterChainId = encodedVM.toUint16(index);
        index += 2;

        vm.emitterAddress = encodedVM.toBytes32(index);
        index += 32;

        vm.sequence = encodedVM.toUint64(index);
        index += 8;

        vm.consistencyLevel = encodedVM.toUint8(index);
        index += 1;

        vm.payload = encodedVM.slice(index, encodedVM.length - index);
    }
}// contracts/Setters.sol

pragma solidity ^0.8.0;


contract Setters is State {

    function updateGuardianSetIndex(uint32 newIndex) internal {

        _state.guardianSetIndex = newIndex;
    }

    function expireGuardianSet(uint32 index) internal {

        _state.guardianSets[index].expirationTime = uint32(block.timestamp) + 86400;
    }

    function storeGuardianSet(Structs.GuardianSet memory set, uint32 index) internal {

        _state.guardianSets[index] = set;
    }

    function setInitialized(address implementatiom) internal {

        _state.initializedImplementations[implementatiom] = true;
    }

    function setGovernanceActionConsumed(bytes32 hash) internal {

        _state.consumedGovernanceActions[hash] = true;
    }

    function setChainId(uint16 chainId) internal {

        _state.provider.chainId = chainId;
    }

    function setGovernanceChainId(uint16 chainId) internal {

        _state.provider.governanceChainId = chainId;
    }

    function setGovernanceContract(bytes32 governanceContract) internal {

        _state.provider.governanceContract = governanceContract;
    }

    function setMessageFee(uint256 newFee) internal {

        _state.messageFee = newFee;
    }

    function setNextSequence(address emitter, uint64 sequence) internal {

        _state.sequences[emitter] = sequence;
    }
}// MIT

pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

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

    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(address newImplementation, bytes memory data, bool forceCall) internal {
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
                abi.encodeWithSignature(
                    "upgradeTo(address)",
                    oldImplementation
                )
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _setImplementation(newImplementation);
            emit Upgraded(newImplementation);
        }
    }

    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
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
        require(
            Address.isContract(newBeacon),
            "ERC1967: new beacon is not a contract"
        );
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }
}// contracts/Governance.sol

pragma solidity ^0.8.0;



abstract contract Governance is GovernanceStructs, Messages, Setters, ERC1967Upgrade {
    event ContractUpgraded(address indexed oldContract, address indexed newContract);
    event GuardianSetAdded(uint32 indexed index);

    bytes32 constant module = 0x00000000000000000000000000000000000000000000000000000000436f7265;

    function submitContractUpgrade(bytes memory _vm) public {
        Structs.VM memory vm = parseVM(_vm);

        (bool isValid, string memory reason) = verifyGovernanceVM(vm);
        require(isValid, reason);

        GovernanceStructs.ContractUpgrade memory upgrade = parseContractUpgrade(vm.payload);

        require(upgrade.module == module, "Invalid Module");
        require(upgrade.chain == chainId(), "Invalid Chain");

        setGovernanceActionConsumed(vm.hash);

        upgradeImplementation(upgrade.newContract);
    }

    function submitSetMessageFee(bytes memory _vm) public {
        Structs.VM memory vm = parseVM(_vm);

        (bool isValid, string memory reason) = verifyGovernanceVM(vm);
        require(isValid, reason);

        GovernanceStructs.SetMessageFee memory upgrade = parseSetMessageFee(vm.payload);

        require(upgrade.module == module, "Invalid Module");
        require(upgrade.chain == chainId(), "Invalid Chain");

        setGovernanceActionConsumed(vm.hash);

        setMessageFee(upgrade.messageFee);
    }

    function submitNewGuardianSet(bytes memory _vm) public {
        Structs.VM memory vm = parseVM(_vm);

        (bool isValid, string memory reason) = verifyGovernanceVM(vm);
        require(isValid, reason);

        GovernanceStructs.GuardianSetUpgrade memory upgrade = parseGuardianSetUpgrade(vm.payload);

        require(upgrade.module == module, "invalid Module");
        require(upgrade.chain == chainId() || upgrade.chain == 0, "invalid Chain");

        require(upgrade.newGuardianSet.keys.length > 0, "new guardian set is empty");
        require(upgrade.newGuardianSetIndex == getCurrentGuardianSetIndex() + 1, "index must increase in steps of 1");

        setGovernanceActionConsumed(vm.hash);

        expireGuardianSet(getCurrentGuardianSetIndex());
        storeGuardianSet(upgrade.newGuardianSet, upgrade.newGuardianSetIndex);
        updateGuardianSetIndex(upgrade.newGuardianSetIndex);
    }

    function submitTransferFees(bytes memory _vm) public {
        Structs.VM memory vm = parseVM(_vm);

        (bool isValid, string memory reason) = verifyGovernanceVM(vm);
        require(isValid, reason);

        GovernanceStructs.TransferFees memory transfer = parseTransferFees(vm.payload);

        require(transfer.module == module, "invalid Module");
        require(transfer.chain == chainId() || transfer.chain == 0, "invalid Chain");

        setGovernanceActionConsumed(vm.hash);

        address payable recipient = payable(address(uint160(uint256(transfer.recipient))));

        recipient.transfer(transfer.amount);
    }

    function upgradeImplementation(address newImplementation) internal {
        address currentImplementation = _getImplementation();

        _upgradeTo(newImplementation);

        (bool success, bytes memory reason) = newImplementation.delegatecall(abi.encodeWithSignature("initialize()"));

        require(success, string(reason));

        emit ContractUpgraded(currentImplementation, newImplementation);
    }

    function verifyGovernanceVM(Structs.VM memory vm) internal view returns (bool, string memory){
        (bool isValid, string memory reason) = verifyVM(vm);
        if (!isValid){
            return (false, reason);
        }

        if (vm.guardianSetIndex != getCurrentGuardianSetIndex()) {
            return (false, "not signed by current guardian set");
        }

        if (uint16(vm.emitterChainId) != governanceChainId()) {
            return (false, "wrong governance chain");
        }
        if (vm.emitterAddress != governanceContract()) {
            return (false, "wrong governance contract");
        }

        if (governanceActionIsConsumed(vm.hash)){
            return (false, "governance action already consumed");
        }

        return (true, "");
    }
}// contracts/Implementation.sol

pragma solidity ^0.8.0;



contract Implementation is Governance {

    event LogMessagePublished(address indexed sender, uint64 sequence, uint32 nonce, bytes payload, uint8 consistencyLevel);

    function publishMessage(
        uint32 nonce,
        bytes memory payload,
        uint8 consistencyLevel
    ) public payable returns (uint64 sequence) {

        require(msg.value == messageFee(), "invalid fee");

        sequence = useSequence(msg.sender);
        emit LogMessagePublished(msg.sender, sequence, nonce, payload, consistencyLevel);
    }

    function useSequence(address emitter) internal returns (uint64 sequence) {

        sequence = nextSequence(emitter);
        setNextSequence(emitter, sequence + 1);
    }

    function initialize(address[] memory initialGuardians, uint16 chainId, uint16 governanceChainId, bytes32 governanceContract) initializer public {

        require(initialGuardians.length > 0, "no guardians specified");

        Structs.GuardianSet memory initialGuardianSet = Structs.GuardianSet({
            keys : initialGuardians,
            expirationTime : 0
        });

        storeGuardianSet(initialGuardianSet, 0);

        setChainId(chainId);

        setGovernanceChainId(governanceChainId);
        setGovernanceContract(governanceContract);
    }

    modifier initializer() {

        address implementation = ERC1967Upgrade._getImplementation();

        require(
            !isInitialized(implementation),
            "already initialized"
        );

        setInitialized(implementation);

        _;
    }

    fallback() external payable {revert("unsupported");}

    receive() external payable {revert("the Wormhole contract does not accept assets");}
}