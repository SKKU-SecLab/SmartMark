
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
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

library Signature {

  function recoverSigner(bytes32 message, bytes memory sig)
    internal
    pure
    returns (address){

    
    uint8 v;
    bytes32 r;
    bytes32 s;
    (v, r, s) = splitSignature(sig);
    return ecrecover(message, v, r, s);
  }
  
  function splitSignature(bytes memory sig)
    internal
    pure
    returns (uint8, bytes32, bytes32){

    
    require(sig.length == 65, "Invalid Signature");
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
    r := mload(add(sig, 32))
        s := mload(add(sig, 64))
        v := byte(0, mload(add(sig, 96)))
        }
    return (v, r, s);
  }
}// MIT
pragma solidity ^0.8.0;

library Utils {

  using SafeMath for uint256;
    function hashString(string memory domainName)
      internal
      pure
      returns (bytes32) {

      return keccak256(abi.encode(domainName));
    }
    function calculatePercentage(uint256 amount,
                                 uint256 percentagePoints,
                                 uint256 maxPercentagePoints)
      internal
      pure
      returns (uint256){  

      return amount.mul(percentagePoints).div(maxPercentagePoints);
    }

    function percentageCentsMax()
        internal
        pure
        returns (uint256){

        return 10000;
    }

    function calculatePercentageCents(uint256 amount,
                                      uint256 percentagePoints)
        internal
        pure
        returns (uint256){

        return calculatePercentage(amount, percentagePoints, percentageCentsMax());
    }
    
}// MIT

pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
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


contract ERC20Changeable is Context, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string public _name;
    string public _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT 
pragma solidity ^0.8.0;

contract TLD is ERC20Changeable {
  using SafeMath for uint256;
  using Counters for Counters.Counter;
  
  address private _owner;
  uint256 private AVERAGE_LENGTH;
  uint256 private MINT_UNIT = 1;
  uint256 private gasUnitsHistory;
  uint256 private gasPriceHistory;
  uint256 private MINTED_ETH = 0;
  uint256 private MINTED_TLD = 0;
  uint256 private MINTED_CONSTANT = 0;
  uint256 private REIMBURSEMENT_TX_GAS_HISTORY;
  uint256 private DEFAULT_REIMBURSEMENT_TX_GAS = 90000;
  uint256 private BASE_PRICE_MULTIPLIER = 3;
  uint256 private _basePrice;
  
  Counters.Counter private _reservedIds;
  mapping(uint256=>uint256) reservedPrice;
  
  event Skimmed(address destinationAddress, uint256 amount);
  constructor() ERC20Changeable("Domain Name Community Token", ".TLD") {
    _owner = msg.sender;
  }

  function changeSymbol(string memory symbol_) public onlyOwner{
    _symbol = symbol_;
  }
  function changeName(string memory name_) public onlyOwner{
    _name = name_;
  }
  
  function init(uint256 initialGasEstimation, uint256 averageLength, uint256 basePriceMultiplier) public payable onlyOwner returns(uint256){
    if(MINTED_CONSTANT != 0){
      revert("Already initialized");
    }
    AVERAGE_LENGTH = averageLength;
    BASE_PRICE_MULTIPLIER = basePriceMultiplier;
    trackGasReimburses(initialGasEstimation);
    trackGasPrice(tx.gasprice.add(1));
    uint256 toMint = msg.value.mul(unit()).div(basePrice());
    MINTED_ETH = msg.value;
    MINTED_TLD = toMint;
    MINTED_CONSTANT = MINTED_ETH.mul(MINTED_TLD);
    _mint(msg.sender, toMint);
    return toMint;
  }
  function setBasePriceMultiplier(uint256 basePriceMultiplier) public onlyOwner {
    BASE_PRICE_MULTIPLIER = basePriceMultiplier;
  }
  function setAverageLength(uint256 averageLength) public onlyOwner {
      require(averageLength > 1, "Average length must be greater than one.");
      AVERAGE_LENGTH = averageLength;
  }
  function mintedEth() public view returns(uint256){
    return MINTED_ETH;
  }
  function mintedTld() public view returns(uint256){
    return MINTED_TLD;
  }
  function unit() public view returns (uint256) {
    return MINT_UNIT.mul(10 ** decimals());
  }
  function owner() public view virtual returns (address) {
    return _owner;
  }
  function payableOwner() public view virtual returns(address payable){
    return payable(_owner);
  }
  modifier onlyOwner() {
    require(owner() == msg.sender, "Caller is not the owner");
    _;
  }
  function decimals() public view virtual override returns (uint8) {
    return 8;
  }
  function totalAvailableEther() public view returns (uint256) {
    return address(this).balance;
  }
  function basePrice() public view returns (uint256){
    return averageGasUnits().mul(averageGasPrice()).mul(BASE_PRICE_MULTIPLIER);
  }
  function mintPrice(uint256 numberOfTokensToMint) public view returns (uint256){
    if(numberOfTokensToMint >= MINTED_TLD){
        return basePrice()
            .add(uncovered()
                 .div(AVERAGE_LENGTH));
    }
    uint256 computedPrice = MINTED_CONSTANT
        .div( MINTED_TLD
              .sub(numberOfTokensToMint))
        .add(uncovered()
             .div(AVERAGE_LENGTH))
      .add(basePrice());
    if(computedPrice <= MINTED_ETH){
      return uncovered().add(basePrice());
    }
    return computedPrice
      .sub(MINTED_ETH);
  }
  
  function burnPrice(uint256 numberOfTokensToBurn) public view returns (uint256) {
    if(MINTED_CONSTANT == 0){
      return 0;
    }
    if(uncovered() > 0){
        return 0;
    }
    return MINTED_ETH.sub(MINTED_CONSTANT.div( MINTED_TLD.add(numberOfTokensToBurn)));
  }
  function isCovered() public view returns (bool){
    return  MINTED_ETH > 0 && MINTED_ETH <= address(this).balance;
  }
  function uncovered() public view returns (uint256){
    if(isCovered()){
      return 0;
    }
    
    return MINTED_ETH.sub(address(this).balance);
  }
  function overflow() public view returns (uint256){
    if(!isCovered()){
      return 0;
    }
    
    return address(this).balance.sub(MINTED_ETH);
  }
  function transferOwnership(address newOwner) public onlyOwner returns(address){
    require(newOwner != address(0), "New owner is the zero address");
    _owner = newOwner;
    return _owner;
  }
  function mintUpdateMintedStats(uint256 unitsAmount, uint256 ethAmount) internal {
    MINTED_TLD = MINTED_TLD.add(unitsAmount);
    MINTED_ETH = MINTED_ETH.add(ethAmount);
    MINTED_CONSTANT = MINTED_TLD.mul(MINTED_ETH);
  }
  function rprice(uint256 reservedId) public view returns(uint256){
      return reservedPrice[reservedId];
  }
  function reserveMint() public returns (uint256) {
    _reservedIds.increment();

    uint256 reservedId = _reservedIds.current();
    reservedPrice[reservedId] = mintPrice(unit());
    return reservedId;
  }
  function mint(uint256 reservedId) payable public onlyOwner returns (uint256){
    require(msg.value >= reservedPrice[reservedId], "Minimum payment is not met.");
    mintUpdateMintedStats(unit(), basePrice());
    _mint(msg.sender, unit());
    return unit();
  }
  function unitsToBurn(uint256 ethAmount) public view returns (uint256){
    if(MINTED_CONSTANT == 0){
      return totalSupply();
    }
    if(ethAmount > MINTED_ETH){
      return totalSupply();
    }
    return MINTED_CONSTANT.div( MINTED_ETH.sub(ethAmount) ).sub(MINTED_TLD);
  }
  function trackGasReimburses(uint256 gasUnits) internal {
      gasUnitsHistory = gasUnitsHistory.mul(AVERAGE_LENGTH-1).add(gasUnits).div(AVERAGE_LENGTH);
  }
  function trackGasPrice(uint256 gasPrice) internal {
      gasPriceHistory = gasPriceHistory.mul(AVERAGE_LENGTH-1).add(gasPrice).div(AVERAGE_LENGTH);
  }
  function averageGasPrice() public view returns(uint256){
      return gasPriceHistory;
  }
  function averageGasUnits() public view returns(uint256){
    return gasUnitsHistory;
  }
  function reimbursementValue() public view returns(uint256){
    return averageGasUnits().mul(averageGasPrice()).mul(2);
  }
  function burn(uint256 unitsAmount) public returns(uint256){
    require(balanceOf(msg.sender) >= unitsAmount, "Insuficient funds to burn");
    uint256 value = burnPrice(unitsAmount);
    if(value > 0 && value <= address(this).balance){
      _burn(msg.sender, unitsAmount);
      payable(msg.sender).transfer(value);
    }
    return 0;
  }
  function skim(address destination) public onlyOwner returns (uint256){
      uint256 amountToSkim = overflow();
      if(amountToSkim > 0){
          if(payable(destination).send(amountToSkim)){
              emit Skimmed(destination, amountToSkim);
          }
      }
      return amountToSkim;
  }
  function reimburse(uint256 gasUnits, address payable toAddress) public onlyOwner returns (bool){
    uint256 gasStart = gasleft();
    uint256 value = reimbursementValue();
    if(value > MINTED_ETH){
      return false;
    }
    uint256 reimbursementUnits = unitsToBurn(value);

    trackGasPrice(tx.gasprice.add(1));
    if(balanceOf(msg.sender) >= reimbursementUnits && address(this).balance > value){
      _burn(msg.sender, reimbursementUnits);
      payable(toAddress).transfer(value);
    }else{
      mintUpdateMintedStats(0, value);
    }
    trackGasReimburses(gasUnits.add(gasStart.sub(gasleft()))); 
    return false;
  }
  receive() external payable {
      
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

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}// MIT

pragma solidity ^0.8.0;


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
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

library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping (uint256 => address) private _owners;

    mapping (address => uint256) private _balances;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;

library EnumerableSet {

    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
}// MIT

pragma solidity ^0.8.0;


interface IAccessControlEnumerable {
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping (bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}// MIT
pragma solidity ^0.8.0;

contract Settings is AccessControlEnumerable {
    mapping(bytes32=>uint256) uintSetting;
    mapping(bytes32=>address) addressSetting;

    modifier onlyAdmin() {
      require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
              "Must be admin");
      _;
    }
    
    constructor(){
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function isAdmin(address _address) public view returns(bool){
      return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }

    function changeAdmin(address adminAddress)
        public onlyAdmin {     
        require(adminAddress != address(0), "New admin must be a valid address");
        _setupRole(DEFAULT_ADMIN_ROLE, adminAddress);
        revokeRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function registerNamedRole(string memory _name, address _address) public onlyAdmin {
        bytes32 role = toKey(_name);
        require(!hasRole(role, _address), "Address already has role");
        _setupRole(role, _address);
    }
    function unregisterNamedRole(string memory _name, address _address) public onlyAdmin {
      bytes32 role = toKey(_name);
      require(hasRole(role, _address), "Address already has role");
      revokeRole(role, _address);
    }
    
    function hasNamedRole(string memory _name, address _address) public view returns(bool){
      return hasRole(toKey(_name), _address);
    }
    
    function toKey(string memory _name) public pure returns(bytes32){
      return keccak256(abi.encode(_name));
    }
    function ownerSetNamedUint(string memory _name, uint256 _value) public onlyAdmin{
        ownerSetUint(toKey(_name), _value);
    }
    function ownerSetUint(bytes32 _key, uint256 _value) public onlyAdmin {
        uintSetting[_key] = _value;
    }
    function ownerSetAddress(bytes32 _key, address _value) public onlyAdmin {
        addressSetting[_key] = _value;
    }
    function ownerSetNamedAddress(string memory _name, address _value) public onlyAdmin{
        ownerSetAddress(toKey(_name), _value);
    }
    
    function getUint(bytes32 _key) public view returns(uint256){
        return uintSetting[_key];
    }
    
    function getAddress(bytes32 _key) public view returns(address){
        return addressSetting[_key];
    }

    function getNamedUint(string memory _name) public view returns(uint256){
        return getUint(toKey(_name));
    }
    function getNamedAddress(string memory _name) public view returns(address){
        return getAddress(toKey(_name));
    }
    function removeNamedUint(string memory _name) public onlyAdmin {
      delete uintSetting[toKey(_name)];
    }
    function removeNamedAddress(string memory _name) public onlyAdmin {
      delete addressSetting[toKey(_name)];
    }
}// MIT
pragma solidity ^0.8.0;


contract User is Ownable{
  bool public initialized;
  Settings settings;
  struct Account {
        uint256 registered;
        uint256 active;
    }
    mapping (address=>Account) users;
    mapping (address=>address) subaccounts;
    mapping (address=>address[]) userSubaccounts;

    constructor() {
      
    }
    function initialize(Settings _settings) public onlyOwner {
      require(!initialized, "Contract instance has already been initialized");
      initialized = true;
      settings = _settings;
    }
    function setSettingsAddress(Settings _settings) public onlyOwner {
      settings = _settings;
    }
    function isRegistered(address userAddress) public view returns(bool){
        return users[userAddress].registered > 0;
    }
    
    function isSubaccount(address anAddress) public view returns(bool){
        return subaccounts[anAddress] != address(0x0);
    }
    
    function parentUser(address anAddress) public view returns(address){
        if(isSubaccount(anAddress) ){
            return subaccounts[anAddress];
        }
        if(isRegistered(anAddress)){
            return anAddress;
        }
        return address(0x0);
    }
    
    function isActive(address anAddress) public view returns(bool){
        address checkAddress = parentUser(anAddress);
        return (isRegistered(checkAddress) && users[checkAddress].active > 0);
    }
    function register(address registerAddress) public onlyOwner {
        require(!isRegistered(registerAddress),"Address already registered");
        require(!isSubaccount(registerAddress), "Address is a subaccount of another address");
        users[registerAddress] = Account(block.timestamp, 0);
    }
    
    function activateUser(address userAddress) public onlyOwner {
        require(isRegistered(userAddress), "Address is not a registered user");
        users[userAddress].active = block.timestamp;
    }
    function deactivateUser(address userAddress) public onlyOwner {
        require(isRegistered(userAddress), "Address is not a registered user");
        users[userAddress].active = 0;
    }
    
    function addSubaccount(address anAddress) public {
        require(isActive(_msgSender()),"Must be a registered active user");
        require(!isRegistered(anAddress), "Address is already registered");
        require(!isSubaccount(anAddress), "Address is already a subaccount");
        require(settings.getNamedUint("SUBACCOUNTS_ENABLED") > 0, "Subaccounts are not enabled");
        subaccounts[anAddress] = _msgSender();
        userSubaccounts[_msgSender()].push(anAddress);
        
    }
    function removeSubaccount(address anAddress) public {
        if(anAddress == _msgSender()){
            require(subaccounts[anAddress] != address(0x0), "Address is not a subaccount");
        }else{
            require(subaccounts[anAddress] == _msgSender(), "Subaccount doesnt belong to caller");
        }
        address parent = parentUser(anAddress);
        require(parent != address(0x0), "Address has no parent");
        delete subaccounts[anAddress];
        for(uint256 i = 0; i < userSubaccounts[parent].length; i++){
            if(userSubaccounts[parent][i] == anAddress){
                userSubaccounts[parent][i] = userSubaccounts[parent][userSubaccounts[parent].length-1];
                userSubaccounts[parent].pop();
            }
        }
    }
    
    function listSubaccounts(address anAddress) public view returns(address[] memory){
        return userSubaccounts[anAddress];
    }
    
}// MIT
pragma solidity ^0.8.0;

contract Registry {

    
    mapping(bytes32=>string) registry;
    bytes32[] private index;

    constructor(){
    
    }

    function count() public view returns(uint256){
        return index.length;
    }

    function atIndex(uint256 _i) public view returns(string memory){
        
        return registry[index[_i]];
    }

    function discover(string memory _name) public returns(bytes32){
        if(bytes(_name).length == 0){
          revert("Revert due to empty name");
        }
        bytes32 hash = Utils.hashString(_name);
        if(bytes(registry[hash]).length == 0){
            registry[hash] = _name;
        }
        return hash;
    }
    function reveal(bytes32 hash) public view returns(string memory){
        return registry[hash];
    }

    function isDiscovered(string memory _name) public view returns(bool) {
        bytes32 hash = Utils.hashString(_name);
        return bytes(registry[hash]).length > 0;
    }

}// MIT
pragma solidity ^0.8.0;

contract Domain is  ERC721Enumerable {
  using SafeMath for uint256;
  using Counters for Counters.Counter;
  
  Settings settings;
  Counters.Counter private _tokenIds;
  struct DomainInfo {
      bytes32 domainHash;
      uint256 expireTimestamp;
      uint256 transferCooloffTime;
      bool active;
      uint256 canBurnAfter;
      bool burnRequest;
      bool burnRequestCancel;
      bool burnInit;
  }
  
  address private _owner;

  mapping(uint256=>DomainInfo) public domains;
  mapping(bytes32=>uint256) public domainHashToToken;
  mapping(address=>mapping(address=>mapping(uint256=>uint256))) public offchainTransferConfirmations;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  event DomainDeactivated(uint256 tokenId);
  event DomainActivated(uint256 tokenId);
  event InitBurnRequest(uint256 tokenId);
  event BurnInitiated(uint256 tokenId);
  event InitCancelBurn(uint256 tokenId);
  event BurnCancel(uint256 tokenId);
  event Burned(uint256 tokenId, bytes32 domainHash);
   
  string public _custodianBaseUri;
  
  constructor(string memory baseUri, Settings _settings) ERC721("Domain Name Token", "DOMAIN") {
    _owner = msg.sender;
    _custodianBaseUri = baseUri;
    settings = _settings;
  }
  
  function _baseURI()
    internal
    view
    virtual
    override
    returns (string memory) {
    return _custodianBaseUri;
  }
  
  
  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    
    string memory baseURI = _baseURI();
    string memory domainName = getDomainName(tokenId);
    return string(abi.encodePacked(baseURI, "/", "api" "/","info","/","domain","/",domainName,".json"));
    
  }
  
  function owner() public view virtual returns (address) {
    return _owner;
  }
  modifier onlyOwner() {
    require(owner() == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function setSettingsAddress(Settings _settings) public onlyOwner {
      settings = _settings;
  }

  function burnRestrictionWindow() public view returns(uint256){
      return settings.getNamedUint("BURN_RESTRICTION_WINDOW");
  }
  
  function changeOwner(address nextOwner) public onlyOwner {
    address previousOwner = _owner;
    _owner = nextOwner;
    emit OwnershipTransferred(previousOwner, nextOwner);
  }

  function user() public view returns(User){
      return User(settings.getNamedAddress("USER"));
  }
  function registry() public view returns(Registry){
      return Registry(settings.getNamedAddress("REGISTRY"));
  }
  
  function isDomainActive(uint256 tokenId)
    public
    view
    returns (bool){
    
    return _exists(tokenId) && domains[tokenId].active && domains[tokenId].expireTimestamp > block.timestamp;
  }
  
  function isDomainNameActive(string memory domainName)
    public
    view
    returns (bool){
    return isDomainActive(tokenOfDomain(domainName));
  }
  function getDomainName(uint256 tokenId)
    public
    view
    returns (string memory){
      return registry().reveal(domains[tokenId].domainHash);
  }

  function getHashOfTokenId(uint256 tokenId) public view returns(bytes32){
      return domains[tokenId].domainHash;
  }
  
  function registryDiscover(string memory name) public returns(bytes32){
      return registry().discover(name);
  }
  function registryReveal(bytes32 key) public view returns(string memory){
      return registry().reveal(key);
  }
  
  function tokenOfDomain(string memory domainName)
    public
    view
    returns (uint256){
    
    bytes32 domainHash = Utils.hashString(domainName);
    return domainHashToToken[domainHash];
    
  }
  
  function getTokenId(string memory domainName)
    public
    view
    returns (uint256){
    
    return tokenOfDomain(domainName);
  }
  
  function getExpirationDate(uint256 tokenId)
    public
    view
    returns(uint256){
    return domains[tokenId].expireTimestamp;
  }
  
  function extendExpirationDate(uint256 tokenId, uint256 interval) public onlyOwner {
    require(_exists(tokenId), "Token id does not exist");
    domains[tokenId].expireTimestamp = domains[tokenId].expireTimestamp.add(interval);
  }
  
  function extendExpirationDateDomainHash(bytes32 domainHash, uint256 interval) public onlyOwner {
    extendExpirationDate(domainHashToToken[domainHash], interval);
  }
  
  function getTokenInfo(uint256 tokenId)
    public
    view
    returns(uint256, // tokenId
            address, // ownerOf tokenId
            uint256, // expireTimestamp
            bytes32, // domainHash
            string memory // domainName
            ){
    return (tokenId,
            ownerOf(tokenId),
            domains[tokenId].expireTimestamp,
            domains[tokenId].domainHash,
            registry().reveal(domains[tokenId].domainHash));
  }
  function getTokenInfoByDomainHash(bytes32 domainHash)
    public
    view
    returns (
             uint256, // tokenId
             address, // ownerOf tokenId
             uint256, // expireTimestamp
             bytes32, // domainHash
             string memory // domainName
             ){
    if(_exists(domainHashToToken[domainHash])){
      return getTokenInfo(domainHashToToken[domainHash]);
    }else{
      return (
              0,
              address(0x0),
              0,
              bytes32(0x00),
              ""
              );
    }
  }

  
  function claim(address domainOwner, bytes32 domainHash, uint256 expireTimestamp) public onlyOwner returns (uint256){
    require(domainHashToToken[domainHash] == 0, "Token already exists");
    require(user().isActive(domainOwner), "Domain Owner is not an active user");
    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();
    
    domains[tokenId] = DomainInfo(domainHash,
                                  expireTimestamp,
                                  0,
                                  true,
                                  block.timestamp.add(burnRestrictionWindow()),
                                  false,
                                  false,
                                  false);
    domainHashToToken[domainHash] = tokenId;
    _mint(domainOwner, tokenId); 
    return tokenId;
  }

  function transferCooloffTime() public view returns (uint256){
    return settings.getNamedUint("TRANSFER_COOLOFF_WINDOW");
  }
  
  function _deactivate(uint256 tokenId) internal {
      domains[tokenId].active = false;
      emit DomainDeactivated(tokenId);
  }

  function _activate(uint256 tokenId) internal {
      domains[tokenId].active = true;
      emit DomainActivated(tokenId);
  }
  
  function deactivate(uint256 tokenId) public onlyOwner {
    require(_exists(tokenId), "Token does not exist");
    require(domains[tokenId].active, "Token is already deactivated");
    _deactivate(tokenId);
  }
  function activate(uint256 tokenId) public onlyOwner {
    require(_exists(tokenId), "Token does not exist");
    require(!domains[tokenId].active, "Token is already activated");
    _activate(tokenId);
  }
  function isInBurnCycle(uint256 tokenId) public view returns(bool){
      return _exists(tokenId)
          &&
          (
           domains[tokenId].burnRequest
           || domains[tokenId].burnRequestCancel
           || domains[tokenId].burnInit
           );
  }
  
  function canBeTransferred(uint256 tokenId) public view returns(bool){
      return user().isActive(ownerOf(tokenId))
        && domains[tokenId].active
        && domains[tokenId].transferCooloffTime <= block.timestamp
        && domains[tokenId].expireTimestamp > block.timestamp
        && !isInBurnCycle(tokenId);
  }

  function canBeBurned(uint256 tokenId) public view returns(bool){
      return domains[tokenId].canBurnAfter < block.timestamp;
  }
  
  function canTransferTo(address _receiver) public view returns(bool){
      return user().isActive(_receiver);
  }
  function extendCooloffTimeForToken(uint256 tokenId, uint256 window) public onlyOwner {
    if(_exists(tokenId)){
      domains[tokenId].transferCooloffTime = block.timestamp.add(window);
    }
  }
  function extendCooloffTimeForHash(bytes32 hash, uint256 window) public onlyOwner {
    uint256 tokenId = tokenIdForHash(hash);
    if(_exists(tokenId)){
      domains[tokenId].transferCooloffTime = block.timestamp.add(window);
    }
  }
  function offchainConfirmTransfer(address from, address to, uint256 tokenId, uint256 validUntil, uint256 custodianNonce, bytes memory signature) public {
    bytes32 message = keccak256(abi.encode(from,
                                           to,
                                           tokenId,
                                           validUntil,
                                           custodianNonce));
    address signer = Signature.recoverSigner(message, signature);
    require(settings.hasNamedRole("CUSTODIAN", signer), "Signer is not a registered custodian");
    require(_exists(tokenId), "Token does not exist");
    require(_isApprovedOrOwner(from, tokenId), "Is not token owner");
    require(isDomainActive(tokenId), "Token is not active");
    require(user().isActive(to), "Destination address is not an active user");
    offchainTransferConfirmations[from][to][tokenId] = validUntil;
  }
  function transferFrom(address from, address to, uint256 tokenId) public virtual override(ERC721){
    require(canBeTransferred(tokenId), "Token can not be transfered now");
    require(user().isActive(to), "Destination address is not an active user");
    if(settings.getNamedUint("OFFCHAIN_TRANSFER_CONFIRMATION_ENABLED") > 0){
      require(offchainTransferConfirmations[from][to][tokenId] > block.timestamp, "Transfer requires offchain confirmation");
    }
    domains[tokenId].transferCooloffTime = block.timestamp.add(transferCooloffTime());
    super.transferFrom(from, to, tokenId);
  }
  
  function adminTransferFrom(address from, address to, uint256 tokenId) public onlyOwner {
    require(_exists(tokenId), "Token does not exist");
    require(_isApprovedOrOwner(from, tokenId), "Can not transfer");
    require(user().isActive(to), "Destination address is not an active user");
    _transfer(from, to, tokenId);
  }
  
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
  function tokenExists(uint256 tokenId) public view returns(bool){
    return _exists(tokenId);
  }
  function tokenForHashExists(bytes32 hash) public view returns(bool){
    return tokenExists(tokenIdForHash(hash));
  }
  function tokenIdForHash(bytes32 hash) public view returns(uint256){
      return domainHashToToken[hash];
  }
  
    
  function initBurn(uint256 tokenId) public {
      require(canBeBurned(tokenId), "Domain is in burn restriction period");
      require(!isInBurnCycle(tokenId), "Domain already in burn cycle");
      require(_exists(tokenId), "Domain does not exist");
      require(ownerOf(tokenId) == msg.sender, "Must be owner of domain");

      domains[tokenId].burnRequest = true;
      _deactivate(tokenId);
      
      emit InitBurnRequest(tokenId);
  }
  
  function cancelBurn(uint256 tokenId) public {
      require(_exists(tokenId), "Domain does not exist");
      require(ownerOf(tokenId) == msg.sender, "Must be owner of domain");
      require(domains[tokenId].burnRequest, "No burn initiated");

      domains[tokenId].burnRequestCancel = true;
      emit InitCancelBurn(tokenId);
  }

  function burnInit(uint256 tokenId) public onlyOwner {
      require(_exists(tokenId), "Token does not exist");
      
      domains[tokenId].burnRequest = true;
      domains[tokenId].burnRequestCancel = false;
      domains[tokenId].burnInit = true;
      _deactivate(tokenId);
      emit BurnInitiated(tokenId);
  }

  function burnCancel(uint256 tokenId) public onlyOwner {
      require(_exists(tokenId), "Token does not exist");
      domains[tokenId].burnRequest = false;
      domains[tokenId].burnRequestCancel = false;
      domains[tokenId].burnInit = false;
      _activate(tokenId);
      emit BurnCancel(tokenId);
  }
  
  function burn(uint256 tokenId) public onlyOwner {
      require(_exists(tokenId), "Token does not exist");
      bytes32 domainHash = domains[tokenId].domainHash;
      delete domainHashToToken[domainHash];
      delete domains[tokenId];
      _burn(tokenId);
      emit Burned(tokenId, domainHash);    
  }
  
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20 {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}// MIT
pragma solidity ^0.8.0;

contract Locker is Ownable{
    using SafeMath for uint256;
    bool public initialized;
    
    Settings settings;
    uint256 totalDepositedTLD;
    mapping(address=>uint256) deposits;
    mapping(address=>uint256) extracted;
    uint256 allowDepositsUntil;
    uint256 allowEtherExtractionUntil;
    uint256 totalAvailableForExtraction;
    uint256 totalTLDForExtraction;

    event DepositsStarted(uint256 startedUntil);
    event DepositsEnded(uint256 totalTLDAmount, uint256 totalAvailableEther);
    event ExtractionsEnded();
    
    constructor(){

    }

    function initialize(Settings _settings) public onlyOwner{
      require(!initialized, "Contract instance has already been initialized");
      initialized = true;
      settings = _settings;
    }
    
    function setSettingsAddress(Settings _settings) public onlyOwner {
      
        settings = _settings;
    }
    
    function tld() public view returns(ERC20){
      return ERC20(settings.getNamedAddress("TLD"));
    }
    
    function deposit(uint256 amount) public {
        require(amount > 0, "Deposit value must be greater than zero");
        require(tld().allowance(msg.sender, address(this)) >= amount, "Allowance too small to cover deposit");
        
        require(block.timestamp <= allowDepositsUntil
                || msg.sender == owner(),"Wait for another deposit period to begin");
        tld().transferFrom(msg.sender, address(this), amount);
        totalDepositedTLD = totalDepositedTLD.add(amount);
        deposits[msg.sender] = deposits[msg.sender].add(amount);
    }
    function balanceOf(address userAddress) public view returns(uint256){
        return deposits[userAddress];
    }
    function withdraw(uint256 amount) public {
        require(deposits[msg.sender] >= amount, "Not enough deposited to withdraw");
        require(tld().balanceOf(address(this)) >= amount, "Not enough TLD to process");
        deposits[msg.sender] = deposits[msg.sender].sub(amount);
        totalDepositedTLD = totalDepositedTLD.sub(amount);
        tld().transfer(msg.sender, amount);
    }
    function withdrawAll() public {
        require(deposits[msg.sender] > 0, "Not enough deposited to withdraw");
        withdraw(deposits[msg.sender]);
    }

    function extractionAmount(address ofAddress) public view returns(uint256){
      if(!isExtractionsOpen()){
        return 0;
      }
      if(deposits[ofAddress] == 0){
        return 0;
      }
      if(extracted[ofAddress] >= allowEtherExtractionUntil){
        return 0;
      }
      if(totalTLDForExtraction > 0){
        return totalAvailableForExtraction.mul(deposits[ofAddress]).div(totalTLDForExtraction);
      }
      return 0;
    }
    function totalEtherAvailableForExtraction() public view returns(uint256){
      return totalAvailableForExtraction;
    }
    function totalDeposited() public view returns(uint256){
      return totalTLDForExtraction;
    }
    function totalBalanceTLD() public view returns(uint256){
      return totalDepositedTLD;
    }
    function contractBalance() public view returns(uint256){
      return address(this).balance;
    }
    
    function extract() public returns(uint256){
        require(!isDepositsOpen(), "Deposits are still open");
        require(deposits[msg.sender] > 0, "Nothing deposited");
        require(extracted[msg.sender] <= allowEtherExtractionUntil, "Already extracted. Wait for another extraction period");
        uint256 availableToExtract = extractionAmount(msg.sender);
        require(availableToExtract > 0, "Nothing to extract");
        require(availableToExtract <= address(this).balance, "Not enough balance to process extraction");
        extracted[msg.sender] = allowEtherExtractionUntil + 1;
        payable(msg.sender).transfer(availableToExtract);
        return availableToExtract;
    }
    function isDepositsOpen() public view returns(bool) {
        return block.timestamp <= allowDepositsUntil;
    }
    function isExtractionsOpen() public view returns(bool) {
        return block.timestamp <= allowEtherExtractionUntil;
    }
    
    function startDeposit(uint256 window) public onlyOwner {
        require(!isDepositsOpen(), "deposits already opened");
        allowDepositsUntil = block.timestamp.add(window);
        if(allowEtherExtractionUntil > 0){
            emit ExtractionsEnded();
        }
        allowEtherExtractionUntil = 0;
        totalAvailableForExtraction = 0;
        totalTLDForExtraction = 0;
        emit DepositsStarted(allowDepositsUntil);
    }
    function startExtraction(uint256 window) public payable onlyOwner {
        allowDepositsUntil = 0;
        allowEtherExtractionUntil = block.timestamp.add(window);
        totalAvailableForExtraction = address(this).balance;
        totalTLDForExtraction = totalDepositedTLD;
        emit DepositsEnded(totalDepositedTLD, totalAvailableForExtraction);
    }

    receive() external payable {
    }
    
}// MIT
pragma solidity ^0.8.0;

contract Ordering is Ownable {
  using SafeMath for uint256;
  bool public initialized;
  Settings settings;
  
  struct AcquisitionOrder {
      address payable custodianAddress;
      address requester;
      uint256 acquisitionType;
      uint256 acquisitionFee;
      uint256 paidAcquisitionFee;
      uint256 transferInitiated;
      uint256 acquisitionSuccessful;
      uint256 acquisitionFail;
      uint256 acquisitionYears;
      uint256 validUntil;
      uint256 custodianNonce;
      uint256 reservedId;
  }

  mapping(bytes32=>AcquisitionOrder) acquisitionOrders;

  event AcquisitionOrderCreated(address custodianAddress,
                                  address requesterAddress,
                                  bytes32 domainHash,
                                  uint256 acquisitionType,
                                  uint256 custodianNonce,
                                  bytes acquisitionCustodianEncryptedData);
    event TransferInitiated( bytes32 domainHash );
    event DomainAcquisitionPaid(bytes32 domainHash,
                                uint256 acquisitionFeePaid);
    
    event AcquisitionSuccessful(bytes32 domainHash,
                                string domainName,
                                uint256 acquisitionType);
    
    event AcquisitionFailed(bytes32 domainHash);
    
    event AcquisitionPaid(bytes32 domainHash,
                          string domainName,
                          uint256 amount);
    event RefundPaid(bytes32 domainHash,
                     address requester,
                     uint256 amount);
    event OrderCancel(bytes32 domainHash);
    
    event TokenExpirationExtension(bytes32 domainHash,
                                   uint256 tokenId,
                                   uint256 extensionTime);
    
  
  enum OrderStatus {
      UNDEFINED, // 0
      OPEN, // 1
      ACQUISITION_CONFIRMED, // 2
      ACQUISITION_FAILED, // 3
      EXPIRED, // 4
      TRANSFER_INITIATED // 5
  }
  
  enum OrderType {
      UNKNOWN, // should not be used
      REGISTRATION, // 1
      TRANSFER, // 2
      EXTENSION // 3
  }
  constructor(){
    
  }

  
  function initialize(Settings _settings) public onlyOwner {
    require(!initialized, "Contract instance has already been initialized");
    initialized = true;
    settings = _settings;
  }

  function user() public view returns(User){
      return User(settings.getNamedAddress("USER"));
  }
      
  function getAcquisitionOrder(bytes32 domainHash) public view returns(AcquisitionOrder memory){
      return acquisitionOrders[domainHash];
  }
  
  function getAcquisitionOrderByDomainName(string memory domainName) public view returns(AcquisitionOrder memory){
      bytes32 domainHash = Utils.hashString(domainName);
      return acquisitionOrders[domainHash];
  }
  
  
  function setSettingsAddress(Settings _settings) public onlyOwner {
      settings = _settings;
  }

  function tld() public view returns(TLD){
      return TLD(payable(settings.getNamedAddress("TLD")));
  }
  function tokenCreationFee(bytes32 domainHash)
    public
    view
    returns(uint256){
    return tld().rprice(acquisitionOrders[domainHash].reservedId);
      
  }
    
  
  function minimumOrderValidityTime(uint256 orderType)
      public
      view
      returns (uint256) {
      if(orderType == uint256(OrderType.REGISTRATION)){
          return settings.getNamedUint("ORDER_MINIMUM_VALIDITY_TIME_REGISTRATION");
      }
      if(orderType == uint256(OrderType.TRANSFER)){
          return settings.getNamedUint("ORDER_MINIMUM_VALIDITY_TIME_TRANSFER");
      }
      if(orderType == uint256(OrderType.EXTENSION)){
          return settings.getNamedUint("ORDER_MINIMUM_VALIDITY_TIME_EXTENSION");
      }
      return 0;
  }

  
    function orderStatus(bytes32 domainHash)
        public
        view
        returns (uint256) {
         if(isOrderConfirmed(domainHash)){
            return uint256(OrderStatus.ACQUISITION_CONFIRMED);
        }
        if(isOrderFailed(domainHash)){
            return uint256(OrderStatus.ACQUISITION_FAILED);
        }
        
        if(isTransferInitiated(domainHash)){
          return uint256(OrderStatus.TRANSFER_INITIATED);
        }
        if(isOrderExpired(domainHash)){
            return uint256(OrderStatus.EXPIRED);
        }
        
        if(isOrderOpen(domainHash)){
            return uint256(OrderStatus.OPEN);
        }
        
        return uint256(OrderStatus.UNDEFINED);
    }
    
    function orderExists(bytes32 domainHash)
      public
      view
      returns (bool){
      
      return acquisitionOrders[domainHash].validUntil > 0;
      
    }

    function isOrderExpired(bytes32 domainHash)
        public
        view
        returns (bool){
        return acquisitionOrders[domainHash].validUntil > 0
            && acquisitionOrders[domainHash].validUntil < block.timestamp
            && acquisitionOrders[domainHash].transferInitiated == 0
            && acquisitionOrders[domainHash].acquisitionSuccessful == 0
            && acquisitionOrders[domainHash].acquisitionFail == 0;
    }
    
    function isOrderOpen(bytes32 domainHash)
      public
      view
      returns (bool){
      return acquisitionOrders[domainHash].validUntil > block.timestamp
        || isOrderConfirmed(domainHash)
        || isTransferInitiated(domainHash);
    }
    
    function isOrderConfirmed(bytes32 domainHash)
      public
      view
      returns (bool){
      
      return acquisitionOrders[domainHash].acquisitionSuccessful > 0;
      
    }
    
    function isOrderFailed(bytes32 domainHash)
      public
      view
      returns (bool){

      return acquisitionOrders[domainHash].acquisitionFail > 0;
      
    }

    function isTransferInitiated(bytes32 domainHash)
      public
      view
      returns(bool){
      return acquisitionOrders[domainHash].transferInitiated > 0;
    }

    function canCancelOrder(bytes32 domainHash)
      public
      view
      returns (bool){
      
      return orderExists(domainHash)
        && acquisitionOrders[domainHash].validUntil > block.timestamp
        && !isOrderConfirmed(domainHash)
        && !isOrderFailed(domainHash)
        && !isTransferInitiated(domainHash);
      
    }
    
    function orderDomainAcquisition(bytes32 domainHash,
                                    address requester,
                                    uint256 acquisitionType,
                                    uint256 acquisitionYears,
                                    uint256 acquisitionFee,
                                    uint256 acquisitionOrderTimestamp,
                                    uint256 custodianNonce,
                                    bytes memory signature,
                                    bytes memory acquisitionCustodianEncryptedData)
      public
      payable {
        require(user().isActive(requester), "Requester must be an active user");
        require(acquisitionOrderTimestamp > block.timestamp.sub(settings.getNamedUint("ACQUISITION_ORDER_TIME_WINDOW")),
              "Try again with a fresh acquisition order");

      bytes32 message = keccak256(abi.encode(requester,
                                             acquisitionType,
                                             acquisitionYears,
                                             acquisitionFee,
                                             acquisitionOrderTimestamp,
                                             custodianNonce,
                                             domainHash));
      
      address custodianAddress = Signature.recoverSigner(message,signature);
      
      require(settings.hasNamedRole("CUSTODIAN", custodianAddress),
              "Signer is not a registered custodian");
      
      if(isOrderOpen(domainHash)){
        revert("An order for this domain is already active");
      }

      if(acquisitionType == uint256(OrderType.EXTENSION)){
        require(domainToken().tokenForHashExists(domainHash), "Token for domain does not exist");
      }
      
      require(msg.value >= acquisitionFee,
              "Acquisition fee must be paid upfront");
      uint256 reservedId = tld().reserveMint();
      acquisitionOrders[domainHash] = AcquisitionOrder(
                                                       payable(custodianAddress),
                                                       requester,
                                                       acquisitionType,
                                                       acquisitionFee,
                                                       0, // paidAcquisitionFee
                                                       0, // transferInitiated
                                                       0, // acquisitionSuccessful flag,
                                                       0, // acquisitionFail flag,
                                                       acquisitionYears,
                                                       block.timestamp.add(minimumOrderValidityTime(acquisitionType)), //validUntil,
                                                       custodianNonce,
                                                       reservedId
                                                       );
        
      emit  AcquisitionOrderCreated(custodianAddress,
                                    requester,
                                    domainHash,
                                    acquisitionType,
                                    custodianNonce,
                                    acquisitionCustodianEncryptedData);
      
    }
    modifier onlyCustodian() {
      require(settings.hasNamedRole("CUSTODIAN", _msgSender())
              || _msgSender() == owner(),
              "Must be a custodian");
      _;
    }

    function transferInitiated(bytes32 domainHash)
      public onlyCustodian {
      require(acquisitionOrders[domainHash].validUntil > 0,
              "Order does not exist");
      require(acquisitionOrders[domainHash].acquisitionType == uint256(OrderType.TRANSFER),
              "Order is not Transfer");
      require(acquisitionOrders[domainHash].transferInitiated == 0,
              "Already marked");
      acquisitionOrders[domainHash].transferInitiated = block.timestamp;
      if(acquisitionOrders[domainHash].paidAcquisitionFee == 0
         && acquisitionOrders[domainHash].acquisitionFee > 0){

        uint256 communityFee = Utils.calculatePercentageCents(acquisitionOrders[domainHash].acquisitionFee,
                                                           settings.getNamedUint("COMMUNITY_FEE"));
        address payable custodianAddress = acquisitionOrders[domainHash].custodianAddress;
        uint256 custodianFee = acquisitionOrders[domainHash].acquisitionFee.sub(communityFee);
        acquisitionOrders[domainHash].paidAcquisitionFee = acquisitionOrders[domainHash].acquisitionFee;
        custodianAddress.transfer(custodianFee);
        payable(address(tld())).transfer(communityFee);
          
      }
      emit TransferInitiated(domainHash);
    }
    
    function domainToken() public view returns(Domain){
        return Domain(settings.getNamedAddress("DOMAIN"));
    }
    function acquisitionSuccessful(string memory domainName)
      public onlyCustodian {
        bytes32 domainHash = domainToken().registryDiscover(domainName);
        require(acquisitionOrders[domainHash].validUntil > 0,
                "Order does not exist");
        require(acquisitionOrders[domainHash].acquisitionSuccessful == 0,
                "Already marked");
        if(acquisitionOrders[domainHash].acquisitionType == uint256(OrderType.TRANSFER)
           && acquisitionOrders[domainHash].transferInitiated == 0){
          revert("Transfer was not initiated");
        }
        acquisitionOrders[domainHash].acquisitionSuccessful = block.timestamp;
        acquisitionOrders[domainHash].acquisitionFail = 0;
       
        if(acquisitionOrders[domainHash].paidAcquisitionFee == 0
           && acquisitionOrders[domainHash].acquisitionFee > 0){
          uint256 communityFee = Utils.calculatePercentageCents(acquisitionOrders[domainHash].acquisitionFee,
                                                             settings.getNamedUint("COMMUNITY_FEE"));
          address payable custodianAddress = acquisitionOrders[domainHash].custodianAddress;
          uint256 custodianFee = acquisitionOrders[domainHash].acquisitionFee.sub(communityFee);
          acquisitionOrders[domainHash].paidAcquisitionFee = acquisitionOrders[domainHash].acquisitionFee;
          custodianAddress.transfer(custodianFee);
          payable(address(tld())).transfer(communityFee);
        }
        uint256 acquisitionType = acquisitionOrders[domainHash].acquisitionType;
        if(acquisitionOrders[domainHash].acquisitionType == uint256(OrderType.EXTENSION)){
          
            emit TokenExpirationExtension(domainHash,
                                          domainToken().tokenIdForHash(domainHash),
                                          acquisitionOrders[domainHash].acquisitionYears.mul(365 days));
            delete acquisitionOrders[domainHash];
        }
        
        emit AcquisitionSuccessful(domainHash, domainName, acquisitionType);

    }
    function getAcquisitionYears(bytes32 domainHash) public view returns(uint256){
      return acquisitionOrders[domainHash].acquisitionYears;
    }
    
    function acquisitionFail(bytes32 domainHash)
      public onlyCustodian {
      require(acquisitionOrders[domainHash].validUntil > 0,
              "Order does not exist");
      require(acquisitionOrders[domainHash].acquisitionFail == 0,
              "Already marked");
      acquisitionOrders[domainHash].transferInitiated = 0;
      acquisitionOrders[domainHash].acquisitionSuccessful = 0;
      acquisitionOrders[domainHash].acquisitionFail = block.timestamp;
      if( acquisitionOrders[domainHash].paidAcquisitionFee == 0
          && acquisitionOrders[domainHash].acquisitionFee > 0){
        
        address payable requester = payable(acquisitionOrders[domainHash].requester);
        uint256 refundAmount = acquisitionOrders[domainHash].acquisitionFee;
        requester.transfer(refundAmount);
        
      }
      
      delete acquisitionOrders[domainHash];
      
      emit AcquisitionFailed(domainHash);

    }

    function cancelOrder(bytes32 domainHash)
      public {
      require(canCancelOrder(domainHash),
              "Can not cancel order");
      if(acquisitionOrders[domainHash].paidAcquisitionFee == 0
         && acquisitionOrders[domainHash].acquisitionFee > 0){
        address payable requester = payable(acquisitionOrders[domainHash].requester);
        acquisitionOrders[domainHash].paidAcquisitionFee = acquisitionOrders[domainHash].acquisitionFee;
        if(requester.send(acquisitionOrders[domainHash].acquisitionFee)){

            emit RefundPaid(domainHash, requester, acquisitionOrders[domainHash].acquisitionFee);

        }
      }
      delete acquisitionOrders[domainHash];
      emit OrderCancel(domainHash);
    }

    function canClaim(bytes32 domainHash)
      public view returns(bool){
      return (acquisitionOrders[domainHash].validUntil > 0 &&
              acquisitionOrders[domainHash].acquisitionFail == 0 &&
              acquisitionOrders[domainHash].acquisitionSuccessful > 0 &&
              !domainToken().tokenForHashExists(domainHash));
      
    }
        
    function orderRequester(bytes32 domainHash)
      public view returns(address){
      return acquisitionOrders[domainHash].requester;
    }

    function computedExpirationDate(bytes32 domainHash)
      public view returns(uint256){
      return acquisitionOrders[domainHash].acquisitionSuccessful
        .add(acquisitionOrders[domainHash].acquisitionYears
             .mul(365 days));
    }
    function tldOrderReservedId(bytes32 domainHash)
      public view returns(uint256){
      return acquisitionOrders[domainHash].reservedId;
    }

    function finishOrder(bytes32 domainHash)
      public onlyOwner {
      delete acquisitionOrders[domainHash];
    }
}// MIT
pragma solidity ^0.8.0;

contract Manager is  Ownable {
    using SafeMath for uint256;
    bool public initialized;
    Settings settings;
    
    mapping(bytes32=>uint256) domainHashToToken;
    mapping(uint256=>bytes32) tokenToDomainHash;
        
    event TokenClaim(bytes32 domainHash,
                     uint256 tokenId,
                     string domainName);
    
    constructor()  {
      
    }
    
    function initialize(Settings _settings) public onlyOwner {
      require(!initialized, "Contract instance has already been initialized");
      initialized = true;
      settings = _settings;
    }

    modifier onlyCustodian() {
        require(settings.hasNamedRole("CUSTODIAN", _msgSender()),
                "Must be a custodian");
        _;
    }
    
    modifier onlyNamedRole(string memory _name) {
        require(settings.hasNamedRole(_name, _msgSender()),
                "Does not have required role");
        _;
    }
    
    function setSettingsAddress(Settings _settings) public onlyOwner {
        settings = _settings;
    }

    function tld() public view returns(TLD){
      return TLD(payable(settings.getNamedAddress("TLD")));
    }

    function domainToken() public view returns(Domain){
      return Domain(settings.getNamedAddress("DOMAIN"));
    }
    
    function initTLD(uint256 initialGasUsed, uint256 averageLength, uint256 basePriceMultiplier) public payable onlyOwner{
        
      tld().init{value: msg.value}(initialGasUsed, averageLength, basePriceMultiplier);
    }
    function callNamedContract(string memory _name, bytes memory data) public payable onlyOwner returns(bool, bytes memory){
      uint256 gasStart = gasleft();
      address _contract = settings.getNamedAddress(_name);
      (bool success, bytes memory response) = _contract.call{value: msg.value}(data);
      if(success){
        tld().reimburse(gasStart.sub(gasleft()), payable(_msgSender()));
      }
      return (success, response);
    }
    function callContract(address _contract, bytes memory data) public payable onlyOwner returns(bool, bytes memory){
      (bool success, bytes memory response) = _contract.call{value: msg.value}(data);
      return (success, response);
    }
    function reimbursedOrdering(bytes memory data) public returns(bool, bytes memory){
      uint256 gasStart = gasleft();
      require(owner() == _msgSender() || settings.hasNamedRole("CUSTODIAN", _msgSender()), "must be custodian");
      (bool success, bytes memory response) = settings.getNamedAddress("ORDERING").call(data);
      if(success){
          tld().reimburse(gasStart.sub(gasleft()), payable(_msgSender()));
      }
      return (success, response);
    }
    function registerCustodian(address custodianAddress)
      public onlyOwner{
      uint256 gasStart = gasleft();
      require(custodianAddress != address(0), "Custodian address must be a valid address");
      require(!settings.hasNamedRole("CUSTODIAN", custodianAddress), "Address is already a custodian");
      settings.registerNamedRole("CUSTODIAN", custodianAddress);
      tld().reimburse(gasStart - gasleft(), payable(_msgSender()));
      
    }
    
    function unregisterCustodian(address custodianAddress)
      public onlyOwner{
      uint256 gasStart = gasleft();
      require(settings.hasNamedRole("CUSTODIAN", custodianAddress), "Not a custodian");
      settings.unregisterNamedRole("CUSTODIAN", custodianAddress);
      tld().reimburse(gasStart - gasleft(), payable(_msgSender()));
    }
    
    function changeSettingsAdmin(address adminAddress)
      public onlyOwner{
      uint256 gasStart = gasleft();
      require(adminAddress != address(0), "New admin must be a valid address");
      settings.changeAdmin(adminAddress);
      tld().reimburse(gasStart - gasleft(), payable(_msgSender()));
    }

    function ordering() public view returns(Ordering){
      return Ordering(settings.getNamedAddress("ORDERING"));
    }
    function acceptExtension(bytes32 domainHash) public onlyCustodian {
      uint256 gasStart = gasleft();
    
      string memory domainName = domainToken().registryReveal(domainHash);
      uint256 extensionTime = ordering().getAcquisitionYears(domainHash).mul(365 days);
      ordering().acquisitionSuccessful(domainName);
      domainToken().extendExpirationDate(domainToken().tokenIdForHash(domainHash),
                                         extensionTime);
      tld().reimburse(gasStart - gasleft(), payable(_msgSender()));
    }
    
    function claimToken(bytes32 domainHash)
      public
      payable
      returns (uint256) {
      
      require(ordering().canClaim(domainHash), "Can not claim token");
        
      uint256 requiredTokenCreationFee = ordering().tokenCreationFee(domainHash);
      
      require(msg.value >= requiredTokenCreationFee,
              "Must pay token creation fee");
      
      address requester = ordering().orderRequester(domainHash);
      uint256 tokenId = domainToken().claim(requester,
                                            domainHash,
                                            ordering().computedExpirationDate(domainHash));
      tokenToDomainHash[tokenId] = domainHash;
      domainHashToToken[domainHash] = tokenId;
      uint256 mintedTLD = tld().mint{value: msg.value}(ordering().tldOrderReservedId(domainHash));
      uint256 userTLD = Utils.calculatePercentageCents(mintedTLD,
                                                       settings.getNamedUint("TLD_DISTRIBUTION_COMMUNITY_PERCENTAGE"));
      uint256 networkTLD = Utils.calculatePercentageCents(mintedTLD,
                                                          settings.getNamedUint("TLD_DISTRIBUTION_NETWORK_MAINTENANCE_PERCENTAGE"));
      uint256 devTLD = mintedTLD.sub(userTLD).sub(networkTLD);
      ordering().finishOrder(domainHash);
      tld().transfer(requester, userTLD);
      tld().transfer(settings.getNamedAddress("DEVELOPER"), devTLD);
      emit TokenClaim(domainHash, tokenId, domainToken().registryReveal(domainHash));
      return tokenId;
    }
    
    function spendTLD(uint256 amount, address toAddress) public onlyOwner {
      tld().transfer(toAddress, amount);
    }
    function locker() public view returns(Locker){
      return Locker(payable(settings.getNamedAddress("LOCKER")));
    }
    function startDepositsRound(uint256 depositsWindow) public {
        uint256 gasStart = gasleft();
        require(settings.hasNamedRole("SKIMMER", _msgSender()), "Caller is skimmer");
        if(locker().isExtractionsOpen() && locker().extractionAmount(address(this)) > 0){
          uint256 extracted = locker().extract();
          if(extracted > 0){
            payable(_msgSender()).transfer(extracted);
          }
        }
        if(locker().balanceOf(address(this)) > 0){
          locker().withdrawAll();
        }
        locker().startDeposit(depositsWindow);
        tld().reimburse(gasStart - gasleft(), payable(_msgSender()));
    }
    function startExtractionsRound(uint extractionsWindow) public {
        uint gasStart = gasleft();
        require(settings.hasNamedRole("SKIMMER", _msgSender()), "Caller is not skimmer");
        if(locker().isDepositsOpen() &&  tld().overflow() > 0){
          uint256 totalTldFunds = tld().balanceOf(address(this));
          if(totalTldFunds > 0){
            tld().approve(address(locker()), totalTldFunds);
            locker().deposit(totalTldFunds);
          }
        }
        uint256 skimmedAmount = tld().skim(address(this));
        locker().startExtraction{value: skimmedAmount}(extractionsWindow);
        if(locker().isExtractionsOpen() && locker().extractionAmount(address(this)) > 0){
          uint256 extracted = locker().extract();
          if(extracted > 0){
            payable(_msgSender()).transfer(extracted);
          }
        }
        if(locker().balanceOf(address(this)) > 0){
          locker().withdrawAll();
        }
        tld().reimburse(gasStart - gasleft(), payable(_msgSender()));
    }
    function user() public view returns(User){
      return User(settings.getNamedAddress("USER"));
    }
    function registerUser(address _userAddress) public onlyOwner{
      uint256 gasStart = gasleft();
      require(!user().isRegistered(_userAddress), "Address already registered");
      user().register(_userAddress);
      tld().reimburse(gasStart - gasleft(), payable(_msgSender()));
    }
    function activateUser(address _userAddress) public onlyOwner{
      uint256 gasStart = gasleft();
      require(user().isRegistered(_userAddress), "Address is not registered");
      require(!user().isActive(_userAddress), "Address is already an active user");
      user().activateUser(_userAddress);
      tld().reimburse(gasStart - gasleft(), payable(_msgSender()));
    }
    function deactivateUser(address _userAddress) public onlyOwner{
      uint256 gasStart = gasleft();
      require(user().isRegistered(_userAddress), "Address is not registered");
      require(user().isActive(_userAddress), "Address is not an active user");
      user().deactivateUser(_userAddress);
      tld().reimburse(gasStart - gasleft(), payable(_msgSender()));
    }

    function initBurn(bytes32 hash) public onlyCustodian{
        uint256 gasStart = gasleft();
        uint256 tokenId = domainToken().tokenIdForHash(hash);
        require(domainToken().tokenExists(tokenId), "Token does not exist");
        domainToken().burnInit(tokenId);
        tld().reimburse(gasStart - gasleft(), payable(_msgSender()));
    }

    function cancelBurn(bytes32 hash) public onlyCustodian{
        uint256 gasStart = gasleft();
        uint256 tokenId = domainToken().tokenIdForHash(hash);
        require(domainToken().tokenExists(tokenId), "Token does not exist");
        domainToken().burnCancel(tokenId);
        tld().reimburse(gasStart - gasleft(), payable(_msgSender()));
    }

    function acceptBurn(bytes32 hash) public onlyOwner{
        uint256 gasStart = gasleft();
        uint256 tokenId = domainToken().tokenIdForHash(hash);
        require(domainToken().tokenExists(tokenId), "Token does not exist");
        domainToken().burn(tokenId);
        tld().reimburse(gasStart - gasleft(), payable(_msgSender()));
    }
    
    receive() external payable {

    }
}