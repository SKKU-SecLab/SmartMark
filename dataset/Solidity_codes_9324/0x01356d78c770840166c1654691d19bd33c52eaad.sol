
pragma solidity 0.8.4;

contract OwnerController {

    address private _owner;
    address private _controller;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event ControlTransferred(
        address indexed previousController,
        address indexed newController
    );

    constructor() {
        _owner = msg.sender;
        _controller = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
        emit ControlTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function controller() public view returns (address) {

        return _controller;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "oc1");
        _;
    }

    modifier onlyController() {

        require(_controller == msg.sender, "oc2");
        _;
    }

    function requireOwner() internal view {

        require(_owner == msg.sender, "oc1");
    }

    function requireController() internal view {

        require(_controller == msg.sender, "oc2");
    }

    function transferOwnership(address newOwner) public virtual {

        requireOwner();
        require(newOwner != address(0), "oc3");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transferControl(address newController) public virtual {

        requireOwner();
        require(newController != address(0), "oc4");
        emit ControlTransferred(_controller, newController);
        _controller = newController;
    }
}/*
IPoolInfo

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;


interface IPoolInfo {

    function modules(address pool)
        external
        view
        returns (
            address,
            address,
            address,
            address
        );


    function rewards(address pool, address addr)
        external
        view
        returns (uint256[] memory);

}/*
IPool

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;

interface IPool {

    function stakingTokens() external view returns (address[] memory);


    function rewardTokens() external view returns (address[] memory);


    function stakingBalances(address user)
        external
        view
        returns (uint256[] memory);


    function stakingTotals() external view returns (uint256[] memory);


    function rewardBalances() external view returns (uint256[] memory);


    function usage() external view returns (uint256);


    function stakingModule() external view returns (address);


    function rewardModule() external view returns (address);


    function stake(
        uint256 amount,
        bytes calldata stakingdata,
        bytes calldata rewarddata
    ) external;


    function unstake(
        uint256 amount,
        bytes calldata stakingdata,
        bytes calldata rewarddata
    ) external;


    function claim(
        uint256 amount,
        bytes calldata stakingdata,
        bytes calldata rewarddata
    ) external;


    function update() external;


    function clean() external;


    function gysrBalance() external view returns (uint256);


    function withdraw(uint256 amount) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}/*
IEvents

https://github.com/gysr-io/core

MIT
 */

pragma solidity 0.8.4;

interface IEvents {

    event Staked(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );
    event Unstaked(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );
    event Claimed(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );

    event RewardsDistributed(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );
    event RewardsFunded(
        address indexed token,
        uint256 amount,
        uint256 shares,
        uint256 timestamp
    );
    event RewardsUnlocked(address indexed token, uint256 shares);
    event RewardsExpired(
        address indexed token,
        uint256 amount,
        uint256 shares,
        uint256 timestamp
    );

    event GysrSpent(address indexed user, uint256 amount);
    event GysrVested(address indexed user, uint256 amount);
    event GysrWithdrawn(uint256 amount);
}/*
IStakingModule

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;




abstract contract IStakingModule is OwnerController, IEvents {
    uint256 public constant DECIMALS = 18;

    function tokens() external view virtual returns (address[] memory);

    function balances(address user)
        external
        view
        virtual
        returns (uint256[] memory);

    function factory() external view virtual returns (address);

    function totals() external view virtual returns (uint256[] memory);

    function stake(
        address user,
        uint256 amount,
        bytes calldata data
    ) external virtual returns (address, uint256);

    function unstake(
        address user,
        uint256 amount,
        bytes calldata data
    ) external virtual returns (address, uint256);

    function claim(
        address user,
        uint256 amount,
        bytes calldata data
    ) external virtual returns (address, uint256);

    function update(address user) external virtual;

    function clean() external virtual;
}/*
IRewardModule

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;




abstract contract IRewardModule is OwnerController, IEvents {
    uint256 public constant DECIMALS = 18;

    function tokens() external view virtual returns (address[] memory);

    function balances() external view virtual returns (uint256[] memory);

    function usage() external view virtual returns (uint256);

    function factory() external view virtual returns (address);

    function stake(
        address account,
        address user,
        uint256 shares,
        bytes calldata data
    ) external virtual returns (uint256, uint256);

    function unstake(
        address account,
        address user,
        uint256 shares,
        bytes calldata data
    ) external virtual returns (uint256, uint256);

    function claim(
        address account,
        address user,
        uint256 shares,
        bytes calldata data
    ) external virtual returns (uint256, uint256);

    function update(address user) external virtual;

    function clean() external virtual;
}/*
IStakingModuleInfo

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;

interface IStakingModuleInfo {

    function token(address module)
        external
        view
        returns (
            address,
            string memory,
            string memory,
            uint8
        );


    function shares(
        address module,
        address addr,
        uint256 amount
    ) external view returns (uint256);


    function sharesPerToken(address module) external view returns (uint256);

}/*
IRewardModuleInfo

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;


interface IRewardModuleInfo {

    function tokens(address module)
        external
        view
        returns (
            address[] memory,
            string[] memory,
            string[] memory,
            uint8[] memory
        );


    function rewards(
        address module,
        address addr,
        uint256 shares
    ) external view returns (uint256[] memory);

}/*
PoolInfo

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;



contract PoolInfo is IPoolInfo, OwnerController {

    mapping(address => address) public registry;

    function modules(address pool)
        public
        view
        override
        returns (
            address,
            address,
            address,
            address
        )
    {

        IPool p = IPool(pool);
        IStakingModule s = IStakingModule(p.stakingModule());
        IRewardModule r = IRewardModule(p.rewardModule());
        return (address(s), address(r), s.factory(), r.factory());
    }

    function register(address factory, address info) external onlyController {

        registry[factory] = info;
    }

    function rewards(address pool, address addr)
        public
        view
        override
        returns (uint256[] memory rewards_)
    {

        address stakingModule;
        address rewardModule;
        address stakingModuleType;
        address rewardModuleType;

        (
            stakingModule,
            rewardModule,
            stakingModuleType,
            rewardModuleType
        ) = modules(pool);

        IStakingModuleInfo stakingModuleInfo =
            IStakingModuleInfo(registry[stakingModuleType]);
        IRewardModuleInfo rewardModuleInfo =
            IRewardModuleInfo(registry[rewardModuleType]);

        uint256 shares = stakingModuleInfo.shares(stakingModule, addr, 0);

        if (shares == 0)
            return new uint256[](IPool(pool).rewardTokens().length);

        return rewardModuleInfo.rewards(rewardModule, addr, shares);
    }
}