
pragma solidity 0.5.11;

contract FissionPool {



    event OnAddPlayer(
        uint256 indexed _poolId,
        address indexed _owner,
        uint256 _tokenId
    );

    event OnCancelPool(
        uint256 indexed _poolId
    );

    event OnCollect(
        uint256 indexed _poolId
    );

    event OnCreatePool(
        uint256 indexed _poolId,
        address indexed _host,
        uint16 _proto,
        uint8 _quality,
        uint256 _quorum,
        uint256 _tokenId
    );

    event OnRemovePlayer(
        uint256 indexed _poolId,
        uint256 _index
    );

    event OnWinner(
        uint256 indexed _poolId,
        address indexed _winner,
        uint256 _random
    );

    struct Pool {
        address host;
        Player[] players;
        uint16 proto;
        uint8 quality;
        uint256 quorum;
        uint256 tokenId;
    }

    struct Player {
        address owner;
        uint256 tokenId;
    }


    mapping(uint256 => Pool) public pools;

    address public tokenAddress;

    interfaceERC721 public tokenInterface;

    uint256 public totalPools;


    constructor(address _tokenAddress)
        public
    {
        tokenInterface = interfaceERC721(_tokenAddress);
    }


    modifier onlyEOA() {

        require(msg.sender == tx.origin, "only externally owned accounts");
        _;
    }


    function activatePool(uint256 poolId)
        public
        onlyEOA
    {

        Pool storage pool = pools[poolId];

        require( pool.quorum > 0 && pool.players.length == pool.quorum, "requires minimum number of players");

        uint256 random = getRandom(pool.quorum, poolId);

        address winner = pool.players[random].owner;

        delete pool.quorum;

        tokenInterface.transferFrom(address(this), winner, pool.tokenId);

        emit OnWinner(poolId, winner, random);
    }

    function cancelPool(uint256 poolId)
        public
        onlyEOA
    {

        Pool storage pool = pools[poolId];

        require(pool.quorum > 0, "must be an active pool");

        require(pool.host == msg.sender, "must be the host");

        if (pool.players.length > 0) {
            for(uint256 i = pool.players.length - 1; i >= 0; i--) {
                tokenInterface.transferFrom(address(this), pool.players[i].owner, pool.players[i].tokenId);
                pool.players.pop();
            }
        }

        address host = pool.host;
        uint256 tokenId = pool.tokenId;

        delete pools[poolId];

        tokenInterface.transferFrom(address(this), host, tokenId);

        emit OnCancelPool(poolId);
    }

    function collectCards(uint256 poolId)
        public
    {

        Pool storage pool = pools[poolId];

        require(pool.host == msg.sender, "must be the host");

        require(pool.quorum == 0, "pool not activated");

        for(uint256 i = pool.players.length - 1; i >= 0; i--) {
            tokenInterface.transferFrom(address(this), pool.host, pool.players[i].tokenId);
            pool.players.pop();
        }

        delete pools[poolId];

        emit OnCollect(poolId);
    }

    function exitPool(uint256 poolId, uint256 index)
        public
        onlyEOA
    {

        Player[] storage players = pools[poolId].players;

        require(players[index].owner == msg.sender, "Must be the player");

        uint256 tokenId = players[index].tokenId;

        players[index] = players[players.length - 1];

        players.pop();

        tokenInterface.transferFrom(address(this), msg.sender, tokenId);

        emit OnRemovePlayer(poolId, index);
    }


    function getPool(uint256 poolId)
        public
        view
        returns(uint256 _tokenId, address _host, uint16 _proto, uint8 _quality, uint256 _quorum, address[] memory _players, uint256[] memory _tokenIds)
    {

        Pool storage pool = pools[poolId];

        _host = pool.host;
        _proto = pool.proto;
        _quality = pool.quality;
        _quorum = pool.quorum;
        _tokenId = pool.tokenId;

        for(uint256 i = 0; i < pool.players.length; i++) {
            _players[i] = pool.players[i].owner;
            _tokenIds[i] = pool.players[i].tokenId;
        }
    }


    function onERC721Received(address /*_operator*/, address _from, uint256 _tokenId, bytes calldata _data)
        external
        returns(bytes4)
    {

        require(msg.sender == tokenAddress, "must be the token address");

        require(tx.origin == _from, "token owner must be an externally owned account");

        (uint256 poolId, uint256 quorum) = abi.decode(_data, (uint256, uint256));

        (uint16 proto, uint8 quality) = tokenInterface.getDetails(_tokenId);

        if (poolId == 0) {
            createPool(_from, proto, quality, quorum, _tokenId);
        } else {
            joinPool(poolId, _from, proto, quality, _tokenId);
        }

        return 0x150b7a02;
    }


    function createPool(address host, uint16 proto, uint8 quality, uint256 quorum, uint256 tokenId)
        private
    {

        require(quality < 4, "Must be Shadow, Gold, or Diamond");

        require(quorum > 0 && quorum < 11, "must be an integer from 1 to 10");

        totalPools = totalPools + 1;

        Pool storage pool = pools[totalPools];

        pool.host = host;
        pool.proto = proto;
        pool.quality = quality + 1;
        pool.quorum = quorum;
        pool.tokenId = tokenId;

        emit OnCreatePool(totalPools, host, proto, quality, quorum, tokenId);
    }

    function joinPool(uint256 poolId, address owner, uint16 proto, uint8 quality, uint256 tokenId)
        private
    {

        Pool storage pool = pools[poolId];

        require(pool.quorum > 0, "invalid pool");

        require(pool.players.length < pool.quorum, "full pool");

        require(proto == pool.proto, "proto must match");

        require(quality == pool.quality, "quality must match");

        pool.players.push(Player(owner, tokenId));

        emit OnAddPlayer(poolId, owner, tokenId);
    }

    function getRandom(uint256 max, uint256 poolId)
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
            poolId
        ))) % max;
    }
}

contract interfaceERC721 {

    function getDetails(uint256 _tokenId) public view returns (uint16, uint8);

    function transferFrom(address from, address to, uint256 tokenId) public;

}