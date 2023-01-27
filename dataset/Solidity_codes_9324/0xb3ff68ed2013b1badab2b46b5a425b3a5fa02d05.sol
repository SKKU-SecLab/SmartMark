
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

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

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

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

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
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

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
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

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;

library MerkleProof {
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}// MIT

pragma solidity ^0.8.0;

interface NFTMintable {
    function mintTo(address to, uint16 amount) external;
}// MIT

pragma solidity ^0.8.0;



contract NFTPresale is Ownable {
    using SafeERC20 for IERC20;
    using MerkleProof for bytes32[];

    enum SaleState {
        Paused,
        PrivateSale,
        WhitelistSale,
        PublicSale,
        Reveal
    }

    SaleState public state = SaleState.Paused;

    uint16 public maxSupply = 4200;

    uint256 public purchasePrice = 0.09 ether;

    address public walletAddress = 0x01C92E523EeAab2c78f0E6B203C3867fF39b7463;

    bytes32 privateMerkleRoot;

    mapping(address => uint8) public privateSoldCount;

    bytes32 whitelistMerkleRoot;

    uint8 public whitelistMaxSalePerAddr;

    mapping(address => uint8) public whitelistSoldCount;

    uint8 public publicMaxSalePerAddr;

    mapping(address => uint8) public publicSoldCount;

    mapping(address => uint8) public softMinted;

    uint16 public soldCount;

    NFTMintable public NFT;

    event RecoveredERC20(address token, uint256 amount);
    event RecoveredERC721(address token, uint256 tokenId);

    event PresaleMint(
        address minter,
        uint8 numberOfTokensMinted,
        bool hardMinted,
        SaleState state
    );

    constructor(
        address _NFT,
        bytes32 _privateMerkleRoot,
        bytes32 _whitelistMerkleRoot,
        uint8 _whitelistMaxSalePerAddr,
        uint8 _publicMaxSalePerAddr
    ) {
        NFT = NFTMintable(_NFT);

        privateMerkleRoot = _privateMerkleRoot;
        whitelistMerkleRoot = _whitelistMerkleRoot;

        whitelistMaxSalePerAddr = _whitelistMaxSalePerAddr;
        publicMaxSalePerAddr = _publicMaxSalePerAddr;
    }

    modifier whenSalePaused() {
        require(
            state == SaleState.Paused,
            "You can not perform action when contract is not on Paused state"
        );
        _;
    }

    modifier atState(SaleState _state) {
        require(state == _state, "Wrong state. Action not allowed.");
        _;
    }

    function isPrivateUser(bytes32[] memory proof, address addr)
        public
        view
        returns (bool)
    {
        return
            proof.verify(privateMerkleRoot, keccak256(abi.encodePacked(addr)));
    }

    function isWhitelisted(bytes32[] memory proof, address addr)
        public
        view
        returns (bool)
    {
        return
            proof.verify(
                whitelistMerkleRoot,
                keccak256(abi.encodePacked(addr))
            );
    }

    function pauseSale() external onlyOwner {
        state = SaleState.Paused;
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount)
        external
        onlyOwner
    {
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit RecoveredERC20(tokenAddress, tokenAmount);
    }

    function recoverERC721(address tokenAddress, uint256 tokenId)
        external
        onlyOwner
    {
        IERC721(tokenAddress).safeTransferFrom(address(this), owner(), tokenId);
        emit RecoveredERC721(tokenAddress, tokenId);
    }

    function setPrivateMerkleRoot(bytes32 _root)
        external
        onlyOwner
        whenSalePaused
    {
        privateMerkleRoot = _root;
    }

    function setWhitelisteMerkleRoot(bytes32 _root)
        external
        onlyOwner
        whenSalePaused
    {
        whitelistMerkleRoot = _root;
    }

    function setWalletAddress(address _walletAddress)
        external
        onlyOwner
        returns (bool)
    {
        walletAddress = _walletAddress;
        return true;
    }

    function setPurchasePrice(uint256 _purchasePrice)
        external
        onlyOwner
        whenSalePaused
        returns (bool)
    {
        require(_purchasePrice > 0, "Invalid price");
        purchasePrice = _purchasePrice;
        return true;
    }

    function setWhitelistMaxSalePerAddr(uint8 _whitelistMaxSalePerAddr)
        external
        onlyOwner
        whenSalePaused
        returns (bool)
    {
        whitelistMaxSalePerAddr = _whitelistMaxSalePerAddr;
        return true;
    }

    function setPublicMaxSalePerAddr(uint8 _publicMaxSalePerAddr)
        external
        onlyOwner
        whenSalePaused
        returns (bool)
    {
        publicMaxSalePerAddr = _publicMaxSalePerAddr;
        return true;
    }

    function setMaxSupply(uint16 _maxSupply)
        external
        onlyOwner
        whenSalePaused
        returns (bool)
    {
        require(
            soldCount <= _maxSupply,
            "More than or equal to soldCount allowed"
        );
        maxSupply = _maxSupply;

        return true;
    }

    function startPrivateSale() external onlyOwner {
        state = SaleState.PrivateSale;
    }

    function startWhitelistSale() external onlyOwner {
        state = SaleState.WhitelistSale;
    }

    function startPublicSale() external onlyOwner {
        state = SaleState.PublicSale;
    }

    function startReveal() external onlyOwner {
        state = SaleState.Reveal;
    }

    function reclaimFunds() external onlyOwner {
        assert(payable(walletAddress).send(address(this).balance));
    }

    function mintNFTInPrivateSale(bytes32[] memory proof) external {
        require(state == SaleState.PrivateSale, "Minting not allowed");

        address buyer = _msgSender();

        require(
            isPrivateUser(proof, _msgSender()),
            "Address is not member of private sale"
        );

        require(
            privateSoldCount[buyer] == 0,
            "More than max allowed in private for this address"
        );

        require(soldCount + 1 <= maxSupply, "More than max supply allowed");

        privateSoldCount[buyer] += 1;
        soldCount += 1;

        NFT.mintTo(_msgSender(), 1);

        emit PresaleMint(buyer, 1, true, state);
    }

    function mintNFTInWhitelistSale(
        uint8 numberOfTokens,
        bool hardMint,
        bytes32[] memory proof
    ) external payable {
        require(state == SaleState.WhitelistSale, "Minting not allowed");

        address buyer = _msgSender();
        uint256 value = msg.value;

        require(purchasePrice * numberOfTokens <= value, "Not enough Funds");

        require(isWhitelisted(proof, _msgSender()), "Address not whitelisted");

        require(
            whitelistSoldCount[buyer] + numberOfTokens <=
                whitelistMaxSalePerAddr,
            "More than max allowed in whitelist for this address"
        );

        require(
            soldCount + numberOfTokens <= maxSupply,
            "More than max supply allowed"
        );

        whitelistSoldCount[buyer] += numberOfTokens;
        soldCount += numberOfTokens;

        if (hardMint) {
            NFT.mintTo(_msgSender(), numberOfTokens);
        } else {
            softMinted[_msgSender()] += numberOfTokens;
        }

        emit PresaleMint(buyer, numberOfTokens, hardMint, state);
    }

    function mintNFTInPublicSale(uint8 numberOfTokens, bool hardMint)
        external
        payable
    {
        require(state == SaleState.PublicSale, "Minting not allowed");

        address buyer = _msgSender();
        uint256 value = msg.value;

        require(purchasePrice * numberOfTokens <= value, "Not enough Funds");

        require(
            publicSoldCount[buyer] + numberOfTokens <= publicMaxSalePerAddr,
            "More than max allowed in public sale for this address"
        );

        require(
            soldCount + numberOfTokens <= maxSupply,
            "More than max supply allowed"
        );

        publicSoldCount[buyer] += numberOfTokens;
        soldCount += numberOfTokens;

        if (hardMint) {
            NFT.mintTo(_msgSender(), numberOfTokens);
        } else {
            softMinted[_msgSender()] += numberOfTokens;
        }

        emit PresaleMint(buyer, numberOfTokens, hardMint, state);
    }

    function mint(uint8 numberOfTokens) external {
        require(
            softMinted[_msgSender()] >= numberOfTokens,
            "Not soft minted NFTs for sender"
        );

        softMinted[_msgSender()] -= numberOfTokens;

        NFT.mintTo(_msgSender(), numberOfTokens);
    }
}