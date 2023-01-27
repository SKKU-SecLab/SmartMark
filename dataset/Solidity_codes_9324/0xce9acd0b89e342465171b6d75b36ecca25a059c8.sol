


pragma solidity 0.8.7;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, 'SafeMath: division by zero');
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

        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, 'Address: insufficient balance');

        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, 'Address: low-level call failed');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), 'Address: call to non-contract');

        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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

contract Context {

    constructor()  {}

    function _msgSender() internal view returns (address payable) {

        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner  = _msgSender();
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

interface ITheApeProject {

    

    function getNFTBalance(address _owner) external view returns (uint256);


    function getNFTPrice() external view returns (uint256);


}
interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

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

}

contract StakingContract is Ownable {

    using SafeMath for uint256;

    address public rewardToken;
    address public nftAddress;
    
    
    uint256 public RewardTokenPerDay = 700 ether;

    struct StakingInfo {
        uint256 tokenId;
        uint256 startBlock;
    }

    mapping(address => StakingInfo[]) private userInfo;
    mapping(address => uint256[]) private stackingNfts;
    mapping(address => uint256) private rewards;
    event Stake(address indexed user, uint256 amount);
    event UnStake(address indexed user, uint256 amount);

    constructor(address _nftAddress, address _rewardTokenAddress) {
        require (_nftAddress != address(0), "NFT token can't be adress (0)");
        require (_rewardTokenAddress != address(0), "Reward token can't be adress (0)");

        nftAddress = _nftAddress;
        rewardToken = _rewardTokenAddress;
    }

    function changeRewardTokenAddress(address _rewardTokenAddress) public onlyOwner {

        rewardToken = _rewardTokenAddress;
    }

    function changeNFTAddress(address _nftAddress) public onlyOwner {

        nftAddress = _nftAddress;
    }

    function changeRewardTokenPerBlock(uint256 _rewardTokenPerBlock) public onlyOwner {

        RewardTokenPerDay = _rewardTokenPerBlock;
    }

    function contractBalance() public view returns(uint256){

        return IERC721(nftAddress).balanceOf(address(this));
    }

    function pendingReward(address _user, uint256 _tokenId) public view returns (uint256) {


        (bool _isStaked, uint256 _startBlock) = getStakingItemInfo(_user, _tokenId);
        if(!_isStaked) return 0;
        uint256 currentBlock = block.timestamp;
        uint256 rewardAmount = (currentBlock.sub(_startBlock)).mul(RewardTokenPerDay).div(86400);
        return rewardAmount;
    }

    function pendingTotalReward(address _user) public view returns(uint256) {

        uint256 pending = 0;
        for (uint256 i = 0; i < userInfo[_user].length; i++) {
            uint256 temp = pendingReward(_user, userInfo[_user][i].tokenId);
            pending = pending.add(temp);
        }
        return pending;
    }

    function stake(uint256[] memory tokenIds) public {

        for(uint256 i = 0; i < tokenIds.length; i++) {
            (bool _isStaked,) = getStakingItemInfo(msg.sender, tokenIds[i]);
            require(!_isStaked, "On of the nfts is already staked");
            require(IERC721(nftAddress).ownerOf(tokenIds[i]) == msg.sender, "You don't own the nft");
            stackingNfts[msg.sender].push(tokenIds[i]);
            StakingInfo memory info;
            info.tokenId = tokenIds[i];
            info.startBlock = block.timestamp;
            userInfo[msg.sender].push(info);
            IERC721(nftAddress).transferFrom(address(msg.sender), address(this), tokenIds[i]);
            emit Stake(msg.sender, 1);
        }
    }
    function nftsStakedByUser(address _user) public view returns(uint256[] memory){

        return stackingNfts[_user];
    }
    function rewardsOfUser(address _user) onlyOwner public view returns(uint256){

        return rewards[_user];
    }
    function numberOfNftsStacked(address _user) onlyOwner public view returns(uint256){

        return stackingNfts[_user].length;
    }
    function unstake(uint256[] memory tokenIds) public {

        uint256 pending = 0;
        for(uint256 i = 0; i < tokenIds.length; i++) {
            (bool _isStaked,) = getStakingItemInfo(msg.sender, tokenIds[i]);
            require(_isStaked, "Nft is not staked");
            require(IERC721(nftAddress).ownerOf(tokenIds[i]) == address(this), "NFT is not staked");
            uint256 temp = pendingReward(msg.sender, tokenIds[i]);
            pending = pending.add(temp);
            bool flag = false;
            for(uint256 j = 0 ; j < stackingNfts[msg.sender].length && flag == false; j ++)
            {
                if(stackingNfts[msg.sender][j] == tokenIds[i])
                    {
                        stackingNfts[msg.sender][j] = stackingNfts[msg.sender][stackingNfts[msg.sender].length - 1];
                        stackingNfts[msg.sender].pop();
                        flag = true;
                    }
            }
            require(flag, "Something went wrong");
            removeFromStakingInfo(tokenIds[i]);
            IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenIds[i]);
            emit UnStake(msg.sender, 1);
        }

        if(pending > 0) {
            IERC20(rewardToken).transfer(msg.sender, pending);
        }
    }

    function getStakingItemInfo(address _user, uint256 _tokenId) public view returns(bool _isStaked, uint256 _startBlock) {

        for(uint256 i = 0; i < userInfo[_user].length; i++) {
            if(userInfo[_user][i].tokenId == _tokenId) {
                _isStaked = true;
                _startBlock = userInfo[_user][i].startBlock;
                break;
            }
        }
    }

    function removeFromStakingInfo(uint256 tokenId) private {        

        for (uint256 i = 0; i < userInfo[msg.sender].length; i++) {
            if (userInfo[msg.sender][i].tokenId == tokenId) {
                userInfo[msg.sender][i] = userInfo[msg.sender][userInfo[msg.sender].length - 1];
                userInfo[msg.sender].pop();
                break;
            }
        }        
    }

    function claim() public {


        uint256 reward = pendingTotalReward(msg.sender);

        for (uint256 i = 0; i < userInfo[msg.sender].length; i++)
            {
                userInfo[msg.sender][i].startBlock = block.timestamp;

            }
        rewards[msg.sender] = rewards[msg.sender] + reward;
        IERC20(rewardToken).transfer(msg.sender, reward);
    }
}