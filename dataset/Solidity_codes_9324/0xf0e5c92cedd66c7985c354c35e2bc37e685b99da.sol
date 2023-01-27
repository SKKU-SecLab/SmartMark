
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

pragma solidity =0.8.4;

interface ISwap {

    struct Offer {
        address seller;
        address oToken;
        uint96 minPrice;
        address biddingToken;
        uint96 minBidSize;
        uint128 totalSize;
        uint128 availableSize;
        uint256 totalSales;
    }

    struct Bid {
        uint256 swapId;
        uint256 nonce;
        address signerWallet;
        uint256 sellAmount;
        uint256 buyAmount;
        address referrer;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct OfferDetails {
        address seller;
        address oToken;
        uint256 minPrice;
        address biddingToken;
        uint256 minBidSize;
    }

    event Swap(
        uint256 indexed swapId,
        uint256 nonce,
        address indexed signerWallet,
        uint256 signerAmount,
        uint256 sellerAmount,
        address referrer,
        uint256 feeAmount
    );

    event NewOffer(
        uint256 swapId,
        address seller,
        address oToken,
        address biddingToken,
        uint256 minPrice,
        uint256 minBidSize,
        uint256 totalSize
    );

    event SetFee(address referrer, uint256 fee);

    event SettleOffer(uint256 swapId);

    event Cancel(uint256 indexed nonce, address indexed signerWallet);

    function createOffer(
        address oToken,
        address biddingToken,
        uint96 minPrice,
        uint96 minBidSize,
        uint128 totalSize
    ) external returns (uint256 swapId);


    function settleOffer(uint256 swapId, Bid[] calldata bids) external;


    function cancelNonce(uint256[] calldata nonces) external;


    function check(Bid calldata bid)
        external
        view
        returns (uint256, bytes32[] memory);


    function averagePriceForOffer(uint256 swapId)
        external
        view
        returns (uint256);


    function nonceUsed(address, uint256) external view returns (bool);

}// MIT
pragma solidity =0.8.4;


interface IERC20Detailed is IERC20 {

    function decimals() external view returns (uint8);


    function symbol() external view returns (string calldata);


    function name() external view returns (string calldata);

}// MIT

pragma solidity =0.8.4;


contract Swap is ISwap, ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "EIP712Domain(",
                "string name,",
                "string version,",
                "uint256 chainId,",
                "address verifyingContract",
                ")"
            )
        );

    bytes32 public constant BID_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "Bid(",
                "uint256 swapId,",
                "uint256 nonce,",
                "address signerWallet,",
                "uint256 sellAmount,",
                "uint256 buyAmount,",
                "address referrer",
                ")"
            )
        );

    bytes32 public constant DOMAIN_NAME = keccak256("RIBBON SWAP");
    bytes32 public constant DOMAIN_VERSION = keccak256("1");
    uint256 public immutable DOMAIN_CHAIN_ID;
    bytes32 public immutable DOMAIN_SEPARATOR;

    uint256 internal constant MAX_PERCENTAGE = 10000;
    uint256 internal constant MAX_FEE = 1000;
    uint256 internal constant MAX_ERROR_COUNT = 10;
    uint256 internal constant OTOKEN_DECIMALS = 8;

    uint256 public offersCounter = 0;

    mapping(uint256 => Offer) public swapOffers;

    mapping(address => uint256) public referralFees;

    mapping(address => mapping(uint256 => uint256)) internal _nonceGroups;


    constructor() {
        uint256 currentChainId = getChainId();
        DOMAIN_CHAIN_ID = currentChainId;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                DOMAIN_NAME,
                DOMAIN_VERSION,
                currentChainId,
                this
            )
        );
    }


    function setFee(address referrer, uint256 fee) external onlyOwner {

        require(referrer != address(0), "Referrer cannot be the zero address");
        require(fee < MAX_FEE, "Fee exceeds maximum");

        referralFees[referrer] = fee;

        emit SetFee(referrer, fee);
    }


    function createOffer(
        address oToken,
        address biddingToken,
        uint96 minPrice,
        uint96 minBidSize,
        uint128 totalSize
    ) external override returns (uint256 swapId) {

        require(oToken != address(0), "oToken cannot be the zero address");
        require(
            biddingToken != address(0),
            "BiddingToken cannot be the zero address"
        );
        require(minPrice > 0, "MinPrice must be larger than zero");
        require(minBidSize > 0, "MinBidSize must be larger than zero");
        require(minBidSize <= totalSize, "MinBidSize exceeds total size");

        offersCounter += 1;

        swapId = offersCounter;

        swapOffers[swapId].seller = msg.sender;
        swapOffers[swapId].oToken = oToken;
        swapOffers[swapId].biddingToken = biddingToken;
        swapOffers[swapId].minBidSize = minBidSize;
        swapOffers[swapId].minPrice = minPrice;
        swapOffers[swapId].totalSize = totalSize;
        swapOffers[swapId].availableSize = totalSize;
        swapOffers[swapId].totalSales = 1;

        emit NewOffer(
            swapId,
            msg.sender,
            oToken,
            biddingToken,
            minPrice,
            minBidSize,
            totalSize
        );
    }

    function settleOffer(uint256 swapId, Bid[] calldata bids)
        external
        override
        nonReentrant
    {

        Offer storage offer = swapOffers[swapId];

        address seller = offer.seller;
        require(
            seller == msg.sender,
            "Only seller can settle or offer doesn't exist"
        );
        require(offer.availableSize > 0, "Offer fully settled");

        uint256 totalSales;
        OfferDetails memory offerDetails;
        offerDetails.seller = seller;
        offerDetails.oToken = offer.oToken;
        offerDetails.biddingToken = offer.biddingToken;
        offerDetails.minPrice = offer.minPrice;
        offerDetails.minBidSize = offer.minBidSize;

        for (uint256 i = 0; i < bids.length; i++) {
            require(
                swapId == bids[i].swapId,
                "Offer and bid swapId mismatched"
            );

            _swap(offerDetails, offer, bids[i]);
            totalSales += bids[i].sellAmount;
        }

        bool fullySettled = offer.availableSize == 0;

        offer.totalSales += totalSales - (fullySettled ? 1 : 0);

        if (fullySettled) {
            offer.seller = address(0);
            offer.oToken = address(0);
            offer.biddingToken = address(0);
            offer.minBidSize = 0;
            offer.minPrice = 0;

            emit SettleOffer(swapId);
        }
    }

    function cancelNonce(uint256[] calldata nonces) external override {

        for (uint256 i = 0; i < nonces.length; i++) {
            uint256 nonce = nonces[i];
            if (_markNonceAsUsed(msg.sender, nonce)) {
                emit Cancel(nonce, msg.sender);
            }
        }
    }


    function check(Bid calldata bid)
        external
        view
        override
        returns (uint256, bytes32[] memory)
    {

        Offer memory offer = swapOffers[bid.swapId];
        require(offer.seller != address(0), "Offer does not exist");

        bytes32[] memory errors = new bytes32[](MAX_ERROR_COUNT);

        uint256 errCount;

        address signatory = _getSignatory(bid);

        if (signatory == address(0)) {
            errors[errCount] = "SIGNATURE_INVALID";
            errCount++;
        }

        if (signatory != bid.signerWallet) {
            errors[errCount] = "SIGNATURE_MISMATCHED";
            errCount++;
        }

        if (nonceUsed(signatory, bid.nonce)) {
            errors[errCount] = "NONCE_ALREADY_USED";
            errCount++;
        }

        if (bid.buyAmount < offer.minBidSize) {
            errors[errCount] = "BID_TOO_SMALL";
            errCount++;
        }
        if (bid.buyAmount > offer.availableSize) {
            errors[errCount] = "BID_EXCEED_AVAILABLE_SIZE";
            errCount++;
        }

        uint256 bidPrice =
            (bid.sellAmount * 10**OTOKEN_DECIMALS) / bid.buyAmount;
        if (bidPrice < offer.minPrice) {
            errors[errCount] = "PRICE_TOO_LOW";
            errCount++;
        }

        uint256 signerAllowance =
            IERC20(offer.biddingToken).allowance(
                bid.signerWallet,
                address(this)
            );
        if (signerAllowance < bid.sellAmount) {
            errors[errCount] = "SIGNER_ALLOWANCE_LOW";
            errCount++;
        }

        uint256 signerBalance =
            IERC20(offer.biddingToken).balanceOf(bid.signerWallet);
        if (signerBalance < bid.sellAmount) {
            errors[errCount] = "SIGNER_BALANCE_LOW";
            errCount++;
        }

        uint256 sellerAllowance =
            IERC20(offer.oToken).allowance(offer.seller, address(this));
        if (sellerAllowance < bid.buyAmount) {
            errors[errCount] = "SELLER_ALLOWANCE_LOW";
            errCount++;
        }

        uint256 sellerBalance = IERC20(offer.oToken).balanceOf(offer.seller);
        if (sellerBalance < bid.buyAmount) {
            errors[errCount] = "SELLER_BALANCE_LOW";
            errCount++;
        }

        return (errCount, errors);
    }

    function averagePriceForOffer(uint256 swapId)
        external
        view
        override
        returns (uint256)
    {

        Offer storage offer = swapOffers[swapId];
        require(offer.totalSize != 0, "Offer does not exist");

        uint256 availableSize = offer.availableSize;

        uint256 adjustment = availableSize != 0 ? 1 : 0;

        return
            ((offer.totalSales - adjustment) * (10**8)) /
            (offer.totalSize - availableSize);
    }

    function nonceUsed(address signer, uint256 nonce)
        public
        view
        override
        returns (bool)
    {

        uint256 groupKey = nonce / 256;
        uint256 indexInGroup = nonce % 256;
        return (_nonceGroups[signer][groupKey] >> indexInGroup) & 1 == 1;
    }


    function _swap(
        OfferDetails memory details,
        Offer storage offer,
        Bid calldata bid
    ) internal {

        require(DOMAIN_CHAIN_ID == getChainId(), "CHAIN_ID_CHANGED");

        address signatory = _getSignatory(bid);
        require(signatory != address(0), "SIGNATURE_INVALID");
        require(signatory == bid.signerWallet, "SIGNATURE_MISMATCHED");
        require(_markNonceAsUsed(signatory, bid.nonce), "NONCE_ALREADY_USED");
        require(
            bid.buyAmount <= offer.availableSize,
            "BID_EXCEED_AVAILABLE_SIZE"
        );
        require(bid.buyAmount >= details.minBidSize, "BID_TOO_SMALL");

        uint256 bidPrice =
            (bid.sellAmount * 10**OTOKEN_DECIMALS) / bid.buyAmount;
        require(bidPrice >= details.minPrice, "PRICE_TOO_LOW");

        offer.availableSize -= uint128(bid.buyAmount);

        IERC20(details.oToken).safeTransferFrom(
            details.seller,
            bid.signerWallet,
            bid.buyAmount
        );

        uint256 feeAmount;
        if (bid.referrer != address(0)) {
            uint256 feePercent = referralFees[bid.referrer];

            if (feePercent > 0) {
                feeAmount = (bid.sellAmount * feePercent) / MAX_PERCENTAGE;

                IERC20(details.biddingToken).safeTransferFrom(
                    bid.signerWallet,
                    bid.referrer,
                    feeAmount
                );
            }
        }

        IERC20(details.biddingToken).safeTransferFrom(
            bid.signerWallet,
            details.seller,
            bid.sellAmount - feeAmount
        );

        emit Swap(
            bid.swapId,
            bid.nonce,
            bid.signerWallet,
            bid.sellAmount,
            bid.buyAmount,
            bid.referrer,
            feeAmount
        );
    }

    function _markNonceAsUsed(address signer, uint256 nonce)
        internal
        returns (bool)
    {

        uint256 groupKey = nonce / 256;
        uint256 indexInGroup = nonce % 256;
        uint256 group = _nonceGroups[signer][groupKey];

        if ((group >> indexInGroup) & 1 == 1) {
            return false;
        }

        _nonceGroups[signer][groupKey] = group | (uint256(1) << indexInGroup);

        return true;
    }

    function _getSignatory(Bid calldata bid) internal view returns (address) {

        return
            ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR,
                        keccak256(
                            abi.encode(
                                BID_TYPEHASH,
                                bid.swapId,
                                bid.nonce,
                                bid.signerWallet,
                                bid.sellAmount,
                                bid.buyAmount,
                                bid.referrer
                            )
                        )
                    )
                ),
                bid.v,
                bid.r,
                bid.s
            );
    }

    function getChainId() internal view returns (uint256 id) {

        assembly {
            id := chainid()
        }
    }
}