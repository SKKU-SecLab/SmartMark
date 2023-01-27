
pragma solidity ^0.8.0;









abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

interface BGANPUNKSV2 {

    function calculatePrice() external view returns (uint256);


    function adoptBASTARD(uint256 numBastards) external payable;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


    function totalSupply() external view returns (uint256);

}


contract BASTARDGANPUNKSV2PROXYSALE is Ownable, IERC721Receiver {


    address payable public treasuryAddress;

    uint256 public startTime;
    bool public saleRunning = false;

    uint256 private two = 2;
    uint256 public startprice; 
    uint256 public discountPerSecond;
    uint256 public halvingTimeInterval;

    address public BGANPUNKSV2ADDRESS =
        0x31385d3520bCED94f77AaE104b406994D8F2168C;

    struct Charity {
        string name;
        address charityAddress;
    }

    Charity[] public charities;
    
    event saleStarted( uint indexed startTime, uint indexed startPrice, uint indexed halvingTimeInterval);
    event charityAdded(string indexed _name, address indexed _address);
    event charityEdited(uint indexed _index, string indexed _name, address indexed _address);
    event charityRemoved(uint indexed _index);
    event donationSent(string indexed charityName, uint indexed amount);

    constructor(address payable _treasuryAddress) {
        treasuryAddress = _treasuryAddress;
    }

    receive() external payable {}

    function startSale(uint256 _startPrice, uint256 _halvingInterval)
        public
        onlyOwner
    {

        startTime = block.timestamp;
        startprice = _startPrice;
        halvingTimeInterval = _halvingInterval;
        discountPerSecond = startprice / halvingTimeInterval / two;
        saleRunning = true;
        emit saleStarted(startTime, _startPrice, _halvingInterval);
    }

    function pauseSale() public onlyOwner {

        saleRunning = false;
    }
    function resumeSale() public onlyOwner {

        saleRunning = true;
    }


    function addCharity(address _address, string memory _name)
        public
        onlyOwner
    {

        charities.push(Charity(_name, _address));
        emit charityAdded(_name, _address);
    }
    
    
    function editCharity(
        uint256 index,
        address _address,
        string memory _name
    ) public onlyOwner {

        charities[index].name = _name;
        charities[index].charityAddress = _address;
        emit charityEdited(index, _name, _address);

    }


    function removeCharityNoOrder(uint index)
        public
        onlyOwner
    {

        charities[index] = charities[charities.length - 1];
        charities.pop();
        emit charityRemoved(index);
    }

    function getCharityCount() public view returns (uint256) {

        return charities.length;
    }

    function getCharities() public view returns (Charity[] memory) {

        return charities;
    }
    
    function getCharity(uint index) public view returns (Charity memory) {

        require(index < charities.length, "YOU REQUESTED A CHARITY OUTSIDE THE RANGE PAL");
        return charities[index];
    }


    function howManySecondsElapsed() public view returns (uint256) {

        if(saleRunning) {
        return block.timestamp - startTime;
        } else {
            return 0;
        }
    }

    function calculateDiscountedPrice() public view returns (uint256) {

        require(saleRunning, "SALE HASN'T STARTED OR PAUSED");

        uint256 elapsed = block.timestamp - startTime;
        uint256 factorpow = elapsed / halvingTimeInterval;
        uint256 priceFactor = two ** factorpow;

        uint256 howmanyseconds =
            elapsed % halvingTimeInterval * discountPerSecond / priceFactor;

        uint256 finalPrice = startprice / priceFactor - howmanyseconds;
        return finalPrice;
    }

    function calculateDiscountedPriceTest(uint256 elapsedTime)
        public
        view
        returns (uint256)
    {

        require(saleRunning, "SALE HASN'T STARTED OR PAUSED");
        uint256 factorpow = elapsedTime / halvingTimeInterval;
        uint256 priceFactor = two**factorpow;

        uint256 howmanyseconds =
            elapsedTime % halvingTimeInterval * discountPerSecond / priceFactor;

        uint256 finalPrice = startprice / priceFactor - howmanyseconds;
        return finalPrice;
    }

    function adoptCheaperBASTARD(uint256 _charitychoice, uint256 _amount)
        public
        payable
    {

        uint256 originalPrice =
            BGANPUNKSV2(BGANPUNKSV2ADDRESS).calculatePrice() * _amount;

        require(
            msg.value >= calculateDiscountedPrice() * _amount,
            "YOU HAVEN'T PAID ENOUGH LOL"
        );
        require(
            _charitychoice < charities.length,
            "U CHOSE A CHARITY THAT DOESN'T EXIST"
        );

        payable(charities[_charitychoice].charityAddress).transfer(msg.value);

        BGANPUNKSV2(BGANPUNKSV2ADDRESS).adoptBASTARD{value: originalPrice}(
            _amount
        );
        uint256 total = BGANPUNKSV2(BGANPUNKSV2ADDRESS).totalSupply();
        for (uint256 i = total - _amount; i < total; i++) {
            BGANPUNKSV2(BGANPUNKSV2ADDRESS).safeTransferFrom(
                address(this),
                msg.sender,
                i,
                ""
            );
        }
        emit donationSent(charities[_charitychoice].name, msg.value);
    }


    function addFundsToContract() public payable onlyOwner {

        payable(address(this)).transfer(msg.value);
    }

    function returnFunds() public onlyOwner {

        treasuryAddress.transfer(address(this).balance);
    }

    function setTreasuryAddress(address payable _address) public onlyOwner {

        treasuryAddress = _address;
    }


    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}