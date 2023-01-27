

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

struct Wallets {
    address team;
    address charity;
    address staking;
    address liquidity;
}

contract DistributionWallet {

    IERC20 token;
    Wallets public wallets;

    event Distributed(uint256 amount);

    constructor(address _token, Wallets memory _wallets) {
        token = IERC20(_token);
        wallets = _wallets;
    }

    function distribute() public {

        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "no tokens to transfer");
        emit Distributed(balance);
        uint256 distributionReward = balance / 1000;
        balance -= distributionReward;
        uint256 teamAmount = (balance * 15) / 100;
        uint256 charityAmount = (balance * 625) / 10000;
        uint256 liquidityAmount = (balance * 375) / 10000;
        uint256 stakingAmount =
            balance - teamAmount - charityAmount - liquidityAmount;
        token.transfer(wallets.team, teamAmount);
        token.transfer(wallets.charity, charityAmount);
        token.transfer(wallets.liquidity, liquidityAmount);
        token.transfer(wallets.staking, stakingAmount);
        token.transfer(msg.sender, distributionReward);
    }
}