
pragma solidity ^0.7.0;


contract Ownable
{

    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor()
    {
        owner = msg.sender;
    }

    modifier onlyOwner()
    {

        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }

    function transferOwnership(
        address newOwner
        )
        public
        virtual
        onlyOwner
    {

        require(newOwner != address(0), "ZERO_ADDRESS");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership()
        public
        onlyOwner
    {

        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}




interface WalletRegistry
{

    function registerWallet(address wallet) external;

    function isWalletRegistered(address addr) external view returns (bool);

    function numOfWallets() external view returns (uint);

}







interface ModuleRegistry
{

    function registerModule(address module) external;


    function disableModule(address module) external;


    function isModuleEnabled(address module) external view returns (bool);


    function enabledModules() external view returns (address[] memory _modules);


    function numOfEnabledModules() external view returns (uint);


    function isModuleRegistered(address module) external view returns (bool);

}




abstract contract Controller
{
    ModuleRegistry public moduleRegistry;
    WalletRegistry public walletRegistry;
    address        public walletFactory;
}




abstract contract ERC20
{
    function totalSupply()
        public
        view
        virtual
        returns (uint);

    function balanceOf(
        address who
        )
        public
        view
        virtual
        returns (uint);

    function allowance(
        address owner,
        address spender
        )
        public
        view
        virtual
        returns (uint);

    function transfer(
        address to,
        uint value
        )
        public
        virtual
        returns (bool);

    function transferFrom(
        address from,
        address to,
        uint    value
        )
        public
        virtual
        returns (bool);

    function approve(
        address spender,
        uint    value
        )
        public
        virtual
        returns (bool);
}













interface Module
{

    function activate() external;


    function deactivate() external;

}





interface Wallet
{

    function version() external pure returns (string memory);


    function owner() external view returns (address);


    function setOwner(address newOwner) external;


    function addModule(address _module) external;


    function removeModule(address _module) external;


    function hasModule(address _module) external view returns (bool);


    function bindMethod(bytes4 _method, address _module) external;


    function boundMethodModule(bytes4 _method) external view returns (address _module);


    function transact(
        uint8    mode,
        address  to,
        uint     value,
        bytes    calldata data
        )
        external
        returns (bytes memory returnData);

}






contract ReentrancyGuard
{

    uint private _guardValue;

    modifier nonReentrant()
    {

        require(_guardValue == 0, "REENTRANCY");
        _guardValue = 1;
        _;
        _guardValue = 0;
    }
}




abstract contract BaseWallet is ReentrancyGuard, Wallet
{
    address internal _owner;

    mapping (address => bool) private modules;

    Controller public controller;

    mapping (bytes4  => address) internal methodToModule;

    event OwnerChanged          (address newOwner);
    event ControllerChanged     (address newController);
    event ModuleAdded           (address module);
    event ModuleRemoved         (address module);
    event MethodBound           (bytes4  method, address module);
    event WalletSetup           (address owner);

    event Transacted(
        address module,
        address to,
        uint    value,
        bytes   data
    );

    modifier onlyFromModule
    {
        require(modules[msg.sender], "MODULE_UNAUTHORIZED");
        _;
    }

    modifier onlyFromFactory
    {
        require(
            msg.sender == controller.walletFactory(),
            "UNAUTHORIZED"
        );
        _;
    }

    modifier onlyFromFactoryOrModule
    {
        require(
            modules[msg.sender] || msg.sender == controller.walletFactory(),
            "UNAUTHORIZED"
        );
        _;
    }

    function initOwner(
        address _initialOwner
        )
        external
        onlyFromFactory
        nonReentrant
    {
        require(controller != Controller(0), "NO_CONTROLLER");
        require(_owner == address(0), "INITIALIZED_ALREADY");
        require(_initialOwner != address(0), "ZERO_ADDRESS");

        _owner = _initialOwner;
        emit WalletSetup(_initialOwner);
    }

    function initController(
        Controller _controller
        )
        external
        nonReentrant
    {
        require(
            _owner == address(0) &&
            controller == Controller(0) &&
            _controller != Controller(0),
            "CONTROLLER_INIT_FAILED"
        );

        controller = _controller;
    }

    function owner()
        override
        external
        view
        returns (address)
    {
        return _owner;
    }

    function setOwner(address newOwner)
        external
        override
        nonReentrant
        onlyFromModule
    {
        require(newOwner != address(0), "ZERO_ADDRESS");
        require(newOwner != address(this), "PROHIBITED");
        require(newOwner != _owner, "SAME_ADDRESS");
        _owner = newOwner;
        emit OwnerChanged(newOwner);
    }

    function setController(Controller newController)
        external
        nonReentrant
        onlyFromModule
    {
        require(newController != controller, "SAME_CONTROLLER");
        require(newController != Controller(0), "INVALID_CONTROLLER");
        controller = newController;
        emit ControllerChanged(address(newController));
    }

    function addModule(address _module)
        external
        override
        onlyFromFactoryOrModule
    {
        addModuleInternal(_module);
    }

    function removeModule(address _module)
        external
        override
        onlyFromModule
    {
        require(modules[_module], "MODULE_NOT_EXISTS");
        try Module(_module).deactivate() {} catch {}
        delete modules[_module];
        emit ModuleRemoved(_module);
    }

    function hasModule(address _module)
        external
        view
        override
        returns (bool)
    {
        return modules[_module];
    }

    function bindMethod(bytes4 _method, address _module)
        external
        override
        onlyFromModule
    {
        require(_method != bytes4(0), "BAD_METHOD");
        if (_module != address(0)) {
            require(modules[_module], "MODULE_UNAUTHORIZED");
        }

        methodToModule[_method] = _module;
        emit MethodBound(_method, _module);
    }

    function boundMethodModule(bytes4 _method)
        external
        view
        override
        returns (address)
    {
        return methodToModule[_method];
    }

    function transact(
        uint8    mode,
        address  to,
        uint     value,
        bytes    calldata data
        )
        external
        override
        onlyFromFactoryOrModule
        returns (bytes memory returnData)
    {
        require(
            !controller.moduleRegistry().isModuleRegistered(to),
            "TRANSACT_ON_MODULE_DISALLOWED"
        );

        bool success;
        (success, returnData) = nonReentrantCall(mode, to, value, data);

        if (!success) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
        emit Transacted(msg.sender, to, value, data);
    }

    function addModuleInternal(address _module)
        internal
    {
        require(_module != address(0), "NULL_MODULE");
        require(modules[_module] == false, "MODULE_EXISTS");
        require(
            controller.moduleRegistry().isModuleEnabled(_module),
            "INVALID_MODULE"
        );
        modules[_module] = true;
        emit ModuleAdded(_module);
        Module(_module).activate();
    }

    receive()
        external
        payable
    {
    }

    fallback()
        external
        payable
    {
        address module = methodToModule[msg.sig];
        require(modules[module], "MODULE_UNAUTHORIZED");

        (bool success, bytes memory returnData) = module.call{value: msg.value}(msg.data);
        assembly {
            switch success
            case 0 { revert(add(returnData, 32), mload(returnData)) }
            default { return(add(returnData, 32), mload(returnData)) }
        }
    }

    function nonReentrantCall(
        uint8        mode,
        address      target,
        uint         value,
        bytes memory data
        )
        private
        nonReentrant
        returns (
            bool success,
            bytes memory returnData
        )
    {
        if (mode == 1) {
            (success, returnData) = target.call{value: value}(data);
        } else if (mode == 2) {
            (success, returnData) = target.delegatecall(data);
        } else if (mode == 3) {
            require(value == 0, "INVALID_VALUE");
            (success, returnData) = target.staticcall(data);
        } else {
            revert("UNSUPPORTED_MODE");
        }
    }
}



contract WalletImpl is BaseWallet {

    function version()
        external
        override
        pure
        returns (string memory)
    {

        return "1.1.5 (shenyang)";
    }
}