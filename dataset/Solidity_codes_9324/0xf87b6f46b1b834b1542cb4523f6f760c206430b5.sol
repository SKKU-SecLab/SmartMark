
pragma solidity ^0.6.5;


library LibBytesRichErrorsV06 {


    enum InvalidByteOperationErrorCodes {
        FromLessThanOrEqualsToRequired,
        ToLessThanOrEqualsLengthRequired,
        LengthGreaterThanZeroRequired,
        LengthGreaterThanOrEqualsFourRequired,
        LengthGreaterThanOrEqualsTwentyRequired,
        LengthGreaterThanOrEqualsThirtyTwoRequired,
        LengthGreaterThanOrEqualsNestedBytesLengthRequired,
        DestinationLengthGreaterThanOrEqualSourceLengthRequired
    }

    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR =
        0x28006595;

    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            INVALID_BYTE_OPERATION_ERROR_SELECTOR,
            errorCode,
            offset,
            required
        );
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibRichErrorsV06 {


    bytes4 internal constant STANDARD_ERROR_SELECTOR = 0x08c379a0;

    function StandardError(string memory message)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            STANDARD_ERROR_SELECTOR,
            bytes(message)
        );
    }

    function rrevert(bytes memory errorData)
        internal
        pure
    {

        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



library LibBytesV06 {


    using LibBytesV06 for bytes;

    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {

        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }

    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {

        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {

        if (length < 32) {
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            if (source == dest) {
                return;
            }

            if (source > dest) {
                assembly {
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    let last := mload(sEnd)

                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    let first := mload(source)

                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                    mstore(dest, first)
                }
            }
        }
    }

    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        if (from > to) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }

    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        if (from > to) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        if (b.length == 0) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanZeroRequired,
                b.length,
                0
            ));
        }

        result = b[b.length - 1];

        assembly {
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        if (b.length < index + 20) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

        index += 20;

        assembly {
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        if (b.length < index + 20) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

        index += 20;

        assembly {

            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )

            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            mstore(add(b, index), xor(input, neighbors))
        }
    }

    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        if (b.length < index + 32) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        index += 32;

        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        if (b.length < index + 32) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        index += 32;

        assembly {
            mstore(add(b, index), input)
        }
    }

    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        if (b.length < index + 4) {
            LibRichErrorsV06.rrevert(LibBytesRichErrorsV06.InvalidByteOperationError(
                LibBytesRichErrorsV06.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsFourRequired,
                b.length,
                index + 4
            ));
        }

        index += 32;

        assembly {
            result := mload(add(b, index))
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    function writeLength(bytes memory b, uint256 length)
        internal
        pure
    {
        assembly {
            mstore(b, length)
        }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibProxyRichErrors {



    function NotImplementedError(bytes4 selector)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("NotImplementedError(bytes4)")),
            selector
        );
    }

    function InvalidBootstrapCallerError(address actual, address expected)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("InvalidBootstrapCallerError(address,address)")),
            actual,
            expected
        );
    }

    function InvalidDieCallerError(address actual, address expected)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("InvalidDieCallerError(address,address)")),
            actual,
            expected
        );
    }

    function BootstrapCallFailedError(address target, bytes memory resultData)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("BootstrapCallFailedError(address,bytes)")),
            target,
            resultData
        );
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;
pragma experimental ABIEncoderV2;



library LibBootstrap {


    bytes4 internal constant BOOTSTRAP_SUCCESS = 0xd150751b;

    using LibRichErrorsV06 for bytes;

    function delegatecallBootstrapFunction(
        address target,
        bytes memory data
    )
        internal
    {

        (bool success, bytes memory resultData) = target.delegatecall(data);
        if (!success ||
            resultData.length != 32 ||
            abi.decode(resultData, (bytes4)) != BOOTSTRAP_SUCCESS)
        {
            LibProxyRichErrors.BootstrapCallFailedError(target, resultData).rrevert();
        }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibStorage {


    uint256 private constant STORAGE_SLOT_EXP = 128;

    enum StorageId {
        Proxy,
        SimpleFunctionRegistry,
        Ownable,
        TokenSpender,
        TransformERC20
    }

    function getStorageSlot(StorageId storageId)
        internal
        pure
        returns (uint256 slot)
    {

        return (uint256(storageId) + 1) << STORAGE_SLOT_EXP;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



library LibProxyStorage {


    struct Storage {
        mapping(bytes4 => address) impls;
        address owner;
    }

    function getStorage() internal pure returns (Storage storage stor) {

        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.Proxy
        );
        assembly { stor_slot := storageSlot }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


interface IBootstrap {


    function bootstrap(address target, bytes calldata callData) external;

}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract Bootstrap is
    IBootstrap
{

    address immutable private _deployer;
    address immutable private _implementation;
    address immutable private _bootstrapCaller;

    using LibRichErrorsV06 for bytes;

    constructor(address bootstrapCaller) public {
        _deployer = msg.sender;
        _implementation = address(this);
        _bootstrapCaller = bootstrapCaller;
    }

    function bootstrap(address target, bytes calldata callData) external override {

        if (msg.sender != _bootstrapCaller) {
            LibProxyRichErrors.InvalidBootstrapCallerError(
                msg.sender,
                _bootstrapCaller
            ).rrevert();
        }
        LibProxyStorage.getStorage().impls[this.bootstrap.selector] = address(0);
        Bootstrap(_implementation).die();
        LibBootstrap.delegatecallBootstrapFunction(target, callData);
    }

    function die() external {

        if (msg.sender != _deployer) {
            LibProxyRichErrors.InvalidDieCallerError(msg.sender, _deployer).rrevert();
        }
        selfdestruct(msg.sender);
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract ZeroEx {

    using LibBytesV06 for bytes;

    constructor() public {
        Bootstrap bootstrap = new Bootstrap(msg.sender);
        LibProxyStorage.getStorage().impls[bootstrap.bootstrap.selector] =
            address(bootstrap);
    }


    fallback() external payable {
        bytes4 selector = msg.data.readBytes4(0);
        address impl = getFunctionImplementation(selector);
        if (impl == address(0)) {
            _revertWithData(LibProxyRichErrors.NotImplementedError(selector));
        }

        (bool success, bytes memory resultData) = impl.delegatecall(msg.data);
        if (!success) {
            _revertWithData(resultData);
        }
        _returnWithData(resultData);
    }

    receive() external payable {}


    function getFunctionImplementation(bytes4 selector)
        public
        view
        returns (address impl)
    {

        return LibProxyStorage.getStorage().impls[selector];
    }

    function _revertWithData(bytes memory data) private pure {

        assembly { revert(add(data, 32), mload(data)) }
    }

    function _returnWithData(bytes memory data) private pure {

        assembly { return(add(data, 32), mload(data)) }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibCommonRichErrors {



    function OnlyCallableBySelfError(address sender)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("OnlyCallableBySelfError(address)")),
            sender
        );
    }

    function IllegalReentrancyError()
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("IllegalReentrancyError()"))
        );
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibOwnableRichErrors {



    function OnlyOwnerError(
        address sender,
        address owner
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("OnlyOwnerError(address,address)")),
            sender,
            owner
        );
    }

    function TransferOwnerToZeroError()
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("TransferOwnerToZeroError()"))
        );
    }

    function MigrateCallFailedError(address target, bytes memory resultData)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("MigrateCallFailedError(address,bytes)")),
            target,
            resultData
        );
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibSimpleFunctionRegistryRichErrors {



    function NotInRollbackHistoryError(bytes4 selector, address targetImpl)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("NotInRollbackHistoryError(bytes4,address)")),
            selector,
            targetImpl
        );
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibSpenderRichErrors {



    function SpenderERC20TransferFromFailedError(
        address token,
        address owner,
        address to,
        uint256 amount,
        bytes memory errorData
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("SpenderERC20TransferFromFailedError(address,address,address,uint256,bytes)")),
            token,
            owner,
            to,
            amount,
            errorData
        );
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibTransformERC20RichErrors {



    function InsufficientEthAttachedError(
        uint256 ethAttached,
        uint256 ethNeeded
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("InsufficientEthAttachedError(uint256,uint256)")),
            ethAttached,
            ethNeeded
        );
    }

    function IncompleteTransformERC20Error(
        address outputToken,
        uint256 outputTokenAmount,
        uint256 minOutputTokenAmount
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("IncompleteTransformERC20Error(address,uint256,uint256)")),
            outputToken,
            outputTokenAmount,
            minOutputTokenAmount
        );
    }

    function NegativeTransformERC20OutputError(
        address outputToken,
        uint256 outputTokenLostAmount
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("NegativeTransformERC20OutputError(address,uint256)")),
            outputToken,
            outputTokenLostAmount
        );
    }

    function TransformerFailedError(
        address transformer,
        bytes memory transformerData,
        bytes memory resultData
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("TransformerFailedError(address,bytes,bytes)")),
            transformer,
            transformerData,
            resultData
        );
    }


    function OnlyCallableByDeployerError(
        address caller,
        address deployer
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("OnlyCallableByDeployerError(address,address)")),
            caller,
            deployer
        );
    }

    function InvalidExecutionContextError(
        address actualContext,
        address expectedContext
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("InvalidExecutionContextError(address,address)")),
            actualContext,
            expectedContext
        );
    }

    enum InvalidTransformDataErrorCode {
        INVALID_TOKENS,
        INVALID_ARRAY_LENGTH
    }

    function InvalidTransformDataError(
        InvalidTransformDataErrorCode errorCode,
        bytes memory transformData
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("InvalidTransformDataError(uint8,bytes)")),
            errorCode,
            transformData
        );
    }


    function IncompleteFillSellQuoteError(
        address sellToken,
        uint256 soldAmount,
        uint256 sellAmount
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("IncompleteFillSellQuoteError(address,uint256,uint256)")),
            sellToken,
            soldAmount,
            sellAmount
        );
    }

    function IncompleteFillBuyQuoteError(
        address buyToken,
        uint256 boughtAmount,
        uint256 buyAmount
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("IncompleteFillBuyQuoteError(address,uint256,uint256)")),
            buyToken,
            boughtAmount,
            buyAmount
        );
    }

    function InsufficientTakerTokenError(
        uint256 tokenBalance,
        uint256 tokensNeeded
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("InsufficientTakerTokenError(uint256,uint256)")),
            tokenBalance,
            tokensNeeded
        );
    }

    function InsufficientProtocolFeeError(
        uint256 ethBalance,
        uint256 ethNeeded
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("InsufficientProtocolFeeError(uint256,uint256)")),
            ethBalance,
            ethNeeded
        );
    }

    function InvalidERC20AssetDataError(
        bytes memory assetData
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("InvalidERC20AssetDataError(bytes)")),
            assetData
        );
    }

    function InvalidTakerFeeTokenError(
        address token
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("InvalidTakerFeeTokenError(address)")),
            token
        );
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibWalletRichErrors {



    function WalletExecuteCallFailedError(
        address wallet,
        address callTarget,
        bytes memory callData,
        uint256 callValue,
        bytes memory errorData
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("WalletExecuteCallFailedError(address,address,bytes,uint256,bytes)")),
            wallet,
            callTarget,
            callData,
            callValue,
            errorData
        );
    }

    function WalletExecuteDelegateCallFailedError(
        address wallet,
        address callTarget,
        bytes memory callData,
        bytes memory errorData
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            bytes4(keccak256("WalletExecuteDelegateCallFailedError(address,address,bytes,bytes)")),
            wallet,
            callTarget,
            callData,
            errorData
        );
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


interface IOwnableV06 {


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function transferOwnership(address newOwner) external;


    function owner() external view returns (address ownerAddress);

}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



interface IAuthorizableV06 is
    IOwnableV06
{

    event AuthorizedAddressAdded(
        address indexed target,
        address indexed caller
    );

    event AuthorizedAddressRemoved(
        address indexed target,
        address indexed caller
    );

    function addAuthorizedAddress(address target)
        external;


    function removeAuthorizedAddress(address target)
        external;


    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        external;


    function getAuthorizedAddresses()
        external
        view
        returns (address[] memory authorizedAddresses);


    function authorized(address addr) external view returns (bool isAuthorized);


    function authorities(uint256 idx) external view returns (address addr);


}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibAuthorizableRichErrorsV06 {


    bytes4 internal constant AUTHORIZED_ADDRESS_MISMATCH_ERROR_SELECTOR =
        0x140a84db;

    bytes4 internal constant INDEX_OUT_OF_BOUNDS_ERROR_SELECTOR =
        0xe9f83771;

    bytes4 internal constant SENDER_NOT_AUTHORIZED_ERROR_SELECTOR =
        0xb65a25b9;

    bytes4 internal constant TARGET_ALREADY_AUTHORIZED_ERROR_SELECTOR =
        0xde16f1a0;

    bytes4 internal constant TARGET_NOT_AUTHORIZED_ERROR_SELECTOR =
        0xeb5108a2;

    bytes internal constant ZERO_CANT_BE_AUTHORIZED_ERROR_BYTES =
        hex"57654fe4";

    function AuthorizedAddressMismatchError(
        address authorized,
        address target
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            AUTHORIZED_ADDRESS_MISMATCH_ERROR_SELECTOR,
            authorized,
            target
        );
    }

    function IndexOutOfBoundsError(
        uint256 index,
        uint256 length
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            INDEX_OUT_OF_BOUNDS_ERROR_SELECTOR,
            index,
            length
        );
    }

    function SenderNotAuthorizedError(address sender)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            SENDER_NOT_AUTHORIZED_ERROR_SELECTOR,
            sender
        );
    }

    function TargetAlreadyAuthorizedError(address target)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            TARGET_ALREADY_AUTHORIZED_ERROR_SELECTOR,
            target
        );
    }

    function TargetNotAuthorizedError(address target)
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            TARGET_NOT_AUTHORIZED_ERROR_SELECTOR,
            target
        );
    }

    function ZeroCantBeAuthorizedError()
        internal
        pure
        returns (bytes memory)
    {

        return ZERO_CANT_BE_AUTHORIZED_ERROR_BYTES;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/
pragma solidity ^0.6.5;


library LibOwnableRichErrorsV06 {


    bytes4 internal constant ONLY_OWNER_ERROR_SELECTOR =
        0x1de45ad1;

    bytes internal constant TRANSFER_OWNER_TO_ZERO_ERROR_BYTES =
        hex"e69edc3e";

    function OnlyOwnerError(
        address sender,
        address owner
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            ONLY_OWNER_ERROR_SELECTOR,
            sender,
            owner
        );
    }

    function TransferOwnerToZeroError()
        internal
        pure
        returns (bytes memory)
    {

        return TRANSFER_OWNER_TO_ZERO_ERROR_BYTES;
    }
}/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract OwnableV06 is
    IOwnableV06
{

    address public override owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        _assertSenderIsOwner();
        _;
    }

    function transferOwnership(address newOwner)
        public
        override
        onlyOwner
    {

        if (newOwner == address(0)) {
            LibRichErrorsV06.rrevert(LibOwnableRichErrorsV06.TransferOwnerToZeroError());
        } else {
            owner = newOwner;
            emit OwnershipTransferred(msg.sender, newOwner);
        }
    }

    function _assertSenderIsOwner()
        internal
        view
    {

        if (msg.sender != owner) {
            LibRichErrorsV06.rrevert(LibOwnableRichErrorsV06.OnlyOwnerError(
                msg.sender,
                owner
            ));
        }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract AuthorizableV06 is
    OwnableV06,
    IAuthorizableV06
{

    modifier onlyAuthorized {

        _assertSenderIsAuthorized();
        _;
    }

    mapping (address => bool) public override authorized;
    address[] public override authorities;

    constructor()
        public
        OwnableV06()
    {}

    function addAuthorizedAddress(address target)
        external
        override
        onlyOwner
    {

        _addAuthorizedAddress(target);
    }

    function removeAuthorizedAddress(address target)
        external
        override
        onlyOwner
    {

        if (!authorized[target]) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.TargetNotAuthorizedError(target));
        }
        for (uint256 i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                _removeAuthorizedAddressAtIndex(target, i);
                break;
            }
        }
    }

    function removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        external
        override
        onlyOwner
    {

        _removeAuthorizedAddressAtIndex(target, index);
    }

    function getAuthorizedAddresses()
        external
        override
        view
        returns (address[] memory)
    {

        return authorities;
    }

    function _assertSenderIsAuthorized()
        internal
        view
    {

        if (!authorized[msg.sender]) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.SenderNotAuthorizedError(msg.sender));
        }
    }

    function _addAuthorizedAddress(address target)
        internal
    {

        if (target == address(0)) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.ZeroCantBeAuthorizedError());
        }

        if (authorized[target]) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.TargetAlreadyAuthorizedError(target));
        }

        authorized[target] = true;
        authorities.push(target);
        emit AuthorizedAddressAdded(target, msg.sender);
    }

    function _removeAuthorizedAddressAtIndex(
        address target,
        uint256 index
    )
        internal
    {

        if (!authorized[target]) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.TargetNotAuthorizedError(target));
        }
        if (index >= authorities.length) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.IndexOutOfBoundsError(
                index,
                authorities.length
            ));
        }
        if (authorities[index] != target) {
            LibRichErrorsV06.rrevert(LibAuthorizableRichErrorsV06.AuthorizedAddressMismatchError(
                authorities[index],
                target
            ));
        }

        delete authorized[target];
        authorities[index] = authorities[authorities.length - 1];
        authorities.pop();
        emit AuthorizedAddressRemoved(target, msg.sender);
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



interface IAllowanceTarget is
    IAuthorizableV06
{

    function executeCall(
        address payable target,
        bytes calldata callData
    )
        external
        returns (bytes memory resultData);

}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract AllowanceTarget is
    IAllowanceTarget,
    AuthorizableV06
{

    using LibRichErrorsV06 for bytes;

    function executeCall(
        address payable target,
        bytes calldata callData
    )
        external
        override
        onlyAuthorized
        returns (bytes memory resultData)
    {

        bool success;
        (success, resultData) = target.call(callData);
        if (!success) {
            resultData.rrevert();
        }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



interface IFlashWallet {


    function executeCall(
        address payable target,
        bytes calldata callData,
        uint256 value
    )
        external
        payable
        returns (bytes memory resultData);


    function executeDelegateCall(
        address payable target,
        bytes calldata callData
    )
        external
        payable
        returns (bytes memory resultData);


    receive() external payable;

    function owner() external view returns (address owner_);

}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract FlashWallet is
    IFlashWallet
{

    using LibRichErrorsV06 for bytes;

    address public override immutable owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() virtual {

        if (msg.sender != owner) {
            LibOwnableRichErrorsV06.OnlyOwnerError(
                msg.sender,
                owner
            ).rrevert();
        }
        _;
    }

    function executeCall(
        address payable target,
        bytes calldata callData,
        uint256 value
    )
        external
        payable
        override
        onlyOwner
        returns (bytes memory resultData)
    {

        bool success;
        (success, resultData) = target.call{value: value}(callData);
        if (!success) {
            LibWalletRichErrors
                .WalletExecuteCallFailedError(
                    address(this),
                    target,
                    callData,
                    value,
                    resultData
                )
                .rrevert();
        }
    }

    function executeDelegateCall(
        address payable target,
        bytes calldata callData
    )
        external
        payable
        override
        onlyOwner
        returns (bytes memory resultData)
    {

        bool success;
        (success, resultData) = target.delegatecall(callData);
        if (!success) {
            LibWalletRichErrors
                .WalletExecuteDelegateCallFailedError(
                    address(this),
                    target,
                    callData,
                    resultData
                )
                .rrevert();
        }
    }

    receive() external override payable {}

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        returns (bool hasSupport)
    {

        return  interfaceID == this.supportsInterface.selector ||
                interfaceID == this.onERC1155Received.selector ^ this.onERC1155BatchReceived.selector ||
                interfaceID == this.tokenFallback.selector;
    }

    function onERC1155Received(
        address, // operator,
        address, // from,
        uint256, // id,
        uint256, // value,
        bytes calldata //data
    )
        external
        pure
        returns (bytes4 success)
    {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address, // operator,
        address, // from,
        uint256[] calldata, // ids,
        uint256[] calldata, // values,
        bytes calldata // data
    )
        external
        pure
        returns (bytes4 success)
    {

        return this.onERC1155BatchReceived.selector;
    }

    function tokenFallback(
        address, // from,
        uint256, // value,
        bytes calldata // value
    )
        external
        pure
    {}

}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



interface IKillable {
    function die() external;
}

contract TransformerDeployer is
    AuthorizableV06
{
    event Deployed(address deployedAddress, uint256 nonce, address sender);
    event Killed(address target, address sender);

    uint256 public nonce = 1;
    mapping (address => uint256) public toDeploymentNonce;

    constructor(address[] memory authorities) public {
        for (uint256 i = 0; i < authorities.length; ++i) {
            _addAuthorizedAddress(authorities[i]);
        }
    }

    function deploy(bytes memory bytecode)
        public
        payable
        onlyAuthorized
        returns (address deployedAddress)
    {
        uint256 deploymentNonce = nonce;
        nonce += 1;
        assembly {
            deployedAddress := create(callvalue(), add(bytecode, 32), mload(bytecode))
        }
        toDeploymentNonce[deployedAddress] = deploymentNonce;
        emit Deployed(deployedAddress, deploymentNonce, msg.sender);
    }

    function kill(IKillable target)
        public
        onlyAuthorized
    {
        target.die();
        emit Killed(address(target), msg.sender);
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


interface IFeature {


    function FEATURE_NAME() external view returns (string memory name);

    function FEATURE_VERSION() external view returns (uint256 version);
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



interface IOwnable is
    IOwnableV06
{
    event Migrated(address caller, address migrator, address newOwner);

    function migrate(address target, bytes calldata data, address newOwner) external;
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


interface ISimpleFunctionRegistry {

    event ProxyFunctionUpdated(bytes4 indexed selector, address oldImpl, address newImpl);

    function rollback(bytes4 selector, address targetImpl) external;

    function extend(bytes4 selector, address impl) external;

    function getRollbackLength(bytes4 selector)
        external
        view
        returns (uint256 rollbackLength);

    function getRollbackEntryAtIndex(bytes4 selector, uint256 idx)
        external
        view
        returns (address impl);
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


interface IERC20TokenV06 {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function transfer(address to, uint256 value)
        external
        returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external
        returns (bool);

    function approve(address spender, uint256 value)
        external
        returns (bool);

    function totalSupply()
        external
        view
        returns (uint256);

    function balanceOf(address owner)
        external
        view
        returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function decimals()
        external
        view
        returns (uint8);
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



interface ITokenSpender {

    function _spendERC20Tokens(
        IERC20TokenV06 token,
        address owner,
        address to,
        uint256 amount
    )
        external;

    function getSpendableERC20BalanceOf(IERC20TokenV06 token, address owner)
        external
        view
        returns (uint256 amount);

    function getAllowanceTarget() external view returns (address target);
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



interface IERC20Transformer {

    function transform(
        bytes32 callDataHash,
        address payable taker,
        bytes calldata data
    )
        external
        returns (bytes4 success);
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



interface ITransformERC20 {

    struct Transformation {
        uint32 deploymentNonce;
        bytes data;
    }

    event TransformedERC20(
        address indexed taker,
        address inputToken,
        address outputToken,
        uint256 inputTokenAmount,
        uint256 outputTokenAmount
    );

    event TransformerDeployerUpdated(address transformerDeployer);

    function setTransformerDeployer(address transformerDeployer)
        external;

    function createTransformWallet()
        external
        returns (IFlashWallet wallet);

    function transformERC20(
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 inputTokenAmount,
        uint256 minOutputTokenAmount,
        Transformation[] calldata transformations
    )
        external
        payable
        returns (uint256 outputTokenAmount);

    function _transformERC20(
        bytes32 callDataHash,
        address payable taker,
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 inputTokenAmount,
        uint256 minOutputTokenAmount,
        Transformation[] calldata transformations
    )
        external
        payable
        returns (uint256 outputTokenAmount);

    function getTransformWallet()
        external
        view
        returns (IFlashWallet wallet);

    function getTransformerDeployer()
        external
        view
        returns (address deployer);
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract FixinCommon {

    using LibRichErrorsV06 for bytes;

    modifier onlySelf() virtual {
        if (msg.sender != address(this)) {
            LibCommonRichErrors.OnlyCallableBySelfError(msg.sender).rrevert();
        }
        _;
    }

    modifier onlyOwner() virtual {
        {
            address owner = IOwnable(address(this)).owner();
            if (msg.sender != owner) {
                LibOwnableRichErrors.OnlyOwnerError(
                    msg.sender,
                    owner
                ).rrevert();
            }
        }
        _;
    }

    function _encodeVersion(uint32 major, uint32 minor, uint32 revision)
        internal
        pure
        returns (uint256 encodedVersion)
    {
        return (major << 64) | (minor << 32) | revision;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



library LibOwnableStorage {

    struct Storage {
        address owner;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.Ownable
        );
        assembly { stor_slot := storageSlot }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



library LibMigrate {

    bytes4 internal constant MIGRATE_SUCCESS = 0x2c64c5ef;

    using LibRichErrorsV06 for bytes;

    function delegatecallMigrateFunction(
        address target,
        bytes memory data
    )
        internal
    {
        (bool success, bytes memory resultData) = target.delegatecall(data);
        if (!success ||
            resultData.length != 32 ||
            abi.decode(resultData, (bytes4)) != MIGRATE_SUCCESS)
        {
            LibOwnableRichErrors.MigrateCallFailedError(target, resultData).rrevert();
        }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



library LibSimpleFunctionRegistryStorage {

    struct Storage {
        mapping(bytes4 => address[]) implHistory;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.SimpleFunctionRegistry
        );
        assembly { stor_slot := storageSlot }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract SimpleFunctionRegistry is
    IFeature,
    ISimpleFunctionRegistry,
    FixinCommon
{
    string public constant override FEATURE_NAME = "SimpleFunctionRegistry";
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);
    address private immutable _implementation;

    using LibRichErrorsV06 for bytes;

    constructor() public {
        _implementation = address(this);
    }

    function bootstrap()
        external
        returns (bytes4 success)
    {
        _extend(this.extend.selector, _implementation);
        _extend(this._extendSelf.selector, _implementation);
        _extend(this.rollback.selector, _implementation);
        _extend(this.getRollbackLength.selector, _implementation);
        _extend(this.getRollbackEntryAtIndex.selector, _implementation);
        return LibBootstrap.BOOTSTRAP_SUCCESS;
    }

    function rollback(bytes4 selector, address targetImpl)
        external
        override
        onlyOwner
    {
        (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        ) = _getStorages();

        address currentImpl = proxyStor.impls[selector];
        if (currentImpl == targetImpl) {
            return;
        }
        address[] storage history = stor.implHistory[selector];
        uint256 i = history.length;
        for (; i > 0; --i) {
            address impl = history[i - 1];
            history.pop();
            if (impl == targetImpl) {
                break;
            }
        }
        if (i == 0) {
            LibSimpleFunctionRegistryRichErrors.NotInRollbackHistoryError(
                selector,
                targetImpl
            ).rrevert();
        }
        proxyStor.impls[selector] = targetImpl;
        emit ProxyFunctionUpdated(selector, currentImpl, targetImpl);
    }

    function extend(bytes4 selector, address impl)
        external
        override
        onlyOwner
    {
        _extend(selector, impl);
    }

    function _extendSelf(bytes4 selector, address impl)
        external
        onlySelf
    {
        _extend(selector, impl);
    }

    function getRollbackLength(bytes4 selector)
        external
        override
        view
        returns (uint256 rollbackLength)
    {
        return LibSimpleFunctionRegistryStorage.getStorage().implHistory[selector].length;
    }

    function getRollbackEntryAtIndex(bytes4 selector, uint256 idx)
        external
        override
        view
        returns (address impl)
    {
        return LibSimpleFunctionRegistryStorage.getStorage().implHistory[selector][idx];
    }

    function _extend(bytes4 selector, address impl)
        private
    {
        (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        ) = _getStorages();

        address oldImpl = proxyStor.impls[selector];
        address[] storage history = stor.implHistory[selector];
        history.push(oldImpl);
        proxyStor.impls[selector] = impl;
        emit ProxyFunctionUpdated(selector, oldImpl, impl);
    }

    function _getStorages()
        private
        pure
        returns (
            LibSimpleFunctionRegistryStorage.Storage storage stor,
            LibProxyStorage.Storage storage proxyStor
        )
    {
        return (
            LibSimpleFunctionRegistryStorage.getStorage(),
            LibProxyStorage.getStorage()
        );
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract Ownable is
    IFeature,
    IOwnable,
    FixinCommon
{

    string public constant override FEATURE_NAME = "Ownable";
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);
    address immutable private _implementation;

    using LibRichErrorsV06 for bytes;

    constructor() public {
        _implementation = address(this);
    }

    function bootstrap() external returns (bytes4 success) {
        LibOwnableStorage.getStorage().owner = address(this);

        SimpleFunctionRegistry(address(this))._extendSelf(this.transferOwnership.selector, _implementation);
        SimpleFunctionRegistry(address(this))._extendSelf(this.owner.selector, _implementation);
        SimpleFunctionRegistry(address(this))._extendSelf(this.migrate.selector, _implementation);
        return LibBootstrap.BOOTSTRAP_SUCCESS;
    }

    function transferOwnership(address newOwner)
        external
        override
        onlyOwner
    {
        LibOwnableStorage.Storage storage proxyStor = LibOwnableStorage.getStorage();

        if (newOwner == address(0)) {
            LibOwnableRichErrors.TransferOwnerToZeroError().rrevert();
        } else {
            proxyStor.owner = newOwner;
            emit OwnershipTransferred(msg.sender, newOwner);
        }
    }

    function migrate(address target, bytes calldata data, address newOwner)
        external
        override
        onlyOwner
    {
        if (newOwner == address(0)) {
            LibOwnableRichErrors.TransferOwnerToZeroError().rrevert();
        }

        LibOwnableStorage.Storage storage stor = LibOwnableStorage.getStorage();
        stor.owner = address(this);

        LibMigrate.delegatecallMigrateFunction(target, data);

        stor.owner = newOwner;

        emit Migrated(msg.sender, target, newOwner);
    }

    function owner() external override view returns (address owner_) {
        return LibOwnableStorage.getStorage().owner;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibSafeMathRichErrorsV06 {

    bytes4 internal constant UINT256_BINOP_ERROR_SELECTOR =
        0xe946c1bb;

    bytes4 internal constant UINT256_DOWNCAST_ERROR_SELECTOR =
        0xc996af7b;

    enum BinOpErrorCodes {
        ADDITION_OVERFLOW,
        MULTIPLICATION_OVERFLOW,
        SUBTRACTION_UNDERFLOW,
        DIVISION_BY_ZERO
    }

    enum DowncastErrorCodes {
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT32,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96
    }

    function Uint256BinOpError(
        BinOpErrorCodes errorCode,
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            UINT256_BINOP_ERROR_SELECTOR,
            errorCode,
            a,
            b
        );
    }

    function Uint256DowncastError(
        DowncastErrorCodes errorCode,
        uint256 a
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            UINT256_DOWNCAST_ERROR_SELECTOR,
            errorCode,
            a
        );
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



library LibSafeMathV06 {

    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a != b) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function safeDiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (b == 0) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.DIVISION_BY_ZERO,
                a,
                b
            ));
        }
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (b > a) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                a,
                b
            ));
        }
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        if (c < a) {
            LibRichErrorsV06.rrevert(LibSafeMathRichErrorsV06.Uint256BinOpError(
                LibSafeMathRichErrorsV06.BinOpErrorCodes.ADDITION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function max256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



library LibERC20TokenV06 {
    bytes constant private DECIMALS_CALL_DATA = hex"313ce567";

    function compatApprove(
        IERC20TokenV06 token,
        address spender,
        uint256 allowance
    )
        internal
    {
        bytes memory callData = abi.encodeWithSelector(
            token.approve.selector,
            spender,
            allowance
        );
        _callWithOptionalBooleanResult(address(token), callData);
    }

    function approveIfBelow(
        IERC20TokenV06 token,
        address spender,
        uint256 amount
    )
        internal
    {
        if (token.allowance(address(this), spender) < amount) {
            compatApprove(token, spender, uint256(-1));
        }
    }

    function compatTransfer(
        IERC20TokenV06 token,
        address to,
        uint256 amount
    )
        internal
    {
        bytes memory callData = abi.encodeWithSelector(
            token.transfer.selector,
            to,
            amount
        );
        _callWithOptionalBooleanResult(address(token), callData);
    }

    function compatTransferFrom(
        IERC20TokenV06 token,
        address from,
        address to,
        uint256 amount
    )
        internal
    {
        bytes memory callData = abi.encodeWithSelector(
            token.transferFrom.selector,
            from,
            to,
            amount
        );
        _callWithOptionalBooleanResult(address(token), callData);
    }

    function compatDecimals(IERC20TokenV06 token)
        internal
        view
        returns (uint8 tokenDecimals)
    {
        tokenDecimals = 18;
        (bool didSucceed, bytes memory resultData) = address(token).staticcall(DECIMALS_CALL_DATA);
        if (didSucceed && resultData.length == 32) {
            tokenDecimals = uint8(LibBytesV06.readUint256(resultData, 0));
        }
    }

    function compatAllowance(IERC20TokenV06 token, address owner, address spender)
        internal
        view
        returns (uint256 allowance_)
    {
        (bool didSucceed, bytes memory resultData) = address(token).staticcall(
            abi.encodeWithSelector(
                token.allowance.selector,
                owner,
                spender
            )
        );
        if (didSucceed && resultData.length == 32) {
            allowance_ = LibBytesV06.readUint256(resultData, 0);
        }
    }

    function compatBalanceOf(IERC20TokenV06 token, address owner)
        internal
        view
        returns (uint256 balance)
    {
        (bool didSucceed, bytes memory resultData) = address(token).staticcall(
            abi.encodeWithSelector(
                token.balanceOf.selector,
                owner
            )
        );
        if (didSucceed && resultData.length == 32) {
            balance = LibBytesV06.readUint256(resultData, 0);
        }
    }

    function isSuccessfulResult(bytes memory resultData)
        internal
        pure
        returns (bool isSuccessful)
    {
        if (resultData.length == 0) {
            return true;
        }
        if (resultData.length == 32) {
            uint256 result = LibBytesV06.readUint256(resultData, 0);
            if (result == 1) {
                return true;
            }
        }
    }

    function _callWithOptionalBooleanResult(
        address target,
        bytes memory callData
    )
        private
    {
        (bool didSucceed, bytes memory resultData) = target.call(callData);
        if (didSucceed && isSuccessfulResult(resultData)) {
            return;
        }
        LibRichErrorsV06.rrevert(resultData);
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



library LibTokenSpenderStorage {

    struct Storage {
        IAllowanceTarget allowanceTarget;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.TokenSpender
        );
        assembly { stor_slot := storageSlot }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TokenSpender is
    IFeature,
    ITokenSpender,
    FixinCommon
{
    string public constant override FEATURE_NAME = "TokenSpender";
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);
    address private immutable _implementation;

    using LibRichErrorsV06 for bytes;

    constructor() public {
        _implementation = address(this);
    }

    function migrate(IAllowanceTarget allowanceTarget) external returns (bytes4 success) {
        LibTokenSpenderStorage.getStorage().allowanceTarget = allowanceTarget;
        ISimpleFunctionRegistry(address(this))
            .extend(this.getAllowanceTarget.selector, _implementation);
        ISimpleFunctionRegistry(address(this))
            .extend(this._spendERC20Tokens.selector, _implementation);
        ISimpleFunctionRegistry(address(this))
            .extend(this.getSpendableERC20BalanceOf.selector, _implementation);
        return LibMigrate.MIGRATE_SUCCESS;
    }

    function _spendERC20Tokens(
        IERC20TokenV06 token,
        address owner,
        address to,
        uint256 amount
    )
        external
        override
        onlySelf
    {
        IAllowanceTarget spender = LibTokenSpenderStorage.getStorage().allowanceTarget;
        (bool didSucceed, bytes memory resultData) = address(spender).call(
            abi.encodeWithSelector(
                IAllowanceTarget.executeCall.selector,
                address(token),
                abi.encodeWithSelector(
                    IERC20TokenV06.transferFrom.selector,
                    owner,
                    to,
                    amount
                )
            )
        );
        if (didSucceed) {
            resultData = abi.decode(resultData, (bytes));
        }
        if (!didSucceed || !LibERC20TokenV06.isSuccessfulResult(resultData)) {
            LibSpenderRichErrors.SpenderERC20TransferFromFailedError(
                address(token),
                owner,
                to,
                amount,
                resultData
            ).rrevert();
        }
    }

    function getSpendableERC20BalanceOf(IERC20TokenV06 token, address owner)
        external
        override
        view
        returns (uint256 amount)
    {
        return LibSafeMathV06.min256(
            token.allowance(owner, address(LibTokenSpenderStorage.getStorage().allowanceTarget)),
            token.balanceOf(owner)
        );
    }

    function getAllowanceTarget()
        external
        override
        view
        returns (address target)
    {
        return address(LibTokenSpenderStorage.getStorage().allowanceTarget);
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



library LibTransformERC20Storage {

    struct Storage {
        IFlashWallet wallet;
        address transformerDeployer;
    }

    function getStorage() internal pure returns (Storage storage stor) {
        uint256 storageSlot = LibStorage.getStorageSlot(
            LibStorage.StorageId.TransformERC20
        );
        assembly { stor_slot := storageSlot }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



library LibERC20Transformer {

    using LibERC20TokenV06 for IERC20TokenV06;

    address constant internal ETH_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    bytes4 constant internal TRANSFORMER_SUCCESS = 0x13c9929e;

    function transformerTransfer(
        IERC20TokenV06 token,
        address payable to,
        uint256 amount
    )
        internal
    {
        if (isTokenETH(token)) {
            to.transfer(amount);
        } else {
            token.compatTransfer(to, amount);
        }
    }

    function isTokenETH(IERC20TokenV06 token)
        internal
        pure
        returns (bool isETH)
    {
        return address(token) == ETH_TOKEN_ADDRESS;
    }

    function getTokenBalanceOf(IERC20TokenV06 token, address owner)
        internal
        view
        returns (uint256 tokenBalance)
    {
        if (isTokenETH(token)) {
            return owner.balance;
        }
        return token.balanceOf(owner);
    }

    function rlpEncodeNonce(uint32 nonce)
        internal
        pure
        returns (bytes memory rlpNonce)
    {
        if (nonce == 0) {
            rlpNonce = new bytes(1);
            rlpNonce[0] = 0x80;
        } else if (nonce < 0x80) {
            rlpNonce = new bytes(1);
            rlpNonce[0] = byte(uint8(nonce));
        } else if (nonce <= 0xFF) {
            rlpNonce = new bytes(2);
            rlpNonce[0] = 0x81;
            rlpNonce[1] = byte(uint8(nonce));
        } else if (nonce <= 0xFFFF) {
            rlpNonce = new bytes(3);
            rlpNonce[0] = 0x82;
            rlpNonce[1] = byte(uint8((nonce & 0xFF00) >> 8));
            rlpNonce[2] = byte(uint8(nonce));
        } else if (nonce <= 0xFFFFFF) {
            rlpNonce = new bytes(4);
            rlpNonce[0] = 0x83;
            rlpNonce[1] = byte(uint8((nonce & 0xFF0000) >> 16));
            rlpNonce[2] = byte(uint8((nonce & 0xFF00) >> 8));
            rlpNonce[3] = byte(uint8(nonce));
        } else {
            rlpNonce = new bytes(5);
            rlpNonce[0] = 0x84;
            rlpNonce[1] = byte(uint8((nonce & 0xFF000000) >> 24));
            rlpNonce[2] = byte(uint8((nonce & 0xFF0000) >> 16));
            rlpNonce[3] = byte(uint8((nonce & 0xFF00) >> 8));
            rlpNonce[4] = byte(uint8(nonce));
        }
    }

    function getDeployedAddress(address deployer, uint32 deploymentNonce)
        internal
        pure
        returns (address payable deploymentAddress)
    {
        bytes memory rlpNonce = rlpEncodeNonce(deploymentNonce);
        return address(uint160(uint256(keccak256(abi.encodePacked(
            byte(uint8(0xC0 + 21 + rlpNonce.length)),
            byte(uint8(0x80 + 20)),
            deployer,
            rlpNonce
        )))));
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TransformERC20 is
    IFeature,
    ITransformERC20,
    FixinCommon
{

    struct TransformERC20PrivateState {
        IFlashWallet wallet;
        address transformerDeployer;
        uint256 takerOutputTokenBalanceBefore;
        uint256 takerOutputTokenBalanceAfter;
    }

    string public constant override FEATURE_NAME = "TransformERC20";
    uint256 public immutable override FEATURE_VERSION = _encodeVersion(1, 0, 0);
    address private immutable _implementation;

    using LibSafeMathV06 for uint256;
    using LibRichErrorsV06 for bytes;

    constructor() public {
        _implementation = address(this);
    }

    function migrate(address transformerDeployer) external returns (bytes4 success) {
        ISimpleFunctionRegistry(address(this))
            .extend(this.getTransformerDeployer.selector, _implementation);
        ISimpleFunctionRegistry(address(this))
            .extend(this.createTransformWallet.selector, _implementation);
        ISimpleFunctionRegistry(address(this))
            .extend(this.getTransformWallet.selector, _implementation);
        ISimpleFunctionRegistry(address(this))
            .extend(this.setTransformerDeployer.selector, _implementation);
        ISimpleFunctionRegistry(address(this))
            .extend(this.transformERC20.selector, _implementation);
        ISimpleFunctionRegistry(address(this))
            .extend(this._transformERC20.selector, _implementation);
        createTransformWallet();
        LibTransformERC20Storage.getStorage().transformerDeployer = transformerDeployer;
        return LibMigrate.MIGRATE_SUCCESS;
    }

    function setTransformerDeployer(address transformerDeployer)
        external
        override
        onlyOwner
    {
        LibTransformERC20Storage.getStorage().transformerDeployer = transformerDeployer;
        emit TransformerDeployerUpdated(transformerDeployer);
    }

    function getTransformerDeployer()
        public
        override
        view
        returns (address deployer)
    {
        return LibTransformERC20Storage.getStorage().transformerDeployer;
    }

    function createTransformWallet()
        public
        override
        returns (IFlashWallet wallet)
    {
        wallet = new FlashWallet();
        LibTransformERC20Storage.getStorage().wallet = wallet;
    }

    function transformERC20(
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 inputTokenAmount,
        uint256 minOutputTokenAmount,
        Transformation[] memory transformations
    )
        public
        override
        payable
        returns (uint256 outputTokenAmount)
    {
        return _transformERC20Private(
            keccak256(msg.data),
            msg.sender,
            inputToken,
            outputToken,
            inputTokenAmount,
            minOutputTokenAmount,
            transformations
        );
    }

    function _transformERC20(
        bytes32 callDataHash,
        address payable taker,
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 inputTokenAmount,
        uint256 minOutputTokenAmount,
        Transformation[] memory transformations
    )
        public
        override
        payable
        onlySelf
        returns (uint256 outputTokenAmount)
    {
        return _transformERC20Private(
            callDataHash,
            taker,
            inputToken,
            outputToken,
            inputTokenAmount,
            minOutputTokenAmount,
            transformations
        );
    }

    function _transformERC20Private(
        bytes32 callDataHash,
        address payable taker,
        IERC20TokenV06 inputToken,
        IERC20TokenV06 outputToken,
        uint256 inputTokenAmount,
        uint256 minOutputTokenAmount,
        Transformation[] memory transformations
    )
        private
        returns (uint256 outputTokenAmount)
    {
        if (inputTokenAmount == uint256(-1)) {
            inputTokenAmount = ITokenSpender(address(this))
                .getSpendableERC20BalanceOf(inputToken, taker);
        }

        TransformERC20PrivateState memory state;
        state.wallet = getTransformWallet();
        state.transformerDeployer = getTransformerDeployer();

        state.takerOutputTokenBalanceBefore =
            LibERC20Transformer.getTokenBalanceOf(outputToken, taker);

        _transferInputTokensAndAttachedEth(
            inputToken,
            taker,
            address(state.wallet),
            inputTokenAmount
        );

        for (uint256 i = 0; i < transformations.length; ++i) {
            _executeTransformation(
                state.wallet,
                transformations[i],
                state.transformerDeployer,
                taker,
                callDataHash
            );
        }

        state.takerOutputTokenBalanceAfter =
            LibERC20Transformer.getTokenBalanceOf(outputToken, taker);
        if (state.takerOutputTokenBalanceAfter > state.takerOutputTokenBalanceBefore) {
            outputTokenAmount = state.takerOutputTokenBalanceAfter.safeSub(
                state.takerOutputTokenBalanceBefore
            );
        } else if (state.takerOutputTokenBalanceAfter < state.takerOutputTokenBalanceBefore) {
            LibTransformERC20RichErrors.NegativeTransformERC20OutputError(
                address(outputToken),
                state.takerOutputTokenBalanceBefore - state.takerOutputTokenBalanceAfter
            ).rrevert();
        }
        if (outputTokenAmount < minOutputTokenAmount) {
            LibTransformERC20RichErrors.IncompleteTransformERC20Error(
                address(outputToken),
                outputTokenAmount,
                minOutputTokenAmount
            ).rrevert();
        }

        emit TransformedERC20(
            taker,
            address(inputToken),
            address(outputToken),
            inputTokenAmount,
            outputTokenAmount
        );
    }

    function getTransformWallet()
        public
        override
        view
        returns (IFlashWallet wallet)
    {
        return LibTransformERC20Storage.getStorage().wallet;
    }

    function _transferInputTokensAndAttachedEth(
        IERC20TokenV06 inputToken,
        address from,
        address payable to,
        uint256 amount
    )
        private
    {
        if (msg.value != 0) {
            to.transfer(msg.value);
        }
        if (!LibERC20Transformer.isTokenETH(inputToken)) {
            ITokenSpender(address(this))._spendERC20Tokens(
                inputToken,
                from,
                to,
                amount
            );
        } else if (msg.value < amount) {
            LibTransformERC20RichErrors.InsufficientEthAttachedError(
                msg.value,
                amount
            ).rrevert();
        }
    }

    function _executeTransformation(
        IFlashWallet wallet,
        Transformation memory transformation,
        address transformerDeployer,
        address payable taker,
        bytes32 callDataHash
    )
        private
    {
        address payable transformer = LibERC20Transformer.getDeployedAddress(
            transformerDeployer,
            transformation.deploymentNonce
        );
        bytes memory resultData = wallet.executeDelegateCall(
            transformer,
            abi.encodeWithSelector(
                IERC20Transformer.transform.selector,
                callDataHash,
                taker,
                transformation.data
            )
        );
        if (resultData.length != 32 ||
            abi.decode(resultData, (bytes4)) != LibERC20Transformer.TRANSFORMER_SUCCESS
        ) {
            LibTransformERC20RichErrors.TransformerFailedError(
                transformer,
                transformation.data,
                resultData
            ).rrevert();
        }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract InitialMigration {

    struct BootstrapFeatures {
        SimpleFunctionRegistry registry;
        Ownable ownable;
    }

    address public immutable deployer;
    address private immutable _implementation;

    constructor(address deployer_) public {
        deployer = deployer_;
        _implementation = address(this);
    }

    function deploy(address payable owner, BootstrapFeatures memory features)
        public
        virtual
        returns (ZeroEx zeroEx)
    {
        require(msg.sender == deployer, "InitialMigration/INVALID_SENDER");

        zeroEx = new ZeroEx();

        IBootstrap(address(zeroEx)).bootstrap(
            address(this),
            abi.encodeWithSelector(this.bootstrap.selector, owner, features)
        );

        this.die(owner);
    }

    function bootstrap(address owner, BootstrapFeatures memory features)
        public
        virtual
        returns (bytes4 success)
    {

        LibBootstrap.delegatecallBootstrapFunction(
            address(features.registry),
            abi.encodeWithSelector(
                SimpleFunctionRegistry.bootstrap.selector
            )
        );

        LibBootstrap.delegatecallBootstrapFunction(
            address(features.ownable),
            abi.encodeWithSelector(
                Ownable.bootstrap.selector
            )
        );

        SimpleFunctionRegistry(address(this)).rollback(
            SimpleFunctionRegistry._extendSelf.selector,
            address(0)
        );

        Ownable(address(this)).transferOwnership(owner);

        success = LibBootstrap.BOOTSTRAP_SUCCESS;
    }

    function die(address payable ethRecipient) public virtual {
        require(msg.sender == _implementation, "InitialMigration/INVALID_SENDER");
        selfdestruct(ethRecipient);
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract FullMigration {


    struct Features {
        SimpleFunctionRegistry registry;
        Ownable ownable;
        TokenSpender tokenSpender;
        TransformERC20 transformERC20;
    }

    struct MigrateOpts {
        address transformerDeployer;
    }

    address public immutable deployer;
    InitialMigration private _initialMigration;

    constructor(address payable deployer_)
        public
    {
        deployer = deployer_;
        _initialMigration = new InitialMigration(address(this));
    }

    function deploy(
        address payable owner,
        Features memory features,
        MigrateOpts memory migrateOpts
    )
        public
        returns (ZeroEx zeroEx)
    {
        require(msg.sender == deployer, "FullMigration/INVALID_SENDER");

        zeroEx = _initialMigration.deploy(
            address(uint160(address(this))),
            InitialMigration.BootstrapFeatures({
                registry: features.registry,
                ownable: features.ownable
            })
        );

        _addFeatures(zeroEx, owner, features, migrateOpts);

        IOwnable(address(zeroEx)).transferOwnership(owner);

        this.die(owner);
    }

    function die(address payable ethRecipient)
        external
        virtual
    {
        require(msg.sender == address(this), "FullMigration/INVALID_SENDER");
        selfdestruct(ethRecipient);
    }

    function _addFeatures(
        ZeroEx zeroEx,
        address owner,
        Features memory features,
        MigrateOpts memory migrateOpts
    )
        private
    {
        IOwnable ownable = IOwnable(address(zeroEx));
        {
            AllowanceTarget allowanceTarget = new AllowanceTarget();
            allowanceTarget.addAuthorizedAddress(address(zeroEx));
            allowanceTarget.transferOwnership(owner);
            ownable.migrate(
                address(features.tokenSpender),
                abi.encodeWithSelector(
                    TokenSpender.migrate.selector,
                    allowanceTarget
                ),
                address(this)
            );
        }
        {
            ownable.migrate(
                address(features.transformERC20),
                abi.encodeWithSelector(
                    TransformERC20.migrate.selector,
                    migrateOpts.transformerDeployer
                ),
                address(this)
            );
        }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



abstract contract Transformer is
    IERC20Transformer
{
    using LibRichErrorsV06 for bytes;

    address public immutable deployer;
    address private immutable _implementation;

    constructor() public {
        deployer = msg.sender;
        _implementation = address(this);
    }

    function die(address payable ethRecipient)
        external
        virtual
    {
        if (msg.sender != deployer) {
            LibTransformERC20RichErrors
                .OnlyCallableByDeployerError(msg.sender, deployer)
                .rrevert();
        }
        if (address(this) != _implementation) {
            LibTransformERC20RichErrors
                .InvalidExecutionContextError(address(this), _implementation)
                .rrevert();
        }
        selfdestruct(ethRecipient);
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract AffiliateFeeTransformer is
    Transformer
{
    using LibRichErrorsV06 for bytes;
    using LibSafeMathV06 for uint256;
    using LibERC20Transformer for IERC20TokenV06;

    struct TokenFee {
        IERC20TokenV06 token;
        uint256 amount;
        address payable recipient;
    }

    uint256 private constant MAX_UINT256 = uint256(-1);

    constructor()
        public
        Transformer()
    {}

    function transform(
        bytes32, // callDataHash,
        address payable, // taker,
        bytes calldata data
    )
        external
        override
        returns (bytes4 success)
    {
        TokenFee[] memory fees = abi.decode(data, (TokenFee[]));

        for (uint256 i = 0; i < fees.length; ++i) {
            uint256 amount = fees[i].amount;
            if (amount == MAX_UINT256) {
                amount = LibERC20Transformer.getTokenBalanceOf(fees[i].token, address(this));
            }
            if (amount != 0) {
                fees[i].token.transformerTransfer(fees[i].recipient, amount);
            }
        }

        return LibERC20Transformer.TRANSFORMER_SUCCESS;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


library LibMathRichErrorsV06 {

    bytes internal constant DIVISION_BY_ZERO_ERROR =
        hex"a791837c";

    bytes4 internal constant ROUNDING_ERROR_SELECTOR =
        0x339f3de2;

    function DivisionByZeroError()
        internal
        pure
        returns (bytes memory)
    {
        return DIVISION_BY_ZERO_ERROR;
    }

    function RoundingError(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(
            ROUNDING_ERROR_SELECTOR,
            numerator,
            denominator,
            target
        );
    }
}/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



library LibMathV06 {

    using LibSafeMathV06 for uint256;

    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        if (isRoundingErrorFloor(
                numerator,
                denominator,
                target
        )) {
            LibRichErrorsV06.rrevert(LibMathRichErrorsV06.RoundingError(
                numerator,
                denominator,
                target
            ));
        }

        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        if (isRoundingErrorCeil(
                numerator,
                denominator,
                target
        )) {
            LibRichErrorsV06.rrevert(LibMathRichErrorsV06.RoundingError(
                numerator,
                denominator,
                target
            ));
        }

        partialAmount = numerator.safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {
        partialAmount = numerator.safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {
        if (denominator == 0) {
            LibRichErrorsV06.rrevert(LibMathRichErrorsV06.DivisionByZeroError());
        }

        if (target == 0 || numerator == 0) {
            return false;
        }

        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }

    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {
        if (denominator == 0) {
            LibRichErrorsV06.rrevert(LibMathRichErrorsV06.DivisionByZeroError());
        }

        if (target == 0 || numerator == 0) {
            return false;
        }
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        remainder = denominator.safeSub(remainder) % denominator;
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


interface IExchange {

    struct Order {
        address makerAddress;
        address takerAddress;
        address feeRecipientAddress;
        address senderAddress;
        uint256 makerAssetAmount;
        uint256 takerAssetAmount;
        uint256 makerFee;
        uint256 takerFee;
        uint256 expirationTimeSeconds;
        uint256 salt;
        bytes makerAssetData;
        bytes takerAssetData;
        bytes makerFeeAssetData;
        bytes takerFeeAssetData;
    }

    struct FillResults {
        uint256 makerAssetFilledAmount;
        uint256 takerAssetFilledAmount;
        uint256 makerFeePaid;
        uint256 takerFeePaid;
        uint256 protocolFeePaid;
    }

    function fillOrder(
        Order calldata order,
        uint256 takerAssetFillAmount,
        bytes calldata signature
    )
        external
        payable
        returns (FillResults memory fillResults);

    function protocolFeeMultiplier()
        external
        view
        returns (uint256 multiplier);

    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address proxyAddress);
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract FillQuoteTransformer is
    Transformer
{
    using LibERC20TokenV06 for IERC20TokenV06;
    using LibERC20Transformer for IERC20TokenV06;
    using LibSafeMathV06 for uint256;
    using LibRichErrorsV06 for bytes;

    enum Side {
        Sell,
        Buy
    }

    struct TransformData {
        Side side;
        IERC20TokenV06 sellToken;
        IERC20TokenV06 buyToken;
        IExchange.Order[] orders;
        bytes[] signatures;
        uint256[] maxOrderFillAmounts;
        uint256 fillAmount;
    }

    struct FillOrderResults {
        uint256 takerTokenSoldAmount;
        uint256 makerTokenBoughtAmount;
        uint256 protocolFeePaid;
    }

    bytes4 private constant ERC20_ASSET_PROXY_ID = 0xf47261b0;
    uint256 private constant MAX_UINT256 = uint256(-1);

    IExchange public immutable exchange;
    address public immutable erc20Proxy;

    constructor(IExchange exchange_)
        public
        Transformer()
    {
        exchange = exchange_;
        erc20Proxy = exchange_.getAssetProxy(ERC20_ASSET_PROXY_ID);
    }

    function transform(
        bytes32, // callDataHash,
        address payable, // taker,
        bytes calldata data_
    )
        external
        override
        returns (bytes4 success)
    {
        TransformData memory data = abi.decode(data_, (TransformData));

        if (data.sellToken.isTokenETH() || data.buyToken.isTokenETH()) {
            LibTransformERC20RichErrors.InvalidTransformDataError(
                LibTransformERC20RichErrors.InvalidTransformDataErrorCode.INVALID_TOKENS,
                data_
            ).rrevert();
        }
        if (data.orders.length != data.signatures.length) {
            LibTransformERC20RichErrors.InvalidTransformDataError(
                LibTransformERC20RichErrors.InvalidTransformDataErrorCode.INVALID_ARRAY_LENGTH,
                data_
            ).rrevert();
        }

        if (data.side == Side.Sell && data.fillAmount == MAX_UINT256) {
            data.fillAmount = data.sellToken.getTokenBalanceOf(address(this));
        }

        data.sellToken.approveIfBelow(erc20Proxy, data.fillAmount);

        uint256 singleProtocolFee = exchange.protocolFeeMultiplier().safeMul(tx.gasprice);
        uint256 ethRemaining = address(this).balance;
        uint256 boughtAmount = 0;
        uint256 soldAmount = 0;
        for (uint256 i = 0; i < data.orders.length; ++i) {
            if (data.side == Side.Sell) {
                if (soldAmount >= data.fillAmount) {
                    break;
                }
            } else {
                if (boughtAmount >= data.fillAmount) {
                    break;
                }
            }

            if (ethRemaining < singleProtocolFee) {
                LibTransformERC20RichErrors
                    .InsufficientProtocolFeeError(ethRemaining, singleProtocolFee)
                    .rrevert();
            }

            FillOrderResults memory results;
            if (data.side == Side.Sell) {
                results = _sellToOrder(
                    data.buyToken,
                    data.sellToken,
                    data.orders[i],
                    data.signatures[i],
                    data.fillAmount.safeSub(soldAmount).min256(
                        data.maxOrderFillAmounts.length > i
                        ? data.maxOrderFillAmounts[i]
                        : MAX_UINT256
                    ),
                    singleProtocolFee
                );
            } else {
                results = _buyFromOrder(
                    data.buyToken,
                    data.sellToken,
                    data.orders[i],
                    data.signatures[i],
                    data.fillAmount.safeSub(boughtAmount).min256(
                        data.maxOrderFillAmounts.length > i
                        ? data.maxOrderFillAmounts[i]
                        : MAX_UINT256
                    ),
                    singleProtocolFee
                );
            }

            soldAmount = soldAmount.safeAdd(results.takerTokenSoldAmount);
            boughtAmount = boughtAmount.safeAdd(results.makerTokenBoughtAmount);
            ethRemaining = ethRemaining.safeSub(results.protocolFeePaid);
        }

        if (data.side == Side.Sell) {
            if (soldAmount < data.fillAmount) {
                LibTransformERC20RichErrors
                    .IncompleteFillSellQuoteError(
                        address(data.sellToken),
                        soldAmount,
                        data.fillAmount
                    ).rrevert();
            }
        } else {
            if (boughtAmount < data.fillAmount) {
                LibTransformERC20RichErrors
                    .IncompleteFillBuyQuoteError(
                        address(data.buyToken),
                        boughtAmount,
                        data.fillAmount
                    ).rrevert();
            }
        }
        return LibERC20Transformer.TRANSFORMER_SUCCESS;
    }

    function _sellToOrder(
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        IExchange.Order memory order,
        bytes memory signature,
        uint256 sellAmount,
        uint256 protocolFee
    )
        private
        returns (FillOrderResults memory results)
    {
        IERC20TokenV06 takerFeeToken =
            _getTokenFromERC20AssetData(order.takerFeeAssetData);

        uint256 takerTokenFillAmount = sellAmount;

        if (order.takerFee != 0) {
            if (takerFeeToken == makerToken) {
                takerFeeToken.approveIfBelow(erc20Proxy, order.takerFee);
            } else if (takerFeeToken == takerToken){
                takerTokenFillAmount = LibMathV06.getPartialAmountCeil(
                    order.takerAssetAmount,
                    order.takerAssetAmount.safeAdd(order.takerFee),
                    sellAmount
                );
            } else {
                LibTransformERC20RichErrors.InvalidTakerFeeTokenError(
                    address(takerFeeToken)
                ).rrevert();
            }
        }

        takerTokenFillAmount = LibSafeMathV06.min256(
            takerTokenFillAmount,
            order.takerAssetAmount
        );

        return _fillOrder(
            order,
            signature,
            takerTokenFillAmount,
            protocolFee,
            makerToken,
            takerFeeToken == takerToken
        );
    }

    function _buyFromOrder(
        IERC20TokenV06 makerToken,
        IERC20TokenV06 takerToken,
        IExchange.Order memory order,
        bytes memory signature,
        uint256 buyAmount,
        uint256 protocolFee
    )
        private
        returns (FillOrderResults memory results)
    {
        IERC20TokenV06 takerFeeToken =
            _getTokenFromERC20AssetData(order.takerFeeAssetData);
        uint256 takerTokenFillAmount = LibMathV06.getPartialAmountCeil(
            buyAmount,
            order.makerAssetAmount,
            order.takerAssetAmount
        );

        if (order.takerFee != 0) {
            if (takerFeeToken == makerToken) {
                takerTokenFillAmount = LibMathV06.getPartialAmountCeil(
                    buyAmount,
                    order.makerAssetAmount.safeSub(order.takerFee),
                    order.takerAssetAmount
                );
                takerFeeToken.approveIfBelow(erc20Proxy, order.takerFee);
            } else if (takerFeeToken != takerToken) {
                LibTransformERC20RichErrors.InvalidTakerFeeTokenError(
                    address(takerFeeToken)
                ).rrevert();
            }
        }

        takerTokenFillAmount = LibSafeMathV06.min256(
            order.takerAssetAmount,
            takerTokenFillAmount
        );

        return _fillOrder(
            order,
            signature,
            takerTokenFillAmount,
            protocolFee,
            makerToken,
            takerFeeToken == takerToken
        );
    }

    function _fillOrder(
        IExchange.Order memory order,
        bytes memory signature,
        uint256 takerAssetFillAmount,
        uint256 protocolFee,
        IERC20TokenV06 makerToken,
        bool isTakerFeeInTakerToken
    )
        private
        returns (FillOrderResults memory results)
    {
        uint256 initialMakerTokenBalance = makerToken.balanceOf(address(this));
        try
            exchange.fillOrder
                {value: protocolFee}
                (order, takerAssetFillAmount, signature)
            returns (IExchange.FillResults memory fillResults)
        {
            results.makerTokenBoughtAmount = makerToken.balanceOf(address(this))
                .safeSub(initialMakerTokenBalance);
            results.protocolFeePaid = fillResults.protocolFeePaid;
            results.takerTokenSoldAmount = fillResults.takerAssetFilledAmount;
            if (isTakerFeeInTakerToken) {
                results.takerTokenSoldAmount =
                    results.takerTokenSoldAmount.safeAdd(fillResults.takerFeePaid);
            }
        } catch (bytes memory) {
        }
    }

    function _getTokenFromERC20AssetData(bytes memory assetData)
        private
        pure
        returns (IERC20TokenV06 token)
    {
        if (assetData.length == 0) {
            return IERC20TokenV06(address(0));
        }
        if (assetData.length != 36 ||
            LibBytesV06.readBytes4(assetData, 0) != ERC20_ASSET_PROXY_ID)
        {
            LibTransformERC20RichErrors
                .InvalidERC20AssetDataError(assetData)
                .rrevert();
        }
        return IERC20TokenV06(LibBytesV06.readAddress(assetData, 16));
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract PayTakerTransformer is
    Transformer
{
    using LibRichErrorsV06 for bytes;
    using LibSafeMathV06 for uint256;
    using LibERC20Transformer for IERC20TokenV06;

    struct TransformData {
        IERC20TokenV06[] tokens;
        uint256[] amounts;
    }

    uint256 private constant MAX_UINT256 = uint256(-1);

    constructor()
        public
        Transformer()
    {}

    function transform(
        bytes32, // callDataHash,
        address payable taker,
        bytes calldata data_
    )
        external
        override
        returns (bytes4 success)
    {
        TransformData memory data = abi.decode(data_, (TransformData));

        for (uint256 i = 0; i < data.tokens.length; ++i) {
            uint256 amount = data.amounts.length > i ? data.amounts[i] : uint256(-1);
            if (amount == MAX_UINT256) {
                amount = data.tokens[i].getTokenBalanceOf(address(this));
            }
            if (amount != 0) {
                data.tokens[i].transformerTransfer(taker, amount);
            }
        }
        return LibERC20Transformer.TRANSFORMER_SUCCESS;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



interface IEtherTokenV06 is
    IERC20TokenV06
{
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract WethTransformer is
    Transformer
{
    using LibRichErrorsV06 for bytes;
    using LibSafeMathV06 for uint256;
    using LibERC20Transformer for IERC20TokenV06;

    struct TransformData {
        IERC20TokenV06 token;
        uint256 amount;
    }

    IEtherTokenV06 public immutable weth;
    uint256 private constant MAX_UINT256 = uint256(-1);

    constructor(IEtherTokenV06 weth_)
        public
        Transformer()
    {
        weth = weth_;
    }

    function transform(
        bytes32, // callDataHash,
        address payable, // taker,
        bytes calldata data_
    )
        external
        override
        returns (bytes4 success)
    {
        TransformData memory data = abi.decode(data_, (TransformData));
        if (!data.token.isTokenETH() && data.token != weth) {
            LibTransformERC20RichErrors.InvalidTransformDataError(
                LibTransformERC20RichErrors.InvalidTransformDataErrorCode.INVALID_TOKENS,
                data_
            ).rrevert();
        }

        uint256 amount = data.amount;
        if (amount == MAX_UINT256) {
            amount = data.token.getTokenBalanceOf(address(this));
        }

        if (amount != 0) {
            if (data.token.isTokenETH()) {
                weth.deposit{value: amount}();
            } else {
                weth.withdraw(amount);
            }
        }
        return LibERC20Transformer.TRANSFORMER_SUCCESS;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


interface ITestSimpleFunctionRegistryFeature {
    function testFn() external view returns (uint256 id);
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


contract TestCallTarget {

    event CallTargetCalled(
        address context,
        address sender,
        bytes data,
        uint256 value
    );

    bytes4 private constant MAGIC_BYTES = 0x12345678;
    bytes private constant REVERTING_DATA = hex"1337";

    fallback() external payable {
        if (keccak256(msg.data) == keccak256(REVERTING_DATA)) {
            revert("TestCallTarget/REVERT");
        }
        emit CallTargetCalled(
            address(this),
            msg.sender,
            msg.data,
            msg.value
        );
        bytes4 rval = MAGIC_BYTES;
        assembly {
            mstore(0, rval)
            return(0, 32)
        }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


contract TestDelegateCaller {
    function executeDelegateCall(
        address target,
        bytes calldata callData
    )
        external
    {
        (bool success, bytes memory resultData) = target.delegatecall(callData);
        if (!success) {
            assembly { revert(add(resultData, 32), mload(resultData)) }
        }
        assembly { return(add(resultData, 32), mload(resultData)) }
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


contract TestMintableERC20Token {

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function transfer(address to, uint256 amount)
        external
        virtual
        returns (bool)
    {
        return transferFrom(msg.sender, to, amount);
    }

    function approve(address spender, uint256 amount)
        external
        virtual
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function mint(address owner, uint256 amount)
        external
        virtual
    {
        balanceOf[owner] += amount;
    }

    function burn(address owner, uint256 amount)
        external
        virtual
    {
        require(balanceOf[owner] >= amount, "TestMintableERC20Token/INSUFFICIENT_FUNDS");
        balanceOf[owner] -= amount;
    }

    function transferFrom(address from, address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        if (from != msg.sender) {
            require(
                allowance[from][msg.sender] >= amount,
                "TestMintableERC20Token/INSUFFICIENT_ALLOWANCE"
            );
            allowance[from][msg.sender] -= amount;
        }
        require(balanceOf[from] >= amount, "TestMintableERC20Token/INSUFFICIENT_FUNDS");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function getSpendableAmount(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return balanceOf[owner] < allowance[owner][spender]
            ? balanceOf[owner]
            : allowance[owner][spender];
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestFillQuoteTransformerExchange {

    struct FillBehavior {
        uint256 filledTakerAssetAmount;
        uint256 makerAssetMintRatio;
    }

    uint256 private constant PROTOCOL_FEE_MULTIPLIER = 1337;

    using LibSafeMathV06 for uint256;

    function fillOrder(
        IExchange.Order calldata order,
        uint256 takerAssetFillAmount,
        bytes calldata signature
    )
        external
        payable
        returns (IExchange.FillResults memory fillResults)
    {
        require(
            signature.length != 0,
            "TestFillQuoteTransformerExchange/INVALID_SIGNATURE"
        );
        FillBehavior memory behavior = abi.decode(signature, (FillBehavior));

        uint256 protocolFee = PROTOCOL_FEE_MULTIPLIER * tx.gasprice;
        require(
            msg.value == protocolFee,
            "TestFillQuoteTransformerExchange/INSUFFICIENT_PROTOCOL_FEE"
        );
        msg.sender.transfer(msg.value - protocolFee);

        TestMintableERC20Token takerToken = _getTokenFromAssetData(order.takerAssetData);
        takerAssetFillAmount = LibSafeMathV06.min256(
            order.takerAssetAmount.safeSub(behavior.filledTakerAssetAmount),
            takerAssetFillAmount
        );
        require(
            takerToken.getSpendableAmount(msg.sender, address(this)) >= takerAssetFillAmount,
            "TestFillQuoteTransformerExchange/INSUFFICIENT_TAKER_FUNDS"
        );
        takerToken.transferFrom(msg.sender, order.makerAddress, takerAssetFillAmount);

        uint256 makerAssetFilledAmount = LibMathV06.getPartialAmountFloor(
            takerAssetFillAmount,
            order.takerAssetAmount,
            order.makerAssetAmount
        );
        TestMintableERC20Token makerToken = _getTokenFromAssetData(order.makerAssetData);
        makerToken.mint(
            msg.sender,
            LibMathV06.getPartialAmountFloor(
                behavior.makerAssetMintRatio,
                1e18,
                makerAssetFilledAmount
            )
        );

        TestMintableERC20Token takerFeeToken = _getTokenFromAssetData(order.takerFeeAssetData);
        uint256 takerFee = LibMathV06.getPartialAmountFloor(
            takerAssetFillAmount,
            order.takerAssetAmount,
            order.takerFee
        );
        require(
            takerFeeToken.getSpendableAmount(msg.sender, address(this)) >= takerFee,
            "TestFillQuoteTransformerExchange/INSUFFICIENT_TAKER_FEE_FUNDS"
        );
        takerFeeToken.transferFrom(msg.sender, order.feeRecipientAddress, takerFee);

        fillResults.makerAssetFilledAmount = makerAssetFilledAmount;
        fillResults.takerAssetFilledAmount = takerAssetFillAmount;
        fillResults.makerFeePaid = uint256(-1);
        fillResults.takerFeePaid = takerFee;
        fillResults.protocolFeePaid = protocolFee;
    }

    function encodeBehaviorData(FillBehavior calldata behavior)
        external
        pure
        returns (bytes memory encoded)
    {
        return abi.encode(behavior);
    }

    function protocolFeeMultiplier()
        external
        pure
        returns (uint256)
    {
        return PROTOCOL_FEE_MULTIPLIER;
    }

    function getAssetProxy(bytes4)
        external
        view
        returns (address)
    {
        return address(this);
    }

    function _getTokenFromAssetData(bytes memory assetData)
        private
        pure
        returns (TestMintableERC20Token token)
    {
        return TestMintableERC20Token(LibBytesV06.readAddress(assetData, 16));
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestTransformerHost {

    using LibERC20Transformer for IERC20TokenV06;
    using LibRichErrorsV06 for bytes;

    function rawExecuteTransform(
        IERC20Transformer transformer,
        bytes32 callDataHash,
        address taker,
        bytes calldata data
    )
        external
    {
        (bool _success, bytes memory resultData) =
            address(transformer).delegatecall(abi.encodeWithSelector(
                transformer.transform.selector,
                callDataHash,
                taker,
                data
            ));
        if (!_success) {
            resultData.rrevert();
        }
        require(
            abi.decode(resultData, (bytes4)) == LibERC20Transformer.TRANSFORMER_SUCCESS,
            "TestTransformerHost/INVALID_TRANSFORMER_RESULT"
        );
    }

    receive() external payable {}
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestFillQuoteTransformerHost is
    TestTransformerHost
{
    function executeTransform(
        IERC20Transformer transformer,
        TestMintableERC20Token inputToken,
        uint256 inputTokenAmount,
        bytes calldata data
    )
        external
        payable
    {
        if (inputTokenAmount != 0) {
            inputToken.mint(address(this), inputTokenAmount);
        }
        this.rawExecuteTransform(transformer, bytes32(0), msg.sender, data);
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestFullMigration is
    FullMigration
{
    address public dieRecipient;

    constructor(address payable deployer) public FullMigration(deployer) {}

    function die(address payable ethRecipient) external override {
        dieRecipient = ethRecipient;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestInitialMigration is
    InitialMigration
{
    address public bootstrapFeature;
    address public dieRecipient;

    constructor(address deployer) public InitialMigration(deployer) {}

    function callBootstrap(ZeroEx zeroEx) external {
        IBootstrap(address(zeroEx)).bootstrap(address(this), new bytes(0));
    }

    function bootstrap(address owner, BootstrapFeatures memory features)
        public
        override
        returns (bytes4 success)
    {
        success = InitialMigration.bootstrap(owner, features);
        bootstrapFeature = ZeroEx(address(uint160(address(this))))
            .getFunctionImplementation(IBootstrap.bootstrap.selector);
    }

    function die(address payable ethRecipient) public override {
        dieRecipient = ethRecipient;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestMigrator {
    event TestMigrateCalled(
        bytes callData,
        address owner
    );

    function succeedingMigrate() external returns (bytes4 success) {
        emit TestMigrateCalled(
            msg.data,
            IOwnable(address(this)).owner()
        );
        return LibMigrate.MIGRATE_SUCCESS;
    }

    function failingMigrate() external returns (bytes4 success) {
        emit TestMigrateCalled(
            msg.data,
            IOwnable(address(this)).owner()
        );
        return 0xdeadbeef;
    }

    function revertingMigrate() external pure {
        revert("OOPSIE");
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestMintTokenERC20Transformer is
    IERC20Transformer
{
    struct TransformData {
        IERC20TokenV06 inputToken;
        TestMintableERC20Token outputToken;
        uint256 burnAmount;
        uint256 mintAmount;
        uint256 feeAmount;
    }

    event MintTransform(
        address context,
        address caller,
        bytes32 callDataHash,
        address taker,
        bytes data,
        uint256 inputTokenBalance,
        uint256 ethBalance
    );

    function transform(
        bytes32 callDataHash,
        address payable taker,
        bytes calldata data_
    )
        external
        override
        returns (bytes4 success)
    {
        TransformData memory data = abi.decode(data_, (TransformData));
        emit MintTransform(
            address(this),
            msg.sender,
            callDataHash,
            taker,
            data_,
            data.inputToken.balanceOf(address(this)),
            address(this).balance
        );
        data.inputToken.transfer(address(0), data.burnAmount);
        if (LibERC20Transformer.isTokenETH(IERC20TokenV06(address(data.outputToken)))) {
            taker.transfer(data.mintAmount);
        } else {
            data.outputToken.mint(
                taker,
                data.mintAmount
            );
            data.outputToken.burn(taker, data.feeAmount);
        }
        return LibERC20Transformer.TRANSFORMER_SUCCESS;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestSimpleFunctionRegistryFeatureImpl1 is
    FixinCommon
{
    function testFn()
        external
        pure
        returns (uint256 id)
    {
        return 1337;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestSimpleFunctionRegistryFeatureImpl2 is
    FixinCommon
{
    function testFn()
        external
        pure
        returns (uint256 id)
    {
        return 1338;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;


contract TestTokenSpender is
    TokenSpender
{
    modifier onlySelf() override {
        _;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestTokenSpenderERC20Token is
    TestMintableERC20Token
{

    event TransferFromCalled(
        address sender,
        address from,
        address to,
        uint256 amount
    );

    uint256 constant private EMPTY_RETURN_AMOUNT = 1337;
    uint256 constant private FALSE_RETURN_AMOUNT = 1338;
    uint256 constant private REVERT_RETURN_AMOUNT = 1339;

    function transferFrom(address from, address to, uint256 amount)
        public
        override
        returns (bool)
    {
        emit TransferFromCalled(msg.sender, from, to, amount);
        if (amount == EMPTY_RETURN_AMOUNT) {
            assembly { return(0, 0) }
        }
        if (amount == FALSE_RETURN_AMOUNT) {
            return false;
        }
        if (amount == REVERT_RETURN_AMOUNT) {
            revert("TestTokenSpenderERC20Token/Revert");
        }
        return true;
    }

    function setBalanceAndAllowanceOf(
        address owner,
        uint256 balance,
        address spender,
        uint256 allowance_
    )
        external
    {
        balanceOf[owner] = balance;
        allowance[owner][spender] = allowance_;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestTransformERC20 is
    TransformERC20
{
    constructor()
        TransformERC20()
        public
    {}

    modifier onlySelf() override {
        _;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestTransformerBase is
    Transformer
{
    function transform(
        bytes32,
        address payable,
        bytes calldata
    )
        external
        override
        returns (bytes4 success)
    {
        return LibERC20Transformer.TRANSFORMER_SUCCESS;
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestTransformerDeployerTransformer {

    address payable public immutable deployer;

    constructor() public payable {
        deployer = msg.sender;
    }

    modifier onlyDeployer() {
        require(msg.sender == deployer, "TestTransformerDeployerTransformer/ONLY_DEPLOYER");
        _;
    }

    function die()
        external
        onlyDeployer
    {
        selfdestruct(deployer);
    }

    function isDeployedByDeployer(uint32 nonce)
        external
        view
        returns (bool)
    {
        return LibERC20Transformer.getDeployedAddress(deployer, nonce) == address(this);
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestWeth is
    TestMintableERC20Token
{
    function deposit()
        external
        payable
    {
        this.mint(msg.sender, msg.value);
    }

    function withdraw(uint256 amount)
        external
    {
        require(balanceOf[msg.sender] >= amount, "TestWeth/INSUFFICIENT_FUNDS");
        balanceOf[msg.sender] -= amount;
        msg.sender.transfer(amount);
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestWethTransformerHost is
    TestTransformerHost
{
    TestWeth private immutable _weth;

    constructor(TestWeth weth) public {
        _weth = weth;
    }

    function executeTransform(
        uint256 wethAmount,
        IERC20Transformer transformer,
        bytes calldata data
    )
        external
        payable
    {
        if (wethAmount != 0) {
            _weth.deposit{value: wethAmount}();
        }
        this.rawExecuteTransform(transformer, bytes32(0), msg.sender, data);
    }
}/*

  Copyright 2020 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;



contract TestZeroExFeature is
    FixinCommon
{
    event PayableFnCalled(uint256 value);
    event NotPayableFnCalled();

    function payableFn()
        external
        payable
    {
        emit PayableFnCalled(msg.value);
    }

    function notPayableFn()
        external
    {
        emit NotPayableFnCalled();
    }

    function unimplmentedFn()
        external
    {}

    function internalFn()
        external
        onlySelf
    {}
}