
pragma solidity 0.6.12;

interface IERC1155TokenCreator {

    function tokenCreator(uint256 _tokenId)
    external
    view
    returns (address payable);

}// MIT

pragma solidity 0.6.12;

interface IMarketplaceSettings {

    function getMarketplaceMaxValue() external view returns (uint256);


    function getMarketplaceMinValue() external view returns (uint256);


    function getMarketplaceFeePercentage() external view returns (uint8);


    function calculateMarketplaceFee(uint256 _amount)
    external
    view
    returns (uint256);


    function getERC1155ContractPrimarySaleFeePercentage()
    external
    view
    returns (uint8);


    function calculatePrimarySaleFee(uint256 _amount)
    external
    view
    returns (uint256);


    function hasTokenSold(uint256 _tokenId)
    external
    view
    returns (bool);


    function markERC1155Token(
        uint256 _tokenId,
        bool _hasSold
    ) external;

}// MIT

pragma solidity 0.6.12;


interface INafter {


    function creatorOfToken(uint256 _tokenId)
    external
    view
    returns (address payable);


    function getServiceFee(uint256 _tokenId)
    external
    view
    returns (uint8);


    function getPriceType(uint256 _tokenId, address _owner)
    external
    view
    returns (uint8);


    function setPrice(uint256 _price, uint256 _tokenId, address _owner) external;


    function setBid(uint256 _bid, address _bidder, uint256 _tokenId, address _owner) external;


    function removeFromSale(uint256 _tokenId, address _owner) external;


    function getTokenIdsLength() external view returns (uint256);


    function getTokenId(uint256 _index) external view returns (uint256);


    function getOwners(uint256 _tokenId)
    external
    view
    returns (address[] memory owners);


    function getIsForSale(uint256 _tokenId, address _owner) external view returns (bool);

}// MIT

pragma solidity 0.6.12;

interface INafterMarketAuction {

    function setSalePrice(
        uint256 _tokenId,
        uint256 _amount,
        address _owner
    ) external;


    function setInitialBidPriceWithRange(
        uint256 _bidAmount,
        uint256 _startTime,
        uint256 _endTime,
        address _owner,
        uint256 _tokenId
    ) external;


    function hasTokenActiveBid(uint256 _tokenId, address _owner) external view returns (bool);


}// MIT

pragma solidity 0.6.12;


interface INafterRoyaltyRegistry is IERC1155TokenCreator {

    function getTokenRoyaltyPercentage(
        uint256 _tokenId
    ) external view returns (uint8);


    function calculateRoyaltyFee(
        uint256 _tokenId,
        uint256 _amount
    ) external view returns (uint256);


    function setPercentageForTokenRoyalty(
        uint256 _tokenId,
        uint8 _percentage
    ) external returns (uint8);

}// MIT

pragma solidity 0.6.12;

interface INafterTokenCreatorRegistry {

    function tokenCreator(uint256 _tokenId)
    external
    view
    returns (address payable);


    function setTokenCreator(
        uint256 _tokenId,
        address payable _creator
    ) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.6.0 <0.8.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using SafeMath for uint256;
    using Address for address;

    mapping (uint256 => mapping(address => uint256)) private _balances;

    mapping (address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    constructor (string memory uri_) public {
        _setURI(uri_);

        _registerInterface(_INTERFACE_ID_ERC1155);

        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    function uri(uint256) external view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {

        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {

        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] = _balances[id][account].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(address account, uint256 id, uint256 amount) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        virtual
    { }


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        private
    {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}// MIT
pragma solidity 0.6.12;

pragma experimental ABIEncoderV2;


contract Nafter is ERC1155, Ownable, INafter {

    using SafeMath for uint256;
    struct TokenInfo {
        uint256 tokenId;
        address creator;
        uint256 tokenAmount;
        address[] owners;
        uint8 serviceFee;
        uint256 creationTime;
    }

    struct TokenOwnerInfo {
        bool isForSale;
        uint8 priceType; // 0 for fixed, 1 for Auction dates range, 2 for Auction Infinity
        uint256[] prices;
        uint256[] bids;
        address[] bidders;
    }

    INafterMarketAuction marketAuction;
    IMarketplaceSettings marketplaceSettings;
    INafterRoyaltyRegistry royaltyRegistry;
    INafterTokenCreatorRegistry tokenCreatorRigistry;

    mapping(uint256 => TokenInfo) public tokenInfo;
    mapping(uint256 => mapping(address => TokenOwnerInfo)) public tokenOwnerInfo;

    mapping(uint256 => bool) public tokenIdsAvailable;

    uint256[] public tokenIds;
    uint256 public maxId;

    event AddNewToken(address user, uint256 tokenId);
    event DeleteTokens(address user, uint256 tokenId, uint256 amount);
    event SetURI(string uri);

    constructor(
        string memory _uri
    ) public
    ERC1155(_uri)
    {

    }

    function creatorOfToken(uint256 _tokenId)
    external
    view override
    returns (address payable) {

        return payable(tokenInfo[_tokenId].creator);
    }

    function getServiceFee(uint256 _tokenId)
    external
    view override
    returns (uint8){

        return tokenInfo[_tokenId].serviceFee;
    }

    function getPriceType(uint256 _tokenId, address _owner)
    external
    view override
    returns (uint8){

        return tokenOwnerInfo[_tokenId][_owner].priceType;
    }

    function getTokenAmount(uint256 _tokenId)
    external
    view
    returns (uint256){

        return tokenInfo[_tokenId].tokenAmount;
    }

    function getIsForSale(uint256 _tokenId, address _owner)
    external
    override
    view
    returns (bool){

        return tokenOwnerInfo[_tokenId][_owner].isForSale;
    }

    function getOwners(uint256 _tokenId)
    external
    override
    view
    returns (address[] memory owners){

        return tokenInfo[_tokenId].owners;
    }

    function getPrices(uint256 _tokenId, address _owner)
    external
    view
    returns (uint256[] memory prices){

        return tokenOwnerInfo[_tokenId][_owner].prices;
    }

    function getBids(uint256 _tokenId, address _owner)
    external
    view
    returns (uint256[] memory bids){

        return tokenOwnerInfo[_tokenId][_owner].bids;
    }

    function getBidders(uint256 _tokenId, address _owner)
    external
    view
    returns (address[] memory bidders){

        return tokenOwnerInfo[_tokenId][_owner].bidders;
    }

    function getCreationTime(uint256 _tokenId)
    external
    view
    returns (uint256){

        return tokenInfo[_tokenId].creationTime;
    }

    function getTokenIdsLength() external override view returns (uint256){

        return tokenIds.length;
    }


    function getTokenId(uint256 _index) external override view returns (uint256){

        return tokenIds[_index];
    }

    function getOwnerTokens(address _owner) public view returns (TokenInfo[] memory tokens, TokenOwnerInfo[] memory ownerInfo) {


        uint totalValues;
        for (uint i = 0; i < tokenIds.length; i++) {
            TokenInfo memory info = tokenInfo[tokenIds[i]];
            if (info.owners[info.owners.length - 1] == _owner) {
                totalValues++;
            }
        }

        TokenInfo[] memory values = new TokenInfo[](totalValues);
        TokenOwnerInfo[] memory valuesOwner = new TokenOwnerInfo[](totalValues);
        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            TokenInfo memory info = tokenInfo[tokenId];
            if (info.owners[info.owners.length - 1] == _owner) {
                values[i] = info;
                valuesOwner[i] = tokenOwnerInfo[tokenId][_owner];
            }
        }

        return (values, valuesOwner);
    }

    function getTokensPaging(uint _offset, uint _limit) public view returns (TokenInfo[] memory tokens, uint nextOffset, uint total) {

        uint256 tokenInfoLength = tokenIds.length;
        if (_limit == 0) {
            _limit = 1;
        }

        if (_limit > tokenInfoLength - _offset) {
            _limit = tokenInfoLength - _offset;
        }

        TokenInfo[] memory values = new TokenInfo[] (_limit);
        for (uint i = 0; i < _limit; i++) {
            uint256 tokenId = tokenIds[_offset + i];
            values[i] = tokenInfo[tokenId];
        }

        return (values, _offset + _limit, tokenInfoLength);
    }

    modifier onlyTokenOwner(uint256 _tokenId) {

        uint256 balance = balanceOf(msg.sender, _tokenId);
        require(balance > 0, "must be the owner of the token");
        _;
    }

    modifier onlyTokenCreator(uint256 _tokenId) {

        address creator = tokenInfo[_tokenId].creator;
        require(creator == msg.sender, "must be the creator of the token");
        _;
    }

    function restore(address _oldAddress, uint256 _startIndex, uint256 _endIndex) external onlyOwner {

        Nafter oldContract = Nafter(_oldAddress);
        uint256 length = oldContract.getTokenIdsLength();
        require(_startIndex < length, "wrong start index");
        require(_endIndex <= length, "wrong end index");

        for (uint i = _startIndex; i < _endIndex; i++) {
            uint256 tokenId = oldContract.getTokenId(i);
            tokenIds.push(tokenId);
            tokenInfo[tokenId] = TokenInfo(
                tokenId,
                oldContract.creatorOfToken(tokenId),
                oldContract.getTokenAmount(tokenId),
                oldContract.getOwners(tokenId),
                oldContract.getServiceFee(tokenId),
                oldContract.getCreationTime(tokenId)
            );

            address[] memory owners = tokenInfo[tokenId].owners;
            for (uint j = 0; j < owners.length; j++) {
                address owner = owners[j];
                tokenOwnerInfo[tokenId][owner] = TokenOwnerInfo(
                    oldContract.getIsForSale(tokenId, owner),
                    oldContract.getPriceType(tokenId, owner),
                    oldContract.getPrices(tokenId, owner),
                    oldContract.getBids(tokenId, owner),
                    oldContract.getBidders(tokenId, owner)
                );

                uint256 ownerBalance = oldContract.balanceOf(owner, tokenId);
                if (ownerBalance > 0) {
                    _mint(owner, tokenId, ownerBalance, '');
                }
            }
            tokenIdsAvailable[tokenId] = true;
        }
        maxId = oldContract.maxId();
    }

    function setTokenAmount(uint256 _tokenAmount, uint256 _tokenId) external onlyTokenCreator(_tokenId) {

        tokenInfo[_tokenId].tokenAmount = tokenInfo[_tokenId].tokenAmount + _tokenAmount;
        _mint(msg.sender, _tokenId, _tokenAmount, '');
    }

    function setIsForSale(bool _isForSale, uint256 _tokenId) public onlyTokenOwner(_tokenId) {

        tokenOwnerInfo[_tokenId][msg.sender].isForSale = _isForSale;
    }

    function putOnSale(uint8 _priceType, uint256 _price, uint256 _startTime, uint256 _endTime, uint256 _tokenId, address _owner) public onlyTokenOwner(_tokenId) {

        if (_priceType == 0) {
            marketAuction.setSalePrice(_tokenId, _price, _owner);
        }
        if (_priceType == 1 || _priceType == 2) {
            marketAuction.setInitialBidPriceWithRange(_price, _startTime, _endTime, _owner, _tokenId);
        }
        tokenOwnerInfo[_tokenId][_owner].isForSale = true;
        tokenOwnerInfo[_tokenId][_owner].priceType = _priceType;
    }

    function removeFromSale(uint256 _tokenId, address _owner) external override {

        uint256 balance = balanceOf(msg.sender, _tokenId);
        require(balance > 0 || msg.sender == address(marketAuction), "must be the owner of the token or sender is market auction");

        tokenOwnerInfo[_tokenId][_owner].isForSale = false;
    }

    function setPriceType(uint8 _priceType, uint256 _tokenId) external onlyTokenOwner(_tokenId) {

        tokenOwnerInfo[_tokenId][msg.sender].priceType = _priceType;
    }

    function setMarketAddresses(address _marketAuction, address _marketplaceSettings, address _tokenCreatorRigistry, address _royaltyRegistry) external onlyOwner {

        marketAuction = INafterMarketAuction(_marketAuction);
        marketplaceSettings = IMarketplaceSettings(_marketplaceSettings);
        tokenCreatorRigistry = INafterTokenCreatorRegistry(_tokenCreatorRigistry);
        royaltyRegistry = INafterRoyaltyRegistry(_royaltyRegistry);
    }

    function setPrice(uint256 _price, uint256 _tokenId, address _owner) external override {

        require(msg.sender == address(marketAuction), "only market auction can set the price");
        TokenOwnerInfo storage info = tokenOwnerInfo[_tokenId][_owner];
        info.prices.push(_price);
    }

    function setBid(uint256 _bid, address _bidder, uint256 _tokenId, address _owner) external override {

        require(msg.sender == address(marketAuction), "only market auction can set the price");
        TokenOwnerInfo storage info = tokenOwnerInfo[_tokenId][_owner];
        info.bids.push(_bid);
        info.bidders.push(_bidder);
    }

    function addNewToken(uint256 _tokenAmount, bool _isForSale, uint8 _priceType, uint8 _royaltyPercentage) public {

        uint256 tokenId = _createToken(msg.sender, _tokenAmount, _isForSale, 0, _priceType, _royaltyPercentage);

        emit AddNewToken(msg.sender, tokenId);
    }

    function addNewTokenWithId(uint256 _tokenAmount, bool _isForSale, uint8 _priceType, uint8 _royaltyPercentage, uint256 _tokenId) public {

        uint256 tokenId = _createTokenWithId(msg.sender, _tokenAmount, _isForSale, 0, _priceType, _royaltyPercentage, _tokenId);

        emit AddNewToken(msg.sender, tokenId);
    }

    function addNewTokenAndSetThePrice(uint256 _tokenAmount, bool _isForSale, uint256 _price, uint8 _priceType, uint8 _royaltyPercentage, uint256 _startTime, uint256 _endTime) public {

        uint256 tokenId = getTokenIdAvailable();
        addNewTokenAndSetThePriceWithId(_tokenAmount, _isForSale, _price, _priceType, _royaltyPercentage, _startTime, _endTime, tokenId);
    }

    function addNewTokenAndSetThePriceWithId(uint256 _tokenAmount, bool _isForSale, uint256 _price, uint8 _priceType, uint8 _royaltyPercentage, uint256 _startTime, uint256 _endTime, uint256 _tokenId) public {

        uint256 tokenId = _createTokenWithId(msg.sender, _tokenAmount, _isForSale, _price, _priceType, _royaltyPercentage, _tokenId);
        putOnSale(_priceType, _price, _startTime, _endTime, tokenId, msg.sender);

        emit AddNewToken(msg.sender, tokenId);
    }

    function deleteToken(uint256 _tokenId, uint256 _amount) public onlyTokenOwner(_tokenId) {

        bool activeBid = marketAuction.hasTokenActiveBid(_tokenId, msg.sender);
        uint256 balance = balanceOf(msg.sender, _tokenId);
        if (activeBid == true)
            require(balance.sub(_amount) > 0, "you have the active bid");
        _burn(msg.sender, _tokenId, _amount);
        DeleteTokens(msg.sender, _tokenId, _amount);
    }

    function setURI(string memory _uri) external onlyOwner {

        _setURI(_uri);
        emit SetURI(_uri);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
    public
    virtual
    override
    {

        if (msg.sender != address(marketAuction)) {
            bool activeBid = marketAuction.hasTokenActiveBid(id, from);
            uint256 balance = balanceOf(from, id);
            if (activeBid == true)
                require(balance.sub(amount) > 0, "you have the active bid");
        }
        super.safeTransferFrom(from, to, id, amount, data);
        _setTokenOwner(id, to);
    }

    function _setTokenOwner(uint256 _tokenId, address _owner) internal {

        address[] storage owners = tokenInfo[_tokenId].owners;
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == _owner) //incase owner already exists
                return;
        }
        owners.push(_owner);
    }

    function _createToken(address _creator, uint256 _tokenAmount, bool _isForSale, uint256 _price, uint8 _priceType, uint8 _royaltyPercentage) internal returns (uint256) {

        uint256 newId = getTokenIdAvailable();
        return _createTokenWithId(_creator, _tokenAmount, _isForSale, _price, _priceType, _royaltyPercentage, newId);
    }

    function _createTokenWithId(address _creator, uint256 _tokenAmount, bool _isForSale, uint256 _price, uint8 _priceType, uint8 _royaltyPercentage, uint256 _tokenId) internal returns (uint256) {

        require(tokenIdsAvailable[_tokenId] == false, "token id is already exist");

        tokenIdsAvailable[_tokenId] = true;
        tokenIds.push(_tokenId);

        maxId = maxId > _tokenId ? maxId : _tokenId;

        _mint(_creator, _tokenId, _tokenAmount, '');
        uint8 serviceFee = marketplaceSettings.getMarketplaceFeePercentage();

        tokenInfo[_tokenId] = TokenInfo(
            _tokenId,
            _creator,
            _tokenAmount,
            new address[](0),
            serviceFee,
            block.timestamp);

        tokenInfo[_tokenId].owners.push(_creator);

        tokenOwnerInfo[_tokenId][_creator] = TokenOwnerInfo(
            _isForSale,
            _priceType,
            new uint256[](0),
            new uint256[](0),
            new address[](0));
        tokenOwnerInfo[_tokenId][_creator].prices.push(_price);

        royaltyRegistry.setPercentageForTokenRoyalty(_tokenId, _royaltyPercentage);
        tokenCreatorRigistry.setTokenCreator(_tokenId, msg.sender);

        return _tokenId;
    }

    function getLastTokenId() external view returns (uint256){

        return tokenIds[tokenIds.length - 1];
    }

    function getTokenIdAvailable() public view returns (uint256){


        for (uint256 i = 0; i < maxId; i++) {
            if (tokenIdsAvailable[i] == false)
                return i;
        }
        return tokenIds.length;
    }
}