
pragma solidity ^0.5.4;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

library SafeERC20 {

    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        require(token.transfer(to, value));
    }
}

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);

}

contract MultiBeneficiariesTokenTimelock {

    using SafeERC20 for IERC20;

    IERC20 public token;

    address[] public beneficiaries;
    
    uint256[] public tokenValues;

    uint256 public releaseTime;
    
    bool public distributed;

    constructor(
        IERC20 _token,
        address[] memory _beneficiaries,
        uint256[] memory _tokenValues,
        uint256 _releaseTime
    )
    public
    {
        require(_releaseTime > block.timestamp);
        releaseTime = _releaseTime;
        require(_beneficiaries.length == _tokenValues.length);
        beneficiaries = _beneficiaries;
        tokenValues = _tokenValues;
        token = _token;
        distributed = false;
    }

    function release() public {

        require(block.timestamp >= releaseTime);
        require(!distributed);

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            address beneficiary = beneficiaries[i];
            uint256 amount = tokenValues[i];
            require(amount > 0);
            token.safeTransfer(beneficiary, amount);
        }
        
        distributed = true;
    }
    
    function getTimeLeft() public view returns (uint256 timeLeft){

        if (releaseTime > block.timestamp) {
            return releaseTime - block.timestamp;
        }
        return 0;
    }
    
    function() external payable {
        revert();
    }
}