

pragma solidity 0.4.24;

interface IMiniMeToken {

    function decimals() external view returns(uint8);

    function balanceOf(address _account) external view returns(uint256);

    function balanceOfAt(address _account, uint256 _block) external view returns(uint256);

    function totalSupply() external view returns(uint256);

    function totalSupplyAt(uint256 _block) external view returns(uint256);

}

// Adapted to use pragma ^0.4.24 and satisfy our linter rules

pragma solidity ^0.4.24;


library SafeMath {

    string private constant ERROR_ADD_OVERFLOW = "MATH_ADD_OVERFLOW";
    string private constant ERROR_SUB_UNDERFLOW = "MATH_SUB_UNDERFLOW";
    string private constant ERROR_MUL_OVERFLOW = "MATH_MUL_OVERFLOW";
    string private constant ERROR_DIV_ZERO = "MATH_DIV_ZERO";

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {

        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b, ERROR_MUL_OVERFLOW);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b > 0, ERROR_DIV_ZERO); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;

        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

        require(_b <= _a, ERROR_SUB_UNDERFLOW);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {

        uint256 c = _a + _b;
        require(c >= _a, ERROR_ADD_OVERFLOW);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, ERROR_DIV_ZERO);
        return a % b;
    }
}


pragma solidity 0.4.24;



contract Crust is IMiniMeToken {

    using SafeMath for uint256;
    IMiniMeToken[] public crumbs;
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(address[] memory _crumbs, string _name, string _symbol, uint8 _decimals) public {
        require(_crumbs.length > 0, "Crust.constructor: Crust must at least have one crumb");
        for(uint256 i = 0; i < _crumbs.length; i ++) {
            crumbs.push(IMiniMeToken(_crumbs[i]));
            require(crumbs[i].decimals() == _decimals, "Crumbs must have same number of decimals as crust");
        }
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function balanceOf(address _account) external view returns(uint256) {

        return this.balanceOfAt(_account, block.number);
    }

    function balanceOfAt(address _account, uint256 _block) external view returns(uint256) {

        uint256 result = 0;
        for(uint256 i = 0; i < crumbs.length; i++) {
            result = result.add(crumbs[i].balanceOfAt(_account, _block));
        }
        return result;
    }

    function totalSupply() external view returns(uint256) {

        return this.totalSupplyAt(block.number);
    }

    function totalSupplyAt(uint256 _block) external view returns(uint256) {

        uint256 result = 0;
        for(uint256 i = 0; i < crumbs.length; i++) {
            result = result.add(crumbs[i].totalSupplyAt(_block));
        }
        return result;
    }

    function decimals() external view returns(uint8) {

        return decimals;
    }
}