
pragma solidity >=0.4.23 <0.6.0;

interface UmiTokenInterface {

    function putIntoBlacklist(address _addr) external;


    function removeFromBlacklist(address _addr) external;


    function inBlacklist(address _addr) external view returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function mint(address account, uint256 amount) external returns (bool);


    function balanceOf(address account) external view returns (uint256);

}

interface UniSageInterface {

    function isUserExists(address user) external view returns (bool);

}

contract UMIChrismas {

    address owner;

    address public umiTokenAddr = 0x3B4005397f57804BEbFAf5B0aFA3B2DD13CD7F0F;
    UmiTokenInterface public umiToken = UmiTokenInterface(umiTokenAddr);

    address public unisageAddr = 0xf61DdA9A827cff208b6242FCF72AD1bB2006A995;
    UniSageInterface public unisage = UniSageInterface(unisageAddr);

    bool public open = true;

    uint256 public totalAirdropAmount = 100000000000000000000000;
    uint256 public singleAirdropAmount = 100000000000000000000;
    uint256 public singleAirdropAmountForReferrer = 0;

    uint256 public hasAirdropAmount = 0;

    mapping(address => bool) public successList;

    event chrismasAirdropEvent(address indexed userAddr, uint256 airdropAmount);

    constructor() public {
        owner = msg.sender;
    }


    function isUserJoined(address user) public view returns (bool) {

        return successList[user];
    }

    function getChrismasAirdrop() external {

        require(open, "umi chrismas has been closed");

        bool isInblacklist = umiToken.inBlacklist(msg.sender);
        require(!isInblacklist, "address is in blacklist");

        bool isRegisterd = unisage.isUserExists(msg.sender);
        require(!isRegisterd, "address is exsits");

        bool isJoined = isUserJoined(msg.sender);
        require(!isJoined, "address has been join already");

        require(
            hasAirdropAmount + singleAirdropAmount <= totalAirdropAmount,
            "the remain airdrop amount is not enough"
        );

        umiToken.transfer(msg.sender,singleAirdropAmount);
        umiToken.putIntoBlacklist(msg.sender);

        hasAirdropAmount = hasAirdropAmount + singleAirdropAmount;

        successList[msg.sender] = true;

        emit chrismasAirdropEvent(msg.sender, singleAirdropAmount);
    }

    function refreshOpen(bool _open) external {

        require(msg.sender == owner, "only owner can do this operation");
        open = _open;
    }

    function changeTotalAirdropAmount(uint256 amount) external {

        require(msg.sender == owner, "only owner can do this operation");
        totalAirdropAmount = amount;
    }

    function changeSingleAirdropAmount(uint256 amount) external {

        require(msg.sender == owner, "only owner can do this operation");
        singleAirdropAmount = amount;
    }

    function changeSingleAirdropAmountForReferrer(uint256 amount) external {

        require(msg.sender == owner, "only owner can do this operation");
        singleAirdropAmountForReferrer = amount;
    }

    function changeUmiTokenAddr(address _addr) external {

        require(msg.sender == owner, "only owner can do this operation");
        umiTokenAddr = _addr;
        umiToken = UmiTokenInterface(umiTokenAddr);
    }

    function changeUnisageAddr(address _addr) external {

        require(msg.sender == owner, "only owner can do this operation");
        unisageAddr = _addr;
        unisage = UniSageInterface(umiTokenAddr);
    }
}