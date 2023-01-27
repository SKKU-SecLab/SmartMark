pragma solidity 0.6.12;

interface IBPool {

    function rebind(address token, uint balance, uint denorm) external;

    function setSwapFee(uint swapFee) external;

    function setPublicSwap(bool publicSwap) external;

    function bind(address token, uint balance, uint denorm) external;

    function unbind(address token) external;

    function gulp(address token) external;

    function isBound(address token) external view returns(bool);

    function getBalance(address token) external view returns (uint);

    function totalSupply() external view returns (uint);

    function getSwapFee() external view returns (uint);

    function isPublicSwap() external view returns (bool);

    function getDenormalizedWeight(address token) external view returns (uint);

    function getTotalDenormalizedWeight() external view returns (uint);

    function EXIT_FEE() external view returns (uint);

 
    function calcPoolOutGivenSingleIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountIn,
        uint swapFee
    )
        external pure
        returns (uint poolAmountOut);


    function calcSingleInGivenPoolOut(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint poolAmountOut,
        uint swapFee
    )
        external pure
        returns (uint tokenAmountIn);


    function calcSingleOutGivenPoolIn(
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint poolSupply,
        uint totalWeight,
        uint poolAmountIn,
        uint swapFee
    )
        external pure
        returns (uint tokenAmountOut);


    function calcPoolInGivenSingleOut(
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountOut,
        uint swapFee
    )
        external pure
        returns (uint poolAmountIn);


    function getCurrentTokens()
        external view
        returns (address[] memory tokens);

}

interface IBFactory {

    function newBPool() external returns (IBPool);

    function setBLabs(address b) external;

    function collect(IBPool pool) external;

    function isBPool(address b) external view returns (bool);

    function getBLabs() external view returns (address);

}// GPL-3.0
pragma solidity 0.6.12;


library BalancerConstants {


    uint public constant BONE = 10**18;
    uint public constant MIN_WEIGHT = BONE;
    uint public constant MAX_WEIGHT = BONE * 50;
    uint public constant MAX_TOTAL_WEIGHT = BONE * 50;
    uint public constant MIN_BALANCE = BONE / 10**6;
    uint public constant MAX_BALANCE = BONE * 10**12;
    uint public constant MIN_POOL_SUPPLY = BONE * 100;
    uint public constant MAX_POOL_SUPPLY = BONE * 10**9;
    uint public constant MIN_FEE = BONE / 10**6;
    uint public constant MAX_FEE = BONE / 10;
    uint public constant EXIT_FEE = 0;
    uint public constant MAX_IN_RATIO = BONE / 2;
    uint public constant MAX_OUT_RATIO = (BONE / 3) + 1 wei;
    uint public constant MIN_ASSET_LIMIT = 2;
    uint public constant MAX_ASSET_LIMIT = 8;
    uint public constant MAX_UINT = uint(-1);
}// GPL-3.0
pragma solidity 0.6.12;




library BalancerSafeMath {

    function badd(uint a, uint b) internal pure returns (uint) {

        uint c = a + b;
        require(c >= a, "ERR_ADD_OVERFLOW");
        return c;
    }

    function bsub(uint a, uint b) internal pure returns (uint) {

        (uint c, bool negativeResult) = bsubSign(a, b);
        require(!negativeResult, "ERR_SUB_UNDERFLOW");
        return c;
    }

    function bsubSign(uint a, uint b) internal pure returns (uint, bool) {

        if (b <= a) {
            return (a - b, false);
        } else {
            return (b - a, true);
        }
    }

    function bmul(uint a, uint b) internal pure returns (uint) {

        if (a == 0) {
            return 0;
        }

        uint c0 = a * b;
        require(c0 / a == b, "ERR_MUL_OVERFLOW");

        uint c1 = c0 + (BalancerConstants.BONE / 2);
        require(c1 >= c0, "ERR_MUL_OVERFLOW");
        uint c2 = c1 / BalancerConstants.BONE;
        return c2;
    }

    function bdiv(uint dividend, uint divisor) internal pure returns (uint) {

        require(divisor != 0, "ERR_DIV_ZERO");

        if (dividend == 0){
            return 0;
        }

        uint c0 = dividend * BalancerConstants.BONE;
        require(c0 / dividend == BalancerConstants.BONE, "ERR_DIV_INTERNAL"); // bmul overflow

        uint c1 = c0 + (divisor / 2);
        require(c1 >= c0, "ERR_DIV_INTERNAL"); //  badd require

        uint c2 = c1 / divisor;
        return c2;
    }

    function bmod(uint dividend, uint divisor) internal pure returns (uint) {

        require(divisor != 0, "ERR_MODULO_BY_ZERO");

        return dividend % divisor;
    }

    function bmax(uint a, uint b) internal pure returns (uint) {

        return a >= b ? a : b;
    }

    function bmin(uint a, uint b) internal pure returns (uint) {

        return a < b ? a : b;
    }

    function baverage(uint a, uint b) internal pure returns (uint) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

    function sqrt(uint y) internal pure returns (uint z) {

        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        }
        else if (y != 0) {
            z = 1;
        }
    }
}// GPL-3.0
pragma solidity 0.6.12;



interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);

    event Transfer(address indexed from, address indexed to, uint value);

    function totalSupply() external view returns (uint);


    function balanceOf(address account) external view returns (uint);


    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint amount) external returns (bool);


    function transfer(address recipient, uint amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

}// GPL-3.0
pragma solidity 0.6.12;





contract PCToken is IERC20 {

    using BalancerSafeMath for uint;

    string public constant NAME = "Balancer Smart Pool";
    uint8 public constant DECIMALS = 18;

    uint internal varTotalSupply;

    mapping(address => uint) private _balance;
    mapping(address => mapping(address => uint)) private _allowance;

    string private _symbol;
    string private _name;


    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);


    function _initializePCToken(string memory tokenSymbol, string memory tokenName) internal {

        _symbol = tokenSymbol;
        _name = tokenName;
    }


    function allowance(address owner, address spender) external view override returns (uint) {

        return _allowance[owner][spender];
    }

    function balanceOf(address account) external view override returns (uint) {

        return _balance[account];
    }

    function approve(address spender, uint amount) external override returns (bool) {


        _allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function increaseApproval(address spender, uint amount) external returns (bool) {

        _allowance[msg.sender][spender] = BalancerSafeMath.badd(_allowance[msg.sender][spender], amount);

        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);

        return true;
    }

    function decreaseApproval(address spender, uint amount) external returns (bool) {

        uint oldValue = _allowance[msg.sender][spender];
        if (amount >= oldValue) {
            _allowance[msg.sender][spender] = 0;
        } else {
            _allowance[msg.sender][spender] = BalancerSafeMath.bsub(oldValue, amount);
        }

        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);

        return true;
    }

    function transfer(address recipient, uint amount) external override returns (bool) {

        require(recipient != address(0), "ERR_ZERO_ADDRESS");

        _move(msg.sender, recipient, amount);

        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) external override returns (bool) {

        require(recipient != address(0), "ERR_ZERO_ADDRESS");
        require(msg.sender == sender || amount <= _allowance[sender][msg.sender], "ERR_PCTOKEN_BAD_CALLER");

        _move(sender, recipient, amount);

        uint oldAllowance = _allowance[sender][msg.sender];

        if (msg.sender != sender && oldAllowance != uint(-1)) {
            _allowance[sender][msg.sender] = BalancerSafeMath.bsub(oldAllowance, amount);

            emit Approval(msg.sender, recipient, _allowance[sender][msg.sender]);
        }

        return true;
    }


    function totalSupply() external view override returns (uint) {

        return varTotalSupply;
    }


    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function decimals() external pure returns (uint8) {

        return DECIMALS;
    }


    function _mint(uint amount) internal virtual {

        _balance[address(this)] = BalancerSafeMath.badd(_balance[address(this)], amount);
        varTotalSupply = BalancerSafeMath.badd(varTotalSupply, amount);

        emit Transfer(address(0), address(this), amount);
    }

    function _burn(uint amount) internal virtual {


        _balance[address(this)] = BalancerSafeMath.bsub(_balance[address(this)], amount);
        varTotalSupply = BalancerSafeMath.bsub(varTotalSupply, amount);

        emit Transfer(address(this), address(0), amount);
    }

    function _move(address sender, address recipient, uint amount) internal virtual {


        _balance[sender] = BalancerSafeMath.bsub(_balance[sender], amount);
        _balance[recipient] = BalancerSafeMath.badd(_balance[recipient], amount);

        emit Transfer(sender, recipient, amount);
    }

    function _push(address recipient, uint amount) internal {

        _move(address(this), recipient, amount);
    }

    function _pull(address sender, uint amount) internal {

        _move(sender, address(this), amount);
    }
}// GPL-3.0
pragma solidity 0.6.12;

contract BalancerReentrancyGuard {


    uint private constant _NOT_ENTERED = 1;
    uint private constant _ENTERED = 2;

    uint private _status;

    function _initializeReentrancyGuard() internal {

        _status = _NOT_ENTERED;
    }

    modifier lock() {

        require(_status != _ENTERED, "ERR_REENTRY");

        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

     modifier viewlock() {

        require(_status != _ENTERED, "ERR_REENTRY_VIEW");
        _;
     }
}// GPL-3.0
pragma solidity 0.6.12;

contract BalancerOwnable {


    address private _owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier onlyOwner() {

        require(_owner == msg.sender, "ERR_NOT_CONTROLLER");
        _;
    }


    function _initializeOwner() internal {

        _owner = msg.sender;
    }

    function setController(address newOwner) external onlyOwner {

        require(newOwner != address(0), "ERR_ZERO_ADDRESS");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;
    }

    function getController() external view returns (address) {

        return _owner;
    }
}