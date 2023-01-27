

pragma solidity 0.8.4;


contract NFTBroker {


    address private _admin;

    address private _owner;

    address private _notary;

    address payable private _tokenContract;

    uint256 private _tier1;

    uint256 private _tier2;

    uint256 private _tier3;

    mapping(address => bool) private _tier1wallets;

    mapping(address => uint256[]) private _reservedTokens;

    mapping(address => uint256) private _reservedTokenAmounts;

    mapping(address => uint256) private _purchasedTokens;

    uint256 private _tokenBasePrice;

    uint256 private _tokenStakePrice;

    uint256 private _tokenClaimPrice;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bool private _autoWithdraw;

    uint256 private _maxPurchases;

    bool private _reserveLifted;

    mapping(address => mapping(bytes4 => bool)) private _approvedFunctions;

    modifier onlyOwner() {

        require(isOwner(), "CXIP: caller not an owner");
        _;
    }

    constructor (address tokenContract, address notary, bool autoWithdraw, uint256 maxPurchases, address newOwner) {
        _admin = tx.origin;
        _owner = newOwner;
        _tokenContract = payable(tokenContract);
        _notary = notary;
        _autoWithdraw = autoWithdraw;
        _maxPurchases = maxPurchases;
    }

    function buyToken (uint256 tokenId) public payable {
        ISNUFFY500 snuffy = ISNUFFY500(_tokenContract);
        require(snuffy.exists(tokenId), "CXIP: token not minted");
        require(_exists(tokenId), "CXIP: token not for sale");
        require(snuffy.ownerOf(tokenId) == address(this), "CXIP: broker not owner of token");
        if (_tier1wallets[msg.sender]) {
            require(msg.value >= _tokenClaimPrice, "CXIP: payment amount is too low");
        } else {
            require(msg.value >= _tokenBasePrice, "CXIP: payment amount is too low");
        }
        if (!_reserveLifted) {
            require(_purchasedTokens[msg.sender] < _maxPurchases, "CXIP: max allowance reached");
        }
        _purchasedTokens[msg.sender] = _purchasedTokens[msg.sender] + 1;
        snuffy.safeTransferFrom(address(this), msg.sender, tokenId);
        _removeTokenFromAllTokensEnumeration(tokenId);
        if (_autoWithdraw) {
            _moveEth();
        }
    }

    function claimAndMint (uint256 tokenId, TokenData[] calldata tokenData, Verification calldata verification) public {
        require(block.timestamp >= _tier1, "CXIP: too early to claim");
        require(!ISNUFFY500(_tokenContract).exists(tokenId), "CXIP: token snatched");
        if (_reservedTokenAmounts[msg.sender] > 0) {
            require(_exists(tokenId), "CXIP: token not for sale");
            ISNUFFY500(_tokenContract).mint(0, tokenId, tokenData, _admin, verification, msg.sender);
            _reservedTokenAmounts[msg.sender] = _reservedTokenAmounts[msg.sender] - 1;
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else {
            uint256 length = _reservedTokens[msg.sender].length;
            require(length > 0, "CXIP: no tokens to claim");
            uint256 index = length - 1;
            require(_reservedTokens[msg.sender][index] == tokenId, "CXIP: not your token");
            delete _reservedTokens[msg.sender][index];
            _reservedTokens[msg.sender].pop();
            ISNUFFY500(_tokenContract).mint(1, tokenId, tokenData, _admin, verification, msg.sender);
        }
        if (!_tier1wallets[msg.sender]) {
            _tier1wallets[msg.sender] = true;
        }
        if (_autoWithdraw) {
            _moveEth();
        }
    }

    function delegateApproved (address target, bytes4 functionHash, bytes calldata payload) public payable {
        require(_approvedFunctions[target][functionHash], "CXIP: not approved delegate call");
        (bool success, bytes memory data) = target.delegatecall(abi.encodePacked(functionHash, payload));
        require(success, string(data));
    }

    function payAndMint (uint256 tokenId, TokenData[] calldata tokenData, Verification calldata verification) public payable {
        require(block.timestamp >= _tier3 || _tier1wallets[msg.sender], "CXIP: too early to buy");
        require(!ISNUFFY500(_tokenContract).exists(tokenId), "CXIP: token snatched");
        require(_exists(tokenId), "CXIP: token not for sale");
        if (_tier1wallets[msg.sender]) {
            if (_purchasedTokens[msg.sender] > 0) {
                require(msg.value >= _tokenClaimPrice, "CXIP: payment amount is too low");
            }
        } else {
            require(msg.value >= _tokenBasePrice, "CXIP: payment amount is too low");
        }
        if (!_reserveLifted) {
            require(_purchasedTokens[msg.sender] < _maxPurchases, "CXIP: max allowance reached");
        }
        _purchasedTokens[msg.sender] = _purchasedTokens[msg.sender] + 1;
        ISNUFFY500(_tokenContract).mint(0, tokenId, tokenData, _admin, verification, msg.sender);
        _removeTokenFromAllTokensEnumeration(tokenId);
        if (_autoWithdraw) {
            _moveEth();
        }
    }

    function proofOfStakeAndMint (Verification calldata proof, uint256 tokens, uint256 tokenId, TokenData[] calldata tokenData, Verification calldata verification) public payable {
        require(block.timestamp >= _tier2, "CXIP: too early to stake");
        require(msg.value >= _tokenStakePrice, "CXIP: payment amount is too low");
        require(!ISNUFFY500(_tokenContract).exists(tokenId), "CXIP: token snatched");
        require(_exists(tokenId), "CXIP: token not for sale");
        bytes memory encoded = abi.encodePacked(msg.sender, tokens);
        require(Signature.Valid(
            _notary,
            proof.r,
            proof.s,
            proof.v,
            encoded
        ), "CXIP: invalid signature");
        if (!_reserveLifted) {
            require(_purchasedTokens[msg.sender] < _maxPurchases, "CXIP: max allowance reached");
        }
        _purchasedTokens[msg.sender] = _purchasedTokens[msg.sender] + 1;
        ISNUFFY500(_tokenContract).mint(0, tokenId, tokenData, _admin, verification, msg.sender);
        _removeTokenFromAllTokensEnumeration(tokenId);
        if (_autoWithdraw) {
            _moveEth();
        }
    }

    function clearReservedTokens (address[] calldata wallets) public onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            _reservedTokens[wallets[i]] = new uint256[](0);
        }
    }

    function delegate (address target, bytes calldata payload) public onlyOwner {
        (bool success, bytes memory data) = target.delegatecall(payload);
        require(success, string(data));
    }

    function liftPurchaseLimits () public onlyOwner {
        _reserveLifted = true;
    }

    function removeOpenTokens (uint256[] calldata tokens) public onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            _removeTokenFromAllTokensEnumeration(tokens[i]);
        }
    }

    function removeReservedTokens (address[] calldata wallets) public onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            delete _reservedTokens[wallets[i]];
        }
    }

    function setApprovedFunction (address target, bytes4 functionHash, bool value) public onlyOwner {
        _approvedFunctions[target][functionHash] = value;
    }

    function setNotary (address notary) public onlyOwner {
        _notary = notary;
    }

    function setOpenTokens (uint256[] calldata tokens) public onlyOwner {
        for (uint256 i = 0; i < tokens.length; i++) {
            _addTokenToEnumeration(tokens[i]);
        }
    }

    function setPrices (uint256 basePrice, uint256 claimPrice, uint256 stakePrice) public onlyOwner {
        _tokenBasePrice = basePrice;
        _tokenClaimPrice = claimPrice;
        _tokenStakePrice = stakePrice;
    }

    function setPurchaseLimit (uint256 limit) public onlyOwner {
        _maxPurchases = limit;
    }

    function setPurchasedTokensAmount (address[] calldata wallets, uint256[] calldata amounts) public onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            _purchasedTokens[wallets[i]] = amounts[i];
        }
    }

    function setReservedTokenAmounts (address[] calldata wallets, uint256[] calldata amounts) public onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            _reservedTokenAmounts[wallets[i]] = amounts[i];
        }
    }

    function setReservedTokens (address[] calldata wallets, uint256[] calldata tokens) public onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            _reservedTokens[wallets[i]].push (tokens[i]);
        }
    }

    function setReservedTokensArrays (address[] calldata wallets, uint256[][] calldata tokens) public onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            _reservedTokens[wallets[i]] = tokens[i];
        }
    }

    function setTierTimes (uint256 tier1, uint256 tier2, uint256 tier3) public onlyOwner {
        _tier1 = tier1;
        _tier2 = tier2;
        _tier3 = tier3;
    }

    function setVIPs (address[] calldata wallets) public onlyOwner {
        for (uint256 i = 0; i < wallets.length; i++) {
            _tier1wallets[wallets[i]] = true;
        }
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(!Address.isZero(newOwner), "CXIP: zero address");
        _owner = newOwner;
    }

    function withdrawEth () public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function delegateApprovedCall (address target, bytes4 functionHash, bytes calldata payload) public returns (bytes memory) {
        require(_approvedFunctions[target][functionHash], "CXIP: not approved delegate call");
        (bool success, bytes memory data) = target.delegatecall(abi.encodePacked(functionHash, payload));
        require(success, string(data));
        return data;
    }

    function onERC721Received(
        address payable _operator,
        address/* _from*/,
        uint256 _tokenId,
        bytes calldata /*_data*/
    ) public returns (bytes4) {

        if (_operator == _tokenContract) {
            if (ISNUFFY500(_operator).ownerOf(_tokenId) == address(this)) {
                _addTokenToEnumeration (_tokenId);
            }
        }
        return 0x150b7a02;
    }

    function arePurchasesLimited () public view returns (bool) {
        return !_reserveLifted;
    }

    function getNotary () public view returns (address) {
        return _notary;
    }

    function getPrices () public view returns (uint256 basePrice, uint256 claimPrice, uint256 stakePrice) {
        basePrice = _tokenBasePrice;
        claimPrice = _tokenClaimPrice;
        stakePrice = _tokenStakePrice;
    }

    function getPurchaseLimit() public view returns (uint256) {

        return _maxPurchases;
    }

    function getPurchasedTokensAmount (address wallet) public view returns (uint256) {
        return _purchasedTokens[wallet];
    }

    function getReservedTokenAmounts(address wallet) public view returns (uint256) {

        return _reservedTokenAmounts[wallet];
    }

    function getReservedTokens(address wallet) public view returns (uint256[] memory) {

        return _reservedTokens[wallet];
    }

    function getTierTimes () public view returns (uint256 tier1, uint256 tier2, uint256 tier3) {
        tier1 = _tier1;
        tier2 = _tier2;
        tier3 = _tier3;
    }

    function isOwner() public view returns (bool) {

        return (msg.sender == _owner || msg.sender == _admin);
    }

    function isVIP (address wallet) public view returns (bool) {
        return _tier1wallets[wallet];
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply(), "CXIP: index out of bounds");
        return _allTokens[index];
    }

    function tokensByChunk(uint256 start, uint256 length) public view returns (uint256[] memory tokens) {

        if (start + length > totalSupply()) {
            length = totalSupply() - start;
        }
        tokens = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            tokens[i] = _allTokens[start + i];
        }
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {

        if (
            interfaceId == 0x01ffc9a7 || // ERC165
            interfaceId == 0x150b7a02    // ERC721TokenReceiver
        ) {
            return true;
        } else {
            return false;
        }
    }

    function _addTokenToEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _moveEth() internal {

        uint256 amount = address(this).balance;
        payable(ISNUFFY500(_tokenContract).getIdentity()).transfer(amount);
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

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _allTokens[_allTokensIndex[tokenId]] == tokenId;
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



struct Verification {
    bytes32 r;
    bytes32 s;
    uint8 v;
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



interface ISNUFFY500 {


    function mint(uint256 state, uint256 tokenId, TokenData[] memory tokenData, address signer, Verification memory verification, address recipient) external;


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external;


    function balanceOf(address wallet) external view returns (uint256);


    function exists(uint256 tokenId) external view returns (bool);


    function getIdentity() external view returns (address);


    function ownerOf(uint256 tokenId) external view returns (address);


}