
pragma solidity ^0.6.0;



interface IndexInterface {

    function master() external view returns (address);

}

interface ConnectorInterface {

    function connectorID() external view returns(uint _type, uint _id);

    function name() external view returns (string memory);

}


contract DSMath {


    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

}

contract Controllers is DSMath {


    event LogAddController(address indexed addr);
    event LogRemoveController(address indexed addr);

    address public constant instaIndex = 0x2971AdFa57b20E5a416aE5a708A8655A9c74f723;

    mapping(address => bool) public chief;
    mapping(address => bool) public connectors;
    mapping(address => bool) public staticConnectors;

    modifier isChief {

        require(chief[msg.sender] || msg.sender == IndexInterface(instaIndex).master(), "not-an-chief");
        _;
    }

    function enableChief(address _userAddress) external isChief {

        chief[_userAddress] = true;
        emit LogAddController(_userAddress);
    }

    function disableChief(address _userAddress) external isChief {

        delete chief[_userAddress];
        emit LogRemoveController(_userAddress);
    }

}


contract Listings is Controllers {

    address[] public connectorArray;
    uint public connectorCount;

    function addToArr(address _connector) internal {

        require(_connector != address(0), "Not-valid-connector");
        (, uint _id) = ConnectorInterface(_connector).connectorID();
        require(_id == (connectorArray.length+1),"ConnectorID-doesnt-match");
        ConnectorInterface(_connector).name(); // Checking if connector has function name()
        connectorArray.push(_connector);
    }

    address[] public staticConnectorArray;

    function addToArrStatic(address _connector) internal {

        require(_connector != address(0), "Not-valid-connector");
        (, uint _id) = ConnectorInterface(_connector).connectorID();
        require(_id == (staticConnectorArray.length+1),"ConnectorID-doesnt-match");
        ConnectorInterface(_connector).name(); // Checking if connector has function name()
        staticConnectorArray.push(_connector);
    }

}


contract InstaConnectors is Listings {


    event LogEnable(address indexed connector);
    event LogDisable(address indexed connector);
    event LogEnableStatic(address indexed connector);

    function enable(address _connector) external isChief {

        require(!connectors[_connector], "already-enabled");
        addToArr(_connector);
        connectors[_connector] = true;
        connectorCount++;
        emit LogEnable(_connector);
    }
    function disable(address _connector) external isChief {

        require(connectors[_connector], "already-disabled");
        delete connectors[_connector];
        connectorCount--;
        emit LogDisable(_connector);
    }

    function enableStatic(address _connector) external isChief {

        require(!staticConnectors[_connector], "already-enabled");
        addToArrStatic(_connector);
        staticConnectors[_connector] = true;
        emit LogEnableStatic(_connector);
    }

    function isConnector(address[] calldata _connectors) external view returns (bool isOk) {

        isOk = true;
        for (uint i = 0; i < _connectors.length; i++) {
            if (!connectors[_connectors[i]]) {
                isOk = false;
                break;
            }
        }
    }

    function isStaticConnector(address[] calldata _connectors) external view returns (bool isOk) {

        isOk = true;
        for (uint i = 0; i < _connectors.length; i++) {
            if (!staticConnectors[_connectors[i]]) {
                isOk = false;
                break;
            }
        }
    }

    function connectorLength() external view returns (uint) {

        return connectorArray.length;
    }

    function staticConnectorLength() external view returns (uint) {

        return staticConnectorArray.length;
    }
}