
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

pragma solidity 0.6.12;


library MathUtils {
    function within1(uint256 a, uint256 b) internal pure returns (bool) {
        return (difference(a, b) <= 1);
    }

    function difference(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a > b) {
            return a - b;
        }
        return b - a;
    }
}// MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



contract BaseBoringBatchable {
    function _getRevertMsg(bytes memory _returnData)
        internal
        pure
        returns (string memory)
    {
        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }

    function batch(bytes[] calldata calls, bool revertOnFail) external payable {
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(
                calls[i]
            );
            if (!success && revertOnFail) {
                revert(_getRevertMsg(result));
            }
        }
    }
}// MIT

pragma solidity 0.6.12;

interface IAllowlist {
    function getPoolAccountLimit(address poolAddress)
        external
        view
        returns (uint256);

    function getPoolCap(address poolAddress) external view returns (uint256);

    function verifyAddress(address account, bytes32[] calldata merkleProof)
        external
        returns (bool);
}// MIT

pragma solidity 0.6.12;


interface ISwap {
    function getA() external view returns (uint256);

    function getAPrecise() external view returns (uint256);

    function getAllowlist() external view returns (IAllowlist);

    function getToken(uint8 index) external view returns (IERC20);

    function getTokenIndex(address tokenAddress) external view returns (uint8);

    function getTokenBalance(uint8 index) external view returns (uint256);

    function getVirtualPrice() external view returns (uint256);

    function isGuarded() external view returns (bool);

    function swapStorage()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        );

    function calculateSwap(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx
    ) external view returns (uint256);

    function calculateTokenAmount(uint256[] calldata amounts, bool deposit)
        external
        view
        returns (uint256);

    function calculateRemoveLiquidity(uint256 amount)
        external
        view
        returns (uint256[] memory);

    function calculateRemoveLiquidityOneToken(
        uint256 tokenAmount,
        uint8 tokenIndex
    ) external view returns (uint256 availableTokenAmount);

    function initialize(
        IERC20[] memory pooledTokens,
        uint8[] memory decimals,
        string memory lpTokenName,
        string memory lpTokenSymbol,
        uint256 a,
        uint256 fee,
        uint256 adminFee,
        address lpTokenTargetAddress
    ) external;

    function swap(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx,
        uint256 minDy,
        uint256 deadline
    ) external returns (uint256);

    function addLiquidity(
        uint256[] calldata amounts,
        uint256 minToMint,
        uint256 deadline
    ) external returns (uint256);

    function removeLiquidity(
        uint256 amount,
        uint256[] calldata minAmounts,
        uint256 deadline
    ) external returns (uint256[] memory);

    function removeLiquidityOneToken(
        uint256 tokenAmount,
        uint8 tokenIndex,
        uint256 minAmount,
        uint256 deadline
    ) external returns (uint256);

    function removeLiquidityImbalance(
        uint256[] calldata amounts,
        uint256 maxBurnAmount,
        uint256 deadline
    ) external returns (uint256);
}// MIT

pragma solidity 0.6.12;


interface IERC20Decimals {
    function decimals() external returns (uint8);
}

contract SwapCalculator is BaseBoringBatchable {
    using SafeMath for uint256;
    using MathUtils for uint256;

    uint256 private constant BALANCE_PRECISION = 1e18;
    uint256 private constant BALANCE_DECIMALS = 18;
    uint256 private constant A_PRECISION = 100;
    uint256 private constant MAX_LOOP_LIMIT = 256;
    uint256 private constant MAX_TOKENS_LENGTH = 8;
    uint256 private constant FEE_DENOMINATOR = 10**10;

    mapping(address => uint256[]) public storedDecimals;

    function calculateSwapOutput(
        address pool,
        uint256 inputIndex,
        uint256 outputIndex,
        uint256 inputAmount
    ) external view returns (uint256 outputAmount) {
        outputAmount = ISwap(pool).calculateSwap(
            uint8(inputIndex),
            uint8(outputIndex),
            inputAmount
        );
    }

    function calculateSwapInput(
        address pool,
        uint256 inputIndex,
        uint256 outputIndex,
        uint256 outputAmount
    ) external view returns (uint256 inputAmount) {
        uint256[] memory decimalsArr = storedDecimals[pool];
        require(decimalsArr.length > 0, "Must call addPool() first");

        uint256[] memory balances = new uint256[](decimalsArr.length);
        for (uint256 i = 0; i < decimalsArr.length; i++) {
            uint256 multiplier = 10**BALANCE_DECIMALS.sub(decimalsArr[i]);
            balances[i] = ISwap(pool).getTokenBalance(uint8(i)).mul(multiplier);
        }
        outputAmount = outputAmount.mul(
            10**BALANCE_DECIMALS.sub(decimalsArr[outputIndex])
        );

        (, , , , uint256 swapFee, , ) = ISwap(pool).swapStorage();

        inputAmount = calculateSwapInputCustom(
            balances,
            ISwap(pool).getAPrecise(),
            swapFee,
            inputIndex,
            outputIndex,
            outputAmount
        ).div(10**BALANCE_DECIMALS.sub(decimalsArr[inputIndex]));
    }

    function relativePrice(
        address pool,
        uint256 inputIndex,
        uint256 outputIndex
    ) external view returns (uint256 price) {
        uint256[] memory decimalsArr = storedDecimals[pool];
        require(decimalsArr.length > 0, "Must call addPool() first");

        uint256[] memory balances = new uint256[](decimalsArr.length);
        for (uint256 i = 0; i < decimalsArr.length; i++) {
            uint256 multiplier = 10**BALANCE_DECIMALS.sub(decimalsArr[i]);
            balances[i] = ISwap(pool).getTokenBalance(uint8(i)).mul(multiplier);
        }

        price = relativePriceCustom(
            balances,
            ISwap(pool).getAPrecise(),
            inputIndex,
            outputIndex
        );
    }

    function calculateSwapOutputCustom(
        uint256[] memory balances,
        uint256 a,
        uint256 swapFee,
        uint256 inputIndex,
        uint256 outputIndex,
        uint256 inputAmount
    ) public pure returns (uint256 outputAmount) {
        require(
            inputIndex < balances.length && outputIndex < balances.length,
            "Invalid token index"
        );
        uint256 x = inputAmount.add(balances[inputIndex]);
        uint256 y = getY(a, inputIndex, outputIndex, x, balances);
        outputAmount = balances[outputIndex].sub(y).sub(1);

        uint256 fee = outputAmount.mul(swapFee).div(FEE_DENOMINATOR);
        outputAmount = outputAmount.sub(fee);
    }

    function calculateSwapInputCustom(
        uint256[] memory balances,
        uint256 a,
        uint256 swapFee,
        uint256 inputIndex,
        uint256 outputIndex,
        uint256 outputAmount
    ) public pure returns (uint256 inputAmount) {
        require(
            inputIndex < balances.length && outputIndex < balances.length,
            "Invalid token index"
        );

        uint256 fee = outputAmount.mul(swapFee).div(
            FEE_DENOMINATOR.sub(swapFee)
        );
        outputAmount = outputAmount.add(fee);

        uint256 y = balances[outputIndex].sub(outputAmount);
        uint256 x = getX(a, inputIndex, outputIndex, y, balances);
        inputAmount = x.sub(balances[inputIndex]).add(1);
    }

    function relativePriceCustom(
        uint256[] memory balances,
        uint256 a,
        uint256 inputIndex,
        uint256 outputIndex
    ) public pure returns (uint256 price) {
        return
            calculateSwapOutputCustom(
                balances,
                a,
                0,
                inputIndex,
                outputIndex,
                BALANCE_PRECISION
            );
    }

    function addPool(address pool) external payable {
        uint256[] memory decimalsArr = new uint256[](MAX_TOKENS_LENGTH);

        for (uint256 i = 0; i < MAX_TOKENS_LENGTH; i++) {
            try ISwap(pool).getToken(uint8(i)) returns (IERC20 token) {
                require(address(token) != address(0), "Token invalid");
                decimalsArr[i] = IERC20Decimals(address(token)).decimals();
            } catch {
                assembly {
                    mstore(decimalsArr, sub(mload(decimalsArr), sub(8, i)))
                }
                break;
            }
        }

        require(decimalsArr.length > 0, "Must call addPool() first");
        storedDecimals[pool] = decimalsArr;
    }

    function getD(uint256[] memory xp, uint256 a)
        internal
        pure
        returns (uint256)
    {
        uint256 numTokens = xp.length;
        uint256 s;
        for (uint256 i = 0; i < numTokens; i++) {
            s = s.add(xp[i]);
        }
        if (s == 0) {
            return 0;
        }

        uint256 prevD;
        uint256 d = s;
        uint256 nA = a.mul(numTokens);

        for (uint256 i = 0; i < MAX_LOOP_LIMIT; i++) {
            uint256 dP = d;
            for (uint256 j = 0; j < numTokens; j++) {
                dP = dP.mul(d).div(xp[j].mul(numTokens));
            }
            prevD = d;
            d = nA.mul(s).div(A_PRECISION).add(dP.mul(numTokens)).mul(d).div(
                nA.sub(A_PRECISION).mul(d).div(A_PRECISION).add(
                    numTokens.add(1).mul(dP)
                )
            );
            if (d.within1(prevD)) {
                return d;
            }
        }

        revert("D does not converge");
    }

    function getY(
        uint256 preciseA,
        uint256 tokenIndexFrom,
        uint256 tokenIndexTo,
        uint256 x,
        uint256[] memory xp
    ) internal pure returns (uint256) {
        uint256 numTokens = xp.length;
        require(
            tokenIndexFrom != tokenIndexTo,
            "Can't compare token to itself"
        );
        require(
            tokenIndexFrom < numTokens && tokenIndexTo < numTokens,
            "Tokens must be in pool"
        );

        uint256 d = getD(xp, preciseA);
        uint256 c = d;
        uint256 s;
        uint256 nA = numTokens.mul(preciseA);

        uint256 _x;
        for (uint256 i = 0; i < numTokens; i++) {
            if (i == tokenIndexFrom) {
                _x = x;
            } else if (i != tokenIndexTo) {
                _x = xp[i];
            } else {
                continue;
            }
            s = s.add(_x);
            c = c.mul(d).div(_x.mul(numTokens));
        }
        c = c.mul(d).mul(A_PRECISION).div(nA.mul(numTokens));
        uint256 b = s.add(d.mul(A_PRECISION).div(nA));
        uint256 yPrev;
        uint256 y = d;

        for (uint256 i = 0; i < MAX_LOOP_LIMIT; i++) {
            yPrev = y;
            y = y.mul(y).add(c).div(y.mul(2).add(b).sub(d));
            if (y.within1(yPrev)) {
                return y;
            }
        }
        revert("Approximation did not converge");
    }

    function getX(
        uint256 preciseA,
        uint256 tokenIndexFrom,
        uint256 tokenIndexTo,
        uint256 y,
        uint256[] memory xp
    ) internal pure returns (uint256) {
        return getY(preciseA, tokenIndexTo, tokenIndexFrom, y, xp);
    }
}