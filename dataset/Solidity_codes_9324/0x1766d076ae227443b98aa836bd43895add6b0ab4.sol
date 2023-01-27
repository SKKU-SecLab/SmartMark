
pragma solidity 0.6.11;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}

interface Token {

    function approve(address, uint) external returns (bool);

    function balanceOf(address) external view returns (uint);

    function transferFrom(address, address, uint) external returns (bool);

    function transfer(address, uint) external returns (bool);

}

interface LegacyToken {

    function transfer(address, uint) external;

}

interface StakingPool {

    function disburseRewardTokens() external;

    function burnRewardTokens() external;

    function transferOwnership(address) external;

    function transferAnyERC20Token(address, address, uint) external;

    function transferAnyOldERC20Token(address, address, uint) external;

}

contract Ownable {

    address private _owner;
    address public pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }
    
    modifier onlyPendingOwner() {

        assert(msg.sender != address(0));
        require(msg.sender == pendingOwner);
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        require(_newOwner != address(0));
        pendingOwner = _newOwner;
    }
  
    function claimOwnership() onlyPendingOwner public {

        _transferOwnership(pendingOwner);
        pendingOwner = address(0);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract Governance is Ownable {

    using SafeMath for uint;
    using Address for address;
    modifier noContractsAllowed() {

        require(!(address(msg.sender).isContract()) && tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }
    
    
    address public constant TRUSTED_TOKEN_ADDRESS = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17;
    
    uint public QUORUM = 25000e18;
    
    uint public constant ADMIN_FEATURES_EXPIRE_AFTER = 180 days;
    
    uint public constant ADMIN_CAN_CLAIM_AFTER = 395 days;
    
    uint public MIN_BALANCE_TO_INIT_PROPOSAL = 5000e18;
    
    uint public constant VOTE_DURATION = 3 days;
    
    uint public constant RESULT_EXECUTION_ALLOWANCE_PERIOD = 3 days;
    
    
    uint public immutable contractStartTime;
    
    event PoolCallSucceeded(StakingPool);
    event PoolCallReverted(StakingPool, string);
    event PoolCallReverted(StakingPool, bytes);
    
    enum PoolGroupName {
        WETH,
        WBTC,
        USDT,
        USDC
    }
    
    enum Action {
        DISBURSE_OR_BURN,
        UPGRADE_GOVERNANCE,
        CHANGE_QUORUM,
        TEXT_PROPOSAL,
        CHANGE_MIN_BALANCE_TO_INIT_PROPOSAL
    }
    
    enum Option {
        ONE, // disburse | yes
        TWO // burn | no
    }
    
    mapping (PoolGroupName => StakingPool[4]) public hardcodedStakingPools;
    
    constructor() public {
        contractStartTime = now;
        
        hardcodedStakingPools[PoolGroupName.WETH][0] = StakingPool(0xa7d6F5fa9b0be0e98b3b40E6aC884e53F2F9460e);
        hardcodedStakingPools[PoolGroupName.WETH][1] = StakingPool(0x0b0A544AE6131801522E3aC1FBAc6D311094c94c);
        hardcodedStakingPools[PoolGroupName.WETH][2] = StakingPool(0x16cAaD63BDFC3Ec4A2850336B28efE17e802b896);
        hardcodedStakingPools[PoolGroupName.WETH][3] = StakingPool(0x512FF8739d39e55d75d80046921E7dE20c3e9BFf);
        
        hardcodedStakingPools[PoolGroupName.WBTC][0] = StakingPool(0xeF71DE5Cb40f7985FEb92AA49D8e3E84063Af3BB);
        hardcodedStakingPools[PoolGroupName.WBTC][1] = StakingPool(0x8B0e324EEdE360CaB670a6AD12940736d74f701e);
        hardcodedStakingPools[PoolGroupName.WBTC][2] = StakingPool(0x78e2dA2eda6dF49BaE46E3B51528BAF5c106e654);
        hardcodedStakingPools[PoolGroupName.WBTC][3] = StakingPool(0x350F3fE979bfad4766298713c83b387C2D2D7a7a);
        
        hardcodedStakingPools[PoolGroupName.USDT][0] = StakingPool(0x4a76Fc15D3fbf3855127eC5DA8AAf02DE7ca06b3);
        hardcodedStakingPools[PoolGroupName.USDT][1] = StakingPool(0xF4abc60a08B546fA879508F4261eb4400B55099D);
        hardcodedStakingPools[PoolGroupName.USDT][2] = StakingPool(0x13F421Aa823f7D90730812a33F8Cac8656E47dfa);
        hardcodedStakingPools[PoolGroupName.USDT][3] = StakingPool(0x86690BbE7a9683A8bAd4812C2e816fd17bC9715C);
        
        hardcodedStakingPools[PoolGroupName.USDC][0] = StakingPool(0x2b5D7a865A3888836d15d69dCCBad682663DCDbb);
        hardcodedStakingPools[PoolGroupName.USDC][1] = StakingPool(0xa52250f98293c17C894d58cf4f78c925dC8955d0);
        hardcodedStakingPools[PoolGroupName.USDC][2] = StakingPool(0x924BECC8F4059987E4bc4B741B7C354FF52c25e4);
        hardcodedStakingPools[PoolGroupName.USDC][3] = StakingPool(0xbE528593781988974D83C2655CBA4c45FC75c033);
    }
    
    
    
    mapping (uint => Action) public actions;
    
    mapping (uint => uint) public optionOneVotes;
    
    mapping (uint => uint) public optionTwoVotes;
    
    mapping (uint => StakingPool[]) public stakingPools;
    
    mapping (uint => address) public newGovernances;
    
    mapping (uint => uint) public proposalStartTime;
    
    mapping (uint => bool) public isProposalExecuted;
    
    mapping (uint => uint) public newQuorums;
    mapping (uint => uint) public newMinBalances;
    mapping (uint => string) public proposalTexts;
    
    mapping (address => uint) public totalDepositedTokens;
    
    mapping (address => mapping (uint => uint)) public votesForProposalByAddress;
    
    mapping (address => mapping (uint => Option)) public votedForOption;
    
    mapping (address => uint) public lastVotedProposalStartTime;
    
    uint public lastIndex = 0;
    
    function getProposal(uint proposalId) external view returns (
        uint _proposalId, 
        Action _proposalAction,
        uint _optionOneVotes,
        uint _optionTwoVotes,
        StakingPool[] memory _stakingPool,
        address _newGovernance,
        uint _proposalStartTime,
        bool _isProposalExecuted,
        uint _newQuorum,
        string memory _proposalText,
        uint _newMinBalance
        ) {

        _proposalId = proposalId;
        _proposalAction = actions[proposalId];
        _optionOneVotes = optionOneVotes[proposalId];
        _optionTwoVotes = optionTwoVotes[proposalId];
        _stakingPool = stakingPools[proposalId];
        _newGovernance = newGovernances[proposalId];
        _proposalStartTime = proposalStartTime[proposalId];
        _isProposalExecuted = isProposalExecuted[proposalId];
        _newQuorum = newQuorums[proposalId];
        _proposalText = proposalTexts[proposalId];
        _newMinBalance = newMinBalances[proposalId];
    }
    
    function changeQuorum(uint newQuorum) external onlyOwner {

        require(now < contractStartTime.add(ADMIN_FEATURES_EXPIRE_AFTER), "Change quorum feature expired!");
        QUORUM = newQuorum;
    }
    
    function changeMinBalanceToInitProposal(uint newMinBalanceToInitProposal) external onlyOwner {

        require(now < contractStartTime.add(ADMIN_FEATURES_EXPIRE_AFTER), "This admin feature has expired!");
        MIN_BALANCE_TO_INIT_PROPOSAL = newMinBalanceToInitProposal;
    }
    
    function proposeText(string memory text) external noContractsAllowed {

        require(Token(TRUSTED_TOKEN_ADDRESS).balanceOf(msg.sender) >= MIN_BALANCE_TO_INIT_PROPOSAL, "Insufficient Governance Token Balance");
        lastIndex = lastIndex.add(1);
        proposalStartTime[lastIndex] = now;
        actions[lastIndex] = Action.TEXT_PROPOSAL;
        proposalTexts[lastIndex] = text;
    }
    
    function proposeDisburseOrBurn(PoolGroupName poolGroupName) external noContractsAllowed {

        require(poolGroupName == PoolGroupName.WETH ||
                poolGroupName == PoolGroupName.WBTC ||
                poolGroupName == PoolGroupName.USDT ||
                poolGroupName == PoolGroupName.USDC, "Invalid Pool Group Name!");
        require(Token(TRUSTED_TOKEN_ADDRESS).balanceOf(msg.sender) >= MIN_BALANCE_TO_INIT_PROPOSAL, "Insufficient Governance Token Balance");
        lastIndex = lastIndex.add(1);
        
        stakingPools[lastIndex] = hardcodedStakingPools[poolGroupName];
        
        proposalStartTime[lastIndex] = now;
        actions[lastIndex] = Action.DISBURSE_OR_BURN;
    }
    
    function proposeUpgradeGovernance(PoolGroupName poolGroupName, address newGovernance) external noContractsAllowed onlyOwner {

        require(poolGroupName == PoolGroupName.WETH ||
                poolGroupName == PoolGroupName.WBTC ||
                poolGroupName == PoolGroupName.USDT ||
                poolGroupName == PoolGroupName.USDC, "Invalid Pool Group Name!");
                
        require(Token(TRUSTED_TOKEN_ADDRESS).balanceOf(msg.sender) >= MIN_BALANCE_TO_INIT_PROPOSAL, "Insufficient Governance Token Balance");
        lastIndex = lastIndex.add(1);
        
        stakingPools[lastIndex] = hardcodedStakingPools[poolGroupName];
        
        newGovernances[lastIndex] = newGovernance;
        proposalStartTime[lastIndex] = now;
        actions[lastIndex] = Action.UPGRADE_GOVERNANCE;
    }
    
    function proposeNewQuorum(uint newQuorum) external noContractsAllowed onlyOwner {

        require(Token(TRUSTED_TOKEN_ADDRESS).balanceOf(msg.sender) >= MIN_BALANCE_TO_INIT_PROPOSAL, "Insufficient Governance Token Balance");
        lastIndex = lastIndex.add(1);
        newQuorums[lastIndex] = newQuorum;
        proposalStartTime[lastIndex] = now;
        actions[lastIndex] = Action.CHANGE_QUORUM;
    }
    
    function proposeNewMinBalanceToInitProposal(uint newMinBalance) external noContractsAllowed onlyOwner {

        require(Token(TRUSTED_TOKEN_ADDRESS).balanceOf(msg.sender) >= MIN_BALANCE_TO_INIT_PROPOSAL, "Insufficient Governance Token Balance");
        lastIndex = lastIndex.add(1);
        newMinBalances[lastIndex] = newMinBalance;
        proposalStartTime[lastIndex] = now;
        actions[lastIndex] = Action.CHANGE_MIN_BALANCE_TO_INIT_PROPOSAL;
    }
    
    
    function addVotes(uint proposalId, Option option, uint amount) external noContractsAllowed {

        require(amount > 0, "Cannot add 0 votes!");
        require(isProposalOpen(proposalId), "Proposal is closed!");
        
        require(Token(TRUSTED_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), amount), "transferFrom failed!");
        
        if (votesForProposalByAddress[msg.sender][proposalId] == 0) {
            votedForOption[msg.sender][proposalId] = option;
        } else {
            if (votedForOption[msg.sender][proposalId] != option) {
                revert("Cannot vote for both options!");
            }
        }
        
        if (option == Option.ONE) {
            optionOneVotes[proposalId] = optionOneVotes[proposalId].add(amount);
        } else {
            optionTwoVotes[proposalId] = optionTwoVotes[proposalId].add(amount);
        }
        totalDepositedTokens[msg.sender] = totalDepositedTokens[msg.sender].add(amount);
        votesForProposalByAddress[msg.sender][proposalId] = votesForProposalByAddress[msg.sender][proposalId].add(amount);
        
        if (lastVotedProposalStartTime[msg.sender] < proposalStartTime[proposalId]) {
            lastVotedProposalStartTime[msg.sender] = proposalStartTime[proposalId];
        }
    }
    
    function removeVotes(uint proposalId, uint amount) external noContractsAllowed {

        require(amount > 0, "Cannot remove 0 votes!");
        require(isProposalOpen(proposalId), "Proposal is closed!");
        
        require(amount <= votesForProposalByAddress[msg.sender][proposalId], "Cannot remove more tokens than deposited!");
        
        votesForProposalByAddress[msg.sender][proposalId] = votesForProposalByAddress[msg.sender][proposalId].sub(amount);
        totalDepositedTokens[msg.sender] = totalDepositedTokens[msg.sender].sub(amount);
        
        if (votedForOption[msg.sender][proposalId] == Option.ONE) {
            optionOneVotes[proposalId] = optionOneVotes[proposalId].sub(amount);
        } else {
            optionTwoVotes[proposalId] = optionTwoVotes[proposalId].sub(amount);
        }
        
        require(Token(TRUSTED_TOKEN_ADDRESS).transfer(msg.sender, amount), "transfer failed");
    }

    function withdrawAllTokens() external noContractsAllowed {

        require(now > lastVotedProposalStartTime[msg.sender].add(VOTE_DURATION), "Tokens are still in voting!");
        require(Token(TRUSTED_TOKEN_ADDRESS).transfer(msg.sender, totalDepositedTokens[msg.sender]), "transfer failed!");
        totalDepositedTokens[msg.sender] = 0;
    }
    
    function executeProposal(uint proposalId) external noContractsAllowed {

        require (actions[proposalId] != Action.TEXT_PROPOSAL, "Cannot programmatically execute text proposals");
        require (optionOneVotes[proposalId] != optionTwoVotes[proposalId], "This is a TIE! Cannot execute!");
        require (isProposalExecutible(proposalId), "Proposal Expired!");
        
        isProposalExecuted[proposalId] = true;
    
        Option winningOption;
        uint winningOptionVotes;
        
        if (optionOneVotes[proposalId] > optionTwoVotes[proposalId]) {
            winningOption = Option.ONE;
            winningOptionVotes = optionOneVotes[proposalId];
        } else {
            winningOption = Option.TWO;
            winningOptionVotes = optionTwoVotes[proposalId];
        }
        
        if (winningOptionVotes < QUORUM) {
            revert("QUORUM not reached!");
        }
        
        if (actions[proposalId] == Action.DISBURSE_OR_BURN) {
            if (winningOption == Option.ONE) {
                for (uint8 i = 0; i < 4; i++) {
                    StakingPool pool = stakingPools[proposalId][i];
                    try pool.disburseRewardTokens() {
                        emit PoolCallSucceeded(pool);
                    } catch Error(string memory reason) {
                        emit PoolCallReverted(pool, reason);
                    } catch (bytes memory lowLevelData) {
                        emit PoolCallReverted(pool, lowLevelData);
                    }
                }
            } else {
                for (uint8 i = 0; i < 4; i++) {
                    StakingPool pool = stakingPools[proposalId][i];
                    try pool.burnRewardTokens() {
                        emit PoolCallSucceeded(pool);
                    } catch Error(string memory reason) {
                        emit PoolCallReverted(pool, reason);
                    } catch (bytes memory lowLevelData) {
                        emit PoolCallReverted(pool, lowLevelData);
                    }
                }
            }
        } else if (actions[proposalId] == Action.UPGRADE_GOVERNANCE) {
            if (winningOption == Option.ONE) {
                for (uint8 i = 0; i < 4; i++) {
                    StakingPool pool = stakingPools[proposalId][i];
                    try pool.transferOwnership(newGovernances[proposalId]) {
                        emit PoolCallSucceeded(pool);
                    } catch Error(string memory reason) {
                        emit PoolCallReverted(pool, reason);
                    } catch (bytes memory lowLevelData) {
                        emit PoolCallReverted(pool, lowLevelData);
                    }
                }
            }
        } else if (actions[proposalId] == Action.CHANGE_QUORUM) {
            if (winningOption == Option.ONE) {
                QUORUM = newQuorums[proposalId];
            }
        } else if (actions[proposalId] == Action.CHANGE_MIN_BALANCE_TO_INIT_PROPOSAL) {
            if (winningOption == Option.ONE) {
                MIN_BALANCE_TO_INIT_PROPOSAL = newMinBalances[proposalId];
            }
        }
    }
    
    function isProposalOpen(uint proposalId) public view returns (bool) {

        if (now < proposalStartTime[proposalId].add(VOTE_DURATION)) {
            return true;
        }
        return false;
    }
    
    function isProposalExecutible(uint proposalId) public view returns (bool) {

        if ((!isProposalOpen(proposalId)) && 
            (now < proposalStartTime[proposalId].add(VOTE_DURATION).add(RESULT_EXECUTION_ALLOWANCE_PERIOD)) &&
            !isProposalExecuted[proposalId] &&
            optionOneVotes[proposalId] != optionTwoVotes[proposalId]) {
                return true;
            }
        return false;
    }
    
    function transferAnyERC20Token(address tokenAddress, address recipient, uint amount) external onlyOwner {

        require (tokenAddress != TRUSTED_TOKEN_ADDRESS || now > contractStartTime.add(ADMIN_CAN_CLAIM_AFTER), "Cannot Transfer Out main tokens!");
        require (Token(tokenAddress).transfer(recipient, amount), "Transfer failed!");
    }
    
    function transferAnyLegacyERC20Token(address tokenAddress, address recipient, uint amount) external onlyOwner {

        require (tokenAddress != TRUSTED_TOKEN_ADDRESS || now > contractStartTime.add(ADMIN_CAN_CLAIM_AFTER), "Cannot Transfer Out main tokens!");
        LegacyToken(tokenAddress).transfer(recipient, amount);
    }
    
    function transferAnyERC20TokenFromPool(address pool, address tokenAddress, address recipient, uint amount) external onlyOwner {

        StakingPool(pool).transferAnyERC20Token(tokenAddress, recipient, amount);
    }
    
    function transferAnyLegacyERC20TokenFromPool(address pool, address tokenAddress, address recipient, uint amount) external onlyOwner {

        StakingPool(pool).transferAnyOldERC20Token(tokenAddress, recipient, amount);
    }
    
}