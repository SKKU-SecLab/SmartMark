
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



contract TokenData is Iupgradable {

    using SafeMath for uint;

    address payable public walletAddress;
    uint public lockTokenTimeAfterCoverExp;
    uint public bookTime;
    uint public lockCADays;
    uint public lockMVDays;
    uint public scValidDays;
    uint public joiningFee;
    uint public stakerCommissionPer;
    uint public stakerMaxCommissionPer;
    uint public tokenExponent;
    uint public priceStep;

    struct StakeCommission {
        uint commissionEarned;
        uint commissionRedeemed;
    }

    struct Stake {
        address stakedContractAddress;
        uint stakedContractIndex;
        uint dateAdd;
        uint stakeAmount;
        uint unlockedAmount;
        uint burnedAmount;
        uint unLockableBeforeLastBurn;
    }

    struct Staker {
        address stakerAddress;
        uint stakerIndex;
    }

    struct CoverNote {
        uint amount;
        bool isDeposited;
    }

    mapping(address => Stake[]) public stakerStakedContracts; 

    mapping(address => Staker[]) public stakedContractStakers;

    mapping(address => mapping(uint => StakeCommission)) public stakedContractStakeCommission;

    mapping(address => uint) public lastCompletedStakeCommission;

    mapping(address => uint) public stakedContractCurrentCommissionIndex;

    mapping(address => uint) public stakedContractCurrentBurnIndex;

    mapping(uint => CoverNote) public depositedCN;

    mapping(address => uint) internal isBookedTokens;

    event Commission(
        address indexed stakedContractAddress,
        address indexed stakerAddress,
        uint indexed scIndex,
        uint commissionAmount
    );

    constructor(address payable _walletAdd) public {
        walletAddress = _walletAdd;
        bookTime = 12 hours;
        joiningFee = 2000000000000000; // 0.002 Ether
        lockTokenTimeAfterCoverExp = 35 days;
        scValidDays = 250;
        lockCADays = 7 days;
        lockMVDays = 2 days;
        stakerCommissionPer = 20;
        stakerMaxCommissionPer = 50;
        tokenExponent = 4;
        priceStep = 1000;

    }

    function changeWalletAddress(address payable _address) external onlyInternal {

        walletAddress = _address;
    }

    function getUintParameters(bytes8 code) external view returns(bytes8 codeVal, uint val) {

        codeVal = code;
        if (code == "TOKEXP") {

            val = tokenExponent; 

        } else if (code == "TOKSTEP") {

            val = priceStep;

        } else if (code == "RALOCKT") {

            val = scValidDays;

        } else if (code == "RACOMM") {

            val = stakerCommissionPer;

        } else if (code == "RAMAXC") {

            val = stakerMaxCommissionPer;

        } else if (code == "CABOOKT") {

            val = bookTime / (1 hours);

        } else if (code == "CALOCKT") {

            val = lockCADays / (1 days);

        } else if (code == "MVLOCKT") {

            val = lockMVDays / (1 days);

        } else if (code == "QUOLOCKT") {

            val = lockTokenTimeAfterCoverExp / (1 days);

        } else if (code == "JOINFEE") {

            val = joiningFee;

        } 
    }

    function changeDependentContractAddress() public { //solhint-disable-line

    }
    
    function getStakerStakedContractByIndex(
        address _stakerAddress,
        uint _stakerIndex
    ) 
        public
        view
        returns (address stakedContractAddress) 
    {

        stakedContractAddress = stakerStakedContracts[
            _stakerAddress][_stakerIndex].stakedContractAddress;
    }

    function getStakerStakedBurnedByIndex(
        address _stakerAddress,
        uint _stakerIndex
    ) 
        public
        view
        returns (uint burnedAmount) 
    {

        burnedAmount = stakerStakedContracts[
            _stakerAddress][_stakerIndex].burnedAmount;
    }

    function getStakerStakedUnlockableBeforeLastBurnByIndex(
        address _stakerAddress,
        uint _stakerIndex
    ) 
        public
        view
        returns (uint unlockable) 
    {

        unlockable = stakerStakedContracts[
            _stakerAddress][_stakerIndex].unLockableBeforeLastBurn;
    }

    function getStakerStakedContractIndex(
        address _stakerAddress,
        uint _stakerIndex
    ) 
        public
        view
        returns (uint scIndex) 
    {

        scIndex = stakerStakedContracts[
            _stakerAddress][_stakerIndex].stakedContractIndex;
    }

    function getStakedContractStakerIndex(
        address _stakedContractAddress,
        uint _stakedContractIndex
    ) 
        public
        view
        returns (uint sIndex) 
    {

        sIndex = stakedContractStakers[
            _stakedContractAddress][_stakedContractIndex].stakerIndex;
    }

    function getStakerInitialStakedAmountOnContract(
        address _stakerAddress,
        uint _stakerIndex
    )
        public 
        view
        returns (uint amount)
    {

        amount = stakerStakedContracts[
            _stakerAddress][_stakerIndex].stakeAmount;
    }

    function getStakerStakedContractLength(
        address _stakerAddress
    ) 
        public
        view
        returns (uint length)
    {

        length = stakerStakedContracts[_stakerAddress].length;
    }

    function getStakerUnlockedStakedTokens(
        address _stakerAddress,
        uint _stakerIndex
    )
        public 
        view
        returns (uint amount)
    {

        amount = stakerStakedContracts[
            _stakerAddress][_stakerIndex].unlockedAmount;
    }

    function pushUnlockedStakedTokens(
        address _stakerAddress,
        uint _stakerIndex,
        uint _amount
    )   
        public
        onlyInternal
    {   

        stakerStakedContracts[_stakerAddress][
            _stakerIndex].unlockedAmount = stakerStakedContracts[_stakerAddress][
                _stakerIndex].unlockedAmount.add(_amount);
    }

    function pushBurnedTokens(
        address _stakerAddress,
        uint _stakerIndex,
        uint _amount
    )   
        public
        onlyInternal
    {   

        stakerStakedContracts[_stakerAddress][
            _stakerIndex].burnedAmount = stakerStakedContracts[_stakerAddress][
                _stakerIndex].burnedAmount.add(_amount);
    }

    function pushUnlockableBeforeLastBurnTokens(
        address _stakerAddress,
        uint _stakerIndex,
        uint _amount
    )   
        public
        onlyInternal
    {   

        stakerStakedContracts[_stakerAddress][
            _stakerIndex].unLockableBeforeLastBurn = stakerStakedContracts[_stakerAddress][
                _stakerIndex].unLockableBeforeLastBurn.add(_amount);
    }

    function setUnlockableBeforeLastBurnTokens(
        address _stakerAddress,
        uint _stakerIndex,
        uint _amount
    )   
        public
        onlyInternal
    {   

        stakerStakedContracts[_stakerAddress][
            _stakerIndex].unLockableBeforeLastBurn = _amount;
    }

    function pushEarnedStakeCommissions(
        address _stakerAddress,
        address _stakedContractAddress,
        uint _stakedContractIndex,
        uint _commissionAmount
    )   
        public
        onlyInternal
    {

        stakedContractStakeCommission[_stakedContractAddress][_stakedContractIndex].
            commissionEarned = stakedContractStakeCommission[_stakedContractAddress][
                _stakedContractIndex].commissionEarned.add(_commissionAmount);
                
        emit Commission(
            _stakerAddress,
            _stakedContractAddress,
            _stakedContractIndex,
            _commissionAmount
        );
    }

    function pushRedeemedStakeCommissions(
        address _stakerAddress,
        uint _stakerIndex,
        uint _amount
    )   
        public
        onlyInternal
    {   

        uint stakedContractIndex = stakerStakedContracts[
            _stakerAddress][_stakerIndex].stakedContractIndex;
        address stakedContractAddress = stakerStakedContracts[
            _stakerAddress][_stakerIndex].stakedContractAddress;
        stakedContractStakeCommission[stakedContractAddress][stakedContractIndex].
            commissionRedeemed = stakedContractStakeCommission[
                stakedContractAddress][stakedContractIndex].commissionRedeemed.add(_amount);
    }

    function getStakerEarnedStakeCommission(
        address _stakerAddress,
        uint _stakerIndex
    )
        public 
        view
        returns (uint) 
    {

        return _getStakerEarnedStakeCommission(_stakerAddress, _stakerIndex);
    }

    function getStakerRedeemedStakeCommission(
        address _stakerAddress,
        uint _stakerIndex
    )
        public 
        view
        returns (uint) 
    {

        return _getStakerRedeemedStakeCommission(_stakerAddress, _stakerIndex);
    }

    function getStakerTotalEarnedStakeCommission(
        address _stakerAddress
    )
        public 
        view
        returns (uint totalCommissionEarned) 
    {

        totalCommissionEarned = 0;
        for (uint i = 0; i < stakerStakedContracts[_stakerAddress].length; i++) {
            totalCommissionEarned = totalCommissionEarned.
                add(_getStakerEarnedStakeCommission(_stakerAddress, i));
        }
    }

    function getStakerTotalReedmedStakeCommission(
        address _stakerAddress
    )
        public 
        view
        returns(uint totalCommissionRedeemed) 
    {

        totalCommissionRedeemed = 0;
        for (uint i = 0; i < stakerStakedContracts[_stakerAddress].length; i++) {
            totalCommissionRedeemed = totalCommissionRedeemed.add(
                _getStakerRedeemedStakeCommission(_stakerAddress, i));
        }
    }

    function setDepositCN(uint coverId, bool flag) public onlyInternal {


        if (flag == true) {
            require(!depositedCN[coverId].isDeposited, "Cover note already deposited");    
        }

        depositedCN[coverId].isDeposited = flag;
    }

    function setDepositCNAmount(uint coverId, uint amount) public onlyInternal {


        depositedCN[coverId].amount = amount;
    }

    function getStakedContractStakerByIndex(
        address _stakedContractAddress,
        uint _stakedContractIndex
    )
        public
        view
        returns (address stakerAddress)
    {

        stakerAddress = stakedContractStakers[
            _stakedContractAddress][_stakedContractIndex].stakerAddress;
    }

    function getStakedContractStakersLength(
        address _stakedContractAddress
    ) 
        public
        view
        returns (uint length)
    {

        length = stakedContractStakers[_stakedContractAddress].length;
    } 
    
    function addStake(
        address _stakerAddress,
        address _stakedContractAddress,
        uint _amount
    ) 
        public
        onlyInternal
        returns(uint scIndex) 
    {

        scIndex = (stakedContractStakers[_stakedContractAddress].push(
            Staker(_stakerAddress, stakerStakedContracts[_stakerAddress].length))).sub(1);
        stakerStakedContracts[_stakerAddress].push(
            Stake(_stakedContractAddress, scIndex, now, _amount, 0, 0, 0));
    }

    function bookCATokens(address _of) public onlyInternal {

        require(!isCATokensBooked(_of), "Tokens already booked");
        isBookedTokens[_of] = now.add(bookTime);
    }

    function isCATokensBooked(address _of) public view returns(bool res) {

        if (now < isBookedTokens[_of])
            res = true;
    }

    function setStakedContractCurrentCommissionIndex(
        address _stakedContractAddress,
        uint _index
    )
        public
        onlyInternal
    {

        stakedContractCurrentCommissionIndex[_stakedContractAddress] = _index;
    }

    function setLastCompletedStakeCommissionIndex(
        address _stakerAddress,
        uint _index
    )
        public
        onlyInternal
    {

        lastCompletedStakeCommission[_stakerAddress] = _index;
    }

    function setStakedContractCurrentBurnIndex(
        address _stakedContractAddress,
        uint _index
    )
        public
        onlyInternal
    {

        stakedContractCurrentBurnIndex[_stakedContractAddress] = _index;
    }

    function updateUintParameters(bytes8 code, uint val) public {

        require(ms.checkIsAuthToGoverned(msg.sender));
        if (code == "TOKEXP") {

            _setTokenExponent(val); 

        } else if (code == "TOKSTEP") {

            _setPriceStep(val);

        } else if (code == "RALOCKT") {

            _changeSCValidDays(val);

        } else if (code == "RACOMM") {

            _setStakerCommissionPer(val);

        } else if (code == "RAMAXC") {

            _setStakerMaxCommissionPer(val);

        } else if (code == "CABOOKT") {

            _changeBookTime(val * 1 hours);

        } else if (code == "CALOCKT") {

            _changelockCADays(val * 1 days);

        } else if (code == "MVLOCKT") {

            _changelockMVDays(val * 1 days);

        } else if (code == "QUOLOCKT") {

            _setLockTokenTimeAfterCoverExp(val * 1 days);

        } else if (code == "JOINFEE") {

            _setJoiningFee(val);

        } else {
            revert("Invalid param code");
        } 
    }

    function _getStakerEarnedStakeCommission(
        address _stakerAddress,
        uint _stakerIndex
    )
        internal
        view 
        returns (uint amount) 
    {

        uint _stakedContractIndex;
        address _stakedContractAddress;
        _stakedContractAddress = stakerStakedContracts[
            _stakerAddress][_stakerIndex].stakedContractAddress;
        _stakedContractIndex = stakerStakedContracts[
            _stakerAddress][_stakerIndex].stakedContractIndex;
        amount = stakedContractStakeCommission[
            _stakedContractAddress][_stakedContractIndex].commissionEarned;
    }

    function _getStakerRedeemedStakeCommission(
        address _stakerAddress,
        uint _stakerIndex
    )
        internal
        view 
        returns (uint amount) 
    {

        uint _stakedContractIndex;
        address _stakedContractAddress;
        _stakedContractAddress = stakerStakedContracts[
            _stakerAddress][_stakerIndex].stakedContractAddress;
        _stakedContractIndex = stakerStakedContracts[
            _stakerAddress][_stakerIndex].stakedContractIndex;
        amount = stakedContractStakeCommission[
            _stakedContractAddress][_stakedContractIndex].commissionRedeemed;
    }

    function _setStakerCommissionPer(uint _val) internal {

        stakerCommissionPer = _val;
    }

    function _setStakerMaxCommissionPer(uint _val) internal {

        stakerMaxCommissionPer = _val;
    }

    function _setTokenExponent(uint _val) internal {

        tokenExponent = _val;
    }

    function _setPriceStep(uint _val) internal {

        priceStep = _val;
    }

    function _changeSCValidDays(uint _days) internal {

        scValidDays = _days;
    }

    function _changeBookTime(uint _time) internal {

        bookTime = _time;
    }

    function _changelockCADays(uint _val) internal {

        lockCADays = _val;
    }
    
    function _changelockMVDays(uint _val) internal {

        lockMVDays = _val;
    }

    function _setLockTokenTimeAfterCoverExp(uint time) internal {

        lockTokenTimeAfterCoverExp = time;
    }

    function _setJoiningFee(uint _amount) internal {

        joiningFee = _amount;
    }
}