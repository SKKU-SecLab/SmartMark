pragma solidity 0.8.6;

interface IController {

    function repayFYDai(bytes32 collateral, uint256 maturity, address from, address to, uint256 fyDaiAmount) external returns (uint256);

    function debtFYDai(bytes32, uint256, address) external view returns (uint256);

}

contract RepayOneWei {

    IController constant public controller = IController(0xB94199866Fe06B535d019C11247D3f921460b91A);
    bytes32 constant public collateral = "ETH-A";
    uint256 constant public amount = 1;

    function hasDebt(address vault) external view returns (uint256[5] memory debts) {

        uint32[5] memory maturities = [1604188799, 1609459199, 1617235199, 1625097599, 1633046399];
        for (uint256 i; i < 5; i++) {
            debts[i] = controller.debtFYDai(collateral, maturities[i], vault);
        }
    }

    function repay(address vault) external
    {

        uint32[5] memory maturities = [1604188799, 1609459199, 1617235199, 1625097599, 1633046399];
        for (uint256 i; i < 5; i++) {
            if (controller.debtFYDai(collateral, maturities[i], vault) == amount)
                controller.repayFYDai(collateral, maturities[i], address(this), vault, amount);
        }
    }
}