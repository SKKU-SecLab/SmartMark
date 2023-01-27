
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
pragma solidity ^0.8.4;


interface IVotingEscrow {


    struct LockedBalance {
        int128 amount;
        uint256 end;
    }
    
    function balanceOf(address _account) external view returns (uint256);


    function locked(address _account) external view returns (LockedBalance memory);


    function create_lock(uint256 _value, uint256 _unlock_time) external returns (uint256);


    function increase_amount(uint256 _value) external;


    function increase_unlock_time(uint256 _unlock_time) external;


    function locked__end(address _addr) external view returns (uint256);


}// MIT
pragma solidity ^0.8.4;


interface IVotingEscrowDelegation {


    function isApprovedForAll(address owner, address operator) external view returns(bool);


    function ownerOf(uint256 tokenId) external view returns(address);


    function balanceOf(uint256 tokenId) external view returns(uint256);


    function token_of_delegator_by_index(address delegator, uint256 index) external view returns(uint256);


    function total_minted(address delegator) external view returns(uint256);


    function grey_list(address receiver, address delegator) external view returns(bool);


    function setApprovalForAll(address _operator, bool _approved) external;


    function create_boost(
        address _delegator,
        address _receiver,
        int256 _percentage,
        uint256 _cancel_time,
        uint256 _expire_time,
        uint256 _id
    ) external;


    function extend_boost(
        uint256 _token_id,
        int256 _percentage,
        uint256 _cancel_time,
        uint256 _expire_time
    ) external;


    function burn(uint256 _token_id) external;


    function cancel_boost(uint256 _token_id) external;


    function batch_cancel_boosts(uint256[256] memory _token_ids) external;


    function adjusted_balance_of(address _account) external view returns(uint256);


    function delegated_boost(address _account) external view returns(uint256);


    function token_boost(uint256 _token_id) external view returns(int256);


    function token_cancel_time(uint256 _token_id) external view returns(uint256);


    function token_expiry(uint256 _token_id) external view returns(uint256);


    function get_token_id(address _delegator, uint256 _id) external view returns(uint256);


}// MIT
pragma solidity ^0.8.4;


contract Warden is Ownable, Pausable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    uint256 public constant UNIT = 1e18;
    uint256 public constant MAX_PCT = 10000;
    uint256 public constant WEEK = 7 * 86400;


    struct BoostOffer {
        address user;
        uint256 pricePerVote;
        uint16 minPerc; //bps
        uint16 maxPerc; //bps
    }

    IERC20 public feeToken;
    IVotingEscrow public votingEscrow;
    IVotingEscrowDelegation public delegationBoost;

    uint256 public feeReserveRatio; //bps
    uint256 public reserveAmount;
    address public reserveManager;

    uint256 public minPercRequired; //bps

    uint256 public minDelegationTime = 1 weeks;

    BoostOffer[] public offers;

    mapping(address => uint256) public userIndex;

    mapping(address => uint256) public earnedFees;

    bool private _claimBlocked;


    event Registred(address indexed user, uint256 price);

    event UpdateOffer(address indexed user, uint256 newPrice);

    event Quit(address indexed user);

    event BoostPurchase(
        address indexed delegator,
        address indexed receiver,
        uint256 tokenId,
        uint256 percent, //bps
        uint256 price,
        uint256 paidFeeAmount,
        uint256 expiryTime
    );

    event Claim(address indexed user, uint256 amount);

    modifier onlyAllowed(){

        require(msg.sender == reserveManager || msg.sender == owner(), "Warden: Not allowed");
        _;
    }

    constructor(
        address _feeToken,
        address _votingEscrow,
        address _delegationBoost,
        uint256 _feeReserveRatio, //bps
        uint256 _minPercRequired //bps
    ) {
        feeToken = IERC20(_feeToken);
        votingEscrow = IVotingEscrow(_votingEscrow);
        delegationBoost = IVotingEscrowDelegation(_delegationBoost);

        require(_feeReserveRatio <= 5000);
        require(_minPercRequired > 0 && _minPercRequired <= 10000);
        feeReserveRatio = _feeReserveRatio;
        minPercRequired = _minPercRequired;

        offers.push(BoostOffer(address(0), 0, 0, 0));
    }


    function offersIndex() external view returns(uint256){

        return offers.length;
    }

    function register(
        uint256 pricePerVote,
        uint16 minPerc,
        uint16 maxPerc
    ) external whenNotPaused returns(bool) {

        address user = msg.sender;
        require(userIndex[user] == 0, "Warden: Already registered");
        require(
            delegationBoost.isApprovedForAll(user, address(this)),
            "Warden: Not operator for caller"
        );

        require(pricePerVote > 0, "Warden: Price cannot be 0");
        require(maxPerc <= 10000, "Warden: maxPerc too high");
        require(minPerc <= maxPerc, "Warden: minPerc is over maxPerc");
        require(minPerc >= minPercRequired, "Warden: minPerc too low");

        userIndex[user] = offers.length;
        offers.push(BoostOffer(user, pricePerVote, minPerc, maxPerc));

        emit Registred(user, pricePerVote);

        return true;
    }

    function updateOffer(
        uint256 pricePerVote,
        uint16 minPerc,
        uint16 maxPerc
    ) external whenNotPaused returns(bool) {

        address user = msg.sender;
        uint256 index = userIndex[user];
        require(index != 0, "Warden: Not registered");

        BoostOffer storage offer = offers[index];

        require(offer.user == msg.sender, "Warden: Not offer owner");

        require(pricePerVote > 0, "Warden: Price cannot be 0");
        require(maxPerc <= 10000, "Warden: maxPerc too high");
        require(minPerc <= maxPerc, "Warden: minPerc is over maxPerc");
        require(minPerc >= minPercRequired, "Warden: minPerc too low");

        offer.pricePerVote = pricePerVote;
        offer.minPerc = minPerc;
        offer.maxPerc = maxPerc;

        emit UpdateOffer(user, pricePerVote);

        return true;
    }

    function quit() external whenNotPaused nonReentrant returns(bool) {

        address user = msg.sender;
        require(userIndex[user] != 0, "Warden: Not registered");

        if (earnedFees[user] > 0) {
            _claim(user, earnedFees[user]);
        }

        uint256 currentIndex = userIndex[user];
        if (currentIndex < offers.length) {
            uint256 lastIndex = offers.length - 1;
            address lastUser = offers[lastIndex].user;
            offers[currentIndex] = offers[lastIndex];
            userIndex[lastUser] = currentIndex;
        }
        offers.pop();
        userIndex[user] = 0;

        emit Quit(user);

        return true;
    }

    function estimateFees(
        address delegator,
        uint256 percent,
        uint256 duration //in weeks
    ) external view returns (uint256) {

        require(delegator != address(0), "Warden: Zero address");
        require(userIndex[delegator] != 0, "Warden: Not registered");
        require(
            percent >= minPercRequired,
            "Warden: Percent under min required"
        );
        require(percent <= MAX_PCT, "Warden: Percent over 100");

        uint256 durationSeconds = duration * 1 weeks;
        require(
            durationSeconds >= minDelegationTime,
            "Warden: Duration too short"
        );

        BoostOffer storage offer = offers[userIndex[delegator]];

        require(
            percent >= offer.minPerc && percent <= offer.maxPerc,
            "Warden: Percent out of Offer bounds"
        );
        uint256 expiryTime = ((block.timestamp + durationSeconds) / WEEK) * WEEK;
        expiryTime = (expiryTime < block.timestamp + durationSeconds) ?
            ((block.timestamp + durationSeconds + WEEK) / WEEK) * WEEK :
            expiryTime;
        require(
            expiryTime <= votingEscrow.locked__end(delegator),
            "Warden: Lock expires before Boost"
        );

        uint256 delegatorBalance = votingEscrow.balanceOf(delegator);
        uint256 toDelegateAmount = (delegatorBalance * percent) / MAX_PCT;

        uint256 priceForAmount = (toDelegateAmount * offer.pricePerVote) / UNIT;

        return priceForAmount * durationSeconds;
    }

    struct BuyVars {
        uint256 boostDuration;
        uint256 delegatorBalance;
        uint256 toDelegateAmount;
        uint256 realFeeAmount;
        uint256 expiryTime;
        uint256 cancelTime;
        uint256 boostPercent;
        uint256 newId;
        uint256 newTokenId;
    }

    function buyDelegationBoost(
        address delegator,
        address receiver,
        uint256 percent,
        uint256 duration, //in weeks
        uint256 maxFeeAmount
    ) external nonReentrant whenNotPaused returns(uint256) {

        require(
            delegator != address(0) && receiver != address(0),
            "Warden: Zero address"
        );
        require(userIndex[delegator] != 0, "Warden: Not registered");
        require(maxFeeAmount > 0, "Warden: No fees");
        require(
            percent >= minPercRequired,
            "Warden: Percent under min required"
        );
        require(percent <= MAX_PCT, "Warden: Percent over 100");

        BuyVars memory vars;

        vars.boostDuration = duration * 1 weeks;
        require(
            vars.boostDuration >= minDelegationTime,
            "Warden: Duration too short"
        );

        BoostOffer storage offer = offers[userIndex[delegator]];

        require(
            percent >= offer.minPerc && percent <= offer.maxPerc,
            "Warden: Percent out of Offer bounds"
        );

        vars.delegatorBalance = votingEscrow.balanceOf(delegator);
        vars.toDelegateAmount = (vars.delegatorBalance * percent) / MAX_PCT;

        require(
            _canDelegate(delegator, vars.toDelegateAmount, offer.maxPerc),
            "Warden: Cannot delegate"
        );

        vars.realFeeAmount = (vars.toDelegateAmount * offer.pricePerVote * vars.boostDuration) / UNIT;
        require(
            vars.realFeeAmount <= maxFeeAmount,
            "Warden: Fees do not cover Boost duration"
        );

        _pullFees(msg.sender, vars.realFeeAmount, delegator);

        vars.expiryTime = ((block.timestamp + vars.boostDuration) / WEEK) * WEEK;

        vars.expiryTime = (vars.expiryTime < block.timestamp + vars.boostDuration) ?
            ((block.timestamp + vars.boostDuration + WEEK) / WEEK) * WEEK :
            vars.expiryTime;
        require(
            vars.expiryTime <= votingEscrow.locked__end(delegator),
            "Warden: Lock expires before Boost"
        );

        vars.boostPercent = (vars.toDelegateAmount * MAX_PCT) / 
            (vars.delegatorBalance - delegationBoost.delegated_boost(delegator));

        vars.newId = delegationBoost.total_minted(delegator);
        unchecked {
            vars.cancelTime = block.timestamp + vars.boostDuration;
        }

        delegationBoost.create_boost(
            delegator,
            receiver,
            int256(vars.boostPercent),
            vars.cancelTime,
            vars.expiryTime,
            vars.newId
        );

        vars.newTokenId = delegationBoost.get_token_id(delegator, vars.newId);
        require(
            vars.newTokenId ==
                delegationBoost.token_of_delegator_by_index(delegator, vars.newId),
            "Warden: DelegationBoost failed"
        );

        emit BoostPurchase(
            delegator,
            receiver,
            vars.newTokenId,
            percent,
            offer.pricePerVote,
            vars.realFeeAmount,
            vars.expiryTime
        );

        return vars.newTokenId;
    }

    function cancelDelegationBoost(uint256 tokenId) external whenNotPaused returns(bool) {

        address tokenOwner = delegationBoost.ownerOf(tokenId);
        if (
            msg.sender == tokenOwner &&
            delegationBoost.isApprovedForAll(tokenOwner, address(this))
        ) {
            delegationBoost.burn(tokenId);
            return true;
        }

        uint256 currentTime = block.timestamp;

        address delegator = _getTokenDelegator(tokenId);
        if (
            delegationBoost.token_cancel_time(tokenId) < currentTime &&
            (msg.sender == delegator &&
                delegationBoost.isApprovedForAll(delegator, address(this)))
        ) {
            delegationBoost.cancel_boost(tokenId);
            return true;
        }

        if (delegationBoost.token_expiry(tokenId) < currentTime) {
            delegationBoost.cancel_boost(tokenId);
            return true;
        }

        revert("Cannot cancel the boost");
    }

    function claimable(address user) external view returns (uint256) {

        return earnedFees[user];
    }

    function claim() external nonReentrant returns(bool) {

        require(
            earnedFees[msg.sender] != 0,
            "Warden: Claim null amount"
        );
        return _claim(msg.sender, earnedFees[msg.sender]);
    }

    function claimAndCancel() external nonReentrant returns(bool) {

        _cancelAllExpired(msg.sender);
        return _claim(msg.sender, earnedFees[msg.sender]);
    }

    function claim(uint256 amount) external nonReentrant returns(bool) {

        require(amount <= earnedFees[msg.sender], "Warden: Amount too high");
        require(
            amount != 0,
            "Warden: Claim null amount"
        );
        return _claim(msg.sender, amount);
    }

    function _pullFees(
        address buyer,
        uint256 amount,
        address seller
    ) internal {

        feeToken.safeTransferFrom(buyer, address(this), amount);

        earnedFees[seller] += (amount * (MAX_PCT - feeReserveRatio)) / MAX_PCT;
        reserveAmount += (amount * feeReserveRatio) / MAX_PCT;
    }

    function _canDelegate(
        address delegator,
        uint256 amount,
        uint256 delegatorMaxPerc
    ) internal returns (bool) {

        if (!delegationBoost.isApprovedForAll(delegator, address(this)))
            return false;

        uint256 balance = votingEscrow.balanceOf(delegator);

        uint256 blockedBalance = (balance * (MAX_PCT - delegatorMaxPerc)) / MAX_PCT;

        uint256 availableBalance = balance - blockedBalance;
        uint256 delegatedBalance = delegationBoost.delegated_boost(delegator);

        if(availableBalance > delegatedBalance){
            if(amount <= (availableBalance - delegatedBalance)) return true;
        }

        uint256 potentialCancelableBalance = 0;

        uint256 nbTokens = delegationBoost.total_minted(delegator);
        uint256[256] memory toCancel; //Need this type of array because of batch_cancel_boosts() from veBoost
        uint256 nbToCancel = 0;

        for (uint256 i = 0; i < nbTokens; i++) {
            uint256 tokenId = delegationBoost.token_of_delegator_by_index(
                delegator,
                i
            );

            if (delegationBoost.token_cancel_time(tokenId) <= block.timestamp && delegationBoost.token_cancel_time(tokenId) != 0) {
                int256 boost = delegationBoost.token_boost(tokenId);
                uint256 absolute_boost = boost >= 0 ? uint256(boost) : uint256(-boost);
                potentialCancelableBalance += absolute_boost;
                toCancel[nbToCancel] = tokenId;
                nbToCancel++;
            }
        }

        if (availableBalance < (delegatedBalance - potentialCancelableBalance)) return false;
        if (amount <= (availableBalance - (delegatedBalance - potentialCancelableBalance)) && nbToCancel > 0) {
            delegationBoost.batch_cancel_boosts(toCancel);
            return true;
        }

        return false;
    }

    function _cancelAllExpired(address delegator) internal {

        uint256 nbTokens = delegationBoost.total_minted(delegator);
        if (nbTokens == 0) return;

        uint256[256] memory toCancel;
        uint256 nbToCancel = 0;
        uint256 currentTime = block.timestamp;

        for (uint256 i = 0; i < nbTokens; i++) {
            uint256 tokenId = delegationBoost.token_of_delegator_by_index(
                delegator,
                i
            );
            uint256 cancelTime = delegationBoost.token_cancel_time(tokenId);

            if (cancelTime <= currentTime && cancelTime != 0) {
                toCancel[nbToCancel] = tokenId;
                nbToCancel++;
            }
        }

        if (nbToCancel > 0) {
            delegationBoost.batch_cancel_boosts(toCancel);
        }
    }

    function _claim(address user, uint256 amount) internal returns(bool) {

        require(
            !_claimBlocked,
            "Warden: Claim blocked"
        );
        require(
            amount <= feeToken.balanceOf(address(this)),
            "Warden: Insufficient cash"
        );

        if(amount == 0) return true; // nothing to claim, but used in claimAndCancel()

        unchecked{
            earnedFees[user] -= amount;
        }

        feeToken.safeTransfer(user, amount);

        emit Claim(user, amount);

        return true;
    }

    function _getTokenDelegator(uint256 tokenId)
        internal
        pure
        returns (address)
    {

        return address(uint160(tokenId >> 96));
    }


    function setMinPercRequired(uint256 newMinPercRequired) external onlyOwner {

        require(newMinPercRequired > 0 && newMinPercRequired <= 10000);
        minPercRequired = newMinPercRequired;
    }

    function setMinDelegationTime(uint256 newMinDelegationTime) external onlyOwner {

        require(newMinDelegationTime > 0);
        minDelegationTime = newMinDelegationTime;
    }

    function setFeeReserveRatio(uint256 newFeeReserveRatio) external onlyOwner {

        require(newFeeReserveRatio <= 5000);
        feeReserveRatio = newFeeReserveRatio;
    }

    function setDelegationBoost(address newDelegationBoost) external onlyOwner {

        delegationBoost = IVotingEscrowDelegation(newDelegationBoost);
    }

    function setReserveManager(address newReserveManager) external onlyOwner {

        reserveManager = newReserveManager;
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }

    function blockClaim() external onlyOwner {

        require(
            !_claimBlocked,
            "Warden: Claim blocked"
        );
        _claimBlocked = true;
    }

    function unblockClaim() external onlyOwner {

        require(
            _claimBlocked,
            "Warden: Claim not blocked"
        );
        _claimBlocked = false;
    }

    function withdrawERC20(address token, uint256 amount) external onlyOwner returns(bool) {

        require(_claimBlocked || token != address(feeToken), "Warden: cannot withdraw fee Token"); //We want to be able to recover the fees if there is an issue
        IERC20(token).safeTransfer(owner(), amount);

        return true;
    }

    function depositToReserve(address from, uint256 amount) external onlyAllowed returns(bool) {

        reserveAmount = reserveAmount + amount;
        feeToken.safeTransferFrom(from, address(this), amount);

        return true;
    }

    function withdrawFromReserve(uint256 amount) external onlyAllowed returns(bool) {

        require(amount <= reserveAmount, "Warden: Reserve too low");
        reserveAmount = reserveAmount - amount;
        feeToken.safeTransfer(reserveManager, amount);

        return true;
    }
}// MIT
pragma solidity ^0.8.4;


contract WardenMultiBuy is Ownable {

    using SafeERC20 for IERC20;

    uint256 public constant UNIT = 1e18;
    uint256 public constant MAX_PCT = 10000;
    uint256 public constant WEEK = 7 * 86400;

    IERC20 public feeToken;
    IVotingEscrow public votingEscrow;
    IVotingEscrowDelegation public delegationBoost;
    Warden public warden;


    constructor(
        address _feeToken,
        address _votingEscrow,
        address _delegationBoost,
        address _warden
    ) {
        feeToken = IERC20(_feeToken);
        votingEscrow = IVotingEscrow(_votingEscrow);
        delegationBoost = IVotingEscrowDelegation(_delegationBoost);
        warden = Warden(_warden);
    }


    struct MultiBuyVars {
        uint256 weeksDuration;
        uint256 boostDuration;
        uint256 totalNbOffers;
        uint256 boostEndTime;
        uint256 expiryTime;
        uint256 previousBalance;
        uint256 endBalance;
        uint256 missingAmount;
        uint256 boughtAmount;
        uint256 wardenMinRequiredPercent;
    }

    struct OfferVars {
        uint256 availableUserBalance;
        uint256 toBuyAmount;
        address delegator;
        uint256 offerPrice;
        uint256 offerminPercent;
        uint256 boostFeeAmount;
        uint256 boostPercent;
        uint256 newTokenId;
    }

    function simpleMultiBuy(
        address receiver,
        uint256 duration, //in number of weeks
        uint256 boostAmount,
        uint256 maxPrice,
        uint256 minRequiredAmount,
        uint256 totalFeesAmount,
        uint256 acceptableSlippage, //BPS
        bool clearExpired
    ) external returns (bool) {

        require(
            receiver != address(0),
            "Zero address"
        );
        require(boostAmount != 0 && totalFeesAmount != 0 && acceptableSlippage != 0, "Null value");
        require(maxPrice != 0, "Null price");

        MultiBuyVars memory vars;

        vars.boostDuration = duration * 1 weeks;
        require(vars.boostDuration >= warden.minDelegationTime(), "Duration too short");
        require(((boostAmount * maxPrice * vars.boostDuration) / UNIT) <= totalFeesAmount, "Not Enough Fees");

        vars.totalNbOffers = warden.offersIndex();

        vars.boostEndTime = block.timestamp + vars.boostDuration;
        vars.expiryTime = (vars.boostEndTime / WEEK) * WEEK;
        vars.expiryTime = (vars.expiryTime < vars.boostEndTime)
            ? ((vars.boostEndTime + WEEK) / WEEK) * WEEK
            : vars.expiryTime;

        vars.previousBalance = feeToken.balanceOf(address(this));

        feeToken.safeTransferFrom(msg.sender, address(this), totalFeesAmount);

        if(feeToken.allowance(address(this), address(warden)) != 0) feeToken.safeApprove(address(warden), 0);
        feeToken.safeApprove(address(warden), totalFeesAmount);

        vars.missingAmount = boostAmount;
        vars.boughtAmount = 0;

        vars.wardenMinRequiredPercent = warden.minPercRequired();

        for (uint256 i = 1; i < vars.totalNbOffers; i++) { //since the offer at index 0 is useless

            if(vars.missingAmount == 0) break;

            OfferVars memory varsOffer;

            varsOffer.availableUserBalance = _availableAmount(i, maxPrice, vars.expiryTime, clearExpired);
            if (varsOffer.availableUserBalance == 0) continue;
            if (varsOffer.availableUserBalance < minRequiredAmount) continue;

            varsOffer.toBuyAmount = varsOffer.availableUserBalance > vars.missingAmount ? vars.missingAmount : varsOffer.availableUserBalance;

            (varsOffer.delegator, varsOffer.offerPrice, varsOffer.offerminPercent,) = warden.offers(i);

            varsOffer.boostFeeAmount = (varsOffer.toBuyAmount * varsOffer.offerPrice * vars.boostDuration) / UNIT;

            varsOffer.boostPercent = (varsOffer.toBuyAmount * MAX_PCT) / votingEscrow.balanceOf(varsOffer.delegator);
            if(varsOffer.boostPercent < vars.wardenMinRequiredPercent || varsOffer.boostPercent < varsOffer.offerminPercent) continue;

            varsOffer.newTokenId = warden.buyDelegationBoost(varsOffer.delegator, receiver, varsOffer.boostPercent, duration, varsOffer.boostFeeAmount);

            require(varsOffer.newTokenId != 0, "Boost buy fail");

            vars.missingAmount -= varsOffer.toBuyAmount;
            vars.boughtAmount += uint256(delegationBoost.token_boost(varsOffer.newTokenId));
        }

        if(vars.boughtAmount < ((boostAmount * (MAX_PCT - acceptableSlippage)) / MAX_PCT)) 
            revert('Cannot match Order');

        vars.endBalance = feeToken.balanceOf(address(this));
        feeToken.safeTransfer(msg.sender, (vars.endBalance - vars.previousBalance));

        return true;
    }

    function preSortedMultiBuy(
        address receiver,
        uint256 duration,
        uint256 boostAmount,
        uint256 maxPrice,
        uint256 minRequiredAmount,
        uint256 totalFeesAmount,
        uint256 acceptableSlippage, //BPS
        bool clearExpired,
        uint256[] memory sortedOfferIndexes
    ) external returns (bool) {

        return _sortedMultiBuy(
        receiver,
        duration,
        boostAmount,
        maxPrice,
        minRequiredAmount,
        totalFeesAmount,
        acceptableSlippage,
        clearExpired,
        sortedOfferIndexes
        );
    }

    function sortingMultiBuy(
        address receiver,
        uint256 duration,
        uint256 boostAmount,
        uint256 maxPrice,
        uint256 minRequiredAmount,
        uint256 totalFeesAmount,
        uint256 acceptableSlippage, //BPS
        bool clearExpired
    ) external returns (bool) {

        uint256[] memory sortedOfferIndexes = _quickSortOffers();

        return _sortedMultiBuy(
        receiver,
        duration,
        boostAmount,
        maxPrice,
        minRequiredAmount,
        totalFeesAmount,
        acceptableSlippage,
        clearExpired,
        sortedOfferIndexes
        );
    }



    function _sortedMultiBuy(
        address receiver,
        uint256 duration,
        uint256 boostAmount,
        uint256 maxPrice,
        uint256 minRequiredAmount, //minimum size of the Boost to buy, smaller will be skipped
        uint256 totalFeesAmount,
        uint256 acceptableSlippage, //BPS
        bool clearExpired,
        uint256[] memory sortedOfferIndexes
    ) internal returns(bool) {

        require(
            receiver != address(0),
            "Zero address"
        );
        require(boostAmount != 0 && totalFeesAmount != 0 && acceptableSlippage != 0, "Null value");
        require(maxPrice != 0, "Null price");


        MultiBuyVars memory vars;

        vars.boostDuration = duration * 1 weeks;
        vars.weeksDuration = duration;
        require(vars.boostDuration >= warden.minDelegationTime(), "Duration too short");
        require(((boostAmount * maxPrice * vars.boostDuration) / UNIT) <= totalFeesAmount, "Not Enough Fees");

        require(sortedOfferIndexes.length != 0, "Empty Array");

        vars.boostEndTime = block.timestamp + vars.boostDuration;
        vars.expiryTime = (vars.boostEndTime / WEEK) * WEEK;
        vars.expiryTime = (vars.expiryTime < vars.boostEndTime)
            ? ((vars.boostEndTime + WEEK) / WEEK) * WEEK
            : vars.expiryTime;

        vars.previousBalance = feeToken.balanceOf(address(this));

        feeToken.safeTransferFrom(msg.sender, address(this), totalFeesAmount);

        if(feeToken.allowance(address(this), address(warden)) != 0) feeToken.safeApprove(address(warden), 0);
        feeToken.safeApprove(address(warden), totalFeesAmount);

        vars.missingAmount = boostAmount;
        vars.boughtAmount = 0;

        vars.wardenMinRequiredPercent = warden.minPercRequired();

        for (uint256 i = 0; i < sortedOfferIndexes.length; i++) {

            require(sortedOfferIndexes[i] != 0 && sortedOfferIndexes[i] < warden.offersIndex(), "BoostOffer does not exist");

            if(vars.missingAmount == 0) break;

            OfferVars memory varsOffer;

            varsOffer.availableUserBalance = _availableAmount(sortedOfferIndexes[i], maxPrice, vars.expiryTime, clearExpired);
            if (varsOffer.availableUserBalance == 0) continue;
            if (varsOffer.availableUserBalance < minRequiredAmount) continue;

            varsOffer.toBuyAmount = varsOffer.availableUserBalance > vars.missingAmount ? vars.missingAmount : varsOffer.availableUserBalance;

            (varsOffer.delegator, varsOffer.offerPrice, varsOffer.offerminPercent,) = warden.offers(sortedOfferIndexes[i]);

            varsOffer.boostFeeAmount = (varsOffer.toBuyAmount * varsOffer.offerPrice * vars.boostDuration) / UNIT;

            varsOffer.boostPercent = (varsOffer.toBuyAmount * MAX_PCT) / votingEscrow.balanceOf(varsOffer.delegator);
            if(varsOffer.boostPercent < vars.wardenMinRequiredPercent || varsOffer.boostPercent < varsOffer.offerminPercent) continue; // Offer available percent is udner Warden's minimum required percent

            varsOffer.newTokenId = warden.buyDelegationBoost(varsOffer.delegator, receiver, varsOffer.boostPercent, vars.weeksDuration, varsOffer.boostFeeAmount);

            require(varsOffer.newTokenId != 0, "Boost buy fail");

            vars.missingAmount -= varsOffer.toBuyAmount;
            vars.boughtAmount += uint256(delegationBoost.token_boost(varsOffer.newTokenId));
            
        }

        if(vars.boughtAmount < ((boostAmount * (MAX_PCT - acceptableSlippage)) / MAX_PCT)) 
            revert('Cannot match Order');

        vars.endBalance = feeToken.balanceOf(address(this));
        feeToken.safeTransfer(msg.sender, (vars.endBalance - vars.previousBalance));

        return true;
    }

    function getSortedOffers() external view returns(uint[] memory) {

        return _quickSortOffers();
    }

    struct OfferInfos {
        address user;
        uint256 price;
    }

    function _quickSortOffers() internal view returns(uint[] memory){

        uint256 totalNbOffers = warden.offersIndex();

        OfferInfos[] memory offersList = new OfferInfos[](totalNbOffers - 1);
        for(uint256 i = 0; i < offersList.length; i++){ //Because the 0 index is an empty Offer
            (offersList[i].user, offersList[i].price,,) = warden.offers(i + 1);
        }

        _quickSort(offersList, int(0), int(offersList.length - 1));

        uint256[] memory sortedOffers = new uint256[](totalNbOffers - 1);
        for(uint256 i = 0; i < offersList.length; i++){
            sortedOffers[i] = warden.userIndex(offersList[i].user);
        }

        return sortedOffers;
    }

    function _quickSort(OfferInfos[] memory offersList, int left, int right) internal view {

        int i = left;
        int j = right;
        if(i==j) return;
        OfferInfos memory pivot = offersList[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (offersList[uint(i)].price < pivot.price) i++;
            while (pivot.price < offersList[uint(j)].price) j--;
            if (i <= j) {
                (offersList[uint(i)], offersList[uint(j)]) = (offersList[uint(j)], offersList[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            _quickSort(offersList, left, j);
        if (i < right)
            _quickSort(offersList, i, right);
    }

    struct AvailableAmountVars {
        address delegator;
        uint256 offerPrice;
        uint256 minPerc;
        uint256 maxPerc;
        uint256 userBalance;
        uint256 delegatedBalance;
        uint256 blockedBalance;
        uint256 availableBalance;
        uint256 minBoostAmount;
        uint256 potentialCancelableBalance;
        uint256 currentBoostsNumber;
    }

    function _availableAmount(
        uint256 offerIndex,
        uint256 maxPrice,
        uint256 expiryTime,
        bool clearExpired
    ) internal returns (uint256) {

        AvailableAmountVars memory vars;

        (
            vars.delegator,
            vars.offerPrice,
            vars.minPerc,
            vars.maxPerc
        ) = warden.offers(offerIndex);

        if (vars.offerPrice > maxPrice) return 0;

        if (!delegationBoost.isApprovedForAll(vars.delegator, address(warden))) return 0;

        if (expiryTime >= votingEscrow.locked__end(vars.delegator)) return 0;

        vars.userBalance = votingEscrow.balanceOf(vars.delegator);

        vars.delegatedBalance = delegationBoost.delegated_boost(vars.delegator);

        vars.blockedBalance = (vars.userBalance * (MAX_PCT - vars.maxPerc)) / MAX_PCT;

        vars.availableBalance = vars.userBalance - vars.blockedBalance;

        vars.minBoostAmount = (vars.userBalance * vars.minPerc) / MAX_PCT;

        if(!clearExpired) {
            if(delegationBoost.adjusted_balance_of(vars.delegator) == 0) return 0;

            if(vars.availableBalance > vars.delegatedBalance){
                if(vars.minBoostAmount > (vars.availableBalance - vars.delegatedBalance)) return 0;

                return (vars.availableBalance - vars.delegatedBalance);
            }

            return 0;
        }

        vars.currentBoostsNumber = delegationBoost.total_minted(vars.delegator);
        uint256[256] memory expiredBoosts; //Need this type of array because of batch_cancel_boosts() from veBoost

        vars.potentialCancelableBalance = 0;

        if(vars.currentBoostsNumber > 0){
            uint256 nbExpired = 0;

            for (uint256 i = 0; i < vars.currentBoostsNumber;) {
                uint256 tokenId = delegationBoost.token_of_delegator_by_index(
                    vars.delegator,
                    i
                );

                if (delegationBoost.token_expiry(tokenId) < block.timestamp) {
                    expiredBoosts[nbExpired] = tokenId;
                    nbExpired++;
                }

                unchecked{ ++i; }
            }

            if (nbExpired > 0) {
                delegationBoost.batch_cancel_boosts(expiredBoosts);

                vars.delegatedBalance = delegationBoost.delegated_boost(vars.delegator);
            }

            for (uint256 i = 0; i < vars.currentBoostsNumber;) {
                uint256 tokenId = delegationBoost.token_of_delegator_by_index(
                    vars.delegator,
                    i
                );

                uint256 cancelTime = delegationBoost.token_cancel_time(tokenId);

                if (cancelTime < block.timestamp) {
                    int256 boost = delegationBoost.token_boost(tokenId);
                    uint256 absolute_boost = boost >= 0 ? uint256(boost) : uint256(-boost);
                    vars.potentialCancelableBalance += absolute_boost;
                }

                unchecked{ ++i; }
            }
        }

        if (vars.availableBalance < (vars.delegatedBalance - vars.potentialCancelableBalance)) return 0;
        if (vars.minBoostAmount <= (vars.availableBalance - (vars.delegatedBalance - vars.potentialCancelableBalance))) {
            return (vars.availableBalance - (vars.delegatedBalance - vars.potentialCancelableBalance));
        }

        return 0; //fallback => not enough availableBalance to propose the minimum Boost Amount allowed

    }

    function recoverERC20(address token, uint256 amount) external onlyOwner returns(bool) {

        IERC20(token).safeTransfer(owner(), amount);

        return true;
    }

}