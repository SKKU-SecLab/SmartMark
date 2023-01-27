
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
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


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT
pragma solidity >=0.8.2 <0.9.0;

interface IManager {

    function isAdmin(address _user) external view returns (bool);


    function isGorvernance(address _user) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


contract ANWERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

}// MIT
pragma solidity >=0.8.2 <0.9.0;

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}// MIT
pragma solidity >=0.8.2 <0.9.0;



interface IPairERC20 is IERC20, IERC20Metadata {
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function permitSalt(address owner, uint256 salt) external view returns (bool); // replaces nonces in the UniV2 version

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 salt,
        uint256 expiry,
        bytes calldata signature
    ) external; // uses bytes signature instead of v,r,s as per the ECDSA lib
}// MIT
pragma solidity >=0.8.2 <0.9.0;


interface IPair is IPairERC20 {

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);

    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);

    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}// MIT
pragma solidity >=0.8.2 <0.9.0;

interface IPairFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
    event ChangeSwapFee(uint256 adminFee, uint256 lpFee);
    event ChangeFeeTo(address feeTo);

    function feeTo() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address);

    function allPairsLength() external view returns (uint256);

    function getFeeSwap() external view returns (uint256, uint256);

    function getInfoAdminFee()
        external
        view
        returns (
            address,
            uint256,
            uint256
        );

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setSwapFee(uint256 adminFee, uint256 lpFee) external;


    function setRouter(address) external;

    function router() external view returns (address);
}// MIT
pragma solidity >=0.8.2 <0.9.0;

interface IPairCallee {
    function pairCall(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}// MIT
pragma solidity >=0.8.2 <0.9.0;


abstract contract EIP712 {
    bytes32 private _CACHED_DOMAIN_SEPARATOR;
    uint256 private _CACHED_CHAIN_ID;

    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private _TYPE_HASH;


    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}// MIT
pragma solidity >=0.8.2 <0.9.0;




contract PairERC20 is ANWERC20, EIP712, IPairERC20 {
    bytes32 public override DOMAIN_SEPARATOR;

    bytes32 public constant override PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 salt,uint256 deadline)");

    mapping(address => mapping(uint256 => bool)) public override permitSalt;

    constructor() ANWERC20("ANW Finance LPs", "ANWFI-LP") EIP712("ANW Finance LPs", "1.0.0") {
        DOMAIN_SEPARATOR = _domainSeparatorV4();
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 salt,
        uint256 deadline,
        bytes calldata signature
    ) public virtual override {
        require(deadline >= block.timestamp, "PoolERC20::permit: EXPIRED");
        require(!permitSalt[owner][salt], "PoolERC20::permit: INVALID_SALT");

        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, salt, deadline))
        );

        address signer = ECDSA.recover(digest, signature);
        require(signer != address(0) && signer == owner, "PoolERC20::permit: INVALID_SIGNATURE");

        permitSalt[owner][salt] = true;
        _approve(owner, spender, value);
    }
}// GPL-3.0-or-later
pragma solidity >=0.8.2 <0.9.0;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferNative(address to, uint256 value) internal {
        (bool success, ) = to.call{ value: value }(new bytes(0));
        require(success, "TransferHelper::safeTransferNative: TRANSFER_FAILED");
    }
}// MIT
pragma solidity >=0.8.2 <0.9.0;











contract Pair is IPair, PairERC20, ReentrancyGuard {
    using UQ112x112 for uint224;

    uint256 public constant override MINIMUM_LIQUIDITY = 10**3;

    address public override factory;
    address public override token0;
    address public override token1;

    uint256 public override price0CumulativeLast;
    uint256 public override price1CumulativeLast;
    uint256 public override kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint112 private _reserve0; // uses single storage slot, accessible via getReserves
    uint112 private _reserve1; // uses single storage slot, accessible via getReserves
    uint32 private _blockTimestampLast; // uses single storage slot, accessible via getReserves

    modifier onlyRouter() {
        require(_msgSender() == IPairFactory(factory).router(), "Pair:onlyRouter: FORBIDDEN");
        _;
    }

    constructor() {
        factory = _msgSender();
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 salt,
        uint256 expiry,
        bytes calldata signature
    ) public override(IPairERC20, PairERC20) {
        super.permit(owner, spender, value, salt, expiry, signature);
    }

    function totalSupply() public view override(IERC20, ANWERC20) returns (uint256) {
        return super.totalSupply();
    }

    function balanceOf(address account) public view override(IERC20, ANWERC20) returns (uint256) {
        return super.balanceOf(account);
    }

    function transfer(address recipient, uint256 amount) public override(IERC20, ANWERC20) returns (bool) {
        return super.transfer(recipient, amount);
    }

    function allowance(address owner, address spender) public view override(IERC20, ANWERC20) returns (uint256) {
        return super.allowance(owner, spender);
    }

    function approve(address spender, uint256 amount) public override(IERC20, ANWERC20) returns (bool) {
        return super.approve(spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override(IERC20, ANWERC20) returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

    function name() public view override(IERC20Metadata, ANWERC20) returns (string memory) {
        return super.name();
    }

    function symbol() public view override(IERC20Metadata, ANWERC20) returns (string memory) {
        return super.symbol();
    }

    function decimals() public view override(IERC20Metadata, ANWERC20) returns (uint8) {
        return super.decimals();
    }


    function getReserves()
        public
        view
        override
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        )
    {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
        blockTimestampLast = _blockTimestampLast;
    }

    function initialize(address token0_, address token1_) external override {
        require(_msgSender() == factory, "Pair::initialize: FORBIDDEN"); // sufficient check
        token0 = token0_;
        token1 = token1_;
    }

    function _update(
        uint256 balance0,
        uint256 balance1,
        uint112 reserve0,
        uint112 reserve1
    ) private {
        require(balance0 <= type(uint112).max && balance1 <= type(uint112).max, "Pair::_update: OVERFLOW");
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed;
        unchecked {
            timeElapsed = blockTimestamp - _blockTimestampLast;
        } // overflow is desired

        if (timeElapsed > 0 && reserve0 != 0 && reserve1 != 0) {
            unchecked {
                price0CumulativeLast += uint256(UQ112x112.encode(reserve1).uqdiv(reserve0)) * timeElapsed;
            } // + overflow is desired
            unchecked {
                price1CumulativeLast += uint256(UQ112x112.encode(reserve0).uqdiv(reserve1)) * timeElapsed;
            } // + overflow is desired
        }

        _reserve0 = uint112(balance0);
        _reserve1 = uint112(balance1);
        _blockTimestampLast = blockTimestamp;

        emit Sync(_reserve0, _reserve1);
    }

    function _mintFee(uint112 reserve0, uint112 reserve1) private returns (bool feeOn) {
        address feeTo = IPairFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 kLast_ = kLast; // gas savings
        if (feeOn) {
            if (kLast_ != 0) {
                uint256 rootK = _sqrt(uint256(reserve0) * uint256(reserve1));
                uint256 rootKLast = _sqrt(kLast_);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply() * (rootK - rootKLast) * 8;
                    uint256 denominator = (rootK * 17) + (rootKLast * 8);
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (kLast_ != 0) {
            kLast = 0;
        }
    }

    function mint(address to) external override nonReentrant onlyRouter returns (uint256 liquidity) {
        (uint112 reserve0, uint112 reserve1, ) = getReserves(); // gas savings
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - reserve0;
        uint256 amount1 = balance1 - reserve1;

        bool feeOn = _mintFee(reserve0, reserve1);
        uint256 supply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        if (supply == 0) {
            liquidity = _sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first _MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min((amount0 * supply) / reserve0, (amount1 * supply) / reserve1);
        }

        require(liquidity > 0, "Pair::mint: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);

        _update(balance0, balance1, reserve0, reserve1);
        if (feeOn) kLast = uint256(_reserve0) * uint256(_reserve1); // _reserve0 and _reserve1 are up-to-date

        emit Mint(_msgSender(), amount0, amount1);
    }

    function burn(address to) external override nonReentrant onlyRouter returns (uint256 amount0, uint256 amount1) {
        (uint112 reserve0, uint112 reserve1, ) = getReserves(); // gas savings
        address token0_ = token0; // gas savings
        address token1_ = token1; // gas savings
        uint256 balance0 = IERC20(token0_).balanceOf(address(this));
        uint256 balance1 = IERC20(token1_).balanceOf(address(this));
        uint256 liquidity = balanceOf(address(this));

        bool feeOn = _mintFee(reserve0, reserve1);
        uint256 supply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = (liquidity * balance0) / supply; // using balances ensures pro-rata distribution
        amount1 = (liquidity * balance1) / supply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, "Pair::burn: INSUFFICIENT_LIQUIDITY_BURNED");
        _burn(address(this), liquidity);

        TransferHelper.safeTransfer(token0_, to, amount0);
        TransferHelper.safeTransfer(token1_, to, amount1);

        balance0 = IERC20(token0_).balanceOf(address(this));
        balance1 = IERC20(token1_).balanceOf(address(this));

        _update(balance0, balance1, reserve0, reserve1);
        if (feeOn) kLast = uint256(_reserve0) * uint256(_reserve1); // _reserve0 and _reserve1 are up-to-date

        emit Burn(_msgSender(), amount0, amount1, to);
    }

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external override nonReentrant onlyRouter {
        require(amount0Out > 0 || amount1Out > 0, "Pair::swap: INSUFFICIENT_OUTPUT_AMOUNT");
        (uint112 reserve0, uint112 reserve1, ) = getReserves(); // gas savings
        require(amount0Out < reserve0 && amount1Out < reserve1, "Pair::swap: INSUFFICIENT_LIQUIDITY");

        uint256 balance0;
        uint256 balance1;
        {
            address token0_ = token0;
            address token1_ = token1;
            require(to != token0_ && to != token1_, "Pair::swap: INVALID_TO");
            if (amount0Out > 0) TransferHelper.safeTransfer(token0_, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) TransferHelper.safeTransfer(token1_, to, amount1Out); // optimistically transfer tokens
            if (data.length > 0) IPairCallee(to).pairCall(_msgSender(), amount0Out, amount1Out, data);
            balance0 = IERC20(token0_).balanceOf(address(this));
            balance1 = IERC20(token1_).balanceOf(address(this));
        }
        uint256 amount0In = balance0 > reserve0 - amount0Out ? balance0 - (reserve0 - amount0Out) : 0;
        uint256 amount1In = balance1 > reserve1 - amount1Out ? balance1 - (reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, "Pair::swap: INSUFFICIENT_INPUT_AMOUNT");
        {
            (uint256 fee, uint256 precision) = getSwapFee();
            uint256 balance0Adjusted = (balance0 * precision) - (amount0In * fee);

            uint256 balance1Adjusted = (balance1 * precision) - (amount1In * fee);
            require(
                (balance0Adjusted * balance1Adjusted) >= (uint256(reserve0) * uint256(reserve1) * precision**2),
                "Pair::swap: K"
            );
        }

        if (amount0In > 0) {
            balance0 = balance0 - _transferFeeToAdmin(token0, amount0In);
        } else {
            balance1 = balance1 - _transferFeeToAdmin(token1, amount1In);
        }

        _update(balance0, balance1, reserve0, reserve1);
        emit Swap(_msgSender(), amount0In, amount1In, amount0Out, amount1Out, to);
    }

    function skim(address to) external override nonReentrant {
        address token0_ = token0; // gas savings
        address token1_ = token1; // gas savings
        TransferHelper.safeTransfer(token0_, to, IERC20(token0_).balanceOf(address(this)) - uint256(_reserve0));
        TransferHelper.safeTransfer(token1_, to, IERC20(token1_).balanceOf(address(this)) - uint256(_reserve1));
    }

    function sync() external override nonReentrant {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), _reserve0, _reserve1);
    }

    function _sqrt(uint256 x) private pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function getSwapFee() internal view returns (uint256, uint256) {
        return IPairFactory(factory).getFeeSwap();
    }

    function _transferFeeToAdmin(address tokenFee, uint256 amount) private returns (uint256) {
        (address feeTo, uint256 fee, uint256 precision) = IPairFactory(factory).getInfoAdminFee();
        if (feeTo == address(0)) {
            return 0;
        }
        uint256 feeAmount = (amount * fee) / precision;
        TransferHelper.safeTransfer(tokenFee, feeTo, feeAmount);
        return feeAmount;
    }
}// MIT
pragma solidity >=0.8.2 <0.9.0;


contract PairFactory is Context, IPairFactory {
    bytes32 private constant _INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(Pair).creationCode));

    address public override router;

    address public override feeTo;
    uint256 public PRECISION = 10000;
    uint256 public swapFeeForLP = 20;
    uint256 public swapFeeForAdmin = 5;
    IManager public manager;

    mapping(address => mapping(address => address)) public override getPair;

    address[] public override allPairs;

    modifier onlyAdmin() {
        require(manager.isAdmin(_msgSender()), "Pool::onlyAdmin");
        _;
    }

    modifier onlyGovernance() {
        require(manager.isGorvernance(_msgSender()), "Pool::onlyGovernance");
        _;
    }

    constructor(address _treasury, address _manager) {
        feeTo = _treasury;
        manager = IManager(_manager);
    }

    function allPairsLength() external view override returns (uint256) {
        return allPairs.length;
    }

    function getInfoAdminFee()
        public
        view
        override
        returns (
            address,
            uint256,
            uint256
        )
    {
        return (feeTo, swapFeeForAdmin, PRECISION);
    }

    function getFeeSwap() public view override returns (uint256, uint256) {
        uint256 _swapFeeForAdmin = swapFeeForAdmin;
        if (feeTo == address(0)) {
            _swapFeeForAdmin = 0;
        }
        return (swapFeeForLP + _swapFeeForAdmin, PRECISION);
    }

    function getAllPairs() public view returns (address[] memory) {
        return allPairs;
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        require(tokenA != tokenB, "PairFactory::createPair: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "PairFactory::createPair: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "PairFactory::createPair: PAIR_EXISTS"); // single check is sufficient
        bytes memory bytecode = type(Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address feeTo_) external override onlyGovernance {
        feeTo = feeTo_;
        emit ChangeFeeTo(feeTo_);
    }

    function setSwapFee(uint256 adminFee, uint256 lpFee) external override onlyGovernance {
        swapFeeForAdmin = adminFee;
        swapFeeForLP = lpFee;
        emit ChangeSwapFee(adminFee, lpFee);
    }

    function setRouter(address router_) external override onlyAdmin {
        router = router_;
    }
}