
pragma solidity ^0.4.14;

library SafeMath {

    function mul(uint256 a, uint256 b) internal constant returns (uint256) {

        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {

        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20Interface {

    uint256 public totalSupply; //tokens that can vote, transfer, receive dividend
    function balanceOf(address who) public constant returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    function allowance(address owner, address spender) public constant returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ModumToken is ERC20Interface {


    using SafeMath for uint256;

    address public owner;

    mapping(address => mapping (address => uint256)) public allowed;

    enum UpdateMode{Wei, Vote, Both} //update mode for the account
    struct Account {
        uint256 lastProposalStartTime; //For checking at which proposal valueModVote was last updated
        uint256 lastAirdropWei; //For checking after which airDrop bonusWei was last updated
        uint256 lastAirdropClaimTime; //for unclaimed airdrops, re-airdrop
        uint256 bonusWei;      //airDrop/Dividend payout available for withdrawal.
        uint256 valueModVote;  // votes available for voting on active Proposal
        uint256 valueMod;      // the owned tokens
    }
    mapping(address => Account) public accounts;

    uint256 public totalDropPerUnlockedToken = 0;     //totally airdropped eth per unlocked token
    uint256 public rounding = 0;                      //airdrops not accounted yet to make system rounding error proof

    uint256 public lockedTokens = 9 * 1100 * 1000;   //token that need to be unlocked by voting
    uint256 public constant maxTokens = 30 * 1000 * 1000;      //max distributable tokens

    bool public mintDone = false;
    uint256 public constant redistributionTimeout = 548 days; //18 month

    string public constant name = "Modum Token";
    string public constant symbol = "MOD";
    uint8 public constant decimals = 0;

    struct Proposal {
        string addr;        //Uri for more info
        bytes32 hash;       //Hash of the uri content for checking
        uint256 valueMod;      //token to unlock: proposal with 0 amount is invalid
        uint256 startTime;
        uint256 yay;
        uint256 nay;
    }
    Proposal public currentProposal;
    uint256 public constant votingDuration = 2 weeks;
    uint256 public lastNegativeVoting = 0;
    uint256 public constant blockingDuration = 90 days;

    event Voted(address _addr, bool option, uint256 votes); //called when a vote is casted
    event Payout(uint256 weiPerToken); //called when an someone payed ETHs to this contract, that can be distributed

    function ModumToken() public {

        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) public {

        require(msg.sender == owner);
        require(_newOwner != address(0));
        owner = _newOwner;
    }

    function votingProposal(string _addr, bytes32 _hash, uint256 _value) public {

        require(msg.sender == owner); // proposal ony by onwer
        require(!isProposalActive()); // no proposal is active, cannot vote in parallel
        require(_value <= lockedTokens); //proposal cannot be larger than remaining locked tokens
        require(_value > 0); //there needs to be locked tokens to make proposal, at least 1 locked token
        require(_hash != bytes32(0)); //hash need to be set
        require(bytes(_addr).length > 0); //the address need to be set and non-empty
        require(mintDone); //minting phase needs to be over
        require(now >= lastNegativeVoting.add(blockingDuration));

        currentProposal = Proposal(_addr, _hash, _value, now, 0, 0);
    }

    function vote(bool _vote) public returns (uint256) {

        require(isVoteOngoing()); // vote needs to be ongoing
        Account storage account = updateAccount(msg.sender, UpdateMode.Vote);
        uint256 votes = account.valueModVote; //available votes
        require(votes > 0); //voter must have a vote left, either by not voting yet, or have modum tokens

        if(_vote) {
            currentProposal.yay = currentProposal.yay.add(votes);
        }
        else {
            currentProposal.nay = currentProposal.nay.add(votes);
        }

        account.valueModVote = 0;
        Voted(msg.sender, _vote, votes);
        return votes;
    }

    function showVotes(address _addr) public constant returns (uint256) {

        Account memory account = accounts[_addr];
        if(account.lastProposalStartTime < currentProposal.startTime || // the user did set his token power yet
            (account.lastProposalStartTime == 0 && currentProposal.startTime == 0)) {
            return account.valueMod;
        }
        return account.valueModVote;
    }

    function claimVotingProposal() public {

        require(msg.sender == owner); //only owner can claim proposal
        require(isProposalActive()); // proposal active
        require(isVotingPhaseOver()); // voting has already ended

        if(currentProposal.yay > currentProposal.nay && currentProposal.valueMod > 0) {
            Account storage account = updateAccount(owner, UpdateMode.Both);
            uint256 valueMod = currentProposal.valueMod;
            account.valueMod = account.valueMod.add(valueMod); //add tokens to owner
            totalSupply = totalSupply.add(valueMod);
            lockedTokens = lockedTokens.sub(valueMod);
        } else if(currentProposal.yay <= currentProposal.nay) {
            lastNegativeVoting = currentProposal.startTime.add(votingDuration);
        }
        delete currentProposal; //proposal ended
    }

    function isProposalActive() public constant returns (bool)  {

        return currentProposal.hash != bytes32(0);
    }

    function isVoteOngoing() public constant returns (bool)  {

        return isProposalActive()
            && now >= currentProposal.startTime
            && now < currentProposal.startTime.add(votingDuration);
    }

    function isVotingPhaseOver() public constant returns (bool)  {

        return now >= currentProposal.startTime.add(votingDuration);
    }

    function mint(address[] _recipient, uint256[] _value) public {

        require(msg.sender == owner); //only owner can claim proposal
        require(!mintDone); //only during minting

        for (uint8 i=0; i<_recipient.length; i++) {
            

            address tmpRecipient = _recipient[i];
            uint tmpValue = _value[i];

            Account storage account = accounts[tmpRecipient];
            account.valueMod = account.valueMod.add(tmpValue);
            account.lastAirdropClaimTime = now;
            totalSupply = totalSupply.add(tmpValue); //create the tokens and add to recipient
            Transfer(msg.sender, tmpRecipient, tmpValue);
        }
    }

    function setMintDone() public {

        require(msg.sender == owner);
        require(!mintDone); //only in minting phase
        require(lockedTokens.add(totalSupply) <= maxTokens);
        mintDone = true; //end the minting
    }

    function updateAccount(address _addr, UpdateMode mode) internal returns (Account storage){

        Account storage account = accounts[_addr];
        if(mode == UpdateMode.Vote || mode == UpdateMode.Both) {
            if(isVoteOngoing() && account.lastProposalStartTime < currentProposal.startTime) {// the user did set his token power yet
                account.valueModVote = account.valueMod;
                account.lastProposalStartTime = currentProposal.startTime;
            }
        }

        if(mode == UpdateMode.Wei || mode == UpdateMode.Both) {
            uint256 bonus = totalDropPerUnlockedToken.sub(account.lastAirdropWei);
            if(bonus != 0) {
                account.bonusWei = account.bonusWei.add(bonus.mul(account.valueMod));
                account.lastAirdropWei = totalDropPerUnlockedToken;
            }
        }

        return account;
    }

    function() public payable {
        require(mintDone); //minting needs to be over
        require(msg.sender == owner); //ETH payment need to be one-way only, from modum to tokenholders, confirmed by Lykke
        payout(msg.value);
    }
    
    function payBonus(address[] _addr) public payable {

        require(msg.sender == owner);  //ETH payment need to be one-way only, from modum to tokenholders, confirmed by Lykke
        uint256 totalWei = 0;
        for (uint8 i=0; i<_addr.length; i++) {
            Account storage account = updateAccount(_addr[i], UpdateMode.Wei);
            if(now >= account.lastAirdropClaimTime + redistributionTimeout) {
                totalWei += account.bonusWei;
                account.bonusWei = 0;
                account.lastAirdropClaimTime = now;
            } else {
                revert();
            }
        }
        payout(msg.value.add(totalWei));
    }
    
    function payout(uint256 valueWei) internal {

        uint256 value = valueWei.add(rounding); //add old rounding
        rounding = value % totalSupply; //ensure no rounding error
        uint256 weiPerToken = value.sub(rounding).div(totalSupply);
        totalDropPerUnlockedToken = totalDropPerUnlockedToken.add(weiPerToken); //account for locked tokens and add the drop
        Payout(weiPerToken);
    }

    function showBonus(address _addr) public constant returns (uint256) {

        uint256 bonus = totalDropPerUnlockedToken.sub(accounts[_addr].lastAirdropWei);
        if(bonus != 0) {
            return accounts[_addr].bonusWei.add(bonus.mul(accounts[_addr].valueMod));
        }
        return accounts[_addr].bonusWei;
    }

    function claimBonus() public returns (uint256) {

        require(mintDone); //minting needs to be over

        Account storage account = updateAccount(msg.sender, UpdateMode.Wei);
        uint256 sendValue = account.bonusWei; //fetch the values

        if(sendValue != 0) {
            account.bonusWei = 0; //set to zero (before, against reentry)
            account.lastAirdropClaimTime = now; //mark as collected now
            msg.sender.transfer(sendValue); //send the bonus to the correct account
            return sendValue;
        }
        return 0;
    }


    function balanceOf(address _owner) public constant returns (uint256 balance) {

        return accounts[_owner].valueMod;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(mintDone);
        require(_value > 0);
        Account memory tmpFrom = accounts[msg.sender];
        require(tmpFrom.valueMod >= _value);

        Account storage from = updateAccount(msg.sender, UpdateMode.Both);
        Account storage to = updateAccount(_to, UpdateMode.Both);
        from.valueMod = from.valueMod.sub(_value);
        to.valueMod = to.valueMod.add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(mintDone);
        require(_value > 0);
        Account memory tmpFrom = accounts[_from];
        require(tmpFrom.valueMod >= _value);
        require(allowed[_from][msg.sender] >= _value);

        Account storage from = updateAccount(_from, UpdateMode.Both);
        Account storage to = updateAccount(_to, UpdateMode.Both);
        from.valueMod = from.valueMod.sub(_value);
        to.valueMod = to.valueMod.add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool) {

        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool success) {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool success) {

        uint256 oldValue = allowed[msg.sender][_spender];
        if(_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}