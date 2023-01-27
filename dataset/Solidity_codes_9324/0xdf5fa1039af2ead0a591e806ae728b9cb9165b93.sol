pragma solidity ^0.7.0;




contract Ownable {

    bytes32 private constant MASTER_POSITION = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    constructor(address masterAddress) {
        setMaster(masterAddress);
    }

    function requireMaster(address _address) internal view {

        require(_address == getMaster(), "1c"); // oro11 - only by master
    }

    function getMaster() public view returns (address master) {

        bytes32 position = MASTER_POSITION;
        assembly {
            master := sload(position)
        }
    }

    function setMaster(address _newMaster) internal {

        bytes32 position = MASTER_POSITION;
        assembly {
            sstore(position, _newMaster)
        }
    }

    function transferMastership(address _newMaster) external {

        requireMaster(msg.sender);
        require(_newMaster != address(0), "1d"); // otp11 - new masters address can't be zero address
        setMaster(_newMaster);
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

    uint16 internal constant MAX_AMOUNT_OF_REGISTERED_TOKENS = 1023;

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

    uint256 internal constant PRIORITY_EXPIRATION_PERIOD = 3 days;

    uint256 internal constant PRIORITY_EXPIRATION =
        PRIORITY_EXPIRATION_PERIOD/BLOCK_PERIOD;

    uint64 internal constant MAX_PRIORITY_REQUESTS_TO_DELETE_IN_VERIFY = 6;

    uint256 internal constant MASS_FULL_EXIT_PERIOD = 9 days;

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

    uint256 internal constant SECURITY_COUNCIL_MEMBERS_NUMBER = 15;
}pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;







contract RegenesisMultisig is Ownable, Config {

    event CandidateAccepted(bytes32 oldRootHash, bytes32 newRootHash);
    event CandidateApproval(uint256 currentApproval);

    bytes32 public oldRootHash;
    bytes32 public newRootHash;

    bytes32 public candidateOldRootHash;
    bytes32 public candidateNewRootHash;

    mapping(uint256 => bool) internal securityCouncilApproves;
    uint256 internal numberOfApprovalsFromSecurityCouncil;

    uint256 securityCouncilThreshold;

    constructor(uint256 threshold) Ownable(msg.sender) {
        securityCouncilThreshold = threshold;
    }

    function submitHash(bytes32 _oldRootHash, bytes32 _newRootHash) external {

        require(msg.sender == getMaster(), "1");

        candidateOldRootHash = _oldRootHash;
        candidateNewRootHash = _newRootHash;

        oldRootHash = bytes32(0);
        newRootHash = bytes32(0);

        for (uint256 i = 0; i < SECURITY_COUNCIL_MEMBERS_NUMBER; ++i) {
            securityCouncilApproves[i] = false;
        }
        numberOfApprovalsFromSecurityCouncil = 0;
    }

    function approveHash(bytes32 _oldRootHash, bytes32 _newRootHash) external {

        require(_oldRootHash == candidateOldRootHash, "2");
        require(_newRootHash == candidateNewRootHash, "3");

        address payable[SECURITY_COUNCIL_MEMBERS_NUMBER] memory SECURITY_COUNCIL_MEMBERS =
            [0xa2602ea835E03fb39CeD30B43d6b6EAf6aDe1769,0x9D5d6D4BaCCEDf6ECE1883456AA785dc996df607,0x002A5dc50bbB8d5808e418Aeeb9F060a2Ca17346,0x71E805aB236c945165b9Cd0bf95B9f2F0A0488c3,0x76C6cE74EAb57254E785d1DcC3f812D274bCcB11,0xFBfF3FF69D65A9103Bf4fdBf988f5271D12B3190,0xAfC2F2D803479A2AF3A72022D54cc0901a0ec0d6,0x4d1E3089042Ab3A93E03CA88B566b99Bd22438C6,0x19eD6cc20D44e5cF4Bb4894F50162F72402d8567,0x39415255619783A2E71fcF7d8f708A951d92e1b6,0x399a6a13D298CF3F41a562966C1a450136Ea52C2,0xee8AE1F1B4B1E1956C8Bda27eeBCE54Cf0bb5eaB,0xe7CCD4F3feA7df88Cf9B59B30f738ec1E049231f,0xA093284c707e207C36E3FEf9e0B6325fd9d0e33B,0x225d3822De44E58eE935440E0c0B829C4232086e];
        for (uint256 id = 0; id < SECURITY_COUNCIL_MEMBERS_NUMBER; ++id) {
            if (SECURITY_COUNCIL_MEMBERS[id] == msg.sender) {
                require(securityCouncilApproves[id] == false);
                securityCouncilApproves[id] = true;
                numberOfApprovalsFromSecurityCouncil++;
                emit CandidateApproval(numberOfApprovalsFromSecurityCouncil);

                if (numberOfApprovalsFromSecurityCouncil == securityCouncilThreshold) {
                    oldRootHash = candidateOldRootHash;
                    newRootHash = candidateNewRootHash;
                    emit CandidateAccepted(oldRootHash, newRootHash);
                }
            }
        }
    }
}