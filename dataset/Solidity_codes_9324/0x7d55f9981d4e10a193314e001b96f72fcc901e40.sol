


pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

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


pragma solidity 0.6.6;

library CloneLib {

    function cloneBytecode(address template) internal pure returns (bytes memory code) {

        bytes20 targetBytes = bytes20(template);
        assembly {
            code := mload(0x40)
            mstore(0x40, add(code, 0x57)) // code length is 0x37 plus 0x20 for bytes length field. update free memory pointer
            mstore(code, 0x37) // store length in first 32 bytes

            mstore(add(code, 0x20), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(code, 0x34), targetBytes)
            mstore(add(code, 0x48), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
        }
    }

    function predictCloneAddressCreate2(
        address template,
        address deployer,
        bytes32 salt
    ) internal pure returns (address proxy) {

        bytes32 codehash = keccak256(cloneBytecode(template));
        return address(uint160(uint256(keccak256(abi.encodePacked(
            bytes1(0xff),
            deployer,
            salt,
            codehash
        )))));
    }

    function deployCodeAndInitUsingCreate2(
        bytes memory code,
        bytes memory initData,
        bytes32 salt
    ) internal returns (address payable proxy) {

        uint256 len = code.length;
        assembly {
            proxy := create2(0, add(code, 0x20), len, salt)
        }
        require(proxy != address(0), "error_alreadyCreated");
        if (initData.length != 0) {
            (bool success, ) = proxy.call(initData);
            require(success, "error_initialization");
        }
    }

    function deployCodeAndInitUsingCreate(
        bytes memory code,
        bytes memory initData
    ) internal returns (address payable proxy) {

        uint256 len = code.length;
        assembly {
            proxy := create(0, add(code, 0x20), len)
        }
        require(proxy != address(0), "error_create");
        if (initData.length != 0) {
            (bool success, ) = proxy.call(initData);
            require(success, "error_initialization");
        }
    }
}


pragma solidity 0.6.6;

interface IAMB {


    function executeSignatures(bytes calldata _data, bytes calldata _signatures) external;


    function messageSender() external view returns (address);


    function maxGasPerTx() external view returns (uint256);


    function transactionHash() external view returns (bytes32);


    function messageId() external view returns (bytes32);


    function messageSourceChainId() external view returns (bytes32);


    function messageCallStatus(bytes32 _messageId) external view returns (bool);


    function requiredSignatures() external view returns (uint256);

    function numMessagesSigned(bytes32 _message) external view returns (uint256);

    function signature(bytes32 _hash, uint256 _index) external view returns (bytes memory);

    function message(bytes32 _hash) external view returns (bytes memory);

    function failedMessageDataHash(bytes32 _messageId)
        external
        view
        returns (bytes32);


    function failedMessageReceiver(bytes32 _messageId)
        external
        view
        returns (address);


    function failedMessageSender(bytes32 _messageId)
        external
        view
        returns (address);


    function requireToPassMessage(
        address _contract,
        bytes calldata _data,
        uint256 _gas
    ) external returns (bytes32);

}


pragma solidity 0.6.6;

interface ITokenMediator {

    function bridgeContract() external view returns (address);


    function getBridgeMode() external pure returns (bytes4 _data);


    function relayTokensAndCall(address token, address _receiver, uint256 _value, bytes calldata _data) external;

}


pragma solidity 0.6.6;

interface FactoryConfig {

    function currentToken() external view returns (address);

    function currentMediator() external view returns (address);

}


pragma solidity 0.6.6;







interface IDataUnionMainnet {

    function sidechainAddress() external view returns (address proxy);

}

contract DataUnionFactoryMainnet {

    event MainnetDUCreated(address indexed mainnet, address indexed sidechain, address indexed owner, address template);

    address public dataUnionMainnetTemplate;

    address public dataUnionSidechainTemplate;
    address public dataUnionSidechainFactory;
    uint256 public sidechainMaxGas;
    FactoryConfig public migrationManager;

    constructor(address _migrationManager,
                address _dataUnionMainnetTemplate,
                address _dataUnionSidechainTemplate,
                address _dataUnionSidechainFactory,
                uint256 _sidechainMaxGas)
        public
    {
        migrationManager = FactoryConfig(_migrationManager);
        dataUnionMainnetTemplate = _dataUnionMainnetTemplate;
        dataUnionSidechainTemplate = _dataUnionSidechainTemplate;
        dataUnionSidechainFactory = _dataUnionSidechainFactory;
        sidechainMaxGas = _sidechainMaxGas;
    }

    function amb() public view returns (IAMB) {

        return IAMB(ITokenMediator(migrationManager.currentMediator()).bridgeContract());
    }
 
    function token() public view returns (address) {

        return migrationManager.currentToken();
    }


    function sidechainAddress(address mainetAddress)
        public view
        returns (address)
    {

        return CloneLib.predictCloneAddressCreate2(
            dataUnionSidechainTemplate,
            dataUnionSidechainFactory,
            bytes32(uint256(mainetAddress))
        );
    }
    function mainnetAddress(address deployer, string memory name)
        public view
        returns (address)
    {

        bytes32 salt = keccak256(abi.encode(bytes(name), deployer));
        return CloneLib.predictCloneAddressCreate2(
            dataUnionMainnetTemplate,
            address(this),
            salt
        );
    }


    function deployNewDataUnion(address owner, uint256 adminFeeFraction, address[] memory agents, string memory name)
        public
        returns (address)
    {

        bytes32 salt = keccak256(abi.encode(bytes(name), msg.sender));
        bytes memory data = abi.encodeWithSignature("initialize(address,address,uint256,address,address,uint256,address[])",
            migrationManager,
            dataUnionSidechainFactory,
            sidechainMaxGas,
            dataUnionSidechainTemplate,
            owner,
            adminFeeFraction,
            agents
        );
        address du = CloneLib.deployCodeAndInitUsingCreate2(CloneLib.cloneBytecode(dataUnionMainnetTemplate), data, salt);
        emit MainnetDUCreated(du, sidechainAddress(du), owner, dataUnionMainnetTemplate);
        return du;
    }
}