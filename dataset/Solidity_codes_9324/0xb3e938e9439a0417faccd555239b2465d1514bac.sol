

pragma solidity >=0.7.0;

interface IAnteTest {

    function testAuthor() external view returns (address);


    function protocolName() external view returns (string memory);


    function testedContracts(uint256 i) external view returns (address);


    function testName() external view returns (string memory);


    function checkTestPasses() external returns (bool);

}// GPL-3.0-only


pragma solidity >=0.7.0;


abstract contract AnteTest is IAnteTest {
    address public override testAuthor;
    string public override testName;
    string public override protocolName;
    address[] public override testedContracts;

    constructor(string memory _testName) {
        testAuthor = msg.sender;
        testName = _testName;
    }

    function getTestedContracts() external view returns (address[] memory) {
        return testedContracts;
    }

    function checkTestPasses() external virtual override returns (bool) {}
}// MIT

pragma solidity 0.7.6;
pragma abicoder v2;

interface IPendleMarket {

    function getReserves()
        external
        view
        returns (
            uint256 xytBalance,
            uint256 xytWeight,
            uint256 tokenBalance,
            uint256 tokenWeight,
            uint256 currentBlock
        );


    function expiry() external view returns (uint256);


    function token() external view returns (address);


    function xyt() external view returns (address);


    function lockStartTime() external view returns (uint256);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.0;


contract AntePendleMarketBalanceTest is AnteTest("Pendle Market Balance Test") {

    address[4] public markets = [
        0x8315BcBC2c5C1Ef09B71731ab3827b0808A2D6bD, // YT-aUSDC/USDC_Dec_29_2022
        0xB26C86330FC7F97533051F2F8cD0a90C2E82b5EE, // YT-cDai/USDC_Dec_29_2022
        0x79c05Da47dC20ff9376B2f7DbF8ae0c994C3A0D0, // YT-ETHUSDC/USDC_Dec_29_2022
        0x685d32f394a5F03e78a1A0F6A91B4E2bf6F52cfE // YT-PENDLEETH/PENDLE_Dec_29_2022
    ];

    constructor() {
        protocolName = "Pendle";

        for (uint256 i = 0; i < markets.length; ++i) {
            testedContracts.push(markets[i]);
        }
    }

    function checkTestPasses() public view override returns (bool) {

        for (uint256 i = 0; i < markets.length; ++i) {
            IPendleMarket market = IPendleMarket(markets[i]);

            if (block.timestamp >= market.lockStartTime()) continue;

            IERC20 xyt = IERC20(market.xyt());
            IERC20 token = IERC20(market.token());

            (uint256 xytBalance, , uint256 tokenBalance, , ) = market.getReserves();

            if (xytBalance > xyt.balanceOf(address(market))) return false;
            if (tokenBalance > token.balanceOf(address(market))) return false;
        }
        return true;
    }
}