

pragma solidity 0.5.8;

interface IERC1404 {

    function detectTransferRestriction (address from, address to, uint256 value) external view returns (uint8);

    function detectTransferFromRestriction (address sender, address from, address to, uint256 value) external view returns (uint8);

    function messageForTransferRestriction (uint8 restrictionCode) external view returns (string memory);
}

interface IERC1404getSuccessCode {

    function getSuccessCode () external view returns (uint256);
}

contract IERC1404Success is IERC1404getSuccessCode, IERC1404 {

}


pragma solidity 0.5.8;

interface IERC1404Validators {

    function balanceOf (address account) external view returns (uint256);

    function paused () external view returns (bool);

    function checkWhitelists (address from, address to) external view returns (bool);

    function checkTimelock (address _address, uint256 amount, uint256 balance) external view returns (bool);
}


pragma solidity 0.5.8;

contract RestrictionMessages {

    uint8 public constant SUCCESS_CODE = 0;
    uint8 public constant FAILURE_NON_WHITELIST = 1;
    uint8 public constant FAILURE_TIMELOCK = 2;
    uint8 public constant FAILURE_CONTRACT_PAUSED = 3;

    string public constant SUCCESS_MESSAGE = "SUCCESS";
    string public constant FAILURE_NON_WHITELIST_MESSAGE = "The transfer was restricted due to white list configuration.";
    string public constant FAILURE_TIMELOCK_MESSAGE = "The transfer was restricted due to timelocked tokens.";
    string public constant FAILURE_CONTRACT_PAUSED_MESSAGE = "The transfer was restricted due to the contract being paused.";
    string public constant UNKNOWN_ERROR = "Unknown Error Code";
}


pragma solidity 0.5.8;





contract TransferRestrictions is IERC1404, RestrictionMessages, IERC1404Success {


    IERC1404Validators validators;

    constructor(address _validators) public
    {
        require(_validators != address(0), "0x0 is not a valid _validators address");
        validators = IERC1404Validators(_validators);
    }

    function detectTransferRestriction (address from, address to, uint256 amount)
        public
        view
        returns (uint8)
    {
        if(!validators.checkWhitelists(from,to)) {
            return FAILURE_NON_WHITELIST;
        }

        if(!validators.checkTimelock(from, amount, validators.balanceOf(from))) {
            return FAILURE_TIMELOCK;
        }

        if(validators.paused()) {
            return FAILURE_CONTRACT_PAUSED;
        }

        return SUCCESS_CODE;
    }

    function detectTransferFromRestriction (address sender, address from, address to, uint256 value)
        public
        view
        returns (uint8)
    {
        if(!validators.checkWhitelists(sender, to)) {
            return FAILURE_NON_WHITELIST;
        }

        return detectTransferRestriction(from, to, value);
    }

    function messageForTransferRestriction (uint8 restrictionCode)
        external
        view
        returns (string memory)
    {
        if (restrictionCode == SUCCESS_CODE) {
            return SUCCESS_MESSAGE;
        }

        if (restrictionCode == FAILURE_NON_WHITELIST) {
            return FAILURE_NON_WHITELIST_MESSAGE;
        }

        if (restrictionCode == FAILURE_TIMELOCK) {
            return FAILURE_TIMELOCK_MESSAGE;
        }

        if (restrictionCode == FAILURE_CONTRACT_PAUSED) {
            return FAILURE_CONTRACT_PAUSED_MESSAGE;
        }

        return UNKNOWN_ERROR;
    }

    function getSuccessCode() external view returns (uint256) {

      return SUCCESS_CODE;
    }
}