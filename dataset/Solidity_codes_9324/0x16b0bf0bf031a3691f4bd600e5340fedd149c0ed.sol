
pragma solidity 0.6.7;




abstract contract CollateralLike {
    function approve(address, uint) virtual public;
    function transfer(address, uint) virtual public;
    function transferFrom(address, address, uint) virtual public;
    function deposit() virtual public payable;
    function withdraw(uint) virtual public;
}

abstract contract ManagerLike {
    function safeCan(address, uint, address) virtual public view returns (uint);
    function collateralTypes(uint) virtual public view returns (bytes32);
    function ownsSAFE(uint) virtual public view returns (address);
    function safes(uint) virtual public view returns (address);
    function safeEngine() virtual public view returns (address);
    function openSAFE(bytes32, address) virtual public returns (uint);
    function transferSAFEOwnership(uint, address) virtual public;
    function allowSAFE(uint, address, uint) virtual public;
    function allowHandler(address, uint) virtual public;
    function modifySAFECollateralization(uint, int, int) virtual public;
    function transferCollateral(uint, address, uint) virtual public;
    function transferInternalCoins(uint, address, uint) virtual public;
    function quitSystem(uint, address) virtual public;
    function enterSystem(address, uint) virtual public;
    function moveSAFE(uint, uint) virtual public;
    function protectSAFE(uint, address, address) virtual public;
}

abstract contract SAFEEngineLike {
    function canModifySAFE(address, address) virtual public view returns (uint);
    function collateralTypes(bytes32) virtual public view returns (uint, uint, uint, uint, uint);
    function coinBalance(address) virtual public view returns (uint);
    function safes(bytes32, address) virtual public view returns (uint, uint);
    function modifySAFECollateralization(bytes32, address, address, address, int, int) virtual public;
    function approveSAFEModification(address) virtual public;
    function transferInternalCoins(address, address, uint) virtual public;
}

abstract contract CollateralJoinLike {
    function decimals() virtual public returns (uint);
    function collateral() virtual public returns (CollateralLike);
    function join(address, uint) virtual public payable;
    function exit(address, uint) virtual public;
}

abstract contract GNTJoinLike {
    function bags(address) virtual public view returns (address);
    function make(address) virtual public returns (address);
}

abstract contract DSTokenLike {
    function balanceOf(address) virtual public view returns (uint);
    function approve(address, uint) virtual public;
    function transfer(address, uint) virtual public returns (bool);
    function transferFrom(address, address, uint) virtual public returns (bool);
}

abstract contract WethLike {
    function balanceOf(address) virtual public view returns (uint);
    function approve(address, uint) virtual public;
    function transfer(address, uint) virtual public;
    function transferFrom(address, address, uint) virtual public;
    function deposit() virtual public payable;
    function withdraw(uint) virtual public;
}

abstract contract CoinJoinLike {
    function safeEngine() virtual public returns (SAFEEngineLike);
    function systemCoin() virtual public returns (DSTokenLike);
    function join(address, uint) virtual public payable;
    function exit(address, uint) virtual public;
}

abstract contract ApproveSAFEModificationLike {
    function approveSAFEModification(address) virtual public;
    function denySAFEModification(address) virtual public;
}

abstract contract GlobalSettlementLike {
    function collateralCashPrice(bytes32) virtual public view returns (uint);
    function redeemCollateral(bytes32, uint) virtual public;
    function freeCollateral(bytes32) virtual public;
    function prepareCoinsForRedeeming(uint) virtual public;
    function processSAFE(bytes32, address) virtual public;
}

abstract contract TaxCollectorLike {
    function taxSingle(bytes32) virtual public returns (uint);
}

abstract contract CoinSavingsAccountLike {
    function savings(address) virtual public view returns (uint);
    function updateAccumulatedRate() virtual public returns (uint);
    function deposit(uint) virtual public;
    function withdraw(uint) virtual public;
}

abstract contract ProxyRegistryLike {
    function proxies(address) virtual public view returns (address);
    function build(address) virtual public returns (address);
}

abstract contract ProxyLike {
    function owner() virtual public view returns (address);
}


contract Common {

    uint256 constant RAY = 10 ** 27;

    function multiply(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }

    function _coinJoin_join(address apt, address safeHandler, uint wad) internal {

        CoinJoinLike(apt).systemCoin().approve(apt, wad);
        CoinJoinLike(apt).join(safeHandler, wad);
    }

    function coinJoin_join(address apt, address safeHandler, uint wad) public {

        CoinJoinLike(apt).systemCoin().transferFrom(msg.sender, address(this), wad);

        _coinJoin_join(apt, safeHandler, wad);
    }
}

contract BasicActions is Common {


    function subtract(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, "sub-overflow");
    }

    function toInt(uint x) internal pure returns (int y) {

        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function toRad(uint wad) internal pure returns (uint rad) {

        rad = multiply(wad, 10 ** 27);
    }

    function convertTo18(address collateralJoin, uint256 amt) internal returns (uint256 wad) {

        uint decimals = CollateralJoinLike(collateralJoin).decimals();
        wad = amt;
        if (decimals < 18) {
          wad = multiply(
              amt,
              10 ** (18 - decimals)
          );
        } else if (decimals > 18) {
          wad = amt / 10 ** (decimals - 18);
        }
    }

    function _getGeneratedDeltaDebt(
        address safeEngine,
        address taxCollector,
        address safeHandler,
        bytes32 collateralType,
        uint wad
    ) internal returns (int deltaDebt) {

        uint rate = TaxCollectorLike(taxCollector).taxSingle(collateralType);
        require(rate > 0, "invalid-collateral-type");

        uint coin = SAFEEngineLike(safeEngine).coinBalance(safeHandler);

        if (coin < multiply(wad, RAY)) {
            deltaDebt = toInt(subtract(multiply(wad, RAY), coin) / rate);
            deltaDebt = multiply(uint(deltaDebt), rate) < multiply(wad, RAY) ? deltaDebt + 1 : deltaDebt;
        }
    }

    function _getRepaidDeltaDebt(
        address safeEngine,
        uint coin,
        address safe,
        bytes32 collateralType
    ) internal view returns (int deltaDebt) {

        (, uint rate,,,) = SAFEEngineLike(safeEngine).collateralTypes(collateralType);
        require(rate > 0, "invalid-collateral-type");

        (, uint generatedDebt) = SAFEEngineLike(safeEngine).safes(collateralType, safe);

        deltaDebt = toInt(coin / rate);
        deltaDebt = uint(deltaDebt) <= generatedDebt ? - deltaDebt : - toInt(generatedDebt);
    }

    function _getRepaidAlDebt(
        address safeEngine,
        address usr,
        address safe,
        bytes32 collateralType
    ) internal view returns (uint wad) {

        (, uint rate,,,) = SAFEEngineLike(safeEngine).collateralTypes(collateralType);
        (, uint generatedDebt) = SAFEEngineLike(safeEngine).safes(collateralType, safe);
        uint coin = SAFEEngineLike(safeEngine).coinBalance(usr);

        uint rad = subtract(multiply(generatedDebt, rate), coin);
        wad = rad / RAY;

        wad = multiply(wad, RAY) < rad ? wad + 1 : wad;
    }

    function _generateDebt(address manager, address taxCollector, address coinJoin, uint safe, uint wad, address to) internal {

        address safeHandler = ManagerLike(manager).safes(safe);
        address safeEngine = ManagerLike(manager).safeEngine();
        bytes32 collateralType = ManagerLike(manager).collateralTypes(safe);
        modifySAFECollateralization(manager, safe, 0, _getGeneratedDeltaDebt(safeEngine, taxCollector, safeHandler, collateralType, wad));
        transferInternalCoins(manager, safe, address(this), toRad(wad));
        if (SAFEEngineLike(safeEngine).canModifySAFE(address(this), address(coinJoin)) == 0) {
            SAFEEngineLike(safeEngine).approveSAFEModification(coinJoin);
        }
        CoinJoinLike(coinJoin).exit(to, wad);
    }

    function _lockETH(
        address manager,
        address ethJoin,
        uint safe,
        uint value
    ) internal {

        ethJoin_join(ethJoin, address(this), value);
        SAFEEngineLike(ManagerLike(manager).safeEngine()).modifySAFECollateralization(
            ManagerLike(manager).collateralTypes(safe),
            ManagerLike(manager).safes(safe),
            address(this),
            address(this),
            toInt(value),
            0
        );
    }

    function _repayDebt(
        address manager,
        address coinJoin,
        uint safe,
        uint wad,
        bool transferFromCaller
    ) internal {

        address safeEngine = ManagerLike(manager).safeEngine();
        address safeHandler = ManagerLike(manager).safes(safe);
        bytes32 collateralType = ManagerLike(manager).collateralTypes(safe);

        address own = ManagerLike(manager).ownsSAFE(safe);
        if (own == address(this) || ManagerLike(manager).safeCan(own, safe, address(this)) == 1) {
            if (transferFromCaller) coinJoin_join(coinJoin, safeHandler, wad);
            else _coinJoin_join(coinJoin, safeHandler, wad);
            modifySAFECollateralization(manager, safe, 0, _getRepaidDeltaDebt(safeEngine, SAFEEngineLike(safeEngine).coinBalance(safeHandler), safeHandler, collateralType));
        } else {
            if (transferFromCaller) coinJoin_join(coinJoin, address(this), wad);
            else _coinJoin_join(coinJoin, address(this), wad);
            SAFEEngineLike(safeEngine).modifySAFECollateralization(
                collateralType,
                safeHandler,
                address(this),
                address(this),
                0,
                _getRepaidDeltaDebt(safeEngine, wad * RAY, safeHandler, collateralType)
            );
        }
    }

    function _repayDebtAndFreeETH(
        address manager,
        address ethJoin,
        address coinJoin,
        uint safe,
        uint collateralWad,
        uint deltaWad,
        bool transferFromCaller
    ) internal {

        address safeHandler = ManagerLike(manager).safes(safe);
        if (transferFromCaller) coinJoin_join(coinJoin, safeHandler, deltaWad);
        else _coinJoin_join(coinJoin, safeHandler, deltaWad);
        modifySAFECollateralization(
            manager,
            safe,
            -toInt(collateralWad),
            _getRepaidDeltaDebt(ManagerLike(manager).safeEngine(), SAFEEngineLike(ManagerLike(manager).safeEngine()).coinBalance(safeHandler), safeHandler, ManagerLike(manager).collateralTypes(safe))
        );
        transferCollateral(manager, safe, address(this), collateralWad);
        CollateralJoinLike(ethJoin).exit(address(this), collateralWad);
        CollateralJoinLike(ethJoin).collateral().withdraw(collateralWad);
    }


    function transfer(address collateral, address dst, uint amt) external {

        CollateralLike(collateral).transfer(dst, amt);
    }

    function ethJoin_join(address apt, address safe) external payable {

        ethJoin_join(apt, safe, msg.value);
    }

    function ethJoin_join(address apt, address safe, uint value) public payable {

        CollateralJoinLike(apt).collateral().deposit{value: value}();
        CollateralJoinLike(apt).collateral().approve(address(apt), value);
        CollateralJoinLike(apt).join(safe, value);
    }

    function approveSAFEModification(
        address safeEngine,
        address usr
    ) external {

        ApproveSAFEModificationLike(safeEngine).approveSAFEModification(usr);
    }

    function denySAFEModification(
        address safeEngine,
        address usr
    ) external {

        ApproveSAFEModificationLike(safeEngine).denySAFEModification(usr);
    }

    function openSAFE(
        address manager,
        bytes32 collateralType,
        address usr
    ) public returns (uint safe) {

        safe = ManagerLike(manager).openSAFE(collateralType, usr);
    }

    function transferSAFEOwnership(
        address manager,
        uint safe,
        address usr
    ) public {

        ManagerLike(manager).transferSAFEOwnership(safe, usr);
    }

    function transferSAFEOwnershipToProxy(
        address proxyRegistry,
        address manager,
        uint safe,
        address dst
    ) external {

        address proxy = ProxyRegistryLike(proxyRegistry).proxies(dst);
        if (proxy == address(0) || ProxyLike(proxy).owner() != dst) {
            uint csize;
            assembly {
                csize := extcodesize(dst)
            }
            require(csize == 0, "dst-is-a-contract");
            proxy = ProxyRegistryLike(proxyRegistry).build(dst);
        }
        transferSAFEOwnership(manager, safe, proxy);
    }

    function allowSAFE(
        address manager,
        uint safe,
        address usr,
        uint ok
    ) external {

        ManagerLike(manager).allowSAFE(safe, usr, ok);
    }

    function allowHandler(
        address manager,
        address usr,
        uint ok
    ) external {

        ManagerLike(manager).allowHandler(usr, ok);
    }

    function transferCollateral(
        address manager,
        uint safe,
        address dst,
        uint wad
    ) public {

        ManagerLike(manager).transferCollateral(safe, dst, wad);
    }

    function transferInternalCoins(
        address manager,
        uint safe,
        address dst,
        uint rad
    ) public {

        ManagerLike(manager).transferInternalCoins(safe, dst, rad);
    }


    function modifySAFECollateralization(
        address manager,
        uint safe,
        int deltaCollateral,
        int deltaDebt
    ) public {

        ManagerLike(manager).modifySAFECollateralization(safe, deltaCollateral, deltaDebt);
    }

    function quitSystem(
        address manager,
        uint safe,
        address dst
    ) external {

        ManagerLike(manager).quitSystem(safe, dst);
    }

    function enterSystem(
        address manager,
        address src,
        uint safe
    ) external {

        ManagerLike(manager).enterSystem(src, safe);
    }

    function moveSAFE(
        address manager,
        uint safeSrc,
        uint safeDst
    ) external {

        ManagerLike(manager).moveSAFE(safeSrc, safeDst);
    }

    function lockETH(
        address manager,
        address ethJoin,
        uint safe
    ) public payable {

        _lockETH(manager, ethJoin, safe, msg.value);
    }

    function freeETH(
        address manager,
        address ethJoin,
        uint safe,
        uint wad
    ) public {

        modifySAFECollateralization(manager, safe, -toInt(wad), 0);
        transferCollateral(manager, safe, address(this), wad);
        CollateralJoinLike(ethJoin).exit(address(this), wad);
        CollateralJoinLike(ethJoin).collateral().withdraw(wad);
        msg.sender.transfer(wad);
    }


    function exitETH(
        address manager,
        address ethJoin,
        uint safe,
        uint wad
    ) external {

        transferCollateral(manager, safe, address(this), wad);
        CollateralJoinLike(ethJoin).exit(address(this), wad);
        CollateralJoinLike(ethJoin).collateral().withdraw(wad);
        msg.sender.transfer(wad);
    }

    function generateDebt(
        address manager,
        address taxCollector,
        address coinJoin,
        uint safe,
        uint wad
    ) public {

        _generateDebt(manager, taxCollector, coinJoin, safe, wad, msg.sender);
    }

    function repayDebt(
        address manager,
        address coinJoin,
        uint safe,
        uint wad
    ) public {

        _repayDebt(manager, coinJoin, safe, wad, true);
    }

    function lockETHAndGenerateDebt(
        address manager,
        address taxCollector,
        address ethJoin,
        address coinJoin,
        uint safe,
        uint deltaWad
    ) public payable {

        _lockETH(manager, ethJoin, safe, msg.value);
        _generateDebt(manager, taxCollector, coinJoin, safe, deltaWad, msg.sender);
    }

    function openLockETHAndGenerateDebt(
        address manager,
        address taxCollector,
        address ethJoin,
        address coinJoin,
        bytes32 collateralType,
        uint deltaWad
    ) external payable returns (uint safe) {

        safe = openSAFE(manager, collateralType, address(this));
        lockETHAndGenerateDebt(manager, taxCollector, ethJoin, coinJoin, safe, deltaWad);
    }

    function repayDebtAndFreeETH(
        address manager,
        address ethJoin,
        address coinJoin,
        uint safe,
        uint collateralWad,
        uint deltaWad
    ) external {

        _repayDebtAndFreeETH(manager, ethJoin, coinJoin, safe, collateralWad, deltaWad, true);
        msg.sender.transfer(collateralWad);
    }    
}





abstract contract AccountingEngineLike {
    function debtAuctionHouse() external virtual returns (address);
    function surplusAuctionHouse() external virtual returns (address);
    function auctionDebt() external virtual returns (uint256);
    function auctionSurplus() external virtual returns (uint256);
}

abstract contract DebtAuctionHouseLike {
    function bids(uint) external virtual returns (uint, uint, address, uint48, uint48);
    function decreaseSoldAmount(uint256, uint256, uint256) external virtual;
    function restartAuction(uint256) external virtual;
    function settleAuction(uint256) external virtual;
    function protocolToken() external virtual returns (address);
}

abstract contract SurplusAuctionHouseLike {
    function bids(uint) external virtual returns (uint, uint, address, uint48, uint48);
    function increaseBidSize(uint256 id, uint256 amountToBuy, uint256 bid) external virtual;
    function restartAuction(uint256) external virtual;
    function settleAuction(uint256) external virtual;
    function protocolToken() external virtual returns (address);
}

contract AuctionCommon {


    function claimProxyFunds(address tokenAddress) public {

        DSTokenLike token = DSTokenLike(tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    function claimProxyFunds(address[] memory tokenAddresses) public {

        for (uint i = 0; i < tokenAddresses.length; i++)
            claimProxyFunds(tokenAddresses[i]);
    }

    function both(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := and(x, y)}
    }

    function toWad(uint rad) internal pure returns (uint wad) {

        wad = rad / 10**27;
    }
}

contract GebProxySurplusAuctionActions is Common, AuctionCommon {


    function startAndIncreaseBidSize(address accountingEngineAddress, uint bidSize) public {

        AccountingEngineLike accountingEngine = AccountingEngineLike(accountingEngineAddress);
        SurplusAuctionHouseLike surplusAuctionHouse = SurplusAuctionHouseLike(accountingEngine.surplusAuctionHouse());
        DSTokenLike protocolToken = DSTokenLike(surplusAuctionHouse.protocolToken());

        uint auctionId = accountingEngine.auctionSurplus();
        require(protocolToken.transferFrom(msg.sender, address(this), bidSize), "geb-proxy-auction-actions/transfer-from-failed");
        protocolToken.approve(address(surplusAuctionHouse), bidSize);
        (, uint amountToSell,,,) = surplusAuctionHouse.bids(auctionId);
        surplusAuctionHouse.increaseBidSize(auctionId, amountToSell, bidSize);
    }

    function increaseBidSize(address auctionHouse, uint auctionId, uint bidSize) public {

        SurplusAuctionHouseLike surplusAuctionHouse = SurplusAuctionHouseLike(auctionHouse);
        DSTokenLike protocolToken = DSTokenLike(surplusAuctionHouse.protocolToken());

        require(protocolToken.transferFrom(msg.sender, address(this), bidSize), "geb-proxy-auction-actions/transfer-from-failed");
        protocolToken.approve(address(surplusAuctionHouse), bidSize);
        (, uint amountToSell,, uint48 bidExpiry, uint48 auctionDeadline) = surplusAuctionHouse.bids(auctionId);
        if (auctionDeadline < now && bidExpiry == 0 && auctionDeadline > 0) {
            surplusAuctionHouse.restartAuction(auctionId);
        }
        surplusAuctionHouse.increaseBidSize(auctionId, amountToSell, bidSize);
    }

    function settleAuction(address coinJoin, address auctionHouse, uint auctionId) public {

        SurplusAuctionHouseLike surplusAuctionHouse = SurplusAuctionHouseLike(auctionHouse);
        SAFEEngineLike safeEngine = SAFEEngineLike(CoinJoinLike(coinJoin).safeEngine());
        (, uint amountToBuy,,,) = surplusAuctionHouse.bids(auctionId);
        surplusAuctionHouse.settleAuction(auctionId);
        if (safeEngine.canModifySAFE(address(this), address(coinJoin)) == 0) {
            safeEngine.approveSAFEModification(address(coinJoin));
        }
        CoinJoinLike(coinJoin).exit(msg.sender, toWad(amountToBuy));
        claimProxyFunds(surplusAuctionHouse.protocolToken());
    }
}