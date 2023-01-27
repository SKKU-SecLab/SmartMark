
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity ^0.8.4;

interface IApproveAndCall {

    function approveAndCall(
        address spender,
        uint256 amount,
        bytes memory extraData
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.4;



interface IERC20WithPermit is IERC20, IERC20Metadata, IApproveAndCall {

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function burn(uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function PERMIT_TYPEHASH() external pure returns (bytes32);

}// MIT

pragma solidity ^0.8.4;

interface IReceiveApproval {

    function receiveApproval(
        address from,
        uint256 amount,
        address token,
        bytes calldata extraData
    ) external;

}// MIT

pragma solidity ^0.8.4;



contract ERC20WithPermit is IERC20WithPermit, Ownable {

    mapping(address => uint256) public override balanceOf;

    mapping(address => mapping(address => uint256)) public override allowance;

    mapping(address => uint256) public override nonces;

    uint256 public immutable cachedChainId;
    bytes32 public immutable cachedDomainSeparator;

    bytes32 public constant override PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    uint256 public override totalSupply;

    string public override name;

    string public override symbol;

    uint8 public constant override decimals = 18;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;

        cachedChainId = block.chainid;
        cachedDomainSeparator = buildDomainSeparator();
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {

        uint256 currentAllowance = allowance[sender][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "Transfer amount exceeds allowance"
            );
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        _transfer(sender, recipient, amount);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {

        require(deadline >= block.timestamp, "Permission expired");

        require(
            uint256(s) <=
                0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "Invalid signature 's' value"
        );
        require(v == 27 || v == 28, "Invalid signature 'v' value");

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        amount,
                        nonces[owner]++,
                        deadline
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == owner,
            "Invalid signature"
        );
        _approve(owner, spender, amount);
    }

    function mint(address recipient, uint256 amount) external onlyOwner {

        require(recipient != address(0), "Mint to the zero address");

        beforeTokenTransfer(address(0), recipient, amount);

        totalSupply += amount;
        balanceOf[recipient] += amount;
        emit Transfer(address(0), recipient, amount);
    }

    function burn(uint256 amount) external override {

        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external override {

        uint256 currentAllowance = allowance[account][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "Burn amount exceeds allowance"
            );
            _approve(account, msg.sender, currentAllowance - amount);
        }
        _burn(account, amount);
    }

    function approveAndCall(
        address spender,
        uint256 amount,
        bytes memory extraData
    ) external override returns (bool) {

        if (approve(spender, amount)) {
            IReceiveApproval(spender).receiveApproval(
                msg.sender,
                amount,
                address(this),
                extraData
            );
            return true;
        }
        return false;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function DOMAIN_SEPARATOR() public view override returns (bytes32) {

        if (block.chainid == cachedChainId) {
            return cachedDomainSeparator;
        } else {
            return buildDomainSeparator();
        }
    }

    function beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _burn(address account, uint256 amount) internal {

        uint256 currentBalance = balanceOf[account];
        require(currentBalance >= amount, "Burn amount exceeds balance");

        beforeTokenTransfer(account, address(0), amount);

        balanceOf[account] = currentBalance - amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {

        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(recipient != address(this), "Transfer to the token address");

        beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = balanceOf[sender];
        require(senderBalance >= amount, "Transfer amount exceeds balance");
        balanceOf[sender] = senderBalance - amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {

        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function buildDomainSeparator() private view returns (bytes32) {

        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes(name)),
                    keccak256(bytes("1")),
                    block.chainid,
                    address(this)
                )
            );
    }
}// ▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄


pragma solidity 0.8.5;

interface IAssetPool {

    function deposit(uint256 amount) external returns (uint256);


    function depositWithMin(uint256 amountToDeposit, uint256 minAmountToMint)
        external
        returns (uint256);


    function initiateWithdrawal(uint256 covAmount) external;


    function completeWithdrawal(address underwriter) external returns (uint256);

}// ▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄


pragma solidity 0.8.5;

interface IAssetPoolUpgrade {

    function depositFor(address underwriter, uint256 amount) external;

}// ▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄


pragma solidity 0.8.5;


contract RewardsPool is Ownable {

    using SafeERC20 for IERC20;

    uint256 public constant DURATION = 7 days;

    IERC20 public immutable rewardToken;
    address public immutable assetPool;

    uint256 public intervalFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public rewardAccumulated = 0;
    uint256 public lastUpdateTime = 0;

    event RewardToppedUp(uint256 amount);
    event RewardWithdrawn(uint256 amount);

    constructor(
        IERC20 _rewardToken,
        address _assetPool,
        address owner
    ) {
        rewardToken = _rewardToken;
        assetPool = _assetPool;
        transferOwnership(owner);
    }

    function topUpReward(uint256 reward) external onlyOwner {

        rewardAccumulated = earned();

        if (block.timestamp >= intervalFinish) {
            rewardRate = reward / DURATION;
        } else {
            uint256 remaining = intervalFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / DURATION;
        }
        intervalFinish = block.timestamp + DURATION;
        lastUpdateTime = block.timestamp;

        emit RewardToppedUp(reward);
        rewardToken.safeTransferFrom(msg.sender, address(this), reward);
    }

    function withdraw() external {

        uint256 amount = earned();
        rewardAccumulated = 0;
        lastUpdateTime = lastTimeRewardApplicable();
        emit RewardWithdrawn(amount);
        rewardToken.safeTransfer(assetPool, amount);
    }

    function earned() public view returns (uint256) {

        return
            rewardAccumulated +
            ((lastTimeRewardApplicable() - lastUpdateTime) * rewardRate);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, intervalFinish);
    }
}// ▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄


pragma solidity 0.8.5;


contract UnderwriterToken is ERC20WithPermit {

    constructor(string memory _name, string memory _symbol)
        ERC20WithPermit(_name, _symbol)
    {}
}// ▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄


pragma solidity 0.8.5;

library GovernanceUtils {

    function getRemainingChangeTime(uint256 changeTimestamp, uint256 delay)
        internal
        view
        returns (uint256)
    {

        require(changeTimestamp > 0, "Change not initiated");
        uint256 elapsed = block.timestamp - changeTimestamp;
        if (elapsed >= delay) {
            return 0;
        } else {
            return delay - elapsed;
        }
    }
}// ▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄


pragma solidity 0.8.5;



contract AssetPool is Ownable, IAssetPool {

    using SafeERC20 for IERC20;
    using SafeERC20 for UnderwriterToken;

    IERC20 public immutable collateralToken;
    UnderwriterToken public immutable underwriterToken;

    RewardsPool public immutable rewardsPool;

    IAssetPoolUpgrade public newAssetPool;

    uint256 public withdrawalDelay = 21 days;
    uint256 public newWithdrawalDelay;
    uint256 public withdrawalDelayChangeInitiated;

    uint256 public withdrawalTimeout = 2 days;
    uint256 public newWithdrawalTimeout;
    uint256 public withdrawalTimeoutChangeInitiated;

    mapping(address => uint256) public withdrawalInitiatedTimestamp;
    mapping(address => uint256) public pendingWithdrawal;

    event Deposited(
        address indexed underwriter,
        uint256 amount,
        uint256 covAmount
    );

    event CoverageClaimed(
        address indexed recipient,
        uint256 amount,
        uint256 timestamp
    );

    event WithdrawalInitiated(
        address indexed underwriter,
        uint256 covAmount,
        uint256 timestamp
    );
    event WithdrawalCompleted(
        address indexed underwriter,
        uint256 amount,
        uint256 covAmount,
        uint256 timestamp
    );

    event ApprovedAssetPoolUpgrade(address newAssetPool);
    event CancelledAssetPoolUpgrade(address cancelledAssetPool);
    event AssetPoolUpgraded(
        address indexed underwriter,
        uint256 collateralAmount,
        uint256 covAmount,
        uint256 timestamp
    );

    event WithdrawalDelayUpdateStarted(
        uint256 withdrawalDelay,
        uint256 timestamp
    );
    event WithdrawalDelayUpdated(uint256 withdrawalDelay);
    event WithdrawalTimeoutUpdateStarted(
        uint256 withdrawalTimeout,
        uint256 timestamp
    );
    event WithdrawalTimeoutUpdated(uint256 withdrawalTimeout);

    modifier onlyAfterWithdrawalGovernanceDelay(
        uint256 changeInitiatedTimestamp
    ) {

        require(changeInitiatedTimestamp > 0, "Change not initiated");
        require(
            block.timestamp - changeInitiatedTimestamp >=
                withdrawalGovernanceDelay(),
            "Governance delay has not elapsed"
        );
        _;
    }

    constructor(
        IERC20 _collateralToken,
        UnderwriterToken _underwriterToken,
        address rewardsManager
    ) {
        collateralToken = _collateralToken;
        underwriterToken = _underwriterToken;

        rewardsPool = new RewardsPool(
            _collateralToken,
            address(this),
            rewardsManager
        );
    }

    function receiveApproval(
        address from,
        uint256 amount,
        address token,
        bytes calldata extraData
    ) external {

        require(msg.sender == token, "Only token caller allowed");
        require(
            token == address(collateralToken),
            "Unsupported collateral token"
        );

        uint256 toMint = _calculateTokensToMint(amount);
        if (extraData.length != 0) {
            require(extraData.length == 32, "Unexpected data length");
            uint256 minAmountToMint = abi.decode(extraData, (uint256));
            require(
                minAmountToMint <= toMint,
                "Amount to mint is smaller than the required minimum"
            );
        }

        _deposit(from, amount, toMint);
    }

    function deposit(uint256 amountToDeposit)
        external
        override
        returns (uint256)
    {

        uint256 toMint = _calculateTokensToMint(amountToDeposit);
        _deposit(msg.sender, amountToDeposit, toMint);
        return toMint;
    }

    function depositWithMin(uint256 amountToDeposit, uint256 minAmountToMint)
        external
        override
        returns (uint256)
    {

        uint256 toMint = _calculateTokensToMint(amountToDeposit);

        require(
            minAmountToMint <= toMint,
            "Amount to mint is smaller than the required minimum"
        );

        _deposit(msg.sender, amountToDeposit, toMint);
        return toMint;
    }

    function initiateWithdrawal(uint256 covAmount) external override {

        uint256 pending = pendingWithdrawal[msg.sender];
        require(
            covAmount > 0 || pending > 0,
            "Underwriter token amount must be greater than 0"
        );

        pending += covAmount;
        pendingWithdrawal[msg.sender] = pending;
        withdrawalInitiatedTimestamp[msg.sender] = block.timestamp;

        emit WithdrawalInitiated(msg.sender, pending, block.timestamp);

        if (covAmount > 0) {
            underwriterToken.safeTransferFrom(
                msg.sender,
                address(this),
                covAmount
            );
        }
    }

    function completeWithdrawal(address underwriter)
        external
        override
        returns (uint256)
    {

        uint256 initiatedAt = withdrawalInitiatedTimestamp[underwriter];
        require(initiatedAt > 0, "No withdrawal initiated for the underwriter");

        uint256 withdrawalDelayEndTimestamp = initiatedAt + withdrawalDelay;
        require(
            withdrawalDelayEndTimestamp < block.timestamp,
            "Withdrawal delay has not elapsed"
        );

        require(
            withdrawalDelayEndTimestamp + withdrawalTimeout >= block.timestamp,
            "Withdrawal timeout elapsed"
        );

        uint256 covAmount = pendingWithdrawal[underwriter];
        uint256 covSupply = underwriterToken.totalSupply();
        delete withdrawalInitiatedTimestamp[underwriter];
        delete pendingWithdrawal[underwriter];

        rewardsPool.withdraw();

        uint256 collateralBalance = collateralToken.balanceOf(address(this));

        uint256 amountToWithdraw = (covAmount * collateralBalance) / covSupply;

        emit WithdrawalCompleted(
            underwriter,
            amountToWithdraw,
            covAmount,
            block.timestamp
        );
        collateralToken.safeTransfer(underwriter, amountToWithdraw);

        underwriterToken.burn(covAmount);

        return amountToWithdraw;
    }

    function upgradeToNewAssetPool(uint256 covAmount, address _newAssetPool)
        external
    {

        require(
            address(newAssetPool) != address(0),
            "New asset pool must be assigned"
        );

        require(
            address(newAssetPool) == _newAssetPool,
            "Addresses of a new asset pool must match"
        );

        require(
            covAmount > 0,
            "Underwriter token amount must be greater than 0"
        );

        uint256 covSupply = underwriterToken.totalSupply();

        rewardsPool.withdraw();

        uint256 collateralBalance = collateralToken.balanceOf(address(this));

        uint256 collateralToTransfer = (covAmount * collateralBalance) /
            covSupply;

        collateralToken.safeApprove(
            address(newAssetPool),
            collateralToTransfer
        );
        underwriterToken.burnFrom(msg.sender, covAmount);
        newAssetPool.depositFor(msg.sender, collateralToTransfer);

        emit AssetPoolUpgraded(
            msg.sender,
            collateralToTransfer,
            covAmount,
            block.timestamp
        );
    }

    function approveNewAssetPoolUpgrade(IAssetPoolUpgrade _newAssetPool)
        external
        onlyOwner
    {

        require(
            address(_newAssetPool) != address(0),
            "New asset pool can't be zero address"
        );

        newAssetPool = _newAssetPool;

        emit ApprovedAssetPoolUpgrade(address(_newAssetPool));
    }

    function cancelNewAssetPoolUpgrade() external onlyOwner {

        emit CancelledAssetPoolUpgrade(address(newAssetPool));

        newAssetPool = IAssetPoolUpgrade(address(0));
    }

    function claim(address recipient, uint256 amount) external onlyOwner {

        emit CoverageClaimed(recipient, amount, block.timestamp);
        rewardsPool.withdraw();
        collateralToken.safeTransfer(recipient, amount);
    }

    function beginWithdrawalDelayUpdate(uint256 _newWithdrawalDelay)
        external
        onlyOwner
    {

        newWithdrawalDelay = _newWithdrawalDelay;
        withdrawalDelayChangeInitiated = block.timestamp;
        emit WithdrawalDelayUpdateStarted(_newWithdrawalDelay, block.timestamp);
    }

    function finalizeWithdrawalDelayUpdate()
        external
        onlyOwner
        onlyAfterWithdrawalGovernanceDelay(withdrawalDelayChangeInitiated)
    {

        withdrawalDelay = newWithdrawalDelay;
        emit WithdrawalDelayUpdated(withdrawalDelay);
        newWithdrawalDelay = 0;
        withdrawalDelayChangeInitiated = 0;
    }

    function beginWithdrawalTimeoutUpdate(uint256 _newWithdrawalTimeout)
        external
        onlyOwner
    {

        newWithdrawalTimeout = _newWithdrawalTimeout;
        withdrawalTimeoutChangeInitiated = block.timestamp;
        emit WithdrawalTimeoutUpdateStarted(
            _newWithdrawalTimeout,
            block.timestamp
        );
    }

    function finalizeWithdrawalTimeoutUpdate()
        external
        onlyOwner
        onlyAfterWithdrawalGovernanceDelay(withdrawalTimeoutChangeInitiated)
    {

        withdrawalTimeout = newWithdrawalTimeout;
        emit WithdrawalTimeoutUpdated(withdrawalTimeout);
        newWithdrawalTimeout = 0;
        withdrawalTimeoutChangeInitiated = 0;
    }

    function grantShares(address recipient, uint256 covAmount)
        external
        onlyOwner
    {

        rewardsPool.withdraw();
        underwriterToken.mint(recipient, covAmount);
    }

    function getRemainingWithdrawalDelayUpdateTime()
        external
        view
        returns (uint256)
    {

        return
            GovernanceUtils.getRemainingChangeTime(
                withdrawalDelayChangeInitiated,
                withdrawalGovernanceDelay()
            );
    }

    function getRemainingWithdrawalTimeoutUpdateTime()
        external
        view
        returns (uint256)
    {

        return
            GovernanceUtils.getRemainingChangeTime(
                withdrawalTimeoutChangeInitiated,
                withdrawalGovernanceDelay()
            );
    }

    function totalValue() external view returns (uint256) {

        return collateralToken.balanceOf(address(this)) + rewardsPool.earned();
    }

    function withdrawalGovernanceDelay() public view returns (uint256) {

        return withdrawalDelay + withdrawalTimeout + 2 days;
    }

    function _calculateTokensToMint(uint256 amountToDeposit)
        internal
        returns (uint256)
    {

        rewardsPool.withdraw();

        uint256 covSupply = underwriterToken.totalSupply();
        uint256 collateralBalance = collateralToken.balanceOf(address(this));

        if (covSupply == 0) {
            return amountToDeposit;
        }

        return (amountToDeposit * covSupply) / collateralBalance;
    }

    function _deposit(
        address depositor,
        uint256 amountToDeposit,
        uint256 amountToMint
    ) internal {

        require(depositor != address(this), "Self-deposit not allowed");

        require(
            amountToMint > 0,
            "Minted tokens amount must be greater than 0"
        );

        emit Deposited(depositor, amountToDeposit, amountToMint);

        underwriterToken.mint(depositor, amountToMint);
        collateralToken.safeTransferFrom(
            depositor,
            address(this),
            amountToDeposit
        );
    }
}