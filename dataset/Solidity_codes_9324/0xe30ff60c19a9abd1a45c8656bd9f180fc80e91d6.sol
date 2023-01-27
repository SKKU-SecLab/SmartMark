
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


interface IERC20Permit is IERC20 {

    function getDomainSeparator() external view returns (bytes32);

    function DOMAIN_TYPEHASH() external view returns (bytes32);

    function VERSION_HASH() external view returns (bytes32);

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function nonces(address) external view returns (uint);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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


contract Payments is ReentrancyGuard {

    using SafeERC20 for IERC20;

    struct Payment {
        address token;
        address receiver;
        address payer;
        uint48 startTime;
        uint48 stopTime;
        uint16 cliffDurationInDays;
        uint256 paymentDurationInSecs;
        uint256 amount;
        uint256 amountClaimed;
    }

    struct PaymentBalance {
        uint256 id;
        uint256 claimableAmount;
        Payment payment;
    }

    struct TokenBalance {
        uint256 totalAmount;
        uint256 claimableAmount;
        uint256 claimedAmount;
    }

    uint256 constant internal SECONDS_PER_DAY = 86400;
    
    mapping (uint256 => Payment) public tokenPayments;

    mapping (address => uint256[]) public paymentIds;

    uint256 public numPayments;

    event PaymentCreated(address indexed token, address indexed payer, address indexed receiver, uint256 paymentId, uint256 amount, uint48 startTime, uint256 durationInSecs, uint16 cliffInDays);
    
    event TokensClaimed(address indexed receiver, address indexed token, uint256 indexed paymentId, uint256 amountClaimed);

    event PaymentStopped(uint256 indexed paymentId, uint256 indexed originalDuration, uint48 stopTime, uint48 startTime);

    function createPayment(
        address token,
        address receiver,
        uint48 startTime,
        uint256 amount,
        uint256 paymentDurationInSecs,
        uint16 cliffDurationInDays
    )
        external nonReentrant
    {

        _validatePayment(paymentDurationInSecs, cliffDurationInDays, amount);
        _createPayment(token, receiver, startTime, amount, paymentDurationInSecs, cliffDurationInDays);
    }

    function createPaymentWithPermit(
        address token,
        address receiver,
        uint48 startTime,
        uint256 amount,
        uint256 paymentDurationInSecs,
        uint16 cliffDurationInDays,
        uint256 deadline,
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) 
        external nonReentrant
    {

        _validatePayment(paymentDurationInSecs, cliffDurationInDays, amount);
        _permit(token, amount, deadline, v, r, s);
        _createPayment(token, receiver, startTime, amount, paymentDurationInSecs, cliffDurationInDays);
    }

    function createPayments(
        address[] memory tokens,
        address[] memory receivers,
        uint48[] memory startTimes,
        uint256[] memory amounts,
        uint256[] memory paymentDurationsInSecs,
        uint16[] memory cliffDurationsInDays
    )
        external nonReentrant
    {

        require(
            tokens.length == receivers.length &&
            receivers.length == startTimes.length &&
            startTimes.length == amounts.length &&
            amounts.length == paymentDurationsInSecs.length &&
            paymentDurationsInSecs.length == cliffDurationsInDays.length, 
            "Payments::createPayments: arrays must be same length"
        );
        for (uint256 i; i < tokens.length; i++) {
            _validatePayment(paymentDurationsInSecs[i], cliffDurationsInDays[i], amounts[i]);
            _createPayment(
                tokens[i],
                receivers[i],
                startTimes[i],
                amounts[i],
                paymentDurationsInSecs[i],
                cliffDurationsInDays[i]
            );
        }
    }

    function createPaymentsWithPermit(
        address[] memory tokens,
        address[] memory receivers,
        uint48[] memory startTimes,
        uint256[] memory amounts,
        uint256[] memory paymentDurationsInSecs,
        uint16[] memory cliffDurationsInDays,
        uint256[] memory deadlines,
        uint8[] memory vs, 
        bytes32[] memory rs, 
        bytes32[] memory ss
    )
        external nonReentrant
    {

        require(
            tokens.length == receivers.length &&
            receivers.length == startTimes.length &&
            startTimes.length == amounts.length &&
            amounts.length == paymentDurationsInSecs.length &&
            paymentDurationsInSecs.length == cliffDurationsInDays.length &&
            cliffDurationsInDays.length == deadlines.length &&
            deadlines.length == vs.length &&
            vs.length == rs.length &&
            rs.length == ss.length,
            "Payments::createPaymentsWithPermit: arrays must be same length"
        );
        for (uint256 i; i < tokens.length; i++) {
            _validatePayment(paymentDurationsInSecs[i], cliffDurationsInDays[i], amounts[i]);
            _permit(tokens[i], amounts[i], deadlines[i], vs[i], rs[i], ss[i]);
            _createPayment(
                tokens[i],
                receivers[i],
                startTimes[i],
                amounts[i],
                paymentDurationsInSecs[i],
                cliffDurationsInDays[i]
            );
        }
    }

    function allActivePaymentIds() external view returns(uint256[] memory){

        uint256 activeCount;

        for (uint256 i; i < numPayments; i++) {
            if(claimableBalance(i) > 0) {
                activeCount++;
            }
        }

        uint256[] memory result = new uint256[](activeCount);
        uint256 j;

        for (uint256 i; i < numPayments; i++) {
            if(claimableBalance(i) > 0) {
                result[j] = i;
                j++;
            }
        }
        return result;
    }

    function allActivePayments() external view returns(Payment[] memory){

        uint256 activeCount;

        for (uint256 i; i < numPayments; i++) {
            if(claimableBalance(i) > 0) {
                activeCount++;
            }
        }

        Payment[] memory result = new Payment[](activeCount);
        uint256 j;

        for (uint256 i; i < numPayments; i++) {
            if(claimableBalance(i) > 0) {
                result[j] = tokenPayments[i];
                j++;
            }
        }
        return result;
    }

    function allActivePaymentBalances() external view returns(PaymentBalance[] memory){

        uint256 activeCount;

        for (uint256 i; i < numPayments; i++) {
            if(claimableBalance(i) > 0) {
                activeCount++;
            }
        }

        PaymentBalance[] memory result = new PaymentBalance[](activeCount);
        uint256 j;

        for (uint256 i; i < numPayments; i++) {
            if(claimableBalance(i) > 0) {
                result[j] = paymentBalance(i);
                j++;
            }
        }
        return result;
    }

    function activePaymentIds(address receiver) external view returns(uint256[] memory){

        uint256 activeCount;
        uint256[] memory receiverPaymentIds = paymentIds[receiver];

        for (uint256 i; i < receiverPaymentIds.length; i++) {
            if(claimableBalance(receiverPaymentIds[i]) > 0) {
                activeCount++;
            }
        }

        uint256[] memory result = new uint256[](activeCount);
        uint256 j;

        for (uint256 i; i < receiverPaymentIds.length; i++) {
            if(claimableBalance(receiverPaymentIds[i]) > 0) {
                result[j] = receiverPaymentIds[i];
                j++;
            }
        }
        return result;
    }

    function allPayments(address receiver) external view returns(Payment[] memory){

        uint256[] memory allPaymentIds = paymentIds[receiver];
        Payment[] memory result = new Payment[](allPaymentIds.length);
        for (uint256 i; i < allPaymentIds.length; i++) {
            result[i] = tokenPayments[allPaymentIds[i]];
        }
        return result;
    }

    function activePayments(address receiver) external view returns(Payment[] memory){

        uint256 activeCount;
        uint256[] memory receiverPaymentIds = paymentIds[receiver];

        for (uint256 i; i < receiverPaymentIds.length; i++) {
            if(claimableBalance(receiverPaymentIds[i]) > 0) {
                activeCount++;
            }
        }

        Payment[] memory result = new Payment[](activeCount);
        uint256 j;

        for (uint256 i; i < receiverPaymentIds.length; i++) {
            if(claimableBalance(receiverPaymentIds[i]) > 0) {
                result[j] = tokenPayments[receiverPaymentIds[i]];
                j++;
            }
        }
        return result;
    }

    function activePaymentBalances(address receiver) external view returns(PaymentBalance[] memory){

        uint256 activeCount;
        uint256[] memory receiverPaymentIds = paymentIds[receiver];

        for (uint256 i; i < receiverPaymentIds.length; i++) {
            if(claimableBalance(receiverPaymentIds[i]) > 0) {
                activeCount++;
            }
        }

        PaymentBalance[] memory result = new PaymentBalance[](activeCount);
        uint256 j;

        for (uint256 i; i < receiverPaymentIds.length; i++) {
            if(claimableBalance(receiverPaymentIds[i]) > 0) {
                result[j] = paymentBalance(receiverPaymentIds[i]);
                j++;
            }
        }
        return result;
    }

    function totalTokenBalance(address token) external view returns(TokenBalance memory balance){

        for (uint256 i; i < numPayments; i++) {
            Payment memory tokenPayment = tokenPayments[i];
            if(tokenPayment.token == token && tokenPayment.startTime != tokenPayment.stopTime){
                balance.totalAmount = balance.totalAmount + tokenPayment.amount;
                if(block.timestamp > tokenPayment.startTime) {
                    balance.claimedAmount = balance.claimedAmount + tokenPayment.amountClaimed;

                    uint256 elapsedTime = tokenPayment.stopTime > 0 && tokenPayment.stopTime < block.timestamp ? tokenPayment.stopTime - tokenPayment.startTime : block.timestamp - tokenPayment.startTime;
                    uint256 elapsedDays = elapsedTime / SECONDS_PER_DAY;

                    if (
                        elapsedDays >= tokenPayment.cliffDurationInDays
                    ) {
                        if (tokenPayment.stopTime == 0 && elapsedTime >= tokenPayment.paymentDurationInSecs) {
                            balance.claimableAmount = balance.claimableAmount + tokenPayment.amount - tokenPayment.amountClaimed;
                        } else {
                            uint256 paymentAmountPerSec = tokenPayment.amount / tokenPayment.paymentDurationInSecs;
                            uint256 amountAvailable = paymentAmountPerSec * elapsedTime;
                            balance.claimableAmount = balance.claimableAmount + amountAvailable - tokenPayment.amountClaimed;
                        }
                    }
                }
            }
        }
    }

    function tokenBalance(address token, address receiver) external view returns(TokenBalance memory balance){

        uint256[] memory receiverPaymentIds = paymentIds[receiver];
        for (uint256 i; i < receiverPaymentIds.length; i++) {
            Payment memory receiverPayment = tokenPayments[receiverPaymentIds[i]];
            if(receiverPayment.token == token && receiverPayment.startTime != receiverPayment.stopTime){
                balance.totalAmount = balance.totalAmount + receiverPayment.amount;
                if(block.timestamp > receiverPayment.startTime) {
                    balance.claimedAmount = balance.claimedAmount + receiverPayment.amountClaimed;

                    uint256 elapsedTime = receiverPayment.stopTime > 0 && receiverPayment.stopTime < block.timestamp ? receiverPayment.stopTime - receiverPayment.startTime : block.timestamp - receiverPayment.startTime;
                    uint256 elapsedDays = elapsedTime / SECONDS_PER_DAY;

                    if (
                        elapsedDays >= receiverPayment.cliffDurationInDays
                    ) {
                        if (receiverPayment.stopTime == 0 && elapsedTime >= receiverPayment.paymentDurationInSecs) {
                            balance.claimableAmount = balance.claimableAmount + receiverPayment.amount - receiverPayment.amountClaimed;
                        } else {
                            uint256 paymentAmountPerSec = receiverPayment.amount / receiverPayment.paymentDurationInSecs;
                            uint256 amountAvailable = paymentAmountPerSec * elapsedTime;
                            balance.claimableAmount = balance.claimableAmount + amountAvailable - receiverPayment.amountClaimed;
                        }
                    }
                }
            }
        }
    }

    function paymentBalance(uint256 paymentId) public view returns (PaymentBalance memory balance) {

        balance.id = paymentId;
        balance.claimableAmount = claimableBalance(paymentId);
        balance.payment = tokenPayments[paymentId];
    }

    function claimableBalance(uint256 paymentId) public view returns (uint256) {

        Payment storage payment = tokenPayments[paymentId];

        if (block.timestamp < payment.startTime || payment.startTime == payment.stopTime) {
            return 0;
        }

        
        uint256 elapsedTime = payment.stopTime > 0 && payment.stopTime < block.timestamp ? payment.stopTime - payment.startTime : block.timestamp - payment.startTime;
        uint256 elapsedDays = elapsedTime / SECONDS_PER_DAY;
        
        if (elapsedDays < payment.cliffDurationInDays) {
            return 0;
        }

        if (payment.stopTime == 0 && elapsedTime >= payment.paymentDurationInSecs) {
            return payment.amount - payment.amountClaimed;
        }
        
        uint256 paymentAmountPerSec = payment.amount / payment.paymentDurationInSecs;
        uint256 amountAvailable = paymentAmountPerSec * elapsedTime;
        return amountAvailable - payment.amountClaimed;
    }

    function claimAllAvailableTokens(uint256[] memory payments) external nonReentrant {

        for (uint i = 0; i < payments.length; i++) {
            uint256 claimableAmount = claimableBalance(payments[i]);
            require(claimableAmount > 0, "Payments::claimAllAvailableTokens: claimableAmount is 0");
            _claimTokens(payments[i], claimableAmount);
        }
    }

    function claimAvailableTokenAmounts(uint256[] memory payments, uint256[] memory amounts) external nonReentrant {

        require(payments.length == amounts.length, "Payments::claimAvailableTokenAmounts: arrays must be same length");
        for (uint i = 0; i < payments.length; i++) {
            uint256 claimableAmount = claimableBalance(payments[i]);
            require(claimableAmount >= amounts[i], "Payments::claimAvailableTokenAmounts: claimableAmount < amount");
            _claimTokens(payments[i], amounts[i]);
        }
    }

    function stopPayment(uint256 paymentId, uint48 stopTime) external nonReentrant {

        Payment storage payment = tokenPayments[paymentId];
        require(msg.sender == payment.payer || msg.sender == payment.receiver, "Payments::stopPayment: msg.sender must be payer or receiver");
        require(payment.stopTime == 0, "Payments::stopPayment: payment already stopped");
        stopTime = stopTime == 0 ? uint48(block.timestamp) : stopTime;
        require(stopTime < payment.startTime + payment.paymentDurationInSecs, "Payments::stopPayment: stop time > payment duration");
        if(stopTime > payment.startTime) {
            payment.stopTime = stopTime;
            uint256 newPaymentDuration = stopTime - payment.startTime;
            uint256 paymentAmountPerSec = payment.amount / payment.paymentDurationInSecs;
            uint256 newPaymentAmount = paymentAmountPerSec * newPaymentDuration;
            IERC20(payment.token).safeTransfer(payment.payer, payment.amount - newPaymentAmount);
            emit PaymentStopped(paymentId, payment.paymentDurationInSecs, stopTime, payment.startTime);
        } else {
            payment.stopTime = payment.startTime;
            IERC20(payment.token).safeTransfer(payment.payer, payment.amount);
            emit PaymentStopped(paymentId, payment.paymentDurationInSecs, payment.startTime, payment.startTime);
        }
    }

    function _validatePayment(uint256 paymentDurationInSecs, uint16 cliffDurationInDays, uint256 amount) internal pure {

        require(paymentDurationInSecs > 0, "Payments::_validatePayment: payment duration must be > 0");
        require(paymentDurationInSecs <= 25*365*SECONDS_PER_DAY, "Payments::_validatePayment: payment duration more than 25 years");
        require(paymentDurationInSecs >= SECONDS_PER_DAY*cliffDurationInDays, "Payments::_validatePayment: payment duration < cliff");
        require(amount > 0, "Payments::_validatePayment: amount not > 0");
    }

    function _createPayment(
        address token,
        address receiver,
        uint48 startTime,
        uint256 amount,
        uint256 paymentDurationInSecs,
        uint16 cliffDurationInDays
    ) internal {


        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        uint48 paymentStartTime = startTime == 0 ? uint48(block.timestamp) : startTime;

        Payment memory payment = Payment({
            token: token,
            receiver: receiver,
            payer: msg.sender,
            startTime: paymentStartTime,
            stopTime: 0,
            paymentDurationInSecs: paymentDurationInSecs,
            cliffDurationInDays: cliffDurationInDays,
            amount: amount,
            amountClaimed: 0
        });

        tokenPayments[numPayments] = payment;
        paymentIds[receiver].push(numPayments);
        emit PaymentCreated(token, msg.sender, receiver, numPayments, amount, paymentStartTime, paymentDurationInSecs, cliffDurationInDays);
        
        numPayments++;
    }

    function _claimTokens(uint256 paymentId, uint256 claimAmount) internal {

        Payment storage payment = tokenPayments[paymentId];
        require(msg.sender == payment.receiver, "Payments::_claimTokens: msg.sender != receiver");

        payment.amountClaimed = payment.amountClaimed + claimAmount;

        IERC20(payment.token).safeTransfer(payment.receiver, claimAmount);
        emit TokensClaimed(payment.receiver, payment.token, paymentId, claimAmount);
    }

    function _permit(
        address token,
        uint256 amount,
        uint256 deadline,
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) internal {

        IERC20Permit(token).permit(msg.sender, address(this), amount, deadline, v, r, s);
    }
}