
pragma solidity ^0.5.0;


library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
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


contract IERC20Mintable is IERC20 {

    function mint(address account, uint256 amount) external returns (bool);

    function isMinter(address account) external view returns (bool);

    function renounceMinter() external;

}

contract IERC20Burnable is IERC20 {

    function burn(uint256 _value) external;

}

contract HORSEMigrator {

    IERC20Burnable public legacyToken = IERC20Burnable(0x5B0751713b2527d7f002c0c4e2a37e1219610A6B);

    IERC20Mintable public TRIBEToken;

    IERC20Mintable public DECENTToken;

    uint256 horseToTribeRatio = 0.1 ether; // you'll get 1 tribe for 10 horse
    uint256 horseToDecentRatio = 0.000001 ether; //you'll get 1 DECENT for 1M HORSE

    uint256 public migrationTime = 5 weeks;
    uint256 public migrationEnds;

    function beginMigration(IERC20Mintable tribeContract, IERC20Mintable decentContract) public {

        require(migrationEnds == 0, "migration already started");
        require((address(tribeContract) != address(0)) && (address(decentContract) != address(0)), "new token is the zero address");

        require(tribeContract.isMinter(address(this)), "not a minter for tribe");
        require(decentContract.isMinter(address(this)), "not a minter for decent");

        migrationEnds = now + migrationTime;

        TRIBEToken = tribeContract;
        DECENTToken = decentContract;
    }

    function migrate(address account, uint256 amount) notEnded() public {

        require(address(TRIBEToken) != address(0), "migration not started");
        legacyToken.transferFrom(account, address(this), amount);
        legacyToken.burn(amount);
        TRIBEToken.mint(account, amount * horseToTribeRatio / 1 ether);
        DECENTToken.mint(account, amount * horseToDecentRatio / 1 ether);
    }

    function migrateAll(address account) public {

        uint256 balance = legacyToken.balanceOf(account);
        uint256 allowance = legacyToken.allowance(account, address(this));
        uint256 amount = Math.min(balance, allowance);
        migrate(account, amount);
    }

    modifier notEnded() {

        require(now < migrationEnds, "Swapping ended");
        _;
    }
}