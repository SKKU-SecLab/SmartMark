
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
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
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

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

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}
contract Hotfriescoin is Context, Ownable, ERC20 {
 address public lootContractAddress =
 0xFF9C1b15B16263C61d017ee9F65C50e4AE0113D7;
 IERC721Enumerable public lootContract;
 uint256 public HotfriescoinPerTokenId = 1243 * (10**decimals());
 uint256 public tokenIdStart = 1;
 
 uint256 public tokenIdEnd = 8000;
 uint256 public PUBLIC_MINT_PRICE = 200000000000000; // 0.0002000000 eth
 uint public MAX_SUPPLY = 4 * 10 ** (7+18);
 uint public MAX_FREE_SUPPLY = 9.9944 * 10 ** (6+18);
 uint256 public _totalSupply =4 * 10 **(7 + 18);
 uint public MAX_PAID_SUPPLY = 2.9836 * 10 ** (7+18);
 uint public totalFreeClaims = 0;
 uint public totalPaidClaims = 0;
 address private devWallet = 0x482e57C86D0eA19d7756Ea863fB8E58E6c69f0E9;
 uint256 public season = 0;
 uint256 public contractorToken = 2.2 * 10 ** (5+18);
 uint256 public tokenPrice = 0.0002 ether;
 
 mapping(uint256 => mapping(uint256 => bool)) public seasonClaimedByTokenId;
 constructor() Ownable() ERC20("Hotfries", "HF") {
 lootContract = IERC721Enumerable(lootContractAddress);
 
 _mint(msg.sender, (_totalSupply - MAX_FREE_SUPPLY));
 _mint(lootContractAddress, MAX_FREE_SUPPLY);
 
 
 


 }
 
 
 
 function claimById(uint256 tokenId) external {
 require(
 _msgSender() == lootContract.ownerOf(tokenId),
 "MUST_OWN_TOKEN_ID"
 );
 _claim(tokenId, _msgSender());
 
 
 }
 function claimAllForOwner() payable public {
 uint256 tokenBalanceOwner = lootContract.balanceOf(_msgSender());
 require( tokenBalanceOwner <= HotfriescoinPerTokenId); // Each loot bag owner claim 1243 HFC Maximum.
 
 require(tokenBalanceOwner > 0, "NO_TOKENS_OWNED"); 
 for (uint256 i = 0; i < tokenBalanceOwner; i++) {
 _claim(
 lootContract.tokenOfOwnerByIndex(_msgSender(), i),
 _msgSender()
 );
 }
 }
 function claimAllToken() external{
     uint256 tokenBalanceOwner = lootContract.balanceOf(_msgSender());
 require(tokenBalanceOwner == HotfriescoinPerTokenId , "1243 HFC Claimed by each user"); 
 PUBLIC_MINT_PRICE = 1600000000000000;
  }

 function claimRangeForOwner(uint256 ownerIndexStart, uint256 ownerIndexEnd)
 external
 {
 uint256 tokenBalanceOwner = lootContract.balanceOf(_msgSender());
 require(tokenBalanceOwner > 0, "NO_TOKENS_OWNED");
 require(
 ownerIndexStart >= 0 && ownerIndexEnd < tokenBalanceOwner,
 "INDEX_OUT_OF_RANGE"
 );
 for (uint256 i = ownerIndexStart; i <= ownerIndexEnd; i++) {
 _claim(
 lootContract.tokenOfOwnerByIndex(_msgSender(), i),
 _msgSender()
 );
 }
 }
 function _claim(uint256 tokenId, address tokenOwner) internal {
 require(
 tokenId >= tokenIdStart && tokenId <= tokenIdEnd,
 "TOKEN_ID_OUT_OF_RANGE"
 );

 require(
 !seasonClaimedByTokenId[season][tokenId],
 "GOLD_CLAIMED_FOR_TOKEN_ID"
 );
 
 seasonClaimedByTokenId[season][tokenId] = true;
 _mint(tokenOwner, HotfriescoinPerTokenId);

 }
 
 
 function daoMint(uint256 amountDisplayValue) external onlyOwner {
 _mint(owner(), amountDisplayValue * (10**decimals()));
 }
 function daoSetLootContractAddress(address lootContractAddress_)
 external
 onlyOwner
 {
 lootContractAddress = lootContractAddress_;
 lootContract = IERC721Enumerable(lootContractAddress);
 }
 function daoSetTokenIdRange(uint256 tokenIdStart_, uint256 tokenIdEnd_)
 external
 onlyOwner
 {
 tokenIdStart = tokenIdStart_;
 tokenIdEnd = tokenIdEnd_;
 }
 function daoSetSeason(uint256 season_) public onlyOwner {
 season = season_;
 }
 function daoSetHotfriescoinPerTokenId(uint256 HotfriescoinDisplayValue)
 public
 onlyOwner
 {
 HotfriescoinDisplayValue = 1243;
 HotfriescoinPerTokenId = HotfriescoinDisplayValue * (10**decimals());
 }
 function daoSetSeasonAndHotfriescoinPerTokenID(
 uint256 season_,
 uint256 HotfriescoinDisplayValue
 ) external onlyOwner {
 daoSetSeason(season_);
 daoSetHotfriescoinPerTokenId(HotfriescoinDisplayValue);
 }
 
 
}


contract TokenSale{
    Hotfriescoin public tokenContract;
    
    constructor(Hotfriescoin _contractAddr){
        tokenContract = _contractAddr;
    }
    
    function buyTokens(uint _amount) public payable{
     require(_amount <= tokenContract.balanceOf(tokenContract.owner()));
     require(uint256(msg.value) == uint256(_amount*tokenContract.tokenPrice()));
     tokenContract.transferFrom(tokenContract.owner(), msg.sender, _amount);
     payable(tokenContract.owner()).transfer(msg.value);
 }
}