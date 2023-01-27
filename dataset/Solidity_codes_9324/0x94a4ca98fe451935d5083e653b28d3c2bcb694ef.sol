


pragma solidity 0.6.7;

abstract contract SAFEEngineLike {
    function approveSAFEModification(address) virtual external;
    function coinBalance(address) virtual public view returns (uint256);
    function transferInternalCoins(address,address,uint256) virtual external;
}
abstract contract SurplusAuctionHouseLike {
    function startAuction(uint256, uint256) virtual public returns (uint256);
    function contractEnabled() virtual public returns (uint256);
}
abstract contract AccountingEngineLike {
    function surplusAuctionAmountToSell() virtual public view returns (uint256);
    function contractEnabled() virtual public view returns (uint256);
}

contract SurplusAuctionTrigger {

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

        require(authorizedAccounts[msg.sender] == 1, "SurplusAuctionTrigger/account-not-authorized");
        _;
    }

    SAFEEngineLike             public safeEngine;
    SurplusAuctionHouseLike    public surplusAuctionHouse;
    AccountingEngineLike       public accountingEngine;

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event AuctionSurplus(uint256 indexed id, uint256 coinBalance);
    event TransferSurplus(address dst, uint256 surplusAmount);

    constructor(
      address safeEngine_,
      address surplusAuctionHouse_,
      address accountingEngine_
    ) public {
        require(safeEngine_ != address(0), "SurplusAuctionTrigger/null-safe-engine");
        require(surplusAuctionHouse_ != address(0), "SurplusAuctionTrigger/null-surplus-auction-house");
        require(accountingEngine_ != address(0), "SurplusAuctionTrigger/null-accounting-engine");

        authorizedAccounts[msg.sender] = 1;

        safeEngine                 = SAFEEngineLike(safeEngine_);
        surplusAuctionHouse        = SurplusAuctionHouseLike(surplusAuctionHouse_);
        accountingEngine           = AccountingEngineLike(accountingEngine_);

        safeEngine.approveSAFEModification(surplusAuctionHouse_);
    }

    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }

    function auctionSurplus() external returns (uint256 id) {

        uint256 surplusAuctionAmountToSell = accountingEngine.surplusAuctionAmountToSell();

        require(
          safeEngine.coinBalance(address(this)) >= surplusAuctionAmountToSell, "SurplusAuctionTrigger/insufficient-surplus"
        );
        id = surplusAuctionHouse.startAuction(surplusAuctionAmountToSell, 0);
        emit AuctionSurplus(id, safeEngine.coinBalance(address(this)));
    }
    function transferSurplus(address dst, uint256 surplusAmount) external isAuthorized {

        require(
          either(accountingEngine.contractEnabled() == 0, surplusAuctionHouse.contractEnabled() == 0),
          "SurplusAuctionTrigger/cannot-transfer-surplus"
        );

        surplusAuctionHouse.contractEnabled() == 0;
        safeEngine.transferInternalCoins(address(this), dst, surplusAmount);
        emit TransferSurplus(dst, surplusAmount);
    }
}