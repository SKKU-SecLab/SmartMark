


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
}



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
}



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
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



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

}



pragma solidity >=0.6.0 <0.8.0;

interface IERC20Permit {
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}



pragma solidity >=0.6.0 <0.8.0;

library ECDSA {
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}



pragma solidity >=0.6.0 <0.8.0;


library Counters {
    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract EIP712 {
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    constructor(string memory name, string memory version) internal {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = _getChainId();
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view virtual returns (bytes32) {
        if (_getChainId() == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                _getChainId(),
                address(this)
            )
        );
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
    }

    function _getChainId() private view returns (uint256 chainId) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        assembly {
            chainId := chainid()
        }
    }
}



pragma solidity >=0.6.5 <0.8.0;






abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping (address => Counters.Counter) private _nonces;

    bytes32 private immutable _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor(string memory name) internal EIP712(name, "1") {
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _nonces[owner].current(),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _nonces[owner].increment();
        _approve(owner, spender, value);
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}


pragma solidity ^0.6.0;


interface IFlashBorrower {
    function onFlashLoan(
        address sender,
        IERC20 token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external;
}

interface IBentoBoxV1 {

    function balanceOf(IERC20, address) external view returns (uint256);

    function deposit(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external payable returns (uint256 amountOut, uint256 shareOut);

    function flashLoan(
        IFlashBorrower borrower,
        address receiver,
        IERC20 token,
        uint256 amount,
        bytes calldata data
    ) external;


    function toAmount(
        IERC20 token,
        uint256 share,
        bool roundUp
    ) external view returns (uint256 amount);

    function toShare(
        IERC20 token,
        uint256 amount,
        bool roundUp
    ) external view returns (uint256 share);

    function transfer(
        IERC20 token,
        address from,
        address to,
        uint256 share
    ) external;

    function withdraw(
        IERC20 token_,
        address from,
        address to,
        uint256 amount,
        uint256 share
    ) external returns (uint256 amountOut, uint256 shareOut);
}


pragma solidity ^0.6.0;


library BoringMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a - b) <= a, "BoringMath: Underflow");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
    }

    function to128(uint256 a) internal pure returns (uint128 c) {
        require(a <= uint128(-1), "BoringMath: uint128 Overflow");
        c = uint128(a);
    }

    function to64(uint256 a) internal pure returns (uint64 c) {
        require(a <= uint64(-1), "BoringMath: uint64 Overflow");
        c = uint64(a);
    }

    function to32(uint256 a) internal pure returns (uint32 c) {
        require(a <= uint32(-1), "BoringMath: uint32 Overflow");
        c = uint32(a);
    }
}

library BoringMath128 {
    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {
        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {
        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

struct Rebase {
    uint128 elastic;
    uint128 base;
}

library RebaseLibrary {
    using BoringMath for uint256;
    using BoringMath128 for uint128;

    function toBase(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (uint256 base) {
        if (total.elastic == 0) {
            base = elastic;
        } else {
            base = elastic.mul(total.base) / total.elastic;
            if (roundUp && base.mul(total.elastic) / total.base < elastic) {
                base = base.add(1);
            }
        }
    }

    function toElastic(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (uint256 elastic) {
        if (total.base == 0) {
            elastic = base;
        } else {
            elastic = base.mul(total.elastic) / total.base;
            if (roundUp && elastic.mul(total.base) / total.elastic < base) {
                elastic = elastic.add(1);
            }
        }
    }

    function add(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 base) {
        base = toBase(total, elastic, roundUp);
        total.elastic = total.elastic.add(elastic.to128());
        total.base = total.base.add(base.to128());
        return (total, base);
    }

    function sub(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 elastic) {
        elastic = toElastic(total, base, roundUp);
        total.elastic = total.elastic.sub(elastic.to128());
        total.base = total.base.sub(base.to128());
        return (total, elastic);
    }

    function add(
        Rebase memory total,
        uint256 elastic,
        uint256 base
    ) internal pure returns (Rebase memory) {
        total.elastic = total.elastic.add(elastic.to128());
        total.base = total.base.add(base.to128());
        return total;
    }

    function sub(
        Rebase memory total,
        uint256 elastic,
        uint256 base
    ) internal pure returns (Rebase memory) {
        total.elastic = total.elastic.sub(elastic.to128());
        total.base = total.base.sub(base.to128());
        return total;
    }

    function addElastic(Rebase storage total, uint256 elastic) internal returns (uint256 newElastic) {
        newElastic = total.elastic = total.elastic.add(elastic.to128());
    }

    function subElastic(Rebase storage total, uint256 elastic) internal returns (uint256 newElastic) {
        newElastic = total.elastic = total.elastic.sub(elastic.to128());
    }
}

interface ICauldron {
    function cook(
        uint8[] calldata actions,
        uint256[] calldata values,
        bytes[] calldata datas
    ) external payable returns (uint256 value1, uint256 value2);

    function repay(
        address to,
        bool skim,
        uint256 part
    ) external returns (uint256 amount);

    function borrow(address to, uint256 amount) external returns (uint256 part, uint256 share);    

    function removeCollateral(address to, uint256 share) external;

    function addCollateral(
        address to,
        bool skim,
        uint256 share
    ) external;

    function updateExchangeRate() external returns (bool updated, uint256 rate);     

    function accrue() external;


    function userCollateralShare(address) external view returns(uint256);
    function userBorrowPart(address) external view returns(uint256);


    function bentoBox() external view returns (IBentoBoxV1);

    function magicInternetMoney() external view returns (IERC20);

    function totalBorrow() external view returns (Rebase memory); // elastic = Total token amount to be repayed by borrowers, base = Total parts of the debt held by borrowers

}


pragma solidity ^0.6.0;

interface IYearnVault {
    function pricePerShare() external view returns (uint256 price);
    function deposit() external returns (uint256 shares);
    function withdraw(uint256 shares) external returns (uint256 amount);
    function decimals() external view returns (uint256);
}


pragma solidity ^0.6.0;

interface ILendingPoolAddressesProvider {
  function getAddress(bytes32 id) external view returns (address);

  function getLendingPool() external view returns (address);
}


pragma solidity ^0.6.0;

interface ILendingPool {

  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;

}


pragma solidity ^0.6.0;

interface ICurvePool {
    
    function get_dy_underlying(int128 i, int128 j, uint256 dx) external view returns (uint256);

    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint256);
    
}


pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;










interface ITERC20{

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external;
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

contract Patronus is ERC20Permit, Ownable, IFlashBorrower {

    using RebaseLibrary for Rebase;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public WITHDRAWAL_FEES = 50; // 0.5%
    uint256 public COLLATERAL_RATIO = 8950; // 89.5%
    uint256 public BASIS_POINT = 10000; 
    uint256 public AAVE_FLASHLOAN_FEE = 9; // 0.09%

    address public asset; // USDC

    address public collateral; // yvUSDC

    address public mim;

    ICauldron public cauldron;

    ILendingPoolAddressesProvider public addressesProvider;

    ICurvePool public metapool;

    IBentoBoxV1 public bentoBox;

    constructor(
        address asset_, 
        address collateral_, 
        address cauldron_,
        address addressesProvider_,
        address metapool_
        ) public 
            ERC20Permit("pUSDT")
            ERC20("Patronus USDT", "pUSDT")
        {
        asset = asset_;
        collateral = collateral_;
        cauldron = ICauldron(cauldron_);
        addressesProvider = ILendingPoolAddressesProvider(addressesProvider_);
        metapool = ICurvePool(metapool_);
        bentoBox = cauldron.bentoBox();
        mim = address(cauldron.magicInternetMoney());
        IERC20(mim).approve(metapool_, uint256(-1));
        ITERC20(asset).approve(metapool_, uint256(-1));
        IERC20(mim).approve(address(bentoBox), uint256(-1));
        IERC20(collateral).approve(address(bentoBox), uint256(-1));
        ITERC20(asset).approve(collateral, uint256(-1));
    }

    function depositToBentobox(address token, uint256 amount, address to) internal returns (uint256 share) {


        (, share) = bentoBox.deposit(IERC20(token), address(this), to, amount, 0);

    }

    function withdrawFromBentobox(address token, uint256 amount) internal returns (uint256 share) {

        share = bentoBox.toShare(IERC20(token), amount, false);

        bentoBox.withdraw(IERC20(token), address(this), address(this), amount, share);        
    }

    function _addToPosition(uint256 amount) internal {


        uint256 yShare = IYearnVault(collateral).deposit();


        depositToBentobox(collateral, yShare, address(cauldron));

        cauldron.addCollateral(address(this), true, yShare);

        uint256 borrowAmount = amount.mul(1e12).mul(COLLATERAL_RATIO).div(BASIS_POINT);

        (, uint256 share) = cauldron.borrow(address(this), borrowAmount);

        bentoBox.withdraw(IERC20(mim), address(this), address(this), borrowAmount, share);

    }


    function getSharesToMint(uint256 diff) internal view returns (uint256) {

        if(totalSupply() == 0){
            return diff;
        }

        return diff.mul(totalSupply()).div(totalBalance().sub(diff));
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    )
        external
        returns (bool)
    {

        require(initiator == address(this), "!invalid");

        (address user, uint256 amount) = abi.decode(params, (address, uint256));


        cauldron.updateExchangeRate();

        uint256 preBalance = totalBalance();

        require(IERC20(asset).balanceOf(address(this)) >= amounts[0], "Invalid flashloan");

        _addToPosition(amounts[0]);



        uint256 amountOwing = amounts[0].add(premiums[0]);

        {
            uint256 min_dy = amountOwing.sub(amount);

            uint256 dy_get = metapool.get_dy_underlying(0, 3, IERC20(mim).balanceOf(address(this)));

            require(dy_get >= min_dy, "Not enough amount being received from curve");

            uint256 amountReceived = metapool.exchange_underlying(0, 3, IERC20(mim).balanceOf(address(this)), min_dy);

            if(amountOwing > amountReceived){
                IERC20(asset).safeTransferFrom(user, address(this), amountOwing.sub(amountReceived));
            }
        }

        ITERC20(asset).approve(addressesProvider.getLendingPool(), amountOwing);

        uint256 postBalance = totalBalance();
        uint256 diff = postBalance.sub(preBalance);
        uint256 shareAmount = getSharesToMint(diff);

        _mint(user, shareAmount);
        
        return true;
    }


    function pricePerShare() public view returns(uint256 sharePrice)  {

        if(totalSupply() == 0){
            return 0;
        }

        sharePrice = totalBalance().mul(1e18).div(totalSupply());

    }


    function totalBalance() public view returns(uint256) {

        if(cauldron.userCollateralShare(address(this)) == 0){
            return 0;
        }

        uint256 collateralValue = cauldron.userCollateralShare(address(this)).mul(IYearnVault(collateral).pricePerShare());
        
        Rebase memory totalBorrow = cauldron.totalBorrow();
        uint256 debtValue = totalBorrow.toElastic(cauldron.userBorrowPart(address(this)), true);
        

        collateralValue = collateralValue.mul(1e12).div(10**IYearnVault(collateral).decimals());

        return collateralValue.sub(debtValue);
    }

    function deposit(uint256 amount, uint256 leveragedAmount) external {

        address receiverAddress = address(this);

        address[] memory assets = new address[](1);
        assets[0] = asset; // USDC


        uint256[] memory amounts = new uint256[](1);
        amounts[0] = leveragedAmount;
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        address onBehalfOf = address(this);
        bytes memory params = abi.encode(address(msg.sender), amount);
        uint16 referralCode = 0;

        ILendingPool(addressesProvider.getLendingPool()).flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );

    }


    function flashloanAmount(uint256 amount) public view returns (uint256 netAmount) {

        if(amount == 0){
            return 0;
        }
        netAmount = amount.mul(COLLATERAL_RATIO).div(BASIS_POINT.sub(COLLATERAL_RATIO));


        while(true){

            uint256 amountToSwap = netAmount.mul(1e12).mul(COLLATERAL_RATIO).div(BASIS_POINT);          
            uint256 amountBack = metapool.get_dy_underlying(0, 3, amountToSwap);
            uint256 amountRequired = netAmount.add(netAmount.mul(AAVE_FLASHLOAN_FEE).div(BASIS_POINT)).sub(amount);
            
            if(amountBack < amountRequired){
                netAmount = netAmount.sub(amountRequired.sub(amountBack));
            }

            if(amountBack >= amountRequired){
                break;
            }

        }
    }

    function withdraw(uint256 amount) external {

        require(balanceOf(msg.sender) >= amount, "!not enough shares");
        cauldron.accrue();
        uint256 borrowPart = cauldron.userBorrowPart(address(this)).mul(amount).div(totalSupply());

        (, uint256 repayAmount) = cauldron.totalBorrow().sub(borrowPart, true);
        
        uint256 share = bentoBox.toShare(IERC20(mim), repayAmount, true);
        
        repayAmount = bentoBox.toAmount(IERC20(mim), share, true);

        bytes memory params = abi.encode(msg.sender, amount, borrowPart, share);
        
        bentoBox.flashLoan(IFlashBorrower(address(this)), address(this), IERC20(mim), repayAmount, params);

    }


    function onFlashLoan(
        address sender,
        IERC20 token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override {

        require(address(this) == sender, "!invalid flash loan");

        (address user, uint256 shareAmount, uint256 borrowPart, uint256 share) = abi.decode(data, (address, uint256, uint256, uint256));

        bentoBox.deposit(IERC20(mim), address(this), address(bentoBox), amount, share);

        cauldron.repay(address(this), true, borrowPart);

        uint256 collateralShare = cauldron.userCollateralShare(address(this)).mul(shareAmount).div(totalSupply());

        cauldron.removeCollateral(address(this), collateralShare);

        bentoBox.withdraw(IERC20(collateral), address(this), address(this), 0, collateralShare);

        IYearnVault(collateral).withdraw(IERC20(collateral).balanceOf(address(this)));

        metapool.exchange_underlying(3, 0, IERC20(asset).balanceOf(address(this)), amount.add(fee));

        uint256 extraMIM = IERC20(mim).balanceOf(address(this)).sub(amount.add(fee));

        uint256 withdrawalAmount = metapool.exchange_underlying(0, 3, extraMIM, 0);

        uint256 adminFees = withdrawalAmount.mul(WITHDRAWAL_FEES).div(BASIS_POINT);

        transferFees(adminFees);

        IERC20(asset).safeTransfer(user, withdrawalAmount.sub(adminFees));
        IERC20(mim).safeTransfer(address(bentoBox), amount.add(fee));
        _burn(user, shareAmount);
    }



    function transferFees(uint256 amount) internal {
        IERC20(asset).safeTransfer(owner(), amount);
    }

    function withdrawERC20(address token) external onlyOwner {
        IERC20(token).safeTransfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdrawEth() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

}