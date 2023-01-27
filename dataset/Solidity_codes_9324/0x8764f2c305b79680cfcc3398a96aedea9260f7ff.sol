

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

interface IMultiVaultConverter {

    function token() external returns (address);

    function get_virtual_price() external view returns (uint);


    function convert_rate(address _input, address _output, uint _inputAmount) external view returns (uint _outputAmount);

    function calc_token_amount_deposit(uint[] calldata _amounts) external view returns (uint _shareAmount);

    function calc_token_amount_withdraw(uint _shares, address _output) external view returns (uint _outputAmount);


    function convert(address _input, address _output, uint _inputAmount) external returns (uint _outputAmount);

    function convertAll(uint[] calldata _amounts) external returns (uint _outputAmount);

}

interface IFreeFromUpTo {

    function freeFromUpTo(address from, uint value) external returns (uint freed);

}

contract ValueMultiVaultBank {

    using SafeMath for uint;
    using SafeERC20 for IERC20;

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

    IERC20 public valueToken = IERC20(0x49E833337ECe7aFE375e44F4E3e8481029218E5c);

    address public governance;
    address public strategist; // who can call harvestXXX()

    IValueVaultMaster public vaultMaster;
    
    struct UserInfo {
        uint amount;
        mapping(uint8 => uint) rewardDebt;
        mapping(uint8 => uint) accumulatedEarned; // will accumulate every time user harvest
    }

    struct RewardPoolInfo {
        IERC20 rewardToken;     // Address of rewardPool token contract.
        uint lastRewardBlock;   // Last block number that rewardPool distribution occurs.
        uint endRewardBlock;    // Block number which rewardPool distribution ends.
        uint rewardPerBlock;    // Reward token amount to distribute per block.
        uint accRewardPerShare; // Accumulated rewardPool per share, times 1e18.
        uint totalPaidRewards;  // for stat only
    }

    mapping(address => RewardPoolInfo[]) public rewardPoolInfos; // vault address => pool info
    mapping(address => mapping(address => UserInfo)) public userInfo; // vault address => account => userInfo

    event Deposit(address indexed vault, address indexed user, uint amount);
    event Withdraw(address indexed vault, address indexed user, uint amount);
    event RewardPaid(address indexed vault, uint pid, address indexed user, uint reward);

    constructor(IERC20 _valueToken, IValueVaultMaster _vaultMaster) public {
        valueToken = _valueToken;
        vaultMaster = _vaultMaster;
        governance = msg.sender;
        strategist = msg.sender;
    }

    function setGovernance(address _governance) external {

        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setStrategist(address _strategist) external {

        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }

    function setVaultMaster(IValueVaultMaster _vaultMaster) external {

        require(msg.sender == governance, "!governance");
        vaultMaster = _vaultMaster;
    }

    function addVaultRewardPool(address _vault, IERC20 _rewardToken, uint _startBlock, uint _endRewardBlock, uint _rewardPerBlock) external {

        require(msg.sender == governance, "!governance");
        RewardPoolInfo[] storage rewardPools = rewardPoolInfos[_vault];
        require(rewardPools.length < 8, "exceed rwdPoolLim");
        _startBlock = (block.number > _startBlock) ? block.number : _startBlock;
        require(_startBlock <= _endRewardBlock, "sVB>eVB");
        updateReward(_vault);
        rewardPools.push(RewardPoolInfo({
            rewardToken : _rewardToken,
            lastRewardBlock : _startBlock,
            endRewardBlock : _endRewardBlock,
            rewardPerBlock : _rewardPerBlock,
            accRewardPerShare : 0,
            totalPaidRewards : 0
            }));
    }

    function updateRewardPool(address _vault, uint8 _pid, uint _endRewardBlock, uint _rewardPerBlock) external {

        require(msg.sender == governance, "!governance");
        updateRewardPool(_vault, _pid);
        RewardPoolInfo storage rewardPool = rewardPoolInfos[_vault][_pid];
        require(block.number <= rewardPool.endRewardBlock, "late");
        rewardPool.endRewardBlock = _endRewardBlock;
        rewardPool.rewardPerBlock = _rewardPerBlock;
    }

    function updateReward(address _vault) public {

        uint8 rewardPoolLength = uint8(rewardPoolInfos[_vault].length);
        for (uint8 _pid = 0; _pid < rewardPoolLength; ++_pid) {
            updateRewardPool(_vault, _pid);
        }
    }

    function updateRewardPool(address _vault, uint8 _pid) public {

        RewardPoolInfo storage rewardPool = rewardPoolInfos[_vault][_pid];
        uint _endRewardBlockApplicable = block.number > rewardPool.endRewardBlock ? rewardPool.endRewardBlock : block.number;
        if (_endRewardBlockApplicable > rewardPool.lastRewardBlock) {
            uint lpSupply = IERC20(address(_vault)).balanceOf(address(this));
            if (lpSupply > 0) {
                uint _numBlocks = _endRewardBlockApplicable.sub(rewardPool.lastRewardBlock);
                uint _incRewardPerShare = _numBlocks.mul(rewardPool.rewardPerBlock).mul(1e18).div(lpSupply);
                rewardPool.accRewardPerShare = rewardPool.accRewardPerShare.add(_incRewardPerShare);
            }
            rewardPool.lastRewardBlock = _endRewardBlockApplicable;
        }
    }

    function cap(IValueMultiVault _vault) external view returns (uint) {

        return _vault.cap();
    }

    function approveForSpender(IERC20 _token, address _spender, uint _amount) external {

        require(msg.sender == governance, "!governance");
        require(!vaultMaster.isVault(address(_token)), "vaultToken");
        _token.safeApprove(_spender, _amount);
    }

    function deposit(IValueMultiVault _vault, address _input, uint _amount, uint _min_mint_amount, bool _isStake, uint8 _flag) public discountCHI(_flag) {

        require(_vault.accept(_input), "vault does not accept this asset");
        require(_amount > 0, "!_amount");

        if (!_isStake) {
            _vault.depositFor(msg.sender, msg.sender, _input, _amount, _min_mint_amount);
        } else {
            uint _mint_amount = _vault.depositFor(msg.sender, address(this), _input, _amount, _min_mint_amount);
            _stakeVaultShares(address(_vault), _mint_amount);
        }
    }

    function depositAll(IValueMultiVault _vault, uint[] calldata _amounts, uint _min_mint_amount, bool _isStake, uint8 _flag) public discountCHI(_flag) {

        if (!_isStake) {
            _vault.depositAllFor(msg.sender, msg.sender, _amounts, _min_mint_amount);
        } else {
            uint _mint_amount = _vault.depositAllFor(msg.sender, address(this), _amounts, _min_mint_amount);
            _stakeVaultShares(address(_vault), _mint_amount);
        }
    }

    function stakeVaultShares(address _vault, uint _shares) external {

        uint _before = IERC20(address(_vault)).balanceOf(address(this));
        IERC20(address(_vault)).safeTransferFrom(msg.sender, address(this), _shares);
        uint _after = IERC20(address(_vault)).balanceOf(address(this));
        _shares = _after.sub(_before); // Additional check for deflationary tokens
        _stakeVaultShares(_vault, _shares);
    }

    function _stakeVaultShares(address _vault, uint _shares) internal {

        UserInfo storage user = userInfo[_vault][msg.sender];
        updateReward(_vault);
        if (user.amount > 0) {
            getAllRewards(_vault, msg.sender, uint8(0));
        }
        user.amount = user.amount.add(_shares);
        RewardPoolInfo[] storage rewardPools = rewardPoolInfos[_vault];
        uint8 rewardPoolLength = uint8(rewardPools.length);
        for (uint8 _pid = 0; _pid < rewardPoolLength; ++_pid) {
            user.rewardDebt[_pid] = user.amount.mul(rewardPools[_pid].accRewardPerShare).div(1e18);
        }
        emit Deposit(_vault, msg.sender, _shares);
    }

    function unstake(address _vault, uint _amount, uint8 _flag) public discountCHI(_flag) {

        UserInfo storage user = userInfo[_vault][msg.sender];
        updateReward(_vault);
        if (user.amount > 0) {
            getAllRewards(_vault, msg.sender, uint8(0));
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            IERC20(address(_vault)).safeTransfer(msg.sender, _amount);
        }
        RewardPoolInfo[] storage rewardPools = rewardPoolInfos[_vault];
        uint8 rewardPoolLength = uint8(rewardPools.length);
        for (uint8 _pid = 0; _pid < rewardPoolLength; ++_pid) {
            user.rewardDebt[_pid] = user.amount.mul(rewardPools[_pid].accRewardPerShare).div(1e18);
        }
        emit Withdraw(_vault, msg.sender, _amount);
    }

    function getAllRewards(address _vault, address _account, uint8 _flag) public discountCHI(_flag) {

        uint8 rewardPoolLength = uint8(rewardPoolInfos[_vault].length);
        for (uint8 _pid = 0; _pid < rewardPoolLength; ++_pid) {
            getReward(_vault, _pid, _account, uint8(0));
        }
    }

    function getReward(address _vault, uint8 _pid, address _account, uint8 _flag) public discountCHI(_flag) {

        updateRewardPool(_vault, _pid);
        UserInfo storage user = userInfo[_vault][_account];
        RewardPoolInfo storage rewardPool = rewardPoolInfos[_vault][_pid];
        uint _pendingReward = user.amount.mul(rewardPool.accRewardPerShare).div(1e18).sub(user.rewardDebt[_pid]);
        if (_pendingReward > 0) {
            user.accumulatedEarned[_pid] = user.accumulatedEarned[_pid].add(_pendingReward);
            rewardPool.totalPaidRewards = rewardPool.totalPaidRewards.add(_pendingReward);
            safeTokenTransfer(rewardPool.rewardToken, _account, _pendingReward);
            emit RewardPaid(_vault, _pid, _account, _pendingReward);
            user.rewardDebt[_pid] = user.amount.mul(rewardPool.accRewardPerShare).div(1e18);
        }
    }

    function pendingReward(address _vault, uint8 _pid, address _account) public view returns (uint _pending) {

        UserInfo storage user = userInfo[_vault][_account];
        RewardPoolInfo storage rewardPool = rewardPoolInfos[_vault][_pid];
        uint _accRewardPerShare = rewardPool.accRewardPerShare;
        uint lpSupply = IERC20(_vault).balanceOf(address(this));
        uint _endRewardBlockApplicable = block.number > rewardPool.endRewardBlock ? rewardPool.endRewardBlock : block.number;
        if (_endRewardBlockApplicable > rewardPool.lastRewardBlock && lpSupply != 0) {
            uint _numBlocks = _endRewardBlockApplicable.sub(rewardPool.lastRewardBlock);
            uint _incRewardPerShare = _numBlocks.mul(rewardPool.rewardPerBlock).mul(1e18).div(lpSupply);
            _accRewardPerShare = _accRewardPerShare.add(_incRewardPerShare);
        }
        _pending = user.amount.mul(_accRewardPerShare).div(1e18).sub(user.rewardDebt[_pid]);
    }

    function shares_owner(address _vault, address _account) public view returns (uint) {

        return IERC20(_vault).balanceOf(_account).add(userInfo[_vault][_account].amount);
    }

    function withdraw(address _vault, uint _shares, address _output, uint _min_output_amount, uint8 _flag) public discountCHI(_flag) {

        uint _userBal = IERC20(address(_vault)).balanceOf(msg.sender);
        if (_shares > _userBal) {
            uint _need = _shares.sub(_userBal);
            require(_need <= userInfo[_vault][msg.sender].amount, "_userBal+staked < _shares");
            unstake(_vault, _need, uint8(0));
        }
        IERC20(address(_vault)).safeTransferFrom(msg.sender, address(this), _shares);
        IValueMultiVault(_vault).withdrawFor(msg.sender, _shares, _output, _min_output_amount);
    }

    function exit(address _vault, address _output, uint _min_output_amount, uint8 _flag) external discountCHI(_flag) {

        unstake(_vault, userInfo[_vault][msg.sender].amount, uint8(0));
        withdraw(_vault, IERC20(address(_vault)).balanceOf(msg.sender), _output, _min_output_amount, uint8(0));
    }

    function withdraw_fee(IValueMultiVault _vault, uint _shares) external view returns (uint) {

        return _vault.withdraw_fee(_shares);
    }

    function calc_token_amount_deposit(IValueMultiVault _vault, uint[] calldata _amounts) external view returns (uint) {

        return _vault.calc_token_amount_deposit(_amounts);
    }

    function calc_token_amount_withdraw(IValueMultiVault _vault, uint _shares, address _output) external view returns (uint) {

        return _vault.calc_token_amount_withdraw(_shares, _output);
    }

    function convert_rate(IValueMultiVault _vault, address _input, uint _amount) external view returns (uint) {

        return _vault.convert_rate(_input, _amount);
    }

    function harvestStrategy(IValueMultiVault _vault, address _strategy, uint8 _flag) external discountCHI(_flag) {

        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        _vault.harvestStrategy(_strategy);
    }

    function harvestWant(IValueMultiVault _vault, address _want, uint8 _flag) external discountCHI(_flag) {

        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        _vault.harvestWant(_want);
    }

    function harvestAllStrategies(IValueMultiVault _vault, uint8 _flag) external discountCHI(_flag) {

        require(msg.sender == strategist || msg.sender == governance, "!strategist");
        _vault.harvestAllStrategies();
    }

    function safeTokenTransfer(IERC20 _token, address _to, uint _amount) internal {

        uint bal = _token.balanceOf(address(this));
        if (_amount > bal) {
            _token.safeTransfer(_to, bal);
        } else {
            _token.safeTransfer(_to, _amount);
        }
    }

    function governanceRecoverUnsupported(IERC20 _token, uint amount, address to) external {

        require(msg.sender == governance, "!governance");
        require(!vaultMaster.isVault(address(_token)), "vaultToken");
        _token.safeTransfer(to, amount);
    }
}