

pragma solidity ^0.8.6;

contract AnyCallProxy {

    struct Context {
        address sender;
        uint256 fromChainID;
    }

    struct FeeData {
        uint128 accruedFees;
        uint128 premium;
    }

    struct TransferData {
        uint96 effectiveTime;
        address pendingMPC;
    }

    uint256 constant EXECUTION_OVERHEAD = 100000;

    address public mpc;
    TransferData private _transferData;

    mapping(address => bool) public blacklist;
    mapping(address => mapping(address => mapping(uint256 => bool))) public whitelist;
    
    Context public context;

    mapping(address => uint256) public executionBudget;
    FeeData private _feeData;

    event LogAnyCall(
        address indexed from,
        address indexed to,
        bytes data,
        address _fallback,
        uint256 indexed toChainID
    );

    event LogAnyExec(
        address indexed from,
        address indexed to,
        bytes data,
        bool success,
        bytes result,
        address _fallback,
        uint256 indexed fromChainID
    );

    event Deposit(address indexed account, uint256 amount);
    event Withdrawl(address indexed account, uint256 amount);
    event SetBlacklist(address indexed account, bool flag);
    event SetWhitelist(
        address indexed from,
        address indexed to,
        uint256 indexed toChainID,
        bool flag
    );
    event TransferMPC(address oldMPC, address newMPC, uint256 effectiveTime);
    event UpdatePremium(uint256 oldPremium, uint256 newPremium);

    constructor(address _mpc, uint128 _premium) {
        mpc = _mpc;
        _feeData.premium = _premium;

        emit TransferMPC(address(0), _mpc, block.timestamp);
        emit UpdatePremium(0, _premium);
    }

    modifier onlyMPC() {

        require(msg.sender == mpc); // dev: only MPC
        _;
    }

    modifier charge(address _from) {

        uint256 gasUsed = gasleft() + EXECUTION_OVERHEAD;
        _;
        uint256 totalCost = (gasUsed - gasleft()) * (tx.gasprice + _feeData.premium);

        executionBudget[_from] -= totalCost;
        _feeData.accruedFees += uint128(totalCost);
    }

    function anyCall(
        address _to,
        bytes calldata _data,
        address _fallback,
        uint256 _toChainID
    ) external {

        require(!blacklist[msg.sender]); // dev: caller is blacklisted
        require(whitelist[msg.sender][_to][_toChainID]); // dev: request denied

        emit LogAnyCall(msg.sender, _to, _data, _fallback, _toChainID);
    }

    function anyExec(
        address _from,
        address _to,
        bytes calldata _data,
        address _fallback,
        uint256 _fromChainID
    ) external charge(_from) onlyMPC {

        context = Context({sender: _from, fromChainID: _fromChainID});
        (bool success, bytes memory result) = _to.call(_data);
        context = Context({sender: address(0), fromChainID: 0});

        emit LogAnyExec(_from, _to, _data, success, result, _fallback, _fromChainID);

        if (!success && _fallback != address(0)) {
            emit LogAnyCall(
                _from,
                _fallback,
                abi.encodeWithSignature("anyFallback(address,bytes)", _to, _data),
                address(0),
                _fromChainID
            );
        }
    }

    function deposit(address _account) external payable {

        executionBudget[_account] += msg.value;
        emit Deposit(_account, msg.value);
    }

    function withdraw(uint256 _amount) external {

        executionBudget[msg.sender] -= _amount;
        emit Withdrawl(msg.sender, _amount);
        (bool success,) = msg.sender.call{value: _amount}("");
        require(success);
    }

    function withdrawAccruedFees() external {

        uint256 fees = _feeData.accruedFees;
        _feeData.accruedFees = 0;
        (bool success,) = mpc.call{value: fees}("");
        require(success);
    }

    function setWhitelist(
        address _from,
        address _to,
        uint256 _toChainID,
        bool _flag
    ) external onlyMPC {

        require(_toChainID != block.chainid, "AnyCall: Forbidden");
        whitelist[_from][_to][_toChainID] = _flag;
        emit SetWhitelist(_from, _to, _toChainID, _flag);
    }

    function setBlacklist(address _account, bool _flag) external onlyMPC {

        blacklist[_account] = _flag;
        emit SetBlacklist(_account, _flag);
    }

    function setPremium(uint128 _premium) external onlyMPC {

        emit UpdatePremium(_feeData.premium, _premium);
        _feeData.premium = _premium;
    }

    function changeMPC(address _newMPC) external onlyMPC {

        mpc = _newMPC;
    }

    function accruedFees() external view returns(uint128) {

        return _feeData.accruedFees;
    }

    function premium() external view returns(uint128) {

        return _feeData.premium;
    }

    function effectiveTime() external view returns(uint256) {

        return _transferData.effectiveTime;
    }
    
    function pendingMPC() external view returns(address) {

        return _transferData.pendingMPC;
    }
}