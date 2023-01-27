


pragma solidity 0.6.7;

abstract contract SAFEEngineLike {
    function modifyCollateralBalance(bytes32,address,int) virtual public;
}

abstract contract CollateralLike {
    function decimals() virtual public view returns (uint);
    function transfer(address,uint) virtual public returns (bool);
    function transferFrom(address,address,uint) virtual public returns (bool);
}

contract CollateralJoin1 {

    mapping (address => uint) public authorizedAccounts;
    function addAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "CollateralJoin1/account-not-authorized");
        _;
    }

    SAFEEngineLike public safeEngine;
    bytes32        public collateralType;
    CollateralLike public collateral;
    uint           public decimals;
    uint           public contractEnabled;  // Access Flag

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event DisableContract();
    event Join(address sender, address usr, uint wad);
    event Exit(address sender, address usr, uint wad);

    constructor(address safeEngine_, bytes32 collateralType_, address collateral_) public {
        authorizedAccounts[msg.sender] = 1;
        contractEnabled = 1;
        safeEngine = SAFEEngineLike(safeEngine_);
        collateralType = collateralType_;
        collateral = CollateralLike(collateral_);
        decimals = collateral.decimals();
        require(decimals == 18, "CollateralJoin1/not-18-decimals");
        emit AddAuthorization(msg.sender);
    }

    function addition(uint x, int y) internal pure returns (uint z) {

        z = x + uint(y);
        require(y >= 0 || z <= x);
        require(y <= 0 || z >= x);
    }

    function disableContract() external isAuthorized {

        contractEnabled = 0;
        emit DisableContract();
    }

    function join(address usr, uint wad) external {

        require(contractEnabled == 1, "CollateralJoin1/not-contractEnabled");
        require(int(wad) >= 0, "CollateralJoin1/overflow");
        safeEngine.modifyCollateralBalance(collateralType, usr, int(wad));
        require(collateral.transferFrom(msg.sender, address(this), wad), "CollateralJoin1/failed-transfer");
        emit Join(msg.sender, usr, wad);
    }
    function exit(address usr, uint wad) external {

        require(wad <= 2 ** 255, "CollateralJoin1/overflow");
        safeEngine.modifyCollateralBalance(collateralType, msg.sender, -int(wad));
        require(collateral.transfer(usr, wad), "CollateralJoin1/failed-transfer");
        emit Exit(msg.sender, usr, wad);
    }
}