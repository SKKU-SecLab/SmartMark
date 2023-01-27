
pragma solidity ^0.8.0;

interface INinfaERC721 {

    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function mint(bytes32 _tokenURI, address _to) external;


    function totalSupply() external view returns (uint256);


    function ownerOf(uint256 tokenId) external view returns (address owner);

}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
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
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library CountersUpgradeable {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT

pragma solidity 0.8.13;



contract NinfaMarketplace is
    Initializable,
    AccessControlUpgradeable // {AccessControl} doesn’t allow enumerating role members, whereas {AccessControlEnumerable} allows it. The additional "enumerable" functions are getRoleMember(role, index) and getRoleMemberCount(role). The role member can be enumerated by frontend using events, therefore the enumerable extension is not needed to be read on-chain.

{
    INinfaERC721 public NinfaERC721;

    using CountersUpgradeable for CountersUpgradeable.Counter; // counters for marketplace offers and orders

    CountersUpgradeable.Counter private _orderCount; // orders counter
    CountersUpgradeable.Counter private _offerCount; // offers counter

    bytes32 private constant CURATOR_ROLE = 0x850d585eb7f024ccee5e68e55f2c26cc72e1e6ee456acf62135757a5eb9d4a10; // hardcoded hash equivalent to keccak256("CURATOR_ROLE"); CURATOR_ROLE is the "role admin" of ARTIST_ROLE, i.e. it is the only account that can grant and revoke roles to artists. This was added to avoid having a DEFAULT_ADMIN_ROLE approve artists, which would introduce security risks if different from a multisig, and usability issues if each time a multisig was needed to approve artists.
    bytes32 private constant ARTIST_ROLE = 0x877a78dc988c0ec5f58453b44888a55eb39755c3d5ed8d8ea990912aa3ef29c6; // hardcoded hash equivalent to keccak256("ARTIST_ROLE"); Since there isn't a getter function, it can be copied from the source code. The ARTIST_ROLE allows an address to mint tokens
    uint24 private ninfaPrimaryFee; // Ninfa Marketplace fee percentage for primary sales, expressed in basis points. It is not constant because primary sale fees are at 0% for 2022 and will need to be set afterwards to 10%.
    uint24 private constant NINFA_SECONDARY_FEE = 500; // 5% fee on all secondary sales paid to Ninfa (seller receives the remainder after paying 10% royalties to artist/gallery and 5% Ninfa, i.e. 85%)
    bytes4 private constant INTERFACE_ID_ERC2981 = 0x2a55205a; // https://eips.ethereum.org/EIPS/eip-2981
    address payable private feeAccount; // EOA or contract where to send trading fees generated by the marketplace
    mapping(address => mapping(uint256 => _Commission)) private _royaltiesCommission; // commission % amount out of any royalties received by an artist who choses to split with someone, normally a gallery. collection => tokenId => _Commission.
    mapping(uint256 => _Commission) private _primarySalesCommission; // The % amount on all primary sales income that an artist received from sales on the marketplacce, destined to a gallery chosen by the artist.
    mapping(address => mapping(uint256 => uint256)) private _tokenToOrderId; // mapping to find orderId given an ERC721 address and a tokenId.
    mapping(address => bool) private ERC721Whitelist; // in order to be traded on the Ninfa marketplace, collections need to be manually approved by a multisig contract.
    mapping(uint256 => bool) private secondarySale; // map token Id to bool indicating wether it has been sold before, only applies to the Ninfa collection NFTs, all other collections are considered as secondary sales.
    mapping(uint256 => _Invoice) private orders; // mapping order id to invoice struct
    mapping(uint256 => _Invoice) private offers; // mapping offer id to invoice struct

    struct _Invoice {
        address collection;
        uint256 tokenId;
        address from; // if invoice represents an order, `from` will correspond to the seller, if it represents an offer, `from` will correspond to the buyer
        uint256 price; // seller ask or buyer bid
    }

    struct _Commission {
        address receiver; // receiver of royalty fees commission
        uint24 feeBps; // royalties's commission receiver fees, expressed in basis points 0 - 10000
    }

	event Order(            address indexed collection, uint256 indexed tokenId, address indexed from, uint256 orderId, uint256 price);
    event Offer(            address indexed collection, uint256 indexed tokenId, address indexed from, uint256 offerId, uint256 price);
	event OrderCancelled(   address indexed collection, uint256 indexed tokenId, address indexed from, uint256 orderId);
    event OfferCancelled(   address indexed collection, uint256 indexed tokenId, address indexed from, uint256 offerId);
    event Trade(            address indexed collection, uint256 indexed tokenId, address indexed from, uint256 price, address to, uint256 orderId);
    event RoyaltyPayment(   address indexed collection, uint256 indexed tokenId, address indexed to, uint256 amount); // currency is eth for now, in the future it will include a parameter for currency as well. This event is also emitted when paying commissions on royalties.
    event Commission(       address indexed collection, uint256 indexed tokenId, address indexed to, uint24 primaryBps, uint24 royaltyBps); // using Commission event as cheap storage for commission info. In order to tell whether this event was emitted by `setRoyaltyCommission()` or by `setPrimarySaleCommission()` is given away by whichever "bps" parameter is not 0. E.g. if `primaryBps` has a value (1-10000) that means the commission was set on primary sales, therefore `royaltyBps` must be 0, and viceversa, they can also be both true.
    event FeeAccount(       address feeAccount); // emitted for transparency whenever the marketplace's fees receiver account changes

    modifier orderValid(uint256 _id) {

        require(_id > 0 && _id <= _orderCount.current(), "Order Id does not exist"); // check the order exists in order to avoid unhandled "index out of bound" errors
        _;
    }

    modifier offerValid(uint256 _id) {
        require(_id > 0 && _id <= _offerCount.current(), "Offer Id does not exist"); // not strictly necessary, but prevents reverts like when accepting an inexistent offer would return "ERC721: transfer to the zero address" because the "from" is 0x0.
        _;
    }


    function mint(bytes32 _tokenURI) external onlyRole(ARTIST_ROLE) {
        NinfaERC721.mint(_tokenURI, msg.sender);
    }

    function mintAndTransfer(
        bytes32 _tokenURI,
        address _to,
        uint24 _primaryBps,
        uint24 _royaltyBps
        ) onlyRole(ARTIST_ROLE) external {

        require(_primaryBps <= 8500 && _royaltyBps <= 9000);
        uint256 _tokenId = NinfaERC721.totalSupply();

        NinfaERC721.mint(_tokenURI, msg.sender);

        NinfaERC721.transferFrom(msg.sender, _to, _tokenId);

        if (_primaryBps > 0 || _royaltyBps > 0) {

            if (_primaryBps > 0) {
                _primarySalesCommission[_tokenId] = _Commission(_to, _primaryBps);
            }

            if (_royaltyBps > 0) {
                _royaltiesCommission[address(NinfaERC721)][_tokenId] = _Commission(_to, _royaltyBps);
            }

            emit Commission(address(NinfaERC721), _tokenId, _to, _primaryBps, _royaltyBps);
        }

    }


    function submitOrder(address _collection, uint256 _tokenId, uint256 _price) external {
        require( _price > 0); // protecting the user from mistakenly submitting an order for free
        require( _collection == address(NinfaERC721) || ERC721Whitelist[_collection] == true); // ERC721 must be whitelisted. Comparing the collection to address(ninfa) first is cheaper than whitelisting the ninfa erc721 and then checking the whitelist, however if the collection is not ninfa then it might be slightly more expensive than if we just checked the whitelist
        require( INinfaERC721(_collection).ownerOf(_tokenId) == msg.sender); // it may seem safe to remove this require statement, since after transferFrom another require statement already checks that ownerOf tokenId is the marketplace, however imagine the ERC721 does not revert if sender isn't owner; somebody could create orders for NFTs already on sale (owned by marketplace)!

        INinfaERC721(_collection).transferFrom(msg.sender, address(this), _tokenId); // transfer NFT directly to this contract, reverts on failure. Only NFT owner can transfer the token, i.e. call this function.
        require( INinfaERC721(_collection).ownerOf(_tokenId) == address(this)); // According to the EIP, the transfer and transferFrom function will revert if the msg.sender is not the owner of the NFT. Consider what would happen if a non-standard implementation does not revert.

		_orderCount.increment(); // start _orderCount at 1
        orders[_orderCount.current()] = _Invoice(_collection, _tokenId, msg.sender, _price); // add order to orders mapping

        _tokenToOrderId[_collection][_tokenId] = _orderCount.current(); /// @dev map token Id to order Id. There is no need to reset back to zero when cancelling the order, as the frontend would determine whether the token is for sale first by checking if owned by the Marketplace, if it is then the order Id is valid.

		emit Order(_collection, _tokenId, msg.sender, _orderCount.current(), _price);
	}

    function submitOffer(address _collection, uint256 _tokenId) external payable {
        require(msg.value > 0);
        require(INinfaERC721(_collection).ownerOf(_tokenId) != address(0x0)); // the nft id must exist already
        require( _collection == address(NinfaERC721) || ERC721Whitelist[_collection] == true);
        
        _offerCount.increment(); // start count at 1
        
        offers[_offerCount.current()] = _Invoice(_collection, _tokenId, msg.sender, msg.value); // add offer Struct to offers mapping

		emit Offer(_collection, _tokenId, msg.sender, _offerCount.current(), msg.value);
    }

    function cancelOrder(uint256 _orderId) orderValid(_orderId) external {

		require(orders[_orderId].from == msg.sender);
        
        NinfaERC721.transferFrom(address(this), msg.sender, orders[_orderId].tokenId); // transfer NFT back to the owner

        delete _tokenToOrderId[ orders[_orderId].collection ][ orders[_orderId].tokenId ];

        emit OrderCancelled(orders[_orderId].collection, orders[_orderId].tokenId, msg.sender, _orderId);

        delete orders[_orderId]; // mark order as cancelled forever after event is emitted or else all values emitted will be 0
    }

    function refundOffer(uint256 _offerId) offerValid(_offerId) external {

        _Invoice memory _offer = offers[_offerId]; // in memory copy needed so that it is possible to delete the struct inside the storage offers mapping, while keeping check effects interact pattern intact

		require(_offer.from == msg.sender); // this implicitly also checks that the offer exists, since msg.sender cannot be == 0x0

        delete offers[_offerId]; // mark offer as cancelled forever, updating offer price before external call, Checks Effects Interactions pattern
        (bool success, ) = payable(_offer.from).call{value: _offer.price}(""); // transfer the offer amount back to bidder
        require(success);

        emit OfferCancelled(_offer.collection, _offer.tokenId, msg.sender, _offerId);
    }

    function changeOrderPrice(uint256 _orderId, uint256 _newPrice) orderValid(_orderId) external {
        require(_newPrice > 0); // protecting the user from mistakenly submitting an order for free. We could also require that it is not the same as the previous price, but it is  probably spending gas for nothing as the chance is very low and doesn't res

        _Invoice storage _order = orders[_orderId];
		require(_order.from == msg.sender);

        _order.price = _newPrice;

        emit Order(_order.collection, _order.tokenId, msg.sender, _orderId, _order.price);
    }

    function increaseOffer(uint256 _offerId) offerValid(_offerId) external payable {

        _Invoice storage _offer = offers[_offerId];
        require(_offer.from == msg.sender);
        require(msg.value > 0);

        _offer.price = _offer.price + msg.value; // transfer extra amount needed on top of older offer

        emit Offer(_offer.collection, _offer.tokenId, msg.sender, _offerId, _offer.price);
    }

    function decreaseOffer(uint256 _offerId, uint256 _newAmount) offerValid(_offerId) external {
        
        _Invoice storage _offer = offers[_offerId];
        require(_offer.from == msg.sender);
        require(_newAmount > 0 && _newAmount < _offer.price);

        uint256 _refund = _offer.price - _newAmount; // needed to store result before offer price is updated
        _offer.price = _newAmount; // updating offer price before external call, Checks Effects Interactions pattern

        (bool success, ) = payable(msg.sender).call{value: _refund}(""); // transfer the difference between old and new lower offer to the user
        require(success);

        emit Offer(_offer.collection, _offer.tokenId, msg.sender, _offerId, _offer.price);
    }

    function fillOrder (uint256 _orderId) orderValid(_orderId) external payable {

        require(orders[_orderId].price > 0); // checking that the order wasn't deleted or filled

        require(msg.value >= orders[_orderId].price);

		_trade(_orderId, msg.sender, orders[_orderId].from, orders[_orderId].price, orders[_orderId].tokenId, orders[_orderId].collection);
	}

    function acceptOffer(uint256 _offerId) offerValid(_offerId) external {
        
        _Invoice memory _offer = offers[_offerId]; // creating an additional variable in this particular case is cheaper than calling `offers[_offerId].something` each time. See https://ethereum.org/en/developers/tutorials/downsizing-contracts-to-fight-the-contract-size-limit/#avoid-additional-variables
        require(_offer.price > 0); // checks that the offer exists, since offer price cannot be 0
        
        uint256 _orderId = _tokenToOrderId[_offer.collection][_offer.tokenId]; // If there is no order, the Id will be set to 0, else the order will be marked as filled by the _trade() function, orderFilled[_orderId] = true;

        if(_orderId != 0) {

            require(orders[_orderId].from == msg.sender); // if _orderId is different from 0, then automatically the order exists because otherwise the mapping would be deleted, i.e. no need to check the order is valid
        } else {
            require(INinfaERC721(_offer.collection).ownerOf(_offer.tokenId) == msg.sender);
        }
        
        delete offers[_offerId]; // mark offer as cancelled forever, so that user's can't claim a refund after their offer gets accepted
		
        _trade(_orderId, _offer.from, msg.sender, _offer.price , _offer.tokenId, _offer.collection); // we are passing offer amount instead of order price as function parameter
    }

    function _trade(uint256 _orderId, address _buyer, address _seller, uint256 _price, uint256 _tokenId, address _collection) private {

        uint256 marketplaceFeeAmount = _price * NINFA_SECONDARY_FEE / 10000;
        uint256 sellerAmount;
        bool success;

        if (_orderId != 0) {
            NinfaERC721.transferFrom(address(this), _buyer, _tokenId); // transfer NFT from Marketplace to buyer
            delete orders[_orderId]; // mark the order as filled
            delete _tokenToOrderId[_collection][_tokenId]; // delete old mapping
        } else {
            NinfaERC721.transferFrom(_seller, _buyer, _tokenId); // transfer NFT from seller to buyer
        }

        if ( IERC165(_collection).supportsInterface(INTERFACE_ID_ERC2981) ) {
            
            ( address royaltyReceiver, uint256 royaltyAmount ) = IERC2981(_collection).royaltyInfo(_tokenId, _price);

            if ( _collection == address(NinfaERC721) ) {
                
                if ( !secondarySale[_tokenId] ) {
                    if ( ninfaPrimaryFee == 0 ) {
                        marketplaceFeeAmount = 0;
                    } else {
                        marketplaceFeeAmount = _price * ninfaPrimaryFee / 10000; 
                    }
                    
                    secondarySale[_tokenId] = true; // Set secondarySale bool to true after first sale on NinfaMarketplace.
                    
                    address commissionReceiver = _primarySalesCommission[_tokenId].receiver;
                    uint256 commissionAmount = (_price * _primarySalesCommission[_tokenId].feeBps) / 10000; 
                    if ( commissionAmount > 0 && _seller == commissionReceiver) {

                        delete _primarySalesCommission[_tokenId]; // since this struct is only ever used for primary sales once, it is possible to delete it
                        sellerAmount = commissionAmount; // swap `sellerAmount` for `commissionAmount`, because the seller being the `commissionReceiver` will receive `commissionAmount`, while the artist will receive the principal left after subtracting marketplace fees and gallery commission
                        
                        (success, ) = royaltyReceiver.call{ value: _price - marketplaceFeeAmount - commissionAmount }("");
                        require(success);
                        
                        emit RoyaltyPayment(_collection, _tokenId, royaltyReceiver, _price - marketplaceFeeAmount - commissionAmount);
                    } else {
                        sellerAmount = ( _price - marketplaceFeeAmount );
                    }

                } else {
                    sellerAmount = ( _price - royaltyAmount - marketplaceFeeAmount );
                    payRoyalties(royaltyReceiver, royaltyAmount, _collection, _tokenId);
                }

            } else {
                if( royaltyReceiver != address(0) && royaltyAmount > 0 && royaltyAmount <= (_price - marketplaceFeeAmount) ) {
                    sellerAmount = ( _price - royaltyAmount - marketplaceFeeAmount );
                    payRoyalties(royaltyReceiver, royaltyAmount, _collection, _tokenId);
                }
            }

        }

        (success, ) = feeAccount.call{ value: marketplaceFeeAmount }("");
        require(success);

        (success, ) = payable(_seller).call{ value: sellerAmount /*(_price - marketplaceFeeAmount - royaltyAmount)*/ }("");
        require(success);

        emit Trade(_collection, _tokenId, _seller, _price, _buyer, _orderId);
    }

    function payRoyalties(address _royaltyReceiver, uint256 _royaltyAmount, address _collection, uint256 _tokenId) private {

        address commissionReceiver = _royaltiesCommission[_collection][_tokenId].receiver;
        uint256 commissionAmount = ( _royaltyAmount * _royaltiesCommission[_collection][_tokenId].feeBps ) / 10000; 
        bool success;

        if (commissionAmount > 0) { // if there is a gallery commission on royalties, pay it. Even if an artist is associated to a gallery, they may chose to pay 0 commission on royalties.

            (success, ) = commissionReceiver.call{ value: commissionAmount }("");
            require(success);

            emit RoyaltyPayment(_collection, _tokenId, commissionReceiver, commissionAmount); // reusing the same event definition for both artist and gallery royalties, one may just filter events by address to find out which is which
        }

        (success, ) = _royaltyReceiver.call{ value: _royaltyAmount - commissionAmount }("");
        require(success);

        emit RoyaltyPayment(_collection, _tokenId, _royaltyReceiver, _royaltyAmount);
    }


    function setRoyaltyCommission (
        address _collection,
        uint256 _tokenId,
        address _receiver,
        uint24  _bps
    ) external {
        require(_bps <= 9000); // max 90% of royalties to gallery.
        require( _collection == address(NinfaERC721) || ERC721Whitelist[_collection] == true);
        require(_receiver != address(0)); // placing this check here avoids checking it each time a sale occurs
        require( IERC165(_collection).supportsInterface(INTERFACE_ID_ERC2981) );

        (address royaltyReceiver, ) = IERC2981(_collection).royaltyInfo(_tokenId, 10000);
        require( msg.sender == royaltyReceiver ); // caller must be royalty receiver. Receiver corresponds to artist in Ninfa collection.

        _royaltiesCommission[_collection][_tokenId] = _Commission(_receiver, _bps);

        emit Commission(_collection, _tokenId, _receiver, 0, _bps);
    }

    function setPrimarySaleCommission (
        uint256 _tokenId,
        address _receiver,
        uint24  _bps
    ) external {
        require(_bps <= 8500); 
        require(_receiver != address(0)); // placing this check here avoids checking it each time a sale occurs
        (address royaltyReceiver, ) = IERC2981(address(NinfaERC721)).royaltyInfo(_tokenId, 10000);
        require( msg.sender == royaltyReceiver ); // caller must be royalty receiver. Receiver corresponds to artist in Ninfa collection.
        require( !secondarySale[_tokenId] ); // technically not needed to check, since it won't make a difference; the split will not be used if it is a secondary sale anyway. However, it avoids wasting gas by mistake should someone try it, this way they will get a "transaction will likely fail, are you sure?" message.

        _primarySalesCommission[_tokenId] = _Commission(_receiver, _bps);

        emit Commission(address(NinfaERC721), _tokenId, _receiver, _bps, 0);
    }

    function deleteRoyaltyCommission ( address _collection, uint256 _tokenId ) external {
        require( IERC165(_collection).supportsInterface(INTERFACE_ID_ERC2981) );
        (address royaltyReceiver, ) = IERC2981(_collection).royaltyInfo(_tokenId, 10000); // 10000 is just a placeholder uint as the royaltyAmount returned by royaltyInfo is not used
        require( msg.sender == royaltyReceiver ); // caller must be royalty receiver. Receiver corresponds to artist in Ninfa collection.
        
        delete _royaltiesCommission[_collection][_tokenId];
    }

    function deletePrimarySaleCommission ( uint256 _tokenId ) external {
        (address royaltyReceiver, ) = IERC2981(address(NinfaERC721)).royaltyInfo(_tokenId, 10000); // 10000 is just a placeholder uint as the royaltyAmount returned by royaltyInfo is not used
        require( msg.sender == royaltyReceiver ); // caller must be royalty receiver. Receiver corresponds to artist in Ninfa collection.

        delete _primarySalesCommission[_tokenId];
    }


    function setFeeAccount(address payable _feeAccount) onlyRole(DEFAULT_ADMIN_ROLE) external {
        feeAccount = _feeAccount;
        emit FeeAccount(feeAccount);
    }

    function whitelistERC721(address _collection) onlyRole(DEFAULT_ADMIN_ROLE) external {
        ERC721Whitelist[_collection] = true;
    }

    function setPrimaryFee (uint24 _feeBps) onlyRole(DEFAULT_ADMIN_ROLE) external {
        ninfaPrimaryFee = _feeBps;
    }

    function setNinfaNFT(address _NFT) onlyRole(DEFAULT_ADMIN_ROLE) external {
        require(_NFT != address(0));

        NinfaERC721 = INinfaERC721(_NFT);

        emit FeeAccount(feeAccount);
    }

    function initialize(address _NFT, address _feeAccount) public initializer {
        require(_NFT != address(0));

        __AccessControl_init();
        
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(ARTIST_ROLE, CURATOR_ROLE);

        feeAccount = payable(_feeAccount);

        NinfaERC721 = INinfaERC721(_NFT);

        emit FeeAccount(feeAccount);
    }


    function getOrderId(address _collection, uint256 _tokenId) external view returns(uint256 orderId) {
        orderId = _tokenToOrderId[_collection][_tokenId];
    }

    function getRoyaltyCommission(address _collection, uint256 _tokenId, uint256 _amount) external view returns (address receiver, uint256 commissionAmount) {
        receiver = _royaltiesCommission[_collection][_tokenId].receiver;
        commissionAmount = (_amount * _royaltiesCommission[_collection][_tokenId].feeBps) / 10000; 
    }

    function getPrimaryCommission(uint256 _tokenId, uint256 _amount) external view returns (address receiver, uint256 commissionAmount) {
        receiver = _primarySalesCommission[_tokenId].receiver;
        commissionAmount = (_amount * _primarySalesCommission[_tokenId].feeBps) / 10000; 
    }
    
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC2981 is IERC165 {

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

}