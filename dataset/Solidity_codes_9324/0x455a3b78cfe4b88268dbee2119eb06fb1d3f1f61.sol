

pragma solidity 0.6.10;

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

contract AmpPartitionStrategyValidatorBase is
    IAmpPartitionStrategyValidator,
    ERC1820Client,
    ERC1820Implementer
{

    bytes4 public partitionPrefix;

    address public amp;

    constructor(bytes4 _prefix, address _amp) public {
        partitionPrefix = _prefix;

        string memory iname = PartitionUtils._getPartitionStrategyValidatorIName(
            partitionPrefix
        );
        ERC1820Implementer._setInterface(iname);

        amp = _amp;
    }

    function tokensFromPartitionToValidate(
        bytes4, /* functionSig */
        bytes32, /* fromPartition */
        address, /* operator */
        address, /* from */
        address, /* to */
        uint256, /* value */
        bytes calldata, /* data */
        bytes calldata /* operatorData */
    ) external virtual override {}


    function tokensToPartitionToValidate(
        bytes4, /* functionSig */
        bytes32, /* fromPartition */
        address, /* operator */
        address, /* from */
        address, /* to */
        uint256, /* value */
        bytes calldata, /* data */
        bytes calldata /* operatorData */
    ) external virtual override {}


    function isOperatorForPartitionScope(
        bytes32, /* partition */
        address, /* operator */
        address /* tokenHolder */
    ) external virtual override view returns (bool) {

        return false;
    }
}


interface IAmp {

    function isCollateralManager(address) external view returns (bool);

}

contract CollateralPoolPartitionValidator is AmpPartitionStrategyValidatorBase {

    bytes4 constant PARTITION_PREFIX = 0xCCCCCCCC;

    constructor(address _amp)
        public
        AmpPartitionStrategyValidatorBase(PARTITION_PREFIX, _amp)
    {}

    function isOperatorForPartitionScope(
        bytes32 _partition,
        address, /* operator */
        address _tokenHolder
    ) external override view returns (bool) {

        require(msg.sender == address(amp), "Hook must be called by amp");

        (, , address partitionOwner) = PartitionUtils._splitPartition(_partition);
        if (!IAmp(amp).isCollateralManager(partitionOwner)) {
            return false;
        }

        return _tokenHolder == partitionOwner;
    }

    function tokensToPartitionToValidate(
        bytes4, /* functionSig */
        bytes32 _toPartition,
        address, /* operator */
        address, /* from */
        address _to,
        uint256, /* value */
        bytes calldata, /* _data */
        bytes calldata /* operatorData */
    ) external override {

        require(msg.sender == address(amp), "Hook must be called by amp");

        (, , address toPartitionOwner) = PartitionUtils._splitPartition(_toPartition);

        require(
            _to == toPartitionOwner,
            "Transfers to this partition must be to the partitionOwner"
        );
        require(
            IAmp(amp).isCollateralManager(toPartitionOwner),
            "Partition owner is not a registered collateral manager"
        );
    }
}