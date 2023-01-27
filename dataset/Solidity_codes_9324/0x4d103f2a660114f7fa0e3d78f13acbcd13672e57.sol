pragma solidity 0.6.5;


library SafeMathWithRequire {

    using SafeMathWithRequire for uint256;

    uint256 constant DECIMALS_18 = 1000000000000000000;
    uint256 constant DECIMALS_12 = 1000000000000;
    uint256 constant DECIMALS_9 = 1000000000;
    uint256 constant DECIMALS_6 = 1000000;

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

    function sqrt6(uint256 a) internal pure returns (uint256 c) {

        a = a.mul(DECIMALS_12);
        uint256 tmp = a.add(1) / 2;
        c = a;
        while (tmp < c) {
            c = tmp;
            tmp = ((a / tmp) + tmp) / 2;
        }
    }

    function sqrt3(uint256 a) internal pure returns (uint256 c) {

        a = a.mul(DECIMALS_6);
        uint256 tmp = a.add(1) / 2;
        c = a;
        while (tmp < c) {
            c = tmp;
            tmp = ((a / tmp) + tmp) / 2;
        }
    }

    function cbrt6(uint256 a) internal pure returns (uint256 c) {

        a = a.mul(DECIMALS_18);
        uint256 tmp = a.add(2) / 3;
        c = a;
        while (tmp < c) {
            c = tmp;
            uint256 tmpSquare = tmp**2;
            require(tmpSquare > tmp, "overflow");
            tmp = ((a / tmpSquare) + (tmp * 2)) / 3;
        }
        return c;
    }

    function cbrt3(uint256 a) internal pure returns (uint256 c) {

        a = a.mul(DECIMALS_9);
        uint256 tmp = a.add(2) / 3;
        c = a;
        while (tmp < c) {
            c = tmp;
            uint256 tmpSquare = tmp**2;
            require(tmpSquare > tmp, "overflow");
            tmp = ((a / tmpSquare) + (tmp * 2)) / 3;
        }
        return c;
    }

    function rt6_3(uint256 a) internal pure returns (uint256 c) {

        a = a.mul(DECIMALS_18);
        uint256 tmp = a.add(5) / 6;
        c = a;
        while (tmp < c) {
            c = tmp;
            uint256 tmpFive = tmp**5;
            require(tmpFive > tmp, "overflow");
            tmp = ((a / tmpFive) + (tmp * 5)) / 6;
        }
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


interface CatalystToken {

    function getMintData(uint256 catalystId)
        external
        view
        returns (
            uint16 maxGems,
            uint16 minQuantity,
            uint16 maxQuantity,
            uint256 sandMintingFee,
            uint256 sandUpdateFee
        );


    function batchBurnFrom(
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external;


    function burnFrom(
        address from,
        uint256 id,
        uint256 amount
    ) external;

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


interface GemToken {

    function batchBurnFrom(
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external;

}pragma solidity 0.6.5;


interface AssetToken {

    function mint(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint256 supply,
        uint8 rarity,
        address owner,
        bytes calldata data
    ) external returns (uint256 id);


    function mintMultiple(
        address creator,
        uint40 packId,
        bytes32 hash,
        uint256[] calldata supplies,
        bytes calldata rarityPack,
        address owner,
        bytes calldata data
    ) external returns (uint256[] memory ids);


    function collectionOf(uint256 id) external view returns (uint256);


    function isCollection(uint256 id) external view returns (bool);


    function collectionIndexOf(uint256 id) external view returns (uint256);


    function extractERC721From(
        address sender,
        uint256 id,
        address to
    ) external returns (uint256 newId);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) external;

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



interface ERC20Extended is ERC20 {

    function burnFor(address from, uint256 amount) external;


    function burn(uint256 amount) external;


    function approveFor(
        address owner,
        address spender,
        uint256 amount
    ) external returns (bool success);

}pragma solidity 0.6.5;



contract CatalystRegistry is Admin, CatalystValue {

    event Minter(address indexed newMinter);
    event CatalystApplied(uint256 indexed assetId, uint256 indexed catalystId, uint256 seed, uint256[] gemIds, uint64 blockNumber);
    event GemsAdded(uint256 indexed assetId, uint256 seed, uint256[] gemIds, uint64 blockNumber);

    function getCatalyst(uint256 assetId) external view returns (bool exists, uint256 catalystId) {

        CatalystStored memory catalyst = _catalysts[assetId];
        if (catalyst.set != 0) {
            return (true, catalyst.catalystId);
        }
        if (assetId & IS_NFT != 0) {
            catalyst = _catalysts[_getCollectionId(assetId)];
            return (catalyst.set != 0, catalyst.catalystId);
        }
        return (false, 0);
    }

    function setCatalyst(
        uint256 assetId,
        uint256 catalystId,
        uint256 maxGems,
        uint256[] calldata gemIds
    ) external {

        require(msg.sender == _minter, "NOT_AUTHORIZED_MINTER");
        require(gemIds.length <= maxGems, "INVALID_GEMS_TOO_MANY");
        uint256 emptySockets = maxGems - gemIds.length;
        _catalysts[assetId] = CatalystStored(uint64(emptySockets), uint64(catalystId), 1);
        uint64 blockNumber = _getBlockNumber();
        emit CatalystApplied(assetId, catalystId, assetId, gemIds, blockNumber);
    }

    function addGems(uint256 assetId, uint256[] calldata gemIds) external {

        require(msg.sender == _minter, "NOT_AUTHORIZED_MINTER");
        require(assetId & IS_NFT != 0, "INVALID_NOT_NFT");
        require(gemIds.length != 0, "INVALID_GEMS_0");
        (uint256 emptySockets, uint256 seed) = _getSocketData(assetId);
        require(emptySockets >= gemIds.length, "INVALID_GEMS_TOO_MANY");
        emptySockets -= gemIds.length;
        _catalysts[assetId].emptySockets = uint64(emptySockets);
        uint64 blockNumber = _getBlockNumber();
        emit GemsAdded(assetId, seed, gemIds, blockNumber);
    }

    function setMinter(address minter) external {

        require(msg.sender == _admin, "NOT_AUTHORIZED_ADMIN");
        require(minter != _minter, "INVALID_MINTER_SAME_ALREADY_SET");
        _minter = minter;
        emit Minter(minter);
    }

    function getMinter() external view returns (address) {

        return _minter;
    }

    function getValues(
        uint256 catalystId,
        uint256 seed,
        GemEvent[] calldata events,
        uint32 totalNumberOfGemTypes
    ) external override view returns (uint32[] memory values) {

        return _catalystValue.getValues(catalystId, seed, events, totalNumberOfGemTypes);
    }


    uint256 private constant IS_NFT = 0x0000000000000000000000000000000000000000800000000000000000000000;
    uint256 private constant NOT_IS_NFT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFFFFFFFFFFF;
    uint256 private constant NOT_NFT_INDEX = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF800000007FFFFFFFFFFFFFFF;

    function _getSocketData(uint256 assetId) internal view returns (uint256 emptySockets, uint256 seed) {

        seed = assetId;
        CatalystStored memory catalyst = _catalysts[assetId];
        if (catalyst.set != 0) {
            return (catalyst.emptySockets, seed);
        }
        seed = _getCollectionId(assetId);
        catalyst = _catalysts[seed];
        return (catalyst.emptySockets, seed);
    }

    function _getBlockNumber() internal view returns (uint64 blockNumber) {

        blockNumber = uint64(block.number + 1);
    }

    function _getCollectionId(uint256 assetId) internal pure returns (uint256) {

        return assetId & NOT_NFT_INDEX & NOT_IS_NFT; // compute the same as Asset to get collectionId
    }

    constructor(CatalystValue catalystValue, address admin) public {
        _admin = admin;
        _catalystValue = catalystValue;
    }


    struct CatalystStored {
        uint64 emptySockets;
        uint64 catalystId;
        uint64 set;
    }
    address internal _minter;
    CatalystValue internal immutable _catalystValue;
    mapping(uint256 => CatalystStored) internal _catalysts;
}pragma solidity 0.6.5;



contract CatalystMinter is MetaTransactionReceiver {

    event FeeCollector(address newCollector);

    function setFeeCollector(address newCollector) external {

        require(msg.sender == _admin, "NOT_AUTHORIZED_ADMIN");
        _setFeeCollector(newCollector);
    }

    event GemAdditionFee(uint256 newFee);

    function setGemAdditionFee(uint256 newFee) external {

        require(msg.sender == _admin, "NOT_AUTHORIZED_ADMIN");
        _setGemAdditionFee(newFee);
    }

    function mint(
        address from,
        uint40 packId,
        bytes32 metadataHash,
        uint256 catalystId,
        uint256[] calldata gemIds,
        uint256 quantity,
        address to,
        bytes calldata data
    ) external returns (uint256) {

        _checkAuthorization(from, to);
        _burnCatalyst(from, catalystId);
        uint16 maxGems = _checkQuantityAndBurnSandAndGems(from, catalystId, gemIds, quantity);
        uint256 id = _asset.mint(from, packId, metadataHash, quantity, 0, to, data);
        _catalystRegistry.setCatalyst(id, catalystId, maxGems, gemIds);
        return id;
    }

    function extractAndChangeCatalyst(
        address from,
        uint256 assetId,
        uint256 catalystId,
        uint256[] calldata gemIds,
        address to
    ) external returns (uint256 tokenId) {

        _checkAuthorization(from, to);
        tokenId = _asset.extractERC721From(from, assetId, from);
        _changeCatalyst(from, tokenId, catalystId, gemIds, to);
    }

    function changeCatalyst(
        address from,
        uint256 assetId,
        uint256 catalystId,
        uint256[] calldata gemIds,
        address to
    ) external returns (uint256 tokenId) {

        _checkAuthorization(from, to);
        _changeCatalyst(from, assetId, catalystId, gemIds, to);
        return assetId;
    }

    function extractAndAddGems(
        address from,
        uint256 assetId,
        uint256[] calldata gemIds,
        address to
    ) external returns (uint256 tokenId) {

        _checkAuthorization(from, to);
        tokenId = _asset.extractERC721From(from, assetId, from);
        _addGems(from, tokenId, gemIds, to);
    }

    function addGems(
        address from,
        uint256 assetId,
        uint256[] calldata gemIds,
        address to
    ) external {

        _checkAuthorization(from, to);
        _addGems(from, assetId, gemIds, to);
    }

    struct AssetData {
        uint256[] gemIds;
        uint256 quantity;
        uint256 catalystId;
    }

    function mintMultiple(
        address from,
        uint40 packId,
        bytes32 metadataHash,
        uint256[] memory gemsQuantities,
        uint256[] memory catalystsQuantities,
        AssetData[] memory assets,
        address to,
        bytes memory data
    ) public returns (uint256[] memory ids) {

        require(assets.length != 0, "INVALID_0_ASSETS");
        _checkAuthorization(from, to);
        return _mintMultiple(from, packId, metadataHash, gemsQuantities, catalystsQuantities, assets, to, data);
    }


    function _checkQuantityAndBurnSandAndGems(
        address from,
        uint256 catalystId,
        uint256[] memory gemIds,
        uint256 quantity
    ) internal returns (uint16) {

        (uint16 maxGems, uint16 minQuantity, uint16 maxQuantity, uint256 sandMintingFee, ) = _getMintData(catalystId);
        require(minQuantity <= quantity && quantity <= maxQuantity, "INVALID_QUANTITY");
        require(gemIds.length <= maxGems, "INVALID_GEMS_TOO_MANY");
        _burnSingleGems(from, gemIds);
        _chargeSand(from, quantity.mul(sandMintingFee));
        return maxGems;
    }

    function _mintMultiple(
        address from,
        uint40 packId,
        bytes32 metadataHash,
        uint256[] memory gemsQuantities,
        uint256[] memory catalystsQuantities,
        AssetData[] memory assets,
        address to,
        bytes memory data
    ) internal returns (uint256[] memory) {

        (uint256 totalSandFee, uint256[] memory supplies, uint16[] memory maxGemsList) = _handleMultipleCatalysts(
            from,
            gemsQuantities,
            catalystsQuantities,
            assets
        );

        _chargeSand(from, totalSandFee);

        return _mintAssets(from, packId, metadataHash, assets, supplies, maxGemsList, to, data);
    }

    function _chargeSand(address from, uint256 sandFee) internal {

        address feeCollector = _feeCollector;
        if (feeCollector != address(0) && sandFee != 0) {
            if (feeCollector == address(BURN_ADDRESS)) {
                _sand.burnFor(from, sandFee);
            } else {
                _sand.transferFrom(from, _feeCollector, sandFee);
            }
        }
    }

    function _extractMintData(uint256 data)
        internal
        pure
        returns (
            uint16 maxGems,
            uint16 minQuantity,
            uint16 maxQuantity,
            uint256 sandMintingFee,
            uint256 sandUpdateFee
        )
    {

        maxGems = uint16(data >> 240);
        minQuantity = uint16((data >> 224) % 2**16);
        maxQuantity = uint16((data >> 208) % 2**16);
        sandMintingFee = uint256((data >> 120) % 2**88);
        sandUpdateFee = uint256(data % 2**88);
    }

    function _getMintData(uint256 catalystId)
        internal
        view
        returns (
            uint16,
            uint16,
            uint16,
            uint256,
            uint256
        )
    {

        if (catalystId == 0) {
            return _extractMintData(_common_mint_data);
        } else if (catalystId == 1) {
            return _extractMintData(_rare_mint_data);
        } else if (catalystId == 2) {
            return _extractMintData(_epic_mint_data);
        } else if (catalystId == 3) {
            return _extractMintData(_legendary_mint_data);
        }
        return _catalysts.getMintData(catalystId);
    }

    function _handleMultipleCatalysts(
        address from,
        uint256[] memory gemsQuantities,
        uint256[] memory catalystsQuantities,
        AssetData[] memory assets
    )
        internal
        returns (
            uint256 totalSandFee,
            uint256[] memory supplies,
            uint16[] memory maxGemsList
        )
    {

        _burnCatalysts(from, catalystsQuantities);
        _burnGems(from, gemsQuantities);

        supplies = new uint256[](assets.length);
        maxGemsList = new uint16[](assets.length);

        for (uint256 i = 0; i < assets.length; i++) {
            require(catalystsQuantities[assets[i].catalystId] != 0, "INVALID_CATALYST_NOT_ENOUGH");
            catalystsQuantities[assets[i].catalystId]--;
            gemsQuantities = _checkGemsQuantities(gemsQuantities, assets[i].gemIds);
            (uint16 maxGems, uint16 minQuantity, uint16 maxQuantity, uint256 sandMintingFee, ) = _getMintData(assets[i].catalystId);
            require(minQuantity <= assets[i].quantity && assets[i].quantity <= maxQuantity, "INVALID_QUANTITY");
            require(assets[i].gemIds.length <= maxGems, "INVALID_GEMS_TOO_MANY");
            maxGemsList[i] = maxGems;
            supplies[i] = assets[i].quantity;
            totalSandFee = totalSandFee.add(sandMintingFee.mul(assets[i].quantity));
        }
    }

    function _checkGemsQuantities(uint256[] memory gemsQuantities, uint256[] memory gemIds) internal pure returns (uint256[] memory) {

        for (uint256 i = 0; i < gemIds.length; i++) {
            require(gemsQuantities[gemIds[i]] != 0, "INVALID_GEMS_NOT_ENOUGH");
            gemsQuantities[gemIds[i]]--;
        }
        return gemsQuantities;
    }

    function _burnCatalysts(address from, uint256[] memory catalystsQuantities) internal {

        uint256[] memory ids = new uint256[](catalystsQuantities.length);
        for (uint256 i = 0; i < ids.length; i++) {
            ids[i] = i;
        }
        _catalysts.batchBurnFrom(from, ids, catalystsQuantities);
    }

    function _burnGems(address from, uint256[] memory gemsQuantities) internal {

        uint256[] memory ids = new uint256[](gemsQuantities.length);
        for (uint256 i = 0; i < ids.length; i++) {
            ids[i] = i;
        }
        _gems.batchBurnFrom(from, ids, gemsQuantities);
    }

    function _mintAssets(
        address from,
        uint40 packId,
        bytes32 metadataHash,
        AssetData[] memory assets,
        uint256[] memory supplies,
        uint16[] memory maxGemsList,
        address to,
        bytes memory data
    ) internal returns (uint256[] memory tokenIds) {

        tokenIds = _asset.mintMultiple(from, packId, metadataHash, supplies, "", to, data);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _catalystRegistry.setCatalyst(tokenIds[i], assets[i].catalystId, maxGemsList[i], assets[i].gemIds);
        }
    }

    function _changeCatalyst(
        address from,
        uint256 assetId,
        uint256 catalystId,
        uint256[] memory gemIds,
        address to
    ) internal {

        require(assetId & IS_NFT != 0, "INVALID_NOT_NFT"); // Asset (ERC1155ERC721.sol) ensure NFT will return true here and non-NFT will return false
        _burnCatalyst(from, catalystId);
        (uint16 maxGems, , , , uint256 sandUpdateFee) = _getMintData(catalystId);
        require(gemIds.length <= maxGems, "INVALID_GEMS_TOO_MANY");
        _burnGems(from, gemIds);
        _chargeSand(from, sandUpdateFee);

        _catalystRegistry.setCatalyst(assetId, catalystId, maxGems, gemIds);

        _transfer(from, to, assetId);
    }

    function _addGems(
        address from,
        uint256 assetId,
        uint256[] memory gemIds,
        address to
    ) internal {

        require(assetId & IS_NFT != 0, "INVALID_NOT_NFT"); // Asset (ERC1155ERC721.sol) ensure NFT will return true here and non-NFT will return false
        _catalystRegistry.addGems(assetId, gemIds);
        _chargeSand(from, gemIds.length.mul(_gemAdditionFee));
        _transfer(from, to, assetId);
    }

    function _transfer(
        address from,
        address to,
        uint256 assetId
    ) internal {

        if (from != to) {
            _asset.safeTransferFrom(from, to, assetId);
        }
    }

    function _checkAuthorization(address from, address to) internal view {

        require(to != address(0), "INVALID_TO_ZERO_ADDRESS");
        require(from == msg.sender || _metaTransactionContracts[msg.sender], "NOT_SENDER");
    }

    function _burnSingleGems(address from, uint256[] memory gemIds) internal {

        uint256[] memory amounts = new uint256[](gemIds.length);
        for (uint256 i = 0; i < gemIds.length; i++) {
            amounts[i] = 1;
        }
        _gems.batchBurnFrom(from, gemIds, amounts);
    }

    function _burnCatalyst(address from, uint256 catalystId) internal {

        _catalysts.burnFrom(from, catalystId, 1);
    }

    function _setFeeCollector(address newCollector) internal {

        _feeCollector = newCollector;
        emit FeeCollector(newCollector);
    }

    function _setGemAdditionFee(uint256 newFee) internal {

        _gemAdditionFee = newFee;
        emit GemAdditionFee(newFee);
    }

    using SafeMathWithRequire for uint256;

    uint256 private constant IS_NFT = 0x0000000000000000000000000000000000000000800000000000000000000000;
    address private constant BURN_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;

    ERC20Extended internal immutable _sand;
    AssetToken internal immutable _asset;
    GemToken internal immutable _gems;
    CatalystToken internal immutable _catalysts;
    CatalystRegistry internal immutable _catalystRegistry;
    address internal _feeCollector;

    uint256 internal immutable _common_mint_data;
    uint256 internal immutable _rare_mint_data;
    uint256 internal immutable _epic_mint_data;
    uint256 internal immutable _legendary_mint_data;

    uint256 internal _gemAdditionFee;

    constructor(
        CatalystRegistry catalystRegistry,
        ERC20Extended sand,
        AssetToken asset,
        GemToken gems,
        address metaTx,
        address admin,
        address feeCollector,
        uint256 gemAdditionFee,
        CatalystToken catalysts,
        uint256[4] memory bakedInMintdata
    ) public {
        _catalystRegistry = catalystRegistry;
        _sand = sand;
        _asset = asset;
        _gems = gems;
        _catalysts = catalysts;
        _admin = admin;
        _setGemAdditionFee(gemAdditionFee);
        _setFeeCollector(feeCollector);
        _setMetaTransactionProcessor(metaTx, true);
        _common_mint_data = bakedInMintdata[0];
        _rare_mint_data = bakedInMintdata[1];
        _epic_mint_data = bakedInMintdata[2];
        _legendary_mint_data = bakedInMintdata[3];
    }
}