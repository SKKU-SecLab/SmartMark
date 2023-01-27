


pragma solidity ^0.8.0;

contract ReentrancyGuard {


  uint256 private _guardCounter = 1;

  modifier nonReentrant() {

    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter);
  }

}



pragma solidity ^0.8.0;

interface IABCTreasury {

    function sendABCToken(address recipient, uint _amount) external;


    function getTokensClaimed() external view returns(uint);

    
    function updateNftPriced() external;

    
    function updateProfitGenerated(uint _amount) external;


}



pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;

library sqrtLibrary {

    
    function sqrt(uint x) pure internal returns (uint y) {

        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}



pragma solidity ^0.8.0;

library PostSessionLibrary {


    using sqrtLibrary for *;


    function calculateBase(uint finalAppraisalValue, uint userAppraisalValue) pure internal returns(uint){

        uint base = 1;
        uint userVal = 100 * userAppraisalValue;
        for(uint i=5; i >= 1; i--) {
            uint lowerOver = (100 + (i - 1)) * finalAppraisalValue;
            uint upperOver = (100 + i) * finalAppraisalValue;
            uint lowerUnder = (100 - i) * finalAppraisalValue;
            uint upperUnder = (100 - i + 1) * finalAppraisalValue;
            if (lowerOver < userVal && userVal <= upperOver) {
                return base; 
            }
            if (lowerUnder < userVal && userVal <= upperUnder) {
                return base;
            }
            base += 1;
        }
        if(userVal == 100*finalAppraisalValue) {
            return 6;
        }
        return 0;
    }


    

    function harvest(uint _stake, uint _userAppraisal, uint _finalAppraisal) pure internal returns(uint) {

        if(_userAppraisal*100 > 105*_finalAppraisal) {
            return _stake * (_userAppraisal*100 - 105*_finalAppraisal)/(_finalAppraisal*100);
        }
        else if(_userAppraisal*100 < 95*_finalAppraisal) {
            return _stake * (95*_finalAppraisal - 100*_userAppraisal)/(_finalAppraisal*100);
        }
        else {
            return 0;
        }
    }

    function setCommission(uint _treasurySize) pure internal returns(uint) {

        if (_treasurySize < 25000 ether) {
            return 500;
        }
        else if(_treasurySize >= 25000 ether && _treasurySize < 50000 ether) {
            return 400;
        }
        else if(_treasurySize >= 50000 ether && _treasurySize < 100000 ether) {
            return 300;
        }
        else if(_treasurySize >= 100000 ether && _treasurySize < 2000000 ether) {
            return 200;
        }
        else if(_treasurySize >= 200000 ether && _treasurySize < 400000 ether) {
            return 100;
        }
        else if(_treasurySize >= 400000 ether && _treasurySize < 700000 ether) {
            return 50;
        }
        else {
            return 25;
        }
    }


}



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
}



pragma solidity ^0.8.0;

contract ABCTreasury {

    

    uint public nftsPriced;
    uint public profitGenerated;
    uint public tokensClaimed;


    address public auction;
    address public pricingSessionFactory;
    address public admin;
    address public ABCToken;
    address public multisig;


    constructor() {
        admin = msg.sender;
    }


    function setABCTokenAddress(address _ABCToken) onlyAdmin external {

        require(ABCToken == address(0));
        ABCToken = _ABCToken;
    }

    function setMultisig(address _multisig) onlyAdmin external {

        multisig = _multisig;
    }

    function withdraw(uint _amountAbc, uint _amountEth) onlyAdmin external {

        IERC20(ABCToken).transfer(multisig, _amountAbc);
        (bool sent, ) = payable(multisig).call{value: _amountEth}("");
        require(sent, "Failed to send Ether");
    }

    function setAdmin(address _newAdmin) onlyAdmin external {

        admin = _newAdmin;
    }

    function setPricingFactory(address _pricingFactory) onlyAdmin external {

        pricingSessionFactory = _pricingFactory;
    }

    function setAuction(address _auction) onlyAdmin external {

        auction = _auction;
    }

    
    function sendABCToken(address recipient, uint _amount) external {

        require(msg.sender == pricingSessionFactory || msg.sender == admin || msg.sender == auction);
        IERC20(ABCToken).transfer(recipient, _amount);
        tokensClaimed += _amount;
    }

    function updateProfitGenerated(uint _amount) isFactory external { 

        profitGenerated += _amount;
    }
    
    function updateNftPriced() isFactory external {

        nftsPriced++;
    }


    receive() external payable {}
    fallback() external payable {}


    modifier onlyAdmin() {

        require(admin == msg.sender, "not admin");
        _;
    }
    
    modifier isFactory() {

        require(msg.sender == pricingSessionFactory, "not factory");
        _;
    }
}



pragma solidity ^0.8.0;







contract PricingSession is ReentrancyGuard {


    using SafeMath for uint;


    address public ABCToken;
    ABCTreasury public Treasury;
    address public admin;
    address auction;


    bool auctionStatus;
    

    mapping(address => uint) public payoutStored;

    mapping(address => mapping (uint => uint)) public nftNonce; 

    mapping(uint => mapping(address => mapping(uint => VotingSessionMapping))) NftSessionMap;

    mapping(uint => mapping(address => mapping(uint => VotingSessionChecks))) public NftSessionCheck;

    mapping(uint => mapping(address => mapping(uint => VotingSessionCore))) public NftSessionCore;

    mapping(uint => mapping(address => mapping(uint => uint))) public finalAppraisalValue;
    

    struct VotingSessionMapping {

        mapping (address => uint) voterCheck;
        mapping (address => uint) winnerPoints;
        mapping (address => uint) amountHarvested;
        mapping (address => Voter) nftVotes;
    }

    struct VotingSessionChecks {

        uint sessionProgression;
        uint calls;
        uint correct;
        uint incorrect;
        uint timeFinalAppraisalSet;
    }

    struct VotingSessionCore {

        uint endTime;
        uint lowestStake;
        uint maxAppraisal;
        uint totalAppraisalValue;
        uint totalSessionStake;
        uint totalProfit;
        uint totalWinnerPoints;
        uint totalVotes;
        uint uniqueVoters;
        uint votingTime;
    }

    struct Voter {

        bytes32 concealedAppraisal;
        uint base;
        uint appraisal;
        uint stake;
    }


    event PricingSessionCreated(address creator_, address nftAddress_, uint tokenid_, uint initialAppraisal_, uint bounty_);
    event newAppraisalAdded(address voter_, uint stake_, uint appraisal, uint weight);
    event finalAppraisalDetermined(uint finalAppraisal, uint amountOfParticipants, uint totalStake);
    event lossHarvestedFromUser(address user_, uint harvested);
    event ethClaimedByUser(address user_, uint ethClaimed);
    event ethToPPExchange(address user_, uint ethExchanged, uint ppSent);
    event sessionEnded(address nftAddress, uint tokenid, uint nonce);


    constructor(address _ABCToken, address _treasury, address _auction) {
        ABCToken = _ABCToken;
        Treasury = ABCTreasury(payable(_treasury));
        auction = _auction;
        admin = msg.sender;
        auctionStatus = true;
    }

    function setAuction(address _auction) external {

        require(msg.sender == admin);
        auction = _auction;
    }

    function setAuctionStatus(bool status) external {

        require(msg.sender == admin); 
        auctionStatus = status;
    }

    function createNewSession(
        address nftAddress,
        uint tokenid,
        uint _initialAppraisal,
        uint _votingTime
    ) stopOverwrite(nftAddress, tokenid) external payable {

        require(_votingTime <= 1 days && (!auctionStatus || msg.sender == auction));
        VotingSessionCore storage sessionCore = NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        uint abcCost = 0.005 ether *(ethToAbc());
        (bool abcSent) = IERC20(ABCToken).transferFrom(msg.sender, address(Treasury), abcCost);
        require(abcSent);
        if(nftNonce[nftAddress][tokenid] == 0 || getStatus(nftAddress, tokenid) == 5) {}
        else if(block.timestamp > sessionCore.endTime + sessionCore.votingTime * 3) {
            _executeEnd(nftAddress, tokenid);
        }
        nftNonce[nftAddress][tokenid]++;
        VotingSessionCore storage sessionCoreNew = NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        sessionCoreNew.votingTime = _votingTime;
        sessionCoreNew.maxAppraisal = 69420 * _initialAppraisal / 1000;
        sessionCoreNew.lowestStake = 100000 ether;
        sessionCoreNew.endTime = block.timestamp + _votingTime;
        sessionCoreNew.totalSessionStake = msg.value;
        emit PricingSessionCreated(msg.sender, nftAddress, tokenid, _initialAppraisal, msg.value);
    }

    
    function setVote(
        address nftAddress,
        uint tokenid,
        bytes32 concealedAppraisal
    ) properVote(nftAddress, tokenid) payable external {

        uint currentNonce = nftNonce[nftAddress][tokenid];
        VotingSessionCore storage sessionCore = NftSessionCore[currentNonce][nftAddress][tokenid];
        VotingSessionMapping storage sessionMap = NftSessionMap[currentNonce][nftAddress][tokenid];
        require(sessionCore.endTime > block.timestamp);
        sessionMap.voterCheck[msg.sender] = 1;
        if (msg.value < sessionCore.lowestStake) {
            sessionCore.lowestStake = msg.value;
        }
        sessionCore.uniqueVoters++;
        sessionCore.totalSessionStake = sessionCore.totalSessionStake.add(msg.value);
        sessionMap.nftVotes[msg.sender].concealedAppraisal = concealedAppraisal;
        sessionMap.nftVotes[msg.sender].stake = msg.value;
    }

    function updateVote(
        address nftAddress,
        uint tokenid,
        bytes32 concealedAppraisal
    ) external {

        uint currentNonce = nftNonce[nftAddress][tokenid];
        VotingSessionCore storage sessionCore = NftSessionCore[currentNonce][nftAddress][tokenid];
        VotingSessionMapping storage sessionMap = NftSessionMap[currentNonce][nftAddress][tokenid];
        require(sessionMap.voterCheck[msg.sender] == 1);
        require(sessionCore.endTime > block.timestamp);
        sessionMap.nftVotes[msg.sender].concealedAppraisal = concealedAppraisal;
    }

    function weightVote(address nftAddress, uint tokenid, uint appraisal, uint seedNum) checkParticipation(nftAddress, tokenid) nonReentrant external {

        uint currentNonce = nftNonce[nftAddress][tokenid];
        VotingSessionCore storage sessionCore = NftSessionCore[currentNonce][nftAddress][tokenid];
        VotingSessionChecks storage sessionCheck = NftSessionCheck[currentNonce][nftAddress][tokenid];
        VotingSessionMapping storage sessionMap = NftSessionMap[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        require(sessionCheck.sessionProgression < 2
                && sessionCore.endTime < block.timestamp
                && sessionMap.voterCheck[msg.sender] == 1
                && sessionMap.nftVotes[msg.sender].concealedAppraisal == keccak256(abi.encodePacked(appraisal, msg.sender, seedNum))
                && sessionCore.maxAppraisal >= appraisal
        );
        sessionMap.voterCheck[msg.sender] = 2;
        if(sessionCheck.sessionProgression == 0) {
            sessionCheck.sessionProgression = 1;
        }
        sessionMap.nftVotes[msg.sender].appraisal = appraisal;
        uint weight = sqrtLibrary.sqrt(sessionMap.nftVotes[msg.sender].stake/sessionCore.lowestStake);
        sessionCore.totalVotes += weight;
        sessionCheck.calls++;
        
        sessionCore.totalAppraisalValue = sessionCore.totalAppraisalValue.add((weight) * appraisal);
        emit newAppraisalAdded(msg.sender, sessionMap.nftVotes[msg.sender].stake, appraisal, weight);
        if(sessionCheck.calls == sessionCore.uniqueVoters || sessionCore.endTime + sessionCore.votingTime < block.timestamp) {
            sessionCheck.sessionProgression = 2;
            sessionCore.uniqueVoters = sessionCheck.calls;
            sessionCheck.calls = 0;
        }
    }
    
    function setFinalAppraisal(address nftAddress, uint tokenid) nonReentrant external {

        VotingSessionCore storage sessionCore = NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        VotingSessionChecks storage sessionCheck = NftSessionCheck[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        require(
            (block.timestamp > sessionCore.endTime + sessionCore.votingTime || sessionCheck.sessionProgression == 2)
            && sessionCheck.sessionProgression <= 2
        );
        Treasury.updateNftPriced();
        if(sessionCheck.calls != 0) {
            sessionCore.uniqueVoters = sessionCheck.calls;
        }
        sessionCheck.calls = 0;
        sessionCheck.timeFinalAppraisalSet = block.timestamp;
        finalAppraisalValue[nftNonce[nftAddress][tokenid]][nftAddress][tokenid] = (sessionCore.totalAppraisalValue)/(sessionCore.totalVotes);
        sessionCheck.sessionProgression = 3;
        emit finalAppraisalDetermined(finalAppraisalValue[nftNonce[nftAddress][tokenid]][nftAddress][tokenid], sessionCore.uniqueVoters, sessionCore.totalSessionStake);
    }

    function harvest(address nftAddress, uint tokenid) checkParticipation(nftAddress, tokenid) nonReentrant external {

        VotingSessionCore storage sessionCore = NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        VotingSessionChecks storage sessionCheck = NftSessionCheck[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        VotingSessionMapping storage sessionMap = NftSessionMap[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        require(
            sessionCheck.sessionProgression == 3
            && sessionMap.voterCheck[msg.sender] == 2
        );
        sessionCheck.calls++;
        sessionMap.voterCheck[msg.sender] = 3;
        sessionMap.nftVotes[msg.sender].base = 
            PostSessionLibrary.calculateBase(
                finalAppraisalValue[nftNonce[nftAddress][tokenid]][nftAddress][tokenid], 
                sessionMap.nftVotes[msg.sender].appraisal
            );
        uint weight = sqrtLibrary.sqrt(sessionMap.nftVotes[msg.sender].stake/sessionCore.lowestStake);
        
        if(NftSessionMap[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].nftVotes[msg.sender].base > 0) {
            sessionCore.totalWinnerPoints += sessionMap.nftVotes[msg.sender].base * weight;
            sessionMap.winnerPoints[msg.sender] = sessionMap.nftVotes[msg.sender].base * weight;
            sessionCheck.correct += weight;
        }
        else {
            sessionCheck.incorrect += weight;
        }
        
       sessionMap.amountHarvested[msg.sender] = PostSessionLibrary.harvest( 
            sessionMap.nftVotes[msg.sender].stake, 
            sessionMap.nftVotes[msg.sender].appraisal,
            finalAppraisalValue[nftNonce[nftAddress][tokenid]][nftAddress][tokenid]
        );

        sessionMap.nftVotes[msg.sender].stake -= sessionMap.amountHarvested[msg.sender];
        uint commission = PostSessionLibrary.setCommission(address(Treasury).balance).mul(sessionMap.amountHarvested[msg.sender]).div(10000);
        sessionCore.totalSessionStake -= commission;
        sessionMap.amountHarvested[msg.sender] -= commission;
        sessionCore.totalProfit += sessionMap.amountHarvested[msg.sender];
        Treasury.updateProfitGenerated(sessionMap.amountHarvested[msg.sender]);
        (bool sent, ) = payable(Treasury).call{value: commission}("");
        require(sent);
        emit lossHarvestedFromUser(msg.sender, sessionMap.amountHarvested[msg.sender]);

        if(sessionCheck.calls == sessionCore.uniqueVoters) {
            sessionCheck.sessionProgression = 4;
            sessionCore.uniqueVoters = sessionCheck.calls;
            sessionCheck.calls = 0;
        }
    }

    function claim(address nftAddress, uint tokenid) checkHarvestLoss(nftAddress, tokenid) checkParticipation(nftAddress, tokenid) nonReentrant external returns(uint) {

        VotingSessionCore storage sessionCore = NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        VotingSessionChecks storage sessionCheck = NftSessionCheck[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        VotingSessionMapping storage sessionMap = NftSessionMap[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        require(
            (block.timestamp > sessionCheck.timeFinalAppraisalSet + sessionCore.votingTime || sessionCheck.sessionProgression == 4)
            && sessionCheck.sessionProgression <= 4
            && sessionMap.voterCheck[msg.sender] == 3
        );
        uint principalReturn;
        sessionMap.voterCheck[msg.sender] = 4;
        if(sessionCheck.sessionProgression == 3) {
            sessionCore.uniqueVoters = sessionCheck.calls;
            sessionCheck.calls = 0;
            sessionCheck.sessionProgression = 4;
        }
        if(sessionCheck.correct * 100 / (sessionCheck.correct + sessionCheck.incorrect) >= 90) {
            principalReturn = sessionMap.nftVotes[msg.sender].stake + sessionMap.amountHarvested[msg.sender];
        }
        else {
            principalReturn = sessionMap.nftVotes[msg.sender].stake;
        }
        sessionCheck.calls++;
        uint payout;
        if(sessionMap.winnerPoints[msg.sender] == 0) {
            payout = 0;
        }
        else {
            payout = sessionCore.totalProfit * sessionMap.winnerPoints[msg.sender] / sessionCore.totalWinnerPoints;
        }
        payoutStored[msg.sender] += payout;
        sessionCore.totalProfit -= payout;
        sessionCore.totalSessionStake -= payout + principalReturn;
        sessionCore.totalWinnerPoints -= sessionMap.winnerPoints[msg.sender];
        sessionMap.winnerPoints[msg.sender] = 0;
        (bool sent1, ) = payable(msg.sender).call{value: principalReturn}("");
        require(sent1);
        if(sessionCheck.calls == sessionCore.uniqueVoters || block.timestamp > sessionCheck.timeFinalAppraisalSet + sessionCore.votingTime*2) {
            _executeEnd(nftAddress, tokenid);
            return 0;
        }

        return 1;
    }
    
    function endSession(address nftAddress, uint tokenid) public {

        VotingSessionCore storage sessionCore = NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        VotingSessionChecks storage sessionCheck = NftSessionCheck[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        require((block.timestamp > sessionCheck.timeFinalAppraisalSet + sessionCore.votingTime * 2) || sessionCheck.sessionProgression == 5, "Session not complete");
        _executeEnd(nftAddress, tokenid);
    }

    function claimProfitsEarned(uint trigger, uint _amount) nonReentrant external {

        require(trigger == 1 || trigger == 2);
        require(payoutStored[msg.sender] >= _amount);
        if(trigger == 1) {
            (bool sent1, ) = payable(msg.sender).call{value: _amount}("");
            require(sent1);
            payoutStored[msg.sender] -= _amount;
            emit ethClaimedByUser(msg.sender, _amount);
        }
        else if(trigger == 2) {
            uint abcAmount = _amount / (0.00005 ether + 0.000015 ether * Treasury.tokensClaimed()/(1000000*1e18));
            uint abcPayout = ((_amount / (0.00005 ether + 0.000015 ether * Treasury.tokensClaimed()/(1000000*1e18))) + (_amount / (0.00005 ether + 0.000015 ether * Treasury.tokensClaimed() + abcAmount) / (1000000*1e18)) / 2);
            (bool sent3, ) = payable(Treasury).call{value: _amount}("");
            require(sent3);
            payoutStored[msg.sender] -= _amount;
            Treasury.sendABCToken(msg.sender, abcPayout * 1e18);
            emit ethToPPExchange(msg.sender, _amount, abcPayout);
        }
    } 


    function _executeEnd(address nftAddress, uint tokenid) internal {

        VotingSessionCore storage sessionCore = NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        VotingSessionChecks storage sessionCheck = NftSessionCheck[nftNonce[nftAddress][tokenid]][nftAddress][tokenid];
        sessionCheck.sessionProgression = 5;
        uint tPayout = 95*sessionCore.totalSessionStake/100;
        uint cPayout = sessionCore.totalSessionStake - tPayout;
        (bool sent, ) = payable(Treasury).call{value: tPayout}("");
        require(sent);
        (bool sent1, ) = payable(msg.sender).call{value: cPayout}("");
        require(sent1);
        sessionCore.totalSessionStake = 0;
        emit sessionEnded(nftAddress, tokenid, nftNonce[nftAddress][tokenid]);
    }


    function addToBounty(address nftAddress, uint tokenid) payable external {

        require(NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].endTime > block.timestamp);
        NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].totalSessionStake += msg.value;
    }
    
    function addToAppraisal(address nftAddress, uint tokenid, address user) payable external {

        require(
            NftSessionMap[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].voterCheck[user] == 1
            && NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].endTime > block.timestamp
        );
        NftSessionMap[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].nftVotes[user].stake += msg.value;
    }


    function getStatus(address nftAddress, uint tokenid) view public returns(uint) {

        return NftSessionCheck[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].sessionProgression;
    }

    function ethToAbc() view public returns(uint) {

        return 1e18 / (0.00005 ether + 0.000015 ether * Treasury.tokensClaimed() / (1000000*1e18));
    }

    function getEthPayout(address nftAddress, uint tokenid) view external returns(uint) {

        if(NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].totalWinnerPoints == 0) {
            return 0;
        }
        return NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].totalSessionStake * NftSessionMap[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].winnerPoints[msg.sender] / NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].totalWinnerPoints;
    }

    function getVoterCheck(address nftAddress, uint tokenid, address _user) view external returns(uint) {

        return NftSessionMap[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].voterCheck[_user];
    }


    receive() external payable {}
    fallback() external payable {}


    modifier stopOverwrite(
        address nftAddress, 
        uint tokenid
    ) {

        require(
            nftNonce[nftAddress][tokenid] == 0 
            || getStatus(nftAddress, tokenid) == 5
            || block.timestamp > NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].endTime + NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].votingTime * 3
        );
        _;
    }
    
    modifier properVote(
        address nftAddress,
        uint tokenid
    ) {

        require(
            NftSessionMap[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].voterCheck[msg.sender] == 0
            && msg.value >= 0.005 ether
        );
        _;
    }
    
    modifier checkParticipation(
        address nftAddress,
        uint tokenid
    ) {

        require(NftSessionMap[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].voterCheck[msg.sender] > 0);
        _;
    }
    
    modifier checkHarvestLoss(
        address nftAddress,
        uint tokenid
    ) {

        require(
            NftSessionCheck[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].sessionProgression == 4
            || block.timestamp > (NftSessionCheck[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].timeFinalAppraisalSet + NftSessionCore[nftNonce[nftAddress][tokenid]][nftAddress][tokenid].votingTime)
        );
        _;
    }
}