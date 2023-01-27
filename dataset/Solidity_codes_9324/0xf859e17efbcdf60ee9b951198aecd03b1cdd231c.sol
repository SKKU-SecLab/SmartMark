pragma solidity 0.5.9;

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
}/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * This code has not been reviewed.
 * Do not use or deploy this code before reviewing it personally first.
 */
pragma solidity 0.5.9;

interface ERC721TokenReceiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}pragma solidity 0.5.9;

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
}pragma solidity 0.5.9;

contract AdminV2 {


    address internal _admin;

    event AdminChanged(address oldAdmin, address newAdmin);

    function getAdmin() external view returns (address) {

        return _admin;
    }

    function changeAdmin(address newAdmin) external {

        address admin = _admin;
        require(msg.sender == admin, "only admin can change admin");
        require(newAdmin != admin, "it can be only changed to a new admin");
        emit AdminChanged(admin, newAdmin);
        _admin = newAdmin;
    }

    modifier onlyAdmin() {

        require (msg.sender == _admin, "only admin allowed");
        _;
    }

}pragma solidity 0.5.9;


contract SuperOperatorsV2 is AdminV2 {


    mapping(address => bool) internal _superOperators;

    event SuperOperator(address superOperator, bool enabled);

    function setSuperOperator(address superOperator, bool enabled) external onlyAdmin {

        require(
            superOperator != address(0),
            "address 0 is not allowed as super operator"
        );
        require(
            enabled != _superOperators[superOperator],
            "the status should be different than the current one"
        );
        _superOperators[superOperator] = enabled;
        emit SuperOperator(superOperator, enabled);
    }

    function isSuperOperator(address who) public view returns (bool) {

        return _superOperators[who];
    }
}pragma solidity 0.5.9;


contract MetaTransactionReceiverV2 is AdminV2 {

    using AddressUtils for address;

    mapping(address => bool) internal _metaTransactionContracts;
    event MetaTransactionProcessor(address metaTransactionProcessor, bool enabled);

    function setMetaTransactionProcessor(address metaTransactionProcessor, bool enabled) public onlyAdmin {

        require(
            metaTransactionProcessor.isContract(),
            "only contracts can be meta transaction processor"
        );
        _setMetaTransactionProcessor(metaTransactionProcessor, enabled);
    }

    function _setMetaTransactionProcessor(address metaTransactionProcessor, bool enabled) internal {

        _metaTransactionContracts[metaTransactionProcessor] = enabled;
        emit MetaTransactionProcessor(metaTransactionProcessor, enabled);
    }

    function isMetaTransactionProcessor(address who) external view returns(bool) {

        return _metaTransactionContracts[who];
    }
}pragma solidity 0.5.9;

interface ERC721MandatoryTokenReceiver {

    function onERC721BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        bytes calldata data
    ) external returns (bytes4); // needs to return 0x4b808c46


    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4); // needs to return 0x150b7a02

}/* solhint-disable func-order, code-complexity */
pragma solidity 0.5.9;


contract ERC721BaseTokenV2 is ERC721Events, SuperOperatorsV2, MetaTransactionReceiverV2 {

    using AddressUtils for address;

    bytes4 internal constant _ERC721_RECEIVED = 0x150b7a02;
    bytes4 internal constant _ERC721_BATCH_RECEIVED = 0x4b808c46;

    bytes4 internal constant ERC165ID = 0x01ffc9a7;
    bytes4 internal constant ERC721_MANDATORY_RECEIVER = 0x5e8bf644;

    mapping (address => uint256) public _numNFTPerAddress;
    mapping (uint256 => uint256) public _owners;
    mapping (address => mapping(address => bool)) public _operatorsForAll;
    mapping (uint256 => address) public _operators;

    bool internal _initialized;

    modifier initializer() {

        require(!_initialized, "ERC721BaseToken: Contract already initialized");
        _;
    }

    function initialize (
        address metaTransactionContract,
        address admin
    ) public initializer {
        _admin = admin;
        _setMetaTransactionProcessor(metaTransactionContract, true);
        _initialized = true;
    }

    function _transferFrom(address from, address to, uint256 id) internal {

        _numNFTPerAddress[from]--;
        _numNFTPerAddress[to]++;
        _owners[id] = uint256(to);
        emit Transfer(from, to, id);
    }

    function balanceOf(address owner) external view returns (uint256) {

        require(owner != address(0), "owner is zero address");
        return _numNFTPerAddress[owner];
    }


    function _ownerOf(uint256 id) internal view returns (address) {

        return address(_owners[id]);
    }

    function _ownerAndOperatorEnabledOf(uint256 id) internal view returns (address owner, bool operatorEnabled) {

        uint256 data = _owners[id];
        owner = address(data);
        operatorEnabled = (data / 2**255) == 1;
    }

    function ownerOf(uint256 id) external view returns (address owner) {

        owner = _ownerOf(id);
        require(owner != address(0), "token does not exist");
    }

    function _approveFor(address owner, address operator, uint256 id) internal {

        if(operator == address(0)) {
            _owners[id] = uint256(owner); // no need to resset the operator, it will be overriden next time
        } else {
            _owners[id] = uint256(owner) + 2**255;
            _operators[id] = operator;
        }
        emit Approval(owner, operator, id);
    }

    function approveFor(
        address sender,
        address operator,
        uint256 id
    ) external {

        address owner = _ownerOf(id);
        require(sender != address(0), "sender is zero address");
        require(
            msg.sender == sender ||
            _metaTransactionContracts[msg.sender] ||
            _operatorsForAll[sender][msg.sender] ||
            _superOperators[msg.sender],
            "not authorized to approve"
        );
        require(owner == sender, "owner != sender");
        _approveFor(owner, operator, id);
    }

    function approve(address operator, uint256 id) external {

        address owner = _ownerOf(id);
        require(owner != address(0), "token does not exist");
        require(
            owner == msg.sender ||
            _operatorsForAll[owner][msg.sender] ||
            _superOperators[msg.sender],
            "not authorized to approve"
        );
        _approveFor(owner, operator, id);
    }

    function getApproved(uint256 id) external view returns (address) {

        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(owner != address(0), "token does not exist");
        if (operatorEnabled) {
            return _operators[id];
        } else {
            return address(0);
        }
    }

    function _checkTransfer(address from, address to, uint256 id) internal view returns (bool isMetaTx) {

        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(owner != address(0), "token does not exist");
        require(owner == from, "not owner in _checkTransfer");
        require(to != address(0), "can't send to zero address");
        isMetaTx = msg.sender != from && _metaTransactionContracts[msg.sender];
        if (msg.sender != from && !isMetaTx) {
            require(
                _operatorsForAll[from][msg.sender] ||
                (operatorEnabled && _operators[id] == msg.sender) ||
                _superOperators[msg.sender],
                "not approved to transfer"
            );
        }
    }

    function _checkInterfaceWith10000Gas(address _contract, bytes4 interfaceId)
        internal
        view
        returns (bool)
    {

        bool success;
        bool result;
        bytes memory call_data = abi.encodeWithSelector(
            ERC165ID,
            interfaceId
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

    function transferFrom(address from, address to, uint256 id) external {

        bool metaTx = _checkTransfer(from, to, id);
        _transferFrom(from, to, id);
        if (to.isContract() && _checkInterfaceWith10000Gas(to, ERC721_MANDATORY_RECEIVER)) {
            require(
                _checkOnERC721Received(metaTx ? from : msg.sender, from, to, id, ""),
                "erc721 transfer rejected by to"
            );
        }
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes memory data) public {

        bool metaTx = _checkTransfer(from, to, id);
        _transferFrom(from, to, id);
        if (to.isContract()) {
            require(
                _checkOnERC721Received(metaTx ? from : msg.sender, from, to, id, data),
                "ERC721: transfer rejected by to"
            );
        }
    }

    function safeTransferFrom(address from, address to, uint256 id) external {

        safeTransferFrom(from, to, id, "");
    }

    function batchTransferFrom(address from, address to, uint256[] calldata ids, bytes calldata data) external {

        _batchTransferFrom(from, to, ids, data, false);
    }

    function _batchTransferFrom(address from, address to, uint256[] memory ids, bytes memory data, bool safe) internal {

        bool metaTx = msg.sender != from && _metaTransactionContracts[msg.sender];
        bool authorized = msg.sender == from ||
            metaTx ||
            _operatorsForAll[from][msg.sender] ||
            _superOperators[msg.sender];

        require(from != address(0), "from is zero address");
        require(to != address(0), "can't send to zero address");

        uint256 numTokens = ids.length;
        for(uint256 i = 0; i < numTokens; i ++) {
            uint256 id = ids[i];
            (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
            require(owner == from, "not owner in batchTransferFrom");
            require(authorized || (operatorEnabled && _operators[id] == msg.sender), "not authorized");
            _owners[id] = uint256(to);
            emit Transfer(from, to, id);
        }
        if (from != to) {
            _numNFTPerAddress[from] -= numTokens;
            _numNFTPerAddress[to] += numTokens;
        }

        if (to.isContract()) {
            if (_checkInterfaceWith10000Gas(to, ERC721_MANDATORY_RECEIVER)) {
                require(
                    _checkOnERC721BatchReceived(metaTx ? from : msg.sender, from, to, ids, data),
                    "erc721 batch transfer rejected by to"
                );
            } else if (safe) {
                for (uint256 i = 0; i < numTokens; i ++) {
                    require(
                        _checkOnERC721Received(metaTx ? from : msg.sender, from, to, ids[i], ""),
                        "erc721 transfer rejected by to"
                    );
                }
            }
        }
    }

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, bytes calldata data) external {

        _batchTransferFrom(from, to, ids, data, true);
    }

    function supportsInterface(bytes4 id) external pure returns (bool) {

        return id == 0x01ffc9a7 || id == 0x80ac58cd;
    }

    function setApprovalForAllFor(
        address sender,
        address operator,
        bool approved
    ) external {

        require(sender != address(0), "Invalid sender address");
        require(
            msg.sender == sender ||
            _metaTransactionContracts[msg.sender] ||
            _superOperators[msg.sender],
            "not authorized to approve for all"
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

        return _operatorsForAll[owner][operator] || _superOperators[operator];
    }

    function _burn(address from, address owner, uint256 id) internal {

        require(from == owner, "not owner");
        _owners[id] = 2**160; // cannot mint it again
        _numNFTPerAddress[from]--;
        emit Transfer(from, address(0), id);
    }

    function burn(uint256 id) external {

        _burn(msg.sender, _ownerOf(id), id);
    }

    function burnFrom(address from, uint256 id) external {

        require(from != address(0), "Invalid sender address");
        (address owner, bool operatorEnabled) = _ownerAndOperatorEnabledOf(id);
        require(
            msg.sender == from ||
            _metaTransactionContracts[msg.sender] ||
            (operatorEnabled && _operators[id] == msg.sender) ||
            _operatorsForAll[from][msg.sender] ||
            _superOperators[msg.sender],
            "not authorized to burn"
        );
        _burn(from, owner, id);
    }

    function _checkOnERC721Received(address operator, address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {

        bytes4 retval = ERC721TokenReceiver(to).onERC721Received(operator, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _checkOnERC721BatchReceived(address operator, address from, address to, uint256[] memory ids, bytes memory _data)
        internal returns (bool)
    {

        bytes4 retval = ERC721MandatoryTokenReceiver(to).onERC721BatchReceived(operator, from, ids, _data);
        return (retval == _ERC721_BATCH_RECEIVED);
    }

    uint256[49] private __gap;
}/* solhint-disable func-order, code-complexity */
pragma solidity 0.5.9;


contract LandBaseTokenV2 is ERC721BaseTokenV2 {

    uint256 internal constant GRID_SIZE = 408;

    uint256 internal constant LAYER =          0xFF00000000000000000000000000000000000000000000000000000000000000;
    uint256 internal constant LAYER_1x1 =      0x0000000000000000000000000000000000000000000000000000000000000000;
    uint256 internal constant LAYER_3x3 =      0x0100000000000000000000000000000000000000000000000000000000000000;
    uint256 internal constant LAYER_6x6 =      0x0200000000000000000000000000000000000000000000000000000000000000;
    uint256 internal constant LAYER_12x12 =    0x0300000000000000000000000000000000000000000000000000000000000000;
    uint256 internal constant LAYER_24x24 =    0x0400000000000000000000000000000000000000000000000000000000000000;

    mapping(address => bool) internal _minters;
    event Minter(address superOperator, bool enabled);

    function setMinter(address minter, bool enabled) external onlyAdmin {

        require(
            minter != address(0),
            "address 0 is not allowed as minter"
        );
        require(
            enabled != _minters[minter],
            "the status should be different than the current one"
        );
        _minters[minter] = enabled;
        emit Minter(minter, enabled);
    }

    function isMinter(address who) public view returns (bool) {

        return _minters[who];
    }

    function width() external returns(uint256) {

        return GRID_SIZE;
    }

    function height() external returns(uint256) {

        return GRID_SIZE;
    }

    function x(uint256 id) external returns(uint256) {

        require(_ownerOf(id) != address(0), "token does not exist");
        return id % GRID_SIZE;
    }

    function y(uint256 id) external returns(uint256) {

        require(_ownerOf(id) != address(0), "token does not exist");
        return id / GRID_SIZE;
    }

    function mintQuad(address to, uint256 size, uint256 x, uint256 y, bytes calldata data) external {

        require(to != address(0), "to is zero address");
        require(
            isMinter(msg.sender),
            "Only a minter can mint"
        );
        require(x % size == 0 && y % size == 0, "Invalid coordinates");
        require(x <= GRID_SIZE - size && y <= GRID_SIZE - size, "Out of bounds");

        uint256 quadId;
        uint256 id = x + y * GRID_SIZE;

        if (size == 1) {
            quadId = id;
        } else if (size == 3) {
            quadId = LAYER_3x3 + id;
        } else if (size == 6) {
            quadId = LAYER_6x6 + id;
        } else if (size == 12) {
            quadId = LAYER_12x12 + id;
        } else if (size == 24) {
            quadId = LAYER_24x24 + id;
        } else {
            require(false, "Invalid size");
        }

        require(_owners[LAYER_24x24 + (x/24) * 24 + ((y/24) * 24) * GRID_SIZE] == 0, "Already minted as 24x24");

        uint256 toX = x+size;
        uint256 toY = y+size;
        if (size <= 12) {
            require(
                _owners[LAYER_12x12 + (x/12) * 12 + ((y/12) * 12) * GRID_SIZE] == 0,
                "Already minted as 12x12"
            );
        } else {
            for (uint256 x12i = x; x12i < toX; x12i += 12) {
                for (uint256 y12i = y; y12i < toY; y12i += 12) {
                    uint256 id12x12 = LAYER_12x12 + x12i + y12i * GRID_SIZE;
                    require(_owners[id12x12] == 0, "Already minted as 12x12");
                }
            }
        }

        if (size <= 6) {
            require(_owners[LAYER_6x6 + (x/6) * 6 + ((y/6) * 6) * GRID_SIZE] == 0, "Already minted as 6x6");
        } else {
            for (uint256 x6i = x; x6i < toX; x6i += 6) {
                for (uint256 y6i = y; y6i < toY; y6i += 6) {
                    uint256 id6x6 = LAYER_6x6 + x6i + y6i * GRID_SIZE;
                    require(_owners[id6x6] == 0, "Already minted as 6x6");
                }
            }
        }

        if (size <= 3) {
            require(_owners[LAYER_3x3 + (x/3) * 3 + ((y/3) * 3) * GRID_SIZE] == 0, "Already minted as 3x3");
        } else {
            for (uint256 x3i = x; x3i < toX; x3i += 3) {
                for (uint256 y3i = y; y3i < toY; y3i += 3) {
                    uint256 id3x3 = LAYER_3x3 + x3i + y3i * GRID_SIZE;
                    require(_owners[id3x3] == 0, "Already minted as 3x3");
                }
            }
        }

        for (uint256 i = 0; i < size*size; i++) {
            uint256 id = _idInPath(i, size, x, y);
            require(_owners[id] == 0, "Already minted");
            emit Transfer(address(0), to, id);
        }

        _owners[quadId] = uint256(to);
        _numNFTPerAddress[to] += size * size;

        _checkBatchReceiverAcceptQuad(msg.sender, address(0), to, size, x, y, data);
    }

    function _idInPath(uint256 i, uint256 size, uint256 x, uint256 y) internal pure returns(uint256) {

        uint256 row = i / size;
        if(row % 2 == 0) { // allow ids to follow a path in a quad
            return (x + (i%size)) + ((y + row) * GRID_SIZE);
        } else {
            return ((x + size) - (1 + i%size)) + ((y + row) * GRID_SIZE);
        }
    }

    function transferQuad(address from, address to, uint256 size, uint256 x, uint256 y, bytes calldata data) external {

        require(from != address(0), "from is zero address");
        require(to != address(0), "can't send to zero address");
        bool metaTx = msg.sender != from && _metaTransactionContracts[msg.sender];
        if (msg.sender != from && !metaTx) {
            require(
                _operatorsForAll[from][msg.sender] ||
                _superOperators[msg.sender],
                "not authorized to transferQuad"
            );
        }
        _transferQuad(from, to, size, x, y);
        _numNFTPerAddress[from] -= size * size;
        _numNFTPerAddress[to] += size * size;

        _checkBatchReceiverAcceptQuad(metaTx ? from : msg.sender, from, to, size, x, y, data);
    }

    function _checkBatchReceiverAcceptQuad(
        address operator,
        address from,
        address to,
        uint256 size,
        uint256 x,
        uint256 y,
        bytes memory data
    ) internal {

        if (to.isContract() && _checkInterfaceWith10000Gas(to, ERC721_MANDATORY_RECEIVER)) {
            uint256[] memory ids = new uint256[](size*size);
            for (uint256 i = 0; i < size*size; i++) {
                ids[i] = _idInPath(i, size, x, y);
            }
            require(
                _checkOnERC721BatchReceived(operator, from, to, ids, data),
                "erc721 batch transfer rejected by to"
            );
        }
    }

    function batchTransferQuad(
        address from,
        address to,
        uint256[] calldata sizes,
        uint256[] calldata xs,
        uint256[] calldata ys,
        bytes calldata data
    ) external {

        require(from != address(0), "from is zero address");
        require(to != address(0), "can't send to zero address");
        require(sizes.length == xs.length && xs.length == ys.length, "invalid data");
        bool metaTx = msg.sender != from && _metaTransactionContracts[msg.sender];
        if (msg.sender != from && !metaTx) {
            require(
                _operatorsForAll[from][msg.sender] ||
                _superOperators[msg.sender],
                "not authorized to transferMultiQuads"
            );
        }
        uint256 numTokensTransfered = 0;
        for (uint256 i = 0; i < sizes.length; i++) {
            uint256 size = sizes[i];
            _transferQuad(from, to, size, xs[i], ys[i]);
            numTokensTransfered += size * size;
        }
        _numNFTPerAddress[from] -= numTokensTransfered;
        _numNFTPerAddress[to] += numTokensTransfered;

        if (to.isContract() && _checkInterfaceWith10000Gas(to, ERC721_MANDATORY_RECEIVER)) {
            uint256[] memory ids = new uint256[](numTokensTransfered);
            uint256 counter = 0;
            for (uint256 j = 0; j < sizes.length; j++) {
                uint256 size = sizes[j];
                for (uint256 i = 0; i < size*size; i++) {
                    ids[counter] = _idInPath(i, size, xs[j], ys[j]);
                    counter++;
                }
            }
            require(
                _checkOnERC721BatchReceived(metaTx ? from : msg.sender, from, to, ids, data),
                "erc721 batch transfer rejected by to"
            );
        }
    }

    function _transferQuad(address from, address to, uint256 size, uint256 x, uint256 y) internal {

        if (size == 1) {
            uint256 id1x1 = x + y * GRID_SIZE;
            address owner = _ownerOf(id1x1);
            require(owner != address(0), "token does not exist");
            require(owner == from, "not owner in _transferQuad");
            _owners[id1x1] = uint256(to);
        } else {
            _regroup(from, to, size, x, y);
        }
        for (uint256 i = 0; i < size*size; i++) {
            emit Transfer(from, to, _idInPath(i, size, x, y));
        }
    }

    function _checkAndClear(address from, uint256 id) internal returns(bool) {

        uint256 owner = _owners[id];
        if (owner != 0) {
            require(address(owner) == from, "not owner");
            _owners[id] = 0;
            return true;
        }
        return false;
    }

    function _regroup(address from, address to, uint256 size, uint256 x, uint256 y) internal {

        require(x % size == 0 && y % size == 0, "Invalid coordinates");
        require(x <= GRID_SIZE - size && y <= GRID_SIZE - size, "Out of bounds");

        if (size == 3) {
            _regroup3x3(from, to, x, y, true);
        } else if (size == 6) {
            _regroup6x6(from, to, x, y, true);
        } else if (size == 12) {
            _regroup12x12(from, to, x, y, true);
        } else if (size == 24) {
            _regroup24x24(from, to, x, y, true);
        } else {
            require(false, "Invalid size");
        }
    }

    function _regroup3x3(address from, address to, uint256 x, uint256 y, bool set) internal returns (bool) {

        uint256 id = x + y * GRID_SIZE;
        uint256 quadId = LAYER_3x3 + id;
        bool ownerOfAll = true;
        for (uint256 xi = x; xi < x+3; xi++) {
            for (uint256 yi = y; yi < y+3; yi++) {
                ownerOfAll = _checkAndClear(from, xi + yi * GRID_SIZE) && ownerOfAll;
            }
        }
        if(set) {
            if(!ownerOfAll) {
                require(
                    _ownerOfQuad(3, x, y) == from,
                    "not owner of all sub quads nor parent quads"
                );
            }
            _owners[quadId] = uint256(to);
            return true;
        }
        return ownerOfAll;
    }

    function _ownerOfQuad(uint256 size, uint256 x, uint256 y) internal returns (address) {

        uint256 layer;
        uint256 parentSize = size * 2;
        if (size == 3) {
            layer = LAYER_3x3;
        } else if (size == 6) {
            layer = LAYER_6x6;
        } else if (size == 12) {
            layer = LAYER_12x12;
        } else if (size == 24) {
            layer = LAYER_24x24;
        } else {
            require(false, "Invalid size");
        }
        address owner = address(_owners[layer + (x/size) * size + ((y/size) * size) * GRID_SIZE]);
        if (owner != address(0)) {
            return owner;
        } else if(size < 24) {
            return _ownerOfQuad(parentSize, x, y);
        }
        return address(0);
    }
    function _regroup6x6(address from, address to, uint256 x, uint256 y, bool set) internal returns (bool) {

        uint256 id = x + y * GRID_SIZE;
        uint256 quadId = LAYER_6x6 + id;
        bool ownerOfAll = true;
        for (uint256 xi = x; xi < x+6; xi += 3) {
            for (uint256 yi = y; yi < y+6; yi += 3) {
                bool ownAllIndividual = _regroup3x3(from, to, xi, yi, false);
                uint256 id3x3 = LAYER_3x3 + xi + yi * GRID_SIZE;
                uint256 owner3x3 = _owners[id3x3];
                if (owner3x3 != 0) {
                    if(!ownAllIndividual) {
                        require(owner3x3 == uint256(from), "not owner of 3x3 quad");
                    }
                    _owners[id3x3] = 0;
                }
                ownerOfAll = (ownAllIndividual || owner3x3 != 0) && ownerOfAll;
            }
        }
        if(set) {
            if(!ownerOfAll) {
                require(
                    _ownerOfQuad(6, x, y) == from,
                    "not owner of all sub quads nor parent quads"
                );
            }
            _owners[quadId] = uint256(to);
            return true;
        }
        return ownerOfAll;
    }
    function _regroup12x12(address from, address to, uint256 x, uint256 y, bool set) internal returns (bool) {

        uint256 id = x + y * GRID_SIZE;
        uint256 quadId = LAYER_12x12 + id;
        bool ownerOfAll = true;
        for (uint256 xi = x; xi < x+12; xi += 6) {
            for (uint256 yi = y; yi < y+12; yi += 6) {
                bool ownAllIndividual = _regroup6x6(from, to, xi, yi, false);
                uint256 id6x6 = LAYER_6x6 + xi + yi * GRID_SIZE;
                uint256 owner6x6 = _owners[id6x6];
                if (owner6x6 != 0) {
                    if(!ownAllIndividual) {
                        require(owner6x6 == uint256(from), "not owner of 6x6 quad");
                    }
                    _owners[id6x6] = 0;
                }
                ownerOfAll = (ownAllIndividual || owner6x6 != 0) && ownerOfAll;
            }
        }
        if(set) {
            if(!ownerOfAll) {
                require(
                    _ownerOfQuad(12, x, y) == from,
                    "not owner of all sub quads nor parent quads"
                );
            }
            _owners[quadId] = uint256(to);
            return true;
        }
        return ownerOfAll;
    }
    function _regroup24x24(address from, address to, uint256 x, uint256 y, bool set) internal returns (bool) {

        uint256 id = x + y * GRID_SIZE;
        uint256 quadId = LAYER_24x24 + id;
        bool ownerOfAll = true;
        for (uint256 xi = x; xi < x+24; xi += 12) {
            for (uint256 yi = y; yi < y+24; yi += 12) {
                bool ownAllIndividual = _regroup12x12(from, to, xi, yi, false);
                uint256 id12x12 = LAYER_12x12 + xi + yi * GRID_SIZE;
                uint256 owner12x12 = _owners[id12x12];
                if (owner12x12 != 0) {
                    if(!ownAllIndividual) {
                        require(owner12x12 == uint256(from), "not owner of 12x12 quad");
                    }
                    _owners[id12x12] = 0;
                }
                ownerOfAll = (ownAllIndividual || owner12x12 != 0) && ownerOfAll;
            }
        }
        if(set) {
            if(!ownerOfAll) {
                require(
                    _ownerOfQuad(24, x, y) == from,
                    "not owner of all sub quads not parent quad"
                );
            }
            _owners[quadId] = uint256(to);
            return true;
        }
        return ownerOfAll || _owners[quadId] == uint256(from);
    }

    function _ownerOf(uint256 id) internal view returns (address) {

        require(id & LAYER == 0, "Invalid token id");
        uint256 x = id % GRID_SIZE;
        uint256 y = id / GRID_SIZE;
        uint256 owner1x1 = _owners[id];

        if (owner1x1 != 0) {
            return address(owner1x1); // cast to zero
        } else {
            address owner3x3 = address(_owners[LAYER_3x3 + (x/3) * 3 + ((y/3) * 3) * GRID_SIZE]);
            if (owner3x3 != address(0)) {
                return owner3x3;
            } else {
                address owner6x6 = address(_owners[LAYER_6x6 + (x/6) * 6 + ((y/6) * 6) * GRID_SIZE]);
                if (owner6x6 != address(0)) {
                    return owner6x6;
                } else {
                    address owner12x12 = address(_owners[LAYER_12x12 + (x/12) * 12 + ((y/12) * 12) * GRID_SIZE]);
                    if (owner12x12 != address(0)) {
                        return owner12x12;
                    } else {
                        return address(_owners[LAYER_24x24 + (x/24) * 24 + ((y/24) * 24) * GRID_SIZE]);
                    }
                }
            }
        }
    }

    function _ownerAndOperatorEnabledOf(uint256 id) internal view returns (address owner, bool operatorEnabled) {

        require(id & LAYER == 0, "Invalid token id");
        uint256 x = id % GRID_SIZE;
        uint256 y = id / GRID_SIZE;
        uint256 owner1x1 = _owners[id];

        if (owner1x1 != 0) {
            owner = address(owner1x1);
            operatorEnabled = (owner1x1 / 2**255) == 1;
        } else {
            address owner3x3 = address(_owners[LAYER_3x3 + (x/3) * 3 + ((y/3) * 3) * GRID_SIZE]);
            if (owner3x3 != address(0)) {
                owner = owner3x3;
                operatorEnabled = false;
            } else {
                address owner6x6 = address(_owners[LAYER_6x6 + (x/6) * 6 + ((y/6) * 6) * GRID_SIZE]);
                if (owner6x6 != address(0)) {
                    owner = owner6x6;
                    operatorEnabled = false;
                } else {
                    address owner12x12 = address(_owners[LAYER_12x12 + (x/12) * 12 + ((y/12) * 12) * GRID_SIZE]);
                    if (owner12x12 != address(0)) {
                        owner = owner12x12;
                        operatorEnabled = false;
                    } else {
                        owner = address(_owners[LAYER_24x24 + (x/24) * 24 + ((y/24) * 24) * GRID_SIZE]);
                        operatorEnabled = false;
                    }
                }
            }
        }
    }

}/* solhint-disable no-empty-blocks */

pragma solidity 0.5.9;


contract LandV2 is LandBaseTokenV2 {

    function name() external pure returns (string memory) {

        return "Sandbox's LANDs";
    }

    function symbol() external pure returns (string memory) {

        return "LAND";
    }

    function uint2str(uint _i) internal pure returns (string memory) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function tokenURI(uint256 id) public view returns (string memory) {

        require(_ownerOf(id) != address(0), "Id does not exist");
        return
            string(
                abi.encodePacked(
                    "https://api.sandbox.game/lands/",
                    uint2str(id),
                    "/metadata.json"
                )
            );
    }

    function supportsInterface(bytes4 id) external pure returns (bool) {

        return id == 0x01ffc9a7 || id == 0x80ac58cd || id == 0x5b5e139f;
    }
}