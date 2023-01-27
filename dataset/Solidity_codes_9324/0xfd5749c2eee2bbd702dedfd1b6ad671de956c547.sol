


contract ISettingsRegistry {

    enum SettingsValueTypes { NONE, UINT, STRING, ADDRESS, BYTES, BOOL, INT }

    function uintOf(bytes32 _propertyName) public view returns (uint256);


    function stringOf(bytes32 _propertyName) public view returns (string);


    function addressOf(bytes32 _propertyName) public view returns (address);


    function bytesOf(bytes32 _propertyName) public view returns (bytes);


    function boolOf(bytes32 _propertyName) public view returns (bool);


    function intOf(bytes32 _propertyName) public view returns (int);


    function setUintProperty(bytes32 _propertyName, uint _value) public;


    function setStringProperty(bytes32 _propertyName, string _value) public;


    function setAddressProperty(bytes32 _propertyName, address _value) public;


    function setBytesProperty(bytes32 _propertyName, bytes _value) public;


    function setBoolProperty(bytes32 _propertyName, bool _value) public;


    function setIntProperty(bytes32 _propertyName, int _value) public;


    function getValueTypeOf(bytes32 _propertyName) public view returns (uint /* SettingsValueTypes */ );


    event ChangeProperty(bytes32 indexed _propertyName, uint256 _type);
}




contract ERC223ReceivingContract {


    function tokenFallback(address _from, uint256 _value, bytes _data) public;


}




contract ERC223 {

    function transfer(address to, uint amount, bytes data) public returns (bool ok);


    function transferFrom(address from, address to, uint256 amount, bytes data) public returns (bool ok);


    event ERC223Transfer(address indexed from, address indexed to, uint amount, bytes data);
}




contract IUserPoints {

    event AddedPoints(address indexed user, uint256 pointAmount);
    event SubedPoints(address indexed user, uint256 pointAmount);

    function addPoints(address _user, uint256 _pointAmount) public;


    function subPoints(address _user, uint256 _pointAmount) public;


    function pointsSupply() public view returns (uint256);


    function pointsBalanceOf(address _user) public view returns (uint256);

}




contract IAuthority {

    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);

}




contract DSAuthEvents {

    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {

    IAuthority   public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {

        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(IAuthority authority_)
        public
        auth
    {

        authority = authority_;
        emit LogSetAuthority(authority);
    }

    modifier auth {

        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {

        if (src == owner) {
            return true;
        } else if (authority == IAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}





contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}






contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}




contract SettingIds {

    bytes32 public constant CONTRACT_RING_ERC20_TOKEN = "CONTRACT_RING_ERC20_TOKEN";

    bytes32 public constant CONTRACT_KTON_ERC20_TOKEN = "CONTRACT_KTON_ERC20_TOKEN";

    bytes32 public constant CONTRACT_GOLD_ERC20_TOKEN = "CONTRACT_GOLD_ERC20_TOKEN";

    bytes32 public constant CONTRACT_WOOD_ERC20_TOKEN = "CONTRACT_WOOD_ERC20_TOKEN";

    bytes32 public constant CONTRACT_WATER_ERC20_TOKEN = "CONTRACT_WATER_ERC20_TOKEN";

    bytes32 public constant CONTRACT_FIRE_ERC20_TOKEN = "CONTRACT_FIRE_ERC20_TOKEN";

    bytes32 public constant CONTRACT_SOIL_ERC20_TOKEN = "CONTRACT_SOIL_ERC20_TOKEN";

    bytes32 public constant CONTRACT_OBJECT_OWNERSHIP = "CONTRACT_OBJECT_OWNERSHIP";

    bytes32 public constant CONTRACT_TOKEN_LOCATION = "CONTRACT_TOKEN_LOCATION";

    bytes32 public constant CONTRACT_LAND_BASE = "CONTRACT_LAND_BASE";

    bytes32 public constant CONTRACT_USER_POINTS = "CONTRACT_USER_POINTS";

    bytes32 public constant CONTRACT_INTERSTELLAR_ENCODER = "CONTRACT_INTERSTELLAR_ENCODER";

    bytes32 public constant CONTRACT_DIVIDENDS_POOL = "CONTRACT_DIVIDENDS_POOL";

    bytes32 public constant CONTRACT_TOKEN_USE = "CONTRACT_TOKEN_USE";

    bytes32 public constant CONTRACT_REVENUE_POOL = "CONTRACT_REVENUE_POOL";

    bytes32 public constant CONTRACT_ERC721_BRIDGE = "CONTRACT_ERC721_BRIDGE";

    bytes32 public constant CONTRACT_PET_BASE = "CONTRACT_PET_BASE";

    bytes32 public constant UINT_AUCTION_CUT = "UINT_AUCTION_CUT";  // Denominator is 10000

    bytes32 public constant UINT_TOKEN_OFFER_CUT = "UINT_TOKEN_OFFER_CUT";  // Denominator is 10000

    bytes32 public constant UINT_REFERER_CUT = "UINT_REFERER_CUT";

    bytes32 public constant CONTRACT_LAND_RESOURCE = "CONTRACT_LAND_RESOURCE";
}




contract AuctionSettingIds is SettingIds {


    bytes32 public constant CONTRACT_CLOCK_AUCTION = "CONTRACT_CLOCK_AUCTION";

    bytes32 public constant UINT_AUCTION_BID_WAITING_TIME = "UINT_AUCTION_BID_WAITING_TIME";


    bytes32 public constant CONTRACT_MYSTERIOUS_TREASURE = "CONTRACT_MYSTERIOUS_TREASURE";

    bytes32 public constant CONTRACT_BANCOR_EXCHANGE = "BANCOR_EXCHANGE";

    bytes32 public constant CONTRACT_POINTS_REWARD_POOL = "CONTRACT_POINTS_REWARD_POOL";

    bytes32 public constant UINT_EXCHANGE_ERROR_SPACE = "UINT_EXCHANGE_ERROR_SPACE";

    bytes32 public constant CONTRACT_CONTRIBUTION_INCENTIVE_POOL = "CONTRACT_CONTRIBUTION_POOL";

    bytes32 public constant CONTRACT_DEV_POOL = "CONTRACT_DEV_POOL";

}




contract IGovernorPool {

    function checkRewardAvailable(address _token) external view returns(bool);

    function rewardAmount(uint256 _amount) external; 

}



pragma solidity ^0.4.24;



contract RevenuePoolV2 is DSAuth, ERC223ReceivingContract, AuctionSettingIds {


    bool private singletonLock = false;


    ISettingsRegistry public registry;

    event ClaimedTokens(address indexed token, address indexed owner, uint amount);

    modifier singletonLockCall() {

        require(!singletonLock, "Only can call once");
        _;
        singletonLock = true;
    }

    function initializeContract(address _registry) public singletonLockCall {

        owner = msg.sender;
        emit LogSetOwner(msg.sender);

        registry = ISettingsRegistry(_registry);
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public {


        address ring = registry.addressOf(SettingIds.CONTRACT_RING_ERC20_TOKEN);
        address userPoints = registry.addressOf(SettingIds.CONTRACT_USER_POINTS);

        if(msg.sender == ring) {
            address buyer = bytesToAddress(_data);

            IUserPoints(userPoints).addPoints(buyer, _value / 1000);
        }
    }


    function settleToken(address _tokenAddress) public {

        uint balance = ERC20(_tokenAddress).balanceOf(address(this));

        if (balance > 10) {
            address pointsRewardPool = registry.addressOf(AuctionSettingIds.CONTRACT_POINTS_REWARD_POOL);
            address contributionIncentivePool = registry.addressOf(AuctionSettingIds.CONTRACT_CONTRIBUTION_INCENTIVE_POOL);
            address governorPool = registry.addressOf(CONTRACT_DIVIDENDS_POOL);
            address devPool = registry.addressOf(AuctionSettingIds.CONTRACT_DEV_POOL);

            require(pointsRewardPool != 0x0 && contributionIncentivePool != 0x0 && governorPool != 0x0 && devPool != 0x0, "invalid addr");

            require(ERC223(_tokenAddress).transfer(pointsRewardPool, balance / 10, "0x0"));
            require(ERC223(_tokenAddress).transfer(contributionIncentivePool, balance * 3 / 10, "0x0"));
            if (IGovernorPool(governorPool).checkRewardAvailable(_tokenAddress)) {
                ERC20(_tokenAddress).approve(governorPool, balance * 3 / 10);
                IGovernorPool(governorPool).rewardAmount(balance * 3 / 10);
            }
            require(ERC223(_tokenAddress).transfer(devPool, balance * 3 / 10, "0x0"));
        }

    }


    function claimTokens(address _token) public auth {

        if (_token == 0x0) {
            owner.transfer(address(this).balance);
            return;
        }
        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(address(this));
        token.transfer(owner, balance);

        emit ClaimedTokens(_token, msg.sender, balance);
    }

    function bytesToAddress(bytes b) public pure returns (address) {

        bytes32 out;

        for (uint i = 0; i < 32; i++) {
            out |= bytes32(b[i] & 0xFF) >> (i * 8);
        }
        return address(out);
    }

}