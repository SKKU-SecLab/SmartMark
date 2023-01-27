
pragma solidity ^0.5.11;


contract IERC173 {

    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);


    function transferOwnership(address _newOwner) external;

}


contract Ownable is IERC173 {

    address internal _owner;

    modifier onlyOwner() {

        require(msg.sender == _owner, "The owner should be the sender");
        _;
    }

    constructor() public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0x0), msg.sender);
    }

    function owner() external view returns (address) {

        return _owner;
    }

    function transferOwnership(address _newOwner) external onlyOwner {

        require(_newOwner != address(0), "0x0 Is not a valid owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }
}


interface IERC20 {

    function transfer(address _to, uint _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function increaseApproval (address _spender, uint _addedValue) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);

}


library SafeERC20 {

    function safeTransfer(IERC20 _token, address _to, uint256 _value) internal returns (bool) {

        uint256 prevBalance = _token.balanceOf(address(this));

        if (prevBalance < _value) {
            return false;
        }

        address(_token).call(
           abi.encodeWithSignature("transfer(address,uint256)", _to, _value)
        );

        return prevBalance - _value == _token.balanceOf(address(this));
    }

    function safeTransferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool)
    {

        uint256 prevBalance = _token.balanceOf(_from);

        if (
           prevBalance < _value || // Insufficient funds
            _token.allowance(_from, address(this)) < _value // Insufficient allowance
        ) {
            return false;
        }

        address(_token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _value)
        );

        return prevBalance - _value == _token.balanceOf(_from);
    }

    function safeApprove(IERC20 _token, address _spender, uint256 _value) internal returns (bool) {

        address(_token).call(
           abi.encodeWithSignature("approve(address,uint256)",_spender, _value)
        );

        return _token.allowance(address(this), _spender) == _value;
    }

    function clearApprove(IERC20 _token, address _spender) internal returns (bool) {

        bool success = safeApprove(_token, _spender, 0);

        if (!success) {
            success = safeApprove(_token, _spender, 1);
        }

        return success;
    }
}


library SafeMath {

    using SafeMath for uint256;

    function add(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 z = x + y;
        require(z >= x, "Add overflow");
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256) {

        require(x >= y, "Sub overflow");
        return x - y;
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256) {

        if (x == 0) {
            return 0;
        }

        uint256 z = x * y;
        require(z/x == y, "Mul overflow");
        return z;
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256) {

        require(y != 0, "Div by zero");
        return x / y;
    }

    function muldiv(uint256 x, uint256 y, uint256 z) internal pure returns (uint256) {

        require(z != 0, "div by zero");
        return x.mul(y) / z;
    }
}


contract EmytoTokenEscrow is Ownable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;


    event CreateEscrow(
        bytes32 _escrowId,
        address _agent,
        address _depositant,
        address _retreader,
        uint256 _fee,
        IERC20 _token,
        uint256 _salt
    );

    event SignedCreateEscrow(bytes32 _escrowId, bytes _agentSignature);

    event CancelSignature(bytes _agentSignature);

    event Deposit(
        bytes32 _escrowId,
        uint256 _toEscrow,
        uint256 _toEmyto
    );

    event Withdraw(
        bytes32 _escrowId,
        address _sender,
        address _to,
        uint256 _toAmount,
        uint256 _toAgent
    );

    event Cancel(bytes32 _escrowId, uint256 _amount);

    event SetEmytoFee(uint256 _fee);

    event EmytoWithdraw(IERC20 _token, address _to, uint256 _amount);

    struct Escrow {
        address agent;
        address depositant;
        address retreader;
        uint256 fee;
        IERC20 token;
        uint256 balance;
    }

    uint256 public BASE = 10000;
    uint256 private MAX_EMYTO_FEE = 50;
    uint256 private MAX_AGENT_FEE = 1000;
    uint256 public emytoFee;

    mapping(address => uint256) public emytoBalances;
    mapping(bytes32 => Escrow) public escrows;

    mapping (address => mapping (bytes => bool)) public canceledSignatures;


    function setEmytoFee(uint256 _fee) external onlyOwner {

        require(_fee <= MAX_EMYTO_FEE, "setEmytoFee: The emyto fee should be low or equal than the MAX_EMYTO_FEE");
        emytoFee = _fee;

        emit SetEmytoFee(_fee);
    }

    function emytoWithdraw(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) external onlyOwner {

        require(_to != address(0), "emytoWithdraw: The to address 0 its invalid");

        emytoBalances[address(_token)] = emytoBalances[address(_token)].sub(_amount);

        require(
            _token.safeTransfer(_to, _amount),
            "emytoWithdraw: Error transfer to emyto"
        );

        emit EmytoWithdraw(_token, _to, _amount);
    }


    function calculateId(
        address _agent,
        address _depositant,
        address _retreader,
        uint256 _fee,
        IERC20 _token,
        uint256 _salt
    ) public view returns(bytes32) {

        return keccak256(
            abi.encodePacked(
                address(this),
                _agent,
                _depositant,
                _retreader,
                _fee,
                _token,
                _salt
            )
        );
    }


    function createEscrow(
        address _depositant,
        address _retreader,
        uint256 _fee,
        IERC20 _token,
        uint256 _salt
    ) external returns(bytes32 escrowId) {

        escrowId = _createEscrow(
            msg.sender,
            _depositant,
            _retreader,
            _fee,
            _token,
            _salt
        );
    }

    function signedCreateEscrow(
        address _agent,
        address _depositant,
        address _retreader,
        uint256 _fee,
        IERC20 _token,
        uint256 _salt,
        bytes calldata _agentSignature
    ) external returns(bytes32 escrowId) {

        escrowId = _createEscrow(
            _agent,
            _depositant,
            _retreader,
            _fee,
            _token,
            _salt
        );

        require(!canceledSignatures[_agent][_agentSignature], "signedCreateEscrow: The signature was canceled");

        require(
            _agent == _ecrecovery(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", escrowId)), _agentSignature),
            "signedCreateEscrow: Invalid agent signature"
        );

        emit SignedCreateEscrow(escrowId, _agentSignature);
    }

    function cancelSignature(bytes calldata _agentSignature) external {

        canceledSignatures[msg.sender][_agentSignature] = true;

        emit CancelSignature(_agentSignature);
    }

    function deposit(bytes32 _escrowId, uint256 _amount) external {

        Escrow storage escrow = escrows[_escrowId];
        require(msg.sender == escrow.depositant, "deposit: The sender should be the depositant");

        uint256 toEmyto = _feeAmount(_amount, emytoFee);

        require(
            escrow.token.safeTransferFrom(msg.sender, address(this), _amount),
            "deposit: Error deposit tokens"
        );

        emytoBalances[address(escrow.token)] += toEmyto;
        uint256 toEscrow = _amount.sub(toEmyto);
        escrow.balance += toEscrow;

        emit Deposit(_escrowId, toEscrow, toEmyto);
    }

    function withdrawToRetreader(bytes32 _escrowId, uint256 _amount) external {

        Escrow storage escrow = escrows[_escrowId];
        _withdraw(_escrowId, escrow.depositant, escrow.retreader, _amount);
    }

    function withdrawToDepositant(bytes32 _escrowId, uint256 _amount) external {

        Escrow storage escrow = escrows[_escrowId];
        _withdraw(_escrowId, escrow.retreader, escrow.depositant, _amount);
    }

    function cancel(bytes32 _escrowId) external {

        Escrow storage escrow = escrows[_escrowId];
        require(msg.sender == escrow.agent, "cancel: The sender should be the agent");

        uint256 balance = escrow.balance;
        address depositant = escrow.depositant;
        IERC20 token = escrow.token;

        delete escrows[_escrowId];

        if (balance != 0)
            require(
                token.safeTransfer(depositant, balance),
                "cancel: Error transfer to the depositant"
            );

        emit Cancel(_escrowId, balance);
    }


    function _createEscrow(
        address _agent,
        address _depositant,
        address _retreader,
        uint256 _fee,
        IERC20 _token,
        uint256 _salt
    ) internal returns(bytes32 escrowId) {

        require(_fee <= MAX_AGENT_FEE, "createEscrow: The agent fee should be low or equal than 1000");

        escrowId = calculateId(
            _agent,
            _depositant,
            _retreader,
            _fee,
            _token,
            _salt
        );

        require(escrows[escrowId].agent == address(0), "createEscrow: The escrow exists");

        escrows[escrowId] = Escrow({
            agent: _agent,
            depositant: _depositant,
            retreader: _retreader,
            fee: _fee,
            token: _token,
            balance: 0
        });

        emit CreateEscrow(escrowId, _agent, _depositant, _retreader, _fee, _token, _salt);
    }

    function _withdraw(
        bytes32 _escrowId,
        address _approved,
        address _to,
        uint256 _amount
    ) internal {

        Escrow storage escrow = escrows[_escrowId];
        require(msg.sender == _approved || msg.sender == escrow.agent, "_withdraw: The sender should be the _approved or the agent");

        uint256 toAgent = _feeAmount(_amount, escrow.fee);
        escrow.balance = escrow.balance.sub(_amount);
        require(
            escrow.token.safeTransfer(escrow.agent, toAgent),
            "_withdraw: Error transfer tokens to the agent"
        );
        uint256 toAmount = _amount.sub(toAgent);
        require(
            escrow.token.safeTransfer(_to, toAmount),
            "_withdraw: Error transfer to the _to"
        );

        emit Withdraw(_escrowId, msg.sender, _to, toAmount, toAgent);
    }

    function _feeAmount(
        uint256 _amount,
        uint256 _fee
    ) internal view returns(uint256) {

        return _amount.mul(_fee).div(BASE);
    }

    function _ecrecovery(bytes32 _hash, bytes memory _sig) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := and(mload(add(_sig, 65)), 255)
        }

        if (v < 27) {
            v += 27;
        }

        return ecrecover(_hash, v, r, s);
    }
}