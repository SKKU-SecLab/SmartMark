



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
}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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
}




pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}




pragma solidity ^0.8.0;


abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}




pragma solidity ^0.8.0;



abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}




pragma solidity ^0.8.0;



abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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
}



pragma solidity 0.8.3;


contract VerifySignaturePool01 {


    function getMessageHash(
        address nft,
        uint punkID,
        uint valuation,
        uint expireAtBlock
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(nft, punkID, valuation, expireAtBlock));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    function verify(
        address nft,
        uint punkID,
        uint valuation,
        uint expireAtBlock,
        address _signer,
        bytes memory signature
    ) public pure returns (bool) {

        bytes32 messageHash = getMessageHash(nft,punkID, valuation, expireAtBlock);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        internal
        pure
        returns (address)
    {

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {

        require(sig.length == 65, "invalid signature length");

        assembly {

            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

    }
}


pragma solidity 0.8.3;







contract ERC721LendingPoolETH01 is
    VerifySignaturePool01,
    OwnableUpgradeable,
    IERC721Receiver,
    PausableUpgradeable
{

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public pure override returns (bytes4) {

        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    address public _valuationSigner;

    address public _supportedCollection;


    struct PoolParams {
        uint32 interestBPS1000000XBlock;
        uint32 collateralFactorBPS;
    }

    mapping(uint256 => PoolParams) public durationSeconds_poolParam;


    function initialize(address supportedCollection) public initializer {

        __Ownable_init();
        __Pausable_init();
        _supportedCollection = supportedCollection;
    }

    function setDurationParam(uint256 duration, PoolParams calldata ppm)
        public
        onlyOwner
    {

        durationSeconds_poolParam[duration] = ppm;
    }

    function setValuationSigner(address valuationSigner) public onlyOwner {

        _valuationSigner = valuationSigner;
    }

    function pause() public onlyOwner {

      _pause();
    }

    function unpause() public onlyOwner {

      _unpause();
    }


    struct LoanTerms {
        uint256 loanStartBlock;
        uint256 loanExpireTimestamp;
        uint32 interestBPS1000000XBlock;
        uint32 maxLTVBPS;
        uint256 borrowedWei;
        uint256 returnedWei;
        uint256 accuredInterestWei;
        uint256 repaidInterestWei;
        address borrower;
    }

    mapping(uint256 => LoanTerms) public _loans;
    event LoanInitiated(
        address indexed user,
        address indexed erc721,
        uint256 indexed nftID,
        LoanTerms loan
    );
    event LoanTermsChanged(
        address indexed user,
        address indexed erc721,
        uint256 indexed nftID,
        LoanTerms oldTerms,
        LoanTerms newTerms
    );
    event Liquidation(
        address indexed user,
        address indexed erc721,
        uint256 indexed nftID,
        uint256 liquidated_at,
        address liquidator,
        uint256 reason
    );


    function nftHasLoan(uint256 nftID) internal view returns (bool) {

        return _loans[nftID].borrowedWei > _loans[nftID].returnedWei;
    }

    function outstanding(uint256 nftID) public view returns (uint256) {

        if (_loans[nftID].borrowedWei <= _loans[nftID].returnedWei) return 0;
        uint256 newAccuredInterestWei = ((block.number -
            _loans[nftID].loanStartBlock) *
            (_loans[nftID].borrowedWei - _loans[nftID].returnedWei) *
            _loans[nftID].interestBPS1000000XBlock) / 10000000000;
        return
            (_loans[nftID].borrowedWei - _loans[nftID].returnedWei) +
            (_loans[nftID].accuredInterestWei -
                _loans[nftID].repaidInterestWei) +
            newAccuredInterestWei;
    }

    function isUnHealthyLoan(uint256 nftID)
        public
        view
        returns (bool, uint256)
    {

        require(nftHasLoan(nftID), "nft does not have active loan");
        bool isExpired = block.timestamp > _loans[nftID].loanExpireTimestamp &&
            outstanding(nftID) > 0;
        return (isExpired, 0);
    }


    function borrowETH(
        uint256 valuation,
        uint256 nftID,
        uint256 loanDurationSeconds,
        uint256 expireAtBlock,
        uint256 borrowedWei,
        bytes memory signature
    ) public whenNotPaused {

        require(
            verify(
                _supportedCollection,
                nftID,
                valuation,
                expireAtBlock,
                _valuationSigner,
                signature
            ),
            "SignatureVerifier: fake valuation provided!"
        );
        require(!nftHasLoan(nftID), "NFT already has loan!");
        uint32 maxLTVBPS = durationSeconds_poolParam[loanDurationSeconds]
            .collateralFactorBPS;
        require(maxLTVBPS > 0, "Duration not supported");
        require(
            IERC721(_supportedCollection).ownerOf(nftID) == msg.sender,
            "Stealer!"
        );
        require(block.number < expireAtBlock, "Valuation expired");
        require(
            borrowedWei <= (valuation * maxLTVBPS) / 10_000,
            "Can't borrow more than max LTV"
        );
        require(borrowedWei < address(this).balance, "not enough money");
        
        _loans[nftID] = LoanTerms(
            block.number,
            block.timestamp + loanDurationSeconds,
            durationSeconds_poolParam[loanDurationSeconds].interestBPS1000000XBlock,
            maxLTVBPS,
            borrowedWei,
            0,
            0,
            0,
            msg.sender
        );
        emit LoanInitiated(
            msg.sender,
            _supportedCollection,
            nftID,
            _loans[nftID]
        );
        IERC721(_supportedCollection).transferFrom(
            msg.sender,
            address(this),
            nftID
        );

        (bool success, ) = msg.sender.call{value: borrowedWei}("");
        require(success, "cannot send ether");
    }


    function repayETH(uint256 nftID) public payable whenNotPaused {

        require(nftHasLoan(nftID), "NFT does not have active loan");
        uint256 repayAmount = msg.value;
        LoanTerms memory oldLoanTerms = _loans[nftID];
        if (repayAmount >= outstanding(nftID)) {
            uint256 toBeTransferred = repayAmount - outstanding(nftID);
            repayAmount = outstanding(nftID);
            _loans[nftID].returnedWei = _loans[nftID].borrowedWei;
            IERC721(_supportedCollection).transferFrom(
                address(this),
                _loans[nftID].borrower,
                nftID
            );
            (bool success, ) = msg.sender.call{value: toBeTransferred}("");
            require(success, "cannot send ether");
        } else {
            _loans[nftID].accuredInterestWei +=
                ((block.number - _loans[nftID].loanStartBlock) *
                    (_loans[nftID].borrowedWei - _loans[nftID].returnedWei) *
                    _loans[nftID].interestBPS1000000XBlock) /
                10000000000;
            uint256 outstandingInterest = _loans[nftID].accuredInterestWei -
                _loans[nftID].repaidInterestWei;
            if (repayAmount > outstandingInterest) {
                _loans[nftID].repaidInterestWei = _loans[nftID]
                    .accuredInterestWei;
                _loans[nftID].returnedWei += (repayAmount -
                    outstandingInterest);
            } else {
                _loans[nftID].repaidInterestWei += repayAmount;
            }
            _loans[nftID].loanStartBlock = block.number;
        }
        emit LoanTermsChanged(
            _loans[nftID].borrower,
            _supportedCollection,
            nftID,
            oldLoanTerms,
            _loans[nftID]
        );
    }


    function liquidateLoan(uint256 nftID) public onlyOwner {

        require(nftHasLoan(nftID), "nft does not have active loan");
        (bool unhealthy, uint256 reason) = isUnHealthyLoan(nftID);
        require(unhealthy, "can't liquidate this loan");
        LoanTerms memory oldLoanTerms = _loans[nftID];
        _loans[nftID].returnedWei = _loans[nftID].borrowedWei;
        emit Liquidation(
            _loans[nftID].borrower,
            _supportedCollection,
            nftID,
            block.timestamp,
            msg.sender,
            reason
        );
        IERC721(_supportedCollection).safeTransferFrom(
            address(this),
            owner(),
            nftID
        );
        emit LoanTermsChanged(
            _loans[nftID].borrower,
            _supportedCollection,
            nftID,
            oldLoanTerms,
            _loans[nftID]
        );
    }

    receive() external payable {
    }


    function withdraw(uint256 amount) public onlyOwner {

        (bool success, ) = owner().call{value: amount}("");
        require(success, "cannot send ether");
    }

    function withdrawERC20(address currency, uint256 amount) public onlyOwner {

        IERC20(currency).transfer(owner(), amount);
    }

    function withdrawERC721(address collection, uint256 nftID)
        public
        onlyOwner
    {

        require(
            !(collection == _supportedCollection && nftHasLoan(nftID)),
            "no stealing"
        );
        IERC721(collection).safeTransferFrom(address(this), owner(), nftID);
    }

    function emergencyWithdrawLoanCollateral(uint256 nftID, bytes memory signature, uint8 withdrawToOwner)
        public
        whenPaused onlyOwner
    {

        require(
            nftHasLoan(nftID),
            "could be withdrawn using withdrawERC721"
        );
        require(
            verify(
                _supportedCollection,
                nftID,
                238888 + withdrawToOwner,
                238888 + withdrawToOwner,
                _loans[nftID].borrower,
                signature
            ),
            "SignatureVerifier: fake signature provided!"
        );
        if (withdrawToOwner == 1) {
          IERC721(_supportedCollection).safeTransferFrom(address(this), owner(), nftID);
        } else if (withdrawToOwner == 0) {
          IERC721(_supportedCollection).safeTransferFrom(address(this), _loans[nftID].borrower, nftID);
        }
        
    }
}