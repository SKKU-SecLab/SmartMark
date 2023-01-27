
pragma solidity ^0.8.0;

contract Multiownable {



    uint256 public ownersGeneration;
    uint256 public howManyOwnersDecide;
    address[] public owners;
    bytes32[] public allOperations;
    address internal insideCallSender;
    uint256 internal insideCallCount;

    mapping(address => uint) public ownersIndices; // Starts from 1
    mapping(bytes32 => uint) public allOperationsIndicies;

    mapping(bytes32 => uint256) public votesMaskByOperation;
    mapping(bytes32 => uint256) public votesCountByOperation;


    event OwnershipTransferred(address[] previousOwners, uint howManyOwnersDecide, address[] newOwners, uint newHowManyOwnersDecide);
    event OperationCreated(bytes32 operation, uint howMany, uint ownersCount, address proposer);
    event OperationUpvoted(bytes32 operation, uint votes, uint howMany, uint ownersCount, address upvoter);
    event OperationPerformed(bytes32 operation, uint howMany, uint ownersCount, address performer);
    event OperationDownvoted(bytes32 operation, uint votes, uint ownersCount,  address downvoter);
    event OperationCancelled(bytes32 operation, address lastCanceller);
    

    function isOwner(address wallet) public view returns(bool) {

        return ownersIndices[wallet] > 0;
    }

    function ownersCount() public view returns(uint) {

        return owners.length;
    }

    function allOperationsCount() public view returns(uint) {

        return allOperations.length;
    }


    modifier onlyAnyOwner {

        if (checkHowManyOwners(1)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = 1;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    modifier onlyManyOwners {

        if (checkHowManyOwners(howManyOwnersDecide)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = howManyOwnersDecide;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    modifier onlyAllOwners {

        if (checkHowManyOwners(owners.length)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = owners.length;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }

    modifier onlySomeOwners(uint howMany) {

        require(howMany > 0, "onlySomeOwners: howMany argument is zero");
        require(howMany <= owners.length, "onlySomeOwners: howMany argument exceeds the number of owners");
        
        if (checkHowManyOwners(howMany)) {
            bool update = (insideCallSender == address(0));
            if (update) {
                insideCallSender = msg.sender;
                insideCallCount = howMany;
            }
            _;
            if (update) {
                insideCallSender = address(0);
                insideCallCount = 0;
            }
        }
    }


    constructor() {
        owners.push(msg.sender);
        ownersIndices[msg.sender] = 1;
        howManyOwnersDecide = 1;
    }


    function checkHowManyOwners(uint howMany) internal returns(bool) {

        if (insideCallSender == msg.sender) {
            require(howMany <= insideCallCount, "checkHowManyOwners: nested owners modifier check require more owners");
            return true;
        }

        uint ownerIndex = ownersIndices[msg.sender] - 1;
        require(ownerIndex < owners.length, "checkHowManyOwners: msg.sender is not an owner");
        bytes32 operation = keccak256(abi.encodePacked(msg.data, ownersGeneration));

        require((votesMaskByOperation[operation] & (2 ** ownerIndex)) == 0, "checkHowManyOwners: owner already voted for the operation");
        votesMaskByOperation[operation] |= (2 ** ownerIndex);
        uint operationVotesCount = votesCountByOperation[operation] + 1;
        votesCountByOperation[operation] = operationVotesCount;
        if (operationVotesCount == 1) {
            allOperationsIndicies[operation] = allOperations.length;
            allOperations.push(operation);
            emit OperationCreated(operation, howMany, owners.length, msg.sender);
        }
        emit OperationUpvoted(operation, operationVotesCount, howMany, owners.length, msg.sender);

        if (votesCountByOperation[operation] == howMany) {
            deleteOperation(operation);
            emit OperationPerformed(operation, howMany, owners.length, msg.sender);
            return true;
        }

        return false;
    }

    function deleteOperation(bytes32 operation) internal {

        uint index = allOperationsIndicies[operation];
        if (index < allOperations.length - 1) { // Not last
            allOperations[index] = allOperations[allOperations.length - 1];
            allOperationsIndicies[allOperations[index]] = index;
        }
        allOperations.push(allOperations[allOperations.length-1]);

        delete votesMaskByOperation[operation];
        delete votesCountByOperation[operation];
        delete allOperationsIndicies[operation];
    }


    function cancelPending(bytes32 operation) public onlyAnyOwner {

        uint ownerIndex = ownersIndices[msg.sender] - 1;
        require((votesMaskByOperation[operation] & (2 ** ownerIndex)) != 0, "cancelPending: operation not found for this user");
        votesMaskByOperation[operation] &= ~(2 ** ownerIndex);
        uint operationVotesCount = votesCountByOperation[operation] - 1;
        votesCountByOperation[operation] = operationVotesCount;
        emit OperationDownvoted(operation, operationVotesCount, owners.length, msg.sender);
        if (operationVotesCount == 0) {
            deleteOperation(operation);
            emit OperationCancelled(operation, msg.sender);
        }
    }

    function transferOwnership(address[] memory newOwners) public {

        transferOwnershipWithHowMany(newOwners, newOwners.length);
    }

    function transferOwnershipWithHowMany(address[] memory newOwners, uint256 newHowManyOwnersDecide) public onlyManyOwners {

        require(newOwners.length > 0, "transferOwnershipWithHowMany: owners array is empty");
        require(newOwners.length <= 256, "transferOwnershipWithHowMany: owners count is greater then 256");
        require(newHowManyOwnersDecide > 0, "transferOwnershipWithHowMany: newHowManyOwnersDecide equal to 0");
        require(newHowManyOwnersDecide <= newOwners.length, "transferOwnershipWithHowMany: newHowManyOwnersDecide exceeds the number of owners");

        for (uint j = 0; j < owners.length; j++) {
            delete ownersIndices[owners[j]];
        }
        for (uint i = 0; i < newOwners.length; i++) {
            require(newOwners[i] != address(0), "transferOwnershipWithHowMany: owners array contains zero");
            require(ownersIndices[newOwners[i]] == 0, "transferOwnershipWithHowMany: owners array contains duplicates");
            ownersIndices[newOwners[i]] = i + 1;
        }
        
        emit OwnershipTransferred(owners, howManyOwnersDecide, newOwners, newHowManyOwnersDecide);
        owners = newOwners;
        howManyOwnersDecide = newHowManyOwnersDecide;
        allOperations.push(allOperations[0]);
        ownersGeneration++;
    }

}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


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

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

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

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
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
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);


    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);


    function allPairs(uint256) external view returns (address pair);


    function allPairsLength() external view returns (uint256);


    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);


    function setFeeTo(address) external;


    function setFeeToSetter(address) external;

}

interface IUniswapV2Pair {

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
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


    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


    function skim(address to) external;


    function sync() external;


    function initialize(address, address) external;

}

interface IUniswapV2Router01 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


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


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

contract FUTURECOIN is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 119700000 * 10**18; // 119.7 Million
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "FUTURECOIN";
    string private constant _symbol = "FUTURE";
    uint8 private constant _decimals = 18;

    uint256 public _taxFee = 4; // 4 -> 0.4% or 40 means 4%
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _liquidityFee = 4; // 4 -> 0.4% or 40 means 4%
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _charityFee = 0;
    uint256 private _previousCharityFee = _charityFee;

    uint256 public _teamFee = 3; // 3 -> 0.3% or 30 means 3%
    uint256 private _previousTeamFee = _teamFee;

    address public _charityWallet;
    address public _teamWallet;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public _maxTxAmount = 500000 * 10**18; // 500k
    uint256 private constant numTokensSellToAddToLiquidity = 50000 * 10**18;

    struct TValues {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tCharity;
        uint256 tTeam;
    }

    struct FeeValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tCharity;
        uint256 tTeam;
        uint256 rCharity;
        uint256 rTeam;
    }

    event Burn(address indexed sender, uint256 amount, address indexed to);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    event SetCharityWallet(address owner, address newCharityWallet);
    event SetTeamWallet(address owner, address newTeamWallet);
    event CharityAmount(address user, uint256 amount);
    event TeamAmount(address user, uint256 amount);

    modifier lockTheSwap() {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(address charityWallet, address teamWallet) {
        _rOwned[_msgSender()] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _charityWallet = charityWallet;
        _teamWallet = teamWallet;
        excludeFromReward(charityWallet);
        excludeFromReward(teamWallet);

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() public pure returns (string memory) {

        return _name;
    }

    function symbol() public pure returns (string memory) {

        return _symbol;
    }

    function decimals() public pure returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
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
    ) public override returns (bool) {

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

    function isExcludedFromReward(address account) public view returns (bool) {

        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {

        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {

        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        FeeValues memory feeValues = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(feeValues.rAmount);
        _rTotal = _rTotal.sub(feeValues.rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {

        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            return _getValues(tAmount).rAmount;
        } else {
            return _getValues(tAmount).rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {

        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function burn(uint256 amount) public onlyOwner returns (bool) {

        address callerAddress = _msgSender();
        require(
            amount > _tOwned[callerAddress],
            "ERC20: burn amount exceeds balance"
        );
        uint256 tAmount = amount;
        uint256 rAmount = tAmount.mul(_getRate());

        _tokenTransfer(callerAddress, address(0), amount, false);

        _tTotal = _tTotal.sub(tAmount);
        _rTotal = _rTotal.sub(rAmount);

        emit Transfer(owner(), address(0), amount);

        return true;
    }

    function excludeFromReward(address account) public onlyOwner {

        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {

        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {

        FeeValues memory feeValues = _getValues(tAmount);
        _tOwned[_charityWallet] = _tOwned[_charityWallet].add(
            feeValues.tCharity
        );
        _tOwned[_teamWallet] = _tOwned[_teamWallet].add(feeValues.tTeam);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(feeValues.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(feeValues.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(feeValues.rTransferAmount);
        _takeLiquidity(feeValues.tLiquidity);
        _reflectFee(
            feeValues.rCharity,
            feeValues.rTeam,
            feeValues.rFee,
            feeValues.tFee
        );
        emit Transfer(sender, recipient, feeValues.tTransferAmount);
        emit CharityAmount(msg.sender, feeValues.tCharity);
        emit TeamAmount(msg.sender, feeValues.tTeam);
    }

    function excludeFromFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = false;
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner {

        _taxFee = taxFee;
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {

        _liquidityFee = liquidityFee;
    }

    function setCharityFeePercentage(uint256 charityFee) external onlyOwner {

        _charityFee = charityFee;
    }

    function setTeamFeePercentage(uint256 teamFee) external onlyOwner {

        _teamFee = teamFee;
    }

    function setCharityWallet(address charityWallet) external onlyOwner {

        require(
            charityWallet != address(0),
            "FTC :: charity wallet not a zero address"
        );
        _charityWallet = charityWallet;
        excludeFromReward(charityWallet);

        emit SetCharityWallet(msg.sender, charityWallet);
    }

    function setTeamWallet(address teamWallet) external onlyOwner {

        require(
            teamWallet != address(0),
            "FTC :: team wallet not a zero address"
        );
        _teamWallet = teamWallet;
        excludeFromReward(teamWallet);

        emit SetTeamWallet(msg.sender, teamWallet);
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {

        _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {

        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function withdraw() public onlyOwner {

        require(
            address(this).balance > 0,
            "No BNB stored at the contract address"
        );
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}

    function _reflectFee(
        uint256 rCharity,
        uint256 rTeam,
        uint256 rFee,
        uint256 tFee
    ) private {

        _rTotal = _rTotal.sub(rFee).sub(rCharity).sub(rTeam);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (FeeValues memory)
    {

        TValues memory tValues = _getTValues(tAmount);
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 rCharity,
            uint256 rTeam
        ) = _getRValues(
                tAmount,
                tValues.tFee,
                tValues.tLiquidity,
                tValues.tCharity,
                tValues.tTeam,
                _getRate()
            );
        return
            FeeValues({
                rAmount: rAmount,
                rTransferAmount: rTransferAmount,
                rFee: rFee,
                tTransferAmount: tValues.tTransferAmount,
                tFee: tValues.tFee,
                tLiquidity: tValues.tLiquidity,
                tCharity: tValues.tCharity,
                tTeam: tValues.tTeam,
                rCharity: rCharity,
                rTeam: rTeam
            });
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (TValues memory)
    {

        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tcharity = tAmount.mul(_charityFee).div(1000);
        uint256 tteam = tAmount.mul(_teamFee).div(1000);
        uint256 tTransferAmount = tAmount
            .sub(tFee)
            .sub(tLiquidity)
            .sub(tcharity)
            .sub(tteam);

        TValues memory tValues = TValues({
            tTransferAmount: tTransferAmount,
            tFee: tFee,
            tLiquidity: tLiquidity,
            tCharity: tcharity,
            tTeam: tteam
        });

        return tValues;
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 tcharity,
        uint256 tteam,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rCharity = tcharity.mul(currentRate);
        uint256 rTeam = tteam.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount
            .sub(rFee)
            .sub(rLiquidity)
            .sub(rCharity)
            .sub(rTeam);
        return (rAmount, rTransferAmount, rFee, rCharity, rTeam);
    }

    function _getRate() private view returns (uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {

        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {

        return _amount.mul(_taxFee).div(10**3);
    }

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {

        return _amount.mul(_liquidityFee).div(10**3);
    }

    function removeAllFee() private {

        if (
            _taxFee == 0 &&
            _liquidityFee == 0 &&
            _charityFee == 0 &&
            _teamFee == 0
        ) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousCharityFee = _charityFee;
        _previousTeamFee = _teamFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _charityFee = 0;
        _teamFee = 0;
    }

    function restoreAllFee() private {

        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _charityFee = _previousCharityFee;
        _teamFee = _previousTeamFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {

        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from != owner() && to != owner())
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );

        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >=
            numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance);
        }

        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
        emit Transfer(address(this), uniswapV2Pair, tokenAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {

        if (!takeFee) removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {

        FeeValues memory feeValues = _getValues(tAmount);
        _tOwned[_charityWallet] = _tOwned[_charityWallet].add(
            feeValues.tCharity
        );
        _tOwned[_teamWallet] = _tOwned[_teamWallet].add(feeValues.tTeam);
        _rOwned[sender] = _rOwned[sender].sub(feeValues.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(feeValues.rTransferAmount);
        _takeLiquidity(feeValues.tLiquidity);
        _reflectFee(
            feeValues.rCharity,
            feeValues.rTeam,
            feeValues.rFee,
            feeValues.tFee
        );
        emit Transfer(sender, recipient, feeValues.tTransferAmount);
        emit CharityAmount(msg.sender, feeValues.tCharity);
        emit TeamAmount(msg.sender, feeValues.tTeam);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {

        FeeValues memory feeValues = _getValues(tAmount);
        _tOwned[_charityWallet] = _tOwned[_charityWallet].add(
            feeValues.tCharity
        );
        _tOwned[_teamWallet] = _tOwned[_teamWallet].add(feeValues.tTeam);
        _rOwned[sender] = _rOwned[sender].sub(feeValues.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(feeValues.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(feeValues.rTransferAmount);
        _takeLiquidity(feeValues.tLiquidity);
        _reflectFee(
            feeValues.rCharity,
            feeValues.rTeam,
            feeValues.rFee,
            feeValues.tFee
        );
        emit Transfer(sender, recipient, feeValues.tTransferAmount);
        emit CharityAmount(msg.sender, feeValues.tCharity);
        emit TeamAmount(msg.sender, feeValues.tTeam);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {

        FeeValues memory feeValues = _getValues(tAmount);
        _tOwned[_charityWallet] = _tOwned[_charityWallet].add(
            feeValues.tCharity
        );
        _tOwned[_teamWallet] = _tOwned[_teamWallet].add(feeValues.tTeam);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(feeValues.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(feeValues.rTransferAmount);
        _takeLiquidity(feeValues.tLiquidity);
        _reflectFee(
            feeValues.rCharity,
            feeValues.rTeam,
            feeValues.rFee,
            feeValues.tFee
        );
        emit Transfer(sender, recipient, feeValues.tTransferAmount);
        emit CharityAmount(msg.sender, feeValues.tCharity);
        emit TeamAmount(msg.sender, feeValues.tTeam);
    }
}

contract ethBridge is Multiownable {

    FUTURECOIN private token;

    uint256 public minimumCommissionGas;

    uint256 public minimumExchangeOnBridge;

    mapping(address => uint256) public tokensSent;
    mapping(address => uint256) public tokensRecieved;
    mapping(address => uint256) public tokensRecievedButNotSent;

    mapping(address => uint256) public howManyWritesToRefund;
 
    address public tokenAddress; 

    constructor (address payable _token, uint256 _minimumCommissionGas, uint256 _minimumExchangeOnBridge) {
        tokenAddress = _token;
        token = FUTURECOIN(_token);
        minimumCommissionGas = _minimumCommissionGas;
        minimumExchangeOnBridge = _minimumExchangeOnBridge;
    }
 
    bool transferStatus;
    
    bool avoidReentrancy = false;
 
    function sendTokens(uint256 amount) public {

        require(msg.sender != address(0), "Zero account");
        require(amount >= minimumExchangeOnBridge,"Amount of tokens should be more then minimumExchangeOnBridge");
        require(token.balanceOf(msg.sender) >= amount,"Not enough balance");
        
        transferStatus = token.transferFrom(msg.sender, address(this), amount);
        if (transferStatus == true) {
            tokensRecieved[msg.sender] += amount;
        }
    }
 
    function writeTransaction(address user, uint256 amount) public onlyAllOwners {

        require(user != address(0), "Zero account");
        require(amount > 0,"Amount of tokens should be more then 0");
        require(!avoidReentrancy);

        avoidReentrancy = true;
        tokensRecievedButNotSent[user] += amount;
        howManyWritesToRefund[user] += 1;
        avoidReentrancy = false;
    }

    function recieveTokens(uint256[] memory commissions) public payable {

        require(tokensRecievedButNotSent[msg.sender] > tokensSent[msg.sender], "Nothing to send");
        require(commissions.length == owners.length, "The number of commissions and owners does not match");
        uint256 sum = 0;
        for(uint i = 0; i < commissions.length; i++) {
            sum += commissions[i];
        }
        require(msg.value >= sum, "Not enough ETH (The amount of ETH is less than the amount of commissions.)");
        require(msg.value >= howManyWritesToRefund[msg.sender] * owners.length * minimumCommissionGas, "Not enough ETH (The amount of ETH is less than the internal commission.)");
    
        for (uint i = 0; i < owners.length; i++) {
            address payable owner = payable(owners[i]);
            uint256 commission = commissions[i];
            owner.transfer(commission);
        }

        uint256 amountToSent;

        amountToSent = tokensRecievedButNotSent[msg.sender] - tokensSent[msg.sender];
        transferStatus = token.transfer(msg.sender, amountToSent);
        if (transferStatus == true) {
            tokensSent[msg.sender] += amountToSent;
            howManyWritesToRefund[msg.sender] = 0;
        }
    }
 
    function withdrawTokens(uint256 amount, address reciever) public onlyAllOwners {

        require(amount > 0,"Amount of tokens should be more then 0");
        require(reciever != address(0), "Zero account");
        require(token.balanceOf(address(this)) >= amount,"Not enough balance");
        
        token.transfer(reciever, amount);
    }
    
    function withdrawEther(uint256 amount, address payable reciever) public onlyAllOwners {

        require(amount > 0,"Amount of tokens should be more then 0");
        require(reciever != address(0), "Zero account");
        require(address(this).balance >= amount,"Not enough balance");

        reciever.transfer(amount);
    }

    function setMinimumCommissionGas(uint256 gasPrice, uint256 gasLimit) public onlyAnyOwner {

        uint256 commission = gasPrice * gasLimit;
        minimumCommissionGas = commission;
    }

    function setMinimumExchangeOnBridge(uint256 _minimumExchangeOnBridge) public onlyAnyOwner {

        minimumExchangeOnBridge = _minimumExchangeOnBridge;
    }

    function setHowManyWritesToRefund(uint256 amount, address user) public onlyAllOwners {

        howManyWritesToRefund[user] = amount;
    }
}