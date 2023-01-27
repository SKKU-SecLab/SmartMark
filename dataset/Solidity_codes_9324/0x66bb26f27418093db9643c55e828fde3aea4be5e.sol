
pragma solidity >=0.6.0 <0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// BUSL-1.1
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

interface PriceOracleDataTypes {

    struct PriceDataOut {
        uint64 price;
        uint64 timestamp;
    }

}// BUSL-1.1
pragma solidity 0.7.4;


interface PriceOracleInterface is PriceOracleDataTypes {

    function assetPrices(address) external view returns (PriceDataOut memory);

    function givePrices(address[] calldata assetAddresses) external view returns (PriceDataOut[] memory);

}// BUSL-1.1
pragma solidity 0.7.4;

library MarginalFunctionality {


    struct Liability {
        address asset;
        uint64 timestamp;
        uint192 outstandingAmount;
    }

    enum PositionState {
        POSITIVE,
        NEGATIVE, // weighted position below 0
        OVERDUE,  // liability is not returned for too long
        NOPRICE,  // some assets has no price or expired
        INCORRECT // some of the basic requirements are not met: too many liabilities, no locked stake, etc
    }

    struct Position {
        PositionState state;
        int256 weightedPosition; // sum of weighted collateral minus liabilities
        int256 totalPosition; // sum of unweighted (total) collateral minus liabilities
        int256 totalLiabilities; // total liabilities value
    }

    struct UsedConstants {
        address user;
        address _oracleAddress;
        address _orionTokenAddress;
        uint64 positionOverdue;
        uint64 priceOverdue;
        uint8 stakeRisk;
        uint8 liquidationPremium;
    }


    function uint8Percent(int192 _a, uint8 b) internal pure returns (int192 c) {

        int a = int256(_a);
        int d = 255;
        c = int192((a>65536) ? (a/d)*b : a*b/d );
    }

    function getAssetPrice(address asset, address oracle) internal view returns (uint64 price, uint64 timestamp) {

        PriceOracleInterface.PriceDataOut memory assetPriceData = PriceOracleInterface(oracle).assetPrices(asset);
        (price, timestamp) = (assetPriceData.price, assetPriceData.timestamp);
    }

    function calcAssets(
        address[] storage collateralAssets,
        mapping(address => mapping(address => int192)) storage assetBalances,
        mapping(address => uint8) storage assetRisks,
        address user,
        address orionTokenAddress,
        address oracleAddress,
        uint64 priceOverdue
    ) internal view returns (bool outdated, int192 weightedPosition, int192 totalPosition) {

        uint256 collateralAssetsLength = collateralAssets.length;
        for(uint256 i = 0; i < collateralAssetsLength; i++) {
            address asset = collateralAssets[i];
            if(assetBalances[user][asset]<0)
                continue; // will be calculated in calcLiabilities
            (uint64 price, uint64 timestamp) = (1e8, 0xfffffff000000000);

            if(asset != orionTokenAddress) {
                (price, timestamp) = getAssetPrice(asset, oracleAddress);
            }


            uint8 specificRisk = assetRisks[asset];
            int192 balance = assetBalances[user][asset];
            int256 _assetValue = int256(balance)*price/1e8;
            int192 assetValue = int192(_assetValue);


            if(assetValue>0) {
                weightedPosition += uint8Percent(assetValue, specificRisk);
                totalPosition += assetValue;
                outdated = outdated || ((timestamp + priceOverdue) < block.timestamp);
            }

        }

        return (outdated, weightedPosition, totalPosition);
    }

    function calcLiabilities(
        mapping(address => Liability[]) storage liabilities,
        mapping(address => mapping(address => int192)) storage assetBalances,
        address user,
        address oracleAddress,
        uint64 positionOverdue,
        uint64 priceOverdue
    ) internal view returns  (bool outdated, bool overdue, int192 weightedPosition, int192 totalPosition) {

        uint256 liabilitiesLength = liabilities[user].length;

        for(uint256 i = 0; i < liabilitiesLength; i++) {
            Liability storage liability = liabilities[user][i];
            int192 balance = assetBalances[user][liability.asset];
            (uint64 price, uint64 timestamp) = getAssetPrice(liability.asset, oracleAddress);

            int192 liabilityValue = int192(int256(balance) * price / 1e8);
            weightedPosition += liabilityValue; //already negative since balance is negative
            totalPosition += liabilityValue;
            overdue = overdue || ((liability.timestamp + positionOverdue) < block.timestamp);
            outdated = outdated || ((timestamp + priceOverdue) < block.timestamp);
        }

        return (outdated, overdue, weightedPosition, totalPosition);
    }

    function calcPosition(
        address[] storage collateralAssets,
        mapping(address => Liability[]) storage liabilities,
        mapping(address => mapping(address => int192)) storage assetBalances,
        mapping(address => uint8) storage assetRisks,
        UsedConstants memory constants
    ) public view returns (Position memory result) {


        (bool outdatedPrice, int192 weightedPosition, int192 totalPosition) =
        calcAssets(
            collateralAssets,
            assetBalances,
            assetRisks,
            constants.user,
            constants._orionTokenAddress,
            constants._oracleAddress,
            constants.priceOverdue
        );

        (bool _outdatedPrice, bool overdue, int192 _weightedPosition, int192 _totalPosition) =
        calcLiabilities(
            liabilities,
            assetBalances,
            constants.user,
            constants._oracleAddress,
            constants.positionOverdue,
            constants.priceOverdue
        );

        weightedPosition += _weightedPosition;
        totalPosition += _totalPosition;
        outdatedPrice = outdatedPrice || _outdatedPrice;
        if(_totalPosition<0) {
            result.totalLiabilities = _totalPosition;
        }
        if(weightedPosition<0) {
            result.state = PositionState.NEGATIVE;
        }
        if(outdatedPrice) {
            result.state = PositionState.NOPRICE;
        }
        if(overdue) {
            result.state = PositionState.OVERDUE;
        }
        result.weightedPosition = weightedPosition;
        result.totalPosition = totalPosition;
    }

    function removeLiability(
        address user,
        address asset,
        mapping(address => Liability[]) storage liabilities
    ) public {

        uint256 length = liabilities[user].length;

        for (uint256 i = 0; i < length; i++) {
            if (liabilities[user][i].asset == asset) {
                if (length>1) {
                    liabilities[user][i] = liabilities[user][length - 1];
                }
                liabilities[user].pop();
                break;
            }
        }
    }

    function updateLiability(address user,
        address asset,
        mapping(address => Liability[]) storage liabilities,
        uint112 depositAmount,
        int192 currentBalance
    ) internal {

        if(currentBalance>=0) {
            removeLiability(user,asset,liabilities);
        } else {
            uint256 i;
            uint256 liabilitiesLength=liabilities[user].length;
            for(; i<liabilitiesLength-1; i++) {
                if(liabilities[user][i].asset == asset)
                    break;
            }
            Liability storage liability = liabilities[user][i];
            if(depositAmount>=liability.outstandingAmount) {
                liability.outstandingAmount = uint192(-currentBalance);
                liability.timestamp = uint64(block.timestamp);
            } else {
                liability.outstandingAmount -= depositAmount;
            }
        }
    }


    function partiallyLiquidate(address[] storage collateralAssets,
        mapping(address => Liability[]) storage liabilities,
        mapping(address => mapping(address => int192)) storage assetBalances,
        mapping(address => uint8) storage assetRisks,
        UsedConstants memory constants,
        address redeemedAsset,
        uint112 amount) public {

        Position memory initialPosition = calcPosition(collateralAssets,
            liabilities,
            assetBalances,
            assetRisks,
            constants);
        require(initialPosition.state == PositionState.NEGATIVE ||
            initialPosition.state == PositionState.OVERDUE  , "E7");
        address liquidator = msg.sender;
        require(assetBalances[liquidator][redeemedAsset]>=amount,"E8");
        require(assetBalances[constants.user][redeemedAsset]<0,"E15");
        assetBalances[liquidator][redeemedAsset] -= amount;
        assetBalances[constants.user][redeemedAsset] += amount;

        if(assetBalances[constants.user][redeemedAsset] >= 0)
            removeLiability(constants.user, redeemedAsset, liabilities);

        (uint64 price, uint64 timestamp) = getAssetPrice(redeemedAsset, constants._oracleAddress);
        require((timestamp + constants.priceOverdue) > block.timestamp, "E9"); //Price is outdated

        reimburseLiquidator(
            amount,
            price,
            liquidator,
            assetBalances,
            constants.liquidationPremium,
            constants.user,
            constants._orionTokenAddress
        );

        Position memory finalPosition = calcPosition(collateralAssets,
            liabilities,
            assetBalances,
            assetRisks,
            constants);
        require( int(finalPosition.state)<3 && //POSITIVE,NEGATIVE or OVERDUE
            (finalPosition.weightedPosition>initialPosition.weightedPosition),
            "E10");//Incorrect state position after liquidation
        if(finalPosition.state == PositionState.POSITIVE)
            require (finalPosition.weightedPosition<10e8,"Can not liquidate to very positive state");

    }

    function reimburseLiquidator(
        uint112 amount,
        uint64 price,
        address liquidator,
        mapping(address => mapping(address => int192)) storage assetBalances,
        uint8 liquidationPremium,
        address user,
        address orionTokenAddress
    ) internal {

        int192 _orionAmount = int192(int256(amount)*price/1e8);
        _orionAmount += uint8Percent(_orionAmount, liquidationPremium); //Liquidation premium
        require(_orionAmount == int64(_orionAmount), "E11");
        int192 onBalanceOrion = assetBalances[user][orionTokenAddress];

        require(onBalanceOrion >= _orionAmount, "E10");
        assetBalances[user][orionTokenAddress] -= _orionAmount;
        assetBalances[liquidator][orionTokenAddress] += _orionAmount;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// BUSL-1.1
pragma solidity 0.7.4;



library LibUnitConverter {

    using SafeMath for uint;

    function decimalToBaseUnit(address assetAddress, uint amount) internal view returns(int112 baseValue){
        uint256 result;

        if(assetAddress == address(0)){
            result =  amount.mul(1 ether).div(10**8); // 18 decimals
        } else {

            ERC20 asset = ERC20(assetAddress);
            uint decimals = asset.decimals();

            result = amount.mul(10**decimals).div(10**8);
        }

        require(result < uint256(type(int112).max), "E3U");
        baseValue = int112(result);
    }

    function baseUnitToDecimal(address assetAddress, uint amount) internal view returns(int112 decimalValue){
        uint256 result;

        if(assetAddress == address(0)){
            result = amount.mul(10**8).div(1 ether);
        } else {

            ERC20 asset = ERC20(assetAddress);
            uint decimals = asset.decimals();

            result = amount.mul(10**8).div(10**decimals);
        }
        require(result < uint256(type(int112).max), "E3U");
        decimalValue = int112(result);
    }
}// BUSL-1.1
pragma solidity 0.7.4;


library LibValidator {

    using ECDSA for bytes32;

    string public constant DOMAIN_NAME = "Orion Exchange";
    string public constant DOMAIN_VERSION = "1";
    uint256 public constant CHAIN_ID = 1;
    bytes32 public constant DOMAIN_SALT = 0xf2d857f4a3edcb9b78b4d503bfe733db1e3f6cdc2b7971ee739626c97e86a557;

    bytes32 public constant EIP712_DOMAIN_TYPEHASH = keccak256(
        abi.encodePacked(
            "EIP712Domain(string name,string version,uint256 chainId,bytes32 salt)"
        )
    );
    bytes32 public constant ORDER_TYPEHASH = keccak256(
        abi.encodePacked(
            "Order(address senderAddress,address matcherAddress,address baseAsset,address quoteAsset,address matcherFeeAsset,uint64 amount,uint64 price,uint64 matcherFee,uint64 nonce,uint64 expiration,uint8 buySide)"
        )
    );

    bytes32 public constant DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes(DOMAIN_NAME)),
            keccak256(bytes(DOMAIN_VERSION)),
            CHAIN_ID,
            DOMAIN_SALT
        )
    );

    struct Order {
        address senderAddress;
        address matcherAddress;
        address baseAsset;
        address quoteAsset;
        address matcherFeeAsset;
        uint64 amount;
        uint64 price;
        uint64 matcherFee;
        uint64 nonce;
        uint64 expiration;
        uint8 buySide; // buy or sell
        bool isPersonalSign;
        bytes signature;
    }

    function validateV3(Order memory order) public pure returns (bool) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                getTypeValueHash(order)
            )
        );

        return digest.recover(order.signature) == order.senderAddress;
    }

    function getTypeValueHash(Order memory _order)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    ORDER_TYPEHASH,
                    _order.senderAddress,
                    _order.matcherAddress,
                    _order.baseAsset,
                    _order.quoteAsset,
                    _order.matcherFeeAsset,
                    _order.amount,
                    _order.price,
                    _order.matcherFee,
                    _order.nonce,
                    _order.expiration,
                    _order.buySide
                )
            );
    }

    function checkOrdersInfo(
        Order memory buyOrder,
        Order memory sellOrder,
        address sender,
        uint256 filledAmount,
        uint256 filledPrice,
        uint256 currentTime,
        address allowedMatcher
    ) public pure returns (bool success) {
        buyOrder.isPersonalSign ? require(validatePersonal(buyOrder), "E2BP") : require(validateV3(buyOrder), "E2B");
        sellOrder.isPersonalSign ? require(validatePersonal(sellOrder), "E2SP") : require(validateV3(sellOrder), "E2S");

        require(
            buyOrder.matcherAddress == sender &&
                sellOrder.matcherAddress == sender,
            "E3M"
        );

        if(allowedMatcher != address(0)) {
          require(buyOrder.matcherAddress == allowedMatcher, "E3M2");
        }


        require(
            buyOrder.baseAsset == sellOrder.baseAsset &&
                buyOrder.quoteAsset == sellOrder.quoteAsset,
            "E3As"
        );

        require(filledAmount <= buyOrder.amount, "E3AmB");
        require(filledAmount <= sellOrder.amount, "E3AmS");

        require(filledPrice <= buyOrder.price, "E3");
        require(filledPrice >= sellOrder.price, "E3");

        require(buyOrder.expiration/1000 >= currentTime, "E4B");
        require(sellOrder.expiration/1000 >= currentTime, "E4S");

        require( buyOrder.buySide==1 && sellOrder.buySide==0, "E3D");
        success = true;
    }

    function getEthSignedOrderHash(Order memory _order) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "order",
                    _order.senderAddress,
                    _order.matcherAddress,
                    _order.baseAsset,
                    _order.quoteAsset,
                    _order.matcherFeeAsset,
                    _order.amount,
                    _order.price,
                    _order.matcherFee,
                    _order.nonce,
                    _order.expiration,
                    _order.buySide
                )
            ).toEthSignedMessageHash();
    }

    function validatePersonal(Order memory order) public pure returns (bool) {

        bytes32 digest = getEthSignedOrderHash(order);
        return digest.recover(order.signature) == order.senderAddress;
    }

    function checkOrderSingleMatch(
        Order memory buyOrder,
        address sender,
        address allowedMatcher,
        uint112 filledAmount,
        uint256 currentTime,
        address[] memory path
    ) internal pure {
        buyOrder.isPersonalSign ? require(validatePersonal(buyOrder), "E2BP") : require(validateV3(buyOrder), "E2B");
        require(buyOrder.matcherAddress == sender && buyOrder.matcherAddress == allowedMatcher, "E3M2");
        if(buyOrder.buySide==1){
            require(
                buyOrder.baseAsset == path[path.length-1] &&
                buyOrder.quoteAsset == path[0],
                "E3As"
            );
        }else{
            require(
                buyOrder.quoteAsset == path[path.length-1] &&
                buyOrder.baseAsset == path[0],
                "E3As"
            );
        }
        require(filledAmount <= buyOrder.amount, "E3AmB");
        require(buyOrder.expiration/1000 >= currentTime, "E4B");
    }
}pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}// BUSL-1.1
pragma solidity 0.7.4;


library SafeTransferHelper {

    function safeAutoTransferFrom(address weth, address token, address from, address to, uint value) internal {
        if (token == address(0)) {
            require(from == address(this), "TransferFrom: this");
            IWETH(weth).deposit{value: value}();
            assert(IWETH(weth).transfer(to, value));
        } else {
            if (from == address(this)) {
                SafeERC20.safeTransfer(IERC20(token), to, value);
            } else {
                SafeERC20.safeTransferFrom(IERC20(token), from, to, value);
            }
        }
    }

    function safeAutoTransferTo(address weth, address token, address to, uint value) internal {
        if (address(this) != to) {
            if (token == address(0)) {
                IWETH(weth).withdraw(value);
                Address.sendValue(payable(to), value);
            } else {
                SafeERC20.safeTransfer(IERC20(token), to, value);
            }
        }
    }

    function safeTransferTokenOrETH(address token, address to, uint value) internal {
        if (address(this) != to) {
            if (token == address(0)) {
                Address.sendValue(payable(to), value);
            } else {
                SafeERC20.safeTransfer(IERC20(token), to, value);
            }
        }
    }
}pragma solidity 0.7.4;


library LibExchange {
    using SafeERC20 for IERC20;

    uint8 public constant kSell = 0;
    uint8 public constant kBuy = 1; //  if 0 - then sell
    uint8 public constant kCorrectMatcherFeeByOrderAmount = 2;

    function _updateBalance(address user, address asset, int amount,
        mapping(address => mapping(address => int192)) storage assetBalances,
        mapping(address => MarginalFunctionality.Liability[]) storage liabilities
    ) internal returns (uint tradeType) { // 0 - in contract, 1 - from wallet
        int beforeBalance = int(assetBalances[user][asset]);
        int afterBalance = beforeBalance + amount;

        if (amount > 0 && beforeBalance < 0) {
            MarginalFunctionality.updateLiability(user, asset, liabilities, uint112(amount), int192(afterBalance));
        } else if (beforeBalance >= 0 && afterBalance < 0){
            if (asset != address(0)) {
                afterBalance += int(_tryDeposit(asset, uint(-1*afterBalance), user));
            }

            if (afterBalance < 0) {
                setLiability(user, asset, int192(afterBalance), liabilities);
            } else {
                tradeType = beforeBalance > 0 ? 0 : 1;
            }
        }

        if (beforeBalance != afterBalance) {
            assetBalances[user][asset] = int192(afterBalance);
        }
    }

    function setLiability(address user, address asset, int192 balance,
        mapping(address => MarginalFunctionality.Liability[]) storage liabilities
    ) internal {
        liabilities[user].push(
            MarginalFunctionality.Liability({
                asset : asset,
                timestamp : uint64(block.timestamp),
                outstandingAmount : uint192(- balance)
            })
        );
    }

    function _tryDeposit(
        address asset,
        uint amount,
        address user
    ) internal returns(uint) {
        uint256 amountInBase = uint256(LibUnitConverter.decimalToBaseUnit(asset, amount));

        if (IERC20(asset).balanceOf(user) >= amountInBase && IERC20(asset).allowance(user, address(this)) >= amountInBase) {
            SafeERC20.safeTransferFrom(IERC20(asset), user, address(this), amountInBase);
            return amount;
        } else {
            return 0;
        }
    }

    function creditUserAssets(uint tradeType, address user, int amount, address asset,
        mapping(address => mapping(address => int192)) storage assetBalances,
        mapping(address => MarginalFunctionality.Liability[]) storage liabilities
    ) internal {
        int beforeBalance = int(assetBalances[user][asset]);
        int remainingAmount = amount + beforeBalance;
        int sentAmount = 0;
        if (tradeType == 1 && remainingAmount > 0 && beforeBalance <= 0) {
            uint amountInBase = uint(LibUnitConverter.decimalToBaseUnit(asset, uint(remainingAmount)));
            uint contractBalance = asset == address(0) ? address(this).balance : IERC20(asset).balanceOf(address(this));
            if (contractBalance >= amountInBase) {
                SafeTransferHelper.safeTransferTokenOrETH(asset, user, amountInBase);
                sentAmount = remainingAmount;
            }
        }
        int toUpdate = amount - sentAmount;
        if (toUpdate != 0) {
            _updateBalance(user, asset, toUpdate, assetBalances, liabilities);
        }
    }

    struct SwapBalanceChanges {
        int amountOut;
        address assetOut;
        int amountIn;
        address assetIn;
    }

    function updateOrderBalanceDebit(
        LibValidator.Order memory order,
        uint112 amountBase,
        uint112 amountQuote,
        uint8 flags,
        mapping(address => mapping(address => int192)) storage assetBalances,
        mapping(address => MarginalFunctionality.Liability[]) storage liabilities
    ) internal returns (uint tradeType, int actualIn) {
        bool isSeller = (flags & kBuy) == 0;

        {
            bool isCorrectFee = ((flags & kCorrectMatcherFeeByOrderAmount) != 0);

            if (isCorrectFee) {
                order.matcherFee = uint64(
                    (uint256(order.matcherFee) * amountBase) / order.amount
                ); //rewrite in memory only
            }
        }

        if (amountBase > 0) {
            SwapBalanceChanges memory swap;

            (swap.amountOut, swap.amountIn) = isSeller
            ? (-1*int(amountBase), int(amountQuote))
            : (-1*int(amountQuote), int(amountBase));

            (swap.assetOut, swap.assetIn) = isSeller
            ? (order.baseAsset, order.quoteAsset)
            : (order.quoteAsset, order.baseAsset);


            uint feeTradeType = 1;
            if (order.matcherFeeAsset == swap.assetOut) {
                swap.amountOut -= order.matcherFee;
            } else if (order.matcherFeeAsset == swap.assetIn) {
                swap.amountIn -= order.matcherFee;
            } else {
                feeTradeType = _updateBalance(order.senderAddress, order.matcherFeeAsset, -1*int256(order.matcherFee),
                    assetBalances, liabilities);
            }

            tradeType = feeTradeType & _updateBalance(order.senderAddress, swap.assetOut, swap.amountOut, assetBalances, liabilities);

            actualIn = swap.amountIn;

            _updateBalance(order.matcherAddress, order.matcherFeeAsset, order.matcherFee, assetBalances, liabilities);
        }

    }

}pragma solidity 0.7.4;


library LibAtomic {
    using ECDSA for bytes32;

    struct LockOrder {
        address sender;
        address asset;
        uint64 amount;
        uint64 expiration;
        bytes32 secretHash;
        bool used;
    }

    struct ClaimOrder {
        address receiver;
        bytes32 secretHash;
    }

    struct RedeemOrder {
        address sender;
        address receiver;
        address claimReceiver;
        address asset;
        uint64 amount;
        uint64 expiration;
        bytes32 secretHash;
        bytes signature;
    }

    struct RedeemInfo {
        address claimReceiver;
        bytes secret;
    }

    function doLockAtomic(LockOrder memory swap,
        mapping(bytes32 => LockOrder) storage atomicSwaps,
        mapping(bytes32 => RedeemInfo) storage secrets,
        mapping(address => mapping(address => int192)) storage assetBalances,
        mapping(address => MarginalFunctionality.Liability[]) storage liabilities
    ) public {
        require(msg.sender == swap.sender, "E3C");
        require(swap.expiration/1000 >= block.timestamp, "E17E");
        require(secrets[swap.secretHash].claimReceiver == address(0), "E17R");
        require(atomicSwaps[swap.secretHash].sender == address(0), "E17R");

        int remaining = swap.amount;
        if (msg.value > 0) {
            require(swap.asset == address(0), "E17ETH");
            uint112 eth_sent = uint112(LibUnitConverter.baseUnitToDecimal(address(0), msg.value));
            if (eth_sent < swap.amount) {
                remaining = int(swap.amount) - eth_sent;
            } else {
                swap.amount = uint64(eth_sent);
                remaining = 0;
            }
        }

        if (remaining > 0) {
            LibExchange._updateBalance(swap.sender, swap.asset, -1*remaining, assetBalances, liabilities);
            require(assetBalances[swap.sender][swap.asset] >= 0, "E1A");
        }

        bytes32 secretHash = swap.secretHash;
        swap.secretHash = bytes32(0);
        atomicSwaps[secretHash] = swap;
    }

    function doRedeemAtomic(
        LibAtomic.RedeemOrder calldata order,
        bytes calldata secret,
        mapping(bytes32 => RedeemInfo) storage secrets,
        mapping(address => mapping(address => int192)) storage assetBalances,
        mapping(address => MarginalFunctionality.Liability[]) storage liabilities
    ) public {
        require(msg.sender == order.receiver, "E3C");
        require(secrets[order.secretHash].claimReceiver == address(0), "E17R");
        require(getEthSignedAtomicOrderHash(order).recover(order.signature) == order.sender, "E2");
        require(order.expiration/1000 >= block.timestamp, "E4A");
        require(order.secretHash == keccak256(secret), "E17");

        LibExchange._updateBalance(order.sender, order.asset, -1*int(order.amount), assetBalances, liabilities);

        LibExchange._updateBalance(order.receiver, order.asset, order.amount, assetBalances, liabilities);
        secrets[order.secretHash] = RedeemInfo(order.claimReceiver, secret);
    }

    function doClaimAtomic(
        address receiver,
        bytes calldata secret,
        bytes calldata matcherSignature,
        address allowedMatcher,
        mapping(bytes32 => LockOrder) storage atomicSwaps,
        mapping(address => mapping(address => int192)) storage assetBalances,
        mapping(address => MarginalFunctionality.Liability[]) storage liabilities
    ) public returns (LockOrder storage swap) {
        bytes32 secretHash = keccak256(secret);
        bytes32 coHash = getEthSignedClaimOrderHash(ClaimOrder(receiver, secretHash));
        require(coHash.recover(matcherSignature) == allowedMatcher, "E2");

        swap = atomicSwaps[secretHash];
        require(swap.sender != address(0), "E17NF");
        require(swap.expiration/1000 >= block.timestamp, "E17E");
        require(!swap.used, "E17U");

        swap.used = true;
        LibExchange._updateBalance(receiver, swap.asset, swap.amount, assetBalances, liabilities);
    }

    function doRefundAtomic(
        bytes32 secretHash,
        mapping(bytes32 => LockOrder) storage atomicSwaps,
        mapping(address => mapping(address => int192)) storage assetBalances,
        mapping(address => MarginalFunctionality.Liability[]) storage liabilities
    ) public returns(LockOrder storage swap) {
        swap = atomicSwaps[secretHash];
        require(swap.sender != address(0x0), "E17NF");
        require(swap.expiration/1000 < block.timestamp, "E17NE");
        require(!swap.used, "E17U");

        swap.used = true;
        LibExchange._updateBalance(swap.sender, swap.asset, int(swap.amount), assetBalances, liabilities);
    }

    function getEthSignedAtomicOrderHash(RedeemOrder calldata _order) internal view returns (bytes32) {
        uint256 chId;
        assembly {
            chId := chainid()
        }
        return keccak256(
            abi.encodePacked(
                "atomicOrder",
                chId,
                _order.sender,
                _order.receiver,
                _order.claimReceiver,
                _order.asset,
                _order.amount,
                _order.expiration,
                _order.secretHash
            )
        ).toEthSignedMessageHash();
    }

    function getEthSignedClaimOrderHash(ClaimOrder memory _order) internal pure returns (bytes32) {
        uint256 chId;
        assembly {
            chId := chainid()
        }
        return keccak256(
            abi.encodePacked(
                "claimOrder",
                chId,
                _order.receiver,
                _order.secretHash
            )
        ).toEthSignedMessageHash();
    }
}