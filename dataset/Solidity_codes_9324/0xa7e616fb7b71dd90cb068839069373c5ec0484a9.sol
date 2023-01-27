pragma solidity 0.6.11;

interface IQredoWalletImplementation {

    function init(address _walletOwner) external;

    function invoke(bytes memory signature, address _to, uint256 _value, bytes calldata _data) external returns (bytes memory _result);

    function getBalance(address tokenAddress) external view returns(uint256 _balance);

    function getNonce() external view returns(uint256 nonce);

    function getWalletOwnerAddress() external view returns(address _walletOwner);

    
    event Invoked(address indexed sender, address indexed target, uint256 value, uint256 indexed nonce, bytes data);
    event Received(address indexed sender, uint indexed value, bytes data);
    event Fallback(address indexed sender, uint indexed value, bytes data);
}// MIT
pragma solidity 0.6.11;

interface IWalletFactory {

    function computeFutureWalletAddress(address _walletOwner) external view returns(address _walletAddress);

    function createWallet(address owner) external returns (address _walletAddress);

    function getTemplate() external view returns (address template);

    function getWalletByOwner(address owner) external view returns (address _wallet);

    function verifyWallet(address wallet) external  view returns (bool _validWallet);

    
    event WalletCreated(address indexed caller, address indexed wallet, address indexed owner);
}// MIT
pragma solidity 0.6.11;



library Create2 {

    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address) {

        address addr;
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
        return addr;
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {

        return computeAddress(salt, bytecodeHash, address(this));
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) internal pure returns (address) {

        bytes32 _data = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash)
        );
        return address(uint160(uint256(_data)));
    }
}// MIT
pragma solidity 0.6.11;


contract WalletFactory is IWalletFactory {


    mapping(address => address) private walletOwner;
    address immutable private _template;

    constructor(address _template_) public {
        require(_template_ != address(0), "WF::constructor:_template_ address cannot be 0");
        _template = _template_;
    }

    function computeFutureWalletAddress(address _walletOwner) external override view returns(address _walletAddress) {

        return Create2.computeAddress(
                    keccak256(abi.encodePacked(_walletOwner)),
                    keccak256(getBytecode())
                );
    }
   
    function createWallet(address _walletOwner) external override returns (address _walletAddress) {

        require(_walletOwner != address(0), "WF::createWallet:owner address cannot be 0");
        require(walletOwner[_walletOwner] == address(0), "WF::createWallet:owner already has wallet");
        address wallet = Create2.deploy(
                0,
                keccak256(abi.encodePacked(_walletOwner)),
                getBytecode()
            );
        IQredoWalletImplementation(wallet).init(_walletOwner);
        walletOwner[_walletOwner] = address(wallet);
        emit WalletCreated(msg.sender, address(wallet), _walletOwner);
        return wallet;
    }

    function getWalletByOwner(address owner) external override view returns (address _wallet) {

        return walletOwner[owner];
    }

    function verifyWallet(address wallet) external override view returns (bool _validWallet) {

        return walletOwner[IQredoWalletImplementation(wallet).getWalletOwnerAddress()] != address(0);
    }

    function getTemplate() external override view returns (address template){

        return _template;
    }

    function getBytecode() private view returns (bytes memory) {

        bytes10 creation = 0x3d602d80600a3d3981f3;
        bytes10 runtimePrefix = 0x363d3d373d3d3d363d73;
        bytes20 targetBytes = bytes20(_template);
        bytes15 runtimeSuffix = 0x5af43d82803e903d91602b57fd5bf3;
        return abi.encodePacked(creation, runtimePrefix, targetBytes, runtimeSuffix);
    }
}