


pragma solidity >=0.6.2 <0.8.0;

library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    function supportsERC165(address account) internal view returns (bool) {

        return _supportsERC165Interface(account, _INTERFACE_ID_ERC165) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
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

        (bool success, bool result) = _callERC165SupportsInterface(account, interfaceId);

        return (success && result);
    }

    function _callERC165SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool, bool)
    {

        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_ERC165, interfaceId);
        (bool success, bytes memory result) = account.staticcall{ gas: 30000 }(encodedParams);
        if (result.length < 32) return (false, false);
        return (success, abi.decode(result, (bool)));
    }
}




pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity >=0.6.0 <0.8.0;

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




pragma solidity >=0.6.0 <0.8.0;

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




pragma solidity >=0.6.0 <0.8.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
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




pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}




pragma solidity >=0.6.2 <0.8.0;


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
}




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
}




pragma solidity >=0.6.0 <0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}




pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}




pragma solidity >=0.6.0 <0.8.0;



abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}


pragma solidity >=0.5.0;

interface IUnicFactory {
    event TokenCreated(address indexed caller, address indexed uToken);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getUToken(address uToken) external view returns (uint);
    function uTokens(uint) external view returns (address);
    function uTokensLength() external view returns (uint);

    function createUToken(uint256 totalSupply, uint8 decimals, string calldata name, string calldata symbol, uint256 threshold, string calldata description) external returns (address);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


pragma solidity 0.6.12;








contract Converter is ERC20, ERC1155Receiver {
    using SafeMath for uint;

    struct NFT {
        address contractAddr;
        uint256 tokenId;
        uint256 amount;
        bool claimed;
    }

    struct Bid {
        address bidder;
        uint256 amount;
        uint time;
    }

    mapping(uint256 => NFT) public nfts;
    uint256 public currentNFTIndex = 0;

    bool public active = false;
    uint256 public totalBidAmount = 0;
    uint256 public unlockVotes = 0;
    uint256 public _threshold;
    address public issuer;
    string public _description;
    uint256 public cap;

    mapping(address => uint256) public unlockApproved;

    IUnicFactory public factory;

    mapping(uint256 => Bid) public bids;
    mapping(uint256 => mapping(address => uint256)) public bidRefunds;
    uint public constant TOP_BID_LOCK_TIME = 3 days;

    event Deposited(uint256[] tokenIDs, uint256[] amounts, address contractAddr);
    event Refunded();
    event Issued();
    event BidCreated(address sender, uint256 nftIndex, uint256 bidAmount);
    event BidRemoved(address sender, uint256 nftIndex);
    event ClaimedNFT(address winner, uint256 nftIndex, uint256 tokenId);

    bytes private constant VALIDATOR = bytes('JCMY');

    constructor (uint256 totalSupply, uint8 decimals, string memory name, string memory symbol, uint256 threshold, string memory description, address _issuer, IUnicFactory _factory)
        public
        ERC20(name, symbol)
    {
        _setupDecimals(decimals);
        issuer = _issuer;
        _description = description;
        _threshold = threshold;
        factory = _factory;
        cap = totalSupply;
    }

    function deposit(uint256[] calldata tokenIDs, uint256[] calldata amounts, address contractAddr) external {
        require(msg.sender == issuer, "Converter: Only issuer can deposit");
        require(tokenIDs.length <= 50, "Converter: A maximum of 50 tokens can be deposited in one go");
        require(tokenIDs.length > 0, "Converter: You must specify at least one token ID");

        if (ERC165Checker.supportsInterface(contractAddr, 0xd9b67a26)){
            IERC1155(contractAddr).safeBatchTransferFrom(msg.sender, address(this), tokenIDs, amounts, VALIDATOR);

            for (uint8 i = 0; i < 50; i++){
                if (tokenIDs.length == i){
                    break;
                }
                nfts[currentNFTIndex++] = NFT(contractAddr, tokenIDs[i], amounts[i], false);
            }
        }
        else if (ERC165Checker.supportsInterface(contractAddr, 0x80ac58cd)){
            for (uint8 i = 0; i < 50; i++){
                if (tokenIDs.length == i){
                    break;
                }
                IERC721(contractAddr).transferFrom(msg.sender, address(this), tokenIDs[i]);
                nfts[currentNFTIndex++] = NFT(contractAddr, tokenIDs[i], 1, false);
            }
        }

        emit Deposited(tokenIDs, amounts, contractAddr);
    }

    function issue() external {
        require(msg.sender == issuer, "Converter: Only issuer can issue the tokens");
        require(active == false, "Converter: Token is already active");

        active = true;
        address feeTo = factory.feeTo();
        uint256 feeAmount = 0;
        if (feeTo != address(0)) {
            feeAmount = cap.div(200);
            _mint(feeTo, feeAmount);
        }

        _mint(issuer, cap - feeAmount);

        emit Issued();
    }

    function refund(address _to) external {
        require(!active, "Converter: Contract is already active - cannot refund");
        require(msg.sender == issuer, "Converter: Only issuer can refund");

        uint8 _i = 0;
        uint256 _index = currentNFTIndex;
        bytes memory data;

        while (_index > 0 && _i < 50){
            NFT memory nft = nfts[_index - 1];

            if (ERC165Checker.supportsInterface(nft.contractAddr, 0xd9b67a26)){
                IERC1155(nft.contractAddr).safeTransferFrom(address(this), _to, nft.tokenId, nft.amount, data);
            }
            else if (ERC165Checker.supportsInterface(nft.contractAddr, 0x80ac58cd)){
                IERC721(nft.contractAddr).safeTransferFrom(address(this), _to, nft.tokenId);
            }

            delete nfts[_index - 1];

            _index--;
            _i++;
        }

        currentNFTIndex = _index;

        emit Refunded();
    }

    function bid(uint256 nftIndex) external payable {
        require(unlockVotes < _threshold, "Converter: Release threshold has been met, no more bids allowed");
        Bid memory topBid = bids[nftIndex];
        require(topBid.bidder != msg.sender, "Converter: You have an active bid");
        require(topBid.amount < msg.value, "Converter: Bid too low");
        require(bidRefunds[nftIndex][msg.sender] == 0, "Converter: Collect bid refund");

        bids[nftIndex] = Bid(msg.sender, msg.value, getBlockTimestamp());
        bidRefunds[nftIndex][topBid.bidder] = topBid.amount;
        totalBidAmount += msg.value - topBid.amount;

        emit BidCreated(msg.sender, nftIndex, msg.value);
    }

    function unbid(uint256 nftIndex) external {
        Bid memory topBid = bids[nftIndex];
        bool isTopBidder = topBid.bidder == msg.sender;
        if (unlockVotes >= _threshold) {
            require(!isTopBidder, "Converter: Release threshold has been met, winner can't unbid");
        }

        if (isTopBidder) {
            require(topBid.time + TOP_BID_LOCK_TIME < getBlockTimestamp(), "Converter: Top bid locked");
            totalBidAmount -= topBid.amount;
            bids[nftIndex] = Bid(address(0), 0, getBlockTimestamp());
            (bool sent, bytes memory data) = msg.sender.call{value: topBid.amount}("");
            require(sent, "Converter: Failed to send Ether");

            emit BidRemoved(msg.sender, nftIndex);
        }
        else { 
            uint256 refundAmount = bidRefunds[nftIndex][msg.sender];
            require(refundAmount > 0, "Converter: no bid found");
            bidRefunds[nftIndex][msg.sender] = 0;
            (bool sent, bytes memory data) = msg.sender.call{value: refundAmount}("");
            require(sent, "Converter: Failed to send Ether");
        }
    }

    function claim(uint256 nftIndex) external {
        require(unlockVotes >= _threshold, "Converter: Threshold not met");
        require(!nfts[nftIndex].claimed, "Converter: Already claimed");
        Bid memory topBid = bids[nftIndex];
        require(msg.sender == topBid.bidder, "Converter: Only winner can claim");

        nfts[nftIndex].claimed = true;
        NFT memory winningNFT = nfts[nftIndex];

        if (ERC165Checker.supportsInterface(winningNFT.contractAddr, 0xd9b67a26)){
            bytes memory data;
            IERC1155(winningNFT.contractAddr).safeTransferFrom(address(this), topBid.bidder, winningNFT.tokenId, winningNFT.amount, data);
        }
        else if (ERC165Checker.supportsInterface(winningNFT.contractAddr, 0x80ac58cd)){
            IERC721(winningNFT.contractAddr).safeTransferFrom(address(this), topBid.bidder, winningNFT.tokenId);
        }

        emit ClaimedNFT(topBid.bidder, nftIndex, winningNFT.tokenId);
    }

    function approveUnlock(uint256 amount) external {
        require(unlockVotes < _threshold, "Converter: Threshold reached");
        _transfer(msg.sender, address(this), amount);

        unlockApproved[msg.sender] += amount;
        unlockVotes += amount;
    }

    function unapproveUnlock(uint256 amount) external {
        require(unlockVotes < _threshold, "Converter: Threshold reached");
        require(unlockApproved[msg.sender] >= amount, "Converter: Not enough uTokens locked by user");
        unlockVotes -= amount;
        unlockApproved[msg.sender] -= amount;

        _transfer(address(this), msg.sender, amount);
    }

    function redeemETH(uint256 amount) external {
        require(unlockVotes >= _threshold, "Converter: Threshold not met");
        if (amount > 0) {
            _transfer(msg.sender, address(this), amount);
        }
        uint256 finalBalance = amount + unlockApproved[msg.sender];
        unlockApproved[msg.sender] = 0;

        (bool sent, bytes memory data) = msg.sender.call{value: totalBidAmount.mul(finalBalance).div(this.totalSupply())}("");
        require(sent, "Converter: Failed to send Ether");
    }

    function getBlockTimestamp() internal view returns (uint) {
        return block.timestamp;
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) override external returns(bytes4) {
        if(keccak256(_data) == keccak256(VALIDATOR)){
            return 0xf23a6e61;
        }
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) override external returns(bytes4) {
        if(keccak256(_data) == keccak256(VALIDATOR)){
            return 0xbc197c81;
        }
    }

}


pragma solidity 0.6.12;




contract UnicFactory is IUnicFactory {
    using SafeMath for uint;
    
    address public override feeTo;
    
    address public override feeToSetter;
    
    address[] public override uTokens;
    
    mapping(address => uint) public override getUToken;
    
    event TokenCreated(address indexed caller, address indexed uToken);
    
    function uTokensLength() external override view returns (uint) {
        return uTokens.length;
    }
    
    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }
    
    function createUToken(uint256 totalSupply, uint8 decimals, string calldata name, string calldata symbol, uint256 threshold, string calldata description) external override returns (address) {
        require(totalSupply > 0, 'Unic: MIN SUPPLY');
        require(decimals >= 4, 'Unic: MIN PRECISION');
        require(bytes(name).length < 32, 'Unic: MAX NAME');
        require(bytes(symbol).length < 16, 'Unic: MAX TICKER');
        require(threshold > 0 && threshold <= totalSupply, 'Unic: THRESHOLD GREATER THAN SUPPLY');
        require(bytes(description).length < 256, 'Unic: MAX DESCRIPTION');
                
        address issuer = msg.sender;
        Converter converter = new Converter(totalSupply, decimals, name, symbol, threshold, description, issuer, this);
        getUToken[address(converter)] = uTokens.length;
        uTokens.push(address(converter));
        emit TokenCreated(msg.sender, address(converter));
        
        return address(converter);
    }
    
    function setFeeTo(address _feeTo) external override {
        require(msg.sender == feeToSetter, 'Unic: FORBIDDEN');
        feeTo = _feeTo;
    }
    
    function setFeeToSetter(address _feeToSetter) external override {
        require(msg.sender == feeToSetter, 'Unic: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}