
pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}// GPL-3.0-or-later
pragma solidity 0.8.10;


library TransferHelper {

  function safeTransfer(
    address token,
    address to,
    uint256 value
  ) internal {

    (bool success, bytes memory data) = token.call(
      abi.encodeWithSelector(0xa9059cbb, to, value)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      'TransferHelper::safeTransfer: transfer failed'
    );
  }

  function safeTransferFrom(
    address token,
    address from,
    address to,
    uint256 value
  ) internal {

    (bool success, bytes memory returndata) = token.call(
      abi.encodeWithSelector(0x23b872dd, from, to, value)
    );
    Address.verifyCallResult(
      success,
      returndata,
      'TransferHelper::transferFrom: transferFrom failed'
    );
  }
}// UNLICENSED
pragma solidity 0.8.10;


abstract contract ERC20Interface {
  function transfer(address _to, uint256 _value)
    public
    virtual
    returns (bool success);

  function balanceOf(address _owner)
    public
    virtual
    view
    returns (uint256 balance);
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}pragma solidity ^0.8.0;


interface IForwarder is IERC165 {

  function setAutoFlush721(bool autoFlush) external;


  function setAutoFlush1155(bool autoFlush) external;


  function flushTokens(address tokenContractAddress) external;


  function flushERC721Token(address tokenContractAddress, uint256 tokenId)
    external;


  function flushERC1155Tokens(address tokenContractAddress, uint256 tokenId)
    external;


  function batchFlushERC1155Tokens(
    address tokenContractAddress,
    uint256[] calldata tokenIds
  ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// Apache-2.0
pragma solidity 0.8.10;


contract WalletSimple is IERC721Receiver, ERC1155Receiver {

  event Deposited(address from, uint256 value, bytes data);
  event SafeModeActivated(address msgSender);
  event Transacted(
    address msgSender, // Address of the sender of the message initiating the transaction
    address otherSigner, // Address of the signer (second signature) used to initiate the transaction
    bytes32 operation, // Operation hash (see Data Formats)
    address toAddress, // The address the transaction was sent to
    uint256 value, // Amount of Wei sent to the address
    bytes data // Data sent when invoking the transaction
  );

  event BatchTransfer(address sender, address recipient, uint256 value);
  event BatchTransacted(
    address msgSender, // Address of the sender of the message initiating the transaction
    address otherSigner, // Address of the signer (second signature) used to initiate the transaction
    bytes32 operation // Operation hash (see Data Formats)
  );

  mapping(address => bool) public signers; // The addresses that can co-sign transactions on the wallet
  bool public safeMode = false; // When active, wallet may only send to signer addresses
  bool public initialized = false; // True if the contract has been initialized

  uint256 private constant MAX_SEQUENCE_ID_INCREASE = 10000;
  uint256 constant SEQUENCE_ID_WINDOW_SIZE = 10;
  uint256[SEQUENCE_ID_WINDOW_SIZE] recentSequenceIds;

  function init(address[] calldata allowedSigners) external onlyUninitialized {

    require(allowedSigners.length == 3, 'Invalid number of signers');

    for (uint8 i = 0; i < allowedSigners.length; i++) {
      require(allowedSigners[i] != address(0), 'Invalid signer');
      signers[allowedSigners[i]] = true;
    }

    initialized = true;
  }

  function getNetworkId() internal virtual pure returns (string memory) {

    return 'ETHER';
  }

  function getTokenNetworkId() internal virtual pure returns (string memory) {

    return 'ERC20';
  }

  function getBatchNetworkId() internal virtual pure returns (string memory) {

    return 'ETHER-Batch';
  }

  function isSigner(address signer) public view returns (bool) {

    return signers[signer];
  }

  modifier onlySigner {

    require(isSigner(msg.sender), 'Non-signer in onlySigner method');
    _;
  }

  modifier onlyUninitialized {

    require(!initialized, 'Contract already initialized');
    _;
  }

  fallback() external payable {
    if (msg.value > 0) {
      emit Deposited(msg.sender, msg.value, msg.data);
    }
  }

  receive() external payable {
    if (msg.value > 0) {
      emit Deposited(msg.sender, msg.value, '');
    }
  }

  function sendMultiSig(
    address toAddress,
    uint256 value,
    bytes calldata data,
    uint256 expireTime,
    uint256 sequenceId,
    bytes calldata signature
  ) external onlySigner {

    bytes32 operationHash = keccak256(
      abi.encodePacked(
        getNetworkId(),
        toAddress,
        value,
        data,
        expireTime,
        sequenceId
      )
    );

    address otherSigner = verifyMultiSig(
      toAddress,
      operationHash,
      signature,
      expireTime,
      sequenceId
    );

    (bool success, ) = toAddress.call{ value: value }(data);
    require(success, 'Call execution failed');

    emit Transacted(
      msg.sender,
      otherSigner,
      operationHash,
      toAddress,
      value,
      data
    );
  }

  function sendMultiSigBatch(
    address[] calldata recipients,
    uint256[] calldata values,
    uint256 expireTime,
    uint256 sequenceId,
    bytes calldata signature
  ) external onlySigner {

    require(recipients.length != 0, 'Not enough recipients');
    require(
      recipients.length == values.length,
      'Unequal recipients and values'
    );
    require(recipients.length < 256, 'Too many recipients, max 255');

    bytes32 operationHash = keccak256(
      abi.encodePacked(
        getBatchNetworkId(),
        recipients,
        values,
        expireTime,
        sequenceId
      )
    );

    require(!safeMode, 'Batch in safe mode');
    address otherSigner = verifyMultiSig(
      address(0x0),
      operationHash,
      signature,
      expireTime,
      sequenceId
    );

    batchTransfer(recipients, values);
    emit BatchTransacted(msg.sender, otherSigner, operationHash);
  }

  function batchTransfer(
    address[] calldata recipients,
    uint256[] calldata values
  ) internal {

    for (uint256 i = 0; i < recipients.length; i++) {
      require(address(this).balance >= values[i], 'Insufficient funds');

      (bool success, ) = recipients[i].call{ value: values[i] }('');
      require(success, 'Call failed');

      emit BatchTransfer(msg.sender, recipients[i], values[i]);
    }
  }

  function sendMultiSigToken(
    address toAddress,
    uint256 value,
    address tokenContractAddress,
    uint256 expireTime,
    uint256 sequenceId,
    bytes calldata signature
  ) external onlySigner {

    bytes32 operationHash = keccak256(
      abi.encodePacked(
        getTokenNetworkId(),
        toAddress,
        value,
        tokenContractAddress,
        expireTime,
        sequenceId
      )
    );

    verifyMultiSig(toAddress, operationHash, signature, expireTime, sequenceId);

    TransferHelper.safeTransfer(tokenContractAddress, toAddress, value);
  }

  function flushForwarderTokens(
    address payable forwarderAddress,
    address tokenContractAddress
  ) external onlySigner {

    IForwarder forwarder = IForwarder(forwarderAddress);
    forwarder.flushTokens(tokenContractAddress);
  }

  function flushERC721ForwarderTokens(
    address payable forwarderAddress,
    address tokenContractAddress,
    uint256 tokenId
  ) external onlySigner {

    IForwarder forwarder = IForwarder(forwarderAddress);
    forwarder.flushERC721Token(tokenContractAddress, tokenId);
  }

  function batchFlushERC1155ForwarderTokens(
    address payable forwarderAddress,
    address tokenContractAddress,
    uint256[] calldata tokenIds
  ) external onlySigner {

    IForwarder forwarder = IForwarder(forwarderAddress);
    forwarder.batchFlushERC1155Tokens(tokenContractAddress, tokenIds);
  }

  function flushERC1155ForwarderTokens(
    address payable forwarderAddress,
    address tokenContractAddress,
    uint256 tokenId
  ) external onlySigner {

    IForwarder forwarder = IForwarder(forwarderAddress);
    forwarder.flushERC1155Tokens(tokenContractAddress, tokenId);
  }

  function setAutoFlush721(address forwarderAddress, bool autoFlush)
    external
    onlySigner
  {

    IForwarder forwarder = IForwarder(forwarderAddress);
    forwarder.setAutoFlush721(autoFlush);
  }

  function setAutoFlush1155(address forwarderAddress, bool autoFlush)
    external
    onlySigner
  {

    IForwarder forwarder = IForwarder(forwarderAddress);
    forwarder.setAutoFlush1155(autoFlush);
  }

  function verifyMultiSig(
    address toAddress,
    bytes32 operationHash,
    bytes calldata signature,
    uint256 expireTime,
    uint256 sequenceId
  ) private returns (address) {

    address otherSigner = recoverAddressFromSignature(operationHash, signature);

    require(!safeMode || isSigner(toAddress), 'External transfer in safe mode');

    require(expireTime >= block.timestamp, 'Transaction expired');

    tryInsertSequenceId(sequenceId);

    require(isSigner(otherSigner), 'Invalid signer');

    require(otherSigner != msg.sender, 'Signers cannot be equal');

    return otherSigner;
  }

  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes memory _data
  ) external virtual override returns (bytes4) {

    return this.onERC721Received.selector;
  }

  function onERC1155Received(
    address _operator,
    address _from,
    uint256 id,
    uint256 value,
    bytes calldata data
  ) external virtual override returns (bytes4) {

    return this.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(
    address _operator,
    address _from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
  ) external virtual override returns (bytes4) {

    return this.onERC1155BatchReceived.selector;
  }

  function activateSafeMode() external onlySigner {

    safeMode = true;
    emit SafeModeActivated(msg.sender);
  }

  function recoverAddressFromSignature(
    bytes32 operationHash,
    bytes memory signature
  ) private pure returns (address) {

    require(signature.length == 65, 'Invalid signature - wrong length');

    bytes32 r;
    bytes32 s;
    uint8 v;

    assembly {
      r := mload(add(signature, 32))
      s := mload(add(signature, 64))
      v := and(mload(add(signature, 65)), 255)
    }
    if (v < 27) {
      v += 27; // Ethereum versions are 27 or 28 as opposed to 0 or 1 which is submitted by some signing libs
    }

    require(
      uint256(s) <=
        0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
      "ECDSA: invalid signature 's' value"
    );

    return ecrecover(operationHash, v, r, s);
  }

  function tryInsertSequenceId(uint256 sequenceId) private onlySigner {

    uint256 lowestValueIndex = 0;


      uint256[SEQUENCE_ID_WINDOW_SIZE] memory _recentSequenceIds
     = recentSequenceIds;
    for (uint256 i = 0; i < SEQUENCE_ID_WINDOW_SIZE; i++) {
      require(_recentSequenceIds[i] != sequenceId, 'Sequence ID already used');

      if (_recentSequenceIds[i] < _recentSequenceIds[lowestValueIndex]) {
        lowestValueIndex = i;
      }
    }

    require(
      sequenceId > _recentSequenceIds[lowestValueIndex],
      'Sequence ID below window'
    );

    require(
      sequenceId <=
        (_recentSequenceIds[lowestValueIndex] + MAX_SEQUENCE_ID_INCREASE),
      'Sequence ID above maximum'
    );

    recentSequenceIds[lowestValueIndex] = sequenceId;
  }

  function getNextSequenceId() external view returns (uint256) {

    uint256 highestSequenceId = 0;
    for (uint256 i = 0; i < SEQUENCE_ID_WINDOW_SIZE; i++) {
      if (recentSequenceIds[i] > highestSequenceId) {
        highestSequenceId = recentSequenceIds[i];
      }
    }
    return highestSequenceId + 1;
  }
}