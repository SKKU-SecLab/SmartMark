
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
pragma experimental ABIEncoderV2;



interface IERC20Permit{

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}

contract BaseBoringBatchable {

    function _getRevertMsg(bytes memory _returnData) internal pure returns (string memory) {

        if (_returnData.length < 68) return "Transaction reverted silently";

        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }

    function batch(bytes[] calldata calls, bool revertOnFail) external payable {

        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(calls[i]);
            if (!success && revertOnFail) {
                revert(_getRevertMsg(result));
            }
        }
    }
}

contract BoringBatchable is BaseBoringBatchable {

    function permitToken(
        IERC20Permit token,
        address from,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {

        token.permit(from, to, amount, deadline, v, r, s);
    }
}//None
pragma solidity ^0.8.0;


interface Factory {

    function parameter() external view returns (address);

}

interface IERC20WithDecimals {

    function decimals() external view returns (uint8);

}




contract LlamaPay is BoringBatchable {

    using SafeERC20 for IERC20;

    struct Payer {
        uint40 lastPayerUpdate;
        uint216 totalPaidPerSec; // uint216 is enough to hold 1M streams of 3e51 tokens/yr, which is enough
    }

    mapping (bytes32 => uint) public streamToStart;
    mapping (address => Payer) public payers;
    mapping (address => uint) public balances; // could be packed together with lastPayerUpdate but gains are not high
    IERC20 public token;
    uint public DECIMALS_DIVISOR;

    event StreamCreated(address indexed from, address indexed to, uint216 amountPerSec, bytes32 streamId);
    event StreamCancelled(address indexed from, address indexed to, uint216 amountPerSec, bytes32 streamId);
    event StreamModified(address indexed from, address indexed oldTo, uint216 oldAmountPerSec, bytes32 oldStreamId, address indexed to, uint216 amountPerSec, bytes32 newStreamId);
    event Withdraw(address indexed from, address indexed to, uint216 amountPerSec, bytes32 streamId, uint amount);

    constructor(){
        token = IERC20(Factory(msg.sender).parameter());
        uint8 tokenDecimals = IERC20WithDecimals(address(token)).decimals();
        DECIMALS_DIVISOR = 10**(20 - tokenDecimals);
    }

    function getStreamId(address from, address to, uint216 amountPerSec) public pure returns (bytes32){

        return keccak256(abi.encodePacked(from, to, amountPerSec));
    }

    function _createStream(address to, uint216 amountPerSec) internal returns (bytes32 streamId){

        streamId = getStreamId(msg.sender, to, amountPerSec);
        require(amountPerSec > 0, "amountPerSec can't be 0");
        require(streamToStart[streamId] == 0, "stream already exists");
        streamToStart[streamId] = block.timestamp;

        Payer storage payer = payers[msg.sender];
        uint totalPaid;
        uint delta = block.timestamp - payer.lastPayerUpdate;
        unchecked {
            totalPaid = delta * uint(payer.totalPaidPerSec);
        }
        balances[msg.sender] -= totalPaid; // implicit check that balance >= totalPaid, can't create a new stream unless there's no debt

        payer.lastPayerUpdate = uint40(block.timestamp);
        payer.totalPaidPerSec += amountPerSec;

    }

    function createStream(address to, uint216 amountPerSec) public {

        bytes32 streamId = _createStream(to, amountPerSec);
        emit StreamCreated(msg.sender, to, amountPerSec, streamId);
    }


    function _withdraw(address from, address to, uint216 amountPerSec) private returns (uint40 lastUpdate, bytes32 streamId, uint amountToTransfer) {

        streamId = getStreamId(from, to, amountPerSec);
        require(streamToStart[streamId] != 0, "stream doesn't exist");

        Payer storage payer = payers[from];
        uint totalPayerPayment;
        uint payerDelta = block.timestamp - payer.lastPayerUpdate;
        unchecked{
            totalPayerPayment = payerDelta * uint(payer.totalPaidPerSec);
        }
        uint payerBalance = balances[from];
        if(payerBalance >= totalPayerPayment){
            unchecked {
                balances[from] = payerBalance - totalPayerPayment;   
            }
            lastUpdate = uint40(block.timestamp);
        } else {
            unchecked {
                uint timePaid = payerBalance/uint(payer.totalPaidPerSec);
                lastUpdate = uint40(payer.lastPayerUpdate + timePaid);
                balances[from] = payerBalance % uint(payer.totalPaidPerSec);
            }
        }
        uint delta = lastUpdate - streamToStart[streamId]; // Could use unchecked here too I think
        unchecked {
            amountToTransfer = (delta*uint(amountPerSec))/DECIMALS_DIVISOR;
        }
        emit Withdraw(from, to, amountPerSec, streamId, amountToTransfer);
    }

    function withdrawable(address from, address to, uint216 amountPerSec) external view returns (uint withdrawableAmount, uint lastUpdate, uint owed) {

        bytes32 streamId = getStreamId(from, to, amountPerSec);
        require(streamToStart[streamId] != 0, "stream doesn't exist");

        Payer storage payer = payers[from];
        uint totalPayerPayment;
        uint payerDelta = block.timestamp - payer.lastPayerUpdate;
        unchecked{
            totalPayerPayment = payerDelta * uint(payer.totalPaidPerSec);
        }
        uint payerBalance = balances[from];
        if(payerBalance >= totalPayerPayment){
            lastUpdate = block.timestamp;
        } else {
            unchecked {
                uint timePaid = payerBalance/uint(payer.totalPaidPerSec);
                lastUpdate = payer.lastPayerUpdate + timePaid;
            }
        }
        uint delta = lastUpdate - streamToStart[streamId];
        withdrawableAmount = (delta*uint(amountPerSec))/DECIMALS_DIVISOR;
        owed = ((block.timestamp - lastUpdate)*uint(amountPerSec))/DECIMALS_DIVISOR;
    }

    function withdraw(address from, address to, uint216 amountPerSec) external {

        (uint40 lastUpdate, bytes32 streamId, uint amountToTransfer) = _withdraw(from, to, amountPerSec);
        streamToStart[streamId] = lastUpdate;
        payers[from].lastPayerUpdate = lastUpdate;
        token.safeTransfer(to, amountToTransfer);
    }

    function _cancelStream(address to, uint216 amountPerSec) internal returns (bytes32 streamId) {

        uint40 lastUpdate; uint amountToTransfer;
        (lastUpdate, streamId, amountToTransfer) = _withdraw(msg.sender, to, amountPerSec);
        streamToStart[streamId] = 0;
        Payer storage payer = payers[msg.sender];
        unchecked{
            payer.totalPaidPerSec -= amountPerSec;
        }
        payer.lastPayerUpdate = lastUpdate;
        token.safeTransfer(to, amountToTransfer);
    }

    function cancelStream(address to, uint216 amountPerSec) public {

        bytes32 streamId = _cancelStream(to, amountPerSec);
        emit StreamCancelled(msg.sender, to, amountPerSec, streamId);
    }

    function modifyStream(address oldTo, uint216 oldAmountPerSec, address to, uint216 amountPerSec) external {

        bytes32 oldStreamId = _cancelStream(oldTo, oldAmountPerSec);
        bytes32 newStreamId = _createStream(to, amountPerSec);
        emit StreamModified(msg.sender, oldTo, oldAmountPerSec, oldStreamId, to, amountPerSec, newStreamId);
    }

    function deposit(uint amount) public {

        balances[msg.sender] += amount * DECIMALS_DIVISOR;
        token.safeTransferFrom(msg.sender, address(this), amount);
    }

    function depositAndCreate(uint amountToDeposit, address to, uint216 amountPerSec) external {

        deposit(amountToDeposit);
        createStream(to, amountPerSec);
    }

    function withdrawPayer(uint amount) public {

        Payer storage payer = payers[msg.sender];
        balances[msg.sender] -= amount; // implicit check that balance > amount
        uint delta = block.timestamp - payer.lastPayerUpdate;
        unchecked {
            require(balances[msg.sender] >= delta*uint(payer.totalPaidPerSec), "pls no rug");
            token.safeTransfer(msg.sender, amount/DECIMALS_DIVISOR);
        }
    }

    function withdrawPayerAll() external {

        Payer storage payer = payers[msg.sender];
        unchecked {
            uint delta = block.timestamp - payer.lastPayerUpdate;
            withdrawPayer(balances[msg.sender]-delta*uint(payer.totalPaidPerSec));
        }
    }

    function getPayerBalance(address payerAddress) external view returns (int) {

        Payer storage payer = payers[payerAddress];
        int balance = int(balances[payerAddress]);
        uint delta = block.timestamp - payer.lastPayerUpdate;
        return (balance - int(delta*uint(payer.totalPaidPerSec)))/int(DECIMALS_DIVISOR);
    }
}//None
pragma solidity ^0.8.0;



contract LlamaPayFactory {

    bytes32 constant INIT_CODEHASH = keccak256(type(LlamaPay).creationCode);

    address public parameter;
    uint256 public getLlamaPayContractCount;
    address[1000000000] public getLlamaPayContractByIndex; // 1 billion indices

    event LlamaPayCreated(address token, address llamaPay);

    function createLlamaPayContract(address _token) external returns (address llamaPayContract) {

        parameter = _token;
        llamaPayContract = address(new LlamaPay{salt: bytes32(uint256(uint160(_token)))}());
        require(llamaPayContract != address(0));

        uint256 index = getLlamaPayContractCount;
        getLlamaPayContractByIndex[index] = llamaPayContract;
        unchecked{
            getLlamaPayContractCount = index + 1;
        }

        emit LlamaPayCreated(_token, llamaPayContract);
    }

    function getLlamaPayContractByToken(address _token) external view returns(address predictedAddress, bool isDeployed){

        predictedAddress = address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            bytes32(uint256(uint160(_token))),
            INIT_CODEHASH
        )))));
        isDeployed = predictedAddress.code.length != 0;
    }
}