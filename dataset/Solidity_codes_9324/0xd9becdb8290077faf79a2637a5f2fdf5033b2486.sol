
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
}// UNLICENSED
pragma solidity ^0.8.6;

interface IVault {

    function vidyaRate() external view returns (uint256);


    function totalPriority() external view returns (uint256);


    function tellerPriority(address tellerId) external view returns (uint256);


    function addTeller(address teller, uint256 priority) external;


    function changePriority(address teller, uint256 newPriority) external;


    function payProvider(
        address provider,
        uint256 providerTimeWeight,
        uint256 totalWeight
    ) external;


    function calculateRateExternal() external;

}// UNLICENSED
pragma solidity ^0.8.6;


contract Teller is Ownable, ReentrancyGuard {

    using Address for address;
    using SafeERC20 for IERC20;

    event TellerDeployed();

    event TellerToggled(address teller, bool status);

    event NewCommitmentAdded(
        uint256 bonus,
        uint256 time,
        uint256 penalty,
        uint256 deciAdjustment
    );

    event CommitmentToggled(uint256 index, bool status);

    event PurposeSet(address devAddress, bool purposeStatus);

    event LpDeposited(address indexed provider, uint256 indexed amount);

    event Withdrew(address indexed provider, uint256 indexed amount);

    event Commited(address indexed provider, uint256 indexed commitedAmount);

    event CommitmentBroke(address indexed provider, uint256 indexed tokenSentAmount);

    event Claimed(address indexed provider, bool indexed success);

    struct Provider {
        uint256 LPDepositedRatio;
        uint256 userWeight;
        uint256 lastClaimedTime;
        uint256 commitmentIndex;
        uint256 committedAmount;
        uint256 commitmentEndTime;
    }

    struct Commitment {
        uint256 bonus;
        uint256 duration;
        uint256 penalty;
        uint256 deciAdjustment;
        bool isActive;
    }

    IVault public Vault;
    IERC20 public LpToken;

    uint256 public totalLP;
    uint256 public totalWeight;
    uint256 public tellerClosedTime;

    bool public tellerOpen;
    bool public purpose;

    address public devAddress;

    Commitment[] public commitmentInfo;

    mapping(address => Provider) public providerInfo;

    modifier isTellerOpen() {

        require(tellerOpen, "Teller: Teller is not open.");
        _;
    }

    modifier isProvider() {

        require(
            providerInfo[msg.sender].LPDepositedRatio != 0,
            "Teller: Caller is not a provider."
        );
        _;
    }

    modifier isTellerClosed() {

        require(!tellerOpen, "Teller: Teller is still active.");
        _;
    }

    constructor(IERC20 _LpToken, IVault _Vault) {
        LpToken = _LpToken;
        Vault = _Vault;
        commitmentInfo.push();

        emit TellerDeployed();
    }

    function toggleTeller() external onlyOwner {

        tellerOpen = !tellerOpen;
        tellerClosedTime = block.timestamp;
        emit TellerToggled(address(this), tellerOpen);
    }

    function addCommitment(
        uint256 _bonus,
        uint256 _days,
        uint256 _penalty,
        uint256 _deciAdjustment
    ) external onlyOwner {

        Commitment memory holder;

        holder.bonus = _bonus;
        holder.duration = _days * 1 days;
        holder.penalty = _penalty;
        holder.deciAdjustment = _deciAdjustment;
        holder.isActive = true;

        commitmentInfo.push(holder);

        emit NewCommitmentAdded(_bonus, _days, _penalty, _deciAdjustment);
    }

    function toggleCommitment(uint256 _index) external onlyOwner {

        require(
            0 < _index && _index < commitmentInfo.length,
            "Teller: Current index is not listed in the commitment array."
        );
        commitmentInfo[_index].isActive = !commitmentInfo[_index].isActive;

        emit CommitmentToggled(_index, commitmentInfo[_index].isActive);
    }

    function setPurpose(address _address, bool _status) external onlyOwner {

        purpose = _status;
        devAddress = _address;

        emit PurposeSet(devAddress, purpose);
    }

    function depositLP(uint256 _amount) external isTellerOpen {

        uint256 contractBalance = LpToken.balanceOf(address(this));
        LpToken.safeTransferFrom(msg.sender, address(this), _amount);

        Provider storage user = providerInfo[msg.sender];
        if (user.LPDepositedRatio != 0) {
            commitmentFinished();
            claim();
        } else {
            user.lastClaimedTime = block.timestamp;
        }
        if (contractBalance == totalLP || totalLP == 0) {
            user.LPDepositedRatio += _amount;
            totalLP += _amount;
        } else {
            uint256 _adjustedAmount = (_amount * totalLP) / contractBalance;
            user.LPDepositedRatio += _adjustedAmount;
            totalLP += _adjustedAmount;
        }

        user.userWeight += _amount;
        totalWeight += _amount;

        emit LpDeposited(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external isProvider nonReentrant {

        Provider storage user = providerInfo[msg.sender];
        uint256 contractBalance = LpToken.balanceOf(address(this));
        commitmentFinished();
        uint256 userTokens = (user.LPDepositedRatio * contractBalance) /
            totalLP;
        require(
            userTokens - user.committedAmount >= _amount,
            "Teller: Provider hasn't got enough deposited LP tokens to withdraw."
        );

        claim();

        uint256 _weightChange = (_amount * user.userWeight) / userTokens;
        user.userWeight -= _weightChange;
        totalWeight -= _weightChange;

        uint256 ratioChange = _amount * totalLP/contractBalance;
        user.LPDepositedRatio -= ratioChange;
        totalLP -= ratioChange;


        LpToken.safeTransfer(msg.sender, _amount);

        emit Withdrew(msg.sender, _amount);
    }

    function tellerClosedWithdraw() external isTellerClosed isProvider {

        uint256 contractBalance = LpToken.balanceOf(address(this));
        require(contractBalance != 0, "Teller: Contract balance is zero.");

        claim();

        Provider memory user = providerInfo[msg.sender];

        uint256 userTokens = (user.LPDepositedRatio * contractBalance) /
            totalLP;
        totalLP -= user.LPDepositedRatio;
        totalWeight -= user.userWeight;

        providerInfo[msg.sender] = Provider(0, 0, 0, 0, 0, 0);

        LpToken.safeTransfer(msg.sender, userTokens);

        emit Withdrew(msg.sender, userTokens);
    }

    function commit(uint256 _amount, uint256 _commitmentIndex)
        external
        nonReentrant
        isProvider
    {

        require(
            commitmentInfo[_commitmentIndex].isActive,
            "Teller: Current commitment is not active."
        );

        Provider storage user = providerInfo[msg.sender];
        commitmentFinished();
        uint256 contractBalance = LpToken.balanceOf(address(this));
        uint256 userTokens = (user.LPDepositedRatio * contractBalance) /
            totalLP;

        require(
            userTokens - user.committedAmount >= _amount,
            "Teller: Provider hasn't got enough deposited LP tokens to commit."
        );

        if (user.committedAmount != 0) {
            require(
                _commitmentIndex == user.commitmentIndex,
                "Teller: Commitment index is not the same as providers'."
            );
        }

        uint256 newEndTime;

        if (
            user.commitmentEndTime >= block.timestamp &&
            user.committedAmount != 0
        ) {
            newEndTime = calculateNewEndTime(
                user.committedAmount,
                _amount,
                user.commitmentEndTime,
                _commitmentIndex
            );
        } else {
            newEndTime =
                block.timestamp +
                commitmentInfo[_commitmentIndex].duration;
        }

        uint256 weightToGain = (_amount * user.userWeight) / userTokens;
        uint256 bonusCredit = commitBonus(_commitmentIndex, weightToGain);

        claim();

        user.commitmentIndex = _commitmentIndex;
        user.committedAmount += _amount;
        user.commitmentEndTime = newEndTime;
        user.userWeight += bonusCredit;
        totalWeight += bonusCredit;

        emit Commited(msg.sender, _amount);
    }

    function breakCommitment() external nonReentrant isProvider {

        Provider memory user = providerInfo[msg.sender];

        require(
            user.commitmentEndTime > block.timestamp,
            "Teller: No commitment to break."
        );

        uint256 contractBalance = LpToken.balanceOf(address(this));

        uint256 tokenToReceive = (user.LPDepositedRatio * contractBalance) /
            totalLP;

        Commitment memory currentCommit = commitmentInfo[user.commitmentIndex];
        
        uint256 fee = (user.committedAmount * currentCommit.penalty) /
            currentCommit.deciAdjustment;
            
        tokenToReceive -= fee;

        totalLP -= user.LPDepositedRatio;

        totalWeight -= user.userWeight;

        providerInfo[msg.sender] = Provider(0, 0, 0, 0, 0, 0);
        
        if (purpose) {
            LpToken.safeTransfer(devAddress, fee / 10);
        }
        
        LpToken.safeTransfer(msg.sender, tokenToReceive);

        emit CommitmentBroke(msg.sender, tokenToReceive);
    }

    function claim() internal {

        Provider storage user = providerInfo[msg.sender];
        uint256 timeGap = block.timestamp - user.lastClaimedTime;

        if (!tellerOpen) {
            timeGap = tellerClosedTime - user.lastClaimedTime;
        }

        if (timeGap > 365 * 1 days) {
            timeGap = 365 * 1 days;
        }

        uint256 timeWeight = timeGap * user.userWeight;

        user.lastClaimedTime = block.timestamp;

        Vault.payProvider(msg.sender, timeWeight, totalWeight);

        emit Claimed(msg.sender, true);
    }

    function commitBonus(uint256 _commitmentIndex, uint256 _amount)
        internal
        view
        returns (uint256)
    {

        if (commitmentInfo[_commitmentIndex].isActive) {
            return
                (commitmentInfo[_commitmentIndex].bonus * _amount) /
                commitmentInfo[_commitmentIndex].deciAdjustment;
        }
        return 0;
    }

    function calculateNewEndTime(
        uint256 _oldAmount,
        uint256 _extraAmount,
        uint256 _oldEndTime,
        uint256 _commitmentIndex
    ) internal view returns (uint256) {

        uint256 extraEndTIme = commitmentInfo[_commitmentIndex].duration +
            block.timestamp;
        uint256 newEndTime = ((_oldAmount * _oldEndTime) +
            (_extraAmount * extraEndTIme)) / (_oldAmount + _extraAmount);

        return newEndTime;
    }

    function commitmentFinished() internal {

        Provider storage user = providerInfo[msg.sender];
        if (user.commitmentEndTime <= block.timestamp) {
            user.committedAmount = 0;
            user.commitmentIndex = 0;
        }
    }

    function claimExternal() external isTellerOpen isProvider nonReentrant {

        commitmentFinished();
        claim();
    }

    function getUserInfo(address _user)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        Provider memory user = providerInfo[_user];

        if (user.LPDepositedRatio > 0) {
            uint256 claimAmount = (Vault.vidyaRate() *
                Vault.tellerPriority(address(this)) *
                (block.timestamp - user.lastClaimedTime) *
                user.userWeight) / (totalWeight * Vault.totalPriority());

            uint256 totalLPDeposited = (providerInfo[msg.sender]
                .LPDepositedRatio * LpToken.balanceOf(address(this))) / totalLP;

            if (user.commitmentEndTime > block.timestamp) {
                return (
                    user.commitmentEndTime - block.timestamp,
                    user.committedAmount,
                    user.commitmentIndex,
                    claimAmount,
                    totalLPDeposited
                );
            } else {
                return (0, 0, 0, claimAmount, totalLPDeposited);
            }
        } else {
            return (0, 0, 0, 0, 0);
        }
    }
}