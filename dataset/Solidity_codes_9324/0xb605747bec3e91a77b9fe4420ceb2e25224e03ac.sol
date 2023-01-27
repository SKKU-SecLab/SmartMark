
pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

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
}pragma solidity 0.7.6;


contract APWineNaming {

    using SafeMathUpgradeable for uint256;

    function genFYTSymbol(
        uint8 _index,
        string memory _ibtSymbol,
        string memory _platform,
        uint256 _periodDuration
    ) public pure returns (string memory) {

        return concatenate(genIBTSymbol(_ibtSymbol, _platform, _periodDuration), concatenate("-", uintToString(_index)));
    }

    function genFYTSymbolFromIBT(uint8 _index, string memory _ibtSymbol) public pure returns (string memory) {

        return concatenate(_ibtSymbol, concatenate("-", uintToString(_index)));
    }

    function genIBTSymbol(
        string memory _ibtSymbol,
        string memory _platform,
        uint256 _periodDuration
    ) public pure returns (string memory) {

        return
            concatenate(
                getPeriodDurationDenominator(_periodDuration),
                concatenate("-", concatenate(_platform, concatenate("-", _ibtSymbol)))
            );
    }

    function getPeriodDurationDenominator(uint256 _periodDuration) public pure returns (string memory) {

        if (_periodDuration >= 1 days) {
            uint256 numberOfdays = _periodDuration.div(1 days);
            return string(concatenate(uintToString(uint8(numberOfdays)), "D"));
        }
        return "CUSTOM";
    }

    function uintToString(uint8 v) public pure returns (string memory) {

        bytes memory reversed = new bytes(8);
        uint256 i = 0;
        if (v == 0) return "0";
        while (v != 0) {
            uint256 remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i + 1);
        for (uint256 j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        return string(s);
    }

    function concatenate(string memory a, string memory b) public pure returns (string memory) {

        return string(abi.encodePacked(a, b));
    }
}