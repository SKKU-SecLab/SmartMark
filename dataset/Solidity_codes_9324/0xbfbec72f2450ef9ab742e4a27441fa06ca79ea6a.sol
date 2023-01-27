

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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

interface IVaultManager {
    function yax() external view returns (address);
    function vaults(address) external view returns (bool);
    function controllers(address) external view returns (bool);
    function strategies(address) external view returns (bool);
    function stakingPool() external view returns (address);
    function profitSharer() external view returns (address);
    function treasuryWallet() external view returns (address);
    function performanceReward() external view returns (address);
    function stakingPoolShareFee() external view returns (uint);
    function gasFee() external view returns (uint);
    function insuranceFee() external view returns (uint);
    function withdrawalProtectionFee() external view returns (uint);
}

interface IController {
    function vaults(address) external view returns (address);
    function want(address) external view returns (address);
    function balanceOf(address) external view returns (uint);
    function withdraw(address, uint) external;
    function earn(address, uint) external;
    function withdrawFee(address, uint) external view returns (uint); // pJar: 0.5% (50/10000)
    function investEnabled() external view returns (bool);
}

interface IConverter {
    function token() external returns (address _share);
    function convert(address _input, address _output, uint _inputAmount) external returns (uint _outputAmount);
    function convert_rate(address _input, address _output, uint _inputAmount) external view returns (uint _outputAmount);
    function convert_stables(uint[3] calldata amounts) external returns (uint _shareAmount); // 0: DAI, 1: USDC, 2: USDT
    function get_dy(int128 i, int128 j, uint dx) external view returns (uint);
    function exchange(int128 i, int128 j, uint dx, uint min_dy) external returns (uint dy);
    function calc_token_amount(uint[3] calldata amounts, bool deposit) external view returns (uint _shareAmount);
    function calc_token_amount_withdraw(uint _shares, address _output) external view returns (uint _outputAmount);
}

interface IMetaVault {
    function balance() external view returns (uint);
    function setController(address _controller) external;
    function claimInsurance() external;
    function token() external view returns (address);
    function available() external view returns (uint);
    function withdrawFee(uint _amount) external view returns (uint);
    function earn() external;
    function calc_token_amount_deposit(uint[3] calldata amounts) external view returns (uint);
    function calc_token_amount_withdraw(uint _shares, address _output) external view returns (uint);
    function convert_rate(address _input, uint _amount) external view returns (uint);
    function deposit(uint _amount, address _input, uint _min_mint_amount, bool _isStake) external;
    function harvest(address reserve, uint amount) external;
    function withdraw(uint _shares, address _output) external;
    function want() external view returns (address);
    function getPricePerFullShare() external view returns (uint);
}

contract yAxisMetaVault is ERC20, IMetaVault {
    using Address for address;
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20[4] public inputTokens; // DAI, USDC, USDT, 3Crv

    IERC20 public token3CRV;
    IERC20 public tokenYAX;

    uint public min = 9500;
    uint public constant max = 10000;

    uint public earnLowerlimit = 5 ether; // minimum to invest is 5 3CRV
    uint public totalDepositCap = 10000000 ether; // initial cap set at 10 million dollar

    address public governance;
    address public controller;
    uint public insurance;
    IVaultManager public vaultManager;
    IConverter public converter;

    bool public acceptContractDepositor = false; // dont accept contract at beginning

    struct UserInfo {
        uint amount;
        uint yaxRewardDebt;
        uint accEarned;
    }

    uint public lastRewardBlock;
    uint public accYaxPerShare;

    uint public yaxPerBlock;

    mapping(address => UserInfo) public userInfo;

    address public treasuryWallet = 0x362Db1c17db4C79B51Fe6aD2d73165b1fe9BaB4a;

    uint public constant BLOCKS_PER_WEEK = 46500;

    uint[5] public epochEndBlocks;

    uint[6] public epochRewardMultiplers = [86000, 64000, 43000, 21000, 10000, 1];

    event Deposit(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);
    event RewardPaid(address indexed user, uint reward);

    constructor (IERC20 _tokenDAI, IERC20 _tokenUSDC, IERC20 _tokenUSDT, IERC20 _token3CRV, IERC20 _tokenYAX,
        uint _yaxPerBlock, uint _startBlock) public ERC20("yAxis.io:MetaVault:3CRV", "MVLT") {
        inputTokens[0] = _tokenDAI;
        inputTokens[1] = _tokenUSDC;
        inputTokens[2] = _tokenUSDT;
        inputTokens[3] = _token3CRV;
        token3CRV = _token3CRV;
        tokenYAX = _tokenYAX;
        yaxPerBlock = _yaxPerBlock; // supposed to be 0.000001 YAX (1000000000000 = 1e12 wei)
        lastRewardBlock = (_startBlock > block.number) ? _startBlock : block.number; // supposed to be 11,163,000 (Sat Oct 31 2020 06:30:00 GMT+0)
        epochEndBlocks[0] = lastRewardBlock + BLOCKS_PER_WEEK * 2; // weeks 1-2
        epochEndBlocks[1] = epochEndBlocks[0] + BLOCKS_PER_WEEK * 2; // weeks 3-4
        epochEndBlocks[2] = epochEndBlocks[1] + BLOCKS_PER_WEEK * 4; // month 2
        epochEndBlocks[3] = epochEndBlocks[2] + BLOCKS_PER_WEEK * 8; // month 3-4
        epochEndBlocks[4] = epochEndBlocks[3] + BLOCKS_PER_WEEK * 8; // month 5-6
        governance = msg.sender;
    }

    modifier checkContract() {
        if (!acceptContractDepositor) {
            require(!address(msg.sender).isContract() && msg.sender == tx.origin, "Sorry we do not accept contract!");
        }
        _;
    }

    function balance() public override view returns (uint) {
        uint bal = token3CRV.balanceOf(address(this));
        if (controller != address(0)) bal = bal.add(IController(controller).balanceOf(address(token3CRV)));
        return bal.sub(insurance);
    }

    function setMin(uint _min) external {
        require(msg.sender == governance, "!governance");
        min = _min;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setController(address _controller) public override {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }

    function setConverter(IConverter _converter) public {
        require(msg.sender == governance, "!governance");
        require(_converter.token() == address(token3CRV), "!token3CRV");
        converter = _converter;
    }

    function setVaultManager(IVaultManager _vaultManager) public {
        require(msg.sender == governance, "!governance");
        vaultManager = _vaultManager;
    }

    function setEarnLowerlimit(uint _earnLowerlimit) public {
        require(msg.sender == governance, "!governance");
        earnLowerlimit = _earnLowerlimit;
    }

    function setTotalDepositCap(uint _totalDepositCap) public {
        require(msg.sender == governance, "!governance");
        totalDepositCap = _totalDepositCap;
    }

    function setAcceptContractDepositor(bool _acceptContractDepositor) public {
        require(msg.sender == governance, "!governance");
        acceptContractDepositor = _acceptContractDepositor;
    }

    function setYaxPerBlock(uint _yaxPerBlock) public {
        require(msg.sender == governance, "!governance");
        updateReward();
        yaxPerBlock = _yaxPerBlock;
    }

    function setEpochEndBlock(uint8 _index, uint256 _epochEndBlock) public {
        require(msg.sender == governance, "!governance");
        require(_index < 5, "_index out of range");
        require(_epochEndBlock > block.number, "Too late to update");
        require(epochEndBlocks[_index] > block.number, "Too late to update");
        epochEndBlocks[_index] = _epochEndBlock;
    }

    function setEpochRewardMultipler(uint8 _index, uint256 _epochRewardMultipler) public {
        require(msg.sender == governance, "!governance");
        require(_index > 0 && _index < 6, "Index out of range");
        require(epochEndBlocks[_index - 1] > block.number, "Too late to update");
        epochRewardMultiplers[_index] = _epochRewardMultipler;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        for (uint8 epochId = 5; epochId >= 1; --epochId) {
            if (_to >= epochEndBlocks[epochId - 1]) {
                if (_from >= epochEndBlocks[epochId - 1]) return _to.sub(_from).mul(epochRewardMultiplers[epochId]);
                uint256 multiplier = _to.sub(epochEndBlocks[epochId - 1]).mul(epochRewardMultiplers[epochId]);
                if (epochId == 1) return multiplier.add(epochEndBlocks[0].sub(_from).mul(epochRewardMultiplers[0]));
                for (epochId = epochId - 1; epochId >= 1; --epochId) {
                    if (_from >= epochEndBlocks[epochId - 1]) return multiplier.add(epochEndBlocks[epochId].sub(_from).mul(epochRewardMultiplers[epochId]));
                    multiplier = multiplier.add(epochEndBlocks[epochId].sub(epochEndBlocks[epochId - 1]).mul(epochRewardMultiplers[epochId]));
                }
                return multiplier.add(epochEndBlocks[0].sub(_from).mul(epochRewardMultiplers[0]));
            }
        }
        return _to.sub(_from).mul(epochRewardMultiplers[0]);
    }

    function setTreasuryWallet(address _treasuryWallet) public {
        require(msg.sender == governance, "!governance");
        treasuryWallet = _treasuryWallet;
    }

    function claimInsurance() external override {
        if (msg.sender != controller) {
            require(msg.sender == governance, "!governance");
            token3CRV.safeTransfer(treasuryWallet, insurance);
        }
        insurance = 0;
    }

    function token() public override view returns (address) {
        return address(token3CRV);
    }

    function available() public override view returns (uint) {
        return token3CRV.balanceOf(address(this)).mul(min).div(max);
    }

    function withdrawFee(uint _amount) public override view returns (uint) {
        return (controller == address(0)) ? 0 : IController(controller).withdrawFee(address(token3CRV), _amount);
    }

    function earn() public override {
        if (controller != address(0)) {
            IController _contrl = IController(controller);
            if (_contrl.investEnabled()) {
                uint _bal = available();
                token3CRV.safeTransfer(controller, _bal);
                _contrl.earn(address(token3CRV), _bal);
            }
        }
    }

    function calc_token_amount_deposit(uint[3] calldata amounts) external override view returns (uint) {
        return converter.calc_token_amount(amounts, true);
    }

    function calc_token_amount_withdraw(uint _shares, address _output) external override view returns (uint) {
        uint _withdrawFee = withdrawFee(_shares);
        if (_withdrawFee > 0) {
            _shares = _shares.mul(10000 - _withdrawFee).div(10000);
        }
        uint r = (balance().mul(_shares)).div(totalSupply());
        if (_output == address(token3CRV)) {
            return r;
        }
        return converter.calc_token_amount_withdraw(r, _output);
    }

    function convert_rate(address _input, uint _amount) external override view returns (uint) {
        return converter.convert_rate(_input, address(token3CRV), _amount);
    }

    function deposit(uint _amount, address _input, uint _min_mint_amount, bool _isStake) external override checkContract {
        require(_amount > 0, "!_amount");
        uint _pool = balance();
        uint _before = token3CRV.balanceOf(address(this));
        if (_input == address(token3CRV)) {
            token3CRV.safeTransferFrom(msg.sender, address(this), _amount);
        } else if (converter.convert_rate(_input, address(token3CRV), _amount) > 0) {
            IERC20(_input).safeTransferFrom(msg.sender, address(converter), _amount);
            converter.convert(_input, address(token3CRV), _amount);
        }
        uint _after = token3CRV.balanceOf(address(this));
        require(totalDepositCap == 0 || _after <= totalDepositCap, ">totalDepositCap");
        _amount = _after.sub(_before); // Additional check for deflationary tokens
        require(_amount >= _min_mint_amount, "slippage");
        if (_amount > 0) {
            if (!_isStake) {
                _deposit(msg.sender, _pool, _amount);
            } else {
                uint _shares = _deposit(address(this), _pool, _amount);
                _stakeShares(_shares);
            }
        }
    }

    function depositAll(uint[4] calldata _amounts, uint _min_mint_amount, bool _isStake) external checkContract {
        uint _pool = balance();
        uint _before = token3CRV.balanceOf(address(this));
        bool hasStables = false;
        for (uint8 i = 0; i < 4; i++) {
            uint _inputAmount = _amounts[i];
            if (_inputAmount > 0) {
                if (i == 3) {
                    inputTokens[i].safeTransferFrom(msg.sender, address(this), _inputAmount);
                } else if (converter.convert_rate(address(inputTokens[i]), address(token3CRV), _inputAmount) > 0) {
                    inputTokens[i].safeTransferFrom(msg.sender, address(converter), _inputAmount);
                    hasStables = true;
                }
            }
        }
        if (hasStables) {
            uint[3] memory _stablesAmounts;
            _stablesAmounts[0] = _amounts[0];
            _stablesAmounts[1] = _amounts[1];
            _stablesAmounts[2] = _amounts[2];
            converter.convert_stables(_stablesAmounts);
        }
        uint _after = token3CRV.balanceOf(address(this));
        require(totalDepositCap == 0 || _after <= totalDepositCap, ">totalDepositCap");
        uint _totalDepositAmount = _after.sub(_before); // Additional check for deflationary tokens
        require(_totalDepositAmount >= _min_mint_amount, "slippage");
        if (_totalDepositAmount > 0) {
            if (!_isStake) {
                _deposit(msg.sender, _pool, _totalDepositAmount);
            } else {
                uint _shares = _deposit(address(this), _pool, _totalDepositAmount);
                _stakeShares(_shares);
            }
        }
    }

    function stakeShares(uint _shares) external {
        uint _before = balanceOf(address(this));
        IERC20(address(this)).transferFrom(msg.sender, address(this), _shares);
        uint _after = balanceOf(address(this));
        _shares = _after.sub(_before);
        _stakeShares(_shares);
    }

    function _deposit(address _mintTo, uint _pool, uint _amount) internal returns (uint _shares) {
        if (address(vaultManager) != address(0)) {
            uint _insuranceFee = vaultManager.insuranceFee();
            if (_insuranceFee > 0) {
                uint _insurance = _amount.mul(_insuranceFee).div(10000);
                _amount = _amount.sub(_insurance);
                insurance = insurance.add(_insurance);
            }
        }

        if (totalSupply() == 0) {
            _shares = _amount;
        } else {
            _shares = (_amount.mul(totalSupply())).div(_pool);
        }
        if (_shares > 0) {
            if (token3CRV.balanceOf(address(this)) > earnLowerlimit) {
                earn();
            }
            _mint(_mintTo, _shares);
        }
    }

    function _stakeShares(uint _shares) internal {
        UserInfo storage user = userInfo[msg.sender];
        updateReward();
        _getReward();
        user.amount = user.amount.add(_shares);
        user.yaxRewardDebt = user.amount.mul(accYaxPerShare).div(1e12);
        emit Deposit(msg.sender, _shares);
    }

    function pendingYax(address _account) public view returns (uint _pending) {
        UserInfo storage user = userInfo[_account];
        uint _accYaxPerShare = accYaxPerShare;
        uint lpSupply = balanceOf(address(this));
        if (block.number > lastRewardBlock && lpSupply != 0) {
            uint256 _multiplier = getMultiplier(lastRewardBlock, block.number);
            _accYaxPerShare = accYaxPerShare.add(_multiplier.mul(yaxPerBlock).mul(1e12).div(lpSupply));
        }
        _pending = user.amount.mul(_accYaxPerShare).div(1e12).sub(user.yaxRewardDebt);
    }

    function updateReward() public {
        if (block.number <= lastRewardBlock) {
            return;
        }
        uint lpSupply = balanceOf(address(this));
        if (lpSupply == 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 _multiplier = getMultiplier(lastRewardBlock, block.number);
        accYaxPerShare = accYaxPerShare.add(_multiplier.mul(yaxPerBlock).mul(1e12).div(lpSupply));
        lastRewardBlock = block.number;
    }

    function _getReward() internal {
        UserInfo storage user = userInfo[msg.sender];
        uint _pendingYax = user.amount.mul(accYaxPerShare).div(1e12).sub(user.yaxRewardDebt);
        if (_pendingYax > 0) {
            user.accEarned = user.accEarned.add(_pendingYax);
            safeYaxTransfer(msg.sender, _pendingYax);
            emit RewardPaid(msg.sender, _pendingYax);
        }
    }

    function withdrawAll(address _output) external {
        unstake(userInfo[msg.sender].amount);
        withdraw(balanceOf(msg.sender), _output);
    }

    function harvest(address reserve, uint amount) external override {
        require(msg.sender == controller, "!controller");
        require(reserve != address(token3CRV), "token3CRV");
        IERC20(reserve).safeTransfer(controller, amount);
    }

    function unstake(uint _amount) public {
        updateReward();
        _getReward();
        UserInfo storage user = userInfo[msg.sender];
        if (_amount > 0) {
            require(user.amount >= _amount, "stakedBal < _amount");
            user.amount = user.amount.sub(_amount);
            IERC20(address(this)).transfer(msg.sender, _amount);
        }
        user.yaxRewardDebt = user.amount.mul(accYaxPerShare).div(1e12);
        emit Withdraw(msg.sender, _amount);
    }

    function withdraw(uint _shares, address _output) public override {
        uint _userBal = balanceOf(msg.sender);
        if (_shares > _userBal) {
            uint _need = _shares.sub(_userBal);
            require(_need <= userInfo[msg.sender].amount, "_userBal+staked < _shares");
            unstake(_need);
        }
        uint r = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);

        if (address(vaultManager) != address(0)) {
            uint _withdrawalProtectionFee = vaultManager.withdrawalProtectionFee();
            if (_withdrawalProtectionFee > 0) {
                uint _withdrawalProtection = r.mul(_withdrawalProtectionFee).div(10000);
                r = r.sub(_withdrawalProtection);
            }
        }

        uint b = token3CRV.balanceOf(address(this));
        if (b < r) {
            uint _toWithdraw = r.sub(b);
            if (controller != address(0)) {
                IController(controller).withdraw(address(token3CRV), _toWithdraw);
            }
            uint _after = token3CRV.balanceOf(address(this));
            uint _diff = _after.sub(b);
            if (_diff < _toWithdraw) {
                r = b.add(_diff);
            }
        }

        if (_output == address(token3CRV)) {
            token3CRV.safeTransfer(msg.sender, r);
        } else {
            require(converter.convert_rate(address(token3CRV), _output, r) > 0, "rate=0");
            token3CRV.safeTransfer(address(converter), r);
            uint _outputAmount = converter.convert(address(token3CRV), _output, r);
            IERC20(_output).safeTransfer(msg.sender, _outputAmount);
        }
    }

    function want() external override view returns (address) {
        return address(token3CRV);
    }

    function getPricePerFullShare() external override view returns (uint) {
        return balance().mul(1e18).div(totalSupply());
    }

    function safeYaxTransfer(address _to, uint _amount) internal {
        uint _tokenBal = tokenYAX.balanceOf(address(this));
        tokenYAX.safeTransfer(_to, (_tokenBal < _amount) ? _tokenBal : _amount);
    }

    function earnExtra(address _token) public {
        require(msg.sender == governance, "!governance");
        require(address(_token) != address(token3CRV), "3crv");
        require(address(_token) != address(this), "mlvt");
        uint _amount = IERC20(_token).balanceOf(address(this));
        require(converter.convert_rate(_token, address(token3CRV), _amount) > 0, "rate=0");
        IERC20(_token).safeTransfer(address(converter), _amount);
        converter.convert(_token, address(token3CRV), _amount);
    }
}