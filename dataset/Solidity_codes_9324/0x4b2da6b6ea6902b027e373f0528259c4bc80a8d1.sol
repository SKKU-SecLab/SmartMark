
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
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


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using Address for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
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

        _setApprovalForAll(_msgSender(), operator, approved);
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
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}


    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
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
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
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

pragma solidity ^0.8.0;


abstract contract ERC1155Supply is ERC1155 {
    mapping(uint256 => uint256) private _totalSupply;

    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply[id];
    }

    function exists(uint256 id) public view virtual returns (bool) {
        return ERC1155Supply.totalSupply(id) > 0;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                _totalSupply[ids[i]] += amounts[i];
            }
        }

        if (to == address(0)) {
            for (uint256 i = 0; i < ids.length; ++i) {
                uint256 id = ids[i];
                uint256 amount = amounts[i];
                uint256 supply = _totalSupply[id];
                require(supply >= amount, "ERC1155: burn amount exceeds totalSupply");
                unchecked {
                    _totalSupply[id] = supply - amount;
                }
            }
        }
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
pragma solidity ^0.8.4;


contract PoulinaToken is ERC1155Supply, Ownable {

    uint256 public totalMinted;
    mapping(uint256 => string) tokenURIs;
    mapping(uint256 => uint256) fractionPrices;
    mapping(uint256 => uint256) maxSupplys;
    mapping(uint256 => address) creators;
    mapping(address => uint256[]) tokenAmountByUser;

    address public marketAddress;

    event CreateNFT(
        uint256 tokenId,
        string tokenURI,
        uint256 airdropAmount,
        uint256 maxSupply,
        uint256 fractionPrice,
        address creator
    );
    event Minted(uint256 tokenId, uint256 amount, address minter);

    constructor() ERC1155("Poulina") {}

    modifier exist(uint256 tokenId) {

        require(exists(tokenId) == true, "The Token does not exist");
        _;
    }

    modifier onlyMarket() {

        require(msg.sender == marketAddress, "Only marketplace can use me.");
        _;
    }

    function setMarketAddress(address _newMarketAddress) external onlyOwner {

        marketAddress = _newMarketAddress;
    }

    function create(
        string memory tokenURI,
        uint256 airdropAmount,
        uint256 mxSpl,
        uint256 frcPrice
    ) external {

        require(mxSpl > 0, "Max Supply Must be bigger than 0");
        tokenURIs[++totalMinted] = tokenURI;
        fractionPrices[totalMinted] = frcPrice;
        maxSupplys[totalMinted] = mxSpl;
        creators[totalMinted] = msg.sender;
        if (airdropAmount > 0) {
            _mint(msg.sender, totalMinted, airdropAmount, "0x0000");
        }
        emit CreateNFT(
            totalMinted,
            tokenURI,
            airdropAmount,
            mxSpl,
            frcPrice,
            msg.sender
        );
    }

    function mint(uint256 tokenId, uint256 amount) external payable {

        require(exists(tokenId) == true, "The Token does not exist");
        require(amount > 0, "Minting 0 is not allowed");
        require(
            totalSupply(tokenId) + amount <= maxSupplys[tokenId],
            "Exceeds Max Supply"
        );

        uint256 price = fractionPrices[tokenId] * amount;
        if (totalSupply(tokenId) % 100000 == 0) {
            uint256 times = totalSupply(tokenId) / 100000;
            for (uint256 i = 1; i <= times; ++i) {
                price = (price * 201) / 200;
            }
        }

        require(msg.value >= price, "Insufficient funds");
        _mint(msg.sender, tokenId, amount, "0x0000");
        payable(creators[tokenId]).transfer(msg.value);
        emit Minted(tokenId, amount, msg.sender);
    }


    function uri(uint256 tokenId)
        public
        view
        override
        exist(tokenId)
        returns (string memory)
    {

        return tokenURIs[tokenId];
    }

    function fractionPrice(uint256 tokenId)
        external
        view
        exist(tokenId)
        returns (uint256)
    {

        return fractionPrices[tokenId];
    }

    function maxSupply(uint256 tokenId)
        external
        view
        exist(tokenId)
        returns (uint256)
    {

        return maxSupplys[tokenId];
    }

    function creator(uint256 tokenId)
        external
        view
        exist(tokenId)
        returns (address)
    {

        return creators[tokenId];
    }

    function getTotalMinted() external view returns (uint256) {

        return totalMinted;
    }


    function setFractionPrice(uint256 tokenId, uint256 price)
        external
        exist(tokenId)
        onlyMarket
    {

        fractionPrices[tokenId] = price;
    }

    function setMaxSupply(uint256 tokenId, uint256 supply)
        external
        exist(tokenId)
        onlyMarket
    {

        maxSupplys[tokenId] = supply;
    }

    function setCreator(uint256 tokenId, address newCreator)
        external
        exist(tokenId)
        onlyMarket
    {

        creators[tokenId] = newCreator;
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI)
        external
        exist(tokenId)
        onlyMarket
    {

        tokenURIs[tokenId] = tokenURI;
    }

    function setTotalMinted(uint256 _newTotalMinted) external onlyMarket {

        totalMinted = _newTotalMinted;
    }

    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool isOperator)
    {

        if (_operator == marketAddress) {
            return true;
        }

        return super.isApprovedForAll(_owner, _operator);
    }

    function getTokenIdByUser(address _addr)
        external
        view
        returns (uint256[] memory)
    {

        uint256 length;
        uint256 i;
        uint256[] memory tokenIds;
        for (i = 1; i <= totalMinted; ++i) {
            if (balanceOf(_addr, i) > 0) {
                ++length;
            }
        }
        if (length > 0) {
            tokenIds = new uint256[](length);
            length = 0;
            for (i = 1; i <= totalMinted; ++i) {
                if (balanceOf(_addr, i) > 0) {
                    tokenIds[length++] = i;
                }
            }
        }
        return tokenIds;
    }

    function getTokenAmountByUser(address _addr)
        external
        view
        returns (uint256[] memory)
    {

        return tokenAmountByUser[_addr];
    }
}// MIT
pragma solidity ^0.8.4;


interface externalInterface is IERC1155 {

    function getTotalMinted() external view returns (uint256);


    function exists(uint256 id) external view returns (bool);

}

contract PoulinaMarketplace is ERC1155Holder {

    struct Sale {
        address seller;
        uint256 price;
        uint256 amount;
    }

    mapping(uint256 => Sale[]) tokenIdToSales;
    mapping(address => mapping(uint256 => Sale[])) private saleTokensBySeller;

    mapping(bytes4 => bool) private _supportedInterfaces;

    address public nftContractAddr;

    event CreateNFT(
        uint256 tokenId,
        string tokenURI,
        uint256 airdropAmount,
        uint256 maxSupply,
        uint256 fractionPrice,
        address creator
    );
    event Minted(uint256 tokenId, uint256 amount, address minter);
    event SaleCreated(
        address seller,
        uint256 tokenId,
        uint256 price,
        uint256 amount
    );
    event SaleCanceled(
        address seller,
        uint256 tokenId,
        uint256 price,
        uint256 amount
    );
    event SaleSuccess(
        address seller,
        address buyer,
        uint256 tokenId,
        uint256 price,
        uint256 amount
    );

    constructor(address _poulinaTokenAddr) {
        nftContractAddr = _poulinaTokenAddr;
        _supportedInterfaces[0xd9b67a26] = true; // _INTERFACE_ID_ERC1155
    }

    function createSale(
        uint256 tokenId,
        uint256 price,
        uint256 amount
    ) external {

        require(
            externalInterface(nftContractAddr).balanceOf(msg.sender, tokenId) >=
                amount,
            "Insufficient token to create sale"
        );
        externalInterface(nftContractAddr).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            amount,
            "0x0000"
        );
        uint256 i;
        uint256 length = tokenIdToSales[tokenId].length;
        for (
            i = 0;
            i < length &&
                (tokenIdToSales[tokenId][i].seller != msg.sender ||
                    tokenIdToSales[tokenId][i].price != price);
            ++i
        ) {}
        if (i < length) {
            tokenIdToSales[tokenId][i].amount += amount;
        } else {
            tokenIdToSales[tokenId].push(Sale(msg.sender, price, amount));
        }
        length = saleTokensBySeller[msg.sender][tokenId].length;
        for (
            i = 0;
            i < length &&
                saleTokensBySeller[msg.sender][tokenId][i].price != price;
            ++i
        ) {}
        if (i < length) {
            saleTokensBySeller[msg.sender][tokenId][i].amount += amount;
        } else {
            saleTokensBySeller[msg.sender][tokenId].push(
                Sale(msg.sender, price, amount)
            );
        }
        emit SaleCreated(msg.sender, tokenId, price, amount);
    }

    function removeSale(
        address seller,
        uint256 tokenId,
        uint256 price,
        uint256 amount
    ) internal {

        uint256 i;
        uint256 length = tokenIdToSales[tokenId].length;
        for (
            i = 0;
            i < length &&
                (tokenIdToSales[tokenId][i].seller != seller ||
                    tokenIdToSales[tokenId][i].price != price);
            ++i
        ) {}
        require(i < length, "No sale created with this token");
        require(
            tokenIdToSales[tokenId][i].amount >= amount,
            "Insufficient token sale to cancel"
        );
        tokenIdToSales[tokenId][i].amount -= amount;
        if (tokenIdToSales[tokenId][i].amount == 0) {
            tokenIdToSales[tokenId][i] = tokenIdToSales[tokenId][length - 1];
            tokenIdToSales[tokenId].pop();
        }
        length = saleTokensBySeller[seller][tokenId].length;
        for (
            i = 0;
            i < length && saleTokensBySeller[seller][tokenId][i].price != price;
            ++i
        ) {}
        require(i < length, "No sale created with this token");
        require(
            saleTokensBySeller[seller][tokenId][i].amount >= amount,
            "Insufficient token sale to cancel"
        );
        saleTokensBySeller[seller][tokenId][i].amount -= amount;
        if (saleTokensBySeller[seller][tokenId][i].amount == 0) {
            saleTokensBySeller[seller][tokenId][i] = saleTokensBySeller[seller][
                tokenId
            ][length - 1];
            saleTokensBySeller[seller][tokenId].pop();
        }
    }

    function cancelSale(
        uint256 tokenId,
        uint256 price,
        uint256 amount
    ) external {

        removeSale(msg.sender, tokenId, price, amount);
        externalInterface(nftContractAddr).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId,
            amount,
            "0x0000"
        );
        emit SaleCanceled(msg.sender, tokenId, price, amount);
    }

    function purchase(
        address seller,
        uint256 tokenId,
        uint256 price,
        uint256 amount
    ) external payable {

        require(seller != msg.sender, "Seller cannot buy his token");
        require(msg.value >= price * amount, "Insufficient fund to buy token");
        removeSale(seller, tokenId, price, amount);
        externalInterface(nftContractAddr).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId,
            amount,
            "0x0000"
        );
        payable(seller).transfer(msg.value);
        emit SaleSuccess(seller, msg.sender, tokenId, price, amount);
    }

    function getSales()
        external
        view
        returns (
            address[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {

        uint256 length;
        uint256 i;
        for (
            i = 1;
            i <= externalInterface(nftContractAddr).getTotalMinted();
            ++i
        ) {
            if (externalInterface(nftContractAddr).exists(i)) {
                length += tokenIdToSales[i].length;
            }
        }
        address[] memory sellers = new address[](length);
        uint256[] memory tokenIds = new uint256[](length);
        uint256[] memory prices = new uint256[](length);
        uint256[] memory amounts = new uint256[](length);
        length = 0;
        uint256 j;
        for (
            i = 1;
            i <= externalInterface(nftContractAddr).getTotalMinted();
            ++i
        ) {
            if (externalInterface(nftContractAddr).exists(i)) {
                for (j = 0; j < tokenIdToSales[i].length; ++j) {
                    sellers[length] = tokenIdToSales[i][j].seller;
                    tokenIds[length] = i;
                    prices[length] = tokenIdToSales[i][j].price;
                    amounts[length++] = tokenIdToSales[i][j].amount;
                }
            }
        }
        return (sellers, tokenIds, prices, amounts);
    }

    function getSalesByTokenId(uint256 tokenId)
        external
        view
        returns (
            address[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {

        uint256 length = tokenIdToSales[tokenId].length;
        uint256 i;
        address[] memory sellers = new address[](length);
        uint256[] memory prices = new uint256[](length);
        uint256[] memory amounts = new uint256[](length);
        for (i = 0; i < length; ++i) {
            sellers[i] = tokenIdToSales[tokenId][i].seller;
            prices[i] = tokenIdToSales[tokenId][i].price;
            amounts[i] = tokenIdToSales[tokenId][i].amount;
        }
        return (sellers, prices, amounts);
    }

    function getSaleTokensBySeller(address seller)
        external
        view
        returns (
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {

        uint256 i;
        uint256 j;
        uint256 length;
        uint256 totalCnt;
        for (
            i = 1;
            i <= externalInterface(nftContractAddr).getTotalMinted();
            ++i
        ) {
            totalCnt += saleTokensBySeller[seller][i].length;
        }
        uint256[] memory tokenIds = new uint256[](totalCnt);
        uint256[] memory prices = new uint256[](totalCnt);
        uint256[] memory amounts = new uint256[](totalCnt);
        totalCnt = 0;
        for (
            i = 1;
            i <= externalInterface(nftContractAddr).getTotalMinted();
            ++i
        ) {
            length = saleTokensBySeller[seller][i].length;
            for (j = 0; j < length; ++j) {
                tokenIds[totalCnt] = i;
                prices[totalCnt] = saleTokensBySeller[seller][i][j].price;
                amounts[totalCnt++] = saleTokensBySeller[seller][i][j].amount;
            }
        }
        return (tokenIds, prices, amounts);
    }

    function getSaleTokensBySellerAndTokenId(address seller, uint256 tokenId)
        external
        view
        returns (uint256[] memory, uint256[] memory)
    {

        uint256 i;
        uint256 length = saleTokensBySeller[seller][tokenId].length;
        uint256[] memory prices = new uint256[](length);
        uint256[] memory amounts = new uint256[](length);
        for (i = 0; i < length; ++i) {
            prices[i] = saleTokensBySeller[seller][tokenId][i].price;
            amounts[i] = saleTokensBySeller[seller][tokenId][i].amount;
        }
        return (prices, amounts);
    }
}