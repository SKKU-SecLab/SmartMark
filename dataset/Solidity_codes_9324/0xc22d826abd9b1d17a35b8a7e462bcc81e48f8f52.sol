
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

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
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
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
pragma solidity 0.8.9;


interface IGovernance {

    function notifyAccVolumeUpdated(uint checkpoint, uint accVolumeX2) external;

}// MIT
pragma solidity 0.8.9;


interface IDistributor {

    function rewardToken() external view returns (address);

    function reserves() external view returns (uint);


    function stake(uint amount) external;

    function unstake(uint amount) external;

    function claim() external;

    function exit() external;


    function notifyRewardDistributed(uint rewardAmount) external;

    function stakeBehalf(address account, uint amount) external;

}// MIT
pragma solidity 0.8.9;


library LibGovernance {

    bytes32 constant _MINT_PACKED_TYPEHASH = 0x3f51e172eac209b5c99a91c13ae7a166bcd49d068af4f27f3aa08d4c6268e204;

    struct AccountCursor {
        uint checkpoint;
        uint nonce;
    }

    struct MintPacked {
        address account;
        uint checkpoint;
        uint volume;
        uint nonce;
    }

    struct MintExecution {
        MintPacked p;
        bytes sig;
    }

    function recover(MintExecution memory exec, bytes32 domainSeparator) internal pure returns (address) {

        MintPacked memory packed = exec.p;
        bytes memory signature = exec.sig;
        require(signature.length == 65, "invalid signature length");

        bytes32 structHash;
        bytes32 digest;

        assembly {
            let dataStart := sub(packed, 32)
            let temp := mload(dataStart)
            mstore(dataStart, _MINT_PACKED_TYPEHASH)
            structHash := keccak256(dataStart, 160)
            mstore(dataStart, temp)
        }

        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, "\x19\x01")
            mstore(add(freeMemoryPointer, 2), domainSeparator)
            mstore(add(freeMemoryPointer, 34), structHash)
            digest := keccak256(freeMemoryPointer, 66)
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "invalid signature 's' value");

        address signer;

        if (v > 30) {
            require(v - 4 == 27 || v - 4 == 28, "invalid signature 'v' value");
            signer = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", digest)), v - 4, r, s);
        } else {
            require(v == 27 || v == 28, "invalid signature 'v' value");
            signer = ecrecover(digest, v, r, s);
        }
        return signer;
    }
}// MIT
pragma solidity 0.8.9;


interface IERC20Meta {

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address to, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address from, address to, uint amount) external returns (bool);

}// MIT
pragma solidity 0.8.9;



library LibTransfer {

    function available(IERC20Meta token, address owner, address spender) internal view returns (uint) {

        uint _allowance = token.allowance(owner, spender);
        uint _balance = token.balanceOf(owner);
        return _allowance < _balance ? _allowance : _balance;
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success, ) = to.call{ value: value }(new bytes(0));
        require(success, "!safeTransferETH");
    }

    function safeApprove(IERC20Meta token, address to, uint value) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(IERC20Meta token, address to, uint value) internal {

        bytes4 selector_ = token.transfer.selector;
        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, selector_)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff))
            mstore(add(freeMemoryPointer, 36), value)

            if iszero(call(gas(), token, 0, freeMemoryPointer, 68, 0, 0)) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
        require(_getLastTransferResult(token), "!safeTransfer");
    }

    function safeTransferFrom(IERC20Meta token, address from, address to, uint value) internal {

        bytes4 selector_ = token.transferFrom.selector;
        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, selector_)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff))
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff))
            mstore(add(freeMemoryPointer, 68), value)

            if iszero(call(gas(), token, 0, freeMemoryPointer, 100, 0, 0)) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
        require(_getLastTransferResult(token), "!safeTransferFrom");
    }

    function _getLastTransferResult(IERC20Meta token) private view returns (bool success) {

        assembly {
            function revertWithMessage(length, message) {
                mstore(0x00, "\x08\xc3\x79\xa0")
                mstore(0x04, 0x20)
                mstore(0x24, length)
                mstore(0x44, message)
                revert(0x00, 0x64)
            }

            switch returndatasize()
            case 0 {
                if iszero(extcodesize(token)) {
                    revertWithMessage(20, "!contract")
                }
                success := 1
            }
            case 32 {
                returndatacopy(0, 0, returndatasize())
                success := iszero(iszero(mload(0)))
            }
            default {
                revertWithMessage(31, "!transferResult")
            }
        }
    }
}// MIT
pragma solidity 0.8.9;



contract OscilloToken is IGovernance, OwnableUpgradeable, ERC20Upgradeable {

    using LibGovernance for LibGovernance.MintExecution;

    bytes32 private constant _DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;
    bytes32 private constant _DOMAIN_VERSION = 0x0984d5efd47d99151ae1be065a709e56c602102f24c1abc4008eb3f815a8d217;
    bytes32 private constant _DOMAIN_NAME = 0xd8847acffb1e80c967781c9cefc950c79c285c67014ab8ca7bfb053adcb94e20;

    uint public constant TREASURY_CAPACITY = 18000e21;
    uint public constant SHARE_RATIO = 1765;

    uint public constant DIST_CAPACITY = 102000e21;
    uint public constant DIST_SPEED = 1275e21;
    uint public constant DIST_INTERVAL_MIN = 160 hours;

    bytes32 private _domainSeparator;
    mapping(address => bool) private _whitelist;

    mapping(uint => uint) private _accVolumes;
    mapping(address => LibGovernance.AccountCursor) private _cursors;

    uint public accBooked;
    uint public accMinted;
    address public distributor;

    uint public lastCheckpoint;
    uint public lastCheckpointTime;

    event Minted(address indexed account, uint amount);
    event AccVolumeUpdated(uint indexed checkpoint, uint accVolume);

    modifier onlyWhitelisted {

        require(msg.sender != address(0) && _whitelist[msg.sender], "!whitelist");
        _;
    }


    function initialize() external initializer {

        __Ownable_init();
        __ERC20_init("Oscillo Token", "OSC");

        require(_domainSeparator == 0);
        _domainSeparator = keccak256(abi.encode(_DOMAIN_TYPEHASH, _DOMAIN_NAME, _DOMAIN_VERSION, block.chainid, address(this)));
    }


    function cursorOf(address account) public view returns (LibGovernance.AccountCursor memory) {

        return _cursors[account];
    }

    function accVolumeOf(uint checkpoint) public view returns (uint) {

        return _accVolumes[checkpoint];
    }

    function calculate(LibGovernance.MintExecution[] calldata chunk, address account) public view returns (uint amount) {

        LibGovernance.AccountCursor memory cursor = _cursors[account];
        for (uint i = 0; i < chunk.length; i++) {
            LibGovernance.MintExecution memory e = chunk[i];
            if (e.recover(_domainSeparator) != owner() || e.p.account != account) continue;

            if (e.p.checkpoint <= cursor.checkpoint) continue;
            if (e.p.volume > _accVolumes[e.p.checkpoint]) continue;
            if (e.p.nonce != cursor.nonce + 1) continue;

            cursor.checkpoint = e.p.checkpoint;
            cursor.nonce = e.p.nonce++;
            amount += e.p.volume * DIST_SPEED / _accVolumes[e.p.checkpoint];
        }
        amount = amount - (amount * SHARE_RATIO / 10000);
    }


    function mint(LibGovernance.MintExecution[] calldata chunk, bool stake) external {

        uint amount;

        LibGovernance.AccountCursor storage cursor = _cursors[msg.sender];
        for (uint i = 0; i < chunk.length; i++) {
            LibGovernance.MintExecution memory e = chunk[i];
            require(e.recover(_domainSeparator) == owner() && e.p.account == msg.sender, "!sig");

            require(e.p.checkpoint > cursor.checkpoint, "!checkpoint");
            require(e.p.volume <= _accVolumes[e.p.checkpoint], "!volume");
            require(e.p.nonce == cursor.nonce + 1, "!nonce");

            cursor.checkpoint = e.p.checkpoint;
            cursor.nonce = e.p.nonce++;
            amount += e.p.volume * DIST_SPEED / _accVolumes[e.p.checkpoint];
        }
        require(amount > 0 && accMinted + amount <= DIST_CAPACITY, "!capacity");
        accMinted += amount;

        uint shared = amount * SHARE_RATIO / 10000;
        _transferOut(owner(), shared, true);
        _transferOut(msg.sender, amount - shared, stake);
        emit Minted(msg.sender, amount - shared);
    }


    function setWhitelist(address target, bool on) external onlyOwner {

        require(target != address(0), "!target");
        _whitelist[target] = on;
    }

    function notifyAccVolumeUpdated(uint checkpoint, uint accVolume) external override onlyWhitelisted {

        require(_accVolumes[checkpoint] == 0 && checkpoint <= block.number, "!checkpoint.block");
        require(block.timestamp >= lastCheckpointTime + DIST_INTERVAL_MIN, "!checkpoint.time");
        require(accBooked + DIST_SPEED <= DIST_CAPACITY, "!capacity");

        accBooked += DIST_SPEED;
        _accVolumes[checkpoint] = accVolume;
        lastCheckpoint = checkpoint;
        lastCheckpointTime = block.timestamp;
        emit AccVolumeUpdated(checkpoint, accVolume);
    }

    function setDistributor(address newDistributor) external onlyOwner {

        require(newDistributor != address(0) && newDistributor != distributor, "!distributor");
        distributor = newDistributor;
    }


    function _transferOut(address account, uint amount, bool stake) private {

        if (distributor != address(0) && stake) {
            _mint(distributor, amount);
            IDistributor(distributor).stakeBehalf(account, amount);
        } else {
            _mint(account, amount);
        }
    }
}