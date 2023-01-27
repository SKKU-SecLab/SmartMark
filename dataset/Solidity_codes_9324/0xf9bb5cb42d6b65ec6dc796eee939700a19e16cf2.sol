

pragma solidity 0.8.4;


contract SNUFFY500 {

    CollectionData private _collectionData;

    uint256 private _currentTokenId;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    mapping(uint256 => address) private _tokenOwner;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => uint256) private _ownedTokensCount;

    mapping(address => uint256[]) private _ownedTokens;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(uint256 => TokenData) private _tokenData;

    address private _admin;

    address private _owner;

    uint256 private _totalTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed wallet, address indexed operator, uint256 indexed tokenId);

    event ApprovalForAll(address indexed wallet, address indexed operator, bool approved);

    event PermanentURI(string uri, uint256 indexed id);

    constructor() {}

    function getStatesConfig() public view returns (uint256 max, uint256 limit, uint256 future0, uint256 future1, uint256 future2, uint256 future3) {

        return SnuffyToken.getStatesConfig();
    }

    function setStatesConfig(uint256 max, uint256 limit, uint256 future0, uint256 future1, uint256 future2, uint256 future3) public onlyOwner {

        SnuffyToken.setStatesConfig(max, limit, future0, future1, future2, future3);
    }

    function getStateTimestamps() public view returns (uint256[8] memory) {

        return SnuffyToken.getStateTimestamps();
    }

    function setStateTimestamps(uint256[8] memory _timestamps) public onlyOwner {

        SnuffyToken.setStateTimestamps(_timestamps);
    }

    function getMutationRequirements() public view returns (uint256[8] memory) {

        return SnuffyToken.getMutationRequirements();
    }

    function setMutationRequirements(uint256[8] memory _limits) public onlyOwner {

        SnuffyToken.setMutationRequirements(_limits);
    }

    function getBroker() public view returns (address) {

        return SnuffyToken.getBroker();
    }

    function setBroker(address broker) public onlyOwner {

        SnuffyToken.setBroker(broker);
    }

    function getTokenState(uint256 tokenId) public view returns (uint256) {

        return SnuffyToken.getTokenState(tokenId);
    }

    function getTokenDataIndex(uint256 tokenId) public view returns (uint256) {

        return SnuffyToken.calculateState(tokenId);
    }

    function getTokenData(uint256 tokenId) public view returns (uint256, uint256, uint256) {

        return SnuffyToken.getTokenData(tokenId);
    }

    modifier onlyOwner() {

        require(isOwner(), "CXIP: caller not an owner");
        _;
    }

    receive() external payable {}

    fallback() external {
        _royaltiesFallback();
    }

    function arweaveURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = SnuffyToken.calculateState(tokenId);
        return string(abi.encodePacked("https://arweave.net/", _tokenData[index].arweave, _tokenData[index].arweave2));
    }

    function contractURI() external view returns (string memory) {

        return string(abi.encodePacked("https://nft.cxip.io/", Strings.toHexString(address(this)), "/"));
    }

    function creator(uint256 tokenId) external view returns (address) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = SnuffyToken.calculateState(tokenId);
        return _tokenData[index].creator;
    }

    function httpURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "CXIP: token does not exist");
        return string(abi.encodePacked(baseURI(), "/", Strings.toHexString(tokenId)));
    }

    function ipfsURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = SnuffyToken.calculateState(tokenId);
        return string(abi.encodePacked("https://ipfs.io/ipfs/", _tokenData[index].ipfs, _tokenData[index].ipfs2));
    }

    function name() external view returns (string memory) {

        return string(abi.encodePacked(Bytes.trim(_collectionData.name), Bytes.trim(_collectionData.name2)));
    }

    function payloadHash(uint256 tokenId) external view returns (bytes32) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = SnuffyToken.calculateState(tokenId);
        return _tokenData[index].payloadHash;
    }

    function payloadSignature(uint256 tokenId) external view returns (Verification memory) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = SnuffyToken.calculateState(tokenId);
        return _tokenData[index].payloadSignature;
    }

    function payloadSigner(uint256 tokenId) external view returns (address) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = SnuffyToken.calculateState(tokenId);
        return _tokenData[index].creator;
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        if (
            interfaceId == 0x01ffc9a7 || // ERC165
            interfaceId == 0x80ac58cd || // ERC721
            interfaceId == 0x780e9d63 || // ERC721Enumerable
            interfaceId == 0x5b5e139f || // ERC721Metadata
            interfaceId == 0x150b7a02 || // ERC721TokenReceiver
            interfaceId == 0xe8a3d485 || // contractURI()
            IPA1D(getRegistry().getPA1D()).supportsInterface(interfaceId)
        ) {
            return true;
        } else {
            return false;
        }
    }

    function symbol() external view returns (string memory) {

        return string(Bytes.trim(_collectionData.symbol));
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "CXIP: token does not exist");
        uint256 index = SnuffyToken.calculateState(tokenId);
        return string(abi.encodePacked("https://arweave.net/", _tokenData[index].arweave, _tokenData[index].arweave2));
    }

    function tokensOfOwner(address wallet) external view returns (uint256[] memory) {

        return _ownedTokens[wallet];
    }

    function verifySHA256(bytes32 hash, bytes calldata payload) external pure returns (bool) {

        bytes32 thePayloadHash = sha256(payload);
        return hash == thePayloadHash;
    }

    function approve(address to, uint256 tokenId) public {

        address tokenOwner = _tokenOwner[tokenId];
        require(to != tokenOwner, "CXIP: can't approve self");
        require(_isApproved(msg.sender, tokenId), "CXIP: not approved sender");
        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }

    function burn(uint256 tokenId) public {

        require(_isApproved(msg.sender, tokenId), "CXIP: not approved sender");
        address wallet = _tokenOwner[tokenId];
        _clearApproval(tokenId);
        _tokenOwner[tokenId] = address(0);
        emit Transfer(wallet, address(0), tokenId);
        _removeTokenFromOwnerEnumeration(wallet, tokenId);
    }

    function init(address newOwner, CollectionData calldata collectionData) public {

        require(Address.isZero(_admin), "CXIP: already initialized");
        _admin = msg.sender;
        _owner = address(this);
        _collectionData = collectionData;
        IPA1D(address(this)).init (0, payable(collectionData.royalties), collectionData.bps);
        _owner = newOwner;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable {

        require(_isApproved(msg.sender, tokenId), "CXIP: not approved sender");
        _transferFrom(from, to, tokenId);
        if (Address.isContract(to)) {
            require(
                ICxipERC721(to).onERC721Received(address(this), from, tokenId, data) == 0x150b7a02,
                "CXIP: onERC721Received fail"
            );
        }
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender, "CXIP: can't approve self");
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function transfer(
        address to,
        uint256 tokenId
    ) public payable {

        transferFrom(msg.sender, to, tokenId, "");
    }


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable {

        transferFrom(from, to, tokenId, "");
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory /*_data*/
    ) public payable {

        require(_isApproved(msg.sender, tokenId), "CXIP: not approved sender");
        _transferFrom(from, to, tokenId);
    }

    function mint(uint256 state, uint256 tokenId, TokenData[] memory tokenData, address signer, Verification memory verification, address recipient) public {

        require(isOwner() || msg.sender == getBroker(), "CXIP: only owner/broker can mint");
        require(_allTokens.length < getTokenLimit(), "CXIP: over token limit");
        require(isIdentityWallet(tokenData[0].creator), "CXIP: creator not in identity");
        if (!isOwner()) {
            require(isIdentityWallet(signer), "CXIP: invalid signer");
            bytes memory encoded = abi.encode(
                tokenData[0].creator,
                tokenId,
                tokenData
            );
            require(Signature.Valid(
                signer,
                verification.r,
                verification.s,
                verification.v,
                encoded
            ), "CXIP: invalid signature");
        }
        if (!Address.isZero(recipient)) {
            require(!_exists(tokenId), "CXIP: token already exists");
            emit Transfer(address(0), tokenData[0].creator, tokenId);
            emit Transfer(tokenData[0].creator, recipient, tokenId);
            _tokenOwner[tokenId] = recipient;
            _addTokenToOwnerEnumeration(recipient, tokenId);
        } else {
            _mint(tokenData[0].creator, tokenId);
        }
        if (_allTokens.length == getTokenLimit()) {
            setMintingClosed();
        }
        (uint256 max,/* uint256 limit*/,/* uint256 future0*/,/* uint256 future1*/,/* uint256 future2*/,/* uint256 future3*/) = SnuffyToken.getStatesConfig();
        require(tokenData.length <= max, "CXIP: token data states too long");
        uint256 index = max * tokenId;
        for (uint256 i = 0; i < tokenData.length; i++) {
            _tokenData[index] = tokenData[i];
            index++;
        }
        SnuffyToken.setTokenData(tokenId, state, block.timestamp, tokenId);
    }

    function evolve(uint256 tokenId, uint256[] calldata tokenIds) public {

        uint256 state = SnuffyToken.getTokenState(tokenId);
        (/*uint256 max*/, uint256 limit,/* uint256 future0*/,/* uint256 future1*/,/* uint256 future2*/,/* uint256 future3*/) = SnuffyToken.getStatesConfig();
        require(state < (limit - 1), "CXIP: token evolved to max");
        uint256[8] memory _limits = SnuffyToken.getMutationRequirements();
        require(tokenIds.length == _limits[state], "CXIP: incorrect tokens amount");
        bool included;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(ownerOf(tokenIds[i]) == msg.sender, "CXIP: not owner of token");
            require(SnuffyToken.getTokenState(tokenIds[i]) >= state, "CXIP: token level too low");
            if (!included && tokenId == tokenIds[i]) {
                SnuffyToken.setTokenData(tokenId, state + 1, block.timestamp, tokenId);
                included = true;
            } else {
                SnuffyToken.setTokenData(tokenIds[i], 0, block.timestamp, tokenIds[i]);
                _transferFrom(msg.sender, SnuffyToken.getBroker(), tokenIds[i]);
            }
        }
        require(included, "CXIP: missing evolving token");
    }

    function getMintingClosed() public view returns (bool mintingClosed) {

        uint256 data;
        assembly {
            data := sload(
                0x82d37688748a8833e0d222efdc792424f8a1acdd6c8351cb26b314a4ceee6a84
            )
        }
        mintingClosed = (data == 1);
    }

    function setMintingClosed() public onlyOwner {

        uint256 data = 1;
        assembly {
            sstore(
                0x82d37688748a8833e0d222efdc792424f8a1acdd6c8351cb26b314a4ceee6a84,
                data
            )
        }
    }

    function getTokenLimit() public view returns (uint256 tokenLimit) {

        assembly {
            tokenLimit := sload(
                0xd7cccb4858870420bddc578f86437fd66f8949091f61f21bd40e4390dc953953
            )
        }
        if (tokenLimit == 0) {
            tokenLimit = type(uint256).max;
        }
    }

    function setTokenLimit(uint256 tokenLimit) public onlyOwner {

        require(getTokenLimit() == 0, "CXIP: token limit already set");
        assembly {
            sstore(
                0xd7cccb4858870420bddc578f86437fd66f8949091f61f21bd40e4390dc953953,
                tokenLimit
            )
        }
    }

    function prepareMintData(uint256 id, TokenData calldata tokenData) public onlyOwner {

        require(Address.isZero(_tokenData[id].creator), "CXIP: token data already set");
        _tokenData[id] = tokenData;
    }

    function prepareMintDataBatch(uint256[] calldata ids, TokenData[] calldata tokenData) public onlyOwner {

        require(ids.length == tokenData.length, "CXIP: array lengths missmatch");
        for (uint256 i = 0; i < ids.length; i++) {
            require(Address.isZero(_tokenData[ids[i]].creator), "CXIP: token data already set");
            _tokenData[ids[i]] = tokenData[i];
        }
    }

    function setName(bytes32 newName, bytes32 newName2) public onlyOwner {

        _collectionData.name = newName;
        _collectionData.name2 = newName2;
    }

    function setSymbol(bytes32 newSymbol) public onlyOwner {

        _collectionData.symbol = newSymbol;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(!Address.isZero(newOwner), "CXIP: zero address");
        _owner = newOwner;
    }

    function balanceOf(address wallet) public view returns (uint256) {

        require(!Address.isZero(wallet), "CXIP: zero address");
        return _ownedTokensCount[wallet];
    }

    function baseURI() public view returns (string memory) {

        return string(abi.encodePacked("https://nft.cxip.io/", Strings.toHexString(address(this))));
    }

    function exists(uint256 tokenId) public view returns (bool) {

        return !Address.isZero(_tokenOwner[tokenId]);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        return _tokenApprovals[tokenId];
    }

    function getIdentity() public view returns (address) {

        return ICxipProvenance(getRegistry().getProvenance()).getWalletIdentity(_owner);
    }

    function isApprovedForAll(address wallet, address operator) public view returns (bool) {

        return (_operatorApprovals[wallet][operator]/* ||
            0x4feE7B061C97C9c496b01DbcE9CDb10c02f0a0Be == operator ||
            address(OpenSeaProxyRegistry(0xa5409ec958C83C3f309868babACA7c86DCB077c1).proxies(wallet)) == operator*/);
    }

    function isOwner() public view returns (bool) {

        return (msg.sender == _owner || msg.sender == _admin || isIdentityWallet(msg.sender));
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address tokenOwner = _tokenOwner[tokenId];
        require(!Address.isZero(tokenOwner), "ERC721: token does not exist");
        return tokenOwner;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply(), "CXIP: index out of bounds");
        return _allTokens[index];
    }

    function tokenOfOwnerByIndex(
        address wallet,
        uint256 index
    ) public view returns (uint256) {

        require(index < balanceOf(wallet));
        return _ownedTokens[wallet][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function onERC721Received(
        address, /*_operator*/
        address, /*_from*/
        uint256, /*_tokenId*/
        bytes calldata /*_data*/
    ) public pure returns (bytes4) {

        return 0x150b7a02;
    }

    function _royaltiesFallback() internal {

        address _target = getRegistry().getPA1D();
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _target, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function isIdentityWallet(address sender) internal view returns (bool) {

        address identity = getIdentity();
        if (Address.isZero(identity)) {
            return false;
        }
        return ICxipIdentity(identity).isWalletRegistered(sender);
    }

    function getRegistry() internal pure returns (ICxipRegistry) {

        return ICxipRegistry(0xC267d41f81308D7773ecB3BDd863a902ACC01Ade);
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokensCount[to];
        _ownedTokensCount[to]++;
        _ownedTokens[to].push(tokenId);
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _clearApproval(uint256 tokenId) private {

        delete _tokenApprovals[tokenId];
    }

    function _mint(address to, uint256 tokenId) private {

        require(!Address.isZero(to), "CXIP: can't mint a burn");
        require(!_exists(tokenId), "CXIP: token already exists");
        _tokenOwner[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];
        uint256 lastTokenId = _allTokens[lastTokenIndex];
        _allTokens[tokenIndex] = lastTokenId;
        _allTokensIndex[lastTokenId] = tokenIndex;
        delete _allTokensIndex[tokenId];
        delete _allTokens[lastTokenIndex];
        _allTokens.pop();
    }

    function _removeTokenFromOwnerEnumeration(
        address from,
        uint256 tokenId
    ) private {

        _removeTokenFromAllTokensEnumeration(tokenId);
        _ownedTokensCount[from]--;
        uint256 lastTokenIndex = _ownedTokensCount[from];
        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        if(tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }
        if(lastTokenIndex == 0) {
            delete _ownedTokens[from];
        } else {
            delete _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from].pop();
        }
    }

    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) private {

        require(_tokenOwner[tokenId] == from, "CXIP: not from's token");
        require(!Address.isZero(to), "CXIP: use burn instead");
        _clearApproval(tokenId);
        _tokenOwner[tokenId] = to;
        emit Transfer(from, to, tokenId);
        _removeTokenFromOwnerEnumeration(from, tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
        SnuffyToken.setTokenData(tokenId, SnuffyToken.getTokenState(tokenId), block.timestamp, tokenId);
    }

    function _exists(uint256 tokenId) private view returns (bool) {

        address tokenOwner = _tokenOwner[tokenId];
        return !Address.isZero(tokenOwner);
    }

    function _isApproved(address spender, uint256 tokenId) private view returns (bool) {

        require(_exists(tokenId));
        address tokenOwner = _tokenOwner[tokenId];
        return (
            spender == tokenOwner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(tokenOwner, spender)
        );
    }
}

library SnuffyToken {



    function getStatesConfig() internal view returns (uint256 max, uint256 limit, uint256 future0, uint256 future1, uint256 future2, uint256 future3) {

        uint256 unpacked;
        assembly {
            unpacked := sload(
                0x320f7df63ad3c1fb03163fc8f47010f96d0a4b028d5ed2c9bdbc6b577caddacf
            )
        }
        max = uint256(uint32(unpacked >> 0));
        limit = uint256(uint32(unpacked >> 32));
        future0 = uint256(uint32(unpacked >> 64));
        future1 = uint256(uint32(unpacked >> 96));
        future2 = uint256(uint32(unpacked >> 128));
        future3 = uint256(uint32(unpacked >> 160));
    }

    function setStatesConfig(uint256 max, uint256 limit, uint256 future0, uint256 future1, uint256 future2, uint256 future3) internal {

        uint256 packed;
        packed = packed | max << 0;
        packed = packed | limit << 32;
        packed = packed | future0 << 64;
        packed = packed | future1 << 96;
        packed = packed | future2 << 128;
        packed = packed | future3 << 160;
        assembly {
            sstore(
                0x320f7df63ad3c1fb03163fc8f47010f96d0a4b028d5ed2c9bdbc6b577caddacf,
                packed
            )
        }
    }

    function getStateTimestamps() internal view returns (uint256[8] memory _timestamps) {

        uint256 data;
        assembly {
            data := sload(
                0xb3272806717bb124fff9d338a5d6ec1182c08fc56784769d91b37c01055db8e2
            )
        }
        for (uint256 i = 0; i < 8; i++) {
            _timestamps[i] = uint256(uint32(data >> (32 * i)));
        }
    }

    function setStateTimestamps(uint256[8] memory _timestamps) internal {

        uint256 packed;
        for (uint256 i = 0; i < 8; i++) {
            packed = packed | _timestamps[i] << (32 * i);
        }
        assembly {
            sstore(
                0xb3272806717bb124fff9d338a5d6ec1182c08fc56784769d91b37c01055db8e2,
                packed
            )
        }
    }

    function getMutationRequirements() internal view returns (uint256[8] memory _limits) {

        uint256 data;
        assembly {
            data := sload(
                0x6ab8a5e4f8314f5c905e9eb234db45800102f76ee29724ea1039076fe1c57441
            )
        }
        for (uint256 i = 0; i < 8; i++) {
            _limits[i] = uint256(uint32(data >> (32 * i)));
        }
    }

    function setMutationRequirements(uint256[8] memory _limits) internal {

        uint256 packed;
        for (uint256 i = 0; i < 8; i++) {
            packed = packed | _limits[i] << (32 * i);
        }
        assembly {
            sstore(
                0x6ab8a5e4f8314f5c905e9eb234db45800102f76ee29724ea1039076fe1c57441,
                packed
            )
        }
    }

    function getBroker() internal view returns (address broker) {

        assembly {
            broker := sload(
                0x71ad4b54125645bc093479b790dba1d002be6ff1fc59f46b726e598257e1e3c1
            )
        }
    }

    function setBroker(address broker) internal {

        assembly {
            sstore(
                0x71ad4b54125645bc093479b790dba1d002be6ff1fc59f46b726e598257e1e3c1,
                broker
            )
        }
    }

    function getTokenData(uint256 tokenId) internal view returns (uint256 state, uint256 timestamp, uint256 stencilId) {

        uint256 unpacked;
        bytes32 slot = bytes32(uint256(keccak256(abi.encodePacked("eip1967.CXIP.SnuffyToken.tokenData.", tokenId))) - 1);
        assembly {
            unpacked := sload(slot)
        }
        state = uint256(uint32(unpacked >> 0));
        timestamp = uint256(uint32(unpacked >> 32));
        stencilId = uint256(uint32(unpacked >> 64));
    }

    function setTokenData(uint256 tokenId, uint256 state, uint256 timestamp, uint256 stencilId) internal {

        bytes32 slot = bytes32(uint256(keccak256(abi.encodePacked("eip1967.CXIP.SnuffyToken.tokenData.", tokenId))) - 1);
        uint256 packed;
        packed = packed | state << 0;
        packed = packed | timestamp << 32;
        packed = packed | stencilId << 64;
        assembly {
            sstore(slot, packed)
        }
    }

    function calculateState(uint256 tokenId) internal view returns (uint256 dataIndex) {

        (uint256 max,/* uint256 limit*/,/* uint256 future0*/,/* uint256 future1*/,/* uint256 future2*/,/* uint256 future3*/) = getStatesConfig();
        (/*uint256 state*/,/* uint256 timestamp*/, uint256 stencilId) = getTokenData(tokenId);
        dataIndex = max * stencilId;
        return dataIndex + getTokenState(tokenId);
    }

    function getTokenState(uint256 tokenId) internal view returns (uint256 dataIndex) {

        (/*uint256 max*/, uint256 limit,/* uint256 future0*/,/* uint256 future1*/,/* uint256 future2*/,/* uint256 future3*/) = getStatesConfig();
        (uint256[8] memory _timestamps) = getStateTimestamps();
        (uint256 state, uint256 timestamp,/* uint256 stencilId*/) = getTokenData(tokenId);
        uint256 duration = block.timestamp - timestamp;
        for (uint256 i = state; i < limit; i++) {
            if (duration < _timestamps[i]) {
                return i;
            }
            duration -= _timestamps[i];
        }
        return limit - 1;
    }

}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
    }

    function isZero(address account) internal pure returns (bool) {

        return (account == address(0));
    }
}

library Bytes {

    function getBoolean(uint192 _packedBools, uint192 _boolNumber) internal pure returns (bool) {

        uint192 flag = (_packedBools >> _boolNumber) & uint192(1);
        return (flag == 1 ? true : false);
    }

    function setBoolean(
        uint192 _packedBools,
        uint192 _boolNumber,
        bool _value
    ) internal pure returns (uint192) {

        if (_value) {
            return _packedBools | (uint192(1) << _boolNumber);
        } else {
            return _packedBools & ~(uint192(1) << _boolNumber);
        }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {

        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");
        bytes memory tempBytes;
        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)
                let lengthmod := and(_length, 31)
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)
                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }
                mstore(tempBytes, _length)
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)
                mstore(tempBytes, 0)
                mstore(0x40, add(tempBytes, 0x20))
            }
        }
        return tempBytes;
    }

    function trim(bytes32 source) internal pure returns (bytes memory) {

        uint256 temp = uint256(source);
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return slice(abi.encodePacked(source), 32 - length, length);
    }
}

library Signature {

    function Derive(
        bytes32 r,
        bytes32 s,
        uint8 v,
        bytes memory encoded
    )
        internal
        pure
        returns (
            address derived1,
            address derived2,
            address derived3,
            address derived4
        )
    {

        bytes32 encoded32;
        assembly {
            encoded32 := mload(add(encoded, 32))
        }
        derived1 = ecrecover(encoded32, v, r, s);
        derived2 = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", encoded32)), v, r, s);
        encoded32 = keccak256(encoded);
        derived3 = ecrecover(encoded32, v, r, s);
        encoded32 = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", encoded32));
        derived4 = ecrecover(encoded32, v, r, s);
    }

    function PackMessage(bytes memory encoded, bool geth) internal pure returns (bytes32) {

        bytes32 hash = keccak256(encoded);
        if (geth) {
            hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        }
        return hash;
    }

    function Valid(
        address target,
        bytes32 r,
        bytes32 s,
        uint8 v,
        bytes memory encoded
    ) internal pure returns (bool) {

        bytes32 encoded32;
        address derived;
        if (encoded.length == 32) {
            assembly {
                encoded32 := mload(add(encoded, 32))
            }
            derived = ecrecover(encoded32, v, r, s);
            if (target == derived) {
                return true;
            }
            derived = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", encoded32)), v, r, s);
            if (target == derived) {
                return true;
            }
        }
        bytes32 hash = keccak256(encoded);
        derived = ecrecover(hash, v, r, s);
        if (target == derived) {
            return true;
        }
        hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        derived = ecrecover(hash, v, r, s);
        return target == derived;
    }
}

library Strings {

    function toHexString(address account) internal pure returns (string memory) {

        return toHexString(uint256(uint160(account)));
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = bytes16("0123456789abcdef")[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

struct CollectionData {
    bytes32 name;
    bytes32 name2;
    bytes32 symbol;
    address royalties;
    uint96 bps;
}

struct Token {
    address collection;
    uint256 tokenId;
    InterfaceType tokenType;
    address creator;
}

struct TokenData {
    bytes32 payloadHash;
    Verification payloadSignature;
    address creator;
    bytes32 arweave;
    bytes11 arweave2;
    bytes32 ipfs;
    bytes14 ipfs2;
}

struct Verification {
    bytes32 r;
    bytes32 s;
    uint8 v;
}

enum InterfaceType {
    NULL, // 0
    ERC20, // 1
    ERC721, // 2
    ERC1155 // 3
}

enum UriType {
    ARWEAVE, // 0
    IPFS, // 1
    HTTP // 2
}

interface ICxipERC721 {

    function arweaveURI(uint256 tokenId) external view returns (string memory);


    function contractURI() external view returns (string memory);


    function creator(uint256 tokenId) external view returns (address);


    function httpURI(uint256 tokenId) external view returns (string memory);


    function ipfsURI(uint256 tokenId) external view returns (string memory);


    function name() external view returns (string memory);


    function payloadHash(uint256 tokenId) external view returns (bytes32);


    function payloadSignature(uint256 tokenId) external view returns (Verification memory);


    function payloadSigner(uint256 tokenId) external view returns (address);


    function supportsInterface(bytes4 interfaceId) external view returns (bool);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);



    function verifySHA256(bytes32 hash, bytes calldata payload) external pure returns (bool);


    function approve(address to, uint256 tokenId) external;


    function burn(uint256 tokenId) external;


    function init(address newOwner, CollectionData calldata collectionData) external;



    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external payable;


    function setApprovalForAll(address to, bool approved) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external payable;


    function cxipMint(uint256 id, TokenData calldata tokenData) external returns (uint256);


    function setApprovalForAll(
        address from,
        address to,
        bool approved
    ) external;


    function setName(bytes32 newName, bytes32 newName2) external;


    function setSymbol(bytes32 newSymbol) external;


    function transferOwnership(address newOwner) external;


    function baseURI() external view returns (string memory);


    function getApproved(uint256 tokenId) external view returns (address);


    function getIdentity() external view returns (address);


    function isApprovedForAll(address wallet, address operator) external view returns (bool);


    function isOwner() external view returns (bool);


    function owner() external view returns (address);


    function ownerOf(uint256 tokenId) external view returns (address);





    function totalSupply() external view returns (uint256);


    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4);

}

interface ICxipIdentity {

    function addSignedWallet(
        address newWallet,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function addWallet(address newWallet) external;


    function connectWallet() external;


    function createERC721Token(
        address collection,
        uint256 id,
        TokenData calldata tokenData,
        Verification calldata verification
    ) external returns (uint256);


    function createERC721Collection(
        bytes32 saltHash,
        address collectionCreator,
        Verification calldata verification,
        CollectionData calldata collectionData
    ) external returns (address);


    function createCustomERC721Collection(
        bytes32 saltHash,
        address collectionCreator,
        Verification calldata verification,
        CollectionData calldata collectionData,
        bytes32 slot,
        bytes memory bytecode
    ) external returns (address);


    function init(address wallet, address secondaryWallet) external;


    function getAuthorizer(address wallet) external view returns (address);


    function getCollectionById(uint256 index) external view returns (address);


    function getCollectionType(address collection) external view returns (InterfaceType);


    function getWallets() external view returns (address[] memory);


    function isCollectionCertified(address collection) external view returns (bool);


    function isCollectionRegistered(address collection) external view returns (bool);


    function isNew() external view returns (bool);


    function isOwner() external view returns (bool);


    function isTokenCertified(address collection, uint256 tokenId) external view returns (bool);


    function isTokenRegistered(address collection, uint256 tokenId) external view returns (bool);


    function isWalletRegistered(address wallet) external view returns (bool);


    function listCollections(uint256 offset, uint256 length) external view returns (address[] memory);


    function nextNonce(address wallet) external view returns (uint256);


    function totalCollections() external view returns (uint256);


    function isCollectionOpen(address collection) external pure returns (bool);

}

interface ICxipProvenance {

    function createIdentity(
        bytes32 saltHash,
        address wallet,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256, address);


    function createIdentityBatch(
        bytes32 saltHash,
        address[] memory wallets,
        uint8[] memory V,
        bytes32[] memory RS
    ) external returns (uint256, address);


    function getIdentity() external view returns (address);


    function getWalletIdentity(address wallet) external view returns (address);


    function informAboutNewWallet(address newWallet) external;


    function isIdentityValid(address identity) external view returns (bool);


    function nextNonce(address wallet) external view returns (uint256);

}

interface ICxipRegistry {

    function getAsset() external view returns (address);


    function getAssetSigner() external view returns (address);


    function getAssetSource() external view returns (address);


    function getCopyright() external view returns (address);


    function getCopyrightSource() external view returns (address);


    function getCustomSource(bytes32 name) external view returns (address);


    function getCustomSourceFromString(string memory name) external view returns (address);


    function getERC1155CollectionSource() external view returns (address);


    function getERC721CollectionSource() external view returns (address);


    function getIdentitySource() external view returns (address);


    function getPA1D() external view returns (address);


    function getPA1DSource() external view returns (address);


    function getProvenance() external view returns (address);


    function getProvenanceSource() external view returns (address);


    function owner() external view returns (address);


    function setAsset(address proxy) external;


    function setAssetSigner(address source) external;


    function setAssetSource(address source) external;


    function setCopyright(address proxy) external;


    function setCopyrightSource(address source) external;


    function setCustomSource(string memory name, address source) external;


    function setERC1155CollectionSource(address source) external;


    function setERC721CollectionSource(address source) external;


    function setIdentitySource(address source) external;


    function setPA1D(address proxy) external;


    function setPA1DSource(address source) external;


    function setProvenance(address proxy) external;


    function setProvenanceSource(address source) external;

}

interface IPA1D {

    function init(
        uint256 tokenId,
        address payable receiver,
        uint256 bp
    ) external;


    function supportsInterface(bytes4 interfaceId) external pure returns (bool);

}