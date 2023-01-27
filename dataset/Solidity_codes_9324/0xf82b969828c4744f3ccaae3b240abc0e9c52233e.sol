
pragma solidity 0.6.12;

interface IERC1155TokenCreator {

    function tokenCreator(uint256 _tokenId)
    external
    view
    returns (address payable);

}// MIT

pragma solidity 0.6.12;

interface IMarketplaceSettings {

    function getMarketplaceMaxValue() external view returns (uint256);


    function getMarketplaceMinValue() external view returns (uint256);


    function getMarketplaceFeePercentage() external view returns (uint8);


    function calculateMarketplaceFee(uint256 _amount)
    external
    view
    returns (uint256);


    function getERC1155ContractPrimarySaleFeePercentage()
    external
    view
    returns (uint8);


    function calculatePrimarySaleFee(uint256 _amount)
    external
    view
    returns (uint256);


    function hasTokenSold(uint256 _tokenId)
    external
    view
    returns (bool);


    function markERC1155Token(
        uint256 _tokenId,
        bool _hasSold
    ) external;

}// MIT

pragma solidity 0.6.12;


interface INifter {


    function creatorOfToken(uint256 _tokenId)
    external
    view
    returns (address payable);


    function getServiceFee(uint256 _tokenId)
    external
    view
    returns (uint8);


    function getPriceType(uint256 _tokenId, address _owner)
    external
    view
    returns (uint8);


    function setPrice(uint256 _price, uint256 _tokenId, address _owner) external;


    function setBid(uint256 _bid, address _bidder, uint256 _tokenId, address _owner) external;


    function removeFromSale(uint256 _tokenId, address _owner) external;


    function getTokenIdsLength() external view returns (uint256);


    function getTokenId(uint256 _index) external view returns (uint256);


    function getOwners(uint256 _tokenId)
    external
    view
    returns (address[] memory owners);


    function getIsForSale(uint256 _tokenId, address _owner) external view returns (bool);

}// MIT

pragma solidity 0.6.12;

interface INifterMarketAuction {

    function setSalePrice(
        uint256 _tokenId,
        uint256 _amount,
        address _owner
    ) external;


    function setInitialBidPriceWithRange(
        uint256 _bidAmount,
        uint256 _startTime,
        uint256 _endTime,
        address _owner,
        uint256 _tokenId
    ) external;


    function hasTokenActiveBid(uint256 _tokenId, address _owner) external view returns (bool);


}// MIT

pragma solidity 0.6.12;


interface INifterRoyaltyRegistry is IERC1155TokenCreator {

    function getTokenRoyaltyPercentage(
        uint256 _tokenId
    ) external view returns (uint8);


    function calculateRoyaltyFee(
        uint256 _tokenId,
        uint256 _amount
    ) external view returns (uint256);


    function setPercentageForTokenRoyalty(
        uint256 _tokenId,
        uint8 _percentage
    ) external returns (uint8);

}// MIT
pragma solidity 0.6.12;

interface ISendValueProxy {

    function sendValue(address payable _to) external payable;

}// MI
pragma solidity 0.6.12;


contract SendValueProxy is ISendValueProxy {

    function sendValue(address payable _to) external payable override {

        _to.transfer(msg.value);
    }
}// MIT
pragma solidity 0.6.12;



contract MaybeSendValue {

    SendValueProxy proxy;

    constructor() internal {
        proxy = new SendValueProxy();
    }

    function maybeSendValue(address payable _to, uint256 _value)
    internal
    returns (bool)
    {


        _to.transfer(_value);

        return true;
    }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


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

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


contract Escrow is Ownable {

    using SafeMath for uint256;
    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private _deposits;

    function depositsOf(address payee) public view returns (uint256) {

        return _deposits[payee];
    }

    function deposit(address payee) public payable virtual onlyOwner {

        uint256 amount = msg.value;
        _deposits[payee] = _deposits[payee].add(amount);

        emit Deposited(payee, amount);
    }

    function withdraw(address payable payee) public virtual onlyOwner {

        uint256 payment = _deposits[payee];

        _deposits[payee] = 0;

        payee.sendValue(payment);

        emit Withdrawn(payee, payment);
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;


abstract contract PullPayment {
    Escrow private _escrow;

    constructor () internal {
        _escrow = new Escrow();
    }

    function withdrawPayments(address payable payee) public virtual {
        _escrow.withdraw(payee);
    }

    function payments(address dest) public view returns (uint256) {
        return _escrow.depositsOf(dest);
    }

    function _asyncTransfer(address dest, uint256 amount) internal virtual {
        _escrow.deposit{ value: amount }(dest);
    }
}// MIT

pragma solidity 0.6.12;

contract SendValueOrEscrow is MaybeSendValue, PullPayment {

    event SendValue(address indexed _payee, uint256 amount);

    function sendValueOrEscrow(address payable _to, uint256 _value) internal {

        bool successfulTransfer = MaybeSendValue.maybeSendValue(_to, _value);
        if (!successfulTransfer) {
            _asyncTransfer(_to, _value);
        }
        emit SendValue(_to, _value);
    }
}// MIT

pragma solidity 0.6.12;


contract Payments is SendValueOrEscrow {

    using SafeMath for uint256;
    using SafeMath for uint8;

    function refund(
        uint8 _marketplacePercentage,
        address payable _payee,
        uint256 _amount
    ) internal {

        require(
            _payee != address(0),
            "refund::no payees can be the zero address"
        );

        if (_amount > 0) {
            SendValueOrEscrow.sendValueOrEscrow(
                _payee,
                _amount.add(
                    calcPercentagePayment(_amount, _marketplacePercentage)
                )
            );
        }
    }

    function payout(
        uint256 _amount,
        bool _isPrimarySale,
        uint8 _marketplacePercentage,
        uint8 _royaltyPercentage,
        uint8 _primarySalePercentage,
        address payable _payee,
        address payable _marketplacePayee,
        address payable _royaltyPayee,
        address payable _primarySalePayee
    ) internal {

        require(
            _marketplacePercentage <= 100,
            "payout::marketplace percentage cannot be above 100"
        );
        require(
            _royaltyPercentage.add(_primarySalePercentage) <= 100,
            "payout::percentages cannot go beyond 100"
        );
        require(
            _payee != address(0) &&
            _primarySalePayee != address(0) &&
            _marketplacePayee != address(0) &&
            _royaltyPayee != address(0),
            "payout::no payees can be the zero address"
        );

        uint256[4] memory payments;

        payments[0] = calcPercentagePayment(_amount, _marketplacePercentage);

        payments[1] = calcRoyaltyPayment(
            _isPrimarySale,
            _amount,
            _royaltyPercentage
        );

        payments[2] = calcPrimarySalePayment(
            _isPrimarySale,
            _amount,
            _primarySalePercentage
        );

        payments[3] = _amount.sub(payments[1]).sub(payments[2]);

        if (payments[0] > 0) {
            SendValueOrEscrow.sendValueOrEscrow(_marketplacePayee, payments[0]);
        }

        if (payments[1] > 0) {
            SendValueOrEscrow.sendValueOrEscrow(_royaltyPayee, payments[1]);
        }
        if (payments[2] > 0) {
            SendValueOrEscrow.sendValueOrEscrow(_primarySalePayee, payments[2]);
        }
        if (payments[3] > 0) {
            SendValueOrEscrow.sendValueOrEscrow(_payee, payments[3]);
        }
    }

    function calcRoyaltyPayment(
        bool _isPrimarySale,
        uint256 _amount,
        uint8 _percentage
    ) private pure returns (uint256) {

        if (_isPrimarySale) {
            return 0;
        }
        return calcPercentagePayment(_amount, _percentage);
    }

    function calcPrimarySalePayment(
        bool _isPrimarySale,
        uint256 _amount,
        uint8 _percentage
    ) private pure returns (uint256) {

        if (_isPrimarySale) {
            return calcPercentagePayment(_amount, _percentage);
        }
        return 0;
    }

    function calcPercentagePayment(uint256 _amount, uint8 _percentage)
    internal
    pure
    returns (uint256)
    {

        return _amount.mul(_percentage).div(100);
    }
}// MIT

pragma solidity 0.6.12;


contract NifterMarketAuction is INifterMarketAuction, Ownable, Payments {

    using SafeMath for uint256;


    struct ActiveBid {
        address payable bidder;
        uint8 marketplaceFee;
        uint256 amount;
    }

    struct ActiveBidRange {
        uint256 startTime;
        uint256 endTime;
    }

    struct SalePrice {
        address payable seller;
        uint256 amount;
    }


    IMarketplaceSettings public iMarketplaceSettings;

    INifterRoyaltyRegistry public iERC1155CreatorRoyalty;

    INifter public nifter;
    IERC1155 public erc1155;

    mapping(uint256 => mapping(address => SalePrice)) private salePrice;
    mapping(uint256 => mapping(address => ActiveBid)) private activeBid;
    mapping(uint256 => mapping(address => ActiveBidRange)) private activeBidRange;

    mapping(address => uint256) public bidBalance;
    uint8 public minimumBidIncreasePercentage; // 10 = 10%

    event Sold(
        address indexed _buyer,
        address indexed _seller,
        uint256 _amount,
        uint256 _tokenId
    );

    event SetSalePrice(
        uint256 _amount,
        uint256 _tokenId
    );

    event Bid(
        address indexed _bidder,
        uint256 _amount,
        uint256 _tokenId
    );

    event SetInitialBidPriceWithRange(
        uint256 _bidAmount,
        uint256 _startTime,
        uint256 _endTime,
        address _owner,
        uint256 _tokenId
    );
    event AcceptBid(
        address indexed _bidder,
        address indexed _seller,
        uint256 _amount,
        uint256 _tokenId
    );

    event CancelBid(
        address indexed _bidder,
        uint256 _amount,
        uint256 _tokenId
    );

    constructor(address _iMarketSettings, address _iERC1155CreatorRoyalty, address _nifter)
    public
    {
        require(
            _iMarketSettings != address(0),
            "constructor::Cannot have null address for _iMarketSettings"
        );

        require(
            _iERC1155CreatorRoyalty != address(0),
            "constructor::Cannot have null address for _iERC1155CreatorRoyalty"
        );

        require(
            _nifter != address(0),
            "constructor::Cannot have null address for _nifter"
        );

        iMarketplaceSettings = IMarketplaceSettings(_iMarketSettings);

        iERC1155CreatorRoyalty = INifterRoyaltyRegistry(_iERC1155CreatorRoyalty);

        nifter = INifter(_nifter);
        erc1155 = IERC1155(_nifter);

        minimumBidIncreasePercentage = 10;
    }

    function isOwnerOfTheToken(uint256 _tokenId, address _owner) public view returns (bool) {

        uint256 balance = erc1155.balanceOf(_owner, _tokenId);
        return balance > 0;
    }

    function getSalePrice(uint256 _tokenId, address _owner) external view returns (address payable, uint256){

        SalePrice memory sp = salePrice[_tokenId][_owner];
        return (sp.seller, sp.amount);
    }

    function getActiveBid(uint256 _tokenId, address _owner) external view returns (address payable, uint8, uint256){

        ActiveBid memory ab = activeBid[_tokenId][_owner];
        return (ab.bidder, ab.marketplaceFee, ab.amount);
    }

    function hasTokenActiveBid(uint256 _tokenId, address _owner) external view override returns (bool){

        ActiveBid memory ab = activeBid[_tokenId][_owner];
        if (ab.bidder == _owner || ab.bidder == address(0))
            return false;

        return true;
    }

    function getBidBalance(address _user) external view returns (uint256){

        return bidBalance[_user];
    }

    function getActiveBidRange(uint256 _tokenId, address _owner) external view returns (uint256, uint256){

        ActiveBidRange memory abr = activeBidRange[_tokenId][_owner];
        return (abr.startTime, abr.endTime);
    }

    function withdrawMarketFunds() external onlyOwner {

        uint256 balance = address(this).balance;
        _makePayable(owner()).transfer(balance);
    }

    function setMarketplaceSettings(address _address) public onlyOwner {

        require(
            _address != address(0),
            "setMarketplaceSettings::Cannot have null address for _iMarketSettings"
        );

        iMarketplaceSettings = IMarketplaceSettings(_address);
    }

    function setNifter(address _address) public onlyOwner {

        require(
            _address != address(0),
            "setNifter::Cannot have null address for _INifter"
        );

        nifter = INifter(_address);
        erc1155 = IERC1155(_address);
    }

    function setIERC1155CreatorRoyalty(address _address) public onlyOwner {

        require(
            _address != address(0),
            "setIERC1155CreatorRoyalty::Cannot have null address for _iERC1155CreatorRoyalty"
        );

        iERC1155CreatorRoyalty = INifterRoyaltyRegistry(_address);
    }

    function setMinimumBidIncreasePercentage(uint8 _percentage)
    public
    onlyOwner
    {

        minimumBidIncreasePercentage = _percentage;
    }

    function ownerMustHaveMarketplaceApproved(
        address _owner
    ) internal view {

        require(
            erc1155.isApprovedForAll(_owner, address(this)),
            "owner must have approved contract"
        );
    }

    function senderMustBeTokenOwner(uint256 _tokenId)
    internal
    view
    {

        bool isOwner = isOwnerOfTheToken(_tokenId, msg.sender);

        require(isOwner || msg.sender == address(nifter), 'sender must be the token owner');
    }

    function setSalePrice(
        uint256 _tokenId,
        uint256 _amount,
        address _owner
    ) external override {

        ownerMustHaveMarketplaceApproved(_owner);

        senderMustBeTokenOwner(_tokenId);

        if (_amount == 0) {
            _resetTokenPrice(_tokenId, _owner);
            emit SetSalePrice(_amount, _tokenId);
            return;
        }

        salePrice[_tokenId][_owner] = SalePrice(payable(_owner), _amount);
        nifter.setPrice(_amount, _tokenId, _owner);
        emit SetSalePrice(_amount, _tokenId);
    }

    function restore(address _oldAddress, address _oldNifterAddress, uint256 _startIndex, uint256 _endIndex) external onlyOwner {

        NifterMarketAuction oldContract = NifterMarketAuction(_oldAddress);
        INifter oldNifterContract = INifter(_oldNifterAddress);

        uint256 length = oldNifterContract.getTokenIdsLength();
        require(_startIndex < length, "wrong start index");
        require(_endIndex <= length, "wrong end index");

        for (uint i = _startIndex; i < _endIndex; i++) {
            uint256 tokenId = oldNifterContract.getTokenId(i);

            address[] memory owners = oldNifterContract.getOwners(tokenId);
            for (uint j = 0; j < owners.length; j++) {
                address owner = owners[j];
                (address payable sender, uint256 amount) = oldContract.getSalePrice(tokenId, owner);
                salePrice[tokenId][owner] = SalePrice(sender, amount);

                (address payable bidder, uint8 marketplaceFee, uint256 bidAmount) = oldContract.getActiveBid(tokenId, owner);
                activeBid[tokenId][owner] = ActiveBid(bidder, marketplaceFee, bidAmount);
                uint256 serviceFee = bidAmount.mul(marketplaceFee).div(100);
                bidBalance[bidder] = bidBalance[bidder].add(bidAmount.add(serviceFee));


                (uint256 startTime, uint256 endTime) = oldContract.getActiveBidRange(tokenId, owner);
                activeBidRange[tokenId][owner] = ActiveBidRange(startTime, endTime);
            }
        }
        setMinimumBidIncreasePercentage(oldContract.minimumBidIncreasePercentage());
    }
    function safeBuy(
        uint256 _tokenId,
        uint256 _amount,
        address _owner
    ) external payable {

        require(
            salePrice[_tokenId][_owner].amount == _amount,
            "safeBuy::Purchase amount must equal expected amount"
        );
        buy(_tokenId, _owner);
    }

    function buy(uint256 _tokenId, address _owner) public payable {

        require(nifter.getIsForSale(_tokenId, _owner) == true, "bid::not for sale");
        ownerMustHaveMarketplaceApproved(_owner);

        require(
            _priceSetterStillOwnsTheToken(_tokenId, _owner),
            "buy::Current token owner must be the person to have the latest price."
        );

        uint8 priceType = nifter.getPriceType(_tokenId, _owner);
        require(priceType == 0, "buy is only allowed for fixed sale");

        SalePrice memory sp = salePrice[_tokenId][_owner];

        require(sp.amount > 0, "buy::Tokens priced at 0 are not for sale.");

        require(
            tokenPriceFeeIncluded(_tokenId, _owner) == msg.value,
            "buy::Must purchase the token for the correct price"
        );

        _resetTokenPrice(_tokenId, _owner);

        erc1155.safeTransferFrom(_owner, msg.sender, _tokenId, 1, '');

        if (_addressHasBidOnToken(msg.sender, _tokenId, _owner)) {
            _refundBid(_tokenId, _owner);
        }

        address payable marketOwner = _makePayable(owner());
        Payments.payout(
            sp.amount,
            !iMarketplaceSettings.hasTokenSold(_tokenId),
            nifter.getServiceFee(_tokenId),
            iERC1155CreatorRoyalty.getTokenRoyaltyPercentage(
                _tokenId
            ),
            iMarketplaceSettings.getERC1155ContractPrimarySaleFeePercentage(),
            _makePayable(_owner),
            marketOwner,
            iERC1155CreatorRoyalty.tokenCreator(_tokenId),
            marketOwner
        );

        iMarketplaceSettings.markERC1155Token(_tokenId, true);

        nifter.removeFromSale(_tokenId, _owner);

        emit Sold(msg.sender, _owner, sp.amount, _tokenId);
    }

    function tokenPrice(uint256 _tokenId, address _owner)
    external
    view
    returns (uint256)
    {

        ownerMustHaveMarketplaceApproved(_owner);

        if (_priceSetterStillOwnsTheToken(_tokenId, _owner)) {
            return salePrice[_tokenId][_owner].amount;
        }
        return 0;
    }

    function tokenPriceFeeIncluded(uint256 _tokenId, address _owner)
    public
    view
    returns (uint256)
    {

        ownerMustHaveMarketplaceApproved(_owner);

        if (_priceSetterStillOwnsTheToken(_tokenId, _owner)) {
            return
            salePrice[_tokenId][_owner].amount.add(
                salePrice[_tokenId][_owner].amount.mul(
                    nifter.getServiceFee(_tokenId)
                ).div(100)
            );
        }
        return 0;
    }

    function setInitialBidPriceWithRange(uint256 _bidAmount, uint256 _startTime, uint256 _endTime, address _owner, uint256 _tokenId) external override {

        require(_bidAmount > 0, "setInitialBidPriceWithRange::Cannot bid 0 Wei.");
        senderMustBeTokenOwner(_tokenId);
        activeBid[_tokenId][_owner] = ActiveBid(
            payable(_owner),
            nifter.getServiceFee(_tokenId),
            _bidAmount
        );
        _setBidRange(_startTime, _endTime, _tokenId, _owner);

        emit SetInitialBidPriceWithRange(_bidAmount, _startTime, _endTime, _owner, _tokenId);
    }

    function bid(
        uint256 _newBidAmount,
        uint256 _tokenId,
        address _owner
    ) external payable {

        require(_newBidAmount > 0, "bid::Cannot bid 0 Wei.");

        require(nifter.getIsForSale(_tokenId, _owner) == true, "bid::not for sale");

        uint256 currentBidAmount =
        activeBid[_tokenId][_owner].amount;
        require(
            _newBidAmount > currentBidAmount &&
            _newBidAmount >=
            currentBidAmount.add(
                currentBidAmount.mul(minimumBidIncreasePercentage).div(100)
            ),
            "bid::Must place higher bid than existing bid + minimum percentage."
        );

        uint256 requiredCost =
        _newBidAmount.add(
            _newBidAmount.mul(
                nifter.getServiceFee(_tokenId)
            ).div(100)
        );
        require(
            requiredCost <= msg.value,
            "bid::Must purchase the token for the correct price."
        );

        ActiveBidRange memory range = activeBidRange[_tokenId][_owner];
        uint8 priceType = nifter.getPriceType(_tokenId, _owner);

        require(priceType == 1 || priceType == 2, "bid is not valid for fixed sale");
        if (priceType == 1)
            require(range.startTime < block.timestamp && range.endTime > block.timestamp, "bid::can't place bid'");

        require(_owner != msg.sender, "bid::Bidder cannot be owner.");

        _refundBid(_tokenId, _owner);

        _setBid(_newBidAmount, msg.sender, _tokenId, _owner);
        nifter.setBid(_newBidAmount, msg.sender, _tokenId, _owner);
        emit Bid(msg.sender, _newBidAmount, _tokenId);
    }

    function safeAcceptBid(
        uint256 _tokenId,
        uint256 _amount,
        address _owner
    ) external {

        require(
            activeBid[_tokenId][_owner].amount == _amount,
            "safeAcceptBid::Bid amount must equal expected amount"
        );
        acceptBid(_tokenId, _owner);
    }

    function acceptBid(uint256 _tokenId, address _owner) public {

        senderMustBeTokenOwner(_tokenId);

        ownerMustHaveMarketplaceApproved(_owner);


        require(
            _tokenHasBid(_tokenId, _owner),
            "acceptBid::Cannot accept a bid when there is none."
        );


        ActiveBid memory currentBid =
        activeBid[_tokenId][_owner];

        _resetTokenPrice(_tokenId, _owner);
        _resetBid(_tokenId, _owner);

        erc1155.safeTransferFrom(msg.sender, currentBid.bidder, _tokenId, 1, '');

        address payable marketOwner = _makePayable(owner());
        Payments.payout(
            currentBid.amount,
            !iMarketplaceSettings.hasTokenSold(_tokenId),
            nifter.getServiceFee(_tokenId),
            iERC1155CreatorRoyalty.getTokenRoyaltyPercentage(
                _tokenId
            ),
            iMarketplaceSettings.getERC1155ContractPrimarySaleFeePercentage(),
            msg.sender,
            marketOwner,
            iERC1155CreatorRoyalty.tokenCreator(_tokenId),
            marketOwner
        );

        iMarketplaceSettings.markERC1155Token(_tokenId, true);
        uint256 serviceFee = currentBid.amount.mul(currentBid.marketplaceFee).div(100);
        bidBalance[currentBid.bidder] = bidBalance[currentBid.bidder].sub(currentBid.amount.add(serviceFee));

        nifter.removeFromSale(_tokenId, _owner);
        emit AcceptBid(
            currentBid.bidder,
            msg.sender,
            currentBid.amount,
            _tokenId
        );
    }

    function cancelBid(uint256 _tokenId, address _owner) external {

        require(
            _addressHasBidOnToken(msg.sender, _tokenId, _owner),
            "cancelBid::Cannot cancel a bid if sender hasn't made one."
        );

        _refundBid(_tokenId, _owner);

        emit CancelBid(
            msg.sender,
            activeBid[_tokenId][_owner].amount,
            _tokenId
        );
    }

    function currentBidDetailsOfToken(uint256 _tokenId, address _owner)
    public
    view
    returns (uint256, address)
    {

        return (
        activeBid[_tokenId][_owner].amount,
        activeBid[_tokenId][_owner].bidder
        );
    }

    function _priceSetterStillOwnsTheToken(
        uint256 _tokenId,
        address _owner
    ) internal view returns (bool) {


        return
        _owner ==
        salePrice[_tokenId][_owner].seller;
    }

    function _resetTokenPrice(uint256 _tokenId, address _owner)
    internal
    {

        salePrice[_tokenId][_owner] = SalePrice(address(0), 0);
    }

    function _addressHasBidOnToken(
        address _bidder,
        uint256 _tokenId,
        address _owner)
    internal view returns (bool) {

        return activeBid[_tokenId][_owner].bidder == _bidder;
    }

    function _tokenHasBid(
        uint256 _tokenId,
        address _owner)
    internal
    view
    returns (bool)
    {

        return activeBid[_tokenId][_owner].bidder != address(0);
    }

    function _refundBid(uint256 _tokenId, address _owner) internal {

        ActiveBid memory currentBid =
        activeBid[_tokenId][_owner];
        if (currentBid.bidder == address(0)) {
            return;
        }
        if (bidBalance[currentBid.bidder] > 0 && currentBid.bidder != _owner)
        {
            Payments.refund(
                currentBid.marketplaceFee,
                currentBid.bidder,
                currentBid.amount
            );
            uint256 serviceFee = currentBid.amount.mul(currentBid.marketplaceFee).div(100);

            bidBalance[currentBid.bidder] = bidBalance[currentBid.bidder].sub(currentBid.amount.add(serviceFee));
        }
        _resetBid(_tokenId, _owner);
    }

    function _resetBid(uint256 _tokenId, address _owner) internal {

        activeBid[_tokenId][_owner] = ActiveBid(
            address(0),
            0,
            0
        );
    }

    function _setBid(
        uint256 _amount,
        address payable _bidder,
        uint256 _tokenId,
        address _owner
    ) internal {

        require(_bidder != address(0), "Bidder cannot be 0 address.");

        activeBid[_tokenId][_owner] = ActiveBid(
            _bidder,
            nifter.getServiceFee(_tokenId),
            _amount
        );
        uint256 serviceFee = _amount.mul(nifter.getServiceFee(_tokenId)).div(100);
        bidBalance[_bidder] = bidBalance[_bidder].add(_amount.add(serviceFee));

    }

    function _setBidRange(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _tokenId,
        address _owner
    ) internal {

        activeBidRange[_tokenId][_owner] = ActiveBidRange(_startTime, _endTime);
    }

    function _makePayable(address _address)
    internal
    pure
    returns (address payable)
    {

        return address(uint160(_address));
    }


}