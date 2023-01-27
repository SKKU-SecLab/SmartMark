
pragma solidity ^0.7.4;

library SafeMath {

    function addSafe(uint _a, uint _b) internal pure returns (uint c) {

        c = _a + _b;
        require(c >= _a);
    }
    function subSafe(uint _a, uint _b) internal pure returns (uint c) {

        require(_b <= _a, "Insufficient balance");
        c = _a - _b;
    }
    function mulSafe(uint _a, uint _b) internal pure returns (uint c) {

        c = _a * _b;
        require(_a == 0 || c / _a == _b);
    }
    function divSafe(uint _a, uint _b) internal pure returns (uint c) {

        require(_b > 0);
        c = _a / _b;
    }
}


interface ERC20Interface {

    function totalSupply() external view returns (uint);

    function balanceOf(address _tokenOwner) external view returns (uint);

    function allowance(address _tokenOwner, address _spender) external view returns (uint);

    function transfer(address _to, uint _amount) external returns (bool);

    function approve(address _spender, uint _amount) external returns (bool);

    function transferFrom(address _from, address _to, uint _amount) external returns (bool);


    event Transfer(address indexed _from, address indexed _to, uint _tokens);
    event Approval(address indexed _tokenOwner, address indexed _spender, uint _tokens);
}

interface ApproveAndCallFallBack {

    function receiveApproval(address _tokenOwner, uint256 _amount, address _token, bytes memory _data) external;

}

interface SettlementInterface {

    function disburseCommissions(bool _disburseBackstop) external;

}


contract Owned {

    address public owner;
    address public newOwner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;
    }
    function acceptOwnership() public {

        require(msg.sender == newOwner);
        owner = newOwner;
        newOwner = address(0);
        emit OwnershipTransferred(owner, newOwner);
    }
}


contract yBXTBToken is ERC20Interface, Owned {

    using SafeMath for uint;

    string public constant symbol = "yBXTB";
    string public constant name = "Yield Token for BXTB";
    uint public constant decimals = 6;
    uint totalSupplyAmount;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;

    uint public pausedForSettlementBlock;

    address public settlementAdmin;
    address public serviceContractAddress;

    bool public pausedForSettlement;

    constructor() {
        totalSupplyAmount = 100000000 * 10**uint(decimals);
        emit Mint(totalSupplyAmount);

        balances[owner] = totalSupplyAmount;
        emit Transfer(address(0), owner, totalSupplyAmount);
    }

    modifier onlyPayloadSize(uint _size) {

        require(msg.data.length == _size + 4, "Input length error");
        _;
    }

    modifier pauseCheck {

        if(pausedForSettlement == true) {
            if(block.number.subSafe(pausedForSettlementBlock) >= 10) pausedForSettlement = false;
            else revert("Paused for settlement");
        }
        _;
    }

    event Mint(uint _amount);


    function totalSupply() public override view returns (uint) {

        return totalSupplyAmount.subSafe(balances[address(0)]);
    }
    function balanceOf(address _tokenOwner) public override view returns (uint) {

        return balances[_tokenOwner];
    }
    function allowance(address _tokenOwner, address _spender) public override view returns (uint) {

        return allowed[_tokenOwner][_spender];
    }

    function transfer(address _to, uint _amount) public override onlyPayloadSize(2 * 32) pauseCheck returns (bool) {

        require(_to != address(this), "Can not transfer to this");
        if(serviceContractAddress != address(0)) require(_to != serviceContractAddress, "Address not allowed");

        balances[msg.sender] = balances[msg.sender].subSafe(_amount);
        balances[_to] = balances[_to].addSafe(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    function approve(address _spender, uint _amount) public override onlyPayloadSize(2 * 32) pauseCheck returns (bool) {

        require(_amount <= balances[msg.sender], "Insufficient balance");

        if(_amount > 0) require(allowed[msg.sender][_spender] == 0, "Zero allowance first");

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
    function transferFrom(address _tokenOwner, address _to, uint _amount) public override onlyPayloadSize(3 * 32) pauseCheck returns (bool) {

        require(_to != address(this), "Can not transfer to this");
        allowed[_tokenOwner][msg.sender] = allowed[_tokenOwner][msg.sender].subSafe(_amount);
        balances[_tokenOwner] = balances[_tokenOwner].subSafe(_amount);
        balances[_to] = balances[_to].addSafe(_amount);
        emit Transfer(_tokenOwner, _to, _amount);
        return true;
    }


    function approveAndCall(address _spender, uint _amount, bytes memory _data) pauseCheck public returns (bool) {

        uint length256;
        if(_data.length > 0) {
            length256 = _data.length / 32;
            if(32 * length256 < _data.length) length256++;
        }
        require(msg.data.length == (((4 + length256) * 32) + 4), "Input length error");
        require(_amount <= balances[msg.sender], "Insufficient balance");

        if(_amount > 0) require(allowed[msg.sender][_spender] == 0, "Zero allowance first");

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _amount, address(this), _data);
        return true;
    }
    function mint(uint _newTokens) public onlyOwner pauseCheck {

        totalSupplyAmount = totalSupplyAmount.addSafe(_newTokens);
        emit Mint(totalSupplyAmount);

        balances[owner] = balances[owner].addSafe(_newTokens);
        emit Transfer(address(0), owner, _newTokens);
    }
    function totalOutstanding() public view returns (uint) {

        uint outOfCirculation;
        if(owner == address(0)) outOfCirculation = balances[address(0)];
        else outOfCirculation = balances[address(0)].addSafe(balances[owner]);
        return totalSupplyAmount.subSafe(outOfCirculation);
    }
    function setServiceContractAddress(address _setAddress) public onlyOwner onlyPayloadSize(1 * 32) {

        serviceContractAddress = _setAddress;
    }
    function performSettlement(bool _doPause, bool _doDisburseCommission, bool _doDisburseBackstop) external {

        require((msg.sender == settlementAdmin) || (msg.sender == owner), "Caller not authorized");
        pausedForSettlement = _doPause;
        if(_doPause == true) pausedForSettlementBlock = block.number;
        if(_doDisburseCommission == true) {
            require(serviceContractAddress != address(0), "Service Contract not set");
            SettlementInterface(serviceContractAddress).disburseCommissions(_doDisburseBackstop);
        }
    }
    function changeSettlementAdmin(address _newAddress) external {

        require(msg.data.length == 32 + 4, "Address error");  // Prevent input error
        require((msg.sender == settlementAdmin) || (msg.sender == owner), "Caller not authorized");
        settlementAdmin = _newAddress;
    }
    function transferAnyERC20Token(address _fromTokenContract, uint _amount) public onlyOwner returns (bool success) {

        return ERC20Interface(_fromTokenContract).transfer(owner, _amount);
    }

}