



pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}




pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}




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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}




pragma solidity ^0.8.0;



abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}




pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}




pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;




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


pragma solidity 0.8.7;









contract PIXEL_PAWN is ERC20, IERC721Receiver, ERC1155Holder, Ownable, ReentrancyGuard  {
    event SoldToShop721(uint256 indexed txId, address indexed nftAddress, uint256 tokenId, uint256 value);
    event BoughtFromShop721(uint256 indexed txId, address indexed nftAddress, uint256 tokenId, uint256 value);

    event SoldToShop1155(uint256 indexed txId, address indexed nftAddress, uint256 indexed tokenId, uint256 value);
    event BoughtFromShop1155(uint256 indexed txId, address indexed nftAddress, uint256 indexed tokenId, uint256 value);

    struct Status721{
      uint256 reserves; // reserves for the ERC721
    }

    struct Status1155{
      mapping(uint256 => uint256) reserves; // reserves for the ERC1155 specific tokenId
    }

    mapping(address => Status721) _status721;
    mapping(address => Status1155) _status1155;

    mapping(address => bool) public _claimed;

    bytes32 constant public root = 0xb861f2ff2bbffd05e4a8852c7a8a367d91e6117b0cfeb4c76679e9ffe109e4e7;//bytes32(0);

    uint256 constant _reserveSaleMultiplier = 100;
    uint256 constant _reserveDerpMultiplier = 1;
    uint256 constant _reserveBurnMultiplier = 1;
    uint256 constant _reserveAvimeMultiplier = 1;
    uint256 constant _reserveProfitMultiplier = 5;
    uint256 constant _reserveBuyMultiplier = 108;
    uint256 constant _reserveDivisor = 2500;

    address constant _derpAddress = 0xF7a26a24eb5dd146Ea00D7fC9dC4Ec1c474eeF03; //DerpDAO Address
    address constant _avimeFusionAddress = 0xd92Cc219AcF2199DeadAC2b965B35B9e84FA7F0A; // Avime Fusion Address
    uint256 _txId = 1;
    uint256 _claimTotal = 0;
    uint8 _lockGeneration = 0;

    string constant _reserveFailed = "PAWN Transfer Failed";
    string constant _priceTooHigh = "Buy price higher than max price";
    string constant _priceTooLow = "Sell price lower than min price";

    uint256 constant initialSupply = 1*(10**27);

    constructor() ERC20("Pixel Pawn", "PAWN") {
        _mint(msg.sender, initialSupply);
    }

    receive() external payable {}
    fallback() external payable {}

    function deposit() public payable {

    }

    function withdraw(uint256 amount) public onlyOwner {
      (bool success, ) = payable(msg.sender).call{value: amount}("");
      require(success);
    }

    function lockGeneration(uint8 lock) public onlyOwner{
      require(lock == 1);
      _lockGeneration = 1;
    }

    function get721Reserves(address contractAddress) public view  returns(uint256){
      return _status721[contractAddress].reserves;
    }

    function get721BuyPrice(address contractAddress) public view returns(uint256){
      return _status721[contractAddress].reserves*_reserveBuyMultiplier/_reserveDivisor;
    }

    function get721SellPrice(address contractAddress) public view returns(uint256){
      return _status721[contractAddress].reserves*_reserveSaleMultiplier/_reserveDivisor;
    }

    function get1155Reserves(address contractAddress, uint256 tokenId) public view returns(uint256){
      return _status1155[contractAddress].reserves[tokenId];
    }

    function get1155BuyPrice(address contractAddress, uint256 tokenId) public view returns(uint256){
      return _status1155[contractAddress].reserves[tokenId]*_reserveBuyMultiplier/_reserveDivisor;
    }

    function get1155SellPrice(address contractAddress, uint256 tokenId) public view returns(uint256){
      return _status1155[contractAddress].reserves[tokenId]*_reserveSaleMultiplier/_reserveDivisor;
    }

    function generate721Reserves(address[] calldata contractAddresses, uint256[] calldata amount) public onlyOwner{
      require(_lockGeneration == 0, "L");
      uint256 totalAmount = 0;
      uint i = 0;
      for(i=0; i<contractAddresses.length; i++){
        totalAmount += amount[i];
        _status721[contractAddresses[i]].reserves+= amount[i];
      }
      _mint(address(this), totalAmount);
    }

    function generate1155Reserves(address[] calldata contractAddresses, uint256[] calldata tokenIds, uint256[] calldata amount) public onlyOwner{
      require(_lockGeneration == 0, "L");
      uint256 totalAmount = 0;
      uint i = 0;
      for(i=0; i<contractAddresses.length; i++){
        totalAmount += amount[i];
        _status1155[contractAddresses[i]].reserves[tokenIds[i]]+= amount[i];
      }
      _mint(address(this), totalAmount);
    }

    function add721Reserve(address contractAddress, uint256 amount) public returns (bool){
      _transfer(msg.sender, address(this), amount);
      _status721[contractAddress].reserves += amount;
      return true;
    }

    function add1155Reserve(address contractAddress, uint256 tokenId, uint256 amount) public returns (bool){
      _transfer(msg.sender, address(this), amount);
      _status1155[contractAddress].reserves[tokenId] += amount;
      return true;
    }


    function onERC721Received( address operator, address from, uint256 tokenId, bytes calldata data ) public virtual nonReentrant override returns (bytes4) {
        uint256 salePrice = _status721[msg.sender].reserves*_reserveSaleMultiplier/_reserveDivisor;
        uint256 minPrice = abi.decode(data, (uint256));
        require(salePrice >= minPrice, _priceTooLow);
        _status721[msg.sender].reserves -= salePrice;
        _transfer(address(this), from , salePrice);
        emit SoldToShop721(_txId, msg.sender, tokenId, salePrice);
        _txId +=1;
        return this.onERC721Received.selector;
    }


    function onERC1155Received(address operator, address from, uint256 tokenId, uint256 value, bytes calldata data) public virtual nonReentrant override returns (bytes4) {
        require(value == 1, "One token at a time!");
        uint256 salePrice = _status1155[msg.sender].reserves[tokenId]*_reserveSaleMultiplier/_reserveDivisor;
        uint256 minPrice = abi.decode(data, (uint256));
        require(salePrice >= minPrice, _priceTooLow);
        _status1155[msg.sender].reserves[tokenId] -= salePrice;
        _transfer(address(this), from , salePrice);
        emit SoldToShop1155(_txId, msg.sender, tokenId , salePrice);
        _txId +=1;
        return this.onERC1155Received.selector;
    }

    function buy721(address nftAddress, uint256 tokenId, uint256 maxPrice) public nonReentrant {
        uint256 buyPrice = _status721[nftAddress].reserves*_reserveBuyMultiplier/_reserveDivisor;
        require(buyPrice <= maxPrice, _priceTooHigh);
        _transfer(msg.sender, address(this), buyPrice);
        _status721[_derpAddress].reserves += _status721[nftAddress].reserves*(_reserveDerpMultiplier)/_reserveDivisor;
        _status721[_avimeFusionAddress].reserves += _status721[nftAddress].reserves*(_reserveAvimeMultiplier)/_reserveDivisor;
        _burn(address(this),_status721[nftAddress].reserves*(_reserveBurnMultiplier)/_reserveDivisor);
        _status721[nftAddress].reserves += _status721[nftAddress].reserves*(_reserveSaleMultiplier+_reserveProfitMultiplier)/_reserveDivisor;
        IERC721(nftAddress).safeTransferFrom(address(this), msg.sender ,tokenId);
        emit BoughtFromShop721(_txId, nftAddress, tokenId, buyPrice);
        _txId +=1;
    }

    function buy1155(address nftAddress, uint256 tokenId, uint256 maxPrice) public nonReentrant{
        uint256 buyPrice = _status1155[nftAddress].reserves[tokenId]*_reserveBuyMultiplier/_reserveDivisor;
        require(buyPrice <= maxPrice, _priceTooHigh);
        _transfer(msg.sender, address(this), buyPrice);
        _status721[_derpAddress].reserves += _status1155[nftAddress].reserves[tokenId]*(_reserveDerpMultiplier)/_reserveDivisor;
        _status721[_avimeFusionAddress].reserves += _status1155[nftAddress].reserves[tokenId]*(_reserveAvimeMultiplier)/_reserveDivisor;
        _burn(address(this), _status1155[nftAddress].reserves[tokenId]*(_reserveBurnMultiplier)/_reserveDivisor);
        _status1155[nftAddress].reserves[tokenId] += _status1155[nftAddress].reserves[tokenId]*(_reserveSaleMultiplier+_reserveProfitMultiplier)/_reserveDivisor;
        IERC1155(nftAddress).safeTransferFrom(address(this), msg.sender, tokenId, 1,"");
        emit BoughtFromShop1155(_txId, nftAddress, tokenId, buyPrice);
        _txId +=1;
    }

    function claim(uint256 amount, bytes32[] calldata proof) external {
        require(block.number < 14612300, "Claim has ended"); // apr 17 2022
        require(_claimed[msg.sender] == false, "Already Claimed!");
        _claimed[msg.sender] = true;
        require(_verify(_leaf(msg.sender, amount), proof), "Invalid proof");
        amount = amount*10**18; // add the zeros
        if(_claimTotal < 10000)
          _mint(msg.sender, amount*125/100);
        else
          _mint(msg.sender, amount);
        _claimTotal +=1;
    }

    function _leaf(address account, uint256 amount) internal pure returns (bytes32){
        return keccak256(abi.encodePacked(account, amount));
    }

    function _verify(bytes32 leaf, bytes32[] memory proof) internal pure returns (bool){
        return MerkleProof.verify(proof, root, leaf);
    }

}