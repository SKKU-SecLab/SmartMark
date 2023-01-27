
pragma solidity ^0.4.24;


interface Emojisan {


    function ownerOf(uint tokenId) external view returns (address);

    function balanceOf(address owner) external view returns (uint);

    function transferFrom(address from, address to, uint tokenId) external;

    function mint(uint tokenId) external;

    function setMinter(address newMinter) external;

}

contract EmojisanAuctionHouse {


    event Bid(uint indexed tokenId);

    struct Auction {
        address owner;
        uint128 currentPrice;
    }

    struct User {
        uint128 balance;
        uint32 bidBlock;
    }

    Emojisan public constant emojisan = Emojisan(0xE3f2F807ba194ea0221B9109fb14Da600C9e1eb6);

    uint[] public tokenByIndex;
    mapping (uint => Auction) public auction;
    mapping (address => User) public user;
    uint32 private constant auctionTime = 20000;

    address public whaleAddress;
    uint32 public whaleStartTime;
    uint128 public whaleBalance;
    uint32 private constant whaleWithdrawDelay = 80000;

    uint128 public ownerBalance;
    uint private constant ownerTokenId = 128512;

    function tokens() external view returns (uint[]) {

        return tokenByIndex;
    }

    function tokensCount() external view returns (uint) {

        return tokenByIndex.length;
    }

    function wantItForFree(uint tokenId) external {

        require(block.number >= user[msg.sender].bidBlock + auctionTime);
        require(auction[tokenId].owner == address(this));
        auction[tokenId].owner = msg.sender;
        user[msg.sender].bidBlock = uint32(block.number);
        emojisan.mint(tokenId);
        emit Bid(tokenId);
    }

    function wantItMoreThanYou(uint tokenId) external payable {

        require(block.number >= user[msg.sender].bidBlock + auctionTime);
        address previousOwner = auction[tokenId].owner;
        require(block.number < user[previousOwner].bidBlock + auctionTime);
        uint128 previousPrice = auction[tokenId].currentPrice;
        uint128 price;
        if (previousPrice == 0) {
            price = 2 finney;
        } else if (previousPrice < 500 finney) {
            price = 2 * previousPrice;
        } else {
            price = (previousPrice + 500 finney) / 500 finney * 500 finney;
        }
        require(msg.value >= price);
        uint128 priceDiff = price - previousPrice;
        user[previousOwner] = User({
            balance: previousPrice + priceDiff / 4,
            bidBlock: 0
        });
        whaleBalance += priceDiff / 2;
        ownerBalance += priceDiff / 4;
        auction[tokenId] = Auction({
            owner: msg.sender,
            currentPrice: price
        });
        user[msg.sender].bidBlock = uint32(block.number);
        if (msg.value > price) {
            msg.sender.transfer(msg.value - price);
        }
        emit Bid(tokenId);
    }

    function wantMyToken(uint tokenId) external {

        Auction memory a = auction[tokenId];
        require(block.number >= user[a.owner].bidBlock + auctionTime);
        emojisan.transferFrom(this, a.owner, tokenId);
    }

    function wantMyEther() external {

        uint amount = user[msg.sender].balance;
        user[msg.sender].balance = 0;
        msg.sender.transfer(amount);
    }

    function wantToBeWhale() external {

        require(emojisan.balanceOf(msg.sender) > emojisan.balanceOf(whaleAddress));
        whaleAddress = msg.sender;
        whaleStartTime = uint32(block.number);
    }

    function whaleWantMyEther() external {

        require(msg.sender == whaleAddress);
        require(block.number >= whaleStartTime + whaleWithdrawDelay);
        whaleStartTime = uint32(block.number);
        uint amount = whaleBalance;
        whaleBalance = 0;
        whaleAddress.transfer(amount);
    }

    function ownerWantMyEther() external {

        uint amount = ownerBalance;
        ownerBalance = 0;
        emojisan.ownerOf(ownerTokenId).transfer(amount);
    }

    function wantNewTokens(uint[] tokenIds) external {

        require(msg.sender == emojisan.ownerOf(ownerTokenId));
        for (uint i = 0; i < tokenIds.length; i++) {
            auction[tokenIds[i]].owner = this;
            tokenByIndex.push(tokenIds[i]);
        }
    }

    function wantNewMinter(address minter) external {

        require(msg.sender == emojisan.ownerOf(ownerTokenId));
        emojisan.setMinter(minter);
    }
}