
pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;

library ECDSAUpgradeable {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.0;

library MathUpgradeable {

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

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// GPL-3.0-only
pragma solidity ^0.8.6;


interface IRewardPool {


    event RewardPayoutDeposited(uint8 payoutType, uint64 fromBlock, uint64 toBlockExclusive, uint256 amount);

    event TokensClaimed(uint256 claimId, uint256 amount, uint256 claimBeforeBlock, address account);

    event ClaimedParachainRewards(address account, bytes recipient, uint256 amount);

    event ClaimedTokenRewards(address account, uint256 amount);

    event TokensBurnedForRefund(address account, bytes recipient, uint256 amount);

    function initZeroRewardPayout(uint256 maxSupply, uint8 payoutType, uint64 fromBlock, uint64 toBlockExclusive, uint256 amount) external;


    function depositRewardPayout(uint8 payoutType, uint64 fromBlock, uint64 toBlockExclusive, uint256 amount) external;


    function isClaimUsed(uint256 claimId) external view returns (bool);


    function claimTokensFor(uint256 claimId, uint256 amount, uint256 claimBeforeBlock, address account, bytes memory signature) external;


    function claimableRewardsOf(address account) external view returns (uint256);


    function isTokenClaim() external view returns (bool);


    function isParachainClaim() external view returns (bool);


    function claimTokenRewards() external;


    function claimParachainRewards(bytes calldata recipient) external;


    function toggleTokenBurn(bool isEnabled) external;


    function isTokenBurnEnabled() external view returns (bool);


    function burnTokens(uint256 amount, bytes calldata recipient) external;

}// GPL-3.0-only
pragma solidity ^0.8.0;

interface IOwnable {


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);


    function renounceOwnership() external;


    function transferOwnership(address newOwner) external;


}// GPL-3.0-only
pragma solidity ^0.8.0;

interface IPausable {


    event Paused(address account);

    event Unpaused(address account);

    function paused() external view returns (bool);

}// GPL-3.0-only
pragma solidity ^0.8.6;



contract RewardPoolTemplate_R1 is Initializable, ContextUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable, OwnableUpgradeable, ERC20Upgradeable, ERC165Upgradeable, IRewardPool {


    uint8 constant public PAYOUT_TYPE_UNIFORM = uint8(0x00);

    uint16 constant public CLAIM_MODE_UNAVAILABLE = uint16(0 << 0);
    uint16 constant public CLAIM_MODE_ERC20 = uint16(1 << 0);
    uint16 constant public CLAIM_MODE_PARACHAIN = uint16(1 << 1);

    struct RewardPayout {
        uint8 payoutType;
        uint128 totalRewards;
        uint64 fromBlock;
        uint32 durationBlocks;
    }

    struct RewardState {
        uint64 firstNotClaimedBlock;
        uint128 pendingRewards;
        uint32 activeRewardPayout;
    }

    RewardPayout[] private _rewardPayouts;
    mapping(address => RewardState) _rewardStates;
    address private _transactionNotary;
    mapping(bytes32 => bool) _verifiedProofs;
    IERC20Upgradeable private _stakingToken;
    uint8 private _decimals;
    address private _multiSigWallet;
    uint16 private _claimMode;
    bool private _burnEnabled;

    function initialize(string calldata symbol, string calldata name, uint8 decimals_, address transactionNotary, address multiSigWallet, IERC20Upgradeable rewardToken, uint16 claimMode) external initializer {

        __Context_init();
        __ReentrancyGuard_init();
        __Pausable_init();
        __Ownable_init();
        __ERC20_init(name, symbol);
        __RewardPool_init(decimals_, transactionNotary, multiSigWallet, rewardToken, claimMode);
    }

    function __RewardPool_init(uint8 decimals_, address transactionNotary, address multiSigWallet, IERC20Upgradeable stakingToken, uint16 claimMode) internal {

        _transactionNotary = transactionNotary;
        _decimals = decimals_;
        _multiSigWallet = multiSigWallet;
        _claimMode = claimMode;
        _stakingToken = stakingToken;
        if (isTokenClaim()) {
            require(address(stakingToken) != address(0x00), "staking token is required for ERC20 claim mode");
        }
        _pause();
    }

    function getRewardPayouts() external view returns (RewardPayout[] memory) {

        return _rewardPayouts;
    }

    function getTransactionNotary() external view returns (address) {

        return _transactionNotary;
    }

    function getRewardToken() external view returns (IERC20Upgradeable) {

        return _stakingToken;
    }

    function getStakingToken() external view returns (IERC20Upgradeable) {

        return _stakingToken;
    }

    function getMultiSigWallet() external view returns (address) {

        return _multiSigWallet;
    }

    function getClaimMode() external view returns (uint16) {

        return _claimMode;
    }

    function getCurrentRewardState(address account) external view returns (RewardState memory) {

        return _rewardStates[account];
    }

    function getFutureRewardState(address account) external view returns (RewardState memory) {

        RewardState memory rewardState = _rewardStates[account];
        _calcPendingRewards(balanceOf(account), rewardState);
        return rewardState;
    }

    modifier onlyMultiSig() {

        require(msg.sender == _multiSigWallet, "only multi-sig");
        _;
    }

    modifier onlyOperator() {

        require(msg.sender == _transactionNotary, "Operator: not allowed");
        _;
    }

    modifier whenTokenBurnEnabled() {

        require(_burnEnabled, "token burning is not allowed yet");
        _;
    }

    function decimals() public view virtual override returns (uint8) {

        return _decimals;
    }

    function changeMultiSigWallet(address multiSigWallet) external onlyMultiSig {

        _multiSigWallet = multiSigWallet;
    }

    modifier whenZeroSupply() {

        require(totalSupply() == 0, "total supply is not zero");
        _;
    }

    function initZeroRewardPayout(uint256 maxSupply, uint8 payoutType, uint64 fromBlock, uint64 toBlockExclusive, uint256 amount) external onlyMultiSig whenZeroSupply whenPaused override {

        _mint(address(this), maxSupply);
        _depositRewardPayout(payoutType, fromBlock, toBlockExclusive, amount);
        _unpause();
    }

    function depositRewardPayout(uint8 payoutType, uint64 fromBlock, uint64 toBlockExclusive, uint256 amount) external onlyMultiSig whenNotPaused override {

        _depositRewardPayout(payoutType, fromBlock, toBlockExclusive, amount);
    }

    function _depositRewardPayout(uint8 payoutType, uint64 fromBlock, uint64 toBlockExclusive, uint256 amount) internal {

        require(toBlockExclusive > fromBlock, "intersection is not allowed");
        require(payoutType == PAYOUT_TYPE_UNIFORM, "invalid payout type");
        if (_rewardPayouts.length > 0) {
            RewardPayout memory latestRewardPayout = _rewardPayouts[_rewardPayouts.length - 1];
            require(latestRewardPayout.fromBlock + latestRewardPayout.durationBlocks <= fromBlock, "intersection is not allowed");
        }
        _rewardPayouts.push(RewardPayout({
        totalRewards : uint128(amount),
        fromBlock : fromBlock,
        durationBlocks : uint32(toBlockExclusive - fromBlock),
        payoutType : payoutType
        }));
        if (address(_stakingToken) != address(0x00)) {
            require(_stakingToken.transferFrom(msg.sender, address(this), amount), "can't transfer reward tokens");
        }
        emit RewardPayoutDeposited(payoutType, fromBlock, toBlockExclusive, amount);
    }

    function isClaimUsed(uint256 claimId) external view override returns (bool) {

        return _verifiedProofs[bytes32(claimId)];
    }

    function claimTokensFor(uint256 claimId, uint256 amount, uint256 claimBeforeBlock, address account, bytes memory signature) external nonReentrant whenNotPaused override {

        require(block.number < claimBeforeBlock, "claim is expired");
        bytes32 messageHash = keccak256(abi.encode(address(this), claimId, amount, claimBeforeBlock, account));
        require(ECDSAUpgradeable.recover(messageHash, signature) == _transactionNotary, "bad signature");
        require(!_verifiedProofs[bytes32(claimId)], "proof is already used");
        _verifiedProofs[bytes32(claimId)] = true;
        _transfer(address(this), account, amount);
        RewardState memory rewardState = _rewardStates[account];
        rewardState.activeRewardPayout = 0;
        rewardState.firstNotClaimedBlock = 0;
        _calcPendingRewards(amount, rewardState);
        _rewardStates[account] = rewardState;
        emit TokensClaimed(claimId, amount, claimBeforeBlock, account);
    }

    function claimableRewardsOf(address account) external view override returns (uint256) {

        RewardState memory rewardState = _rewardStates[account];
        _calcPendingRewards(balanceOf(account), rewardState);
        return uint256(rewardState.pendingRewards);
    }

    function isTokenClaim() public view override returns (bool) {

        return (_claimMode & CLAIM_MODE_ERC20) > 0;
    }

    function isParachainClaim() public view override returns (bool) {

        return (_claimMode & CLAIM_MODE_PARACHAIN) > 0;
    }

    function claimTokenRewards() external nonReentrant whenNotPaused override {

        require(isTokenClaim(), "not supported claim mode");
        address account = address(msg.sender);
        uint256 amount = _chargeRewardsClaim(account);
        require(_stakingToken.transfer(account, amount), "can't send rewards");
        emit ClaimedTokenRewards(account, amount);
    }

    function claimParachainRewards(bytes calldata recipient) external nonReentrant whenNotPaused override {

        require(isParachainClaim(), "not supported claim mode");
        address account = address(msg.sender);
        uint256 amount = _chargeRewardsClaim(account);
        emit ClaimedParachainRewards(account, recipient, amount);
    }

    function _chargeRewardsClaim(address account) internal returns (uint256) {

        RewardState memory rewardState = _rewardStates[account];
        _calcPendingRewards(balanceOf(account), rewardState);
        require(rewardState.pendingRewards > 0, "there is no rewards to be claimed");
        uint256 amount = rewardState.pendingRewards;
        rewardState.pendingRewards = 0;
        _rewardStates[account] = rewardState;
        return amount;
    }

    function _advancePendingRewards(address account) internal {

        if (account == address(this)) {
            return;
        }
        RewardState memory rewardState = _rewardStates[account];
        _calcPendingRewards(balanceOf(account), rewardState);
        _rewardStates[account] = rewardState;
    }

    function _calcPendingRewards(uint256 balance, RewardState memory rewardState) internal view {

        if (_rewardPayouts.length == 0 || rewardState.activeRewardPayout >= _rewardPayouts.length) {
            return;
        }
        uint64 latestPayoutBlock = 0;
        uint256 totalRewardPayouts = _rewardPayouts.length;
        for (uint256 i = rewardState.activeRewardPayout; i < totalRewardPayouts; i++) {
            RewardPayout memory rewardPayout = _rewardPayouts[i];
            if (i == totalRewardPayouts - 1) {
                latestPayoutBlock = rewardPayout.fromBlock + rewardPayout.durationBlocks;
            }
            _calcPendingRewardsForPayout(balance, rewardState, rewardPayout);
        }
        uint64 blockNumber = uint64(block.number);
        if (blockNumber >= latestPayoutBlock) {
            rewardState.activeRewardPayout = uint32(_rewardPayouts.length);
            rewardState.firstNotClaimedBlock = latestPayoutBlock;
        } else {
            rewardState.activeRewardPayout = uint32(_rewardPayouts.length - 1);
            rewardState.firstNotClaimedBlock = blockNumber + 1;
        }
    }

    function _calcPendingRewardsForPayout(uint256 balance, RewardState memory rewardState, RewardPayout memory currentPayout) internal view {

        (uint256 fromBlock, uint256 toBlockExclusive) = (uint256(currentPayout.fromBlock), uint256(currentPayout.fromBlock + currentPayout.durationBlocks));
        uint64 blockNumber = uint64(block.number);
        if (blockNumber < fromBlock || rewardState.firstNotClaimedBlock >= toBlockExclusive) {
            return;
        }
        uint256 stakingBlocks = MathUpgradeable.min(blockNumber + 1, toBlockExclusive) - MathUpgradeable.max(fromBlock, rewardState.firstNotClaimedBlock);
        if (currentPayout.payoutType == PAYOUT_TYPE_UNIFORM) {
            uint256 avgRewardsPerBlock = uint256(currentPayout.totalRewards) / currentPayout.durationBlocks;
            uint256 accountShare = 1e18 * balance / totalSupply();
            rewardState.pendingRewards += uint128(accountShare * avgRewardsPerBlock / 1e18 * stakingBlocks);
        } else {
            revert("not supported payout type");
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 /*amount*/) internal override {

        if (from != to) {
            _advancePendingRewards(from);
        }
        _advancePendingRewards(to);
    }

    function toggleTokenBurn(bool isEnabled) external onlyOperator whenNotPaused override {

        _burnEnabled = isEnabled;
    }

    function isTokenBurnEnabled() external view override returns (bool) {

        return _burnEnabled;
    }

    function burnTokens(uint256 amount, bytes calldata recipient) external nonReentrant whenNotPaused whenTokenBurnEnabled override {

        uint256 balance = balanceOf(_msgSender());
        require(balance >= amount, "cannot burn more tokens than available");
        _burn(_msgSender(), amount);
        address account = address(msg.sender);
        emit TokensBurnedForRefund(account, recipient, amount);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return super.supportsInterface(interfaceId)
        || interfaceId == type(IOwnable).interfaceId
        || interfaceId == type(IPausable).interfaceId
        || interfaceId == type(IERC20Upgradeable).interfaceId
        || interfaceId == type(IERC20MetadataUpgradeable).interfaceId
        || interfaceId == type(IRewardPool).interfaceId;
    }
}