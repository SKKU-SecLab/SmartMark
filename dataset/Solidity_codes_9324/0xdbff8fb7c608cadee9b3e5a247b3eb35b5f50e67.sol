




pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}





pragma solidity 0.8.10;


abstract contract IWhitelistable {
	error IWhitelistable_NOT_SET();
	error IWhitelistable_CONSUMED();
	error IWhitelistable_FORBIDDEN();
	error IWhitelistable_NO_ALLOWANCE();

	bytes32 private _root;
	mapping( address => uint256 ) private _consumed;

	modifier isWhitelisted( address account_, bytes32[] memory proof_, uint256 passMax_, uint256 qty_ ) {
		if ( qty_ > passMax_ ) {
			revert IWhitelistable_FORBIDDEN();
		}

		uint256 _allowed_ = _checkWhitelistAllowance( account_, proof_, passMax_ );

		if ( _allowed_ < qty_ ) {
			revert IWhitelistable_FORBIDDEN();
		}

		_;
	}

	function _setWhitelist( bytes32 root_ ) internal virtual {
		_root = root_;
	}

	function _checkWhitelistAllowance( address account_, bytes32[] memory proof_, uint256 passMax_ ) internal view returns ( uint256 ) {
		if ( _root == 0 ) {
			revert IWhitelistable_NOT_SET();
		}

		if ( _consumed[ account_ ] >= passMax_ ) {
			revert IWhitelistable_CONSUMED();
		}

		if ( ! _computeProof( account_, proof_ ) ) {
			revert IWhitelistable_FORBIDDEN();
		}

		uint256 _res_;
		unchecked {
			_res_ = passMax_ - _consumed[ account_ ];
		}

		return _res_;
	}

	function _computeProof( address account_, bytes32[] memory proof_ ) private view returns ( bool ) {
		bytes32 leaf = keccak256(abi.encodePacked(account_));
		return MerkleProof.processProof( proof_, leaf ) == _root;
	}

	function _consumeWhitelist( address account_, uint256 qty_ ) internal {
		unchecked {
			_consumed[ account_ ] += qty_;
		}
	}
}





pragma solidity 0.8.10;

contract OwnableDelegateProxy {}


contract ProxyRegistry {

	mapping( address => OwnableDelegateProxy ) public proxies;
}

abstract contract ITradable {
	address[] internal _proxyRegistries;

	function _setProxyRegistry( address proxyRegistryAddress_ ) internal {
		_proxyRegistries.push( proxyRegistryAddress_ );
	}

	function _isRegisteredProxy( address tokenOwner_, address operator_ ) internal view returns ( bool ) {
		for ( uint256 i; i < _proxyRegistries.length; i++ ) {
			ProxyRegistry _proxyRegistry_ = ProxyRegistry( _proxyRegistries[ i ] );
			if ( address( _proxyRegistry_.proxies( tokenOwner_ ) ) == operator_ ) {
				return true;
			}
		}
		return false;
	}
}




pragma solidity 0.8.10;

abstract contract IPausable {
	error IPausable_SALE_NOT_CLOSED();
	error IPausable_SALE_NOT_OPEN();
	error IPausable_PRESALE_NOT_OPEN();

	enum SaleState { CLOSED, PRESALE, SALE }

	SaleState public saleState;

	event SaleStateChanged( SaleState indexed previousState, SaleState indexed newState );

	function _setSaleState( SaleState newState_ ) internal virtual {
		SaleState _previousState_ = saleState;
		saleState = newState_;
		emit SaleStateChanged( _previousState_, newState_ );
	}

	modifier saleClosed {
		if ( saleState != SaleState.CLOSED ) {
			revert IPausable_SALE_NOT_CLOSED();
		}
		_;
	}

	modifier saleOpen {
		if ( saleState != SaleState.SALE ) {
			revert IPausable_SALE_NOT_OPEN();
		}
		_;
	}

	modifier presaleOpen {
		if ( saleState != SaleState.PRESALE ) {
			revert IPausable_PRESALE_NOT_OPEN();
		}
		_;
	}
}





pragma solidity 0.8.10;

abstract contract IOwnable {
	error IOwnable_NOT_OWNER();

	address private _owner;

	event OwnershipTransferred( address indexed previousOwner, address indexed newOwner );

	function _initIOwnable( address owner_ ) internal {
		_owner = owner_;
	}

	function owner() public view virtual returns ( address ) {
		return _owner;
	}

	modifier onlyOwner() {
		if ( owner() != msg.sender ) {
			revert IOwnable_NOT_OWNER();
		}
		_;
	}

	function transferOwnership( address newOwner_ ) public virtual onlyOwner {
		address _oldOwner_ = _owner;
		_owner = newOwner_;
		emit OwnershipTransferred( _oldOwner_, newOwner_ );
	}
}



pragma solidity 0.8.10;

interface IERC2981 {

  function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount);

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}




pragma solidity 0.8.10;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





pragma solidity 0.8.10;



abstract contract ERC2981Base is IERC165, IERC2981 {
	error IERC2981_INVALID_ROYALTIES();

	uint private constant ROYALTY_BASE = 10000;

	uint256 private _royaltyRate;

	address private _royaltyRecipient;

	function _initERC2981Base( address royaltyRecipient_, uint256 royaltyRate_ ) internal {
		_setRoyaltyInfo( royaltyRecipient_, royaltyRate_ );
	}

	function royaltyInfo( uint256, uint256 salePrice_ ) public view virtual override returns ( address, uint256 ) {
		if ( salePrice_ == 0 || _royaltyRate == 0 ) {
			return ( _royaltyRecipient, 0 );
		}
		uint256 _royaltyAmount_ = _royaltyRate * salePrice_ / ROYALTY_BASE;
		return ( _royaltyRecipient, _royaltyAmount_ );
	}

	function _setRoyaltyInfo( address royaltyRecipient_, uint256 royaltyRate_ ) internal virtual {
		if ( royaltyRate_ > ROYALTY_BASE ) {
			revert IERC2981_INVALID_ROYALTIES();
		}
		_royaltyRate      = royaltyRate_;
		_royaltyRecipient = royaltyRecipient_;
	}

	function supportsInterface( bytes4 interfaceId_ ) public view virtual override returns ( bool ) {
		return 
			interfaceId_ == type( IERC2981 ).interfaceId ||
			interfaceId_ == type( IERC165 ).interfaceId;
	}
}




pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


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


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}




pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}





pragma solidity 0.8.10;




abstract contract ERC721Batch is Context, IERC721Metadata {
	error IERC721_APPROVE_OWNER();
	error IERC721_APPROVE_CALLER();
	error IERC721_CALLER_NOT_APPROVED();
	error IERC721_NONEXISTANT_TOKEN();
	error IERC721_NON_ERC721_RECEIVER();
	error IERC721_NULL_ADDRESS_BALANCE();
	error IERC721_NULL_ADDRESS_TRANSFER();

	string private _name;

	string private _symbol;

	string private _baseURI;

	uint256 private _numTokens;

	mapping( uint256 => address ) private _owners;

	mapping( uint256 => address ) private _tokenApprovals;

	mapping( address => mapping( address => bool ) ) private _operatorApprovals;

	modifier exists( uint256 tokenId_ ) {
		if ( ! _exists( tokenId_ ) ) {
			revert IERC721_NONEXISTANT_TOKEN();
		}
		_;
	}

		function _balanceOf( address tokenOwner_ ) internal view virtual returns ( uint256 ) {
			if ( tokenOwner_ == address( 0 ) ) {
				return 0;
			}

			uint256 _supplyMinted_ = _supplyMinted();
			uint256 _count_ = 0;
			address _currentTokenOwner_;
			for ( uint256 i; i < _supplyMinted_; i++ ) {
				if ( _owners[ i ] != address( 0 ) ) {
					_currentTokenOwner_ = _owners[ i ];
				}
				if ( tokenOwner_ == _currentTokenOwner_ ) {
					_count_++;
				}
			}
			return _count_;
		}

		function _checkOnERC721Received( address from_, address to_, uint256 tokenId_, bytes memory data_ ) internal virtual returns ( bool ) {
			uint256 _size_;
			assembly {
				_size_ := extcodesize( to_ )
			}

			if ( _size_ > 0 ) {
				try IERC721Receiver( to_ ).onERC721Received( _msgSender(), from_, tokenId_, data_ ) returns ( bytes4 retval ) {
					return retval == IERC721Receiver.onERC721Received.selector;
				}
				catch ( bytes memory reason ) {
					if ( reason.length == 0 ) {
						revert IERC721_NON_ERC721_RECEIVER();
					}
					else {
						assembly {
							revert( add( 32, reason ), mload( reason ) )
						}
					}
				}
			}
			else {
				return true;
			}
		}

		function _exists( uint256 tokenId_ ) internal view virtual returns ( bool ) {
			return tokenId_ < _numTokens;
		}

		function _initERC721BatchMetadata( string memory name_, string memory symbol_ ) internal {
			_name   = name_;
			_symbol = symbol_;
		}

		function _isApprovedForAll( address tokenOwner_, address operator_ ) internal view virtual returns ( bool ) {
			return _operatorApprovals[ tokenOwner_ ][ operator_ ];
		}

		function _isApprovedOrOwner( address tokenOwner_, address operator_, uint256 tokenId_ ) internal view virtual returns ( bool ) {
			bool _isApproved_ = operator_ == tokenOwner_ ||
													operator_ == _tokenApprovals[ tokenId_ ] ||
													_isApprovedForAll( tokenOwner_, operator_ );
			return _isApproved_;
		}

		function _mint( address to_, uint256 qty_ ) internal virtual {
			uint256 _firstToken_ = _numTokens;
			uint256 _lastToken_ = _firstToken_ + qty_ - 1;

			_owners[ _firstToken_ ] = to_;
			if ( _lastToken_ > _firstToken_ ) {
				_owners[ _lastToken_ ] = to_;
			}
			for ( uint256 i; i < qty_; i ++ ) {
				emit Transfer( address( 0 ), to_, _firstToken_ + i );
			}
			_numTokens = _lastToken_ + 1;
		}

		function _ownerOf( uint256 tokenId_ ) internal view virtual returns ( address ) {
			uint256 _tokenId_ = tokenId_;
			address _tokenOwner_ = _owners[ _tokenId_ ];
			while ( _tokenOwner_ == address( 0 ) ) {
				_tokenId_ --;
				_tokenOwner_ = _owners[ _tokenId_ ];
			}

			return _tokenOwner_;
		}

		function _setBaseURI( string memory baseURI_ ) internal virtual {
			_baseURI = baseURI_;
		}

		function _supplyMinted() internal view virtual returns ( uint256 ) {
			return _numTokens;
		}

		function _toString( uint256 value ) internal pure returns ( string memory ) {
			if ( value == 0 ) {
				return "0";
			}
			uint256 temp = value;
			uint256 digits;
			while ( temp != 0 ) {
				digits ++;
				temp /= 10;
			}
			bytes memory buffer = new bytes( digits );
			while ( value != 0 ) {
				digits -= 1;
				buffer[ digits ] = bytes1( uint8( 48 + uint256( value % 10 ) ) );
				value /= 10;
			}
			return string( buffer );
		}

		function _transfer( address from_, address to_, uint256 tokenId_ ) internal virtual {
			_tokenApprovals[ tokenId_ ] = address( 0 );
			uint256 _previousId_ = tokenId_ > 0 ? tokenId_ - 1 : 0;
			uint256 _nextId_     = tokenId_ + 1;
			bool _previousShouldUpdate_ = _previousId_ < tokenId_ &&
																		_exists( _previousId_ ) &&
																		_owners[ _previousId_ ] == address( 0 );
			bool _nextShouldUpdate_ = _exists( _nextId_ ) &&
																_owners[ _nextId_ ] == address( 0 );

			if ( _previousShouldUpdate_ ) {
				_owners[ _previousId_ ] = from_;
			}

			if ( _nextShouldUpdate_ ) {
				_owners[ _nextId_ ] = from_;
			}

			_owners[ tokenId_ ] = to_;

			emit Transfer( from_, to_, tokenId_ );
		}

		function approve( address to_, uint256 tokenId_ ) external virtual exists( tokenId_ ) {
			address _operator_ = _msgSender();
			address _tokenOwner_ = _ownerOf( tokenId_ );
			bool _isApproved_ = _isApprovedOrOwner( _tokenOwner_, _operator_, tokenId_ );

			if ( ! _isApproved_ ) {
				revert IERC721_CALLER_NOT_APPROVED();
			}

			if ( to_ == _tokenOwner_ ) {
				revert IERC721_APPROVE_OWNER();
			}

			_tokenApprovals[ tokenId_ ] = to_;
			emit Approval( _tokenOwner_, to_, tokenId_ );
		}

		function safeTransferFrom( address, address to_, uint256 tokenId_ ) external virtual exists( tokenId_ ) {
			address _operator_ = _msgSender();
			address _tokenOwner_ = _ownerOf( tokenId_ );
			bool _isApproved_ = _isApprovedOrOwner( _tokenOwner_, _operator_, tokenId_ );

			if ( ! _isApproved_ ) {
				revert IERC721_CALLER_NOT_APPROVED();
			}

			if ( to_ == address( 0 ) ) {
				revert IERC721_NULL_ADDRESS_TRANSFER();
			}

			_transfer( _tokenOwner_, to_, tokenId_ );

			if ( ! _checkOnERC721Received( _tokenOwner_, to_, tokenId_, "" ) ) {
				revert IERC721_NON_ERC721_RECEIVER();
			}
		}

		function safeTransferFrom( address, address to_, uint256 tokenId_, bytes calldata data_ ) external virtual exists( tokenId_ ) {
			address _operator_ = _msgSender();
			address _tokenOwner_ = _ownerOf( tokenId_ );
			bool _isApproved_ = _isApprovedOrOwner( _tokenOwner_, _operator_, tokenId_ );

			if ( ! _isApproved_ ) {
				revert IERC721_CALLER_NOT_APPROVED();
			}

			if ( to_ == address( 0 ) ) {
				revert IERC721_NULL_ADDRESS_TRANSFER();
			}

			_transfer( _tokenOwner_, to_, tokenId_ );

			if ( ! _checkOnERC721Received( _tokenOwner_, to_, tokenId_, data_ ) ) {
				revert IERC721_NON_ERC721_RECEIVER();
			}
		}

		function setApprovalForAll( address operator_, bool approved_ ) public virtual override {
			address _account_ = _msgSender();
			if ( operator_ == _account_ ) {
				revert IERC721_APPROVE_CALLER();
			}

			_operatorApprovals[ _account_ ][ operator_ ] = approved_;
			emit ApprovalForAll( _account_, operator_, approved_ );
		}

		function transferFrom( address, address to_, uint256 tokenId_ ) external virtual exists( tokenId_ ) {
			address _operator_ = _msgSender();
			address _tokenOwner_ = _ownerOf( tokenId_ );
			bool _isApproved_ = _isApprovedOrOwner( _tokenOwner_, _operator_, tokenId_ );

			if ( ! _isApproved_ ) {
				revert IERC721_CALLER_NOT_APPROVED();
			}

			if ( to_ == address( 0 ) ) {
				revert IERC721_NULL_ADDRESS_TRANSFER();
			}

			_transfer( _tokenOwner_, to_, tokenId_ );
		}

		function balanceOf( address tokenOwner_ ) external view virtual returns ( uint256 ) {
			return _balanceOf( tokenOwner_ );
		}

		function getApproved( uint256 tokenId_ ) external view virtual exists( tokenId_ ) returns ( address ) {
			return _tokenApprovals[ tokenId_ ];
		}

		function isApprovedForAll( address tokenOwner_, address operator_ ) external view virtual returns ( bool ) {
			return _isApprovedForAll( tokenOwner_, operator_ );
		}

		function name() public view virtual override returns ( string memory ) {
			return _name;
		}

		function ownerOf( uint256 tokenId_ ) external view virtual exists( tokenId_ ) returns ( address ) {
			return _ownerOf( tokenId_ );
		}

		function supportsInterface( bytes4 interfaceId_ ) public view virtual override returns ( bool ) {
			return 
				interfaceId_ == type( IERC721Metadata ).interfaceId ||
				interfaceId_ == type( IERC721 ).interfaceId ||
				interfaceId_ == type( IERC165 ).interfaceId;
		}

		function symbol() public view virtual override returns ( string memory ) {
			return _symbol;
		}

		function tokenURI( uint256 tokenId_ ) public view virtual override exists( tokenId_ ) returns ( string memory ) {
			return bytes( _baseURI ).length > 0 ? string( abi.encodePacked( _baseURI, _toString( tokenId_ ) ) ) : _toString( tokenId_ );
		}
}





pragma solidity 0.8.10;



abstract contract ERC721BatchStakable is ERC721Batch, IERC721Receiver {
	mapping( uint256 => address ) internal _stakedOwners;

		function _balanceOfStaked( address tokenOwner_ ) internal view virtual returns ( uint256 ) {
			if ( tokenOwner_ == address( 0 ) ) {
				return 0;
			}

			uint256 _supplyMinted_ = _supplyMinted();
			uint256 _count_ = 0;
			for ( uint256 i; i < _supplyMinted_; i++ ) {
				if ( _stakedOwners[ i ] == tokenOwner_ ) {
					_count_++;
				}
			}
			return _count_;
		}

		function _mintAndStake( address tokenOwner_, uint256 qtyMinted_, uint256 qtyStaked_ ) internal {
			uint256 _qtyNotStaked_;
			uint256 _qtyStaked_ = qtyStaked_;
			if ( qtyStaked_ > qtyMinted_ ) {
				_qtyStaked_ = qtyMinted_;
			}
			else if ( qtyStaked_ < qtyMinted_ ) {
				_qtyNotStaked_ = qtyMinted_ - qtyStaked_;
			}
			if ( _qtyStaked_ > 0 ) {
				_mintInContract( tokenOwner_, _qtyStaked_ );
			}
			if ( _qtyNotStaked_ > 0 ) {
				_mint( tokenOwner_, _qtyNotStaked_ );
			}
		}

		function _mintInContract( address tokenOwner_, uint256 qtyStaked_ ) internal {
			uint256 _currentToken_ = _supplyMinted();
			uint256 _lastToken_ = _currentToken_ + qtyStaked_ - 1;

			while ( _currentToken_ <= _lastToken_ ) {
				_stakedOwners[ _currentToken_ ] = tokenOwner_;
				_currentToken_ ++;
			}

			_mint( address( this ), qtyStaked_ );
		}

		function _ownerOfStaked( uint256 tokenId_ ) internal view virtual returns ( address ) {
			return _stakedOwners[ tokenId_ ];
		}

		function _stake( address tokenOwner_, uint256 tokenId_ ) internal {
			_stakedOwners[ tokenId_ ] = tokenOwner_;
			_transfer( tokenOwner_, address( this ), tokenId_ );
		}

		function _unstake( address tokenOwner_, uint256 tokenId_ ) internal {
			_transfer( address( this ), tokenOwner_, tokenId_ );
			delete _stakedOwners[ tokenId_ ];
		}

		function stake( uint256 tokenId_ ) external exists( tokenId_ ) {
			address _operator_ = _msgSender();
			address _tokenOwner_ = _ownerOf( tokenId_ );
			bool _isApproved_ = _isApprovedOrOwner( _tokenOwner_, _operator_, tokenId_ );

			if ( ! _isApproved_ ) {
				revert IERC721_CALLER_NOT_APPROVED();
			}
			_stake( _tokenOwner_, tokenId_ );
		}

		function unstake( uint256 tokenId_ ) external exists( tokenId_ ) {
			address _operator_ = _msgSender();
			address _tokenOwner_ = _ownerOfStaked( tokenId_ );
			bool _isApproved_ = _isApprovedOrOwner( _tokenOwner_, _operator_, tokenId_ );

			if ( ! _isApproved_ ) {
				revert IERC721_CALLER_NOT_APPROVED();
			}
			_unstake( _tokenOwner_, tokenId_ );
		}

		function balanceOf( address tokenOwner_ ) public view virtual override returns ( uint256 balance ) {
			return _balanceOfStaked( tokenOwner_ ) + _balanceOf( tokenOwner_ );
		}

		function balanceOfStaked( address tokenOwner_ ) public view virtual returns ( uint256 ) {
			return _balanceOfStaked( tokenOwner_ );
		}

		function ownerOf( uint256 tokenId_ ) public view virtual override exists( tokenId_ ) returns ( address ) {
			address _tokenOwner_ = _ownerOf( tokenId_ );
			if ( _tokenOwner_ == address( this ) ) {
				return _ownerOfStaked( tokenId_ );
			}
			return _tokenOwner_;
		}

		function ownerOfStaked( uint256 tokenId_ ) public view virtual exists( tokenId_ ) returns ( address ) {
			return _ownerOfStaked( tokenId_ );
		}

		function onERC721Received( address, address, uint256, bytes memory ) public override pure returns ( bytes4 ) {
			return type( IERC721Receiver ).interfaceId;
		}
}




pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}





pragma solidity 0.8.10;



abstract contract ERC721BatchEnumerable is ERC721Batch, IERC721Enumerable {
	error IERC721Enumerable_OWNER_INDEX_OUT_OF_BOUNDS();
	error IERC721Enumerable_INDEX_OUT_OF_BOUNDS();

	function supportsInterface( bytes4 interfaceId_ ) public view virtual override(IERC165, ERC721Batch) returns ( bool ) {
		return 
			interfaceId_ == type( IERC721Enumerable ).interfaceId ||
			super.supportsInterface( interfaceId_ );
	}

	function tokenByIndex( uint256 index_ ) public view virtual override returns ( uint256 ) {
		if ( index_ >= _supplyMinted() ) {
			revert IERC721Enumerable_INDEX_OUT_OF_BOUNDS();
		}
		return index_;
	}

	function tokenOfOwnerByIndex( address tokenOwner_, uint256 index_ ) public view virtual override returns ( uint256 tokenId ) {
		uint256 _supplyMinted_ = _supplyMinted();
		if ( index_ >= _balanceOf( tokenOwner_ ) ) {
			revert IERC721Enumerable_OWNER_INDEX_OUT_OF_BOUNDS();
		}

		uint256 _count_ = 0;
		for ( uint256 i = 0; i < _supplyMinted_; i++ ) {
			if ( _exists( i ) && tokenOwner_ == _ownerOf( i ) ) {
				if ( index_ == _count_ ) {
					return i;
				}
				_count_++;
			}
		}
	}

	function totalSupply() public view virtual override returns ( uint256 ) {
		uint256 _supplyMinted_ = _supplyMinted();
		uint256 _count_ = 0;
		for ( uint256 i; i < _supplyMinted_; i++ ) {
			if ( _exists( i ) ) {
				_count_++;
			}
		}
		return _count_;
	}
}





pragma solidity 0.8.10;



contract CCFoundersKeys is ERC721BatchEnumerable, ERC721BatchStakable, ERC2981Base, IOwnable, IPausable, ITradable, IWhitelistable {

	event PaymentReleased( address indexed from, address[] indexed tos, uint256[] indexed amounts );

	error CCFoundersKeys_ARRAY_LENGTH_MISMATCH();
	error CCFoundersKeys_FORBIDDEN();
	error CCFoundersKeys_INCORRECT_PRICE();
	error CCFoundersKeys_INSUFFICIENT_KEY_BALANCE();
	error CCFoundersKeys_MAX_BATCH();
	error CCFoundersKeys_MAX_RESERVE();
	error CCFoundersKeys_MAX_SUPPLY();
	error CCFoundersKeys_NO_ETHER_BALANCE();
	error CCFoundersKeys_TRANSFER_FAIL();

	uint public immutable WL_MINT_PRICE; // = 0.069 ether;

	uint public immutable PUBLIC_MINT_PRICE; // = 0.1 ether;

	uint public immutable MAX_SUPPLY;

	uint public immutable MAX_BATCH;

	address private immutable _CC_SAFE;

	address private immutable _CC_CHARITY;

	address private immutable _CC_FOUNDERS;

	address private immutable _CC_COMMUNITY;

	mapping( address => uint256 ) public anonClaimList;

	uint256 private _reserve;

	constructor(
		uint256 reserve_,
		uint256 maxBatch_,
		uint256 maxSupply_,
		uint256 royaltyRate_,
		uint256 wlMintPrice_,
		uint256 publicMintPrice_,
		string memory name_,
		string memory symbol_,
		string memory baseURI_,
		address[] memory wallets_
	) {
		address _contractOwner_ = _msgSender();
		_initIOwnable( _contractOwner_ );
		_initERC2981Base( _contractOwner_, royaltyRate_ );
		_initERC721BatchMetadata( name_, symbol_ );
		_setBaseURI( baseURI_ );
		_CC_SAFE          = wallets_[ 0 ];
		_CC_CHARITY       = wallets_[ 1 ];
		_CC_FOUNDERS      = wallets_[ 2 ];
		_CC_COMMUNITY     = wallets_[ 3 ];
		_reserve          = reserve_;
		MAX_BATCH         = maxBatch_;
		MAX_SUPPLY        = maxSupply_;
		WL_MINT_PRICE     = wlMintPrice_;
		PUBLIC_MINT_PRICE = publicMintPrice_;
	}

		function _isApprovedForAll( address tokenOwner_, address operator_ ) internal view virtual override returns ( bool ) {

			return _isRegisteredProxy( tokenOwner_, operator_ ) ||
						 super._isApprovedForAll( tokenOwner_, operator_ );
		}

		function _sendValue( address payable recipient_, uint256 amount_ ) internal {

			if ( address( this ).balance < amount_ ) {
				revert CCFoundersKeys_INCORRECT_PRICE();
			}
			( bool _success_, ) = recipient_.call{ value: amount_ }( "" );
			if ( ! _success_ ) {
				revert CCFoundersKeys_TRANSFER_FAIL();
			}
		}

		function claim( uint256 qty_ ) external presaleOpen {

			address _account_   = _msgSender();
			if ( qty_ > anonClaimList[ _account_ ] ) {
				revert CCFoundersKeys_FORBIDDEN();
			}

			uint256 _endSupply_ = _supplyMinted() + qty_;
			if ( _endSupply_ > MAX_SUPPLY - _reserve ) {
				revert CCFoundersKeys_MAX_SUPPLY();
			}

			unchecked {
				anonClaimList[ _account_ ] -= qty_;
			}
			_mint( _account_, qty_ );
		}

		function claimAndStake( uint256 qty_, uint256 qtyStaked_ ) external presaleOpen {

			address _account_   = _msgSender();
			if ( qty_ > anonClaimList[ _account_ ] ) {
				revert CCFoundersKeys_FORBIDDEN();
			}

			uint256 _endSupply_ = _supplyMinted() + qty_;
			if ( _endSupply_ > MAX_SUPPLY - _reserve ) {
				revert CCFoundersKeys_MAX_SUPPLY();
			}

			unchecked {
				anonClaimList[ _account_ ] -= qty_;
			}
			_mintAndStake( _account_, qty_, qtyStaked_ );
		}

		function mintPreSale( bytes32[] memory proof_ ) external payable presaleOpen isWhitelisted( _msgSender(), proof_, 1, 1 ) {

			if ( _supplyMinted() + 1 > MAX_SUPPLY - _reserve ) {
				revert CCFoundersKeys_MAX_SUPPLY();
			}

			if ( WL_MINT_PRICE != msg.value ) {
				revert CCFoundersKeys_INCORRECT_PRICE();
			}

			address _account_    = _msgSender();
			_consumeWhitelist( _account_, 1 );
			_mint( _account_, 1 );
		}

		function mintPreSaleAndStake( bytes32[] memory proof_ ) external payable presaleOpen isWhitelisted( _msgSender(), proof_, 1, 1 ) {

			if ( _supplyMinted() + 1 > MAX_SUPPLY - _reserve ) {
				revert CCFoundersKeys_MAX_SUPPLY();
			}

			if ( WL_MINT_PRICE != msg.value ) {
				revert CCFoundersKeys_INCORRECT_PRICE();
			}

			address _account_    = _msgSender();
			_consumeWhitelist( _account_, 1 );
			_mintAndStake( _account_, 1, 1 );
		}

		function mint( uint256 qty_ ) external payable saleOpen {

			if ( qty_ > MAX_BATCH ) {
				revert CCFoundersKeys_MAX_BATCH();
			}

			uint256 _endSupply_  = _supplyMinted() + qty_;
			if ( _endSupply_ > MAX_SUPPLY - _reserve ) {
				revert CCFoundersKeys_MAX_SUPPLY();
			}

			if ( qty_ * PUBLIC_MINT_PRICE != msg.value ) {
				revert CCFoundersKeys_INCORRECT_PRICE();
			}
			address _account_    = _msgSender();
			_mint( _account_, qty_ );
		}

		function mintAndStake( uint256 qty_, uint256 qtyStaked_ ) external payable saleOpen {

			if ( qty_ > MAX_BATCH ) {
				revert CCFoundersKeys_MAX_BATCH();
			}

			uint256 _endSupply_  = _supplyMinted() + qty_;
			if ( _endSupply_ > MAX_SUPPLY - _reserve ) {
				revert CCFoundersKeys_MAX_SUPPLY();
			}

			if ( qty_ * PUBLIC_MINT_PRICE != msg.value ) {
				revert CCFoundersKeys_INCORRECT_PRICE();
			}
			address _account_    = _msgSender();
			_mintAndStake( _account_, qty_, qtyStaked_ );
		}

		function airdrop( address[] memory accounts_, uint256[] memory amounts_ ) external onlyOwner {

			uint256 _len_ = amounts_.length;
			if ( _len_ != accounts_.length ) {
				revert CCFoundersKeys_ARRAY_LENGTH_MISMATCH();
			}
			uint _totalQty_;
			for ( uint256 i = _len_; i > 0; i -- ) {
				_totalQty_ += amounts_[ i - 1 ];
			}
			if ( _totalQty_ > _reserve ) {
				revert CCFoundersKeys_MAX_RESERVE();
			}
			unchecked {
				_reserve -= _totalQty_;
			}
			for ( uint256 i = _len_; i > 0; i -- ) {
				_mint( accounts_[ i - 1], amounts_[ i - 1] );
			}
		}

		function setAnonClaimList( address[] memory accounts_, uint256[] memory amounts_ ) external onlyOwner saleClosed {

			uint256 _len_ = amounts_.length;
			if ( _len_ != accounts_.length ) {
				revert CCFoundersKeys_ARRAY_LENGTH_MISMATCH();
			}
			for ( uint256 i; i < _len_; i ++ ) {
				anonClaimList[ accounts_[ i ] ] = amounts_[ i ];
			}
		}

		function setProxyRegistry( address proxyRegistryAddress_ ) external onlyOwner {

			_setProxyRegistry( proxyRegistryAddress_ );
		}

		function setRoyaltyInfo( address royaltyRecipient_, uint256 royaltyRate_ ) external onlyOwner {

			_setRoyaltyInfo( royaltyRecipient_, royaltyRate_ );
		}

		function setSaleState( SaleState newState_ ) external onlyOwner {

			_setSaleState( newState_ );
		}

		function setWhitelist( bytes32 root_ ) external onlyOwner saleClosed {

			_setWhitelist( root_ );
		}

		function withdraw() external onlyOwner {

			uint256 _balance_ = address(this).balance;
			if ( _balance_ == 0 ) {
				revert CCFoundersKeys_NO_ETHER_BALANCE();
			}

			uint256 _safeShare_ = _balance_ * 900 / 1000;
			uint256 _charityShare_ = _balance_ * 50 / 1000;
			uint256 _othersShare_ = _charityShare_ / 2;
			_sendValue( payable( _CC_COMMUNITY ), _othersShare_ );
			_sendValue( payable( _CC_FOUNDERS ), _othersShare_ );
			_sendValue( payable( _CC_CHARITY ), _charityShare_ );
			_sendValue( payable( _CC_SAFE ), _safeShare_ );

			address[] memory _tos_ = new address[]( 4 );
			_tos_[ 0 ] = _CC_COMMUNITY;
			_tos_[ 1 ] = _CC_FOUNDERS;
			_tos_[ 2 ] = _CC_CHARITY;
			_tos_[ 3 ] = _CC_SAFE;
			uint256[] memory _amounts_ = new uint256[]( 4 );
			_amounts_[ 0 ] = _othersShare_;
			_amounts_[ 1 ] = _othersShare_;
			_amounts_[ 2 ] = _charityShare_;
			_amounts_[ 3 ] = _safeShare_;
			emit PaymentReleased( address( this ), _tos_, _amounts_ );
		}

		function balanceOf( address tokenOwner_ ) public view virtual override(ERC721Batch, ERC721BatchStakable) returns ( uint256 balance ) {

			return ERC721BatchStakable.balanceOf( tokenOwner_ );
		}

		function ownerOf( uint256 tokenId_ ) public view virtual override(ERC721Batch, ERC721BatchStakable) exists( tokenId_ ) returns ( address ) {

			return ERC721BatchStakable.ownerOf( tokenId_ );
		}

		function royaltyInfo( uint256 tokenId_, uint256 salePrice_ ) public view virtual override exists( tokenId_ ) returns ( address, uint256 ) {

			return super.royaltyInfo( tokenId_, salePrice_ );
		}

		function supportsInterface( bytes4 interfaceId_ ) public view virtual override(ERC721BatchEnumerable, ERC721Batch, ERC2981Base) returns ( bool ) {

			return 
				interfaceId_ == type( IERC2981 ).interfaceId ||
				ERC721Batch.supportsInterface( interfaceId_ ) ||
				ERC721BatchEnumerable.supportsInterface( interfaceId_ );
		}
}