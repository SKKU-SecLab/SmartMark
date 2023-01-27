pragma solidity =0.6.10;

contract Spawn {

    constructor(address logicContract, bytes memory initializationCalldata) public payable {
        (bool ok, ) = logicContract.delegatecall(initializationCalldata);
        if (!ok) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        bytes memory runtimeCode = abi.encodePacked(
            bytes10(0x363d3d373d3d3d363d73),
            logicContract,
            bytes15(0x5af43d82803e903d91602b57fd5bf3)
        );

        assembly {
            return(add(0x20, runtimeCode), 45) // eip-1167 runtime code, length
        }
    }
}// MIT

pragma solidity =0.6.10;

library Create2 {

    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address) {

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

    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address) {

        bytes32 _data = keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, bytecodeHash));
        return address(uint256(_data));
    }
}/* UNLICENSED */

pragma solidity =0.6.10;


contract OtokenSpawner {

    bytes32 private constant SALT = bytes32(0);

    function _spawn(address logicContract, bytes memory initializationCalldata) internal returns (address) {

        bytes memory initCode = abi.encodePacked(
            type(Spawn).creationCode,
            abi.encode(logicContract, initializationCalldata)
        );

        return Create2.deploy(0, SALT, initCode);
    }

    function _computeAddress(address logicContract, bytes memory initializationCalldata)
        internal
        view
        returns (address target)
    {

        bytes memory initCode = abi.encodePacked(
            type(Spawn).creationCode,
            abi.encode(logicContract, initializationCalldata)
        );
        bytes32 initCodeHash = keccak256(initCode);

        target = Create2.computeAddress(SALT, initCodeHash);
    }
}// MIT

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// UNLICENSED
pragma solidity 0.6.10;

interface AddressBookInterface {


    function getOtokenImpl() external view returns (address);


    function getOtokenFactory() external view returns (address);


    function getWhitelist() external view returns (address);


    function getController() external view returns (address);


    function getOracle() external view returns (address);


    function getRewards() external view returns (address);


    function getMarginPool() external view returns (address);


    function getMarginCalculator() external view returns (address);


    function getLiquidationManager() external view returns (address);


    function getAddress(bytes32 _id) external view returns (address);



    function setOtokenImpl(address _otokenImpl) external;


    function setOtokenFactory(address _factory) external;


    function setWhitelist(address _whitelist) external;


    function setController(address _controller) external;


    function setMarginPool(address _marginPool) external;


    function setMarginCalculator(address _calculator) external;


    function setLiquidationManager(address _liquidationManager) external;


    function setOracle(address _oracle) external;


    function setRewards(address _rewards) external;


    function setAddress(bytes32 _id, address _newImpl) external;

}// UNLICENSED
pragma solidity 0.6.10;

interface OtokenInterface {

    function underlyingAsset() external view returns (address);


    function strikeAsset() external view returns (address);


    function collateralAsset() external view returns (address);


    function strikePrice() external view returns (uint256);


    function expiryTimestamp() external view returns (uint256);


    function isPut() external view returns (bool);


    function isWhitelisted() external view returns (bool);


    function init(
        address _addressBook,
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut,
        bool _isWhitelisted
    ) external;


    function getOtokenDetails()
        external
        view
        returns (
            address,
            address,
            address,
            uint256,
            uint256,
            bool
        );


    function mintOtoken(address account, uint256 amount) external;


    function burnOtoken(address account, uint256 amount) external;

}// UNLICENSED
pragma solidity 0.6.10;

interface WhitelistInterface {


    function addressBook() external view returns (address);


    function isWhitelistedProduct(
        address _underlying,
        address _strike,
        address _collateral,
        bool _isPut
    ) external view returns (bool);


    function isOwnerWhitelistedProduct(
        address _underlying,
        address _strike,
        address _collateral,
        bool _isPut
    ) external view returns (bool);


    function isWhitelistedCollateral(address _collateral) external view returns (bool);


    function isWhitelistedOtoken(address _otoken) external view returns (bool);


    function isOwnerWhitelistedOtoken(address _otoken) external view returns (bool);


    function isWhitelistedCallee(address _callee) external view returns (bool);


    function isWhitelistedOwner(address _owner) external view returns (bool);


    function whitelistProduct(
        address _underlying,
        address _strike,
        address _collateral,
        bool _isPut
    ) external;


    function whitelistCollateral(address _collateral) external;


    function ownerWhitelistProduct(
        address _underlying,
        address _strike,
        address _collateral,
        bool _isPut
    ) external;


    function blacklistProduct(
        address _underlying,
        address _strike,
        address _collateral,
        bool _isPut
    ) external;


    function ownerWhitelistCollateral(address _collateral) external;


    function blacklistCollateral(address _collateral) external;


    function whitelistOtoken(address _otoken) external;


    function blacklistOtoken(address _otoken) external;


    function whitelistCallee(address _callee) external;


    function blacklistCallee(address _callee) external;


    function whitelistOwner(address account) external;


    function blacklistOwner(address account) external;

}pragma solidity =0.6.10;


contract OtokenFactory is OtokenSpawner {

    using SafeMath for uint256;
    address public addressBook;

    address[] public otokens;

    mapping(bytes32 => address) private idToAddress;

    uint256 private constant MAX_EXPIRY = 11865398400;

    constructor(address _addressBook) public {
        addressBook = _addressBook;
    }

    event OtokenCreated(
        address tokenAddress,
        address creator,
        address indexed underlying,
        address indexed strike,
        address indexed collateral,
        uint256 strikePrice,
        uint256 expiry,
        bool isPut,
        bool whitelisted
    );

    function createOtoken(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external returns (address) {

        require(_expiry > now, "OtokenFactory: Can't create expired option");
        require(_expiry < MAX_EXPIRY, "OtokenFactory: Can't create option with expiry > 2345/12/31");
        require(_expiry.sub(28800).mod(86400) == 0, "OtokenFactory: Option has to expire 08:00 UTC");
        bytes32 id = _getOptionId(
            _underlyingAsset,
            _strikeAsset,
            _collateralAsset,
            _strikePrice,
            _expiry,
            _isPut,
            false
        );
        require(idToAddress[id] == address(0), "OtokenFactory: Option already created");

        address whitelist = AddressBookInterface(addressBook).getWhitelist();
        require(
            WhitelistInterface(whitelist).isWhitelistedProduct(
                _underlyingAsset,
                _strikeAsset,
                _collateralAsset,
                _isPut
            ),
            "OtokenFactory: Unsupported Product"
        );

        require(!_isPut || _strikePrice > 0, "OtokenFactory: Can't create a $0 strike put option");

        address otokenImpl = AddressBookInterface(addressBook).getOtokenImpl();

        bytes memory initializationCalldata = abi.encodeWithSelector(
            OtokenInterface(otokenImpl).init.selector,
            addressBook,
            _underlyingAsset,
            _strikeAsset,
            _collateralAsset,
            _strikePrice,
            _expiry,
            _isPut,
            false
        );

        address newOtoken = _spawn(otokenImpl, initializationCalldata);

        idToAddress[id] = newOtoken;
        otokens.push(newOtoken);
        WhitelistInterface(whitelist).whitelistOtoken(newOtoken);

        emit OtokenCreated(
            newOtoken,
            msg.sender,
            _underlyingAsset,
            _strikeAsset,
            _collateralAsset,
            _strikePrice,
            _expiry,
            _isPut,
            false
        );

        return newOtoken;
    }

    function createWhitelistedOtoken(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external returns (address) {

        require(_expiry > now, "OtokenFactory: Can't create expired option");
        require(_expiry < MAX_EXPIRY, "OtokenFactory: Can't create option with expiry > 2345/12/31");
        require(_expiry.sub(28800).mod(86400) == 0, "OtokenFactory: Option has to expire 08:00 UTC");
        bytes32 id = _getOptionId(
            _underlyingAsset,
            _strikeAsset,
            _collateralAsset,
            _strikePrice,
            _expiry,
            _isPut,
            true
        );
        require(idToAddress[id] == address(0), "OtokenFactory: Option already created");

        address whitelist = AddressBookInterface(addressBook).getWhitelist();
        require(WhitelistInterface(whitelist).isWhitelistedOwner(msg.sender), "OtokenFactory: Unsupported creator");
        require(
            WhitelistInterface(whitelist).isWhitelistedProduct(
                _underlyingAsset,
                _strikeAsset,
                _collateralAsset,
                _isPut
            ),
            "OtokenFactory: Unsupported Product"
        );

        require(!_isPut || _strikePrice > 0, "OtokenFactory: Can't create a $0 strike put option");

        address otokenImpl = AddressBookInterface(addressBook).getOtokenImpl();

        bytes memory initializationCalldata = abi.encodeWithSelector(
            OtokenInterface(otokenImpl).init.selector,
            addressBook,
            _underlyingAsset,
            _strikeAsset,
            _collateralAsset,
            _strikePrice,
            _expiry,
            _isPut,
            true
        );

        address newOtoken = _spawn(otokenImpl, initializationCalldata);

        idToAddress[id] = newOtoken;
        otokens.push(newOtoken);
        WhitelistInterface(whitelist).whitelistOtoken(newOtoken);

        emit OtokenCreated(
            newOtoken,
            msg.sender,
            _underlyingAsset,
            _strikeAsset,
            _collateralAsset,
            _strikePrice,
            _expiry,
            _isPut,
            true
        );

        return newOtoken;
    }

    function getOtokensLength() external view returns (uint256) {

        return otokens.length;
    }

    function getOtoken(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external view returns (address) {

        bytes32 id = _getOptionId(
            _underlyingAsset,
            _strikeAsset,
            _collateralAsset,
            _strikePrice,
            _expiry,
            _isPut,
            false
        );
        return idToAddress[id];
    }

    function getWhitelistedOtoken(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external view returns (address) {

        bytes32 id = _getOptionId(
            _underlyingAsset,
            _strikeAsset,
            _collateralAsset,
            _strikePrice,
            _expiry,
            _isPut,
            true
        );
        return idToAddress[id];
    }

    function getTargetOtokenAddress(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external view returns (address) {

        address otokenImpl = AddressBookInterface(addressBook).getOtokenImpl();

        bytes memory initializationCalldata = abi.encodeWithSelector(
            OtokenInterface(otokenImpl).init.selector,
            addressBook,
            _underlyingAsset,
            _strikeAsset,
            _collateralAsset,
            _strikePrice,
            _expiry,
            _isPut,
            false
        );
        return _computeAddress(otokenImpl, initializationCalldata);
    }

    function getTargetWhitelistedOtokenAddress(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut
    ) external view returns (address) {

        address otokenImpl = AddressBookInterface(addressBook).getOtokenImpl();

        bytes memory initializationCalldata = abi.encodeWithSelector(
            OtokenInterface(otokenImpl).init.selector,
            addressBook,
            _underlyingAsset,
            _strikeAsset,
            _collateralAsset,
            _strikePrice,
            _expiry,
            _isPut,
            true
        );
        return _computeAddress(otokenImpl, initializationCalldata);
    }

    function _getOptionId(
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut,
        bool _isWhitelisted
    ) internal pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    _underlyingAsset,
                    _strikeAsset,
                    _collateralAsset,
                    _strikePrice,
                    _expiry,
                    _isPut,
                    _isWhitelisted
                )
            );
    }
}