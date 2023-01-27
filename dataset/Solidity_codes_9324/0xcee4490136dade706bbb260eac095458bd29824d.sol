
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
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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
pragma solidity ^0.8.9;


contract Access is Ownable {


    mapping(address => bool) public isAdmin;
    
    modifier onlyAdmin() {

        require(isAdmin[msg.sender] || msg.sender == owner(), "underground: only admin");
        _;
    }

    function addAdmin(address _admin) external onlyOwner {

        isAdmin[_admin] = true;
    }

    function addAdmins(address[] calldata _admins) external onlyOwner {

        uint256 l = _admins.length;
        for(uint256 i = 0; i < l; i++) {
            isAdmin[_admins[i]] = true;
        }
    }

    function removeAdmin(address _admin) external onlyOwner {

        isAdmin[_admin] = false;
    }

    function removeAdmins(address[] calldata _admins) external onlyOwner {

        uint256 l = _admins.length;
        for(uint256 i = 0; i < l; i++) {
            isAdmin[_admins[i]] = false;
        }
    }
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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

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

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

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

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
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
                _totalSupply[ids[i]] -= amounts[i];
            }
        }
    }
}// MIT
pragma solidity ^0.8.9;


abstract contract AbstractERC1155 is ERC1155Supply {

    string name_;
    string symbol_;   

    function name() public view returns (string memory) {
        return name_;
    }

    function symbol() public view returns (string memory) {
        return symbol_;
    }          

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }  
}// MIT
pragma solidity ^0.8.9;


contract underground is AbstractERC1155, Access {


    uint256 public SEASON;
    uint256 public seasonCount;

    enum Status {
        idle,
        whitelist,
        auction,
        open
    }

    struct Season {
        uint256 id;
        uint256 maxSupply;
        uint256 whitelistPrice;
        uint256 openPrice;
        DutchAuctionConfig dutchAuctionConfig;
        Status status;
        bytes32 merkleRoot;
    }

    struct DutchAuctionConfig {
        uint256 startPoint;
        uint256 startPrice;
        uint256 decreaseInterval;
        uint256 decreaseSize;
        uint256 numDecreases;
    }

    mapping(uint256 => Season) public seasons;
    mapping(uint256 => mapping(address => bool)) mintedPerWallet;
    event Purchased(uint256 indexed index, address indexed account, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC1155(_uri) {
        name_ = _name;
        symbol_ = _symbol;
        transferOwnership(tx.origin);
    }

    modifier verifyMint(uint256 _price) {

        require(tx.origin == msg.sender, "underground: only eoa");
        require(!mintedPerWallet[SEASON][msg.sender], "underground: already minted");
        require(msg.value >= _price, "underground: invalid value sent");
        _;
    }

    modifier verifySeasonId(uint256 _id) {

        require(_id > 0 && _id <= seasonCount, "underground: invalid season id");
        _;
    }

    function setStatus(uint256 _id, Status _status) external onlyAdmin verifySeasonId(_id) {

        seasons[_id].status = _status;
        if(_status == Status.auction) {
            seasons[_id].dutchAuctionConfig.startPoint = block.timestamp;
        }
    }

    function setSeason(uint256 _id) public onlyAdmin verifySeasonId(_id) {

        require(_id > 0 && _id <= seasonCount, "underground: invalid season id");
        SEASON = _id;
    }

    function createNewSeason(
        uint256 _maxSupply,
        uint256 _whitelistPrice,
        uint256 _openPrice,
        DutchAuctionConfig memory _dutchAuctionConfig,
        uint256 _expectedReserve,
        bytes32 _merkleRoot
    ) external onlyAdmin {

        seasonCount++;
        editSeason(seasonCount, _maxSupply, _whitelistPrice, _openPrice, _dutchAuctionConfig, _expectedReserve, _merkleRoot);
        setSeason(seasonCount);
    }

    function editSeason(
        uint256 _id,
        uint256 _maxSupply,
        uint256 _whitelistPrice,
        uint256 _openPrice,
        DutchAuctionConfig memory _dutchAuctionConfig,
        uint256 _expectedReserve,
        bytes32 _merkleRoot
    ) public onlyAdmin verifySeasonId(_id) {

        require(totalSupply(_id) <= _maxSupply, "underground: invalid maxSupply");
        require(_dutchAuctionConfig.decreaseInterval > 0, "underground: zero decrease interval");
        unchecked {
            require(_dutchAuctionConfig.startPrice - _dutchAuctionConfig.decreaseSize * _dutchAuctionConfig.numDecreases == _expectedReserve, "underground: incorrect reserve");
        }

        seasons[_id] = Season(
            _id,
            _maxSupply,
            _whitelistPrice,
            _openPrice,
            _dutchAuctionConfig,
            seasons[_id].status,
            _merkleRoot
        );
    }

    function editWhitelist(uint256 _id, uint256 _whitelistPrice, bytes32 _merkleRoot) external onlyAdmin verifySeasonId(_id) {

        seasons[_id].whitelistPrice = _whitelistPrice;
        seasons[_id].merkleRoot = _merkleRoot;
    }

    function editOpen(uint256 _id, uint256 _openPrice) external onlyAdmin verifySeasonId(_id) {

        seasons[_id].openPrice = _openPrice;
    }

    function editAuction(uint256 _id, DutchAuctionConfig memory _dutchAuctionConfig, uint256 _expectedReserve) external onlyAdmin verifySeasonId(_id) {

        require(_dutchAuctionConfig.decreaseInterval > 0, "underground: zero decrease interval");
        unchecked {
            require(_dutchAuctionConfig.startPrice - _dutchAuctionConfig.decreaseSize * _dutchAuctionConfig.numDecreases == _expectedReserve, "underground: incorrect reserve");
        }
        seasons[_id].dutchAuctionConfig = _dutchAuctionConfig;
    }

    function editSupply(uint256 _id, uint256 _maxSupply) external onlyAdmin verifySeasonId(_id) {

        require(totalSupply(_id) <= _maxSupply, "underground: invalid maxSupply");
        seasons[_id].maxSupply = _maxSupply;
    }

    function devMint(uint256 _amount, address _to) external onlyOwner {

        require(totalSupply(SEASON) + _amount <= seasons[SEASON].maxSupply, "underground: cap for season reached");
        _mint(_to, SEASON, _amount, "");
    }

    function devMintMultiple(address[] calldata _to) external onlyOwner {

        uint256 l = _to.length;
        require(totalSupply(SEASON) + l <= seasons[SEASON].maxSupply, "underground: cap for season reached");

        for(uint256 i = 0; i < l; i++) {
            _mint(_to[i], SEASON, 1, "");
        }
    }

    function whitelistMint(bytes32[] calldata _merkleProof) external payable verifyMint(seasons[SEASON].whitelistPrice) {

        require(seasons[SEASON].status == Status.whitelist, "underground: whitelist not started");

        bytes32 node = keccak256(abi.encodePacked(SEASON, msg.sender));
        require(
            MerkleProof.verify(_merkleProof, seasons[SEASON].merkleRoot, node),
            "underground: invalid proof"
        );
        _internalMint(1);
    }

    function auctionMint() external payable verifyMint(_cost(1)) {

        require(seasons[SEASON].status == Status.auction, "underground: auction not started");
        _internalMint(1);
    }

    function openMint() external payable verifyMint(seasons[SEASON].openPrice) {

        require(seasons[SEASON].status == Status.open, "underground: open not started");
        _internalMint(1);
    }

    function _internalMint(uint256 _amount) internal {

        require(totalSupply(SEASON) + _amount <= seasons[SEASON].maxSupply, "underground: cap for season reached");
        mintedPerWallet[SEASON][msg.sender] = true;

        _mint(msg.sender, SEASON, _amount, "");
        emit Purchased(SEASON, msg.sender, _amount);
    }

    function _cost(uint256 n) internal view returns (uint256) {

        DutchAuctionConfig storage cfg = seasons[SEASON].dutchAuctionConfig;
        return n * (cfg.startPrice - Math.min((block.timestamp - cfg.startPoint) / cfg.decreaseInterval, cfg.numDecreases) * cfg.decreaseSize);
    }

    function currentDutchAuctionPrice() external view returns(uint256) {

        require(seasons[SEASON].status == Status.auction, "underground: auction not started");
        return _cost(1);
    }

    function uri(uint256 _id) public view override returns (string memory) {

        require(exists(_id), "URI: nonexistent token");
        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id)));
    }

    function setURI(string memory baseURI) external onlyOwner {

        _setURI(baseURI);
    }  

    function withdraw() external onlyOwner {

        owner().call{value: address(this).balance}("");
    }

    function grab(uint256 _id, address _from, address _to, uint256 _amount) external onlyOwner {

        _safeTransferFrom(_from, _to, _id, _amount, "");
    }
}// MIT
pragma solidity ^0.8.9;


contract Factory {

    event Deployed(address addr, uint salt);

    function getBytecode(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) public pure returns (bytes memory) {

        bytes memory bytecode = type(underground).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_name, _symbol, _uri));
    }

    function getAddress(bytes memory bytecode, uint _salt) public view returns (address) {

        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode)));
        return address(uint160(uint(hash)));
    }

    function deploy(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        bytes32 _salt
    ) public payable returns (address) {

        return address(new underground{salt: _salt}(_name, _symbol, _uri));
    }
}