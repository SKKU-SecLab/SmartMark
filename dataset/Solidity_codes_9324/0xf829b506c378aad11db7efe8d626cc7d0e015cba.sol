pragma solidity ^0.6.0;

interface IGelatoAction {

    function actionSelector() external pure returns(bytes4);

    function actionGas() external pure returns(uint256);



    function actionConditionsCheck(bytes calldata _actionPayloadWithSelector)
        external
        view
        returns(string memory);


}pragma solidity ^0.6.0;

abstract contract GelatoCoreEnums {

    enum CanExecuteResults {
        ExecutionClaimAlreadyExecutedOrCancelled,
        ExecutionClaimNonExistant,
        ExecutionClaimExpired,
        WrongCalldata,  // also returns if a not-selected executor calls fn
        ConditionNotOk,
        UnhandledConditionError,
        Executable
    }


    enum StandardReason { Ok, NotOk, UnhandledError }
}pragma solidity ^0.6.0;


interface IGelatoUserProxy {

    function callAccount(address, bytes calldata) external payable returns(bool, bytes memory);

    function delegatecallAccount(address, bytes calldata) external payable returns(bool, bytes memory);


    function delegatecallGelatoAction(
        IGelatoAction _action,
        bytes calldata _actionPayloadWithSelector,
        uint256 _actionGas
    )
        external
        payable;


    function user() external view returns(address);

    function gelatoCore() external view returns(address);

}pragma solidity ^0.6.0;


abstract contract GelatoActionsStandard is IGelatoAction {

    event LogOneWay(
        address origin,
        address sendToken,
        uint256 sendAmount,
        address destination
    );

    event LogTwoWay(
        address origin,
        address sendToken,
        uint256 sendAmount,
        address destination,
        address receiveToken,
        uint256 receiveAmount,
        address receiver
    );


    function actionConditionsCheck(bytes calldata)  // _actionPayloadWithSelector
        external
        view
        override
        virtual
        returns(string memory)  // actionCondition
    {
        this;
        return "ok";
    }


    function _isUserOwnerOfUserProxy(address _user, address _userProxy)
        internal
        view
        virtual
        returns(bool)
    {
        address owner = IGelatoUserProxy(_userProxy).user();
        return _user == owner;
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
pragma solidity ^0.6.0;

interface IKyber {

    function trade(
        address src,
        uint256 srcAmount,
        address dest,
        address destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address walletId
    )
        external
        payable
        returns (uint256);


    function getExpectedRate(address src, address dest, uint256 srcQty)
        external
        view
        returns (uint256, uint256);

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

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
pragma solidity ^0.6.0;


contract ActionKyberTrade is GelatoActionsStandard {

    using SafeMath for uint256;
    using Address for address;

    function actionSelector() external pure override returns(bytes4) {

        return this.action.selector;
    }
    uint256 public constant override actionGas = 1200000;

    function action(
        address _user,
        address _userProxy,
        address _sendToken,
        uint256 _sendAmt,
        address _receiveToken
    )
        external
        virtual
    {

        require(address(this) == _userProxy, "ErrorUserProxy");

        address kyberAddress = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;

        IERC20 sendERC20 = IERC20(_sendToken);
        try sendERC20.transferFrom(_user, _userProxy, _sendAmt) {} catch {
            revert("ErrorTransferFromUser");
        }
        try sendERC20.approve(kyberAddress, _sendAmt) {} catch {
            revert("ErrorApproveKyber");
        }

        try IKyber(kyberAddress).trade(
            _sendToken,
            _sendAmt,
            _receiveToken,
            _user,  // receiver
            2**255,
            0,  // minConversionRate (if price condition, limit order still possible)
            address(0xe1F076849B781b1395Fd332dC1758Dbc129be6EC)  // fee-sharing: gelato-node
        )
            returns(uint256 receiveAmt)
        {
            emit LogTwoWay(
                _user,  // origin
                _sendToken,
                _sendAmt,
                kyberAddress,  // destination
                _receiveToken,
                receiveAmt,
                _user  // receiver
            );
        } catch {
            revert("KyberTradeError");
        }
    }

    function actionConditionsCheck(bytes calldata _actionPayloadWithSelector)
        external
        view
        override
        virtual
        returns(string memory)  // actionCondition
    {
        (address _user, address _userProxy, address _sendToken, uint256 _sendAmt) = abi.decode(
            _actionPayloadWithSelector[4:132],
            (address,address,address,uint256)
        );
        return _actionConditionsCheck(_user, _userProxy, _sendToken, _sendAmt);
    }

    function _actionConditionsCheck(
        address _user,
        address _userProxy,
        address _sendToken,
        uint256 _sendAmt
    )
        internal
        view
        virtual
        returns(string memory)  // actionCondition
    {
        if (!_isUserOwnerOfUserProxy(_user, _userProxy))
            return "ActionKyberTrade: NotOkUserProxyOwner";

        if (!_sendToken.isContract()) return "ActionKyberTrade: NotOkSrcAddress";

        IERC20 sendERC20 = IERC20(_sendToken);
        try sendERC20.balanceOf(_user) returns(uint256 userSendTokenBalance) {
            if (userSendTokenBalance < _sendAmt)
                return "ActionKyberTrade: NotOkUserBalance";
        } catch {
            return "ActionKyberTrade: ErrorBalanceOf";
        }
        try sendERC20.allowance(_user, _userProxy) returns(uint256 userProxySendTokenAllowance) {
            if (userProxySendTokenAllowance < _sendAmt)
                return "ActionKyberTrade: NotOkUserProxySendTokenAllowance";
        } catch {
            return "ActionKyberTrade: ErrorAllowance";
        }

        return "ok";
    }

    function getUsersSendTokenBalance(
        address _user,
        address _userProxy,
        address _sendToken,  // sendToken
        uint256,
        address
    )
        external
        view
        virtual
        returns(uint256)
    {
        _userProxy;  // silence warning
        IERC20 sendERC20 = IERC20(_sendToken);
        try sendERC20.balanceOf(_user) returns(uint256 userSendTokenBalance) {
            return userSendTokenBalance;
        } catch {
            revert(
                "Error: ActionKyberTrade.getUsersSendTokenBalance: balanceOf"
            );
        }
    }
}
