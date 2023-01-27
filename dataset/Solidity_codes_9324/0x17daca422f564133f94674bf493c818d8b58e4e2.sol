
pragma solidity 0.6.7;

contract GebAuth {

    mapping (address => uint) public authorizedAccounts;
    function addAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "GebAuth/account-not-authorized");
        _;
    }

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);

    constructor () public {
        authorizedAccounts[msg.sender] = 1;
        emit AddAuthorization(msg.sender);
    }
}

abstract contract SFTreasuryCoreParamAdjusterLike {
    function modifyParameters(bytes32 parameter, uint256 val) external virtual;
    function modifyParameters(address targetContract, bytes4 targetFunction, bytes32 parameter, uint256 val) external virtual;
}

contract MinimalSFTreasuryCoreParamAdjusterOverlay is GebAuth {

    SFTreasuryCoreParamAdjusterLike public adjuster;

    constructor(address adjuster_) public GebAuth() {
        require(adjuster_ != address(0), "MinimalSFTreasuryCoreParamAdjusterOverlay/null-adjuster");
        adjuster = SFTreasuryCoreParamAdjusterLike(adjuster_);
    }

    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }

    function modifyParameters(bytes32 parameter, uint256 data) external isAuthorized {

        require(
          either(parameter == "minPullFundsThreshold", parameter == "pullFundsMinThresholdMultiplier"),
          "MinimalSFTreasuryCoreParamAdjusterOverlay/invalid-parameter"
        );
        adjuster.modifyParameters(parameter, data);
    }

    function modifyParameters(address targetContract, bytes4 targetFunction, bytes32 parameter, uint256 val) external isAuthorized {

        require(parameter == "latestExpectedCalls", "MinimalSFTreasuryCoreParamAdjusterOverlay/invalid-parameter");
        adjuster.modifyParameters(targetContract, targetFunction, parameter, val);
    }
}