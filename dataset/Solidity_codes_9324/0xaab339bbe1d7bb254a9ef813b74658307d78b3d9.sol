

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
}


pragma solidity ^0.6.0;

library EnumerableSet {


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


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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
}


pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.6.0;



contract ERC165UpgradeSafe is Initializable, IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;


    function __ERC165_init() internal initializer {

        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {



        _registerInterface(_INTERFACE_ID_ERC165);

    }


    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }

    uint256[49] private __gap;
}


pragma solidity ^0.6.0;


contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


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
}


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.6.0;






contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    function __ERC20_init(string memory name, string memory symbol) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {



        _name = name;
        _symbol = symbol;
        _decimals = 18;

    }


    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }


    uint256[44] private __gap;
}


pragma solidity ^0.6.2;

library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    function supportsERC165(address account) internal view returns (bool) {

        return _supportsERC165Interface(account, _INTERFACE_ID_ERC165) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        (bool success, bool result) = _callERC165SupportsInterface(account, interfaceId);

        return (success && result);
    }

    function _callERC165SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool, bool)
    {

        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_ERC165, interfaceId);
        (bool success, bytes memory result) = account.staticcall{ gas: 30000 }(encodedParams);
        if (result.length < 32) return (false, false);
        return (success, abi.decode(result, (bool)));
    }
}



pragma solidity ^0.6.0;



interface IConsumable is IERC165, IERC20 {

  struct ConsumableAmount {
    IConsumable consumable;
    uint256 amount;
  }



  function myBalance() external view returns (uint256);


  function myAllowance(address owner) external view returns (uint256);



}



pragma solidity ^0.6.0;



library ConsumableInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant CONSUMABLE_INTERFACE_ID = 0x0d6673db;

  function supportsConsumableInterface(IConsumable account) internal view returns (bool) {

    return address(account).supportsInterface(CONSUMABLE_INTERFACE_ID);
  }
}



pragma solidity ^0.6.0;


interface IBaseContract is IERC165 {

  function contractName() external view returns (string memory);


  function contractDescription() external view returns (string memory);


  function contractUri() external view returns (string memory);

}



pragma solidity ^0.6.0;



library BaseContractInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant BASE_CONTRACT_INTERFACE_ID = 0x321f350b;

  function supportsBaseContractInterface(IBaseContract account) internal view returns (bool) {

    return address(account).supportsInterface(BASE_CONTRACT_INTERFACE_ID);
  }
}



pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;




contract BaseContract is Initializable, IBaseContract, ERC165UpgradeSafe {

  struct ContractInfo {
    string name;
    string description;
    string uri;
  }

  ContractInfo private _info;

  function _initializeBaseContract(ContractInfo memory info) internal initializer {

    __ERC165_init();
    _registerInterface(BaseContractInterfaceSupport.BASE_CONTRACT_INTERFACE_ID);

    _info = info;
  }

  function contractName() external override view returns (string memory) {

    return _info.name;
  }

  function contractDescription() external override view returns (string memory) {

    return _info.description;
  }

  function contractUri() external override view returns (string memory) {

    return _info.uri;
  }

  uint256[50] private ______gap;
}



pragma solidity ^0.6.0;

interface IDisableable {

  event Disabled();

  event Enabled();

  function disabled() external view returns (bool);


  function enabled() external view returns (bool);


  modifier onlyEnabled() virtual {

    require(!this.disabled(), 'Contract is disabled');
    _;
  }

  function disable() external;


  function enable() external;

}



pragma solidity ^0.6.0;


abstract contract Disableable is IDisableable {
  bool private _disabled;

  function disabled() external override view returns (bool) {
    return _disabled;
  }

  function enabled() external override view returns (bool) {
    return !_disabled;
  }

  function _disable() internal {
    if (_disabled) {
      return;
    }

    _disabled = true;
    emit Disabled();
  }

  function _enable() internal {
    if (!_disabled) {
      return;
    }

    _disabled = false;
    emit Enabled();
  }

  uint256[50] private ______gap;
}



pragma solidity ^0.6.0;


library TransferringInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant TRANSFERRING_INTERFACE_ID = 0x6fafa3a8;

  function supportsTransferInterface(address account) internal view returns (bool) {

    return account.supportsInterface(TRANSFERRING_INTERFACE_ID);
  }
}


pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}


pragma solidity ^0.6.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}



pragma solidity ^0.6.0;





interface ITransferring is IERC165, IERC721Receiver {

  function transferToken(
    IERC20 token,
    uint256 amount,
    address recipient
  ) external;


  function transferItem(
    IERC721 artifact,
    uint256 itemId,
    address recipient
  ) external;

}



pragma solidity ^0.6.0;


interface IConvertibleConsumable is IConsumable {

  function exchangeToken() external view returns (IERC20);


  function asymmetricalExchangeRate() external view returns (bool);


  function intrinsicValueExchangeRate() external view returns (uint256);


  function purchasePriceExchangeRate() external view returns (uint256);


  function amountExchangeTokenAvailable() external view returns (uint256);


  function mintByExchange(uint256 consumableAmount) external;


  function amountExchangeTokenNeeded(uint256 consumableAmount) external view returns (uint256);


  function burnByExchange(uint256 consumableAmount) external;


  function amountExchangeTokenProvided(uint256 consumableAmount) external view returns (uint256);

}



pragma solidity ^0.6.0;



library ConvertibleConsumableInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant CONVERTIBLE_CONSUMABLE_INTERFACE_ID = 0x1574139e;

  function supportsConvertibleConsumableInterface(IConvertibleConsumable consumable) internal view returns (bool) {

    return address(consumable).supportsInterface(CONVERTIBLE_CONSUMABLE_INTERFACE_ID);
  }

  function calcConvertibleConsumableInterfaceId(IConvertibleConsumable consumable) internal pure returns (bytes4) {

    return
      consumable.exchangeToken.selector ^
      consumable.asymmetricalExchangeRate.selector ^
      consumable.intrinsicValueExchangeRate.selector ^
      consumable.purchasePriceExchangeRate.selector ^
      consumable.amountExchangeTokenAvailable.selector ^
      consumable.mintByExchange.selector ^
      consumable.amountExchangeTokenNeeded.selector ^
      consumable.burnByExchange.selector ^
      consumable.amountExchangeTokenProvided.selector;
  }
}



pragma solidity ^0.6.0;






library TransferLogic {

  using ConvertibleConsumableInterfaceSupport for IConvertibleConsumable;

  function transferToken(
    address, /*account*/
    IERC20 token,
    uint256 amount,
    address recipient
  ) internal {

    token.transfer(recipient, amount);
  }

  function transferTokenWithExchange(
    address account,
    IERC20 token,
    uint256 amount,
    address recipient
  ) internal {

    uint256 myBalance = token.balanceOf(account);
    if (myBalance < amount && IConvertibleConsumable(address(token)).supportsConvertibleConsumableInterface()) {
      IConvertibleConsumable convertibleConsumable = IConvertibleConsumable(address(token));

      uint256 amountConsumableNeeded = amount - myBalance; // safe since we checked < above
      uint256 amountExchangeToken = convertibleConsumable.amountExchangeTokenNeeded(amountConsumableNeeded);

      ERC20UpgradeSafe exchange = ERC20UpgradeSafe(address(convertibleConsumable.exchangeToken()));
      exchange.increaseAllowance(address(token), amountExchangeToken);
    }

    token.transfer(recipient, amount);
  }

  function transferItem(
    address account,
    IERC721 artifact,
    uint256 itemId,
    address recipient
  ) internal {

    artifact.safeTransferFrom(account, recipient, itemId);
  }

  function onERC721Received(
    address, /*operator*/
    address, /*from*/
    uint256, /*tokenId*/
    bytes memory /*data*/
  ) internal pure returns (bytes4) {

    return IERC721Receiver.onERC721Received.selector;
  }
}



pragma solidity ^0.6.0;










abstract contract Consumable is
  IDisableable,
  Initializable,
  ITransferring,
  ContextUpgradeSafe,
  IConsumable,
  ERC165UpgradeSafe,
  BaseContract,
  ERC20UpgradeSafe
{
  using TransferLogic for address;

  function _initializeConsumable(ContractInfo memory info, string memory symbol) internal initializer {
    _initializeBaseContract(info);
    _registerInterface(ConsumableInterfaceSupport.CONSUMABLE_INTERFACE_ID);

    __ERC20_init(info.name, symbol);
    _registerInterface(TransferringInterfaceSupport.TRANSFERRING_INTERFACE_ID);
  }

  function myBalance() external override view returns (uint256) {
    return balanceOf(_msgSender());
  }

  function myAllowance(address owner) external override view returns (uint256) {
    return allowance(owner, _msgSender());
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual override onlyEnabled {
    super._transfer(sender, recipient, amount);
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external virtual override returns (bytes4) {
    return TransferLogic.onERC721Received(operator, from, tokenId, data);
  }

  uint256[50] private ______gap;
}



pragma solidity ^0.6.0;



interface IConsumableExchange is IConsumable {

  struct ExchangeRate {
    uint256 purchasePrice;
    uint256 intrinsicValue;
  }

  event ExchangeRateChanged(
    IConvertibleConsumable indexed token,
    uint256 indexed purchasePriceExchangeRate,
    uint256 indexed intrinsicValueExchangeRate
  );

  function totalConvertibles() external view returns (uint256);


  function convertibleAt(uint256 index) external view returns (IConvertibleConsumable);


  function isConvertible(IConvertibleConsumable token) external view returns (bool);


  function exchangeRateOf(IConvertibleConsumable token) external view returns (ExchangeRate memory);


  function exchangeTo(IConvertibleConsumable tokenAddress, uint256 amount) external;


  function exchangeFrom(IConvertibleConsumable token, uint256 tokenAmount) external;


  function registerToken(uint256 purchasePriceExchangeRate, uint256 intrinsicValueExchangeRate) external;

}



pragma solidity ^0.6.0;



library ConsumableExchangeInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant CONSUMABLE_EXCHANGE_INTERFACE_ID = 0x1e34ecc8;

  function supportsConsumableExchangeInterface(IConsumableExchange exchange) internal view returns (bool) {

    return address(exchange).supportsInterface(CONSUMABLE_EXCHANGE_INTERFACE_ID);
  }

  function calcConsumableExchangeInterfaceId(IConsumableExchange exchange) internal pure returns (bytes4) {

    return
      exchange.totalConvertibles.selector ^
      exchange.convertibleAt.selector ^
      exchange.isConvertible.selector ^
      exchange.exchangeRateOf.selector ^
      exchange.exchangeTo.selector ^
      exchange.exchangeFrom.selector ^
      exchange.registerToken.selector;
  }
}



pragma solidity ^0.6.0;





library ConsumableConversionMath {

  using SafeMath for uint256;
  using ConvertibleConsumableInterfaceSupport for IConvertibleConsumable;

  function exchangeTokenNeeded(IConsumable.ConsumableAmount memory consumableAmount) internal view returns (uint256) {

    IConvertibleConsumable consumable = IConvertibleConsumable(address(consumableAmount.consumable));
    require(
      consumable.supportsConvertibleConsumableInterface(),
      'ConsumableConversionMath: consumable not convertible'
    );

    uint256 purchasePriceExchangeRate = consumable.purchasePriceExchangeRate();
    return exchangeTokenNeeded(consumableAmount.amount, purchasePriceExchangeRate);
  }

  function exchangeTokenProvided(IConsumable.ConsumableAmount memory consumableAmount) internal view returns (uint256) {

    IConvertibleConsumable consumable = IConvertibleConsumable(address(consumableAmount.consumable));
    require(
      consumable.supportsConvertibleConsumableInterface(),
      'ConsumableConversionMath: consumable not convertible'
    );

    uint256 intrinsicValueExchangeRate = consumable.intrinsicValueExchangeRate();
    return exchangeTokenProvided(consumableAmount.amount, intrinsicValueExchangeRate);
  }

  function exchangeTokenNeeded(uint256 consumableAmount, uint256 purchasePriceExchangeRate)
    internal
    pure
    returns (uint256)
  {

    return _toExchangeToken(consumableAmount, purchasePriceExchangeRate, true);
  }

  function exchangeTokenProvided(uint256 consumableAmount, uint256 intrinsicValueExchangeRate)
    internal
    pure
    returns (uint256)
  {

    return _toExchangeToken(consumableAmount, intrinsicValueExchangeRate, false);
  }

  function _toExchangeToken(
    uint256 consumableAmount,
    uint256 exchangeRate,
    bool purchasing
  ) private pure returns (uint256) {

    uint256 amountExchangeToken = consumableAmount.div(exchangeRate);
    if (purchasing && consumableAmount.mod(exchangeRate) != 0) {
      amountExchangeToken += 1;
    }
    return amountExchangeToken;
  }

  function convertibleTokenNeeded(uint256 exchangeTokenAmount, uint256 intrinsicValueExchangeRate)
    internal
    pure
    returns (uint256)
  {

    return _fromExchangeToken(exchangeTokenAmount, intrinsicValueExchangeRate);
  }

  function convertibleTokenProvided(uint256 exchangeTokenAmount, uint256 purchasePriceExchangeRate)
    internal
    pure
    returns (uint256)
  {

    return _fromExchangeToken(exchangeTokenAmount, purchasePriceExchangeRate);
  }

  function _fromExchangeToken(uint256 exchangeTokenAmount, uint256 exchangeRate) private pure returns (uint256) {

    return exchangeTokenAmount.mul(exchangeRate);
  }

  function exchangeTokenNeeded(IConsumableExchange exchange, IConsumable.ConsumableAmount[] memory consumableAmounts)
    internal
    view
    returns (uint256)
  {

    return _toExchangeToken(exchange, consumableAmounts, true);
  }

  function exchangeTokenProvided(IConsumableExchange exchange, IConsumable.ConsumableAmount[] memory consumableAmounts)
    internal
    view
    returns (uint256)
  {

    return _toExchangeToken(exchange, consumableAmounts, false);
  }

  function _toExchangeToken(
    IConsumableExchange exchange,
    IConsumable.ConsumableAmount[] memory consumableAmounts,
    bool purchasing
  ) private view returns (uint256) {

    uint256 totalAmount = 0;

    for (uint256 consumableIndex = 0; consumableIndex < consumableAmounts.length; consumableIndex++) {
      IConsumable.ConsumableAmount memory consumableAmount = consumableAmounts[consumableIndex];
      IConsumable consumable = consumableAmount.consumable;
      IConvertibleConsumable convertibleConsumable = IConvertibleConsumable(address(consumable));
      uint256 amount = consumableAmount.amount;

      require(
        exchange.isConvertible(convertibleConsumable),
        'ConsumableConversionMath: Consumable must be convertible by exchange'
      );

      IConsumableExchange.ExchangeRate memory exchangeRate = exchange.exchangeRateOf(convertibleConsumable);
      uint256 exchangeAmount;
      if (purchasing) {
        exchangeAmount = _toExchangeToken(amount, exchangeRate.purchasePrice, true);
      } else {
        exchangeAmount = _toExchangeToken(amount, exchangeRate.intrinsicValue, false);
      }

      totalAmount = totalAmount.add(exchangeAmount);
    }

    return totalAmount;
  }
}



pragma solidity ^0.6.0;








abstract contract ConsumableExchange is IConsumableExchange, Consumable {
  using EnumerableSet for EnumerableSet.AddressSet;
  using ConsumableConversionMath for uint256;
  using SafeMath for uint256;

  mapping(address => ExchangeRate) private _exchangeRates;
  EnumerableSet.AddressSet private _convertibles;

  function _initializeConsumableExchange(ContractInfo memory info, string memory symbol) internal initializer {
    _initializeConsumable(info, symbol);
    _registerInterface(ConsumableExchangeInterfaceSupport.CONSUMABLE_EXCHANGE_INTERFACE_ID);
  }

  function totalConvertibles() external override view returns (uint256) {
    return _convertibles.length();
  }

  function convertibleAt(uint256 index) external override view returns (IConvertibleConsumable) {
    return IConvertibleConsumable(_convertibles.at(index));
  }

  function isConvertible(IConvertibleConsumable token) external override view returns (bool) {
    return _exchangeRates[address(token)].purchasePrice > 0;
  }

  function exchangeRateOf(IConvertibleConsumable token) external override view returns (ExchangeRate memory) {
    return _exchangeRates[address(token)];
  }

  function exchangeTo(IConvertibleConsumable token, uint256 tokenAmount) external override {
    _exchangeTo(_msgSender(), token, tokenAmount);
  }

  function _exchangeTo(
    address account,
    IConvertibleConsumable consumable,
    uint256 amount
  ) internal onlyEnabled {
    ExchangeRate memory exchangeRate = _exchangeRates[address(consumable)];

    require(exchangeRate.purchasePrice != 0, 'ConsumableExchange: consumable is not convertible');

    uint256 tokenAmount = amount.convertibleTokenProvided(exchangeRate.purchasePrice);

    _transfer(account, address(this), amount);
    this.increaseAllowance(address(consumable), amount);

    consumable.mintByExchange(tokenAmount);

    ERC20UpgradeSafe token = ERC20UpgradeSafe(address(consumable));
    token.increaseAllowance(account, tokenAmount);
  }

  function exchangeFrom(IConvertibleConsumable token, uint256 tokenAmount) external override {
    _exchangeFrom(_msgSender(), token, tokenAmount);
  }

  function _exchangeFrom(
    address account,
    IConvertibleConsumable token,
    uint256 tokenAmount
  ) internal onlyEnabled {
    ExchangeRate memory exchangeRate = _exchangeRates[address(token)];

    require(exchangeRate.intrinsicValue != 0, 'ConsumableExchange: token is not convertible');

    token.transferFrom(account, address(this), tokenAmount);

    token.burnByExchange(tokenAmount);

    uint256 myAmount = tokenAmount.exchangeTokenProvided(exchangeRate.intrinsicValue);
    this.transferFrom(address(token), address(this), myAmount);

    _transfer(address(this), account, myAmount);
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual override onlyEnabled {
    super._transfer(sender, recipient, amount);

    ExchangeRate memory senderExchangeRate = _exchangeRates[sender];
    if (senderExchangeRate.intrinsicValue != 0) {
      uint256 senderBalance = balanceOf(sender);
      uint256 tokenAmountAllowed = senderBalance.convertibleTokenProvided(senderExchangeRate.intrinsicValue);

      IERC20 token = IERC20(sender);
      require(token.totalSupply() <= tokenAmountAllowed, 'ConsumableExchange: not enough left to cover exchange');
    }
  }

  function registerToken(uint256 purchasePriceExchangeRate, uint256 intrinsicValueExchangeRate) external override {
    IConvertibleConsumable token = IConvertibleConsumable(_msgSender());
    require(purchasePriceExchangeRate > 0, 'ConsumableExchange: must register with a purchase price exchange rate');
    require(intrinsicValueExchangeRate > 0, 'ConsumableExchange: must register with an intrinsic value exchange rate');
    require(
      _exchangeRates[address(token)].purchasePrice == 0,
      'ConsumableExchange: cannot register already registered token'
    );

    _updateExchangeRate(
      token,
      ExchangeRate({ purchasePrice: purchasePriceExchangeRate, intrinsicValue: intrinsicValueExchangeRate })
    );
  }

  function _updateExchangeRate(IConvertibleConsumable token, ExchangeRate memory exchangeRate) internal onlyEnabled {
    require(token != IConvertibleConsumable(0), 'ConsumableExchange: updateExchangeRate for the zero address');

    if (exchangeRate.purchasePrice != 0 && exchangeRate.intrinsicValue != 0) {
      _convertibles.add(address(token));
    } else {
      _convertibles.remove(address(token));
    }

    _exchangeRates[address(token)] = exchangeRate;
    emit ExchangeRateChanged(token, exchangeRate.purchasePrice, exchangeRate.intrinsicValue);
  }

  uint256[50] private ______gap;
}



pragma solidity ^0.6.0;







abstract contract ConvertibleConsumable is IConvertibleConsumable, Consumable {
  using SafeMath for uint256;
  using ConsumableConversionMath for uint256;

  IERC20 private _exchangeToken;

  uint256 private _purchasePriceExchangeRate;

  uint256 private _intrinsicValueExchangeRate;

  function _initializeConvertibleConsumable(
    ContractInfo memory info,
    string memory symbol,
    IERC20 exchangeToken,
    uint256 purchasePriceExchangeRate,
    uint256 intrinsicValueExchangeRate,
    bool registerWithExchange
  ) internal initializer {
    _initializeConsumable(info, symbol);
    _registerInterface(ConvertibleConsumableInterfaceSupport.CONVERTIBLE_CONSUMABLE_INTERFACE_ID);

    require(purchasePriceExchangeRate > 0, 'ConvertibleConsumable: purchase price exchange rate must be > 0');
    require(intrinsicValueExchangeRate > 0, 'ConvertibleConsumable: intrinsic value exchange rate must be > 0');
    require(
      purchasePriceExchangeRate <= intrinsicValueExchangeRate,
      'ConvertibleConsumable: purchase price exchange must be <= intrinsic value exchange rate'
    );


    _exchangeToken = exchangeToken;
    _purchasePriceExchangeRate = purchasePriceExchangeRate;
    _intrinsicValueExchangeRate = intrinsicValueExchangeRate;

    if (registerWithExchange) {
      _registerWithExchange();
    }
  }

  function exchangeToken() external override view returns (IERC20) {
    return _exchangeToken;
  }

  function asymmetricalExchangeRate() external override view returns (bool) {
    return _purchasePriceExchangeRate != _intrinsicValueExchangeRate;
  }

  function purchasePriceExchangeRate() external override view returns (uint256) {
    return _purchasePriceExchangeRate;
  }

  function intrinsicValueExchangeRate() external override view returns (uint256) {
    return _intrinsicValueExchangeRate;
  }

  function amountExchangeTokenAvailable() external override view returns (uint256) {
    uint256 amountNeeded = totalSupply().exchangeTokenNeeded(_intrinsicValueExchangeRate);
    uint256 amountExchangeToken = _exchangeToken.balanceOf(address(this));
    if (amountNeeded >= amountExchangeToken) {
      return 0;
    }
    return amountExchangeToken - amountNeeded;
  }

  function _registerWithExchange() internal onlyEnabled {
    IConsumableExchange consumableExchange = IConsumableExchange(address(_exchangeToken));
    consumableExchange.registerToken(_purchasePriceExchangeRate, _intrinsicValueExchangeRate);
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual override onlyEnabled {
    _exchangeIfNeeded(sender, amount);

    super._transfer(sender, recipient, amount);
  }

  function _exchangeIfNeeded(address sender, uint256 consumableAmount) internal onlyEnabled {
    uint256 senderBalance = this.balanceOf(sender);
    if (senderBalance < consumableAmount) {
      uint256 consumableAmountNeeded = consumableAmount - senderBalance;

      _mintByExchange(sender, consumableAmountNeeded);
    }
  }

  function mintByExchange(uint256 consumableAmount) external override {
    _mintByExchange(_msgSender(), consumableAmount);
  }

  function _mintByExchange(address account, uint256 consumableAmount) internal onlyEnabled {
    uint256 amountExchangeToken = this.amountExchangeTokenNeeded(consumableAmount);

    _exchangeToken.transferFrom(account, address(this), amountExchangeToken);

    _mint(account, consumableAmount);
  }

  function amountExchangeTokenNeeded(uint256 consumableAmount) external override view returns (uint256) {
    return consumableAmount.exchangeTokenNeeded(_purchasePriceExchangeRate);
  }

  function _mint(address account, uint256 amount) internal virtual override {
    super._mint(account, amount);

    uint256 amountNeeded = totalSupply().exchangeTokenNeeded(_intrinsicValueExchangeRate);
    uint256 amountExchangeToken = _exchangeToken.balanceOf(address(this));
    require(amountExchangeToken >= amountNeeded, 'ConvertibleConsumable: Not enough exchange token available to mint');
  }

  function burnByExchange(uint256 consumableAmount) external virtual override {
    _burnByExchange(_msgSender(), consumableAmount);
  }

  function _burnByExchange(address receiver, uint256 consumableAmount) internal onlyEnabled {
    _burn(receiver, consumableAmount);

    ERC20UpgradeSafe token = ERC20UpgradeSafe(address(_exchangeToken));

    uint256 exchangeTokenAmount = this.amountExchangeTokenProvided(consumableAmount);
    token.increaseAllowance(receiver, exchangeTokenAmount);
  }

  function amountExchangeTokenProvided(uint256 consumableAmount) external override view returns (uint256) {
    return consumableAmount.exchangeTokenProvided(_intrinsicValueExchangeRate);
  }

  uint256[50] private ______gap;
}



pragma solidity ^0.6.0;

interface IRoleDelegate {

  function isInRole(bytes32 role, address account) external view returns (bool);

}



pragma solidity ^0.6.0;



library RoleDelegateInterfaceSupport {

  using ERC165Checker for address;

  bytes4 internal constant ROLE_DELEGATE_INTERFACE_ID = 0x7cef57ea;

  function supportsRoleDelegateInterface(IRoleDelegate roleDelegate) internal view returns (bool) {

    return address(roleDelegate).supportsInterface(ROLE_DELEGATE_INTERFACE_ID);
  }
}



pragma solidity ^0.6.0;

library RoleSupport {

  bytes32 public constant SUPER_ADMIN_ROLE = 0x00;
  bytes32 public constant MINTER_ROLE = keccak256('Minter');
  bytes32 public constant ADMIN_ROLE = keccak256('Admin');
  bytes32 public constant TRANSFER_AGENT_ROLE = keccak256('Transfer');
}



pragma solidity ^0.6.0;






contract DelegatingRoles is Initializable, ContextUpgradeSafe {

  using EnumerableSet for EnumerableSet.AddressSet;
  using RoleDelegateInterfaceSupport for IRoleDelegate;

  EnumerableSet.AddressSet private _roleDelegates;

  function isRoleDelegate(IRoleDelegate roleDelegate) public view returns (bool) {

    return _roleDelegates.contains(address(roleDelegate));
  }

  function _addRoleDelegate(IRoleDelegate roleDelegate) internal {

    require(address(roleDelegate) != address(0), 'Role delegate cannot be zero address');
    require(roleDelegate.supportsRoleDelegateInterface(), 'Role delegate must implement interface');

    _roleDelegates.add(address(roleDelegate));
    emit RoleDelegateAdded(roleDelegate);
  }

  function _removeRoleDelegate(IRoleDelegate roleDelegate) internal {

    _roleDelegates.remove(address(roleDelegate));
    emit RoleDelegateRemoved(roleDelegate);
  }

  function _hasRole(bytes32 role, address account) internal virtual view returns (bool) {

    uint256 roleDelegateLength = _roleDelegates.length();
    for (uint256 roleDelegateIndex = 0; roleDelegateIndex < roleDelegateLength; roleDelegateIndex++) {
      IRoleDelegate roleDelegate = IRoleDelegate(_roleDelegates.at(roleDelegateIndex));
      if (roleDelegate.isInRole(role, account)) {
        return true;
      }
    }

    return false;
  }

  modifier onlyAdmin() {

    require(isAdmin(_msgSender()), 'Caller does not have the Admin role');
    _;
  }

  function isAdmin(address account) public view returns (bool) {

    return _hasRole(RoleSupport.ADMIN_ROLE, account);
  }

  modifier onlyMinter() {

    require(isMinter(_msgSender()), 'Caller does not have the Minter role');
    _;
  }

  function isMinter(address account) public view returns (bool) {

    return _hasRole(RoleSupport.MINTER_ROLE, account);
  }

  modifier onlyTransferAgent() {

    require(isTransferAgent(_msgSender()), 'Caller does not have the Transfer Agent role');
    _;
  }

  function isTransferAgent(address account) public view returns (bool) {

    return _hasRole(RoleSupport.TRANSFER_AGENT_ROLE, account);
  }

  event RoleDelegateAdded(IRoleDelegate indexed roleDelegate);

  event RoleDelegateRemoved(IRoleDelegate indexed roleDelegate);

  uint256[50] private ______gap;
}




pragma solidity ^0.6.0;





contract Paypr is
  Initializable,
  ContextUpgradeSafe,
  ERC165UpgradeSafe,
  BaseContract,
  Consumable,
  ConvertibleConsumable,
  ConsumableExchange,
  Disableable,
  DelegatingRoles
{

  using SafeMath for uint256;
  using TransferLogic for address;

  function initializePaypr(
    IConsumableExchange baseToken,
    uint256 basePurchasePriceExchangeRate,
    uint256 baseIntrinsicValueExchangeRate,
    IRoleDelegate roleDelegate
  ) public initializer {

    ContractInfo memory info = ContractInfo({
      name: 'Paypr',
      description: 'Paypr exchange token',
      uri: 'https://paypr.money/'
    });

    string memory symbol = 'ℙ';

    _initializeConvertibleConsumable(
      info,
      symbol,
      baseToken,
      basePurchasePriceExchangeRate,
      baseIntrinsicValueExchangeRate,
      false
    );
    _initializeConsumableExchange(info, symbol);

    _addRoleDelegate(roleDelegate);
  }

  function mint(address account, uint256 amount) external onlyMinter {

    _mint(account, amount);
  }

  function _mint(address account, uint256 amount) internal override(ERC20UpgradeSafe, ConvertibleConsumable) {

    ERC20UpgradeSafe._mint(account, amount);
  }

  function burn(address account, uint256 amount) external onlyMinter {

    _burn(account, amount);
  }

  function burnByExchange(uint256 payprAmount) external override onlyEnabled onlyMinter {

    _burnByExchange(_msgSender(), payprAmount);
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal override(Consumable, ConsumableExchange, ConvertibleConsumable) onlyEnabled {

    ConvertibleConsumable._transfer(sender, recipient, amount);
  }

  function transferToken(
    IERC20 token,
    uint256 amount,
    address recipient
  ) external override onlyTransferAgent onlyEnabled {

    address(this).transferToken(token, amount, recipient);
  }

  function transferItem(
    IERC721 artifact,
    uint256 itemId,
    address recipient
  ) external override onlyTransferAgent onlyEnabled {

    address(this).transferItem(artifact, itemId, recipient);
  }

  function disable() external override onlyAdmin {

    _disable();
  }

  function enable() external override onlyAdmin {

    _enable();
  }
}