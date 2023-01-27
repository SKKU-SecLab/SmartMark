
pragma solidity ^0.8.1;

library AddressUpgradeable {

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

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


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
                bytes32 lastValue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
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

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

}//MIT
pragma solidity ^0.8.4;


interface INeuron is IERC20 {

    function mint(address to, uint256 amount) external;


    function burn(uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;

}//MIT
pragma solidity ^0.8.4;



contract BBKStaking is
    Initializable,
    IERC721ReceiverUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable
{

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    address public genAddress;
    address public gen2Address;
    address public erc20Address;
    uint256 public gen2Rate;
    uint256 public rareRate;
    uint256 public legendaryRate;

    struct Bag {
        EnumerableSetUpgradeable.UintSet genTokenIds;
        EnumerableSetUpgradeable.UintSet gen2TokenIds;
    }

    mapping(uint256 => uint256) public genToTimestamp;
    mapping(uint256 => uint256) public gen2ToTimestamp;

    mapping(uint256 => address) public genToStaker;
    mapping(uint256 => address) public gen2ToStaker;

    mapping(address => Bag) private stakerToBag;

    mapping(uint256 => bool) public isLegendaryToken;

    mapping(address => int256) private balance;

    function initialize(
        address _genAddress,
        address _gen2Address,
        address _erc20Address
    ) public initializer {

        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        genAddress = _genAddress;
        gen2Address = _gen2Address;
        erc20Address = _erc20Address;

        gen2Rate = 1 * 1e18;
        rareRate = 5 * 1e18;
        legendaryRate = 10 * 1e18;
    }


    function stake(
        uint256[] calldata genTokenIds,
        uint256[] calldata gen2TokenIds
    ) external whenNotPaused {

        for (uint256 i = 0; i < genTokenIds.length; i++) {
            uint256 curTokenId = genTokenIds[i];
            IERC721 nftContract = IERC721(genAddress);
            nftContract.safeTransferFrom(msg.sender, address(this), curTokenId);

            stakerToBag[msg.sender].genTokenIds.add(curTokenId);
            genToStaker[curTokenId] = msg.sender;
            genToTimestamp[curTokenId] = block.timestamp;
        }
        for (uint256 i = 0; i < gen2TokenIds.length; i++) {
            uint256 curTokenId = gen2TokenIds[i];
            IERC721 nftContract = IERC721(gen2Address);
            nftContract.safeTransferFrom(msg.sender, address(this), curTokenId);

            stakerToBag[msg.sender].gen2TokenIds.add(curTokenId);
            gen2ToStaker[curTokenId] = msg.sender;
            gen2ToTimestamp[curTokenId] = block.timestamp;
        }
    }

    function unstake(
        uint256[] calldata genTokenIds,
        uint256[] calldata gen2TokenIds
    ) external whenNotPaused {

        for (uint256 i = 0; i < genTokenIds.length; i++) {
            uint256 curTokenId = genTokenIds[i];
            require(
                genToStaker[curTokenId] == msg.sender,
                "You don't own this Token"
            );
            uint256 rewardForToken = _calculateRewardForToken(curTokenId);
            if (rewardForToken > 0) {
                balance[msg.sender] += int256(rewardForToken);
            }
            genToStaker[curTokenId] = address(0);
            genToTimestamp[curTokenId] = 0;
            stakerToBag[msg.sender].genTokenIds.remove(curTokenId);
            IERC721(genAddress).safeTransferFrom(
                address(this),
                msg.sender,
                curTokenId
            );
        }
        for (uint256 i = 0; i < gen2TokenIds.length; i++) {
            uint256 curTokenId = gen2TokenIds[i];
            require(
                gen2ToStaker[curTokenId] == msg.sender,
                "You don't own this Token"
            );
            uint256 rewardForToken = _calculateRewardForTokenGen2(curTokenId);
            if (rewardForToken > 0) {
                balance[msg.sender] += int256(rewardForToken);
            }
            gen2ToStaker[curTokenId] = address(0);
            gen2ToTimestamp[curTokenId] = 0;
            stakerToBag[msg.sender].gen2TokenIds.remove(curTokenId);
            IERC721(gen2Address).safeTransferFrom(
                address(this),
                msg.sender,
                curTokenId
            );
        }
    }

    function claimRewards() external nonReentrant whenNotPaused {

        EnumerableSetUpgradeable.UintSet storage tokenIds = stakerToBag[
            msg.sender
        ].genTokenIds;
        EnumerableSetUpgradeable.UintSet storage tokenIdsGen2 = stakerToBag[
            msg.sender
        ].gen2TokenIds;

        int256 reward = 0;
        for (uint256 i = 0; i < tokenIds.length(); i++) {
            uint256 curTokenId = tokenIds.at(i);
            uint256 stakedSince = genToTimestamp[curTokenId];
            genToTimestamp[curTokenId] = block.timestamp;
            uint256 timePassed = block.timestamp - stakedSince;
            uint256 _rate = isLegendaryToken[curTokenId]
                ? legendaryRate
                : rareRate;
            reward += int256(
                (timePassed / 60) * (((_rate / 1440) / 1e12) * 1e12)
            );
        }
        for (uint256 i = 0; i < tokenIdsGen2.length(); i++) {
            uint256 curTokenId = tokenIdsGen2.at(i);
            uint256 stakedSince = gen2ToTimestamp[curTokenId];
            gen2ToTimestamp[curTokenId] = block.timestamp;
            uint256 timePassed = block.timestamp - stakedSince;
            reward += int256(
                (timePassed / 60) * (((gen2Rate / 1440) / 1e12) * 1e12)
            );
        }

        reward = reward + balance[msg.sender];
        balance[msg.sender] = 0;

        require(reward > 0, "reward is less or equal 0");
        INeuron(erc20Address).mint(msg.sender, uint256(reward));
    }

    function deductFromBalance(uint256 amount) external whenNotPaused {

        _deductFromBalanceOf(msg.sender, amount);
    }

    function deductFromBalanceOf(address account, uint256 amount)
        external
        whenNotPaused
    {

        require(
            INeuron(erc20Address).allowance(account, msg.sender) >= amount,
            "ERC20: insufficient allowance"
        );
        _deductFromBalanceOf(account, amount);
    }

    function setGenAddress(address _genAddress) external onlyOwner {

        genAddress = _genAddress;
    }

    function setGen2Address(address _gen2Address) external onlyOwner {

        gen2Address = _gen2Address;
    }

    function setErc20Address(address _erc20Address) external onlyOwner {

        erc20Address = _erc20Address;
    }

    function setGen2Rate(uint256 _gen2Rate) external onlyOwner {

        gen2Rate = _gen2Rate;
    }

    function setRareRate(uint256 _rareRate) external onlyOwner {

        rareRate = _rareRate;
    }

    function setLegendaryRate(uint256 _legendaryRate) external onlyOwner {

        legendaryRate = _legendaryRate;
    }

    function setLegendaryTokenIds(uint256[] calldata tokenIds)
        external
        onlyOwner
    {

        for (uint256 i = 0; i < tokenIds.length; i++) {
            isLegendaryToken[tokenIds[i]] = true;
        }
    }

    function setPaused(bool b) external onlyOwner {

        b ? _pause() : _unpause();
    }

    function genDepositsOf(address addr)
        external
        view
        returns (uint256[] memory)
    {

        return stakerToBag[addr].genTokenIds.values();
    }

    function gen2DepositsOf(address addr)
        external
        view
        returns (uint256[] memory)
    {

        return stakerToBag[addr].gen2TokenIds.values();
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure override returns (bytes4) {

        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }



    function calculateRewards(address account) public view returns (uint256) {

        EnumerableSetUpgradeable.UintSet storage tokenIds = stakerToBag[account]
            .genTokenIds;
        EnumerableSetUpgradeable.UintSet storage tokenIdsGen2 = stakerToBag[
            account
        ].gen2TokenIds;

        int256 reward = 0;
        for (uint256 i = 0; i < tokenIds.length(); i++) {
            uint256 curTokenId = tokenIds.at(i);
            uint256 stakedSince = genToTimestamp[curTokenId];
            uint256 timePassed = block.timestamp - stakedSince;
            uint256 _rate = isLegendaryToken[curTokenId]
                ? legendaryRate
                : rareRate;
            reward += int256(
                (timePassed / 60) * (((_rate / 1440) / 1e12) * 1e12)
            );
        }
        for (uint256 i = 0; i < tokenIdsGen2.length(); i++) {
            uint256 curTokenId = tokenIdsGen2.at(i);
            uint256 stakedSince = gen2ToTimestamp[curTokenId];
            uint256 timePassed = block.timestamp - stakedSince;
            reward += int256(
                (timePassed / 60) * (((gen2Rate / 1440) / 1e12) * 1e12)
            );
        }
        reward = reward + balance[account];
        return reward > 0 ? uint256(reward) : 0;
    }

    function genBalanceOf(address addr) public view returns (uint256) {

        return stakerToBag[addr].genTokenIds.length();
    }

    function gen2BalanceOf(address addr) public view returns (uint256) {

        return stakerToBag[addr].gen2TokenIds.length();
    }


    function _calculateRewardForToken(uint256 tokenId)
        internal
        view
        returns (uint256)
    {

        if (genToStaker[tokenId] == address(0)) {
            return 0;
        }
        uint256 stakedSince = genToTimestamp[tokenId];
        uint256 timePassed = block.timestamp - stakedSince;
        uint256 _rate = isLegendaryToken[tokenId] ? legendaryRate : rareRate;
        uint256 reward = (timePassed / 60) * (((_rate / 1440) / 1e12) * 1e12);
        return reward;
    }

    function _calculateRewardForTokenGen2(uint256 tokenId)
        internal
        view
        returns (uint256)
    {

        if (gen2ToStaker[tokenId] == address(0)) {
            return 0;
        }
        uint256 stakedSince = gen2ToTimestamp[tokenId];
        uint256 timePassed = block.timestamp - stakedSince;
        uint256 reward = (timePassed / 60) *
            (((gen2Rate / 1440) / 1e12) * 1e12);
        return reward;
    }

    function _deductFromBalanceOf(address account, uint256 amount) internal {

        require(amount <= uint256(type(int256).max), "amount overflow");
        uint256 reward = calculateRewards(account);
        require(reward >= amount, "balance insufficient");
        balance[account] -= int256(amount);
    }
}