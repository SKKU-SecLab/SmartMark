

pragma solidity ^0.8.9;



interface IPixelCons {

	function getAdmin() external view returns(address);


	function create(address to, uint256 tokenId, bytes8 name) external payable returns(uint64);

	function rename(uint256 tokenId, bytes8 name) external returns(uint64);

	function exists(uint256 tokenId) external view returns(bool);

	function creatorOf(uint256 tokenId) external view returns(address);

	function creatorTotal(address creator) external view returns(uint256);

	function tokenOfCreatorByIndex(address creator, uint256 index) external view returns(uint256);

	function getTokenIndex(uint256 tokenId) external view returns(uint64);


	function createCollection(uint64[] memory tokenIndexes, bytes8 name) external returns(uint64);

	function renameCollection(uint64 collectionIndex, bytes8 name) external returns(uint64);

	function clearCollection(uint64 collectionIndex) external returns(uint64);

	function collectionExists(uint64 collectionIndex) external view returns(bool);

	function collectionCleared(uint64 collectionIndex) external view returns(bool);

	function totalCollections() external view returns(uint256);

	function collectionOf(uint256 tokenId) external view returns(uint256);

	function collectionTotal(uint64 collectionIndex) external view returns(uint256);

	function getCollectionName(uint64 collectionIndex) external view returns(bytes8);

	function tokenOfCollectionByIndex(uint64 collectionIndex, uint256 index) external view returns(uint256);


	function balanceOf(address owner) external view returns(uint256);

	function ownerOf(uint256 tokenId) external view returns(address);

	function approve(address to, uint256 tokenId) external;

	function getApproved(uint256 tokenId) external view returns(address);

	function setApprovalForAll(address to, bool approved) external;

	function isApprovedForAll(address owner, address operator) external view returns(bool);

	function transferFrom(address from, address to, uint256 tokenId) external;

	function safeTransferFrom(address from, address to, uint256 tokenId) external;

	function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external;


	function totalSupply() external view returns(uint256);

	function tokenByIndex(uint256 tokenIndex) external view returns(uint256);

	function tokenOfOwnerByIndex(address owner, uint256 index) external view returns(uint256);


	function name() external view returns(string memory);

	function symbol() external view returns(string memory);

	function tokenURI(uint256 tokenId) external view returns(string memory);

}



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
        require(owner() == _msgSender(), "Caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



interface ICrossDomainMessenger {


    event SentMessage(
        address indexed target,
        address sender,
        bytes message,
        uint256 messageNonce,
        uint256 gasLimit
    );
    event RelayedMessage(bytes32 indexed msgHash);
    event FailedRelayedMessage(bytes32 indexed msgHash);


    function xDomainMessageSender() external view returns (address);



    function sendMessage(
        address _target,
        bytes calldata _message,
        uint32 _gasLimit
    ) external;

}



contract CrossDomainEnabled {


    address public messenger;


    constructor(address _messenger) {
        messenger = _messenger;
    }


    modifier onlyFromCrossDomainAccount(address _sourceDomainAccount) {

        require(
            msg.sender == address(getCrossDomainMessenger()),
            "OVM_XCHAIN: messenger contract unauthenticated"
        );

        require(
            getCrossDomainMessenger().xDomainMessageSender() == _sourceDomainAccount,
            "OVM_XCHAIN: wrong sender of cross-domain message"
        );

        _;
    }


    function getCrossDomainMessenger() internal virtual returns (ICrossDomainMessenger) {

        return ICrossDomainMessenger(messenger);
    }

    function sendCrossDomainMessage(
        address _crossDomainTarget,
        uint32 _gasLimit,
        bytes memory _message
    ) internal {

        getCrossDomainMessenger().sendMessage(_crossDomainTarget, _message, _gasLimit);
    }
}



contract PixelConInvadersBridge is Ownable, CrossDomainEnabled {


	
	uint64 constant MAX_TOKENS = 1000;
	uint64 constant MINT1_PIXELCON_INDEX = 1411;//before Feb 1st, 2022 (620 mintable)
	uint64 constant MINT2_PIXELCON_INDEX = 791; //before Jan 1st, 2021 (156 mintable)
	uint64 constant MINT3_PIXELCON_INDEX = 713; //before Jan 1st, 2020 (186 mintable)
	uint64 constant MINT4_PIXELCON_INDEX = 651; //Genesis (1950 mintable)
	uint64 constant MINT5_PIXELCON_INDEX = 651; 
	uint64 constant MINT6_PIXELCON_INDEX = 651; //2912 Invaders to mint from
	
	
	
	
	address internal _pixelconsContract;
	
	address internal _pixelconInvadersContract;

	uint256 internal _generationSeed;



	event Mint(uint256 indexed invaderId, uint256 generationSeed, uint256 generationId, uint256 generationIndex, address minter);
	event Bridge(uint256 indexed invaderId, address to);
	event Unbridge(uint256 indexed invaderId, address to);



	constructor(address pixelconsContract, address l1CrossDomainMessenger) CrossDomainEnabled(l1CrossDomainMessenger) Ownable() {
		_pixelconsContract = pixelconsContract;
		_pixelconInvadersContract = address(0);
		_generationSeed = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.difficulty)));
	}

	function linkInvadersContract(address pixelconInvadersContract) public onlyOwner {

		require(_pixelconInvadersContract == address(0), "Already set");
		_pixelconInvadersContract = pixelconInvadersContract;
	}

	function cycleGenerationSeed() public onlyOwner {

		_generationSeed = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.difficulty)));
	}
	
	
	function mintInvader(uint256 pixelconId, uint32 generationIndex, uint32 gasLimit) public returns (uint256) {

		require(generationIndex < 6, "Invalid index");
		address minter = _msgSender();
		
		address pixelconOwner = IPixelCons(_pixelconsContract).ownerOf(pixelconId);
		require(pixelconOwner == minter, "Not PixelCon owner");
		
		uint256 numInvadersCreated = IPixelCons(_pixelconsContract).creatorTotal(address(this));
		require(numInvadersCreated < MAX_TOKENS, "Max Invaders have been minted");
		
		uint64 pixelconIndex = IPixelCons(_pixelconsContract).getTokenIndex(pixelconId);
		if(generationIndex == 5) require(pixelconIndex <= MINT6_PIXELCON_INDEX, "Index out of bounds");
		if(generationIndex == 4) require(pixelconIndex <= MINT5_PIXELCON_INDEX, "Index out of bounds");
		if(generationIndex == 3) require(pixelconIndex <= MINT4_PIXELCON_INDEX, "Index out of bounds");
		if(generationIndex == 2) require(pixelconIndex <= MINT3_PIXELCON_INDEX, "Index out of bounds");
		if(generationIndex == 1) require(pixelconIndex <= MINT2_PIXELCON_INDEX, "Index out of bounds");
		if(generationIndex == 0) require(pixelconIndex <= MINT1_PIXELCON_INDEX, "Index out of bounds");
		
		uint256 invaderId = _generate(pixelconId, generationIndex);
		
		IPixelCons(_pixelconsContract).create(address(this), invaderId, bytes8(0));

		_bridgeToL2(invaderId, minter, gasLimit);

		emit Mint(invaderId, _generationSeed, pixelconId, generationIndex, minter);
		return invaderId;
	}
	
	function bridgeToL2(uint256 tokenId, address from, address to, uint32 gasLimit) public {

		require(to != address(0), "Invalid address");
		
		address pixelconOwner = IPixelCons(_pixelconsContract).ownerOf(tokenId);
		require(pixelconOwner == _msgSender(), "Not owner");
		
		address pixelconCreator = IPixelCons(_pixelconsContract).creatorOf(tokenId);
		require(pixelconCreator == address(this), "Not Invader");
		
		IPixelCons(_pixelconsContract).transferFrom(from, address(this), tokenId);
	
		_bridgeToL2(tokenId, to, gasLimit);
	}
	
	function unbridgeFromL2(uint256 tokenId, address to) external onlyFromCrossDomainAccount(_pixelconInvadersContract) {

		
		IPixelCons(_pixelconsContract).transferFrom(address(this), to, tokenId);
		emit Unbridge(tokenId, to);
	}
	
    function getGenerationSeed() public view returns (uint256) {

        return _generationSeed;
    }
	
    function getPixelconsContract() public view returns (address) {

        return _pixelconsContract;
    }
	
    function getPixelconInvadersContract() public view returns (address) {

        return _pixelconInvadersContract;
    }
	

	
	function _bridgeToL2(uint256 tokenId, address to, uint32 gasLimit) private {

		bytes memory message = abi.encodeWithSignature("bridgeFromL1(uint256,address)", tokenId, to);

		sendCrossDomainMessage(_pixelconInvadersContract, gasLimit, message);
		emit Bridge(tokenId, to);
	}
	
	
	
	function _generate(uint256 pixelconId, uint32 generationIndex) private view returns (uint256) {

		uint256 seed = uint256(keccak256(abi.encodePacked(_generationSeed, pixelconId, generationIndex)));

		uint8 horizontalExpand1 = uint8(seed & 0x00000001);
		uint8 verticalExpand1 = uint8(seed & 0x00000002);
		uint8 horizontalExpand2 = uint8(seed & 0x00000004);
		uint8 verticalExpand2 = uint8(seed & 0x00000008);
		seed = seed >> 32;

		(uint256 color1, uint256 color2, uint256 color3) = _getColors(seed);
		seed = seed >> 32;

		uint256 mask1 = _generateMask_5x5(seed, verticalExpand1, horizontalExpand1);
		seed = seed >> 32;
		uint256 mask2 = _generateMask_5x5(seed, verticalExpand2, horizontalExpand2);
		seed = seed >> 32;
		uint256 mask3 = _generateMask_8x8(seed);
		seed = seed >> 64;
		uint256 combinedMask = mask1 & mask2;
		uint256 highlightMask = mask1 & mask3;

		uint256 invaderId = ((mask1 & ~combinedMask & ~highlightMask) & color1) | ((combinedMask & ~highlightMask) & color2) | (highlightMask & color3);
		return invaderId;
	}
	
	function _generateMask_8x8(uint256 seed) private pure returns (uint256){

		uint256 mask = _generateLine_8x8(seed);
		mask = (mask << 32) + _generateLine_8x8(seed >> 8);
		mask = (mask << 32) + _generateLine_8x8(seed >> 16);
		mask = (mask << 32) + _generateLine_8x8(seed >> 24);
		mask = (mask << 32) + _generateLine_8x8(seed >> 32);
		mask = (mask << 32) + _generateLine_8x8(seed >> 40);
		mask = (mask << 32) + _generateLine_8x8(seed >> 48);
		mask = (mask << 32) + _generateLine_8x8(seed >> 56);
		return mask;
	}
	
	function _generateLine_8x8(uint256 seed) private pure returns (uint256){

		uint256 line = 0x00000000;
		if((seed & 0x00000003) == 0x00000001) line |= 0x000ff000;
		if((seed & 0x0000000c) == 0x00000004) line |= 0x00f00f00;
		if((seed & 0x00000030) == 0x00000010) line |= 0x0f0000f0;
		if((seed & 0x000000c0) == 0x00000040) line |= 0xf000000f;
		return line;
	}
	
	function _generateMask_5x5(uint256 seed, uint8 verticalExpand, uint8 horizontalExpand) private pure returns (uint256){

		uint256 mask = 0x0000000000000000000000000000000000000000000000000000000000000000;
		uint256 line1 = _generateLine_5x5(seed, horizontalExpand);
		uint256 line2 = _generateLine_5x5(seed >> 3, horizontalExpand);
		uint256 line3 = _generateLine_5x5(seed >> 6, horizontalExpand);
		uint256 line4 = _generateLine_5x5(seed >> 9, horizontalExpand);
		uint256 line5 = _generateLine_5x5(seed >> 12, horizontalExpand);
		if(verticalExpand > 0) {
			mask = (line1 << 224) + (line2 << 192) + (line2 << 160) + (line3 << 128) + (line4 << 96) + (line4 << 64) + (line5 << 32) + (line5);
		} else {
			mask = (line1 << 224) + (line1 << 192) + (line2 << 160) + (line2 << 128) + (line3 << 96) + (line4 << 64) + (line4 << 32) + (line5);
		}
		return mask;
	}
	
	function _generateLine_5x5(uint256 seed, uint8 horizontalExpand) private pure returns (uint256){

		uint256 line = 0x00000000;
		if((seed & 0x00000001) == 0x00000001) line |= 0x000ff000;
		if(horizontalExpand > 0) {
			if((seed & 0x00000002) == 0x00000002) line |= 0x0ff00ff0;
			if((seed & 0x00000004) == 0x00000004) line |= 0xf000000f;
		} else {
			if((seed & 0x00000002) == 0x00000002) line |= 0x00f00f00;
			if((seed & 0x00000004) == 0x00000004) line |= 0xff0000ff;
		}
		return line;
	}

	function _getColors(uint256 seed) private pure returns (uint256, uint256, uint256){

		uint256 color1 = 0x0000000000000000000000000000000000000000000000000000000000000000;
		uint256 color2 = 0x0000000000000000000000000000000000000000000000000000000000000000;
		uint256 color3 = 0x0000000000000000000000000000000000000000000000000000000000000000;

		uint256 colorNum = seed & 0x000000ff;
		if(colorNum < 0x00000080) {
			if(colorNum < 0x00000055) {
				if(colorNum < 0x0000002B) color3 = 0x7777777777777777777777777777777777777777777777777777777777777777;
				else color3 = 0x8888888888888888888888888888888888888888888888888888888888888888;
			} else {
				color3 = 0x9999999999999999999999999999999999999999999999999999999999999999;
			}
		} else {
			if(colorNum < 0x000000D5) {
				if(colorNum < 0x000000AB) color3 = 0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
				else color3 = 0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb;
			} else {
				color3 = 0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc;
			}
		}

		if((seed & 0x00000100) == 0x00000100) color1 = 0x1111111111111111111111111111111111111111111111111111111111111111;
		else color1 = 0x5555555555555555555555555555555555555555555555555555555555555555;

		if((seed & 0x00000200) == 0x00000200) color2 = 0x6666666666666666666666666666666666666666666666666666666666666666;
		else color2 = 0xdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd;

		return (color1, color2, color3);
	}
}