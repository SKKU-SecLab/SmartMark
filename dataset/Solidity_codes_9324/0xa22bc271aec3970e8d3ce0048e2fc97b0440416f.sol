



pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
}



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}



pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.0;

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
}



pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}



pragma solidity ^0.8.0;



contract ERC20 is Initializable, Context, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) public initializer {

        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[45] private __gap;
}



pragma solidity ^0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.8.0;



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


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity ^0.8.0;




contract CryptoCapsule is Ownable{

    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for ERC20;

    struct Capsule {
        uint256 id;
        address grantor;
        address payable beneficiary;
        uint48 distributionDate;
        uint256 periodSize;
        uint256 periodCount;
        uint256 claimedPeriods;
        uint48 createdDate;
        bool empty;
        uint256 value;
        address[] tokens;
        uint256[] amounts;
        bool addingAssetsAllowed;
    }

    Capsule[] capsules;
    mapping (address => EnumerableSet.UintSet) private sent;
    mapping (address => EnumerableSet.UintSet) private received;


    constructor() Ownable() { }


    function createCapsule(
        address payable _beneficiary,
        uint48 _distributionDate,
        uint256 _periodSize,
        uint256 _periodCount,
        address[] calldata _tokens,
        uint256[] calldata _values,
        bool addingAssetsAllowed
    ) public payable returns(Capsule memory) {

        require(_distributionDate > block.timestamp, "Distribution Date must be in future");
        require(_tokens.length == _values.length, "Tokens and Values must be same length");
        require(_periodSize >= 1, "Period Size must greater than or equal to 1");
        require(_periodCount >= 1, "Period Count must greater than or equal to 1");
        require(_tokens.length <= 10, "Assets exceed maximum of 10 per capsule");

        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_values[i] > 0, "Token value must be greater than 0");
            ERC20 erc20Token = ERC20(_tokens[i]);
            erc20Token.safeTransferFrom(msg.sender, address(this), _values[i]);
        }

        uint256 capsuleId = capsules.length;
        capsules.push(
            Capsule(
                capsuleId,
                msg.sender,
                _beneficiary,
                _distributionDate,
                _periodSize,
                _periodCount,
                0,
                uint48(block.timestamp),
                false,
                msg.value,
                _tokens,
                _values,
                addingAssetsAllowed
            )
        );

        sent[msg.sender].add(capsuleId);
        received[_beneficiary].add(capsuleId);
        emit CapsuleCreated(capsuleId);
        return getCapsule(capsuleId);
    }

    function openCapsule(uint256 capsuleId) public {

        require(capsules.length > capsuleId, "Capsule does not exist");
        Capsule memory capsule = capsules[capsuleId];
        require(msg.sender == capsule.beneficiary, "You are not the beneficiary of this Capsule");
        require(!capsule.empty, "Capsule is empty");
        require(block.timestamp >= capsule.distributionDate, "Capsule has not matured yet");
        uint256 nextClaimDate = capsule.distributionDate + capsule.claimedPeriods * capsule.periodSize;
        require(block.timestamp >= nextClaimDate, "No periods available to claim"); 

        uint256 claimablePeriods = (block.timestamp - nextClaimDate) / capsule.periodSize + 1;
        uint256 unclaimedPeriods = capsule.periodCount - capsule.claimedPeriods;
        claimablePeriods = claimablePeriods > unclaimedPeriods ? unclaimedPeriods : claimablePeriods;

        capsules[capsuleId].claimedPeriods = capsule.claimedPeriods + claimablePeriods;
        capsules[capsuleId].empty = capsule.claimedPeriods + claimablePeriods == capsule.periodCount;

        if (capsule.value > 0) capsule.beneficiary.transfer(capsule.value * claimablePeriods / capsule.periodCount);
        for (uint256 i = 0; i < capsule.tokens.length; i++) {
            ERC20 erc20Token = ERC20(capsule.tokens[i]);
            erc20Token.safeTransfer(capsule.beneficiary, capsule.amounts[i] * claimablePeriods / capsule.periodCount);
        }

        emit CapsuleOpened(capsuleId);
    }

    function addAssets(uint256 capsuleId, address[] calldata _tokens, uint256[] calldata _values) public payable {

        require(capsules.length > capsuleId, "Capsule does not exist");
        require(_tokens.length == _values.length, "Tokens and Values must be same length");
        Capsule memory capsule = capsules[capsuleId];
        require(capsule.addingAssetsAllowed, "Adding assets not allowed for this Capsule");
        require(msg.sender == capsule.grantor, "You are not the grantor of this Capsule");
        require(block.timestamp < capsule.distributionDate, "Capsule is past distribution date");

        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_values[i] > 0, "Token value must be greater than 0");
            ERC20 erc20Token = ERC20(_tokens[i]);
            erc20Token.safeTransferFrom(msg.sender, address(this), _values[i]);

            bool tokenExists = false;
            for (uint256 j = 0; j < capsule.tokens.length; j++) {
                if (capsule.tokens[j] == _tokens[i]) {
                    capsules[capsuleId].amounts[j] += _values[i];
                    tokenExists = true;
                    break;
                }
            }
            if (!tokenExists) {
                capsules[capsuleId].tokens.push(_tokens[i]);
                capsules[capsuleId].amounts.push(_values[i]);
            }
        }
        require(capsules[capsuleId].tokens.length <= 10, "Assets exceed maximum of 10 per capsule");

        capsules[capsuleId].value += msg.value; 

        emit AddedAssets(capsuleId, _tokens, _values, msg.value);
    }

    function updateBeneficiary(uint256 capsuleId, address payable beneficiary) public {

        require(capsules.length > capsuleId, "Capsule does not exist");
        Capsule memory capsule = capsules[capsuleId];
        require(msg.sender == capsule.beneficiary, "You are not the beneficiary of this Capsule");
        require(!capsule.empty, "Capsule is empty");
        require(capsule.beneficiary != beneficiary, "Beneficiary is not different to curret");
        received[capsule.beneficiary].remove(capsuleId);
        capsules[capsuleId].beneficiary = beneficiary;
        received[beneficiary].add(capsuleId);
        emit UpdatedBeneficiary(capsuleId, beneficiary);
    }


    function getCapsuleCount() public view returns(uint256) {

        return capsules.length;
    }
    
    function getCapsule(uint256 capsuleId) public view returns(Capsule memory) {

        require(capsules.length > capsuleId, "Capsule does not exist");
        return capsules[capsuleId];
    }

    function getCapsules() public view returns(Capsule[] memory) {

        return capsules;
    }

    function getSentCapsules(address grantor) public view returns(Capsule[] memory) {

        uint256 count = sent[grantor].length();
        Capsule[] memory _capsules = new Capsule[](count);
        for (uint256 i = 0; i < count; i++) {
            _capsules[i] = capsules[sent[grantor].at(i)];
        }
        return _capsules;
    }

    function getReceivedCapsules(address beneficiary) public view returns(Capsule[] memory) {

        uint256 count = received[beneficiary].length();
        Capsule[] memory _capsules = new Capsule[](count);
        for (uint256 i = 0; i < count; i++) {
            _capsules[i] = capsules[received[beneficiary].at(i)];
        }
        return _capsules;
    }


    event CapsuleOpened(uint256 capsuleId);
    event CapsuleCreated(uint256 capsuleId);
    event AddedAssets(uint256 capsuleId, address[] tokens, uint256[] values, uint256 eth);
    event UpdatedBeneficiary(uint256 capsuleId, address payable beneficiary);
}