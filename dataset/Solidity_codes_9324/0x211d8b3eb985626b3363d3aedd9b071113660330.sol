
pragma solidity 0.4.24;
pragma experimental "v0.5.0";
library SafeMath {


    function mul(uint256 a, uint256 b) internal pure  returns (uint256) {

        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

interface RTCoinInterface {

    

    function transfer(address _recipient, uint256 _amount) external returns (bool);


    function transferFrom(address _owner, address _recipient, uint256 _amount) external returns (bool);


    function approve(address _spender, uint256 _amount) external returns (bool approved);


    function totalSupply() external view returns (uint256);


    function balanceOf(address _holder) external view returns (uint256);


    function allowance(address _owner, address _spender) external view returns (uint256);


    function mint(address _recipient, uint256 _amount) external returns (bool);


    function stakeContractAddress() external view returns (address);


    function mergedMinerValidatorAddress() external view returns (address);

    
    function freezeTransfers() external returns (bool);


    function thawTransfers() external returns (bool);

}


contract Vesting {


    using SafeMath for uint256;

    address constant public TOKENADDRESS = 0xecc043b92834c1ebDE65F2181B59597a6588D616;
    RTCoinInterface constant public RTI = RTCoinInterface(TOKENADDRESS);
    string constant public VERSION = "production";

    address public admin;

    enum VestState {nil, vesting, vested}

    struct Vest {
        uint256 totalVest;
        uint256[] releaseDates;
        uint256[] releaseAmounts;
        VestState state;
        mapping (uint256 => bool) claimed;
    }

    mapping (address => Vest) public vests;

    modifier validIndex(uint256 _vestIndex) {

        require(_vestIndex < vests[msg.sender].releaseDates.length, "attempting to access invalid vest index must be less than length of array");
        _;
    }

    modifier pastClaimDate(uint256 _vestIndex) {

        require(now >= vests[msg.sender].releaseDates[_vestIndex], "attempting to claim vest before release date");
        _;
    }

    modifier unclaimedVest(uint256 _vestIndex) {

        require(!vests[msg.sender].claimed[_vestIndex], "vest must be unclaimed");
        _;
    }

    modifier activeVester() {

        require(vests[msg.sender].state == VestState.vesting, "vest must be active");
        _;
    }

    modifier nonActiveVester(address _vester) {

        require(vests[_vester].state == VestState.nil, "address must not have an active vest");
        _;
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, "sender must be admin");
        _;
    }

    constructor(address _admin) public {
        require(TOKENADDRESS != address(0), "token address not set");
        admin = _admin;
    }

    function addVest(
        address _vester,
        uint256 _totalAmountToVest,
        uint256[] _releaseDates, // unix time stamp format `time.Now().Unix()` in golang
        uint256[] _releaseAmounts)
        public
        nonActiveVester(_vester)
        onlyAdmin
        returns (bool)
    {

        require(_releaseDates.length > 0 && _releaseAmounts.length > 0 && _totalAmountToVest > 0, "attempting to use non zero values");
        require(_releaseDates.length == _releaseAmounts.length, "array lengths are not equal");
        uint256 total;
        for (uint256 i = 0; i < _releaseAmounts.length; i++) {
            total = total.add(_releaseAmounts[i]);
            require(now < _releaseDates[i], "release date must be in the future");
        }
        require(total == _totalAmountToVest, "invalid total amount to vest");
        Vest memory v = Vest({
            totalVest: _totalAmountToVest,
            releaseDates: _releaseDates,
            releaseAmounts: _releaseAmounts,
            state: VestState.vesting
        });
        vests[_vester] = v;
        require(RTI.transferFrom(msg.sender, address(this), _totalAmountToVest), "transfer from failed, most likely needs approval");
        return true;
    }


    function withdrawVestedTokens(
        uint256 _vestIndex)
        public
        activeVester
        validIndex(_vestIndex)
        unclaimedVest(_vestIndex)
        pastClaimDate(_vestIndex)
        returns (bool)
    {

        if (_vestIndex == vests[msg.sender].releaseAmounts.length.sub(1)) {
            bool check;
            for (uint256 i = 0; i < vests[msg.sender].releaseAmounts.length; i++) {
                if (!vests[msg.sender].claimed[i]) {
                    check = false;
                    break;
                }
                check = true;
            }
            require(check, "not all vests have been withdrawn before attempting to withdraw final vest");
            vests[msg.sender].state = VestState.vested;
        }
        vests[msg.sender].claimed[_vestIndex] = true;
        uint256 amount = vests[msg.sender].releaseAmounts[_vestIndex];
        require(RTI.transfer(msg.sender, amount), "failed to transfer");
        return true;
    }
}