
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
}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;

interface IAddressRegistry {


    function initialize(
        address lock_manager_,
        address liquidity_,
        address revest_token_,
        address token_vault_,
        address revest_,
        address fnft_,
        address metadata_,
        address admin_,
        address rewards_
    ) external;


    function getAdmin() external view returns (address);


    function setAdmin(address admin) external;


    function getLockManager() external view returns (address);


    function setLockManager(address manager) external;


    function getTokenVault() external view returns (address);


    function setTokenVault(address vault) external;


    function getRevestFNFT() external view returns (address);


    function setRevestFNFT(address fnft) external;


    function getMetadataHandler() external view returns (address);


    function setMetadataHandler(address metadata) external;


    function getRevest() external view returns (address);


    function setRevest(address revest) external;


    function getDEX(uint index) external view returns (address);


    function setDex(address dex) external;


    function getRevestToken() external view returns (address);


    function setRevestToken(address token) external;


    function getRewardsHandler() external view returns(address);


    function setRewardsHandler(address esc) external;


    function getAddress(bytes32 id) external view returns (address);


    function getLPs() external view returns (address);


    function setLPs(address liquidToken) external;


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;

interface IRevest {

    event FNFTTimeLockMinted(
        address indexed asset,
        address indexed from,
        uint indexed fnftId,
        uint endTime,
        uint[] quantities,
        FNFTConfig fnftConfig
    );

    event FNFTValueLockMinted(
        address indexed asset,
        address indexed from,
        uint indexed fnftId,
        address compareTo,
        address oracleDispatch,
        uint[] quantities,
        FNFTConfig fnftConfig
    );

    event FNFTAddressLockMinted(
        address indexed asset,
        address indexed from,
        uint indexed fnftId,
        address trigger,
        uint[] quantities,
        FNFTConfig fnftConfig
    );

    event FNFTWithdrawn(
        address indexed from,
        uint indexed fnftId,
        uint indexed quantity
    );

    event FNFTSplit(
        address indexed from,
        uint[] indexed newFNFTId,
        uint[] indexed proportions,
        uint quantity
    );

    event FNFTUnlocked(
        address indexed from,
        uint indexed fnftId
    );

    event FNFTMaturityExtended(
        address indexed from,
        uint indexed fnftId,
        uint indexed newExtendedTime
    );

    event FNFTAddionalDeposited(
        address indexed from,
        uint indexed newFNFTId,
        uint indexed quantity,
        uint amount
    );

    struct FNFTConfig {
        address asset; // The token being stored
        address pipeToContract; // Indicates if FNFT will pipe to another contract
        uint depositAmount; // How many tokens
        uint depositMul; // Deposit multiplier
        uint split; // Number of splits remaining
        uint depositStopTime; //
        bool maturityExtension; // Maturity extensions remaining
        bool isMulti; //
        bool nontransferrable; // False by default (transferrable) //
    }

    struct TokenTracker {
        uint lastBalance;
        uint lastMul;
    }

    enum LockType {
        DoesNotExist,
        TimeLock,
        ValueLock,
        AddressLock
    }

    struct LockParam {
        address addressLock;
        uint timeLockExpiry;
        LockType lockType;
        ValueLock valueLock;
    }

    struct Lock {
        address addressLock;
        LockType lockType;
        ValueLock valueLock;
        uint timeLockExpiry;
        uint creationTime;
        bool unlocked;
    }

    struct ValueLock {
        address asset;
        address compareTo;
        address oracle;
        uint unlockValue;
        bool unlockRisingEdge;
    }

    function mintTimeLock(
        uint endTime,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable returns (uint);


    function mintValueLock(
        address primaryAsset,
        address compareTo,
        uint unlockValue,
        bool unlockRisingEdge,
        address oracleDispatch,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable returns (uint);


    function mintAddressLock(
        address trigger,
        bytes memory arguments,
        address[] memory recipients,
        uint[] memory quantities,
        IRevest.FNFTConfig memory fnftConfig
    ) external payable returns (uint);


    function withdrawFNFT(uint tokenUID, uint quantity) external;


    function unlockFNFT(uint tokenUID) external;


    function splitFNFT(
        uint fnftId,
        uint[] memory proportions,
        uint quantity
    ) external returns (uint[] memory newFNFTIds);


    function depositAdditionalToFNFT(
        uint fnftId,
        uint amount,
        uint quantity
    ) external returns (uint);


    function setFlatWeiFee(uint wethFee) external;


    function setERC20Fee(uint erc20) external;


    function getFlatWeiFee() external view returns (uint);


    function getERC20Fee() external view returns (uint);



}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface ITokenVault {


    function createFNFT(
        uint fnftId,
        IRevest.FNFTConfig memory fnftConfig,
        uint quantity,
        address from
    ) external;


    function withdrawToken(
        uint fnftId,
        uint quantity,
        address user
    ) external;


    function depositToken(
        uint fnftId,
        uint amount,
        uint quantity
    ) external;


    function cloneFNFTConfig(IRevest.FNFTConfig memory old) external returns (IRevest.FNFTConfig memory);


    function mapFNFTToToken(
        uint fnftId,
        IRevest.FNFTConfig memory fnftConfig
    ) external;


    function handleMultipleDeposits(
        uint fnftId,
        uint newFNFTId,
        uint amount
    ) external;


    function splitFNFT(
        uint fnftId,
        uint[] memory newFNFTIds,
        uint[] memory proportions,
        uint quantity
    ) external;


    function getFNFT(uint fnftId) external view returns (IRevest.FNFTConfig memory);

    function getFNFTCurrentValue(uint fnftId) external view returns (uint);

    function getNontransferable(uint fnftId) external view returns (bool);

    function getSplitsRemaining(uint fnftId) external view returns (uint);

}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface ILockManager {


    function createLock(uint fnftId, IRevest.LockParam memory lock) external returns (uint);


    function getLock(uint lockId) external view returns (IRevest.Lock memory);


    function fnftIdToLockId(uint fnftId) external view returns (uint);


    function fnftIdToLock(uint fnftId) external view returns (IRevest.Lock memory);


    function pointFNFTToLock(uint fnftId, uint lockId) external;


    function lockTypes(uint tokenId) external view returns (IRevest.LockType);


    function unlockFNFT(uint fnftId, address sender) external returns (bool);


    function getLockMaturity(uint fnftId) external view returns (bool);

}// GNU-GPL v3.0 or later

pragma solidity ^0.8.0;


interface IRegistryProvider {

    function setAddressRegistry(address revest) external;


    function getAddressRegistry() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;



interface IOutputReceiver is IRegistryProvider, IERC165 {


    function receiveRevestOutput(
        uint fnftId,
        address asset,
        address payable owner,
        uint quantity
    ) external;


    function getCustomMetadata(uint fnftId) external view returns (string memory);


    function getValue(uint fnftId) external view returns (uint);


    function getAsset(uint fnftId) external view returns (address);


    function getOutputDisplayValues(uint fnftId) external view returns (bytes memory);


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;



interface IOutputReceiverV2 is IOutputReceiver {


    function receiveSecondaryCallback(
        uint fnftId,
        address payable owner,
        uint quantity,
        IRevest.FNFTConfig memory config,
        bytes memory args
    ) external payable;


    function triggerOutputReceiverUpdate(
        uint fnftId,
        bytes memory args
    ) external;


    function handleFNFTRemaps(uint fnftId, uint[] memory newFNFTIds, bool cleanup) external;


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface IFeeReporter {


    function getFlatWeiFee(address asset) external view returns (uint);


    function getERC20Fee(address asset) external view returns (uint);


}// GNU-GPL v3.0 or later

pragma solidity >=0.8.0;


interface IFNFTHandler  {

    function mint(address account, uint id, uint amount, bytes memory data) external;


    function mintBatchRec(address[] memory recipients, uint[] memory quantities, uint id, uint newSupply, bytes memory data) external;


    function mintBatch(address to, uint[] memory ids, uint[] memory amounts, bytes memory data) external;


    function setURI(string memory newuri) external;


    function burn(address account, uint id, uint amount) external;


    function burnBatch(address account, uint[] memory ids, uint[] memory amounts) external;


    function getBalance(address tokenHolder, uint id) external view returns (uint);


    function getSupply(uint fnftId) external view returns (uint);


    function getNextId() external view returns (uint);

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


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
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


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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
}// GNU-GPL v3.0 or later

pragma solidity ^0.8.0;



contract NFTLocker is IOutputReceiverV2, Ownable, ERC165, ERC721Holder, ReentrancyGuard, IFeeReporter {

    using SafeERC20 for IERC20;

    address public addressRegistry;
    string public  metadata;
    uint public constant PRECISION = 10**27;

    string private constant REWARDS_ENDPOINT = "https://lambda.revest.finance/api/getRewardsForNFTLocker/"; 
    string private constant ARGUMENTS_FACTORY = "https://lambda.revest.finance/api/getParamsForNFTLocker/"; 

    struct ERC721Data {
        uint[] tokenIds;
        uint index;
        address erc721;
    }

    struct Balance {
        uint curMul;
        uint lastMul;
    }

    event AirdropEvent(address indexed token, address indexed erc721, uint indexed update_index, uint amount);
    event LockedNFTEvent(address indexed erc721, uint indexed tokenId, uint indexed fnftId, uint update_index);
    event ClaimedReward(address indexed token, address indexed erc721, uint indexed fnftId, uint update_index, uint amount);

    uint public updateIndex = 1;

    mapping (uint => ERC721Data) public nfts;

    mapping (address => bytes32) public globalBalances;

    mapping (bytes32 => Balance) public updateEvents;

    mapping (uint => mapping (address => uint)) public localMuls;

    mapping (address => uint) public minTimes;

    mapping (address => bool) public whitelisted;

    uint public MIN_PERIOD = 30 days; //Minimum lock-up of 30 days

    constructor(address _provider, string memory _meta) {
        addressRegistry = _provider;
        metadata = _meta;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {

        return interfaceId == type(IOutputReceiver).interfaceId
            || interfaceId == type(IOutputReceiverV2).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function mintTimeLock(
        uint endTime,
        uint[] memory tokenIds,
        address erc721,
        bool hardLock
    ) external payable returns (uint fnftId) {

        require(( minTimes[erc721] == 0 && endTime - block.timestamp >= MIN_PERIOD) || 
                ( minTimes[erc721] > 0 && endTime - block.timestamp >= minTimes[erc721]), 
                'Must lock for longer than minimum');
        IRevest.FNFTConfig memory fnftConfig;
        fnftConfig.pipeToContract = address(this);
        fnftConfig.nontransferrable = hardLock;


        uint[] memory quantities = new uint[](1);
        quantities[0] = 1;
        address[] memory recipients = new address[](1);
        recipients[0] = msg.sender;

        fnftId = getRevest().mintTimeLock{value:msg.value}(endTime, recipients, quantities, fnftConfig);

        for(uint i = 0; i < tokenIds.length; i++) {
            IERC721(erc721).safeTransferFrom(msg.sender, address(this), tokenIds[i], '');
            emit LockedNFTEvent(erc721, tokenIds[i], fnftId, updateIndex);
        }

        nfts[fnftId] = ERC721Data(tokenIds, updateIndex, erc721);
    }

    function receiveRevestOutput(
        uint fnftId,
        address,
        address payable owner,
        uint
    ) external override  {

        require(_msgSender() == IAddressRegistry(addressRegistry).getTokenVault(), 'E016');
        ERC721Data memory nft = nfts[fnftId];

        for(uint i = 0; i < nft.tokenIds.length; i++) {
            IERC721(nft.erc721).safeTransferFrom(address(this), owner, nft.tokenIds[i]);
        }
        delete nfts[fnftId]; // Remove the mapping entirely, refund some gas
    }

    function handleFNFTRemaps(uint, uint[] memory, bool) external pure override {

        require(false,'Unauthorized Method');
    }

    function receiveSecondaryCallback(
        uint fnftId,
        address payable owner,
        uint quantity,
        IRevest.FNFTConfig memory config,
        bytes memory args
    ) external payable override {}


    function triggerOutputReceiverUpdate(
        uint fnftId,
        bytes memory args
    ) external override {

        (uint[] memory timeIndices, address[] memory tokens) = abi.decode(args, (uint[], address[]));
        claimRewardsBatch(fnftId, timeIndices, tokens);
    }

    function airdropTokens(uint amount, address token, address erc721) external {

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        uint totalAllocPoints = IERC721(erc721).balanceOf(address(this));
        require(totalAllocPoints > 0, 'E076');
        uint newMulComponent = amount * PRECISION / totalAllocPoints;
        uint current = updateEvents[globalBalances[token]].curMul;
        if(current == 0) {
            current = PRECISION;
        }
        Balance memory bal = Balance(current + newMulComponent, current);
        bytes32 key = getBalanceKey(updateIndex, token);
        updateEvents[key] = bal;
        globalBalances[token] = key;
        emit AirdropEvent(token, erc721, updateIndex, amount);
        updateIndex++;
    }

    function claimRewards(
        uint fnftId,
        uint timeIndex,
        address token
    ) external nonReentrant {

        IAddressRegistry reg = IAddressRegistry(addressRegistry);
        require(IFNFTHandler(reg.getRevestFNFT()).getBalance(_msgSender(), fnftId) > 0, 'E064');
        _claimRewards(fnftId, timeIndex, token);
    }

    function claimRewardsBatch(
        uint fnftId,
        uint[] memory timeIndices,
        address[] memory tokens
    ) public nonReentrant {

        require(timeIndices.length == tokens.length, 'E067');
        IAddressRegistry reg = IAddressRegistry(addressRegistry);
        require(IFNFTHandler(reg.getRevestFNFT()).getBalance(_msgSender(), fnftId) > 0, 'E064');
        for(uint i = 0; i < timeIndices.length; i++) {
            _claimRewards(fnftId, timeIndices[i], tokens[i]);
        }
    }

    function _claimRewards(
        uint fnftId,
        uint timeIndex,
        address token
    ) internal {

        uint localMul = localMuls[fnftId][token];
        require(nfts[fnftId].index <= timeIndex || localMul > 0, 'E075');
        Balance memory bal =updateEvents[globalBalances[token]];
        

        if(localMul == 0) {
            localMul = updateEvents[getBalanceKey(timeIndex, token)].lastMul;
            require(localMul != 0, 'E081');
        }
        uint rewards = (bal.curMul - localMul) * nfts[fnftId].tokenIds.length / PRECISION;
        localMuls[fnftId][token] = bal.curMul;
        try IERC20(token).transfer(_msgSender(), rewards) returns (bool success) {
        } catch {}
        emit ClaimedReward(token, nfts[fnftId].erc721, fnftId, updateIndex, rewards);
    }

    function getRewards(
        uint fnftId,
        uint timeIndex,
        address token
    ) external view returns (uint rewards) {
        uint localMul = localMuls[fnftId][token];
        require(nfts[fnftId].index <= timeIndex || localMul > 0, 'E075');
        Balance memory bal =updateEvents[globalBalances[token]];

        if(localMul == 0) {
            localMul = updateEvents[getBalanceKey(timeIndex, token)].lastMul;
            require(localMul != 0, 'E081');
        }
        rewards = (bal.curMul - localMul) * nfts[fnftId].tokenIds.length / PRECISION;
    }
    
    function setMinPeriod(address erc721, uint min) external {
        require(msg.sender == owner() || msg.sender == Ownable(erc721).owner(), 'Must have admin access to change min period');
        minTimes[erc721] = min;
    }
    
    function setGlobalMin(uint minPer) external onlyOwner {
        MIN_PERIOD = minPer;
    }

    function getCustomMetadata(uint) external view override returns (string memory) {
        return metadata;
    }

    function getValue(uint fnftId) external view override returns (uint) {
        return nfts[fnftId].tokenIds.length;
    }

    function getAsset(uint fnftId) external view override returns (address) {
        return nfts[fnftId].erc721;
    }

    function getOutputDisplayValues(uint fnftId) external view override returns (bytes memory) {
        ERC721Data memory nft = nfts[fnftId];
        string memory tokenURI = IERC721Metadata(nft.erc721).tokenURI(nft.tokenIds[0]);
        string memory endpoint = string(abi.encodePacked(REWARDS_ENDPOINT,uint2str(fnftId), '-',uint2str(block.chainid)));
        string memory argumentsGen = string(abi.encodePacked(ARGUMENTS_FACTORY,uint2str(fnftId),'-',uint2str(block.chainid)));

        return abi.encode(tokenURI, endpoint, argumentsGen, nft.tokenIds, nft.erc721, nft.index);
    }

    function setAddressRegistry(address addressRegistry_) external override onlyOwner {
        addressRegistry = addressRegistry_;
    }

    function getAddressRegistry() external view override returns (address) {
        return addressRegistry;
    }

    function getRevest() internal view returns (IRevest) {
        return IRevest(IAddressRegistry(addressRegistry).getRevest());
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function getBalanceKey(uint num, address add) public pure returns (bytes32 hash_) {
        hash_ = keccak256(abi.encode(num, add));
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function setWhitelisted(address asset, bool whitelist) external onlyOwner {
        whitelisted[asset] = whitelist;
    }


    function getFlatWeiFee(address asset) external view override returns (uint fee) {
        if(!whitelisted[asset]) {
            fee = getRevest().getFlatWeiFee();
        }
    }

    function getERC20Fee(address asset) external view override returns (uint fee) {
        if(!whitelisted[asset]) {
            fee = getRevest().getERC20Fee();
        }
    }
}