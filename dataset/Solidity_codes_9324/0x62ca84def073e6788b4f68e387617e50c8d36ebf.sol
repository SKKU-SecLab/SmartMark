

pragma solidity ^0.7.0;

interface IAnteTest {

    function testAuthor() external view returns (address);


    function protocolName() external view returns (string memory);


    function testedContracts(uint256 i) external view returns (address);


    function testName() external view returns (string memory);


    function checkTestPasses() external returns (bool);

}// GPL-3.0-only


pragma solidity ^0.7.0;


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
}// GPL-3.0-only




pragma solidity ^0.7.0;


interface ILlamaPayFactory {

    function getLlamaPayContractByToken(address _token) external view returns (address, bool);

}

interface ILlamaPay {

    function payers(address _payer) external view returns (uint40, uint216);

}

contract AnteLlamaPayTest is
    AnteTest("LlamaPay never pays future payments early (lastPayerUpdate[anyone] <= block.timestamp)")
{

    ILlamaPayFactory internal factory;

    address public tokenAddress;
    address public payerAddress;

    constructor(address _llamaPayFactoryAddress) {
        factory = ILlamaPayFactory(_llamaPayFactoryAddress);

        protocolName = "LlamaPay"; // <3
        testedContracts.push(_llamaPayFactoryAddress);
        testedContracts.push(address(0)); // LlamaPay instance once set
    }

    function checkTestPasses() external view override returns (bool) {

        (address predictedAddress, bool isDeployed) = factory.getLlamaPayContractByToken(tokenAddress);
        if (isDeployed) {
            (uint40 lastPayerUpdate, ) = ILlamaPay(predictedAddress).payers(payerAddress);

            return (lastPayerUpdate <= block.timestamp);
        }

        return true;
    }


    function setPayerAddress(address _payerAddress) external {

        payerAddress = _payerAddress;
    }

    function setTokenAddress(address _tokenAddress) external {

        (address predictedAddress, bool isDeployed) = factory.getLlamaPayContractByToken(_tokenAddress);
        require(isDeployed, "ANTE: LlamaPay instance not deployed for that token");
        testedContracts[1] = predictedAddress;
        tokenAddress = _tokenAddress;
    }
}