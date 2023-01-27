

pragma solidity ^0.5.0;

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


pragma solidity >=0.5.0;

interface IAgency {

    function register(string calldata _input) external pure returns(bytes32);

}


pragma solidity >=0.5.0;

interface IAgentRegistry {

    function agents() external returns (uint256);

    function register(string calldata _nameString) external payable;

    function getAgentAddressById(uint256 _agentId) external view returns (address payable);

    function getAgentAddressByName(bytes32 _agentName) external view returns (address payable);

    function isAgent(address _agent) external view returns (bool);

}


pragma solidity ^0.5.0;

contract ADDRESSBOOK {

    address constant public FEE_APPROVER = 0x6C70d504932AA318f8070De13F3c4Ab69A87953f;
    address payable constant public VAULT = 0xB1ff949285107B7b967c0d05886F2513488D0042;
    address constant public REWARDS_DISTRIBUTOR = 0xB3c39777142320F7C5329bF87287A707C77266e3;
    address constant public STAKING_CONTRACT = 0x29d44e1726e4368e5A7Abf4fbC481a874AebCf00;
    address constant public ZAP = 0x0797778B9110D03FF64fF25192e2a980Bf4523b8;
    address constant public TOKEN_ADDRESS_711 = 0x9d4709e7C38e7857636c342a37547E191125E028;
    address constant public AGENT_REGISTRY = 0x35C9Dbd51D926838cAc8eB33ebDbEA5e2930b247;
    address constant public UNISWAP_V2_PAIR_711_WETH = 0xF295b0fa1A89c8a06109fB2D2c860a96Fb39dca5;
}


pragma solidity 0.5.16;





contract AgentRegistry is IAgentRegistry, ADDRESSBOOK {

    using SafeMath for *;

    struct Player {
        uint256 id;             // agent id
        bytes32 name;           // agent name
        bool isAgent;           // referral activated
    }

    IAgency agency = IAgency(0x7Bc360ebD65eFa503FF189A0F81f61f85D310Ec3);
    address payable public vault;
    uint256 public agents;      // number of agent
    mapping(address => Player) public player;       // player data
    mapping(uint256 => address) public agentxID_;   // return agent address by id
    mapping(bytes32 => address) public agentxName_; // return agent address by name

    modifier isHuman() {

        require(msg.sender == tx.origin, "sorry humans only");
        _;
    }

    constructor() public {
        vault = VAULT;
    }

    function register(string calldata _nameString)
        external
        payable
        isHuman()
    {

        bytes32 _name = agency.register(_nameString);
        address _agent = msg.sender;
        require(msg.value >= 0.1 ether, "insufficient amount");
        require(agentxName_[_name] == address(0), "name registered");

        if(!player[_agent].isAgent){
            agents += 1;
            player[_agent].isAgent = true;
            player[_agent].id = agents;
            agentxID_[agents] = _agent;
        }
        player[_agent].name = _name;
        agentxName_[_name] = _agent;
        vault.transfer(msg.value);
    }

    function getAgentAddressById(uint256 _agentId) external view returns (address payable) {

        return address(uint160(agentxID_[_agentId]));
    }

    function getAgentAddressByName(bytes32 _agentName) external view returns (address payable) {

        return address(uint160(agentxName_[_agentName]));
    }

    function isAgent(address _agent) external view returns (bool) {

        return player[_agent].isAgent;
    }
}