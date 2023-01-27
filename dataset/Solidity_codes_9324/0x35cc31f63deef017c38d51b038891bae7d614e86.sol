pragma solidity ^0.7.0;




contract ReentrancyGuard {

    uint256 private constant LOCK_FLAG_ADDRESS = 0x8e94fed44239eb2314ab7a406345e6c5a8f0ccedf3b600de3d004e672c33abf4; // keccak256("ReentrancyGuard") - 1;

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    function initializeReentrancyGuard() internal {

        uint256 lockSlotOldValue;

        assembly {
            lockSlotOldValue := sload(LOCK_FLAG_ADDRESS)
            sstore(LOCK_FLAG_ADDRESS, _NOT_ENTERED)
        }

        require(lockSlotOldValue == 0, "1B");
    }

    modifier nonReentrant() {

        uint256 _status;
        assembly {
            _status := sload(LOCK_FLAG_ADDRESS)
        }

        require(_status == _NOT_ENTERED);

        assembly {
            sstore(LOCK_FLAG_ADDRESS, _ENTERED)
        }

        _;

        assembly {
            sstore(LOCK_FLAG_ADDRESS, _NOT_ENTERED)
        }
    }
}pragma solidity ^0.7.0;




contract Config {

    uint256 internal constant WITHDRAWAL_GAS_LIMIT = 100000;

    uint256 internal constant WITHDRAWAL_NFT_GAS_LIMIT = 300000;

    uint8 internal constant CHUNK_BYTES = 10;

    uint8 internal constant ADDRESS_BYTES = 20;

    uint8 internal constant PUBKEY_HASH_BYTES = 20;

    uint8 internal constant PUBKEY_BYTES = 32;

    uint8 internal constant ETH_SIGN_RS_BYTES = 32;

    uint8 internal constant SUCCESS_FLAG_BYTES = 1;

    uint32 internal constant MAX_AMOUNT_OF_REGISTERED_TOKENS = 1023;

    uint32 internal constant MAX_ACCOUNT_ID = 16777215;

    uint256 internal constant BLOCK_PERIOD = 15 seconds;

    uint256 internal constant EXPECT_VERIFICATION_IN = 0 hours / BLOCK_PERIOD;

    uint256 internal constant NOOP_BYTES = 1 * CHUNK_BYTES;
    uint256 internal constant DEPOSIT_BYTES = 6 * CHUNK_BYTES;
    uint256 internal constant MINT_NFT_BYTES = 5 * CHUNK_BYTES;
    uint256 internal constant TRANSFER_TO_NEW_BYTES = 6 * CHUNK_BYTES;
    uint256 internal constant PARTIAL_EXIT_BYTES = 6 * CHUNK_BYTES;
    uint256 internal constant TRANSFER_BYTES = 2 * CHUNK_BYTES;
    uint256 internal constant FORCED_EXIT_BYTES = 6 * CHUNK_BYTES;
    uint256 internal constant WITHDRAW_NFT_BYTES = 10 * CHUNK_BYTES;

    uint256 internal constant FULL_EXIT_BYTES = 11 * CHUNK_BYTES;

    uint256 internal constant CHANGE_PUBKEY_BYTES = 6 * CHUNK_BYTES;

    uint256 internal constant PRIORITY_EXPIRATION_PERIOD = 14 days;

    uint256 internal constant PRIORITY_EXPIRATION =
        PRIORITY_EXPIRATION_PERIOD/BLOCK_PERIOD;

    uint64 internal constant MAX_PRIORITY_REQUESTS_TO_DELETE_IN_VERIFY = 6;

    uint256 internal constant MASS_FULL_EXIT_PERIOD = 5 days;

    uint256 internal constant TIME_TO_WITHDRAW_FUNDS_FROM_FULL_EXIT = 2 days;

    uint256 internal constant UPGRADE_NOTICE_PERIOD =
        MASS_FULL_EXIT_PERIOD+PRIORITY_EXPIRATION_PERIOD+TIME_TO_WITHDRAW_FUNDS_FROM_FULL_EXIT;

    uint256 internal constant COMMIT_TIMESTAMP_NOT_OLDER = 24 hours;

    uint256 internal constant COMMIT_TIMESTAMP_APPROXIMATION_DELTA = 15 minutes;

    uint256 internal constant INPUT_MASK = 14474011154664524427946373126085988481658748083205070504932198000989141204991;

    uint256 internal constant AUTH_FACT_RESET_TIMELOCK = 1 days;

    uint128 internal constant MAX_DEPOSIT_AMOUNT = 20282409603651670423947251286015;

    uint32 internal constant SPECIAL_ACCOUNT_ID = 16777215;
    address internal constant SPECIAL_ACCOUNT_ADDRESS = address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);
    uint32 internal constant SPECIAL_NFT_TOKEN_ID = 2147483646;

    uint32 internal constant MAX_FUNGIBLE_TOKEN_ID = 65535;

    uint256 internal constant SECURITY_COUNCIL_MEMBERS_NUMBER = 3;
}pragma solidity ^0.7.0;



interface IERC20 {

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

        require(byteLength <= 32, "Q");
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
        require(self.length >= offset, "R");
        assembly {
            addr := mload(add(self, offset))
        }
    }

    function bytesToBytes20(bytes memory self, uint256 _start) internal pure returns (bytes20 r) {

        require(self.length >= (_start + 20), "S");
        assembly {
            r := mload(add(add(self, 0x20), _start))
        }
    }

    function bytesToUInt16(bytes memory _bytes, uint256 _start) internal pure returns (uint16 r) {

        uint256 offset = _start + 0x2;
        require(_bytes.length >= offset, "T");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    function bytesToUInt24(bytes memory _bytes, uint256 _start) internal pure returns (uint24 r) {

        uint256 offset = _start + 0x3;
        require(_bytes.length >= offset, "U");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    function bytesToUInt32(bytes memory _bytes, uint256 _start) internal pure returns (uint32 r) {

        uint256 offset = _start + 0x4;
        require(_bytes.length >= offset, "V");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    function bytesToUInt128(bytes memory _bytes, uint256 _start) internal pure returns (uint128 r) {

        uint256 offset = _start + 0x10;
        require(_bytes.length >= offset, "W");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    function bytesToUInt160(bytes memory _bytes, uint256 _start) internal pure returns (uint160 r) {

        uint256 offset = _start + 0x14;
        require(_bytes.length >= offset, "X");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    function bytesToBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32 r) {

        uint256 offset = _start + 0x20;
        require(_bytes.length >= offset, "Y");
        assembly {
            r := mload(add(_bytes, offset))
        }
    }

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {

        require(_bytes.length >= (_start + _length), "Z"); // bytes length is less then start byte + length bytes

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
    ) internal pure returns (uint256 newOffset, bytes memory data) {

        data = slice(_data, _offset, _length);
        newOffset = _offset + _length;
    }

    function readBool(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, bool r) {

        newOffset = _offset + 1;
        r = uint8(_data[_offset]) != 0;
    }

    function readUint8(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint8 r) {

        newOffset = _offset + 1;
        r = uint8(_data[_offset]);
    }

    function readUInt16(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint16 r) {

        newOffset = _offset + 2;
        r = bytesToUInt16(_data, _offset);
    }

    function readUInt24(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint24 r) {

        newOffset = _offset + 3;
        r = bytesToUInt24(_data, _offset);
    }

    function readUInt32(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint32 r) {

        newOffset = _offset + 4;
        r = bytesToUInt32(_data, _offset);
    }

    function readUInt128(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint128 r) {

        newOffset = _offset + 16;
        r = bytesToUInt128(_data, _offset);
    }

    function readUInt160(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, uint160 r) {

        newOffset = _offset + 20;
        r = bytesToUInt160(_data, _offset);
    }

    function readAddress(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, address r) {

        newOffset = _offset + 20;
        r = bytesToAddress(_data, _offset);
    }

    function readBytes20(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, bytes20 r) {

        newOffset = _offset + 20;
        r = bytesToBytes20(_data, _offset);
    }

    function readBytes32(bytes memory _data, uint256 _offset) internal pure returns (uint256 newOffset, bytes32 r) {

        newOffset = _offset + 32;
        r = bytesToBytes32(_data, _offset);
    }

    function trim(bytes memory _data, uint256 _newLength) internal pure returns (uint256 r) {

        require(_newLength <= 0x20, "10"); // new_length is longer than word
        require(_data.length >= _newLength, "11"); // data is to short

        uint256 a;
        assembly {
            a := mload(add(_data, 0x20)) // load bytes into uint256
        }

        return a >> ((0x20 - _newLength) * 8);
    }

    function halfByteToHex(bytes1 _byte) internal pure returns (bytes1 _hexByte) {

        require(uint8(_byte) < 0x10, "hbh11"); // half byte's value is out of 0..15 range.

        return bytes1(uint8(0x66656463626139383736353433323130 >> (uint8(_byte) * 8)));
    }

    function bytesToHexASCIIBytes(bytes memory _input) internal pure returns (bytes memory _output) {

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
                mstore(
                    out_curr,
                    shl(0xf8, shr(mul(shr(0x04, curr_input_byte), 0x08), 0x66656463626139383736353433323130))
                )
                mstore(
                    add(out_curr, 0x01),
                    shl(0xf8, shr(mul(and(0x0f, curr_input_byte), 0x08), 0x66656463626139383736353433323130))
                )
            }
        }
        return outStringBytes;
    }
}pragma solidity ^0.7.0;





library Utils {

    function minU32(uint32 a, uint32 b) internal pure returns (uint32) {

        return a < b ? a : b;
    }

    function minU64(uint64 a, uint64 b) internal pure returns (uint64) {

        return a < b ? a : b;
    }

    function minU128(uint128 a, uint128 b) internal pure returns (uint128) {

        return a < b ? a : b;
    }

    function recoverAddressFromEthSignature(bytes memory _signature, bytes32 _messageHash)
        internal
        pure
        returns (address)
    {

        require(_signature.length == 65, "P"); // incorrect signature length

        bytes32 signR;
        bytes32 signS;
        uint8 signV;
        assembly {
            signR := mload(add(_signature, 32))
            signS := mload(add(_signature, 64))
            signV := byte(0, mload(add(_signature, 96)))
        }

        address recoveredAddress = ecrecover(_messageHash, signV, signR, signS);
        require(recoveredAddress != address(0), "p4"); // invalid signature

        return recoveredAddress;
    }

    function concatHash(bytes32 _hash, bytes memory _bytes) internal pure returns (bytes32) {

        bytes32 result;
        assembly {
            let bytesLen := add(mload(_bytes), 32)
            mstore(_bytes, _hash)
            result := keccak256(_bytes, bytesLen)
        }
        return result;
    }

    function hashBytesToBytes20(bytes memory _bytes) internal pure returns (bytes20) {

        return bytes20(uint160(uint256(keccak256(_bytes))));
    }
}pragma solidity ^0.7.0;



interface NFTFactory {

    function mintNFTFromZkSync(
        address creator,
        address recipient,
        uint32 creatorAccountId,
        uint32 serialId,
        bytes32 contentHash,
        uint256 tokenId
    ) external;


    event MintNFTFromZkSync(
        address indexed creator,
        address indexed recipient,
        uint32 creatorAccountId,
        uint32 serialId,
        bytes32 contentHash,
        uint256 tokenId
    );
}pragma solidity ^0.7.0;





contract Governance is Config {

    event NewToken(address indexed token, uint16 indexed tokenId);

    event SetDefaultNFTFactory(address indexed factory);

    event NFTFactoryRegisteredCreator(
        uint32 indexed creatorAccountId,
        address indexed creatorAddress,
        address factoryAddress
    );

    event NewGovernor(address newGovernor);

    event NewTokenGovernance(TokenGovernance newTokenGovernance);

    event ValidatorStatusUpdate(address indexed validatorAddress, bool isActive);

    event TokenPausedUpdate(address indexed token, bool paused);

    address public networkGovernor;

    uint16 public totalTokens;

    mapping(uint16 => address) public tokenAddresses;

    mapping(address => uint16) public tokenIds;

    mapping(address => bool) public validators;

    mapping(uint16 => bool) public pausedTokens;

    TokenGovernance public tokenGovernance;

    mapping(uint32 => mapping(address => NFTFactory)) public nftFactories;

    NFTFactory public defaultFactory;

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

    function changeTokenGovernance(TokenGovernance _newTokenGovernance) external {

        requireGovernor(msg.sender);
        if (tokenGovernance != _newTokenGovernance) {
            tokenGovernance = _newTokenGovernance;
            emit NewTokenGovernance(_newTokenGovernance);
        }
    }

    function addToken(address _token) external {

        require(msg.sender == address(tokenGovernance), "1E");
        require(tokenIds[_token] == 0, "1e"); // token exists
        require(totalTokens < MAX_AMOUNT_OF_REGISTERED_TOKENS, "1f"); // no free identifiers for tokens

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

        require(_address == networkGovernor, "1g"); // only by governor
    }

    function requireActiveValidator(address _address) external view {

        require(validators[_address], "1h"); // validator is not active
    }

    function isValidTokenId(uint16 _tokenId) external view returns (bool) {

        return _tokenId <= totalTokens;
    }

    function validateTokenAddress(address _tokenAddr) external view returns (uint16) {

        uint16 tokenId = tokenIds[_tokenAddr];
        require(tokenId != 0, "1i"); // 0 is not a valid token
        return tokenId;
    }

    function packRegisterNFTFactoryMsg(
        uint32 _creatorAccountId,
        address _creatorAddress,
        address _factoryAddress
    ) internal pure returns (bytes memory) {

        return
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n141",
                "\nCreator's account ID in zkSync: ",
                Bytes.bytesToHexASCIIBytes(abi.encodePacked((_creatorAccountId))),
                "\nCreator: ",
                Bytes.bytesToHexASCIIBytes(abi.encodePacked((_creatorAddress))),
                "\nFactory: ",
                Bytes.bytesToHexASCIIBytes(abi.encodePacked((_factoryAddress)))
            );
    }

    function registerNFTFactoryCreator(
        uint32 _creatorAccountId,
        address _creatorAddress,
        bytes memory _signature
    ) external {

        require(address(nftFactories[_creatorAccountId][_creatorAddress]) == address(0), "Q");
        bytes32 messageHash = keccak256(packRegisterNFTFactoryMsg(_creatorAccountId, _creatorAddress, msg.sender));

        address recoveredAddress = Utils.recoverAddressFromEthSignature(_signature, messageHash);
        require(recoveredAddress == _creatorAddress, "ws");
        nftFactories[_creatorAccountId][_creatorAddress] = NFTFactory(msg.sender);
        emit NFTFactoryRegisteredCreator(_creatorAccountId, _creatorAddress, msg.sender);
    }

    function setDefaultNFTFactory(address _factory) external {

        requireGovernor(msg.sender);
        require(address(_factory) != address(0), "mb1"); // Factory should be non zero
        require(address(defaultFactory) == address(0), "mb2"); // NFTFactory is already set
        defaultFactory = NFTFactory(_factory);
        emit SetDefaultNFTFactory(_factory);
    }

    function getNFTFactory(uint32 _creatorAccountId, address _creatorAddress) external view returns (NFTFactory) {

        NFTFactory _factory = nftFactories[_creatorAccountId][_creatorAddress];
        if (address(_factory) == address(0) || !isContract(address(_factory))) {
            require(address(defaultFactory) != address(0), "fs"); // NFTFactory does not set
            return defaultFactory;
        } else {
            return _factory;
        }
    }

    function isContract(address _address) internal view returns (bool) {

        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_address)
        }

        return contractSize != 0;
    }
}/// @dev Interface of the ERC20 standard as defined in the EIP.
interface ITrustedTransfarableERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}pragma solidity ^0.7.0;





contract TokenGovernance is ReentrancyGuard {

    event TokenListerUpdate(address indexed tokenLister, bool isActive);

    event ListingFeeTokenUpdate(ITrustedTransfarableERC20 indexed newListingFeeToken, uint256 newListingFee);

    event ListingFeeUpdate(uint256 newListingFee);

    event ListingCapUpdate(uint16 newListingCap);

    event TreasuryUpdate(address newTreasury);

    Governance public governance;

    ITrustedTransfarableERC20 public listingFeeToken;

    uint256 public listingFee;

    uint16 public listingCap;

    mapping(address => bool) public tokenLister;

    address public treasury;

    constructor(
        Governance _governance,
        ITrustedTransfarableERC20 _listingFeeToken,
        uint256 _listingFee,
        uint16 _listingCap,
        address _treasury
    ) {
        initializeReentrancyGuard();

        governance = _governance;
        listingFeeToken = _listingFeeToken;
        listingFee = _listingFee;
        listingCap = _listingCap;
        treasury = _treasury;

        address governor = governance.networkGovernor();
        tokenLister[governor] = true;
        emit TokenListerUpdate(governor, true);
    }

    function addToken(address _token) external nonReentrant {

        require(_token != address(0), "z1"); // Token should have a non-zero address
        require(_token != 0xaBEA9132b05A70803a4E85094fD0e1800777fBEF, "z2"); // Address of the token cannot be the same as the address of the main zksync contract
        require(governance.totalTokens() < listingCap, "can't add more tokens"); // Impossible to add more tokens using this contract
        if (!tokenLister[msg.sender] && listingFee > 0) {
            bool feeTransferOk = listingFeeToken.transferFrom(msg.sender, treasury, listingFee);
            require(feeTransferOk, "fee transfer failed"); // Failed to receive payment for token addition.
        }
        governance.addToken(_token);
    }


    function setListingFeeToken(ITrustedTransfarableERC20 _newListingFeeToken, uint256 _newListingFee) external {

        governance.requireGovernor(msg.sender);
        listingFeeToken = _newListingFeeToken;
        listingFee = _newListingFee;

        emit ListingFeeTokenUpdate(_newListingFeeToken, _newListingFee);
    }

    function setListingFee(uint256 _newListingFee) external {

        governance.requireGovernor(msg.sender);
        listingFee = _newListingFee;

        emit ListingFeeUpdate(_newListingFee);
    }

    function setLister(address _listerAddress, bool _active) external {

        governance.requireGovernor(msg.sender);
        if (tokenLister[_listerAddress] != _active) {
            tokenLister[_listerAddress] = _active;
            emit TokenListerUpdate(_listerAddress, _active);
        }
    }

    function setListingCap(uint16 _newListingCap) external {

        governance.requireGovernor(msg.sender);
        listingCap = _newListingCap;

        emit ListingCapUpdate(_newListingCap);
    }

    function setTreasury(address _newTreasury) external {

        governance.requireGovernor(msg.sender);
        treasury = _newTreasury;

        emit TreasuryUpdate(_newTreasury);
    }
}