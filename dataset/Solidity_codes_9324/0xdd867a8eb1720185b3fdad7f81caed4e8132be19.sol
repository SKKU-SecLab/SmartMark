
pragma solidity ^0.7.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.7.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.7.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT
pragma solidity 0.7.3;

interface ISuperRareAuctionHouse {

    function configureAuction(
        bytes32 _auctionType,
        address _originContract,
        uint256 _tokenId,
        uint256 _startingAmount,
        address _currencyAddress,
        uint256 _lengthOfAuction,
        uint256 _startTime,
        address payable[] calldata _splitAddresses,
        uint8[] calldata _splitRatios
    ) external;


    function convertOfferToAuction(
        address _originContract,
        uint256 _tokenId,
        address _currencyAddress,
        uint256 _amount,
        uint256 _lengthOfAuction,
        address payable[] calldata _splitAddresses,
        uint8[] calldata _splitRatios
    ) external;


    function cancelAuction(address _originContract, uint256 _tokenId) external;


    function bid(
        address _originContract,
        uint256 _tokenId,
        address _currencyAddress,
        uint256 _amount
    ) external payable;


    function settleAuction(address _originContract, uint256 _tokenId) external;


    function getAuctionDetails(address _originContract, uint256 _tokenId)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            bytes32,
            address payable[] memory,
            uint8[] memory
        );

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

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
}// MIT
pragma solidity 0.7.3;

interface IMarketplaceSettings {

    function getMarketplaceMaxValue() external view returns (uint256);


    function getMarketplaceMinValue() external view returns (uint256);


    function getMarketplaceFeePercentage() external view returns (uint8);


    function calculateMarketplaceFee(uint256 _amount)
        external
        view
        returns (uint256);


    function getERC721ContractPrimarySaleFeePercentage(address _contractAddress)
        external
        view
        returns (uint8);


    function calculatePrimarySaleFee(address _contractAddress, uint256 _amount)
        external
        view
        returns (uint256);


    function hasERC721TokenSold(address _contractAddress, uint256 _tokenId)
        external
        view
        returns (bool);


    function markERC721Token(
        address _contractAddress,
        uint256 _tokenId,
        bool _hasSold
    ) external;


    function setERC721ContractPrimarySaleFeePercentage(
        address _contractAddress,
        uint8 _percentage
    ) external;

}// MIT
pragma solidity 0.7.3;

interface IERC721TokenCreator {

    function tokenCreator(address _contractAddress, uint256 _tokenId)
        external
        view
        returns (address payable);

}// MIT
pragma solidity 0.7.3;


interface IERC721CreatorRoyalty is IERC721TokenCreator {

    function getERC721TokenRoyaltyPercentage(
        address _contractAddress,
        uint256 _tokenId
    ) external view returns (uint8);


    function calculateRoyaltyFee(
        address _contractAddress,
        uint256 _tokenId,
        uint256 _amount
    ) external view returns (uint256);


    function setPercentageForSetERC721ContractRoyalty(
        address _contractAddress,
        uint8 _percentage
    ) external;

}// MIT
pragma solidity 0.7.3;

interface IPayments {

    function refund(address _payee, uint256 _amount) external payable;


    function payout(address[] calldata _splits, uint256[] calldata _amounts)
        external
        payable;

}// MIT
pragma solidity 0.7.3;

interface ISpaceOperatorRegistry {

    function getPlatformCommission(address _operator)
        external
        view
        returns (uint8);


    function setPlatformCommission(address _operator, uint8 _commission)
        external;


    function isApprovedSpaceOperator(address _operator)
        external
        view
        returns (bool);


    function setSpaceOperatorApproved(address _operator, bool _approved)
        external;

}// MIT
pragma solidity 0.7.3;

interface IApprovedTokenRegistry {

    function isApprovedToken(address _tokenContract)
        external
        view
        returns (bool);


    function addApprovedToken(address _tokenContract) external;


    function removeApprovedToken(address _tokenContract) external;


    function setAllTokensApproved(bool _allTokensApproved) external;

}// MIT
pragma solidity 0.7.3;


interface IRoyaltyEngineV1 {

    function getRoyalty(
        address tokenAddress,
        uint256 tokenId,
        uint256 value
    )
        external
        returns (address payable[] memory recipients, uint256[] memory amounts);


    function getRoyaltyView(
        address tokenAddress,
        uint256 tokenId,
        uint256 value
    )
        external
        view
        returns (address payable[] memory recipients, uint256[] memory amounts);

}// MIT
pragma solidity 0.7.3;


contract SuperRareBazaarStorage {


    bytes32 public constant COLDIE_AUCTION = "COLDIE_AUCTION";
    bytes32 public constant SCHEDULED_AUCTION = "SCHEDULED_AUCTION";
    bytes32 public constant NO_AUCTION = bytes32(0);


    struct Offer {
        address payable buyer;
        uint256 amount;
        uint256 timestamp;
        uint8 marketplaceFee;
        bool convertible;
    }

    struct SalePrice {
        address payable seller;
        address currencyAddress;
        uint256 amount;
        address payable[] splitRecipients;
        uint8[] splitRatios;
    }

    struct Auction {
        address payable auctionCreator;
        uint256 creationBlock;
        uint256 startingTime;
        uint256 lengthOfAuction;
        address currencyAddress;
        uint256 minimumBid;
        bytes32 auctionType;
        address payable[] splitRecipients;
        uint8[] splitRatios;
    }

    struct Bid {
        address payable bidder;
        address currencyAddress;
        uint256 amount;
        uint8 marketplaceFee;
    }

    event Sold(
        address indexed _originContract,
        address indexed _buyer,
        address indexed _seller,
        address _currencyAddress,
        uint256 _amount,
        uint256 _tokenId
    );

    event SetSalePrice(
        address indexed _originContract,
        address indexed _currencyAddress,
        address _target,
        uint256 _amount,
        uint256 _tokenId,
        address payable[] _splitRecipients,
        uint8[] _splitRatios
    );

    event OfferPlaced(
        address indexed _originContract,
        address indexed _bidder,
        address indexed _currencyAddress,
        uint256 _amount,
        uint256 _tokenId,
        bool _convertible
    );

    event AcceptOffer(
        address indexed _originContract,
        address indexed _bidder,
        address indexed _seller,
        address _currencyAddress,
        uint256 _amount,
        uint256 _tokenId,
        address payable[] _splitAddresses,
        uint8[] _splitRatios
    );

    event CancelOffer(
        address indexed _originContract,
        address indexed _bidder,
        address indexed _currencyAddress,
        uint256 _amount,
        uint256 _tokenId
    );

    event NewAuction(
        address indexed _contractAddress,
        uint256 indexed _tokenId,
        address indexed _auctionCreator,
        address _currencyAddress,
        uint256 _startingTime,
        uint256 _minimumBid,
        uint256 _lengthOfAuction
    );

    event CancelAuction(
        address indexed _contractAddress,
        uint256 indexed _tokenId,
        address indexed _auctionCreator
    );

    event AuctionBid(
        address indexed _contractAddress,
        address indexed _bidder,
        uint256 indexed _tokenId,
        address _currencyAddress,
        uint256 _amount,
        bool _startedAuction,
        uint256 _newAuctionLength,
        address _previousBidder
    );

    event AuctionSettled(
        address indexed _contractAddress,
        address indexed _bidder,
        address _seller,
        uint256 indexed _tokenId,
        address _currencyAddress,
        uint256 _amount
    );


    IMarketplaceSettings public marketplaceSettings;

    IERC721CreatorRoyalty public royaltyRegistry;

    IRoyaltyEngineV1 public royaltyEngine;

    address public superRareMarketplace;

    address public superRareAuctionHouse;

    ISpaceOperatorRegistry public spaceOperatorRegistry;

    IApprovedTokenRegistry public approvedTokenRegistry;

    IPayments public payments;

    address public stakingRegistry;

    address public networkBeneficiary;

    uint8 public minimumBidIncreasePercentage; // 10 = 10%

    uint256 public maxAuctionLength;

    uint256 public auctionLengthExtension;

    uint256 public offerCancelationDelay;

    mapping(address => mapping(uint256 => mapping(address => SalePrice)))
        public tokenSalePrices;

    mapping(address => mapping(uint256 => mapping(address => Offer)))
        public tokenCurrentOffers;

    mapping(address => mapping(uint256 => Auction)) public tokenAuctions;

    mapping(address => mapping(uint256 => Bid)) public auctionBids;

    uint256[50] private __gap;
}// MIT
pragma solidity 0.7.3;


abstract contract SuperRareBazaarBase is SuperRareBazaarStorage {
    using SafeMath for uint256;
    using SafeMath for uint8;
    using SafeERC20 for IERC20;


    function _checkIfCurrencyIsApproved(address _currencyAddress)
        internal
        view
    {
        require(
            _currencyAddress == address(0) ||
                approvedTokenRegistry.isApprovedToken(_currencyAddress),
            "Not approved currency"
        );
    }

    function _ownerMustHaveMarketplaceApprovedForNFT(
        address _originContract,
        uint256 _tokenId
    ) internal view {
        IERC721 erc721 = IERC721(_originContract);
        address owner = erc721.ownerOf(_tokenId);
        require(
            erc721.isApprovedForAll(owner, address(this)),
            "owner must have approved contract"
        );
    }

    function _senderMustBeTokenOwner(address _originContract, uint256 _tokenId)
        internal
        view
    {
        IERC721 erc721 = IERC721(_originContract);
        require(
            erc721.ownerOf(_tokenId) == msg.sender,
            "sender must be the token owner"
        );
    }

    function _checkSplits(
        address payable[] calldata _splits,
        uint8[] calldata _ratios
    ) internal pure {
        require(_splits.length > 0, "checkSplits::Must have at least 1 split");
        require(_splits.length <= 5, "checkSplits::Split exceeded max size");
        require(
            _splits.length == _ratios.length,
            "checkSplits::Splits and ratios must be equal"
        );
        uint256 totalRatio = 0;

        for (uint256 i = 0; i < _ratios.length; i++) {
            totalRatio += _ratios[i];
        }

        require(totalRatio == 100, "checkSplits::Total must be equal to 100");
    }

    function _senderMustHaveMarketplaceApproved(
        address _contract,
        uint256 _amount
    ) internal view {
        if (_contract == address(0)) {
            return;
        }

        IERC20 erc20 = IERC20(_contract);

        require(
            erc20.allowance(msg.sender, address(this)) >= _amount,
            "sender needs to approve marketplace for currency"
        );
    }

    function _checkAmountAndTransfer(address _currencyAddress, uint256 _amount)
        internal
    {
        if (_currencyAddress == address(0)) {
            require(msg.value == _amount, "not enough eth sent");
            return;
        }

        require(msg.value == 0, "msg.value should be 0 when not using eth");

        IERC20 erc20 = IERC20(_currencyAddress);
        uint256 balanceBefore = erc20.balanceOf(address(this));

        erc20.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 balanceAfter = erc20.balanceOf(address(this));

        require(
            balanceAfter.sub(balanceBefore) == _amount,
            "not enough tokens transfered"
        );
    }

    function _refund(
        address _currencyAddress,
        uint256 _amount,
        uint256 _marketplaceFee,
        address _recipient
    ) internal {
        if (_amount == 0) {
            return;
        }

        uint256 requiredAmount = _amount.add(
            _amount.mul(_marketplaceFee).div(100)
        );

        if (_currencyAddress == address(0)) {
            (bool success, bytes memory data) = address(payments).call{
                value: requiredAmount
            }(
                abi.encodeWithSignature(
                    "refund(address,uint256)",
                    _recipient,
                    requiredAmount
                )
            );

            require(success, string(data));
            return;
        }

        IERC20 erc20 = IERC20(_currencyAddress);
        erc20.safeTransfer(_recipient, requiredAmount);
    }

    function _payout(
        address _originContract,
        uint256 _tokenId,
        address _currencyAddress,
        uint256 _amount,
        address _seller,
        address payable[] memory _splitAddrs,
        uint8[] memory _splitRatios
    ) internal {
        require(
            _splitAddrs.length == _splitRatios.length,
            "Number of split addresses and ratios must be equal."
        );


        uint256 remainingAmount = _amount;

        uint256 marketplaceFee = marketplaceSettings.calculateMarketplaceFee(
            _amount
        );

        address payable[] memory mktFeeRecip = new address payable[](1);
        mktFeeRecip[0] = payable(networkBeneficiary);
        uint256[] memory mktFee = new uint256[](1);
        mktFee[0] = marketplaceFee;

        _performPayouts(_currencyAddress, marketplaceFee, mktFeeRecip, mktFee);

        if (
            !marketplaceSettings.hasERC721TokenSold(_originContract, _tokenId)
        ) {
            uint256[] memory platformFee = new uint256[](1);

            if (spaceOperatorRegistry.isApprovedSpaceOperator(_seller)) {
                uint256 platformCommission = spaceOperatorRegistry
                    .getPlatformCommission(_seller);

                remainingAmount = remainingAmount.sub(
                    _amount.mul(platformCommission).div(100)
                );

                platformFee[0] = _amount.mul(platformCommission).div(100);

                _performPayouts(
                    _currencyAddress,
                    platformFee[0],
                    mktFeeRecip,
                    platformFee
                );
            } else {
                uint256 platformCommission = marketplaceSettings
                    .getERC721ContractPrimarySaleFeePercentage(_originContract);

                remainingAmount = remainingAmount.sub(
                    _amount.mul(platformCommission).div(100)
                );

                platformFee[0] = _amount.mul(platformCommission).div(100);

                _performPayouts(
                    _currencyAddress,
                    platformFee[0],
                    mktFeeRecip,
                    platformFee
                );
            }
        } else {
            (
                address payable[] memory receivers,
                uint256[] memory royalties
            ) = royaltyEngine.getRoyalty(_originContract, _tokenId, _amount);

            uint256 totalRoyalties = 0;

            for (uint256 i = 0; i < royalties.length; i++) {
                totalRoyalties = totalRoyalties.add(royalties[i]);
            }

            remainingAmount = remainingAmount.sub(totalRoyalties);
            _performPayouts(
                _currencyAddress,
                totalRoyalties,
                receivers,
                royalties
            );
        }

        uint256[] memory remainingAmts = new uint256[](_splitAddrs.length);

        uint256 totalSplit = 0;

        for (uint256 i = 0; i < _splitAddrs.length; i++) {
            remainingAmts[i] = remainingAmount.mul(_splitRatios[i]).div(100);
            totalSplit = totalSplit.add(
                remainingAmount.mul(_splitRatios[i]).div(100)
            );
        }
        _performPayouts(
            _currencyAddress,
            totalSplit,
            _splitAddrs,
            remainingAmts
        );
    }

    function _performPayouts(
        address _currencyAddress,
        uint256 _amount,
        address payable[] memory _recipients,
        uint256[] memory _amounts
    ) internal {
        if (_currencyAddress == address(0)) {
            (bool success, bytes memory data) = address(payments).call{
                value: _amount
            }(
                abi.encodeWithSelector(
                    IPayments.payout.selector,
                    _recipients,
                    _amounts
                )
            );

            require(success, string(data));
        } else {
            IERC20 erc20 = IERC20(_currencyAddress);

            for (uint256 i = 0; i < _recipients.length; i++) {
                erc20.safeTransfer(_recipients[i], _amounts[i]);
            }
        }
    }
}// MIT
pragma solidity 0.7.3;


contract SuperRareAuctionHouse is
    ISuperRareAuctionHouse,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    SuperRareBazaarBase
{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function initialize(
        address _marketplaceSettings,
        address _royaltyRegistry,
        address _royaltyEngine,
        address _spaceOperatorRegistry,
        address _approvedTokenRegistry,
        address _payments,
        address _stakingRegistry,
        address _networkBeneficiary
    ) public initializer {

        require(_marketplaceSettings != address(0));
        require(_royaltyRegistry != address(0));
        require(_royaltyEngine != address(0));
        require(_spaceOperatorRegistry != address(0));
        require(_approvedTokenRegistry != address(0));
        require(_payments != address(0));
        require(_networkBeneficiary != address(0));

        marketplaceSettings = IMarketplaceSettings(_marketplaceSettings);
        royaltyRegistry = IERC721CreatorRoyalty(_royaltyRegistry);
        royaltyEngine = IRoyaltyEngineV1(_royaltyEngine);
        spaceOperatorRegistry = ISpaceOperatorRegistry(_spaceOperatorRegistry);
        approvedTokenRegistry = IApprovedTokenRegistry(_approvedTokenRegistry);
        payments = IPayments(_payments);
        stakingRegistry = _stakingRegistry;
        networkBeneficiary = _networkBeneficiary;

        minimumBidIncreasePercentage = 10;
        maxAuctionLength = 7 days;
        auctionLengthExtension = 15 minutes;
        offerCancelationDelay = 5 minutes;

        __Ownable_init();
        __ReentrancyGuard_init();
    }

    function configureAuction(
        bytes32 _auctionType,
        address _originContract,
        uint256 _tokenId,
        uint256 _startingAmount,
        address _currencyAddress,
        uint256 _lengthOfAuction,
        uint256 _startTime,
        address payable[] calldata _splitAddresses,
        uint8[] calldata _splitRatios
    ) external override {

        _checkIfCurrencyIsApproved(_currencyAddress);
        _senderMustBeTokenOwner(_originContract, _tokenId);
        _ownerMustHaveMarketplaceApprovedForNFT(_originContract, _tokenId);
        _checkSplits(_splitAddresses, _splitRatios);
        _checkValidAuctionType(_auctionType);

        require(
            _lengthOfAuction <= maxAuctionLength,
            "configureAuction::Auction too long."
        );

        Auction memory auction = tokenAuctions[_originContract][_tokenId];

        require(
            auction.auctionType == NO_AUCTION ||
                auction.auctionCreator != msg.sender,
            "configureAuction::Cannot have a current auction."
        );

        require(_lengthOfAuction > 0, "configureAuction::Length must be > 0");

        if (_auctionType == COLDIE_AUCTION) {
            require(
                _startingAmount > 0,
                "configureAuction::Coldie starting price must be > 0"
            );
        } else if (_auctionType == SCHEDULED_AUCTION) {
            require(
                _startTime > block.timestamp,
                "configureAuction::Scheduled auction cannot start in past."
            );
        }

        require(
            _startingAmount <= marketplaceSettings.getMarketplaceMaxValue(),
            "configureAuction::Cannot set starting price higher than max value."
        );

        tokenAuctions[_originContract][_tokenId] = Auction(
            msg.sender,
            block.number,
            _auctionType == COLDIE_AUCTION ? 0 : _startTime,
            _lengthOfAuction,
            _currencyAddress,
            _startingAmount,
            _auctionType,
            _splitAddresses,
            _splitRatios
        );

        if (_auctionType == SCHEDULED_AUCTION) {
            IERC721 erc721 = IERC721(_originContract);
            erc721.transferFrom(msg.sender, address(this), _tokenId);
        }

        emit NewAuction(
            _originContract,
            _tokenId,
            msg.sender,
            _currencyAddress,
            _startTime,
            _startingAmount,
            _lengthOfAuction
        );
    }

    function convertOfferToAuction(
        address _originContract,
        uint256 _tokenId,
        address _currencyAddress,
        uint256 _amount,
        uint256 _lengthOfAuction,
        address payable[] calldata _splitAddresses,
        uint8[] calldata _splitRatios
    ) external override {

        _senderMustBeTokenOwner(_originContract, _tokenId);
        _ownerMustHaveMarketplaceApprovedForNFT(_originContract, _tokenId);
        _checkSplits(_splitAddresses, _splitRatios);

        Auction memory auction = tokenAuctions[_originContract][_tokenId];

        require(
            auction.auctionType == NO_AUCTION ||
                auction.auctionCreator != msg.sender,
            "convertOfferToAuction::Cannot have a current auction."
        );

        require(
            _lengthOfAuction <= maxAuctionLength,
            "convertOfferToAuction::Auction too long."
        );

        Offer memory currOffer = tokenCurrentOffers[_originContract][_tokenId][
            _currencyAddress
        ];

        require(currOffer.buyer != msg.sender, "convert::own offer");

        require(
            currOffer.convertible,
            "convertOfferToAuction::Offer is not convertible"
        );

        require(
            currOffer.amount == _amount,
            "convertOfferToAuction::Converting offer with different amount."
        );

        tokenAuctions[_originContract][_tokenId] = Auction(
            msg.sender,
            block.number,
            block.timestamp,
            _lengthOfAuction,
            _currencyAddress,
            currOffer.amount,
            COLDIE_AUCTION,
            _splitAddresses,
            _splitRatios
        );

        delete tokenCurrentOffers[_originContract][_tokenId][_currencyAddress];

        auctionBids[_originContract][_tokenId] = Bid(
            currOffer.buyer,
            _currencyAddress,
            _amount,
            marketplaceSettings.getMarketplaceFeePercentage()
        );

        IERC721 erc721 = IERC721(_originContract);
        erc721.transferFrom(msg.sender, address(this), _tokenId);

        emit NewAuction(
            _originContract,
            _tokenId,
            msg.sender,
            _currencyAddress,
            block.timestamp,
            _amount,
            _lengthOfAuction
        );

        emit AuctionBid(
            _originContract,
            currOffer.buyer,
            _tokenId,
            _currencyAddress,
            _amount,
            true,
            0,
            address(0)
        );
    }

    function cancelAuction(address _originContract, uint256 _tokenId)
        external
        override
    {

        Auction memory auction = tokenAuctions[_originContract][_tokenId];

        IERC721 erc721 = IERC721(_originContract);

        require(
            auction.auctionType != NO_AUCTION,
            "cancelAuction::Must have an auction configured."
        );

        require(
            auction.startingTime == 0 || block.timestamp < auction.startingTime,
            "cancelAuction::Auction must not have started."
        );

        require(
            auction.auctionCreator == msg.sender ||
                erc721.ownerOf(_tokenId) == msg.sender,
            "cancelAuction::Must be creator or owner."
        );

        delete tokenAuctions[_originContract][_tokenId];

        if (erc721.ownerOf(_tokenId) == address(this)) {
            erc721.transferFrom(address(this), msg.sender, _tokenId);
        }

        emit CancelAuction(_originContract, _tokenId, auction.auctionCreator);
    }

    function bid(
        address _originContract,
        uint256 _tokenId,
        address _currencyAddress,
        uint256 _amount
    ) external payable override nonReentrant {

        uint256 requiredAmount = _amount.add(
            marketplaceSettings.calculateMarketplaceFee(_amount)
        );

        _senderMustHaveMarketplaceApproved(_currencyAddress, requiredAmount);

        Auction memory auction = tokenAuctions[_originContract][_tokenId];

        require(
            auction.auctionType != NO_AUCTION,
            "bid::Must have a current auction."
        );

        require(
            auction.auctionCreator != msg.sender,
            "bid::Cannot bid on your own auction."
        );

        require(
            block.timestamp >= auction.startingTime,
            "bid::Auction not active."
        );

        require(
            _currencyAddress == auction.currencyAddress,
            "bid::Currency must be in configured denomination"
        );

        require(_amount > 0, "bid::Cannot be 0");

        require(
            _amount <= marketplaceSettings.getMarketplaceMaxValue(),
            "bid::Must be less than max value."
        );

        require(
            _amount >= auction.minimumBid,
            "bid::Cannot be lower than minimum bid."
        );

        require(
            auction.startingTime == 0 ||
                block.timestamp <
                auction.startingTime.add(auction.lengthOfAuction),
            "bid::Must be active."
        );

        Bid memory currBid = auctionBids[_originContract][_tokenId];

        require(
            _amount >=
                currBid.amount.add(
                    currBid.amount.mul(minimumBidIncreasePercentage).div(100)
                ),
            "bid::Must be higher than prev bid + min increase."
        );

        IERC721 erc721 = IERC721(_originContract);
        address tokenOwner = erc721.ownerOf(_tokenId);

        require(
            auction.auctionCreator == tokenOwner || tokenOwner == address(this),
            "bid::Auction creator must be owner."
        );

        if (auction.auctionCreator == tokenOwner) {
            _ownerMustHaveMarketplaceApprovedForNFT(_originContract, _tokenId);
        }

        _checkAmountAndTransfer(_currencyAddress, requiredAmount);

        _refund(
            _currencyAddress,
            currBid.amount,
            currBid.marketplaceFee,
            currBid.bidder
        );

        auctionBids[_originContract][_tokenId] = Bid(
            msg.sender,
            _currencyAddress,
            _amount,
            marketplaceSettings.getMarketplaceFeePercentage()
        );

        bool startedAuction = false;
        uint256 newAuctionLength = 0;

        if (auction.startingTime == 0) {
            tokenAuctions[_originContract][_tokenId].startingTime = block
                .timestamp;

            erc721.transferFrom(
                auction.auctionCreator,
                address(this),
                _tokenId
            );

            startedAuction = true;
        } else if (
            auction.startingTime.add(auction.lengthOfAuction).sub(
                block.timestamp
            ) < auctionLengthExtension
        ) {
            newAuctionLength = block.timestamp.add(auctionLengthExtension).sub(
                auction.startingTime
            );

            tokenAuctions[_originContract][_tokenId]
                .lengthOfAuction = newAuctionLength;
        }

        emit AuctionBid(
            _originContract,
            msg.sender,
            _tokenId,
            _currencyAddress,
            _amount,
            startedAuction,
            newAuctionLength,
            currBid.bidder
        );
    }

    function settleAuction(address _originContract, uint256 _tokenId)
        external
        override
    {

        Auction memory auction = tokenAuctions[_originContract][_tokenId];

        require(
            auction.auctionType != NO_AUCTION && auction.startingTime != 0,
            "settleAuction::Must have a current valid auction."
        );

        require(
            block.timestamp >=
                auction.startingTime.add(auction.lengthOfAuction),
            "settleAuction::Can only settle ended auctions."
        );

        Bid memory currBid = auctionBids[_originContract][_tokenId];

        delete tokenAuctions[_originContract][_tokenId];
        delete auctionBids[_originContract][_tokenId];

        IERC721 erc721 = IERC721(_originContract);

        if (currBid.bidder == address(0)) {
            erc721.transferFrom(
                address(this),
                auction.auctionCreator,
                _tokenId
            );
        } else {
            erc721.transferFrom(address(this), currBid.bidder, _tokenId);

            _payout(
                _originContract,
                _tokenId,
                auction.currencyAddress,
                currBid.amount,
                auction.auctionCreator,
                auction.splitRecipients,
                auction.splitRatios
            );

            marketplaceSettings.markERC721Token(
                _originContract,
                _tokenId,
                true
            );
        }

        emit AuctionSettled(
            _originContract,
            currBid.bidder,
            auction.auctionCreator,
            _tokenId,
            auction.currencyAddress,
            currBid.amount
        );
    }

    function getAuctionDetails(address _originContract, uint256 _tokenId)
        external
        view
        override
        returns (
            address,
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            bytes32,
            address payable[] memory,
            uint8[] memory
        )
    {

        Auction memory auction = tokenAuctions[_originContract][_tokenId];

        return (
            auction.auctionCreator,
            auction.creationBlock,
            auction.startingTime,
            auction.lengthOfAuction,
            auction.currencyAddress,
            auction.minimumBid,
            auction.auctionType,
            auction.splitRecipients,
            auction.splitRatios
        );
    }

    function _checkValidAuctionType(bytes32 _auctionType) internal pure {

        if (
            _auctionType != COLDIE_AUCTION && _auctionType != SCHEDULED_AUCTION
        ) {
            revert("Invalid Auction Type");
        }
    }
}