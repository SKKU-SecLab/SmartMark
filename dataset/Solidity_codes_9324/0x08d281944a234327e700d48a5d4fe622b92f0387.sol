
pragma solidity 0.6.7;

contract SAFESaviourRegistry {

    mapping (address => uint256) public authorizedAccounts;
    function addAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "SAFESaviourRegistry/account-not-authorized");
        _;
    }

    modifier isSaviour {

        require(saviours[msg.sender] == 1, "SAFESaviourRegistry/not-a-saviour");
        _;
    }

    uint256 public saveCooldown;

    mapping(bytes32 => mapping(address => uint256)) public lastSaveTime;

    mapping(address => uint256) public saviours;

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event ModifyParameters(bytes32 parameter, uint256 val);
    event ToggleSaviour(address saviour, uint256 whitelistState);
    event MarkSave(bytes32 indexed collateralType, address indexed safeHandler);

    constructor(uint256 saveCooldown_) public {
        require(saveCooldown_ > 0, "SAFESaviourRegistry/null-save-cooldown");
        authorizedAccounts[msg.sender] = 1;
        saveCooldown = saveCooldown_;
        emit ModifyParameters("saveCooldown", saveCooldown_);
    }

    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }

    function addition(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "SAFESaviourRegistry/add-uint-uint-overflow");
    }

    function modifyParameters(bytes32 parameter, uint256 val) external isAuthorized {

        require(val > 0, "SAFESaviourRegistry/null-val");
        if (parameter == "saveCooldown") {
          saveCooldown = val;
        } else revert("SAFESaviourRegistry/modify-unrecognized-param");
        emit ModifyParameters(parameter, val);
    }
    function toggleSaviour(address saviour) external isAuthorized {

        if (saviours[saviour] == 0) {
          saviours[saviour] = 1;
        } else {
          saviours[saviour] = 0;
        }
        emit ToggleSaviour(saviour, saviours[saviour]);
    }

    function markSave(bytes32 collateralType, address safeHandler) external isSaviour {

        require(
          either(lastSaveTime[collateralType][safeHandler] == 0,
          addition(lastSaveTime[collateralType][safeHandler], saveCooldown) < now),
          "SAFESaviourRegistry/wait-more-to-save"
        );
        lastSaveTime[collateralType][safeHandler] = now;
        emit MarkSave(collateralType, safeHandler);
    }
}