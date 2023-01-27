
pragma experimental ABIEncoderV2;



pragma solidity ^0.6.0;

contract FormulaDefiner {


    struct Operation {
        uint16 instruction;
        bytes operands; // encoded operands
    }

    struct Formula {
        uint256 salt;
        uint256 signedEndpointCount;
        address[] endpoints;
        Operation[] operations;
        bytes[] signatures;
    }
}

contract Constants {


    uint256 constant sizeWord = 32; // Ethereum word size (uint256 size)
    uint256 constant sizeArrayLength = 2; // size of array length representation
    uint256 constant sizeAmount = sizeWord; // size of (ether/token/etc.) amount
    uint256 constant sizeAddress = 20; // size of ethereum address
    uint256 constant sizePointer = 2; // size of endpoint pointer
    uint256 constant sizeInstruction = 2; // size of instruction code
    uint256 constant sizeSalt = sizeWord; // size of unique salt
    uint256 constant sizeSignature = 65; // size of signature
    uint256 constant sizeBlockNumber = 4; // size of block number (used for time conditioning)

    uint256 constant formulaFee = 0.0004 ether; // fee per operation
    uint256 constant feeInstruction = 4;

    function feePerOperation() external pure returns (uint256) {

        return formulaFee;
    }
}



pragma solidity ^0.6.0;


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
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                sstore(
                    _preBytes_slot,
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
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))


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
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

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
        uint _start,
        uint _length
    )
        internal
        pure
        returns (bytes memory)
    {

        require(_bytes.length >= (_start + _length), 'BytesLib: unexpected error');

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

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {

        require(_bytes.length >= (_start + 20), 'BytesLib: unexpected error');
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {

        require(_bytes.length >= (_start + 1), 'BytesLib: unexpected error');
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {

        require(_bytes.length >= (_start + 2), 'BytesLib: unexpected error');
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {

        require(_bytes.length >= (_start + 4), 'BytesLib: unexpected error');
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint _start) internal  pure returns (uint64) {

        require(_bytes.length >= (_start + 8), 'BytesLib: unexpected error');
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint _start) internal  pure returns (uint96) {

        require(_bytes.length >= (_start + 12), 'BytesLib: unexpected error');
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint _start) internal  pure returns (uint128) {

        require(_bytes.length >= (_start + 16), 'BytesLib: unexpected error');
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {

        require(_bytes.length >= (_start + 32), 'BytesLib: unexpected error');
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {

        require(_bytes.length >= (_start + 32), 'BytesLib: unexpected error');
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
            let fslot := sload(_preBytes_slot)
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

                        mstore(0x0, _preBytes_slot)
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
}





contract FormulaDecompiler is FormulaDefiner, Constants {


    function decompileFormulaCompiled(bytes memory compiledFormula) public pure returns (Formula memory) {

        Formula memory formulaInfo;
        uint256 offset = sizeWord; // compiledFormula bytes size

        uint256 salt;
        assembly {
            salt := mload(add(compiledFormula, offset))
        }
        formulaInfo.salt = salt;
        offset += sizeSalt;

        (formulaInfo.endpoints, formulaInfo.signedEndpointCount, offset) = decompileEndpoints(compiledFormula, offset);
        (formulaInfo.operations, offset) = decompileOperations(compiledFormula, offset);
        (formulaInfo.signatures, offset) = decompileSignatures(compiledFormula, offset, formulaInfo.signedEndpointCount);

        return formulaInfo;
    }

    function decompileEndpoints(bytes memory compiledFormula, uint256 offset) internal pure returns (address[] memory, uint16 signedEndpointCount, uint256 newOffset) {

        uint256 shiftArrayLength = sizeWord - sizeArrayLength;
        uint256 shiftAddress = sizeWord - sizeAddress;

        uint16 endpointCount;
        uint16 tmpSignedEndpointCount;
        assembly {
            endpointCount := mload(add(compiledFormula, sub(offset, shiftArrayLength)))
        }
        offset += sizeArrayLength;
        assembly {
            tmpSignedEndpointCount := mload(add(compiledFormula, sub(offset, shiftArrayLength)))
        }
        offset += sizeArrayLength;

        require(tmpSignedEndpointCount <= endpointCount, 'Invalid signed endpoint count');

        address endpoint;
        address[] memory endpoints = new address[](endpointCount);

        for (uint256 i = 0; i < endpointCount; i++) {
            assembly {
                endpoint := mload(add(compiledFormula, sub(offset, shiftAddress)))
            }
            offset += sizeAddress;
            endpoints[i] = endpoint;
        }

        return (endpoints, tmpSignedEndpointCount, offset);
    }

    function decompileOperations(bytes memory compiledFormula, uint256 offset) internal pure returns (Operation[] memory, uint256 newOffset) {

        uint256 shiftArrayLength = sizeWord - sizeArrayLength;

        uint16 operationCount;
        assembly {
            operationCount := mload(add(compiledFormula, sub(offset, shiftArrayLength)))
        }
        offset += sizeArrayLength;


        uint16 instruction;
        bytes memory operands;
        uint256 operandsLength;
        Operation[] memory operations = new Operation[](operationCount);

        uint256 shiftInstruction = sizeWord - sizeInstruction;
        for (uint256 i = 0; i < operationCount; i++) {
            assembly {
                instruction := mload(add(compiledFormula, sub(offset, shiftInstruction)))
            }
            offset += sizeInstruction;

            operandsLength = decompileOperandsLength(instruction, compiledFormula, offset);
            operands = BytesLib.slice(compiledFormula, offset - sizeWord, operandsLength);
            offset += operandsLength;

            operations[i] = Operation({
                instruction: instruction,
                operands: operands
            });
        }

        return (operations, offset);
    }

    function decompileSignatures(bytes memory compiledFormula, uint256 offset, uint256 signatureCount) internal pure returns (bytes[] memory, uint256 newOffset) {

        bytes[] memory signatures = new bytes[](signatureCount);

        for (uint256 i = 0; i < signatureCount; i++) {
            signatures[i] = BytesLib.slice(compiledFormula, offset - sizeWord, sizeSignature);
            offset += sizeSignature;
        }

        return (signatures, offset);
    }

    function decompileOperandsLength(uint256 instruction, bytes memory compiledFormula, uint256 offset) internal pure returns (uint256) {


        if (instruction == 0 || instruction == 3) {
            return 0
                + sizePointer // endpoint index
                + sizePointer // to address
                + sizeAmount // amount
            ;
        }

        if (instruction == 1 || instruction == 2) {
            return 0
                + sizePointer // endpoint index
                + sizePointer // to address
                + sizeAmount // amount or tokenId
                + sizeAddress // token address
            ;
        }

        if (instruction == 4) {
            return 0
                + sizePointer // endpoint index
                + sizeAmount // amount
            ;
        }

        if (instruction == 5) {
            return 0
                + sizeBlockNumber // minimum block number
                + sizeBlockNumber // maximum block number
            ;
        }

        revert('Unknown instruction');
    }
}

pragma solidity ^0.6.0;



contract FormulaPresigner {


    enum PresignStates {
        defaultValue,
        permitted,
        forbidden
    }

    event FormulaPresigner_presignFormula(address party, bytes32 formulaHash, PresignStates newState);

    mapping(address => mapping(bytes32 => PresignStates)) public presignedFormulas;

    function presignFormula(bytes32 formulaHash, PresignStates state) external {

        presignedFormulas[msg.sender][formulaHash] = state;

        emit FormulaPresigner_presignFormula(msg.sender, formulaHash, state);
    }
}

pragma solidity ^0.6.0;

library SignatureVerifier {


    function verifySignaturePrefixed(address signer, bytes32 messageHash, bytes memory signature) internal pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = signatureParts(signature);

        return verifySignaturePrefixed(signer, messageHash, v, r, s);
    }

    function verifySignature(address signer, bytes32 messageHash, bytes memory signature) internal pure returns (bool) {

        (uint8 v, bytes32 r, bytes32 s) = signatureParts(signature);

        return verifySignature(signer, messageHash, v, r, s);
    }

    function verifySignaturePrefixed(address signer, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) internal pure returns (bool) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, messageHash));

        return addressFromSignature(prefixedHash, v, r, s) == signer;
    }

    function verifySignature(address signer, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) internal pure returns (bool) {

        bytes32 prefixedHash = keccak256(abi.encodePacked(messageHash));

        return addressFromSignature(prefixedHash, v, r, s) == signer;
    }

    function addressFromSignature(bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        address signer = ecrecover(messageHash, v, r, s);

        return signer;
    }

    function signatureParts(bytes memory signature) internal pure returns (uint8 v, bytes32 r, bytes32 s) {

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            revert('Invalid signature');
        }

        return (v, r, s);
    }
}
pragma solidity ^0.6.0;







contract FormulaValidator is FormulaDecompiler, FormulaPresigner {



    function validateFormula(Formula memory formulaInfo) public view returns (bool) {

        bytes32 hash = calcFormulaHash(formulaInfo);

        return validateFormula(formulaInfo, hash);
    }

    function validateFormula(Formula memory formulaInfo, bytes32 hash) internal view returns (bool) {

        if (formulaInfo.signedEndpointCount != formulaInfo.signatures.length) {
            return false;
        }

        if (!validateSignatures(formulaInfo, hash)) {
            return false;
        }

        if (!validateFee(formulaInfo)) {
            return false;
        }

        return true;
    }

    function validateSignatures(Formula memory formulaInfo, bytes32 hash) internal view returns (bool) {

        for (uint256 i = 0; i < formulaInfo.signedEndpointCount; i++) {
            bool isEmpty = isSignatureEmpty(formulaInfo.signatures[i]);
            if (isEmpty && presignedFormulas[formulaInfo.endpoints[i]][hash] == PresignStates.permitted) {
                continue;
            }

            if (isEmpty && formulaInfo.endpoints[i] == msg.sender) {
                continue;
            }

            if (isEmpty) {
                return false;
            }

            uint16 endpointIndex = uint16(i);
            bytes32 positionHash = keccak256(abi.encodePacked(hash, endpointIndex));

            if (!SignatureVerifier.verifySignaturePrefixed(formulaInfo.endpoints[i], positionHash, formulaInfo.signatures[i])) {
                return false;
            }
        }

        return true;
    }

    function isSignatureEmpty(bytes memory signature) internal pure returns (bool) {

        uint256 shiftFirstPart = sizeWord + (sizeSignature - sizeWord);
        uint256 shiftSecondPart = sizeWord + (sizeSignature - sizeWord);
        uint256 tmp;
        assembly {
            tmp := mload(add(signature, shiftFirstPart))
        }

        if (tmp == 0) {
            return true;
        }

        assembly {
            tmp := mload(add(signature, shiftSecondPart))
        }

        if (tmp == 0) {
            return true;
        }

        return false;
    }

    function validateFee(Formula memory formulaInfo) virtual internal pure returns (bool) {

        for (uint256 i = 0; i < formulaInfo.operations.length; i++) {
            if (formulaInfo.operations[i].instruction == feeInstruction) {
                return true;
            }
        }

        return false;
    }

    function calcFormulaHash(Formula memory formulaInfo) public pure returns (bytes32) {

        bytes memory packedOperations;
        for (uint256 i = 0; i < formulaInfo.operations.length; i++) {
            packedOperations = abi.encodePacked(packedOperations, formulaInfo.operations[i].instruction, formulaInfo.operations[i].operands);
        }

        bytes memory messageToSign = abi.encodePacked(
            formulaInfo.salt,
            uint16(formulaInfo.endpoints.length),
            uint16(formulaInfo.signedEndpointCount),
            packedOperations
        );
        bytes32 hash = keccak256(messageToSign);

        return hash;
    }
}



pragma solidity ^0.6.0;

abstract contract IERC20 {
    function totalSupply() virtual public view returns (uint256 supply);

    function balanceOf(address _owner) virtual public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) virtual public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success);

    function approve(address _spender, uint256 _value) virtual public returns (bool success);

    function allowance(address _owner, address _spender) virtual public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
pragma solidity ^0.6.0;




contract FormulasAdapter_ERC20 /* is FormulasAdapter */ {


    event FormulasAdapter_ERC20_Sent(address token, address indexed from, address indexed to, uint256 amount);

    function erc20_transferValue(address token, address from, address to, uint256 amount) internal {

        require(IERC20(token).transferFrom(from, to, amount), 'IERC20 refused transerFrom() transaction.');

        emit FormulasAdapter_ERC20_Sent(token, from, to, amount);
    }
}




pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}
pragma solidity ^0.6.0;



abstract contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) virtual public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) virtual public view returns (address owner);

    function approve(address to, uint256 tokenId) virtual public;
    function getApproved(uint256 tokenId) virtual public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) virtual public;
    function isApprovedForAll(address owner, address operator) virtual public view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) virtual public;
    function safeTransferFrom(address from, address to, uint256 tokenId) virtual public;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) virtual public;
}
pragma solidity ^0.6.0;




contract FormulasAdapter_ERC721 /* is FormulasAdapter */ {


    event FormulasAdapter_ERC721_Sent(address indexed token, address indexed from, address indexed to, uint256 tokenId);

    function erc721_transferValue(address token, address from, address to, uint256 tokenId) internal {

        IERC721(token).transferFrom(from, to, tokenId);

        emit FormulasAdapter_ERC721_Sent(token, from, to, tokenId);
    }
}


pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
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
}

pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
pragma solidity ^0.6.0;





contract FormulasAdapter_Ether /* is FormulasAdapter */ {


    event FormulasAdapter_Ether_Recieved(address indexed from, uint256 amount);
    event FormulasAdapter_Ether_Sent(address indexed from, address indexed to, uint256 amount);
    event FormulasAdapter_Ether_SentInside(address indexed from, address indexed to, uint256 amount);
    event FormulasAdapter_Ether_Withdrawal(address indexed to, uint256 amount);

    using SafeMath for uint256;

    mapping(address => uint256) public etherBalances; // inner ledger
    uint256 public etherTotalBalance;

    function ether_transferValue(address from, address payable to, uint256 amount) internal {

        etherBalances[from] = etherBalances[from].sub(amount);
        if (to != address(this)) {
            etherTotalBalance = etherTotalBalance.sub(amount);
        }
        Address.sendValue(to, amount);

        emit FormulasAdapter_Ether_Sent(from, to, amount);
    }

    function ether_transferValueInside(address from, address to, uint256 amount) internal {

        etherBalances[from] = etherBalances[from].sub(amount);
        etherBalances[to] = etherBalances[to].add(amount);

        emit FormulasAdapter_Ether_SentInside(from, to, amount);
    }


    function ether_recieve(address from, uint256 amount) internal {

        etherBalances[from] = etherBalances[from].add(amount);
        etherTotalBalance = etherTotalBalance.add(amount);

        emit FormulasAdapter_Ether_Recieved(from, amount);
    }
}







contract FormulaResolver is FormulaDefiner, Constants, FormulasAdapter_Ether, FormulasAdapter_ERC721, FormulasAdapter_ERC20 {


    event FormulasResolver_feePaid(address payer, uint256 amount);

    function resolveFormula(Formula memory formulaInfo) internal {

        for (uint256 i = 0; i < formulaInfo.operations.length; i++) {
            resolveOperation(formulaInfo, formulaInfo.operations[i], formulaInfo.endpoints, formulaInfo.signedEndpointCount);
        }
    }

    function resolveOperation(Formula memory formulaInfo, Operation memory operation, address[] memory endpoints, uint256 signedEndpointCount) internal {

        if (operation.instruction == 0) {
            (uint16 fromIndex, uint16 to, uint256 amount) = extractGenericEtherParams(operation, endpoints.length, signedEndpointCount);

            ether_transferValueInside(endpoints[fromIndex], endpoints[to], amount);
            return;
        }

        if (operation.instruction == 1) {
            (uint16 fromIndex, uint16 to, uint256 amount, address token) = extractGenericTokenParams(operation, endpoints.length, signedEndpointCount);

            erc20_transferValue(token, endpoints[fromIndex], endpoints[to], amount);
            return;
        }

        if (operation.instruction == 2) {
            (uint16 fromIndex, uint16 to, uint256 tokenId, address token) = extractGenericTokenParams(operation, endpoints.length, signedEndpointCount);

            erc721_transferValue(token, endpoints[fromIndex], endpoints[to], tokenId);
            return;
        }

        if (operation.instruction == 3) {
            (uint16 fromIndex, uint16 to, uint256 amount) = extractGenericEtherParams(operation, endpoints.length, signedEndpointCount);

            ether_transferValue(endpoints[fromIndex], payable(endpoints[to]), amount);
            return;
        }

        if (operation.instruction == 4) {
            uint256 shiftFromIndex = sizePointer;
            uint256 shiftAmount = sizePointer + sizeAmount;

            bytes memory operandsPointer = operation.operands;
            uint16 fromIndex;
            uint256 amount;
            assembly {
                fromIndex := mload(add(operandsPointer, shiftFromIndex))
                amount := mload(add(operandsPointer, shiftAmount))
            }

            require(amount >= formulaInfo.operations.length * formulaFee, 'Fee amount is too small.');

            ether_transferValueInside(endpoints[fromIndex], payable(address(this)), amount);
            emit FormulasResolver_feePaid(endpoints[fromIndex], amount);

            return;
        }

        if (operation.instruction == 5) {
            uint256 shiftMinimum = sizeBlockNumber;
            uint256 shiftMaximum = sizeBlockNumber + sizeBlockNumber;

            bytes memory operandsPointer = operation.operands;
            uint32 minimumBlockNumber;
            uint32 maximumBlockNumber;

            assembly {
                minimumBlockNumber := mload(add(operandsPointer, shiftMinimum))
                maximumBlockNumber := mload(add(operandsPointer, shiftMaximum))
            }

            require(minimumBlockNumber == 0 || minimumBlockNumber <= block.number, 'Minimum block number not reached yet.');
            require(maximumBlockNumber == 0 || maximumBlockNumber >= block.number, 'Formula validity already expired.');
            return;
        }

        revert('Invalid operation');
    }

    function extractGenericEtherParams(Operation memory operation, uint256 endpointCount, uint256 signedEndpointCount) internal pure returns (uint16 fromIndex, uint16 to, uint256 amount) {

        bytes memory operandsPointer = operation.operands;

        uint256 shiftFromIndex = sizePointer;
        uint256 shiftTo = sizePointer + sizePointer;
        uint256 shiftAmount = sizePointer + sizePointer + sizeAmount;
        assembly {
            fromIndex := mload(add(operandsPointer, shiftFromIndex))
            to := mload(add(operandsPointer, shiftTo))
            amount := mload(add(operandsPointer, shiftAmount))
        }

        require(fromIndex < signedEndpointCount, 'Invalid signed endpoint pointer.');
        require(to < endpointCount, 'Invalid endpoint pointer.');
    }

    function extractGenericTokenParams(Operation memory operation, uint256 endpointCount, uint256 signedEndpointCount) internal pure returns (uint16 fromIndex, uint16 to, uint256 amountOrId, address token) {

        bytes memory operandsPointer = operation.operands;

        uint256 shiftFromIndex = sizePointer;
        uint256 shiftTo = sizePointer + sizePointer;
        uint256 shiftAmount = sizePointer + sizePointer + sizeAmount;
        uint256 shiftToken = sizePointer + sizePointer + sizeWord + sizeAddress;
        assembly {
            fromIndex := mload(add(operandsPointer, shiftFromIndex))
            to := mload(add(operandsPointer, shiftTo))
            amountOrId := mload(add(operandsPointer, shiftAmount))
            token := mload(add(operandsPointer, shiftToken))
        }

        require(fromIndex < signedEndpointCount, 'Invalid signed endpoint pointer.');
        require(to < endpointCount, 'Invalid endpoint pointer.');
    }
}


pragma solidity ^0.6.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}









contract DonationWithdrawal is Ownable, FormulasAdapter_Ether, FormulasAdapter_ERC721, FormulasAdapter_ERC20 {


    event DonationWithdrawal_Withdraw(uint8 resourceType, address to, uint256 amount, address tokenAddress);

    using SafeMath for uint256;

    function withdrawDonations(uint8 resourceType, address payable to, uint256 amountOrId, address tokenAddress) external onlyOwner {

        if (resourceType == 0) {
            require(amountOrId <= address(this).balance.sub(etherTotalBalance), 'Insufficient balance to withdraw');
            Address.sendValue(to, amountOrId);

            emit DonationWithdrawal_Withdraw(resourceType, to, amountOrId, address(0));
            return;
        }


        if (resourceType == 1) {
            IERC20(tokenAddress).transfer(to, amountOrId);

            emit DonationWithdrawal_Withdraw(resourceType, to, amountOrId, tokenAddress);
            return;
        }

        if (resourceType == 2) {
            IERC721(tokenAddress).transferFrom(address(this), to, amountOrId);

            emit DonationWithdrawal_Withdraw(resourceType, to, amountOrId, tokenAddress);
            return;
        }

        revert('Invalid type');
    }
}

pragma solidity ^0.6.0;



contract StaticUpdate is Ownable {


    event StaticUpdate_NewVersion(address newVersion);
    event StaticUpdate_SecurityHazard();

    address public nextVersion;
    address public newestVersion;
    bool public versionIsSecurityHazard;

    constructor() Ownable() public {

    }

    function setNewVerion(address newVersion, bool securityHazard) external onlyOwner {

        require(nextVersion == address(0), 'New version already set.'); // prevent this function from being called repeatedly

        nextVersion = newVersion;
        newestVersion = newVersion;

        emit StaticUpdate_NewVersion(newVersion);

        if (securityHazard) {
            markAsSecurityHazard();
        }
    }

    function markAsSecurityHazard() public onlyOwner {

        versionIsSecurityHazard = true;
        emit StaticUpdate_SecurityHazard();
    }

    function findTheNewestVersion() external returns (address) {

        if (newestVersion == address(0)) {
            return address(this);
        }

        newestVersion = StaticUpdate(newestVersion).findTheNewestVersion();
        return newestVersion;
    }
}
pragma solidity ^0.6.0;










contract CryptoFormulas is Ownable, FormulaDecompiler, FormulaValidator, FormulaResolver, DonationWithdrawal, StaticUpdate {


    event Formulas_FormulaExecuted(bytes32 indexed messageHash);

    mapping(bytes32 => bool) public executedFormulas;

    constructor() StaticUpdate() public {

    }

    function executeFormula(bytes calldata compiledFormula) external payable {

        Formula memory formulaInfo = decompileFormulaCompiled(compiledFormula);
        bytes32 hash = calcFormulaHash(formulaInfo);

        require(!executedFormulas[hash], 'Formula already executed.');
        executedFormulas[hash] = true;

        require(validateFormula(formulaInfo, hash), 'Invalid formula.');

        if (msg.value > 0) {
            ether_recieve(msg.sender, msg.value);
        }

        resolveFormula(formulaInfo);

        emit Formulas_FormulaExecuted(hash);
    }

    function topUpEther() external payable {

        require(msg.value > 0, 'Must top-up more than zero Wei');

        ether_recieve(msg.sender, msg.value);
    }

    receive() external payable {
        require(msg.value > 0, "Can't receive zero Wei");

        ether_recieve(msg.sender, msg.value);
    }

}