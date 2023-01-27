
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
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

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IDispatcher {
    function cancelMigration(address _vaultProxy, bool _bypassFailure) external;

    function claimOwnership() external;

    function deployVaultProxy(
        address _vaultLib,
        address _owner,
        address _vaultAccessor,
        string calldata _fundName
    ) external returns (address vaultProxy_);

    function executeMigration(address _vaultProxy, bool _bypassFailure) external;

    function getCurrentFundDeployer() external view returns (address currentFundDeployer_);

    function getFundDeployerForVaultProxy(address _vaultProxy)
        external
        view
        returns (address fundDeployer_);

    function getMigrationRequestDetailsForVaultProxy(address _vaultProxy)
        external
        view
        returns (
            address nextFundDeployer_,
            address nextVaultAccessor_,
            address nextVaultLib_,
            uint256 executableTimestamp_
        );

    function getMigrationTimelock() external view returns (uint256 migrationTimelock_);

    function getNominatedOwner() external view returns (address nominatedOwner_);

    function getOwner() external view returns (address owner_);

    function getSharesTokenSymbol() external view returns (string memory sharesTokenSymbol_);

    function getTimelockRemainingForMigrationRequest(address _vaultProxy)
        external
        view
        returns (uint256 secondsRemaining_);

    function hasExecutableMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasExecutableRequest_);

    function hasMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasMigrationRequest_);

    function removeNominatedOwner() external;

    function setCurrentFundDeployer(address _nextFundDeployer) external;

    function setMigrationTimelock(uint256 _nextTimelock) external;

    function setNominatedOwner(address _nextNominatedOwner) external;

    function setSharesTokenSymbol(string calldata _nextSymbol) external;

    function signalMigration(
        address _vaultProxy,
        address _nextVaultAccessor,
        address _nextVaultLib,
        bool _bypassFailure
    ) external;
}// GPL-3.0


pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract AddressListRegistry {
    enum UpdateType {None, AddOnly, RemoveOnly, AddAndRemove}

    event ItemAddedToList(uint256 indexed id, address item);

    event ItemRemovedFromList(uint256 indexed id, address item);

    event ListAttested(uint256 indexed id, string description);

    event ListCreated(
        address indexed creator,
        address indexed owner,
        uint256 id,
        UpdateType updateType
    );

    event ListOwnerSet(uint256 indexed id, address indexed nextOwner);

    event ListUpdateTypeSet(
        uint256 indexed id,
        UpdateType prevUpdateType,
        UpdateType indexed nextUpdateType
    );

    struct ListInfo {
        address owner;
        UpdateType updateType;
        mapping(address => bool) itemToIsInList;
    }

    address private immutable DISPATCHER;

    ListInfo[] private lists;

    modifier onlyListOwner(uint256 _id) {
        require(__isListOwner(msg.sender, _id), "Only callable by list owner");
        _;
    }

    constructor(address _dispatcher) public {
        DISPATCHER = _dispatcher;

        lists.push(ListInfo({owner: address(0), updateType: UpdateType.None}));
    }


    function addToList(uint256 _id, address[] calldata _items) external onlyListOwner(_id) {
        UpdateType updateType = getListUpdateType(_id);
        require(
            updateType == UpdateType.AddOnly || updateType == UpdateType.AddAndRemove,
            "addToList: Cannot add to list"
        );

        __addToList(_id, _items);
    }

    function attestLists(uint256[] calldata _ids, string[] calldata _descriptions) external {
        require(_ids.length == _descriptions.length, "attestLists: Unequal arrays");

        for (uint256 i; i < _ids.length; i++) {
            require(
                __isListOwner(msg.sender, _ids[i]),
                "attestLists: Only callable by list owner"
            );

            emit ListAttested(_ids[i], _descriptions[i]);
        }
    }

    function createList(
        address _owner,
        UpdateType _updateType,
        address[] calldata _initialItems
    ) external returns (uint256 id_) {
        id_ = getListCount();

        lists.push(ListInfo({owner: _owner, updateType: _updateType}));

        emit ListCreated(msg.sender, _owner, id_, _updateType);

        __addToList(id_, _initialItems);

        return id_;
    }

    function removeFromList(uint256 _id, address[] calldata _items) external onlyListOwner(_id) {
        UpdateType updateType = getListUpdateType(_id);
        require(
            updateType == UpdateType.RemoveOnly || updateType == UpdateType.AddAndRemove,
            "removeFromList: Cannot remove from list"
        );

        for (uint256 i; i < _items.length; i++) {
            if (isInList(_id, _items[i])) {
                lists[_id].itemToIsInList[_items[i]] = false;

                emit ItemRemovedFromList(_id, _items[i]);
            }
        }
    }

    function setListOwner(uint256 _id, address _nextOwner) external onlyListOwner(_id) {
        lists[_id].owner = _nextOwner;

        emit ListOwnerSet(_id, _nextOwner);
    }

    function setListUpdateType(uint256 _id, UpdateType _nextUpdateType)
        external
        onlyListOwner(_id)
    {
        UpdateType prevUpdateType = getListUpdateType(_id);
        require(
            _nextUpdateType == UpdateType.None || prevUpdateType == UpdateType.AddAndRemove,
            "setListUpdateType: _nextUpdateType not allowed"
        );

        lists[_id].updateType = _nextUpdateType;

        emit ListUpdateTypeSet(_id, prevUpdateType, _nextUpdateType);
    }


    function __addToList(uint256 _id, address[] memory _items) private {
        for (uint256 i; i < _items.length; i++) {
            if (!isInList(_id, _items[i])) {
                lists[_id].itemToIsInList[_items[i]] = true;

                emit ItemAddedToList(_id, _items[i]);
            }
        }
    }

    function __isListOwner(address _who, uint256 _id) private view returns (bool isListOwner_) {
        address owner = getListOwner(_id);
        return
            _who == owner ||
            (owner == getDispatcher() && _who == IDispatcher(getDispatcher()).getOwner());
    }





    function areAllInList(uint256 _id, address[] memory _items)
        external
        view
        returns (bool areAllInList_)
    {
        for (uint256 i; i < _items.length; i++) {
            if (!isInList(_id, _items[i])) {
                return false;
            }
        }

        return true;
    }

    function areAllNotInList(uint256 _id, address[] memory _items)
        external
        view
        returns (bool areAllNotInList_)
    {
        for (uint256 i; i < _items.length; i++) {
            if (isInList(_id, _items[i])) {
                return false;
            }
        }

        return true;
    }


    function areAllInAllLists(uint256[] memory _ids, address[] memory _items)
        external
        view
        returns (bool areAllInAllLists_)
    {
        for (uint256 i; i < _items.length; i++) {
            if (!isInAllLists(_ids, _items[i])) {
                return false;
            }
        }

        return true;
    }

    function areAllInSomeOfLists(uint256[] memory _ids, address[] memory _items)
        external
        view
        returns (bool areAllInSomeOfLists_)
    {
        for (uint256 i; i < _items.length; i++) {
            if (!isInSomeOfLists(_ids, _items[i])) {
                return false;
            }
        }

        return true;
    }

    function areAllNotInAnyOfLists(uint256[] memory _ids, address[] memory _items)
        external
        view
        returns (bool areAllNotInAnyOfLists_)
    {
        for (uint256 i; i < _items.length; i++) {
            if (isInSomeOfLists(_ids, _items[i])) {
                return false;
            }
        }

        return true;
    }



    function isInAllLists(uint256[] memory _ids, address _item)
        public
        view
        returns (bool isInAllLists_)
    {
        for (uint256 i; i < _ids.length; i++) {
            if (!isInList(_ids[i], _item)) {
                return false;
            }
        }

        return true;
    }

    function isInSomeOfLists(uint256[] memory _ids, address _item)
        public
        view
        returns (bool isInSomeOfLists_)
    {
        for (uint256 i; i < _ids.length; i++) {
            if (isInList(_ids[i], _item)) {
                return true;
            }
        }

        return false;
    }


    function getDispatcher() public view returns (address dispatcher_) {
        return DISPATCHER;
    }

    function getListCount() public view returns (uint256 count_) {
        return lists.length;
    }

    function getListOwner(uint256 _id) public view returns (address owner_) {
        return lists[_id].owner;
    }

    function getListUpdateType(uint256 _id) public view returns (UpdateType updateType_) {
        return lists[_id].updateType;
    }

    function isInList(uint256 _id, address _item) public view returns (bool isInList_) {
        return lists[_id].itemToIsInList[_item];
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IExternalPosition {
    function getDebtAssets() external returns (address[] memory, uint256[] memory);

    function getManagedAssets() external returns (address[] memory, uint256[] memory);

    function init(bytes memory) external;

    function receiveCallFromVault(bytes memory) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IProtocolFeeReserve1 {
    function buyBackSharesViaTrustedVaultProxy(
        uint256 _sharesAmount,
        uint256 _mlnValue,
        uint256 _gav
    ) external returns (uint256 mlnAmountToBurn_);
}// GPL-3.0


pragma solidity 0.6.12;

interface IMigratableVault {
    function canMigrate(address _who) external view returns (bool canMigrate_);

    function init(
        address _owner,
        address _accessor,
        string calldata _fundName
    ) external;

    function setAccessor(address _nextAccessor) external;

    function setVaultLib(address _nextVaultLib) external;
}// GPL-3.0


pragma solidity 0.6.12;

abstract contract ProxiableVaultLib {
    function __updateCodeAddress(address _nextVaultLib) internal {
        require(
            bytes32(0x027b9570e9fedc1a80b937ae9a06861e5faef3992491af30b684a64b3fbec7a5) ==
                ProxiableVaultLib(_nextVaultLib).proxiableUUID(),
            "__updateCodeAddress: _nextVaultLib not compatible"
        );
        assembly {
            sstore(
                0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc,
                _nextVaultLib
            )
        }
    }

    function proxiableUUID() public pure returns (bytes32 uuid_) {
        return 0x027b9570e9fedc1a80b937ae9a06861e5faef3992491af30b684a64b3fbec7a5;
    }
}// GPL-3.0


pragma solidity 0.6.12;

library VaultLibSafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "VaultLibSafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "VaultLibSafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "VaultLibSafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "VaultLibSafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "VaultLibSafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract SharesTokenBase {
    using VaultLibSafeMath for uint256;

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);

    string internal sharesName;
    string internal sharesSymbol;
    uint256 internal sharesTotalSupply;
    mapping(address => uint256) internal sharesBalances;
    mapping(address => mapping(address => uint256)) internal sharesAllowances;


    function approve(address _spender, uint256 _amount) public virtual returns (bool) {
        __approve(msg.sender, _spender, _amount);
        return true;
    }

    function transfer(address _recipient, uint256 _amount) public virtual returns (bool) {
        __transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public virtual returns (bool) {
        __transfer(_sender, _recipient, _amount);
        __approve(
            _sender,
            msg.sender,
            sharesAllowances[_sender][msg.sender].sub(
                _amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }


    function allowance(address _owner, address _spender) public view virtual returns (uint256) {
        return sharesAllowances[_owner][_spender];
    }

    function balanceOf(address _account) public view virtual returns (uint256) {
        return sharesBalances[_account];
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function name() public view virtual returns (string memory) {
        return sharesName;
    }

    function symbol() public view virtual returns (string memory) {
        return sharesSymbol;
    }

    function totalSupply() public view virtual returns (uint256) {
        return sharesTotalSupply;
    }


    function __approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        sharesAllowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function __burn(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "ERC20: burn from the zero address");

        sharesBalances[_account] = sharesBalances[_account].sub(
            _amount,
            "ERC20: burn amount exceeds balance"
        );
        sharesTotalSupply = sharesTotalSupply.sub(_amount);
        emit Transfer(_account, address(0), _amount);
    }

    function __mint(address _account, uint256 _amount) internal virtual {
        require(_account != address(0), "ERC20: mint to the zero address");

        sharesTotalSupply = sharesTotalSupply.add(_amount);
        sharesBalances[_account] = sharesBalances[_account].add(_amount);
        emit Transfer(address(0), _account, _amount);
    }

    function __transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal virtual {
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(_recipient != address(0), "ERC20: transfer to the zero address");

        sharesBalances[_sender] = sharesBalances[_sender].sub(
            _amount,
            "ERC20: transfer amount exceeds balance"
        );
        sharesBalances[_recipient] = sharesBalances[_recipient].add(_amount);
        emit Transfer(_sender, _recipient, _amount);
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract VaultLibBaseCore is IMigratableVault, ProxiableVaultLib, SharesTokenBase {
    event AccessorSet(address prevAccessor, address nextAccessor);

    event MigratorSet(address prevMigrator, address nextMigrator);

    event OwnerSet(address prevOwner, address nextOwner);

    event VaultLibSet(address prevVaultLib, address nextVaultLib);

    address internal accessor;
    address internal creator;
    address internal migrator;
    address internal owner;


    function init(
        address _owner,
        address _accessor,
        string calldata _fundName
    ) external override {
        require(creator == address(0), "init: Proxy already initialized");
        creator = msg.sender;
        sharesName = _fundName;

        __setAccessor(_accessor);
        __setOwner(_owner);

        emit VaultLibSet(address(0), getVaultLib());
    }

    function setAccessor(address _nextAccessor) external override {
        require(msg.sender == creator, "setAccessor: Only callable by the contract creator");

        __setAccessor(_nextAccessor);
    }

    function setVaultLib(address _nextVaultLib) external override {
        require(msg.sender == creator, "setVaultLib: Only callable by the contract creator");

        address prevVaultLib = getVaultLib();

        __updateCodeAddress(_nextVaultLib);

        emit VaultLibSet(prevVaultLib, _nextVaultLib);
    }


    function canMigrate(address _who) public view virtual override returns (bool canMigrate_) {
        return _who == owner || _who == migrator;
    }

    function getVaultLib() public view returns (address vaultLib_) {
        assembly {
            vaultLib_ := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
        }
        return vaultLib_;
    }


    function __setAccessor(address _nextAccessor) internal {
        require(_nextAccessor != address(0), "__setAccessor: _nextAccessor cannot be empty");
        address prevAccessor = accessor;

        accessor = _nextAccessor;

        emit AccessorSet(prevAccessor, _nextAccessor);
    }

    function __setOwner(address _nextOwner) internal {
        require(_nextOwner != address(0), "__setOwner: _nextOwner cannot be empty");
        address prevOwner = owner;
        require(_nextOwner != prevOwner, "__setOwner: _nextOwner is the current owner");

        owner = _nextOwner;

        emit OwnerSet(prevOwner, _nextOwner);
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract VaultLibBase1 is VaultLibBaseCore {
    event AssetWithdrawn(address indexed asset, address indexed target, uint256 amount);

    event TrackedAssetAdded(address asset);

    event TrackedAssetRemoved(address asset);

    address[] internal trackedAssets;
    mapping(address => bool) internal assetToIsTracked;
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract VaultLibBase2 is VaultLibBase1 {
    event AssetManagerAdded(address manager);

    event AssetManagerRemoved(address manager);

    event EthReceived(address indexed sender, uint256 amount);

    event ExternalPositionAdded(address indexed externalPosition);

    event ExternalPositionRemoved(address indexed externalPosition);

    event FreelyTransferableSharesSet();

    event NameSet(string name);

    event NominatedOwnerRemoved(address indexed nominatedOwner);

    event NominatedOwnerSet(address indexed nominatedOwner);

    event ProtocolFeePaidInShares(uint256 sharesAmount);

    event ProtocolFeeSharesBoughtBack(uint256 sharesAmount, uint256 mlnValue, uint256 mlnBurned);

    event OwnershipTransferred(address indexed prevOwner, address indexed nextOwner);

    event SymbolSet(string symbol);

    bool internal freelyTransferableShares;
    address internal nominatedOwner;
    address[] internal activeExternalPositions;
    mapping(address => bool) internal accountToIsAssetManager;
    mapping(address => bool) internal externalPositionToIsActive;
}// GPL-3.0


pragma solidity 0.6.12;

interface IExternalPositionVault {
    function getExternalPositionLibForType(uint256) external view returns (address);
}// GPL-3.0


pragma solidity 0.6.12;

interface IFreelyTransferableSharesVault {
    function sharesAreFreelyTransferable()
        external
        view
        returns (bool sharesAreFreelyTransferable_);
}// GPL-3.0


pragma solidity 0.6.12;

interface IFundDeployer {
    function getOwner() external view returns (address);

    function hasReconfigurationRequest(address) external view returns (bool);

    function isAllowedBuySharesOnBehalfCaller(address) external view returns (bool);

    function isAllowedVaultCall(
        address,
        bytes4,
        bytes32
    ) external view returns (bool);
}// GPL-3.0


pragma solidity 0.6.12;

interface IExtension {
    function activateForFund(bool _isMigration) external;

    function deactivateForFund() external;

    function receiveCallFromComptroller(
        address _caller,
        uint256 _actionId,
        bytes calldata _callArgs
    ) external;

    function setConfigForFund(
        address _comptrollerProxy,
        address _vaultProxy,
        bytes calldata _configData
    ) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IFeeManager {
    enum FeeHook {Continuous, PreBuyShares, PostBuyShares, PreRedeemShares}
    enum SettlementType {None, Direct, Mint, Burn, MintSharesOutstanding, BurnSharesOutstanding}

    function invokeHook(
        FeeHook,
        bytes calldata,
        uint256
    ) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IPolicyManager {
    enum PolicyHook {
        PostBuyShares,
        PostCallOnIntegration,
        PreTransferShares,
        RedeemSharesForSpecificAssets,
        AddTrackedAssets,
        RemoveTrackedAssets,
        CreateExternalPosition,
        PostCallOnExternalPosition,
        RemoveExternalPosition,
        ReactivateExternalPosition
    }

    function validatePolicies(
        address,
        PolicyHook,
        bytes calldata
    ) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IBeacon {
    function getCanonicalLib() external view returns (address);
}// GPL-3.0



pragma solidity 0.6.12;

interface IBeaconProxyFactory is IBeacon {
    function deployProxy(bytes memory _constructData) external returns (address proxy_);

    function setCanonicalLib(address _canonicalLib) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IGsnForwarder {
    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
        uint256 validUntil;
    }
}// GPL-3.0


pragma solidity 0.6.12;


interface IGsnTypes {
    struct RelayData {
        uint256 gasPrice;
        uint256 pctRelayFee;
        uint256 baseRelayFee;
        address relayWorker;
        address paymaster;
        address forwarder;
        bytes paymasterData;
        uint256 clientId;
    }

    struct RelayRequest {
        IGsnForwarder.ForwardRequest request;
        RelayData relayData;
    }
}// GPL-3.0


pragma solidity 0.6.12;


interface IGsnPaymaster {
    struct GasAndDataLimits {
        uint256 acceptanceBudget;
        uint256 preRelayedCallGasLimit;
        uint256 postRelayedCallGasLimit;
        uint256 calldataSizeLimit;
    }

    function getGasAndDataLimits() external view returns (GasAndDataLimits memory limits);

    function getHubAddr() external view returns (address);

    function getRelayHubDeposit() external view returns (uint256);

    function preRelayedCall(
        IGsnTypes.RelayRequest calldata relayRequest,
        bytes calldata signature,
        bytes calldata approvalData,
        uint256 maxPossibleGas
    ) external returns (bytes memory context, bool rejectOnRecipientRevert);

    function postRelayedCall(
        bytes calldata context,
        bool success,
        uint256 gasUseWithoutPost,
        IGsnTypes.RelayData calldata relayData
    ) external;

    function trustedForwarder() external view returns (address);

    function versionPaymaster() external view returns (string memory);
}// GPL-3.0


pragma solidity 0.6.12;


interface IGasRelayPaymaster is IGsnPaymaster {
    function deposit() external;

    function withdrawBalance() external;
}// GPL-3.0



pragma solidity 0.6.12;

abstract contract GasRelayRecipientMixin {
    address internal immutable GAS_RELAY_PAYMASTER_FACTORY;

    constructor(address _gasRelayPaymasterFactory) internal {
        GAS_RELAY_PAYMASTER_FACTORY = _gasRelayPaymasterFactory;
    }

    function __msgSender() internal view returns (address payable canonicalSender_) {
        if (msg.data.length >= 24 && msg.sender == getGasRelayTrustedForwarder()) {
            assembly {
                canonicalSender_ := shr(96, calldataload(sub(calldatasize(), 20)))
            }

            return canonicalSender_;
        }

        return msg.sender;
    }


    function getGasRelayPaymasterFactory()
        public
        view
        returns (address gasRelayPaymasterFactory_)
    {
        return GAS_RELAY_PAYMASTER_FACTORY;
    }

    function getGasRelayTrustedForwarder() public view returns (address trustedForwarder_) {
        return
            IGasRelayPaymaster(
                IBeaconProxyFactory(getGasRelayPaymasterFactory()).getCanonicalLib()
            )
                .trustedForwarder();
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IGasRelayPaymasterDepositor {
    function pullWethForGasRelayer(uint256) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IValueInterpreter {
    function calcCanonicalAssetValue(
        address,
        uint256,
        address
    ) external returns (uint256);

    function calcCanonicalAssetsTotalValue(
        address[] calldata,
        uint256[] calldata,
        address
    ) external returns (uint256);

    function isSupportedAsset(address) external view returns (bool);

    function isSupportedDerivativeAsset(address) external view returns (bool);

    function isSupportedPrimitiveAsset(address) external view returns (bool);
}// GPL-3.0


pragma solidity 0.6.12;

library AddressArrayLib {

    function removeStorageItem(address[] storage _self, address _itemToRemove)
        internal
        returns (bool removed_)
    {
        uint256 itemCount = _self.length;
        for (uint256 i; i < itemCount; i++) {
            if (_self[i] == _itemToRemove) {
                if (i < itemCount - 1) {
                    _self[i] = _self[itemCount - 1];
                }
                _self.pop();
                removed_ = true;
                break;
            }
        }

        return removed_;
    }


    function addItem(address[] memory _self, address _itemToAdd)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        nextArray_ = new address[](_self.length + 1);
        for (uint256 i; i < _self.length; i++) {
            nextArray_[i] = _self[i];
        }
        nextArray_[_self.length] = _itemToAdd;

        return nextArray_;
    }

    function addUniqueItem(address[] memory _self, address _itemToAdd)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        if (contains(_self, _itemToAdd)) {
            return _self;
        }

        return addItem(_self, _itemToAdd);
    }

    function contains(address[] memory _self, address _target)
        internal
        pure
        returns (bool doesContain_)
    {
        for (uint256 i; i < _self.length; i++) {
            if (_target == _self[i]) {
                return true;
            }
        }
        return false;
    }

    function mergeArray(address[] memory _self, address[] memory _arrayToMerge)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        uint256 newUniqueItemCount;
        for (uint256 i; i < _arrayToMerge.length; i++) {
            if (!contains(_self, _arrayToMerge[i])) {
                newUniqueItemCount++;
            }
        }

        if (newUniqueItemCount == 0) {
            return _self;
        }

        nextArray_ = new address[](_self.length + newUniqueItemCount);
        for (uint256 i; i < _self.length; i++) {
            nextArray_[i] = _self[i];
        }
        uint256 nextArrayIndex = _self.length;
        for (uint256 i; i < _arrayToMerge.length; i++) {
            if (!contains(_self, _arrayToMerge[i])) {
                nextArray_[nextArrayIndex] = _arrayToMerge[i];
                nextArrayIndex++;
            }
        }

        return nextArray_;
    }

    function isUniqueSet(address[] memory _self) internal pure returns (bool isUnique_) {
        if (_self.length <= 1) {
            return true;
        }

        uint256 arrayLength = _self.length;
        for (uint256 i; i < arrayLength; i++) {
            for (uint256 j = i + 1; j < arrayLength; j++) {
                if (_self[i] == _self[j]) {
                    return false;
                }
            }
        }

        return true;
    }

    function removeItems(address[] memory _self, address[] memory _itemsToRemove)
        internal
        pure
        returns (address[] memory nextArray_)
    {
        if (_itemsToRemove.length == 0) {
            return _self;
        }

        bool[] memory indexesToRemove = new bool[](_self.length);
        uint256 remainingItemsCount = _self.length;
        for (uint256 i; i < _self.length; i++) {
            if (contains(_itemsToRemove, _self[i])) {
                indexesToRemove[i] = true;
                remainingItemsCount--;
            }
        }

        if (remainingItemsCount == _self.length) {
            nextArray_ = _self;
        } else if (remainingItemsCount > 0) {
            nextArray_ = new address[](remainingItemsCount);
            uint256 nextArrayIndex;
            for (uint256 i; i < _self.length; i++) {
                if (!indexesToRemove[i]) {
                    nextArray_[nextArrayIndex] = _self[i];
                    nextArrayIndex++;
                }
            }
        }

        return nextArray_;
    }
}// GPL-3.0


pragma solidity 0.6.12;


interface IVault is IMigratableVault, IFreelyTransferableSharesVault, IExternalPositionVault {
    enum VaultAction {
        None,
        BurnShares,
        MintShares,
        TransferShares,
        AddTrackedAsset,
        ApproveAssetSpender,
        RemoveTrackedAsset,
        WithdrawAssetTo,
        AddExternalPosition,
        CallOnExternalPosition,
        RemoveExternalPosition
    }

    function addTrackedAsset(address) external;

    function burnShares(address, uint256) external;

    function buyBackProtocolFeeShares(
        uint256,
        uint256,
        uint256
    ) external;

    function callOnContract(address, bytes calldata) external returns (bytes memory);

    function canManageAssets(address) external view returns (bool);

    function canRelayCalls(address) external view returns (bool);

    function getAccessor() external view returns (address);

    function getOwner() external view returns (address);

    function getActiveExternalPositions() external view returns (address[] memory);

    function getTrackedAssets() external view returns (address[] memory);

    function isActiveExternalPosition(address) external view returns (bool);

    function isTrackedAsset(address) external view returns (bool);

    function mintShares(address, uint256) external;

    function payProtocolFee() external;

    function receiveValidatedVaultAction(VaultAction, bytes calldata) external;

    function setAccessorForFundReconfiguration(address) external;

    function setSymbol(string calldata) external;

    function transferShares(
        address,
        address,
        uint256
    ) external;

    function withdrawAssetTo(
        address,
        address,
        uint256
    ) external;
}// GPL-3.0


pragma solidity 0.6.12;


interface IComptroller {
    function activate(bool) external;

    function calcGav() external returns (uint256);

    function calcGrossShareValue() external returns (uint256);

    function callOnExtension(
        address,
        uint256,
        bytes calldata
    ) external;

    function destructActivated(uint256, uint256) external;

    function destructUnactivated() external;

    function getDenominationAsset() external view returns (address);

    function getExternalPositionManager() external view returns (address);

    function getFeeManager() external view returns (address);

    function getFundDeployer() external view returns (address);

    function getGasRelayPaymaster() external view returns (address);

    function getIntegrationManager() external view returns (address);

    function getPolicyManager() external view returns (address);

    function getVaultProxy() external view returns (address);

    function init(address, uint256) external;

    function permissionedVaultAction(IVault.VaultAction, bytes calldata) external;

    function preTransferSharesHook(
        address,
        address,
        uint256
    ) external;

    function preTransferSharesHookFreelyTransferable(address) external view;

    function setGasRelayPaymaster(address) external;

    function setVaultProxy(address) external;
}// GPL-3.0


pragma solidity 0.6.12;


contract ComptrollerLib is IComptroller, IGasRelayPaymasterDepositor, GasRelayRecipientMixin {
    using AddressArrayLib for address[];
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    event AutoProtocolFeeSharesBuybackSet(bool autoProtocolFeeSharesBuyback);

    event BuyBackMaxProtocolFeeSharesFailed(
        bytes indexed failureReturnData,
        uint256 sharesAmount,
        uint256 buybackValueInMln,
        uint256 gav
    );
    event DeactivateFeeManagerFailed();

    event GasRelayPaymasterSet(address gasRelayPaymaster);

    event MigratedSharesDuePaid(uint256 sharesDue);

    event PayProtocolFeeDuringDestructFailed();

    event PreRedeemSharesHookFailed(
        bytes indexed failureReturnData,
        address indexed redeemer,
        uint256 sharesAmount
    );

    event RedeemSharesInKindCalcGavFailed();

    event SharesBought(
        address indexed buyer,
        uint256 investmentAmount,
        uint256 sharesIssued,
        uint256 sharesReceived
    );

    event SharesRedeemed(
        address indexed redeemer,
        address indexed recipient,
        uint256 sharesAmount,
        address[] receivedAssets,
        uint256[] receivedAssetAmounts
    );

    event VaultProxySet(address vaultProxy);

    uint256 private constant ONE_HUNDRED_PERCENT = 10000;
    uint256 private constant SHARES_UNIT = 10**18;
    address
        private constant SPECIFIC_ASSET_REDEMPTION_DUMMY_FORFEIT_ADDRESS = 0x000000000000000000000000000000000000aaaa;
    address private immutable DISPATCHER;
    address private immutable EXTERNAL_POSITION_MANAGER;
    address private immutable FUND_DEPLOYER;
    address private immutable FEE_MANAGER;
    address private immutable INTEGRATION_MANAGER;
    address private immutable MLN_TOKEN;
    address private immutable POLICY_MANAGER;
    address private immutable PROTOCOL_FEE_RESERVE;
    address private immutable VALUE_INTERPRETER;
    address private immutable WETH_TOKEN;


    address internal denominationAsset;
    address internal vaultProxy;
    bool internal isLib;


    bool internal autoProtocolFeeSharesBuyback;
    bool internal permissionedVaultActionAllowed;
    bool internal reentranceLocked;
    uint256 internal sharesActionTimelock;
    mapping(address => uint256) internal acctToLastSharesBoughtTimestamp;
    address private gasRelayPaymaster;


    modifier allowsPermissionedVaultAction {
        __assertPermissionedVaultActionNotAllowed();
        permissionedVaultActionAllowed = true;
        _;
        permissionedVaultActionAllowed = false;
    }

    modifier locksReentrance() {
        __assertNotReentranceLocked();
        reentranceLocked = true;
        _;
        reentranceLocked = false;
    }

    modifier onlyFundDeployer() {
        __assertIsFundDeployer();
        _;
    }
    modifier onlyGasRelayPaymaster() {
        __assertIsGasRelayPaymaster();
        _;
    }

    modifier onlyOwner() {
        __assertIsOwner(__msgSender());
        _;
    }

    modifier onlyOwnerNotRelayable() {
        __assertIsOwner(msg.sender);
        _;
    }



    function __assertIsFundDeployer() private view {
        require(msg.sender == getFundDeployer(), "Only FundDeployer callable");
    }

    function __assertIsGasRelayPaymaster() private view {
        require(msg.sender == getGasRelayPaymaster(), "Only Gas Relay Paymaster callable");
    }

    function __assertIsOwner(address _who) private view {
        require(_who == IVault(getVaultProxy()).getOwner(), "Only fund owner callable");
    }

    function __assertNotReentranceLocked() private view {
        require(!reentranceLocked, "Re-entrance");
    }

    function __assertPermissionedVaultActionNotAllowed() private view {
        require(!permissionedVaultActionAllowed, "Vault action re-entrance");
    }

    function __assertSharesActionNotTimelocked(address _vaultProxy, address _account)
        private
        view
    {
        uint256 lastSharesBoughtTimestamp = getLastSharesBoughtTimestampForAccount(_account);

        require(
            lastSharesBoughtTimestamp == 0 ||
                block.timestamp.sub(lastSharesBoughtTimestamp) >= getSharesActionTimelock() ||
                __hasPendingMigrationOrReconfiguration(_vaultProxy),
            "Shares action timelocked"
        );
    }

    constructor(
        address _dispatcher,
        address _protocolFeeReserve,
        address _fundDeployer,
        address _valueInterpreter,
        address _externalPositionManager,
        address _feeManager,
        address _integrationManager,
        address _policyManager,
        address _gasRelayPaymasterFactory,
        address _mlnToken,
        address _wethToken
    ) public GasRelayRecipientMixin(_gasRelayPaymasterFactory) {
        DISPATCHER = _dispatcher;
        EXTERNAL_POSITION_MANAGER = _externalPositionManager;
        FEE_MANAGER = _feeManager;
        FUND_DEPLOYER = _fundDeployer;
        INTEGRATION_MANAGER = _integrationManager;
        MLN_TOKEN = _mlnToken;
        POLICY_MANAGER = _policyManager;
        PROTOCOL_FEE_RESERVE = _protocolFeeReserve;
        VALUE_INTERPRETER = _valueInterpreter;
        WETH_TOKEN = _wethToken;
        isLib = true;
    }


    function callOnExtension(
        address _extension,
        uint256 _actionId,
        bytes calldata _callArgs
    ) external override locksReentrance allowsPermissionedVaultAction {
        require(
            _extension == getFeeManager() ||
                _extension == getIntegrationManager() ||
                _extension == getExternalPositionManager(),
            "callOnExtension: _extension invalid"
        );

        IExtension(_extension).receiveCallFromComptroller(__msgSender(), _actionId, _callArgs);
    }

    function vaultCallOnContract(
        address _contract,
        bytes4 _selector,
        bytes calldata _encodedArgs
    ) external onlyOwner returns (bytes memory returnData_) {
        require(
            IFundDeployer(getFundDeployer()).isAllowedVaultCall(
                _contract,
                _selector,
                keccak256(_encodedArgs)
            ),
            "vaultCallOnContract: Not allowed"
        );

        return
            IVault(getVaultProxy()).callOnContract(
                _contract,
                abi.encodePacked(_selector, _encodedArgs)
            );
    }

    function __hasPendingMigrationOrReconfiguration(address _vaultProxy)
        private
        view
        returns (bool hasPendingMigrationOrReconfiguration)
    {
        return
            IDispatcher(getDispatcher()).hasMigrationRequest(_vaultProxy) ||
            IFundDeployer(getFundDeployer()).hasReconfigurationRequest(_vaultProxy);
    }


    function buyBackProtocolFeeShares(uint256 _sharesAmount) external {
        address vaultProxyCopy = vaultProxy;
        require(
            IVault(vaultProxyCopy).canManageAssets(__msgSender()),
            "buyBackProtocolFeeShares: Unauthorized"
        );

        uint256 gav = calcGav();

        IVault(vaultProxyCopy).buyBackProtocolFeeShares(
            _sharesAmount,
            __getBuybackValueInMln(vaultProxyCopy, _sharesAmount, gav),
            gav
        );
    }

    function setAutoProtocolFeeSharesBuyback(bool _nextAutoProtocolFeeSharesBuyback)
        external
        onlyOwner
    {
        autoProtocolFeeSharesBuyback = _nextAutoProtocolFeeSharesBuyback;

        emit AutoProtocolFeeSharesBuybackSet(_nextAutoProtocolFeeSharesBuyback);
    }

    function __buyBackMaxProtocolFeeShares(address _vaultProxy, uint256 _gav) private {
        uint256 sharesAmount = ERC20(_vaultProxy).balanceOf(getProtocolFeeReserve());
        uint256 buybackValueInMln = __getBuybackValueInMln(_vaultProxy, sharesAmount, _gav);

        try
            IVault(_vaultProxy).buyBackProtocolFeeShares(sharesAmount, buybackValueInMln, _gav)
         {} catch (bytes memory reason) {
            emit BuyBackMaxProtocolFeeSharesFailed(reason, sharesAmount, buybackValueInMln, _gav);
        }
    }

    function __getBuybackValueInMln(
        address _vaultProxy,
        uint256 _sharesAmount,
        uint256 _gav
    ) private returns (uint256 buybackValueInMln_) {
        address denominationAssetCopy = getDenominationAsset();

        uint256 grossShareValue = __calcGrossShareValue(
            _gav,
            ERC20(_vaultProxy).totalSupply(),
            10**uint256(ERC20(denominationAssetCopy).decimals())
        );

        uint256 buybackValueInDenominationAsset = grossShareValue.mul(_sharesAmount).div(
            SHARES_UNIT
        );

        return
            IValueInterpreter(getValueInterpreter()).calcCanonicalAssetValue(
                denominationAssetCopy,
                buybackValueInDenominationAsset,
                getMlnToken()
            );
    }


    function permissionedVaultAction(IVault.VaultAction _action, bytes calldata _actionData)
        external
        override
    {
        __assertPermissionedVaultAction(msg.sender, _action);

        if (_action == IVault.VaultAction.RemoveTrackedAsset) {
            require(
                abi.decode(_actionData, (address)) != getDenominationAsset(),
                "permissionedVaultAction: Cannot untrack denomination asset"
            );
        }

        IVault(getVaultProxy()).receiveValidatedVaultAction(_action, _actionData);
    }

    function __assertPermissionedVaultAction(address _caller, IVault.VaultAction _action)
        private
        view
    {
        bool validAction;
        if (permissionedVaultActionAllowed) {
            if (_caller == getIntegrationManager()) {
                if (
                    _action == IVault.VaultAction.AddTrackedAsset ||
                    _action == IVault.VaultAction.RemoveTrackedAsset ||
                    _action == IVault.VaultAction.WithdrawAssetTo ||
                    _action == IVault.VaultAction.ApproveAssetSpender
                ) {
                    validAction = true;
                }
            } else if (_caller == getFeeManager()) {
                if (
                    _action == IVault.VaultAction.MintShares ||
                    _action == IVault.VaultAction.BurnShares ||
                    _action == IVault.VaultAction.TransferShares
                ) {
                    validAction = true;
                }
            } else if (_caller == getExternalPositionManager()) {
                if (
                    _action == IVault.VaultAction.CallOnExternalPosition ||
                    _action == IVault.VaultAction.AddExternalPosition ||
                    _action == IVault.VaultAction.RemoveExternalPosition
                ) {
                    validAction = true;
                }
            }
        }

        require(validAction, "__assertPermissionedVaultAction: Action not allowed");
    }



    function init(address _denominationAsset, uint256 _sharesActionTimelock) external override {
        require(getDenominationAsset() == address(0), "init: Already initialized");
        require(
            IValueInterpreter(getValueInterpreter()).isSupportedPrimitiveAsset(_denominationAsset),
            "init: Bad denomination asset"
        );

        denominationAsset = _denominationAsset;
        sharesActionTimelock = _sharesActionTimelock;
    }

    function setVaultProxy(address _vaultProxy) external override onlyFundDeployer {
        vaultProxy = _vaultProxy;

        emit VaultProxySet(_vaultProxy);
    }

    function activate(bool _isMigration) external override onlyFundDeployer {
        address vaultProxyCopy = getVaultProxy();

        if (_isMigration) {
            uint256 sharesDue = ERC20(vaultProxyCopy).balanceOf(vaultProxyCopy);
            if (sharesDue > 0) {
                IVault(vaultProxyCopy).transferShares(
                    vaultProxyCopy,
                    IVault(vaultProxyCopy).getOwner(),
                    sharesDue
                );

                emit MigratedSharesDuePaid(sharesDue);
            }
        }

        IVault(vaultProxyCopy).addTrackedAsset(getDenominationAsset());

        IExtension(getFeeManager()).activateForFund(_isMigration);
        IExtension(getPolicyManager()).activateForFund(_isMigration);
    }

    function destructActivated(
        uint256 _deactivateFeeManagerGasLimit,
        uint256 _payProtocolFeeGasLimit
    ) external override onlyFundDeployer allowsPermissionedVaultAction {
        try IVault(getVaultProxy()).payProtocolFee{gas: _payProtocolFeeGasLimit}()  {} catch {
            emit PayProtocolFeeDuringDestructFailed();
        }



        try
            IExtension(getFeeManager()).deactivateForFund{gas: _deactivateFeeManagerGasLimit}()
         {} catch {
            emit DeactivateFeeManagerFailed();
        }

        __selfDestruct();
    }

    function destructUnactivated() external override onlyFundDeployer {
        __selfDestruct();
    }

    function __selfDestruct() private {
        require(!isLib, "__selfDestruct: Only delegate callable");

        selfdestruct(payable(address(this)));
    }


    function calcGav() public override returns (uint256 gav_) {
        address vaultProxyAddress = getVaultProxy();
        address[] memory assets = IVault(vaultProxyAddress).getTrackedAssets();
        address[] memory externalPositions = IVault(vaultProxyAddress)
            .getActiveExternalPositions();

        if (assets.length == 0 && externalPositions.length == 0) {
            return 0;
        }

        uint256[] memory balances = new uint256[](assets.length);
        for (uint256 i; i < assets.length; i++) {
            balances[i] = ERC20(assets[i]).balanceOf(vaultProxyAddress);
        }

        gav_ = IValueInterpreter(getValueInterpreter()).calcCanonicalAssetsTotalValue(
            assets,
            balances,
            getDenominationAsset()
        );

        if (externalPositions.length > 0) {
            for (uint256 i; i < externalPositions.length; i++) {
                uint256 externalPositionValue = __calcExternalPositionValue(externalPositions[i]);

                gav_ = gav_.add(externalPositionValue);
            }
        }

        return gav_;
    }

    function calcGrossShareValue() external override returns (uint256 grossShareValue_) {
        uint256 gav = calcGav();

        grossShareValue_ = __calcGrossShareValue(
            gav,
            ERC20(getVaultProxy()).totalSupply(),
            10**uint256(ERC20(getDenominationAsset()).decimals())
        );

        return grossShareValue_;
    }

    function __calcExternalPositionValue(address _externalPosition)
        private
        returns (uint256 value_)
    {
        (address[] memory managedAssets, uint256[] memory managedAmounts) = IExternalPosition(
            _externalPosition
        )
            .getManagedAssets();

        uint256 managedValue = IValueInterpreter(getValueInterpreter())
            .calcCanonicalAssetsTotalValue(managedAssets, managedAmounts, getDenominationAsset());

        (address[] memory debtAssets, uint256[] memory debtAmounts) = IExternalPosition(
            _externalPosition
        )
            .getDebtAssets();

        uint256 debtValue = IValueInterpreter(getValueInterpreter()).calcCanonicalAssetsTotalValue(
            debtAssets,
            debtAmounts,
            getDenominationAsset()
        );

        if (managedValue > debtValue) {
            value_ = managedValue.sub(debtValue);
        }

        return value_;
    }

    function __calcGrossShareValue(
        uint256 _gav,
        uint256 _sharesSupply,
        uint256 _denominationAssetUnit
    ) private pure returns (uint256 grossShareValue_) {
        if (_sharesSupply == 0) {
            return _denominationAssetUnit;
        }

        return _gav.mul(SHARES_UNIT).div(_sharesSupply);
    }



    function buySharesOnBehalf(
        address _buyer,
        uint256 _investmentAmount,
        uint256 _minSharesQuantity
    ) external returns (uint256 sharesReceived_) {
        bool hasSharesActionTimelock = getSharesActionTimelock() > 0;
        address canonicalSender = __msgSender();

        require(
            !hasSharesActionTimelock ||
                IFundDeployer(getFundDeployer()).isAllowedBuySharesOnBehalfCaller(canonicalSender),
            "buySharesOnBehalf: Unauthorized"
        );

        return
            __buyShares(
                _buyer,
                _investmentAmount,
                _minSharesQuantity,
                hasSharesActionTimelock,
                canonicalSender
            );
    }

    function buyShares(uint256 _investmentAmount, uint256 _minSharesQuantity)
        external
        returns (uint256 sharesReceived_)
    {
        bool hasSharesActionTimelock = getSharesActionTimelock() > 0;
        address canonicalSender = __msgSender();

        return
            __buyShares(
                canonicalSender,
                _investmentAmount,
                _minSharesQuantity,
                hasSharesActionTimelock,
                canonicalSender
            );
    }

    function __buyShares(
        address _buyer,
        uint256 _investmentAmount,
        uint256 _minSharesQuantity,
        bool _hasSharesActionTimelock,
        address _canonicalSender
    ) private locksReentrance allowsPermissionedVaultAction returns (uint256 sharesReceived_) {
        require(_minSharesQuantity > 0, "__buyShares: _minSharesQuantity must be >0");

        address vaultProxyCopy = getVaultProxy();
        require(
            !_hasSharesActionTimelock || !__hasPendingMigrationOrReconfiguration(vaultProxyCopy),
            "__buyShares: Pending migration or reconfiguration"
        );

        uint256 gav = calcGav();

        __preBuySharesHook(_buyer, _investmentAmount, gav);

        IVault(vaultProxyCopy).payProtocolFee();
        if (doesAutoProtocolFeeSharesBuyback()) {
            __buyBackMaxProtocolFeeShares(vaultProxyCopy, gav);
        }

        uint256 receivedInvestmentAmount = __transferFromWithReceivedAmount(
            getDenominationAsset(),
            _canonicalSender,
            vaultProxyCopy,
            _investmentAmount
        );

        uint256 sharePrice = __calcGrossShareValue(
            gav,
            ERC20(vaultProxyCopy).totalSupply(),
            10**uint256(ERC20(getDenominationAsset()).decimals())
        );
        uint256 sharesIssued = receivedInvestmentAmount.mul(SHARES_UNIT).div(sharePrice);

        uint256 prevBuyerShares = ERC20(vaultProxyCopy).balanceOf(_buyer);
        IVault(vaultProxyCopy).mintShares(_buyer, sharesIssued);

        __postBuySharesHook(_buyer, receivedInvestmentAmount, sharesIssued, gav);

        sharesReceived_ = ERC20(vaultProxyCopy).balanceOf(_buyer).sub(prevBuyerShares);
        require(
            sharesReceived_ >= _minSharesQuantity,
            "__buyShares: Shares received < _minSharesQuantity"
        );

        if (_hasSharesActionTimelock) {
            acctToLastSharesBoughtTimestamp[_buyer] = block.timestamp;
        }

        emit SharesBought(_buyer, receivedInvestmentAmount, sharesIssued, sharesReceived_);

        return sharesReceived_;
    }

    function __preBuySharesHook(
        address _buyer,
        uint256 _investmentAmount,
        uint256 _gav
    ) private {
        IFeeManager(getFeeManager()).invokeHook(
            IFeeManager.FeeHook.PreBuyShares,
            abi.encode(_buyer, _investmentAmount),
            _gav
        );
    }

    function __postBuySharesHook(
        address _buyer,
        uint256 _investmentAmount,
        uint256 _sharesIssued,
        uint256 _preBuySharesGav
    ) private {
        uint256 gav = _preBuySharesGav.add(_investmentAmount);
        IFeeManager(getFeeManager()).invokeHook(
            IFeeManager.FeeHook.PostBuyShares,
            abi.encode(_buyer, _investmentAmount, _sharesIssued),
            gav
        );

        IPolicyManager(getPolicyManager()).validatePolicies(
            address(this),
            IPolicyManager.PolicyHook.PostBuyShares,
            abi.encode(_buyer, _investmentAmount, _sharesIssued, gav)
        );
    }

    function __transferFromWithReceivedAmount(
        address _asset,
        address _sender,
        address _recipient,
        uint256 _transferAmount
    ) private returns (uint256 receivedAmount_) {
        uint256 preTransferRecipientBalance = ERC20(_asset).balanceOf(_recipient);

        ERC20(_asset).safeTransferFrom(_sender, _recipient, _transferAmount);

        return ERC20(_asset).balanceOf(_recipient).sub(preTransferRecipientBalance);
    }


    function redeemSharesForSpecificAssets(
        address _recipient,
        uint256 _sharesQuantity,
        address[] calldata _payoutAssets,
        uint256[] calldata _payoutAssetPercentages
    ) external locksReentrance returns (uint256[] memory payoutAmounts_) {
        address canonicalSender = __msgSender();
        require(
            _payoutAssets.length == _payoutAssetPercentages.length,
            "redeemSharesForSpecificAssets: Unequal arrays"
        );
        require(
            _payoutAssets.isUniqueSet(),
            "redeemSharesForSpecificAssets: Duplicate payout asset"
        );

        uint256 gav = calcGav();

        IVault vaultProxyContract = IVault(getVaultProxy());
        (uint256 sharesToRedeem, uint256 sharesSupply) = __redeemSharesSetup(
            vaultProxyContract,
            canonicalSender,
            _sharesQuantity,
            true,
            gav
        );

        payoutAmounts_ = __payoutSpecifiedAssetPercentages(
            vaultProxyContract,
            _recipient,
            _payoutAssets,
            _payoutAssetPercentages,
            gav.mul(sharesToRedeem).div(sharesSupply)
        );

        __postRedeemSharesForSpecificAssetsHook(
            canonicalSender,
            _recipient,
            sharesToRedeem,
            _payoutAssets,
            payoutAmounts_,
            gav
        );

        emit SharesRedeemed(
            canonicalSender,
            _recipient,
            sharesToRedeem,
            _payoutAssets,
            payoutAmounts_
        );

        return payoutAmounts_;
    }

    function redeemSharesInKind(
        address _recipient,
        uint256 _sharesQuantity,
        address[] calldata _additionalAssets,
        address[] calldata _assetsToSkip
    )
        external
        locksReentrance
        returns (address[] memory payoutAssets_, uint256[] memory payoutAmounts_)
    {
        address canonicalSender = __msgSender();
        require(
            _additionalAssets.isUniqueSet(),
            "redeemSharesInKind: _additionalAssets contains duplicates"
        );
        require(
            _assetsToSkip.isUniqueSet(),
            "redeemSharesInKind: _assetsToSkip contains duplicates"
        );

        payoutAssets_ = __parseRedemptionPayoutAssets(
            IVault(vaultProxy).getTrackedAssets(),
            _additionalAssets,
            _assetsToSkip
        );

        uint256 gavOrZero;
        if (doesAutoProtocolFeeSharesBuyback()) {
            try this.calcGav() returns (uint256 gav) {
                gavOrZero = gav;
            } catch {
                emit RedeemSharesInKindCalcGavFailed();
            }
        }

        (uint256 sharesToRedeem, uint256 sharesSupply) = __redeemSharesSetup(
            IVault(vaultProxy),
            canonicalSender,
            _sharesQuantity,
            false,
            gavOrZero
        );

        payoutAmounts_ = new uint256[](payoutAssets_.length);
        for (uint256 i; i < payoutAssets_.length; i++) {
            payoutAmounts_[i] = ERC20(payoutAssets_[i])
                .balanceOf(vaultProxy)
                .mul(sharesToRedeem)
                .div(sharesSupply);

            if (payoutAmounts_[i] > 0) {
                IVault(vaultProxy).withdrawAssetTo(
                    payoutAssets_[i],
                    _recipient,
                    payoutAmounts_[i]
                );
            }
        }

        emit SharesRedeemed(
            canonicalSender,
            _recipient,
            sharesToRedeem,
            payoutAssets_,
            payoutAmounts_
        );

        return (payoutAssets_, payoutAmounts_);
    }

    function __parseRedemptionPayoutAssets(
        address[] memory _trackedAssets,
        address[] memory _additionalAssets,
        address[] memory _assetsToSkip
    ) private pure returns (address[] memory payoutAssets_) {
        address[] memory trackedAssetsToPayout = _trackedAssets.removeItems(_assetsToSkip);
        if (_additionalAssets.length == 0) {
            return trackedAssetsToPayout;
        }

        bool[] memory indexesToAdd = new bool[](_additionalAssets.length);
        uint256 additionalItemsCount;
        for (uint256 i; i < _additionalAssets.length; i++) {
            if (!trackedAssetsToPayout.contains(_additionalAssets[i])) {
                indexesToAdd[i] = true;
                additionalItemsCount++;
            }
        }
        if (additionalItemsCount == 0) {
            return trackedAssetsToPayout;
        }

        payoutAssets_ = new address[](trackedAssetsToPayout.length.add(additionalItemsCount));
        for (uint256 i; i < trackedAssetsToPayout.length; i++) {
            payoutAssets_[i] = trackedAssetsToPayout[i];
        }
        uint256 payoutAssetsIndex = trackedAssetsToPayout.length;
        for (uint256 i; i < _additionalAssets.length; i++) {
            if (indexesToAdd[i]) {
                payoutAssets_[payoutAssetsIndex] = _additionalAssets[i];
                payoutAssetsIndex++;
            }
        }

        return payoutAssets_;
    }

    function __payoutSpecifiedAssetPercentages(
        IVault vaultProxyContract,
        address _recipient,
        address[] calldata _payoutAssets,
        uint256[] calldata _payoutAssetPercentages,
        uint256 _owedGav
    ) private returns (uint256[] memory payoutAmounts_) {
        address denominationAssetCopy = getDenominationAsset();
        uint256 percentagesTotal;
        payoutAmounts_ = new uint256[](_payoutAssets.length);
        for (uint256 i; i < _payoutAssets.length; i++) {
            percentagesTotal = percentagesTotal.add(_payoutAssetPercentages[i]);

            if (_payoutAssets[i] == SPECIFIC_ASSET_REDEMPTION_DUMMY_FORFEIT_ADDRESS) {
                continue;
            }

            payoutAmounts_[i] = IValueInterpreter(getValueInterpreter()).calcCanonicalAssetValue(
                denominationAssetCopy,
                _owedGav.mul(_payoutAssetPercentages[i]).div(ONE_HUNDRED_PERCENT),
                _payoutAssets[i]
            );
            require(
                payoutAmounts_[i] > 0,
                "__payoutSpecifiedAssetPercentages: Zero amount for asset"
            );

            vaultProxyContract.withdrawAssetTo(_payoutAssets[i], _recipient, payoutAmounts_[i]);
        }

        require(
            percentagesTotal == ONE_HUNDRED_PERCENT,
            "__payoutSpecifiedAssetPercentages: Percents must total 100%"
        );

        return payoutAmounts_;
    }

    function __preRedeemSharesHook(
        address _redeemer,
        uint256 _sharesToRedeem,
        bool _forSpecifiedAssets,
        uint256 _gavIfCalculated
    ) private allowsPermissionedVaultAction {
        try
            IFeeManager(getFeeManager()).invokeHook(
                IFeeManager.FeeHook.PreRedeemShares,
                abi.encode(_redeemer, _sharesToRedeem, _forSpecifiedAssets),
                _gavIfCalculated
            )
         {} catch (bytes memory reason) {
            emit PreRedeemSharesHookFailed(reason, _redeemer, _sharesToRedeem);
        }
    }

    function __postRedeemSharesForSpecificAssetsHook(
        address _redeemer,
        address _recipient,
        uint256 _sharesToRedeemPostFees,
        address[] memory _assets,
        uint256[] memory _assetAmounts,
        uint256 _gavPreRedeem
    ) private {
        IPolicyManager(getPolicyManager()).validatePolicies(
            address(this),
            IPolicyManager.PolicyHook.RedeemSharesForSpecificAssets,
            abi.encode(
                _redeemer,
                _recipient,
                _sharesToRedeemPostFees,
                _assets,
                _assetAmounts,
                _gavPreRedeem
            )
        );
    }

    function __redeemSharesSetup(
        IVault vaultProxyContract,
        address _redeemer,
        uint256 _sharesQuantityInput,
        bool _forSpecifiedAssets,
        uint256 _gavIfCalculated
    ) private returns (uint256 sharesToRedeem_, uint256 sharesSupply_) {
        __assertSharesActionNotTimelocked(address(vaultProxyContract), _redeemer);

        ERC20 sharesContract = ERC20(address(vaultProxyContract));

        uint256 preFeesRedeemerSharesBalance = sharesContract.balanceOf(_redeemer);

        if (_sharesQuantityInput == type(uint256).max) {
            sharesToRedeem_ = preFeesRedeemerSharesBalance;
        } else {
            sharesToRedeem_ = _sharesQuantityInput;
        }
        require(sharesToRedeem_ > 0, "__redeemSharesSetup: No shares to redeem");

        __preRedeemSharesHook(_redeemer, sharesToRedeem_, _forSpecifiedAssets, _gavIfCalculated);

        uint256 postFeesRedeemerSharesBalance = sharesContract.balanceOf(_redeemer);
        if (_sharesQuantityInput == type(uint256).max) {
            sharesToRedeem_ = postFeesRedeemerSharesBalance;
        } else if (postFeesRedeemerSharesBalance < preFeesRedeemerSharesBalance) {
            sharesToRedeem_ = sharesToRedeem_.sub(
                preFeesRedeemerSharesBalance.sub(postFeesRedeemerSharesBalance)
            );
        }

        vaultProxyContract.payProtocolFee();

        if (_gavIfCalculated > 0 && doesAutoProtocolFeeSharesBuyback()) {
            __buyBackMaxProtocolFeeShares(address(vaultProxyContract), _gavIfCalculated);
        }

        sharesSupply_ = sharesContract.totalSupply();
        vaultProxyContract.burnShares(_redeemer, sharesToRedeem_);

        return (sharesToRedeem_, sharesSupply_);
    }


    function preTransferSharesHook(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external override {
        address vaultProxyCopy = getVaultProxy();
        require(msg.sender == vaultProxyCopy, "preTransferSharesHook: Only VaultProxy callable");
        __assertSharesActionNotTimelocked(vaultProxyCopy, _sender);

        IPolicyManager(getPolicyManager()).validatePolicies(
            address(this),
            IPolicyManager.PolicyHook.PreTransferShares,
            abi.encode(_sender, _recipient, _amount)
        );
    }

    function preTransferSharesHookFreelyTransferable(address _sender) external view override {
        __assertSharesActionNotTimelocked(getVaultProxy(), _sender);
    }


    function deployGasRelayPaymaster() external onlyOwnerNotRelayable {
        require(
            getGasRelayPaymaster() == address(0),
            "deployGasRelayPaymaster: Paymaster already deployed"
        );

        bytes memory constructData = abi.encodeWithSignature("init(address)", getVaultProxy());
        address paymaster = IBeaconProxyFactory(getGasRelayPaymasterFactory()).deployProxy(
            constructData
        );

        __setGasRelayPaymaster(paymaster);

        __depositToGasRelayPaymaster(paymaster);
    }

    function depositToGasRelayPaymaster() external onlyOwner {
        __depositToGasRelayPaymaster(getGasRelayPaymaster());
    }

    function pullWethForGasRelayer(uint256 _amount) external override onlyGasRelayPaymaster {
        IVault(getVaultProxy()).withdrawAssetTo(getWethToken(), getGasRelayPaymaster(), _amount);
    }

    function setGasRelayPaymaster(address _nextGasRelayPaymaster)
        external
        override
        onlyFundDeployer
    {
        __setGasRelayPaymaster(_nextGasRelayPaymaster);
    }

    function shutdownGasRelayPaymaster() external onlyOwnerNotRelayable {
        IGasRelayPaymaster(gasRelayPaymaster).withdrawBalance();

        IVault(vaultProxy).addTrackedAsset(getWethToken());

        delete gasRelayPaymaster;

        emit GasRelayPaymasterSet(address(0));
    }

    function __depositToGasRelayPaymaster(address _paymaster) private {
        IGasRelayPaymaster(_paymaster).deposit();
    }

    function __setGasRelayPaymaster(address _nextGasRelayPaymaster) private {
        gasRelayPaymaster = _nextGasRelayPaymaster;

        emit GasRelayPaymasterSet(_nextGasRelayPaymaster);
    }



    function getDispatcher() public view returns (address dispatcher_) {
        return DISPATCHER;
    }

    function getExternalPositionManager()
        public
        view
        override
        returns (address externalPositionManager_)
    {
        return EXTERNAL_POSITION_MANAGER;
    }

    function getFeeManager() public view override returns (address feeManager_) {
        return FEE_MANAGER;
    }

    function getFundDeployer() public view override returns (address fundDeployer_) {
        return FUND_DEPLOYER;
    }

    function getIntegrationManager() public view override returns (address integrationManager_) {
        return INTEGRATION_MANAGER;
    }

    function getMlnToken() public view returns (address mlnToken_) {
        return MLN_TOKEN;
    }

    function getPolicyManager() public view override returns (address policyManager_) {
        return POLICY_MANAGER;
    }

    function getProtocolFeeReserve() public view returns (address protocolFeeReserve_) {
        return PROTOCOL_FEE_RESERVE;
    }

    function getValueInterpreter() public view returns (address valueInterpreter_) {
        return VALUE_INTERPRETER;
    }

    function getWethToken() public view returns (address wethToken_) {
        return WETH_TOKEN;
    }


    function doesAutoProtocolFeeSharesBuyback() public view returns (bool doesAutoBuyback_) {
        return autoProtocolFeeSharesBuyback;
    }

    function getDenominationAsset() public view override returns (address denominationAsset_) {
        return denominationAsset;
    }

    function getGasRelayPaymaster() public view override returns (address gasRelayPaymaster_) {
        return gasRelayPaymaster;
    }

    function getLastSharesBoughtTimestampForAccount(address _who)
        public
        view
        returns (uint256 lastSharesBoughtTimestamp_)
    {
        return acctToLastSharesBoughtTimestamp[_who];
    }

    function getSharesActionTimelock() public view returns (uint256 sharesActionTimelock_) {
        return sharesActionTimelock;
    }

    function getVaultProxy() public view override returns (address vaultProxy_) {
        return vaultProxy;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IProtocolFeeTracker {
    function initializeForVault(address) external;

    function payFee() external returns (uint256);
}// GPL-3.0


pragma solidity 0.6.12;

interface IExternalPositionManager {
    struct ExternalPositionTypeInfo {
        address parser;
        address lib;
    }
    enum ExternalPositionManagerActions {
        CreateExternalPosition,
        CallOnExternalPosition,
        RemoveExternalPosition,
        ReactivateExternalPosition
    }

    function getExternalPositionLibForType(uint256) external view returns (address);
}// GPL-3.0


pragma solidity 0.6.12;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256) external;
}// GPL-3.0


pragma solidity 0.6.12;


contract VaultLib is VaultLibBase2, IVault, GasRelayRecipientMixin {
    using AddressArrayLib for address[];
    using SafeERC20 for ERC20;

    address private immutable EXTERNAL_POSITION_MANAGER;
    address private immutable MLN_BURNER;
    address private immutable MLN_TOKEN;
    uint256 private immutable POSITIONS_LIMIT;
    address private immutable PROTOCOL_FEE_RESERVE;
    address private immutable PROTOCOL_FEE_TRACKER;
    address private immutable WETH_TOKEN;

    modifier notShares(address _asset) {
        require(_asset != address(this), "Cannot act on shares");
        _;
    }

    modifier onlyAccessor() {
        require(msg.sender == accessor, "Only the designated accessor can make this call");
        _;
    }

    modifier onlyOwner() {
        require(__msgSender() == owner, "Only the owner can call this function");
        _;
    }

    constructor(
        address _externalPositionManager,
        address _gasRelayPaymasterFactory,
        address _protocolFeeReserve,
        address _protocolFeeTracker,
        address _mlnToken,
        address _mlnBurner,
        address _wethToken,
        uint256 _positionsLimit
    ) public GasRelayRecipientMixin(_gasRelayPaymasterFactory) {
        EXTERNAL_POSITION_MANAGER = _externalPositionManager;
        MLN_BURNER = _mlnBurner;
        MLN_TOKEN = _mlnToken;
        POSITIONS_LIMIT = _positionsLimit;
        PROTOCOL_FEE_RESERVE = _protocolFeeReserve;
        PROTOCOL_FEE_TRACKER = _protocolFeeTracker;
        WETH_TOKEN = _wethToken;
    }

    receive() external payable {
        uint256 ethAmount = payable(address(this)).balance;
        IWETH(payable(getWethToken())).deposit{value: ethAmount}();

        emit EthReceived(msg.sender, ethAmount);
    }


    function getExternalPositionLibForType(uint256 _typeId)
        external
        view
        override
        returns (address externalPositionLib_)
    {
        return
            IExternalPositionManager(getExternalPositionManager()).getExternalPositionLibForType(
                _typeId
            );
    }

    function setFreelyTransferableShares() external onlyOwner {
        require(!sharesAreFreelyTransferable(), "setFreelyTransferableShares: Already set");

        freelyTransferableShares = true;

        emit FreelyTransferableSharesSet();
    }

    function setName(string calldata _nextName) external onlyOwner {
        sharesName = _nextName;

        emit NameSet(_nextName);
    }

    function setSymbol(string calldata _nextSymbol) external override {
        require(__msgSender() == owner || msg.sender == getFundDeployer(), "Unauthorized");

        sharesSymbol = _nextSymbol;

        emit SymbolSet(_nextSymbol);
    }


    function addAssetManagers(address[] calldata _managers) external onlyOwner {
        for (uint256 i; i < _managers.length; i++) {
            require(!isAssetManager(_managers[i]), "addAssetManagers: Manager already registered");

            accountToIsAssetManager[_managers[i]] = true;

            emit AssetManagerAdded(_managers[i]);
        }
    }

    function claimOwnership() external {
        address nextOwner = nominatedOwner;
        require(
            msg.sender == nextOwner,
            "claimOwnership: Only the nominatedOwner can call this function"
        );

        delete nominatedOwner;

        address prevOwner = owner;
        owner = nextOwner;

        emit OwnershipTransferred(prevOwner, nextOwner);
    }

    function removeAssetManagers(address[] calldata _managers) external onlyOwner {
        for (uint256 i; i < _managers.length; i++) {
            require(isAssetManager(_managers[i]), "removeAssetManagers: Manager not registered");

            accountToIsAssetManager[_managers[i]] = false;

            emit AssetManagerRemoved(_managers[i]);
        }
    }

    function removeNominatedOwner() external onlyOwner {
        address removedNominatedOwner = nominatedOwner;
        require(
            removedNominatedOwner != address(0),
            "removeNominatedOwner: There is no nominated owner"
        );

        delete nominatedOwner;

        emit NominatedOwnerRemoved(removedNominatedOwner);
    }

    function setMigrator(address _nextMigrator) external onlyOwner {
        address prevMigrator = migrator;
        require(_nextMigrator != prevMigrator, "setMigrator: Value already set");

        migrator = _nextMigrator;

        emit MigratorSet(prevMigrator, _nextMigrator);
    }

    function setNominatedOwner(address _nextNominatedOwner) external onlyOwner {
        require(
            _nextNominatedOwner != address(0),
            "setNominatedOwner: _nextNominatedOwner cannot be empty"
        );
        require(
            _nextNominatedOwner != owner,
            "setNominatedOwner: _nextNominatedOwner is already the owner"
        );
        require(
            _nextNominatedOwner != nominatedOwner,
            "setNominatedOwner: _nextNominatedOwner is already nominated"
        );

        nominatedOwner = _nextNominatedOwner;

        emit NominatedOwnerSet(_nextNominatedOwner);
    }


    function setAccessorForFundReconfiguration(address _nextAccessor) external override {
        require(msg.sender == getFundDeployer(), "Only the FundDeployer can make this call");

        __setAccessor(_nextAccessor);
    }


    function addTrackedAsset(address _asset) external override onlyAccessor {
        __addTrackedAsset(_asset);
    }

    function burnShares(address _target, uint256 _amount) external override onlyAccessor {
        __burn(_target, _amount);
    }

    function buyBackProtocolFeeShares(
        uint256 _sharesAmount,
        uint256 _mlnValue,
        uint256 _gav
    ) external override onlyAccessor {
        uint256 mlnAmountToBurn = IProtocolFeeReserve1(getProtocolFeeReserve())
            .buyBackSharesViaTrustedVaultProxy(_sharesAmount, _mlnValue, _gav);

        if (mlnAmountToBurn == 0) {
            return;
        }

        __burn(getProtocolFeeReserve(), _sharesAmount);

        if (getMlnBurner() == address(0)) {
            ERC20Burnable(getMlnToken()).burn(mlnAmountToBurn);
        } else {
            ERC20(getMlnToken()).safeTransfer(getMlnBurner(), mlnAmountToBurn);
        }

        emit ProtocolFeeSharesBoughtBack(_sharesAmount, _mlnValue, mlnAmountToBurn);
    }

    function callOnContract(address _contract, bytes calldata _callData)
        external
        override
        onlyAccessor
        returns (bytes memory returnData_)
    {
        bool success;
        (success, returnData_) = _contract.call(_callData);
        require(success, string(returnData_));

        return returnData_;
    }

    function mintShares(address _target, uint256 _amount) external override onlyAccessor {
        __mint(_target, _amount);
    }

    function payProtocolFee() external override onlyAccessor {
        uint256 sharesDue = IProtocolFeeTracker(getProtocolFeeTracker()).payFee();

        if (sharesDue == 0) {
            return;
        }

        __mint(getProtocolFeeReserve(), sharesDue);

        emit ProtocolFeePaidInShares(sharesDue);
    }

    function transferShares(
        address _from,
        address _to,
        uint256 _amount
    ) external override onlyAccessor {
        __transfer(_from, _to, _amount);
    }

    function withdrawAssetTo(
        address _asset,
        address _target,
        uint256 _amount
    ) external override onlyAccessor {
        __withdrawAssetTo(_asset, _target, _amount);
    }


    function receiveValidatedVaultAction(VaultAction _action, bytes calldata _actionData)
        external
        override
        onlyAccessor
    {
        if (_action == VaultAction.AddExternalPosition) {
            __executeVaultActionAddExternalPosition(_actionData);
        } else if (_action == VaultAction.AddTrackedAsset) {
            __executeVaultActionAddTrackedAsset(_actionData);
        } else if (_action == VaultAction.ApproveAssetSpender) {
            __executeVaultActionApproveAssetSpender(_actionData);
        } else if (_action == VaultAction.BurnShares) {
            __executeVaultActionBurnShares(_actionData);
        } else if (_action == VaultAction.CallOnExternalPosition) {
            __executeVaultActionCallOnExternalPosition(_actionData);
        } else if (_action == VaultAction.MintShares) {
            __executeVaultActionMintShares(_actionData);
        } else if (_action == VaultAction.RemoveExternalPosition) {
            __executeVaultActionRemoveExternalPosition(_actionData);
        } else if (_action == VaultAction.RemoveTrackedAsset) {
            __executeVaultActionRemoveTrackedAsset(_actionData);
        } else if (_action == VaultAction.TransferShares) {
            __executeVaultActionTransferShares(_actionData);
        } else if (_action == VaultAction.WithdrawAssetTo) {
            __executeVaultActionWithdrawAssetTo(_actionData);
        }
    }

    function __executeVaultActionAddExternalPosition(bytes memory _actionData) private {
        __addExternalPosition(abi.decode(_actionData, (address)));
    }

    function __executeVaultActionAddTrackedAsset(bytes memory _actionData) private {
        __addTrackedAsset(abi.decode(_actionData, (address)));
    }

    function __executeVaultActionApproveAssetSpender(bytes memory _actionData) private {
        (address asset, address target, uint256 amount) = abi.decode(
            _actionData,
            (address, address, uint256)
        );

        __approveAssetSpender(asset, target, amount);
    }

    function __executeVaultActionBurnShares(bytes memory _actionData) private {
        (address target, uint256 amount) = abi.decode(_actionData, (address, uint256));

        __burn(target, amount);
    }

    function __executeVaultActionCallOnExternalPosition(bytes memory _actionData) private {
        (
            address externalPosition,
            bytes memory callOnExternalPositionActionData,
            address[] memory assetsToTransfer,
            uint256[] memory amountsToTransfer,
            address[] memory assetsToReceive
        ) = abi.decode(_actionData, (address, bytes, address[], uint256[], address[]));

        __callOnExternalPosition(
            externalPosition,
            callOnExternalPositionActionData,
            assetsToTransfer,
            amountsToTransfer,
            assetsToReceive
        );
    }

    function __executeVaultActionMintShares(bytes memory _actionData) private {
        (address target, uint256 amount) = abi.decode(_actionData, (address, uint256));

        __mint(target, amount);
    }

    function __executeVaultActionRemoveExternalPosition(bytes memory _actionData) private {
        __removeExternalPosition(abi.decode(_actionData, (address)));
    }

    function __executeVaultActionRemoveTrackedAsset(bytes memory _actionData) private {
        __removeTrackedAsset(abi.decode(_actionData, (address)));
    }

    function __executeVaultActionTransferShares(bytes memory _actionData) private {
        (address from, address to, uint256 amount) = abi.decode(
            _actionData,
            (address, address, uint256)
        );

        __transfer(from, to, amount);
    }

    function __executeVaultActionWithdrawAssetTo(bytes memory _actionData) private {
        (address asset, address target, uint256 amount) = abi.decode(
            _actionData,
            (address, address, uint256)
        );

        __withdrawAssetTo(asset, target, amount);
    }


    function __addExternalPosition(address _externalPosition) private {
        if (!isActiveExternalPosition(_externalPosition)) {
            __validatePositionsLimit();

            externalPositionToIsActive[_externalPosition] = true;
            activeExternalPositions.push(_externalPosition);

            emit ExternalPositionAdded(_externalPosition);
        }
    }

    function __addTrackedAsset(address _asset) private notShares(_asset) {
        if (!isTrackedAsset(_asset)) {
            __validatePositionsLimit();

            assetToIsTracked[_asset] = true;
            trackedAssets.push(_asset);

            emit TrackedAssetAdded(_asset);
        }
    }

    function __approveAssetSpender(
        address _asset,
        address _target,
        uint256 _amount
    ) private notShares(_asset) {
        ERC20 assetContract = ERC20(_asset);
        if (assetContract.allowance(address(this), _target) > 0) {
            assetContract.safeApprove(_target, 0);
        }
        assetContract.safeApprove(_target, _amount);
    }

    function __callOnExternalPosition(
        address _externalPosition,
        bytes memory _actionData,
        address[] memory _assetsToTransfer,
        uint256[] memory _amountsToTransfer,
        address[] memory _assetsToReceive
    ) private {
        require(
            isActiveExternalPosition(_externalPosition),
            "__callOnExternalPosition: Not an active external position"
        );

        for (uint256 i; i < _assetsToTransfer.length; i++) {
            __withdrawAssetTo(_assetsToTransfer[i], _externalPosition, _amountsToTransfer[i]);
        }

        IExternalPosition(_externalPosition).receiveCallFromVault(_actionData);

        for (uint256 i; i < _assetsToReceive.length; i++) {
            __addTrackedAsset(_assetsToReceive[i]);
        }
    }

    function __getAssetBalance(address _asset) private view returns (uint256 balance_) {
        return ERC20(_asset).balanceOf(address(this));
    }

    function __removeExternalPosition(address _externalPosition) private {
        if (isActiveExternalPosition(_externalPosition)) {
            externalPositionToIsActive[_externalPosition] = false;

            activeExternalPositions.removeStorageItem(_externalPosition);

            emit ExternalPositionRemoved(_externalPosition);
        }
    }

    function __removeTrackedAsset(address _asset) private {
        if (isTrackedAsset(_asset)) {
            assetToIsTracked[_asset] = false;

            trackedAssets.removeStorageItem(_asset);

            emit TrackedAssetRemoved(_asset);
        }
    }

    function __validatePositionsLimit() private view {
        require(
            trackedAssets.length + activeExternalPositions.length < getPositionsLimit(),
            "__validatePositionsLimit: Limit exceeded"
        );
    }

    function __withdrawAssetTo(
        address _asset,
        address _target,
        uint256 _amount
    ) private notShares(_asset) {
        ERC20(_asset).safeTransfer(_target, _amount);

        emit AssetWithdrawn(_asset, _target, _amount);
    }


    function symbol() public view override returns (string memory symbol_) {
        symbol_ = sharesSymbol;
        if (bytes(symbol_).length == 0) {
            symbol_ = IDispatcher(creator).getSharesTokenSymbol();
        }

        return symbol_;
    }

    function transfer(address _recipient, uint256 _amount)
        public
        override
        returns (bool success_)
    {
        __invokePreTransferSharesHook(msg.sender, _recipient, _amount);

        return super.transfer(_recipient, _amount);
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) public override returns (bool success_) {
        __invokePreTransferSharesHook(_sender, _recipient, _amount);

        return super.transferFrom(_sender, _recipient, _amount);
    }

    function __invokePreTransferSharesHook(
        address _sender,
        address _recipient,
        uint256 _amount
    ) private {
        if (sharesAreFreelyTransferable()) {
            IComptroller(accessor).preTransferSharesHookFreelyTransferable(_sender);
        } else {
            IComptroller(accessor).preTransferSharesHook(_sender, _recipient, _amount);
        }
    }


    function canManageAssets(address _who) external view override returns (bool canManageAssets_) {
        return _who == getOwner() || isAssetManager(_who);
    }

    function canRelayCalls(address _who) external view override returns (bool canRelayCalls_) {
        return _who == getOwner() || isAssetManager(_who) || _who == getMigrator();
    }

    function getAccessor() public view override returns (address accessor_) {
        return accessor;
    }

    function getCreator() external view returns (address creator_) {
        return creator;
    }

    function getMigrator() public view returns (address migrator_) {
        return migrator;
    }

    function getNominatedOwner() external view returns (address nominatedOwner_) {
        return nominatedOwner;
    }

    function getActiveExternalPositions()
        external
        view
        override
        returns (address[] memory activeExternalPositions_)
    {
        return activeExternalPositions;
    }

    function getTrackedAssets() external view override returns (address[] memory trackedAssets_) {
        return trackedAssets;
    }


    function getExternalPositionManager() public view returns (address externalPositionManager_) {
        return EXTERNAL_POSITION_MANAGER;
    }

    function getFundDeployer() public view returns (address fundDeployer_) {
        return IDispatcher(creator).getFundDeployerForVaultProxy(address(this));
    }

    function getMlnBurner() public view returns (address mlnBurner_) {
        return MLN_BURNER;
    }

    function getMlnToken() public view returns (address mlnToken_) {
        return MLN_TOKEN;
    }

    function getOwner() public view override returns (address owner_) {
        return owner;
    }

    function getPositionsLimit() public view returns (uint256 positionsLimit_) {
        return POSITIONS_LIMIT;
    }

    function getProtocolFeeReserve() public view returns (address protocolFeeReserve_) {
        return PROTOCOL_FEE_RESERVE;
    }

    function getProtocolFeeTracker() public view returns (address protocolFeeTracker_) {
        return PROTOCOL_FEE_TRACKER;
    }

    function isActiveExternalPosition(address _externalPosition)
        public
        view
        override
        returns (bool isActiveExternalPosition_)
    {
        return externalPositionToIsActive[_externalPosition];
    }

    function isAssetManager(address _who) public view returns (bool isAssetManager_) {
        return accountToIsAssetManager[_who];
    }

    function isTrackedAsset(address _asset) public view override returns (bool isTrackedAsset_) {
        return assetToIsTracked[_asset];
    }

    function sharesAreFreelyTransferable()
        public
        view
        override
        returns (bool sharesAreFreelyTransferable_)
    {
        return freelyTransferableShares;
    }

    function getWethToken() public view returns (address wethToken_) {
        return WETH_TOKEN;
    }
}// GPL-3.0


pragma solidity 0.6.12;


interface IPolicy {
    function activateForFund(address _comptrollerProxy) external;

    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings) external;

    function canDisable() external pure returns (bool canDisable_);

    function identifier() external pure returns (string memory identifier_);

    function implementedHooks()
        external
        pure
        returns (IPolicyManager.PolicyHook[] memory implementedHooks_);

    function updateFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external;

    function validateRule(
        address _comptrollerProxy,
        IPolicyManager.PolicyHook _hook,
        bytes calldata _encodedArgs
    ) external returns (bool isValid_);
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract FundDeployerOwnerMixin {
    address internal immutable FUND_DEPLOYER;

    modifier onlyFundDeployerOwner() {
        require(
            msg.sender == getOwner(),
            "onlyFundDeployerOwner: Only the FundDeployer owner can call this function"
        );
        _;
    }

    constructor(address _fundDeployer) public {
        FUND_DEPLOYER = _fundDeployer;
    }

    function getOwner() public view returns (address owner_) {
        return IFundDeployer(FUND_DEPLOYER).getOwner();
    }


    function getFundDeployer() public view returns (address fundDeployer_) {
        return FUND_DEPLOYER;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract MathHelpers {
    using SafeMath for uint256;

    function __calcRelativeQuantity(
        uint256 _quantity1,
        uint256 _quantity2,
        uint256 _relativeQuantity1
    ) internal pure returns (uint256 relativeQuantity2_) {
        return _relativeQuantity1.mul(_quantity2).div(_quantity1);
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IDerivativePriceFeed {
    function calcUnderlyingValues(address, uint256)
        external
        returns (address[] memory, uint256[] memory);

    function isSupportedAsset(address) external view returns (bool);
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract AggregatedDerivativePriceFeedMixin {
    event DerivativeAdded(address indexed derivative, address priceFeed);

    event DerivativeRemoved(address indexed derivative);

    mapping(address => address) private derivativeToPriceFeed;

    function __calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        internal
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        address derivativePriceFeed = getPriceFeedForDerivative(_derivative);
        require(
            derivativePriceFeed != address(0),
            "calcUnderlyingValues: _derivative is not supported"
        );

        return
            IDerivativePriceFeed(derivativePriceFeed).calcUnderlyingValues(
                _derivative,
                _derivativeAmount
            );
    }


    function __addDerivatives(address[] memory _derivatives, address[] memory _priceFeeds)
        internal
    {
        require(
            _derivatives.length == _priceFeeds.length,
            "__addDerivatives: Unequal _derivatives and _priceFeeds array lengths"
        );

        for (uint256 i = 0; i < _derivatives.length; i++) {
            require(
                getPriceFeedForDerivative(_derivatives[i]) == address(0),
                "__addDerivatives: Already added"
            );

            __validateDerivativePriceFeed(_derivatives[i], _priceFeeds[i]);

            derivativeToPriceFeed[_derivatives[i]] = _priceFeeds[i];

            emit DerivativeAdded(_derivatives[i], _priceFeeds[i]);
        }
    }

    function __removeDerivatives(address[] memory _derivatives) internal {
        for (uint256 i = 0; i < _derivatives.length; i++) {
            require(
                getPriceFeedForDerivative(_derivatives[i]) != address(0),
                "removeDerivatives: Derivative not yet added"
            );

            delete derivativeToPriceFeed[_derivatives[i]];

            emit DerivativeRemoved(_derivatives[i]);
        }
    }


    function __validateDerivativePriceFeed(address _derivative, address _priceFeed) private view {
        require(
            IDerivativePriceFeed(_priceFeed).isSupportedAsset(_derivative),
            "__validateDerivativePriceFeed: Unsupported derivative"
        );
    }


    function getPriceFeedForDerivative(address _derivative)
        public
        view
        returns (address priceFeed_)
    {
        return derivativeToPriceFeed[_derivative];
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IChainlinkAggregator {
    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        );
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract ChainlinkPriceFeedMixin {
    using SafeMath for uint256;

    event EthUsdAggregatorSet(address prevEthUsdAggregator, address nextEthUsdAggregator);

    event PrimitiveAdded(
        address indexed primitive,
        address aggregator,
        RateAsset rateAsset,
        uint256 unit
    );

    event PrimitiveRemoved(address indexed primitive);

    enum RateAsset {ETH, USD}

    struct AggregatorInfo {
        address aggregator;
        RateAsset rateAsset;
    }

    uint256 private constant ETH_UNIT = 10**18;

    uint256 private immutable STALE_RATE_THRESHOLD;
    address private immutable WETH_TOKEN;

    address private ethUsdAggregator;
    mapping(address => AggregatorInfo) private primitiveToAggregatorInfo;
    mapping(address => uint256) private primitiveToUnit;

    constructor(address _wethToken, uint256 _staleRateThreshold) public {
        STALE_RATE_THRESHOLD = _staleRateThreshold;
        WETH_TOKEN = _wethToken;
    }


    function __calcCanonicalValue(
        address _baseAsset,
        uint256 _baseAssetAmount,
        address _quoteAsset
    ) internal view returns (uint256 quoteAssetAmount_) {

        int256 baseAssetRate = __getLatestRateData(_baseAsset);
        require(baseAssetRate > 0, "__calcCanonicalValue: Invalid base asset rate");

        int256 quoteAssetRate = __getLatestRateData(_quoteAsset);
        require(quoteAssetRate > 0, "__calcCanonicalValue: Invalid quote asset rate");

        return
            __calcConversionAmount(
                _baseAsset,
                _baseAssetAmount,
                uint256(baseAssetRate),
                _quoteAsset,
                uint256(quoteAssetRate)
            );
    }

    function __setEthUsdAggregator(address _nextEthUsdAggregator) internal {
        address prevEthUsdAggregator = getEthUsdAggregator();
        require(
            _nextEthUsdAggregator != prevEthUsdAggregator,
            "__setEthUsdAggregator: Value already set"
        );

        __validateAggregator(_nextEthUsdAggregator);

        ethUsdAggregator = _nextEthUsdAggregator;

        emit EthUsdAggregatorSet(prevEthUsdAggregator, _nextEthUsdAggregator);
    }


    function __calcConversionAmount(
        address _baseAsset,
        uint256 _baseAssetAmount,
        uint256 _baseAssetRate,
        address _quoteAsset,
        uint256 _quoteAssetRate
    ) private view returns (uint256 quoteAssetAmount_) {
        RateAsset baseAssetRateAsset = getRateAssetForPrimitive(_baseAsset);
        RateAsset quoteAssetRateAsset = getRateAssetForPrimitive(_quoteAsset);
        uint256 baseAssetUnit = getUnitForPrimitive(_baseAsset);
        uint256 quoteAssetUnit = getUnitForPrimitive(_quoteAsset);

        if (baseAssetRateAsset == quoteAssetRateAsset) {
            return
                __calcConversionAmountSameRateAsset(
                    _baseAssetAmount,
                    baseAssetUnit,
                    _baseAssetRate,
                    quoteAssetUnit,
                    _quoteAssetRate
                );
        }

        (, int256 ethPerUsdRate, , uint256 ethPerUsdRateLastUpdatedAt, ) = IChainlinkAggregator(
            getEthUsdAggregator()
        )
            .latestRoundData();
        require(ethPerUsdRate > 0, "__calcConversionAmount: Bad ethUsd rate");
        __validateRateIsNotStale(ethPerUsdRateLastUpdatedAt);

        if (baseAssetRateAsset == RateAsset.ETH) {
            return
                __calcConversionAmountEthRateAssetToUsdRateAsset(
                    _baseAssetAmount,
                    baseAssetUnit,
                    _baseAssetRate,
                    quoteAssetUnit,
                    _quoteAssetRate,
                    uint256(ethPerUsdRate)
                );
        }

        return
            __calcConversionAmountUsdRateAssetToEthRateAsset(
                _baseAssetAmount,
                baseAssetUnit,
                _baseAssetRate,
                quoteAssetUnit,
                _quoteAssetRate,
                uint256(ethPerUsdRate)
            );
    }

    function __calcConversionAmountEthRateAssetToUsdRateAsset(
        uint256 _baseAssetAmount,
        uint256 _baseAssetUnit,
        uint256 _baseAssetRate,
        uint256 _quoteAssetUnit,
        uint256 _quoteAssetRate,
        uint256 _ethPerUsdRate
    ) private pure returns (uint256 quoteAssetAmount_) {
        uint256 intermediateStep = _baseAssetAmount.mul(_baseAssetRate).mul(_ethPerUsdRate).div(
            ETH_UNIT
        );

        return intermediateStep.mul(_quoteAssetUnit).div(_baseAssetUnit).div(_quoteAssetRate);
    }

    function __calcConversionAmountSameRateAsset(
        uint256 _baseAssetAmount,
        uint256 _baseAssetUnit,
        uint256 _baseAssetRate,
        uint256 _quoteAssetUnit,
        uint256 _quoteAssetRate
    ) private pure returns (uint256 quoteAssetAmount_) {
        return
            _baseAssetAmount.mul(_baseAssetRate).mul(_quoteAssetUnit).div(
                _baseAssetUnit.mul(_quoteAssetRate)
            );
    }

    function __calcConversionAmountUsdRateAssetToEthRateAsset(
        uint256 _baseAssetAmount,
        uint256 _baseAssetUnit,
        uint256 _baseAssetRate,
        uint256 _quoteAssetUnit,
        uint256 _quoteAssetRate,
        uint256 _ethPerUsdRate
    ) private pure returns (uint256 quoteAssetAmount_) {
        uint256 intermediateStep = _baseAssetAmount.mul(_baseAssetRate).mul(_quoteAssetUnit).div(
            _ethPerUsdRate
        );

        return intermediateStep.mul(ETH_UNIT).div(_baseAssetUnit).div(_quoteAssetRate);
    }

    function __getLatestRateData(address _primitive) private view returns (int256 rate_) {
        if (_primitive == getWethToken()) {
            return int256(ETH_UNIT);
        }

        address aggregator = getAggregatorForPrimitive(_primitive);
        require(aggregator != address(0), "__getLatestRateData: Primitive does not exist");

        uint256 rateUpdatedAt;
        (, rate_, , rateUpdatedAt, ) = IChainlinkAggregator(aggregator).latestRoundData();
        __validateRateIsNotStale(rateUpdatedAt);

        return rate_;
    }

    function __validateRateIsNotStale(uint256 _latestUpdatedAt) private view {
        require(
            _latestUpdatedAt >= block.timestamp.sub(getStaleRateThreshold()),
            "__validateRateIsNotStale: Stale rate detected"
        );
    }


    function __addPrimitives(
        address[] calldata _primitives,
        address[] calldata _aggregators,
        RateAsset[] calldata _rateAssets
    ) internal {
        require(
            _primitives.length == _aggregators.length,
            "__addPrimitives: Unequal _primitives and _aggregators array lengths"
        );
        require(
            _primitives.length == _rateAssets.length,
            "__addPrimitives: Unequal _primitives and _rateAssets array lengths"
        );

        for (uint256 i; i < _primitives.length; i++) {
            require(
                getAggregatorForPrimitive(_primitives[i]) == address(0),
                "__addPrimitives: Value already set"
            );

            __validateAggregator(_aggregators[i]);

            primitiveToAggregatorInfo[_primitives[i]] = AggregatorInfo({
                aggregator: _aggregators[i],
                rateAsset: _rateAssets[i]
            });

            uint256 unit = 10**uint256(ERC20(_primitives[i]).decimals());
            primitiveToUnit[_primitives[i]] = unit;

            emit PrimitiveAdded(_primitives[i], _aggregators[i], _rateAssets[i], unit);
        }
    }

    function __removePrimitives(address[] calldata _primitives) internal {
        for (uint256 i; i < _primitives.length; i++) {
            require(
                getAggregatorForPrimitive(_primitives[i]) != address(0),
                "__removePrimitives: Primitive not yet added"
            );

            delete primitiveToAggregatorInfo[_primitives[i]];
            delete primitiveToUnit[_primitives[i]];

            emit PrimitiveRemoved(_primitives[i]);
        }
    }


    function __validateAggregator(address _aggregator) private view {
        (, int256 answer, , uint256 updatedAt, ) = IChainlinkAggregator(_aggregator)
            .latestRoundData();
        require(answer > 0, "__validateAggregator: No rate detected");
        __validateRateIsNotStale(updatedAt);
    }


    function getAggregatorForPrimitive(address _primitive)
        public
        view
        returns (address aggregator_)
    {
        return primitiveToAggregatorInfo[_primitive].aggregator;
    }

    function getEthUsdAggregator() public view returns (address ethUsdAggregator_) {
        return ethUsdAggregator;
    }

    function getRateAssetForPrimitive(address _primitive)
        public
        view
        returns (RateAsset rateAsset_)
    {
        if (_primitive == getWethToken()) {
            return RateAsset.ETH;
        }

        return primitiveToAggregatorInfo[_primitive].rateAsset;
    }

    function getStaleRateThreshold() public view returns (uint256 staleRateThreshold_) {
        return STALE_RATE_THRESHOLD;
    }

    function getUnitForPrimitive(address _primitive) public view returns (uint256 unit_) {
        if (_primitive == getWethToken()) {
            return ETH_UNIT;
        }

        return primitiveToUnit[_primitive];
    }

    function getWethToken() public view returns (address wethToken_) {
        return WETH_TOKEN;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract ValueInterpreter is
    IValueInterpreter,
    FundDeployerOwnerMixin,
    AggregatedDerivativePriceFeedMixin,
    ChainlinkPriceFeedMixin,
    MathHelpers
{
    using SafeMath for uint256;

    uint256 private constant MIN_INVERSE_RATE_AMOUNT = 10000;

    constructor(
        address _fundDeployer,
        address _wethToken,
        uint256 _chainlinkStaleRateThreshold
    )
        public
        FundDeployerOwnerMixin(_fundDeployer)
        ChainlinkPriceFeedMixin(_wethToken, _chainlinkStaleRateThreshold)
    {}


    function calcCanonicalAssetsTotalValue(
        address[] memory _baseAssets,
        uint256[] memory _amounts,
        address _quoteAsset
    ) external override returns (uint256 value_) {
        require(
            _baseAssets.length == _amounts.length,
            "calcCanonicalAssetsTotalValue: Arrays unequal lengths"
        );
        require(
            isSupportedPrimitiveAsset(_quoteAsset),
            "calcCanonicalAssetsTotalValue: Unsupported _quoteAsset"
        );

        for (uint256 i; i < _baseAssets.length; i++) {
            uint256 assetValue = __calcAssetValue(_baseAssets[i], _amounts[i], _quoteAsset);
            value_ = value_.add(assetValue);
        }

        return value_;
    }


    function calcCanonicalAssetValue(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) external override returns (uint256 value_) {
        if (_baseAsset == _quoteAsset || _amount == 0) {
            return _amount;
        }

        if (isSupportedPrimitiveAsset(_quoteAsset)) {
            return __calcAssetValue(_baseAsset, _amount, _quoteAsset);
        } else if (
            isSupportedDerivativeAsset(_quoteAsset) && isSupportedPrimitiveAsset(_baseAsset)
        ) {
            return __calcPrimitiveToDerivativeValue(_baseAsset, _amount, _quoteAsset);
        }

        revert("calcCanonicalAssetValue: Unsupported conversion");
    }

    function isSupportedAsset(address _asset) public view override returns (bool isSupported_) {
        return isSupportedPrimitiveAsset(_asset) || isSupportedDerivativeAsset(_asset);
    }


    function __calcAssetValue(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) private returns (uint256 value_) {
        if (_baseAsset == _quoteAsset || _amount == 0) {
            return _amount;
        }

        if (isSupportedPrimitiveAsset(_baseAsset)) {
            return __calcCanonicalValue(_baseAsset, _amount, _quoteAsset);
        }

        address derivativePriceFeed = getPriceFeedForDerivative(_baseAsset);
        if (derivativePriceFeed != address(0)) {
            return __calcDerivativeValue(derivativePriceFeed, _baseAsset, _amount, _quoteAsset);
        }

        revert("__calcAssetValue: Unsupported _baseAsset");
    }

    function __calcDerivativeValue(
        address _derivativePriceFeed,
        address _derivative,
        uint256 _amount,
        address _quoteAsset
    ) private returns (uint256 value_) {
        (address[] memory underlyings, uint256[] memory underlyingAmounts) = IDerivativePriceFeed(
            _derivativePriceFeed
        )
            .calcUnderlyingValues(_derivative, _amount);

        require(underlyings.length > 0, "__calcDerivativeValue: No underlyings");
        require(
            underlyings.length == underlyingAmounts.length,
            "__calcDerivativeValue: Arrays unequal lengths"
        );

        for (uint256 i = 0; i < underlyings.length; i++) {
            uint256 underlyingValue = __calcAssetValue(
                underlyings[i],
                underlyingAmounts[i],
                _quoteAsset
            );

            value_ = value_.add(underlyingValue);
        }
    }

    function __calcPrimitiveToDerivativeValue(
        address _primitiveBaseAsset,
        uint256 _primitiveBaseAssetAmount,
        address _derivativeQuoteAsset
    ) private returns (uint256 value_) {
        uint256 derivativeUnit = 10**uint256(ERC20(_derivativeQuoteAsset).decimals());

        address derivativePriceFeed = getPriceFeedForDerivative(_derivativeQuoteAsset);
        uint256 primitiveAmountForDerivativeUnit = __calcDerivativeValue(
            derivativePriceFeed,
            _derivativeQuoteAsset,
            derivativeUnit,
            _primitiveBaseAsset
        );
        require(
            primitiveAmountForDerivativeUnit > MIN_INVERSE_RATE_AMOUNT,
            "__calcPrimitiveToDerivativeValue: Insufficient rate"
        );

        return
            __calcRelativeQuantity(
                primitiveAmountForDerivativeUnit.add(1),
                derivativeUnit,
                _primitiveBaseAssetAmount
            );
    }


    function addPrimitives(
        address[] calldata _primitives,
        address[] calldata _aggregators,
        RateAsset[] calldata _rateAssets
    ) external onlyFundDeployerOwner {
        __addPrimitives(_primitives, _aggregators, _rateAssets);
    }

    function removePrimitives(address[] calldata _primitives) external onlyFundDeployerOwner {
        __removePrimitives(_primitives);
    }

    function setEthUsdAggregator(address _nextEthUsdAggregator) external onlyFundDeployerOwner {
        __setEthUsdAggregator(_nextEthUsdAggregator);
    }

    function updatePrimitives(
        address[] calldata _primitives,
        address[] calldata _aggregators,
        RateAsset[] calldata _rateAssets
    ) external onlyFundDeployerOwner {
        __removePrimitives(_primitives);
        __addPrimitives(_primitives, _aggregators, _rateAssets);
    }


    function isSupportedPrimitiveAsset(address _asset)
        public
        view
        override
        returns (bool isSupported_)
    {
        return _asset == getWethToken() || getAggregatorForPrimitive(_asset) != address(0);
    }


    function addDerivatives(address[] calldata _derivatives, address[] calldata _priceFeeds)
        external
        onlyFundDeployerOwner
    {
        __addDerivatives(_derivatives, _priceFeeds);
    }

    function removeDerivatives(address[] calldata _derivatives) external onlyFundDeployerOwner {
        __removeDerivatives(_derivatives);
    }

    function updateDerivatives(address[] calldata _derivatives, address[] calldata _priceFeeds)
        external
        onlyFundDeployerOwner
    {
        __removeDerivatives(_derivatives);
        __addDerivatives(_derivatives, _priceFeeds);
    }


    function isSupportedDerivativeAsset(address _asset)
        public
        view
        override
        returns (bool isSupported_)
    {
        return getPriceFeedForDerivative(_asset) != address(0);
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract PolicyBase is IPolicy {
    address internal immutable POLICY_MANAGER;

    modifier onlyPolicyManager {
        require(msg.sender == POLICY_MANAGER, "Only the PolicyManager can make this call");
        _;
    }

    constructor(address _policyManager) public {
        POLICY_MANAGER = _policyManager;
    }

    function activateForFund(address) external virtual override {
        return;
    }

    function canDisable() external pure virtual override returns (bool canDisable_) {
        return false;
    }

    function updateFundSettings(address, bytes calldata) external virtual override {
        revert("updateFundSettings: Updates not allowed for this policy");
    }


    function __decodeAddTrackedAssetsValidationData(bytes memory _validationData)
        internal
        pure
        returns (address caller_, address[] memory assets_)
    {
        return abi.decode(_validationData, (address, address[]));
    }

    function __decodeCreateExternalPositionValidationData(bytes memory _validationData)
        internal
        pure
        returns (
            address caller_,
            uint256 typeId_,
            bytes memory initializationData_
        )
    {
        return abi.decode(_validationData, (address, uint256, bytes));
    }

    function __decodePreTransferSharesValidationData(bytes memory _validationData)
        internal
        pure
        returns (
            address sender_,
            address recipient_,
            uint256 amount_
        )
    {
        return abi.decode(_validationData, (address, address, uint256));
    }

    function __decodePostBuySharesValidationData(bytes memory _validationData)
        internal
        pure
        returns (
            address buyer_,
            uint256 investmentAmount_,
            uint256 sharesIssued_,
            uint256 gav_
        )
    {
        return abi.decode(_validationData, (address, uint256, uint256, uint256));
    }

    function __decodePostCallOnExternalPositionValidationData(bytes memory _validationData)
        internal
        pure
        returns (
            address caller_,
            address externalPosition_,
            address[] memory assetsToTransfer_,
            uint256[] memory amountsToTransfer_,
            address[] memory assetsToReceive_,
            bytes memory encodedActionData_
        )
    {
        return
            abi.decode(
                _validationData,
                (address, address, address[], uint256[], address[], bytes)
            );
    }

    function __decodePostCallOnIntegrationValidationData(bytes memory _validationData)
        internal
        pure
        returns (
            address caller_,
            address adapter_,
            bytes4 selector_,
            address[] memory incomingAssets_,
            uint256[] memory incomingAssetAmounts_,
            address[] memory spendAssets_,
            uint256[] memory spendAssetAmounts_
        )
    {
        return
            abi.decode(
                _validationData,
                (address, address, bytes4, address[], uint256[], address[], uint256[])
            );
    }

    function __decodeReactivateExternalPositionValidationData(bytes memory _validationData)
        internal
        pure
        returns (address caller_, address externalPosition_)
    {
        return abi.decode(_validationData, (address, address));
    }

    function __decodeRedeemSharesForSpecificAssetsValidationData(bytes memory _validationData)
        internal
        pure
        returns (
            address redeemer_,
            address recipient_,
            uint256 sharesToRedeemPostFees_,
            address[] memory assets_,
            uint256[] memory assetAmounts_,
            uint256 gavPreRedeem_
        )
    {
        return
            abi.decode(
                _validationData,
                (address, address, uint256, address[], uint256[], uint256)
            );
    }

    function __decodeRemoveExternalPositionValidationData(bytes memory _validationData)
        internal
        pure
        returns (address caller_, address externalPosition_)
    {
        return abi.decode(_validationData, (address, address));
    }

    function __decodeRemoveTrackedAssetsValidationData(bytes memory _validationData)
        internal
        pure
        returns (address caller_, address[] memory assets_)
    {
        return abi.decode(_validationData, (address, address[]));
    }


    function getPolicyManager() external view returns (address policyManager_) {
        return POLICY_MANAGER;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract PricelessAssetBypassMixin {
    using SafeMath for uint256;

    event PricelessAssetBypassed(address indexed comptrollerProxy, address indexed asset);

    event PricelessAssetTimelockStarted(address indexed comptrollerProxy, address indexed asset);

    uint256 private immutable PRICELESS_ASSET_BYPASS_TIMELOCK;
    uint256 private immutable PRICELESS_ASSET_BYPASS_TIME_LIMIT;
    address private immutable PRICELESS_ASSET_BYPASS_VALUE_INTERPRETER;
    address private immutable PRICELESS_ASSET_BYPASS_WETH_TOKEN;

    mapping(address => mapping(address => uint256))
        private comptrollerProxyToAssetToBypassWindowStart;

    constructor(
        address _valueInterpreter,
        address _wethToken,
        uint256 _timelock,
        uint256 _timeLimit
    ) public {
        PRICELESS_ASSET_BYPASS_TIMELOCK = _timelock;
        PRICELESS_ASSET_BYPASS_TIME_LIMIT = _timeLimit;
        PRICELESS_ASSET_BYPASS_VALUE_INTERPRETER = _valueInterpreter;
        PRICELESS_ASSET_BYPASS_WETH_TOKEN = _wethToken;
    }


    function startAssetBypassTimelock(address _asset) external {
        address comptrollerProxy = VaultLib(msg.sender).getAccessor();
        require(
            msg.sender == ComptrollerLib(comptrollerProxy).getVaultProxy(),
            "startAssetBypassTimelock: Sender is not the VaultProxy of the associated ComptrollerProxy"
        );

        try
            ValueInterpreter(getPricelessAssetBypassValueInterpreter()).calcCanonicalAssetValue(
                _asset,
                1, // Any value >0 will attempt to retrieve a rate
                getPricelessAssetBypassWethToken() // Any valid asset would do
            )
         {
            revert("startAssetBypassTimelock: Asset has a price");
        } catch {
            comptrollerProxyToAssetToBypassWindowStart[comptrollerProxy][_asset] = block
                .timestamp
                .add(getPricelessAssetBypassTimelock());

            emit PricelessAssetTimelockStarted(comptrollerProxy, _asset);
        }
    }


    function assetIsBypassableForFund(address _comptrollerProxy, address _asset)
        public
        view
        returns (bool isBypassable_)
    {
        uint256 windowStart = getAssetBypassWindowStartForFund(_comptrollerProxy, _asset);

        return
            windowStart <= block.timestamp &&
            windowStart.add(getPricelessAssetBypassTimeLimit()) >= block.timestamp;
    }


    function __calcTotalValueExlcudingBypassablePricelessAssets(
        address _comptrollerProxy,
        address[] memory _baseAssets,
        uint256[] memory _baseAssetAmounts,
        address _quoteAsset
    ) internal returns (uint256 value_) {
        for (uint256 i; i < _baseAssets.length; i++) {
            value_ = value_.add(
                __calcValueExcludingBypassablePricelessAsset(
                    _comptrollerProxy,
                    _baseAssets[i],
                    _baseAssetAmounts[i],
                    _quoteAsset
                )
            );
        }
    }

    function __calcValueExcludingBypassablePricelessAsset(
        address _comptrollerProxy,
        address _baseAsset,
        uint256 _baseAssetAmount,
        address _quoteAsset
    ) internal returns (uint256 value_) {
        try
            ValueInterpreter(getPricelessAssetBypassValueInterpreter()).calcCanonicalAssetValue(
                _baseAsset,
                _baseAssetAmount,
                _quoteAsset
            )
        returns (uint256 result) {
            return result;
        } catch {
            require(
                assetIsBypassableForFund(_comptrollerProxy, _baseAsset),
                "__calcValueExcludingBypassablePricelessAsset: Invalid asset not bypassable"
            );

            emit PricelessAssetBypassed(_comptrollerProxy, _baseAsset);
        }

        return 0;
    }


    function getAssetBypassWindowStartForFund(address _comptrollerProxy, address _asset)
        public
        view
        returns (uint256 windowStart_)
    {
        return comptrollerProxyToAssetToBypassWindowStart[_comptrollerProxy][_asset];
    }

    function getPricelessAssetBypassTimeLimit() public view returns (uint256 timeLimit_) {
        return PRICELESS_ASSET_BYPASS_TIME_LIMIT;
    }

    function getPricelessAssetBypassTimelock() public view returns (uint256 timelock_) {
        return PRICELESS_ASSET_BYPASS_TIMELOCK;
    }

    function getPricelessAssetBypassValueInterpreter()
        public
        view
        returns (address valueInterpreter_)
    {
        return PRICELESS_ASSET_BYPASS_VALUE_INTERPRETER;
    }

    function getPricelessAssetBypassWethToken() public view returns (address wethToken_) {
        return PRICELESS_ASSET_BYPASS_WETH_TOKEN;
    }
}// GPL-3.0


pragma solidity 0.6.12;


contract CumulativeSlippageTolerancePolicy is PolicyBase, PricelessAssetBypassMixin {
    using SafeMath for uint256;

    event CumulativeSlippageUpdatedForFund(
        address indexed comptrollerProxy,
        uint256 nextCumulativeSlippage
    );

    event FundSettingsSet(address indexed comptrollerProxy, uint256 tolerance);

    struct PolicyInfo {
        uint64 tolerance;
        uint64 cumulativeSlippage;
        uint128 lastSlippageTimestamp;
    }

    uint256 private constant ONE_HUNDRED_PERCENT = 1 ether; // 10 ** 18

    address private immutable ADDRESS_LIST_REGISTRY;
    uint256 private immutable BYPASSABLE_ADAPTERS_LIST_ID;
    uint256 private immutable TOLERANCE_PERIOD_DURATION;

    mapping(address => PolicyInfo) private comptrollerProxyToPolicyInfo;

    constructor(
        address _policyManager,
        address _addressListRegistry,
        address _valueInterpreter,
        address _wethToken,
        uint256 _bypassableAdaptersListId,
        uint256 _tolerancePeriodDuration,
        uint256 _pricelessAssetBypassTimelock,
        uint256 _pricelessAssetBypassTimeLimit
    )
        public
        PolicyBase(_policyManager)
        PricelessAssetBypassMixin(
            _valueInterpreter,
            _wethToken,
            _pricelessAssetBypassTimelock,
            _pricelessAssetBypassTimeLimit
        )
    {
        ADDRESS_LIST_REGISTRY = _addressListRegistry;
        BYPASSABLE_ADAPTERS_LIST_ID = _bypassableAdaptersListId;
        TOLERANCE_PERIOD_DURATION = _tolerancePeriodDuration;
    }


    function addFundSettings(address _comptrollerProxy, bytes calldata _encodedSettings)
        external
        override
        onlyPolicyManager
    {
        uint64 tolerance = abi.decode(_encodedSettings, (uint64));
        require(tolerance < ONE_HUNDRED_PERCENT, "addFundSettings: Max tolerance exceeded");

        comptrollerProxyToPolicyInfo[_comptrollerProxy] = PolicyInfo({
            tolerance: tolerance,
            cumulativeSlippage: 0,
            lastSlippageTimestamp: 0
        });

        emit FundSettingsSet(_comptrollerProxy, tolerance);
    }

    function identifier() external pure override returns (string memory identifier_) {
        return "CUMULATIVE_SLIPPAGE_TOLERANCE";
    }

    function implementedHooks()
        external
        pure
        override
        returns (IPolicyManager.PolicyHook[] memory implementedHooks_)
    {
        implementedHooks_ = new IPolicyManager.PolicyHook[](1);
        implementedHooks_[0] = IPolicyManager.PolicyHook.PostCallOnIntegration;

        return implementedHooks_;
    }

    function validateRule(
        address _comptrollerProxy,
        IPolicyManager.PolicyHook,
        bytes calldata _encodedArgs
    ) external override onlyPolicyManager returns (bool isValid_) {
        (
            ,
            address adapter,
            ,
            address[] memory incomingAssets,
            uint256[] memory incomingAssetAmounts,
            address[] memory spendAssets,
            uint256[] memory spendAssetAmounts
        ) = __decodePostCallOnIntegrationValidationData(_encodedArgs);

        if (__isBypassableAction(adapter)) {
            return true;
        }

        uint256 newSlippage = __calcSlippage(
            _comptrollerProxy,
            incomingAssets,
            incomingAssetAmounts,
            spendAssets,
            spendAssetAmounts
        );
        if (newSlippage == 0) {
            return true;
        }

        uint256 tolerance = comptrollerProxyToPolicyInfo[_comptrollerProxy].tolerance;

        return __updateCumulativeSlippage(_comptrollerProxy, newSlippage, tolerance) <= tolerance;
    }


    function __calcSlippage(
        address _comptrollerProxy,
        address[] memory _incomingAssets,
        uint256[] memory _incomingAssetAmounts,
        address[] memory _spendAssets,
        uint256[] memory _spendAssetAmounts
    ) private returns (uint256 slippage_) {
        uint256 outgoingValue = __calcTotalValueExlcudingBypassablePricelessAssets(
            _comptrollerProxy,
            _spendAssets,
            _spendAssetAmounts,
            getPricelessAssetBypassWethToken()
        );

        if (outgoingValue == 0) {
            return 0;
        }

        uint256 incomingValue = __calcTotalValueExlcudingBypassablePricelessAssets(
            _comptrollerProxy,
            _incomingAssets,
            _incomingAssetAmounts,
            getPricelessAssetBypassWethToken()
        );

        if (outgoingValue > incomingValue) {
            uint256 loss = outgoingValue.sub(incomingValue);

            return loss.mul(ONE_HUNDRED_PERCENT).div(outgoingValue);
        }

        return 0;
    }

    function __isBypassableAction(address _adapter) private view returns (bool isBypassable_) {
        return
            AddressListRegistry(getAddressListRegistry()).isInList(
                getBypassableAdaptersListId(),
                _adapter
            );
    }

    function __updateCumulativeSlippage(
        address _comptrollerProxy,
        uint256 _newSlippage,
        uint256 _tolerance
    ) private returns (uint256 nextCumulativeSlippage_) {
        PolicyInfo storage policyInfo = comptrollerProxyToPolicyInfo[_comptrollerProxy];

        nextCumulativeSlippage_ = policyInfo.cumulativeSlippage;

        if (nextCumulativeSlippage_ > 0) {
            uint256 cumulativeSlippageToRestore = _tolerance
                .mul(block.timestamp.sub(policyInfo.lastSlippageTimestamp))
                .div(getTolerancePeriodDuration());
            if (cumulativeSlippageToRestore < nextCumulativeSlippage_) {
                nextCumulativeSlippage_ = nextCumulativeSlippage_.sub(cumulativeSlippageToRestore);
            } else {
                nextCumulativeSlippage_ = 0;
            }
        }

        nextCumulativeSlippage_ = nextCumulativeSlippage_.add(_newSlippage);

        policyInfo.cumulativeSlippage = uint64(nextCumulativeSlippage_);
        policyInfo.lastSlippageTimestamp = uint128(block.timestamp);

        emit CumulativeSlippageUpdatedForFund(_comptrollerProxy, nextCumulativeSlippage_);

        return nextCumulativeSlippage_;
    }


    function getAddressListRegistry() public view returns (address addressListRegistry_) {
        return ADDRESS_LIST_REGISTRY;
    }

    function getBypassableAdaptersListId()
        public
        view
        returns (uint256 bypassableAdaptersListId_)
    {
        return BYPASSABLE_ADAPTERS_LIST_ID;
    }

    function getPolicyInfoForFund(address _comptrollerProxy)
        public
        view
        returns (PolicyInfo memory policyInfo_)
    {
        return comptrollerProxyToPolicyInfo[_comptrollerProxy];
    }

    function getTolerancePeriodDuration() public view returns (uint256 tolerancePeriodDuration_) {
        return TOLERANCE_PERIOD_DURATION;
    }
}