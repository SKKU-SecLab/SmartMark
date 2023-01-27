
pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";


contract ZeroExApiAdapter {


    struct RfqOrder {
        address makerToken;
        address takerToken;
        uint128 makerAmount;
        uint128 takerAmount;
        address maker;
        address taker;
        address txOrigin;
        bytes32 pool;
        uint64 expiry;
        uint256 salt;
    }

    struct Signature {
        uint8 signatureType;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }


    address private constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 private constant UNISWAP_V3_PATH_ADDRESS_SIZE = 20;
    uint256 private constant UNISWAP_V3_PATH_FEE_SIZE = 3;
    uint256 private constant UNISWAP_V3_SINGLE_HOP_PATH_SIZE = UNISWAP_V3_PATH_ADDRESS_SIZE + UNISWAP_V3_PATH_FEE_SIZE + UNISWAP_V3_PATH_ADDRESS_SIZE;
    uint256 private constant UNISWAP_V3_SINGLE_HOP_OFFSET_SIZE = UNISWAP_V3_PATH_ADDRESS_SIZE + UNISWAP_V3_PATH_FEE_SIZE;

    address public immutable zeroExAddress;
    address public immutable wethAddress;

    address public immutable getSpender;


    constructor(address _zeroExAddress, address _wethAddress) public {
        zeroExAddress = _zeroExAddress;
        wethAddress = _wethAddress;
        getSpender = _zeroExAddress;
    }



    function getTradeCalldata(
        address _sourceToken,
        address _destinationToken,
        address _destinationAddress,
        uint256 _sourceQuantity,
        uint256 _minDestinationQuantity,
        bytes calldata _data
    )
        external
        view
        returns (address, uint256, bytes memory)
    {

        address inputToken;
        address outputToken;
        address recipient;
        bool supportsRecipient;
        uint256 inputTokenAmount;
        uint256 minOutputTokenAmount;

        {
            require(_data.length >= 4, "Invalid calldata");
            bytes4 selector;
            assembly {
                selector := and(
                    calldataload(add(36, calldataload(164))), // 164 = 5 * 32 + 4
                    0xffffffff00000000000000000000000000000000000000000000000000000000
                )
            }

            if (selector == 0x415565b0 || selector == 0x8182b61f) {
                (inputToken, outputToken, inputTokenAmount, minOutputTokenAmount) =
                    abi.decode(_data[4:], (address, address, uint256, uint256));
            } else if (selector == 0xf7fcd384) {
                (inputToken, outputToken, , recipient, inputTokenAmount, minOutputTokenAmount) =
                    abi.decode(_data[4:], (address, address, address, address, uint256, uint256));
                supportsRecipient = true;
                if (recipient == address(0)) {
                    recipient = _destinationAddress;
                }
            } else if (selector == 0xd9627aa4) {
                address[] memory path;
                (path, inputTokenAmount, minOutputTokenAmount) =
                    abi.decode(_data[4:], (address[], uint256, uint256));
                require(path.length > 1, "Uniswap token path too short");
                inputToken = path[0];
                outputToken = path[path.length - 1];
            } else if (selector == 0xaa77476c) {
                RfqOrder memory order;
                uint128 takerTokenFillAmount;
                (order, , takerTokenFillAmount) =
                    abi.decode(_data[4:], (RfqOrder, Signature, uint128));
                inputTokenAmount = uint256(takerTokenFillAmount);
                inputToken = order.takerToken;
                outputToken = order.makerToken;
                minOutputTokenAmount = getRfqOrderMakerFillAmount(order, inputTokenAmount);
            } else if (selector == 0x75103cb9) {
                RfqOrder[] memory orders;
                uint128[] memory takerTokenFillAmounts;
                bool revertIfIncomplete;
                (orders, , takerTokenFillAmounts, revertIfIncomplete) =
                    abi.decode(_data[4:], (RfqOrder[], uint256, uint128[], bool));
                require(orders.length > 0, "Empty RFQ orders");
                require(revertIfIncomplete, "batchFillRfqOrder must be all or nothing");
                inputToken = orders[0].takerToken;
                outputToken = orders[0].makerToken;
                for (uint256 i = 0; i < orders.length; ++i) {
                    inputTokenAmount += uint256(takerTokenFillAmounts[i]);
                    minOutputTokenAmount += getRfqOrderMakerFillAmount(orders[i], takerTokenFillAmounts[i]);
                }
            } else if (selector == 0x6af479b2) {
                bytes memory encodedPath;
                (encodedPath, inputTokenAmount, minOutputTokenAmount, recipient) =
                    abi.decode(_data[4:], (bytes, uint256, uint256, address));
                supportsRecipient = true;
                if (recipient == address(0)) {
                    recipient = _destinationAddress;
                }
                (inputToken, outputToken) = _decodeTokensFromUniswapV3EncodedPath(encodedPath);
            } else if (selector == 0x7a1eb1b9) {
                (inputToken, outputToken, , inputTokenAmount, minOutputTokenAmount) =
                	abi.decode(_data[4:], (address, address, uint256, uint256, uint256));
            } else if (selector == 0x0f3b31b2) {
                address[] memory tokens;
                (tokens, , inputTokenAmount, minOutputTokenAmount) =
                	abi.decode(_data[4:], (address[], uint256, uint256, uint256));
                require(tokens.length > 1, "Multihop token path too short");
                inputToken = tokens[0];
                outputToken = tokens[tokens.length - 1];
            } else {
                revert("Unsupported 0xAPI function selector");
            }
        }

        require(inputToken != ETH_ADDRESS && outputToken != ETH_ADDRESS, "ETH not supported");
        require(inputToken == _sourceToken, "Mismatched input token");
        require(outputToken == _destinationToken, "Mismatched output token");
        require(!supportsRecipient || recipient == _destinationAddress, "Mismatched recipient");
        require(inputTokenAmount == _sourceQuantity, "Mismatched input token quantity");
        require(minOutputTokenAmount >= _minDestinationQuantity, "Mismatched output token quantity");

        return (
            zeroExAddress,
            0,
            _data
        );
    }

    function getRfqOrderMakerFillAmount(RfqOrder memory order, uint256 takerTokenFillAmount)
        private
        pure
        returns (uint256 makerTokenFillAmount)
    {

        if (order.takerAmount == 0 || order.makerAmount == 0 || takerTokenFillAmount == 0) {
            return 0;
        }
        return uint256(order.makerAmount * takerTokenFillAmount / order.takerAmount);
    }

    function _decodeTokensFromUniswapV3EncodedPath(bytes memory encodedPath)
        private
        pure
        returns (
            address inputToken,
            address outputToken
        )
    {

        require(encodedPath.length >= UNISWAP_V3_SINGLE_HOP_PATH_SIZE, "UniswapV3 token path too short");

        uint256 numHops = (encodedPath.length - UNISWAP_V3_PATH_ADDRESS_SIZE)/UNISWAP_V3_SINGLE_HOP_OFFSET_SIZE;
        uint256 lastTokenOffset = numHops * UNISWAP_V3_SINGLE_HOP_OFFSET_SIZE;
        assembly {
            let p := add(encodedPath, 32)
            inputToken := shr(96, mload(p))
            p := add(p, lastTokenOffset)
            outputToken := shr(96, mload(p))
        }
    }
}