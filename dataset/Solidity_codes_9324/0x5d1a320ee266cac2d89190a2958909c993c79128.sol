







pragma solidity >=0.7.6 <0.8.0;

library AddressIsContract {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}


pragma solidity >=0.7.6 <0.8.0;

library ERC20Wrapper {

    using AddressIsContract for address;

    function wrappedTransfer(
        IWrappedERC20 token,
        address to,
        uint256 value
    ) internal {

        _callWithOptionalReturnData(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function wrappedTransferFrom(
        IWrappedERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callWithOptionalReturnData(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function wrappedApprove(
        IWrappedERC20 token,
        address spender,
        uint256 value
    ) internal {

        _callWithOptionalReturnData(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callWithOptionalReturnData(IWrappedERC20 token, bytes memory callData) internal {

        address target = address(token);
        require(target.isContract(), "ERC20Wrapper: non-contract");

        (bool success, bytes memory data) = target.call(callData);
        if (success) {
            if (data.length != 0) {
                require(abi.decode(data, (bool)), "ERC20Wrapper: operation failed");
            }
        } else {
            if (data.length == 0) {
                revert("ERC20Wrapper: operation failed");
            }

            assembly {
                let size := mload(data)
                revert(add(32, data), size)
            }
        }
    }
}

interface IWrappedERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);

}



pragma solidity >=0.7.6 <0.8.0;

library EnumMap {


    struct MapEntry {
        bytes32 key;
        bytes32 value;
    }

    struct Map {
        MapEntry[] entries;
        mapping(bytes32 => uint256) indexes;
    }

    function set(
        Map storage map,
        bytes32 key,
        bytes32 value
    ) internal returns (bool) {

        uint256 keyIndex = map.indexes[key];

        if (keyIndex == 0) {
            map.entries.push(MapEntry({key: key, value: value}));
            map.indexes[key] = map.entries.length;
            return true;
        } else {
            map.entries[keyIndex - 1].value = value;
            return false;
        }
    }

    function remove(Map storage map, bytes32 key) internal returns (bool) {

        uint256 keyIndex = map.indexes[key];

        if (keyIndex != 0) {

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map.entries.length - 1;


            MapEntry storage lastEntry = map.entries[lastIndex];

            map.entries[toDeleteIndex] = lastEntry;
            map.indexes[lastEntry.key] = toDeleteIndex + 1; // All indexes are 1-based

            map.entries.pop();

            delete map.indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function contains(Map storage map, bytes32 key) internal view returns (bool) {

        return map.indexes[key] != 0;
    }

    function length(Map storage map) internal view returns (uint256) {

        return map.entries.length;
    }

    function at(Map storage map, uint256 index) internal view returns (bytes32, bytes32) {

        require(map.entries.length > index, "EnumMap: index out of bounds");

        MapEntry storage entry = map.entries[index];
        return (entry.key, entry.value);
    }

    function get(Map storage map, bytes32 key) internal view returns (bytes32) {

        uint256 keyIndex = map.indexes[key];
        require(keyIndex != 0, "EnumMap: nonexistent key"); // Equivalent to contains(map, key)
        return map.entries[keyIndex - 1].value; // All indexes are 1-based
    }
}



pragma solidity >=0.7.6 <0.8.0;

library EnumSet {


    struct Set {
        bytes32[] values;
        mapping(bytes32 => uint256) indexes;
    }

    function add(Set storage set, bytes32 value) internal returns (bool) {

        if (!contains(set, value)) {
            set.values.push(value);
            set.indexes[value] = set.values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(Set storage set, bytes32 value) internal returns (bool) {

        uint256 valueIndex = set.indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set.values.length - 1;


            bytes32 lastvalue = set.values[lastIndex];

            set.values[toDeleteIndex] = lastvalue;
            set.indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set.values.pop();

            delete set.indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function contains(Set storage set, bytes32 value) internal view returns (bool) {

        return set.indexes[value] != 0;
    }

    function length(Set storage set) internal view returns (uint256) {

        return set.values.length;
    }

    function at(Set storage set, uint256 index) internal view returns (bytes32) {

        require(set.values.length > index, "EnumSet: index out of bounds");
        return set.values[index];
    }
}


pragma solidity >=0.7.6 <0.8.0;

abstract contract ManagedIdentity {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        return msg.data;
    }
}


pragma solidity >=0.7.6 <0.8.0;

interface IERC173 {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);


    function transferOwnership(address newOwner) external;

}


pragma solidity >=0.7.6 <0.8.0;

abstract contract Ownable is ManagedIdentity, IERC173 {
    address internal _owner;

    constructor(address owner_) {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
    }

    function owner() public view virtual override returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public virtual override {
        _requireOwnership(_msgSender());
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    function _requireOwnership(address account) internal virtual {
        require(account == this.owner(), "Ownable: not the owner");
    }
}


pragma solidity >=0.7.6 <0.8.0;

abstract contract PayoutWallet is ManagedIdentity, Ownable {
    event PayoutWalletSet(address payoutWallet_);

    address payable public payoutWallet;

    constructor(address owner, address payable payoutWallet_) Ownable(owner) {
        require(payoutWallet_ != address(0), "Payout: zero address");
        payoutWallet = payoutWallet_;
        emit PayoutWalletSet(payoutWallet_);
    }

    function setPayoutWallet(address payable payoutWallet_) public {
        _requireOwnership(_msgSender());
        require(payoutWallet_ != address(0), "Payout: zero address");
        payoutWallet = payoutWallet_;
        emit PayoutWalletSet(payoutWallet);
    }
}


pragma solidity >=0.7.6 <0.8.0;

abstract contract Startable is ManagedIdentity {
    event Started(address account);

    uint256 private _startedAt;

    modifier whenNotStarted() {
        require(_startedAt == 0, "Startable: started");
        _;
    }

    modifier whenStarted() {
        require(_startedAt != 0, "Startable: not started");
        _;
    }

    constructor() {}

    function startedAt() public view returns (uint256) {
        return _startedAt;
    }

    function _start() internal virtual whenNotStarted {
        _startedAt = block.timestamp;
        emit Started(_msgSender());
    }
}


pragma solidity >=0.7.6 <0.8.0;

abstract contract Pausable is ManagedIdentity {
    event Paused(address account);

    event Unpaused(address account);

    bool public paused;

    constructor(bool paused_) {
        paused = paused_;
    }

    function _requireNotPaused() internal view {
        require(!paused, "Pausable: paused");
    }

    function _requirePaused() internal view {
        require(paused, "Pausable: not paused");
    }

    function _pause() internal virtual {
        _requireNotPaused();
        paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual {
        _requirePaused();
        paused = false;
        emit Unpaused(_msgSender());
    }
}


pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}


pragma solidity >=0.7.6 <0.8.0;

interface ISale {

    event MagicValues(bytes32[] names, bytes32[] values);

    event SkuCreation(bytes32 sku, uint256 totalSupply, uint256 maxQuantityPerPurchase, address notificationsReceiver);

    event SkuPricingUpdate(bytes32 indexed sku, address[] tokens, uint256[] prices);

    event Purchase(
        address indexed purchaser,
        address recipient,
        address indexed token,
        bytes32 indexed sku,
        uint256 quantity,
        bytes userData,
        uint256 totalPrice,
        bytes extData
    );

    function TOKEN_ETH() external pure returns (address);


    function SUPPLY_UNLIMITED() external pure returns (uint256);


    function purchaseFor(
        address payable recipient,
        address token,
        bytes32 sku,
        uint256 quantity,
        bytes calldata userData
    ) external payable;


    function estimatePurchase(
        address payable recipient,
        address token,
        bytes32 sku,
        uint256 quantity,
        bytes calldata userData
    ) external view returns (uint256 totalPrice, bytes32[] memory pricingData);


    function getSkuInfo(bytes32 sku)
        external
        view
        returns (
            uint256 totalSupply,
            uint256 remainingSupply,
            uint256 maxQuantityPerPurchase,
            address notificationsReceiver,
            address[] memory tokens,
            uint256[] memory prices
        );


    function getSkus() external view returns (bytes32[] memory skus);

}


pragma solidity >=0.7.6 <0.8.0;

interface IPurchaseNotificationsReceiver {

    function onPurchaseNotificationReceived(
        address purchaser,
        address recipient,
        address token,
        bytes32 sku,
        uint256 quantity,
        bytes calldata userData,
        uint256 totalPrice,
        bytes32[] calldata pricingData,
        bytes32[] calldata paymentData,
        bytes32[] calldata deliveryData
    ) external returns (bytes4);

}


pragma solidity >=0.7.6 <0.8.0;

abstract contract PurchaseLifeCycles {
    struct PurchaseData {
        address payable purchaser;
        address payable recipient;
        address token;
        bytes32 sku;
        uint256 quantity;
        bytes userData;
        uint256 totalPrice;
        bytes32[] pricingData;
        bytes32[] paymentData;
        bytes32[] deliveryData;
    }


    function _estimatePurchase(PurchaseData memory purchase) internal view virtual returns (uint256 totalPrice, bytes32[] memory pricingData) {
        _validation(purchase);
        _pricing(purchase);

        totalPrice = purchase.totalPrice;
        pricingData = purchase.pricingData;
    }

    function _purchaseFor(PurchaseData memory purchase) internal virtual {
        _validation(purchase);
        _pricing(purchase);
        _payment(purchase);
        _delivery(purchase);
        _notification(purchase);
    }


    function _validation(PurchaseData memory purchase) internal view virtual;

    function _pricing(PurchaseData memory purchase) internal view virtual;

    function _payment(PurchaseData memory purchase) internal virtual;

    function _delivery(PurchaseData memory purchase) internal virtual;

    function _notification(PurchaseData memory purchase) internal virtual;
}


pragma solidity >=0.7.6 <0.8.0;

abstract contract Sale is PurchaseLifeCycles, ISale, PayoutWallet, Startable, Pausable {
    using AddressIsContract for address;
    using SafeMath for uint256;
    using EnumSet for EnumSet.Set;
    using EnumMap for EnumMap.Map;

    struct SkuInfo {
        uint256 totalSupply;
        uint256 remainingSupply;
        uint256 maxQuantityPerPurchase;
        address notificationsReceiver;
        EnumMap.Map prices;
    }

    address public constant override TOKEN_ETH = address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    uint256 public constant override SUPPLY_UNLIMITED = type(uint256).max;

    EnumSet.Set internal _skus;
    mapping(bytes32 => SkuInfo) internal _skuInfos;

    uint256 internal immutable _skusCapacity;
    uint256 internal immutable _tokensPerSkuCapacity;

    constructor(
        address payable payoutWallet_,
        uint256 skusCapacity,
        uint256 tokensPerSkuCapacity
    ) PayoutWallet(msg.sender, payoutWallet_) Pausable(true) {
        _skusCapacity = skusCapacity;
        _tokensPerSkuCapacity = tokensPerSkuCapacity;
        bytes32[] memory names = new bytes32[](2);
        bytes32[] memory values = new bytes32[](2);
        (names[0], values[0]) = ("TOKEN_ETH", bytes32(uint256(TOKEN_ETH)));
        (names[1], values[1]) = ("SUPPLY_UNLIMITED", bytes32(uint256(SUPPLY_UNLIMITED)));
        emit MagicValues(names, values);
    }


    function start() public virtual {
        _requireOwnership(_msgSender());
        _start();
        _unpause();
    }

    function pause() public virtual whenStarted {
        _requireOwnership(_msgSender());
        _pause();
    }

    function unpause() public virtual whenStarted {
        _requireOwnership(_msgSender());
        _unpause();
    }

    function updateSkuPricing(
        bytes32 sku,
        address[] memory tokens,
        uint256[] memory prices
    ) public virtual {
        _requireOwnership(_msgSender());
        uint256 length = tokens.length;
        require(length == prices.length, "Sale: inconsistent arrays");
        SkuInfo storage skuInfo = _skuInfos[sku];
        require(skuInfo.totalSupply != 0, "Sale: non-existent sku");

        EnumMap.Map storage tokenPrices = skuInfo.prices;
        if (length == 0) {
            uint256 currentLength = tokenPrices.length();
            for (uint256 i = 0; i < currentLength; ++i) {
                (bytes32 token, ) = tokenPrices.at(0);
                tokenPrices.remove(token);
            }
        } else {
            _setTokenPrices(tokenPrices, tokens, prices);
        }

        emit SkuPricingUpdate(sku, tokens, prices);
    }


    function purchaseFor(
        address payable recipient,
        address token,
        bytes32 sku,
        uint256 quantity,
        bytes calldata userData
    ) external payable virtual override whenStarted {
        _requireNotPaused();
        PurchaseData memory purchase;
        purchase.purchaser = _msgSender();
        purchase.recipient = recipient;
        purchase.token = token;
        purchase.sku = sku;
        purchase.quantity = quantity;
        purchase.userData = userData;

        _purchaseFor(purchase);
    }

    function estimatePurchase(
        address payable recipient,
        address token,
        bytes32 sku,
        uint256 quantity,
        bytes calldata userData
    ) external view virtual override whenStarted returns (uint256 totalPrice, bytes32[] memory pricingData) {
        _requireNotPaused();
        PurchaseData memory purchase;
        purchase.purchaser = _msgSender();
        purchase.recipient = recipient;
        purchase.token = token;
        purchase.sku = sku;
        purchase.quantity = quantity;
        purchase.userData = userData;

        return _estimatePurchase(purchase);
    }

    function getSkuInfo(bytes32 sku)
        external
        view
        override
        returns (
            uint256 totalSupply,
            uint256 remainingSupply,
            uint256 maxQuantityPerPurchase,
            address notificationsReceiver,
            address[] memory tokens,
            uint256[] memory prices
        )
    {
        SkuInfo storage skuInfo = _skuInfos[sku];
        uint256 length = skuInfo.prices.length();

        totalSupply = skuInfo.totalSupply;
        require(totalSupply != 0, "Sale: non-existent sku");
        remainingSupply = skuInfo.remainingSupply;
        maxQuantityPerPurchase = skuInfo.maxQuantityPerPurchase;
        notificationsReceiver = skuInfo.notificationsReceiver;

        tokens = new address[](length);
        prices = new uint256[](length);
        for (uint256 i = 0; i < length; ++i) {
            (bytes32 token, bytes32 price) = skuInfo.prices.at(i);
            tokens[i] = address(uint256(token));
            prices[i] = uint256(price);
        }
    }

    function getSkus() external view override returns (bytes32[] memory skus) {
        skus = _skus.values;
    }


    function _createSku(
        bytes32 sku,
        uint256 totalSupply,
        uint256 maxQuantityPerPurchase,
        address notificationsReceiver
    ) internal virtual {
        require(totalSupply != 0, "Sale: zero supply");
        require(_skus.length() < _skusCapacity, "Sale: too many skus");
        require(_skus.add(sku), "Sale: sku already created");
        if (notificationsReceiver != address(0)) {
            require(notificationsReceiver.isContract(), "Sale: non-contract receiver");
        }
        SkuInfo storage skuInfo = _skuInfos[sku];
        skuInfo.totalSupply = totalSupply;
        skuInfo.remainingSupply = totalSupply;
        skuInfo.maxQuantityPerPurchase = maxQuantityPerPurchase;
        skuInfo.notificationsReceiver = notificationsReceiver;
        emit SkuCreation(sku, totalSupply, maxQuantityPerPurchase, notificationsReceiver);
    }

    function _setTokenPrices(
        EnumMap.Map storage tokenPrices,
        address[] memory tokens,
        uint256[] memory prices
    ) internal virtual {
        for (uint256 i = 0; i < tokens.length; ++i) {
            address token = tokens[i];
            require(token != address(0), "Sale: zero address token");
            uint256 price = prices[i];
            if (price == 0) {
                tokenPrices.remove(bytes32(uint256(token)));
            } else {
                tokenPrices.set(bytes32(uint256(token)), bytes32(price));
            }
        }
        require(tokenPrices.length() <= _tokensPerSkuCapacity, "Sale: too many tokens");
    }


    function _validation(PurchaseData memory purchase) internal view virtual override {
        require(purchase.recipient != address(0), "Sale: zero address recipient");
        require(purchase.token != address(0), "Sale: zero address token");
        require(purchase.quantity != 0, "Sale: zero quantity purchase");
        SkuInfo storage skuInfo = _skuInfos[purchase.sku];
        require(skuInfo.totalSupply != 0, "Sale: non-existent sku");
        require(skuInfo.maxQuantityPerPurchase >= purchase.quantity, "Sale: above max quantity");
        if (skuInfo.totalSupply != SUPPLY_UNLIMITED) {
            require(skuInfo.remainingSupply >= purchase.quantity, "Sale: insufficient supply");
        }
        bytes32 priceKey = bytes32(uint256(purchase.token));
        require(skuInfo.prices.contains(priceKey), "Sale: non-existent sku token");
    }

    function _delivery(PurchaseData memory purchase) internal virtual override {
        SkuInfo storage skuInfo = _skuInfos[purchase.sku];
        if (skuInfo.totalSupply != SUPPLY_UNLIMITED) {
            _skuInfos[purchase.sku].remainingSupply = skuInfo.remainingSupply.sub(purchase.quantity);
        }
    }

    function _notification(PurchaseData memory purchase) internal virtual override {
        emit Purchase(
            purchase.purchaser,
            purchase.recipient,
            purchase.token,
            purchase.sku,
            purchase.quantity,
            purchase.userData,
            purchase.totalPrice,
            abi.encodePacked(purchase.pricingData, purchase.paymentData, purchase.deliveryData)
        );

        address notificationsReceiver = _skuInfos[purchase.sku].notificationsReceiver;
        if (notificationsReceiver != address(0)) {
            require(
                IPurchaseNotificationsReceiver(notificationsReceiver).onPurchaseNotificationReceived(
                    purchase.purchaser,
                    purchase.recipient,
                    purchase.token,
                    purchase.sku,
                    purchase.quantity,
                    purchase.userData,
                    purchase.totalPrice,
                    purchase.pricingData,
                    purchase.paymentData,
                    purchase.deliveryData
                ) == IPurchaseNotificationsReceiver(address(0)).onPurchaseNotificationReceived.selector, // TODO precompute return value
                "Sale: notification refused"
            );
        }
    }
}


pragma solidity >=0.7.6 <0.8.0;

abstract contract FixedPricesSale is Sale {
    using ERC20Wrapper for IWrappedERC20;
    using SafeMath for uint256;
    using EnumMap for EnumMap.Map;

    constructor(
        address payable payoutWallet_,
        uint256 skusCapacity,
        uint256 tokensPerSkuCapacity
    ) Sale(payoutWallet_, skusCapacity, tokensPerSkuCapacity) {}


    function _pricing(PurchaseData memory purchase) internal view virtual override {
        SkuInfo storage skuInfo = _skuInfos[purchase.sku];
        require(skuInfo.totalSupply != 0, "Sale: unsupported SKU");
        EnumMap.Map storage prices = skuInfo.prices;
        uint256 unitPrice = _unitPrice(purchase, prices);
        purchase.totalPrice = unitPrice.mul(purchase.quantity);
    }

    function _payment(PurchaseData memory purchase) internal virtual override {
        if (purchase.token == TOKEN_ETH) {
            require(msg.value >= purchase.totalPrice, "Sale: insufficient ETH");

            payoutWallet.transfer(purchase.totalPrice);

            uint256 change = msg.value.sub(purchase.totalPrice);

            if (change != 0) {
                purchase.purchaser.transfer(change);
            }
        } else {
            IWrappedERC20(purchase.token).wrappedTransferFrom(_msgSender(), payoutWallet, purchase.totalPrice);
        }
    }


    function _unitPrice(PurchaseData memory purchase, EnumMap.Map storage prices) internal view virtual returns (uint256 unitPrice) {
        unitPrice = uint256(prices.get(bytes32(uint256(purchase.token))));
        require(unitPrice != 0, "Sale: unsupported payment token");
    }
}


pragma solidity >=0.7.6 <0.8.0;

abstract contract Recoverable is ManagedIdentity, Ownable {
    using ERC20Wrapper for IWrappedERC20;

    function recoverERC20s(
        address[] calldata accounts,
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external virtual {
        _requireOwnership(_msgSender());
        uint256 length = accounts.length;
        require(length == tokens.length && length == amounts.length, "Recov: inconsistent arrays");
        for (uint256 i = 0; i != length; ++i) {
            IWrappedERC20(tokens[i]).wrappedTransfer(accounts[i], amounts[i]);
        }
    }

    function recoverERC721s(
        address[] calldata accounts,
        address[] calldata contracts,
        uint256[] calldata tokenIds
    ) external virtual {
        _requireOwnership(_msgSender());
        uint256 length = accounts.length;
        require(length == contracts.length && length == tokenIds.length, "Recov: inconsistent arrays");
        for (uint256 i = 0; i != length; ++i) {
            IRecoverableERC721(contracts[i]).transferFrom(address(this), accounts[i], tokenIds[i]);
        }
    }
}

interface IRecoverableERC721 {

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

}


pragma solidity >=0.7.6 <0.8.0;

contract BenjiBananasPassSale is FixedPricesSale, Recoverable {

    IMembershipPassContract public immutable membershipPassContract;

    struct SkuAdditionalInfo {
        uint256[] tokenIds;
        uint256 startTimestamp;
        uint256 endTimestamp;
    }

    mapping(bytes32 => SkuAdditionalInfo) internal _skuAdditionalInfo;

    constructor(
        IMembershipPassContract membershipPass_,
        address payable payoutWallet,
        uint256 skusCapacity,
        uint256 tokensPerSkuCapacity
    ) FixedPricesSale(payoutWallet, skusCapacity, tokensPerSkuCapacity) {
        membershipPassContract = membershipPass_;
    }

    function createSku(
        bytes32 sku,
        uint256 totalSupply,
        uint256 maxQuantityPerPurchase,
        uint256[] calldata tokenIds,
        uint256 startTimestamp,
        uint256 endTimestamp
    ) external {

        _requireOwnership(_msgSender());
        uint256 length = tokenIds.length;
        require(length != 0, "Sale: empty tokens");
        for (uint256 i; i != length; ++i) {
            require(membershipPassContract.isFungible(tokenIds[i]), "Sale: not a fungible token");
        }
        _skuAdditionalInfo[sku] = SkuAdditionalInfo(tokenIds, startTimestamp, endTimestamp);
        _createSku(sku, totalSupply, maxQuantityPerPurchase, address(0));
    }

    function updateSkuTimestamps(
        bytes32 sku,
        uint256 startTimestamp,
        uint256 endTimestamp
    ) external {

        _requireOwnership(_msgSender());
        require(_skuInfos[sku].totalSupply != 0, "Sale: non-existent sku");
        SkuAdditionalInfo storage info = _skuAdditionalInfo[sku];
        info.startTimestamp = startTimestamp;
        info.endTimestamp = endTimestamp;
    }

    function getSkuAdditionalInfo(bytes32 sku)
        external
        view
        returns (
            uint256[] memory tokenIds,
            uint256 startTimestamp,
            uint256 endTimestamp
        )
    {

        require(_skuInfos[sku].totalSupply != 0, "Sale: non-existent sku");
        SkuAdditionalInfo memory info = _skuAdditionalInfo[sku];
        return (info.tokenIds, info.startTimestamp, info.endTimestamp);
    }

    function canPurchaseSku(bytes32 sku) external view returns (bool) {

        require(_skuInfos[sku].totalSupply != 0, "Sale: non-existent sku");
        SkuAdditionalInfo memory info = _skuAdditionalInfo[sku];
        return block.timestamp > info.startTimestamp && (info.endTimestamp == 0 || block.timestamp < info.endTimestamp);
    }

    function _delivery(PurchaseData memory purchase) internal override {

        super._delivery(purchase);
        SkuAdditionalInfo memory info = _skuAdditionalInfo[purchase.sku];
        uint256 startTimestamp = info.startTimestamp;
        uint256 endTimestamp = info.endTimestamp;
        require(block.timestamp > startTimestamp, "Sale: not started yet");
        require(endTimestamp == 0 || block.timestamp < endTimestamp, "Sale: already ended");

        uint256 length = info.tokenIds.length;
        if (length == 1) {
            membershipPassContract.safeMint(purchase.recipient, info.tokenIds[0], purchase.quantity, "");
        } else {
            uint256 purchaseQuantity = purchase.quantity;
            uint256[] memory quantities = new uint256[](length);
            for (uint256 i; i != length; ++i) {
                quantities[i] = purchaseQuantity;
            }
            membershipPassContract.safeBatchMint(purchase.recipient, info.tokenIds, quantities, "");
        }
    }
}

interface IMembershipPassContract {

    function isFungible(uint256 id) external pure returns (bool);


    function safeMint(
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external;


    function safeBatchMint(
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;

}