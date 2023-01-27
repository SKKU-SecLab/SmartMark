
pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

pragma solidity ^0.5.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.5.0;


library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}

pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}
pragma solidity ^0.5.0;

interface DGXinterface {

function showTransferConfigs()
 external
  returns (uint256 _base, uint256 _rate, address _collector, bool _no_transfer_fee, uint256 _minimum_transfer_amount);

function showDemurrageConfigs()
  external
  returns (uint256 _base, uint256 _rate, address _collector, bool _no_demurrage_fee);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
function read_user(address _account)
        external
    returns (
        bool _exists,
        uint256 _raw_balance,
        uint256 _payment_date,
        bool _no_demurrage_fee,
        bool _no_recast_fee,
        bool _no_transfer_fee
    );


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.0;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}
pragma solidity ^0.5.0;


contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}
pragma solidity ^0.5.0;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}
pragma solidity ^0.5.0;


contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}

pragma solidity ^0.5.0;

contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => Counters.Counter) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

pragma solidity ^0.5.0;


contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {

        return _ownedTokens[owner];
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {


        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        _ownedTokens[from].length--;

    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {


        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}

pragma solidity ^0.5.0;


contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}
pragma solidity ^0.5.0;


contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {

    string private _name;

    string private _symbol;

    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

pragma solidity ^0.5.0;


contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
    }
}
pragma solidity ^0.5.0;



contract ERC721MetadataMintable is ERC721, ERC721Metadata {

    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) internal  returns (bool) {

        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return true;
    }
}

pragma solidity ^0.5.0;


contract ERC721Burnable is ERC721 {

    function burn(uint256 tokenId) internal {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}
pragma solidity >=0.4.22 <0.6.0;



contract BullionixGenerator is
    ERC721Enumerable,
    ERC721MetadataMintable,
    ERC721Burnable,
    Ownable
{

    modifier isActive {

        require(isOnline == true);
        _;
    }
    using SafeMath for uint256;
    DGXinterface dgx;
    DGXinterface dgxStorage;
    DGXinterface dgxToken;
    bool public isOnline = false;
    address payable public DGXTokenContract = 0x4f3AfEC4E5a3F2A6a1A411DEF7D7dFe50eE057bF;
    address payable public DGXContract = 0xBB246ee3FA95b88B3B55A796346313738c6E0150; //To be filled in
    address payable public DGXTokenStorage = 0xC672EC9CF3Be7Ad06Be4C5650812aEc23BBfB7E1; //To be filled in
    string constant name = "Bullionix";
    string constant title = "Bullionix"; //To be filled in
    string constant symbol = "BLX"; //To be filled in
    string constant version = "Bullionix v0.2";
    mapping(uint256 => uint256) public StakedValue;
    mapping(uint256 => seriesData) public seriesToTokenId;
    uint256 public totalSeries = 0;
    uint256 public totalFeesCollected = 0;
    struct seriesData {
        string url;
        uint256 numberInSeries;
        uint256 DGXcost;
        uint256 fee;
        bool alive;
    }
    event NewSeriesMade(string indexed url, uint256 indexed numberToMint);
    event Staked(address indexed _sender, uint256 _amount, uint256 tokenStaked);
    event Burned(address indexed _sender, uint256 _amount, uint256 _tokenId);
    event Withdrawal(address indexed _receiver, uint256 indexed _amount);
    event TransferFee(uint256 indexed transferFee);
    event DemurrageFee(uint256 indexed demurrageFee);
    event CheckFees(
        uint256 indexed feeValue,
        uint256 indexed stakedValue,
        uint256 indexed _totalWithdrawal
    );

    constructor() public ERC721Metadata(name, symbol) {
        if (
            address(DGXContract) != address(0x0) &&
            address(DGXTokenStorage) != address(0x0)
        ) {
            isOnline = true;
            dgx = DGXinterface(DGXContract);
            dgxStorage = DGXinterface(DGXTokenStorage);
            dgxToken = DGXinterface(DGXTokenContract);
        }
    }

    function toggleOnline() external onlyOwner {

        isOnline = !isOnline;
    }
    function createNewSeries(
        string memory _url,
        uint256 _numberToMint,
        uint256 _DGXcost,
        uint256 _fee
    ) public onlyOwner isActive returns (bool _success) {

        require(msg.sender == owner(), "Only Owner"); //optional as onlyOwner Modifier is used
        uint256 total = totalSeries;
        uint256 tempNumber = _numberToMint.add(totalSeries);
        for (uint256 i = total; i < tempNumber; i++) {
            seriesToTokenId[i].url = _url;
            seriesToTokenId[i].numberInSeries = _numberToMint;
            seriesToTokenId[i].DGXcost = _DGXcost;
            seriesToTokenId[i].fee = _fee;
            totalSeries = totalSeries.add(1);
        }

        emit NewSeriesMade(_url, _numberToMint);
        return true;
    }

    function stake(uint256 _tokenToBuy) public payable isActive returns (bool) {

        require(
            seriesToTokenId[_tokenToBuy].fee >= 0 &&
                StakedValue[_tokenToBuy] == 0,
            "Can't stake to this token!"
        );
        uint256 amountRequired = (
            (
                seriesToTokenId[_tokenToBuy].DGXcost.add(
                    seriesToTokenId[_tokenToBuy].fee
                )
            )
        );
        uint256 transferFee = fetchTransferFee(amountRequired);
        uint256 adminFees = seriesToTokenId[_tokenToBuy].fee.sub(transferFee);
        totalFeesCollected = totalFeesCollected.add(adminFees);
        uint256 demurageFee = fetchDemurrageFee(msg.sender);
        uint256 totalFees = transferFee.add(demurageFee);
        amountRequired = amountRequired.sub(totalFees);
        require(
            _checkAllowance(msg.sender, amountRequired),
            "Not enough allowance"
        );
        require(
            _transferFromDGX(msg.sender, amountRequired),
            "Transfer DGX failed"
        );
        string memory fullURL = returnURL(_tokenToBuy);

        emit CheckFees(
            totalFees,
            amountRequired,
            (
                (
                    seriesToTokenId[_tokenToBuy].DGXcost.add(
                        seriesToTokenId[_tokenToBuy].fee
                    )
                )
            )
        );
        require(amountRequired > totalFees, "Math invalid");
        require(
            mintWithTokenURI(msg.sender, _tokenToBuy, fullURL),
            "Minting NFT failed"
        );
        StakedValue[_tokenToBuy] = amountRequired;
        emit Staked(msg.sender, StakedValue[_tokenToBuy], _tokenToBuy);
        seriesToTokenId[_tokenToBuy].alive = true;
        return true;
    }


    function burnStake(uint256 _tokenId) public payable returns (bool) {


        require(
            StakedValue[_tokenId] > 0 && seriesToTokenId[_tokenId].alive,
            "NFT not burnable yet"
        );
        require(
            _isApprovedOrOwner(msg.sender, _tokenId),
            "ERC721Burnable: caller is not owner nor approved"
        );
        uint256 transferFee = fetchTransferFee(StakedValue[_tokenId]);
        uint256 demurrageFee = fetchDemurrageFee(address(this));
        uint256 feeValue = transferFee.add(demurrageFee);
        require(
            feeValue < StakedValue[_tokenId],
            "Fee is more than StakedValue"
        );
        uint256 UserWithdrawal = StakedValue[_tokenId].sub(feeValue);
        UserWithdrawal = UserWithdrawal.sub((seriesToTokenId[_tokenId].fee));
        require(_checkBalance() >= UserWithdrawal, "Balance check failed");
        seriesToTokenId[_tokenId].alive = false;
        _burn(_tokenId);
        require(dgxToken.transfer(msg.sender, UserWithdrawal));
        emit Burned(msg.sender, UserWithdrawal, _tokenId);
        return true;
    }

    function checkFeesForBurn(uint256 _tokenId)
        public
        payable
        returns (uint256)
    {

        uint256 transferFee = fetchTransferFee(
            (
                seriesToTokenId[_tokenId].DGXcost.add(
                    seriesToTokenId[_tokenId].fee
                )
            )
        );
        uint256 demurrageFee = fetchDemurrageFee(address(this));
        uint256 feeValue = transferFee.add(demurrageFee);

        uint256 UserWithdrawal = (
            (
                seriesToTokenId[_tokenId].DGXcost.add(
                    seriesToTokenId[_tokenId].fee
                )
            )
                .sub(feeValue)
        );
        UserWithdrawal = UserWithdrawal.sub((seriesToTokenId[_tokenId].fee));
        emit CheckFees(
            feeValue,
            (
                seriesToTokenId[_tokenId].DGXcost.add(
                    seriesToTokenId[_tokenId].fee
                )
            ),
            UserWithdrawal
        );
    }
    function withdrawal() public onlyOwner returns (bool) {

        require(isOnline == false);
        uint256 temp = _checkBalance(); //calls checkBalance which will revert if no balance, if balance pass it into transfer as amount to withdrawal MAX
        require(
            temp >= totalFeesCollected,
            "Not enough balance to withdrawal the fees collected"
        );
        require(dgxToken.transfer(msg.sender, totalFeesCollected));
        emit Withdrawal(msg.sender, totalFeesCollected);
        totalFeesCollected = 0;
        return true;
    }
    function _checkBalance() internal view returns (uint256) {

        uint256 tempBalance = dgxToken.balanceOf(address(this)); //checking balance on DGX contract
        require(tempBalance > 0, "Revert: Balance is 0!"); //do I even have a balance? Lets see. If no balance revert.
        return tempBalance; //here is your balance! Fresh off the stove.
    }
    function _checkAllowance(address sender, uint256 amountNeeded)
        internal
        view
        returns (bool)
    {

        uint256 tempBalance = dgxToken.allowance(sender, address(this)); //checking balance on DGX contract
        require(tempBalance >= amountNeeded, "Revert: Balance is 0!"); //do I even have a balance? Lets see. If no balance revert.
        return true; //here is your balance! Fresh off the stove.
    }
    function viewYourTokens()
        external
        view
        returns (uint256[] memory _yourTokens)
    {

        return super._tokensOfOwner(msg.sender);
    }
    function setDGXStorage(address payable newAddress)
        external
        onlyOwner
        returns (bool)
    {

        DGXTokenStorage = newAddress;
        dgxStorage = DGXinterface(DGXTokenStorage);
        return true;
    }
    function setDGXContract(address payable newAddress)
        external
        onlyOwner
        returns (bool)
    {

        DGXContract = newAddress;
        dgx = DGXinterface(DGXContract);
        return true;
    }
    function setDGXTokenContract(address payable newAddress)
        external
        onlyOwner
        returns (bool)
    {

        DGXContract = newAddress;
        dgxToken = DGXinterface(DGXContract);
        return true;
    }

    function returnURL(uint256 _tokenId)
        internal
        view
        returns (string memory _URL)
    {

        require(
            checkURL(_tokenId),
            "ERC721: approved query for nonexistent token"
        ); //Does this token exist? Lets see.
        string memory uri = seriesToTokenId[_tokenId].url;
        return string(abi.encodePacked("https://app.bullionix.io/metadata/", uri)); //Here is your URL!
    }

    function checkURL(uint256 _tokenId) internal view returns (bool) {

        string memory temp = seriesToTokenId[_tokenId].url;
        bytes memory tempEmptyStringTest = bytes(temp);
        require(tempEmptyStringTest.length >= 1, temp);
        return true;
    }
    function _transferFromDGX(address _owner, uint256 _amount)
        internal
        returns (bool)
    {

        require(dgxToken.transferFrom(_owner, address(this), _amount));
        return true;
    }

    function fetchTransferFee(uint256 _amountToBeTransferred)
        internal
        returns (uint256 rate)
    {

        (uint256 _base, uint256 _rate, address _collector, bool _no_transfer_fee, uint256 _minimum_transfer_amount) = dgx
            .showTransferConfigs();
        if (_no_transfer_fee) {
            return 0;
        }
        emit TransferFee(_rate.mul(_amountToBeTransferred).div(_base));
        return _rate.mul(_amountToBeTransferred).div(_base);

    }

    function fetchLastTransfer(address _user)
        internal
        returns (uint256 _payment_date)
    {

        (bool _exists, uint256 _raw_balance, uint256 _payment_date, bool _no_demurrage_fee, bool _no_recast_fee, bool _no_transfer_fee) = dgxStorage
            .read_user(_user);
        require(
            _payment_date >= 0 && _payment_date < block.timestamp,
            "Last payment timestamp is invalid"
        );

        return _payment_date;

    }

    function fetchDemurrageFee(address _sender)
        internal
        returns (uint256 rate)
    {

        (uint256 _base, uint256 _rate, address _collector, bool _no_demurrage_fee) = dgx
            .showDemurrageConfigs();
        if (_no_demurrage_fee) return 0;
        uint256 last_timestamp = fetchLastTransfer(_sender);
        uint256 daysSinceTransfer = block.timestamp.sub(last_timestamp);

        uint256 totalFees = (
            (_rate * 10**8).div(_base).mul(daysSinceTransfer).div(86400)
        );
        emit DemurrageFee(totalFees);
        return totalFees;

    }
    function() external payable {
        revert("Please call a function");
    }
}