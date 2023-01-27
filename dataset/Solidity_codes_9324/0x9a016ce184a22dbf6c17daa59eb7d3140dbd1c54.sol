


pragma solidity 0.6.12;

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



pragma solidity 0.6.12;

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



pragma solidity 0.6.12;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}



pragma solidity 0.6.12;

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



pragma solidity 0.6.12;

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



pragma solidity 0.6.12;

interface ERC20 {

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

}

contract Wallet {

    bool public isInitialized;
    address public creator;
    address public owner;
    bytes public swthAddress;

    function initialize(address _owner, bytes calldata _swthAddress) external {

        require(isInitialized == false, "Contract already initialized");
        isInitialized = true;
        creator = msg.sender;
        owner = _owner;
        swthAddress = _swthAddress;
    }

    receive() external payable {}

    function tokenFallback(address, uint, bytes calldata) external {}


    function sendETHToCreator(uint256 _amount) external {

        require(msg.sender == creator, "Sender must be creator");
        (bool success,  ) = creator.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    function sendERC20ToCreator(address _assetId, uint256 _amount) external {

        require(msg.sender == creator, "Sender must be creator");

        ERC20 token = ERC20(_assetId);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.transfer.selector,
                creator,
                _amount
            )
        );
    }

    function _callOptionalReturn(ERC20 token, bytes memory data) private {


        require(_isContract(address(token)), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function _isContract(address account) private view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}



pragma solidity 0.6.12;







interface CCM {

    function crossChain(uint64 _toChainId, bytes calldata _toContract, bytes calldata _method, bytes calldata _txData) external returns (bool);

}

interface CCMProxy {

    function getEthCrossChainManager() external view returns (address);

}

contract LockProxy is ReentrancyGuard {

    using SafeMath for uint256;

    struct ExtensionTxArgs {
        bytes extensionAddress;
    }

    struct RegisterAssetTxArgs {
        bytes assetHash;
        bytes nativeAssetHash;
    }

    struct TransferTxArgs {
        bytes fromAssetHash;
        bytes toAssetHash;
        bytes toAddress;
        uint256 amount;
        uint256 feeAmount;
        bytes feeAddress;
        bytes fromAddress;
        uint256 nonce;
    }

    bytes public constant SALT_PREFIX = "switcheo-eth-wallet-factory-v1";
    address public constant ETH_ASSET_HASH = address(0);

    CCMProxy public ccmProxy;
    uint64 public counterpartChainId;
    uint256 public currentNonce = 0;

    mapping(address => bytes32) public registry;

    mapping(bytes32 => bool) public seenMessages;

    mapping(address => bool) public extensions;

    mapping(address => bool) public wallets;

    event LockEvent(
        address fromAssetHash,
        address fromAddress,
        uint64 toChainId,
        bytes toAssetHash,
        bytes toAddress,
        bytes txArgs
    );

    event UnlockEvent(
        address toAssetHash,
        address toAddress,
        uint256 amount,
        bytes txArgs
    );

    constructor(address _ccmProxyAddress, uint64 _counterpartChainId) public {
        require(_counterpartChainId > 0, "counterpartChainId cannot be zero");
        require(_ccmProxyAddress != address(0), "ccmProxyAddress cannot be empty");
        counterpartChainId = _counterpartChainId;
        ccmProxy = CCMProxy(_ccmProxyAddress);
    }

    modifier onlyManagerContract() {

        require(
            msg.sender == ccmProxy.getEthCrossChainManager(),
            "msg.sender is not CCM"
        );
        _;
    }

    receive() external payable {}

    function tokenFallback(address, uint, bytes calldata) external {}


    function getWalletAddress(
        address _ownerAddress,
        bytes calldata _swthAddress,
        bytes32 _bytecodeHash
    )
        external
        view
        returns (address)
    {

        bytes32 salt = _getSalt(
            _ownerAddress,
            _swthAddress
        );

        bytes32 data = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), salt, _bytecodeHash)
        );

        return address(bytes20(data << 96));
    }

    function createWallet(
        address _ownerAddress,
        bytes calldata _swthAddress
    )
        external
        nonReentrant
        returns (bool)
    {

        require(_ownerAddress != address(0), "Empty ownerAddress");
        require(_swthAddress.length != 0, "Empty swthAddress");

        bytes32 salt = _getSalt(
            _ownerAddress,
            _swthAddress
        );

        Wallet wallet = new Wallet{salt: salt}();
        wallet.initialize(_ownerAddress, _swthAddress);
        wallets[address(wallet)] = true;

        return true;
    }

    function addExtension(
        bytes calldata _argsBz,
        bytes calldata /* _fromContractAddr */,
        uint64 _fromChainId
    )
        external
        onlyManagerContract
        nonReentrant
        returns (bool)
    {

        require(_fromChainId == counterpartChainId, "Invalid chain ID");

        ExtensionTxArgs memory args = _deserializeExtensionTxArgs(_argsBz);
        address extensionAddress = Utils.bytesToAddress(args.extensionAddress);
        extensions[extensionAddress] = true;

        return true;
    }

    function removeExtension(
        bytes calldata _argsBz,
        bytes calldata /* _fromContractAddr */,
        uint64 _fromChainId
    )
        external
        onlyManagerContract
        nonReentrant
        returns (bool)
    {

        require(_fromChainId == counterpartChainId, "Invalid chain ID");

        ExtensionTxArgs memory args = _deserializeExtensionTxArgs(_argsBz);
        address extensionAddress = Utils.bytesToAddress(args.extensionAddress);
        extensions[extensionAddress] = false;

        return true;
    }

    function registerAsset(
        bytes calldata _argsBz,
        bytes calldata _fromContractAddr,
        uint64 _fromChainId
    )
        external
        onlyManagerContract
        nonReentrant
        returns (bool)
    {

        require(_fromChainId == counterpartChainId, "Invalid chain ID");

        RegisterAssetTxArgs memory args = _deserializeRegisterAssetTxArgs(_argsBz);
        _markAssetAsRegistered(
            Utils.bytesToAddress(args.nativeAssetHash),
            _fromContractAddr,
            args.assetHash
        );

        return true;
    }

    function lockFromWallet(
        address payable _walletAddress,
        address _assetHash,
        bytes calldata _targetProxyHash,
        bytes calldata _toAssetHash,
        bytes calldata _feeAddress,
        uint256[] calldata _values,
        uint8 _v,
        bytes32[] calldata _rs
    )
        external
        nonReentrant
        returns (bool)
    {

        require(wallets[_walletAddress], "Invalid wallet address");

        Wallet wallet = Wallet(_walletAddress);
        _validateLockFromWallet(
            wallet.owner(),
            _assetHash,
            _targetProxyHash,
            _toAssetHash,
            _feeAddress,
            _values,
            _v,
            _rs
        );

        _transferInFromWallet(_walletAddress, _assetHash, _values[0], _values[3]);

        _lock(
            _assetHash,
            _targetProxyHash,
            _toAssetHash,
            wallet.swthAddress(),
            _values[0],
            _values[1],
            _feeAddress
        );

        return true;
    }

    function lock(
        address _assetHash,
        bytes calldata _targetProxyHash,
        bytes calldata _toAddress,
        bytes calldata _toAssetHash,
        bytes calldata _feeAddress,
        uint256[] calldata _values
    )
        external
        payable
        nonReentrant
        returns (bool)
    {


        _transferIn(_assetHash, _values[0], _values[2]);

        _lock(
            _assetHash,
            _targetProxyHash,
            _toAssetHash,
            _toAddress,
            _values[0],
            _values[1],
            _feeAddress
        );

        return true;
    }

    function unlock(
        bytes calldata _argsBz,
        bytes calldata _fromContractAddr,
        uint64 _fromChainId
    )
        external
        onlyManagerContract
        nonReentrant
        returns (bool)
    {

        require(_fromChainId == counterpartChainId, "Invalid chain ID");

        TransferTxArgs memory args = _deserializeTransferTxArgs(_argsBz);
        require(args.fromAssetHash.length > 0, "Invalid fromAssetHash");
        require(args.toAssetHash.length == 20, "Invalid toAssetHash");

        address toAssetHash = Utils.bytesToAddress(args.toAssetHash);
        address toAddress = Utils.bytesToAddress(args.toAddress);

        _validateAssetRegistration(toAssetHash, _fromContractAddr, args.fromAssetHash);
        _transferOut(toAddress, toAssetHash, args.amount);

        emit UnlockEvent(toAssetHash, toAddress, args.amount, _argsBz);
        return true;
    }

    function extensionTransfer(
        address _receivingAddress,
        address _assetHash,
        uint256 _amount
    )
        external
        returns (bool)
    {

        require(
            extensions[msg.sender] == true,
            "Invalid extension"
        );

        if (_assetHash == ETH_ASSET_HASH) {
            (bool success,  ) = _receivingAddress.call{value: _amount}("");
            require(success, "Transfer failed");
            return true;
        }

        ERC20 token = ERC20(_assetHash);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                _receivingAddress,
                _amount
            )
        );

        return true;
    }

    function _markAssetAsRegistered(
        address _assetHash,
        bytes memory _proxyAddress,
        bytes memory _toAssetHash
    )
        private
    {

        require(_proxyAddress.length == 20, "Invalid proxyAddress");
        require(
            registry[_assetHash] == bytes32(0),
            "Asset already registered"
        );

        bytes32 value = keccak256(abi.encodePacked(
            _proxyAddress,
            _toAssetHash
        ));

        registry[_assetHash] = value;
    }

    function _validateAssetRegistration(
        address _assetHash,
        bytes memory _proxyAddress,
        bytes memory _toAssetHash
    )
        private
        view
    {

        require(_proxyAddress.length == 20, "Invalid proxyAddress");
        bytes32 value = keccak256(abi.encodePacked(
            _proxyAddress,
            _toAssetHash
        ));
        require(registry[_assetHash] == value, "Asset not registered");
    }

    function _lock(
        address _fromAssetHash,
        bytes memory _targetProxyHash,
        bytes memory _toAssetHash,
        bytes memory _toAddress,
        uint256 _amount,
        uint256 _feeAmount,
        bytes memory _feeAddress
    )
        private
    {

        require(_targetProxyHash.length == 20, "Invalid targetProxyHash");
        require(_toAssetHash.length > 0, "Empty toAssetHash");
        require(_toAddress.length > 0, "Empty toAddress");
        require(_amount > 0, "Amount must be more than zero");
        require(_feeAmount < _amount, "Fee amount cannot be greater than amount");

        _validateAssetRegistration(_fromAssetHash, _targetProxyHash, _toAssetHash);

        TransferTxArgs memory txArgs = TransferTxArgs({
            fromAssetHash: Utils.addressToBytes(_fromAssetHash),
            toAssetHash: _toAssetHash,
            toAddress: _toAddress,
            amount: _amount,
            feeAmount: _feeAmount,
            feeAddress: _feeAddress,
            fromAddress: abi.encodePacked(msg.sender),
            nonce: _getNextNonce()
        });

        bytes memory txData = _serializeTransferTxArgs(txArgs);
        CCM ccm = _getCcm();
        require(
            ccm.crossChain(counterpartChainId, _targetProxyHash, "unlock", txData),
            "EthCrossChainManager crossChain executed error!"
        );

        emit LockEvent(_fromAssetHash, msg.sender, counterpartChainId, _toAssetHash, _toAddress, txData);
    }

    function _validateLockFromWallet(
        address _walletOwner,
        address _assetHash,
        bytes memory _targetProxyHash,
        bytes memory _toAssetHash,
        bytes memory _feeAddress,
        uint256[] memory _values,
        uint8 _v,
        bytes32[] memory _rs
    )
        private
    {

        bytes32 message = keccak256(abi.encodePacked(
            "sendTokens",
            _assetHash,
            _targetProxyHash,
            _toAssetHash,
            _feeAddress,
            _values[0],
            _values[1],
            _values[2]
        ));

        require(seenMessages[message] == false, "Message already seen");
        seenMessages[message] = true;
        _validateSignature(message, _walletOwner, _v, _rs[0], _rs[1]);
    }

    function _transferInFromWallet(
        address payable _walletAddress,
        address _assetHash,
        uint256 _amount,
        uint256 _callAmount
    )
        private
    {

        Wallet wallet = Wallet(_walletAddress);
        if (_assetHash == ETH_ASSET_HASH) {
            uint256 before = address(this).balance;

            wallet.sendETHToCreator(_callAmount);

            uint256 transferred = address(this).balance.sub(before);
            require(transferred == _amount, "ETH transferred does not match the expected amount");
            return;
        }

        ERC20 token = ERC20(_assetHash);
        uint256 before = token.balanceOf(address(this));

        wallet.sendERC20ToCreator(_assetHash, _callAmount);

        uint256 transferred = token.balanceOf(address(this)).sub(before);
        require(transferred == _amount, "Tokens transferred does not match the expected amount");
    }

    function _transferIn(
        address _assetHash,
        uint256 _amount,
        uint256 _callAmount
    )
        private
    {

        if (_assetHash == ETH_ASSET_HASH) {
            require(msg.value == _amount, "ETH transferred does not match the expected amount");
            return;
        }

        ERC20 token = ERC20(_assetHash);
        uint256 before = token.balanceOf(address(this));
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.transferFrom.selector,
                msg.sender,
                address(this),
                _callAmount
            )
        );
        uint256 transferred = token.balanceOf(address(this)).sub(before);
        require(transferred == _amount, "Tokens transferred does not match the expected amount");
    }

    function _transferOut(
        address _toAddress,
        address _assetHash,
        uint256 _amount
    )
        private
    {

        if (_assetHash == ETH_ASSET_HASH) {
            (bool success,  ) = _toAddress.call{value: _amount}("");
            require(success, "Transfer failed");
            return;
        }

        ERC20 token = ERC20(_assetHash);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.transfer.selector,
                _toAddress,
                _amount
            )
        );
    }

    function _validateSignature(
        bytes32 _message,
        address _user,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        private
        pure
    {

        bytes32 prefixedMessage = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            _message
        ));

        require(
            _user == ecrecover(prefixedMessage, _v, _r, _s),
            "Invalid signature"
        );
    }

    function _serializeTransferTxArgs(TransferTxArgs memory args) private pure returns (bytes memory) {

        bytes memory buff;
        buff = abi.encodePacked(
            ZeroCopySink.WriteVarBytes(args.fromAssetHash),
            ZeroCopySink.WriteVarBytes(args.toAssetHash),
            ZeroCopySink.WriteVarBytes(args.toAddress),
            ZeroCopySink.WriteUint255(args.amount),
            ZeroCopySink.WriteUint255(args.feeAmount),
            ZeroCopySink.WriteVarBytes(args.feeAddress),
            ZeroCopySink.WriteVarBytes(args.fromAddress),
            ZeroCopySink.WriteUint255(args.nonce)
        );
        return buff;
    }

    function _deserializeTransferTxArgs(bytes memory valueBz) private pure returns (TransferTxArgs memory) {

        TransferTxArgs memory args;
        uint256 off = 0;
        (args.fromAssetHash, off) = ZeroCopySource.NextVarBytes(valueBz, off);
        (args.toAssetHash, off) = ZeroCopySource.NextVarBytes(valueBz, off);
        (args.toAddress, off) = ZeroCopySource.NextVarBytes(valueBz, off);
        (args.amount, off) = ZeroCopySource.NextUint255(valueBz, off);
        return args;
    }

    function _deserializeRegisterAssetTxArgs(bytes memory valueBz) private pure returns (RegisterAssetTxArgs memory) {

        RegisterAssetTxArgs memory args;
        uint256 off = 0;
        (args.assetHash, off) = ZeroCopySource.NextVarBytes(valueBz, off);
        (args.nativeAssetHash, off) = ZeroCopySource.NextVarBytes(valueBz, off);
        return args;
    }

    function _deserializeExtensionTxArgs(bytes memory valueBz) private pure returns (ExtensionTxArgs memory) {

        ExtensionTxArgs memory args;
        uint256 off = 0;
        (args.extensionAddress, off) = ZeroCopySource.NextVarBytes(valueBz, off);
        return args;
    }

    function _getCcm() private view returns (CCM) {

      CCM ccm = CCM(ccmProxy.getEthCrossChainManager());
      return ccm;
    }

    function _getNextNonce() private returns (uint256) {

      currentNonce = currentNonce.add(1);
      return currentNonce;
    }

    function _getSalt(
        address _ownerAddress,
        bytes memory _swthAddress
    )
        private
        pure
        returns (bytes32)
    {

        return keccak256(abi.encodePacked(
            SALT_PREFIX,
            _ownerAddress,
            _swthAddress
        ));
    }


    function _callOptionalReturn(ERC20 token, bytes memory data) private {


        require(_isContract(address(token)), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function _isContract(address account) private view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}