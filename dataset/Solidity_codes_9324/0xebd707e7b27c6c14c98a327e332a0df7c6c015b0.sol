
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
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

pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity ^0.8.7;

interface RewardLike {
    function mintMany(address to, uint256 amount) external;
}

interface IDNAChip is RewardLike {
    function tokenIdToTraits(uint256 tokenId) external view returns (uint256);

    function isEvolutionPod(uint256 tokenId) external view returns (bool);

    function breedingIdToEvolutionPod(uint256 tokenId) external view returns (uint256);
}

interface IDescriptor {
    function tokenURI(uint256 _tokenId) external view returns (string memory);

    function tokenBreedingURI(uint256 _tokenId, uint256 _breedingId) external view returns (string memory);
}

interface IEvolutionTraits {
    function getDNAChipSVG(uint256 base) external view returns (string memory);

    function getEvolutionPodImageTag(uint256 base) external view returns (string memory);

    function getTraitsImageTags(uint8[8] memory traits) external view returns (string memory);

    function getMetadata(uint8[8] memory traits) external view returns (string memory);
}

interface IERC721Like {
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) external;

    function transfer(address to, uint256 id) external;

    function ownerOf(uint256 id) external returns (address owner);

    function mint(address to, uint256 tokenid) external;
}// MIT
pragma solidity ^0.8.7;


contract CheethV3 is ERC20Burnable, Ownable {
    uint256 public constant MAX_SUPPLY = 21_000_000;

    address private _rewarderAddress;
    address public genesisAddress;
    address public babyAddress;
    bool public isSignatureClaimEnabled;

    mapping(uint256 => bool) public claimedBabies;
    mapping(uint256 => bool) public claimedGenesis;
    mapping(address => bool) public claimedWallets;

    constructor() ERC20("Cheeth", "CHEETH") {
        isSignatureClaimEnabled = true;
    }

    function claimCheeth(uint256 outcome, bytes calldata signature) external {
        (
            uint256[] memory genesisTokens,
            uint256 genesisClaimableCheeth,
            uint256[] memory babyTokens,
            uint256 babyClaimableCheeth
        ) = getClaimableData(msg.sender);

        for (uint256 index = 0; index < genesisTokens.length; index++) {
            claimedGenesis[genesisTokens[index]] = true;
        }
        for (uint256 index = 0; index < babyTokens.length; index++) {
            claimedBabies[babyTokens[index]] = true;
        }

        if (outcome > 0) {
            _validateCheethClaimSignature(outcome, signature);
            claimedWallets[msg.sender] = true;
        }

        _safeMint(msg.sender, genesisClaimableCheeth + babyClaimableCheeth + outcome);
    }

    function _validateCheethClaimSignature(uint256 outcome, bytes calldata signature) internal view {
        require(isSignatureClaimEnabled, "signature claim disabled");
        require(!claimedWallets[msg.sender], "not allowed");
        bytes32 messageHash = keccak256(abi.encodePacked(outcome, msg.sender));
        require(_verifySignature(messageHash, signature), "invalid signature");
    }

    function getClaimableData(address owner)
        public
        view
        returns (
            uint256[] memory genesisTokens,
            uint256 genesisClaimableCheeth,
            uint256[] memory babyTokens,
            uint256 babyClaimableCheeth
        )
    {
        genesisTokens = _getClaimableGenesisTokens(owner);
        babyTokens = _getClaimableBabyTokens(owner);
        genesisClaimableCheeth = genesisTokens.length * 4500 ether;
        babyClaimableCheeth = babyTokens.length * 1125 ether;
        return (genesisTokens, genesisClaimableCheeth, babyTokens, babyClaimableCheeth);
    }

    function setIsSignatureClaimEnabled(bool _isSignatureClaimEnabled) external onlyOwner {
        isSignatureClaimEnabled = _isSignatureClaimEnabled;
    }

    function setAddresses(
        address _genesisAddress,
        address _babyAddress,
        address rewarderAddress
    ) external onlyOwner {
        genesisAddress = _genesisAddress;
        babyAddress = _babyAddress;
        _rewarderAddress = rewarderAddress;
    }

    function _getClaimableGenesisTokens(address owner) internal view returns (uint256[] memory) {
        uint256[] memory tokens = _getAllTokens(genesisAddress, owner);
        uint256 claimableTokensCount;
        for (uint256 index = 0; index < tokens.length; index++) {
            uint256 tokenId = tokens[index];
            if (!claimedGenesis[tokenId]) {
                claimableTokensCount++;
            }
        }

        uint256[] memory claimableTokens = new uint256[](claimableTokensCount);
        uint256 resultsIndex;

        for (uint256 index = 0; index < tokens.length; index++) {
            uint256 tokenId = tokens[index];
            if (!claimedGenesis[tokenId]) {
                claimableTokens[resultsIndex] = tokenId;
                resultsIndex++;
            }
        }
        return claimableTokens;
    }

    function _getClaimableBabyTokens(address owner) internal view returns (uint256[] memory) {
        uint256[] memory tokens = _getAllTokens(babyAddress, owner);
        uint256 claimableTokensCount;
        for (uint256 index = 0; index < tokens.length; index++) {
            uint256 tokenId = tokens[index];
            if (!claimedBabies[tokenId]) {
                claimableTokensCount++;
            }
        }

        uint256[] memory claimableTokens = new uint256[](claimableTokensCount);
        uint256 resultsIndex;

        for (uint256 index = 0; index < tokens.length; index++) {
            uint256 tokenId = tokens[index];
            if (!claimedBabies[tokenId]) {
                claimableTokens[resultsIndex] = tokenId;
                resultsIndex++;
            }
        }
        return claimableTokens;
    }

    function _getAllTokens(address tokenAddress, address owner) internal view returns (uint256[] memory) {
        uint256 tokenCount = IERC721Enumerable(tokenAddress).balanceOf(owner);
        uint256[] memory tokens = new uint256[](tokenCount);
        for (uint256 index = 0; index < tokenCount; index++) {
            tokens[index] = IERC721Enumerable(tokenAddress).tokenOfOwnerByIndex(owner, index);
        }
        return tokens;
    }

    function _safeMint(address to, uint256 amount) internal {
        uint256 newSupply = totalSupply() + amount;
        require(newSupply <= MAX_SUPPLY * 1 ether, "max supply");
        _mint(to, amount);
    }

    function _verifySignature(bytes32 messageHash, bytes memory signature) internal view returns (bool) {
        return ECDSA.recover(ECDSA.toEthSignedMessageHash(messageHash), signature) == _rewarderAddress;
    }
}