
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IMosaicNFT {

    function getOriginalNftInfo(uint256 nftId)
        external
        view
        returns (
            address,
            uint256,
            uint256
        );


    function getNftId(
        address originalNftAddress,
        uint256 originalNetworkID,
        uint256 originalNftId
    ) external view returns (uint256);


    function mintNFT(
        address _to,
        string memory _tokenURI,
        address originalNftAddress,
        uint256 originalNetworkId,
        uint256 originalNftId
    ) external returns (uint256);


    function preMintNFT() external returns (uint256);


    function getLatestId() external view returns (uint256);


    function setNFTMetadata(
        uint256 nftId,
        string memory nftUri,
        address originalNftAddress,
        uint256 originalNetworkID,
        uint256 originalNftId
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface ISummonerConfig {

    function getTransferLockupTime() external view returns (uint256);


    function getFeeTokenAmount(uint256 remoteNetworkId, address feeToken)
        external
        view
        returns (uint256);


    function getPausedNetwork(uint256 networkId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;



contract Summoner is
    IERC721ReceiverUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{

    struct Fee {
        address tokenAddress;
        uint256 amount;
    }

    struct TransferTemporaryData {
        string sourceUri;
        uint256 originalNetworkId;
        uint256 originalNftId;
        bytes32 id;
        bool isRelease;
        address originalNftAddress;
    }

    ISummonerConfig public config;
    address public mosaicNftAddress;
    address public relayer;

    uint256 private nonce;

    uint256[] private preMints;

    mapping(address => uint256) public lastTransfer;
    mapping(bytes32 => bool) public hasBeenSummoned; //hasBeenWithdrawn
    mapping(bytes32 => bool) public hasBeenReleased; //hasBeenUnlocked
    bytes32 public lastSummonedID; //lastWithdrawnID
    bytes32 public lastReleasedID; //lastUnlockedID

    mapping(bytes32 => Fee) private feeCollection;

    event TransferInitiated(
        address indexed sourceNftOwner,
        address indexed sourceNftAddress,
        uint256 indexed sourceNFTId,
        string sourceUri,
        address destinationAddress,
        uint256 destinationNetworkID,
        address originalNftAddress,
        uint256 originalNetworkID,
        uint256 originalNftId,
        uint256 transferDelay,
        bool isRelease,
        bytes32 id
    );

    event SealReleased(
        address indexed nftOwner,
        address indexed nftContract,
        uint256 indexed nftId,
        bytes32 id
    );

    event SummonCompleted(
        address indexed nftOwner,
        address indexed destinationNftContract,
        string nftUri,
        uint256 mosaicNFTId,
        bytes32 id
    );

    event FeeTaken(
        address indexed owner,
        address indexed nftAddress,
        uint256 indexed nftId,
        bytes32 id,
        uint256 remoteNetworkId,
        address feeToken,
        uint256 feeAmount
    );

    event FeeRefunded(
        address indexed owner,
        address indexed nftAddress,
        uint256 indexed nftId,
        bytes32 id,
        address feeToken,
        uint256 feeAmount
    );
    event ValueChanged(address indexed owner, address oldConfig, address newConfig, string valType);

    function initialize(address _config) public initializer {

        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();

        nonce = 0;
        config = ISummonerConfig(_config);
    }

    function setConfig(address _config) external onlyOwner {

        emit ValueChanged(msg.sender, address(config), _config, "CONFIG");
        config = ISummonerConfig(_config);
    }

    function setMosaicNft(address _mosaicNftAddress) external onlyOwner {

        require(preMints.length == 0, "ALREADY PRE-MINTED");
        require(lastSummonedID == "", "ALREADY SUMMONED");
        require(_mosaicNftAddress != mosaicNftAddress, "SAME ADDRESS");
        emit ValueChanged(msg.sender, mosaicNftAddress, _mosaicNftAddress, "MOSAICNFT");
        mosaicNftAddress = _mosaicNftAddress;
    }

    function setRelayer(address _relayer) external onlyOwner {

        emit ValueChanged(msg.sender, relayer, _relayer, "RELAYER");
        relayer = _relayer;
    }

    function pause() external whenNotPaused onlyOwner {

        _pause();
    }

    function unpause() external whenPaused onlyOwner {

        _unpause();
    }

    function transferERC721ToLayer(
        address _sourceNFTAddress,
        uint256 _sourceNFTId,
        address _destinationAddress,
        uint256 _destinationNetworkID,
        uint256 _transferDelay,
        address _feeToken
    ) external payable nonReentrant {

        require(mosaicNftAddress != address(0), "MOSAIC NFT NOT SET");
        require(_sourceNFTAddress != address(0), "NFT ADDRESS");
        require(_destinationAddress != address(0), "DEST ADDRESS");
        require(paused() == false, "CONTRACT PAUSED");
        require(config.getPausedNetwork(_destinationNetworkID) == false, "NETWORK PAUSED");
        require(
            lastTransfer[msg.sender] + config.getTransferLockupTime() < block.timestamp,
            "TIMESTAMP"
        );
        require(config.getFeeTokenAmount(_destinationNetworkID, _feeToken) > 0, "FEE TOKEN");
        require(_destinationNetworkID != block.chainid, "TRANSFER TO SAME NETWORK");

        IERC721Upgradeable(_sourceNFTAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _sourceNFTId
        );
        lastTransfer[msg.sender] = block.timestamp;

        TransferTemporaryData memory tempData;
        tempData.id = _generateId();
        tempData.sourceUri = IERC721MetadataUpgradeable(_sourceNFTAddress).tokenURI(_sourceNFTId);

        if (_sourceNFTAddress == mosaicNftAddress) {
            (
                tempData.originalNftAddress,
                tempData.originalNetworkId,
                tempData.originalNftId
            ) = IMosaicNFT(mosaicNftAddress).getOriginalNftInfo(_sourceNFTId);
        } else {
            tempData.originalNftAddress = _sourceNFTAddress;
            tempData.originalNetworkId = block.chainid;
            tempData.originalNftId = _sourceNFTId;
        }

        if (
            _destinationNetworkID == tempData.originalNetworkId &&
            mosaicNftAddress == _sourceNFTAddress
        ) {
            tempData.isRelease = true;
        }

        emit TransferInitiated(
            msg.sender,
            _sourceNFTAddress,
            _sourceNFTId,
            tempData.sourceUri,
            _destinationAddress,
            _destinationNetworkID,
            tempData.originalNftAddress,
            tempData.originalNetworkId,
            tempData.originalNftId,
            _transferDelay,
            tempData.isRelease,
            tempData.id
        );

        _takeFees(_sourceNFTAddress, _sourceNFTId, tempData.id, _destinationNetworkID, _feeToken);
    }

    function _takeFees(
        address _nftContract,
        uint256 _nftId,
        bytes32 _id,
        uint256 _remoteNetworkID,
        address _feeToken
    ) private {

        uint256 fee = config.getFeeTokenAmount(_remoteNetworkID, _feeToken);
        if (_feeToken != address(0)) {
            require(IERC20Upgradeable(_feeToken).balanceOf(msg.sender) >= fee, "LOW BAL");
            SafeERC20Upgradeable.safeTransferFrom(
                IERC20Upgradeable(_feeToken),
                msg.sender,
                address(this),
                fee
            );
        } else {
            require(msg.value >= fee, "FEE");
        }
        feeCollection[_id] = Fee(_feeToken, fee);
        emit FeeTaken(msg.sender, _nftContract, _nftId, _id, _remoteNetworkID, _feeToken, fee);
    }

    function releaseSeal(
        address _nftOwner,
        address _nftContract,
        uint256 _nftId,
        bytes32 _id,
        bool _isFailure
    ) public nonReentrant onlyOwnerOrRelayer {

        require(paused() == false, "CONTRACT PAUSED");
        require(hasBeenReleased[_id] == false, "RELEASED");
        require(IERC721Upgradeable(_nftContract).ownerOf(_nftId) == address(this), "NOT LOCKED");

        hasBeenReleased[_id] = true;
        lastReleasedID = _id;

        IERC721Upgradeable(_nftContract).safeTransferFrom(address(this), _nftOwner, _nftId);

        emit SealReleased(_nftOwner, _nftContract, _nftId, _id);

        if (_isFailure == true) {
            _refundFees(_nftOwner, _nftContract, _nftId, _id);
        }
    }

    function _refundFees(
        address _nftOwner,
        address _nftContract,
        uint256 _nftId,
        bytes32 _id
    ) private {

        Fee memory fee = feeCollection[_id];
        if (fee.tokenAddress != address(0)) {
            SafeERC20Upgradeable.safeTransfer(
                IERC20Upgradeable(fee.tokenAddress),
                _nftOwner,
                fee.amount
            );
        } else {
            (bool success, ) = _nftOwner.call{value: fee.amount}("");
            if (success == false) {
                revert("FAILED REFUND");
            }
        }
        emit FeeRefunded(msg.sender, _nftContract, _nftId, _id, fee.tokenAddress, fee.amount);
    }

    function withdrawFees(
        address _feeToken,
        address _withdrawTo,
        uint256 _amount
    ) external nonReentrant onlyOwner {

        if (_feeToken != address(0)) {
            require(IERC20Upgradeable(_feeToken).balanceOf(address(this)) >= _amount, "LOW BAL");
            SafeERC20Upgradeable.safeTransfer(IERC20Upgradeable(_feeToken), _withdrawTo, _amount);
        } else {
            require(address(this).balance >= _amount, "LOW BAL");
            (bool success, ) = _withdrawTo.call{value: _amount}("");
            if (success == false) {
                revert("FAILED");
            }
        }
    }

    function summonNFT(
        string memory _nftUri,
        address _destinationAddress,
        address _originalNftAddress,
        uint256 _originalNetworkID,
        uint256 _originalNftId,
        bytes32 _id
    ) public nonReentrant onlyOwnerOrRelayer {

        require(block.chainid != _originalNetworkID, "SUMMONED ON ORIGINAL NETWORK");
        require(_originalNftAddress != address(0), "ORIGINAL NFT ADDRESS");
        require(paused() == false, "CONTRACT PAUSED");
        require(hasBeenSummoned[_id] == false, "SUMMONED");

        hasBeenSummoned[_id] = true;
        lastSummonedID = _id;

        uint256 mosaicNFTId = IMosaicNFT(mosaicNftAddress).getNftId(
            _originalNftAddress,
            _originalNetworkID,
            _originalNftId
        );

        if (mosaicNFTId == 0) {
            mosaicNFTId = getPreMintedNftId();
            if (mosaicNFTId != 0) {
                IMosaicNFT(mosaicNftAddress).setNFTMetadata(
                    mosaicNFTId,
                    _nftUri,
                    _originalNftAddress,
                    _originalNetworkID,
                    _originalNftId
                );
                IERC721Upgradeable(mosaicNftAddress).safeTransferFrom(
                    address(this),
                    _destinationAddress,
                    mosaicNFTId
                );
            } else {
                mosaicNFTId = IMosaicNFT(mosaicNftAddress).mintNFT(
                    _destinationAddress,
                    _nftUri,
                    _originalNftAddress,
                    _originalNetworkID,
                    _originalNftId
                );
            }
        } else {
            IERC721Upgradeable(mosaicNftAddress).safeTransferFrom(
                address(this),
                _destinationAddress,
                mosaicNFTId
            );
        }

        emit SummonCompleted(_destinationAddress, mosaicNftAddress, _nftUri, mosaicNFTId, _id);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }

    function _generateId() private returns (bytes32) {

        return keccak256(abi.encodePacked(block.number, block.chainid, address(this), nonce++));
    }

    function preMintNFT(uint256 n) external onlyOwnerOrRelayer {

        require(mosaicNftAddress != address(0), "MOSAIC NFT NOT SET");
        for (uint256 i = 0; i < n; i++) {
            uint256 nftId = IMosaicNFT(mosaicNftAddress).preMintNFT();
            preMints.push(nftId);
        }
    }

    function getPreMintedNftId() private returns (uint256) {

        uint256 nftId;
        if (preMints.length > 0) {
            nftId = preMints[preMints.length - 1];
            preMints.pop();
        }
        return nftId;
    }

    function getPreMintedCount() external view returns (uint256) {

        return preMints.length;
    }

    modifier onlyOwnerOrRelayer() {

        require(_msgSender() == owner() || _msgSender() == relayer, "ONLY OWNER OR RELAYER");
        _;
    }
}