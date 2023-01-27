
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
}// MIT

pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}// MIT
pragma solidity ^0.8.0;


contract MultiRewardsDistributor is Pausable, ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    struct TreeParameter {
        address safeGuard; // address of the safe guard (e.g., address(0))
        bytes32 merkleRoot; // current merkle root
        uint256 maxAmountPerUserInCurrentTree; // max amount per user in the current tree
    }

    uint256 public constant BUFFER_ADMIN_WITHDRAW = 3 days;

    uint256 public constant SAFE_GUARD_AMOUNT = 1e18;

    IERC20 public immutable looksRareToken;

    uint8 public numberTrees;

    uint256 public currentRewardRound;

    uint256 public lastPausedTimestamp;

    mapping(uint8 => TreeParameter) public treeParameters;

    mapping(address => mapping(uint8 => uint256)) public amountClaimedByUserPerTreeId;

    mapping(address => bool) public safeGuardUsed;

    mapping(bytes32 => bool) public merkleRootUsed;

    event Claim(address user, uint256 rewardRound, uint256 totalAmount, uint8[] treeIds, uint256[] amounts);
    event NewTree(uint8 treeId);
    event UpdateTradingRewards(uint256 indexed rewardRound);
    event TokenWithdrawnOwner(uint256 amount);

    constructor(address _looksRareToken) {
        looksRareToken = IERC20(_looksRareToken);
        _pause();
    }

    function claim(
        uint8[] calldata treeIds,
        uint256[] calldata amounts,
        bytes32[][] calldata merkleProofs
    ) external whenNotPaused nonReentrant {

        require(
            treeIds.length > 0 && treeIds.length == amounts.length && merkleProofs.length == treeIds.length,
            "Rewards: Wrong lengths"
        );

        uint256 amountToTransfer;
        uint256[] memory adjustedAmounts = new uint256[](amounts.length);

        for (uint256 i = 0; i < treeIds.length; i++) {
            require(treeIds[i] < numberTrees, "Rewards: Tree nonexistent");
            (bool claimStatus, uint256 adjustedAmount) = _canClaim(msg.sender, treeIds[i], amounts[i], merkleProofs[i]);
            require(claimStatus, "Rewards: Invalid proof");
            require(adjustedAmount > 0, "Rewards: Already claimed");
            require(
                amounts[i] <= treeParameters[treeIds[i]].maxAmountPerUserInCurrentTree,
                "Rewards: Amount higher than max"
            );
            amountToTransfer += adjustedAmount;
            amountClaimedByUserPerTreeId[msg.sender][treeIds[i]] += adjustedAmount;
            adjustedAmounts[i] = adjustedAmount;
        }

        looksRareToken.safeTransfer(msg.sender, amountToTransfer);

        emit Claim(msg.sender, currentRewardRound, amountToTransfer, treeIds, adjustedAmounts);
    }

    function updateTradingRewards(
        uint8[] calldata treeIds,
        bytes32[] calldata merkleRoots,
        uint256[] calldata maxAmountsPerUser,
        bytes32[][] calldata merkleProofsSafeGuards
    ) external onlyOwner {

        require(
            treeIds.length > 0 &&
                treeIds.length == merkleRoots.length &&
                treeIds.length == maxAmountsPerUser.length &&
                treeIds.length == merkleProofsSafeGuards.length,
            "Owner: Wrong lengths"
        );

        for (uint256 i = 0; i < merkleRoots.length; i++) {
            require(treeIds[i] < numberTrees, "Owner: Tree nonexistent");
            require(!merkleRootUsed[merkleRoots[i]], "Owner: Merkle root already used");
            treeParameters[treeIds[i]].merkleRoot = merkleRoots[i];
            treeParameters[treeIds[i]].maxAmountPerUserInCurrentTree = maxAmountsPerUser[i];
            merkleRootUsed[merkleRoots[i]] = true;
            (bool canSafeGuardClaim, ) = _canClaim(
                treeParameters[treeIds[i]].safeGuard,
                treeIds[i],
                SAFE_GUARD_AMOUNT,
                merkleProofsSafeGuards[i]
            );
            require(canSafeGuardClaim, "Owner: Wrong safe guard proofs");
        }

        emit UpdateTradingRewards(++currentRewardRound);
    }

    function addNewTree(address safeGuard) external onlyOwner {

        require(!safeGuardUsed[safeGuard], "Owner: Safe guard already used");
        safeGuardUsed[safeGuard] = true;
        treeParameters[numberTrees].safeGuard = safeGuard;

        emit NewTree(numberTrees++);
    }

    function pauseDistribution() external onlyOwner whenNotPaused {

        lastPausedTimestamp = block.timestamp;
        _pause();
    }

    function unpauseDistribution() external onlyOwner whenPaused {

        _unpause();
    }

    function withdrawTokenRewards(uint256 amount) external onlyOwner whenPaused {

        require(block.timestamp > (lastPausedTimestamp + BUFFER_ADMIN_WITHDRAW), "Owner: Too early to withdraw");
        looksRareToken.safeTransfer(msg.sender, amount);

        emit TokenWithdrawnOwner(amount);
    }

    function canClaim(
        address user,
        uint8[] calldata treeIds,
        uint256[] calldata amounts,
        bytes32[][] calldata merkleProofs
    ) external view returns (bool[] memory, uint256[] memory) {

        bool[] memory statuses = new bool[](amounts.length);
        uint256[] memory adjustedAmounts = new uint256[](amounts.length);

        if (treeIds.length != amounts.length || treeIds.length != merkleProofs.length || treeIds.length == 0) {
            return (statuses, adjustedAmounts);
        } else {
            for (uint256 i = 0; i < treeIds.length; i++) {
                if (treeIds[i] < numberTrees) {
                    (statuses[i], adjustedAmounts[i]) = _canClaim(user, treeIds[i], amounts[i], merkleProofs[i]);
                }
            }
            return (statuses, adjustedAmounts);
        }
    }

    function _canClaim(
        address user,
        uint8 treeId,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) internal view returns (bool, uint256) {

        bytes32 node = keccak256(abi.encodePacked(user, amount));
        bool canUserClaim = MerkleProof.verify(merkleProof, treeParameters[treeId].merkleRoot, node);

        if (!canUserClaim) {
            return (false, 0);
        } else {
            uint256 adjustedAmount = amount - amountClaimedByUserPerTreeId[user][treeId];
            return (true, adjustedAmount);
        }
    }
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
}