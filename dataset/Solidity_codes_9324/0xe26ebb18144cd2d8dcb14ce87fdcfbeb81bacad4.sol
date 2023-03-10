pragma solidity ^0.5.0;

contract ReentrancyGuard {

    uint constant private LOCK_FLAG_ADDRESS = 0x8e94fed44239eb2314ab7a406345e6c5a8f0ccedf3b600de3d004e672c33abf4; // keccak256("ReentrancyGuard") - 1;

    function initializeReentrancyGuard () internal {
        assembly { sstore(LOCK_FLAG_ADDRESS, 1) }
    }

    modifier nonReentrant() {

        bool notEntered;
        assembly { notEntered := sload(LOCK_FLAG_ADDRESS) }

        require(notEntered, "ReentrancyGuard: reentrant call");

        assembly { sstore(LOCK_FLAG_ADDRESS, 0) }

        _;

        assembly { sstore(LOCK_FLAG_ADDRESS, 1) }
    }
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;

library SafeMathUInt128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128) {

        uint128 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {

        require(b <= a, errorMessage);
        uint128 c = a - b;

        return c;
    }

    function mul(uint128 a, uint128 b) internal pure returns (uint128) {

        if (a == 0) {
            return 0;
        }

        uint128 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint128 a, uint128 b) internal pure returns (uint128) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {

        require(b > 0, errorMessage);
        uint128 c = a / b;

        return c;
    }

    function mod(uint128 a, uint128 b) internal pure returns (uint128) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {

        require(b != 0, errorMessage);
        return a % b;
    }
}pragma solidity ^0.5.0;


library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.0;


library Bytes {


    function toBytesFromUInt16(uint16 self) internal pure returns (bytes memory _bts) {

        return toBytesFromUIntTruncated(uint(self), 2);
    }

    function toBytesFromUInt24(uint24 self) internal pure returns (bytes memory _bts) {

        return toBytesFromUIntTruncated(uint(self), 3);
    }

    function toBytesFromUInt32(uint32 self) internal pure returns (bytes memory _bts) {

        return toBytesFromUIntTruncated(uint(self), 4);
    }

    function toBytesFromUInt128(uint128 self) internal pure returns (bytes memory _bts) {

        return toBytesFromUIntTruncated(uint(self), 16);
    }

    function toBytesFromUIntTruncated(uint self, uint8 byteLength) private pure returns (bytes memory bts) {

        require(byteLength <= 32, "bt211");
        bts = new bytes(byteLength);
        uint data = self << ((32 - byteLength) * 8);
        assembly {
            mstore(add(bts, /*BYTES_HEADER_SIZE*/32), data)
        }
    }

    function toBytesFromAddress(address self) internal pure returns (bytes memory bts) {

        bts = toBytesFromUIntTruncated(uint(self), 20);
    }

    function bytesToAddress(bytes memory self, uint256 _start) internal pure returns (address addr) {

        uint256 offset = _start + 20;
        require(self.length >= offset, "bta11");
        assembly {
            addr := mload(add(self, offset))
        }
    }

    function bytesToBytes20(bytes memory self, uint256 _start) internal pure returns (bytes20 r) {

        require(self.length >= (_start + 20), "btb20");
        assembly {
            r := mload(add(add(self, 0x20), _start))
        }
    }

    function bytesToUInt16(bytes memory _bytes, uint256 _start) internal pure returns (uint16 r) {

        uint256 offset = _start + 0x2;
        require(_bytes.length >= offset, "btu02");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    function bytesToUInt24(bytes memory _bytes, uint256 _start) internal pure returns (uint24 r) {

        uint256 offset = _start + 0x3;
        require(_bytes.length >= offset, "btu03");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    function bytesToUInt32(bytes memory _bytes, uint256 _start) internal pure returns (uint32 r) {

        uint256 offset = _start + 0x4;
        require(_bytes.length >= offset, "btu04");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    function bytesToUInt128(bytes memory _bytes, uint256 _start) internal pure returns (uint128 r) {

        uint256 offset = _start + 0x10;
        require(_bytes.length >= offset, "btu16");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    function bytesToUInt160(bytes memory _bytes, uint256 _start) internal pure returns (uint160 r) {

        uint256 offset = _start + 0x14;
        require(_bytes.length >= offset, "btu20");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    function bytesToBytes32(bytes memory  _bytes, uint256 _start) internal pure returns (bytes32 r) {

        uint256 offset = _start + 0x20;
        require(_bytes.length >= offset, "btb32");
        assembly {
            r := mload(add(_bytes, offset))
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

        require(_bytes.length >= (_start + _length), "bse11"); // bytes length is less then start byte + length bytes

        bytes memory tempBytes = new bytes(_length);

        if (_length != 0) {
            assembly {
                let slice_curr := add(tempBytes, 0x20)
                let slice_end := add(slice_curr, _length)

                for {
                    let array_current := add(_bytes, add(_start, 0x20))
                } lt(slice_curr, slice_end) {
                    slice_curr := add(slice_curr, 0x20)
                    array_current := add(array_current, 0x20)
                } {
                    mstore(slice_curr, mload(array_current))
                }
            }
        }

        return tempBytes;
    }

    function read(bytes memory _data, uint _offset, uint _length) internal pure returns (uint new_offset, bytes memory data) {

        data = slice(_data, _offset, _length);
        new_offset = _offset + _length;
    }

    function readBool(bytes memory _data, uint _offset) internal pure returns (uint new_offset, bool r) {

        new_offset = _offset + 1;
        r = uint8(_data[_offset]) != 0;
    }

    function readUint8(bytes memory _data, uint _offset) internal pure returns (uint new_offset, uint8 r) {

        new_offset = _offset + 1;
        r = uint8(_data[_offset]);
    }

    function readUInt16(bytes memory _data, uint _offset) internal pure returns (uint new_offset, uint16 r) {

        new_offset = _offset + 2;
        r = bytesToUInt16(_data, _offset);
    }

    function readUInt24(bytes memory _data, uint _offset) internal pure returns (uint new_offset, uint24 r) {

        new_offset = _offset + 3;
        r = bytesToUInt24(_data, _offset);
    }

    function readUInt32(bytes memory _data, uint _offset) internal pure returns (uint new_offset, uint32 r) {

        new_offset = _offset + 4;
        r = bytesToUInt32(_data, _offset);
    }

    function readUInt128(bytes memory _data, uint _offset) internal pure returns (uint new_offset, uint128 r) {

        new_offset = _offset + 16;
        r = bytesToUInt128(_data, _offset);
    }

    function readUInt160(bytes memory _data, uint _offset) internal pure returns (uint new_offset, uint160 r) {

        new_offset = _offset + 20;
        r = bytesToUInt160(_data, _offset);
    }

    function readAddress(bytes memory _data, uint _offset) internal pure returns (uint new_offset, address r) {

        new_offset = _offset + 20;
        r = bytesToAddress(_data, _offset);
    }

    function readBytes20(bytes memory _data, uint _offset) internal pure returns (uint new_offset, bytes20 r) {

        new_offset = _offset + 20;
        r = bytesToBytes20(_data, _offset);
    }

    function readBytes32(bytes memory _data, uint _offset) internal pure returns (uint new_offset, bytes32 r) {

        new_offset = _offset + 32;
        r = bytesToBytes32(_data, _offset);
    }

    function halfByteToHex(byte _byte) internal pure returns (byte _hexByte) {

        require(uint8(_byte) < 0x10, "hbh11");  // half byte's value is out of 0..15 range.

        return byte (uint8 (0x66656463626139383736353433323130 >> (uint8 (_byte) * 8)));
    }

    function bytesToHexASCIIBytes(bytes memory  _input) internal pure returns (bytes memory _output) {

        bytes memory outStringBytes = new bytes(_input.length * 2);

        assembly {
            let input_curr := add(_input, 0x20)
            let input_end := add(input_curr, mload(_input))

            for {
                let out_curr := add(outStringBytes, 0x20)
            } lt(input_curr, input_end) {
                input_curr := add(input_curr, 0x01)
                out_curr := add(out_curr, 0x02)
            } {
                let curr_input_byte := shr(0xf8, mload(input_curr))
                mstore(out_curr,            shl(0xf8, shr(mul(shr(0x04, curr_input_byte), 0x08), 0x66656463626139383736353433323130)))
                mstore(add(out_curr, 0x01), shl(0xf8, shr(mul(and(0x0f, curr_input_byte), 0x08), 0x66656463626139383736353433323130)))
            }
        }
        return outStringBytes;
    }

    function trim(bytes memory _data, uint _new_length) internal pure returns (uint r) {

        require(_new_length <= 0x20, "trm10");  // new_length is longer than word
        require(_data.length >= _new_length, "trm11");  // data is to short

        uint a;
        assembly {
            a := mload(add(_data, 0x20)) // load bytes into uint256
        }

        return a >> ((0x20 - _new_length) * 8);
    }
}pragma solidity ^0.5.0;


library Utils {

    function minU32(uint32 a, uint32 b) internal pure returns (uint32) {

        return a < b ? a : b;
    }

    function minU64(uint64 a, uint64 b) internal pure returns (uint64) {

        return a < b ? a : b;
    }

    function sendERC20(IERC20 _token, address _to, uint256 _amount) internal returns (bool) {

        (bool callSuccess, bytes memory callReturnValueEncoded) = address(_token).call(
            abi.encodeWithSignature("transfer(address,uint256)", _to, _amount)
        );
        bool returnedSuccess = callReturnValueEncoded.length == 0 || abi.decode(callReturnValueEncoded, (bool));
        return callSuccess && returnedSuccess;
    }

    function transferFromERC20(IERC20 _token, address _from, address _to, uint256 _amount) internal returns (bool) {

        (bool callSuccess, bytes memory callReturnValueEncoded) = address(_token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _amount)
        );
        bool returnedSuccess = callReturnValueEncoded.length == 0 || abi.decode(callReturnValueEncoded, (bool));
        return callSuccess && returnedSuccess;
    }

    function sendETHNoRevert(address payable _to, uint256 _amount) internal returns (bool) {

        uint256 ETH_WITHDRAWAL_GAS_LIMIT = 10000;

        (bool callSuccess, ) = _to.call.gas(ETH_WITHDRAWAL_GAS_LIMIT).value(_amount)("");
        return callSuccess;
    }

    function recoverAddressFromEthSignature(bytes memory _signature, bytes memory _message) internal pure returns (address) {

        require(_signature.length == 65, "ves10"); // incorrect signature length

        bytes32 signR;
        bytes32 signS;
        uint offset = 0;

        (offset, signR) = Bytes.readBytes32(_signature, offset);
        (offset, signS) = Bytes.readBytes32(_signature, offset);
        uint8 signV = uint8(_signature[offset]);

        return ecrecover(keccak256(_message), signV, signR, signS);
    }
}pragma solidity ^0.5.0;


contract Config {


    uint256 constant ERC20_WITHDRAWAL_GAS_LIMIT = 350000;

    uint256 constant ETH_WITHDRAWAL_GAS_LIMIT = 10000;

    uint8 constant CHUNK_BYTES = 11;

    uint8 constant ADDRESS_BYTES = 20;

    uint8 constant PUBKEY_HASH_BYTES = 20;

    uint8 constant PUBKEY_BYTES = 32;

    uint8 constant ETH_SIGN_RS_BYTES = 32;

    uint8 constant SUCCESS_FLAG_BYTES = 1;

    uint16 constant MAX_AMOUNT_OF_REGISTERED_FEE_TOKENS = 32 - 1;

    uint16 constant USER_TOKENS_START_ID = 32;

    uint16 constant MAX_AMOUNT_OF_REGISTERED_USER_TOKENS = 16352;

    uint16 constant MAX_AMOUNT_OF_REGISTERED_TOKENS = 16384 - 1;

    uint32 constant MAX_ACCOUNT_ID = (2 ** 28) - 1;

    uint256 constant BLOCK_PERIOD = 15 seconds;

    uint256 constant EXPECT_VERIFICATION_IN = 0 hours / BLOCK_PERIOD;

    uint256 constant NOOP_BYTES = 1 * CHUNK_BYTES;
    uint256 constant CREATE_PAIR_BYTES = 3 * CHUNK_BYTES;
    uint256 constant DEPOSIT_BYTES = 4 * CHUNK_BYTES;
    uint256 constant TRANSFER_TO_NEW_BYTES = 4 * CHUNK_BYTES;
    uint256 constant PARTIAL_EXIT_BYTES = 5 * CHUNK_BYTES;
    uint256 constant TRANSFER_BYTES = 2 * CHUNK_BYTES;
    uint256 constant UNISWAP_ADD_LIQ_BYTES = 3 * CHUNK_BYTES;
    uint256 constant UNISWAP_RM_LIQ_BYTES = 3 * CHUNK_BYTES;
    uint256 constant UNISWAP_SWAP_BYTES = 2 * CHUNK_BYTES;

    uint256 constant FULL_EXIT_BYTES = 4 * CHUNK_BYTES;

    uint256 constant ONCHAIN_WITHDRAWAL_BYTES = 1 + 20 + 2 + 16; // (uint8 addToPendingWithdrawalsQueue, address _to, uint16 _tokenId, uint128 _amount)

    uint256 constant CHANGE_PUBKEY_BYTES = 5 * CHUNK_BYTES;

    uint256 constant PRIORITY_EXPIRATION_PERIOD = 3 days;

    uint256 constant PRIORITY_EXPIRATION = PRIORITY_EXPIRATION_PERIOD / BLOCK_PERIOD;

    uint64 constant MAX_PRIORITY_REQUESTS_TO_DELETE_IN_VERIFY = 6;

    uint constant MASS_FULL_EXIT_PERIOD = 3 days;

    uint constant TIME_TO_WITHDRAW_FUNDS_FROM_FULL_EXIT = 2 days;

    uint constant UPGRADE_NOTICE_PERIOD = MASS_FULL_EXIT_PERIOD + PRIORITY_EXPIRATION_PERIOD + TIME_TO_WITHDRAW_FUNDS_FROM_FULL_EXIT;

    uint128 constant DEFAULT_MAX_DEPOSIT_AMOUNT = 2 ** 85;
}pragma solidity ^0.5.0;



contract Governance is Config {


    event NewToken(
        address indexed token,
        uint16 indexed tokenId
    );

    event NewGovernor(
        address newGovernor
    );

    event NewTokenLister(
        address newTokenLister
    );

    event ValidatorStatusUpdate(
        address indexed validatorAddress,
        bool isActive
    );

    address public networkGovernor;

    uint16 public totalFeeTokens;

    uint16 public totalUserTokens;

    mapping(uint16 => address) public tokenAddresses;

    mapping(address => uint16) public tokenIds;

    mapping(address => bool) public validators;

    address public tokenLister;

    constructor() public {
        networkGovernor = msg.sender;
    }

    function initialize(bytes calldata initializationParameters) external {

        require(networkGovernor == address(0), "init0");
        (address _networkGovernor, address _tokenLister) = abi.decode(initializationParameters, (address, address));

        networkGovernor = _networkGovernor;
        tokenLister = _tokenLister;
    }

    function upgrade(bytes calldata upgradeParameters) external {}


    function changeGovernor(address _newGovernor) external {

        requireGovernor(msg.sender);
        require(_newGovernor != address(0), "zero address is passed as _newGovernor");
        if (networkGovernor != _newGovernor) {
            networkGovernor = _newGovernor;
            emit NewGovernor(_newGovernor);
        }
    }

    function changeTokenLister(address _newTokenLister) external {

        requireGovernor(msg.sender);
        require(_newTokenLister != address(0), "zero address is passed as _newTokenLister");
        if (tokenLister != _newTokenLister) {
            tokenLister = _newTokenLister;
            emit NewTokenLister(_newTokenLister);
        }
    }

    function addFeeToken(address _token) external {

        requireGovernor(msg.sender);
        require(tokenIds[_token] == 0, "gan11"); // token exists
        require(totalFeeTokens < MAX_AMOUNT_OF_REGISTERED_FEE_TOKENS, "fee12"); // no free identifiers for tokens
	require(
            _token != address(0), "address cannot be zero"
        );

        totalFeeTokens++;
        uint16 newTokenId = totalFeeTokens; // it is not `totalTokens - 1` because tokenId = 0 is reserved for eth

        tokenAddresses[newTokenId] = _token;
        tokenIds[_token] = newTokenId;
        emit NewToken(_token, newTokenId);
    }

    function addToken(address _token) external {

        requireTokenLister(msg.sender);
        require(tokenIds[_token] == 0, "gan11"); // token exists
        require(totalUserTokens < MAX_AMOUNT_OF_REGISTERED_USER_TOKENS, "gan12"); // no free identifiers for tokens
        require(
            _token != address(0), "address cannot be zero"
        );

        uint16 newTokenId = USER_TOKENS_START_ID + totalUserTokens;
        totalUserTokens++;

        tokenAddresses[newTokenId] = _token;
        tokenIds[_token] = newTokenId;
        emit NewToken(_token, newTokenId);
    }

    function setValidator(address _validator, bool _active) external {

        requireGovernor(msg.sender);
        if (validators[_validator] != _active) {
            validators[_validator] = _active;
            emit ValidatorStatusUpdate(_validator, _active);
        }
    }

    function requireGovernor(address _address) public view {

        require(_address == networkGovernor, "grr11"); // only by governor
    }

    function requireTokenLister(address _address) public view {

        require(_address == networkGovernor || _address == tokenLister, "grr11"); // token lister or governor
    }

    function requireActiveValidator(address _address) external view {

        require(validators[_address], "grr21"); // validator is not active
    }

    function isValidTokenId(uint16 _tokenId) external view returns (bool) {

        return (_tokenId <= totalFeeTokens) || (_tokenId >= USER_TOKENS_START_ID && _tokenId < (USER_TOKENS_START_ID + totalUserTokens  ));
    }

    function validateTokenAddress(address _tokenAddr) external view returns (uint16) {

        uint16 tokenId = tokenIds[_tokenAddr];
        require(tokenId != 0, "gvs11"); // 0 is not a valid token
	require(tokenId <= MAX_AMOUNT_OF_REGISTERED_TOKENS, "gvs12");
        return tokenId;
    }

    function getTokenAddress(uint16 _tokenId) external view returns (address) {

        address tokenAddr = tokenAddresses[_tokenId];
        return tokenAddr;
    }
}pragma solidity >=0.5.0 <0.7.0;

library PairingsBn254 {

    uint256 constant q_mod = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    uint256 constant r_mod = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant bn254_b_coeff = 3;

    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    struct Fr {
        uint256 value;
    }

    function new_fr(uint256 fr) internal pure returns (Fr memory) {

        require(fr < r_mod);
        return Fr({value: fr});
    }

    function copy(Fr memory self) internal pure returns (Fr memory n) {

        n.value = self.value;
    }

    function assign(Fr memory self, Fr memory other) internal pure {

        self.value = other.value;
    }

    function inverse(Fr memory fr) internal view returns (Fr memory) {

        require(fr.value != 0);
        return pow(fr, r_mod-2);
    }

    function add_assign(Fr memory self, Fr memory other) internal pure {

        self.value = addmod(self.value, other.value, r_mod);
    }

    function sub_assign(Fr memory self, Fr memory other) internal pure {

        self.value = addmod(self.value, r_mod - other.value, r_mod);
    }

    function mul_assign(Fr memory self, Fr memory other) internal pure {

        self.value = mulmod(self.value, other.value, r_mod);
    }

    function pow(Fr memory self, uint256 power) internal view returns (Fr memory) {

        uint256[6] memory input = [32, 32, 32, self.value, power, r_mod];
        uint256[1] memory result;
        bool success;
        assembly {
            success := staticcall(gas(), 0x05, input, 0xc0, result, 0x20)
        }
        require(success);
        return Fr({value: result[0]});
    }

    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }

    function P1() internal pure returns (G1Point memory) {

        return G1Point(1, 2);
    }

    function new_g1(uint256 x, uint256 y) internal pure returns (G1Point memory) {

        return G1Point(x, y);
    }

    function new_g1_checked(uint256 x, uint256 y) internal pure returns (G1Point memory) {

        if (x == 0 && y == 0) {
            return G1Point(x, y);
        }

        require(x < q_mod);
        require(y < q_mod);
        uint256 lhs = mulmod(y, y, q_mod); // y^2
        uint256 rhs = mulmod(x, x, q_mod); // x^2
        rhs = mulmod(rhs, x, q_mod); // x^3
        rhs = addmod(rhs, bn254_b_coeff, q_mod); // x^3 + b
        require(lhs == rhs);

        return G1Point(x, y);
    }

    function new_g2(uint256[2] memory x, uint256[2] memory y) internal pure returns (G2Point memory) {

        return G2Point(x, y);
    }

    function copy_g1(G1Point memory self) internal pure returns (G1Point memory result) {

        result.X = self.X;
        result.Y = self.Y;
    }

    function P2() internal pure returns (G2Point memory) {


        return G2Point(
            [0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2,
            0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed],
            [0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b,
            0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa]
        );
    }

    function negate(G1Point memory self) internal pure {

        if (self.Y == 0) {
            require(self.X == 0);
            return;
        }

        self.Y = q_mod - self.Y;
    }

    function point_add(G1Point memory p1, G1Point memory p2)
    internal view returns (G1Point memory r)
    {

        point_add_into_dest(p1, p2, r);
        return r;
    }

    function point_add_assign(G1Point memory p1, G1Point memory p2)
    internal view
    {

        point_add_into_dest(p1, p2, p1);
    }

    function point_add_into_dest(G1Point memory p1, G1Point memory p2, G1Point memory dest)
    internal view
    {

        if (p2.X == 0 && p2.Y == 0) {
            dest.X = p1.X;
            dest.Y = p1.Y;
            return;
        } else if (p1.X == 0 && p1.Y == 0) {
            dest.X = p2.X;
            dest.Y = p2.Y;
            return;
        } else {
            uint256[4] memory input;

            input[0] = p1.X;
            input[1] = p1.Y;
            input[2] = p2.X;
            input[3] = p2.Y;

            bool success = false;
            assembly {
                success := staticcall(gas(), 6, input, 0x80, dest, 0x40)
            }
            require(success);
        }
    }

    function point_sub_assign(G1Point memory p1, G1Point memory p2)
    internal view
    {

        point_sub_into_dest(p1, p2, p1);
    }

    function point_sub_into_dest(G1Point memory p1, G1Point memory p2, G1Point memory dest)
    internal view
    {

        if (p2.X == 0 && p2.Y == 0) {
            dest.X = p1.X;
            dest.Y = p1.Y;
            return;
        } else if (p1.X == 0 && p1.Y == 0) {
            dest.X = p2.X;
            dest.Y = q_mod - p2.Y;
            return;
        } else {
            uint256[4] memory input;

            input[0] = p1.X;
            input[1] = p1.Y;
            input[2] = p2.X;
            input[3] = q_mod - p2.Y;

            bool success = false;
            assembly {
                success := staticcall(gas(), 6, input, 0x80, dest, 0x40)
            }
            require(success);
        }
    }

    function point_mul(G1Point memory p, Fr memory s)
    internal view returns (G1Point memory r)
    {

        point_mul_into_dest(p, s, r);
        return r;
    }

    function point_mul_assign(G1Point memory p, Fr memory s)
    internal view
    {

        point_mul_into_dest(p, s, p);
    }

    function point_mul_into_dest(G1Point memory p, Fr memory s, G1Point memory dest)
    internal view
    {

        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s.value;
        bool success;
        assembly {
            success := staticcall(gas(), 7, input, 0x60, dest, 0x40)
        }
        require(success);
    }

    function pairing(G1Point[] memory p1, G2Point[] memory p2)
    internal view returns (bool)
    {

        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(gas(), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
        }
        require(success);
        return out[0] != 0;
    }

    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2)
    internal view returns (bool)
    {

        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
}

library TranscriptLibrary {

    uint256 constant FR_MASK = 0x1fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    uint32 constant DST_0 = 0;
    uint32 constant DST_1 = 1;
    uint32 constant DST_CHALLENGE = 2;

    struct Transcript {
        bytes32 state_0;
        bytes32 state_1;
        uint32 challenge_counter;
    }

    function new_transcript() internal pure returns (Transcript memory t) {

        t.state_0 = bytes32(0);
        t.state_1 = bytes32(0);
        t.challenge_counter = 0;
    }

    function update_with_u256(Transcript memory self, uint256 value) internal pure {

        bytes32 old_state_0 = self.state_0;
        self.state_0 = keccak256(abi.encodePacked(DST_0, old_state_0, self.state_1, value));
        self.state_1 = keccak256(abi.encodePacked(DST_1, old_state_0, self.state_1, value));
    }

    function update_with_fr(Transcript memory self, PairingsBn254.Fr memory value) internal pure {

        update_with_u256(self, value.value);
    }

    function update_with_g1(Transcript memory self, PairingsBn254.G1Point memory p) internal pure {

        update_with_u256(self, p.X);
        update_with_u256(self, p.Y);
    }

    function get_challenge(Transcript memory self) internal pure returns(PairingsBn254.Fr memory challenge) {

        bytes32 query = keccak256(abi.encodePacked(DST_CHALLENGE, self.state_0, self.state_1, self.challenge_counter));
        self.challenge_counter += 1;
        challenge = PairingsBn254.Fr({value: uint256(query) & FR_MASK});
    }
}pragma solidity >=0.5.0 <0.7.0;
pragma experimental ABIEncoderV2;


contract Plonk4AggVerifierWithAccessToDNext {

    uint256 constant r_mod = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    using PairingsBn254 for PairingsBn254.G1Point;
    using PairingsBn254 for PairingsBn254.G2Point;
    using PairingsBn254 for PairingsBn254.Fr;

    using TranscriptLibrary for TranscriptLibrary.Transcript;


    uint256 constant ZERO = 0;
    uint256 constant ONE = 1;
    uint256 constant TWO = 2;
    uint256 constant THREE = 3;
    uint256 constant FOUR = 4;

    uint256 constant STATE_WIDTH = 4;
    uint256 constant NUM_DIFFERENT_GATES = 2;
    uint256 constant NUM_SETUP_POLYS_FOR_MAIN_GATE = 7;
    uint256 constant NUM_SETUP_POLYS_RANGE_CHECK_GATE = 0;
    uint256 constant ACCESSIBLE_STATE_POLYS_ON_NEXT_STEP = 1;
    uint256 constant NUM_GATE_SELECTORS_OPENED_EXPLICITLY = 1;

    uint256 constant RECURSIVE_CIRCUIT_INPUT_COMMITMENT_MASK = 0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 constant LIMB_WIDTH = 68;

    struct VerificationKey {
        uint256 domain_size;
        uint256 num_inputs;
        PairingsBn254.Fr omega;
        PairingsBn254.G1Point[NUM_SETUP_POLYS_FOR_MAIN_GATE + NUM_SETUP_POLYS_RANGE_CHECK_GATE] gate_setup_commitments;
        PairingsBn254.G1Point[NUM_DIFFERENT_GATES] gate_selector_commitments;
        PairingsBn254.G1Point[STATE_WIDTH] copy_permutation_commitments;
        PairingsBn254.Fr[STATE_WIDTH-1] copy_permutation_non_residues;
        PairingsBn254.G2Point g2_x;
    }

    struct Proof {
        uint256[] input_values;
        PairingsBn254.G1Point[STATE_WIDTH] wire_commitments;
        PairingsBn254.G1Point copy_permutation_grand_product_commitment;
        PairingsBn254.G1Point[STATE_WIDTH] quotient_poly_commitments;
        PairingsBn254.Fr[STATE_WIDTH] wire_values_at_z;
        PairingsBn254.Fr[ACCESSIBLE_STATE_POLYS_ON_NEXT_STEP] wire_values_at_z_omega;
        PairingsBn254.Fr[NUM_GATE_SELECTORS_OPENED_EXPLICITLY] gate_selector_values_at_z;
        PairingsBn254.Fr copy_grand_product_at_z_omega;
        PairingsBn254.Fr quotient_polynomial_at_z;
        PairingsBn254.Fr linearization_polynomial_at_z;
        PairingsBn254.Fr[STATE_WIDTH-1] permutation_polynomials_at_z;

        PairingsBn254.G1Point opening_at_z_proof;
        PairingsBn254.G1Point opening_at_z_omega_proof;
    }

    struct PartialVerifierState {
        PairingsBn254.Fr alpha;
        PairingsBn254.Fr beta;
        PairingsBn254.Fr gamma;
        PairingsBn254.Fr v;
        PairingsBn254.Fr u;
        PairingsBn254.Fr z;
        PairingsBn254.Fr[] cached_lagrange_evals;
    }

    function evaluate_lagrange_poly_out_of_domain(
        uint256 poly_num,
        uint256 domain_size,
        PairingsBn254.Fr memory omega,
        PairingsBn254.Fr memory at
    ) internal view returns (PairingsBn254.Fr memory res) {

        require(poly_num < domain_size);
        PairingsBn254.Fr memory one = PairingsBn254.new_fr(1);
        PairingsBn254.Fr memory omega_power = omega.pow(poly_num);
        res = at.pow(domain_size);
        res.sub_assign(one);
        require(res.value != 0); // Vanishing polynomial can not be zero at point `at`
        res.mul_assign(omega_power);

        PairingsBn254.Fr memory den = PairingsBn254.copy(at);
        den.sub_assign(omega_power);
        den.mul_assign(PairingsBn254.new_fr(domain_size));

        den = den.inverse();

        res.mul_assign(den);
    }

    function evaluate_vanishing(
        uint256 domain_size,
        PairingsBn254.Fr memory at
    ) internal view returns (PairingsBn254.Fr memory res) {

        res = at.pow(domain_size);
        res.sub_assign(PairingsBn254.new_fr(1));
    }

    function verify_at_z(
        PartialVerifierState memory state,
        Proof memory proof,
        VerificationKey memory vk
    ) internal view returns (bool) {

        PairingsBn254.Fr memory lhs = evaluate_vanishing(vk.domain_size, state.z);
        require(lhs.value != 0); // we can not check a polynomial relationship if point `z` is in the domain
        lhs.mul_assign(proof.quotient_polynomial_at_z);

        PairingsBn254.Fr memory quotient_challenge = PairingsBn254.new_fr(1);
        PairingsBn254.Fr memory rhs = PairingsBn254.copy(proof.linearization_polynomial_at_z);

        PairingsBn254.Fr memory tmp = PairingsBn254.new_fr(0);
        PairingsBn254.Fr memory inputs_term = PairingsBn254.new_fr(0);
        for (uint256 i = 0; i < proof.input_values.length; i++) {
            tmp.assign(state.cached_lagrange_evals[i]);
            tmp.mul_assign(PairingsBn254.new_fr(proof.input_values[i]));
            inputs_term.add_assign(tmp);
        }

        inputs_term.mul_assign(proof.gate_selector_values_at_z[0]);
        rhs.add_assign(inputs_term);

        quotient_challenge.mul_assign(state.alpha);
        quotient_challenge.mul_assign(state.alpha);
        quotient_challenge.mul_assign(state.alpha);
        quotient_challenge.mul_assign(state.alpha);
        quotient_challenge.mul_assign(state.alpha);

        PairingsBn254.Fr memory z_part = PairingsBn254.copy(proof.copy_grand_product_at_z_omega);
        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            tmp.assign(proof.permutation_polynomials_at_z[i]);
            tmp.mul_assign(state.beta);
            tmp.add_assign(state.gamma);
            tmp.add_assign(proof.wire_values_at_z[i]);

            z_part.mul_assign(tmp);
        }

        tmp.assign(state.gamma);
        tmp.add_assign(proof.wire_values_at_z[STATE_WIDTH - 1]);

        z_part.mul_assign(tmp);
        z_part.mul_assign(quotient_challenge);

        rhs.sub_assign(z_part);

        quotient_challenge.mul_assign(state.alpha);

        tmp.assign(state.cached_lagrange_evals[0]);
        tmp.mul_assign(quotient_challenge);

        rhs.sub_assign(tmp);

        return lhs.value == rhs.value;
    }

    function add_contribution_from_range_constraint_gates(
        PartialVerifierState memory state,
        Proof memory proof,
        PairingsBn254.Fr memory current_alpha
    ) internal pure returns (PairingsBn254.Fr memory res) {


        PairingsBn254.Fr memory one_fr = PairingsBn254.new_fr(ONE);
        PairingsBn254.Fr memory two_fr = PairingsBn254.new_fr(TWO);
        PairingsBn254.Fr memory three_fr = PairingsBn254.new_fr(THREE);
        PairingsBn254.Fr memory four_fr = PairingsBn254.new_fr(FOUR);

        res = PairingsBn254.new_fr(0);
        PairingsBn254.Fr memory t0 = PairingsBn254.new_fr(0);
        PairingsBn254.Fr memory t1 = PairingsBn254.new_fr(0);
        PairingsBn254.Fr memory t2 = PairingsBn254.new_fr(0);

        for (uint256 i = 0; i < 3; i++) {
            current_alpha.mul_assign(state.alpha);


            t0 = PairingsBn254.copy(proof.wire_values_at_z[3 - i]);
            t0.mul_assign(four_fr);

            t1 = PairingsBn254.copy(proof.wire_values_at_z[2 - i]);
            t1.sub_assign(t0);


            t2 = PairingsBn254.copy(t1);

            t0 = PairingsBn254.copy(t1);
            t0.sub_assign(one_fr);
            t2.mul_assign(t0);

            t0 = PairingsBn254.copy(t1);
            t0.sub_assign(two_fr);
            t2.mul_assign(t0);

            t0 = PairingsBn254.copy(t1);
            t0.sub_assign(three_fr);
            t2.mul_assign(t0);

            t2.mul_assign(current_alpha);

            res.add_assign(t2);
        }


        current_alpha.mul_assign(state.alpha);


        t0 = PairingsBn254.copy(proof.wire_values_at_z[0]);
        t0.mul_assign(four_fr);

        t1 = PairingsBn254.copy(proof.wire_values_at_z_omega[0]);
        t1.sub_assign(t0);


        t2 = PairingsBn254.copy(t1);

        t0 = PairingsBn254.copy(t1);
        t0.sub_assign(one_fr);
        t2.mul_assign(t0);

        t0 = PairingsBn254.copy(t1);
        t0.sub_assign(two_fr);
        t2.mul_assign(t0);

        t0 = PairingsBn254.copy(t1);
        t0.sub_assign(three_fr);
        t2.mul_assign(t0);

        t2.mul_assign(current_alpha);

        res.add_assign(t2);

        return res;
    }

    function reconstruct_linearization_commitment(
        PartialVerifierState memory state,
        Proof memory proof,
        VerificationKey memory vk
    ) internal view returns (PairingsBn254.G1Point memory res) {


        res = PairingsBn254.copy_g1(vk.gate_setup_commitments[STATE_WIDTH + 1]); // index of q_const(x)

        PairingsBn254.G1Point memory tmp_g1 = PairingsBn254.P1();
        PairingsBn254.Fr memory tmp_fr = PairingsBn254.new_fr(0);

        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            tmp_g1 = vk.gate_setup_commitments[i].point_mul(proof.wire_values_at_z[i]);
            res.point_add_assign(tmp_g1);
        }

        tmp_fr.assign(proof.wire_values_at_z[0]);
        tmp_fr.mul_assign(proof.wire_values_at_z[1]);
        tmp_g1 = vk.gate_setup_commitments[STATE_WIDTH].point_mul(tmp_fr);
        res.point_add_assign(tmp_g1);

        tmp_g1 = vk.gate_setup_commitments[STATE_WIDTH+2].point_mul(proof.wire_values_at_z_omega[0]); // index of q_d_next(x)
        res.point_add_assign(tmp_g1);

        res.point_mul_assign(proof.gate_selector_values_at_z[0]); // these is only one explicitly opened selector

        PairingsBn254.Fr memory current_alpha = PairingsBn254.new_fr(ONE);

        tmp_fr = add_contribution_from_range_constraint_gates(state, proof, current_alpha);
        tmp_g1 = vk.gate_selector_commitments[1].point_mul(tmp_fr); // selector commitment for range constraint gate * scalar
        res.point_add_assign(tmp_g1);

        current_alpha.mul_assign(state.alpha); // alpha^5

        PairingsBn254.Fr memory alpha_for_grand_product = PairingsBn254.copy(current_alpha);

        PairingsBn254.Fr memory grand_product_part_at_z = PairingsBn254.copy(state.z);
        grand_product_part_at_z.mul_assign(state.beta);
        grand_product_part_at_z.add_assign(proof.wire_values_at_z[0]);
        grand_product_part_at_z.add_assign(state.gamma);
        for (uint256 i = 0; i < vk.copy_permutation_non_residues.length; i++) {
            tmp_fr.assign(state.z);
            tmp_fr.mul_assign(vk.copy_permutation_non_residues[i]);
            tmp_fr.mul_assign(state.beta);
            tmp_fr.add_assign(state.gamma);
            tmp_fr.add_assign(proof.wire_values_at_z[i+1]);

            grand_product_part_at_z.mul_assign(tmp_fr);
        }

        grand_product_part_at_z.mul_assign(alpha_for_grand_product);

        current_alpha.mul_assign(state.alpha);

        tmp_fr.assign(state.cached_lagrange_evals[0]);
        tmp_fr.mul_assign(current_alpha);

        grand_product_part_at_z.add_assign(tmp_fr);


        PairingsBn254.Fr memory last_permutation_part_at_z = PairingsBn254.new_fr(1);
        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            tmp_fr.assign(state.beta);
            tmp_fr.mul_assign(proof.permutation_polynomials_at_z[i]);
            tmp_fr.add_assign(state.gamma);
            tmp_fr.add_assign(proof.wire_values_at_z[i]);

            last_permutation_part_at_z.mul_assign(tmp_fr);
        }

        last_permutation_part_at_z.mul_assign(state.beta);
        last_permutation_part_at_z.mul_assign(proof.copy_grand_product_at_z_omega);
        last_permutation_part_at_z.mul_assign(alpha_for_grand_product); // we multiply by the power of alpha from the argument

        tmp_g1 = proof.copy_permutation_grand_product_commitment.point_mul(grand_product_part_at_z);
        tmp_g1.point_sub_assign(vk.copy_permutation_commitments[STATE_WIDTH - 1].point_mul(last_permutation_part_at_z));

        res.point_add_assign(tmp_g1);
        res.point_mul_assign(state.v);

    }

    function aggregate_commitments(
        PartialVerifierState memory state,
        Proof memory proof,
        VerificationKey memory vk
    ) internal view returns (PairingsBn254.G1Point[2] memory res) {

        PairingsBn254.G1Point memory d = reconstruct_linearization_commitment(state, proof, vk);

        PairingsBn254.Fr memory z_in_domain_size = state.z.pow(vk.domain_size);

        PairingsBn254.G1Point memory tmp_g1 = PairingsBn254.P1();

        PairingsBn254.Fr memory aggregation_challenge = PairingsBn254.new_fr(1);

        PairingsBn254.G1Point memory commitment_aggregation = PairingsBn254.copy_g1(proof.quotient_poly_commitments[0]);
        PairingsBn254.Fr memory tmp_fr = PairingsBn254.new_fr(1);
        for (uint i = 1; i < proof.quotient_poly_commitments.length; i++) {
            tmp_fr.mul_assign(z_in_domain_size);
            tmp_g1 = proof.quotient_poly_commitments[i].point_mul(tmp_fr);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        aggregation_challenge.mul_assign(state.v);
        commitment_aggregation.point_add_assign(d);

        for (uint i = 0; i < proof.wire_commitments.length; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_g1 = proof.wire_commitments[i].point_mul(aggregation_challenge);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        for (uint i = 0; i < NUM_GATE_SELECTORS_OPENED_EXPLICITLY; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_g1 = vk.gate_selector_commitments[i].point_mul(aggregation_challenge);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        for (uint i = 0; i < vk.copy_permutation_commitments.length - 1; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_g1 = vk.copy_permutation_commitments[i].point_mul(aggregation_challenge);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        aggregation_challenge.mul_assign(state.v);
        tmp_fr.assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        commitment_aggregation.point_add_assign(proof.copy_permutation_grand_product_commitment.point_mul(tmp_fr));

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        tmp_g1 = proof.wire_commitments[STATE_WIDTH - 1].point_mul(tmp_fr);
        commitment_aggregation.point_add_assign(tmp_g1);

        aggregation_challenge = PairingsBn254.new_fr(1);

        PairingsBn254.Fr memory aggregated_value = PairingsBn254.copy(proof.quotient_polynomial_at_z);

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(proof.linearization_polynomial_at_z);
        tmp_fr.mul_assign(aggregation_challenge);
        aggregated_value.add_assign(tmp_fr);

        for (uint i = 0; i < proof.wire_values_at_z.length; i++) {
            aggregation_challenge.mul_assign(state.v);

            tmp_fr.assign(proof.wire_values_at_z[i]);
            tmp_fr.mul_assign(aggregation_challenge);
            aggregated_value.add_assign(tmp_fr);
        }

        for (uint i = 0; i < proof.gate_selector_values_at_z.length; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_fr.assign(proof.gate_selector_values_at_z[i]);
            tmp_fr.mul_assign(aggregation_challenge);
            aggregated_value.add_assign(tmp_fr);
        }

        for (uint i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            aggregation_challenge.mul_assign(state.v);

            tmp_fr.assign(proof.permutation_polynomials_at_z[i]);
            tmp_fr.mul_assign(aggregation_challenge);
            aggregated_value.add_assign(tmp_fr);
        }

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(proof.copy_grand_product_at_z_omega);
        tmp_fr.mul_assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        aggregated_value.add_assign(tmp_fr);

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(proof.wire_values_at_z_omega[0]);
        tmp_fr.mul_assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        aggregated_value.add_assign(tmp_fr);

        commitment_aggregation.point_sub_assign(PairingsBn254.P1().point_mul(aggregated_value));

        PairingsBn254.G1Point memory pair_with_generator = commitment_aggregation;
        pair_with_generator.point_add_assign(proof.opening_at_z_proof.point_mul(state.z));

        tmp_fr.assign(state.z);
        tmp_fr.mul_assign(vk.omega);
        tmp_fr.mul_assign(state.u);
        pair_with_generator.point_add_assign(proof.opening_at_z_omega_proof.point_mul(tmp_fr));

        PairingsBn254.G1Point memory pair_with_x = proof.opening_at_z_omega_proof.point_mul(state.u);
        pair_with_x.point_add_assign(proof.opening_at_z_proof);
        pair_with_x.negate();

        res[0] = pair_with_generator;
        res[1] = pair_with_x;

        return res;
    }

    function verify_initial(
        PartialVerifierState memory state,
        Proof memory proof,
        VerificationKey memory vk
    ) internal view returns (bool) {

        require(proof.input_values.length == vk.num_inputs);
        require(vk.num_inputs == 1);
        TranscriptLibrary.Transcript memory transcript = TranscriptLibrary.new_transcript();
        for (uint256 i = 0; i < vk.num_inputs; i++) {
            transcript.update_with_u256(proof.input_values[i]);
        }

        for (uint256 i = 0; i < proof.wire_commitments.length; i++) {
            transcript.update_with_g1(proof.wire_commitments[i]);
        }

        state.beta = transcript.get_challenge();
        state.gamma = transcript.get_challenge();

        transcript.update_with_g1(proof.copy_permutation_grand_product_commitment);
        state.alpha = transcript.get_challenge();

        for (uint256 i = 0; i < proof.quotient_poly_commitments.length; i++) {
            transcript.update_with_g1(proof.quotient_poly_commitments[i]);
        }

        state.z = transcript.get_challenge();

        state.cached_lagrange_evals = new PairingsBn254.Fr[](1);
        state.cached_lagrange_evals[0] = evaluate_lagrange_poly_out_of_domain(
            0,
            vk.domain_size,
            vk.omega, state.z
        );

        bool valid = verify_at_z(state, proof, vk);

        if (valid == false) {
            return false;
        }

        transcript.update_with_fr(proof.quotient_polynomial_at_z);

        for (uint256 i = 0; i < proof.wire_values_at_z.length; i++) {
            transcript.update_with_fr(proof.wire_values_at_z[i]);
        }

        for (uint256 i = 0; i < proof.wire_values_at_z_omega.length; i++) {
            transcript.update_with_fr(proof.wire_values_at_z_omega[i]);
        }

        transcript.update_with_fr(proof.gate_selector_values_at_z[0]);

        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            transcript.update_with_fr(proof.permutation_polynomials_at_z[i]);
        }

        transcript.update_with_fr(proof.copy_grand_product_at_z_omega);
        transcript.update_with_fr(proof.linearization_polynomial_at_z);

        state.v = transcript.get_challenge();
        transcript.update_with_g1(proof.opening_at_z_proof);
        transcript.update_with_g1(proof.opening_at_z_omega_proof);
        state.u = transcript.get_challenge();

        return true;
    }


    function aggregate_for_verification(Proof memory proof, VerificationKey memory vk) internal view returns (bool valid, PairingsBn254.G1Point[2] memory part) {

        PartialVerifierState memory state;

        valid = verify_initial(state, proof, vk);

        if (valid == false) {
            return (valid, part);
        }

        part = aggregate_commitments(state, proof, vk);

        (valid, part);
    }

    function verify(Proof memory proof, VerificationKey memory vk) internal view returns (bool) {

        (bool valid, PairingsBn254.G1Point[2] memory recursive_proof_part) = aggregate_for_verification(proof, vk);
        if (valid == false) {
            return false;
        }

        valid = PairingsBn254.pairingProd2(recursive_proof_part[0], PairingsBn254.P2(), recursive_proof_part[1], vk.g2_x);

        return valid;
    }

    function verify_recursive(
        Proof memory proof,
        VerificationKey memory vk,
        uint256 recursive_vks_root,
        uint8 max_valid_index,
        uint8[] memory recursive_vks_indexes,
        uint256[] memory individual_vks_inputs,
        uint256[] memory subproofs_limbs
    ) internal view returns (bool) {

        (uint256 recursive_input, PairingsBn254.G1Point[2] memory aggregated_g1s) = reconstruct_recursive_public_input(
            recursive_vks_root, max_valid_index, recursive_vks_indexes,
            individual_vks_inputs, subproofs_limbs
        );

        assert(recursive_input == proof.input_values[0]);

        (bool valid, PairingsBn254.G1Point[2] memory recursive_proof_part) = aggregate_for_verification(proof, vk);
        if (valid == false) {
            return false;
        }

        PairingsBn254.G1Point[2] memory combined = combine_inner_and_outer(aggregated_g1s, recursive_proof_part);

        valid = PairingsBn254.pairingProd2(combined[0], PairingsBn254.P2(), combined[1], vk.g2_x);

        return valid;
    }

    function combine_inner_and_outer(PairingsBn254.G1Point[2] memory inner, PairingsBn254.G1Point[2] memory outer)
        internal
        view
        returns (PairingsBn254.G1Point[2] memory result)
    {

        TranscriptLibrary.Transcript memory transcript = TranscriptLibrary.new_transcript();
        transcript.update_with_g1(inner[0]);
        transcript.update_with_g1(inner[1]);
        transcript.update_with_g1(outer[0]);
        transcript.update_with_g1(outer[1]);
        PairingsBn254.Fr memory challenge = transcript.get_challenge();
        result[0] = PairingsBn254.copy_g1(inner[0]);
        result[1] = PairingsBn254.copy_g1(inner[1]);
        PairingsBn254.G1Point memory tmp = outer[0].point_mul(challenge);
        result[0].point_add_assign(tmp);
        tmp = outer[1].point_mul(challenge);
        result[1].point_add_assign(tmp);

        return result;
    }

    function reconstruct_recursive_public_input(
        uint256 recursive_vks_root,
        uint8 max_valid_index,
        uint8[] memory recursive_vks_indexes,
        uint256[] memory individual_vks_inputs,
        uint256[] memory subproofs_aggregated
    ) internal pure returns (uint256 recursive_input, PairingsBn254.G1Point[2] memory reconstructed_g1s) {

        assert(recursive_vks_indexes.length == individual_vks_inputs.length);
        bytes memory concatenated = abi.encodePacked(recursive_vks_root);
        uint8 index;
        for (uint256 i = 0; i < recursive_vks_indexes.length; i++) {
            index = recursive_vks_indexes[i];
            assert(index <= max_valid_index);
            concatenated = abi.encodePacked(concatenated, index);
        }
        uint256 input;
        for (uint256 i = 0; i < recursive_vks_indexes.length; i++) {
            input = individual_vks_inputs[i];
            assert(input < r_mod);
            concatenated = abi.encodePacked(concatenated, input);
        }

        concatenated = abi.encodePacked(concatenated, subproofs_aggregated);

        bytes32 commitment = sha256(concatenated);
        recursive_input = uint256(commitment) & RECURSIVE_CIRCUIT_INPUT_COMMITMENT_MASK;

        reconstructed_g1s[0] = PairingsBn254.new_g1_checked(
            subproofs_aggregated[0] + (subproofs_aggregated[1] << LIMB_WIDTH) + (subproofs_aggregated[2] << 2*LIMB_WIDTH) + (subproofs_aggregated[3] << 3*LIMB_WIDTH),
            subproofs_aggregated[4] + (subproofs_aggregated[5] << LIMB_WIDTH) + (subproofs_aggregated[6] << 2*LIMB_WIDTH) + (subproofs_aggregated[7] << 3*LIMB_WIDTH)
        );

        reconstructed_g1s[1] = PairingsBn254.new_g1_checked(
            subproofs_aggregated[8] + (subproofs_aggregated[9] << LIMB_WIDTH) + (subproofs_aggregated[10] << 2*LIMB_WIDTH) + (subproofs_aggregated[11] << 3*LIMB_WIDTH),
            subproofs_aggregated[12] + (subproofs_aggregated[13] << LIMB_WIDTH) + (subproofs_aggregated[14] << 2*LIMB_WIDTH) + (subproofs_aggregated[15] << 3*LIMB_WIDTH)
        );

        return (recursive_input, reconstructed_g1s);
    }
}

contract AggVerifierWithDeserialize is Plonk4AggVerifierWithAccessToDNext {

    uint256 constant SERIALIZED_PROOF_LENGTH = 34;

    function deserialize_proof(
        uint256[] memory public_inputs,
        uint256[] memory serialized_proof
    ) internal pure returns(Proof memory proof) {

        require(serialized_proof.length == SERIALIZED_PROOF_LENGTH);
        proof.input_values = new uint256[](public_inputs.length);
        for (uint256 i = 0; i < public_inputs.length; i++) {
            proof.input_values[i] = public_inputs[i];
        }

        uint256 j = 0;
        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            proof.wire_commitments[i] = PairingsBn254.new_g1_checked(
                serialized_proof[j],
                serialized_proof[j+1]
            );

            j += 2;
        }

        proof.copy_permutation_grand_product_commitment = PairingsBn254.new_g1_checked(
            serialized_proof[j],
            serialized_proof[j+1]
        );
        j += 2;

        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            proof.quotient_poly_commitments[i] = PairingsBn254.new_g1_checked(
                serialized_proof[j],
                serialized_proof[j+1]
            );

            j += 2;
        }

        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            proof.wire_values_at_z[i] = PairingsBn254.new_fr(
                serialized_proof[j]
            );

            j += 1;
        }

        for (uint256 i = 0; i < proof.wire_values_at_z_omega.length; i++) {
            proof.wire_values_at_z_omega[i] = PairingsBn254.new_fr(
                serialized_proof[j]
            );

            j += 1;
        }

        for (uint256 i = 0; i < proof.gate_selector_values_at_z.length; i++) {
            proof.gate_selector_values_at_z[i] = PairingsBn254.new_fr(
                serialized_proof[j]
            );

            j += 1;
        }

        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            proof.permutation_polynomials_at_z[i] = PairingsBn254.new_fr(
                serialized_proof[j]
            );

            j += 1;
        }


        proof.copy_grand_product_at_z_omega = PairingsBn254.new_fr(
            serialized_proof[j]
        );

        j += 1;

        proof.quotient_polynomial_at_z = PairingsBn254.new_fr(
            serialized_proof[j]
        );

        j += 1;

        proof.linearization_polynomial_at_z = PairingsBn254.new_fr(
            serialized_proof[j]
        );

        j += 1;

        proof.opening_at_z_proof = PairingsBn254.new_g1_checked(
            serialized_proof[j],
            serialized_proof[j+1]
        );
        j += 2;

        proof.opening_at_z_omega_proof = PairingsBn254.new_g1_checked(
            serialized_proof[j],
            serialized_proof[j+1]
        );
    }

    function verify_serialized_proof(
        uint256[] memory public_inputs,
        uint256[] memory serialized_proof,
        VerificationKey memory vk
    ) public view returns (bool) {

        require(vk.num_inputs == public_inputs.length);

        Proof memory proof = deserialize_proof(public_inputs, serialized_proof);

        bool valid = verify(proof, vk);

        return valid;
    }

    function verify_serialized_proof_with_recursion(
        uint256[] memory public_inputs,
        uint256[] memory serialized_proof,
        uint256 recursive_vks_root,
        uint8 max_valid_index,
        uint8[] memory recursive_vks_indexes,
        uint256[] memory individual_vks_inputs,
        uint256[] memory subproofs_limbs,
        VerificationKey memory vk
    ) public view returns (bool) {

        require(vk.num_inputs == public_inputs.length);

        Proof memory proof = deserialize_proof(public_inputs, serialized_proof);

        bool valid = verify_recursive(proof, vk, recursive_vks_root, max_valid_index, recursive_vks_indexes, individual_vks_inputs, subproofs_limbs);

        return valid;
    }
}pragma solidity >=0.5.0 <0.7.0;


contract KeysWithPlonkAggVerifier is AggVerifierWithDeserialize {


uint256 constant VK_TREE_ROOT = 0x0a3cdc9655e61bf64758c1e8df745723e9b83addd4f0d0f2dd65dc762dc1e9e7;
uint8 constant VK_MAX_INDEX = 5;

function isBlockSizeSupportedInternal(uint32 _size) internal pure returns (bool) {

if (_size == uint32(6)) { return true; }
else if (_size == uint32(12)) { return true; }
else if (_size == uint32(48)) { return true; }
else if (_size == uint32(96)) { return true; }
else if (_size == uint32(204)) { return true; }
else if (_size == uint32(420)) { return true; }
else { return false; }
}

function blockSizeToVkIndex(uint32 _chunks) internal pure returns (uint8) {

if (_chunks == uint32(6)) { return 0; }
else if (_chunks == uint32(12)) { return 1; }
else if (_chunks == uint32(48)) { return 2; }
else if (_chunks == uint32(96)) { return 3; }
else if (_chunks == uint32(204)) { return 4; }
else if (_chunks == uint32(420)) { return 5; }
}


function getVkAggregated(uint32 _blocks) internal pure returns (VerificationKey memory vk) {

if (_blocks == uint32(1)) { return getVkAggregated1(); }
else if (_blocks == uint32(5)) { return getVkAggregated5(); }
}


function getVkAggregated1() internal pure returns(VerificationKey memory vk) {

vk.domain_size = 4194304;
vk.num_inputs = 1;
vk.omega = PairingsBn254.new_fr(0x18c95f1ae6514e11a1b30fd7923947c5ffcec5347f16e91b4dd654168326bede);
vk.gate_setup_commitments[0] = PairingsBn254.new_g1(
0x19fbd6706b4cbde524865701eae0ae6a270608a09c3afdab7760b685c1c6c41b,
0x25082a191f0690c175cc9af1106c6c323b5b5de4e24dc23be1e965e1851bca48
);
vk.gate_setup_commitments[1] = PairingsBn254.new_g1(
0x16c02d9ca95023d1812a58d16407d1ea065073f02c916290e39242303a8a1d8e,
0x230338b422ce8533e27cd50086c28cb160cf05a7ae34ecd5899dbdf449dc7ce0
);
vk.gate_setup_commitments[2] = PairingsBn254.new_g1(
0x1db0d133243750e1ea692050bbf6068a49dc9f6bae1f11960b6ce9e10adae0f5,
0x12a453ed0121ae05de60848b4374d54ae4b7127cb307372e14e8daf5097c5123
);
vk.gate_setup_commitments[3] = PairingsBn254.new_g1(
0x1062ed5e86781fd34f78938e5950c2481a79f132085d2bc7566351ddff9fa3b7,
0x2fd7aac30f645293cc99883ab57d8c99a518d5b4ab40913808045e8653497346
);
vk.gate_setup_commitments[4] = PairingsBn254.new_g1(
0x062755048bb95739f845e8659795813127283bf799443d62fea600ae23e7f263,
0x2af86098beaa241281c78a454c5d1aa6e9eedc818c96cd1e6518e1ac2d26aa39
);
vk.gate_setup_commitments[5] = PairingsBn254.new_g1(
0x0994e25148bbd25be655034f81062d1ebf0a1c2b41e0971434beab1ae8101474,
0x27cc8cfb1fafd13068aeee0e08a272577d89f8aa0fb8507aabbc62f37587b98f
);
vk.gate_setup_commitments[6] = PairingsBn254.new_g1(
0x044edf69ce10cfb6206795f92c3be2b0d26ab9afd3977b789840ee58c7dbe927,
0x2a8aa20c106f8dc7e849bc9698064dcfa9ed0a4050d794a1db0f13b0ee3def37
);

vk.gate_selector_commitments[0] = PairingsBn254.new_g1(
0x136967f1a2696db05583a58dbf8971c5d9d1dc5f5c97e88f3b4822aa52fefa1c,
0x127b41299ea5c840c3b12dbe7b172380f432b7b63ce3b004750d6abb9e7b3b7a
);
vk.gate_selector_commitments[1] = PairingsBn254.new_g1(
0x02fd5638bf3cc2901395ad1124b951e474271770a337147a2167e9797ab9d951,
0x0fcb2e56b077c8461c36911c9252008286d782e96030769bf279024fc81d412a
);

vk.copy_permutation_commitments[0] = PairingsBn254.new_g1(
0x1865c60ecad86f81c6c952445707203c9c7fdace3740232ceb704aefd5bd45b3,
0x2f35e29b39ec8bb054e2cff33c0299dd13f8c78ea24a07622128a7444aba3f26
);
vk.copy_permutation_commitments[1] = PairingsBn254.new_g1(
0x2a86ec9c6c1f903650b5abbf0337be556b03f79aecc4d917e90c7db94518dde6,
0x15b1b6be641336eebd58e7991be2991debbbd780e70c32b49225aa98d10b7016
);
vk.copy_permutation_commitments[2] = PairingsBn254.new_g1(
0x213e42fcec5297b8e01a602684fcd412208d15bdac6b6331a8819d478ba46899,
0x03223485f4e808a3b2496ae1a3c0dfbcbf4391cffc57ee01e8fca114636ead18
);
vk.copy_permutation_commitments[3] = PairingsBn254.new_g1(
0x2e9b02f8cf605ad1a36e99e990a07d435de06716448ad53053c7a7a5341f71e1,
0x2d6fdf0bc8bd89112387b1894d6f24b45dcb122c09c84344b6fc77a619dd1d59
);

vk.copy_permutation_non_residues[0] = PairingsBn254.new_fr(
0x0000000000000000000000000000000000000000000000000000000000000005
);
vk.copy_permutation_non_residues[1] = PairingsBn254.new_fr(
0x0000000000000000000000000000000000000000000000000000000000000007
);
vk.copy_permutation_non_residues[2] = PairingsBn254.new_fr(
0x000000000000000000000000000000000000000000000000000000000000000a
);

vk.g2_x = PairingsBn254.new_g2(
[0x260e01b251f6f1c7e7ff4e580791dee8ea51d87a358e038b4efe30fac09383c1,
0x0118c4d5b837bcc2bc89b5b398b5974e9f5944073b32078b7e231fec938883b0],
[0x04fc6369f7110fe3d25156c1bb9a72859cf2a04641f99ba4ee413c80da6a5fe4,
0x22febda3c0c0632a56475b4214e5615e11e6dd3f96e6cea2854a87d4dacc5e55]
);
}

function getVkAggregated5() internal pure returns(VerificationKey memory vk) {

vk.domain_size = 16777216;
vk.num_inputs = 1;
vk.omega = PairingsBn254.new_fr(0x1951441010b2b95a6e47a6075066a50a036f5ba978c050f2821df86636c0facb);
vk.gate_setup_commitments[0] = PairingsBn254.new_g1(
0x023cfc69ef1b002da66120fce352ede75893edd8cd8196403a54e1eceb82cd43,
0x2baf3bd673e46be9df0d43ca30f834671543c22db422f450b2efd8c931e9b34e
);
vk.gate_setup_commitments[1] = PairingsBn254.new_g1(
0x23783fe0e5c3f83c02c864e25fe766afb727134c9a77ae6b9694efb7b46f31ab,
0x1903d01005e447d061c16323a1d604d8fbd4b5cc9b64945a71f1234d280c4d3a
);
vk.gate_setup_commitments[2] = PairingsBn254.new_g1(
0x2897df6c6fa993661b2b0b0cf52460278e33533de71b3c0f7ed7c1f20af238c6,
0x042344afee0aed5505e59bce4ebbe942a91268a8af6b77ea95f603b5b726e8cb
);
vk.gate_setup_commitments[3] = PairingsBn254.new_g1(
0x0fceed33e78426afc38d8a68c0d93413d2bbaa492b087125271d33d52bdb07b8,
0x0057e4f63be36edb56e91da931f3d0ba72d1862d4b7751c59b92b6ae9f1fcc11
);
vk.gate_setup_commitments[4] = PairingsBn254.new_g1(
0x14230a35f172cd77a2147cecc20b2a13148363cbab78709489a29d08001e26fb,
0x04f1040477d77896475080b5abb8091cda2cce4917ee0ba5dd62d0ab1be379b4
);
vk.gate_setup_commitments[5] = PairingsBn254.new_g1(
0x20d1a079ad80a8abb7fd8ba669dddbbe23231360a5f0ba679b6536b6bf980649,
0x120c5a845903bd6de4105eb8cef90e6dff2c3888ada16c90e1efb393778d6a4d
);
vk.gate_setup_commitments[6] = PairingsBn254.new_g1(
0x1af6b9e362e458a96b8bbbf8f8ce2bdbd650fb68478360c408a2acf1633c1ce1,
0x27033728b767b44c659e7896a6fcc956af97566a5a1135f87a2e510976a62d41
);

vk.gate_selector_commitments[0] = PairingsBn254.new_g1(
0x0dbfb3c5f5131eb6f01e12b1a6333b0ad22cc8292b666e46e9bd4d80802cccdf,
0x2d058711c42fd2fd2eef33fb327d111a27fe2063b46e1bb54b32d02e9676e546
);
vk.gate_selector_commitments[1] = PairingsBn254.new_g1(
0x0c8c7352a84dd3f32412b1a96acd94548a292411fd7479d8609ca9bd872f1e36,
0x0874203fd8012d6976698cc2df47bca14bc04879368ade6412a2109c1e71e5e8
);

vk.copy_permutation_commitments[0] = PairingsBn254.new_g1(
0x1b17bb7c319b1cf15461f4f0b69d98e15222320cb2d22f4e3a5f5e0e9e51f4bd,
0x0cf5bc338235ded905926006027aa2aab277bc32a098cd5b5353f5545cbd2825
);
vk.copy_permutation_commitments[1] = PairingsBn254.new_g1(
0x0794d3cfbc2fdd756b162571a40e40b8f31e705c77063f30a4e9155dbc00e0ef,
0x1f821232ab8826ea5bf53fe9866c74e88a218c8d163afcaa395eda4db57b7a23
);
vk.copy_permutation_commitments[2] = PairingsBn254.new_g1(
0x224d93783aa6856621a9bbec495f4830c94994e266b240db9d652dbb394a283b,
0x161bcec99f3bc449d655c0ca59874dafe1194138eec91af34392b09a83338ca1
);
vk.copy_permutation_commitments[3] = PairingsBn254.new_g1(
0x1fa27e2916b2c11d39c74c0e61063190da31c102d2b7da5c0a61ec8c5e82f132,
0x0a815ee76cd8aa600e6f66463b25a0ee57814bfdf06c65a91ddc70cede41caae
);

vk.copy_permutation_non_residues[0] = PairingsBn254.new_fr(
0x0000000000000000000000000000000000000000000000000000000000000005
);
vk.copy_permutation_non_residues[1] = PairingsBn254.new_fr(
0x0000000000000000000000000000000000000000000000000000000000000007
);
vk.copy_permutation_non_residues[2] = PairingsBn254.new_fr(
0x000000000000000000000000000000000000000000000000000000000000000a
);

vk.g2_x = PairingsBn254.new_g2(
[0x260e01b251f6f1c7e7ff4e580791dee8ea51d87a358e038b4efe30fac09383c1,
0x0118c4d5b837bcc2bc89b5b398b5974e9f5944073b32078b7e231fec938883b0],
[0x04fc6369f7110fe3d25156c1bb9a72859cf2a04641f99ba4ee413c80da6a5fe4,
0x22febda3c0c0632a56475b4214e5615e11e6dd3f96e6cea2854a87d4dacc5e55]
);
}


}pragma solidity ^0.5.0;


contract Verifier is KeysWithPlonkAggVerifier {


    bool constant DUMMY_VERIFIER = false;

    function initialize(bytes calldata) external {

    }

    function upgrade(bytes calldata upgradeParameters) external {}


    function isBlockSizeSupported(uint32 _size) public pure returns (bool) {

        if (DUMMY_VERIFIER) {
            return true;
        } else {
            return isBlockSizeSupportedInternal(_size);
        }
    }

    function verifyMultiblockProof(
        uint256[] calldata _recursiveInput,
        uint256[] calldata _proof,
        uint32[] calldata _block_sizes,
        uint256[] calldata _individual_vks_inputs,
        uint256[] calldata _subproofs_limbs
    ) external view returns (bool) {

        if (DUMMY_VERIFIER) {
            uint oldGasValue = gasleft();
            uint tmp;
            while (gasleft() + 500000 > oldGasValue) {
                tmp += 1;
            }
            return true;
        }
        uint8[] memory vkIndexes = new uint8[](_block_sizes.length);
        for (uint32 i = 0; i < _block_sizes.length; i++) {
            vkIndexes[i] = blockSizeToVkIndex(_block_sizes[i]);
        }
        VerificationKey memory vk = getVkAggregated(uint32(_block_sizes.length));
        return  verify_serialized_proof_with_recursion(_recursiveInput, _proof, VK_TREE_ROOT, VK_MAX_INDEX, vkIndexes, _individual_vks_inputs, _subproofs_limbs, vk);
    }
}pragma solidity >=0.5.0 <0.7.0;


contract Plonk4SingleVerifierWithAccessToDNext {

    using PairingsBn254 for PairingsBn254.G1Point;
    using PairingsBn254 for PairingsBn254.G2Point;
    using PairingsBn254 for PairingsBn254.Fr;

    using TranscriptLibrary for TranscriptLibrary.Transcript;

    uint256 constant STATE_WIDTH = 4;
    uint256 constant ACCESSIBLE_STATE_POLYS_ON_NEXT_STEP = 1;

    struct VerificationKey {
        uint256 domain_size;
        uint256 num_inputs;
        PairingsBn254.Fr omega;
        PairingsBn254.G1Point[STATE_WIDTH+2] selector_commitments; // STATE_WIDTH for witness + multiplication + constant
        PairingsBn254.G1Point[ACCESSIBLE_STATE_POLYS_ON_NEXT_STEP] next_step_selector_commitments;
        PairingsBn254.G1Point[STATE_WIDTH] permutation_commitments;
        PairingsBn254.Fr[STATE_WIDTH-1] permutation_non_residues;
        PairingsBn254.G2Point g2_x;
    }

    struct Proof {
        uint256[] input_values;
        PairingsBn254.G1Point[STATE_WIDTH] wire_commitments;
        PairingsBn254.G1Point grand_product_commitment;
        PairingsBn254.G1Point[STATE_WIDTH] quotient_poly_commitments;
        PairingsBn254.Fr[STATE_WIDTH] wire_values_at_z;
        PairingsBn254.Fr[ACCESSIBLE_STATE_POLYS_ON_NEXT_STEP] wire_values_at_z_omega;
        PairingsBn254.Fr grand_product_at_z_omega;
        PairingsBn254.Fr quotient_polynomial_at_z;
        PairingsBn254.Fr linearization_polynomial_at_z;
        PairingsBn254.Fr[STATE_WIDTH-1] permutation_polynomials_at_z;

        PairingsBn254.G1Point opening_at_z_proof;
        PairingsBn254.G1Point opening_at_z_omega_proof;
    }

    struct PartialVerifierState {
        PairingsBn254.Fr alpha;
        PairingsBn254.Fr beta;
        PairingsBn254.Fr gamma;
        PairingsBn254.Fr v;
        PairingsBn254.Fr u;
        PairingsBn254.Fr z;
        PairingsBn254.Fr[] cached_lagrange_evals;
    }

    function evaluate_lagrange_poly_out_of_domain(
        uint256 poly_num,
        uint256 domain_size,
        PairingsBn254.Fr memory omega,
        PairingsBn254.Fr memory at
    ) internal view returns (PairingsBn254.Fr memory res) {

        require(poly_num < domain_size);
        PairingsBn254.Fr memory one = PairingsBn254.new_fr(1);
        PairingsBn254.Fr memory omega_power = omega.pow(poly_num);
        res = at.pow(domain_size);
        res.sub_assign(one);
        require(res.value != 0); // Vanishing polynomial can not be zero at point `at`
        res.mul_assign(omega_power);

        PairingsBn254.Fr memory den = PairingsBn254.copy(at);
        den.sub_assign(omega_power);
        den.mul_assign(PairingsBn254.new_fr(domain_size));

        den = den.inverse();

        res.mul_assign(den);
    }

    function evaluate_vanishing(
        uint256 domain_size,
        PairingsBn254.Fr memory at
    ) internal view returns (PairingsBn254.Fr memory res) {

        res = at.pow(domain_size);
        res.sub_assign(PairingsBn254.new_fr(1));
    }

    function verify_at_z(
        PartialVerifierState memory state,
        Proof memory proof,
        VerificationKey memory vk
    ) internal view returns (bool) {

        PairingsBn254.Fr memory lhs = evaluate_vanishing(vk.domain_size, state.z);
        require(lhs.value != 0); // we can not check a polynomial relationship if point `z` is in the domain
        lhs.mul_assign(proof.quotient_polynomial_at_z);

        PairingsBn254.Fr memory quotient_challenge = PairingsBn254.new_fr(1);
        PairingsBn254.Fr memory rhs = PairingsBn254.copy(proof.linearization_polynomial_at_z);

        PairingsBn254.Fr memory tmp = PairingsBn254.new_fr(0);
        for (uint256 i = 0; i < proof.input_values.length; i++) {
            tmp.assign(state.cached_lagrange_evals[i]);
            tmp.mul_assign(PairingsBn254.new_fr(proof.input_values[i]));
            rhs.add_assign(tmp);
        }

        quotient_challenge.mul_assign(state.alpha);

        PairingsBn254.Fr memory z_part = PairingsBn254.copy(proof.grand_product_at_z_omega);
        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            tmp.assign(proof.permutation_polynomials_at_z[i]);
            tmp.mul_assign(state.beta);
            tmp.add_assign(state.gamma);
            tmp.add_assign(proof.wire_values_at_z[i]);

            z_part.mul_assign(tmp);
        }

        tmp.assign(state.gamma);
        tmp.add_assign(proof.wire_values_at_z[STATE_WIDTH - 1]);

        z_part.mul_assign(tmp);
        z_part.mul_assign(quotient_challenge);

        rhs.sub_assign(z_part);

        quotient_challenge.mul_assign(state.alpha);

        tmp.assign(state.cached_lagrange_evals[0]);
        tmp.mul_assign(quotient_challenge);

        rhs.sub_assign(tmp);

        return lhs.value == rhs.value;
    }

    function reconstruct_d(
        PartialVerifierState memory state,
        Proof memory proof,
        VerificationKey memory vk
    ) internal view returns (PairingsBn254.G1Point memory res) {

        uint256 power_for_z_omega_opening = 1 + 1 + STATE_WIDTH + STATE_WIDTH - 1;
        res = PairingsBn254.copy_g1(vk.selector_commitments[STATE_WIDTH + 1]);

        PairingsBn254.G1Point memory tmp_g1 = PairingsBn254.P1();
        PairingsBn254.Fr memory tmp_fr = PairingsBn254.new_fr(0);

        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            tmp_g1 = vk.selector_commitments[i].point_mul(proof.wire_values_at_z[i]);
            res.point_add_assign(tmp_g1);
        }

        tmp_fr.assign(proof.wire_values_at_z[0]);
        tmp_fr.mul_assign(proof.wire_values_at_z[1]);
        tmp_g1 = vk.selector_commitments[STATE_WIDTH].point_mul(tmp_fr);
        res.point_add_assign(tmp_g1);

        tmp_g1 = vk.next_step_selector_commitments[0].point_mul(proof.wire_values_at_z_omega[0]);
        res.point_add_assign(tmp_g1);

        PairingsBn254.Fr memory grand_product_part_at_z = PairingsBn254.copy(state.z);
        grand_product_part_at_z.mul_assign(state.beta);
        grand_product_part_at_z.add_assign(proof.wire_values_at_z[0]);
        grand_product_part_at_z.add_assign(state.gamma);
        for (uint256 i = 0; i < vk.permutation_non_residues.length; i++) {
            tmp_fr.assign(state.z);
            tmp_fr.mul_assign(vk.permutation_non_residues[i]);
            tmp_fr.mul_assign(state.beta);
            tmp_fr.add_assign(state.gamma);
            tmp_fr.add_assign(proof.wire_values_at_z[i+1]);

            grand_product_part_at_z.mul_assign(tmp_fr);
        }

        grand_product_part_at_z.mul_assign(state.alpha);

        tmp_fr.assign(state.cached_lagrange_evals[0]);
        tmp_fr.mul_assign(state.alpha);
        tmp_fr.mul_assign(state.alpha);

        grand_product_part_at_z.add_assign(tmp_fr);

        PairingsBn254.Fr memory grand_product_part_at_z_omega = state.v.pow(power_for_z_omega_opening);
        grand_product_part_at_z_omega.mul_assign(state.u);

        PairingsBn254.Fr memory last_permutation_part_at_z = PairingsBn254.new_fr(1);
        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            tmp_fr.assign(state.beta);
            tmp_fr.mul_assign(proof.permutation_polynomials_at_z[i]);
            tmp_fr.add_assign(state.gamma);
            tmp_fr.add_assign(proof.wire_values_at_z[i]);

            last_permutation_part_at_z.mul_assign(tmp_fr);
        }

        last_permutation_part_at_z.mul_assign(state.beta);
        last_permutation_part_at_z.mul_assign(proof.grand_product_at_z_omega);
        last_permutation_part_at_z.mul_assign(state.alpha);

        tmp_g1 = proof.grand_product_commitment.point_mul(grand_product_part_at_z);
        tmp_g1.point_sub_assign(vk.permutation_commitments[STATE_WIDTH - 1].point_mul(last_permutation_part_at_z));

        res.point_add_assign(tmp_g1);
        res.point_mul_assign(state.v);

        res.point_add_assign(proof.grand_product_commitment.point_mul(grand_product_part_at_z_omega));
    }

    function verify_commitments(
        PartialVerifierState memory state,
        Proof memory proof,
        VerificationKey memory vk
    ) internal view returns (bool) {

        PairingsBn254.G1Point memory d = reconstruct_d(state, proof, vk);

        PairingsBn254.Fr memory z_in_domain_size = state.z.pow(vk.domain_size);

        PairingsBn254.G1Point memory tmp_g1 = PairingsBn254.P1();

        PairingsBn254.Fr memory aggregation_challenge = PairingsBn254.new_fr(1);

        PairingsBn254.G1Point memory commitment_aggregation = PairingsBn254.copy_g1(proof.quotient_poly_commitments[0]);
        PairingsBn254.Fr memory tmp_fr = PairingsBn254.new_fr(1);
        for (uint i = 1; i < proof.quotient_poly_commitments.length; i++) {
            tmp_fr.mul_assign(z_in_domain_size);
            tmp_g1 = proof.quotient_poly_commitments[i].point_mul(tmp_fr);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        aggregation_challenge.mul_assign(state.v);
        commitment_aggregation.point_add_assign(d);

        for (uint i = 0; i < proof.wire_commitments.length; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_g1 = proof.wire_commitments[i].point_mul(aggregation_challenge);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        for (uint i = 0; i < vk.permutation_commitments.length - 1; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_g1 = vk.permutation_commitments[i].point_mul(aggregation_challenge);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        aggregation_challenge.mul_assign(state.v);

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        tmp_g1 = proof.wire_commitments[STATE_WIDTH - 1].point_mul(tmp_fr);
        commitment_aggregation.point_add_assign(tmp_g1);

        aggregation_challenge = PairingsBn254.new_fr(1);

        PairingsBn254.Fr memory aggregated_value = PairingsBn254.copy(proof.quotient_polynomial_at_z);

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(proof.linearization_polynomial_at_z);
        tmp_fr.mul_assign(aggregation_challenge);
        aggregated_value.add_assign(tmp_fr);

        for (uint i = 0; i < proof.wire_values_at_z.length; i++) {
            aggregation_challenge.mul_assign(state.v);

            tmp_fr.assign(proof.wire_values_at_z[i]);
            tmp_fr.mul_assign(aggregation_challenge);
            aggregated_value.add_assign(tmp_fr);
        }

        for (uint i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            aggregation_challenge.mul_assign(state.v);

            tmp_fr.assign(proof.permutation_polynomials_at_z[i]);
            tmp_fr.mul_assign(aggregation_challenge);
            aggregated_value.add_assign(tmp_fr);
        }

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(proof.grand_product_at_z_omega);
        tmp_fr.mul_assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        aggregated_value.add_assign(tmp_fr);

        aggregation_challenge.mul_assign(state.v);

        tmp_fr.assign(proof.wire_values_at_z_omega[0]);
        tmp_fr.mul_assign(aggregation_challenge);
        tmp_fr.mul_assign(state.u);
        aggregated_value.add_assign(tmp_fr);

        commitment_aggregation.point_sub_assign(PairingsBn254.P1().point_mul(aggregated_value));

        PairingsBn254.G1Point memory pair_with_generator = commitment_aggregation;
        pair_with_generator.point_add_assign(proof.opening_at_z_proof.point_mul(state.z));

        tmp_fr.assign(state.z);
        tmp_fr.mul_assign(vk.omega);
        tmp_fr.mul_assign(state.u);
        pair_with_generator.point_add_assign(proof.opening_at_z_omega_proof.point_mul(tmp_fr));

        PairingsBn254.G1Point memory pair_with_x = proof.opening_at_z_omega_proof.point_mul(state.u);
        pair_with_x.point_add_assign(proof.opening_at_z_proof);
        pair_with_x.negate();

        return PairingsBn254.pairingProd2(pair_with_generator, PairingsBn254.P2(), pair_with_x, vk.g2_x);
    }

    function verify_initial(
        PartialVerifierState memory state,
        Proof memory proof,
        VerificationKey memory vk
    ) internal view returns (bool) {

        require(proof.input_values.length == vk.num_inputs);
        require(vk.num_inputs == 1);
        TranscriptLibrary.Transcript memory transcript = TranscriptLibrary.new_transcript();
        for (uint256 i = 0; i < vk.num_inputs; i++) {
            transcript.update_with_u256(proof.input_values[i]);
        }

        for (uint256 i = 0; i < proof.wire_commitments.length; i++) {
            transcript.update_with_g1(proof.wire_commitments[i]);
        }

        state.beta = transcript.get_challenge();
        state.gamma = transcript.get_challenge();

        transcript.update_with_g1(proof.grand_product_commitment);
        state.alpha = transcript.get_challenge();

        for (uint256 i = 0; i < proof.quotient_poly_commitments.length; i++) {
            transcript.update_with_g1(proof.quotient_poly_commitments[i]);
        }

        state.z = transcript.get_challenge();

        state.cached_lagrange_evals = new PairingsBn254.Fr[](1);
        state.cached_lagrange_evals[0] = evaluate_lagrange_poly_out_of_domain(
            0,
            vk.domain_size,
            vk.omega, state.z
        );

        bool valid = verify_at_z(state, proof, vk);

        if (valid == false) {
            return false;
        }

        for (uint256 i = 0; i < proof.wire_values_at_z.length; i++) {
            transcript.update_with_fr(proof.wire_values_at_z[i]);
        }

        for (uint256 i = 0; i < proof.wire_values_at_z_omega.length; i++) {
            transcript.update_with_fr(proof.wire_values_at_z_omega[i]);
        }

        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            transcript.update_with_fr(proof.permutation_polynomials_at_z[i]);
        }

        transcript.update_with_fr(proof.quotient_polynomial_at_z);
        transcript.update_with_fr(proof.linearization_polynomial_at_z);
        transcript.update_with_fr(proof.grand_product_at_z_omega);

        state.v = transcript.get_challenge();
        transcript.update_with_g1(proof.opening_at_z_proof);
        transcript.update_with_g1(proof.opening_at_z_omega_proof);
        state.u = transcript.get_challenge();

        return true;
    }


    function verify(Proof memory proof, VerificationKey memory vk) internal view returns (bool) {

        PartialVerifierState memory state;

        bool valid = verify_initial(state, proof, vk);

        if (valid == false) {
            return false;
        }

        valid = verify_commitments(state, proof, vk);

        return valid;
    }
}

contract SingleVerifierWithDeserialize is Plonk4SingleVerifierWithAccessToDNext {

    uint256 constant SERIALIZED_PROOF_LENGTH = 33;

    function deserialize_proof(
        uint256[] memory public_inputs,
        uint256[] memory serialized_proof
    ) internal pure returns(Proof memory proof) {

        require(serialized_proof.length == SERIALIZED_PROOF_LENGTH);
        proof.input_values = new uint256[](public_inputs.length);
        for (uint256 i = 0; i < public_inputs.length; i++) {
            proof.input_values[i] = public_inputs[i];
        }

        uint256 j = 0;
        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            proof.wire_commitments[i] = PairingsBn254.new_g1_checked(
                serialized_proof[j],
                serialized_proof[j+1]
            );

            j += 2;
        }

        proof.grand_product_commitment = PairingsBn254.new_g1_checked(
            serialized_proof[j],
            serialized_proof[j+1]
        );
        j += 2;

        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            proof.quotient_poly_commitments[i] = PairingsBn254.new_g1_checked(
                serialized_proof[j],
                serialized_proof[j+1]
            );

            j += 2;
        }

        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            proof.wire_values_at_z[i] = PairingsBn254.new_fr(
                serialized_proof[j]
            );

            j += 1;
        }

        for (uint256 i = 0; i < proof.wire_values_at_z_omega.length; i++) {
            proof.wire_values_at_z_omega[i] = PairingsBn254.new_fr(
                serialized_proof[j]
            );

            j += 1;
        }

        proof.grand_product_at_z_omega = PairingsBn254.new_fr(
            serialized_proof[j]
        );

        j += 1;

        proof.quotient_polynomial_at_z = PairingsBn254.new_fr(
            serialized_proof[j]
        );

        j += 1;

        proof.linearization_polynomial_at_z = PairingsBn254.new_fr(
            serialized_proof[j]
        );

        j += 1;

        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            proof.permutation_polynomials_at_z[i] = PairingsBn254.new_fr(
                serialized_proof[j]
            );

            j += 1;
        }

        proof.opening_at_z_proof = PairingsBn254.new_g1_checked(
            serialized_proof[j],
            serialized_proof[j+1]
        );
        j += 2;

        proof.opening_at_z_omega_proof = PairingsBn254.new_g1_checked(
            serialized_proof[j],
            serialized_proof[j+1]
        );
    }
}pragma solidity >=0.5.0 <0.7.0;


contract KeysWithPlonkSingleVerifier is SingleVerifierWithDeserialize {


    function isBlockSizeSupportedInternal(uint32 _size) internal pure returns (bool) {

        if (_size == uint32(6)) { return true; }
        else if (_size == uint32(12)) { return true; }
        else if (_size == uint32(48)) { return true; }
        else if (_size == uint32(96)) { return true; }
        else if (_size == uint32(204)) { return true; }
        else if (_size == uint32(420)) { return true; }
        else { return false; }
    }

    
    function getVkExit() internal pure returns(VerificationKey memory vk) {

        vk.domain_size = 262144;
        vk.num_inputs = 1;
        vk.omega = PairingsBn254.new_fr(0x0f60c8fe0414cb9379b2d39267945f6bd60d06a05216231b26a9fcf88ddbfebe);
        vk.selector_commitments[0] = PairingsBn254.new_g1(
            0x1abc710835cdc78389d61b670b0e8d26416a63c9bd3d6ed435103ebbb8a8665e,
            0x138c6678230ed19f90b947d0a9027bd9fc458bbd1d2b8371fa72e28470a97b9c
        );
        vk.selector_commitments[1] = PairingsBn254.new_g1(
            0x28d81ac76e1ddf630b4bf8e4a789cf9c4470c5e5cc010a24849b20ab595b8b22,
            0x251ca3cf0829b261d3be8d6cbd25aa97d9af716819c29f6319d806f075e79655
        );
        vk.selector_commitments[2] = PairingsBn254.new_g1(
            0x1504c8c227833a1152f3312d258412c334ac7ae213e21427ff63028729bc28fa,
            0x0f0942f3fede795cbe624fb9ddf9be90ba546609383f2246c3c9b92af7aab5fd
        );
        vk.selector_commitments[3] = PairingsBn254.new_g1(
            0x1f14a5bb19ea2897ac6b9fbdbd2b4e371be09f8e90a47ae26602d399c9bcd311,
            0x029c6ea094247da75d9a66cea627c3c77d48b898003125d4f8e785435dc2cf23
        );
        vk.selector_commitments[4] = PairingsBn254.new_g1(
            0x102cdd83e2d70638a70d700622b662607f8a2d92f5c36053a4ddb4b600d75bcf,
            0x09ef3679579d761507ef69eaf49c978b271f0e4500468da1ebd7197f3ff5d6ac
        );
        vk.selector_commitments[5] = PairingsBn254.new_g1(
            0x2c2bd1d2fa3d4b3915d0fe465469e11ee563e79751da71c6082fcd0ca4e41cd5,
            0x0304f16147a8af177dcc703370931d5161bda9dcf3e091787b9a54377ab54c32
        );

        vk.next_step_selector_commitments[0] = PairingsBn254.new_g1(
            0x14420680f992f4bc8d8012e2d8b14a774cf9114adf1e41b3c02c20cc1648398e,
            0x237d3d5cdee5e3d7d58f4eb336ecd7aa5ec88d89205861b410420f6b9f6b26a1
        );

         vk.permutation_commitments[0] = PairingsBn254.new_g1(
            0x221045ae5578ccb35e0a198d83c0fb191da8cdc98423fc46e580f1762682c73e,
            0x15b7f3d74fcd258fdd2ae6001693a7c615e654d613a506d213aaf0ad314e338d
        );
        vk.permutation_commitments[1] = PairingsBn254.new_g1(
            0x03e47981b459b3be258a6353593898babec571ccf3e0362d53a67f078f04830a,
            0x0809556ab6eb28403bb5a749fcdbd8656940add7685ff5473dc3a9ad940034df
        );
        vk.permutation_commitments[2] = PairingsBn254.new_g1(
            0x2c02322c53d7e6a6474b15c7db738419e3f4d1263e9f98ebb56c24906f555ef9,
            0x2322c69f51366551665b584d797e0fdadb16fe31b1e7ae2f532847a75b3aeaab
        );
        vk.permutation_commitments[3] = PairingsBn254.new_g1(
            0x2147e39b49c2bef4168884c0ac9e38bb4dc65b41ba21953f7ded2daab7fe1534,
            0x071f3548c9ca2c6a8d10b11d553263ebe0afaf1f663b927ef970bd6c3974cb68
        );

        vk.permutation_non_residues[0] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000005
        );
        vk.permutation_non_residues[1] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000007
        );
        vk.permutation_non_residues[2] = PairingsBn254.new_fr(
            0x000000000000000000000000000000000000000000000000000000000000000a
        );

        vk.g2_x = PairingsBn254.new_g2(
            [0x260e01b251f6f1c7e7ff4e580791dee8ea51d87a358e038b4efe30fac09383c1,
             0x0118c4d5b837bcc2bc89b5b398b5974e9f5944073b32078b7e231fec938883b0],
            [0x04fc6369f7110fe3d25156c1bb9a72859cf2a04641f99ba4ee413c80da6a5fe4,
             0x22febda3c0c0632a56475b4214e5615e11e6dd3f96e6cea2854a87d4dacc5e55]
        );
    }
    
    function getVkLpExit() internal pure returns(VerificationKey memory vk) {

        vk.domain_size = 524288;
        vk.num_inputs = 1;
        vk.omega = PairingsBn254.new_fr(0x0cf1526aaafac6bacbb67d11a4077806b123f767e4b0883d14cc0193568fc082);
        vk.selector_commitments[0] = PairingsBn254.new_g1(
            0x067d967299b3d380f2e461409fbacb82d9af8c85b62de082a423f344fb0b9d38,
            0x2440bd569ac24e9525b29e433334ee98d72cb8eb19af65250ee0099fb470d873
        );
        vk.selector_commitments[1] = PairingsBn254.new_g1(
            0x086a9ed0f6175964593e516a8c1fc8bbd0a9c8afb724ebbce08a7772bd7b8837,
            0x0aca3794dc6a2f0cab69dfed529d31deb7a5e9e6c339e3c07d8d88df0f7abd6b
        );
        vk.selector_commitments[2] = PairingsBn254.new_g1(
            0x00b6bfec3aceb55618e6caf637c978c3fe2344568c64515022fcfa00e490eb97,
            0x0f890fe6b9cb943fb4887df1529cdae99e2494eabf675f89905215eb51c29c6e
        );
        vk.selector_commitments[3] = PairingsBn254.new_g1(
            0x0968470be841bcbfbcccc10dd0d8b63a871cdb3289c214fc59f38c88ab15146a,
            0x1a9b4d034050fa0b119bb64ba0e967fd09f224c6fd9cd8b54cd6f081085dfb98
        );
        vk.selector_commitments[4] = PairingsBn254.new_g1(
            0x080dbe10de0cacf12db303a86049c7a4d42f068a9def099e0cb874008f210b1b,
            0x02f17638d3410ab573e33a4e6c6cf0c918bea2aa4f1025ca5ee13d7a950c4058
        );
        vk.selector_commitments[5] = PairingsBn254.new_g1(
            0x267043dbe00520bd8bbf55a96b51fde6b3b64219eca9e2fd8309693db0cf0392,
            0x08dbbfa17faad841228af22a03fab7ec20f765036a2acae62f543f61e55b6e8c
        );

        vk.next_step_selector_commitments[0] = PairingsBn254.new_g1(
            0x215141775449677e3dbe25ff6c5e5d99336a29d952a61d5ec87618346e78df30,
            0x29502caeb6afaf2acd13766d52fac2907efb7d11c66cd8beb93c8321d380b215
        );

         vk.permutation_commitments[0] = PairingsBn254.new_g1(
            0x150790105b9f5455ae6f91daa6b03c5793fb7bcfcd9d5d37d3b643b77535b10a,
            0x2b644a9736282f80fae8d35f00cbddf2bba3560c54f3d036ec1c8014c147a506
        );
        vk.permutation_commitments[1] = PairingsBn254.new_g1(
            0x1b898666ded092a449935de7d707ad8d65809c2baccdd7dd7cfdaf2fb27e1262,
            0x2a24c241dcad93b7bdf1cce2427c9c54f731a7d50c27a825e2af3dabb66dc81f
        );
        vk.permutation_commitments[2] = PairingsBn254.new_g1(
            0x049892634dbbfa0c364523827cd7e604b70a7e24a4cb111cb8fccb7c05b04d7f,
            0x1e5d8d7c0bf92d822dcf339a52c326a35cadf010b888b8f26e155a68c7e23dc9
        );
        vk.permutation_commitments[3] = PairingsBn254.new_g1(
            0x04f90846cb1598aa05164a78d171ea918154414652d07d3f5cab84a26e6aa158,
            0x0975ba8858f136bb8b1b043daf8dfed33709f72ba37e01e5de62c81f3928a13c
        );

        vk.permutation_non_residues[0] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000005
        );
        vk.permutation_non_residues[1] = PairingsBn254.new_fr(
            0x0000000000000000000000000000000000000000000000000000000000000007
        );
        vk.permutation_non_residues[2] = PairingsBn254.new_fr(
            0x000000000000000000000000000000000000000000000000000000000000000a
        );

        vk.g2_x = PairingsBn254.new_g2(
            [0x260e01b251f6f1c7e7ff4e580791dee8ea51d87a358e038b4efe30fac09383c1,
             0x0118c4d5b837bcc2bc89b5b398b5974e9f5944073b32078b7e231fec938883b0],
            [0x04fc6369f7110fe3d25156c1bb9a72859cf2a04641f99ba4ee413c80da6a5fe4,
             0x22febda3c0c0632a56475b4214e5615e11e6dd3f96e6cea2854a87d4dacc5e55]
        );
    }
    

}pragma solidity ^0.5.0;


contract VerifierExit is KeysWithPlonkSingleVerifier {


    function initialize(bytes calldata) external {

    }

    function upgrade(bytes calldata upgradeParameters) external {}


    function verifyExitProof(
        bytes32 _rootHash,
        uint32 _accountId,
        address _owner,
        uint16 _tokenId,
        uint128 _amount,
        uint256[] calldata _proof
    ) external view returns (bool) {

        bytes32 commitment = sha256(abi.encodePacked(_rootHash, _accountId, _owner, _tokenId, _amount));

        uint256[] memory inputs = new uint256[](1);
        uint256 mask = (~uint256(0)) >> 3;
        inputs[0] = uint256(commitment) & mask;
        Proof memory proof = deserialize_proof(inputs, _proof);
        VerificationKey memory vk = getVkExit();
        require(vk.num_inputs == inputs.length);
        return verify(proof, vk);
    }

    function concatBytes(bytes memory param1, bytes memory param2) public pure returns (bytes memory) {

        bytes memory merged = new bytes(param1.length + param2.length);

        uint k = 0;
        for (uint i = 0; i < param1.length; i++) {
            merged[k] = param1[i];
            k++;
        }

        for (uint i = 0; i < param2.length; i++) {
            merged[k] = param2[i];
            k++;
        }
        return merged;
    }

    function verifyLpExitProof(
        bytes calldata _account_data,
        bytes calldata _pair_data0,
        bytes calldata _pair_data1,
        uint256[] calldata _proof
    ) external view returns (bool) {

        bytes memory _data1 = concatBytes(_account_data, _pair_data0);
        bytes memory _data2 = concatBytes(_data1, _pair_data1);
        bytes32 commitment = sha256(_data2);

        uint256[] memory inputs = new uint256[](1);
        uint256 mask = (~uint256(0)) >> 3;
        inputs[0] = uint256(commitment) & mask;
        Proof memory proof = deserialize_proof(inputs, _proof);
        VerificationKey memory vk = getVkLpExit();
        require(vk.num_inputs == inputs.length);
        return verify(proof, vk);
    }
}pragma solidity ^0.5.0;



library Operations {



    enum OpType {
        Noop,
        Deposit,
        TransferToNew,
        PartialExit,
        _CloseAccount, // used for correct op id offset
        Transfer,
        FullExit,
        ChangePubKey,
        CreatePair,
        AddLiquidity,
        RemoveLiquidity,
        Swap
    }


    uint8 constant TOKEN_BYTES = 2;

    uint8 constant PUBKEY_BYTES = 32;

    uint8 constant NONCE_BYTES = 4;

    uint8 constant PUBKEY_HASH_BYTES = 20;

    uint8 constant ADDRESS_BYTES = 20;

    uint8 constant FEE_BYTES = 2;

    uint8 constant ACCOUNT_ID_BYTES = 4;

    uint8 constant AMOUNT_BYTES = 16;

    uint8 constant SIGNATURE_BYTES = 64;

    struct Deposit {
        uint32 accountId;
        uint16 tokenId;
        uint128 amount;
        address owner;
    }

    uint public constant PACKED_DEPOSIT_PUBDATA_BYTES = 
        ACCOUNT_ID_BYTES + TOKEN_BYTES + AMOUNT_BYTES + ADDRESS_BYTES;

    function readDepositPubdata(bytes memory _data) internal pure
        returns (Deposit memory parsed)
    {

        uint offset = 0;
        (offset, parsed.accountId) = Bytes.readUInt32(_data, offset); // accountId
        (offset, parsed.tokenId) = Bytes.readUInt16(_data, offset);   // tokenId
        (offset, parsed.amount) = Bytes.readUInt128(_data, offset);   // amount
        (offset, parsed.owner) = Bytes.readAddress(_data, offset);    // owner

        require(offset == PACKED_DEPOSIT_PUBDATA_BYTES, "rdp10"); // reading invalid deposit pubdata size
    }

    function writeDepositPubdata(Deposit memory op) internal pure returns (bytes memory buf) {

        buf = abi.encodePacked(
            bytes4(0),   // accountId (ignored) (update when ACCOUNT_ID_BYTES is changed)
            op.tokenId,  // tokenId
            op.amount,   // amount
            op.owner     // owner
        );
    }

    function depositPubdataMatch(bytes memory _lhs, bytes memory _rhs) internal pure returns (bool) {

        bytes memory lhs_trimmed = Bytes.slice(_lhs, ACCOUNT_ID_BYTES, PACKED_DEPOSIT_PUBDATA_BYTES - ACCOUNT_ID_BYTES);
        bytes memory rhs_trimmed = Bytes.slice(_rhs, ACCOUNT_ID_BYTES, PACKED_DEPOSIT_PUBDATA_BYTES - ACCOUNT_ID_BYTES);
        return keccak256(lhs_trimmed) == keccak256(rhs_trimmed);
    }


    struct FullExit {
        uint32 accountId;
        address owner;
        uint16 tokenId;
        uint128 amount;
    }

    uint public constant PACKED_FULL_EXIT_PUBDATA_BYTES = 
        ACCOUNT_ID_BYTES + ADDRESS_BYTES + TOKEN_BYTES + AMOUNT_BYTES;

    function readFullExitPubdata(bytes memory _data) internal pure
        returns (FullExit memory parsed)
    {

        uint offset = 0;
        (offset, parsed.accountId) = Bytes.readUInt32(_data, offset);      // accountId
        (offset, parsed.owner) = Bytes.readAddress(_data, offset);         // owner
        (offset, parsed.tokenId) = Bytes.readUInt16(_data, offset);        // tokenId
        (offset, parsed.amount) = Bytes.readUInt128(_data, offset);        // amount

        require(offset == PACKED_FULL_EXIT_PUBDATA_BYTES, "rfp10"); // reading invalid full exit pubdata size
    }

    function writeFullExitPubdata(FullExit memory op) internal pure returns (bytes memory buf) {

        buf = abi.encodePacked(
            op.accountId,  // accountId
            op.owner,      // owner
            op.tokenId,    // tokenId
            op.amount      // amount
        );
    }

    function fullExitPubdataMatch(bytes memory _lhs, bytes memory _rhs) internal pure returns (bool) {

        uint lhs = Bytes.trim(_lhs, PACKED_FULL_EXIT_PUBDATA_BYTES - AMOUNT_BYTES);
        uint rhs = Bytes.trim(_rhs, PACKED_FULL_EXIT_PUBDATA_BYTES - AMOUNT_BYTES);
        return lhs == rhs;
    }

    
    struct PartialExit {
        uint16 tokenId;
        uint128 amount;
        address owner;
    }

    function readPartialExitPubdata(bytes memory _data, uint _offset) internal pure
        returns (PartialExit memory parsed)
    {

        uint offset = _offset + ACCOUNT_ID_BYTES;                   // accountId (ignored)
        (offset, parsed.owner) = Bytes.readAddress(_data, offset);  // owner
        (offset, parsed.tokenId) = Bytes.readUInt16(_data, offset); // tokenId
        (offset, parsed.amount) = Bytes.readUInt128(_data, offset); // amount
    }

    function writePartialExitPubdata(PartialExit memory op) internal pure returns (bytes memory buf) {

        buf = abi.encodePacked(
            bytes4(0),  // accountId (ignored) (update when ACCOUNT_ID_BYTES is changed)
            op.owner,    // owner
            op.tokenId, // tokenId
            op.amount  // amount
        );
    }


    struct ChangePubKey {
        uint32 accountId;
        bytes20 pubKeyHash;
        address owner;
        uint32 nonce;
    }

    function readChangePubKeyPubdata(bytes memory _data, uint _offset) internal pure
        returns (ChangePubKey memory parsed)
    {

        uint offset = _offset;
        (offset, parsed.accountId) = Bytes.readUInt32(_data, offset);                // accountId
        (offset, parsed.pubKeyHash) = Bytes.readBytes20(_data, offset);              // pubKeyHash
        (offset, parsed.owner) = Bytes.readAddress(_data, offset);                   // owner
        (offset, parsed.nonce) = Bytes.readUInt32(_data, offset);                    // nonce
    }


    function readWithdrawalData(bytes memory _data, uint _offset) internal pure
        returns (bool _addToPendingWithdrawalsQueue, address _to, uint16 _tokenId, uint128 _amount)
    {

        uint offset = _offset;
        (offset, _addToPendingWithdrawalsQueue) = Bytes.readBool(_data, offset);
        (offset, _to) = Bytes.readAddress(_data, offset);
        (offset, _tokenId) = Bytes.readUInt16(_data, offset);
        (offset, _amount) = Bytes.readUInt128(_data, offset);
    }

    
    struct CreatePair {
        uint32 accountId;
        uint16 tokenA;
        uint16 tokenB;
        uint16 tokenPair;
        address pair;
    }

    uint public constant PACKED_CREATE_PAIR_PUBDATA_BYTES =
        ACCOUNT_ID_BYTES + TOKEN_BYTES + TOKEN_BYTES + TOKEN_BYTES + ADDRESS_BYTES;

    function readCreatePairPubdata(bytes memory _data) internal pure
        returns (CreatePair memory parsed)
    {

        uint offset = 0;
        (offset, parsed.accountId) = Bytes.readUInt32(_data, offset); // accountId
        (offset, parsed.tokenA) = Bytes.readUInt16(_data, offset); // tokenAId
        (offset, parsed.tokenB) = Bytes.readUInt16(_data, offset); // tokenBId
        (offset, parsed.tokenPair) = Bytes.readUInt16(_data, offset); // pairId
        (offset, parsed.pair) = Bytes.readAddress(_data, offset); // pairId
        require(offset == PACKED_CREATE_PAIR_PUBDATA_BYTES, "rcp10"); // reading invalid create pair pubdata size
    }

    function writeCreatePairPubdata(CreatePair memory op) internal pure returns (bytes memory buf) {

        buf = abi.encodePacked(
            bytes4(0),      // accountId (ignored) (update when ACCOUNT_ID_BYTES is changed)
            op.tokenA,      // tokenAId
            op.tokenB,      // tokenBId
            op.tokenPair,   // pairId
            op.pair         // pair account
        );
    }

    function createPairPubdataMatch(bytes memory _lhs, bytes memory _rhs) internal pure returns (bool) {

        bytes memory lhs_trimmed = Bytes.slice(_lhs, ACCOUNT_ID_BYTES, PACKED_CREATE_PAIR_PUBDATA_BYTES - ACCOUNT_ID_BYTES);
        bytes memory rhs_trimmed = Bytes.slice(_rhs, ACCOUNT_ID_BYTES, PACKED_CREATE_PAIR_PUBDATA_BYTES - ACCOUNT_ID_BYTES);
        return keccak256(lhs_trimmed) == keccak256(rhs_trimmed);
    }


}pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);

}pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);


    function initialize(address, address) external;


    function mint(address to, uint amount) external;

    function burn(address to, uint amount) external;

}pragma solidity >=0.5.0;

interface IUniswapV2ERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}pragma solidity =0.5.16;


library UniswapSafeMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}pragma solidity =0.5.16;


contract UniswapV2ERC20 is IUniswapV2ERC20 {

    using UniswapSafeMath for uint;

    string public constant name = 'ZKSWAP V2';
    string public constant symbol = 'ZKS-V2';
    uint8 public constant decimals = 18;
    uint  public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor() public {
        uint chainId;
        assembly {
            chainId := chainid
        }
    }

    function _mint(address to, uint value) internal {

        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {

        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {

        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }
}pragma solidity =0.5.16;


library Math {

    function min(uint x, uint y) internal pure returns (uint z) {

        z = x < y ? x : y;
    }

    function sqrt(uint y) internal pure returns (uint z) {

        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}pragma solidity =0.5.16;



library UQ112x112 {

    uint224 constant Q112 = 2**112;

    function encode(uint112 y) internal pure returns (uint224 z) {

        z = uint224(y) * Q112; // never overflows
    }

    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {

        z = x / uint224(y);
    }
}pragma solidity >=0.5.0;

interface IUNISWAPERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}pragma solidity >=0.5.0;

interface IUniswapV2Callee {

    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;

}pragma solidity =0.5.16;


contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20 {

    using UniswapSafeMath  for uint;
    using UQ112x112 for uint224;

    address public factory;
    address public token0;
    address public token1;

    uint private unlocked = 1;
    modifier lock() {

        require(unlocked == 1, 'UniswapV2: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor() public {
        factory = msg.sender;
    }

    function initialize(address _token0, address _token1) external {

        require(msg.sender == factory, 'UniswapV2: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    function mint(address to, uint amount) external lock {

        require(msg.sender == factory, 'mt1');
        _mint(to, amount);
    }

    function burn(address to, uint amount) external lock {

        require(msg.sender == factory, 'br1');
        _burn(to, amount);
    }
}pragma solidity =0.5.16;


contract UniswapV2Factory is IUniswapV2Factory {

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;
    address public zkSyncAddress;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor() public {
    }

    function initialize(bytes calldata data) external {


    }

    function setZkSyncAddress(address _zksyncAddress) external {

        require(zkSyncAddress == address(0), "szsa1");
        zkSyncAddress = _zksyncAddress;
    }

    function upgrade(bytes calldata upgradeParameters) external {}


    function allPairsLength() external view returns (uint) {

        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {

        require(msg.sender == zkSyncAddress, 'fcp1');
        require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        require(zkSyncAddress != address(0), 'wzk');
        IUniswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function mint(address pair, address to, uint amount) external {

        require(msg.sender == zkSyncAddress, 'fmt1');
        IUniswapV2Pair(pair).mint(to, amount);
    }

    function burn(address pair, address to, uint amount) external {

        require(msg.sender == zkSyncAddress, 'fbr1');
        IUniswapV2Pair(pair).burn(to, amount);
    }
}pragma solidity ^0.5.0;




contract Storage {


    bool public upgradePreparationActive;

    uint public upgradePreparationActivationTime;

    Verifier internal verifier;
    VerifierExit internal verifierExit;

    Governance internal governance;
    
    UniswapV2Factory internal pairmanager;

    struct BalanceToWithdraw {
        uint128 balanceToWithdraw;
        uint8 gasReserveValue; // gives user opportunity to fill storage slot with nonzero value
    }

    mapping(bytes22 => BalanceToWithdraw) public balancesToWithdraw;

    struct PendingWithdrawal {
        address to;
        uint16 tokenId;
    }
    
    mapping(uint32 => PendingWithdrawal) public pendingWithdrawals;
    uint32 public firstPendingWithdrawalIndex;
    uint32 public numberOfPendingWithdrawals;

    uint32 public totalBlocksVerified;

    uint32 public totalBlocksChecked;

    uint32 public totalBlocksCommitted;

    struct Block {
        uint32 committedAtBlock;
        uint64 priorityOperations;
        uint32 chunks;
        bytes32 withdrawalsDataHash; /// can be restricted to 16 bytes to reduce number of required storage slots
        bytes32 commitment;
        bytes32 stateRoot;
    }

    mapping(uint32 => Block) public blocks;

    struct OnchainOperation {
        Operations.OpType opType;
        bytes pubData;
    }

    mapping(uint32 => mapping(uint16 => bool)) public exited;
    mapping(uint32 => mapping(uint32 => bool)) public swap_exited;

    bool public exodusMode;

    mapping(address => mapping(uint32 => bytes32)) public authFacts;

    struct PriorityOperation {
        Operations.OpType opType;
        bytes pubData;
        uint256 expirationBlock;
    }

    mapping(uint64 => PriorityOperation) public priorityRequests;

    uint64 public firstPriorityRequestId;

    uint64 public totalOpenPriorityRequests;

    uint64 public totalCommittedPriorityRequests;

    function packAddressAndTokenId(address _address, uint16 _tokenId) internal pure returns (bytes22) {

        return bytes22((uint176(_address) | (uint176(_tokenId) << 160)));
    }

    function getBalanceToWithdraw(address _address, uint16 _tokenId) public view returns (uint128) {

        return balancesToWithdraw[packAddressAndTokenId(_address, _tokenId)].balanceToWithdraw;
    }

    address public zkSyncCommitBlockAddress;
    address public zkSyncExitAddress;

    uint128 public maxDepositAmount;

    uint256 public withdrawGasLimit;
}pragma solidity ^0.5.0;


interface Upgradeable {


    function upgradeTarget(address newTarget, bytes calldata newTargetInitializationParameters) external;


}pragma solidity ^0.5.0;



interface Events {


    event BlockCommit(uint32 indexed blockNumber);

    event BlockVerification(uint32 indexed blockNumber);

    event MultiblockVerification(uint32 indexed blockNumberFrom, uint32 indexed blockNumberTo);

    event OnchainWithdrawal(
        address indexed owner,
        uint16 indexed tokenId,
        uint128 amount
    );

    event OnchainDeposit(
        address indexed sender,
        uint16 indexed tokenId,
        uint128 amount,
        address indexed owner
    );

    event OnchainCreatePair(
        uint16 indexed tokenAId,
        uint16 indexed tokenBId,
        uint16 indexed pairId,
        address pair
    );

    event FactAuth(
        address indexed sender,
        uint32 nonce,
        bytes fact
    );

    event BlocksRevert(
        uint32 indexed totalBlocksVerified,
        uint32 indexed totalBlocksCommitted
    );

    event ExodusMode();

    event NewPriorityRequest(
        address sender,
        uint64 serialId,
        Operations.OpType opType,
        bytes pubData,
        bytes userData,
        uint256 expirationBlock
    );

    event DepositCommit(
        uint32 indexed zkSyncBlockId,
        uint32 indexed accountId,
        address owner,
        uint16 indexed tokenId,
        uint128 amount
    );

    event FullExitCommit(
        uint32 indexed zkSyncBlockId,
        uint32 indexed accountId,
        address owner,
        uint16 indexed tokenId,
        uint128 amount
    );

    event PendingWithdrawalsAdd(
        uint32 queueStartIndex,
        uint32 queueEndIndex
    );

    event PendingWithdrawalsComplete(
        uint32 queueStartIndex,
        uint32 queueEndIndex
    );

    event CreatePairCommit(
        uint32 indexed zkSyncBlockId,
        uint32 indexed accountId,
        uint16 tokenAId,
        uint16 tokenBId,
        uint16 indexed tokenPairId,
        address pair
    );
}

interface UpgradeEvents {


    event NewUpgradable(
        uint indexed versionId,
        address indexed upgradeable
    );

    event NoticePeriodStart(
        uint indexed versionId,
        address[] newTargets,
        uint noticePeriod // notice period (in seconds)
    );

    event UpgradeCancel(
        uint indexed versionId
    );

    event PreparationStart(
        uint indexed versionId
    );

    event UpgradeComplete(
        uint indexed versionId,
        address[] newTargets
    );

}pragma solidity ^0.5.0;

contract PairTokenManager {

    uint16 constant MAX_AMOUNT_OF_PAIR_TOKENS = 49152;

    uint16 constant PAIR_TOKEN_START_ID = 16384;

    uint16 public totalPairTokens;

    mapping(uint16 => address) public tokenAddresses;

    mapping(address => uint16) public tokenIds;
    
    event NewToken(
        address indexed token,
        uint16 indexed tokenId
    );

    function addPairToken(address _token) internal {

        require(tokenIds[_token] == 0, "pan1"); // token exists
        require(totalPairTokens < MAX_AMOUNT_OF_PAIR_TOKENS, "pan2"); // no free identifiers for tokens

        uint16 newPairTokenId = PAIR_TOKEN_START_ID + totalPairTokens;
        totalPairTokens++;

        tokenAddresses[newPairTokenId] = _token;
        tokenIds[_token] = newPairTokenId;
        emit NewToken(_token, newPairTokenId);
    }

    function validatePairTokenAddress(address _tokenAddr) public view returns (uint16) {

        uint16 tokenId = tokenIds[_tokenAddr];
        require(tokenId != 0, "pms3");
        require(tokenId <= (PAIR_TOKEN_START_ID -1 + MAX_AMOUNT_OF_PAIR_TOKENS), "pms4");
        return tokenId;
    }
}pragma solidity ^0.5.0;





contract ZkSyncCommitBlock is PairTokenManager, Storage, Config, Events, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeMathUInt128 for uint128;

    bytes32 public constant EMPTY_STRING_KECCAK = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    function commitBlock(
        uint32 _blockNumber,
        uint32 _feeAccount,
        bytes32[] calldata _newBlockInfo,
        bytes calldata _publicData,
        bytes calldata _ethWitness,
        uint32[] calldata _ethWitnessSizes
    ) external nonReentrant {

        requireActive();
        require(_blockNumber == totalBlocksCommitted + 1, "fck11"); // only commit next block
        governance.requireActiveValidator(msg.sender);
        require(_newBlockInfo.length == 1, "fck13"); // This version of the contract expects only account tree root hash

        bytes memory publicData = _publicData;

        uint64 prevTotalCommittedPriorityRequests = totalCommittedPriorityRequests;

        bytes32 withdrawalsDataHash = collectOnchainOps(_blockNumber, publicData, _ethWitness, _ethWitnessSizes);

        uint64 nPriorityRequestProcessed = totalCommittedPriorityRequests - prevTotalCommittedPriorityRequests;

        createCommittedBlock(_blockNumber, _feeAccount, _newBlockInfo[0], publicData, withdrawalsDataHash, nPriorityRequestProcessed);
        totalBlocksCommitted++;

        emit BlockCommit(_blockNumber);
    }

    function commitMultiBlock(
        uint32[] calldata _blockInfo,
        bytes32[] calldata _newRootAndCommitment,
        bytes[] calldata _publicDatas,
        uint32[] calldata _ethWitnessSizes
    ) external nonReentrant {

        requireActive();
        uint32 _blockNumber = _blockInfo[0];
        uint32 _blockCount = _blockInfo[1];
        require(_blockNumber == totalBlocksCommitted + 1, "fck11"); // only commit next block
        governance.requireActiveValidator(msg.sender);
        for (uint32 i = 0; i < _blockCount; i++) {
            uint32 chunks = _blockInfo[3+i];
            bytes memory publicData = _publicDatas[2*i];
            bytes memory ethWitness = _publicDatas[2*i+1];
            uint32 blockNumber = _blockNumber+i;
            bytes32 newRoot = _newRootAndCommitment[2*i];
            bytes32 newCommitment = _newRootAndCommitment[2*i+1];
            uint32[] memory ethWitnessSizes = _ethWitnessSizes;
	    uint32 ethWitnessSizesOffset = _ethWitnessSizes[i];

            uint64 prevTotalCommittedPriorityRequests = totalCommittedPriorityRequests;

            bytes32 withdrawalsDataHash = collectOnchainMultiOps([blockNumber, ethWitnessSizesOffset+_blockCount], publicData, ethWitness, ethWitnessSizes);

            uint64 nPriorityRequestProcessed = totalCommittedPriorityRequests - prevTotalCommittedPriorityRequests;

            createCommittedMultiBlock(blockNumber, chunks, newRoot, newCommitment, publicData, withdrawalsDataHash, nPriorityRequestProcessed);
            totalBlocksCommitted++;

            emit BlockCommit(blockNumber);
        }
    }

    function verifyBlock(uint32 _blockNumber, uint256[] calldata _proof, bytes calldata _withdrawalsData)
        external nonReentrant
    {

        revert("fb1"); // verify one block is not supported
    }

    function createMultiblockCommitment(uint32 _blockNumberFrom, uint32 _blockNumberTo)
    internal returns (uint32[] memory blockSizes, uint256[] memory inputs) {

        uint32 numberOfBlocks = _blockNumberTo - _blockNumberFrom + 1;
        blockSizes = new uint32[](numberOfBlocks);
        inputs = new uint256[](numberOfBlocks);
        for (uint32 i = 0; i < numberOfBlocks; i++) {
            blockSizes[i] = blocks[_blockNumberFrom + i].chunks;

            bytes32 blockCommitment = blocks[_blockNumberFrom + i].commitment;
            uint256 mask = (~uint256(0)) >> 3;
            inputs[i] = uint256(blockCommitment) & mask;
        }
    }

    function verifyBlocks(
        uint32 _blockNumberFrom, uint32 _blockNumberTo,
        uint256[] calldata _recursiveInput, uint256[] calldata _proof, uint256[] calldata _subProofLimbs
    )
    external nonReentrant
    {

        requireActive();
        require(_blockNumberFrom <= _blockNumberTo, "vbs11"); // vbs11 - must verify non empty sequence of blocks
        require(_blockNumberFrom == totalBlocksVerified + 1, "mbfvk11"); // only verify from next block
        governance.requireActiveValidator(msg.sender);

        (uint32[] memory aggregatedBlockSizes,  uint256[] memory aggregatedInputs) = createMultiblockCommitment(_blockNumberFrom, _blockNumberTo);

        require(verifier.verifyMultiblockProof(_recursiveInput, _proof, aggregatedBlockSizes, aggregatedInputs, _subProofLimbs), "mbfvk13");

        for (uint32 _blockNumber = _blockNumberFrom; _blockNumber <= _blockNumberTo; _blockNumber++){
            deleteRequests(
                blocks[_blockNumber].priorityOperations
            );
        }

        totalBlocksVerified = _blockNumberTo;

        emit MultiblockVerification(_blockNumberFrom, _blockNumberTo);
    }

    function checkWithdrawals(uint32 _blockNumberFrom, uint32 _blockNumberTo, bytes[] calldata _withdrawalsData) external nonReentrant {

        require(_blockNumberFrom <= _blockNumberTo, "cw1");
	require(_blockNumberFrom == totalBlocksChecked + 1, "cw2");
	require(_blockNumberTo <= totalBlocksVerified, "cw3");

        for (uint32 _blockNumber = _blockNumberFrom; _blockNumber <= _blockNumberTo; _blockNumber++){
            processOnchainWithdrawals(_withdrawalsData[_blockNumber - _blockNumberFrom], blocks[_blockNumber].withdrawalsDataHash);
        }

	totalBlocksChecked = _blockNumberTo;
    }

    function revertBlocks(uint32 _maxBlocksToRevert) external nonReentrant {

        require(isBlockCommitmentExpired(), "rbs11"); // trying to revert non-expired blocks.
        governance.requireActiveValidator(msg.sender);

        uint32 blocksCommited = totalBlocksCommitted;
        uint32 blocksToRevert = Utils.minU32(_maxBlocksToRevert, blocksCommited - totalBlocksVerified);
        uint64 revertedPriorityRequests = 0;

        for (uint32 i = totalBlocksCommitted - blocksToRevert + 1; i <= blocksCommited; i++) {
            Block memory revertedBlock = blocks[i];
            require(revertedBlock.committedAtBlock > 0, "frk11"); // block not found

            revertedPriorityRequests += revertedBlock.priorityOperations;

            delete blocks[i];
        }

        blocksCommited -= blocksToRevert;
        totalBlocksCommitted -= blocksToRevert;
        totalCommittedPriorityRequests -= revertedPriorityRequests;

        emit BlocksRevert(totalBlocksVerified, blocksCommited);
    }

    function triggerExodusIfNeeded() external returns (bool) {

        bool trigger = block.number >= priorityRequests[firstPriorityRequestId].expirationBlock &&
        priorityRequests[firstPriorityRequestId].expirationBlock != 0;
        if (trigger) {
            if (!exodusMode) {
                exodusMode = true;
                emit ExodusMode();
            }
            return true;
        } else {
            return false;
        }
    }

    function setAuthPubkeyHash(bytes calldata _pubkey_hash, uint32 _nonce) external nonReentrant {

        require(_pubkey_hash.length == PUBKEY_HASH_BYTES, "ahf10"); // PubKeyHash should be 20 bytes.
        require(authFacts[msg.sender][_nonce] == bytes32(0), "ahf11"); // auth fact for nonce should be empty

        authFacts[msg.sender][_nonce] = keccak256(_pubkey_hash);

        emit FactAuth(msg.sender, _nonce, _pubkey_hash);
    }

    function createCommittedBlock(
        uint32 _blockNumber,
        uint32 _feeAccount,
        bytes32 _newRoot,
        bytes memory _publicData,
        bytes32 _withdrawalDataHash,
        uint64 _nCommittedPriorityRequests
    ) internal {

        require(_publicData.length % CHUNK_BYTES == 0, "cbb10"); // Public data size is not multiple of CHUNK_BYTES

        uint32 blockChunks = uint32(_publicData.length / CHUNK_BYTES);
        require(verifier.isBlockSizeSupported(blockChunks), "ccb11");

        bytes32 commitment = createBlockCommitment(
            _blockNumber,
            _feeAccount,
            blocks[_blockNumber - 1].stateRoot,
            _newRoot,
            _publicData
        );

        blocks[_blockNumber] = Block(
            uint32(block.number), // committed at
            _nCommittedPriorityRequests, // number of priority onchain ops in block
            blockChunks,
            _withdrawalDataHash, // hash of onchain withdrawals data (will be used during checking block withdrawal data in verifyBlock function)
            commitment, // blocks' commitment
            _newRoot // new root
        );
    }

    function createCommittedMultiBlock(
        uint32 _blockNumber,
	uint32 _chunks,
        bytes32 _newRoot,
        bytes32 _newCommitment,
        bytes memory _publicData,
        bytes32 _withdrawalDataHash,
        uint64 _nCommittedPriorityRequests
    ) internal {

        require(verifier.isBlockSizeSupported(_chunks), "ccb11");

        blocks[_blockNumber] = Block(
            uint32(block.number), // committed at
            _nCommittedPriorityRequests, // number of priority onchain ops in block
            _chunks,
            _withdrawalDataHash, // hash of onchain withdrawals data (will be used during checking block withdrawal data in verifyBlock function)
            _newCommitment, // blocks' commitment
            _newRoot // new root
        );
    }

    function emitDepositCommitEvent(uint32 _blockNumber, Operations.Deposit memory depositData) internal {

        emit DepositCommit(_blockNumber, depositData.accountId, depositData.owner, depositData.tokenId, depositData.amount);
    }

    function emitFullExitCommitEvent(uint32 _blockNumber, Operations.FullExit memory fullExitData) internal {

        emit FullExitCommit(_blockNumber, fullExitData.accountId, fullExitData.owner, fullExitData.tokenId, fullExitData.amount);
    }

    function emitCreatePairCommitEvent(uint32 _blockNumber, Operations.CreatePair memory createPairData) internal {

        emit CreatePairCommit(_blockNumber, createPairData.accountId, createPairData.tokenA, createPairData.tokenB, createPairData.tokenPair, createPairData.pair);
    }

    function collectOnchainOps(uint32 _blockNumber, bytes memory _publicData, bytes memory _ethWitness, uint32[] memory _ethWitnessSizes)
        internal returns (bytes32 withdrawalsDataHash) {

        require(_publicData.length % CHUNK_BYTES == 0, "fcs11"); // pubdata length must be a multiple of CHUNK_BYTES

        uint64 currentPriorityRequestId = firstPriorityRequestId + totalCommittedPriorityRequests;

        uint256 pubDataPtr = 0;
        uint256 pubDataStartPtr = 0;
        uint256 pubDataEndPtr = 0;

        assembly { pubDataStartPtr := add(_publicData, 0x20) }
        pubDataPtr = pubDataStartPtr;
        pubDataEndPtr = pubDataStartPtr + _publicData.length;

        uint64 ethWitnessOffset = 0;
        uint16 processedOperationsRequiringEthWitness = 0;

        withdrawalsDataHash = EMPTY_STRING_KECCAK;

        while (pubDataPtr < pubDataEndPtr) {
            Operations.OpType opType;
            assembly {
                opType := shr(0xf8, mload(pubDataPtr))
            }

            if (opType == Operations.OpType.Transfer) {
                pubDataPtr += TRANSFER_BYTES;
            } else if (opType == Operations.OpType.Noop) {
                pubDataPtr += NOOP_BYTES;
            } else if (opType == Operations.OpType.TransferToNew) {
                pubDataPtr += TRANSFER_TO_NEW_BYTES;
            } else if (opType == Operations.OpType.AddLiquidity) {
                pubDataPtr += UNISWAP_ADD_LIQ_BYTES;
            } else if (opType == Operations.OpType.RemoveLiquidity) {
                pubDataPtr += UNISWAP_RM_LIQ_BYTES;
            } else if (opType == Operations.OpType.Swap) {
                pubDataPtr += UNISWAP_SWAP_BYTES;
            } else {

                uint256 pubdataOffset = pubDataPtr - pubDataStartPtr;

                if (opType == Operations.OpType.Deposit) {
                    bytes memory pubData = Bytes.slice(_publicData, pubdataOffset + 1, DEPOSIT_BYTES - 1);

                    Operations.Deposit memory depositData = Operations.readDepositPubdata(pubData);
                    emitDepositCommitEvent(_blockNumber, depositData);

                    OnchainOperation memory onchainOp = OnchainOperation(
                        Operations.OpType.Deposit,
                        pubData
                    );
                    commitNextPriorityOperation(onchainOp, currentPriorityRequestId);
                    currentPriorityRequestId++;

                    pubDataPtr += DEPOSIT_BYTES;
                } else if (opType == Operations.OpType.PartialExit) {
                    Operations.PartialExit memory data = Operations.readPartialExitPubdata(_publicData, pubdataOffset + 1);

                    bool addToPendingWithdrawalsQueue = true;
                    withdrawalsDataHash = keccak256(abi.encode(withdrawalsDataHash, addToPendingWithdrawalsQueue, data.owner, data.tokenId, data.amount));

                    pubDataPtr += PARTIAL_EXIT_BYTES;
                } else if (opType == Operations.OpType.FullExit) {
                    bytes memory pubData = Bytes.slice(_publicData, pubdataOffset + 1, FULL_EXIT_BYTES - 1);

                    Operations.FullExit memory fullExitData = Operations.readFullExitPubdata(pubData);
                    emitFullExitCommitEvent(_blockNumber, fullExitData);

                    bool addToPendingWithdrawalsQueue = false;
                    withdrawalsDataHash = keccak256(abi.encode(withdrawalsDataHash, addToPendingWithdrawalsQueue, fullExitData.owner, fullExitData.tokenId, fullExitData.amount));

                    OnchainOperation memory onchainOp = OnchainOperation(
                        Operations.OpType.FullExit,
                        pubData
                    );
                    commitNextPriorityOperation(onchainOp, currentPriorityRequestId);
                    currentPriorityRequestId++;

                    pubDataPtr += FULL_EXIT_BYTES;
                } else if (opType == Operations.OpType.ChangePubKey) {
                    require(processedOperationsRequiringEthWitness < _ethWitnessSizes.length, "fcs13"); // eth witness data malformed
                    Operations.ChangePubKey memory op = Operations.readChangePubKeyPubdata(_publicData, pubdataOffset + 1);

                    if (_ethWitnessSizes[processedOperationsRequiringEthWitness] != 0) {
                        bytes memory currentEthWitness = Bytes.slice(_ethWitness, ethWitnessOffset, _ethWitnessSizes[processedOperationsRequiringEthWitness]);

                        bool valid = verifyChangePubkeySignature(currentEthWitness, op.pubKeyHash, op.nonce, op.owner, op.accountId);
                        require(valid, "fpp15"); // failed to verify change pubkey hash signature
                    } else {
                        bool valid = authFacts[op.owner][op.nonce] == keccak256(abi.encodePacked(op.pubKeyHash));
                        require(valid, "fpp16"); // new pub key hash is not authenticated properly
                    }

                    ethWitnessOffset += _ethWitnessSizes[processedOperationsRequiringEthWitness];
                    processedOperationsRequiringEthWitness++;

                    pubDataPtr += CHANGE_PUBKEY_BYTES;
                } else if (opType == Operations.OpType.CreatePair) {
                    bytes memory pubData = Bytes.slice(_publicData, pubdataOffset + 1, CREATE_PAIR_BYTES - 1);

                    Operations.CreatePair memory createPairData = Operations.readCreatePairPubdata(pubData);
                    emitCreatePairCommitEvent(_blockNumber, createPairData);

                    OnchainOperation memory onchainOp = OnchainOperation(
                        Operations.OpType.CreatePair,
                        pubData
                    );
                    commitNextPriorityOperation(onchainOp, currentPriorityRequestId);
                    currentPriorityRequestId++;

                    pubDataPtr += CREATE_PAIR_BYTES;
                } else {
                    revert("fpp14"); // unsupported op
                }
            }
        }
        require(pubDataPtr == pubDataEndPtr, "fcs12"); // last chunk exceeds pubdata
        require(ethWitnessOffset == _ethWitness.length, "fcs14"); // _ethWitness was not used completely
        require(processedOperationsRequiringEthWitness == _ethWitnessSizes.length, "fcs15"); // _ethWitnessSizes was not used completely

        require(currentPriorityRequestId <= firstPriorityRequestId + totalOpenPriorityRequests, "fcs16"); // fcs16 - excess priority requests in pubdata
        totalCommittedPriorityRequests = currentPriorityRequestId - firstPriorityRequestId;
    }

    function collectOnchainMultiOps(uint32[2] memory _blockInfo, bytes memory _publicData, bytes memory _ethWitness, uint32[] memory _ethWitnessSizes)
        internal returns (bytes32 withdrawalsDataHash) {

        require(_publicData.length % CHUNK_BYTES == 0, "fcs11"); // pubdata length must be a multiple of CHUNK_BYTES

        uint64 currentPriorityRequestId = firstPriorityRequestId + totalCommittedPriorityRequests;

        uint256 pubDataPtr = 0;
        uint256 pubDataStartPtr = 0;
        uint256 pubDataEndPtr = 0;

        assembly { pubDataStartPtr := add(_publicData, 0x20) }
        pubDataPtr = pubDataStartPtr;
        pubDataEndPtr = pubDataStartPtr + _publicData.length;

        uint64 ethWitnessOffset = 0;
        uint32 processedOperationsRequiringEthWitness = _blockInfo[1];

        withdrawalsDataHash = EMPTY_STRING_KECCAK;

	uint32 _blockNumber = _blockInfo[0];
        while (pubDataPtr < pubDataEndPtr) {
            Operations.OpType opType;
            assembly {
                opType := shr(0xf8, mload(pubDataPtr))
            }

            if (opType == Operations.OpType.Transfer) {
                pubDataPtr += TRANSFER_BYTES;
            } else if (opType == Operations.OpType.Noop) {
                pubDataPtr += NOOP_BYTES;
            } else if (opType == Operations.OpType.TransferToNew) {
                pubDataPtr += TRANSFER_TO_NEW_BYTES;
            } else if (opType == Operations.OpType.AddLiquidity)  {
                pubDataPtr += UNISWAP_ADD_LIQ_BYTES;
            } else if (opType == Operations.OpType.RemoveLiquidity) {
                pubDataPtr += UNISWAP_RM_LIQ_BYTES;
            } else if (opType == Operations.OpType.Swap) {
                pubDataPtr += UNISWAP_SWAP_BYTES;
            } else {

                uint256 pubdataOffset = pubDataPtr - pubDataStartPtr;

                if (opType == Operations.OpType.Deposit) {
                    bytes memory pubData = Bytes.slice(_publicData, pubdataOffset + 1, DEPOSIT_BYTES - 1);

                    Operations.Deposit memory depositData = Operations.readDepositPubdata(pubData);
                    emitDepositCommitEvent(_blockNumber, depositData);

                    OnchainOperation memory onchainOp = OnchainOperation(
                        Operations.OpType.Deposit,
                        pubData
                    );
                    commitNextPriorityOperation(onchainOp, currentPriorityRequestId);
                    currentPriorityRequestId++;

                    pubDataPtr += DEPOSIT_BYTES;
                } else if (opType == Operations.OpType.PartialExit) {
                    Operations.PartialExit memory data = Operations.readPartialExitPubdata(_publicData, pubdataOffset + 1);

                    bool addToPendingWithdrawalsQueue = true;
                    withdrawalsDataHash = keccak256(abi.encode(withdrawalsDataHash, addToPendingWithdrawalsQueue, data.owner, data.tokenId, data.amount));

                    pubDataPtr += PARTIAL_EXIT_BYTES;
                } else if (opType == Operations.OpType.FullExit) {
                    bytes memory pubData = Bytes.slice(_publicData, pubdataOffset + 1, FULL_EXIT_BYTES - 1);

                    Operations.FullExit memory fullExitData = Operations.readFullExitPubdata(pubData);
                    emitFullExitCommitEvent(_blockNumber, fullExitData);

                    bool addToPendingWithdrawalsQueue = false;
                    withdrawalsDataHash = keccak256(abi.encode(withdrawalsDataHash, addToPendingWithdrawalsQueue, fullExitData.owner, fullExitData.tokenId, fullExitData.amount));

                    OnchainOperation memory onchainOp = OnchainOperation(
                        Operations.OpType.FullExit,
                        pubData
                    );
                    commitNextPriorityOperation(onchainOp, currentPriorityRequestId);
                    currentPriorityRequestId++;

                    pubDataPtr += FULL_EXIT_BYTES;
                } else if (opType == Operations.OpType.ChangePubKey) {
                    require(processedOperationsRequiringEthWitness < _ethWitnessSizes.length, "fcs13"); // eth witness data malformed
                    Operations.ChangePubKey memory op = Operations.readChangePubKeyPubdata(_publicData, pubdataOffset + 1);

                    if (_ethWitnessSizes[processedOperationsRequiringEthWitness] != 0) {
                        bytes memory currentEthWitness = Bytes.slice(_ethWitness, ethWitnessOffset, _ethWitnessSizes[processedOperationsRequiringEthWitness]);

                        bool valid = verifyChangePubkeySignature(currentEthWitness, op.pubKeyHash, op.nonce, op.owner, op.accountId);
                        require(valid, "fpp15"); // failed to verify change pubkey hash signature
                    } else {
                        bool valid = authFacts[op.owner][op.nonce] == keccak256(abi.encodePacked(op.pubKeyHash));
                        require(valid, "fpp16"); // new pub key hash is not authenticated properly
                    }

                    ethWitnessOffset += _ethWitnessSizes[processedOperationsRequiringEthWitness];
                    processedOperationsRequiringEthWitness++;

                    pubDataPtr += CHANGE_PUBKEY_BYTES;
                } else if (opType == Operations.OpType.CreatePair) {
                    bytes memory pubData = Bytes.slice(_publicData, pubdataOffset + 1, CREATE_PAIR_BYTES - 1);

                    Operations.CreatePair memory createPairData = Operations.readCreatePairPubdata(pubData);
                    emitCreatePairCommitEvent(_blockNumber, createPairData);

                    OnchainOperation memory onchainOp = OnchainOperation(
                        Operations.OpType.CreatePair,
                        pubData
                    );
                    commitNextPriorityOperation(onchainOp, currentPriorityRequestId);
                    currentPriorityRequestId++;

                    pubDataPtr += CREATE_PAIR_BYTES;
                } else {
                    revert("fpp14"); // unsupported op
                }
            }
        }
        require(pubDataPtr == pubDataEndPtr, "fcs12"); // last chunk exceeds pubdata

        require(currentPriorityRequestId <= firstPriorityRequestId + totalOpenPriorityRequests, "fcs16"); // fcs16 - excess priority requests in pubdata
        totalCommittedPriorityRequests = currentPriorityRequestId - firstPriorityRequestId;
    }

    function verifyChangePubkeySignature(bytes memory _signature, bytes20 _newPkHash, uint32 _nonce, address _ethAddress, uint32 _accountId) internal pure returns (bool) {

        bytes memory signedMessage = abi.encodePacked(
            "\x19Ethereum Signed Message:\n152",
            "Register ZKSwap pubkey:\n\n",
            Bytes.bytesToHexASCIIBytes(abi.encodePacked(_newPkHash)), "\n",
            "nonce: 0x", Bytes.bytesToHexASCIIBytes(Bytes.toBytesFromUInt32(_nonce)), "\n",
            "account id: 0x", Bytes.bytesToHexASCIIBytes(Bytes.toBytesFromUInt32(_accountId)),
            "\n\n",
            "Only sign this message for a trusted client!"
        );
        address recoveredAddress = Utils.recoverAddressFromEthSignature(_signature, signedMessage);
        return recoveredAddress == _ethAddress;
    }

    function createBlockCommitment(
        uint32 _blockNumber,
        uint32 _feeAccount,
        bytes32 _oldRoot,
        bytes32 _newRoot,
        bytes memory _publicData
    ) internal view returns (bytes32 commitment) {

        bytes32 hash = sha256(
            abi.encodePacked(uint256(_blockNumber), uint256(_feeAccount))
        );
        hash = sha256(abi.encodePacked(hash, uint256(_oldRoot)));
        hash = sha256(abi.encodePacked(hash, uint256(_newRoot)));



        assembly {
            let hashResult := mload(0x40)
            let pubDataLen := mload(_publicData)
            mstore(_publicData, hash)
            let success := staticcall(
                gas,
                0x2,
                _publicData,
                add(pubDataLen, 0x20),
                hashResult,
                0x20
            )
            mstore(_publicData, pubDataLen)

            switch success case 0 { invalid() }

            commitment := mload(hashResult)
        }
    }

    function commitNextPriorityOperation(OnchainOperation memory _onchainOp, uint64 _priorityRequestId) internal view {

        Operations.OpType priorReqType = priorityRequests[_priorityRequestId].opType;
        bytes memory priorReqPubdata = priorityRequests[_priorityRequestId].pubData;

        require(priorReqType == _onchainOp.opType, "nvp12"); // incorrect priority op type

        if (_onchainOp.opType == Operations.OpType.Deposit) {
            require(Operations.depositPubdataMatch(priorReqPubdata, _onchainOp.pubData), "vnp13");
        } else if (_onchainOp.opType == Operations.OpType.FullExit) {
            require(Operations.fullExitPubdataMatch(priorReqPubdata, _onchainOp.pubData), "vnp14");
        } else if (_onchainOp.opType == Operations.OpType.CreatePair) {
            require(Operations.createPairPubdataMatch(priorReqPubdata, _onchainOp.pubData), "vnp15");
        } else {
            revert("vnp16"); // invalid or non-priority operation
        }
    }

    function processOnchainWithdrawals(bytes memory withdrawalsData, bytes32 expectedWithdrawalsDataHash) internal {

        require(withdrawalsData.length % ONCHAIN_WITHDRAWAL_BYTES == 0, "pow11"); // pow11 - withdrawalData length is not multiple of ONCHAIN_WITHDRAWAL_BYTES

        bytes32 withdrawalsDataHash = EMPTY_STRING_KECCAK;

        uint offset = 0;
        uint32 localNumberOfPendingWithdrawals = numberOfPendingWithdrawals;
        while (offset < withdrawalsData.length) {
            (bool addToPendingWithdrawalsQueue, address _to, uint16 _tokenId, uint128 _amount) = Operations.readWithdrawalData(withdrawalsData, offset);
            bytes22 packedBalanceKey = packAddressAndTokenId(_to, _tokenId);

            uint128 balance = balancesToWithdraw[packedBalanceKey].balanceToWithdraw;
            balancesToWithdraw[packedBalanceKey] = BalanceToWithdraw({
                balanceToWithdraw: balance.add(_amount),
                gasReserveValue: 0xff
            });

            if (addToPendingWithdrawalsQueue) {
                pendingWithdrawals[firstPendingWithdrawalIndex + localNumberOfPendingWithdrawals] = PendingWithdrawal(_to, _tokenId);
                localNumberOfPendingWithdrawals++;
            }

            withdrawalsDataHash = keccak256(abi.encode(withdrawalsDataHash, addToPendingWithdrawalsQueue, _to, _tokenId, _amount));
            offset += ONCHAIN_WITHDRAWAL_BYTES;
        }
        require(withdrawalsDataHash == expectedWithdrawalsDataHash, "pow12"); // pow12 - withdrawals data hash not matches with expected value
        if (numberOfPendingWithdrawals != localNumberOfPendingWithdrawals) {
            emit PendingWithdrawalsAdd(firstPendingWithdrawalIndex + numberOfPendingWithdrawals, firstPendingWithdrawalIndex + localNumberOfPendingWithdrawals);
        }
        numberOfPendingWithdrawals = localNumberOfPendingWithdrawals;
    }

    function isBlockCommitmentExpired() internal view returns (bool) {

        return (
            totalBlocksCommitted > totalBlocksVerified &&
            blocks[totalBlocksVerified + 1].committedAtBlock > 0 &&
            block.number > blocks[totalBlocksVerified + 1].committedAtBlock + EXPECT_VERIFICATION_IN
        );
    }

    function requireActive() internal view {

        require(!exodusMode, "fre11"); // exodus mode activated
    }

    function deleteRequests(uint64 _number) internal {

        require(_number <= totalOpenPriorityRequests, "pcs21"); // number is higher than total priority requests number

        uint64 numberOfRequestsToClear = Utils.minU64(_number, MAX_PRIORITY_REQUESTS_TO_DELETE_IN_VERIFY);
        uint64 startIndex = firstPriorityRequestId;
        for (uint64 i = startIndex; i < startIndex + numberOfRequestsToClear; i++) {
            delete priorityRequests[i];
        }

        totalOpenPriorityRequests -= _number;
        firstPriorityRequestId += _number;
        totalCommittedPriorityRequests -= _number;
    }

    function() external payable {
        address nextAddress = zkSyncExitAddress;
        require(nextAddress != address(0), "zkSyncExitAddress should be set");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), nextAddress, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {revert(0, returndatasize())}
            default {return (0, returndatasize())}
        }
    }
}