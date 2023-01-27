

pragma solidity 0.6.12;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


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
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
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
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }

    uint256[50] private ______gap;
}

contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


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

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }


    uint256[44] private __gap;
}

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


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface Converter {

    function convert(address) external returns (uint);

}

interface IValueMultiVault {

    function cap() external view returns (uint);

    function getConverter(address _want) external view returns (address);

    function getVaultMaster() external view returns (address);

    function balance() external view returns (uint);

    function token() external view returns (address);

    function available(address _want) external view returns (uint);

    function accept(address _input) external view returns (bool);


    function claimInsurance() external;

    function earn(address _want) external;

    function harvest(address reserve, uint amount) external;


    function withdraw_fee(uint _shares) external view returns (uint);

    function calc_token_amount_deposit(uint[] calldata _amounts) external view returns (uint);

    function calc_token_amount_withdraw(uint _shares, address _output) external view returns (uint);

    function convert_rate(address _input, uint _amount) external view returns (uint);

    function getPricePerFullShare() external view returns (uint);

    function get_virtual_price() external view returns (uint); // average dollar value of vault share token


    function deposit(address _input, uint _amount, uint _min_mint_amount) external returns (uint _mint_amount);

    function depositFor(address _account, address _to, address _input, uint _amount, uint _min_mint_amount) external returns (uint _mint_amount);

    function depositAll(uint[] calldata _amounts, uint _min_mint_amount) external returns (uint _mint_amount);

    function depositAllFor(address _account, address _to, uint[] calldata _amounts, uint _min_mint_amount) external returns (uint _mint_amount);

    function withdraw(uint _shares, address _output, uint _min_output_amount) external returns (uint);

    function withdrawFor(address _account, uint _shares, address _output, uint _min_output_amount) external returns (uint _output_amount);


    function harvestStrategy(address _strategy) external;

    function harvestWant(address _want) external;

    function harvestAllStrategies() external;

}

interface IValueVaultMaster {

    function bank(address) view external returns (address);

    function isVault(address) view external returns (bool);

    function isController(address) view external returns (bool);

    function isStrategy(address) view external returns (bool);


    function slippage(address) view external returns (uint);

    function convertSlippage(address _input, address _output) view external returns (uint);


    function valueToken() view external returns (address);

    function govVault() view external returns (address);

    function insuranceFund() view external returns (address);

    function performanceReward() view external returns (address);


    function govVaultProfitShareFee() view external returns (uint);

    function gasFee() view external returns (uint);

    function insuranceFee() view external returns (uint);

    function withdrawalProtectionFee() view external returns (uint);

}

interface IMultiVaultController {

    function vault() external view returns (address);


    function wantQuota(address _want) external view returns (uint);

    function wantStrategyLength(address _want) external view returns (uint);

    function wantStrategyBalance(address _want) external view returns (uint);


    function getStrategyCount() external view returns(uint);

    function strategies(address _want, uint _stratId) external view returns (address _strategy, uint _quota, uint _percent);

    function getBestStrategy(address _want) external view returns (address _strategy);


    function basedWant() external view returns (address);

    function want() external view returns (address);

    function wantLength() external view returns (uint);


    function balanceOf(address _want, bool _sell) external view returns (uint);

    function withdraw_fee(address _want, uint _amount) external view returns (uint); // eg. 3CRV => pJar: 0.5% (50/10000)

    function investDisabled(address _want) external view returns (bool);


    function withdraw(address _want, uint) external returns (uint _withdrawFee);

    function earn(address _token, uint _amount) external;


    function harvestStrategy(address _strategy) external;

    function harvestWant(address _want) external;

    function harvestAllStrategies() external;

}

interface IMultiVaultConverter {

    function token() external returns (address);

    function get_virtual_price() external view returns (uint);


    function convert_rate(address _input, address _output, uint _inputAmount) external view returns (uint _outputAmount);

    function calc_token_amount_deposit(uint[] calldata _amounts) external view returns (uint _shareAmount);

    function calc_token_amount_withdraw(uint _shares, address _output) external view returns (uint _outputAmount);


    function convert(address _input, address _output, uint _inputAmount) external returns (uint _outputAmount);

    function convertAll(uint[] calldata _amounts) external returns (uint _outputAmount);

}

interface IShareConverter {

    function convert_shares_rate(address _input, address _output, uint _inputAmount) external view returns (uint _outputAmount);


    function convert_shares(address _input, address _output, uint _inputAmount) external returns (uint _outputAmount);

}

contract MultiStablesVault is ERC20UpgradeSafe, IValueMultiVault {

    using Address for address;
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20 public basedToken; // [3CRV] (used for center-metric price: share value will based on this)

    IERC20[] public inputTokens; // DAI, USDC, USDT, 3CRV, BUSD, sUSD, husd
    IERC20[] public wantTokens; // [3CRV], [yDAI+yUSDC+yUSDT+yBUSD], [crvPlain3andSUSD], [husd3CRV], [cDAI+cUSDC], [yDAI+yUSDC+yUSDT+yTUSD]

    mapping(address => uint) public inputTokenIndex; // input_token_address => (index + 1)
    mapping(address => uint) public wantTokenIndex; // want_token_address => (index + 1)
    mapping(address => address) public input2Want; // eg. BUSD => [yDAI+yUSDC+yUSDT+yBUSD], sUSD => [husd3CRV]
    mapping(address => bool) public allowWithdrawFromOtherWant; // we allow to withdraw from others if based want strategies have not enough balance

    uint public min = 9500;
    uint public constant max = 10000;

    uint public earnLowerlimit = 10 ether; // minimum to invest is 10 3CRV
    uint totalDepositCap = 10000000 ether; // initial cap set at 10 million dollar

    address public governance;
    address public controller;
    uint public insurance;
    IValueVaultMaster vaultMaster;
    IMultiVaultConverter public basedConverter; // converter for 3CRV
    IShareConverter public shareConverter; // converter for shares (3CRV <-> BCrv, etc ...)

    mapping(address => IMultiVaultConverter) public converters; // want_token_address => converter
    mapping(address => address) public converterMap; // non-core token => converter

    bool public acceptContractDepositor = false;
    mapping(address => bool) public whitelistedContract;

    event Deposit(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);
    event RewardPaid(address indexed user, uint reward);

    function initialize(IERC20 _basedToken, IValueVaultMaster _vaultMaster) public initializer {

        __ERC20_init("ValueDefi:MultiVault:Stables", "mvUSD");
        basedToken = _basedToken;
        vaultMaster = _vaultMaster;
        governance = msg.sender;
    }

    modifier checkContract() {

        if (!acceptContractDepositor && !whitelistedContract[msg.sender]) {
            require(!address(msg.sender).isContract() && msg.sender == tx.origin, "contract not support");
        }
        _;
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

    function cap() external override view returns (uint) {

        return totalDepositCap;
    }

    function getConverter(address _want) external override view returns (address) {

        return address(converters[_want]);
    }

    function getVaultMaster() external override view returns (address) {

        return address(vaultMaster);
    }

    function accept(address _input) external override view returns (bool) {

        return inputTokenIndex[_input] > 0;
    }

    function balance() public override view returns (uint) {

        uint bal = basedToken.balanceOf(address(this));
        if (controller != address(0)) bal = bal.add(IMultiVaultController(controller).balanceOf(address(basedToken), false));
        return bal.sub(insurance);
    }

    function balance_to_sell() public view returns (uint) {

        uint bal = basedToken.balanceOf(address(this));
        if (controller != address(0)) bal = bal.add(IMultiVaultController(controller).balanceOf(address(basedToken), true));
        return bal.sub(insurance);
    }

    function setMin(uint _min) external {

        require(msg.sender == governance, "!governance");
        min = _min;
    }

    function setGovernance(address _governance) external {

        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setController(address _controller) external {

        require(msg.sender == governance, "!governance");
        controller = _controller;
    }

    function setConverter(address _want, IMultiVaultConverter _converter) external {

        require(msg.sender == governance, "!governance");
        require(_converter.token() == _want, "!_want");
        converters[_want] = _converter;
        if (_want == address(basedToken)) basedConverter = _converter;
    }

    function setShareConverter(IShareConverter _shareConverter) external {

        require(msg.sender == governance, "!governance");
        shareConverter = _shareConverter;
    }

    function setConverterMap(address _token, address _converter) external {

        require(msg.sender == governance, "!governance");
        converterMap[_token] = _converter;
    }

    function setVaultMaster(IValueVaultMaster _vaultMaster) external {

        require(msg.sender == governance, "!governance");
        vaultMaster = _vaultMaster;
    }

    function setEarnLowerlimit(uint _earnLowerlimit) external {

        require(msg.sender == governance, "!governance");
        earnLowerlimit = _earnLowerlimit;
    }

    function setCap(uint _cap) external {

        require(msg.sender == governance, "!governance");
        totalDepositCap = _cap;
    }

    function claimInsurance() external override {

        if (msg.sender != controller) {
            require(msg.sender == governance, "!governance");
            basedToken.safeTransfer(vaultMaster.insuranceFund(), insurance);
        }
        insurance = 0;
    }

    function setInputTokens(IERC20[] memory _inputTokens) external {

        require(msg.sender == governance, "!governance");
        for (uint256 i = 0; i < inputTokens.length; ++i) {
            inputTokenIndex[address(inputTokens[i])] = 0;
        }
        delete inputTokens;
        for (uint256 i = 0; i < _inputTokens.length; ++i) {
            inputTokens.push(_inputTokens[i]);
            inputTokenIndex[address(_inputTokens[i])] = i + 1;
        }
    }

    function setInputToken(uint _index, IERC20 _inputToken) external {

        require(msg.sender == governance, "!governance");
        inputTokenIndex[address(inputTokens[_index])] = 0;
        inputTokens[_index] = _inputToken;
        inputTokenIndex[address(_inputToken)] = _index + 1;
    }

    function setWantTokens(IERC20[] memory _wantTokens) external {

        require(msg.sender == governance, "!governance");
        for (uint256 i = 0; i < wantTokens.length; ++i) {
            wantTokenIndex[address(wantTokens[i])] = 0;
        }
        delete wantTokens;
        for (uint256 i = 0; i < _wantTokens.length; ++i) {
            wantTokens.push(_wantTokens[i]);
            wantTokenIndex[address(_wantTokens[i])] = i + 1;
        }
    }

    function setInput2Want(address _inputToken, address _wantToken) external {

        require(msg.sender == governance, "!governance");
        input2Want[_inputToken] = _wantToken;
    }

    function setAllowWithdrawFromOtherWant(address _token, bool _allow) external {

        require(msg.sender == governance, "!governance");
        allowWithdrawFromOtherWant[_token] = _allow;
    }

    function token() public override view returns (address) {

        return address(basedToken);
    }

    function available(address _want) public override view returns (uint) {

        uint _bal = IERC20(_want).balanceOf(address(this));
        return (_want == address(basedToken)) ? _bal.mul(min).div(max) : _bal;
    }

    function earn(address _want) public override {

        if (controller != address(0)) {
            IMultiVaultController _contrl = IMultiVaultController(controller);
            if (!_contrl.investDisabled(_want)) {
                uint _bal = available(_want);
                if ((_bal > 0) && (_want != address(basedToken) || _bal >= earnLowerlimit)) {
                    IERC20(_want).safeTransfer(controller, _bal);
                    _contrl.earn(_want, _bal);
                }
            }
        }
    }

    function convert_nonbased_want(address _want, uint _amount) external {

        require(msg.sender == governance, "!governance");
        require(_want != address(basedToken), "basedToken");
        require(address(shareConverter) != address(0), "!shareConverter");
        require(shareConverter.convert_shares_rate(_want, address(basedToken), _amount) > 0, "rate=0");
        IERC20(_want).safeTransfer(address(shareConverter), _amount);
        shareConverter.convert_shares(_want, address(basedToken), _amount);
    }

    function earnExtra(address _token) external {

        require(msg.sender == governance, "!governance");
        require(converterMap[_token] != address(0), "!converter");
        require(address(_token) != address(basedToken), "3crv");
        require(address(_token) != address(this), "mvUSD");
        require(wantTokenIndex[_token] == 0, "wantToken");
        uint _amount = IERC20(_token).balanceOf(address(this));
        address _converter = converterMap[_token];
        IERC20(_token).safeTransfer(_converter, _amount);
        Converter(_converter).convert(_token);
    }

    function withdraw_fee(uint _shares) public override view returns (uint) {

        return (controller == address(0)) ? 0 : IMultiVaultController(controller).withdraw_fee(address(basedToken), _shares);
    }

    function calc_token_amount_deposit(uint[] calldata _amounts) external override view returns (uint) {

        return basedConverter.calc_token_amount_deposit(_amounts).mul(1e18).div(getPricePerFullShare());
    }

    function calc_token_amount_withdraw(uint _shares, address _output) external override view returns (uint) {

        uint _withdrawFee = withdraw_fee(_shares);
        if (_withdrawFee > 0) {
            _shares = _shares.sub(_withdrawFee);
        }
        uint _totalSupply = totalSupply();
        uint r = (_totalSupply == 0) ? _shares : (balance().mul(_shares)).div(_totalSupply);
        if (_output == address(basedToken)) {
            return r;
        }
        return basedConverter.calc_token_amount_withdraw(r, _output).mul(1e18).div(getPricePerFullShare());
    }

    function convert_rate(address _input, uint _amount) external override view returns (uint) {

        return basedConverter.convert_rate(_input, address(basedToken), _amount).mul(1e18).div(getPricePerFullShare());
    }

    function deposit(address _input, uint _amount, uint _min_mint_amount) external override checkContract returns (uint) {

        return depositFor(msg.sender, msg.sender, _input, _amount, _min_mint_amount);
    }

    function depositFor(address _account, address _to, address _input, uint _amount, uint _min_mint_amount) public override checkContract returns (uint _mint_amount) {

        require(msg.sender == _account || msg.sender == vaultMaster.bank(address(this)), "!bank && !yourself");
        uint _pool = balance();
        require(totalDepositCap == 0 || _pool <= totalDepositCap, ">totalDepositCap");
        uint _before = 0;
        uint _after = 0;
        address _want = address(0);
        address _ctrlWant = IMultiVaultController(controller).want();
        if (_input == address(basedToken) || _input == _ctrlWant) {
            _want = _want;
            _before = IERC20(_input).balanceOf(address(this));
            basedToken.safeTransferFrom(_account, address(this), _amount);
            _after = IERC20(_input).balanceOf(address(this));
            _amount = _after.sub(_before); // additional check for deflationary tokens
        } else {
            _want = input2Want[_input];
            if (_want == address(0)) {
                _want = _ctrlWant;
            }
            IMultiVaultConverter _converter = converters[_want];
            require(_converter.convert_rate(_input, _want, _amount) > 0, "rate=0");
            _before = IERC20(_want).balanceOf(address(this));
            IERC20(_input).safeTransferFrom(_account, address(_converter), _amount);
            _converter.convert(_input, _want, _amount);
            _after = IERC20(_want).balanceOf(address(this));
            _amount = _after.sub(_before); // additional check for deflationary tokens
        }
        require(_amount > 0, "no _want");
        _mint_amount = _deposit(_to, _pool, _amount, _want);
        require(_mint_amount >= _min_mint_amount, "slippage");
    }

    function depositAll(uint[] calldata _amounts, uint _min_mint_amount) external override checkContract returns (uint) {

        return depositAllFor(msg.sender, msg.sender, _amounts, _min_mint_amount);
    }

    function depositAllFor(address _account, address _to, uint[] calldata _amounts, uint _min_mint_amount) public override checkContract returns (uint _mint_amount) {

        require(msg.sender == _account || msg.sender == vaultMaster.bank(address(this)), "!bank && !yourself");
        uint _pool = balance();
        require(totalDepositCap == 0 || _pool <= totalDepositCap, ">totalDepositCap");
        address _want = IMultiVaultController(controller).want();
        IMultiVaultConverter _converter = converters[_want];
        require(address(_converter) != address(0), "!converter");
        uint _length = _amounts.length;
        for (uint8 i = 0; i < _length; i++) {
            uint _inputAmount = _amounts[i];
            if (_inputAmount > 0) {
                inputTokens[i].safeTransferFrom(_account, address(_converter), _inputAmount);
            }
        }
        uint _before = IERC20(_want).balanceOf(address(this));
        _converter.convertAll(_amounts);
        uint _after = IERC20(_want).balanceOf(address(this));
        uint _totalDepositAmount = _after.sub(_before); // additional check for deflationary tokens
        _mint_amount = (_totalDepositAmount > 0) ? _deposit(_to, _pool, _totalDepositAmount, _want) : 0;
        require(_mint_amount >= _min_mint_amount, "slippage");
    }

    function _deposit(address _mintTo, uint _pool, uint _amount, address _want) internal returns (uint _shares) {

        uint _insuranceFee = vaultMaster.insuranceFee();
        if (_insuranceFee > 0) {
            uint _insurance = _amount.mul(_insuranceFee).div(10000);
            _amount = _amount.sub(_insurance);
            insurance = insurance.add(_insurance);
        }

        if (_want != address(basedToken)) {
            _amount = shareConverter.convert_shares_rate(_want, address(basedToken), _amount);
            if (_amount == 0) {
                _amount = basedConverter.convert_rate(_want, address(basedToken), _amount); // try [stables_2_basedWant] if [share_2_share] failed
            }
        }

        if (totalSupply() == 0) {
            _shares = _amount;
        } else {
            _shares = (_amount.mul(totalSupply())).div(_pool);
        }

        if (_shares > 0) {
            earn(_want);
            _mint(_mintTo, _shares);
        }
    }

    function harvest(address reserve, uint amount) external override {

        require(msg.sender == controller, "!controller");
        require(reserve != address(basedToken), "basedToken");
        IERC20(reserve).safeTransfer(controller, amount);
    }

    function harvestStrategy(address _strategy) external override {

        require(msg.sender == governance || msg.sender == vaultMaster.bank(address(this)), "!governance && !bank");
        IMultiVaultController(controller).harvestStrategy(_strategy);
    }

    function harvestWant(address _want) external override {

        require(msg.sender == governance || msg.sender == vaultMaster.bank(address(this)), "!governance && !bank");
        IMultiVaultController(controller).harvestWant(_want);
    }

    function harvestAllStrategies() external override {

        require(msg.sender == governance || msg.sender == vaultMaster.bank(address(this)), "!governance && !bank");
        IMultiVaultController(controller).harvestAllStrategies();
    }

    function withdraw(uint _shares, address _output, uint _min_output_amount) external override returns (uint) {

        return withdrawFor(msg.sender, _shares, _output, _min_output_amount);
    }

    function withdrawFor(address _account, uint _shares, address _output, uint _min_output_amount) public override returns (uint _output_amount) {

        _output_amount = (balance_to_sell().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);

        uint _withdrawalProtectionFee = vaultMaster.withdrawalProtectionFee();
        if (_withdrawalProtectionFee > 0) {
            uint _withdrawalProtection = _output_amount.mul(_withdrawalProtectionFee).div(10000);
            _output_amount = _output_amount.sub(_withdrawalProtection);
        }

        uint b = basedToken.balanceOf(address(this));
        if (b < _output_amount) {
            uint _toWithdraw = _output_amount.sub(b);
            uint _wantBal = IMultiVaultController(controller).wantStrategyBalance(address(basedToken));
            if (_wantBal < _toWithdraw && allowWithdrawFromOtherWant[_output]) {
                address _otherWant = input2Want[_output];
                if (_otherWant != address(0) && _otherWant != address(basedToken)) {
                    IMultiVaultConverter otherConverter = converters[_otherWant];
                    if (address(otherConverter) != address(0)) {
                        uint _toWithdrawOtherWant = shareConverter.convert_shares_rate(address(basedToken), _otherWant, _output_amount);
                        _wantBal = IMultiVaultController(controller).wantStrategyBalance(_otherWant);
                        if (_wantBal >= _toWithdrawOtherWant) {
                            {
                                uint _before = IERC20(_otherWant).balanceOf(address(this));
                                uint _withdrawFee = IMultiVaultController(controller).withdraw(_otherWant, _toWithdrawOtherWant);
                                uint _after = IERC20(_otherWant).balanceOf(address(this));
                                _output_amount = _after.sub(_before);
                                if (_withdrawFee > 0) {
                                    _output_amount = _output_amount.sub(_withdrawFee, "_output_amount < _withdrawFee");
                                }
                            }
                            if (_output != _otherWant) {
                                require(otherConverter.convert_rate(_otherWant, _output, _output_amount) > 0, "rate=0");
                                IERC20(_otherWant).safeTransfer(address(otherConverter), _output_amount);
                                _output_amount = otherConverter.convert(_otherWant, _output, _output_amount);
                            }
                            require(_output_amount >= _min_output_amount, "slippage");
                            IERC20(_output).safeTransfer(_account, _output_amount);
                            return _output_amount;
                        }
                    }
                }
            }
            uint _withdrawFee = IMultiVaultController(controller).withdraw(address(basedToken), _toWithdraw);
            uint _after = basedToken.balanceOf(address(this));
            uint _diff = _after.sub(b);
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
            require(basedConverter.convert_rate(address(basedToken), _output, _output_amount) > 0, "rate=0");
            basedToken.safeTransfer(address(basedConverter), _output_amount);
            uint _outputAmount = basedConverter.convert(address(basedToken), _output, _output_amount);
            require(_outputAmount >= _min_output_amount, "slippage");
            IERC20(_output).safeTransfer(_account, _outputAmount);
        }
    }

    function getPricePerFullShare() public override view returns (uint) {

        return (totalSupply() == 0) ? 1e18 : balance().mul(1e18).div(totalSupply());
    }

    function get_virtual_price() external override view returns (uint) {

        return basedConverter.get_virtual_price().mul(getPricePerFullShare()).div(1e18);
    }

    function governanceRecoverUnsupported(IERC20 _token, uint amount, address to) external {

        require(msg.sender == governance, "!governance");
        require(address(_token) != address(basedToken), "3crv");
        require(address(_token) != address(this), "mvUSD");
        require(wantTokenIndex[address(_token)] == 0, "wantToken");
        _token.safeTransfer(to, amount);
    }
}