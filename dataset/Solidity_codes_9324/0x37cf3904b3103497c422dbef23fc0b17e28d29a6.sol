
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

interface IDAMA {

    event AddMinter(address minter);
    event RemoveMinter(address minter);

    event AddBurner(address minter);
    event RemoveBurner(address minter);

    event MintDAMA(address to, uint256 amount);
    event BurnDAMA(address from, uint256 amount);

    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

}// MIT
pragma solidity ^0.8.0;

interface INewKinko{

    
    function joinOf(address erc721, address account) external view returns (uint256[] memory);

    function batchClaimRewards() external;

    function claimRewards(address erc721) external;

    function calcReward(address erc721, address account) external view returns(uint256);

    function calcRewardAll(address account) external view returns(uint256 reward);

    function join(address erc721, uint256[] calldata tokenIds) external;

    function leave(address erc721, uint256[] calldata tokenIds) external;

    function ownerOf(address erc721, address account, uint256 tokenId) external view returns(bool);

}// MIT
pragma solidity ^0.8.0;


contract NewKinko is INewKinko, IERC721Receiver, Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    address DAMA;

    EnumerableSet.AddressSet erc721s;
    mapping(address => uint256) public perDays;

    mapping(address => mapping(address => EnumerableSet.UintSet))
        private _deposits;
    mapping(address => mapping(address => uint256)) public depositBlockTimes;

    uint256 public startTimestamp;
    uint256 public endTimestamp;
    uint256 public totalSupply;

    mapping(address => uint256) public joined;

    modifier onlyRegistered(address erc721) {

        require(erc721s.contains(erc721), "unregistered ERC721");
        _;
    }

    constructor() {
        startTimestamp = 1638316800;
        endTimestamp = 1764547200;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        return IERC721Receiver.onERC721Received.selector;
    }

    function setDama(address dama) public onlyOwner {

        DAMA = dama;
    }

    function addERC721(address erc721, uint256 perDay) public onlyOwner {

        require(
            IERC721(erc721).supportsInterface(0x80ac58cd),
            "Only ERC721 by ERC165"
        );
        require(!erc721s.contains(erc721), "Already Registry ERC721");
        erc721s.add(erc721);
        perDays[erc721] = perDay;
    }

    function modifyERC721(address erc721, uint256 perDay)
        public
        onlyOwner
        onlyRegistered(erc721)
    {

        perDays[erc721] = perDay;
    }

    function removeERC721(address erc721)
        public
        onlyOwner
        onlyRegistered(erc721)
    {

        erc721s.remove(erc721);
        perDays[erc721] = 0;
    }

    function modifyEndTimestamp(uint256 timestamp) public onlyOwner {

        require(
            endTimestamp < timestamp,
            "timestamp must be greater than endTimestamp."
        );
        endTimestamp = timestamp;
    }

    function joinOf(address erc721, address account)
        public
        view
        override
        onlyRegistered(erc721)
        returns (uint256[] memory)
    {

        EnumerableSet.UintSet storage depositSet = _deposits[erc721][account];
        uint256[] memory tokenIds = new uint256[](depositSet.length());

        for (uint256 i; i < depositSet.length(); i++) {
            tokenIds[i] = depositSet.at(i);
        }

        return tokenIds;
    }

    function batchClaimRewards() public override nonReentrant {

        for (uint256 i = 0; i < erc721s.length(); i++) {
            address erc721 = erc721s.at(i);
            _claimRewards(erc721);
        }
    }

    function claimRewards(address erc721) public override nonReentrant {

        _claimRewards(erc721);
    }

    function calcReward(address erc721, address account)
        public
        view
        override
        returns (uint256)
    {

        return
            perDays[erc721]
                .mul(_deposits[erc721][account].length())
                .mul(
                    Math.min(block.timestamp, endTimestamp) -
                        (
                            depositBlockTimes[erc721][account] == 0
                                ? block.timestamp
                                : depositBlockTimes[erc721][account]
                        )
                )
                .div(1 days);
    }

    function calcRewardAll(address account)
        public
        view
        override
        returns (uint256)
    {

        uint256 reward = 0;
        for (uint256 i = 0; i < erc721s.length(); i++) {
            address erc721 = erc721s.at(i);
            reward += calcReward(erc721, account);
        }
        return reward;
    }

    function _claimRewards(address erc721) internal onlyRegistered(erc721) {

        uint256 reward = calcReward(erc721, msg.sender);
        if (reward > 0) {
            IDAMA(DAMA).mint(msg.sender, reward);
        }
        depositBlockTimes[erc721][msg.sender] = block.timestamp;
        totalSupply = totalSupply + reward;
    }

    function join(address erc721, uint256[] calldata tokenIds)
        external
        override
        nonReentrant
        onlyRegistered(erc721)
    {

        require(block.timestamp > startTimestamp, "Can't join yet.");
        _claimRewards(erc721);
        for (uint256 i; i < tokenIds.length; i++) {
            IERC721(erc721).safeTransferFrom(
                msg.sender,
                address(this),
                tokenIds[i]
            );

            _deposits[erc721][msg.sender].add(tokenIds[i]);
            joined[erc721] = joined[erc721] + 1;
        }
    }

    function batchJoin(
        address[] calldata _erc721s,
        uint256[][] calldata tokenIds
    ) external nonReentrant {

        require(
            _erc721s.length == tokenIds.length,
            "Not equals ERC721s length and tokenIds length"
        );
        for (uint256 i; i < _erc721s.length; i++) {
            require(erc721s.contains(_erc721s[i]), "unregistered ERC721");
            _claimRewards(_erc721s[i]);
            for (uint256 j; j < tokenIds[i].length; j++) {
                IERC721(_erc721s[i]).safeTransferFrom(
                    msg.sender,
                    address(this),
                    tokenIds[i][j]
                );
                _deposits[_erc721s[i]][msg.sender].add(tokenIds[i][j]);
                joined[_erc721s[i]] = joined[_erc721s[i]] + 1;
            }
        }
    }

    function leave(address erc721, uint256[] calldata tokenIds)
        external
        override
        nonReentrant
        onlyRegistered(erc721)
    {

        _claimRewards(erc721);
        for (uint256 i; i < tokenIds.length; i++) {
            require(
                _deposits[erc721][msg.sender].contains(tokenIds[i]),
                "Token Not joined"
            );

            _deposits[erc721][msg.sender].remove(tokenIds[i]);
            joined[erc721] = joined[erc721] - 1;
            IERC721(erc721).safeTransferFrom(
                address(this),
                msg.sender,
                tokenIds[i]
            );
        }
    }

    function batchLeave(
        address[] calldata _erc721s,
        uint256[][] calldata tokenIds
    ) external nonReentrant {

        require(
            _erc721s.length == tokenIds.length,
            "Not equals ERC721s length and tokenIds length"
        );

        for (uint256 i; i < _erc721s.length; i++) {
            require(erc721s.contains(_erc721s[i]), "unregistered ERC721");
            _claimRewards(_erc721s[i]);
            for (uint256 j; j < tokenIds[i].length; j++) {
                require(
                    _deposits[_erc721s[i]][msg.sender].contains(tokenIds[i][j]),
                    "Token Not joined"
                );
                _deposits[_erc721s[i]][msg.sender].remove(tokenIds[i][j]);
                joined[_erc721s[i]] = joined[_erc721s[i]] - 1;
                IERC721(_erc721s[i]).safeTransferFrom(
                    address(this),
                    msg.sender,
                    tokenIds[i][j]
                );
            }
        }
    }

    function ownerOf(
        address erc721,
        address account,
        uint256 tokenId
    ) external view override returns (bool) {

        return _deposits[erc721][account].contains(tokenId);
    }
}