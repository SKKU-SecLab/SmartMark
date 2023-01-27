
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT


pragma solidity ^0.8.13;



interface IIce {

  event EntropyAdded (address _entropyAddress);
  event EntropyUpdated (uint256 _index, address _newAddress, address _oldAddress); 
  event EntropyCleared (); 
  event EntropyServed(address seedAddress, uint256 seedValue, uint256 timeStamp, uint256 modulo, uint256 entropy);
  event BaseFeeUpdated(uint256 oldFee, uint256 newFee);
  event ETHExponentUpdated(uint256 oldETHExponent, uint256 newETHExponent);
  event OATExponentUpdated(uint256 oldOATExponent, uint256 newOATExponent);
  event TreasurySet(address treasury);
  event TokenWithdrawal(uint256 indexed withdrawal, address indexed tokenAddress);
  event EthWithdrawal(uint256 indexed withdrawal);

  function iceRingEntropy(uint256 _mode) external payable returns(bool, uint256 entropy_);

  function iceRingNumberInRange(uint256 _mode, uint256 _upperBound) external payable returns(bool, uint256 numberInRange_);

  function viewEntropyAddress(uint256 _index) external view returns (address entropyAddress);

  function addEntropy(address _entropyAddress) external;

  function updateEntropy(uint256 _index, address _newAddress) external;

  function deleteAllEntropy() external;

  function updateBaseFee(uint256 _newBasefee) external;

  function updateOATFeeExponent(uint256 _newOatExponent) external;

  function updateETHFeeExponent(uint256 _newEthExponent) external;

  function getConfig() external view returns(uint256 seedIndex_, uint256 counter_, uint256 modulo_, address seedAddress_, uint256 baseFee_, uint256 ethExponent_, uint256 oatExponent_);

  function getEthFee() external view returns (uint256 ethFee);

  function getOatFee() external view returns (uint256 oatFee); 

  function validateProof(uint256 _seedValue, uint256 _modulo, uint256 _timeStamp, uint256 _entropy) external pure returns(bool valid);

}// MIT
 

pragma solidity ^0.8.13;



abstract contract OmStorage is Context {

  uint256 public nus;

  uint256 private immutable om1Length;
  uint256 private immutable om2Length;
  uint256 private immutable om3Length;
  uint256 private immutable om4Length;
  uint256 private immutable om5Length;
  uint256 private immutable om6Length;
  uint256 private immutable om7Length;
  uint256 private immutable om8Length;
  uint256 private immutable om9Length;
  uint256 private immutable om10Length;
  uint256 private immutable om11Length;
  uint256 private immutable om12Length;

  uint256 private immutable om1Modulo;
  uint256 private immutable om2Modulo;
  uint256 private immutable om3Modulo;
  uint256 private immutable om4Modulo;
  uint256 private immutable om5Modulo;
  uint256 private immutable om6Modulo;
  uint256 private immutable om7Modulo;
  uint256 private immutable om8Modulo;
  uint256 private immutable om9Modulo;
  uint256 private immutable om10Modulo;
  uint256 private immutable om11Modulo;
  uint256 private immutable om12Modulo;

  uint256 private immutable om2Divisor;
  uint256 private immutable om3Divisor;
  uint256 private immutable om4Divisor;
  uint256 private immutable om5Divisor;
  uint256 private immutable om6Divisor;
  uint256 private immutable om7Divisor;
  uint256 private immutable om8Divisor;
  uint256 private immutable om9Divisor;
  uint256 private immutable om10Divisor;
  uint256 private immutable om11Divisor;
  uint256 private immutable om12Divisor;

  constructor(uint256 _om1Length, uint256 _om2Length, uint256 _om3Length, uint256 _om4Length, 
    uint256 _om5Length, uint256 _om6Length, uint256 _om7Length, uint256 _om8Length, uint256 _om9Length, 
    uint256 _om10Length, uint256 _om11Length, uint256 _om12Length) {
    
    om1Length  = _om1Length;
    om2Length  = _om2Length;
    om3Length  = _om3Length;
    om4Length  = _om4Length;
    om5Length  = _om5Length;
    om6Length  = _om6Length;
    om7Length  = _om7Length;
    om8Length  = _om8Length;
    om9Length  = _om9Length;
    om10Length = _om10Length;
    om11Length = _om12Length;
    om12Length = _om12Length;

    uint256 moduloExponent;
    uint256 divisorExponent;

    moduloExponent += _om1Length;
    om1Modulo = 10 ** moduloExponent;

    divisorExponent = moduloExponent;
    moduloExponent  += _om2Length;
    om2Divisor      = 10 ** divisorExponent;
    om2Modulo       = 10 ** moduloExponent;

    divisorExponent = moduloExponent;
    moduloExponent  += _om3Length;
    om3Divisor      = 10 ** divisorExponent;
    om3Modulo       = 10 ** moduloExponent;

    divisorExponent = moduloExponent;
    moduloExponent  += _om4Length;
    om4Divisor      = 10 ** divisorExponent;
    om4Modulo       = 10 ** moduloExponent;

    divisorExponent = moduloExponent;
    moduloExponent  += _om5Length;
    om5Divisor      = 10 ** divisorExponent;
    om5Modulo       = 10 ** moduloExponent;

    divisorExponent = moduloExponent;
    moduloExponent  += _om6Length;
    om6Divisor      = 10 ** divisorExponent;
    om6Modulo       = 10 ** moduloExponent;

    divisorExponent = moduloExponent;
    moduloExponent  += _om7Length;
    om7Divisor      = 10 ** divisorExponent;
    om7Modulo       = 10 ** moduloExponent;

    divisorExponent = moduloExponent;
    moduloExponent  += _om8Length;
    om8Divisor      = 10 ** divisorExponent;
    om8Modulo       = 10 ** moduloExponent;

    divisorExponent = moduloExponent;
    moduloExponent  += _om9Length;
    om9Divisor      = 10 ** divisorExponent;
    om9Modulo       = 10 ** moduloExponent;

    divisorExponent = moduloExponent;
    moduloExponent  += _om10Length;
    om10Divisor      = 10 ** divisorExponent;
    om10Modulo       = 10 ** moduloExponent;

    divisorExponent = moduloExponent;
    moduloExponent  += _om11Length;
    om11Divisor      = 10 ** divisorExponent;
    om11Modulo       = 10 ** moduloExponent;

    divisorExponent = moduloExponent;
    moduloExponent  += _om12Length;
    om12Divisor      = 10 ** divisorExponent;
    om12Modulo       = 10 ** moduloExponent;

    require(moduloExponent < 76, "Too wide");
  }

  function getOm01() public view returns(uint256 om1_) {
    return(om1Value(nus));
  }
  function getOm02() public view returns(uint256 om2_) {
    return(om2Value(nus));
  }
  function getOm03() public view returns(uint256 om3_) {
    return(om3Value(nus));
  }
  function getOm04() public view returns(uint256 om4_) {
    return(om4Value(nus));
  }
  function getOm05() public view returns(uint256 om5_) {
    return(om5Value(nus));
  }
  function getOm06() public view returns(uint256 om6_) {
    return(om6Value(nus));
  }
  function getOm07() public view returns(uint256 om7_) {
    return(om7Value(nus));
  }
  function getOm08() public view returns(uint256 om8_) {
    return(om8Value(nus));
  }
  function getOm09() public view returns(uint256 om9_) {
    return(om9Value(nus));
  }
  function getOm10() public view returns(uint256 om10_) {
    return(om10Value(nus));
  }
  function getOm11() public view returns(uint256 om11_) {
    return(om11Value(nus));
  }
  function getOm12() public view returns(uint256 om12_) {
    return(om12Value(nus));
  }

  function om1Value(uint256 _nus) internal view returns(uint256 om1_){
    if (om1Length == 0) return(0);
    return(_nus % om1Modulo);
  }

  function om2Value(uint256 _nus) internal view returns(uint256 om2_) {
    if (om2Length == 0) return(0);
    return((_nus % om2Modulo) / om2Divisor);
  }

  function om3Value(uint256 _nus) internal view returns(uint256 om3_) {
    if (om3Length == 0) return(0);
    return((_nus % om3Modulo) / om3Divisor);
  }

  function om4Value(uint256 _nus) internal view returns(uint256 om4_) {
    if (om4Length == 0) return(0);
    return((_nus % om4Modulo) / om4Divisor);
  }

  function om5Value(uint256 _nus) internal view returns(uint256 om5_) {
    if (om5Length == 0) return(0);
    return((_nus % om5Modulo) / om5Divisor);
  }

  function om6Value(uint256 _nus) internal view returns(uint256 om6_) {
    if (om6Length == 0) return(0);
    return((_nus % om6Modulo) / om6Divisor);
  }

  function om7Value(uint256 _nus) internal view returns(uint256 om7_) {
    if (om7Length == 0) return(0);
    return((_nus % om7Modulo) / om7Divisor);
  }

  function om8Value(uint256 _nus) internal view returns(uint256 om8_) {
    if (om8Length == 0) return(0);
    return((_nus % om8Modulo) / om8Divisor);
  }

  function om9Value(uint256 _nus) internal view returns(uint256 om9_) {
    if (om9Length == 0) return(0);
    return((_nus % om9Modulo) / om9Divisor);
  }

  function om10Value(uint256 _nus) internal view returns(uint256 om10_) {
    if (om10Length == 0) return(0);
    return((_nus % om10Modulo) / om10Divisor);
  }

  function om11Value(uint256 _nus) internal view returns(uint256 om11_) {
    if (om11Length == 0) return(0);
    return((_nus % om11Modulo) / om11Divisor); 
  }

  function om12Value(uint256 _nus) internal view returns(uint256 om12_) {
    if (om12Length == 0) return(0);
    return((_nus % om12Modulo) / om12Divisor);  
  }

  function decodeNus() public view returns(uint256 om1, uint256 om2, uint256 om3, uint256 om4, uint256 om5, 
  uint256 om6, uint256 om7, uint256 om8, uint256 om9, uint256 om10, uint256 om11, uint256 om12){

    uint256 _nus = nus;

    om1 = om1Value(_nus);
    if (om2Length == 0)  return(om1, om2, om3, om4, om5, om6, om7, om8, om9, om10, om11, om12);
      om2 = om2Value(_nus);
    if (om3Length == 0)  return(om1, om2, om3, om4, om5, om6, om7, om8, om9, om10, om11, om12);
      om3 = om3Value(_nus);
    if (om4Length == 0)  return(om1, om2, om3, om4, om5, om6, om7, om8, om9, om10, om11, om12);
      om4 = om4Value(_nus);
    if (om5Length == 0)  return(om1, om2, om3, om4, om5, om6, om7, om8, om9, om10, om11, om12);
      om5 = om5Value(_nus);
    if (om6Length == 0)  return(om1, om2, om3, om4, om5, om6, om7, om8, om9, om10, om11, om12);
      om6 = om6Value(_nus);
    if (om7Length == 0)  return(om1, om2, om3, om4, om5, om6, om7, om8, om9, om10, om11, om12);
      om7 = om7Value(_nus);
    if (om8Length == 0)  return(om1, om2, om3, om4, om5, om6, om7, om8, om9, om10, om11, om12);
      om8 = om8Value(_nus);
    if (om9Length == 0)  return(om1, om2, om3, om4, om5, om6, om7, om8, om9, om10, om11, om12);
      om9 = om9Value(_nus);
    if (om10Length == 0) return(om1, om2, om3, om4, om5, om6, om7, om8, om9, om10, om11, om12);
      om10 = om10Value(_nus);
    if (om11Length == 0) return(om1, om2, om3, om4, om5, om6, om7, om8, om9, om10, om11, om12);
      om11 = om11Value(_nus);
    if (om12Length == 0) return(om1, om2, om3, om4, om5, om6, om7, om8, om9, om10, om11, om12);
      om12 = om12Value(_nus);
    return(om1, om2, om3, om4, om5, om6, om7, om8, om9, om10, om11, om12);
  }

  function encodeNus(uint256 _om1, uint256 _om2, uint256 _om3, uint256 _om4, uint256 _om5, 
  uint256 _om6, uint256 _om7, uint256 _om8, uint256 _om9, uint256 _om10, uint256 _om11, uint256 _om12) internal {
    checkOverflow(_om1,_om2, _om3, _om4, _om5, _om6, _om7, _om8, _om9, _om10, _om11, _om12);
    nus = sumOmNus (_om1,_om2, _om3, _om4, _om5, _om6, _om7, _om8, _om9, _om10, _om11, _om12);      
  }

  function sumOmNus(uint256 _om1, uint256 _om2, uint256 _om3, uint256 _om4, uint256 _om5, 
  uint256 _om6, uint256 _om7, uint256 _om8, uint256 _om9, uint256 _om10, uint256 _om11, uint256 _om12) view internal returns(uint256 nus_) {
    nus_ = _om1;
    if (om2Length == 0)  return(nus_);
    nus_ += _om2 * om2Divisor;
    if (om3Length == 0)  return(nus_);
    nus_ += _om3 * om3Divisor;
    if (om4Length == 0)  return(nus_);
    nus_ += _om4 * om4Divisor;
    if (om5Length == 0)  return(nus_);
    nus_ += _om5 * om5Divisor;
    if (om6Length == 0)  return(nus_);
    nus_ += _om6 * om6Divisor;
    if (om7Length == 0)  return(nus_);
    nus_ += _om7 * om7Divisor;
    if (om8Length == 0)  return(nus_);
    nus_ += _om8 * om8Divisor;
    if (om9Length == 0)  return(nus_);
    nus_ += _om9 * om9Divisor;
    if (om10Length == 0)  return(nus_);
    nus_ += _om10 * om10Divisor;
    if (om11Length == 0)  return(nus_);
    nus_ += _om11 * om11Divisor;
    if (om12Length == 0)  return(nus_);
    nus_ += _om12 * om12Divisor;
    return(nus_);
  }        

  function checkOverflow(uint256 _om1, uint256 _om2, uint256 _om3, uint256 _om4, uint256 _om5, 
  uint256 _om6, uint256 _om7, uint256 _om8, uint256 _om9, uint256 _om10, uint256 _om11, uint256 _om12) view internal {
    
    require((_om1  / (10 ** om1Length) == 0),  "om1 overflow");
    if (om2Length == 0) return;
    require((_om2  / (10 ** om2Length) == 0),  "om2 overflow");
    if (om3Length == 0) return;
    require((_om3  / (10 ** om3Length) == 0),  "om3 overflow");
    if (om4Length == 0) return;
    require((_om4  / (10 ** om4Length) == 0),  "om4 overflow");   
    if (om5Length == 0) return;
    require((_om5  / (10 ** om5Length) == 0),  "om5 overflow"); 
    if (om6Length == 0) return;
    require((_om6  / (10 ** om6Length) == 0),  "om6 overflow");
    if (om7Length == 0) return;
    require((_om7  / (10 ** om7Length) == 0),  "om7 overflow");
    if (om8Length == 0) return;
    require((_om8  / (10 ** om8Length) == 0),  "om8 overflow");
    if (om9Length == 0) return;
    require((_om9  / (10 ** om9Length) == 0),  "om9 overflow");
    if (om10Length == 0) return;
    require((_om10 / (10 ** om10Length) == 0), "om10 overflow");
    if (om11Length == 0) return;
    require((_om11 / (10 ** om11Length) == 0), "om11 overflow");
    if (om2Length == 0) return;
    require((_om12 / (10 ** om12Length) == 0), "om12 overflow"); 
  }
}// MIT


pragma solidity ^0.8.13;


interface IERC20SpendableReceiver{


  function receiveSpendableERC20(address _caller, uint256 _tokenPaid, uint256[] memory arguments) external returns(bool, uint256[] memory);


}// MIT


pragma solidity ^0.8.13;



abstract contract ERC20SpendableReceiver is Context, Ownable, IERC20SpendableReceiver {
  
  address public immutable ERC20Spendable; 

  event ERC20Received(address _caller, uint256 _tokenPaid, uint256[] _arguments);

  constructor(address _ERC20Spendable) {
    ERC20Spendable = _ERC20Spendable;
  }

  modifier onlyERC20Spendable(address _caller) {
    require (_caller == ERC20Spendable, "Call from unauthorised caller");
    _;
  }

  function receiveSpendableERC20(address _caller, uint256 _tokenPaid, uint256[] memory _arguments) external virtual onlyERC20Spendable(msg.sender) returns(bool, uint256[] memory) { 
  }

}// MIT


pragma solidity ^0.8.13;



contract Ice is Ownable, OmStorage, ERC20SpendableReceiver, IIce {

  using SafeERC20 for IERC20;
  
  uint256 constant NUMBER_IN_RANGE_LIGHT = 0;
  uint256 constant NUMBER_IN_RANGE_STANDARD = 1;
  uint256 constant NUMBER_IN_RANGE_HEAVY = 2;
  uint256 constant ENTROPY_LIGHT = 3;
  uint256 constant ENTROPY_STANDARD = 4;
  uint256 constant ENTROPY_HEAVY = 5;

  address public treasury;
  mapping (uint256 => address) entropyItem;

  constructor(address _ERC20Spendable)
    ERC20SpendableReceiver(_ERC20Spendable)
    OmStorage(2, 2, 8, 49, 10, 2, 2, 0, 0, 0, 0, 0) {
    encodeNus(0, 0, 10000000, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  }

  function receiveSpendableERC20(address, uint256 _tokenPaid, uint256[] memory _arguments) override external onlyERC20Spendable(msg.sender) returns(bool, uint256[] memory) { 

    
    (uint256 seedIndex, uint256 counter, uint256 modulo, address seedAddress, uint256 feeBase, uint256 ethExponent, uint256 oatExponent) = getConfig();

    uint256 oatFee = feeBase * (10 ** oatExponent);

    if (oatFee != 0) {
      require(_tokenPaid == oatFee, "Incorrect ERC20 payment");
    }

    uint256[] memory returnResults = new uint256[](1);

    if (_arguments[0] == NUMBER_IN_RANGE_LIGHT) {
      returnResults[0] = getNumberInRangeLight(_arguments[1], seedIndex, counter, modulo, seedAddress, feeBase, ethExponent, oatExponent); 
      return(true, returnResults);
    }
    if (_arguments[0] == NUMBER_IN_RANGE_STANDARD) {
      returnResults[0] = getNumberInRange(_arguments[1], seedIndex, counter, modulo, seedAddress, feeBase, ethExponent, oatExponent); 
      return(true, returnResults);
    }

    if (_arguments[0] == NUMBER_IN_RANGE_HEAVY) {
      returnResults[0] = getNumberInRangeHeavy(_arguments[1], seedIndex, counter, modulo, seedAddress, feeBase, ethExponent, oatExponent); 
      return(true, returnResults);
    }

    if (_arguments[0] == ENTROPY_LIGHT) {
      returnResults[0] = getEntropyLight(seedIndex, counter, modulo, seedAddress, feeBase, ethExponent, oatExponent); 
      return(true, returnResults);
    }
    if (_arguments[0] == ENTROPY_STANDARD) {
      returnResults[0] = getEntropy(seedIndex, counter, modulo, seedAddress, feeBase, ethExponent, oatExponent); 
      return(true, returnResults);
    }

    if (_arguments[0] == ENTROPY_HEAVY) {
      returnResults[0] = getEntropyHeavy(seedIndex, counter, modulo, seedAddress, feeBase, ethExponent, oatExponent); 
      return(true, returnResults);
    }  

    return(false, returnResults);
  }

  function iceRingNumberInRange(uint256 _mode, uint256 _upperBound) external payable returns(bool, uint256 numberInRange_) {  


    (uint256 seedIndex, uint256 counter, uint256 modulo, address seedAddress, uint256 feeBase, uint256 ethExponent, uint256 oatExponent) = getConfig();

    uint256 ethFee = feeBase * (10 ** ethExponent);

    if (ethFee != 0) {
      require(msg.value == ethFee, "Incorrect ETH payment");
    }

    if (_mode == NUMBER_IN_RANGE_LIGHT) {

      return(true, getNumberInRangeLight(_upperBound, seedIndex, counter, modulo, seedAddress, feeBase, ethExponent, oatExponent));
    
    }
    if (_mode == NUMBER_IN_RANGE_STANDARD) {

      return(true, getNumberInRange(_upperBound, seedIndex, counter, modulo, seedAddress, feeBase, ethExponent, oatExponent));

    }

    if (_mode == NUMBER_IN_RANGE_HEAVY) {

      return(true, getNumberInRangeHeavy(_upperBound, seedIndex, counter, modulo, seedAddress, feeBase, ethExponent, oatExponent)); 

    }

    return(false, 0);
  }

  function iceRingEntropy(uint256 _mode) external payable returns(bool, uint256 entropy_) { 


    (uint256 seedIndex, uint256 counter, uint256 modulo, address seedAddress, uint256 feeBase, uint256 ethExponent, uint256 oatExponent) = getConfig();

    uint256 ethFee = feeBase * (10 ** ethExponent);

    if (ethFee != 0) {
      require(msg.value == ethFee, "Incorrect ETH payment");
    }

    if (_mode == ENTROPY_LIGHT) {

      return(true, getEntropyLight(seedIndex, counter, modulo, seedAddress, feeBase, ethExponent, oatExponent));

    }

    if (_mode == ENTROPY_STANDARD) {

      return(true, getEntropy(seedIndex, counter, modulo, seedAddress, feeBase, ethExponent, oatExponent));

    }

    if (_mode == ENTROPY_HEAVY) {

      return(true, getEntropyHeavy(seedIndex, counter, modulo, seedAddress, feeBase, ethExponent, oatExponent));

    }  

    return(false, 0);

  }


  function viewEntropyAddress(uint256 _index) external view returns (address entropyAddress) {

    return (entropyItem[_index]) ;
  }

  function getEthFee() external view returns (uint256 ethFee) {

    return (getOm05() * (10 ** getOm06())) ;
  }

  function getOatFee() external view returns (uint256 oatFee) {

    return (getOm05() * (10 ** getOm07())) ;
  }
  
  function addEntropy(address _entropyAddress) external onlyOwner {


    (uint256 seedIndex, uint256 counter, uint256 modulo, address seedAddress, uint256 feeBase, uint256 ethExponent, uint256 oatExponent) = getConfig();

    counter += 1;
    entropyItem[counter] = _entropyAddress;
    seedAddress = _entropyAddress;
    emit EntropyAdded(_entropyAddress);
    encodeNus(seedIndex, counter, modulo, uint256(uint160(seedAddress)), feeBase, ethExponent, oatExponent, 0, 0, 0, 0, 0);
  }

  function updateEntropy(uint256 _index, address _newAddress) external onlyOwner {

    address oldEntropyAddress = entropyItem[_index];
    entropyItem[_index] = _newAddress;
    emit EntropyUpdated(_index, _newAddress, oldEntropyAddress); 
  }

  function deleteAllEntropy() external onlyOwner {

    (uint256 seedIndex, uint256 counter, uint256 modulo, address seedAddress, uint256 feeBase, uint256 ethExponent, uint256 oatExponent) = getConfig();

    require(counter > 0, "No entropy defined");
    for (uint i = 1; i <= counter; i++){
      delete entropyItem[i];
    }
    counter = 0;
    seedAddress = address(0);
    encodeNus(seedIndex, counter, modulo, uint256(uint160(seedAddress)), feeBase, ethExponent, oatExponent, 0, 0, 0, 0, 0);
    emit EntropyCleared();
  }

  function updateBaseFee(uint256 _newBaseFee) external onlyOwner {

    (uint256 seedIndex, uint256 counter, uint256 modulo, address seedAddress, uint256 oldFeeBase, uint256 ethExponent, uint256 oatExponent) = getConfig(); 
    
    encodeNus(seedIndex, counter, modulo, uint256(uint160(seedAddress)), _newBaseFee, ethExponent, oatExponent, 0, 0, 0, 0, 0);
    
    emit BaseFeeUpdated(oldFeeBase, _newBaseFee);
  }

  function updateETHFeeExponent(uint256 _newEthExponent) external onlyOwner {

    (uint256 seedIndex, uint256 counter, uint256 modulo, address seedAddress, uint256 feeBase, uint256 oldEthExponent, uint256 oatExponent) = getConfig(); 
    
    encodeNus(seedIndex, counter, modulo, uint256(uint160(seedAddress)), feeBase, _newEthExponent, oatExponent, 0, 0, 0, 0, 0);
    
    emit ETHExponentUpdated(oldEthExponent, _newEthExponent);
  }

  function updateOATFeeExponent(uint256 _newOatExponent) external onlyOwner {

    (uint256 seedIndex, uint256 counter, uint256 modulo, address seedAddress, uint256 feeBase, uint256 ethExponent, uint256 oldOatExponent) = getConfig(); 
    
    encodeNus(seedIndex, counter, modulo, uint256(uint160(seedAddress)), feeBase, ethExponent, _newOatExponent, 0, 0, 0, 0, 0);
    
    emit OATExponentUpdated(oldOatExponent, _newOatExponent);
  }

  function setTreasury(address _treasury) external onlyOwner {

    treasury = _treasury;
    emit TreasurySet(_treasury);
  }

  function _hashEntropy(bool lightMode, uint256 seedIndex, uint256 counter, uint256 modulo, address seedAddress, uint256  feeBase, uint256 ethExponent, uint256 oatExponent) internal returns(uint256 hashedEntropy_){


    if (modulo >= 99999999) {
      modulo = 10000000;
    }  
    else {
      modulo = modulo + 1; 
    } 

    if (lightMode) {
      hashedEntropy_ = (uint256(keccak256(abi.encode(seedAddress.balance + (block.timestamp % modulo)))));
    }
    else {
      if (seedIndex >= counter) {
      seedIndex = 1;
      }  
      else {
        seedIndex += 1; 
      } 
      address rotatingSeedAddress = entropyItem[seedIndex];
      uint256 seedAddressBalance = rotatingSeedAddress.balance;
      hashedEntropy_ = (uint256(keccak256(abi.encode(seedAddressBalance, (block.timestamp % modulo)))));
      emit EntropyServed(rotatingSeedAddress, seedAddressBalance, block.timestamp, modulo, hashedEntropy_); 
    }         

    encodeNus(seedIndex, counter, modulo, uint256(uint160(seedAddress)), feeBase, ethExponent, oatExponent, 0, 0, 0, 0, 0);
      
    return(hashedEntropy_);
  }

  function _numberInRange(uint256 _upperBound, bool _lightMode, uint256 _seed, uint256 _counter, uint256 _modulo, address _seedAddress, uint256 _feeBase, uint256 _ethExponent, uint256 _oatExponent) internal returns(uint256 numberWithinRange){

    return((((_hashEntropy(_lightMode, _seed, _counter, _modulo, _seedAddress, _feeBase, _ethExponent, _oatExponent) % 10 ** 18) * _upperBound) / (10 ** 18)) + 1);
  }

  function getConfig() public view returns(uint256 seedIndex_, uint256 counter_, uint256 modulo_, address seedAddress_, uint256 feeBase_, uint256 ethExponent_, uint256 oatExponent_){

    
    uint256 nusInMemory = nus;

    return(om1Value(nusInMemory), om2Value(nusInMemory), om3Value(nusInMemory), address(uint160(om4Value(nusInMemory))), om5Value(nusInMemory), om6Value(nusInMemory), om7Value(nusInMemory));
  }

  function getEntropy(uint256 _seed, uint256 _counter, uint256 _modulo, address _seedAddress, uint256  _feeBase, uint256 _ethExponent, uint256 _oatExponent) internal returns(uint256 entropy_){

    entropy_ = _hashEntropy(false, _seed, _counter, _modulo, _seedAddress, _feeBase, _ethExponent, _oatExponent); 
    return(entropy_);
  }

  function getEntropyLight(uint256 _seedIndex,uint256 _counter, uint256 _modulo, address _seedAddress, uint256 _feeBase, uint256 _ethExponent, uint256 _oatExponent) internal returns(uint256 entropy_){

    entropy_ = _hashEntropy(true, _seedIndex, _counter, _modulo, _seedAddress, _feeBase, _ethExponent, _oatExponent); 
    return(entropy_);
  }

  function getEntropyHeavy(uint256, uint256 _counter, uint256 _modulo, address _seedAddress, uint256  _feeBase, uint256 _ethExponent, uint256 _oatExponent) internal returns(uint256 entropy_){

    
    uint256 loopEntropy;

    for (uint i = 0; i < _counter; i++){
      loopEntropy = _hashEntropy(false, i, _counter, _modulo, _seedAddress, _feeBase, _ethExponent, _oatExponent); 
      entropy_ = (uint256(keccak256(abi.encode(entropy_, loopEntropy))));
    }
    return(entropy_);

  }

  function getNumberInRange(uint256 _upperBound, uint256 _seedIndex, uint256 _counter, uint256 _modulo, 
      address _seedAddress, uint256 _feeBase, uint256 _ethExponent, uint256 _oatExponent) internal returns(uint256 numberInRange_){

    numberInRange_ = _numberInRange(_upperBound, false, _seedIndex, _counter, _modulo, _seedAddress, _feeBase, _ethExponent, _oatExponent);
    return(numberInRange_);
  }

  function getNumberInRangeLight(uint256 _upperBound, uint256 _seedIndex, uint256 _counter, uint256 _modulo, 
      address _seedAddress, uint256 _feeBase, uint256 _ethExponent, uint256 _oatExponent) internal returns(uint256 numberInRange_){

    numberInRange_ = _numberInRange(_upperBound, true, _seedIndex, _counter, _modulo, _seedAddress, _feeBase, _ethExponent, _oatExponent);
    return(numberInRange_);
  }

  function getNumberInRangeHeavy(uint256 _upperBound, uint256 _seedIndex, uint256 _counter, uint256 _modulo, 
      address _seedAddress, uint256 _feeBase, uint256 _ethExponent, uint256 _oatExponent) internal returns(uint256 numberInRange_){

    numberInRange_ = ((((getEntropyHeavy(_seedIndex, _counter, _modulo, _seedAddress, _feeBase, _ethExponent, _oatExponent) % 10 ** 18) * _upperBound) / (10 ** 18)) + 1);
    return(numberInRange_);
  }

  function validateProof(uint256 _seedValue, uint256 _modulo, uint256 _timeStamp, uint256 _entropy) external pure returns(bool valid){

    if (uint256(keccak256(abi.encode(_seedValue, (_timeStamp % _modulo)))) == _entropy) return true;
    else return false;
  }

  function withdrawERC20(IERC20 _token, uint256 _amountToWithdraw) external onlyOwner {

    _token.safeTransfer(treasury, _amountToWithdraw); 
    emit TokenWithdrawal(_amountToWithdraw, address(_token));
  }

  function withdrawETH(uint256 _amount) external onlyOwner returns (bool) {

    (bool success, ) = treasury.call{value: _amount}("");
    require(success, "Transfer failed.");
    emit EthWithdrawal(_amount); 
    return true;
  }

  receive() external payable {
    require(msg.sender == owner(), "Only owner can fund contract");
  }

  fallback() external payable {
    revert();
  }

}