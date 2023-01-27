
pragma solidity 0.8.4;

interface Rocketeer {

    function totalSupply () external view returns ( uint256 );
    function balanceOf ( address owner ) external view returns ( uint256 );
    function spawnRocketeer ( address _to ) external;
    function tokenOfOwnerByIndex ( address owner, uint256 index ) external view returns ( uint256 );
}

contract RocketeerHelper {


    Rocketeer constant rocketeer = Rocketeer(0xb3767b2033CF24334095DC82029dbF0E9528039d);

    function spawnOne(bool spawn_for_devs) external {

        bool next_is_42nd = rocketeer.totalSupply() % 42 == 41;
        if (next_is_42nd == spawn_for_devs) {
            rocketeer.spawnRocketeer(msg.sender);
        }
    }

    function spawnMany(uint amount) public {

        for (uint i = 0; i < amount; i++) {
            rocketeer.spawnRocketeer(msg.sender);
        }
    }

    function spawnManyLimited(uint max_amount) external {

        uint avail = 41 - rocketeer.totalSupply() % 42;
        spawnMany(max_amount > avail ? avail : max_amount);
    }

    function spawnUntil42(bool spawn_for_devs) external {

        spawnMany((spawn_for_devs ? 42 : 41) - rocketeer.totalSupply() % 42);
    }

    function spawnUntilId(uint id) external {

        require(id % 42 != 0, "Rocketeer with this ID is reserved for devs");
        uint cur_id = rocketeer.totalSupply();
        require(id > cur_id, "The Rocketeer with this ID has been minted already");
        uint amount = id - cur_id;
        if ((42 - cur_id % 42) < amount)
        {
            amount--;
        }
        amount -= amount / 42;
        spawnMany(amount);
    }
}