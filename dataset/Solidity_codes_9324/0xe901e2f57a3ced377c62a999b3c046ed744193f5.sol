


pragma solidity >=0.6.12;






interface AuthLike {

    function rely(address) external;

    function deny(address) external;

    function wards(address) external returns(uint);

}

interface TinlakeRootLike {

    function relyContract(address, address) external;

    function denyContract(address, address) external;

}

interface FileLike {

    function file(bytes32, uint) external;

    function file(bytes32, address) external;

}

interface NAVFeedLike {

    function file(bytes32 name, uint value) external;

    function file(bytes32 name, uint risk_, uint thresholdRatio_, uint ceilingRatio_, uint rate_, uint recoveryRatePD_) external;

    function discountRate() external returns(uint);

    function update(bytes32 nftID, uint value, uint risk) external;

    function nftID(uint loan) external returns (bytes32);

    function nftValues(bytes32 nftID) external returns(uint);

}

interface PileLike {

    function changeRate(uint loan, uint newRate) external;

}

contract TinlakeSpell {


    bool public done;
    string constant public description = "Tinlake GigPool spell";


    address constant public ROOT = 0x3d167bd08f762FD391694c67B5e6aF0868c45538;
    address constant public NAV_FEED = 0x468eb2408c6F24662a291892550952eb0d70b707;
    address constant public PILE = 0x9E39e0130558cd9A01C1e3c7b2c3803baCb59616;
                                                             
    uint256 constant ONE = 10**27;
    address self;
    
    function cast() public {

        require(!done, "spell-already-cast");
        done = true;
        execute();
    }

    function execute() internal {

       TinlakeRootLike root = TinlakeRootLike(address(ROOT));
       NAVFeedLike navFeed = NAVFeedLike(address(NAV_FEED));
       PileLike pile = PileLike(PILE);
       self = address(this);
       root.relyContract(NAV_FEED, self); // required to file riskGroups & change discountRate
       root.relyContract(PILE, self); // required to change the interestRates for loans according to new riskGroups
        
        navFeed.file("riskGroup", 3, ONE, ONE, uint256(1000000004122272957889396245), 99.9*10**25);
        navFeed.file("riskGroup", 4, ONE, ONE, uint256(1000000003488077118214104515), 99.9*10**25);
        navFeed.file("riskGroup", 5, ONE, ONE, uint256(1000000003170979198376458650), 99.9*10**25);
        
        uint newRiskGroup3 = 3;
        uint newRiskGroup4 = 4;
        uint loanID2 = 2;
        bytes32 nftIDLoan2 = navFeed.nftID(loanID2);
        uint nftValueLoan2 = navFeed.nftValues(nftIDLoan2);
        navFeed.update(nftIDLoan2, nftValueLoan2, newRiskGroup3);
        pile.changeRate(loanID2, newRiskGroup3);
        
        uint loanID3 = 3;
        bytes32 nftIDLoan3 = navFeed.nftID(loanID3);
        uint nftValueLoan3 = navFeed.nftValues(nftIDLoan3);
        navFeed.update(nftIDLoan3, nftValueLoan3, newRiskGroup3);
        pile.changeRate(loanID3, newRiskGroup3);

        uint loanID4 = 4;
        bytes32 nftIDLoan4 = navFeed.nftID(loanID4);
        uint nftValueLoan4 = navFeed.nftValues(nftIDLoan4);
        navFeed.update(nftIDLoan4, nftValueLoan4, newRiskGroup4);
        pile.changeRate(loanID4, newRiskGroup4);
     }  
}