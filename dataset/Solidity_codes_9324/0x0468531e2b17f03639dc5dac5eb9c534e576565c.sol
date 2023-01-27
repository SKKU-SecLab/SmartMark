
pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
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

}//Unlicense
pragma solidity 0.7.6;

interface IERC2612Permit {
    function permit(
        address _owner,
        address _spender,
        uint256 _amount,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function nonces(address _owner) external view returns (uint256);
}//Unlicense
pragma solidity 0.7.6;



abstract contract ERC20Permit is ERC20, IERC2612Permit {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    mapping(uint256 => bytes32) public domainSeparators;

    constructor() {
        _updateDomainSeparator();
    }

    function permit(
        address _owner,
        address _spender,
        uint256 _amount,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public virtual override {
        require(block.timestamp <= _deadline, "ERC20Permit: expired _deadline");


        bytes32 hashStruct;
        Counters.Counter storage nonceCounter = _nonces[_owner];
        uint256 nonce = nonceCounter.current();

        assembly {
            let memPtr := mload(64)

            mstore(memPtr, 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9)
            mstore(add(memPtr, 32), _owner)
            mstore(add(memPtr, 64), _spender)
            mstore(add(memPtr, 96), _amount)
            mstore(add(memPtr, 128), nonce)
            mstore(add(memPtr, 160), _deadline)

            hashStruct := keccak256(memPtr, 192)
        }

        bytes32 eip712DomainHash = _domainSeparator();


        bytes32 hash;

        assembly {
            let memPtr := mload(64)

            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)  // EIP191 header
            mstore(add(memPtr, 2), eip712DomainHash)                                            // EIP712 domain hash
            mstore(add(memPtr, 34), hashStruct)                                                 // Hash of struct

            hash := keccak256(memPtr, 66)
        }

        address signer = _recover(hash, _v, _r, _s);

        require(signer == _owner, "ERC20Permit: invalid signature");

        nonceCounter.increment();
        _approve(_owner, _spender, _amount);
    }

    function nonces(address _owner) public override view returns (uint256) {
        return _nonces[_owner].current();
    }

    function _updateDomainSeparator() private returns (bytes32) {
        uint256 chainID = _chainID();

        bytes32 newDomainSeparator = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name())), // ERC-20 Name
                keccak256(bytes("1")),    // Version
                chainID,
                address(this)
            )
        );

        domainSeparators[chainID] = newDomainSeparator;

        return newDomainSeparator;
    }

    function _domainSeparator() private returns (bytes32) {
        bytes32 domainSeparator = domainSeparators[_chainID()];

        if (domainSeparator != 0x00) {
            return domainSeparator;
        }

        return _updateDomainSeparator();
    }

    function _chainID() private pure returns (uint256) {
        uint256 chainID;
        assembly {
            chainID := chainid()
        }

        return chainID;
    }

    function _recover(
        bytes32 _hash,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal pure returns (address) {
        if (
            uint256(_s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            revert("ECDSA: invalid signature '_s' value");
        }

        if (_v != 27 && _v != 28) {
            revert("ECDSA: invalid signature '_v' value");
        }

        address signer = ecrecover(_hash, _v, _r, _s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }
}//Unlicense
pragma solidity 0.7.6;


contract WrappedToken is ERC20Permit, Pausable, Ownable {
    using SafeMath for uint256;
    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 decimals
    ) ERC20(_tokenName, _tokenSymbol) {
        super._setupDecimals(decimals);
    }

    function mint(address _account, uint256 _amount) public onlyOwner {
        super._mint(_account, _amount);
    }

    function burnFrom(address _account, uint256 _amount)
        public
        onlyOwner
    {
        uint256 decreasedAllowance =
            allowance(_account, _msgSender()).sub(
                _amount,
                "ERC20: burn amount exceeds allowance"
            );

        _approve(_account, _msgSender(), decreasedAllowance);
        _burn(_account, _amount);
    }

    function pause() public onlyOwner {
        super._pause();
    }

    function unpause() public onlyOwner {
        super._unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 _amount) internal virtual override {
        super._beforeTokenTransfer(from, to, _amount);

        require(!paused(), "WrappedToken: token transfer while paused");
    }
}// Unlicense
pragma solidity 0.7.6;

library LibRouter {
    bytes32 constant STORAGE_POSITION = keccak256("router.storage");

    struct NativeTokenWithChainId {
        uint8 chainId;
        bytes token;
    }

    struct Storage {
        bool initialized;

        mapping(uint8 => mapping(bytes => address)) nativeToWrappedToken;

        mapping(address => NativeTokenWithChainId) wrappedToNativeToken;

        mapping(uint8 => mapping(bytes32 => bool)) hashesUsed;

        address albtToken;

        uint8 chainId;
    }

    function routerStorage() internal pure returns (Storage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}//Unlicense
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;


struct WrappedTokenParams {
    string name;
    string symbol;
    uint8 decimals;
}

interface IRouter {
    event Lock(uint8 targetChain, address token, bytes receiver, uint256 amount, uint256 serviceFee);
    event Burn(address token, uint256 amount, bytes receiver);
    event BurnAndTransfer(uint8 targetChain, address token, uint256 amount, bytes receiver);
    event Unlock(address token, uint256 amount, address receiver);
    event Mint(address token, uint256 amount, address receiver);
    event WrappedTokenDeployed(uint8 sourceChain, bytes nativeToken, address wrappedToken);
    event Fees(uint256 serviceFee, uint256 externalFee);

    function initRouter(uint8 _chainId, address _albtToken) external;
    function nativeToWrappedToken(uint8 _chainId, bytes memory _nativeToken) external view returns (address);
    function wrappedToNativeToken(address _wrappedToken) external view returns (LibRouter.NativeTokenWithChainId memory);
    function hashesUsed(uint8 _chainId, bytes32 _ethHash) external view returns (bool);
    function albtToken() external view returns (address);
    function lock(uint8 _targetChain, address _nativeToken, uint256 _amount, bytes memory _receiver) external;

    function lockWithPermit(
        uint8 _targetChain,
        address _nativeToken,
        uint256 _amount,
        bytes memory _receiver,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function unlock(
        uint8 _sourceChain,
        bytes memory _transactionId,
        address _nativeToken,
        uint256 _amount,
        address _receiver,
        bytes[] calldata _signatures
    ) external;

    function burn(address _wrappedToken, uint256 _amount, bytes memory _receiver) external;

    function burnWithPermit(
        address _wrappedToken,
        uint256 _amount,
        bytes memory _receiver,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function burnAndTransfer(uint8 _targetChain, address _wrappedToken, uint256 _amount, bytes memory _receiver) external;

    function burnAndTransferWithPermit(
        uint8 _targetChain,
        address _wrappedToken,
        uint256 _amount,
        bytes memory _receiver,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

    function mint(
        uint8 _nativeChain,
        bytes memory _nativeToken,
        bytes memory _transactionId,
        uint256 _amount,
        address _receiver,
        bytes[] calldata _signatures,
        WrappedTokenParams memory _tokenParams
    ) external;
}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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
}// Unlicense
pragma solidity 0.7.6;


library LibGovernance {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Counters for Counters.Counter;
    bytes32 constant STORAGE_POSITION = keccak256("governance.storage");

    struct Storage {
        bool initialized;
        Counters.Counter administrativeNonce;
        EnumerableSet.AddressSet membersSet;
    }

    function governanceStorage() internal pure returns (Storage storage gs) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            gs.slot := position
        }
    }


    function updateMember(address _account, bool _status) internal {
        Storage storage gs = governanceStorage();
        if (_status) {
            require(
                gs.membersSet.add(_account),
                "Governance: Account already added"
            );
        } else if (!_status) {
            require(
                gs.membersSet.length() > 1,
                "Governance: Would become memberless"
            );
            require(
                gs.membersSet.remove(_account),
                "Governance: Account is not a member"
            );
        }
        gs.administrativeNonce.increment();
    }

    function computeMemberUpdateMessage(address _account, bool _status) internal view returns (bytes32) {
        Storage storage gs = governanceStorage();
        bytes32 hashedData =
            keccak256(
                abi.encode(_account, _status, gs.administrativeNonce.current())
            );
        return ECDSA.toEthSignedMessageHash(hashedData);
    }

    function isMember(address _member) internal view returns (bool) {
        Storage storage gs = governanceStorage();
        return gs.membersSet.contains(_member);
    }

    function membersCount() internal view returns (uint256) {
        Storage storage gs = governanceStorage();
        return gs.membersSet.length();
    }

    function memberAt(uint256 _index) internal view returns (address) {
        Storage storage gs = governanceStorage();
        return gs.membersSet.at(_index);
    }

    function validateSignatures(bytes32 _ethHash, bytes[] calldata _signatures) internal view {
        address[] memory signers = new address[](_signatures.length);
        for (uint256 i = 0; i < _signatures.length; i++) {
            address signer = ECDSA.recover(_ethHash, _signatures[i]);
            require(isMember(signer), "Governance: invalid signer");
            for (uint256 j = 0; j < i; j++) {
                require(signer != signers[j], "Governance: duplicate signatures");
            }
            signers[i] = signer;
        }
    }
}// Unlicense
pragma solidity 0.7.6;


library LibFeeCalculator {
    using SafeMath for uint256;
    bytes32 constant STORAGE_POSITION = keccak256("fee.calculator.storage");

    struct Storage {
        bool initialized;

        uint256 serviceFee;

        uint256 feesAccrued;

        uint256 previousAccrued;

        uint256 accumulator;

        mapping(address => uint256) claimedRewardsPerAccount; 
    }

    function feeCalculatorStorage() internal pure returns (Storage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    function addNewMember(address _account) internal {
        LibFeeCalculator.Storage storage fcs = feeCalculatorStorage();
        uint256 amount = fcs.feesAccrued.sub(fcs.previousAccrued).div(LibGovernance.membersCount());

        fcs.previousAccrued = fcs.feesAccrued;
        fcs.accumulator = fcs.accumulator.add(amount);
        fcs.claimedRewardsPerAccount[_account] = fcs.accumulator;
    }

    function claimReward(address _claimer)
        internal
        returns (uint256)
    {
        LibFeeCalculator.Storage storage fcs = feeCalculatorStorage();
        uint256 amount = fcs.feesAccrued.sub(fcs.previousAccrued).div(LibGovernance.membersCount());

        fcs.previousAccrued = fcs.feesAccrued;
        fcs.accumulator = fcs.accumulator.add(amount);

        uint256 claimableAmount = fcs.accumulator.sub(fcs.claimedRewardsPerAccount[_claimer]);

        fcs.claimedRewardsPerAccount[_claimer] = fcs.accumulator;

        return claimableAmount;
    }

    function distributeRewards() internal {
        LibFeeCalculator.Storage storage fcs = feeCalculatorStorage();
        fcs.feesAccrued = fcs.feesAccrued.add(fcs.serviceFee);
    }
}// Unlicense
pragma solidity 0.7.6;


library LibFeeExternal {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bytes32 constant STORAGE_POSITION = keccak256("fee.external.storage");

    struct Storage {
        bool initialized;

        uint256 externalFee;

        address externalFeeAddress;
    }

    function chargeExternalFee() internal returns (uint256) {
        LibFeeExternal.Storage storage fes = LibFeeExternal.feeExternalStorage();
        LibRouter.Storage storage rs = LibRouter.routerStorage();
        if (fes.externalFee != 0) {
            require(fes.externalFeeAddress != address(0), "External fee set, but no receiver address");
            IERC20(rs.albtToken).safeTransferFrom(msg.sender, fes.externalFeeAddress, fes.externalFee);
        }

        return fes.externalFee;
    }

    function feeExternalStorage() internal pure returns (Storage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

}//Unlicense
pragma solidity 0.7.6;


contract RouterFacet is IRouter {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    function initRouter(
        uint8 _chainId,
        address _albtToken
    )
        external override
    {
        LibRouter.Storage storage rs = LibRouter.routerStorage();
        require(!rs.initialized, "Router: already initialized");
        rs.initialized = true;
        rs.chainId = _chainId;

        if(_chainId != 1) {
            bytes memory nativeAlbt = abi.encodePacked(_albtToken);
            WrappedToken wrappedAlbt = new WrappedToken("Wrapped AllianceBlock Token", "WALBT", 18);
            rs.albtToken = address(wrappedAlbt);
            rs.nativeToWrappedToken[1][nativeAlbt] = rs.albtToken;
            rs.wrappedToNativeToken[rs.albtToken].chainId = 1;
            rs.wrappedToNativeToken[rs.albtToken].token = nativeAlbt;
            emit WrappedTokenDeployed(1, nativeAlbt, rs.albtToken);
        } else {
            rs.albtToken = _albtToken;
        }
    }

    modifier onlyValidSignatures(uint256 _n) {
        uint256 members = LibGovernance.membersCount();
        require(_n <= members, "Governance: Invalid number of signatures");
        require(_n > members / 2, "Governance: Invalid number of signatures");
        _;
    }

    function nativeToWrappedToken(uint8 _chainId, bytes memory _nativeToken) external view override returns (address) {
        LibRouter.Storage storage rs = LibRouter.routerStorage();
        return rs.nativeToWrappedToken[_chainId][_nativeToken];
    }

    function wrappedToNativeToken(address _wrappedToken) external view override returns (LibRouter.NativeTokenWithChainId memory) {
        LibRouter.Storage storage rs = LibRouter.routerStorage();
        return rs.wrappedToNativeToken[_wrappedToken];
    }

    function hashesUsed(uint8 _chainId, bytes32 _ethHash) external view override returns (bool) {
        LibRouter.Storage storage rs = LibRouter.routerStorage();
        return rs.hashesUsed[_chainId][_ethHash];
    }

    function albtToken() external view override returns (address) {
        LibRouter.Storage storage rs = LibRouter.routerStorage();
        return rs.albtToken;
    }

    function lock(uint8 _targetChain, address _nativeToken, uint256 _amount, bytes memory _receiver) public override {
        LibRouter.Storage storage rs = LibRouter.routerStorage();
        LibFeeCalculator.Storage storage fcs = LibFeeCalculator.feeCalculatorStorage();
        LibFeeCalculator.distributeRewards();
        IERC20(rs.albtToken).safeTransferFrom(msg.sender, address(this), fcs.serviceFee);
        uint256 _chargedExternalFee = LibFeeExternal.chargeExternalFee();
        IERC20(_nativeToken).safeTransferFrom(msg.sender, address(this), _amount);
        emit Lock(_targetChain, _nativeToken, _receiver, _amount, fcs.serviceFee);
        emit Fees(fcs.serviceFee, _chargedExternalFee);
    }

    function lockWithPermit(
        uint8 _targetChain,
        address _nativeToken,
        uint256 _amount,
        bytes memory _receiver,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override {
        IERC2612Permit(_nativeToken).permit(msg.sender, address(this), _amount, _deadline, _v, _r, _s);
        lock(_targetChain, _nativeToken, _amount, _receiver);
    }

    function unlock(
        uint8 _sourceChain,
        bytes memory _transactionId,
        address _nativeToken,
        uint256 _amount,
        address _receiver,
        bytes[] calldata _signatures
    )
        external override
        onlyValidSignatures(_signatures.length)
    {
        LibRouter.Storage storage rs = LibRouter.routerStorage();
        bytes32 ethHash =
            computeUnlockMessage(_sourceChain, rs.chainId, _transactionId, abi.encodePacked(_nativeToken), _receiver, _amount);

        require(!rs.hashesUsed[_sourceChain][ethHash], "Router: transaction already submitted");

        validateAndStoreTx(_sourceChain, ethHash, _signatures);

        IERC20(_nativeToken).safeTransfer(_receiver, _amount);

        emit Unlock(_nativeToken, _amount, _receiver);
    }

    function burn(address _wrappedToken, uint256 _amount, bytes memory _receiver) public override {
        LibRouter.Storage storage rs = LibRouter.routerStorage();
        LibFeeCalculator.Storage storage fcs = LibFeeCalculator.feeCalculatorStorage();
        LibFeeCalculator.distributeRewards();
        IERC20(rs.albtToken).safeTransferFrom(msg.sender, address(this), fcs.serviceFee);
        uint256 _chargedExternalFee = LibFeeExternal.chargeExternalFee();
        WrappedToken(_wrappedToken).burnFrom(msg.sender, _amount);
        emit Burn(_wrappedToken, _amount, _receiver);
        emit Fees(fcs.serviceFee, _chargedExternalFee);
    }

    function burnWithPermit(
        address _wrappedToken,
        uint256 _amount,
        bytes memory _receiver,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override {
        WrappedToken(_wrappedToken).permit(msg.sender, address(this), _amount, _deadline, _v, _r, _s);
        burn(_wrappedToken, _amount, _receiver);
    }

    function burnAndTransfer(uint8 _targetChain, address _wrappedToken, uint256 _amount, bytes memory _receiver) public override {
        LibRouter.Storage storage rs = LibRouter.routerStorage();
        LibFeeCalculator.Storage storage fcs = LibFeeCalculator.feeCalculatorStorage();
        LibFeeCalculator.distributeRewards();
        IERC20(rs.albtToken).safeTransferFrom(msg.sender, address(this), fcs.serviceFee);
        uint256 _chargedExternalFee = LibFeeExternal.chargeExternalFee();
        WrappedToken(_wrappedToken).burnFrom(msg.sender, _amount);
        emit BurnAndTransfer(_targetChain, _wrappedToken, _amount, _receiver);
        emit Fees(fcs.serviceFee, _chargedExternalFee);
    }

    function burnAndTransferWithPermit(
        uint8 _targetChain,
        address _wrappedToken,
        uint256 _amount,
        bytes memory _receiver,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external override {
        WrappedToken(_wrappedToken).permit(msg.sender, address(this), _amount, _deadline, _v, _r, _s);
        burnAndTransfer(_targetChain, _wrappedToken, _amount, _receiver);
    }

    function mint(
        uint8 _nativeChain,
        bytes memory _nativeToken,
        bytes memory _transactionId,
        uint256 _amount,
        address _receiver,
        bytes[] calldata _signatures,
        WrappedTokenParams memory _tokenParams
    )
        external override
        onlyValidSignatures(_signatures.length)
    {
        LibRouter.Storage storage rs = LibRouter.routerStorage();
        bytes32 ethHash =
            computeMintMessage(_nativeChain, rs.chainId, _transactionId, _nativeToken, _receiver, _amount, _tokenParams);

        require(!rs.hashesUsed[_nativeChain][ethHash], "Router: transaction already submitted");

        validateAndStoreTx(_nativeChain, ethHash, _signatures);

        if(rs.nativeToWrappedToken[_nativeChain][_nativeToken] == address(0)) {
            deployWrappedToken(_nativeChain, _nativeToken, _tokenParams);
        }

        WrappedToken(rs.nativeToWrappedToken[_nativeChain][_nativeToken]).mint(_receiver, _amount);

        emit Mint(rs.nativeToWrappedToken[_nativeChain][_nativeToken], _amount, _receiver);
    }

    function deployWrappedToken(
        uint8 _sourceChain,
        bytes memory _nativeToken,
        WrappedTokenParams memory _tokenParams
    )
        internal
    {
        require(bytes(_tokenParams.name).length > 0, "Router: empty wrapped token name");
        require(bytes(_tokenParams.symbol).length > 0, "Router: empty wrapped token symbol");
        require(_tokenParams.decimals > 0, "Router: invalid wrapped token decimals");

        LibRouter.Storage storage rs = LibRouter.routerStorage();
        WrappedToken t = new WrappedToken(_tokenParams.name, _tokenParams.symbol, _tokenParams.decimals);
        rs.nativeToWrappedToken[_sourceChain][_nativeToken] = address(t);
        rs.wrappedToNativeToken[address(t)].chainId = _sourceChain;
        rs.wrappedToNativeToken[address(t)].token = _nativeToken;

        emit WrappedTokenDeployed(_sourceChain, _nativeToken, address(t));
    }

    function computeUnlockMessage(
        uint8 _sourceChain,
        uint8 _targetChain,
        bytes memory _transactionId,
        bytes memory _nativeToken,
        address _receiver,
        uint256 _amount
    ) internal pure returns (bytes32) {
        bytes32 hashedData =
            keccak256(
                abi.encode(_sourceChain, _targetChain, _transactionId, _receiver, _amount, _nativeToken)
            );
        return ECDSA.toEthSignedMessageHash(hashedData);
    }

    function computeMintMessage(
        uint8 _nativeChain,
        uint8 _targetChain,
        bytes memory _transactionId,
        bytes memory _nativeToken,
        address _receiver,
        uint256 _amount,
        WrappedTokenParams memory _tokenParams
    ) internal pure returns (bytes32) {
        bytes32 hashedData =
            keccak256(
                abi.encode(
                    _nativeChain,
                    _targetChain,
                    _transactionId,
                    _receiver,
                    _amount,
                    _nativeToken,
                    _tokenParams.name,
                    _tokenParams.symbol,
                    _tokenParams.decimals
                )
            );
        return ECDSA.toEthSignedMessageHash(hashedData);
    }

    function validateAndStoreTx(
        uint8 _chainId,
        bytes32 _ethHash,
        bytes[] calldata _signatures
    ) internal {
        LibRouter.Storage storage rs = LibRouter.routerStorage();
        LibGovernance.validateSignatures(_ethHash, _signatures);
        rs.hashesUsed[_chainId][_ethHash] = true;
    }
}