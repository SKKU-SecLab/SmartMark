

pragma solidity 0.8.3;




interface ERC721TokenReceiver {

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) external returns(bytes4);

}


contract EvohERC721 {


    string public name;
    string public symbol;
    uint256 public totalSupply;

    mapping(bytes4 => bool) public supportsInterface;

    struct UserData {
        uint256 balance;
        uint256[4] ownership;
    }
    mapping(address => UserData) userData;

    address[1024] tokenOwners;
    address[1024] tokenApprovals;
    mapping(uint256 => string) tokenURIs;

    mapping (address => mapping (address => bool)) private operatorApprovals;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        supportsInterface[_INTERFACE_ID_ERC165] = true;
        supportsInterface[_INTERFACE_ID_ERC721] = true;
        supportsInterface[_INTERFACE_ID_ERC721_METADATA] = true;
        supportsInterface[_INTERFACE_ID_ERC721_ENUMERABLE] = true;
    }

    function balanceOf(address _owner) external view returns (uint256) {

        require(_owner != address(0), "Query for zero address");
        return userData[_owner].balance;
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        if (tokenId < 1024) {
            address owner = tokenOwners[tokenId];
            if (owner != address(0)) return owner;
        }
        revert("Query for nonexistent tokenId");
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {

        require(_from != address(0));
        require(_to != address(0));
        address owner = ownerOf(_tokenId);
        if (
            msg.sender == owner ||
            getApproved(_tokenId) == msg.sender ||
            isApprovedForAll(owner, msg.sender)
        ) {
            delete tokenApprovals[_tokenId];
            removeOwnership(_from, _tokenId);
            addOwnership(_to, _tokenId);
            emit Transfer(_from, _to, _tokenId);
            return;
        }
        revert("Caller is not owner nor approved");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public {

        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "Transfer to non ERC721 receiver");
    }

    function removeOwnership(address _owner, uint256 _tokenId) internal {

        UserData storage data = userData[_owner];
        data.balance -= 1;
        uint256 idx = _tokenId / 256;
        uint256 bitfield = data.ownership[idx];
        data.ownership[idx] = bitfield & ~(uint256(1) << (_tokenId % 256));
    }

    function addOwnership(address _owner, uint256 _tokenId) internal {

        tokenOwners[_tokenId] = _owner;
        UserData storage data = userData[_owner];
        data.balance += 1;
        uint256 idx = _tokenId / 256;
        uint256 bitfield = data.ownership[idx];
        data.ownership[idx] = bitfield | uint256(1) << (_tokenId % 256);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {

        safeTransferFrom(_from, _to, _tokenId, bytes(""));
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external {

        _transfer(_from, _to, _tokenId);
    }

    function approve(address approved, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "Not owner nor approved for all"
        );
        tokenApprovals[tokenId] = approved;
        emit Approval(owner, approved, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        ownerOf(tokenId);
        return tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {

        operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return operatorApprovals[owner][operator];
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {

        ownerOf(tokenId);
        return tokenURIs[tokenId];
    }

    function tokenByIndex(uint256 _index) external view returns (uint256) {

        require(_index < totalSupply, "Index out of bounds");
        return _index;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {

        UserData storage data = userData[_owner];
        require (_index < data.balance, "Index out of bounds");
        uint256 bitfield;
        uint256 count;
        for (uint256 i = 0; i < 1024; i++) {
            uint256 key = i % 256;
            if (key == 0) {
                bitfield = data.ownership[i / 256];
            }
            if ((bitfield >> key) & uint256(1) == 1) {
                if (count == _index) {
                    return i;
                }
                count++;
            }
        }
        revert();
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    )
        private
        returns (bool)
    {

        uint256 size;
        assembly { size := extcodesize(to) }
        if (size == 0) {
            return true;
        }

        (bool success, bytes memory returnData) = to.call{ value: 0 }(
            abi.encodeWithSelector(
                ERC721TokenReceiver(to).onERC721Received.selector,
                msg.sender,
                from,
                tokenId,
                _data
            )
        );
        require(success, "Transfer to non ERC721 receiver");
        bytes4 returnValue = abi.decode(returnData, (bytes4));
        return (returnValue == _ERC721_RECEIVED);
    }

}


contract EvohClaimable is EvohERC721 {


    uint256 public maxTotalSupply;
    bytes32 public hashRoot;
    address public owner;
    uint256 public startTime;

    struct ClaimData {
        bytes32 root;
        uint256 count;
        uint256 limit;
        mapping(address => bool) claimed;
    }

    ClaimData[] public claimData;

    constructor(
        string memory _name,
        string memory _symbol,
        bytes32 _hashRoot,
        uint256 _maxTotalSupply,
        uint256 _startTime
    )
        EvohERC721(_name, _symbol)
    {
        owner = msg.sender;
        hashRoot = _hashRoot;
        maxTotalSupply = _maxTotalSupply;
        startTime = _startTime;
    }

    function addClaimRoots(bytes32[] calldata _merkleRoots, uint256[] calldata _claimLimits) external {

        require(msg.sender == owner);
        for (uint256 i = 0; i < _merkleRoots.length; i++) {
            ClaimData storage data = claimData.push();
            data.root = _merkleRoots[i];
            data.limit = _claimLimits[i];
        }
    }

    function isClaimed(uint256 _claimIndex, address _account) public view returns (bool) {

        return claimData[_claimIndex].claimed[_account];
    }

    function claim(
        uint256 _claimIndex,
        bytes32[] calldata _claimProof
    )
        external
    {

        require(block.timestamp >= startTime, "Cannot claim before start time");
        uint256 claimed = totalSupply;
        require(maxTotalSupply > claimed, "All NFTs claimed");

        bytes32 node = keccak256(abi.encodePacked(msg.sender));
        ClaimData storage data = claimData[_claimIndex];

        require(_claimIndex < claimData.length, "Invalid merkleIndex");
        require(data.count < data.limit, "All NFTs claimed in this airdrop");
        require(!data.claimed[msg.sender], "User has claimed in this airdrop");
        require(verify(_claimProof, data.root, node), "Invalid claim proof");

        data.count++;
        data.claimed[msg.sender] = true;

        addOwnership(msg.sender, claimed);
        emit Transfer(address(0), msg.sender, claimed);
        totalSupply = claimed + 1;
    }

    function submitHashes(
        uint256[] calldata _indexes,
        string[] calldata _hashes,
        bytes32[][] calldata _proofs
    ) external {

        require(_indexes.length == _proofs.length);
        bytes32 root = hashRoot;
        for (uint256 i = 0; i < _indexes.length; i++) {
            bytes32 node = keccak256(abi.encodePacked(_indexes[i], _hashes[i]));
            require(verify(_proofs[i], root, node), "Invalid hash proof");
            tokenURIs[_indexes[i]] = _hashes[i];
        }
    }

    function verify(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    )
        internal
        pure
        returns (bool)
    {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }

}