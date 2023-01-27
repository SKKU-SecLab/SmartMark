


pragma solidity 0.8.13;

interface IAssemblyNFT {

    event AssemblyAsset(
        address indexed firstHolder,
        uint256 indexed tokenId,
        uint256 salt,
        address[] addresses,
        uint256[] numbers
    );

    event AssemblyAssetClaimed(
        uint256 indexed tokenId,
        address indexed owner,
        address[] addresses,
        uint256[] numbers
    );

    function hash(
        uint256 _salt,
        address[] memory _addresses,
        uint256[] memory _numbers
    ) external pure returns (uint256 tokenId);


    function safeMint(
        address _to,
        address[] memory _addresses,
        uint256[] memory _numbers
    ) external payable returns (uint256 tokenId);


    function burn(
        address _to,
        uint256 _tokenId,
        uint256 _salt,
        address[] calldata _addresses,
        uint256[] calldata _numbers
    ) external;

}




pragma solidity ^0.8.0;

library Strings {

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




pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




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

}




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

}




pragma solidity ^0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




pragma solidity ^0.8.0;



abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}




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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}




pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}




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
}




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
}




pragma solidity ^0.8.0;








contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}




pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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
}




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
}



pragma solidity 0.8.13;









contract CustomAssemblyNFT is
    ERC721,
    ERC721Holder,
    ERC1155Holder,
    IAssemblyNFT,
    Ownable
{
    using SafeERC20 for IERC20;
    using Strings for uint256;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC1155Receiver)
        returns (bool)
    {
        return
            ERC721.supportsInterface(interfaceId) ||
            ERC1155Receiver.supportsInterface(interfaceId);
    }

    address private L3P = 0xdeF1da03061DDd2A5Ef6c59220C135dec623116d; // L3P contract address (only available on Ethereum && BSC);
    address private feeReceiver = 0xB7B8E47423bF7191aedd3AE649Ef074C2406b52C; /// Lepricon Multisig address
    uint256 public feeETH; // Fees charged on TXs, if paid in native (ETH, MATIC, BNB)
    uint256 public feeL3P; // Fees charged on TXs, if paid in L3P, default === 100 L3P
    uint256 public maxPackSupply;
    uint256 nonce;
    string public _baseURIextended;

    event BatchAssemblyAsset(
        address indexed firstHolder,
        uint256 amountOfPacks
    );

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxPackSupply,
        string memory baseURIextended,
        uint256 _feeETH,
        uint256 _feeL3P,
        address _owner
    ) ERC721(_name, _symbol) {
        maxPackSupply = _maxPackSupply;
        _baseURIextended = baseURIextended;
        feeETH = _feeETH;
        feeL3P = _feeL3P;
        transferOwnership(_owner);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return _baseURIextended;
    }

    function hash(
        uint256 _salt,
        address[] memory _addresses,
        uint256[] memory _numbers
    ) public pure override returns (uint256 tokenId) {
        bytes32 signature = keccak256(abi.encodePacked(_salt));
        for (uint256 i = 0; i < _addresses.length; i++) {
            signature = keccak256(abi.encodePacked(signature, _addresses[i]));
        }
        for (uint256 j = 0; j < _numbers.length; j++) {
            signature = keccak256(abi.encodePacked(signature, _numbers[j]));
        }
        assembly {
            tokenId := signature
        }
    }

    function safeMint(
        address _to,
        address[] memory _addresses,
        uint256[] memory _numbers
    ) external payable override onlyOwner returns (uint256 tokenId) {
        require(_to != address(0), "mint to zero address");

        if (feeETH != 0) {
            if (msg.value > _numbers[0]) {
                require(
                    msg.value == (_numbers[0] + feeETH),
                    "wrong native fee amount"
                );
                (bool feeInEth, ) = payable(feeReceiver).call{value: feeETH}(
                    ""
                );
                require(feeInEth, "ETH payment failed");
                require(
                    msg.value - feeETH == _numbers[0],
                    "native value do not match"
                );
            }
            else if (msg.value == _numbers[0]) {
                require(
                    IERC20(L3P).balanceOf(msg.sender) >= feeL3P,
                    "Not enough L3P to pay the fee"
                );
                require(
                    IERC20(L3P).allowance(msg.sender, address(this)) >= feeL3P,
                    "Not authorized"
                );
                bool feeInL3P = IERC20(L3P).transferFrom(
                    msg.sender,
                    feeReceiver,
                    feeL3P
                );
                require(feeInL3P, "L3P payment failed");
                require(msg.value == _numbers[0], "value not match");
            }
            else revert("value sent do not match");
        } else {
            require(msg.value == _numbers[0], "value not match");
        }

        require(
            _addresses.length == _numbers[1] + _numbers[2] + _numbers[3],
            "2 array length not match"
        );
        require(
            _addresses.length == _numbers.length - 4 - _numbers[3],
            "numbers length not match"
        );
        if (maxPackSupply != 0) {
            require(nonce < maxPackSupply, "Max supply reached");
        }
        uint256 pointerA; //points to first erc20 address, if there is any
        uint256 pointerB = 4; //points to first erc20 amount, if there is any
        for (uint256 i = 0; i < _numbers[1]; i++) {
            require(_numbers[pointerB] > 0, "transfer erc20 0 amount");
            IERC20 token = IERC20(_addresses[pointerA++]);
            uint256 orgBalance = token.balanceOf(address(this));
            token.safeTransferFrom(
                _msgSender(),
                address(this),
                _numbers[pointerB]
            );
            _numbers[pointerB++] = token.balanceOf(address(this)) - orgBalance;
        }
        for (uint256 j = 0; j < _numbers[2]; j++) {
            IERC721(_addresses[pointerA++]).safeTransferFrom(
                _msgSender(),
                address(this),
                _numbers[pointerB++]
            );
        }
        for (uint256 k = 0; k < _numbers[3]; k++) {
            IERC1155(_addresses[pointerA++]).safeTransferFrom(
                _msgSender(),
                address(this),
                _numbers[pointerB],
                _numbers[_numbers[3] + pointerB++],
                ""
            );
        }
        tokenId = hash(nonce, _addresses, _numbers);
        super._mint(_to, tokenId);
        emit AssemblyAsset(_to, tokenId, nonce, _addresses, _numbers);
        nonce++;
    }

    function burn(
        address _to,
        uint256 _tokenId,
        uint256 _salt,
        address[] calldata _addresses,
        uint256[] calldata _numbers
    ) external override {
        require(_msgSender() == ownerOf(_tokenId), "not owned");
        require(_tokenId == hash(_salt, _addresses, _numbers));
        super._burn(_tokenId);
        payable(_to).transfer(_numbers[0]);
        uint256 pointerA; //points to first erc20 address, if there is any
        uint256 pointerB = 4; //points to first erc20 amount, if there is any
        for (uint256 i = 0; i < _numbers[1]; i++) {
            require(_numbers[pointerB] > 0, "transfer erc20 0 amount");
            IERC20(_addresses[pointerA++]).safeTransfer(
                _to,
                _numbers[pointerB++]
            );
        }
        for (uint256 j = 0; j < _numbers[2]; j++) {
            IERC721(_addresses[pointerA++]).safeTransferFrom(
                address(this),
                _to,
                _numbers[pointerB++]
            );
        }
        for (uint256 k = 0; k < _numbers[3]; k++) {
            IERC1155(_addresses[pointerA++]).safeTransferFrom(
                address(this),
                _to,
                _numbers[pointerB],
                _numbers[_numbers[3] + pointerB++],
                ""
            );
        }

        emit AssemblyAssetClaimed(_tokenId, msg.sender, _addresses, _numbers);
    }

    function _batchMint(
        address _to,
        address[] memory _addresses,
        uint256[] memory _numbers
    ) public payable onlyOwner returns (uint256 tokenId) {
        require(
            _addresses.length == _numbers[1] + _numbers[2] + _numbers[3],
            "2 array length not match"
        );
        require(
            _addresses.length == _numbers.length - 4 - _numbers[3],
            "numbers length not match"
        );
        uint256 pointerA; //points to first erc20 address, if there is any
        uint256 pointerB = 4; //points to first erc20 amount, if there is any
        for (uint256 i = 0; i < _numbers[1]; i++) {
            require(_numbers[pointerB] > 0, "transfer erc20 0 amount");
            IERC20(_addresses[pointerA++]).safeTransferFrom(
                _msgSender(),
                address(this),
                _numbers[pointerB++]
            );
        }
        for (uint256 j = 0; j < _numbers[2]; j++) {
            IERC721(_addresses[pointerA++]).safeTransferFrom(
                _msgSender(),
                address(this),
                _numbers[pointerB++]
            );
        }
        for (uint256 k = 0; k < _numbers[3]; k++) {
            IERC1155(_addresses[pointerA++]).safeTransferFrom(
                _msgSender(),
                address(this),
                _numbers[pointerB],
                _numbers[_numbers[3] + pointerB++],
                ""
            );
        }

        tokenId = hash(nonce, _addresses, _numbers);
        super._mint(_to, tokenId);
        emit AssemblyAsset(_to, tokenId, nonce, _addresses, _numbers);
        nonce++;
    }

    function batchMint(
        address _to,
        address[] memory _addresses,
        uint256[][] memory _arrayOfNumbers,
        uint256 _amountOfPacks,
        uint256 _totalOfPacks
    ) external payable onlyOwner {
        require(_to != address(0), "can't mint to address(0)");
        uint256 totalEth = _arrayOfNumbers[0][0] * _amountOfPacks;

        if (feeETH != 0) {
            if (msg.value > totalEth) {
                uint256 totalFees = _amountOfPacks *
                    _discountPercentInETH(_totalOfPacks);
                require(
                    msg.value == (totalEth + totalFees),
                    "wrong native fee amount on custom"
                );
                (bool feeInEth, ) = payable(feeReceiver).call{value: totalFees}(
                    ""
                );
                require(feeInEth, "ETH payment failed");
                require(
                    msg.value - totalFees == totalEth,
                    "native value do not match"
                );
            }
            else if (msg.value == totalEth) {
                uint256 totalFees = _amountOfPacks *
                    _discountPercentInL3P(_amountOfPacks);
                require(
                    IERC20(L3P).balanceOf(msg.sender) >= totalFees,
                    "Not enough L3P to pay the fee"
                );
                require(
                    IERC20(L3P).allowance(msg.sender, address(this)) >=
                        totalFees,
                    "Not authorized"
                );
                bool feeInL3P = IERC20(L3P).transferFrom(
                    msg.sender,
                    feeReceiver,
                    totalFees
                );
                require(feeInL3P, "L3P payment failed");
                require(msg.value == totalEth, "value not match");
            }
            else revert("value sent do not match");
        } else {
            require(msg.value == totalEth, "value not match");
        }

        if (maxPackSupply != 0) {
            require(
                nonce + _amountOfPacks <= maxPackSupply,
                "Max supply reached"
            );
        }

        for (uint256 i = 0; i < _amountOfPacks; i++) {
            _batchMint(_to, _addresses, _arrayOfNumbers[i]);
        }

        emit BatchAssemblyAsset(_to, _amountOfPacks);
    }

    function _discountPercentInETH(uint256 _totalOfPacks)
        private
        view
        returns (uint256)
    {
        if (_totalOfPacks > 0 && _totalOfPacks < 1001) {
            return feeETH;
        } else if (_totalOfPacks >= 1001 && _totalOfPacks < 5001) {
            return (feeETH * 80) / 100;
        } else return (feeETH * 60) / 100;
    }

    function _discountPercentInL3P(uint256 _totalOfPacks)
        private
        view
        returns (uint256)
    {
        if (_totalOfPacks > 0 && _totalOfPacks < 1001) {
            return feeL3P;
        } else if (_totalOfPacks >= 1001 && _totalOfPacks < 5001) {
            return (feeL3P * 80) / 100;
        } else return (feeL3P * 60) / 100;
    }
}



pragma solidity 0.8.13;




contract PackFactory is Ownable {
    address[] public customCollectionList; // Array containing all created pack collections addresses
    mapping(string => address) public getCustomCollection; // Map custom Collection address per token symbol

    uint256 public feeETH = 0 ether; // Fees passed to each custom collection. Charged per pack if paid in native (ETH, MATIC, BNB)
    uint256 public feeL3P = 0; // Fees passed to each custom collection. Charged per pack if paid in L3P (default === 100 L3P)

    event NewCustomCollectionCreated(
        address owner,
        address indexed newCustomCollection,
        string indexed newNFT,
        string indexed newNFTsymbol,
        uint256 customCollection_id
    );

    function createCustomCollection(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        string memory _baseURIextended
    ) external returns (address) {
        require(
            getCustomCollection[_symbol] == address(0),
            "Collection exist already"
        );

        address newCustomCollection = address(
            new CustomAssemblyNFT(
                _name,
                _symbol,
                _maxSupply,
                _baseURIextended,
                feeETH,
                feeL3P,
                msg.sender
            )
        ); // call the ERC721 constructor to create a new custom collection

        getCustomCollection[_symbol] = newCustomCollection;
        customCollectionList.push(newCustomCollection);

        emit NewCustomCollectionCreated(
            msg.sender,
            newCustomCollection,
            _name,
            _symbol,
            customCollectionList.length
        );
        return newCustomCollection;
    }

    function getCustomCollectionAddress(string memory _NftSymbol)
        external
        view
        returns (address)
    {
        return getCustomCollection[_NftSymbol];
    }

    function numberOfCustomCollections() external view returns (uint256) {
        return customCollectionList.length;
    }

    function setFeeETH(uint256 _newEthFee) external onlyOwner {
        feeETH = _newEthFee;
    }

    function setFeeL3P(uint256 _newL3PFee) external onlyOwner {
        feeL3P = _newL3PFee;
    }
}