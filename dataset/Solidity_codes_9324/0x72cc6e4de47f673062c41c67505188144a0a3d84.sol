
pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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

}//MIT
pragma solidity ^0.8.6;

interface ILP {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function burn(address _to, uint256 _amount) external returns (bool);

    function mint(address _to, uint256 _amount) external returns (bool);

    function mintable() external view returns (bool);

    function burnable() external view returns (bool);

    function mintableStatusFrozen() external view returns (bool);

    function burnableStatusFrozen() external view returns (bool);
}//MIT
pragma solidity ^0.8.6;

interface IAdapter {
    function withdraw(
        address _recipient,
        address _pool,
        uint256 _share // multiplied by 1e18, for example 20% = 2e17
    ) external returns (bool);
}//MIT
pragma solidity ^0.8.6;

interface IFactory {
    function getDaos() external view returns (address[] memory);

    function shop() external view returns (address);

    function monthlyCost() external view returns (uint256);

    function subscriptions(address _dao) external view returns (uint256);

    function containsDao(address _dao) external view returns (bool);
}/*
██   ██ ██████   █████   ██████      ██████   █████   ██████  
 ██ ██  ██   ██ ██   ██ ██    ██     ██   ██ ██   ██ ██    ██ 
  ███   ██   ██ ███████ ██    ██     ██   ██ ███████ ██    ██ 
 ██ ██  ██   ██ ██   ██ ██    ██     ██   ██ ██   ██ ██    ██ 
██   ██ ██████  ██   ██  ██████      ██████  ██   ██  ██████  
*/
pragma solidity ^0.8.6;



contract Dao is ReentrancyGuard, ERC20 {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    using Address for address;
    using Address for address payable;
    using ECDSA for bytes32;

    uint32 public constant VOTING_DURATION = 3 days;


    EnumerableSet.AddressSet private permitted;

    EnumerableSet.AddressSet private adapters;

    address public immutable factory;

    address public immutable shop;

    address public lp = address(0);

    uint8 public quorum;

    struct ExecutedVoting {
        address target;
        bytes data;
        uint256 value;
        uint256 nonce;
        uint256 timestamp;
        uint256 executionTimestamp;
        bytes32 txHash;
        bytes[] sigs;
    }

    ExecutedVoting[] internal executedVoting;

    mapping(bytes32 => bool) public executedTx;

    struct ExecutedPermitted {
        address target;
        bytes data;
        uint256 value;
        uint256 executionTimestamp;
        address executor;
    }

    ExecutedPermitted[] public executedPermitted;

    bool public mintable = true;
    bool public burnable = true;


    event Executed(
        address indexed target,
        bytes data,
        uint256 value,
        uint256 indexed nonce,
        uint256 timestamp,
        uint256 executionTimestamp,
        bytes32 txHash,
        bytes[] sigs
    );

    event ExecutedP(
        address indexed target,
        bytes data,
        uint256 value,
        address indexed executor
    );


    modifier onlyDao() {
        require(
            msg.sender == address(this),
            "DAO: this function is only for DAO"
        );
        _;
    }


    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _quorum,
        address[] memory _partners,
        uint256[] memory _shares
    ) ERC20(_name, _symbol) {
        factory = msg.sender;

        shop = IFactory(msg.sender).shop();

        require(
            _quorum >= 1 && _quorum <= 100,
            "DAO: quorum should be 1 <= q <= 100"
        );

        quorum = _quorum;

        require(
            _partners.length > 0 && _partners.length == _shares.length,
            "DAO: shares distribution is invalid"
        );

        for (uint256 i = 0; i < _partners.length; i++) {
            _mint(_partners[i], _shares[i]);
        }
    }


    function executePermitted(
        address _target,
        bytes calldata _data,
        uint256 _value
    ) external nonReentrant returns (bool) {
        require(checkSubscription(), "DAO: subscription not paid");

        require(permitted.contains(msg.sender), "DAO: only for permitted");

        executedPermitted.push(
            ExecutedPermitted({
                target: _target,
                data: _data,
                value: _value,
                executionTimestamp: block.timestamp,
                executor: msg.sender
            })
        );

        emit ExecutedP(_target, _data, _value, msg.sender);

        if (_data.length == 0) {
            payable(_target).sendValue(_value);
        } else {
            if (_value == 0) {
                _target.functionCall(_data);
            } else {
                _target.functionCallWithValue(_data, _value);
            }
        }

        return true;
    }

    function execute(
        address _target,
        bytes calldata _data,
        uint256 _value,
        uint256 _nonce,
        uint256 _timestamp,
        bytes[] memory _sigs
    ) external nonReentrant returns (bool) {
        require(checkSubscription(), "DAO: subscription not paid");

        require(balanceOf(msg.sender) > 0, "DAO: only for members");

        require(
            _timestamp + VOTING_DURATION >= block.timestamp,
            "DAO: voting is over"
        );

        bytes32 txHash = getTxHash(_target, _data, _value, _nonce, _timestamp);

        require(!executedTx[txHash], "DAO: voting already executed");

        require(_checkSigs(_sigs, txHash), "DAO: quorum is not reached");

        executedTx[txHash] = true;

        executedVoting.push(
            ExecutedVoting({
                target: _target,
                data: _data,
                value: _value,
                nonce: _nonce,
                timestamp: _timestamp,
                executionTimestamp: block.timestamp,
                txHash: txHash,
                sigs: _sigs
            })
        );

        emit Executed(
            _target,
            _data,
            _value,
            _nonce,
            _timestamp,
            block.timestamp,
            txHash,
            _sigs
        );

        if (_data.length == 0) {
            payable(_target).sendValue(_value);
        } else {
            if (_value == 0) {
                _target.functionCall(_data);
            } else {
                _target.functionCallWithValue(_data, _value);
            }
        }

        return true;
    }

    function getTxHash(
        address _target,
        bytes calldata _data,
        uint256 _value,
        uint256 _nonce,
        uint256 _timestamp
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    address(this),
                    _target,
                    _data,
                    _value,
                    _nonce,
                    _timestamp,
                    block.chainid
                )
            );
    }

    function _checkSigs(bytes[] memory _sigs, bytes32 _txHash)
        internal
        view
        returns (bool)
    {
        bytes32 ethSignedHash = _txHash.toEthSignedMessageHash();

        uint256 share = 0;

        address[] memory signers = new address[](_sigs.length);

        for (uint256 i = 0; i < _sigs.length; i++) {
            address signer = ethSignedHash.recover(_sigs[i]);

            signers[i] = signer;
        }

        require(!_hasDuplicate(signers), "DAO: signatures are not unique");

        for (uint256 i = 0; i < signers.length; i++) {
            share += balanceOf(signers[i]);
        }

        if (share * 100 < totalSupply() * quorum) {
            return false;
        }

        return true;
    }

    function checkSubscription() public view returns (bool) {
        if (
            IFactory(factory).monthlyCost() > 0 &&
            IFactory(factory).subscriptions(address(this)) < block.timestamp
        ) {
            return false;
        }

        return true;
    }


    function burnLp(
        address _recipient,
        uint256 _share,
        address[] memory _tokens,
        address[] memory _adapters,
        address[] memory _pools
    ) external nonReentrant returns (bool) {
        require(lp != address(0), "DAO: LP not set yet");

        require(msg.sender == lp, "DAO: only for LP");

        require(
            !_hasDuplicate(_tokens),
            "DAO: duplicates are prohibited (tokens)"
        );

        for (uint256 i = 0; i < _tokens.length; i++) {
            require(
                _tokens[i] != lp && _tokens[i] != address(this),
                "DAO: LP and GT cannot be part of a share"
            );
        }

        require(_adapters.length == _pools.length, "DAO: adapters error");

        if (_adapters.length > 0) {
            uint256 length = _adapters.length;

            if (length > 1) {
                for (uint256 i = 0; i < length - 1; i++) {
                    for (uint256 j = i + 1; j < length; j++) {
                        require(
                            !(_adapters[i] == _adapters[j] &&
                                _pools[i] == _pools[j]),
                            "DAO: duplicates are prohibited (adapters)"
                        );
                    }
                }
            }
        }


        payable(_recipient).sendValue((address(this).balance * _share) / 1e18);


        if (_tokens.length > 0) {
            uint256[] memory _tokenShares = new uint256[](_tokens.length);

            for (uint256 i = 0; i < _tokens.length; i++) {
                _tokenShares[i] = ((IERC20(_tokens[i]).balanceOf(
                    address(this)
                ) * _share) / 1e18);
            }

            for (uint256 i = 0; i < _tokens.length; i++) {
                IERC20(_tokens[i]).safeTransfer(_recipient, _tokenShares[i]);
            }
        }


        if (_adapters.length > 0) {
            uint256 length = _adapters.length;

            for (uint256 i = 0; i < length; i++) {
                require(
                    adapters.contains(_adapters[i]),
                    "DAO: this is not an adapter"
                );

                require(
                    permitted.contains(_adapters[i]),
                    "DAO: this adapter is not permitted"
                );

                bool b = IAdapter(_adapters[i]).withdraw(
                    _recipient,
                    _pools[i],
                    _share
                );

                require(b, "DAO: withdrawal error");
            }
        }

        return true;
    }


    function mint(address _to, uint256 _amount)
        external
        onlyDao
        returns (bool)
    {
        require(mintable, "DAO: GT minting is disabled");
        _mint(_to, _amount);
        return true;
    }

    function burn(address _to, uint256 _amount)
        external
        onlyDao
        returns (bool)
    {
        require(burnable, "DAO: GT burning is disabled");
        _burn(_to, _amount);
        return true;
    }

    function move(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external onlyDao returns (bool) {
        _transfer(_sender, _recipient, _amount);
        return true;
    }

    function disableMinting() external onlyDao returns (bool) {
        mintable = false;
        return true;
    }

    function disableBurning() external onlyDao returns (bool) {
        burnable = false;
        return true;
    }


    function addAdapter(address a) external onlyDao returns (bool) {
        require(adapters.add(a), "DAO: already an adapter");

        permitted.add(a);

        return true;
    }

    function removeAdapter(address a) external onlyDao returns (bool) {
        require(adapters.remove(a), "DAO: not an adapter");

        permitted.remove(a);

        return true;
    }

    function addPermitted(address p) external onlyDao returns (bool) {
        require(permitted.add(p), "DAO: already permitted");

        return true;
    }

    function removePermitted(address p) external onlyDao returns (bool) {
        require(permitted.remove(p), "DAO: not a permitted");

        return true;
    }


    function setLp(address _lp) external returns (bool) {
        require(lp == address(0), "DAO: LP address has already been set");

        require(msg.sender == shop, "DAO: only Shop can set LP");

        lp = _lp;

        return true;
    }


    function changeQuorum(uint8 _q) external onlyDao returns (bool) {
        require(_q >= 1 && _q <= 100, "DAO: quorum should be 1 <= q <= 100");

        quorum = _q;

        return true;
    }


    function executedVotingByIndex(uint256 _index)
        external
        view
        returns (ExecutedVoting memory)
    {
        return executedVoting[_index];
    }

    function getExecutedVoting()
        external
        view
        returns (ExecutedVoting[] memory)
    {
        return executedVoting;
    }

    function getExecutedPermitted()
        external
        view
        returns (ExecutedPermitted[] memory)
    {
        return executedPermitted;
    }

    function numberOfAdapters() external view returns (uint256) {
        return adapters.length();
    }

    function containsAdapter(address a) external view returns (bool) {
        return adapters.contains(a);
    }

    function getAdapters() external view returns (address[] memory) {
        uint256 adaptersLength = adapters.length();

        if (adaptersLength == 0) {
            return new address[](0);
        } else {
            address[] memory adaptersArray = new address[](adaptersLength);

            for (uint256 i = 0; i < adaptersLength; i++) {
                adaptersArray[i] = adapters.at(i);
            }

            return adaptersArray;
        }
    }

    function numberOfPermitted() external view returns (uint256) {
        return permitted.length();
    }

    function containsPermitted(address p) external view returns (bool) {
        return permitted.contains(p);
    }

    function getPermitted() external view returns (address[] memory) {
        uint256 permittedLength = permitted.length();

        if (permittedLength == 0) {
            return new address[](0);
        } else {
            address[] memory permittedArray = new address[](permittedLength);

            for (uint256 i = 0; i < permittedLength; i++) {
                permittedArray[i] = permitted.at(i);
            }

            return permittedArray;
        }
    }


    function _hasDuplicate(address[] memory A) internal pure returns (bool) {
        if (A.length <= 1) {
            return false;
        } else {
            for (uint256 i = 0; i < A.length - 1; i++) {
                address current = A[i];
                for (uint256 j = i + 1; j < A.length; j++) {
                    if (current == A[j]) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    function transfer(address, uint256) public pure override returns (bool) {
        revert("GT: transfer is prohibited");
    }

    function transferFrom(
        address,
        address,
        uint256
    ) public pure override returns (bool) {
        revert("GT: transferFrom is prohibited");
    }


    event Received(address indexed, uint256);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}/*
██   ██ ██████   █████   ██████      ███████  █████   ██████ ████████  ██████  ██████  ██    ██ 
 ██ ██  ██   ██ ██   ██ ██    ██     ██      ██   ██ ██         ██    ██    ██ ██   ██  ██  ██  
  ███   ██   ██ ███████ ██    ██     █████   ███████ ██         ██    ██    ██ ██████    ████   
 ██ ██  ██   ██ ██   ██ ██    ██     ██      ██   ██ ██         ██    ██    ██ ██   ██    ██    
██   ██ ██████  ██   ██  ██████      ██      ██   ██  ██████    ██     ██████  ██   ██    ██    
*/
pragma solidity ^0.8.6;



contract Factory is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    address public immutable shop;

    address public immutable xdao;

    mapping(address => uint256) public subscriptions;

    uint256 public monthlyCost;

    uint256 public freeTrial;

    function subscribe(address _dao) external returns (bool) {
        require(daos.contains(_dao));

        if (subscriptions[_dao] < block.timestamp) {
            subscriptions[_dao] = block.timestamp + 30 days;
        } else {
            subscriptions[_dao] += 30 days;
        }

        IERC20(xdao).safeTransferFrom(msg.sender, owner(), monthlyCost);

        return true;
    }

    function changeMonthlyCost(uint256 _m) external onlyOwner returns (bool) {
        monthlyCost = _m;

        return true;
    }

    function changeFreeTrial(uint256 _freeTrial)
        external
        onlyOwner
        returns (bool)
    {
        freeTrial = _freeTrial;

        return true;
    }

    event DaoCreated(address indexed dao);

    constructor(address _shop, address _xdao) {
        shop = _shop;
        xdao = _xdao;
    }

    EnumerableSet.AddressSet private daos;

    function create(
        string memory _daoName,
        string memory _daoSymbol,
        uint8 _quorum,
        address[] memory _partners,
        uint256[] memory _shares
    ) external returns (bool) {
        Dao dao = new Dao(_daoName, _daoSymbol, _quorum, _partners, _shares);

        subscriptions[address(dao)] = block.timestamp + freeTrial;

        require(daos.add(address(dao)));

        emit DaoCreated(address(dao));

        return true;
    }


    function daoAt(uint256 _i) external view returns (address) {
        return daos.at(_i);
    }

    function containsDao(address _dao) external view returns (bool) {
        return daos.contains(_dao);
    }

    function numberOfDaos() external view returns (uint256) {
        return daos.length();
    }

    function getDaos() external view returns (address[] memory) {
        uint256 daosLength = daos.length();

        if (daosLength == 0) {
            return new address[](0);
        } else {
            address[] memory daosArray = new address[](daosLength);

            for (uint256 i = 0; i < daosLength; i++) {
                daosArray[i] = daos.at(i);
            }

            return daosArray;
        }
    }
}