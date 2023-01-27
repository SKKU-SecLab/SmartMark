pragma solidity ^0.6.0;


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
}pragma solidity ^0.6.0;


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
}pragma solidity ^0.6.0;



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
}pragma solidity ^0.6.0;



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
}pragma solidity ^0.6.0;


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
}pragma solidity ^0.6.0;


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
}pragma solidity ^0.6.0;



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
}pragma solidity ^0.6.0;


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
}