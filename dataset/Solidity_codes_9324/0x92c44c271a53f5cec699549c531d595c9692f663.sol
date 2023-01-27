
pragma solidity 0.7.5;



contract Batcher {

    event BatchTransfer(address sender, address recipient, uint256 value);
    event OwnerChange(address prevOwner, address newOwner);
    event TransferGasLimitChange(uint256 prevTransferGasLimit, uint256 newTransferGasLimit);

    address public owner;
    uint256 public lockCounter;
    uint256 public transferGasLimit;

    constructor() {
        lockCounter = 1;
        owner = msg.sender;
        emit OwnerChange(address(0), owner);
        transferGasLimit = 10000;
        emit TransferGasLimitChange(0, transferGasLimit);
    }

    modifier lockCall() {

        lockCounter++;
        uint256 localCounter = lockCounter;
        _;
        require(localCounter == lockCounter, "Reentrancy attempt detected");
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Not owner");
        _;
    }

    function batch(address[] calldata recipients, uint256[] calldata values) external payable lockCall {

        require(recipients.length != 0, "Must send to at least one person");
        require(recipients.length == values.length, "Unequal recipients and values");
        require(recipients.length < 256, "Too many recipients");

        for (uint8 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient address");
            (bool success,) = recipients[i].call{value: values[i], gas: transferGasLimit}("");
            require(success, "Send failed");
            emit BatchTransfer(msg.sender, recipients[i], values[i]);
        }

        if (address(this).balance > 0) {
            (bool success,) = msg.sender.call{value: address(this).balance, gas: transferGasLimit}("");
            require(success, "Sender refund failed");
        }
    }

    function recover(address to, uint256 value, bytes calldata data) external onlyOwner returns (bytes memory) {

        (bool success, bytes memory returnData) = to.call{value: value}(data);
        require(success, "Call was not successful");
        return returnData;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0), "Invalid new owner");
        emit OwnerChange(owner, newOwner);
        owner = newOwner;
    }

    function changeTransferGasLimit(uint256 newTransferGasLimit) external onlyOwner {

        require(newTransferGasLimit >= 2300, "Transfer gas limit too low");
        emit TransferGasLimitChange(transferGasLimit, newTransferGasLimit);
        transferGasLimit = newTransferGasLimit;
    }

    fallback() external payable {
        revert("Invalid fallback");
    }
    
    receive() external payable {
        revert("Invalid receive");
    }
}