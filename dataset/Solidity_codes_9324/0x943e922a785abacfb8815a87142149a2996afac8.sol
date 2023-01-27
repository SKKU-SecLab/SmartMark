
pragma solidity ^0.6.8;


pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

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

pragma solidity ^0.6.8;

interface IModule {

    receive() external payable;

    function execute(
        IERC20 _inputToken,
        uint256 _inputAmount,
        address payable _owner,
        bytes calldata _data,
        bytes calldata _auxData
    ) external returns (uint256 bought);


    function canExecute(
        IERC20 _inputToken,
        uint256 _inputAmount,
        bytes calldata _data,
        bytes calldata _auxData
    ) external view returns (bool);

}

pragma solidity ^0.6.8;

interface IHandler {

    receive() external payable;

    function handle(
        IERC20 _inputToken,
        IERC20 _outputToken,
        uint256 _inputAmount,
        uint256 _minReturn,
        bytes calldata _data
    ) external payable returns (uint256 bought);


    function canHandle(
        IERC20 _inputToken,
        IERC20 _outputToken,
        uint256 _inputAmount,
        uint256 _minReturn,
        bytes calldata _data
    ) external view returns (bool);

}

pragma solidity ^0.6.8;

contract Order {

    address public constant ETH_ADDRESS = address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
}

pragma solidity ^0.6.8;

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

pragma solidity ^0.6.8;

library SafeERC20 {

    function transfer(IERC20 _token, address _to, uint256 _val) internal returns (bool) {

        (bool success, bytes memory data) = address(_token).call(abi.encodeWithSelector(_token.transfer.selector, _to, _val));
        return success && (data.length == 0 || abi.decode(data, (bool)));
    }
}

pragma solidity ^0.6.8;

library UniDexUtils {

    address internal constant ETH_ADDRESS = address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    function balanceOf(IERC20 _token, address _addr) internal view returns (uint256) {

        if (ETH_ADDRESS == address(_token)) {
            return _addr.balance;
        }

        return _token.balanceOf(_addr);
    }

    function transfer(IERC20 _token, address _to, uint256 _val) internal returns (bool) {

        if (ETH_ADDRESS == address(_token)) {
            (bool success, ) = _to.call{value:_val}("");
            return success;
        }

        return SafeERC20.transfer(_token, _to, _val);
    }
}

pragma solidity ^0.6.8;

 
contract LimitOrders is IModule, Order, ReentrancyGuard {

    using SafeMath for uint256;

    receive() external override payable { }

    function execute(
        IERC20 _inputToken,
        uint256,
        address payable _owner,
        bytes calldata _data,
        bytes calldata _auxData
    ) nonReentrant external override returns (uint256 bought) {

        (
            IERC20 outputToken,
            uint256 minReturn
        ) = abi.decode(
            _data,
            (
                IERC20,
                uint256
            )
        );

        (IHandler handler) = abi.decode(_auxData, (IHandler));

        uint256 inputAmount = UniDexUtils.balanceOf(_inputToken, address(this));
        _transferAmount(_inputToken, address(handler), inputAmount);

        handler.handle(
            _inputToken,
            outputToken,
            inputAmount,
            minReturn,
            _auxData
        );

        bought = UniDexUtils.balanceOf(outputToken, address(this));
        require(bought >= minReturn, "LimitOrders#execute: ISSUFICIENT_BOUGHT_TOKENS");

        _transferAmount(outputToken, _owner, bought);

        return bought;
    }

    function canExecute(
        IERC20 _inputToken,
        uint256 _inputAmount,
        bytes calldata _data,
        bytes calldata _auxData
    ) external override view returns (bool) {

         (
            IERC20 outputToken,
            uint256 minReturn
        ) = abi.decode(
            _data,
            (
                IERC20,
                uint256
            )
        );
        (IHandler handler) = abi.decode(_auxData, (IHandler));

        return handler.canHandle(
            _inputToken,
            outputToken,
            _inputAmount,
            minReturn,
            _auxData
        );
    }

    function _transferAmount(
        IERC20 _token,
        address payable _to,
        uint256 _amount
    ) internal {

        if (address(_token) == ETH_ADDRESS) {
            (bool success,) = _to.call{value: _amount}("");
            require(success, "LimitOrders#_transferAmount: ETH_TRANSFER_FAILED");
        } else {
            require(SafeERC20.transfer(_token, _to, _amount), "LimitOrders#_transferAmount: TOKEN_TRANSFER_FAILED");
        }
    }
}