
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

library Strings {

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
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction underflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}
interface EIP20Interface {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256 balance);


    function transfer(address dst, uint256 amount) external returns (bool success);


    function transferFrom(address src, address dst, uint256 amount) external returns (bool success);


    function approve(address spender, uint256 amount) external returns (bool success);


    function allowance(address owner, address spender) external view returns (uint256 remaining);


    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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


interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}
contract CallOption {

  using SafeMath for uint256;
  using Strings for uint256;
  using Address for address;

  struct PremiumInfo {
    address premiumToken;
    uint premiumAmt;
    bool premiumRedeemed;
    uint premiumPlatformFee;
    uint sellerPremium;
  }

  struct UnderlyingInfo {
    address underlyingCurrency;
    uint underlyingAmt;
    bool redeemed;
    bool isCall;
  }

  struct Option {
    uint proposalExpiresAt;
    address seller;
    address buyer;
    
    PremiumInfo premiumInfo;
    
    UnderlyingInfo underlyingInfo;

    address strikeCurrency;
    uint strikeAmt;
  
    bool sellerAccepted;
    bool buyerAccepted;

    uint optionExpiresAt;
    bool cancelled;
    bool executed;
  }

  event UnderlyingDeposited(uint indexed optionUID, address seller, address token, uint amount);  
  event PremiumDeposited(uint indexed optionUID, address buyer, address token, uint amount);  
  event SellerAccepted(uint indexed optionUID, address seller);
  event BuyerAccepted(uint indexed optionUID, address buyer);
  event BuyerCancelled(uint indexed optionUID, address buyer);
  event SellerCancelled(uint indexed optionUID, address seller);
  event BuyerPremiumRefunded(uint indexed optionUID, address buyer);
  event SellerUnderlyingRedeemed(uint indexed optionUID, address seller);
  event SellerRedeemedPremium(uint indexed optionUID, address seller);
  event TransferSeller(uint indexed optionUID, address oldSeller, address newSeller);
  
  event OptionExecuted(uint indexed optionUID);

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  mapping(address => uint[]) public userOptions;
  
  Option[] public options;

  uint public platformFee = 5; // 0.005 
 
  address public feeBeneficiaryAddress;

  mapping(address => uint) public platformFeeBalances;

  mapping (uint256 => address) private _tokenApprovals;

  mapping (address => mapping (address => bool)) private _operatorApprovals;

  string public constant symbol = "OPTION-SWAP";
  string public constant name = "ERC-20 Option (OptionSwap.finance)";

  address public admin;

  constructor() public {
    admin = msg.sender;
  }


  function propose(address seller, address buyer, uint proposalExpiresAt, uint optionExpiresAt, 
                        address premiumToken, uint premiumAmt, 
                        address underlyingCurrency, uint underlyingAmt, 
                        address strikeCurrency, uint strikeAmt, bool isCall) public {

    
    require((seller == msg.sender) || (buyer == msg.sender), "Must be either the seller or buyer");

    require(proposalExpiresAt <= optionExpiresAt, "Option cannot expire before proposal");

    (uint sellerPremium, uint platformFeePremium) = _computePremiumSplit(premiumAmt, EIP20Interface(premiumToken).decimals());
    
    options.push(Option(
      { 
          seller: seller, 
          buyer: buyer, 
          proposalExpiresAt: proposalExpiresAt, 
          premiumInfo: PremiumInfo({ 
            premiumToken: premiumToken, 
            premiumAmt: premiumAmt, 
            premiumRedeemed: false,
            premiumPlatformFee: platformFeePremium,
            sellerPremium: sellerPremium}),
          underlyingInfo: UnderlyingInfo({ 
            underlyingCurrency: underlyingCurrency, 
            underlyingAmt: underlyingAmt, 
            isCall: isCall,
            redeemed: false }),
          strikeCurrency: strikeCurrency,
          strikeAmt: strikeAmt,
          optionExpiresAt: optionExpiresAt,
          cancelled: false,
          executed: false,
          sellerAccepted: false,
          buyerAccepted: false
      }));
    
    if (msg.sender == seller) {
      _acceptSeller(options.length - 1);
    }
    
    if (msg.sender == buyer) {
      _acceptBuyer(options.length - 1);
    }
  }
  
  function _computePremiumSplit(uint premium, uint decimals) public view returns(uint, uint) {

    require(decimals <= 78, "_computePremiumSplit(): too many decimals will overflow"); 
    require(decimals >= 3, "_computePremiumSplit(): too few decimals will underflow"); 
    uint platformFeeDoubleScaled = premium.mul(platformFee * (10 ** (decimals - 3)));
    
    uint platformFeeCollected = platformFeeDoubleScaled.div(10 ** (decimals));

    uint redeemable = premium.sub(platformFeeCollected);
    return (redeemable, platformFeeCollected);
  }

  function redeemPremium(uint optionUID) public {

    Option storage option = options[optionUID];
    
    require(!option.premiumInfo.premiumRedeemed, "redeemPremium(): premium already redeemed");
    
    if(option.cancelled || proposalExpired(optionUID)){
      bool isBuyer = option.buyer == msg.sender; 
      require(isBuyer, "redeemPremium(): only buyer can redeem when proposal expired");
     
      option.premiumInfo.premiumRedeemed = true; 
    
      EIP20Interface token = EIP20Interface(option.premiumInfo.premiumToken);
      bool success = token.transfer(option.buyer, option.premiumInfo.premiumAmt);
      require(success, "redeemPremium(): premium transfer failed"); 
     
      emit BuyerPremiumRefunded(optionUID, msg.sender);
      return;
    }
    
    bool isSeller = option.seller == msg.sender; 
    
    require(isSeller, "redeemPremium(): only option seller can redeem");
    
    require(option.buyerAccepted && option.sellerAccepted, "redeemPremium(): option hasn't been accepted");
    
    option.premiumInfo.premiumRedeemed = true; 
    
    platformFeeBalances[option.premiumInfo.premiumToken] = platformFeeBalances[option.premiumInfo.premiumToken].add(option.premiumInfo.premiumPlatformFee);
    
    EIP20Interface token = EIP20Interface(option.premiumInfo.premiumToken);
    bool success = token.transfer(option.seller, option.premiumInfo.sellerPremium);
    require(success, "redeemPremium(): premium transfer failed"); 
  
    emit SellerRedeemedPremium(optionUID, msg.sender);
  }

  function optionExpired(uint optionUID) public view returns(bool) {

    Option memory option = options[optionUID];
    if (option.optionExpiresAt > now) 
      return false;
    else
      return true;
  }

  function proposalExpired(uint optionUID) public view returns (bool) {

    Option memory option = options[optionUID];
    if (option.sellerAccepted && option.buyerAccepted)
      return false;
    if (option.proposalExpiresAt > now) 
      return false;
    else
      return true;
  }

  function redeemUnderlying(uint optionUID) public {

    Option storage option = options[optionUID];
    
    bool isSeller = option.seller == msg.sender; 
    require(isSeller, "redeemUnderlying(): only seller may redeem");
    
    require(!option.underlyingInfo.redeemed, "redeemUnderlying(): redeemed, nothing remaining to redeem");
    require(!option.executed, "redeemUnderlying(): executed, nothing to redeem");
    require(option.cancelled || optionExpired(optionUID) || proposalExpired(optionUID), "redeemUnderlying(): must be cancelled or expired to redeem");

    option.underlyingInfo.redeemed = true;
   
    emit SellerUnderlyingRedeemed(optionUID, msg.sender);

    EIP20Interface token = EIP20Interface(option.underlyingInfo.underlyingCurrency);
    bool success = token.transfer(option.seller, option.underlyingInfo.underlyingAmt);
    require(success, "redeemUnderlying(): premium transfer failed"); 
  }

  function transferSeller(uint optionUID, address newSeller) public {

    Option storage option = options[optionUID];
    
    bool isSeller = option.seller == msg.sender; 
    require(isSeller, "transferSeller(): must be seller");
    
    option.seller = newSeller; 
    userOptions[newSeller].push(optionUID);
    
    emit TransferSeller(optionUID, msg.sender, newSeller);
  }

  function execute(uint optionUID) public {

    Option storage option = options[optionUID];
    
    bool isBuyer = option.buyer == msg.sender; 
    require(isBuyer, "execute(): Must be option owner");
    
    require(option.buyerAccepted && option.sellerAccepted, "execute(): must be a fully accepted option");
    
    require(!optionExpired(optionUID), "execute(): option expired");
    
    require(!option.executed, "execute(): already executed");

    option.executed = true;
     
    EIP20Interface token = EIP20Interface(option.strikeCurrency);
    bool success = token.transferFrom(option.buyer, address(this), option.strikeAmt);
    require(success, "execute(): strike transfer failed"); 
    
    success = token.transfer(option.seller, option.strikeAmt);
    require(success, "execute(): strike transfer failed"); 
    
    EIP20Interface tokenUnderlying = EIP20Interface(option.underlyingInfo.underlyingCurrency);
    success = tokenUnderlying.transfer(option.buyer, option.underlyingInfo.underlyingAmt);
    
    emit OptionExecuted(optionUID);

    require(success, "execute(): underlying transfer failed"); 
  }

  function accept(uint optionUID) public {

    Option memory option = options[optionUID];
    bool isSeller = option.seller == msg.sender || option.seller == address(0);
    bool isBuyer = option.buyer == msg.sender || option.buyer == address(0);
    require(isSeller || isBuyer, "accept(): Must either buyer or seller");

    if (isBuyer){ 
      _acceptBuyer(optionUID);
    }
    else if (isSeller) {
      _acceptSeller(optionUID);
    }
  }

  function cancel(uint optionUID) public {

    Option memory option = options[optionUID];
    bool isSeller = option.seller == msg.sender; 
    bool isBuyer = option.buyer == msg.sender; 
    require(isSeller || isBuyer, "cancel(): only sellers and buyers can cancel"); 
    
    if (isSeller) {
      _cancelSeller(optionUID);
    }
    else if (isBuyer) {
      _cancelBuyer(optionUID);
    }
  }

  function _cancelSeller(uint optionUID) internal {

    Option memory option = options[optionUID];
    require(option.sellerAccepted, "_cancelSeller(): cannot cancel before accepting");
    require(!option.buyerAccepted, "_cancelSeller(): already accepted");
    require(!option.cancelled, "_cancelSeller(): already cancelled");
    options[optionUID].cancelled = true;
  
    emit SellerCancelled(optionUID, msg.sender);
    
    redeemUnderlying(optionUID);
  }

  function _cancelBuyer(uint optionUID) internal {

    Option memory option = options[optionUID];
    require(option.buyerAccepted, "_cancelBuyer(): cannot cancel before accepting");
    require(!option.sellerAccepted, "_cancelBuyer(): already accepted");
    require(!option.cancelled, "already cancelled");
    
    options[optionUID].cancelled = true;
    
    emit BuyerCancelled(optionUID, msg.sender);
    
    redeemPremium(optionUID);
  }

  function _acceptSeller(uint optionUID) internal {

    Option storage option = options[optionUID];
    require(!option.sellerAccepted, "seller already accepted");
    
    option.sellerAccepted = true;
    
    EIP20Interface token = EIP20Interface(option.underlyingInfo.underlyingCurrency);
    bool success = token.transferFrom(msg.sender, address(this), option.underlyingInfo.underlyingAmt);
    require(success, "_acceptSeller(): Failed to transfer underlying");

    emit UnderlyingDeposited(optionUID, msg.sender, option.underlyingInfo.underlyingCurrency, option.underlyingInfo.underlyingAmt);

    if (option.seller == address(0)) {
      options[optionUID].seller = msg.sender;
    }
    userOptions[msg.sender].push(optionUID);

    if (option.buyerAccepted) {
      redeemPremium(optionUID);
    }

    emit SellerAccepted(optionUID, msg.sender);
  }

  function _acceptBuyer(uint optionUID) internal {

    Option storage option = options[optionUID];
    require(!option.buyerAccepted, "buyer already accepted");
    
    option.buyerAccepted = true;
   
    EIP20Interface token = EIP20Interface(option.premiumInfo.premiumToken);
    bool success = token.transferFrom(msg.sender, address(this), option.premiumInfo.premiumAmt);
    require(success, "Failed to transfer premium");
    
    if (option.buyer == address(0)) {
      options[optionUID].buyer = msg.sender;
    }
      
    userOptions[msg.sender].push(optionUID);
    
    emit PremiumDeposited(optionUID, msg.sender, option.premiumInfo.premiumToken, option.premiumInfo.premiumAmt);
    emit BuyerAccepted(optionUID, msg.sender);
  }
  
  
  function canAccept(uint optionUID) public view returns(bool) {

    Option memory option = options[optionUID];
    return (!option.buyerAccepted || !option.sellerAccepted) && !proposalExpired(optionUID); 
  }

  function canCancel(uint optionUID) public view returns(bool) {

    Option memory option = options[optionUID];
    return (!option.buyerAccepted || !option.sellerAccepted) && !proposalExpired(optionUID); 
  }

  function canExecute(uint optionUID) public view returns(bool) {

    Option memory option = options[optionUID];
    return !option.executed && (option.buyerAccepted && option.sellerAccepted) && !optionExpired(optionUID); 
  }
  
  function canRedeemPremium(uint optionUID) public view returns(bool) {

    Option memory option = options[optionUID];
    return (option.buyerAccepted && option.sellerAccepted) && !option.premiumInfo.premiumRedeemed; 
  }
  
  function canRedeemUnderlying(uint optionUID) public view returns(bool) {

    Option memory option = options[optionUID];
    if (option.cancelled || optionExpired(optionUID) || proposalExpired(optionUID))
      return !option.underlyingInfo.redeemed && !option.executed;
    else
      return false;
  }
  
    function balanceOf(address _owner) external view returns (uint256) {

      uint count = 0;
      for(uint i; i< options.length; i++) {
        if(options[i].seller == _owner || options[i].buyer == _owner) {
          if(options[i].sellerAccepted && options[i].buyerAccepted) {
            count += 1;
          }
        }
      }
      return count;
    }

    function totalSupply() public view returns (uint256) {

      uint count = 0;
      for(uint i; i< options.length; i++) {
        if(options[i].sellerAccepted && options[i].buyerAccepted) {
          count += 1;
        }
      }
      return count;
    }

    function baseTokenURI() public view returns (string memory) {

      return "https://metadata.optionswap.finance/";
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return string(abi.encodePacked(baseTokenURI(), tokenId.toString()));
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {

      Option memory option = options[_tokenId];
      return option.buyer;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {

        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return options[tokenId].buyer != address(0); 
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
  
    function _transfer(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        Option storage option = options[tokenId];
        option.buyer = to;
        userOptions[to].push(tokenId);

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        bytes4 _ERC721_RECEIVED = 0x150b7a02;
        if (to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            msg.sender,
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal {}


 
  function optionsForAccount(address account) public view returns(uint[] memory) {

    if (userOptions[account].length == 0) {
      uint[] memory blank;
      return blank;
    }
    return userOptions[account];
  }
  
  function getOptions() public view returns(Option[] memory) {

    return options;
  }


  
  function __updateFee(uint newPlatformFee) public {

    require(msg.sender == admin, "__updateFee(): must be admin");
    platformFee = newPlatformFee;
  }

  function __redeemPlatformFee(uint amount, address tokenAddress) public {

    require(msg.sender == admin, "__redeemPlatformFee(): must be admin");
    require(platformFeeBalances[tokenAddress] >= amount, "__redeemPlatformFee(): requested redemption too large");

    platformFeeBalances[tokenAddress] = platformFeeBalances[tokenAddress].sub(amount);
    
    EIP20Interface token = EIP20Interface(tokenAddress);
    bool success = token.transfer(msg.sender, amount);
    require(success, "Failed to transfer premium");
  }


}