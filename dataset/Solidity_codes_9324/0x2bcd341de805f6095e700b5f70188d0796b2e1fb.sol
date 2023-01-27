

pragma solidity >=0.5.0 <0.6.0;

contract IACE {


    uint8 public latestEpoch;

    function burn(
        uint24 _proof,
        bytes calldata _proofData,
        address _proofSender
    ) external returns (bytes memory);



    function createNoteRegistry(
        address _linkedTokenAddress,
        uint256 _scalingFactor,
        bool _canAdjustSupply,
        bool _canConvert
    ) external;


    function createNoteRegistry(
        address _linkedTokenAddress,
        uint256 _scalingFactor,
        bool _canAdjustSupply,
        bool _canConvert,
        uint24 _factoryId
    ) external;


    function clearProofByHashes(uint24 _proof, bytes32[] calldata _proofHashes) external;


    function getCommonReferenceString() external view returns (bytes32[6] memory);



    function getFactoryAddress(uint24 _factoryId) external view returns (address factoryAddress);


    function getRegistry(address _registryOwner) external view returns (
        address linkedToken,
        uint256 scalingFactor,
        bytes32 confidentialTotalMinted,
        bytes32 confidentialTotalBurned,
        uint256 totalSupply,
        uint256 totalSupplemented,
        bool canConvert,
        bool canAdjustSupply
    );


    function getNote(address _registryOwner, bytes32 _noteHash) external view returns (
        uint8 status,
        uint40 createdOn,
        uint40 destroyedOn,
        address noteOwner
    );


    function getValidatorAddress(uint24 _proof) external view returns (address validatorAddress);


    function incrementDefaultRegistryEpoch() external;


    function incrementLatestEpoch() external;


    function invalidateProof(uint24 _proof) external;

        
    function isOwner() external view returns (bool);


    function mint(
        uint24 _proof,
        bytes calldata _proofData,
        address _proofSender
    ) external returns (bytes memory);

    

    function owner() external returns (address);


    function publicApprove(address _registryOwner, bytes32 _proofHash, uint256 _value) external;



    function renounceOwnership() external;


    function setCommonReferenceString(bytes32[6] calldata _commonReferenceString) external;


    function setDefaultCryptoSystem(uint8 _defaultCryptoSystem) external;


    function setFactory(uint24 _factoryId, address _factoryAddress) external;


    function setProof(
        uint24 _proof,
        address _validatorAddress
    ) external;


    function supplementTokens(uint256 _value) external;


    function transferOwnership(address newOwner) external;



    function validateProof(uint24 _proof, address _sender, bytes calldata) external returns (bytes memory);


    function validateProofByHash(uint24 _proof, bytes32 _proofHash, address _sender) external view returns (bool);


    function upgradeNoteRegistry(uint24 _factoryId) external;


    function updateNoteRegistry(
        uint24 _proof,
        bytes calldata _proofOutput,
        address _proofSender
    ) external;



    event SetCommonReferenceString(bytes32[6] _commonReferenceString);
    
    event SetProof(
        uint8 indexed epoch,
        uint8 indexed category,
        uint8 indexed id,
        address validatorAddress
    );

    event IncrementLatestEpoch(uint8 newLatestEpoch);

    event SetFactory(
        uint8 indexed epoch,
        uint8 indexed cryptoSystem,
        uint8 indexed assetType,
        address factoryAddress
    );

    event CreateNoteRegistry(
        address registryOwner,
        address registryAddress,
        uint256 scalingFactor,
        address linkedTokenAddress,
        bool canAdjustSupply,
        bool canConvert
    );

    event UpgradeNoteRegistry(
        address registryOwner,
        address proxyAddress,
        address newBehaviourAddress
    );
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity >=0.5.0 <0.6.0;


interface IZkAsset {


    function approveProof(
        uint24 _proofId,
        bytes calldata _proofOutputs,
        address _spender,
        bool _approval,
        bytes calldata _proofSignature
    ) external;


    function confidentialApprove(
        bytes32 _noteHash,
        address _spender,
        bool _spenderApproval,
        bytes calldata _signature
    ) external;


    function confidentialTransferFrom(uint24 _proof, bytes calldata _proofOutput) external;



    function confidentialTransfer(bytes calldata _proofData, bytes calldata _signatures) external;


    function confidentialTransfer(uint24 _proofId, bytes calldata _proofData, bytes calldata _signatures) external;



    function extractAddress(bytes calldata metaData, uint256 addressPos) external returns (address desiredAddress);


    function updateNoteMetaData(bytes32 noteHash, bytes calldata metaData) external;


    event CreateZkAsset(
        address indexed aceAddress,
        address indexed linkedTokenAddress,
        uint256 scalingFactor,
        bool indexed _canAdjustSupply,
        bool _canConvert
    );

    event CreateNoteRegistry(uint256 noteRegistryId);

    event CreateNote(address indexed owner, bytes32 indexed noteHash, bytes metadata);

    event DestroyNote(address indexed owner, bytes32 indexed noteHash);

    event ConvertTokens(address indexed owner, uint256 value);

    event RedeemTokens(address indexed owner, uint256 value);

    event UpdateNoteMetaData(address indexed owner, bytes32 indexed noteHash, bytes metadata);
}


pragma solidity >=0.5.0 <0.6.0;

library NoteUtils {


    function getLength(bytes memory _proofOutputsOrNotes) internal pure returns (
        uint len
    ) {

        assembly {
            len := mload(add(_proofOutputsOrNotes, 0x20))
        }
    }

    function get(bytes memory _proofOutputsOrNotes, uint _i) internal pure returns (
        bytes memory out
    ) {

        bool valid;
        assembly {
            valid := lt(
                _i,
                mload(add(_proofOutputsOrNotes, 0x20))
            )

            out := add(
                mload(
                    add(
                        add(_proofOutputsOrNotes, 0x40),
                        mul(_i, 0x20)
                    )
                ),
                _proofOutputsOrNotes
            )
        }
        require(valid, "AZTEC array index is out of bounds");
    }

    function extractProofOutput(bytes memory _proofOutput) internal pure returns (
        bytes memory inputNotes,
        bytes memory outputNotes,
        address publicOwner,
        int256 publicValue
    ) {

        assembly {
            inputNotes := add(_proofOutput, mload(add(_proofOutput, 0x20)))
            outputNotes := add(_proofOutput, mload(add(_proofOutput, 0x40)))
            publicOwner := and(
                mload(add(_proofOutput, 0x60)),
                0xffffffffffffffffffffffffffffffffffffffff
            )
            publicValue := mload(add(_proofOutput, 0x80))
        }
    }

    function extractChallenge(bytes memory _proofOutput) internal pure returns (
        bytes32 challenge
    ) {

        assembly {
            challenge := mload(add(_proofOutput, 0xa0))
        }
    }

    function extractNote(bytes memory _note) internal pure returns (
            address owner,
            bytes32 noteHash,
            bytes memory metadata
    ) {

        assembly {
            owner := and(
                mload(add(_note, 0x40)),
                0xffffffffffffffffffffffffffffffffffffffff
            )
            noteHash := mload(add(_note, 0x60))
            metadata := add(_note, 0x80)
        }
    }
    
    function getNoteType(bytes memory _note) internal pure returns (
        uint256 noteType
    ) {

        assembly {
            noteType := mload(add(_note, 0x20))
        }
    }
}


pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

contract IRelayRecipient {

    function getHubAddr() public view returns (address);


    function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256 maxPossibleCharge
    )
        external
        view
        returns (uint256, bytes memory);


    function preRelayedCall(bytes calldata context) external returns (bytes32);


    function postRelayedCall(bytes calldata context, bool success, uint256 actualCharge, bytes32 preRetVal) external;

}


pragma solidity ^0.5.0;

contract IRelayHub {


    function stake(address relayaddr, uint256 unstakeDelay) external payable;


    event Staked(address indexed relay, uint256 stake, uint256 unstakeDelay);

    function registerRelay(uint256 transactionFee, string memory url) public;


    event RelayAdded(address indexed relay, address indexed owner, uint256 transactionFee, uint256 stake, uint256 unstakeDelay, string url);

    function removeRelayByOwner(address relay) public;


    event RelayRemoved(address indexed relay, uint256 unstakeTime);

    function unstake(address relay) public;


    event Unstaked(address indexed relay, uint256 stake);

    enum RelayState {
        Unknown, // The relay is unknown to the system: it has never been staked for
        Staked, // The relay has been staked for, but it is not yet active
        Registered, // The relay has registered itself, and is active (can relay calls)
        Removed    // The relay has been removed by its owner and can no longer relay calls. It must wait for its unstakeDelay to elapse before it can unstake
    }

    function getRelay(address relay) external view returns (uint256 totalStake, uint256 unstakeDelay, uint256 unstakeTime, address payable owner, RelayState state);



    function depositFor(address target) public payable;


    event Deposited(address indexed recipient, address indexed from, uint256 amount);

    function balanceOf(address target) external view returns (uint256);


    function withdraw(uint256 amount, address payable dest) public;


    event Withdrawn(address indexed account, address indexed dest, uint256 amount);


    function canRelay(
        address relay,
        address from,
        address to,
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public view returns (uint256 status, bytes memory recipientContext);


    enum PreconditionCheck {
        OK,                         // All checks passed, the call can be relayed
        WrongSignature,             // The transaction to relay is not signed by requested sender
        WrongNonce,                 // The provided nonce has already been used by the sender
        AcceptRelayedCallReverted,  // The recipient rejected this call via acceptRelayedCall
        InvalidRecipientStatusCode  // The recipient returned an invalid (reserved) status code
    }

    function relayCall(
        address from,
        address to,
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public;


    event CanRelayFailed(address indexed relay, address indexed from, address indexed to, bytes4 selector, uint256 reason);

    event TransactionRelayed(address indexed relay, address indexed from, address indexed to, bytes4 selector, RelayCallStatus status, uint256 charge);

    enum RelayCallStatus {
        OK,                      // The transaction was successfully relayed and execution successful - never included in the event
        RelayedCallFailed,       // The transaction was relayed, but the relayed call failed
        PreRelayedFailed,        // The transaction was not relayed due to preRelatedCall reverting
        PostRelayedFailed,       // The transaction was relayed and reverted due to postRelatedCall reverting
        RecipientBalanceChanged  // The transaction was relayed and reverted due to the recipient's balance changing
    }

    function requiredGas(uint256 relayedCallStipend) public view returns (uint256);


    function maxPossibleCharge(uint256 relayedCallStipend, uint256 gasPrice, uint256 transactionFee) public view returns (uint256);



    function penalizeRepeatedNonce(bytes memory unsignedTx1, bytes memory signature1, bytes memory unsignedTx2, bytes memory signature2) public;


    function penalizeIllegalTransaction(bytes memory unsignedTx, bytes memory signature) public;


    event Penalized(address indexed relay, address sender, uint256 amount);

    function getNonce(address from) external view returns (uint256);

}


pragma solidity ^0.5.0;


contract Context is Initializable {

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





contract GSNRecipient is Initializable, IRelayRecipient, Context {

    function initialize() public initializer {

        if (_relayHub == address(0)) {
            setDefaultRelayHub();
        }
    }

    function setDefaultRelayHub() public {

        _upgradeRelayHub(0xD216153c06E857cD7f72665E0aF1d7D82172F494);
    }

    address private _relayHub;

    uint256 constant private RELAYED_CALL_ACCEPTED = 0;
    uint256 constant private RELAYED_CALL_REJECTED = 11;

    uint256 constant internal POST_RELAYED_CALL_MAX_GAS = 100000;

    event RelayHubChanged(address indexed oldRelayHub, address indexed newRelayHub);

    function getHubAddr() public view returns (address) {

        return _relayHub;
    }

    function _upgradeRelayHub(address newRelayHub) internal {

        address currentRelayHub = _relayHub;
        require(newRelayHub != address(0), "GSNRecipient: new RelayHub is the zero address");
        require(newRelayHub != currentRelayHub, "GSNRecipient: new RelayHub is the current one");

        emit RelayHubChanged(currentRelayHub, newRelayHub);

        _relayHub = newRelayHub;
    }

    function relayHubVersion() public view returns (string memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return "1.0.0";
    }

    function _withdrawDeposits(uint256 amount, address payable payee) internal {

        IRelayHub(_relayHub).withdraw(amount, payee);
    }


    function _msgSender() internal view returns (address payable) {

        if (msg.sender != _relayHub) {
            return msg.sender;
        } else {
            return _getRelayedCallSender();
        }
    }

    function _msgData() internal view returns (bytes memory) {

        if (msg.sender != _relayHub) {
            return msg.data;
        } else {
            return _getRelayedCallData();
        }
    }


    function preRelayedCall(bytes calldata context) external returns (bytes32) {

        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        return _preRelayedCall(context);
    }

    function _preRelayedCall(bytes memory context) internal returns (bytes32);


    function postRelayedCall(bytes calldata context, bool success, uint256 actualCharge, bytes32 preRetVal) external {

        require(msg.sender == getHubAddr(), "GSNRecipient: caller is not RelayHub");
        _postRelayedCall(context, success, actualCharge, preRetVal);
    }

    function _postRelayedCall(bytes memory context, bool success, uint256 actualCharge, bytes32 preRetVal) internal;


    function _approveRelayedCall() internal pure returns (uint256, bytes memory) {

        return _approveRelayedCall("");
    }

    function _approveRelayedCall(bytes memory context) internal pure returns (uint256, bytes memory) {

        return (RELAYED_CALL_ACCEPTED, context);
    }

    function _rejectRelayedCall(uint256 errorCode) internal pure returns (uint256, bytes memory) {

        return (RELAYED_CALL_REJECTED + errorCode, "");
    }

    function _computeCharge(uint256 gas, uint256 gasPrice, uint256 serviceFee) internal pure returns (uint256) {

        return (gas * gasPrice * (100 + serviceFee)) / 100;
    }

    function _getRelayedCallSender() private pure returns (address payable result) {



        bytes memory array = msg.data;
        uint256 index = msg.data.length;

        assembly {
            result := and(mload(add(array, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    function _getRelayedCallData() private pure returns (bytes memory) {


        uint256 actualDataLength = msg.data.length - 20;
        bytes memory actualData = new bytes(actualDataLength);

        for (uint256 i = 0; i < actualDataLength; ++i) {
            actualData[i] = msg.data[i];
        }

        return actualData;
    }
}


pragma solidity ^0.5.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}


pragma solidity ^0.5.0;





contract GSNRecipientTimestampSignature is Initializable, GSNRecipient {

    using ECDSA for bytes32;

    uint256 constant private RELAYED_CALL_REJECTED = 11;

    address private _trustedSigner;

    enum GSNRecipientSignatureErrorCodes {
        INVALID_SIGNER,
        INVALID_TIMESTAMP
    }

    function initialize(address trustedSigner) internal initializer {

        require(trustedSigner != address(0), "GSNRecipientSignature: trusted signer is the zero address");
        _trustedSigner = trustedSigner;

        GSNRecipient.initialize();
    }

    function _rejectRelayedCall(uint256 errorCode, bytes memory context) internal pure returns (uint256, bytes memory) {

        return (RELAYED_CALL_REJECTED + errorCode, context);
    }

    function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256
    )
        external
        view
        returns (uint256, bytes memory context)
    {

        (
            uint256 maxTimestamp,
            bytes memory signature
        ) = abi.decode(approvalData, (uint256, bytes));

        bytes memory blob = abi.encodePacked(
            relay,
            from,
            encodedFunction,
            transactionFee,
            gasPrice,
            gasLimit,
            nonce, // Prevents replays on RelayHub
            getHubAddr(), // Prevents replays in multiple RelayHubs
            address(this), // Prevents replays in multiple recipients
            maxTimestamp // Prevents sends tx after long perion of time
        );
        context = abi.encode(signature);

        if (keccak256(blob).toEthSignedMessageHash().recover(signature) == _trustedSigner) {
            if (block.timestamp > maxTimestamp) {
                return _rejectRelayedCall(uint256(GSNRecipientSignatureErrorCodes.INVALID_TIMESTAMP), context);
            }
            return _approveRelayedCall(context);
        } else {
            return _rejectRelayedCall(uint256(GSNRecipientSignatureErrorCodes.INVALID_SIGNER), context);
        }
    }

    function _preRelayedCall(bytes memory) internal returns (bytes32) {

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


pragma solidity >=0.5.0 <0.6.0;








contract PromoManager is GSNRecipientTimestampSignature {

    using NoteUtils for bytes;
    using SafeMath for uint256;


    address private _owner;

    mapping(bytes32 => bool) public codeRedemptions;
    mapping(bytes32 => bytes32) public codeToTotalNotes;
    mapping(bytes32 => address) public userCommitToCode;

    event GSNTransactionProcessed(bytes32 indexed signatureHash, bool indexed success, uint actualCharge);
    event LogAddress(address conrtrac);
    event LogBytes(bytes32 bb);

    IACE ace;

    uint24 JOIN_SPLIT_PROOF = 65793;

    IZkAsset zkDAI;
    bytes32 unallocatedNoteHash;
    struct Note {
        address owner;
        bytes32 noteHash;
    }
    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function _noteCoderToStruct(bytes memory note) internal pure returns (Note memory codedNote) {

        (address owner, bytes32 noteHash,) = note.extractNote();
        return Note(owner, noteHash );
    }


    constructor(
        address _aceAddress,
        address _zkDaiAddress
    ) public {


        _owner = msg.sender;
        zkDAI = IZkAsset(_zkDaiAddress);
        ace = IACE(_aceAddress);

    }



    function initialize( bytes32 _unallocatedNoteHash, address _trustedGSNSignerAddress) initializer onlyOwner public {


        unallocatedNoteHash = _unallocatedNoteHash; // initialise as the zero value note
        GSNRecipientTimestampSignature.initialize(_trustedGSNSignerAddress);
    }

    function reset(bytes32 _unallocatedNoteHash, address _zkDaiAddress) onlyOwner public {


        unallocatedNoteHash = _unallocatedNoteHash; // initialise as the zero value note
        zkDAI = IZkAsset(_zkDaiAddress);
    }



    function setCodes(bytes32[] memory _codeHashes, bytes memory _proofData) public onlyOwner {

        (bytes memory _proofOutputs) = ace.validateProof(JOIN_SPLIT_PROOF, address(this), _proofData);
        (bytes memory _proofInputNotes, bytes memory _proofOutputNotes, ,) = _proofOutputs.get(0).extractProofOutput();
        for (uint i = 0; i < _codeHashes.length; i += 1) {
            codeToTotalNotes[_codeHashes[i]] = _noteCoderToStruct(_proofOutputNotes.get(i.add(1))).noteHash;
        }
        require(_noteCoderToStruct(_proofInputNotes.get(0)).noteHash == unallocatedNoteHash, 'hash incorrect');

        zkDAI.confidentialApprove(_noteCoderToStruct(_proofInputNotes.get(0)).noteHash, address(this), true, '');
        zkDAI.confidentialTransferFrom(JOIN_SPLIT_PROOF, _proofOutputs.get(0));
        unallocatedNoteHash = _noteCoderToStruct(_proofOutputNotes.get(0)).noteHash;
    }

    function claim1(bytes32 _codeHash, address _noteOwner) public {

        require(_owner != address(0), 'bad address');
        require(address(userCommitToCode[_codeHash]) == address(0));
        userCommitToCode[_codeHash] = _noteOwner;
    }

    function claim2(string memory _code, uint256 _challenge, address _noteOwner, bytes memory _proofData) public {

        bytes32 codeCommitHash = keccak256(abi.encode(_code, _challenge, _noteOwner));
        bytes32 codeHash = keccak256(abi.encode(_code));
        require(userCommitToCode[codeCommitHash] == _noteOwner, 'code');
        require(!codeRedemptions[codeHash], 'code redeemed');
        codeRedemptions[codeHash] = true;

        (bytes memory _proofOutputs) = ace.validateProof(JOIN_SPLIT_PROOF, address(this), _proofData);
        (bytes memory _proofInputNotes, bytes memory _proofOutputNotes, ,) = _proofOutputs.get(0).extractProofOutput();
        require(codeToTotalNotes[codeHash] == _noteCoderToStruct(_proofInputNotes.get(0)).noteHash, 'bad note');
        require(_proofInputNotes.getLength() == 1, 'bad length');

        uint256 numberOfNotes = _proofOutputNotes.getLength();
        for (uint256 i = 0; i < numberOfNotes; i += 1) {
            (address owner,,) = _proofOutputNotes.get(i).extractNote();
            require(owner == _noteOwner, "Cannot deposit note to other account if sender is not the same as owner.");
        }
        
        zkDAI.confidentialApprove(codeToTotalNotes[codeHash], address(this), true, '');
        zkDAI.confidentialTransferFrom(JOIN_SPLIT_PROOF, _proofOutputs.get(0));
    }



    function _postRelayedCall(bytes memory context, bool success, uint256 actualCharge, bytes32 preRetVal) internal {

        (bytes memory approveData) = abi.decode(context, (bytes));
        emit GSNTransactionProcessed(keccak256(approveData), success, actualCharge);
    }


}