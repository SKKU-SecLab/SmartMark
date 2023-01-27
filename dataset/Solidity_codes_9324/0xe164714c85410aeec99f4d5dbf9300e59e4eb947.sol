pragma solidity 0.8.4;

interface IToken {

    function mint(address _receiver, uint256 _amount) external;

    function burn(address _receiver, uint256 _amount) external;

}

contract GRODistributer {

    uint256 public constant DEFAULT_FACTOR = 1E18;
    uint256 public constant DAO_QUOTA = 8_000_000 * DEFAULT_FACTOR;
    uint256 public constant INVESTOR_QUOTA = 19_490_577 * DEFAULT_FACTOR;
    uint256 public constant TEAM_QUOTA = 22_509_423 * DEFAULT_FACTOR;
    uint256 public constant COMMUNITY_QUOTA = 45_000_000 * DEFAULT_FACTOR;

    IToken public immutable govToken;
    address public immutable DAO_VESTER;
    address public immutable INVESTOR_VESTER;
    address public immutable TEAM_VESTER;
    address public immutable COMMUNITY_VESTER;
    address public immutable BURNER;

    mapping(address => uint256) public mintingPools;

    constructor(address token, address[4] memory vesters, address burner) {
        govToken = IToken(token);
        
        DAO_VESTER = vesters[0];
        INVESTOR_VESTER = vesters[1];
        TEAM_VESTER = vesters[2];
        COMMUNITY_VESTER = vesters[3];
        BURNER = burner;
        
        mintingPools[vesters[0]] = DAO_QUOTA;
        mintingPools[vesters[1]] = INVESTOR_QUOTA;
        mintingPools[vesters[2]] = TEAM_QUOTA;
        mintingPools[vesters[3]] = COMMUNITY_QUOTA;
    }

    function mint(address account, uint256 amount) external {

        require(
            msg.sender == INVESTOR_VESTER ||
            msg.sender == TEAM_VESTER ||
            msg.sender == COMMUNITY_VESTER,
            'mint: msg.sender != vester'
        );
        uint256 available = mintingPools[msg.sender];
        mintingPools[msg.sender] = available - amount;
        govToken.mint(account, amount);
    }

    function mintDao(
        address account,
        uint256 amount,
        bool community
    ) external {

        require(msg.sender == DAO_VESTER, "mintDao: msg.sender != DAO_VESTER");
        address poolId = msg.sender;
        if (community) {
            poolId = COMMUNITY_VESTER;
        }
        uint256 available = mintingPools[poolId];
        mintingPools[poolId] = available - amount;
        govToken.mint(account, amount);
    }

    function burn(uint256 amount) external {

        require(msg.sender == BURNER, "burn: msg.sender != BURNER");
        govToken.burn(msg.sender, amount);
        mintingPools[COMMUNITY_VESTER] = mintingPools[COMMUNITY_VESTER] + amount;
    }
}