
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

  function emitEvent(bytes32 eventCode, bytes memory eventData) virtual internal {

    (uint model, uint id) = connectorID();
    EventInterface(getEventAddr()).emitEvent(model, id, eventCode, eventData);
  }

  function connectorID() public view returns(uint model, uint id) {

    (model, id) = (1, 38);
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

interface OneInchInterace {

    function swap(
        TokenInterface fromToken,
        TokenInterface toToken,
        uint256 fromTokenAmount,
        uint256 minReturnAmount,
        uint256 guaranteedAmount,
        address payable referrer,
        address[] calldata callAddresses,
        bytes calldata callDataConcat,
        uint256[] calldata starts,
        uint256[] calldata gasLimitsAndValues
    )
    external
    payable
    returns (uint256 returnAmount);

}

interface OneProtoInterface {

    function swapWithReferral(
        TokenInterface fromToken,
        TokenInterface destToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256 flags, // See contants in IOneSplit.sol
        address referral,
        uint256 feePercent
    ) external payable returns(uint256);


    function swapWithReferralMulti(
        TokenInterface[] calldata tokens,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata distribution,
        uint256[] calldata flags,
        address referral,
        uint256 feePercent
    ) external payable returns(uint256 returnAmount);


    function getExpectedReturn(
        TokenInterface fromToken,
        TokenInterface destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    )
    external
    view
    returns(
        uint256 returnAmount,
        uint256[] memory distribution
    );

}

interface OneProtoMappingInterface {

    function oneProtoAddress() external view returns(address);

}


contract OneHelpers is Stores, DSMath {


    function getOneProtoMappingAddress() internal pure returns (address payable) {

        return 0x8d0287AFa7755BB5f2eFe686AA8d4F0A7BC4AE7F;
    }

    function getOneProtoAddress() internal view returns (address payable) {

        return payable(OneProtoMappingInterface(getOneProtoMappingAddress()).oneProtoAddress());
    }

    function getOneInchAddress() internal pure returns (address) {

        return 0x11111254369792b2Ca5d084aB5eEA397cA8fa48B;
    }

    function getOneInchTokenTaker() internal pure returns (address payable) {

        return 0xE4C9194962532fEB467DCe8b3d42419641c6eD2E;
    }

    function getOneInchSig() internal pure returns (bytes4) {

        return 0xf88309d7;
    }

    function getReferralAddr() internal pure returns (address) {

        return 0xa7615CD307F323172331865181DC8b80a2834324;
    }

    function convert18ToDec(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {

        amt = (_amt / 10 ** (18 - _dec));
    }

    function convertTo18(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {

        amt = mul(_amt, 10 ** (18 - _dec));
    }

    function getTokenBal(TokenInterface token) internal view returns(uint _amt) {

        _amt = address(token) == getEthAddr() ? address(this).balance : token.balanceOf(address(this));
    }

    function getTokensDec(TokenInterface buyAddr, TokenInterface sellAddr) internal view returns(uint buyDec, uint sellDec) {

        buyDec = address(buyAddr) == getEthAddr() ?  18 : buyAddr.decimals();
        sellDec = address(sellAddr) == getEthAddr() ?  18 : sellAddr.decimals();
    }

    function getSlippageAmt(
        TokenInterface _buyAddr,
        TokenInterface _sellAddr,
        uint _sellAmt,
        uint unitAmt
    ) internal view returns(uint _slippageAmt) {

        (uint _buyDec, uint _sellDec) = getTokensDec(_buyAddr, _sellAddr);
        uint _sellAmt18 = convertTo18(_sellDec, _sellAmt);
        _slippageAmt = convert18ToDec(_buyDec, wmul(unitAmt, _sellAmt18));
    }

    function convertToTokenInterface(address[] memory tokens) internal pure returns(TokenInterface[] memory) {

        TokenInterface[] memory _tokens = new TokenInterface[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            _tokens[i] = TokenInterface(tokens[i]);
        }
        return _tokens;
    }
}


contract OneProtoResolver is OneHelpers {

    struct OneProtoData {
        TokenInterface sellToken;
        TokenInterface buyToken;
        uint _sellAmt;
        uint _buyAmt;
        uint unitAmt;
        uint[] distribution;
        uint disableDexes;
    }

    function oneProtoSwap(
        OneProtoInterface oneProtoContract,
        OneProtoData memory oneProtoData
    ) internal returns (uint buyAmt) {

        TokenInterface _sellAddr = oneProtoData.sellToken;
        TokenInterface _buyAddr = oneProtoData.buyToken;
        uint _sellAmt = oneProtoData._sellAmt;

        uint _slippageAmt = getSlippageAmt(_buyAddr, _sellAddr, _sellAmt, oneProtoData.unitAmt);

        uint ethAmt;
        if (address(_sellAddr) == getEthAddr()) {
            ethAmt = _sellAmt;
        } else {
            _sellAddr.approve(address(oneProtoContract), _sellAmt);
        }


        uint initalBal = getTokenBal(_buyAddr);
        oneProtoContract.swapWithReferral.value(ethAmt)(
            _sellAddr,
            _buyAddr,
            _sellAmt,
            _slippageAmt,
            oneProtoData.distribution,
            oneProtoData.disableDexes,
            getReferralAddr(),
            0
        );
        uint finalBal = getTokenBal(_buyAddr);

        buyAmt = sub(finalBal, initalBal);

        require(_slippageAmt <= buyAmt, "Too much slippage");
    }

    struct OneProtoMultiData {
        address[] tokens;
        TokenInterface sellToken;
        TokenInterface buyToken;
        uint _sellAmt;
        uint _buyAmt;
        uint unitAmt;
        uint[] distribution;
        uint[] disableDexes;
    }

    function oneProtoSwapMulti(OneProtoMultiData memory oneProtoData) internal returns (uint buyAmt) {

        TokenInterface _sellAddr = oneProtoData.sellToken;
        TokenInterface _buyAddr = oneProtoData.buyToken;
        uint _sellAmt = oneProtoData._sellAmt;
        uint _slippageAmt = getSlippageAmt(_buyAddr, _sellAddr, _sellAmt, oneProtoData.unitAmt);

        OneProtoInterface oneSplitContract = OneProtoInterface(getOneProtoAddress());
        uint ethAmt;
        if (address(_sellAddr) == getEthAddr()) {
            ethAmt = _sellAmt;
        } else {
            _sellAddr.approve(address(oneSplitContract), _sellAmt);
        }

        uint initalBal = getTokenBal(_buyAddr);
        oneSplitContract.swapWithReferralMulti.value(ethAmt)(
            convertToTokenInterface(oneProtoData.tokens),
            _sellAmt,
            _slippageAmt,
            oneProtoData.distribution,
            oneProtoData.disableDexes,
            getReferralAddr(),
            0
        );
        uint finalBal = getTokenBal(_buyAddr);

        buyAmt = sub(finalBal, initalBal);

        require(_slippageAmt <= buyAmt, "Too much slippage");
    }
}

contract OneInchResolver is OneProtoResolver {

    function checkOneInchSig(bytes memory callData) internal pure returns(bool isOk) {

        bytes memory _data = callData;
        bytes4 sig;
        assembly {
            sig := mload(add(_data, 32))
        }
        isOk = sig == getOneInchSig();
    }

    struct OneInchData {
        TokenInterface sellToken;
        TokenInterface buyToken;
        uint _sellAmt;
        uint _buyAmt;
        uint unitAmt;
        bytes callData;
    }

    function oneInchSwap(
        OneInchData memory oneInchData,
        uint ethAmt
    ) internal returns (uint buyAmt) {

        TokenInterface buyToken = oneInchData.buyToken;
        (uint _buyDec, uint _sellDec) = getTokensDec(buyToken, oneInchData.sellToken);
        uint _sellAmt18 = convertTo18(_sellDec, oneInchData._sellAmt);
        uint _slippageAmt = convert18ToDec(_buyDec, wmul(oneInchData.unitAmt, _sellAmt18));

        uint initalBal = getTokenBal(buyToken);

        (bool success, ) = address(getOneInchAddress()).call.value(ethAmt)(oneInchData.callData);
        if (!success) revert("1Inch-swap-failed");

        uint finalBal = getTokenBal(buyToken);

        buyAmt = sub(finalBal, initalBal);

        require(_slippageAmt <= buyAmt, "Too much slippage");
    }

}

contract OneProtoEventResolver is OneInchResolver {

    event LogSell(
        address indexed buyToken,
        address indexed sellToken,
        uint256 buyAmt,
        uint256 sellAmt,
        uint256 getId,
        uint256 setId
    );

    function emitLogSell(
        OneProtoData memory oneProtoData,
        uint256 getId,
        uint256 setId
    ) internal {

        bytes32 _eventCode;
        bytes memory _eventParam;
        emit LogSell(
            address(oneProtoData.buyToken),
            address(oneProtoData.sellToken),
            oneProtoData._buyAmt,
            oneProtoData._sellAmt,
            getId,
            setId
        );
        _eventCode = keccak256("LogSell(address,address,uint256,uint256,uint256,uint256)");
        _eventParam = abi.encode(
            address(oneProtoData.buyToken),
            address(oneProtoData.sellToken),
            oneProtoData._buyAmt,
            oneProtoData._sellAmt,
            getId,
            setId
        );
        emitEvent(_eventCode, _eventParam);
    }

    event LogSellTwo(
        address indexed buyToken,
        address indexed sellToken,
        uint256 buyAmt,
        uint256 sellAmt,
        uint256 getId,
        uint256 setId
    );

    function emitLogSellTwo(
        OneProtoData memory oneProtoData,
        uint256 getId,
        uint256 setId
    ) internal {

        bytes32 _eventCode;
        bytes memory _eventParam;
        emit LogSellTwo(
            address(oneProtoData.buyToken),
            address(oneProtoData.sellToken),
            oneProtoData._buyAmt,
            oneProtoData._sellAmt,
            getId,
            setId
        );
        _eventCode = keccak256("LogSellTwo(address,address,uint256,uint256,uint256,uint256)");
        _eventParam = abi.encode(
            address(oneProtoData.buyToken),
            address(oneProtoData.sellToken),
            oneProtoData._buyAmt,
            oneProtoData._sellAmt,
            getId,
            setId
        );
        emitEvent(_eventCode, _eventParam);
    }

    event LogSellMulti(
        address[] tokens,
        address indexed buyToken,
        address indexed sellToken,
        uint256 buyAmt,
        uint256 sellAmt,
        uint256 getId,
        uint256 setId
    );

    function emitLogSellMulti(
        OneProtoMultiData memory oneProtoData,
        uint256 getId,
        uint256 setId
    ) internal {

        bytes32 _eventCode;
        bytes memory _eventParam;
        emit LogSellMulti(
            oneProtoData.tokens,
            address(oneProtoData.buyToken),
            address(oneProtoData.sellToken),
            oneProtoData._buyAmt,
            oneProtoData._sellAmt,
            getId,
            setId
        );
        _eventCode = keccak256("LogSellMulti(address[],address,address,uint256,uint256,uint256,uint256)");
        _eventParam = abi.encode(
            oneProtoData.tokens,
            address(oneProtoData.buyToken),
            address(oneProtoData.sellToken),
            oneProtoData._buyAmt,
            oneProtoData._sellAmt,
            getId,
            setId
        );
        emitEvent(_eventCode, _eventParam);
    }
}

contract OneInchEventResolver is OneProtoEventResolver {

    event LogSellThree(
        address indexed buyToken,
        address indexed sellToken,
        uint256 buyAmt,
        uint256 sellAmt,
        uint256 getId,
        uint256 setId
    );

    function emitLogSellThree(
        OneInchData memory oneInchData,
        uint256 setId
    ) internal {

        bytes32 _eventCode;
        bytes memory _eventParam;
        emit LogSellThree(
            address(oneInchData.buyToken),
            address(oneInchData.sellToken),
            oneInchData._buyAmt,
            oneInchData._sellAmt,
            0,
            setId
        );
        _eventCode = keccak256("LogSellThree(address,address,uint256,uint256,uint256,uint256)");
        _eventParam = abi.encode(
            address(oneInchData.buyToken),
            address(oneInchData.sellToken),
            oneInchData._buyAmt,
            oneInchData._sellAmt,
            0,
            setId
        );
        emitEvent(_eventCode, _eventParam);
    }
}

contract OneProtoResolverHelpers is OneInchEventResolver {

    function _sell(
        OneProtoData memory oneProtoData,
        uint256 getId,
        uint256 setId
    ) internal {

        uint _sellAmt = getUint(getId, oneProtoData._sellAmt);

        oneProtoData._sellAmt = _sellAmt == uint(-1) ?
            getTokenBal(oneProtoData.sellToken) :
            _sellAmt;

        OneProtoInterface oneProtoContract = OneProtoInterface(getOneProtoAddress());

        (, oneProtoData.distribution) = oneProtoContract.getExpectedReturn(
                oneProtoData.sellToken,
                oneProtoData.buyToken,
                oneProtoData._sellAmt,
                5,
                0
            );

        oneProtoData._buyAmt = oneProtoSwap(
            oneProtoContract,
            oneProtoData
        );

        setUint(setId, oneProtoData._buyAmt);

        emitLogSell(oneProtoData, getId, setId);
    }

    function _sellTwo(
        OneProtoData memory oneProtoData,
        uint getId,
        uint setId
    ) internal {

        uint _sellAmt = getUint(getId, oneProtoData._sellAmt);

        oneProtoData._sellAmt = _sellAmt == uint(-1) ?
            getTokenBal(oneProtoData.sellToken) :
            _sellAmt;

        oneProtoData._buyAmt = oneProtoSwap(
            OneProtoInterface(getOneProtoAddress()),
            oneProtoData
        );

        setUint(setId, oneProtoData._buyAmt);
        emitLogSellTwo(oneProtoData, getId, setId);
    }

    function _sellMulti(
        OneProtoMultiData memory oneProtoData,
        uint getId,
        uint setId
    ) internal {

        uint _sellAmt = getUint(getId, oneProtoData._sellAmt);

        oneProtoData._sellAmt = _sellAmt == uint(-1) ?
            getTokenBal(oneProtoData.sellToken) :
            _sellAmt;

        oneProtoData._buyAmt = oneProtoSwapMulti(oneProtoData);
        setUint(setId, oneProtoData._buyAmt);

        emitLogSellMulti(oneProtoData, getId, setId);
    }
}

contract OneInchResolverHelpers is OneProtoResolverHelpers {

    function _sellThree(
        OneInchData memory oneInchData,
        uint setId
    ) internal {

        TokenInterface _sellAddr = oneInchData.sellToken;

        uint ethAmt;
        if (address(_sellAddr) == getEthAddr()) {
            ethAmt = oneInchData._sellAmt;
        } else {
            TokenInterface(_sellAddr).approve(getOneInchTokenTaker(), oneInchData._sellAmt);
        }

        require(checkOneInchSig(oneInchData.callData), "Not-swap-function");

        oneInchData._buyAmt = oneInchSwap(oneInchData, ethAmt);
        setUint(setId, oneInchData._buyAmt);

        emitLogSellThree(oneInchData, setId);
    }
}

contract OneProto is OneInchResolverHelpers {

    function sell(
        address buyAddr,
        address sellAddr,
        uint sellAmt,
        uint unitAmt,
        uint getId,
        uint setId
    ) external payable {

        OneProtoData memory oneProtoData = OneProtoData({
            buyToken: TokenInterface(buyAddr),
            sellToken: TokenInterface(sellAddr),
            _sellAmt: sellAmt,
            unitAmt: unitAmt,
            distribution: new uint[](0),
            _buyAmt: 0,
            disableDexes: 0
        });

        _sell(oneProtoData, getId, setId);
    }

    function sellTwo(
        address buyAddr,
        address sellAddr,
        uint sellAmt,
        uint unitAmt,
        uint[] calldata distribution,
        uint disableDexes,
        uint getId,
        uint setId
    ) external payable {

        OneProtoData memory oneProtoData = OneProtoData({
            buyToken: TokenInterface(buyAddr),
            sellToken: TokenInterface(sellAddr),
            _sellAmt: sellAmt,
            unitAmt: unitAmt,
            distribution: distribution,
            disableDexes: disableDexes,
            _buyAmt: 0
        });

        _sellTwo(oneProtoData, getId, setId);
    }

    function sellMulti(
        address[] calldata tokens,
        uint sellAmt,
        uint unitAmt,
        uint[] calldata distribution,
        uint[] calldata disableDexes,
        uint getId,
        uint setId
    ) external payable {

        OneProtoMultiData memory oneProtoData = OneProtoMultiData({
            tokens: tokens,
            buyToken: TokenInterface(address(tokens[tokens.length - 1])),
            sellToken: TokenInterface(address(tokens[0])),
            unitAmt: unitAmt,
            distribution: distribution,
            disableDexes: disableDexes,
            _sellAmt: sellAmt,
            _buyAmt: 0
        });

        _sellMulti(oneProtoData, getId, setId);
    }
}

contract OneInch is OneProto {

    function sellThree(
        address buyAddr,
        address sellAddr,
        uint sellAmt,
        uint unitAmt,
        bytes calldata callData,
        uint setId
    ) external payable {

        OneInchData memory oneInchData = OneInchData({
            buyToken: TokenInterface(buyAddr),
            sellToken: TokenInterface(sellAddr),
            unitAmt: unitAmt,
            callData: callData,
            _sellAmt: sellAmt,
            _buyAmt: 0
        });

        _sellThree(oneInchData, setId);
    }
}

contract ConnectOne is OneInch {

    string public name = "1inch-1proto-v1";
}