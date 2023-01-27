
pragma solidity 0.5.11;

contract TheChosenOne {



    event OnPlayerEnter(
        address _player,
        uint8 indexed _quality,
        uint16 indexed _proto
    );

    event OnPlayerExit(
        address _player,
        uint8 indexed _quality,
        uint16 indexed _proto
    );

    event OnChosenOneSelected(
        address indexed _chosenOne,
        uint8 indexed _quality,
        uint16 indexed _proto
    );

    struct Player {
        uint256 tokenId;
        address owner;
    }


    mapping(uint16 => mapping(uint8 => Player[])) public arenas;

    uint256 public quorum = 5;

    address public tokenAddress;

    interfaceERC721 public tokenInterface;


    constructor(address _tokenAddress)
        public
    {
        tokenInterface = interfaceERC721(_tokenAddress);
    }


    modifier onlyEOA() {

        require(msg.sender == tx.origin, "only externally owned accounts");
        _;
    }


    function activateArena(uint16 proto, uint8 quality)
        public
        onlyEOA
    {

        Player[] storage players = arenas[proto][quality];

        require(players.length == quorum, "requires minimum number of players");

        uint256 random = getRandom(quorum, proto, quality);

        address theChosenOne = players[random].owner;

        for(uint256 i = players.length - 1; i >= 0; i--) {
            tokenInterface.transferFrom(address(this), theChosenOne, players[i].tokenId);
            players.pop();
        }

        emit OnChosenOneSelected(theChosenOne, quality, proto);
    }

    function exitArena(uint16 proto, uint8 quality, uint256 index)
        private
    {

        Player[] storage arena = arenas[proto][quality];

        require(arena[index].owner == msg.sender, "Must be the player");

        uint256 tokenId = arena[index].tokenId;

        arena[index] = arena[arena.length - 1];

        arena.pop();

        tokenInterface.transferFrom(address(this), msg.sender, tokenId);

        emit OnPlayerExit(msg.sender, quality, proto);
    }


    function onERC721Received(address /*_operator*/, address _from, uint256 _tokenId, bytes calldata /*_data*/)
        external
        returns(bytes4)
    {

        require(msg.sender == tokenAddress, "must be the token address");

        require(tx.origin == _from, "token owner must be an externally owned account");

        (uint16 proto, uint8 quality) = tokenInterface.getDetails(_tokenId);

        require(arenas[proto][quality].length < quorum, "Max Players Reached");

        arenas[proto][quality].push(Player({
            tokenId: _tokenId,
            owner: _from
        }));

        emit OnPlayerEnter(_from, quality, proto);

        return 0x150b7a02;
    }


    function getRandom(uint256 max, uint16 proto, uint8 quality)
        private
        view
        returns(uint256 random)
    {

        uint256 blockhash_ = uint256(blockhash(block.number - 1));

        random = uint256(keccak256(abi.encodePacked(
            block.timestamp,
            block.coinbase,
            block.difficulty,
            blockhash_,
            proto,
            quality
        ))) % max;
    }
}

contract interfaceERC721 {

    function getDetails(uint256 _tokenId) public view returns (uint16, uint8);

    function transferFrom(address from, address to, uint256 tokenId) public;

}