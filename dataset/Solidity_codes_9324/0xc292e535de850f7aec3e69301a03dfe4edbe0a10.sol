


pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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




pragma solidity >=0.4.24 <0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}




pragma solidity >=0.6.0 <0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}




pragma solidity >=0.6.2 <0.8.0;

library ERC165CheckerUpgradeable {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    function supportsERC165(address account) internal view returns (bool) {

        return _supportsERC165Interface(account, _INTERFACE_ID_ERC165) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool[] memory) {

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

        (bool success, bool result) = _callERC165SupportsInterface(account, interfaceId);

        return (success && result);
    }

    function _callERC165SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool, bool)
    {

        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_ERC165, interfaceId);
        (bool success, bytes memory result) = account.staticcall{ gas: 30000 }(encodedParams);
        if (result.length < 32) return (false, false);
        return (success, abi.decode(result, (bool)));
    }
}




pragma solidity >=0.6.0 <0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity >=0.6.2 <0.8.0;

interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}




pragma solidity >=0.6.2 <0.8.0;

interface IERC1155Upgradeable is IERC165Upgradeable {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}




pragma solidity >=0.6.0 <0.8.0;

interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {


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

}




pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    uint256[49] private __gap;
}




pragma solidity >=0.6.0 <0.8.0;



abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal initializer {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
    }

    function __ERC1155Receiver_init_unchained() internal initializer {
        _registerInterface(
            ERC1155ReceiverUpgradeable(address(0)).onERC1155Received.selector ^
            ERC1155ReceiverUpgradeable(address(0)).onERC1155BatchReceived.selector
        );
    }
    uint256[50] private __gap;
}




pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}


pragma solidity >=0.5.0;

interface IUnicFactory {

    event TokenCreated(address indexed caller, address indexed uToken);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function converterImplementation() external view returns (address);


    function getUToken(address uToken) external view returns (uint);

    function uTokens(uint) external view returns (address);

    function uTokensLength() external view returns (uint);

    function getGovernorAlpha(address uToken) external view returns (address);

    function feeDivisor() external view returns (uint);

    function auctionHandler() external view returns (address);

    function uTokenSupply() external view returns (uint);

    function airdropAmount() external view returns (uint);

    function airdropEnabled() external view returns (bool);

    function unic() external view returns (address);

    function isAirdropCollection(address collection) external view returns (bool);

    function receivedAirdrop(address user) external view returns (bool);

    function owner() external view returns (address);

    function proxyTransactionFactory() external view returns (address);


    function createUToken(
        string calldata name,
        string calldata symbol,
        bool enableProxyTransactions
    ) external returns (address, address);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setConverterImplementation(address) external;

    function setFeeDivisor(uint) external;

    function setAuctionHandler(address) external;

    function setSupply(uint) external;

    function setProxyTransactionFactory(address _proxyTransactionFactory) external;

    function setAirdropCollections(address[] calldata, bool) external;

    function setAirdropReceived(address) external;

    function toggleAirdrop() external;

}


pragma solidity >=0.5.0;

interface IProxyTransaction {

    function forwardCall(address target, uint256 value, bytes calldata callData) external payable returns (bool success, bytes memory returnData);

}


pragma solidity 0.6.12;

interface IGetAuctionInfo {

    function onAuction(address uToken, uint nftIndexForUToken) external view returns (bool);

}


pragma solidity 0.6.12;

interface IConverter {

    function setConverterTimeLock(address _converterTimeLock) external;

}




pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity >=0.6.0 <0.8.0;




contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}




pragma solidity >=0.6.0 <0.8.0;



abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC20Burnable_init_unchained();
    }

    function __ERC20Burnable_init_unchained() internal initializer {
    }
    using SafeMathUpgradeable for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
    uint256[50] private __gap;
}


pragma solidity 0.6.12;


abstract contract ERC20VotesUpgradeable is ERC20BurnableUpgradeable  {
    using SafeMathUpgradeable for uint256;


    mapping (address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping (address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    function delegates(address delegator)
    external
    view
    returns (address)
    {
        return _delegates[delegator];
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
    external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "UNIC::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "UNIC::delegateBySig: invalid nonce");
        require(now <= expiry, "UNIC::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
    external
    view
    returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber)
    external
    view
    returns (uint256)
    {
        require(blockNumber < block.number, "UNIC::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
    internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying UNICs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
    internal
    {
        uint32 blockNumber = safe32(block.number, "UNIC::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}


pragma solidity 0.6.12;












contract Converter is IConverter, IProxyTransaction, Initializable, ERC1155ReceiverUpgradeable, ERC20VotesUpgradeable, OwnableUpgradeable {

    using SafeMathUpgradeable for uint;

    struct NFT {
        address contractAddr;
        uint256 tokenId;
        uint256 amount;
        uint256 triggerPrice;
    }

    mapping(uint256 => NFT) public nfts;
    uint256 public currentNFTIndex = 0;
    bool public active = false;
    address public issuer;
    uint256 public cap;
    address public converterTimeLock;

    IUnicFactory public factory;

    event Deposited(uint256[] tokenIDs, uint256[] amounts, uint256[] triggerPrices, address indexed contractAddr);
    event Refunded();
    event Issued();
    event PriceUpdate(uint256[] indexed nftIndex, uint[] price);

    bytes private constant VALIDATOR = bytes('JCMY');

    function initialize (
        string memory name,
        string memory symbol,
        address _issuer,
        address _factory
    )
        public
        initializer
        returns (bool)
    {
        require(_issuer != address(0) && _factory != address(0), "Invalid address");
        __Ownable_init();
        __ERC20_init(name, symbol);
        issuer = _issuer;
        factory = IUnicFactory(_factory);
        cap = factory.uTokenSupply();
        return true;
    }

    function burn(address _account, uint256 _amount) public {

        require(msg.sender == factory.auctionHandler(), "Converter: Only auction handler can burn");
        super._burn(_account, _amount);
    }

    function setCurator(address _issuer) external {

        require(active, "Converter: Tokens have not been issued yet");
        require(msg.sender == factory.owner() || msg.sender == issuer, "Converter: Not vault manager or issuer");

        issuer = _issuer;
    }

    function setTriggers(uint256[] calldata _nftIndex, uint256[] calldata _triggerPrices) external {

        require(msg.sender == issuer, "Converter: Only issuer can set trigger prices");
        require(_nftIndex.length <= 50, "Converter: A maximum of 50 trigger prices can be set at once");
        require(_nftIndex.length == _triggerPrices.length, "Array length mismatch");
        for (uint8 i = 0; i < 50; i++) {
            if (_nftIndex.length == i) {
                break;
            }
            nfts[_nftIndex[i]].triggerPrice = _triggerPrices[i];
        }

        emit PriceUpdate(_nftIndex, _triggerPrices);
    }

    function setConverterTimeLock(address _converterTimeLock) public override {

        require(msg.sender == address(factory), "Converter: Only factory can set converterTimeLock");
        require(_converterTimeLock != address(0), "Invalid address");
        converterTimeLock = _converterTimeLock;
    }

    function deposit(uint256[] calldata tokenIDs, uint256[] calldata amounts, uint256[] calldata triggerPrices, address contractAddr) external {

        require(msg.sender == issuer, "Converter: Only issuer can deposit");
        require(tokenIDs.length <= 50, "Converter: A maximum of 50 tokens can be deposited in one go");
        require(tokenIDs.length > 0, "Converter: You must specify at least one token ID");
        require(tokenIDs.length == triggerPrices.length, "Array length mismatch");

        if (ERC165CheckerUpgradeable.supportsInterface(contractAddr, 0xd9b67a26)){
            IERC1155Upgradeable(contractAddr).safeBatchTransferFrom(msg.sender, address(this), tokenIDs, amounts, VALIDATOR);

            for (uint8 i = 0; i < 50; i++){
                if (tokenIDs.length == i){
                    break;
                }
                nfts[currentNFTIndex++] = NFT(contractAddr, tokenIDs[i], amounts[i], triggerPrices[i]);
            }
        }
        else {
            for (uint8 i = 0; i < 50; i++){
                if (tokenIDs.length == i){
                    break;
                }
                IERC721Upgradeable(contractAddr).transferFrom(msg.sender, address(this), tokenIDs[i]);
                nfts[currentNFTIndex++] = NFT(contractAddr, tokenIDs[i], 1, triggerPrices[i]);
            }
        }

        emit Deposited(tokenIDs, amounts, triggerPrices, contractAddr);
    }

    function issue() external {

        require(msg.sender == issuer, "Converter: Only issuer can issue the tokens");
        require(active == false, "Converter: Token is already active");

        active = true;
        address feeTo = factory.feeTo();
        uint256 feeAmount = 0;
        if (feeTo != address(0)) {
            feeAmount = cap.div(factory.feeDivisor());
            _mint(feeTo, feeAmount);
        }

        uint256 amount = cap - feeAmount;
        _mint(issuer, amount);

        if (!factory.airdropEnabled()) {
            emit Issued();
            return;
        }

        if (!factory.receivedAirdrop(msg.sender)) {
            bool airdropEligible = false;
            for (uint8 i = 0; i < currentNFTIndex; i++) {
                if (factory.isAirdropCollection(nfts[i].contractAddr)) {
                    airdropEligible = true;
                    break;
                }
            }
            if (airdropEligible) {
                if (IERC20Upgradeable(factory.unic()).balanceOf(address(factory)) < factory.airdropAmount()) {
                    emit Issued();
                    return;
                }
                factory.setAirdropReceived(msg.sender);
                IERC20Upgradeable(factory.unic()).transferFrom(address(factory), msg.sender, factory.airdropAmount());
            }
        }

        emit Issued();
    }

    function refund(address _to) external {

        require(!active, "Converter: Contract is already active - cannot refund");
        require(msg.sender == issuer, "Converter: Only issuer can refund");

        uint8 _i = 0;
        uint256 _index = currentNFTIndex;
        bytes memory data;

        while (_index > 0 && _i < 50){
            NFT memory nft = nfts[_index - 1];

            if (ERC165CheckerUpgradeable.supportsInterface(nft.contractAddr, 0xd9b67a26)){
                IERC1155Upgradeable(nft.contractAddr).safeTransferFrom(address(this), _to, nft.tokenId, nft.amount, data);
            }
            else {
                IERC721Upgradeable(nft.contractAddr).safeTransferFrom(address(this), _to, nft.tokenId);
            }

            delete nfts[_index - 1];

            _index--;
            _i++;
        }

        currentNFTIndex = _index;

        emit Refunded();
    }

    function claimNFT(uint256 _nftIndex, address _to) external returns (bool) {

        require(msg.sender == factory.auctionHandler(), "Converter: Not auction handler");

        if (ERC165CheckerUpgradeable.supportsInterface(nfts[_nftIndex].contractAddr, 0xd9b67a26)){
            bytes memory data;
            IERC1155Upgradeable(nfts[_nftIndex].contractAddr).safeTransferFrom(address(this), _to, nfts[_nftIndex].tokenId, nfts[_nftIndex].amount, data);
        }
        else {
            IERC721Upgradeable(nfts[_nftIndex].contractAddr).safeTransferFrom(address(this), _to, nfts[_nftIndex].tokenId);
        }

        return true;
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) override external returns(bytes4) {

        if(keccak256(_data) == keccak256(VALIDATOR)){
            return 0xf23a6e61;
        }
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) override external returns(bytes4) {

        if(keccak256(_data) == keccak256(VALIDATOR)){
            return 0xbc197c81;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {

        super._beforeTokenTransfer(from, to, amount);
        _moveDelegates(_delegates[from], _delegates[to], amount);
    }

    function forwardCall(address target, uint256 value, bytes calldata callData) external override payable returns (bool success, bytes memory returnData) {

        require(target != address(factory), "Converter: No proxy transactions calling factory allowed");
        require(target != address(factory.unic()), "Converter: No proxy transactions calling unic allowed");
        require(msg.sender == converterTimeLock, "Converter: Caller is not the converterTimeLock contract");
        return target.call{value: value}(callData);
    }

    function getBlockTimestamp() internal view returns (uint) {

        return block.timestamp;
    }
}