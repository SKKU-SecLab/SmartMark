



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
}




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
}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

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
}


pragma solidity 0.8.7;





contract DeathWish is ReentrancyGuard {

    using EnumerableSet for EnumerableSet.UintSet;
    struct Switch {
        TokenType tokenType; //1 - ERC20 , 2 - ERC721 - 3 - ERC1155
        uint64 unlock;
        address user;
        address tokenAddress;
        uint256 tokenId; //for ERC721/ERC1155
        uint256 amount; //for ERC20/ERC1155
    }
    enum TokenType {
        ERC20, ERC721, ERC1155
    }
    uint256 public counter;
    mapping(uint256 => Switch) switches; // main construct
    mapping(uint256 => bool) switchClaimed; 
    mapping(address => uint256[]) userSwitches; // Enumerate switches owned by a user
    mapping(address => EnumerableSet.UintSet) userBenefactor; // Enumerate switches given someone who is a benefactor
    mapping(uint256 => address[]) benefactors; // Enumerate benefactors given a switch. Ordered list.

    uint64 public constant MAX_TIMESTAMP = type(uint64).max;
    uint256 public constant MAX_ALLOWANCE = type(uint256).max;

    function inspectSwitchAs(uint256 id, address _user) external view returns (uint64, uint64, address, address, TokenType, uint256, uint256) {

        require(id < counter, "Out of range");
        Switch memory _switch = switches[id];
        return (switchClaimableByAt(id, _user), _switch.unlock, _switch.user, _switch.tokenAddress, _switch.tokenType, _switch.tokenId, _switch.amount);
    }

    function isSwitchClaimed(uint256 id) external view returns (bool) {

        return switchClaimed[id];
    }

    function switchClaimableByAt(uint256 id, address _user) internal view returns (uint64) {

        if (switchClaimed[id]) return MAX_TIMESTAMP;
        Switch memory _switch = switches[id];
        if (_user == _switch.user) return 0;
        uint256 length = benefactors[id].length;
        for(uint256 i = 0; i < length; i++) {
            if (benefactors[id][i] == _user) {
                return (_switch.unlock + uint64((i * 60 days)));
            }
        }
        return MAX_TIMESTAMP;
    }

    function isSwitchClaimableBy(uint256 id, address _user) public view returns (bool) {

        return (block.timestamp > switchClaimableByAt(id, _user));
    }

    function getBenefactorsForSwitch(uint256 id) external view returns (address[] memory) {

        require(id < counter, "Out of range");
        return benefactors[id];
    }

    function getOwnedSwitches(address _user) external view returns (uint256[] memory) {

        return userSwitches[_user];
    }

    function getBenefactorSwitches(address _user) external view returns (uint256[] memory) {

        return userBenefactor[_user].values();
    }

    function createNewERC20Switch(uint64 unlockTimestamp, address tokenAddress, uint256 amount, address[] memory _benefactors) external {

        require(IERC20(tokenAddress).allowance(msg.sender, address(this)) == MAX_ALLOWANCE, "Max allowance not set");
        switches[counter] = Switch(
            TokenType.ERC20,
            unlockTimestamp,
            msg.sender,
            tokenAddress,
            0, //null
            amount
        );
        benefactors[counter] = _benefactors;
        userSwitches[msg.sender].push(counter);
        uint256 length = _benefactors.length;
        for(uint256 i = 0; i < length; i++) {
            userBenefactor[_benefactors[i]].add(counter);
        }
        emit SwitchCreated(counter, switches[counter].tokenType);
        counter++;
    }

    function createNewERC721Switch(uint64 unlockTimestamp, address tokenAddress, uint256 tokenId, address[] memory _benefactors) external {

        require(IERC721(tokenAddress).isApprovedForAll(msg.sender, address(this)), "No allowance set");
        require(tokenAddress != 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB, "please use Wrapped Punks: https://www.wrappedpunks.com/");
        switches[counter] = Switch(
            TokenType.ERC721,
            unlockTimestamp,
            msg.sender,
            tokenAddress,
            tokenId, 
            0 //null
        );
        benefactors[counter] = _benefactors;
        userSwitches[msg.sender].push(counter);
        uint256 length = _benefactors.length;
        for(uint256 i = 0; i < length; i++) {
            userBenefactor[_benefactors[i]].add(counter);
        }
        emit SwitchCreated(counter, switches[counter].tokenType);
        counter++;
    }

    function createNewERC1155Switch(uint64 unlockTimestamp, address tokenAddress, uint256 tokenId, uint256 amount, address[] memory _benefactors) external {

        require(IERC1155(tokenAddress).isApprovedForAll(msg.sender, address(this)), "No allowance set");
        switches[counter] = Switch(
            TokenType.ERC1155,
            unlockTimestamp,
            msg.sender,
            tokenAddress,
            tokenId,
            amount
        );
        benefactors[counter] = _benefactors;
        userSwitches[msg.sender].push(counter);
        uint256 length = _benefactors.length;
        for(uint256 i = 0; i < length; i++) {
            userBenefactor[_benefactors[i]].add(counter);
        }
        emit SwitchCreated(counter, switches[counter].tokenType);
        counter++;
    }

    event SwitchCreated(uint256 id, TokenType switchType);
    event SwitchClaimed(uint256 id, TokenType switchType);
    event UnlockTimeUpdated(uint256 id, uint64 unlock_time);
    event TokenAmountUpdated(uint256 id, uint256 unlock_time);
    event BenefactorsUpdated(uint256 id);

    function updateUnlockTime(uint256 id, uint64 newUnlock) external {

        require(id < counter, "out of range");
        Switch memory _switch = switches[id];
        require(_switch.user == msg.sender, "You are not the locker");
        switches[id].unlock = newUnlock;
        emit UnlockTimeUpdated(id, newUnlock);
    }

    function updateTokenAmount(uint256 id, uint256 newAmount) external {

        require(id < counter, "out of range");
        Switch memory _switch = switches[id];
        require(_switch.user == msg.sender, "You are not the locker");
        require(_switch.tokenType != TokenType.ERC721, "Not valid for ERC721");
        if (_switch.tokenType == TokenType.ERC20) {
            require(IERC20(_switch.tokenAddress).allowance(msg.sender, address(this)) == MAX_ALLOWANCE, "Max allowance not set");
        }
        switches[id].amount = newAmount;
        emit TokenAmountUpdated(id, newAmount);
    }

    function updateBenefactors(uint256 id, address[] memory _benefactors) external {

        require(id < counter, "out of range");
        Switch memory _switch = switches[id];
        uint256 len1 = benefactors[id].length;
        uint256 len2 = _benefactors.length;
        require(_switch.user == msg.sender, "You are not the locker");
        for(uint256 i = 0; i < len1; i++) {
            userBenefactor[benefactors[id][i]].remove(id);
        }
        
        benefactors[id] = _benefactors;

        for(uint256 i = 0; i < len2; i++) {
            userBenefactor[_benefactors[i]].add(id);
        }
        emit BenefactorsUpdated(id);
    }

    function claimSwitch(uint256 id) external nonReentrant {

        Switch memory _switch = switches[id];
        require(isSwitchClaimableBy(id, msg.sender), "sender is not a benefactor or owner");
        switchClaimed[id] = true;
        if (_switch.tokenType == TokenType.ERC20) {
            IERC20(_switch.tokenAddress).transferFrom(_switch.user, msg.sender, 
            min(IERC20(_switch.tokenAddress).balanceOf(_switch.user), _switch.amount));
        } else if (_switch.tokenType == TokenType.ERC721) {
            IERC721(_switch.tokenAddress).safeTransferFrom(_switch.user, msg.sender, _switch.tokenId);
        } else if (_switch.tokenType == TokenType.ERC1155) {
            IERC1155(_switch.tokenAddress).safeTransferFrom(_switch.user, msg.sender, _switch.tokenId, 
            min(IERC1155(_switch.tokenAddress).balanceOf(_switch.user, _switch.tokenId), _switch.amount), '');
        } else { revert("FUD"); }
        emit SwitchClaimed(id, _switch.tokenType);
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x > y) {
            return y;
        }
        return x;
    }
}