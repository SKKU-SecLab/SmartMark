
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

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity >=0.5.16;

contract Governable {

  address public governance;

  constructor(address _governance) public {
    setGovernance(_governance);
  }

  modifier onlyGovernance() {
    require((governance==address(0)) || (msg.sender==governance), "Not governance");
    _;
  }

  function setGovernance(address _governance) public onlyGovernance {
    require(_governance != address(0), "new governance shouldn't be empty");
    governance = _governance;
  }

}// MIT

pragma solidity 0.6.12;

abstract contract SwapBase {

  using Address for address;
  using SafeMath for uint256;

  uint256 public constant PRECISION_DECIMALS = 18;

  address factoryAddress;

  constructor(address _factoryAddress) public {
    require(_factoryAddress!=address(0), "Factory must be set");
    factoryAddress = _factoryAddress;
    initializeFactory();
  }

  function initializeFactory() internal virtual;

  function isPool(address token) public virtual view returns(bool);

  function getUnderlying(address token) public virtual view returns (address[] memory, uint256[] memory);

  function getLargestPool(address token, address[] memory tokenList) public virtual view returns (address, address, uint256);

  function getPriceVsToken(address token0, address token1, address poolAddress) public virtual view returns (uint256) ;

}// MIT
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
  event PairCreated(address indexed token0, address indexed token1, address pair, uint);

  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);

  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);

  function createPair(address tokenA, address tokenB) external returns (address pair);
}// MIT


pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}// MIT

pragma solidity 0.6.12;

contract UniSwap is SwapBase {

  IUniswapV2Factory uniswapFactory;

  constructor(address _factoryAddress) SwapBase(_factoryAddress) public {

  }

  function initializeFactory() internal virtual override {
    uniswapFactory = IUniswapV2Factory(factoryAddress);
  }

  function checkFactory(IUniswapV2Pair pair, address compareFactory) internal view returns (bool) {
    bool check;
    try pair.factory{gas: 3000}() returns (address factory) {
      check = (factory == compareFactory);
    } catch {
      check = false;
    }
    return check;
  }

  function isPool(address token) public virtual override view returns(bool){
    IUniswapV2Pair pair = IUniswapV2Pair(token);
    return checkFactory(pair, factoryAddress);
  }

  function getUnderlying(address token) public virtual override view returns (address[] memory, uint256[] memory){
    IUniswapV2Pair pair = IUniswapV2Pair(token);
    address[] memory tokens  = new address[](2);
    uint256[] memory amounts = new uint256[](2);
    tokens[0] = pair.token0();
    tokens[1] = pair.token1();
    uint256 token0Decimals = ERC20(tokens[0]).decimals();
    uint256 token1Decimals = ERC20(tokens[1]).decimals();
    uint256 supplyDecimals = ERC20(token).decimals();
    (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
    uint256 totalSupply = pair.totalSupply();
    if (reserve0 == 0 || reserve1 == 0 || totalSupply == 0) {
      amounts[0] = 0;
      amounts[1] = 0;
      return (tokens, amounts);
    }
    amounts[0] = reserve0*10**(supplyDecimals-token0Decimals+PRECISION_DECIMALS)/totalSupply;
    amounts[1] = reserve1*10**(supplyDecimals-token1Decimals+PRECISION_DECIMALS)/totalSupply;
    return (tokens, amounts);
  }

  function getPoolSize(address pairAddress, address token) internal view returns(uint256){
    IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
    address token0 = pair.token0();
    (uint112 poolSize0, uint112 poolSize1,) = pair.getReserves();
    uint256 poolSize = (token==token0)? poolSize0:poolSize1;
    return poolSize;
  }

  function getLargestPool(address token, address[] memory tokenList) public virtual override view returns (address, address, uint256){
    uint256 largestPoolSize = 0;
    address largestKeyToken;
    address largestPool;
    uint256 poolSize;
    uint256 i;
    for (i=0;i<tokenList.length;i++) {
      address poolAddress = uniswapFactory.getPair(token,tokenList[i]);
      poolSize = poolAddress !=address(0) ? getPoolSize(poolAddress, token) : 0;
      if (poolSize > largestPoolSize) {
        largestKeyToken = tokenList[i];
        largestPool = poolAddress;
        largestPoolSize = poolSize;
      }
    }
    return (largestKeyToken, largestPool, largestPoolSize);
  }

  function getPriceVsToken(address token0, address token1, address /*poolAddress*/) public virtual override view returns (uint256){
    address pairAddress = uniswapFactory.getPair(token0,token1);
    IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
    (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
    uint256 token0Decimals = ERC20(token0).decimals();
    uint256 token1Decimals = ERC20(token1).decimals();
    uint256 price;
    if (token0 == pair.token0()) {
      price = (reserve1*10**(token0Decimals-token1Decimals+PRECISION_DECIMALS))/reserve0;
    } else {
      price = (reserve0*10**(token0Decimals-token1Decimals+PRECISION_DECIMALS))/reserve1;
    }
    return price;
  }

}// MIT



pragma solidity 0.6.12;

contract OracleBase is Governable, Initializable  {

  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  uint256 public constant PRECISION_DECIMALS = 18;
  uint256 public constant ONE = 10**PRECISION_DECIMALS;

  bytes32 internal constant _DEFINED_OUTPUT_TOKEN_SLOT = bytes32(uint256(keccak256("eip1967.OracleBase.definedOutputToken")) - 1);

  address[] public keyTokens;

  address[] public pricingTokens;

  mapping(address => address) replacementTokens;

  address[] public swaps;

  modifier validKeyToken(address keyToken){
      require(checkKeyToken(keyToken), "Not a Key Token");
      _;
  }
  modifier validPricingToken(address pricingToken){
      require(checkPricingToken(pricingToken), "Not a Pricing Token");
      _;
  }
  modifier validSwap(address swap){
      require(checkSwap(swap), "Not a Swap");
      _;
  }

  event RegistryChanged(address newRegistry, address oldRegistry);
  event KeyTokenAdded(address newKeyToken);
  event PricingTokenAdded(address newPricingToken);
  event SwapAdded(address newSwap);
  event KeyTokenRemoved(address keyToken);
  event PricingTokenRemoved(address pricingToken);
  event SwapRemoved(address newSwap);
  event DefinedOutputChanged(address newOutputToken, address oldOutputToken);

  constructor(address[] memory _keyTokens, address[] memory _pricingTokens, address _outputToken)
  public Governable(msg.sender) {
    Governable.setGovernance(msg.sender);
  }

  function initialize(address[] memory _keyTokens, address[] memory _pricingTokens, address _outputToken)
  public onlyGovernance initializer {
    Governable.setGovernance(msg.sender);

    addKeyTokens(_keyTokens);
    addPricingTokens(_pricingTokens);
    changeDefinedOutput(_outputToken);
  }

  function addSwap(address newSwap) public onlyGovernance {
    require(!checkSwap(newSwap), "Already a swap");
    swaps.push(newSwap);
    emit SwapAdded(newSwap);
  }

  function addSwaps(address[] memory newSwaps) public onlyGovernance {
    for(uint i=0; i<newSwaps.length; i++) {
      if (!checkSwap(newSwaps[i])) addSwap(newSwaps[i]);
    }
  }
  function setSwaps(address[] memory newSwaps) external onlyGovernance {
    delete swaps;
    addSwaps(newSwaps);
  }

  function addKeyToken(address newToken) public onlyGovernance {
    require(!checkKeyToken(newToken), "Already a key token");
    keyTokens.push(newToken);
    emit KeyTokenAdded(newToken);
  }

  function addKeyTokens(address[] memory newTokens) public onlyGovernance {
    for(uint i=0; i<newTokens.length; i++) {
      if (!checkKeyToken(newTokens[i])) addKeyToken(newTokens[i]);
    }
  }

  function addPricingToken(address newToken) public onlyGovernance validKeyToken(newToken) {
    require(!checkPricingToken(newToken), "Already a pricing token");
    pricingTokens.push(newToken);
    emit PricingTokenAdded(newToken);
  }

  function addPricingTokens(address[] memory newTokens) public onlyGovernance {
    for(uint i=0; i<newTokens.length; i++) {
      if (!checkPricingToken(newTokens[i])) addPricingToken(newTokens[i]);
    }
  }

  function removeAddressFromArray(address adr, address[] storage array) internal {
    uint i;
    for (i=0; i<array.length; i++) {
      if (adr == array[i]) break;
    }

    while (i<array.length-1) {
      array[i] = array[i+1];
      i++;
    }
    array.pop();
  }

  function removeKeyToken(address keyToken) external onlyGovernance validKeyToken(keyToken) {
    removeAddressFromArray(keyToken, keyTokens);
    emit KeyTokenRemoved(keyToken);

    if (checkPricingToken(keyToken)) {
      removePricingToken(keyToken);
    }
  }

  function removePricingToken(address pricingToken) public onlyGovernance validPricingToken(pricingToken) {
    removeAddressFromArray(pricingToken, pricingTokens );
    emit PricingTokenRemoved(pricingToken);
  }

  function removeSwap(address swap) public onlyGovernance validSwap(swap) {
    removeAddressFromArray(swap, swaps);
    emit SwapRemoved(swap);
  }

  function definedOutputToken() public view returns (address value) {
    bytes32 slot = _DEFINED_OUTPUT_TOKEN_SLOT;
    assembly {
      value := sload(slot)
    }
  }

  function changeDefinedOutput(address newOutputToken) public onlyGovernance validKeyToken(newOutputToken) {
    require(newOutputToken != address(0), "zero address");
    address oldOutputToken = definedOutputToken();
    bytes32 slot = _DEFINED_OUTPUT_TOKEN_SLOT;
    assembly {
      sstore(slot, newOutputToken)
    }
    emit DefinedOutputChanged(newOutputToken, oldOutputToken);
  }

  function modifyReplacementTokens(address _inputToken, address _replacementToken) external onlyGovernance {
    replacementTokens[_inputToken] = _replacementToken;
  }

  function getPrice(address token) external view returns (uint256) {
    if (token == definedOutputToken())
      return (ONE);

    if (replacementTokens[token] != address(0)) {
      token = replacementTokens[token];
    }

    uint256 tokenPrice;
    uint256 tokenValue;
    uint256 price = 0;
    uint256 i;
    address swap = getSwapForPool(token);
    if (swap!=address(0)) {
      (address[] memory tokens, uint256[] memory amounts) = SwapBase(swap).getUnderlying(token);
      for (i=0;i<tokens.length;i++) {
        if (tokens[i] == address(0)) break;
        tokenPrice = computePrice(tokens[i]);
        if (tokenPrice == 0) return 0;
        tokenValue = tokenPrice *amounts[i]/ONE;
        price += tokenValue;
      }
      return price;
    } else {
      return computePrice(token);
    }
  }

  function getSwapForPool(address token) public view returns(address) {
    for (uint i=0; i<swaps.length; i++ ) {
      if (SwapBase(swaps[i]).isPool(token)) {
        return swaps[i];
      }
    }
    return address(0);
  }

  function computePrice(address token) public view returns (uint256) {
    uint256 price;
    if (token == definedOutputToken()) {
      price = ONE;
    } else if (token == address(0)) {
      price = 0;
    } else {
      (address swap, address keyToken, address pool) = getLargestPool(token,keyTokens);
      uint256 priceVsKeyToken;
      uint256 keyTokenPrice;
      if (keyToken == address(0)) {
        price = 0;
      } else {
        priceVsKeyToken = SwapBase(swap).getPriceVsToken(token,keyToken,pool);
        keyTokenPrice = getKeyTokenPrice(keyToken);
        price = priceVsKeyToken*keyTokenPrice/ONE;
      }
    }
    return (price);
  }

  function getLargestPool(address token) public view returns (address, address, address) {
    return getLargestPool(token, keyTokens);
  }

  function getLargestPool(address token, address[] memory keyTokenList) public view returns (address, address, address) {
    address largestKeyToken = address(0);
    address largestPool = address(0);
    uint largestPoolSize = 0;
    SwapBase largestSwap;
    for (uint i=0;i<swaps.length;i++) {
      SwapBase swap = SwapBase(swaps[i]);
      (address swapLargestKeyToken, address swapLargestPool, uint swapLargestPoolSize) = swap.getLargestPool(token, keyTokenList);
      if (swapLargestPoolSize>largestPoolSize) {
        largestSwap = swap;
        largestKeyToken = swapLargestKeyToken;
        largestPool = swapLargestPool;
        largestPoolSize = swapLargestPoolSize;
      }
    }
    return (address(largestSwap), largestKeyToken, largestPool);
  }

  function getKeyTokenPrice(address token) internal view returns (uint256) {
    bool isPricingToken = checkPricingToken(token);
    uint256 price;
    uint256 priceVsPricingToken;
    if (token == definedOutputToken()) {
      price = ONE;
    } else if (isPricingToken) {
      price = SwapBase(swaps[0]).getPriceVsToken(token, definedOutputToken(), address(0)); // first swap is used
    } else {
      uint256 pricingTokenPrice;
      (address swap, address pricingToken, address pricingPool) = getLargestPool(token,pricingTokens);
      priceVsPricingToken = SwapBase(swap).getPriceVsToken(token, pricingToken, pricingPool);
      pricingTokenPrice = (pricingToken == definedOutputToken())? ONE : SwapBase(swaps[0]).getPriceVsToken(pricingToken,definedOutputToken(),pricingPool);
      price = priceVsPricingToken*pricingTokenPrice/ONE;
    }
    return price;
  }

  function addressInArray(address adr, address[] storage array) internal view returns (bool) {
    for (uint i=0; i<array.length; i++)
      if (adr == array[i]) return true;

    return false;
  }

  function checkPricingToken(address token) public view returns (bool) {
    return addressInArray(token, pricingTokens);
  }

  function checkKeyToken(address token) public view returns (bool) {
    return addressInArray(token, keyTokens);
  }

  function checkSwap(address swap) public view returns (bool) {
    return addressInArray(swap, swaps);
  }
}