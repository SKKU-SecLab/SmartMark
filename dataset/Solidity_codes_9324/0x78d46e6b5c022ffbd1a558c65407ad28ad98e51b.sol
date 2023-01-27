

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

interface IController {
    function vaults(address) external view returns (address);
    function rewards() external view returns (address);
    function want(address) external view returns (address);
    function balanceOf(address) external view returns (uint);
    function withdraw(address, uint) external;
    function maxAcceptAmount(address) external view returns (uint256);
    function earn(address, uint) external;

    function getStrategyCount(address _vault) external view returns(uint256);
    function depositAvailable(address _vault) external view returns(bool);
    function harvestAllStrategies(address _vault) external;
    function harvestStrategy(address _vault, address _strategy) external;
}

interface ITokenInterface is IERC20 {
    function minters(address account) external view returns (bool);
    function mint(address _to, uint _amount) external;

    function deposit(uint _amount) external;
    function withdraw(uint _amount) external;
    function cap() external returns (uint);
    function yfvLockedBalance() external returns (uint);
}

interface IYFVReferral {
    function setReferrer(address farmer, address referrer) external;
    function getReferrer(address farmer) external view returns (address);
}

interface IFreeFromUpTo {
    function freeFromUpTo(address from, uint valueToken) external returns (uint freed);
}

contract ValueGovernanceVault is ERC20 {
    using Address for address;
    using SafeMath for uint;

    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    modifier discountCHI(uint8 _flag) {
        if ((_flag & 0x1) == 0) {
            _;
        } else {
            uint gasStart = gasleft();
            _;
            uint gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41130);
        }
    }

    ITokenInterface public yfvToken; // stake and wrap to VALUE
    ITokenInterface public valueToken; // stake and reward token
    ITokenInterface public vUSD; // reward token
    ITokenInterface public vETH; // reward token

    uint public fundCap = 9500; // use up to 95% of fund (to keep small withdrawals cheap)
    uint public constant FUND_CAP_DENOMINATOR = 10000;

    uint public earnLowerlimit;

    address public governance;
    address public controller;
    address public rewardReferral;

    struct UserInfo {
        uint amount;
        uint valueRewardDebt;
        uint vusdRewardDebt;
        uint lastStakeTime;
        uint accumulatedStakingPower; // will accumulate every time user harvest

        uint lockedAmount;
        uint lockedDays; // 7 days -> 150 days (5 months)
        uint boostedExtra; // times 1e12 (285200000000 -> +28.52%). See below.
        uint unlockedTime;
    }

    uint maxLockedDays = 150;

    uint lastRewardBlock;  // Last block number that reward distribution occurs.
    uint accValuePerShare; // Accumulated VALUEs per share, times 1e12. See below.
    uint accVusdPerShare; // Accumulated vUSD per share, times 1e12. See below.

    uint public valuePerBlock; // 0.2 VALUE/block at start
    uint public vusdPerBlock; // 5 vUSD/block at start

    mapping(address => UserInfo) public userInfo;
    uint public totalDepositCap;

    uint public constant vETH_REWARD_FRACTION_RATE = 1000;
    uint public minStakingAmount = 0 ether;
    uint public unstakingFrozenTime = 40 hours;
    uint public unlockWithdrawFee = 192; // per ten thousand (eg. 15 -> 0.15%)
    address public valueInsuranceFund = 0xb7b2Ea8A1198368f950834875047aA7294A2bDAa; // set to Governance Multisig at start

    event Deposit(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);
    event RewardPaid(address indexed user, uint reward);
    event CommissionPaid(address indexed user, uint reward);
    event Locked(address indexed user, uint amount, uint _days);
    event EmergencyWithdraw(address indexed user, uint amount);

    constructor (ITokenInterface _yfvToken,
        ITokenInterface _valueToken,
        ITokenInterface _vUSD,
        ITokenInterface _vETH,
        uint _valuePerBlock,
        uint _vusdPerBlock,
        uint _startBlock) public ERC20("GovVault:ValueLiquidity", "gvVALUE") {
        yfvToken = _yfvToken;
        valueToken = _valueToken;
        vUSD = _vUSD;
        vETH = _vETH;
        valuePerBlock = _valuePerBlock;
        vusdPerBlock = _vusdPerBlock;
        lastRewardBlock = _startBlock;
        governance = msg.sender;
    }

    function balance() public view returns (uint) {
        uint bal = valueToken.balanceOf(address(this));
        if (controller != address(0)) bal = bal.add(IController(controller).balanceOf(address(valueToken)));
        return bal;
    }

    function setFundCap(uint _fundCap) external {
        require(msg.sender == governance, "!governance");
        fundCap = _fundCap;
    }

    function setTotalDepositCap(uint _totalDepositCap) external {
        require(msg.sender == governance, "!governance");
        totalDepositCap = _totalDepositCap;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setController(address _controller) public {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }

    function setRewardReferral(address _rewardReferral) external {
        require(msg.sender == governance, "!governance");
        rewardReferral = _rewardReferral;
    }

    function setEarnLowerlimit(uint _earnLowerlimit) public {
        require(msg.sender == governance, "!governance");
        earnLowerlimit = _earnLowerlimit;
    }

    function setMaxLockedDays(uint _maxLockedDays) public {
        require(msg.sender == governance, "!governance");
        maxLockedDays = _maxLockedDays;
    }

    function setValuePerBlock(uint _valuePerBlock) public {
        require(msg.sender == governance, "!governance");
        require(_valuePerBlock <= 10 ether, "Too big _valuePerBlock"); // <= 10 VALUE
        updateReward();
        valuePerBlock = _valuePerBlock;
    }

    function setVusdPerBlock(uint _vusdPerBlock) public {
        require(msg.sender == governance, "!governance");
        require(_vusdPerBlock <= 200 * (10 ** 9), "Too big _vusdPerBlock"); // <= 200 vUSD
        updateReward();
        vusdPerBlock = _vusdPerBlock;
    }

    function setMinStakingAmount(uint _minStakingAmount) public {
        require(msg.sender == governance, "!governance");
        minStakingAmount = _minStakingAmount;
    }

    function setUnstakingFrozenTime(uint _unstakingFrozenTime) public {
        require(msg.sender == governance, "!governance");
        unstakingFrozenTime = _unstakingFrozenTime;
    }

    function setUnlockWithdrawFee(uint _unlockWithdrawFee) public {
        require(msg.sender == governance, "!governance");
        require(_unlockWithdrawFee <= 1000, "Dont be too greedy"); // <= 10%
        unlockWithdrawFee = _unlockWithdrawFee;
    }

    function setValueInsuranceFund(address _valueInsuranceFund) public {
        require(msg.sender == governance, "!governance");
        valueInsuranceFund = _valueInsuranceFund;
    }

    function upgradeVUSDContract(address _vUSDContract) public {
        require(msg.sender == governance, "!governance");
        vUSD = ITokenInterface(_vUSDContract);
    }

    function upgradeVETHContract(address _vETHContract) public {
        require(msg.sender == governance, "!governance");
        vETH = ITokenInterface(_vETHContract);
    }

    function available() public view returns (uint) {
        return valueToken.balanceOf(address(this)).mul(fundCap).div(FUND_CAP_DENOMINATOR);
    }

    function earn(uint8 _flag) public discountCHI(_flag) {
        if (controller != address(0)) {
            uint _amount = available();
            uint _accepted = IController(controller).maxAcceptAmount(address(valueToken));
            if (_amount > _accepted) _amount = _accepted;
            if (_amount > 0) {
                yfvToken.transfer(controller, _amount);
                IController(controller).earn(address(yfvToken), _amount);
            }
        }
    }

    function getRewardAndDepositAll(uint8 _flag) external discountCHI(_flag) {
        unstake(0, 0x0);
        depositAll(address(0), 0x0);
    }

    function depositAll(address _referrer, uint8 _flag) public discountCHI(_flag) {
        deposit(valueToken.balanceOf(msg.sender), _referrer, 0x0);
    }

    function deposit(uint _amount, address _referrer, uint8 _flag) public discountCHI(_flag) {
        uint _pool = balance();
        uint _before = valueToken.balanceOf(address(this));
        valueToken.transferFrom(msg.sender, address(this), _amount);
        uint _after = valueToken.balanceOf(address(this));
        require(totalDepositCap == 0 || _after <= totalDepositCap, ">totalDepositCap");
        _amount = _after.sub(_before); // Additional check for deflationary tokens
        uint _shares = _deposit(address(this), _pool, _amount);
        _stakeShares(msg.sender, _shares, _referrer);
    }

    function depositYFV(uint _amount, address _referrer, uint8 _flag) public discountCHI(_flag) {
        uint _pool = balance();
        yfvToken.transferFrom(msg.sender, address(this), _amount);
        uint _before = valueToken.balanceOf(address(this));
        yfvToken.approve(address(valueToken), 0);
        yfvToken.approve(address(valueToken), _amount);
        valueToken.deposit(_amount);
        uint _after = valueToken.balanceOf(address(this));
        require(totalDepositCap == 0 || _after <= totalDepositCap, ">totalDepositCap");
        _amount = _after.sub(_before); // Additional check for deflationary tokens
        uint _shares = _deposit(address(this), _pool, _amount);
        _stakeShares(msg.sender, _shares, _referrer);
    }

    function buyShares(uint _amount, uint8 _flag) public discountCHI(_flag) {
        uint _pool = balance();
        uint _before = valueToken.balanceOf(address(this));
        valueToken.transferFrom(msg.sender, address(this), _amount);
        uint _after = valueToken.balanceOf(address(this));
        require(totalDepositCap == 0 || _after <= totalDepositCap, ">totalDepositCap");
        _amount = _after.sub(_before); // Additional check for deflationary tokens
        _deposit(msg.sender, _pool, _amount);
    }

    function depositShares(uint _shares, address _referrer, uint8 _flag) public discountCHI(_flag) {
        require(totalDepositCap == 0 || balance().add(_shares) <= totalDepositCap, ">totalDepositCap");
        uint _before = balanceOf(address(this));
        IERC20(address(this)).transferFrom(msg.sender, address(this), _shares);
        uint _after = balanceOf(address(this));
        _shares = _after.sub(_before); // Additional check for deflationary tokens
        _stakeShares(msg.sender, _shares, _referrer);
    }

    function lockShares(uint _locked, uint _days, uint8 _flag) external discountCHI(_flag) {
        require(_days >= 7 && _days <= maxLockedDays, "_days out-of-range");
        UserInfo storage user = userInfo[msg.sender];
        if (user.unlockedTime < block.timestamp) {
            user.lockedAmount = 0;
        } else {
            require(_days >= user.lockedDays, "Extra days should not less than current locked days");
        }
        user.lockedAmount = user.lockedAmount.add(_locked);
        require(user.lockedAmount <= user.amount, "lockedAmount > amount");
        user.unlockedTime = block.timestamp.add(_days * 86400);
        user.boostedExtra = 50000000000 + (_days - 7) * 1500000000;
        emit Locked(msg.sender, user.lockedAmount, _days);
    }

    function _deposit(address _mintTo, uint _pool, uint _amount) internal returns (uint _shares) {
        _shares = 0;
        if (totalSupply() == 0) {
            _shares = _amount;
        } else {
            _shares = (_amount.mul(totalSupply())).div(_pool);
        }
        if (_shares > 0) {
            if (valueToken.balanceOf(address(this)) > earnLowerlimit) {
                earn(0x0);
            }
            _mint(_mintTo, _shares);
        }
    }

    function _stakeShares(address _account, uint _shares, address _referrer) internal {
        UserInfo storage user = userInfo[_account];
        require(minStakingAmount == 0 || user.amount.add(_shares) >= minStakingAmount, "<minStakingAmount");
        updateReward();
        _getReward();
        user.amount = user.amount.add(_shares);
        if (user.lockedAmount > 0 && user.unlockedTime < block.timestamp) {
            user.lockedAmount = 0;
        }
        user.valueRewardDebt = user.amount.mul(accValuePerShare).div(1e12);
        user.vusdRewardDebt = user.amount.mul(accVusdPerShare).div(1e12);
        user.lastStakeTime = block.timestamp;
        emit Deposit(_account, _shares);
        if (rewardReferral != address(0) && _account != address(0)) {
            IYFVReferral(rewardReferral).setReferrer(_account, _referrer);
        }
    }

    function unfrozenStakeTime(address _account) public view returns (uint) {
        return userInfo[_account].lastStakeTime + unstakingFrozenTime;
    }

    function pendingValue(address _account) public view returns (uint _pending) {
        UserInfo storage user = userInfo[_account];
        uint _accValuePerShare = accValuePerShare;
        uint lpSupply = balanceOf(address(this));
        if (block.number > lastRewardBlock && lpSupply != 0) {
            uint numBlocks = block.number.sub(lastRewardBlock);
            _accValuePerShare = accValuePerShare.add(numBlocks.mul(valuePerBlock).mul(1e12).div(lpSupply));
        }
        _pending = user.amount.mul(_accValuePerShare).div(1e12).sub(user.valueRewardDebt);
        if (user.lockedAmount > 0 && user.unlockedTime >= block.timestamp) {
            uint _bonus = _pending.mul(user.lockedAmount.mul(user.boostedExtra).div(1e12)).div(user.amount);
            uint _ceilingBonus = _pending.mul(33).div(100); // 33%
            if (_bonus > _ceilingBonus) _bonus = _ceilingBonus; // Additional check to avoid insanely high bonus!
            _pending = _pending.add(_bonus);
        }
    }

    function pendingVusd(address _account) public view returns (uint) {
        UserInfo storage user = userInfo[_account];
        uint _accVusdPerShare = accVusdPerShare;
        uint lpSupply = balanceOf(address(this));
        if (block.number > lastRewardBlock && lpSupply != 0) {
            uint numBlocks = block.number.sub(lastRewardBlock);
            _accVusdPerShare = accVusdPerShare.add(numBlocks.mul(vusdPerBlock).mul(1e12).div(lpSupply));
        }
        return user.amount.mul(_accVusdPerShare).div(1e12).sub(user.vusdRewardDebt);
    }

    function pendingVeth(address _account) public view returns (uint) {
        return pendingVusd(_account).div(vETH_REWARD_FRACTION_RATE);
    }

    function stakingPower(address _account) public view returns (uint) {
        return userInfo[_account].accumulatedStakingPower.add(pendingValue(_account));
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
        uint _numBlocks = block.number.sub(lastRewardBlock);
        accValuePerShare = accValuePerShare.add(_numBlocks.mul(valuePerBlock).mul(1e12).div(lpSupply));
        accVusdPerShare = accVusdPerShare.add(_numBlocks.mul(vusdPerBlock).mul(1e12).div(lpSupply));
        lastRewardBlock = block.number;
    }

    function _getReward() internal {
        UserInfo storage user = userInfo[msg.sender];
        uint _pendingValue = user.amount.mul(accValuePerShare).div(1e12).sub(user.valueRewardDebt);
        if (_pendingValue > 0) {
            if (user.lockedAmount > 0) {
                if (user.unlockedTime < block.timestamp) {
                    user.lockedAmount = 0;
                } else {
                    uint _bonus = _pendingValue.mul(user.lockedAmount.mul(user.boostedExtra).div(1e12)).div(user.amount);
                    uint _ceilingBonus = _pendingValue.mul(33).div(100); // 33%
                    if (_bonus > _ceilingBonus) _bonus = _ceilingBonus; // Additional check to avoid insanely high bonus!
                    _pendingValue = _pendingValue.add(_bonus);
                }
            }
            user.accumulatedStakingPower = user.accumulatedStakingPower.add(_pendingValue);
            uint actualPaid = _pendingValue.mul(99).div(100); // 99%
            uint commission = _pendingValue - actualPaid; // 1%
            safeValueMint(msg.sender, actualPaid);
            address _referrer = address(0);
            if (rewardReferral != address(0)) {
                _referrer = IYFVReferral(rewardReferral).getReferrer(msg.sender);
            }
            if (_referrer != address(0)) { // send commission to referrer
                safeValueMint(_referrer, commission);
                CommissionPaid(_referrer, commission);
            } else { // send commission to valueInsuranceFund
                safeValueMint(valueInsuranceFund, commission);
                CommissionPaid(valueInsuranceFund, commission);
            }
        }
        uint _pendingVusd = user.amount.mul(accVusdPerShare).div(1e12).sub(user.vusdRewardDebt);
        if (_pendingVusd > 0) {
            safeVusdMint(msg.sender, _pendingVusd);
        }
    }

    function withdrawAll(uint8 _flag) public discountCHI(_flag) {
        UserInfo storage user = userInfo[msg.sender];
        uint _amount = user.amount;
        if (user.lockedAmount > 0) {
            if (user.unlockedTime < block.timestamp) {
                user.lockedAmount = 0;
            } else {
                _amount = user.amount.sub(user.lockedAmount);
            }
        }
        unstake(_amount, 0x0);
        withdraw(balanceOf(msg.sender), 0x0);
    }

    function harvest(address reserve, uint amount) external {
        require(msg.sender == controller, "!controller");
        require(reserve != address(valueToken), "token");
        ITokenInterface(reserve).transfer(controller, amount);
    }

    function unstake(uint _amount, uint8 _flag) public discountCHI(_flag) returns (uint _actualWithdraw) {
        updateReward();
        _getReward();
        UserInfo storage user = userInfo[msg.sender];
        _actualWithdraw = _amount;
        if (_amount > 0) {
            require(user.amount >= _amount, "stakedBal < _amount");
            if (user.lockedAmount > 0) {
                if (user.unlockedTime < block.timestamp) {
                    user.lockedAmount = 0;
                } else {
                    require(user.amount.sub(user.lockedAmount) >= _amount, "stakedBal-locked < _amount");
                }
            }
            user.amount = user.amount.sub(_amount);

            if (block.timestamp < user.lastStakeTime.add(unstakingFrozenTime)) {
                if (unlockWithdrawFee == 0 || valueInsuranceFund == address(0)) revert("Coin is still frozen");

                uint _withdrawFee = _amount.mul(unlockWithdrawFee).div(10000);
                uint r = _amount.sub(_withdrawFee);
                if (_amount > r) {
                    _withdrawFee = _amount.sub(r);
                    _actualWithdraw = r;
                    IERC20(address(this)).transfer(valueInsuranceFund, _withdrawFee);
                    emit RewardPaid(valueInsuranceFund, _withdrawFee);
                }
            }

            IERC20(address(this)).transfer(msg.sender, _actualWithdraw);
        }
        user.valueRewardDebt = user.amount.mul(accValuePerShare).div(1e12);
        user.vusdRewardDebt = user.amount.mul(accVusdPerShare).div(1e12);
        emit Withdraw(msg.sender, _amount);
    }

    function withdraw(uint _shares, uint8 _flag) public discountCHI(_flag) {
        uint _userBal = balanceOf(msg.sender);
        if (_shares > _userBal) {
            uint _need = _shares.sub(_userBal);
            require(_need <= userInfo[msg.sender].amount, "_userBal+staked < _shares");
            uint _actualWithdraw = unstake(_need, 0x0);
            _shares = _userBal.add(_actualWithdraw); // may be less than expected due to unlockWithdrawFee
        }
        uint r = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);

        uint b = valueToken.balanceOf(address(this));
        if (b < r) {
            uint _withdraw = r.sub(b);
            if (controller != address(0)) {
                IController(controller).withdraw(address(valueToken), _withdraw);
            }
            uint _after = valueToken.balanceOf(address(this));
            uint _diff = _after.sub(b);
            if (_diff < _withdraw) {
                r = b.add(_diff);
            }
        }

        valueToken.transfer(msg.sender, r);
    }

    function getPricePerFullShare() public view returns (uint) {
        return balance().mul(1e18).div(totalSupply());
    }

    function getStrategyCount() external view returns (uint) {
        return (controller != address(0)) ? IController(controller).getStrategyCount(address(this)) : 0;
    }

    function depositAvailable() external view returns (bool) {
        return (controller != address(0)) ? IController(controller).depositAvailable(address(this)) : false;
    }

    function harvestAllStrategies(uint8 _flag) public discountCHI(_flag) {
        if (controller != address(0)) {
            IController(controller).harvestAllStrategies(address(this));
        }
    }

    function harvestStrategy(address _strategy, uint8 _flag) public discountCHI(_flag) {
        if (controller != address(0)) {
            IController(controller).harvestStrategy(address(this), _strategy);
        }
    }

    function emergencyWithdraw() external {
        UserInfo storage user = userInfo[msg.sender];
        if (user.lockedAmount > 0 && user.unlockedTime < block.timestamp) {
            user.lockedAmount = 0;
        }
        uint _amount = user.amount.sub(user.lockedAmount);
        user.amount = user.amount.sub(_amount);
        user.valueRewardDebt = 0;
        user.vusdRewardDebt = 0;
        IERC20(address(this)).transfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    function safeValueMint(address _to, uint _amount) internal {
        if (valueToken.minters(address(this)) && _to != address(0)) {
            uint totalSupply = valueToken.totalSupply();
            uint realCap = valueToken.cap().add(valueToken.yfvLockedBalance());
            if (totalSupply.add(_amount) > realCap) {
                valueToken.mint(_to, realCap.sub(totalSupply));
            } else {
                valueToken.mint(_to, _amount);
            }
        }
    }

    function safeVusdMint(address _to, uint _amount) internal {
        if (vUSD.minters(address(this)) && _to != address(0)) {
            vUSD.mint(_to, _amount);
        }
        if (vETH.minters(address(this)) && _to != address(0)) {
            vETH.mint(_to, _amount.div(vETH_REWARD_FRACTION_RATE));
        }
    }

    function governanceResetLocked(address _account) external {
        require(msg.sender == governance, "!governance");
        UserInfo storage user = userInfo[_account];
        user.lockedAmount = 0;
        user.lockedDays = 0;
        user.boostedExtra = 0;
        user.unlockedTime = 0;
    }

    function governanceRecoverUnsupported(IERC20 _token, uint _amount, address _to) external {
        require(msg.sender == governance, "!governance");
        require(address(_token) != address(valueToken) || balance().sub(_amount) >= totalSupply(), "cant withdraw VALUE more than gvVALUE supply");
        _token.transfer(_to, _amount);
    }
}