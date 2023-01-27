
pragma solidity >=0.8.0 <0.9.0;

interface ERC721 {

    function ownerOf(uint256 _tokenId) external view returns (address);

}


function isNftOwner(address nft, uint256 tokenid, address owner) view returns (bool) {
    address addr = ERC721(nft).ownerOf(tokenid);
    return addr == owner;
}

function min(uint256 a, uint256 b) pure returns (uint256) {
    return a < b ? a : b;
}


contract RedPacket {

    address feeOwner;
    uint256 feeValue;
    
    struct Packet {
        bool seald;  // if true, the envelope can't modify.
        bool secret; // if true, hide the value  
        uint value;  // the money stored in.
    }
    
    mapping(address => mapping(uint256 => Packet)) packets;
    
    constructor()  {
        feeOwner = msg.sender;
    }

    function send(address payable nft, uint256 tokenid, bool secret) public payable {

        address owner = msg.sender;
        Packet memory env = packets[nft][tokenid];
        
        require(!env.seald, "sealed envelope can't modify.");
        require(isNftOwner(nft, tokenid, owner), "only nft owner can store money.");
        
        packets[nft][tokenid] = Packet(true, secret, msg.value);
    }
  
    function open(address payable nft, uint256 tokenid) public {

        address owner = msg.sender;
        Packet memory env = packets[nft][tokenid];
        
        require(env.seald, "it's not a valid envelope.");
        require(isNftOwner(nft, tokenid, owner), "only nft owner can withdraw money.");
        
        uint256 fee = min(0.001 ether, env.value/1000);
        uint256 value = env.value - fee;
        
        feeValue += fee;
        packets[nft][tokenid] = Packet(false, false, 0);
        
        payable(owner).transfer(value);
        
        assert(env.value >= fee);
    }
    
    function peep(address nft, uint256 tokenid) public view returns(Packet memory) {

        Packet memory env = packets[nft][tokenid];
        if (env.secret && !isNftOwner(nft, tokenid, msg.sender))  {
            env.value = 0;
        }
        return env;
    }
    
    function withdrawFee() public {

        require(feeOwner == msg.sender, "only contract owner can withdraw");
        require(feeValue > 0, "no fee no withdraw");
        
        require(address(this).balance >= feeValue);
        
        uint256 value = feeValue;
        
        feeValue = 0;
        payable(feeOwner).transfer(value);
        
        assert(feeValue == 0);
    }
    
    function getFeeValue() public view returns(uint256) {

        require(feeOwner == msg.sender, "only contract owner can see fee value");
        
        return feeValue;
    }
}