



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}




pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
}




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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}




pragma solidity ^0.8.0;



abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}




pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}


pragma solidity ^0.8.2;







contract HeartbreakBearsNFTStaking is ERC1155Holder, Pausable, Ownable {

    IERC1155 private NFT;
    IERC20 private TOKEN;

    struct NftBundle {
        uint256[] tokenIds;
        uint256[] timestamps;
        uint256[] percentageBoost;
        bool isStaking;
    }

    mapping(address => NftBundle) private stakers;
    address[] private stakerList;
    uint256 public rate = 11574074074074;
    uint256 endTimestamp;
    bool hasEnded;

    constructor(address _nftAddress, address _tokenAddress) {
        NFT = IERC1155(_nftAddress);
        TOKEN = IERC20(_tokenAddress);
    }

    function percentageOf(uint256 pct, uint256 _number)
        public
        pure
        returns (uint256)
    {

        require(_number >= 10000, "Number is too small for calculation");
        uint256 bp = pct * 100;
        return (_number * bp) / 10000;
    }

    function endStaking() public onlyOwner {

        hasEnded = true;
        endTimestamp = block.timestamp;
    }

    function stakeIds(address _staker) public view returns (uint256[] memory) {

        return stakers[_staker].tokenIds;
    }

    function bonusRewards(address _staker)
        public
        view
        returns (uint256[] memory)
    {

        return stakers[_staker].percentageBoost;
    }

    function stakeTimestamps(address _staker)
        public
        view
        returns (uint256[] memory)
    {

        return stakers[_staker].timestamps;
    }

    function allowance() public view returns (uint256) {

        return TOKEN.balanceOf(address(this));
    }

    function stakeDuration(address _staker) public view returns (uint256) {

        uint256 startTime = stakers[_staker].timestamps[0];
        if (startTime > 0) {
            return block.timestamp - startTime;
        } else {
            return 0;
        }
    }

    function tokensAwarded(address _staker) public view returns (uint256) {

        NftBundle memory staker = stakers[_staker];
        uint256 totalReward;
        uint256 endTime;

        if (hasEnded) {
            endTime = endTimestamp;
        } else {
            endTime = block.timestamp;
        }

        for (uint256 i = 0; i < staker.tokenIds.length; i++) {
            uint256 _rate = rate +
                percentageOf(staker.percentageBoost[i], rate);
            totalReward += (_rate * (endTime - staker.timestamps[i]));
        }

        return totalReward;
    }

    function tokensRemaining() public view returns (uint256) {

        uint256 tokensSpent;
        for (uint256 i = 0; i < stakerList.length; i++) {
            tokensSpent += tokensAwarded(stakerList[i]);
        }
        return allowance() - tokensSpent;
    }

    function tokensAwardedForNFT(address _staker, uint256 tokenId)
        public
        view
        returns (uint256)
    {

        NftBundle memory staker = stakers[_staker];
        uint256 endTime;

        if (hasEnded) {
            endTime = endTimestamp;
        } else {
            endTime = block.timestamp;
        }

        for (uint256 i = 0; i < staker.tokenIds.length; i++) {
            if (staker.tokenIds[i] == tokenId) {
                uint256 _rate = rate +
                    percentageOf(staker.percentageBoost[i], rate);
                return (_rate * (endTime - staker.timestamps[i]));
            }
        }

        return 0;
    }

    function stakeBatch(uint256[] memory _tokenIds) public whenNotPaused {

        require(_tokenIds.length > 0, "Must stake at least 1 NFT");
        require(hasEnded == false, "Staking has ended");
        require(allowance() > 10 ether, "No more rewards left for staking");

        if (!stakers[msg.sender].isStaking) {
            stakerList.push(msg.sender);
        }

        uint256[] memory _values = new uint256[](_tokenIds.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            _values[i] = 1;
            stakers[msg.sender].tokenIds.push(_tokenIds[i]);
            stakers[msg.sender].timestamps.push(block.timestamp);

            uint256 pctBoost = 0;
            uint256 id = _tokenIds[i];
            if (id >= 1 && id <= 1888) {
                pctBoost += 3; // Add 3%
            }
            if (
                id == 1 ||
                id == 5 ||
                id == 9 ||
                id == 13 ||
                id == 17 ||
                id == 23 ||
                id == 24 ||
                id == 25 ||
                id == 26 ||
                id == 71 ||
                id == 532 ||
                id == 777 ||
                id == 1144 ||
                id == 1707 ||
                id == 1482 ||
                id == 3888
            ) {
                pctBoost += 5; // Add 5%
            }
            if (_tokenIds.length == 2) {
                pctBoost += 1; // Add 1%
            } else if (_tokenIds.length >= 3) {
                pctBoost += 2; // Add 2%
            }
            stakers[msg.sender].percentageBoost.push(pctBoost);
        }

        stakers[msg.sender].isStaking = true;

        NFT.safeBatchTransferFrom(
            msg.sender,
            address(this),
            _tokenIds,
            _values,
            ""
        );
    }

    function claimTokens() public whenNotPaused {

        
        uint256 reward = tokensAwarded(msg.sender);
        require(reward > 0, "No rewards available");
        require(reward <= allowance(), "Reward exceeds tokens available");
        uint256[] memory _tokenIds = stakeIds(msg.sender);

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            stakers[msg.sender].timestamps[i] = block.timestamp;
        }

        TOKEN.transfer(msg.sender, reward);

    }

    function withdraw() public whenNotPaused {

        uint256 reward = tokensAwarded(msg.sender);
        require(reward > 0, "No rewards available");
        require(reward <= allowance(), "Reward exceeds tokens available");
        uint256[] memory _tokenIds = stakeIds(msg.sender);
        uint256[] memory _values = new uint256[](_tokenIds.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            _values[i] = 1;
        }
        delete stakers[msg.sender];
        TOKEN.transfer(msg.sender, reward);
        NFT.safeBatchTransferFrom(
            address(this),
            msg.sender,
            _tokenIds,
            _values,
            ""
        );
    }

    function withdrawSelected(uint256[] memory _tokenIds) public whenNotPaused {

        uint256 reward;

        uint256[] memory _values = new uint256[](_tokenIds.length);
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            _values[i] = 1;
            reward += tokensAwardedForNFT(msg.sender, _tokenIds[i]);

            uint256 index = getIndexOf(
                _tokenIds[i],
                stakers[msg.sender].tokenIds
            );

            remove(index, stakers[msg.sender].tokenIds);
            remove(index, stakers[msg.sender].timestamps);
            remove(index, stakers[msg.sender].percentageBoost);
        }

        require(reward > 0, "No rewards available");
        require(reward <= allowance(), "Reward exceeds tokens available");

        if (stakers[msg.sender].tokenIds.length == 0) {
            delete stakers[msg.sender];
        }

        TOKEN.transfer(msg.sender, reward);
        NFT.safeBatchTransferFrom(
            address(this),
            msg.sender,
            _tokenIds,
            _values,
            ""
        );
    }

    function remove(uint256 index, uint256[] storage array) internal {

        if (index >= array.length) return;

        for (uint256 i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }
        array.pop();
    }

    function getIndexOf(uint256 item, uint256[] memory array)
        public
        pure
        returns (uint256)
    {

        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == item) {
                return i;
            }
        }
        revert("Token not found");
    }

    function sweep() public onlyOwner {

        TOKEN.transfer(msg.sender, TOKEN.balanceOf(address(this)));
    }
}


