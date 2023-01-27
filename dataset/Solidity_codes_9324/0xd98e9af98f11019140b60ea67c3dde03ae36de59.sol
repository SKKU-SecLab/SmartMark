


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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}

contract Escrow is Pausable, Ownable {

    enum Statuses {
        Pending, // When the contract is created
        Completed, // When buyer completes it
        Cancelled, // When seller cancels the contact
        Paused // When seller puts it on HOLD
    }

    struct Contract {
        uint256 id; // Contract id
        address creator; // Creator of the contract
        address buyer; // Member 2 of the contract
        address creatorInputToken; // What creator is giving
        address buyerInputToken; // What creator want in exchange
        uint256 creatorInputAmount; // How much the creator is giving
        uint256 buyerInputAmount; // How much the creator want in exchange
        Statuses status; // Current status of contract
        uint256 createdAt;
        uint256 updatedAt;
    }

    Contract[] contracts;
    uint256 public feePercentage;
    mapping(address => uint256) public fees;
    mapping(address => uint256[]) address_contract_ids; // Contract IDs associated with each address

    event ContractCreated(Contract _contract);

    event ContractCancelled(Contract _contract);

    event ContractPaused(Contract _contract);

    event ContractUnpaused(Contract _contract);

    event ContractCompleted(
        Contract _contract,
        uint256 _creatorReceivedAmount,
        uint256 _buyerReceivedAmount,
        uint256 _serviceFeeForCreatorOutput,
        uint256 _serviceFeeForBuyerOutput
    );

    constructor(uint256 _feePercentage) {
        require(_feePercentage < 10000, "You should charge less than 100% :-)");

        feePercentage = _feePercentage; // 100 = 1%, 1 = 0.01%
    }

    modifier onlyCreator(uint256 _id) {

        require(contracts[_id].creator == msg.sender, "Error: Only creator");
        _;
    }

    modifier onlyBuyer(uint256 _id) {

        require(
            contracts[_id].buyer == msg.sender ||
                (contracts[_id].buyer == address(0) && contracts[_id].creator != msg.sender),
            "Error: Only buyer"
        );
        _;
    }

    modifier onlyPending(uint256 _id) {

        require(contracts[_id].status == Statuses.Pending, "Error: Contract is not active.");
        _;
    }

    modifier onlyPausedContract(uint256 _id) {

        require(contracts[_id].status == Statuses.Paused, "Error: Contract is not paused.");
        _;
    }

    modifier onlyPendingOrPaused(uint256 _id) {

        require(
            contracts[_id].status == Statuses.Pending || contracts[_id].status == Statuses.Paused,
            "Error: Contract is not pending or paused."
        );
        _;
    }

    function renounceOwnership() public view override onlyOwner {

        revert("Disabled!");
    }

    function pause() public onlyOwner {

        _pause();
    }

    function unpause() public onlyOwner {

        _unpause();
    }

    function calculateFee(uint256 _amount) public view returns (uint256) {

        if (feePercentage > 0 && (_amount / 10000) * 10000 == _amount) {
            return (_amount / 10000) * feePercentage;
        }

        return 0;
    }

    function find(uint256 _id) public view returns (Contract memory) {

        return contracts[_id];
    }

    function create(
        address _buyer,
        address _creatorInputToken,
        address _buyerInputToken,
        uint256 _createInputAmount,
        uint256 _buyerInputAmount
    ) public payable whenNotPaused returns (uint256) {

        require(_creatorInputToken != _buyerInputToken, "Error: Cannot create contract with same currencies.");
        require(msg.sender != _buyer, "Error: You cannot create contract with yourself.");

        if (_creatorInputToken != address(0)) {
            IERC20(_creatorInputToken).transferFrom(msg.sender, address(this), _createInputAmount);
        } else {
            require(msg.value > 0, "Error: Please send some ether.");

            _createInputAmount = msg.value;
        }

        Contract memory _contract = Contract(
            contracts.length,
            msg.sender,
            _buyer,
            _creatorInputToken,
            _buyerInputToken,
            _createInputAmount,
            _buyerInputAmount,
            Statuses.Pending,
            block.timestamp,
            block.timestamp
        );

        contracts.push(_contract);

        address_contract_ids[_contract.creator].push(_contract.id);

        if (_contract.buyer != address(0)) {
            address_contract_ids[_contract.buyer].push(_contract.id);
        }

        emit ContractCreated(_contract);

        return _contract.id;
    }

    function pauseContract(uint256 _id) public onlyPending(_id) onlyCreator(_id) returns (bool) {

        Contract storage _contract = contracts[_id];
        _contract.status = Statuses.Paused;
        emit ContractPaused(_contract);
        return true;
    }

    function unpauseContract(uint256 _id) public onlyPausedContract(_id) onlyCreator(_id) returns (bool) {

        Contract storage _contract = contracts[_id];
        _contract.status = Statuses.Pending;
        emit ContractUnpaused(_contract);
        return true;
    }

    function complete(uint256 _id) public payable onlyPending(_id) onlyBuyer(_id) returns (bool) {

        Contract storage _contract = contracts[_id];

        if (_contract.buyerInputToken == address(0)) {
            require(msg.value >= _contract.buyerInputAmount, "Error: Incorrect amount.");

            _contract.status = Statuses.Completed;
            _contract.updatedAt = block.timestamp;

            if (_contract.buyer == address(0)) {
                address_contract_ids[msg.sender].push(_contract.id);
                _contract.buyer = msg.sender;
            }

            uint256 _serviceFeeForCreatorOutput = calculateFee(msg.value);
            uint256 _serviceFeeForBuyerOutput = calculateFee(_contract.creatorInputAmount);

            uint256 _creatorReceivedAmount = msg.value - _serviceFeeForCreatorOutput;
            uint256 _buyerReceivedAmount = _contract.creatorInputAmount - _serviceFeeForBuyerOutput;

            payable(_contract.creator).transfer(_creatorReceivedAmount);

            IERC20(_contract.creatorInputToken).transfer(_contract.buyer, _buyerReceivedAmount);

            fees[_contract.buyerInputToken] += _serviceFeeForCreatorOutput;
            fees[_contract.creatorInputToken] += _serviceFeeForBuyerOutput;

            emit ContractCompleted(
                _contract,
                _creatorReceivedAmount,
                _buyerReceivedAmount,
                _serviceFeeForCreatorOutput,
                _serviceFeeForBuyerOutput
            );
        } else {
            require(msg.value == 0, "Error: Please don't send any ETH.");

            IERC20(_contract.buyerInputToken).transferFrom(msg.sender, address(this), _contract.buyerInputAmount);

            _contract.status = Statuses.Completed;
            _contract.updatedAt = block.timestamp;

            if (_contract.buyer == address(0)) {
                address_contract_ids[msg.sender].push(_contract.id);
                _contract.buyer = msg.sender;
            }

            uint256 _serviceFeeForCreatorOutput = calculateFee(_contract.buyerInputAmount);
            uint256 _serviceFeeForBuyerOutput = calculateFee(_contract.creatorInputAmount);

            uint256 _creatorReceivedAmount = _contract.buyerInputAmount - _serviceFeeForCreatorOutput;
            uint256 _buyerReceivedAmount = _contract.creatorInputAmount - _serviceFeeForBuyerOutput;

            IERC20(_contract.buyerInputToken).transfer(_contract.creator, _creatorReceivedAmount);

            if (_contract.creatorInputToken == address(0)) {
                payable(_contract.buyer).transfer(_buyerReceivedAmount);
            } else {
                IERC20(_contract.creatorInputToken).transfer(_contract.buyer, _buyerReceivedAmount);
            }

            fees[_contract.buyerInputToken] += _serviceFeeForCreatorOutput;
            fees[_contract.creatorInputToken] += _serviceFeeForBuyerOutput;

            emit ContractCompleted(
                _contract,
                _creatorReceivedAmount,
                _buyerReceivedAmount,
                _serviceFeeForCreatorOutput,
                _serviceFeeForBuyerOutput
            );
        }

        return true;
    }

    function cancel(uint256 _id) public onlyPendingOrPaused(_id) onlyCreator(_id) returns (bool) {

        Contract storage _contract = contracts[_id];

        _contract.status = Statuses.Cancelled;
        _contract.updatedAt = block.timestamp;

        if (_contract.creatorInputToken == address(0)) {
            payable(_contract.creator).transfer(_contract.creatorInputAmount);
        } else {
            IERC20(_contract.creatorInputToken).transfer(_contract.creator, _contract.creatorInputAmount);
        }

        emit ContractCancelled(_contract);

        return true;
    }

    function withdrawFees(address _currency) public onlyOwner {

        uint256 _amount = fees[_currency];
        require(_amount > 0, "Nothing to withdraw!");

        fees[_currency] = 0;

        if (_currency == address(0)) {
            payable(owner()).transfer(_amount);
        } else {
            IERC20(_currency).transfer(owner(), _amount);
        }
    }

    function countContracts() public view returns (uint256) {

        return contracts.length;
    }

    function paginateContracts(uint256 _offset, uint256 _limit)
        public
        view
        returns (
            Contract[] memory _contracts,
            uint256 _nextOffset,
            uint256 _total
        )
    {

        _total = contracts.length;

        if (_limit == 0) {
            _limit = 1;
        }

        if (_limit > _total - _offset) {
            _limit = _total - _offset;
        }

        _contracts = new Contract[](_limit);

        for (uint256 _i = 0; _i < _limit; _i++) {
            _contracts[_i] = contracts[_offset + _i];
        }

        return (_contracts, _offset + _limit, _total);
    }

    function countContractsOf(address _address) public view returns (uint256) {

        return address_contract_ids[_address].length;
    }

    function paginateContractsOf(
        address _address,
        uint256 _offset,
        uint256 _limit
    )
        public
        view
        returns (
            Contract[] memory _contracts,
            uint256 _nextOffset,
            uint256 _total
        )
    {

        uint256[] memory _contractIds = address_contract_ids[_address];

        _total = _contractIds.length;

        if (_limit == 0) {
            _limit = 1;
        }

        if (_limit > _total - _offset) {
            _limit = _total - _offset;
        }

        _contracts = new Contract[](_limit);

        for (uint256 _i = 0; _i < _limit; _i++) {
            _contracts[_i] = contracts[_contractIds[_offset + _i]];
        }

        return (_contracts, _offset + _limit, _total);
    }

    function paginateContractIdsOf(
        address _address,
        uint256 _offset,
        uint256 _limit
    )
        public
        view
        returns (
            uint256[] memory,
            uint256 _nextOffset,
            uint256 _total
        )
    {

        uint256[] memory _contractIds = address_contract_ids[_address];

        _total = _contractIds.length;

        if (_limit == 0) {
            _limit = 1;
        }

        if (_limit > _total - _offset) {
            _limit = _total - _offset;
        }

        uint256[] memory _ids = new uint256[](_limit);

        for (uint256 _i = 0; _i < _limit; _i++) {
            _ids[_i] = _contractIds[_offset + _i];
        }

        return (_ids, _offset + _limit, _total);
    }
}