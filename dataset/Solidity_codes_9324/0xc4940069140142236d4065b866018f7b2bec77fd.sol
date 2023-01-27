

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
}// Apache-2.0


pragma solidity ^0.6.11;


contract OutboxEntry is Cloneable {

    address outbox;
    bytes32 public root;
    uint256 public numRemaining;
    mapping(bytes32 => bool) public spentOutput;

    function initialize(bytes32 _root, uint256 _numInBatch) external {

        require(outbox == address(0), "ALREADY_INIT");
        require(root == 0, "ALREADY_INIT");
        require(_root != 0, "BAD_ROOT");
        outbox = msg.sender;
        root = _root;
        numRemaining = _numInBatch;
    }

    function spendOutput(bytes32 _root, bytes32 _id) external returns (uint256) {

        require(msg.sender == outbox, "NOT_FROM_OUTBOX");
        require(!spentOutput[_id], "ALREADY_SPENT");
        require(_root == root, "BAD_ROOT");

        spentOutput[_id] = true;
        numRemaining--;

        return numRemaining;
    }

    function destroy() external {

        require(msg.sender == outbox, "NOT_FROM_OUTBOX");
        safeSelfDestruct(msg.sender);
    }
}