
pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT
pragma solidity ^0.6.2;

interface WETH {

    function deposit() external payable;


    function withdraw(uint256 wad) external;


    function approve(address guy, uint256 wad) external returns (bool);


    function transfer(address dst, uint256 wad) external returns (bool);

}// MIT

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

library Account {

    enum Status {Normal, Liquid, Vapor}
    struct Info {
        address owner; // The address that owns the account
        uint256 number; // A nonce that allows a single address to control many accounts
    }
    struct Storage {
        mapping(uint256 => Types.Par) balances; // Mapping from marketId to principal
        Status status;
    }
}

library Actions {

    enum ActionType {
        Deposit, // supply tokens
        Withdraw, // borrow tokens
        Transfer, // transfer balance between accounts
        Buy, // buy an amount of some token (externally)
        Sell, // sell an amount of some token (externally)
        Trade, // trade tokens against another account
        Liquidate, // liquidate an undercollateralized or expiring account
        Vaporize, // use excess tokens to zero-out a completely negative account
        Call // send arbitrary data to an address
    }

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        Types.AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    struct DepositArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 market;
        address from;
    }

    struct WithdrawArgs {
        Types.AssetAmount amount;
        Account.Info account;
        uint256 market;
        address to;
    }

    struct CallArgs {
        Account.Info account;
        address callee;
        bytes data;
    }
}

library Decimal {

    struct D256 {
        uint256 value;
    }
}

library Types {

    enum AssetDenomination {
        Wei, // the amount is denominated in wei
        Par // the amount is denominated in par
    }

    enum AssetReference {
        Delta, // the amount is given as a delta from the current value
        Target // the amount is given as an exact number to end up at
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct TotalPar {
        uint128 borrow;
        uint128 supply;
    }

    struct Par {
        bool sign; // true if positive
        uint128 value;
    }

    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }
}

interface ISoloMargin {

    function getMarketTokenAddress(uint256 marketId)
        external
        view
        returns (address);


    function getNumMarkets() external view returns (uint256);


    function operate(
        Account.Info[] calldata accounts,
        Actions.ActionArgs[] calldata actions
    ) external;

}

interface ICallee {


    function callFunction(
        address sender,
        Account.Info calldata accountInfo,
        bytes calldata data
    ) external;

}// SPDX-License-Identifier:
pragma solidity >=0.6.0 <0.7.0;



contract DydxFlashloanBase {

    using SafeMath for uint256;


    function _getMarketIdFromTokenAddress(address _solo, address token)
        internal
        view
        returns (uint256)
    {

        ISoloMargin solo = ISoloMargin(_solo);

        uint256 numMarkets = solo.getNumMarkets();

        address curToken;
        for (uint256 i = 0; i < numMarkets; i++) {
            curToken = solo.getMarketTokenAddress(i);

            if (curToken == token) {
                return i;
            }
        }

        revert("No marketId found for provided token");
    }

    function _getRepaymentAmount() internal pure returns (uint256) {

        return 2;
    }

    function _getAccountInfo() internal view returns (Account.Info memory) {

        return Account.Info({owner: address(this), number: 1});
    }

    function _getWithdrawAction(uint256 marketId, uint256 amount)
        internal
        view
        returns (Actions.ActionArgs memory)
    {

        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Withdraw,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }

    function _getCallAction(bytes memory data)
        internal
        view
        returns (Actions.ActionArgs memory)
    {

        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Call,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: false,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: 0
                }),
                primaryMarketId: 0,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: data
            });
    }

    function _getDepositAction(uint256 marketId, uint256 amount)
        internal
        view
        returns (Actions.ActionArgs memory)
    {

        return
            Actions.ActionArgs({
                actionType: Actions.ActionType.Deposit,
                accountId: 0,
                amount: Types.AssetAmount({
                    sign: true,
                    denomination: Types.AssetDenomination.Wei,
                    ref: Types.AssetReference.Delta,
                    value: amount
                }),
                primaryMarketId: marketId,
                secondaryMarketId: 0,
                otherAddress: address(this),
                otherAccountId: 0,
                data: ""
            });
    }
}// MIT
pragma solidity >=0.6.0 <0.7.0;

interface IDssCdpManager {

    function cdpAllow(
        uint256 cdp,
        address usr,
        uint256 ok
    ) external;


    function cdpCan(
        address,
        uint256,
        address
    ) external view returns (uint256);


    function cdpi() external view returns (uint256);


    function count(address) external view returns (uint256);


    function enter(address src, uint256 cdp) external;


    function first(address) external view returns (uint256);


    function flux(
        bytes32 ilk,
        uint256 cdp,
        address dst,
        uint256 wad
    ) external;


    function flux(
        uint256 cdp,
        address dst,
        uint256 wad
    ) external;


    function frob(
        uint256 cdp,
        int256 dink,
        int256 dart
    ) external;


    function give(uint256 cdp, address dst) external;


    function ilks(uint256) external view returns (bytes32);


    function last(address) external view returns (uint256);


    function list(uint256) external view returns (uint256 prev, uint256 next);


    function move(
        uint256 cdp,
        address dst,
        uint256 rad
    ) external;


    function open(bytes32 ilk, address usr) external returns (uint256);


    function owns(uint256) external view returns (address);


    function quit(uint256 cdp, address dst) external;


    function shift(uint256 cdpSrc, uint256 cdpDst) external;


    function urnAllow(address usr, uint256 ok) external;


    function urnCan(address, address) external view returns (uint256);


    function urns(uint256) external view returns (address);


    function vat() external view returns (address);

}// MIT
pragma solidity >=0.6.0 <0.7.0;

interface IDssProxyActions {

    function cdpAllow(
        address manager,
        uint256 cdp,
        address usr,
        uint256 ok
    ) external;


    function daiJoin_join(
        address apt,
        address urn,
        uint256 wad
    ) external;


    function draw(
        address manager,
        address jug,
        address daiJoin,
        uint256 cdp,
        uint256 wad
    ) external;


    function enter(
        address manager,
        address src,
        uint256 cdp
    ) external;


    function ethJoin_join(address apt, address urn) external payable;


    function exitETH(
        address manager,
        address ethJoin,
        uint256 cdp,
        uint256 wad
    ) external;


    function exitGem(
        address manager,
        address gemJoin,
        uint256 cdp,
        uint256 amt
    ) external;


    function flux(
        address manager,
        uint256 cdp,
        address dst,
        uint256 wad
    ) external;


    function freeETH(
        address manager,
        address ethJoin,
        uint256 cdp,
        uint256 wad
    ) external;


    function freeGem(
        address manager,
        address gemJoin,
        uint256 cdp,
        uint256 amt
    ) external;


    function frob(
        address manager,
        uint256 cdp,
        int256 dink,
        int256 dart
    ) external;


    function gemJoin_join(
        address apt,
        address urn,
        uint256 amt,
        bool transferFrom
    ) external;


    function give(
        address manager,
        uint256 cdp,
        address usr
    ) external;


    function giveToProxy(
        address proxyRegistry,
        address manager,
        uint256 cdp,
        address dst
    ) external;


    function hope(address obj, address usr) external;


    function lockETH(
        address manager,
        address ethJoin,
        uint256 cdp
    ) external payable;


    function lockETHAndDraw(
        address manager,
        address jug,
        address ethJoin,
        address daiJoin,
        uint256 cdp,
        uint256 wadD
    ) external payable;


    function lockGem(
        address manager,
        address gemJoin,
        uint256 cdp,
        uint256 amt,
        bool transferFrom
    ) external;


    function lockGemAndDraw(
        address manager,
        address jug,
        address gemJoin,
        address daiJoin,
        uint256 cdp,
        uint256 amtC,
        uint256 wadD,
        bool transferFrom
    ) external;


    function makeGemBag(address gemJoin) external returns (address bag);


    function move(
        address manager,
        uint256 cdp,
        address dst,
        uint256 rad
    ) external;


    function nope(address obj, address usr) external;


    function open(
        address manager,
        bytes32 ilk,
        address usr
    ) external returns (uint256 cdp);


    function openLockETHAndDraw(
        address manager,
        address jug,
        address ethJoin,
        address daiJoin,
        bytes32 ilk,
        uint256 wadD
    ) external payable returns (uint256 cdp);


    function openLockGNTAndDraw(
        address manager,
        address jug,
        address gntJoin,
        address daiJoin,
        bytes32 ilk,
        uint256 amtC,
        uint256 wadD
    ) external returns (address bag, uint256 cdp);


    function openLockGemAndDraw(
        address manager,
        address jug,
        address gemJoin,
        address daiJoin,
        bytes32 ilk,
        uint256 amtC,
        uint256 wadD,
        bool transferFrom
    ) external returns (uint256 cdp);


    function quit(
        address manager,
        uint256 cdp,
        address dst
    ) external;


    function safeLockETH(
        address manager,
        address ethJoin,
        uint256 cdp,
        address owner
    ) external payable;


    function safeLockGem(
        address manager,
        address gemJoin,
        uint256 cdp,
        uint256 amt,
        bool transferFrom,
        address owner
    ) external;


    function safeWipe(
        address manager,
        address daiJoin,
        uint256 cdp,
        uint256 wad,
        address owner
    ) external;


    function safeWipeAll(
        address manager,
        address daiJoin,
        uint256 cdp,
        address owner
    ) external;


    function shift(
        address manager,
        uint256 cdpSrc,
        uint256 cdpOrg
    ) external;


    function transfer(
        address gem,
        address dst,
        uint256 amt
    ) external;


    function urnAllow(
        address manager,
        address usr,
        uint256 ok
    ) external;


    function wipe(
        address manager,
        address daiJoin,
        uint256 cdp,
        uint256 wad
    ) external;


    function wipeAll(
        address manager,
        address daiJoin,
        uint256 cdp
    ) external;


    function wipeAllAndFreeETH(
        address manager,
        address ethJoin,
        address daiJoin,
        uint256 cdp,
        uint256 wadC
    ) external;


    function wipeAllAndFreeGem(
        address manager,
        address gemJoin,
        address daiJoin,
        uint256 cdp,
        uint256 amtC
    ) external;


    function wipeAndFreeETH(
        address manager,
        address ethJoin,
        address daiJoin,
        uint256 cdp,
        uint256 wadC,
        uint256 wadD
    ) external;


    function wipeAndFreeGem(
        address manager,
        address gemJoin,
        address daiJoin,
        uint256 cdp,
        uint256 amtC,
        uint256 wadD
    ) external;

}// MIT
pragma solidity >=0.6.0 <0.7.0;

library Constants {

    address constant CDP_MANAGER = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    address constant PROXY_ACTIONS = 0x82ecD135Dce65Fbc6DbdD0e4237E0AF93FFD5038;
    address constant MCD_JOIN_ETH_A = 0x2F0b23f53734252Bda2277357e97e1517d6B042A;
    address constant MCD_JOIN_USDC_A = 0xA191e578a6736167326d05c119CE0c90849E84B7;
    address constant MCD_JOIN_DAI = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    address constant MCD_JUG = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address constant MCD_END = 0xaB14d3CE3F733CACB76eC2AbE7d2fcb00c99F3d5;

    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address constant UNISWAPV2_ROUTER2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    bytes32 constant USDC_A_ILK = bytes32("USDC-A");
    bytes32 constant ETH_A_ILK = bytes32("ETH-A");
}// MIT
pragma solidity >=0.6.0 <0.7.0;



interface GemLike {

    function approve(address, uint256) external;


    function transfer(address, uint256) external;


    function transferFrom(
        address,
        address,
        uint256
    ) external;


    function deposit() external payable;


    function withdraw(uint256) external;

}

interface GemJoinLike {

    function dec() external returns (uint256);


    function gem() external returns (address);


    function join(address, uint256) external payable;


    function exit(address, uint256) external;

}

interface VatLike {

    function can(address, address) external view returns (uint256);


    function ilks(bytes32)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );


    function dai(address) external view returns (uint256);


    function urns(bytes32, address) external view returns (uint256, uint256);


    function frob(
        bytes32,
        address,
        address,
        address,
        int256,
        int256
    ) external;


    function hope(address) external;


    function move(
        address,
        address,
        uint256
    ) external;

}

interface JugLike {

    function drip(bytes32) external returns (uint256);


    function ilks(bytes32) external view returns (uint256, uint256);

}

interface DaiJoinLike {

    function vat() external returns (VatLike);


    function dai() external returns (GemLike);


    function join(address, uint256) external payable;


    function exit(address, uint256) external;

}

contract DssActionsBase {

    uint256 constant RAY = 10**27;

    using SafeMath for uint256;

    function _convertTo18(address gemJoin, uint256 amt)
        internal
        returns (uint256 wad)
    {

        wad = amt.mul(10**(18 - GemJoinLike(gemJoin).dec()));
    }

    function _toInt(uint256 x) internal pure returns (int256 y) {

        y = int256(x);
        require(y >= 0, "int-overflow");
    }

    function _toRad(uint256 wad) internal pure returns (uint256 rad) {

        rad = wad.mul(10**27);
    }

    function _gemJoin_join(
        address apt,
        address urn,
        uint256 wad,
        bool transferFrom
    ) internal {

        if (transferFrom) {
            GemLike(GemJoinLike(apt).gem()).approve(apt, wad);
        }
        GemJoinLike(apt).join(urn, wad);
    }

    function _daiJoin_join(
        address apt,
        address urn,
        uint256 wad
    ) internal {

        DaiJoinLike(apt).dai().approve(apt, wad);
        DaiJoinLike(apt).join(urn, wad);
    }

    function _getDrawDart(
        address vat,
        address jug,
        address urn,
        bytes32 ilk,
        uint256 wad
    ) internal returns (int256 dart) {

        uint256 rate = JugLike(jug).drip(ilk);

        uint256 dai = VatLike(vat).dai(urn);

        if (dai < wad.mul(RAY)) {
            dart = _toInt(wad.mul(RAY).sub(dai) / rate);
            dart = uint256(dart).mul(rate) < wad.mul(RAY) ? dart + 1 : dart;
        }
    }

    function _getWipeDart(
        address vat,
        uint256 dai,
        address urn,
        bytes32 ilk
    ) internal view returns (int256 dart) {

        (, uint256 rate, , , ) = VatLike(vat).ilks(ilk);
        (, uint256 art) = VatLike(vat).urns(ilk, urn);

        dart = _toInt(dai / rate);
        dart = uint256(dart) <= art ? -dart : -_toInt(art);
    }

    function _getWipeAllWad(
        address vat,
        address usr,
        address urn,
        bytes32 ilk
    ) internal view returns (uint256 wad) {

        (, uint256 rate, , , ) = VatLike(vat).ilks(ilk);
        (, uint256 art) = VatLike(vat).urns(ilk, urn);
        uint256 dai = VatLike(vat).dai(usr);

        uint256 rad = art.mul(rate).sub(dai);
        wad = rad / RAY;

        wad = wad.mul(RAY) < rad ? wad + 1 : wad;
    }

    function _getSuppliedAndBorrow(address gemJoin, uint256 cdp)
        internal
        returns (uint256, uint256)
    {

        IDssCdpManager manager = IDssCdpManager(Constants.CDP_MANAGER);

        address vat = manager.vat();
        bytes32 ilk = manager.ilks(cdp);

        (, uint256 rate, , , ) = VatLike(vat).ilks(ilk);
        (uint256 supplied, uint256 art) = VatLike(vat).urns(
            ilk,
            manager.urns(cdp)
        );
        uint256 dai = VatLike(vat).dai(manager.owns(cdp));

        uint256 rad = art.mul(rate).sub(dai);
        uint256 wad = rad / RAY;

        uint256 borrowed = wad.mul(RAY) < rad ? wad + 1 : wad;

        supplied = supplied.div(10**(18 - GemJoinLike(gemJoin).dec()));

        return (supplied, borrowed);
    }

    function _lockGemAndDraw(
        address gemJoin,
        uint256 cdp,
        uint256 wadC,
        uint256 wadD
    ) internal {

        IDssCdpManager manager = IDssCdpManager(Constants.CDP_MANAGER);

        address urn = manager.urns(cdp);
        address vat = manager.vat();
        bytes32 ilk = manager.ilks(cdp);

        _gemJoin_join(gemJoin, urn, wadC, true);

        manager.frob(
            cdp,
            _toInt(_convertTo18(gemJoin, wadC)),
            _getDrawDart(vat, Constants.MCD_JUG, urn, ilk, wadD)
        );

        manager.move(cdp, address(this), _toRad(wadD));

        if (
            VatLike(vat).can(address(this), address(Constants.MCD_JOIN_DAI)) ==
            0
        ) {
            VatLike(vat).hope(Constants.MCD_JOIN_DAI);
        }
        DaiJoinLike(Constants.MCD_JOIN_DAI).exit(address(this), wadD);
    }

    function _wipeAllAndFreeGem(
        address gemJoin,
        uint256 cdp,
        uint256 amtC
    ) internal {

        IDssCdpManager manager = IDssCdpManager(Constants.CDP_MANAGER);

        address vat = manager.vat();
        address urn = manager.urns(cdp);
        bytes32 ilk = manager.ilks(cdp);
        (, uint256 art) = VatLike(vat).urns(ilk, urn);

        _daiJoin_join(
            Constants.MCD_JOIN_DAI,
            urn,
            _getWipeAllWad(vat, urn, urn, ilk)
        );
        uint256 wadC = _convertTo18(gemJoin, amtC);
        manager.frob(cdp, -_toInt(wadC), -int256(art));
        manager.flux(cdp, address(this), wadC);
        GemJoinLike(gemJoin).exit(address(this), amtC);
    }

    function _openLockGemAndDraw(
        address gemJoin,
        bytes32 ilk,
        uint256 amtC,
        uint256 wadD
    ) internal returns (uint256 cdp) {

        cdp = IDssCdpManager(Constants.CDP_MANAGER).open(ilk, address(this));
        _lockGemAndDraw(gemJoin, cdp, amtC, wadD);
    }
}// MIT
pragma solidity >=0.6.0 <0.7.0;

interface ICurveFiCurve {

    function get_virtual_price() external view returns (uint256 out);


    function add_liquidity(uint256[2] calldata amounts, uint256 deadline)
        external;


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256 out);


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256 out);


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        uint256 deadline
    ) external;


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        uint256 deadline
    ) external;


    function remove_liquidity(
        uint256 _amount,
        uint256 deadline,
        uint256[2] calldata min_amounts
    ) external;


    function remove_liquidity_imbalance(
        uint256[2] calldata amounts,
        uint256 deadline
    ) external;


    function commit_new_parameters(
        int128 amplification,
        int128 new_fee,
        int128 new_admin_fee
    ) external;


    function apply_new_parameters() external;


    function revert_new_parameters() external;


    function commit_transfer_ownership(address _owner) external;


    function apply_transfer_ownership() external;


    function revert_transfer_ownership() external;


    function withdraw_admin_fees() external;


    function coins(int128 arg0) external returns (address out);


    function underlying_coins(int128 arg0) external returns (address out);


    function balances(int128 arg0) external returns (uint256 out);


    function A() external returns (int128 out);


    function fee() external returns (int128 out);


    function admin_fee() external returns (int128 out);


    function owner() external returns (address out);


    function admin_actions_deadline() external returns (uint256 out);


    function transfer_ownership_deadline() external returns (uint256 out);


    function future_A() external returns (int128 out);


    function future_fee() external returns (int128 out);


    function future_admin_fee() external returns (int128 out);


    function future_owner() external returns (address out);

}// MIT
pragma solidity >=0.6.0 <0.7.0;







contract CloseShortDAI is ICallee, DydxFlashloanBase, DssActionsBase {

    struct CSDParams {
        uint256 cdpId; // CdpId to close
        address curvePool; // Which curve pool to use
        uint256 mintAmountDAI; // Amount of DAI to mint
        uint256 withdrawAmountUSDC; // Amount of USDC to withdraw from vault
        uint256 flashloanAmountWETH; // Amount of WETH flashloaned
    }

    function callFunction(
        address sender,
        Account.Info memory account,
        bytes memory data
    ) public override {

        CSDParams memory csdp = abi.decode(data, (CSDParams));

        uint256 wethCdp = _openLockGemAndDraw(
            Constants.MCD_JOIN_ETH_A,
            Constants.ETH_A_ILK,
            csdp.flashloanAmountWETH,
            csdp.mintAmountDAI
        );

        _wipeAllAndFreeGem(
            Constants.MCD_JOIN_USDC_A,
            csdp.cdpId,
            csdp.withdrawAmountUSDC
        );

        ICurveFiCurve curve = ICurveFiCurve(csdp.curvePool);
        uint256 usdcBal = IERC20(Constants.USDC).balanceOf(address(this));
        require(
            IERC20(Constants.USDC).approve(address(curve), usdcBal),
            "erc20-approve-curvepool-failed"
        );
        curve.exchange_underlying(int128(1), int128(0), usdcBal, 0);

        _wipeAllAndFreeGem(
            Constants.MCD_JOIN_ETH_A,
            wethCdp,
            csdp.flashloanAmountWETH
        );
    }

    function flashloanAndClose(
        address _sender,
        address _solo,
        address _curvePool,
        uint256 _cdpId,
        uint256 _ethUsdRatio18 // 1 ETH = <X> DAI?
    ) external payable {

        require(msg.value == 2, "!fee");

        ISoloMargin solo = ISoloMargin(_solo);

        uint256 marketId = _getMarketIdFromTokenAddress(_solo, Constants.WETH);

        (
            uint256 withdrawAmountUSDC,
            uint256 mintAmountDAI
        ) = _getSuppliedAndBorrow(Constants.MCD_JOIN_USDC_A, _cdpId);

        uint256 flashloanAmountWETH = mintAmountDAI.mul(1 ether).div(
            _ethUsdRatio18.div(2)
        );

        require(
            IERC20(Constants.WETH).balanceOf(_solo) >= flashloanAmountWETH,
            "!weth-supply"
        );

        WETH(Constants.WETH).deposit{value: msg.value}();
        WETH(Constants.WETH).approve(_solo, flashloanAmountWETH.add(msg.value));

        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

        operations[0] = _getWithdrawAction(marketId, flashloanAmountWETH);
        operations[1] = _getCallAction(
            abi.encode(
                CSDParams({
                    mintAmountDAI: mintAmountDAI,
                    withdrawAmountUSDC: withdrawAmountUSDC,
                    flashloanAmountWETH: flashloanAmountWETH,
                    cdpId: _cdpId,
                    curvePool: _curvePool
                })
            )
        );
        operations[2] = _getDepositAction(
            marketId,
            flashloanAmountWETH.add(msg.value)
        );

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        solo.operate(accountInfos, operations);

        uint256 daiBal = IERC20(Constants.DAI).balanceOf(address(this));
        require(
            IERC20(Constants.DAI).approve(_curvePool, daiBal),
            "erc20-approve-curvepool-failed"
        );
        ICurveFiCurve(_curvePool).exchange_underlying(
            int128(0),
            int128(1),
            daiBal,
            0
        );

        IERC20(Constants.USDC).transfer(
            _sender,
            IERC20(Constants.USDC).balanceOf(address(this))
        );
    }
}// MIT
pragma solidity >=0.6.0 <0.7.0;

interface IDSProxy {

    function authority() external view returns (address);


    function cache() external view returns (address);


    function execute(address _target, bytes calldata _data)
        external
        payable
        returns (bytes memory response);


    function execute(bytes calldata _code, bytes calldata _data)
        external
        payable
        returns (address target, bytes memory response);


    function owner() external view returns (address);


    function setAuthority(address authority_) external;


    function setCache(address _cacheAddr) external returns (bool);


    function setOwner(address owner_) external;

}// MIT
pragma solidity >=0.6.0 <0.7.0;

interface IGetCdps {

    function getCdpsAsc(address manager, address guy)
        external
        view
        returns (
            uint256[] memory ids,
            address[] memory urns,
            bytes32[] memory ilks
        );


    function getCdpsDesc(address manager, address guy)
        external
        view
        returns (
            uint256[] memory ids,
            address[] memory urns,
            bytes32[] memory ilks
        );

}// MIT
pragma solidity >=0.6.0 <0.7.0;

interface IProxyRegistry {

    function build() external returns (address proxy);


    function proxies(address) external view returns (address);


    function build(address owner) external returns (address proxy);

}// MIT
pragma solidity >=0.4.21 <0.7.0;

contract Migrations {

  address public owner;
  uint public last_completed_migration;

  constructor() public {
      owner = msg.sender;
    }

  modifier restricted() {

      if (msg.sender == owner) _;
    }

  function setCompleted(uint completed) public restricted {

      last_completed_migration = completed;
    }
}// MIT
pragma solidity >=0.6.0 <0.7.0;

interface IOneSplit {

    function getExpectedReturn(
        address fromToken,
        address destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    )
        external
        view
        returns (uint256 returnAmount, uint256[] memory distribution);


    function swap(
        address fromToken,
        address destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256 flags
    ) external payable returns (uint256 returnAmount);

}// MIT
pragma solidity >=0.6.0 <0.7.0;







contract OpenShortDAI is ICallee, DydxFlashloanBase, DssActionsBase {

    struct OSDParams {
        uint256 cdpId; // CDP Id to leverage
        uint256 mintAmountDAI; // Amount of DAI to mint
        uint256 flashloanAmountWETH; // Amount of WETH flashloaned
        address curvePool;
    }

    function callFunction(
        address sender,
        Account.Info memory account,
        bytes memory data
    ) public override {

        OSDParams memory osdp = abi.decode(data, (OSDParams));

        uint256 wethCdp = _openLockGemAndDraw(
            Constants.MCD_JOIN_ETH_A,
            Constants.ETH_A_ILK,
            osdp.flashloanAmountWETH,
            osdp.mintAmountDAI
        );

        require(
            IERC20(Constants.DAI).approve(osdp.curvePool, osdp.mintAmountDAI),
            "!curvepool-approved"
        );
        ICurveFiCurve(osdp.curvePool).exchange_underlying(
            int128(0),
            int128(1),
            osdp.mintAmountDAI,
            0
        );

        uint256 supplyAmount = IERC20(Constants.USDC).balanceOf(address(this));
        _lockGemAndDraw(
            Constants.MCD_JOIN_USDC_A,
            osdp.cdpId,
            supplyAmount,
            osdp.mintAmountDAI
        );

        _wipeAllAndFreeGem(
            Constants.MCD_JOIN_ETH_A,
            wethCdp,
            osdp.flashloanAmountWETH
        );
    }

    function flashloanAndOpen(
        address _sender,
        address _solo,
        address _curvePool,
        uint256 _cdpId,
        uint256 _initialMarginUSDC,
        uint256 _mintAmountDAI,
        uint256 _flashloanAmountWETH
    ) external payable {

        require(msg.value == 2, "!fee");

        require(
            IERC20(Constants.WETH).balanceOf(_solo) >= _flashloanAmountWETH,
            "!weth-supply"
        );

        require(
            IERC20(Constants.USDC).transferFrom(
                msg.sender,
                address(this),
                _initialMarginUSDC
            ),
            "initial-margin-transferFrom-failed"
        );

        ISoloMargin solo = ISoloMargin(_solo);

        uint256 marketId = _getMarketIdFromTokenAddress(_solo, Constants.WETH);

        WETH(Constants.WETH).deposit{value: msg.value}();
        WETH(Constants.WETH).approve(
            _solo,
            _flashloanAmountWETH.add(msg.value)
        );

        Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

        operations[0] = _getWithdrawAction(marketId, _flashloanAmountWETH);
        operations[1] = _getCallAction(
            abi.encode(
                OSDParams({
                    mintAmountDAI: _mintAmountDAI,
                    flashloanAmountWETH: _flashloanAmountWETH,
                    cdpId: _cdpId,
                    curvePool: _curvePool
                })
            )
        );
        operations[2] = _getDepositAction(
            marketId,
            _flashloanAmountWETH.add(msg.value)
        );

        Account.Info[] memory accountInfos = new Account.Info[](1);
        accountInfos[0] = _getAccountInfo();

        solo.operate(accountInfos, operations);

        IERC20(Constants.DAI).transfer(
            _sender,
            IERC20(Constants.DAI).balanceOf(address(this))
        );
        IERC20(Constants.USDC).transfer(
            _sender,
            IERC20(Constants.USDC).balanceOf(address(this))
        );
    }
}// MIT
pragma solidity >=0.6.0 <0.7.0;




contract VaultStats {

    uint256 constant RAY = 10**27;

    using SafeMath for uint256;

    mapping(uint256 => uint256) public daiUsdcRatio6;


    function _getCdpSuppliedAndBorrowed(
        address vat,
        address usr,
        address urn,
        bytes32 ilk
    ) internal view returns (uint256, uint256) {

        (, uint256 rate, , , ) = VatLike(vat).ilks(ilk);
        (uint256 supplied, uint256 art) = VatLike(vat).urns(ilk, urn);
        uint256 dai = VatLike(vat).dai(usr);

        uint256 rad = art.mul(rate).sub(dai);
        uint256 wad = rad / RAY;

        uint256 borrowed = wad.mul(RAY) < rad ? wad + 1 : wad;


        return (supplied, borrowed);
    }

    function getCdpStats(uint256 cdp)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        address vat = IDssCdpManager(Constants.CDP_MANAGER).vat();
        address urn = IDssCdpManager(Constants.CDP_MANAGER).urns(cdp);
        bytes32 ilk = IDssCdpManager(Constants.CDP_MANAGER).ilks(cdp);
        address usr = IDssCdpManager(Constants.CDP_MANAGER).owns(cdp);

        (uint256 supplied, uint256 borrowed) = _getCdpSuppliedAndBorrowed(
            vat,
            usr,
            urn,
            ilk
        );

        uint256 ratio = daiUsdcRatio6[cdp];

        return (supplied, borrowed, ratio);
    }

    function setDaiUsdcRatio6(uint256 _cdp, uint256 _daiUsdcRatio6) public {

        IDssCdpManager manager = IDssCdpManager(Constants.CDP_MANAGER);
        address owner = manager.owns(_cdp);

        require(
            owner == msg.sender || manager.cdpCan(owner, _cdp, msg.sender) == 1,
            "cdp-not-allowed"
        );

        daiUsdcRatio6[_cdp] = _daiUsdcRatio6;
    }
}// MIT
pragma solidity >=0.6.0 <0.7.0;







contract ShortDAIActions {

    using SafeMath for uint256;

    function _openUSDCACdp() internal returns (uint256) {

        return
            IDssCdpManager(Constants.CDP_MANAGER).open(
                bytes32("USDC-A"),
                address(this)
            );
    }

    function flashloanAndOpen(
        address _osd,
        address _solo,
        address _curvePool,
        uint256 _cdpId, // Set 0 for new vault
        uint256 _initialMarginUSDC, // Initial USDC margin
        uint256 _mintAmountDAI, // Amount of DAI to mint
        uint256 _flashloanAmountWETH, // Amount of WETH to flashloan
        address _vaultStats,
        uint256 _daiUsdcRatio6
    ) external payable {

        require(msg.value == 2, "!fee");

        require(
            IERC20(Constants.USDC).transferFrom(
                msg.sender,
                address(this),
                _initialMarginUSDC
            ),
            "initial-margin-transferFrom-failed"
        );

        uint256 cdpId = _cdpId;

        if (cdpId == 0) {
            cdpId = _openUSDCACdp();
        }

        IDssCdpManager(Constants.CDP_MANAGER).cdpAllow(cdpId, _osd, 1);

        require(
            IERC20(Constants.USDC).approve(_osd, _initialMarginUSDC),
            "initial-margin-approve-failed"
        );
        OpenShortDAI(_osd).flashloanAndOpen{value: msg.value}(
            msg.sender,
            _solo,
            _curvePool,
            cdpId,
            _initialMarginUSDC,
            _mintAmountDAI,
            _flashloanAmountWETH
        );

        IDssCdpManager(Constants.CDP_MANAGER).cdpAllow(cdpId, _osd, 0);

        VaultStats(_vaultStats).setDaiUsdcRatio6(cdpId, _daiUsdcRatio6);
    }

    function flashloanAndClose(
        address _csd,
        address _solo,
        address _curvePool,
        uint256 _cdpId,
        uint256 _ethUsdRatio18
    ) external payable {

        require(msg.value == 2, "!fee");

        IDssCdpManager(Constants.CDP_MANAGER).cdpAllow(_cdpId, _csd, 1);

        CloseShortDAI(_csd).flashloanAndClose{value: msg.value}(
            msg.sender,
            _solo,
            _curvePool,
            _cdpId,
            _ethUsdRatio18
        );

        IDssCdpManager(Constants.CDP_MANAGER).cdpAllow(_cdpId, _csd, 0);
        IDssCdpManager(Constants.CDP_MANAGER).give(_cdpId, address(1));
    }

    function cdpAllow(
        uint256 cdp,
        address usr,
        uint256 ok
    ) public {

        IDssCdpManager(Constants.CDP_MANAGER).cdpAllow(cdp, usr, ok);
    }
}// MIT
pragma solidity ^0.6.2;

interface UniswapRouterV2 {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

}

interface UniswapPair {

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestamp
        );

}