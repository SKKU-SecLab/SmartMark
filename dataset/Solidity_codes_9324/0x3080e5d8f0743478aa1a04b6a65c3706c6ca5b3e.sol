
pragma solidity ^0.6.7;

abstract contract AccountingEngineLike {
    function debtAuctionHouse() virtual public returns (address);
}
abstract contract DebtAuctionHouseLike {
    function AUCTION_HOUSE_TYPE() virtual public returns (bytes32);
    function activeDebtAuctions() virtual public returns (uint256);
}
abstract contract ProtocolTokenAuthorityLike {
    function setRoot(address) virtual public;
    function setOwner(address) virtual public;
    function addAuthorization(address) virtual public;
    function removeAuthorization(address) virtual public;

    function owner() virtual public view returns (address);
    function root() virtual public view returns (address);
}

contract GebPrintingPermissions {

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

        require(authorizedAccounts[msg.sender] == 1, "GebPrintingPermissions/account-not-authorized");
        _;
    }

    struct SystemRights {
        bool    covered;
        uint256 revokeRightsDeadline;
        uint256 uncoverCooldownEnd;
        uint256 withdrawAddedRightsDeadline;
        address previousDebtAuctionHouse;
        address currentDebtAuctionHouse;
    }

    mapping(address => SystemRights) public allowedSystems;
    mapping(address => uint256)      public usedAuctionHouses;

    uint256 public unrevokableRightsCooldown;
    uint256 public denyRightsCooldown;
    uint256 public addRightsCooldown;
    uint256 public coveredSystems;

    ProtocolTokenAuthorityLike public protocolTokenAuthority;

    bytes32 public constant AUCTION_HOUSE_TYPE = bytes32("DEBT");

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event ModifyParameters(bytes32 parameter, uint data);
    event GiveUpAuthorityRoot();
    event GiveUpAuthorityOwnership();
    event RevokeDebtAuctionHouses(address accountingEngine, address currentHouse, address previousHouse);
    event CoverSystem(address accountingEngine, address debtAuctionHouse, uint256 coveredSystems, uint256 withdrawAddedRightsDeadline);
    event StartUncoverSystem(address accountingEngine, address debtAuctionHouse, uint256 coveredSystems, uint256 revokeRightsDeadline, uint256 uncoverCooldownEnd, uint256 withdrawAddedRightsDeadline);
    event AbandonUncoverSystem(address accountingEngine);
    event EndUncoverSystem(address accountingEngine, address currentHouse, address previousHouse);
    event UpdateCurrentDebtAuctionHouse(address accountingEngine, address currentHouse, address previousHouse);
    event RemovePreviousDebtAuctionHouse(address accountingEngine, address currentHouse, address previousHouse);
    event ProposeIndefinitePrintingPermissions(address accountingEngine, uint256 freezeDelay);

    constructor(address protocolTokenAuthority_) public {
        authorizedAccounts[msg.sender] = 1;
        protocolTokenAuthority = ProtocolTokenAuthorityLike(protocolTokenAuthority_);
        emit AddAuthorization(msg.sender);
    }

    function addition(uint x, uint y) internal pure returns (uint z) {

        z = x + y;
        require(z >= x);
    }
    function subtract(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x);
    }

    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }
    function both(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := and(x, y)}
    }

    function modifyParameters(bytes32 parameter, uint data) external isAuthorized {

        if (parameter == "unrevokableRightsCooldown") unrevokableRightsCooldown = data;
        else if (parameter == "denyRightsCooldown") denyRightsCooldown = data;
        else if (parameter == "addRightsCooldown") addRightsCooldown = data;
        else revert("GebPrintingPermissions/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }

    function giveUpAuthorityRoot() external isAuthorized {

        require(protocolTokenAuthority.root() == address(this), "GebPrintingPermissions/not-root");
        protocolTokenAuthority.setRoot(address(0));
        emit GiveUpAuthorityRoot();
    }
    function giveUpAuthorityOwnership() external isAuthorized {

        require(
          either(
            protocolTokenAuthority.root() == address(this),
            protocolTokenAuthority.owner() == address(this)
          ), "GebPrintingPermissions/not-root-or-owner"
        );
        protocolTokenAuthority.setOwner(address(0));
        emit GiveUpAuthorityOwnership();
    }

    function revokeDebtAuctionHouses(address accountingEngine) internal {

        address currentHouse  = allowedSystems[accountingEngine].currentDebtAuctionHouse;
        address previousHouse = allowedSystems[accountingEngine].previousDebtAuctionHouse;
        delete allowedSystems[accountingEngine];
        protocolTokenAuthority.removeAuthorization(currentHouse);
        protocolTokenAuthority.removeAuthorization(previousHouse);
        emit RevokeDebtAuctionHouses(accountingEngine, currentHouse, previousHouse);
    }

    function coverSystem(address accountingEngine) external isAuthorized {

        require(!allowedSystems[accountingEngine].covered, "GebPrintingPermissions/system-already-covered");
        address debtAuctionHouse = AccountingEngineLike(accountingEngine).debtAuctionHouse();
        require(
          keccak256(abi.encode(DebtAuctionHouseLike(debtAuctionHouse).AUCTION_HOUSE_TYPE())) ==
          keccak256(abi.encode(AUCTION_HOUSE_TYPE)),
          "GebPrintingPermissions/not-a-debt-auction-house"
        );
        require(usedAuctionHouses[debtAuctionHouse] == 0, "GebPrintingPermissions/auction-house-already-used");
        usedAuctionHouses[debtAuctionHouse] = 1;
        uint newWithdrawAddedRightsCooldown = addition(now, addRightsCooldown);
        allowedSystems[accountingEngine] = SystemRights(
          true,
          uint256(-1),
          0,
          newWithdrawAddedRightsCooldown,
          address(0),
          debtAuctionHouse
        );
        coveredSystems = addition(coveredSystems, 1);
        protocolTokenAuthority.addAuthorization(debtAuctionHouse);
        emit CoverSystem(accountingEngine, debtAuctionHouse, coveredSystems, newWithdrawAddedRightsCooldown);
    }
    function startUncoverSystem(address accountingEngine) external isAuthorized {

        require(allowedSystems[accountingEngine].covered, "GebPrintingPermissions/system-not-covered");
        require(allowedSystems[accountingEngine].uncoverCooldownEnd == 0, "GebPrintingPermissions/system-not-being-uncovered");
        require(
          DebtAuctionHouseLike(allowedSystems[accountingEngine].currentDebtAuctionHouse).activeDebtAuctions() == 0,
          "GebPrintingPermissions/ongoing-debt-auctions-current-house"
        );
        if (allowedSystems[accountingEngine].previousDebtAuctionHouse != address(0)) {
          require(
            DebtAuctionHouseLike(allowedSystems[accountingEngine].previousDebtAuctionHouse).activeDebtAuctions() == 0,
            "GebPrintingPermissions/ongoing-debt-auctions-previous-house"
          );
        }
        require(
          either(
            coveredSystems > 1,
            now <= allowedSystems[accountingEngine].withdrawAddedRightsDeadline
          ),
          "GebPrintingPermissions/not-enough-systems-covered"
        );

        if (now <= allowedSystems[accountingEngine].withdrawAddedRightsDeadline) {
          coveredSystems = subtract(coveredSystems, 1);
          usedAuctionHouses[allowedSystems[accountingEngine].previousDebtAuctionHouse] = 0;
          usedAuctionHouses[allowedSystems[accountingEngine].currentDebtAuctionHouse] = 0;
          revokeDebtAuctionHouses(accountingEngine);
        } else {
          require(allowedSystems[accountingEngine].revokeRightsDeadline >= now, "GebPrintingPermissions/revoke-frozen");
          allowedSystems[accountingEngine].uncoverCooldownEnd = addition(now, denyRightsCooldown);
        }
        emit StartUncoverSystem(
          accountingEngine,
          allowedSystems[accountingEngine].currentDebtAuctionHouse,
          coveredSystems,
          allowedSystems[accountingEngine].revokeRightsDeadline,
          allowedSystems[accountingEngine].uncoverCooldownEnd,
          allowedSystems[accountingEngine].withdrawAddedRightsDeadline
        );
    }
    function abandonUncoverSystem(address accountingEngine) external isAuthorized {

        require(allowedSystems[accountingEngine].covered, "GebPrintingPermissions/system-not-covered");
        require(allowedSystems[accountingEngine].uncoverCooldownEnd > 0, "GebPrintingPermissions/system-not-being-uncovered");
        allowedSystems[accountingEngine].uncoverCooldownEnd = 0;
        emit AbandonUncoverSystem(accountingEngine);
    }
    function endUncoverSystem(address accountingEngine) external isAuthorized {

        require(allowedSystems[accountingEngine].covered, "GebPrintingPermissions/system-not-covered");
        require(allowedSystems[accountingEngine].uncoverCooldownEnd > 0, "GebPrintingPermissions/system-not-being-uncovered");
        require(allowedSystems[accountingEngine].uncoverCooldownEnd < now, "GebPrintingPermissions/cooldown-not-passed");
        require(
          DebtAuctionHouseLike(allowedSystems[accountingEngine].currentDebtAuctionHouse).activeDebtAuctions() == 0,
          "GebPrintingPermissions/ongoing-debt-auctions-current-house"
        );
        if (allowedSystems[accountingEngine].previousDebtAuctionHouse != address(0)) {
          require(
            DebtAuctionHouseLike(allowedSystems[accountingEngine].previousDebtAuctionHouse).activeDebtAuctions() == 0,
            "GebPrintingPermissions/ongoing-debt-auctions-previous-house"
          );
        }
        require(
          either(
            coveredSystems > 1,
            now <= allowedSystems[accountingEngine].withdrawAddedRightsDeadline
          ),
          "GebPrintingPermissions/not-enough-systems-covered"
        );

        usedAuctionHouses[allowedSystems[accountingEngine].previousDebtAuctionHouse] = 0;
        usedAuctionHouses[allowedSystems[accountingEngine].currentDebtAuctionHouse]  = 0;

        coveredSystems = subtract(coveredSystems, 1);
        revokeDebtAuctionHouses(accountingEngine);

        emit EndUncoverSystem(
          accountingEngine,
          allowedSystems[accountingEngine].currentDebtAuctionHouse,
          allowedSystems[accountingEngine].previousDebtAuctionHouse
        );

        delete allowedSystems[accountingEngine];
    }
    function updateCurrentDebtAuctionHouse(address accountingEngine) external isAuthorized {

        require(allowedSystems[accountingEngine].covered, "GebPrintingPermissions/system-not-covered");
        address newHouse = AccountingEngineLike(accountingEngine).debtAuctionHouse();
        require(newHouse != allowedSystems[accountingEngine].currentDebtAuctionHouse, "GebPrintingPermissions/new-house-not-changed");
        require(
          keccak256(abi.encode(DebtAuctionHouseLike(newHouse).AUCTION_HOUSE_TYPE())) ==
          keccak256(abi.encode(AUCTION_HOUSE_TYPE)),
          "GebPrintingPermissions/new-house-not-a-debt-auction"
        );
        require(allowedSystems[accountingEngine].previousDebtAuctionHouse == address(0), "GebPrintingPermissions/previous-house-not-removed");
        require(usedAuctionHouses[newHouse] == 0, "GebPrintingPermissions/auction-house-already-used");
        usedAuctionHouses[newHouse] = 1;
        allowedSystems[accountingEngine].previousDebtAuctionHouse =
          allowedSystems[accountingEngine].currentDebtAuctionHouse;
        allowedSystems[accountingEngine].currentDebtAuctionHouse = newHouse;
        protocolTokenAuthority.addAuthorization(newHouse);
        emit UpdateCurrentDebtAuctionHouse(
          accountingEngine,
          allowedSystems[accountingEngine].currentDebtAuctionHouse,
          allowedSystems[accountingEngine].previousDebtAuctionHouse
        );
    }
    function removePreviousDebtAuctionHouse(address accountingEngine) external isAuthorized {

        require(allowedSystems[accountingEngine].covered, "GebPrintingPermissions/system-not-covered");
        require(
          allowedSystems[accountingEngine].previousDebtAuctionHouse != address(0),
          "GebPrintingPermissions/inexistent-previous-auction-house"
        );
        require(
          DebtAuctionHouseLike(allowedSystems[accountingEngine].previousDebtAuctionHouse).activeDebtAuctions() == 0,
          "GebPrintingPermissions/ongoing-debt-auctions-previous-house"
        );
        address previousHouse = allowedSystems[accountingEngine].previousDebtAuctionHouse;
        usedAuctionHouses[previousHouse] = 0;
        allowedSystems[accountingEngine].previousDebtAuctionHouse = address(0);
        protocolTokenAuthority.removeAuthorization(previousHouse);
        emit RemovePreviousDebtAuctionHouse(
          accountingEngine,
          allowedSystems[accountingEngine].currentDebtAuctionHouse,
          previousHouse
        );
    }
    function proposeIndefinitePrintingPermissions(address accountingEngine, uint256 freezeDelay) external isAuthorized {

        require(allowedSystems[accountingEngine].covered, "GebPrintingPermissions/system-not-covered");
        require(both(freezeDelay >= unrevokableRightsCooldown, freezeDelay > 0), "GebPrintingPermissions/low-delay");
        require(allowedSystems[accountingEngine].revokeRightsDeadline > addition(now, freezeDelay), "GebPrintingPermissions/big-delay");
        allowedSystems[accountingEngine].revokeRightsDeadline = addition(now, freezeDelay);
        emit ProposeIndefinitePrintingPermissions(accountingEngine, freezeDelay);
    }
}