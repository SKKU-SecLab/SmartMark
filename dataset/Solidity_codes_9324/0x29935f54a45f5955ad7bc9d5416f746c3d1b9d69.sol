
pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSetUpgradeable {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT

pragma solidity 0.7.6;

library EthAddressLib {


    function ethAddress() internal pure returns(address) {

        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }
}// MIT

pragma solidity 0.7.6;

interface ERC20Interface {

    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}

library ERC20TransferHelper {

    function doTransferIn(
        address underlying,
        address from,
        uint256 amount
    ) internal returns (uint256) {

        if (underlying == EthAddressLib.ethAddress()) {
            require(tx.origin == from || msg.sender == from, "sender mismatch");
            require(msg.value == amount, "value mismatch");

            return amount;
        } else {
            require(msg.value == 0, "don't support msg.value");
            uint256 balanceBefore = ERC20Interface(underlying).balanceOf(
                address(this)
            );
            (bool success, bytes memory data) = underlying.call(
                abi.encodeWithSelector(
                    ERC20Interface.transferFrom.selector,
                    from,
                    address(this),
                    amount
                )
            );
            require(
                success && (data.length == 0 || abi.decode(data, (bool))),
                "STF"
            );

            uint256 balanceAfter = ERC20Interface(underlying).balanceOf(
                address(this)
            );
            require(
                balanceAfter >= balanceBefore,
                "TOKEN_TRANSFER_IN_OVERFLOW"
            );
            return balanceAfter - balanceBefore; // underflow already checked above, just subtract
        }
    }

    function doTransferOut(
        address underlying,
        address payable to,
        uint256 amount
    ) internal {

        if (underlying == EthAddressLib.ethAddress()) {
            (bool success, ) = to.call{value: amount}(new bytes(0));
            require(success, "STE");
        } else {
            (bool success, bytes memory data) = underlying.call(
                abi.encodeWithSelector(
                    ERC20Interface.transfer.selector,
                    to,
                    amount
                )
            );
            require(
                success && (data.length == 0 || abi.decode(data, (bool))),
                "ST"
            );
        }
    }

    function getCashPrior(address underlying_) internal view returns (uint256) {

        if (underlying_ == EthAddressLib.ethAddress()) {
            uint256 startingBalance = sub(address(this).balance, msg.value);
            return startingBalance;
        } else {
            ERC20Interface token = ERC20Interface(underlying_);
            return token.balanceOf(address(this));
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
}// MIT

pragma solidity 0.7.6;

interface ERC721Interface {

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

}

interface VNFTInterface {

    function transferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 units
    ) external returns (uint256 newTokenId);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 units,
        bytes calldata data
    ) external returns (uint256 newTokenId);


    function transferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 targetTokenId,
        uint256 units
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 targetTokenId,
        uint256 units,
        bytes calldata data
    ) external;

}

library VNFTTransferHelper {

    function doTransferIn(
        address underlying,
        address from,
        uint256 tokenId
    ) internal {

        ERC721Interface token = ERC721Interface(underlying);
        token.transferFrom(from, address(this), tokenId);
    }

    function doTransferOut(
        address underlying,
        address to,
        uint256 tokenId
    ) internal {

        ERC721Interface token = ERC721Interface(underlying);
        token.transferFrom(address(this), to, tokenId);
    }

    function doTransferIn(
        address underlying,
        address from,
        uint256 tokenId,
        uint256 units
    ) internal {

        VNFTInterface token = VNFTInterface(underlying);
        token.safeTransferFrom(from, address(this), tokenId, units, "");
    }

    function doTransferOut(
        address underlying,
        address to,
        uint256 tokenId,
        uint256 units
    ) internal returns (uint256 newTokenId) {

        VNFTInterface token = VNFTInterface(underlying);
        newTokenId = token.safeTransferFrom(
            address(this),
            to,
            tokenId,
            units,
            ""
        );
    }

    function doTransferOut(
        address underlying,
        address to,
        uint256 tokenId,
        uint256 targetTokenId,
        uint256 units
    ) internal {

        VNFTInterface token = VNFTInterface(underlying);
        token.safeTransferFrom(
            address(this),
            to,
            tokenId,
            targetTokenId,
            units,
            ""
        );
    }
}// MIT

pragma solidity 0.7.6;

contract PriceManager {

    enum PriceType {
        FIXED,
        DECLIINING_BY_TIME
    }

    struct DecliningPrice {
        uint128 highest; //起始价格
        uint128 lowest; //最终价格
        uint32 startTime;
        uint32 duration; //持续时间
        uint32 interval; //降价周期
    }

    mapping(uint24 => DecliningPrice) internal decliningPrices;
    mapping(uint24 => uint128) internal fixedPrices;

    function getDecliningPrice(uint24 saleId_)
        external
        view
        returns (
            uint128 highest,
            uint128 lowest,
            uint32 startTime,
            uint32 duration,
            uint32 interval
        )
    {

        DecliningPrice storage decliningPrice = decliningPrices[saleId_];
        return (
            decliningPrice.highest,
            decliningPrice.lowest,
            decliningPrice.startTime,
            decliningPrice.duration,
            decliningPrice.interval
        );
    }

    function getFixedPrice(uint24 saleId_) external view returns (uint128) {

        return fixedPrices[saleId_];
    }

    function price(PriceType priceType_, uint24 saleId_)
        internal
        view
        returns (uint128)
    {

        if (priceType_ == PriceType.FIXED) {
            return fixedPrices[saleId_];
        }

        if (priceType_ == PriceType.DECLIINING_BY_TIME) {
            DecliningPrice storage price_ = decliningPrices[saleId_];
            if (block.timestamp >= price_.startTime + price_.duration) {
                return price_.lowest;
            }
            if (block.timestamp <= price_.startTime) {
                return price_.highest;
            }

            uint256 lastPrice = price_.highest -
                ((block.timestamp - price_.startTime) / price_.interval) *
                ((price_.interval * (price_.highest - price_.lowest)) /
                    price_.duration);
            uint256 price256 = lastPrice < price_.lowest
                ? price_.lowest
                : lastPrice;
            require(price256 <= uint128(-1), "price: exceeds uint128 max");

            return uint128(price256);
        }

        revert("unsupported priceType");
    }

    function setFixedPrice(uint24 saleId_, uint128 price_) internal {

        fixedPrices[saleId_] = price_;
    }

    function setDecliningPrice(
        uint24 saleId_,
        uint32 startTime_,
        uint128 highest_,
        uint128 lowest_,
        uint32 duration_,
        uint32 interval_
    ) internal {

        decliningPrices[saleId_].startTime = startTime_;
        decliningPrices[saleId_].highest = highest_;
        decliningPrices[saleId_].lowest = lowest_;
        decliningPrices[saleId_].duration = duration_;
        decliningPrices[saleId_].interval = interval_;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable128 {

    function tryAdd(uint128 a, uint128 b) internal pure returns (bool, uint128) {

        uint128 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint128 a, uint128 b) internal pure returns (bool, uint128) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint128 a, uint128 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint128 a, uint128 b) internal pure returns (bool, uint128) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint128 a, uint128 b) internal pure returns (bool, uint128) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint128 a, uint128 b) internal pure returns (uint128) {

        uint128 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint128 a, uint128 b) internal pure returns (uint128) {

        if (a == 0) return 0;
        uint128 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint128 a, uint128 b) internal pure returns (uint128) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint128 a, uint128 b) internal pure returns (uint128) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity 0.7.6;

interface IVNFT /* is IERC721 */{

    event TransferUnits(address from, address to, uint256 tokenId, uint256 targetTokenId,
        uint256 transferUnits);
    event Split(address owner, uint256 tokenId, uint256 newTokenId, uint256 splitUnits);
    event Merge(address owner, uint256 tokenId, uint256 targetTokenId, uint256 mergeUnits);
    event ApprovalUnits(address indexed owner, address indexed approved, uint256 indexed tokenId, uint256 approvalUnits);

    function slotOf(uint256 tokenId)  external view returns(uint256 slot);


    function balanceOfSlot(uint256 slot) external view returns (uint256 balance);

    function tokenOfSlotByIndex(uint256 slot, uint256 index) external view returns (uint256 tokenId);

    function unitsInToken(uint256 tokenId) external view returns (uint256 units);


    function approve(address to, uint256 tokenId, uint256 units) external;

    function allowance(uint256 tokenId, address spender) external view returns (uint256 allowed);


    function split(uint256 tokenId, uint256[] calldata units) external returns (uint256[] memory newTokenIds);

    function merge(uint256[] calldata tokenIds, uint256 targetTokenId) external;


    function transferFrom(address from, address to, uint256 tokenId,
        uint256 units) external returns (uint256 newTokenId);


    function safeTransferFrom(address from, address to, uint256 tokenId,
        uint256 units, bytes calldata data) external returns (uint256 newTokenId);


    function transferFrom(address from, address to, uint256 tokenId, uint256 targetTokenId,
        uint256 units) external;


    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 targetTokenId,
        uint256 units, bytes calldata data) external;

}

interface IVNFTReceiver {

    function onVNFTReceived(address operator, address from, uint256 tokenId,
        uint256 units, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity 0.7.6;

interface ISolver {

    
    function isSolver() external returns (bool);


    function depositAllowed(
        address product,
        address depositor,
        uint64 term,
        uint256 depositAmount,
        uint64[] calldata maturities
    ) external returns (uint256);


    function depositVerify(
        address product,
        address depositor,
        uint256 depositAmount,
        uint256 tokenId,
        uint64 term,
        uint64[] calldata maturities
    ) external returns (uint256);


    function withdrawAllowed(
        address product,
        address payee,
        uint256 withdrawAmount,
        uint256 tokenId,
        uint64 term,
        uint64 maturity
    ) external returns (uint256);


    function withdrawVerify(
        address product,
        address payee,
        uint256 withdrawAmount,
        uint256 tokenId,
        uint64 term,
        uint64 maturity
    ) external returns (uint256);


    function transferFromAllowed(
        address product,
        address from,
        address to,
        uint256 tokenId,
        uint256 targetTokenId,
        uint256 amount
    ) external returns (uint256);


    function transferFromVerify(
        address product,
        address from,
        address to,
        uint256 tokenId,
        uint256 targetTokenId,
        uint256 amount
    ) external returns (uint256);


    function mergeAllowed(
        address product,
        address owner,
        uint256 tokenId,
        uint256 targetTokenId,
        uint256 amount
    ) external returns (uint256);


    function mergeVerify(
        address product,
        address owner,
        uint256 tokenId,
        uint256 targetTokenId,
        uint256 amount
    ) external returns (uint256);


    function splitAllowed(
        address product,
        address owner,
        uint256 tokenId,
        uint256 newTokenId,
        uint256 amount
    ) external returns (uint256);


    function splitVerify(
        address product,
        address owner,
        uint256 tokenId,
        uint256 newTokenId,
        uint256 amount
    ) external returns (uint256);


    function needConvertUnsafeTransfer(
        address product,
        address from,
        address to,
        uint256 tokenId,
        uint256 units
    ) external view returns (bool);


    function needRejectUnsafeTransfer(
        address product,
        address from,
        address to,
        uint256 tokenId,
        uint256 units
    ) external view returns (bool);


    function publishFixedPriceAllowed(
        address icToken,
        uint256 tokenId,
        address seller,
        address currency,
        uint256 min,
        uint256 max,
        uint256 startTime,
        bool useAllowList,
        uint256 price
    ) external returns (uint256);


    function publishDecliningPriceAllowed(
        address icToken,
        uint256 tokenId,
        address seller,
        address currency,
        uint256 min,
        uint256 max,
        uint256 startTime,
        bool useAllowList,
        uint256 highest,
        uint256 lowest,
        uint256 duration,
        uint256 interval
    ) external returns (uint256);


    function publishVerify(
        address icToken,
        uint256 tokenId,
        address seller,
        address currency,
        uint256 saleId,
        uint256 units
    ) external;


    function buyAllowed(
        address icToken,
        uint256 tokenId,
        uint256 saleId,
        address buyer,
        address currency,
        uint256 buyAmount,
        uint256 buyUnits,
        uint256 price
    ) external returns (uint256);


    function buyVerify(
        address icToken,
        uint256 tokenId,
        uint256 saleId,
        address buyer,
        address seller,
        uint256 amount,
        uint256 units,
        uint256 price,
        uint256 fee
    ) external;


    function removeAllow(
        address icToken,
        uint256 tokenId,
        uint256 saleId,
        address seller
    ) external returns (uint256);

}// MIT

pragma solidity 0.7.6;

interface IUnderlyingContainer {

    function underlying() external view returns (address);

}// MIT

pragma solidity 0.7.6;

interface ISolvICMarket {

    event Publish(
        address indexed icToken,
        address indexed seller,
        uint24 indexed tokenId,
        uint24 saleId,
        uint8 priceType,
        uint128 units,
        uint128 startTime,
        address currency,
        uint128 min,
        uint128 max,
        bool useAllowList
    );

    event Remove(
        address indexed icToken,
        address indexed seller,
        uint24 indexed saleId,
        uint128 total,
        uint128 saled
    );

    event FixedPriceSet(
        address indexed icToken,
        uint24 indexed saleId,
        uint24 indexed tokenId,
        uint8 priceType,
        uint128 lastPrice
    );

    event DecliningPriceSet(
        address indexed icToken,
        uint24 indexed saleId,
        uint24 indexed tokenId,
        uint128 highest,
        uint128 lowest,
        uint32 duration,
        uint32 interval
    );

    event Traded(
        address indexed buyer,
        uint24 indexed saleId,
        address indexed icToken,
        uint24 tokenId,
        uint24 tradeId,
        uint32 tradeTime,
        address currency,
        uint8 priceType,
        uint128 price,
        uint128 tradedUnits,
        uint256 tradedAmount,
        uint8 feePayType,
        uint128 fee
    );

    function publishFixedPrice(
        address icToken_,
        uint24 tokenId_,
        address currency_,
        uint128 min_,
        uint128 max_,
        uint32 startTime_,
        bool useAllowList_,
        uint128 price_
    ) external returns (uint24 saleId);


    function publishDecliningPrice(
        address icToken_,
        uint24 tokenId_,
        address currency_,
        uint128 min_,
        uint128 max_,
        uint32 startTime_,
        bool useAllowList_,
        uint128 highest_,
        uint128 lowest_,
        uint32 duration_,
        uint32 interval_
    ) external returns (uint24 saleId);


    function buyByAmount(uint24 saleId_, uint256 amount_)
        external
        payable
        returns (uint128 units_);


    function buyByUnits(uint24 saleId_, uint128 units_)
        external
        payable
        returns (uint256 amount_, uint128 fee_);


    function remove(uint24 saleId_) external;


    function totalSalesOfICToken(address icToken_)
        external
        view
        returns (uint256);


    function saleIdOfICTokenByIndex(address icToken_, uint256 index_)
        external
        view
        returns (uint256);

    function getPrice(uint24 saleId_) external view returns (uint128);

}// MIT

pragma solidity 0.7.6;

contract SolvConvertibleMarket is ISolvICMarket, PriceManager {

    using SafeMathUpgradeable for uint256;
    using SafeMathUpgradeable128 for uint128;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    event NewAdmin(address oldAdmin, address newAdmin);
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
    event NewSolver(ISolver oldSolver, ISolver newSolver);

    event AddMarket(
        address indexed icToken,
        uint128 precision,
        uint8 feePayType,
        uint8 feeType,
        uint128 feeAmount,
        uint16 feeRate
    );

    event RemoveMarket(address indexed icToken);

    event SetCurrency(address indexed currency, bool enable);

    event WithdrawFee(address icToken, uint256 reduceAmount);

    struct Sale {
        uint24 saleId;
        uint24 tokenId;
        uint32 startTime;
        address seller;
        PriceManager.PriceType priceType;
        uint128 total; //sale units
        uint128 units; //current units
        uint128 min; //min units
        uint128 max; //max units
        address icToken; //sale asset
        address currency; //pay currency
        bool useAllowList;
        bool isValid;
    }

    struct Market {
        bool isValid;
        uint128 precision;
        FeeType feeType;
        FeePayType feePayType;
        uint128 feeAmount;
        uint16 feeRate;
    }

    enum FeeType {
        BY_AMOUNT,
        FIXED
    }

    enum FeePayType {
        SELLER_PAY,
        BUYER_PAY
    }

    mapping(uint24 => Sale) public sales;

    mapping(address => Market) public markets;

    EnumerableSetUpgradeable.AddressSet internal _currencies;
    EnumerableSetUpgradeable.AddressSet internal _vouchers;

    mapping(address => EnumerableSetUpgradeable.UintSet) internal _voucherSales;
    mapping(address => EnumerableSetUpgradeable.AddressSet)
        internal _allowAddresses;

    ISolver public solver;
    uint24 public nextSaleId;
    address payable public pendingAdmin;
    uint24 public nextTradeId;
    address payable public admin;
    bool public initialized;
    uint16 internal constant PERCENTAGE_BASE = 10000;
    bool internal _notEntered;

    mapping(address => EnumerableSetUpgradeable.AddressSet)
        internal allowAddressManagers;

    mapping(uint24 => mapping(address => uint128)) internal saleRecords;

    uint16 public repoFeeRate;

    modifier onlyAdmin() {

        require(msg.sender == admin, "only admin");
        _;
    }

    modifier onlyAllowAddressManager(address voucher_) {

        require(
            msg.sender == admin ||
                allowAddressManagers[voucher_].contains(msg.sender),
            "only manager"
        );
        _;
    }

    modifier nonReentrant() {

        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true;
    }

    constructor() {}

    function initialize(ISolver solver_) public {

        require(initialized == false, "already initialized");
        admin = msg.sender;
        nextSaleId = 1;
        nextTradeId = 1;
        _setSolver(solver_);
        initialized = true;
        _notEntered = true;
    }

    function currencies() external view returns (address[] memory currencies_) {

        currencies_ = new address[](_currencies.length());
        for (uint256 i = 0; i < _currencies.length(); i++) {
            currencies_[i] = _currencies.at(i);
        }
    }

    function vouchers() external view returns (address[] memory vouchers_) {

        vouchers_ = new address[](_vouchers.length());
        for (uint256 i = 0; i < _vouchers.length(); i++) {
            vouchers_[i] = _vouchers.at(i);
        }
    }

    function publishFixedPrice(
        address voucher_,
        uint24 tokenId_,
        address currency_,
        uint128 min_,
        uint128 max_,
        uint32 startTime_,
        bool useAllowList_,
        uint128 price_
    ) external virtual override returns (uint24 saleId) {

        address seller = msg.sender;

        uint256 err = solver.publishFixedPriceAllowed(
            voucher_,
            tokenId_,
            seller,
            currency_,
            min_,
            max_,
            startTime_,
            useAllowList_,
            price_
        );
        require(err == 0, "Solver: not allowed");

        PriceManager.PriceType priceType = PriceManager.PriceType.FIXED;
        saleId = _publish(
            seller,
            voucher_,
            tokenId_,
            currency_,
            priceType,
            min_,
            max_,
            startTime_,
            useAllowList_
        );
        PriceManager.setFixedPrice(saleId, price_);

        emit FixedPriceSet(
            voucher_,
            saleId,
            tokenId_,
            uint8(priceType),
            price_
        );
    }

    struct PublishDecliningPriceLocalVars {
        address icToken;
        uint24 tokenId;
        address currency;
        uint128 min;
        uint128 max;
        uint32 startTime;
        bool useAllowList;
        uint128 highest;
        uint128 lowest;
        uint32 duration;
        uint32 interval;
        address seller;
    }

    function publishDecliningPrice(
        address voucher_,
        uint24 tokenId_,
        address currency_,
        uint128 min_,
        uint128 max_,
        uint32 startTime_,
        bool useAllowList_,
        uint128 highest_,
        uint128 lowest_,
        uint32 duration_,
        uint32 interval_
    ) external virtual override returns (uint24 saleId) {

        PublishDecliningPriceLocalVars memory vars;
        vars.seller = msg.sender;
        vars.icToken = voucher_;
        vars.tokenId = tokenId_;
        vars.currency = currency_;
        vars.min = min_;
        vars.max = max_;
        vars.startTime = startTime_;
        vars.useAllowList = useAllowList_;
        vars.highest = highest_;
        vars.lowest = lowest_;
        vars.duration = duration_;
        vars.interval = interval_;

        require(vars.interval > 0, "interval cannot be 0");
        require(vars.lowest <= vars.highest, "lowest > highest");
        require(vars.duration > 0, "duration cannot be 0");

        uint256 err = solver.publishDecliningPriceAllowed(
            vars.icToken,
            vars.tokenId,
            vars.seller,
            vars.currency,
            vars.min,
            vars.max,
            vars.startTime,
            vars.useAllowList,
            vars.highest,
            vars.lowest,
            vars.duration,
            vars.interval
        );
        require(err == 0, "Solver: not allowed");

        PriceManager.PriceType priceType = PriceManager
            .PriceType
            .DECLIINING_BY_TIME;
        saleId = _publish(
            vars.seller,
            vars.icToken,
            vars.tokenId,
            vars.currency,
            priceType,
            vars.min,
            vars.max,
            vars.startTime,
            vars.useAllowList
        );

        PriceManager.setDecliningPrice(
            saleId,
            vars.startTime,
            vars.highest,
            vars.lowest,
            vars.duration,
            vars.interval
        );

        emit DecliningPriceSet(
            vars.icToken,
            saleId,
            vars.tokenId,
            vars.highest,
            vars.lowest,
            vars.duration,
            vars.interval
        );
    }

    function _publish(
        address seller_,
        address voucher_,
        uint24 tokenId_,
        address currency_,
        PriceManager.PriceType priceType_,
        uint128 min_,
        uint128 max_,
        uint32 startTime_,
        bool useAllowList_
    ) internal returns (uint24 saleId) {

        require(markets[voucher_].isValid, "unsupported voucher");
        require(
            _currencies.contains(currency_) ||
                currency_ == IUnderlyingContainer(voucher_).underlying(),
            "unsupported currency"
        );
        if (max_ > 0) {
            require(min_ <= max_, "min > max");
        }

        IVNFT vnft = IVNFT(voucher_);

        VNFTTransferHelper.doTransferIn(voucher_, seller_, tokenId_);

        saleId = _generateNextSaleId();
        uint256 units = vnft.unitsInToken(tokenId_);
        require(units <= uint128(-1), "exceeds uint128 max");
        sales[saleId] = Sale({
            saleId: saleId,
            seller: msg.sender,
            tokenId: tokenId_,
            total: uint128(units),
            units: uint128(units),
            startTime: startTime_,
            min: min_,
            max: max_,
            icToken: voucher_,
            currency: currency_,
            priceType: priceType_,
            useAllowList: useAllowList_,
            isValid: true
        });
        Sale storage sale = sales[saleId];
        _voucherSales[voucher_].add(saleId);
        emit Publish(
            sale.icToken,
            sale.seller,
            sale.tokenId,
            saleId,
            uint8(sale.priceType),
            sale.units,
            sale.startTime,
            sale.currency,
            sale.min,
            sale.max,
            sale.useAllowList
        );
        solver.publishVerify(
            sale.icToken,
            sale.tokenId,
            sale.seller,
            sale.currency,
            sale.saleId,
            sale.units
        );

        return saleId;
    }

    function buyByAmount(uint24 saleId_, uint256 amount_)
        external
        payable
        virtual
        override
        returns (uint128 units_)
    {

        Sale storage sale = sales[saleId_];
        address buyer = msg.sender;
        uint128 fee = _getFee(sale.icToken, sale.currency, amount_);
        uint128 price = PriceManager.price(sale.priceType, sale.saleId);
        uint256 units256;
        if (markets[sale.icToken].feePayType == FeePayType.BUYER_PAY) {
            units256 = amount_
                .sub(fee, "fee exceeds amount")
                .mul(uint256(markets[sale.icToken].precision))
                .div(uint256(price));
        } else {
            units256 = amount_
                .mul(uint256(markets[sale.icToken].precision))
                .div(uint256(price));
        }
        require(units256 <= uint128(-1), "exceeds uint128 max");
        units_ = uint128(units256);

        uint256 err = solver.buyAllowed(
            sale.icToken,
            sale.tokenId,
            saleId_,
            buyer,
            sale.currency,
            amount_,
            units_,
            price
        );
        require(err == 0, "Solver: not allowed");

        _buy(buyer, sale, amount_, units_, price, fee);
        return units_;
    }

    function buyByUnits(uint24 saleId_, uint128 units_)
        external
        payable
        virtual
        override
        returns (uint256 amount_, uint128 fee_)
    {

        Sale storage sale = sales[saleId_];
        address buyer = msg.sender;
        uint128 price = PriceManager.price(sale.priceType, sale.saleId);

        amount_ = uint256(units_).mul(uint256(price)).div(
            uint256(markets[sale.icToken].precision)
        );

        if (
            sale.currency == EthAddressLib.ethAddress() &&
            sale.priceType == PriceType.DECLIINING_BY_TIME &&
            amount_ != msg.value
        ) {
            amount_ = msg.value;
            uint128 fee = _getFee(sale.icToken, sale.currency, amount_);
            uint256 units256;
            if (markets[sale.icToken].feePayType == FeePayType.BUYER_PAY) {
                units256 = amount_
                    .sub(fee, "fee exceeds amount")
                    .mul(uint256(markets[sale.icToken].precision))
                    .div(uint256(price));
            } else {
                units256 = amount_
                    .mul(uint256(markets[sale.icToken].precision))
                    .div(uint256(price));
            }
            require(units256 <= uint128(-1), "exceeds uint128 max");
            units_ = uint128(units256);
        }

        fee_ = _getFee(sale.icToken, sale.currency, amount_);

        uint256 err = solver.buyAllowed(
            sale.icToken,
            sale.tokenId,
            saleId_,
            buyer,
            sale.currency,
            amount_,
            units_,
            price
        );
        require(err == 0, "Solver: not allowed");

        _buy(buyer, sale, amount_, units_, price, fee_);
        return (amount_, fee_);
    }

    struct BuyLocalVar {
        uint256 transferInAmount;
        uint256 transferOutAmount;
        FeePayType feePayType;
    }

    function _buy(
        address buyer_,
        Sale storage sale_,
        uint256 amount_,
        uint128 units_,
        uint128 price_,
        uint128 fee_
    ) internal {

        require(sale_.isValid, "invalid saleId");
        require(block.timestamp >= sale_.startTime, "not yet on sale");
        if (sale_.units >= sale_.min) {
            require(units_ >= sale_.min, "min units not met");
        }
        if (sale_.max > 0) {
            uint128 purchased = saleRecords[sale_.saleId][buyer_].add(units_);
            require(purchased <= sale_.max, "exceeds purchase limit");
            saleRecords[sale_.saleId][buyer_] = purchased;
        }

        if (sale_.useAllowList) {
            require(
                _allowAddresses[sale_.icToken].contains(buyer_),
                "not in allow list"
            );
        }

        sale_.units = sale_.units.sub(units_, "insufficient units for sale");
        BuyLocalVar memory vars;
        vars.feePayType = markets[sale_.icToken].feePayType;

        if (vars.feePayType == FeePayType.BUYER_PAY) {
            vars.transferInAmount = amount_.add(fee_);
            vars.transferOutAmount = amount_;
        } else if (vars.feePayType == FeePayType.SELLER_PAY) {
            vars.transferInAmount = amount_;
            vars.transferOutAmount = amount_.sub(fee_, "fee exceeds amount");
        } else {
            revert("unsupported feePayType");
        }

        ERC20TransferHelper.doTransferIn(
            sale_.currency,
            buyer_,
            vars.transferInAmount
        );

        if (units_ == IVNFT(sale_.icToken).unitsInToken(sale_.tokenId)) {
            VNFTTransferHelper.doTransferOut(
                sale_.icToken,
                buyer_,
                sale_.tokenId
            );
        } else {
            VNFTTransferHelper.doTransferOut(
                sale_.icToken,
                buyer_,
                sale_.tokenId,
                units_
            );
        }
        ERC20TransferHelper.doTransferOut(
            sale_.currency,
            payable(sale_.seller),
            vars.transferOutAmount
        );

        emit Traded(
            buyer_,
            sale_.saleId,
            sale_.icToken,
            sale_.tokenId,
            _generateNextTradeId(),
            uint32(block.timestamp),
            sale_.currency,
            uint8(sale_.priceType),
            price_,
            units_,
            amount_,
            uint8(vars.feePayType),
            fee_
        );

        solver.buyVerify(
            sale_.icToken,
            sale_.tokenId,
            sale_.saleId,
            buyer_,
            sale_.seller,
            amount_,
            units_,
            price_,
            fee_
        );

        if (sale_.units == 0) {
            emit Remove(
                sale_.icToken,
                sale_.seller,
                sale_.saleId,
                sale_.total,
                sale_.total - sale_.units
            );
            delete sales[sale_.saleId];
        }
    }

    function purchasedUnits(uint24 saleId_, address buyer_)
        external
        view
        returns (uint128)
    {

        return saleRecords[saleId_][buyer_];
    }

    function remove(uint24 saleId_) public virtual override {

        Sale memory sale = sales[saleId_];
        require(sale.isValid, "invalid sale");
        require(sale.seller == msg.sender, "only seller");

        uint256 err = solver.removeAllow(
            sale.icToken,
            sale.tokenId,
            sale.saleId,
            sale.seller
        );
        require(err == 0, "Solver: not allowed");

        VNFTTransferHelper.doTransferOut(
            sale.icToken,
            sale.seller,
            sale.tokenId
        );

        emit Remove(
            sale.icToken,
            sale.seller,
            sale.saleId,
            sale.total,
            sale.total - sale.units
        );
        delete sales[saleId_];
    }

    function _getFee(
        address voucher_,
        address currency_,
        uint256 amount
    ) internal view returns (uint128) {

        if (currency_ == IUnderlyingContainer(voucher_).underlying()) {
            uint256 fee = amount.mul(uint256(repoFeeRate)).div(PERCENTAGE_BASE);
            require(fee <= uint128(-1), "Fee: exceeds uint128 max");
            return uint128(fee);
        }

        Market storage market = markets[voucher_];
        if (market.feeType == FeeType.FIXED) {
            return market.feeAmount;
        } else if (market.feeType == FeeType.BY_AMOUNT) {
            uint256 fee = amount.mul(uint256(market.feeRate)).div(
                uint256(PERCENTAGE_BASE)
            );
            require(fee <= uint128(-1), "Fee: exceeds uint128 max");
            return uint128(fee);
        } else {
            revert("unsupported feeType");
        }
    }

    function getPrice(uint24 saleId_)
        public
        view
        virtual
        override
        returns (uint128)
    {

        return PriceManager.price(sales[saleId_].priceType, saleId_);
    }

    function totalSalesOfICToken(address voucher_)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _voucherSales[voucher_].length();
    }

    function saleIdOfICTokenByIndex(address voucher_, uint256 index_)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return _voucherSales[voucher_].at(index_);
    }

    function _generateNextSaleId() internal returns (uint24) {

        return nextSaleId++;
    }

    function _generateNextTradeId() internal returns (uint24) {

        return nextTradeId++;
    }

    function _addMarket(
        address voucher_,
        uint128 precision_,
        uint8 feePayType_,
        uint8 feeType_,
        uint128 feeAmount_,
        uint16 feeRate_
    ) public onlyAdmin {

        markets[voucher_].isValid = true;
        markets[voucher_].precision = precision_;
        markets[voucher_].feePayType = FeePayType(feePayType_);
        markets[voucher_].feeType = FeeType(feeType_);
        markets[voucher_].feeAmount = feeAmount_;
        markets[voucher_].feeRate = feeRate_;

        _vouchers.add(voucher_);

        emit AddMarket(
            voucher_,
            precision_,
            feePayType_,
            feeType_,
            feeAmount_,
            feeRate_
        );
    }

    function _removeMarket(address voucher_) public onlyAdmin {

        _vouchers.remove(voucher_);
        delete markets[voucher_];
        emit RemoveMarket(voucher_);
    }

    function _setCurrency(address currency_, bool enable_) public onlyAdmin {

        _currencies.add(currency_);
        emit SetCurrency(currency_, enable_);
    }

    function _setRepoFeeRate(uint16 newRepoFeeRate_) external onlyAdmin {

        repoFeeRate = newRepoFeeRate_;
    }

    function _withdrawFee(address currency_, uint256 reduceAmount_)
        public
        onlyAdmin
    {

        ERC20TransferHelper.doTransferOut(currency_, admin, reduceAmount_);
        emit WithdrawFee(currency_, reduceAmount_);
    }

    function _addAllowAddress(
        address voucher_,
        address[] calldata addresses_,
        bool resetExisting_
    ) external onlyAllowAddressManager(voucher_) {

        require(markets[voucher_].isValid, "unsupported icToken");
        EnumerableSetUpgradeable.AddressSet storage set = _allowAddresses[
            voucher_
        ];

        if (resetExisting_) {
            while (set.length() != 0) {
                set.remove(set.at(0));
            }
        }

        for (uint256 i = 0; i < addresses_.length; i++) {
            set.add(addresses_[i]);
        }
    }

    function _removeAllowAddress(
        address voucher_,
        address[] calldata addresses_
    ) external onlyAllowAddressManager(voucher_) {

        require(markets[voucher_].isValid, "unsupported icToken");
        EnumerableSetUpgradeable.AddressSet storage set = _allowAddresses[
            voucher_
        ];
        for (uint256 i = 0; i < addresses_.length; i++) {
            set.remove(addresses_[i]);
        }
    }

    function isBuyerAllowed(address voucher_, address buyer_)
        external
        view
        returns (bool)
    {

        return _allowAddresses[voucher_].contains(buyer_);
    }

    function setAllowAddressManager(
        address voucher_,
        address[] calldata managers_,
        bool resetExisting_
    ) external onlyAdmin {

        require(markets[voucher_].isValid, "unsupported icToken");
        EnumerableSetUpgradeable.AddressSet storage set = allowAddressManagers[
            voucher_
        ];
        if (resetExisting_) {
            while (set.length() != 0) {
                set.remove(set.at(0));
            }
        }

        for (uint256 i = 0; i < managers_.length; i++) {
            set.add(managers_[i]);
        }
    }

    function allowAddressManager(address voucher_, uint256 index_)
        external
        view
        returns (address)
    {

        return allowAddressManagers[voucher_].at(index_);
    }

    function _setSolver(ISolver newSolver_) public virtual onlyAdmin {

        ISolver oldSolver = solver;
        require(newSolver_.isSolver(), "invalid solver");
        solver = newSolver_;

        emit NewSolver(oldSolver, newSolver_);
    }

    function _setPendingAdmin(address payable newPendingAdmin) public {

        require(msg.sender == admin, "only admin");

        address oldPendingAdmin = pendingAdmin;

        pendingAdmin = newPendingAdmin;

        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    function _acceptAdmin() public {

        require(
            msg.sender == pendingAdmin && msg.sender != address(0),
            "only pending admin"
        );

        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        admin = pendingAdmin;

        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }
}