
pragma solidity 0.7.0;

interface IERC1404 {

    function detectTransferRestriction (address from, address to, uint256 value) external view returns (uint8);
    function messageForTransferRestriction (uint8 restrictionCode) external view returns (string memory);
}
    
    
interface IERC1404Checks {

    function paused () external view returns (bool);
    function checkWhitelists (address from, address to) external view returns (bool);
    function isLocked(address wallet) external view returns (bool);

}



contract Ownable {

    
    address public owner;
    address private _newOwner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor () {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function proposeOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _newOwner = newOwner;
    }
    
    function acceptOwnership() public {

        require(msg.sender == _newOwner, "Ownable: caller is not the new owner");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


contract RestrictedMessages {

    
    uint8 internal constant SUCCESS = 0;
    uint8 internal constant PAUSED_FAILURE = 1;
    uint8 internal constant WHITELIST_FAILURE = 2;
    uint8 internal constant TIMELOCK_FAILURE = 3;
    
    string internal constant SUCCESS_MSG = "SUCCESS";
    string internal constant PAUSED_FAILURE_MSG = "ERROR: All transfer is paused now";
    string internal constant WHITELIST_FAILURE_MSG = "ERROR: Wallet is not whitelisted";
    string internal constant TIMELOCK_FAILURE_MSG = "ERROR: Wallet is locked";
    string internal constant UNKNOWN = "ERROR: Unknown";
}


contract ERC1404 is IERC1404, RestrictedMessages, Ownable {

    
    IERC1404Checks public checker;

    event UpdatedChecker(IERC1404Checks indexed _checker);
    
    function updateChecker(IERC1404Checks _checker) public onlyOwner{

        require(_checker != IERC1404Checks(0), "ERC1404: Address should not be zero.");
        checker = _checker;
        emit UpdatedChecker(_checker);
    }
    
    function detectTransferRestriction (address from, address to, uint256 amount) public override view returns (uint8) {
        if(checker.paused()){ 
            return PAUSED_FAILURE; 
        }
        if(!checker.checkWhitelists(from, to)){ 
            return WHITELIST_FAILURE;
        }
        if(checker.isLocked(from)){ 
            return TIMELOCK_FAILURE;
        }
        return SUCCESS;
    }
    
    function messageForTransferRestriction (uint8 code) public override pure returns (string memory){
        if (code == SUCCESS) {
            return SUCCESS_MSG;
        }
        if (code == PAUSED_FAILURE) {
            return PAUSED_FAILURE_MSG;
        }
        if (code == WHITELIST_FAILURE) {
            return WHITELIST_FAILURE_MSG;
        }
        if (code == TIMELOCK_FAILURE) {
            return TIMELOCK_FAILURE_MSG;
        }
        return UNKNOWN;
    }

}