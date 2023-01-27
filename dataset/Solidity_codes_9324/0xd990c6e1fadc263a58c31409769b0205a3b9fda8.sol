
pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}pragma solidity =0.6.6;

interface IUniswapPairsOracle {

    function addPair(address tokenA, address tokenB) external returns (bool);


    function pairFor(address tokenA, address tokenB) external view returns(address);


    function update(address pair) external returns (bool);


    function consult(address pair, address token, uint256 amountIn)
        external
        view
        returns (uint256 amountOut);

    
}// MIT
pragma solidity =0.6.6;


interface IERC20 {

    function decimals() external view returns (uint8);

}

contract PriceOracle is Initializable {


    address public wethAddress;
    address public wethDaiPairAddress;
    IUniswapPairsOracle public UniswapPairsOracle;
    
    function initialize(IUniswapPairsOracle _UniswapPairsOracleAddress, address _wethAddress, address _daiAddress) public initializer {

        require(address(_UniswapPairsOracleAddress) != address(0), "PriceOracle: invalid _UniswapPairsOracleAddress");
        require(_wethAddress != address(0), "PriceOracle: invalid _wethAddress");
        require(_daiAddress != address(0), "PriceOracle: invalid _daiAddress");
        require(IERC20(_wethAddress).decimals() == 18, "PriceOracle: _wethAddress token should has 18 decimals");
        require(IERC20(_daiAddress).decimals() == 18, "PriceOracle: _daiAddress token should has 18 decimals");

        UniswapPairsOracle = _UniswapPairsOracleAddress;
        wethAddress = _wethAddress;
        UniswapPairsOracle.addPair(_wethAddress, _daiAddress);
        wethDaiPairAddress = UniswapPairsOracle.pairFor(_wethAddress, _daiAddress);
    }

    function addToken(address token) external returns (bool success) {

        return UniswapPairsOracle.addPair(wethAddress, token);
    }

    function update(address token) external {

        UniswapPairsOracle.update(wethDaiPairAddress);
        UniswapPairsOracle.update(UniswapPairsOracle.pairFor(wethAddress, token));
    }
    
    function priceOf(address token, uint256 amount) external view returns (uint256 daiAmount) {

        uint256 wethAmount = UniswapPairsOracle.consult(UniswapPairsOracle.pairFor(wethAddress, token), token, amount);
        if (wethAmount == 0) {
            return 0;
        }
        daiAmount = UniswapPairsOracle.consult(wethDaiPairAddress, wethAddress, wethAmount);
    }
}