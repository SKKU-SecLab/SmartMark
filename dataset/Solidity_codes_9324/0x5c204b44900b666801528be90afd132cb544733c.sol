
pragma solidity ^0.6.0;

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

pragma solidity ^0.6.0;

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
}// MIT

pragma solidity ^0.6.2;

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.6.0;


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
}// MIT

pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

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

}// MIT

pragma solidity ^0.6.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}// MIT

pragma solidity ^0.6.0;


contract ERC721Holder is IERC721Receiver {


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}// MIT

pragma solidity ^0.6.0;

contract ReentrancyGuard {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.6.0;


library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}// MIT

pragma solidity ^0.6.0;

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

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;


interface IERC20Decimals {

    function decimals() external view returns (uint8);

}

contract Main is ERC721Holder, ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeMath for uint256;
    enum TokenType { Erc20, Erc721 }

    struct TokenDeposit {
        address _tokenAddress;
        uint256 _value;
        TokenType _type;
    }

    struct TokenDepositWithDecimals {
        address _tokenAddress;
        uint256 _value;
        TokenType _type;
        uint8 _decimals;
    }

    event Deposit(
        address _contractAddress,
        uint256 _value,
        uint _type,
        uint256 _vaultId
    );

    event Withdraw(
        uint256 _vaultId,
        address _to
    );

    Counters.Counter private _globalIndex;

    uint constant MAX = uint(0) - uint(1);
    uint constant DUST_WITHDRAWAL_TIMESTAMP = 1635379200;

    mapping (uint256 => TokenDeposit[]) _VaultIdToDeposits;

    uint256[] _vaults;

    mapping(address => uint256) _OwnerToVaultId;
    mapping(uint256 => address) _VaultIdToOwner;


    bool public isGameActive = true;
    bool public isEmergencyPlugPlugged = false;
    uint public gameEndTimestamp;

    uint256 private _random;

    constructor (uint256 timestamp) public {
        gameEndTimestamp = timestamp;
    }

    function _depositERC20(address[] memory erc20Addresses, uint256[] memory erc20Values) private   {

        require(erc20Addresses.length == erc20Values.length, "both array need to be same length");

        for (uint i = 0; i< erc20Addresses.length; i++) {
            IERC20(erc20Addresses[i]).safeTransferFrom(msg.sender, address(this), erc20Values[i]);
            TokenDeposit memory entry = TokenDeposit(erc20Addresses[i], erc20Values[i], TokenType.Erc20);
            _VaultIdToDeposits[_getUserVaultId()].push(entry);
            emit Deposit(erc20Addresses[i], erc20Values[i], 0, _getUserVaultId());
        }
    }

    function _depositERC721(address[] memory erc721Addresses, uint256[] memory erc721TokenIds) private {

        require(erc721Addresses.length == erc721TokenIds.length, "both array need to be same length");

        for (uint i = 0; i< erc721Addresses.length; i++) {
            IERC721(erc721Addresses[i]).safeTransferFrom(msg.sender, address(this), erc721TokenIds[i]);
            TokenDeposit memory entry = TokenDeposit(erc721Addresses[i], erc721TokenIds[i], TokenType.Erc721);
            _VaultIdToDeposits[_getUserVaultId()].push(entry);
            emit Deposit(erc721Addresses[i], erc721TokenIds[i], 1, _getUserVaultId());
        }
    }

    function deposit(
        address[] calldata erc20Addresses, uint256[] calldata erc20Values,
        address[] calldata erc721Addresses, uint256[] calldata erc721TokenIds
    ) external gameActive nonReentrant {

        require(erc721Addresses.length > 0 || erc20Addresses.length > 0, "at least one token needs to be deposited");

        if (erc721Addresses.length > 0) {
            _depositERC721(erc721Addresses, erc721TokenIds);
        }
        if (erc20Addresses.length > 0) {
            _depositERC20(erc20Addresses, erc20Values);
        }

        _endGameMaybe();
    }

    function _getUserVaultId() private returns(uint256) {

        if (_OwnerToVaultId[msg.sender] == 0) {
            _globalIndex.increment();
            uint256 current = _globalIndex.current();
            _OwnerToVaultId[msg.sender] = current;
            _VaultIdToOwner[current] = msg.sender;
            _vaults.push(current);
        }
        return _OwnerToVaultId[msg.sender];
    }

    function _getMiddleAddress() private view returns (address) {

        uint256 middleVaultId;
        if (_vaults.length == 0) {
            return address(0);
        }
        if (_vaults.length.mod(2) != 0) {
            middleVaultId = _vaults[_vaults.length.sub(1).div(2)];
        } else {
            middleVaultId = _vaults[_vaults.length.div(2)];
        }
        return _VaultIdToOwner[middleVaultId];
    }

    function _endGameMaybe() private {

        if(block.timestamp > gameEndTimestamp) {
            isGameActive = false;
            address _middleAddress = _getMiddleAddress();
            _random = uint256(keccak256(abi.encodePacked(blockhash(block.number), _middleAddress)));
        }
    }

    modifier gameActive {

      require(isGameActive == true, "game is not active");
      _;
    }

    modifier gameOver {

      require(isGameActive == false, "game is still active");
      _;
    }

    function withdraw() external gameOver nonReentrant {

        require(_OwnerToVaultId[msg.sender] > 0, "must be a player");

        if (isEmergencyPlugPlugged) {
            uint256 vaultId = _OwnerToVaultId[msg.sender];
            _withdraw(vaultId, msg.sender);
            emit Withdraw(vaultId, msg.sender);
        } else {
            (uint256 vaultId, uint256 vaultIndex) = _getRandomVaultIdIndex();
            _deleteVaultAtIndex(vaultIndex);
            _withdraw(vaultId, msg.sender);
            emit Withdraw(vaultId, msg.sender);
        }
    }

    function _withdraw(uint256 vaultId, address beneficiary) private {


        for (uint i = 0; i< _VaultIdToDeposits[vaultId].length; i++) {
            TokenDeposit memory entry = _VaultIdToDeposits[vaultId][i];
            if (entry._type == TokenType.Erc721) {
                IERC721(entry._tokenAddress).safeTransferFrom(address(this), beneficiary, entry._value);
            }
            if (entry._type == TokenType.Erc20) {
                IERC20(entry._tokenAddress).safeTransfer(beneficiary, entry._value);
            }
        }

        delete _VaultIdToDeposits[vaultId];
        delete _OwnerToVaultId[beneficiary];
        delete _VaultIdToOwner[vaultId];
    }

    function _deleteVaultAtIndex(uint index) internal {

        require(index < _vaults.length);
        _vaults[index] = _vaults[_vaults.length-1];
        _vaults.pop();
    }

    function _getRandomVaultIdIndex() private view returns(uint256, uint256) {

        uint256 randomIndex = _getRandom(_random, _vaults.length);
        return (_vaults[randomIndex], randomIndex);
    }

    function _getRandom(uint256 seed, uint256 upperBound) private pure returns(uint256) {

        return seed / (MAX / upperBound);
    }

    function getVaultIdCounter() external view returns(uint256) {

        return _globalIndex.current();
    }

    function isUserPlayer(address userAddress) external view returns(bool) {

        return _OwnerToVaultId[userAddress] > 0;
    }

    function getVaultDepositsOfOwner(address owner) external view returns (TokenDepositWithDecimals[] memory) {

        uint256 vaultId = _OwnerToVaultId[owner];
        TokenDepositWithDecimals[] memory tokenList = new TokenDepositWithDecimals[](_VaultIdToDeposits[vaultId].length);
        for (uint i = 0; i< _VaultIdToDeposits[vaultId].length; i++) {
            TokenDeposit memory tokenDeposit = _VaultIdToDeposits[vaultId][i];
            uint8 decimals = 0;
            if (tokenDeposit._type == TokenType.Erc20) {
                decimals = IERC20Decimals(tokenDeposit._tokenAddress).decimals();
            }
            tokenList[i] = TokenDepositWithDecimals(tokenDeposit._tokenAddress, tokenDeposit._value, tokenDeposit._type, decimals);
        }
        return tokenList;
    }

    function emergencyPlug() external onlyOwner {

        isGameActive = false;
        isEmergencyPlugPlugged = true;
    }

    function dust(address tokenAddress, uint256 value, TokenType tokenType) external onlyOwner {

        require(block.timestamp > DUST_WITHDRAWAL_TIMESTAMP, "try again later");
        if (tokenType == TokenType.Erc721) {
            IERC721(tokenAddress).safeTransferFrom(address(this), msg.sender, value);
        }
        if (tokenType == TokenType.Erc20) {
            IERC20(tokenAddress).safeTransfer(msg.sender, value);
        }
    }
}