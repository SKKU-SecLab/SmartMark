



pragma solidity ^0.8.6;

interface INestPriceFacade {

    







    function latestPrice(address tokenAddress, address payback) external payable returns (uint blockNumber, uint price);



    function latestPriceAndTriggeredPriceInfo(address tokenAddress, address payback) 
    external 
    payable 
    returns (
        uint latestPriceBlockNumber, 
        uint latestPriceValue,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    );


    function lastPriceListAndTriggeredPriceInfo(
        address tokenAddress, 
        uint count, 
        address payback
    ) external payable 
    returns (
        uint[] memory prices,
        uint triggeredPriceBlockNumber,
        uint triggeredPriceValue,
        uint triggeredAvgPrice,
        uint triggeredSigmaSQ
    );




}




pragma solidity ^0.8.6;
interface ICoFiXController {



    function queryPrice(
        address tokenAddress,
        address payback
    ) external payable returns (
        uint ethAmount, 
        uint tokenAmount, 
        uint blockNumber
    );


    function queryOracle(
        address tokenAddress,
        address payback
    ) external payable returns (
        uint k, 
        uint ethAmount, 
        uint tokenAmount, 
        uint blockNumber
    );

    
    function calcRevisedK(uint sigmaSQ, uint p0, uint bn0, uint p, uint bn) external view returns (uint k);


    function latestPriceInfo(address tokenAddress, address payback) 
    external 
    payable 
    returns (
        uint blockNumber, 
        uint priceEthAmount,
        uint priceTokenAmount,
        uint avgPriceEthAmount,
        uint avgPriceTokenAmount,
        uint sigmaSQ
    );

}




pragma solidity ^0.8.6;
contract CoFiXController is ICoFiXController {


    uint constant BLOCK_TIME = 14;

    address constant NEST_PRICE_FACADE = 0xB5D2890c061c321A5B6A4a4254bb1522425BAF0A;

    function initialize(address nestPriceFacade) external {

    }

    function latestPriceInfo(address tokenAddress, address payback) 
    public 
    payable 
    override
    returns (
        uint blockNumber, 
        uint priceEthAmount,
        uint priceTokenAmount,
        uint avgPriceEthAmount,
        uint avgPriceTokenAmount,
        uint sigmaSQ
    ) {

        (
            blockNumber, 
            priceTokenAmount,
            ,//uint triggeredPriceBlockNumber,
            ,//uint triggeredPriceValue,
            avgPriceTokenAmount,
            sigmaSQ
        ) = INestPriceFacade(NEST_PRICE_FACADE).latestPriceAndTriggeredPriceInfo { 
            value: msg.value 
        } (tokenAddress, payback);
        
        _checkPrice(priceTokenAmount, avgPriceTokenAmount);
        priceEthAmount = 1 ether;
        avgPriceEthAmount = 1 ether;
    }


    function queryPrice(
        address tokenAddress,
        address payback
    ) external payable override returns (
        uint ethAmount, 
        uint tokenAmount, 
        uint blockNumber
    ) {

        (blockNumber, tokenAmount) = INestPriceFacade(NEST_PRICE_FACADE).latestPrice { 
            value: msg.value 
        } (tokenAddress, payback);
        ethAmount = 1 ether;

        

    }

    function queryOracle(
        address tokenAddress,
        address payback
    ) external override payable returns (
        uint k, 
        uint ethAmount, 
        uint tokenAmount, 
        uint blockNumber
    ) {

        (
            uint[] memory prices,
            ,//uint triggeredPriceBlockNumber,
            ,//uint triggeredPriceValue,
            uint triggeredAvgPrice,
            uint triggeredSigmaSQ
        ) = INestPriceFacade(NEST_PRICE_FACADE).lastPriceListAndTriggeredPriceInfo {
            value: msg.value  
        } (tokenAddress, 2, payback);

        tokenAmount = prices[1];
        _checkPrice(tokenAmount, triggeredAvgPrice);
        blockNumber = prices[0];
        ethAmount = 1 ether;

        k = calcRevisedK(triggeredSigmaSQ, prices[3], prices[2], tokenAmount, blockNumber);
    }

    function calcRevisedK(uint sigmaSQ, uint p0, uint bn0, uint p, uint bn) public view override returns (uint k) {

        k = _calcK(_calcRevisedSigmaSQ(sigmaSQ, p0, bn0, p, bn), bn);
    }

    function _calcRevisedSigmaSQ(
        uint sigmaSQ,
        uint p0, 
        uint bn0, 
        uint p, 
        uint bn
    ) private pure returns (uint revisedSigmaSQ) {


        uint rq2 = p * 1 ether / p0;
        if (rq2 > 1 ether) {
            rq2 -= 1 ether;
        } else {
            rq2 = 1 ether - rq2;
        }
        rq2 = rq2 * rq2 / 1 ether;

        uint dt = (bn - bn0) * BLOCK_TIME;
        uint sq1 = 0;
        uint rq2dt = rq2 / dt;
        if (sigmaSQ * 10 > rq2dt) {
            sq1 = (sigmaSQ * 10 - rq2dt) / 9;
        }

        uint dds = dt * dt * dt * sq1;
        if (rq2 <= (dds << 2)) {
            revisedSigmaSQ = sigmaSQ;
        } else if (rq2 <= 9 * dds) {
            revisedSigmaSQ = (sq1 + rq2dt) >> 1;
        } else {
            revisedSigmaSQ = (sq1 + (rq2dt << 2)) / 5;
        }
    }

    function _calcK(uint sigmaSQ, uint bn) private view returns (uint k) {

        k = 0.002 ether + _sqrt((block.number - bn) * BLOCK_TIME * sigmaSQ / 1e4) * 2e11;
    }

    function _sqrt(uint y) private pure returns (uint z) {

        if (y > 3) {
            z = y;
            uint x = (y >> 1) + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) >> 1;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _checkPrice(uint price, uint avgPrice) private pure {

        require(
            price <= avgPrice * 11 / 10 &&
            price >= avgPrice * 9 / 10, 
            "CoFiXController: price deviation"
        );
    }
    
    function getAdmin() external view returns (address adm) {

        assembly {
            adm := sload(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103)
        }
    }
}