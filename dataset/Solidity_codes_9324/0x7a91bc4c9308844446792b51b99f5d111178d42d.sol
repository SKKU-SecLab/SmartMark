
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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

interface IAggregatorV3 {

    function decimals() external view returns (uint8);


    function description() external view returns (string memory);


    function version() external view returns (uint256);


    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );


    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

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

interface ICurveMetapool {

    function initialize(
        string memory _name,
        string memory _symbol,
        address _coin,
        uint256 _decimals,
        uint256 _A,
        uint256 _fee,
        address _admin
    ) external;


    function decimals() external view returns (uint256);


    function transfer(address _to, uint256 _value) external returns (bool);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);


    function approve(address _spender, uint256 _value) external returns (bool);


    function get_previous_balances() external view returns (uint256[2] memory);


    function get_balances() external view returns (uint256[2] memory);


    function get_twap_balances(
        uint256[2] memory _first_balances,
        uint256[2] memory _last_balances,
        uint256 _time_elapsed
    ) external view returns (uint256[2] memory);


    function get_price_cumulative_last() external view returns (uint256[2] memory);


    function admin_fee() external view returns (uint256);


    function A() external view returns (uint256);


    function A_precise() external view returns (uint256);


    function get_virtual_price() external view returns (uint256);


    function calc_token_amount(uint256[2] memory _amounts, bool _is_deposit) external view returns (uint256);


    function calc_token_amount(
        uint256[2] memory _amounts,
        bool _is_deposit,
        bool _previous
    ) external view returns (uint256);


    function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external returns (uint256);


    function add_liquidity(
        uint256[2] memory _amounts,
        uint256 _min_mint_amount,
        address _receiver
    ) external returns (uint256);


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx,
        uint256[2] memory _balances
    ) external view returns (uint256);


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256[2] memory _balances
    ) external view returns (uint256);


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address _receiver
    ) external returns (uint256);


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        address _receiver
    ) external returns (uint256);


    function remove_liquidity(uint256 _burn_amount, uint256[2] memory _min_amounts)
        external
        returns (uint256[2] memory);


    function remove_liquidity(
        uint256 _burn_amount,
        uint256[2] memory _min_amounts,
        address _receiver
    ) external returns (uint256[2] memory);


    function remove_liquidity_imbalance(uint256[2] memory _amounts, uint256 _max_burn_amount)
        external
        returns (uint256);


    function remove_liquidity_imbalance(
        uint256[2] memory _amounts,
        uint256 _max_burn_amount,
        address _receiver
    ) external returns (uint256);


    function calc_withdraw_one_coin(uint256 _burn_amount, int128 i) external view returns (uint256);


    function calc_withdraw_one_coin(
        uint256 _burn_amount,
        int128 i,
        bool _previous
    ) external view returns (uint256);


    function remove_liquidity_one_coin(
        uint256 _burn_amount,
        int128 i,
        uint256 _min_received
    ) external returns (uint256);


    function remove_liquidity_one_coin(
        uint256 _burn_amount,
        int128 i,
        uint256 _min_received,
        address _receiver
    ) external returns (uint256);


    function ramp_A(uint256 _future_A, uint256 _future_time) external;


    function stop_ramp_A() external;


    function admin_balances(uint256 i) external view returns (uint256);


    function withdraw_admin_fees() external;


    function admin() external view returns (address);


    function coins(uint256 arg0) external view returns (address);


    function balances(uint256 arg0) external view returns (uint256);


    function fee() external view returns (uint256);


    function block_timestamp_last() external view returns (uint256);


    function initial_A() external view returns (uint256);


    function future_A() external view returns (uint256);


    function initial_A_time() external view returns (uint256);


    function future_A_time() external view returns (uint256);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function balanceOf(address arg0) external view returns (uint256);


    function allowance(address arg0, address arg1) external view returns (uint256);


    function totalSupply() external view returns (uint256);

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


contract Minter is Context, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    string public constant NAME = "VUSD-Minter";
    string public constant VERSION = "1.3.0";

    IVUSD public immutable vusd;

    uint256 public mintingFee; // Default no fee
    uint256 public constant MAX_BPS = 10_000; // 10_000 = 100%
    uint256 public constant MINT_LIMIT = 50_000_000 * 10**18; // 50M VUSD
    uint256 private constant STABLE_PRICE = 100_000_000;
    uint256 private constant MAX_UINT_VALUE = type(uint256).max;
    uint256 public priceDeviationLimit = 400; // 4% based on BPS
    uint256 internal priceUpperBound;
    uint256 internal priceLowerBound;

    mapping(address => address) public cTokens;
    mapping(address => address) public oracles;

    address public constant CURVE_METAPOOL = 0x4dF9E1A764Fb8Df1113EC02fc9dc75963395b508;
    EnumerableSet.AddressSet private _whitelistedTokens;

    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    address private constant cDAI = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    address private constant cUSDC = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;

    address private constant DAI_USD = 0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9;
    address private constant USDC_USD = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;

    event UpdatedMintingFee(uint256 previousMintingFee, uint256 newMintingFee);
    event UpdatedPriceDeviationLimit(uint256 previousDeviationLimit, uint256 newDeviationLimit);

    constructor(address _vusd) {
        require(_vusd != address(0), "vusd-address-is-zero");
        vusd = IVUSD(_vusd);

        _addToken(DAI, cDAI, DAI_USD);
        _addToken(USDC, cUSDC, USDC_USD);
        IERC20(_vusd).safeApprove(CURVE_METAPOOL, MAX_UINT_VALUE);
    }

    modifier onlyGovernor() {

        require(_msgSender() == governor(), "caller-is-not-the-governor");
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
        IERC20(_token).safeApprove(cTokens[_token], 0);
        delete cTokens[_token];
        delete oracles[_token];
    }

    function mintAndAddLiquidity(uint256 _amount) external onlyGovernor {

        uint256 _availableMintage = availableMintage();
        if (_amount > _availableMintage) {
            _amount = _availableMintage;
        }
        vusd.mint(address(this), _amount);
        ICurveMetapool(CURVE_METAPOOL).add_liquidity([_amount, 0], 1, treasury());
    }

    function updateMintingFee(uint256 _newMintingFee) external onlyGovernor {

        require(_newMintingFee <= MAX_BPS, "minting-fee-limit-reached");
        require(mintingFee != _newMintingFee, "same-minting-fee");
        emit UpdatedMintingFee(mintingFee, _newMintingFee);
        mintingFee = _newMintingFee;
    }

    function updatePriceDeviationLimit(uint256 _newDeviationLimit) external onlyGovernor {

        require(_newDeviationLimit <= MAX_BPS, "price-deviation-is-invalid");
        require(priceDeviationLimit != _newDeviationLimit, "same-price-deviation-limit");
        emit UpdatedPriceDeviationLimit(priceDeviationLimit, _newDeviationLimit);
        priceDeviationLimit = _newDeviationLimit;
    }


    function mint(address _token, uint256 _amount) external nonReentrant {

        _mint(_token, _amount, _msgSender());
    }

    function mint(
        address _token,
        uint256 _amount,
        address _receiver
    ) external nonReentrant {

        _mint(_token, _amount, _receiver);
    }

    function calculateMintage(address _token, uint256 _amount) external view returns (uint256 _mintReturn) {

        if (_whitelistedTokens.contains(_token)) {
            (uint256 _mintage, ) = _calculateMintage(_token, _amount);
            return _mintage;
        }
        return 0;
    }

    function isMintingAllowed(address _token) external view returns (bool) {

        if (_whitelistedTokens.contains(_token)) {
            return _isMintingAllowed(_token);
        }
        return false;
    }

    function isWhitelistedToken(address _address) external view returns (bool) {

        return _whitelistedTokens.contains(_address);
    }

    function whitelistedTokens() external view returns (address[] memory) {

        return _whitelistedTokens.values();
    }

    function availableMintage() public view returns (uint256 _mintage) {

        return MINT_LIMIT - vusd.totalSupply();
    }

    function treasury() public view returns (address) {

        return vusd.treasury();
    }

    function governor() public view returns (address) {

        return vusd.governor();
    }

    function _addToken(
        address _token,
        address _cToken,
        address _oracle
    ) internal {

        require(_whitelistedTokens.add(_token), "add-in-list-failed");
        oracles[_token] = _oracle;
        cTokens[_token] = _cToken;
        IERC20(_token).safeApprove(_cToken, type(uint256).max);
    }

    function _mint(
        address _token,
        uint256 _amount,
        address _receiver
    ) internal {

        require(_whitelistedTokens.contains(_token), "token-is-not-supported");
        require(_isMintingAllowed(_token), "too-much-token-price-deviation");
        (uint256 _mintage, uint256 _actualAmount) = _calculateMintage(_token, _amount);
        require(_mintage != 0, "mint-limit-reached");
        IERC20(_token).safeTransferFrom(_msgSender(), address(this), _actualAmount);
        address _cToken = cTokens[_token];
        require(CToken(_cToken).mint(_actualAmount) == 0, "cToken-mint-failed");
        IERC20(_cToken).safeTransfer(treasury(), IERC20(_cToken).balanceOf(address(this)));
        vusd.mint(_receiver, _mintage);
    }

    function _calculateMintage(address _token, uint256 _amount)
        internal
        view
        returns (uint256 _mintage, uint256 _actualAmount)
    {

        uint256 _decimals = IERC20Metadata(_token).decimals();
        uint256 _availableAmount = availableMintage() / 10**(18 - _decimals);
        _actualAmount = (_amount > _availableAmount) ? _availableAmount : _amount;
        _mintage = (mintingFee != 0) ? _actualAmount - ((_actualAmount * mintingFee) / MAX_BPS) : _actualAmount;
        _mintage = _mintage * 10**(18 - _decimals);
    }

    function _isMintingAllowed(address _token) internal view returns (bool) {

        address _oracle = oracles[_token];
        uint8 _oracleDecimal = IAggregatorV3(_oracle).decimals();
        uint256 _stablePrice = 10**_oracleDecimal;
        uint256 _deviationInPrice = (_stablePrice * priceDeviationLimit) / MAX_BPS;
        uint256 _priceUpperBound = _stablePrice + _deviationInPrice;
        uint256 _priceLowerBound = _stablePrice - _deviationInPrice;
        (, int256 _price, , , ) = IAggregatorV3(_oracle).latestRoundData();

        uint256 _latestPrice = uint256(_price);
        return _latestPrice <= _priceUpperBound && _latestPrice >= _priceLowerBound;
    }
}