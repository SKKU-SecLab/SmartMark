
pragma solidity 0.5.7;


contract INXMMaster {


    address public tokenAddress;

    address public owner;


    uint public pauseTime;

    function delegateCallBack(bytes32 myid) external;


    function masterInitialized() public view returns(bool);

    
    function isInternal(address _add) public view returns(bool);


    function isPause() public view returns(bool check);


    function isOwner(address _add) public view returns(bool);


    function isMember(address _add) public view returns(bool);

    
    function checkIsAuthToGoverned(address _add) public view returns(bool);


    function updatePauseTime(uint _time) public;


    function dAppLocker() public view returns(address _add);


    function dAppToken() public view returns(address _add);


    function getLatestAddress(bytes2 _contractName) public view returns(address payable contractAddress);

}pragma solidity 0.5.7;



contract Iupgradable {


    INXMMaster public ms;
    address public nxMasterAddress;

    modifier onlyInternal {

        require(ms.isInternal(msg.sender));
        _;
    }

    modifier isMemberAndcheckPause {

        require(ms.isPause() == false && ms.isMember(msg.sender) == true);
        _;
    }

    modifier onlyOwner {

        require(ms.isOwner(msg.sender));
        _;
    }

    modifier checkPause {

        require(ms.isPause() == false);
        _;
    }

    modifier isMember {

        require(ms.isMember(msg.sender), "Not member");
        _;
    }

    function  changeDependentContractAddress() public;

    function changeMasterAddress(address _masterAddress) public {

        if (address(ms) != address(0)) {
            require(address(ms) == msg.sender, "Not master");
        }
        ms = INXMMaster(_masterAddress);
        nxMasterAddress = _masterAddress;
    }

}
pragma solidity 0.5.7;


library SafeMath {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

pragma solidity 0.5.7;



contract QuotationData is Iupgradable {

    using SafeMath for uint;

    enum HCIDStatus { NA, kycPending, kycPass, kycFailedOrRefunded, kycPassNoCover }

    enum CoverStatus { Active, ClaimAccepted, ClaimDenied, CoverExpired, ClaimSubmitted, Requested }

    struct Cover {
        address payable memberAddress;
        bytes4 currencyCode;
        uint sumAssured;
        uint16 coverPeriod;
        uint validUntil;
        address scAddress;
        uint premiumNXM;
    }

    struct HoldCover {
        uint holdCoverId;
        address payable userAddress;
        address scAddress;
        bytes4 coverCurr;
        uint[] coverDetails;
        uint16 coverPeriod;
    }

    address public authQuoteEngine;
  
    mapping(bytes4 => uint) internal currencyCSA;
    mapping(address => uint[]) internal userCover;
    mapping(address => uint[]) public userHoldedCover;
    mapping(address => bool) public refundEligible;
    mapping(address => mapping(bytes4 => uint)) internal currencyCSAOfSCAdd;
    mapping(uint => uint8) public coverStatus;
    mapping(uint => uint) public holdedCoverIDStatus;
    mapping(uint => bool) public timestampRepeated; 
    

    Cover[] internal allCovers;
    HoldCover[] internal allCoverHolded;

    uint public stlp;
    uint public stl;
    uint public pm;
    uint public minDays;
    uint public tokensRetained;
    address public kycAuthAddress;

    event CoverDetailsEvent(
        uint indexed cid,
        address scAdd,
        uint sumAssured,
        uint expiry,
        uint premium,
        uint premiumNXM,
        bytes4 curr
    );

    event CoverStatusEvent(uint indexed cid, uint8 statusNum);

    constructor(address _authQuoteAdd, address _kycAuthAdd) public {
        authQuoteEngine = _authQuoteAdd;
        kycAuthAddress = _kycAuthAdd;
        stlp = 90;
        stl = 100;
        pm = 30;
        minDays = 30;
        tokensRetained = 10;
        allCovers.push(Cover(address(0), "0x00", 0, 0, 0, address(0), 0));
        uint[] memory arr = new uint[](1);
        allCoverHolded.push(HoldCover(0, address(0), address(0), 0x00, arr, 0));

    }
    
    function addInTotalSumAssuredSC(address _add, bytes4 _curr, uint _amount) external onlyInternal {

        currencyCSAOfSCAdd[_add][_curr] = currencyCSAOfSCAdd[_add][_curr].add(_amount);
    }

    function subFromTotalSumAssuredSC(address _add, bytes4 _curr, uint _amount) external onlyInternal {

        currencyCSAOfSCAdd[_add][_curr] = currencyCSAOfSCAdd[_add][_curr].sub(_amount);
    }
    
    function subFromTotalSumAssured(bytes4 _curr, uint _amount) external onlyInternal {

        currencyCSA[_curr] = currencyCSA[_curr].sub(_amount);
    }

    function addInTotalSumAssured(bytes4 _curr, uint _amount) external onlyInternal {

        currencyCSA[_curr] = currencyCSA[_curr].add(_amount);
    }

    function setTimestampRepeated(uint _timestamp) external onlyInternal {

        timestampRepeated[_timestamp] = true;
    }
    
    function addCover(
        uint16 _coverPeriod,
        uint _sumAssured,
        address payable _userAddress,
        bytes4 _currencyCode,
        address _scAddress,
        uint premium,
        uint premiumNXM
    )   
        external
        onlyInternal
    {

        uint expiryDate = now.add(uint(_coverPeriod).mul(1 days));
        allCovers.push(Cover(_userAddress, _currencyCode,
                _sumAssured, _coverPeriod, expiryDate, _scAddress, premiumNXM));
        uint cid = allCovers.length.sub(1);
        userCover[_userAddress].push(cid);
        emit CoverDetailsEvent(cid, _scAddress, _sumAssured, expiryDate, premium, premiumNXM, _currencyCode);
    }

    function addHoldCover(
        address payable from,
        address scAddress,
        bytes4 coverCurr, 
        uint[] calldata coverDetails,
        uint16 coverPeriod
    )   
        external
        onlyInternal
    {

        uint holdedCoverLen = allCoverHolded.length;
        holdedCoverIDStatus[holdedCoverLen] = uint(HCIDStatus.kycPending);             
        allCoverHolded.push(HoldCover(holdedCoverLen, from, scAddress, 
            coverCurr, coverDetails, coverPeriod));
        userHoldedCover[from].push(allCoverHolded.length.sub(1));
    
    }

    function setRefundEligible(address _add, bool status) external onlyInternal {

        refundEligible[_add] = status;
    }

    function setHoldedCoverIDStatus(uint holdedCoverID, uint status) external onlyInternal {

        holdedCoverIDStatus[holdedCoverID] = status;
    }

    function setKycAuthAddress(address _add) external onlyInternal {

        kycAuthAddress = _add;
    }

    function changeAuthQuoteEngine(address _add) external onlyInternal {

        authQuoteEngine = _add;
    }

    function getUintParameters(bytes8 code) external view returns(bytes8 codeVal, uint val) {

        codeVal = code;

        if (code == "STLP") {
            val = stlp;

        } else if (code == "STL") {
            
            val = stl;

        } else if (code == "PM") {

            val = pm;

        } else if (code == "QUOMIND") {

            val = minDays;

        } else if (code == "QUOTOK") {

            val = tokensRetained;

        }
        
    }

    function getProductDetails()
        external
        view
        returns (
            uint _minDays,
            uint _pm,
            uint _stl,
            uint _stlp
        )
    {


        _minDays = minDays;
        _pm = pm;
        _stl = stl;
        _stlp = stlp;
    }

    function getCoverLength() external view returns(uint len) {

        return (allCovers.length);
    }

    function getAuthQuoteEngine() external view returns(address _add) {

        _add = authQuoteEngine;
    }

    function getTotalSumAssured(bytes4 _curr) external view returns(uint amount) {

        amount = currencyCSA[_curr];
    }

    function getAllCoversOfUser(address _add) external view returns(uint[] memory allCover) {

        return (userCover[_add]);
    }

    function getUserCoverLength(address _add) external view returns(uint len) {

        len = userCover[_add].length;
    }

    function getCoverStatusNo(uint _cid) external view returns(uint8) {

        return coverStatus[_cid];
    }

    function getCoverPeriod(uint _cid) external view returns(uint32 cp) {

        cp = allCovers[_cid].coverPeriod;
    }

    function getCoverSumAssured(uint _cid) external view returns(uint sa) {

        sa = allCovers[_cid].sumAssured;
    }

    function getCurrencyOfCover(uint _cid) external view returns(bytes4 curr) {

        curr = allCovers[_cid].currencyCode;
    }

    function getValidityOfCover(uint _cid) external view returns(uint date) {

        date = allCovers[_cid].validUntil;
    }

    function getscAddressOfCover(uint _cid) external view returns(uint, address) {

        return (_cid, allCovers[_cid].scAddress);
    }

    function getCoverMemberAddress(uint _cid) external view returns(address payable _add) {

        _add = allCovers[_cid].memberAddress;
    }

    function getCoverPremiumNXM(uint _cid) external view returns(uint _premiumNXM) {

        _premiumNXM = allCovers[_cid].premiumNXM;
    }

    function getCoverDetailsByCoverID1(
        uint _cid
    ) 
        external
        view
        returns (
            uint cid,
            address _memberAddress,
            address _scAddress,
            bytes4 _currencyCode,
            uint _sumAssured,  
            uint premiumNXM 
        ) 
    {

        return (
            _cid,
            allCovers[_cid].memberAddress,
            allCovers[_cid].scAddress,
            allCovers[_cid].currencyCode,
            allCovers[_cid].sumAssured,
            allCovers[_cid].premiumNXM
        );
    }

    function getCoverDetailsByCoverID2(
        uint _cid
    )
        external
        view
        returns (
            uint cid,
            uint8 status,
            uint sumAssured,
            uint16 coverPeriod,
            uint validUntil
        ) 
    {


        return (
            _cid,
            coverStatus[_cid],
            allCovers[_cid].sumAssured,
            allCovers[_cid].coverPeriod,
            allCovers[_cid].validUntil
        );
    }

    function getHoldedCoverDetailsByID1(
        uint _hcid
    )
        external 
        view
        returns (
            uint hcid,
            address scAddress,
            bytes4 coverCurr,
            uint16 coverPeriod
        )
    {

        return (
            _hcid,
            allCoverHolded[_hcid].scAddress,
            allCoverHolded[_hcid].coverCurr, 
            allCoverHolded[_hcid].coverPeriod
        );
    }

    function getUserHoldedCoverLength(address _add) external view returns (uint) {

        return userHoldedCover[_add].length;
    }

    function getUserHoldedCoverByIndex(address _add, uint index) external view returns (uint) {

        return userHoldedCover[_add][index];
    }

    function getHoldedCoverDetailsByID2(
        uint _hcid
    ) 
        external
        view
        returns (
            uint hcid,
            address payable memberAddress, 
            uint[] memory coverDetails
        )
    {

        return (
            _hcid,
            allCoverHolded[_hcid].userAddress,
            allCoverHolded[_hcid].coverDetails
        );
    }

    function getTotalSumAssuredSC(address _add, bytes4 _curr) external view returns(uint amount) {

        amount = currencyCSAOfSCAdd[_add][_curr];
    }

    function changeDependentContractAddress() public {}


    function changeCoverStatusNo(uint _cid, uint8 _stat) public onlyInternal {

        coverStatus[_cid] = _stat;
        emit CoverStatusEvent(_cid, _stat);
    }

    function updateUintParameters(bytes8 code, uint val) public {


        require(ms.checkIsAuthToGoverned(msg.sender));
        if (code == "STLP") {
            _changeSTLP(val);

        } else if (code == "STL") {
            
            _changeSTL(val);

        } else if (code == "PM") {

            _changePM(val);

        } else if (code == "QUOMIND") {

            _changeMinDays(val);

        } else if (code == "QUOTOK") {

            _setTokensRetained(val);

        } else {

            revert("Invalid param code");
        }
        
    }
    
    function _changePM(uint _pm) internal {

        pm = _pm;
    }

    function _changeSTLP(uint _stlp) internal {

        stlp = _stlp;
    }

    function _changeSTL(uint _stl) internal {

        stl = _stl;
    }

    function _changeMinDays(uint _days) internal {

        minDays = _days;
    }
    
    function _setTokensRetained(uint val) internal {

        tokensRetained = val;
    }
}
