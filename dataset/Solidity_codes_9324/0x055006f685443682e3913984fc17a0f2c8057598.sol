
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
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

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library ECDSAUpgradeable {

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
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

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

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

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
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
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

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
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

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}//MIT

pragma solidity 0.8.4;


interface IERC20Decimals {

    function decimals() external returns (uint8);

}

abstract contract AbstractLocker_v30 is Initializable, OwnableUpgradeable {
    string constant EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA = "\x19\x01";
    bytes32 constant EIP712_DOMAIN_TYPEHASH=keccak256(abi.encodePacked(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    ));
    bytes32 private constant BRIDGE_WITHDRAW_TYPEHASH=keccak256(abi.encodePacked(
        "BridgeWithdraw(uint256 claimId,uint256 targetChainGuid,address targetLockerAddress,address targetAddress,uint256 amount,uint256 deadline)"
    ));
    bytes32 private constant BRIDGE_REFUND_TYPEHASH=keccak256(abi.encodePacked(
        "BridgeRefund(uint256 claimId,uint256 sourceChainGuid,address sourceLockerAddress,address sourceAddress,uint256 amount)"
    ));
    bytes32 private constant LIQUIDITY_WITHDRAW_TYPEHASH=keccak256(abi.encodePacked(
        "LiquidityWithdraw(uint256 claimId,uint256 targetChainGuid,address targetLockerAddress,address targetAddress,uint256 amount,uint256 deadline,bool bypassFee)"
    ));
    bytes32 private ORACLE_DOMAIN_SEPARATOR;
    uint256 public chainGuid;
    uint256 public evmChainId;
    address public lockerToken;
    address public feeAddress;
    uint16 public feeBP;
    bool public maintenanceMode;
    mapping(address => bool) public oracles;
    mapping(uint256 => bool) public claims;
    uint8 public tokenDecimals;

    event BridgeDeposit(address indexed sender, uint256 indexed targetChainGuid, address targetLockerAddress, address indexed targetAddress, uint256 amount);
    event BridgeWithdraw(address indexed sender, address indexed targetAddress,  uint256 amount);
    event BridgeRefund(address indexed sender, address indexed sourceAddress, uint256 amount);

    event LiquidityAdd(address indexed sender, address indexed to, uint256 amount);
    event LiquidityRemove(address indexed sender, uint256 indexed targetChainGuid, address targetLockerAddress, address indexed targetAddress, uint256 amount);
    event LiquidityWithdraw(address indexed sender, uint256 indexed targetChainGuid, address targetLockerAddress, address indexed targetAddress, uint256 amount);
    event LiquidityRefund(address indexed sender, address indexed sourceAddress, uint256 amount);

    function __AbstractLocker_init(
        uint256 _chainGuid,
        address _lockerToken,
        address _oracleAddress,
        address _feeAddress,
        uint16 _feeBP
    ) internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __AbstractLocker_init_unchained(_chainGuid, _lockerToken, _oracleAddress, _feeAddress, _feeBP);
    }

    function __AbstractLocker_init_unchained(
        uint256 _chainGuid,
        address _lockerToken,
        address _oracleAddress,
        address _feeAddress,
        uint16 _feeBP
    ) internal initializer {
        require(_feeBP <= 10000, "initialize: invalid fee");

        uint256 _evmChainId;
        assembly {
            _evmChainId := chainid()
        }
        chainGuid = _chainGuid;
        evmChainId = _evmChainId;
        lockerToken = _lockerToken;
        feeAddress = _feeAddress;
        feeBP = _feeBP;
        maintenanceMode = false;
        oracles[_oracleAddress] = true;

        bytes32 _ORACLE_DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256("BAG Locker Oracle"),
            keccak256("2"),
            _evmChainId,
            address(this)
        ));
        ORACLE_DOMAIN_SEPARATOR = _ORACLE_DOMAIN_SEPARATOR;

        setupTokenDecimals();
    }

    modifier live {
        require(!maintenanceMode, "locker: maintenance mode");
        _;
    }

    function setupTokenDecimals() public virtual onlyOwner {
        tokenDecimals = IERC20Decimals(lockerToken).decimals();
    }

    function setFeeAddress(address _feeAddress) external {
        require(msg.sender == feeAddress, "setFeeAddress: not authorized");
        feeAddress = _feeAddress;
    }

    function setFeeBP(uint16 _feeBP) external onlyOwner {
        require(_feeBP <= 10000, "setFeeBP: invalid fee");
        feeBP = _feeBP;
    }

    function addOracleAddress(address _oracleAddress) external onlyOwner {
        oracles[_oracleAddress] = true;
    }

    function removeOracleAddress(address _oracleAddress) external onlyOwner {
        oracles[_oracleAddress] = false;
    }

    function setMaintenanceMode(bool _maintenanceMode) external onlyOwner {
        maintenanceMode = _maintenanceMode;
    }

    function isClaimed(uint256 _claimId) external view returns (bool, uint256, uint256) {
        return (claims[_claimId], block.timestamp, block.number);
    }

    function bridgeDeposit(
        uint256 _targetChainGuid,
        address _targetLockerAddress,
        address _targetAddress,
        uint256 _amount,
        uint256 _deadline
    ) external live {
        require(_targetChainGuid != chainGuid || _targetLockerAddress != address(this), 'bridgeDeposit: same locker');
        require(_amount > 0, 'bridgeDeposit: zero amount');
        require(_deadline >= block.timestamp, 'bridgeDeposit: invalid deadline');


        _receiveTokens(msg.sender, _amount);

        emit BridgeDeposit(msg.sender, _targetChainGuid, _targetLockerAddress, _targetAddress, _amount);
    }

    function bridgeWithdraw(
        uint256 _claimId,
        uint256 _targetChainGuid,
        address _targetLockerAddress,
        address _targetAddress,
        uint256 _amount,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        require(chainGuid == _targetChainGuid, 'bridgeWithdraw: wrong chain');
        require(address(this) == _targetLockerAddress, 'bridgeWithdraw: wrong locker');
        require(_deadline >= block.timestamp, 'bridgeWithdraw: claim expired');
        require(claims[_claimId] == false, 'bridgeWithdraw: claim used');
        require(IERC20Decimals(lockerToken).decimals() == tokenDecimals, 'bridgeWithdraw: bad decimals');

        uint256 feeAmount = _amount * feeBP / 10000;
        uint256 netAmount = _amount - feeAmount;

        bytes32 values = keccak256(abi.encode(
            BRIDGE_WITHDRAW_TYPEHASH,
            _claimId, _targetChainGuid, _targetLockerAddress, _targetAddress, _amount, _deadline
        ));
        _verify(values, _v, _r, _s);

        claims[_claimId] = true;

        if (feeAmount > 0) {
            _sendFees(feeAmount);
        }
        _sendTokens(_targetAddress, netAmount);

        emit BridgeWithdraw(msg.sender, _targetAddress, _amount);
    }

    function bridgeRefund(
        uint256 _claimId,
        uint256 _sourceChainGuid,
        address _sourceLockerAddress,
        address _sourceAddress,
        uint256 _amount,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        require((chainGuid == _sourceChainGuid) && (address(this) == _sourceLockerAddress), 'bridgeRefund: wrong chain');
        require(claims[_claimId] == false, 'bridgeRefund: claim used');
        require(IERC20Decimals(lockerToken).decimals() == tokenDecimals, 'bridgeRefund: bad decimals');

        bytes32 values = keccak256(abi.encode(
            BRIDGE_REFUND_TYPEHASH,
            _claimId, _sourceChainGuid, _sourceLockerAddress, _sourceAddress, _amount
        ));
        _verify(values, _v, _r, _s);

        claims[_claimId] = true;

        _sendTokens(_sourceAddress, _amount);

        emit BridgeRefund(msg.sender, _sourceAddress, _amount);
    }


    function liquidityWithdraw(
        uint256 _claimId,
        uint256 _targetChainGuid,
        address _targetLockerAddress,
        address _targetAddress,
        uint256 _amount,
        uint256 _deadline,
        bool _bypassFee,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        require(chainGuid == _targetChainGuid, 'liquidityWithdraw: wrong chain');
        require(address(this) == _targetLockerAddress, 'liquidityWithdraw: wrong locker');
        require(_deadline >= block.timestamp, 'liquidityWithdraw: claim expired');
        require(claims[_claimId] == false, 'liquidityWithdraw: claim used');
        require(IERC20Decimals(lockerToken).decimals() == tokenDecimals, 'liquidityWithdraw: bad decimals');

        bytes32 values = keccak256(abi.encode(
            LIQUIDITY_WITHDRAW_TYPEHASH,
            _claimId, _targetChainGuid, _targetLockerAddress, _targetAddress, _amount, _deadline, _bypassFee
        ));
        _verify(values, _v, _r, _s);

        claims[_claimId] = true;

        uint256 feeAmount = _bypassFee ? 0 : _amount * feeBP / 10000;
        uint256 netAmount = _amount - feeAmount;
        if (feeAmount > 0) {
            _sendFees(feeAmount);
        }
        _sendTokens(_targetAddress, netAmount);

        emit LiquidityWithdraw(msg.sender, _targetChainGuid, _targetLockerAddress, _targetAddress, _amount);
    }

    function _verify(
        bytes32 _values,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal view {
        bytes32 digest = keccak256(abi.encodePacked(
            EIP191_PREFIX_FOR_EIP712_STRUCTURED_DATA,
            ORACLE_DOMAIN_SEPARATOR,
            _values
        ));
        address recoveredAddress = ECDSAUpgradeable.recover(digest, _v, _r, _s);
        require(oracles[recoveredAddress], 'verify: tampered sig');
    }

    function _receiveTokens(
        address _fromAddress,
        uint256 _amount
    ) virtual internal;

    function _sendTokens(
        address _toAddress,
        uint256 _amount
    ) virtual internal;

    function _sendFees(
        uint256 _feeAmount
    ) virtual internal;

    uint256[50] private __gap;
}// MIT

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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
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

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

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
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC20Burnable_init_unchained();
    }

    function __ERC20Burnable_init_unchained() internal initializer {
    }
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library CountersUpgradeable {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}//MIT

pragma solidity 0.8.4;



contract BalanceLocker_v30 is Initializable, ContextUpgradeable, OwnableUpgradeable,
    ERC20BurnableUpgradeable, AbstractLocker_v30
{

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    string private constant _LP_NAME = 'BAG Bridge LP';
    string private constant _LP_SYMBOL = 'BBLP';
    uint8 private _decimals;
    uint256 public lpFeeShareBP;
    uint256 public lpLockerTokenBalance;
    uint256 public lpLockerTokenBalanceCap;


    bytes32 private constant LIQUIDITY_REFUND_TYPEHASH=keccak256(abi.encodePacked(
        "LiquidityRefund(uint256 claimId,uint256 sourceChainGuid,address sourceLockerAddress,address sourceAddress,uint256 amount,uint256 deadline)"
    ));

    function initialize(
        uint256 _chainGuid,
        address _lockerToken,
        address _oracleAddress,
        address _feeAddress,
        uint16 _feeBP,
        uint16 _lpFeeShareBP,
        uint256 _lpLockerTokenBalanceCap
    ) public initializer {

        __BalanceLocker_init(_chainGuid, _lockerToken, _oracleAddress, _feeAddress, _feeBP,
            _lpFeeShareBP, _lpLockerTokenBalanceCap);
    }

    function __BalanceLocker_init(
        uint256 _chainGuid,
        address _lockerToken,
        address _oracleAddress,
        address _feeAddress,
        uint16 _feeBP,
        uint16 _lpFeeShareBP,
        uint256 _lpLockerTokenBalanceCap
    ) internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
        __ERC20_init_unchained(_LP_NAME, _LP_SYMBOL);
        _decimals = 18;
        __ERC20Burnable_init_unchained();
        __AbstractLocker_init_unchained(_chainGuid, _lockerToken, _oracleAddress, _feeAddress, _feeBP);
        __BalanceLocker_init_unchained(_lpFeeShareBP, _lpLockerTokenBalanceCap);
    }

    function __BalanceLocker_init_unchained(
        uint16 _lpFeeShareBP,
        uint256 _lpLockerTokenBalanceCap
    ) internal initializer {

        require(_lpFeeShareBP <= 10000, 'initialize: invalid lpFeeShareBP');

        lpLockerTokenBalance = 0;
        lpFeeShareBP = _lpFeeShareBP;
        lpLockerTokenBalanceCap = _lpLockerTokenBalanceCap;
    }

    function setLpLockerTokenBalanceCap(uint256 _cap) external onlyOwner {

        lpLockerTokenBalanceCap = _cap;
    }


    function _receiveTokens(
        address _fromAddress,
        uint256 _amount
    ) virtual internal override {

        IERC20Upgradeable(lockerToken).safeTransferFrom(
            address(_fromAddress),
            address(this),
            _amount
        );
    }

    function _sendTokens(
        address _toAddress,
        uint256 _amount
    ) virtual internal override {

        require(IERC20Upgradeable(lockerToken).balanceOf(address(this)) >= _amount,
            'sendTokens: insufficient funds');
        IERC20Upgradeable(lockerToken).safeTransfer(
            address(_toAddress),
            _amount
        );
    }

    function _sendFees(
        uint256 _feeAmount
    ) virtual internal override {

        uint256 lpFeeAmount = _feeAmount * lpFeeShareBP / 10000;
        uint256 netFeeAmount = _feeAmount - lpFeeAmount;

        lpLockerTokenBalance = lpLockerTokenBalance + lpFeeAmount;
        _sendTokens(feeAddress, netFeeAmount);
    }



    function calcNewLiquidity(
        uint256 _newAmount
    ) view internal returns (uint liquidity) {

        uint256 totalSupply = totalSupply();
        if (totalSupply == 0) {
            liquidity = _newAmount;
        } else {
            liquidity = _newAmount * totalSupply / lpLockerTokenBalance;
        }
    }

    function liquidityAdd(
        uint256 _amount,
        address _to,
        uint256 _deadline
    ) external {

        require(_deadline >= block.timestamp, 'liquidityAdd: expired');
        require(_amount > 0, 'liquidityAdd: zero amount');
        require(lpLockerTokenBalance + _amount < lpLockerTokenBalanceCap, 'liquidityAdd: cap exceeded');

        uint256 liquidity = calcNewLiquidity(_amount);
        lpLockerTokenBalance = lpLockerTokenBalance + _amount;

        _receiveTokens(msg.sender, _amount);

        _mint(_to, liquidity);
        emit LiquidityAdd(msg.sender, _to, _amount);
    }

    function liquidityRemove(
        uint256 _targetChainGuid,
        address _targetLockerAddress,
        address _targetAddress,
        uint256 _liquidity,
        bool _payImmediateFee,
        uint256 _deadline
    ) external {

        require(_deadline >= block.timestamp, 'liquidityRemove: expired');
        require(_liquidity > 0, 'liquidityRemove: zero liquidity');
        bool sameLocker = (address(this) == _targetLockerAddress) && (chainGuid == _targetChainGuid);
        require(!(_payImmediateFee && sameLocker), 'liquidityRemove: invalid fee');
        uint256 totalSupply = totalSupply();
        require(_liquidity <= totalSupply, 'liquidityRemove: invalid liquidity');

        uint256 removedAmount = lpLockerTokenBalance * _liquidity / totalSupply;
        require(lpLockerTokenBalance >= removedAmount, 'liquidityRemove: negative balance');
        lpLockerTokenBalance = lpLockerTokenBalance - removedAmount;

        burn(_liquidity);
        if (sameLocker) {
            _sendTokens(_targetAddress, removedAmount);
        }
        emit LiquidityRemove(msg.sender, _targetChainGuid, _targetLockerAddress, _targetAddress, removedAmount);
    }

    function liquidityRefund(
        uint256 _claimId,
        uint256 _sourceChainGuid,
        address _sourceLockerAddress,
        address _sourceAddress,
        uint256 _amount,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {

        require(_deadline >= block.timestamp, 'liquidityRefund: expired');
        require(chainGuid == _sourceChainGuid, 'liquidityRefund: wrong chain');
        require(address(this) == _sourceLockerAddress, 'liquidityRefund: wrong locker');
        require(claims[_claimId] == false, 'liquidityRefund: claim used');
        require(IERC20Decimals(lockerToken).decimals() == tokenDecimals, 'liquidityRefund: bad decimals');

        bytes32 values = keccak256(abi.encode(
            LIQUIDITY_REFUND_TYPEHASH,
            _claimId, _sourceChainGuid, _sourceLockerAddress, _sourceAddress, _amount, _deadline
        ));
        _verify(values, _v, _r, _s);

        claims[_claimId] = true;
        uint256 liquidity = calcNewLiquidity(_amount);
        lpLockerTokenBalance = lpLockerTokenBalance + _amount;

        _mint(_sourceAddress, liquidity);

        emit LiquidityRefund(msg.sender, _sourceAddress, _amount);
    }

    function setupTokenDecimals() public override onlyOwner {

        super.setupTokenDecimals();
        require(tokenDecimals<=255, 'setupTokenDecimals: invalid decimals');
        _decimals = tokenDecimals;
    }

    function decimals() public view override returns (uint8) {

        return _decimals;
    }

    uint256[50] private __gap;
}