
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
}// MIT

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
}// MIT

pragma solidity >=0.4.0;
library RLPEncode {


    function encodeBytes(bytes memory self) internal pure returns (bytes memory) {

        bytes memory encoded;
        if (self.length == 1 && uint8(self[0]) <= 128) {
            encoded = self;
        } else {
            encoded = concat(encodeLength(self.length, 128), self);
        }
        return encoded;
    }

    function encodeList(bytes[] memory self) internal pure returns (bytes memory) {

        bytes memory list = flatten(self);
        return concat(encodeLength(list.length, 192), list);
    }

    function encodeString(string memory self) internal pure returns (bytes memory) {

        return encodeBytes(bytes(self));
    }

    function encodeAddress(address self) internal pure returns (bytes memory) {

        bytes memory inputBytes;
        assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, self))
            mstore(0x40, add(m, 52))
            inputBytes := m
        }
        return encodeBytes(inputBytes);
    }

    function encodeUint(uint self) internal pure returns (bytes memory) {

        return encodeBytes(toBinary(self));
    }

    function encodeInt(int self) internal pure returns (bytes memory) {

        return encodeUint(uint(self));
    }

    function encodeBool(bool self) internal pure returns (bytes memory) {

        bytes memory encoded = new bytes(1);
        encoded[0] = (self ? bytes1(0x01) : bytes1(0x80));
        return encoded;
    }



    function encodeLength(uint len, uint offset) private pure returns (bytes memory) {

        bytes memory encoded;
        if (len < 56) {
            encoded = new bytes(1);
            encoded[0] = bytes32(len + offset)[31];
        } else {
            uint lenLen;
            uint i = 1;
            while (len / i != 0) {
                lenLen++;
                i *= 256;
            }

            encoded = new bytes(lenLen + 1);
            encoded[0] = bytes32(lenLen + offset + 55)[31];
            for(i = 1; i <= lenLen; i++) {
                encoded[i] = bytes32((len / (256**(lenLen-i))) % 256)[31];
            }
        }
        return encoded;
    }

    function toBinary(uint _x) private pure returns (bytes memory) {

        bytes memory b = new bytes(32);
        assembly { 
            mstore(add(b, 32), _x) 
        }
        uint i;
        for (i = 0; i < 32; i++) {
            if (b[i] != 0) {
                break;
            }
        }
        bytes memory res = new bytes(32 - i);
        for (uint j = 0; j < res.length; j++) {
            res[j] = b[i++];
        }
        return res;
    }

    function memcpy(uint _dest, uint _src, uint _len) private pure {

        uint dest = _dest;
        uint src = _src;
        uint len = _len;

        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function flatten(bytes[] memory _list) private pure returns (bytes memory) {

        if (_list.length == 0) {
            return new bytes(0);
        }

        uint len;
        uint i;
        for (i = 0; i < _list.length; i++) {
            len += _list[i].length;
        }

        bytes memory flattened = new bytes(len);
        uint flattenedPtr;
        assembly { flattenedPtr := add(flattened, 0x20) }

        for(i = 0; i < _list.length; i++) {
            bytes memory item = _list[i];
            
            uint listPtr;
            assembly { listPtr := add(item, 0x20)}

            memcpy(flattenedPtr, listPtr, item.length);
            flattenedPtr += _list[i].length;
        }

        return flattened;
    }

    function concat(bytes memory _preBytes, bytes memory _postBytes) private pure returns (bytes memory) {

        bytes memory tempBytes;

        assembly {
            tempBytes := mload(0x40)

            let length := mload(_preBytes)
            mstore(tempBytes, length)

            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)

            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))

            mc := end
            end := add(mc, length)

            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }

            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31)
            ))
        }

        return tempBytes;
    }
}/**
* LicenseRef-Aktionariat
*
* MIT License with Automated License Fee Payments
*
* Copyright (c) 2020 Aktionariat AG (aktionariat.com)
*
* Permission is hereby granted to any person obtaining a copy of this software
* and associated documentation files (the "Software"), to deal in the Software
* without restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies of the
* Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* - The above copyright notice and this permission notice shall be included in
*   all copies or substantial portions of the Software.
* - All automated license fee payments integrated into this and related Software
*   are preserved.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

pragma solidity ^0.8.0;

contract Nonce {


    uint256 public constant MAX_INCREASE = 100;
    
    uint256 private compound;
    
    constructor(){
        setBoth(128, 0);
    }
    
    function nextNonce() external view returns (uint256){

        return getMax() + 1;
    }

    function isFree(uint128 nonce) external view returns (bool){

        uint128 max = getMax();
        return isValidHighNonce(max, nonce) || isValidLowNonce(max, getRegister(), nonce);
    }

    function flagUsed(uint128 nonce) internal {

        uint256 comp = compound;
        uint128 max = uint128(comp);
        uint128 reg = uint128(comp >> 128);
        if (isValidHighNonce(max, nonce)){
            setBoth(nonce, ((reg << 1) | 0x1) << (nonce - max - 1));
        } else if (isValidLowNonce(max, reg, nonce)){
            setBoth(max, uint128(reg | 0x1 << (max - nonce - 1)));
        } else {
            require(false);
        }
    }
    
    function getMax() private view returns (uint128) {

        return uint128(compound);
    }
    
    function getRegister() private view returns (uint128) {

        return uint128(compound >> 128);
    }
    
    function setBoth(uint128 max, uint128 reg) private {

        compound = uint256(reg) << 128 | max;
    }

    function isValidHighNonce(uint128 max, uint128 nonce) private pure returns (bool){

        return nonce > max && nonce <= max + MAX_INCREASE;
    }

    function isValidLowNonce(uint128 max, uint128 reg, uint256 nonce) private pure returns (bool){

        uint256 diff = max - nonce;
        return diff > 0 && diff <= 128 && ((0x1 << (diff - 1)) & reg == 0);
    }
    
}/**
 * MIT
 */

pragma solidity ^0.8.0;


contract MultiSigWallet is Nonce, Initializable {


  mapping (address => uint8) public signers; // The addresses that can co-sign transactions and the number of signatures needed

  uint16 public signerCount;
  bytes public contractId; // most likely unique id of this contract

  event SignerChange(
    address indexed signer,
    uint8 cosignaturesNeeded
  );

  event Transacted(
    address indexed toAddress,  // The address the transaction was sent to
    bytes4 selector, // selected operation
    address[] signers // Addresses of the signers used to initiate the transaction
  );

  constructor () {
  }

  function initialize(address owner) external initializer {

    contractId = toBytes(uint32(uint160(address(this))));
    _setSigner(owner, 1); // set initial owner
  }

  receive() external payable {
  }

  function checkSignatures(uint128 nonce, address to, uint value, bytes calldata data,
    uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external view returns (address[] memory) {

    bytes32 transactionHash = calculateTransactionHash(nonce, contractId, to, value, data);
    return verifySignatures(transactionHash, v, r, s);
  }

  function checkExecution(address to, uint value, bytes calldata data) external {

    Address.functionCallWithValue(to, data, value);
    require(false, "Test passed. Reverting.");
  }

  function execute(uint128 nonce, address to, uint value, bytes calldata data, uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external returns (bytes memory) {

    bytes32 transactionHash = calculateTransactionHash(nonce, contractId, to, value, data);
    address[] memory found = verifySignatures(transactionHash, v, r, s);
    bytes memory returndata = Address.functionCallWithValue(to, data, value);
    flagUsed(nonce);
    emit Transacted(to, extractSelector(data), found);
    return returndata;
  }

  function extractSelector(bytes calldata data) private pure returns (bytes4){

    if (data.length < 4){
      return bytes4(0);
    } else {
      return bytes4(data[0]) | (bytes4(data[1]) >> 8) | (bytes4(data[2]) >> 16) | (bytes4(data[3]) >> 24);
    }
  }

  function toBytes(uint number) internal pure returns (bytes memory){

    uint len = 0;
    uint temp = 1;
    while (number >= temp){
      temp = temp << 8;
      len++;
    }
    temp = number;
    bytes memory data = new bytes(len);
    for (uint i = len; i>0; i--) {
      data[i-1] = bytes1(uint8(temp));
      temp = temp >> 8;
    }
    return data;
  }

  function calculateTransactionHash(uint128 sequence, bytes memory id, address to, uint value, bytes calldata data)
    internal view returns (bytes32){

    bytes[] memory all = new bytes[](9);
    all[0] = toBytes(sequence); // sequence number instead of nonce
    all[1] = id; // contract id instead of gas price
    all[2] = toBytes(21000); // gas limit
    all[3] = abi.encodePacked(to);
    all[4] = toBytes(value);
    all[5] = data;
    all[6] = toBytes(block.chainid);
    all[7] = toBytes(0);
    for (uint i = 0; i<8; i++){
      all[i] = RLPEncode.encodeBytes(all[i]);
    }
    all[8] = all[7];
    return keccak256(RLPEncode.encodeList(all));
  }

  function verifySignatures(bytes32 transactionHash, uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s)
    public view returns (address[] memory) {

    address[] memory found = new address[](r.length);
    for (uint i = 0; i < r.length; i++) {
      address signer = ecrecover(transactionHash, v[i], r[i], s[i]);
      uint8 cosignaturesNeeded = signers[signer];
      require(cosignaturesNeeded > 0 && cosignaturesNeeded <= r.length, "cosigner error");
      found[i] = signer;
    }
    requireNoDuplicates(found);
    return found;
  }

  function requireNoDuplicates(address[] memory found) private pure {

    for (uint i = 0; i < found.length; i++) {
      for (uint j = i+1; j < found.length; j++) {
        require(found[i] != found[j], "duplicate signature");
      }
    }
  }

  function setSigner(address signer, uint8 cosignaturesNeeded) external authorized {

    _setSigner(signer, cosignaturesNeeded);
    require(signerCount > 0);
  }

  function migrate(address destination) external {

    _migrate(msg.sender, destination);
  }

  function migrate(address source, address destination) external authorized {

    _migrate(source, destination);
  }

  function _migrate(address source, address destination) private {

    require(signers[destination] == 0); // do not overwrite existing signer!
    _setSigner(destination, signers[source]);
    _setSigner(source, 0);
  }

  function _setSigner(address signer, uint8 cosignaturesNeeded) private {

    require(!Address.isContract(signer), "signer cannot be a contract");
    uint8 prevValue = signers[signer];
    signers[signer] = cosignaturesNeeded;
    if (prevValue > 0 && cosignaturesNeeded == 0){
      signerCount--;
    } else if (prevValue == 0 && cosignaturesNeeded > 0){
      signerCount++;
    }
    emit SignerChange(signer, cosignaturesNeeded);
  }

  modifier authorized() {

    require(address(this) == msg.sender || signers[msg.sender] == 1, "not authorized");
    _;
  }

}