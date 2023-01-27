
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

pragma solidity ^0.6.0;

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
}// MIT

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.2;

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
}// MIT

pragma solidity ^0.6.0;


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
}// MIT

pragma solidity ^0.6.0;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract QueenDecks is Ownable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    struct TermSheet {
        uint176 minAmount;
        uint32 maxAmountFactor;
        uint32 rewardFactor;
        uint16 lockHours;
        uint16 rewardLockHours;
        address token;
        bool enabled;
    }

    struct Stake {
        uint256 amount;
        uint32 unlockTime;
        uint32 lastRewardTime;
        uint32 rewardFactor; // see TermSheet.rewardFactor
        uint16 rewardLockHours; // see TermSheet.rewardLockHours
        uint16 lockHours; // see TermSheet.lockHours
    }

    struct UserStakes {
        uint256[] ids;
        mapping(uint256 => Stake) data;
    }

    bool public emergencyWithdrawEnabled = true;

    uint16 public emergencyFeesFactor = 500; // i.e. 5%

    uint48 public stakeQty;

    address public treasury;

    TermSheet[] internal termSheets;

    mapping(address => uint256) public amountsStaked; // in token units
    mapping(address => uint256) public amountsDue; // in token units

    mapping(address => UserStakes) internal stakes;

    event Deposit(
        address indexed token,
        address indexed user,
        uint256 stakeId,
        uint256 termsId,
        uint256 amount, // amount staked
        uint256 amountDue, // amount to be returned
        uint256 unlockTime // UNIX-time when the stake is unlocked
    );

    event Withdraw(
        address indexed user,
        uint256 stakeId,
        uint256 amount // amount sent to user (in token units)
    );

    event Reward(
        address indexed user,
        uint256 stakeId,
        uint256 amount // amount sent to user (in token units)
    );

    event Emergency(bool enabled);
    event EmergencyFactor(uint256 factor);

    event EmergencyWithdraw(
        address indexed user,
        uint256 stakeId,
        uint256 amount, // amount sent to user (in token units)
        uint256 reward, // cancelled reward (in token units)
        uint256 fees // withheld fees (in token units)
    );

    event NewTermSheet(
        uint256 indexed termsId, // index in the `termSheets` array
        address indexed token, // here and further - see `struct TermSheet`
        uint256 minAmount,
        uint256 maxAmountFactor,
        uint256 lockHours,
        uint256 rewardLockHours,
        uint256 rewardFactor
    );

    event TermsEnabled(uint256 indexed termsId);
    event TermsDisabled(uint256 indexed termsId);

    constructor(address _treasury) public {
        _setTreasury(_treasury);
    }

    receive() external payable {
        revert("QDeck:can't receive ethers");
    }

    function encodeStakeId(
        address token, // token contract address
        uint256 stakeNum, // uniq nonce (limited to 48 bits)
        uint256 unlockTime, // UNIX time (limited to 32 bits)
        uint256 stakeHours // Stake duration (limited to 16 bits)
    ) public pure returns (uint256) {

        require(stakeNum < 2**48, "QDeck:stakeNum_EXCEEDS_48_BITS");
        require(unlockTime < 2**32, "QDeck:unlockTime_EXCEEDS_32_BITS");
        require(stakeHours < 2**16, "QDeck:stakeHours_EXCEEDS_16_BITS");
        return _encodeStakeId(token, stakeNum, unlockTime, stakeHours);
    }

    function decodeStakeId(uint256 stakeId)
        public
        pure
        returns (
            address token,
            uint256 stakeNum,
            uint256 unlockTime,
            uint256 stakeHours
        )
    {

        token = address(stakeId >> 96);
        stakeNum = (stakeId >> 48) & (2**48 - 1);
        unlockTime = (stakeId >> 16) & (2**32 - 1);
        stakeHours = stakeId & (2**16 - 1);
    }

    function stakeIds(address user) external view returns (uint256[] memory) {

        _revertZeroAddress(user);
        UserStakes storage userStakes = stakes[user];
        return userStakes.ids;
    }

    function stakeData(address user, uint256 stakeId)
        external
        view
        returns (Stake memory)
    {

        return stakes[_nonZeroAddr(user)].data[stakeId];
    }

    function getAmountDue(address user, uint256 stakeId)
        external
        view
        returns (uint256 totalDue, uint256 rewardDue)
    {

        Stake memory stake = stakes[_nonZeroAddr(user)].data[stakeId];
        (totalDue, rewardDue) = _amountDueOn(stake, now);
    }

    function termSheet(uint256 termsId)
        external
        view
        returns (TermSheet memory)
    {

        return termSheets[_validTermsID(termsId)];
    }

    function termsLength() external view returns (uint256) {

        return termSheets.length;
    }

    function allTermSheets() external view returns(TermSheet[] memory) {

        return termSheets;
    }

    function deposit(uint256 termsId, uint256 amount) public nonReentrant {

        TermSheet memory tS = termSheets[_validTermsID(termsId)];
        require(tS.enabled, "deposit: terms disabled");

        require(amount >= tS.minAmount, "deposit: too small amount");
        if (tS.maxAmountFactor != 0) {
            require(
                amount <=
                    uint256(tS.minAmount).mul(tS.maxAmountFactor).div(1e4),
                "deposit: too big amount"
            );
        }

        uint48 stakeNum = stakeQty + 1;
        require(stakeNum != 0, "QDeck:stakeQty_OVERFLOW");

        uint256 amountDue = amount.mul(tS.rewardFactor).div(1e6);
        uint32 unlockTime = safe32(now.add(uint256(tS.lockHours) * 3600));

        uint256 stakeId = _encodeStakeId(tS.token, stakeNum, now, tS.lockHours);

        IERC20(tS.token).safeTransferFrom(msg.sender, treasury, amount);

        _addUserStake(
            stakes[msg.sender],
            stakeId,
            Stake(
                amount,
                unlockTime,
                safe32(now),
                tS.rewardFactor,
                tS.rewardLockHours,
                tS.lockHours
            )
        );
        stakeQty = stakeNum;
        amountsStaked[tS.token] = amountsStaked[tS.token].add(amount);
        amountsDue[tS.token] = amountsDue[tS.token].add(amountDue);

        emit Deposit(
            tS.token,
            msg.sender,
            stakeId,
            termsId,
            amount,
            amountDue,
            unlockTime
        );
    }

    function withdraw(uint256 stakeId) public nonReentrant {

        _withdraw(stakeId, false);
    }

    function withdrawReward(uint256 stakeId) public {

        _withdrawReward(stakeId);
    }

    function emergencyWithdraw(uint256 stakeId) public nonReentrant {

        _withdraw(stakeId, true);
    }

    function addTerms(TermSheet[] memory _termSheets) public onlyOwner {

        for (uint256 i = 0; i < _termSheets.length; i++) {
            _addTermSheet(_termSheets[i]);
        }
    }

    function enableTerms(uint256 termsId) external onlyOwner {

        termSheets[_validTermsID(termsId)].enabled = true;
        emit TermsEnabled(termsId);
    }

    function disableTerms(uint256 termsId) external onlyOwner {

        termSheets[_validTermsID(termsId)].enabled = false;
        emit TermsDisabled(termsId);
    }

    function enableEmergencyWithdraw() external onlyOwner {

        emergencyWithdrawEnabled = true;
        emit Emergency(true);
    }

    function disableEmergencyWithdraw() external onlyOwner {

        emergencyWithdrawEnabled = false;
        emit Emergency(false);
    }

    function setEmergencyFeesFactor(uint256 factor) external onlyOwner {

        require(factor < 5000, "QDeck:INVALID_factor"); // less then 50%
        emergencyFeesFactor = uint16(factor);
        emit EmergencyFactor(factor);
    }

    function setTreasury(address _treasury) public onlyOwner {

        _setTreasury(_treasury);
    }

    function transferFromContract(
        IERC20 token,
        uint256 amount,
        address to
    ) external onlyOwner {

        _revertZeroAddress(to);
        token.safeTransfer(to, amount);
    }

    function _withdraw(uint256 stakeId, bool isEmergency) internal {

        address token = _tokenFromId(stakeId);
        UserStakes storage userStakes = stakes[msg.sender];
        Stake memory stake = userStakes.data[stakeId];

        require(stake.amount != 0, "QDeck:unknown or returned stake");
        (uint256 amountDue, uint256 reward) = _amountDueOn(stake, now);

        uint256 amountToUser;
        if (isEmergency) {
            require(emergencyWithdrawEnabled, "withdraw: emergency disabled");
            uint256 fees = stake.amount.mul(emergencyFeesFactor).div(1e4);
            amountToUser = stake.amount.sub(fees);
            emit EmergencyWithdraw(
                msg.sender,
                stakeId,
                amountToUser,
                reward,
                fees
            );
        } else {
            require(now >= stake.unlockTime, "withdraw: stake is locked");
            amountToUser = amountDue;
            emit Withdraw(msg.sender, stakeId, amountToUser);
        }

        if (now > stake.lastRewardTime) {
            userStakes.data[stakeId].lastRewardTime = safe32(now);
        }

        _removeUserStake(userStakes, stakeId);
        amountsStaked[token] = amountsStaked[token].sub(stake.amount);
        amountsDue[token] = amountsDue[token].sub(amountDue);

        IERC20(token).safeTransferFrom(treasury, msg.sender, amountToUser);
    }

    function _withdrawReward(uint256 stakeId) internal {

        address token = _tokenFromId(stakeId);
        UserStakes storage userStakes = stakes[msg.sender];
        Stake memory stake = userStakes.data[stakeId];
        require(stake.amount != 0, "QDeck:unknown or returned stake");
        require(stake.rewardLockHours != 0, "QDeck:reward is locked");

        uint256 allowedTime = stake.lastRewardTime +
            stake.rewardLockHours *
            3600;
        require(now >= allowedTime, "QDeck:reward withdrawal not yet allowed");

        (, uint256 reward) = _amountDueOn(stake, now);
        if (reward == 0) return;

        stakes[msg.sender].data[stakeId].lastRewardTime = safe32(now);
        amountsDue[token] = amountsDue[token].sub(reward);

        IERC20(token).safeTransferFrom(treasury, msg.sender, reward);
        emit Reward(msg.sender, stakeId, reward);
    }

    function _amountDueOn (Stake memory stake, uint256 timestamp)
        internal
        pure
        returns (uint256 totalDue, uint256 rewardAccrued)
    {
        totalDue = stake.amount;
        rewardAccrued = 0;
        if (
            (stake.amount != 0) &&
            (timestamp > stake.lastRewardTime) &&
            (stake.lastRewardTime < stake.unlockTime)
        ) {
            uint256 end = timestamp > stake.unlockTime
                ? stake.unlockTime
                : timestamp;
            uint256 fullyDue = stake.amount.mul(stake.rewardFactor).div(1e6);

            rewardAccrued = fullyDue
                .sub(stake.amount)
                .mul(end.sub(stake.lastRewardTime))
                .div(uint256(stake.lockHours) * 3600);
            totalDue = totalDue.add(rewardAccrued);
        }
    }

    function _addTermSheet(TermSheet memory tS) internal {

        _revertZeroAddress(tS.token);
        require(
            tS.minAmount != 0 && tS.lockHours != 0 && tS.rewardFactor >= 1e6,
            "QDeck:add:INVALID_ZERO_PARAM"
        );
        require(_isMissingTerms(tS), "QDeck:add:TERMS_DUPLICATED");

        termSheets.push(tS);

        emit NewTermSheet(
            termSheets.length - 1,
            tS.token,
            tS.minAmount,
            tS.maxAmountFactor,
            tS.lockHours,
            tS.rewardLockHours,
            tS.rewardFactor
        );
        if (tS.enabled) emit TermsEnabled(termSheets.length);
    }

    function _isMissingTerms(TermSheet memory newSheet)
        internal
        view
        returns (bool)
    {

        for (uint256 i = 0; i < termSheets.length; i++) {
            TermSheet memory sheet = termSheets[i];
            if (
                sheet.token == newSheet.token &&
                sheet.minAmount == newSheet.minAmount &&
                sheet.maxAmountFactor == newSheet.maxAmountFactor &&
                sheet.lockHours == newSheet.lockHours &&
                sheet.rewardLockHours == newSheet.rewardLockHours &&
                sheet.rewardFactor == newSheet.rewardFactor
            ) {
                return false;
            }
        }
        return true;
    }

    function _addUserStake(
        UserStakes storage userStakes,
        uint256 stakeId,
        Stake memory stake
    ) internal {

        require(
            userStakes.data[stakeId].amount == 0,
            "QDeck:DUPLICATED_STAKE_ID"
        );
        userStakes.data[stakeId] = stake;
        userStakes.ids.push(stakeId);
    }

    function _removeUserStake(UserStakes storage userStakes, uint256 stakeId)
        internal
    {

        require(userStakes.data[stakeId].amount != 0, "QDeck:INVALID_STAKE_ID");
        userStakes.data[stakeId].amount = 0;
        _removeArrayElement(userStakes.ids, stakeId);
    }

    function _removeArrayElement(uint256[] storage arr, uint256 el) internal {

        uint256 lastIndex = arr.length - 1;
        if (lastIndex != 0) {
            uint256 replaced = arr[lastIndex];
            if (replaced != el) {
                do {
                    uint256 replacing = replaced;
                    replaced = arr[lastIndex - 1];
                    lastIndex--;
                    arr[lastIndex] = replacing;
                } while (replaced != el && lastIndex != 0);
            }
        }
        arr.pop();
    }

    function _setTreasury(address _treasury) internal {

        _revertZeroAddress(_treasury);
        treasury = _treasury;
    }

    function _encodeStakeId(
        address token,
        uint256 stakeNum,
        uint256 unlockTime,
        uint256 stakeHours
    ) internal pure returns (uint256) {

        require(stakeNum < 2**48, "QDeck:stakeNum_EXCEEDS_48_BITS");
        return
            (uint256(token) << 96) |
            (stakeNum << 48) |
            (unlockTime << 16) |
            stakeHours;
    }

    function _tokenFromId(uint256 stakeId) internal pure returns (address) {

        address token = address(stakeId >> 96);
        _revertZeroAddress(token);
        return token;
    }

    function _revertZeroAddress(address _address) internal pure {

        require(_address != address(0), "QDeck:ZERO_ADDRESS");
    }

    function _nonZeroAddr(address _address) private pure returns (address) {

        _revertZeroAddress(_address);
        return _address;
    }

    function _validTermsID(uint256 termsId) private view returns (uint256) {

        require(termsId < termSheets.length, "QDeck:INVALID_TERMS_ID");
        return termsId;
    }

    function safe32(uint256 n) private pure returns (uint32) {

        require(n < 2**32, "QDeck:UNSAFE_UINT32");
        return uint32(n);
    }
}