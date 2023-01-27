pragma solidity 0.8.11;

interface IOracle {

    function get(bytes calldata data)
        external
        returns (bool success, uint256 rate);


    function peek(bytes calldata data)
        external
        view
        returns (bool success, uint256 rate);


    function peekSpot(bytes calldata data) external view returns (uint256 rate);


    function symbol(bytes calldata data) external view returns (string memory);


    function name(bytes calldata data) external view returns (string memory);

}// MIT

pragma solidity 0.8.11;


interface IKashiPair {

    function oracle() external view returns (IOracle);


    function oracleData() external view returns (bytes memory);


    function updateExchangeRate() external returns (bool updated, uint256 rate);


    function exchangeRate() external view returns (uint256);

}// MIT

pragma solidity 0.8.11;


interface IResolver {

    function updateExchangeRateForPairs(IKashiPair[] memory kashiPairs)
        external;


    function checker(IKashiPair[] memory kashiPairs)
        external
        view
        returns (bool canExec, bytes memory execPayload);

}// MIT

pragma solidity 0.8.11;


contract KashiExchangeRateResolver is IResolver {

    function updateExchangeRateForPairs(IKashiPair[] memory kashiPairs)
        external
    {

        for (uint256 i; i < kashiPairs.length; i++) {
            if (address(kashiPairs[i]) != address(0)) {
                kashiPairs[i].updateExchangeRate();
            }
        }
    }

    function checker(IKashiPair[] memory kashiPairs)
        external
        view
        override
        returns (bool canExec, bytes memory execPayload)
    {

        IKashiPair[] memory pairsToUpdate = new IKashiPair[](kashiPairs.length);

        for (uint256 i; i < kashiPairs.length; i++) {
            IOracle oracle = kashiPairs[i].oracle();
            bytes memory oracleData = kashiPairs[i].oracleData();
            uint256 lastExchangeRate = kashiPairs[i].exchangeRate();
            (bool updated, uint256 rate) = oracle.peek(oracleData);
            if (updated) {
                uint256 deviation = ((
                    lastExchangeRate > rate
                        ? lastExchangeRate - rate
                        : rate - lastExchangeRate
                ) * 100) / lastExchangeRate;
                if (deviation > 20) {
                    pairsToUpdate[i] = kashiPairs[i];
                    canExec = true;
                }
            }
        }

        if (canExec) {
            execPayload = abi.encodeWithSignature(
                "updateExchangeRateForPairs(address[])",
                pairsToUpdate
            );
        }
    }
}