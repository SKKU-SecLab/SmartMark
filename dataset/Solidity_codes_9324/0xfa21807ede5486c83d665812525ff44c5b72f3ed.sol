
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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId
            || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
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
pragma solidity 0.8.3;

abstract contract BalanceTrackingMixin {
    struct DepositBalance {
        mapping(address => mapping(uint256 => uint256)) balances;
    }

    mapping(address => DepositBalance) private accountBalances;

    function _depositIntoAccount(
        address account,
        address contractAddress,
        uint256 tokenId,
        uint256 amount
    ) internal {
        uint256 newBalance = accountBalances[account].balances[contractAddress][tokenId] + amount;
        accountBalances[account].balances[contractAddress][tokenId] = newBalance;
    }

    function _depositIntoAccount(
        address account,
        address contractAddress,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) internal {
        require(tokenIds.length == amounts.length, "Length mismatch");

        for (uint256 i = 0; i < amounts.length; i++) {
            _depositIntoAccount(account, contractAddress, tokenIds[i], amounts[i]);
        }
    }

    function _withdrawFromAccount(
        address account,
        address contractAddress,
        uint256 tokenId,
        uint256 amount
    ) internal {
        require(accountBalances[account].balances[contractAddress][tokenId] >= amount, "Insufficient balance");
        uint256 newBalance = accountBalances[account].balances[contractAddress][tokenId] - amount;
        accountBalances[account].balances[contractAddress][tokenId] = newBalance;
    }

    function _withdrawFromAccount(
        address account,
        address contractAddress,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) internal {
        require(tokenIds.length == amounts.length, "Length mismatch");

        for (uint256 i = 0; i < amounts.length; i++) {
            _withdrawFromAccount(account, contractAddress, tokenIds[i], amounts[i]);
        }
    }

    function balanceOf(
        address account,
        address contractAddress,
        uint256 tokenId
    ) public view returns (uint256 balance) {
        require(account != address(0), "Zero address");
        return accountBalances[account].balances[contractAddress][tokenId];
    }

    function balanceOfBatch(
        address account,
        address[] memory contractAddresses,
        uint256[] memory tokenIds
    ) public view returns (uint256[] memory batchBalances) {
        require(contractAddresses.length == tokenIds.length, "Length mismatch");

        batchBalances = new uint256[](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; ++i) {
            batchBalances[i] = balanceOf(account, contractAddresses[i], tokenIds[i]);
        }
    }
}// MIT
pragma solidity 0.8.3;

abstract contract RewardTrackingMixin {
    struct AccountInfo {
        uint256 shares;
        uint256 rewardDebt;
    }

    uint256 public totalShares;

    uint256 private accumulatedRewardPerShare;

    mapping(address => AccountInfo) private accountRewards;

    function _addReward(uint256 amount) internal {
        if (totalShares == 0 || amount == 0) {
            return;
        }

        uint256 rewardPerShare = amount / totalShares;
        accumulatedRewardPerShare += rewardPerShare;
    }

    function _addShares(address account, uint256 amount) internal {
        totalShares += amount;

        accountRewards[account].shares += amount;
        _updateRewardDebtToCurrent(account);
    }

    function _removeShares(address account, uint256 amount) internal {
        require(amount <= accountRewards[account].shares, "Invalid account amount");
        require(amount <= totalShares, "Invalid global amount");

        totalShares -= amount;

        accountRewards[account].shares -= amount;
        _updateRewardDebtToCurrent(account);
    }

    function _resetRewardAccount(address account) internal {
        uint256 currentShares = accountRewards[account].shares;
        if (currentShares > 0) {
            totalShares -= currentShares;
            accountRewards[account].shares = 0;
            accountRewards[account].rewardDebt = 0;
        }
    }

    function _updateRewardDebtToCurrent(address account) internal {
        accountRewards[account].rewardDebt = accountRewards[account].shares * accumulatedRewardPerShare;
    }

    function accountPendingReward(address account) public view returns (uint256 pendingReward) {
        return accountRewards[account].shares * accumulatedRewardPerShare - accountRewards[account].rewardDebt;
    }

    function accountRewardShares(address account) public view returns (uint256 rewardShares) {
        return accountRewards[account].shares;
    }
}// MIT
pragma solidity 0.8.3;

abstract contract RestrictedPairsMixin {
    struct PairInfo {
        uint256 tokenIdA;
        uint256 tokenIdB;
        bool enabled;
    }

    address public tokenA;
    address public tokenB;

    uint256 public nextPairId;

    mapping(uint256 => PairInfo) public pairs;

    constructor(address tokenAddressA, address tokenAddressB) {
        tokenA = tokenAddressA;
        tokenB = tokenAddressB;
    }

    modifier onlyEnabledPair(uint256 pairId) {
        require(isPairEnabled(pairId), "Not enabled");
        _;
    }

    function isPairEnabled(uint256 pairId) public view returns (bool) {
        return pairs[pairId].enabled;
    }

    function _enablePairs(uint256[] memory pairIds, bool[] memory enabled) internal {
        require(pairIds.length == enabled.length, "Array lengths");

        for (uint256 i = 0; i < pairIds.length; i++) {
            pairs[pairIds[i]].enabled = enabled[i];
        }
    }

    function _addPairs(
        uint256[] memory tokenIdsA,
        uint256[] memory tokenIdsB,
        bool[] memory enabled
    ) internal {
        require(tokenIdsA.length == tokenIdsB.length && tokenIdsB.length == enabled.length, "Array lengths");
        for (uint256 i = 0; i < tokenIdsA.length; i++) {
            pairs[nextPairId] = PairInfo({tokenIdA: tokenIdsA[i], tokenIdB: tokenIdsB[i], enabled: enabled[i]});
            nextPairId = nextPairId + 1;
        }
    }

    function getAllPairs() external view returns (PairInfo[] memory results) {
        results = new PairInfo[](nextPairId);

        for (uint256 i = 0; i < nextPairId; i++) {
            results[i] = pairs[i];
        }
    }
}// MIT
pragma solidity 0.8.3;


abstract contract ERC1155Staker is ERC1155Holder {

    function _beforeDeposit(
        address account,
        address contractAddress,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {}

    function _beforeWithdraw(
        address account,
        address contractAddress,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {}

    function _depositSingle(
        address contractAddress,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {
        require(amount > 0, "Invalid amount");
        _beforeDeposit(msg.sender, contractAddress, tokenId, amount);
        IERC1155(contractAddress).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");
    }

    function _deposit(
        address contractAddress,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) internal virtual returns (uint256 totalTokensDeposited) {
        totalTokensDeposited = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(amounts[i] > 0, "Invalid amount");
            _beforeDeposit(msg.sender, contractAddress, tokenIds[i], amounts[i]);
            totalTokensDeposited += amounts[i];
        }

        IERC1155(contractAddress).safeBatchTransferFrom(msg.sender, address(this), tokenIds, amounts, "");
    }

    function _withdrawSingle(
        address contractAddress,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {
        require(amount > 0, "Invalid amount");
        _beforeWithdraw(msg.sender, contractAddress, tokenId, amount);
        IERC1155(contractAddress).safeTransferFrom(address(this), msg.sender, tokenId, amount, "");
    }

    function _withdraw(
        address contractAddress,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) internal virtual returns (uint256 totalTokensWithdrawn) {
        totalTokensWithdrawn = 0;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(amounts[i] > 0, "Invalid amount");
            _beforeWithdraw(msg.sender, contractAddress, tokenIds[i], amounts[i]);
            totalTokensWithdrawn += amounts[i];
        }

        IERC1155(contractAddress).safeBatchTransferFrom(address(this), msg.sender, tokenIds, amounts, "");
    }
}// MIT
pragma solidity 0.8.3;



contract EulerBeatsPairStaking is
    ERC1155Staker,
    BalanceTrackingMixin,
    RewardTrackingMixin,
    RestrictedPairsMixin,
    ReentrancyGuard,
    Ownable
{

    bool public emergency;
    uint256 public maxPairs;

    event RewardAdded(uint256 amount);
    event RewardClaimed(address indexed account, uint256 amount);

    event PairStaked(uint256 indexed pairId, address indexed account, uint256 amount);
    event PairUnstaked(uint256 indexed pairId, address indexed account, uint256 amount);

    event EmergencyUnstake(uint256 pairId, address indexed account, uint256 amount);

    constructor(address tokenAddressA, address tokenAddressB) RestrictedPairsMixin(tokenAddressA, tokenAddressB) {}

    function claimReward() external nonReentrant {

        claimRewardInternal();
    }

    function stake(uint256 pairId, uint256 amount) external onlyEnabledPair(pairId) nonReentrant {

        require(totalShares + amount <= maxPairs, "Max Pairs Exceeded");
        require(!emergency, "Not allowed");

        claimRewardInternal();

        depositPair(pairId, amount);

        _addShares(msg.sender, amount);
    }

    function unstake(uint256 pairId, uint256 amount) external nonReentrant {

        claimRewardInternal();

        withdrawPair(pairId, amount);

        _removeShares(msg.sender, amount);
    }

    function emergencyUnstake(uint256 pairId, uint256 amount) external nonReentrant {

        require(emergency, "Not allowed");
        require(amount > 0, "Invalid amount");

        _resetRewardAccount(msg.sender);

        withdrawPair(pairId, amount);

        emit EmergencyUnstake(pairId, msg.sender, amount);
    }

    function addReward() external payable {

        require(msg.value > 0, "No ETH sent");
        require(totalShares > 0, "No stakers");
        _addReward(msg.value);
        emit RewardAdded(msg.value);
    }



    function _beforeDeposit(
        address account,
        address contractAddress,
        uint256 tokenId,
        uint256 amount
    ) internal virtual override {

        _depositIntoAccount(account, contractAddress, tokenId, amount);
    }

    function _beforeWithdraw(
        address account,
        address contractAddress,
        uint256 tokenId,
        uint256 amount
    ) internal virtual override {

        _withdrawFromAccount(account, contractAddress, tokenId, amount);
    }



    function numStakedPairs() external view returns (uint256) {

        return totalShares;
    }



    function claimRewardInternal() internal {

        uint256 currentReward = accountPendingReward(msg.sender);
        if (currentReward > 0) {
            _updateRewardDebtToCurrent(msg.sender);

            uint256 amount;
            if (currentReward > address(this).balance) {
                amount = address(this).balance;
            } else {
                amount = currentReward;
            }
            Address.sendValue(payable(msg.sender), amount);
            emit RewardClaimed(msg.sender, amount);
        }
    }

    function depositPair(uint256 pairId, uint256 amount) internal {

        PairInfo memory pair = pairs[pairId];
        _depositSingle(tokenA, pair.tokenIdA, amount);
        _depositSingle(tokenB, pair.tokenIdB, amount);
        emit PairStaked(pairId, msg.sender, amount);
    }

    function withdrawPair(uint256 pairId, uint256 amount) internal {

        PairInfo memory pair = pairs[pairId];
        _withdrawSingle(tokenA, pair.tokenIdA, amount);
        _withdrawSingle(tokenB, pair.tokenIdB, amount);
        emit PairUnstaked(pairId, msg.sender, amount);
    }



    function addPairs(
        uint256[] memory tokenIdA,
        uint256[] memory tokenIdB,
        bool[] memory enabled
    ) external onlyOwner {

        _addPairs(tokenIdA, tokenIdB, enabled);
    }

    function enablePairs(uint256[] memory pairIds, bool[] memory enabled) external onlyOwner {

        _enablePairs(pairIds, enabled);
    }

    function setMaxPairs(uint256 amount) external onlyOwner {

        maxPairs = amount;
    }

    function withdrawUnclaimed() external onlyOwner {

        require(totalShares == 0, "Stakers");
        if (address(this).balance > 0) {
            Address.sendValue(payable(msg.sender), address(this).balance);
        }
    }

    function setEmergency(bool value) external onlyOwner {

        emergency = value;
    }

}