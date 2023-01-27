pragma solidity ^0.8.0;

library ECDSA {


    function recover(bytes32 hash, bytes memory signature)
    internal
    pure
    returns (address)
    {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    function toBytesPrefixed(bytes32 hash)
    internal
    pure
    returns (bytes32)
    {

        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
    }
}// Apache 2.0
pragma solidity ^0.8.0;


library Array {

    function indexOf(address[] storage values, address value) internal view returns(uint) {

        uint i = 0;

        while (values[i] != value && i <= values.length) {
            i++;
        }

        return i;
    }

    function removeByValue(address[] storage values, address value) internal {

        uint i = indexOf(values, value);

        removeByIndex(values, i);
    }

    function removeByIndex(address[] storage values, uint i) internal {

        while (i<values.length-1) {
            values[i] = values[i+1];
            i++;
        }

        values.pop();
    }
}// Apache 2.0
pragma solidity ^0.8.0;



contract DistributedOwnable {

    using ECDSA for bytes32;
    using Array for address[];

    mapping (address => bool) private _owners;
    address[] private _ownersList;

    event OwnershipGranted(address indexed newOwner);
    event OwnershipRemoved(address indexed removedOwner);

    function isOwner(address checkAddr) public view returns (bool) {

        return _owners[checkAddr];
    }

    function getOwners() public view returns(address[] memory) {

        return _ownersList;
    }

    function recoverSignature(
        bytes memory payload,
        bytes memory signature
    ) public pure returns(address) {

        return keccak256(payload).toBytesPrefixed().recover(signature);
    }

    function grantOwnership(address newOwner) internal {

        require(!_owners[newOwner], 'Already owner');

        _owners[newOwner] = true;
        _ownersList.push(newOwner);

        emit OwnershipGranted(newOwner);
    }

    function removeOwnership(address ownerToRemove) internal {

        require(_owners[ownerToRemove], 'Not an owner');

        _owners[ownerToRemove] = false;
        _ownersList.removeByValue(ownerToRemove);

        emit OwnershipRemoved(ownerToRemove);
    }
}// Apache 2.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


interface IBridge {

    function isRelay(address candidate) external view returns (bool);

    function countRelaysSignatures(
        bytes calldata payload,
        bytes[] calldata signatures
    ) external view returns(uint);


    struct BridgeConfiguration {
        uint16 nonce;
        uint16 bridgeUpdateRequiredConfirmations;
    }

    struct BridgeRelay {
        uint16 nonce;
        address account;
        bool action;
    }

    function getConfiguration() external view returns (BridgeConfiguration memory);

}// Apache 2.0
pragma solidity ^0.8.0;


contract Nonce {

    mapping(uint16 => bool) public nonce;

    event NonceUsed(uint16 _nonce);

    function nonceNotUsed(uint16 _nonce) public view returns(bool) {

        return !nonce[_nonce];
    }

    function rememberNonce(uint16 _nonce) internal {

        nonce[_nonce] = true;

        emit NonceUsed(_nonce);
    }
}// Apache 2.0
pragma solidity ^0.8.0;

contract RedButton {

    address public admin;

    function _setAdmin(address _admin) internal {

        admin = _admin;
    }

    function transferAdmin(address _newAdmin) public onlyAdmin {

        require(_newAdmin != address(0), 'Cant set admin to zero address');
        _setAdmin(_newAdmin);
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, 'Sender not admin');
        _;
    }

    function externalCallEth(
        address payable[] memory  _to,
        bytes[] memory _data,
        uint256[] memory weiAmount
    ) onlyAdmin public payable {

        require(
            _to.length == _data.length && _data.length == weiAmount.length,
            "Parameters should be equal length"
        );

        for (uint16 i = 0; i < _to.length; i++) {
            _cast(_to[i], _data[i], weiAmount[i]);
        }
    }

    function _cast(
        address payable _to,
        bytes memory _data,
        uint256 weiAmount
    ) internal {

        bytes32 response;

        assembly {
            let succeeded := call(sub(gas(), 5000), _to, weiAmount, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)
            switch iszero(succeeded)
            case 1 {
                revert(0, 0)
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// Apache 2.0
pragma solidity ^0.8.0;





contract Bridge is Initializable, DistributedOwnable, RedButton, Nonce, IBridge {

    BridgeConfiguration bridgeConfiguration;

    function initialize(
        address[] memory owners,
        address admin,
        BridgeConfiguration memory _bridgeConfiguration
    ) public initializer {

        for (uint i=0; i < owners.length; i++) {
            grantOwnership(owners[i]);
        }

        _setAdmin(admin);

        bridgeConfiguration = _bridgeConfiguration;
    }

    function isRelay(
        address candidate
    ) override public view returns(bool) {

        return isOwner(candidate);
    }

    function countRelaysSignatures(
        bytes memory payload,
        bytes[] memory signatures
    ) public override view returns(uint) {

        uint ownersConfirmations = 0;

        address[] memory signers = new address[](signatures.length);

        for (uint i=0; i<signatures.length; i++) {
            address signer = recoverSignature(payload, signatures[i]);

            if (isOwner(signer)) {
                for (uint u=0; u<signers.length; u++) {
                    require(signers[u] != signer, "Signer already seen");
                }

                ownersConfirmations++;
                signers[i] = signer;
            }
        }

        return ownersConfirmations;
    }

    function updateBridgeConfiguration(
        bytes memory payload,
        bytes[] memory signatures
    ) public {

        require(
            countRelaysSignatures(
                payload,
                signatures
            ) >= bridgeConfiguration.bridgeUpdateRequiredConfirmations,
            'Not enough confirmations'
        );

        (BridgeConfiguration memory _bridgeConfiguration) = abi.decode(payload, (BridgeConfiguration));

        require(nonceNotUsed(_bridgeConfiguration.nonce), 'Nonce already used');

        bridgeConfiguration = _bridgeConfiguration;

        rememberNonce(_bridgeConfiguration.nonce);
    }

    function updateBridgeRelay(
        bytes memory payload,
        bytes[] memory signatures
    ) public {

        require(
            countRelaysSignatures(
                payload,
                signatures
            ) >= bridgeConfiguration.bridgeUpdateRequiredConfirmations,
            'Not enough confirmations'
        );

        (BridgeRelay memory bridgeRelay) = abi.decode(payload, (BridgeRelay));

        require(nonceNotUsed(bridgeRelay.nonce), 'Nonce already used');

        if (bridgeRelay.action) {
            grantOwnership(bridgeRelay.account);
        } else {
            removeOwnership(bridgeRelay.account);
        }

        rememberNonce(bridgeRelay.nonce);
    }

    function getConfiguration() public view override returns (BridgeConfiguration memory) {

        return bridgeConfiguration;
    }
}