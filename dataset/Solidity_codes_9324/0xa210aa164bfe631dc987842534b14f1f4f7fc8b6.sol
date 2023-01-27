

pragma solidity 0.8.7;

contract ProxyTarget {


    bytes32 internal constant IMPLEMENTATION_SLOT = bytes32(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);
    bytes32 internal constant ADMIN_SLOT          = bytes32(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103);

    function _getAddress(bytes32 key) internal view returns (address add) {

        add = address(uint160(uint256(_getSlotValue(key))));
    }

    function _getSlotValue(bytes32 slot_) internal view returns (bytes32 value_) {

        assembly {
            value_ := sload(slot_)
        }
    }

    function _setSlotValue(bytes32 slot_, bytes32 value_) internal {

        assembly {
            sstore(slot_, value_)
        }
    }

}

pragma solidity ^0.8.0;

interface IMetadata{


    function addMetadata(uint8 tokenType,uint8 level,uint tokenID) external;

    function createRandomZombie(uint8 level) external returns(uint8[] memory traits);

    function createRandomSurvivor(uint8 level) external returns(uint8[] memory traits);

    function getTokenURI(uint tokenId) external view returns (string memory);

    function changeNft(uint tokenID, uint8 nftType, uint8 level, bool canClaim, uint stakedTime, uint lastClaimTime) external;

    function getToken(uint256 _tokenId) external view returns(uint8, uint8, bool, uint,uint);

}



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
}


pragma solidity ^0.8.0;

interface IVRF{


    function initiateRandomness(uint _tokenId,uint _timestamp) external view returns(uint);

    function stealRandomness() external view returns(uint);

    function getCurrentIndex() external view returns(uint);

}



pragma solidity ^0.8.0;

contract Context {


    constructor ()  {}

    function _msgSender() internal view returns (address payable) {

        return payable (msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {

        this;
        return msg.data;
    }
}




pragma solidity ^0.8.0;
contract Ownable is Context {

    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




pragma solidity ^0.8.0;
interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}



pragma solidity ^0.8.0;

interface INFTFactory is IERC721{


    function restrictedChangeNft(uint tokenID, uint8 nftType, uint8 level, bool canClaim, uint stakedTime, uint lastClaimTime) external;

    function tokenOwnerCall(uint tokenId) external view  returns (address);

    function burnNFT(uint tokenId) external ;

    function tokenOwnerSetter(uint tokenId, address _owner) external;

    function setTimeStamp(uint tokenId) external;

    function actionTimestamp(uint tokenId) external returns(uint);


}



pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function burn(uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}


pragma solidity ^0.8.0;

interface ISUP is IERC20{

    function mintFromEngine(address _receiver, uint _amount) external;

}




pragma solidity ^0.8.0;









contract testGameEngine is Ownable, ReentrancyGuard, ProxyTarget {


    mapping (uint => uint) public firstStakeLockPeriod;
    mapping (uint => bool) public stakeConfirmation;
    mapping (uint => bool) public isStaked;
    mapping (uint => uint) public stakeTime;
    mapping (uint => uint) public lastClaim;
    mapping (uint8 => mapping(uint8 =>uint[])) public pool; //0 zombie 1 survivor (1-5) levels
    mapping (uint => uint) public levelOfToken;
    mapping (uint => uint) public tokenToArrayPosition;
    mapping (uint => uint) public tokenToRandomHourInStake;
    mapping (uint => bool) public wasUnstakedRecently;

    ISUP token;
    INFTFactory nftToken;
    IVRF randomNumberGenerated;
    IMetadata metadataHandler;

    bool public frenzyStarted;

    function initialize(address _randomEngineAddress, address _nftAddress, address _tokenAddress,address _metadata) external {

        require(msg.sender == _getAddress(ADMIN_SLOT), "not admin");

        _owner = msg.sender;

        token = ISUP(_tokenAddress);
        nftToken = INFTFactory(_nftAddress);
        randomNumberGenerated = IVRF(_randomEngineAddress);
        metadataHandler = IMetadata(_metadata);
        for(uint8 i=0;i<2;i++){
            for(uint8 j=1;j<6;j++){
                pool[i][j].push(0);
            }
        }
    }

    function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) public pure returns (bytes4) {

        return 0x150b7a02;
    }

    function alertStake (uint tokenId) external {
        require (isStaked[tokenId] == false);
        require (nftToken.ownerOf(tokenId)==address(this));
        uint randomNo = 2 + randomNumberGenerated.initiateRandomness(tokenId,nftToken.actionTimestamp(tokenId))%5;
        nftToken.setTimeStamp(tokenId);
        firstStakeLockPeriod[tokenId] = block.timestamp + randomNo*1 hours; //convert randomNo from hours to sec
        isStaked[tokenId] = true;
        stakeTime[tokenId] = block.timestamp;
        tokenToRandomHourInStake[tokenId]= randomNo*1 hours; //conversion required
        levelOfToken[tokenId] = 1;
        determineAndPush(tokenId);
    }

    function stake (uint[] memory tokenId) external {
        for (uint i;i<tokenId.length;i++) {
        require (isStaked[tokenId[i]] == false);
        if ( stakeConfirmation [tokenId[i]] == true ){
            nftToken.safeTransferFrom(msg.sender, address(this), tokenId[i]);
            stakeTime[tokenId[i]] = block.timestamp;
            isStaked[tokenId[i]] = true;
            nftToken.setTimeStamp(tokenId[i]);
            determineAndPush(tokenId[i]);
        } else   {
            require(firstStakeLockPeriod[tokenId[i]]==0,"AlreadyStaked");
            uint randomNo =  2 + randomNumberGenerated.initiateRandomness(tokenId[i],nftToken.actionTimestamp(tokenId[i])) % 5;
            nftToken.setTimeStamp(tokenId[i]);
            firstStakeLockPeriod[tokenId[i]] = block.timestamp + randomNo*1 hours; //convert randomNo from hours to sec
            nftToken.safeTransferFrom(msg.sender, address (this), tokenId[i]);
            stakeTime[tokenId[i]] = block.timestamp;
            isStaked[tokenId[i]] = true;
            tokenToRandomHourInStake[tokenId[i]]= randomNo * 1 hours; //conversion required
            levelOfToken[tokenId[i]] = 1;
            determineAndPush(tokenId[i]);
          }
        }
    }

    function moveToLast(uint _tokenId) internal {

        (uint8 tokenType,,,,) = metadataHandler.getToken(_tokenId);
        uint8 level = uint8(levelOfToken[_tokenId]);
        uint position = tokenToArrayPosition[_tokenId];
        uint[] storage currentPool = pool[tokenType][level];
        uint length = currentPool.length;
        uint lastToken = currentPool[length-1];
        currentPool[position] = lastToken;
        tokenToArrayPosition[lastToken] = position;
        currentPool[length-1] = _tokenId;
        currentPool.pop();
    }

    function determineAndPush(uint tokenId) internal {

        uint8 tokenLevel = uint8(levelOfToken[tokenId]);
        (uint8 tokenType,,,,) = metadataHandler.getToken(tokenId);
        pool[tokenType][tokenLevel].push(tokenId);
        tokenToArrayPosition[tokenId] = pool[tokenType][tokenLevel].length-1;
    }

    function unstakeBurnCalculator(uint8 tokenLevel) internal returns(uint){

        if(isFrenzy()){
            return 50-5*tokenLevel;
        }
        else if(isAggression()){
            uint val = whichAggression();
            return (25+5*val)-(5*tokenLevel);
        }
        else{
            return 25-5*tokenLevel;
        }
    }

    function isFrenzy() public returns (bool){

        uint totalPoolStrength;
        for(uint8 i=0;i<2;i++){
            for(uint8 j=1;j<6;j++){
                totalPoolStrength += pool[i][j].length;
            }
        }
        if(totalPoolStrength<10000 && frenzyStarted == true){
            frenzyStarted = false;
            return false;
        }
        else if(totalPoolStrength >= 20000){
            frenzyStarted = true;
            return true;
        }
        else{
            return false;
        }
    }

    function isAggression() view public returns(bool){

        uint totalPoolStrength;
        for(uint8 i=0;i<2;i++){
            for(uint8 j=1;j<6;j++){
                totalPoolStrength += pool[i][j].length;
            }
        }
        if(totalPoolStrength >= 12000) return true;
        else return false;
    }

    function whichAggression() view internal returns(uint){

        uint totalPoolStrength;
        for(uint8 i=0;i<2;i++){
            for(uint8 j=1;j<6;j++){
                totalPoolStrength += pool[i][j].length;
            }
        }
        if(totalPoolStrength>=12000 && totalPoolStrength<14000) return 1;
        else if(totalPoolStrength<16000) return 2;
        else if(totalPoolStrength<18000) return 3;
        else if(totalPoolStrength<20000) return 4;
        else return 0;
    }

    function steal(uint8 tokenType,uint nonce) internal view returns (uint) {

        uint randomNumber = randomNumberGenerated.stealRandomness();
        randomNumber = uint(keccak256(abi.encodePacked(randomNumber,nonce)));
        uint8 level = whichLevelToChoose(tokenType, randomNumber);
        uint tokenToGet = randomNumber % pool[tokenType][level].length;
        return pool[tokenType][level][tokenToGet];
    }

    function whichLevelToChoose(uint8 tokenType, uint randomNumber) internal view returns(uint8) {

        uint16[5] memory x = [1000,875,750,625,500];
        uint denom;
        for(uint8 level=1;level<6;level++){
            denom += pool[tokenType][level].length*x[level-1];
        }
        uint[5] memory stealing;
        for(uint8 level=1;level<6;level++){
            stealing[level-1] = (pool[tokenType][level].length*x[level-1]*1000000)/denom;
        }
        uint8 levelToReturn;
        randomNumber = randomNumber %1000000;
        if (randomNumber < stealing[0]) {
            levelToReturn = 1;
        } else if (randomNumber < stealing[0]+stealing[1]) {
            levelToReturn = 2;
        } else if (randomNumber < stealing[0]+stealing[1]+stealing[2]) {
            levelToReturn = 3;
        } else if (randomNumber < stealing[0]+stealing[1]+stealing[2]+stealing[3]) {
            levelToReturn = 4;
        } else {
            levelToReturn = 5;
        }
        return levelToReturn;
    }

    function howManyTokensCanSteal(uint8 tokenType) view internal returns (uint) {

        uint[2] memory totalStaked;

        for(uint8 i =0;i<2;i++){
            totalStaked[i] = totalStakedOfType(i);
        }
        for(uint i = 0;i<5;i++) {
            if((totalStaked[tokenType]*100)/(totalStaked[0]+totalStaked[1])<=10+10*i){
                if(totalStaked[1-tokenType] >= 5-i){
                    return 5-i;
                }
                return totalStaked[1-tokenType];
            }
        }
        if(totalStaked[1-tokenType] > 0) {
            return 1;
        }
        return 0;
    }

    function calculateSUP (uint tokenId) internal returns (uint) {
        uint calculatedDuration;
        uint stakedTime = stakeTime[tokenId];
        uint lastClaimTime = lastClaim[tokenId];
        if (lastClaimTime == 0) {
            calculatedDuration = (block.timestamp - (stakedTime+tokenToRandomHourInStake[tokenId]))/1 hours;//todo /60*60
            if (calculatedDuration >= tokenToRandomHourInStake[tokenId]/1 hours) {
            return 250 ether;
            } else {
                return 0;
            }
        } else {
            if (wasUnstakedRecently[tokenId] == true) {
                calculatedDuration = (block.timestamp - stakedTime);
                wasUnstakedRecently[tokenId] = false;
            }
            else {
            calculatedDuration = (block.timestamp - lastClaimTime)/1 hours;//(60*60);
            }
            if (calculatedDuration >= 12) {
            calculatedDuration = calculatedDuration / 12; //todo 12
            uint toReturn = calculateFinalAmountInDays (calculatedDuration);
            return toReturn;
            } else {
                return 0;
            }
        }
    }

    function calculateFinalAmountInDays (uint _calculatedHour)internal pure returns (uint) {
        return _calculatedHour * 250 ether;
    }

    function executeClaims (uint randomNumber, uint tokenId, uint firstHold, uint secondHold) internal returns (bool) {
        if (randomNumber >=0 && randomNumber < firstHold) {
            bool query = onSuccess(tokenId);
            return query;
        }
        else if (randomNumber >= firstHold && randomNumber < secondHold) {
            bool query = onCriticalSuccess(tokenId);
            return query;
        }
        else {
            bool query = onCriticalFail(tokenId);
            return query;
        }
    }

    function onSuccess (uint tokenId) internal returns (bool) {
        (uint8 nftType,,,,) = metadataHandler.getToken(tokenId);
        require (lastClaim[tokenId] + 12 hours <= block.timestamp, "Claiming before 12 hours");
        uint calculatedValue = calculateSUP(tokenId);
        token.mintFromEngine(msg.sender, calculatedValue);
        lastClaim[tokenId] = block.timestamp;
        uint randomNumber = randomNumberGenerated.initiateRandomness(tokenId,nftToken.actionTimestamp(tokenId));
        randomNumber = uint(keccak256(abi.encodePacked(randomNumber,"1")))%100;
        if(randomNumber<32 && levelOfToken[tokenId] < 5){
            moveToLast(tokenId);
            levelOfToken[tokenId]++;
            determineAndPush(tokenId);
            nftToken.restrictedChangeNft(tokenId, nftType, uint8(levelOfToken[tokenId]), false, stakeTime[tokenId],lastClaim[tokenId]);
        }
        return false;
    }

    function onCriticalSuccess (uint tokenId) internal returns (bool) {
        (uint8 nftType,,,,) = metadataHandler.getToken(tokenId);
        require (lastClaim[tokenId] + 12 hours <= block.timestamp, "Claiming before 12 hours");
        token.mintFromEngine(msg.sender, calculateSUP(tokenId));
        lastClaim[tokenId] = block.timestamp;
        if (uint(keccak256(abi.encodePacked(randomNumberGenerated.initiateRandomness(tokenId,nftToken.actionTimestamp(tokenId)),"1")))%100 < 40 
        && levelOfToken[tokenId]<5) {
            moveToLast (tokenId);
            levelOfToken[tokenId]++;
            determineAndPush(tokenId);
            nftToken.restrictedChangeNft(tokenId, nftType, uint8(levelOfToken[tokenId]), false, stakeTime[tokenId],lastClaim[tokenId]);
        }
        uint value = howManyTokensCanSteal(nftType);

        uint stolenTokenId;

        for (uint i=0;i < value;i++) {
            stolenTokenId = steal(1-nftType,i+1);
            moveToLast(stolenTokenId);
            nftToken.restrictedChangeNft(stolenTokenId, nftType, uint8(levelOfToken[stolenTokenId]), false, stakeTime[tokenId],lastClaim[tokenId]);//s->1
            pool[nftType][uint8(levelOfToken[tokenId])].push(stolenTokenId);
            nftToken.tokenOwnerSetter(stolenTokenId, msg.sender);

        }
        return false;
        }

    function onCriticalFail(uint tokenId) internal returns (bool) {

            nftToken.burnNFT(tokenId);
            isStaked[tokenId] = false;
            moveToLast(tokenId);
            return true;
     }


    function claimStake ( uint tokenId ) internal returns (bool){
        uint randomNumber = randomNumberGenerated.initiateRandomness(tokenId,nftToken.actionTimestamp(tokenId))%100;
        (,uint8 level,,,) =
        metadataHandler.getToken(tokenId);
    
        if (stakeConfirmation[tokenId] == false) {
            require (block.timestamp >= firstStakeLockPeriod[tokenId],"lock not over");
            stakeConfirmation[tokenId] = true;
            if(isFrenzy()) {
                bool query =  executeClaims(randomNumber, tokenId, 55, 63+2*(level));
                return query;
            }
            else if(isAggression()){
                uint aggKicker = whichAggression();
                bool query = executeClaims(randomNumber, tokenId, 80-3*aggKicker, 85+2*(level));
                return query;
            }
            else {
                bool query =  executeClaims(randomNumber, tokenId, 80, 88+2*(level));
                return query;
            }
        }
        else {
            if(isFrenzy()){
                bool query = executeClaims(randomNumber, tokenId, 55, 63+2*(level));
                return query;
            }
            else if(isAggression()){
                uint aggKicker = whichAggression();
                bool query = executeClaims(randomNumber, tokenId, 80-3*aggKicker, 85+2*(level));
                return query;
            }
            else{
                bool query = executeClaims(randomNumber, tokenId, 80, 88+2*(level));
                return query;
            }
        }
    }

    function unstakeNFT ( uint tokenId ) internal {
        uint randomNumber = randomNumberGenerated.initiateRandomness(tokenId,nftToken.actionTimestamp(tokenId));
        if (stakeConfirmation[tokenId] == true) {
            uint level = levelOfToken[tokenId];
            uint burnPercent = unstakeBurnCalculator(uint8(level));
            if(randomNumber%100 <= burnPercent){
                nftToken.burnNFT(tokenId);
            }
            else {
                nftToken.safeTransferFrom(address(this), msg.sender, tokenId);
                wasUnstakedRecently[tokenId] = true;
            }
            moveToLast(tokenId);
        }
        else {
            uint burnPercent = unstakeBurnCalculator(1);
            if(randomNumber%100 <= burnPercent){
                nftToken.burnNFT(tokenId);
                
            }
            else{
                nftToken.safeTransferFrom(address(this), msg.sender, tokenId);
                wasUnstakedRecently[tokenId] = true;
            }
            moveToLast(tokenId);
        }
    }

    function claimAndUnstake (bool claim,uint[] memory tokenAmount) external nonReentrant{

        for (uint i=0;i<tokenAmount.length;i++) {
            require(nftToken.tokenOwnerCall(tokenAmount[i]) == msg.sender, "Caller not the owner");
            require(nftToken.ownerOf(tokenAmount[i]) == address(this),"Contract not the owner");
            require(isStaked[tokenAmount[i]] = true, "Not Staked");
            require (stakeTime[tokenAmount[i]]+ tokenToRandomHourInStake[tokenAmount[i]]<= block.timestamp,"Be Patient");
            if (claim == true) {
                claimStake(tokenAmount[i]);
            }
            else {
                bool isBurnt = claimStake(tokenAmount[i]);
                if (isBurnt == false)
                {
                    unstakeNFT(tokenAmount[i]);
                    isStaked[tokenAmount[i]] = false;
                }

            }
            nftToken.setTimeStamp(tokenAmount[i]);
        }
    }

    function totalStakedOfType(uint8 tokenType) public view returns(uint){       

        uint totalStaked; 
        for(uint8 j=1;j<6;j++){
                totalStaked += pool[tokenType][j].length;
        }
        return totalStaked;
        
    }
}