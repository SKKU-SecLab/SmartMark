pragma solidity ^0.6.0;

interface IGelatoCondition {



    function conditionSelector() external pure returns(bytes4);

    function conditionGas() external pure returns(uint256);

}pragma solidity ^0.6.0;

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


contract ConditionBalance is IGelatoCondition {


    enum Reason {
        Ok,  // 0: Standard Field for Fulfilled Conditions and No Errors
        NotOk,  // 1: Standard Field for Unfulfilled Conditions or Caught/Handled Errors
        UnhandledError,  // 2: Standard Field for Uncaught/Unhandled Errors
        OkETHBalanceIsGreaterThanRefBalance,
        OkERC20BalanceIsGreaterThanRefBalance,
        OkETHBalanceIsSmallerThanRefBalance,
        OkERC20BalanceIsSmallerThanRefBalance,
        NotOkETHBalanceIsNotGreaterThanRefBalance,
        NotOkERC20BalanceIsNotGreaterThanRefBalance,
        NotOkETHBalanceIsNotSmallerThanRefBalance,
        NotOkERC20BalanceIsNotSmallerThanRefBalance,
        ERC20Error
    }

    function conditionSelector() external pure override returns(bytes4) {

        return this.reached.selector;
    }
    uint256 public constant override conditionGas = 30000;

    function reached(
        address _account,
        address _coin,
        uint256 _refBalance,
        bool _greaterElseSmaller
    )
        external
        view
        returns(bool, uint8)  // executable?, reason
    {

        if (_coin == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            if (_greaterElseSmaller) {  // greaterThan
                if (_account.balance >= _refBalance)
                    return (true, uint8(Reason.OkETHBalanceIsGreaterThanRefBalance));
                else
                    return(false, uint8(Reason.NotOkETHBalanceIsNotGreaterThanRefBalance));
            } else {  // smallerThan
                if (_account.balance <= _refBalance)
                    return (true, uint8(Reason.OkETHBalanceIsSmallerThanRefBalance));
                else
                    return(false, uint8(Reason.NotOkETHBalanceIsNotSmallerThanRefBalance));
            }
        } else {
            IERC20 erc20 = IERC20(_coin);
            try erc20.balanceOf(_account) returns (uint256 erc20Balance) {
                if (_greaterElseSmaller) {  // greaterThan
                    if (erc20Balance >= _refBalance)
                        return (true, uint8(Reason.OkERC20BalanceIsGreaterThanRefBalance));
                    else
                        return(false, uint8(Reason.NotOkERC20BalanceIsNotGreaterThanRefBalance));
                } else {  // smallerThan
                    if (erc20Balance <= _refBalance)
                        return (true, uint8(Reason.OkETHBalanceIsSmallerThanRefBalance));
                    else
                        return(false, uint8(Reason.NotOkERC20BalanceIsNotSmallerThanRefBalance));
                }
            } catch {
                return(false, uint8(Reason.ERC20Error));
            }
        }
    }

    function getConditionValue(address _account, address _coin, uint256, bool)
        external
        view
        returns(uint256)
    {

        if (_coin == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)
            return _account.balance;
        IERC20 erc20 = IERC20(_coin);
        return erc20.balanceOf(_account);
    }
}