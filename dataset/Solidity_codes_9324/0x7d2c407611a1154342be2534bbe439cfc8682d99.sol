
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

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
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
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
}// MIT

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
}// MIT
pragma solidity ^0.8.0;




abstract contract SamotToken {
    function claim(address _claimer, uint256 _reward) external {}

    function burn(address _from, uint256 _amount) external {}
}

abstract contract StakingV1 {
    function stakeOf(address _stakeholder)
        public
        view
        virtual
        returns (uint256[] memory);

    function stakeTimestampsOf(address _stakeholder)
        public
        view
        virtual
        returns (uint256[] memory);
}

abstract contract SamotNFT {
    function ownerOf(uint256 tokenId) public view virtual returns (address);

    function balanceOf(address owner)
        public
        view
        virtual
        returns (uint256 balance);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual;

    function isApprovedForAll(address owner, address operator)
        external
        view
        virtual
        returns (bool);
}

contract SamotStaking is Ownable, IERC721Receiver, ReentrancyGuard, Pausable {

    using EnumerableSet for EnumerableSet.UintSet;
    using SafeMath for uint256;
    address public nftAddress;
    address public erc20Address;
    address public stakingV1Address;

    uint256 public rate;
    uint256 public startBlock = 13606743;
    uint256 public v1Rate;
    uint256 public v1RatePost;

    SamotToken token;
    SamotNFT nft;
    StakingV1 stakedV1;

    bool public stakingV1IsActive = true;

    mapping(address => EnumerableSet.UintSet) private _deposits;
    mapping(address => mapping(uint256 => uint256)) public _depositBlocks;

    mapping(address => uint256) public v1Timestamp;
    mapping(address => bool) public hasClaimedDrop;

    constructor(
        address _nftAddress,
        uint256 _rate,
        address _erc20Address,
        address _stakingV1Address,
        uint256 _v1Rate
    ) {
        rate = _rate;
        v1Rate = _v1Rate;
        v1RatePost = _v1Rate;
        nftAddress = _nftAddress;
        token = SamotToken(_erc20Address);
        nft = SamotNFT(_nftAddress);
        stakedV1 = StakingV1(_stakingV1Address);
        _pause();
    }

    function setTokenContract(address _erc20Address) external onlyOwner {

        token = SamotToken(_erc20Address);
    }

    function setStakingV1Contract(address _stakingV1Address)
        external
        onlyOwner
    {

        stakedV1 = StakingV1(_stakingV1Address);
    }

    function setNFTContract(address _nftAddress) external onlyOwner {

        nft = SamotNFT(_nftAddress);
    }

    function pause() public onlyOwner {

        _pause();
    }

    function unpause() public onlyOwner {

        _unpause();
    }


    function setRate(uint256 _rate) public onlyOwner {

        rate = _rate;
    }

    function depositsOf(address account)
        public
        view
        returns (uint256[] memory)
    {

        EnumerableSet.UintSet storage depositSet = _deposits[account];
        uint256[] memory tokenIds = new uint256[](depositSet.length());

        for (uint256 i; i < depositSet.length(); i++) {
            tokenIds[i] = depositSet.at(i);
        }

        return tokenIds;
    }

    function totalStakes() public view returns (uint256 _totalStakes) {

        return nft.balanceOf(address(this));
    }

    function calculateRewards(address account, uint256[] memory tokenIds)
        public
        view
        returns (uint256[] memory rewards)
    {

        rewards = new uint256[](tokenIds.length);

        for (uint256 i; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            rewards[i] =
                rate *
                (_deposits[account].contains(tokenId) ? 1 : 0) *
                (block.number - _depositBlocks[account][tokenId]);
        }

        return rewards;
    }

    function calculateReward(address account, uint256 tokenId)
        public
        view
        returns (uint256)
    {

        require(
            block.number > _depositBlocks[account][tokenId],
            "Invalid blocks"
        );
        return
            rate *
            (_deposits[account].contains(tokenId) ? 1 : 0) *
            (block.number - _depositBlocks[account][tokenId]);
    }

    function calculateBlocks(address account, uint256 tokenId)
        public
        view
        returns (uint256)
    {

        return (block.number - _depositBlocks[account][tokenId]);
    }

    function claimRewards(uint256[] memory tokenIds) public whenNotPaused {

        uint256 reward;
        uint256 blockCur = block.number;

        for (uint256 i; i < tokenIds.length; i++) {
            reward += calculateReward(msg.sender, tokenIds[i]);
            _depositBlocks[msg.sender][tokenIds[i]] = blockCur;
        }

        if (reward > 0) {
            token.claim(msg.sender, reward);
        }
    }

    function claimTotalRewards() public {

        uint256[] memory v2TokenIds = depositsOf(msg.sender);
        claimRewards(v2TokenIds);
        claimV1Rewards();
    }

    function stake(uint256[] calldata tokenIds) external whenNotPaused {

        require(msg.sender != nftAddress, "Invalid address");
        require(
            nft.isApprovedForAll(msg.sender, address(this)),
            "This contract is not approved to transfer your NFT."
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                nft.ownerOf(tokenIds[i]) == msg.sender,
                "You do not own this NFT."
            );
        }

        claimRewards(tokenIds);
        for (uint256 i; i < tokenIds.length; i++) {
            IERC721(nftAddress).safeTransferFrom(
                msg.sender,
                address(this),
                tokenIds[i],
                ""
            );
            _deposits[msg.sender].add(tokenIds[i]);
        }
    }

    function unstake(uint256[] calldata tokenIds)
        external
        whenNotPaused
        nonReentrant
    {

        claimRewards(tokenIds);
        for (uint256 i; i < tokenIds.length; i++) {
            require(
                _deposits[msg.sender].contains(tokenIds[i]),
                "Staking: token not deposited"
            );
            _deposits[msg.sender].remove(tokenIds[i]);
            IERC721(nftAddress).safeTransferFrom(
                address(this),
                msg.sender,
                tokenIds[i],
                ""
            );
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

        return IERC721Receiver.onERC721Received.selector;
    }


    function setStartBlock(uint256 _startBlock) public onlyOwner {

        startBlock = _startBlock;
    }

    function setV1Rate(uint256 _v1Rate) public onlyOwner {

        v1Rate = _v1Rate;
    }

    function setV1RatePostV2(uint256 _v1RatePost) public onlyOwner {

        v1RatePost = _v1RatePost;
    }

    function flipStakingV1State() public onlyOwner {

        stakingV1IsActive = !stakingV1IsActive;
    }

    function calculateStakingBlocksV1(address _address)
        public
        view
        returns (uint256 _blocks)
    {

        require(stakingV1IsActive, "Staking V1 is deprecated");
        uint256 blocks;
        uint256 blockCur = block.number;
        if (hasClaimedDrop[_address] == false) {
            blocks = blockCur - startBlock;
        } else {
            blocks = blockCur - v1Timestamp[_address];
        }
        return blocks;
    }

    function calculateV1Rewards(address _address)
        public
        view
        returns (uint256 v1Rewards)
    {

        require(stakingV1IsActive, "Staking V1 is deprecated");
        uint256 rewards;
        uint256 blockCur = block.number;
        if (hasClaimedDrop[_address] == false) {
            rewards = (v1Rate * (blockCur - startBlock)).mul(
                stakedV1.stakeOf(_address).length
            );
        } else {
            rewards = (v1RatePost * (blockCur - v1Timestamp[_address])).mul(
                stakedV1.stakeOf(_address).length
            );
        }
        return rewards;
    }

    function numberStakedV1(address _address)
        public
        view
        returns (uint256 _numberStaked)
    {

        require(stakingV1IsActive, "Staking V1 is deprecated");
        return stakedV1.stakeOf(_address).length;
    }

    function claimV1Rewards() public whenNotPaused {

        require(stakingV1IsActive, "Staking V1 is deprecated");
        uint256 blockCur = block.number;
        if (hasClaimedDrop[msg.sender] == false) {
            token.claim(msg.sender, calculateV1Rewards(msg.sender));
            v1Timestamp[msg.sender] = blockCur;
            hasClaimedDrop[msg.sender] = true;
        } else {
            token.claim(msg.sender, calculateV1Rewards(msg.sender));
            v1Timestamp[msg.sender] = blockCur;
        }
    }

    function withdraw() external onlyOwner {

        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}