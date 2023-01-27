pragma solidity 0.7.6;

interface IPoolFactory {

    function createPoolFromUni(address tradeToken, address poolToken, uint24 fee, bool reverse) external;


    function createPoolFromSushi(address tradeToken, address poolToken, bool reverse) external;


    function pools(address poolToken, address oraclePool, bool reverse) external view returns (address pool);


    event CreatePoolFromUni(
        address tradeToken,
        address poolToken,
        address uniPool,
        address pool,
        address debt,
        string tradePair,
        uint24 fee,
        bool reverse);

    event CreatePoolFromSushi(
        address tradeToken,
        address poolToken,
        address sushiPool,
        address pool,
        address debt,
        string tradePair,
        bool reverse);
}// GPL-3.0
pragma solidity 0.7.6;

interface IPool {

    struct Position {
        uint256 openPrice;
        uint256 openBlock;
        uint256 margin;
        uint256 size;
        uint256 openRebase;
        address account;
        uint8 direction;
    }

    function _positions(uint32 positionId)
        external
        view
        returns (
            uint256 openPrice,
            uint256 openBlock,
            uint256 margin,
            uint256 size,
            uint256 openRebase,
            address account,
            uint8 direction
        );


    function debtToken() external view returns (address);


    function lsTokenPrice() external view returns (uint256);


    function addLiquidity(address user, uint256 amount) external;


    function removeLiquidity(address user, uint256 lsAmount, uint256 bondsAmount, address receipt) external;


    function openPosition(
        address user,
        uint8 direction,
        uint16 leverage,
        uint256 position
    ) external returns (uint32);


    function addMargin(
        address user,
        uint32 positionId,
        uint256 margin
    ) external;


    function closePosition(
        address receipt,
        uint32 positionId
    ) external;


    function liquidate(
        address user,
        uint32 positionId,
        address receipt
    ) external;


    function exit(
        address receipt,
        uint32 positionId
    ) external;


    event MintLiquidity(uint256 amount);

    event AddLiquidity(
        address indexed sender,
        uint256 amount,
        uint256 lsAmount,
        uint256 bonds
    );

    event RemoveLiquidity(
        address indexed sender,
        uint256 amount,
        uint256 lsAmount,
        uint256 bondsRequired
    );

    event OpenPosition(
        address indexed sender,
        uint256 openPrice,
        uint256 openRebase,
        uint8 direction,
        uint16 level,
        uint256 margin,
        uint256 size,
        uint32 positionId
    );

    event AddMargin(
        address indexed sender,
        uint256 margin,
        uint32 positionId
    );

    event ClosePosition(
        address indexed receipt,
        uint256 closePrice,
        uint256 serviceFee,
        uint256 fundingFee,
        uint256 pnl,
        uint32  positionId,
        bool isProfit,
        int256 debtChange
    );

    event Liquidate(
        address indexed sender,
        uint32 positionID,
        uint256 liqPrice,
        uint256 serviceFee,
        uint256 fundingFee,
        uint256 liqReward,
        uint256 pnl,
        bool isProfit,
        uint256 debtRepay
    );

    event Rebase(uint256 rebaseAccumulatedLong, uint256 rebaseAccumulatedShort);
}// GPL-3.0
pragma solidity 0.7.6;

interface IPoolCallback {

    function poolV2Callback(
        uint256 amount,
        address poolToken,
        address oraclePool,
        address payer,
        bool reverse
    ) external payable;


    function poolV2RemoveCallback(
        uint256 amount,
        address poolToken,
        address oraclePool,
        address payer,
        bool reverse
    ) external;


    function poolV2BondsCallback(
        uint256 amount,
        address poolToken,
        address oraclePool,
        address payer,
        bool reverse
    ) external;


    function poolV2BondsCallbackFromDebt(
        uint256 amount,
        address poolToken,
        address oraclePool,
        address payer,
        bool reverse
    ) external;

}// GPL-3.0
pragma solidity 0.7.6;

interface IRouter {

    function createPoolFromUni(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse
    ) external;


    function createPoolFromSushi(
        address tradeToken,
        address poolToken,
        bool reverse
    ) external;


    function getLsBalance(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse,
        address user
    ) external view returns (uint256);


    function getLsBalance2(
        address tradeToken,
        address poolToken,
        bool reverse,
        address user
    ) external view returns (uint256);


    function getLsPrice(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse
    ) external view returns (uint256);


    function getLsPrice2(
        address tradeToken,
        address poolToken,
        bool reverse
    ) external view returns (uint256);


    function addLiquidity(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse,
        uint256 amount
    ) external payable;


    function addLiquidity2(
        address tradeToken,
        address poolToken,
        bool reverse,
        uint256 amount
    ) external payable;


    function removeLiquidity(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse,
        uint256 lsAmount,
        uint256 bondsAmount,
        address receipt
    ) external;


    function removeLiquidity2(
        address tradeToken,
        address poolToken,
        bool reverse,
        uint256 lsAmount,
        uint256 bondsAmount,
        address receipt
    ) external;


    function openPosition(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse,
        uint8 direction,
        uint16 leverage,
        uint256 position
    ) external payable;


    function openPosition2(
        address tradeToken,
        address poolToken,
        bool reverse,
        uint8 direction,
        uint16 leverage,
        uint256 position
    ) external payable;


    function addMargin(uint32 tokenId, uint256 margin) external payable;


    function closePosition(uint32 tokenId, address receipt) external;


    function liquidate(uint32 tokenId, address receipt) external;


    function liquidateByPool(address poolAddress, uint32 positionId, address receipt) external;


    function withdrawERC20(address poolToken) external;


    function withdrawETH() external;


    function repayLoan(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse,
        uint256 amount,
        address receipt
    ) external payable;


    function repayLoan2(
        address tradeToken,
        address poolToken,
        bool reverse,
        uint256 amount,
        address receipt
    ) external payable;


    function exit(uint32 tokenId, address receipt) external;


    event TokenCreate(uint32 tokenId, address pool, address sender, uint32 positionId);
}// GPL-3.0
pragma solidity 0.7.6;

interface IDebt {


    function owner() external view returns (address);


    function issueBonds(address recipient, uint256 amount) external;


    function burnBonds(uint256 amount) external;


    function repayLoan(address payer, address recipient, uint256 amount) external;


    function totalDebt() external view returns (uint256);


    function bondsLeft() external view returns (uint256);


    event RepayLoan(
        address indexed receipt,
        uint256 bondsTokenAmount,
        uint256 poolTokenAmount
    );
}// GPL-3.0
pragma solidity 0.7.6;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

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
}// MIT

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
}pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3Factory {

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    function owner() external view returns (address);


    function feeAmountTickSpacing(uint24 fee) external view returns (int24);


    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);


    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);


    function setOwner(address _owner) external;


    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;

}// GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IMulticall {

    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);

}// GPL-2.0-or-later
pragma solidity =0.7.6;


abstract contract Multicall is IMulticall {
    function multicall(bytes[] calldata data) external payable override returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }
}// GPL-3.0
pragma solidity 0.7.6;



contract Router is IRouter, IPoolCallback, Multicall {

    fallback() external {}
    receive() payable external {}

    using SafeERC20 for IERC20;

    address public _factory;
    address public _wETH;
    address private _uniV3Factory;
    address private _uniV2Factory;
    address private _sushiFactory;
    uint32 private _tokenId = 0;

    struct tokenDate {
        address user;
        address poolAddress;
        uint32 positionId;
    }

    mapping(uint32 => tokenDate) public _tokenData;

    constructor(address factory, address uniV3Factory, address uniV2Factory, address sushiFactory, address wETH) {
        _factory = factory;
        _uniV3Factory = uniV3Factory;
        _uniV2Factory = uniV2Factory;
        _sushiFactory = sushiFactory;
        _wETH = wETH;
    }

    function poolV2Callback(
        uint256 amount,
        address poolToken,
        address oraclePool,
        address payer,
        bool reverse
    ) external override payable {

        IPoolFactory qilin = IPoolFactory(_factory);
        require(
            qilin.pools(poolToken, oraclePool, reverse) == msg.sender,
            "poolV2Callback caller is not the pool contract"
        );

        if (poolToken == _wETH && address(this).balance >= amount) {
            IWETH wETH = IWETH(_wETH);
            wETH.deposit{value: amount}();
            wETH.transfer(msg.sender, amount);
        } else {
            IERC20(poolToken).safeTransferFrom(payer, msg.sender, amount);
        }
    }

    function poolV2RemoveCallback(
        uint256 amount,
        address poolToken,
        address oraclePool,
        address payer,
        bool reverse
    ) external override {

        IPoolFactory qilin = IPoolFactory(_factory);
        require(
            qilin.pools(poolToken, oraclePool, reverse) == msg.sender,
            "poolV2Callback caller is not the pool contract"
        );

        IERC20(msg.sender).safeTransferFrom(payer, msg.sender, amount);
    }

    function poolV2BondsCallback(
        uint256 amount,
        address poolToken,
        address oraclePool,
        address payer,
        bool reverse
    ) external override {

        address pool = IPoolFactory(_factory).pools(poolToken, oraclePool, reverse);
        require(
             pool == msg.sender,
            "poolV2BondsCallback caller is not the pool contract"
        );

        address debt = IPool(pool).debtToken();

        IERC20(debt).safeTransferFrom(payer, debt, amount);
    }

    function poolV2BondsCallbackFromDebt(
        uint256 amount,
        address poolToken,
        address oraclePool,
        address payer,
        bool reverse
    ) external override {

        address pool = IPoolFactory(_factory).pools(poolToken, oraclePool, reverse);
        address debt = IPool(pool).debtToken();
        require(
            debt == msg.sender,
            "poolV2BondsCallbackFromDebt caller is not the debt contract"
        );

        IERC20(debt).safeTransferFrom(payer, debt, amount);
    }

    function getPoolFromUni(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse
    ) public view returns (address) {

        address oraclePool;

        if (fee == 0) {
            oraclePool = IUniswapV2Factory(_uniV2Factory).getPair(tradeToken, poolToken);
        } else {
            oraclePool = IUniswapV3Factory(_uniV3Factory).getPool(tradeToken, poolToken, fee);
        }

        return IPoolFactory(_factory).pools(poolToken, oraclePool, reverse);
    }

    function getPoolFromSushi(
        address tradeToken,
        address poolToken,
        bool reverse
    ) public view returns (address) {

        address oraclePool = IUniswapV2Factory(_sushiFactory).getPair(tradeToken, poolToken);
        return IPoolFactory(_factory).pools(poolToken, oraclePool, reverse);
    }

    function createPoolFromUni(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse
    ) external override {

        IPoolFactory(_factory).createPoolFromUni(tradeToken, poolToken, fee, reverse);
    }

    function createPoolFromSushi(
        address tradeToken,
        address poolToken,
        bool reverse
    ) external override {

        IPoolFactory(_factory).createPoolFromSushi(tradeToken, poolToken, reverse);
    }

    function getLsBalance(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse,
        address user
    ) external override view returns (uint256) {

        address pool = getPoolFromUni(tradeToken, poolToken, fee, reverse);
        require(pool != address(0), "non-exist pool");
        return IERC20(pool).balanceOf(user);
    }

    function getLsBalance2(
        address tradeToken,
        address poolToken,
        bool reverse,
        address user
    ) external override view returns (uint256) {

        address pool = getPoolFromSushi(tradeToken, poolToken, reverse);
        require(pool != address(0), "non-exist pool");
        return IERC20(pool).balanceOf(user);
    }

    function getLsPrice(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse
    ) external override view returns (uint256) {

        address pool = getPoolFromUni(tradeToken, poolToken, fee, reverse);
        require(pool != address(0), "non-exist pool");
        return IPool(pool).lsTokenPrice();
    }

    function getLsPrice2(
        address tradeToken,
        address poolToken,
        bool reverse
    ) external override view returns (uint256) {

        address pool = getPoolFromSushi(tradeToken, poolToken, reverse);
        require(pool != address(0), "non-exist pool");
        return IPool(pool).lsTokenPrice();
    }

    function addLiquidity(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse,
        uint256 amount
    ) external override payable {

        address pool = getPoolFromUni(tradeToken, poolToken, fee, reverse);
        require(pool != address(0), "non-exist pool");
        IPool(pool).addLiquidity(msg.sender, amount);
    }

    function addLiquidity2(
        address tradeToken,
        address poolToken,
        bool reverse,
        uint256 amount
    ) external override payable {

        address pool = getPoolFromSushi(tradeToken, poolToken, reverse);
        require(pool != address(0), "non-exist pool");
        IPool(pool).addLiquidity(msg.sender, amount);
    }

    function removeLiquidity(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse,
        uint256 lsAmount,
        uint256 bondsAmount,
        address receipt
    ) external override {

        address pool = getPoolFromUni(tradeToken, poolToken, fee, reverse);
        require(pool != address(0), "non-exist pool");
        IPool(pool).removeLiquidity(msg.sender, lsAmount, bondsAmount, receipt);
    }

    function removeLiquidity2(
        address tradeToken,
        address poolToken,
        bool reverse,
        uint256 lsAmount,
        uint256 bondsAmount,
        address receipt
    ) external override {

        address pool = getPoolFromSushi(tradeToken, poolToken, reverse);
        require(pool != address(0), "non-exist pool");
        IPool(pool).removeLiquidity(msg.sender, lsAmount, bondsAmount, receipt);
    }

    function openPosition(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse,
        uint8 direction,
        uint16 leverage,
        uint256 position
    ) external override payable {

        address pool = getPoolFromUni(tradeToken, poolToken, fee, reverse);
        require(pool != address(0), "non-exist pool");
        _tokenId++;
        uint32 positionId = IPool(pool).openPosition(
            msg.sender,
            direction,
            leverage,
            position
        );
        tokenDate memory tempTokenDate = tokenDate(
            msg.sender,
            pool,
            positionId
        );
        _tokenData[_tokenId] = tempTokenDate;
        emit TokenCreate(_tokenId, address(pool), msg.sender, positionId);
    }

    function openPosition2(
        address tradeToken,
        address poolToken,
        bool reverse,
        uint8 direction,
        uint16 leverage,
        uint256 position
    ) external override payable {

        address pool = getPoolFromSushi(tradeToken, poolToken, reverse);
        require(pool != address(0), "non-exist pool");
        _tokenId++;
        uint32 positionId = IPool(pool).openPosition(
            msg.sender,
            direction,
            leverage,
            position
        );
        tokenDate memory tempTokenDate = tokenDate(
            msg.sender,
            pool,
            positionId
        );
        _tokenData[_tokenId] = tempTokenDate;
        emit TokenCreate(_tokenId, address(pool), msg.sender, positionId);
    }

    function addMargin(uint32 tokenId, uint256 margin) external override payable {

        tokenDate memory tempTokenDate = _tokenData[tokenId];
        require(
            tempTokenDate.user == msg.sender,
            "token owner not match msg.sender"
        );
        IPool(tempTokenDate.poolAddress).addMargin(
            msg.sender,
            tempTokenDate.positionId,
            margin
        );
    }

    function closePosition(uint32 tokenId, address receipt) external override {

        tokenDate memory tempTokenDate = _tokenData[tokenId];
        require(
            tempTokenDate.user == msg.sender,
            "token owner not match msg.sender"
        );
        IPool(tempTokenDate.poolAddress).closePosition(
            receipt,
            tempTokenDate.positionId
        );
    }

    function liquidate(uint32 tokenId, address receipt) external override {

        tokenDate memory tempTokenDate = _tokenData[tokenId];
        require(tempTokenDate.user != address(0), "tokenId does not exist");
        IPool(tempTokenDate.poolAddress).liquidate(
            msg.sender,
            tempTokenDate.positionId,
            receipt
        );
    }

    function liquidateByPool(address poolAddress, uint32 positionId, address receipt) external override {

        IPool(poolAddress).liquidate(msg.sender, positionId, receipt);
    }

    function withdrawERC20(address poolToken) external override {

        IERC20 erc20 = IERC20(poolToken);
        uint256 balance = erc20.balanceOf(address(this));
        require(balance > 0, "balance of router must > 0");
        erc20.safeTransfer(msg.sender, balance);
    }

    function withdrawETH() external override {

        uint256 balance = IERC20(_wETH).balanceOf(address(this));
        require(balance > 0, "balance of router must > 0");
        IWETH(_wETH).withdraw(balance);
        (bool success, ) = msg.sender.call{value: balance}(new bytes(0));
        require(success, "ETH transfer failed");
    }

    function repayLoan(
        address tradeToken,
        address poolToken,
        uint24 fee,
        bool reverse,
        uint256 amount,
        address receipt
    ) external override payable {

        address pool = getPoolFromUni(tradeToken, poolToken, fee, reverse);
        require(pool != address(0), "non-exist pool");
        address debtToken = IPool(pool).debtToken();
        IDebt(debtToken).repayLoan(msg.sender, receipt, amount);
    }

    function repayLoan2(
        address tradeToken,
        address poolToken,
        bool reverse,
        uint256 amount,
        address receipt
    ) external override payable {

        address pool = getPoolFromSushi(tradeToken, poolToken, reverse);
        require(pool != address(0), "non-exist pool");
        address debtToken = IPool(pool).debtToken();
        IDebt(debtToken).repayLoan(msg.sender, receipt, amount);
    }

    function exit(uint32 tokenId, address receipt) external override {

        tokenDate memory tempTokenDate = _tokenData[tokenId];
        require(
            tempTokenDate.user == msg.sender,
            "token owner not match msg.sender"
        );
        IPool(tempTokenDate.poolAddress).exit(
            receipt,
            tempTokenDate.positionId
        );
    }
}