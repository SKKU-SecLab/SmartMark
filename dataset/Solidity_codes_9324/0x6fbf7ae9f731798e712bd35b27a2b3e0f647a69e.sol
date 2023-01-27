
pragma solidity ^0.7.5;


library LibRichErrors {


    bytes4 internal constant STANDARD_ERROR_SELECTOR =
        0x08c379a0;

    function StandardError(
        string memory message
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            STANDARD_ERROR_SELECTOR,
            bytes(message)
        );
    }

    function rrevert(bytes memory errorData)
        internal
        pure
    {

        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}pragma solidity ^0.7.5;


library LibSafeMathRichErrors {


    bytes4 internal constant UINT256_BINOP_ERROR_SELECTOR =
        0xe946c1bb;

    bytes4 internal constant UINT256_DOWNCAST_ERROR_SELECTOR =
        0xc996af7b;

    enum BinOpErrorCodes {
        ADDITION_OVERFLOW,
        MULTIPLICATION_OVERFLOW,
        SUBTRACTION_UNDERFLOW,
        DIVISION_BY_ZERO
    }

    enum DowncastErrorCodes {
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT32,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96
    }

    function Uint256BinOpError(
        BinOpErrorCodes errorCode,
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            UINT256_BINOP_ERROR_SELECTOR,
            errorCode,
            a,
            b
        );
    }

    function Uint256DowncastError(
        DowncastErrorCodes errorCode,
        uint256 a
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            UINT256_DOWNCAST_ERROR_SELECTOR,
            errorCode,
            a
        );
    }
}pragma solidity ^0.7.5;



library LibSafeMath {


    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a != b) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function safeDiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (b == 0) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.DIVISION_BY_ZERO,
                a,
                b
            ));
        }
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (b > a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                a,
                b
            ));
        }
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        uint256 c = a + b;
        if (c < a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.ADDITION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function max256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        return a < b ? a : b;
    }
}/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.7.5;


library LibAddress {


    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

}/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.7.5;

interface IERC1155 {


    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _value
    );

    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _values
    );

    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    event URI(
        string _value,
        uint256 indexed _id
    );

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external;


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function balanceOf(address owner, uint256 id) external view returns (uint256);


    function balanceOfBatch(
        address[] calldata owners,
        uint256[] calldata ids
    )
        external
        view
        returns (uint256[] memory balances_);

}/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.7.5;


interface IERC1155Receiver {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.7.5;


contract MixinNonFungibleToken {

    uint256 constant internal TYPE_MASK = uint256(uint128(~0)) << 128;

    uint256 constant internal NF_INDEX_MASK = uint128(~0);

    uint256 constant internal TYPE_NF_BIT = 1 << 255;

    mapping (uint256 => address) internal nfOwners;

    mapping (address => uint256[]) internal nfOwnerMapping;

    mapping (uint256 => uint256) internal tokenIdToNFOwnerMappingOneIndex;

    function isNonFungible(uint256 id) public pure returns(bool) {

        return id & TYPE_NF_BIT == TYPE_NF_BIT;
    }

    function isFungible(uint256 id) public pure returns(bool) {

        return id & TYPE_NF_BIT == 0;
    }

    function getNonFungibleIndex(uint256 id) public pure returns(uint256) {

        return id & NF_INDEX_MASK;
    }

    function getNonFungibleBaseType(uint256 id) public pure returns(uint256) {

        return id & TYPE_MASK;
    }

    function isNonFungibleBaseType(uint256 id) public pure returns(bool) {

        return (id & TYPE_NF_BIT == TYPE_NF_BIT) && (id & NF_INDEX_MASK == 0);
    }

    function isNonFungibleItem(uint256 id) public pure returns(bool) {

        return (id & TYPE_NF_BIT == TYPE_NF_BIT) && (id & NF_INDEX_MASK != 0);
    }

    function ownerOf(uint256 id) public view returns (address) {

        return nfOwners[id];
    }

    function nfTokensOf(address _address) external view returns (uint256[] memory) {

        return nfOwnerMapping[_address];
    }

    function transferNFToken(uint256 _id, address _from, address _to) internal {

        require(nfOwners[_id] == _from, "Token not owned by the from address");

        nfOwners[_id] = _to;

        if (tokenIdToNFOwnerMappingOneIndex[_id] != 0) {
            uint256 fromTokenIdIndex = tokenIdToNFOwnerMappingOneIndex[_id] - 1;

            uint256 tokenIdToMove = nfOwnerMapping[_from][nfOwnerMapping[_from].length-1];

            nfOwnerMapping[_from][fromTokenIdIndex] = tokenIdToMove;
            nfOwnerMapping[_from].pop();
            tokenIdToNFOwnerMappingOneIndex[tokenIdToMove] = fromTokenIdIndex + 1;
        }

        nfOwnerMapping[_to].push(_id);
        tokenIdToNFOwnerMappingOneIndex[_id] = nfOwnerMapping[_to].length; // no need -1 because 1-index
    }
}// MIT
pragma solidity ^0.7.5;

contract Context {

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}pragma solidity ^0.7.5;


contract WhitelistExchangesProxy is Ownable {

    mapping(address => bool) internal proxies;

    bool public paused = true;
    
    function setPaused(bool newPaused) external onlyOwner() {

        paused = newPaused;
    }

    function updateProxyAddress(address proxy, bool status) external onlyOwner() {

        proxies[proxy] = status;
    }

    function isAddressWhitelisted(address proxy) external view returns (bool) {

        if (paused) {
            return false;
        } else {
            return proxies[proxy];
        }
    }
}/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.7.5;


contract ERC1155 is
    IERC1155,
    MixinNonFungibleToken,
    Ownable
{

    using LibAddress for address;
    using LibSafeMath for uint256;

    bytes4 constant public ERC1155_RECEIVED       = 0xf23a6e61;
    bytes4 constant public ERC1155_BATCH_RECEIVED = 0xbc197c81;

    mapping (uint256 => mapping(address => uint256)) internal balances;

    mapping (address => mapping(address => bool)) internal operatorApproval;

    address public exchangesRegistry;

    function setExchangesRegistry(address newExchangesRegistry) external onlyOwner() {

        exchangesRegistry = newExchangesRegistry;
    }

    function burn(address from, uint256 id, uint256 amount) external {

        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "INSUFFICIENT_ALLOWANCE"
        );
        require(isFungible(id), "Don't allow burn of NFTs via this function");

        balances[id][from] = balances[id][from].safeSub(amount);
        emit TransferSingle(msg.sender, from, address(0x0), id, amount);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        override
        external
    {

        require(
            to != address(0x0),
            "CANNOT_TRANSFER_TO_ADDRESS_ZERO"
        );
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "INSUFFICIENT_ALLOWANCE"
        );

        if (isNonFungible(id)) {
            require(
                    value == 1,
                    "AMOUNT_EQUAL_TO_ONE_REQUIRED"
            );
            require(
                nfOwners[id] == from,
                "NFT_NOT_OWNED_BY_FROM_ADDRESS"
            );
            transferNFToken(id, from, to);
        } else {
            balances[id][from] = balances[id][from].safeSub(value);
            balances[id][to] = balances[id][to].safeAdd(value);
        }
        emit TransferSingle(msg.sender, from, to, id, value);

        if (to.isContract()) {
            bytes4 callbackReturnValue = IERC1155Receiver(to).onERC1155Received(
                msg.sender,
                from,
                id,
                value,
                data
            );
            require(
                callbackReturnValue == ERC1155_RECEIVED,
                "BAD_RECEIVER_RETURN_VALUE"
            );
        }
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        override
        external
    {

        require(
            to != address(0x0),
            "CANNOT_TRANSFER_TO_ADDRESS_ZERO"
        );
        require(
            ids.length == values.length,
            "TOKEN_AND_VALUES_LENGTH_MISMATCH"
        );

        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "INSUFFICIENT_ALLOWANCE"
        );

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 value = values[i];

            if (isNonFungible(id)) {
                require(
                    value == 1,
                    "AMOUNT_EQUAL_TO_ONE_REQUIRED"
                );
                require(
                    nfOwners[id] == from,
                    "NFT_NOT_OWNED_BY_FROM_ADDRESS"
                );
                transferNFToken(id, from, to);
            } else {
                balances[id][from] = balances[id][from].safeSub(value);
                balances[id][to] = balances[id][to].safeAdd(value);
            }
        }
        emit TransferBatch(msg.sender, from, to, ids, values);

        if (to.isContract()) {
            bytes4 callbackReturnValue = IERC1155Receiver(to).onERC1155BatchReceived(
                msg.sender,
                from,
                ids,
                values,
                data
            );
            require(
                callbackReturnValue == ERC1155_BATCH_RECEIVED,
                "BAD_RECEIVER_RETURN_VALUE"
            );
        }
    }

    function setApprovalForAll(address operator, bool approved) external override {

        operatorApproval[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public override view returns (bool) {

        bool approved = operatorApproval[owner][operator];
        if (!approved && exchangesRegistry != address(0)) {
            return WhitelistExchangesProxy(exchangesRegistry).isAddressWhitelisted(operator) == true;
        }
        return approved;
    }

    function balanceOf(address owner, uint256 id) external override view returns (uint256) {

        if (isNonFungibleItem(id)) {
            return nfOwners[id] == owner ? 1 : 0;
        }
        return balances[id][owner];
    }

    function balanceOfBatch(address[] calldata owners, uint256[] calldata ids) external override view returns (uint256[] memory balances_) {

        require(
            owners.length == ids.length,
            "OWNERS_AND_IDS_MUST_HAVE_SAME_LENGTH"
        );

        balances_ = new uint256[](owners.length);
        for (uint256 i = 0; i < owners.length; ++i) {
            uint256 id = ids[i];
            if (isNonFungibleItem(id)) {
                balances_[i] = nfOwners[id] == owners[i] ? 1 : 0;
            } else {
                balances_[i] = balances[id][owners[i]];
            }
        }

        return balances_;
    }

    bytes4 constant private INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;
    bytes4 constant private INTERFACE_SIGNATURE_ERC1155 = 0xd9b67a26;

    function supportsInterface(bytes4 _interfaceID) external view returns (bool) {

        if (_interfaceID == INTERFACE_SIGNATURE_ERC165 ||
            _interfaceID == INTERFACE_SIGNATURE_ERC1155) {
        return true;
        }
        return false;
    }
}/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.7.5;



interface IERC1155Mintable is
    IERC1155
{


    function create(
        bool isNF
    )
        external
        returns (uint256 type_);


    function mintFungible(
        uint256 id,
        address[] calldata to,
        uint256[] calldata quantities
    )
        external;


    function mintNonFungible(
        uint256 type_,
        address[] calldata to
    )
        external;

}pragma solidity ^0.7.5;


contract MixinContractURI is Ownable {

    string public contractURI;

    function setContractURI(string calldata newContractURI) external onlyOwner() {

        contractURI = newContractURI;
    }
}pragma solidity ^0.7.5;

library LibString {

  function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory) {

      bytes memory _ba = bytes(_a);
      bytes memory _bb = bytes(_b);
      bytes memory _bc = bytes(_c);
      bytes memory _bd = bytes(_d);
      bytes memory _be = bytes(_e);
      string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
      bytes memory babcde = bytes(abcde);
      uint k = 0;
      for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
      for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
      for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
      for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
      for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
      return string(babcde);
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory) {

        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function uint2hexstr(uint i) internal pure returns (string memory) {

        if (i == 0) {
            return "0";
        }
        uint j = i;
        uint len;
        while (j != 0) {
            len++;
            j = j >> 4;
        }
        uint mask = 15;
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            uint curr = (i & mask);
            bstr[k--] = curr > 9 ? byte(uint8(55 + curr)) : byte(uint8(48 + curr));
            i = i >> 4;
        }
        return string(bstr);
    }
}pragma solidity ^0.7.5;


contract MixinTokenURI is Ownable {

    using LibString for string;

    string public baseMetadataURI = "";

    function setBaseMetadataURI(string memory newBaseMetadataURI) public onlyOwner() {

        baseMetadataURI = newBaseMetadataURI;
    }

    function uri(uint256 _id) public view returns (string memory) {

        return LibString.strConcat(
        baseMetadataURI,
        LibString.uint2hexstr(_id)
        );
    }
}/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.7.5;


contract ERC1155Mintable is
    IERC1155Mintable,
    ERC1155,
    MixinContractURI,
    MixinTokenURI
{

    using LibSafeMath for uint256;
    using LibAddress for address;

    uint256 internal nonce;

    mapping (uint256 => uint256) public maxIndex;

    mapping (uint256 => mapping(address => bool)) internal creatorApproval;

    modifier onlyCreator(uint256 _id) {

        require(creatorApproval[_id][msg.sender], "not an approved creator of id");
        _;
    }

    function setCreatorApproval(uint256 id, address creator, bool status) external onlyCreator(id) {

        creatorApproval[id][creator] = status;
    }

    function create(
        bool isNF
    )
        external
        override
        onlyOwner()
        returns (uint256 type_)
    {

        type_ = (++nonce << 128);

        if (isNF) {
            type_ = type_ | TYPE_NF_BIT;
        }

        creatorApproval[type_][msg.sender] = true;

        emit TransferSingle(
            msg.sender,
            address(0x0),
            address(0x0),
            type_,
            0
        );

        emit URI(uri(type_), type_);
    }

    function createWithType(
        uint256 type_
    )
        external
        onlyOwner()
    {


        creatorApproval[type_][msg.sender] = true;

        emit TransferSingle(
            msg.sender,
            address(0x0),
            address(0x0),
            type_,
            0
        );

        emit URI(uri(type_), type_);
    }

    function mintFungible(
        uint256 id,
        address[] calldata to,
        uint256[] calldata quantities
    )
        external
        override
        onlyCreator(id)
    {

        require(
            isFungible(id),
            "TRIED_TO_MINT_FUNGIBLE_FOR_NON_FUNGIBLE_TOKEN"
        );

        for (uint256 i = 0; i < to.length; ++i) {
            address dst = to[i];
            uint256 quantity = quantities[i];

            balances[id][dst] = quantity.safeAdd(balances[id][dst]);

            emit TransferSingle(
                msg.sender,
                address(0x0),
                dst,
                id,
                quantity
            );

            if (dst.isContract()) {
                bytes4 callbackReturnValue = IERC1155Receiver(dst).onERC1155Received(
                    msg.sender,
                    msg.sender,
                    id,
                    quantity,
                    ""
                );
                require(
                    callbackReturnValue == ERC1155_RECEIVED,
                    "BAD_RECEIVER_RETURN_VALUE"
                );
            }
        }
    }

    function mintNonFungible(
        uint256 type_,
        address[] calldata to
    )
        external
        override
        onlyCreator(type_)
    {

        require(
            isNonFungible(type_),
            "TRIED_TO_MINT_NON_FUNGIBLE_FOR_FUNGIBLE_TOKEN"
        );

        uint256 index = maxIndex[type_] + 1;

        for (uint256 i = 0; i < to.length; ++i) {
            address dst = to[i];
            uint256 id  = type_ | index + i;

            transferNFToken(id, address(0x0), dst);

            balances[type_][dst] = balances[type_][dst].safeAdd(1);

            emit TransferSingle(msg.sender, address(0x0), dst, id, 1);

            if (dst.isContract()) {
                bytes4 callbackReturnValue = IERC1155Receiver(dst).onERC1155Received(
                    msg.sender,
                    msg.sender,
                    id,
                    1,
                    ""
                );
                require(
                    callbackReturnValue == ERC1155_RECEIVED,
                    "BAD_RECEIVER_RETURN_VALUE"
                );
            }
        }

        maxIndex[type_] = to.length.safeAdd(maxIndex[type_]);
    }
}pragma solidity ^0.7.5;


library LibDateMath  {

    using LibString for string;

    struct _DateTime {
        int256 year;
        uint month;
        uint day;
    }

    uint constant DAY_IN_SECONDS = 86400;
    uint constant YEAR_IN_SECONDS = 31536000;
    uint constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint constant HOUR_IN_SECONDS = 3600;
    uint constant MINUTE_IN_SECONDS = 60;

    int256 constant ORIGIN_YEAR = 1970;

    function getDateAsString(int256 timestamp) internal pure returns (string memory) {

        _DateTime memory dt = parseTimestamp(timestamp);

        string memory monthStr;
        string memory dayStr;
        if (dt.month < 10) {
            monthStr = LibString.strConcat("0", uint2str(dt.month));
        } else {
            monthStr = uint2str(dt.month);
        }
        if (dt.day < 10) {
            dayStr = LibString.strConcat("0", uint2str(dt.day));
        } else {
            dayStr = uint2str(dt.day);
        }
        return LibString.strConcat(LibString.strConcat(monthStr, "/", dayStr, "/"), int2str(dt.year));
    }

    function isLeapYear(int256 year) public pure returns (bool) {

        if (year % 4 != 0) {
                return false;
        }
        if (year % 100 != 0) {
                return true;
        }
        if (year % 400 != 0) {
                return false;
        }
        return true;
    }

    function leapYearsBefore(int256 year) internal pure returns (uint) {

        year -= 1;
        return uint(year / 4 - year / 100 + year / 400);
    }

    function getDaysInMonth(uint month, int256 year) internal pure returns (uint) {

        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            return 31;
        }
        else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        }
        else if (isLeapYear(int256(year))) {
            return 29;
        }
        else {
            return 28;
        }
    }

    function parseTimestamp(int256 timestamp) internal pure returns (_DateTime memory) {

        uint secondsAccountedFor = 0;
        uint buf;
        uint i;
        _DateTime memory dt;

        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * uint((dt.year - ORIGIN_YEAR - int256(buf)));

        uint secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, int256(dt.year));
            if (int256(secondsInMonth + secondsAccountedFor) > timestamp) {
                dt.month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }

        for (i = 1; i <= getDaysInMonth(dt.month, int256(dt.year)); i++) {
            if (int256(DAY_IN_SECONDS + secondsAccountedFor) > timestamp) {
                dt.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }
        return dt;
    }

    function getYear(int256 timestamp) internal pure returns (int256) {

        uint secondsAccountedFor = 0;
        int256 year;
        uint numLeapYears;

        year = int256(ORIGIN_YEAR) + timestamp / int256(YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * uint((year - ORIGIN_YEAR - int256(numLeapYears)));

        while (int256(secondsAccountedFor) > timestamp) {
            if (isLeapYear(int256(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            }
            else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function int2str(int x) internal pure returns (string memory) {

        if (x < 0) {
            return LibString.strConcat("-", uint2str(uint(x * -1)));
        }
        return uint2str(uint(x));
    }
}pragma solidity ^0.7.5;
pragma abicoder v2;


contract DateMinter is Ownable {

  using LibSafeMath for uint256;
  using LibDateMath for int256;

  struct _DateToken {
    int256 timestamp;
    uint256 generation;
    bool isValid; // set if the value is set, to distinguish from the real (0,0) value - ie, epoch at gen 0.
  }

  uint256 public tokenType;
  uint256 public batchOrderLimit;

  uint256 public curMaxSupplyLimit;
  uint256 public curGeneration;
  int256 public curDateRangeStartTimestamp;
  int256 public curDateRangeEndTimestamp;

  bool public allowFutureDates;
  bool public saleStarted;
  int256 public oldestTimestamp;

  mapping(string => uint256) public referralCodeMapping; // make this a mapping to make it easily searchable if something exists
  mapping(string => uint256) public referralCodeToAmount;

  ERC1155Mintable public mintableErc1155;

  address payable public treasury;

  string[] public claimedDateStrings;

  mapping(uint256 => _DateToken) public tokenIdToTimestamp;
  mapping(string => uint256) public dateStringToTokenId; // we need this because there are multiple timestamps to a date

  mapping(uint256 => uint256) public generationToTokenCount;

  uint256 public constant reservedTokenCountCap = 30;
  uint256 public currentReservedTokenCount;
 
  constructor(
    address _mintableErc1155,
    address payable _treasury,
    uint256 _tokenType,
    uint256 _curMaxSupplyLimit,    // 3650
    uint256 _curGeneration,        // 0
    uint256 _batchOrderLimit,      // 20
    bool _allowFutureDates,        // false
    int256 _oldestTimestamp,       // some unix timestamp
    string[] memory _initialReferralCodes // ["some", "referral", "codes"]
  ) {
    mintableErc1155 = ERC1155Mintable(_mintableErc1155);
    treasury = _treasury;
    tokenType = _tokenType;
    curMaxSupplyLimit = _curMaxSupplyLimit;
    curGeneration = _curGeneration;
    batchOrderLimit = _batchOrderLimit;
    allowFutureDates = _allowFutureDates;
    oldestTimestamp = _oldestTimestamp;

    for (uint i = 0; i < _initialReferralCodes.length; i++) {
      string memory code = _initialReferralCodes[i];
      if (referralCodeMapping[code] == 0) {
        referralCodeMapping[code] = 1;
      }
    }
  }

  event UpdatedRegistry(
      uint256 tokenId,
      int256 timestamp
  );

  function totalSupply() public view returns (uint256) {

    return mintableErc1155.maxIndex(tokenType);
  }

  function getPrice() public view returns (uint256) {

    uint256 curTokenCount = generationToTokenCount[curGeneration];
    require(curTokenCount < curMaxSupplyLimit, "Sale has already ended");

    if (curTokenCount >= 3640) {
        return 1000000000000000000; // 3640 - 3649 1 ETH
    } else if (curTokenCount >= 3000) {
        return 500000000000000000; // 3000 - 3639 0.50 ETH
    } else if (curTokenCount >= 2500) {
        return 320000000000000000; // 2500  - 2999 0.32 ETH
    } else if (curTokenCount >= 2000) {
        return 160000000000000000; // 2000 - 2499 0.16 ETH
    } else if (curTokenCount >= 1500) {
        return 80000000000000000; // 1500 - 1999 0.08 ETH
    } else if (curTokenCount >= 1000) {
        return 40000000000000000; // 1000 - 1499 0.04 ETH
    } else {
        return 30000000000000000; // 0 - 999 0.03 ETH 
    }
  }

  function getDateStringFromTokenId(uint256 _tokenId) public view returns (string memory) {

    _DateToken memory dt = tokenIdToTimestamp[_tokenId];
    require(dt.isValid, "tokenId must exist in mapping");
    return dt.timestamp.getDateAsString();
  }

  function getDateStringFromTimestamp(int256 _timestamp) public view returns (string memory) {

    return _timestamp.getDateAsString();
  }

  function getDateFormat() public pure returns (string memory) {

    return "MM/DD/YYYY";
  }

  function getAllClaimedDateStrings() public view returns (string[] memory) {

    return claimedDateStrings;
  }

  function timestampsOf(address _address) public view returns (_DateToken[] memory) {

    uint256[] memory tokenIds = mintableErc1155.nfTokensOf(_address);
    _DateToken[] memory timestamps = new _DateToken[](tokenIds.length);
    for(uint i=0; i<tokenIds.length; i++){
      timestamps[i] = tokenIdToTimestamp[tokenIds[i]];
    }
    return timestamps;
  }

  function setTreasury(address payable _treasury) external onlyOwner() {

    treasury = _treasury;
  }

  function setCurMaxSupply(uint256 _curMaxSupplyLimit) external onlyOwner() {

    curMaxSupplyLimit = _curMaxSupplyLimit;
  }

  function setCurGeneration(uint256 _curGeneration) external onlyOwner() {

    curGeneration = _curGeneration;
  }

  function setSaleStarted(bool _saleStarted) external onlyOwner() {

    saleStarted = _saleStarted;
  }

  function setAllowFutureDates(bool _allowFutureDates) external onlyOwner() {

    allowFutureDates = _allowFutureDates;
  }

  function setOldestTimestamp(int256 _oldestTimestamp) external onlyOwner() {

    oldestTimestamp = _oldestTimestamp;
  }

  function addReferralCodes(string[] memory _codes) external onlyOwner() {

    for (uint i = 0; i < _codes.length; i++) {
      string memory code = _codes[i];
      if (referralCodeMapping[code] == 0) {
        referralCodeMapping[code] = 1;
      }
    }
  }

  function reserveTokens(int256[] memory _timestamps) external onlyOwner() {

    require(currentReservedTokenCount.safeAdd(_timestamps.length) <= reservedTokenCountCap, "Exceeds reservedTokenCountCap");
    for (uint i = 0; i < _timestamps.length; i++) {
      int256 dateTimestamp = _timestamps[i];

      string memory dateString = getDateStringFromTimestamp(dateTimestamp);
      if (dateStringToTokenId[dateString] != 0) {
        continue;
      }

      if (!allowFutureDates && int256(block.timestamp) < dateTimestamp) {
        continue;
      }

      if (dateTimestamp < oldestTimestamp) {
        continue;
      }

      address[] memory dsts = new address[](1);
      dsts[0] = _msgSender();
      uint256 index = mintableErc1155.maxIndex(tokenType) + 1;
      uint256 tokenId  = tokenType | index;
      mintableErc1155.mintNonFungible(tokenType, dsts);

      _DateToken memory dt;
      dt.timestamp = dateTimestamp;
      dt.generation = curGeneration;
      dt.isValid = true;

      tokenIdToTimestamp[tokenId] = dt;
      generationToTokenCount[curGeneration] += 1;

      dateStringToTokenId[dateString] = tokenId;

      claimedDateStrings.push(dateString);

      emit UpdatedRegistry(tokenId, dateTimestamp);

      currentReservedTokenCount += 1;
    }
  }

  function mint(address _dst, int256[] memory _dateTimestamps, string memory referralCode) public payable {

    require(saleStarted, "Sale has not started yet");
    uint256 curTokenCount = generationToTokenCount[curGeneration];
    require(curTokenCount < curMaxSupplyLimit, "Sale has already ended");

    uint numberOfDates = _dateTimestamps.length;
    require(numberOfDates > 0, "numberOfDates cannot be 0");
    require(numberOfDates <= batchOrderLimit, "You may not buy more than the batch limit at once");
    require(totalSupply().safeAdd(numberOfDates) <= curMaxSupplyLimit, "Exceeds curMaxSupplyLimit");
    require(getPrice().safeMul(numberOfDates) <= msg.value, "Ether value sent is not correct");

    uint256 pricePerDate = getPrice();
    uint mintedCount = 0;

    for (uint i = 0; i < numberOfDates; i++) {
      int256 dateTimestamp = _dateTimestamps[i];

      string memory dateString = getDateStringFromTimestamp(dateTimestamp);
      if (dateStringToTokenId[dateString] != 0) {
        continue;
      }

      if (!allowFutureDates && int256(block.timestamp) < dateTimestamp) {
        continue;
      }

      if (dateTimestamp < oldestTimestamp) {
        continue;
      }

      address[] memory dsts = new address[](1);
      dsts[0] = _dst;
      uint256 index = mintableErc1155.maxIndex(tokenType) + 1;
      uint256 tokenId  = tokenType | index;
      mintableErc1155.mintNonFungible(tokenType, dsts);

      _DateToken memory dt;
      dt.timestamp = dateTimestamp;
      dt.generation = curGeneration;
      dt.isValid = true;

      tokenIdToTimestamp[tokenId] = dt;
      generationToTokenCount[curGeneration] += 1;

      dateStringToTokenId[dateString] = tokenId;
      mintedCount++;

      claimedDateStrings.push(dateString);

      emit UpdatedRegistry(tokenId, dateTimestamp);
    }

    uint256 actualTotalPrice = pricePerDate.safeMul(mintedCount);
    treasury.transfer(actualTotalPrice);
    msg.sender.transfer(msg.value.safeSub(actualTotalPrice));

    bytes memory referralCodeInBytes = bytes(referralCode); // make string into bytes to test for lengtth
    if (referralCodeInBytes.length != 0 && referralCodeMapping[referralCode] == 1) {
      referralCodeToAmount[referralCode] += actualTotalPrice;
    }
  }
}