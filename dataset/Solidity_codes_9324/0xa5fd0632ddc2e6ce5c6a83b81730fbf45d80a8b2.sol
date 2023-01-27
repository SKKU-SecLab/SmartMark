
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

}interface IPriceFeed {
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

}// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)











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

contract Vault20Actions is VaultActions {

    using SafeERC20 for IERC20;


    error VaultActions__enterVault_zeroVaultAddress();
    error VaultActions__enterVault_zeroTokenAddress();
    error VaultActions__exitVault_zeroVaultAddress();
    error VaultActions__exitVault_zeroTokenAddress();
    error VaultActions__exitVault_zeroToAddress();

    constructor(
        address codex_,
        address moneta_,
        address fiat_,
        address publican_
    ) VaultActions(codex_, moneta_, fiat_, publican_) {}

    function enterVault(
        address vault,
        address token,
        uint256, /* tokenId */
        address from,
        uint256 amount
    ) public virtual override {

        if (vault == address(0)) revert VaultActions__enterVault_zeroVaultAddress();
        if (token == address(0)) revert VaultActions__enterVault_zeroTokenAddress();

        if (from != address(0) && from != address(this)) {
            IERC20(token).safeTransferFrom(from, address(this), amount);
        }

        IERC20(token).approve(vault, amount);
        IVault(vault).enter(0, address(this), amount);
    }

    function exitVault(
        address vault,
        address token,
        uint256, /* tokenId */
        address to,
        uint256 amount
    ) public virtual override {

        if (vault == address(0)) revert VaultActions__exitVault_zeroVaultAddress();
        if (token == address(0)) revert VaultActions__exitVault_zeroTokenAddress();
        if (to == address(0)) revert VaultActions__exitVault_zeroToAddress();

        IVault(vault).exit(0, to, amount);
    }
}
interface IBalancerVault {

    enum SwapKind {
        GIVEN_IN,
        GIVEN_OUT
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        address assetIn;
        address assetOut;
        uint256 amount;
        bytes userData;
    }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external payable returns (uint256);


    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            address[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        );


    enum PoolSpecialization {
        GENERAL,
        MINIMAL_SWAP_INFO,
        TWO_TOKEN
    }

    function getPool(bytes32 poolId) external view returns (address, PoolSpecialization);

}

interface IConvergentCurvePool {

    function solveTradeInvariant(
        uint256 amountX,
        uint256 reserveX,
        uint256 reserveY,
        bool out
    ) external view returns (uint256);


    function percentFee() external view returns (uint256);


    function totalSupply() external view returns (uint256);

}

interface ITranche {

    function withdrawPrincipal(uint256 _amount, address _destination) external returns (uint256);

}


contract VaultEPTActions is Vault20Actions {

    using SafeERC20 for IERC20;


    error VaultEPTActions__buyCollateralAndModifyDebt_zeroUnderlierAmount();
    error VaultEPTActions__sellCollateralAndModifyDebt_zeroPTokenAmount();
    error VaultEPTActions__redeemCollateralAndModifyDebt_zeroPTokenAmount();
    error VaultEPTActions__solveTradeInvariant_tokenMismatch();


    struct SwapParams {
        address balancerVault;
        bytes32 poolId;
        address assetIn;
        address assetOut;
        uint256 minOutput; // The
        uint256 deadline;
        uint256 approve;
    }

    constructor(
        address codex_,
        address moneta_,
        address fiat_,
        address publican_
    ) Vault20Actions(codex_, moneta_, fiat_, publican_) {}


    function buyCollateralAndModifyDebt(
        address vault,
        address position,
        address collateralizer,
        address creditor,
        uint256 underlierAmount,
        int256 deltaNormalDebt,
        SwapParams calldata swapParams
    ) public {

        if (underlierAmount == 0) revert VaultEPTActions__buyCollateralAndModifyDebt_zeroUnderlierAmount();

        uint256 pTokenAmount = _buyPToken(underlierAmount, collateralizer, swapParams);
        int256 deltaCollateral = toInt256(wdiv(pTokenAmount, IVault(vault).tokenScale()));

        modifyCollateralAndDebt(
            vault,
            swapParams.assetOut,
            0,
            position,
            address(this),
            creditor,
            deltaCollateral,
            deltaNormalDebt
        );
    }

    function sellCollateralAndModifyDebt(
        address vault,
        address position,
        address collateralizer,
        address creditor,
        uint256 pTokenAmount,
        int256 deltaNormalDebt,
        SwapParams calldata swapParams
    ) public {

        if (pTokenAmount == 0) revert VaultEPTActions__sellCollateralAndModifyDebt_zeroPTokenAmount();

        int256 deltaCollateral = -toInt256(wdiv(pTokenAmount, IVault(vault).tokenScale()));

        modifyCollateralAndDebt(
            vault,
            swapParams.assetIn,
            0,
            position,
            address(this),
            creditor,
            deltaCollateral,
            deltaNormalDebt
        );

        _sellPToken(pTokenAmount, collateralizer, swapParams);
    }

    function redeemCollateralAndModifyDebt(
        address vault,
        address token,
        address position,
        address collateralizer,
        address creditor,
        uint256 pTokenAmount,
        int256 deltaNormalDebt
    ) public {

        if (pTokenAmount == 0) revert VaultEPTActions__redeemCollateralAndModifyDebt_zeroPTokenAmount();

        int256 deltaCollateral = -toInt256(wdiv(pTokenAmount, IVault(vault).tokenScale()));

        modifyCollateralAndDebt(vault, token, 0, position, address(this), creditor, deltaCollateral, deltaNormalDebt);

        ITranche(token).withdrawPrincipal(pTokenAmount, collateralizer);
    }

    function _buyPToken(
        uint256 underlierAmount,
        address from,
        SwapParams calldata swapParams
    ) internal returns (uint256) {

        if (from != address(0) && from != address(this)) {
            IERC20(swapParams.assetIn).safeTransferFrom(from, address(this), underlierAmount);
        }

        IBalancerVault.SingleSwap memory singleSwap = IBalancerVault.SingleSwap(
            swapParams.poolId,
            IBalancerVault.SwapKind.GIVEN_IN,
            swapParams.assetIn,
            swapParams.assetOut,
            underlierAmount, // note precision
            new bytes(0)
        );
        IBalancerVault.FundManagement memory funds = IBalancerVault.FundManagement(
            address(this),
            false,
            payable(address(this)),
            false
        );

        if (swapParams.approve != 0) {
            IERC20(swapParams.assetIn).approve(swapParams.balancerVault, swapParams.approve);
        }

        return
            IBalancerVault(swapParams.balancerVault).swap(singleSwap, funds, swapParams.minOutput, swapParams.deadline);
    }

    function _sellPToken(
        uint256 pTokenAmount,
        address to,
        SwapParams calldata swapParams
    ) internal returns (uint256) {

        IERC20(swapParams.assetIn).approve(swapParams.balancerVault, pTokenAmount);

        IBalancerVault.SingleSwap memory singleSwap = IBalancerVault.SingleSwap(
            swapParams.poolId,
            IBalancerVault.SwapKind.GIVEN_IN,
            swapParams.assetIn,
            swapParams.assetOut,
            pTokenAmount,
            new bytes(0)
        );
        IBalancerVault.FundManagement memory funds = IBalancerVault.FundManagement(
            address(this),
            false,
            payable(to),
            false
        );

        if (swapParams.approve != 0) {
            IERC20(swapParams.assetIn).approve(swapParams.balancerVault, swapParams.approve);
        }

        return
            IBalancerVault(swapParams.balancerVault).swap(singleSwap, funds, swapParams.minOutput, swapParams.deadline);
    }


    function underlierToPToken(
        address vault,
        address balancerVault,
        bytes32 curvePoolId,
        uint256 underlierAmount
    ) external view returns (uint256) {

        return _solveTradeInvariant(underlierAmount, vault, balancerVault, curvePoolId, true);
    }

    function pTokenToUnderlier(
        address vault,
        address balancerVault,
        bytes32 curvePoolId,
        uint256 pTokenAmount
    ) external view returns (uint256) {

        return _solveTradeInvariant(pTokenAmount, vault, balancerVault, curvePoolId, false);
    }

    function _solveTradeInvariant(
        uint256 amountIn_,
        address vault,
        address balancerVault,
        bytes32 poolId,
        bool fromUnderlier
    ) internal view returns (uint256) {

        uint256 tokenScale = IVault(vault).tokenScale();
        uint256 underlierScale = IVault(vault).underlierScale();

        uint256 amountIn = (fromUnderlier) ? wdiv(amountIn_, underlierScale) : wdiv(amountIn_, tokenScale);

        uint256 currentBalanceTokenIn;
        uint256 currentBalanceTokenOut;
        {
            (address[] memory tokens, uint256[] memory balances, ) = IBalancerVault(balancerVault).getPoolTokens(
                poolId
            );
            address token = IVault(vault).token();
            address underlier = IVault(vault).underlierToken();

            if (tokens[0] == underlier && tokens[1] == token) {
                currentBalanceTokenIn = (fromUnderlier)
                    ? wdiv(balances[0], underlierScale)
                    : wdiv(balances[1], tokenScale);
                currentBalanceTokenOut = (fromUnderlier)
                    ? wdiv(balances[1], tokenScale)
                    : wdiv(balances[0], underlierScale);
            } else if (tokens[0] == token && tokens[1] == underlier) {
                currentBalanceTokenIn = (fromUnderlier)
                    ? wdiv(balances[1], underlierScale)
                    : wdiv(balances[0], tokenScale);
                currentBalanceTokenOut = (fromUnderlier)
                    ? wdiv(balances[0], tokenScale)
                    : wdiv(balances[1], underlierScale);
            } else {
                revert VaultEPTActions__solveTradeInvariant_tokenMismatch();
            }
        }

        (address pool, ) = IBalancerVault(balancerVault).getPool(poolId);
        IConvergentCurvePool ccp = IConvergentCurvePool(pool);

        if (fromUnderlier) {
            unchecked {
                currentBalanceTokenOut += ccp.totalSupply();
            }
        } else {
            unchecked {
                currentBalanceTokenIn += ccp.totalSupply();
            }
        }

        uint256 amountOut = ccp.solveTradeInvariant(amountIn, currentBalanceTokenIn, currentBalanceTokenOut, true);
        uint256 impliedYieldFee = wmul(
            ccp.percentFee(),
            fromUnderlier
                ? sub(amountOut, amountIn) // If the output is token the implied yield is out - in
                : sub(amountIn, amountOut) // If the output is underlier the implied yield is in - out
        );

        return wmul(sub(amountOut, impliedYieldFee), (fromUnderlier) ? tokenScale : underlierScale);
    }
}