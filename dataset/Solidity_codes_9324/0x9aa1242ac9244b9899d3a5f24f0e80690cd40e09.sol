

pragma solidity ^0.8.4;

contract SubgraphUpdater {

    event UpdateSubgraph(string message, string[] params);

    function update(string memory message, string[] memory params) external returns(bool) {

        emit UpdateSubgraph(message, params);

        return true;
    }
}