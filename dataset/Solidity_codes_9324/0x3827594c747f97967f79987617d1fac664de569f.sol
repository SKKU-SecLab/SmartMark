
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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
}// contracts/Pond.sol
pragma solidity ^0.8.0;


interface IFrogGame {

    function transferFrom(address from, address to, uint tokenId) external;

}
interface ITadpole {

    function updateOriginActionBlockTime() external;

    function mintTo(address recepient, uint amount) external;

    function transfer(address to, uint amount) external;

} 

contract Pond is IERC721Receiver, ReentrancyGuard, Pausable {

    uint typeShift = 69000;

    bytes32 entropySauce;
    address constant nullAddress = address(0x0);

    uint constant public tadpolePerDay = 10000 ether;
    uint constant public tadpoleMax = 2000000000 ether;
    
    uint internal _tadpoleClaimed;
    uint snakeReward;

    uint randomNounce=0;

    address public owner;
    IFrogGame internal frogGameContract;
    ITadpole internal tadpoleContract;

    uint[] internal snakesStaked;
    uint[] internal frogsStaked;

    uint internal _snakeTaxesCollected;
    uint internal _snakeTaxesPaid;

    bool public evacuationStarted;

    mapping(uint => address) stakedIdToStaker;
    mapping(address => uint[]) stakerToIds;
    mapping(uint => uint) stakedIdToLastClaimTimestamp;
    mapping(uint => uint[2]) stakedIdsToIndicies;
    mapping(uint => uint) stakedSnakeToRewardPaid;
    mapping(address => uint) callerToLastActionBlock;

    constructor() {
        owner=msg.sender;
    }


    function stakeToPond(uint[] calldata tokenIds) external noCheaters nonReentrant whenNotPaused {

        for (uint i=0;i<tokenIds.length;i++) {
            if (tokenIds[i]==0) { continue; }
            uint tokenId = tokenIds[i];

            stakedIdToStaker[tokenId] = msg.sender;
            stakedIdToLastClaimTimestamp[tokenId] = block.timestamp;
            
            uint stakerToIdsIndex = stakerToIds[msg.sender].length;
            stakerToIds[msg.sender].push(tokenId);

            uint stakedIndex;
            if (tokenId > typeShift)  {
                stakedSnakeToRewardPaid[tokenId]=snakeReward;
                stakedIndex=snakesStaked.length;
                snakesStaked.push(tokenId);
            } else {
                stakedIndex = frogsStaked.length;
                frogsStaked.push(tokenId);
            }
            stakedIdsToIndicies[tokenId]=[stakerToIdsIndex, stakedIndex];
            frogGameContract.transferFrom(msg.sender, address(this), tokenId);  
        }
    }

    function _claimById(uint tokenId, bool unstake) internal {

        address staker = stakedIdToStaker[tokenId];
        require(staker!=nullAddress, "Token is not staked");
        require(staker==msg.sender, "You're not the staker");

        uint[2] memory indicies = stakedIdsToIndicies[tokenId];
        uint rewards;

        if (unstake) {
            stakedIdToStaker[tokenId] = nullAddress;
            stakerToIds[msg.sender][indicies[0]] = stakerToIds[msg.sender][stakerToIds[msg.sender].length-1];
            stakedIdsToIndicies[stakerToIds[msg.sender][stakerToIds[msg.sender].length-1]][0] = indicies[0];
            stakerToIds[msg.sender].pop();
        }

        if (tokenId > typeShift) {
            rewards=snakeReward-stakedSnakeToRewardPaid[tokenId];
            _snakeTaxesPaid+=rewards;
            stakedSnakeToRewardPaid[tokenId]=snakeReward;

            if (unstake) {
                stakedIdsToIndicies[snakesStaked[snakesStaked.length-1]][1]=indicies[1];
                snakesStaked[indicies[1]]=snakesStaked[snakesStaked.length-1];
                snakesStaked.pop();
            }
        } else {
            uint taxPercent = 20;
            uint tax;
            rewards = calculateRewardForFrogId(tokenId);
            _tadpoleClaimed += rewards;

            if (unstake) {
                if (_tadpoleClaimed < tadpoleMax) {
                    require(rewards >= 30000 ether, "3 days worth tadpole required to leave the Pond");
                }

                stakedIdsToIndicies[frogsStaked[frogsStaked.length-1]][1]=indicies[1];
                frogsStaked[indicies[1]]=frogsStaked[frogsStaked.length-1];
                frogsStaked.pop();

                uint stealRoll = _randomize(_rand(), "rewardStolen", (rewards + randomNounce++)) % 10000;
                if (stealRoll < 5000) {
                    taxPercent = 100;
                } 
            }
            if (snakesStaked.length>0)
            {
                tax = rewards * taxPercent / 100;
                _snakeTaxesCollected+=tax;
                rewards = rewards - tax;
                snakeReward += tax / snakesStaked.length;
            }
        }
        stakedIdToLastClaimTimestamp[tokenId]=block.timestamp;

        if (rewards > 0) { tadpoleContract.transfer(msg.sender, rewards); }
        callerToLastActionBlock[tx.origin] = block.number;
        tadpoleContract.updateOriginActionBlockTime();
        if (unstake) {
            frogGameContract.transferFrom(address(this),msg.sender,tokenId);
        }
    }

    function claimByIds(uint[] calldata tokenIds, bool unstake) external noCheaters nonReentrant whenNotPaused {

        uint length=tokenIds.length;
        for (uint i=length; i>0; i--) {
            _claimById(tokenIds[i-1], unstake);
        }
    }

    function claimAll(bool unstake) external noCheaters nonReentrant whenNotPaused {

        uint length=stakerToIds[msg.sender].length;
        for (uint i=length; i>0; i--) {
            _claimById(stakerToIds[msg.sender][i-1], unstake);
        }
    }


    function claimableById(uint tokenId) public view noSameBlockAsAction returns (uint) {

        uint reward;
        if (stakedIdToStaker[tokenId]==nullAddress) {return 0;}
        if (tokenId>typeShift) { 
            reward=snakeReward-stakedSnakeToRewardPaid[tokenId];
        }
        else {
            uint pre_reward = (block.timestamp-stakedIdToLastClaimTimestamp[tokenId])*(tadpolePerDay/86400);
            reward = _tadpoleClaimed + pre_reward > tadpoleMax?tadpoleMax-_tadpoleClaimed:pre_reward;
        }
        return reward;
    }

    function evacuate(uint[] calldata tokenIds) external noCheaters nonReentrant {

        for (uint i=0;i<tokenIds.length;i++) {
            address staker = stakedIdToStaker[tokenIds[i]];
            require(evacuationStarted, "There was no evacuation signal");
            require(staker!=nullAddress, "Token is not staked");
            require(staker==msg.sender, "You're not the staker");

            uint tokenId=tokenIds[i];

            uint[2] memory indicies = stakedIdsToIndicies[tokenId];

            stakedIdToStaker[tokenId] = nullAddress;
            stakerToIds[msg.sender][indicies[0]]=stakerToIds[msg.sender][stakerToIds[msg.sender].length-1];
            stakedIdsToIndicies[stakerToIds[msg.sender][stakerToIds[msg.sender].length-1]][0]=indicies[0];
            stakerToIds[msg.sender].pop();

            if (tokenId>typeShift) {
                stakedIdsToIndicies[snakesStaked[snakesStaked.length-1]][1]=indicies[1];
                snakesStaked[indicies[1]]=snakesStaked[snakesStaked.length-1];
                snakesStaked.pop();
            } else {
                stakedIdsToIndicies[frogsStaked[frogsStaked.length-1]][1]=indicies[1];
                frogsStaked[indicies[1]]=frogsStaked[frogsStaked.length-1];
                frogsStaked.pop();
            }

            frogGameContract.transferFrom(address(this), msg.sender, tokenId);
        }
    }

    function snakesInPond() external view noSameBlockAsAction returns(uint) {

        return snakesStaked.length;
    }
    
    function frogsInPond() external view noSameBlockAsAction returns(uint) {

        return frogsStaked.length;
    }

    function snakeTaxesCollected() external view noSameBlockAsAction returns(uint) {

        return _snakeTaxesCollected;
    }

    function snakeTaxesPaid() external view noSameBlockAsAction returns(uint) {

        return _snakeTaxesPaid;
    }

    function tadpoleClaimed() external view noSameBlockAsAction returns(uint) {

        return _tadpoleClaimed;
    }

    function stakedByAddress(address _wallet)
        public
        view
        noSameBlockAsAction
        returns (uint256[] memory)
    {

        return stakerToIds[_wallet];
    }

                                    

    function Pause() external onlyOwner {

        _pause();
    }

    function Unpause() external onlyOwner {

        _unpause();
    }

    function evacuationSwitch() external onlyOwner {

        evacuationStarted=!evacuationStarted;
    }

    function setTadpoleAddress(address _tadpoleAddress) external onlyOwner {

        tadpoleContract=ITadpole(_tadpoleAddress);
    }

    function setFrogGameAddress(address _frogGameAddress) external onlyOwner {

        frogGameContract=IFrogGame(_frogGameAddress);
    }
                         

    function _randomize(uint256 rand, string memory val, uint256 spicy) internal pure returns (uint256) {

        return uint256(keccak256(abi.encode(rand, val, spicy)));
    }

    function _rand() internal view returns (uint256) {

        return uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.difficulty, block.timestamp, entropySauce)));
    }

    function getRandomSnakeOwner() external returns(address) {

        require(msg.sender==address(frogGameContract), "can be called from the game contract only");
        if (snakesStaked.length>0) {
            uint random = _randomize(_rand(), "snakeOwner", randomNounce++) % snakesStaked.length; 
            return stakedIdToStaker[snakesStaked[random]];
        } else return nullAddress;
    }

    function calculateRewardForFrogId(uint tokenId) internal view returns(uint) {

        uint reward = (block.timestamp-stakedIdToLastClaimTimestamp[tokenId])*(tadpolePerDay/86400);
        return ((_tadpoleClaimed + reward > tadpoleMax) ? (tadpoleMax - _tadpoleClaimed) : reward);
    }

    function mintTadpolePool() external onlyOwner() {

        tadpoleContract.mintTo(address(this), 2000000000 ether);
    }
    

    modifier noCheaters() {

        uint256 size = 0;
        address acc = msg.sender;
        assembly { size := extcodesize(acc)}

        require(msg.sender == tx.origin , "you're trying to cheat!");
        require(size == 0,                "you're trying to cheat!");
        _;

        entropySauce = keccak256(abi.encodePacked(msg.sender, block.coinbase));
    }

    modifier onlyOwner() {

        require(owner == msg.sender, "Caller is not the owner");
        _;
    }

    modifier noSameBlockAsAction() {

        require(callerToLastActionBlock[tx.origin] < block.number, "Please try again on next block");
        _;
    }
    
    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

      require(from == address(0x0), "Cannot send tokens to Pond directly");
      return IERC721Receiver.onERC721Received.selector;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        owner = newOwner;
    }
}