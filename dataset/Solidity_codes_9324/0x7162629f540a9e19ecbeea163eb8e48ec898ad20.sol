

pragma solidity >=0.8.0 <0.9.0;

interface IERC1155TokenReceiver {

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external returns (bytes4);

}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IMultiSigEthAdmin is IERC1155TokenReceiver, IERC165 {

    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Revocation(address indexed sender, uint256 indexed transactionId);
    event Submission(uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    event Deposit(address indexed sender, uint256 value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint256 required);

    receive() external payable;

    function submitTransaction(
        address destination,
        uint256 value,
        bytes memory data
    ) external returns (uint256 transactionId);


    function addOwner(address owner) external;


    function removeOwner(address owner) external;


    function replaceOwner(address owner, address newOwner) external;


    function changeRequirement(uint256 _required) external;


    function confirmTransaction(uint256 transactionId) external;


    function revokeConfirmation(uint256 transactionId) external;


    function executeTransaction(uint256 transactionId) external;


    function isConfirmed(uint256 transactionId) external view returns (bool);


    function getConfirmationCount(uint256 transactionId)
        external
        view
        returns (uint256 count);


    function getTransactionCount(bool pending, bool executed)
        external
        view
        returns (uint256 count);


    function getOwners() external view returns (address[] memory);


    function getRequired() external view returns (uint256);


    function getConfirmations(uint256 transactionId)
        external
        view
        returns (address[] memory _confirmations);


    function getTransactionIds(
        uint256 from,
        uint256 to,
        bool pending,
        bool executed
    ) external view returns (uint256[] memory _transactionIds);

}

interface IMultiSigEthPayments is IMultiSigEthAdmin {

    event OnTokenUpdate(address indexed tokenAddress, bool allowed);
    event OnWithdrawAddressUpdate(address withdrawAddress);
    event OnPayedEthOrder(uint256 indexed orderId, uint256 amount);
    event OnPayedTokenOrder(
        uint256 indexed orderId,
        address indexed tokenAddress,
        uint256 amount
    );
    event OnEthWithdraw(address indexed receiver, uint256 amount);
    event OnTokenWithdraw(
        address indexed receiver,
        address indexed tokenAddress,
        uint256 amount
    );

    function payEthOrder(uint256 orderId) external payable;


    function payTokenOrder(
        uint256 orderId,
        address tokenAddress,
        uint256 amount
    ) external;


    function updateAllowedToken(address tokenAddress, bool allowed) external;


    function withdraw() external;


    function withdrawToken(address tokenAddress) external;


    function updateWithdrawAddress(address payable withdrawAddress) external;


    function isTokenAllowed(address tokenAddress) external view returns (bool);


    function isOrderIdExecuted(uint256 orderId) external view returns (bool);


    function getWithdrawAddress() external view returns (address);

}

contract CommonConstants {

    bytes4 internal constant ERC1155_ACCEPTED = 0xf23a6e61; // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))
    bytes4 internal constant ERC1155_BATCH_ACCEPTED = 0xbc197c81; // bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))
}

abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor() {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

contract MultiSigEthAdmin is IMultiSigEthAdmin, ERC165, CommonConstants {

    uint256 public constant MAX_OWNER_COUNT = 50;

    mapping(uint256 => Transaction) public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isOwner;
    address[] public owners;
    uint256 public required;
    uint256 public transactionCount;

    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
    }

    modifier isAuthorizedWallet() {

        require(
            msg.sender == address(this),
            "Can only be executed by the wallet contract itself."
        );
        _;
    }

    modifier isAuthorizedOwner(address owner) {

        require(isOwner[owner], "This address is not an owner.");
        _;
    }

    modifier ownerDoesNotExist(address owner) {

        require(!isOwner[owner], "This address is an owner.");
        _;
    }

    modifier transactionExists(uint256 transactionId) {

        require(
            transactions[transactionId].destination != address(0x0),
            "The transaction destination does not exist."
        );
        _;
    }

    modifier confirmed(uint256 transactionId, address owner) {

        require(
            confirmations[transactionId][owner],
            "The owner did not confirm this transactionId yet."
        );
        _;
    }

    modifier notConfirmed(uint256 transactionId, address owner) {

        require(
            !confirmations[transactionId][owner],
            "This owner did confirm this transactionId already."
        );
        _;
    }

    modifier notExecuted(uint256 transactionId) {

        require(
            !transactions[transactionId].executed,
            "This transactionId is executed already."
        );
        _;
    }

    modifier notNull(address _address) {

        require(_address != address(0x0), "The zero-address is not allowed.");
        _;
    }

    modifier validRequirement(uint256 ownerCount, uint256 _required) {

        require(
            ownerCount <= MAX_OWNER_COUNT &&
                _required <= ownerCount &&
                _required != 0 &&
                ownerCount != 0,
            "This change in requirement is not allowed."
        );
        _;
    }

    constructor(address[] memory _owners, uint256 _required)
        validRequirement(_owners.length, _required)
    {
        for (uint256 i = 0; i < _owners.length; i++) {
            require(
                !isOwner[_owners[i]] && _owners[i] != address(0x0),
                "An owner address is included multiple times or as the zero-address."
            );
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;

        _registerInterface(type(IERC1155TokenReceiver).interfaceId); // 0x4e2312e0
        _registerInterface(type(IMultiSigEthAdmin).interfaceId);
    }

    receive() external payable override {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    function submitTransaction(
        address destination,
        uint256 value,
        bytes memory data
    ) public override returns (uint256 transactionId) {

        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    function addOwner(address owner)
        public
        override
        isAuthorizedWallet()
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {

        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

    function removeOwner(address owner)
        public
        override
        isAuthorizedWallet()
        isAuthorizedOwner(owner)
    {

        isOwner[owner] = false;
        for (uint256 i = 0; i < owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.pop(); //owners.length -= 1;
        if (required > owners.length) changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

    function replaceOwner(address owner, address newOwner)
        public
        override
        isAuthorizedWallet()
        isAuthorizedOwner(owner)
        ownerDoesNotExist(newOwner)
    {

        for (uint256 i = 0; i < owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

    function changeRequirement(uint256 _required)
        public
        override
        isAuthorizedWallet()
        validRequirement(owners.length, _required)
    {

        required = _required;
        emit RequirementChange(_required);
    }

    function confirmTransaction(uint256 transactionId)
        public
        override
        isAuthorizedOwner(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {

        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    function revokeConfirmation(uint256 transactionId)
        public
        override
        isAuthorizedOwner(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {

        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    function executeTransaction(uint256 transactionId)
        public
        override
        isAuthorizedOwner(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {

        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (
                external_call(
                    txn.destination,
                    txn.value,
                    txn.data.length,
                    txn.data
                )
            ) {
                emit Execution(transactionId);
            } else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    function isConfirmed(uint256 transactionId)
        public
        view
        override
        returns (bool)
    {

        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) count += 1;
            if (count == required) return true;
        }
        return false;
    }

    function getConfirmationCount(uint256 transactionId)
        public
        view
        override
        returns (uint256 count)
    {

        for (uint256 i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) count += 1;
    }

    function getTransactionCount(bool pending, bool executed)
        public
        view
        override
        returns (uint256 count)
    {

        for (uint256 i = 0; i < transactionCount; i++)
            if (
                (pending && !transactions[i].executed) ||
                (executed && transactions[i].executed)
            ) count += 1;
    }

    function getOwners() public view override returns (address[] memory) {

        return owners;
    }

    function getRequired() public view override returns (uint256) {

        return required;
    }

    function getConfirmations(uint256 transactionId)
        public
        view
        override
        returns (address[] memory _confirmations)
    {

        address[] memory confirmationsTemp = new address[](owners.length);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++) _confirmations[i] = confirmationsTemp[i];
    }

    function getTransactionIds(
        uint256 from,
        uint256 to,
        bool pending,
        bool executed
    ) public view override returns (uint256[] memory _transactionIds) {

        uint256[] memory transactionIdsTemp = new uint256[](transactionCount);
        uint256 count = 0;
        uint256 i;
        for (i = 0; i < transactionCount; i++)
            if (
                (pending && !transactions[i].executed) ||
                (executed && transactions[i].executed)
            ) {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint256[](to - from);
        for (i = from; i < to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        return ERC1155_ACCEPTED;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {

        return ERC1155_BATCH_ACCEPTED;
    }

    function external_call(
        address destination,
        uint256 value,
        uint256 dataLength,
        bytes memory data
    ) internal returns (bool) {

        bool result;
        assembly {
            let x := mload(0x40) // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas(), 34710), // 34710 is the value that solidity is currently emitting
                destination,
                value,
                d,
                dataLength, // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0 // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }

    function addTransaction(
        address destination,
        uint256 value,
        bytes memory data
    ) internal notNull(destination) returns (uint256 transactionId) {

        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract MultiSigEthPayments is IMultiSigEthPayments, MultiSigEthAdmin {


    mapping(address => bool) private _tokenAddressIsAllowed;
    mapping(uint256 => bool) private _orderIdIsExecuted;
    address payable private _withdrawAddress;


    constructor(
        address[] memory _owners,
        address[] memory allowedTokens,
        uint256 _required,
        address payable withdrawAddress
    ) MultiSigEthAdmin(_owners, _required) {
        require(
            withdrawAddress != address(0),
            "A withdraw address is required"
        );

        for (uint256 index = 0; index < allowedTokens.length; index++) {
            _updateAllowedToken(allowedTokens[index], true);
        }

        _updateWithdrawAddress(withdrawAddress);

        _registerInterface(type(IMultiSigEthPayments).interfaceId);
    }

    function payEthOrder(uint256 orderId) external payable override {

        require(
            !_orderIdIsExecuted[orderId],
            "This order is executed already."
        );
        _orderIdIsExecuted[orderId] = true;
        OnPayedEthOrder(orderId, msg.value);
    }

    function payTokenOrder(
        uint256 orderId,
        address tokenAddress,
        uint256 amount
    ) external override {

        require(
            _tokenAddressIsAllowed[tokenAddress],
            "This token is not allowed."
        );
        require(
            !_orderIdIsExecuted[orderId],
            "This order is executed already."
        );
        IERC20 tokenContract = IERC20(tokenAddress);

        bool success =
            tokenContract.transferFrom(msg.sender, address(this), amount);
        require(success, "Paying the order with tokens failed.");

        _orderIdIsExecuted[orderId] = true;
        OnPayedTokenOrder(orderId, tokenAddress, amount);
    }

    function updateAllowedToken(address tokenAddress, bool allowed)
        public
        override
        isAuthorizedWallet()
    {

        _updateAllowedToken(tokenAddress, allowed);
    }

    function updateWithdrawAddress(address payable withdrawAddress)
        public
        override
        isAuthorizedWallet()
    {

        _updateWithdrawAddress(withdrawAddress);
    }

    function withdraw() external override isAuthorizedOwner(msg.sender) {

        uint256 amount = address(this).balance;
        _withdrawAddress.transfer(amount);

        emit OnEthWithdraw(_withdrawAddress, amount);
    }

    function withdrawToken(address tokenAddress)
        external
        override
        isAuthorizedOwner(msg.sender)
    {

        IERC20 erc20Contract = IERC20(tokenAddress);
        uint256 amount = erc20Contract.balanceOf(address(this));
        erc20Contract.transfer(_withdrawAddress, amount);

        emit OnTokenWithdraw(_withdrawAddress, tokenAddress, amount);
    }

    function isTokenAllowed(address tokenAddress)
        public
        view
        override
        returns (bool)
    {

        return _tokenAddressIsAllowed[tokenAddress];
    }

    function isOrderIdExecuted(uint256 orderId)
        public
        view
        override
        returns (bool)
    {

        return _orderIdIsExecuted[orderId];
    }

    function getWithdrawAddress() public view override returns (address) {

        return _withdrawAddress;
    }

    function _updateWithdrawAddress(address payable withdrawAddress) private {

        _withdrawAddress = withdrawAddress;
        OnWithdrawAddressUpdate(withdrawAddress);
    }

    function _updateAllowedToken(address tokenAddress, bool allowed) private {

        _tokenAddressIsAllowed[tokenAddress] = allowed;
        OnTokenUpdate(tokenAddress, allowed);
    }
}