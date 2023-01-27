
pragma solidity ^0.8.0;


library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
}// MIT

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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library ECDSAUpgradeable {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
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
}// GPL-3.0-only
pragma solidity ^0.8.6;

interface IGlobalPool_R1 {


    event StakePending(address indexed staker, uint256 amount);

    event StakePendingV2(address indexed staker, uint256 amount, bool indexed isRebasing);

    event RewardClaimed(address indexed staker, uint256 amount);

    event BondContractChanged(address oldBondContract, address newBondContract);

    event CertContractChanged(address oldCertContract, address newCertContract);

    event TokensBurned(address indexed staker, uint256 amount, uint256 shares, uint256 fee, bool indexed isRebasing);

    function stake(uint256 amount) external;


    function stakeAndClaimBonds(uint256 amount) external;


    function stakeAndClaimCerts(uint256 amount) external;


    function unstake(uint256 amount, uint256 fee, uint256 useBeforeBlock, bytes memory signature) external;


    function unstakeBonds(uint256 amount, uint256 fee, uint256 useBeforeBlock, bytes memory signature) external;


    function unstakeCerts(uint256 amount, uint256 fee, uint256 useBeforeBlock, bytes memory signature) external;

}// GPL-3.0-only
pragma solidity ^0.8.6;

interface IinternetBond_R1 {


    event CertTokenChanged(address oldCertToken, address newCertToken);

    event SwapFeeOperatorChanged(address oldSwapFeeOperator, address newSwapFeeOperator);

    event SwapFeeRatioUpdate(uint256 newSwapFeeRatio);

    function balanceToShares(uint256 bonds) external view returns (uint256);


    function burn(address account, uint256 amount) external;


    function changeCertToken(address newCertToken) external;


    function changeSwapFeeOperator(address newSwapFeeOperator) external;


    function commitDelayedBurn(address account, uint256 amount) external;


    function getSwapFeeInBonds(uint256 bonds) external view returns(uint256);


    function getSwapFeeInShares(uint256 shares) external view returns(uint256);


    function lockForDelayedBurn(address account, uint256 amount) external;


    function lockShares(uint256 shares) external;


    function lockSharesFor(address account, uint256 shares) external;


    function mintBonds(address account, uint256 amount) external;


    function pendingBurn(address account) external view returns (uint256);


    function ratio() external view returns (uint256);


    function sharesOf(address account) external view returns (uint256);


    function sharesToBalance(uint256 shares) external view returns (uint256);


    function totalSharesSupply() external view returns (uint256);


    function unlockShares(uint256 shares) external;


    function unlockSharesFor(address account, uint256 bonds) external;


    function updateSwapFeeRatio(uint256 newSwapFeeRatio) external;

}// GPL-3.0-only
pragma solidity ^0.8.6;



contract PolygonPool_R3 is PausableUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable, IGlobalPool_R1 {


    using SafeMathUpgradeable for uint256;
    using MathUpgradeable for uint256;

    event IntermediaryClaimed(
        address[] stakers,
        uint256[] amounts,
        address intermediary, /* intermediary address which handle these funds */
        uint256 total /* total ether sent to intermediary */
    );

    event MaticClaimPending(address indexed claimer, uint256 amount);

    event ClaimsServed(
        address[] claimers,
        uint256[] amounts,
        uint256 missing /* total amount of claims still waiting to be served*/
    );

    mapping(address => uint256) private _pendingUserStakes;
    address[] private _pendingStakers;
    address private _operator;
    address private _notary;
    uint256 private _collectedFee;
    uint256 private _minimumStake;
    address private _bondContract;
    uint256 private _pendingGap;
    uint256[] private  _pendingClaimAmounts;
    address[] private _pendingClaimers;
    uint256 private _pendingMaticClaimGap;
    IERC20Upgradeable private _maticToken;
    IERC20Upgradeable private _ankrToken;
    address private _feeCollector;

    modifier onlyOperator() {

        require(msg.sender == owner() || msg.sender == _operator, "Operator: not allowed");
        _;
    }

    function initialize(address operator, address maticToken, address ankrToken, address feeCollector) public initializer {

        __Pausable_init();
        __ReentrancyGuard_init();
        __Ownable_init();
        _operator = operator;
        _notary = operator;
        _minimumStake = 1e18;
        _maticToken = IERC20Upgradeable(maticToken);
        _ankrToken = IERC20Upgradeable(ankrToken);
        _feeCollector = feeCollector;
    }

    function stake(uint256 amount) external override {

        _stake(msg.sender, amount, true);
    }

    function stakeAndClaimBonds(uint256 amount) external override {

        _stake(msg.sender, amount, true);
    }

    function stakeAndClaimCerts(uint256 amount) external override {

        _stake(msg.sender, amount, false);
        IinternetBond_R1(_bondContract).unlockSharesFor(msg.sender, amount);
    }

    function _stake(address staker, uint256 amount, bool isRebasing) internal nonReentrant {

        require(amount >= _minimumStake, "Value must be greater than min amount");
        require(_maticToken.transferFrom(staker, address(this), amount), "failed to receive MATIC");
        if (_pendingUserStakes[staker] == 0) {
            _pendingStakers.push(staker);
        }
        _pendingUserStakes[staker] = _pendingUserStakes[staker].add(amount);
        IinternetBond_R1(_bondContract).mintBonds(staker, amount);
        emit StakePending(staker, amount);
        emit StakePendingV2(staker, amount, isRebasing);
    }

    function getPendingStakes() public onlyOperator view returns (address[] memory, uint256[] memory) {

        address[] memory addresses = new address[](_pendingStakers.length.sub(_pendingGap));
        uint256[] memory amounts = new uint256[](_pendingStakers.length.sub(_pendingGap));
        uint256 j = 0;
        for (uint256 i = _pendingGap; i < _pendingStakers.length; i++) {
            address staker = _pendingStakers[i];
            if (staker != address(0)) {
                addresses[j] = staker;
                amounts[j] = _pendingUserStakes[staker];
                j++;
            }
        }
        return (addresses, amounts);
    }

    function getRawPendingStakes() public onlyOperator view returns (address[] memory, uint256[] memory) {

        address[] memory addresses = new address[](_pendingStakers.length);
        uint256[] memory amounts = new uint256[](_pendingStakers.length);
        for (uint256 i = 0; i < _pendingStakers.length; i++) {
            address staker = _pendingStakers[i];
            if (staker != address(0)) {
                addresses[i] = staker;
                amounts[i] = _pendingUserStakes[staker];
            }
        }
        return (addresses, amounts);
    }

    function claimToIntermediary(address payable intermediary, uint256 threshold) public onlyOperator payable {

        address[] memory stakers = new address[](_pendingStakers.length.sub(_pendingGap));
        uint256[] memory amounts = new uint256[](_pendingStakers.length.sub(_pendingGap));
        uint256 total = 0;
        uint256 j = 0;
        uint256 gaps = 0;
        uint256 i = 0;
        for (i = _pendingGap; i < _pendingStakers.length; i++) {
            if (total >= threshold) {
                break;
            }
            address staker = _pendingStakers[i];
            uint256 amount = _pendingUserStakes[staker];
            if (staker == address(0) || amount == 0) {
                gaps++;
                continue;
            }
            if (total.add(amount) > threshold) {
                amount = threshold.sub(total);
            }
            stakers[j] = staker;
            amounts[j] = amount;
            total = total.add(amount);
            j++;
            _pendingUserStakes[staker] = _pendingUserStakes[staker].sub(amount);
            if (_pendingUserStakes[staker] == 0) {
                delete _pendingStakers[i];
                gaps++;
            }
        }
        _pendingGap = _pendingGap.add(gaps);
        _maticToken.transfer(intermediary, total.add(msg.value));
        uint256 removeCells = stakers.length.sub(j);
        if (removeCells > 0) {
            assembly {mstore(stakers, sub(mload(stakers), removeCells))}
            assembly {mstore(amounts, sub(mload(amounts), removeCells))}
        }
        emit IntermediaryClaimed(stakers, amounts, intermediary, total);
    }

    function pendingStakesOf(address staker) public view returns (uint256) {

        return _pendingUserStakes[staker];
    }

    function pendingGap() public view returns (uint256) {

        return _pendingGap;
    }

    function calcPendingGap() public onlyOwner {

        uint256 gaps = 0;
        for (uint256 i = 0; i < _pendingStakers.length; i++) {
            address staker = _pendingStakers[i];
            if (staker != address(0)) {
                break;
            }
            gaps++;
        }
        _pendingGap = gaps;
    }

    function resetPendingGap() public onlyOwner {

        _pendingGap = 0;
    }

    function changeOperator(address operator) public onlyOwner {

        _operator = operator;
    }

    function changeBondContract(address bondContract) public onlyOwner {

        _bondContract = bondContract;
    }

    function pendingMaticClaimsOf(address claimer) external view returns (uint256) {

        uint256 claimsTotal;
        for (uint256 i = _pendingMaticClaimGap; i < _pendingClaimers.length; i++) {
            if (_pendingClaimers[i] == claimer) {
                claimsTotal += _pendingClaimAmounts[i];
            }
        }
        return claimsTotal;
    }

    function getPendingClaims() public onlyOperator view returns (address[] memory, uint256[] memory) {

        address[] memory addresses = new address[](_pendingClaimers.length.sub(_pendingMaticClaimGap));
        uint256[] memory amounts = new uint256[](_pendingClaimers.length.sub(_pendingMaticClaimGap));
        uint256 j = 0;
        for (uint256 i = _pendingMaticClaimGap; i < _pendingClaimers.length; i++) {
            address claimer = _pendingClaimers[i];
            uint256 amount = _pendingClaimAmounts[i];
            if (claimer != address(0)) {
                addresses[j] = claimer;
                amounts[j] = amount;
                j++;
            }
        }
        return (addresses, amounts);
    }

    function getRawPendingClaims() public onlyOperator view returns (address[] memory, uint256[] memory) {

        address[] memory addresses = new address[](_pendingClaimers.length);
        uint256[] memory amounts = new uint256[](_pendingClaimers.length);
        for (uint256 i = 0; i < _pendingClaimers.length; i++) {
            address claimer = _pendingClaimers[i];
            uint256 amount = _pendingClaimAmounts[i];
            if (claimer != address(0)) {
                addresses[i] = claimer;
                amounts[i] = amount;
            }
        }
        return (addresses, amounts);
    }

    function unstake(uint256 amount, uint256 fee, uint256 useBeforeBlock, bytes memory signature) override external nonReentrant {

        uint256 shares = IinternetBond_R1(_bondContract).balanceToShares(amount);
        _unstake(msg.sender, amount, shares, fee, useBeforeBlock, signature, true);
    }

    function unstakeBonds(uint256 amount, uint256 fee, uint256 useBeforeBlock, bytes memory signature) override external nonReentrant {

        uint256 shares = IinternetBond_R1(_bondContract).balanceToShares(amount);
        _unstake(msg.sender, amount, shares, fee, useBeforeBlock, signature, true);
    }

    function unstakeCerts(uint256 shares, uint256 fee, uint256 useBeforeBlock, bytes memory signature) override external nonReentrant {

        uint256 amount = IinternetBond_R1(_bondContract).sharesToBalance(shares);
        IinternetBond_R1(_bondContract).lockSharesFor(msg.sender, shares);
        _unstake(msg.sender, amount, shares, fee, useBeforeBlock, signature, false);
    }

    function _unstake(address staker, uint256 amount, uint256 shares, uint256 fee, uint256 useBeforeBlock, bytes memory signature, bool isRebasing) internal {

        require(IERC20Upgradeable(_bondContract).balanceOf(staker) >= amount, "cannot claim more than have on address");
        require(block.number < useBeforeBlock, "fee approval expired");
        require(
            _checkUnstakeFeeSignature(fee, useBeforeBlock, staker, signature),
            "Invalid unstake fee signature"
        );
        require(_ankrToken.transferFrom(staker, _feeCollector, fee), "could not transfer unstake fee");
        _pendingClaimers.push(staker);
        _pendingClaimAmounts.push(amount);
        IinternetBond_R1(_bondContract).lockForDelayedBurn(staker, amount);
        emit MaticClaimPending(staker, amount);
        emit TokensBurned(staker, amount, shares, fee, isRebasing);
    }

    function serveClaims(uint256 amountToUse, address payable residueAddress, uint256 minThreshold) public onlyOperator payable {

        address[] memory claimers = new address[](_pendingClaimers.length.sub(_pendingMaticClaimGap));
        uint256[] memory amounts = new uint256[](_pendingClaimers.length.sub(_pendingMaticClaimGap));
        uint256 availableAmount = _maticToken.balanceOf(address(this));
        availableAmount = availableAmount.sub(_getTotalPendingStakes());
        require(amountToUse <= availableAmount, "not enough MATIC tokens to serve claims");
        if (amountToUse > 0) {
            availableAmount = amountToUse;
        }
        uint256 j = 0;
        uint256 gaps = 0;
        uint256 i = 0;
        for (i = _pendingMaticClaimGap; i < _pendingClaimers.length; i++) {
            if (availableAmount < minThreshold) {
                break;
            }
            address claimer = _pendingClaimers[i];
            uint256 amount = _pendingClaimAmounts[i];
            if (claimer == address(0) || amount == 0) {
                gaps++;
                continue;
            }
            if (availableAmount < amount) {
                break;
            }
            claimers[j] = claimer;
            amounts[j] = amount;
            address payable wallet = payable(address(claimer));
            _maticToken.transfer(wallet, amount);
            availableAmount = availableAmount.sub(amount);
            j++;
            IinternetBond_R1(_bondContract).commitDelayedBurn(claimer, amount);
            delete _pendingClaimAmounts[i];
            delete _pendingClaimers[i];
            gaps++;
        }
        _pendingMaticClaimGap = _pendingMaticClaimGap.add(gaps);
        uint256 missing = 0;
        for (i = _pendingMaticClaimGap; i < _pendingClaimers.length; i++) {
            missing = missing.add(_pendingClaimAmounts[i]);
        }
        if (availableAmount > 0) {
            _maticToken.transfer(residueAddress, availableAmount);
        }
        uint256 removeCells = claimers.length.sub(j);
        if (removeCells > 0) {
            assembly {mstore(claimers, sub(mload(claimers), removeCells))}
            assembly {mstore(amounts, sub(mload(amounts), removeCells))}
        }
        emit ClaimsServed(claimers, amounts, missing);
    }

    function pendingClaimGap() public view returns (uint256) {

        return _pendingMaticClaimGap;
    }

    function calcPendingClaimGap() public onlyOwner {

        uint256 gaps = 0;
        for (uint256 i = 0; i < _pendingClaimers.length; i++) {
            address staker = _pendingClaimers[i];
            if (staker != address(0)) {
                break;
            }
            gaps++;
        }
        _pendingMaticClaimGap = gaps;
    }

    function resetPendingClaimGap() public onlyOwner {

        _pendingMaticClaimGap = 0;
    }

    function getMinimumStake() public view returns (uint256) {

        return _minimumStake;
    }

    function setMinimumStake(uint256 minStake) public onlyOperator {

        _minimumStake = minStake;
    }

    function setFeeCollector(address feeCollector) public onlyOwner {

        _feeCollector = feeCollector;
    }

    function setNotary(address notary) public onlyOwner {

        _notary = notary;
    }

    function setAnkrTokenAddress(IERC20Upgradeable ankrToken) public onlyOwner {

        _ankrToken = ankrToken;
    }

    function _checkUnstakeFeeSignature(
        uint256 fee, uint256 useBeforeBlock, address staker, bytes memory signature
    ) public view returns (bool) {

        bytes32 payloadHash = keccak256(abi.encode(currentChain(), address(this), fee, useBeforeBlock, staker));
        return ECDSAUpgradeable.recover(payloadHash, signature) == _notary;
    }

    function currentChain() private view returns (uint256) {

        uint256 chain;
        assembly {
            chain := chainid()
        }
        return chain;
    }

    function _getTotalPendingStakes() internal view returns (uint256) {

        uint256 totalPendingStakeAmt;
        for (uint256 i = 0; i < _pendingStakers.length; i++) {
            address staker = _pendingStakers[i];
            if (staker != address(0)) {
                totalPendingStakeAmt = totalPendingStakeAmt.add(_pendingUserStakes[staker]);
            }
        }
        return totalPendingStakeAmt;
    }
}