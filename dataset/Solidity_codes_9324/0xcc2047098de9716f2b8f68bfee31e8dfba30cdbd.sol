
pragma solidity 0.6.12;

interface ITimelockTarget {

    function setGov(address _gov) external;

}// MIT

pragma solidity 0.6.12;

interface IXVIX {

    function setGov(address gov) external;

    function createSafe(address account) external;

    function normalDivisor() external view returns (uint256);

    function maxSupply() external view returns (uint256);

    function mint(address account, uint256 amount) external returns (bool);

    function burn(address account, uint256 amount) external returns (bool);

    function toast(uint256 amount) external returns (bool);

    function rebase() external returns (bool);

}// MIT

pragma solidity 0.6.12;

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
}// MIT

pragma solidity 0.6.12;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity 0.6.12;



contract Timelock {

    using SafeMath for uint256;

    uint256 public buffer;
    address public admin;

    mapping (bytes32 => uint256) public pendingActions;

    event SignalPendingAction(bytes32 action);
    event SignalSetGov(address target, address gov, bytes32 action);
    event ClearAction(bytes32 action);

    modifier onlyAdmin() {

        require(msg.sender == admin, "Timelock: forbidden");
        _;
    }

    constructor(uint256 _buffer) public {
        buffer = _buffer;
        admin = msg.sender;
    }

    function createSafe(address _token, address _account) external onlyAdmin {

        IXVIX(_token).createSafe(_account);
    }

    function signalSetGov(address _target, address _gov) external onlyAdmin {

        bytes32 action = keccak256(abi.encodePacked("setGov", _target, _gov));
        _setPendingAction(action);
        emit SignalSetGov(_target, _gov, action);
    }

    function setGov(address _target, address _gov) external onlyAdmin {

        bytes32 action = keccak256(abi.encodePacked("setGov", _target, _gov));
        _validateAction(action);
        ITimelockTarget(_target).setGov(_gov);
        _clearAction(action);
    }

    function cancelAction(bytes32 _action) external onlyAdmin {

        _clearAction(_action);
    }

    function _setPendingAction(bytes32 _action) private {

        pendingActions[_action] = block.timestamp.add(buffer);
        emit SignalPendingAction(_action);
    }

    function _validateAction(bytes32 _action) private view {

        require(pendingActions[_action] != 0, "Timelock: action not signalled");
        require(pendingActions[_action] < block.timestamp, "Timelock: action time not yet passed");
    }

    function _clearAction(bytes32 _action) private {

        require(pendingActions[_action] != 0, "Timelock: invalid _action");
        delete pendingActions[_action];
        emit ClearAction(_action);
    }
}