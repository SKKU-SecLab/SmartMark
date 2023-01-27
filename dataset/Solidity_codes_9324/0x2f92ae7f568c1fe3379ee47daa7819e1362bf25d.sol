
pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// agpl-3.0
pragma solidity 0.8.5;

library RegistryEntities {

    struct ProtocolParametersArgs {
        uint32 noDataCancellationPeriod;
        uint32 derivativeAuthorExecutionFeeCap;
        uint32 derivativeAuthorRedemptionReservePart;
        uint32 protocolExecutionReservePart;
        uint32 protocolRedemptionReservePart;
        uint32 __gapOne;
        uint32 __gapTwo;
        uint32 __gapThree;
    }

    struct ProtocolAddressesArgs {
        address core;
        address opiumProxyFactory;
        address oracleAggregator;
        address syntheticAggregator;
        address tokenSpender;
        address protocolExecutionReserveClaimer;
        address protocolRedemptionReserveClaimer;
        uint32 __gapOne;
        uint32 __gapTwo;
    }

    struct ProtocolPausabilityArgs {
        bool protocolGlobal;
        bool protocolPositionCreation;
        bool protocolPositionMinting;
        bool protocolPositionRedemption;
        bool protocolPositionExecution;
        bool protocolPositionCancellation;
        bool protocolReserveClaim;
        bool __gapOne;
        bool __gapTwo;
        bool __gapThree;
        bool __gapFour;
    }
}// agpl-3.0
pragma solidity 0.8.5;

interface IRegistry {

    function initialize(address _governor) external;


    function setProtocolAddresses(
        address _opiumProxyFactory,
        address _core,
        address _oracleAggregator,
        address _syntheticAggregator,
        address _tokenSpender
    ) external;


    function setNoDataCancellationPeriod(uint32 _noDataCancellationPeriod) external;


    function addToWhitelist(address _whitelisted) external;


    function removeFromWhitelist(address _whitelisted) external;


    function setProtocolExecutionReserveClaimer(address _protocolExecutionReserveClaimer) external;


    function setProtocolRedemptionReserveClaimer(address _protocolRedemptionReserveClaimer) external;


    function setProtocolExecutionReservePart(uint32 _protocolExecutionReservePart) external;


    function setDerivativeAuthorExecutionFeeCap(uint32 _derivativeAuthorExecutionFeeCap) external;


    function setProtocolRedemptionReservePart(uint32 _protocolRedemptionReservePart) external;


    function setDerivativeAuthorRedemptionReservePart(uint32 _derivativeAuthorRedemptionReservePart) external;


    function pause() external;


    function pauseProtocolPositionCreation() external;


    function pauseProtocolPositionMinting() external;


    function pauseProtocolPositionRedemption() external;


    function pauseProtocolPositionExecution() external;


    function pauseProtocolPositionCancellation() external;


    function pauseProtocolReserveClaim() external;


    function unpause() external;


    function getProtocolParameters() external view returns (RegistryEntities.ProtocolParametersArgs memory);


    function getProtocolAddresses() external view returns (RegistryEntities.ProtocolAddressesArgs memory);


    function isRegistryManager(address _address) external view returns (bool);


    function isCoreConfigurationUpdater(address _address) external view returns (bool);


    function getCore() external view returns (address);


    function isCoreSpenderWhitelisted(address _address) external view returns (bool);


    function isProtocolPaused() external view returns (bool);


    function isProtocolPositionCreationPaused() external view returns (bool);


    function isProtocolPositionMintingPaused() external view returns (bool);


    function isProtocolPositionRedemptionPaused() external view returns (bool);


    function isProtocolPositionExecutionPaused() external view returns (bool);


    function isProtocolPositionCancellationPaused() external view returns (bool);


    function isProtocolReserveClaimPaused() external view returns (bool);

}// agpl-3.0
pragma solidity 0.8.5;


contract RegistryManager is Initializable {

    event LogRegistryChanged(address indexed _changer, address indexed _newRegistryAddress);

    IRegistry internal registry;

    modifier onlyRegistryManager() {

        require(registry.isRegistryManager(msg.sender), "M1");
        _;
    }

    modifier onlyCoreConfigurationUpdater() {

        require(registry.isCoreConfigurationUpdater(msg.sender), "M2");
        _;
    }

    function __RegistryManager__init(address _registry) internal initializer {

        require(_registry != address(0));
        registry = IRegistry(_registry);
        emit LogRegistryChanged(msg.sender, _registry);
    }

    function setRegistry(address _registry) external onlyRegistryManager {

        registry = IRegistry(_registry);
        emit LogRegistryChanged(msg.sender, _registry);
    }

    function getRegistry() external view returns (address) {

        return address(registry);
    }

    uint256[50] private __gap;
}// agpl-3.0
pragma solidity 0.8.5;

library LibDerivative {

    enum PositionType {
        SHORT,
        LONG
    }

    struct Derivative {
        uint256 margin;
        uint256 endTime;
        uint256[] params;
        address oracleId;
        address token;
        address syntheticId;
    }

    function getDerivativeHash(Derivative memory _derivative) internal pure returns (bytes32 derivativeHash) {

        derivativeHash = keccak256(
            abi.encodePacked(
                _derivative.margin,
                _derivative.endTime,
                _derivative.params,
                _derivative.oracleId,
                _derivative.token,
                _derivative.syntheticId
            )
        );
    }
}// agpl-3.0
pragma solidity 0.8.5;


interface IDerivativeLogic {

    event LogMetadataSet(string metadata);

    function validateInput(LibDerivative.Derivative memory _derivative) external view returns (bool);


    function getSyntheticIdName() external view returns (string memory);


    function getMargin(LibDerivative.Derivative memory _derivative)
        external
        view
        returns (uint256 buyerMargin, uint256 sellerMargin);


    function getExecutionPayout(LibDerivative.Derivative memory _derivative, uint256 _result)
        external
        view
        returns (uint256 buyerPayout, uint256 sellerPayout);


    function getAuthorAddress() external view returns (address authorAddress);


    function getAuthorCommission() external view returns (uint256 commission);


    function thirdpartyExecutionAllowed(address _derivativeOwner) external view returns (bool);


    function allowThirdpartyExecution(bool _allow) external;

}// agpl-3.0
pragma solidity 0.8.5;



contract SyntheticAggregator is ReentrancyGuardUpgradeable, RegistryManager {

    using LibDerivative for LibDerivative.Derivative;

    event LogSyntheticInit(LibDerivative.Derivative indexed derivative, bytes32 indexed derivativeHash);

    struct SyntheticCache {
        uint256 buyerMargin;
        uint256 sellerMargin;
        uint256 authorCommission;
        address authorAddress;
        bool init;
    }
    mapping(bytes32 => SyntheticCache) private syntheticCaches;


    function initialize(address _registry) external initializer {

        __RegistryManager__init(_registry);
        __ReentrancyGuard_init();
    }

    function getOrCacheMargin(bytes32 _derivativeHash, LibDerivative.Derivative calldata _derivative)
        external
        returns (uint256 buyerMargin, uint256 sellerMargin)
    {

        if (!syntheticCaches[_derivativeHash].init) {
            _initDerivative(_derivativeHash, _derivative);
        }
        return (syntheticCaches[_derivativeHash].buyerMargin, syntheticCaches[_derivativeHash].sellerMargin);
    }

    function getOrCacheSyntheticCache(bytes32 _derivativeHash, LibDerivative.Derivative calldata _derivative)
        external
        returns (SyntheticCache memory)
    {

        if (!syntheticCaches[_derivativeHash].init) {
            _initDerivative(_derivativeHash, _derivative);
        }
        return syntheticCaches[_derivativeHash];
    }


    function _initDerivative(bytes32 _derivativeHash, LibDerivative.Derivative memory _derivative)
        private
        nonReentrant
    {

        bytes32 derivativeHash = _derivative.getDerivativeHash();
        require(derivativeHash == _derivativeHash, "S1");

        (uint256 buyerMargin, uint256 sellerMargin) = IDerivativeLogic(_derivative.syntheticId).getMargin(_derivative);
        require(buyerMargin != 0 || sellerMargin != 0, "S2");

        uint256 authorCommission = IDerivativeLogic(_derivative.syntheticId).getAuthorCommission();
        RegistryEntities.ProtocolParametersArgs memory protocolParametersArgs = registry.getProtocolParameters();
        require(authorCommission <= protocolParametersArgs.derivativeAuthorExecutionFeeCap, "S3");
        syntheticCaches[derivativeHash] = SyntheticCache({
            buyerMargin: buyerMargin,
            sellerMargin: sellerMargin,
            authorCommission: authorCommission,
            authorAddress: IDerivativeLogic(_derivative.syntheticId).getAuthorAddress(),
            init: true
        });

        emit LogSyntheticInit(_derivative, derivativeHash);
    }

    uint256[50] private __gap;
}