

pragma solidity ^0.4.24;


contract ERC721ReceiverDraft {


    bytes4 internal constant ERC721_RECEIVED_DRAFT = 0xf0b9e5ba;

    function onERC721Received(address _from, uint256 _tokenId, bytes data) external returns(bytes4);

}


pragma solidity ^0.4.24;


contract ERC721ReceiverFinal {


    bytes4 internal constant ERC721_RECEIVED_FINAL = 0x150b7a02;

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes _data
    )
    public
        returns (bytes4);

}


pragma solidity ^0.4.24;



contract ERC721Receivable is ERC721ReceiverDraft, ERC721ReceiverFinal {


    function onERC721Received(address _from, uint256 _tokenId, bytes data) external returns(bytes4) {

        _from;
        _tokenId;
        data;


        return ERC721_RECEIVED_DRAFT;
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes _data
    )
        public
        returns(bytes4)
    {

        _operator;
        _from;
        _tokenId;
        _data;


        return ERC721_RECEIVED_FINAL;
    }

}


pragma solidity ^0.4.24;


contract ERC223Receiver {

    
    bytes4 public constant ERC223_ID = 0xc0ee0b8a;

    struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }
    
    function tokenFallback(address _from, uint _value, bytes _data) public pure {

        _from;
        _value;
        _data;
      

    }
}


pragma solidity ^0.4.24;

contract ERC1271 {


    bytes4 internal constant ERC1271_VALIDSIGNATURE = 0x1626ba7e;

    function isValidSignature(
        bytes32 hash, 
        bytes _signature)
        external
        view 
        returns (bytes4);

}


pragma solidity ^0.4.24;


library ECDSA {


    function extractSignature(bytes sigData, uint256 offset) internal pure returns  (bytes32 r, bytes32 s, uint8 v) {

        assembly {
             let dataPointer := add(sigData, offset)
             r := mload(add(dataPointer, 0x20))
             s := mload(add(dataPointer, 0x40))
             v := byte(0, mload(add(dataPointer, 0x60)))
        }
    
        return (r, s, v);
    }
}


pragma solidity ^0.4.24;






contract CoreWallet is ERC721Receivable, ERC223Receiver, ERC1271  {


    using ECDSA for bytes;

    byte public constant EIP191_VERSION_DATA = byte(0);
    byte public constant EIP191_PREFIX = byte(0x19);

    string public constant VERSION = "1.0.0";

    uint256 public constant AUTH_VERSION_INCREMENTOR = (1 << 160);
    
    uint256 public authVersion;

    mapping(uint256 => uint256) public authorizations;

    mapping(address => uint256) public nonces;

    address public recoveryAddress;

    bool public initialized;
    
    modifier onlyRecoveryAddress() {

        require(msg.sender == recoveryAddress, "sender must be recovery address");
        _;
    }

    modifier onlyOnce() {

        require(!initialized, "must not already be initialized");
        initialized = true;
        _;
    }
    
    modifier onlyInvoked() {

        require(msg.sender == address(this), "must be called from `invoke()`");
        _;
    }
    
    event Authorized(address authorizedAddress, uint256 cosigner);
    
    event EmergencyRecovery(address authorizedAddress, uint256 cosigner);

    event RecoveryAddressChanged(address previousRecoveryAddress, address newRecoveryAddress);

    event Received(address from, uint value);

    event InvocationSuccess(
        bytes32 hash,
        uint256 result,
        uint256 numOperations
    );

    function init(address _authorizedAddress, uint256 _cosigner, address _recoveryAddress) public onlyOnce {

        require(_authorizedAddress != _recoveryAddress, "Do not use the recovery address as an authorized address.");
        require(address(_cosigner) != _recoveryAddress, "Do not use the recovery address as a cosigner.");
        require(_authorizedAddress != address(0), "Authorized addresses must not be zero.");
        require(address(_cosigner) != address(0), "Initial cosigner must not be zero.");
        
        recoveryAddress = _recoveryAddress;
        authVersion = AUTH_VERSION_INCREMENTOR;
        authorizations[authVersion + uint256(_authorizedAddress)] = _cosigner;
        
        emit Authorized(_authorizedAddress, _cosigner);
    }

    function() external payable {
        require(msg.data.length == 0, "Invalid transaction.");
        if (msg.value > 0) {
            emit Received(msg.sender, msg.value);
        }
    }
    
    function setAuthorized(address _authorizedAddress, uint256 _cosigner) external onlyInvoked {

        
        
        require(_authorizedAddress != address(0), "Authorized addresses must not be zero.");
        require(_authorizedAddress != recoveryAddress, "Do not use the recovery address as an authorized address.");
        require(address(_cosigner) == address(0) || address(_cosigner) != recoveryAddress, "Do not use the recovery address as a cosigner.");
 
        authorizations[authVersion + uint256(_authorizedAddress)] = _cosigner;
        emit Authorized(_authorizedAddress, _cosigner);
    }
    
    function emergencyRecovery(address _authorizedAddress, uint256 _cosigner) external onlyRecoveryAddress {

        require(_authorizedAddress != address(0), "Authorized addresses must not be zero.");
        require(_authorizedAddress != recoveryAddress, "Do not use the recovery address as an authorized address.");
        require(address(_cosigner) != address(0), "The cosigner must not be zero.");

        authVersion += AUTH_VERSION_INCREMENTOR;

        authorizations[authVersion + uint256(_authorizedAddress)] = _cosigner;
        emit EmergencyRecovery(_authorizedAddress, _cosigner);
    }

    function setRecoveryAddress(address _recoveryAddress) external onlyInvoked {

        require(
            address(authorizations[authVersion + uint256(_recoveryAddress)]) == address(0),
            "Do not use an authorized address as the recovery address."
        );
 
        address previous = recoveryAddress;
        recoveryAddress = _recoveryAddress;

        emit RecoveryAddressChanged(previous, recoveryAddress);
    }

    function recoverGas(uint256 _version, address[] _keys) external {

        require(_version > 0 && _version < 0xffffffff, "Invalid version number.");
        
        uint256 shiftedVersion = _version << 160;

        require(shiftedVersion < authVersion, "You can only recover gas from expired authVersions.");

        for (uint256 i = 0; i < _keys.length; ++i) {
            delete(authorizations[shiftedVersion + uint256(_keys[i])]);
        }
    }

    function isValidSignature(bytes32 hash, bytes _signature) external view returns (bytes4) {

        
        bytes32 operationHash = keccak256(
            abi.encodePacked(
            EIP191_PREFIX,
            EIP191_VERSION_DATA,
            this,
            hash));

        bytes32[2] memory r;
        bytes32[2] memory s;
        uint8[2] memory v;
        address signer;
        address cosigner;

        if (_signature.length == 65) {
            (r[0], s[0], v[0]) = _signature.extractSignature(0);
            signer = ecrecover(operationHash, v[0], r[0], s[0]);
            cosigner = signer;
        } else if (_signature.length == 130) {
            (r[0], s[0], v[0]) = _signature.extractSignature(0);
            (r[1], s[1], v[1]) = _signature.extractSignature(65);
            signer = ecrecover(operationHash, v[0], r[0], s[0]);
            cosigner = ecrecover(operationHash, v[1], r[1], s[1]);
        } else {
            return 0;
        }
            
        if (signer == address(0)) {
            return 0;
        }

        if (cosigner == address(0)) {
            return 0;
        }

        if (address(authorizations[authVersion + uint256(signer)]) != cosigner) {
            return 0;
        }

        return ERC1271_VALIDSIGNATURE;
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {

        return
            interfaceID == this.supportsInterface.selector || // ERC165
            interfaceID == ERC721_RECEIVED_FINAL || // ERC721 Final
            interfaceID == ERC721_RECEIVED_DRAFT || // ERC721 Draft
            interfaceID == ERC223_ID || // ERC223
            interfaceID == ERC1271_VALIDSIGNATURE; // ERC1271
    }

    function invoke0(bytes data) external {


        require(address(authorizations[authVersion + uint256(msg.sender)]) == msg.sender, "Invalid authorization.");

        internalInvoke(0, data);
    }

    function invoke1CosignerSends(uint8 v, bytes32 r, bytes32 s, uint256 nonce, address authorizedAddress, bytes data) external {

        require(v == 27 || v == 28, "Invalid signature version.");

        bytes32 operationHash = keccak256(
            abi.encodePacked(
            EIP191_PREFIX,
            EIP191_VERSION_DATA,
            this,
            nonce,
            authorizedAddress,
            data));
 
        address signer = ecrecover(operationHash, v, r, s);

        require(signer != address(0), "Invalid signature.");

        require(nonce == nonces[signer], "must use correct nonce");

        require(signer == authorizedAddress, "authorized addresses must be equal");

        address requiredCosigner = address(authorizations[authVersion + uint256(signer)]);
        
        require(requiredCosigner == signer || requiredCosigner == msg.sender, "Invalid authorization.");

        nonces[signer] = nonce + 1;

        internalInvoke(operationHash, data);
    }

    function invoke1SignerSends(uint8 v, bytes32 r, bytes32 s, bytes data) external {

        require(v == 27 || v == 28, "Invalid signature version.");
        
        uint256 nonce = nonces[msg.sender];

        bytes32 operationHash = keccak256(
            abi.encodePacked(
            EIP191_PREFIX,
            EIP191_VERSION_DATA,
            this,
            nonce,
            msg.sender,
            data));
 
        address cosigner = ecrecover(operationHash, v, r, s);
        
        require(cosigner != address(0), "Invalid signature.");

        address requiredCosigner = address(authorizations[authVersion + uint256(msg.sender)]);
        
        require(requiredCosigner == cosigner || requiredCosigner == msg.sender, "Invalid authorization.");

        nonces[msg.sender] = nonce + 1;
 
        internalInvoke(operationHash, data);
    }

    function invoke2(uint8[2] v, bytes32[2] r, bytes32[2] s, uint256 nonce, address authorizedAddress, bytes data) external {

        require(v[0] == 27 || v[0] == 28, "invalid signature version v[0]");
        require(v[1] == 27 || v[1] == 28, "invalid signature version v[1]");
 
        bytes32 operationHash = keccak256(
            abi.encodePacked(
            EIP191_PREFIX,
            EIP191_VERSION_DATA,
            this,
            nonce,
            authorizedAddress,
            data));
 
        address signer = ecrecover(operationHash, v[0], r[0], s[0]);
        address cosigner = ecrecover(operationHash, v[1], r[1], s[1]);

        require(signer != address(0), "Invalid signature for signer.");
        require(cosigner != address(0), "Invalid signature for cosigner.");

        require(signer == authorizedAddress, "authorized addresses must be equal");

        require(nonce == nonces[signer], "must use correct nonce for signer");

        address requiredCosigner = address(authorizations[authVersion + uint256(signer)]);
        
        require(requiredCosigner == signer || requiredCosigner == cosigner, "Invalid authorization.");

        nonces[signer]++;

        internalInvoke(operationHash, data);
    }

    function internalInvoke(bytes32 operationHash, bytes data) internal {

        uint256 numOps;
        uint256 result;

        string memory invalidLengthMessage = "Data field too short";
        string memory callFailed = "Call failed";

        require(data.length >= 85, invalidLengthMessage);

        assembly {
            let memPtr := add(data, 32)

            let revertFlag := byte(0, mload(memPtr))

            let endPtr := add(memPtr, mload(data))

            memPtr := add(memPtr, 1)

            for { } lt(memPtr, endPtr) { } {
                let len := mload(add(memPtr, 52))
                
                let opEnd := add(len, add(memPtr, 84))

                if gt(opEnd, endPtr) {
                    revert(add(invalidLengthMessage, 32), mload(invalidLengthMessage))
                }

                if eq(0, call(gas, div(mload(memPtr), exp(2, 96)), mload(add(memPtr, 20)), add(memPtr, 84), len, 0, 0)) {
                    
                    switch revertFlag
                    case 1 {
                        revert(add(callFailed, 32), mload(callFailed))
                    }
                    default {
                        result := or(result, exp(2, numOps))
                    }
                }

                numOps := add(numOps, 1)
             
                memPtr := opEnd
            }
        }

        emit InvocationSuccess(operationHash, result, numOps);
    }
}


pragma solidity ^0.4.24;



contract CloneableWallet is CoreWallet {


    constructor () public {
        initialized = true;
    }
}