
pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT
pragma solidity ^0.8.4;

interface IGnosisSafe {

    enum Operation {
        Call,
        DelegateCall
    }

    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Operation operation
    ) external returns (bool success);


    function enableModule(address module) external;


    function isModuleEnabled(address module) external view returns (bool);

}// MIT
pragma solidity ^0.8.4;

interface IProposalRegistry {

    enum VotingType {
        Single,
        Weighted
    }

    struct Proposal {
        uint256 deadline;
        uint256 maxIndex;
        VotingType _type;
    }

    function proposalInfo(bytes32 proposalHash)
        external
        returns (Proposal memory ProposalInfo);

}// MIT
pragma solidity ^0.8.4;



contract VoteProcessorModule is Pausable {

    using EnumerableSet for EnumerableSet.AddressSet;

    struct Vote {
        uint256 timestamp;
        uint256 choice;
        string version;
        string space;
        string voteType;
        bool approved;
    }

    string public constant NAME = "Vote Processor Module";
    string public constant VERSION = "0.1.0";
    address public constant signMessageLib =
        0xA65387F16B013cf2Af4605Ad8aA5ec25a2cbA3a2;

    IProposalRegistry public proposalRegistry;

    address public governance;

    mapping(string => Vote) public proposals;

    EnumerableSet.AddressSet internal _proposers;
    EnumerableSet.AddressSet internal _validators;

    event VoteApproved(address approver, string proposal);

    constructor(address _governance, address _proposalRegistry) {
        governance = _governance;
        proposalRegistry = IProposalRegistry(_proposalRegistry);
    }

    modifier onlyVoteProposers() {

        require(_proposers.contains(msg.sender), "not-proposer!");
        _;
    }

    modifier onlyVoteValidators() {

        require(_validators.contains(msg.sender), "not-validator!");
        _;
    }

    modifier onlyGovernance() {

        require(msg.sender == governance, "not-governance!");
        _;
    }


    function addProposer(address _proposer) external onlyGovernance {

        require(_proposer != address(0), "zero-address!");
        _proposers.add(_proposer);
    }

    function removeProposer(address _proposer) external onlyGovernance {

        require(_proposer != address(0), "zero-address!");
        _proposers.remove(_proposer);
    }

    function addValidator(address _validator) external onlyGovernance {

        require(_validator != address(0), "zero-address!");
        _validators.add(_validator);
    }

    function removeValidator(address _validator) external onlyGovernance {

        require(_validator != address(0), "zero-address!");
        _validators.remove(_validator);
    }

    function pause() external onlyGovernance {

        _pause();
    }

    function unpause() external onlyGovernance {

        _unpause();
    }


    function setProposalVote(
        uint256 choice,
        uint256 timestamp,
        string memory version,
        string memory proposal,
        string memory space,
        string memory voteType
    ) external onlyVoteProposers {

        bytes32 proposalHash = keccak256(abi.encodePacked(proposal));
        IProposalRegistry.Proposal memory proposalInfo = proposalRegistry
            .proposalInfo(proposalHash);

        require(proposalInfo.deadline > block.timestamp, "deadline!");

        if (IProposalRegistry.VotingType.Single == proposalInfo._type) {
            require(proposalInfo.maxIndex >= choice, "invalid choice");
        } else {
        }

        Vote memory vote = Vote(
            timestamp,
            choice,
            version,
            space,
            voteType,
            false
        );
        proposals[proposal] = vote;
    }

    function verifyVote(string memory proposal) external onlyVoteValidators {

        Vote storage vote = proposals[proposal];
        vote.approved = true;
        emit VoteApproved(msg.sender, proposal);
    }

    function sign(IGnosisSafe safe, string memory proposal)
        external
        whenNotPaused
    {

        require(proposals[proposal].approved, "not-approved!");

        bytes memory data = abi.encodeWithSignature(
            "signMessage(bytes32)",
            hash(proposal)
        );

        require(
            safe.execTransactionFromModule(
                signMessageLib,
                0,
                data,
                IGnosisSafe.Operation.DelegateCall
            ),
            "sign-error!"
        );
    }


    function hash(string memory proposal) public view returns (bytes32) {

        Vote memory vote = proposals[proposal];

        return
            hashStr(
                string(
                    abi.encodePacked(
                        "{",
                        '"version":"',
                        vote.version,
                        '",',
                        '"timestamp":"',
                        Strings.toString(vote.timestamp),
                        '",',
                        '"space":"',
                        vote.space,
                        '",',
                        '"type":"',
                        vote.voteType,
                        '",',
                        payloadStr(proposal, vote.choice),
                        "}"
                    )
                )
            );
    }

    function payloadStr(string memory proposal, uint256 choice)
        internal
        pure
        returns (string memory)
    {

        return
            string(
                abi.encodePacked(
                    '"payload":',
                    "{",
                    '"proposal":',
                    '"',
                    proposal,
                    '",',
                    '"choice":',
                    Strings.toString(choice),
                    ","
                    '"metadata":',
                    '"{}"',
                    "}"
                )
            );
    }

    function hashStr(string memory str) internal pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n",
                    Strings.toString(bytes(str).length),
                    str
                )
            );
    }
}