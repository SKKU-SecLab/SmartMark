
pragma solidity ^0.6.8;


library Math {


    function add(uint256 a, uint256 b) public pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "add overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) public pure returns (uint256) {

        require(b <= a, "sub underflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) public pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "mul overflow");
        return c;
    }

    function div(uint256 a, uint256 b) public pure returns (uint256) {

        require(b != 0, "div zero");
        return a / b;
    }

    function sqrt(uint256 a) public pure returns (uint256) {

        uint256 result = 0;
        uint256 bit = 1 << 254; // the second to top bit
        while (bit > a) {
            bit >>= 2;
        }
        while (bit != 0) {
            uint256 sum = result + bit;
            result >>= 1;
            if (a >= sum) {
                a -= sum;
                result += bit;
            }
            bit >>= 2;
        }
        return result;
    }
}