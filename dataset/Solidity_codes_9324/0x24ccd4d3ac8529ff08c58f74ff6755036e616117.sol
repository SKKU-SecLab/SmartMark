
pragma solidity >=0.6.12 <0.8.0;

interface IController {

    function getGovernor() external view returns (address);



    function setContractProxy(bytes32 _id, address _contractAddress) external;


    function unsetContractProxy(bytes32 _id) external;


    function updateController(bytes32 _id, address _controller) external;


    function getContractProxy(bytes32 _id) external view returns (address);



    function setPartialPaused(bool _partialPaused) external;


    function setPaused(bool _paused) external;


    function setPauseGuardian(address _newPauseGuardian) external;


    function paused() external view returns (bool);


    function partialPaused() external view returns (bool);

}// MIT

pragma solidity ^0.7.3;

interface IManaged {

    function setController(address _controller) external;

}// MIT

pragma solidity ^0.7.3;

contract Governed {


    address public governor;
    address public pendingGovernor;


    event NewPendingOwnership(address indexed from, address indexed to);
    event NewOwnership(address indexed from, address indexed to);

    modifier onlyGovernor {

        require(msg.sender == governor, "Only Governor can call");
        _;
    }

    function _initialize(address _initGovernor) internal {

        governor = _initGovernor;
    }

    function transferOwnership(address _newGovernor) external onlyGovernor {

        require(_newGovernor != address(0), "Governor must be set");

        address oldPendingGovernor = pendingGovernor;
        pendingGovernor = _newGovernor;

        emit NewPendingOwnership(oldPendingGovernor, pendingGovernor);
    }

    function acceptOwnership() external {

        require(
            pendingGovernor != address(0) && msg.sender == pendingGovernor,
            "Caller must be pending governor"
        );

        address oldGovernor = governor;
        address oldPendingGovernor = pendingGovernor;

        governor = pendingGovernor;
        pendingGovernor = address(0);

        emit NewOwnership(oldGovernor, governor);
        emit NewPendingOwnership(oldPendingGovernor, pendingGovernor);
    }
}// MIT

pragma solidity ^0.7.3;

contract Pausable {

    bool internal _partialPaused;
    bool internal _paused;

    uint256 public lastPausePartialTime;
    uint256 public lastPauseTime;

    address public pauseGuardian;

    event PartialPauseChanged(bool isPaused);
    event PauseChanged(bool isPaused);
    event NewPauseGuardian(address indexed oldPauseGuardian, address indexed pauseGuardian);

    function _setPartialPaused(bool _toPause) internal {

        if (_toPause == _partialPaused) {
            return;
        }
        _partialPaused = _toPause;
        if (_partialPaused) {
            lastPausePartialTime = block.timestamp;
        }
        emit PartialPauseChanged(_partialPaused);
    }

    function _setPaused(bool _toPause) internal {

        if (_toPause == _paused) {
            return;
        }
        _paused = _toPause;
        if (_paused) {
            lastPauseTime = block.timestamp;
        }
        emit PauseChanged(_paused);
    }

    function _setPauseGuardian(address newPauseGuardian) internal {

        address oldPauseGuardian = pauseGuardian;
        pauseGuardian = newPauseGuardian;
        emit NewPauseGuardian(oldPauseGuardian, pauseGuardian);
    }
}// MIT

pragma solidity ^0.7.3;


contract Controller is Governed, Pausable, IController {

    mapping(bytes32 => address) private registry;

    event SetContractProxy(bytes32 indexed id, address contractAddress);

    constructor() {
        Governed._initialize(msg.sender);

        _setPaused(true);
    }

    modifier onlyGovernorOrGuardian {

        require(
            msg.sender == governor || msg.sender == pauseGuardian,
            "Only Governor or Guardian can call"
        );
        _;
    }

    function getGovernor() external override view returns (address) {

        return governor;
    }


    function setContractProxy(bytes32 _id, address _contractAddress)
        external
        override
        onlyGovernor
    {

        require(_contractAddress != address(0), "Contract address must be set");
        registry[_id] = _contractAddress;
        emit SetContractProxy(_id, _contractAddress);
    }

    function unsetContractProxy(bytes32 _id)
        external
        override
        onlyGovernor
    {

        registry[_id] = address(0);
        emit SetContractProxy(_id, address(0));
    }

    function getContractProxy(bytes32 _id) public override view returns (address) {

        return registry[_id];
    }

    function updateController(bytes32 _id, address _controller) external override onlyGovernor {

        require(_controller != address(0), "Controller must be set");
        return IManaged(registry[_id]).setController(_controller);
    }


    function setPartialPaused(bool _partialPaused) external override onlyGovernorOrGuardian {

        _setPartialPaused(_partialPaused);
    }

    function setPaused(bool _paused) external override onlyGovernorOrGuardian {

        _setPaused(_paused);
    }

    function setPauseGuardian(address _newPauseGuardian) external override onlyGovernor {

        require(_newPauseGuardian != address(0), "PauseGuardian must be set");
        _setPauseGuardian(_newPauseGuardian);
    }

    function paused() external override view returns (bool) {

        return _paused;
    }

    function partialPaused() external override view returns (bool) {

        return _partialPaused;
    }
}