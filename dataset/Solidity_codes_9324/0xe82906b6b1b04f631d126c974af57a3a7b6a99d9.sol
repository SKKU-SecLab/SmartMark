
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity ^0.8.0;

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
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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
pragma solidity >=0.6.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


library SafeERC20 {
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
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// Business Source License 1.1 see LICENSE.txt
pragma solidity ^0.8.0;


library UniERC20 {
    using SafeERC20 for ERC20;

    function isETH(ERC20 token) internal pure returns (bool) {
        return (address(token) == address(0));
    }

    function uniCheckAllowance(ERC20 token, uint256 amount, address owner, address spender) internal view returns (bool) {
        if(isETH(token)){
            return msg.value==amount;
        } else {
            return token.allowance(owner, spender) >= amount;
        }
    }

    function uniBalanceOf(ERC20 token, address account) internal view returns (uint256) {
        if (isETH(token)) {
            return account.balance-msg.value;
        } else {
            return token.balanceOf(account);
        }
    }

    function uniTransfer(ERC20 token, address to, uint256 amount) internal {
        if (amount > 0) {
            if (isETH(token)) {
                (bool success, ) = payable(to).call{value: amount}("");
                require(success, "Transfer failed.");
            } else {
                token.safeTransfer(to, amount);
            }
        }
    }

    function uniTransferFromSender(ERC20 token, uint256 amount, address sendTo) internal {
        if (amount > 0) {
            if (isETH(token)) {
                require(msg.value == amount, "Incorrect value");
                payable(sendTo).transfer(msg.value);
            } else {
                token.safeTransferFrom(msg.sender, sendTo, amount);
            }
        }
    }
}// Business Source License 1.1 see LICENSE.txt
pragma solidity ^0.8.0;

library Sqrt {
    function sqrt(uint256 y, uint256 x) internal pure returns (uint256) {
        unchecked {
            uint256 z = y;
            while (x < z) {
                z = x;
                x = (y / x + x) >> 1;
            }
            return z;
        }
    }

    function sqrt(uint256 y) internal pure returns (uint256) {
        unchecked {
            uint256 x = y / 6e17;
            if(y <= 37e34){
                x = y/2 +1;
            }
            return sqrt(y,x); 
        }
    }
}// MIT

pragma solidity ^0.8.0;

library SafeCast {
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// Business Source License 1.1 see LICENSE.txt
pragma solidity ^0.8.0;


library SafeAggregatorInterface {
    using SafeCast for int256;

    uint256 constant ONE_DAY_IN_SECONDS = 86400;

    function safeUnsignedLatest(AggregatorV3Interface oracle) internal view returns (uint256) {
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) = oracle.latestRoundData();
        require((roundId==answeredInRound) && (updatedAt+ONE_DAY_IN_SECONDS > block.timestamp), "Oracle out of date");
        return answer.toUint256();
    }
}// Business Source License 1.1 see LICENSE.txt
pragma solidity ^0.8.0;


interface ApprovalInterface {
    function approveSwap(address recipient) external view returns (bool);
    function approveDeposit(address depositor, uint nDays) external view returns (bool);
}// Business Source License 1.1 see LICENSE.txt
pragma solidity ^0.8.0;






contract ClipperExchangeInterface is ReentrancyGuard, Ownable {
    using Sqrt for uint256;
    using UniERC20 for ERC20;
    using SafeAggregatorInterface for AggregatorV3Interface;

    ClipperPool public theExchange;
    ApprovalInterface public approvalContract;

    uint256 public swapFee;
    uint256 constant MAXIMUM_SWAP_FEE = 500;
    uint256 constant ONE_IN_DEFAULT_DECIMALS_DIVIDED_BY_ONE_HUNDRED_SQUARED = 1e14;
    uint256 constant ONE_IN_TEN_DECIMALS = 1e10;
    uint256 constant ONE_HUNDRED_PERCENT_IN_BPS = 1e4;
    uint256 constant ONE_BASIS_POINT_IN_TEN_DECIMALS = 1e6;

    address constant MATCHA_ETH_SIGIL = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    address constant CLIPPER_ETH_SIGIL = address(0);
    address immutable myAddress;

    event Swapped(
        address inAsset,
        address outAsset,
        address recipient,
        uint256 inAmount,
        uint256 outAmount,
        bytes auxiliaryData
    );

    event SwapFeeModified(
        uint256 swapFee
    );

    modifier poolOwnerOnly() {
        require(msg.sender == theExchange.owner(), "Clipper: Only owner");
        _;
    }


    constructor(ApprovalInterface initialApprovalContract, uint256 initialSwapFee) {
        require(initialSwapFee < MAXIMUM_SWAP_FEE, "Clipper: Maximum swap fee exceeded");
        approvalContract = initialApprovalContract;
        swapFee = initialSwapFee;
        myAddress = address(this);
    }

    function setPoolAddress(address payable poolAddress) external onlyOwner {
        theExchange = ClipperPool(poolAddress);
        renounceOwnership();
    }

    function modifyApprovalContract(ApprovalInterface newApprovalContract) external poolOwnerOnly {
        approvalContract = newApprovalContract;
    }

    function modifySwapFee(uint256 newSwapFee) external poolOwnerOnly {
        require(newSwapFee < MAXIMUM_SWAP_FEE, "Clipper: Maximum swap fee exceeded");
        swapFee = newSwapFee;
        emit SwapFeeModified(newSwapFee);
    }

    function invariant() public view returns (uint256) {
        (uint256 balance, uint256 M, uint256 marketWeight) = theExchange.findBalanceAndMultiplier(ERC20(CLIPPER_ETH_SIGIL));
        uint256 cumulant = (M*balance).sqrt()/marketWeight;
        uint i;
        uint n = theExchange.nTokens();
        while(i < n){
            ERC20 the_token = ERC20(theExchange.tokenAt(i));
            (balance, M, marketWeight) = theExchange.findBalanceAndMultiplier(the_token);
            cumulant = cumulant + (M*balance).sqrt()/marketWeight;
            i++;
        }
        return (cumulant*cumulant)/ONE_IN_DEFAULT_DECIMALS_DIVIDED_BY_ONE_HUNDRED_SQUARED;
    }

    function invariantSwap(uint256 x, uint256 y, uint256 M, uint256 N, uint256 a, uint256 marketWeightX, uint256 marketWeightY) internal pure returns(uint256) {
        uint256 Ma = M*a;
        uint256 Mx = M*x;
        uint256 rMax = (Ma+Mx).sqrt();
        uint256 rMx = Mx.sqrt(rMax+1);
        uint256 rNy = (N*y).sqrt();
        uint256 X2 = marketWeightX*marketWeightX;
        uint256 XY = marketWeightX*marketWeightY;
        uint256 Y2 = marketWeightY*marketWeightY;

        if(rMax*marketWeightY >= (rNy*marketWeightX+rMx*marketWeightY)) {
            return y;
        } else {
            return (2*((XY*rNy*(rMax-rMx)) + Y2*(rMx*rMax-Mx)) - Y2*Ma)/(N*X2);
        }
    }

    function calculateSwapAmount(ERC20 inputToken, ERC20 outputToken, uint256 totalInputToken) public view returns(uint256 outputAmount, uint256 inputAmount) {
        (uint256 x, uint256 y, uint256 M, uint256 N, uint256 weightX, uint256 weightY) = theExchange.balancesAndMultipliers(inputToken, outputToken);
        inputAmount = totalInputToken-x;
        uint256 b = invariantSwap(x, y, M, N, inputAmount, weightX, weightY);
        outputAmount = b-((b*swapFee)/10000);
    }

    function unifiedSwap(ERC20 _input, ERC20 _output, address recipient, uint256 totalInputToken, uint256 minBuyAmount, bytes calldata auxiliaryData) internal returns (uint256 boughtAmount) {
        require(address(this)==myAddress && approvalContract.approveSwap(recipient), "Clipper: Recipient not approved");
        uint256 inputTokenAmount;
        (boughtAmount, inputTokenAmount) = calculateSwapAmount(_input, _output, totalInputToken);
        require(boughtAmount >= minBuyAmount, "Clipper: Not enough output");
        
        theExchange.syncAndTransfer(_input, _output, recipient, boughtAmount);
        
        emit Swapped(address(_input), address(_output), recipient, inputTokenAmount, boughtAmount, auxiliaryData);
    }

    
    function getSellQuote(address inputToken, address outputToken, uint256 sellAmount) external view returns (uint256 outputTokenAmount){
        ERC20 _input = ERC20(inputToken==MATCHA_ETH_SIGIL ? CLIPPER_ETH_SIGIL : inputToken);
        ERC20 _output = ERC20(outputToken==MATCHA_ETH_SIGIL ? CLIPPER_ETH_SIGIL : outputToken);
        (outputTokenAmount, ) = calculateSwapAmount(_input, _output, sellAmount+theExchange.lastBalance(_input));
    }

    function sellTokenForToken(address inputToken, address outputToken, address recipient, uint256 minBuyAmount, bytes calldata auxiliaryData) external returns (uint256 boughtAmount) {
        ERC20 _input = ERC20(inputToken);
        ERC20 _output = ERC20(outputToken);
        
        uint256 inputTokenAmount = _input.balanceOf(address(theExchange));
        boughtAmount = unifiedSwap(_input, _output, recipient, inputTokenAmount, minBuyAmount, auxiliaryData);
    }

    function sellEthForToken(address outputToken, address recipient, uint256 minBuyAmount, bytes calldata auxiliaryData) external payable returns (uint256 boughtAmount){
        ERC20 _input = ERC20(CLIPPER_ETH_SIGIL);
        ERC20 _output = ERC20(outputToken);
        _input.uniTransferFromSender(msg.value, address(theExchange));
        uint256 inputETHAmount = address(theExchange).balance;
        boughtAmount = unifiedSwap(_input, _output, recipient, inputETHAmount, minBuyAmount, auxiliaryData);
    }

    function sellTokenForEth(address inputToken, address payable recipient, uint256 minBuyAmount, bytes calldata auxiliaryData) external returns (uint256 boughtAmount){
        ERC20 _input = ERC20(inputToken);
        uint256 inputTokenAmount = _input.balanceOf(address(theExchange));
        boughtAmount = unifiedSwap(_input, ERC20(CLIPPER_ETH_SIGIL), recipient, inputTokenAmount, minBuyAmount, auxiliaryData);
    }


    function withdrawInto(uint256 amount, ERC20 outputToken, uint256 outputTokenAmount) external nonReentrant {
        require(theExchange.isTradable(outputToken) && outputTokenAmount > 0, "Clipper: Unsupported withdrawal");
        theExchange.sync(outputToken);
        uint256 initialFullyDilutedSupply = theExchange.fullyDilutedSupply();
        uint256 beforeWithdrawalInvariant = invariant();

        theExchange.swapBurn(msg.sender, amount);
        
        theExchange.transferAsset(outputToken, msg.sender, outputTokenAmount);
        uint256 afterWithdrawalInvariant = invariant();


        uint256 tokenFractionBurned = (ONE_IN_TEN_DECIMALS*amount)/initialFullyDilutedSupply;
        uint256 invariantFractionBurned = (ONE_IN_TEN_DECIMALS*(beforeWithdrawalInvariant-afterWithdrawalInvariant))/beforeWithdrawalInvariant;
        uint256 feeFraction = (tokenFractionBurned*swapFee*ONE_BASIS_POINT_IN_TEN_DECIMALS)/ONE_IN_TEN_DECIMALS;
        require(tokenFractionBurned >= (invariantFractionBurned+feeFraction), "Too much taken");
        emit Swapped(address(theExchange), address(outputToken), msg.sender, amount, outputTokenAmount, "");
    }

    function _withdraw(uint256 myFraction, uint256 theFee) internal {
        ERC20 the_token;
        uint256 toTransfer;
        uint256 fee;

        uint i;
        uint n = theExchange.nTokens();
        while(i < n) {
            the_token = ERC20(theExchange.tokenAt(i));
            toTransfer = (myFraction*the_token.uniBalanceOf(address(theExchange))) / ONE_IN_TEN_DECIMALS;
            fee = (toTransfer*theFee)/ONE_HUNDRED_PERCENT_IN_BPS;
            theExchange.transferAsset(the_token, msg.sender, toTransfer-fee);
            i++;
        }
        the_token = ERC20(CLIPPER_ETH_SIGIL);
        toTransfer = (myFraction*the_token.uniBalanceOf(address(theExchange))) / ONE_IN_TEN_DECIMALS;
        fee = (toTransfer*theFee)/ONE_HUNDRED_PERCENT_IN_BPS;
        theExchange.transferAsset(the_token, msg.sender, toTransfer-fee);
    }

    function withdrawAll() external nonReentrant {
        theExchange.swapBurn(msg.sender, theExchange.fullyDilutedSupply());
        _withdraw(ONE_IN_TEN_DECIMALS, 0);
    }

    function withdraw(uint256 amount) external nonReentrant {
        uint256 myFraction = (amount*ONE_IN_TEN_DECIMALS)/theExchange.fullyDilutedSupply();
        require(myFraction > 1, "Clipper: Not enough to withdraw");

        theExchange.swapBurn(msg.sender, amount);
        _withdraw(myFraction, swapFee);
    }
}// Business Source License 1.1 see LICENSE.txt
pragma solidity ^0.8.0;



contract ClipperEscapeContract {
    using UniERC20 for ERC20;

    ClipperPool theExchange;

    constructor() {
        theExchange = ClipperPool(payable(msg.sender));
    }

    receive() external payable {
    }

    function transfer(ERC20 token, address to, uint256 amount) external {
        require(msg.sender == theExchange.owner(), "Only Clipper Owner");
        token.uniTransfer(to, amount);
    }
}// Business Source License 1.1 see LICENSE.txt
pragma solidity ^0.8.0;




contract ClipperDeposit is ReentrancyGuard {
    using UniERC20 for ERC20;
    ClipperPool theExchange;

    constructor() {
        theExchange = ClipperPool(payable(msg.sender));
    }

    struct Deposit {
        uint lockedUntil;
        uint256 poolTokenAmount;
    }

    event Deposited(
        address indexed account,
        uint256 amount
    );

    mapping(address => Deposit) public deposits;

    function hasDeposit(address theAddress) internal view returns (bool) {
        return deposits[theAddress].lockedUntil > 0;
    }

    function canUnlockDeposit(address theAddress) public view returns (bool) {
        Deposit storage myDeposit = deposits[theAddress];
        return hasDeposit(theAddress) && (myDeposit.poolTokenAmount > 0) && (myDeposit.lockedUntil <= block.timestamp);
    }

    function unlockVestedDeposit() public nonReentrant returns (uint256 numTokens) {
        require(canUnlockDeposit(msg.sender), "Deposit cannot be unlocked");
        numTokens = deposits[msg.sender].poolTokenAmount;
        delete deposits[msg.sender];
        theExchange.recordUnlockedDeposit(msg.sender, numTokens);
    }

    function deposit(uint nDays) external nonReentrant returns(uint256 newTokensToMint) {
        require((nDays < 2000) && ClipperExchangeInterface(theExchange.exchangeInterfaceContract()).approvalContract().approveDeposit(msg.sender, nDays), "Clipper: Deposit rejected");
        uint256 beforeDepositInvariant = theExchange.exchangeInterfaceContract().invariant();
        uint256 initialFullyDilutedSupply = theExchange.fullyDilutedSupply();

        theExchange.syncAll();

        uint256 afterDepositInvariant = theExchange.exchangeInterfaceContract().invariant();

        newTokensToMint = (afterDepositInvariant*initialFullyDilutedSupply)/beforeDepositInvariant - initialFullyDilutedSupply;

        require(newTokensToMint > 0, "Deposit not large enough");

        theExchange.recordDeposit(newTokensToMint);

        if(nDays == 0 && !hasDeposit(msg.sender)){
            theExchange.recordUnlockedDeposit(msg.sender, newTokensToMint);
        } else {
            Deposit storage curDeposit = deposits[msg.sender];
            uint lockDepositUntil = block.timestamp + (nDays*86400);
            Deposit memory myDeposit = Deposit({
                                            lockedUntil: curDeposit.lockedUntil > lockDepositUntil ? curDeposit.lockedUntil : lockDepositUntil,
                                            poolTokenAmount: newTokensToMint+curDeposit.poolTokenAmount
                                        });
            deposits[msg.sender] = myDeposit;
        }
        emit Deposited(msg.sender, newTokensToMint);        
    }

}// Business Source License 1.1 see LICENSE.txt
pragma solidity ^0.8.0;






contract ClipperPool is ERC20, ReentrancyGuard, Ownable {
    using Sqrt for uint256;
    using UniERC20 for ERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeAggregatorInterface for AggregatorV3Interface;

    address constant CLIPPER_ETH_SIGIL = address(0);

    uint256 public fullyDilutedSupply;

    address public depositContract;
    address public escapeContract;

    address public triage;
    
    ClipperExchangeInterface public exchangeInterfaceContract;

    uint constant FIVE_DAYS_IN_SECONDS = 432000;
    uint256 constant MAXIMUM_MINT_IN_FIVE_DAYS_BASIS_POINTS = 500;
    uint lastMint;

    struct Asset {
        AggregatorV3Interface oracle; // Chainlink oracle interface
        uint256 marketShare; // Where 100 in market share is equal to ETH in pool weight. Higher numbers = Less of a share.
        uint256 marketShareDecimalsAdjusted;
        uint256 lastBalance; // last recorded balance (for deposit / swap / sync modality)
        uint removalTime; // time at which we can remove this asset (0 by default, meaning can't remove it)
    }

    mapping(ERC20 => Asset) assets;
    
    EnumerableSet.AddressSet private assetSet;

    uint256 lastETHBalance;
    AggregatorV3Interface public ethOracle;
    uint256 private ethMarketShareDecimalsAdjusted;

    uint256 constant DEFAULT_DECIMALS = 18;
    uint256 constant ETH_MARKET_WEIGHT = 100;
    uint256 constant WEI_PER_ETH = 1e18;
    uint256 constant ETH_WEIGHT_DECIMALS_ADJUSTED = 1e20;
    
    event UnlockedDeposit(
        address indexed account,
        uint256 amount
    );

    event TokenRemovalActivated(
        address token,
        uint timestamp
    );

    event TokenModified(
        address token,
        uint256 marketShare,
        address oracle
    );

    event ContractModified(
        address newContract,
        bytes contractType
    );

    modifier triageOrOwnerOnly() {
        require(msg.sender==this.owner() || msg.sender==triage, "Clipper: Only owner or triage");
        _;
    }

    modifier depositContractOnly() {
        require(msg.sender==depositContract, "Clipper: Deposit contract only");
        _;
    }

    modifier exchangeContractOnly() {
        require(msg.sender==address(exchangeInterfaceContract), "Clipper: Exchange contract only");
        _;
    }

    modifier depositOrExchangeContractOnly() {
        require(msg.sender==address(exchangeInterfaceContract) || msg.sender==depositContract, "Clipper: Deposit or Exchange Only");
        _;
    }

    constructor(ClipperExchangeInterface initialExchangeInterface) payable ERC20("Clipper Pool Token", "CLPRPL") {
        require(msg.value > 0, "Clipper: Must deposit ETH");
        
        _mint(msg.sender, msg.value*10);
        lastETHBalance = msg.value;
        fullyDilutedSupply = totalSupply();
        
        exchangeInterfaceContract = initialExchangeInterface;

        depositContract = address(new ClipperDeposit());
        escapeContract = address(new ClipperEscapeContract());
    }

    receive() external payable {
    }

    function nTokens() public view returns (uint) {
        return assetSet.length();
    }

    function tokenAt(uint i) public view returns (address) {
        return assetSet.at(i);
    } 


    function isToken(ERC20 token) public view returns (bool) {
        return assetSet.contains(address(token));
    }

    function isTradable(ERC20 token) public view returns (bool) {
        return token.isETH() || isToken(token);
    }

    function lastBalance(ERC20 token) public view returns (uint256) {
        return token.isETH() ? lastETHBalance : assets[token].lastBalance;
    }

    function upsertAsset(ERC20 token, AggregatorV3Interface oracle, uint256 rawMarketShare) external onlyOwner {
        require(rawMarketShare > 0, "Clipper: Market share must be positive");



        uint256 sumDecimals = token.decimals()+oracle.decimals();
        uint256 marketShareDecimalsAdjusted = rawMarketShare*WEI_PER_ETH;
        if(sumDecimals < 2*DEFAULT_DECIMALS){
            marketShareDecimalsAdjusted = marketShareDecimalsAdjusted*(10**(2*DEFAULT_DECIMALS-sumDecimals));
        } else if(sumDecimals > 2*DEFAULT_DECIMALS){
            marketShareDecimalsAdjusted = marketShareDecimalsAdjusted/(10**(sumDecimals-2*DEFAULT_DECIMALS));
        }

        assetSet.add(address(token));
        assets[token] = Asset(oracle, rawMarketShare, marketShareDecimalsAdjusted, token.balanceOf(address(this)), 0);
        
        emit TokenModified(address(token), rawMarketShare, address(oracle));  
    }

    function getOracle(ERC20 token) public view returns (AggregatorV3Interface) {
        if(token.isETH()){
            return ethOracle;
        } else{
            return assets[token].oracle;
        }
    }

    function getMarketShare(ERC20 token) public view returns (uint256) {
        if(token.isETH()){
            return ETH_MARKET_WEIGHT;
        } else {
            return assets[token].marketShare;
        }
    }

    function activateRemoval(ERC20 token) external onlyOwner {
        require(isToken(token), "Clipper: Asset not present");
        assets[token].removalTime = block.timestamp + FIVE_DAYS_IN_SECONDS;
        emit TokenRemovalActivated(address(token), assets[token].removalTime);
    }

    function clearRemoval(ERC20 token) external triageOrOwnerOnly {
        require(isToken(token), "Clipper: Asset not present");
        delete assets[token].removalTime;
    }

    function removeToken(ERC20 token) external onlyOwner {
        require(isToken(token), "Clipper: Asset not present");
        require(assets[token].removalTime > 0 && (assets[token].removalTime < block.timestamp), "Not ready");
        assetSet.remove(address(token));
        delete assets[token];
    }

    function escape(ERC20 token) external onlyOwner {
        require(!isTradable(token) || (assetSet.length()==0 && address(token)==CLIPPER_ETH_SIGIL), "Can only escape nontradable");
        token.uniTransfer(escapeContract, token.uniBalanceOf(address(this)));
    }

    function modifyExchangeInterfaceContract(address newContract) external onlyOwner {
        exchangeInterfaceContract = ClipperExchangeInterface(newContract);
        emit ContractModified(newContract, "exchangeInterfaceContract modified");
    }

    function modifyDepositContract(address newContract) external onlyOwner {
        depositContract = newContract;
        emit ContractModified(newContract, "depositContract modified");
    }

    function modifyTriage(address newTriageAddress) external onlyOwner {
        triage = newTriageAddress;
        emit ContractModified(newTriageAddress, "triage address modified");
    }

    function modifyEthOracle(AggregatorV3Interface newOracle) external onlyOwner {
        if(address(newOracle)==address(0)){
            delete ethOracle;
            ethMarketShareDecimalsAdjusted=ETH_WEIGHT_DECIMALS_ADJUSTED;
        } else {
            uint256 sumDecimals = DEFAULT_DECIMALS+newOracle.decimals();
            ethMarketShareDecimalsAdjusted = ETH_WEIGHT_DECIMALS_ADJUSTED;
            if(sumDecimals < 2*DEFAULT_DECIMALS){
                ethMarketShareDecimalsAdjusted = ethMarketShareDecimalsAdjusted*(10**(2*DEFAULT_DECIMALS-sumDecimals));
            } else if(sumDecimals > 2*DEFAULT_DECIMALS){
                ethMarketShareDecimalsAdjusted = ethMarketShareDecimalsAdjusted/(10**(sumDecimals-2*DEFAULT_DECIMALS));
            }
            ethOracle = newOracle;
        }
        emit TokenModified(CLIPPER_ETH_SIGIL, ETH_MARKET_WEIGHT, address(newOracle));
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(block.timestamp > lastMint+FIVE_DAYS_IN_SECONDS, "Clipper: Pool token can mint once in 5 days");
        require(amount < (MAXIMUM_MINT_IN_FIVE_DAYS_BASIS_POINTS*fullyDilutedSupply)/1e4, "Clipper: Mint amount exceeded");
        _mint(to, amount);
        fullyDilutedSupply = fullyDilutedSupply+amount;
        lastMint = block.timestamp;
    }

    function balancesAndMultipliers(ERC20 inputToken, ERC20 outputToken) external view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        require(isTradable(inputToken) && isTradable(outputToken), "Clipper: Untradable asset(s)");
        (uint256 x, uint256 M, uint256 marketWeightX) = findBalanceAndMultiplier(inputToken);
        (uint256 y, uint256 N, uint256 marketWeightY) = findBalanceAndMultiplier(outputToken);

        return (x,y,M,N,marketWeightX,marketWeightY);
    }

    function findBalanceAndMultiplier(ERC20 token) public view returns(uint256 balance, uint256 M, uint256 marketWeight){
        if(token.isETH()){
            balance = lastETHBalance;
            marketWeight = ETH_MARKET_WEIGHT;
            if(address(ethOracle)==address(0)){
                M = WEI_PER_ETH;
            } else {
                uint256 weiPerInput = ethOracle.safeUnsignedLatest();
                M = (ethMarketShareDecimalsAdjusted*weiPerInput)/ETH_WEIGHT_DECIMALS_ADJUSTED;
            }
        } else {
            Asset memory the_asset = assets[token];
            uint256 weiPerInput = the_asset.oracle.safeUnsignedLatest();
            marketWeight = the_asset.marketShare;
            uint256 marketWeightDecimals = the_asset.marketShareDecimalsAdjusted;
            balance = the_asset.lastBalance;
            M = (marketWeightDecimals*weiPerInput)/ETH_WEIGHT_DECIMALS_ADJUSTED;
        }
    }

    function _sync(ERC20 token) internal {
        if(token.isETH()){
            lastETHBalance = address(this).balance;
        } else {
            assets[token].lastBalance = token.balanceOf(address(this));
        }
    }

    function recordDeposit(uint256 amount) external depositContractOnly {
        fullyDilutedSupply = fullyDilutedSupply+amount;
    }

    function recordUnlockedDeposit(address depositor, uint256 amount) external depositContractOnly {
        _mint(depositor, amount);
        emit UnlockedDeposit(depositor, amount);
    }

    function syncAll() external depositOrExchangeContractOnly {
        _sync(ERC20(CLIPPER_ETH_SIGIL));
        uint i;
        while(i < assetSet.length()) {
            _sync(ERC20(assetSet.at(i)));
            i++;
        }
    }

    function sync(ERC20 token) external depositOrExchangeContractOnly {
        _sync(token);
    }

    function transferAsset(ERC20 token, address recipient, uint256 amount) external nonReentrant exchangeContractOnly {
        token.uniTransfer(recipient, amount);
        _sync(token);
    }

    function syncAndTransfer(ERC20 inputToken, ERC20 outputToken, address recipient, uint256 amount) external nonReentrant exchangeContractOnly {
        _sync(inputToken);
        outputToken.uniTransfer(recipient, amount);
        _sync(outputToken);
    }

    function swapBurn(address burner, uint256 amount) external exchangeContractOnly {
        _burn(burner, amount);
        fullyDilutedSupply = fullyDilutedSupply-amount;
    }

    function getSellQuote(address inputToken, address outputToken, uint256 sellAmount) external view returns (uint256 outputTokenAmount){
        outputTokenAmount=exchangeInterfaceContract.getSellQuote(inputToken, outputToken, sellAmount);
    }
    function sellTokenForToken(address inputToken, address outputToken, address recipient, uint256 minBuyAmount, bytes calldata auxiliaryData) external returns (uint256 boughtAmount) {
        boughtAmount = exchangeInterfaceContract.sellTokenForToken(inputToken, outputToken, recipient, minBuyAmount, auxiliaryData);
    }

    function sellEthForToken(address outputToken, address recipient, uint256 minBuyAmount, bytes calldata auxiliaryData) external payable returns (uint256 boughtAmount){
        boughtAmount=exchangeInterfaceContract.sellEthForToken(outputToken, recipient, minBuyAmount, auxiliaryData);
    }
    function sellTokenForEth(address inputToken, address payable recipient, uint256 minBuyAmount, bytes calldata auxiliaryData) external returns (uint256 boughtAmount){
        boughtAmount=exchangeInterfaceContract.sellTokenForEth(inputToken, recipient, minBuyAmount, auxiliaryData);
    }
}