

pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.6.0;


contract ContextUpgradeSafe is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {



    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}


pragma solidity ^0.6.0;

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


pragma solidity ^0.6.0;

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



pragma solidity ^0.6.7;



interface IAeron is IERC20 {


    event Freeze(address indexed from, uint256 value);
    event Unfreeze(address indexed from, uint256 value);
    
    function stakingContract() external view returns (address);

    function freezeOf(address _owner) external view returns (uint256);

    function burn(address from, uint256 amount) external;

    function mint(address to, uint256 amount) external;

}



pragma solidity ^0.6.7;


interface IAeronLegacy {


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);

    event Freeze(address indexed from, uint256 value);

    event Unfreeze(address indexed from, uint256 value);

    function transfer(address _to, uint256 _value) external;


    function approve(address _spender, uint256 _value) external returns (bool);


    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);


    function burn(uint256 _value) external returns (bool);


    function freeze(uint256 _value) external returns (bool);


    function unfreeze(uint256 _value) external returns (bool);


    function balanceOf(address account) external view returns (uint256);


    function freezeOf(address account) external view returns (uint256);

    function allowance(address sender, address spender) external view returns (uint256);

    function totalSupply() external view returns (uint256);


}



pragma solidity ^0.6.7;






contract AeronSwap is ContextUpgradeSafe {

    using SafeMath for uint256;
    address internal swapAddress;
    IAeron internal newAeron;
    IAeronLegacy internal legacyAeron;

    event Swapped(address indexed from, uint256 amount);

    constructor(IAeron _newAeron, IAeronLegacy _legacyAeron, address _swapAddress) public {
        newAeron = _newAeron;
        legacyAeron = _legacyAeron;
        swapAddress = _swapAddress;
    }

    function swap() public returns (bool) {

        address senderAddress = _msgSender();
        address contractAddress = address(this);
        uint256 amountIn = legacyAeron.balanceOf(senderAddress);
        uint256 amountOut = amountIn.mul(10000000000);

        require(amountIn > 0, "Insufficient balance on sender address");

        require(legacyAeron.allowance(senderAddress, contractAddress) >= amountIn, "Insufficient allowance");
        require(newAeron.allowance(swapAddress, contractAddress) >= amountOut, "Insufficient allowance");

        require(newAeron.balanceOf(swapAddress) >= amountOut, "Insufficient balance on swap address");

        legacyAeron.transferFrom(senderAddress, address(legacyAeron), amountIn);
        newAeron.transferFrom(swapAddress, senderAddress, amountOut);

        emit Swapped(senderAddress, amountOut);

        return true;
    }


}