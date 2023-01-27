
pragma solidity ^0.6.0;



interface OneSplitInterface {

    function swap(
        TokenInterface fromToken,
        TokenInterface toToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution, // [Uniswap, Kyber, Bancor, Oasis]
        uint256 disableFlags // 16 - Compound, 32 - Fulcrum, 64 - Chai, 128 - Aave, 256 - SmartToken, 1024 - bDAI
    ) external payable;


    function getExpectedReturn(
        TokenInterface fromToken,
        TokenInterface toToken,
        uint256 amount,
        uint256 parts,
        uint256 disableFlags
    )
    external
    view
    returns(
        uint256 returnAmount,
        uint256[] memory distribution
    );

}


interface TokenInterface {

    function allowance(address, address) external view returns (uint);

    function balanceOf(address) external view returns (uint);

    function approve(address, uint) external;

    function transfer(address, uint) external returns (bool);

    function transferFrom(address, address, uint) external returns (bool);

}



contract DSMath {


    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, "math-not-safe");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;

    function wmul(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {

        z = add(mul(x, WAD), y / 2) / y;
    }

}


contract Helpers is DSMath {

    function getAddressETH() internal pure returns (address) {

        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // ETH Address
    }





}


contract CompoundHelpers is Helpers {


    function getOneSplitAddress() internal pure returns (address) {

        return 0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E;
    }
}


contract BasicResolver is CompoundHelpers {


    function sell(
        address buyAddr,
        address sellAddr,
        uint sellAmt,
        uint unitAmt,
        uint getId
    ) external payable {

        TokenInterface _buyAddr = TokenInterface(buyAddr);
        TokenInterface _sellAddr = TokenInterface(sellAddr);
        OneSplitInterface oneSplitContract = OneSplitInterface(getOneSplitAddress());
        (uint buyAmt, uint[] memory distribution) =
        oneSplitContract.getExpectedReturn(
                _buyAddr,
                _sellAddr,
                sellAmt,
                unitAmt,
                getId
            );

        uint ethAmt;
        uint _sellAmt;
        if (sellAddr == getAddressETH()) {
            _sellAmt = _sellAmt == uint(-1) ? address(this).balance : _sellAmt;
            ethAmt = _sellAmt;
        } else {
            TokenInterface sellContract = TokenInterface(sellAddr);
            _sellAmt = _sellAmt == uint(-1) ? sellContract.balanceOf(address(this)) : _sellAmt;
            sellContract.approve(address(oneSplitContract), _sellAmt);
        }

        oneSplitContract.swap.value(ethAmt)(
            _buyAddr,
            _sellAddr,
            sellAmt,
            buyAmt,
            distribution,
            getId
        );
    }

}