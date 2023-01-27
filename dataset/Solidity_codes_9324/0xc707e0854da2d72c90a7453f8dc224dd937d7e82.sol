
pragma solidity ^0.5.5;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value, mapping(address => uint8) storage bugERC20s) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value), bugERC20s);
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value, mapping(address => uint8) storage bugERC20s) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value), bugERC20s);
    }




    function callOptionalReturn(IERC20 token, bytes memory data, mapping(address => uint8) storage bugERC20s) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (bugERC20s[address(token)] != 0) {
            return;
        }
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library BytesLib {

    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
    internal
    pure
    returns (bytes memory)
    {

        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(0x40, and(
            add(add(end, iszero(add(length, mload(_preBytes)))), 31),
            not(31) // Round down to the nearest 32 bytes.
            ))
        }

        return tempBytes;
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                sstore(
                _preBytes_slot,
                add(
                fslot,
                add(
                mul(
                div(
                mload(add(_postBytes, 0x20)),
                exp(0x100, sub(32, mlength))
                ),
                exp(0x100, sub(32, newlength))
                ),
                mul(mlength, 2)
                )
                )
                )
            }
            case 1 {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))


                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(
                sc,
                add(
                and(
                fslot,
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                ),
                and(mload(mc), mask)
                )
                )

                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))

                sstore(_preBytes_slot, add(mul(newlength, 2), 1))

                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)

                sstore(sc, add(sload(sc), and(mload(mc), mask)))

                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }

                mask := exp(0x100, sub(mc, end))

                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }

    function slice(
        bytes memory _bytes,
        uint _start,
        uint _length
    )
    internal
    pure
    returns (bytes memory)
    {

        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {

        require(_bytes.length >= (_start + 20));
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {

        require(_bytes.length >= (_start + 1));
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {

        require(_bytes.length >= (_start + 2));
        uint16 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }

        return tempUint;
    }

    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {

        require(_bytes.length >= (_start + 4));
        uint32 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }

        return tempUint;
    }

    function toUint64(bytes memory _bytes, uint _start) internal  pure returns (uint64) {

        require(_bytes.length >= (_start + 8));
        uint64 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }

        return tempUint;
    }

    function toUint96(bytes memory _bytes, uint _start) internal  pure returns (uint96) {

        require(_bytes.length >= (_start + 12));
        uint96 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }

        return tempUint;
    }

    function toUint128(bytes memory _bytes, uint _start) internal  pure returns (uint128) {

        require(_bytes.length >= (_start + 16));
        uint128 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }

        return tempUint;
    }

    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {

        require(_bytes.length >= (_start + 32));
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {

        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {

        bool success = true;

        assembly {
            let length := mload(_preBytes)

            switch eq(length, mload(_postBytes))
            case 1 {
                let cb := 1

                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)

                for {
                    let cc := add(_postBytes, 0x20)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    if iszero(eq(mload(mc), mload(cc))) {
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }

    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
    internal
    view
    returns (bool)
    {

        bool success = true;

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)

            switch eq(slength, mlength)
            case 1 {
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        fslot := mul(div(fslot, 0x100), 0x100)

                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            success := 0
                        }
                    }
                    default {
                        let cb := 1

                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)

                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)

                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                success := 0
            }
        }

        return success;
    }
}

interface IERC20Minter {

    function mint(address to, uint256 amount) external;

    function burn(uint256 amount) external;

    function replaceMinter(address newMinter) external;

}

contract NerveMultiSigWalletIII is ReentrancyGuard {

    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using BytesLib for bytes;

    modifier isOwner{

        require(owner == msg.sender, "Only owner can execute it");
        _;
    }
    modifier isManager{

        require(managers[msg.sender] == 1, "Only manager can execute it");
        _;
    }
    bool public upgrade = false;
    address public upgradeContractAddress = address(0);
    uint public max_managers = 15;
    uint public min_managers = 3;
    uint public rate = 66;
    uint public signatureLength = 65;
    uint constant DENOMINATOR = 100;
    uint8 constant VERSION = 3;
    uint public hashSalt; 
    uint8 public current_min_signatures;
    address public owner;
    mapping(address => uint8) private seedManagers;
    address[] private seedManagerArray;
    mapping(address => uint8) private managers;
    address[] private managerArray;
    mapping(bytes32 => uint8) private completedKeccak256s;
    mapping(string => uint8) private completedTxs;
    mapping(address => uint8) private minterERC20s;
    mapping(address => uint8) public bugERC20s;
    bool public openCrossOutII = false;

    constructor(uint256 _chainid, address[] memory _managers) public{
        require(_managers.length <= max_managers, "Exceeded the maximum number of managers");
        require(_managers.length >= min_managers, "Not reaching the min number of managers");
        owner = msg.sender;
        managerArray = _managers;
        for (uint8 i = 0; i < managerArray.length; i++) {
            managers[managerArray[i]] = 1;
            seedManagers[managerArray[i]] = 1;
            seedManagerArray.push(managerArray[i]);
        }
        require(managers[owner] == 0, "Contract creator cannot act as manager");
        current_min_signatures = calMinSignatures(managerArray.length);
        hashSalt = _chainid * 2 + VERSION;
    }
    function() external payable {
        emit DepositFunds(msg.sender, msg.value);
    }

    function createOrSignWithdraw(string memory txKey, address payable to, uint256 amount, bool isERC20, address ERC20, bytes memory signatures) public nonReentrant isManager {

        require(bytes(txKey).length == 64, "Fixed length of txKey: 64");
        require(to != address(0), "Withdraw: transfer to the zero address");
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(completedTxs[txKey] == 0, "Transaction has been completed");
        if (isERC20) {
            validateTransferERC20(ERC20, to, amount);
        } else {
            require(address(this).balance >= amount, "This contract address does not have sufficient balance of ether");
        }
        bytes32 vHash = keccak256(abi.encodePacked(txKey, to, amount, isERC20, ERC20, hashSalt));
        require(completedKeccak256s[vHash] == 0, "Invalid signatures");
        require(validSignature(vHash, signatures), "Valid signatures fail");
        if (isERC20) {
            transferERC20(ERC20, to, amount);
        } else {
            require(address(this).balance >= amount, "This contract address does not have sufficient balance of ether");
            to.transfer(amount);
            emit TransferFunds(to, amount);
        }
        completeTx(txKey, vHash, 1);
        emit TxWithdrawCompleted(txKey);
    }


    function createOrSignManagerChange(string memory txKey, address[] memory adds, address[] memory removes, uint8 count, bytes memory signatures) public isManager {

        require(bytes(txKey).length == 64, "Fixed length of txKey: 64");
        require(adds.length > 0 || removes.length > 0, "There are no managers joining or exiting");
        require(completedTxs[txKey] == 0, "Transaction has been completed");
        preValidateAddsAndRemoves(adds, removes);
        bytes32 vHash = keccak256(abi.encodePacked(txKey, adds, count, removes, hashSalt));
        require(completedKeccak256s[vHash] == 0, "Invalid signatures");
        require(validSignature(vHash, signatures), "Valid signatures fail");
        removeManager(removes);
        addManager(adds);
        current_min_signatures = calMinSignatures(managerArray.length);
        completeTx(txKey, vHash, 1);
        emit TxManagerChangeCompleted(txKey);
    }

    function createOrSignUpgrade(string memory txKey, address upgradeContract, bytes memory signatures) public isManager {

        require(bytes(txKey).length == 64, "Fixed length of txKey: 64");
        require(completedTxs[txKey] == 0, "Transaction has been completed");
        require(!upgrade, "It has been upgraded");
        require(upgradeContract.isContract(), "The address is not a contract address");
        bytes32 vHash = keccak256(abi.encodePacked(txKey, upgradeContract, hashSalt));
        require(completedKeccak256s[vHash] == 0, "Invalid signatures");
        require(validSignature(vHash, signatures), "Valid signatures fail");
        upgrade = true;
        upgradeContractAddress = upgradeContract;
        completeTx(txKey, vHash, 1);
        emit TxUpgradeCompleted(txKey);
    }

    function validSignature(bytes32 hash, bytes memory signatures) internal view returns (bool) {

        require(signatures.length <= 975, "Max length of signatures: 975");
        uint sManagersCount = getManagerFromSignatures(hash, signatures);
        return sManagersCount >= current_min_signatures;
    }

    function getManagerFromSignatures(bytes32 hash, bytes memory signatures) internal view returns (uint){

        uint signCount = 0;
        uint times = signatures.length.div(signatureLength);
        address[] memory result = new address[](times);
        uint k = 0;
        uint8 j = 0;
        for (uint i = 0; i < times; i++) {
            bytes memory sign = signatures.slice(k, signatureLength);
            address mAddress = ecrecovery(hash, sign);
            require(mAddress != address(0), "Signatures error");
            if (managers[mAddress] == 1) {
                signCount++;
                result[j++] = mAddress;
            }
            k += signatureLength;
        }
        bool suc = repeatability(result);
        delete result;
        require(suc, "Signatures duplicate");
        return signCount;
    }

    function validateRepeatability(address currentAddress, address[] memory list) internal pure returns (bool) {

        address tempAddress;
        for (uint i = 0; i < list.length; i++) {
            tempAddress = list[i];
            if (tempAddress == address(0)) {
                break;
            }
            if (tempAddress == currentAddress) {
                return false;
            }
        }
        return true;
    }

    function repeatability(address[] memory list) internal pure returns (bool) {

        for (uint i = 0; i < list.length; i++) {
            address address1 = list[i];
            if (address1 == address(0)) {
                break;
            }
            for (uint j = i + 1; j < list.length; j++) {
                address address2 = list[j];
                if (address2 == address(0)) {
                    break;
                }
                if (address1 == address2) {
                    return false;
                }
            }
        }
        return true;
    }

    function ecrecovery(bytes32 hash, bytes memory sig) internal view returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;
        if (sig.length != signatureLength) {
            return address(0);
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        if(uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }
        if (v < 27) {
            v += 27;
        }
        if (v != 27 && v != 28) {
            return address(0);
        }
        return ecrecover(hash, v, r, s);
    }

    function preValidateAddsAndRemoves(address[] memory adds, address[] memory removes) internal view {

        uint addLen = adds.length;
        for (uint i = 0; i < addLen; i++) {
            address add = adds[i];
            require(add != address(0), "ERROR: Detected zero address in adds");
            require(managers[add] == 0, "The address list that is being added already exists as a manager");
        }
        require(repeatability(adds), "Duplicate parameters for the address to join");
        require(validateRepeatability(owner, adds), "Contract creator cannot act as manager");
        require(repeatability(removes), "Duplicate parameters for the address to exit");
        uint removeLen = removes.length;
        for (uint i = 0; i < removeLen; i++) {
            address remove = removes[i];
            require(seedManagers[remove] == 0, "Can't exit seed manager");
            require(managers[remove] == 1, "There are addresses in the exiting address list that are not manager");
        }
        require(managerArray.length + adds.length - removes.length <= max_managers, "Exceeded the maximum number of managers");
    }

    function calMinSignatures(uint managerCounts) internal view returns (uint8) {

        require(managerCounts > 0, "Manager Can't empty.");
        uint numerator = rate * managerCounts + DENOMINATOR - 1;
        return uint8(numerator / DENOMINATOR);
    }
    function removeManager(address[] memory removes) internal {

        if (removes.length == 0) {
            return;
        }
        for (uint i = 0; i < removes.length; i++) {
            delete managers[removes[i]];
        }
        for (uint i = 0; i < managerArray.length; i++) {
            if (managers[managerArray[i]] == 0) {
                delete managerArray[i];
            }
        }
        uint tempIndex = 0x10;
        for (uint i = 0; i<managerArray.length; i++) {
            address temp = managerArray[i];
            if (temp == address(0)) {
                if (tempIndex == 0x10) tempIndex = i;
                continue;
            } else if (tempIndex != 0x10) {
                managerArray[tempIndex] = temp;
                tempIndex++;
            }
        }
        managerArray.length -= removes.length;
    }
    function addManager(address[] memory adds) internal {

        if (adds.length == 0) {
            return;
        }
        for (uint i = 0; i < adds.length; i++) {
            address add = adds[i];
            if(managers[add] == 0) {
                managers[add] = 1;
                managerArray.push(add);
            }
        }
    }
    function completeTx(string memory txKey, bytes32 keccak256Hash, uint8 e) internal {

        completedTxs[txKey] = e;
        completedKeccak256s[keccak256Hash] = e;
    }
    function validateTransferERC20(address ERC20, address to, uint256 amount) internal view {

        require(to != address(0), "ERC20: transfer to the zero address");
        require(address(this) != ERC20, "Do nothing by yourself");
        require(ERC20.isContract(), "The address is not a contract address");
        if (isMinterERC20(ERC20)) {
            return;
        }
        IERC20 token = IERC20(ERC20);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, "No enough balance of token");
    }
    function transferERC20(address ERC20, address to, uint256 amount) internal {

        if (isMinterERC20(ERC20)) {
            IERC20Minter minterToken = IERC20Minter(ERC20);
            minterToken.mint(to, amount);
            return;
        }
        IERC20 token = IERC20(ERC20);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= amount, "No enough balance of token");
        token.safeTransfer(to, amount, bugERC20s);
    }
    function closeUpgrade() public isOwner {

        require(upgrade, "Denied");
        upgrade = false;
    }
    function upgradeContractS1() public isOwner {

        require(upgrade, "Denied");
        require(upgradeContractAddress != address(0), "ERROR: transfer to the zero address");
        address(uint160(upgradeContractAddress)).transfer(address(this).balance);
    }
    function upgradeContractS2(address ERC20) public isOwner {

        require(upgrade, "Denied");
        require(upgradeContractAddress != address(0), "ERROR: transfer to the zero address");
        require(address(this) != ERC20, "Do nothing by yourself");
        require(ERC20.isContract(), "The address is not a contract address");
        IERC20 token = IERC20(ERC20);
        uint256 balance = token.balanceOf(address(this));
        require(balance >= 0, "No enough balance of token");
        token.safeTransfer(upgradeContractAddress, balance, bugERC20s);
        if (isMinterERC20(ERC20)) {
            IERC20Minter minterToken = IERC20Minter(ERC20);
            minterToken.replaceMinter(upgradeContractAddress);
        }
    }

    function isMinterERC20(address ERC20) public view returns (bool) {

        return minterERC20s[ERC20] > 0;
    }

    function registerMinterERC20(address ERC20) public isOwner {

        require(address(this) != ERC20, "Do nothing by yourself");
        require(ERC20.isContract(), "The address is not a contract address");
        require(!isMinterERC20(ERC20), "This address has already been registered");
        minterERC20s[ERC20] = 1;
    }

    function unregisterMinterERC20(address ERC20) public isOwner {

        require(isMinterERC20(ERC20), "This address is not registered");
        delete minterERC20s[ERC20];
    }

    function registerBugERC20(address bug) public isOwner {

        require(address(this) != bug, "Do nothing by yourself");
        require(bug.isContract(), "The address is not a contract address");
        bugERC20s[bug] = 1;
    }
    function unregisterBugERC20(address bug) public isOwner {

        bugERC20s[bug] = 0;
    }
    function crossOut(string memory to, uint256 amount, address ERC20) public payable returns (bool) {

        address from = msg.sender;
        require(amount > 0, "ERROR: Zero amount");
        if (ERC20 != address(0)) {
            require(msg.value == 0, "ERC20: Does not accept Ethereum Coin");
            require(ERC20.isContract(), "The address is not a contract address");
            IERC20 token = IERC20(ERC20);
            uint256 allowance = token.allowance(from, address(this));
            require(allowance >= amount, "No enough amount for authorization");
            uint256 fromBalance = token.balanceOf(from);
            require(fromBalance >= amount, "No enough balance of the token");
            token.safeTransferFrom(from, address(this), amount, bugERC20s);
            if (isMinterERC20(ERC20)) {
                IERC20Minter minterToken = IERC20Minter(ERC20);
                minterToken.burn(amount);
            }
        } else {
            require(msg.value == amount, "Inconsistency Ethereum amount");
        }
        emit CrossOutFunds(from, to, amount, ERC20);
        return true;
    }

    function crossOutII(string memory to, uint256 amount, address ERC20, bytes memory data) public payable returns (bool) {

        require(openCrossOutII, "CrossOutII: Not open");
        address from = msg.sender;
        uint erc20Amount = 0;
        if (ERC20 != address(0)) {
            require(amount > 0, "ERROR: Zero amount");
            require(ERC20.isContract(), "The address is not a contract address");
            IERC20 token = IERC20(ERC20);
            uint256 allowance = token.allowance(from, address(this));
            require(allowance >= amount, "No enough amount for authorization");
            uint256 fromBalance = token.balanceOf(from);
            require(fromBalance >= amount, "No enough balance of the token");
            token.safeTransferFrom(from, address(this), amount, bugERC20s);
            if (isMinterERC20(ERC20)) {
                IERC20Minter minterToken = IERC20Minter(ERC20);
                minterToken.burn(amount);
            }
            erc20Amount = amount;
        } else {
            require(msg.value > 0 && amount == 0, "CrossOutII: Illegal eth amount");
        }
        emit CrossOutIIFunds(from, to, erc20Amount, ERC20, msg.value, data);
        return true;
    }

    function setCrossOutII(bool _open) public isOwner {

        openCrossOutII = _open;
    }

    function isCompletedTx(string memory txKey) public view returns (bool){

        return completedTxs[txKey] > 0;
    }
    function ifManager(address _manager) public view returns (bool) {

        return managers[_manager] == 1;
    }
    function allManagers() public view returns (address[] memory) {

        return managerArray;
    }
    event DepositFunds(address from, uint amount);
    event CrossOutFunds(address from, string to, uint amount, address ERC20);
    event CrossOutIIFunds(address from, string to, uint amount, address ERC20, uint ethAmount, bytes data);
    event TransferFunds(address to, uint amount);
    event TxWithdrawCompleted(string txKey);
    event TxManagerChangeCompleted(string txKey);
    event TxUpgradeCompleted(string txKey);
}