pragma solidity 0.6.11;

interface ITimeLock {

    event NewAdmin(address admin);
    event NewDelay(uint delay);
    event Queue(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        bytes data,
        uint eta
    );
    event Execute(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        bytes data,
        uint eta
    );
    event Cancel(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        bytes data,
        uint eta
    );

    function admin() external view returns (address);


    function delay() external view returns (uint);


    function queued(bytes32 _txHash) external view returns (bool);


    function setAdmin(address _admin) external;


    function setDelay(uint _delay) external;


    receive() external payable;

    function getTxHash(
        address target,
        uint value,
        bytes calldata data,
        uint eta
    ) external pure returns (bytes32);


    function queue(
        address target,
        uint value,
        bytes calldata data,
        uint eta
    ) external returns (bytes32);


    function execute(
        address target,
        uint value,
        bytes calldata data,
        uint eta
    ) external payable returns (bytes memory);


    function cancel(
        address target,
        uint value,
        bytes calldata data,
        uint eta
    ) external;

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
}// AGPL-3.0-or-later
pragma solidity 0.6.11;

contract TimeLock is ITimeLock {

    using SafeMath for uint;

    event NewAdmin(address admin);
    event NewDelay(uint delay);
    event Queue(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        bytes data,
        uint eta
    );
    event Execute(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        bytes data,
        uint eta
    );
    event Cancel(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        bytes data,
        uint eta
    );

    uint public constant GRACE_PERIOD = 14 days;
    uint public constant MIN_DELAY = 1 days;
    uint public constant MAX_DELAY = 30 days;

    address public override admin;
    uint public override delay;

    mapping(bytes32 => bool) public override queued;

    constructor(uint _delay) public {
        admin = msg.sender;
        _setDelay(_delay);
    }

    receive() external payable override {}

    modifier onlyAdmin() {

        require(msg.sender == admin, "!admin");
        _;
    }

    function setAdmin(address _admin) external override onlyAdmin {

        require(_admin != address(0), "admin = zero address");
        admin = _admin;
        emit NewAdmin(_admin);
    }

    function _setDelay(uint _delay) private {

        require(_delay >= MIN_DELAY, "delay < min");
        require(_delay <= MAX_DELAY, "delay > max");
        delay = _delay;

        emit NewDelay(delay);
    }

    function setDelay(uint _delay) external override {

        require(msg.sender == address(this), "!timelock");

        _setDelay(_delay);
    }

    function _getTxHash(
        address target,
        uint value,
        bytes memory data,
        uint eta
    ) private pure returns (bytes32) {

        return keccak256(abi.encode(target, value, data, eta));
    }

    function getTxHash(
        address target,
        uint value,
        bytes calldata data,
        uint eta
    ) external pure override returns (bytes32) {

        return _getTxHash(target, value, data, eta);
    }

    function queue(
        address target,
        uint value,
        bytes calldata data,
        uint eta
    ) external override onlyAdmin returns (bytes32) {

        require(eta >= block.timestamp.add(delay), "eta < now + delay");

        bytes32 txHash = _getTxHash(target, value, data, eta);
        queued[txHash] = true;

        emit Queue(txHash, target, value, data, eta);

        return txHash;
    }

    function execute(
        address target,
        uint value,
        bytes calldata data,
        uint eta
    ) external payable override onlyAdmin returns (bytes memory) {

        bytes32 txHash = _getTxHash(target, value, data, eta);
        require(queued[txHash], "!queued");
        require(block.timestamp >= eta, "eta < now");
        require(block.timestamp <= eta.add(GRACE_PERIOD), "eta expired");

        queued[txHash] = false;

        (bool success, bytes memory returnData) = target.call{value: value}(data);
        require(success, "tx failed");

        emit Execute(txHash, target, value, data, eta);

        return returnData;
    }

    function cancel(
        address target,
        uint value,
        bytes calldata data,
        uint eta
    ) external override onlyAdmin {

        bytes32 txHash = _getTxHash(target, value, data, eta);
        require(queued[txHash], "!queued");

        queued[txHash] = false;

        emit Cancel(txHash, target, value, data, eta);
    }
}