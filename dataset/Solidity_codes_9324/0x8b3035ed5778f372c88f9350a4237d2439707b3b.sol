



pragma solidity ^0.8.0;


interface IERC20 {

 function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function burnbyContract(uint256 _amount) external;

    function withdrawStakingReward(address _address,uint256 _amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}




interface IERC721 {

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
contract Ownable   {

    address public _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor()  {
        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);
    }


    function owner() public view returns (address) {

        return _owner;
    }


    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");

        _;
    }


    function transferOwnership(address newOwner) public onlyOwner {

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;
    }
}


contract SYAC_NFT_Staking is Ownable{

    using SafeMath for uint256;
    IERC721 NFTToken;
    IERC20 token;
    struct userInfo 
      {
        uint256 totlaWithdrawn;
        uint256 withdrawable;
        uint256 availableToWithdraw;
      }
    struct Stake {
    uint24 tokenId;
    uint48 timestamp;
    address owner;
  }
    mapping(address => mapping(uint256 => uint256)) public stakingTime;
    mapping(address => userInfo ) public User;
    mapping(uint256=>bool) public alreadyAwarded;
    mapping(address=>mapping(uint256=>uint256)) public depositTime;
    mapping(uint256=>Stake) public vault;
    uint256 time= 1 days;
    uint256 public totalSupply=3981;
    uint256 lockingtime= 1 days;
    uint256 public firstReward =300 ether;
    constructor(IERC721 _NFTToken,IERC20 _token)  
    {
        NFTToken   =_NFTToken;
        token=_token;
        
    }
    function balanceOf(address account) public view returns (uint256) {

    uint256 balance = 0;
    uint256 supply =totalSupply;
    for(uint i = 1; i <= supply; i++) {
      if (vault[i].owner == account) {
        balance += 1;
      }
    }
    return balance;
  }
   function userStakedNFT(address account) public view returns (uint256[] memory ownerTokens) {


    uint256 supply=totalSupply;
    uint256[] memory tmp = new uint256[](supply);

    uint256 index = 0;
    for(uint tokenId = 1; tokenId <= supply; tokenId++) {
      if (vault[tokenId].owner == account) {
        tmp[index] = vault[tokenId].tokenId;
        index +=1;
      }
    }

    uint256[] memory tokens = new uint256[](index);
    for(uint i = 0; i < index; i++) {
      tokens[i] = tmp[i];
    }

    return tokens;
  }

    function stake(uint256[] calldata tokenIds) external 
    { 

       uint256 tokenId;
       for(uint256 i=0;i<tokenIds.length;i++){
       tokenId = tokenIds[i];
       require(NFTToken.ownerOf(tokenId) == msg.sender,"nft not found");
       NFTToken.transferFrom(msg.sender,address(this),tokenId);
       vault[tokenId] = Stake({
        owner: msg.sender,
        tokenId: uint24(tokenId),
        timestamp: uint48(block.timestamp)
      });
       if(!alreadyAwarded[tokenId])depositTime[msg.sender][tokenId]=block.timestamp;
       }
    }
    function rewardOfUser(address Add) public view returns(uint256)
     {

        uint256 RewardToken;
        uint256[] memory AllStakedNft=userStakedNFT(Add);

        for(uint256 i = 0 ; i < AllStakedNft.length ; i++){
              if((block.timestamp>depositTime[Add][AllStakedNft[i]]+lockingtime)&&!alreadyAwarded[AllStakedNft[i]]){
              RewardToken+=firstReward;
              }
             RewardToken += (((block.timestamp - (vault[AllStakedNft[i]].timestamp)).div(time)))*15 ether;        
     }
    return RewardToken+User[Add].availableToWithdraw;
     }


   
    function WithdrawReward()  public 
      {

       uint256 reward = rewardOfUser(msg.sender);
       uint256[] memory allStakedNft=userStakedNFT(msg.sender);
       require(reward > 0,"you don't have reward yet!");
       require(token.balanceOf(address(token))>=reward,"Contract Don't have enough tokens to give reward");
       token.withdrawStakingReward(msg.sender,reward);
       for(uint8 i=0;i<allStakedNft.length;i++){
       vault[allStakedNft[i]].timestamp=uint48(block.timestamp);
       alreadyAwarded[allStakedNft[i]]=true;
       }
       User[msg.sender].totlaWithdrawn +=  reward;
       User[msg.sender].availableToWithdraw =  0;
      }


    function unstake(uint256[] memory _tokenId)  external 
        {

        User[msg.sender].availableToWithdraw+=rewardOfUser(msg.sender);
        uint256 tokenId;
        for(uint256 i=0;i<_tokenId.length;i++){
        tokenId=_tokenId[i];
        if(rewardOfUser(msg.sender)>0)alreadyAwarded[_tokenId[i]]=true;
        Stake memory staked = vault[tokenId];
        require(staked.owner == msg.sender, "not an owner");
        NFTToken.transferFrom(address(this),msg.sender,tokenId);
        delete vault[tokenId];
        }       
    }
    function isStaked(address _stakeHolder)public view returns(bool){

            if(userStakedNFT(_stakeHolder).length>0){
            return true;
            }else{
            return false;
          }
     }
    function totalStaked(address _stakeHolder)public view returns(uint256){

           return userStakedNFT(_stakeHolder).length;
     }
                                        
            function WithdrawToken()public onlyOwner{

            require(token.transfer(msg.sender,token.balanceOf(address(this))),"Token transfer Error!");
            } 
            function changeFirstReward(uint256 _reward)external onlyOwner{

             firstReward=_reward;
            }
            function setTotalSupply(uint256 _totalSupply)external onlyOwner{

                totalSupply=_totalSupply;
            }
            }