

pragma solidity ^0.5.16;


contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.16;



contract Wallet is Ownable {

    function execute(
        address payable _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner returns (bool, bytes memory) {

        return _to.call.value(_value)(_data);
    }
}


pragma solidity ^0.5.16;



contract Pausable is Ownable {

    bool public paused;

    event SetPaused(bool _paused);

    constructor() public {
        emit SetPaused(false);
    }

    modifier notPaused() {

        require(!paused, "Contract is paused");
        _;
    }

    function setPaused(bool _paused) external onlyOwner {

        paused = _paused;
        emit SetPaused(_paused);
    }
}


pragma solidity ^0.5.16;


interface ERC20 {

    function transfer(address _to, uint _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function increaseApproval (address _spender, uint _addedValue) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);

}


pragma solidity ^0.5.11;


contract Model {


    event Created(bytes32 indexed _id);

    event ChangedStatus(bytes32 indexed _id, uint256 _timestamp, uint256 _status);

    event ChangedObligation(bytes32 indexed _id, uint256 _timestamp, uint256 _debt);

    event ChangedFrequency(bytes32 indexed _id, uint256 _timestamp, uint256 _frequency);

    event ChangedDueTime(bytes32 indexed _id, uint256 _timestamp, uint256 _status);

    event ChangedFinalTime(bytes32 indexed _id, uint256 _timestamp, uint64 _dueTime);

    event AddedDebt(bytes32 indexed _id, uint256 _amount);

    event AddedPaid(bytes32 indexed _id, uint256 _paid);

    bytes4 internal constant MODEL_INTERFACE = 0xaf498c35;

    uint256 public constant STATUS_ONGOING = 1;
    uint256 public constant STATUS_PAID = 2;
    uint256 public constant STATUS_ERROR = 4;


    function modelId() external view returns (bytes32);


    function descriptor() external view returns (address);


    function isOperator(address operator) external view returns (bool canOperate);


    function validate(bytes calldata data) external view returns (bool isValid);



    function getStatus(bytes32 id) external view returns (uint256 status);


    function getPaid(bytes32 id) external view returns (uint256 paid);


    function getObligation(bytes32 id, uint64 timestamp) external view returns (uint256 amount, bool defined);


    function getClosingObligation(bytes32 id) external view returns (uint256 amount);


    function getDueTime(bytes32 id) external view returns (uint256 timestamp);



    function getFrequency(bytes32 id) external view returns (uint256 frequency);


    function getInstallments(bytes32 id) external view returns (uint256 installments);


    function getFinalTime(bytes32 id) external view returns (uint256 timestamp);


    function getEstimateObligation(bytes32 id) external view returns (uint256 amount);



    function create(bytes32 id, bytes calldata data) external returns (bool success);


    function addPaid(bytes32 id, uint256 amount) external returns (uint256 real);


    function addDebt(bytes32 id, uint256 amount) external returns (bool added);



    function run(bytes32 id) external returns (bool effect);

}


pragma solidity ^0.5.16;


interface DebtEngine {

    function pay(
        bytes32 _id,
        uint256 _amount,
        address _origin,
        bytes calldata _oracleData
    ) external returns (uint256 paid, uint256 paidToken);

}


pragma solidity ^0.5.16;




interface LoanManager {

    function token() external view returns (ERC20);

    function debtEngine() external view returns (DebtEngine);

    function getStatus(uint256 _id) external view returns (uint256);

    function getModel(uint256 _id) external view returns (Model);

    function cosign(uint256 _id, uint256 _cost) external returns (bool);

    function getCreator(uint256 _id) external view returns (address);

}


pragma solidity ^0.5.11;



contract Cosigner {

    uint256 public constant VERSION = 2;

    function url() external view returns (string memory);


    function cost(
        LoanManager manager,
        uint256 index,
        bytes calldata data,
        bytes calldata oracleData
    )
        external view returns (uint256);


    function requestCosign(
        LoanManager manager,
        uint256 index,
        bytes calldata data,
        bytes calldata oracleData
    )
        external returns (bool);


    function claim(LoanManager manager, uint256 index, bytes calldata oracleData) external returns (bool);

}


pragma solidity ^0.5.16;










contract RPCosignerV2 is Cosigner, Ownable, Wallet, Pausable {

    uint256 public deltaPayment = 1 days;
    bool public legacyEnabled = true;

    LoanManager public manager;
    DebtEngine public engine;

    mapping(address => bool) public originators;
    mapping(uint256 => bool) public liability;

    event SetOriginator(address _originator, bool _enabled);
    event SetDeltaPayment(uint256 _prev, uint256 _val);
    event SetLegacyEnabled(bool _enabled);
    event Cosigned(uint256 _id);
    event Paid(uint256 _id, uint256 _amount, uint256 _tokens);

    string private constant ERROR_PREFIX = "rpcosigner: ";

    string private constant ERROR_INVALID_MANAGER = string(abi.encodePacked(ERROR_PREFIX, "invalid loan manager"));
    string private constant ERROR_INVALID_ORIGINATOR = string(abi.encodePacked(ERROR_PREFIX, "invalid loan originator"));
    string private constant ERROR_DUPLICATED_LIABILITY = string(abi.encodePacked(ERROR_PREFIX, "duplicated liability"));
    string private constant ERROR_COSIGN_FAILED = string(abi.encodePacked(ERROR_PREFIX, "failed cosign"));
    string private constant ERROR_INVALID_LOAN_STATUS = string(abi.encodePacked(ERROR_PREFIX, "invalid loan status"));
    string private constant ERROR_LOAN_NOT_OUTSTANDING = string(abi.encodePacked(ERROR_PREFIX, "not outstanding loan"));
    string private constant ERROR_LEGACY_DISABLED = string(abi.encodePacked(ERROR_PREFIX, "legacy claim is disabled"));

    uint256 private constant LOAN_STATUS_LENT = 1;

    constructor(
        LoanManager _manager
    ) public {
        ERC20 _token = _manager.token();
        DebtEngine tengine = _manager.debtEngine();
        _token.approve(address(tengine), uint(-1));
        manager = _manager;
        engine = tengine;
        emit SetDeltaPayment(0, deltaPayment);
        emit SetLegacyEnabled(legacyEnabled);
    }

    function setOriginator(address _originator, bool _enabled) external onlyOwner {

        emit SetOriginator(_originator, _enabled);
        originators[_originator] = _enabled;
    }

    function setDeltaPayment(uint256 _delta) external onlyOwner {

        emit SetDeltaPayment(deltaPayment, _delta);
        deltaPayment = _delta;
    }

    function setLegacyEnabled(bool _enabled) external onlyOwner {

        emit SetLegacyEnabled(_enabled);
        legacyEnabled = _enabled;
    }

    function url() external view returns (string memory) {

        return "";
    }

    function cost(
        LoanManager,
        uint256,
        bytes calldata,
        bytes calldata
    ) external view returns (uint256) {

        return 0;
    }

    function requestCosign(
        LoanManager _manager,
        uint256 _index,
        bytes calldata,
        bytes calldata
    ) external notPaused returns (bool) {

        require(_manager == manager, ERROR_INVALID_MANAGER);
        require(originators[_manager.getCreator(_index)], ERROR_INVALID_ORIGINATOR);
        require(!liability[_index], ERROR_DUPLICATED_LIABILITY);
        liability[_index] = true;
        require(_manager.cosign(_index, 0), ERROR_COSIGN_FAILED);
        emit Cosigned(_index);
        return true;
    }

    function claim(
        LoanManager _manager,
        uint256 _index,
        bytes calldata _oracleData
    ) external returns (bool) {

        require(_manager == manager, ERROR_INVALID_MANAGER);
        require(_manager.getStatus(_index) == LOAN_STATUS_LENT, ERROR_INVALID_LOAN_STATUS);

        Model model = _manager.getModel(_index);

        uint256 dueTime = model.getDueTime(bytes32(_index));
        require(dueTime + deltaPayment < now, ERROR_LOAN_NOT_OUTSTANDING);

        if (!liability[_index]) {
            require(originators[_manager.getCreator(_index)], ERROR_INVALID_ORIGINATOR);
            require(legacyEnabled, ERROR_LEGACY_DISABLED);
        }

        (uint256 paid, uint256 tokens) = engine.pay(bytes32(_index), uint(-1), address(this), _oracleData);
        emit Paid(_index, paid, tokens);
        return true;
    }
}