
pragma solidity ^0.5.5;
library SigUtils {

    function ecrecover2 (
        bytes32 _hash, 
        bytes memory _signature
    ) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := and(mload(add(_signature, 65)), 255)
        }
        if (v < 27) {
            v += 27;
        }
        return ecrecover(
            _hash,
            v,
            r,
            s
        );
    }
}
contract Marmo {

    event Relayed(bytes32 indexed _id, address _implementation, bytes _data);
    event Canceled(bytes32 indexed _id);
    address private constant INVALID_ADDRESS = address(0x9431Bab00000000000000000000000039bD955c9);
    bytes32 private constant SIGNER_SLOT = keccak256("marmo.wallet.signer");
    mapping(bytes32 => bytes32) private intentReceipt;
    function() external payable {}
    function init(address _signer) external payable {

        address signer;
        bytes32 signerSlot = SIGNER_SLOT;
        assembly { signer := sload(signerSlot) }
        require(signer == address(0), "Signer already defined");
        assembly { sstore(signerSlot, _signer) }
    }
    function signer() public view returns (address _signer) {

        bytes32 signerSlot = SIGNER_SLOT;
        assembly { _signer := sload(signerSlot) }
    } 
    function relayedBy(bytes32 _id) external view returns (address _relayer) {

        (,,_relayer) = _decodeReceipt(intentReceipt[_id]);
    }
    function relayedAt(bytes32 _id) external view returns (uint256 _block) {

        (,_block,) = _decodeReceipt(intentReceipt[_id]);
    }
    function isCanceled(bytes32 _id) external view returns (bool _canceled) {

        (_canceled,,) = _decodeReceipt(intentReceipt[_id]);
    }
    function relay(
        address _implementation,
        bytes calldata _data,
        bytes calldata _signature
    ) external payable returns (
        bytes memory result
    ) {

        bytes32 id = keccak256(
            abi.encodePacked(
                address(this),
                _implementation,
                keccak256(_data)
            )
        );
        if (intentReceipt[id] != bytes32(0)) {
            (bool canceled, , address relayer) = _decodeReceipt(intentReceipt[id]);
            require(relayer == address(0), "Intent already relayed");
            require(!canceled, "Intent was canceled");
            revert("Unknown error");
        }
        address _signer = signer();
        require(_signer != INVALID_ADDRESS, "Signer is not a valid address");
        require(_signer == msg.sender || _signer == SigUtils.ecrecover2(id, _signature), "Invalid signature");
        intentReceipt[id] = _encodeReceipt(false, block.number, msg.sender);
        emit Relayed(id, _implementation, _data);
        bool success;
        (success, result) = _implementation.delegatecall(abi.encode(id, _data));
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }
    function cancel(bytes32 _id) external {

        require(msg.sender == address(this), "Only wallet can cancel txs");
        if (intentReceipt[_id] != bytes32(0)) {
            (bool canceled, , address relayer) = _decodeReceipt(intentReceipt[_id]);
            require(relayer == address(0), "Intent already relayed");
            require(!canceled, "Intent was canceled");
            revert("Unknown error");
        }
        emit Canceled(_id);
        intentReceipt[_id] = _encodeReceipt(true, 0, address(0));
    }
    function _encodeReceipt(
        bool _canceled,
        uint256 _block,
        address _relayer
    ) internal pure returns (bytes32 _receipt) {

        assembly {
            _receipt := or(shl(255, _canceled), or(shl(160, _block), _relayer))
        }
    }
    function _decodeReceipt(bytes32 _receipt) internal pure returns (
        bool _canceled,
        uint256 _block,
        address _relayer
    ) {

        assembly {
            _canceled := shr(255, _receipt)
            _block := and(shr(160, _receipt), 0x7fffffffffffffffffffffff)
            _relayer := and(_receipt, 0xffffffffffffffffffffffffffffffffffffffff)
        }
    }
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {

        return bytes4(0x150b7a02);
    }
}