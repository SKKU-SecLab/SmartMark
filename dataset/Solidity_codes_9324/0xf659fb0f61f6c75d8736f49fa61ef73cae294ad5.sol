
pragma solidity =0.7.6;

contract SafeMath {


    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }
}


interface Token {


    function transfer(address _to, uint256 _value) external returns (bool success);


    function balanceOf(address _who) external view returns (uint256);

}

interface DragoEventful {


    function customDragoLog(bytes4 _methodHash, bytes calldata _encodedParams) external returns (bool success);

}

abstract contract Drago {

    address public owner;

    function getEventful() external view virtual returns (address);
}

contract ASelfCustody is SafeMath {

    
    address constant private GRG_ADDRESS = address(0x4FbB350052Bca5417566f188eB2EBCE5b19BC964);


    uint256 constant internal MIN_TOKEN_VALUE = 1e21;
    
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));

    function transferToSelfCustody(
        address payable selfCustodyAccount,
        address token,
        uint256 amount)
        external
        returns (bool, uint256)
    {

        require(
            Drago(
                address(this)
            ).owner() == msg.sender,
            "FAIL_OWNER_CHECK"
        );

        require(amount != uint256(0));

        (bool satisfied, uint256 shortfall) = _poolGRGminimumSatisfied(GRG_ADDRESS, token, amount);
        if (satisfied == true) {
            require(
                transferToSelfCustodyInternal(selfCustodyAccount, token, amount),
                "TRANSFER_FAIL_GRG_REQ_SATISFIED_ERROR"
                );
            require(
                logTransferToSelfCustody(selfCustodyAccount, token, amount),
                "LOG_FAIL_GRG_REQ_SATISFIED_ERROR"
                );
            return (true, shortfall);
        } else {
            return (false, shortfall);
        }
    }

    function poolGRGminimumSatisfied (
        address grgTokenAddress,
        address tokenAddress,
        uint256 amount
    )
        external
        view
        returns (bool satisfied, uint256 shortfall)
    {
        return _poolGRGminimumSatisfied(grgTokenAddress, tokenAddress, amount);
    }

    function _poolGRGminimumSatisfied(
        address grgTokenAddress,
        address tokenAddress,
        uint256 amount
    )
        internal
        view
        returns (bool satisfied, uint256 shortfall)
    {

        uint256 etherBase = 18;
        uint256 rationalBase = 36;
        uint256 rationalizedAmountBase36 = safeMul(amount, 10 ** (rationalBase - etherBase));
        uint256 poolRationalizedGrgBalanceBase36 = Token(grgTokenAddress).balanceOf(address(this)) * (10 ** (rationalBase - etherBase));

        if (tokenAddress != address(0)) {
            uint256 poolGrgBalance = Token(grgTokenAddress).balanceOf(address(this));
            satisfied = poolGrgBalance >= MIN_TOKEN_VALUE;
            shortfall = poolGrgBalance < MIN_TOKEN_VALUE ? MIN_TOKEN_VALUE - poolGrgBalance : uint256(0);

        } else if (rationalizedAmountBase36 < findPi2()) {
            if (poolRationalizedGrgBalanceBase36 < findPi4()) {
                satisfied = false;
                shortfall = safeDiv(findPi4() - poolRationalizedGrgBalanceBase36, (10 ** (rationalBase - etherBase)));
            } else {
                satisfied = true;
                shortfall = uint256(0);
            }

        } else if (rationalizedAmountBase36 < findPi3()) {
            if (poolRationalizedGrgBalanceBase36 < findPi5()) {
                satisfied = false;
                shortfall = safeDiv(findPi5() - poolRationalizedGrgBalanceBase36, (10 ** (rationalBase - etherBase)));
            } else {
                satisfied = true;
                shortfall = uint256(0);
            }

        } else if (rationalizedAmountBase36 >= findPi3()) {
            if (poolRationalizedGrgBalanceBase36 < findPi6()) {
                satisfied = false;
                shortfall = safeDiv(findPi6() - poolRationalizedGrgBalanceBase36, (10 ** (rationalBase - etherBase)));
            } else {
                satisfied = true;
                shortfall = uint256(0);
            }

        } else {
            revert("UNKNOWN_GRG_MINIMUM_ERROR");
        }

        return (satisfied, shortfall);
    }

    function findPi() internal pure returns (uint256 pi1) {

        uint8 power = 1;
        uint256 pi = 3141592;
        uint256 piBase = 6;
        uint256 rationalBase = 36;
        pi1 = pi ** power * 10 ** (rationalBase - piBase * power);
    }

    function findPi2() internal pure returns (uint256 pi2) {

        uint8 power = 2;
        uint256 pi = 3141592;
        uint256 piBase = 6;
        uint256 rationalBase = 36;
        pi2 = pi ** power * 10 ** (rationalBase - piBase * power);
    }

    function findPi3() internal pure returns (uint256 pi3) {

        uint8 power = 3;
        uint256 pi = 3141592;
        uint256 piBase = 6;
        uint256 rationalBase = 36;
        pi3 = pi ** power * 10 ** (rationalBase - piBase * power);
    }

    function findPi4() internal pure returns (uint256 pi4) {

        uint8 power = 4;
        uint256 pi = 3141592;
        uint256 piBase = 6;
        uint256 rationalBase = 36;
        pi4 = pi ** power * 10 ** (rationalBase - piBase * power);
    }

    function findPi5() internal pure returns (uint256 pi5) {

        uint8 power = 5;
        uint256 pi = 3141592;
        uint256 piBase = 6;
        uint256 rationalBase = 36;
        pi5 = pi ** power * 10 ** (rationalBase - piBase * power);
    }

    function findPi6() internal pure returns (uint256 pi6) {

        uint8 power = 6;
        uint256 pi = 3141592;
        uint256 piBase = 6;
        uint256 rationalBase = 36;
        pi6 = pi ** power * 10 ** (rationalBase - piBase * power);
    }

    function logTransferToSelfCustody(
        address selfCustodyAccount,
        address token,
        uint256 amount)
        internal
        returns (bool)
    {

        DragoEventful events = DragoEventful(getDragoEventful());
        bytes4 methodHash = bytes4(keccak256("transferToSelfCustody(address,address,uint256)"));
        bytes memory encodedParams = abi.encode(
            address(this),
            selfCustodyAccount,
            token,
            amount
            );
        require(
            events.customDragoLog(methodHash, encodedParams),
            "ISSUE_IN_EVENTFUL"
            );
        return true;
    }

    function transferToSelfCustodyInternal(
        address payable selfCustodyAccount,
        address token,
        uint256 amount)
        internal
        returns (bool success)
    {

        if (token == address(0)) {
            selfCustodyAccount.transfer(amount);
            success = true;
        } else {
            _safeTransfer(token, selfCustodyAccount, amount);
            success = true;
        }
        return success;
    }
    
    function _safeTransfer(address token, address to, uint value) private {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "RIGOBLOCK_TRANSFER_FAILED"
        );
    }

    function getDragoEventful()
        internal
        view
        returns (address)
    {

        address dragoEvenfulAddress =
            Drago(
                address(this)
            ).getEventful();
        return dragoEvenfulAddress;
    }
}