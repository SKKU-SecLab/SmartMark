




pragma solidity 0.8.11;

interface OracleLike {

    function peek() external view returns (uint256, bool);

    function read() external view returns (uint256);

}

interface StethLike {

    function getPooledEthByShares(uint256) external view returns (uint256);

}

contract StethPrice {

    uint256 constant WAD = 10**18;

    StethLike immutable STETH;
    OracleLike immutable WSTETH_ORACLE;

    mapping(address => uint256) public wards;
    function rely(address usr) external auth {wards[usr] = 1; emit Rely(usr);}

    function deny(address usr) external auth {wards[usr] = 0; emit Deny(usr);}

    modifier auth {

      require(wards[msg.sender] == 1, "StethPrice/not-authorized");
      _;
    }

    mapping (address => uint256) public bud;
    modifier toll {

        require(bud[msg.sender] == 1, "StethPrice/not-whitelisted");
        _;
    }

    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event Kiss(address a);
    event Diss(address a);

    constructor(address _steth, address _wstETHOracle) {
        STETH = StethLike(_steth);
        WSTETH_ORACLE = OracleLike(_wstETHOracle);
        wards[msg.sender] = 1;
        emit Rely(msg.sender);
    }

    function peek() external view toll returns (uint256 val, bool has) {

        (val, has) = WSTETH_ORACLE.peek();
        val = val * WAD / STETH.getPooledEthByShares(1 ether);
    }

    function read() external view toll returns (uint256 price) {

        price = WSTETH_ORACLE.read() * WAD / STETH.getPooledEthByShares(1 ether);
    }

    function kiss(address _a) external auth {

        require(_a != address(0), "StethPrice/no-contract-0");
        bud[_a] = 1;
        emit Kiss(_a);
    }

    function diss(address _a) external auth {

        bud[_a] = 0;
        emit Diss(_a);
    }

    function kiss(address[] calldata _a) external auth {

        for(uint256 i = 0; i < _a.length;) {
            require(_a[i] != address(0), "StethPrice/no-contract-0");
            bud[_a[i]] = 1;
            emit Kiss(_a[i]);
            unchecked { i++; }
        }
    }

    function diss(address[] calldata _a) external auth {

        for(uint256 i = 0; i < _a.length;) {
            bud[_a[i]] = 0;
            emit Diss(_a[i]);
            unchecked { i++; }
        }
    }
}