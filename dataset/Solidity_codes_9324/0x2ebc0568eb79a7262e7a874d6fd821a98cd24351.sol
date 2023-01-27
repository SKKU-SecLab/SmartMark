


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



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
}



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
}



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
}



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
}



pragma solidity ^0.6.0;



contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

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
    
    function constructor1 (string memory name, string memory symbol) internal {
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

}


pragma solidity ^0.6.6;

interface IProposer {
    function proposeToken(
        address tokenAddress,
        string calldata tokenOverview,
        uint256 devTokens,
        address devAddress
    ) external;

    function approveProposal(address tokenAddress) external;

    function voteForProposal(
        address tokenAddress,
        uint256 amount,
        address voter
    ) external;

    function finalizeInvestment(address tokenAddress, uint256 index) external;
}


pragma solidity ^0.6.6;

interface IInvestmentManager {
    function finalizeInvestment(address tokenAddress) external;
    function reclaimETH(address tokenAddress) external;
    function updateETH() payable external;
    function calculateRewards(address voter, uint256 totalStaked) view external;
    function sendRewards(address voter, uint256 totalStaked) external;

}


pragma solidity ^0.6.6;




contract Proxiable {

    function updateCodeAddress(address newAddress) internal {
        require(
            bytes32(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly { // solium-disable-line
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, newAddress)
        }
    }
    function proxiableUUID() public pure returns (bytes32) {
        return 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}

contract NyanV2 {
    struct stakeTracker {
        uint256 stakedNyanV2LP;
        uint256 stakedDNyanV2LP;
        uint256 nyanV2Rewards;
        uint256 lastBlockChecked;
        uint256 blockStaked;
    }
    mapping(address => stakeTracker) public userStake;
}

contract LibraryLockDataLayout {
  bool public initialized = false;
}

contract LibraryLock is LibraryLockDataLayout {

    modifier delegatedOnly() {
        require(initialized == true, "The library is locked. No direct 'call' is allowed");
        _;
    }
    function initialize() internal {
        initialized = true;
    }
}

contract JumpstartDataLayout is LibraryLock {
    address public owner;
    address public nyanV2;
    address public proposer;
    address public investmentManager;

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct votingStruct {
        uint256 totalVotes;
        uint256 currentVotesUsed;
        bool votesInitialized;
        uint256 lastBlockChecked;
        uint256 totalETHStaked;
    }
    mapping (address => votingStruct) public voteTracker;

    mapping(address => bool) public isAdmin;

    address public uniswapRouterV2;
    address public uniswapFactory;

    modifier _onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier updateState() {
        _;
    }
}

contract Jumpstart is Proxiable, JumpstartDataLayout{

    constructor() public {

    }

    function jumpStartConstructor(
        address _nyanV2, 
        address _uniswapRouter, 
        address _uniswapFactory,
        address _proposer,
        address _investmentManager) public {

        require (!initialized);
        owner = msg.sender;
        nyanV2 = _nyanV2;
        proposer = _proposer;
        investmentManager = _investmentManager;
        uniswapRouterV2 = _uniswapRouter;
        uniswapFactory = _uniswapFactory;
        initialize();
    }

    event logicContractUpdated(address newCode);
    function updateCode(address newCode) public _onlyOwner delegatedOnly  {
        updateCodeAddress(newCode);
        
        emit logicContractUpdated(newCode);
    }

    function updateOwner() public _onlyOwner delegatedOnly {
        owner = msg.sender;
        isAdmin[msg.sender] = true;
    }

    function setExtensions(address _proposer, address _iManager) public _onlyOwner delegatedOnly {
        proposer = _proposer;
        investmentManager = _iManager;
    }

    event tokenProposed(address tokenAddress, address dev);

    function proposeToken(
        address tokenAddress,
        string memory tokenOverview,
        uint256 devTokens,
        address devAddress
    ) public updateState {
        IProposer(proposer).proposeToken(
            tokenAddress,
            tokenOverview,
            devTokens,
            devAddress
        );

        emit tokenProposed(tokenAddress, msg.sender);
    }

    function getVoteCount(address staker) public view returns(uint256, uint256) {
        uint256 currentTotalVotes = voteTracker[staker].totalVotes.add(voteTracker[staker].totalETHStaked);
        uint256 newTotalVotes;
        uint256 dNyan;
        uint256 rewards;
        uint256 blockChecked;
        uint256 blockStaked;
        (newTotalVotes,dNyan, rewards, blockChecked, blockStaked) = NyanV2(nyanV2).userStake(staker);

        uint256 votesUsed = voteTracker[staker].currentVotesUsed;
        if (!voteTracker[staker].votesInitialized || block.number.sub(voteTracker[staker].lastBlockChecked) > 6500) {
            return (newTotalVotes.add(voteTracker[staker].totalETHStaked), 0);
        } else {
            return (currentTotalVotes.sub(votesUsed), votesUsed);
        }
    }

    event votesUpdated(address voter, uint256 totalVotesUsed);

    function updateVotesUsed(address voter, uint256 amount) public {
        require(msg.sender == proposer);
        voteTracker[voter].currentVotesUsed = voteTracker[voter].currentVotesUsed.add(amount);
        voteTracker[voter].votesInitialized = true;
        
        if (block.number.sub(voteTracker[voter].lastBlockChecked) > 6500) {
            voteTracker[voter].currentVotesUsed = 0;
        }
        emit votesUpdated(voter, voteTracker[voter].currentVotesUsed);
    }

    event proposalApproved(address tokenAddress, address admin);

    function approveProposal(address tokenAddress) public {
        require(isAdmin[msg.sender]);
        IProposer(proposer).approveProposal(tokenAddress);

        emit proposalApproved(tokenAddress, msg.sender);
    }

    event proposalVote(address voter, address token, uint256 amount);

    function voteForProposal(
        address tokenAddress,
        uint256 amount
    ) public delegatedOnly{
        IProposer(proposer).voteForProposal(
            tokenAddress,
            amount,
            msg.sender
        );

        emit proposalVote(msg.sender, tokenAddress, amount);
    }

    event investmentFinalized(address investment);

    function finalizeInvestment(address tokenAddress, uint256 index) public delegatedOnly {
        IProposer(proposer).finalizeInvestment(tokenAddress, index);

        emit investmentFinalized(tokenAddress);
    }

    function reclaimETH(address tokenAddress) public delegatedOnly {
        IInvestmentManager(investmentManager).reclaimETH(tokenAddress);
    }

    function addETH() public payable delegatedOnly {
        voteTracker[msg.sender].totalETHStaked = voteTracker[msg.sender].totalETHStaked.add(msg.value);
        voteTracker[msg.sender].lastBlockChecked = block.number;
        IInvestmentManager(investmentManager).updateETH{ value: msg.value }();
    }

    function viewRewards() public view returns(uint256) {
        uint256 totalVotes = voteTracker[msg.sender].totalVotes.add(voteTracker[msg.sender].totalETHStaked);
        IInvestmentManager(investmentManager).calculateRewards(msg.sender, totalVotes);
    }

    function claimRewards() public delegatedOnly {
        uint256 totalVotes = voteTracker[msg.sender].totalVotes.add(voteTracker[msg.sender].totalETHStaked);
        IInvestmentManager(investmentManager).sendRewards(msg.sender, totalVotes);
    }
    

    function syncVotes() public delegatedOnly {
        uint256 newTotalVotes;
        uint256 dNyan;
        uint256 rewards;
        uint256 blockChecked;
        uint256 blockStaked;
        (newTotalVotes,dNyan, rewards, blockChecked, blockStaked) = NyanV2(nyanV2).userStake(msg.sender);
        voteTracker[msg.sender].totalVotes = newTotalVotes.add(voteTracker[msg.sender].totalETHStaked);
        voteTracker[msg.sender].votesInitialized = true;
        voteTracker[msg.sender].lastBlockChecked = block.number;
    }
}