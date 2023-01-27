
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

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

interface IERC20Permit {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

pragma solidity 0.8.3;

interface IUniswap {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}// MIT

pragma solidity 0.8.3;


interface ISwapManager {

    event OracleCreated(address indexed _sender, address indexed _newOracle, uint256 _period);

    function N_DEX() external view returns (uint256);


    function ROUTERS(uint256 i) external view returns (IUniswap);


    function bestOutputFixedInput(
        address _from,
        address _to,
        uint256 _amountIn
    )
        external
        view
        returns (
            address[] memory path,
            uint256 amountOut,
            uint256 rIdx
        );


    function bestPathFixedInput(
        address _from,
        address _to,
        uint256 _amountIn,
        uint256 _i
    ) external view returns (address[] memory path, uint256 amountOut);


    function bestInputFixedOutput(
        address _from,
        address _to,
        uint256 _amountOut
    )
        external
        view
        returns (
            address[] memory path,
            uint256 amountIn,
            uint256 rIdx
        );


    function bestPathFixedOutput(
        address _from,
        address _to,
        uint256 _amountOut,
        uint256 _i
    ) external view returns (address[] memory path, uint256 amountIn);


    function safeGetAmountsOut(
        uint256 _amountIn,
        address[] memory _path,
        uint256 _i
    ) external view returns (uint256[] memory result);


    function unsafeGetAmountsOut(
        uint256 _amountIn,
        address[] memory _path,
        uint256 _i
    ) external view returns (uint256[] memory result);


    function safeGetAmountsIn(
        uint256 _amountOut,
        address[] memory _path,
        uint256 _i
    ) external view returns (uint256[] memory result);


    function unsafeGetAmountsIn(
        uint256 _amountOut,
        address[] memory _path,
        uint256 _i
    ) external view returns (uint256[] memory result);


    function comparePathsFixedInput(
        address[] memory pathA,
        address[] memory pathB,
        uint256 _amountIn,
        uint256 _i
    ) external view returns (address[] memory path, uint256 amountOut);


    function comparePathsFixedOutput(
        address[] memory pathA,
        address[] memory pathB,
        uint256 _amountOut,
        uint256 _i
    ) external view returns (address[] memory path, uint256 amountIn);


    function ours(address a) external view returns (bool);


    function oracleCount() external view returns (uint256);


    function oracleAt(uint256 idx) external view returns (address);


    function getOracle(
        address _tokenA,
        address _tokenB,
        uint256 _period,
        uint256 _i
    ) external view returns (address);


    function createOrUpdateOracle(
        address _tokenA,
        address _tokenB,
        uint256 _period,
        uint256 _i
    ) external returns (address oracleAddr);


    function consultForFree(
        address _from,
        address _to,
        uint256 _amountIn,
        uint256 _period,
        uint256 _i
    ) external view returns (uint256 amountOut, uint256 lastUpdatedAt);


    function consult(
        address _from,
        address _to,
        uint256 _amountIn,
        uint256 _period,
        uint256 _i
    )
        external
        returns (
            uint256 amountOut,
            uint256 lastUpdatedAt,
            bool updated
        );


    function updateOracles() external returns (uint256 updated, uint256 expected);


    function updateOracles(address[] memory _oracleAddrs) external returns (uint256 updated, uint256 expected);

}// MIT

pragma solidity 0.8.3;

interface CToken is IERC20 {

    function accrueInterest() external returns (uint256);


    function balanceOfUnderlying(address owner) external returns (uint256);


    function exchangeRateCurrent() external returns (uint256);


    function exchangeRateStored() external view returns (uint256);


    function mint() external payable; // For ETH


    function mint(uint256 mintAmount) external returns (uint256); // For ERC20


    function redeem(uint256 redeemTokens) external returns (uint256);


    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

}

interface Comptroller {

    function claimComp(address holder, address[] memory) external;


    function compAccrued(address holder) external view returns (uint256);

}// MIT

pragma solidity 0.8.3;


interface IVUSD is IERC20, IERC20Permit {

    function burnFrom(address _user, uint256 _amount) external;


    function mint(address _to, uint256 _amount) external;


    function multiTransfer(address[] memory _recipients, uint256[] memory _amounts) external returns (bool);


    function updateMinter(address _newMinter) external;


    function updateTreasury(address _newTreasury) external;


    function governor() external view returns (address _governor);


    function minter() external view returns (address _minter);


    function treasury() external view returns (address _treasury);

}// MIT

pragma solidity 0.8.3;

interface ITreasury {

    function withdraw(address _token, uint256 _amount) external;


    function withdraw(
        address _token,
        uint256 _amount,
        address _tokenReceiver
    ) external;


    function isWhitelistedToken(address _address) external view returns (bool);


    function oracles(address _token) external view returns (address);


    function withdrawable(address _token) external view returns (uint256);


    function whitelistedTokens() external view returns (address[] memory);


    function vusd() external view returns (address);

}// MIT

pragma solidity 0.8.3;


contract Treasury is Context, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    string public constant NAME = "VUSD-Treasury";
    string public constant VERSION = "1.3.0";

    IVUSD public immutable vusd;
    address public redeemer;

    ISwapManager public swapManager = ISwapManager(0xC48ea9A2daA4d816e4c9333D6689C70070010174);

    mapping(address => address) public cTokens;
    mapping(address => address) public oracles;

    address private constant COMP = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
    Comptroller private constant COMPTROLLER = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);

    EnumerableSet.AddressSet private _whitelistedTokens;
    EnumerableSet.AddressSet private _cTokenList;
    EnumerableSet.AddressSet private _keepers;

    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    address private constant cDAI = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    address private constant cUSDC = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;
    address private constant cUSDT = 0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9;

    address private constant DAI_USD = 0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9;
    address private constant USDC_USD = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;
    address private constant USDT_USD = 0x3E7d1eAB13ad0104d2750B8863b489D65364e32D;

    event UpdatedRedeemer(address indexed previousRedeemer, address indexed newRedeemer);
    event UpdatedSwapManager(address indexed previousSwapManager, address indexed newSwapManager);

    constructor(address _vusd) {
        require(_vusd != address(0), "vusd-address-is-zero");
        vusd = IVUSD(_vusd);

        _keepers.add(_msgSender());

        _addToken(DAI, cDAI, DAI_USD);
        _addToken(USDC, cUSDC, USDC_USD);
        _addToken(USDT, cUSDT, USDT_USD);

        _approveRouters(swapManager, type(uint256).max);
    }

    modifier onlyGovernor() {

        require(_msgSender() == governor(), "caller-is-not-the-governor");
        _;
    }

    modifier onlyAuthorized() {

        require(_msgSender() == governor() || _msgSender() == redeemer, "caller-is-not-authorized");
        _;
    }

    modifier onlyKeeperOrGovernor() {

        require(_msgSender() == governor() || _keepers.contains(_msgSender()), "caller-is-not-authorized");
        _;
    }

    function addWhitelistedToken(
        address _token,
        address _cToken,
        address _oracle
    ) external onlyGovernor {

        require(_token != address(0), "token-address-is-zero");
        require(_cToken != address(0), "cToken-address-is-zero");
        require(_oracle != address(0), "oracle-address-is-zero");
        _addToken(_token, _cToken, _oracle);
    }

    function removeWhitelistedToken(address _token) external onlyGovernor {

        require(_whitelistedTokens.remove(_token), "remove-from-list-failed");
        require(_cTokenList.remove(cTokens[_token]), "remove-from-list-failed");
        IERC20(_token).safeApprove(cTokens[_token], 0);
        delete cTokens[_token];
        delete cTokens[_token];
    }

    function updateRedeemer(address _newRedeemer) external onlyGovernor {

        require(_newRedeemer != address(0), "redeemer-address-is-zero");
        require(redeemer != _newRedeemer, "same-redeemer");
        emit UpdatedRedeemer(redeemer, _newRedeemer);
        redeemer = _newRedeemer;
    }

    function addKeeper(address _keeperAddress) external onlyGovernor {

        require(_keeperAddress != address(0), "keeper-address-is-zero");
        require(_keepers.add(_keeperAddress), "add-keeper-failed");
    }

    function removeKeeper(address _keeperAddress) external onlyGovernor {

        require(_keepers.remove(_keeperAddress), "remove-keeper-failed");
    }

    function updateSwapManager(address _newSwapManager) external onlyGovernor {

        require(_newSwapManager != address(0), "swap-manager-address-is-zero");
        emit UpdatedSwapManager(address(swapManager), _newSwapManager);
        _approveRouters(swapManager, 0);
        _approveRouters(ISwapManager(_newSwapManager), type(uint256).max);
        swapManager = ISwapManager(_newSwapManager);
    }


    function claimCompAndConvertTo(address _toToken, uint256 _minOut) external onlyKeeperOrGovernor {

        require(_whitelistedTokens.contains(_toToken), "token-is-not-supported");
        COMPTROLLER.claimComp(address(this), _cTokenList.values());
        uint256 _compAmount = IERC20(COMP).balanceOf(address(this));
        (address[] memory path, uint256 amountOut, uint256 rIdx) = swapManager.bestOutputFixedInput(
            COMP,
            _toToken,
            _compAmount
        );
        if (amountOut != 0) {
            swapManager.ROUTERS(rIdx).swapExactTokensForTokens(
                _compAmount,
                _minOut,
                path,
                address(this),
                block.timestamp
            );
        }
        require(CToken(cTokens[_toToken]).mint(IERC20(_toToken).balanceOf(address(this))) == 0, "cToken-mint-failed");
    }

    function migrate(address _newTreasury) external onlyGovernor {

        require(_newTreasury != address(0), "new-treasury-address-is-zero");
        require(address(vusd) == ITreasury(_newTreasury).vusd(), "vusd-mismatch");
        uint256 _len = _cTokenList.length();
        for (uint256 i = 0; i < _len; i++) {
            address _cToken = _cTokenList.at(i);
            IERC20(_cToken).safeTransfer(_newTreasury, IERC20(_cToken).balanceOf(address(this)));
        }
    }

    function withdraw(address _token, uint256 _amount) external nonReentrant onlyAuthorized {

        _withdraw(_token, _amount, _msgSender());
    }

    function withdraw(
        address _token,
        uint256 _amount,
        address _tokenReceiver
    ) external nonReentrant onlyAuthorized {

        _withdraw(_token, _amount, _tokenReceiver);
    }

    function withdrawMulti(address[] memory _tokens, uint256[] memory _amounts) external nonReentrant onlyGovernor {

        require(_tokens.length == _amounts.length, "input-length-mismatch");
        for (uint256 i = 0; i < _tokens.length; i++) {
            _withdraw(_tokens[i], _amounts[i], _msgSender());
        }
    }

    function withdrawAll(address[] memory _tokens) external nonReentrant onlyGovernor {

        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_whitelistedTokens.contains(_tokens[i]), "token-is-not-supported");
            CToken _cToken = CToken(cTokens[_tokens[i]]);
            require(_cToken.redeem(_cToken.balanceOf(address(this))) == 0, "redeem-failed");
            IERC20(_tokens[i]).safeTransfer(_msgSender(), IERC20(_tokens[i]).balanceOf(address(this)));
        }
    }

    function sweep(address _fromToken) external onlyGovernor {

        require(!_cTokenList.contains(_fromToken), "cToken-is-not-allowed-to-sweep");

        uint256 _amount = IERC20(_fromToken).balanceOf(address(this));
        IERC20(_fromToken).safeTransfer(_msgSender(), _amount);
    }

    function withdrawable(address _token) external view returns (uint256) {

        if (cTokens[_token] != address(0)) {
            CToken _cToken = CToken(cTokens[_token]);
            return (_cToken.balanceOf(address(this)) * _cToken.exchangeRateStored()) / 1e18;
        }
        return 0;
    }

    function governor() public view returns (address) {

        return vusd.governor();
    }

    function cTokenList() external view returns (address[] memory) {

        return _cTokenList.values();
    }

    function keepers() external view returns (address[] memory) {

        return _keepers.values();
    }

    function isWhitelistedToken(address _address) external view returns (bool) {

        return _whitelistedTokens.contains(_address);
    }

    function whitelistedTokens() external view returns (address[] memory) {

        return _whitelistedTokens.values();
    }

    function _addToken(
        address _token,
        address _cToken,
        address _oracle
    ) internal {

        require(_whitelistedTokens.add(_token), "add-in-list-failed");
        require(_cTokenList.add(_cToken), "add-in-list-failed");
        oracles[_token] = _oracle;
        cTokens[_token] = _cToken;
        IERC20(_token).safeApprove(_cToken, type(uint256).max);
    }

    function _approveRouters(ISwapManager _swapManager, uint256 _amount) internal {

        for (uint256 i = 0; i < _swapManager.N_DEX(); i++) {
            IERC20(COMP).safeApprove(address(swapManager.ROUTERS(i)), _amount);
        }
    }

    function _withdraw(
        address _token,
        uint256 _amount,
        address _tokenReceiver
    ) internal {

        require(_whitelistedTokens.contains(_token), "token-is-not-supported");
        require(CToken(cTokens[_token]).redeemUnderlying(_amount) == 0, "redeem-underlying-failed");
        IERC20(_token).safeTransfer(_tokenReceiver, _amount);
    }
}