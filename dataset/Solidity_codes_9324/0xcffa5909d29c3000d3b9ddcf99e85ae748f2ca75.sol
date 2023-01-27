
pragma solidity ^0.6.0;


contract Pausable {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        _whenNotPaused();
        _;
    }

    function _whenNotPaused() private view {

        require(!_paused, "Pausable: paused");
    }

    modifier whenPaused() {

        _whenPaused();
        _;
    }

    function _whenPaused() private view {

        require(_paused, "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal virtual whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }
}// MIT

pragma solidity ^0.6.0;


contract SafeMathContract {


    function sub(uint256 a, uint256 b) public pure returns (uint256) {

        return _sub(a, b, "SafeMath: subtraction overflow");
    }

    function _sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract UpgradableOwnable is Context {
    address private _owner;
    bool public _isInitialised;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

     function ownableInit(address owner) public {
       require(!_isInitialised);
        _owner = owner;
        _isInitialised = true;
        emit OwnershipTransferred(address(0), owner);
     }

     modifier isInitisalised() {
       require(_isInitialised);
       _;
     }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "sender should be owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner)
        public
        virtual
        onlyOwner
    {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}pragma solidity 0.6.4;

interface IDepositExecute {

    function deposit(
        bytes32 resourceID,
        bytes8 destinationChainID,
        uint64 depositNonce,
        address depositer,
        address recipientAddress,
        uint256 amount,
        bytes calldata params
    ) external returns (address);


    function executeProposal(bytes32 resourceID, address recipientAddress, uint256 amount, bytes calldata params) external;

    function getAddressFromResourceId(bytes32 resourceID) external view returns(address);

}pragma solidity 0.6.4;

interface IBridge {

    function _chainID() external returns (uint8);


    function internalDeposit(bytes8 destinationChainID,bytes32 resourceID,uint256 amount,address recipientAddress) external;

}pragma solidity 0.6.4;

interface IERCHandler {

    function setResource(bytes32 resourceID, address contractAddress) external;

    function setBurnable(address contractAddress) external;

    function withdraw(address tokenAddress, address recipient, uint256 amountOrTokenID) external;


    function approve(bytes32 resourceID, address spender, uint256 amountOrTokenID) external;

}pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;


contract Bridge is Pausable, SafeMathContract, UpgradableOwnable {

    bytes8 public _chainID;
    uint256 public _fee;
    address public _backendSrvAddress;

    enum ProposalStatus {
        Inactive,
        Active,
        Passed,
        Executed,
        Cancelled
    }

    bytes32 public _nativeResourceID;

    mapping(bytes8 => uint64) public _depositCounts;
    mapping(bytes32 => address) public _resourceIDToHandlerAddress;
    mapping(uint64 => mapping(bytes8 => bytes)) public _depositRecords;
    mapping(bytes32 => mapping(bytes32 => bool)) public _executedProposals;

    mapping(address => bool) public handlers;

    event Deposit(
        bytes8 originChainID,
        bytes8 indexed destinationChainID,
        bytes32 indexed resourceID,
        uint64 indexed depositNonce,
        address depositor,
        address recipientAddress,
        address tokenAddress,
        uint256 amount,
        bytes32 dataHash
    );
    event ProposalEvent(
        bytes8 indexed originChainID,
        bytes8 indexed destinationChainID,
        address indexed recipientAddress,
        uint256 amount,
        uint64 depositNonce,
        ProposalStatus status,
        bytes32 resourceID,
        bytes32 dataHash
    );
    event ExtraFeeSupplied(
        bytes8 originChainID,
        bytes8 destinationChainID,
        uint64 depositNonce,
        bytes32 resourceID,
        address recipientAddress,
        uint256 amount
    );

    modifier onlyBackendSrv() {

        _onlyBackendSrv();
        _;
    }

    function _onlyBackendSrv() private view {

        require(
            _backendSrvAddress == msg.sender,
            "sender is not a backend service"
        );
    }

    modifier onlyHandler() {

        require(handlers[msg.sender], "sender is not a handler" );
        _;
    }

    function setHandler(address _handler, bool value) external onlyBackendSrv {

        handlers[_handler] = value;
    }

    function initialize(
        bytes8 chainID,
        uint256 fee,
        address initBackendSrvAddress
    ) public {

        _chainID = chainID;
        _fee = fee;
        _backendSrvAddress = initBackendSrvAddress;
        ownableInit(msg.sender);
    }

    function setBackendSrv(address newBackendSrv) external onlyBackendSrv {

        _backendSrvAddress = newBackendSrv;
    }

    function adminPauseTransfers() external onlyOwner {

        _pause();
    }

    function adminUnpauseTransfers() external onlyOwner {

        _unpause();
    }

    function setResource(
        address handlerAddress,
        bytes32 resourceID,
        address tokenAddress
    ) external onlyBackendSrv {

        _resourceIDToHandlerAddress[resourceID] = handlerAddress;
        IERCHandler handler = IERCHandler(handlerAddress);
        handler.setResource(resourceID, tokenAddress);
        handlers[handlerAddress] = true;
    }

    function setNativeResourceID(bytes32 resourceID) external onlyBackendSrv {

        _nativeResourceID = resourceID;
    }

    function setBurnable(address handlerAddress, address tokenAddress)
        external
        onlyBackendSrv
    {

        IERCHandler handler = IERCHandler(handlerAddress);
        handler.setBurnable(tokenAddress);
    }

    function changeFee(uint256 newFee) external onlyBackendSrv {

        require(_fee != newFee, "Current fee is equal to new fee");
        _fee = newFee;
    }

    function adminWithdraw(
        address handlerAddress,
        address tokenAddress,
        address recipient,
        uint256 amountOrTokenID
    ) external onlyOwner {

        IERCHandler handler = IERCHandler(handlerAddress);
        handler.withdraw(tokenAddress, recipient, amountOrTokenID);
    }

    function approveSpending(
        bytes32 resourceIDOwner,
        bytes32 resourceIDSpender,
        uint256 amountOrTokenID
    ) external onlyBackendSrv {

        address handlerOwner = _resourceIDToHandlerAddress[resourceIDOwner];
        require(handlerOwner != address(0), "resourceIDOwner not mapped to handler");

        address handlerSpender = _resourceIDToHandlerAddress[resourceIDSpender];
        require(handlerSpender != address(0), "resourceIDSpender not mapped to handler");

        IERCHandler handler = IERCHandler(handlerOwner);
        handler.approve(resourceIDOwner, handlerSpender, amountOrTokenID);
    }

    function deposit(
        bytes8 destinationChainID,
        bytes32 resourceID,
        uint256 amount,
        address recipientAddress,
        uint256 amountToLA,
        bytes calldata params
    ) external payable whenNotPaused {

        uint64 depositNonce = ++_depositCounts[destinationChainID];
        bytes memory data = abi.encode(amount, recipientAddress);
        bytes32 dataHash = keccak256(abi.encode(resourceID, data));
        _depositRecords[depositNonce][destinationChainID] = data;

        address tokenAddress;
        uint256 totalAmount = amount + amountToLA;
        if (resourceID == _nativeResourceID) {
            require(
                msg.value >= (totalAmount + _fee),
                "Incorrect fee/amount supplied"
            );

            tokenAddress = address(0);

        } else {
            require(msg.value >= _fee, "Incorrect fee supplied");

            address handler = _resourceIDToHandlerAddress[resourceID];
            require(handler != address(0), "resourceID not mapped to handler");

            tokenAddress = IDepositExecute(handler).deposit(
                resourceID,
                destinationChainID,
                depositNonce,
                msg.sender,
                recipientAddress,
                totalAmount,
                params
            );
        }
            if (amountToLA > 0) {
                emit ExtraFeeSupplied(
                    _chainID,
                    destinationChainID,
                    depositNonce,
                    resourceID,
                    recipientAddress,
                    amountToLA
                );
            }

        uint256 stackAmount = amount;

        emit Deposit(
            _chainID,
            destinationChainID,
            resourceID,
            depositNonce,
            msg.sender,
            recipientAddress,
            tokenAddress,
            stackAmount,
            dataHash
        );
    }
    
    function internalDeposit(
        bytes8 destinationChainID,
        bytes32 resourceID,
        uint256 amount,
        address recipientAddress
    ) public whenNotPaused onlyHandler {

        uint64 depositNonce = ++_depositCounts[destinationChainID];
        bytes memory data = abi.encode(amount, recipientAddress);
        bytes32 dataHash = keccak256(abi.encode(resourceID, data));
        _depositRecords[depositNonce][destinationChainID] = data;

        address handler = _resourceIDToHandlerAddress[resourceID];
        address tokenAddress = IDepositExecute(handler).getAddressFromResourceId(resourceID);
        
        emit Deposit(
            _chainID,
            destinationChainID,
            resourceID,
            depositNonce,
            msg.sender,
            recipientAddress,
            tokenAddress,
            amount,
            dataHash
        );
    }

    function executeProposal(
        bytes8 originChainID,
        bytes8 destinationChainID,
        uint64 depositNonce,
        bytes32 resourceID,
        address payable recipientAddress,
        uint256 amount,
        bytes calldata params
    ) external onlyBackendSrv whenNotPaused {

        bytes memory data = abi.encode(amount, recipientAddress);
        bytes32 nonceAndID = keccak256(
            abi.encode(depositNonce, originChainID, destinationChainID)
        );
        bytes32 dataHash = keccak256(abi.encode(resourceID, data));

        require(
            !_executedProposals[nonceAndID][dataHash],
            "proposal already executed"
        );
        require(destinationChainID == _chainID, "ChainID Incorrect");

        _executedProposals[nonceAndID][dataHash] = true;

        if (resourceID == _nativeResourceID) {
            recipientAddress.transfer(amount);
        } else {
            address handler = _resourceIDToHandlerAddress[resourceID];
            require(handler != address(0), "resourceID not mapped to handler");

            IDepositExecute depositHandler = IDepositExecute(handler);
            depositHandler.executeProposal(
                resourceID,
                recipientAddress,
                amount,
                params
            );
        }

        emit ProposalEvent(
            originChainID,
            destinationChainID,
            recipientAddress,
            amount,
            depositNonce,
            ProposalStatus.Executed,
            resourceID,
            dataHash
        );
    }

    function adminCollectFees(address payable recipient, uint256 amount) external onlyOwner {

        uint256 amountToTransfer = amount < address(this).balance
            ? amount
            : address(this).balance;
        recipient.transfer(amountToTransfer);
    }

    function depositFunds() external payable onlyOwner {}

}