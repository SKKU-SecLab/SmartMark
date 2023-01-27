
pragma solidity 0.4.26;

contract IOwned {

    function owner() public view returns (address) {this;}


    function transferOwnership(address _newOwner) public;

    function acceptOwnership() public;

}

contract IERC20Token {

    function name() public view returns (string) {this;}

    function symbol() public view returns (string) {this;}

    function decimals() public view returns (uint8) {this;}

    function totalSupply() public view returns (uint256) {this;}

    function balanceOf(address _owner) public view returns (uint256) {_owner; this;}

    function allowance(address _owner, address _spender) public view returns (uint256) {_owner; _spender; this;}


    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

}

contract INonStandardERC20 {

    function name() public view returns (string) {this;}

    function symbol() public view returns (string) {this;}

    function decimals() public view returns (uint8) {this;}

    function totalSupply() public view returns (uint256) {this;}

    function balanceOf(address _owner) public view returns (uint256) {_owner; this;}

    function allowance(address _owner, address _spender) public view returns (uint256) {_owner; _spender; this;}


    function transfer(address _to, uint256 _value) public;

    function transferFrom(address _from, address _to, uint256 _value) public;

    function approve(address _spender, uint256 _value) public;

}

contract IBancorX {

    function xTransfer(bytes32 _toBlockchain, bytes32 _to, uint256 _amount, uint256 _id) public;

    function getXTransferAmount(uint256 _xTransferId, address _for) public view returns (uint256);

}

contract ITokenHolder is IOwned {

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;

}

contract Utils {

    constructor() public {
    }

    modifier greaterThanZero(uint256 _amount) {

        require(_amount > 0);
        _;
    }

    modifier validAddress(address _address) {

        require(_address != address(0));
        _;
    }

    modifier notThis(address _address) {

        require(_address != address(this));
        _;
    }

}

contract Owned is IOwned {

    address public owner;
    address public newOwner;

    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier ownerOnly {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public ownerOnly {

        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract TokenHolder is ITokenHolder, Owned, Utils {

    constructor() public {
    }

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_to)
        notThis(_to)
    {

        INonStandardERC20(_token).transfer(_to, _amount);
    }
}

contract AirDropper is TokenHolder {

    enum State {
        storeEnabled,
        storeDisabled,
        transferEnabled
    }

    address public agent;
    State public state;
    bytes32 public storedBalancesCRC;

    mapping (address => uint256) public storedBalances;
    mapping (address => uint256) public transferredBalances;

    constructor() TokenHolder() public {
        state = State.storeEnabled;
    }

    function setAgent(address _agent) external ownerOnly {

        agent = _agent;
    }

    function setState(State _state) external ownerOnly {

        state = _state;
    }

    function storeBatch(address[] _targets, uint256[] _amounts) external {

        bytes32 crc = 0;
        require(msg.sender == agent && state == State.storeEnabled);
        uint256 length = _targets.length;
        require(length == _amounts.length);
        for (uint256 i = 0; i < length; i++) {
            address target = _targets[i];
            uint256 amount = _amounts[i];
            require(storedBalances[target] == 0);
            storedBalances[target] = amount;
            crc ^= keccak256(abi.encodePacked(_targets[i], _amounts[i]));
        }
        storedBalancesCRC ^= crc;
    }

    function transferEth(IERC20Token _token, address[] _targets, uint256[] _amounts) external {

        require(msg.sender == agent && state == State.transferEnabled);
        uint256 length = _targets.length;
        require(length == _amounts.length);
        for (uint256 i = 0; i < length; i++) {
            address target = _targets[i];
            uint256 amount = _amounts[i];
            require(storedBalances[target] == amount);
            require(transferredBalances[target] == 0);
            require(_token.transfer(target, amount));
            transferredBalances[target] = amount;
        }
    }

    function transferEos(IBancorX _bancorX, bytes32 _target, uint256 _amount) external {

        require(msg.sender == agent && state == State.transferEnabled);
        require(storedBalances[_bancorX] == _amount);
        require(transferredBalances[_bancorX] == 0);
        _bancorX.xTransfer("eos", _target, _amount, 0);
        transferredBalances[_bancorX] = _amount;
    }
}