
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


interface IERC1155Upgradeable is IERC165Upgradeable {

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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}// MIT

pragma solidity ^0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length == 65) {
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
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

interface IManager {

    function treasury() external view returns (address);

    function verifier() external view returns (address);

    function vendor() external view returns (address);

    function acceptedPayments(address _token) external view returns (bool);

}// MIT
pragma solidity ^0.8.0;

interface IArchive {

    function prevSaleIds(uint256 _saleId) external view returns (bool);


    function getCurrentOnSale(uint256 _saleId) external view returns (uint256 _currentAmt);


    function setCurrentOnSale(uint256 _saleId, uint256 _newAmt) external;


    function getLocked(uint256 _saleId) external view returns (bool _locked);


    function setLocked(uint256 _saleId) external;


    function archive(uint256 _saleId) external;

}// MIT
pragma solidity ^0.8.0;


contract Vendor is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    uint256 private constant NFT721 = 721;
    uint256 private constant NFT1155 = 1155;
    uint256 private constant PRIMARY = 7746279;
    uint256 private constant SECONDARY = 732663279;
    uint256 public constant FEE_DENOMINATOR = 10**6;

    IManager public manager;

    IArchive public archive;

    struct SaleInfo {
        address seller;
        address nftContract;
        address paymentToken;
        uint256 saleID;
        uint256 nftType;
        uint256 tokenID;
        uint256 onSaleAmt;
        uint256 amount;
        uint256 unitPrice;
        uint256 saleKind;
    }

    struct FeeInfo {
        address royaltyRecv;
        uint256 fee;
        uint256 royalty;
    }

    event PaymentTx(
        uint256 indexed _saleId,
        address indexed _buyer,
        address indexed _seller,
        address _royaltyRecv,
        uint256 _amount,
        uint256 _fee,
        uint256 _royalty
    );

    event NativeCoinPayment(address indexed _to, uint256 _amount);
    event CancelSale(address indexed _seller, uint256 _saleId);

    constructor(address _manager, address _archive) Ownable() {
        manager = IManager(_manager);
        archive = IArchive(_archive);
    }

    function updateManager(address _newManager) external onlyOwner {

        require(_newManager != address(0), "Set zero address");
        manager = IManager(_newManager);
    }

    function cancelOnSale(uint256 _saleId, bytes calldata _sig) external {

        require(!archive.prevSaleIds(_saleId), "SaleId already recorded");

        address _seller = _msgSender();
        _checkCancelSignature(_saleId, _seller, _sig);
        archive.archive(_saleId);

        emit CancelSale(_seller, _saleId);
    }

    function purchase(SaleInfo calldata _saleInfo, FeeInfo calldata _feeInfo, bytes calldata _sig) external payable nonReentrant {

        require(_saleInfo.nftType == NFT721 || _saleInfo.nftType == NFT1155, "Invalid nft type");
        require(_saleInfo.saleKind == PRIMARY || _saleInfo.saleKind == SECONDARY, "Invalid sale type");

        _checkPurchase(_saleInfo.saleID, _saleInfo.nftType, _saleInfo.onSaleAmt, _saleInfo.unitPrice, _saleInfo.amount, _saleInfo.paymentToken);

        _checkSignature(_saleInfo, _feeInfo, _sig);

        if (_saleInfo.saleKind == PRIMARY) {
            _primaryPayment(_saleInfo.paymentToken, _saleInfo.unitPrice, _saleInfo.amount);

            emit PaymentTx(
                _saleInfo.saleID, _msgSender(), _saleInfo.seller, address(0), _saleInfo.amount, _saleInfo.unitPrice * _saleInfo.amount, 0
            );
        } else {
            (uint256 _chargedFee, uint256 _royaltyFee, uint256 _payToSeller) = _calcPayment(
                _saleInfo.unitPrice, _saleInfo.amount, _feeInfo.fee, _feeInfo.royalty
            );
            _secondaryPayment(
                _saleInfo.paymentToken, _saleInfo.seller, _feeInfo.royaltyRecv, 
                _payToSeller, _royaltyFee, _chargedFee
            );

            emit PaymentTx(
                _saleInfo.saleID, _msgSender(), _saleInfo.seller, _feeInfo.royaltyRecv, _saleInfo.amount, _chargedFee, _royaltyFee
            );
        }

        _transferItem(_saleInfo.nftContract, _saleInfo.nftType, _saleInfo.seller, _saleInfo.tokenID, _saleInfo.amount);
    }

    function _checkCancelSignature(uint256 _saleId, address _seller, bytes calldata _sig) private view {

        bytes32 _data = keccak256(abi.encodePacked(_saleId, _seller));
        _data = ECDSA.toEthSignedMessageHash(_data);
        require(
            ECDSA.recover(_data, _sig) == manager.verifier(),
            "Invalid params or signature"
        );
    }

    function _checkSignature(SaleInfo calldata _saleInfo, FeeInfo calldata _feeInfo, bytes calldata _sig) private view {

        bytes memory packedAddrs = abi.encodePacked(
            _saleInfo.seller, _saleInfo.nftContract, _saleInfo.paymentToken, _feeInfo.royaltyRecv
        );
        bytes memory packedNumbs = abi.encodePacked(
            _saleInfo.saleID, _saleInfo.nftType, _saleInfo.tokenID, _saleInfo.onSaleAmt, _saleInfo.amount, 
            _saleInfo.unitPrice, _saleInfo.saleKind, _feeInfo.fee, _feeInfo.royalty
        );

        bytes32 _txHash = ECDSA.toEthSignedMessageHash(
            keccak256(
                abi.encodePacked(packedAddrs, packedNumbs)
            )
        );
        require(
            ECDSA.recover(_txHash, _sig) == manager.verifier(),
            "Invalid params or signature"
        );
    }

    function _checkPurchase(uint256 _saleId, uint256 _nftType, uint256 _onSaleAmt, uint256 _price, uint256 _amount, address _paymentToken) private {

        require(!archive.prevSaleIds(_saleId), "SaleId already canceled");
        
        require(_amount > 0, "Purchase zero item");
        require(
            _nftType == NFT721 && _onSaleAmt == 1 ||
            _nftType == NFT1155 && _onSaleAmt != 0,
            "Invalid OnSaleAmt"
        );

        uint256 availableOnSale = archive.getCurrentOnSale(_saleId);
        if ( archive.getLocked(_saleId) ) {
            require(availableOnSale >= _amount, "Invalid purchase amount");
        } else {
            archive.setLocked(_saleId);
            availableOnSale = _onSaleAmt;
        }

        archive.setCurrentOnSale(_saleId, availableOnSale - _amount);
        if (_paymentToken == address(0)) {
            require(
                _price * _amount == msg.value,
                "Insufficient payment"
            );
        } else {
            require(manager.acceptedPayments(_paymentToken), "Invalid payment token");
        }
    }

    function _primaryPayment(address _paymentToken, uint256 _price, uint256 _amount) private {

        if (_paymentToken == address(0)) {
            _paymentTransfer(payable(manager.treasury()), _price * _amount);
        } else {
            IERC20(_paymentToken).safeTransferFrom(
                _msgSender(),
                manager.treasury(),
                _price * _amount
            );
        }
    }

    function _secondaryPayment(
        address _paymentToken,
        address _seller,
        address _royaltyRecv,
        uint256 _payToSeller,
        uint256 _royalty,
        uint256 _fee
    ) private {

        if (_paymentToken == address(0)) {
            _paymentTransfer(payable(manager.treasury()), _fee);
            _paymentTransfer(payable(_royaltyRecv), _royalty);
            _paymentTransfer(payable(_seller), _payToSeller);
            
        } else {
            IERC20(_paymentToken).safeTransferFrom(
                _msgSender(),
                manager.treasury(),
                _fee
            );
            IERC20(_paymentToken).safeTransferFrom(
                _msgSender(),
                _royaltyRecv,
                _royalty
            );
            IERC20(_paymentToken).safeTransferFrom(
                _msgSender(),
                _seller,
                _payToSeller
            );
        }
    }

    function _paymentTransfer(address payable _to, uint256 _amount) private {

        (bool sent, ) = _to.call{ value: _amount }("");
        require(sent, "Payment transfer failed");
        emit NativeCoinPayment(_to, _amount);
    }

    function _transferItem(
        address _nftContract,
        uint256 _nftType,
        address _from,
        uint256 _id,
        uint256 _amount
    ) private {

        if (_nftType == NFT721) {
            IERC721Upgradeable(_nftContract).safeTransferFrom(_from, _msgSender(), _id);
        }else {
            IERC1155Upgradeable(_nftContract).safeTransferFrom(
                _from, _msgSender(), _id, _amount, ""
            );
        }
    }

    function _calcPayment(
        uint256 _price,
        uint256 _amount,
        uint256 _feeRate,
        uint256 _royaltyRate
    ) private pure returns (uint256 _fee, uint256 _royalty, uint256 _payToSeller) {

        _fee = (_price * _amount * _feeRate) / FEE_DENOMINATOR;
        _royalty = (_price * _amount * _royaltyRate) / FEE_DENOMINATOR;
        _payToSeller = _price * _amount - _fee - _royalty;
    }
}