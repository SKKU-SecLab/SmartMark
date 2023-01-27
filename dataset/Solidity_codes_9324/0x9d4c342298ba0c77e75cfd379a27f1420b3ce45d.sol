


pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "MUL_ERROR");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "DIVIDING_ERROR");
        return a / b;
    }

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SUB_ERROR");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "ADD_ERROR");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {

        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}


contract InitializableOwnable {

    address public _OWNER_;
    address public _NEW_OWNER_;
    bool internal _INITIALIZED_;


    event OwnershipTransferPrepared(address indexed previousOwner, address indexed newOwner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    modifier notInitialized() {

        require(!_INITIALIZED_, "DODO_INITIALIZED");
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == _OWNER_, "NOT_OWNER");
        _;
    }


    function initOwner(address newOwner) public notInitialized {

        _INITIALIZED_ = true;
        _OWNER_ = newOwner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        emit OwnershipTransferPrepared(_OWNER_, newOwner);
        _NEW_OWNER_ = newOwner;
    }

    function claimOwnership() public {

        require(msg.sender == _NEW_OWNER_, "INVALID_CLAIM");
        emit OwnershipTransferred(_OWNER_, _NEW_OWNER_);
        _OWNER_ = _NEW_OWNER_;
        _NEW_OWNER_ = address(0);
    }
}



interface ICloneFactory {

    function clone(address prototype) external returns (address proxy);

}



contract ReentrancyGuard {

    bool private _ENTERED_;

    modifier preventReentrant() {

        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
}



interface IFilter {

    function init(
        address filterAdmin,
        address nftCollection,
        bool[] memory toggles,
        string memory filterName,
        uint256[] memory numParams,
        uint256[] memory priceRules,
        uint256[] memory spreadIds
    ) external;


    function isNFTValid(address nftCollectionAddress, uint256 nftId) external view returns (bool);


    function _NFT_COLLECTION_() external view returns (address);


    function queryNFTIn(uint256 NFTInAmount)
        external
        view
        returns (uint256 rawReceive, uint256 received);


    function queryNFTTargetOut(uint256 NFTOutAmount)
        external
        view
        returns (uint256 rawPay, uint256 pay);


    function queryNFTRandomOut(uint256 NFTOutAmount)
        external
        view
        returns (uint256 rawPay, uint256 pay);


    function ERC721In(uint256[] memory tokenIds, address to) external returns (uint256 received);


    function ERC721TargetOut(uint256[] memory tokenIds, address to) external returns (uint256 paid);


    function ERC721RandomOut(uint256 amount, address to) external returns (uint256 paid);


    function ERC1155In(uint256[] memory tokenIds, address to) external returns (uint256 received);


    function ERC1155TargetOut(
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        address to
    ) external returns (uint256 paid);


    function ERC1155RandomOut(uint256 amount, address to) external returns (uint256 paid);

}



interface IFilterAdmin {

    function _OWNER_() external view returns (address);


    function _CONTROLLER_() external view returns (address);


    function init(
        address owner,
        uint256 initSupply,
        string memory name,
        string memory symbol,
        uint256 feeRate,
        address controller,
        address maintainer,
        address[] memory filters
    ) external;


    function mintFragTo(address to, uint256 rawAmount) external returns (uint256 received);


    function burnFragFrom(address from, uint256 rawAmount) external returns (uint256 paid);


    function queryMintFee(uint256 rawAmount)
        external
        view
        returns (
            uint256 poolFee,
            uint256 mtFee,
            uint256 afterChargedAmount
        );


    function queryBurnFee(uint256 rawAmount)
        external
        view
        returns (
            uint256 poolFee,
            uint256 mtFee,
            uint256 afterChargedAmount
        );

}



interface IDODONFTApprove {

    function isAllowedProxy(address _proxy) external view returns (bool);


    function claimERC721(address nftContract, address who, address dest, uint256 tokenId) external;


    function claimERC1155(address nftContract, address who, address dest, uint256 tokenId, uint256 amount) external;


    function claimERC1155Batch(address nftContract, address who, address dest, uint256[] memory tokenIds, uint256[] memory amounts) external;

}



interface IERC20 {

    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}



library SafeERC20 {

    using SafeMath for uint256;

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

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {



        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



contract DODONFTPoolProxy is InitializableOwnable, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    mapping(uint256 => address) public _FILTER_TEMPLATES_;
    address public _FILTER_ADMIN_TEMPLATE_;
    address public _MAINTAINER_;
    address public _CONTROLLER_;
    address public immutable _CLONE_FACTORY_;
    address public immutable _DODO_NFT_APPROVE_;
    address public immutable _DODO_APPROVE_;

    mapping (address => bool) public isWhiteListed;

    event SetFilterTemplate(uint256 idx, address filterTemplate);
    event Erc721In(address filter, address to, uint256 received);
    event Erc1155In(address filter, address to, uint256 received);

    event CreateLiteNFTPool(address newFilterAdmin, address filterAdminOwner);
    event CreateNFTPool(address newFilterAdmin, address filterAdminOwner, address filter);
    event CreateFilterV1(address newFilterAdmin, address newFilterV1, address nftCollection, uint256 filterTemplateKey);
    event Erc721toErc20(address nftContract, uint256 tokenId, address toToken, uint256 returnAmount);

    event ChangeMaintainer(address newMaintainer);
    event ChangeContoller(address newController);
    event ChangeFilterAdminTemplate(address newFilterAdminTemplate);
    event ChangeWhiteList(address contractAddr, bool isAllowed);

    constructor(
        address cloneFactory,
        address filterAdminTemplate,
        address controllerModel,
        address defaultMaintainer,
        address dodoNftApprove,
        address dodoApprove
    ) public {
        _CLONE_FACTORY_ = cloneFactory;
        _FILTER_ADMIN_TEMPLATE_ = filterAdminTemplate;
        _CONTROLLER_ = controllerModel;
        _MAINTAINER_ = defaultMaintainer;
        _DODO_NFT_APPROVE_ = dodoNftApprove;
        _DODO_APPROVE_ = dodoApprove;
    }

    function erc721In(
        address filter,
        address nftCollection,
        uint256[] memory tokenIds,
        address to,
        uint256 minMintAmount
    ) external {

        for(uint256 i = 0; i < tokenIds.length; i++) {
            require(IFilter(filter).isNFTValid(nftCollection,tokenIds[i]), "NOT_REGISTRIED");
            IDODONFTApprove(_DODO_NFT_APPROVE_).claimERC721(nftCollection, msg.sender, filter, tokenIds[i]);
        }
        uint256 received = IFilter(filter).ERC721In(tokenIds, to);
        require(received >= minMintAmount, "MINT_AMOUNT_NOT_ENOUGH");

        emit Erc721In(filter, to, received);
    }

    function erc1155In(
        address filter,
        address nftCollection,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        address to,
        uint256 minMintAmount
    ) external {

        for(uint256 i = 0; i < tokenIds.length; i++) {
            require(IFilter(filter).isNFTValid(nftCollection,tokenIds[i]), "NOT_REGISTRIED");
        }
        IDODONFTApprove(_DODO_NFT_APPROVE_).claimERC1155Batch(nftCollection, msg.sender, filter, tokenIds, amounts);
        uint256 received = IFilter(filter).ERC1155In(tokenIds, to);
        require(received >= minMintAmount, "MINT_AMOUNT_NOT_ENOUGH");

        emit Erc1155In(filter, to, received);
    }

    function createLiteNFTPool(
        address filterAdminOwner,
        string[] memory infos, // 0 => fragName, 1 => fragSymbol
        uint256[] memory numParams //0 - initSupply, 1 - fee
    ) external returns(address newFilterAdmin) {

        newFilterAdmin = ICloneFactory(_CLONE_FACTORY_).clone(_FILTER_ADMIN_TEMPLATE_);
        
        address[] memory filters = new address[](0);
        
        IFilterAdmin(newFilterAdmin).init(
            filterAdminOwner, 
            numParams[0],
            infos[0],
            infos[1],
            numParams[1],
            _CONTROLLER_,
            _MAINTAINER_,
            filters
        );

        emit CreateLiteNFTPool(newFilterAdmin, filterAdminOwner);
    }



    function createNewNFTPoolV1(
        address filterAdminOwner,
        address nftCollection,
        uint256 filterKey, //1 => FilterERC721V1, 2 => FilterERC1155V1
        string[] memory infos, // 0 => filterName, 1 => fragName, 2 => fragSymbol
        uint256[] memory numParams,//0 - initSupply, 1 - fee
        bool[] memory toggles,
        uint256[] memory filterNumParams, //0 - startId, 1 - endId, 2 - maxAmount, 3 - minAmount
        uint256[] memory priceRules,
        uint256[] memory spreadIds
    ) external returns(address newFilterAdmin) {

        newFilterAdmin = ICloneFactory(_CLONE_FACTORY_).clone(_FILTER_ADMIN_TEMPLATE_);

        address filterV1 = createFilterV1(
            filterKey,
            newFilterAdmin,
            nftCollection,
            toggles,
            infos[0],
            filterNumParams,
            priceRules,
            spreadIds
        );

        address[] memory filters = new address[](1);
        filters[0] = filterV1;
        
        IFilterAdmin(newFilterAdmin).init(
            filterAdminOwner, 
            numParams[0],
            infos[1],
            infos[2],
            numParams[1],
            _CONTROLLER_,
            _MAINTAINER_,
            filters
        );

        emit CreateNFTPool(newFilterAdmin, filterAdminOwner, filterV1);
    }

    function createFilterV1(
        uint256 key,
        address filterAdmin,
        address nftCollection,
        bool[] memory toggles,
        string memory filterName,
        uint256[] memory numParams, //0 - startId, 1 - endId, 2 - maxAmount, 3 - minAmount
        uint256[] memory priceRules,
        uint256[] memory spreadIds
    ) public returns(address newFilterV1) {

        newFilterV1 = ICloneFactory(_CLONE_FACTORY_).clone(_FILTER_TEMPLATES_[key]);

        emit CreateFilterV1(filterAdmin, newFilterV1, nftCollection, key);
        
        IFilter(newFilterV1).init(
            filterAdmin,
            nftCollection,
            toggles,
            filterName,
            numParams,
            priceRules,
            spreadIds
        );
    }


    function erc721ToErc20(
        address filterAdmin,
        address filter,
        address nftContract,
        uint256 tokenId,
        address toToken,
        address dodoProxy,
        bytes memory dodoSwapData
    ) 
        external
        preventReentrant
    {

        IDODONFTApprove(_DODO_NFT_APPROVE_).claimERC721(nftContract, msg.sender, filter, tokenId);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = tokenId;

        uint256 receivedFragAmount = IFilter(filter).ERC721In(tokenIds, address(this));

        _generalApproveMax(filterAdmin, _DODO_APPROVE_, receivedFragAmount);

        require(isWhiteListed[dodoProxy], "Not Whitelist Proxy Contract");
        (bool success, ) = dodoProxy.call(dodoSwapData);
        require(success, "API_SWAP_FAILED");

        uint256 returnAmount = _generalBalanceOf(toToken, address(this));

        _generalTransfer(toToken, msg.sender, returnAmount);

        emit Erc721toErc20(nftContract, tokenId, toToken, returnAmount);
    }
    

    function changeMaintainer(address newMaintainer) external onlyOwner {

        _MAINTAINER_ = newMaintainer;
        emit ChangeMaintainer(newMaintainer);
    }

    function changeFilterAdminTemplate(address newFilterAdminTemplate) external onlyOwner {

        _FILTER_ADMIN_TEMPLATE_ = newFilterAdminTemplate;
        emit ChangeFilterAdminTemplate(newFilterAdminTemplate);
    }

    function changeController(address newController) external onlyOwner {

        _CONTROLLER_ = newController;
        emit ChangeContoller(newController);
    }

    function setFilterTemplate(uint256 idx, address newFilterTemplate) external onlyOwner {

        _FILTER_TEMPLATES_[idx] = newFilterTemplate;
        emit SetFilterTemplate(idx, newFilterTemplate);
    }

    function changeWhiteList(address contractAddr, bool isAllowed) external onlyOwner {

        isWhiteListed[contractAddr] = isAllowed;
        emit ChangeWhiteList(contractAddr, isAllowed);
    }

    function _generalApproveMax(
        address token,
        address to,
        uint256 amount
    ) internal {

        uint256 allowance = IERC20(token).allowance(address(this), to);
        if (allowance < amount) {
            if (allowance > 0) {
                IERC20(token).safeApprove(to, 0);
            }
            IERC20(token).safeApprove(to, uint256(-1));
        }
    }

    function _generalBalanceOf(
        address token, 
        address who
    ) internal view returns (uint256) {

        if (token == _ETH_ADDRESS_) {
            return who.balance;
        } else {
            return IERC20(token).balanceOf(who);
        }
    }

    function _generalTransfer(
        address token,
        address payable to,
        uint256 amount
    ) internal {

        if (amount > 0) {
            if (token == _ETH_ADDRESS_) {
                to.transfer(amount);
            } else {
                IERC20(token).safeTransfer(to, amount);
            }
        }
    }
}