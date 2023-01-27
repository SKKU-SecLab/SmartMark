
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

pragma solidity ^0.8.0;


interface IERC2981 is IERC165 {

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

}

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);


    function tokenByIndex(uint256 index) external view returns (uint256);

}

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

}

pragma solidity ^0.8.0;


interface IERC2981Mutable is IERC165, IERC2981 {

    function setDefaultRoyalty(address _receiver, uint96 _feeNumerator) external;

    function deleteDefaultRoyalty() external;

}

interface IBaseWrappedNFT is IERC165, IERC2981Mutable, IERC721Receiver, IERC721, IERC721Metadata {

    event DelegatorChanged(address _delegator);
    event Deposit(address _forUser, uint256[] _tokenIds);
    event Withdraw(address _forUser, uint256[] _wnftTokenIds);

    function nft() external view returns (IERC721Metadata);

    function factory() external view returns (IWrappedNFTFactory);


    function deposit(address _forUser, uint256[] memory _tokenIds) external;

    function withdraw(address _forUser, uint256[] memory _wnftTokenIds) external;


    function exists(uint256 _tokenId) external view returns (bool);

    
    function delegator() external view returns (address);

    function setDelegator(address _delegator) external;

    
    function isEnumerable() external view returns (bool);

}

interface IWrappedNFT is IBaseWrappedNFT {

    function totalSupply() external view returns (uint256);

}

interface IWrappedNFTEnumerable is IWrappedNFT, IERC721Enumerable {

    function totalSupply() external view override(IWrappedNFT, IERC721Enumerable) returns (uint256);

}

interface IWrappedNFTFactory {

    event WrappedNFTDeployed(IERC721Metadata _nft, IWrappedNFT _wnft, bool _isEnumerable);
    event WNFTDelegatorChanged(address _wnftDelegator);

    function wnftDelegator() external view returns (address);


    function deployWrappedNFT(IERC721Metadata _nft, bool _isEnumerable) external returns (IWrappedNFT);

    function wnfts(IERC721Metadata _nft) external view returns (IWrappedNFT);

    function wnftsNumber() external view returns (uint);

}// MIT

pragma solidity ^0.8.0;



interface IHarvestStrategy {

    function canHarvest(uint256 _pid, address _forUser, uint256[] memory _wnfTokenIds) external view returns (bool);

}

interface INFTMasterChef {

    event AddPoolInfo(IERC721Metadata nft, IWrappedNFT wnft, uint256 startBlock, 
                    RewardInfo[] rewards, uint256 depositFee, IERC20 dividendToken, bool withUpdate);
    event SetStartBlock(uint256 pid, uint256 startBlock);
    event UpdatePoolReward(uint256 pid, uint256 rewardIndex, uint256 rewardBlock, uint256 rewardForEachBlock, uint256 rewardPerNFTForEachBlock);
    event SetPoolDepositFee(uint256 pid, uint256 depositFee);
    event SetHarvestStrategy(IHarvestStrategy harvestStrategy);
    event SetPoolDividendToken(uint256 pid, IERC20 dividendToken);

    event AddTokenRewardForPool(uint256 pid, uint256 addTokenPerPool, uint256 addTokenPerBlock, bool withTokenTransfer);
    event AddDividendForPool(uint256 pid, uint256 addDividend);

    event UpdateDevAddress(address payable devAddress);
    event EmergencyStop(address user, address to);
    event ClosePool(uint256 pid, address payable to);

    event Deposit(address indexed user, uint256 indexed pid, uint256[] tokenIds);
    event Withdraw(address indexed user, uint256 indexed pid, uint256[] wnfTokenIds);
    event WithdrawWithoutHarvest(address indexed user, uint256 indexed pid, uint256[] wnfTokenIds);
    event Harvest(address indexed user, uint256 indexed pid, uint256[] wnftTokenIds, 
                    uint256 mining, uint256 dividend);

    struct NFTInfo {
        bool deposited;     // If the NFT is deposited.
        uint256 rewardDebt; // Reward debt.

        uint256 dividendDebt; // Dividend debt.
    }

    struct RewardInfo {
        uint256 rewardBlock;
        uint256 rewardForEachBlock;    //Reward for each block, can only be set one with rewardPerNFTForEachBlock
        uint256 rewardPerNFTForEachBlock;    //Reward for each block for every NFT, can only be set one with rewardForEachBlock
    }

    struct PoolInfo {
        IWrappedNFT wnft;// Address of wnft contract.

        uint256 startBlock; // Reward start block.

        uint256 currentRewardIndex;// the current reward phase index for poolsRewardInfos
        uint256 currentRewardEndBlock;  // the current reward end block.

        uint256 amount;     // How many NFTs the pool has.
        
        uint256 lastRewardBlock;  // Last block number that token distribution occurs.
        uint256 accTokenPerShare; // Accumulated tokens per share, times 1e12.
        
        IERC20 dividendToken;
        uint256 accDividendPerShare;

        uint256 depositFee;// ETH charged when user deposit.
    }
    
    function poolLength() external view returns (uint256);

    function poolRewardLength(uint256 _pid) external view returns (uint256);


    function poolInfos(uint256 _pid) external view returns (PoolInfo memory poolInfo);

    function poolsRewardInfos(uint256 _pid, uint256 _rewardInfoId) external view returns (uint256 _rewardBlock, uint256 _rewardForEachBlock, uint256 _rewardPerNFTForEachBlock);

    function poolNFTInfos(uint256 _pid, uint256 _nftTokenId) external view returns (bool _deposited, uint256 _rewardDebt, uint256 _dividendDebt);


    function getPoolCurrentReward(uint256 _pid) external view returns (RewardInfo memory _rewardInfo, uint256 _currentRewardIndex);

    function getPoolEndBlock(uint256 _pid) external view returns (uint256 _poolEndBlock);

    function isPoolEnd(uint256 _pid) external view returns (bool);


    function pending(uint256 _pid, uint256[] memory _wnftTokenIds) external view returns (uint256 _mining, uint256 _dividend);

    function deposit(uint256 _pid, uint256[] memory _tokenIds) external payable;

    function withdraw(uint256 _pid, uint256[] memory _wnftTokenIds) external;

    function withdrawWithoutHarvest(uint256 _pid, uint256[] memory _wnftTokenIds) external;

    function harvest(uint256 _pid, address _forUser, uint256[] memory _wnftTokenIds) external returns (uint256 _mining, uint256 _dividend);

}

contract NFTUtils { 

    struct UserInfo {
        uint256 mining;
        uint256 dividend;
        uint256 nftQuantity;
        uint256 wnftQuantity;
        bool isNFTApproved;
        bool isWNFTApproved;
    }

    function getNFTMasterChefInfos(INFTMasterChef _nftMasterchef, uint256 _pid, address _owner, uint256 _fromTokenId, uint256 _toTokenId) external view
                returns (INFTMasterChef.PoolInfo memory _poolInfo, INFTMasterChef.RewardInfo memory _rewardInfo, UserInfo memory _userInfo, 
                        uint256 _currentRewardIndex, uint256 _endBlock, IERC721Metadata _nft) {

        require(address(_nftMasterchef) != address(0), "NFTUtils: nftMasterchef can not be zero");
        _poolInfo = _nftMasterchef.poolInfos(_pid);
        (_rewardInfo, _currentRewardIndex)  = _nftMasterchef.getPoolCurrentReward(_pid);
        _endBlock = _nftMasterchef.getPoolEndBlock(_pid);
        _nft = _poolInfo.wnft.nft();
        
        if (_owner != address(0)) {
            uint256[] memory wnftTokenIds = ownedNFTTokens(_poolInfo.wnft, _owner, _fromTokenId, _toTokenId);
            _userInfo = UserInfo({mining: 0, dividend: 0, nftQuantity: 0, wnftQuantity: 0, isNFTApproved: false, isWNFTApproved: false});
            if (wnftTokenIds.length > 0) {
                (_userInfo.mining, _userInfo.dividend) = _nftMasterchef.pending(_pid, wnftTokenIds);
            }
        
            IWrappedNFT wnft = _poolInfo.wnft;
            _userInfo.nftQuantity = wnft.nft().balanceOf(_owner);
            _userInfo.wnftQuantity = wnft.balanceOf(_owner);
            _userInfo.isNFTApproved = wnft.nft().isApprovedForAll(_owner, address(wnft));
            _userInfo.isWNFTApproved = wnft.isApprovedForAll(_owner, address(_nftMasterchef)); 
       }
    }

    function pendingAll(INFTMasterChef _nftMasterchef, address _forUser, uint256[] memory _pids, uint256[][] memory _tokenIdRange) external view returns (uint256 _mining, uint256 _dividend) {

        require(address(_nftMasterchef) != address(0) && _pids.length > 0 && _pids.length == _tokenIdRange.length, "NFTUtils: invalid parameters!");
        for(uint256 index = 0; index < _pids.length; index ++){
            uint256 pid = _pids[index];
            INFTMasterChef.PoolInfo memory poolInfo = _nftMasterchef.poolInfos(pid);
            uint256[] memory wnftTokenIds = ownedNFTTokens(poolInfo.wnft, _forUser, _tokenIdRange[index][0], _tokenIdRange[index][1]);
            if (wnftTokenIds.length > 0) {
                (uint256 mining, uint256 dividend) = _nftMasterchef.pending(pid, wnftTokenIds);
                _mining += mining;
                _dividend += dividend;
            }
        }
    }

    function harvestAll(INFTMasterChef _nftMasterchef, address _forUser, uint256[] memory _pids, uint256[][] memory _tokenIdRange) external {

        require(address(_nftMasterchef) != address(0) && _pids.length > 0 && _pids.length == _tokenIdRange.length, "NFTUtils: invalid parameters!");
        for(uint256 index = 0; index < _pids.length; index ++){
            uint256 pid = _pids[index];
            INFTMasterChef.PoolInfo memory poolInfo = _nftMasterchef.poolInfos(pid);
            uint256[] memory wnftTokenIds = ownedNFTTokens(poolInfo.wnft, _forUser, _tokenIdRange[index][0], _tokenIdRange[index][1]);
            if (wnftTokenIds.length > 0) {
                _nftMasterchef.harvest(pid, _forUser, wnftTokenIds);
            }
        }
    }

    function ownedNFTTokens(IERC721 _nft, address _owner, uint256 _fromTokenId, uint256 _toTokenId) public view returns (uint256[] memory _totalTokenIds) {

        if(address(_nft) == address(0) || _owner == address(0)){
            return _totalTokenIds;
        }
        if (_nft.supportsInterface(type(IERC721Enumerable).interfaceId)) {
            IERC721Enumerable nftEnumerable = IERC721Enumerable(address(_nft));
            _totalTokenIds = ownedNFTEnumerableTokens(nftEnumerable, _owner);
        }else{
            _totalTokenIds = ownedNFTNotEnumerableTokens(_nft, _owner, _fromTokenId, _toTokenId);
        }
    }
    
    function ownedNFTEnumerableTokens(IERC721Enumerable _nftEnumerable, address _owner) public view returns (uint256[] memory _totalTokenIds) {

        if(address(_nftEnumerable) == address(0) || _owner == address(0)){
            return _totalTokenIds;
        }
        uint256 balance = _nftEnumerable.balanceOf(_owner);
        if (balance > 0) {
            _totalTokenIds = new uint256[](balance);
            for (uint256 i = 0; i < balance; i++) {
                uint256 tokenId = _nftEnumerable.tokenOfOwnerByIndex(_owner, i);
                _totalTokenIds[i] = tokenId;
            }
        }
    }

    function ownedNFTNotEnumerableTokens(IERC721 _nft, address _owner, uint256 _fromTokenId, uint256 _toTokenId) public view returns (uint256[] memory _totalTokenIds) {

        if(address(_nft) == address(0) || _owner == address(0)){
            return _totalTokenIds;
        }
        uint256 number;
        for (uint256 tokenId = _fromTokenId; tokenId <= _toTokenId; tokenId ++) {
            if (_tokenIdExists(_nft, tokenId)) {
                address tokenOwner = _nft.ownerOf(tokenId);
                if (tokenOwner == _owner) {
                    number ++;
                }
            }
        }
        if(number > 0){
            _totalTokenIds = new uint256[](number);
            uint256 index;
            for (uint256 tokenId = _fromTokenId; tokenId <= _toTokenId; tokenId ++) {
                if (_tokenIdExists(_nft, tokenId)) {
                    address tokenOwner = _nft.ownerOf(tokenId);
                    if (tokenOwner == _owner) {
                        _totalTokenIds[index] = tokenId;
                        index ++;
                    }
                }
            }
        }
    }

    function _tokenIdExists(IERC721 _nft, uint256 _tokenId) internal view returns (bool){

        if(_nft.supportsInterface(type(IWrappedNFT).interfaceId)){
            IWrappedNFT wnft = IWrappedNFT(address(_nft));
            return wnft.exists(_tokenId);
        }
        return true;
    }

    function supportERC721(IERC721 _nft) external view returns (bool){

        return _nft.supportsInterface(type(IERC721).interfaceId);
    }

    function supportERC721Metadata(IERC721 _nft) external view returns (bool){

        return _nft.supportsInterface(type(IERC721Metadata).interfaceId);
    }

    function supportERC721Enumerable(IERC721 _nft) external view returns (bool){

        return _nft.supportsInterface(type(IERC721Enumerable).interfaceId);
    }

    function supportIWrappedNFT(IERC721 _nft) external view returns (bool){

        return _nft.supportsInterface(type(IWrappedNFT).interfaceId);
    }

    function supportIWrappedNFTEnumerable(IERC721 _nft) external view returns (bool){

        return _nft.supportsInterface(type(IWrappedNFTEnumerable).interfaceId);
    }
}

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
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
