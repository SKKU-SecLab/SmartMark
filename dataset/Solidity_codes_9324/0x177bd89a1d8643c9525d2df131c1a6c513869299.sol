pragma solidity 0.8.7;

interface ISwapModule {

    function swap(address[] memory _swapActions, bytes[] memory _swapDatas)
        external;

}// "UNLICENSED"
pragma solidity 0.8.7;

library GelatoBytes {

    function calldataSliceSelector(bytes calldata _bytes)
        internal
        pure
        returns (bytes4 selector)
    {

        selector =
            _bytes[0] |
            (bytes4(_bytes[1]) >> 8) |
            (bytes4(_bytes[2]) >> 16) |
            (bytes4(_bytes[3]) >> 24);
    }

    function memorySliceSelector(bytes memory _bytes)
        internal
        pure
        returns (bytes4 selector)
    {

        selector =
            _bytes[0] |
            (bytes4(_bytes[1]) >> 8) |
            (bytes4(_bytes[2]) >> 16) |
            (bytes4(_bytes[3]) >> 24);
    }

    function revertWithError(bytes memory _bytes, string memory _tracingInfo)
        internal
        pure
    {

        if (_bytes.length % 32 == 4) {
            bytes4 selector;
            assembly {
                selector := mload(add(0x20, _bytes))
            }
            if (selector == 0x08c379a0) {
                assembly {
                    _bytes := add(_bytes, 68)
                }
                revert(string(abi.encodePacked(_tracingInfo, string(_bytes))));
            } else {
                revert(
                    string(abi.encodePacked(_tracingInfo, "NoErrorSelector"))
                );
            }
        } else {
            revert(
                string(abi.encodePacked(_tracingInfo, "UnexpectedReturndata"))
            );
        }
    }

    function returnError(bytes memory _bytes, string memory _tracingInfo)
        internal
        pure
        returns (string memory)
    {

        if (_bytes.length % 32 == 4) {
            bytes4 selector;
            assembly {
                selector := mload(add(0x20, _bytes))
            }
            if (selector == 0x08c379a0) {
                assembly {
                    _bytes := add(_bytes, 68)
                }
                return string(abi.encodePacked(_tracingInfo, string(_bytes)));
            } else {
                return
                    string(abi.encodePacked(_tracingInfo, "NoErrorSelector"));
            }
        } else {
            return
                string(abi.encodePacked(_tracingInfo, "UnexpectedReturndata"));
        }
    }
}// MIT
pragma solidity 0.8.7;


contract SwapModule is ISwapModule {

    function swap(address[] memory _swapActions, bytes[] memory _swapDatas)
        external
        override
    {

        require(
            _swapActions.length == _swapDatas.length,
            "SwapModule.swap: actions length != datas length."
        );

        for (uint256 i; i < _swapActions.length; i++) {
            {
                (bool success, bytes memory returnsData) = _swapActions[i].call(
                    _swapDatas[i]
                );
                if (!success)
                    GelatoBytes.revertWithError(
                        returnsData,
                        "SwapModule.swap: "
                    );
            }
        }
    }
}