

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
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
}

contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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

interface IStableSwap3Pool {
    function get_virtual_price() external view returns (uint);
    function balances(uint) external view returns (uint);
    function calc_token_amount(uint[3] calldata amounts, bool deposit) external view returns (uint);
    function calc_withdraw_one_coin(uint _token_amount, int128 i) external view returns (uint);
    function get_dy(int128 i, int128 j, uint dx) external view returns (uint);
    function add_liquidity(uint[3] calldata amounts, uint min_mint_amount) external;
    function remove_liquidity_one_coin(uint _token_amount, int128 i, uint min_amount) external;
    function exchange(int128 i, int128 j, uint dx, uint min_dy) external;
}

interface IDepositBUSD {
    function calc_withdraw_one_coin(uint _token_amount, int128 i) external view returns (uint);
    function add_liquidity(uint[4] calldata amounts, uint min_mint_amount) external;
    function remove_liquidity_one_coin(uint _token_amount, int128 i, uint min_amount) external;
}

interface IStableSwapBUSD {
    function get_virtual_price() external view returns (uint);
    function calc_token_amount(uint[4] calldata amounts, bool deposit) external view returns (uint);
    function get_dy_underlying(int128 i, int128 j, uint dx) external view returns (uint dy);
    function get_dx_underlying(int128 i, int128 j, uint dy) external view returns (uint dx);
    function exchange_underlying(int128 i, int128 j, uint dx, uint min_dy) external;
}

interface IStableSwapHUSD {
    function get_virtual_price() external view returns (uint);
    function calc_token_amount(uint[2] calldata amounts, bool deposit) external view returns (uint);
    function get_dy(int128 i, int128 j, uint dx) external view returns (uint dy);
    function get_dy_underlying(int128 i, int128 j, uint dx) external view returns (uint dy);
    function get_dx_underlying(int128 i, int128 j, uint dy) external view returns (uint dx);
    function exchange_underlying(int128 i, int128 j, uint dx, uint min_dy) external;
    function exchange(int128 i, int128 j, uint dx, uint min_dy) external;
    function calc_withdraw_one_coin(uint amount, int128 i) external view returns (uint);
    function remove_liquidity_one_coin(uint amount, int128 i, uint minAmount) external returns (uint);
    function add_liquidity(uint[2] calldata amounts, uint min_mint_amount) external returns (uint);
}

interface IStableSwapSUSD {
    function get_virtual_price() external view returns (uint);
    function calc_token_amount(uint[4] calldata amounts, bool deposit) external view returns (uint);
    function get_dy_underlying(int128 i, int128 j, uint dx) external view returns (uint dy);
    function get_dx_underlying(int128 i, int128 j, uint dy) external view returns (uint dx);
    function exchange_underlying(int128 i, int128 j, uint dx, uint min_dy) external;
}

interface yTokenInterface {
    function getPricePerFullShare() external view returns (uint);
}

contract StableSwapBusdConverter is IMultiVaultConverter {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20[4] public bpoolTokens; // DAI, USDC, USDT, BUSD

    IERC20 public tokenBUSD; // BUSD
    IERC20 public tokenBCrv; // BCrv (yDAI+yUSDC+yUSDT+yBUSD)

    IERC20 public token3Crv; // 3Crv

    IERC20 public tokenSUSD; // sUSD
    IERC20 public tokenSCrv; // sCrv (DAI/USDC/USDT/sUSD)

    IERC20 public tokenHUSD; // hUSD
    IERC20 public tokenHCrv; // hCrv (HUSD/3Crv)

    address public governance;

    IStableSwap3Pool public stableSwap3Pool;
    IDepositBUSD public depositBUSD;
    IStableSwapBUSD public stableSwapBUSD;

    IStableSwapSUSD public stableSwapSUSD;

    IStableSwapHUSD public stableSwapHUSD;

    yTokenInterface[4] poolBUSDyTokens;

    IValueVaultMaster public vaultMaster;

    uint public defaultSlippage = 1; // very small 0.01%

    constructor (IERC20 _tokenDAI, IERC20 _tokenUSDC, IERC20 _tokenUSDT, IERC20 _token3Crv,
        IERC20[] memory _tokens, IERC20[] memory _tokenCrvs,
        address[] memory _stableSwapUSD,
        IStableSwap3Pool _stableSwap3Pool,
        IDepositBUSD _depositBUSD,
        yTokenInterface[4] memory _yTokens,
        IValueVaultMaster _vaultMaster) public {
        bpoolTokens[0] = _tokenDAI;
        bpoolTokens[1] = _tokenUSDC;
        bpoolTokens[2] = _tokenUSDT;
        bpoolTokens[3] = _tokens[0];
        token3Crv = _token3Crv;
        tokenBCrv = _tokenCrvs[0];
        tokenSUSD = _tokens[1];
        tokenSCrv = _tokenCrvs[1];
        tokenHUSD = _tokens[2];
        tokenHCrv = _tokenCrvs[2];
        stableSwap3Pool = _stableSwap3Pool;
        stableSwapBUSD = IStableSwapBUSD(_stableSwapUSD[0]);
        stableSwapSUSD = IStableSwapSUSD(_stableSwapUSD[1]);
        stableSwapHUSD = IStableSwapHUSD(_stableSwapUSD[2]);
        depositBUSD = _depositBUSD;
        poolBUSDyTokens = _yTokens;

        bpoolTokens[0].safeApprove(address(stableSwap3Pool), type(uint256).max);
        bpoolTokens[1].safeApprove(address(stableSwap3Pool), type(uint256).max);
        bpoolTokens[2].safeApprove(address(stableSwap3Pool), type(uint256).max);
        token3Crv.safeApprove(address(stableSwap3Pool), type(uint256).max);

        bpoolTokens[0].safeApprove(address(stableSwapBUSD), type(uint256).max);
        bpoolTokens[1].safeApprove(address(stableSwapBUSD), type(uint256).max);
        bpoolTokens[2].safeApprove(address(stableSwapBUSD), type(uint256).max);
        bpoolTokens[3].safeApprove(address(stableSwapBUSD), type(uint256).max);
        tokenBCrv.safeApprove(address(stableSwapBUSD), type(uint256).max);

        bpoolTokens[0].safeApprove(address(depositBUSD), type(uint256).max);
        bpoolTokens[1].safeApprove(address(depositBUSD), type(uint256).max);
        bpoolTokens[2].safeApprove(address(depositBUSD), type(uint256).max);
        bpoolTokens[3].safeApprove(address(depositBUSD), type(uint256).max);
        tokenBCrv.safeApprove(address(depositBUSD), type(uint256).max);

        bpoolTokens[0].safeApprove(address(stableSwapSUSD), type(uint256).max);
        bpoolTokens[1].safeApprove(address(stableSwapSUSD), type(uint256).max);
        bpoolTokens[2].safeApprove(address(stableSwapSUSD), type(uint256).max);
        tokenSUSD.safeApprove(address(stableSwapSUSD), type(uint256).max);
        tokenSCrv.safeApprove(address(stableSwapSUSD), type(uint256).max);

        token3Crv.safeApprove(address(stableSwapHUSD), type(uint256).max);
        tokenHUSD.safeApprove(address(stableSwapHUSD), type(uint256).max);
        tokenHCrv.safeApprove(address(stableSwapHUSD), type(uint256).max);

        vaultMaster = _vaultMaster;
        governance = msg.sender;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setVaultMaster(IValueVaultMaster _vaultMaster) external {
        require(msg.sender == governance, "!governance");
        vaultMaster = _vaultMaster;
    }

    function approveForSpender(IERC20 _token, address _spender, uint _amount) external {
        require(msg.sender == governance, "!governance");
        _token.safeApprove(_spender, _amount);
    }

    function setDefaultSlippage(uint _defaultSlippage) external {
        require(msg.sender == governance, "!governance");
        require(_defaultSlippage <= 100, "_defaultSlippage>1%");
        defaultSlippage = _defaultSlippage;
    }

    function token() external override returns (address) {
        return address(tokenBCrv);
    }

    function get_virtual_price() external override view returns (uint) {
        return stableSwapBUSD.get_virtual_price();
    }

    function convert_rate(address _input, address _output, uint _inputAmount) public override view returns (uint _outputAmount) {
        if (_inputAmount == 0) return 0;
        if (_output == address(tokenBCrv)) { // convert to BCrv
            uint[4] memory _amounts;
            for (uint8 i = 0; i < 4; i++) {
                if (_input == address(bpoolTokens[i])) {
                    _amounts[i] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[i], _inputAmount);
                    _outputAmount = stableSwapBUSD.calc_token_amount(_amounts, true);
                    return _outputAmount.mul(10000 - defaultSlippage).div(10000);
                }
            }
            if (_input == address(tokenSUSD)) {
                uint dai = stableSwapSUSD.get_dy_underlying(int128(3), int128(0), _inputAmount); // convert to DAI
                _amounts[0] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[0], dai); // DAI -> yDAI
                _outputAmount = stableSwapBUSD.calc_token_amount(_amounts, true); // DAI -> BCrv
            }
            if (_input == address(tokenHUSD)) {
                uint _3crvAmount = stableSwapHUSD.get_dy(int128(0), int128(1), _inputAmount); // HUSD -> 3Crv
                uint dai = stableSwap3Pool.calc_withdraw_one_coin(_3crvAmount, 0); // 3Crv -> DAI
                _amounts[0] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[0], dai); // DAI -> yDAI
                _outputAmount = stableSwapBUSD.calc_token_amount(_amounts, true); // DAI -> BCrv
            }
            if (_input == address(token3Crv)) {
                uint dai = stableSwap3Pool.calc_withdraw_one_coin(_inputAmount, 0); // 3Crv -> DAI
                _amounts[0] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[0], dai); // DAI -> yDAI
                _outputAmount = stableSwapBUSD.calc_token_amount(_amounts, true); // DAI -> BCrv
            }
        } else if (_input == address(tokenBCrv)) { // convert from BCrv
            for (uint8 i = 0; i < 4; i++) {
                if (_output == address(bpoolTokens[i])) {
                    _outputAmount = depositBUSD.calc_withdraw_one_coin(_inputAmount, i);
                    return _outputAmount.mul(10000 - defaultSlippage).div(10000);
                }
            }
            if (_output == address(tokenSUSD)) {
                uint _daiAmount = depositBUSD.calc_withdraw_one_coin(_inputAmount, 0); // BCrv -> DAI
                _outputAmount = stableSwapSUSD.get_dy_underlying(int128(0), int128(3), _daiAmount); // DAI -> SUSD
            }
            if (_output == address(tokenHUSD)) {
                uint _3crvAmount = _convert_bcrv_to_3crv_rate(_inputAmount); // BCrv -> DAI -> 3Crv
                _outputAmount = stableSwapHUSD.get_dy(int128(1), int128(0), _3crvAmount); // 3Crv -> HUSD
            }
        }
        if (_outputAmount > 0) {
            uint _slippage = _outputAmount.mul(vaultMaster.convertSlippage(_input, _output)).div(10000);
            _outputAmount = _outputAmount.sub(_slippage);
        }
    }

    function _convert_bcrv_to_3crv_rate(uint _bcrvAmount) internal view returns (uint _3crv) {
        uint[3] memory _amounts;
        _amounts[0] = depositBUSD.calc_withdraw_one_coin(_bcrvAmount, 0); // BCrv -> DAI
        _3crv = stableSwap3Pool.calc_token_amount(_amounts, true); // DAI -> 3Crv
    }

    function calc_token_amount_deposit(uint[] calldata _amounts) external override view returns (uint _shareAmount) {
        uint[4] memory _bpoolAmounts;
        _bpoolAmounts[0] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[0], _amounts[0]);
        _bpoolAmounts[1] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[1], _amounts[1]);
        _bpoolAmounts[2] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[2], _amounts[2]);
        _bpoolAmounts[3] = _convert_underlying_to_ytoken_rate(poolBUSDyTokens[3], _amounts[4]);
        uint _bpoolToBcrv = stableSwapBUSD.calc_token_amount(_bpoolAmounts, true);
        uint _3crvToBCrv = convert_rate(address(token3Crv), address(tokenBCrv), _amounts[3]);
        uint _susdToBCrv = convert_rate(address(tokenSUSD), address(tokenBCrv), _amounts[5]);
        uint _husdToBCrv = convert_rate(address(tokenHUSD), address(tokenBCrv), _amounts[6]);
        return _shareAmount.add(_bpoolToBcrv).add(_3crvToBCrv).add(_susdToBCrv).add(_husdToBCrv);
    }

    function calc_token_amount_withdraw(uint _shares, address _output) external override view returns (uint _outputAmount) {
        for (uint8 i = 0; i < 4; i++) {
            if (_output == address(bpoolTokens[i])) {
                _outputAmount = depositBUSD.calc_withdraw_one_coin(_shares, i);
                return _outputAmount.mul(10000 - defaultSlippage).div(10000);
            }
        }
        if (_output == address(token3Crv)) {
            _outputAmount = _convert_bcrv_to_3crv_rate(_shares); // BCrv -> DAI -> 3Crv
        } else if (_output == address(tokenSUSD)) {
            uint _daiAmount = depositBUSD.calc_withdraw_one_coin(_shares, 0); // BCrv -> DAI
            _outputAmount = stableSwapSUSD.get_dy_underlying(int128(0), int128(3), _daiAmount); // DAI -> SUSD
        } else if (_output == address(tokenHUSD)) {
            uint _3crvAmount = _convert_bcrv_to_3crv_rate(_shares); // BCrv -> DAI -> 3Crv
            _outputAmount = stableSwapHUSD.get_dy(int128(1), int128(0), _3crvAmount); // 3Crv -> HUSD
        }
        if (_outputAmount > 0) {
            uint _slippage = _outputAmount.mul(vaultMaster.slippage(_output)).div(10000);
            _outputAmount = _outputAmount.sub(_slippage);
        }
    }

    function convert(address _input, address _output, uint _inputAmount) external override returns (uint _outputAmount) {
        require(vaultMaster.isVault(msg.sender) || vaultMaster.isController(msg.sender) || msg.sender == governance, "!(governance||vault||controller)");
        if (_output == address(tokenBCrv)) { // convert to BCrv
            uint[4] memory amounts;
            for (uint8 i = 0; i < 4; i++) {
                if (_input == address(bpoolTokens[i])) {
                    amounts[i] = _inputAmount;
                    uint _before = tokenBCrv.balanceOf(address(this));
                    depositBUSD.add_liquidity(amounts, 1);
                    uint _after = tokenBCrv.balanceOf(address(this));
                    _outputAmount = _after.sub(_before);
                    tokenBCrv.safeTransfer(msg.sender, _outputAmount);
                    return _outputAmount;
                }
            }
            if (_input == address(token3Crv)) {
                _outputAmount = _convert_3crv_to_shares(_inputAmount);
                tokenBCrv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_input == address(tokenSUSD)) {
                _outputAmount = _convert_susd_to_shares(_inputAmount);
                tokenBCrv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_input == address(tokenHUSD)) {
                _outputAmount = _convert_husd_to_shares(_inputAmount);
                tokenBCrv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
        } else if (_input == address(tokenBCrv)) { // convert from BCrv
            for (uint8 i = 0; i < 4; i++) {
                if (_output == address(bpoolTokens[i])) {
                    uint _before = bpoolTokens[i].balanceOf(address(this));
                    depositBUSD.remove_liquidity_one_coin(_inputAmount, i, 1);
                    uint _after = bpoolTokens[i].balanceOf(address(this));
                    _outputAmount = _after.sub(_before);
                    bpoolTokens[i].safeTransfer(msg.sender, _outputAmount);
                    return _outputAmount;
                }
            }
            if (_output == address(token3Crv)) {
                uint[3] memory amounts;
                uint _before = bpoolTokens[0].balanceOf(address(this));
                depositBUSD.remove_liquidity_one_coin(_inputAmount, 0, 1);
                uint _after = bpoolTokens[0].balanceOf(address(this));
                amounts[0] = _after.sub(_before);

                _before = token3Crv.balanceOf(address(this));
                stableSwap3Pool.add_liquidity(amounts, 1);
                _after = token3Crv.balanceOf(address(this));
                _outputAmount = _after.sub(_before);

                token3Crv.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_output == address(tokenSUSD)) {
                uint _before = bpoolTokens[0].balanceOf(address(this));
                depositBUSD.remove_liquidity_one_coin(_inputAmount, 0, 1);
                uint _after = bpoolTokens[0].balanceOf(address(this));
                _outputAmount = _after.sub(_before);

                _before = tokenSUSD.balanceOf(address(this));
                stableSwapSUSD.exchange_underlying(int128(0), int128(3), _outputAmount, 1);
                _after = tokenSUSD.balanceOf(address(this));
                _outputAmount = _after.sub(_before);

                tokenSUSD.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
            if (_output == address(tokenHUSD)) {
                _outputAmount = _convert_shares_to_husd(_inputAmount);
                tokenHUSD.safeTransfer(msg.sender, _outputAmount);
                return _outputAmount;
            }
        }
        return 0;
    }

    function _convert_underlying_to_ytoken_rate(yTokenInterface yToken, uint _inputAmount) internal view returns (uint _outputAmount) {
        return _inputAmount.mul(1e18).div(yToken.getPricePerFullShare());
    }

    function _convert_3crv_to_shares(uint _3crv) internal returns (uint _shares) {
        uint[4] memory amounts;
        uint _before = bpoolTokens[0].balanceOf(address(this));
        stableSwap3Pool.remove_liquidity_one_coin(_3crv, 0, 1);
        uint _after = bpoolTokens[0].balanceOf(address(this));
        amounts[0] = _after.sub(_before);

        _before = tokenBCrv.balanceOf(address(this));
        depositBUSD.add_liquidity(amounts, 1);
        _after = tokenBCrv.balanceOf(address(this));

        _shares = _after.sub(_before);
    }

    function _convert_susd_to_shares(uint _amount) internal returns (uint _shares) {
        uint[4] memory amounts;
        uint _before = bpoolTokens[0].balanceOf(address(this));
        stableSwapSUSD.exchange_underlying(int128(3), int128(0), _amount, 1);
        uint _after = bpoolTokens[0].balanceOf(address(this));
        amounts[0] = _after.sub(_before);

        _before = tokenBCrv.balanceOf(address(this));
        depositBUSD.add_liquidity(amounts, 1);
        _after = tokenBCrv.balanceOf(address(this));

        _shares = _after.sub(_before);
    }

    function _convert_husd_to_shares(uint _amount) internal returns (uint _shares) {
        uint _before = token3Crv.balanceOf(address(this));
        stableSwapHUSD.exchange(int128(0), int128(1), _amount, 1);
        uint _after = token3Crv.balanceOf(address(this));
        _amount = _after.sub(_before);

        uint[4] memory amounts;
        _before = bpoolTokens[0].balanceOf(address(this));
        stableSwap3Pool.remove_liquidity_one_coin(_amount, 0, 1);
        _after = bpoolTokens[0].balanceOf(address(this));
        amounts[0] = _after.sub(_before);

        _before = tokenBCrv.balanceOf(address(this));
        depositBUSD.add_liquidity(amounts, 1);
        _after = tokenBCrv.balanceOf(address(this));

        _shares = _after.sub(_before);
    }

    function _convert_shares_to_husd(uint _amount) internal returns (uint _husd) {
        uint[3] memory amounts;
        uint _before = bpoolTokens[0].balanceOf(address(this));
        depositBUSD.remove_liquidity_one_coin(_amount, 0, 1);
        uint _after = bpoolTokens[0].balanceOf(address(this));
        amounts[0] = _after.sub(_before);

        _before = token3Crv.balanceOf(address(this));
        stableSwap3Pool.add_liquidity(amounts, 1);
        _after = token3Crv.balanceOf(address(this));
        _amount = _after.sub(_before);

        _before = tokenHUSD.balanceOf(address(this));
        stableSwapHUSD.exchange(int128(1), int128(0), _amount, 1);
        _after = tokenHUSD.balanceOf(address(this));
        _husd = _after.sub(_before);
    }

    function convertAll(uint[] calldata _amounts) external override returns (uint _outputAmount) {
        require(vaultMaster.isVault(msg.sender) || vaultMaster.isController(msg.sender) || msg.sender == governance, "!(governance||vault||controller)");
        uint _before = tokenBCrv.balanceOf(address(this));
        if (_amounts[0] > 0 || _amounts[1] > 0 || _amounts[2] > 0 || _amounts[4] == 0) {
            uint[4] memory _bpoolAmounts;
            _bpoolAmounts[0] = _amounts[0];
            _bpoolAmounts[1] = _amounts[1];
            _bpoolAmounts[2] = _amounts[2];
            _bpoolAmounts[3] = _amounts[4];
            depositBUSD.add_liquidity(_bpoolAmounts, 1);
        }
        if (_amounts[3] > 0) { // 3Crv
            _convert_3crv_to_shares(_amounts[3]);
        }
        if (_amounts[5] > 0) { // sUSD
            _convert_susd_to_shares(_amounts[5]);
        }
        if (_amounts[6] > 0) { // hUSD
            _convert_husd_to_shares(_amounts[6]);
        }
        uint _after = tokenBCrv.balanceOf(address(this));
        _outputAmount = _after.sub(_before);
        tokenBCrv.safeTransfer(msg.sender, _outputAmount);
        return _outputAmount;
    }

    function governanceRecoverUnsupported(IERC20 _token, uint _amount, address _to) external {
        require(msg.sender == governance, "!governance");
        _token.transfer(_to, _amount);
    }
}