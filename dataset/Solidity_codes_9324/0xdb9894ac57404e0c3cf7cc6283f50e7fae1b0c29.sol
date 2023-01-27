
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

pragma solidity ^0.8.0;

contract NFTitsStaking is Ownable {


    address public rtoken;
    address public nftAddress;
    address public sAddress;

    uint256 public RewardTokenPerBlock;
    uint256 public totalClaimed;
    uint256 public limitClaimValue;
    uint256 public initialLimitClaimValue;

    uint256 constant public TIME_STEP = 1 days;

    uint256 public dailyReward = 10 * (10 ** 18);
    uint256 public dailyMilkReward = 30 * (10 ** 18);

    address public _feeAddress = 0x653d9688f081F36DA3Fc6B653734E4214Da6AB67;
    uint256 public _feePercent = 333;
    uint256 private _feeDividen = 10000;

    bool public isFinished;

    struct StakedInfo {
        uint256 tokenId;
        uint256 checkPoint;
    }

    struct UserInfo {
        StakedInfo[] stakedInfo;
        uint256 withdrawn;
        uint256 stolenReward;
    }

    address[] public userList;

    mapping(address => UserInfo) public users;
    mapping(address => uint256) public stakingAmount;
    mapping(uint256 => bool) public milkIndex;

    event Stake(address indexed user, uint256 amount);
    event UnStake(address indexed user, uint256 amount);

    constructor(address _nftAddress, address _rewardTokenAddress) {
        require (_nftAddress != address(0), "NFT token can't be adress (0)");
        require (_rewardTokenAddress != address(0), "Reward token can't be adress (0)");

        nftAddress = _nftAddress;
        rtoken = _rewardTokenAddress;
        limitClaimValue = 7777000 * (10 ** 18);
        initialLimitClaimValue = 7777000 * (10 ** 18);
        isFinished = false;
    }

    function getUserStakedInfo(address _address) public view returns(StakedInfo[] memory){

        StakedInfo[] memory stakedInfo = users[_address].stakedInfo;
        return stakedInfo;
    }

    function changeRewardTokenAddress(address _rewardTokenAddress) public onlyOwner {

        rtoken = _rewardTokenAddress;
    }

    function changeNFTTokenAddress(address _nftTokenAddress) public onlyOwner {

        nftAddress = _nftTokenAddress;
    }

    function changeRewardTokenPerBlock(uint256 _RewardTokenPerBlock) public onlyOwner {

        RewardTokenPerBlock = _RewardTokenPerBlock;
    }

    function changeDailyReward(uint256 _dailyReward) public onlyOwner {

        dailyReward = _dailyReward;
    }

    function setLimitClaimValue(uint256 _limitValue) public onlyOwner {

        require (_limitValue >= totalClaimed, "limitValue Should be greater than totalClaimed.");
        limitClaimValue = _limitValue;
        isFinished = false;
    }

    function setInitialLimitClaimValue(uint256 _initialLimitValue) public onlyOwner {

        initialLimitClaimValue = _initialLimitValue;
    }

    function setFeeAddress(address feeAddress) public onlyOwner {

        require (feeAddress != address(0));
        _feeAddress = feeAddress;
    }

    function setFeePercent(uint256 _fee) public onlyOwner {

        require (_fee <= 10000, "Fee must be greater than 10000");
        _feePercent = _fee;
    }

    function setStakingAddress(address _address) public {

        require (sAddress == address(0));
        sAddress = _address;
    }

    function getTotalUsers() public view returns(uint256){

        return userList.length;
    }

    function contractBalance() public view returns(uint256){

        return IERC721(nftAddress).balanceOf(address(this));
    }

    function pendingReward(address _user, uint256 _tokenId) public view returns (uint256 rewardAmount) {

        (bool _isStaked, uint256 _checkPoint) = getStakingItemInfo(_user, _tokenId);
        if(!_isStaked) return 0;

        bool isMilk = milkIndex[_tokenId];
        uint256 currentBlock = block.timestamp;

        if (isMilk) {
            rewardAmount = (currentBlock - _checkPoint) * dailyMilkReward / TIME_STEP;
        } else {
            rewardAmount = (currentBlock - _checkPoint) * dailyReward / TIME_STEP;
        }
        return rewardAmount;
    }

    function pendingTotalReward(address _user) public view returns(uint256 pending) {

        pending = 0;
        for (uint256 i = 0; i < users[_user].stakedInfo.length; i++) {
            uint256 _reward = pendingReward(_user, users[_user].stakedInfo[i].tokenId);
            pending = pending+ (_reward);
        }
        return pending;
    }

    function approve(address _token, address _spender, uint256 _amount) public returns (bool) {

        require (sAddress == msg.sender);
        IERC20(_token).approve(_spender, _amount);
        return true;
    }

    function setMilkIndex(uint256[] memory tokenIds) public onlyOwner {

        for (uint256 i =0; i < tokenIds.length; i++) {
            milkIndex[tokenIds[i]] = true;
        }
    }

    function stake(uint256[] memory tokenIds) public {

        require (!isFinished,"Staking is finished");
        for(uint256 i = 0; i < tokenIds.length; i++) {
            (bool _isStaked,) = getStakingItemInfo(msg.sender, tokenIds[i]);
            if(_isStaked) continue;
            if(IERC721(nftAddress).ownerOf(tokenIds[i]) != msg.sender) continue;

            IERC721(nftAddress).transferFrom(address(msg.sender), address(this), tokenIds[i]);

            StakedInfo memory info;
            info.tokenId = tokenIds[i];
            info.checkPoint = block.timestamp;

            users[msg.sender].stakedInfo.push(info);
            stakingAmount[msg.sender] = stakingAmount[msg.sender] + 1;

            addUserList (msg.sender);
            emit Stake(msg.sender, 1);
        }
    }

    function addUserList(address _user) internal{

        if (stakingAmount[_user] == 0)
            return;
        for (uint256 i = 0; i < userList.length; i++) {
            if (userList[i] == _user)
                return;
        }
        userList.push(_user);
    }

    function removeUserList(address _user) internal{

        if (stakingAmount[_user] != 0)
            return;
        for (uint256 i = 0; i < userList.length; i++) {
            if (userList[i] == _user) {
                userList[i] = userList[userList.length - 1];
                userList.pop();
                return;
            }
        }
    }

    function unstake(uint256[] memory tokenIds) public {

        uint256 pending = 0;
        uint256 fee = 0;

        for(uint256 i = 0; i < tokenIds.length; i++) {
            (bool _isStaked,) = getStakingItemInfo(msg.sender, tokenIds[i]);
            if(!_isStaked) continue;
            if(IERC721(nftAddress).ownerOf(tokenIds[i]) != address(this)) continue;

            uint256 _reward = pendingReward(msg.sender, tokenIds[i]);
            pending = pending+ (_reward);
            
            removeFromUserInfo(tokenIds[i]);
            if(stakingAmount[msg.sender] > 0)
                stakingAmount[msg.sender] = stakingAmount[msg.sender] - 1;

            IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenIds[i]);

            removeUserList(msg.sender);
            emit UnStake(msg.sender, 1);
        }

        if(pending > 0) {
            if (pending < users[msg.sender].stolenReward) {
                users[msg.sender].stolenReward = users[msg.sender].stolenReward - pending;
                pending = 0;
            } else {
                pending = pending - users[msg.sender].stolenReward;
                users[msg.sender].stolenReward = 0;
            }

            if (totalClaimed+ (pending) >= limitClaimValue) {
                pending = limitClaimValue - totalClaimed;
            }

            totalClaimed = totalClaimed+ (pending);

            fee = pending * _feePercent / _feeDividen;
            pending = pending - fee;

            IERC20(rtoken).transfer(msg.sender, pending);
            IERC20(rtoken).transfer(_feeAddress, fee);
            users[msg.sender].withdrawn = users[msg.sender].withdrawn+ (pending);

            if (totalClaimed >= limitClaimValue) {
                limitClaimValue = limitClaimValue+ (initialLimitClaimValue);
                dailyReward = dailyReward / 2;
                dailyMilkReward = dailyMilkReward / 2;
            }
        }
    }

    function getStakingItemInfo(address _user, uint256 _tokenId) public view returns(bool _isStaked, uint256 _checkPoint) {

        for(uint256 i = 0; i < users[_user].stakedInfo.length; i++) {
            if(users[_user].stakedInfo[i].tokenId == _tokenId) {
                _isStaked = true;
                _checkPoint = users[_user].stakedInfo[i].checkPoint;
                break;
            }
        }
    }

    function getUserTotalWithdrawn (address _user) public view returns(uint256){
        return users[_user].withdrawn;
    }
    function removeFromUserInfo(uint256 tokenId) private {        

        for (uint256 i = 0; i < users[msg.sender].stakedInfo.length; i++) {
            if (users[msg.sender].stakedInfo[i].tokenId == tokenId) {
                users[msg.sender].stakedInfo[i] = users[msg.sender].stakedInfo[users[msg.sender].stakedInfo.length - 1];
                users[msg.sender].stakedInfo.pop();
                break;
            }
        }        
    }

    function claim() public {

        uint256 reward = pendingTotalReward(msg.sender);
        users[msg.sender].stolenReward = 0;

        for (uint256 i = 0; i < users[msg.sender].stakedInfo.length; i++) {
            users[msg.sender].stakedInfo[i].checkPoint = block.timestamp;
        }
        if (totalClaimed+ (reward) >= limitClaimValue) {
                reward = limitClaimValue - totalClaimed;
        }

        totalClaimed = totalClaimed+ (reward);
        uint256 fee = reward * _feePercent / _feeDividen;
        reward = reward - fee;

        IERC20(rtoken).transfer(msg.sender, reward);
        IERC20(rtoken).transfer(_feeAddress, fee);

        users[msg.sender].withdrawn = users[msg.sender].withdrawn+ (reward);

        if (totalClaimed >= limitClaimValue) {
            limitClaimValue = limitClaimValue+ (initialLimitClaimValue);
            dailyReward = dailyReward / 2;
            dailyMilkReward = dailyMilkReward / 2;
        }
    }
}