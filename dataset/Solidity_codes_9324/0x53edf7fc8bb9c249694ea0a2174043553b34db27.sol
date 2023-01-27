
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


interface TokenInterface {

    function approve(address, uint256) external;

    function transfer(address, uint) external;

    function transferFrom(address, address, uint) external;

    function deposit() external payable;

    function withdraw(uint) external;

    function balanceOf(address) external view returns (uint);

    function decimals() external view returns (uint);

}

interface MemoryInterface {

    function getUint(uint id) external returns (uint num);

    function setUint(uint id, uint val) external;

}

interface EventInterface {

    function emitEvent(uint connectorType, uint connectorID, bytes32 eventCode, bytes calldata eventData) external;

}

contract Stores {


  function getEthAddr() internal pure returns (address) {

    return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // ETH Address
  }

  function getMemoryAddr() internal pure returns (address) {

    return 0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F; // InstaMemory Address
  }

  function getEventAddr() internal pure returns (address) {

    return 0x2af7ea6Cb911035f3eb1ED895Cb6692C39ecbA97; // InstaEvent Address
  }

  function getUint(uint getId, uint val) internal returns (uint returnVal) {

    returnVal = getId == 0 ? val : MemoryInterface(getMemoryAddr()).getUint(getId);
  }

  function setUint(uint setId, uint val) virtual internal {

    if (setId != 0) MemoryInterface(getMemoryAddr()).setUint(setId, val);
  }

  function connectorID() public pure returns(uint model, uint id) {

    (model, id) = (1, 66);
  }

}

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

contract DSMath {

  uint constant WAD = 10 ** 18;
  uint constant RAY = 10 ** 27;

  function add(uint x, uint y) internal pure returns (uint z) {

    z = SafeMath.add(x, y);
  }

  function sub(uint x, uint y) internal virtual pure returns (uint z) {

    z = SafeMath.sub(x, y);
  }

  function mul(uint x, uint y) internal pure returns (uint z) {

    z = SafeMath.mul(x, y);
  }

  function div(uint x, uint y) internal pure returns (uint z) {

    z = SafeMath.div(x, y);
  }

  function wmul(uint x, uint y) internal pure returns (uint z) {

    z = SafeMath.add(SafeMath.mul(x, y), WAD / 2) / WAD;
  }

  function wdiv(uint x, uint y) internal pure returns (uint z) {

    z = SafeMath.add(SafeMath.mul(x, WAD), y / 2) / y;
  }

  function rdiv(uint x, uint y) internal pure returns (uint z) {

    z = SafeMath.add(SafeMath.mul(x, RAY), y / 2) / y;
  }

  function rmul(uint x, uint y) internal pure returns (uint z) {

    z = SafeMath.add(SafeMath.mul(x, y), RAY / 2) / RAY;
  }

}

interface AaveInterface {

    function deposit(address _asset, uint256 _amount, address _onBehalfOf, uint16 _referralCode) external;

    function withdraw(address _asset, uint256 _amount, address _to) external;

    function borrow(
        address _asset,
        uint256 _amount,
        uint256 _interestRateMode,
        uint16 _referralCode,
        address _onBehalfOf
    ) external;

    function repay(address _asset, uint256 _amount, uint256 _rateMode, address _onBehalfOf) external;

    function setUserUseReserveAsCollateral(address _asset, bool _useAsCollateral) external;

}

interface AaveLendingPoolProviderInterface {

    function getLendingPool() external view returns (address);

}

interface AaveDataProviderInterface {

    function getReserveTokensAddresses(address _asset) external view returns (
        address aTokenAddress,
        address stableDebtTokenAddress,
        address variableDebtTokenAddress
    );

    function getUserReserveData(address _asset, address _user) external view returns (
        uint256 currentATokenBalance,
        uint256 currentStableDebt,
        uint256 currentVariableDebt,
        uint256 principalStableDebt,
        uint256 scaledVariableDebt,
        uint256 stableBorrowRate,
        uint256 liquidityRate,
        uint40 stableRateLastUpdated,
        bool usageAsCollateralEnabled
    );

}

interface AaveAddressProviderRegistryInterface {

    function getAddressesProvidersList() external view returns (address[] memory);

}

interface ATokenInterface {

    function balanceOf(address _user) external view returns(uint256);

}

contract AaveHelpers is DSMath, Stores {

    function getAaveProvider() internal pure returns (AaveLendingPoolProviderInterface) {

        return AaveLendingPoolProviderInterface(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5); //mainnet
    }

    function getAaveDataProvider() internal pure returns (AaveDataProviderInterface) {

        return AaveDataProviderInterface(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d); //mainnet
    }

    function getWethAddr() internal pure returns (address) {

        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Mainnet WETH Address
    }

    function getReferralCode() internal pure returns (uint16) {

        return 3228;
    }

    function getIsColl(AaveDataProviderInterface aaveData, address token, address user) internal view returns (bool isCol) {

        (, , , , , , , , isCol) = aaveData.getUserReserveData(token, user);
    }

    function convertEthToWeth(bool isEth, TokenInterface token, uint amount) internal {

        if(isEth) token.deposit.value(amount)();
    }

    function convertWethToEth(bool isEth, TokenInterface token, uint amount) internal {

       if(isEth) {
            token.approve(address(token), amount);
            token.withdraw(amount);
        }
    }

    function getPaybackBalance(AaveDataProviderInterface aaveData, address token, uint rateMode) internal view returns (uint) {

        (, uint stableDebt, uint variableDebt, , , , , , ) = aaveData.getUserReserveData(token, address(this));
        return rateMode == 1 ? stableDebt : variableDebt;
    }

    function getCollateralBalance(AaveDataProviderInterface aaveData, address token) internal view returns (uint bal) {

        (bal, , , , , , , ,) = aaveData.getUserReserveData(token, address(this));
    }
}

contract BasicResolver is AaveHelpers {

    event LogDeposit(address indexed token, uint256 tokenAmt, uint256 getId, uint256 setId);
    event LogWithdraw(address indexed token, uint256 tokenAmt, uint256 getId, uint256 setId);
    event LogBorrow(address indexed token, uint256 tokenAmt, uint256 indexed rateMode, uint256 getId, uint256 setId);
    event LogPayback(address indexed token, uint256 tokenAmt, uint256 indexed rateMode, uint256 getId, uint256 setId);
    event LogEnableCollateral(address[] tokens);

    function deposit(address token, uint amt, uint getId, uint setId) external payable {

        uint _amt = getUint(getId, amt);

        AaveInterface aave = AaveInterface(getAaveProvider().getLendingPool());
        AaveDataProviderInterface aaveData = getAaveDataProvider();

        bool isEth = token == getEthAddr();
        address _token = isEth ? getWethAddr() : token;

        TokenInterface tokenContract = TokenInterface(_token);

        if (isEth) {
            _amt = _amt == uint(-1) ? address(this).balance : _amt;
            convertEthToWeth(isEth, tokenContract, _amt);
        } else {
            _amt = _amt == uint(-1) ? tokenContract.balanceOf(address(this)) : _amt;
        }

        tokenContract.approve(address(aave), _amt);

        aave.deposit(_token, _amt, address(this), getReferralCode());

        if (!getIsColl(aaveData, _token, address(this))) {
            aave.setUserUseReserveAsCollateral(_token, true);
        }

        setUint(setId, _amt);

        emit LogDeposit(token, _amt, getId, setId);
    }

    function withdraw(address token, uint amt, uint getId, uint setId) external payable {

        uint _amt = getUint(getId, amt);

        AaveInterface aave = AaveInterface(getAaveProvider().getLendingPool());
        bool isEth = token == getEthAddr();
        address _token = isEth ? getWethAddr() : token;

        TokenInterface tokenContract = TokenInterface(_token);

        uint initialBal = tokenContract.balanceOf(address(this));
        aave.withdraw(_token, _amt, address(this));
        uint finalBal = tokenContract.balanceOf(address(this));

        _amt = sub(finalBal, initialBal);

        convertWethToEth(isEth, tokenContract, _amt);
        
        setUint(setId, _amt);

        emit LogWithdraw(token, _amt, getId, setId);
    }

    function borrow(address token, uint amt, uint rateMode, uint getId, uint setId) external payable {

        uint _amt = getUint(getId, amt);

        AaveInterface aave = AaveInterface(getAaveProvider().getLendingPool());

        bool isEth = token == getEthAddr();
        address _token = isEth ? getWethAddr() : token;

        aave.borrow(_token, _amt, rateMode, getReferralCode(), address(this));
        convertWethToEth(isEth, TokenInterface(_token), _amt);

        setUint(setId, _amt);

        emit LogBorrow(token, _amt, rateMode, getId, setId);
    }

    function payback(address token, uint amt, uint rateMode, uint getId, uint setId) external payable {

        uint _amt = getUint(getId, amt);

        AaveInterface aave = AaveInterface(getAaveProvider().getLendingPool());
        AaveDataProviderInterface aaveData = getAaveDataProvider();

        bool isEth = token == getEthAddr();
        address _token = isEth ? getWethAddr() : token;

        TokenInterface tokenContract = TokenInterface(_token);

        _amt = _amt == uint(-1) ? getPaybackBalance(aaveData, _token, rateMode) : _amt;

        if (isEth) convertEthToWeth(isEth, tokenContract, _amt);

        tokenContract.approve(address(aave), _amt);

        aave.repay(_token, _amt, rateMode, address(this));

        setUint(setId, _amt);

        emit LogPayback(token, _amt, rateMode, getId, setId);
    }

    function enableCollateral(address[] calldata tokens) external payable {

        uint _length = tokens.length;
        require(_length > 0, "0-tokens-not-allowed");

        AaveInterface aave = AaveInterface(getAaveProvider().getLendingPool());
        AaveDataProviderInterface aaveData = getAaveDataProvider();

        for (uint i = 0; i < _length; i++) {
            address token = tokens[i];
            if (getCollateralBalance(aaveData, token) > 0 && !getIsColl(aaveData, token, address(this))) {
                aave.setUserUseReserveAsCollateral(token, true);
            }
        }

        emit LogEnableCollateral(tokens);
    }
}

contract ConnectAaveV2 is BasicResolver {

    string public name = "AaveV2-v1.1";
}