
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
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// contracts/F3K721.sol

pragma solidity ^0.8.0;

interface F3K1155 {

    function mint(address to, uint256 amountToMint) external;


    function nextTokenId() external view returns (uint256);

    
    function balanceOf(address account, uint256 id) external view returns (uint256);


    function burnToken(address account, uint256 id, uint256 value) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

}// contracts/F3K721.sol

pragma solidity ^0.8.0;

interface F3K721 {

    function mintTokens(address to, uint256 count) external;


    function setBaseURI(string calldata newbaseURI) external;


    function nextTokenId() external view returns (uint256);

}// MIT

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
}// contracts/F3kControl.sol

pragma solidity ^0.8.0;


contract Fantasy3KControl is ReentrancyGuard, Ownable {


    using Address for address;
    event BlindBoxPriceChanged(uint256 _epicBoxPrice, uint256 _LegendBoxPrice);
    event SaleConfigChanged (uint256 round, uint256 start, uint256 end, uint256 number, uint256 epicNumber, uint256 epicBoxPrice, uint256 legendNumber, uint256 legendBoxPrice);
    event AddWhiteList(address[] whitelist);
    event WhiteBlindBox(address to);
    event EpicBlindBox(address to);
    event LegendBlindBox(address to);
    event PayeeAdded(address account, uint256 shares_);
    event PaymentReceived(address account, uint256 amount);
    event OpenBlindBox(uint256 id);
    event MintTokens(address to, uint256 count, uint256 mtype);
    event SaleStarted();
    event SalePaused();
    event MerkleRootChanged(bytes32 merkleRoot);

    struct SaleConfig {
        uint256 round;
        uint256 startTime;
        uint256 endTime;
        uint256 whiteNumber;
        uint256 epicNumber;
        uint256 epicBoxPrice;
        uint256 legendNumber;
        uint256 legendBoxPrice;
        uint256 whiteBoxPrice;
    }

    struct BoxIdx {
        uint256 _id;
        address _address;
        uint256 _round;
        uint256 _amount;
        uint256 _height;
    }

    struct OpenBoxIdx {
        uint256 _burnId;
        uint256 _start;
        uint256 _end;
        uint256 _height;
    }

    bytes32 public merkleRoot;
    uint256 private immutable whiteListPrice = 0.5 ether; 
    bool public _isSaleActive = false;
    bool public isWhiteListActive = false;
    bool public isOpenActive = false;
    uint256 public boxLength;
    uint256 public openboxLength;
    F3K721 private f3k721;
    F3K1155 private f3k1155;

    mapping (address => bool) public whiteList;
    mapping (address => bool) private top10List;
    mapping (uint256 => BoxIdx) boxIdxs;
    mapping (uint256 => OpenBoxIdx) openBoxIdxs;
    mapping (bytes32 => bool) public activity;

    address public f3kVault;
    SaleConfig public saleConfig;

    constructor(
        address _f3k721,
        address _f3k1155,
        address _f3kVault
    ) {
        f3k721 = F3K721(_f3k721);
        f3k1155 = F3K1155(_f3k1155);
        f3kVault = _f3kVault;
    }

    function startSale() external onlyOwner {

        require(!_isSaleActive, 'Fantasy3k: Public sale is already began');
        _isSaleActive = true;
        emit SaleStarted();
    }

    function pauseSale() external onlyOwner {

        require(_isSaleActive, 'Fantasy3k: Public sale is already paused');
        _isSaleActive = false;
        emit SalePaused();
    }

    function setIsWhiteListActive(bool _isAllowListActive) external onlyOwner {

        isWhiteListActive = _isAllowListActive;
    }

    function setIsOpenActive(bool _isAllowOpen) external onlyOwner {

        isOpenActive = _isAllowOpen;
    }

    function setBaseURI(string calldata newbaseURI) external onlyOwner {

        f3k721.setBaseURI(newbaseURI);
    }
    
    function addWhiteList(address[] memory whitelist) public onlyOwner {


        require(whitelist.length == 40, "Fantasy3K: incorrect whiteList length");

        for (uint64 i; i < whitelist.length; i++){
               whiteList[whitelist[i]] = true;
        }
    
        emit AddWhiteList(whitelist);
    }

    function whiteListAirDrop(address[] memory droplist, uint32[] memory number) public onlyOwner {


        require(droplist.length == 50, "Fantasy3K: incorrect droplist airdrop length");
        require(droplist.length == number.length, "Fantasy3K: incorrect droplist or number length");

        for (uint64 i; i < droplist.length; i++){
            if (number[i] > 1) {
                boxUpdate(f3k1155.nextTokenId(), droplist[i], 0, 6);
                f3k1155.mint(droplist[i], 6);
            } else {
                f3k721.mintTokens(droplist[i], 1);
            }
        }
    }

    function whiteBlindBox() public payable {

        SaleConfig memory _saleConfig = saleConfig;

        require(isWhiteListActive, "Fantasy3K: white list is not active");
        require(_saleConfig.whiteNumber  > 0, "Fantasy3K: whiteBlindBox has sold out");
        require(whiteListPrice == msg.value, "Fantasy3K: incorrect Ether value");
        require(whiteList[msg.sender] == true, "Fantasy3K: not whitelist address");
        require(block.timestamp < _saleConfig.endTime, "Fantasy3K: whitelist sale is end"); 

        boxUpdate(f3k1155.nextTokenId(), msg.sender, 0, 6);

        saleConfig.whiteNumber -= 1;

        f3k1155.mint(msg.sender, 6);
        whiteList[msg.sender] = false;
        emit WhiteBlindBox(msg.sender);
    }

    function epicBlindBox() public payable {

        SaleConfig memory _saleConfig = saleConfig;

        require(_isSaleActive, 'Fantasy3K: sale must be active');
        require(_saleConfig.round  > 0, "Fantasy3K: epicBlindBox has not started");
        require(_saleConfig.epicBoxPrice == msg.value, "Fantasy3K: incorrect Ether value");
        require(_saleConfig.epicNumber  > 0, "Fantasy3K: epicBlindBox has sold out");
        require(block.timestamp >= _saleConfig.startTime, "Fantasy3K: sale not started");
        require(block.timestamp < _saleConfig.endTime, "Fantasy3K: sale is end");
        require(!msg.sender.isContract(), "Fantasy3K: caller can't be a contract");

        saleConfig.epicNumber -= 1;

        boxUpdate(f3k1155.nextTokenId(), msg.sender, _saleConfig.round, 5);

        f3k1155.mint(msg.sender, 5);

        emit EpicBlindBox(msg.sender);      
    }

    function legendBlindBox() public payable {

        SaleConfig memory _saleConfig = saleConfig;

        require(_isSaleActive, 'Fantasy3K: sale must be active');
        require(_saleConfig.round  > 0, "Fantasy3K: legendBlindBox has not started");
        require(_saleConfig.legendBoxPrice == msg.value, "Fantasy3K: incorrect Ether value");
        require(_saleConfig.legendNumber > 0, "Fantasy3K: legendBlindBox has sold out");
        require(block.timestamp >= _saleConfig.startTime, "Fantasy3K: sale not started");
        require(block.timestamp < _saleConfig.endTime, "Fantasy3K: sale is end");
        require(!msg.sender.isContract(), "Fantasy3K: caller can't be a contract");

        saleConfig.legendNumber -= 1;
        boxUpdate(f3k1155.nextTokenId(), msg.sender, _saleConfig.round, 50);

        f3k1155.mint(msg.sender, 50);
        emit LegendBlindBox(msg.sender);
    }


    function openBlindBox(uint256 id) public {

        require(isOpenActive, 'Fantasy3K: Open box not active');
        require(f3k1155.balanceOf(msg.sender, id) > 0, "Doesn't own the token"); 
        
        uint256 fromBalance = f3k1155.balanceOf(msg.sender, id);

        f3k1155.burnToken(msg.sender, id, fromBalance);

        nftUpdate(id, f3k721.nextTokenId(), f3k721.nextTokenId() + fromBalance);

        f3k721.mintTokens(msg.sender, fromBalance); 
        emit OpenBlindBox(id);
    }



    function nftUpdate(uint256 burnId, uint256 start, uint256 end) private {

        uint256 _openBoxLength = openboxLength;

        openBoxIdxs[_openBoxLength] = OpenBoxIdx({
            _burnId: burnId, 
            _start: start, 
            _end: end, 
            _height: block.number});

        openboxLength++;
    }

    function boxUpdate(uint256 id, address to, uint256 round, uint256 amount) private {

        uint256 _boxLength = boxLength;

        boxIdxs[_boxLength] = BoxIdx({
            _id: id, 
            _address: to, 
            _round: round, 
            _amount: amount,
            _height: block.number});

        boxLength += 1;

    }

    function getBoxMap(uint256 index) public view returns(uint256 id, address addr, uint256 round, uint256 amount, uint256 height){

        BoxIdx memory b = boxIdxs[index];
        return (b._id, b._address, b._round, b._amount, b._height);
    }

    function getOpenBoxMap(uint256 index) public view returns(uint256 burnId, uint256 start, uint256 end, uint256 height){

        OpenBoxIdx memory b = openBoxIdxs[index];
        return (b._burnId, b._start, b._end, b._height);
    }

    function setUpSale(
        uint256 round, 
        uint256 start, 
        uint256 end, 
        uint256 whiteNumber, 
        uint256 epicNumber, 
        uint256 epicBoxPrice,
        uint256 legendNumber,
        uint256 legendBoxPrice
    ) external onlyOwner {

        uint256 _round = round;
        uint256 _startTime = start;
        uint256 _endTime = end;
        uint256 _whiteNumber = whiteNumber;
        uint256 _epicNumber = epicNumber;
        uint256 _epicBoxPrice = epicBoxPrice;
        uint256 _legendNumber = legendNumber;
        uint256 _legendBoxPrice = legendBoxPrice;
        if (_round > 0) {
            require(_epicNumber > 0 && _legendNumber > 0, "Fantasy3k: zero amount");
        }
        require(start > 0 && _endTime > _startTime, "Fantasy3k: invalid time range");

        saleConfig = SaleConfig({
            round: _round,
            startTime: _startTime,
            endTime: _endTime,
            whiteNumber: _whiteNumber,
            epicNumber: _epicNumber,
            epicBoxPrice: _epicBoxPrice,
            legendNumber: _legendNumber,
            legendBoxPrice: _legendBoxPrice,
            whiteBoxPrice: whiteListPrice
        });

        emit SaleConfigChanged(_round, _startTime, _endTime, _whiteNumber, _epicNumber, _epicBoxPrice, _legendNumber, _legendBoxPrice);
    }

    function merkleCheck(bytes32 leaf, bytes32[] calldata merkleProof) view public returns (bool, bool) {

        bool valid = MerkleProof.verify(merkleProof, merkleRoot, leaf);
        return (valid, activity[leaf]);
    }

    function cooperativeSales(uint256 around, uint256[] memory round, uint256[] memory count, 
    uint256 mtype, uint256[] memory idx, bytes32[][] calldata merkleProof) public {


        for (uint256 i; i < count.length; i++) {
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender, around, round[i], count[i], mtype, idx[i]));
            require(!activity[leaf], "Fantasy: leaf already participate");
            bool valid = MerkleProof.verify(merkleProof[i], merkleRoot, leaf);
            require(valid, "Fantasy: Valid proof required.");
            if (mtype == 1155){
                boxUpdate(f3k1155.nextTokenId(), msg.sender, round[i], count[i]);
                f3k1155.mint(msg.sender, count[i]);
            }else if (mtype == 721) {
                f3k721.mintTokens(msg.sender, count[i]);
            }
            activity[leaf] = true;
        }
    }


    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {

        merkleRoot = _merkleRoot;
        emit MerkleRootChanged(_merkleRoot);
    }

    function setF3K721Contract(address _f3k721New) external onlyOwner {

        f3k721 = F3K721(_f3k721New);
    }

    function setF3K1155Contract(address _f3k1155New) external onlyOwner {

        f3k1155 = F3K1155(_f3k1155New);
    }

    function setVaultAddress(address _f3kVault) external onlyOwner {

        f3kVault = _f3kVault;
    }

    function withdraw() nonReentrant external {

        Address.sendValue(payable(f3kVault), address(this).balance);
    }

    receive() external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }
}