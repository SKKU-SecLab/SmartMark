

pragma solidity ^0.4.24;

contract IAuthority {

    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);

}


pragma solidity ^0.4.24;


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


pragma solidity ^0.4.24;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


pragma solidity ^0.4.24;



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


pragma solidity ^0.4.23;

contract IBurnableERC20 {

    function burn(address _from, uint _value) public;

}


pragma solidity ^0.4.24;

contract ISettingsRegistry {

    enum SettingsValueTypes { NONE, UINT, STRING, ADDRESS, BYTES, BOOL, INT }

    function addressOf(bytes32 _propertyName) public view returns (address);


    event ChangeProperty(bytes32 indexed _propertyName, uint256 _type);
}


pragma solidity ^0.4.24;

contract SettingIds {

    bytes32 public constant CONTRACT_RING_ERC20_TOKEN = "CONTRACT_RING_ERC20_TOKEN";

    bytes32 public constant CONTRACT_KTON_ERC20_TOKEN = "CONTRACT_KTON_ERC20_TOKEN";



    bytes32 public constant CONTRACT_CROSSCHAIN_TXFEES = "CONTRACT_CROSSCHAIN_TXFEES";
}


pragma solidity ^0.4.24;






contract TokenBuildInGenesis is DSAuth, SettingIds {

    event ClaimedTokens(address indexed token, address indexed owner, uint amount);

    event RingBuildInEvent(address indexed token, address indexed owner, uint amount, bytes data);

    event KtonBuildInEvent(address indexed token, address indexed owner, uint amount, bytes data);

    event SetStatus(bool status);

    ISettingsRegistry public registry;

    bool public paused = false;

    bool private singletonLock = false;

    modifier singletonLockCall() {

        require(!singletonLock, "Only can call once");
        _;
        singletonLock = true;
    }

    modifier isWork() {

        require(!paused, "Not started");
        _;
    }

    function initializeContract(address _registry, bool _status) public singletonLockCall{

        registry = ISettingsRegistry(_registry);
        paused = _status;
        owner = msg.sender;
    }

    function tokenFallback(address _from, uint256 _amount, bytes _data) public isWork{

        bytes32 darwiniaAddress;

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            darwiniaAddress := mload(add(ptr, 132))
        }

        address ring = registry.addressOf(SettingIds.CONTRACT_RING_ERC20_TOKEN);
        address kryptonite = registry.addressOf(SettingIds.CONTRACT_KTON_ERC20_TOKEN);

        require((msg.sender == ring) || (msg.sender == kryptonite), "Permission denied");

        require(_data.length == 32, "The address (Darwinia Network) must be in a 32 bytes hexadecimal format");
        require(darwiniaAddress != bytes32(0x0), "Darwinia Network Address can't be empty");

        if(ring == msg.sender) {
            IBurnableERC20(ring).burn(address(this), _amount);
            emit RingBuildInEvent(msg.sender, _from, _amount, _data);
        }

        if (kryptonite == msg.sender) {
            IBurnableERC20(kryptonite).burn(address(this), _amount);
            emit KtonBuildInEvent(msg.sender, _from, _amount, _data);
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

        emit ClaimedTokens(_token, owner, balance);
    }

    function setPaused(bool _status) public auth {

        paused = _status;
    }

    function togglePaused() public auth {

        paused = !paused;
    }
    
    function setRegistry(address _registry) public auth {

        registry = ISettingsRegistry(_registry);
    }
}