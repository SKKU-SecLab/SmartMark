

pragma solidity 0.6.10;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {

    address private _owner;
    address private _authorizedNewOwner;

    event OwnershipTransferAuthorization(address indexed authorizedAddress);

    event OwnerUpdate(address indexed oldValue, address indexed newValue);

    constructor() internal {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function authorizedNewOwner() public view returns (address) {

        return _authorizedNewOwner;
    }

    function authorizeOwnershipTransfer(address _authorizedAddress) external {

        require(msg.sender == _owner, "Invalid sender");

        _authorizedNewOwner = _authorizedAddress;

        emit OwnershipTransferAuthorization(_authorizedNewOwner);
    }

    function assumeOwnership() external {

        require(msg.sender == _authorizedNewOwner, "Invalid sender");

        address oldValue = _owner;
        _owner = _authorizedNewOwner;
        _authorizedNewOwner = address(0);

        emit OwnerUpdate(oldValue, _owner);
    }
}

abstract contract ERC1820Registry {
    function setInterfaceImplementer(
        address _addr,
        bytes32 _interfaceHash,
        address _implementer
    ) external virtual;

    function getInterfaceImplementer(address _addr, bytes32 _interfaceHash)
        external
        virtual
        view
        returns (address);

    function setManager(address _addr, address _newManager) external virtual;

    function getManager(address _addr) public virtual view returns (address);
}

contract ERC1820Client {

    ERC1820Registry constant ERC1820REGISTRY = ERC1820Registry(
        0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24
    );

    function setInterfaceImplementation(
        string memory _interfaceLabel,
        address _implementation
    ) internal {

        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));
        ERC1820REGISTRY.setInterfaceImplementer(
            address(this),
            interfaceHash,
            _implementation
        );
    }

    function interfaceAddr(address addr, string memory _interfaceLabel)
        internal
        view
        returns (address)
    {

        bytes32 interfaceHash = keccak256(abi.encodePacked(_interfaceLabel));
        return ERC1820REGISTRY.getInterfaceImplementer(addr, interfaceHash);
    }

    function delegateManagement(address _newManager) internal {

        ERC1820REGISTRY.setManager(address(this), _newManager);
    }
}

contract ERC1820Implementer {

    bytes32 constant ERC1820_ACCEPT_MAGIC = keccak256(
        abi.encodePacked("ERC1820_ACCEPT_MAGIC")
    );

    mapping(bytes32 => bool) internal _interfaceHashes;

    function canImplementInterfaceForAddress(
        bytes32 _interfaceHash,
        address // Comments to avoid compilation warnings for unused variables. /*addr*/
    ) external view returns (bytes32) {

        if (_interfaceHashes[_interfaceHash]) {
            return ERC1820_ACCEPT_MAGIC;
        } else {
            return "";
        }
    }

    function _setInterface(string memory _interfaceLabel) internal {

        _interfaceHashes[keccak256(abi.encodePacked(_interfaceLabel))] = true;
    }
}

interface IAmpTokensSender {

    function canTransfer(
        bytes4 functionSig,
        bytes32 partition,
        address operator,
        address from,
        address to,
        uint256 value,
        bytes calldata data,
        bytes calldata operatorData
    ) external view returns (bool);


    function tokensToTransfer(
        bytes4 functionSig,
        bytes32 partition,
        address operator,
        address from,
        address to,
        uint256 value,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

}

interface IAmpTokensRecipient {

    function canReceive(
        bytes4 functionSig,
        bytes32 partition,
        address operator,
        address from,
        address to,
        uint256 value,
        bytes calldata data,
        bytes calldata operatorData
    ) external view returns (bool);


    function tokensReceived(
        bytes4 functionSig,
        bytes32 partition,
        address operator,
        address from,
        address to,
        uint256 value,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

}

interface IAmpPartitionStrategyValidator {

    function tokensFromPartitionToValidate(
        bytes4 _functionSig,
        bytes32 _partition,
        address _operator,
        address _from,
        address _to,
        uint256 _value,
        bytes calldata _data,
        bytes calldata _operatorData
    ) external;


    function tokensToPartitionToValidate(
        bytes4 _functionSig,
        bytes32 _partition,
        address _operator,
        address _from,
        address _to,
        uint256 _value,
        bytes calldata _data,
        bytes calldata _operatorData
    ) external;


    function isOperatorForPartitionScope(
        bytes32 _partition,
        address _operator,
        address _tokenHolder
    ) external view returns (bool);

}


library PartitionUtils {

    bytes32 public constant CHANGE_PARTITION_FLAG = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    function _getDestinationPartition(bytes memory _data, bytes32 _fallbackPartition)
        internal
        pure
        returns (bytes32)
    {

        if (_data.length < 64) {
            return _fallbackPartition;
        }

        (bytes32 flag, bytes32 toPartition) = abi.decode(_data, (bytes32, bytes32));
        if (flag == CHANGE_PARTITION_FLAG) {
            return toPartition;
        }

        return _fallbackPartition;
    }

    function _getPartitionPrefix(bytes32 _partition) internal pure returns (bytes4) {

        return bytes4(_partition);
    }

    function _splitPartition(bytes32 _partition)
        internal
        pure
        returns (
            bytes4,
            bytes8,
            address
        )
    {

        bytes4 prefix = bytes4(_partition);
        bytes8 subPartition = bytes8(_partition << 32);
        address addressPart = address(uint160(uint256(_partition)));
        return (prefix, subPartition, addressPart);
    }

    function _getPartitionStrategyValidatorIName(bytes4 _prefix)
        internal
        pure
        returns (string memory)
    {

        return string(abi.encodePacked("AmpPartitionStrategyValidator", _prefix));
    }
}

contract ErrorCodes {

    string internal EC_50_TRANSFER_FAILURE = "50";
    string internal EC_51_TRANSFER_SUCCESS = "51";
    string internal EC_52_INSUFFICIENT_BALANCE = "52";
    string internal EC_53_INSUFFICIENT_ALLOWANCE = "53";

    string internal EC_56_INVALID_SENDER = "56";
    string internal EC_57_INVALID_RECEIVER = "57";
    string internal EC_58_INVALID_OPERATOR = "58";

    string internal EC_59_INSUFFICIENT_RIGHTS = "59";

    string internal EC_5A_INVALID_SWAP_TOKEN_ADDRESS = "5A";
    string internal EC_5B_INVALID_VALUE_0 = "5B";
    string internal EC_5C_ADDRESS_CONFLICT = "5C";
    string internal EC_5D_PARTITION_RESERVED = "5D";
    string internal EC_5E_PARTITION_PREFIX_CONFLICT = "5E";
    string internal EC_5F_INVALID_PARTITION_PREFIX_0 = "5F";
    string internal EC_60_SWAP_TRANSFER_FAILURE = "60";
}

interface ISwapToken {

    function allowance(address owner, address spender)
        external
        view
        returns (uint256 remaining);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool success);

}

contract Amp is IERC20, ERC1820Client, ERC1820Implementer, ErrorCodes, Ownable {

    using SafeMath for uint256;


    string internal constant AMP_INTERFACE_NAME = "AmpToken";

    string internal constant ERC20_INTERFACE_NAME = "ERC20Token";

    string internal constant AMP_TOKENS_SENDER = "AmpTokensSender";

    string internal constant AMP_TOKENS_RECIPIENT = "AmpTokensRecipient";

    string internal constant AMP_TOKENS_CHECKER = "AmpTokensChecker";


    string internal _name;

    string internal _symbol;

    uint256 internal _totalSupply;

    uint256 internal constant _granularity = 1;


    mapping(address => uint256) internal _balances;


    bytes32[] internal _totalPartitions;

    mapping(bytes32 => uint256) internal _indexOfTotalPartitions;

    mapping(bytes32 => uint256) public totalSupplyByPartition;

    mapping(address => bytes32[]) internal _partitionsOf;

    mapping(address => mapping(bytes32 => uint256)) internal _indexOfPartitionsOf;

    mapping(address => mapping(bytes32 => uint256)) internal _balanceOfByPartition;

    bytes32
        public constant defaultPartition = 0x0000000000000000000000000000000000000000000000000000000000000000;

    bytes4 internal constant ZERO_PREFIX = 0x00000000;


    mapping(address => mapping(address => bool)) internal _authorizedOperator;


    mapping(bytes32 => mapping(address => mapping(address => uint256)))
        internal _allowedByPartition;

    mapping(address => mapping(bytes32 => mapping(address => bool)))
        internal _authorizedOperatorByPartition;

    address[] public collateralManagers;
    mapping(address => bool) internal _isCollateralManager;


    bytes4[] public partitionStrategies;

    mapping(bytes4 => bool) internal _isPartitionStrategy;


    ISwapToken public swapToken;

    address
        public constant swapTokenGraveyard = 0x000000000000000000000000000000000000dEaD;



    event TransferByPartition(
        bytes32 indexed fromPartition,
        address operator,
        address indexed from,
        address indexed to,
        uint256 value,
        bytes data,
        bytes operatorData
    );

    event ChangedPartition(
        bytes32 indexed fromPartition,
        bytes32 indexed toPartition,
        uint256 value
    );


    event ApprovalByPartition(
        bytes32 indexed partition,
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);

    event AuthorizedOperatorByPartition(
        bytes32 indexed partition,
        address indexed operator,
        address indexed tokenHolder
    );

    event RevokedOperatorByPartition(
        bytes32 indexed partition,
        address indexed operator,
        address indexed tokenHolder
    );


    event CollateralManagerRegistered(address collateralManager);


    event PartitionStrategySet(bytes4 flag, string name, address indexed implementation);


    event Minted(address indexed operator, address indexed to, uint256 value, bytes data);

    event Swap(address indexed operator, address indexed from, uint256 value);


    constructor(
        address _swapTokenAddress_,
        string memory _name_,
        string memory _symbol_
    ) public {
        require(_swapTokenAddress_ != address(0), EC_5A_INVALID_SWAP_TOKEN_ADDRESS);
        swapToken = ISwapToken(_swapTokenAddress_);

        _name = _name_;
        _symbol = _symbol_;
        _totalSupply = 0;

        _addPartitionToTotalPartitions(defaultPartition);

        ERC1820Client.setInterfaceImplementation(AMP_INTERFACE_NAME, address(this));
        ERC1820Client.setInterfaceImplementation(ERC20_INTERFACE_NAME, address(this));

        ERC1820Implementer._setInterface(AMP_INTERFACE_NAME);
        ERC1820Implementer._setInterface(ERC20_INTERFACE_NAME);
    }


    function totalSupply() external override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address _tokenHolder) external override view returns (uint256) {

        return _balances[_tokenHolder];
    }

    function transfer(address _to, uint256 _value) external override returns (bool) {

        _transferByDefaultPartition(msg.sender, msg.sender, _to, _value, "");
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external override returns (bool) {

        _transferByDefaultPartition(msg.sender, _from, _to, _value, "");
        return true;
    }

    function allowance(address _owner, address _spender)
        external
        override
        view
        returns (uint256)
    {

        return _allowedByPartition[defaultPartition][_owner][_spender];
    }

    function approve(address _spender, uint256 _value) external override returns (bool) {

        _approveByPartition(defaultPartition, msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue)
        external
        returns (bool)
    {

        _approveByPartition(
            defaultPartition,
            msg.sender,
            _spender,
            _allowedByPartition[defaultPartition][msg.sender][_spender].add(_addedValue)
        );
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        external
        returns (bool)
    {

        _approveByPartition(
            defaultPartition,
            msg.sender,
            _spender,
            _allowedByPartition[defaultPartition][msg.sender][_spender].sub(
                _subtractedValue
            )
        );
        return true;
    }



    function swap(address _from) public {

        uint256 amount = swapToken.allowance(_from, address(this));
        require(amount > 0, EC_53_INSUFFICIENT_ALLOWANCE);

        require(
            swapToken.transferFrom(_from, swapTokenGraveyard, amount),
            EC_60_SWAP_TRANSFER_FAILURE
        );

        _mint(msg.sender, _from, amount);

        emit Swap(msg.sender, _from, amount);
    }


    function balanceOfByPartition(bytes32 _partition, address _tokenHolder)
        external
        view
        returns (uint256)
    {

        return _balanceOfByPartition[_tokenHolder][_partition];
    }

    function partitionsOf(address _tokenHolder) external view returns (bytes32[] memory) {

        return _partitionsOf[_tokenHolder];
    }


    function transferByPartition(
        bytes32 _partition,
        address _from,
        address _to,
        uint256 _value,
        bytes calldata _data,
        bytes calldata _operatorData
    ) external returns (bytes32) {

        return
            _transferByPartition(
                _partition,
                msg.sender,
                _from,
                _to,
                _value,
                _data,
                _operatorData
            );
    }


    function authorizeOperator(address _operator) external {

        require(_operator != msg.sender, EC_58_INVALID_OPERATOR);

        _authorizedOperator[msg.sender][_operator] = true;
        emit AuthorizedOperator(_operator, msg.sender);
    }

    function revokeOperator(address _operator) external {

        require(_operator != msg.sender, EC_58_INVALID_OPERATOR);

        _authorizedOperator[msg.sender][_operator] = false;
        emit RevokedOperator(_operator, msg.sender);
    }

    function authorizeOperatorByPartition(bytes32 _partition, address _operator)
        external
    {

        require(_operator != msg.sender, EC_58_INVALID_OPERATOR);

        _authorizedOperatorByPartition[msg.sender][_partition][_operator] = true;
        emit AuthorizedOperatorByPartition(_partition, _operator, msg.sender);
    }

    function revokeOperatorByPartition(bytes32 _partition, address _operator) external {

        require(_operator != msg.sender, EC_58_INVALID_OPERATOR);

        _authorizedOperatorByPartition[msg.sender][_partition][_operator] = false;
        emit RevokedOperatorByPartition(_partition, _operator, msg.sender);
    }

    function isOperator(address _operator, address _tokenHolder)
        external
        view
        returns (bool)
    {

        return _isOperator(_operator, _tokenHolder);
    }

    function isOperatorForPartition(
        bytes32 _partition,
        address _operator,
        address _tokenHolder
    ) external view returns (bool) {

        return _isOperatorForPartition(_partition, _operator, _tokenHolder);
    }

    function isOperatorForCollateralManager(
        bytes32 _partition,
        address _operator,
        address _collateralManager
    ) external view returns (bool) {

        return
            _isCollateralManager[_collateralManager] &&
            (_isOperator(_operator, _collateralManager) ||
                _authorizedOperatorByPartition[_collateralManager][_partition][_operator]);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function decimals() external pure returns (uint8) {

        return uint8(18);
    }

    function granularity() external pure returns (uint256) {

        return _granularity;
    }

    function totalPartitions() external view returns (bytes32[] memory) {

        return _totalPartitions;
    }

    function allowanceByPartition(
        bytes32 _partition,
        address _owner,
        address _spender
    ) external view returns (uint256) {

        return _allowedByPartition[_partition][_owner][_spender];
    }

    function approveByPartition(
        bytes32 _partition,
        address _spender,
        uint256 _value
    ) external returns (bool) {

        _approveByPartition(_partition, msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowanceByPartition(
        bytes32 _partition,
        address _spender,
        uint256 _addedValue
    ) external returns (bool) {

        _approveByPartition(
            _partition,
            msg.sender,
            _spender,
            _allowedByPartition[_partition][msg.sender][_spender].add(_addedValue)
        );
        return true;
    }

    function decreaseAllowanceByPartition(
        bytes32 _partition,
        address _spender,
        uint256 _subtractedValue
    ) external returns (bool) {

        _approveByPartition(
            _partition,
            msg.sender,
            _spender,
            _allowedByPartition[_partition][msg.sender][_spender].sub(_subtractedValue)
        );
        return true;
    }


    function registerCollateralManager() external {

        require(!_isCollateralManager[msg.sender], EC_5C_ADDRESS_CONFLICT);

        collateralManagers.push(msg.sender);
        _isCollateralManager[msg.sender] = true;

        emit CollateralManagerRegistered(msg.sender);
    }

    function isCollateralManager(address _collateralManager)
        external
        view
        returns (bool)
    {

        return _isCollateralManager[_collateralManager];
    }

    function setPartitionStrategy(bytes4 _prefix, address _implementation) external {

        require(msg.sender == owner(), EC_56_INVALID_SENDER);
        require(!_isPartitionStrategy[_prefix], EC_5E_PARTITION_PREFIX_CONFLICT);
        require(_prefix != ZERO_PREFIX, EC_5F_INVALID_PARTITION_PREFIX_0);

        string memory iname = PartitionUtils._getPartitionStrategyValidatorIName(_prefix);

        ERC1820Client.setInterfaceImplementation(iname, _implementation);
        partitionStrategies.push(_prefix);
        _isPartitionStrategy[_prefix] = true;

        emit PartitionStrategySet(_prefix, iname, _implementation);
    }

    function isPartitionStrategy(bytes4 _prefix) external view returns (bool) {

        return _isPartitionStrategy[_prefix];
    }



    function _transferByPartition(
        bytes32 _fromPartition,
        address _operator,
        address _from,
        address _to,
        uint256 _value,
        bytes memory _data,
        bytes memory _operatorData
    ) internal returns (bytes32) {

        require(_to != address(0), EC_57_INVALID_RECEIVER);

        if (_from != _operator) {
            require(
                _isOperatorForPartition(_fromPartition, _operator, _from) ||
                    (_value <= _allowedByPartition[_fromPartition][_from][_operator]),
                EC_53_INSUFFICIENT_ALLOWANCE
            );

            if (_allowedByPartition[_fromPartition][_from][_operator] >= _value) {
                _allowedByPartition[_fromPartition][_from][msg
                    .sender] = _allowedByPartition[_fromPartition][_from][_operator].sub(
                    _value
                );
            } else {
                _allowedByPartition[_fromPartition][_from][_operator] = 0;
            }
        }

        _callPreTransferHooks(
            _fromPartition,
            _operator,
            _from,
            _to,
            _value,
            _data,
            _operatorData
        );

        require(
            _balanceOfByPartition[_from][_fromPartition] >= _value,
            EC_52_INSUFFICIENT_BALANCE
        );

        bytes32 toPartition = PartitionUtils._getDestinationPartition(
            _data,
            _fromPartition
        );

        _removeTokenFromPartition(_from, _fromPartition, _value);
        _addTokenToPartition(_to, toPartition, _value);
        _callPostTransferHooks(
            toPartition,
            _operator,
            _from,
            _to,
            _value,
            _data,
            _operatorData
        );

        emit Transfer(_from, _to, _value);
        emit TransferByPartition(
            _fromPartition,
            _operator,
            _from,
            _to,
            _value,
            _data,
            _operatorData
        );

        if (toPartition != _fromPartition) {
            emit ChangedPartition(_fromPartition, toPartition, _value);
        }

        return toPartition;
    }

    function _transferByDefaultPartition(
        address _operator,
        address _from,
        address _to,
        uint256 _value,
        bytes memory _data
    ) internal {

        _transferByPartition(defaultPartition, _operator, _from, _to, _value, _data, "");
    }

    function _removeTokenFromPartition(
        address _from,
        bytes32 _partition,
        uint256 _value
    ) internal {

        if (_value == 0) {
            return;
        }

        _balances[_from] = _balances[_from].sub(_value);

        _balanceOfByPartition[_from][_partition] = _balanceOfByPartition[_from][_partition]
            .sub(_value);
        totalSupplyByPartition[_partition] = totalSupplyByPartition[_partition].sub(
            _value
        );

        if (totalSupplyByPartition[_partition] == 0 && _partition != defaultPartition) {
            _removePartitionFromTotalPartitions(_partition);
        }

        if (_balanceOfByPartition[_from][_partition] == 0) {
            uint256 index = _indexOfPartitionsOf[_from][_partition];

            if (index == 0) {
                return;
            }

            bytes32 lastValue = _partitionsOf[_from][_partitionsOf[_from].length - 1];
            _partitionsOf[_from][index - 1] = lastValue; // adjust for 1-based indexing
            _indexOfPartitionsOf[_from][lastValue] = index;

            _partitionsOf[_from].pop();
            _indexOfPartitionsOf[_from][_partition] = 0;
        }
    }

    function _addTokenToPartition(
        address _to,
        bytes32 _partition,
        uint256 _value
    ) internal {

        if (_value == 0) {
            return;
        }

        _balances[_to] = _balances[_to].add(_value);

        if (_indexOfPartitionsOf[_to][_partition] == 0) {
            _partitionsOf[_to].push(_partition);
            _indexOfPartitionsOf[_to][_partition] = _partitionsOf[_to].length;
        }
        _balanceOfByPartition[_to][_partition] = _balanceOfByPartition[_to][_partition]
            .add(_value);

        if (_indexOfTotalPartitions[_partition] == 0) {
            _addPartitionToTotalPartitions(_partition);
        }
        totalSupplyByPartition[_partition] = totalSupplyByPartition[_partition].add(
            _value
        );
    }

    function _addPartitionToTotalPartitions(bytes32 _partition) internal {

        _totalPartitions.push(_partition);
        _indexOfTotalPartitions[_partition] = _totalPartitions.length;
    }

    function _removePartitionFromTotalPartitions(bytes32 _partition) internal {

        uint256 index = _indexOfTotalPartitions[_partition];

        if (index == 0) {
            return;
        }

        bytes32 lastValue = _totalPartitions[_totalPartitions.length - 1];
        _totalPartitions[index - 1] = lastValue; // adjust for 1-based indexing
        _indexOfTotalPartitions[lastValue] = index;

        _totalPartitions.pop();
        _indexOfTotalPartitions[_partition] = 0;
    }

    function _callPreTransferHooks(
        bytes32 _fromPartition,
        address _operator,
        address _from,
        address _to,
        uint256 _value,
        bytes memory _data,
        bytes memory _operatorData
    ) internal {

        address senderImplementation;
        senderImplementation = interfaceAddr(_from, AMP_TOKENS_SENDER);
        if (senderImplementation != address(0)) {
            IAmpTokensSender(senderImplementation).tokensToTransfer(
                msg.sig,
                _fromPartition,
                _operator,
                _from,
                _to,
                _value,
                _data,
                _operatorData
            );
        }

        bytes4 fromPartitionPrefix = PartitionUtils._getPartitionPrefix(_fromPartition);
        if (_isPartitionStrategy[fromPartitionPrefix]) {
            address fromPartitionValidatorImplementation;
            fromPartitionValidatorImplementation = interfaceAddr(
                address(this),
                PartitionUtils._getPartitionStrategyValidatorIName(fromPartitionPrefix)
            );
            if (fromPartitionValidatorImplementation != address(0)) {
                IAmpPartitionStrategyValidator(fromPartitionValidatorImplementation)
                    .tokensFromPartitionToValidate(
                    msg.sig,
                    _fromPartition,
                    _operator,
                    _from,
                    _to,
                    _value,
                    _data,
                    _operatorData
                );
            }
        }
    }

    function _callPostTransferHooks(
        bytes32 _toPartition,
        address _operator,
        address _from,
        address _to,
        uint256 _value,
        bytes memory _data,
        bytes memory _operatorData
    ) internal {

        bytes4 toPartitionPrefix = PartitionUtils._getPartitionPrefix(_toPartition);
        if (_isPartitionStrategy[toPartitionPrefix]) {
            address partitionManagerImplementation;
            partitionManagerImplementation = interfaceAddr(
                address(this),
                PartitionUtils._getPartitionStrategyValidatorIName(toPartitionPrefix)
            );
            if (partitionManagerImplementation != address(0)) {
                IAmpPartitionStrategyValidator(partitionManagerImplementation)
                    .tokensToPartitionToValidate(
                    msg.sig,
                    _toPartition,
                    _operator,
                    _from,
                    _to,
                    _value,
                    _data,
                    _operatorData
                );
            }
        } else {
            require(toPartitionPrefix == ZERO_PREFIX, EC_5D_PARTITION_RESERVED);
        }

        address recipientImplementation;
        recipientImplementation = interfaceAddr(_to, AMP_TOKENS_RECIPIENT);

        if (recipientImplementation != address(0)) {
            IAmpTokensRecipient(recipientImplementation).tokensReceived(
                msg.sig,
                _toPartition,
                _operator,
                _from,
                _to,
                _value,
                _data,
                _operatorData
            );
        }
    }

    function _approveByPartition(
        bytes32 _partition,
        address _tokenHolder,
        address _spender,
        uint256 _amount
    ) internal {

        require(_tokenHolder != address(0), EC_56_INVALID_SENDER);
        require(_spender != address(0), EC_58_INVALID_OPERATOR);

        _allowedByPartition[_partition][_tokenHolder][_spender] = _amount;
        emit ApprovalByPartition(_partition, _tokenHolder, _spender, _amount);

        if (_partition == defaultPartition) {
            emit Approval(_tokenHolder, _spender, _amount);
        }
    }

    function _isOperator(address _operator, address _tokenHolder)
        internal
        view
        returns (bool)
    {

        return (_operator == _tokenHolder ||
            _authorizedOperator[_tokenHolder][_operator]);
    }

    function _isOperatorForPartition(
        bytes32 _partition,
        address _operator,
        address _tokenHolder
    ) internal view returns (bool) {

        return (_isOperator(_operator, _tokenHolder) ||
            _authorizedOperatorByPartition[_tokenHolder][_partition][_operator] ||
            _callPartitionStrategyOperatorHook(_partition, _operator, _tokenHolder));
    }

    function _callPartitionStrategyOperatorHook(
        bytes32 _partition,
        address _operator,
        address _tokenHolder
    ) internal view returns (bool) {

        bytes4 prefix = PartitionUtils._getPartitionPrefix(_partition);

        if (!_isPartitionStrategy[prefix]) {
            return false;
        }

        address strategyValidatorImplementation;
        strategyValidatorImplementation = interfaceAddr(
            address(this),
            PartitionUtils._getPartitionStrategyValidatorIName(prefix)
        );
        if (strategyValidatorImplementation != address(0)) {
            return
                IAmpPartitionStrategyValidator(strategyValidatorImplementation)
                    .isOperatorForPartitionScope(_partition, _operator, _tokenHolder);
        }

        return false;
    }

    function _mint(
        address _operator,
        address _to,
        uint256 _value
    ) internal {

        require(_to != address(0), EC_57_INVALID_RECEIVER);

        _totalSupply = _totalSupply.add(_value);
        _addTokenToPartition(_to, defaultPartition, _value);
        _callPostTransferHooks(
            defaultPartition,
            _operator,
            address(0),
            _to,
            _value,
            "",
            ""
        );

        emit Minted(_operator, _to, _value, "");
        emit Transfer(address(0), _to, _value);
        emit TransferByPartition(bytes32(0), _operator, address(0), _to, _value, "", "");
    }
}