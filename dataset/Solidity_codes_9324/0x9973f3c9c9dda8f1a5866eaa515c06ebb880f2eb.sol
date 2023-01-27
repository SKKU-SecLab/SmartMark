
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}
pragma solidity ^0.7.4;


interface Dung {

    function mint(address to, uint256 amount) external;

}

interface Creatures {

    enum AnimalType {
        Cow, Horse, Rabbit, Chicken, Pig, Cat, Dog, Goose, Goat, Sheep,
        Snake, Fish, Frog, Worm, Lama, Mouse, Camel, Donkey, Bee, Duck,
        GenesisEgg // 20
    }
    enum Rarity     {
        Normie, // 0
        Chad,   // 1
        Degen,  // 2
        Unique // 3
    }

    function animals(uint256 tokenId) external view returns (AnimalType atype,
        Rarity     rarity,
        uint32     index,
        uint64     birthday,
        string   memory  name);

    function ownerOf(uint256 tokenId) external view returns (address owner);

}

contract DungGathering {


    using SafeMath for uint256;

    uint public constant NORMIE_DUNG_PER_SEC =   465_000_000_000 ether;
    uint public constant CHAD_DUNG_PER_SEC   = 1_400_000_000_000 ether;
    uint public constant DEGEN_DUNG_PER_SEC  = 7_000_000_000_000 ether;

    mapping(uint => uint) public lastGatherTime;

    Creatures public creatures;
    Dung public dung;

    constructor (Creatures _creatures, Dung _dung) {
        creatures = _creatures;
        dung = _dung;
    }

    function gather(uint creatureId) external {

        address owner = creatures.ownerOf(creatureId);
        require(owner == msg.sender, "Wrong creature owner");
        uint unclaimedDung = getUnclaimedDung(creatureId);
        markCreatureAsClaimed(creatureId);

        dung.mint(msg.sender, unclaimedDung);
    }

    function gatherBatch(uint[] calldata creatureIds) external {

        uint unclaimedDung = 0;
        for (uint i = 0; i < creatureIds.length; i++) {
            uint creatureId = creatureIds[i];
            address owner = creatures.ownerOf(creatureId);
            require(owner == msg.sender, "Wrong creature owner");
            unclaimedDung = unclaimedDung.add(getUnclaimedDung(creatureId));
            markCreatureAsClaimed(creatureId);
        }
        dung.mint(msg.sender, unclaimedDung);
    }

    function markCreatureAsClaimed(uint creatureId) internal {

        lastGatherTime[creatureId] = block.timestamp;
    }

    function getUnclaimedDung(uint creatureId) public view returns (uint) {

        uint lastTime = lastGatherTime[creatureId];

        (, Creatures.Rarity rarity, , uint64 birthday,) = creatures.animals(creatureId);

        if (lastTime == 0) {
            if (birthday == 0) {
                return 0;
            }
            lastTime = birthday;
        }
        uint timeDelta = block.timestamp - lastTime;
        uint dung_reward_per_sec;

        if (rarity == Creatures.Rarity.Normie) dung_reward_per_sec = NORMIE_DUNG_PER_SEC;
        else if (rarity == Creatures.Rarity.Chad) dung_reward_per_sec = CHAD_DUNG_PER_SEC;
        else if (rarity == Creatures.Rarity.Degen) dung_reward_per_sec = DEGEN_DUNG_PER_SEC;
        else dung_reward_per_sec = 0;

        return dung_reward_per_sec.mul(timeDelta);
    }
}
