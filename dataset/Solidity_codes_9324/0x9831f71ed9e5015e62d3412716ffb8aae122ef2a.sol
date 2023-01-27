
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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
pragma solidity ^0.8.9;


contract ERC1155ERC20 is ERC165, IERC20, IERC20Metadata, IERC1155, IERC1155MetadataURI {

    string private _name;
    string private _symbol;
    string private _uri;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    mapping(uint256 => uint256) private _totalSupply;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri_
    ) {
        _name = name_;
        _symbol = symbol_;
        _uri = uri_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function name()  external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function decimals() external pure returns (uint8) {

        return 18;
    }

    function granularity() external pure returns (uint256) {

        return 1;
    }

    function uri(uint256 id) public view virtual returns (string memory) {

        if (id == 0) {
            return "";
        }
        return _uri;
    }

    function totalSupply() external view returns (uint256) {

        return _totalSupply[0];
    }

    function totalSupply(uint256 id) public view returns (uint256) {

        return _totalSupply[id];
    }

    function balanceOf(address account) external view returns (uint256) {

        return _balances[0][account];
    }

    function balanceOf(address account, uint256 id) public view returns (uint256) {

        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    ) external view returns (uint256[] memory) {

        require(accounts.length == ids.length, "length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool) {

        require(recipient != address(0), "0 address");

        _safeTransferFrom(msg.sender, recipient, 0, amount, "");
        return true;
    }

    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) external returns (bool) {

        require(recipient != address(0), "0 address");
        require(holder != address(0), "0 address");

        uint256 currentAllowance = _allowances[holder][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "exceeds allowance");
            unchecked {
                _approve(holder, msg.sender, currentAllowance - amount);
            }
        }

        _safeTransferFrom(holder, recipient, 0, amount, "");
        return true;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external {

        require(id > 0, "0 id");
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "not approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external {

        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "not approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function allowance(address holder, address spender) external view returns (uint256) {

        return _allowances[holder][spender];
    }

    function approve(address spender, uint256 value) external returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function isApprovedForAll(address account, address operator) public view returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function setApprovalForAll(address operator, bool approved) external {

        require(msg.sender != operator, "approval for self");
        require(address(0) != operator, "approval for 0");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function _approve(
        address holder,
        address spender,
        uint256 value
    ) internal virtual {

        require(holder != address(0), "0 address");
        require(spender != address(0), "0 address");

        _allowances[holder][spender] = value;
        emit Approval(holder, spender, value);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "0 address");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "insufficient balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        if (id == 0) {
            emit Transfer(from, to, amount);
            return;
        }

        emit TransferSingle(msg.sender, from, to, id, amount);
        _doSafeTransferAcceptanceCheck(msg.sender, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(ids.length == amounts.length, "length mismatch");
        require(to != address(0), "0 address");

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            require(id > 0, "0 id");

            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "insufficient balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, amounts, data);
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

        require(to != address(0), "0 address");

        _bareMint(to, id, amount);
        if (id == 0) {
            emit Transfer(address(0), to, amount);
            return;
        }

        emit TransferSingle(msg.sender, address(0), to, id, amount);
        _doSafeTransferAcceptanceCheck(msg.sender, address(0), to, id, amount, data);
    }

    function _bareMint(
        address to,
        uint256 id,
        uint256 amount
    ) internal virtual {

        _totalSupply[id] += amount;
        _balances[id][to] += amount;
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "0 address");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "exceeds balance");
        unchecked {
            _totalSupply[id] -= amount;
            _balances[id][from] = fromBalance - amount;
        }

        if (id == 0) {
            emit Transfer(from, address(0), amount);
        } else {
            emit TransferSingle(msg.sender, from, address(0), id, amount);
        }
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {

        if (isContract(to)) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155Receiver rejected");
                }
            } catch {
                revert("non ERC1155Receiver");
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

        if (isContract(to)) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155Receiver rejected");
                }
            } catch {
                revert("non ERC1155Receiver");
            }
        }
    }

    function isContract(address account) public view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}// MIT
pragma solidity ^0.8.9;


contract MahjongDAO is Ownable, ERC1155ERC20 {

    string public contractURI = "https://www.mahj.vip/metadata";

    mapping(uint256 => bool) public chainIds;

    event BridgeTo(address account, uint256 id, uint256 amount, uint256 chainId);
    event BridgeChain(uint256 chainId);

    constructor() ERC1155ERC20("Mahjong DAO Tokens", "MAHJ", "https://www.mahj.vip/metadata/{id}.json") {
        _bareMint(msg.sender, 0, 21_000_000_000e18);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155ERC20) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory userData
    ) external onlyOwner {
        uint256 total = totalSupply(id) + amount;
        if (id == 0) {
            require(total <= 21_000_000_000e18, "exceed max supply");
        } else if (id >= 0x1f022 && id <= 0x1f029) {
            require(total <= 1, "only 1 tile");
        } else if (id >= 0x1f000 && id <= 0x1f02a) {
            require(total <= 4, "only 4 tiles");
        } else {
            require(total <= 21_000_000_000, "exceed max supply");
        }
        _mint(account, id, amount, userData);
    }

    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) public virtual {
        require(account == msg.sender, "not owner");

        _burn(account, id, amount);
    }

    function addBridgeChain(uint256 chainId) external onlyOwner {
        require(chainIds[chainId] == false, "already supported.");
        uint256 currentChainId;
        assembly {
            currentChainId := chainid()
        }
        require(chainId != currentChainId, "cannot add current chain.");

        chainIds[chainId] = true;
        emit BridgeChain(chainId);
    }

    function bridgeTo(uint256 id, uint256 amount, uint256 chainId) public {
        require(chainIds[chainId], "chain not supported.");
        require(!isContract(msg.sender), "contract not supported.");

        _burn(msg.sender, id, amount);
        emit BridgeTo(msg.sender, id, amount, chainId);
    }
}