
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

abstract contract IncreasingTreasuryReimbursementLike {
    function modifyParameters(bytes32, uint256) virtual external;
}
contract MinimalIncreasingTreasuryReimbursementOverlay is GebAuth {

    mapping(address => uint256) public reimbursers;

    event ToggleReimburser(address reimburser, uint256 whitelisted);

    constructor() public GebAuth() {}

    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }

    function toggleReimburser(address reimburser) external isAuthorized {

        if (reimbursers[reimburser] == 0) {
          reimbursers[reimburser] = 1;
        } else {
          reimbursers[reimburser] = 0;
        }
        emit ToggleReimburser(reimburser, reimbursers[reimburser]);
    }

    function modifyParameters(address reimburser, bytes32 parameter, uint256 data) external isAuthorized {

        require(reimbursers[reimburser] == 1, "MinimalIncreasingTreasuryReimbursementOverlay/not-whitelisted");
        if (either(parameter == "baseUpdateCallerReward", parameter == "maxUpdateCallerReward")) {
          IncreasingTreasuryReimbursementLike(reimburser).modifyParameters(parameter, data);
        } else revert("MinimalIncreasingTreasuryReimbursementOverlay/modify-forbidden-param");
    }
}