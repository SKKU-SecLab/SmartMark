

pragma solidity 0.5.17;

interface IProxyManager {

    function proxyActions() external view returns (address);

    function proxyActionsStorage() external view returns (address);

}


pragma solidity 0.5.17;

interface IProxyActions {

    function setup() external;

}


pragma solidity 0.5.17;

interface IVat {

    function hope(address usr) external;

    function gem(bytes32, address) external view returns (uint);

    function dai(address) external view returns (uint);

}


pragma solidity 0.5.17;

interface IETHJoin {

    function join(address usr) external payable;

    function exit(address payable usr, uint wad) external;

}


pragma solidity 0.5.17;

interface ITokenJoin {

    function join(address usr, uint wad) external;

    function exit(address usr, uint wad) external;

}


pragma solidity 0.5.17;

contract IFlip {

    function tick(uint id) external;

    function tend(uint id, uint lot, uint bid) external;

    function dent(uint id, uint lot, uint bid) external;

    function deal(uint id) external;

}


pragma solidity 0.5.17;

contract IFlap {

    function tick(uint id) external;

    function tend(uint id, uint lot, uint bid) external;

    function deal(uint id) external;

}


pragma solidity 0.5.17;

contract IFlop {

    function tick(uint id) external;

    function dent(uint id, uint lot, uint bid) external;

    function deal(uint id) external;

}


pragma solidity 0.5.17;

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


pragma solidity 0.5.17;

interface IProxyActionsStorage  {


    function vat() external view returns (IVat);

    function flap() external view returns (IFlap);

    function flop() external view returns (IFlop);


    function tokens(bytes32) external view returns (IERC20);

    function decimals(bytes32) external view returns (uint);

    function ilks(bytes32) external view returns (bytes32);

    function tokenJoins(bytes32) external view returns (ITokenJoin);

    function flips(bytes32) external view returns (IFlip);

}


pragma solidity 0.5.17;




contract Proxy {


    IProxyManager private manager;
    IProxyActionsStorage private store;
    address private owner;

    constructor(address _owner) public {
        manager = IProxyManager(msg.sender);
        store = IProxyActionsStorage(manager.proxyActionsStorage());
        owner = _owner;
    }

    function() external payable {
        if(msg.data.length != 0) {
            address target = manager.proxyActions();
            store = IProxyActionsStorage(manager.proxyActionsStorage());

            assembly {
                calldatacopy(0, 0, calldatasize())
                let result := delegatecall(gas, target, 0, calldatasize(), 0, 0)
                returndatacopy(0, 0, returndatasize())
                switch result
                case 0 { revert(0, returndatasize()) }
                default { return (0, returndatasize()) }
            }
        }
    }
}


pragma solidity 0.5.17;


contract ProxyManager {


    address public owner;
    address public proxyActions;
    address public proxyActionsStorage;

    uint public timelockDuration;
    uint public currentTimelock;

    uint public pendingTimelockDuration;
    address public pendingProxyActions;
    address public pendingProxyActionsStorage;

    mapping(address => address) public proxies;

    event ValuesSubmittedForTimelock(uint pendingTimelockDuration, address pendingProxyActions, address pendingProxyActionsStorage);
    event NewTimelockDuration(uint old, uint updated);
    event NewProxyActions(address old, address updated);
    event NewProxyActionsStorage(address old, address updated);


    modifier onlyOwner {

        require(msg.sender == owner, "ProxyManager / onlyOwner: not allowed");
        _;
    }

    constructor(address _proxyActions, address _proxyActionsStorage) public {
        owner = msg.sender;
        proxyActions = _proxyActions;
        proxyActionsStorage = _proxyActionsStorage;
        timelockDuration = 3 days;

        emit NewTimelockDuration(0, timelockDuration);
        emit NewProxyActions(address(0), _proxyActions);
        emit NewProxyActionsStorage(address(0), _proxyActionsStorage);
    }

    function submitTimelockValues(
        uint _pendingTimelockDuration,
        address _pendingProxyActions,
        address _pendingProxyActionsStorage
    ) external onlyOwner {

        require(_pendingTimelockDuration <= 7 days, "ProxyManager / submitTimelockValues: duration too high");

        pendingTimelockDuration = _pendingTimelockDuration;
        pendingProxyActions = _pendingProxyActions;
        pendingProxyActionsStorage = _pendingProxyActionsStorage;

        currentTimelock = now + timelockDuration;

        emit ValuesSubmittedForTimelock(_pendingTimelockDuration, _pendingProxyActions, _pendingProxyActionsStorage);
    }

    function implementTimelockValues() external onlyOwner {

        require(now > currentTimelock, "ProxyManager / implementTimelockValues: timelock not over");

        if(pendingTimelockDuration != 0) {
            emit NewTimelockDuration(timelockDuration, pendingTimelockDuration);
            timelockDuration = pendingTimelockDuration;
            pendingTimelockDuration = 0;
        }

        if(pendingProxyActions != address(0)) {
            emit NewProxyActions(proxyActions, pendingProxyActions);
            proxyActions = pendingProxyActions;
            pendingProxyActions = address(0);
        }

        if(pendingProxyActionsStorage != address(0)) {
            emit NewProxyActionsStorage(proxyActionsStorage, pendingProxyActionsStorage);
            proxyActionsStorage = pendingProxyActionsStorage;
            pendingProxyActionsStorage = address(0);
        }

        currentTimelock = 0;
    }

    function deploy() external {

        require(proxies[msg.sender] == address(0), "ProxyManager / deploy: already deployed");
        address newProxy = address(new Proxy(msg.sender));
        proxies[msg.sender] = newProxy;
        IProxyActions(newProxy).setup();
    }
}