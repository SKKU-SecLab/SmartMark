

pragma solidity 0.7.0;
pragma experimental ABIEncoderV2;




library BoostersStringUtils {


    function compare(string memory _a, string memory _b) internal pure returns (int) {

        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

    function equal(string memory _a, string memory _b)  internal pure returns (bool) {

        return compare(_a, _b) == 0;
    }

    function indexOf(string memory _haystack, string memory _needle) internal pure returns (int) {

    	bytes memory h = bytes(_haystack);
    	bytes memory n = bytes(_needle);
    	if(h.length < 1 || n.length < 1 || (n.length > h.length)) 
    		return -1;
    	else if(h.length > (2**128 -1)) // since we have to be able to return -1 (if the char isn't found or input error), this function must return an "int" type with a max length of (2^128 - 1)
    		return -1;									
    	else
    	{
    		uint subindex = 0;
    		for (uint i = 0; i < h.length; i ++)
    		{
    			if (h[i] == n[0]) // found the first char of b
    			{
    				subindex = 1;
    				while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex]) // search until the chars don't match or until we reach the end of a or b
    				{
    					subindex++;
    				}	
    				if(subindex == n.length)
    					return int(i);
    			}
    		}
    		return -1;
    	}	
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}


interface ISIGHBoosters {



    event baseURIUpdated(string baseURI);
    event newCategoryAdded(string _type, uint256 _platformFeeDiscount_, uint256 _sighPayDiscount_, uint256 _maxBoosters);
    event BoosterMinted(address _owner, string _type,string boosterURI,uint256 newItemId,uint256 totalBoostersOfThisCategory);
    event boosterURIUpdated(uint256 boosterId, string _boosterURI);
    event discountMultiplierUpdated(string _type,uint256 _platformFeeDiscount_,uint256 _sighPayDiscount_ );

    event BoosterWhiteListed(uint256 boosterId);
    event BoosterBlackListed(uint256 boosterId);

    
    function addNewBoosterType(string memory _type, uint256 _platformFeeDiscount_, uint256 _sighPayDiscount_, uint256 _maxBoosters) external returns (bool) ;

    function createNewBoosters(address _owner, string[] memory _type,  string[] memory boosterURI) external returns (uint256);

    function createNewSIGHBooster(address _owner, string memory _type,  string memory boosterURI, bytes memory _data ) external returns (uint256) ;

    function _updateBaseURI(string memory baseURI )  external ;

    function updateBoosterURI(uint256 boosterId, string memory boosterURI )  external returns (bool) ;

    function updateDiscountMultiplier(string memory _type, uint256 _platformFeeDiscount_,uint256 _sighPayDiscount_)  external returns (bool) ;


    function blackListBooster(uint256 boosterId) external;

    function whiteListBooster(uint256 boosterId) external;


    function name() external view  returns (string memory) ;

    function symbol() external view  returns (string memory) ;

    function totalSupply() external view  returns (uint256) ;

    function baseURI() external view returns (string memory) ;


    function tokenByIndex(uint256 index) external view  returns (uint256) ;


    function balanceOf(address _owner) external view returns (uint256 balance) ;    // Returns total number of Boosters owned by the _owner

    function tokenOfOwnerByIndex(address owner, uint256 index) external view  returns (uint256) ; //  See {IERC721Enumerable-tokenOfOwnerByIndex}.


    function ownerOfBooster(uint256 boosterId) external view returns (address owner) ; // Returns current owner of the Booster having the ID = boosterId

    function tokenURI(uint256 boosterId) external view  returns (string memory) ;   // Returns the boostURI for the Booster


    function approve(address to, uint256 boosterId) external ;  // A BOOSTER owner can approve anyone to be able to transfer the underlying booster

    function setApprovalForAll(address operator, bool _approved) external;



    function getApproved(uint256 boosterId) external view  returns (address);   // Returns the Address currently approved for the Booster with ID = boosterId

    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function transferFrom(address from, address to, uint256 boosterId) external;

    function safeTransferFrom(address from, address to, uint256 boosterId) external;

    function safeTransferFrom(address from, address to, uint256 boosterId, bytes memory data) external;



    function getAllBoosterTypes() external view returns (string[] memory);


    function isCategorySupported(string memory _category) external view returns (bool);

    function getDiscountRatiosForBoosterCategory(string memory _category) external view returns ( uint platformFeeDiscount, uint sighPayDiscount );


    function totalBoostersAvailable(string memory _category) external view returns (uint256);

    function maxBoostersAllowed(string memory _category) external view returns (uint256);


    function totalBoostersOwnedOfType(address owner, string memory _category) external view returns (uint256) ;  // Returns the number of Boosters of a particular category owned by the owner address


    function isValidBooster(uint256 boosterId) external view returns (bool);

    function getBoosterCategory(uint256 boosterId) external view returns ( string memory boosterType );

    function getDiscountRatiosForBooster(uint256 boosterId) external view returns ( uint platformFeeDiscount, uint sighPayDiscount );

    function getBoosterInfo(uint256 boosterId) external view returns (address farmer, string memory boosterType,uint platformFeeDiscount, uint sighPayDiscount, uint _maxBoosters );


    function isBlacklisted(uint boosterId) external view returns(bool) ;


}


interface ISIGHBoostersSale {


    event BoosterAddedForSale(string _type,uint boosterid);
    event SalePriceUpdated(string _type,uint _price);
    event PaymentTokenUpdated(address token);
    event FundsTransferred(uint amount);
    event TokensTransferred(address token,address to,uint amount);
    event SaleTimeUpdated(uint initiateTimestamp);
    event BoosterSold(address _to, string _BoosterType,uint _boosterId, uint salePrice );
    event BoostersBought(address caller,address receiver,string _BoosterType,uint boostersBought,uint amountToBePaid);
    event BoosterAdded(address operator,address from,uint tokenId);



    function updateSalePrice(string calldata _BoosterType, uint256 _price ) external;


    function updateAcceptedToken(address token) external;


    function transferBalance(address to, uint amount) external;


    function updateSaleTime(uint timestamp) external;


    function transferTokens(address token, address to, uint amount) external ;


    function buyBoosters(address receiver, string memory _BoosterType, uint boostersToBuy) external;



    function getBoosterSaleDetails(string memory _Boostertype) external view returns (uint256 available,uint256 price, uint256 sold);


    function getTokenAccepted() external view returns(string memory symbol, address tokenAddress);


    function getCurrentFundsBalance() external view returns (uint256);


    function getTokenBalance(address token) external view returns (uint256) ;


}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
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


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}


contract SIGHBoostersSale is IERC721Receiver,Ownable,ISIGHBoostersSale {

    using BoostersStringUtils for string;
    using SafeMath for uint256;

    ISIGHBoosters private _SIGH_NFT_BoostersContract;    // SIGH Finance NFT Boosters Contract
    uint public initiateTimestamp;

    ERC20 private tokenAcceptedAsPayment;         // Address of token accepted as payment

    struct boosterList {
        uint256 totalAvailable;             // No. of Boosters of a particular type currently available for sale
        uint256[] boosterIdsList;          // List of BoosterIds for the boosters of a particular type currently available for sale
        uint256 salePrice;                  // Sale price for a particular type of Booster
        uint256 totalBoostersSold;           // Boosters sold
    }

    mapping (string => boosterList) private listOfBoosters;   // (Booster Type => boosterList struct)
    mapping (uint256 => bool) private boosterIdsForSale;      // Booster Ids that have been included for sale
    mapping (string => bool) private boosterTypes;            // Booster Type => Yes/No

    constructor(address _SIGHNFTBoostersContract) {
        require(_SIGHNFTBoostersContract != address(0),'SIGH Finance : Invalid _SIGHNFTBoostersContract address');
        _SIGH_NFT_BoostersContract = ISIGHBoosters(_SIGHNFTBoostersContract);
    }



    function updateSalePrice(string memory _BoosterType, uint256 _price ) external override onlyOwner {
        require( _SIGH_NFT_BoostersContract.isCategorySupported(_BoosterType),"Invalid Type");
        require( boosterTypes[_BoosterType] ,"Not yet initialized");
        listOfBoosters[_BoosterType].salePrice = _price;
        emit SalePriceUpdated(_BoosterType,_price);
    }

    function updateAcceptedToken(address token) external override onlyOwner {
        require( token != address(0) ,"Invalid address");
        tokenAcceptedAsPayment = ERC20(token);
        emit PaymentTokenUpdated(token);
    }

    function transferBalance(address to, uint amount) external override onlyOwner {
        require( to != address(0) ,"Invalid address");
        require( amount <= getCurrentFundsBalance() ,"Invalid amount");
        tokenAcceptedAsPayment.transfer(to,amount);
        emit FundsTransferred(amount);
    }

    function updateSaleTime(uint timestamp) external override onlyOwner {
        require( block.timestamp < timestamp,'Invalid stamp');
        initiateTimestamp = timestamp;
        emit SaleTimeUpdated(initiateTimestamp);
    }

    function transferTokens(address token, address to, uint amount) external override onlyOwner {
        require( to != address(0) ,"Invalid address");
        ERC20 token_ = ERC20(token);
        uint balance = token_.balanceOf(address(this));
        require( amount <= balance ,"Invalid amount");
        token_.transfer(to,amount);
        emit TokensTransferred(token,to,amount);
    }


    function buyBoosters(address receiver, string memory _BoosterType, uint boostersToBuy) override external {
        require( block.timestamp > initiateTimestamp,'Sale not begin');
        require(listOfBoosters[_BoosterType].salePrice > 0 ,"Price cannot be Zero");
        require(boosterTypes[_BoosterType],"Invalid Booster Type");
        require(boostersToBuy >= 1,"Invalid number of boosters");
        require(listOfBoosters[_BoosterType].totalAvailable >=  boostersToBuy,"Boosters not available");

        uint amountToBePaid = boostersToBuy.mul(listOfBoosters[_BoosterType].salePrice);

        require(transferFunds(msg.sender,amountToBePaid),'Funds transfer Failed');
        require(transferBoosters(receiver, _BoosterType, boostersToBuy),'Boosters transfer Failed');

        emit BoostersBought(msg.sender,receiver,_BoosterType,boostersToBuy,amountToBePaid);
    }



    function getBoosterSaleDetails(string memory _Boostertype) external view override returns (uint256 available,uint256 price, uint256 sold) {
        require( _SIGH_NFT_BoostersContract.isCategorySupported(_Boostertype),"SIGH Finance : Not a valid Booster Type");
        available = listOfBoosters[_Boostertype].totalAvailable;
        price = listOfBoosters[_Boostertype].salePrice;
        sold = listOfBoosters[_Boostertype].totalBoostersSold;
    }

    function getTokenAccepted() public view override returns(string memory symbol, address tokenAddress) {
        require( address(tokenAcceptedAsPayment) != address(0) );
        symbol = tokenAcceptedAsPayment.symbol();
        tokenAddress = address(tokenAcceptedAsPayment);
    }

    function getCurrentFundsBalance() public view override returns (uint256) {
        require( address(tokenAcceptedAsPayment) != address(0) );
        return tokenAcceptedAsPayment.balanceOf(address(this));
    }

    function getTokenBalance(address token) public view override returns (uint256) {
        require( token != address(0) );
        ERC20 token_ = ERC20(token);
        uint balance = token_.balanceOf(address(this));
        return balance;
    }


    function addBoosterForSaleInternal(uint256 boosterId) internal {
        require( !boosterIdsForSale[boosterId], "Already Added");
        ( , string memory _BoosterType, , ,) = _SIGH_NFT_BoostersContract.getBoosterInfo(boosterId);

        if (!boosterTypes[_BoosterType]) {
            boosterTypes[_BoosterType] = true;
        }

        listOfBoosters[_BoosterType].boosterIdsList.push( boosterId ); // ADDED the boosterID to the list of Boosters available for sale
        listOfBoosters[_BoosterType].totalAvailable = listOfBoosters[_BoosterType].totalAvailable.add(1); // Incremented total available by 1
        boosterIdsForSale[boosterId] = true;
        require( _SIGH_NFT_BoostersContract.ownerOfBooster(boosterId) == address(this) ); // ONLY SIGH BOOSTERS CAN BE SENT TO THIS CONTRACT

        emit BoosterAddedForSale(_BoosterType , boosterId);
    }

    function transferBoosters(address to, string memory _BoosterType, uint totalBoosters) internal returns (bool) {
        uint listLength = listOfBoosters[_BoosterType].boosterIdsList.length;

        for (uint i=0; i < totalBoosters; i++ ) {
            uint256 _boosterId = listOfBoosters[_BoosterType].boosterIdsList[0];  // current BoosterID

            if (boosterIdsForSale[_boosterId]) {
                _SIGH_NFT_BoostersContract.safeTransferFrom(address(this),to,_boosterId);
                require(to == _SIGH_NFT_BoostersContract.ownerOfBooster(_boosterId),"Booster Transfer failed");

                listOfBoosters[_BoosterType].boosterIdsList[0] = listOfBoosters[_BoosterType].boosterIdsList[listLength.sub(1)];
                listOfBoosters[_BoosterType].boosterIdsList.pop();
                listLength = listLength.sub(1);

                listOfBoosters[_BoosterType].totalAvailable = listOfBoosters[_BoosterType].totalAvailable.sub(1);
                listOfBoosters[_BoosterType].totalBoostersSold = listOfBoosters[_BoosterType].totalBoostersSold.add(1);

                boosterIdsForSale[_boosterId] = false;

                emit BoosterSold(to, _BoosterType, _boosterId, listOfBoosters[_BoosterType].salePrice );
            }
        }
        return true;
    }

    function transferFunds(address from, uint amount) internal returns (bool) {
        uint prevBalance = tokenAcceptedAsPayment.balanceOf(address(this));
        tokenAcceptedAsPayment.transferFrom(from,address(this),amount);
        uint newBalance = tokenAcceptedAsPayment.balanceOf(address(this));
        require(newBalance == prevBalance.add(amount),'Funds Transfer failed');
        return true;
    }


    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory _data) public virtual override returns (bytes4) {
        addBoosterForSaleInternal(tokenId);
        emit BoosterAdded(operator,from,tokenId);
        return this.onERC721Received.selector;
    }
}