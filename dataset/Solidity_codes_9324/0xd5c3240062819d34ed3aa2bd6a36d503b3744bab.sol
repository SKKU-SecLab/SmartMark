


pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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


pragma solidity 0.8.6;

 
interface IHuxleyComics is IERC721 {

    struct Issue {
        uint256 price;
        uint256 goldSupplyLeft;
        uint256 firstEditionSupplyLeft;
        uint256 holographicSupplyLeft;
        uint256 serialNumberToMintGold;
        uint256 serialNumberToMintFirstEdition;
        uint256 serialNumberToMintHolographic;
        uint256 maxPayableMintBatch;
        string uri;
        bool exist;
    }

    struct Token {
        uint256 serialNumber;
        uint256 issueNumber;
        TokenType tokenType;
    }

    enum TokenType {FirstEdition, Gold, Holographic}

    function safeMint(address _to) external returns (uint256);


    function getCurrentIssue() external returns (uint256 _currentIssue);

    function getCurrentPrice() external returns (uint256 _currentPrice);

    function getCurrentMaxPayableMintBatch() external returns (uint256 _currentMaxPayableMintBatch);


    function createNewIssue(
        uint256 _price,
        uint256 _goldSupply,
        uint256 _firstEditionSupply,
        uint256 _holographicSupply,
        uint256 _startSerialNumberGold,
        uint256 _startSerialNumberFirstEdition,
        uint256 _startSerialNumberHolographic,
        uint256 _maxPaybleMintBatch,
        string memory _uri
    ) external;


    function getIssue(uint256 _issueNumber) external returns (Issue memory _issue);


    function getToken(uint256 _tokenId) external returns (Token memory _token);


    function setTokenDetails(uint256 _tokenId, TokenType _tokenType) external;


    function setBaseURI(uint256 _issueNumber, string memory _uri) external;


    function setCanBurn(bool _canBurn) external;

}



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



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
}



pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}



pragma solidity ^0.8.0;




interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}



pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}



pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}



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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

interface IERC1271 {

    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);

}



pragma solidity ^0.8.0;




library SignatureChecker {

    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {

        if (Address.isContract(signer)) {
            try IERC1271(signer).isValidSignature(hash, signature) returns (bytes4 magicValue) {
                return magicValue == IERC1271(signer).isValidSignature.selector;
            } catch {
                return false;
            }
        } else {
            return ECDSA.recover(hash, signature) == signer;
        }
    }
}


pragma solidity 0.8.6;





contract HuxleyComicsOps is Pausable, AccessControl {

    using SignatureChecker for address;

    address public trustedWallet_A;
    address public trustedWallet_B;

    address public signer;

    IHuxleyComics public huxleyComics;

    mapping(address => bool) public blacklisted;

    mapping(address => mapping(uint256 => uint256)) public purchased;

    bytes32 public constant OPERATIONS_ROLE = keccak256("OPERATIONS_ROLE");

    event FundsTransfered(address _wallet, uint256 _amount);
    event IssueCreated(address _sender, uint256 _newIssue);
    event StartedBurn(address _sender);
    event StoppedBurn(address _sender);
    event IssueBaseURIUpdated(address _sender, string _uri);
    event FreeMintExecuted(address _sender);
    event FirstEditionMintExecuted(address _sender, uint256 _paid);

    constructor(
        address _operationAddress,
        address _trustedWallet_A,
        address _trustedWallet_B,
        address _huxLeyComics
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(OPERATIONS_ROLE, _operationAddress);

        trustedWallet_A = _trustedWallet_A;
        trustedWallet_B = _trustedWallet_B;

        huxleyComics = IHuxleyComics(_huxLeyComics);

        signer = msg.sender;

        _pause();
    }

    function createIssue(
        uint256 _price,
        uint256 _goldSupply,
        uint256 _firstEditionSupply,
        uint256 _holographicSupply,
        uint256 _startSerialNumberGold,
        uint256 _startSerialNumberFirstEdition,
        uint256 _startSerialNumberHolographic,
        uint256 _maxPayableMintBatch,
        string memory _uri
    ) external onlyRole(OPERATIONS_ROLE) {

        if (!paused()) {
            _pause();
        }

        huxleyComics.createNewIssue(
            _price,
            _goldSupply,
            _firstEditionSupply,
            _holographicSupply,
            _startSerialNumberGold,
            _startSerialNumberFirstEdition,
            _startSerialNumberHolographic,
            _maxPayableMintBatch,
            _uri
        );

        emit IssueCreated(msg.sender, huxleyComics.getCurrentIssue());
    }

    function setBaseURI(uint256 _issueNumber, string memory _uri)
        external
        onlyRole(OPERATIONS_ROLE)
    {

        huxleyComics.setBaseURI(_issueNumber, _uri);

        emit IssueBaseURIUpdated(msg.sender, _uri);
    }

    function freeMint(bytes memory signature) external {

        require(huxleyComics.getCurrentIssue() == 1, "Huxley: not issue 1");
        require(!blacklisted[msg.sender], "Huxley: blacklisted");
        require(isWhitelisted(signature), "Huxley: not whtl");
        require(isFirstToken(), "Huxley: not first");

        _mint(IHuxleyComics.TokenType.FirstEdition, 1);

        emit FreeMintExecuted(msg.sender);
    }

    function payableMint() external payable whenNotPaused {

        uint256 price = huxleyComics.getCurrentPrice();
        require(price == msg.value, "Huxley: invalid price");

        uint256 maxPayableMintBatch = huxleyComics.getCurrentMaxPayableMintBatch();

        _mint(IHuxleyComics.TokenType.FirstEdition, maxPayableMintBatch);

        payment();

        emit FirstEditionMintExecuted(msg.sender, msg.value);
    }

    function payableMintBatch(uint256 _amountToMint) external payable whenNotPaused {

        require(_amountToMint > 0, "Huxley: batch is 0");

        uint256 maxPayableMintBatch = huxleyComics.getCurrentMaxPayableMintBatch();
        require(_amountToMint <= maxPayableMintBatch, "Huxley: max batch");

        uint256 price = huxleyComics.getCurrentPrice();
        price = price * _amountToMint;

        require(price == msg.value, "Huxley: invalid price");

        for (uint256 i = 1; i <= _amountToMint; i++) {
            _mint(IHuxleyComics.TokenType.FirstEdition, maxPayableMintBatch);
        }

        payment();
    }

    function payment() internal {

        uint256 amount = (msg.value * 85) / 100;
        (bool success, ) = trustedWallet_A.call{value: amount}("");
        require(success, "HV: Transfer A failed");
        emit FundsTransfered(trustedWallet_A, amount);

        amount = msg.value - amount;
        (success, ) = trustedWallet_B.call{value: amount}("");
        require(success, "HV: Transfer B failed");
        emit FundsTransfered(trustedWallet_B, amount);
    }

    function privateMintFirstEditionBatch(uint256 _amountToMint)
        external
        onlyRole(OPERATIONS_ROLE)
    {

        privateMintBatch(_amountToMint, IHuxleyComics.TokenType.FirstEdition);
    }

    function privateMintGoldBatch(uint256 _amountToMint) external onlyRole(OPERATIONS_ROLE) {

        privateMintBatch(_amountToMint, IHuxleyComics.TokenType.Gold);
    }

    function privateMintHolographicBatch(uint256 _amountToMint)
        external
        onlyRole(OPERATIONS_ROLE)
    {

        privateMintBatch(_amountToMint, IHuxleyComics.TokenType.Holographic);
    }

    function privateMintBatch(uint256 _amountToMint, IHuxleyComics.TokenType _tokenType) internal {

        require(_amountToMint > 0, "Huxley: amount is 0");
        for (uint256 i = 1; i <= _amountToMint; i++) {
            _privateMint(_tokenType, true, 0);
        }
    }

    function _mint(IHuxleyComics.TokenType _tokenType, uint256 _maxAmount) internal {

        _privateMint(_tokenType, false, _maxAmount);
    }

    function _privateMint(IHuxleyComics.TokenType _tokenType, bool _isPrivateMint, uint256 _maxAmount) internal {

        if(!_isPrivateMint){
            uint256 totalTokenspurchased = purchased[msg.sender][huxleyComics.getCurrentIssue()];
            require(totalTokenspurchased < _maxAmount, "Huxley: over max amount");
            
            purchased[msg.sender][huxleyComics.getCurrentIssue()] = totalTokenspurchased + 1;
        }

        uint256 tokenId = huxleyComics.safeMint(msg.sender);
        huxleyComics.setTokenDetails(tokenId, _tokenType);
    }


    function setTrustedWallet_A(address _trustedWallet) external onlyRole(DEFAULT_ADMIN_ROLE) {

        trustedWallet_A = _trustedWallet;
    }

    function setTrustedWallet_B(address _trustedWallet) external onlyRole(DEFAULT_ADMIN_ROLE) {

        trustedWallet_B = _trustedWallet;
    }

    function setSigner(address _signer) external onlyRole(DEFAULT_ADMIN_ROLE) {

        signer = _signer;
    }

    function isFirstToken() internal view returns (bool) {

        uint256 balance = huxleyComics.balanceOf(msg.sender);
        return balance == 0;
    }

    function isWhitelisted(bytes memory signature) internal view returns (bool) {

        bytes32 result = keccak256(abi.encodePacked(msg.sender));
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", result));
        return signer.isValidSignatureNow(hash, signature);
    }

    function setBlacklisted(address _addr, bool _value) external onlyRole(OPERATIONS_ROLE) {

        blacklisted[_addr] = _value;
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {

        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {

        _unpause();
    }

    function startBurn() external onlyRole(DEFAULT_ADMIN_ROLE) {

        huxleyComics.setCanBurn(true);
        emit StartedBurn(msg.sender);
    }

    function stopBurn() external onlyRole(DEFAULT_ADMIN_ROLE) {

        huxleyComics.setCanBurn(false);
        emit StoppedBurn(msg.sender);
    }
}