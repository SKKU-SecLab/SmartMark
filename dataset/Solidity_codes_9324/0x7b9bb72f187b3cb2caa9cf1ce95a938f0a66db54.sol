

pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public  onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
pragma solidity ^0.5.0;

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

        require(b != 0, errorMessage);
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
pragma solidity ^0.5.0;


library Utils {


    function bytesToBytes32(bytes memory _bs) internal pure returns (bytes32 value) {

        require(_bs.length == 32, "bytes length is not 32.");
        assembly {
            value := mload(add(_bs, 0x20))
        }
    }

    function bytesToUint256(bytes memory _bs) internal pure returns (uint256 value) {

        require(_bs.length == 32, "bytes length is not 32.");
        assembly {
            value := mload(add(_bs, 0x20))
        }
        require(value <= 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "Value exceeds the range");
    }

    function uint256ToBytes(uint256 _value) internal pure returns (bytes memory bs) {

        require(_value <= 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "Value exceeds the range");
        assembly {
            bs := mload(0x40)
            mstore(bs, 0x20)
            mstore(add(bs, 0x20), _value)
            mstore(0x40, add(bs, 0x40))
        }
    }

    function bytesToAddress(bytes memory _bs) internal pure returns (address addr)
    {

        require(_bs.length == 20, "bytes length does not match address");
        assembly {
            addr := mload(add(_bs, 0x14))
        }

    }
    
    function addressToBytes(address _addr) internal pure returns (bytes memory bs){

        assembly {
            bs := mload(0x40)
            mstore(bs, 0x14)
            mstore(add(bs, 0x20), shl(96, _addr))
            mstore(0x40, add(bs, 0x40))
       }
    }

    function hashLeaf(bytes memory _data) internal pure returns (bytes32 result)  {

        result = sha256(abi.encodePacked(byte(0x0), _data));
    }

    function hashChildren(bytes32 _l, bytes32  _r) internal pure returns (bytes32 result)  {

        result = sha256(abi.encodePacked(bytes1(0x01), _l, _r));
    }

    function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {

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
    function containMAddresses(address[] memory _keepers, address[] memory _signers, uint _m) internal pure returns (bool){
        uint m = 0;
        for(uint i = 0; i < _signers.length; i++){
            for (uint j = 0; j < _keepers.length; j++) {
                if (_signers[i] == _keepers[j]) {
                    m++;
                    delete _keepers[j];
                }
            }
        }
        return m >= _m;
    }

    function compressMCPubKey(bytes memory key) internal pure returns (bytes memory newkey) {
         require(key.length >= 67, "key lenggh is too short");
         newkey = slice(key, 0, 35);
         if (uint8(key[66]) % 2 == 0){
             newkey[2] = byte(0x02);
         } else {
             newkey[2] = byte(0x03);
         }
         return newkey;
    }
    
    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}
pragma solidity ^0.5.0;

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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(Utils.isContract(address(token)), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
pragma solidity ^0.5.0;

interface IEthCrossChainManager {

    function crossChain(uint64 _toChainId, bytes calldata _toContract, bytes calldata _method, bytes calldata _txData) external returns (bool);

}
pragma solidity ^0.5.0;

interface IEthCrossChainManagerProxy {

    function getEthCrossChainManager() external view returns (address);

}
pragma solidity ^0.5.0;

library ZeroCopySource {

    function NextBool(bytes memory buff, uint256 offset) internal pure returns(bool, uint256) {

        require(offset + 1 <= buff.length && offset < offset + 1, "Offset exceeds limit");
        byte v;
        assembly{
            v := mload(add(add(buff, 0x20), offset))
        }
        bool value;
        if (v == 0x01) {
		    value = true;
    	} else if (v == 0x00) {
            value = false;
        } else {
            revert("NextBool value error");
        }
        return (value, offset + 1);
    }

    function NextByte(bytes memory buff, uint256 offset) internal pure returns (byte, uint256) {

        require(offset + 1 <= buff.length && offset < offset + 1, "NextByte, Offset exceeds maximum");
        byte v;
        assembly{
            v := mload(add(add(buff, 0x20), offset))
        }
        return (v, offset + 1);
    }

    function NextUint8(bytes memory buff, uint256 offset) internal pure returns (uint8, uint256) {

        require(offset + 1 <= buff.length && offset < offset + 1, "NextUint8, Offset exceeds maximum");
        uint8 v;
        assembly{
            let tmpbytes := mload(0x40)
            let bvalue := mload(add(add(buff, 0x20), offset))
            mstore8(tmpbytes, byte(0, bvalue))
            mstore(0x40, add(tmpbytes, 0x01))
            v := mload(sub(tmpbytes, 0x1f))
        }
        return (v, offset + 1);
    }

    function NextUint16(bytes memory buff, uint256 offset) internal pure returns (uint16, uint256) {

        require(offset + 2 <= buff.length && offset < offset + 2, "NextUint16, offset exceeds maximum");
        
        uint16 v;
        assembly {
            let tmpbytes := mload(0x40)
            let bvalue := mload(add(add(buff, 0x20), offset))
            mstore8(tmpbytes, byte(0x01, bvalue))
            mstore8(add(tmpbytes, 0x01), byte(0, bvalue))
            mstore(0x40, add(tmpbytes, 0x02))
            v := mload(sub(tmpbytes, 0x1e))
        }
        return (v, offset + 2);
    }


    function NextUint32(bytes memory buff, uint256 offset) internal pure returns (uint32, uint256) {

        require(offset + 4 <= buff.length && offset < offset + 4, "NextUint32, offset exceeds maximum");
        uint32 v;
        assembly {
            let tmpbytes := mload(0x40)
            let byteLen := 0x04
            for {
                let tindex := 0x00
                let bindex := sub(byteLen, 0x01)
                let bvalue := mload(add(add(buff, 0x20), offset))
            } lt(tindex, byteLen) {
                tindex := add(tindex, 0x01)
                bindex := sub(bindex, 0x01)
            }{
                mstore8(add(tmpbytes, tindex), byte(bindex, bvalue))
            }
            mstore(0x40, add(tmpbytes, byteLen))
            v := mload(sub(tmpbytes, sub(0x20, byteLen)))
        }
        return (v, offset + 4);
    }

    function NextUint64(bytes memory buff, uint256 offset) internal pure returns (uint64, uint256) {

        require(offset + 8 <= buff.length && offset < offset + 8, "NextUint64, offset exceeds maximum");
        uint64 v;
        assembly {
            let tmpbytes := mload(0x40)
            let byteLen := 0x08
            for {
                let tindex := 0x00
                let bindex := sub(byteLen, 0x01)
                let bvalue := mload(add(add(buff, 0x20), offset))
            } lt(tindex, byteLen) {
                tindex := add(tindex, 0x01)
                bindex := sub(bindex, 0x01)
            }{
                mstore8(add(tmpbytes, tindex), byte(bindex, bvalue))
            }
            mstore(0x40, add(tmpbytes, byteLen))
            v := mload(sub(tmpbytes, sub(0x20, byteLen)))
        }
        return (v, offset + 8);
    }

    function NextUint255(bytes memory buff, uint256 offset) internal pure returns (uint256, uint256) {

        require(offset + 32 <= buff.length && offset < offset + 32, "NextUint255, offset exceeds maximum");
        uint256 v;
        assembly {
            let tmpbytes := mload(0x40)
            let byteLen := 0x20
            for {
                let tindex := 0x00
                let bindex := sub(byteLen, 0x01)
                let bvalue := mload(add(add(buff, 0x20), offset))
            } lt(tindex, byteLen) {
                tindex := add(tindex, 0x01)
                bindex := sub(bindex, 0x01)
            }{
                mstore8(add(tmpbytes, tindex), byte(bindex, bvalue))
            }
            mstore(0x40, add(tmpbytes, byteLen))
            v := mload(tmpbytes)
        }
        require(v <= 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "Value exceeds the range");
        return (v, offset + 32);
    }
    function NextVarBytes(bytes memory buff, uint256 offset) internal pure returns(bytes memory, uint256) {

        uint len;
        (len, offset) = NextVarUint(buff, offset);
        require(offset + len <= buff.length && offset < offset + len, "NextVarBytes, offset exceeds maximum");
        bytes memory tempBytes;
        assembly{
            switch iszero(len)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(len, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, len)

                for {
                    let cc := add(add(add(buff, lengthmod), mul(0x20, iszero(lengthmod))), offset)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, len)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return (tempBytes, offset + len);
    }
    function NextHash(bytes memory buff, uint256 offset) internal pure returns (bytes32 , uint256) {

        require(offset + 32 <= buff.length && offset < offset + 32, "NextHash, offset exceeds maximum");
        bytes32 v;
        assembly {
            v := mload(add(buff, add(offset, 0x20)))
        }
        return (v, offset + 32);
    }

    function NextBytes20(bytes memory buff, uint256 offset) internal pure returns (bytes20 , uint256) {

        require(offset + 20 <= buff.length && offset < offset + 20, "NextBytes20, offset exceeds maximum");
        bytes20 v;
        assembly {
            v := mload(add(buff, add(offset, 0x20)))
        }
        return (v, offset + 20);
    }
    
    function NextVarUint(bytes memory buff, uint256 offset) internal pure returns(uint, uint256) {

        byte v;
        (v, offset) = NextByte(buff, offset);

        uint value;
        if (v == 0xFD) {
            (value, offset) = NextUint16(buff, offset);
            require(value >= 0xFD && value <= 0xFFFF, "NextUint16, value outside range");
            return (value, offset);
        } else if (v == 0xFE) {
            (value, offset) = NextUint32(buff, offset);
            require(value > 0xFFFF && value <= 0xFFFFFFFF, "NextVarUint, value outside range");
            return (value, offset);
        } else if (v == 0xFF) {
            (value, offset) = NextUint64(buff, offset);
            require(value > 0xFFFFFFFF, "NextVarUint, value outside range");
            return (value, offset);
        } else{
            value = uint8(v);
            require(value < 0xFD, "NextVarUint, value outside range");
            return (value, offset);
        }
    }
}
pragma solidity ^0.5.0;

library ZeroCopySink {

    function WriteBool(bool b) internal pure returns (bytes memory) {

        bytes memory buff;
        assembly{
            buff := mload(0x40)
            mstore(buff, 1)
            switch iszero(b)
            case 1 {
                mstore(add(buff, 0x20), shl(248, 0x00))
            }
            default {
                mstore(add(buff, 0x20), shl(248, 0x01))
            }
            mstore(0x40, add(buff, 0x21))
        }
        return buff;
    }

    function WriteByte(byte b) internal pure returns (bytes memory) {

        return WriteUint8(uint8(b));
    }

    function WriteUint8(uint8 v) internal pure returns (bytes memory) {

        bytes memory buff;
        assembly{
            buff := mload(0x40)
            mstore(buff, 1)
            mstore(add(buff, 0x20), shl(248, v))
            mstore(0x40, add(buff, 0x21))
        }
        return buff;
    }

    function WriteUint16(uint16 v) internal pure returns (bytes memory) {

        bytes memory buff;

        assembly{
            buff := mload(0x40)
            let byteLen := 0x02
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            }{
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x22))
        }
        return buff;
    }
    
    function WriteUint32(uint32 v) internal pure returns(bytes memory) {

        bytes memory buff;
        assembly{
            buff := mload(0x40)
            let byteLen := 0x04
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            }{
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x24))
        }
        return buff;
    }

    function WriteUint64(uint64 v) internal pure returns(bytes memory) {

        bytes memory buff;

        assembly{
            buff := mload(0x40)
            let byteLen := 0x08
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            }{
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x28))
        }
        return buff;
    }

    function WriteUint255(uint256 v) internal pure returns (bytes memory) {

        require(v <= 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff, "Value exceeds uint255 range");
        bytes memory buff;

        assembly{
            buff := mload(0x40)
            let byteLen := 0x20
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            }{
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x40))
        }
        return buff;
    }

    function WriteVarBytes(bytes memory data) internal pure returns (bytes memory) {

        uint64 l = uint64(data.length);
        return abi.encodePacked(WriteVarUint(l), data);
    }

    function WriteVarUint(uint64 v) internal pure returns (bytes memory) {

        if (v < 0xFD){
    		return WriteUint8(uint8(v));
    	} else if (v <= 0xFFFF) {
    		return abi.encodePacked(WriteByte(0xFD), WriteUint16(uint16(v)));
    	} else if (v <= 0xFFFFFFFF) {
            return abi.encodePacked(WriteByte(0xFE), WriteUint32(uint32(v)));
    	} else {
    		return abi.encodePacked(WriteByte(0xFF), WriteUint64(uint64(v)));
    	}
    }
}
contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}
contract LockProxyWithLP is Ownable, Pausable {

    using SafeMath for uint;
    using SafeERC20 for IERC20;

    struct TxArgs {
        bytes toAssetHash;
        bytes toAddress;
        uint256 amount;
    }
    address public managerProxyContract;

    mapping(uint64 => bytes) public proxyHashMap;
    mapping(address => mapping(uint64 => bytes)) public assetHashMap;
    mapping(address => address) public assetLPMap;

    event SetManagerProxyEvent(address manager);
    event BindProxyEvent(uint64 toChainId, bytes targetProxyHash);
    event BindAssetEvent(address fromAssetHash, uint64 toChainId, bytes targetProxyHash, uint initialAmount);
    event UnlockEvent(address toAssetHash, address toAddress, uint256 amount);
    event LockEvent(address fromAssetHash, address fromAddress, uint64 toChainId, bytes toAssetHash, bytes toAddress, uint256 amount);

    event depositEvent(address toAddress, address fromAssetHash, address fromLPHash, uint256 amount);
    event withdrawEvent(address toAddress, address fromAssetHash, address fromLPHash, uint256 amount);
    event BindLPToAssetEvent(address originAssetAddress, address LPTokenAddress);

    modifier onlyManagerContract() {

        IEthCrossChainManagerProxy ieccmp = IEthCrossChainManagerProxy(managerProxyContract);
        require(_msgSender() == ieccmp.getEthCrossChainManager(), "msgSender is not EthCrossChainManagerContract");
        _;
    }

    function pause() onlyOwner whenNotPaused public returns (bool) {

        _pause();
        return true;
    }
    function unpause() onlyOwner whenPaused public returns (bool) {

        _unpause();
        return true;
    }
    
    function setManagerProxy(address ethCCMProxyAddr) onlyOwner public {

        managerProxyContract = ethCCMProxyAddr;
        emit SetManagerProxyEvent(managerProxyContract);
    }
    
    function bindProxyHash(uint64 toChainId, bytes memory targetProxyHash) onlyOwner public returns (bool) {

        proxyHashMap[toChainId] = targetProxyHash;
        emit BindProxyEvent(toChainId, targetProxyHash);
        return true;
    }

    function bindAssetHash(address fromAssetHash, uint64 toChainId, bytes memory toAssetHash) onlyOwner public returns (bool) {

        assetHashMap[fromAssetHash][toChainId] = toAssetHash;
        emit BindAssetEvent(fromAssetHash, toChainId, toAssetHash, getBalanceFor(fromAssetHash));
        return true;
    }

    function bindLPToAsset(address originAssetAddress, address LPTokenAddress) onlyOwner public returns (bool) {

        assetLPMap[originAssetAddress] = LPTokenAddress;
        emit BindLPToAssetEvent(originAssetAddress, LPTokenAddress);
        return true;
    }

    function bindLPAndAsset(address fromAssetHash, address fromLPHash, uint64 toChainId, bytes memory toAssetHash, bytes memory toLPHash) onlyOwner public returns (bool) {

        assetHashMap[fromAssetHash][toChainId] = toAssetHash;
        assetHashMap[fromLPHash][toChainId] = toLPHash;
        assetLPMap[fromAssetHash] = fromLPHash;
        emit BindAssetEvent(fromAssetHash, toChainId, toAssetHash, getBalanceFor(fromAssetHash));
        emit BindAssetEvent(fromLPHash, toChainId, toLPHash, getBalanceFor(fromLPHash));
        emit BindLPToAssetEvent(fromAssetHash, fromLPHash);
        return true;
    }
    
    function bindProxyHashBatch(uint64[] memory toChainId, bytes[] memory targetProxyHash) onlyOwner public returns (bool) {

        require(toChainId.length == targetProxyHash.length, "bindProxyHashBatch: args length diff");
        for (uint i = 0; i < toChainId.length; i++) {
            proxyHashMap[toChainId[i]] = targetProxyHash[i];
            emit BindProxyEvent(toChainId[i], targetProxyHash[i]);
        }
        return true;
    }

    function bindAssetHashBatch(address[] memory fromAssetHash, uint64[] memory toChainId, bytes[] memory toAssetHash) onlyOwner public returns (bool) {

        require(toChainId.length == fromAssetHash.length, "bindAssetHashBatch: args length diff");
        require(toChainId.length == toAssetHash.length, "bindAssetHashBatch: args length diff");
        for (uint i = 0; i < toChainId.length; i++) {
            assetHashMap[fromAssetHash[i]][toChainId[i]] = toAssetHash[i];
            emit BindAssetEvent(fromAssetHash[i], toChainId[i], toAssetHash[i], getBalanceFor(fromAssetHash[i]));
        }
        return true;
    }

    function bindLPToAssetBatch(address[] memory originAssetAddress, address[] memory LPTokenAddress) onlyOwner public returns (bool) {

        require(originAssetAddress.length == LPTokenAddress.length, "bindLPToAssetBatch: args length diff");
        for (uint i = 0; i < originAssetAddress.length; i++) {
            assetLPMap[originAssetAddress[i]] = LPTokenAddress[i];
            emit BindLPToAssetEvent(originAssetAddress[i], LPTokenAddress[i]);
        }
        return true;
    }
 
    function bindLPAndAssetBatch(address[] memory fromAssetHash, address[] memory fromLPHash, uint64[] memory toChainId, bytes[] memory toAssetHash, bytes[] memory toLPHash) onlyOwner public returns (bool) {

        require(fromAssetHash.length == fromLPHash.length, "bindLPAndAssetBatch: args length diff");
        require(toAssetHash.length == toLPHash.length, "bindLPAndAssetBatch: args length diff");
        for(uint256 i = 0; i < fromLPHash.length; i++) {
            assetHashMap[fromAssetHash[i]][toChainId[i]] = toAssetHash[i];
            assetHashMap[fromLPHash[i]][toChainId[i]] = toLPHash[i];
            assetLPMap[fromAssetHash[i]] = fromLPHash[i];
            emit BindAssetEvent(fromAssetHash[i], toChainId[i], toAssetHash[i], getBalanceFor(fromAssetHash[i]));
            emit BindAssetEvent(fromLPHash[i], toChainId[i], toLPHash[i], getBalanceFor(fromLPHash[i]));
            emit BindLPToAssetEvent(fromAssetHash[i], fromLPHash[i]);
        }
        return true;
    } 

    function lock(address fromAssetHash, uint64 toChainId, bytes memory toAddress, uint256 amount) public payable returns (bool) {

        require(amount != 0, "amount cannot be zero!");
        require(_transferToContract(fromAssetHash, amount), "transfer asset from fromAddress to lock_proxy contract failed!");
        bytes memory toAssetHash = assetHashMap[fromAssetHash][toChainId];
        require(toAssetHash.length != 0, "empty illegal toAssetHash");

        TxArgs memory txArgs = TxArgs({
            toAssetHash: toAssetHash,
            toAddress: toAddress,
            amount: amount
        });
        bytes memory txData = _serializeTxArgs(txArgs);
        
        IEthCrossChainManagerProxy eccmp = IEthCrossChainManagerProxy(managerProxyContract);
        address eccmAddr = eccmp.getEthCrossChainManager();
        IEthCrossChainManager eccm = IEthCrossChainManager(eccmAddr);
        
        bytes memory toProxyHash = proxyHashMap[toChainId];
        require(toProxyHash.length != 0, "empty illegal toProxyHash");
        require(eccm.crossChain(toChainId, toProxyHash, "unlock", txData), "EthCrossChainManager crossChain executed error!");

        emit LockEvent(fromAssetHash, _msgSender(), toChainId, toAssetHash, toAddress, amount);
        
        return true;
    }
    
    function unlock(bytes memory argsBs, bytes memory fromContractAddr, uint64 fromChainId) onlyManagerContract public returns (bool) {

        TxArgs memory args = _deserializeTxArgs(argsBs);

        require(fromContractAddr.length != 0, "from proxy contract address cannot be empty");
        require(Utils.equalStorage(proxyHashMap[fromChainId], fromContractAddr), "From Proxy contract address error!");
        
        require(args.toAssetHash.length != 0, "toAssetHash cannot be empty");
        address toAssetHash = Utils.bytesToAddress(args.toAssetHash);

        require(args.toAddress.length != 0, "toAddress cannot be empty");
        address toAddress = Utils.bytesToAddress(args.toAddress);
        
        require(_transferFromContract(toAssetHash, toAddress, args.amount), "transfer asset from lock_proxy contract to toAddress failed!");
        
        emit UnlockEvent(toAssetHash, toAddress, args.amount);
        return true;
    }


    function deposit(address originAssetAddress, uint amount) whenNotPaused payable public returns (bool) {

        require(amount != 0, "amount cannot be zero!");

        require(_transferToContract(originAssetAddress, amount), "transfer asset from fromAddress to lock_proxy contract failed!");

        address LPTokenAddress = assetLPMap[originAssetAddress];
        require(LPTokenAddress != address(0), "do not support deposite this token");
        require(_transferFromContract(LPTokenAddress, msg.sender, amount), "transfer proof of liquidity from lock_proxy contract to fromAddress failed!");
        
        emit depositEvent(msg.sender, originAssetAddress, LPTokenAddress, amount);
        return true;
    }

    function withdraw(address targetTokenAddress, uint amount) whenNotPaused public returns (bool) {

        require(amount != 0, "amount cannot be zero!");

        address LPTokenAddress = assetLPMap[targetTokenAddress];
        require(LPTokenAddress != address(0), "do not support withdraw this token");
        require(_transferToContract(LPTokenAddress, amount), "transfer proof of liquidity from fromAddress to lock_proxy contract failed!");

        require(_transferFromContract(targetTokenAddress, msg.sender, amount), "transfer asset from lock_proxy contract to fromAddress failed!");
        
        emit withdrawEvent(msg.sender, targetTokenAddress, LPTokenAddress, amount);
        return true;
    }

    function getBalanceFor(address fromAssetHash) public view returns (uint256) {

        if (fromAssetHash == address(0)) {
            address selfAddr = address(this);
            return selfAddr.balance;
        } else {
            IERC20 erc20Token = IERC20(fromAssetHash);
            return erc20Token.balanceOf(address(this));
        }
    }

    function _transferToContract(address fromAssetHash, uint256 amount) internal returns (bool) {

        if (fromAssetHash == address(0)) {
            require(msg.value != 0, "transferred ether cannot be zero!");
            require(msg.value == amount, "transferred ether is not equal to amount!");
        } else {
            require(msg.value == 0, "there should be no ether transfer!");
            require(_transferERC20ToContract(fromAssetHash, _msgSender(), address(this), amount), "transfer erc20 asset to lock_proxy contract failed!");
        }
        return true;
    }
    function _transferFromContract(address toAssetHash, address toAddress, uint256 amount) internal returns (bool) {

        if (toAssetHash == address(0x0000000000000000000000000000000000000000)) {
            address(uint160(toAddress)).transfer(amount);
        } else {
            require(_transferERC20FromContract(toAssetHash, toAddress, amount), "transfer erc20 asset to lock_proxy contract failed!");
        }
        return true;
    }
    
    function _transferERC20ToContract(address fromAssetHash, address fromAddress, address toAddress, uint256 amount) internal returns (bool) {

         IERC20 erc20Token = IERC20(fromAssetHash);
         erc20Token.safeTransferFrom(fromAddress, toAddress, amount);
         return true;
    }
    function _transferERC20FromContract(address toAssetHash, address toAddress, uint256 amount) internal returns (bool) {

         IERC20 erc20Token = IERC20(toAssetHash);
         erc20Token.safeTransfer(toAddress, amount);
         return true;
    }
    
    function _serializeTxArgs(TxArgs memory args) internal pure returns (bytes memory) {

        bytes memory buff;
        buff = abi.encodePacked(
            ZeroCopySink.WriteVarBytes(args.toAssetHash),
            ZeroCopySink.WriteVarBytes(args.toAddress),
            ZeroCopySink.WriteUint255(args.amount)
            );
        return buff;
    }

    function _deserializeTxArgs(bytes memory valueBs) internal pure returns (TxArgs memory) {

        TxArgs memory args;
        uint256 off = 0;
        (args.toAssetHash, off) = ZeroCopySource.NextVarBytes(valueBs, off);
        (args.toAddress, off) = ZeroCopySource.NextVarBytes(valueBs, off);
        (args.amount, off) = ZeroCopySource.NextUint255(valueBs, off);
        return args;
    }
}