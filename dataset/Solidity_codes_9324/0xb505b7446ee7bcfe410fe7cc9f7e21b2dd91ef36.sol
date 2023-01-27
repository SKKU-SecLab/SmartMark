
pragma solidity 0.6.7;

abstract contract Auth {
  function addAuthorization(address) public virtual;
  function removeAuthorization(address) public virtual;
}

abstract contract Setter is Auth {
  function modifyParameters(bytes32, address) public virtual;
  function modifyParameters(bytes32, uint) public virtual;
  function addFundedFunction(address, bytes4, uint) public virtual;
  function removeFundedFunction(address, bytes4) public virtual;
  function addFundingReceiver(address, bytes4, uint, uint, uint, uint) public virtual;
  function removeFundingReceiver(address, bytes4) public virtual;
  function toggleReimburser(address) public virtual;
  function modifyParameters(bytes32, uint256, uint256, bytes4, address) public virtual;
}

contract Proposal {

  function execute(bool) public {

    address deployer = 0x3E0139cE3533a42A7D342841aEE69aB2BfEE1d51;

    Setter accountingEngine = Setter(0xcEe6Aa1aB47d0Fb0f24f51A3072EC16E20F90fcE);
    Setter newSurplusAuctionHouse = Setter(0x4EEfDaE928ca97817302242a851f317Be1B85C90);
    Setter newAutoSurplusBuffer = Setter(0x9fe16154582ecCe3414536FdE57A201c17398b2A);
    Setter newAutoSurplusBufferOverlay = Setter(0x7A2414F6b6Ee5D4a043E26127f29ca6D65ea31cd);
    accountingEngine.modifyParameters("surplusAuctionHouse", address(newSurplusAuctionHouse));

    newSurplusAuctionHouse.addAuthorization(address(accountingEngine));
    newSurplusAuctionHouse.removeAuthorization(deployer);
    newSurplusAuctionHouse.modifyParameters("protocolTokenBidReceiver", 0x03da3D5E0b13b6f0917FA9BC3d65B46229d7Ef47);


    newAutoSurplusBuffer.modifyParameters("bufferInflationDelay", 31536000); // 1 year
    newAutoSurplusBuffer.modifyParameters("bufferTargetInflation", 7);       // 7%
    newAutoSurplusBuffer.modifyParameters("maxRewardIncreaseDelay", 10800);   // 3 hours

    accountingEngine.addAuthorization(address(newAutoSurplusBuffer));

    accountingEngine.removeAuthorization(0x1450f40E741F2450A95F9579Be93DD63b8407a25); // old GEB_AUTO_SURPLUS_BUFFER

    newAutoSurplusBuffer.addAuthorization(0x1dCeE093a7C952260f591D9B8401318f2d2d72Ac);
    Setter(0x1dCeE093a7C952260f591D9B8401318f2d2d72Ac).toggleReimburser(address(newAutoSurplusBuffer));
    Setter(0x1dCeE093a7C952260f591D9B8401318f2d2d72Ac).toggleReimburser(0x1450f40E741F2450A95F9579Be93DD63b8407a25); // old GEB_AUTO_SURPLUS_BUFFER

    newAutoSurplusBuffer.addAuthorization(address(newAutoSurplusBufferOverlay));

    newAutoSurplusBuffer.removeAuthorization(deployer);

    newAutoSurplusBufferOverlay.removeAuthorization(deployer);

    newAutoSurplusBuffer.addAuthorization(0xa937A6da2837Dcc91eB19657b051504C0D512a35);

    Setter(0x73FEb3C2DBb87c8E0d040A7CD708F7497853B787).addFundedFunction(address(newAutoSurplusBuffer), 0xbf1ad0db, 26);
    Setter(0x73FEb3C2DBb87c8E0d040A7CD708F7497853B787).removeFundedFunction(0x1450f40E741F2450A95F9579Be93DD63b8407a25, 0xbf1ad0db);

    Setter(0xa937A6da2837Dcc91eB19657b051504C0D512a35).addFundingReceiver(address(newAutoSurplusBuffer), 0xbf1ad0db, 86400, 1000, 100, 200);
    Setter(0xa937A6da2837Dcc91eB19657b051504C0D512a35).removeFundingReceiver(0x1450f40E741F2450A95F9579Be93DD63b8407a25, 0xbf1ad0db);

    Setter(0x7F55e74C25647c100256D87629dee379D68bdCDe).modifyParameters("addFunction", 0, 1, bytes4(0xbf1ad0db), address(newAutoSurplusBuffer));

    Setter(0x7F55e74C25647c100256D87629dee379D68bdCDe).modifyParameters("removeFunction", 9, 1, 0x0, address(0));
  }
}