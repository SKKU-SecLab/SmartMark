
pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// Apache-2.0

pragma solidity ^0.8.13;


interface IPropertyValidator {


    function validateProperty(address tokenAddress, uint256 tokenId, bytes calldata propertyData) external view;

}// Apache-2.0

pragma solidity ^0.8.13;



library LibNFTOrder {


    enum OrderStatus {
        INVALID,
        FILLABLE,
        UNFILLABLE,
        EXPIRED
    }

    struct Property {
        IPropertyValidator propertyValidator;
        bytes propertyData;
    }

    struct Fee {
        address recipient;
        uint256 amount;
        bytes feeData;
    }

    struct NFTSellOrder {
        address maker;
        address taker;
        uint256 expiry;
        uint256 nonce;
        IERC20 erc20Token;
        uint256 erc20TokenAmount;
        Fee[] fees;
        address nft;
        uint256 nftId;
    }

    struct NFTBuyOrder {
        address maker;
        address taker;
        uint256 expiry;
        uint256 nonce;
        IERC20 erc20Token;
        uint256 erc20TokenAmount;
        Fee[] fees;
        address nft;
        uint256 nftId;
        Property[] nftProperties;
    }

    struct ERC1155SellOrder {
        address maker;
        address taker;
        uint256 expiry;
        uint256 nonce;
        IERC20 erc20Token;
        uint256 erc20TokenAmount;
        Fee[] fees;
        address erc1155Token;
        uint256 erc1155TokenId;
        uint128 erc1155TokenAmount;
    }

    struct ERC1155BuyOrder {
        address maker;
        address taker;
        uint256 expiry;
        uint256 nonce;
        IERC20 erc20Token;
        uint256 erc20TokenAmount;
        Fee[] fees;
        address erc1155Token;
        uint256 erc1155TokenId;
        Property[] erc1155TokenProperties;
        uint128 erc1155TokenAmount;
    }

    struct OrderInfo {
        bytes32 orderHash;
        OrderStatus status;
        uint128 orderAmount;
        uint128 remainingAmount;
    }

    uint256 private constant _NFT_SELL_ORDER_TYPE_HASH = 0xed676c7f3e8232a311454799b1cf26e75b4abc90c9bf06c9f7e8e79fcc7fe14d;

    uint256 private constant _NFT_BUY_ORDER_TYPE_HASH = 0xa525d336300f566329800fcbe82fd263226dc27d6c109f060d9a4a364281521c;

    uint256 private constant _ERC_1155_SELL_ORDER_TYPE_HASH = 0x3529b5920cc48ecbceb24e9c51dccb50fefd8db2cf05d36e356aeb1754e19eda;

    uint256 private constant _ERC_1155_BUY_ORDER_TYPE_HASH = 0x1a6eaae1fbed341e0974212ec17f035a9d419cadc3bf5154841cbf7fd605ba48;

    uint256 private constant _FEE_TYPE_HASH = 0xe68c29f1b4e8cce0bbcac76eb1334bdc1dc1f293a517c90e9e532340e1e94115;

    uint256 private constant _PROPERTY_TYPE_HASH = 0x6292cf854241cb36887e639065eca63b3af9f7f70270cebeda4c29b6d3bc65e8;

    bytes32 private constant _EMPTY_ARRAY_KECCAK256 = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    bytes32 private constant _NULL_PROPERTY_STRUCT_HASH = 0x720ee400a9024f6a49768142c339bf09d2dd9056ab52d20fbe7165faba6e142d;

    uint256 private constant ADDRESS_MASK = (1 << 160) - 1;

    function asNFTSellOrder(NFTBuyOrder memory nftBuyOrder) internal pure returns (NFTSellOrder memory order) {

        assembly { order := nftBuyOrder }
    }

    function asNFTSellOrder(ERC1155SellOrder memory erc1155SellOrder) internal pure returns (NFTSellOrder memory order) {

        assembly { order := erc1155SellOrder }
    }

    function asNFTBuyOrder(ERC1155BuyOrder memory erc1155BuyOrder) internal pure returns (NFTBuyOrder memory order) {

        assembly { order := erc1155BuyOrder }
    }

    function asERC1155SellOrder(NFTSellOrder memory nftSellOrder) internal pure returns (ERC1155SellOrder memory order) {

        assembly { order := nftSellOrder }
    }

    function asERC1155BuyOrder(NFTBuyOrder memory nftBuyOrder) internal pure returns (ERC1155BuyOrder memory order) {

        assembly { order := nftBuyOrder }
    }

    function getNFTSellOrderStructHash(NFTSellOrder memory order, uint256 hashNonce) internal pure returns (bytes32 structHash) {

        bytes32 feesHash = _feesHash(order.fees);

        assembly {
            if lt(order, 32) { invalid() } // Don't underflow memory.

            let typeHashPos := sub(order, 32) // order - 32
            let feesHashPos := add(order, 192) // order + (32 * 6)
            let hashNoncePos := add(order, 288) // order + (32 * 9)

            let typeHashMemBefore := mload(typeHashPos)
            let feeHashMemBefore := mload(feesHashPos)
            let hashNonceMemBefore := mload(hashNoncePos)

            mstore(typeHashPos, _NFT_SELL_ORDER_TYPE_HASH)
            mstore(feesHashPos, feesHash)
            mstore(hashNoncePos, hashNonce)
            structHash := keccak256(typeHashPos, 352 /* 32 * 11 */ )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(feesHashPos, feeHashMemBefore)
            mstore(hashNoncePos, hashNonceMemBefore)
        }
        return structHash;
    }

    function getNFTBuyOrderStructHash(NFTBuyOrder memory order, uint256 hashNonce) internal pure returns (bytes32 structHash) {

        bytes32 propertiesHash = _propertiesHash(order.nftProperties);
        bytes32 feesHash = _feesHash(order.fees);

        assembly {
            if lt(order, 32) { invalid() } // Don't underflow memory.

            let typeHashPos := sub(order, 32) // order - 32
            let feesHashPos := add(order, 192) // order + (32 * 6)
            let propertiesHashPos := add(order, 288) // order + (32 * 9)
            let hashNoncePos := add(order, 320) // order + (32 * 10)

            let typeHashMemBefore := mload(typeHashPos)
            let feeHashMemBefore := mload(feesHashPos)
            let propertiesHashMemBefore := mload(propertiesHashPos)
            let hashNonceMemBefore := mload(hashNoncePos)

            mstore(typeHashPos, _NFT_BUY_ORDER_TYPE_HASH)
            mstore(feesHashPos, feesHash)
            mstore(propertiesHashPos, propertiesHash)
            mstore(hashNoncePos, hashNonce)
            structHash := keccak256(typeHashPos, 384 /* 32 * 12 */ )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(feesHashPos, feeHashMemBefore)
            mstore(propertiesHashPos, propertiesHashMemBefore)
            mstore(hashNoncePos, hashNonceMemBefore)
        }
        return structHash;
    }

    function getERC1155SellOrderStructHash(ERC1155SellOrder memory order, uint256 hashNonce) internal pure returns (bytes32 structHash) {

        bytes32 feesHash = _feesHash(order.fees);

        assembly {
            if lt(order, 32) { invalid() } // Don't underflow memory.

            let typeHashPos := sub(order, 32) // order - 32
            let feesHashPos := add(order, 192) // order + (32 * 6)
            let hashNoncePos := add(order, 320) // order + (32 * 10)

            let typeHashMemBefore := mload(typeHashPos)
            let feesHashMemBefore := mload(feesHashPos)
            let hashNonceMemBefore := mload(hashNoncePos)

            mstore(typeHashPos, _ERC_1155_SELL_ORDER_TYPE_HASH)
            mstore(feesHashPos, feesHash)
            mstore(hashNoncePos, hashNonce)
            structHash := keccak256(typeHashPos, 384 /* 32 * 12 */ )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(feesHashPos, feesHashMemBefore)
            mstore(hashNoncePos, hashNonceMemBefore)
        }
        return structHash;
    }

    function getERC1155BuyOrderStructHash(ERC1155BuyOrder memory order, uint256 hashNonce) internal pure returns (bytes32 structHash) {

        bytes32 propertiesHash = _propertiesHash(order.erc1155TokenProperties);
        bytes32 feesHash = _feesHash(order.fees);

        assembly {
            if lt(order, 32) { invalid() } // Don't underflow memory.

            let typeHashPos := sub(order, 32) // order - 32
            let feesHashPos := add(order, 192) // order + (32 * 6)
            let propertiesHashPos := add(order, 288) // order + (32 * 9)
            let hashNoncePos := add(order, 352) // order + (32 * 11)

            let typeHashMemBefore := mload(typeHashPos)
            let feesHashMemBefore := mload(feesHashPos)
            let propertiesHashMemBefore := mload(propertiesHashPos)
            let hashNonceMemBefore := mload(hashNoncePos)

            mstore(typeHashPos, _ERC_1155_BUY_ORDER_TYPE_HASH)
            mstore(feesHashPos, feesHash)
            mstore(propertiesHashPos, propertiesHash)
            mstore(hashNoncePos, hashNonce)
            structHash := keccak256(typeHashPos, 416 /* 32 * 13 */ )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(feesHashPos, feesHashMemBefore)
            mstore(propertiesHashPos, propertiesHashMemBefore)
            mstore(hashNoncePos, hashNonceMemBefore)
        }
        return structHash;
    }

    function _propertiesHash(Property[] memory properties) private pure returns (bytes32 propertiesHash) {

        uint256 numProperties = properties.length;
        if (numProperties == 0) {
            propertiesHash = _EMPTY_ARRAY_KECCAK256;
        } else if (numProperties == 1) {
            Property memory property = properties[0];
            if (address(property.propertyValidator) == address(0) && property.propertyData.length == 0) {
                propertiesHash = _NULL_PROPERTY_STRUCT_HASH;
            } else {
                bytes32 dataHash = keccak256(property.propertyData);
                assembly {
                    let mem := mload(64)
                    mstore(mem, _PROPERTY_TYPE_HASH)
                    mstore(add(mem, 32), and(ADDRESS_MASK, mload(property)))
                    mstore(add(mem, 64), dataHash)
                    mstore(mem, keccak256(mem, 96))
                    propertiesHash := keccak256(mem, 32)
                }
            }
        } else {
            bytes32[] memory propertyStructHashArray = new bytes32[](numProperties);
            for (uint256 i = 0; i < numProperties; i++) {
                propertyStructHashArray[i] = keccak256(abi.encode(
                        _PROPERTY_TYPE_HASH, properties[i].propertyValidator, keccak256(properties[i].propertyData)));
            }
            assembly {
                propertiesHash := keccak256(add(propertyStructHashArray, 32), mul(numProperties, 32))
            }
        }
    }

    function _feesHash(Fee[] memory fees) private pure returns (bytes32 feesHash) {

        uint256 numFees = fees.length;
        if (numFees == 0) {
            feesHash = _EMPTY_ARRAY_KECCAK256;
        } else if (numFees == 1) {
            Fee memory fee = fees[0];
            bytes32 dataHash = keccak256(fee.feeData);
            assembly {
                let mem := mload(64)
                mstore(mem, _FEE_TYPE_HASH)
                mstore(add(mem, 32), and(ADDRESS_MASK, mload(fee)))
                mstore(add(mem, 64), mload(add(fee, 32)))
                mstore(add(mem, 96), dataHash)
                mstore(mem, keccak256(mem, 128))
                feesHash := keccak256(mem, 32)
            }
        } else {
            bytes32[] memory feeStructHashArray = new bytes32[](numFees);
            for (uint256 i = 0; i < numFees; i++) {
                feeStructHashArray[i] = keccak256(abi.encode(_FEE_TYPE_HASH, fees[i].recipient, fees[i].amount, keccak256(fees[i].feeData)));
            }
            assembly {
                feesHash := keccak256(add(feeStructHashArray, 32), mul(numFees, 32))
            }
        }
    }
}// Apache-2.0

pragma solidity ^0.8.13;

library LibSignature {


    enum SignatureType {
        EIP712,
        PRESIGNED
    }

    struct Signature {
        SignatureType signatureType;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
}// Apache-2.0

pragma solidity ^0.8.13;


interface IERC721OrdersFeature {

    function validateERC721SellOrderSignature(LibNFTOrder.NFTSellOrder calldata order, LibSignature.Signature calldata signature) external view;

    function validateERC721BuyOrderSignature(LibNFTOrder.NFTBuyOrder calldata order, LibSignature.Signature calldata signature) external view;

    function getERC721SellOrderHash(LibNFTOrder.NFTSellOrder calldata order) external view returns (bytes32);

    function getERC721BuyOrderHash(LibNFTOrder.NFTBuyOrder calldata order) external view returns (bytes32);

    function getERC721OrderStatusBitVector(address maker, uint248 nonceRange) external view returns (uint256);

    function getHashNonce(address maker) external view returns (uint256);

}

interface IERC1155OrdersFeature {

    function validateERC1155SellOrderSignature(LibNFTOrder.ERC1155SellOrder calldata order, LibSignature.Signature calldata signature) external view;

    function validateERC1155BuyOrderSignature(LibNFTOrder.ERC1155BuyOrder calldata order, LibSignature.Signature calldata signature) external view;

    function getERC1155SellOrderInfo(LibNFTOrder.ERC1155SellOrder calldata order) external view returns (LibNFTOrder.OrderInfo memory orderInfo);

    function getERC1155BuyOrderInfo(LibNFTOrder.ERC1155BuyOrder calldata order) external view returns (LibNFTOrder.OrderInfo memory orderInfo);

    function getERC1155OrderNonceStatusBitVector(address maker, uint248 nonceRange) external view returns (uint256);

}

contract ElementExHelper {


    struct ERC20CheckInfo {
        uint256 balance;
        uint256 allowance;
        bool balanceCheck;          // check `balance >= erc20TotalAmount`
        bool allowanceCheck;        // check `allowance >= erc20TotalAmount`
        bool listingTimeCheck;      // check `block.timestamp >= listingTime`
        bool takerCheck;            // check `order.taker == taker || order.taker == address(0)`
    }

    struct ERC721CheckInfo {
        bool ecr721TokenIdCheck;
        bool erc721OwnerCheck;
        bool erc721ApprovedCheck;
        bool listingTimeCheck;      // check `block.timestamp >= listingTime`
        bool takerCheck;            // check `order.taker == taker || order.taker == address(0)`
    }

    struct ERC721SellOrderCheckInfo {
        bool success;
        uint256 hashNonce;
        bytes32 orderHash;
        bool makerCheck;
        bool takerCheck;
        bool listingTimeCheck;
        bool expireTimeCheck;
        bool extraCheck;
        bool nonceCheck;
        bool feesCheck;
        bool erc20AddressCheck;
        bool erc721AddressCheck;
        bool erc721OwnerCheck;
        bool erc721ApprovedCheck;
        uint256 erc20TotalAmount;   // erc20TotalAmount = `order.erc20TokenAmount` + totalFeesAmount
    }

    struct ERC721BuyOrderCheckInfo {
        bool success;
        uint256 hashNonce;
        bytes32 orderHash;
        bool makerCheck;
        bool takerCheck;
        bool listingTimeCheck;
        bool expireTimeCheck;
        bool nonceCheck;
        bool feesCheck;
        bool propertiesCheck;
        bool erc20AddressCheck;
        bool erc721AddressCheck;
        uint256 erc20TotalAmount;
        uint256 erc20Balance;
        uint256 erc20Allowance;
        bool erc20BalanceCheck;
        bool erc20AllowanceCheck;
    }

    struct ERC1155SellOrderCheckInfo {
        bool success;
        uint256 hashNonce;
        bytes32 orderHash;
        uint256 erc1155RemainingAmount;
        uint256 erc1155Balance;     // erc1155.balanceOf(order.maker, order.erc1155TokenId)
        bool makerCheck;            // check `maker != address(0)`
        bool takerCheck;            // check `taker != ElementEx`
        bool listingTimeCheck;      // check `listingTime < expireTime`
        bool expireTimeCheck;       // check `expireTime > block.timestamp`
        bool extraCheck;
        bool nonceCheck;
        bool remainingAmountCheck;
        bool feesCheck;
        bool erc20AddressCheck;
        bool erc1155AddressCheck;
        bool erc1155BalanceCheck;   // check `erc1155Balance >= order.erc1155TokenAmount
        bool erc1155ApprovedCheck;  // check `erc1155.isApprovedForAll(order.maker, elementEx)`
        uint256 erc20TotalAmount;   // erc20TotalAmount = `order.erc20TokenAmount` + totalFeesAmount
    }

    struct ERC1155SellOrderTakerCheckInfo {
        uint256 erc20Balance;
        uint256 erc20Allowance;
        uint256 erc20WillPayAmount;
        bool balanceCheck;          // check `erc20Balance >= erc20WillPayAmount
        bool allowanceCheck;        // check `erc20Allowance >= erc20WillPayAmount
        bool buyAmountCheck;        // check `erc1155BuyAmount <= erc1155RemainingAmount`
        bool listingTimeCheck;      // check `block.timestamp >= listingTime`
        bool takerCheck;            // check `order.taker == taker || order.taker == address(0)`
    }

    struct ERC1155BuyOrderCheckInfo {
        bool success;
        uint256 hashNonce;
        bytes32 orderHash;
        uint256 erc1155RemainingAmount;
        bool makerCheck;            // check `maker != address(0)`
        bool takerCheck;            // check `taker != ElementEx`
        bool listingTimeCheck;      // check `listingTime < expireTime`
        bool expireTimeCheck;       // check `expireTime > block.timestamp`
        bool nonceCheck;
        bool remainingAmountCheck;  // check `erc1155RemainingAmount > 0`
        bool feesCheck;
        bool propertiesCheck;
        bool erc20AddressCheck;
        bool erc1155AddressCheck;
        uint256 erc20TotalAmount;   // erc20TotalAmount = `order.erc20TokenAmount` + totalFeesAmount
        uint256 erc20Balance;
        uint256 erc20Allowance;
        bool erc20BalanceCheck;     // check `erc20Balance >= erc20TotalAmount`
        bool erc20AllowanceCheck;   // check `erc20AllowanceCheck >= erc20TotalAmount`
    }

    struct ERC1155BuyOrderTakerCheckInfo {
        uint256 erc1155Balance;     // erc1155.balanceOf(taker, erc1155TokenId)
        bool ecr1155TokenIdCheck;
        bool erc1155BalanceCheck;   // check `erc1155SellAmount <= erc1155Balance`
        bool erc1155ApprovedCheck;  // check `erc1155.isApprovedForAll(taker, elementEx)`
        bool sellAmountCheck;       // check `erc1155SellAmount <= erc1155RemainingAmount`
        bool listingTimeCheck;      // check `block.timestamp >= listingTime`
        bool takerCheck;            // check `order.taker == taker || order.taker == address(0)`
    }

    using Address for address;

    address constant internal NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable ELEMENT_EX;
    address public immutable WETH;

    constructor(address elementEx, address weth) {
        ELEMENT_EX = elementEx;
        WETH = weth;
    }

    function checkERC721SellOrder(LibNFTOrder.NFTSellOrder calldata order, address taker)
        public
        view
        returns (ERC721SellOrderCheckInfo memory info, ERC20CheckInfo memory takerCheckInfo)
    {

        info.hashNonce = getHashNonce(order.maker);
        info.orderHash = getERC721SellOrderHash(order);
        info.makerCheck = (order.maker != address(0));
        info.takerCheck = (order.taker != ELEMENT_EX);
        info.listingTimeCheck = checkListingTime(order.expiry);
        info.expireTimeCheck = checkExpiryTime(order.expiry);
        info.extraCheck = checkExtra(order.expiry);
        info.nonceCheck = !isERC721OrderNonceFilled(order.maker, order.nonce);
        info.feesCheck = checkFees(order.fees);
        info.erc20TotalAmount = calcERC20TotalAmount(order.erc20TokenAmount, order.fees);
        info.erc721OwnerCheck = checkERC721Owner(order.nft, order.nftId, order.maker);
        info.erc721ApprovedCheck = checkERC721Approved(order.nft, order.nftId, order.maker);
        info.erc20AddressCheck = checkERC20Address(true, address(order.erc20Token));
        info.erc721AddressCheck = checkERC721Address(order.nft);
        info.success = _isERC721SellOrderSuccess(info);

        if (taker != address(0)) {
            takerCheckInfo.listingTimeCheck = (block.timestamp >= ((order.expiry >> 32) & 0xffffffff));
            takerCheckInfo.takerCheck = (order.taker == taker || order.taker == address(0));
            (takerCheckInfo.balanceCheck, takerCheckInfo.balance) =
                checkERC20Balance(true, taker, address(order.erc20Token), info.erc20TotalAmount);
            (takerCheckInfo.allowanceCheck, takerCheckInfo.allowance) =
                checkERC20Allowance(true, taker, address(order.erc20Token), info.erc20TotalAmount);
        }
        return (info, takerCheckInfo);
    }

    function checkERC721SellOrderEx(
        LibNFTOrder.NFTSellOrder calldata order,
        address taker,
        LibSignature.Signature calldata signature
    )
        public
        view
        returns (ERC721SellOrderCheckInfo memory info, ERC20CheckInfo memory takerCheckInfo, bool validSignature)
    {

        (info, takerCheckInfo) = checkERC721SellOrder(order, taker);
        validSignature = validateERC721SellOrderSignature(order, signature);
        return (info, takerCheckInfo, validSignature);
    }

    function checkERC721BuyOrder(LibNFTOrder.NFTBuyOrder calldata order, address taker, uint256 erc721TokenId)
        public
        view
        returns (ERC721BuyOrderCheckInfo memory info, ERC721CheckInfo memory takerCheckInfo)
    {

        info.hashNonce = getHashNonce(order.maker);
        info.orderHash = getERC721BuyOrderHash(order);
        info.makerCheck = (order.maker != address(0));
        info.takerCheck = (order.taker != ELEMENT_EX);
        info.listingTimeCheck = checkListingTime(order.expiry);
        info.expireTimeCheck = checkExpiryTime(order.expiry);
        info.nonceCheck = !isERC721OrderNonceFilled(order.maker, order.nonce);
        info.feesCheck = checkFees(order.fees);
        info.propertiesCheck = checkProperties(order.nftProperties, order.nftId);
        info.erc20AddressCheck = checkERC20Address(false, address(order.erc20Token));
        info.erc721AddressCheck = checkERC721Address(order.nft);

        info.erc20TotalAmount = calcERC20TotalAmount(order.erc20TokenAmount, order.fees);
        (info.erc20BalanceCheck, info.erc20Balance) =
            checkERC20Balance(false, order.maker, address(order.erc20Token), info.erc20TotalAmount);
        (info.erc20AllowanceCheck, info.erc20Allowance) =
            checkERC20Allowance(false, order.maker, address(order.erc20Token), info.erc20TotalAmount);
        info.success = _isERC721BuyOrderSuccess(info);

        if (taker != address(0)) {
            takerCheckInfo.listingTimeCheck = (block.timestamp >= ((order.expiry >> 32) & 0xffffffff));
            takerCheckInfo.takerCheck = (order.taker == taker || order.taker == address(0));
            takerCheckInfo.ecr721TokenIdCheck = checkNftIdIsMatched(order.nftProperties, order.nft, order.nftId, erc721TokenId);
            takerCheckInfo.erc721OwnerCheck = checkERC721Owner(order.nft, erc721TokenId, taker);
            takerCheckInfo.erc721ApprovedCheck = checkERC721Approved(order.nft, erc721TokenId, taker);
        }
        return (info, takerCheckInfo);
    }

    function checkERC721BuyOrderEx(
        LibNFTOrder.NFTBuyOrder calldata order,
        address taker,
        uint256 erc721TokenId,
        LibSignature.Signature calldata signature
    )
        public
        view
        returns (ERC721BuyOrderCheckInfo memory info, ERC721CheckInfo memory takerCheckInfo, bool validSignature)
    {

        (info, takerCheckInfo) = checkERC721BuyOrder(order, taker, erc721TokenId);
        validSignature = validateERC721BuyOrderSignature(order, signature);
        return (info, takerCheckInfo, validSignature);
    }

    function checkERC1155SellOrder(LibNFTOrder.ERC1155SellOrder calldata order, address taker, uint128 erc1155BuyAmount)
        public
        view
        returns (ERC1155SellOrderCheckInfo memory info, ERC1155SellOrderTakerCheckInfo memory takerCheckInfo)
    {

        LibNFTOrder.OrderInfo memory orderInfo = getERC1155SellOrderInfo(order);
        (uint256 balance, bool isApprovedForAll) = getERC1155Info(order.erc1155Token, order.erc1155TokenId, order.maker, ELEMENT_EX);

        info.hashNonce = getHashNonce(order.maker);
        info.orderHash = orderInfo.orderHash;
        info.erc1155RemainingAmount = orderInfo.remainingAmount;
        info.erc1155Balance = balance;
        info.makerCheck = (order.maker != address(0));
        info.takerCheck = (order.taker != ELEMENT_EX);
        info.listingTimeCheck = checkListingTime(order.expiry);
        info.expireTimeCheck = checkExpiryTime(order.expiry);
        info.extraCheck = checkExtra(order.expiry);
        info.nonceCheck = !isERC1155OrderNonceCancelled(order.maker, order.nonce);
        info.remainingAmountCheck = (info.erc1155RemainingAmount > 0);
        info.feesCheck = checkFees(order.fees);
        info.erc20TotalAmount = calcERC20TotalAmount(order.erc20TokenAmount, order.fees);
        info.erc1155BalanceCheck = (balance >= order.erc1155TokenAmount);
        info.erc1155ApprovedCheck = isApprovedForAll;
        info.erc20AddressCheck = checkERC20Address(true, address(order.erc20Token));
        info.erc1155AddressCheck = checkERC1155Address(order.erc1155Token);
        info.success = _isERC1155SellOrderSuccess(info);

        if (taker != address(0)) {
            if (order.erc1155TokenAmount > 0) {
                takerCheckInfo.erc20WillPayAmount = _ceilDiv(order.erc20TokenAmount * erc1155BuyAmount, order.erc1155TokenAmount);
                for (uint256 i = 0; i < order.fees.length; i++) {
                    takerCheckInfo.erc20WillPayAmount += order.fees[i].amount * erc1155BuyAmount / order.erc1155TokenAmount;
                }
            } else {
                takerCheckInfo.erc20WillPayAmount = type(uint128).max;
            }
            (takerCheckInfo.balanceCheck, takerCheckInfo.erc20Balance) = checkERC20Balance(true, taker, address(order.erc20Token), takerCheckInfo.erc20WillPayAmount);
            (takerCheckInfo.allowanceCheck, takerCheckInfo.erc20Allowance) = checkERC20Allowance(true, taker, address(order.erc20Token), takerCheckInfo.erc20WillPayAmount);
            takerCheckInfo.buyAmountCheck = (erc1155BuyAmount <= info.erc1155RemainingAmount);
            takerCheckInfo.listingTimeCheck = (block.timestamp >= ((order.expiry >> 32) & 0xffffffff));
            takerCheckInfo.takerCheck = (order.taker == taker || order.taker == address(0));
        }
        return (info, takerCheckInfo);
    }

    function checkERC1155SellOrderEx(
        LibNFTOrder.ERC1155SellOrder calldata order,
        address taker,
        uint128 erc1155BuyAmount,
        LibSignature.Signature calldata signature
    )
        public
        view
        returns (ERC1155SellOrderCheckInfo memory info, ERC1155SellOrderTakerCheckInfo memory takerCheckInfo, bool validSignature)
    {

        (info, takerCheckInfo) = checkERC1155SellOrder(order, taker, erc1155BuyAmount);
        validSignature = validateERC1155SellOrderSignature(order, signature);
        return (info, takerCheckInfo, validSignature);
    }

    function checkERC1155BuyOrder(
        LibNFTOrder.ERC1155BuyOrder calldata order,
        address taker,
        uint256 erc1155TokenId,
        uint128 erc1155SellAmount
    )
        public
        view
        returns (ERC1155BuyOrderCheckInfo memory info, ERC1155BuyOrderTakerCheckInfo memory takerCheckInfo)
    {

        LibNFTOrder.OrderInfo memory orderInfo = getERC1155BuyOrderInfo(order);
        info.hashNonce = getHashNonce(order.maker);
        info.orderHash = orderInfo.orderHash;
        info.erc1155RemainingAmount = orderInfo.remainingAmount;
        info.makerCheck = (order.maker != address(0));
        info.takerCheck = (order.taker != ELEMENT_EX);
        info.listingTimeCheck = checkListingTime(order.expiry);
        info.expireTimeCheck = checkExpiryTime(order.expiry);
        info.nonceCheck = !isERC1155OrderNonceCancelled(order.maker, order.nonce);
        info.remainingAmountCheck = (info.erc1155RemainingAmount > 0);
        info.feesCheck = checkFees(order.fees);
        info.propertiesCheck = checkProperties(order.erc1155TokenProperties, order.erc1155TokenId);
        info.erc20AddressCheck = checkERC20Address(false, address(order.erc20Token));
        info.erc1155AddressCheck = checkERC1155Address(order.erc1155Token);
        info.erc20TotalAmount = calcERC20TotalAmount(order.erc20TokenAmount, order.fees);
        (info.erc20BalanceCheck, info.erc20Balance) = checkERC20Balance(false, order.maker, address(order.erc20Token), info.erc20TotalAmount);
        (info.erc20AllowanceCheck, info.erc20Allowance) = checkERC20Allowance(false, order.maker, address(order.erc20Token), info.erc20TotalAmount);
        info.success = _isERC1155BuyOrderSuccess(info);

        if (taker != address(0)) {
            takerCheckInfo.ecr1155TokenIdCheck = checkNftIdIsMatched(order.erc1155TokenProperties, order.erc1155Token, order.erc1155TokenId, erc1155TokenId);
            (takerCheckInfo.erc1155Balance, takerCheckInfo.erc1155ApprovedCheck) = getERC1155Info(order.erc1155Token, erc1155TokenId, taker, ELEMENT_EX);
            takerCheckInfo.erc1155BalanceCheck = (erc1155SellAmount <= takerCheckInfo.erc1155Balance);
            takerCheckInfo.sellAmountCheck = (erc1155SellAmount <= info.erc1155RemainingAmount);
            takerCheckInfo.listingTimeCheck = (block.timestamp >= ((order.expiry >> 32) & 0xffffffff));
            takerCheckInfo.takerCheck = (order.taker == taker || order.taker == address(0));
        }
        return (info, takerCheckInfo);
    }

    function checkERC1155BuyOrderEx(
        LibNFTOrder.ERC1155BuyOrder calldata order,
        address taker,
        uint256 erc1155TokenId,
        uint128 erc1155SellAmount,
        LibSignature.Signature calldata signature
    )
        public
        view
        returns (ERC1155BuyOrderCheckInfo memory info, ERC1155BuyOrderTakerCheckInfo memory takerCheckInfo, bool validSignature)
    {

        (info, takerCheckInfo) = checkERC1155BuyOrder(order, taker, erc1155TokenId, erc1155SellAmount);
        validSignature = validateERC1155BuyOrderSignature(order, signature);
        return (info, takerCheckInfo, validSignature);
    }

    function getERC20Info(address erc20, address account, address allowanceAddress)
        public
        view
        returns (uint256 balance, uint256 allowance)
    {

        if (erc20 == address(0) || erc20 == NATIVE_TOKEN_ADDRESS) {
            balance = address(account).balance;
        } else {
            try IERC20(erc20).balanceOf(account) returns (uint256 _balance) {
                balance = _balance;
            } catch {}
            try IERC20(erc20).allowance(account, allowanceAddress) returns (uint256 _allowance) {
                allowance = _allowance;
            } catch {}
        }
        return (balance, allowance);
    }

    function getERC721Info(address erc721, uint256 tokenId, address account, address approvedAddress)
        public
        view
        returns (address owner, bool isApprovedForAll, address approvedAccount)
    {
        try IERC721(erc721).ownerOf(tokenId) returns (address _owner) {
            owner = _owner;
        } catch {}
        try IERC721(erc721).isApprovedForAll(account, approvedAddress) returns (bool _isApprovedForAll) {
            isApprovedForAll = _isApprovedForAll;
        } catch {}
        try IERC721(erc721).getApproved(tokenId) returns (address _account) {
            approvedAccount = _account;
        } catch {}
        return (owner, isApprovedForAll, approvedAccount);
    }

    function getERC1155Info(address erc1155, uint256 tokenId, address account, address approvedAddress)
        public
        view
        returns (uint256 balance, bool isApprovedForAll)
    {
        try IERC1155(erc1155).balanceOf(account, tokenId) returns (uint256 _balance) {
            balance = _balance;
        } catch {}
        try IERC1155(erc1155).isApprovedForAll(account, approvedAddress) returns (bool _isApprovedForAll) {
            isApprovedForAll = _isApprovedForAll;
        } catch {}
        return (balance, isApprovedForAll);
    }

    function validateERC721SellOrderSignature(LibNFTOrder.NFTSellOrder calldata order, LibSignature.Signature calldata signature)
        public
        view
        returns (bool valid)
    {
        try IERC721OrdersFeature(ELEMENT_EX).validateERC721SellOrderSignature(order, signature) {
            return true;
        } catch {}
        return false;
    }

    function validateERC721BuyOrderSignature(LibNFTOrder.NFTBuyOrder calldata order, LibSignature.Signature calldata signature)
        public
        view
        returns (bool valid)
    {
        try IERC721OrdersFeature(ELEMENT_EX).validateERC721BuyOrderSignature(order, signature) {
            return true;
        } catch {}
        return false;
    }

    function getERC721SellOrderHash(LibNFTOrder.NFTSellOrder calldata order) public view returns (bytes32) {
        try IERC721OrdersFeature(ELEMENT_EX).getERC721SellOrderHash(order) returns (bytes32 orderHash) {
            return orderHash;
        } catch {}
        return bytes32("");
    }

    function getERC721BuyOrderHash(LibNFTOrder.NFTBuyOrder calldata order) public view returns (bytes32) {
        try IERC721OrdersFeature(ELEMENT_EX).getERC721BuyOrderHash(order) returns (bytes32 orderHash) {
            return orderHash;
        } catch {}
        return bytes32("");
    }

    function isERC721OrderNonceFilled(address account, uint256 nonce) public view returns (bool filled) {
        uint256 bitVector = IERC721OrdersFeature(ELEMENT_EX).getERC721OrderStatusBitVector(account, uint248(nonce >> 8));
        uint256 flag = 1 << (nonce & 0xff);
        return (bitVector & flag) != 0;
    }

    function isERC1155OrderNonceCancelled(address account, uint256 nonce) public view returns (bool filled) {
        uint256 bitVector = IERC1155OrdersFeature(ELEMENT_EX).getERC1155OrderNonceStatusBitVector(account, uint248(nonce >> 8));
        uint256 flag = 1 << (nonce & 0xff);
        return (bitVector & flag) != 0;
    }

    function getHashNonce(address maker) public view returns (uint256) {
        return IERC721OrdersFeature(ELEMENT_EX).getHashNonce(maker);
    }

    function getERC1155SellOrderInfo(LibNFTOrder.ERC1155SellOrder calldata order)
        public
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo)
    {
        try IERC1155OrdersFeature(ELEMENT_EX).getERC1155SellOrderInfo(order) returns (LibNFTOrder.OrderInfo memory _orderInfo) {
            orderInfo = _orderInfo;
        } catch {}
        return orderInfo;
    }

    function getERC1155BuyOrderInfo(LibNFTOrder.ERC1155BuyOrder calldata order)
        public
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo)
    {
        try IERC1155OrdersFeature(ELEMENT_EX).getERC1155BuyOrderInfo(order) returns (LibNFTOrder.OrderInfo memory _orderInfo) {
            orderInfo = _orderInfo;
        } catch {}
        return orderInfo;
    }

    function validateERC1155SellOrderSignature(LibNFTOrder.ERC1155SellOrder calldata order, LibSignature.Signature calldata signature)
        public
        view
        returns (bool valid)
    {
        try IERC1155OrdersFeature(ELEMENT_EX).validateERC1155SellOrderSignature(order, signature) {
            return true;
        } catch {}
        return false;
    }

    function validateERC1155BuyOrderSignature(LibNFTOrder.ERC1155BuyOrder calldata order, LibSignature.Signature calldata signature)
        public
        view
        returns (bool valid)
    {
        try IERC1155OrdersFeature(ELEMENT_EX).validateERC1155BuyOrderSignature(order, signature) {
            return true;
        } catch {}
        return false;
    }

    function _isERC721SellOrderSuccess(ERC721SellOrderCheckInfo memory info) private pure returns (bool successAll) {
        return info.makerCheck &&
            info.takerCheck &&
            info.listingTimeCheck &&
            info.expireTimeCheck &&
            info.extraCheck &&
            info.nonceCheck &&
            info.feesCheck &&
            info.erc721OwnerCheck &&
            info.erc721ApprovedCheck &&
            info.erc20AddressCheck &&
            info.erc721AddressCheck;
    }

    function _isERC721BuyOrderSuccess(ERC721BuyOrderCheckInfo memory info) private pure returns (bool successAll) {
        return info.makerCheck &&
            info.takerCheck &&
            info.listingTimeCheck &&
            info.expireTimeCheck &&
            info.nonceCheck &&
            info.feesCheck &&
            info.propertiesCheck &&
            info.erc20BalanceCheck &&
            info.erc20AllowanceCheck &&
            info.erc20AddressCheck &&
            info.erc721AddressCheck;
    }

    function _isERC1155SellOrderSuccess(ERC1155SellOrderCheckInfo memory info) private pure returns (bool successAll) {
        return info.makerCheck &&
            info.takerCheck &&
            info.listingTimeCheck &&
            info.expireTimeCheck &&
            info.extraCheck &&
            info.nonceCheck &&
            info.remainingAmountCheck &&
            info.feesCheck &&
            info.erc20AddressCheck &&
            info.erc1155AddressCheck &&
            info.erc1155BalanceCheck &&
            info.erc1155ApprovedCheck;
    }

    function _isERC1155BuyOrderSuccess(ERC1155BuyOrderCheckInfo memory info) private pure returns (bool successAll) {
        return info.makerCheck &&
            info.takerCheck &&
            info.listingTimeCheck &&
            info.expireTimeCheck &&
            info.nonceCheck &&
            info.remainingAmountCheck &&
            info.feesCheck &&
            info.propertiesCheck &&
            info.erc20AddressCheck &&
            info.erc1155AddressCheck &&
            info.erc20BalanceCheck &&
            info.erc20AllowanceCheck;
    }

    function checkListingTime(uint256 expiry) internal pure returns (bool success) {
        uint256 listingTime = (expiry >> 32) & 0xffffffff;
        uint256 expiryTime = expiry & 0xffffffff;
        return listingTime < expiryTime;
    }

    function checkExpiryTime(uint256 expiry) internal view returns (bool success) {
        uint256 expiryTime = expiry & 0xffffffff;
        return expiryTime > block.timestamp;
    }

    function checkExtra(uint256 expiry) internal pure returns (bool success) {
        if (expiry >> 252 == 1) {
            uint256 extra = (expiry >> 64) & 0xffffffff;
            return (extra <= 100000000);
        }
        return true;
    }

    function checkERC721Owner(address nft, uint256 nftId, address owner) internal view returns (bool success) {
        try IERC721(nft).ownerOf(nftId) returns (address _owner) {
            success = (owner == _owner);
        } catch {
            success = false;
        }
        return success;
    }

    function checkERC721Approved(address nft, uint256 nftId, address owner) internal view returns (bool) {
        try IERC721(nft).isApprovedForAll(owner, ELEMENT_EX) returns (bool approved) {
            if (approved) {
                return true;
            }
        } catch {
        }
        try IERC721(nft).getApproved(nftId) returns (address account) {
            return (account == ELEMENT_EX);
        } catch {
        }
        return false;
    }

    function checkERC20Balance(bool buyNft, address buyer, address erc20, uint256 erc20TotalAmount)
        internal
        view
        returns
        (bool success, uint256 balance)
    {
        if (erc20 == address(0)) {
            return (false, 0);
        }
        if (erc20 == NATIVE_TOKEN_ADDRESS) {
            if (buyNft) {
                balance = buyer.balance;
                success = (balance >= erc20TotalAmount);
                return (success, balance);
            } else {
                return (false, 0);
            }
        }

        try IERC20(erc20).balanceOf(buyer) returns (uint256 _balance) {
            balance = _balance;
            success = (balance >= erc20TotalAmount);
        } catch {
            success = false;
            balance = 0;
        }
        return (success, balance);
    }

    function checkERC20Allowance(bool buyNft, address buyer, address erc20, uint256 erc20TotalAmount)
        internal
        view
        returns
        (bool success, uint256 allowance)
    {
        if (erc20 == address(0)) {
            return (false, 0);
        }
        if (erc20 == NATIVE_TOKEN_ADDRESS) {
            return (buyNft, 0);
        }

        try IERC20(erc20).allowance(buyer, ELEMENT_EX) returns (uint256 _allowance) {
            allowance = _allowance;
            success = (allowance >= erc20TotalAmount);
        } catch {
            success = false;
            allowance = 0;
        }
        return (success, allowance);
    }

    function checkERC20Address(bool sellOrder, address erc20) internal view returns (bool) {
        if (erc20 == address(0)) {
            return false;
        }
        if (erc20 == NATIVE_TOKEN_ADDRESS) {
            return sellOrder;
        }
        return erc20.isContract();
    }

    function checkERC721Address(address erc721) internal view returns (bool) {
        if (erc721 == address(0) || erc721 == NATIVE_TOKEN_ADDRESS) {
            return false;
        }

        try IERC165(erc721).supportsInterface(type(IERC721).interfaceId) returns (bool support) {
            return support;
        } catch {}
        return false;
    }

    function checkERC1155Address(address erc1155) internal view returns (bool) {
        if (erc1155 == address(0) || erc1155 == NATIVE_TOKEN_ADDRESS) {
            return false;
        }

        try IERC165(erc1155).supportsInterface(type(IERC1155).interfaceId) returns (bool support) {
            return support;
        } catch {}
        return false;
    }

    function checkFees(LibNFTOrder.Fee[] calldata fees) internal view returns (bool success) {
        for (uint256 i = 0; i < fees.length; i++) {
            if (fees[i].recipient == ELEMENT_EX) {
                return false;
            }
            if (fees[i].feeData.length > 0 && !fees[i].recipient.isContract()) {
                return false;
            }
        }
        return true;
    }

    function checkProperties(LibNFTOrder.Property[] calldata properties, uint256 nftId) internal view returns (bool success) {
        if (properties.length > 0) {
            if (nftId != 0) {
                return false;
            }
            for (uint256 i = 0; i < properties.length; i++) {
                address propertyValidator = address(properties[i].propertyValidator);
                if (propertyValidator != address(0) && !propertyValidator.isContract()) {
                    return false;
                }
            }
        }
        return true;
    }

    function checkNftIdIsMatched(LibNFTOrder.Property[] calldata properties, address nft, uint256 orderNftId, uint256 nftId)
        internal
        view
        returns (bool isMatched)
    {
        if (properties.length == 0) {
            return orderNftId == nftId;
        }
        for (uint256 i = 0; i < properties.length; i++) {
            LibNFTOrder.Property memory property = properties[i];
            if (address(property.propertyValidator) != address(0)) {
                try property.propertyValidator.validateProperty(nft, nftId, property.propertyData) {
                } catch {
                    return false;
                }
            }
        }
        return true;
    }

    function calcERC20TotalAmount(uint256 erc20TokenAmount, LibNFTOrder.Fee[] calldata fees) internal pure returns (uint256) {
        uint256 sum = erc20TokenAmount;
        for (uint256 i = 0; i < fees.length; i++) {
            sum += fees[i].amount;
        }
        return sum;
    }

    function _ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a + b - 1) / b;
    }
}