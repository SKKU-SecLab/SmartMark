pragma solidity >=0.8.0;

abstract contract ReentrancyGuard {
    uint256 private reentrancyStatus = 1;

    modifier nonReentrant() {
        require(reentrancyStatus == 1, "REENTRANCY");

        reentrancyStatus = 2;

        _;

        reentrancyStatus = 1;
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

pragma solidity ^0.8.1;

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

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
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


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}// GPL-3.0
pragma solidity 0.8.10;


interface IERC721TokenURI {
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract ZoraProtocolFeeSettings is ERC721 {
    address public metadata;
    address public owner;
    address public minter;

    struct FeeSetting {
        uint16 feeBps;
        address feeRecipient;
    }

    mapping(address => FeeSetting) public moduleFeeSetting;

    modifier onlyModuleOwner(address _module) {
        uint256 tokenId = moduleToTokenId(_module);
        require(ownerOf(tokenId) == msg.sender, "onlyModuleOwner");
        _;
    }

    event ProtocolFeeUpdated(address indexed module, address feeRecipient, uint16 feeBps);

    event MetadataUpdated(address indexed newMetadata);

    event OwnerUpdated(address indexed newOwner);

    constructor() ERC721("ZORA Module Fee Switch", "ZORF") {
        _setOwner(msg.sender);
    }

    function init(address _minter, address _metadata) external {
        require(msg.sender == owner, "init only owner");
        require(minter == address(0), "init already initialized");

        minter = _minter;
        metadata = _metadata;
    }

    function mint(address _to, address _module) external returns (uint256) {
        require(msg.sender == minter, "mint onlyMinter");
        uint256 tokenId = moduleToTokenId(_module);
        _mint(_to, tokenId);

        return tokenId;
    }

    function setFeeParams(
        address _module,
        address _feeRecipient,
        uint16 _feeBps
    ) external onlyModuleOwner(_module) {
        require(_feeBps <= 10000, "setFeeParams must set fee <= 100%");
        require(_feeRecipient != address(0) || _feeBps == 0, "setFeeParams fee recipient cannot be 0 address if fee is greater than 0");

        moduleFeeSetting[_module] = FeeSetting(_feeBps, _feeRecipient);

        emit ProtocolFeeUpdated(_module, _feeRecipient, _feeBps);
    }

    function setOwner(address _owner) external {
        require(msg.sender == owner, "setOwner onlyOwner");
        _setOwner(_owner);
    }

    function setMetadata(address _metadata) external {
        require(msg.sender == owner, "setMetadata onlyOwner");
        _setMetadata(_metadata);
    }

    function getFeeAmount(address _module, uint256 _amount) external view returns (uint256) {
        return (_amount * moduleFeeSetting[_module].feeBps) / 10000;
    }

    function tokenIdToModule(uint256 _tokenId) public pure returns (address) {
        return address(uint160(_tokenId));
    }

    function moduleToTokenId(address _module) public pure returns (uint256) {
        return uint256(uint160(_module));
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        require(metadata != address(0), "ERC721Metadata: no metadata address");

        return IERC721TokenURI(metadata).tokenURI(_tokenId);
    }

    function _setMetadata(address _metadata) private {
        metadata = _metadata;

        emit MetadataUpdated(_metadata);
    }

    function _setOwner(address _owner) private {
        owner = _owner;

        emit OwnerUpdated(_owner);
    }
}// GPL-3.0
pragma solidity 0.8.10;


contract ZoraModuleManager {
    bytes32 private constant SIGNED_APPROVAL_TYPEHASH = 0x8413132cc7aa5bd2ce1a1b142a3f09e2baeda86addf4f9a5dacd4679f56e7cec;

    bytes32 private immutable EIP_712_DOMAIN_SEPARATOR =
        keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("ZORA")),
                keccak256(bytes("3")),
                _chainID(),
                address(this)
            )
        );

    ZoraProtocolFeeSettings public immutable moduleFeeToken;

    address public registrar;

    mapping(address => mapping(address => bool)) public userApprovals;

    mapping(address => bool) public moduleRegistered;

    mapping(address => uint256) public sigNonces;

    modifier onlyRegistrar() {
        require(msg.sender == registrar, "ZMM::onlyRegistrar must be registrar");
        _;
    }

    event ModuleApprovalSet(address indexed user, address indexed module, bool approved);

    event ModuleRegistered(address indexed module);

    event RegistrarChanged(address indexed newRegistrar);

    constructor(address _registrar, address _feeToken) {
        require(_registrar != address(0), "ZMM::must set registrar to non-zero address");

        registrar = _registrar;
        moduleFeeToken = ZoraProtocolFeeSettings(_feeToken);
    }

    function isModuleApproved(address _user, address _module) external view returns (bool) {
        return userApprovals[_user][_module];
    }

    function setApprovalForModule(address _module, bool _approved) public {
        _setApprovalForModule(_module, msg.sender, _approved);
    }

    function setBatchApprovalForModules(address[] memory _modules, bool _approved) public {
        uint256 numModules = _modules.length;

        for (uint256 i = 0; i < numModules; ) {
            _setApprovalForModule(_modules[i], msg.sender, _approved);

            unchecked {
                ++i;
            }
        }
    }

    function setApprovalForModuleBySig(
        address _module,
        address _user,
        bool _approved,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        require(_deadline == 0 || _deadline >= block.timestamp, "ZMM::setApprovalForModuleBySig deadline expired");

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                EIP_712_DOMAIN_SEPARATOR,
                keccak256(abi.encode(SIGNED_APPROVAL_TYPEHASH, _module, _user, _approved, _deadline, sigNonces[_user]++))
            )
        );

        address recoveredAddress = ecrecover(digest, _v, _r, _s);

        require(recoveredAddress != address(0) && recoveredAddress == _user, "ZMM::setApprovalForModuleBySig invalid signature");

        _setApprovalForModule(_module, _user, _approved);
    }

    function registerModule(address _module) public onlyRegistrar {
        require(!moduleRegistered[_module], "ZMM::registerModule module already registered");

        moduleRegistered[_module] = true;
        moduleFeeToken.mint(registrar, _module);

        emit ModuleRegistered(_module);
    }

    function setRegistrar(address _registrar) public onlyRegistrar {
        require(_registrar != address(0), "ZMM::setRegistrar must set registrar to non-zero address");
        registrar = _registrar;

        emit RegistrarChanged(_registrar);
    }

    function _setApprovalForModule(
        address _module,
        address _user,
        bool _approved
    ) private {
        require(moduleRegistered[_module], "ZMM::must be registered module");

        userApprovals[_user][_module] = _approved;

        emit ModuleApprovalSet(msg.sender, _module, _approved);
    }

    function _chainID() private view returns (uint256 id) {
        assembly {
            id := chainid()
        }
    }
}// GPL-3.0
pragma solidity 0.8.10;


contract BaseTransferHelper {
    ZoraModuleManager public immutable ZMM;

    constructor(address _moduleManager) {
        require(_moduleManager != address(0), "must set module manager to non-zero address");

        ZMM = ZoraModuleManager(_moduleManager);
    }

    modifier onlyApprovedModule(address _user) {
        require(isModuleApproved(_user), "module has not been approved by user");
        _;
    }

    function isModuleApproved(address _user) public view returns (bool) {
        return ZMM.isModuleApproved(_user, msg.sender);
    }
}// GPL-3.0
pragma solidity 0.8.10;


contract ERC721TransferHelper is BaseTransferHelper {
    constructor(address _approvalsManager) BaseTransferHelper(_approvalsManager) {}

    function safeTransferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _tokenId
    ) public onlyApprovedModule(_from) {
        IERC721(_token).safeTransferFrom(_from, _to, _tokenId);
    }

    function transferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _tokenId
    ) public onlyApprovedModule(_from) {
        IERC721(_token).transferFrom(_from, _to, _tokenId);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
}// GPL-3.0
pragma solidity 0.8.10;


contract ERC20TransferHelper is BaseTransferHelper {
    using SafeERC20 for IERC20;

    constructor(address _approvalsManager) BaseTransferHelper(_approvalsManager) {}

    function safeTransferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _value
    ) public onlyApprovedModule(_from) {
        IERC20(_token).safeTransferFrom(_from, _to, _value);
    }
}// GPL-3.0
pragma solidity 0.8.10;


contract IncomingTransferSupportV1 {
    using SafeERC20 for IERC20;

    ERC20TransferHelper public immutable erc20TransferHelper;

    constructor(address _erc20TransferHelper) {
        erc20TransferHelper = ERC20TransferHelper(_erc20TransferHelper);
    }

    function _handleIncomingTransfer(uint256 _amount, address _currency) internal {
        if (_currency == address(0)) {
            require(msg.value >= _amount, "_handleIncomingTransfer msg value less than expected amount");
        } else {
            IERC20 token = IERC20(_currency);
            uint256 beforeBalance = token.balanceOf(address(this));
            erc20TransferHelper.safeTransferFrom(_currency, msg.sender, address(this), _amount);
            uint256 afterBalance = token.balanceOf(address(this));
            require(beforeBalance + _amount == afterBalance, "_handleIncomingTransfer token transfer call did not transfer expected amount");
        }
    }
}// MIT

pragma solidity ^0.8.0;



interface IRoyaltyEngineV1 is IERC165 {

    function getRoyalty(address tokenAddress, uint256 tokenId, uint256 value) external returns(address payable[] memory recipients, uint256[] memory amounts);

    function getRoyaltyView(address tokenAddress, uint256 tokenId, uint256 value) external view returns(address payable[] memory recipients, uint256[] memory amounts);
}// MIT

pragma solidity ^0.8.0;


library ERC165Checker {
    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {
        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {
        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {
        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}// GPL-3.0
pragma solidity 0.8.10;


interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}// GPL-3.0
pragma solidity 0.8.10;



contract OutgoingTransferSupportV1 {
    using SafeERC20 for IERC20;

    IWETH immutable weth;

    constructor(address _wethAddress) {
        weth = IWETH(_wethAddress);
    }

    function _handleOutgoingTransfer(
        address _dest,
        uint256 _amount,
        address _currency,
        uint256 _gasLimit
    ) internal {
        if (_amount == 0 || _dest == address(0)) {
            return;
        }

        if (_currency == address(0)) {
            require(address(this).balance >= _amount, "_handleOutgoingTransfer insolvent");

            uint256 gas = (_gasLimit == 0 || _gasLimit > gasleft()) ? gasleft() : _gasLimit;
            (bool success, ) = _dest.call{value: _amount, gas: gas}("");
            if (!success) {
                weth.deposit{value: _amount}();
                IERC20(address(weth)).safeTransfer(_dest, _amount);
            }
        } else {
            IERC20(_currency).safeTransfer(_dest, _amount);
        }
    }
}// GPL-3.0
pragma solidity 0.8.10;


contract FeePayoutSupportV1 is OutgoingTransferSupportV1 {
    address public immutable registrar;

    ZoraProtocolFeeSettings immutable protocolFeeSettings;

    IRoyaltyEngineV1 royaltyEngine;

    event RoyaltyPayout(address indexed tokenContract, uint256 indexed tokenId, address recipient, uint256 amount);

    constructor(
        address _royaltyEngine,
        address _protocolFeeSettings,
        address _wethAddress,
        address _registrarAddress
    ) OutgoingTransferSupportV1(_wethAddress) {
        royaltyEngine = IRoyaltyEngineV1(_royaltyEngine);
        protocolFeeSettings = ZoraProtocolFeeSettings(_protocolFeeSettings);
        registrar = _registrarAddress;
    }

    function setRoyaltyEngineAddress(address _royaltyEngine) public {
        require(msg.sender == registrar, "setRoyaltyEngineAddress only registrar");
        require(
            ERC165Checker.supportsInterface(_royaltyEngine, type(IRoyaltyEngineV1).interfaceId),
            "setRoyaltyEngineAddress must match IRoyaltyEngineV1 interface"
        );
        royaltyEngine = IRoyaltyEngineV1(_royaltyEngine);
    }

    function _handleProtocolFeePayout(uint256 _amount, address _payoutCurrency) internal returns (uint256) {
        uint256 protocolFee = protocolFeeSettings.getFeeAmount(address(this), _amount);

        if (protocolFee == 0) return _amount;

        (, address feeRecipient) = protocolFeeSettings.moduleFeeSetting(address(this));

        _handleOutgoingTransfer(feeRecipient, protocolFee, _payoutCurrency, 50000);

        return _amount - protocolFee;
    }

    function _handleRoyaltyPayout(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _amount,
        address _payoutCurrency,
        uint256 _gasLimit
    ) internal returns (uint256, bool) {
        uint256 gas = (_gasLimit == 0 || _gasLimit > gasleft()) ? gasleft() : _gasLimit;

        try this._handleRoyaltyEnginePayout{gas: gas}(_tokenContract, _tokenId, _amount, _payoutCurrency) returns (uint256 remainingFunds) {
            return (remainingFunds, true);
        } catch {
            return (_amount, false);
        }
    }

    function _handleRoyaltyEnginePayout(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _amount,
        address _payoutCurrency
    ) external payable returns (uint256) {
        require(msg.sender == address(this), "_handleRoyaltyEnginePayout only self callable");

        (address payable[] memory recipients, uint256[] memory amounts) = royaltyEngine.getRoyalty(_tokenContract, _tokenId, _amount);

        uint256 numRecipients = recipients.length;

        if (numRecipients == 0) return _amount;

        uint256 amountRemaining = _amount;

        address recipient;
        uint256 amount;

        for (uint256 i = 0; i < numRecipients; ) {
            recipient = recipients[i];
            amount = amounts[i];

            require(amountRemaining >= amount, "insolvent");

            _handleOutgoingTransfer(recipient, amount, _payoutCurrency, 50000);

            emit RoyaltyPayout(_tokenContract, _tokenId, recipient, amount);

            unchecked {
                amountRemaining -= amount;
                ++i;
            }
        }

        return amountRemaining;
    }
}// GPL-3.0
pragma solidity 0.8.10;

contract ModuleNamingSupportV1 {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}// GPL-3.0
pragma solidity 0.8.10;

interface IReserveAuctionListingErc20 {
    function createAuction(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _duration,
        uint256 _reservePrice,
        address _sellerFundsRecipient,
        uint256 _startTime,
        address _bidCurrency,
        uint256 _listingFeeBps,
        address _listingFeeRecipient
    ) external;

    function setAuctionReservePrice(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _reservePrice
    ) external;

    function cancelAuction(address _tokenContract, uint256 _tokenId) external;

    function createBid(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _amount
    ) external payable;

    function settleAuction(address _tokenContract, uint256 _tokenId) external;
}// GPL-3.0
pragma solidity 0.8.10;



contract ReserveAuctionListingErc20 is ReentrancyGuard, IncomingTransferSupportV1, FeePayoutSupportV1, ModuleNamingSupportV1 {
    uint16 constant TIME_BUFFER = 15 minutes;

    uint8 constant MIN_BID_INCREMENT_PERCENTAGE = 10;

    ERC721TransferHelper public immutable erc721TransferHelper;

    mapping(address => mapping(uint256 => Auction)) public auctionForNFT;

    struct Auction {
        address seller;
        uint96 reservePrice;
        address sellerFundsRecipient;
        uint96 highestBid;
        address highestBidder;
        uint96 startTime;
        address currency;
        uint96 firstBidTime;
        address listingFeeRecipient;
        uint80 duration;
        uint16 listingFeeBps;
    }

    event AuctionCreated(address indexed tokenContract, uint256 indexed tokenId, Auction auction);

    event AuctionReservePriceUpdated(address indexed tokenContract, uint256 indexed tokenId, Auction auction);

    event AuctionCanceled(address indexed tokenContract, uint256 indexed tokenId, Auction auction);

    event AuctionBid(address indexed tokenContract, uint256 indexed tokenId, bool firstBid, bool extended, Auction auction);

    event AuctionEnded(address indexed tokenContract, uint256 indexed tokenId, Auction auction);

    constructor(
        address _erc20TransferHelper,
        address _erc721TransferHelper,
        address _royaltyEngine,
        address _protocolFeeSettings,
        address _weth
    )
        IncomingTransferSupportV1(_erc20TransferHelper)
        FeePayoutSupportV1(_royaltyEngine, _protocolFeeSettings, _weth, ERC721TransferHelper(_erc721TransferHelper).ZMM().registrar())
        ModuleNamingSupportV1("Reserve Auction Listing ERC-20")
    {
        erc721TransferHelper = ERC721TransferHelper(_erc721TransferHelper);
    }

    function supportsInterface(bytes4 _interfaceId) external pure returns (bool) {
        return _interfaceId == type(IReserveAuctionListingErc20).interfaceId || _interfaceId == 0x01ffc9a7;
    }

    function createAuction(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _duration,
        uint256 _reservePrice,
        address _sellerFundsRecipient,
        uint256 _startTime,
        address _bidCurrency,
        uint256 _listingFeeBps,
        address _listingFeeRecipient
    ) external nonReentrant {
        address tokenOwner = IERC721(_tokenContract).ownerOf(_tokenId);

        require(msg.sender == tokenOwner || IERC721(_tokenContract).isApprovedForAll(tokenOwner, msg.sender), "ONLY_TOKEN_OWNER_OR_OPERATOR");

        require(_reservePrice <= type(uint96).max, "INVALID_RESERVE_PRICE");

        require(_sellerFundsRecipient != address(0), "INVALID_FUNDS_RECIPIENT");

        require(_listingFeeBps <= 10000, "INVALID_LISTING_FEE");

        auctionForNFT[_tokenContract][_tokenId].seller = tokenOwner;
        auctionForNFT[_tokenContract][_tokenId].reservePrice = uint96(_reservePrice);
        auctionForNFT[_tokenContract][_tokenId].sellerFundsRecipient = _sellerFundsRecipient;
        auctionForNFT[_tokenContract][_tokenId].startTime = uint96(_startTime);
        auctionForNFT[_tokenContract][_tokenId].currency = _bidCurrency;
        auctionForNFT[_tokenContract][_tokenId].listingFeeRecipient = _listingFeeRecipient;
        auctionForNFT[_tokenContract][_tokenId].duration = uint80(_duration);
        auctionForNFT[_tokenContract][_tokenId].listingFeeBps = uint16(_listingFeeBps);

        emit AuctionCreated(_tokenContract, _tokenId, auctionForNFT[_tokenContract][_tokenId]);
    }

    function setAuctionReservePrice(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _reservePrice
    ) external nonReentrant {
        Auction storage auction = auctionForNFT[_tokenContract][_tokenId];

        require(auction.firstBidTime == 0, "AUCTION_STARTED");

        require(msg.sender == auction.seller, "ONLY_SELLER");

        require(_reservePrice <= type(uint96).max, "INVALID_RESERVE_PRICE");

        auction.reservePrice = uint96(_reservePrice);

        emit AuctionReservePriceUpdated(_tokenContract, _tokenId, auction);
    }

    function cancelAuction(address _tokenContract, uint256 _tokenId) external nonReentrant {
        Auction memory auction = auctionForNFT[_tokenContract][_tokenId];

        require(auction.firstBidTime == 0, "AUCTION_STARTED");

        require(msg.sender == auction.seller || msg.sender == IERC721(_tokenContract).ownerOf(_tokenId), "ONLY_SELLER_OR_TOKEN_OWNER");

        emit AuctionCanceled(_tokenContract, _tokenId, auction);

        delete auctionForNFT[_tokenContract][_tokenId];
    }

    function createBid(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _amount
    ) external payable nonReentrant {
        Auction storage auction = auctionForNFT[_tokenContract][_tokenId];

        address seller = auction.seller;

        require(seller != address(0), "AUCTION_DOES_NOT_EXIST");

        require(block.timestamp >= auction.startTime, "AUCTION_NOT_STARTED");

        require(_amount <= type(uint96).max, "INVALID_BID");

        uint256 firstBidTime = auction.firstBidTime;
        uint256 duration = auction.duration;
        address currency = auction.currency;

        bool firstBid;

        if (firstBidTime == 0) {
            require(_amount >= auction.reservePrice, "RESERVE_PRICE_NOT_MET");

            auction.firstBidTime = uint96(block.timestamp);

            firstBid = true;

            erc721TransferHelper.transferFrom(_tokenContract, seller, address(this), _tokenId);

        } else {
            require(block.timestamp < (firstBidTime + duration), "AUCTION_OVER");

            uint256 highestBid = auction.highestBid;

            uint256 minValidBid;

            unchecked {
                minValidBid = highestBid + ((highestBid * MIN_BID_INCREMENT_PERCENTAGE) / 100);
            }

            require(minValidBid <= type(uint96).max, "MAX_BID_PLACED");

            require(_amount >= minValidBid, "MINIMUM_BID_NOT_MET");

            _handleOutgoingTransfer(auction.highestBidder, highestBid, currency, 50000);
        }

        _handleIncomingTransfer(_amount, currency);

        auction.highestBid = uint96(_amount);

        auction.highestBidder = msg.sender;

        bool extended;

        uint256 timeRemaining;

        unchecked {
            timeRemaining = firstBidTime + duration - block.timestamp;
        }

        if (timeRemaining < TIME_BUFFER) {
            unchecked {
                auction.duration += uint80(TIME_BUFFER - timeRemaining);
            }

            extended = true;
        }

        emit AuctionBid(_tokenContract, _tokenId, firstBid, extended, auction);
    }

    function settleAuction(address _tokenContract, uint256 _tokenId) external nonReentrant {
        Auction memory auction = auctionForNFT[_tokenContract][_tokenId];

        uint256 firstBidTime = auction.firstBidTime;

        require(firstBidTime != 0, "AUCTION_NOT_STARTED");

        require(block.timestamp >= (firstBidTime + auction.duration), "AUCTION_NOT_OVER");

        address currency = auction.currency;

        (uint256 remainingProfit, ) = _handleRoyaltyPayout(_tokenContract, _tokenId, auction.highestBid, currency, 300000);

        remainingProfit = _handleProtocolFeePayout(remainingProfit, currency);

        address listingFeeRecipient = auction.listingFeeRecipient;

        if (listingFeeRecipient != address(0)) {
            uint256 listingFee = (remainingProfit * auction.listingFeeBps) / 10000;

            _handleOutgoingTransfer(listingFeeRecipient, listingFee, currency, 50000);

            remainingProfit -= listingFee;
        }

        _handleOutgoingTransfer(auction.sellerFundsRecipient, remainingProfit, currency, 50000);

        IERC721(_tokenContract).transferFrom(address(this), auction.highestBidder, _tokenId);

        emit AuctionEnded(_tokenContract, _tokenId, auction);

        delete auctionForNFT[_tokenContract][_tokenId];
    }
}