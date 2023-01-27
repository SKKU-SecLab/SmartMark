
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

library AddressUpgradeable {

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
}// GPL-3.0-only

pragma solidity ^0.8.0;


contract CollectorStakingPoolV2 is Initializable, OwnableUpgradeable {

    using SafeERC20 for IERC20;

    uint256 private constant DIV_PRECISION = 1e18;

    struct PendingRewardResult {
        uint256 intervalId;
        uint256 reward;
    }

    struct PendingRewardRequest {
        uint256 intervalId;
        uint256 points;
        uint256 totalPoints;
    }

    struct UserData {
        uint256 lastHarvestedInterval;
    }

    struct Interval {
        uint256 rewardAmount;
        uint256 claimedRewardAmount;
    }

    IERC20 private token;

    uint256 public expireAfter;
    uint256 public intervalLengthInSec;

    address trustedSigner;

    uint256 public nextIntervalTimestamp;
    uint256 public intervalIdCounter;
    mapping(uint256 => Interval) idToInterval;

    mapping(uint256 => UserData) userIdToUserData;

    event AddRewards(uint256 amount);
    event IntervalClosed(uint256 newInterval);
    event RedistributeRewards(uint256 unclaimedRewards);

    function initialize(
        IERC20 _token,
        uint256 _expireAfter,
        uint256 _intervalLengthInSec,
        uint256 endOfFirstInterval,
        address _trustedSigner
    ) public initializer {

        intervalIdCounter = 1;
        token = _token;
        expireAfter = _expireAfter;
        intervalLengthInSec = _intervalLengthInSec;
        nextIntervalTimestamp = endOfFirstInterval;
        trustedSigner = _trustedSigner;
        OwnableUpgradeable.__Ownable_init();
    }

    function setExpireAfter(uint256 _expireAfter) external onlyOwner {

        if (isNextIntervalReached()) {
            closeCurrentInterval();
        }
        if (_expireAfter < expireAfter && intervalIdCounter > _expireAfter) {
            uint256 iStart = 1;
            if (intervalIdCounter > expireAfter) {
                iStart = intervalIdCounter - expireAfter;
            }
            for (uint256 i = iStart; i < intervalIdCounter - _expireAfter; i++) {
                redistributeRewards(i);
            }
        }
        expireAfter = _expireAfter;
    }

    function redistributeRewards(uint256 intervalId) private {

        Interval memory oldInterval = idToInterval[intervalId];
        if (oldInterval.rewardAmount > 0) {
            uint256 unclaimedRewards = oldInterval.rewardAmount - oldInterval.claimedRewardAmount;
            if (unclaimedRewards > 0) {
                idToInterval[intervalIdCounter].rewardAmount += unclaimedRewards;
                emit RedistributeRewards(unclaimedRewards);
            }
            delete idToInterval[intervalId];
        }
    }

    function setTrustedSigner(address _trustedSigner) external onlyOwner {

        trustedSigner = _trustedSigner;
    }

    function setIntervalLengthInSec(uint256 _intervalLengthInSec) external onlyOwner {

        intervalLengthInSec = _intervalLengthInSec;
    }

    function isNextIntervalReached() private view returns (bool) {

        return block.timestamp >= nextIntervalTimestamp;
    }

    function addRewards(uint256 amount) external {

        require(amount > 0, "Amount must be greater than zero");
        if (isNextIntervalReached()) {
            closeCurrentInterval();
        }
        token.safeTransferFrom(msg.sender, address(this), amount);
        idToInterval[intervalIdCounter].rewardAmount += amount;
        emit AddRewards(amount);
    }

    function closeCurrentInterval() private {

        ++intervalIdCounter;
        nextIntervalTimestamp += intervalLengthInSec;
        if (intervalIdCounter > expireAfter) {
            redistributeRewards(intervalIdCounter - expireAfter);
        }
        emit IntervalClosed(intervalIdCounter - 1);
    }

    function splitSignature(bytes memory signature) private pure returns (uint8, bytes32, bytes32) {

        bytes32 sigR;
        bytes32 sigS;
        uint8 sigV;
        assembly {
            sigR := mload(add(signature, 32))
            sigS := mload(add(signature, 64))
            sigV := byte(0, mload(add(signature, 96)))
        }
        return (sigV, sigR, sigS);
    }

    function signatureVerification(
        uint256 userId,
        address[] memory userWallets,
        uint256[] memory harvestRequests,
        bytes memory signature
    )
    private
    returns (bool)
    {

        bytes32 sigR;
        bytes32 sigS;
        uint8 sigV;
        (sigV, sigR, sigS) = splitSignature(signature);
        bytes32 msg = keccak256(abi.encodePacked(userId, userWallets, harvestRequests));
        return trustedSigner == ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", msg)), sigV, sigR, sigS);
    }

    function harvest(
        uint256 userId,
        address[] memory userWallets,
        uint256[] memory harvestRequests,
        bytes memory signature
    )
    external
    {

        bool senderAssociatedWithTheUser = false;
        for (uint i = 0; i < userWallets.length && !senderAssociatedWithTheUser; i++) {
            senderAssociatedWithTheUser = msg.sender == userWallets[i];
        }
        require(
            senderAssociatedWithTheUser,
            "Sender is not associated with the user"
        );
        require(
            signatureVerification(userId, userWallets, harvestRequests, signature),
            "Invalid signer or signature"
        );
        if (isNextIntervalReached()) {
            closeCurrentInterval();
        }

        uint256 totalRewards = 0;
        for (uint i = 0; i < harvestRequests.length; i += 2) {
            uint256 intervalId = harvestRequests[i];
            require(
                userIdToUserData[userId].lastHarvestedInterval < intervalId,
                "Tried to harvest already harvested interval"
            );
            require(
                intervalIdCounter < intervalId + expireAfter,
                "Tried to harvest expired interval"
            );
            uint256 reward = harvestRequests[i + 1];
            userIdToUserData[userId].lastHarvestedInterval = intervalId;
            idToInterval[intervalId].claimedRewardAmount += reward;
            totalRewards += reward;
        }
        token.safeTransfer(msg.sender, totalRewards);
    }

    function isExpiredButNotProcessed(uint256 intervalId) private view returns (bool) {

        return isNextIntervalReached()
                && intervalIdCounter + 1 > expireAfter
                && intervalIdCounter - expireAfter == intervalId;
    }

    function pendingRewards(uint256 userId, PendingRewardRequest[] memory pendingRewardRequests)
    external
    view
    returns (PendingRewardResult[] memory)
    {

        uint256 lastHarvestedInterval = userIdToUserData[userId].lastHarvestedInterval;
        PendingRewardResult[] memory rewards = new PendingRewardResult[](pendingRewardRequests.length);
        for (uint i = 0; i < pendingRewardRequests.length; i++) {
            PendingRewardRequest memory request = pendingRewardRequests[i];
            if (
                lastHarvestedInterval < request.intervalId
                && (request.intervalId < intervalIdCounter || (request.intervalId == intervalIdCounter && isNextIntervalReached()))
                && !isExpiredButNotProcessed(request.intervalId)
            ) {
                rewards[i] = PendingRewardResult(
                    request.intervalId,
                    calculateReward(idToInterval[request.intervalId].rewardAmount, request.totalPoints, request.points)
                );
            } else {
                rewards[i] = PendingRewardResult(request.intervalId, 0);
            }
        }
        return rewards;
    }

    function calculateReward(uint256 intervalRewardAmount, uint256 totalPointsForTheInterval, uint256 points)
    private
    view
    returns (uint256)
    {

        return intervalRewardAmount * DIV_PRECISION / totalPointsForTheInterval * points / DIV_PRECISION;
    }

    function getLastHarvestedInterval(uint256 userId)
    external
    view
    returns (uint256)
    {

        return userIdToUserData[userId].lastHarvestedInterval;
    }

    function recoverToken(address _token, uint256 amount) external onlyOwner {

        IERC20(_token).safeTransfer(_msgSender(), amount);
    }
}