pragma solidity 0.8.4;


contract OurStorage {

    bytes32 public merkleRoot;
    uint256 public currentWindow;

    address internal _pylon;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint256[] public balanceForWindow;
    mapping(bytes32 => bool) internal _claimed;
    uint256 internal _depositedInWindow;
}// GPL-3.0-or-later
pragma solidity 0.8.4;


interface IERC20 {

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function balanceOf(address account) external view returns (uint256);

}

interface IWETH {

    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);

}


contract OurSplitter is OurStorage {

    struct Proof {
        bytes32[] merkleProof;
    }

    uint256 public constant PERCENTAGE_SCALE = 10e5;

    event ETHReceived(address indexed sender, uint256 value);
    event WindowIncremented(uint256 currentWindow, uint256 fundsAvailable);
    event TransferETH(address account, uint256 amount, bool success);
    event TransferERC20(address token, uint256 amount);

    receive() external payable {
        _depositedInWindow += msg.value;
        emit ETHReceived(msg.sender, msg.value);
    }

    function claimETH(
        uint256 window,
        address account,
        uint256 scaledPercentageAllocation,
        bytes32[] calldata merkleProof
    ) external {

        require(currentWindow > window, "cannot claim for a future window");
        require(
            !isClaimed(window, account),
            "Account already claimed the given window"
        );

        _setClaimed(window, account);

        require(
            _verifyProof(
                merkleProof,
                merkleRoot,
                _getNode(account, scaledPercentageAllocation)
            ),
            "Invalid proof"
        );

        _transferETHOrWETH(
            account,
            scaleAmountByPercentage(
                balanceForWindow[window],
                scaledPercentageAllocation
            )
        );
    }

    function claimERC20ForAll(
        address tokenAddress,
        address[] calldata accounts,
        uint256[] calldata allocations,
        Proof[] calldata merkleProofs
    ) external {

        require(
            _verifyProof(
                merkleProofs[0].merkleProof,
                merkleRoot,
                _getNode(accounts[0], allocations[0])
            ),
            "Invalid proof for Account 0"
        );

        uint256 erc20Balance = IERC20(tokenAddress).balanceOf(address(this));

        for (uint256 i = 1; i < accounts.length; i++) {
            require(
                _verifyProof(
                    merkleProofs[i].merkleProof,
                    merkleRoot,
                    _getNode(accounts[i], allocations[i])
                ),
                "Invalid proof"
            );

            uint256 scaledAmount = scaleAmountByPercentage(
                erc20Balance,
                allocations[i]
            );
            _attemptERC20Transfer(tokenAddress, accounts[i], scaledAmount);
        }

        _attemptERC20Transfer(
            tokenAddress,
            accounts[0],
            IERC20(tokenAddress).balanceOf(address(this))
        );

        emit TransferERC20(tokenAddress, erc20Balance);
    }

    function claimETHForAllWindows(
        address account,
        uint256 percentageAllocation,
        bytes32[] calldata merkleProof
    ) external {

        require(
            _verifyProof(
                merkleProof,
                merkleRoot,
                _getNode(account, percentageAllocation)
            ),
            "Invalid proof"
        );

        uint256 amount = 0;
        for (uint256 i = 0; i < currentWindow; i++) {
            if (!isClaimed(i, account)) {
                _setClaimed(i, account);

                amount += scaleAmountByPercentage(
                    balanceForWindow[i],
                    percentageAllocation
                );
            }
        }

        _transferETHOrWETH(account, amount);
    }

    function incrementThenClaimAll(
        address account,
        uint256 percentageAllocation,
        bytes32[] calldata merkleProof
    ) external {

        incrementWindow();
        _claimAll(account, percentageAllocation, merkleProof);
    }

    function incrementWindow() public {

        uint256 fundsAvailable;

        if (currentWindow == 0) {
            fundsAvailable = address(this).balance;
        } else {
            fundsAvailable = _depositedInWindow;
        }

        _depositedInWindow = 0;
        require(fundsAvailable > 0, "No additional funds for window");
        balanceForWindow.push(fundsAvailable);
        currentWindow += 1;
        emit WindowIncremented(currentWindow, fundsAvailable);
    }

    function isClaimed(uint256 window, address account)
        public
        view
        returns (bool)
    {

        return _claimed[_getClaimHash(window, account)];
    }

    function scaleAmountByPercentage(uint256 amount, uint256 scaledPercent)
        public
        pure
        returns (uint256 scaledAmount)
    {

        scaledAmount = (amount * scaledPercent) / (100 * PERCENTAGE_SCALE);
    }

    function _claimAll(
        address account,
        uint256 percentageAllocation,
        bytes32[] calldata merkleProof
    ) private {

        require(
            _verifyProof(
                merkleProof,
                merkleRoot,
                _getNode(account, percentageAllocation)
            ),
            "Invalid proof"
        );

        uint256 amount = 0;
        for (uint256 i = 0; i < currentWindow; i++) {
            if (!isClaimed(i, account)) {
                _setClaimed(i, account);

                amount += scaleAmountByPercentage(
                    balanceForWindow[i],
                    percentageAllocation
                );
            }
        }

        _transferETHOrWETH(account, amount);
    }

    function _setClaimed(uint256 window, address account) private {

        _claimed[_getClaimHash(window, account)] = true;
    }

    function _transferETHOrWETH(address to, uint256 value)
        private
        returns (bool didSucceed)
    {

        didSucceed = _attemptETHTransfer(to, value);
        if (!didSucceed) {
            IWETH(WETH).deposit{value: value}();
            IWETH(WETH).transfer(to, value);
            didSucceed = true;
        }

        emit TransferETH(to, value, didSucceed);
    }

    function _attemptETHTransfer(address to, uint256 value)
        private
        returns (bool)
    {

        (bool success, ) = to.call{value: value, gas: 30000}("");
        return success;
    }

    function _attemptERC20Transfer(
        address tokenAddress,
        address splitRecipient,
        uint256 allocatedAmount
    ) private {

        bool didSucceed = IERC20(tokenAddress).transfer(
            splitRecipient,
            allocatedAmount
        );
        require(didSucceed);
    }

    function _getClaimHash(uint256 window, address account)
        private
        pure
        returns (bytes32)
    {

        return keccak256(abi.encodePacked(window, account));
    }

    function _amountFromPercent(uint256 amount, uint32 percent)
        private
        pure
        returns (uint256)
    {

        return (amount * percent) / 100;
    }

    function _getNode(address account, uint256 percentageAllocation)
        private
        pure
        returns (bytes32)
    {

        return keccak256(abi.encodePacked(account, percentageAllocation));
    }

    function _verifyProof(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) private pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }

        return computedHash == root;
    }
}// GPL-3.0-or-later
pragma solidity 0.8.4;


contract OurManagement {

    address internal constant SENTINEL_OWNERS = address(0x1);

    mapping(address => address) internal owners;
    uint256 internal ownerCount;
    uint256 internal threshold;

    event SplitSetup(address[] owners);
    event AddedOwner(address owner);
    event RemovedOwner(address owner);
    event NameChanged(string newName);

    modifier onlyOwners() {

        checkIsOwner(_msgSender());
        _;
    }

    function addOwner(address owner) public onlyOwners {

        require(
            owner != address(0) &&
                owner != SENTINEL_OWNERS &&
                owner != address(this)
        );
        require(owners[owner] == address(0));
        owners[owner] = owners[SENTINEL_OWNERS];
        owners[SENTINEL_OWNERS] = owner;
        ownerCount++;
        emit AddedOwner(owner);
    }

    function removeOwner(address prevOwner, address owner) public onlyOwners {

        require(owner != address(0) && owner != SENTINEL_OWNERS);
        require(owners[prevOwner] == owner);
        owners[prevOwner] = owners[owner];
        owners[owner] = address(0);
        ownerCount--;
        emit RemovedOwner(owner);
    }

    function swapOwner(
        address prevOwner,
        address oldOwner,
        address newOwner
    ) public onlyOwners {

        require(
            newOwner != address(0) &&
                newOwner != SENTINEL_OWNERS &&
                newOwner != address(this),
            "2"
        );
        require(owners[newOwner] == address(0), "3");
        require(oldOwner != address(0) && oldOwner != SENTINEL_OWNERS, "4");
        require(owners[prevOwner] == oldOwner, "5");
        owners[newOwner] = owners[oldOwner];
        owners[prevOwner] = newOwner;
        owners[oldOwner] = address(0);
        emit RemovedOwner(oldOwner);
        emit AddedOwner(newOwner);
    }

    function editNickname(string calldata newName_) public onlyOwners {

        emit NameChanged(newName_);
    }

    function isOwner(address owner) public view returns (bool) {

        return owner != SENTINEL_OWNERS && owners[owner] != address(0);
    }

    function getOwners() public view returns (address[] memory) {

        address[] memory array = new address[](ownerCount);

        uint256 index = 0;
        address currentOwner = owners[SENTINEL_OWNERS];
        while (currentOwner != SENTINEL_OWNERS) {
            array[index] = currentOwner;
            currentOwner = owners[currentOwner];
            index++;
        }
        return array;
    }

    function setupOwners(address[] memory owners_) internal {

        require(threshold == 0, "Setup has already been completed once.");
        address currentOwner = SENTINEL_OWNERS;
        for (uint256 i = 0; i < owners_.length; i++) {
            address owner = owners_[i];
            require(
                owner != address(0) &&
                    owner != SENTINEL_OWNERS &&
                    owner != address(this) &&
                    currentOwner != owner
            );
            require(owners[owner] == address(0));
            owners[currentOwner] = owner;
            currentOwner = owner;
        }
        owners[currentOwner] = SENTINEL_OWNERS;
        ownerCount = owners_.length;
        threshold = 1;
    }

    function _msgSender() internal view returns (address) {

        return msg.sender;
    }

    function checkIsOwner(address caller_) internal view {

        require(
            isOwner(caller_),
            "Caller is not a whitelisted owner of this Split"
        );
    }
}// GPL-3.0-or-later
pragma solidity 0.8.4;


interface IZora {

    struct D256 {
        uint256 value;
    }

    struct EIP712Signature {
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct MediaData {
        string tokenURI;
        string metadataURI;
        bytes32 contentHash;
        bytes32 metadataHash;
    }

    function totalSupply() external returns (uint256);


    function tokenByIndex(uint256 index) external returns (uint256);


    function mint(MediaData calldata data, BidShares calldata bidShares)
        external;


    function mintWithSig(
        address creator,
        MediaData calldata data,
        BidShares calldata bidShares,
        EIP712Signature calldata sig
    ) external;


    function updateTokenURI(uint256 tokenId, string calldata tokenURI) external;


    function updateTokenMetadataURI(
        uint256 tokenId,
        string calldata metadataURI
    ) external;


    struct Bid {
        uint256 amount;
        address currency;
        address bidder;
        address recipient;
        D256 sellOnShare;
    }

    struct Ask {
        uint256 amount;
        address currency;
    }

    struct BidShares {
        D256 prevOwner;
        D256 creator;
        D256 owner;
    }

    function setBidShares(uint256 tokenId, BidShares calldata bidShares)
        external;


    function setAsk(uint256 tokenId, Ask calldata ask) external;


    function removeAsk(uint256 tokenId) external;


    function setBid(
        uint256 tokenId,
        Bid calldata bid,
        address spender
    ) external;


    function removeBid(uint256 tokenId, address bidder) external;


    function acceptBid(uint256 tokenId, Bid calldata expectedBid) external;


    struct Auction {
        uint256 tokenId;
        address tokenContract;
        bool approved;
        uint256 amount;
        uint256 duration;
        uint256 firstBidTime;
        uint256 reservePrice;
        uint8 curatorFeePercentage;
        address tokenOwner;
        address payable bidder;
        address payable curator;
        address auctionCurrency;
    }

    function createAuction(
        uint256 tokenId,
        address tokenContract,
        uint256 duration,
        uint256 reservePrice,
        address payable curator,
        uint8 curatorFeePercentage,
        address auctionCurrency
    ) external returns (uint256);


    function setAuctionApproval(uint256 auctionId, bool approved) external;


    function setAuctionReservePrice(uint256 auctionId, uint256 reservePrice)
        external;


    function createBid(uint256 auctionId, uint256 amount) external payable;


    function endAuction(uint256 auctionId) external;


    function cancelAuction(uint256 auctionId) external;




    function createEdition(
        string memory _name,
        string memory _symbol,
        string memory _description,
        string memory _animationUrl,
        bytes32 _animationHash,
        string memory _imageUrl,
        bytes32 _imageHash,
        uint256 _editionSize,
        uint256 _royaltyBPS
    ) external returns (uint256);


    function setSalePrice(uint256 _salePrice) external;


    function withdraw() external;


    function mintEditions(address[] memory recipients)
        external
        returns (uint256);


    function getEditionAtId(uint256 editionId) external view returns (address);


    function setApprovedMinter(address minter, bool allowed) external;


    function updateEditionURLs(
        string memory _imageUrl,
        string memory _animationUrl
    ) external;

}

interface IERC721Enumerable {

    function totalSupply() external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}

interface IERC721Burnable {

    function burn(uint256 tokenId) external;

}

interface IERC721 is IERC721Burnable, IERC721Enumerable {

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function setApprovalForAll(address operator, bool _approved) external;


}// GPL-3.0-or-later
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;



contract OurMinter is OurManagement {

    address public constant ZORA_MEDIA =
        0xabEFBc9fD2F806065b4f3C237d4b59D9A97Bcac7;
    address public constant ZORA_MARKET =
        0xE5BFAB544ecA83849c53464F85B7164375Bdaac1;
    address public constant ZORA_AH =
        0xE468cE99444174Bd3bBBEd09209577d25D1ad673;
    address public constant ZORA_EDITIONS =
        0x91A8713155758d410DFAc33a63E193AE3E89F909;

    event ZNFTMinted(uint256 tokenId);
    event EditionCreated(
        address editionAddress,
        string name,
        string symbol,
        string description,
        string animationUrl,
        string imageUrl,
        uint256 editionSize,
        uint256 royaltyBPS
    );


    function mintZNFT(
        IZora.MediaData calldata mediaData,
        IZora.BidShares calldata bidShares
    ) external onlyOwners {

        IZora(ZORA_MEDIA).mint(mediaData, bidShares);
        emit ZNFTMinted(_getID());
    }

    function updateZNFTURIs(
        uint256 tokenId,
        string calldata tokenURI,
        string calldata metadataURI
    ) external onlyOwners {

        IZora(ZORA_MEDIA).updateTokenURI(tokenId, tokenURI);
        IZora(ZORA_MEDIA).updateTokenMetadataURI(tokenId, metadataURI);
    }

    function updateZNFTTokenURI(uint256 tokenId, string calldata tokenURI)
        external
        onlyOwners
    {

        IZora(ZORA_MEDIA).updateTokenURI(tokenId, tokenURI);
    }

    function updateZNFTMetadataURI(uint256 tokenId, string calldata metadataURI)
        external
    {

        IZora(ZORA_MEDIA).updateTokenMetadataURI(tokenId, metadataURI);
    }

    function setZMarketBidShares(
        uint256 tokenId,
        IZora.BidShares calldata bidShares
    ) external {

        IZora(ZORA_MARKET).setBidShares(tokenId, bidShares);
    }

    function setZMarketAsk(uint256 tokenId, IZora.Ask calldata ask)
        external
        onlyOwners
    {

        IZora(ZORA_MARKET).setAsk(tokenId, ask);
    }

    function removeZMarketAsk(uint256 tokenId) external onlyOwners {

        IZora(ZORA_MARKET).removeAsk(tokenId);
    }

    function acceptZMarketBid(uint256 tokenId, IZora.Bid calldata expectedBid)
        external
        onlyOwners
    {

        IZora(ZORA_MARKET).acceptBid(tokenId, expectedBid);
    }

    function createZoraAuction(
        uint256 tokenId,
        address tokenContract,
        uint256 duration,
        uint256 reservePrice,
        address payable curator,
        uint8 curatorFeePercentage,
        address auctionCurrency
    ) external onlyOwners {

        IZora(ZORA_AH).createAuction(
            tokenId,
            tokenContract,
            duration,
            reservePrice,
            curator,
            curatorFeePercentage,
            auctionCurrency
        );
    }

    function setZAuctionApproval(uint256 auctionId, bool approved)
        external
        onlyOwners
    {

        IZora(ZORA_AH).setAuctionApproval(auctionId, approved);
    }

    function setZAuctionReservePrice(uint256 auctionId, uint256 reservePrice)
        external
        onlyOwners
    {

        IZora(ZORA_AH).setAuctionReservePrice(auctionId, reservePrice);
    }

    function cancelZAuction(uint256 auctionId) external onlyOwners {

        IZora(ZORA_AH).cancelAuction(auctionId);
    }

    function createZoraEdition(
        string memory name,
        string memory symbol,
        string memory description,
        string memory animationUrl,
        bytes32 animationHash,
        string memory imageUrl,
        bytes32 imageHash,
        uint256 editionSize,
        uint256 royaltyBPS,
        uint256 salePrice,
        bool publicMint
    ) external onlyOwners {

        uint256 editionId = IZora(ZORA_EDITIONS).createEdition(
            name,
            symbol,
            description,
            animationUrl,
            animationHash,
            imageUrl,
            imageHash,
            editionSize,
            royaltyBPS
        );

        address editionAddress = IZora(ZORA_EDITIONS).getEditionAtId(editionId);

        if (salePrice > 0) {
            IZora(editionAddress).setSalePrice(salePrice);
        }

        if (publicMint) {
            IZora(editionAddress).setApprovedMinter(address(0x0), true);
        }

        emit EditionCreated(
            editionAddress,
            name,
            symbol,
            description,
            animationUrl,
            imageUrl,
            editionSize,
            royaltyBPS
        );
    }

    function setEditionPrice(address editionAddress, uint256 salePrice)
        external
        onlyOwners
    {

        IZora(editionAddress).setSalePrice(salePrice);
    }

    function setEditionMinter(
        address editionAddress,
        address minter,
        bool allowed
    ) external onlyOwners {

        IZora(editionAddress).setApprovedMinter(minter, allowed);
    }

    function mintEditionsTo(
        address editionAddress,
        address[] calldata recipients
    ) external onlyOwners {

        IZora(editionAddress).mintEditions(recipients);
    }

    function withdrawEditionFunds(address editionAddress) external {

        IZora(editionAddress).withdraw();
    }

    function updateEditionURLs(
        address editionAddress,
        string memory imageUrl,
        string memory animationUrl
    ) external onlyOwners {

        IZora(editionAddress).updateEditionURLs(imageUrl, animationUrl);
    }

    function _setApprovalForAH() internal {

        IERC721(ZORA_MEDIA).setApprovalForAll(ZORA_AH, true);
    }

    function mintToAuctionForETH(
        IZora.MediaData calldata mediaData,
        IZora.BidShares calldata bidShares,
        uint256 duration,
        uint256 reservePrice
    ) external onlyOwners {

        IZora(ZORA_MEDIA).mint(mediaData, bidShares);

        uint256 tokenId_ = _getID();
        emit ZNFTMinted(tokenId_);

        IZora(ZORA_AH).createAuction(
            tokenId_,
            ZORA_MEDIA,
            duration,
            reservePrice,
            payable(address(this)),
            0,
            address(0)
        );
    }



    function untrustedSafeTransferERC721(
        address tokenContract_,
        address newOwner_,
        uint256 tokenId_
    ) external onlyOwners {

        IERC721(tokenContract_).safeTransferFrom(
            address(this),
            newOwner_,
            tokenId_
        );
    }

    function untrustedSetApprovalERC721(
        address tokenContract_,
        address operator_,
        bool approved_
    ) external onlyOwners {

        IERC721(tokenContract_).setApprovalForAll(operator_, approved_);
    }

    function untrustedBurnERC721(address tokenContract_, uint256 tokenId_)
        external
        onlyOwners
    {

        IERC721(tokenContract_).burn(tokenId_);
    }

    function executeTransaction(address to, bytes memory data)
        external
        onlyOwners
        returns (bool success)
    {

        assembly {
            success := call(gas(), to, 0, add(data, 0x20), mload(data), 0, 0)
        }
    }

    function _getID() private returns (uint256 id) {

        id = IZora(ZORA_MEDIA).tokenByIndex(
            IZora(ZORA_MEDIA).totalSupply() - 1
        );
    }
}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

interface ERC1155TokenReceiver {

    function onERC1155Received(
        address _operator,
        address _from,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external returns (bytes4);

}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

interface ERC721TokenReceiver {

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);

}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

interface ERC777TokensRecipient {

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

}// LGPL-3.0-only
pragma solidity >=0.7.0 <0.9.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// GPL-3.0-or-later
pragma solidity 0.8.4;



contract OurIntrospector is
    ERC1155TokenReceiver,
    ERC777TokensRecipient,
    ERC721TokenReceiver,
    IERC165
{


    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        return 0x150b7a02;
    }


    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        return 0xf23a6e61;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {

        return 0xbc197c81;
    }

    event ERC777Received(
        address operator,
        address from,
        address to,
        uint256 amount
    );

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata,
        bytes calldata
    ) external override {

        emit ERC777Received(operator, from, to, amount);
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {

        return
            interfaceId == type(ERC1155TokenReceiver).interfaceId ||
            interfaceId == type(ERC721TokenReceiver).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}// GPL-3.0-or-later


pragma solidity 0.8.4;



contract OurPylon is OurSplitter, OurMinter, OurIntrospector {

    constructor() {
        threshold = 1;
    }

    function setup(address[] calldata owners_) external {

        setupOwners(owners_);
        emit SplitSetup(owners_);

        _setApprovalForAH();
    }
}