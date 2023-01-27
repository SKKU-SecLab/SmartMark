
pragma solidity 0.5.10;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}



contract CurveFunctions {

	using SafeMath for uint256;

	string constant public curveFunction = "linear: (1/20000)*x + 0.5	curve integral: (0.000025*x + 0.5)*x	inverse curve integral: -10000 + 200*sqrt(x + 2500)";
	uint256 constant public DECIMALS = 18;

	function curveIntegral(uint256 _x) public pure returns (uint256) {

		require(_x <= 10**40, 'Input argument too large');

		uint256 a = 25*10**(DECIMALS - 6);
		uint256 b = 5*10**(DECIMALS - 1);

		return (a.mul(_x).div(10**DECIMALS).add(b)).mul(_x).div(10**DECIMALS);
	}

	function inverseCurveIntegral(uint256 _x) public pure returns(uint256) {

		require(_x <= 10**40, 'Input argument too large');

		uint256 DECIMALS_36 = 36;

		uint256 x = _x*10**DECIMALS;
		uint256 prefix = 200*10**DECIMALS_36;
		uint256 a = prefix
			.mul(sqrt(x + 2500*10**DECIMALS_36))
			.div(sqrt(10**DECIMALS_36));

		return uint256(
				-10000*int256(10**DECIMALS_36) + int256(a)
			).div(10**DECIMALS);
	}

	function sqrt(uint256 _x) public pure returns (uint256) {

		if (_x == 0) return 0;
		else if (_x <= 3) return 1;
		uint256 z = (_x + 1) / 2;
		uint256 y = _x;
		
		while (z < y) {
			y = z;
			z = (_x / z + z) / 2;
		}

		return y;
	}
}