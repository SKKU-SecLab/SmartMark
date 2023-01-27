
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


library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {

        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {

        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}// MIT

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




pragma solidity ^0.8.9;


contract NftPaymentSplitter is Context, Ownable {

    using ERC165Checker for address;

    event PayeeAdded(uint256 tokenId, uint256 shares);
    event PaymentReleased(uint256 tokenId, address to, uint256 amount);
    event ERC20PaymentReleased(
        uint256 tokenId,
        IERC20 indexed token,
        address to,
        uint256 amount
    );
    event UnclaimedPaymentReleased(uint256 tokenId, address to, uint256 amount);
    event UnclaimedERC20PaymentReleased(
        uint256 tokenId,
        IERC20 indexed token,
        address to,
        uint256 amount
    );
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;
    uint256 private _maxSupply;
    uint256 private _sharesPerToken;
    uint256 private _totalSharesOffset; //offset for unitialized tokenids
    address public creat00rWallet;
    address public dev1Wallet;
    address public dev2Wallet;

    uint32 private constant _creat00rId = 0;
    uint32 private constant _dev1Id = 334;
    uint32 private constant _dev2Id = 335;


    bytes4 public constant IID_IERC721 = type(IERC721).interfaceId;
    IERC721 public immutable nftCollection;

    mapping(uint256 => uint256) private _shares;
    mapping(uint256 => uint256) private _released;

    mapping(IERC20 => uint256) private _erc20TotalReleased;
    mapping(IERC20 => mapping(uint256 => uint256)) private _erc20Released;

    constructor(
        uint256 maxSupply_,
        uint256 sharesPerToken_,
        uint256[] memory creat00rsShare_,
        address[] memory creat00rWallets_,
        address nftCollection_
    ) payable {
        require(
            nftCollection_ != address(0),
            "ERC721 collection address can't be zero address"
        );
        require(
            nftCollection_.supportsInterface(IID_IERC721),
            "collection address does not support ERC721"
        );
        require(maxSupply_ > 0, "PaymentSplitter: no payees");

        _maxSupply = maxSupply_;
        _sharesPerToken = sharesPerToken_;

        _totalSharesOffset = maxSupply_ * sharesPerToken_;
        nftCollection = IERC721(nftCollection_);

        _setupCreat00rShares(creat00rsShare_, creat00rWallets_);

    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    function totalShares() public view returns (uint256) {

        return _calculateTotalShares();
    }

    function totalReleased() public view returns (uint256) {

        return _totalReleased;
    }

    function _calculateTotalShares() internal view returns (uint256) {

        return _totalShares + _totalSharesOffset;
    }

    function totalReleased(IERC20 token) public view returns (uint256) {

        return _erc20TotalReleased[token];
    }

    function shares(uint256 tokenId) public view returns (uint256) {

        uint256 tokenShares = _shares[tokenId];
        if (tokenShares == 0 && tokenId <= _maxSupply) {
            tokenShares = _sharesPerToken;
        }
        return tokenShares;
    }

    function released(uint256 tokenId) public view returns (uint256) {

        return _released[tokenId];
    }

    function released(IERC20 token, uint256 tokenId)
        public
        view
        returns (uint256)
    {

        return _erc20Released[token][tokenId];
    }

    function release(uint256 tokenId) public virtual {

        require(
            tokenId <= _maxSupply || _isCreat00r(tokenId),
            "PaymentSplitter: tokenId is outside range"
        );
        if (_shares[tokenId] == 0) {
            _addPayee(tokenId, _sharesPerToken);
        }
        require(_shares[tokenId] > 0, "PaymentSplitter: tokenId has no shares");

        address payable account;
        if (_isCreat00r(tokenId)) {
            account = payable(_getCreat00r(tokenId));
        } else {
            account = payable(nftCollection.ownerOf(tokenId));
        }

        uint256 totalReceived = address(this).balance + totalReleased();
        uint256 payment = _pendingPayment(
            tokenId,
            totalReceived,
            released(tokenId)
        );

        require(payment != 0, "PaymentSplitter: tokenId is not due payment");

        _released[tokenId] += payment;
        _totalReleased += payment;

        Address.sendValue(account, payment);
        emit PaymentReleased(tokenId, account, payment);
    }

    function release(IERC20 token, uint256 tokenId) public virtual {

        require(
            tokenId <= _maxSupply || _isCreat00r(tokenId),
            "PaymentSplitter: tokenId is outside range"
        );
        if (_shares[tokenId] == 0) {
            _addPayee(tokenId, _sharesPerToken);
        }
        require(_shares[tokenId] > 0, "PaymentSplitter: tokenId has no shares");

        address account;
        if (_isCreat00r(tokenId)) {
            account = _getCreat00r(tokenId);
        } else {
            account = nftCollection.ownerOf(tokenId);
        }

        uint256 totalReceived = token.balanceOf(address(this)) +
            totalReleased(token);
        uint256 payment = _pendingPayment(
            tokenId,
            totalReceived,
            released(token, tokenId)
        );

        require(payment != 0, "PaymentSplitter: tokenId is not due payment");

        _erc20Released[token][tokenId] += payment;
        _erc20TotalReleased[token] += payment;

        SafeERC20.safeTransfer(token, account, payment);
        emit ERC20PaymentReleased(tokenId, token, account, payment);
    }

    function _pendingPayment(
        uint256 tokenId,
        uint256 totalReceived,
        uint256 alreadyReleased
    ) private view returns (uint256) {

        return
            (totalReceived * _shares[tokenId]) /
            _calculateTotalShares() -
            alreadyReleased;
    }

    function _addPayee(uint256 tokenId, uint256 shares_) private {

        require(
            tokenId <= _maxSupply || _isCreat00r(tokenId),
            "PaymentSplitter: tokenId must be < _maxSupply"
        );
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(
            _shares[tokenId] == 0,
            "PaymentSplitter: tokenId already has shares"
        );

        _shares[tokenId] = shares_;
        _totalShares = _totalShares + shares_;
        if (!_isCreat00r(tokenId) && _totalSharesOffset - shares_ >= 0) {
            _totalSharesOffset = _totalSharesOffset - shares_;
        }
        emit PayeeAdded(tokenId, shares_);
    }

    function _isCreat00r(uint256 tokenId) internal pure returns (bool){

        return (tokenId == _creat00rId || tokenId == _dev1Id || tokenId == _dev2Id);
    }


    function _getCreat00r(uint256 tokenId) internal view returns (address){

        if(tokenId == _creat00rId) {
            return creat00rWallet; 
        }
        if(tokenId == _dev1Id) {
            return dev1Wallet; 
        }
        if(tokenId == _dev2Id) {
            return dev2Wallet; 
        }
        revert("Invalid creat00r tokenId");
    }

    function _setupCreat00rShares(uint256[] memory creat00rsShare_, address[] memory creat00rWallets_) internal {

        require(creat00rsShare_.length == creat00rWallets_.length);
        require(creat00rWallets_.length == 3);
 
        require(creat00rsShare_[0]>creat00rsShare_[1] && creat00rsShare_[0]>creat00rsShare_[2]);

        creat00rWallet = creat00rWallets_[0];
        _addPayee(_creat00rId, creat00rsShare_[0]);
        dev1Wallet = creat00rWallets_[1];
        _addPayee(_dev1Id, creat00rsShare_[1]);
        dev2Wallet = creat00rWallets_[2];
        _addPayee(_dev2Id, creat00rsShare_[2]);
    }

    function setCreat00rAddress(address creat00rWallet_) external onlyOwner {

        require(creat00rWallet_ != address(0), "Zero Address not allowed");
        creat00rWallet = creat00rWallet_;
    }

    function releaseUnlcaimed(uint256[] memory tokenIds) external onlyOwner {

        (bool success, bytes memory result) = address(nftCollection).call(abi.encodeWithSignature("claimExpiration()", msg.sender));
        uint claimExpiration = abi.decode(result, (uint));
        require(success && claimExpiration < block.timestamp, "nftCollection claim window still active");
        uint256 totalPayment = 0;
        bool isValidUnclaimedList = true;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(tokenId <= 100, "Invalid claim id range[1,100]");
            try nftCollection.ownerOf(tokenId) {
                isValidUnclaimedList = false;
            } catch Error(
                string memory /*reason*/
            ) {
                if (_shares[tokenId] == 0) {
                    _addPayee(tokenId, _sharesPerToken);
                }
                require(_shares[tokenId] > 0, "PaymentSplitter: tokenId has no shares");
                uint256 totalReceived = address(this).balance + totalReleased() - totalPayment;
                uint256 payment = _pendingPayment(
                    tokenId,
                    totalReceived,
                    released(tokenId)
                );

                _released[tokenId] += payment;
                _totalReleased += payment;
                totalPayment += payment;
                emit UnclaimedPaymentReleased(
                    tokenId,
                    creat00rWallet,
                    payment
                );
            }
        }
        require(
            totalPayment != 0,
            "PaymentSplitter: tokenId is not due payment"
        );
        require(isValidUnclaimedList, "Invalid list of unclaimed token");
        Address.sendValue(payable(creat00rWallet), totalPayment);
    }


    function releaseUnlcaimed(IERC20 token, uint256[] memory tokenIds)
        external
        onlyOwner
    {   

        (bool success, bytes memory result) = address(nftCollection).call(abi.encodeWithSignature("claimExpiration()", msg.sender));
        uint claimExpiration = abi.decode(result, (uint));
        require(success && claimExpiration < block.timestamp, "nftCollection claim window still active");
        uint256 totalPayment = 0;
        bool isValidUnclaimedList = true;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(tokenId <= 100, "Invalid claim id range[1,100]");
            try nftCollection.ownerOf(tokenId) {
                isValidUnclaimedList = false;
            } catch Error(
                string memory /*reason*/
            ) {
                if (_shares[tokenId] == 0) {
                    _addPayee(tokenId, _sharesPerToken);
                }
                uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token) - totalPayment;
                uint256 payment = _pendingPayment(
                    tokenId,
                    totalReceived,
                    released(token, tokenId)
                );

                _erc20Released[token][tokenId] += payment;
                _erc20TotalReleased[token] += payment;
                totalPayment += payment;
                emit UnclaimedERC20PaymentReleased(
                    tokenId,
                    token,
                    creat00rWallet,
                    payment
                );
            }
        }
        require(
            totalPayment != 0,
            "PaymentSplitter: account is not due payment"
        );
        require(isValidUnclaimedList, "List contains existing tokenIds");
        SafeERC20.safeTransfer(token, creat00rWallet, totalPayment);
    }
}