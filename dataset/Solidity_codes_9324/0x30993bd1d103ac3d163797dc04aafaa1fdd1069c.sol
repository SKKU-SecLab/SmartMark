

pragma solidity 0.6.12;

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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract Initializable {

    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function isConstructor() private view returns (bool) {

        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    uint256[50] private ______gap;
}

contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}

contract ERC20UpgradeSafe is Initializable, ContextUpgradeSafe, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;


    function __ERC20_init(string memory name, string memory symbol) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
    }

    function __ERC20_init_unchained(string memory name, string memory symbol) internal initializer {

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

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

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


    uint256[44] private __gap;
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface Converter {

    function convert(address) external returns (uint256);

}

interface ICompositeVault {

    function cap() external view returns (uint256);


    function getConverter() external view returns (address);


    function getVaultMaster() external view returns (address);


    function balance() external view returns (uint256);


    function tvl() external view returns (uint256); // total dollar value


    function token() external view returns (address);


    function available() external view returns (uint256);


    function accept(address _input) external view returns (bool);


    function earn() external;


    function harvest(address reserve, uint256 amount) external;


    function addNewCompound(uint256, uint256) external;


    function withdraw_fee(uint256 _shares) external view returns (uint256);


    function calc_token_amount_deposit(address _input, uint256 _amount) external view returns (uint256);


    function calc_add_liquidity(uint256 _amount0, uint256 _amount1) external view returns (uint256);


    function calc_token_amount_withdraw(uint256 _shares, address _output) external view returns (uint256);


    function calc_remove_liquidity(uint256 _shares) external view returns (uint256 _amount0, uint256 _amount1);


    function getPricePerFullShare() external view returns (uint256);


    function get_virtual_price() external view returns (uint256); // average dollar value of vault share token


    function deposit(
        address _input,
        uint256 _amount,
        uint256 _min_mint_amount
    ) external returns (uint256);


    function depositFor(
        address _account,
        address _to,
        address _input,
        uint256 _amount,
        uint256 _min_mint_amount
    ) external returns (uint256 _mint_amount);


    function addLiquidity(
        uint256 _amount0,
        uint256 _amount1,
        uint256 _min_mint_amount
    ) external returns (uint256);


    function addLiquidityFor(
        address _account,
        address _to,
        uint256 _amount0,
        uint256 _amount1,
        uint256 _min_mint_amount
    ) external returns (uint256 _mint_amount);


    function withdraw(
        uint256 _shares,
        address _output,
        uint256 _min_output_amount
    ) external returns (uint256);


    function withdrawFor(
        address _account,
        uint256 _shares,
        address _output,
        uint256 _min_output_amount
    ) external returns (uint256 _output_amount);


    function harvestStrategy(address _strategy) external;


    function harvestAllStrategies() external;

}

interface IVaultMaster {

    function bank(address) external view returns (address);


    function isVault(address) external view returns (bool);


    function isController(address) external view returns (bool);


    function isStrategy(address) external view returns (bool);


    function slippage(address) external view returns (uint256);


    function convertSlippage(address _input, address _output) external view returns (uint256);


    function valueToken() external view returns (address);


    function govVault() external view returns (address);


    function insuranceFund() external view returns (address);


    function performanceReward() external view returns (address);


    function govVaultProfitShareFee() external view returns (uint256);


    function gasFee() external view returns (uint256);


    function insuranceFee() external view returns (uint256);


    function withdrawalProtectionFee() external view returns (uint256);

}

interface IController {

    function vault() external view returns (address);


    function strategyLength() external view returns (uint256);


    function strategyBalance() external view returns (uint256);


    function getStrategyCount() external view returns (uint256);


    function strategies(uint256 _stratId)
        external
        view
        returns (
            address _strategy,
            uint256 _quota,
            uint256 _percent
        );


    function getBestStrategy() external view returns (address _strategy);


    function want() external view returns (address);


    function balanceOf() external view returns (uint256);


    function withdraw_fee(uint256 _amount) external view returns (uint256); // eg. 3CRV => pJar: 0.5% (50/10000)


    function investDisabled() external view returns (bool);


    function withdraw(uint256) external returns (uint256 _withdrawFee);


    function earn(address _token, uint256 _amount) external;


    function harvestStrategy(address _strategy) external;


    function harvestAllStrategies() external;

}

interface ILpPairConverter {

    function lpPair() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function accept(address _input) external view returns (bool);


    function get_virtual_price() external view returns (uint256);


    function convert_rate(
        address _input,
        address _output,
        uint256 _inputAmount
    ) external view returns (uint256 _outputAmount);


    function calc_add_liquidity(uint256 _amount0, uint256 _amount1) external view returns (uint256);


    function calc_remove_liquidity(uint256 _shares) external view returns (uint256 _amount0, uint256 _amount1);


    function convert(
        address _input,
        address _output,
        address _to
    ) external returns (uint256 _outputAmount);


    function add_liquidity(address _to) external returns (uint256 _outputAmount);


    function remove_liquidity(address _to) external returns (uint256 _amount0, uint256 _amount1);

}

interface IDecimals {

    function decimals() external view returns (uint8);

}

abstract contract CompositeVaultBase is ERC20UpgradeSafe, ICompositeVault {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public basedToken;

    IERC20 public token0;
    IERC20 public token1;

    uint256 public min = 9500;
    uint256 public constant max = 10000;

    uint256 public earnLowerlimit = 1; // minimum to invest
    uint256 public depositLimit = 0; // limit for each deposit (set 0 to disable)
    uint256 private totalDepositCap = 0; // initial cap (set 0 to disable)

    address public governance;
    address public controller;

    IVaultMaster vaultMaster;
    ILpPairConverter public basedConverter; // converter for basedToken (SLP or BPT or UNI)

    mapping(address => address) public converterMap; // non-core token => converter

    bool public acceptContractDepositor = false;
    mapping(address => bool) public whitelistedContract;
    bool private _mutex;

    bytes32 private _minterBlock;

    uint256 public totalPendingCompound;
    uint256 public startReleasingCompoundBlk;
    uint256 public endReleasingCompoundBlk;

    function initialize(
        IERC20 _basedToken,
        IERC20 _token0,
        IERC20 _token1,
        IVaultMaster _vaultMaster
    ) public initializer {
        __ERC20_init(_getName(), _getSymbol());
        _setupDecimals(IDecimals(address(_basedToken)).decimals());

        basedToken = _basedToken;
        token0 = _token0;
        token1 = _token1;
        vaultMaster = _vaultMaster;
        governance = msg.sender;
    }

    function _getName() internal view virtual returns (string memory);

    function _getSymbol() internal view virtual returns (string memory);

    modifier checkContract(address _account) {
        if (!acceptContractDepositor && !whitelistedContract[_account] && (_account != vaultMaster.bank(address(this)))) {
            require(!address(_account).isContract() && _account == tx.origin, "contract not support");
        }
        _;
    }

    modifier _non_reentrant_() {
        require(!_mutex, "reentry");
        _mutex = true;
        _;
        _mutex = false;
    }

    function setAcceptContractDepositor(bool _acceptContractDepositor) external {
        require(msg.sender == governance, "!governance");
        acceptContractDepositor = _acceptContractDepositor;
    }

    function whitelistContract(address _contract) external {
        require(msg.sender == governance, "!governance");
        whitelistedContract[_contract] = true;
    }

    function unwhitelistContract(address _contract) external {
        require(msg.sender == governance, "!governance");
        whitelistedContract[_contract] = false;
    }

    function cap() external view override returns (uint256) {
        return totalDepositCap;
    }

    function getConverter() external view override returns (address) {
        return address(basedConverter);
    }

    function getVaultMaster() external view override returns (address) {
        return address(vaultMaster);
    }

    function accept(address _input) external view override returns (bool) {
        return basedConverter.accept(_input);
    }

    function addNewCompound(uint256 _newCompound, uint256 _blocksToReleaseCompound) external override {
        require(msg.sender == governance || vaultMaster.isStrategy(msg.sender), "!authorized");
        if (_blocksToReleaseCompound == 0) {
            totalPendingCompound = 0;
            startReleasingCompoundBlk = 0;
            endReleasingCompoundBlk = 0;
        } else {
            totalPendingCompound = pendingCompound().add(_newCompound);
            startReleasingCompoundBlk = block.number;
            endReleasingCompoundBlk = block.number.add(_blocksToReleaseCompound);
        }
    }

    function pendingCompound() public view returns (uint256) {
        if (totalPendingCompound == 0 || endReleasingCompoundBlk <= block.number) return 0;
        return totalPendingCompound.mul(endReleasingCompoundBlk.sub(block.number)).div(endReleasingCompoundBlk.sub(startReleasingCompoundBlk).add(1));
    }

    function balance() public view override returns (uint256 _balance) {
        _balance = basedToken.balanceOf(address(this)).add(IController(controller).balanceOf()).sub(pendingCompound());
    }

    function tvl() public view override returns (uint256) {
        return balance().mul(basedConverter.get_virtual_price()).div(1e18);
    }

    function setMin(uint256 _min) external {
        require(msg.sender == governance, "!governance");
        min = _min;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        require(IController(_controller).want() == address(basedToken), "!token");
        controller = _controller;
    }

    function setConverter(ILpPairConverter _converter) external {
        require(msg.sender == governance, "!governance");
        require(_converter.lpPair() == address(basedToken), "!token");
        basedConverter = _converter;
    }

    function setConverterMap(address _token, address _converter) external {
        require(msg.sender == governance, "!governance");
        converterMap[_token] = _converter;
    }

    function setVaultMaster(IVaultMaster _vaultMaster) external {
        require(msg.sender == governance, "!governance");
        vaultMaster = _vaultMaster;
    }

    function setEarnLowerlimit(uint256 _earnLowerlimit) external {
        require(msg.sender == governance, "!governance");
        earnLowerlimit = _earnLowerlimit;
    }

    function setCap(uint256 _cap) external {
        require(msg.sender == governance, "!governance");
        totalDepositCap = _cap;
    }

    function setDepositLimit(uint256 _limit) external {
        require(msg.sender == governance, "!governance");
        depositLimit = _limit;
    }

    function token() public view override returns (address) {
        return address(basedToken);
    }

    function available() public view override returns (uint256) {
        return basedToken.balanceOf(address(this)).mul(min).div(max);
    }

    function earn() public override {
        if (controller != address(0)) {
            IController _contrl = IController(controller);
            if (!_contrl.investDisabled()) {
                uint256 _bal = available();
                if (_bal >= earnLowerlimit) {
                    basedToken.safeTransfer(controller, _bal);
                    _contrl.earn(address(basedToken), _bal);
                }
            }
        }
    }

    function earnExtra(address _token) external {
        require(msg.sender == governance, "!governance");
        require(converterMap[_token] != address(0), "!converter");
        require(address(_token) != address(basedToken), "token");
        require(address(_token) != address(this), "share");
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        address _converter = converterMap[_token];
        IERC20(_token).safeTransfer(_converter, _amount);
        Converter(_converter).convert(_token);
    }

    function withdraw_fee(uint256 _shares) public view override returns (uint256) {
        return (controller == address(0)) ? 0 : IController(controller).withdraw_fee(_shares);
    }

    function calc_token_amount_deposit(address _input, uint256 _amount) external view override returns (uint256) {
        return basedConverter.convert_rate(_input, address(basedToken), _amount).mul(1e18).div(getPricePerFullShare());
    }

    function calc_add_liquidity(uint256 _amount0, uint256 _amount1) external view override returns (uint256) {
        return basedConverter.calc_add_liquidity(_amount0, _amount1).mul(1e18).div(getPricePerFullShare());
    }

    function _calc_shares_to_amount_withdraw(uint256 _shares) internal view returns (uint256) {
        uint256 _withdrawFee = withdraw_fee(_shares);
        if (_withdrawFee > 0) {
            _shares = _shares.sub(_withdrawFee);
        }
        uint256 _totalSupply = totalSupply();
        return (_totalSupply == 0) ? _shares : (balance().mul(_shares)).div(_totalSupply);
    }

    function calc_token_amount_withdraw(uint256 _shares, address _output) external view override returns (uint256) {
        uint256 r = _calc_shares_to_amount_withdraw(_shares);
        if (_output != address(basedToken)) {
            r = basedConverter.convert_rate(address(basedToken), _output, r);
        }
        return r;
    }

    function calc_remove_liquidity(uint256 _shares) external view override returns (uint256 _amount0, uint256 _amount1) {
        uint256 r = _calc_shares_to_amount_withdraw(_shares);
        (_amount0, _amount1) = basedConverter.calc_remove_liquidity(r);
    }

    function deposit(
        address _input,
        uint256 _amount,
        uint256 _min_mint_amount
    ) external override returns (uint256) {
        return depositFor(msg.sender, msg.sender, _input, _amount, _min_mint_amount);
    }

    function depositFor(
        address _account,
        address _to,
        address _input,
        uint256 _amount,
        uint256 _min_mint_amount
    ) public override checkContract(_account) _non_reentrant_ returns (uint256 _mint_amount) {
        uint256 _pool = balance();
        require(totalDepositCap == 0 || _pool <= totalDepositCap, ">totalDepositCap");
        uint256 _before = basedToken.balanceOf(address(this));
        if (_input == address(basedToken)) {
            basedToken.safeTransferFrom(_account, address(this), _amount);
        } else {
            uint256 _before0;
            uint256 _before1;
            if (address(token0) != address(0) && address(token1) != address(0)) {
                _before0 = token0.balanceOf(address(this));
                _before1 = token1.balanceOf(address(this));
            }
            IERC20(_input).safeTransferFrom(_account, address(basedConverter), _amount);
            basedConverter.convert(_input, address(basedToken), address(this));
            if (address(token0) != address(0) && address(token1) != address(0)) {
                uint256 _after0 = token0.balanceOf(address(this));
                uint256 _after1 = token1.balanceOf(address(this));
                if (_after0 > _before0) {
                    token0.safeTransfer(_account, _after0.sub(_before0));
                }
                if (_after1 > _before1) {
                    token1.safeTransfer(_account, _after1.sub(_before1));
                }
            }
        }
        uint256 _after = basedToken.balanceOf(address(this));
        _amount = _after.sub(_before); // additional check for deflationary tokens
        require(depositLimit == 0 || _amount <= depositLimit, ">depositLimit");
        require(_amount > 0, "no token");
        _mint_amount = _deposit(_to, _pool, _amount);
        require(_mint_amount >= _min_mint_amount, "slippage");
    }

    function addLiquidity(
        uint256 _amount0,
        uint256 _amount1,
        uint256 _min_mint_amount
    ) external override returns (uint256) {
        return addLiquidityFor(msg.sender, msg.sender, _amount0, _amount1, _min_mint_amount);
    }

    function addLiquidityFor(
        address _account,
        address _to,
        uint256 _amount0,
        uint256 _amount1,
        uint256 _min_mint_amount
    ) public override checkContract(_account) _non_reentrant_ returns (uint256 _mint_amount) {
        require(msg.sender == _account || msg.sender == vaultMaster.bank(address(this)), "!bank && !yourself");
        uint256 _pool = balance();
        require(totalDepositCap == 0 || _pool <= totalDepositCap, ">totalDepositCap");
        uint256 _beforeToken = basedToken.balanceOf(address(this));
        uint256 _before0 = token0.balanceOf(address(this));
        uint256 _before1 = token1.balanceOf(address(this));
        token0.safeTransferFrom(_account, address(basedConverter), _amount0);
        token1.safeTransferFrom(_account, address(basedConverter), _amount1);
        basedConverter.add_liquidity(address(this));
        uint256 _afterToken = basedToken.balanceOf(address(this));
        uint256 _after0 = token0.balanceOf(address(this));
        uint256 _after1 = token1.balanceOf(address(this));
        uint256 _totalDepositAmount = _afterToken.sub(_beforeToken); // additional check for deflationary tokens
        require(depositLimit == 0 || _totalDepositAmount <= depositLimit, ">depositLimit");
        require(_totalDepositAmount > 0, "no token");
        if (_after0 > _before0) {
            token0.safeTransfer(_account, _after0.sub(_before0));
        }
        if (_after1 > _before1) {
            token1.safeTransfer(_account, _after1.sub(_before1));
        }
        _mint_amount = _deposit(_to, _pool, _totalDepositAmount);
        require(_mint_amount >= _min_mint_amount, "slippage");
    }

    function _deposit(
        address _mintTo,
        uint256 _pool,
        uint256 _amount
    ) internal returns (uint256 _shares) {
        if (totalSupply() == 0) {
            _shares = _amount;
        } else {
            _shares = (_amount.mul(totalSupply())).div(_pool);
        }

        if (_shares > 0) {
            earn();

            _minterBlock = keccak256(abi.encodePacked(tx.origin, block.number));
            _mint(_mintTo, _shares);
        }
    }

    function harvest(address reserve, uint256 amount) external override {
        require(msg.sender == controller, "!controller");
        require(reserve != address(basedToken), "basedToken");
        IERC20(reserve).safeTransfer(controller, amount);
    }

    function harvestStrategy(address _strategy) external override {
        require(msg.sender == governance || msg.sender == vaultMaster.bank(address(this)), "!governance && !bank");
        IController(controller).harvestStrategy(_strategy);
    }

    function harvestAllStrategies() external override {
        require(msg.sender == governance || msg.sender == vaultMaster.bank(address(this)), "!governance && !bank");
        IController(controller).harvestAllStrategies();
    }

    function withdraw(
        uint256 _shares,
        address _output,
        uint256 _min_output_amount
    ) external override returns (uint256) {
        return withdrawFor(msg.sender, _shares, _output, _min_output_amount);
    }

    function withdrawFor(
        address _account,
        uint256 _shares,
        address _output,
        uint256 _min_output_amount
    ) public override _non_reentrant_ returns (uint256 _output_amount) {
        require(keccak256(abi.encodePacked(tx.origin, block.number)) != _minterBlock, "REENTR MINT-BURN");

        _output_amount = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);

        uint256 _withdrawalProtectionFee = vaultMaster.withdrawalProtectionFee();
        if (_withdrawalProtectionFee > 0) {
            uint256 _withdrawalProtection = _output_amount.mul(_withdrawalProtectionFee).div(10000);
            _output_amount = _output_amount.sub(_withdrawalProtection);
        }

        uint256 b = basedToken.balanceOf(address(this));
        if (b < _output_amount) {
            uint256 _toWithdraw = _output_amount.sub(b);
            uint256 _withdrawFee = IController(controller).withdraw(_toWithdraw);
            uint256 _after = basedToken.balanceOf(address(this));
            uint256 _diff = _after.sub(b);
            if (_diff < _toWithdraw) {
                _output_amount = b.add(_diff);
            }
            if (_withdrawFee > 0) {
                _output_amount = _output_amount.sub(_withdrawFee, "_output_amount < _withdrawFee");
            }
        }

        if (_output == address(basedToken)) {
            require(_output_amount >= _min_output_amount, "slippage");
            basedToken.safeTransfer(_account, _output_amount);
        } else {
            basedToken.safeTransfer(address(basedConverter), _output_amount);
            uint256 _received = basedConverter.convert(address(basedToken), _output, address(this));
            require(_received >= _min_output_amount, "slippage");
            IERC20(_output).safeTransfer(_account, _received);
        }
    }

    function getPricePerFullShare() public view override returns (uint256) {
        return (totalSupply() == 0) ? 1e18 : balance().mul(1e18).div(totalSupply());
    }

    function get_virtual_price() external view override returns (uint256) {
        return basedConverter.get_virtual_price().mul(getPricePerFullShare()).div(1e18);
    }

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 amount,
        address to
    ) external {
        require(msg.sender == governance, "!governance");
        require(address(_token) != address(basedToken), "token");
        require(address(_token) != address(this), "share");
        _token.safeTransfer(to, amount);
    }
}

contract CompositeVaultBBridgeUsdc is CompositeVaultBase {

    function _getName() internal view override returns (string memory) {

        return "CompositeVault:BBridgeUsdc";
    }

    function _getSymbol() internal view override returns (string memory) {

        return "cvUSDC:BB";
    }

    event ExecuteTransaction(address indexed target, uint256 value, string signature, bytes data);

    function executeTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data
    ) public returns (bytes memory) {

        require(msg.sender == governance, "!governance");

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, string(abi.encodePacked(_getName(), "::executeTransaction: Transaction execution reverted.")));

        emit ExecuteTransaction(target, value, signature, data);

        return returnData;
    }
}