
pragma solidity ^0.5.0;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Assertion Failed");
        return c;
    }
}


contract IERC20 {

    function balanceOf(address who) public view returns (uint256);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

}


contract KyberInterface {

    function trade(
        address src,
        uint srcAmount,
        address dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
        ) public payable returns (uint);


    function getExpectedRate(
        address src,
        address dest,
        uint srcQty
        ) public view returns (uint, uint);

}


contract Helper {


    using SafeMath for uint;
    using SafeMath for uint256;

    function getAddressETH() public pure returns (address eth) {

        eth = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    }

    function getAddressKyber() public pure returns (address kyber) {

        kyber = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    }

    function getAddressAdmin() public pure returns (address admin) {

        admin = 0x7284a8451d9a0e7Dc62B3a71C0593eA2eC5c5638;
    }

    function getUintFees() public pure returns (uint fees) {

        fees = 200;
    }

    function getBal(address src, address _owner) public view returns (uint, uint) {

        uint tknBal;
        if (src != getAddressETH()) {
            tknBal = IERC20(src).balanceOf(address(_owner));
        }
        return (address(_owner).balance, tknBal);
    }

    function getExpectedRate(
        address src,
        address dest,
        uint srcAmt
    ) public view returns (
        uint expectedRate,
        uint slippageRate
    ) 
    {

        (expectedRate,) = KyberInterface(getAddressKyber()).getExpectedRate(src, dest, srcAmt);
        slippageRate = (expectedRate / 100) * 99; // changing slippage rate upto 99%
    }

    function getToken(address trader, address src, uint srcAmt) internal returns (uint ethQty) {

        if (src == getAddressETH()) {
            require(msg.value == srcAmt, "not-enough-src");
            ethQty = srcAmt;
        } else {
            manageApproval(src, srcAmt);
            IERC20(src).transferFrom(trader, address(this), srcAmt);
        }
    }

    function setApproval(address token) internal returns (uint) {

        IERC20(token).approve(getAddressKyber(), 2**255);
    }

    function manageApproval(address token, uint srcAmt) internal returns (uint) {

        uint tokenAllowance = IERC20(token).allowance(address(this), getAddressKyber());
        if (srcAmt > tokenAllowance) {
            setApproval(token);
        }
    }
    
}


contract Swap is Helper {


    event LogTrade(
        uint what, // 0 for BUY & 1 for SELL
        address src,
        uint srcAmt,
        address dest,
        uint destAmt,
        address beneficiary,
        uint minConversionRate,
        address affiliate
    );

    function buy(
        address src,
        address dest,
        uint srcAmt,
        uint maxDestAmt,
        uint slippageRate
    ) public payable returns (uint destAmt)
    {

        uint ethQty = getToken(msg.sender, src, srcAmt);

        destAmt = KyberInterface(getAddressKyber()).trade.value(ethQty)(
            src,
            srcAmt,
            dest,
            msg.sender,
            maxDestAmt,
            slippageRate,
            getAddressAdmin()
        );

        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        } else if (src != getAddressETH()) {
            IERC20 srcTkn = IERC20(src);
            uint srcBal = srcTkn.balanceOf(address(this));
            if (srcBal > 0) {
                srcTkn.transfer(msg.sender, srcBal);
            }
        }

        emit LogTrade(
            0,
            src,
            srcAmt,
            dest,
            destAmt,
            msg.sender,
            slippageRate,
            getAddressAdmin()
        );

    }

    function sell(
        address src,
        address dest,
        uint srcAmt,
        uint slippageRate
    ) public payable returns (uint destAmt)
    {

        uint ethQty = getToken(msg.sender, src, srcAmt);

        destAmt = KyberInterface(getAddressKyber()).trade.value(ethQty)(
            src,
            srcAmt,
            dest,
            msg.sender,
            2**255,
            slippageRate,
            getAddressAdmin()
        );

        emit LogTrade(
            1,
            src,
            srcAmt,
            dest,
            destAmt,
            msg.sender,
            slippageRate,
            getAddressAdmin()
        );

    }

}


contract InstaTrade is Swap {


    uint public version;
    
    constructor(uint _version) public {
        version = _version;
    }

}