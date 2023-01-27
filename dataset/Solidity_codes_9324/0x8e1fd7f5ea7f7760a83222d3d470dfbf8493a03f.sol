
pragma solidity 0.8.2;


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

interface IBoostedVaultWithLockup {

    function stake(uint256 _amount) external;


    function stake(address _beneficiary, uint256 _amount) external;


    function exit() external;


    function exit(uint256 _first, uint256 _last) external;


    function withdraw(uint256 _amount) external;


    function claimReward() external;


    function claimRewards() external;


    function claimRewards(uint256 _first, uint256 _last) external;


    function pokeBoost(address _account) external;


    function lastTimeRewardApplicable() external view returns (uint256);


    function rewardPerToken() external view returns (uint256);


    function earned(address _account) external view returns (uint256);


    function unclaimedRewards(address _account)
        external
        view
        returns (
            uint256 amount,
            uint256 first,
            uint256 last
        );

}

struct PokeVaultAccounts {
    address boostVault;
    address[] accounts;
}

contract Poker {


    function poke(PokeVaultAccounts[] memory _vaultAccounts) external {

        uint vaultCount = _vaultAccounts.length;
        for(uint i = 0; i < vaultCount; i++) {
            PokeVaultAccounts memory vaultAccounts = _vaultAccounts[i];
            address boostVaultAddress = vaultAccounts.boostVault;
            require(boostVaultAddress != address(0), "blank vault address");
            IBoostedVaultWithLockup boostVault = IBoostedVaultWithLockup(boostVaultAddress);

            uint accountsLength = vaultAccounts.accounts.length;
            for(uint j = 0; j < accountsLength; j++) {
                address accountAddress = vaultAccounts.accounts[j];
                require(accountAddress != address(0), "blank address");
                boostVault.pokeBoost(accountAddress);
            }
        }
    }
}