


pragma solidity >=0.5.0;

interface ISwapXV1Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, address pToken, uint);

    function feeTo() external view returns (address);


    function setter() external view returns (address);


    function miner() external view returns (address);


    function token2Pair(address token) external view returns (address pair);


    function pair2Token(address pair) external view returns (address pToken);


    function getPair(address tokenA, address tokenB) external view returns (address pair);


    function allPairs(uint) external view returns (address pair);


    function pairTokens(uint) external view returns (address pair);


    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair, address pToken);


    function setFeeTo(address) external;


    function setSetter(address) external;


    function setMiner(address) external;


}



pragma solidity >=0.5.0;

library AddressStringUtil {

    function toAsciiString(address addr, uint len) pure internal returns (string memory) {

        require(len % 2 == 0 && len > 0 && len <= 40, "AddressStringUtil: INVALID_LEN");

        bytes memory s = new bytes(len);
        uint addrNum = uint(addr);
        for (uint i = 0; i < len / 2; i++) {
            uint8 b = uint8(addrNum >> (8 * (19 - i)));
            uint8 hi = b >> 4;
            uint8 lo = b - (hi << 4);
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(uint8 b) pure private returns (byte c) {

        if (b < 10) {
            return byte(b + 0x30);
        } else {
            return byte(b + 0x37);
        }
    }
}



pragma solidity >=0.5.0;


library SafeERC20Namer {

    function bytes32ToString(bytes32 x) pure private returns (string memory) {

        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = x[j];
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function parseStringData(bytes memory b) pure private returns (string memory) {

        uint charCount = 0;
        for (uint i = 32; i < 64; i++) {
            charCount <<= 8;
            charCount += uint8(b[i]);
        }

        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint i = 0; i < charCount; i++) {
            bytesStringTrimmed[i] = b[i + 64];
        }

        return string(bytesStringTrimmed);
    }

    function addressToName(address token) pure private returns (string memory) {

        return AddressStringUtil.toAsciiString(token, 40);
    }

    function addressToSymbol(address token) pure private returns (string memory) {

        return AddressStringUtil.toAsciiString(token, 6);
    }

    function callAndParseStringReturn(address token, bytes4 selector) view private returns (string memory) {

        (bool success, bytes memory data) = token.staticcall(abi.encodeWithSelector(selector));
        if (!success || data.length == 0) {
            return "";
        }
        if (data.length == 32) {
            bytes32 decoded = abi.decode(data, (bytes32));
            return bytes32ToString(decoded);
        } else if (data.length > 64) {
            return abi.decode(data, (string));
        }
        return "";
    }

    function tokenSymbol(address token) internal view returns (string memory) {

        string memory symbol = callAndParseStringReturn(token, 0x95d89b41);
        if (bytes(symbol).length == 0) {
            return addressToSymbol(token);
        }
        return symbol;
    }

    function tokenName(address token) internal view returns (string memory) {

        string memory name = callAndParseStringReturn(token, 0x06fdde03);
        if (bytes(name).length == 0) {
            return addressToName(token);
        }
        return name;
    }
}


pragma solidity >=0.5.0;


library PairNamer {

    string private constant TOKEN_SYMBOL_PREFIX = '🔀';
    string private constant TOKEN_SEPARATOR = ':';

    function pairName(address token0, address token1, string memory prefix, string memory suffix) internal view returns (string memory) {

        return string(
            abi.encodePacked(
                prefix,
                SafeERC20Namer.tokenName(token0),
                TOKEN_SEPARATOR,
                SafeERC20Namer.tokenName(token1),
                suffix
            )
        );
    }

    function pairSymbol(address token0, address token1, string memory suffix) internal view returns (string memory) {

        return string(
            abi.encodePacked(
                TOKEN_SYMBOL_PREFIX,
                SafeERC20Namer.tokenSymbol(token0),
                TOKEN_SEPARATOR,
                SafeERC20Namer.tokenSymbol(token1),
                suffix
            )
        );
    }

    function pairPtSymbol(address token0, address token1, string memory suffix) internal view returns (string memory) {

        return string(
            abi.encodePacked(
                SafeERC20Namer.tokenSymbol(token0),
                SafeERC20Namer.tokenSymbol(token1),
                suffix
            )
        );
    }
}


pragma solidity >=0.5.16;


library SafeMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}


pragma solidity >=0.5.0;

interface ISwapXToken {

    function initialize(string calldata name, string calldata sym, uint maxSupply) external;


    function transferOwnership(address newOwner) external;


    function verify(bool verified) external;


    function verified() external returns (bool);


    function addIssuer(address _addr) external returns (bool);


    function removeIssuer(address _addr) external returns (bool);


    function issue(address account, uint256 amount) external returns (bool);

}


pragma solidity >=0.5.0;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}


pragma solidity ^0.5.16;

contract SwapXPTStorage {

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    uint256 internal _totalSupply;
    uint256 internal _maxSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    address owner;
    mapping(address => bool) internal issuer;
}


pragma solidity ^0.5.16;





contract SwapXToken is SwapXPTStorage, IERC20, ISwapXToken {


    using SafeMath for uint;

    bool public verified;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {

        require(_isOwner(), "Caller is not the owner");
        _;
    }

    modifier onlyIssuer() {

        require(issuer[msg.sender], "The caller does not have issuer role privileges");
        _;
    }

    constructor () public {
        _decimals = 18;
        verified = false;
        owner = msg.sender;
        issuer[msg.sender] = true;
    }

    function initialize(string memory name, string memory sym, uint maxSupply) onlyOwner public {

        _symbol = sym;
        _name = name;
        if (maxSupply != 0) {
            _maxSupply = maxSupply;
        }

    }

    function isOwner() external view returns (bool) {

        return _isOwner();
    }

    function _isOwner() internal view returns (bool) {

        return msg.sender == owner;
    }
    function transferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function decimals() external view returns (uint8) {

        return _decimals;
    }

    function totalSupply() external view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender) external view returns (uint256) {

        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 value) external returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external  returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function issue(address account, uint256 amount) external onlyIssuer returns (bool) {

        _mint(account, amount);
        return true;
    }
    function addIssuer(address _addr) external onlyOwner returns (bool){

        require(_addr != address(0), "address cannot be 0");
        if (issuer[_addr] == false) {
            issuer[_addr] = true;
            return true;
        }
        return false;
    }

    function removeIssuer(address _addr) external onlyOwner returns (bool) {

        require(_addr != address(0), "address cannot be 0");
        if (issuer[_addr] == true) {
            issuer[_addr] = false;
            return true;
        }
        return false;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);

        require(_totalSupply <= _maxSupply, "ERC20: supply amount cannot over maxSupply");

        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _approve(address _owner, address spender, uint256 value) internal {

        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = value;
        emit Approval(_owner, spender, value);
    }

    function verify(bool _verified) onlyIssuer external{

        verified = _verified;
    }
}


pragma solidity >=0.5.0;

interface ISwapXV1Pair {

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

}


pragma solidity >=0.5.0;

interface ISwapXV1ERC20 {

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

}


pragma solidity =0.5.16;



contract SwapXV1ERC20 is ISwapXV1ERC20 {

    using SafeMath for uint;

    string public constant name = 'S-Token';
    string public symbol = 'S-Token';
    uint8 public constant decimals = 18;
    uint  public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) public nonces;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor() public {
        uint chainId;
        assembly {
            chainId := chainid
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint value) internal {

        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {

        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {

        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external {

        require(deadline >= block.timestamp, 'SwapXV1: EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'SwapXV1: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}


pragma solidity =0.5.16;


library Math {

    function min(uint x, uint y) internal pure returns (uint z) {

        z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {

        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


pragma solidity =0.5.16;



library UQ112x112 {

    uint224 constant Q112 = 2**112;

    function encode(uint112 y) internal pure returns (uint224 z) {

        z = uint224(y) * Q112; // never overflows
    }

    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {

        z = x / uint224(y);
    }
}


pragma solidity >=0.5.0;

interface ISwapXV1Callee {

    function swapXV1Call(address sender, uint amount0, uint amount1, bytes calldata data) external;

}


pragma solidity =0.5.16;









contract SwapXV1Pair is ISwapXV1Pair, SwapXV1ERC20 {

    using SafeMath  for uint;
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;
    address public token0;
    address public token1;

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint private unlocked = 1;
    modifier lock() {

        require(unlocked == 1, 'SwapXV1: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {

        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint value) private {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SwapXV1: TRANSFER_FAILED');
    }

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

    constructor() public {
        factory = msg.sender;
    }

    function initialize(address _token0, address _token1) external {

        require(msg.sender == factory, 'SwapXV1: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
        symbol = string(
            abi.encodePacked(
                IERC20(token0).symbol(),
                IERC20(token1).symbol(),
                "S"
            )
        );

    }

    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {

        require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'SwapXV1: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {

        address feeTo = ISwapXV1Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint denominator = rootK.mul(5).add(rootKLast);
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function mint(address to) external lock returns (uint liquidity) {

        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'SwapXV1: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    function burn(address to) external lock returns (uint amount0, uint amount1) {

        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                // gas savings
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'SwapV1: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {

        require(amount0Out > 0 || amount1Out > 0, 'SwapXV1: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'SwapXV1: INSUFFICIENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        { // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, 'SwapXV1: INVALID_TO');
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
            if (data.length > 0) ISwapXV1Callee(to).swapXV1Call(msg.sender, amount0Out, amount1Out, data);
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'SwapXV1: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
            uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
            require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(1000**2), 'SwapXV1: K');
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
    }

    function sync() external lock {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }

}



pragma solidity =0.5.16;






contract SwapXV1Factory is ISwapXV1Factory {

    address public feeTo;
    address public setter;
    address public miner;

    mapping(address => mapping(address => address)) public getPair;
    mapping(address => address) public token2Pair;
    mapping(address => address) public pair2Token;
    address[] public allPairs;
    address[] public pairTokens;

    event PairCreated(address indexed token0, address indexed token1, address pair, address indexed ptoken, uint);

    constructor(address _setter) public {
        require(_setter != address(0), 'SwapxV1: SETTER INVALID');
        setter = _setter;
    }

    function allPairsLength() external view returns (uint) {

        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair, address pToken) {

        require(miner != address(0), 'SwapxV1: MINER INVALID');
        require(tokenA != tokenB, 'SwapxV1: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'SwapxV1: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'SwapxV1: PAIR_EXISTS');

        bytes memory bytecode = type(SwapXV1Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        bytes memory bytecode1 = type(SwapXToken).creationCode;

        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
            pToken := create2(0, add(bytecode1, 32), mload(bytecode1), salt)
        }
        ISwapXV1Pair(pair).initialize(token0, token1);
        ISwapXToken(pToken).initialize("Pair Token", PairNamer.pairPtSymbol(tokenA, tokenB, "X"), 5760000 * 10 ** 18);
        ISwapXToken(pToken).addIssuer(miner);
        ISwapXToken(pToken).transferOwnership(setter);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        token2Pair[pToken] = pair;
        pair2Token[pair] = pToken;
        allPairs.push(pair);
        pairTokens.push(pToken);
        emit PairCreated(token0, token1, pair, pToken, allPairs.length);
    }

    function setMiner(address _miner) external {

        require(isContract(_miner), "SwapXV1: MINER MUST BE CONTRACT");
        require(msg.sender == setter, 'SwapXV1: FORBIDDEN');
        miner = _miner;
    }

    function setFeeTo(address _feeTo) external {

        require(msg.sender == setter, 'SwapXV1: FORBIDDEN');
        feeTo = _feeTo;
    }


    function setSetter(address _setter) external {

        require(false,"SwapXV1: NOT SUPPORT");
    }

    function isContract(address addr) internal view returns (bool) {

        uint size;
        assembly {size := extcodesize(addr)}
        return size > 0;
    }
}