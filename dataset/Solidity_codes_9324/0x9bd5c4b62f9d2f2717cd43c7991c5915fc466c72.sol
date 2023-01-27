
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

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.7;

interface IClubCards {

    function mintCard(uint256 numMints, uint256 waveId) external payable;


    function whitelistMint(
        uint256 numMints,
        uint256 waveId,
        uint256 nonce,
        uint256 timestamp,
        bytes calldata signature
    ) external payable;


    function claim(
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        uint256 nonce,
        uint256 timestamp,
        bytes memory signature
    ) external payable;


    function allStatus() external view returns (bool);


    function uri(uint256 id) external view returns (string memory);


    function contractURI() external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;
    address private _admin;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);

    constructor() {
        _transferOwnership(_msgSender());
        _setAdmin(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function admin() public view virtual returns (address) {
        return _admin;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    modifier onlyTeam() {
        require(
            msg.sender == _admin || msg.sender == owner(),
            "Not authorized"
        );
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function setAdmin(address newAdmin) public virtual onlyOwner {
        require(
            newAdmin != address(0),
            "Ownable: new admin is the zero address"
        );
        _setAdmin(newAdmin);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _setAdmin(address newAdmin) internal virtual {
        address oldAdmin = _admin;
        _admin = newAdmin;
        emit AdminChanged(oldAdmin, newAdmin);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

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


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using Address for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}// MIT

pragma solidity ^0.8.7;

interface ICCEditions {

    event Claimed(
        address indexed _address,
        uint256 authTxNonce,
        uint256[] ids,
        uint256[] amounts
    );
    event WhitelistMinted(
        address indexed _address,
        uint256 numMints,
        uint256 waveId,
        uint256 authTxNonce
    );
    event ClaimSet(uint256 indexed tokenIndex, uint256 indexed claimId);

    event WaveStartIndexBlockSet(
        uint256 indexed waveId,
        uint256 startIndexBlock
    );
    event WaveStartIndexSet(uint256 indexed waveId, uint256 startIndex);

    function setWaveStartIndex(uint256 waveId) external;


    function getClaim(uint256 claimId)
        external
        view
        returns (
            uint256 CLAIM_INDEX,
            uint256 TOKEN_INDEX,
            bool status,
            uint256 supply,
            string memory uri
        );


    function authTxNonce(address _address) external view returns (uint256);


    function getToken(uint256 id)
        external
        view
        returns (
            bool isClaim,
            uint256 editionId,
            uint256 tokenIdOfEdition
        );


    function totalSupply() external view returns (uint256);


    function getWave(uint256 waveId)
        external
        view
        returns (
            uint256 WAVE_INDEX,
            uint256 MAX_SUPPLY,
            uint256 REVEAL_TIMESTAMP,
            uint256 price,
            uint256 startIndex,
            uint256 startIndexBlock,
            bool status,
            bool whitelistStatus,
            uint256 supply,
            string memory provHash,
            string memory _waveURI
        );

}// MIT

pragma solidity ^0.8.7;



abstract contract CCEditions is ERC1155, Ownable, ICCEditions {
    using Strings for uint256;

    mapping(uint256 => uint256) private _waves;
    mapping(uint256 => uint72) private _claims;
    mapping(uint256 => string) private waveProv;
    mapping(uint256 => string) private waveURI;
    mapping(uint256 => string) private claimURI;
    uint40[] private tokens;

    mapping(address => uint256) private _authTxNonce;

    function setWaveStartIndex(uint256 waveId) external override {
        (
            ,
            uint256 MAX_SUPPLY,
            ,
            ,
            uint256 startIndex,
            uint256 startIndexBlock,
            ,
            ,
            ,
            ,

        ) = getWave(waveId);

        require(
            startIndexBlock != 0,
            "CCEditions: Starting index block not set"
        );
        require(startIndex == 0, "CCEditions: Starting index already set");
        bytes32 blockHash = blockhash(startIndexBlock);
        uint256 si = uint256(blockHash) % MAX_SUPPLY;
        if (blockHash == bytes32(0)) {
            si = uint256(blockhash(block.number - 1)) % MAX_SUPPLY;
        }
        if (si == 0) {
            si += 1;
        }
        _waves[waveId] = _waves[waveId] |= si << 144;

        emit WaveStartIndexSet(waveId, si);
        delete si;
        delete blockHash;
    }

    function setWave(
        uint256 waveId,
        uint256 MAX_SUPPLY,
        uint256 REVEAL_TIMESTAMP,
        uint256 price,
        bool status,
        bool whitelistStatus,
        string calldata provHash,
        string calldata _waveURI
    ) external onlyTeam {
        require(!_waveExists(waveId), "CCEditions: Wave already exists");
        require(
            waveId <= type(uint8).max &&
                MAX_SUPPLY <= type(uint16).max &&
                REVEAL_TIMESTAMP <= type(uint56).max &&
                price <= type(uint64).max,
            "CCEditions: Value is too big!"
        );
        uint256 wave = waveId;
        wave |= MAX_SUPPLY << 8;
        wave |= REVEAL_TIMESTAMP << 24;
        wave |= price << 80;
        wave |= uint256(status ? 1 : 0) << 224;
        wave |= uint256(whitelistStatus ? 1 : 0) << 232;
        _waves[waveId] = wave;
        waveProv[waveId] = provHash;
        waveURI[waveId] = _waveURI;
    }

    function setWavePrice(uint256 waveId, uint256 newPrice) external onlyTeam {
        require(_waveExists(waveId), "CCEditions: Wave does not exist");
        require(newPrice <= type(uint64).max, "CCEditions: Too high");
        (
            ,
            ,
            ,
            ,
            uint256 startIndex,
            uint256 startIndexBlock,
            bool status,
            bool whitelistStatus,
            uint256 supply,
            ,

        ) = getWave(waveId);

        uint256 wave = uint256(uint88(_waves[waveId]));
        wave |= newPrice << 80;
        wave |= startIndex << 144;
        wave |= startIndexBlock << 160;
        wave |= uint256(status ? 1 : 0) << 224;
        wave |= uint256(whitelistStatus ? 1 : 0) << 232;
        wave |= supply << 240;
        _waves[waveId] = wave;
    }

    function setWaveStatus(uint256 waveId, bool newStatus) external onlyTeam {
        require(_waveExists(waveId), "CCEditions: Wave does not exist");
        (
            ,
            ,
            ,
            uint256 price,
            uint256 startIndex,
            uint256 startIndexBlock,
            ,
            bool whitelistStatus,
            uint256 supply,
            ,

        ) = getWave(waveId);
        uint256 wave = uint256(uint88(_waves[waveId]));
        wave |= price << 80;
        wave |= startIndex << 144;
        wave |= startIndexBlock << 160;
        wave |= uint256(newStatus ? 1 : 0) << 224;
        wave |= uint256(whitelistStatus ? 1 : 0) << 232;
        wave |= supply << 240;
        _waves[waveId] = wave;
    }

    function setWaveWLStatus(uint256 waveId, bool newWLStatus)
        external
        onlyTeam
    {
        require(_waveExists(waveId), "CCEditions: Wave does not exist");
        (
            ,
            ,
            ,
            uint256 price,
            uint256 startIndex,
            uint256 startIndexBlock,
            bool status,
            ,
            uint256 supply,
            ,

        ) = getWave(waveId);
        uint256 wave = uint256(uint88(_waves[waveId]));
        wave |= price << 80;
        wave |= startIndex << 144;
        wave |= startIndexBlock << 160;
        wave |= uint256(status ? 1 : 0) << 224;
        wave |= uint256(newWLStatus ? 1 : 0) << 232;
        wave |= supply << 240;
        _waves[waveId] = wave;
    }

    function setWaveURI(uint256 waveId, string memory newURI)
        external
        onlyTeam
    {
        waveURI[waveId] = newURI;
    }

    function setClaimURI(uint256 claimId, string memory newURI)
        external
        onlyTeam
    {
        require(_claimExists(claimId), "ClaimId does not exist");
        require(claimId > 0, "ClaimId cannot be zero");
        claimURI[claimId] = newURI;
    }

    function setClaimStatus(uint256 claimId, bool newStatus) external onlyTeam {
        require(_claimExists(claimId), "ClaimId does not exist");
        require(claimId > 0, "ClaimId cannot be zero");
        (, , , uint256 supply, ) = getClaim(claimId);
        uint256 claim = uint40(_claims[claimId]);
        claim |= uint8(newStatus ? 1 : 0) << 40;
        claim |= supply << 48;
        _claims[claimId] = uint72(claim);
    }

    function setClaim(
        uint256 claimId,
        string memory uri,
        bool status
    ) external onlyTeam {
        require(!_claimExists(claimId), "CCEditions: Claim already exists");
        uint256 ti = totalSupply();
        require(
            claimId <= type(uint16).max && ti <= type(uint24).max,
            "CCEditions: Value is too big!"
        );
        uint256 claim = claimId;
        claim |= ti << 16;
        claim |= uint256(status ? 1 : 0) << 40;
        _claims[claimId] = uint72(claim);

        uint256 token = 1;
        token |= uint256(claimId << 8);
        tokens.push(uint40(token));
        claimURI[claimId] = uri;
        emit ClaimSet(ti, claimId);
    }

    function getClaim(uint256 claimId)
        public
        view
        override
        returns (
            uint256 CLAIM_INDEX,
            uint256 TOKEN_INDEX,
            bool status,
            uint256 supply,
            string memory uri
        )
    {
        require(_claimExists(claimId), "CCEditions: Claim does not exist");
        uint256 claim = _claims[claimId];
        CLAIM_INDEX = uint16(claim);
        TOKEN_INDEX = uint24(claim >> 16);
        status = uint8(claim >> 40) == 1;
        supply = uint24(claim >> 48);
        uri = claimURI[claimId];
    }

    function authTxNonce(address _address)
        public
        view
        override
        returns (uint256)
    {
        return _authTxNonce[_address];
    }

    function getToken(uint256 id)
        public
        view
        override
        returns (
            bool isClaim,
            uint256 editionId,
            uint256 tokenIdOfEdition
        )
    {
        require(_exists(id), "Token does not exist");
        (isClaim, editionId, tokenIdOfEdition) = _getToken(tokens[id]);
    }

    function totalSupply() public view override returns (uint256) {
        return tokens.length;
    }

    function getWave(uint256 waveId)
        public
        view
        override
        returns (
            uint256 WAVE_INDEX,
            uint256 MAX_SUPPLY,
            uint256 REVEAL_TIMESTAMP,
            uint256 price,
            uint256 startIndex,
            uint256 startIndexBlock,
            bool status,
            bool whitelistStatus,
            uint256 supply,
            string memory provHash,
            string memory _waveURI
        )
    {
        require(_waveExists(waveId), "CCEditions: Wave does not exist");
        uint256 wave = _waves[waveId];
        WAVE_INDEX = uint8(wave);
        MAX_SUPPLY = uint16(wave >> 8);
        REVEAL_TIMESTAMP = uint56(wave >> 24);
        price = uint64(wave >> 80);
        startIndex = uint16(wave >> 144);
        startIndexBlock = uint64(wave >> 160);
        status = uint8(wave >> 224) == 1;
        whitelistStatus = uint8(wave >> 232) == 1;
        supply = uint16(wave >> 240);
        provHash = waveProv[waveId];
        _waveURI = waveURI[waveId];
    }

    function _exists(uint256 id) internal view returns (bool) {
        return id >= 0 && id < totalSupply();
    }

    function _setWaveStartIndexBlock(uint256 waveId) internal {
        (
            ,
            ,
            ,
            uint256 price,
            uint256 startIndex,
            uint256 startIndexBlock,
            bool status,
            bool whitelistStatus,
            uint256 supply,
            ,

        ) = getWave(waveId);

        if (startIndexBlock == 0) {
            uint256 bn = block.number;
            uint256 wave = uint256(uint88(_waves[waveId]));
            wave |= price << 80;
            wave |= startIndex << 144;
            wave |= bn << 160;
            wave |= uint256(status ? 1 : 0) << 224;
            wave |= uint256(whitelistStatus ? 1 : 0) << 232;
            wave |= supply << 240;
            _waves[waveId] = wave;

            emit WaveStartIndexBlockSet(waveId, bn);
        }
    }

    function _checkReveal(uint256 waveId) internal {
        (
            ,
            uint256 MAX_SUPPLY, // 16
            uint256 REVEAL_TIMESTAMP, // 64
            ,
            uint256 startIndex, // 8
            ,
            ,
            ,
            uint256 supply,
            ,

        ) = getWave(waveId);
        if (
            startIndex == 0 &&
            ((supply == MAX_SUPPLY) || block.timestamp >= REVEAL_TIMESTAMP)
        ) {
            _setWaveStartIndexBlock(waveId);
        }
    }

    function _getURI(uint256 id) internal view returns (string memory) {
        require(_exists(id), "CCEditions: TokenId does not exist");
        (bool isClaim, uint256 editionId, uint256 tokenIdOfEdition) = _getToken(
            tokens[id]
        );
        if (isClaim) {
            return claimURI[editionId];
        } else {
            return
                string(
                    abi.encodePacked(
                        waveURI[editionId],
                        tokenIdOfEdition.toString()
                    )
                );
        }
    }

    function _waveExists(uint256 waveId) internal view returns (bool) {
        return _waves[waveId] != 0;
    }

    function _claimExists(uint256 claimId) internal view returns (bool) {
        return _claims[claimId] != 0;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        if (from == address(0)) {
            uint256 edId = st2num(string(data));

            if (edId == 0) {
                for (uint256 i = 0; i < ids.length; i++) {
                    (bool isClaim, uint256 claimId, ) = _getToken(
                        tokens[ids[i]]
                    );
                    require(isClaim, "Token is not claimable");
                    _increaseClaimSupply(claimId, amounts[i]);
                }
                emit Claimed(to, _authTxNonce[to], ids, amounts);
            } else {
                for (uint256 i = 0; i < ids.length; i++) {
                    require(!_exists(ids[i]), "Token already exists");
                    require(amounts[i] == 1, "Invalid mint amount");
                }
                if (_increaseWaveSupply(edId, ids.length)) {
                    _authTxNonce[to]++;
                    emit WhitelistMinted(
                        to,
                        ids.length,
                        edId,
                        _authTxNonce[to]
                    );
                }
            }
        }
    }

    function _getToken(uint256 tokenData)
        private
        pure
        returns (
            bool isClaim,
            uint256 editionId,
            uint256 tokenIdOfEdition
        )
    {
        isClaim = uint8(tokenData) == 1;
        editionId = uint16(tokenData >> 8);
        tokenIdOfEdition = uint16(tokenData >> 24);
    }

    function _increaseClaimSupply(uint256 claimId, uint256 amount) private {
        (, , bool status, uint256 supply, ) = getClaim(claimId);
        require(status, "Claim is paused");
        uint256 temp = _claims[claimId];
        temp = uint256(uint48(temp));
        temp |= uint256(supply + amount) << 48;
        _claims[claimId] = uint72(temp);
    }

    function st2num(string memory numString) private pure returns (uint256) {
        uint256 val = 0;
        bytes memory stringBytes = bytes(numString);
        for (uint256 i = 0; i < stringBytes.length; i++) {
            uint256 exp = stringBytes.length - i;
            bytes1 ival = stringBytes[i];
            uint8 uval = uint8(ival);
            uint256 jval = uval - uint256(0x30);

            val += (uint256(jval) * (10**(exp - 1)));
        }
        return val;
    }

    function _increaseWaveSupply(uint256 waveId, uint256 numMints)
        private
        returns (bool)
    {
        (, , , , , , , bool whitelistStatus, uint256 supply, , ) = getWave(
            waveId
        );
        uint256 temp = _waves[waveId];
        temp = uint256(uint240(temp));
        _waves[waveId] = temp |= uint256(supply + numMints) << 240;
        for (uint256 i = 0; i < numMints; i++) {
            temp = 0;
            temp |= uint24(waveId << 8);
            temp |= uint40((supply + i) << 24);
            tokens.push(uint40(temp));
        }
        return whitelistStatus;
    }
}// MIT

pragma solidity ^0.8.7;



contract ClubCards is ReentrancyGuard, CCEditions, IClubCards {

    using Address for address;
    using Strings for uint256;
    string public constant name = "ClubCards";
    string public constant symbol = "CC";
    string private conURI;

    uint256 private _maxMint = 10;

    bool private _allStatus = false;

    address private dev;

    constructor(address _dev) ERC1155("") {
        dev = _dev;
    }

    function mintCard(uint256 numMints, uint256 waveId)
        external
        payable
        override
        nonReentrant
    {

        prepMint(false, numMints, waveId);
        uint256 ti = totalSupply();
        if (numMints == 1) {
            _mint(_msgSender(), ti, 1, abi.encodePacked(waveId.toString()));
        } else {
            uint256[] memory mints = new uint256[](numMints);
            uint256[] memory amts = new uint256[](numMints);
            for (uint256 i = 0; i < numMints; i++) {
                mints[i] = ti + i;
                amts[i] = 1;
            }
            _mintBatch(
                _msgSender(),
                mints,
                amts,
                abi.encodePacked(waveId.toString())
            );
        }
        _checkReveal(waveId);
        delete ti;
    }

    function whitelistMint(
        uint256 numMints,
        uint256 waveId,
        uint256 nonce,
        uint256 timestamp,
        bytes calldata signature
    ) external payable override nonReentrant {

        prepMint(true, numMints, waveId);
        address sender = _msgSender();
        address recovered = ECDSA.recover(
            ECDSA.toEthSignedMessageHash(
                keccak256(
                    abi.encode(sender, numMints, waveId, nonce, timestamp)
                )
            ),
            signature
        );
        require(
            recovered == admin() || recovered == owner(),
            "Not authorized to mint"
        );
        uint256 ti = totalSupply();
        if (numMints == 1) {
            _mint(_msgSender(), ti, 1, abi.encodePacked((waveId.toString())));
        } else {
            uint256[] memory mints = new uint256[](numMints);
            uint256[] memory amts = new uint256[](numMints);
            for (uint256 i = 0; i < numMints; i++) {
                mints[i] = ti + i;
                amts[i] = 1;
            }
            _mintBatch(
                _msgSender(),
                mints,
                amts,
                abi.encodePacked(waveId.toString())
            );
        }
        _checkReveal(waveId);
        delete ti;
    }

    function claim(
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        uint256 nonce,
        uint256 timestamp,
        bytes memory signature
    ) external payable override nonReentrant {

        address sender = _msgSender();
        address recovered = ECDSA.recover(
            ECDSA.toEthSignedMessageHash(
                keccak256(
                    abi.encode(sender, tokenIds, amounts, nonce, timestamp)
                )
            ),
            signature
        );
        require(
            tokenIds.length > 0 && tokenIds.length == amounts.length,
            "Array lengths are invalid"
        );
        require(
            recovered == admin() || recovered == owner(),
            "Not authorized to claim"
        );

        _mintBatch(sender, tokenIds, amounts, "");
        delete recovered;
        delete sender;
    }

    function manualSetBlock(uint256 waveId) external onlyTeam {

        _setWaveStartIndexBlock(waveId);
    }

    function setAllStatus(bool newAllStatus) external onlyTeam {

        _allStatus = newAllStatus;
    }

    function setContractURI(string memory newContractURI) external onlyTeam {

        conURI = newContractURI;
    }

    function withdraw() external payable onlyOwner {

        uint256 _each = address(this).balance / 100;
        require(payable(owner()).send(_each * 85));
        require(payable(dev).send(_each * 15));
    }

    function allStatus() public view override returns (bool) {

        return _allStatus;
    }

    function uri(uint256 id)
        public
        view
        override(ERC1155, IClubCards)
        returns (string memory)
    {

        return _getURI(id);
    }

    function contractURI() public view override returns (string memory) {

        return conURI;
    }

    function prepMint(
        bool privateSale,
        uint256 numMints,
        uint256 waveId
    ) private {

        require(_waveExists(waveId), "Wave does not exist");
        (
            ,
            uint256 MAX_SUPPLY,
            ,
            uint256 price,
            ,
            ,
            bool status,
            bool whitelistStatus,
            uint256 circSupply,
            ,

        ) = getWave(waveId);
        require(whitelistStatus == privateSale, "Not authorized to mint");
        require(allStatus() && status, "Sale is paused");
        require(msg.value >= price * numMints, "Not enough ether sent");
        require(numMints <= _maxMint && numMints > 0, "Invalid mint amount");
        require(
            numMints + circSupply <= MAX_SUPPLY,
            "New mint exceeds maximum supply allowed for wave"
        );
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract CCAuthTx is ERC1155Receiver, Context, ReentrancyGuard {

    event AuthTx(address indexed _address, uint256 newNonce);
    mapping(address => uint256) private _authTxNonce;
    ClubCards public cc;

    constructor(ClubCards _cc) {
        cc = _cc;
    }

    function mint(
        uint256 numMints,
        uint256 waveId,
        uint256 nonce,
        uint256 timestamp,
        bytes calldata sig1,
        bytes calldata sig2
    ) external payable nonReentrant {

        address sender = tx.origin;
        address recovered = ECDSA.recover(
            ECDSA.toEthSignedMessageHash(
                keccak256(
                    abi.encode(sender, numMints, waveId, nonce, timestamp)
                )
            ),
            sig2
        );
        require(nonce == _authTxNonce[sender], "Incorrect nonce");
        require(
            recovered == cc.admin() || recovered == cc.owner(),
            "Sig doesnt recover to admin"
        );
        cc.whitelistMint{value: msg.value}(
            numMints,
            waveId,
            nonce,
            timestamp,
            sig1
        );
        emit AuthTx(sender, _authTxNonce[sender]);
        delete sender;
    }

    function claim(
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        uint256 nonce,
        uint256 timestamp,
        bytes memory sig1,
        bytes memory sig2
    ) external nonReentrant {

        address sender = tx.origin;
        address recovered = ECDSA.recover(
            ECDSA.toEthSignedMessageHash(
                keccak256(
                    abi.encode(sender, tokenIds, amounts, nonce, timestamp)
                )
            ),
            sig2
        );
        require(tokenIds.length <= 10, "Too many ids at a time");
        require(nonce == _authTxNonce[sender], "Incorrect nonce");
        require(
            recovered == cc.admin() || recovered == cc.owner(),
            "Sig doesnt recover to admin"
        );
        cc.claim(tokenIds, amounts, nonce, timestamp, sig1);
        emit AuthTx(sender, _authTxNonce[sender]);
        delete sender;
    }

    function authTxNonce(address _address) public view returns (uint256) {

        return _authTxNonce[_address];
    }

    function onERC1155Received(
        address operator,
        address,
        uint256 id,
        uint256,
        bytes calldata data
    ) public virtual override returns (bytes4 response) {

        address origin = tx.origin;
        require(
            _msgSender() == address(cc),
            "CCAuthTx(onERC1155Received): 'from' is not CC address"
        );
        ++_authTxNonce[origin];
        cc.safeTransferFrom(operator, origin, id, 1, data);
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) public virtual override returns (bytes4) {

        address origin = tx.origin;
        require(
            _msgSender() == address(cc),
            "CCAuthTx(onERC1155BatchReceived): 'from' is not CC address"
        );

        ++_authTxNonce[origin];
        cc.safeBatchTransferFrom(operator, origin, ids, values, data);
        return this.onERC1155BatchReceived.selector;
    }
}