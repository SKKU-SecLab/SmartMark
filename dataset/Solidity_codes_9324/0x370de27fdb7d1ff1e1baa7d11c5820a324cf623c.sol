
pragma solidity ^0.5.0;


contract ERC20FeeProxy {

  event TransferWithReferenceAndFee(
    address tokenAddress,
    address to,
    uint256 amount,
    bytes indexed paymentReference,
    uint256 feeAmount,
    address feeAddress
  );

  function() external payable {
    revert("not payable fallback");
  }

  function transferFromWithReferenceAndFee(
    address _tokenAddress,
    address _to,
    uint256 _amount,
    bytes calldata _paymentReference,
    uint256 _feeAmount,
    address _feeAddress
    ) external
    {

    require(safeTransferFrom(_tokenAddress, _to, _amount), "payment transferFrom() failed");
    if (_feeAmount > 0 && _feeAddress != address(0)) {
      require(safeTransferFrom(_tokenAddress, _feeAddress, _feeAmount), "fee transferFrom() failed");
    }
    emit TransferWithReferenceAndFee(
      _tokenAddress,
      _to,
      _amount,
      _paymentReference,
      _feeAmount,
      _feeAddress
    );
  }

  function safeTransferFrom(address _tokenAddress, address _to, uint256 _amount) internal returns (bool result) {

    assembly {
      if iszero(extcodesize(_tokenAddress)) { revert(0, 0) }
    }
    
    (bool success, ) = _tokenAddress.call(abi.encodeWithSignature(
      "transferFrom(address,address,uint256)",
      msg.sender,
      _to,
      _amount
    ));

    assembly {
        switch returndatasize()
        case 0 { // not a standard erc20
            result := 1
        }
        case 32 { // standard erc20
            returndatacopy(0, 0, 32)
            result := mload(0)
        }
        default { // anything else, should revert for safety
            revert(0, 0)
        }
    }

    require(success, "transferFrom() has been reverted");

    return result;
  }
}