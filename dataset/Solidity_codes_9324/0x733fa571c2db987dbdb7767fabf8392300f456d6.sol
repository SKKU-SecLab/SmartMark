
pragma solidity 0.5.16;


interface IERC20 {

    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

}


contract EthToDaiTradeHelperV4 {

    IERC20 internal constant _DAI = IERC20(
        0x6B175474E89094C44Da98b954EedeAC495271d0F
    );
 
    IERC20 internal constant _DDAI = IERC20(
        0x00000000001876eB1444c986fD502e618c587430
    );

    IERC20 internal constant _DUSDC = IERC20(
        0x00000000008943c65cAf789FFFCF953bE156f6f8
    );
    
    function tradeEthForDai(
        uint256 daiExpected, address payable target, bytes calldata data
    ) external payable returns (uint256 daiReceived) {

        (bool ok,) = target.call.value(address(this).balance)(data);
        
        _revertOnFailure(ok);
        
        daiReceived = _DAI.balanceOf(address(this));
        
        require(
            daiReceived >= daiExpected,
            "Trade did not result in the expected amount of Dai."
        );
        
        ok = (_DAI.transfer(msg.sender, daiReceived));
        require(ok, "Dai transfer out failed.");
    }

    function tradeDaiForEth(
        uint256 ethExpected, address target, bytes calldata data
    ) external returns (uint256 ethReceived) {

        if (_DAI.allowance(address(this), target) != uint256(-1)) {
            _DAI.approve(target, uint256(-1));
        }
        
        (bool ok,) = target.call(data);
        
        _revertOnFailure(ok);
        
        ethReceived = address(this).balance;

        require(
            ethReceived >= ethExpected,
            "Trade did not result in the expected amount of Ether."
        );
   
        (ok, ) = msg.sender.call.gas(4999).value(ethReceived)("");

        _revertOnFailure(ok);
    }

    function tradeDDaiForDUSDC(
        uint256 dUSDCExpected, address target, bytes calldata data
    ) external returns (uint256 dUSDCReceived) {

        if (_DDAI.allowance(address(this), target) != uint256(-1)) {
            _DDAI.approve(target, uint256(-1));
        }
        
        (bool ok,) = target.call(data);
        
        _revertOnFailure(ok);
        
        dUSDCReceived = _DUSDC.balanceOf(address(this));

        require(
            dUSDCReceived >= dUSDCExpected,
            "Trade did not result in the expected amount of dUSDC."
        );
   
        ok = (_DUSDC.transfer(msg.sender, dUSDCReceived));
        require(ok, "dUSDC transfer out failed.");
    }

    function tradeDUSDCForDDai(
        uint256 dDaiExpected, address target, bytes calldata data
    ) external returns (uint256 dDaiReceived) {

        if (_DUSDC.allowance(address(this), target) != uint256(-1)) {
            _DUSDC.approve(target, uint256(-1));
        }
        
        (bool ok,) = target.call(data);
        
        _revertOnFailure(ok);
        
        dDaiReceived = _DDAI.balanceOf(address(this));

        require(
            dDaiReceived >= dDaiExpected,
            "Trade did not result in the expected amount of dDai."
        );
   
        ok = (_DDAI.transfer(msg.sender, dDaiReceived));
        require(ok, "dDai transfer out failed.");
    }

    function _revertOnFailure(bool ok) internal pure {

        if (!ok) {
            assembly {
                returndatacopy(0, 0, returndatasize)
                revert(0, returndatasize)
            }
        }
    }
}