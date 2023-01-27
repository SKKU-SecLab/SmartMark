



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



pragma solidity >=0.6.0 <0.8.0;


abstract contract OwnableV2 is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function setOwner(address newOwner) internal {
        _owner = newOwner;
    }
}



pragma solidity 0.6.12;


contract ClearAccessControl is OwnableV2 {

    address public DAO;

    mapping(address => mapping(bytes4 => bool)) public methods;

    event CallExecuted(address target, uint256 value, bytes data);
    event AddDAOMethod(address _target, bytes4 _method);
    event UpdateDAO(address _DAO);

    constructor(address _owner, address _DAO) public {
        setOwner(_owner);
        DAO = _DAO;
    }

    function setDao(address _DAO) external onlyOwner {

        require(DAO == address(0), "DAO not null");
        DAO = _DAO;
        emit UpdateDAO(_DAO);
    }

    function addDaoMethod(address _target, bytes4 _method) external onlyOwner {

        require(!methods[_target][_method], "repeat operation");
        methods[_target][_method] = true;
        emit AddDAOMethod(_target, _method);
    }

    modifier checkRole(address _target, bytes memory _data) {

        bytes4 _method;
        assembly {
            _method := mload(add(_data, 32))
        }
        if (_msgSender() == owner()) {
            require(!methods[_target][_method], "owner error");
        } else if (_msgSender() == DAO) {
            require(methods[_target][_method], "owner error");
        } else {
            revert();
        }
        _;
    }

    function execute(
        address target,
        uint256 value,
        bytes memory data
    ) public payable checkRole(target, data) {

        _call(target, value, data);
    }

    function _call(
        address target,
        uint256 value,
        bytes memory data
    ) private {

        (bool success, ) = target.call{value: value}(data);
        require(success, "transaction reverted");
        emit CallExecuted(target, value, data);
    }
}