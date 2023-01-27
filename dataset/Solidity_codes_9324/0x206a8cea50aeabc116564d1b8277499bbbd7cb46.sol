
pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity 0.6.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity 0.6.10;


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}/**
 * UNLICENSED
 */
pragma solidity =0.6.10;

pragma experimental ABIEncoderV2;



library MarginVault {

    using SafeMath for uint256;

    struct Vault {
        address[] shortOtokens;
        address[] longOtokens;
        address[] collateralAssets;
        uint256[] shortAmounts;
        uint256[] longAmounts;
        uint256[] collateralAmounts;
    }

    function addShort(
        Vault storage _vault,
        address _shortOtoken,
        uint256 _amount,
        uint256 _index
    ) external {

        require(_amount > 0, "V1");

        if ((_index == _vault.shortOtokens.length) && (_index == _vault.shortAmounts.length)) {
            _vault.shortOtokens.push(_shortOtoken);
            _vault.shortAmounts.push(_amount);
        } else {
            require((_index < _vault.shortOtokens.length) && (_index < _vault.shortAmounts.length), "V2");
            address existingShort = _vault.shortOtokens[_index];
            require((existingShort == _shortOtoken) || (existingShort == address(0)), "V3");

            _vault.shortAmounts[_index] = _vault.shortAmounts[_index].add(_amount);
            _vault.shortOtokens[_index] = _shortOtoken;
        }
    }

    function removeShort(
        Vault storage _vault,
        address _shortOtoken,
        uint256 _amount,
        uint256 _index
    ) external {

        require(_index < _vault.shortOtokens.length, "V2");
        require(_vault.shortOtokens[_index] == _shortOtoken, "V3");

        uint256 newShortAmount = _vault.shortAmounts[_index].sub(_amount);

        if (newShortAmount == 0) {
            delete _vault.shortOtokens[_index];
        }
        _vault.shortAmounts[_index] = newShortAmount;
    }

    function addLong(
        Vault storage _vault,
        address _longOtoken,
        uint256 _amount,
        uint256 _index
    ) external {

        require(_amount > 0, "V4");

        if ((_index == _vault.longOtokens.length) && (_index == _vault.longAmounts.length)) {
            _vault.longOtokens.push(_longOtoken);
            _vault.longAmounts.push(_amount);
        } else {
            require((_index < _vault.longOtokens.length) && (_index < _vault.longAmounts.length), "V5");
            address existingLong = _vault.longOtokens[_index];
            require((existingLong == _longOtoken) || (existingLong == address(0)), "V6");

            _vault.longAmounts[_index] = _vault.longAmounts[_index].add(_amount);
            _vault.longOtokens[_index] = _longOtoken;
        }
    }

    function removeLong(
        Vault storage _vault,
        address _longOtoken,
        uint256 _amount,
        uint256 _index
    ) external {

        require(_index < _vault.longOtokens.length, "V5");
        require(_vault.longOtokens[_index] == _longOtoken, "V6");

        uint256 newLongAmount = _vault.longAmounts[_index].sub(_amount);

        if (newLongAmount == 0) {
            delete _vault.longOtokens[_index];
        }
        _vault.longAmounts[_index] = newLongAmount;
    }

    function addCollateral(
        Vault storage _vault,
        address _collateralAsset,
        uint256 _amount,
        uint256 _index
    ) external {

        require(_amount > 0, "V7");

        if ((_index == _vault.collateralAssets.length) && (_index == _vault.collateralAmounts.length)) {
            _vault.collateralAssets.push(_collateralAsset);
            _vault.collateralAmounts.push(_amount);
        } else {
            require((_index < _vault.collateralAssets.length) && (_index < _vault.collateralAmounts.length), "V8");
            address existingCollateral = _vault.collateralAssets[_index];
            require((existingCollateral == _collateralAsset) || (existingCollateral == address(0)), "V9");

            _vault.collateralAmounts[_index] = _vault.collateralAmounts[_index].add(_amount);
            _vault.collateralAssets[_index] = _collateralAsset;
        }
    }

    function removeCollateral(
        Vault storage _vault,
        address _collateralAsset,
        uint256 _amount,
        uint256 _index
    ) external {

        require(_index < _vault.collateralAssets.length, "V8");
        require(_vault.collateralAssets[_index] == _collateralAsset, "V9");

        uint256 newCollateralAmount = _vault.collateralAmounts[_index].sub(_amount);

        if (newCollateralAmount == 0) {
            delete _vault.collateralAssets[_index];
        }
        _vault.collateralAmounts[_index] = newCollateralAmount;
    }
}// UNLICENSED
pragma solidity 0.6.10;



interface MarginCalculatorInterface {

    function getExpiredPayoutRate(address _otoken) external view returns (uint256);


    function getExcessCollateral(MarginVault.Vault calldata _vault, uint256 _vaultType)
        external
        view
        returns (uint256 netValue, bool isExcess);


    function isLiquidatable(
        MarginVault.Vault memory _vault,
        uint256 _vaultType,
        uint256 _vaultLatestUpdate,
        uint256 _roundId
    )
        external
        view
        returns (
            bool,
            uint256,
            uint256
        );

}// UNLICENSED
pragma solidity 0.6.10;

interface OtokenInterface {

    function underlyingAsset() external view returns (address);


    function strikeAsset() external view returns (address);


    function collateralAsset() external view returns (address);


    function strikePrice() external view returns (uint256);


    function expiryTimestamp() external view returns (uint256);


    function isPut() external view returns (bool);


    function isWhitelisted() external view returns (bool);


    function init(
        address _addressBook,
        address _underlyingAsset,
        address _strikeAsset,
        address _collateralAsset,
        uint256 _strikePrice,
        uint256 _expiry,
        bool _isPut,
        bool _isWhitelisted
    ) external;


    function getOtokenDetails()
        external
        view
        returns (
            address,
            address,
            address,
            uint256,
            uint256,
            bool
        );


    function mintOtoken(address account, uint256 amount) external;


    function burnOtoken(address account, uint256 amount) external;

}// UNLICENSED
pragma solidity 0.6.10;

interface OracleInterface {

    function isLockingPeriodOver(address _asset, uint256 _expiryTimestamp) external view returns (bool);


    function isDisputePeriodOver(address _asset, uint256 _expiryTimestamp) external view returns (bool);


    function isWhitelistedPricer(address _pricer) external view returns (bool);


    function getExpiryPrice(address _asset, uint256 _expiryTimestamp) external view returns (uint256, bool);


    function getDisputer() external view returns (address);


    function getPricer(address _asset) external view returns (address);


    function getPrice(address _asset) external view returns (uint256);


    function getPricerLockingPeriod(address _pricer) external view returns (uint256);


    function getPricerDisputePeriod(address _pricer) external view returns (uint256);


    function getChainlinkRoundData(address _asset, uint80 _roundId) external view returns (uint256, uint256);



    function setAssetPricer(address _asset, address _pricer) external;


    function setLockingPeriod(address _pricer, uint256 _lockingPeriod) external;


    function setDisputePeriod(address _pricer, uint256 _disputePeriod) external;


    function setExpiryPrice(
        address _asset,
        uint256 _expiryTimestamp,
        uint256 _price
    ) external;


    function disputeExpiryPrice(
        address _asset,
        uint256 _expiryTimestamp,
        uint256 _price
    ) external;


    function setDisputer(address _disputer) external;

}/**
 * UNLICENSED
 */
pragma solidity 0.6.10;

interface ERC20Interface {

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


    function decimals() external view returns (uint8);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}