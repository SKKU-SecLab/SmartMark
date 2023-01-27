
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity 0.8.6;


interface IERC677 is IERC20, IERC20Metadata {

    function transferAndCall(address recipient, uint amount, bytes memory data) external returns (bool success);

    
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

interface IERC677Receiver {

    function onTokenTransfer(address sender, uint value, bytes memory data) external;

}// MIT

pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;


interface IyVaren {

    event ProposalCreated(
        uint256 id,
        address indexed proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );
    event VoteCast(
        address indexed voter,
        uint256 proposalId,
        bool support,
        uint256 votes
    );
    event ProposalExecuted(uint256 id, bool success);

    function MAX_OPERATIONS() external pure returns (uint256);


    function VAREN() external returns (IERC677);


    struct Proposal {
        address proposer;
        mapping(address => uint256) forVotes;
        mapping(address => uint256) againstVotes;
        uint256 totalForVotes;
        uint256 totalAgainstVotes;
        uint256 quorumVotes;
        uint256 endBlock;
        address[] targets;
        uint256[] values;
        string[] signatures;
        bytes[] calldatas;
        bool executed;
    }

    function blocksForNoWithdrawalFee() external view returns (uint256);


    function earlyWithdrawalFeePercent() external view returns (uint256);


    function earlyWithdrawalFeeExpiry(address) external view returns (uint256);


    function treasury() external view returns (address);


    function treasuryEarlyWithdrawalFeeShare() external view returns (uint256);


    function voteLockAmount(address) external view returns (uint256);


    function voteLockExpiry(address) external view returns (uint256);


    function hasActiveProposal(address) external view returns (bool);


    function proposals(uint256 id)
        external
        view
        returns (
            address proposer,
            uint256 totalForVotes,
            uint256 totalAgainstVotes,
            uint256 quorumVotes,
            uint256 endBlock,
            bool executed
        );


    function proposalCount() external view returns (uint256);


    function votingPeriodBlocks() external view returns (uint256);


    function minVarenForProposal() external view returns (uint256);


    function quorumPercent() external view returns (uint256);


    function voteThresholdPercent() external view returns (uint256);


    function executionPeriodBlocks() external view returns (uint256);


    function stake(uint256 amount) external;


    function withdraw(uint256 shares) external;


    function getPricePerFullShare() external view returns (uint256);


    function getStakeVarenValue(address staker) external view returns (uint256);


    function propose(
        address[] calldata targets,
        uint256[] calldata values,
        string[] calldata signatures,
        bytes[] calldata calldatas,
        string calldata description
    ) external returns (uint256 id);


    function vote(
        uint256 id,
        bool support,
        uint256 voteAmount
    ) external;


    function executeProposal(uint256 id) external payable;


    function getVotes(uint256 proposalId, address voter)
        external
        view
        returns (bool support, uint256 voteAmount);


    function getProposalCalls(uint256 proposalId)
        external
        view
        returns (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas
        );


    function setTreasury(address) external;


    function setTreasuryEarlyWithdrawalFeeShare(uint256) external;


    function setBlocksForNoWithdrawalFee(uint256) external;


    function setEarlyWithdrawalFeePercent(uint256) external;


    function setVotingPeriodBlocks(uint256) external;


    function setMinVarenForProposal(uint256) external;


    function setQuorumPercent(uint256) external;


    function setVoteThresholdPercent(uint256) external;


    function setExecutionPeriodBlocks(uint256) external;

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


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;

library Address {
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
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


library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity 0.8.6;


contract yVaren is IyVaren, IERC677Receiver, ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 public constant override MAX_OPERATIONS = 10;
    IERC677 public immutable override VAREN;

    uint256 public override blocksForNoWithdrawalFee;
    uint256 public override earlyWithdrawalFeePercent = 5000; // 0.5%
    mapping(address => uint256) public override earlyWithdrawalFeeExpiry;
    address public override treasury;
    uint256 public override treasuryEarlyWithdrawalFeeShare = 1000000; // 100%
    mapping(address => uint256) public override voteLockAmount;
    mapping(address => uint256) public override voteLockExpiry;
    mapping(address => bool) public override hasActiveProposal;
    mapping(uint256 => Proposal) public override proposals;
    uint256 public override proposalCount;
    uint256 public override votingPeriodBlocks;
    uint256 public override minVarenForProposal = 1e17; // 0.1 Varen
    uint256 public override quorumPercent = 150000; // 15%
    uint256 public override voteThresholdPercent = 500000; // 50%
    uint256 public override executionPeriodBlocks;

    modifier onlyThis() {
        require(msg.sender == address(this), "yVRN: FORBIDDEN");
        _;
    }

    constructor(
        address _varen,
        address _treasury,
        uint256 _blocksForNoWithdrawalFee,
        uint256 _votingPeriodBlocks,
        uint256 _executionPeriodBlocks
    ) ERC20("Varen Staking Share", "yVRN") {
        require(
            _varen != address(0) && _treasury != address(0),
            "yVRN: ZERO_ADDRESS"
        );
        VAREN = IERC677(_varen);
        treasury = _treasury;
        blocksForNoWithdrawalFee = _blocksForNoWithdrawalFee;
        votingPeriodBlocks = _votingPeriodBlocks;
        executionPeriodBlocks = _executionPeriodBlocks;
    }

    function stake(uint256 amount) external override nonReentrant {
        require(amount > 0, "yVRN: ZERO");
        require(VAREN.transferFrom(msg.sender, address(this), amount), 'yVRN: transferFrom failed');
        _stake(msg.sender, amount);
    }

    function _stake(address sender, uint256 amount) internal virtual {
        uint256 shares = totalSupply() == 0
            ? amount
            : (amount.mul(totalSupply())).div(VAREN.balanceOf(address(this)).sub(amount));
        _mint(sender, shares);
        earlyWithdrawalFeeExpiry[sender] = blocksForNoWithdrawalFee.add(
            block.number
        );
    }

    function onTokenTransfer(address sender, uint value, bytes memory) external override nonReentrant {                
      require(value > 0, "yVRN: ZERO");
      require(msg.sender == address(VAREN), 'yVRN: access denied');
      _stake(sender, value);
    }

    function withdraw(uint256 shares) external override nonReentrant {
        require(shares > 0, "yVRN: ZERO");
        _updateVoteExpiry();
        require(_checkVoteExpiry(msg.sender, shares), "voteLockExpiry");
        uint256 varenAmount = (VAREN.balanceOf(address(this))).mul(shares).div(
            totalSupply()
        );
        _burn(msg.sender, shares);
        if (block.number < earlyWithdrawalFeeExpiry[msg.sender]) {
            uint256 feeAmount = varenAmount.mul(earlyWithdrawalFeePercent) /
                1000000;
            VAREN.transfer(
                treasury,
                feeAmount.mul(treasuryEarlyWithdrawalFeeShare) / 1000000
            );
            varenAmount = varenAmount.sub(feeAmount);
        }
        VAREN.transfer(msg.sender, varenAmount);
    }

    function getPricePerFullShare() external view override returns (uint256) {
        return totalSupply() == 0 ? 0 : VAREN.balanceOf(address(this)).mul(1e18).div(totalSupply());
    }

    function getStakeVarenValue(address staker)
        external
        view
        override
        returns (uint256)
    {
        return
            (VAREN.balanceOf(address(this)).mul(balanceOf(staker))).div(
                totalSupply()
            );
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) public override nonReentrant returns (uint256 id) {
        require(!hasActiveProposal[msg.sender], "yVRN: HAS_ACTIVE_PROPOSAL");
        require(
            targets.length == values.length &&
                targets.length == signatures.length &&
                targets.length == calldatas.length,
            "yVRN: PARITY_MISMATCH"
        );
        require(targets.length != 0, "yVRN: NO_ACTIONS");
        require(targets.length <= MAX_OPERATIONS, "yVRN: TOO_MANY_ACTIONS");
        require(
            (VAREN.balanceOf(address(this)).mul(balanceOf(msg.sender))).div(
                totalSupply()
            ) >= minVarenForProposal,
            "yVRN: INSUFFICIENT_VAREN_FOR_PROPOSAL"
        );
        uint256 endBlock = votingPeriodBlocks.add(block.number);
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.proposer = msg.sender;
        newProposal.endBlock = endBlock;
        newProposal.targets = targets;
        newProposal.values = values;
        newProposal.signatures = signatures;
        newProposal.calldatas = calldatas;
        newProposal.totalForVotes = 0;
        newProposal.totalAgainstVotes = 0;
        newProposal.quorumVotes = VAREN.balanceOf(address(this)).mul(quorumPercent) / 1000000;
        newProposal.executed = false;

        hasActiveProposal[msg.sender] = true;
        proposalCount = proposalCount.add(1);

        emit ProposalCreated(
            id,
            msg.sender,
            targets,
            values,
            signatures,
            calldatas,
            block.number,
            endBlock,
            description
        );
    }

    function _checkVoteExpiry(address _sender, uint256 _shares)
        private
        view
        returns (bool)
    {
        return _shares <= balanceOf(_sender).sub(voteLockAmount[_sender]);
    }

    function _updateVoteExpiry() private {
        if (block.number >= voteLockExpiry[msg.sender]) {
            voteLockExpiry[msg.sender] = 0;
            voteLockAmount[msg.sender] = 0;
        }
    }

    function vote(
        uint256 id,
        bool support,
        uint256 voteAmount
    ) external override nonReentrant {
        Proposal storage proposal = proposals[id];
        require(proposal.proposer != address(0), "yVRN: INVALID_PROPOSAL_ID");
        require(block.number < proposal.endBlock, "yVRN: VOTING_ENDED");
        require(voteAmount > 0, "yVRN: ZERO");
        require(
            voteAmount <= balanceOf(msg.sender),
            "yVRN: INSUFFICIENT_BALANCE"
        );
        _updateVoteExpiry();
        require(
            voteAmount >= voteLockAmount[msg.sender],
            "yVRN: SMALLER_VOTE"
        );
        if (
            (support && voteAmount == proposal.forVotes[msg.sender]) ||
            (!support && voteAmount == proposal.againstVotes[msg.sender])
        ) {
            revert("yVRN: SAME_VOTE");
        }
        if (voteAmount > voteLockAmount[msg.sender]) {
            voteLockAmount[msg.sender] = voteAmount;
        }

        voteLockExpiry[msg.sender] = proposal.endBlock >
            voteLockExpiry[msg.sender]
            ? proposal.endBlock
            : voteLockExpiry[msg.sender];

        if (support) {
            proposal.totalForVotes = proposal.totalForVotes.add(voteAmount).sub(
                proposal.forVotes[msg.sender]
            );
            proposal.forVotes[msg.sender] = voteAmount;
            proposal.totalAgainstVotes = proposal.totalAgainstVotes.sub(
                proposal.againstVotes[msg.sender]
            );
            proposal.againstVotes[msg.sender] = 0;
        } else {
            proposal.totalAgainstVotes = proposal
            .totalAgainstVotes
            .add(voteAmount)
            .sub(proposal.againstVotes[msg.sender]);
            proposal.againstVotes[msg.sender] = voteAmount;
            proposal.totalForVotes = proposal.totalForVotes.sub(
                proposal.forVotes[msg.sender]
            );
            proposal.forVotes[msg.sender] = 0;
        }

        emit VoteCast(msg.sender, id, support, voteAmount);
    }

    function executeProposal(uint256 id)
        external
        payable
        override
        nonReentrant
    {
        Proposal storage proposal = proposals[id];
        require(!proposal.executed, "yVRN: PROPOSAL_ALREADY_EXECUTED");
        {
            require(
                proposal.proposer != address(0),
                "yVRN: INVALID_PROPOSAL_ID"
            );
            require(
                block.number >= proposal.endBlock,
                "yVRN: PROPOSAL_IN_VOTING"
            );
            hasActiveProposal[proposal.proposer] = false;
            uint256 totalVotes = proposal.totalForVotes.add(
                proposal.totalAgainstVotes
            );
            if (
                totalVotes < proposal.quorumVotes ||
                proposal.totalForVotes <
                totalVotes.mul(voteThresholdPercent) / 1000000 ||
                block.number >= proposal.endBlock.add(executionPeriodBlocks) // execution period ended
            ) {
                return;
            }
        }

        bool success = true;
        uint256 remainingValue = msg.value;
        for (uint256 i = 0; i < proposal.targets.length; i++) {
            if (proposal.values[i] > 0) {
                require(
                    remainingValue >= proposal.values[i],
                    "yVRN: INSUFFICIENT_ETH"
                );
                remainingValue = remainingValue - proposal.values[i];
            }
            (success, ) = proposal.targets[i].call{value: proposal.values[i]}(
                abi.encodePacked(
                    bytes4(keccak256(bytes(proposal.signatures[i]))),
                    proposal.calldatas[i]
                )
            );
            if (!success) break;
        }
        proposal.executed = true;

        emit ProposalExecuted(id, success);
    }

    function getVotes(uint256 proposalId, address voter)
        external
        view
        override
        returns (bool support, uint256 voteAmount)
    {
        support = proposals[proposalId].forVotes[voter] > 0;
        voteAmount = support
            ? proposals[proposalId].forVotes[voter]
            : proposals[proposalId].againstVotes[voter];
    }

    function getProposalCalls(uint256 proposalId)
        external
        view
        override
        returns (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas
        )
    {
        targets = proposals[proposalId].targets;
        values = proposals[proposalId].values;
        signatures = proposals[proposalId].signatures;
        calldatas = proposals[proposalId].calldatas;
    }

    function setTreasury(address _treasury) external override onlyThis {
        treasury = _treasury;
    }

    function setTreasuryEarlyWithdrawalFeeShare(
        uint256 _treasuryEarlyWithdrawalFeeShare
    ) external override onlyThis {
        require(_treasuryEarlyWithdrawalFeeShare <= 1000000);
        treasuryEarlyWithdrawalFeeShare = _treasuryEarlyWithdrawalFeeShare;
    }

    function setBlocksForNoWithdrawalFee(uint256 _blocksForNoWithdrawalFee)
        external
        override
        onlyThis
    {
        require(_blocksForNoWithdrawalFee <= 345600);
        blocksForNoWithdrawalFee = _blocksForNoWithdrawalFee;
    }

    function setEarlyWithdrawalFeePercent(uint256 _earlyWithdrawalFeePercent)
        external
        override
        onlyThis
    {
        require(_earlyWithdrawalFeePercent <= 1000000);
        earlyWithdrawalFeePercent = _earlyWithdrawalFeePercent;
    }

    function setVotingPeriodBlocks(uint256 _votingPeriodBlocks)
        external
        override
        onlyThis
    {
        require(_votingPeriodBlocks >= 1920 && _votingPeriodBlocks <= 80640);
        votingPeriodBlocks = _votingPeriodBlocks;
    }

    function setMinVarenForProposal(uint256 _minVarenForProposal)
        external
        override
        onlyThis
    {
        require(
            _minVarenForProposal >= 1e16 && _minVarenForProposal <= 520 * (1e18)
        );
        minVarenForProposal = _minVarenForProposal;
    }

    function setQuorumPercent(uint256 _quorumPercent)
        external
        override
        onlyThis
    {
        require(_quorumPercent >= 100000 && _quorumPercent <= 330000);
        quorumPercent = _quorumPercent;
    }

    function setVoteThresholdPercent(uint256 _voteThresholdPercent)
        external
        override
        onlyThis
    {
        require(
            _voteThresholdPercent >= 500000 && _voteThresholdPercent <= 660000
        );
        voteThresholdPercent = _voteThresholdPercent;
    }

    function setExecutionPeriodBlocks(uint256 _executionPeriodBlocks)
        external
        override
        onlyThis
    {
        require(
            _executionPeriodBlocks >= 1920 && _executionPeriodBlocks <= 172800
        );
        executionPeriodBlocks = _executionPeriodBlocks;
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        nonReentrant
        returns (bool)
    {
        _updateVoteExpiry();
        require(_checkVoteExpiry(msg.sender, amount), "voteLockExpiry");
        super.transfer(recipient, amount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        nonReentrant
        returns (bool)
    {
        super.approve(spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override nonReentrant returns (bool) {
        _updateVoteExpiry();
        require(_checkVoteExpiry(sender, amount), "voteLockExpiry");
        super.transferFrom(sender, recipient, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        override
        nonReentrant
        returns (bool)
    {
        super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        override
        nonReentrant
        returns (bool)
    {
        super.decreaseAllowance(spender, subtractedValue);
    }
    function decimals() public view virtual override returns (uint8) {
        return VAREN.decimals();
    }
}