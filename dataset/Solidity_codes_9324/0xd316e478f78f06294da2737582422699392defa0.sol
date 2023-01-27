



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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

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



pragma solidity ^0.8.10;




contract rfacStaking{

    mapping(address => IERC20) public rewardToken;
    mapping(address => address) public tokenOwner;
    mapping(address => bool) public tokenState;
    address public stakingToken;
    uint256 public stakePrice;
    bool public paused;

    IERC721 public rfacNFT;
    address payable public owner;

    uint256 public rate; //$CHIPs per card per day
    mapping(uint256 => uint256) rewardTable; //Bonus tokens for each pokerHand, per day

    struct TokenData {
        uint256[] tokenIDs;
        uint256[] values;
        uint256[] suits;
        uint256 pokerHand;
    }

    struct Stake {
        uint256[] tokenIDs; //list of tokens in the hand
        uint256 timestamp;  //time staked
        uint256 pokerHand;  //value of the hand staked
    }

    mapping(address => Stake[]) public stakes;

    mapping(address => uint256) public bank;
    uint256 merkleRoot;
    mapping(uint256 => uint8) public proofBurn;

    event transferredRewardToBank(address _from, uint256 amt);
    event cashedOutFromBank(address _from, address _tokenAddress, uint256 amt);
    event cashedOutFromStaking(address _from, uint256 amt);
    event depositedToBank(address _from, address _tokenAddress, uint256 amt);
    event staked(address _from, uint256[] _tokenIDs);
    event unstaked(address _from, uint256[] _tokenIDs);

    constructor(){
        paused = false;
        stakePrice = 0.005 ether;
        rate = 5;
        owner = payable(msg.sender);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory) public pure returns(bytes4) {

        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function stake(TokenData[] calldata _tokenData) external payable{

        require(!paused,"Staking is paused");
        require(msg.value == stakePrice*_tokenData.length,"Insufficient Funds");

        for(uint256 n = 0;n < _tokenData.length;n++){
            require(_tokenData[n].tokenIDs.length < 6, "Too many cards.");
            require(checkHand(_tokenData[n]),"Pokerhand Doesn't Match");

            for (uint256 i = 0; i < _tokenData[n].tokenIDs.length; i++) {
                rfacNFT.safeTransferFrom(msg.sender, address(this), _tokenData[n].tokenIDs[i],"0x00");
            }
            stakes[msg.sender].push(Stake(_tokenData[n].tokenIDs,block.timestamp,_tokenData[n].pokerHand));
            emit staked(msg.sender, _tokenData[n].tokenIDs);
        }
        
    }

    function unstake(uint8[] calldata hands) external{

        require(!paused,"Staking is paused");
        cashOutFromStaking(hands);
        for(uint256 n = 0;n < hands.length;n++){
            for (uint256 i = 0; i < stakes[msg.sender][hands[n]].tokenIDs.length; i++) {
                rfacNFT.safeTransferFrom(address(this),msg.sender, stakes[msg.sender][hands[n]].tokenIDs[i],"0x00");
            }
            emit unstaked(msg.sender, stakes[msg.sender][hands[n]].tokenIDs);
            removeStakedHand(hands[n]);
        }
        
    }

    function checkHand(TokenData calldata _tokenData) internal pure returns (bool){


        if(_tokenData.pokerHand == 0){
            if(checkFlush(_tokenData) && _tokenData.tokenIDs.length == 5){
                if(_tokenData.values[0] == 1 && _tokenData.values[1] == 13 && _tokenData.values[2] == 12 && _tokenData.values[3] == 11 && _tokenData.values[4] == 10){
                    return true;
                }else{
                    return false;
                }
            }else{
                return false;
            }
        }else if(_tokenData.pokerHand == 1){
            if(checkFlush(_tokenData) && _tokenData.tokenIDs.length == 5){
                if(_tokenData.values[1] == _tokenData.values[0] - 1 && _tokenData.values[2] == _tokenData.values[0] - 2 && _tokenData.values[3] == _tokenData.values[0] - 3 && _tokenData.values[4] == _tokenData.values[0] - 4){
                    return true;
                }else{
                    return false;
                }
            }else{
                return false;
            }

        }else if(_tokenData.pokerHand == 2){
            if(_tokenData.tokenIDs.length > 3){
                if(_tokenData.values[1] == _tokenData.values[0] && _tokenData.values[2] == _tokenData.values[0] && _tokenData.values[3] == _tokenData.values[0]){
                    if((_tokenData.suits[0]+_tokenData.suits[1]+_tokenData.suits[2]+_tokenData.suits[3]) == 10 && (_tokenData.suits[0]*_tokenData.suits[1]*_tokenData.suits[2]*_tokenData.suits[3]) == 24){
                        return true;
                    }else{
                        return false;
                    }                        
                }else{
                    return false;
                }
            }else{
                return false;
            }
        }
        else if(_tokenData.pokerHand == 3){
            if(_tokenData.tokenIDs.length == 5){
                if(_tokenData.values[1] == _tokenData.values[0] && _tokenData.values[2] == _tokenData.values[0] && _tokenData.values[3] == _tokenData.values[4]){
                    if(_tokenData.suits[0] != _tokenData.suits[1] && _tokenData.suits[1] != _tokenData.suits[2] && _tokenData.suits[0] != _tokenData.suits[2] && _tokenData.suits[3] != _tokenData.suits[4]){
                        return true;
                    }else{
                        return false;
                    }                        
                }else{
                    return false;
                }
            }else{
                return false;
            }
        }
        else if(_tokenData.pokerHand == 4){
            if(checkFlush(_tokenData) && _tokenData.tokenIDs.length == 5){
                return true;
            }else{
                return false;
            }
        }
        else if(_tokenData.pokerHand == 5){
            if(_tokenData.tokenIDs.length == 5){
                if(_tokenData.values[0] == 1){
                    if(_tokenData.values[1] == 13 && _tokenData.values[2] == 12 && _tokenData.values[3] == 11 && _tokenData.values[4] == 10){
                        return true;
                    }else{
                        return false;
                    }
                }else{
                    if(_tokenData.values[1] == _tokenData.values[0] - 1 && _tokenData.values[2] == _tokenData.values[0] - 2 && _tokenData.values[3] == _tokenData.values[0] - 3 && _tokenData.values[4] == _tokenData.values[0] - 4){
                        return true;
                    }else{
                        return false;
                    }
                }
                
            }else{
                return false;
            }

        }
        else if(_tokenData.pokerHand == 6){
            if(_tokenData.tokenIDs.length > 2){
                if(_tokenData.values[1] == _tokenData.values[0] && _tokenData.values[2] == _tokenData.values[0]){
                    if(_tokenData.suits[0] != _tokenData.suits[1] && _tokenData.suits[1] != _tokenData.suits[2] && _tokenData.suits[0] != _tokenData.suits[2]){
                        return true;
                    }else{
                        return false;
                    }                        
                }else{
                    return false;
                }
            }else{
                return false;
            }

        }else if(_tokenData.pokerHand == 7){
            if(_tokenData.tokenIDs.length > 3){
                if(_tokenData.values[1] == _tokenData.values[0] && _tokenData.values[2] == _tokenData.values[3]){
                    if(_tokenData.suits[0] != _tokenData.suits[1] && _tokenData.suits[2] != _tokenData.suits[3]){
                        return true;
                    }else{
                        return false;
                    }                        
                }else{
                    return false;
                }
            }else{
                return false;
            }

        }
        else if(_tokenData.pokerHand == 8){
            if(_tokenData.tokenIDs.length > 1){
                if(_tokenData.values[1] == _tokenData.values[0] && _tokenData.suits[0] != _tokenData.suits[1]){
                    return true;                     
                }else{
                    return false;
                }
            }else{
                return false;
            }
        }else{
            return true;
        }
    }

    function checkFlush(TokenData calldata _tokenData) internal pure returns (bool){

        uint256 flush;
        for (uint256 i = 0; i < _tokenData.tokenIDs.length; i++) {
            if(i == 0){
                flush = _tokenData.suits[i];
            }else if(flush != _tokenData.suits[i]){
                return false;
            }
        }
        return true;
    }

    function getStaked(address staker) external view returns(Stake [] memory){

            
        return (stakes[staker]);
    }

    function getReward(address staker, uint256 hand) public view returns(uint256){

        uint256 nDays = ((block.timestamp - stakes[staker][hand].timestamp) - (block.timestamp - stakes[staker][hand].timestamp) % (1 days))/(1 days);
        return (rate*stakes[staker][hand].tokenIDs.length+ rewardTable[stakes[staker][hand].pokerHand])*nDays;
    }


    function depositToken(address _tokenAddress, uint256 _deposit) external{

        require(!paused,"Contract is paused");
        require(rewardToken[_tokenAddress].transferFrom(msg.sender, address(this), _deposit), "Error with token transfer");
        bank[_tokenAddress] += _deposit;
        emit depositedToBank(msg.sender, _tokenAddress, _deposit);
    }

    function getBankBalance(address _tokenAddress) external view returns(uint256){

        return(bank[_tokenAddress]);
    }

    function cashOutFromStaking(uint8[] calldata hands) public{

        require(!paused,"Contract is paused");
        uint256 reward = 1;
        for(uint256 i = 0;i< hands.length;i++){
            reward += getReward(msg.sender,i);
            stakes[msg.sender][i].timestamp = block.timestamp;
        }
        rewardToken[stakingToken].approve(address(this),reward);
        require(rewardToken[stakingToken].transferFrom(address(this),msg.sender, reward-1), "Error with token transfer");
        bank[stakingToken] -= reward-1;
        emit cashedOutFromStaking(msg.sender, reward);
    }

    function cashOutFromBank(uint _value, uint[] calldata _proof, address _tokenAddress, uint256 amt) external{

        require(!paused,"Contract is paused");
        require(proofBurn[_value] == 0,"Proof Already Used");
        require(verifyProof( _value, _proof),"Invalid Proof");
        rewardToken[stakingToken].approve(address(this),amt);
        require(tokenState[_tokenAddress],"Token Withdrawls not permitted, Contact Token Owner");
        require(rewardToken[_tokenAddress].transferFrom(address(this),msg.sender, amt), "Error with token transfer");
        bank[_tokenAddress] -= amt;
        proofBurn[_value] = 1;
        emit cashedOutFromBank(msg.sender, _tokenAddress, amt);
    }

    function transferRewardToBank(uint8[] calldata hands) external{

        require(!paused,"Contract is paused");
        uint256 reward = 1;
        for(uint256 i = 0;i< hands.length;i++){
            reward += getReward(msg.sender,i);
            stakes[msg.sender][i].timestamp = block.timestamp;
        }
        reward -= 1;
        emit transferredRewardToBank(msg.sender, reward);
    }

    modifier onlyOwner(){

        require(msg.sender == owner,"not owner");
        _;
    }


    function setTokenAddress(address _tokenAddress, address _tokenOwner) external onlyOwner {

        rewardToken[_tokenAddress] = IERC20(_tokenAddress);
        if(tokenOwner[_tokenAddress] == address(0)){
            tokenOwner[_tokenAddress] = _tokenOwner;
        }
    }

    function setStakingToken(address _tokenAddress) external onlyOwner{

        stakingToken = _tokenAddress;
        rewardToken[_tokenAddress] = IERC20(_tokenAddress);
        if(tokenOwner[_tokenAddress] == address(0)){
            tokenOwner[_tokenAddress] = owner;
        }
    }

    function setNFTAddress(address _NFTAddress) external onlyOwner {

        rfacNFT = IERC721(_NFTAddress);
    }

    function setRewardTable(uint256[] calldata _rewardTable) external onlyOwner {

        for (uint256 i = 0; i < _rewardTable.length; i++) {
            rewardTable[i] = _rewardTable[i];
        }
    }

    function setRate(uint256 _rate) external onlyOwner {

        rate = _rate;
    }

    function togglePaused() external onlyOwner {

        paused = !paused;
    }

    function setStakePrice(uint256 _stakePrice) external onlyOwner {

        stakePrice = _stakePrice;
    }

    function removeStakedHand(uint hand) internal {

        require(hand <= stakes[msg.sender].length);
        stakes[msg.sender][hand] = stakes[msg.sender][stakes[msg.sender].length-1];
        stakes[msg.sender].pop();
    }


    function setTokenState(address _tokenAddress, bool _state) external{

        require(msg.sender == tokenOwner[_tokenAddress],"not owner");
        tokenState[_tokenAddress] = _state;
    }

    function setTokenOwner(address _tokenAddress, address _newOwner) external{

        require(msg.sender == tokenOwner[_tokenAddress],"not owner");
        tokenOwner[_tokenAddress] = _newOwner;
    }

    function withdraw() external payable onlyOwner{

        uint amount = address(this).balance;

        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    function getRoot() public view returns (uint) {

      return merkleRoot;
    }

    function setRoot(uint _merkleRoot) external onlyOwner{

      merkleRoot = _merkleRoot;
    }   // setRoot

    function pairHash(uint _a, uint _b) internal pure returns(uint) {

      return uint(keccak256(abi.encode(_a ^ _b)));
    }

    function verifyProof(uint _value, uint[] calldata _proof) 
        public view returns (bool) {

      uint temp = _value;
      uint i;
  
      for(i=0; i<_proof.length; i++) {
        temp = pairHash(temp, _proof[i]);
      }

      return temp == merkleRoot;
    }

}