
pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}//MIT
pragma solidity ^0.8.6;

interface IFactory {

    function getDaos() external view returns (address[] memory);


    function shop() external view returns (address);


    function monthlyCost() external view returns (uint256);


    function subscriptions(address _dao) external view returns (uint256);


    function containsDao(address _dao) external view returns (bool);

}//MIT
pragma solidity ^0.8.6;

interface IShop {

    struct PublicOffer {
        bool isActive;
        address currency;
        uint256 rate;
    }

    function publicOffers(address _dao)
        external
        view
        returns (PublicOffer memory);


    struct PrivateOffer {
        bool isActive;
        address recipient;
        address currency;
        uint256 currencyAmount;
        uint256 lpAmount;
    }

    function privateOffers(address _dao, uint256 _index)
        external
        view
        returns (PrivateOffer memory);


    function numberOfPrivateOffers(address _dao)
        external
        view
        returns (uint256);


    function buyPrivateOffer(address _dao, uint256 _id) external returns (bool);

}//MIT
pragma solidity ^0.8.6;

interface IDao {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function lp() external view returns (address);


    function burnLp(
        address _recipient,
        uint256 _share,
        address[] memory _tokens,
        address[] memory _adapters,
        address[] memory _pools
    ) external returns (bool);


    function setLp(address _lp) external returns (bool);


    function quorum() external view returns (uint8);


    function executedTx(bytes32 _txHash) external view returns (bool);


    function mintable() external view returns (bool);


    function burnable() external view returns (bool);


    function numberOfPermitted() external view returns (uint256);


    function numberOfAdapters() external view returns (uint256);


    function executePermitted(
        address _target,
        bytes calldata _data,
        uint256 _value
    ) external returns (bool);

}//MIT
pragma solidity ^0.8.6;

interface IPrivateExitModule {

    function privateExit(address _daoAddress, uint256 _offerId)
        external
        returns (bool success);

}// GPL-2.0-or-later
pragma solidity ^0.8.6;



contract LaunchpadModule is OwnableUpgradeable {

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    IFactory public factory;
    IShop public shop;
    IPrivateExitModule public privateExitModule;

    struct Sale {
        address currency;
        uint256 rate;
        bool isFinite;
        bool isLimitedTotalSaleAmount;
        bool isWhitelist;
        bool isAllocation;
        uint256 endTimestamp;
        uint256 totalSaleAmount;
        EnumerableSetUpgradeable.AddressSet whitelist;
        mapping(address => uint256) allocations;
    }

    mapping(address => mapping(uint256 => Sale)) private sales;

    mapping(address => uint256) public saleIndexes;

    mapping(address => mapping(uint256 => mapping(address => bool)))
        public bought;

    mapping(address => mapping(uint256 => uint256)) public totalBought;

    event InitSale(
        address indexed daoAddress,
        uint256 indexed saleId,
        address currency,
        uint256 rate,
        bool[4] limits,
        uint256 _endTimestamp,
        uint256 _totalSaleAmount,
        address[] _addWhitelist,
        uint256[] _allocations,
        address[] _removeWhitelist
    );

    event CloseSale(address indexed daoAddress, uint256 indexed saleId);

    event Buy(
        address indexed daoAddress,
        uint256 indexed saleId,
        address indexed buyer,
        uint256 currencyAmount,
        uint256 lpAmount
    );

    constructor() initializer {
        __Ownable_init();
    }

    function initialize() public initializer {

        __Ownable_init();
    }

    function setCoreAddresses(
        IFactory _factory,
        IShop _shop,
        IPrivateExitModule _privateExitModule
    ) external onlyOwner {

        factory = _factory;
        shop = _shop;
        privateExitModule = _privateExitModule;
    }

    modifier onlyDao() {

        require(
            factory.containsDao(msg.sender),
            "LaunchpadModule: only for DAOs"
        );
        _;
    }

    function initSale(
        address _currency,
        uint256 _rate,
        bool[4] calldata _limits,
        uint256 _endTimestamp,
        uint256 _totalSaleAmount,
        address[] calldata _addWhitelist,
        uint256[] calldata _allocations,
        address[] calldata _removeWhitelist
    ) external onlyDao {

        require(
            _addWhitelist.length == _allocations.length,
            "LaunchpadModule: Invalid Whitelist Length"
        );

        Sale storage sale = sales[msg.sender][saleIndexes[msg.sender]];

        sale.currency = _currency;
        sale.rate = _rate;
        sale.isFinite = _limits[0];
        sale.isLimitedTotalSaleAmount = _limits[1];
        sale.isWhitelist = _limits[2];
        sale.isAllocation = _limits[3];
        sale.endTimestamp = _endTimestamp;
        sale.totalSaleAmount = _totalSaleAmount;

        for (uint256 i = 0; i < _addWhitelist.length; i++) {
            sale.whitelist.add(_addWhitelist[i]);
            sale.allocations[_addWhitelist[i]] = _allocations[i];
        }

        for (uint256 i = 0; i < _removeWhitelist.length; i++) {
            sale.whitelist.remove(_removeWhitelist[i]);
        }

        emit InitSale(
            msg.sender,
            saleIndexes[msg.sender],
            _currency,
            _rate,
            _limits,
            _endTimestamp,
            _totalSaleAmount,
            _addWhitelist,
            _allocations,
            _removeWhitelist
        );
    }

    function fillLpBalance(address _dao, uint256 _id) external {

        require(shop.buyPrivateOffer(_dao, _id));
    }

    function closeSale() external onlyDao {

        saleIndexes[msg.sender]++;

        emit CloseSale(msg.sender, saleIndexes[msg.sender] - 1);
    }

    function burnLp(address _dao, uint256 _id) external {

        require(factory.containsDao(_dao), "LaunchpadModule: only for DAOs");

        IERC20Upgradeable lp = IERC20Upgradeable(IDao(_dao).lp());

        require(
            lp.approve(address(privateExitModule), lp.balanceOf(address(this)))
        );

        require(privateExitModule.privateExit(_dao, _id));
    }

    function buy(address _dao, uint256 _currencyAmount) external {

        uint256 saleIndex = saleIndexes[_dao];

        require(
            !bought[_dao][saleIndex][msg.sender],
            "LaunchpadModule: already bought"
        );

        Sale storage sale = sales[_dao][saleIndex];

        if (sale.isFinite) {
            require(
                block.timestamp <= sale.endTimestamp,
                "LaunchpadModule: sale is over"
            );
        }

        uint256 currencyAmount;

        if (sale.isAllocation) {
            currencyAmount = sale.allocations[msg.sender];
        } else {
            currencyAmount = _currencyAmount;
        }

        if (sale.isLimitedTotalSaleAmount) {
            require(
                totalBought[_dao][saleIndex] + currencyAmount <=
                    sale.totalSaleAmount,
                "LaunchpadModule: limit exceeded"
            );
        }

        if (sale.isWhitelist) {
            require(
                sale.whitelist.contains(msg.sender),
                "LaunchpadModule: the buyer is not whitelisted"
            );
        }

        bought[_dao][saleIndex][msg.sender] = true;

        totalBought[_dao][saleIndex] += currencyAmount;

        IERC20Upgradeable(sale.currency).safeTransferFrom(
            msg.sender,
            _dao,
            currencyAmount
        );

        uint256 lpAmount = (currencyAmount * 1 ether) / sale.rate;

        IERC20Upgradeable(IDao(_dao).lp()).safeTransfer(msg.sender, lpAmount);

        emit Buy(_dao, saleIndex, msg.sender, currencyAmount, lpAmount);
    }

    struct SaleInfo {
        address currency;
        uint256 rate;
        bool isFinite;
        bool isLimitedTotalSaleAmount;
        bool isWhitelist;
        bool isAllocation;
        uint256 endTimestamp;
        uint256 totalSaleAmount;
        address[] whitelist;
        uint256[] allocations;
    }

    function getSaleInfo(address _dao, uint256 _saleIndex)
        external
        view
        returns (SaleInfo memory)
    {

        Sale storage sale = sales[_dao][_saleIndex];

        address[] memory whitelist = sale.whitelist.values();

        uint256[] memory allocations = new uint256[](whitelist.length);

        for (uint256 i = 0; i < allocations.length; i++) {
            allocations[i] = sale.allocations[whitelist[i]];
        }

        return
            SaleInfo({
                currency: sale.currency,
                rate: sale.rate,
                isFinite: sale.isFinite,
                isLimitedTotalSaleAmount: sale.isLimitedTotalSaleAmount,
                isWhitelist: sale.isWhitelist,
                isAllocation: sale.isAllocation,
                endTimestamp: sale.endTimestamp,
                totalSaleAmount: sale.totalSaleAmount,
                whitelist: whitelist,
                allocations: allocations
            });
    }
}