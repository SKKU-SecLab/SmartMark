
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.1;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

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

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
pragma solidity ^0.8.0;

interface HasSecondarySaleFees {

    function getFeeRecipients(uint256 id)
        external
        view
        returns (address payable[] memory);


    function getFeeBps(uint256 id)
        external
        view
        returns (uint256[] memory);

}// MIT
pragma solidity ^0.8.0;


contract MarketplaceV2_5 is Ownable {

    using SafeERC20 for IERC20;

    enum TokenType {ERC1155, ERC721, ERC721Deprecated}

    struct nftToken {
        address collection;
        uint256 id;
        TokenType tokenType;
    }

    struct Position {
        nftToken nft;
        uint256 amount;
        uint256 price;
        address owner;
        address currency;
    }

    struct MarketplaceFee {
        bool customFee;
        uint16 buyerFee;
        uint16 sellerFee;
    }

    struct CollectionRoyalties {
        address recipient;
        uint256 fee;
    }

    mapping(uint256 => Position) public positions;
    uint256 public positionsCount = 0;

    address public marketplaceBeneficiaryAddress;
    mapping(address => MarketplaceFee) private marketplaceCollectionFee;
    mapping(address => CollectionRoyalties) private customCollectionRoyalties;

    bytes4 private constant _INTERFACE_ID_FEES = 0xb7799584;

    event MarketplaceFeeChanged(
        address indexed colection,
        uint16 buyerFee,
        uint16 sellerFee
    );

    event CollectionRoyaltiesChanged(
        address indexed colection,
        address recipient,
        uint256 indexed amount
    );

    event NewPosition(
        address indexed owner,
        uint256 indexed id,
        address collection,
        uint256 token,
        uint256 amount,
        uint256 price,
        address currency
    );

    event Buy(
        address owner,
        address buyer,
        uint256 indexed position,
        address indexed collection,
        uint256 indexed token,
        uint256 amount,
        uint256 price,
        address currency
    );

    event Cancel(address owner, uint256 position);

    constructor() {
        marketplaceBeneficiaryAddress = payable(msg.sender);
        marketplaceCollectionFee[address(0)] = MarketplaceFee(true, 250, 250);
    }

    function changeMarketplaceBeneficiary(
        address _marketplaceBeneficiaryAddress
    ) external onlyOwner {

        marketplaceBeneficiaryAddress = _marketplaceBeneficiaryAddress;
    }

    function getMarketplaceFee(address _collection) public view returns(MarketplaceFee memory) {

        if (marketplaceCollectionFee[_collection].customFee) {
            return marketplaceCollectionFee[_collection];
        }
        return marketplaceCollectionFee[address(0)];
    }

    function changeMarketplaceCollectionFee(
        address _collection,
        uint16 _buyerFee,
        uint16 _sellerFee
    ) external onlyOwner {

        marketplaceCollectionFee[_collection] = MarketplaceFee(
            true,
            _buyerFee,
            _sellerFee
        );
        emit MarketplaceFeeChanged(_collection, _buyerFee, _sellerFee);
    }

    function removeMarketplaceCollectionFee(address _collection) external onlyOwner {

        require(_collection != address(0), "Wrong collection");
        delete marketplaceCollectionFee[_collection];
        emit MarketplaceFeeChanged(
            _collection,
            marketplaceCollectionFee[address(0)].buyerFee,
            marketplaceCollectionFee[address(0)].sellerFee
        );
    }

    function getCustomCollectionRoyalties(address _collection) public view returns(CollectionRoyalties memory) {

        return customCollectionRoyalties[_collection];
    }

    function changeCollectionRoyalties(
        address _collection,
        address _recipient,
        uint256 _amount
    ) external onlyOwner {

        require(_collection != address(0), "Wrong collection");
        require(_amount > 0 && _amount < 10000, "Wrong amount");
        require(!IERC165(_collection).supportsInterface(_INTERFACE_ID_FEES), "Collection haw own royalties");
        customCollectionRoyalties[_collection] = CollectionRoyalties(_recipient, _amount);
        emit CollectionRoyaltiesChanged(_collection, _recipient, _amount);
    }

    function removeCollectionRoyalties(address _collection) external onlyOwner {

        delete customCollectionRoyalties[_collection];
        emit CollectionRoyaltiesChanged(_collection, address(0), 0);
    }

    function putOnSale(
        address _collection,
        TokenType _tokenType,
        uint256 _id,
        uint256 _amount,
        uint256 _price,
        address _currency
    ) external returns (uint256) {

        if (_tokenType == TokenType.ERC1155) {
            require(
                IERC1155(_collection).balanceOf(msg.sender, _id) >= _amount,
                "Wrong amount"
            );
        } else {
            require(
                (IERC721(_collection).ownerOf(_id) == msg.sender) &&
                    (_amount == 1),
                "Wrong amount"
            );
        }
        positions[++positionsCount] = Position(
            nftToken(_collection, _id, _tokenType),
            _amount,
            _price,
            msg.sender,
            _currency
        );

        emit NewPosition(
            msg.sender,
            positionsCount,
            _collection,
            _id,
            _amount,
            _price,
            _currency
        );
        return positionsCount;
    }

    function cancel(uint256 _id) external {

        require(msg.sender == positions[_id].owner || msg.sender == owner(), "Access denied");
        positions[_id].amount = 0;

        emit Cancel(msg.sender, _id);
    }

    function buy(
        uint256 _position,
        uint256 _amount,
        address _buyer,
        bytes calldata _data
    ) external payable {

        Position memory position = positions[_position];
        require(position.amount >= _amount, "Wrong amount");

        transferWithFees(_position, _amount);

        if (_buyer == address(0)) {
            _buyer = msg.sender;
        }
        if (position.nft.tokenType == TokenType.ERC1155) {
            IERC1155(position.nft.collection).safeTransferFrom(
                position.owner,
                _buyer,
                position.nft.id,
                _amount,
                _data
            );
        } else if (position.nft.tokenType == TokenType.ERC721) {
            require(_amount == 1, "Wrong amount");
            IERC721(position.nft.collection).safeTransferFrom(
                position.owner,
                _buyer,
                position.nft.id
            );
        } else if (position.nft.tokenType == TokenType.ERC721Deprecated) {
            require(_amount == 1, "Wrong amount");
            IERC721(position.nft.collection).transferFrom(
                position.owner,
                _buyer,
                position.nft.id
            );
        }
        emit Buy(
            position.owner,
            _buyer,
            _position,
            position.nft.collection,
            position.nft.id,
            _amount,
            position.price,
            position.currency
        );
    }

    function transferWithFees(uint256 _position, uint256 _amount) internal {

        Position storage position = positions[_position];
        uint256 price = position.price * _amount;
        MarketplaceFee memory marketplaceFee = getMarketplaceFee(position.nft.collection);
        uint256 buyerFee = getFee(price, marketplaceFee.buyerFee);
        uint256 sellerFee = getFee(price, marketplaceFee.sellerFee);
        uint256 total = price + buyerFee;

        if (position.currency == address(0)) {
            require(msg.value >= total, "Insufficient balance");
            uint256 returnBack = msg.value - total;
            if (returnBack > 0) {
                payable(msg.sender).transfer(returnBack);
            }
        }

        if (buyerFee + sellerFee > 0) {
            transfer(
                marketplaceBeneficiaryAddress,
                position.currency,
                buyerFee + sellerFee
            );
        }
        uint256 fees = transferFees(price, position) + sellerFee;
        transfer(position.owner, position.currency, price - fees);

        position.amount = position.amount - _amount;
    }

    function transfer(
        address _to,
        address _currency,
        uint256 _amount
    ) internal {

        if (_currency == address(0)) {
            payable(_to).transfer(_amount);
        } else {
            IERC20(_currency).transferFrom(msg.sender, _to, _amount);
        }
    }

    function transferFees(uint256 _price, Position memory position)
        internal
        returns (uint256)
    {

        HasSecondarySaleFees collection =
            HasSecondarySaleFees(position.nft.collection);
        uint256 result = 0;
        if (
            (position.nft.tokenType == TokenType.ERC1155 &&
                IERC1155(position.nft.collection).supportsInterface(
                    _INTERFACE_ID_FEES
                )) ||
            ((position.nft.tokenType == TokenType.ERC721 ||
                position.nft.tokenType == TokenType.ERC721Deprecated) &&
                IERC721(position.nft.collection).supportsInterface(
                    _INTERFACE_ID_FEES
                ))
        ) {
            uint256[] memory fees = collection.getFeeBps(position.nft.id);
            address payable[] memory recipients =
                collection.getFeeRecipients(position.nft.id);
            for (uint256 i = 0; i < fees.length; i++) {
                uint256 fee = getFee(_price, fees[i]);
                if (fee > 0) {
                    transfer(recipients[i], position.currency, fee);
                    result = result + fee;
                }
            }
        } else if (customCollectionRoyalties[position.nft.collection].fee > 0) {
            uint256 fee = getFee(_price, customCollectionRoyalties[position.nft.collection].fee);
            transfer(customCollectionRoyalties[position.nft.collection].recipient, position.currency, fee);
            result = result + fee;
        }
        return result;
    }

    function getFee(uint256 _amount, uint256 _fee)
        internal
        pure
        returns (uint256)
    {

        return _amount * _fee / 10000;
    }
}