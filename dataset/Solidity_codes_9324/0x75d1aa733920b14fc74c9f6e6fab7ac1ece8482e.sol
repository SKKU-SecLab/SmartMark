pragma solidity 0.6.6;

interface IYFLPurchaser {

    function purchaseYfl(address[] calldata tokens) external;

}// MIT

pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;


interface IyYFL {

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
    event VoteCast(address indexed voter, uint256 proposalId, bool support, uint256 votes);
    event ProposalExecuted(uint256 id, bool success);

    function MAX_OPERATIONS() external pure returns (uint256);


    function YFL() external pure returns (IERC20);


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


    function yflPurchaser() external view returns (address);


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


    function minYflForProposal() external view returns (uint256);


    function quorumPercent() external view returns (uint256);


    function voteThresholdPercent() external view returns (uint256);


    function executionPeriodBlocks() external view returns (uint256);


    function stake(uint256 amount) external;


    function convertTokensToYfl(address[] calldata tokens, uint256[] calldata amounts) external;


    function withdraw(uint256 shares) external;


    function getPricePerFullShare() external view returns (uint256);


    function getStakeYflValue(address staker) external view returns (uint256);


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


    function getVotes(uint256 proposalId, address voter) external view returns (bool support, uint256 voteAmount);


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


    function setYflPurchaser(address) external;


    function setBlocksForNoWithdrawalFee(uint256) external;


    function setEarlyWithdrawalFeePercent(uint256) external;


    function setVotingPeriodBlocks(uint256) external;


    function setMinYflForProposal(uint256) external;


    function setQuorumPercent(uint256) external;


    function setVoteThresholdPercent(uint256) external;


    function setExecutionPeriodBlocks(uint256) external;

}// MIT

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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
}// MIT

pragma solidity ^0.6.2;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.6.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity ^0.6.0;


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
}// MIT

pragma solidity ^0.6.0;

contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}pragma solidity 0.6.6;


contract yYFL is IyYFL, ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 public constant override MAX_OPERATIONS = 10;
    IERC20 public immutable override YFL;

    uint256 public override blocksForNoWithdrawalFee;
    uint256 public override earlyWithdrawalFeePercent = 10000; // 1%
    mapping(address => uint256) public override earlyWithdrawalFeeExpiry;
    address public override treasury;
    uint256 public override treasuryEarlyWithdrawalFeeShare = 800000; // 80%
    address public override yflPurchaser;
    mapping(address => uint256) public override voteLockAmount;
    mapping(address => uint256) public override voteLockExpiry;
    mapping(address => bool) public override hasActiveProposal;
    mapping(uint256 => Proposal) public override proposals;
    uint256 public override proposalCount;
    uint256 public override votingPeriodBlocks;
    uint256 public override minYflForProposal = 1e17; // 0.1 YFL
    uint256 public override quorumPercent = 200000; // 20%
    uint256 public override voteThresholdPercent = 500000; // 50%
    uint256 public override executionPeriodBlocks;

    modifier onlyThis() {
        require(msg.sender == address(this), "yYFL: FORBIDDEN");
        _;
    }

    constructor(
        address _yfl,
        address _treasury,
        uint256 _blocksForNoWithdrawalFee,
        uint256 _votingPeriodBlocks,
        uint256 _executionPeriodBlocks
    ) public ERC20("YFLink Staking Share", "yYFL") {
        require(_yfl != address(0) && _treasury != address(0), "yYFL: ZERO_ADDRESS");
        _setupDecimals(ERC20(_yfl).decimals());
        YFL = IERC20(_yfl);
        treasury = _treasury;
        blocksForNoWithdrawalFee = _blocksForNoWithdrawalFee;
        votingPeriodBlocks = _votingPeriodBlocks;
        executionPeriodBlocks = _executionPeriodBlocks;
    }

    function stake(uint256 amount) external override nonReentrant {
        require(amount > 0, "yYFL: ZERO");
        uint256 shares = totalSupply() == 0 ? amount : (amount.mul(totalSupply())).div(YFL.balanceOf(address(this)));
        YFL.safeTransferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, shares);
        earlyWithdrawalFeeExpiry[msg.sender] = blocksForNoWithdrawalFee.add(block.number);
    }

    function convertTokensToYfl(address[] calldata tokens, uint256[] calldata amounts) external override nonReentrant {
        require(yflPurchaser != address(0), "yYFL: INVALID_YFL_PURCHASER");
        require(tokens.length == amounts.length, "yYFL: ARITY_MISMATCH");
        for (uint256 i = 0; i < tokens.length; i++) {
            require(tokens[i] != address(YFL), "yYFL: ALREADY_CONVERTED");
            IERC20 token = IERC20(tokens[i]);
            token.safeTransfer(yflPurchaser, amounts[i]);
        }
        uint256 yflBalanceBefore = YFL.balanceOf(address(this));
        IYFLPurchaser(yflPurchaser).purchaseYfl(tokens);
        require(YFL.balanceOf(address(this)) > yflBalanceBefore, "yYFL: NO_YFL_PURCHASED");
    }

    function withdraw(uint256 shares) external override nonReentrant {
        require(shares > 0, "yYFL: ZERO");
        _checkVoteExpiry();
        require(shares <= balanceOf(msg.sender).sub(voteLockAmount[msg.sender]), "yYFL: INSUFFICIENT_BALANCE");
        uint256 yflAmount = (YFL.balanceOf(address(this))).mul(shares).div(totalSupply());
        _burn(msg.sender, shares);
        if (block.number < earlyWithdrawalFeeExpiry[msg.sender]) {
            uint256 feeAmount = yflAmount.mul(earlyWithdrawalFeePercent) / 1000000;
            YFL.safeTransfer(treasury, feeAmount.mul(treasuryEarlyWithdrawalFeeShare) / 1000000);
            yflAmount = yflAmount.sub(feeAmount);
        }
        YFL.safeTransfer(msg.sender, yflAmount);
    }

    function getPricePerFullShare() external view override returns (uint256) {
        return YFL.balanceOf(address(this)).mul(1e18).div(totalSupply());
    }

    function getStakeYflValue(address staker) external view override returns (uint256) {
        return (YFL.balanceOf(address(this)).mul(balanceOf(staker))).div(totalSupply());
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) public override nonReentrant returns (uint256 id) {
        require(!hasActiveProposal[msg.sender], "yYFL: HAS_ACTIVE_PROPOSAL");
        require(
            targets.length == values.length &&
                targets.length == signatures.length &&
                targets.length == calldatas.length,
            "yYFL: ARITY_MISMATCH"
        );
        require(targets.length != 0, "yYFL: NO_ACTIONS");
        require(targets.length <= MAX_OPERATIONS, "yYFL: TOO_MANY_ACTIONS");
        require(
            (YFL.balanceOf(address(this)).mul(balanceOf(msg.sender))).div(totalSupply()) >= minYflForProposal,
            "yYFL: INSUFFICIENT_YFL_FOR_PROPOSAL"
        );
        uint256 endBlock = votingPeriodBlocks.add(block.number);
        id = proposalCount;
        proposals[id] = Proposal({
            proposer: msg.sender,
            endBlock: endBlock,
            targets: targets,
            values: values,
            signatures: signatures,
            calldatas: calldatas,
            totalForVotes: 0,
            totalAgainstVotes: 0,
            quorumVotes: YFL.balanceOf(address(this)).mul(quorumPercent) / 1000000,
            executed: false
        });
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

    function _checkVoteExpiry() private {
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
        require(proposal.proposer != address(0), "yYFL: INVALID_PROPOSAL_ID");
        require(block.number < proposal.endBlock, "yYFL: VOTING_ENDED");
        require(voteAmount > 0, "yYFL: ZERO");
        require(voteAmount <= balanceOf(msg.sender), "yYFL: INSUFFICIENT_BALANCE");
        _checkVoteExpiry();
        require(voteAmount >= voteLockAmount[msg.sender], "yYFL: SMALLER_VOTE");
        if (
            (support && voteAmount == proposal.forVotes[msg.sender]) ||
            (!support && voteAmount == proposal.againstVotes[msg.sender])
        ) {
            revert("yYFL: SAME_VOTE");
        }
        if (voteAmount > voteLockAmount[msg.sender]) {
            voteLockAmount[msg.sender] = voteAmount;
        }

        voteLockExpiry[msg.sender] = proposal.endBlock > voteLockExpiry[msg.sender]
            ? proposal.endBlock
            : voteLockExpiry[msg.sender];

        if (support) {
            proposal.totalForVotes = proposal.totalForVotes.add(voteAmount).sub(proposal.forVotes[msg.sender]);
            proposal.forVotes[msg.sender] = voteAmount;
            proposal.totalAgainstVotes = proposal.totalAgainstVotes.sub(proposal.againstVotes[msg.sender]);
            proposal.againstVotes[msg.sender] = 0;
        } else {
            proposal.totalAgainstVotes = proposal.totalAgainstVotes.add(voteAmount).sub(
                proposal.againstVotes[msg.sender]
            );
            proposal.againstVotes[msg.sender] = voteAmount;
            proposal.totalForVotes = proposal.totalForVotes.sub(proposal.forVotes[msg.sender]);
            proposal.forVotes[msg.sender] = 0;
        }

        emit VoteCast(msg.sender, id, support, voteAmount);
    }

    function executeProposal(uint256 id) external payable override nonReentrant {
        Proposal storage proposal = proposals[id];
        require(!proposal.executed, "yYFL: PROPOSAL_ALREADY_EXECUTED");
        {
            require(proposal.proposer != address(0), "yYFL: INVALID_PROPOSAL_ID");
            require(block.number >= proposal.endBlock, "yYFL: PROPOSAL_IN_VOTING");
            hasActiveProposal[proposal.proposer] = false;
            uint256 totalVotes = proposal.totalForVotes.add(proposal.totalAgainstVotes);
            if (
                totalVotes < proposal.quorumVotes ||
                proposal.totalForVotes < totalVotes.mul(voteThresholdPercent) / 1000000 ||
                block.number >= proposal.endBlock.add(executionPeriodBlocks) // execution period ended
            ) {
                return;
            }
        }

        bool success = true;
        uint256 remainingValue = msg.value;
        for (uint256 i = 0; i < proposal.targets.length; i++) {
            if (proposal.values[i] > 0) {
                require(remainingValue >= proposal.values[i], "yYFL: INSUFFICIENT_ETH");
                remainingValue = remainingValue - proposal.values[i];
            }
            (success, ) = proposal.targets[i].call{value: proposal.values[i]}(
                abi.encodePacked(bytes4(keccak256(bytes(proposal.signatures[i]))), proposal.calldatas[i])
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
        voteAmount = support ? proposals[proposalId].forVotes[voter] : proposals[proposalId].againstVotes[voter];
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

    function setTreasuryEarlyWithdrawalFeeShare(uint256 _treasuryEarlyWithdrawalFeeShare) external override onlyThis {
        require(_treasuryEarlyWithdrawalFeeShare <= 1000000);
        treasuryEarlyWithdrawalFeeShare = _treasuryEarlyWithdrawalFeeShare;
    }

    function setYflPurchaser(address _yflPurchaser) external override onlyThis {
        require(_yflPurchaser != address(0));
        yflPurchaser = _yflPurchaser;
    }

    function setBlocksForNoWithdrawalFee(uint256 _blocksForNoWithdrawalFee) external override onlyThis {
        require(_blocksForNoWithdrawalFee <= 345600);
        blocksForNoWithdrawalFee = _blocksForNoWithdrawalFee;
    }

    function setEarlyWithdrawalFeePercent(uint256 _earlyWithdrawalFeePercent) external override onlyThis {
        require(_earlyWithdrawalFeePercent <= 1000000);
        earlyWithdrawalFeePercent = _earlyWithdrawalFeePercent;
    }

    function setVotingPeriodBlocks(uint256 _votingPeriodBlocks) external override onlyThis {
        require(_votingPeriodBlocks >= 1920 && _votingPeriodBlocks <= 80640);
        votingPeriodBlocks = _votingPeriodBlocks;
    }

    function setMinYflForProposal(uint256 _minYflForProposal) external override onlyThis {
        require(_minYflForProposal >= 1e16 && _minYflForProposal <= 520 * (1e18));
        minYflForProposal = _minYflForProposal;
    }

    function setQuorumPercent(uint256 _quorumPercent) external override onlyThis {
        require(_quorumPercent >= 100000 && _quorumPercent <= 330000);
        quorumPercent = _quorumPercent;
    }

    function setVoteThresholdPercent(uint256 _voteThresholdPercent) external override onlyThis {
        require(_voteThresholdPercent >= 500000 && _voteThresholdPercent <= 660000);
        voteThresholdPercent = _voteThresholdPercent;
    }

    function setExecutionPeriodBlocks(uint256 _executionPeriodBlocks) external override onlyThis {
        require(_executionPeriodBlocks >= 1920 && _executionPeriodBlocks <= 172800);
        executionPeriodBlocks = _executionPeriodBlocks;
    }

    function transfer(address recipient, uint256 amount) public override nonReentrant returns (bool) {
        super.transfer(recipient, amount);
    }

    function approve(address spender, uint256 amount) public override nonReentrant returns (bool) {
        super.approve(spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override nonReentrant returns (bool) {
        super.transferFrom(sender, recipient, amount);
    }

    function increaseAllowance(address spender, uint256 addedValue) public override nonReentrant returns (bool) {
        super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override nonReentrant returns (bool) {
        super.decreaseAllowance(spender, subtractedValue);
    }
}