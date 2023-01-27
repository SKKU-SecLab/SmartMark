
pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.1;

library Address {
    function isContract(address account) internal view returns (bool) {

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {
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
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// GPL-3.0
pragma solidity ^0.8.0;

interface IValidatorShare {
    struct DelegatorUnbond {
        uint256 shares;
        uint256 withdrawEpoch;
    }

    function minAmount() external view returns (uint256);

    function unbondNonces(address _address) external view returns (uint256);

    function validatorId() external view returns (uint256);

    function delegation() external view returns (bool);

    function buyVoucher(uint256 _amount, uint256 _minSharesToMint)
        external
        returns (uint256);

    function sellVoucher_new(uint256 claimAmount, uint256 maximumSharesToBurn)
        external;

    function unstakeClaimTokens_new(uint256 unbondNonce) external;

    function restake() external returns (uint256, uint256);

    function withdrawRewards() external;

    function getTotalStake(address user)
        external
        view
        returns (uint256, uint256);

    function getLiquidRewards(address user) external view returns (uint256);

    function unbonds_new(address _address, uint256 _unbondNonce)
        external
        view
        returns (DelegatorUnbond memory);
}// GPL-3.0
pragma solidity ^0.8.0;

interface IValidatorRegistry {
    function addValidator(uint256 _validatorId) external;

    function removeValidator(uint256 _validatorId) external;

    function setPreferredDepositValidatorId(uint256 _validatorId) external;

    function setPreferredWithdrawalValidatorId(uint256 _validatorId) external;

    function togglePause() external;

    function preferredDepositValidatorId() external view returns (uint256);

    function preferredWithdrawalValidatorId() external view returns (uint256);

    function validatorIdExists(uint256 _validatorId)
        external
        view
        returns (bool);

    function getStakeManager() external view returns (address _stakeManager);

    function getValidatorId(uint256 _index) external view returns (uint256);

    function getValidators() external view returns (uint256[] memory);

    event AddValidator(uint256 indexed _validatorId);
    event RemoveValidator(uint256 indexed _validatorId);
    event SetPreferredDepositValidatorId(uint256 indexed _validatorId);
    event SetPreferredWithdrawalValidatorId(uint256 indexed _validatorId);
}// GPL-3.0
pragma solidity ^0.8.0;

interface IStakeManager {
	function unstake(uint256 validatorId) external;

	function getValidatorId(address user) external view returns (uint256);

	function getValidatorContract(uint256 validatorId)
		external
		view
		returns (address);

	function withdrawRewards(uint256 validatorId) external;

	function validatorStake(uint256 validatorId)
		external
		view
		returns (uint256);

	function unstakeClaim(uint256 validatorId) external;

	function migrateDelegation(
		uint256 fromValidatorId,
		uint256 toValidatorId,
		uint256 amount
	) external;

	function withdrawalDelay() external view returns (uint256);

	function delegationDeposit(
		uint256 validatorId,
		uint256 amount,
		address delegator
	) external returns (bool);

	function epoch() external view returns (uint256);

	enum Status {
		Inactive,
		Active,
		Locked,
		Unstaked
	}

	struct Validator {
		uint256 amount;
		uint256 reward;
		uint256 activationEpoch;
		uint256 deactivationEpoch;
		uint256 jailTime;
		address signer;
		address contractAddress;
		Status status;
		uint256 commissionRate;
		uint256 lastCommissionUpdate;
		uint256 delegatorsReward;
		uint256 delegatedAmount;
		uint256 initialRewardPerStake;
	}

	function validators(uint256 _index)
		external
		view
		returns (Validator memory);

	function createValidator(uint256 _validatorId) external;
}// GPL-3.0
pragma solidity ^0.8.0;



interface IJMS is IERC20 {
	struct WithdrawalRequest {
		uint256 validatorNonce;
		uint256 requestEpoch;
		address validatorAddress;
	}

	function treasury() external view returns (address);

	function feePercent() external view returns (uint8);

	function submit(uint256 _amount) external returns (uint256);

	function requestWithdraw(uint256 _amount) external;

	function claimWithdrawal(uint256 _idx) external;

	function withdrawRewards(uint256 _validatorId) external returns (uint256);

	function stakeRewardsAndDistributeFees(uint256 _validatorId) external;

	function migrateDelegation(
		uint256 _fromValidatorId,
		uint256 _toValidatorId,
		uint256 _amount
	) external;

	function togglePause() external;

	function convertJMSToMatic(uint256 _balance)
		external
		view
		returns (
			uint256,
			uint256,
			uint256
		);

	function convertMaticToJMS(uint256 _balance)
		external
		view
		returns (
			uint256,
			uint256,
			uint256
		);

	function setFeePercent(uint8 _feePercent) external;

	function setValidatorRegistry(address _address) external;

	function setTreasury(address _address) external;

	function getUserWithdrawalRequests(address _address)
		external
		view
		returns (WithdrawalRequest[] memory);

	function getSharesAmountOfUserWithdrawalRequest(
		address _address,
		uint256 _idx
	) external view returns (uint256);

	function getTotalStake(IValidatorShare _validatorShare)
		external
		view
		returns (uint256, uint256);

	function getTotalStakeAcrossAllValidators() external view returns (uint256);

	function getTotalPooledMatic() external view returns (uint256);

	function getContracts()
		external
		view
		returns (
			address _stakeManager,
			address _polygonERC20,
			address _validatorRegistry
		);

	event Submit(address indexed _from, uint256 _amount);
	event Delegate(uint256 indexed _validatorId, uint256 _amountDelegated);
	event RequestWithdraw(
		address indexed _from,
		uint256 _amountJMS,
		uint256 _amountMatic
	);
	event ClaimWithdrawal(
		address indexed _from,
		uint256 indexed _idx,
		uint256 _amountClaimed
	);
	event WithdrawRewards(uint256 indexed _validatorId, uint256 _rewards);
	event StakeRewards(uint256 indexed _validatorId, uint256 _amountStaked);
	event DistributeFees(address indexed _address, uint256 _amount);
	event MigrateDelegation(
		uint256 indexed _fromValidatorId,
		uint256 indexed _toValidatorId,
		uint256 _amount
	);
	event SetFeePercent(uint8 _feePercent);
	event SetTreasury(address _address);
	event SetValidatorRegistry(address _address);
}// GPL-3.0
pragma solidity =0.8.14;



contract JMS is IJMS, ERC20, Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address private validatorRegistry;
    address private stakeManager;
    IERC20 private polygonERC20;

    address public override treasury;
    uint8 public override feePercent;

    struct Compound {
        bool isActive;
        uint256 minReward;
        uint256 minRestake;
    }

    Compound public compoundConfig;

    mapping(address => WithdrawalRequest[]) private userWithdrawalRequests;


    constructor(
        address _validatorRegistry,
        address _stakeManager,
        address _polygonERC20,
        address _treasury
    ) ERC20("Jamon Matic Stake", "JSM") {
        validatorRegistry = _validatorRegistry;
        stakeManager = _stakeManager;
        treasury = _treasury;
        polygonERC20 = IERC20(_polygonERC20);
        compoundConfig.isActive = true;
        compoundConfig.minReward = 2 ether;
        compoundConfig.minRestake = 1 ether;

        feePercent = 10;
        polygonERC20.safeApprove(stakeManager, type(uint256).max);
    }


    function submit(uint256 _amount)
        external
        override
        whenNotPaused
        nonReentrant
        returns (uint256 minted)
    {
        require(_amount > 0, "Invalid amount");
        polygonERC20.safeTransferFrom(msg.sender, address(this), _amount);
        minted = helper_delegate_to_mint(msg.sender, _amount);
        if (compoundConfig.isActive) {
            _doCompound();
        }
    }

    function requestWithdraw(uint256 _amount)
        external
        override
        whenNotPaused
        nonReentrant
    {
        require(_amount > 0, "Invalid amount");

        (uint256 totalAmount2WithdrawInMatic, , ) = convertJMSToMatic(_amount);

        _burn(msg.sender, _amount);

        uint256 leftAmount2WithdrawInMatic = totalAmount2WithdrawInMatic;
        uint256 totalDelegated = getTotalStakeAcrossAllValidators();

        require(
            totalDelegated >= totalAmount2WithdrawInMatic,
            "Too much to withdraw"
        );

        uint256[] memory validators = IValidatorRegistry(validatorRegistry)
            .getValidators();
        uint256 preferredValidatorId = IValidatorRegistry(validatorRegistry)
            .preferredWithdrawalValidatorId();
        uint256 currentIdx = 0;
        for (; currentIdx < validators.length; ++currentIdx) {
            if (preferredValidatorId == validators[currentIdx]) break;
        }

        while (leftAmount2WithdrawInMatic > 0) {
            uint256 validatorId = validators[currentIdx];

            address validatorShare = IStakeManager(stakeManager)
                .getValidatorContract(validatorId);
            (uint256 validatorBalance, ) = getTotalStake(
                IValidatorShare(validatorShare)
            );

            uint256 amount2WithdrawFromValidator = (validatorBalance <=
                leftAmount2WithdrawInMatic)
                ? validatorBalance
                : leftAmount2WithdrawInMatic;

            IValidatorShare(validatorShare).sellVoucher_new(
                amount2WithdrawFromValidator,
                type(uint256).max
            );

            userWithdrawalRequests[msg.sender].push(
                WithdrawalRequest(
                    IValidatorShare(validatorShare).unbondNonces(address(this)),
                    IStakeManager(stakeManager).epoch() +
                        IStakeManager(stakeManager).withdrawalDelay(),
                    validatorShare
                )
            );

            leftAmount2WithdrawInMatic -= amount2WithdrawFromValidator;
            currentIdx = currentIdx + 1 < validators.length
                ? currentIdx + 1
                : 0;
        }
        if (compoundConfig.isActive) {
            _doCompound();
        }
        emit RequestWithdraw(msg.sender, _amount, totalAmount2WithdrawInMatic);
    }

    function claimWithdrawal(uint256 _idx)
        external
        override
        whenNotPaused
        nonReentrant
    {
        _claimWithdrawal(msg.sender, _idx);
        if (compoundConfig.isActive) {
            _doCompound();
        }
    }

    function doCompound() external whenNotPaused nonReentrant {
        _doCompound();
    }

    function withdrawRewards(uint256 _validatorId)
        public
        override
        whenNotPaused
        returns (uint256)
    {
        address validatorShare = IStakeManager(stakeManager)
            .getValidatorContract(_validatorId);

        uint256 balanceBeforeRewards = polygonERC20.balanceOf(address(this));
        IValidatorShare(validatorShare).withdrawRewards();
        uint256 rewards = polygonERC20.balanceOf(address(this)) -
            balanceBeforeRewards;

        emit WithdrawRewards(_validatorId, rewards);
        return rewards;
    }

    function stakeRewardsAndDistributeFees(uint256 _validatorId)
        external
        override
        whenNotPaused
        onlyOwner
    {
        require(
            IValidatorRegistry(validatorRegistry).validatorIdExists(
                _validatorId
            ),
            "Doesn't exist in validator registry"
        );

        address validatorShare = IStakeManager(stakeManager)
            .getValidatorContract(_validatorId);

        uint256 rewards = polygonERC20.balanceOf(address(this));

        require(rewards > 0, "Reward is zero");

        uint256 treasuryFees = (rewards * feePercent) / 100;

        if (treasuryFees > 0) {
            polygonERC20.safeTransfer(treasury, treasuryFees);
            emit DistributeFees(treasury, treasuryFees);
        }

        uint256 amountStaked = rewards - treasuryFees;
        IValidatorShare(validatorShare).buyVoucher(amountStaked, 0);

        emit StakeRewards(_validatorId, amountStaked);
    }

    function migrateDelegation(
        uint256 _fromValidatorId,
        uint256 _toValidatorId,
        uint256 _amount
    ) external override whenNotPaused onlyOwner {
        require(
            IValidatorRegistry(validatorRegistry).validatorIdExists(
                _fromValidatorId
            ),
            "From validator id does not exist in our registry"
        );
        require(
            IValidatorRegistry(validatorRegistry).validatorIdExists(
                _toValidatorId
            ),
            "To validator id does not exist in our registry"
        );

        IStakeManager(stakeManager).migrateDelegation(
            _fromValidatorId,
            _toValidatorId,
            _amount
        );

        emit MigrateDelegation(_fromValidatorId, _toValidatorId, _amount);
    }

    function togglePause() external override onlyOwner {
        paused() ? _unpause() : _pause();
    }


    function helper_delegate_to_mint(address deposit_sender, uint256 _amount)
        internal
        returns (uint256)
    {
        (uint256 amountToMint, , ) = convertMaticToJMS(_amount);

        _mint(deposit_sender, amountToMint);
        emit Submit(deposit_sender, _amount);

        uint256 preferredValidatorId = IValidatorRegistry(validatorRegistry)
            .preferredDepositValidatorId();
        address validatorShare = IStakeManager(stakeManager)
            .getValidatorContract(preferredValidatorId);
        IValidatorShare(validatorShare).buyVoucher(_amount, 0);

        emit Delegate(preferredValidatorId, _amount);
        return amountToMint;
    }

    function _doCompound() internal {
        uint256 preferredValidatorId = IValidatorRegistry(validatorRegistry)
            .preferredDepositValidatorId();
        address validatorShare = IStakeManager(stakeManager)
            .getValidatorContract(preferredValidatorId);
        uint256 pending = IValidatorShare(validatorShare).getLiquidRewards(
            address(this)
        );
        if (pending > compoundConfig.minReward) {
            IValidatorShare(validatorShare).withdrawRewards();
        }
        uint256 rewards = polygonERC20.balanceOf(address(this));
        if (rewards > compoundConfig.minRestake) {
            uint256 treasuryFees = (rewards * feePercent) / 100;
            if (treasuryFees > 0) {
                polygonERC20.safeTransfer(treasury, treasuryFees);
                emit DistributeFees(treasury, treasuryFees);
            }

            uint256 amountStaked = rewards - treasuryFees;
            IValidatorShare(validatorShare).buyVoucher(amountStaked, 0);
            emit StakeRewards(preferredValidatorId, amountStaked);
        }
    }

    function _claimWithdrawal(address _to, uint256 _idx)
        internal
        returns (uint256)
    {
        uint256 amountToClaim = 0;
        uint256 balanceBeforeClaim = polygonERC20.balanceOf(address(this));
        WithdrawalRequest[] storage userRequests = userWithdrawalRequests[_to];
        WithdrawalRequest memory userRequest = userRequests[_idx];
        require(
            IStakeManager(stakeManager).epoch() >= userRequest.requestEpoch,
            "Not able to claim yet"
        );

        IValidatorShare(userRequest.validatorAddress).unstakeClaimTokens_new(
            userRequest.validatorNonce
        );

        userRequests[_idx] = userRequests[userRequests.length - 1];
        userRequests.pop();

        amountToClaim =
            polygonERC20.balanceOf(address(this)) -
            balanceBeforeClaim;

        polygonERC20.safeTransfer(_to, amountToClaim);

        emit ClaimWithdrawal(_to, _idx, amountToClaim);
        return amountToClaim;
    }

    function convertJMSToMatic(uint256 _balance)
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 totalShares = totalSupply();
        totalShares = totalShares == 0 ? 1 : totalShares;

        uint256 totalPooledMATIC = getTotalPooledMatic();
        totalPooledMATIC = totalPooledMATIC == 0 ? 1 : totalPooledMATIC;

        uint256 balanceInMATIC = (_balance * (totalPooledMATIC)) / totalShares;

        return (balanceInMATIC, totalShares, totalPooledMATIC);
    }

    function convertMaticToJMS(uint256 _balance)
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 totalShares = totalSupply();
        totalShares = totalShares == 0 ? 1 : totalShares;

        uint256 totalPooledMatic = getTotalPooledMatic();
        totalPooledMatic = totalPooledMatic == 0 ? 1 : totalPooledMatic;

        uint256 balanceInJMS = (_balance * totalShares) / totalPooledMatic;

        return (balanceInJMS, totalShares, totalPooledMatic);
    }


    function setFeePercent(uint8 _feePercent) external override onlyOwner {
        require(_feePercent <= 100, "_feePercent must not exceed 100");

        feePercent = _feePercent;

        emit SetFeePercent(_feePercent);
    }

    function setTreasury(address _address) external override onlyOwner {
        treasury = _address;

        emit SetTreasury(_address);
    }

    function setCompound(
        bool _set,
        uint256 _minReward,
        uint256 _minRestake
    ) external onlyOwner {
        require(_minReward >= 1 ether  && _minRestake >= 1 gwei, "invalid mins");
        compoundConfig.isActive = _set;
        compoundConfig.minReward = _minReward;
        compoundConfig.minRestake = _minRestake;
    }

    function setValidatorRegistry(address _address)
        external
        override
        onlyOwner
    {
        validatorRegistry = _address;

        emit SetValidatorRegistry(_address);
    }

    function getTotalStake(IValidatorShare _validatorShare)
        public
        view
        override
        returns (uint256, uint256)
    {
        return _validatorShare.getTotalStake(address(this));
    }

    function currentEpoch() external view returns (uint256) {
        return IStakeManager(stakeManager).epoch();
    }

    function getTotalStakeAcrossAllValidators()
        public
        view
        override
        returns (uint256)
    {
        uint256 totalStake;
        uint256[] memory validators = IValidatorRegistry(validatorRegistry)
            .getValidators();
        for (uint256 i = 0; i < validators.length; ++i) {
            address validatorShare = IStakeManager(stakeManager)
                .getValidatorContract(validators[i]);
            (uint256 currValidatorShare, ) = getTotalStake(
                IValidatorShare(validatorShare)
            );

            totalStake += currValidatorShare;
        }

        return totalStake;
    }

    function getTotalPooledMatic() public view override returns (uint256) {
        uint256 totalStaked = getTotalStakeAcrossAllValidators();
        return totalStaked;
    }

    function getUserWithdrawalRequests(address _address)
        external
        view
        override
        returns (WithdrawalRequest[] memory)
    {
        return userWithdrawalRequests[_address];
    }

    function getSharesAmountOfUserWithdrawalRequest(
        address _address,
        uint256 _idx
    ) external view override returns (uint256) {
        WithdrawalRequest memory userRequest = userWithdrawalRequests[_address][
            _idx
        ];
        IValidatorShare validatorShare = IValidatorShare(
            userRequest.validatorAddress
        );
        IValidatorShare.DelegatorUnbond memory unbond = validatorShare
            .unbonds_new(address(this), userRequest.validatorNonce);

        return unbond.shares;
    }

    function getPendingRewards() external view returns (uint256) {
        uint256 preferredValidatorId = IValidatorRegistry(validatorRegistry)
            .preferredDepositValidatorId();
        address validatorShare = IStakeManager(stakeManager)
            .getValidatorContract(preferredValidatorId);
        return IValidatorShare(validatorShare).getLiquidRewards(address(this));
    }

    function getPendingRewardsAtValidator(uint256 _validatorId)
        external
        view
        returns (uint256)
    {
        address validatorShare = IStakeManager(stakeManager)
            .getValidatorContract(_validatorId);
        return IValidatorShare(validatorShare).getLiquidRewards(address(this));
    }

    function getContracts()
        external
        view
        override
        returns (
            address _stakeManager,
            address _polygonERC20,
            address _validatorRegistry
        )
    {
        _stakeManager = stakeManager;
        _polygonERC20 = address(polygonERC20);
        _validatorRegistry = validatorRegistry;
    }
}