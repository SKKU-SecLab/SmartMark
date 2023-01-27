

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

interface IYearnVault {

    function pricePerShare() external view returns (uint256 price);

}

contract YearnChainlinkOracleV1 is IOracle {

    using BoringMath for uint256; // Keep everything in uint256

    function _get(
        address multiply,
        address divide,
        uint256 decimals,
        address yearnVault
    ) internal view returns (uint256) {

        uint256 price = uint256(1e36);
        if (multiply != address(0)) {
            price = price.mul(uint256(IAggregator(multiply).latestAnswer()));
        } else {
            price = price.mul(1e18);
        }

        if (divide != address(0)) {
            price = price / uint256(IAggregator(divide).latestAnswer());
        }

        return price.mul(IYearnVault(yearnVault).pricePerShare()) / decimals;
    }

    function getDataParameter(
        address multiply,
        address divide,
        uint256 decimals,
        address yearnVault
    ) public pure returns (bytes memory) {

        return abi.encode(multiply, divide, decimals, yearnVault);
    }

    function get(bytes calldata data) public override returns (bool, uint256) {

        (address multiply, address divide, uint256 decimals, address yearnVault) = abi.decode(data, (address, address, uint256, address));
        return (true, _get(multiply, divide, decimals, yearnVault));
    }

    function peek(bytes calldata data) public view override returns (bool, uint256) {

        (address multiply, address divide, uint256 decimals, address yearnVault) = abi.decode(data, (address, address, uint256, address));
        return (true, _get(multiply, divide, decimals, yearnVault));
    }

    function peekSpot(bytes calldata data) external view override returns (uint256 rate) {

        (, rate) = peek(data);
    }

    function name(bytes calldata) public view override returns (string memory) {

        return "Chainlink";
    }

    function symbol(bytes calldata) public view override returns (string memory) {

        return "LINK";
    }
}