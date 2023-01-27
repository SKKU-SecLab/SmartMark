

pragma solidity 0.6.12;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}


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
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


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
}


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
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


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

}


interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}


interface ILinkAccessor {

    function requestRandomness(uint256 userProvidedSeed_) external returns(bytes32);

}


interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}


contract NFTMaster is Ownable, IERC721Receiver {


    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event CreateCollection(address _who, uint256 _collectionId);
    event PublishCollection(address _who, uint256 _collectionId);
    event UnpublishCollection(address _who, uint256 _collectionId);
    event NFTDeposit(address _who, address _tokenAddress, uint256 _tokenId);
    event NFTWithdraw(address _who, address _tokenAddress, uint256 _tokenId);
    event NFTClaim(address _who, address _tokenAddress, uint256 _tokenId);

    IERC20 public wETH;
    IERC20 public baseToken;
    IERC20 public blesToken;
    IERC20 public linkToken;

    uint256 public linkCost = 1e17;  // 0.1 LINK
    ILinkAccessor public linkAccessor;

    bool public canDrawMultiple = true;

    uint256 constant FEE_BASE = 10000;
    uint256 public feeRate = 500;  // 5%

    address public feeTo;

    uint256 public creatingFee = 0;  // By default, 0

    IUniswapV2Router02 public router;

    uint256 public nextNFTId = 1e4;
    uint256 public nextCollectionId = 1e4;

    struct NFT {
        address tokenAddress;
        uint256 tokenId;
        address owner;
        uint256 price;
        uint256 paid;
        uint256 collectionId;
        uint256 indexInCollection;
    }

    mapping(uint256 => NFT) public allNFTs;

    mapping(address => uint256[]) public nftsByOwner;

    mapping(address => mapping(uint256 => uint256)) public nftIdMap;

    struct Collection {
        address owner;
        string name;
        uint256 size;
        uint256 commissionRate;  // for curator (owner)
        bool willAcceptBLES;

        uint256 totalPrice;
        uint256 averagePrice;
        uint256 fee;
        uint256 commission;

        uint256 publishedAt;  // time that published.
        uint256 timesToCall;
        uint256 soldCount;
    }

    mapping(uint256 => Collection) public allCollections;

    mapping(address => uint256[]) public collectionsByOwner;

    mapping(uint256 => mapping(address => bool)) public isCollaborator;

    mapping(uint256 => address[]) public collaborators;

    mapping(uint256 => uint256[]) public nftsByCollectionId;

    struct RequestInfo {
        uint256 collectionId;
    }

    mapping(bytes32 => RequestInfo) public requestInfoMap;

    struct Slot {
        address owner;
        uint256 size;
    }

    mapping(uint256 => Slot[]) public slotMap;

    mapping(uint256 => uint256[]) public nftMapping;

    uint256 public nftPriceFloor = 1e6;
    uint256 public nftPriceCeil = 1e24;
    uint256 public minimumCollectionSize = 3;  // 3 blind boxes
    uint256 public maximumDuration = 14 days;  // Refund if not sold out in 14 days.

    constructor() public { }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }

    function setWETH(IERC20 wETH_) external onlyOwner {

        wETH = wETH_;
    }

    function setLinkToken(IERC20 linkToken_) external onlyOwner {

        linkToken = linkToken_;
    }

    function setBaseToken(IERC20 baseToken_) external onlyOwner {

        baseToken = baseToken_;
    }

    function setBlesToken(IERC20 blesToken_) external onlyOwner {

        blesToken = blesToken_;
    }

    function setLinkAccessor(ILinkAccessor linkAccessor_) external onlyOwner {

        linkAccessor = linkAccessor_;
    }

    function setLinkCost(uint256 linkCost_) external onlyOwner {

        linkCost = linkCost_;
    }

    function setCanDrawMultiple(bool value_) external onlyOwner {

        canDrawMultiple = value_;
    }

    function setFeeRate(uint256 feeRate_) external onlyOwner {

        feeRate = feeRate_;
    }

    function setFeeTo(address feeTo_) external onlyOwner {

        feeTo = feeTo_;
    }

    function setCreatingFee(uint256 creatingFee_) external onlyOwner {

        creatingFee = creatingFee_;
    }

    function setUniswapV2Router(IUniswapV2Router02 router_) external onlyOwner {

        router = router_;
    }

    function setNFTPriceFloor(uint256 value_) external onlyOwner {

        require(value_ < nftPriceCeil, "should be higher than floor");
        nftPriceFloor = value_;
    }

    function setNFTPriceCeil(uint256 value_) external onlyOwner {

        require(value_ > nftPriceFloor, "should be higher than floor");
        nftPriceCeil = value_;
    }

    function setMinimumCollectionSize(uint256 size_) external onlyOwner {

        minimumCollectionSize = size_;
    }

    function setMaximumDuration(uint256 maximumDuration_) external onlyOwner {

        maximumDuration = maximumDuration_;
    }

    function _generateNextNFTId() private returns(uint256) {

        return ++nextNFTId;
    }

    function _generateNextCollectionId() private returns(uint256) {

        return ++nextCollectionId;
    }

    function _depositNFT(address tokenAddress_, uint256 tokenId_) private returns(uint256) {

        IERC721(tokenAddress_).safeTransferFrom(_msgSender(), address(this), tokenId_);

        NFT memory nft;
        nft.tokenAddress = tokenAddress_;
        nft.tokenId = tokenId_;
        nft.owner = _msgSender();
        nft.collectionId = 0;
        nft.indexInCollection = 0;

        uint256 nftId;

        if (nftIdMap[tokenAddress_][tokenId_] > 0) {
            nftId = nftIdMap[tokenAddress_][tokenId_];
        } else {
            nftId = _generateNextNFTId();
            nftIdMap[tokenAddress_][tokenId_] = nftId;
        }

        allNFTs[nftId] = nft;
        nftsByOwner[_msgSender()].push(nftId);

        emit NFTDeposit(_msgSender(), tokenAddress_, tokenId_);
        return nftId;
    }

    function _withdrawNFT(address who_, uint256 nftId_, bool isClaim_) private {

        allNFTs[nftId_].owner = address(0);
        allNFTs[nftId_].collectionId = 0;

        address tokenAddress = allNFTs[nftId_].tokenAddress;
        uint256 tokenId = allNFTs[nftId_].tokenId;

        IERC721(tokenAddress).safeTransferFrom(address(this), who_, tokenId);

        if (isClaim_) {
            emit NFTClaim(who_, tokenAddress, tokenId);
        } else {
            emit NFTWithdraw(who_, tokenAddress, tokenId);
        }
    }

    function claimNFT(uint256 collectionId_, uint256 index_) external {

        Collection storage collection = allCollections[collectionId_];

        require(collection.soldCount == collection.size, "Not finished");

        address winner = getWinner(collectionId_, index_);

        require(winner == _msgSender(), "Only winner can claim");

        uint256 nftId = nftsByCollectionId[collectionId_][index_];

        require(allNFTs[nftId].collectionId == collectionId_, "Already claimed");

        if (allNFTs[nftId].paid == 0) {
            if (collection.willAcceptBLES) {
                allNFTs[nftId].paid = allNFTs[nftId].price.mul(
                    FEE_BASE.sub(collection.commissionRate)).div(FEE_BASE);
                IERC20(blesToken).safeTransfer(allNFTs[nftId].owner, allNFTs[nftId].paid);
            } else {
                allNFTs[nftId].paid = allNFTs[nftId].price.mul(
                    FEE_BASE.sub(feeRate).sub(collection.commissionRate)).div(FEE_BASE);
                IERC20(baseToken).safeTransfer(allNFTs[nftId].owner, allNFTs[nftId].paid);
            }
        }

        _withdrawNFT(_msgSender(), nftId, true);
    }

    function claimRevenue(uint256 collectionId_, uint256 index_) external {

        Collection storage collection = allCollections[collectionId_];

        require(collection.soldCount == collection.size, "Not finished");

        uint256 nftId = nftsByCollectionId[collectionId_][index_];

        require(allNFTs[nftId].owner == _msgSender() && allNFTs[nftId].collectionId > 0, "NFT not claimed");

        if (allNFTs[nftId].paid == 0) {
            if (collection.willAcceptBLES) {
                allNFTs[nftId].paid = allNFTs[nftId].price.mul(
                    FEE_BASE.sub(collection.commissionRate)).div(FEE_BASE);
                IERC20(blesToken).safeTransfer(allNFTs[nftId].owner, allNFTs[nftId].paid);
            } else {
                allNFTs[nftId].paid = allNFTs[nftId].price.mul(
                    FEE_BASE.sub(feeRate).sub(collection.commissionRate)).div(FEE_BASE);
                IERC20(baseToken).safeTransfer(allNFTs[nftId].owner, allNFTs[nftId].paid);
            }
        }
    }

    function claimCommission(uint256 collectionId_) external {

        Collection storage collection = allCollections[collectionId_];

        require(_msgSender() == collection.owner, "Only curator can claim");
        require(collection.soldCount == collection.size, "Not finished");

        if (collection.willAcceptBLES) {
            IERC20(blesToken).safeTransfer(collection.owner, collection.commission);
        } else {
            IERC20(baseToken).safeTransfer(collection.owner, collection.commission);
        }

        collection.commission = 0;
    }

    function claimFee(uint256 collectionId_) external {

        require(feeTo != address(0), "Please set feeTo first");

        Collection storage collection = allCollections[collectionId_];

        require(collection.soldCount == collection.size, "Not finished");
        require(!collection.willAcceptBLES, "No fee if the curator accepts BLES");

        IERC20(baseToken).safeTransfer(feeTo, collection.fee);

        collection.fee = 0;
    }

    function createCollection(
        string calldata name_,
        uint256 size_,
        uint256 commissionRate_,
        bool willAcceptBLES_,
        address[] calldata collaborators_
    ) external {

        require(size_ >= minimumCollectionSize, "Size too small");
        require(commissionRate_.add(feeRate) < FEE_BASE, "Too much commission");

        if (creatingFee > 0) {
            IERC20(blesToken).safeTransfer(feeTo, creatingFee);
        }

        Collection memory collection;
        collection.owner = _msgSender();
        collection.name = name_;
        collection.size = size_;
        collection.commissionRate = commissionRate_;
        collection.totalPrice = 0;
        collection.averagePrice = 0;
        collection.willAcceptBLES = willAcceptBLES_;
        collection.publishedAt = 0;

        uint256 collectionId = _generateNextCollectionId();

        allCollections[collectionId] = collection;
        collectionsByOwner[_msgSender()].push(collectionId);
        collaborators[collectionId] = collaborators_;

        for (uint256 i = 0; i < collaborators_.length; ++i) {
            isCollaborator[collectionId][collaborators_[i]] = true;
        }

        emit CreateCollection(_msgSender(), collectionId);
    }

    function changeCollaborators(uint256 collectionId_, address[] calldata collaborators_) external {

        Collection storage collection = allCollections[collectionId_];

        require(collection.owner == _msgSender(), "Needs collection owner");
        require(!isPublished(collectionId_), "Collection already published");

        uint256 i;

        for (i = 0; i < collaborators_.length; ++i) {
            isCollaborator[collectionId_][collaborators_[i]] = true;
        }

        for (i = 0; i < collaborators[collectionId_].length; ++i) {
            uint256 j;
            for (j = 0; j < collaborators_.length; ++j) {
                if (collaborators[collectionId_][i] == collaborators_[j]) {
                    break;
                }
            }

            if (j == collaborators_.length) {
                isCollaborator[collectionId_][collaborators[collectionId_][i]] = false;
            }
        }

        collaborators[collectionId_] = collaborators_;
    }

    function isPublished(uint256 collectionId_) public view returns(bool) {

        return allCollections[collectionId_].publishedAt > 0;
    }

    function _addNFTToCollection(uint256 nftId_, uint256 collectionId_, uint256 price_) private {

        Collection storage collection = allCollections[collectionId_];

        require(allNFTs[nftId_].owner == _msgSender(), "Only NFT owner can add");
        require(collection.owner == _msgSender() ||
                isCollaborator[collectionId_][_msgSender()], "Needs collection owner or collaborator");

        require(price_ >= nftPriceFloor && price_ <= nftPriceCeil, "Price not in range");

        require(allNFTs[nftId_].collectionId == 0, "Already added");
        require(!isPublished(collectionId_), "Collection already published");
        require(nftsByCollectionId[collectionId_].length < collection.size,
                "collection full");

        allNFTs[nftId_].price = price_;
        allNFTs[nftId_].collectionId = collectionId_;
        allNFTs[nftId_].indexInCollection = nftsByCollectionId[collectionId_].length;

        nftsByCollectionId[collectionId_].push(nftId_);

        collection.totalPrice = collection.totalPrice.add(price_);

        if (!collection.willAcceptBLES) {
            collection.fee = collection.fee.add(price_.mul(feeRate).div(FEE_BASE));
        }

        collection.commission = collection.commission.add(price_.mul(collection.commissionRate).div(FEE_BASE));
    }

    function addNFTToCollection(address tokenAddress_, uint256 tokenId_, uint256 collectionId_, uint256 price_) external {

        uint256 nftId = _depositNFT(tokenAddress_, tokenId_);
        _addNFTToCollection(nftId, collectionId_, price_);
    }

    function editNFTInCollection(uint256 nftId_, uint256 collectionId_, uint256 price_) external {

        Collection storage collection = allCollections[collectionId_];

        require(collection.owner == _msgSender() ||
                allNFTs[nftId_].owner == _msgSender(), "Needs collection owner or NFT owner");

        require(price_ >= nftPriceFloor && price_ <= nftPriceCeil, "Price not in range");

        require(allNFTs[nftId_].collectionId == collectionId_, "NFT not in collection");
        require(!isPublished(collectionId_), "Collection already published");

        collection.totalPrice = collection.totalPrice.add(price_).sub(allNFTs[nftId_].price);

        if (!collection.willAcceptBLES) {
            collection.fee = collection.fee.add(
                price_.mul(feeRate).div(FEE_BASE)).sub(
                    allNFTs[nftId_].price.mul(feeRate).div(FEE_BASE));
        }

        collection.commission = collection.commission.add(
            price_.mul(collection.commissionRate).div(FEE_BASE)).sub(
                allNFTs[nftId_].price.mul(collection.commissionRate).div(FEE_BASE));

        allNFTs[nftId_].price = price_;  // Change price.
    }

    function _removeNFTFromCollection(uint256 nftId_, uint256 collectionId_) private {

        Collection storage collection = allCollections[collectionId_];

        require(allNFTs[nftId_].owner == _msgSender() ||
                collection.owner == _msgSender(),
                "Only NFT owner or collection owner can remove");
        require(allNFTs[nftId_].collectionId == collectionId_, "NFT not in collection");
        require(!isPublished(collectionId_), "Collection already published");

        collection.totalPrice = collection.totalPrice.sub(allNFTs[nftId_].price);

        if (!collection.willAcceptBLES) {
            collection.fee = collection.fee.sub(
                allNFTs[nftId_].price.mul(feeRate).div(FEE_BASE));
        }

        collection.commission = collection.commission.sub(
            allNFTs[nftId_].price.mul(collection.commissionRate).div(FEE_BASE));


        allNFTs[nftId_].collectionId = 0;

        uint256 index = allNFTs[nftId_].indexInCollection;
        uint256 lastNFTId = nftsByCollectionId[collectionId_][nftsByCollectionId[collectionId_].length - 1];

        nftsByCollectionId[collectionId_][index] = lastNFTId;
        allNFTs[lastNFTId].indexInCollection = index;
        nftsByCollectionId[collectionId_].pop();
    }

    function removeNFTFromCollection(uint256 nftId_, uint256 collectionId_) external {

        address nftOwner = allNFTs[nftId_].owner;
        _removeNFTFromCollection(nftId_, collectionId_);
        _withdrawNFT(nftOwner, nftId_, false);
    }

    function randomnessCount(uint256 size_) public pure returns(uint256){

        uint256 i;
        for (i = 0; size_** i <= type(uint256).max / size_; i++) {}
        return i;
    }

    function publishCollection(uint256 collectionId_, address[] calldata path, uint256 amountInMax_, uint256 deadline_) external {

        Collection storage collection = allCollections[collectionId_];

        require(collection.owner == _msgSender(), "Only owner can publish");

        uint256 actualSize = nftsByCollectionId[collectionId_].length;
        require(actualSize >= minimumCollectionSize, "Not enough boxes");

        collection.size = actualSize;  // Fit the size.

        collection.averagePrice = collection.totalPrice.add(actualSize.sub(1)).div(actualSize);
        collection.publishedAt = now;

        uint256 count = randomnessCount(actualSize);
        uint256 times = actualSize.add(count).sub(1).div(count);  // Math.ceil

        if (linkCost > 0 && address(linkAccessor) != address(0)) {
            buyLink(times, path, amountInMax_, deadline_);
        }

        collection.timesToCall = times;

        emit PublishCollection(_msgSender(), collectionId_);
    }

    function unpublishCollection(uint256 collectionId_) external {


        Collection storage collection = allCollections[collectionId_];

        if (_msgSender() != collection.owner || collection.soldCount > 0) {
            require(now > collection.publishedAt + maximumDuration, "Not expired yet");
            require(collection.soldCount < collection.size, "Sold out");
        }

        collection.publishedAt = 0;
        collection.soldCount = 0;

        uint256 length = slotMap[collectionId_].length;
        for (uint256 i = 0; i < length; ++i) {
            Slot memory slot = slotMap[collectionId_][length.sub(i + 1)];
            slotMap[collectionId_].pop();

            if (collection.willAcceptBLES) {
                IERC20(blesToken).transfer(slot.owner, collection.averagePrice.mul(slot.size));
            } else {
                IERC20(baseToken).transfer(slot.owner, collection.averagePrice.mul(slot.size));
            }
        }

        emit UnpublishCollection(_msgSender(), collectionId_);
    }

    function buyLink(uint256 times_, address[] calldata path, uint256 amountInMax_, uint256 deadline_) internal virtual {

        require(path[path.length.sub(1)] == address(linkToken), "Last token must be LINK");

        uint256 amountToBuy = linkCost.mul(times_);

        if (path.length == 1) {
            linkToken.transferFrom(_msgSender(), address(linkAccessor), amountToBuy);
        } else {
            if (IERC20(path[0]).allowance(address(this), address(router)) < amountInMax_) {
                IERC20(path[0]).approve(address(router), amountInMax_);
            }

            uint256[] memory amounts = router.getAmountsIn(amountToBuy, path);
            IERC20(path[0]).transferFrom(_msgSender(), address(this), amounts[0]);

            router.swapTokensForExactTokens(
                amountToBuy,
                amountInMax_,
                path,
                address(linkAccessor),
                deadline_);
        }
    }

    function drawBoxes(uint256 collectionId_, uint256 times_) external {

        if (!canDrawMultiple) {
            require(times_ == 1, "Can draw only 1");
        }

        require(isPublished(collectionId_), "Not published");

        Collection storage collection = allCollections[collectionId_];

        require(collection.soldCount.add(times_) <= collection.size, "Not enough left");

        uint256 cost = collection.averagePrice.mul(times_);

        if (collection.willAcceptBLES) {
            IERC20(blesToken).safeTransferFrom(_msgSender(), address(this), cost);
        } else {
            IERC20(baseToken).safeTransferFrom(_msgSender(), address(this), cost);
        }

        Slot memory slot;
        slot.owner = _msgSender();
        slot.size = times_;
        slotMap[collectionId_].push(slot);

        uint256 startFromIndex = collection.size.sub(collection.timesToCall);
        if (startFromIndex < collection.soldCount) {
            startFromIndex = collection.soldCount;
        }

        collection.soldCount = collection.soldCount.add(times_);

        for (uint256 i = startFromIndex;
                 i < collection.soldCount;
                 ++i) {
            requestRandomNumber(collectionId_, i.sub(startFromIndex));
        }
    }

    function getWinner(uint256 collectionId_, uint256 nftIndex_) public view returns(address) {

        Collection storage collection = allCollections[collectionId_];

        if (collection.soldCount < collection.size) {
            return address(0);
        }

        uint256 size = collection.size;
        uint256 count = randomnessCount(size);

        uint256 lastRandomnessIndex = nftMapping[collectionId_].length.sub(1);
        uint256 lastR = nftMapping[collectionId_][lastRandomnessIndex];

        nftIndex_ = nftIndex_.add(lastR).mod(size);

        uint256 randomnessIndex = nftIndex_.div(count);

        uint256 r = nftMapping[collectionId_][randomnessIndex];

        uint256 i;

        for (i = 0; i < nftIndex_.mod(count); ++i) {
          r /= size;
        }

        r %= size;

        for (i = 0; i < slotMap[collectionId_].length; ++i) {
            if (r >= slotMap[collectionId_][i].size) {
                r -= slotMap[collectionId_][i].size;
            } else {
                return slotMap[collectionId_][i].owner;
            }
        }

        require(false, "r overflow");
    }

    function psuedoRandomness() public view returns(uint256) {

        return uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(_msgSender())))) / (now)) +
            block.number
        )));
    }

    function requestRandomNumber(uint256 collectionId_, uint256 index_) private {

        if (address(linkAccessor) != address(0)) {
            bytes32 requestId = linkAccessor.requestRandomness(index_);
            requestInfoMap[requestId].collectionId = collectionId_;
        } else {
            useRandomness(collectionId_, psuedoRandomness());
        }
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) public {

        require(_msgSender() == address(linkAccessor), "Only linkAccessor can call");

        uint256 collectionId = requestInfoMap[requestId].collectionId;
        useRandomness(collectionId, randomness);
    }

    function useRandomness(
        uint256 collectionId_,
        uint256 randomness_
    ) private {

        uint256 size = allCollections[collectionId_].size;
        bool[] memory filled = new bool[](size);

        uint256 r;
        uint256 i;
        uint256 j;
        uint256 count = randomnessCount(size);

        for (i = 0; i < nftMapping[collectionId_].length; ++i) {
            r = nftMapping[collectionId_][i];
            for (j = 0; j < count; ++j) {
                filled[r.mod(size)] = true;
                r = r.div(size);
            }
        }

        r = 0;

        uint256 t;
        uint256 remaining = size.sub(count.mul(nftMapping[collectionId_].length));

        for (i = 0; i < count; ++i) {
            if (remaining == 0) {
                break;
            }

            t = randomness_.mod(remaining);
            randomness_ = randomness_.div(remaining);

            t = t.add(1);

            for (j = 0; j < size; ++j) {
                if (!filled[j]) {
                    t = t.sub(1);
                }

                if (t == 0) {
                  break;
                }
            }

            filled[j] = true;
            r = r.mul(size).add(j);
            remaining = remaining.sub(1);
        }

        nftMapping[collectionId_].push(r);
    }
}