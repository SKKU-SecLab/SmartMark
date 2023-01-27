



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
        uint256 totalStaked;
        uint256 availableToWithdraw;
      }
    mapping(address => mapping(uint256 => uint256)) public stakingTime;
    mapping(address => userInfo ) public User;
    mapping(address => uint256[] ) public Tokenid;
    mapping(address=>uint256) public totalStakedNft;
    mapping(uint256=>bool) public alreadyAwarded;
    mapping(address=>mapping(uint256=>uint256)) public depositTime;

    uint256 time= 1 days;
    uint256 lockingtime= 1 days;
    uint256 public firstReward =300 ether;
    constructor(IERC721 _NFTToken,IERC20 _token)  
    {
        NFTToken   =_NFTToken;
        token=_token;
        
    }
    function Stake(uint256[] memory tokenId) external 
    {

       for(uint256 i=0;i<tokenId.length;i++){
       require(NFTToken.ownerOf(tokenId[i]) == msg.sender,"nft not found");
       NFTToken.transferFrom(msg.sender,address(this),tokenId[i]);
       Tokenid[msg.sender].push(tokenId[i]);
       stakingTime[msg.sender][tokenId[i]]=block.timestamp;
       if(!alreadyAwarded[tokenId[i]]){
       depositTime[msg.sender][tokenId[i]]=block.timestamp;
       
       }
       }
       
       User[msg.sender].totalStaked+=tokenId.length;
       totalStakedNft[msg.sender]+=tokenId.length;

    }
    function rewardOfUser(address Add) public view returns(uint256)
     {

        uint256 RewardToken;
        for(uint256 i = 0 ; i < Tokenid[Add].length ; i++){
            if(Tokenid[Add][i] > 0)
            {
              if((block.timestamp>depositTime[Add][Tokenid[Add][i]]+1 days)&&!alreadyAwarded[Tokenid[Add][i]]){
              RewardToken+=firstReward;
              }
             RewardToken += (((block.timestamp - (stakingTime[Add][Tokenid[Add][i]])).div(time)))*15 ether;     
            }
     }
    return RewardToken+User[Add].availableToWithdraw;
     }

              function userStakedNFT(address _staker)public view returns(uint256[] memory)
       {

       return Tokenid[_staker];
       }
   
    function WithdrawReward()  public 
      {

       uint256 reward = rewardOfUser(msg.sender);
       require(reward > 0,"you don't have reward yet!");
       require(token.balanceOf(address(token))>=reward,"Contract Don't have enough tokens to give reward");
       token.withdrawStakingReward(msg.sender,reward);
       for(uint8 i=0;i<Tokenid[msg.sender].length;i++){
       stakingTime[msg.sender][Tokenid[msg.sender][i]]=block.timestamp;
       }
       User[msg.sender].totlaWithdrawn +=  reward;
       User[msg.sender].availableToWithdraw =  0;
       for(uint256 i = 0 ; i < Tokenid[msg.sender].length ; i++){
        alreadyAwarded[Tokenid[msg.sender][i]]=true;
       }
      }


    
    function find(uint value) internal  view returns(uint) {

        uint i = 0;
        while (Tokenid[msg.sender][i] != value) {
            i++;
        }
        return i;
     }

    function unstake(uint256[] memory _tokenId)  external 
        {

        User[msg.sender].availableToWithdraw+=rewardOfUser(msg.sender);
        for(uint256 i=0;i<_tokenId.length;i++){
        if(rewardOfUser(msg.sender)>0)alreadyAwarded[_tokenId[i]]=true;
        uint256 _index=find(_tokenId[i]);
        require(Tokenid[msg.sender][_index] ==_tokenId[i] ,"NFT with this _tokenId not found");
        NFTToken.transferFrom(address(this),msg.sender,_tokenId[i]);
        delete Tokenid[msg.sender][_index];
        Tokenid[msg.sender][_index]=Tokenid[msg.sender][Tokenid[msg.sender].length-1];
        stakingTime[msg.sender][_tokenId[i]]=0;
        Tokenid[msg.sender].pop();
        }
        User[msg.sender].totalStaked-=_tokenId.length;
        totalStakedNft[msg.sender]>0?totalStakedNft[msg.sender]-=_tokenId.length:totalStakedNft[msg.sender]=0;
       
    }
    function isStaked(address _stakeHolder)public view returns(bool){

            if(totalStakedNft[_stakeHolder]>0){
            return true;
            }else{
            return false;
          }
     }

                                        
            function WithdrawToken()public onlyOwner{

            require(token.transfer(msg.sender,token.balanceOf(address(this))),"Token transfer Error!");
            } 
            function changeFirstReward(uint256 _reward)external onlyOwner{

             firstReward=_reward;
            }
            }