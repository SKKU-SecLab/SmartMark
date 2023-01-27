

pragma solidity =0.7.6;

interface IOperContract {

    function operator() external view returns (address);


    function owner() external view returns (address);

}


pragma solidity =0.7.6;


interface ISwapDirector is IOperContract {

    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.7.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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



pragma solidity =0.7.6;


contract Operatable is Ownable {

    address public operator;

    event SetOperator(address indexed oldOperator, address indexed newOperator);

    constructor(){
        operator = msg.sender;
        emit SetOperator(address(0), operator);
    }

    modifier onlyOperator() {

        require(msg.sender == operator, 'not operator');
        _;
    }

    function setOperator(address newOperator) public onlyOwner {

        require(newOperator != address(0), 'bad new operator');
        address oldOperator = operator;
        operator = newOperator;
        emit SetOperator(oldOperator, newOperator);
    }
}



pragma solidity =0.7.6;



contract CheckOper is IOperContract {

    Operatable public operatable;

    event SetOperatorContract(address indexed oldOperator, address indexed newOperator);

    constructor(address _oper){
        operatable = Operatable(_oper);
        emit SetOperatorContract(address(0), _oper);
    }

    modifier onlyOperator() {

        require(operatable.operator() == msg.sender, 'not operator');
        _;
    }

    modifier onlyOwner() {

        require(operatable.owner() == msg.sender, 'Ownable: caller is not the owner');
        _;
    }

    function operator() public view override returns (address) {

        return operatable.operator();
    }

    function owner() public view override returns (address) {

        return operatable.owner();
    }

    function setOperContract(address _oper) public onlyOwner {

        require(_oper != address(0), 'bad new operator');
        address oldOperator = _oper;
        operatable = Operatable(_oper);
        emit SetOperatorContract(oldOperator, _oper);
    }
}


pragma solidity =0.7.6;



contract SwapDirector is ISwapDirector, CheckOper {

    mapping(uint24 => int24) private _feeAmountTickSpacing;

    constructor(address _operatorMsg) CheckOper(_operatorMsg) {
        _feeAmountTickSpacing[500] = 10;
        _feeAmountTickSpacing[1000] = 20;
        _feeAmountTickSpacing[1500] = 30;
        _feeAmountTickSpacing[2000] = 40;
        _feeAmountTickSpacing[3000] = 60;
        _feeAmountTickSpacing[4000] = 80;
        _feeAmountTickSpacing[5000] = 100;
        _feeAmountTickSpacing[10000] = 200;
    }

    function feeAmountTickSpacing(uint24 fee) public view override returns (int24) {

        return _feeAmountTickSpacing[fee];
    }

    function enableFeeAmount(uint24 fee, int24 tickSpacing) public onlyOperator {

        require(fee < 1000000);
        require(tickSpacing > 0 && tickSpacing < 16384);
        require(_feeAmountTickSpacing[fee] == 0);
        _feeAmountTickSpacing[fee] = tickSpacing;
    }
}