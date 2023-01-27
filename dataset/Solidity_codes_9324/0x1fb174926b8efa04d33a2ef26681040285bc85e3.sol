
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
}// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)






interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)







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

}// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)



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

}// Copyright (C) 2020 Maker Ecosystem Growth Holdings, INC.

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

interface IVaultFC is IVault {


    function currencyId() external view returns (uint256);


    function tenor() external view returns (uint256);


    function redeemAndExit(
        uint256 tokenId,
        address user,
        uint256 amount
    ) external returns (uint256 redeemed);


    function redeems(
        uint256 tokenId,
        uint256 amount,
        uint256 cTokenExRate
    ) external view returns (uint256);

}











interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}





abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
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

interface IPublican {

    function vaults(address vault) external view returns (uint256, uint256);


    function codex() external view returns (ICodex);


    function aer() external view returns (IAer);


    function baseInterest() external view returns (uint256);


    function init(address vault) external;


    function setParam(
        address vault,
        bytes32 param,
        uint256 data
    ) external;


    function setParam(bytes32 param, uint256 data) external;


    function setParam(bytes32 param, address data) external;


    function virtualRate(address vault) external returns (uint256 rate);


    function collect(address vault) external returns (uint256 rate);

}
abstract contract VaultActions {

    error VaultActions__exitMoneta_zeroUserAddress();


    ICodex public immutable codex;
    IMoneta public immutable moneta;
    IFIAT public immutable fiat;
    IPublican public immutable publican;

    constructor(
        address codex_,
        address moneta_,
        address fiat_,
        address publican_
    ) {
        codex = ICodex(codex_);
        moneta = IMoneta(moneta_);
        fiat = IFIAT(fiat_);
        publican = IPublican(publican_);
    }

    function approveFIAT(address spender, uint256 amount) external {
        fiat.approve(spender, amount);
    }

    function exitMoneta(address to, uint256 amount) public {
        if (to == address(0)) revert VaultActions__exitMoneta_zeroUserAddress();

        if (codex.delegates(address(this), address(moneta)) != 1) codex.grantDelegate(address(moneta));

        moneta.exit(to, amount);
    }

    function enterMoneta(address from, uint256 amount) public {
        if (from != address(0) && from != address(this)) fiat.transferFrom(from, address(this), amount);

        moneta.enter(address(this), amount);
    }

    function enterVault(
        address vault,
        address token,
        uint256 tokenId,
        address from,
        uint256 amount
    ) public virtual;

    function exitVault(
        address vault,
        address token,
        uint256 tokenId,
        address to,
        uint256 amount
    ) public virtual;

    function modifyCollateralAndDebt(
        address vault,
        address token,
        uint256 tokenId,
        address position,
        address collateralizer,
        address creditor,
        int256 deltaCollateral,
        int256 deltaNormalDebt
    ) public {
        if (deltaNormalDebt != 0) publican.collect(vault);

        if (deltaNormalDebt < 0) {
            (, uint256 rate, , ) = codex.vaults(vault);
            enterMoneta(creditor, uint256(-wmul(rate, deltaNormalDebt)));
        }

        if (deltaCollateral > 0) {
            enterVault(
                vault,
                token,
                tokenId,
                collateralizer,
                wmul(uint256(deltaCollateral), IVault(vault).tokenScale())
            );
        }

        codex.modifyCollateralAndDebt(
            vault,
            tokenId,
            position,
            address(this),
            address(this),
            deltaCollateral,
            deltaNormalDebt
        );

        if (deltaNormalDebt > 0) {
            (, uint256 rate, , ) = codex.vaults(vault);
            exitMoneta(creditor, wmul(uint256(deltaNormalDebt), rate));
        }

        if (deltaCollateral < 0) {
            exitVault(
                vault,
                token,
                tokenId,
                collateralizer,
                wmul(uint256(-deltaCollateral), IVault(vault).tokenScale())
            );
        }
    }
}

contract Vault1155Actions is VaultActions {


    error Vault1155Actions__enterVault_zeroVaultAddress();
    error Vault1155Actions__enterVault_zeroTokenAddress();
    error Vault1155Actions__exitVault_zeroVaultAddress();
    error Vault1155Actions__exitVault_zeroToAddress();
    error Vault1155Actions__exitVault_zeroTokenAddress();

    constructor(
        address codex_,
        address moneta_,
        address fiat_,
        address publican_
    ) VaultActions(codex_, moneta_, fiat_, publican_) {}

    function enterVault(
        address vault,
        address token,
        uint256 tokenId,
        address from,
        uint256 amount
    ) public virtual override {

        if (vault == address(0)) revert Vault1155Actions__enterVault_zeroVaultAddress();
        if (token == address(0)) revert Vault1155Actions__enterVault_zeroTokenAddress();

        if (from != address(0) && from != address(this)) {
            IERC1155(token).safeTransferFrom(from, address(this), tokenId, amount, new bytes(0));
        }

        IERC1155(token).setApprovalForAll(address(vault), true);
        IVault(vault).enter(tokenId, address(this), amount);
    }

    function exitVault(
        address vault,
        address token,
        uint256 tokenId,
        address to,
        uint256 amount
    ) public virtual override {

        if (vault == address(0)) revert Vault1155Actions__exitVault_zeroVaultAddress();
        if (token == address(0)) revert Vault1155Actions__exitVault_zeroTokenAddress();
        if (to == address(0)) revert Vault1155Actions__exitVault_zeroToAddress();

        IVault(vault).exit(tokenId, to, amount);
    }
}
interface INotional {

    enum DepositActionType {
        None,
        DepositAsset,
        DepositUnderlying,
        DepositAssetAndMintNToken,
        DepositUnderlyingAndMintNToken,
        RedeemNToken,
        ConvertCashToNToken
    }

    struct MarketParameters {
        bytes32 storageSlot;
        uint256 maturity;
        int256 totalfCash;
        int256 totalAssetCash;
        int256 totalLiquidity;
        uint256 lastImpliedRate;
        uint256 oracleRate;
        uint256 previousTradeTime;
    }

    enum TokenType {
        UnderlyingToken,
        cToken,
        cETH,
        Ether,
        NonMintable
    }

    struct Token {
        address tokenAddress;
        bool hasTransferFee;
        int256 decimals;
        TokenType tokenType;
        uint256 maxCollateralBalance;
    }

    struct BalanceActionWithTrades {
        DepositActionType actionType;
        uint16 currencyId;
        uint256 depositActionAmount;
        uint256 withdrawAmountInternalPrecision;
        bool withdrawEntireCashBalance;
        bool redeemToUnderlying;
        bytes32[] trades;
    }

    struct AssetRateParameters {
        address rateOracle;
        int256 rate;
        int256 underlyingDecimals;
    }

    function getActiveMarkets(uint16 currencyId) external view returns (MarketParameters[] memory);


    function balanceOf(address account, uint256 id) external view returns (uint256);


    function batchBalanceAndTradeAction(address account, BalanceActionWithTrades[] calldata actions) external payable;


    function getSettlementRate(uint16 currencyId, uint40 maturity) external view returns (AssetRateParameters memory);


    function settleAccount(address account) external;


    function withdraw(
        uint16 currencyId,
        uint88 amountInternalPrecision,
        bool redeemToUnderlying
    ) external returns (uint256);


    function getfCashAmountGivenCashAmount(
        uint16 currencyId,
        int88 netCashToAccount,
        uint256 marketIndex,
        uint256 blockTime
    ) external view returns (int256);


    function getCashAmountGivenfCashAmount(
        uint16 currencyId,
        int88 fCashAmount,
        uint256 marketIndex,
        uint256 blockTime
    ) external view returns (int256, int256);


    function getCurrency(uint16 currencyId)
        external
        view
        returns (Token memory assetToken, Token memory underlyingToken);

}

library Constants {

    int256 internal constant INTERNAL_TOKEN_PRECISION = 1e8;

    uint256 internal constant MAX_TRADED_MARKET_INDEX = 7;

    uint256 internal constant DAY = 86400;
    uint256 internal constant WEEK = DAY * 6;
    uint256 internal constant MONTH = WEEK * 5;
    uint256 internal constant QUARTER = MONTH * 3;
    uint256 internal constant YEAR = QUARTER * 4;

    uint256 internal constant DAYS_IN_WEEK = 6;
    uint256 internal constant DAYS_IN_MONTH = 30;
    uint256 internal constant DAYS_IN_QUARTER = 90;

    uint8 internal constant FCASH_ASSET_TYPE = 1;
    uint8 internal constant MAX_LIQUIDITY_TOKEN_INDEX = 8;

    bytes2 internal constant UNMASK_FLAGS = 0x3FFF;
    uint16 internal constant MAX_CURRENCIES = uint16(UNMASK_FLAGS);
}

library DateTime {

    error DateTime__getReferenceTime_invalidBlockTime();
    error DateTime__getTradedMarket_invalidIndex();
    error DateTime__getMarketIndex_zeroMaxMarketIndex();
    error DateTime__getMarketIndex_invalidMaxMarketIndex();
    error DateTime__getMarketIndex_marketNotFound();

    function getReferenceTime(uint256 blockTime) internal pure returns (uint256) {

        if (blockTime < Constants.QUARTER) revert DateTime__getReferenceTime_invalidBlockTime();
        return blockTime - (blockTime % Constants.QUARTER);
    }

    function getTradedMarket(uint256 index) internal pure returns (uint256) {

        if (index == 1) return Constants.QUARTER;
        if (index == 2) return 2 * Constants.QUARTER;
        if (index == 3) return Constants.YEAR;
        if (index == 4) return 2 * Constants.YEAR;
        if (index == 5) return 5 * Constants.YEAR;
        if (index == 6) return 10 * Constants.YEAR;
        if (index == 7) return 20 * Constants.YEAR;

        revert DateTime__getTradedMarket_invalidIndex();
    }

    function getMarketIndex(
        uint256 maxMarketIndex,
        uint256 maturity,
        uint256 blockTime
    ) internal pure returns (uint256, bool) {

        if (maxMarketIndex == 0) revert DateTime__getMarketIndex_zeroMaxMarketIndex();
        if (maxMarketIndex > Constants.MAX_TRADED_MARKET_INDEX) revert DateTime__getMarketIndex_invalidMaxMarketIndex();

        uint256 tRef = DateTime.getReferenceTime(blockTime);

        for (uint256 i = 1; i <= maxMarketIndex; i++) {
            uint256 marketMaturity = add(tRef, DateTime.getTradedMarket(i));
            if (marketMaturity == maturity) return (i, false);
            if (marketMaturity > maturity) return (i, true);
        }

        revert DateTime__getMarketIndex_marketNotFound();
    }
}

library EncodeDecode {

    error EncodeDecode__encodeERC1155Id_MAX_CURRENCIES();
    error EncodeDecode__encodeERC1155Id_invalidMaturity();
    error EncodeDecode__encodeERC1155Id_MAX_LIQUIDITY_TOKEN_INDEX();

    enum TradeActionType {
        Lend,
        Borrow,
        AddLiquidity,
        RemoveLiquidity,
        PurchaseNTokenResidual,
        SettleCashDebt
    }

    function decodeERC1155Id(uint256 id)
        internal
        pure
        returns (
            uint16 currencyId,
            uint40 maturity,
            uint8 assetType
        )
    {

        assetType = uint8(id);
        maturity = uint40(id >> 8);
        currencyId = uint16(id >> 48);
    }

    function encodeERC1155Id(
        uint256 currencyId,
        uint256 maturity,
        uint256 assetType
    ) internal pure returns (uint256) {

        if (currencyId > Constants.MAX_CURRENCIES) revert EncodeDecode__encodeERC1155Id_MAX_CURRENCIES();
        if (maturity > type(uint40).max) revert EncodeDecode__encodeERC1155Id_invalidMaturity();
        if (assetType > Constants.MAX_LIQUIDITY_TOKEN_INDEX) {
            revert EncodeDecode__encodeERC1155Id_MAX_LIQUIDITY_TOKEN_INDEX();
        }

        return
            uint256(
                (bytes32(uint256(uint16(currencyId))) << 48) |
                    (bytes32(uint256(uint40(maturity))) << 8) |
                    bytes32(uint256(uint8(assetType)))
            );
    }

    function encodeLendTrade(
        uint8 marketIndex,
        uint88 fCashAmount,
        uint32 minImpliedRate
    ) internal pure returns (bytes32) {

        return
            bytes32(
                (uint256(uint8(TradeActionType.Lend)) << 248) |
                    (uint256(marketIndex) << 240) |
                    (uint256(fCashAmount) << 152) |
                    (uint256(minImpliedRate) << 120)
            );
    }

    function encodeBorrowTrade(
        uint8 marketIndex,
        uint88 fCashAmount,
        uint32 maxImpliedRate
    ) internal pure returns (bytes32) {

        return
            bytes32(
                uint256(
                    (uint256(uint8(TradeActionType.Borrow)) << 248) |
                        (uint256(marketIndex) << 240) |
                        (uint256(fCashAmount) << 152) |
                        (uint256(maxImpliedRate) << 120)
                )
            );
    }
}


contract VaultFCActions is Vault1155Actions {

    using SafeERC20 for IERC20;


    error VaultFCActions__buyCollateralAndModifyDebt_zeroMaxUnderlierAmount();
    error VaultFCActions__sellCollateralAndModifyDebt_zeroFCashAmount();
    error VaultFCActions__sellCollateralAndModifyDebt_matured();
    error VaultFCActions__redeemCollateralAndModifyDebt_zeroFCashAmount();
    error VaultFCActions__redeemCollateralAndModifyDebt_notMatured();
    error VaultFCActions__getMarketIndex_invalidMarket();
    error VaultFCActions__getUnderlierToken_invalidUnderlierTokenType();
    error VaultFCActions__getCToken_invalidAssetTokenType();
    error VaultFCActions__sellfCash_amountOverflow();
    error VaultFCActions__redeemfCash_amountOverflow();
    error VaultFCActions__vaultRedeemAndExit_zeroVaultAddress();
    error VaultFCActions__vaultRedeemAndExit_zeroTokenAddress();
    error VaultFCActions__vaultRedeemAndExit_zeroToAddress();
    error VaultFCActions__onERC1155Received_invalidCaller();
    error VaultFCActions__onERC1155Received_invalidValue();


    INotional public immutable notionalV2;
    uint256 public immutable fCashScale;

    constructor(
        address codex,
        address moneta,
        address fiat,
        address publican_,
        address notionalV2_
    ) Vault1155Actions(codex, moneta, fiat, publican_) {
        notionalV2 = INotional(notionalV2_);
        fCashScale = uint256(Constants.INTERNAL_TOKEN_PRECISION);
    }


    function buyCollateralAndModifyDebt(
        address vault,
        address token,
        uint256 tokenId,
        address position,
        address collateralizer,
        address creditor,
        uint256 fCashAmount,
        int256 deltaNormalDebt,
        uint32 minImpliedRate,
        uint256 maxUnderlierAmount
    ) public {

        if (maxUnderlierAmount == 0) revert VaultFCActions__buyCollateralAndModifyDebt_zeroMaxUnderlierAmount();

        _buyFCash(tokenId, collateralizer, maxUnderlierAmount, minImpliedRate, uint88(fCashAmount));
        int256 deltaCollateral = toInt256(wdiv(fCashAmount, fCashScale));

        modifyCollateralAndDebt(
            vault,
            token,
            tokenId,
            position,
            address(this),
            creditor,
            deltaCollateral,
            deltaNormalDebt
        );
    }

    function sellCollateralAndModifyDebt(
        address vault,
        address token,
        uint256 tokenId,
        address position,
        address collateralizer,
        address creditor,
        uint256 fCashAmount,
        int256 deltaNormalDebt,
        uint32 maxImpliedRate
    ) public {

        if (fCashAmount == 0) revert VaultFCActions__sellCollateralAndModifyDebt_zeroFCashAmount();
        if (block.timestamp >= getMaturity(tokenId)) revert VaultFCActions__sellCollateralAndModifyDebt_matured();

        int256 deltaCollateral = -toInt256(wdiv(fCashAmount, fCashScale));

        modifyCollateralAndDebt(
            vault,
            token,
            tokenId,
            position,
            address(this),
            creditor,
            deltaCollateral,
            deltaNormalDebt
        );

        _sellfCash(tokenId, collateralizer, uint88(fCashAmount), maxImpliedRate);
    }

    function redeemCollateralAndModifyDebt(
        address vault,
        address token,
        uint256 tokenId,
        address position,
        address collateralizer,
        address creditor,
        uint256 fCashAmount,
        int256 deltaNormalDebt
    ) public {

        if (fCashAmount == 0) revert VaultFCActions__redeemCollateralAndModifyDebt_zeroFCashAmount();
        if (block.timestamp < getMaturity(tokenId)) revert VaultFCActions__redeemCollateralAndModifyDebt_notMatured();

        int256 deltaCollateral = -toInt256(wdiv(fCashAmount, fCashScale));

        modifyCollateralAndDebt(
            vault,
            token,
            tokenId,
            position,
            collateralizer,
            creditor,
            deltaCollateral,
            deltaNormalDebt
        );
    }

    function _buyFCash(
        uint256 tokenId,
        address from,
        uint256 maxUnderlierAmount,
        uint32 minImpliedRate,
        uint88 fCashAmount
    ) internal {

        (IERC20 underlier, ) = getUnderlierToken(tokenId);

        uint256 balanceBefore = 0;
        if (from != address(0) && from != address(this)) {
            balanceBefore = underlier.balanceOf(address(this));
            underlier.safeTransferFrom(from, address(this), maxUnderlierAmount);
        }

        INotional.BalanceActionWithTrades[] memory action = new INotional.BalanceActionWithTrades[](1);
        action[0].actionType = INotional.DepositActionType.DepositUnderlying;
        action[0].depositActionAmount = maxUnderlierAmount;
        action[0].currencyId = getCurrencyId(tokenId);
        action[0].withdrawEntireCashBalance = true;
        action[0].redeemToUnderlying = true;
        action[0].trades = new bytes32[](1);
        action[0].trades[0] = EncodeDecode.encodeLendTrade(getMarketIndex(tokenId), fCashAmount, minImpliedRate);

        if (underlier.allowance(address(this), address(notionalV2)) < maxUnderlierAmount) {
            underlier.approve(address(notionalV2), maxUnderlierAmount);
        }

        notionalV2.batchBalanceAndTradeAction(address(this), action);

        if (from != address(0) && from != address(this)) {
            uint256 balanceAfter = underlier.balanceOf(address(this));
            uint256 residual = balanceAfter - balanceBefore;
            if (residual > 0) underlier.safeTransfer(from, residual);
        }
    }

    function _sellfCash(
        uint256 tokenId,
        address to,
        uint88 fCashAmount,
        uint32 maxImpliedRate
    ) internal {

        if (fCashAmount > type(uint88).max) revert VaultFCActions__sellfCash_amountOverflow();

        (IERC20 underlier, ) = getUnderlierToken(tokenId);

        INotional.BalanceActionWithTrades[] memory action = new INotional.BalanceActionWithTrades[](1);
        action[0].actionType = INotional.DepositActionType.None;
        action[0].currencyId = getCurrencyId(tokenId);
        action[0].withdrawEntireCashBalance = true;
        action[0].redeemToUnderlying = true;
        action[0].trades = new bytes32[](1);
        action[0].trades[0] = EncodeDecode.encodeBorrowTrade(getMarketIndex(tokenId), fCashAmount, maxImpliedRate);

        uint256 balanceBefore = underlier.balanceOf(address(this));
        notionalV2.batchBalanceAndTradeAction(address(this), action);
        uint256 balanceAfter = underlier.balanceOf(address(this));

        underlier.safeTransfer(to, balanceAfter - balanceBefore);
    }

    function exitVault(
        address vault,
        address token,
        uint256 tokenId,
        address to,
        uint256 amount
    ) public override {

        if (block.timestamp < getMaturity(tokenId)) {
            super.exitVault(vault, token, tokenId, to, amount);
        } else {
            if (vault == address(0)) revert VaultFCActions__vaultRedeemAndExit_zeroVaultAddress();
            if (token == address(0)) revert VaultFCActions__vaultRedeemAndExit_zeroTokenAddress();
            if (to == address(0)) revert VaultFCActions__vaultRedeemAndExit_zeroToAddress();
            IVaultFC(vault).redeemAndExit(tokenId, to, amount);
        }
    }


    function underlierToFCash(uint256 tokenId, uint256 amount) public view returns (uint256) {

        (, uint256 underlierScale) = getUnderlierToken(tokenId);
        return
            uint256(
                _adjustForRounding(
                    notionalV2.getfCashAmountGivenCashAmount(
                        getCurrencyId(tokenId),
                        -int88(toInt256(div(mul(amount, fCashScale), underlierScale))),
                        getMarketIndex(tokenId),
                        block.timestamp
                    )
                )
            );
    }

    function fCashToUnderlier(uint256 tokenId, uint256 amount) external view returns (uint256) {

        (, uint256 underlierScale) = getUnderlierToken(tokenId);
        (, int256 netUnderlyingCash) = notionalV2.getCashAmountGivenfCashAmount(
            getCurrencyId(tokenId),
            -int88(toInt256(amount)),
            getMarketIndex(tokenId),
            block.timestamp
        );
        return div(mul(underlierScale, uint256(_adjustForRounding(netUnderlyingCash))), uint256(fCashScale));
    }

    function getCurrencyId(uint256 tokenId) public pure returns (uint16 currencyId) {

        (currencyId, , ) = EncodeDecode.decodeERC1155Id(tokenId);
    }

    function getMarketIndex(uint256 tokenId) public view returns (uint8) {

        (uint256 marketIndex, bool isInvalidMarket) = DateTime.getMarketIndex(
            Constants.MAX_TRADED_MARKET_INDEX,
            getMaturity(tokenId),
            block.timestamp
        );
        if (isInvalidMarket) revert VaultFCActions__getMarketIndex_invalidMarket();

        return uint8(marketIndex);
    }

    function getMaturity(uint256 tokenId) public pure returns (uint40 maturity) {

        (, maturity, ) = EncodeDecode.decodeERC1155Id(tokenId);
    }

    function getUnderlierToken(uint256 tokenId) public view returns (IERC20 underlierToken, uint256 underlierScale) {

        (, INotional.Token memory underlier) = notionalV2.getCurrency(getCurrencyId(tokenId));
        if (underlier.tokenType != INotional.TokenType.UnderlyingToken) {
            revert VaultFCActions__getUnderlierToken_invalidUnderlierTokenType();
        }
        return (IERC20(underlier.tokenAddress), uint256(underlier.decimals));
    }

    function getCToken(uint256 tokenId) public view returns (IERC20 cToken, uint256 cTokenScale) {

        (INotional.Token memory asset, ) = notionalV2.getCurrency(getCurrencyId(tokenId));
        if (asset.tokenType != INotional.TokenType.cToken) {
            revert VaultFCActions__getCToken_invalidAssetTokenType();
        }
        return (IERC20(asset.tokenAddress), uint256(asset.decimals));
    }

    function _adjustForRounding(int256 x) private pure returns (int256) {

        int256 y = (x < 1e7) ? int256(1) : (x / 1e7);
        return x - y;
    }


    function setApprovalForAll(
        address token,
        address spender,
        bool approved
    ) external {

        IERC1155(token).setApprovalForAll(spender, approved);
    }
}