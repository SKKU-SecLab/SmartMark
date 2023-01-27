pragma solidity 0.6.5;


library SafeMathWithRequire {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }

        c = a * b;
        require(c / a == b, "overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "divbyzero");
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "undeflow");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;
        require(c >= a, "overflow");
        return c;
    }
}pragma solidity 0.6.5;


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

    modifier onlyAdmin() {

        require(msg.sender == _admin, "only admin allowed");
        _;
    }
}pragma solidity 0.6.5;



contract SuperOperators is Admin {

    mapping(address => bool) internal _superOperators;

    event SuperOperator(address superOperator, bool enabled);

    function setSuperOperator(address superOperator, bool enabled) external {

        require(msg.sender == _admin, "only admin is allowed to add super operators");
        _superOperators[superOperator] = enabled;
        emit SuperOperator(superOperator, enabled);
    }

    function isSuperOperator(address who) public view returns (bool) {

        return _superOperators[who];
    }
}pragma solidity 0.6.5;



contract MetaTransactionReceiver is Admin {

    mapping(address => bool) internal _metaTransactionContracts;

    event MetaTransactionProcessor(address metaTransactionProcessor, bool enabled);

    function setMetaTransactionProcessor(address metaTransactionProcessor, bool enabled) public {

        require(msg.sender == _admin, "only admin can setup metaTransactionProcessors");
        _setMetaTransactionProcessor(metaTransactionProcessor, enabled);
    }

    function _setMetaTransactionProcessor(address metaTransactionProcessor, bool enabled) internal {

        _metaTransactionContracts[metaTransactionProcessor] = enabled;
        emit MetaTransactionProcessor(metaTransactionProcessor, enabled);
    }

    function isMetaTransactionProcessor(address who) external view returns (bool) {

        return _metaTransactionContracts[who];
    }
}pragma solidity 0.6.5;




contract ERC20SubToken {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function groupTokenId() external view returns (uint256) {

        return _index;
    }

    function groupAddress() external view returns (address) {

        return address(_group);
    }

    function totalSupply() external view returns (uint256) {

        return _group.supplyOf(_index);
    }

    function balanceOf(address who) external view returns (uint256) {

        return _group.balanceOf(who, _index);
    }

    function decimals() external pure returns (uint8) {

        return uint8(0);
    }

    function transfer(address to, uint256 amount) external returns (bool success) {

        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool success) {

        if (msg.sender != from && !_group.isAuthorizedToTransfer(from, msg.sender)) {
            uint256 allowance = _mAllowed[from][msg.sender];
            if (allowance != ~uint256(0)) {
                require(allowance >= amount, "NOT_AUTHOIZED_ALLOWANCE");
                _mAllowed[from][msg.sender] = allowance - amount;
            }
        }
        _transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool success) {

        _approveFor(msg.sender, spender, amount);
        return true;
    }

    function approveFor(
        address from,
        address spender,
        uint256 amount
    ) external returns (bool success) {

        require(msg.sender == from || _group.isAuthorizedToApprove(msg.sender), "NOT_AUTHORIZED");
        _approveFor(from, spender, amount);
        return true;
    }

    function emitTransferEvent(
        address from,
        address to,
        uint256 amount
    ) external {

        require(msg.sender == address(_group), "NOT_AUTHORIZED_GROUP_ONLY");
        emit Transfer(from, to, amount);
    }


    function _approveFor(
        address owner,
        address spender,
        uint256 amount
    ) internal {

        require(owner != address(0) && spender != address(0), "INVALID_FROM_OR_SPENDER");
        _mAllowed[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender) external view returns (uint256 remaining) {

        return _mAllowed[owner][spender];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {

        _group.singleTransferFrom(from, to, _index, amount);
    }

    using SafeMathWithRequire for uint256;

    constructor(
        ERC20Group group,
        uint256 index,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        _group = group;
        _index = index;
        _name = tokenName;
        _symbol = tokenSymbol;
    }

    ERC20Group internal immutable _group;
    uint256 internal immutable _index;
    mapping(address => mapping(address => uint256)) internal _mAllowed;
    string internal _name;
    string internal _symbol;
}pragma solidity 0.6.5;


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
}pragma solidity 0.6.5;


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
}pragma solidity 0.6.5;



library ObjectLib32 {

    using SafeMathWithRequire for uint256;
    enum Operations {ADD, SUB, REPLACE}
    uint256 constant TYPES_BITS_SIZE = 32; // Max size of each object
    uint256 constant TYPES_PER_UINT256 = 256 / TYPES_BITS_SIZE; // Number of types per uint256


    function getTokenBinIndex(uint256 tokenId) internal pure returns (uint256 bin, uint256 index) {

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
            newBinBalance = writeValueInBin(binBalances, index, objectBalance.add(amount));
        } else if (operation == Operations.SUB) {
            objectBalance = getValueInBin(binBalances, index);
            require(objectBalance >= amount, "can't substract more than there is");
            newBinBalance = writeValueInBin(binBalances, index, objectBalance.sub(amount));
        } else if (operation == Operations.REPLACE) {
            newBinBalance = writeValueInBin(binBalances, index, amount);
        } else {
            revert("Invalid operation"); // Bad operation
        }

        return newBinBalance;
    }

    function getValueInBin(uint256 binValue, uint256 index) internal pure returns (uint256) {

        uint256 mask = (uint256(1) << TYPES_BITS_SIZE) - 1;

        uint256 rightShift = 256 - TYPES_BITS_SIZE * (index + 1);
        return (binValue >> rightShift) & mask;
    }

    function writeValueInBin(
        uint256 binValue,
        uint256 index,
        uint256 amount
    ) internal pure returns (uint256) {

        require(amount < 2**TYPES_BITS_SIZE, "Amount to write in bin is too large");

        uint256 mask = (uint256(1) << TYPES_BITS_SIZE) - 1;

        uint256 leftShift = 256 - TYPES_BITS_SIZE * (index + 1);
        return (binValue & ~(mask << leftShift)) | (amount << leftShift);
    }
}pragma solidity 0.6.5;


library BytesUtil {

    function memcpy(
        uint256 dest,
        uint256 src,
        uint256 len
    ) internal pure {

        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint256 mask = 256**(32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function pointerToBytes(uint256 src, uint256 len) internal pure returns (bytes memory) {

        bytes memory ret = new bytes(len);
        uint256 retptr;
        assembly {
            retptr := add(ret, 32)
        }

        memcpy(retptr, src, len);
        return ret;
    }

    function addressToBytes(address a) internal pure returns (bytes memory b) {

        assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
            mstore(0x40, add(m, 52))
            b := m
        }
    }

    function uint256ToBytes(uint256 a) internal pure returns (bytes memory b) {

        assembly {
            let m := mload(0x40)
            mstore(add(m, 32), a)
            mstore(0x40, add(m, 64))
            b := m
        }
    }

    function doFirstParamEqualsAddress(bytes memory data, address _address) internal pure returns (bool) {

        if (data.length < (36 + 32)) {
            return false;
        }
        uint256 value;
        assembly {
            value := mload(add(data, 36))
        }
        return value == uint256(_address);
    }

    function doParamEqualsUInt256(
        bytes memory data,
        uint256 i,
        uint256 value
    ) internal pure returns (bool) {

        if (data.length < (36 + (i + 1) * 32)) {
            return false;
        }
        uint256 offset = 36 + i * 32;
        uint256 valuePresent;
        assembly {
            valuePresent := mload(add(data, offset))
        }
        return valuePresent == value;
    }

    function overrideFirst32BytesWithAddress(bytes memory data, address _address) internal pure returns (bytes memory) {

        uint256 dest;
        assembly {
            dest := add(data, 48)
        } // 48 = 32 (offset) + 4 (func sig) + 12 (address is only 20 bytes)

        bytes memory addressBytes = addressToBytes(_address);
        uint256 src;
        assembly {
            src := add(addressBytes, 32)
        }

        memcpy(dest, src, 20);
        return data;
    }

    function overrideFirstTwo32BytesWithAddressAndInt(
        bytes memory data,
        address _address,
        uint256 _value
    ) internal pure returns (bytes memory) {

        uint256 dest;
        uint256 src;

        assembly {
            dest := add(data, 48)
        } // 48 = 32 (offset) + 4 (func sig) + 12 (address is only 20 bytes)
        bytes memory bbytes = addressToBytes(_address);
        assembly {
            src := add(bbytes, 32)
        }
        memcpy(dest, src, 20);

        assembly {
            dest := add(data, 68)
        } // 48 = 32 (offset) + 4 (func sig) + 32 (next slot)
        bbytes = uint256ToBytes(_value);
        assembly {
            src := add(bbytes, 32)
        }
        memcpy(dest, src, 32);

        return data;
    }
}pragma solidity 0.6.5;
pragma experimental ABIEncoderV2;




contract ERC20Group is SuperOperators, MetaTransactionReceiver {

    uint256 internal constant MAX_UINT256 = ~uint256(0);

    event SubToken(ERC20SubToken subToken);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    event Minter(address minter, bool enabled);

    function setMinter(address minter, bool enabled) external {

        require(msg.sender == _admin, "NOT_AUTHORIZED_ADMIN");
        _setMinter(minter, enabled);
    }

    function isMinter(address who) public view returns (bool) {

        return _minters[who];
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount
    ) external {

        require(_minters[msg.sender], "NOT_AUTHORIZED_MINTER");
        (uint256 bin, uint256 index) = id.getTokenBinIndex();
        mapping(uint256 => uint256) storage toPack = _packedTokenBalance[to];
        toPack[bin] = toPack[bin].updateTokenBalance(index, amount, ObjectLib32.Operations.ADD);
        _packedSupplies[bin] = _packedSupplies[bin].updateTokenBalance(index, amount, ObjectLib32.Operations.ADD);
        _erc20s[id].emitTransferEvent(address(0), to, amount);
    }

    function batchMint(
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external {

        require(_minters[msg.sender], "NOT_AUTHORIZED_MINTER");
        require(ids.length == amounts.length, "INVALID_INCONSISTENT_LENGTH");
        _batchMint(to, ids, amounts);
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal {

        uint256 lastBin = MAX_UINT256;
        uint256 bal = 0;
        uint256 supply = 0;
        mapping(uint256 => uint256) storage toPack = _packedTokenBalance[to];
        for (uint256 i = 0; i < ids.length; i++) {
            if (amounts[i] != 0) {
                (uint256 bin, uint256 index) = ids[i].getTokenBinIndex();
                if (lastBin == MAX_UINT256) {
                    lastBin = bin;
                    bal = toPack[bin].updateTokenBalance(index, amounts[i], ObjectLib32.Operations.ADD);
                    supply = _packedSupplies[bin].updateTokenBalance(index, amounts[i], ObjectLib32.Operations.ADD);
                } else {
                    if (bin != lastBin) {
                        toPack[lastBin] = bal;
                        bal = toPack[bin];
                        _packedSupplies[lastBin] = supply;
                        supply = _packedSupplies[bin];
                        lastBin = bin;
                    }
                    bal = bal.updateTokenBalance(index, amounts[i], ObjectLib32.Operations.ADD);
                    supply = supply.updateTokenBalance(index, amounts[i], ObjectLib32.Operations.ADD);
                }
                _erc20s[ids[i]].emitTransferEvent(address(0), to, amounts[i]);
            }
        }
        if (lastBin != MAX_UINT256) {
            toPack[lastBin] = bal;
            _packedSupplies[lastBin] = supply;
        }
    }

    function supplyOf(uint256 id) external view returns (uint256 supply) {

        (uint256 bin, uint256 index) = id.getTokenBinIndex();
        return _packedSupplies[bin].getValueInBin(index);
    }

    function balanceOf(address owner, uint256 id) public view returns (uint256 balance) {

        (uint256 bin, uint256 index) = id.getTokenBinIndex();
        return _packedTokenBalance[owner][bin].getValueInBin(index);
    }

    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids) external view returns (uint256[] memory balances) {

        require(owners.length == ids.length, "INVALID_INCONSISTENT_LENGTH");
        balances = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            balances[i] = balanceOf(owners[i], ids[i]);
        }
    }

    function singleTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value
    ) external {

        require(to != address(0), "INVALID_TO_ZERO_ADDRESS");
        ERC20SubToken erc20 = _erc20s[id];
        require(
            from == msg.sender ||
                msg.sender == address(erc20) ||
                _metaTransactionContracts[msg.sender] ||
                _superOperators[msg.sender] ||
                _operatorsForAll[from][msg.sender],
            "NOT_AUTHORIZED"
        );

        (uint256 bin, uint256 index) = id.getTokenBinIndex();
        mapping(uint256 => uint256) storage fromPack = _packedTokenBalance[from];
        mapping(uint256 => uint256) storage toPack = _packedTokenBalance[to];
        fromPack[bin] = fromPack[bin].updateTokenBalance(index, value, ObjectLib32.Operations.SUB);
        toPack[bin] = toPack[bin].updateTokenBalance(index, value, ObjectLib32.Operations.ADD);
        erc20.emitTransferEvent(from, to, value);
    }

    function batchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values
    ) external {

        require(ids.length == values.length, "INVALID_INCONSISTENT_LENGTH");
        require(to != address(0), "INVALID_TO_ZERO_ADDRESS");
        require(
            from == msg.sender || _superOperators[msg.sender] || _operatorsForAll[from][msg.sender] || _metaTransactionContracts[msg.sender],
            "NOT_AUTHORIZED"
        );
        _batchTransferFrom(from, to, ids, values);
    }

    function _batchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal {

        uint256 lastBin = MAX_UINT256;
        uint256 balFrom;
        uint256 balTo;
        mapping(uint256 => uint256) storage fromPack = _packedTokenBalance[from];
        mapping(uint256 => uint256) storage toPack = _packedTokenBalance[to];
        for (uint256 i = 0; i < ids.length; i++) {
            if (values[i] != 0) {
                (uint256 bin, uint256 index) = ids[i].getTokenBinIndex();
                if (lastBin == MAX_UINT256) {
                    lastBin = bin;
                    balFrom = ObjectLib32.updateTokenBalance(fromPack[bin], index, values[i], ObjectLib32.Operations.SUB);
                    balTo = ObjectLib32.updateTokenBalance(toPack[bin], index, values[i], ObjectLib32.Operations.ADD);
                } else {
                    if (bin != lastBin) {
                        fromPack[lastBin] = balFrom;
                        toPack[lastBin] = balTo;
                        balFrom = fromPack[bin];
                        balTo = toPack[bin];
                        lastBin = bin;
                    }
                    balFrom = balFrom.updateTokenBalance(index, values[i], ObjectLib32.Operations.SUB);
                    balTo = balTo.updateTokenBalance(index, values[i], ObjectLib32.Operations.ADD);
                }
                ERC20SubToken erc20 = _erc20s[ids[i]];
                erc20.emitTransferEvent(from, to, values[i]);
            }
        }
        if (lastBin != MAX_UINT256) {
            fromPack[lastBin] = balFrom;
            toPack[lastBin] = balTo;
        }
    }

    function setApprovalForAllFor(
        address sender,
        address operator,
        bool approved
    ) external {

        require(msg.sender == sender || _metaTransactionContracts[msg.sender] || _superOperators[msg.sender], "NOT_AUTHORIZED");
        _setApprovalForAll(sender, operator, approved);
    }

    function setApprovalForAll(address operator, bool approved) external {

        _setApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool isOperator) {

        return _operatorsForAll[owner][operator] || _superOperators[operator];
    }

    function isAuthorizedToTransfer(address owner, address sender) external view returns (bool) {

        return _metaTransactionContracts[sender] || _superOperators[sender] || _operatorsForAll[owner][sender];
    }

    function isAuthorizedToApprove(address sender) external view returns (bool) {

        return _metaTransactionContracts[sender] || _superOperators[sender];
    }

    function batchBurnFrom(
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external {

        require(from != address(0), "INVALID_FROM_ZERO_ADDRESS");
        require(
            from == msg.sender || _metaTransactionContracts[msg.sender] || _superOperators[msg.sender] || _operatorsForAll[from][msg.sender],
            "NOT_AUTHORIZED"
        );

        _batchBurnFrom(from, ids, amounts);
    }

    function burnFrom(
        address from,
        uint256 id,
        uint256 value
    ) external {

        require(
            from == msg.sender || _superOperators[msg.sender] || _operatorsForAll[from][msg.sender] || _metaTransactionContracts[msg.sender],
            "NOT_AUTHORIZED"
        );
        _burn(from, id, value);
    }

    function burn(uint256 id, uint256 value) external {

        _burn(msg.sender, id, value);
    }


    function _batchBurnFrom(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal {

        uint256 balFrom = 0;
        uint256 supply = 0;
        uint256 lastBin = MAX_UINT256;
        mapping(uint256 => uint256) storage fromPack = _packedTokenBalance[from];
        for (uint256 i = 0; i < ids.length; i++) {
            if (amounts[i] != 0) {
                (uint256 bin, uint256 index) = ids[i].getTokenBinIndex();
                if (lastBin == MAX_UINT256) {
                    lastBin = bin;
                    balFrom = fromPack[bin].updateTokenBalance(index, amounts[i], ObjectLib32.Operations.SUB);
                    supply = _packedSupplies[bin].updateTokenBalance(index, amounts[i], ObjectLib32.Operations.SUB);
                } else {
                    if (bin != lastBin) {
                        fromPack[lastBin] = balFrom;
                        balFrom = fromPack[bin];
                        _packedSupplies[lastBin] = supply;
                        supply = _packedSupplies[bin];
                        lastBin = bin;
                    }

                    balFrom = balFrom.updateTokenBalance(index, amounts[i], ObjectLib32.Operations.SUB);
                    supply = supply.updateTokenBalance(index, amounts[i], ObjectLib32.Operations.SUB);
                }
                _erc20s[ids[i]].emitTransferEvent(from, address(0), amounts[i]);
            }
        }
        if (lastBin != MAX_UINT256) {
            fromPack[lastBin] = balFrom;
            _packedSupplies[lastBin] = supply;
        }
    }

    function _burn(
        address from,
        uint256 id,
        uint256 value
    ) internal {

        ERC20SubToken erc20 = _erc20s[id];
        (uint256 bin, uint256 index) = id.getTokenBinIndex();
        mapping(uint256 => uint256) storage fromPack = _packedTokenBalance[from];
        fromPack[bin] = ObjectLib32.updateTokenBalance(fromPack[bin], index, value, ObjectLib32.Operations.SUB);
        _packedSupplies[bin] = ObjectLib32.updateTokenBalance(_packedSupplies[bin], index, value, ObjectLib32.Operations.SUB);
        erc20.emitTransferEvent(from, address(0), value);
    }

    function _addSubToken(ERC20SubToken subToken) internal returns (uint256 id) {

        id = _erc20s.length;
        require(subToken.groupAddress() == address(this), "INVALID_GROUP");
        require(subToken.groupTokenId() == id, "INVALID_ID");
        _erc20s.push(subToken);
        emit SubToken(subToken);
    }

    function _setApprovalForAll(
        address sender,
        address operator,
        bool approved
    ) internal {

        require(!_superOperators[operator], "INVALID_SUPER_OPERATOR");
        _operatorsForAll[sender][operator] = approved;
        emit ApprovalForAll(sender, operator, approved);
    }

    function _setMinter(address minter, bool enabled) internal {

        _minters[minter] = enabled;
        emit Minter(minter, enabled);
    }

    using AddressUtils for address;
    using ObjectLib32 for ObjectLib32.Operations;
    using ObjectLib32 for uint256;
    using SafeMath for uint256;

    mapping(uint256 => uint256) internal _packedSupplies;
    mapping(address => mapping(uint256 => uint256)) internal _packedTokenBalance;
    mapping(address => mapping(address => bool)) internal _operatorsForAll;
    ERC20SubToken[] internal _erc20s;
    mapping(address => bool) internal _minters;


    struct SubTokenData {
        string name;
        string symbol;
    }

    constructor(
        address metaTransactionContract,
        address admin,
        address initialMinter
    ) internal {
        _admin = admin;
        _setMetaTransactionProcessor(metaTransactionContract, true);
        _setMinter(initialMinter, true);
    }
}pragma solidity 0.6.5;


interface CatalystValue {

    struct GemEvent {
        uint256[] gemIds;
        bytes32 blockHash;
    }

    function getValues(
        uint256 catalystId,
        uint256 seed,
        GemEvent[] calldata events,
        uint32 totalNumberOfGemTypes
    ) external view returns (uint32[] memory values);

}pragma solidity 0.6.5;



contract CatalystDataBase is CatalystValue {

    event CatalystConfiguration(uint256 indexed id, uint16 minQuantity, uint16 maxQuantity, uint256 sandMintingFee, uint256 sandUpdateFee);

    function _setMintData(uint256 id, MintData memory data) internal {

        _data[id] = data;
        _emitConfiguration(id, data.minQuantity, data.maxQuantity, data.sandMintingFee, data.sandUpdateFee);
    }

    function _setValueOverride(uint256 id, CatalystValue valueOverride) internal {

        _valueOverrides[id] = valueOverride;
    }

    function _setConfiguration(
        uint256 id,
        uint16 minQuantity,
        uint16 maxQuantity,
        uint256 sandMintingFee,
        uint256 sandUpdateFee
    ) internal {

        _data[id].minQuantity = minQuantity;
        _data[id].maxQuantity = maxQuantity;
        _data[id].sandMintingFee = uint88(sandMintingFee);
        _data[id].sandUpdateFee = uint88(sandUpdateFee);
        _emitConfiguration(id, minQuantity, maxQuantity, sandMintingFee, sandUpdateFee);
    }

    function _emitConfiguration(
        uint256 id,
        uint16 minQuantity,
        uint16 maxQuantity,
        uint256 sandMintingFee,
        uint256 sandUpdateFee
    ) internal {

        emit CatalystConfiguration(id, minQuantity, maxQuantity, sandMintingFee, sandUpdateFee);
    }

    function _computeValue(
        uint256 seed,
        uint256 gemId,
        bytes32 blockHash,
        uint256 slotIndex,
        uint32 min
    ) internal pure returns (uint32) {

        return min + uint16(uint256(keccak256(abi.encodePacked(gemId, seed, blockHash, slotIndex))) % (26 - min));
    }

    function getValues(
        uint256 catalystId,
        uint256 seed,
        GemEvent[] calldata events,
        uint32 totalNumberOfGemTypes
    ) external override view returns (uint32[] memory values) {

        CatalystValue valueOverride = _valueOverrides[catalystId];
        if (address(valueOverride) != address(0)) {
            return valueOverride.getValues(catalystId, seed, events, totalNumberOfGemTypes);
        }
        values = new uint32[](totalNumberOfGemTypes);

        uint32 numGems;
        for (uint256 i = 0; i < events.length; i++) {
            numGems += uint32(events[i].gemIds.length);
        }
        require(numGems <= MAX_UINT32, "TOO_MANY_GEMS");
        uint32 minValue = (numGems - 1) * 5 + 1;

        uint256 numGemsSoFar = 0;
        for (uint256 i = 0; i < events.length; i++) {
            numGemsSoFar += events[i].gemIds.length;
            for (uint256 j = 0; j < events[i].gemIds.length; j++) {
                uint256 gemId = events[i].gemIds[j];
                uint256 slotIndex = numGemsSoFar - events[i].gemIds.length + j;
                if (values[gemId] == 0) {
                    values[gemId] = _computeValue(seed, gemId, events[i].blockHash, slotIndex, (uint32(numGemsSoFar) - 1) * 5 + 1);
                    if (values[gemId] < minValue) {
                        values[gemId] = minValue;
                    }
                } else {
                    uint32 newRoll = _computeValue(seed, gemId, events[i].blockHash, slotIndex, 1);
                    values[gemId] = (((values[gemId] - 1) / 25) + 1) * 25 + newRoll;
                }
            }
        }
    }

    function getMintData(uint256 catalystId)
        external
        view
        returns (
            uint16 maxGems,
            uint16 minQuantity,
            uint16 maxQuantity,
            uint256 sandMintingFee,
            uint256 sandUpdateFee
        )
    {

        maxGems = _data[catalystId].maxGems;
        minQuantity = _data[catalystId].minQuantity;
        maxQuantity = _data[catalystId].maxQuantity;
        sandMintingFee = _data[catalystId].sandMintingFee;
        sandUpdateFee = _data[catalystId].sandUpdateFee;
    }

    struct MintData {
        uint88 sandMintingFee;
        uint88 sandUpdateFee;
        uint16 minQuantity;
        uint16 maxQuantity;
        uint16 maxGems;
    }

    uint32 internal constant MAX_UINT32 = 2**32 - 1;

    mapping(uint256 => MintData) internal _data;
    mapping(uint256 => CatalystValue) internal _valueOverrides;
}pragma solidity 0.6.5;



contract ERC20GroupCatalyst is CatalystDataBase, ERC20Group {

    function addCatalysts(
        ERC20SubToken[] memory catalysts,
        MintData[] memory mintData,
        CatalystValue[] memory valueOverrides
    ) public {

        require(msg.sender == _admin, "NOT_AUTHORIZED_ADMIN");
        require(catalysts.length == mintData.length, "INVALID_INCONSISTENT_LENGTH");
        for (uint256 i = 0; i < mintData.length; i++) {
            uint256 id = _addSubToken(catalysts[i]);
            _setMintData(id, mintData[i]);
            if (valueOverrides.length > i) {
                _setValueOverride(id, valueOverrides[i]);
            }
        }
    }

    function addCatalyst(
        ERC20SubToken catalyst,
        MintData memory mintData,
        CatalystValue valueOverride
    ) public {

        require(msg.sender == _admin, "NOT_AUTHORIZED_ADMIN");
        uint256 id = _addSubToken(catalyst);
        _setMintData(id, mintData);
        _setValueOverride(id, valueOverride);
    }

    function setConfiguration(
        uint256 id,
        uint16 minQuantity,
        uint16 maxQuantity,
        uint256 sandMintingFee,
        uint256 sandUpdateFee
    ) external {

        require(msg.sender == _admin, "NOT_AUTHORIZED_ADMIN");
        _setConfiguration(id, minQuantity, maxQuantity, sandMintingFee, sandUpdateFee);
    }

    constructor(
        address metaTransactionContract,
        address admin,
        address initialMinter
    ) public ERC20Group(metaTransactionContract, admin, initialMinter) {}
}pragma solidity 0.6.5;



contract ERC20GroupGem is ERC20Group {

    function addGems(ERC20SubToken[] calldata catalysts) external {

        require(msg.sender == _admin, "NOT_AUTHORIZED_ADMIN");
        for (uint256 i = 0; i < catalysts.length; i++) {
            _addSubToken(catalysts[i]);
        }
    }

    constructor(
        address metaTransactionContract,
        address admin,
        address initialMinter
    ) public ERC20Group(metaTransactionContract, admin, initialMinter) {}
}pragma solidity 0.6.5;


library SigUtil {

    function recover(bytes32 hash, bytes memory sig) internal pure returns (address recovered) {

        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28);

        recovered = ecrecover(hash, v, r, s);
        require(recovered != address(0));
    }

    function recoverWithZeroOnFailure(bytes32 hash, bytes memory sig) internal pure returns (address) {

        if (sig.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    function prefixed(bytes32 hash) internal pure returns (bytes memory) {

        return abi.encodePacked("\x19Ethereum Signed Message:\n32", hash);
    }
}pragma solidity 0.6.5;



contract PurchaseValidator is Admin {

    address private _signingWallet;

    mapping(address => mapping(uint128 => uint128)) public queuedNonces;

    function getNonceByBuyer(address _buyer, uint128 _queueId) external view returns (uint128) {

        return queuedNonces[_buyer][_queueId];
    }

    function isPurchaseValid(
        address buyer,
        uint256[] memory catalystIds,
        uint256[] memory catalystQuantities,
        uint256[] memory gemIds,
        uint256[] memory gemQuantities,
        uint256 nonce,
        bytes memory signature
    ) public returns (bool) {

        require(_checkAndUpdateNonce(buyer, nonce), "INVALID_NONCE");
        bytes32 hashedData = keccak256(abi.encodePacked(catalystIds, catalystQuantities, gemIds, gemQuantities, buyer, nonce));

        address signer = SigUtil.recover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hashedData)), signature);
        return signer == _signingWallet;
    }

    function getSigningWallet() external view returns (address) {

        return _signingWallet;
    }

    function updateSigningWallet(address newSigningWallet) external {

        require(_admin == msg.sender, "SENDER_NOT_ADMIN");
        _signingWallet = newSigningWallet;
    }

    function _checkAndUpdateNonce(address _buyer, uint256 _packedValue) private returns (bool) {

        uint128 queueId = uint128(_packedValue / 2**128);
        uint128 nonce = uint128(_packedValue % 2**128);
        uint128 currentNonce = queuedNonces[_buyer][queueId];
        if (nonce == currentNonce) {
            queuedNonces[_buyer][queueId] = currentNonce + 1;
            return true;
        }
        return false;
    }

    constructor(address initialSigningWallet) public {
        _signingWallet = initialSigningWallet;
    }
}pragma solidity 0.6.5;


interface ERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256 supply);


    function balanceOf(address who) external view returns (uint256 balance);


    function transfer(address to, uint256 value) external returns (bool success);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool success);


    function approve(address spender, uint256 value) external returns (bool success);


    function allowance(address owner, address spender) external view returns (uint256 amount);

}pragma solidity 0.6.5;


interface Medianizer {

    function read() external view returns (bytes32);

}pragma solidity 0.6.5;



contract StarterPackV1 is Admin, MetaTransactionReceiver, PurchaseValidator {

    using SafeMathWithRequire for uint256;
    uint256 internal constant DAI_PRICE = 44000000000000000;
    uint256 private constant DECIMAL_PLACES = 1 ether;

    ERC20 internal immutable _sand;
    Medianizer private immutable _medianizer;
    ERC20 private immutable _dai;
    ERC20Group internal immutable _erc20GroupCatalyst;
    ERC20Group internal immutable _erc20GroupGem;

    bool _sandEnabled;
    bool _etherEnabled;
    bool _daiEnabled;

    uint256[] private _starterPackPrices;
    uint256[] private _previousStarterPackPrices;
    uint256 private _gemPrice;
    uint256 private _previousGemPrice;

    uint256 private _priceChangeTimestamp;

    address payable internal _wallet;

    uint256 private constant PRICE_CHANGE_DELAY = 1 hours;

    event Purchase(address indexed buyer, Message message, uint256 price, address token, uint256 amountPaid);

    event SetPrices(uint256[] prices, uint256 gemPrice);

    struct Message {
        uint256[] catalystIds;
        uint256[] catalystQuantities;
        uint256[] gemIds;
        uint256[] gemQuantities;
        uint256 nonce;
    }


    function setReceivingWallet(address payable newWallet) external {

        require(newWallet != address(0), "WALLET_ZERO_ADDRESS");
        require(msg.sender == _admin, "NOT_AUTHORIZED");
        _wallet = newWallet;
    }

    function setDAIEnabled(bool enabled) external {

        require(msg.sender == _admin, "NOT_AUTHORIZED");
        _daiEnabled = enabled;
    }

    function isDAIEnabled() external view returns (bool) {

        return _daiEnabled;
    }

    function setETHEnabled(bool enabled) external {

        require(msg.sender == _admin, "NOT_AUTHORIZED");
        _etherEnabled = enabled;
    }

    function isETHEnabled() external view returns (bool) {

        return _etherEnabled;
    }

    function setSANDEnabled(bool enabled) external {

        require(msg.sender == _admin, "NOT_AUTHORIZED");
        _sandEnabled = enabled;
    }

    function isSANDEnabled() external view returns (bool) {

        return _sandEnabled;
    }


    function purchaseWithSand(
        address buyer,
        Message calldata message,
        bytes calldata signature
    ) external {

        require(msg.sender == buyer || _metaTransactionContracts[msg.sender], "INVALID_SENDER");
        require(_sandEnabled, "SAND_IS_NOT_ENABLED");
        require(buyer != address(0), "DESTINATION_ZERO_ADDRESS");
        require(
            isPurchaseValid(buyer, message.catalystIds, message.catalystQuantities, message.gemIds, message.gemQuantities, message.nonce, signature),
            "INVALID_PURCHASE"
        );

        uint256 amountInSand = _calculateTotalPriceInSand(message.catalystIds, message.catalystQuantities, message.gemQuantities);
        _handlePurchaseWithERC20(buyer, _wallet, address(_sand), amountInSand);
        _erc20GroupCatalyst.batchTransferFrom(address(this), buyer, message.catalystIds, message.catalystQuantities);
        _erc20GroupGem.batchTransferFrom(address(this), buyer, message.gemIds, message.gemQuantities);
        emit Purchase(buyer, message, amountInSand, address(_sand), amountInSand);
    }

    function purchaseWithETH(
        address buyer,
        Message calldata message,
        bytes calldata signature
    ) external payable {

        require(msg.sender == buyer || _metaTransactionContracts[msg.sender], "INVALID_SENDER");
        require(_etherEnabled, "ETHER_IS_NOT_ENABLED");
        require(buyer != address(0), "DESTINATION_ZERO_ADDRESS");
        require(buyer != address(this), "DESTINATION_STARTERPACKV1_CONTRACT");
        require(
            isPurchaseValid(buyer, message.catalystIds, message.catalystQuantities, message.gemIds, message.gemQuantities, message.nonce, signature),
            "INVALID_PURCHASE"
        );

        uint256 amountInSand = _calculateTotalPriceInSand(message.catalystIds, message.catalystQuantities, message.gemQuantities);
        uint256 ETHRequired = getEtherAmountWithSAND(amountInSand);
        require(msg.value >= ETHRequired, "NOT_ENOUGH_ETHER_SENT");

        _wallet.transfer(ETHRequired);
        _erc20GroupCatalyst.batchTransferFrom(address(this), buyer, message.catalystIds, message.catalystQuantities);
        _erc20GroupGem.batchTransferFrom(address(this), buyer, message.gemIds, message.gemQuantities);
        emit Purchase(buyer, message, amountInSand, address(0), ETHRequired);

        if (msg.value - ETHRequired > 0) {
            (bool success, ) = msg.sender.call{value: msg.value - ETHRequired}("");
            require(success, "REFUND_FAILED");
        }
    }

    function purchaseWithDAI(
        address buyer,
        Message calldata message,
        bytes calldata signature
    ) external {

        require(msg.sender == buyer || _metaTransactionContracts[msg.sender], "INVALID_SENDER");
        require(_daiEnabled, "DAI_IS_NOT_ENABLED");
        require(buyer != address(0), "DESTINATION_ZERO_ADDRESS");
        require(buyer != address(this), "DESTINATION_STARTERPACKV1_CONTRACT");
        require(
            isPurchaseValid(buyer, message.catalystIds, message.catalystQuantities, message.gemIds, message.gemQuantities, message.nonce, signature),
            "INVALID_PURCHASE"
        );

        uint256 amountInSand = _calculateTotalPriceInSand(message.catalystIds, message.catalystQuantities, message.gemQuantities);
        uint256 DAIRequired = amountInSand.mul(DAI_PRICE).div(DECIMAL_PLACES);
        _handlePurchaseWithERC20(buyer, _wallet, address(_dai), DAIRequired);
        _erc20GroupCatalyst.batchTransferFrom(address(this), buyer, message.catalystIds, message.catalystQuantities);
        _erc20GroupGem.batchTransferFrom(address(this), buyer, message.gemIds, message.gemQuantities);
        emit Purchase(buyer, message, amountInSand, address(_dai), DAIRequired);
    }

    function withdrawAll(
        address to,
        uint256[] calldata catalystIds,
        uint256[] calldata gemIds
    ) external {

        require(msg.sender == _admin, "NOT_AUTHORIZED");

        address[] memory catalystAddresses = new address[](catalystIds.length);
        for (uint256 i = 0; i < catalystIds.length; i++) {
            catalystAddresses[i] = address(this);
        }
        address[] memory gemAddresses = new address[](gemIds.length);
        for (uint256 i = 0; i < gemIds.length; i++) {
            gemAddresses[i] = address(this);
        }
        uint256[] memory unsoldCatalystQuantities = _erc20GroupCatalyst.balanceOfBatch(catalystAddresses, catalystIds);
        uint256[] memory unsoldGemQuantities = _erc20GroupGem.balanceOfBatch(gemAddresses, gemIds);

        _erc20GroupCatalyst.batchTransferFrom(address(this), to, catalystIds, unsoldCatalystQuantities);
        _erc20GroupGem.batchTransferFrom(address(this), to, gemIds, unsoldGemQuantities);
    }


    function setPrices(uint256[] calldata prices, uint256 gemPrice) external {

        require(msg.sender == _admin, "NOT_AUTHORIZED");
        _previousStarterPackPrices = _starterPackPrices;
        _starterPackPrices = prices;
        _previousGemPrice = _gemPrice;
        _gemPrice = gemPrice;
        _priceChangeTimestamp = now;
        emit SetPrices(prices, gemPrice);
    }


    function getPrices()
        external
        view
        returns (
            uint256[] memory pricesBeforeSwitch,
            uint256[] memory pricesAfterSwitch,
            uint256 gemPriceBeforeSwitch,
            uint256 gemPriceAfterSwitch,
            uint256 switchTime
        )
    {

        switchTime = 0;
        if (_priceChangeTimestamp != 0) {
            switchTime = _priceChangeTimestamp + PRICE_CHANGE_DELAY;
        }
        return (_previousStarterPackPrices, _starterPackPrices, _previousGemPrice, _gemPrice, switchTime);
    }

    function getEtherAmountWithSAND(uint256 sandAmount) public view returns (uint256) {

        uint256 ethUsdPair = _getEthUsdPair();
        return sandAmount.mul(DAI_PRICE).div(ethUsdPair);
    }


    function _getEthUsdPair() internal view returns (uint256) {

        bytes32 pair = _medianizer.read();
        return uint256(pair);
    }

    function _calculateTotalPriceInSand(
        uint256[] memory catalystIds,
        uint256[] memory catalystQuantities,
        uint256[] memory gemQuantities
    ) internal returns (uint256) {

        require(catalystIds.length == catalystQuantities.length, "INVALID_INPUT");
        (uint256[] memory prices, uint256 gemPrice) = _priceSelector();
        uint256 totalPrice;
        for (uint256 i = 0; i < catalystIds.length; i++) {
            uint256 id = catalystIds[i];
            uint256 quantity = catalystQuantities[i];
            totalPrice = totalPrice.add(prices[id].mul(quantity));
        }
        for (uint256 i = 0; i < gemQuantities.length; i++) {
            uint256 quantity = gemQuantities[i];
            totalPrice = totalPrice.add(gemPrice.mul(quantity));
        }
        return totalPrice;
    }


    function _priceSelector() internal returns (uint256[] memory, uint256) {

        uint256[] memory prices;
        uint256 gemPrice;
        if (_priceChangeTimestamp == 0) {
            prices = _starterPackPrices;
            gemPrice = _gemPrice;
        } else {
            if (now > _priceChangeTimestamp + PRICE_CHANGE_DELAY) {
                _priceChangeTimestamp = 0;
                prices = _starterPackPrices;
                gemPrice = _gemPrice;
            } else {
                prices = _previousStarterPackPrices;
                gemPrice = _previousGemPrice;
            }
        }
        return (prices, gemPrice);
    }

    function _handlePurchaseWithERC20(
        address buyer,
        address payable paymentRecipient,
        address tokenAddress,
        uint256 amount
    ) internal {

        ERC20 token = ERC20(tokenAddress);
        uint256 amountForDestination = amount;
        require(token.transferFrom(buyer, paymentRecipient, amountForDestination), "PAYMENT_TRANSFER_FAILED");
    }


    constructor(
        address starterPackAdmin,
        address sandContractAddress,
        address initialMetaTx,
        address payable initialWalletAddress,
        address medianizerContractAddress,
        address daiTokenContractAddress,
        address erc20GroupCatalystAddress,
        address erc20GroupGemAddress,
        address initialSigningWallet,
        uint256[] memory initialStarterPackPrices,
        uint256 initialGemPrice
    ) public PurchaseValidator(initialSigningWallet) {
        _setMetaTransactionProcessor(initialMetaTx, true);
        _wallet = initialWalletAddress;
        _admin = starterPackAdmin;
        _sand = ERC20(sandContractAddress);
        _medianizer = Medianizer(medianizerContractAddress);
        _dai = ERC20(daiTokenContractAddress);
        _erc20GroupCatalyst = ERC20Group(erc20GroupCatalystAddress);
        _erc20GroupGem = ERC20Group(erc20GroupGemAddress);
        _starterPackPrices = initialStarterPackPrices;
        _previousStarterPackPrices = initialStarterPackPrices;
        _gemPrice = initialGemPrice;
        _previousGemPrice = initialGemPrice;
        _sandEnabled = true; // Sand is enabled by default
        _etherEnabled = true; // Ether is enabled by default
    }
}