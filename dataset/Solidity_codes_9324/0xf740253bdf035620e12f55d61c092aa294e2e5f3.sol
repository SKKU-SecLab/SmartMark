


pragma solidity 0.6.9;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



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

}



interface IERC1155 is IERC165 {

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

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



contract DODONFTApprove is InitializableOwnable {

    
    uint256 private constant _TIMELOCK_DURATION_ = 3 days;
    mapping (address => bool) public _IS_ALLOWED_PROXY_;
    uint256 public _TIMELOCK_;
    address public _PENDING_ADD_DODO_PROXY_;

    event AddDODOProxy(address dodoProxy);
    event RemoveDODOProxy(address oldProxy);

    modifier notLocked() {

        require(
            _TIMELOCK_ <= block.timestamp,
            "AddProxy is timelocked"
        );
        _;
    }

    function init(address owner, address[] memory proxies) external {

        initOwner(owner);
        for(uint i = 0; i < proxies.length; i++) 
            _IS_ALLOWED_PROXY_[proxies[i]] = true;
    }

    function unlockAddProxy(address newDodoProxy) external onlyOwner {

        _TIMELOCK_ = block.timestamp + _TIMELOCK_DURATION_;
        _PENDING_ADD_DODO_PROXY_ = newDodoProxy;
    }

    function lockAddProxy() public onlyOwner {

       _PENDING_ADD_DODO_PROXY_ = address(0);
       _TIMELOCK_ = 0;
    }


    function addDODOProxy() external onlyOwner notLocked() {

        _IS_ALLOWED_PROXY_[_PENDING_ADD_DODO_PROXY_] = true;
        lockAddProxy();
        emit AddDODOProxy(_PENDING_ADD_DODO_PROXY_);
    }

    function removeDODOProxy (address oldDodoProxy) external onlyOwner {
        _IS_ALLOWED_PROXY_[oldDodoProxy] = false;
        emit RemoveDODOProxy(oldDodoProxy);
    }


    function claimERC721(
        address nftContract,
        address who,
        address dest,
        uint256 tokenId
    ) external {

        require(_IS_ALLOWED_PROXY_[msg.sender], "DODONFTApprove:Access restricted");
        IERC721(nftContract).safeTransferFrom(who, dest, tokenId);
    }

    function claimERC1155(
        address nftContract,
        address who,
        address dest,
        uint256 tokenId,
        uint256 amount
    ) external {

        require(_IS_ALLOWED_PROXY_[msg.sender], "DODONFTApprove:Access restricted");
        IERC1155(nftContract).safeTransferFrom(who, dest, tokenId, amount, "");
    } 

    function claimERC1155Batch(
        address nftContract,
        address who,
        address dest,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) external {

        require(_IS_ALLOWED_PROXY_[msg.sender], "DODONFTApprove:Access restricted");
        IERC1155(nftContract).safeBatchTransferFrom(who, dest, tokenIds, amounts, "");
    } 

    function isAllowedProxy(address _proxy) external view returns (bool) {

        return _IS_ALLOWED_PROXY_[_proxy];
    }
}