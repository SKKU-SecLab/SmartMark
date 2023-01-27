

pragma solidity 0.8.12;


contract PA1D {

    event SecondarySaleFees(uint256 tokenId, address[] recipients, uint256[] bps);

    modifier onlyOwner() {

        require(isOwner(), "PA1D: caller not an owner");
        _;
    }

    constructor() {}

    function init(
        uint256 tokenId,
        address payable receiver,
        uint256 bp
    ) public onlyOwner {}


    function getRegistry() internal pure returns (ICxipRegistry) {

        return ICxipRegistry(0xC267d41f81308D7773ecB3BDd863a902ACC01Ade);
    }

    function isIdentityWallet(address sender) internal view returns (bool) {

        return isIdentityWallet(ICxipERC(address(this)).getIdentity(), sender);
    }

    function isIdentityWallet(address identity, address sender) internal view returns (bool) {

        if (Address.isZero(identity)) {
            return false;
        }
        return ICxipIdentity(identity).isWalletRegistered(sender);
    }

    function isOwner() internal view returns (bool) {

        ICxipERC erc = ICxipERC(address(this));
        return (msg.sender == erc.owner() ||
            msg.sender == erc.admin() ||
            isIdentityWallet(erc.getIdentity(), msg.sender));
    }

    function _getDefaultReceiver() internal view returns (address payable receiver) {

        assembly {
            receiver := sload(
                0xaee4e97c19ce50ea5345ba9751676d533a3a7b99c3568901208f92f9eea6a7f2
            )
        }
    }

    function _setDefaultReceiver(address receiver) internal {

        assembly {
            sstore(
                0xaee4e97c19ce50ea5345ba9751676d533a3a7b99c3568901208f92f9eea6a7f2,
                receiver
            )
        }
    }

    function _getDefaultBp() internal view returns (uint256 bp) {

        assembly {
            bp := sload(
                0xfd198c3b406b2320ea9f4a413c7a69a7592dbfc4175b8c252fec24223e68b720
            )
        }
    }

    function _setDefaultBp(uint256 bp) internal {

        assembly {
            sstore(
                0xfd198c3b406b2320ea9f4a413c7a69a7592dbfc4175b8c252fec24223e68b720,
                bp
            )
        }
    }

    function _getReceiver(uint256 tokenId) internal view returns (address payable receiver) {

        bytes32 slot = bytes32(
            uint256(keccak256(abi.encodePacked("eip1967.PA1D.receiver", tokenId))) - 1
        );
        assembly {
            receiver := sload(slot)
        }
    }

    function _setReceiver(uint256 tokenId, address receiver) internal {

        bytes32 slot = bytes32(
            uint256(keccak256(abi.encodePacked("eip1967.PA1D.receiver", tokenId))) - 1
        );
        assembly {
            sstore(slot, receiver)
        }
    }

    function _getBp(uint256 tokenId) internal view returns (uint256 bp) {

        bytes32 slot = bytes32(
            uint256(keccak256(abi.encodePacked("eip1967.PA1D.bp", tokenId))) - 1
        );
        assembly {
            bp := sload(slot)
        }
    }

    function _setBp(uint256 tokenId, uint256 bp) internal {

        bytes32 slot = bytes32(
            uint256(keccak256(abi.encodePacked("eip1967.PA1D.bp", tokenId))) - 1
        );
        assembly {
            sstore(slot, bp)
        }
    }

    function _getPayoutAddresses() internal view returns (address payable[] memory addresses) {

        bytes32 slot = 0xda9d0b1bc91e594968e30b896be60318d483303fc3ba08af8ac989d483bdd7ca;
        uint256 length;
        assembly {
            length := sload(slot)
        }
        addresses = new address payable[](length);
        address payable value;
        for (uint256 i = 0; i < length; i++) {
            slot = keccak256(abi.encodePacked(i, slot));
            assembly {
                value := sload(slot)
            }
            addresses[i] = value;
        }
    }

    function _setPayoutAddresses(address payable[] memory addresses) internal {

        bytes32 slot = 0xda9d0b1bc91e594968e30b896be60318d483303fc3ba08af8ac989d483bdd7ca;
        uint256 length = addresses.length;
        assembly {
            sstore(slot, length)
        }
        address payable value;
        for (uint256 i = 0; i < length; i++) {
            slot = keccak256(abi.encodePacked(i, slot));
            value = addresses[i];
            assembly {
                sstore(slot, value)
            }
        }
    }

    function _getPayoutBps() internal view returns (uint256[] memory bps) {

        bytes32 slot = 0x7862b872ab9e3483d8176282b22f4ac86ad99c9035b3f794a541d84a66004fa2;
        uint256 length;
        assembly {
            length := sload(slot)
        }
        bps = new uint256[](length);
        uint256 value;
        for (uint256 i = 0; i < length; i++) {
            slot = keccak256(abi.encodePacked(i, slot));
            assembly {
                value := sload(slot)
            }
            bps[i] = value;
        }
    }

    function _setPayoutBps(uint256[] memory bps) internal {

        bytes32 slot = 0x7862b872ab9e3483d8176282b22f4ac86ad99c9035b3f794a541d84a66004fa2;
        uint256 length = bps.length;
        assembly {
            sstore(slot, length)
        }
        uint256 value;
        for (uint256 i = 0; i < length; i++) {
            slot = keccak256(abi.encodePacked(i, slot));
            value = bps[i];
            assembly {
                sstore(slot, value)
            }
        }
    }

    function _getTokenAddress(string memory tokenName)
        internal
        view
        returns (address tokenAddress)
    {

        bytes32 slot = bytes32(
            uint256(keccak256(abi.encodePacked("eip1967.PA1D.tokenAddress", tokenName))) - 1
        );
        assembly {
            tokenAddress := sload(slot)
        }
    }

    function _setTokenAddress(string memory tokenName, address tokenAddress) internal {

        bytes32 slot = bytes32(
            uint256(keccak256(abi.encodePacked("eip1967.PA1D.tokenAddress", tokenName))) - 1
        );
        assembly {
            sstore(slot, tokenAddress)
        }
    }

    function _payoutEth() internal {

        address payable[] memory addresses = _getPayoutAddresses();
        uint256[] memory bps = _getPayoutBps();
        uint256 length = addresses.length;
        uint256 gasCost = (23300 * length) + length;
        uint256 balance = address(this).balance;
        require(balance - gasCost > 10000, "PA1D: Not enough ETH to transfer");
        balance = balance - gasCost;
        uint256 sending;
        for (uint256 i = 0; i < length; i++) {
            sending = ((bps[i] * balance) / 10000);
            addresses[i].transfer(sending);
        }
    }

    function _payoutToken(address tokenAddress) internal {

        address payable[] memory addresses = _getPayoutAddresses();
        uint256[] memory bps = _getPayoutBps();
        uint256 length = addresses.length;
        IERC20 erc20 = IERC20(tokenAddress);
        uint256 balance = erc20.balanceOf(address(this));
        require(balance > 10000, "PA1D: Not enough tokens to transfer");
        uint256 sending;
        for (uint256 i = 0; i < length; i++) {
            sending = ((bps[i] * balance) / 10000);
            require(erc20.transfer(addresses[i], sending), "PA1D: Couldn't transfer token");
        }
    }

    function _payoutTokens(address[] memory tokenAddresses) internal {

        address payable[] memory addresses = _getPayoutAddresses();
        uint256[] memory bps = _getPayoutBps();
        IERC20 erc20;
        uint256 balance;
        uint256 sending;
        for (uint256 t = 0; t < tokenAddresses.length; t++) {
            erc20 = IERC20(tokenAddresses[t]);
            balance = erc20.balanceOf(address(this));
            require(balance > 10000, "PA1D: Not enough tokens to transfer");
            for (uint256 i = 0; i < addresses.length; i++) {
                sending = ((bps[i] * balance) / 10000);
                require(erc20.transfer(addresses[i], sending), "PA1D: Couldn't transfer token");
            }
        }
    }

    function _validatePayoutRequestor() internal view {

        if (!isOwner()) {
            bool matched;
            address payable[] memory addresses = _getPayoutAddresses();
            address payable sender = payable(msg.sender);
            for (uint256 i = 0; i < addresses.length; i++) {
                if (addresses[i] == sender) {
                    matched = true;
                    break;
                }
            }
            require(matched, "PA1D: sender not authorized");
        }
    }

    function configurePayouts(address payable[] memory addresses, uint256[] memory bps)
        public
        onlyOwner
    {

        require(addresses.length == bps.length, "PA1D: missmatched array lenghts");
        uint256 totalBp;
        for (uint256 i = 0; i < addresses.length; i++) {
            totalBp = totalBp + bps[i];
        }
        require(totalBp == 10000, "PA1D: bps down't equal 10000");
        _setPayoutAddresses(addresses);
        _setPayoutBps(bps);
    }

    function getPayoutInfo()
        public
        view
        returns (address payable[] memory addresses, uint256[] memory bps)
    {

        addresses = _getPayoutAddresses();
        bps = _getPayoutBps();
    }

    function getEthPayout() public {

        _validatePayoutRequestor();
        _payoutEth();
    }

    function getTokenPayout(address tokenAddress) public {

        _validatePayoutRequestor();
        _payoutToken(tokenAddress);
    }

    function getTokenPayoutByName(string memory tokenName) public {

        _validatePayoutRequestor();
        address tokenAddress = PA1D(payable(getRegistry().getPA1D())).getTokenAddress(tokenName);
        require(!Address.isZero(tokenAddress), "PA1D: Token address not found");
        _payoutToken(tokenAddress);
    }

    function getTokensPayout(address[] memory tokenAddresses) public {

        _validatePayoutRequestor();
        _payoutTokens(tokenAddresses);
    }

    function getTokensPayoutByName(string[] memory tokenNames) public {

        _validatePayoutRequestor();
        uint256 length = tokenNames.length;
        address[] memory tokenAddresses = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            address tokenAddress = PA1D(payable(getRegistry().getPA1D())).getTokenAddress(
                tokenNames[i]
            );
            require(!Address.isZero(tokenAddress), "PA1D: Token address not found");
            tokenAddresses[i] = tokenAddress;
        }
        _payoutTokens(tokenAddresses);
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {

        if (
            interfaceId == 0x2a55205a ||
            interfaceId == 0xb7799584 ||
            interfaceId == 0xb9c4d9fb ||
            interfaceId == 0xbb3bafd6 ||
            interfaceId == 0xd5a06d4c ||
            interfaceId == 0xb85ed7e4 ||
            interfaceId == 0x860110f5 ||
            interfaceId == 0xa1794bcd ||
            interfaceId == 0xe0fd045f ||
            interfaceId == 0xf9ce0582
        ) {
            return true;
        }
        return false;
    }

    function setRoyalties(
        uint256 tokenId,
        address payable receiver,
        uint256 bp
    ) public onlyOwner {

        if (tokenId == 0) {
            _setDefaultReceiver(receiver);
            _setDefaultBp(bp);
        } else {
            _setReceiver(tokenId, receiver);
            _setBp(tokenId, bp);
        }
        address[] memory receivers = new address[](1);
        receivers[0] = address(receiver);
        uint256[] memory bps = new uint256[](1);
        bps[0] = bp;
        emit SecondarySaleFees(tokenId, receivers, bps);
    }

    function royaltyInfo(uint256 tokenId, uint256 value) public view returns (address, uint256) {

        if (_getReceiver(tokenId) == address(0)) {
            return (_getDefaultReceiver(), (_getDefaultBp() * value) / 10000);
        } else {
            return (_getReceiver(tokenId), (_getBp(tokenId) * value) / 10000);
        }
    }

    function getFeeBps(uint256 tokenId) public view returns (uint256[] memory) {

        uint256[] memory bps = new uint256[](1);
        if (_getReceiver(tokenId) == address(0)) {
            bps[0] = _getDefaultBp();
        } else {
            bps[0] = _getBp(tokenId);
        }
        return bps;
    }

    function getFeeRecipients(uint256 tokenId) public view returns (address payable[] memory) {

        address payable[] memory receivers = new address payable[](1);
        if (_getReceiver(tokenId) == address(0)) {
            receivers[0] = _getDefaultReceiver();
        } else {
            receivers[0] = _getReceiver(tokenId);
        }
        return receivers;
    }

    function getRoyalties(uint256 tokenId)
        public
        view
        returns (address payable[] memory, uint256[] memory)
    {

        address payable[] memory receivers = new address payable[](1);
        uint256[] memory bps = new uint256[](1);
        if (_getReceiver(tokenId) == address(0)) {
            receivers[0] = _getDefaultReceiver();
            bps[0] = _getDefaultBp();
        } else {
            receivers[0] = _getReceiver(tokenId);
            bps[0] = _getBp(tokenId);
        }
        return (receivers, bps);
    }

    function getFees(uint256 tokenId)
        public
        view
        returns (address payable[] memory, uint256[] memory)
    {

        address payable[] memory receivers = new address payable[](1);
        uint256[] memory bps = new uint256[](1);
        if (_getReceiver(tokenId) == address(0)) {
            receivers[0] = _getDefaultReceiver();
            bps[0] = _getDefaultBp();
        } else {
            receivers[0] = _getReceiver(tokenId);
            bps[0] = _getBp(tokenId);
        }
        return (receivers, bps);
    }

    function tokenCreator(
        address, /* contractAddress*/
        uint256 tokenId
    ) public view returns (address) {

        address receiver = _getReceiver(tokenId);
        if (receiver == address(0)) {
            return _getDefaultReceiver();
        }
        return receiver;
    }

    function calculateRoyaltyFee(
        address, /* contractAddress */
        uint256 tokenId,
        uint256 amount
    ) public view returns (uint256) {

        if (_getReceiver(tokenId) == address(0)) {
            return (_getDefaultBp() * amount) / 10000;
        } else {
            return (_getBp(tokenId) * amount) / 10000;
        }
    }

    function marketContract() public view returns (address) {

        return address(this);
    }

    function tokenCreators(uint256 tokenId) public view returns (address) {

        address receiver = _getReceiver(tokenId);
        if (receiver == address(0)) {
            return _getDefaultReceiver();
        }
        return receiver;
    }

    function bidSharesForToken(uint256 tokenId)
        public
        view
        returns (Zora.BidShares memory bidShares)
    {

        bidShares.prevOwner.value = 0;
        bidShares.owner.value = 0;
        if (_getReceiver(tokenId) == address(0)) {
            bidShares.creator.value = _getDefaultBp();
        } else {
            bidShares.creator.value = _getBp(tokenId);
        }
        return bidShares;
    }

    function getStorageSlot(string calldata slot) public pure returns (bytes32) {

        return bytes32(uint256(keccak256(abi.encodePacked("eip1967.PA1D.", slot))) - 1);
    }

    function getTokenAddress(string memory tokenName) public view returns (address) {

        return _getTokenAddress(tokenName);
    }

    function _defaultFallback() internal {

        address _target = getRegistry().getCustomSource(
            sha256(abi.encodePacked("eip1967.CXIP.hotfixes"))
        );

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

    fallback() external {
        _defaultFallback();
    }

    receive() external payable {}
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 &&
            codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
    }

    function isZero(address account) internal pure returns (bool) {

        return (account == address(0));
    }
}

library Zora {

    struct Decimal {
        uint256 value;
    }

    struct BidShares {
        Decimal prevOwner;
        Decimal creator;
        Decimal owner;
    }
}

enum UriType {
    ARWEAVE, // 0
    IPFS, // 1
    HTTP // 2
}

enum InterfaceType {
    NULL, // 0
    ERC20, // 1
    ERC721, // 2
    ERC1155 // 3
}

struct Verification {
    bytes32 r;
    bytes32 s;
    uint8 v;
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

interface ICxipERC {

    function admin() external view returns (address);


    function getIdentity() external view returns (address);


    function isAdmin() external view returns (bool);


    function isOwner() external view returns (bool);


    function name() external view returns (string memory);


    function owner() external view returns (address);


    function supportsInterface(bytes4 interfaceId) external view returns (bool);


    function symbol() external view returns (string memory);

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


    function listCollections(uint256 offset, uint256 length)
        external
        view
        returns (address[] memory);


    function nextNonce(address wallet) external view returns (uint256);


    function totalCollections() external view returns (uint256);


    function isCollectionOpen(address collection) external pure returns (bool);

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

interface IERC20 {

    function approve(address spender, uint256 amount) external returns (bool);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function totalSupply() external view returns (uint256);

}