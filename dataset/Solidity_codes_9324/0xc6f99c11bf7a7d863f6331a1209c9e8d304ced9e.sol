pragma solidity ^0.7.0;





library Bytes {

    function toBytesFromUInt16(uint16 self) internal pure returns (bytes memory _bts) {

        return toBytesFromUIntTruncated(uint256(self), 2);
    }

    function toBytesFromUInt24(uint24 self) internal pure returns (bytes memory _bts) {

        return toBytesFromUIntTruncated(uint256(self), 3);
    }

    function toBytesFromUInt32(uint32 self) internal pure returns (bytes memory _bts) {

        return toBytesFromUIntTruncated(uint256(self), 4);
    }

    function toBytesFromUInt128(uint128 self) internal pure returns (bytes memory _bts) {

        return toBytesFromUIntTruncated(uint256(self), 16);
    }

    function toBytesFromUIntTruncated(uint256 self, uint8 byteLength) private pure returns (bytes memory bts) {

        require(byteLength <= 32, "bt211");
        bts = new bytes(byteLength);
        uint256 data = self << ((32 - byteLength) * 8);
        assembly {
            mstore(
                add(bts, 32), // BYTES_HEADER_SIZE
                data
            )
        }
    }

    function toBytesFromAddress(address self) internal pure returns (bytes memory bts) {

        bts = toBytesFromUIntTruncated(uint256(self), 20);
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

    function bytesToBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32 r) {

        uint256 offset = _start + 0x20;
        require(_bytes.length >= offset, "btb32");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {

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

    function read(
        bytes memory _data,
        uint256 _offset,
        uint256 _length
    ) internal pure returns (uint256 new_offset, bytes memory data) {

        data = slice(_data, _offset, _length);
        new_offset = _offset + _length;
    }

    function readBool(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, bool r) {

        new_offset = _offset + 1;
        r = uint8(_data[_offset]) != 0;
    }

    function readUint8(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, uint8 r) {

        new_offset = _offset + 1;
        r = uint8(_data[_offset]);
    }

    function readUInt16(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, uint16 r) {

        new_offset = _offset + 2;
        r = bytesToUInt16(_data, _offset);
    }

    function readUInt24(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, uint24 r) {

        new_offset = _offset + 3;
        r = bytesToUInt24(_data, _offset);
    }

    function readUInt32(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, uint32 r) {

        new_offset = _offset + 4;
        r = bytesToUInt32(_data, _offset);
    }

    function readUInt128(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, uint128 r) {

        new_offset = _offset + 16;
        r = bytesToUInt128(_data, _offset);
    }

    function readUInt160(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, uint160 r) {

        new_offset = _offset + 20;
        r = bytesToUInt160(_data, _offset);
    }

    function readAddress(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, address r) {

        new_offset = _offset + 20;
        r = bytesToAddress(_data, _offset);
    }

    function readBytes20(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, bytes20 r) {

        new_offset = _offset + 20;
        r = bytesToBytes20(_data, _offset);
    }

    function readBytes32(bytes memory _data, uint256 _offset) internal pure returns (uint256 new_offset, bytes32 r) {

        new_offset = _offset + 32;
        r = bytesToBytes32(_data, _offset);
    }

    function trim(bytes memory _data, uint256 _new_length) internal pure returns (uint256 r) {

        require(_new_length <= 0x20, "trm10"); // new_length is longer than word
        require(_data.length >= _new_length, "trm11"); // data is to short

        uint256 a;
        assembly {
            a := mload(add(_data, 0x20)) // load bytes into uint256
        }

        return a >> ((0x20 - _new_length) * 8);
    }
}pragma solidity ^0.7.0;





contract BytesTest {

    function read(
        bytes calldata _data,
        uint256 _offset,
        uint256 _len
    ) external pure returns (uint256 new_offset, bytes memory data) {

        return Bytes.read(_data, _offset, _len);
    }

    function testUInt24(uint24 x) external pure returns (uint24 r, uint256 offset) {

        require(keccak256(new bytes(0)) == keccak256(new bytes(0)));

        bytes memory buf = Bytes.toBytesFromUInt24(x);
        (offset, r) = Bytes.readUInt24(buf, 0);
    }
}pragma solidity ^0.7.0;



interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.7.0;





library Utils {

    function minU32(uint32 a, uint32 b) internal pure returns (uint32) {

        return a < b ? a : b;
    }

    function minU64(uint64 a, uint64 b) internal pure returns (uint64) {

        return a < b ? a : b;
    }

    function sendERC20(
        IERC20 _token,
        address _to,
        uint256 _amount
    ) internal returns (bool) {

        (bool callSuccess, bytes memory callReturnValueEncoded) =
            address(_token).call(abi.encodeWithSignature("transfer(address,uint256)", _to, _amount));
        bool returnedSuccess = callReturnValueEncoded.length == 0 || abi.decode(callReturnValueEncoded, (bool));
        return callSuccess && returnedSuccess;
    }

    function transferFromERC20(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {

        (bool callSuccess, bytes memory callReturnValueEncoded) =
            address(_token).call(abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _amount));
        bool returnedSuccess = callReturnValueEncoded.length == 0 || abi.decode(callReturnValueEncoded, (bool));
        return callSuccess && returnedSuccess;
    }

    function sendETHNoRevert(address payable _to, uint256 _amount) internal returns (bool) {

        uint256 ETH_WITHDRAWAL_GAS_LIMIT = 10000;

        (bool callSuccess, ) = _to.call{gas: ETH_WITHDRAWAL_GAS_LIMIT, value: _amount}("");
        return callSuccess;
    }

    function recoverAddressFromEthSignature(bytes memory _signature, bytes32 _messageHash)
        internal
        pure
        returns (address)
    {

        require(_signature.length == 65, "ves10"); // incorrect signature length

        bytes32 signR;
        bytes32 signS;
        uint256 offset = 0;

        (offset, signR) = Bytes.readBytes32(_signature, offset);
        (offset, signS) = Bytes.readBytes32(_signature, offset);
        uint8 signV = uint8(_signature[offset]);

        return ecrecover(_messageHash, signV, signR, signS);
    }

    function concatHash(bytes32 _hash, bytes memory _bytes) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_hash, _bytes));
    }
}pragma solidity ^0.7.0;




contract Config {

    uint256 constant ERC20_WITHDRAWAL_GAS_LIMIT = 50000;

    uint256 constant ETH_WITHDRAWAL_GAS_LIMIT = 10000;

    uint8 constant CHUNK_BYTES = 9;

    uint8 constant ADDRESS_BYTES = 20;

    uint8 constant PUBKEY_HASH_BYTES = 20;

    uint8 constant PUBKEY_BYTES = 32;

    uint8 constant ETH_SIGN_RS_BYTES = 32;

    uint8 constant SUCCESS_FLAG_BYTES = 1;

    uint16 constant MAX_AMOUNT_OF_REGISTERED_TOKENS = 127;

    uint32 constant MAX_ACCOUNT_ID = (2**24) - 1;

    uint256 constant BLOCK_PERIOD = 15 seconds;

    uint256 constant EXPECT_VERIFICATION_IN = 0 hours / BLOCK_PERIOD;

    uint256 constant NOOP_BYTES = 1 * CHUNK_BYTES;
    uint256 constant DEPOSIT_BYTES = 6 * CHUNK_BYTES;
    uint256 constant TRANSFER_TO_NEW_BYTES = 6 * CHUNK_BYTES;
    uint256 constant PARTIAL_EXIT_BYTES = 6 * CHUNK_BYTES;
    uint256 constant TRANSFER_BYTES = 2 * CHUNK_BYTES;
    uint256 constant FORCED_EXIT_BYTES = 6 * CHUNK_BYTES;

    uint256 constant FULL_EXIT_BYTES = 6 * CHUNK_BYTES;

    uint256 constant ONCHAIN_WITHDRAWAL_BYTES = 1 + 20 + 2 + 16; // (uint8 addToPendingWithdrawalsQueue, address _to, uint16 _tokenId, uint128 _amount)

    uint256 constant CHANGE_PUBKEY_BYTES = 6 * CHUNK_BYTES;

    uint256 constant PRIORITY_EXPIRATION_PERIOD = 3 days;

    uint256 constant PRIORITY_EXPIRATION =
        PRIORITY_EXPIRATION_PERIOD/BLOCK_PERIOD;

    uint64 constant MAX_PRIORITY_REQUESTS_TO_DELETE_IN_VERIFY = 6;

    uint256 constant MASS_FULL_EXIT_PERIOD = 3 days;

    uint256 constant TIME_TO_WITHDRAW_FUNDS_FROM_FULL_EXIT = 2 days;

    uint256 constant UPGRADE_NOTICE_PERIOD =
        MASS_FULL_EXIT_PERIOD+PRIORITY_EXPIRATION_PERIOD+TIME_TO_WITHDRAW_FUNDS_FROM_FULL_EXIT;

    uint256 constant COMMIT_TIMESTAMP_NOT_OLDER = 8 hours;

    uint256 constant COMMIT_TIMESTAMP_APPROXIMATION_DELTA = 15 minutes;
}pragma solidity ^0.7.0;





contract Governance is Config {

    event NewToken(address indexed token, uint16 indexed tokenId);

    event NewGovernor(address newGovernor);

    event ValidatorStatusUpdate(address indexed validatorAddress, bool isActive);

    event TokenPausedUpdate(address indexed token, bool paused);

    address public networkGovernor;

    uint16 public totalTokens;

    mapping(uint16 => address) public tokenAddresses;

    mapping(address => uint16) public tokenIds;

    mapping(address => bool) public validators;

    mapping(uint16 => bool) public pausedTokens;

    constructor() {}

    function initialize(bytes calldata initializationParameters) external {

        address _networkGovernor = abi.decode(initializationParameters, (address));

        networkGovernor = _networkGovernor;
    }

    function upgrade(bytes calldata upgradeParameters) external {}


    function changeGovernor(address _newGovernor) external {

        requireGovernor(msg.sender);
        if (networkGovernor != _newGovernor) {
            networkGovernor = _newGovernor;
            emit NewGovernor(_newGovernor);
        }
    }

    function addToken(address _token) external {

        requireGovernor(msg.sender);
        require(tokenIds[_token] == 0, "gan11"); // token exists
        require(totalTokens < MAX_AMOUNT_OF_REGISTERED_TOKENS, "gan12"); // no free identifiers for tokens

        totalTokens++;
        uint16 newTokenId = totalTokens; // it is not `totalTokens - 1` because tokenId = 0 is reserved for eth

        tokenAddresses[newTokenId] = _token;
        tokenIds[_token] = newTokenId;
        emit NewToken(_token, newTokenId);
    }

    function setTokenPaused(address _tokenAddr, bool _tokenPaused) external {

        requireGovernor(msg.sender);

        uint16 tokenId = this.validateTokenAddress(_tokenAddr);
        if (pausedTokens[tokenId] != _tokenPaused) {
            pausedTokens[tokenId] = _tokenPaused;
            emit TokenPausedUpdate(_tokenAddr, _tokenPaused);
        }
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

    function requireActiveValidator(address _address) external view {

        require(validators[_address], "grr21"); // validator is not active
    }

    function isValidTokenId(uint16 _tokenId) external view returns (bool) {

        return _tokenId <= totalTokens;
    }

    function validateTokenAddress(address _tokenAddr) external view returns (uint16) {

        uint16 tokenId = tokenIds[_tokenAddr];
        require(tokenId != 0, "gvs11"); // 0 is not a valid token
        return tokenId;
    }
}pragma solidity >=0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;





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
        return pow(fr, r_mod - 2);
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
        uint256[2] X;
        uint256[2] Y;
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


        return
            G2Point(
                [
                    0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2,
                    0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed
                ],
                [
                    0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b,
                    0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa
                ]
            );
    }

    function negate(G1Point memory self) internal pure {

        if (self.Y == 0) {
            require(self.X == 0);
            return;
        }

        self.Y = q_mod - self.Y;
    }

    function point_add(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {

        point_add_into_dest(p1, p2, r);
        return r;
    }

    function point_add_assign(G1Point memory p1, G1Point memory p2) internal view {

        point_add_into_dest(p1, p2, p1);
    }

    function point_add_into_dest(
        G1Point memory p1,
        G1Point memory p2,
        G1Point memory dest
    ) internal view {

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

    function point_sub_assign(G1Point memory p1, G1Point memory p2) internal view {

        point_sub_into_dest(p1, p2, p1);
    }

    function point_sub_into_dest(
        G1Point memory p1,
        G1Point memory p2,
        G1Point memory dest
    ) internal view {

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

    function point_mul(G1Point memory p, Fr memory s) internal view returns (G1Point memory r) {

        point_mul_into_dest(p, s, r);
        return r;
    }

    function point_mul_assign(G1Point memory p, Fr memory s) internal view {

        point_mul_into_dest(p, s, p);
    }

    function point_mul_into_dest(
        G1Point memory p,
        Fr memory s,
        G1Point memory dest
    ) internal view {

        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s.value;
        bool success;
        assembly {
            success := staticcall(gas(), 7, input, 0x60, dest, 0x40)
        }
        require(success);
    }

    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {

        require(p1.length == p2.length);
        uint256 elements = p1.length;
        uint256 inputSize = elements * 6;
        uint256[] memory input = new uint256[](inputSize);
        for (uint256 i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint256[1] memory out;
        bool success;
        assembly {
            success := staticcall(gas(), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
        }
        require(success);
        return out[0] != 0;
    }

    function pairingProd2(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2
    ) internal view returns (bool) {

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

    function get_challenge(Transcript memory self) internal pure returns (PairingsBn254.Fr memory challenge) {

        bytes32 query = keccak256(abi.encodePacked(DST_CHALLENGE, self.state_0, self.state_1, self.challenge_counter));
        self.challenge_counter += 1;
        challenge = PairingsBn254.Fr({value: uint256(query) & FR_MASK});
    }
}

contract Plonk4VerifierWithAccessToDNext {

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

    uint256 constant RECURSIVE_CIRCUIT_INPUT_COMMITMENT_MASK =
        0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 constant LIMB_WIDTH = 68;

    struct VerificationKey {
        uint256 domain_size;
        uint256 num_inputs;
        PairingsBn254.Fr omega;
        PairingsBn254.G1Point[NUM_SETUP_POLYS_FOR_MAIN_GATE + NUM_SETUP_POLYS_RANGE_CHECK_GATE] gate_setup_commitments;
        PairingsBn254.G1Point[NUM_DIFFERENT_GATES] gate_selector_commitments;
        PairingsBn254.G1Point[STATE_WIDTH] copy_permutation_commitments;
        PairingsBn254.Fr[STATE_WIDTH - 1] copy_permutation_non_residues;
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
        PairingsBn254.Fr[STATE_WIDTH - 1] permutation_polynomials_at_z;
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

    function batch_evaluate_lagrange_poly_out_of_domain(
        uint256[] memory poly_nums,
        uint256 domain_size,
        PairingsBn254.Fr memory omega,
        PairingsBn254.Fr memory at
    ) internal view returns (PairingsBn254.Fr[] memory res) {

        PairingsBn254.Fr memory one = PairingsBn254.new_fr(1);
        PairingsBn254.Fr memory tmp_1 = PairingsBn254.new_fr(0);
        PairingsBn254.Fr memory tmp_2 = PairingsBn254.new_fr(domain_size);
        PairingsBn254.Fr memory vanishing_at_z = at.pow(domain_size);
        vanishing_at_z.sub_assign(one);
        require(vanishing_at_z.value != 0);
        PairingsBn254.Fr[] memory nums = new PairingsBn254.Fr[](poly_nums.length);
        PairingsBn254.Fr[] memory dens = new PairingsBn254.Fr[](poly_nums.length);
        for (uint256 i = 0; i < poly_nums.length; i++) {
            tmp_1 = omega.pow(poly_nums[i]); // power of omega
            nums[i].assign(vanishing_at_z);
            nums[i].mul_assign(tmp_1);

            dens[i].assign(at); // (X - omega^i) * N
            dens[i].sub_assign(tmp_1);
            dens[i].mul_assign(tmp_2); // mul by domain size
        }

        PairingsBn254.Fr[] memory partial_products = new PairingsBn254.Fr[](poly_nums.length);
        partial_products[0].assign(PairingsBn254.new_fr(1));
        for (uint256 i = 1; i < dens.length - 1; i++) {
            partial_products[i].assign(dens[i - 1]);
            partial_products[i].mul_assign(dens[i]);
        }

        tmp_2.assign(partial_products[partial_products.length - 1]);
        tmp_2.mul_assign(dens[dens.length - 1]);
        tmp_2 = tmp_2.inverse(); // tmp_2 contains a^-1 * b^-1 (with! the last one)

        for (uint256 i = dens.length - 1; i < dens.length; i--) {
            dens[i].assign(tmp_2); // all inversed
            dens[i].mul_assign(partial_products[i]); // clear lowest terms
            tmp_2.mul_assign(dens[i]);
        }

        for (uint256 i = 0; i < nums.length; i++) {
            nums[i].mul_assign(dens[i]);
        }

        return nums;
    }

    function evaluate_vanishing(uint256 domain_size, PairingsBn254.Fr memory at)
        internal
        view
        returns (PairingsBn254.Fr memory res)
    {

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

        tmp_g1 = vk.gate_setup_commitments[STATE_WIDTH + 2].point_mul(proof.wire_values_at_z_omega[0]); // index of q_d_next(x)
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
            tmp_fr.add_assign(proof.wire_values_at_z[i + 1]);

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
        for (uint256 i = 1; i < proof.quotient_poly_commitments.length; i++) {
            tmp_fr.mul_assign(z_in_domain_size);
            tmp_g1 = proof.quotient_poly_commitments[i].point_mul(tmp_fr);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        aggregation_challenge.mul_assign(state.v);
        commitment_aggregation.point_add_assign(d);

        for (uint256 i = 0; i < proof.wire_commitments.length; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_g1 = proof.wire_commitments[i].point_mul(aggregation_challenge);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        for (uint256 i = 0; i < NUM_GATE_SELECTORS_OPENED_EXPLICITLY; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_g1 = vk.gate_selector_commitments[0].point_mul(aggregation_challenge);
            commitment_aggregation.point_add_assign(tmp_g1);
        }

        for (uint256 i = 0; i < vk.copy_permutation_commitments.length - 1; i++) {
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

        for (uint256 i = 0; i < proof.wire_values_at_z.length; i++) {
            aggregation_challenge.mul_assign(state.v);

            tmp_fr.assign(proof.wire_values_at_z[i]);
            tmp_fr.mul_assign(aggregation_challenge);
            aggregated_value.add_assign(tmp_fr);
        }

        for (uint256 i = 0; i < proof.gate_selector_values_at_z.length; i++) {
            aggregation_challenge.mul_assign(state.v);
            tmp_fr.assign(proof.gate_selector_values_at_z[i]);
            tmp_fr.mul_assign(aggregation_challenge);
            aggregated_value.add_assign(tmp_fr);
        }

        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
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
        require(vk.num_inputs >= 1);
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

        uint256[] memory lagrange_poly_numbers = new uint256[](vk.num_inputs);
        for (uint256 i = 0; i < lagrange_poly_numbers.length; i++) {
            lagrange_poly_numbers[i] = i;
        }

        state.cached_lagrange_evals = batch_evaluate_lagrange_poly_out_of_domain(
            lagrange_poly_numbers,
            vk.domain_size,
            vk.omega,
            state.z
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


    function aggregate_for_verification(Proof memory proof, VerificationKey memory vk)
        internal
        view
        returns (bool valid, PairingsBn254.G1Point[2] memory part)
    {

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

        valid = PairingsBn254.pairingProd2(
            recursive_proof_part[0],
            PairingsBn254.P2(),
            recursive_proof_part[1],
            vk.g2_x
        );

        return valid;
    }

    function verify_recursive(
        Proof memory proof,
        VerificationKey memory vk,
        uint256 recursive_vks_root,
        uint8 max_valid_index,
        uint8[] memory recursive_vks_indexes,
        uint256[] memory individual_vks_inputs,
        uint256[16] memory subproofs_limbs
    ) internal view returns (bool) {

        (uint256 recursive_input, PairingsBn254.G1Point[2] memory aggregated_g1s) =
            reconstruct_recursive_public_input(
                recursive_vks_root,
                max_valid_index,
                recursive_vks_indexes,
                individual_vks_inputs,
                subproofs_limbs
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
        uint256[16] memory subproofs_aggregated
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
            subproofs_aggregated[0] +
                (subproofs_aggregated[1] << LIMB_WIDTH) +
                (subproofs_aggregated[2] << (2 * LIMB_WIDTH)) +
                (subproofs_aggregated[3] << (3 * LIMB_WIDTH)),
            subproofs_aggregated[4] +
                (subproofs_aggregated[5] << LIMB_WIDTH) +
                (subproofs_aggregated[6] << (2 * LIMB_WIDTH)) +
                (subproofs_aggregated[7] << (3 * LIMB_WIDTH))
        );

        reconstructed_g1s[1] = PairingsBn254.new_g1_checked(
            subproofs_aggregated[8] +
                (subproofs_aggregated[9] << LIMB_WIDTH) +
                (subproofs_aggregated[10] << (2 * LIMB_WIDTH)) +
                (subproofs_aggregated[11] << (3 * LIMB_WIDTH)),
            subproofs_aggregated[12] +
                (subproofs_aggregated[13] << LIMB_WIDTH) +
                (subproofs_aggregated[14] << (2 * LIMB_WIDTH)) +
                (subproofs_aggregated[15] << (3 * LIMB_WIDTH))
        );

        return (recursive_input, reconstructed_g1s);
    }
}

contract VerifierWithDeserialize is Plonk4VerifierWithAccessToDNext {

    uint256 constant SERIALIZED_PROOF_LENGTH = 34;

    function deserialize_proof(uint256[] memory public_inputs, uint256[] memory serialized_proof)
        internal
        pure
        returns (Proof memory proof)
    {

        require(serialized_proof.length == SERIALIZED_PROOF_LENGTH);
        proof.input_values = new uint256[](public_inputs.length);
        for (uint256 i = 0; i < public_inputs.length; i++) {
            proof.input_values[i] = public_inputs[i];
        }

        uint256 j = 0;
        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            proof.wire_commitments[i] = PairingsBn254.new_g1_checked(serialized_proof[j], serialized_proof[j + 1]);

            j += 2;
        }

        proof.copy_permutation_grand_product_commitment = PairingsBn254.new_g1_checked(
            serialized_proof[j],
            serialized_proof[j + 1]
        );
        j += 2;

        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            proof.quotient_poly_commitments[i] = PairingsBn254.new_g1_checked(
                serialized_proof[j],
                serialized_proof[j + 1]
            );

            j += 2;
        }

        for (uint256 i = 0; i < STATE_WIDTH; i++) {
            proof.wire_values_at_z[i] = PairingsBn254.new_fr(serialized_proof[j]);

            j += 1;
        }

        for (uint256 i = 0; i < proof.wire_values_at_z_omega.length; i++) {
            proof.wire_values_at_z_omega[i] = PairingsBn254.new_fr(serialized_proof[j]);

            j += 1;
        }

        for (uint256 i = 0; i < proof.gate_selector_values_at_z.length; i++) {
            proof.gate_selector_values_at_z[i] = PairingsBn254.new_fr(serialized_proof[j]);

            j += 1;
        }

        for (uint256 i = 0; i < proof.permutation_polynomials_at_z.length; i++) {
            proof.permutation_polynomials_at_z[i] = PairingsBn254.new_fr(serialized_proof[j]);

            j += 1;
        }

        proof.copy_grand_product_at_z_omega = PairingsBn254.new_fr(serialized_proof[j]);

        j += 1;

        proof.quotient_polynomial_at_z = PairingsBn254.new_fr(serialized_proof[j]);

        j += 1;

        proof.linearization_polynomial_at_z = PairingsBn254.new_fr(serialized_proof[j]);

        j += 1;

        proof.opening_at_z_proof = PairingsBn254.new_g1_checked(serialized_proof[j], serialized_proof[j + 1]);
        j += 2;

        proof.opening_at_z_omega_proof = PairingsBn254.new_g1_checked(serialized_proof[j], serialized_proof[j + 1]);
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
        uint256[16] memory subproofs_limbs,
        VerificationKey memory vk
    ) public view returns (bool) {

        require(vk.num_inputs == public_inputs.length);

        Proof memory proof = deserialize_proof(public_inputs, serialized_proof);

        bool valid =
            verify_recursive(
                proof,
                vk,
                recursive_vks_root,
                max_valid_index,
                recursive_vks_indexes,
                individual_vks_inputs,
                subproofs_limbs
            );

        return valid;
    }
}pragma solidity ^0.7.0;







contract KeysWithPlonkVerifier is VerifierWithDeserialize {


    uint256 constant VK_TREE_ROOT = 0x2d30d1a0fc7880759a9a38f5f2b2faeeb449186dbb1ea3461980b1defdd3d009;
    uint8 constant VK_MAX_INDEX = 5;
    uint256 constant VK_EXIT_TREE_ROOT = 0x1a0126b1a46229ab86d1596d8c1c0129629f8aaf71d08027471d1ceaa22e76ad;

    function getVkAggregated(uint32 _proofs) internal pure returns (VerificationKey memory vk) {

        if (_proofs == uint32(1)) { return getVkAggregated1(); }
        else if (_proofs == uint32(5)) { return getVkAggregated5(); }
        else if (_proofs == uint32(10)) { return getVkAggregated10(); }
        else if (_proofs == uint32(20)) { return getVkAggregated20(); }
    }

    
    function getVkAggregated1() internal pure returns(VerificationKey memory vk) {

        vk.domain_size = 4194304;
        vk.num_inputs = 1;
        vk.omega = PairingsBn254.new_fr(0x18c95f1ae6514e11a1b30fd7923947c5ffcec5347f16e91b4dd654168326bede);
        vk.gate_setup_commitments[0] = PairingsBn254.new_g1(
            0x22da2b43b4df083c8d97322b24a754206832f897545426a34c89a31ce32e6d71,
            0x14a0228494b414796322c2ddf4794bb2a2afa71f0b683037be1e801c953fd7f7
        );
        vk.gate_setup_commitments[1] = PairingsBn254.new_g1(
            0x2407f20cabd71cc784c73d07fae1e54973a1fe4d1a95730f6df91782436a4f0e,
            0x09d62eab4b956798b26b81b81a15d6dbb60d9635104ae1df2b492e1d813a47da
        );
        vk.gate_setup_commitments[2] = PairingsBn254.new_g1(
            0x19c4e2f820f273c8150cbe436f614625e1c5d063a3d1111e46a59252442b7488,
            0x11f8af93dbd520e0b509f74acc3614dc30e45d6245aa46634e3e0226c1246bc4
        );
        vk.gate_setup_commitments[3] = PairingsBn254.new_g1(
            0x14373af9f615150befae0d36a71a1552a5097b4c211cbc0da44a285bbebe1603,
            0x2f50004d7f85b687ff124a9cd5bcaacb3e0ef31e3cd71a1932e8d099c6af7e09
        );
        vk.gate_setup_commitments[4] = PairingsBn254.new_g1(
            0x08062a059421bea203eac68d062f0dc2aff7ffa6eaea202f627937110d635b07,
            0x03b46067547509211b66876b13cade17ac3e506341718e53dcc265457e68654c
        );
        vk.gate_setup_commitments[5] = PairingsBn254.new_g1(
            0x0965e36d9da3434423e4f19d0cac1620e138b736566a5a101110d99b431b6675,
            0x1a76b366f4b7ee995f1e2cb32dc765a563d4c8e5b2c5e3a11fea4725b7ce2c14
        );
        vk.gate_setup_commitments[6] = PairingsBn254.new_g1(
            0x178f79ba2a4b88f667ae4ff1b83f833950613add9ae264ae90561f277b0e1c06,
            0x0a8b1c5b1a072bf70095f03228a8325cdf99d90ab0c2df622c4a451a7f953682
        );
        vk.gate_selector_commitments[0] = PairingsBn254.new_g1(
            0x237149b5bf5ac6fe9fe5cfeafd4a3f067bed6c47109a82af74337e5baa225b2c,
            0x2f6ab33cd38c19824e98eca955d87f7711cd6440870db31d9620e08965ba2cde
        );
        vk.gate_selector_commitments[1] = PairingsBn254.new_g1(
            0x28c30d305efd384e35c4e8e1c2269c3ba2d2e3b4bb2e477d4fba08b4bf47253c,
            0x119f92e3028a299468a036b7e88cf8629b9d0287b61e50994b06ce477bdac91f
        );
        vk.copy_permutation_commitments[0] = PairingsBn254.new_g1(
            0x1ea2c1d8e434d0d195cd3e241b0628e534bc32721ab52e83ef1b2812a9eb8540,
            0x0b2216fe4842960e9ca45622864318e70276c263b31c9a1889b0d9801204fcd1
        );
        vk.copy_permutation_commitments[1] = PairingsBn254.new_g1(
            0x1ea74d3f2cabc47c8027080d9b1fdcdbc0e1d5e81ad4cd0cd51c2a033152e0e7,
            0x22ad474557334081aae6f9663b8a7e65d5cc27846b63a19e2980cd4b23584152
        );
        vk.copy_permutation_commitments[2] = PairingsBn254.new_g1(
            0x11046c6546a01c31b9f9a78aa0afaf3da9bf684c6e3fff530e7bfb918385ad01,
            0x21a1da279a3388ddd2625d90ca358ab0fd28b92a485dc7e704e2bcfd7c886491
        );
        vk.copy_permutation_commitments[3] = PairingsBn254.new_g1(
            0x1ad755a68efa80314226acc7e50a9e59c5ea5e3e736d58eb31dd0d5d25b1b20c,
            0x1b6d12a361b9f715f94cea5222ea51fd977206e05d2615ce31defdffc700b9da
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
            0x2266b592818440dbc63787f3a1aa042c0205806e8bcaa85fd9731bd804f1336c,
            0x00cea1098cbe6b4281ff3cfef2cf473b71f7f112095bab2b2363113dbf786c79
        );
        vk.gate_setup_commitments[1] = PairingsBn254.new_g1(
            0x1ec307f5fadd8403d2fb5832adaf282ae098c5cdfcacc96840dac6ecf5831fa9,
            0x15de86892d8219441aa9b5c446ec106ee43d598ab38716dd5d611a8b53a26893
        );
        vk.gate_setup_commitments[2] = PairingsBn254.new_g1(
            0x197cbf225725dc443e24ab535435678435f56861f2ffef2595feb0951249e7cb,
            0x11a18010639b7b200170e28a840d9d1fafc8d97726dd303b9b03a6d59e6ed222
        );
        vk.gate_setup_commitments[3] = PairingsBn254.new_g1(
            0x290b4842d6cde9120e2224129812643df0a801d2a50c6453ca64c943b83e37f5,
            0x1dc4be4821c84779c2e3f798143fd15702ffe1a5c237acad46d0f1399fddb24e
        );
        vk.gate_setup_commitments[4] = PairingsBn254.new_g1(
            0x114784b9c2e7493e44a05de353457d68bc500922477b14eb87bd0a37f915d1a2,
            0x12f2d0247671d07610974806a5a770fda023e4b3b2b2e0463c3b56edadc7a943
        );
        vk.gate_setup_commitments[5] = PairingsBn254.new_g1(
            0x188056ff46003a1deab44d44c19287ab9a76bea879edb31c1bc0174dbefa1f95,
            0x299cb5a8f96818e8bf450f9b5b7a4ff62f4b59949de68d21be2415e7e9d6eec1
        );
        vk.gate_setup_commitments[6] = PairingsBn254.new_g1(
            0x2b4d114709231f87407121e792c4fecc56d0763a28261bc1a46e571e260635a5,
            0x2a391a14ca0ea7e1b905fbef60aeb27990209b01eb324592ced93591b7cbb5fc
        );
        vk.gate_selector_commitments[0] = PairingsBn254.new_g1(
            0x2d544c51aa523a26d054dff6da0f86c1a756c3ad5ef1827b059e56804f9a0d28,
            0x0129aba2ce479db66e18414a47de275d12c16b6ea416502d2156a97224c12645
        );
        vk.gate_selector_commitments[1] = PairingsBn254.new_g1(
            0x06db383f9ff92a9a6e3269612bce2c606949588309fe6aac6a62f56dc1652bb1,
            0x1e6e5dcd2fa0f37683075cc55a8012b4e3d50d0c47a5297869316792b6d40f0a
        );
        vk.copy_permutation_commitments[0] = PairingsBn254.new_g1(
            0x28ee9697ebf38f6cfe491ac0f0ce10982cf52800f9eee5b797d9c7c3f8a947ad,
            0x0f38da2c8b0c6b2c075f7cdcf2df6ef5055f9280201bf592d7cc837083c60258
        );
        vk.copy_permutation_commitments[1] = PairingsBn254.new_g1(
            0x2057c00374fad5ec29eec51150dcd5c2bfa676e483c86669d74bf14d74bf6b68,
            0x100997e07f3e9e784d1b8fd83d6cc8e6fb85efbe7a172edd80a1a801381548ec
        );
        vk.copy_permutation_commitments[2] = PairingsBn254.new_g1(
            0x236f1b6dac13cefc0cff6faef765072033c36929ead1fe29ce34ae60729be60a,
            0x0b54185abb9cebb9afb1a731919d69d1017120a8e0fc1dcb69c1b9c1d43a56ab
        );
        vk.copy_permutation_commitments[3] = PairingsBn254.new_g1(
            0x1f9a8a5c55bf9ce3e162eda25aac82b8cc6e461d43c54055f2d1ea8b8499948c,
            0x10473a3f95e08a754f67308d33bc8f0c9be19d71b89feb2f99768e3d5eeebf6c
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
    
    function getVkAggregated10() internal pure returns(VerificationKey memory vk) {

        vk.domain_size = 33554432;
        vk.num_inputs = 1;
        vk.omega = PairingsBn254.new_fr(0x0d94d63997367c97a8ed16c17adaae39262b9af83acb9e003f94c217303dd160);
        vk.gate_setup_commitments[0] = PairingsBn254.new_g1(
            0x1f80ecf9e07df072876d928e78cadd4be8223efa5de7a639990f717e6d68129a,
            0x0cc24ea3be8508f4e06a0a1702569834eaf4e7c565bf1a6e464a97524d51e53a
        );
        vk.gate_setup_commitments[1] = PairingsBn254.new_g1(
            0x0c8fd9c7f0307514d11ae4ea1f9ae220af20662d55209c9669ed671e17a6d7a9,
            0x1a908e93618a0694c6edc47388e0fd17a8eddb2dc2a76a590991397ec20302d0
        );
        vk.gate_setup_commitments[2] = PairingsBn254.new_g1(
            0x16544a6923d0ea48e2b69e19a0b4b466e08dd1b56c252ea713b419961644f441,
            0x29cde074c979f212c771d211c5514f7e50473684b8b760ad18a7ec06424e180c
        );
        vk.gate_setup_commitments[3] = PairingsBn254.new_g1(
            0x06e77ffa22b90d36a5bfe5a580524836bc33be848039761764d951cc85735b7b,
            0x26545911b48574aab42adf3466f6e2d90222bbad17bfb47205bd01735299318e
        );
        vk.gate_setup_commitments[4] = PairingsBn254.new_g1(
            0x07af8afd0d08848659b99ba71aa80ad5ffe8cc37d28f638a27309084ee905e72,
            0x177fb27cd9ade55205b5bf7b0a1d95639466cb18600efeb0df780d3dd8267327
        );
        vk.gate_setup_commitments[5] = PairingsBn254.new_g1(
            0x0c8368b5b9f4be800e3c10c8c1a0dd99323c0c990e81b347147f78193132ea4f,
            0x082a1019087dc5501e4d117fb811d9e7ae4a0e51e9b28759de722600623f57ad
        );
        vk.gate_setup_commitments[6] = PairingsBn254.new_g1(
            0x12828a7fe9d46b3a10bcfa6f23ba41b8948fcff1b6654e4942db9d28247510c0,
            0x0121deedb8cb6b747238db8ccf345e0f64502af13eac5787212ebfdfd9c8a590
        );
        vk.gate_selector_commitments[0] = PairingsBn254.new_g1(
            0x02c418dd647e62b1ce21329064b49c5ac3d631d7e2a4422482f90364eb9e2ffc,
            0x1c6265347386b476081e0f46d9b353f78784a38a55a89388f8a31648693dbc8a
        );
        vk.gate_selector_commitments[1] = PairingsBn254.new_g1(
            0x1012ee4f289e19a5dad4b261d8619fe8643327b22b11df175c0a244e62d982cb,
            0x0629cb024cb181471346a3126b389473f1a546188093384ff9837a6136a50352
        );
        vk.copy_permutation_commitments[0] = PairingsBn254.new_g1(
            0x0b1a35615ab9c34a8ff7c645eaf2e4597e6b3ede7c00b5f2af5b798cee0e1574,
            0x226e72be44f6000c4de8e8e3a6769cc2f643faebfbf65ac84f9dd23a24300a83
        );
        vk.copy_permutation_commitments[1] = PairingsBn254.new_g1(
            0x0dd4b4998d775f0e90c5dfe3c9f3f86eafd7f5e97b97831175570f3aaeb9c71c,
            0x0bec5afdd4f230b469ed00602c1d02201bb76ccd22931ad9318da00fea312d88
        );
        vk.copy_permutation_commitments[2] = PairingsBn254.new_g1(
            0x2c4890d6e52bd86bfc68992150628815bb2eeb4f7c038f33247e18062923106a,
            0x01c5e5fdf091264a70d9ccbd1844173c349120387c15a4d90d4c48abf767aca3
        );
        vk.copy_permutation_commitments[3] = PairingsBn254.new_g1(
            0x2b4bfd08af94fdd100ca8dc8f97f05d1e3952987a0d00ee80d0b0f5e91734e5b,
            0x0f44b87cc4627711335babadf98d28f44e8a02fb321e869dff626c4fbd34d09a
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
    
    function getVkAggregated20() internal pure returns(VerificationKey memory vk) {

        vk.domain_size = 67108864;
        vk.num_inputs = 1;
        vk.omega = PairingsBn254.new_fr(0x1dba8b5bdd64ef6ce29a9039aca3c0e524395c43b9227b96c75090cc6cc7ec97);
        vk.gate_setup_commitments[0] = PairingsBn254.new_g1(
            0x08926991f4c681831e6fe1fd3b4e6a0cf658fd404e0cca92864e514b96478161,
            0x17867a63c89789d74c26b600a385cfdbda51cb596a237e29d0d88f2b4c0629f5
        );
        vk.gate_setup_commitments[1] = PairingsBn254.new_g1(
            0x0fd7d94afc0788dba7b0e7652f776798ea08e883e075ead5f465bbd81e6fc99b,
            0x04090c3d0ddf060e405abb11802427e052b6720af4eef5e48d1935b1be0ca06b
        );
        vk.gate_setup_commitments[2] = PairingsBn254.new_g1(
            0x075f268e92b3301b34f9ce5496b047038e0cf60af4fb305ea1778076a3e9b092,
            0x2051024d75a7b5b3d3fb0ffff24f103d91725663943f6b02adcfb01f30c27e50
        );
        vk.gate_setup_commitments[3] = PairingsBn254.new_g1(
            0x117a97c8bd2f4cdd59eedb61b68801de7bf8881af79d210d08d6ebe370073cac,
            0x27ccdf3a13b329826cafc1903d66dd40e2a7aab70d1a272500af3e708038df1c
        );
        vk.gate_setup_commitments[4] = PairingsBn254.new_g1(
            0x18838fc7904eb1fc84afce3437f52830ce78d5386cdcbdff0915113be1fc7d66,
            0x08cb9e758bb069e113a2d1a4aa55f3de2539128ffed2d42ab1d3b142da9a3022
        );
        vk.gate_setup_commitments[5] = PairingsBn254.new_g1(
            0x0be0b03c8447224df15da6e669a3d43a530adedb28b338d4c7b8569d088c6ac0,
            0x2d2e57e1e72a245312ce3cabdc21f576a3942a78ce0b67518b4d7ae960913c64
        );
        vk.gate_setup_commitments[6] = PairingsBn254.new_g1(
            0x202604814117abd6df7e8bb156d83b1631238519d7a864afdb1f6821ad84dbd0,
            0x2073d36dc8f1f3d3557c1b6e70908181f4492dba571131f111909ad8e9a4c23b
        );
        vk.gate_selector_commitments[0] = PairingsBn254.new_g1(
            0x1363a8519f225f173b5fa21caecefdfa6aa2edfba5d316ead638dbd4d89c6418,
            0x03296e2faa2915f7acc0806e6679cf716da531a9b7eb14624b9a58b1933e120f
        );
        vk.gate_selector_commitments[1] = PairingsBn254.new_g1(
            0x19dfcebbb55db8c3cc9af354b262bbd1f72e103eaa93c83bf503783b80ec362c,
            0x086fa13bd394c8fa2dddae1995fbcf6acb5c561e43fbaf5c66321bdc5037a78e
        );
        vk.copy_permutation_commitments[0] = PairingsBn254.new_g1(
            0x11e73d5046c3a7e2253c703aac9f825fb4a4943efdbd3777b938dc43956d29c3,
            0x07161cb02534f8a483011aee48140d31270578cfc7200269b4e938742da669de
        );
        vk.copy_permutation_commitments[1] = PairingsBn254.new_g1(
            0x24c3a8df1bf71d5a3fd7495bf2fafd43d75c845ac0599cdf5bbb31c72b8d807a,
            0x0b6914dc01f33047cb6278fcd729f56fb3b77ad8a669f5cb9077323c161fbb3a
        );
        vk.copy_permutation_commitments[2] = PairingsBn254.new_g1(
            0x21ae18f1c9b1414d512ed1dada4e5d31ea6854edd3bde66053799c4e9f5f6f65,
            0x1661d279963c2798739381d19b375340098d296bd1ace972012aae93695100aa
        );
        vk.copy_permutation_commitments[3] = PairingsBn254.new_g1(
            0x0c1a45ae969673533f1cd3cef4f2f56e9fe4967777cae2cf29daf195d7c9d18e,
            0x2f85f3f301134e9165f9cc32c0717e0c2dc87a3bfaac6e2aea73cdfda0b0546f
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
    

}pragma solidity ^0.7.0;






contract Verifier is KeysWithPlonkVerifier {

    bool constant DUMMY_VERIFIER = false;

    function initialize(bytes calldata) external {}


    function upgrade(bytes calldata upgradeParameters) external {}


    function verifyAggregatedProof(
        uint256[] memory _recursiveInput,
        uint256[] memory _proof,
        uint8[] memory _vkIndexes,
        uint256[] memory _individual_vks_inputs,
        uint256[16] memory _subproofs_limbs,
        bool blockProof
    ) external view returns (bool) {

        if (DUMMY_VERIFIER && blockProof) {
            uint256 oldGasValue = gasleft();
            uint256 tmp;
            while (gasleft() + 500000 > oldGasValue) {
                tmp += 1;
            }
            return true;
        }
        for (uint256 i = 0; i < _individual_vks_inputs.length; ++i) {
            uint256 commitment = _individual_vks_inputs[i];
            uint256 mask = (~uint256(0)) >> 3;
            _individual_vks_inputs[i] = uint256(commitment) & mask;
        }
        VerificationKey memory vk = getVkAggregated(uint32(_vkIndexes.length));

        uint256 treeRoot = blockProof ? VK_TREE_ROOT : VK_EXIT_TREE_ROOT;

        return
            verify_serialized_proof_with_recursion(
                _recursiveInput,
                _proof,
                treeRoot,
                VK_MAX_INDEX,
                _vkIndexes,
                _individual_vks_inputs,
                _subproofs_limbs,
                vk
            );
    }
}pragma solidity ^0.7.0;







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
        ForcedExit,
        TransferFrom
    }


    uint8 constant OP_TYPE_BYTES = 1;

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

    uint256 public constant PACKED_DEPOSIT_PUBDATA_BYTES =
        OP_TYPE_BYTES + ACCOUNT_ID_BYTES + TOKEN_BYTES + AMOUNT_BYTES + ADDRESS_BYTES;

    function readDepositPubdata(bytes memory _data) internal pure returns (Deposit memory parsed) {

        uint256 offset = OP_TYPE_BYTES;
        (offset, parsed.accountId) = Bytes.readUInt32(_data, offset); // accountId
        (offset, parsed.tokenId) = Bytes.readUInt16(_data, offset); // tokenId
        (offset, parsed.amount) = Bytes.readUInt128(_data, offset); // amount
        (offset, parsed.owner) = Bytes.readAddress(_data, offset); // owner

        require(offset == PACKED_DEPOSIT_PUBDATA_BYTES, "rdp10"); // reading invalid deposit pubdata size
    }

    function writeDepositPubdata(Deposit memory op) internal pure returns (bytes memory buf) {

        buf = abi.encodePacked(
            uint8(OpType.Deposit),
            bytes4(0), // accountId (ignored) (update when ACCOUNT_ID_BYTES is changed)
            op.tokenId, // tokenId
            op.amount, // amount
            op.owner // owner
        );
    }

    function depositPubdataMatch(bytes memory _lhs, bytes memory _rhs) internal pure returns (bool) {

        uint256 skipBytes = ACCOUNT_ID_BYTES + OP_TYPE_BYTES;
        bytes memory lhs_trimmed = Bytes.slice(_lhs, skipBytes, PACKED_DEPOSIT_PUBDATA_BYTES - skipBytes);
        bytes memory rhs_trimmed = Bytes.slice(_rhs, skipBytes, PACKED_DEPOSIT_PUBDATA_BYTES - skipBytes);
        return keccak256(lhs_trimmed) == keccak256(rhs_trimmed);
    }


    struct FullExit {
        uint32 accountId;
        address owner;
        uint16 tokenId;
        uint128 amount;
    }

    uint256 public constant PACKED_FULL_EXIT_PUBDATA_BYTES =
        OP_TYPE_BYTES + ACCOUNT_ID_BYTES + ADDRESS_BYTES + TOKEN_BYTES + AMOUNT_BYTES;

    function readFullExitPubdata(bytes memory _data) internal pure returns (FullExit memory parsed) {

        uint256 offset = OP_TYPE_BYTES;
        (offset, parsed.accountId) = Bytes.readUInt32(_data, offset); // accountId
        (offset, parsed.owner) = Bytes.readAddress(_data, offset); // owner
        (offset, parsed.tokenId) = Bytes.readUInt16(_data, offset); // tokenId
        (offset, parsed.amount) = Bytes.readUInt128(_data, offset); // amount

        require(offset == PACKED_FULL_EXIT_PUBDATA_BYTES, "rfp10"); // reading invalid full exit pubdata size
    }

    function writeFullExitPubdata(FullExit memory op) internal pure returns (bytes memory buf) {

        buf = abi.encodePacked(
            uint8(OpType.FullExit),
            op.accountId, // accountId
            op.owner, // owner
            op.tokenId, // tokenId
            op.amount // amount
        );
    }

    function fullExitPubdataMatch(bytes memory _lhs, bytes memory _rhs) internal pure returns (bool) {

        uint256 lhs = Bytes.trim(_lhs, PACKED_FULL_EXIT_PUBDATA_BYTES - AMOUNT_BYTES);
        uint256 rhs = Bytes.trim(_rhs, PACKED_FULL_EXIT_PUBDATA_BYTES - AMOUNT_BYTES);
        return lhs == rhs;
    }


    struct PartialExit {
        uint16 tokenId;
        uint128 amount;
        address owner;
    }

    function readPartialExitPubdata(bytes memory _data) internal pure returns (PartialExit memory parsed) {

        uint256 offset = OP_TYPE_BYTES + ACCOUNT_ID_BYTES; // opType + accountId (ignored)
        (offset, parsed.tokenId) = Bytes.readUInt16(_data, offset); // tokenId
        (offset, parsed.amount) = Bytes.readUInt128(_data, offset); // amount
        offset += FEE_BYTES; // fee (ignored)
        (offset, parsed.owner) = Bytes.readAddress(_data, offset); // owner
    }


    struct ForcedExit {
        uint16 tokenId;
        uint128 amount;
        address target;
    }

    function readForcedExitPubdata(bytes memory _data) internal pure returns (ForcedExit memory parsed) {

        uint256 offset = OP_TYPE_BYTES + ACCOUNT_ID_BYTES * 2; // opType + initiatorAccountId + targetAccountId (ignored)
        (offset, parsed.tokenId) = Bytes.readUInt16(_data, offset); // tokenId
        (offset, parsed.amount) = Bytes.readUInt128(_data, offset); // amount
        offset += FEE_BYTES; // fee (ignored)
        (offset, parsed.target) = Bytes.readAddress(_data, offset); // target
    }


    enum ChangePubkeyType {ECRECOVER, CREATE2}

    struct ChangePubKey {
        uint32 accountId;
        bytes20 pubKeyHash;
        address owner;
        uint32 nonce;
    }

    function readChangePubKeyPubdata(bytes memory _data) internal pure returns (ChangePubKey memory parsed) {

        uint256 offset = OP_TYPE_BYTES;
        (offset, parsed.accountId) = Bytes.readUInt32(_data, offset); // accountId
        (offset, parsed.pubKeyHash) = Bytes.readBytes20(_data, offset); // pubKeyHash
        (offset, parsed.owner) = Bytes.readAddress(_data, offset); // owner
        (offset, parsed.nonce) = Bytes.readUInt32(_data, offset); // nonce
    }


    function readWithdrawalData(bytes memory _data, uint256 _offset)
        internal
        pure
        returns (
            bool _addToPendingWithdrawalsQueue,
            address _to,
            uint16 _tokenId,
            uint128 _amount
        )
    {

        uint256 offset = _offset;
        (offset, _addToPendingWithdrawalsQueue) = Bytes.readBool(_data, offset);
        (offset, _to) = Bytes.readAddress(_data, offset);
        (offset, _tokenId) = Bytes.readUInt16(_data, offset);
        (offset, _amount) = Bytes.readUInt128(_data, offset);
    }
}pragma solidity ^0.7.0;








contract Storage {

    bool public upgradePreparationActive;

    uint256 public upgradePreparationActivationTime;

    Verifier public verifier;

    Governance public governance;

    uint8 constant FILLED_GAS_RESERVE_VALUE = 0xff; // we use it to set gas revert value so slot will not be emptied with 0 balance
    struct BalanceToWithdraw {
        uint128 balanceToWithdraw;
        uint8 gasReserveValue; // gives user opportunity to fill storage slot with nonzero value
    }

    mapping(bytes22 => BalanceToWithdraw) public balancesToWithdraw;

    struct PendingWithdrawal_DEPRECATED {
        address to;
        uint16 tokenId;
    }
    mapping(uint32 => PendingWithdrawal_DEPRECATED) public pendingWithdrawals_DEPRECATED;
    uint32 public firstPendingWithdrawalIndex_DEPRECATED;
    uint32 public numberOfPendingWithdrawals_DEPRECATED;

    uint32 public totalBlocksVerified;

    uint32 public totalBlocksCommitted;

    struct Block_DEPRECATED {
        uint32 committedAtBlock;
        uint64 priorityOperations;
        uint32 chunks;
        bytes32 withdrawalsDataHash; // can be restricted to 16 bytes to reduce number of required storage slots
        bytes32 commitment;
        bytes32 stateRoot;
    }
    mapping(uint32 => Block_DEPRECATED) public blocks_DEPRECATED;

    struct OnchainOperation {
        Operations.OpType opType;
        bytes pubData;
    }

    mapping(uint32 => mapping(uint16 => bool)) public exited;

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

    struct StoredBlockInfo {
        uint32 blockNumber;
        uint64 priorityOperations;
        bytes32 pendingOnchainOperationsHash;
        uint256 timestamp;
        bytes32 stateHash;
        bytes32 commitment;
    }

    function hashStoredBlockInfo(StoredBlockInfo memory _storedBlockInfo) internal pure returns (bytes32) {

        return keccak256(abi.encode(_storedBlockInfo));
    }

    mapping(uint32 => bytes32) public storedBlockHashes;

    mapping(bytes32 => bool) public verifiedCommitmentHashes;
}pragma solidity ^0.7.0;





contract OperationsTest {

    function testDeposit() external pure returns (uint256, uint256) {

        Operations.Deposit memory x =
            Operations.Deposit({
                accountId: 0,
                tokenId: 0x0102,
                amount: 0x101112131415161718191a1b1c1d1e1f,
                owner: 0x823B747710C5bC9b8A47243f2c3d1805F1aA00c5
            });

        bytes memory pubdata = Operations.writeDepositPubdata(x);
        Operations.Deposit memory r = Operations.readDepositPubdata(pubdata);

        require(x.tokenId == r.tokenId, "tokenId mismatch");
        require(x.amount == r.amount, "amount mismatch");
        require(x.owner == r.owner, "owner mismatch");
    }

    function testDepositMatch(bytes calldata offchain) external pure returns (bool) {

        Operations.Deposit memory x =
            Operations.Deposit({
                accountId: 0,
                tokenId: 0x0102,
                amount: 0x101112131415161718191a1b1c1d1e1f,
                owner: 0x823B747710C5bC9b8A47243f2c3d1805F1aA00c5
            });
        bytes memory onchain = Operations.writeDepositPubdata(x);

        return Operations.depositPubdataMatch(onchain, offchain);
    }

    function testFullExit() external pure {

        Operations.FullExit memory x =
            Operations.FullExit({
                accountId: 0x01020304,
                owner: 0x823B747710C5bC9b8A47243f2c3d1805F1aA00c5,
                tokenId: 0x3132,
                amount: 0x101112131415161718191a1b1c1d1e1f
            });

        bytes memory pubdata = Operations.writeFullExitPubdata(x);
        Operations.FullExit memory r = Operations.readFullExitPubdata(pubdata);

        require(x.accountId == r.accountId, "accountId mismatch");
        require(x.owner == r.owner, "owner mismatch");
        require(x.tokenId == r.tokenId, "tokenId mismatch");
        require(x.amount == r.amount, "amount mismatch");
    }

    function testFullExitMatch(bytes calldata offchain) external pure returns (bool) {

        Operations.FullExit memory x =
            Operations.FullExit({
                accountId: 0x01020304,
                owner: 0x823B747710C5bC9b8A47243f2c3d1805F1aA00c5,
                tokenId: 0x3132,
                amount: 0
            });
        bytes memory onchain = Operations.writeFullExitPubdata(x);

        return Operations.fullExitPubdataMatch(onchain, offchain);
    }

    function writePartialExitPubdata(Operations.PartialExit memory op) internal pure returns (bytes memory buf) {

        buf = abi.encodePacked(
            uint8(Operations.OpType.PartialExit),
            bytes4(0), // accountId - ignored
            op.tokenId, // tokenId
            op.amount, // amount
            bytes2(0), // fee - ignored
            op.owner // owner
        );
    }

    function testPartialExit() external pure {

        Operations.PartialExit memory x =
            Operations.PartialExit({
                tokenId: 0x3132,
                amount: 0x101112131415161718191a1b1c1d1e1f,
                owner: 0x823B747710C5bC9b8A47243f2c3d1805F1aA00c5
            });

        bytes memory pubdata = writePartialExitPubdata(x);
        Operations.PartialExit memory r = Operations.readPartialExitPubdata(pubdata);

        require(x.owner == r.owner, "owner mismatch");
        require(x.tokenId == r.tokenId, "tokenId mismatch");
        require(x.amount == r.amount, "amount mismatch");
    }

    function writeForcedExitPubdata(Operations.ForcedExit memory op) internal pure returns (bytes memory buf) {

        buf = abi.encodePacked(
            uint8(Operations.OpType.ForcedExit),
            bytes4(0), // initator accountId - ignored
            bytes4(0), // target accountId - ignored
            op.tokenId, // tokenId
            op.amount, // amount
            bytes2(0), // fee - ignored
            op.target // owner
        );
    }

    function testForcedExit() external pure {

        Operations.ForcedExit memory x =
            Operations.ForcedExit({
                target: 0x823B747710C5bC9b8A47243f2c3d1805F1aA00c5,
                tokenId: 0x3132,
                amount: 0x101112131415161718191a1b1c1d1e1f
            });

        bytes memory pubdata = writeForcedExitPubdata(x);
        Operations.ForcedExit memory r = Operations.readForcedExitPubdata(pubdata);

        require(x.target == r.target, "target mismatch");
        require(x.tokenId == r.tokenId, "tokenId mismatch");
        require(x.amount == r.amount, "packed amount mismatch");
    }

    function parseDepositFromPubdata(bytes calldata _pubdata)
        external
        pure
        returns (
            uint16 tokenId,
            uint128 amount,
            address owner
        )
    {

        Operations.Deposit memory r = Operations.readDepositPubdata(_pubdata);
        return (r.tokenId, r.amount, r.owner);
    }

    function parseFullExitFromPubdata(bytes calldata _pubdata)
        external
        pure
        returns (
            uint32 accountId,
            address owner,
            uint16 tokenId,
            uint128 amount
        )
    {

        Operations.FullExit memory r = Operations.readFullExitPubdata(_pubdata);
        accountId = r.accountId;
        owner = r.owner;
        tokenId = r.tokenId;
        amount = r.amount;
    }
}pragma solidity ^0.7.0;




contract ReentrancyGuard {

    uint256 private constant LOCK_FLAG_ADDRESS = 0x8e94fed44239eb2314ab7a406345e6c5a8f0ccedf3b600de3d004e672c33abf4; // keccak256("ReentrancyGuard") - 1;

    function initializeReentrancyGuard() internal {

        assembly {
            sstore(LOCK_FLAG_ADDRESS, 1)
        }
    }

    modifier nonReentrant() {

        bool notEntered;
        assembly {
            notEntered := sload(LOCK_FLAG_ADDRESS)
        }

        require(notEntered, "ReentrancyGuard: reentrant call");

        assembly {
            sstore(LOCK_FLAG_ADDRESS, 0)
        }

        _;

        assembly {
            sstore(LOCK_FLAG_ADDRESS, 1)
        }
    }
}pragma solidity ^0.7.0;




library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}pragma solidity ^0.7.0;




library SafeMathUInt128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128) {

        uint128 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint128 a,
        uint128 b,
        string memory errorMessage
    ) internal pure returns (uint128) {

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

    function div(
        uint128 a,
        uint128 b,
        string memory errorMessage
    ) internal pure returns (uint128) {

        require(b > 0, errorMessage);
        uint128 c = a / b;

        return c;
    }

    function mod(uint128 a, uint128 b) internal pure returns (uint128) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint128 a,
        uint128 b,
        string memory errorMessage
    ) internal pure returns (uint128) {

        require(b != 0, errorMessage);
        return a % b;
    }
}pragma solidity ^0.7.0;




library SafeCast {

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }
}pragma solidity ^0.7.0;




interface Upgradeable {

    function upgradeTarget(address newTarget, bytes calldata newTargetInitializationParameters) external;

}pragma solidity ^0.7.0;





interface Events {

    event BlockCommit(uint32 indexed blockNumber);

    event BlockVerification(uint32 indexed blockNumber);

    event OnchainWithdrawal(address indexed owner, uint16 indexed tokenId, uint128 amount);

    event OnchainDeposit(address indexed sender, uint16 indexed tokenId, uint128 amount, address indexed owner);

    event FactAuth(address indexed sender, uint32 nonce, bytes fact);

    event BlocksRevert(uint32 totalBlocksVerified, uint32 totalBlocksCommitted);

    event ExodusMode();

    event NewPriorityRequest(
        address sender,
        uint64 serialId,
        Operations.OpType opType,
        bytes pubData,
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

    event PendingWithdrawalsAdd(uint32 queueStartIndex, uint32 queueEndIndex);

    event PendingWithdrawalsComplete(uint32 queueStartIndex, uint32 queueEndIndex);
}

interface UpgradeEvents {

    event NewUpgradable(uint256 indexed versionId, address indexed upgradeable);

    event NoticePeriodStart(
        uint256 indexed versionId,
        address[] newTargets,
        uint256 noticePeriod // notice period (in seconds)
    );

    event UpgradeCancel(uint256 indexed versionId);

    event PreparationStart(uint256 indexed versionId);

    event UpgradeComplete(uint256 indexed versionId, address[] newTargets);
}pragma solidity ^0.7.0;




interface UpgradeableMaster {

    function getNoticePeriod() external returns (uint256);


    function upgradeNoticePeriodStarted() external;


    function upgradePreparationStarted() external;


    function upgradeCanceled() external;


    function upgradeFinishes() external;


    function isReadyForUpgrade() external returns (bool);

}pragma solidity ^0.7.0;










contract ZkSync is UpgradeableMaster, Storage, Config, Events, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeMathUInt128 for uint128;

    bytes32 constant EMPTY_STRING_KECCAK = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    struct OnchainOperationData {
        uint32 publicDataOffset;
        bytes ethWitness;
    }

    struct CommitBlockInfo {
        uint32 blockNumber;
        uint32 feeAccount;
        bytes32 newStateHash;
        bytes publicData;
        uint256 timestamp;
        OnchainOperationData[] onchainOperations;
    }

    struct ExecuteBlockInfo {
        StoredBlockInfo storedBlock;
        bytes[] pendingOnchainOpsPubdata;
        bytes32[] commitmentsInSlot;
        uint256 commitmentIdx;
    }

    struct ProofInput {
        uint256[] recursiveInput;
        uint256[] proof;
        uint256[] commitments;
        uint8[] vkIndexes;
        uint256[16] subproofsLimbs;
    }


    function getNoticePeriod() external pure override returns (uint256) {

        return UPGRADE_NOTICE_PERIOD;
    }

    function upgradeNoticePeriodStarted() external override {}


    function upgradePreparationStarted() external override {

        upgradePreparationActive = true;
        upgradePreparationActivationTime = block.timestamp;
    }

    function upgradeCanceled() external override {

        upgradePreparationActive = false;
        upgradePreparationActivationTime = 0;
    }

    function upgradeFinishes() external override {

        upgradePreparationActive = false;
        upgradePreparationActivationTime = 0;
    }

    function isReadyForUpgrade() external view override returns (bool) {

        return !exodusMode;
    }

    function initialize(bytes calldata initializationParameters) external {

        initializeReentrancyGuard();

        (address _governanceAddress, address _verifierAddress, bytes32 _genesisStateHash) =
            abi.decode(initializationParameters, (address, address, bytes32));

        verifier = Verifier(_verifierAddress);
        governance = Governance(_governanceAddress);

        StoredBlockInfo memory storedBlockZero =
            StoredBlockInfo(0, 0, EMPTY_STRING_KECCAK, 0, _genesisStateHash, bytes32(0));

        storedBlockHashes[0] = hashStoredBlockInfo(storedBlockZero);
    }

    function upgrade(bytes calldata upgradeParameters) external {

        require(upgradeParameters.length == 0, "upg3"); // upgrade parameters should be empty

        require(totalBlocksCommitted == totalBlocksVerified, "upg1"); // all blocks should be verified
        require(numberOfPendingWithdrawals_DEPRECATED == 0, "upg4"); // pending withdrawal is not used anymore
        require(totalOpenPriorityRequests == 0, "upg5"); // no uncommitted priority requests

        Block_DEPRECATED memory lastBlock = blocks_DEPRECATED[totalBlocksVerified];
        require(lastBlock.priorityOperations == 0, "upg2"); // last block should not contain priority operations

        StoredBlockInfo memory rehashedLastBlock =
            StoredBlockInfo(
                totalBlocksVerified,
                lastBlock.priorityOperations,
                EMPTY_STRING_KECCAK,
                0,
                lastBlock.stateRoot,
                lastBlock.commitment
            );
        storedBlockHashes[totalBlocksVerified] = hashStoredBlockInfo(rehashedLastBlock);
    }

    function withdrawERC20Guarded(
        address _tokenAddress,
        address _to,
        uint128 _amount,
        uint128 _maxAmount
    ) external returns (uint128 withdrawnAmount) {

        require(msg.sender == address(this), "wtg10"); // wtg10 - can be called only from this contract as one "external" call (to revert all this function state changes if it is needed)
        IERC20 token = IERC20(_tokenAddress);

        uint256 balanceBefore = token.balanceOf(address(this));
        require(Utils.sendERC20(token, _to, _amount), "wtg11"); // wtg11 - ERC20 transfer fails
        uint256 balanceAfter = token.balanceOf(address(this));
        uint256 balanceDiff = balanceBefore.sub(balanceAfter);
        require(balanceDiff <= _maxAmount, "wtg12"); // wtg12 - rollup balance difference (before and after transfer) is bigger than _maxAmount

        return SafeCast.toUint128(balanceDiff);
    }

    function cancelOutstandingDepositsForExodusMode(uint64 _n) external nonReentrant {

        require(exodusMode, "coe01"); // exodus mode not active
        uint64 toProcess = Utils.minU64(totalOpenPriorityRequests, _n);
        require(toProcess > 0, "coe02"); // no deposits to process
        for (uint64 id = firstPriorityRequestId; id < firstPriorityRequestId + toProcess; id++) {
            if (priorityRequests[id].opType == Operations.OpType.Deposit) {
                Operations.Deposit memory op = Operations.readDepositPubdata(priorityRequests[id].pubData);
                bytes22 packedBalanceKey = packAddressAndTokenId(op.owner, op.tokenId);
                balancesToWithdraw[packedBalanceKey].balanceToWithdraw += op.amount;
            }
            delete priorityRequests[id];
        }
        firstPriorityRequestId += toProcess;
        totalOpenPriorityRequests -= toProcess;
    }

    function withdrawETH(uint128 _amount) external nonReentrant {

        registerWithdrawal(0, _amount, msg.sender);
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "fwe11"); // ETH withdraw failed
    }

    function depositETH(address _zkSyncAddress) external payable nonReentrant {

        requireActive();
        registerDeposit(0, SafeCast.toUint128(msg.value), _zkSyncAddress);
    }

    function depositERC20(
        IERC20 _token,
        uint104 _amount,
        address _zkSyncAddress
    ) external nonReentrant {

        requireActive();

        uint16 tokenId = governance.validateTokenAddress(address(_token));
        require(!governance.pausedTokens(tokenId), "fd011"); // token deposits are paused

        uint256 balanceBefore = _token.balanceOf(address(this));
        require(Utils.transferFromERC20(_token, msg.sender, address(this), SafeCast.toUint128(_amount)), "fd012"); // token transfer failed deposit
        uint256 balanceAfter = _token.balanceOf(address(this));
        uint128 depositAmount = SafeCast.toUint128(balanceAfter.sub(balanceBefore));

        registerDeposit(tokenId, depositAmount, _zkSyncAddress);
    }

    function withdrawERC20(address _token, uint128 _amount) external nonReentrant {

        uint16 tokenId = governance.validateTokenAddress(_token);
        bytes22 packedBalanceKey = packAddressAndTokenId(msg.sender, tokenId);
        uint128 balance = balancesToWithdraw[packedBalanceKey].balanceToWithdraw;
        uint128 withdrawnAmount = this.withdrawERC20Guarded(_token, msg.sender, _amount, balance);
        registerWithdrawal(tokenId, withdrawnAmount, msg.sender);
    }

    function fullExit(uint32 _accountId, address _token) external nonReentrant {

        requireActive();
        require(_accountId <= MAX_ACCOUNT_ID, "fee11");

        uint16 tokenId;
        if (_token == address(0)) {
            tokenId = 0;
        } else {
            tokenId = governance.validateTokenAddress(_token);
        }

        Operations.FullExit memory op =
            Operations.FullExit({
                accountId: _accountId,
                owner: msg.sender,
                tokenId: tokenId,
                amount: 0 // unknown at this point
            });
        bytes memory pubData = Operations.writeFullExitPubdata(op);
        addPriorityRequest(Operations.OpType.FullExit, pubData);

        bytes22 packedBalanceKey = packAddressAndTokenId(msg.sender, tokenId);
        balancesToWithdraw[packedBalanceKey].gasReserveValue = FILLED_GAS_RESERVE_VALUE;
    }

    function commitOneBlock(StoredBlockInfo memory _previousBlock, CommitBlockInfo memory _newBlock)
        internal
        returns (StoredBlockInfo memory storedNewBlock)
    {

        require(_newBlock.blockNumber == _previousBlock.blockNumber + 1, "fck11"); // only commit next block

        {
            require(_newBlock.timestamp >= _previousBlock.timestamp, "tms11"); // Block should be after previous block
            bool timestampNotTooSmall = block.timestamp - COMMIT_TIMESTAMP_NOT_OLDER <= _newBlock.timestamp;
            bool timestampNotTooBig = _newBlock.timestamp <= block.timestamp + COMMIT_TIMESTAMP_APPROXIMATION_DELTA;
            require(timestampNotTooSmall && timestampNotTooBig, "tms12"); // New block timestamp is not valid
        }

        (bytes32 pendingOnchainOpsHash, uint64 priorityReqCommitted, bytes memory onchainOpsOffsetCommitment) =
            collectOnchainOps(_newBlock);

        bytes32 commitment = createBlockCommitment(_previousBlock, _newBlock, onchainOpsOffsetCommitment);

        return
            StoredBlockInfo(
                _newBlock.blockNumber,
                priorityReqCommitted,
                pendingOnchainOpsHash,
                _newBlock.timestamp,
                _newBlock.newStateHash,
                commitment
            );
    }

    function commitBlocks(StoredBlockInfo memory _lastCommittedBlockData, CommitBlockInfo[] memory _newBlocksData)
        external
        nonReentrant
    {

        requireActive();
        governance.requireActiveValidator(msg.sender);
        require(storedBlockHashes[totalBlocksCommitted] == hashStoredBlockInfo(_lastCommittedBlockData), "fck10"); // incorrect previous block data

        StoredBlockInfo memory lastCommittedBlock = _lastCommittedBlockData;

        uint64 committedPriorityRequests = 0;
        for (uint32 i = 0; i < _newBlocksData.length; ++i) {
            lastCommittedBlock = commitOneBlock(lastCommittedBlock, _newBlocksData[i]);

            committedPriorityRequests += lastCommittedBlock.priorityOperations;
            storedBlockHashes[lastCommittedBlock.blockNumber] = hashStoredBlockInfo(lastCommittedBlock);

            emit BlockCommit(lastCommittedBlock.blockNumber);
        }

        totalBlocksCommitted += uint32(_newBlocksData.length);

        totalCommittedPriorityRequests += committedPriorityRequests;
        require(totalCommittedPriorityRequests <= totalOpenPriorityRequests, "fck11");
    }

    function withdrawOrStore(
        uint16 _tokenId,
        address _recipient,
        uint128 _amount
    ) internal {

        bytes22 packedBalanceKey = packAddressAndTokenId(_recipient, _tokenId);

        bool sent = false;
        if (_tokenId == 0) {
            address payable toPayable = address(uint160(_recipient));
            sent = Utils.sendETHNoRevert(toPayable, _amount);
        } else {
            address tokenAddr = governance.tokenAddresses(_tokenId);
            try this.withdrawERC20Guarded{gas: ERC20_WITHDRAWAL_GAS_LIMIT}(tokenAddr, _recipient, _amount, _amount) {
                sent = true;
            } catch {
                sent = false;
            }
        }
        if (!sent) {
            increaseBalanceToWithdraw(packedBalanceKey, _amount);
        }
    }

    function executeOneBlock(ExecuteBlockInfo memory _blockExecuteData, uint32 _executedBlockIdx)
        internal
        returns (uint32 priorityRequestsExecuted)
    {
        require(
            hashStoredBlockInfo(_blockExecuteData.storedBlock) ==
                storedBlockHashes[_blockExecuteData.storedBlock.blockNumber],
            "exe10" // executing block should be committed
        );
        require(_blockExecuteData.storedBlock.blockNumber == totalBlocksVerified + _executedBlockIdx + 1, "exe11"); // Execute blocks in order
        require(_blockExecuteData.storedBlock.blockNumber <= totalBlocksCommitted, "exe03"); // Can't execute blocks more then committed currently.
        require(
            openAndCheckCommitmentInSlot(
                _blockExecuteData.storedBlock.commitment,
                _blockExecuteData.commitmentsInSlot,
                _blockExecuteData.commitmentIdx
            ),
            "exe12"
        ); // block is verified

        priorityRequestsExecuted = 0;
        bytes32 pendingOnchainOpsHash = EMPTY_STRING_KECCAK;
        for (uint32 i = 0; i < _blockExecuteData.pendingOnchainOpsPubdata.length; ++i) {
            bytes memory pubData = _blockExecuteData.pendingOnchainOpsPubdata[i];

            Operations.OpType opType = Operations.OpType(uint8(pubData[0]));

            if (opType == Operations.OpType.Deposit) {
                ++priorityRequestsExecuted;
            } else if (opType == Operations.OpType.PartialExit) {
                Operations.PartialExit memory op = Operations.readPartialExitPubdata(pubData);
                withdrawOrStore(op.tokenId, op.owner, op.amount);
            } else if (opType == Operations.OpType.ForcedExit) {
                Operations.ForcedExit memory op = Operations.readForcedExitPubdata(pubData);
                withdrawOrStore(op.tokenId, op.target, op.amount);
            } else if (opType == Operations.OpType.FullExit) {
                Operations.FullExit memory op = Operations.readFullExitPubdata(pubData);
                withdrawOrStore(op.tokenId, op.owner, op.amount);

                ++priorityRequestsExecuted;
            } else {
                revert("exe13"); // unsupported op in block execution
            }

            pendingOnchainOpsHash = Utils.concatHash(pendingOnchainOpsHash, pubData);
        }
        require(pendingOnchainOpsHash == _blockExecuteData.storedBlock.pendingOnchainOperationsHash, "exe13"); // incorrect onchain ops executed
    }

    function executeBlocks(ExecuteBlockInfo[] memory _blocksData) external nonReentrant {
        requireActive();
        governance.requireActiveValidator(msg.sender);

        uint32 priorityRequestsExecuted = 0;
        uint32 nBlocks = uint32(_blocksData.length);
        for (uint32 i = 0; i < nBlocks; ++i) {
            priorityRequestsExecuted += executeOneBlock(_blocksData[i], i);
            emit BlockVerification(_blocksData[i].storedBlock.blockNumber);
        }

        firstPriorityRequestId += priorityRequestsExecuted;
        totalCommittedPriorityRequests -= priorityRequestsExecuted;
        totalOpenPriorityRequests -= priorityRequestsExecuted;

        totalBlocksVerified += nBlocks;
    }

    function verifyCommitments(ProofInput memory _proof) external nonReentrant {
        bool success =
            verifier.verifyAggregatedProof(
                _proof.recursiveInput,
                _proof.proof,
                _proof.vkIndexes,
                _proof.commitments,
                _proof.subproofsLimbs,
                true
            );

        require(success, "vf1"); // Aggregated proof verification fail

        verifiedCommitmentHashes[keccak256(abi.encode(_proof.commitments))] = true;
    }

    function revertBlocks(StoredBlockInfo[] memory _blocksToRevert) external nonReentrant {
        governance.requireActiveValidator(msg.sender);

        uint32 blocksCommitted = totalBlocksCommitted;
        uint32 blocksToRevert = Utils.minU32(uint32(_blocksToRevert.length), blocksCommitted - totalBlocksVerified);
        uint64 revertedPriorityRequests = 0;

        for (uint32 i = 0; i < blocksToRevert; ++i) {
            StoredBlockInfo memory storedBlockInfo = _blocksToRevert[i];
            require(storedBlockHashes[blocksCommitted] == hashStoredBlockInfo(storedBlockInfo), "frk10"); // incorrect stored block info

            delete storedBlockHashes[blocksCommitted];

            --blocksCommitted;
            revertedPriorityRequests += storedBlockInfo.priorityOperations;
        }

        totalBlocksCommitted = blocksCommitted;
        totalCommittedPriorityRequests -= revertedPriorityRequests;

        emit BlocksRevert(totalBlocksVerified, blocksCommitted);
    }

    function triggerExodusIfNeeded() external returns (bool) {
        bool trigger =
            block.number >= priorityRequests[firstPriorityRequestId].expirationBlock &&
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

    function exit(
        StoredBlockInfo memory _storedBlockInfo,
        uint32 _accountId,
        uint16 _tokenId,
        uint128 _amount,
        ProofInput memory _proof
    ) external nonReentrant {
        bytes22 packedBalanceKey = packAddressAndTokenId(msg.sender, _tokenId);
        require(exodusMode, "fet11"); // must be in exodus mode
        require(!exited[_accountId][_tokenId], "fet12"); // already exited
        require(storedBlockHashes[totalBlocksVerified] == hashStoredBlockInfo(_storedBlockInfo), "fet13"); // incorrect sotred block info

        uint256 commitment =
            uint256(sha256(abi.encodePacked(_storedBlockInfo.stateHash, _accountId, msg.sender, _tokenId, _amount)));
        require(_proof.commitments.length == 1, "fet15");
        uint256 mask = (~uint256(0)) >> 3;
        commitment = commitment & mask;
        require(_proof.commitments[0] == commitment, "fet14");

        bool proofCorrect =
            verifier.verifyAggregatedProof(
                _proof.recursiveInput,
                _proof.proof,
                _proof.vkIndexes,
                _proof.commitments,
                _proof.subproofsLimbs,
                false
            );
        require(proofCorrect, "fet13");

        increaseBalanceToWithdraw(packedBalanceKey, _amount);
        exited[_accountId][_tokenId] = true;
    }

    function setAuthPubkeyHash(bytes calldata _pubkey_hash, uint32 _nonce) external nonReentrant {
        require(_pubkey_hash.length == PUBKEY_HASH_BYTES, "ahf10"); // PubKeyHash should be 20 bytes.
        require(authFacts[msg.sender][_nonce] == bytes32(0), "ahf11"); // auth fact for nonce should be empty

        authFacts[msg.sender][_nonce] = keccak256(_pubkey_hash);

        emit FactAuth(msg.sender, _nonce, _pubkey_hash);
    }

    function registerDeposit(
        uint16 _tokenId,
        uint128 _amount,
        address _owner
    ) internal {
        Operations.Deposit memory op =
            Operations.Deposit({
                accountId: 0, // unknown at this point
                owner: _owner,
                tokenId: _tokenId,
                amount: _amount
            });
        bytes memory pubData = Operations.writeDepositPubdata(op);
        addPriorityRequest(Operations.OpType.Deposit, pubData);

        emit OnchainDeposit(msg.sender, _tokenId, _amount, _owner);
    }

    function registerWithdrawal(
        uint16 _token,
        uint128 _amount,
        address payable _to
    ) internal {
        bytes22 packedBalanceKey = packAddressAndTokenId(_to, _token);
        uint128 balance = balancesToWithdraw[packedBalanceKey].balanceToWithdraw;
        balancesToWithdraw[packedBalanceKey].balanceToWithdraw = balance.sub(_amount);
        emit OnchainWithdrawal(_to, _token, _amount);
    }

    function emitDepositCommitEvent(uint32 _blockNumber, Operations.Deposit memory depositData) internal {
        emit DepositCommit(
            _blockNumber,
            depositData.accountId,
            depositData.owner,
            depositData.tokenId,
            depositData.amount
        );
    }

    function emitFullExitCommitEvent(uint32 _blockNumber, Operations.FullExit memory fullExitData) internal {
        emit FullExitCommit(
            _blockNumber,
            fullExitData.accountId,
            fullExitData.owner,
            fullExitData.tokenId,
            fullExitData.amount
        );
    }

    function collectOnchainOps(CommitBlockInfo memory _newBlockData)
        internal
        returns (
            bytes32 processableOperationsHash,
            uint64 priorityOperationsProcessed,
            bytes memory offsetsCommitment
        )
    {
        bytes memory pubData = _newBlockData.publicData;

        uint64 uncommittedPriorityRequestsOffset = firstPriorityRequestId + totalCommittedPriorityRequests;
        priorityOperationsProcessed = 0;
        processableOperationsHash = EMPTY_STRING_KECCAK;

        require(pubData.length % CHUNK_BYTES == 0, "fcs11"); // pubdata length must be a multiple of CHUNK_BYTES
        offsetsCommitment = new bytes(pubData.length / CHUNK_BYTES);
        for (uint32 i = 0; i < _newBlockData.onchainOperations.length; ++i) {
            OnchainOperationData memory onchainOpData = _newBlockData.onchainOperations[i];

            uint256 pubdataOffset = onchainOpData.publicDataOffset;
            require(pubdataOffset % CHUNK_BYTES == 0, "fcso2"); // offsets should be on chunks boundaries
            require(offsetsCommitment[pubdataOffset / CHUNK_BYTES] == 0x00, "fcso3"); // offset commitment should be empty
            offsetsCommitment[pubdataOffset / CHUNK_BYTES] = bytes1(0x01);

            Operations.OpType opType = Operations.OpType(uint8(pubData[pubdataOffset]));

            if (opType == Operations.OpType.Deposit) {
                bytes memory opPubData = Bytes.slice(pubData, pubdataOffset, DEPOSIT_BYTES);

                Operations.Deposit memory depositData = Operations.readDepositPubdata(opPubData);
                emitDepositCommitEvent(_newBlockData.blockNumber, depositData);

                OnchainOperation memory onchainOp = OnchainOperation(Operations.OpType.Deposit, opPubData);
                commitNextPriorityOperation(onchainOp, uncommittedPriorityRequestsOffset + priorityOperationsProcessed);
                priorityOperationsProcessed++;

                processableOperationsHash = Utils.concatHash(processableOperationsHash, opPubData);
            } else if (opType == Operations.OpType.PartialExit) {
                bytes memory opPubData = Bytes.slice(pubData, pubdataOffset, PARTIAL_EXIT_BYTES);

                processableOperationsHash = Utils.concatHash(processableOperationsHash, opPubData);
            } else if (opType == Operations.OpType.ForcedExit) {
                bytes memory opPubData = Bytes.slice(pubData, pubdataOffset, FORCED_EXIT_BYTES);

                processableOperationsHash = Utils.concatHash(processableOperationsHash, opPubData);
            } else if (opType == Operations.OpType.FullExit) {
                bytes memory opPubData = Bytes.slice(pubData, pubdataOffset, FULL_EXIT_BYTES);

                Operations.FullExit memory fullExitData = Operations.readFullExitPubdata(opPubData);
                emitFullExitCommitEvent(_newBlockData.blockNumber, fullExitData);

                OnchainOperation memory onchainOp = OnchainOperation(Operations.OpType.FullExit, opPubData);
                commitNextPriorityOperation(onchainOp, uncommittedPriorityRequestsOffset + priorityOperationsProcessed);
                priorityOperationsProcessed++;

                processableOperationsHash = Utils.concatHash(processableOperationsHash, opPubData);
            } else if (opType == Operations.OpType.ChangePubKey) {
                bytes memory opPubData = Bytes.slice(pubData, pubdataOffset, CHANGE_PUBKEY_BYTES);

                Operations.ChangePubKey memory op = Operations.readChangePubKeyPubdata(opPubData);

                if (onchainOpData.ethWitness.length != 0) {
                    bool valid = verifyChangePubkey(onchainOpData.ethWitness, op);
                    require(valid, "fpp15"); // failed to verify change pubkey hash signature
                } else {
                    bool valid = authFacts[op.owner][op.nonce] == keccak256(abi.encodePacked(op.pubKeyHash));
                    require(valid, "fpp16"); // new pub key hash is not authenticated properly
                }
            } else {
                revert("fpp14"); // unsupported op
            }
        }
    }

    function verifyChangePubkey(bytes memory _ethWitness, Operations.ChangePubKey memory _changePk)
        internal
        pure
        returns (bool)
    {
        Operations.ChangePubkeyType changePkType = Operations.ChangePubkeyType(uint8(_ethWitness[0]));
        if (changePkType == Operations.ChangePubkeyType.ECRECOVER) {
            return verifyChangePubkeyECRECOVER(_ethWitness, _changePk);
        } else if (changePkType == Operations.ChangePubkeyType.CREATE2) {
            return verifyChangePubkeyCREATE2(_ethWitness, _changePk);
        } else {
            revert("chp13"); // Incorrect ChangePubKey type
        }
    }

    function verifyChangePubkeyECRECOVER(bytes memory _ethWitness, Operations.ChangePubKey memory _changePk)
        internal
        pure
        returns (bool)
    {
        (uint256 offset, bytes memory signature) = Bytes.read(_ethWitness, 1, 65); // offset is 1 because we skip type of ChangePubkey
        (, bytes32 additionalData) = Bytes.readBytes32(_ethWitness, offset);
        bytes32 messageHash =
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n60",
                    _changePk.pubKeyHash,
                    _changePk.nonce,
                    _changePk.accountId,
                    additionalData
                )
            );
        address recoveredAddress = Utils.recoverAddressFromEthSignature(signature, messageHash);
        return recoveredAddress == _changePk.owner;
    }

    function verifyChangePubkeyCREATE2(bytes memory _ethWitness, Operations.ChangePubKey memory _changePk)
        internal
        pure
        returns (bool)
    {
        address creatorAddress;
        bytes32 saltArg; // salt arg is additional bytes that are encoded in the CREATE2 salt
        bytes32 codeHash;
        uint256 offset = 1; // offset is 1 because we skip type of ChangePubkey
        (offset, creatorAddress) = Bytes.readAddress(_ethWitness, offset);
        (offset, saltArg) = Bytes.readBytes32(_ethWitness, offset);
        (offset, codeHash) = Bytes.readBytes32(_ethWitness, offset);
        bytes32 salt = keccak256(abi.encodePacked(_changePk.pubKeyHash, saltArg));
        address recoveredAddress =
            address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), creatorAddress, salt, codeHash)))));
        return recoveredAddress == _changePk.owner && _changePk.nonce == 0;
    }

    function createBlockCommitment(
        StoredBlockInfo memory _previousBlock,
        CommitBlockInfo memory _newBlockData,
        bytes memory _offsetCommitment
    ) internal view returns (bytes32 commitment) {
        bytes32 hash = sha256(abi.encodePacked(uint256(_newBlockData.blockNumber), uint256(_newBlockData.feeAccount)));
        hash = sha256(abi.encodePacked(hash, _previousBlock.stateHash));
        hash = sha256(abi.encodePacked(hash, _newBlockData.newStateHash));
        hash = sha256(abi.encodePacked(hash, uint256(_newBlockData.timestamp)));

        bytes memory pubdata = abi.encodePacked(_newBlockData.publicData, _offsetCommitment);



        assembly {
            let hashResult := mload(0x40)
            let pubDataLen := mload(pubdata)
            mstore(pubdata, hash)
            let success := staticcall(gas(), 0x2, pubdata, add(pubDataLen, 0x20), hashResult, 0x20)
            mstore(pubdata, pubDataLen)

            switch success
                case 0 {
                    invalid()
                }

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
        } else {
            revert("vnp15"); // invalid or non-priority operation
        }
    }

    function requireActive() internal view {
        require(!exodusMode, "fre11"); // exodus mode activated
    }


    function addPriorityRequest(Operations.OpType _opType, bytes memory _pubData) internal {
        uint256 expirationBlock = block.number + PRIORITY_EXPIRATION;

        uint64 nextPriorityRequestId = firstPriorityRequestId + totalOpenPriorityRequests;

        priorityRequests[nextPriorityRequestId] = PriorityOperation({
            opType: _opType,
            pubData: _pubData,
            expirationBlock: expirationBlock
        });

        emit NewPriorityRequest(msg.sender, nextPriorityRequestId, _opType, _pubData, expirationBlock);

        totalOpenPriorityRequests++;
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

    function increaseBalanceToWithdraw(bytes22 _packedBalanceKey, uint128 _amount) internal {
        uint128 balance = balancesToWithdraw[_packedBalanceKey].balanceToWithdraw;
        balancesToWithdraw[_packedBalanceKey] = BalanceToWithdraw(balance.add(_amount), FILLED_GAS_RESERVE_VALUE);
    }

    function openAndCheckCommitmentInSlot(
        bytes32 _commitment,
        bytes32[] memory _commitments,
        uint256 _idx
    ) internal view returns (bool) {
        bool commitmentsAreVerified = verifiedCommitmentHashes[keccak256(abi.encode(_commitments))];
        return commitmentsAreVerified && _commitments[_idx] == _commitment;
    }
}pragma solidity ^0.7.0;






contract ZkSyncWithdrawalUnitTest is ZkSync {

    function setBalanceToWithdraw(
        address _owner,
        uint16 _token,
        uint128 _amount
    ) external {

        balancesToWithdraw[packAddressAndTokenId(_owner, _token)].balanceToWithdraw = _amount;
    }

    function receiveETH() external payable {}


    function withdrawOrStoreExternal(
        uint16 _tokenId,
        address _recipient,
        uint128 _amount
    ) external {

        return withdrawOrStore(_tokenId, _recipient, _amount);
    }
}pragma solidity ^0.7.0;







contract ZKSyncSignatureUnitTest is ZkSync {

    function changePubkeySignatureCheck(
        bytes calldata _signature,
        bytes20 _newPkHash,
        uint32 _nonce,
        address _ethAddress,
        uint24 _accountId
    ) external pure returns (bool) {

        Operations.ChangePubKey memory changePk;
        changePk.owner = _ethAddress;
        changePk.nonce = _nonce;
        changePk.pubKeyHash = _newPkHash;
        changePk.accountId = _accountId;
        bytes memory witness = abi.encodePacked(bytes1(0x01), _signature, bytes32(0));
        return verifyChangePubkeyECRECOVER(witness, changePk);
    }

    function testRecoverAddressFromEthSignature(bytes calldata _signature, bytes32 _messageHash)
        external
        pure
        returns (address)
    {

        return Utils.recoverAddressFromEthSignature(_signature, _messageHash);
    }
}pragma solidity ^0.7.0;







contract ZkSyncProcessOpUnitTest is ZkSync {

    function collectOnchainOpsExternal(
        CommitBlockInfo memory _newBlockData,
        bytes32 processableOperationsHash,
        uint64 priorityOperationsProcessed,
        bytes memory offsetsCommitment
    ) external {

        (bytes32 resOpHash, uint64 resPriorOps, bytes memory resOffsetsCommitment) = collectOnchainOps(_newBlockData);
        require(resOpHash == processableOperationsHash, "hash");
        require(resPriorOps == priorityOperationsProcessed, "prop");
        require(keccak256(resOffsetsCommitment) == keccak256(offsetsCommitment), "offComm");
    }

    function commitPriorityRequests() external {

        totalCommittedPriorityRequests = totalOpenPriorityRequests;
    }
}pragma solidity ^0.7.0;





interface DummyTarget {

    function get_DUMMY_INDEX() external pure returns (uint256);


    function initialize(bytes calldata initializationParameters) external;


    function upgrade(bytes calldata upgradeParameters) external;


    function verifyPriorityOperation() external;

}

contract DummyFirst is UpgradeableMaster, DummyTarget {

    uint256 constant UPGRADE_NOTICE_PERIOD = 4;

    function get_UPGRADE_NOTICE_PERIOD() external pure returns (uint256) {

        return UPGRADE_NOTICE_PERIOD;
    }

    function getNoticePeriod() external pure override returns (uint256) {

        return UPGRADE_NOTICE_PERIOD;
    }

    function upgradeNoticePeriodStarted() external override {}


    function upgradePreparationStarted() external override {}


    function upgradeCanceled() external override {}


    function upgradeFinishes() external override {}


    function isReadyForUpgrade() external view override returns (bool) {

        return totalVerifiedPriorityOperations() >= totalRegisteredPriorityOperations();
    }

    uint256 private constant DUMMY_INDEX = 1;

    function get_DUMMY_INDEX() external pure override returns (uint256) {

        return DUMMY_INDEX;
    }

    uint64 _verifiedPriorityOperations;

    function initialize(bytes calldata initializationParameters) external override {

        bytes32 byte_0 = bytes32(uint256(uint8(initializationParameters[0])));
        bytes32 byte_1 = bytes32(uint256(uint8(initializationParameters[1])));
        assembly {
            sstore(1, byte_0)
            sstore(2, byte_1)
        }
    }

    function upgrade(bytes calldata upgradeParameters) external override {}


    function totalVerifiedPriorityOperations() internal view returns (uint64) {

        return _verifiedPriorityOperations;
    }

    function totalRegisteredPriorityOperations() internal pure returns (uint64) {

        return 1;
    }

    function verifyPriorityOperation() external override {

        _verifiedPriorityOperations++;
    }
}

contract DummySecond is UpgradeableMaster, DummyTarget {

    uint256 constant UPGRADE_NOTICE_PERIOD = 4;

    function get_UPGRADE_NOTICE_PERIOD() external pure returns (uint256) {

        return UPGRADE_NOTICE_PERIOD;
    }

    function getNoticePeriod() external pure override returns (uint256) {

        return UPGRADE_NOTICE_PERIOD;
    }

    function upgradeNoticePeriodStarted() external override {}


    function upgradePreparationStarted() external override {}


    function upgradeCanceled() external override {}


    function upgradeFinishes() external override {}


    function isReadyForUpgrade() external view override returns (bool) {

        return totalVerifiedPriorityOperations() >= totalRegisteredPriorityOperations();
    }

    uint256 private constant DUMMY_INDEX = 2;

    function get_DUMMY_INDEX() external pure override returns (uint256) {

        return DUMMY_INDEX;
    }

    uint64 _verifiedPriorityOperations;

    function initialize(bytes calldata) external pure override {

        revert("dsini");
    }

    function upgrade(bytes calldata upgradeParameters) external override {

        bytes32 byte_0 = bytes32(uint256(uint8(upgradeParameters[0])));
        bytes32 byte_1 = bytes32(uint256(uint8(upgradeParameters[1])));
        assembly {
            sstore(2, byte_0)
            sstore(3, byte_1)
        }
    }

    function totalVerifiedPriorityOperations() internal view returns (uint64) {

        return _verifiedPriorityOperations;
    }

    function totalRegisteredPriorityOperations() internal pure returns (uint64) {

        return 0;
    }

    function verifyPriorityOperation() external override {

        _verifiedPriorityOperations++;
    }
}pragma solidity ^0.7.0;




contract Ownable {

    bytes32 private constant masterPosition = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    constructor(address masterAddress) {
        setMaster(masterAddress);
    }

    function requireMaster(address _address) internal view {

        require(_address == getMaster(), "oro11"); // oro11 - only by master
    }

    function getMaster() public view returns (address master) {

        bytes32 position = masterPosition;
        assembly {
            master := sload(position)
        }
    }

    function setMaster(address _newMaster) internal {

        bytes32 position = masterPosition;
        assembly {
            sstore(position, _newMaster)
        }
    }

    function transferMastership(address _newMaster) external {

        requireMaster(msg.sender);
        require(_newMaster != address(0), "otp11"); // otp11 - new masters address can't be zero address
        setMaster(_newMaster);
    }
}pragma solidity ^0.7.0;






contract UpgradeGatekeeper is UpgradeEvents, Ownable {

    using SafeMath for uint256;

    Upgradeable[] public managedContracts;

    enum UpgradeStatus {Idle, NoticePeriod, Preparation}

    UpgradeStatus public upgradeStatus;

    uint256 public noticePeriodFinishTimestamp;

    address[] public nextTargets;

    uint256 public versionId;

    UpgradeableMaster public mainContract;

    constructor(UpgradeableMaster _mainContract) Ownable(msg.sender) {
        mainContract = _mainContract;
        versionId = 0;
    }

    function addUpgradeable(address addr) external {

        requireMaster(msg.sender);
        require(upgradeStatus == UpgradeStatus.Idle, "apc11"); /// apc11 - upgradeable contract can't be added during upgrade

        managedContracts.push(Upgradeable(addr));
        emit NewUpgradable(versionId, addr);
    }

    function startUpgrade(address[] calldata newTargets) external {

        requireMaster(msg.sender);
        require(upgradeStatus == UpgradeStatus.Idle, "spu11"); // spu11 - unable to activate active upgrade mode
        require(newTargets.length == managedContracts.length, "spu12"); // spu12 - number of new targets must be equal to the number of managed contracts

        uint256 noticePeriod = mainContract.getNoticePeriod();
        mainContract.upgradeNoticePeriodStarted();
        upgradeStatus = UpgradeStatus.NoticePeriod;
        noticePeriodFinishTimestamp = block.timestamp.add(noticePeriod);
        nextTargets = newTargets;
        emit NoticePeriodStart(versionId, newTargets, noticePeriod);
    }

    function cancelUpgrade() external {

        requireMaster(msg.sender);
        require(upgradeStatus != UpgradeStatus.Idle, "cpu11"); // cpu11 - unable to cancel not active upgrade mode

        mainContract.upgradeCanceled();
        upgradeStatus = UpgradeStatus.Idle;
        noticePeriodFinishTimestamp = 0;
        delete nextTargets;
        emit UpgradeCancel(versionId);
    }

    function startPreparation() external returns (bool) {

        requireMaster(msg.sender);
        require(upgradeStatus == UpgradeStatus.NoticePeriod, "ugp11"); // ugp11 - unable to activate preparation status in case of not active notice period status

        if (block.timestamp >= noticePeriodFinishTimestamp) {
            upgradeStatus = UpgradeStatus.Preparation;
            mainContract.upgradePreparationStarted();
            emit PreparationStart(versionId);
            return true;
        } else {
            return false;
        }
    }

    function finishUpgrade(bytes[] calldata targetsUpgradeParameters) external {

        requireMaster(msg.sender);
        require(upgradeStatus == UpgradeStatus.Preparation, "fpu11"); // fpu11 - unable to finish upgrade without preparation status active
        require(targetsUpgradeParameters.length == managedContracts.length, "fpu12"); // fpu12 - number of new targets upgrade parameters must be equal to the number of managed contracts
        require(mainContract.isReadyForUpgrade(), "fpu13"); // fpu13 - main contract is not ready for upgrade
        mainContract.upgradeFinishes();

        for (uint64 i = 0; i < managedContracts.length; i++) {
            address newTarget = nextTargets[i];
            if (newTarget != address(0)) {
                managedContracts[i].upgradeTarget(newTarget, targetsUpgradeParameters[i]);
            }
        }
        versionId++;
        emit UpgradeComplete(versionId, nextTargets);

        upgradeStatus = UpgradeStatus.Idle;
        noticePeriodFinishTimestamp = 0;
        delete nextTargets;
    }
}pragma solidity ^0.7.0;





contract Proxy is Upgradeable, UpgradeableMaster, Ownable {

    bytes32 private constant targetPosition = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address target, bytes memory targetInitializationParameters) Ownable(msg.sender) {
        setTarget(target);
        (bool initializationSuccess, ) =
            getTarget().delegatecall(abi.encodeWithSignature("initialize(bytes)", targetInitializationParameters));
        require(initializationSuccess, "uin11"); // uin11 - target initialization failed
    }

    function initialize(bytes calldata) external pure {

        revert("ini11"); // ini11 - interception of initialization call
    }

    function upgrade(bytes calldata) external pure {

        revert("upg11"); // upg11 - interception of upgrade call
    }

    function getTarget() public view returns (address target) {

        bytes32 position = targetPosition;
        assembly {
            target := sload(position)
        }
    }

    function setTarget(address _newTarget) internal {

        bytes32 position = targetPosition;
        assembly {
            sstore(position, _newTarget)
        }
    }

    function upgradeTarget(address newTarget, bytes calldata newTargetUpgradeParameters) external override {

        requireMaster(msg.sender);

        setTarget(newTarget);
        (bool upgradeSuccess, ) =
            getTarget().delegatecall(abi.encodeWithSignature("upgrade(bytes)", newTargetUpgradeParameters));
        require(upgradeSuccess, "ufu11"); // ufu11 - target upgrade failed
    }

    function _fallback() internal {

        address _target = getTarget();
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0x0, calldatasize())
            let result := delegatecall(gas(), _target, ptr, calldatasize(), 0x0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0x0, size)
            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }


    function getNoticePeriod() external override returns (uint256) {

        (bool success, bytes memory result) = getTarget().delegatecall(abi.encodeWithSignature("getNoticePeriod()"));
        require(success, "unp11"); // unp11 - upgradeNoticePeriod delegatecall failed
        return abi.decode(result, (uint256));
    }

    function upgradeNoticePeriodStarted() external override {

        requireMaster(msg.sender);
        (bool success, ) = getTarget().delegatecall(abi.encodeWithSignature("upgradeNoticePeriodStarted()"));
        require(success, "nps11"); // nps11 - upgradeNoticePeriodStarted delegatecall failed
    }

    function upgradePreparationStarted() external override {

        requireMaster(msg.sender);
        (bool success, ) = getTarget().delegatecall(abi.encodeWithSignature("upgradePreparationStarted()"));
        require(success, "ups11"); // ups11 - upgradePreparationStarted delegatecall failed
    }

    function upgradeCanceled() external override {

        requireMaster(msg.sender);
        (bool success, ) = getTarget().delegatecall(abi.encodeWithSignature("upgradeCanceled()"));
        require(success, "puc11"); // puc11 - upgradeCanceled delegatecall failed
    }

    function upgradeFinishes() external override {

        requireMaster(msg.sender);
        (bool success, ) = getTarget().delegatecall(abi.encodeWithSignature("upgradeFinishes()"));
        require(success, "puf11"); // puf11 - upgradeFinishes delegatecall failed
    }

    function isReadyForUpgrade() external override returns (bool) {

        (bool success, bytes memory result) = getTarget().delegatecall(abi.encodeWithSignature("isReadyForUpgrade()"));
        require(success, "rfu11"); // rfu11 - readyForUpgrade delegatecall failed
        return abi.decode(result, (bool));
    }
}pragma solidity >=0.5.0 <0.8.0;




contract TokenDeployInit {

    function getTokens() internal pure returns (address[] memory) {

        address[] memory tokens = new address[](16);
        tokens[0] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        tokens[1] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        tokens[2] = 0x0000000000085d4780B73119b644AE5ecd22b376;
        tokens[3] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        tokens[4] = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
        tokens[5] = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
        tokens[6] = 0x80fB784B7eD66730e8b1DBd9820aFD29931aab03;
        tokens[7] = 0x0D8775F648430679A709E98d2b0Cb6250d2887EF;
        tokens[8] = 0xdd974D5C2e2928deA5F71b9825b8b646686BD200;
        tokens[9] = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
        tokens[10] = 0x0F5D2fB29fb7d3CFeE444a200298f468908cC942;
        tokens[11] = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
        tokens[12] = 0x1985365e9f78359a9B6AD760e32412f4a445E862;
        tokens[13] = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
        tokens[14] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        tokens[15] = 0xE41d2489571d322189246DaFA5ebDe1F4699F498;
        return tokens;
    }
}pragma solidity ^0.7.0;





contract DeployFactory is TokenDeployInit {

    constructor(
        Governance _govTarget,
        Verifier _verifierTarget,
        ZkSync _zkSyncTarget,
        bytes32 _genesisRoot,
        address _firstValidator,
        address _governor,
        address _feeAccountAddress
    ) {
        require(_firstValidator != address(0));
        require(_governor != address(0));
        require(_feeAccountAddress != address(0));

        deployProxyContracts(_govTarget, _verifierTarget, _zkSyncTarget, _genesisRoot, _firstValidator, _governor);

        selfdestruct(msg.sender);
    }

    event Addresses(address governance, address zksync, address verifier, address gatekeeper);

    function deployProxyContracts(
        Governance _governanceTarget,
        Verifier _verifierTarget,
        ZkSync _zksyncTarget,
        bytes32 _genesisRoot,
        address _validator,
        address _governor
    ) internal {

        Proxy governance = new Proxy(address(_governanceTarget), abi.encode(this));
        Proxy verifier = new Proxy(address(_verifierTarget), abi.encode());
        Proxy zkSync =
            new Proxy(address(_zksyncTarget), abi.encode(address(governance), address(verifier), _genesisRoot));

        UpgradeGatekeeper upgradeGatekeeper = new UpgradeGatekeeper(zkSync);

        governance.transferMastership(address(upgradeGatekeeper));
        upgradeGatekeeper.addUpgradeable(address(governance));

        verifier.transferMastership(address(upgradeGatekeeper));
        upgradeGatekeeper.addUpgradeable(address(verifier));

        zkSync.transferMastership(address(upgradeGatekeeper));
        upgradeGatekeeper.addUpgradeable(address(zkSync));

        upgradeGatekeeper.transferMastership(_governor);

        emit Addresses(address(governance), address(zkSync), address(verifier), address(upgradeGatekeeper));

        finalizeGovernance(Governance(address(governance)), _validator, _governor);
    }

    function finalizeGovernance(
        Governance _governance,
        address _validator,
        address _finalGovernor
    ) internal {

        address[] memory tokens = getTokens();
        for (uint256 i = 0; i < tokens.length; ++i) {
            _governance.addToken(tokens[i]);
        }
        _governance.setValidator(_validator, true);
        _governance.changeGovernor(_finalGovernor);
    }
}pragma solidity ^0.7.0;




abstract contract ContextTest {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity ^0.7.0;




interface MintableIERC20NoTransferReturnValueTest {

    function mint(address to, uint256 amount) external;


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external;


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.7.0;





contract MintableERC20NoTransferReturnValueTest is ContextTest, MintableIERC20NoTransferReturnValueTest {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function mint(address to, uint256 amount) external override {

        _mint(to, amount);
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override {

        _transfer(_msgSender(), recipient, amount);
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance")
        );
    }
}pragma solidity ^0.7.0;




interface MintableIERC20Test {

    function mint(address to, uint256 amount) external;


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.7.0;





contract MintableERC20FeeAndDividendsTest is ContextTest, MintableIERC20Test {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function mint(address to, uint256 amount) external override {

        _mint(to, amount);
    }

    bool _shouldBeFeeTransfers;
    bool _senderUnintuitiveProcess;

    uint256 public FEE_AMOUNT_AS_VALUE = 15;
    uint256 public DIVIDEND_AMOUNT_AS_VALUE = 7;

    constructor(bool shouldBeFeeTransfers, bool senderUnintuitiveProcess) {
        _shouldBeFeeTransfers = shouldBeFeeTransfers;
        _senderUnintuitiveProcess = senderUnintuitiveProcess;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);

        if (_shouldBeFeeTransfers) {
            require(FEE_AMOUNT_AS_VALUE <= amount, "tet10"); // tet10 - fee is bigger than transfer amount
            if (_senderUnintuitiveProcess) {
                _burn(sender, FEE_AMOUNT_AS_VALUE);
            } else {
                _burn(recipient, FEE_AMOUNT_AS_VALUE);
            }
        } else {
            if (_senderUnintuitiveProcess) {
                _mint(sender, DIVIDEND_AMOUNT_AS_VALUE);
            } else {
                _mint(recipient, DIVIDEND_AMOUNT_AS_VALUE);
            }
        }
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance")
        );
    }
}