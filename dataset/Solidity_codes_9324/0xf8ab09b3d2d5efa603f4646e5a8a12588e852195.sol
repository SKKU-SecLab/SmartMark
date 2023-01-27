


pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

contract InitializableOwnable {

    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;


    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier notInitialized() {

        require(!_INITIALIZED_, "DODO_INITIALIZED");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }


    function initOwner(address newOwner) public notInitialized {

        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {

        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}




interface IDODOMineV3Registry {

    function addMineV3(
        address mine,
        bool isLpToken,
        address stakeToken
    ) external;

}

contract DODOMineV3Registry is InitializableOwnable, IDODOMineV3Registry {


    mapping (address => bool) public isAdminListed;
    
    mapping(address => address) public _MINE_REGISTRY_;
    mapping(address => address[]) public _LP_REGISTRY_;
    mapping(address => address[]) public _SINGLE_REGISTRY_;


    event NewMineV3(address mine, address stakeToken, bool isLpToken);
    event RemoveMineV3(address mine, address stakeToken);
    event addAdmin(address admin);
    event removeAdmin(address admin);


    function addMineV3(
        address mine,
        bool isLpToken,
        address stakeToken
    ) override external {

        require(isAdminListed[msg.sender], "ACCESS_DENIED");
        _MINE_REGISTRY_[mine] = stakeToken;
        if(isLpToken) {
            _LP_REGISTRY_[stakeToken].push(mine);
        }else {
            _SINGLE_REGISTRY_[stakeToken].push(mine);
        }

        emit NewMineV3(mine, stakeToken, isLpToken);
    }


    function removeMineV3(
        address mine,
        bool isLpToken,
        address stakeToken
    ) external onlyOwner {

        _MINE_REGISTRY_[mine] = address(0);
        if(isLpToken) {
            uint256 len = _LP_REGISTRY_[stakeToken].length;
            for (uint256 i = 0; i < len; i++) {
                if (mine == _LP_REGISTRY_[stakeToken][i]) {
                    if(i != len - 1) {
                        _LP_REGISTRY_[stakeToken][i] = _LP_REGISTRY_[stakeToken][len - 1];
                    }
                    _LP_REGISTRY_[stakeToken].pop();
                    break;
                }
            }
        }else {
            uint256 len = _SINGLE_REGISTRY_[stakeToken].length;
            for (uint256 i = 0; i < len; i++) {
                if (mine == _SINGLE_REGISTRY_[stakeToken][i]) {
                    if(i != len - 1) {
                        _SINGLE_REGISTRY_[stakeToken][i] = _SINGLE_REGISTRY_[stakeToken][len - 1];
                    }
                    _SINGLE_REGISTRY_[stakeToken].pop();
                    break;
                }
            }
        }

        emit RemoveMineV3(mine, stakeToken);
    }

    function addAdminList (address contractAddr) external onlyOwner {
        isAdminListed[contractAddr] = true;
        emit addAdmin(contractAddr);
    }

    function removeAdminList (address contractAddr) external onlyOwner {
        isAdminListed[contractAddr] = false;
        emit removeAdmin(contractAddr);
    }
}