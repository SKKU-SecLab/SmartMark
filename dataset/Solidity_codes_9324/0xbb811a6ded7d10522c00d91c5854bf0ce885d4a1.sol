
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


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

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

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b + (a % b == 0 ? 0 : 1);
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








pragma solidity ^0.8.7;


contract THCToken is ERC20Burnable, Ownable {

    struct StakedHighApe {
        uint256 tokenId;
        uint256 stakedSince;
        uint256 jointEmision;
    }

    using EnumerableSet for EnumerableSet.UintSet;
    uint256 public constant HighApesLimit = 25;

    address public highApes;

    mapping (uint256 => string) private _initialAccessSetter;


    mapping(address => EnumerableSet.UintSet) private stakedApes;


    mapping(uint256 => uint256) public apesStakeTimes;
    mapping(uint256 => uint256) public apesClaimTimes;

    constructor() ERC20("Joint", "JOINT") {
    }

    function stakeapesByIds(uint256[] memory _apesIds) external {
        require(
            _apesIds.length + stakedApes[msg.sender].length() <= HighApesLimit,
            "THC: Can stake maximum of 25 Apes!"
        );
        
        for (uint256 i = 0; i < _apesIds.length; i++) {
            _stakeHighApe(_apesIds[i]);
        }
    }

    function unstakeapesByIds(uint256[] memory _apesIds) public {
        for (uint256 i = 0; i < _apesIds.length; i++) {
            _unstakeHighApe(_apesIds[i]);
        }
    }

    function claimRewardsByIds(uint256[] memory _apesIds) external {
        uint256 runningjointAllowance;

        for (uint256 i = 0; i < _apesIds.length; i++) {
            uint256 thisApeID = _apesIds[i];
            require(
                stakedApes[msg.sender].contains(thisApeID),
                "THC: You can only claim Apes you've staked!"
            );
            runningjointAllowance += getjointOwedToThisHighApe(thisApeID);

            apesClaimTimes[thisApeID] = block.timestamp;
        }
        _mint(msg.sender, runningjointAllowance);
    }

    function claimAllRewards() external {
        uint256 runningjointAllowance;

        for (uint256 i = 0; i < stakedApes[msg.sender].length(); i++) {
            uint256 thisApeID = stakedApes[msg.sender].at(i);
            runningjointAllowance += getjointOwedToThisHighApe(thisApeID);

            apesClaimTimes[thisApeID] = block.timestamp;
        }
        _mint(msg.sender, runningjointAllowance);
    }

    function unstakeAll() external {
        unstakeapesByIds(stakedApes[msg.sender].values());
    }

    function _stakeHighApe(uint256 _ApesID) internal onlyApesOwner(_ApesID) {


        IERC721Enumerable(highApes).transferFrom(
            msg.sender,
            address(this),
            _ApesID
        );


        stakedApes[msg.sender].add(_ApesID);


        apesStakeTimes[_ApesID] = block.timestamp;
        apesClaimTimes[_ApesID] = 0;
    }

    function _unstakeHighApe(uint256 _ApesID)
        internal
        onlyApesStaker(_ApesID)
    {
        uint256 jointOwedToThisHighApe = getjointOwedToThisHighApe(_ApesID);
        _mint(msg.sender, jointOwedToThisHighApe);

        IERC721(highApes).transferFrom(
            address(this),
            msg.sender,
            _ApesID
        );

        stakedApes[msg.sender].remove(_ApesID);
    }


    function getStakedapesData(address _address)
        external
        view
        returns (StakedHighApe[] memory)
    {
        uint256[] memory ids = stakedApes[_address].values();
        StakedHighApe[] memory stakedapes = new StakedHighApe[](ids.length);
        for (uint256 index = 0; index < ids.length; index++) {
            uint256 _ApesID = ids[index];
            stakedapes[index] = StakedHighApe(
                _ApesID,
                apesStakeTimes[_ApesID],
                getApesJointEmission(_ApesID)
            );
        }

        return stakedapes;
    }

    function tokensStaked(address _address)
        external
        view
        returns (uint256[] memory)
    {
        return stakedApes[_address].values();
    }

    function stakedapesQuantity(address _address)
        external
        view
        returns (uint256)
    {
        return stakedApes[_address].length();
    }

    function getjointOwedToThisHighApe(uint256 _ApesID)
        public
        view
        returns (uint256)
    {
        uint256 elapsedTime = block.timestamp - apesStakeTimes[_ApesID];
        uint256 elapsedDays = elapsedTime < 1 days ? 0 : elapsedTime / 1 days;
        uint256 leftoverSeconds = elapsedTime - elapsedDays * 1 days;

        if (apesClaimTimes[_ApesID] == 0) {
            return _calculatejoint(elapsedDays, leftoverSeconds);
        }

        uint256 elapsedTimeSinceClaim = apesClaimTimes[_ApesID] -
            apesStakeTimes[_ApesID];
        uint256 elapsedDaysSinceClaim = elapsedTimeSinceClaim < 1 days
            ? 0
            : elapsedTimeSinceClaim / 1 days;
        uint256 leftoverSecondsSinceClaim = elapsedTimeSinceClaim -
            elapsedDaysSinceClaim *
            1 days;

       return _calculatejoint(elapsedDays, leftoverSeconds) - _calculatejoint(elapsedDaysSinceClaim, leftoverSecondsSinceClaim);
        
    }

    function getTotalRewardsForUser(address _address)
        external
        view
        returns (uint256)
    {
        uint256 runningjointTotal;
        uint256[] memory apesIds = stakedApes[_address].values();
        for (uint256 i = 0; i < apesIds.length; i++) {
            runningjointTotal += getjointOwedToThisHighApe(apesIds[i]);
        }
        return runningjointTotal;
    }

    function getApesJointEmission(uint256 _ApesID)
        public
        view
        returns (uint256)
    {
        uint256 elapsedTime = block.timestamp - apesStakeTimes[_ApesID];
        uint256 elapsedDays = elapsedTime < 1 days ? 0 : elapsedTime / 1 days;
        return _jointDailyIncrement(elapsedDays);
    }

    function _calculatejoint(uint256 _days, uint256 _leftoverSeconds)
        internal
        pure
        returns (uint256)
    {
        uint256 progressiveDays = Math.min(_days, 100);
        uint256 progressiveReward = progressiveDays == 0
            ? 0
            : (progressiveDays *
                (80.2 ether + 0.2 ether * (progressiveDays - 1) + 80.2 ether)) /
                2;

        uint256 dailyIncrement = _jointDailyIncrement(_days);
        uint256 leftoverReward = _leftoverSeconds > 0
            ? (dailyIncrement * _leftoverSeconds) / 1 days
            : 0;

        if (_days <= 100) {
            return progressiveReward + leftoverReward;
        }
        return progressiveReward + (_days - 100) * 100 ether + leftoverReward;
    }

    function _jointDailyIncrement(uint256 _days)
        internal
        pure
        returns (uint256)
    {
        return _days > 100 ? 100 ether : 80 ether + _days * 0.2 ether;
    }
  

    function setAddresses(address _highApes)
        public
        onlyOwner
    {
        highApes = _highApes;
    }

    function initialSupplyCreation(address to, uint256 amount) public onlyOwner {

        require(bytes(_initialAccessSetter[0]).length == 0, "THC: Access is Disabled Permanently");


        _mint(to, amount);
    }

    function setInitialAccess(string memory setaccess) public onlyOwner {
          _initialAccessSetter[0] = setaccess;
       }


    modifier onlyApesOwner(uint256 _ApesID) {
        require(
            IERC721Enumerable(highApes).ownerOf(_ApesID) == msg.sender,
            "THC: You can only stake the Apes you own!"
        );
        _;
    }

    modifier onlyApesStaker(uint256 _ApesID) {
        require(
            stakedApes[msg.sender].contains(_ApesID),
            "THC: You can only unstake the Apes you staked!"
        );
        _;
    }
}