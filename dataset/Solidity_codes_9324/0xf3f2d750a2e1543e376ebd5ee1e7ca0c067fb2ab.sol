
pragma solidity ^0.8.4;




interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}







library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface ICodex {

    function init(address vault) external;


    function setParam(bytes32 param, uint256 data) external;


    function setParam(
        address,
        bytes32,
        uint256
    ) external;


    function credit(address) external view returns (uint256);


    function unbackedDebt(address) external view returns (uint256);


    function balances(
        address,
        uint256,
        address
    ) external view returns (uint256);


    function vaults(address vault)
        external
        view
        returns (
            uint256 totalNormalDebt,
            uint256 rate,
            uint256 debtCeiling,
            uint256 debtFloor
        );


    function positions(
        address vault,
        uint256 tokenId,
        address position
    ) external view returns (uint256 collateral, uint256 normalDebt);


    function globalDebt() external view returns (uint256);


    function globalUnbackedDebt() external view returns (uint256);


    function globalDebtCeiling() external view returns (uint256);


    function delegates(address, address) external view returns (uint256);


    function grantDelegate(address) external;


    function revokeDelegate(address) external;


    function modifyBalance(
        address,
        uint256,
        address,
        int256
    ) external;


    function transferBalance(
        address vault,
        uint256 tokenId,
        address src,
        address dst,
        uint256 amount
    ) external;


    function transferCredit(
        address src,
        address dst,
        uint256 amount
    ) external;


    function modifyCollateralAndDebt(
        address vault,
        uint256 tokenId,
        address user,
        address collateralizer,
        address debtor,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    ) external;


    function transferCollateralAndDebt(
        address vault,
        uint256 tokenId,
        address src,
        address dst,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    ) external;


    function confiscateCollateralAndDebt(
        address vault,
        uint256 tokenId,
        address user,
        address collateralizer,
        address debtor,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    ) external;


    function settleUnbackedDebt(uint256 debt) external;


    function createUnbackedDebt(
        address debtor,
        address creditor,
        uint256 debt
    ) external;


    function modifyRate(
        address vault,
        address creditor,
        int256 rate
    ) external;


    function lock() external;

}



interface IERC20Permit {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}





interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

interface IFIATExcl {

    function mint(address to, uint256 amount) external;


    function burn(address from, uint256 amount) external;

}

interface IFIAT is IFIATExcl, IERC20, IERC20Permit, IERC20Metadata {}

interface IMoneta {

    function codex() external view returns (ICodex);


    function fiat() external view returns (IFIAT);


    function live() external view returns (uint256);


    function lock() external;


    function enter(address user, uint256 amount) external;


    function exit(address user, uint256 amount) external;

}
interface IPriceCalculator {

    function price(uint256, uint256) external view returns (uint256);

}

interface IPriceFeed {

    function peek() external returns (bytes32, bool);


    function read() external view returns (bytes32);

}

interface ICollybus {

    function vaults(address) external view returns (uint128, uint128);


    function spots(address) external view returns (uint256);


    function rates(uint256) external view returns (uint256);


    function rateIds(address, uint256) external view returns (uint256);


    function redemptionPrice() external view returns (uint256);


    function live() external view returns (uint256);


    function setParam(bytes32 param, uint256 data) external;


    function setParam(
        address vault,
        bytes32 param,
        uint128 data
    ) external;


    function setParam(
        address vault,
        uint256 tokenId,
        bytes32 param,
        uint256 data
    ) external;


    function updateDiscountRate(uint256 rateId, uint256 rate) external;


    function updateSpot(address token, uint256 spot) external;


    function read(
        address vault,
        address underlier,
        uint256 tokenId,
        uint256 maturity,
        bool net
    ) external view returns (uint256 price);


    function lock() external;

}
interface IDebtAuction {

    function auctions(uint256)
        external
        view
        returns (
            uint256,
            uint256,
            address,
            uint48,
            uint48
        );


    function codex() external view returns (ICodex);


    function token() external view returns (IERC20);


    function minBidBump() external view returns (uint256);


    function tokenToSellBump() external view returns (uint256);


    function bidDuration() external view returns (uint48);


    function auctionDuration() external view returns (uint48);


    function auctionCounter() external view returns (uint256);


    function live() external view returns (uint256);


    function aer() external view returns (address);


    function setParam(bytes32 param, uint256 data) external;


    function startAuction(
        address recipient,
        uint256 tokensToSell,
        uint256 bid
    ) external returns (uint256 id);


    function redoAuction(uint256 id) external;


    function submitBid(
        uint256 id,
        uint256 tokensToSell,
        uint256 bid
    ) external;


    function closeAuction(uint256 id) external;


    function lock() external;


    function cancelAuction(uint256 id) external;

}
interface ISurplusAuction {

    function auctions(uint256)
        external
        view
        returns (
            uint256,
            uint256,
            address,
            uint48,
            uint48
        );


    function codex() external view returns (ICodex);


    function token() external view returns (IERC20);


    function minBidBump() external view returns (uint256);


    function bidDuration() external view returns (uint48);


    function auctionDuration() external view returns (uint48);


    function auctionCounter() external view returns (uint256);


    function live() external view returns (uint256);


    function setParam(bytes32 param, uint256 data) external;


    function startAuction(uint256 creditToSell, uint256 bid) external returns (uint256 id);


    function redoAuction(uint256 id) external;


    function submitBid(
        uint256 id,
        uint256 creditToSell,
        uint256 bid
    ) external;


    function closeAuction(uint256 id) external;


    function lock(uint256 credit) external;


    function cancelAuction(uint256 id) external;

}

interface IAer {

    function codex() external view returns (ICodex);


    function surplusAuction() external view returns (ISurplusAuction);


    function debtAuction() external view returns (IDebtAuction);


    function debtQueue(uint256) external view returns (uint256);


    function queuedDebt() external view returns (uint256);


    function debtOnAuction() external view returns (uint256);


    function auctionDelay() external view returns (uint256);


    function debtAuctionSellSize() external view returns (uint256);


    function debtAuctionBidSize() external view returns (uint256);


    function surplusAuctionSellSize() external view returns (uint256);


    function surplusBuffer() external view returns (uint256);


    function live() external view returns (uint256);


    function setParam(bytes32 param, uint256 data) external;


    function setParam(bytes32 param, address data) external;


    function queueDebt(uint256 debt) external;


    function unqueueDebt(uint256 queuedAt) external;


    function settleDebtWithSurplus(uint256 debt) external;


    function settleAuctionedDebt(uint256 debt) external;


    function startDebtAuction() external returns (uint256 auctionId);


    function startSurplusAuction() external returns (uint256 auctionId);


    function transferCredit(address to, uint256 credit) external;


    function lock() external;

}
interface ILimes {

    function codex() external view returns (ICodex);


    function aer() external view returns (IAer);


    function vaults(address)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256
        );


    function live() external view returns (uint256);


    function globalMaxDebtOnAuction() external view returns (uint256);


    function globalDebtOnAuction() external view returns (uint256);


    function setParam(bytes32 param, address data) external;


    function setParam(bytes32 param, uint256 data) external;


    function setParam(
        address vault,
        bytes32 param,
        uint256 data
    ) external;


    function setParam(
        address vault,
        bytes32 param,
        address collateralAuction
    ) external;


    function liquidationPenalty(address vault) external view returns (uint256);


    function liquidate(
        address vault,
        uint256 tokenId,
        address position,
        address keeper
    ) external returns (uint256 auctionId);


    function liquidated(
        address vault,
        uint256 tokenId,
        uint256 debt
    ) external;


    function lock() external;

}

interface INoLossCollateralAuction {

    function vaults(address)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            ICollybus,
            IPriceCalculator
        );


    function codex() external view returns (ICodex);


    function limes() external view returns (ILimes);


    function aer() external view returns (IAer);


    function feeTip() external view returns (uint64);


    function flatTip() external view returns (uint192);


    function auctionCounter() external view returns (uint256);


    function activeAuctions(uint256) external view returns (uint256);


    function auctions(uint256)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            address,
            uint96,
            uint256
        );


    function stopped() external view returns (uint256);


    function init(address vault, address collybus) external;


    function setParam(bytes32 param, uint256 data) external;


    function setParam(bytes32 param, address data) external;


    function setParam(
        address vault,
        bytes32 param,
        uint256 data
    ) external;


    function setParam(
        address vault,
        bytes32 param,
        address data
    ) external;


    function startAuction(
        uint256 debt,
        uint256 collateralToSell,
        address vault,
        uint256 tokenId,
        address user,
        address keeper
    ) external returns (uint256 auctionId);


    function redoAuction(uint256 auctionId, address keeper) external;


    function takeCollateral(
        uint256 auctionId,
        uint256 collateralAmount,
        uint256 maxPrice,
        address recipient,
        bytes calldata data
    ) external;


    function count() external view returns (uint256);


    function list() external view returns (uint256[] memory);


    function getStatus(uint256 auctionId)
        external
        view
        returns (
            bool needsRedo,
            uint256 price,
            uint256 collateralToSell,
            uint256 debt
        );


    function updateAuctionDebtFloor(address vault) external;


    function cancelAuction(uint256 auctionId) external;

}
interface IVault {

    function codex() external view returns (ICodex);


    function collybus() external view returns (ICollybus);


    function token() external view returns (address);


    function tokenScale() external view returns (uint256);


    function underlierToken() external view returns (address);


    function underlierScale() external view returns (uint256);


    function vaultType() external view returns (bytes32);


    function live() external view returns (uint256);


    function lock() external;


    function setParam(bytes32 param, address data) external;


    function maturity(uint256 tokenId) external returns (uint256);


    function fairPrice(
        uint256 tokenId,
        bool net,
        bool face
    ) external view returns (uint256);


    function enter(
        uint256 tokenId,
        address user,
        uint256 amount
    ) external;


    function exit(
        uint256 tokenId,
        address user,
        uint256 amount
    ) external;

}

uint256 constant MLN = 10**6;
uint256 constant BLN = 10**9;
uint256 constant WAD = 10**18;
uint256 constant RAY = 10**18;
uint256 constant RAD = 10**18;


error Math__toInt256_overflow(uint256 x);

function toInt256(uint256 x) pure returns (int256) {
    if (x > uint256(type(int256).max)) revert Math__toInt256_overflow(x);
    return int256(x);
}

function min(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        z = x <= y ? x : y;
    }
}

function max(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        z = x >= y ? x : y;
    }
}

error Math__diff_overflow(uint256 x, uint256 y);

function diff(uint256 x, uint256 y) pure returns (int256 z) {
    unchecked {
        z = int256(x) - int256(y);
        if (!(int256(x) >= 0 && int256(y) >= 0)) revert Math__diff_overflow(x, y);
    }
}

error Math__add_overflow(uint256 x, uint256 y);

function add(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        if ((z = x + y) < x) revert Math__add_overflow(x, y);
    }
}

error Math__add48_overflow(uint256 x, uint256 y);

function add48(uint48 x, uint48 y) pure returns (uint48 z) {
    unchecked {
        if ((z = x + y) < x) revert Math__add48_overflow(x, y);
    }
}

error Math__add_overflow_signed(uint256 x, int256 y);

function add(uint256 x, int256 y) pure returns (uint256 z) {
    unchecked {
        z = x + uint256(y);
        if (!(y >= 0 || z <= x)) revert Math__add_overflow_signed(x, y);
        if (!(y <= 0 || z >= x)) revert Math__add_overflow_signed(x, y);
    }
}

error Math__sub_overflow(uint256 x, uint256 y);

function sub(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        if ((z = x - y) > x) revert Math__sub_overflow(x, y);
    }
}

error Math__sub_overflow_signed(uint256 x, int256 y);

function sub(uint256 x, int256 y) pure returns (uint256 z) {
    unchecked {
        z = x - uint256(y);
        if (!(y <= 0 || z <= x)) revert Math__sub_overflow_signed(x, y);
        if (!(y >= 0 || z >= x)) revert Math__sub_overflow_signed(x, y);
    }
}

error Math__mul_overflow(uint256 x, uint256 y);

function mul(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        if (!(y == 0 || (z = x * y) / y == x)) revert Math__mul_overflow(x, y);
    }
}

error Math__mul_overflow_signed(uint256 x, int256 y);

function mul(uint256 x, int256 y) pure returns (int256 z) {
    unchecked {
        z = int256(x) * y;
        if (int256(x) < 0) revert Math__mul_overflow_signed(x, y);
        if (!(y == 0 || z / y == int256(x))) revert Math__mul_overflow_signed(x, y);
    }
}

function wmul(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        z = mul(x, y) / WAD;
    }
}

function wmul(uint256 x, int256 y) pure returns (int256 z) {
    unchecked {
        z = mul(x, y) / int256(WAD);
    }
}

error Math__div_overflow(uint256 x, uint256 y);

function div(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        if (y == 0) revert Math__div_overflow(x, y);
        return x / y;
    }
}

function wdiv(uint256 x, uint256 y) pure returns (uint256 z) {
    unchecked {
        z = mul(x, WAD) / y;
    }
}

function wpow(
    uint256 x,
    uint256 n,
    uint256 b
) pure returns (uint256 z) {
    unchecked {
        assembly {
            switch n
            case 0 {
                z := b
            }
            default {
                switch x
                case 0 {
                    z := 0
                }
                default {
                    switch mod(n, 2)
                    case 0 {
                        z := b
                    }
                    default {
                        z := x
                    }
                    let half := div(b, 2) // for rounding.
                    for {
                        n := div(n, 2)
                    } n {
                        n := div(n, 2)
                    } {
                        let xx := mul(x, x)
                        if shr(128, x) {
                            revert(0, 0)
                        }
                        let xxRound := add(xx, half)
                        if lt(xxRound, xx) {
                            revert(0, 0)
                        }
                        x := div(xxRound, b)
                        if mod(n, 2) {
                            let zx := mul(z, x)
                            if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) {
                                revert(0, 0)
                            }
                            let zxRound := add(zx, half)
                            if lt(zxRound, zx) {
                                revert(0, 0)
                            }
                            z := div(zxRound, b)
                        }
                    }
                }
            }
        }
    }
}



contract NoLossCollateralAuctionActions {

    using SafeERC20 for IERC20;


    error NoLossCollateralAuctionActions__collateralAuctionCall_msgSenderNotNoLossCollateralAuction();
    error NoLossCollateralAuctionActions__collateralAuctionCall_senderNotProxy();


    ICodex public immutable codex;
    IMoneta public immutable moneta;
    IFIAT public immutable fiat;
    INoLossCollateralAuction public immutable noLossCollateralAuction;

    constructor(
        address codex_,
        address moneta_,
        address fiat_,
        address noLossCollateralAuction_
    ) {
        codex = ICodex(codex_);
        moneta = IMoneta(moneta_);
        fiat = IFIAT(fiat_);
        noLossCollateralAuction = INoLossCollateralAuction(noLossCollateralAuction_);
    }

    function approveFIAT(address spender, uint256 amount) external {

        fiat.approve(spender, amount);
    }

    function takeCollateral(
        address vault,
        uint256 tokenId,
        address from,
        uint256 auctionId,
        uint256 maxCollateralToBuy,
        uint256 maxPrice,
        address recipient
    ) external {

        uint256 maxCredit = wmul(maxCollateralToBuy, maxPrice);

        if (from != address(0) && from != address(this)) fiat.transferFrom(from, address(this), maxCredit);

        moneta.enter(address(this), maxCredit);

        if (codex.delegates(address(this), address(noLossCollateralAuction)) != 1)
            codex.grantDelegate(address(noLossCollateralAuction));

        uint256 credit = codex.credit(address(this));
        uint256 balance = codex.balances(vault, tokenId, address(this));
        noLossCollateralAuction.takeCollateral(auctionId, maxCollateralToBuy, maxPrice, address(this), new bytes(0));

        if (codex.delegates(address(this), address(moneta)) != 1) codex.grantDelegate(address(moneta));

        moneta.exit(from, sub(maxCredit, sub(credit, codex.credit(address(this)))));

        uint256 bought = wmul(sub(codex.balances(vault, tokenId, address(this)), balance), IVault(vault).tokenScale());
        IVault(vault).exit(tokenId, recipient, bought);
    }
}