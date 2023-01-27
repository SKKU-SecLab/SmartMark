
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


pragma solidity ^0.8.11;


struct TransferRequest {
    address receiver;
    uint256 amount;
}

contract ConiunFreeBulkTransfer is Pausable, Ownable {

    constructor() {}

    function withdrawAll() external onlyOwner {

        uint256 balance = address(this).balance;
        require(balance > 0);

        (bool success, ) = owner().call{value: balance}("");
        require(success, "Transfer failed.");
    }

    function initiateBulkTransfer(TransferRequest[] memory transferRequests)
        public
        payable
        whenNotPaused
    {

        uint256 arrayLength = transferRequests.length;
        for (uint256 i = 0; i < arrayLength; i++) {
            TransferRequest memory transferRequest = transferRequests[i];
            (bool success, ) = transferRequest.receiver.call{
                value: transferRequest.amount
            }("");
            require(success, "bulk_transfer_failed");
        }
    }


    function pause() public whenNotPaused {

        _pause();
    }

    function unpause() public whenPaused {

        _unpause();
    }
}