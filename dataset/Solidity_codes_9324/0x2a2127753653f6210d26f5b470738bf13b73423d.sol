
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

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


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

pragma solidity ^0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


interface IAmulet is IERC1155, IERC1155MetadataURI {

    event AmuletRevealed(uint256 indexed tokenId, address revealedBy, string title, string amulet, string offsetUrl);

    struct MintData {
        address owner;
        uint256 tokenId;
    }

    struct RevealData {
        string title;
        string amulet;
        string offsetURL;
    }

    struct MintAndRevealData {
        string title;
        string amulet;
        string offsetURL;
        address owner;
    }

    function ownerOf(uint256 id) external view returns(address);


    function getScore(string calldata amulet) external pure returns(uint32);


    function isRevealed(uint256 tokenId) external view returns(bool);


    function mint(MintData calldata data) external;


    function mintAll(MintData[] calldata data) external;


    function reveal(RevealData calldata data) external;


    function revealAll(RevealData[] calldata data) external;


    function mintAndReveal(MintAndRevealData calldata data) external;


    function mintAndRevealAll(MintAndRevealData[] calldata data) external;


    function getData(uint256 tokenId) external view returns(address owner, uint64 blockRevealed, uint32 score);

}// MIT

pragma solidity ^0.8.0;

contract ProxyRegistry {

    mapping(address => address) public proxies;
}

contract ProxyRegistryWhitelist {

    ProxyRegistry public proxyRegistry;

    constructor(address proxyRegistryAddress) {
        proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    }

    function isProxyForOwner(address owner, address caller) internal view returns(bool) {

        if(address(proxyRegistry) == address(0)) {
            return false;
        }
        return proxyRegistry.proxies(owner) == caller;
    }
}// MIT

pragma solidity ^0.8.0;


contract Amulet is IAmulet, ERC165, ProxyRegistryWhitelist {

    using Address for address;

    mapping (uint256 => uint256) private _tokens;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    constructor (address proxyRegistryAddress, MintData[] memory premineMints, MintAndRevealData[] memory premineReveals) ProxyRegistryWhitelist(proxyRegistryAddress) {
        mintAll(premineMints);
        mintAndRevealAll(premineReveals);
    }


    function contractURI() external pure returns (string memory) {

        return "https://at.amulet.garden/contract.json";
    }

    function name() public view virtual returns (string memory) {

        return "Amulets";
    }

    function symbol() public view virtual returns (string memory) {

        return "AMULET";
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return interfaceId == type(IERC1155).interfaceId
            || interfaceId == type(IERC1155MetadataURI).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function uri(uint256 /*tokenId*/) public view virtual override returns (string memory) {

        return "https://at.amulet.garden/token/{id}.json";
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        (address owner,,) = getData(id);
        if(owner == account) {
            return 1;
        }
        return 0;
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

        require(msg.sender != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator] || isProxyForOwner(account, operator);
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
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ERC1155: caller is not owner nor approved"
        );

        (address oldOwner, uint64 blockRevealed, uint32 score) = getData(id);
        require(amount == 1 && oldOwner == from, "ERC1155: Insufficient balance for transfer");
        setData(id, to, blockRevealed, score);

        emit TransferSingle(msg.sender, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(msg.sender, from, to, id, amount, data);
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
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ERC1155: transfer caller is not owner nor approved"
        );

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            (address oldOwner, uint64 blockRevealed, uint32 score) = getData(id);
            require(amount == 1 && oldOwner == from, "ERC1155: insufficient balance for transfer");
            setData(id, to, blockRevealed, score);
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, amounts, data);
    }


    function ownerOf(uint256 id) external override view returns(address) {

        (address owner,,) = getData(id);
        return owner;
    }


    function getScore(string memory amulet) public override pure returns(uint32) {

        uint256 hash = uint256(sha256(bytes(amulet)));
        uint maxlen = 0;
        uint len = 0;
        for(;hash > 0; hash >>= 4) {
            if(hash & 0xF == 8) {
                len += 1;
                if(len > maxlen) {
                    maxlen = len;
                }
            } else {
                len = 0;
            }
        }
        return uint32(maxlen);        
    }

    function isRevealed(uint256 tokenId) external override view returns(bool) {

        (address owner, uint64 blockRevealed,) = getData(tokenId);
        require(owner != address(0), "ERC721: isRevealed query for nonexistent token");
        return blockRevealed > 0;
    }

    function mint(MintData memory data) public override {

        require(data.owner != address(0), "ERC1155: mint to the zero address");
        require(_tokens[data.tokenId] == 0, "ERC1155: mint of existing token");

        _tokens[data.tokenId] = uint256(uint160(data.owner));
        emit TransferSingle(msg.sender, address(0), data.owner, data.tokenId, 1);

        _doSafeTransferAcceptanceCheck(msg.sender, address(0), data.owner, data.tokenId, 1, "");
    }

    function mintAll(MintData[] memory data) public override {

        for(uint i = 0; i < data.length; i++) {
            mint(data[i]);
        }
    }

    function reveal(RevealData calldata data) public override {

        require(bytes(data.amulet).length <= 64, "Amulet: Too long");
        uint256 tokenId = uint256(keccak256(bytes(data.amulet)));
        (address owner, uint64 blockRevealed, uint32 score) = getData(tokenId);
        require(
            owner == msg.sender || isApprovedForAll(owner, msg.sender),
            "Amulet: reveal caller is not owner nor approved"
        );
        require(blockRevealed == 0, "Amulet: Already revealed");

        score = getScore(data.amulet);
        require(score >= 4, "Amulet: Score too low");

        setData(tokenId, owner, uint64(block.number), score);
        emit AmuletRevealed(tokenId, msg.sender, data.title, data.amulet, data.offsetURL);
    }

    function revealAll(RevealData[] calldata data) external override {

        for(uint i = 0; i < data.length; i++) {
            reveal(data[i]);
        }
    }

    function mintAndReveal(MintAndRevealData memory data) public override {

        require(bytes(data.amulet).length <= 64, "Amulet: Too long");
        uint256 tokenId = uint256(keccak256(bytes(data.amulet)));
        (address owner,,) = getData(tokenId);
        require(owner == address(0), "ERC1155: mint of existing token");
        require(data.owner != address(0), "ERC1155: mint to the zero address");

        uint32 score = getScore(data.amulet);
        require(score >= 4, "Amulet: Score too low");

        setData(tokenId, data.owner, uint64(block.number), score);
        emit TransferSingle(msg.sender, address(0), data.owner, tokenId, 1);
        emit AmuletRevealed(tokenId, msg.sender, data.title, data.amulet, data.offsetURL);
    }

    function mintAndRevealAll(MintAndRevealData[] memory data) public override {

        for(uint i = 0; i < data.length; i++) {
            mintAndReveal(data[i]);
        }
    }

    function getData(uint256 tokenId) public override view returns(address owner, uint64 blockRevealed, uint32 score) {

        uint256 t = _tokens[tokenId];
        owner = address(uint160(t));
        blockRevealed = uint64(t >> 160);
        score = uint32(t >> 224);
    }

    function setData(uint256 tokenId, address owner, uint64 blockRevealed, uint32 score) internal {

        _tokens[tokenId] = uint256(uint160(owner)) | (uint256(blockRevealed) << 160) | (uint256(score) << 224);
    }


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
}