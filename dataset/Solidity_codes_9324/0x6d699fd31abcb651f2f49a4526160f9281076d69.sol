
pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


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
}

interface SmolTingPot {

    function withdraw(uint256 _pid, uint256 _amount, address _staker) external;

    function poolLength() external view returns (uint256);

    function pendingTing(uint256 _pid, address _user) external view returns (uint256);

}

interface SmolStudio {

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;

    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;

    function setApprovalForAll(address _operator, bool _approved) external;

    function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);

    function balanceOf(address _owner, uint256 _id) external view returns (uint256);

}

interface SmolTing {

    function totalSupply() external view returns (uint256);

    function totalClaimed() external view returns (uint256);

    function addClaimed(uint256 _amount) external;

    function setClaimed(uint256 _amount) external;

    function transfer(address receiver, uint numTokens) external returns (bool);

    function transferFrom(address owner, address buyer, uint numTokens) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function mint(address _to, uint256 _amount) external;

    function burn(address _account, uint256 value) external;

}

interface TingBooster {

    function getMultiplierOfAddress(address _addr) external view returns (uint256);

}

contract SmolMuseum is Ownable {

    using SafeMath for uint256;

    struct CardSet {
        uint256[] cardIds;
        uint256 tingPerDayPerCard;
        uint256 bonusTingMultiplier;     	// 100% bonus = 1e5
        bool isBooster;                   	// False if the card set doesn't give pool boost at smolTingPot
        uint256[] poolBoosts;            	// 100% bonus = 1e5. Applicable if isBooster is true.Eg: [0,20000] = 0% boost for pool 1, 20% boost for pool 2
        uint256 bonusFullSetBoost;          // 100% bonus = 1e5. Gives an additional boost if you stake all boosters of that set.
        bool isRemoved;
    }

    SmolStudio public smolStudio;
    SmolTing public ting;
    TingBooster public tingBooster;
    SmolTingPot public smolTingPot;
    address public treasuryAddr;

    uint256[] public cardSetList;
    uint256 public highestCardId;
    mapping (uint256 => CardSet) public cardSets;
    mapping (uint256 => uint256) public cardToSetMap;
    mapping (address => mapping(uint256 => bool)) public userCards;
    mapping (address => uint256) public userLastUpdate;

    event Stake(address indexed user, uint256[] cardIds);
    event Unstake(address indexed user, uint256[] cardIds);
    event Harvest(address indexed user, uint256 amount);

    constructor(SmolTingPot _smolTingPotAddr, SmolStudio _smolStudioAddr, SmolTing _tingAddr, TingBooster _tingBoosterAddr, address _treasuryAddr) public {
        smolTingPot = _smolTingPotAddr;
        smolStudio = _smolStudioAddr;
        ting = _tingAddr;
        tingBooster = _tingBoosterAddr;
        treasuryAddr = _treasuryAddr;
    }

    function _isInArray(uint256 _value, uint256[] memory _array) internal pure returns(bool) {

        uint256 length = _array.length;
        for (uint256 i = 0; i < length; ++i) {
            if (_array[i] == _value) {
                return true;
            }
        }
        return false;
    }

    function getCardsStakedOfAddress(address _user) public view returns(bool[] memory) {

        bool[] memory cardsStaked = new bool[](highestCardId + 1);
        for (uint256 i = 0; i < highestCardId + 1; ++i) {			
            cardsStaked[i] = userCards[_user][i];
        }
        return cardsStaked;
    }
    
    function getCardIdListOfSet(uint256 _setId) external view returns(uint256[] memory) {

        return cardSets[_setId].cardIds;
    }
    
    function getBoostersOfCard(uint256 _cardId) external view returns(uint256[] memory) {

        return cardSets[cardToSetMap[_cardId]].poolBoosts;
    }
	
    function getFullSetsOfAddress(address _user) public view returns(bool[] memory) {

        uint256 length = cardSetList.length;
        bool[] memory isFullSet = new bool[](length);
        for (uint256 i = 0; i < length; ++i) {
            uint256 setId = cardSetList[i];
            if (cardSets[setId].isRemoved) {
                isFullSet[i] = false;
                continue;
            }
            bool _fullSet = true;
            uint256[] memory _cardIds = cardSets[setId].cardIds;
			
            for (uint256 j = 0; j < _cardIds.length; ++j) {
                if (userCards[_user][_cardIds[j]] == false) {
                    _fullSet = false;
                    break;
                }
            }
            isFullSet[i] = _fullSet;
        }
        return isFullSet;
    }

    function getNumOfNftsStakedForSet(address _user, uint256 _setId) public view returns(uint256) {

        uint256 nbStaked = 0;
        if (cardSets[_setId].isRemoved) return 0;
        uint256 length = cardSets[_setId].cardIds.length;
        for (uint256 j = 0; j < length; ++j) {
            uint256 cardId = cardSets[_setId].cardIds[j];
            if (userCards[_user][cardId] == true) {
                nbStaked = nbStaked.add(1);
            }
        }
        return nbStaked;
    }

    function getNumOfNftsStakedByAddress(address _user) public view returns(uint256) {

        uint256 nbStaked = 0;
        for (uint256 i = 0; i < cardSetList.length; ++i) {
            nbStaked = nbStaked.add(getNumOfNftsStakedForSet(_user, cardSetList[i]));
        }
        return nbStaked;
    }
    
    function totalPendingTingOfAddress(address _user, bool _includeTingBooster) public view returns (uint256) {

        uint256 totalTingPerDay = 0;
        uint256 length = cardSetList.length;
        for (uint256 i = 0; i < length; ++i) {
            uint256 setId = cardSetList[i];
            CardSet storage set = cardSets[setId];
            if (set.isRemoved) continue;
            uint256 cardLength = set.cardIds.length;
            bool isFullSet = true;
            uint256 setTingPerDay = 0;
            for (uint256 j = 0; j < cardLength; ++j) {
                if (userCards[_user][set.cardIds[j]] == false) {
                    isFullSet = false;
                    continue;
                }
                setTingPerDay = setTingPerDay.add(set.tingPerDayPerCard);
            }
            if (isFullSet) {
                setTingPerDay = setTingPerDay.mul(set.bonusTingMultiplier).div(1e5);
            }
            totalTingPerDay = totalTingPerDay.add(setTingPerDay);
        }

        if (_includeTingBooster) {
			uint256 boostMult = tingBooster.getMultiplierOfAddress(_user).add(1e5);
            totalTingPerDay = totalTingPerDay.mul(boostMult).div(1e5);
        }
        uint256 lastUpdate = userLastUpdate[_user];
        uint256 blockTime = block.timestamp;
        return blockTime.sub(lastUpdate).mul(totalTingPerDay.div(86400));
    }

    function totalPendingTingOfAddressFromBooster(address _user) external view returns (uint256) {

        uint256 totalPending = totalPendingTingOfAddress(_user, false);
		uint256 userBoost = tingBooster.getMultiplierOfAddress(_user).add(1e5);
        return totalPending.mul(userBoost).div(1e5);
    }
    
    function getBoosterForUser(address _user, uint256 _pid) public view returns (uint256) {

        uint256 totalBooster = 0;
        uint256 length = cardSetList.length;
        for (uint256 i = 0; i < length; ++i) {
            uint256 setId = cardSetList[i];
            CardSet storage set = cardSets[setId];
            if (set.isBooster == false) continue;
            if (set.poolBoosts.length < _pid.add(1)) continue;
            if (set.poolBoosts[_pid] == 0) continue;
            uint256 cardLength = set.cardIds.length;
            bool isFullSet = true;
            uint256 setBooster = 0;
            for (uint256 j = 0; j < cardLength; ++j) {
                if (userCards[_user][set.cardIds[j]] == false) {
                    isFullSet = false;
                    continue;
                }
                setBooster = setBooster.add(set.poolBoosts[_pid]);
            }
            if (isFullSet) {
                setBooster = setBooster.add(set.bonusFullSetBoost);
            }
            totalBooster = totalBooster.add(setBooster);
        }
        return totalBooster;
    }

    function setHighestCardId(uint256 _highestId) public onlyOwner {

        require(_highestId > 0, "Set if minimum 1 card is staked.");
        highestCardId = _highestId;
    }

    function addCardSet(uint256 _setId, uint256[] memory _cardIds, uint256 _bonusTingMultiplier, uint256 _tingPerDayPerCard, uint256[] memory _poolBoosts, uint256 _bonusFullSetBoost, bool _isBooster) public onlyOwner {

        removeCardSet(_setId);
        uint256 length = _cardIds.length;
        for (uint256 i = 0; i < length; ++i) {
            uint256 cardId = _cardIds[i];
            if (cardId > highestCardId) {
                highestCardId = cardId;
            }
            require(cardToSetMap[cardId] == 0, "Card already assigned to a set");
            cardToSetMap[cardId] = _setId;
        }
        if (_isInArray(_setId, cardSetList) == false) {
            cardSetList.push(_setId);
        }
        cardSets[_setId] = CardSet({
        cardIds: _cardIds,
        bonusTingMultiplier: _bonusTingMultiplier,
        tingPerDayPerCard: _tingPerDayPerCard,
        isBooster: _isBooster,
        poolBoosts: _poolBoosts,
        bonusFullSetBoost: _bonusFullSetBoost,
        isRemoved: false
        });
    }

    function setTingRateOfSets(uint256[] memory _setIds, uint256[] memory _tingPerDayPerCard) public onlyOwner {

        require(_setIds.length == _tingPerDayPerCard.length, "_setId and _tingPerDayPerCard have different length");
        for (uint256 i = 0; i < _setIds.length; ++i) {
            require(cardSets[_setIds[i]].cardIds.length > 0, "Set is empty");
            cardSets[_setIds[i]].tingPerDayPerCard = _tingPerDayPerCard[i];
        }
    }

    function setBonusTingMultiplierOfSets(uint256[] memory _setIds, uint256[] memory _bonusTingMultiplier) public onlyOwner {

        require(_setIds.length == _bonusTingMultiplier.length, "_setId and _tingPerDayPerCard have different length");
        for (uint256 i = 0; i < _setIds.length; ++i) {
            require(cardSets[_setIds[i]].cardIds.length > 0, "Set is empty");
            cardSets[_setIds[i]].bonusTingMultiplier = _bonusTingMultiplier[i];
        }
    }

    function removeCardSet(uint256 _setId) public onlyOwner {

        uint256 length = cardSets[_setId].cardIds.length;
        for (uint256 i = 0; i < length; ++i) {
            uint256 cardId = cardSets[_setId].cardIds[i];
            cardToSetMap[cardId] = 0;
        }
        delete cardSets[_setId].cardIds;
        cardSets[_setId].isRemoved = true;
        cardSets[_setId].isBooster = false;
    }

    function harvest() public {

        uint256 pendingTing = totalPendingTingOfAddress(msg.sender, true);
        userLastUpdate[msg.sender] = block.timestamp;
        if (pendingTing > 0) {
            ting.mint(treasuryAddr, pendingTing.div(40)); // 2.5% TING for the treasury (Usable to purchase NFTs)
            ting.mint(msg.sender, pendingTing);
            ting.addClaimed(pendingTing);
        }
        emit Harvest(msg.sender, pendingTing);
    }

    function stake(uint256[] memory _cardIds) public {

        require(_cardIds.length > 0, "you need to stake something");

        uint256 length = _cardIds.length;
        bool onlyBoosters = true;
        bool onlyNoBoosters = true;
        for (uint256 i = 0; i < length; ++i) {
            uint256 cardId = _cardIds[i];
            require(userCards[msg.sender][cardId] == false, "item already staked");
            require(cardToSetMap[cardId] != 0, "you can't stake that");
            if (cardSets[cardToSetMap[cardId]].tingPerDayPerCard > 0) onlyBoosters = false;
            if (cardSets[cardToSetMap[cardId]].isBooster == true) onlyNoBoosters = false;
        }
        if (onlyBoosters == false) harvest();
        
        if (onlyNoBoosters == false) {
            for (uint256 i = 0; i < length; ++i) {                                                                  
                uint256 cardId = _cardIds[i];
                if (cardSets[cardToSetMap[cardId]].isBooster) {
                    CardSet storage cardSet = cardSets[cardToSetMap[cardId]];
                    uint256 boostLength = cardSet.poolBoosts.length;
                    for (uint256 j = 0; j < boostLength; ++j) {                                                     
                        if (cardSet.poolBoosts[j] > 0 && smolTingPot.pendingTing(j, msg.sender) > 0) {
                            address staker = msg.sender;
                            smolTingPot.withdraw(j, 0, staker);   
                        }
                    }
                }
            }
        }
        
        uint256[] memory amounts = new uint256[](_cardIds.length);
        for (uint256 i = 0; i < _cardIds.length; ++i) {
            amounts[i] = 1;
        }
        smolStudio.safeBatchTransferFrom(msg.sender, address(this), _cardIds, amounts, "");
        for (uint256 i = 0; i < length; ++i) {
            uint256 cardId = _cardIds[i];
            userCards[msg.sender][cardId] = true;
        }
        emit Stake(msg.sender, _cardIds);
    }

    function unstake(uint256[] memory _cardIds) public {

 
         require(_cardIds.length > 0, "input at least 1 card id");

        uint256 length = _cardIds.length;
        bool onlyBoosters = true;
        bool onlyNoBoosters = true;
        for (uint256 i = 0; i < length; ++i) {
            uint256 cardId = _cardIds[i];
            require(userCards[msg.sender][cardId] == true, "Card not staked");
            userCards[msg.sender][cardId] = false;
            if (cardSets[cardToSetMap[cardId]].tingPerDayPerCard > 0) onlyBoosters = false;
            if (cardSets[cardToSetMap[cardId]].isBooster == true) onlyNoBoosters = false;
        }
        
        if (onlyBoosters == false) harvest();

        if (onlyNoBoosters == false) {
            for (uint256 i = 0; i < length; ++i) {                                                                  
                uint256 cardId = _cardIds[i];
                if (cardSets[cardToSetMap[cardId]].isBooster) {
                    CardSet storage cardSet = cardSets[cardToSetMap[cardId]];
                    uint256 boostLength = cardSet.poolBoosts.length;
                    for (uint256 j = 0; j < boostLength; ++j) {                                                     
                        if (cardSet.poolBoosts[j] > 0 && smolTingPot.pendingTing(j, msg.sender) > 0) {
                            address staker = msg.sender;
                            smolTingPot.withdraw(j, 0, staker);   
                        }
                    }
                }
            }
        }

        uint256[] memory amounts = new uint256[](_cardIds.length);
        for (uint256 i = 0; i < _cardIds.length; ++i) {
            amounts[i] = 1;
        }
        smolStudio.safeBatchTransferFrom(address(this), msg.sender, _cardIds, amounts, "");
        emit Unstake(msg.sender, _cardIds);
    }

    function emergencyUnstake(uint256[] memory _cardIds) public {

        userLastUpdate[msg.sender] = block.timestamp;
        uint256 length = _cardIds.length;
        for (uint256 i = 0; i < length; ++i) {
            uint256 cardId = _cardIds[i];
            require(userCards[msg.sender][cardId] == true, "Card not staked");
            userCards[msg.sender][cardId] = false;
        }

        uint256[] memory amounts = new uint256[](_cardIds.length);
        for (uint256 i = 0; i < _cardIds.length; ++i) {
            amounts[i] = 1;
        }
        smolStudio.safeBatchTransferFrom(address(this), msg.sender, _cardIds, amounts, "");
    }
    
    function updateTingBoosterAddress(TingBooster _tingBoosterAddress) public onlyOwner{

        tingBooster = _tingBoosterAddress;
    }
	
    function updateSmolTingPotAddress(SmolTingPot _smolTingPotAddress) public onlyOwner{

        smolTingPot = _smolTingPotAddress;
    }
    
    function treasury(address _treasuryAddr) public {

        require(msg.sender == treasuryAddr, "Only current treasury address can update.");
        treasuryAddr = _treasuryAddr;
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _amount, bytes calldata _data) external returns(bytes4) {

        return 0xf23a6e61;
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external returns(bytes4) {

        return 0xbc197c81;
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool) {

        return  interfaceID == 0x01ffc9a7 ||    // ERC-165 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
        interfaceID == 0x4e2312e0;      // ERC-1155 `ERC1155TokenReceiver` support (i.e. `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")) ^ bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
    }
}