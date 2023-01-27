
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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
}// MIT
pragma solidity >=0.8.0 <0.9.0;


contract OwnerPausable is Ownable, Pausable {

    function pause() public onlyOwner {

        Pausable._pause();
    }

    function unpause() public onlyOwner {

        Pausable._unpause();
    }
}// MIT

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

}// MIT

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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
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

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT
pragma solidity ^0.8.0;

library Random {

    function gen(uint256 seed, uint256 max) internal view returns (uint256 randomNumber) {

        return (uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    block.coinbase,
                    block.number,
                    block.timestamp,
                    msg.sender,
                    block.difficulty,
                    seed
                )
            )
        ) % max);
    }
}// MIT
pragma solidity ^0.8.0;

interface IMintable {

    function mint(address to, uint256 tokenId) external;

}// MIT

pragma solidity ^0.8.8;


abstract contract OwnerTokenWithdraw is Ownable {
    using SafeERC20 for IERC20;

    function withdraw(address payable _receiver, uint256 _amount) external onlyOwner {
        Address.sendValue(_receiver, _amount);
    }

    function withdrawERC20(
        address _tokenAddress,
        address _receiver,
        uint256 _amount
    ) external onlyOwner {
        IERC20(_tokenAddress).transfer(_receiver, _amount);
    }

    function withdrawERC721(
        address _tokenAddress,
        address _receiver,
        uint256[] memory _tokenIds
    ) external onlyOwner {
        for (uint256 i; i < _tokenIds.length; ++i) {
            IERC721(_tokenAddress).transferFrom(address(this), _receiver, _tokenIds[i]);
        }
    }
}// MIT

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


contract RandomDrops is OwnerPausable, OwnerTokenWithdraw, ReentrancyGuard {

    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;

    struct DropsInfo {
        uint256 startTime;
        uint256 endTime; // 0 means no end time
        uint256 waitingNum; // waiting to mint token ids Num
        uint256 maxDropEachAddress; // max drops each address can get
        uint256 maxGasPrice; // max gas price
        address nftAddress; // IMintable
        bytes32 merkleRoot;
    }

    struct QuoteTokenInfo {
        address finAddress;
        uint256 price;
        uint256 limit; // Maximum purchase quantity
        uint256 maxDropEachTx; // maximum mint each transaction
        uint256 quantity; // count of bought tokens
    }

    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    mapping(uint256 => EnumerableSet.UintSet) private waitingToMintTokenIds;
    mapping(uint256 => DropsInfo) public dropsInfos;
    mapping(uint256 => mapping(address => QuoteTokenInfo)) public quoteTokenInfos;
    mapping(uint256 => mapping(address => uint256)) public addressGetDropsCount;
    event SetDropsInfo(
        uint256 indexed dropNum,
        address indexed nftAddress,
        uint256 startTime,
        uint256 endTime,
        uint256 waitingNum,
        uint256 maxDropEachAddress,
        uint256 maxGasPrice,
        bytes32 merkleRoot
    );
    event SetQuoteTokenInfo(
        uint256 indexed dropNum,
        address quoteToken,
        address finAddresses,
        uint256 price,
        uint256 maxDropEachTx,
        uint256 limit
    );
    event Drop(
        uint256 indexed dropNum,
        address indexed nft,
        address user,
        uint256 tokenId,
        address quoteToken,
        uint256 price,
        address finAddress
    );

    function addWaitingToMintTokenId(uint256 _waitingNum, uint256 _tokenId) public onlyOwner {

        waitingToMintTokenIds[_waitingNum].add(_tokenId);
    }

    function addWaitingToMintTokenIdFromTo(
        uint256 _waitingNum,
        uint256 _fromTokenId,
        uint256 _toTokenId
    ) external onlyOwner {

        for (; _fromTokenId <= _toTokenId; ++_fromTokenId) {
            waitingToMintTokenIds[_waitingNum].add(_fromTokenId);
        }
    }

    function addWaitingToMintTokenIds(uint256 _waitingNum, uint256[] calldata _tokenIds) external onlyOwner {

        for (uint256 i; i < _tokenIds.length; ++i) {
            waitingToMintTokenIds[_waitingNum].add(_tokenIds[i]);
        }
    }

    function removeWaitingToMintTokenId(uint256 _waitingNum, uint256 _tokenId) public onlyOwner {

        waitingToMintTokenIds[_waitingNum].remove(_tokenId);
    }

    function removeWaitingToMintTokenIdFromTo(
        uint256 _waitingNum,
        uint256 _fromTokenId,
        uint256 _toTokenId
    ) external onlyOwner {

        for (; _fromTokenId <= _toTokenId; ++_fromTokenId) {
            waitingToMintTokenIds[_waitingNum].remove(_fromTokenId);
        }
    }

    function removeWaitingToMintTokenIds(uint256 _waitingNum, uint256[] calldata _tokenIds) external onlyOwner {

        for (uint256 i; i < _tokenIds.length; ++i) {
            waitingToMintTokenIds[_waitingNum].remove(_tokenIds[i]);
        }
    }

    function getWaitingToMintLength(uint256 _waitingNum) external view returns (uint256) {

        return waitingToMintTokenIds[_waitingNum].length();
    }

    function getWaitingToMintAt(uint256 _waitingNum, uint256 index) external view returns (uint256) {

        return waitingToMintTokenIds[_waitingNum].at(index);
    }

    function getWaitingToMints(uint256 _waitingNum) external view returns (uint256[] memory tokenIds) {

        tokenIds = new uint256[](waitingToMintTokenIds[_waitingNum].length());
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            tokenIds[i] = waitingToMintTokenIds[_waitingNum].at(i);
        }
    }

    function setDropsInfo(
        uint256 _dropNum,
        address _nftAddress,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _waitingNum,
        uint256 _maxDropEachAddress,
        uint256 _maxGasPrice,
        bytes32 _merkleRoot
    ) public onlyOwner {

        dropsInfos[_dropNum] = DropsInfo({
            startTime: _startTime,
            endTime: _endTime,
            waitingNum: _waitingNum,
            maxDropEachAddress: _maxDropEachAddress,
            maxGasPrice: _maxGasPrice,
            nftAddress: _nftAddress,
            merkleRoot: _merkleRoot
        });
        emit SetDropsInfo(
            _dropNum,
            _nftAddress,
            _startTime,
            _endTime,
            _waitingNum,
            _maxDropEachAddress,
            _maxGasPrice,
            _merkleRoot
        );
    }

    function setQuoteTokenInfos(
        uint256 _dropNum,
        address[] memory _quoteTokens,
        address[] memory _finAddresses,
        uint256[] memory _prices,
        uint256[] memory _maxDropEachTxs,
        uint256[] memory _limits
    ) public onlyOwner {

        require(
            _quoteTokens.length == _prices.length &&
                _prices.length == _maxDropEachTxs.length &&
                _maxDropEachTxs.length == _limits.length,
            'length error'
        );
        for (uint256 i; i < _quoteTokens.length; ++i) {
            quoteTokenInfos[_dropNum][_quoteTokens[i]].finAddress = _finAddresses[i];
            quoteTokenInfos[_dropNum][_quoteTokens[i]].price = _prices[i];
            quoteTokenInfos[_dropNum][_quoteTokens[i]].maxDropEachTx = _maxDropEachTxs[i];
            quoteTokenInfos[_dropNum][_quoteTokens[i]].limit = _limits[i];
            emit SetQuoteTokenInfo(
                _dropNum,
                _quoteTokens[i],
                _finAddresses[i],
                _prices[i],
                _maxDropEachTxs[i],
                _limits[i]
            );
        }
    }

    function drop(
        uint256 _dropNum,
        address _quoteToken,
        uint256 _amount,
        bytes32[] calldata _merkleProof
    ) external payable whenNotPaused nonReentrant returns (uint256[] memory tokenIds) {

        require(tx.origin == msg.sender, 'only EOA');
        require(
            block.timestamp >= dropsInfos[_dropNum].startTime && dropsInfos[_dropNum].startTime != 0,
            'not start yet'
        );
        require(dropsInfos[_dropNum].endTime == 0 || block.timestamp <= dropsInfos[_dropNum].endTime, 'ended');
        require(
            (msg.value == 0 && _quoteToken != ETH_ADDRESS) || (_quoteToken == ETH_ADDRESS && msg.value == _amount),
            'value error'
        );
        require(
            dropsInfos[_dropNum].maxGasPrice == 0 || tx.gasprice <= dropsInfos[_dropNum].maxGasPrice,
            'gas price too high!'
        );
        QuoteTokenInfo storage quoteTokenInfo = quoteTokenInfos[_dropNum][_quoteToken];
        require(quoteTokenInfo.price != 0, 'quote token disable');
        require(_amount >= quoteTokenInfo.price, 'amount not enough');
        require(quoteTokenInfo.limit > quoteTokenInfo.quantity, 'quote token limit');
        require(
            dropsInfos[_dropNum].merkleRoot == 0 ||
                MerkleProof.verify(
                    _merkleProof,
                    dropsInfos[_dropNum].merkleRoot,
                    keccak256(abi.encodePacked(_msgSender()))
                ),
            'Invalid proof.'
        );
        uint256 size = Math.min(quoteTokenInfo.limit.sub(quoteTokenInfo.quantity), _amount.div(quoteTokenInfo.price));
        size = Math.min(size, quoteTokenInfo.maxDropEachTx);
        uint256 waitingNum = dropsInfos[_dropNum].waitingNum;
        size = Math.min(size, waitingToMintTokenIds[waitingNum].length());
        size = Math.min(
            size,
            dropsInfos[_dropNum].maxDropEachAddress.sub(addressGetDropsCount[_dropNum][_msgSender()])
        );
        require(size > 0, 'no token to mint');

        _amount = size.mul(quoteTokenInfo.price);

        if (_quoteToken == ETH_ADDRESS) {
            Address.sendValue(payable(quoteTokenInfo.finAddress), _amount);
            if (msg.value > _amount) Address.sendValue(payable(_msgSender()), msg.value - _amount);
        } else {
            IERC20(_quoteToken).safeTransferFrom(_msgSender(), quoteTokenInfo.finAddress, _amount);
        }
        tokenIds = new uint256[](size);
        for (uint256 i; i < size; ++i) {
            tokenIds[i] = waitingToMintTokenIds[waitingNum].at(
                Random.gen(uint256(uint160(_msgSender())).add(i), waitingToMintTokenIds[waitingNum].length())
            );
            require(waitingToMintTokenIds[waitingNum].remove(tokenIds[i]), 'remove error');
            IMintable(dropsInfos[_dropNum].nftAddress).mint(_msgSender(), tokenIds[i]);
            emit Drop(
                _dropNum,
                dropsInfos[_dropNum].nftAddress,
                _msgSender(),
                tokenIds[i],
                _quoteToken,
                quoteTokenInfo.price,
                quoteTokenInfo.finAddress
            );
            addressGetDropsCount[_dropNum][_msgSender()]++;
            quoteTokenInfo.quantity++;
        }
    }

    function getQuoteTokenInfos(uint256 _dropNum, address[] memory _quoteTokens)
        public
        view
        returns (QuoteTokenInfo[] memory infos)
    {

        infos = new QuoteTokenInfo[](_quoteTokens.length);
        for (uint256 i; i < _quoteTokens.length; ++i) {
            infos[i] = quoteTokenInfos[_dropNum][_quoteTokens[i]];
        }
    }
}