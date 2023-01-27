pragma solidity ^0.6.0;

interface IGelatoCondition {



    function conditionSelector() external pure returns(bytes4);

    function conditionGas() external pure returns(uint256);

}pragma solidity ^0.6.0;

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


contract ConditionKyberRate is IGelatoCondition {


    using SafeMath for uint256;

    enum Reason {
        Ok,  // 0: Standard Field for Fulfilled Conditions and No Errors
        NotOk,  // 1: Standard Field for Unfulfilled Conditions or Caught/Handled Errors
        UnhandledError,  // 2: Standard Field for Uncaught/Unhandled Errors
        OkKyberExpectedRateIsGreaterThanRefRate,
        OkKyberExpectedRateIsSmallerThanRefRate,
        NotOkKyberExpectedRateIsNotGreaterThanRefRate,
        NotOkKyberExpectedRateIsNotSmallerThanRefRate,
        KyberGetExpectedRateError
    }

    function conditionSelector() external pure override returns(bytes4) {

        return this.reached.selector;
    }
    uint256 public constant override conditionGas = 500000;

    function reached(
        address _src,
        uint256 _srcAmt,
        address _dest,
        uint256 _refRate,
        bool _greaterElseSmaller
    )
        external
        view
        returns(bool, uint8)  // executable?, reason
    {

        address kyberAddress = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;

        try IKyber(kyberAddress).getExpectedRate(
            _src,
            _dest,
            _srcAmt
        )
            returns(uint256 expectedRate, uint256)
        {
            if (_greaterElseSmaller) {  // greaterThan
                if (expectedRate >= _refRate)
                    return (true, uint8(Reason.OkKyberExpectedRateIsGreaterThanRefRate));
                else
                    return (false, uint8(Reason.NotOkKyberExpectedRateIsNotGreaterThanRefRate));
            } else {  // smallerThan
                if (expectedRate <= _refRate)
                    return (true, uint8(Reason.OkKyberExpectedRateIsSmallerThanRefRate));
                else
                    return(false, uint8(Reason.NotOkKyberExpectedRateIsNotSmallerThanRefRate));
            }
        } catch {
            return(false, uint8(Reason.KyberGetExpectedRateError));
        }
    }

    function getConditionValue(address _src, uint256 _srcAmt, address _dest, uint256, bool)
        external
        view
        returns(uint256)
    {

        address kyberAddress = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;

        (uint256 expectedRate,) = IKyber(kyberAddress).getExpectedRate(_src, _dest, _srcAmt);
        return expectedRate;
    }
}