pragma solidity ^0.8.0;

interface ICommand {

    function isTriggerDataValid(uint256 _cdpId, bytes memory triggerData)
        external
        view
        returns (bool);


    function isExecutionCorrect(uint256 cdpId, bytes memory triggerData)
        external
        view
        returns (bool);


    function isExecutionLegal(uint256 cdpId, bytes memory triggerData) external view returns (bool);


    function execute(
        bytes calldata executionData,
        uint256 cdpId,
        bytes memory triggerData
    ) external;

}//Unlicense
pragma solidity ^0.8.0;

interface ManagerLike {

    function cdpCan(
        address owner,
        uint256 cdpId,
        address allowedAddr
    ) external view returns (uint256);


    function vat() external view returns (address);


    function ilks(uint256) external view returns (bytes32);


    function owns(uint256) external view returns (address);


    function urns(uint256) external view returns (address);


    function cdpAllow(
        uint256 cdp,
        address usr,
        uint256 ok
    ) external;


    function frob(
        uint256,
        int256,
        int256
    ) external;


    function flux(
        uint256,
        address,
        uint256
    ) external;


    function move(
        uint256,
        address,
        uint256
    ) external;


    function exit(
        address,
        uint256,
        address,
        uint256
    ) external;

}//Unlicense
pragma solidity ^0.8.0;

interface BotLike {

    function addRecord(
        uint256 cdpId,
        uint256 triggerType,
        uint256 replacedTriggerId,
        bytes memory triggerData
    ) external;


    function removeRecord(
        uint256 cdpId,
        uint256 triggerId
    ) external;


    function execute(
        bytes calldata executionData,
        uint256 cdpId,
        bytes calldata triggerData,
        address commandAddress,
        uint256 triggerId,
        uint256 daiCoverage
    ) external;

}//Unlicense
pragma solidity ^0.8.0;

interface MPALike {

    struct CdpData {
        address gemJoin;
        address payable fundsReceiver;
        uint256 cdpId;
        bytes32 ilk;
        uint256 requiredDebt;
        uint256 borrowCollateral;
        uint256 withdrawCollateral;
        uint256 withdrawDai;
        uint256 depositDai;
        uint256 depositCollateral;
        bool skipFL;
        string methodName;
    }

    struct AddressRegistry {
        address jug;
        address manager;
        address multiplyProxyActions;
        address lender;
        address exchange;
    }

    struct ExchangeData {
        address fromTokenAddress;
        address toTokenAddress;
        uint256 fromTokenAmount;
        uint256 toTokenAmount;
        uint256 minToTokenAmount;
        address exchangeAddress;
        bytes _exchangeCalldata;
    }

    function closeVaultExitCollateral(
        ExchangeData calldata exchangeData,
        CdpData memory cdpData,
        AddressRegistry calldata addressRegistry
    ) external;


    function closeVaultExitDai(
        ExchangeData calldata exchangeData,
        CdpData memory cdpData,
        AddressRegistry calldata addressRegistry
    ) external;

}//Unlicense
pragma solidity ^0.8.0;

contract ServiceRegistry {

    uint256 public constant MAX_DELAY = 30 days;

    mapping(bytes32 => uint256) public lastExecuted;
    mapping(bytes32 => address) private namedService;
    address public owner;
    uint256 public requiredDelay;

    modifier validateInput(uint256 len) {

        require(msg.data.length == len, "registry/illegal-padding");
        _;
    }

    modifier delayedExecution() {

        bytes32 operationHash = keccak256(msg.data);
        uint256 reqDelay = requiredDelay;

        if (lastExecuted[operationHash] == 0 && reqDelay > 0) {
            lastExecuted[operationHash] = block.timestamp;
            emit ChangeScheduled(operationHash, block.timestamp + reqDelay, msg.data);
        } else {
            require(
                block.timestamp - reqDelay > lastExecuted[operationHash],
                "registry/delay-too-small"
            );
            emit ChangeApplied(operationHash, block.timestamp, msg.data);
            _;
            lastExecuted[operationHash] = 0;
        }
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "registry/only-owner");
        _;
    }

    constructor(uint256 initialDelay) {
        require(initialDelay <= MAX_DELAY, "registry/invalid-delay");
        requiredDelay = initialDelay;
        owner = msg.sender;
    }

    function transferOwnership(address newOwner)
        external
        onlyOwner
        validateInput(36)
        delayedExecution
    {

        owner = newOwner;
    }

    function changeRequiredDelay(uint256 newDelay)
        external
        onlyOwner
        validateInput(36)
        delayedExecution
    {

        require(newDelay <= MAX_DELAY, "registry/invalid-delay");
        requiredDelay = newDelay;
    }

    function getServiceNameHash(string memory name) external pure returns (bytes32) {

        return keccak256(abi.encodePacked(name));
    }

    function addNamedService(bytes32 serviceNameHash, address serviceAddress)
        external
        onlyOwner
        validateInput(68)
        delayedExecution
    {

        require(namedService[serviceNameHash] == address(0), "registry/service-override");
        namedService[serviceNameHash] = serviceAddress;
    }

    function updateNamedService(bytes32 serviceNameHash, address serviceAddress)
        external
        onlyOwner
        validateInput(68)
        delayedExecution
    {

        require(namedService[serviceNameHash] != address(0), "registry/service-does-not-exist");
        namedService[serviceNameHash] = serviceAddress;
    }

    function removeNamedService(bytes32 serviceNameHash) external onlyOwner validateInput(36) {

        require(namedService[serviceNameHash] != address(0), "registry/service-does-not-exist");
        namedService[serviceNameHash] = address(0);
        emit NamedServiceRemoved(serviceNameHash);
    }

    function getRegisteredService(string memory serviceName) external view returns (address) {

        return namedService[keccak256(abi.encodePacked(serviceName))];
    }

    function getServiceAddress(bytes32 serviceNameHash) external view returns (address) {

        return namedService[serviceNameHash];
    }

    function clearScheduledExecution(bytes32 scheduledExecution)
        external
        onlyOwner
        validateInput(36)
    {

        require(lastExecuted[scheduledExecution] > 0, "registry/execution-not-scheduled");
        lastExecuted[scheduledExecution] = 0;
        emit ChangeCancelled(scheduledExecution);
    }

    event ChangeScheduled(bytes32 dataHash, uint256 scheduledFor, bytes data);
    event ChangeApplied(bytes32 dataHash, uint256 appliedAt, bytes data);
    event ChangeCancelled(bytes32 dataHash);
    event NamedServiceRemoved(bytes32 nameHash);
}//Unlicense
pragma solidity ^0.8.0;

interface IPipInterface {

    function read() external returns (bytes32);

}

interface SpotterLike {

    function ilks(bytes32) external view returns (IPipInterface pip, uint256 mat);


    function par() external view returns (uint256);

}//Unlicense
pragma solidity ^0.8.0;

interface VatLike {

    function urns(bytes32, address) external view returns (uint256 ink, uint256 art);


    function ilks(bytes32)
        external
        view
        returns (
            uint256 art, // Total Normalised Debt      [wad]
            uint256 rate, // Accumulated Rates         [ray]
            uint256 spot, // Price with Safety Margin  [ray]
            uint256 line, // Debt Ceiling              [rad]
            uint256 dust // Urn Debt Floor             [rad]
        );


    function gem(bytes32, address) external view returns (uint256); // [wad]


    function can(address, address) external view returns (uint256);


    function dai(address) external view returns (uint256);


    function frob(
        bytes32,
        address,
        address,
        address,
        int256,
        int256
    ) external;


    function hope(address) external;


    function move(
        address,
        address,
        uint256
    ) external;


    function fork(
        bytes32,
        address,
        address,
        int256,
        int256
    ) external;

}//Unlicense
pragma solidity ^0.8.0;

interface OsmMomLike {

    function osms(bytes32) external view returns (address);

}//Unlicense
pragma solidity ^0.8.0;

interface OsmLike {

    function peep() external view returns (bytes32, bool);


    function bud(address) external view returns (uint256);


    function kiss(address a) external;

}//Unlicense
pragma solidity ^0.8.0;

contract DSMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "");
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x / y;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x >= y ? x : y;
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {

        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {

        return x >= y ? x : y;
    }

    uint256 internal constant WAD = 10**18;
    uint256 internal constant RAY = 10**27;

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}//Unlicense
pragma solidity ^0.8.0;


contract McdView is DSMath {

    ManagerLike public manager;
    VatLike public vat;
    SpotterLike public spotter;
    OsmMomLike public osmMom;
    address public owner;
    mapping(address => bool) public whitelisted;

    constructor(
        address _vat,
        address _manager,
        address _spotter,
        address _mom,
        address _owner
    ) {
        manager = ManagerLike(_manager);
        vat = VatLike(_vat);
        spotter = SpotterLike(_spotter);
        osmMom = OsmMomLike(_mom);
        owner = _owner;
    }

    function approve(address _allowedReader, bool isApproved) external {

        require(msg.sender == owner, "mcd-view/not-authorised");
        whitelisted[_allowedReader] = isApproved;
    }

    function getVaultInfo(uint256 vaultId) public view returns (uint256, uint256) {

        address urn = manager.urns(vaultId);
        bytes32 ilk = manager.ilks(vaultId);

        (uint256 collateral, uint256 debt) = vat.urns(ilk, urn);
        (, uint256 rate, , , ) = vat.ilks(ilk);

        return (collateral, rmul(debt, rate));
    }

    function getPrice(bytes32 ilk) public view returns (uint256) {

        (, uint256 mat) = spotter.ilks(ilk);
        (, , uint256 spot, , ) = vat.ilks(ilk);

        return div(rmul(rmul(spot, spotter.par()), mat), 10**9);
    }

    function getNextPrice(bytes32 ilk) public view returns (uint256) {

        require(whitelisted[msg.sender], "mcd-view/not-whitelisted");
        OsmLike osm = OsmLike(osmMom.osms(ilk));
        (bytes32 val, bool status) = osm.peep();
        require(status, "mcd-view/osm-price-error");
        return uint256(val);
    }

    function getRatio(uint256 vaultId, bool useNextPrice) public view returns (uint256) {

        bytes32 ilk = manager.ilks(vaultId);
        uint256 price = useNextPrice ? getNextPrice(ilk) : getPrice(ilk);
        (uint256 collateral, uint256 debt) = getVaultInfo(vaultId);
        if (debt == 0) return 0;
        return wdiv(wmul(collateral, price), debt);
    }
}//Unlicense
pragma solidity ^0.8.0;

contract CloseCommand is ICommand {

    address public immutable serviceRegistry;
    string private constant CDP_MANAGER_KEY = "CDP_MANAGER";
    string private constant MCD_VIEW_KEY = "MCD_VIEW";
    string private constant MPA_KEY = "MULTIPLY_PROXY_ACTIONS";

    constructor(address _serviceRegistry) {
        serviceRegistry = _serviceRegistry;
    }

    function isExecutionCorrect(uint256 cdpId, bytes memory) external view override returns (bool) {

        address viewAddress = ServiceRegistry(serviceRegistry).getRegisteredService(MCD_VIEW_KEY);
        McdView viewerContract = McdView(viewAddress);
        (uint256 collateral, uint256 debt) = viewerContract.getVaultInfo(cdpId);
        return !(collateral > 0 || debt > 0);
    }

    function isExecutionLegal(uint256 _cdpId, bytes memory triggerData)
        external
        view
        override
        returns (bool)
    {

        (, , uint256 slLevel) = abi.decode(triggerData, (uint256, uint16, uint256));

        address managerAddress = ServiceRegistry(serviceRegistry).getRegisteredService(
            CDP_MANAGER_KEY
        );
        ManagerLike manager = ManagerLike(managerAddress);
        if (manager.owns(_cdpId) == address(0)) {
            return false;
        }
        address viewAddress = ServiceRegistry(serviceRegistry).getRegisteredService(MCD_VIEW_KEY);
        uint256 collRatio = McdView(viewAddress).getRatio(_cdpId, true);
        bool vaultNotEmpty = collRatio != 0; // MCD_VIEW contract returns 0 (instead of infinity) as a collateralisation ratio of empty vault
        return vaultNotEmpty && collRatio <= slLevel * 10**16;
    }

    function execute(
        bytes calldata executionData,
        uint256,
        bytes memory triggerData
    ) external override {

        (, uint16 triggerType, ) = abi.decode(triggerData, (uint256, uint16, uint256));

        address mpaAddress = ServiceRegistry(serviceRegistry).getRegisteredService(MPA_KEY);

        bytes4 prefix = abi.decode(executionData, (bytes4));
        bytes4 expectedSelector;

        if (triggerType == 1) {
            expectedSelector = MPALike.closeVaultExitCollateral.selector;
        } else if (triggerType == 2) {
            expectedSelector = MPALike.closeVaultExitDai.selector;
        } else revert("unsupported-triggerType");

        require(prefix == expectedSelector, "wrong-payload");
        (bool status, ) = mpaAddress.delegatecall(executionData);

        require(status, "execution failed");
    }

    function isTriggerDataValid(uint256 _cdpId, bytes memory triggerData)
        external
        pure
        override
        returns (bool)
    {

        (uint256 cdpId, uint16 triggerType, uint256 slLevel) = abi.decode(
            triggerData,
            (uint256, uint16, uint256)
        );
        return slLevel > 100 && _cdpId == cdpId && (triggerType == 1 || triggerType == 2);
    }
}