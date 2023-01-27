
pragma solidity 0.4.26;


contract ContractIds {

    bytes32 public constant CONTRACT_FEATURES = "ContractFeatures";
    bytes32 public constant CONTRACT_REGISTRY = "ContractRegistry";
    bytes32 public constant NON_STANDARD_TOKEN_REGISTRY = "NonStandardTokenRegistry";

    bytes32 public constant BANCOR_NETWORK = "BancorNetwork";
    bytes32 public constant BANCOR_FORMULA = "BancorFormula";
    bytes32 public constant BANCOR_GAS_PRICE_LIMIT = "BancorGasPriceLimit";
    bytes32 public constant BANCOR_CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 public constant BANCOR_CONVERTER_FACTORY = "BancorConverterFactory";

    bytes32 public constant BNT_TOKEN = "BNTToken";
    bytes32 public constant BNT_CONVERTER = "BNTConverter";

    bytes32 public constant BANCOR_X = "BancorX";
    bytes32 public constant BANCOR_X_UPGRADER = "BancorXUpgrader";
}


contract Utils {

    constructor() public {
    }

    modifier greaterThanZero(uint256 _amount) {

        require(_amount > 0);
        _;
    }

    modifier validAddress(address _address) {

        require(_address != address(0));
        _;
    }

    modifier notThis(address _address) {

        require(_address != address(this));
        _;
    }

}


contract IContractRegistry {

    function addressOf(bytes32 _contractName) public view returns (address);


    function getAddress(bytes32 _contractName) public view returns (address);

}


contract IBancorConverterRegistry {

    function tokens(uint256 _index) public view returns (address) { _index; }

    function tokenCount() public view returns (uint256);

    function converterCount(address _token) public view returns (uint256);

    function converterAddress(address _token, uint32 _index) public view returns (address);

    function latestConverterAddress(address _token) public view returns (address);

    function tokenAddress(address _converter) public view returns (address);

}


contract IERC20Token {

    function name() public view returns (string) {}

    function symbol() public view returns (string) {}
    function decimals() public view returns (uint8) {}

    function totalSupply() public view returns (uint256) {}
    function balanceOf(address _owner) public view returns (uint256) { _owner; }

    function allowance(address _owner, address _spender) public view returns (uint256) { _owner; _spender; }


    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

}


contract IWhitelist {

    function isWhitelisted(address _address) public view returns (bool);

}


contract IBancorConverter {

    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public view returns (uint256, uint256);

    function convert2(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public returns (uint256);

    function quickConvert2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public payable returns (uint256);

    function conversionWhitelist() public view returns (IWhitelist) {}

    function conversionFee() public view returns (uint32) {}
    function reserves(address _address) public view returns (uint256, uint32, bool, bool, bool) { _address; }

    function getReserveBalance(IERC20Token _reserveToken) public view returns (uint256);

    function reserveTokens(uint256 _index) public view returns (IERC20Token) { _index; }

    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);

    function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);

    function quickConvert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);

    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool);

    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256);

    function connectorTokens(uint256 _index) public view returns (IERC20Token);

}


contract IOwned {

    function owner() public view returns (address) {}


    function transferOwnership(address _newOwner) public;

    function acceptOwnership() public;

}


contract ISmartToken is IOwned, IERC20Token {

    function disableTransfers(bool _disable) public;

    function issue(address _to, uint256 _amount) public;

    function destroy(address _from, uint256 _amount) public;

}


contract ISmartTokenController {

    function claimTokens(address _from, uint256 _amount) public;

    function token() public view returns (ISmartToken) {}

}


contract BancorNetworkPathFinder is ContractIds, Utils {
    IContractRegistry public contractRegistry;
    address public anchorToken;

    bytes4 private constant CONNECTOR_TOKEN_COUNT = bytes4(uint256(keccak256("connectorTokenCount()") >> (256 - 4 * 8)));
    bytes4 private constant RESERVE_TOKEN_COUNT   = bytes4(uint256(keccak256("reserveTokenCount()"  ) >> (256 - 4 * 8)));

    constructor(IContractRegistry _contractRegistry) public validAddress(_contractRegistry) {
        contractRegistry = _contractRegistry;
        anchorToken = contractRegistry.addressOf(BNT_TOKEN);
    }

    function updateAnchorToken() external {
        address bntToken = contractRegistry.addressOf(BNT_TOKEN);
        require(anchorToken != bntToken);
        anchorToken = bntToken;
    }

    function get(address _sourceToken, address _targetToken, IBancorConverterRegistry[] memory _converterRegistries) public view returns (address[] memory) {
        assert(anchorToken == contractRegistry.addressOf(BNT_TOKEN));
        address[] memory sourcePath = getPath(_sourceToken, _converterRegistries);
        address[] memory targetPath = getPath(_targetToken, _converterRegistries);
        return getShortestPath(sourcePath, targetPath);
    }

    function getPath(address _token, IBancorConverterRegistry[] memory _converterRegistries) private view returns (address[] memory) {
        if (_token == anchorToken) {
            address[] memory initialPath = new address[](1);
            initialPath[0] = _token;
            return initialPath;
        }

        uint256 tokenCount;
        uint256 i;
        address token;
        address[] memory path;

        for (uint256 n = 0; n < _converterRegistries.length; n++) {
            IBancorConverter converter = IBancorConverter(_converterRegistries[n].latestConverterAddress(_token));
            tokenCount = getTokenCount(converter, CONNECTOR_TOKEN_COUNT);
            for (i = 0; i < tokenCount; i++) {
                token = converter.connectorTokens(i);
                if (token != _token) {
                    path = getPath(token, _converterRegistries);
                    if (path.length > 0)
                        return getNewPath(path, _token, converter);
                }
            }
            tokenCount = getTokenCount(converter, RESERVE_TOKEN_COUNT);
            for (i = 0; i < tokenCount; i++) {
                token = converter.reserveTokens(i);
                if (token != _token) {
                    path = getPath(token, _converterRegistries);
                    if (path.length > 0)
                        return getNewPath(path, _token, converter);
                }
            }
        }

        return new address[](0);
    }

    function getTokenCount(address _dest, bytes4 _funcSelector) private view returns (uint256) {
        uint256[1] memory ret;
        bytes memory data = abi.encodeWithSelector(_funcSelector);

        assembly {
            pop(staticcall(
                gas,           // gas remaining
                _dest,         // destination address
                add(data, 32), // input buffer (starts after the first 32 bytes in the `data` array)
                mload(data),   // input length (loaded from the first 32 bytes in the `data` array)
                ret,           // output buffer
                32             // output length
            ))
        }

        return ret[0];
    }

    function getNewPath(address[] memory _path, address _token, IBancorConverter _converter) private view returns (address[] memory) {
        address[] memory newPath = new address[](2 + _path.length);
        newPath[0] = _token;
        newPath[1] = ISmartTokenController(_converter).token();
        for (uint256 k = 0; k < _path.length; k++)
            newPath[2 + k] = _path[k];
        return newPath;
    }

    function getShortestPath(address[] memory _sourcePath, address[] memory _targetPath) private pure returns (address[] memory) {
        if (_sourcePath.length > 0 && _targetPath.length > 0) {
            uint256 i = _sourcePath.length;
            uint256 j = _targetPath.length;
            while (i > 0 && j > 0 && _sourcePath[i - 1] == _targetPath[j - 1]) {
                i--;
                j--;
            }

            address[] memory path = new address[](i + j + 1);
            for (uint256 m = 0; m <= i; m++)
                path[m] = _sourcePath[m];
            for (uint256 n = j; n > 0; n--)
                path[path.length - n] = _targetPath[n - 1];
            return path;
        }

        return new address[](0);
    }
}