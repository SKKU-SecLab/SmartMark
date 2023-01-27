

pragma solidity ^0.6.11;

interface INode {

    function initialize(
        address _rollup,
        bytes32 _stateHash,
        bytes32 _challengeHash,
        bytes32 _confirmData,
        uint256 _prev,
        uint256 _deadlineBlock
    ) external;


    function destroy() external;


    function addStaker(address staker) external returns (uint256);


    function removeStaker(address staker) external;


    function childCreated(uint256) external;


    function newChildConfirmDeadline(uint256 deadline) external;


    function stateHash() external view returns (bytes32);


    function challengeHash() external view returns (bytes32);


    function confirmData() external view returns (bytes32);


    function prev() external view returns (uint256);


    function deadlineBlock() external view returns (uint256);


    function noChildConfirmedBeforeBlock() external view returns (uint256);


    function stakerCount() external view returns (uint256);


    function stakers(address staker) external view returns (bool);


    function firstChildBlock() external view returns (uint256);


    function latestChildNumber() external view returns (uint256);


    function requirePastDeadline() external view;


    function requirePastChildConfirmDeadline() external view;

}// Apache-2.0


pragma solidity ^0.6.11;

interface ICloneable {

    function isMaster() external view returns (bool);

}// Apache-2.0


pragma solidity ^0.6.11;


contract Cloneable is ICloneable {

    string private constant NOT_CLONE = "NOT_CLONE";

    bool private isMasterCopy;

    constructor() public {
        isMasterCopy = true;
    }

    function isMaster() external view override returns (bool) {

        return isMasterCopy;
    }

    function safeSelfDestruct(address payable dest) internal {

        require(!isMasterCopy, NOT_CLONE);
        selfdestruct(dest);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// Apache-2.0


pragma solidity ^0.6.11;


contract Node is Cloneable, INode {

    using SafeMath for uint256;

    bytes32 public override stateHash;

    bytes32 public override challengeHash;

    bytes32 public override confirmData;

    uint256 public override prev;

    uint256 public override deadlineBlock;

    uint256 public override noChildConfirmedBeforeBlock;

    uint256 public override stakerCount;

    mapping(address => bool) public override stakers;

    address public rollup;

    uint256 public override firstChildBlock;

    uint256 public override latestChildNumber;

    modifier onlyRollup {

        require(msg.sender == rollup, "ROLLUP_ONLY");
        _;
    }

    function initialize(
        address _rollup,
        bytes32 _stateHash,
        bytes32 _challengeHash,
        bytes32 _confirmData,
        uint256 _prev,
        uint256 _deadlineBlock
    ) external override {

        require(_rollup != address(0), "ROLLUP_ADDR");
        require(rollup == address(0), "ALREADY_INIT");
        rollup = _rollup;
        stateHash = _stateHash;
        challengeHash = _challengeHash;
        confirmData = _confirmData;
        prev = _prev;
        deadlineBlock = _deadlineBlock;
        noChildConfirmedBeforeBlock = _deadlineBlock;
    }

    function destroy() external override onlyRollup {

        safeSelfDestruct(msg.sender);
    }

    function addStaker(address staker) external override onlyRollup returns (uint256) {

        require(!stakers[staker], "ALREADY_STAKED");
        stakers[staker] = true;
        stakerCount++;
        return stakerCount;
    }

    function removeStaker(address staker) external override onlyRollup {

        require(stakers[staker], "NOT_STAKED");
        stakers[staker] = false;
        stakerCount--;
    }

    function childCreated(uint256 number) external override onlyRollup {

        if (firstChildBlock == 0) {
            firstChildBlock = block.number;
        }
        latestChildNumber = number;
    }

    function newChildConfirmDeadline(uint256 deadline) external override onlyRollup {

        noChildConfirmedBeforeBlock = deadline;
    }

    function requirePastDeadline() external view override {

        require(block.number >= deadlineBlock, "BEFORE_DEADLINE");
    }

    function requirePastChildConfirmDeadline() external view override {

        require(block.number >= noChildConfirmedBeforeBlock, "CHILD_TOO_RECENT");
    }
}