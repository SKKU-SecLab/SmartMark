pragma solidity >=0.7.0;

contract Authorizable {


    address public owner;
    mapping(address => bool) public authorized;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Sender not owner");
        _;
    }

    modifier onlyAuthorized() {

        require(isAuthorized(msg.sender), "Sender not Authorized");
        _;
    }

    function isAuthorized(address who) public view returns (bool) {

        return authorized[who];
    }

    function authorize(address who) external onlyOwner {

        _authorize(who);
    }

    function deauthorize(address who) external onlyOwner {

        authorized[who] = false;
    }

    function setOwner(address who) public onlyOwner {

        owner = who;
    }

    function _authorize(address who) internal {

        authorized[who] = true;
    }
}// Apache-2.0
pragma solidity ^0.8.0;

interface IDeploymentValidator {

    function validateWPAddress(address wrappedPosition) external;


    function validatePoolAddress(address pool) external;


    function validateAddresses(address wrappedPosition, address pool) external;


    function checkWPValidation(address wrappedPosition)
        external
        view
        returns (bool);


    function checkPoolValidation(address pool) external view returns (bool);


    function checkPairValidation(address wrappedPosition, address pool)
        external
        view
        returns (bool);

}// Apache-2.0
pragma solidity ^0.8.0;


contract DeploymentValidator is IDeploymentValidator, Authorizable {

    mapping(address => bool) public wrappedPositions;
    mapping(address => bool) public pools;
    mapping(bytes32 => bool) public pairs;

    constructor(address _owner) {
        _authorize(_owner);
    }

    function validateWPAddress(address wrappedPosition)
        public
        override
        onlyAuthorized
    {

        wrappedPositions[wrappedPosition] = true;
    }

    function validatePoolAddress(address pool) public override onlyAuthorized {

        pools[pool] = true;
    }

    function validateAddresses(address wrappedPosition, address pool)
        external
        override
        onlyAuthorized
    {

        validatePoolAddress(pool);
        validateWPAddress(wrappedPosition);
        bytes32 data = keccak256(abi.encodePacked(wrappedPosition, pool));
        pairs[data] = true;
    }

    function checkWPValidation(address wrappedPosition)
        external
        view
        override
        returns (bool)
    {

        return wrappedPositions[wrappedPosition];
    }

    function checkPoolValidation(address pool)
        external
        view
        override
        returns (bool)
    {

        return pools[pool];
    }

    function checkPairValidation(address wrappedPosition, address pool)
        external
        view
        override
        returns (bool)
    {

        bytes32 data = keccak256(abi.encodePacked(wrappedPosition, pool));
        return pairs[data];
    }
}