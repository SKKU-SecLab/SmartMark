pragma solidity ^0.8.6;


contract TaxToken {

 

    uint256 _totalSupply;
    uint8 private _decimals;
    string private _name;
    string private _symbol;

    bool private _paused;  // ERC20 Pausable state

    address public owner;
    address public treasury;
    address public UNIV2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    bool public taxesRemoved;   /// @dev Once true, taxes are permanently set to 0 and CAN NOT be increased in the future.

    uint256 public maxWalletSize;
    uint256 public maxTxAmount;

    mapping(address => uint256) balances;                       // Track balances.
    mapping(address => mapping(address => uint256)) allowed;    // Track allowances.

    mapping(address => bool) public blacklist;          /// @dev If an address is blacklisted, they cannot perform transfer() or transferFrom().
    mapping(address => bool) public whitelist;          /// @dev Any transfer that involves a whitelisted address, will not incur a tax.
    mapping(address => uint) public senderTaxType;      /// @dev  Identifies tax type for msg.sender of transfer() call.
    mapping(address => uint) public receiverTaxType;    /// @dev  Identifies tax type for _to of transfer() call.
    mapping(uint => uint) public basisPointsTax;        /// @dev  Mapping between taxType and basisPoints (taxed).




    constructor(
        uint totalSupplyInput, 
        string memory nameInput, 
        string memory symbolInput, 
        uint8 decimalsInput,
        uint256 maxWalletSizeInput,
        uint256 maxTxAmountInput
    ) {
        _paused = false;    // ERC20 Pausable global state variable, initial state is not paused ("unpaused").
        _name = nameInput;
        _symbol = symbolInput;
        _decimals = decimalsInput;
        _totalSupply = totalSupplyInput * 10**_decimals;

        address UNISWAP_V2_PAIR = IUniswapV2Factory(
            IUniswapV2Router01(UNIV2_ROUTER).factory()
        ).createPair(address(this), IUniswapV2Router01(UNIV2_ROUTER).WETH());
 
        senderTaxType[UNISWAP_V2_PAIR] = 1;
        receiverTaxType[UNISWAP_V2_PAIR] = 2;

        owner = msg.sender;                                         // The "owner" is the "admin" of this contract.
        balances[msg.sender] = totalSupplyInput * 10**_decimals;    // Initial liquidity, allocated entirely to "owner".
        maxWalletSize = maxWalletSizeInput * 10**_decimals;
        maxTxAmount = maxTxAmountInput * 10**_decimals;      
    }

 


    modifier whenNotPausedUni(address a) {

        require(!paused() || whitelist[a], "ERR: Contract is currently paused.");
        _;
    }

    modifier whenNotPausedDual(address from, address to) {

        require(!paused() || whitelist[from] || whitelist[to], "ERR: Contract is currently paused.");
        _;
    }

    modifier whenNotPausedTri(address from, address to, address sender) {

        require(!paused() || whitelist[from] || whitelist[to] || whitelist[sender], "ERR: Contract is currently paused.");
        _;
    }

    modifier whenPaused() {

        require(paused(), "ERR: Contract is not currently paused.");
        _;
    }
    
    modifier onlyOwner {

       require(msg.sender == owner, "ERR: TaxToken.sol, onlyOwner()"); 
       _;
    }




    event Paused(address account);          /// @dev Emitted when the pause is triggered by `account`.
    event Unpaused(address account);        /// @dev Emitted when the pause is lifted by `account`.

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);   
 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event TransferTax(address indexed _from, address indexed _to, uint256 _value, uint256 _taxType);





    
    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];
    }
 

    function approve(address _spender, uint256 _amount) public returns (bool success) {

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
 
    function transfer(address _to, uint256 _amount) public whenNotPausedDual(msg.sender, _to) returns (bool success) {  


        uint _taxType;

        if (balances[msg.sender] >= _amount && (!blacklist[msg.sender] && !blacklist[_to])) {

            if (!whitelist[_to] && !whitelist[msg.sender] && _amount <= maxTxAmount) {

                if (senderTaxType[msg.sender] != 0) {
                    _taxType = senderTaxType[msg.sender];
                }

                if (receiverTaxType[_to] != 0) {
                    _taxType = receiverTaxType[_to];
                }

                uint _taxAmt = _amount * basisPointsTax[_taxType] / 10000;
                uint _sendAmt = _amount * (10000 - basisPointsTax[_taxType]) / 10000;

                if (balances[_to] + _sendAmt <= maxWalletSize) {

                    balances[msg.sender] -= _amount;
                    balances[_to] += _sendAmt;
                    balances[treasury] += _taxAmt;

                    require(_taxAmt + _sendAmt >= _amount * 999999999 / 1000000000, "Critical error, math.");
                
                    ITreasury(treasury).updateTaxesAccrued(
                        _taxType, _taxAmt
                    );
                    
                    emit Transfer(msg.sender, _to, _sendAmt);
                    emit TransferTax(msg.sender, treasury, _taxAmt, _taxType);

                    return true;
                }

                else {
                    return false;
                }

            }

            else if (!whitelist[_to] && !whitelist[msg.sender] && _amount > maxTxAmount) {
                return false;
            }

            else {
                balances[msg.sender] -= _amount;
                balances[_to] += _amount;
                emit Transfer(msg.sender, _to, _amount);
                return true;
            }
        }
        else {
            return false;
        }
    }
 
    function transferFrom(address _from, address _to, uint256 _amount) public whenNotPausedTri(_from, _to, msg.sender) returns (bool success) {


        uint _taxType;

        if (
            balances[_from] >= _amount && 
            allowed[_from][msg.sender] >= _amount && 
            _amount > 0 && balances[_to] + _amount > balances[_to] && 
            _amount <= maxTxAmount && (!blacklist[_from] && !blacklist[_to])
        ) {
            
            allowed[_from][msg.sender] -= _amount;

            if (!whitelist[_to] && !whitelist[_from] && _amount <= maxTxAmount) {

                if (senderTaxType[_from] != 0) {
                    _taxType = senderTaxType[_from];
                }

                if (receiverTaxType[_to] != 0) {
                    _taxType = receiverTaxType[_to];
                }

                uint _taxAmt = _amount * basisPointsTax[_taxType] / 10000;
                uint _sendAmt = _amount * (10000 - basisPointsTax[_taxType]) / 10000;

                if (balances[_to] + _sendAmt <= maxWalletSize || _taxType == 2) {

                    balances[_from] -= _amount;
                    balances[_to] += _sendAmt;
                    balances[treasury] += _taxAmt;

                    require(_taxAmt + _sendAmt == _amount, "Critical error, math.");
                
                    ITreasury(treasury).updateTaxesAccrued(
                        _taxType, _taxAmt
                    );
                    
                    emit Transfer(_from, _to, _sendAmt);
                    emit TransferTax(_from, treasury, _taxAmt, _taxType);

                    return true;
                }
                
                else {
                    return false;
                }

            }

            else if (!whitelist[_to] && !whitelist[_from] && _amount > maxTxAmount) {
                return false;
            }

            else {
                balances[_from] -= _amount;
                balances[_to] += _amount;
                emit Transfer(_from, _to, _amount);
                return true;
            }

        }
        else {
            return false;
        }
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }



    function pause() public onlyOwner whenNotPausedUni(msg.sender) {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }

    function paused() public view virtual returns (bool) {

        return _paused;
    }

    

    function updateSenderTaxType(address _sender, uint _taxType) public onlyOwner {

        require(_taxType < 3, "err _taxType must be less than 3");
        senderTaxType[_sender] = _taxType;
    }

    function updateReceiverTaxType(address _receiver, uint _taxType) public onlyOwner {

        require(_taxType < 3, "err _taxType must be less than 3");
        receiverTaxType[_receiver] = _taxType;
    }

    function adjustBasisPointsTax(uint _taxType, uint _bpt) public onlyOwner {

        require(_bpt <= 2000, "err TaxToken.sol _bpt > 2000 (20%)");
        require(!taxesRemoved, "err TaxToken.sol taxation has been removed");
        basisPointsTax[_taxType] = _bpt;
    }

    function permanentlyRemoveTaxes(uint _key) public onlyOwner {

        require(_key == 42, "err TaxToken.sol _key != 42");
        basisPointsTax[0] = 0;
        basisPointsTax[1] = 0;
        basisPointsTax[2] = 0;
        taxesRemoved = true;
    }



    function transferOwnership(address _owner) public onlyOwner {

        owner = _owner;
    }

    function setTreasury(address _treasury) public onlyOwner {

        treasury = _treasury;
    }

    function updateMaxTxAmount(uint256 _maxTxAmount) public onlyOwner {

        maxTxAmount = (_maxTxAmount * 10**_decimals);
    }

    function updateMaxWalletSize(uint256 _maxWalletSize) public onlyOwner {

        maxWalletSize = (_maxWalletSize * 10**_decimals);
    }

    function modifyWhitelist(address _wallet, bool _whitelist) public onlyOwner {

        whitelist[_wallet] = _whitelist;
    }

    function modifyBlacklist(address _wallet, bool _blacklist) public onlyOwner {

        blacklist[_wallet] = _blacklist;
    }
    
}
pragma solidity ^0.8.6;

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

}

interface ITreasury {

    function updateTaxesAccrued(uint taxType, uint amt) external;

}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external;

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external;

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

struct Slot0 {
    uint160 sqrtPriceX96;
    int24 tick;
    uint16 observationIndex;
    uint16 observationCardinality;
    uint16 observationCardinalityNext;
    uint8 feeProtocol;
    bool unlocked;
}

interface IUniPool {

    function slot0() external returns(Slot0 memory slot0);

    function liquidity() external returns(uint128 liquidity);

    function fee() external returns(uint24 fee);

    function token0() external returns(address token0);

    function token1() external returns(address token1);

    function tickSpacing() external returns(int24 tickSpacing);

    function tickBitmap(int16 i) external payable returns(uint256 o);

}


interface ILiquidityPoolV4 {


}

interface IDapperTri {

    function get_paid(
        address[3] memory _route, 
        uint8[3] memory _exchanges, 
        uint24[4] memory _poolFees, 
        address _borrow, 
        uint _borrowAmt
    ) external;

}

struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
}

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOut(
        uint amountIn, 
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

}

interface IUniswapQuoterV3 {

    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external view returns (uint256 amountOut);

}

interface IUniswapRouterV3 {

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);

}

interface IBancorNetwork {

     function conversionPath(
         IERC20 _sourceToken, 
         IERC20 _targetToken
    ) external view returns (address[] memory);

    function convert(
        address[] memory path,
        uint256 sourceAmount,
        uint256 minReturn
    ) external payable returns (uint256);

    function convertByPath(
        address[] memory path,
        uint256 sourceAmount,
        uint256 minReturn,
        address payable beneficiary,
        address affiliate,
        uint256 affiliateFee
    ) external payable returns (uint256);

    function rateByPath(
        address[] memory path, 
        uint256 sourceAmount
    ) external view returns (uint256);

}

interface ICRVMetaPool {

    function get_dy(uint256 i, uint256 j, uint256 dx) external view returns(uint256); 

    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external payable returns(uint256); 

    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy, bool use_eth) external payable returns(uint256);

    function exchange_underlying(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external payable returns(uint256);

    function add_liquidity(uint256[] memory amounts_in, uint256 min_mint_amount) external payable returns(uint256);

    function remove_liquidity(uint256 amount, uint256[] memory min_amounts_out) external returns(uint256[] memory);

}

interface ICRV {

    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external payable; 

    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy, bool use_eth) external payable;

}

interface ICRV_PP_128_NP {

    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;

    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256);

}
interface ICRV_PP_256_NP {

    function exchange(uint256 i, uint256 j, uint256 dx, uint256 min_dy, bool use_eth) external;

    function get_dy(uint256 i, uint256 j, uint256 dx) external view returns(uint256);

}
interface ICRV_PP_256_P {

    function exchange_underlying(uint256 i, uint256 j, uint256 dx, uint256 min_dy) external payable returns(uint256);

    function get_dy(uint256 i, uint256 j, uint256 dx) external view returns(uint256);

}
interface ICRV_MP_256 {

    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external payable returns(uint256);

    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external payable returns(uint256);

    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256);

}

interface ICRVSBTC {

    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256); 

    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint256); 

    function add_liquidity(uint256[3] memory amounts_in, uint256 min_mint_amount) external;

    function remove_liquidity(uint256 amount, uint256[3] memory min_amounts_out) external;

    function remove_liquidity_one_coin(uint256 token_amount, int128 index, uint min_amount) external;

}

interface ICRVSBTC_CRV {

    function get_dy(int128 i, int128 j, uint256 dx) external view returns(uint256); 

    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy, address _receiver) external; 

    function add_liquidity(uint256[3] memory amounts_in, uint256 min_mint_amount) external;

    function remove_liquidity(uint256 amount, uint256[3] memory min_amounts_out) external;

    function remove_liquidity_one_coin(uint256 token_amount, int128 index, uint min_amount) external;

}

interface ISushiRouter {

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOut(
        uint amountIn, 
        address[] calldata path
    ) external view returns (uint[] memory amounts);

}

interface IWSTETH {

    function wrap(uint256 _stETHAmount) external returns (uint256);

    function unwrap(uint256 _wstETHAmount) external returns (uint256);

}

interface IVault {

    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;

}

interface IFlashLoanRecipient {

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external;

}

interface IWETH {

    function deposit() external payable;

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}