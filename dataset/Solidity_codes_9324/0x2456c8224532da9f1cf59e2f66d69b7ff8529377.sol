



pragma solidity ^0.8.0;
pragma abicoder v2;

interface IERC20Upgradeable {

  function totalSupply() external view returns (uint256);


  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


  function allowance(address owner, address spender)
    external
    view
    returns (uint256);


  function approve(address spender, uint256 amount) external returns (bool);


  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.0;

interface IERC20MetadataUpgradeable is IERC20Upgradeable {

  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


  function decimals() external view returns (uint8);

}



pragma solidity ^0.8.0;

library AddressUpgradeable {

  function isContract(address account) internal view returns (bool) {


    uint256 size;
    assembly {
      size := extcodesize(account)
    }
    return size > 0;
  }

  function sendValue(address payable recipient, uint256 amount) internal {

    require(address(this).balance >= amount, 'Address: insufficient balance');

    (bool success, ) = recipient.call{ value: amount }('');
    require(
      success,
      'Address: unable to send value, recipient may have reverted'
    );
  }

  function functionCall(address target, bytes memory data)
    internal
    returns (bytes memory)
  {

    return functionCall(target, data, 'Address: low-level call failed');
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

    return
      functionCallWithValue(
        target,
        data,
        value,
        'Address: low-level call with value failed'
      );
  }

  function functionCallWithValue(
    address target,
    bytes memory data,
    uint256 value,
    string memory errorMessage
  ) internal returns (bytes memory) {

    require(
      address(this).balance >= value,
      'Address: insufficient balance for call'
    );
    require(isContract(target), 'Address: call to non-contract');

    (bool success, bytes memory returndata) = target.call{ value: value }(data);
    return verifyCallResult(success, returndata, errorMessage);
  }

  function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
  {

    return
      functionStaticCall(target, data, 'Address: low-level static call failed');
  }

  function functionStaticCall(
    address target,
    bytes memory data,
    string memory errorMessage
  ) internal view returns (bytes memory) {

    require(isContract(target), 'Address: static call to non-contract');

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
}



pragma solidity ^0.8.0;

abstract contract Initializable {
  bool private _initialized;

  bool private _initializing;

  modifier initializer() {
    require(
      _initializing ? _isConstructor() : !_initialized,
      'Initializable: contract is already initialized'
    );

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
    require(_initializing, 'Initializable: contract is not initializing');
    _;
  }

  function _isConstructor() private view returns (bool) {
    return !AddressUpgradeable.isContract(address(this));
  }
}



pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
  function __Context_init() internal onlyInitializing {
    __Context_init_unchained();
  }

  function __Context_init_unchained() internal onlyInitializing {}

  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }

  uint256[50] private __gap;
}



pragma solidity ^0.8.0;

contract ERC20Upgradeable is
  Initializable,
  ContextUpgradeable,
  IERC20Upgradeable,
  IERC20MetadataUpgradeable
{

  mapping(address => uint256) private _balances;

  mapping(address => mapping(address => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;

  function __ERC20_init(string memory name_, string memory symbol_)
    internal
    onlyInitializing
  {

    __Context_init_unchained();
    __ERC20_init_unchained(name_, symbol_);
  }

  function __ERC20_init_unchained(string memory name_, string memory symbol_)
    internal
    onlyInitializing
  {

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

  function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
  {

    return _balances[account];
  }

  function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {

    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
  {

    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {

    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {

    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(
      currentAllowance >= amount,
      'ERC20: transfer amount exceeds allowance'
    );
    unchecked {
      _approve(sender, _msgSender(), currentAllowance - amount);
    }

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
  {

    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender] + addedValue
    );
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {

    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(
      currentAllowance >= subtractedValue,
      'ERC20: decreased allowance below zero'
    );
    unchecked {
      _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {

    require(sender != address(0), 'ERC20: transfer from the zero address');
    require(recipient != address(0), 'ERC20: transfer to the zero address');

    _beforeTokenTransfer(sender, recipient, amount);

    uint256 senderBalance = _balances[sender];
    require(senderBalance >= amount, 'ERC20: transfer amount exceeds balance');
    unchecked {
      _balances[sender] = senderBalance - amount;
    }
    _balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);

    _afterTokenTransfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal virtual {

    require(account != address(0), 'ERC20: mint to the zero address');

    _beforeTokenTransfer(address(0), account, amount);

    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);

    _afterTokenTransfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal virtual {

    require(account != address(0), 'ERC20: burn from the zero address');

    _beforeTokenTransfer(account, address(0), amount);

    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, 'ERC20: burn amount exceeds balance');
    unchecked {
      _balances[account] = accountBalance - amount;
    }
    _totalSupply -= amount;

    emit Transfer(account, address(0), amount);

    _afterTokenTransfer(account, address(0), amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {

    require(owner != address(0), 'ERC20: approve from the zero address');
    require(spender != address(0), 'ERC20: approve to the zero address');

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}


  function _afterTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}


  uint256[45] private __gap;
}


pragma solidity >=0.8.0 <0.9.0;

struct Signature {
  uint8 v;
  bytes32 r;
  bytes32 s;
}



pragma solidity ^0.8.0;

library Strings {

  bytes16 private constant _HEX_SYMBOLS = '0123456789abcdef';

  function toString(uint256 value) internal pure returns (string memory) {


    if (value == 0) {
      return '0';
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  function toHexString(uint256 value) internal pure returns (string memory) {

    if (value == 0) {
      return '0x00';
    }
    uint256 temp = value;
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return toHexString(value, length);
  }

  function toHexString(uint256 value, uint256 length)
    internal
    pure
    returns (string memory)
  {

    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = '0';
    buffer[1] = 'x';
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = _HEX_SYMBOLS[value & 0xf];
      value >>= 4;
    }
    require(value == 0, 'Strings: hex length insufficient');
    return string(buffer);
  }
}



pragma solidity ^0.8.0;

library ECDSA {

  enum RecoverError {
    NoError,
    InvalidSignature,
    InvalidSignatureLength,
    InvalidSignatureS,
    InvalidSignatureV
  }

  function _throwError(RecoverError error) private pure {

    if (error == RecoverError.NoError) {
      return; // no error: do nothing
    } else if (error == RecoverError.InvalidSignature) {
      revert('ECDSA: invalid signature');
    } else if (error == RecoverError.InvalidSignatureLength) {
      revert('ECDSA: invalid signature length');
    } else if (error == RecoverError.InvalidSignatureS) {
      revert("ECDSA: invalid signature 's' value");
    } else if (error == RecoverError.InvalidSignatureV) {
      revert("ECDSA: invalid signature 'v' value");
    }
  }

  function tryRecover(bytes32 hash, bytes memory signature)
    internal
    pure
    returns (address, RecoverError)
  {

    if (signature.length == 65) {
      bytes32 r;
      bytes32 s;
      uint8 v;
      assembly {
        r := mload(add(signature, 0x20))
        s := mload(add(signature, 0x40))
        v := byte(0, mload(add(signature, 0x60)))
      }
      return tryRecover(hash, v, r, s);
    } else if (signature.length == 64) {
      bytes32 r;
      bytes32 vs;
      assembly {
        r := mload(add(signature, 0x20))
        vs := mload(add(signature, 0x40))
      }
      return tryRecover(hash, r, vs);
    } else {
      return (address(0), RecoverError.InvalidSignatureLength);
    }
  }

  function recover(bytes32 hash, bytes memory signature)
    internal
    pure
    returns (address)
  {

    (address recovered, RecoverError error) = tryRecover(hash, signature);
    _throwError(error);
    return recovered;
  }

  function tryRecover(
    bytes32 hash,
    bytes32 r,
    bytes32 vs
  ) internal pure returns (address, RecoverError) {

    bytes32 s;
    uint8 v;
    assembly {
      s := and(
        vs,
        0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
      )
      v := add(shr(255, vs), 27)
    }
    return tryRecover(hash, v, r, s);
  }

  function recover(
    bytes32 hash,
    bytes32 r,
    bytes32 vs
  ) internal pure returns (address) {

    (address recovered, RecoverError error) = tryRecover(hash, r, vs);
    _throwError(error);
    return recovered;
  }

  function tryRecover(
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal pure returns (address, RecoverError) {

    if (
      uint256(s) >
      0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
    ) {
      return (address(0), RecoverError.InvalidSignatureS);
    }
    if (v != 27 && v != 28) {
      return (address(0), RecoverError.InvalidSignatureV);
    }

    address signer = ecrecover(hash, v, r, s);
    if (signer == address(0)) {
      return (address(0), RecoverError.InvalidSignature);
    }

    return (signer, RecoverError.NoError);
  }

  function recover(
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal pure returns (address) {

    (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
    _throwError(error);
    return recovered;
  }

  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {

    return
      keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n32', hash));
  }

  function toEthSignedMessageHash(bytes memory s)
    internal
    pure
    returns (bytes32)
  {

    return
      keccak256(
        abi.encodePacked(
          '\x19Ethereum Signed Message:\n',
          Strings.toString(s.length),
          s
        )
      );
  }

  function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash)
    internal
    pure
    returns (bytes32)
  {

    return keccak256(abi.encodePacked('\x19\x01', domainSeparator, structHash));
  }
}



pragma solidity >=0.8.0 <0.9.0;

library EIP712 {

  bytes32 public constant EIP712_DOMAIN_TYPEHASH =
    0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

  function makeDomainSeparator(string memory name, string memory version)
    internal
    view
    returns (bytes32)
  {

    return
      keccak256(
        abi.encode(
          EIP712_DOMAIN_TYPEHASH,
          keccak256(bytes(name)),
          keccak256(bytes(version)),
          bytes32(block.chainid),
          address(this)
        )
      );
  }

  function recover(
    bytes32 domainSeparator,
    uint8 v,
    bytes32 r,
    bytes32 s,
    bytes memory typeHashAndData
  ) internal pure returns (address) {

    bytes32 digest = ECDSA.toTypedDataHash(
      domainSeparator,
      keccak256(typeHashAndData)
    );
    return ECDSA.recover(digest, v, r, s);
  }
}

abstract contract EIP712Domain {
  bytes32 public DOMAIN_SEPARATOR;
}


pragma solidity >=0.8.0 <0.9.0;

abstract contract ERC20Permit is EIP712Domain {
  bytes32 public constant PERMIT_TYPEHASH =
    0xfc77c2b9d30fe91687fd39abb7d16fcdfe1472d065740051ab8b13e4bf4a617f;

  mapping(address => uint256) internal _nonces;

  function nonces(address _owner) external view returns (uint256) {
    return _nonces[_owner];
  }

  function _permit(
    address _owner,
    address _spender,
    uint256 _amount,
    uint256 _deadline,
    Signature memory _sig
  ) internal virtual {
    require(_deadline >= block.timestamp, 'ERC20Permit: expired');

    bytes memory data = abi.encode(
      PERMIT_TYPEHASH,
      _owner,
      _spender,
      _amount,
      _nonces[_owner]++,
      _deadline
    );
    require(
      EIP712.recover(DOMAIN_SEPARATOR, _sig.v, _sig.r, _sig.s, data) == _owner,
      'EIP2612: invalid signature'
    );

  }
}


pragma solidity >=0.8.0 <0.9.0;

abstract contract EIP3009 is EIP712Domain {
  bytes32 public constant CANCEL_AUTHORIZATION_TYPEHASH =
    0x158b0a9edf7a828aad02f63cd515c68ef2f50ba807396f6d12842833a1597429;

  mapping(address => mapping(bytes32 => bool)) internal _authorizationStates;

  event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
  event AuthorizationCanceled(
    address indexed authorizer,
    bytes32 indexed nonce
  );

  string internal constant _INVALID_SIGNATURE_ERROR =
    'EIP3009: invalid signature';
  string internal constant _AUTHORIZATION_USED_ERROR =
    'EIP3009: authorization is used';

  function authorizationState(address authorizer, bytes32 nonce)
    external
    view
    returns (bool)
  {
    return _authorizationStates[authorizer][nonce];
  }

  function _cancelAuthorization(
    address _authorizer,
    bytes32 _nonce,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) internal {
    _spendAuthorization(
      _authorizer,
      abi.encode(CANCEL_AUTHORIZATION_TYPEHASH, _authorizer, _nonce),
      _nonce,
      _v,
      _r,
      _s
    );
  }

  function _spendAuthorization(
    address _from,
    bytes memory _payload,
    bytes32 _nonce,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) internal {
    require(!_authorizationStates[_from][_nonce], _AUTHORIZATION_USED_ERROR);

    require(
      EIP712.recover(DOMAIN_SEPARATOR, _v, _r, _s, _payload) == _from,
      _INVALID_SIGNATURE_ERROR
    );

    _authorizationStates[_from][_nonce] = true;
    emit AuthorizationUsed(_from, _nonce);
  }
}


pragma solidity >=0.8.0 <0.9.0;

abstract contract ERC20Spendable is EIP3009 {
  bytes32 public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH =
    0xa7bc2c08eada54d419b87dfce5103bb4d0fab70d36db67226c8a1bb80b69524b;
  bytes32 public constant RECEIVE_WITH_AUTHORIZATION_TYPEHASH =
    0x809662e72f8d3065d367f26b91f7ad18604329f65460d0132508901cece31a00;

  function _transferWithAuthorization(
    address _from,
    address _to,
    uint256 _amount,
    bytes32 _nonce,
    uint256 _validAfter,
    uint256 _validBefore,
    Signature memory _sig
  ) internal virtual {
    require(block.timestamp > _validAfter, 'ERC20Spendable: not yet valid');
    require(block.timestamp < _validBefore, 'ERC20Spendable: expired');

    _spendAuthorization(
      _from,
      abi.encode(
        TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
        _from,
        _to,
        _amount,
        _nonce,
        _validAfter,
        _validBefore
      ),
      _nonce,
      _sig.v,
      _sig.r,
      _sig.s
    );

  }

  function _receiveWithAuthorization(
    address _from,
    address _to,
    uint256 _amount,
    bytes32 _nonce,
    uint256 _validAfter,
    uint256 _validBefore,
    Signature memory _sig
  ) internal virtual {
    require(_to == msg.sender, 'ERC20Spendable: caller must be the payee');

    require(block.timestamp > _validAfter, 'ERC20Spendable: not yet valid');
    require(block.timestamp < _validBefore, 'ERC20Spendable: expired');

    _spendAuthorization(
      _from,
      abi.encode(
        RECEIVE_WITH_AUTHORIZATION_TYPEHASH,
        _from,
        _to,
        _amount,
        _nonce,
        _validAfter,
        _validBefore
      ),
      _nonce,
      _sig.v,
      _sig.r,
      _sig.s
    );

  }

  function cancelAuthorization(
    address _authorizer,
    bytes32 _nonce,
    Signature memory _sig
  ) external {
    _cancelAuthorization(_authorizer, _nonce, _sig.v, _sig.r, _sig.s);
  }
}


pragma solidity >=0.8.0 <0.9.0;

contract SportiumERC20 is
  Initializable,
  ERC20Upgradeable, // proxy wrapper
  ERC20Spendable, // EIP3009
  ERC20Permit // EIP2612
{

  struct InitialSupplyPayload {
    uint256 amount;
    address to;
  }

  function initialize(
    string memory _name,
    string memory _symbol,
    InitialSupplyPayload[] memory _payload
  ) public initializer {

    __ERC20_init(_name, _symbol);
    DOMAIN_SEPARATOR = EIP712.makeDomainSeparator(_name, '1');
    for (uint256 i = 0; i < _payload.length; i++) {
      _mint(_payload[i].to, _payload[i].amount);
    }
  }

  function transferWithAuthorization(
    address _from,
    address _to,
    uint256 _amount,
    bytes32 _nonce,
    uint256 _validAfter,
    uint256 _validBefore,
    Signature memory _sig
  ) external virtual {

    _transferWithAuthorization(
      _from,
      _to,
      _amount,
      _nonce,
      _validAfter,
      _validBefore,
      _sig
    );
    _transfer(_from, _to, _amount);
  }

  function receiveWithAuthorization(
    address _from,
    address _to,
    uint256 _amount,
    bytes32 _nonce,
    uint256 _validAfter,
    uint256 _validBefore,
    Signature memory _sig
  ) external virtual {

    _receiveWithAuthorization(
      _from,
      _to,
      _amount,
      _nonce,
      _validAfter,
      _validBefore,
      _sig
    );
    _transfer(_from, _to, _amount);
  }

  function permit(
    address _owner,
    address _spender,
    uint256 _amount,
    uint256 _deadline,
    Signature memory _sig
  ) external virtual {

    _permit(_owner, _spender, _amount, _deadline, _sig);
    _approve(_owner, _spender, _amount);
  }
}