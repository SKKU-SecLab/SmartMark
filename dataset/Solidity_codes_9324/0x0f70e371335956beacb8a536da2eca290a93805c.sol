


pragma solidity 0.8.4;

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



library SafeMath {


    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}




contract FolkitoTimelock {

    using SafeMath for uint256;
    
    
    uint256 tokenBalance;
    IERC20 public _tokenInstance;


    address public owner;



    address public teamAndAdvisorWallet;
    address public marketingWallet;
    address public privateSaleWallet;
    address public whitelistingWallet;
    address public airdropWallet;
    address public publicWallet;

    
    
    uint256 public constant TEAM_AND_ADVISOR_SHARE = 20000000 *10**18;
    uint256 public constant AIRDROP_SHARE = 1600000 *10**18;
    uint256 public constant PRIVATE_SALE_SHARE = 5000000*10**18;



    uint256 public constant MARKETING_SHARE =2500000*10**18;
    uint256 public constant WHITELISTING_SHARE =6000000*10**18;
    uint256 public constant PUBLIC_SHARE =4000000*10**18;

    uint256 public TOTAL_DISTRIBUTION =TEAM_AND_ADVISOR_SHARE.add(AIRDROP_SHARE)
                                        .add(PRIVATE_SALE_SHARE).add(MARKETING_SHARE).add(WHITELISTING_SHARE)
                                        .add(PUBLIC_SHARE);

    uint256 public  teamWalletClaimed;
    uint256 public  airdropWalletClaimed;
    uint256 public  privateSaleWalletClaimed;
    uint256 public  whitelistingWalletClaimed;
    uint256 public  marketingWalletClaimed;

    uint256 public  publicWalletClaimed;

    
    uint256 public teamReserveReleaseTime;
    uint256 public airdropReserveReleaseTime;
    uint256 public privateSaleReserveReleaseTime;
    uint256 public whitelistingReleaseTime;
    uint256 public marketingReserveReleaseTime;
    uint256 public publicReserveReleaseTime;

    uint256 public ONE_DAY = 1 days;
    
    

      modifier onlyOwner {

        require(msg.sender == owner,"You are not authorized");
        _;
    }

  
    constructor(address tokenInstance,
    
        address _teamAndAdvisorWallet,
        address _airdropWallet,
        address _marketingWallet,
        address _privateSaleWallet,
        address _whitelistingWallet,
        address _publicWallet
    
    
    
        ) {
        teamAndAdvisorWallet = _teamAndAdvisorWallet;
        privateSaleWallet = _privateSaleWallet;
        whitelistingWallet = _whitelistingWallet;
        airdropWallet = _airdropWallet;
        marketingWallet = _marketingWallet;
        publicWallet = _publicWallet;

        owner = msg.sender;
        teamReserveReleaseTime = block.timestamp.add(ONE_DAY.mul(180));

        marketingReserveReleaseTime = block.timestamp.add(ONE_DAY.mul(30));

        airdropReserveReleaseTime = block.timestamp.add(ONE_DAY.mul(180));
        privateSaleReserveReleaseTime= block.timestamp;
        whitelistingReleaseTime = block.timestamp;
        publicReserveReleaseTime = block.timestamp;

        _tokenInstance = IERC20(address(tokenInstance));
        
    


        
    }
    
    
    
    function getContractBalance() public view returns (uint256){

        return _tokenInstance.balanceOf(address(this));
    }
    
    
    
    function claimAirdropShare() public onlyOwner{

        require(block.timestamp>airdropReserveReleaseTime,"Lock Period has not passed");
        
        uint256 amount  = AIRDROP_SHARE;
        require(airdropWalletClaimed.add(amount)<=AIRDROP_SHARE,"Amount Exceeds");
        airdropWalletClaimed = airdropWalletClaimed.add(amount);
        _tokenInstance.transfer(airdropWallet,amount);

    }




      function claimPublicShare() public onlyOwner{

        require(block.timestamp>publicReserveReleaseTime,"Lock Period has not passed");
        
        uint256 amount  = PUBLIC_SHARE;
        require(publicWalletClaimed.add(amount)<=PUBLIC_SHARE,"Amount Exceeds");
        publicWalletClaimed = publicWalletClaimed.add(amount);
        _tokenInstance.transfer(publicWallet,amount);

    }
    

    
    
    
    function claimMarketingShare() public onlyOwner{

        require(block.timestamp>marketingReserveReleaseTime,"Lock Period has not passed");
        uint256 amount  =MARKETING_SHARE.mul(10).div(100);

        require(marketingWalletClaimed.add(amount)<=MARKETING_SHARE,"Amount Exceeds");

        marketingWalletClaimed = marketingWalletClaimed.add(amount);
        _tokenInstance.transfer(marketingWallet,amount);
        marketingReserveReleaseTime = marketingReserveReleaseTime.add(ONE_DAY.mul(30));
        
    }
    
    
    function claimPrivateSaleShare() public onlyOwner{

        require(block.timestamp>privateSaleReserveReleaseTime,"Lock Period has not passed");

        uint256 amount  = PRIVATE_SALE_SHARE.mul(20).div(100);

        require(privateSaleWalletClaimed.add(amount)<=PRIVATE_SALE_SHARE,"Amount Exceeds");

        privateSaleWalletClaimed = privateSaleWalletClaimed.add(amount);
        _tokenInstance.transfer(privateSaleWallet,amount);
        privateSaleReserveReleaseTime = privateSaleReserveReleaseTime.add(ONE_DAY.mul(30));

    }
    
    
    
    function claimWhitelistingShare() public onlyOwner{

        require(block.timestamp>whitelistingReleaseTime,"Lock Period has not passed");

        uint256 amount  = WHITELISTING_SHARE.mul(20).div(100);

        require(whitelistingWalletClaimed.add(amount)<=WHITELISTING_SHARE,"Amount Exceeds");

        whitelistingWalletClaimed = whitelistingWalletClaimed.add(amount);
        _tokenInstance.transfer(whitelistingWallet,amount);
        whitelistingReleaseTime = whitelistingReleaseTime.add(ONE_DAY.mul(30));

    }
    
    
    function claimTeamAndAdvisorShare() public onlyOwner{

        require(block.timestamp>teamReserveReleaseTime,"Lock Period has not passed");
        uint256 amount  = TEAM_AND_ADVISOR_SHARE.div(24);

        require(teamWalletClaimed.add(amount)<=TEAM_AND_ADVISOR_SHARE,"Amount Exceeds");

        teamWalletClaimed = teamWalletClaimed.add(amount);
        _tokenInstance.transfer(teamAndAdvisorWallet,amount);
        teamReserveReleaseTime = teamReserveReleaseTime.add(ONE_DAY.mul(30));

    }
    
    
    
    
    
    
    
    
    
    
    
}