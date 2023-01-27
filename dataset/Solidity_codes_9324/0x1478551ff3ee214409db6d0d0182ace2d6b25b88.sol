
pragma solidity 0.6.12;

library BoringMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        require(b == 0 || (c = a * b) / b == a, "BoringMath: Mul Overflow");
    }

    function to128(uint256 a) internal pure returns (uint128 c) {

        require(a <= uint128(-1), "BoringMath: uint128 Overflow");
        c = uint128(a);
    }

    function to64(uint256 a) internal pure returns (uint64 c) {

        require(a <= uint64(-1), "BoringMath: uint64 Overflow");
        c = uint64(a);
    }

    function to32(uint256 a) internal pure returns (uint32 c) {

        require(a <= uint32(-1), "BoringMath: uint32 Overflow");
        c = uint32(a);
    }
}

library BoringMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

library BoringMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a + b) >= b, "BoringMath: Add Overflow");
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32 c) {

        require((c = a - b) <= a, "BoringMath: Underflow");
    }
}

pragma solidity 0.6.12;

interface IOracle {

    function get(bytes calldata data) external returns (bool success, uint256 rate);


    function peek(bytes calldata data) external view returns (bool success, uint256 rate);


    function peekSpot(bytes calldata data) external view returns (uint256 rate);


    function symbol(bytes calldata data) external view returns (string memory);


    function name(bytes calldata data) external view returns (string memory);

}

pragma solidity 0.6.12;



interface IAggregator {

    function latestAnswer() external view returns (int256 answer);

}

interface IWOHM {

    function sOHMTowOHM( uint256 _amount ) external view returns ( uint256 );

}

contract wOHMOracleV1 is IOracle {

    using BoringMath for uint256; // Keep everything in uint256

    IAggregator public constant ohmOracle = IAggregator(0x90c2098473852E2F07678Fe1B6d595b1bd9b16Ed);
    IAggregator public constant ethUSDOracle = IAggregator(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    IWOHM public constant WOHM = IWOHM(0xCa76543Cf381ebBB277bE79574059e32108e3E65);

    function _get() internal view returns (uint256) {

        return 1e44 / (uint256(1e18).mul(uint256(ohmOracle.latestAnswer()).mul(uint256(ethUSDOracle.latestAnswer()))) / WOHM.sOHMTowOHM(1e9));
    }

    function get(bytes calldata) public override returns (bool, uint256) {

        return (true, _get());
    }

    function peek(bytes calldata ) public view override returns (bool, uint256) {

        return (true, _get());
    }

    function peekSpot(bytes calldata data) external view override returns (uint256 rate) {

        (, rate) = peek(data);
    }

    function name(bytes calldata) public view override returns (string memory) {

        return "wOHM Chainlink";
    }

    function symbol(bytes calldata) public view override returns (string memory) {

        return "LINK/wOHM";
    }
}