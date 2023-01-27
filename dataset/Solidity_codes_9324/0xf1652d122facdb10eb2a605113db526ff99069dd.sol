pragma solidity ^0.5.2;

contract Admin {


    address internal _admin;

    event AdminChanged(address oldAdmin, address newAdmin);

    function getAdmin() external view returns (address) {

        return _admin;
    }

    function changeAdmin(address newAdmin) external {

        require(msg.sender == _admin, "only admin can change admin");
        emit AdminChanged(_admin, newAdmin);
        _admin = newAdmin;
    }
}pragma solidity ^0.5.2;


contract SuperOperators is Admin {


    mapping(address => bool) internal _superOperators;

    event SuperOperator(address superOperator, bool enabled);

    function setSuperOperator(address superOperator, bool enabled) external {

        require(
            msg.sender == _admin,
            "only admin is allowed to add super operators"
        );
        _superOperators[superOperator] = enabled;
        emit SuperOperator(superOperator, enabled);
    }

    function isSuperOperator(address who) public view returns (bool) {

        return _superOperators[who];
    }
}pragma solidity ^0.5.2;

interface ERC1155 {


    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;


    function balanceOf(address owner, uint256 id)
        external
        view
        returns (uint256);


    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

}pragma solidity ^0.5.2;

interface ERC1155TokenReceiver {

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

}pragma solidity ^0.5.2;

interface ERC165 {

    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool);

}pragma solidity ^0.5.2;

interface ERC721Events {

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );
}pragma solidity ^0.5.2;


contract ERC721 is ERC165, ERC721Events {

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);


    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);


    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);


    function transferFrom(address from, address to, uint256 tokenId)
        external;

    function safeTransferFrom(address from, address to, uint256 tokenId)
        external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
pragma solidity ^0.5.2;

interface ERC721TokenReceiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}pragma solidity ^0.5.2;

library AddressUtils {


    function toPayable(address _address) internal pure returns (address payable _payable) {

        return address(uint160(_address));
    }

    function isContract(address addr) internal view returns (bool) {

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        bytes32 codehash;
        assembly {
            codehash := extcodehash(addr)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }
}pragma solidity ^0.5.2;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;
        assert(c >= a);
        return c;
    }
}pragma solidity ^0.5.2;


library ObjectLib32 {

    using SafeMath for uint256;
    enum Operations {ADD, SUB, REPLACE}
    uint256 constant TYPES_BITS_SIZE = 32; // Max size of each object
    uint256 constant TYPES_PER_UINT256 = 256 / TYPES_BITS_SIZE; // Number of types per uint256


    function getTokenBinIndex(uint256 tokenId)
        internal
        pure
        returns (uint256 bin, uint256 index)
    {

        bin = (tokenId * TYPES_BITS_SIZE) / 256;
        index = tokenId % TYPES_PER_UINT256;
        return (bin, index);
    }

    function updateTokenBalance(
        uint256 binBalances,
        uint256 index,
        uint256 amount,
        Operations operation
    ) internal pure returns (uint256 newBinBalance) {

        uint256 objectBalance = 0;
        if (operation == Operations.ADD) {
            objectBalance = getValueInBin(binBalances, index);
            newBinBalance = writeValueInBin(
                binBalances,
                index,
                objectBalance.add(amount)
            );
        } else if (operation == Operations.SUB) {
            objectBalance = getValueInBin(binBalances, index);
            require(objectBalance >= amount, "can't substract more than there is");
            newBinBalance = writeValueInBin(
                binBalances,
                index,
                objectBalance.sub(amount)
            );
        } else if (operation == Operations.REPLACE) {
            newBinBalance = writeValueInBin(binBalances, index, amount);
        } else {
            revert("Invalid operation"); // Bad operation
        }

        return newBinBalance;
    }
    function getValueInBin(uint256 binValue, uint256 index)
        internal
        pure
        returns (uint256)
    {

        uint256 mask = (uint256(1) << TYPES_BITS_SIZE) - 1;

        uint256 rightShift = 256 - TYPES_BITS_SIZE * (index + 1);
        return (binValue >> rightShift) & mask;
    }

    function writeValueInBin(uint256 binValue, uint256 index, uint256 amount)
        internal
        pure
        returns (uint256)
    {

        require(
            amount < 2**TYPES_BITS_SIZE,
            "Amount to write in bin is too large"
        );

        uint256 mask = (uint256(1) << TYPES_BITS_SIZE) - 1;

        uint256 leftShift = 256 - TYPES_BITS_SIZE * (index + 1);
        return (binValue & ~(mask << leftShift)) | (amount << leftShift);
    }

}pragma solidity 0.5.9;





contract ERC1155ERC721 is SuperOperators, ERC1155, ERC721 {

    using AddressUtils for address;
    using ObjectLib32 for ObjectLib32.Operations;
    using ObjectLib32 for uint256;

    bytes4 private constant ERC1155_IS_RECEIVER = 0x4e2312e0;
    bytes4 private constant ERC1155_RECEIVED = 0xf23a6e61;
    bytes4 private constant ERC1155_BATCH_RECEIVED = 0xbc197c81;
    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

    uint256 private constant CREATOR_OFFSET_MULTIPLIER = uint256(2)**(256 - 160);
    uint256 private constant IS_NFT_OFFSET_MULTIPLIER = uint256(2)**(256 - 160 - 1);
    uint256 private constant PACK_ID_OFFSET_MULTIPLIER = uint256(2)**(256 - 160 - 1 - 32 - 40);
    uint256 private constant PACK_NUM_FT_TYPES_OFFSET_MULTIPLIER = uint256(2)**(256 - 160 - 1 - 32 - 40 - 12);
    uint256 private constant NFT_INDEX_OFFSET = 63;

    uint256 private constant IS_NFT =            0x0000000000000000000000000000000000000000800000000000000000000000;
    uint256 private constant NOT_IS_NFT =        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFFFFFFFFFFF;
    uint256 private constant NFT_INDEX =         0x00000000000000000000000000000000000000007FFFFFFF8000000000000000;
    uint256 private constant NOT_NFT_INDEX =     0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF800000007FFFFFFFFFFFFFFF;
    uint256 private constant URI_ID =            0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000007FFFFFFFFFFFF800;
    uint256 private constant PACK_ID =           0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000007FFFFFFFFF800000;
    uint256 private constant PACK_INDEX =        0x00000000000000000000000000000000000000000000000000000000000007FF;
    uint256 private constant PACK_NUM_FT_TYPES = 0x00000000000000000000000000000000000000000000000000000000007FF800;

    uint256 private constant MAX_SUPPLY = uint256(2)**32 - 1;
    uint256 private constant MAX_PACK_SIZE = uint256(2)**11;

    event CreatorshipTransfer(
        address indexed original,
        address indexed from,
        address indexed to
    );

    mapping(address => uint256) private _numNFTPerAddress; // erc721
    mapping(uint256 => uint256) private _owners; // erc721
    mapping(address => mapping(uint256 => uint256)) private _packedTokenBalance; // erc1155
    mapping(address => mapping(address => bool)) private _operatorsForAll; // erc721 and erc1155
    mapping(uint256 => address) private _erc721operators; // erc721
    mapping(uint256 => bytes32) private _metadataHash; // erc721 and erc1155
    mapping(uint256 => bytes) private _rarityPacks; // rarity configuration per packs (2 bits per Asset)
    mapping(uint256 => uint32) private _nextCollectionIndex; // extraction

    mapping(address => address) private _creatorship; // creatorship transfer

    mapping(address => bool) private _bouncers; // the contracts allowed to mint
    mapping(address => bool) private _metaTransactionContracts; // native meta-transaction support

    address private _bouncerAdmin;

    constructor(
        address metaTransactionContract,
        address admin,
        address bouncerAdmin
    ) public {
        _metaTransactionContracts[metaTransactionContract] = true;
        _admin = admin;
        _bouncerAdmin = bouncerAdmin;
        emit MetaTransactionProcessor(metaTransactionContract, true);
    }

    event BouncerAdminChanged(address oldBouncerAdmin, address newBouncerAdmin);

    function getBouncerAdmin() external view returns(address) {

        return _bouncerAdmin;
    }

    function changeBouncerAdmin(address newBouncerAdmin) external {

        require(
            msg.sender == _bouncerAdmin,
            "only bouncerAdmin can change itself"
        );
        emit BouncerAdminChanged(_bouncerAdmin, newBouncerAdmin);
        _bouncerAdmin = newBouncerAdmin;
    }

    event Bouncer(address bouncer, bool enabled);

    function setBouncer(address bouncer, bool enabled) external {

        require(
            msg.sender == _bouncerAdmin,
            "only bouncerAdmin can setup bouncers"
        );
        _bouncers[bouncer] = enabled;
        emit Bouncer(bouncer, enabled);
    }

    function isBouncer(address who) external view returns(bool) {

        return _bouncers[who];
    }

    event MetaTransactionProcessor(address metaTransactionProcessor, bool enabled);

    function setMetaTransactionProcessor(address metaTransactionProcessor, bool enabled) external {

        require(
            msg.sender == _admin,
            "only admin can setup metaTransactionProcessors"
        );
        _metaTransactionContracts[metaTransactionProcessor] = enabled;
        emit MetaTransactionProcessor(metaTransactionProcessor, enabled);
    }

    function isMetaTransactionProcessor(address who) external view returns(bool) {

        return _metaTransactionContracts[who];
    }

    function mint(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint256 supply,
        uint8 rarity,
        address owner,
        bytes calldata data
    ) external returns (uint256 id) {

        require(hash != 0, "hash is zero");
        require(_bouncers[msg.sender], "only bouncer allowed to mint");
        require(owner != address(0), "destination is zero address");
        id = generateTokenId(creator, supply, packId, supply == 1 ? 0 : 1, 0);
        _mint(
            hash,
            supply,
            rarity,
            msg.sender,
            owner,
            id,
            data,
            false
        );
    }

    function generateTokenId(
        address creator,
        uint256 supply,
        uint40 packId,
        uint16 numFTs,
        uint16 packIndex
    ) internal pure returns (uint256) {

        require(supply > 0 && supply <= MAX_SUPPLY, "invalid supply");

        return
            uint256(creator) * CREATOR_OFFSET_MULTIPLIER + // CREATOR
            (supply == 1 ? uint256(1) * IS_NFT_OFFSET_MULTIPLIER : 0) + // minted as NFT (1) or FT (0) // IS_NFT
            uint256(packId) * PACK_ID_OFFSET_MULTIPLIER + // packId (unique pack) // PACk_ID
            numFTs * PACK_NUM_FT_TYPES_OFFSET_MULTIPLIER + // number of fungible token in the pack // PACK_NUM_FT_TYPES
            packIndex; // packIndex (position in the pack) // PACK_INDEX
    }

    function _mint(
        bytes32 hash,
        uint256 supply,
        uint8 rarity,
        address operator,
        address owner,
        uint256 id,
        bytes memory data,
        bool extraction
    ) internal {

        uint256 uriId = id & URI_ID;
        if (!extraction) {
            require(uint256(_metadataHash[uriId]) == 0, "id already used");
            _metadataHash[uriId] = hash;
            require(rarity < 4, "rarity >= 4");
            bytes memory pack = new bytes(1);
            pack[0] = bytes1(rarity * 64);
            _rarityPacks[uriId] = pack;
        }
        if (supply == 1) {
            _numNFTPerAddress[owner]++;
            _owners[id] = uint256(owner);
            emit Transfer(address(0), owner, id);
        } else {
            (uint256 bin, uint256 index) = id.getTokenBinIndex();
            _packedTokenBalance[owner][bin] = _packedTokenBalance[owner][bin]
                .updateTokenBalance(
                index,
                supply,
                ObjectLib32.Operations.REPLACE
            );
        }

        emit TransferSingle(operator, address(0), owner, id, supply);
        require(
            _checkERC1155AndCallSafeTransfer(
                operator,
                address(0),
                owner,
                id,
                supply,
                data,
                false,
                false
            ),
            "transfer rejected"
        );
    }

    function mintMultiple(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint256[] calldata supplies,
        bytes calldata rarityPack,
        address owner,
        bytes calldata data
    ) external returns (uint256[] memory ids) {

        require(hash != 0, "hash is zero");
        require(_bouncers[msg.sender], "only bouncer allowed to mint");
        require(owner != address(0), "destination is zero address");
        uint16 numNFTs;
        (ids, numNFTs) = allocateIds(
            creator,
            supplies,
            rarityPack,
            packId,
            hash
        );
        _mintBatches(supplies, owner, ids, numNFTs);
        completeMultiMint(msg.sender, owner, ids, supplies, data);
    }

    function allocateIds(
        address creator,
        uint256[] memory supplies,
        bytes memory rarityPack,
        uint40 packId,
        bytes32 hash
    ) internal returns (uint256[] memory ids, uint16 numNFTs) {

        require(supplies.length > 0, "supplies.length == 0");
        require(supplies.length <= MAX_PACK_SIZE, "too big batch");
        (ids, numNFTs) = generateTokenIds(creator, supplies, packId);
        uint256 uriId = ids[0] & URI_ID;
        require(uint256(_metadataHash[uriId]) == 0, "id already used");
        _metadataHash[uriId] = hash;
        _rarityPacks[uriId] = rarityPack;
    }

    function generateTokenIds(
        address creator,
        uint256[] memory supplies,
        uint40 packId
    ) internal pure returns (uint256[] memory, uint16) {

        uint16 numTokenTypes = uint16(supplies.length);
        uint256[] memory ids = new uint256[](numTokenTypes);
        uint16 numNFTs = 0;
        for (uint16 i = 0; i < numTokenTypes; i++) {
            if (numNFTs == 0) {
                if (supplies[i] == 1) {
                    numNFTs = uint16(numTokenTypes - i);
                }
            } else {
                require(supplies[i] == 1, "NFTs need to be put at the end");
            }
        }
        uint16 numFTs = numTokenTypes - numNFTs;
        for (uint16 i = 0; i < numTokenTypes; i++) {
            ids[i] = generateTokenId(creator, supplies[i], packId, numFTs, i);
        }
        return (ids, numNFTs);
    }

    function completeMultiMint(
        address operator,
        address owner,
        uint256[] memory ids,
        uint256[] memory supplies,
        bytes memory data
    ) internal {

        emit TransferBatch(operator, address(0), owner, ids, supplies);
        require(
            _checkERC1155AndCallSafeBatchTransfer(
                operator,
                address(0),
                owner,
                ids,
                supplies,
                data
            ),
            "transfer rejected"
        );
    }

    function _mintBatches(
        uint256[] memory supplies,
        address owner,
        uint256[] memory ids,
        uint16 numNFTs
    ) internal {

        uint16 offset = 0;
        while (offset < supplies.length - numNFTs) {
            _mintBatch(offset, supplies, owner, ids);
            offset += 8;
        }
        if (numNFTs > 0) {
            _mintNFTs(
                uint16(supplies.length - numNFTs),
                numNFTs,
                owner,
                ids
            );
        }
    }

    function _mintNFTs(
        uint16 offset,
        uint32 numNFTs,
        address owner,
        uint256[] memory ids
    ) internal {

        for (uint16 i = 0; i < numNFTs; i++) {
            uint256 id = ids[i + offset];
            _owners[id] = uint256(owner);
            emit Transfer(address(0), owner, id);
        }
        _numNFTPerAddress[owner] += numNFTs;
    }

    function _mintBatch(
        uint16 offset,
        uint256[] memory supplies,
        address owner,
        uint256[] memory ids
    ) internal {

        uint256 firstId = ids[offset];
        (uint256 bin, uint256 index) = firstId.getTokenBinIndex();
        uint256 balances = _packedTokenBalance[owner][bin];
        for (uint256 i = 0; i < 8 && offset + i < supplies.length; i++) {
            uint256 j = offset + i;
            if (supplies[j] > 1) {
                balances = balances.updateTokenBalance(
                    index + i,
                    supplies[j],
                    ObjectLib32.Operations.REPLACE
                );
            } else {
                break;
            }
        }
        _packedTokenBalance[owner][bin] = balances;
    }

    function _transferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value
    ) internal {

        require(to != address(0), "destination is zero address");
        require(from != address(0), "from is zero address");
        bool authorized = from == msg.sender ||
            _superOperators[msg.sender] ||
            _operatorsForAll[from][msg.sender] ||
            _metaTransactionContracts[msg.sender]; // solium-disable-line max-len

        if (id & IS_NFT > 0) {
            require(
                authorized || _erc721operators[id] == msg.sender,
                "Operator not approved"
            );
            if(value > 0) {
                require(value == 1, "cannot transfer nft if amount not 1");
                _numNFTPerAddress[from]--;
                _numNFTPerAddress[to]++;
                _owners[id] = uint256(to);
                _erc721operators[id] = address(0);
                emit Transfer(from, to, id);
            }
        } else {
            require(authorized, "Operator not approved");
            if(value > 0) {
                (uint256 bin, uint256 index) = id.getTokenBinIndex();
                _packedTokenBalance[from][bin] = _packedTokenBalance[from][bin]
                    .updateTokenBalance(index, value, ObjectLib32.Operations.SUB);
                _packedTokenBalance[to][bin] = _packedTokenBalance[to][bin]
                    .updateTokenBalance(index, value, ObjectLib32.Operations.ADD);
            }
        }

        emit TransferSingle(
            _metaTransactionContracts[msg.sender] ? from : msg.sender,
            from,
            to,
            id,
            value
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external {

        if (id & IS_NFT > 0) {
            require(_ownerOf(id) == from, "not owner");
        }
        _transferFrom(from, to, id, value);
        require(
            _checkERC1155AndCallSafeTransfer(
                _metaTransactionContracts[msg.sender] ? from : msg.sender,
                from,
                to,
                id,
                value,
                data,
                false,
                false
            ),
            "erc1155 transfer rejected"
        );
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external {

        _batchTransferFrom(from, to, ids, values);
        require(
            _checkERC1155AndCallSafeBatchTransfer(
                _metaTransactionContracts[msg.sender] ? from : msg.sender,
                from,
                to,
                ids,
                values,
                data
            ),
            "erc1155 transfer rejected"
        );
    }

    function _batchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal {

        uint256 numItems = ids.length;
        require(
            numItems == values.length,
            "Inconsistent array length between args"
        );
        require(to != address(0), "destination is zero address");
        require(from != address(0), "from is zero address");
        bool authorized = from == msg.sender ||
            _superOperators[msg.sender] ||
            _operatorsForAll[from][msg.sender] ||
            _metaTransactionContracts[msg.sender]; // solium-disable-line max-len

        uint256 bin;
        uint256 index;
        uint256 balFrom;
        uint256 balTo;

        uint256 lastBin;
        uint256 numNFTs = 0;
        for (uint256 i = 0; i < numItems; i++) {
            if (ids[i] & IS_NFT > 0) {
                require(
                    authorized || _erc721operators[ids[i]] == msg.sender,
                    "Operator not approved"
                );
                if(values[i] > 0) {
                    require(values[i] == 1, "cannot transfer nft if amount not 1");
                    require(_ownerOf(ids[i]) == from, "not owner");
                    numNFTs++;
                    _owners[ids[i]] = uint256(to);
                    _erc721operators[ids[i]] = address(0);
                    emit Transfer(from, to, ids[i]);
                }
            } else {
                require(authorized, "Operator not approved");
                if(values[i] > 0) {
                    (bin, index) = ids[i].getTokenBinIndex();
                    if (lastBin == 0) {
                        lastBin = bin;
                        balFrom = ObjectLib32.updateTokenBalance(
                            _packedTokenBalance[from][bin],
                            index,
                            values[i],
                            ObjectLib32.Operations.SUB
                        );
                        balTo = ObjectLib32.updateTokenBalance(
                            _packedTokenBalance[to][bin],
                            index,
                            values[i],
                            ObjectLib32.Operations.ADD
                        );
                    } else {
                        if (bin != lastBin) {
                            _packedTokenBalance[from][lastBin] = balFrom;
                            _packedTokenBalance[to][lastBin] = balTo;

                            balFrom = _packedTokenBalance[from][bin];
                            balTo = _packedTokenBalance[to][bin];

                            lastBin = bin;
                        }

                        balFrom = balFrom.updateTokenBalance(
                            index,
                            values[i],
                            ObjectLib32.Operations.SUB
                        );
                        balTo = balTo.updateTokenBalance(
                            index,
                            values[i],
                            ObjectLib32.Operations.ADD
                        );
                    }
                }
            }
        }
        if (numNFTs > 0) {
            _numNFTPerAddress[from] -= numNFTs;
            _numNFTPerAddress[to] += numNFTs;
        }

        if (bin != 0) { // if needed
            _packedTokenBalance[from][bin] = balFrom;
            _packedTokenBalance[to][bin] = balTo;
        }

        emit TransferBatch(
            _metaTransactionContracts[msg.sender] ? from : msg.sender,
            from,
            to,
            ids,
            values
        );
    }

    function balanceOf(address owner, uint256 id)
        public
        view
        returns (uint256)
    {

        if (id & IS_NFT > 0) {
            if (_ownerOf(id) == owner) {
                return 1;
            } else {
                return 0;
            }
        }
        (uint256 bin, uint256 index) = id.getTokenBinIndex();
        return _packedTokenBalance[owner][bin].getValueInBin(index);
    }

    function balanceOfBatch(
        address[] calldata owners,
        uint256[] calldata ids
    ) external view returns (uint256[] memory) {

        require(
            owners.length == ids.length,
            "Inconsistent array length between args"
        );
        uint256[] memory balances = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            balances[i] = balanceOf(owners[i], ids[i]);
        }
        return balances;
    }

    function creatorOf(uint256 id) external view returns (address) {

        require(wasEverMinted(id), "token was never minted");
        address originalCreator = address(id / CREATOR_OFFSET_MULTIPLIER);
        address newCreator = _creatorship[originalCreator];
        if (newCreator != address(0)) {
            return newCreator;
        }
        return originalCreator;
    }

    function transferCreatorship(
        address sender,
        address original,
        address to
    ) external {

        require(
            msg.sender == sender ||
            _metaTransactionContracts[msg.sender] ||
            _superOperators[msg.sender],
            "require meta approval"
        );
        require(sender != address(0), "sender is zero address");
        require(to != address(0), "destination is zero address");
        address current = _creatorship[original];
        if (current == address(0)) {
            current = original;
        }
        require(current != to, "current == to");
        require(current == sender, "current != sender");
        if (to == original) {
            _creatorship[original] = address(0);
        } else {
            _creatorship[original] = to;
        }
        emit CreatorshipTransfer(original, current, to);
    }

    function setApprovalForAllFor(
        address sender,
        address operator,
        bool approved
    ) external {

        require(
            msg.sender == sender ||
            _metaTransactionContracts[msg.sender] ||
            _superOperators[msg.sender],
            "require meta approval"
        );
        _setApprovalForAll(sender, operator, approved);
    }

    function setApprovalForAll(address operator, bool approved) external {

        _setApprovalForAll(msg.sender, operator, approved);
    }

    function _setApprovalForAll(
        address sender,
        address operator,
        bool approved
    ) internal {

        require(sender != address(0), "sender is zero address");
        require(operator != address(0), "operator is zero address");
        require(
            !_superOperators[operator],
            "super operator can't have their approvalForAll changed"
        );
        _operatorsForAll[sender][operator] = approved;
        emit ApprovalForAll(sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool isOperator)
    {

        require(owner != address(0), "owner is zero address");
        require(operator != address(0), "operator is zero address");
        return _operatorsForAll[owner][operator] || _superOperators[operator];
    }

    function balanceOf(address owner)
        external
        view
        returns (uint256 balance)
    {

        require(owner != address(0), "owner is zero address");
        return _numNFTPerAddress[owner];
    }

    function ownerOf(uint256 id) external view returns (address owner) {

        owner = _ownerOf(id);
        require(owner != address(0), "NFT does not exist");
    }

    function _ownerOf(uint256 id) internal view returns (address) {

        return address(_owners[id]);
    }

    function approveFor(address sender, address operator, uint256 id)
        external
    {

        address owner = _ownerOf(id);
        require(sender != address(0), "sender is zero address");
        require(
            msg.sender == sender ||
            _metaTransactionContracts[msg.sender] ||
            _superOperators[msg.sender] ||
            _operatorsForAll[sender][msg.sender],
            "require operators"
        ); // solium-disable-line max-len
        require(owner == sender, "not owner");
        _erc721operators[id] = operator;
        emit Approval(owner, operator, id);
    }

    function approve(address operator, uint256 id) external {

        address owner = _ownerOf(id);
        require(owner != address(0), "NFT does not exist");
        require(
            owner == msg.sender ||
            _superOperators[msg.sender] ||
            _operatorsForAll[owner][msg.sender],
            "not authorized"
        );
        _erc721operators[id] = operator;
        emit Approval(owner, operator, id);
    }

    function getApproved(uint256 id)
        external
        view
        returns (address operator)
    {

        require(_ownerOf(id) != address(0), "NFT does not exist");
        return _erc721operators[id];
    }

    function transferFrom(address from, address to, uint256 id) external {

        require(_ownerOf(id) == from, "not owner");
        _transferFrom(from, to, id, 1);
        require(
            _checkERC1155AndCallSafeTransfer(
                _metaTransactionContracts[msg.sender] ? from : msg.sender,
                from,
                to,
                id,
                1,
                "",
                true,
                false
            ),
            "erc1155 transfer rejected"
        );
    }

    function safeTransferFrom(address from, address to, uint256 id)
        external
    {

        safeTransferFrom(from, to, id, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) public {

        require(_ownerOf(id) == from, "not owner");
        _transferFrom(from, to, id, 1);
        require(
            _checkERC1155AndCallSafeTransfer(
                _metaTransactionContracts[msg.sender] ? from : msg.sender,
                from,
                to,
                id,
                1,
                data,
                true,
                true
            ),
            "erc721/erc1155 transfer rejected"
        );
    }

    function name() external pure returns (string memory _name) {

        return "Sandbox's ASSETs";
    }

    function symbol() external pure returns (string memory _symbol) {

        return "ASSET";
    }

    function rarity(uint256 id) public view returns (uint256) {

        require(wasEverMinted(id), "token was never minted");
        bytes storage rarityPack = _rarityPacks[id & URI_ID];
        uint256 packIndex = id & PACK_INDEX;
        if (packIndex / 4 >= rarityPack.length) {
            return 0;
        } else {
            uint8 pack = uint8(rarityPack[packIndex / 4]);
            uint8 i = (3 - uint8(packIndex % 4)) * 2;
            return (pack / (uint8(2)**i)) % 4;
        }
    }

    function collectionOf(uint256 id) public view returns (uint256) {

        require(_ownerOf(id) != address(0), "NFT does not exist");
        uint256 collectionId = id & NOT_NFT_INDEX & NOT_IS_NFT;
        require(wasEverMinted(collectionId), "no collection ever minted for that token");
        return collectionId;
    }

    function isCollection(uint256 id) public view returns (bool) {

        uint256 collectionId = id & NOT_NFT_INDEX & NOT_IS_NFT;
        return wasEverMinted(collectionId);
    }

    function collectionIndexOf(uint256 id) public view returns (uint256) {

        collectionOf(id); // this check if id and collection indeed was ever minted
        return uint32((id & NFT_INDEX) >> NFT_INDEX_OFFSET);
    }

    function toFullURI(bytes32 hash, uint256 id)
        internal
        pure
        returns (string memory)
    {

        return
            string(
                abi.encodePacked(
                    "ipfs://bafybei",
                    hash2base32(hash),
                    "/",
                    uint2str(id & PACK_INDEX),
                    ".json"
                )
            );
    }

    function wasEverMinted(uint256 id) public view returns(bool) {

        if ((id & IS_NFT) > 0) {
            return _owners[id] != 0;
        } else {
            return
                ((id & PACK_INDEX) < ((id & PACK_NUM_FT_TYPES) / PACK_NUM_FT_TYPES_OFFSET_MULTIPLIER)) &&
                _metadataHash[id & URI_ID] != 0;
        }
    }

    function uri(uint256 id) public view returns (string memory) {

        require(wasEverMinted(id), "token was never minted"); // prevent returning invalid uri
        return toFullURI(_metadataHash[id & URI_ID], id);
    }

    function tokenURI(uint256 id) public view returns (string memory) {

        require(_ownerOf(id) != address(0), "NFT does not exist");
        return toFullURI(_metadataHash[id & URI_ID], id);
    }

    bytes32 private constant base32Alphabet = 0x6162636465666768696A6B6C6D6E6F707172737475767778797A323334353637;
    function hash2base32(bytes32 hash)
        private
        pure
        returns (string memory _uintAsString)
    {

        uint256 _i = uint256(hash);
        uint256 k = 52;
        bytes memory bstr = new bytes(k);
        bstr[--k] = base32Alphabet[uint8((_i % 8) << 2)]; // uint8 s = uint8((256 - skip) % 5);  // (_i % (2**s)) << (5-s)
        _i /= 8;
        while (k > 0) {
            bstr[--k] = base32Alphabet[_i % 32];
            _i /= 32;
        }
        return string(bstr);
    }

    function uint2str(uint256 _i)
        private
        pure
        returns (string memory _uintAsString)
    {

        if (_i == 0) {
            return "0";
        }

        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }

        return string(bstr);
    }

    function supportsInterface(bytes4 id) external view returns (bool) {

        return
            id == 0x01ffc9a7 || //ERC165
            id == 0xd9b67a26 || // ERC1155
            id == 0x80ac58cd || // ERC721
            id == 0x5b5e139f || // ERC721 metadata
            id == 0x0e89341c; // ERC1155 metadata
    }

    bytes4 constant ERC165ID = 0x01ffc9a7;
    function checkIsERC1155Receiver(address _contract)
        internal
        view
        returns (bool)
    {

        bool success;
        bool result;
        bytes memory call_data = abi.encodeWithSelector(
            ERC165ID,
            ERC1155_IS_RECEIVER
        );
        assembly {
            let call_ptr := add(0x20, call_data)
            let call_size := mload(call_data)
            let output := mload(0x40) // Find empty storage location using "free memory pointer"
            mstore(output, 0x0)
            success := staticcall(
                10000,
                _contract,
                call_ptr,
                call_size,
                output,
                0x20
            ) // 32 bytes
            result := mload(output)
        }
        assert(gasleft() > 158);
        return success && result;
    }

    function _checkERC1155AndCallSafeTransfer(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data,
        bool erc721,
        bool erc721Safe
    ) internal returns (bool) {

        if (!to.isContract()) {
            return true;
        }
        if (erc721) {
            if (!checkIsERC1155Receiver(to)) {
                if (erc721Safe) {
                    return
                        _checkERC721AndCallSafeTransfer(
                            operator,
                            from,
                            to,
                            id,
                            data
                        );
                } else {
                    return true;
                }
            }
        }
        return
            ERC1155TokenReceiver(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    value,
                    data
            ) == ERC1155_RECEIVED;
    }

    function _checkERC1155AndCallSafeBatchTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal returns (bool) {

        if (!to.isContract()) {
            return true;
        }
        bytes4 retval = ERC1155TokenReceiver(to).onERC1155BatchReceived(
            operator,
            from,
            ids,
            values,
            data
        );
        return (retval == ERC1155_BATCH_RECEIVED);
    }

    function _checkERC721AndCallSafeTransfer(
        address operator,
        address from,
        address to,
        uint256 id,
        bytes memory data
    ) internal returns (bool) {

        return (ERC721TokenReceiver(to).onERC721Received(
                operator,
                from,
                id,
                data
            ) ==
            ERC721_RECEIVED);
    }

    event Extraction(uint256 indexed fromId, uint256 toId);
    event AssetUpdate(uint256 indexed fromId, uint256 toId);

    function _burnERC1155(
        address operator,
        address from,
        uint256 id,
        uint32 amount
    ) internal {

        (uint256 bin, uint256 index) = (id).getTokenBinIndex();
        _packedTokenBalance[from][bin] = _packedTokenBalance[from][bin]
            .updateTokenBalance(index, amount, ObjectLib32.Operations.SUB);
        emit TransferSingle(operator, from, address(0), id, amount);
    }

    function _burnERC721(address operator, address from, uint256 id)
        internal
    {

        require(from == _ownerOf(id), "not owner");
        _owners[id] = 2**160; // equivalent to zero address when casted but ensure we track minted status
        _numNFTPerAddress[from]--;
        emit Transfer(from, address(0), id);
        emit TransferSingle(operator, from, address(0), id, 1);
    }

    function burn(uint256 id, uint256 amount) external {

        _burn(msg.sender, id, amount);
    }

    function burnFrom(address from, uint256 id, uint256 amount) external {

        require(from != address(0), "from is zero address");
        require(
            msg.sender == from ||
                _metaTransactionContracts[msg.sender] ||
                _superOperators[msg.sender] ||
                _operatorsForAll[from][msg.sender],
            "require meta approval"
        );
        _burn(from, id, amount);
    }

    function _burn(address from, uint256 id, uint256 amount) internal {

        if ((id & IS_NFT) > 0) {
            require(amount == 1, "can only burn one NFT");
            _burnERC721(
                _metaTransactionContracts[msg.sender] ? from : msg.sender,
                from,
                id
            );
        } else {
            require(amount > 0 && amount <= MAX_SUPPLY, "invalid amount");
            _burnERC1155(
                _metaTransactionContracts[msg.sender] ? from : msg.sender,
                from,
                id,
                uint32(amount)
            );
        }
    }

    function updateERC721(
        address from,
        uint256 id,
        uint40 packId,
        bytes32 hash,
        uint8 newRarity,
        address to,
        bytes calldata data
    ) external returns(uint256) {

        require(hash != 0, "hash is zero");
        require(
            _bouncers[msg.sender],
            "only bouncer allowed to mint via update"
        );
        require(to != address(0), "destination is zero address");
        require(from != address(0), "from is zero address");

        _burnERC721(msg.sender, from, id);

        uint256 newId = generateTokenId(from, 1, packId, 0, 0);
        _mint(hash, 1, newRarity, msg.sender, to, newId, data, false);
        emit AssetUpdate(id, newId);
        return newId;
    }

    function extractERC721(uint256 id, address to)
        external
        returns (uint256 newId)
    {

        return _extractERC721From(msg.sender, msg.sender, id, to);
    }

    function extractERC721From(address sender, uint256 id, address to)
        external
        returns (uint256 newId)
    {

        require(
            msg.sender == sender ||
                _metaTransactionContracts[msg.sender] ||
                _superOperators[msg.sender] ||
                _operatorsForAll[sender][msg.sender],
            "require meta approval"
        );
        address operator = _metaTransactionContracts[msg.sender]
            ? sender
            : msg.sender;
        return _extractERC721From(operator, sender, id, to);
    }

    function _extractERC721From(address operator, address sender, uint256 id, address to)
        internal
        returns (uint256 newId)
    {

        require(to != address(0), "destination is zero address");
        require(id & IS_NFT == 0, "Not an ERC1155 Token");
        uint32 tokenCollectionIndex = _nextCollectionIndex[id];
        newId = id +
            IS_NFT +
            (tokenCollectionIndex) *
            2**NFT_INDEX_OFFSET;
        _nextCollectionIndex[id] = tokenCollectionIndex + 1;
        _burnERC1155(operator, sender, id, 1);
        _mint(
            _metadataHash[id & URI_ID],
            1,
            0,
            operator,
            to,
            newId,
            "",
            true
        );
        emit Extraction(id, newId);
    }
}pragma solidity 0.5.9;


contract GenesisBouncer is Admin {

    ERC1155ERC721 _asset;
    mapping(address => bool) _minters;

    constructor(ERC1155ERC721 asset, address genesisAdmin, address firstMinter)
        public
    {
        _asset = asset;
        _admin = genesisAdmin;
        _setMinter(firstMinter, true);
    }

    event MinterUpdated(address minter, bool allowed);
    function _setMinter(address minter, bool allowed) internal {

        _minters[minter] = allowed;
        emit MinterUpdated(minter, allowed);
    }
    function setMinter(address minter, bool allowed) external {

        require(msg.sender == _admin, "only admin can allocate minter");
        _setMinter(minter, allowed);
    }

    function mintFor(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint32 supply,
        uint8 rarity,
        address owner
    ) public returns (uint256 tokenId) {

        require(_minters[msg.sender], "not authorized");
        return
            _asset.mint(creator, packId, hash, supply, rarity, owner, "");
    }

    function mintMultipleFor(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint256[] memory supplies,
        bytes memory rarityPack,
        address owner
    ) public returns (uint256[] memory ids) {

        require(_minters[msg.sender], "not authorized");
        return
            _asset.mintMultiple(
                creator,
                packId,
                hash,
                supplies,
                rarityPack,
                owner,
                ""
            );
    }
}