
pragma solidity ^0.7.0;

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

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

interface IStableCoin {

    function init(
        string calldata name,
        string calldata symbol,
        address doubleProxy,
        address[] calldata allowedPairs,
        uint256[] calldata rebalanceRewardMultiplier,
        uint256[] calldata timeWindows,
        uint256[] calldata mintables
    ) external;


    function tierData() external view returns(uint256[] memory, uint256[] memory);


    function availableToMint() external view returns(uint256);


    function doubleProxy() external view returns (address);


    function setDoubleProxy(address newDoubleProxy) external;


    function allowedPairs() external view returns (address[] memory);


    function setAllowedPairs(address[] calldata newAllowedPairs) external;


    function rebalanceRewardMultiplier()
        external
        view
        returns (uint256[] memory);


    function differences() external view returns (uint256, uint256);


    function calculateRebalanceByDebtReward(uint256 burnt)
        external
        view
        returns (uint256);


    function fromTokenToStable(address tokenAddress, uint256 amount)
        external
        view
        returns (uint256);


    function mint(
        uint256 pairIndex,
        uint256 amount0,
        uint256 amount1,
        uint256 amount0Min,
        uint256 amount1Min
    ) external returns (uint256);


    function burn(
        uint256 pairIndex,
        uint256 pairAmount,
        uint256 amount0,
        uint256 amount1
    ) external returns (uint256, uint256);


    function rebalanceByCredit(
        uint256 pairIndex,
        uint256 pairAmount,
        uint256 amount0,
        uint256 amount1
    ) external returns (uint256);


    function rebalanceByDebt(uint256 amount) external returns(uint256);

}

interface IDoubleProxy {

    function proxy() external view returns (address);

}

interface IMVDProxy {

    function getToken() external view returns (address);


    function getMVDFunctionalitiesManagerAddress()
        external
        view
        returns (address);


    function getMVDWalletAddress() external view returns (address);


    function getStateHolderAddress() external view returns (address);


    function submit(string calldata codeName, bytes calldata data)
        external
        payable
        returns (bytes memory returnData);

}

interface IMVDFunctionalitiesManager {

    function isAuthorizedFunctionality(address functionality)
        external
        view
        returns (bool);

}

interface IStateHolder {

    function getBool(string calldata varName) external view returns (bool);

    function getUint256(string calldata varName) external view returns (uint256);

}

interface IUniswapV2Router {

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

}

interface IUniswapV2Pair {

    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function balanceOf(address account) external view returns (uint256);


    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

}// MIT

pragma solidity ^0.7.0;


abstract contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

     function init(string memory name, string memory symbol) internal {
        require(
            keccak256(bytes(_symbol)) == keccak256(""),
            "Init already Called!"
        );
         _name = name;
         _symbol = symbol;
         _decimals = 18;
     }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {
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
        virtual
        override
        view
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
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
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
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
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

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
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

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}// MIT

pragma solidity ^0.7.0;


contract StableCoin is ERC20, IStableCoin {

    address
        private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address private _doubleProxy;

    address[] private _allowedPairs;

    uint256[] private _rebalanceRewardMultiplier;

    uint256[] private _timeWindows;

    uint256[] private _mintables;

    uint256 private _lastRedeemBlock;

    constructor(
        string memory name,
        string memory symbol,
        address doubleProxy,
        address[] memory allowedPairs,
        uint256[] memory rebalanceRewardMultiplier,
        uint256[] memory timeWindows,
        uint256[] memory mintables
    ) {
        if (doubleProxy == address(0)) {
            return;
        }
        init(
            name,
            symbol,
            doubleProxy,
            allowedPairs,
            rebalanceRewardMultiplier,
            timeWindows,
            mintables
        );
    }

    function init(
        string memory name,
        string memory symbol,
        address doubleProxy,
        address[] memory allowedPairs,
        uint256[] memory rebalanceRewardMultiplier,
        uint256[] memory timeWindows,
        uint256[] memory mintables
    ) public override {

        super.init(name, symbol);
        _doubleProxy = doubleProxy;
        _allowedPairs = allowedPairs;
        assert(rebalanceRewardMultiplier.length == 2);
        _rebalanceRewardMultiplier = rebalanceRewardMultiplier;
        assert(timeWindows.length == mintables.length);
        _timeWindows = timeWindows;
        _mintables = mintables;
    }

    function tierData()
        public
        override
        view
        returns (uint256[] memory, uint256[] memory)
    {

        return (_timeWindows, _mintables);
    }

    function availableToMint() public override view returns (uint256) {


        uint256 mintable
         = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        if(_timeWindows.length > 0 && block.number < _timeWindows[_timeWindows.length - 1]) {
            for (uint256 i = 0; i < _timeWindows.length; i++) {
                if (block.number < _timeWindows[i]) {
                    mintable = _mintables[i];
                    break;
                }
            }
        }
        uint256 minted = totalSupply();
        return minted >= mintable ? 0 : mintable - minted;
    }

    function doubleProxy() public override view returns (address) {

        return _doubleProxy;
    }

    function setDoubleProxy(address newDoubleProxy)
        public
        override
        _byCommunity
    {

        _doubleProxy = newDoubleProxy;
    }

    function allowedPairs() public override view returns (address[] memory) {

        return _allowedPairs;
    }

    function setAllowedPairs(address[] memory newAllowedPairs)
        public
        override
        _byCommunity
    {

        _allowedPairs = newAllowedPairs;
    }

    function rebalanceRewardMultiplier()
        public
        override
        view
        returns (uint256[] memory)
    {

        return _rebalanceRewardMultiplier;
    }

    function differences()
        public
        override
        view
        returns (uint256 credit, uint256 debt)
    {

        uint256 totalSupply = totalSupply();
        uint256 effectiveAmount = 0;
        for (uint256 i = 0; i < _allowedPairs.length; i++) {
            (uint256 amount0, uint256 amount1) = _getPairAmount(i);
            effectiveAmount += (amount0 + amount1);
        }
        credit = effectiveAmount > totalSupply
            ? effectiveAmount - totalSupply
            : 0;
        debt = totalSupply > effectiveAmount
            ? totalSupply - effectiveAmount
            : 0;
    }

    function calculateRebalanceByDebtReward(uint256 burnt)
        public
        override
        view
        returns (uint256 reward)
    {

        if(burnt == 0) {
            return 0;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = IMVDProxy(IDoubleProxy(_doubleProxy).proxy()).getToken();
        reward = IUniswapV2Router(UNISWAP_V2_ROUTER).getAmountsOut(
            burnt,
            path
        )[1];
        reward =
            (reward * _rebalanceRewardMultiplier[0]) /
            _rebalanceRewardMultiplier[1];
    }

    function fromTokenToStable(address tokenAddress, uint256 amount)
        public
        override
        view
        returns (uint256)
    {

        StableCoin token = StableCoin(tokenAddress);
        uint256 remainingDecimals = decimals() - token.decimals();
        uint256 result = amount == 0 ? token.balanceOf(address(this)) : amount;
        if (remainingDecimals == 0) {
            return result;
        }
        return result * 10**remainingDecimals;
    }

    function mint(
        uint256 pairIndex,
        uint256 amount0,
        uint256 amount1,
        uint256 amount0Min,
        uint256 amount1Min
    ) public override _forAllowedPair(pairIndex) returns (uint256 minted) {

        require(
            IStateHolder(
                IMVDProxy(IDoubleProxy(_doubleProxy).proxy())
                    .getStateHolderAddress()
            )
                .getBool(
                _toStateHolderKey(
                    "stablecoin.authorized",
                    _toString(address(this))
                )
            ),
            "Unauthorized action!"
        );
        (address token0, address token1, ) = _getPairData(pairIndex);
        _transferTokensAndCheckAllowance(token0, amount0);
        _transferTokensAndCheckAllowance(token1, amount1);
        (uint256 firstAmount, uint256 secondAmount, ) = _createPoolToken(
            token0,
            token1,
            amount0,
            amount1,
            amount0Min,
            amount1Min
        );
        minted =
            fromTokenToStable(token0, firstAmount) +
            fromTokenToStable(token1, secondAmount);
        require(minted <= availableToMint(), "Minting amount is greater than availability");
        _mint(msg.sender, minted);
    }

    function burn(
        uint256 pairIndex,
        uint256 pairAmount,
        uint256 amount0,
        uint256 amount1
    )
        public
        override
        _forAllowedPair(pairIndex)
        returns (uint256 removed0, uint256 removed1)
    {

        (address token0, address token1, address pairAddress) = _getPairData(pairIndex);
        _checkAllowance(pairAddress, pairAmount);
        (removed0, removed1) = IUniswapV2Router(UNISWAP_V2_ROUTER)
            .removeLiquidity(
            token0,
            token1,
            pairAmount,
            amount0,
            amount1,
            msg.sender,
            block.timestamp + 1000
        );
        _burn(
            msg.sender,
            fromTokenToStable(token0, removed0) +
                fromTokenToStable(token1, removed1)
        );
    }

    function rebalanceByCredit(
        uint256 pairIndex,
        uint256 pairAmount,
        uint256 amount0,
        uint256 amount1
    ) public override _forAllowedPair(pairIndex) returns (uint256 redeemed) {

        require(
            block.number >=
            _lastRedeemBlock + 
            IStateHolder(
                IMVDProxy(IDoubleProxy(_doubleProxy).proxy())
                    .getStateHolderAddress()
            )
                .getUint256("stablecoin.rebalancebycredit.block.interval"),
            "Unauthorized action!"
        );
        _lastRedeemBlock = block.number;
        (uint256 credit, ) = differences();
        (address token0, address token1, address pairAddress) = _getPairData(pairIndex);
        _checkAllowance(pairAddress, pairAmount);
        (uint256 removed0, uint256 removed1) = IUniswapV2Router(
            UNISWAP_V2_ROUTER
        )
            .removeLiquidity(
            token0,
            token1,
            pairAmount,
            amount0,
            amount1,
            IMVDProxy(IDoubleProxy(_doubleProxy).proxy()).getMVDWalletAddress(),
            block.timestamp + 1000
        );
        redeemed =
            fromTokenToStable(token0, removed0) +
            fromTokenToStable(token1, removed1);
        require(redeemed <= credit, "Cannot redeem given pair amount");
    }

    function rebalanceByDebt(uint256 amount) public override returns(uint256 reward) {

        require(amount > 0, "You must insert a positive value");
        (, uint256 debt) = differences();
        require(amount <= debt, "Cannot Burn this amount");
        _burn(msg.sender, amount);
        IMVDProxy(IDoubleProxy(_doubleProxy).proxy()).submit(
            "mintNewVotingTokensForStableCoin",
            abi.encode(
                address(0),
                0,
                reward = calculateRebalanceByDebtReward(amount),
                msg.sender
            )
        );
    }

    modifier _byCommunity() {

        require(
            IMVDFunctionalitiesManager(
                IMVDProxy(IDoubleProxy(_doubleProxy).proxy())
                    .getMVDFunctionalitiesManagerAddress()
            )
                .isAuthorizedFunctionality(msg.sender),
            "Unauthorized Action!"
        );
        _;
    }

    modifier _forAllowedPair(uint256 pairIndex) {

        require(
            pairIndex >= 0 && pairIndex < _allowedPairs.length,
            "Unknown pair!"
        );
        _;
    }

    function _getPairData(uint256 pairIndex)
        private
        view
        returns (
            address token0,
            address token1,
            address pairAddress
        )
    {

        IUniswapV2Pair pair = IUniswapV2Pair(
            pairAddress = _allowedPairs[pairIndex]
        );
        token0 = pair.token0();
        token1 = pair.token1();
    }

    function _transferTokensAndCheckAllowance(
        address tokenAddress,
        uint256 value
    ) private {

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), value);
        _checkAllowance(tokenAddress, value);
    }

    function _checkAllowance(address tokenAddress, uint256 value) private {

        IERC20 token = IERC20(tokenAddress);
        if (token.allowance(address(this), UNISWAP_V2_ROUTER) <= value) {
            token.approve(
                UNISWAP_V2_ROUTER,
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            );
        }
    }

    function _createPoolToken(
        address firstToken,
        address secondToken,
        uint256 originalFirstAmount,
        uint256 originalSecondAmount,
        uint256 firstAmountMin,
        uint256 secondAmountMin
    )
        private
        returns (
            uint256 firstAmount,
            uint256 secondAmount,
            uint256 poolAmount
        )
    {

        (firstAmount, secondAmount, poolAmount) = IUniswapV2Router(
            UNISWAP_V2_ROUTER
        )
            .addLiquidity(
            firstToken,
            secondToken,
            originalFirstAmount,
            originalSecondAmount,
            firstAmountMin,
            secondAmountMin,
            address(this),
            block.timestamp + 1000
        );
        if (firstAmount < originalFirstAmount) {
            IERC20(firstToken).transfer(
                msg.sender,
                originalFirstAmount - firstAmount
            );
        }
        if (secondAmount < originalSecondAmount) {
            IERC20(secondToken).transfer(
                msg.sender,
                originalSecondAmount - secondAmount
            );
        }
    }

    function _getPairAmount(uint256 i)
        private
        view
        returns (uint256 amount0, uint256 amount1)
    {

        (address token0, address token1, address pairAddress) = _getPairData(i);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        uint256 pairAmount = pair.balanceOf(address(this));
        uint256 pairTotalSupply = pair.totalSupply();
        (amount0, amount1, ) = pair.getReserves();
        amount0 = fromTokenToStable(
            token0,
            (pairAmount * amount0) / pairTotalSupply
        );
        amount1 = fromTokenToStable(
            token1,
            (pairAmount * amount1) / pairTotalSupply
        );
    }

    function _toStateHolderKey(string memory a, string memory b)
        private
        pure
        returns (string memory)
    {

        return _toLowerCase(string(abi.encodePacked(a, "_", b)));
    }

    function _toString(address _addr) private pure returns (string memory) {

        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(value[i + 12] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    }

    function _toLowerCase(string memory str)
        private
        pure
        returns (string memory)
    {

        bytes memory bStr = bytes(str);
        for (uint256 i = 0; i < bStr.length; i++) {
            bStr[i] = bStr[i] >= 0x41 && bStr[i] <= 0x5A
                ? bytes1(uint8(bStr[i]) + 0x20)
                : bStr[i];
        }
        return string(bStr);
    }
}