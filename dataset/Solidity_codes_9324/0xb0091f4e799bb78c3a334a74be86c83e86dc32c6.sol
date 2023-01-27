
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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;

contract TokenInventories {

    uint256 constant MAX_SUPPLY = 10101;
    uint256 constant MAX_SUPPLY_EQ = MAX_SUPPLY + 1;

    uint16[] private _vacantInventories;
    address[] private _inventoryToOwner;
    mapping(address => uint256) private _ownerToInventory;

    constructor() {
        _inventoryToOwner.push(address(0));
    }

    function _getInventoryOwner(uint256 inventory)
        internal
        view
        returns (address)
    {

        return _inventoryToOwner[inventory];
    }

    function _getInventoryId(address owner) internal view returns (uint256) {

        return _ownerToInventory[owner] & 0xFFFF;
    }

    function _getBalance(address owner) internal view returns (uint256) {

        return _ownerToInventory[owner] >> 16;
    }

    function _setBalance(address owner, uint256 balance) internal {

        _ownerToInventory[owner] = _getInventoryId(owner) | (balance << 16);
    }

    function _increaseBalance(address owner, uint256 count) internal {

        unchecked {
            _setBalance(owner, _getBalance(owner) + count);
        }
    }

    function _decreaseBalance(address owner, uint256 count) internal {

        uint256 balance = _getBalance(owner);
        
        if (balance == count) {
            _unsubscribeInventory(owner);
        } else {
            unchecked {
                _setBalance(owner, balance - count);
            }
        }
    }

    function _getOrSubscribeInventory(address owner)
        internal
        returns (uint256)
    {

        uint256 id = _getInventoryId(owner);
        return id == 0 ? _subscribeInventory(owner) : id;
    }

    function _subscribeInventory(address owner) private returns (uint256) {

        if (_inventoryToOwner.length < MAX_SUPPLY_EQ) {
            _ownerToInventory[owner] = _inventoryToOwner.length;
            _inventoryToOwner.push(owner);
        } else if (_vacantInventories.length > 0) {
            unchecked {
                uint256 id = _vacantInventories[_vacantInventories.length - 1];
                _vacantInventories.pop();
                _ownerToInventory[owner] = id;
                _inventoryToOwner[id] = owner;
            }
        }
        return _ownerToInventory[owner];
    }

    function _unsubscribeInventory(address owner) private {

        uint256 id = _getInventoryId(owner);
        delete _ownerToInventory[owner];
        delete _inventoryToOwner[id];
        _vacantInventories.push(uint16(id));
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Enumerable is
    Context,
    TokenInventories,
    ERC165,
    IERC721Enumerable
{
    using Address for address;

    uint256 public maxSupply;

    uint256 public burned;

    uint16[MAX_SUPPLY] internal _tokenToInventory;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    modifier tokenExists(uint256 tokenId) {
        require(
            _exists(tokenId),
            "ERC721Enumerable: query for nonexistent token"
        );
        _;
    }

    modifier onlyApprovedOrOwner(uint256 tokenId) {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Enumerable: caller is not owner nor approved"
        );
        _;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function totalSupply() public view override returns (uint256) {
        return maxSupply - burned;
    }

    function tokenByIndex(uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index < totalSupply(),
            "ERC721Enumerable: global index out of bounds"
        );

        uint256 i;
        for (uint256 j; true; i++) {
            if (_tokenToInventory[i] != 0 && j++ == index) {
                break;
            }
        }

        return i;
    }

    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner != address(0),
            "ERC721Enumerable: balance query for the zero address"
        );
        return _getBalance(owner);
    }

    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        tokenExists(tokenId)
        returns (address)
    {
        return _getInventoryOwner(_tokenToInventory[tokenId]);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index < balanceOf(owner),
            "ERC721Enumerable: index query for nonexistent token"
        );

        uint256 i;
        for (uint256 count; count <= index; i++) {
            if (_getInventoryOwner(_tokenToInventory[i]) == owner) {
                count++;
            }
        }

        return i - 1;
    }

    function walletOfOwner(address owner)
        public
        view
        virtual
        returns (uint256[] memory)
    {
        uint256 balance = balanceOf(owner);
        if (balance == 0) {
            return new uint256[](0);
        }

        uint256[] memory tokens = new uint256[](balance);
        for (uint256 j; balance > 0; j++) {
            if (ownerOf(j) == owner) {
                tokens[tokens.length - balance--] = j;
            }
        }
        return tokens;
    }

    function isOwnerOf(address owner, uint256[] memory tokenIds)
        public
        view
        virtual
        returns (bool)
    {
        for (uint256 i; i < tokenIds.length; i++) {
            if (ownerOf(tokenIds[i]) != owner) {
                return false;
            }
        }

        return true;
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721Enumerable: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721Enumerable: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        tokenExists(tokenId)
        returns (address)
    {
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override onlyApprovedOrOwner(tokenId) {
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
    ) public virtual override onlyApprovedOrOwner(tokenId) {
        _safeTransfer(from, to, tokenId, _data);
    }

    function batchTransferFrom(
        address from,
        address to,
        uint256[] memory tokenIds
    ) public virtual {
        for (uint256 i; i < tokenIds.length; i++) {
            transferFrom(from, to, tokenIds[i]);
        }
    }

    function batchSafeTransferFrom(
        address from,
        address to,
        uint256[] memory tokenIds,
        bytes memory data_
    ) public virtual {
        for (uint256 i; i < tokenIds.length; i++) {
            safeTransferFrom(from, to, tokenIds[i], data_);
        }
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721Enumerable: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return tokenId < MAX_SUPPLY && _tokenToInventory[tokenId] != 0;
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        tokenExists(tokenId)
        returns (bool)
    {
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _approve(address(0), tokenId);

        delete _tokenToInventory[tokenId];
        _decreaseBalance(owner, 1);
        burned++;

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(
            ownerOf(tokenId) == from,
            "ERC721Enumerable: transfer from incorrect owner"
        );
        require(
            to != address(0),
            "ERC721Enumerable: transfer to the zero address"
        );

        _approve(address(0), tokenId);

        _decreaseBalance(from, 1);
        _tokenToInventory[tokenId] = uint16(_getOrSubscribeInventory(to));
        _increaseBalance(to, 1);

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721Enumerable: approve to caller");
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
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721Enumerable: transfer to non ERC721Receiver implementer"
                    );
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
}// MIT

pragma solidity ^0.8.0;

interface IMutationRegistry {

    struct Mutation {
        bool enabled;
        bool finalized;
        uint8 prev;
        uint8 next;
        uint8 geneCount;
        address interpreter;
        uint256 cost;
    }

    function getMutation(uint256 mutationId)
        external
        view
        returns (Mutation memory);

}// MIT

pragma solidity ^0.8.0;


interface IERC721GeneticData is IERC721Enumerable, IMutationRegistry {

    event UnlockMutation(uint256 tokenId, uint256 mutationId);
    event Mutate(uint256 tokenId, uint256 mutationId);

    function getTokenMutation(uint256 tokenId) external view returns (uint256);


    function getTokenDNA(uint256 tokenId)
        external
        view
        returns (uint256[] memory);


    function getTokenDNA(uint256 tokenId, uint256[] memory splices)
        external
        view
        returns (uint256[] memory);


    function countTokenMutations(uint256 tokenId)
        external
        view
        returns (uint256);


    function isMutationUnlocked(uint256 tokenId, uint256 mutationId)
        external
        view
        returns (bool);


    function canMutate(uint256 tokenId, uint256 mutationId)
        external
        view
        returns (bool);


    function safeCatalystUnlockMutation(
        uint256 tokenId,
        uint256 mutationId,
        bool force
    ) external;


    function catalystUnlockMutation(uint256 tokenId, uint256 mutationId)
        external;


    function safeCatalystMutate(uint256 tokenId, uint256 mutationId) external;


    function catalystMutate(uint256 tokenId, uint256 mutationId) external;


    function mutate(uint256 tokenId, uint256 mutationId) external payable;

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


contract MutationRegistry is Ownable, IMutationRegistry {

    uint256 constant MAX_MUTATIONS = 256;

    mapping(uint256 => Mutation) private _mutations;

    modifier mutationExists(uint256 mutationId) {

        require(
            _mutations[mutationId].interpreter != address(0),
            "MutationRegistry: query for nonexistent mutation"
        );
        _;
    }

    constructor(address interpreter) {
        loadMutation(0, true, false, 0, 0, 0, interpreter, 0);
    }

    function getMutation(uint256 mutationId)
        public
        view
        override
        returns (Mutation memory)
    {

        return _mutations[mutationId];
    }

    function loadMutation(
        uint8 mutationId,
        bool enabled,
        bool finalized,
        uint8 prev,
        uint8 next,
        uint8 geneCount,
        address interpreter,
        uint256 cost
    ) public onlyOwner {

        require(
            _mutations[mutationId].interpreter == address(0),
            "MutationRegistry: load to existing mutation"
        );

        require(
            interpreter != address(0),
            "MutationRegistry: invalid interpreter"
        );

        _mutations[mutationId] = Mutation(
            enabled,
            finalized,
            prev,
            next,
            geneCount,
            interpreter,
            cost
        );
    }

    function toggleMutation(uint256 mutationId)
        external
        onlyOwner
        mutationExists(mutationId)
    {

        Mutation storage mutation = _mutations[mutationId];

        require(
            !mutation.finalized,
            "MutationRegistry: toggle to finalized mutation"
        );

        mutation.enabled = !mutation.enabled;
    }

    function finalizeMutation(uint256 mutationId)
        external
        onlyOwner
        mutationExists(mutationId)
    {

        _mutations[mutationId].finalized = true;
    }

    function updateMutationInterpreter(uint256 mutationId, address interpreter)
        external
        onlyOwner
        mutationExists(mutationId)
    {

        Mutation storage mutation = _mutations[mutationId];

        require(
            interpreter != address(0),
            "MutationRegistry: zero address interpreter"
        );

        require(
            !mutation.finalized,
            "MutationRegistry: update to finalized mutation"
        );

        mutation.interpreter = interpreter;
    }

    function updateMutationLinks(
        uint8 mutationId,
        uint8 prevMutationId,
        uint8 nextMutationId
    ) external onlyOwner mutationExists(mutationId) {

        Mutation storage mutation = _mutations[mutationId];

        require(
            !mutation.finalized,
            "MutationRegistry: update to finalized mutation"
        );

        mutation.prev = prevMutationId;
        mutation.next = nextMutationId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721GeneticData is
    ERC721Enumerable,
    MutationRegistry,
    IERC721GeneticData
{
    uint64[MAX_SUPPLY] internal _tokenBaseGenes;

    uint8[][MAX_SUPPLY] private _tokenExtendedGenes;

    uint8[MAX_SUPPLY] private _tokenMutation;

    bool[MAX_MUTATIONS][MAX_SUPPLY] public tokenUnlockedMutations;

    mapping(address => bool) public mutationCatalysts;

    modifier onlyMutationCatalyst() {
        require(
            mutationCatalysts[_msgSender()],
            "ERC721GeneticData: caller is not catalyst"
        );
        _;
    }

    function getTokenMutation(uint256 tokenId)
        public
        view
        override
        tokenExists(tokenId)
        returns (uint256)
    {
        return _tokenMutation[tokenId];
    }

    function getTokenDNA(uint256 tokenId)
        public
        view
        override
        returns (uint256[] memory)
    {
        uint256[] memory splices;
        return getTokenDNA(tokenId, splices);
    }

    function getTokenDNA(uint256 tokenId, uint256[] memory splices)
        public
        view
        override
        tokenExists(tokenId)
        returns (uint256[] memory)
    {
        uint8[] memory genes = _tokenExtendedGenes[tokenId];
        uint256 geneCount = genes.length;
        uint256 spliceCount = splices.length;
        uint256[] memory dna = new uint256[](geneCount + 1);
        dna[0] = uint256(keccak256(abi.encodePacked(_tokenBaseGenes[tokenId])));

        for (uint256 i; i < geneCount; i++) {
            dna[i + 1] = uint256(keccak256(abi.encodePacked(dna[i], genes[i])));

            if (i < spliceCount) {
                dna[i] ^= splices[i];
            }
        }

        if (spliceCount == geneCount + 1) {
            dna[geneCount] ^= splices[geneCount];
        }

        return dna;
    }

    function countTokenMutations(uint256 tokenId)
        external
        view
        override
        tokenExists(tokenId)
        returns (uint256)
    {
        return _countTokenMutations(tokenId);
    }

    function isMutationUnlocked(uint256 tokenId, uint256 mutationId)
        external
        view
        override
        tokenExists(tokenId)
        mutationExists(mutationId)
        returns (bool)
    {
        return _isMutationUnlocked(tokenId, mutationId);
    }

    function canMutate(uint256 tokenId, uint256 mutationId)
        external
        view
        override
        tokenExists(tokenId)
        mutationExists(mutationId)
        returns (bool)
    {
        return _canMutate(tokenId, mutationId);
    }

    function toggleMutationCatalyst(address catalyst) external onlyOwner {
        mutationCatalysts[catalyst] = !mutationCatalysts[catalyst];
    }

    function safeCatalystUnlockMutation(
        uint256 tokenId,
        uint256 mutationId,
        bool force
    ) external override tokenExists(tokenId) mutationExists(mutationId) {
        require(
            !_isMutationUnlocked(tokenId, mutationId),
            "ERC721GeneticData: unlock to unlocked mutation"
        );
        require(
            force || _canMutate(tokenId, mutationId),
            "ERC721GeneticData: unlock to unavailable mutation"
        );

        catalystUnlockMutation(tokenId, mutationId);
    }

    function catalystUnlockMutation(uint256 tokenId, uint256 mutationId)
        public
        override
        onlyMutationCatalyst
    {
        _unlockMutation(tokenId, mutationId);
    }

    function safeCatalystMutate(uint256 tokenId, uint256 mutationId)
        external
        override
        tokenExists(tokenId)
        mutationExists(mutationId)
    {
        require(
            _tokenMutation[tokenId] != mutationId,
            "ERC721GeneticData: mutate to active mutation"
        );

        require(
            _isMutationUnlocked(tokenId, mutationId),
            "ERC721GeneticData: mutate to locked mutation"
        );

        catalystMutate(tokenId, mutationId);
    }

    function catalystMutate(uint256 tokenId, uint256 mutationId)
        public
        override
        onlyMutationCatalyst
    {
        _mutate(tokenId, mutationId);
    }

    function mutate(uint256 tokenId, uint256 mutationId)
        external
        payable
        override
        onlyApprovedOrOwner(tokenId)
        mutationExists(mutationId)
    {
        if (_isMutationUnlocked(tokenId, mutationId)) {
            require(
                _tokenMutation[tokenId] != mutationId,
                "ERC721GeneticData: mutate to active mutation"
            );
        } else {
            require(
                _canMutate(tokenId, mutationId),
                "ERC721GeneticData: mutate to unavailable mutation"
            );
            require(
                msg.value == getMutation(mutationId).cost,
                "ERC721GeneticData: incorrect amount of ether sent"
            );

            _unlockMutation(tokenId, mutationId);
        }

        _mutate(tokenId, mutationId);
    }

    function unclone(uint256 tokenA, uint256 tokenB) external onlyOwner {
        require(tokenA != tokenB, "ERC721GeneticData: unclone of same token");
        uint256 genesA = _tokenBaseGenes[tokenA];
        require(
            genesA == _tokenBaseGenes[tokenB],
            "ERC721GeneticData: unclone of uncloned tokens"
        );
        _tokenBaseGenes[tokenA] = uint64(bytes8(_getGenes(tokenA, genesA)));
    }

    function _countTokenMutations(uint256 tokenId)
        internal
        view
        returns (uint256)
    {
        uint256 count = 1;
        bool[MAX_MUTATIONS] memory mutations = tokenUnlockedMutations[tokenId];
        for (uint256 i = 1; i < MAX_MUTATIONS; i++) {
            if (mutations[i]) {
                count++;
            }
        }
        return count;
    }

    function _isMutationUnlocked(uint256 tokenId, uint256 mutationId)
        private
        view
        returns (bool)
    {
        return mutationId == 0 || tokenUnlockedMutations[tokenId][mutationId];
    }

    function _canMutate(uint256 tokenId, uint256 mutationId)
        private
        view
        returns (bool)
    {
        uint256 activeMutationId = _tokenMutation[tokenId];
        uint256 nextMutationId = getMutation(activeMutationId).next;
        Mutation memory mutation = getMutation(mutationId);

        return
            mutation.enabled &&
            (nextMutationId == 0 || nextMutationId == mutationId) &&
            (mutation.prev == 0 || mutation.prev == activeMutationId);
    }

    function _unlockMutation(uint256 tokenId, uint256 mutationId) private {
        tokenUnlockedMutations[tokenId][mutationId] = true;
        _addGenes(tokenId, getMutation(mutationId).geneCount);
        emit UnlockMutation(tokenId, mutationId);
    }

    function _mutate(uint256 tokenId, uint256 mutationId) private {
        _tokenMutation[tokenId] = uint8(mutationId);
        emit Mutate(tokenId, mutationId);
    }

    function _addGenes(uint256 tokenId, uint256 maxGeneCount) private {
        uint8[] storage genes = _tokenExtendedGenes[tokenId];
        uint256 geneCount = genes.length;
        bytes32 newGenes;
        while (geneCount < maxGeneCount) {
            if (newGenes == 0) {
                newGenes = _getGenes(tokenId, geneCount);
            }
            genes.push(uint8(bytes1(newGenes)));
            newGenes <<= 8;
            unchecked {
                geneCount++;
            }
        }
    }

    function _getGenes(uint256 tokenId, uint256 seed)
        private
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    tokenId,
                    seed,
                    ownerOf(tokenId),
                    block.number,
                    block.difficulty
                )
            );
    }

    function _burn(uint256 tokenId) internal override {
        delete _tokenMutation[tokenId];
        delete _tokenBaseGenes[tokenId];
        delete _tokenExtendedGenes[tokenId];
        delete tokenUnlockedMutations[tokenId];
        super._burn(tokenId);
    }
}// MIT

pragma solidity ^0.8.0;


contract Reservable is Ownable {

    uint256 public reserved;

    mapping(address => uint256) public allowances;

    modifier fromAllowance(uint256 count) {

        require(
            count > 0 && count <= allowances[_msgSender()] && count <= reserved,
            "Reservable: reserved tokens mismatch"
        );

        _;

        unchecked {
            allowances[_msgSender()] -= count;
            reserved -= count;
        }
    }

    constructor(uint256 reserved_) {
        reserved = reserved_;
    }

    function reserve(address[] calldata addresses, uint256[] calldata allowance)
        external
        onlyOwner
    {

        uint256 count = addresses.length;

        require(count == allowance.length, "Reservable: data mismatch");

        do {
            count--;
            allowances[addresses[count]] = allowance[count];
        } while (count > 0);
    }
}// MIT

pragma solidity ^0.8.0;


contract ProxyOperated is Ownable {

    address public proxyRegistryAddress;
    mapping(address => bool) public projectProxy;

    constructor(address proxy) {
        proxyRegistryAddress = proxy;
    }

    function toggleProxyState(address proxy) external onlyOwner {

        projectProxy[proxy] = !projectProxy[proxy];
    }

    function setProxyRegistryAddress(address proxy) external onlyOwner {

        proxyRegistryAddress = proxy;
    }

    function _isProxyApprovedForAll(address owner, address operator)
        internal
        view
        returns (bool)
    {

        bool isApproved;

        if (proxyRegistryAddress != address(0)) {
            OpenSeaProxyRegistry proxyRegistry = OpenSeaProxyRegistry(
                proxyRegistryAddress
            );
            isApproved = address(proxyRegistry.proxies(owner)) == operator;
        }

        return isApproved || projectProxy[operator];
    }
}

contract OwnableDelegateProxy {}


contract OpenSeaProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

interface IMutationInterpreter {

    struct TokenData {
        uint256 id;
        string name;
        string info;
        uint256[] dna;
    }

    struct MutationData {
        uint256 id;
        string name;
        string info;
        uint256 count;
    }

    function tokenURI(
        TokenData calldata token,
        MutationData calldata mutation,
        string calldata externalURL
    ) external view returns (string memory);

}// MIT

pragma solidity ^0.8.12;



interface ILabArchive {

    function getMutyteInfo(uint256 tokenId)
        external
        view
        returns (string memory name, string memory info);


    function getMutationInfo(uint256 mutationId)
        external
        view
        returns (string memory name, string memory info);

}

interface IBineticSplicer {

    function getSplices(uint256 tokenId)
        external
        view
        returns (uint256[] memory);

}

contract Mutytes is
    ERC721GeneticData,
    IERC721Metadata,
    Reservable,
    ProxyOperated
{

    string constant NAME = "Mutytes";
    string constant SYMBOL = "TYTE";
    uint256 constant MINT_PER_ADDR = 10;
    uint256 constant MINT_PER_ADDR_EQ = MINT_PER_ADDR + 1; // Skip the equator
    uint256 constant MINT_PRICE = 0.1 ether;

    address public labArchiveAddress;
    address public bineticSplicerAddress;
    string public externalURL;

    constructor(
        string memory externalURL_,
        address interpreter,
        address proxyRegistry,
        uint8 reserved
    )
        Reservable(reserved)
        ProxyOperated(proxyRegistry)
        MutationRegistry(interpreter)
    {
        externalURL = externalURL_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, IERC165)
        returns (bool)
    {

        return
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function mint(uint256 count) external payable {

        uint256 id = maxSupply;

        require(id > 0, "Mutytes: public mint not open");

        require(
            id + count < MAX_SUPPLY_EQ - reserved,
            "Mutytes: amount exceeds available supply"
        );

        require(
            count > 0 && _getBalance(_msgSender()) + count < MINT_PER_ADDR_EQ,
            "Mutytes: invalid token count"
        );

        require(
            msg.value == count * MINT_PRICE,
            "Mutytes: incorrect amount of ether sent"
        );

        _mint(_msgSender(), id, count);
    }

    function mintReserved(uint256 count) external fromAllowance(count) {

        _mint(_msgSender(), maxSupply, count);
    }

    function setLabArchiveAddress(address archive) external onlyOwner {

        labArchiveAddress = archive;
    }

    function setBineticSplicerAddress(address splicer) external onlyOwner {

        bineticSplicerAddress = splicer;
    }

    function setExternalURL(string calldata url) external onlyOwner {

        externalURL = url;
    }

    function name() public pure override returns (string memory) {

        return NAME;
    }

    function symbol() public pure override returns (string memory) {

        return SYMBOL;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        tokenExists(tokenId)
        returns (string memory)
    {

        uint256 mutationId = getTokenMutation(tokenId);
        IMutationInterpreter interpreter = IMutationInterpreter(
            getMutation(mutationId).interpreter
        );
        IMutationInterpreter.TokenData memory token;
        token.id = tokenId;
        IMutationInterpreter.MutationData memory mutation;
        mutation.id = mutationId;
        mutation.count = _countTokenMutations(tokenId);

        if (bineticSplicerAddress != address(0)) {
            IBineticSplicer splicer = IBineticSplicer(bineticSplicerAddress);
            token.dna = getTokenDNA(tokenId, splicer.getSplices(tokenId));
        } else {
            token.dna = getTokenDNA(tokenId);
        }

        if (labArchiveAddress != address(0)) {
            ILabArchive archive = ILabArchive(labArchiveAddress);
            (token.name, token.info) = archive.getMutyteInfo(tokenId);
            (mutation.name, mutation.info) = archive.getMutationInfo(
                mutationId
            );
        }

        return interpreter.tokenURI(token, mutation, externalURL);
    }

    function burn(uint256 tokenId) public onlyApprovedOrOwner(tokenId) {

        _burn(tokenId);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        override(ERC721Enumerable, IERC721)
        returns (bool)
    {

        return
            _isProxyApprovedForAll(owner, operator) ||
            super.isApprovedForAll(owner, operator);
    }

    function withdraw() public payable onlyOwner {

        (bool owner, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(owner, "Mutytes: withdrawal failed");
    }

    function _mint(
        address to,
        uint256 tokenId,
        uint256 count
    ) private {

        uint256 inventory = _getOrSubscribeInventory(to);
        bytes32 dna;

        unchecked {
            uint256 max = tokenId + count;
            while (tokenId < max) {
                if (dna == 0) {
                    dna = keccak256(
                        abi.encodePacked(
                            tokenId,
                            inventory,
                            block.number,
                            block.difficulty,
                            reserved
                        )
                    );
                }
                _tokenToInventory[tokenId] = uint16(inventory);
                _tokenBaseGenes[tokenId] = uint64(bytes8(dna));
                dna <<= 64;

                emit Transfer(address(0), to, tokenId++);
            }
        }

        _increaseBalance(to, count);
        maxSupply = tokenId;
    }
}