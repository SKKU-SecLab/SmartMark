
pragma solidity 0.6.10;
pragma experimental "ABIEncoderV2";

contract UniswapV2ExchangeAdapter {



    address public immutable router;


    constructor(address _router) public {
        router = _router;
    }


    function getTradeCalldata(
        address _sourceToken,
        address _destinationToken,
        address _destinationAddress,
        uint256 _sourceQuantity,
        uint256 _minDestinationQuantity,
        bytes memory _data
    )
        external
        view
        returns (address, uint256, bytes memory)
    {   

        address[] memory path;

        if(_data.length == 0){
            path = new address[](2);
            path[0] = _sourceToken;
            path[1] = _destinationToken;
        } else {
            path = abi.decode(_data, (address[]));
        }

        bytes memory callData = abi.encodeWithSignature(
            "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)",
            _sourceQuantity,
            _minDestinationQuantity,
            path,
            _destinationAddress,
            block.timestamp
        );
        return (router, 0, callData);
    }

    function getSpender()
        external
        view
        returns (address)
    {

        return router;
    }
}