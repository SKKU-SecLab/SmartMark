pragma solidity 0.5.7;

contract Deployer {

    event InstanceDeployed(address instance);
    
    function deploy(
        address _logic
    ) 
      internal 
      returns (address instance) 
    {

        bytes20 targetBytes = bytes20(_logic);
        assembly {
          let clone := mload(0x40)
          mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
          mstore(add(clone, 0x14), targetBytes)
          mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
          instance := create(0, clone, 0x37)
        }
        emit InstanceDeployed(address(instance));
    }
}pragma solidity >=0.5.0;

interface IERC20Template {

    function initialize(
        string calldata name,
        string calldata symbol,
        address minter,
        uint256 cap,
        string calldata blob,
        address collector
    ) external returns (bool);


    function mint(address account, uint256 value) external;

    function minter() external view returns(address);    

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function cap() external view returns (uint256);

    function isMinter(address account) external view returns (bool);

    function isInitialized() external view returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function proposeMinter(address newMinter) external;

    function approveMinter() external;

}pragma solidity 0.5.7;


contract DTFactory is Deployer {

    address private tokenTemplate;
    address private communityFeeCollector;
    uint256 private currentTokenCount = 1;

    event TokenCreated(
        address indexed newTokenAddress,
        address indexed templateAddress,
        string indexed tokenName
    );

    event TokenRegistered(
        address indexed tokenAddress,
        string tokenName,
        string tokenSymbol,
        uint256 tokenCap,
        address indexed registeredBy,
        string indexed blob
    );

    constructor(
        address _template,
        address _collector
    ) public {
        require(
            _template != address(0) &&
            _collector != address(0),
            'DTFactory: Invalid template token/community fee collector address'
        );
        tokenTemplate = _template;
        communityFeeCollector = _collector;
    }

    function createToken(
        string memory blob,
        string memory name,
        string memory symbol,
        uint256 cap
    )
        public
        returns (address token)
    {

        require(
            cap != 0,
            'DTFactory: zero cap is not allowed'
        );

        token = deploy(tokenTemplate);

        require(
            token != address(0),
            'DTFactory: Failed to perform minimal deploy of a new token'
        );
        IERC20Template tokenInstance = IERC20Template(token);
        require(
            tokenInstance.initialize(
                name,
                symbol,
                msg.sender,
                cap,
                blob,
                communityFeeCollector
            ),
            'DTFactory: Unable to initialize token instance'
        );
        emit TokenCreated(token, tokenTemplate, name);
        emit TokenRegistered(
            token,
            name,
            symbol,
            cap,
            msg.sender,
            blob
        );
        currentTokenCount += 1;
    }

    function getCurrentTokenCount() external view returns (uint256) {

        return currentTokenCount;
    }

    function getTokenTemplate() external view returns (address) {

        return tokenTemplate;
    }
}