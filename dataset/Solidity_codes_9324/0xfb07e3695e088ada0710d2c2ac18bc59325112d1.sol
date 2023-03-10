



pragma solidity ^0.8.3;

interface IAuthoriser {

    function isAuthorised(address _sender, address _spender, address _to, bytes calldata _data) external view returns (bool);

    function areAuthorised(
        address _spender,
        address[] calldata _spenders,
        address[] calldata _to,
        bytes[] calldata _data
    )
        external
        view
        returns (bool);

}// Copyright (C) 2021  Argent Labs Ltd. <https://argent.xyz>




pragma solidity ^0.8.3;

interface IFilter {

    function isValid(address _wallet, address _spender, address _to, bytes calldata _data) external view returns (bool valid);

}// Copyright (C) 2021  Argent Labs Ltd. <https://argent.xyz>




pragma solidity ^0.8.3;


abstract contract BaseFilter is IFilter {
    function getMethod(bytes memory _data) internal pure returns (bytes4 method) {
        assembly {
            method := mload(add(_data, 0x20))
        }
    }
}// Copyright (C) 2020  Argent Labs Ltd. <https://argent.xyz>




pragma solidity ^0.8.3;

library ParaswapUtils {

    address constant internal ETH_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    struct ZeroExV2Order {
        address makerAddress;
        address takerAddress;
        address feeRecipientAddress;
        address senderAddress;
        uint256 makerAssetAmount;
        uint256 takerAssetAmount;
        uint256 makerFee;
        uint256 takerFee;
        uint256 expirationTimeSeconds;
        uint256 salt;
        bytes makerAssetData;
        bytes takerAssetData;
    }

    struct ZeroExV2Data {
        ZeroExV2Order[] orders;
        bytes[] signatures;
    }

    struct ZeroExV4Order {
        address makerToken;
        address takerToken;
        uint128 makerAmount;
        uint128 takerAmount;
        address maker;
        address taker;
        address txOrigin;
        bytes32 pool;
        uint64 expiry;
        uint256 salt;
    }

    struct ZeroExV4Signature {
        uint8 signatureType;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct ZeroExV4Data {
        ZeroExV4Order order;
        ZeroExV4Signature signature;
    }

    function hasValidUniV3Pool(
        address _fromToken,
        address _toToken,
        uint24 _fee,
        address _tokenRegistry,
        address _factory,
        bytes32 _initCode,
        address _weth
    )
        internal
        view
        returns (bool)
    {

        address poolToken = uniV3PoolFor(_fromToken, _toToken, _fee, _factory, _initCode, _weth);
        return hasTradableToken(_tokenRegistry, poolToken);
    }

    function hasValidUniV2Path(
        address[] memory _path,
        address _tokenRegistry,
        address _factory,
        bytes32 _initCode,
        address _weth
    )
        internal
        view
        returns (bool)
    {

        address[] memory lpTokens = new address[](_path.length - 1);
        for(uint i = 0; i < lpTokens.length; i++) {
            lpTokens[i] = uniV2PairFor(_path[i], _path[i+1], _factory, _initCode, _weth);
        }
        return hasTradableTokens(_tokenRegistry, lpTokens);
    }

    function uniV3PoolFor(
        address _tokenA,
        address _tokenB,
        uint24 _fee,
        address _factory,
        bytes32 _initCode,
        address _weth
    )
        internal
        pure
        returns (address)
    {

        (address tokenA, address tokenB) = (_tokenA == ETH_TOKEN ? _weth : _tokenA, _tokenB == ETH_TOKEN ? _weth : _tokenB);
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        return(address(uint160(uint(keccak256(abi.encodePacked(
            hex"ff",
            _factory,
            keccak256(abi.encode(token0, token1, _fee)),
            _initCode
        ))))));
    }

    function uniV2PairFor(address _tokenA, address _tokenB, address _factory, bytes32 _initCode, address _weth) internal pure returns (address) {

        (address tokenA, address tokenB) = (_tokenA == ETH_TOKEN ? _weth : _tokenA, _tokenB == ETH_TOKEN ? _weth : _tokenB);
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        return(address(uint160(uint(keccak256(abi.encodePacked(
            hex"ff",
            _factory,
            keccak256(abi.encodePacked(token0, token1)),
            _initCode
        ))))));
    }

    function hasTradableTokens(address _tokenRegistry, address[] memory _tokens) internal view returns (bool) {

        (bool success, bytes memory res) = _tokenRegistry.staticcall(abi.encodeWithSignature("areTokensTradable(address[])", _tokens));
        return success && abi.decode(res, (bool));
    
    }
    function hasTradableToken(address _tokenRegistry, address _token) internal view returns (bool) {

        (bool success, bytes memory res) = _tokenRegistry.staticcall(abi.encodeWithSignature("isTokenTradable(address)", _token));
        return success && abi.decode(res, (bool));
    }
}// Copyright (C) 2020  Argent Labs Ltd. <https://argent.xyz>




pragma solidity ^0.8.3;

library Utils {


    bytes4 private constant ERC20_TRANSFER = bytes4(keccak256("transfer(address,uint256)"));
    bytes4 private constant ERC20_APPROVE = bytes4(keccak256("approve(address,uint256)"));
    bytes4 private constant ERC721_SET_APPROVAL_FOR_ALL = bytes4(keccak256("setApprovalForAll(address,bool)"));
    bytes4 private constant ERC721_TRANSFER_FROM = bytes4(keccak256("transferFrom(address,address,uint256)"));
    bytes4 private constant ERC721_SAFE_TRANSFER_FROM = bytes4(keccak256("safeTransferFrom(address,address,uint256)"));
    bytes4 private constant ERC721_SAFE_TRANSFER_FROM_BYTES = bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)"));
    bytes4 private constant ERC1155_SAFE_TRANSFER_FROM = bytes4(keccak256("safeTransferFrom(address,address,uint256,uint256,bytes)"));

    bytes4 private constant OWNER_SIG = 0x8da5cb5b;
    function recoverSigner(bytes32 _signedHash, bytes memory _signatures, uint _index) internal pure returns (address) {

        uint8 v;
        bytes32 r;
        bytes32 s;
        assembly {
            r := mload(add(_signatures, add(0x20,mul(0x41,_index))))
            s := mload(add(_signatures, add(0x40,mul(0x41,_index))))
            v := and(mload(add(_signatures, add(0x41,mul(0x41,_index)))), 0xff)
        }
        require(v == 27 || v == 28, "Utils: bad v value in signature");

        address recoveredAddress = ecrecover(_signedHash, v, r, s);
        require(recoveredAddress != address(0), "Utils: ecrecover returned 0");
        return recoveredAddress;
    }

    function recoverSpender(address _to, bytes memory _data) internal pure returns (address spender) {

        if(_data.length >= 68) {
            bytes4 methodId;
            assembly {
                methodId := mload(add(_data, 0x20))
            }
            if(
                methodId == ERC20_TRANSFER ||
                methodId == ERC20_APPROVE ||
                methodId == ERC721_SET_APPROVAL_FOR_ALL) 
            {
                assembly {
                    spender := mload(add(_data, 0x24))
                }
                return spender;
            }
            if(
                methodId == ERC721_TRANSFER_FROM ||
                methodId == ERC721_SAFE_TRANSFER_FROM ||
                methodId == ERC721_SAFE_TRANSFER_FROM_BYTES ||
                methodId == ERC1155_SAFE_TRANSFER_FROM)
            {
                assembly {
                    spender := mload(add(_data, 0x44))
                }
                return spender;
            }
        }

        spender = _to;
    }

    function functionPrefix(bytes memory _data) internal pure returns (bytes4 prefix) {

        require(_data.length >= 4, "Utils: Invalid functionPrefix");
        assembly {
            prefix := mload(add(_data, 0x20))
        }
    }

    function isContract(address _addr) internal view returns (bool) {

        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function isGuardianOrGuardianSigner(address[] memory _guardians, address _guardian) internal view returns (bool, address[] memory) {

        if (_guardians.length == 0 || _guardian == address(0)) {
            return (false, _guardians);
        }
        bool isFound = false;
        address[] memory updatedGuardians = new address[](_guardians.length - 1);
        uint256 index = 0;
        for (uint256 i = 0; i < _guardians.length; i++) {
            if (!isFound) {
                if (_guardian == _guardians[i]) {
                    isFound = true;
                    continue;
                }
                if (isContract(_guardians[i]) && isGuardianOwner(_guardians[i], _guardian)) {
                    isFound = true;
                    continue;
                }
            }
            if (index < updatedGuardians.length) {
                updatedGuardians[index] = _guardians[i];
                index++;
            }
        }
        return isFound ? (true, updatedGuardians) : (false, _guardians);
    }

    function isGuardianOwner(address _guardian, address _owner) internal view returns (bool) {

        address owner = address(0);

        assembly {
            let ptr := mload(0x40)
            mstore(ptr,OWNER_SIG)
            let result := staticcall(25000, _guardian, ptr, 0x20, ptr, 0x20)
            if eq(result, 1) {
                owner := mload(ptr)
            }
        }
        return owner == _owner;
    }

    function ceil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        if (a % b == 0) {
            return c;
        } else {
            return c + 1;
        }
    }
}// Copyright (C) 2021  Argent Labs Ltd. <https://argent.xyz>




pragma solidity ^0.8.3;


interface IUniswapV1Factory {

    function getExchange(address token) external view returns (address);

}

interface IParaswapUniswapProxy {

    function UNISWAP_FACTORY() external view returns (address);

    function UNISWAP_INIT_CODE() external view returns (bytes32);

    function WETH() external view returns (address);

}

interface IParaswap {

    struct Route {
        address payable exchange;
        address targetExchange;
        uint256 percent;
        bytes payload;
        uint256 networkFee;
    }

    struct Path {
        address to;
        uint256 totalNetworkFee;
        Route[] routes;
    }

    struct SellData {
        address fromToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address payable beneficiary;
        string referrer;
        bool useReduxToken;
        Path[] path;
    }

    struct MegaSwapPath {
        uint256 fromAmountPercent;
        Path[] path;
    }

    struct MegaSwapSellData {
        address fromToken;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 expectedAmount;
        address payable beneficiary;
        string referrer;
        bool useReduxToken;
        MegaSwapPath[] path;
    }

    struct UniswapV2Data {
        address[] path;
    }

    struct UniswapV3Data {
        uint24 fee;
        uint256 deadline;
        uint160 sqrtPriceLimitX96;
    }

    function getUniswapProxy() external view returns (address);

}

contract ParaswapFilter is BaseFilter {


    bytes4 constant internal MULTISWAP = bytes4(keccak256(
        "multiSwap((address,uint256,uint256,uint256,address,string,bool,(address,uint256,(address,address,uint256,bytes,uint256)[])[]))"
    ));
    bytes4 constant internal SIMPLESWAP = bytes4(keccak256(
        "simpleSwap(address,address,uint256,uint256,uint256,address[],bytes,uint256[],uint256[],address,string,bool)"
    ));
    bytes4 constant internal SWAP_ON_UNI = bytes4(keccak256(
        "swapOnUniswap(uint256,uint256,address[],uint8)"
    ));
    bytes4 constant internal SWAP_ON_UNI_FORK = bytes4(keccak256(
        "swapOnUniswapFork(address,bytes32,uint256,uint256,address[],uint8)"
    ));
    bytes4 constant internal MEGASWAP = bytes4(keccak256(
        "megaSwap((address,uint256,uint256,uint256,address,string,bool,(uint256,(address,uint256,(address,address,uint256,bytes,uint256)[])[])[]))"
    ));
    bytes4 constant internal WITHDRAW_ALL_WETH = bytes4(keccak256("withdrawAllWETH(address)"));

    address public immutable tokenRegistry;
    address public immutable augustus;
    mapping(address => bool) public targetExchanges;
    mapping(address => bool) public marketMakers;
    address public immutable uniV1Adapter;
    address public immutable uniV2Adapter;
    address public immutable sushiswapAdapter;
    address public immutable linkswapAdapter;
    address public immutable defiswapAdapter;
    address public immutable zeroExV2Adapter;
    address public immutable zeroExV4Adapter;
    address public immutable curveAdapter;
    address public immutable wethAdapter;
    address public immutable uniV3Adapter;
    IAuthoriser public immutable authoriser;
    address public immutable uniswapProxy;
    bool public isValidUniswapProxy = true;
    address public immutable weth;

    address public immutable uniFactory; // uniswap
    address public immutable uniForkFactory1; // sushiswap
    address public immutable uniForkFactory2; // linkswap
    address public immutable uniForkFactory3; // defiswap
    address public immutable uniV3Factory; // uniV3
    bytes32 public immutable uniInitCode; // uniswap
    bytes32 public immutable uniForkInitCode1; // sushiswap
    bytes32 public immutable uniForkInitCode2; // linkswap
    bytes32 public immutable uniForkInitCode3; // defiswap
    bytes32 public immutable uniV3InitCode; // uniV3

    constructor(
        address _tokenRegistry,
        IAuthoriser _authoriser,
        address _augustus,
        address _uniswapProxy,
        address[4] memory _uniFactories,
        bytes32[4] memory _uniInitCodes,
        address[10] memory _adapters,
        address[] memory _targetExchanges,
        address[] memory _marketMakers
    ) {
        tokenRegistry = _tokenRegistry;
        authoriser = _authoriser;
        augustus = _augustus;
        uniswapProxy = _uniswapProxy;
        weth = IParaswapUniswapProxy(_uniswapProxy).WETH();
        uniFactory = IParaswapUniswapProxy(_uniswapProxy).UNISWAP_FACTORY();
        uniInitCode = IParaswapUniswapProxy(_uniswapProxy).UNISWAP_INIT_CODE();
        uniForkFactory1 = _uniFactories[0];
        uniForkFactory2 = _uniFactories[1];
        uniForkFactory3 = _uniFactories[2];
        uniV3Factory = _uniFactories[3];
        uniForkInitCode1 = _uniInitCodes[0];
        uniForkInitCode2 = _uniInitCodes[1];
        uniForkInitCode3 = _uniInitCodes[2];
        uniV3InitCode = _uniInitCodes[3];
        uniV1Adapter = _adapters[0];
        uniV2Adapter = _adapters[1];
        sushiswapAdapter = _adapters[2];
        linkswapAdapter = _adapters[3];
        defiswapAdapter = _adapters[4];
        zeroExV2Adapter = _adapters[5];
        zeroExV4Adapter = _adapters[6];
        curveAdapter = _adapters[7];
        wethAdapter = _adapters[8];
        uniV3Adapter = _adapters[9];
        for(uint i = 0; i < _targetExchanges.length; i++) {
            targetExchanges[_targetExchanges[i]] = true;
        }
        for(uint i = 0; i < _marketMakers.length; i++) {
            marketMakers[_marketMakers[i]] = true;
        }
    }

    function updateIsValidUniswapProxy() external {

        isValidUniswapProxy = (uniswapProxy == IParaswap(augustus).getUniswapProxy());
    }

    function isValid(address _wallet, address /*_spender*/, address _to, bytes calldata _data) external view override returns (bool valid) {

        if (_data.length < 4 || _to != augustus) {
            return false;
        }
        bytes4 methodId = getMethod(_data);
        if(methodId == MULTISWAP) {
            return isValidMultiSwap(_wallet, _data);
        } 
        if(methodId == SIMPLESWAP) {
            return isValidSimpleSwap(_wallet, _to, _data);
        }
        if(methodId == SWAP_ON_UNI) {
            return isValidUniSwap(_data);
        }
        if(methodId == SWAP_ON_UNI_FORK) {
            return isValidUniForkSwap(_data);
        }
        if(methodId == MEGASWAP) {
            return isValidMegaSwap(_wallet, _data);
        }
        return false;
    }

    function isValidMultiSwap(address _wallet, bytes calldata _data) internal view returns (bool) {

        (IParaswap.SellData memory sell) = abi.decode(_data[4:], (IParaswap.SellData));
        return hasValidBeneficiary(_wallet, sell.beneficiary) && hasValidPath(sell.fromToken, sell.path);
    }

    function isValidSimpleSwap(address _wallet, address _augustus, bytes calldata _data) internal view returns (bool) {

        (,address toToken,, address[] memory callees,, uint256[] memory startIndexes,, address beneficiary) 
            = abi.decode(_data[4:], (address, address, uint256[3],address[],bytes,uint256[],uint256[],address));
        return hasValidBeneficiary(_wallet, beneficiary) &&
            hasTradableToken(toToken) &&
            hasAuthorisedCallees(_augustus, callees, startIndexes, _data);
    }

    function isValidUniSwap(bytes calldata _data) internal view returns (bool) {

        if(!isValidUniswapProxy) {
            return false;
        }
        (, address[] memory path) = abi.decode(_data[4:], (uint256[2], address[]));
        return ParaswapUtils.hasValidUniV2Path(path, tokenRegistry, uniFactory, uniInitCode, weth);
    }

    function isValidUniForkSwap(bytes calldata _data) internal view returns (bool) {

        if(!isValidUniswapProxy) {
            return false;
        }
        (address factory, bytes32 initCode,, address[] memory path) = abi.decode(_data[4:], (address, bytes32, uint256[2], address[]));
        return factory != address(0) && initCode != bytes32(0) && (
            (
                factory == uniForkFactory1 &&
                initCode == uniForkInitCode1 &&
                ParaswapUtils.hasValidUniV2Path(path, tokenRegistry, uniForkFactory1, uniForkInitCode1, weth)
            ) || (
                factory == uniForkFactory2 &&
                initCode == uniForkInitCode2 &&
                ParaswapUtils.hasValidUniV2Path(path, tokenRegistry, uniForkFactory2, uniForkInitCode2, weth)
            ) || (
                factory == uniForkFactory3 &&
                initCode == uniForkInitCode3 &&
                ParaswapUtils.hasValidUniV2Path(path, tokenRegistry, uniForkFactory3, uniForkInitCode3, weth)
            )
        );
    }

    function isValidMegaSwap(address _wallet, bytes calldata _data) internal view returns (bool) {

        (IParaswap.MegaSwapSellData memory sell) = abi.decode(_data[4:], (IParaswap.MegaSwapSellData));
        return hasValidBeneficiary(_wallet, sell.beneficiary) && hasValidMegaPath(sell.fromToken, sell.path);
    }

    function hasAuthorisedCallees(
        address _augustus,
        address[] memory _callees,
        uint256[] memory _startIndexes,
        bytes calldata _data
    )
        internal
        view
        returns (bool)
    {

        uint256 exchangeDataOffset = 36 + abi.decode(_data[196:228], (uint256)); 
        address[] memory to = new address[](_callees.length);
        address[] memory spenders = new address[](_callees.length);
        bytes[] memory allData = new bytes[](_callees.length);
        uint256 j; // index pointing to the last elements added to the output arrays `to`, `spenders` and `allData`
        for(uint256 i; i < _callees.length; i++) {
            bytes calldata slicedExchangeData = _data[exchangeDataOffset+_startIndexes[i] : exchangeDataOffset+_startIndexes[i+1]];
            if(_callees[i] == _augustus) {
                if(slicedExchangeData.length >= 4 && getMethod(slicedExchangeData) == WITHDRAW_ALL_WETH) {
                    uint newLength = _callees.length - 1;
                    assembly {
                        mstore(to, newLength)
                        mstore(spenders, newLength)
                        mstore(allData, newLength)
                    }
                } else {
                    return false;
                }
            } else {
                to[j] = _callees[i];
                allData[j] = slicedExchangeData;
                spenders[j] = Utils.recoverSpender(_callees[i], slicedExchangeData);
                j++;
            }
        }
        return authoriser.areAuthorised(_augustus, spenders, to, allData);
    }

    function hasValidBeneficiary(address _wallet, address _beneficiary) internal pure returns (bool) {

        return (_beneficiary == address(0) || _beneficiary == _wallet);
    }

    function hasTradableToken(address _destToken) internal view returns (bool) {

        if(_destToken == ParaswapUtils.ETH_TOKEN) {
            return true;
        }
        (bool success, bytes memory res) = tokenRegistry.staticcall(abi.encodeWithSignature("isTokenTradable(address)", _destToken));
        return success && abi.decode(res, (bool));
    }

    function hasValidPath(address _fromToken, IParaswap.Path[] memory _path) internal view returns (bool) {

        for (uint i = 0; i < _path.length; i++) {
            for (uint j = 0; j < _path[i].routes.length; j++) {
                if(!hasValidRoute(_path[i].routes[j], (i == 0) ? _fromToken : _path[i-1].to, _path[i].to)) {
                    return false;
                }
            }
        }
        return true;
    }

    function hasValidRoute(IParaswap.Route memory _route, address _fromToken, address _toToken) internal view returns (bool) {

        if(_route.targetExchange != address(0) && !targetExchanges[_route.targetExchange]) {
            return false;
        }
        if(_route.exchange == wethAdapter) { 
            return true;
        }
        if(_route.exchange == uniV2Adapter) { 
            return hasValidUniV2Route(_route.payload, uniFactory, uniInitCode);
        } 
        if(_route.exchange == sushiswapAdapter) { 
            return hasValidUniV2Route(_route.payload, uniForkFactory1, uniForkInitCode1);
        }
        if(_route.exchange == zeroExV4Adapter) { 
            return hasValidZeroExV4Route(_route.payload);
        }
        if(_route.exchange == zeroExV2Adapter) { 
            return hasValidZeroExV2Route(_route.payload);
        }
        if(_route.exchange == uniV3Adapter) { 
            return hasValidUniV3Route(_route.payload, _fromToken, _toToken);
        }
        if(_route.exchange == curveAdapter) { 
            return true;
        }
        if(_route.exchange == linkswapAdapter) { 
            return hasValidUniV2Route(_route.payload, uniForkFactory2, uniForkInitCode2);
        }
        if(_route.exchange == defiswapAdapter) { 
            return hasValidUniV2Route(_route.payload, uniForkFactory3, uniForkInitCode3);
        }
        if(_route.exchange == uniV1Adapter) { 
            return hasValidUniV1Route(_route.targetExchange, _fromToken, _toToken);
        }
        return false;  
    }

    function hasValidUniV3Route(bytes memory _payload, address _fromToken, address _toToken) internal view returns (bool) {

        IParaswap.UniswapV3Data memory data = abi.decode(_payload, (IParaswap.UniswapV3Data));
        return ParaswapUtils.hasValidUniV3Pool(_fromToken, _toToken, data.fee, tokenRegistry, uniV3Factory, uniV3InitCode, weth);
    }

    function hasValidUniV2Route(bytes memory _payload, address _factory, bytes32 _initCode) internal view returns (bool) {

        IParaswap.UniswapV2Data memory data = abi.decode(_payload, (IParaswap.UniswapV2Data));
        return ParaswapUtils.hasValidUniV2Path(data.path, tokenRegistry, _factory, _initCode, weth);
    }

    function hasValidUniV1Route(address _uniV1Factory, address _fromToken, address _toToken) internal view returns (bool) {

        address pool = IUniswapV1Factory(_uniV1Factory).getExchange(_fromToken == ParaswapUtils.ETH_TOKEN ? _toToken : _fromToken);
        return hasTradableToken(pool);
    }

    function hasValidZeroExV4Route(bytes memory _payload) internal view returns (bool) {

        ParaswapUtils.ZeroExV4Data memory data = abi.decode(_payload, (ParaswapUtils.ZeroExV4Data));
        return marketMakers[data.order.maker];
    }

    function hasValidZeroExV2Route(bytes memory _payload) internal view returns (bool) {

        ParaswapUtils.ZeroExV2Data memory data = abi.decode(_payload, (ParaswapUtils.ZeroExV2Data));
        for(uint i = 0; i < data.orders.length; i++) {
            if(!marketMakers[data.orders[i].makerAddress]) {
                return false;
            }
        }
        return true;
    }

    function hasValidMegaPath(address _fromToken, IParaswap.MegaSwapPath[] memory _megaPath) internal view returns (bool) {

        for(uint i = 0; i < _megaPath.length; i++) {
            if(!hasValidPath(_fromToken, _megaPath[i].path)) {
                return false;
            }
        }
        return true;
    }
}