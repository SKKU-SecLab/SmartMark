
pragma solidity ^0.4.23;


contract OldTrueUSDInterface {

    function delegateToNewContract(address _newContract) public;

    function claimOwnership() public;

    function balances() public returns(address);

    function allowances() public returns(address);

    function totalSupply() public returns(uint);

    function transferOwnership(address _newOwner) external;

}
contract NewTrueUSDInterface {

    function setTotalSupply(uint _totalSupply) public;

    function transferOwnership(address _newOwner) public;

    function claimOwnership() public;

}

contract TokenControllerInterface {

    function claimOwnership() external;

    function transferChild(address _child, address _newOwner) external;

    function requestReclaimContract(address _child) external;

    function issueClaimOwnership(address _child) external;

    function setTrueUSD(address _newTusd) external;

    function setTusdRegistry(address _Registry) external;

    function claimStorageForProxy(address _delegate,
        address _balanceSheet,
        address _alowanceSheet) external;

    function setGlobalPause(address _globalPause) external;

    function transferOwnership(address _newOwner) external;

    function owner() external returns(address);

}

contract UpgradeHelper {

    OldTrueUSDInterface public constant oldTrueUSD = OldTrueUSDInterface(0x8dd5fbce2f6a956c3022ba3663759011dd51e73e);
    NewTrueUSDInterface public constant newTrueUSD = NewTrueUSDInterface(0x0000000000085d4780B73119b644AE5ecd22b376);
    TokenControllerInterface public constant tokenController = TokenControllerInterface(0x0000000000075efbee23fe2de1bd0b7690883cc9);
    address public constant registry = address(0x0000000000013949f288172bd7e36837bddc7211);
    address public constant globalPause = address(0);

    function upgrade() public {

        address endOwner = tokenController.owner();

        tokenController.claimOwnership();
        newTrueUSD.claimOwnership();

        newTrueUSD.setTotalSupply(oldTrueUSD.totalSupply());

        address balanceSheetAddress = oldTrueUSD.balances();
        address allowanceSheetAddress = oldTrueUSD.allowances();
        tokenController.requestReclaimContract(balanceSheetAddress);
        tokenController.requestReclaimContract(allowanceSheetAddress);

        tokenController.issueClaimOwnership(balanceSheetAddress);
        tokenController.issueClaimOwnership(allowanceSheetAddress);
        tokenController.transferChild(balanceSheetAddress, newTrueUSD);
        tokenController.transferChild(allowanceSheetAddress, newTrueUSD);
        
        newTrueUSD.transferOwnership(tokenController);
        tokenController.issueClaimOwnership(newTrueUSD);
        tokenController.setTrueUSD(newTrueUSD);
        tokenController.claimStorageForProxy(newTrueUSD, balanceSheetAddress, allowanceSheetAddress);

        tokenController.setTusdRegistry(registry);
        tokenController.setGlobalPause(globalPause);

        tokenController.transferChild(oldTrueUSD, address(this));
        oldTrueUSD.claimOwnership();
        oldTrueUSD.delegateToNewContract(newTrueUSD);
        
        oldTrueUSD.transferOwnership(tokenController);
        tokenController.issueClaimOwnership(oldTrueUSD);
        tokenController.transferOwnership(endOwner);
    }
}