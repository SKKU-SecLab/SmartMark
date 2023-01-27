



pragma solidity ^0.8.0;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}




pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}




pragma solidity ^0.8.0;


contract PaymentSplitter {

    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    address[] private _payees;

    constructor(address[] memory payees, uint256[] memory shares_) payable {
        require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares_[i]);
        }
    }

    receive() external payable virtual {
        emit PaymentReceived(msg.sender, msg.value);
    }

    function totalShares() public view returns (uint256) {

        return _totalShares;
    }

    function totalReleased() public view returns (uint256) {

        return _totalReleased;
    }

    function shares(address account) public view returns (uint256) {

        return _shares[account];
    }

    function released(address account) public view returns (uint256) {

        return _released[account];
    }

    function payee(uint256 index) public view returns (address) {

        return _payees[index];
    }

    function release(address payable account) public virtual {

        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(account, totalReceived, released(account));

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(account, payment);
    }

    function _pendingPayment(
        address account,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {

        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;
    }

    function _addPayee(address account, uint256 shares_) private {

        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares = _totalShares + shares_;
        emit PayeeAdded(account, shares_);
    }
}




pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}




pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}





pragma solidity ^0.8.0;






contract ERC721 is ERC165, IERC721, IERC721Metadata {

    using Address for address;

    uint256 _tokenIndex;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) public _owners;

    mapping(address => uint256) public _balances;

    mapping(address => uint256) public _minted;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    event PermanentURI(string _value, uint256 indexed _id);

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function totalSupply() public view returns (uint256) {

        return _tokenIndex;
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return "";
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }


    function _mint(address to, uint256 quantity, uint256 safeMint, bytes memory data) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");

        uint256 mintIndex = _tokenIndex;
        _minted[to] += quantity;
        _tokenIndex += quantity;

        for (uint256 i = 0; i < quantity; i++) {
            mintIndex++;
            _owners[mintIndex] = to;
            emit Transfer(address(0), to, mintIndex);
            emit PermanentURI("https://frenlyflyz.io/ffmp-token-metadata/", mintIndex);

            if (safeMint == 1) {
                require(
                    _checkOnERC721Received(address(0), to, mintIndex, data),
                    "ERC721: transfer to non ERC721Receiver implementer"
                );
            }
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}




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

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}



pragma solidity ^0.8.0;





contract OwnableDelegateProxy { }


contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}

contract FlyPass is ERC721, Ownable, PaymentSplitter {

    using ECDSA for bytes32;

    bool _stopMint;

    uint256 _walletLimit;
    uint256 _mintPrice;
    uint256 _startingBlock;
    uint256 _maxSupply;

    address _devWallet;

    address _openSea = 0xa5409ec958C83C3f309868babACA7c86DCB077c1;

    address[] foundingFlyz = [
        0xeE24c06ae9469E29Fc0107048C2B4e806970ecdA,
        0x7d6F7FB391CD36BAde7baa7465581d9826a8D97D,
        0x665C5C08465E7c52DCD869a5998E11D8A6CdE361,
        0x9A665fb3fFB5906F47C438716D1E009767F96BBD,
        0x60916B17F8B0B9194baa5eCA43b7E1583b99A714,
        0xDAcb094be451A45D6C54fB18Eed1931D04F5793c,
        0xc2DfCFa2Bf1C871cB5af60b7eFBd95864984129D,
        0x155a3b74c26955Ca5174500A8f83947d7793bDd2,
        0xbB599fbd3BB5ce9326EA50dE38D09D5B946B24C1
    ];

    uint256[] foundingShares = [
        27,
        20,
        15,
        15,
        5,
        5,
        5,
        5,
        3
    ];

    constructor
    (address devWallet)
    ERC721("FLY Pass", "FFMP")
    PaymentSplitter(foundingFlyz,foundingShares)
    {
        _devWallet = devWallet;
    }

    function maxSupply(uint256 startingBlock, uint256 currentBlock) internal view returns (uint256) {

        uint256 currentMaxSupply;
        if (startingBlock > currentBlock || _stopMint) {
            return 0;
        } else {
            uint256 blocksElapsed = currentBlock - startingBlock;
            if (blocksElapsed < 5760) {
                currentMaxSupply = 2858;
            } else if (blocksElapsed < 7200) {
                currentMaxSupply = 8888;
            } else if (blocksElapsed < 8640) {
                currentMaxSupply = 7888;
            } else if (blocksElapsed < 10080) {
                currentMaxSupply = 6888;
            } else if (blocksElapsed < 11520) {
                currentMaxSupply = 5888;
            } else if (blocksElapsed < 12960) {
                currentMaxSupply = 4888;
            } else if (blocksElapsed < 14400) {
                currentMaxSupply = 3888;
            } else if (blocksElapsed < 15840) {
                currentMaxSupply = 2888;
            } else if (blocksElapsed < 17280) {
                currentMaxSupply = 1888;
            } else {
                currentMaxSupply = 0;
            }

            return totalSupply() < currentMaxSupply ? currentMaxSupply : totalSupply();
        }
    }

    function getMaxSupply() public view returns (uint256) {

        return maxSupply(_startingBlock, block.number);
    }

    function contractURI() public pure returns (string memory) {

        return "https://frenlyflyz.io/ffmp-collection-metadata/";
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {

        require(_exists(tokenId), "Doesn't exist!");
        return "ipfs://QmQrcFTeEWWMr5QRzGUT7KqGFotLbsHscRV2HV5SEpuE3z";
    }

    function isApprovedForAll(
        address owner,
        address operator
    )
        public
        view
        override(ERC721)
        returns (bool)
    {

        ProxyRegistry proxyRegistry = ProxyRegistry(_openSea);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return ERC721.isApprovedForAll(owner, operator);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override (ERC721) {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        if (_minted[from] != 0 && _minted[from] != 10) {
            _balances[from] += _minted[from];
            _minted[from] = 10;
        }

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function balanceOf(address owner) public view virtual override(ERC721) returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        if (_minted[owner] != 10) {
            return _balances[owner] + _minted[owner];
        } else {
            return _balances[owner];
        }
    }

    function startMint(uint256 startingBlock) public onlyOwner {

        require(totalSupply() == 0, "Cannot restart mint!");
        _mint(_devWallet, 188, 1, "");
        _startingBlock = startingBlock;
    }

    function stopMint() public onlyOwner {

        _stopMint = true;
    }

    function mint(uint256 rawQuantity, uint256 mintType, bytes memory signature) public payable {

        require(
            (block.number > _startingBlock) &&
            maxSupply(_startingBlock, block.number) > 0 &&
            (7 > balanceOf(msg.sender) + rawQuantity),
                "Mint Not Allowed!");

        bytes32 hash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            keccak256(abi.encodePacked(msg.sender, mintType, rawQuantity)))
          );

        require(
            hash.recover(signature) == 0x87A7219276164F5740302c24f5D709830f4Ed91F,
                "Mint not signed!");

        uint256 quantity;

        require(0 <= mintType && mintType <= 3,
            "Hmm");
        if (mintType == 0) {
            require(msg.value >= rawQuantity * 0.04 ether,
                "Not enough eth");
            quantity = rawQuantity;
            require((maxSupply(_startingBlock, block.number) > totalSupply() + quantity),
                "Not enough Supply");
        } else if (mintType == 1) {
            require(msg.value >= rawQuantity * 0.03 ether,
                "Not enough eth");
            quantity = rawQuantity == 5 ? 6 : rawQuantity;
        } else if (mintType == 2) {
            require(msg.value >= rawQuantity * 0.025 ether,
                "Not enough eth");
            quantity = rawQuantity == 5 ? 6 : rawQuantity;
        }

        _mint(msg.sender, quantity, 0, "");
    }
}