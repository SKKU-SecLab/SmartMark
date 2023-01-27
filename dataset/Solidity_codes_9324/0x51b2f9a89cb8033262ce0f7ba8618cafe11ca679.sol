
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3Factory {

    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    function owner() external view returns (address);


    function feeAmountTickSpacing(uint24 fee) external view returns (int24);


    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);


    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);


    function setOwner(address _owner) external;


    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;


interface ITimeWeightedOracle {

  event AddedSupportForPair(address _tokenA, address _tokenB);

  function canSupportPair(address _tokenA, address _tokenB) external view returns (bool _canSupport);


  function quote(
    address _tokenIn,
    uint128 _amountIn,
    address _tokenOut
  ) external view returns (uint256 _amountOut);


  function addSupportForPair(address _tokenA, address _tokenB) external;

}

interface IUniswapV3OracleAggregator is ITimeWeightedOracle {

  event AddedFeeTier(uint24 _feeTier);

  event PeriodChanged(uint32 _period);

  function factory() external view returns (IUniswapV3Factory _factory);


  function supportedFeeTiers() external view returns (uint24[] memory _feeTiers);


  function poolsUsedForPair(address _tokenA, address _tokenB) external view returns (address[] memory _pools);


  function period() external view returns (uint16 _period);


  function MINIMUM_PERIOD() external view returns (uint16);


  function MAXIMUM_PERIOD() external view returns (uint16);


  function MINIMUM_LIQUIDITY_THRESHOLD() external view returns (uint16);


  function addFeeTier(uint24 _feeTier) external;


  function setPeriod(uint16 _period) external;

}// GPL-2.0-or-later
pragma solidity ^0.8.6;


interface IDCAPairParameters {

  function globalParameters() external view returns (IDCAGlobalParameters);


  function tokenA() external view returns (IERC20Metadata);


  function tokenB() external view returns (IERC20Metadata);


  function swapAmountDelta(
    uint32 _swapInterval,
    address _from,
    uint32 _swap
  ) external view returns (int256 _delta);


  function isSwapIntervalActive(uint32 _swapInterval) external view returns (bool _isActive);


  function performedSwaps(uint32 _swapInterval) external view returns (uint32 _swaps);

}

interface IDCAPairPositionHandler is IDCAPairParameters {

  struct UserPosition {
    IERC20Metadata from;
    IERC20Metadata to;
    uint32 swapInterval;
    uint32 swapsExecuted;
    uint256 swapped;
    uint32 swapsLeft;
    uint256 remaining;
    uint160 rate;
  }

  event Terminated(address indexed _user, uint256 _dcaId, uint256 _returnedUnswapped, uint256 _returnedSwapped);

  event Deposited(
    address indexed _user,
    uint256 _dcaId,
    address _fromToken,
    uint160 _rate,
    uint32 _startingSwap,
    uint32 _swapInterval,
    uint32 _lastSwap
  );

  event Withdrew(address indexed _user, uint256 _dcaId, address _token, uint256 _amount);

  event WithdrewMany(address indexed _user, uint256[] _dcaIds, uint256 _swappedTokenA, uint256 _swappedTokenB);

  event Modified(address indexed _user, uint256 _dcaId, uint160 _rate, uint32 _startingSwap, uint32 _lastSwap);

  error InvalidToken();

  error InvalidInterval();

  error InvalidPosition();

  error UnauthorizedCaller();

  error ZeroRate();

  error ZeroSwaps();

  error ZeroAmount();

  error PositionCompleted();

  error MandatoryWithdraw();

  function userPosition(uint256 _dcaId) external view returns (UserPosition memory _position);


  function deposit(
    address _tokenAddress,
    uint160 _rate,
    uint32 _amountOfSwaps,
    uint32 _swapInterval
  ) external returns (uint256 _dcaId);


  function withdrawSwapped(uint256 _dcaId) external returns (uint256 _swapped);


  function withdrawSwappedMany(uint256[] calldata _dcaIds) external returns (uint256 _swappedTokenA, uint256 _swappedTokenB);


  function modifyRate(uint256 _dcaId, uint160 _newRate) external;


  function modifySwaps(uint256 _dcaId, uint32 _newSwaps) external;


  function modifyRateAndSwaps(
    uint256 _dcaId,
    uint160 _newRate,
    uint32 _newSwaps
  ) external;


  function addFundsToPosition(
    uint256 _dcaId,
    uint256 _amount,
    uint32 _newSwaps
  ) external;


  function terminate(uint256 _dcaId) external;

}

interface IDCAPairSwapHandler {

  struct SwapInformation {
    uint32 interval;
    uint32 swapToPerform;
    uint256 amountToSwapTokenA;
    uint256 amountToSwapTokenB;
  }

  struct NextSwapInformation {
    SwapInformation[] swapsToPerform;
    uint8 amountOfSwaps;
    uint256 availableToBorrowTokenA;
    uint256 availableToBorrowTokenB;
    uint256 ratePerUnitBToA;
    uint256 ratePerUnitAToB;
    uint256 platformFeeTokenA;
    uint256 platformFeeTokenB;
    uint256 amountToBeProvidedBySwapper;
    uint256 amountToRewardSwapperWith;
    IERC20Metadata tokenToBeProvidedBySwapper;
    IERC20Metadata tokenToRewardSwapperWith;
  }

  event Swapped(
    address indexed _sender,
    address indexed _to,
    uint256 _amountBorrowedTokenA,
    uint256 _amountBorrowedTokenB,
    uint32 _fee,
    NextSwapInformation _nextSwapInformation
  );

  error NoSwapsToExecute();

  function nextSwapAvailable(uint32 _swapInterval) external view returns (uint32 _when);


  function swapAmountAccumulator(uint32 _swapInterval, address _from) external view returns (uint256);


  function getNextSwapInfo() external view returns (NextSwapInformation memory _nextSwapInformation);


  function swap() external;


  function swap(
    uint256 _amountToBorrowTokenA,
    uint256 _amountToBorrowTokenB,
    address _to,
    bytes calldata _data
  ) external;


  function secondsUntilNextSwap() external view returns (uint32 _secondsUntilNextSwap);

}

interface IDCAPairLoanHandler {

  event Loaned(address indexed _sender, address indexed _to, uint256 _amountBorrowedTokenA, uint256 _amountBorrowedTokenB, uint32 _loanFee);

  error ZeroLoan();

  function availableToBorrow() external view returns (uint256 _amountToBorrowTokenA, uint256 _amountToBorrowTokenB);


  function loan(
    uint256 _amountToBorrowTokenA,
    uint256 _amountToBorrowTokenB,
    address _to,
    bytes calldata _data
  ) external;

}

interface IDCAPair is IDCAPairParameters, IDCAPairSwapHandler, IDCAPairPositionHandler, IDCAPairLoanHandler {}// GPL-2.0-or-later

pragma solidity ^0.8.6;


interface IDCATokenDescriptor {

  function tokenURI(IDCAPairPositionHandler _positionHandler, uint256 _tokenId) external view returns (string memory _description);

}// GPL-2.0-or-later
pragma solidity ^0.8.6;


interface IDCAGlobalParameters {

  struct SwapParameters {
    address feeRecipient;
    bool isPaused;
    uint32 swapFee;
    ITimeWeightedOracle oracle;
  }

  struct LoanParameters {
    address feeRecipient;
    bool isPaused;
    uint32 loanFee;
  }

  event FeeRecipientSet(address _feeRecipient);

  event NFTDescriptorSet(IDCATokenDescriptor _descriptor);

  event OracleSet(ITimeWeightedOracle _oracle);

  event SwapFeeSet(uint32 _feeSet);

  event LoanFeeSet(uint32 _feeSet);

  event SwapIntervalsAllowed(uint32[] _swapIntervals, string[] _descriptions);

  event SwapIntervalsForbidden(uint32[] _swapIntervals);

  error HighFee();

  error InvalidParams();

  error ZeroInterval();

  error EmptyDescription();

  function feeRecipient() external view returns (address _feeRecipient);


  function swapFee() external view returns (uint32 _swapFee);


  function loanFee() external view returns (uint32 _loanFee);


  function nftDescriptor() external view returns (IDCATokenDescriptor _nftDescriptor);


  function oracle() external view returns (ITimeWeightedOracle _oracle);


  function FEE_PRECISION() external view returns (uint24 _precision);


  function MAX_FEE() external view returns (uint32 _maxFee);


  function allowedSwapIntervals() external view returns (uint32[] memory _allowedSwapIntervals);


  function intervalDescription(uint32 _swapInterval) external view returns (string memory _description);


  function isSwapIntervalAllowed(uint32 _swapInterval) external view returns (bool _isAllowed);


  function paused() external view returns (bool _isPaused);


  function swapParameters() external view returns (SwapParameters memory _swapParameters);


  function loanParameters() external view returns (LoanParameters memory _loanParameters);


  function setFeeRecipient(address _feeRecipient) external;


  function setSwapFee(uint32 _fee) external;


  function setLoanFee(uint32 _fee) external;


  function setNFTDescriptor(IDCATokenDescriptor _descriptor) external;


  function setOracle(ITimeWeightedOracle _oracle) external;


  function addSwapIntervalsToAllowedList(uint32[] calldata _swapIntervals, string[] calldata _descriptions) external;


  function removeSwapIntervalsFromAllowedList(uint32[] calldata _swapIntervals) external;


  function pause() external;


  function unpause() external;

}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

library Base64 {

    string internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return '';
        
        string memory table = TABLE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)
            
            let tablePtr := add(table, 1)
            
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))
            
            let resultPtr := add(result, 32)
            
            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 3)
               
               let input := mload(dataPtr)
               
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(        input,  0x3F)))))
               resultPtr := add(resultPtr, 1)
            }
            
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }
        
        return result;
    }
}// GPL-2.0-or-later
pragma solidity ^0.8.6;


library NFTSVG {

  using Strings for uint256;
  using Strings for uint32;

  struct SVGParams {
    string tokenA;
    string tokenB;
    string tokenASymbol;
    string tokenBSymbol;
    string interval;
    uint32 swapsExecuted;
    uint32 swapsLeft;
    uint256 tokenId;
    string swapped;
    string averagePrice;
    string remaining;
    string rate;
  }

  function generateSVG(SVGParams memory params) internal pure returns (string memory svg) {

    return
      string(
        abi.encodePacked(
          _generateSVGDefs(),
          _generateSVGBorderText(params.tokenA, params.tokenB, params.tokenASymbol, params.tokenBSymbol),
          _generateSVGCardMantle(params.tokenASymbol, params.tokenBSymbol, params.interval),
          _generageSVGProgressArea(params.swapsExecuted, params.swapsLeft),
          _generateSVGPositionData(params.tokenId, params.swapped, params.averagePrice, params.remaining, params.rate),
          '</svg>'
        )
      );
  }

  function _generateSVGDefs() private pure returns (string memory svg) {

    svg = string(
      abi.encodePacked(
        '<svg width="290" height="560" viewBox="0 0 290 560" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
        '<defs><linearGradient x1="118.1%" y1="10.5%" x2="-18.1%" y2="89.5%" gradientUnits="userSpaceOnUse" id="LinearGradient"><stop stop-color="rgba(13, 5, 20, 1)" offset="0"></stop><stop stop-color="rgba(47, 19, 66, 1)" offset="0.7"></stop><stop stop-color="rgba(35, 17, 51, 1)" offset="1"></stop></linearGradient><clipPath id="corners"><rect width="290" height="560" rx="40" ry="40" /></clipPath><path id="text-path-a" d="M40 12 H250 A28 28 0 0 1 278 40 V520 A28 28 0 0 1 250 548 H40 A28 28 0 0 1 12 520 V40 A28 28 0 0 1 40 12 z" /><mask id="none" maskContentUnits="objectBoundingBox"><rect width="1" height="1" fill="white" /></mask><linearGradient id="grad-symbol"><stop offset="0.8" stop-color="white" stop-opacity="1" /><stop offset=".95" stop-color="white" stop-opacity="0" /></linearGradient><mask id="fade-symbol" maskContentUnits="userSpaceOnUse"><rect width="290px" height="200px" fill="url(#grad-symbol)" /></mask></defs>',
        '<g clip-path="url(#corners)">',
        '<rect width="290" height="560" x="0" y="0" fill="url(#LinearGradient)"></rect>',
        '<path d="M290 0L248.61 0L290 61.48z" fill="rgba(255, 255, 255, .1)"></path>',
        '<path d="M248.61 0L290 61.48L290 189.35999999999999L200.75 0z" fill="rgba(255, 255, 255, .075)"></path>',
        '<path d="M200.75 0L290 189.35999999999999L290 294.91999999999996L112.52 0z" fill="rgba(255, 255, 255, .05)"></path>',
        '<path d="M112.51999999999998 0L290 294.91999999999996L290 357.79999999999995L32.78999999999998 0z" fill="rgba(255, 255, 255, .025)"></path>',
        '<path d="M0 560L40.27 560L0 402.35z" fill="rgba(0, 0, 0, .1)"></path>',
        '<path d="M0 402.35L40.27 560L137.96 560L0 221.89000000000001z" fill="rgba(0, 0, 0, .075)"></path>',
        '<path d="M0 221.89L137.96 560L153.85600000000002 560L0 183.92z" fill="rgba(0, 0, 0, .05)"></path>',
        '<path d="M0 183.91999999999996L153.85000000000002 560L156.66000000000003 560L0 151.61999999999995z" fill="rgba(0, 0, 0, .025)"></path>',
        '</g>'
      )
    );
  }

  function _generateSVGBorderText(
    string memory _tokenA,
    string memory _tokenB,
    string memory _tokenASymbol,
    string memory _tokenBSymbol
  ) private pure returns (string memory svg) {

    string memory _tokenAText = string(abi.encodePacked(_tokenA, unicode' • ', _tokenASymbol));
    string memory _tokenBText = string(abi.encodePacked(_tokenB, unicode' • ', _tokenBSymbol));
    svg = string(
      abi.encodePacked(
        '<text text-rendering="optimizeSpeed"><textPath startOffset="-100%" fill="white" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
        _tokenAText,
        '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /></textPath><textPath startOffset="0%" fill="white" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
        _tokenAText,
        '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /></textPath><textPath startOffset="50%" fill="white" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
        _tokenBText,
        '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /></textPath><textPath startOffset="-50%" fill="white" font-family="\'Courier New\', monospace" font-size="10px" xlink:href="#text-path-a">',
        _tokenBText,
        '<animate additive="sum" attributeName="startOffset" from="0%" to="100%" begin="0s" dur="30s" repeatCount="indefinite" /></textPath></text>'
      )
    );
  }

  function _generateSVGCardMantle(
    string memory _tokenASymbol,
    string memory _tokenBSymbol,
    string memory _interval
  ) private pure returns (string memory svg) {

    svg = string(
      abi.encodePacked(
        '<g mask="url(#fade-symbol)">'
        '<rect fill="none" x="0px" y="0px" width="290px" height="200px" />'
        '<text y="70px" x="32px" fill="white" font-family="\'Courier New\', monospace" font-weight="200" font-size="35px">',
        _tokenASymbol,
        '/',
        _tokenBSymbol,
        '</text>',
        '<text y="115px" x="32px" fill="white" font-family="\'Courier New\', monospace" font-weight="200" font-size="28px">',
        _interval,
        '</text>'
        '</g>'
      )
    );
  }

  function _generageSVGProgressArea(uint32 _swapsExecuted, uint32 _swapsLeft) private pure returns (string memory svg) {

    uint256 _positionNow = 170 + ((314 - 170) / (_swapsExecuted + _swapsLeft)) * _swapsExecuted;
    svg = string(
      abi.encodePacked(
        '<rect x="16" y="16" width="258" height="528" rx="26" ry="26" fill="rgba(0,0,0,0)" stroke="rgba(255,255,255,0.2)" />',
        '<g mask="url(#none)" style="transform:translate(80px,169px)"><rect x="-16px" y="-16px" width="180px" height="180px" fill="none" /><path d="M1 1 L1 145" stroke="rgba(0,0,0,0.3)" stroke-width="32px" fill="none" stroke-linecap="round" /></g>',
        '<g mask="url(#none)" style="transform:translate(80px,169px)"><rect x="-16px" y="-16px" width="180px" height="180px" fill="none" /><path d="M1 1 L1 145" stroke="rgba(255,255,255,1)" fill="none" stroke-linecap="round" /></g>',
        '<circle cx="81px" cy="170px" r="4px" fill="#dddddd" />',
        '<circle cx="81px" cy="',
        _positionNow.toString(),
        'px" r="5px" fill="white" />',
        '<circle cx="81px" cy="314px" r="4px" fill="#dddddd" /><text x="100px" y="174px" font-family="\'Courier New\', monospace" font-size="12px" fill="white"><tspan fill="rgba(255,255,255,0.6)">Executed*: </tspan>',
        _swapsExecuted.toString(),
        ' swaps</text><text x="40px" y="',
        (_positionNow + 4).toString(),
        'px" font-family="\'Courier New\', monospace" font-size="12px" fill="white">Now</text><text x="100px" y="318px" font-family="\'Courier New\', monospace" font-size="12px" fill="white"><tspan fill="rgba(255,255,255,0.6)">Left: </tspan>',
        _swapsLeft.toString(),
        ' swaps</text>'
      )
    );
  }

  function _generateSVGPositionData(
    uint256 _tokenId,
    string memory _swapped,
    string memory _averagePrice,
    string memory _remaining,
    string memory _rate
  ) private pure returns (string memory svg) {

    svg = string(
      abi.encodePacked(
        _generateData('Id', _tokenId.toString(), 364),
        _generateData('Swapped*', _swapped, 394),
        _generateData('Avg Price', _averagePrice, 424),
        _generateData('Remaining', _remaining, 454),
        _generateData('Rate', _rate, 484),
        '<g style="transform:translate(25px, 514px)">',
        '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="10px" fill="white">',
        '<tspan fill="rgba(255,255,255,0.8)">* since start or last edit/withdraw</tspan>',
        '</text>',
        '</g>'
      )
    );
  }

  function _generateData(
    string memory _title,
    string memory _data,
    uint256 _yCoord
  ) private pure returns (string memory svg) {

    uint256 _strLength = bytes(_title).length + bytes(_data).length + 2;
    svg = string(
      abi.encodePacked(
        '<g style="transform:translate(29px, ',
        _yCoord.toString(),
        'px)">',
        '<rect width="',
        uint256(7 * (_strLength + 4)).toString(),
        'px" height="26px" rx="8px" ry="8px" fill="rgba(0,0,0,0.6)" />',
        '<text x="12px" y="17px" font-family="\'Courier New\', monospace" font-size="12px" fill="white">',
        '<tspan fill="rgba(255,255,255,0.6)">',
        _title,
        ': </tspan>',
        _data,
        '</text>',
        '</g>'
      )
    );
  }
}// GPL-2.0-or-later
pragma solidity >=0.7.0;
pragma abicoder v2;


library NFTDescriptor {

  using Strings for uint256;
  using Strings for uint32;

  struct ConstructTokenURIParams {
    address pair;
    address tokenA;
    address tokenB;
    uint8 tokenADecimals;
    uint8 tokenBDecimals;
    string tokenASymbol;
    string tokenBSymbol;
    string swapInterval;
    uint32 swapsExecuted;
    uint32 swapsLeft;
    uint256 tokenId;
    uint256 swapped;
    uint256 remaining;
    uint160 rate;
    bool fromA;
  }

  function constructTokenURI(ConstructTokenURIParams memory _params) internal pure returns (string memory) {

    string memory _name = _generateName(_params);

    string memory _description = _generateDescription(
      _params.tokenASymbol,
      _params.tokenBSymbol,
      addressToString(_params.pair),
      addressToString(_params.tokenA),
      addressToString(_params.tokenB),
      _params.swapInterval,
      _params.tokenId
    );

    string memory _image = Base64.encode(bytes(_generateSVGImage(_params)));

    return
      string(
        abi.encodePacked(
          'data:application/json;base64,',
          Base64.encode(
            bytes(
              abi.encodePacked(
                '{"name":"',
                _name,
                '", "description":"',
                _description,
                '", "image": "',
                'data:image/svg+xml;base64,',
                _image,
                '"}'
              )
            )
          )
        )
      );
  }

  function _escapeQuotes(string memory _symbol) private pure returns (string memory) {

    bytes memory symbolBytes = bytes(_symbol);
    uint8 quotesCount = 0;
    for (uint8 i = 0; i < symbolBytes.length; i++) {
      if (symbolBytes[i] == '"') {
        quotesCount++;
      }
    }
    if (quotesCount > 0) {
      bytes memory escapedBytes = new bytes(symbolBytes.length + (quotesCount));
      uint256 index;
      for (uint8 i = 0; i < symbolBytes.length; i++) {
        if (symbolBytes[i] == '"') {
          escapedBytes[index++] = '\\';
        }
        escapedBytes[index++] = symbolBytes[i];
      }
      return string(escapedBytes);
    }
    return _symbol;
  }

  function _generateDescription(
    string memory _tokenASymbol,
    string memory _tokenBSymbol,
    string memory _pairAddress,
    string memory _tokenAAddress,
    string memory _tokenBAddress,
    string memory _interval,
    uint256 _tokenId
  ) private pure returns (string memory) {

    string memory _part1 = string(
      abi.encodePacked(
        'This NFT represents a position in a Mean Finance DCA ',
        _escapeQuotes(_tokenASymbol),
        '-',
        _escapeQuotes(_tokenBSymbol),
        ' pair. ',
        'The owner of this NFT can modify or redeem the position.\\n',
        '\\nPair Address: ',
        _pairAddress,
        '\\n',
        _escapeQuotes(_tokenASymbol)
      )
    );
    string memory _part2 = string(
      abi.encodePacked(
        ' Address: ',
        _tokenAAddress,
        '\\n',
        _escapeQuotes(_tokenBSymbol),
        ' Address: ',
        _tokenBAddress,
        '\\nSwap interval: ',
        _interval,
        '\\nToken ID: ',
        _tokenId.toString(),
        '\\n\\n',
        unicode'⚠️ DISCLAIMER: Due diligence is imperative when assessing this NFT. Make sure token addresses match the expected tokens, as token symbols may be imitated.'
      )
    );
    return string(abi.encodePacked(_part1, _part2));
  }

  function _generateName(ConstructTokenURIParams memory _params) private pure returns (string memory) {

    return
      string(
        abi.encodePacked(
          'Mean Finance DCA - ',
          _params.swapInterval,
          ' - ',
          _escapeQuotes(_params.tokenASymbol),
          '/',
          _escapeQuotes(_params.tokenBSymbol)
        )
      );
  }

  struct DecimalStringParams {
    uint256 sigfigs;
    uint8 bufferLength;
    uint8 sigfigIndex;
    uint8 decimalIndex;
    uint8 zerosStartIndex;
    uint8 zerosEndIndex;
    bool isLessThanOne;
  }

  function _generateDecimalString(DecimalStringParams memory params) private pure returns (string memory) {

    bytes memory buffer = new bytes(params.bufferLength);
    if (params.isLessThanOne) {
      buffer[0] = '0';
      buffer[1] = '.';
    }

    for (uint256 zerosCursor = params.zerosStartIndex; zerosCursor < params.zerosEndIndex + 1; zerosCursor++) {
      buffer[zerosCursor] = bytes1(uint8(48));
    }
    while (params.sigfigs > 0) {
      if (params.decimalIndex > 0 && params.sigfigIndex == params.decimalIndex) {
        buffer[params.sigfigIndex--] = '.';
      }
      uint8 charIndex = uint8(48 + (params.sigfigs % 10));
      buffer[params.sigfigIndex] = bytes1(charIndex);
      params.sigfigs /= 10;
      if (params.sigfigs > 0) {
        params.sigfigIndex--;
      }
    }
    return string(buffer);
  }

  function _sigfigsRounded(uint256 value, uint8 digits) private pure returns (uint256, bool) {

    bool extraDigit;
    if (digits > 5) {
      value = value / (10**(digits - 5));
    }
    bool roundUp = value % 10 > 4;
    value = value / 10;
    if (roundUp) {
      value = value + 1;
    }
    if (value == 100000) {
      value /= 10;
      extraDigit = true;
    }
    return (value, extraDigit);
  }

  function fixedPointToDecimalString(uint256 value, uint8 decimals) internal pure returns (string memory) {

    if (value == 0) {
      return '0.0000';
    }

    bool priceBelow1 = value < 10**decimals;

    uint256 temp = value;
    uint8 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    digits = digits - 1;

    (uint256 sigfigs, bool extraDigit) = _sigfigsRounded(value, digits);
    if (extraDigit) {
      digits++;
    }

    DecimalStringParams memory params;
    if (priceBelow1) {
      params.bufferLength = uint8(digits >= 5 ? decimals - digits + 6 : decimals + 2);
      params.zerosStartIndex = 2;
      params.zerosEndIndex = uint8(decimals - digits + 1);
      params.sigfigIndex = uint8(params.bufferLength - 1);
    } else if (digits >= decimals + 4) {
      params.bufferLength = uint8(digits - decimals + 1);
      params.zerosStartIndex = 5;
      params.zerosEndIndex = uint8(params.bufferLength - 1);
      params.sigfigIndex = 4;
    } else {
      params.bufferLength = 6;
      params.sigfigIndex = 5;
      params.decimalIndex = uint8(digits - decimals + 1);
    }
    params.sigfigs = sigfigs;
    params.isLessThanOne = priceBelow1;

    return _generateDecimalString(params);
  }

  function addressToString(address _addr) internal pure returns (string memory) {

    bytes memory s = new bytes(40);
    for (uint256 i = 0; i < 20; i++) {
      bytes1 b = bytes1(uint8(uint256(uint160(_addr)) / (2**(8 * (19 - i)))));
      bytes1 hi = bytes1(uint8(b) / 16);
      bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
      s[2 * i] = _char(hi);
      s[2 * i + 1] = _char(lo);
    }
    return string(abi.encodePacked('0x', string(s)));
  }

  function _char(bytes1 b) private pure returns (bytes1 c) {

    if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
    else return bytes1(uint8(b) + 0x57);
  }

  function _generateSVGImage(ConstructTokenURIParams memory _params) private pure returns (string memory svg) {

    string memory _fromSymbol;
    string memory _toSymbol;
    uint8 _fromDecimals;
    uint8 _toDecimals;
    if (_params.fromA) {
      _fromSymbol = _escapeQuotes(_params.tokenASymbol);
      _fromDecimals = _params.tokenADecimals;
      _toSymbol = _escapeQuotes(_params.tokenBSymbol);
      _toDecimals = _params.tokenBDecimals;
    } else {
      _fromSymbol = _escapeQuotes(_params.tokenBSymbol);
      _fromDecimals = _params.tokenBDecimals;
      _toSymbol = _escapeQuotes(_params.tokenASymbol);
      _toDecimals = _params.tokenADecimals;
    }
    NFTSVG.SVGParams memory _svgParams = NFTSVG.SVGParams({
      tokenId: _params.tokenId,
      tokenA: addressToString(_params.tokenA),
      tokenB: addressToString(_params.tokenB),
      tokenASymbol: _escapeQuotes(_params.tokenASymbol),
      tokenBSymbol: _escapeQuotes(_params.tokenBSymbol),
      interval: _params.swapInterval,
      swapsExecuted: _params.swapsExecuted,
      swapsLeft: _params.swapsLeft,
      swapped: string(abi.encodePacked(fixedPointToDecimalString(_params.swapped, _toDecimals), ' ', _toSymbol)),
      averagePrice: string(
        abi.encodePacked(
          fixedPointToDecimalString(_params.swapsExecuted > 0 ? _params.swapped / _params.swapsExecuted : 0, _toDecimals),
          ' ',
          _toSymbol
        )
      ),
      remaining: string(abi.encodePacked(fixedPointToDecimalString(_params.remaining, _fromDecimals), ' ', _fromSymbol)),
      rate: string(abi.encodePacked(fixedPointToDecimalString(_params.rate, _fromDecimals), ' ', _fromSymbol))
    });

    return NFTSVG.generateSVG(_svgParams);
  }
}// GPL-2.0-or-later
pragma solidity ^0.8.6;


contract DCATokenDescriptor is IDCATokenDescriptor {

  function tokenURI(IDCAPairPositionHandler _positionHandler, uint256 _tokenId) external view override returns (string memory) {

    IERC20Metadata _tokenA = _positionHandler.tokenA();
    IERC20Metadata _tokenB = _positionHandler.tokenB();
    IDCAGlobalParameters _globalParameters = _positionHandler.globalParameters();
    IDCAPairPositionHandler.UserPosition memory _userPosition = _positionHandler.userPosition(_tokenId);

    return
      NFTDescriptor.constructTokenURI(
        NFTDescriptor.ConstructTokenURIParams({
          tokenId: _tokenId,
          pair: address(_positionHandler),
          tokenA: address(_tokenA),
          tokenB: address(_tokenB),
          tokenADecimals: _tokenA.decimals(),
          tokenBDecimals: _tokenB.decimals(),
          tokenASymbol: _tokenA.symbol(),
          tokenBSymbol: _tokenB.symbol(),
          swapInterval: _globalParameters.intervalDescription(_userPosition.swapInterval),
          swapsExecuted: _userPosition.swapsExecuted,
          swapped: _userPosition.swapped,
          swapsLeft: _userPosition.swapsLeft,
          remaining: _userPosition.remaining,
          rate: _userPosition.rate,
          fromA: _userPosition.from == _tokenA
        })
      );
  }
}