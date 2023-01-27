
pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}pragma solidity ^0.7.3;
pragma experimental ABIEncoderV2;


contract Governance {


    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Rejected,
        Executable,
        Executed,
        Expired
    }

    struct Proposal {
        uint256 id;
        address proposer;
        address[] contracts;
        uint256[] values;
        string[] signatures;
        bytes[] calldatas;
        uint256 startBlock;
        uint256 endBlock;
        uint256 expirationBlock;
        uint256 forVotes;
        uint256 againstVotes;
        bool canceled;
        bool executed;
        bool expedited;
        mapping(address => Receipt) receipts;
    }

    struct Receipt {
        bool hasVoted;
        bool support;
        uint256 votes;
    }

    event ProposalCreated(
        uint256 indexed id,
        address proposer,
        address[] contracts,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        string description,
        bool expedited
    );
    event ProposalCanceled(uint256 id);
    event ProposalExecuted(uint256 id);
    event VoteCast(
        address voter,
        uint256 proposalId,
        bool support,
        uint256 votes,
        bool isUpdate
    );
    event ExecuteTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        string signature,
        bytes data
    );


    address public token;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _lockedUntil;

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;

    mapping(bytes32 => bool) public signatureWhitelist;

    bool private initialized;


    function initialize(
        address _token
    ) public {

        require(!initialized, '!initialized');
        initialized = true;
        token = _token;
    }


    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function lockedUntil(address account) external view returns (uint256) {

        if (block.number < _lockedUntil[account]) {
            return _lockedUntil[account];
        }
        return 0;
    }

    function proposerMinStaked() public pure returns (uint256) {

        return 10e18; // 0.01% of CAP
    }

    function proposalMaxOperations() public pure returns (uint256) {

        return 10;
    }

    function forVotesThreshold() public view virtual returns (uint256) {

        return IERC20(token).totalSupply().mul(4).div(100);
    }

    function forVotesExpeditedThreshold() public view virtual returns (uint256) {

        return IERC20(token).totalSupply().mul(15).div(100);
    }

    function votingPeriod() public pure virtual returns (uint256) {

        return 40320; // around 1 week
    }

    function executablePeriod() public pure virtual returns (uint256) {

        return 40320; // around 1 week
    }

    function proposalState(uint256 proposalId) public view returns (ProposalState) {

        require(proposalCount >= proposalId && proposalId > 0, '!id');
        Proposal storage proposal = proposals[proposalId];

        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else if (block.number < proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            if (proposal.expedited && proposal.forVotes > proposal.againstVotes && proposal.forVotes > forVotesExpeditedThreshold()) {
                return ProposalState.Executable;
            }
            return ProposalState.Active;
        } else if (proposal.forVotes <= proposal.againstVotes || proposal.forVotes < forVotesThreshold()) {
            return ProposalState.Rejected;
        } else if (block.number < proposal.expirationBlock) {
            return ProposalState.Executable;
        } else {
            return ProposalState.Expired;
        }
    }

    function proposalData(uint256 proposalId) external view returns (address[] memory contracts, uint256[] memory values, string[] memory signatures, bytes[] memory calldatas) {

        Proposal storage proposal = proposals[proposalId];
        return (proposal.contracts, proposal.values, proposal.signatures, proposal.calldatas);
    }


    function stakeToVote(uint256 amount) public {

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        _stake(msg.sender, amount);
    }

    function releaseStaked(uint256 amount) external {

        _unstake(msg.sender, amount);
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function submitProposal(
        uint256 discoverabilityPeriod,
        address[] memory contracts,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description,
        bool expedited
    ) external returns (uint256 id) {


        require(contracts.length != 0, '!empty');
        require(contracts.length <= proposalMaxOperations() && (!expedited || contracts.length < 4), '!max_operations');
        require(contracts.length == values.length && contracts.length == signatures.length && contracts.length == calldatas.length, '!mismatch');
        require(discoverabilityPeriod > 0, '!discoverability');

        address proposer = msg.sender;
        if (balanceOf(proposer) < proposerMinStaked()) {
            stakeToVote(proposerMinStaked().sub(balanceOf(proposer)));
        }

        uint256 startBlock = block.number.add(discoverabilityPeriod);
        uint256 endBlock = startBlock.add(votingPeriod());

        _lockUntil(proposer, endBlock);

        if (expedited) {
            _validateExpedition(signatures);
        }

        uint256 newProposalId = ++proposalCount;
        Proposal storage newProposal = proposals[newProposalId];
        newProposal.id = newProposalId;
        newProposal.proposer = proposer;
        newProposal.contracts = contracts;
        newProposal.values = values;
        newProposal.signatures = signatures;
        newProposal.calldatas = calldatas;
        newProposal.startBlock = startBlock;
        newProposal.endBlock = endBlock;
        newProposal.expirationBlock = endBlock.add(executablePeriod());
        if (expedited) newProposal.expedited = expedited;

        emit ProposalCreated(
            newProposalId,
            msg.sender,
            contracts,
            values,
            signatures,
            calldatas,
            description,
            expedited
        );

        return newProposalId;

    }

    function cancelProposal(uint256 proposalId) external {

        require(proposalState(proposalId) == ProposalState.Pending, '!state');
        Proposal storage proposal = proposals[proposalId];
        require(msg.sender == proposal.proposer, '!authorized');
        proposal.canceled = true;
        emit ProposalCanceled(proposalId);
    }

    function castVote(uint256 proposalId, bool support) external {

        require(proposalState(proposalId) == ProposalState.Active, '!voting_closed');

        address voter = msg.sender;

        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];

        uint256 votes = balanceOf(voter);

        bool isUpdate;
        if (receipt.hasVoted) {
            isUpdate = true;
            if (receipt.support) {
                proposal.forVotes = proposal.forVotes.sub(receipt.votes);
            } else {
                proposal.againstVotes = proposal.againstVotes.sub(receipt.votes);
            }
        }

        if (support) {
            proposal.forVotes = proposal.forVotes.add(votes);
        } else {
            proposal.againstVotes = proposal.againstVotes.add(votes);
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;

        _lockUntil(voter, proposal.endBlock);

        emit VoteCast(
            voter,
            proposalId,
            support,
            votes,
            isUpdate
        );

    }

    function executeProposal(uint256 proposalId) external payable {

        require(proposalState(proposalId) == ProposalState.Executable, '!not_executable');
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;
        uint256 length = proposal.contracts.length;
        for (uint256 i = 0; i < length; i++) {
            _executeTransaction(
                proposal.contracts[i],
                proposal.values[i],
                proposal.signatures[i],
                proposal.calldatas[i]
            );
        }
        emit ProposalExecuted(proposalId);
    }

    function addSignaturesToWhitelist(string[] calldata signaturesToAdd) external onlyGovernance {

        for (uint256 i=0 ; i < signaturesToAdd.length; ++i) {
            bytes32 signature = keccak256(bytes(signaturesToAdd[i]));
            signatureWhitelist[signature] = true;
        }
    }

    function removeSignaturesFromWhitelist(string[] calldata signaturesToRemove) external onlyGovernance {

        for (uint256 i=0 ; i < signaturesToRemove.length; ++i) {
            bytes32 signature = keccak256(bytes(signaturesToRemove[i]));
            delete signatureWhitelist[signature];
        }
    }


    function _stake(address account, uint256 amount) internal {

        require(account != address(this), '!allowed');
        _balances[account] = _balances[account].add(amount);
    }

    function _unstake(address account, uint256 amount) internal {

        require(block.number >= _lockedUntil[account], '!locked_till_expiry');
        _balances[account] = _balances[account].sub(amount, '!insufficient_funds');
    }

    function _lockUntil(address account, uint256 blockNumber) internal {

        if (_lockedUntil[account] <= blockNumber) {
            _lockedUntil[account] = blockNumber.add(1);
        }
    }

    function _executeTransaction(
        address contractAddress,
        uint256 value,
        string memory signature,
        bytes memory data
    ) internal {

        require(contractAddress != token, '!allowed');

        bytes32 txHash = keccak256(abi.encode(contractAddress, value, signature, data));

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success,) = contractAddress.call{value: value}(callData);
        require(success, '!failed');

        emit ExecuteTransaction(
            txHash,
            contractAddress,
            value,
            signature,
            data
        );
    }

    function _validateExpedition(
        string[] memory signatures
    ) internal view {

        uint256 i;
        for (; i < signatures.length; i++) {
            if (!signatureWhitelist[keccak256(bytes(signatures[i]))]) break;
        }

        require(i == signatures.length, '!error');
    }


    modifier onlyGovernance() {

        require(msg.sender == address(this), '!authorized');
        _;
    }

}