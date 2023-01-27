




pragma solidity =0.8.6;

interface IDistro {

    event Claim(address indexed grantee, uint256 amount);
    event Allocate(
        address indexed distributor,
        address indexed grantee,
        uint256 amount
    );
    event Assign(
        address indexed admin,
        address indexed distributor,
        uint256 amount
    );
    event ChangeAddress(address indexed oldAddress, address indexed newAddress);

    event StartTimeChanged(uint256 newStartTime, uint256 newCliffTime);

    function totalTokens() external view returns (uint256);


    function setStartTime(uint256 newStartTime) external;


    function assign(address distributor, uint256 amount) external;


    function claim() external;


    function allocate(
        address recipient,
        uint256 amount,
        bool claim
    ) external;


    function allocateMany(address[] memory recipients, uint256[] memory amounts)
        external;


    function sendGIVbacks(address[] memory recipients, uint256[] memory amounts)
        external;


    function changeAddress(address newAddress) external;


    function getTimestamp() external view returns (uint256);


    function globallyClaimableAt(uint256 timestamp)
        external
        view
        returns (uint256);


    function claimableAt(address recipient, uint256 timestamp)
        external
        view
        returns (uint256);


    function claimableNow(address recipient) external view returns (uint256);


    function cancelAllocation(address prevRecipient, address newRecipient)
        external;

}




pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}




pragma solidity ^0.8.0;


abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}




pragma solidity ^0.8.0;



abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}




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




pragma solidity 0.8.6;




contract UniswapV3RewardToken is IERC20, OwnableUpgradeable {

    uint256 public initialBalance;

    string public constant name = "Giveth Uniswap V3 Reward Token";
    string public constant symbol = "GUR";
    uint8 public constant decimals = 18;

    IDistro public tokenDistro;
    address public uniswapV3Staker;
    uint256 public override totalSupply;

    bool public disabled;

    event RewardPaid(address indexed user, uint256 reward);

    event InvalidRewardPaid(address indexed user, uint256 reward);

    event Disabled(address account);

    event Enabled(address account);

    function initialize(IDistro _tokenDistribution, address _uniswapV3Staker)
        public
        initializer
    {

        __Ownable_init();
        tokenDistro = _tokenDistribution;
        uniswapV3Staker = _uniswapV3Staker;
    }

    function balanceOf(address account) public view override returns (uint256) {

        if (account == uniswapV3Staker) return totalSupply;
        return 0;
    }

    function approve(address, uint256) external pure override returns (bool) {

        return true;
    }

    function transfer(address to, uint256 value)
        external
        override
        returns (bool)
    {

        require(
            msg.sender == uniswapV3Staker,
            "GivethUniswapV3Reward:transfer:ONLY_STAKER"
        );

        totalSupply = totalSupply - value;
        if (!disabled) {
            tokenDistro.allocate(to, value, true);
            emit RewardPaid(to, value);
        } else {
            emit InvalidRewardPaid(to, value);
        }

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {

        require(
            from == owner(),
            "GivethUniswapV3Reward:transferFrom:ONLY_OWNER_CAN_ADD_INCENTIVES"
        );

        require(
            msg.sender == uniswapV3Staker,
            "GivethUniswapV3Reward:transferFrom:ONLY_STAKER"
        );

        require(
            to == uniswapV3Staker,
            "GivethUniswapV3Reward:transferFrom:ONLY_TO_STAKER"
        );

        totalSupply = totalSupply + value;

        emit Transfer(address(0), to, value);
        return true;
    }

    function allowance(address, address spender)
        external
        view
        override
        returns (uint256)
    {

        if (spender == uniswapV3Staker) return type(uint256).max;
        return 0;
    }

    function disable() external onlyOwner {

        disabled = true;
        emit Disabled(msg.sender);
    }

    function enable() external onlyOwner {

        disabled = false;
        emit Enabled(msg.sender);
    }
}