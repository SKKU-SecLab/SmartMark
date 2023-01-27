

pragma solidity >=0.5.15 <0.6.0;


interface TinlakeRootLike {

    function relyContract(address, address) external;

    function denyContract(address, address) external;

}

interface CoordinatorLike {

    function file(bytes32 name, uint value) external;

    function minimumEpochTime() external returns(uint);

}

interface NAVFeedLike {

    function file(bytes32 name, uint value) external;

    function file(bytes32 name, uint risk_, uint thresholdRatio_, uint ceilingRatio_, uint rate_, uint recoveryRatePD_) external;

    function discountRate() external returns(uint);

}

contract TinlakeSpell {


    bool public done;
    string constant public description = "Tinlake Mainnet Spell";


    address constant public ROOT = 0xdB3bC9fB1893222d266762e9fF857EB74D75c7D6;
    address constant public ASSESSOR = 0x6aaf2EE5b2B62fb9E29E021a1bF3B381454d900a;
    address constant public COORDINATOR = 0xFc224d40Eb9c40c85c71efa773Ce24f8C95aAbAb;
    address constant public NAV_FEED = 0x69504da6B2Cd8320B9a62F3AeD410a298d3E7Ac6;
    
    address constant public ASSESSOR_ADMIN_WRAPPER = 0x533Ea66C62fad098599dE145970a8d49D6B5f9C4;  

    address constant public ASSESSOR_ADMIN_TO_BE_REMOVED = 0x71d9f8CFdcCEF71B59DD81AB387e523E2834F2b8;
    address constant public COORDINATOR_ADMIN_TO_BE_REMOVED = 0x97b2d32FE673af5bb322409afb6253DFD02C0567;

    uint constant public minEpochTime = 1 days;
    uint constant public discountRate = uint(1000000003281963470319634703);

    uint256 constant ONE = 10**27;
    
    function cast() public {

        require(!done, "spell-already-cast");
        done = true;
        execute();
    }

    function execute() internal {

       TinlakeRootLike root = TinlakeRootLike(address(ROOT));
       CoordinatorLike coordinator = CoordinatorLike(address(COORDINATOR));
       NAVFeedLike navFeed = NAVFeedLike(address(NAV_FEED));
   
        root.relyContract(ASSESSOR, ASSESSOR_ADMIN_WRAPPER);
        root.relyContract(COORDINATOR, address(this)); // required to modify min epoch time
        root.relyContract(NAV_FEED, address(this)); // required to file riskGroups & change discountRate

        root.denyContract(ASSESSOR, ASSESSOR_ADMIN_TO_BE_REMOVED);
        root.denyContract(COORDINATOR, COORDINATOR_ADMIN_TO_BE_REMOVED);

        coordinator.file("minimumEpochTime", minEpochTime);

        navFeed.file("discountRate", discountRate);
        
        navFeed.file("riskGroup", 12, ONE, ONE, uint(1000000003488077118214104515), 99.93 * 10**25);
        navFeed.file("riskGroup", 13, ONE, 95 * 10**25, uint(1000000003646626078132927447), 99.9 * 10**25);
        navFeed.file("riskGroup", 14, ONE, 90*  10**25, uint(1000000003646626078132927447), 99.88 * 10**25);
        navFeed.file("riskGroup", 15, ONE, 80 * 10**25, uint(1000000003805175038051750380), 99.86 * 10**25);
        navFeed.file("riskGroup", 16, ONE, ONE, uint(1000000003488077118214104515), 99.92 * 10**25);
        navFeed.file("riskGroup", 17, ONE, ONE, uint(1000000003646626078132927447), 99.9 * 10**25);
        navFeed.file("riskGroup", 18, ONE, ONE, uint(1000000003646626078132927447), 99.88 * 10**25);
        navFeed.file("riskGroup", 19, ONE, ONE, uint(1000000003805175038051750380), 99.87 * 10**25);
        navFeed.file("riskGroup", 20, ONE, 80 * 10**25, uint(1000000003488077118214104515), 99.92 * 10**25);
        navFeed.file("riskGroup", 21, ONE, 70 * 10**25, uint(1000000003646626078132927447), 99.9 * 10**25);
        navFeed.file("riskGroup", 22, ONE, 60 * 10**25, uint(1000000003646626078132927447), 99.89 * 10**25);
        navFeed.file("riskGroup", 23, ONE, 50 * 10**25, uint(1000000003805175038051750380), 99.88 * 10**25);
     }   
}