

pragma solidity 0.5.0;

interface I_Curve {

    

    function buyPrice(uint256 _amount)
        external
        view
        returns (uint256 collateralRequired);


    function sellReward(uint256 _amount)
        external
        view
        returns (uint256 collateralReward);


    function isCurveActive() external view returns (bool);


    function collateralToken() external view returns (address);


    function bondedToken() external view returns (address);


    function requiredCollateral(uint256 _initialSupply)
        external
        view
        returns (uint256);



    function init() external;


    function mint(uint256 _amount, uint256 _maxCollateralSpend)
        external
        returns (bool success);


    function mintTo(
        uint256 _amount, 
        uint256 _maxCollateralSpend, 
        address _to
    )
        external
        returns (bool success);


    function redeem(uint256 _amount, uint256 _minCollateralReward)
        external
        returns (bool success);


    function shutDown() external;

}


pragma solidity 0.5.0;

interface I_Token {


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);



    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);



    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);



    function burn(uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;



    function isMinter(address account) external view returns (bool);


    function addMinter(address account) external;


    function renounceMinter() external;


    function mint(address account, uint256 amount) external returns (bool);



    function cap() external view returns (uint256);

}


pragma solidity ^0.5.0;

library SafeMath {

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
}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity 0.5.0;






contract RateCalc {

    using SafeMath for uint256;

    function buyRewardRange(address curveAddress, uint256 collateralAmount)
        public
        view
        returns (uint256, uint256)
    {

        return _calcPriceRange(curveAddress, collateralAmount, true);
    }

    function sellPriceRange(address curveAddress, uint256 collateralAmount)
        public
        view
        returns (uint256, uint256)
    {

        return _calcPriceRange(curveAddress, collateralAmount, false);
    }

    function _calcPriceRange(address curveAddress, uint256 y, bool isBuy)
        private
        view
        returns (uint256, uint256)
    {

        I_Curve curve = I_Curve(curveAddress);
        I_Token token = I_Token(curve.bondedToken());

        uint256 x1 = 0;
        uint256 x2 = (isBuy) ? token.cap() : token.totalSupply();
        uint256 n = _logTwo(x2 - x1); // n = log2(1250000000000000000000000) = 80.04 iterations

        for (uint256 i = 0; i < n; i++) {
            uint256 xm = x1.add(x2).div(2);
            uint256 ym = (isBuy) ? curve.buyPrice(xm) : curve.sellReward(xm);

            if (ym > y) {
                x2 = xm;
            } else if (ym < y) {
                x1 = xm;
            } else if (ym == y) {
                return (xm, xm);
            }
        }

        return (x1, x2);
    }

    function _logTwo(uint x) private pure returns (uint y) {

        assembly {
            let arg := x
            x := sub(x,1)
            x := or(x, div(x, 0x02))
            x := or(x, div(x, 0x04))
            x := or(x, div(x, 0x10))
            x := or(x, div(x, 0x100))
            x := or(x, div(x, 0x10000))
            x := or(x, div(x, 0x100000000))
            x := or(x, div(x, 0x10000000000000000))
            x := or(x, div(x, 0x100000000000000000000000000000000))
            x := add(x, 1)
            let m := mload(0x40)
            mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
            mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
            mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
            mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
            mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
            mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
            mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
            mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
            mstore(0x40, add(m, 0x100))
            let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
            let shift := 0x100000000000000000000000000000000000000000000000000000000000000
            let a := div(mul(x, magic), shift)
            y := div(mload(add(m,sub(255,a))), shift)
            y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
        }  
    }
}