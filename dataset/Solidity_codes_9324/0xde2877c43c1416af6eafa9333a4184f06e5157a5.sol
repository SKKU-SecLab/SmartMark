
pragma solidity ^0.8.0;
//pragma experimental ABIEncoderV2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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


interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}


interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}



abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IVcgERC721Token is IERC721Enumerable {

   

    function getBaseTokenURI() external view returns (string memory); 


    function setBaseTokenURI(string memory url) external;


    function tokenURI(uint256 tokenId) external view returns (string memory);


    function isVcgNftToken(address tokenAddress) external view returns(bool);


    function isApprovedOrOwner(address spender, uint256 tokenId) external view returns (bool);


    function exists(uint256 tokenId) external view returns (bool);


}

interface IERC2981 {


    function royaltyInfo(uint256 _tokenId) external view 
    returns (address receiver, uint256 amount);


    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view returns (
        address receiver,
        uint256 royaltyAmount
    );



    function onRoyaltiesReceived(address _royaltyRecipient, address _buyer, uint256 _tokenId, address _tokenPaid, uint256 _amount, bytes32 _metadata) external returns (bytes4);


    event RoyaltiesReceived(
        address indexed _royaltyRecipient,
        address indexed _buyer,
        uint256 indexed _tokenId,
        address _tokenPaid,
        uint256 _amount,
        bytes32 _metadata
    );

}

interface IVcgERC721TokenWithRoyalty is IVcgERC721Token,IERC2981 {

    
}

interface IERC1155 /* is ERC165 */ {

    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);

    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    event URI(string _value, uint256 indexed _id);

    function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;


    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;


    function balanceOf(address _owner, uint256 _id) external view returns (uint256);


    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);


    function setApprovalForAll(address _operator, bool _approved) external;


    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}

interface IVcgERC1155Token is IERC1155 {


    function tokenURI(uint256 tokenId) external view returns (string memory);


    function isVcgNftToken(address tokenAddress) external view returns(bool);


    function approve(address _spender, uint256 _id, uint256 _currentValue, uint256 _value) external;

    
    function allowance(address _owner, address _spender, uint256 _id) external view returns (uint256);


    function isApprovedOrOwner(address owner, address spender, uint256 tokenId,uint256 value) external view returns (bool);


    function exists(uint256 tokenId) external view returns (bool);


    function isOwner(address owner, uint256 tokenId) external view returns (bool);

}


interface ERC1155TokenReceiver {

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);


    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);

}


contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }


    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract Authentication is Ownable {

    address private _owner;
    mapping(address=>bool) _managers;

    constructor() {    
        _owner = msg.sender;
    }

    modifier onlyAuthorized(address target) {

        require(isOwner()||isManager(target),"Only for manager or owner!");
        _;
    }    

    function addManager(address manager) public onlyOwner{    

        _managers[manager] = true;
    }    

    function removeManager(address manager) public onlyOwner{    

        _managers[manager] = false;
    }  

    function isManager(address manager) public view returns (bool) {    

        return(_managers[manager]);
    }             

}    

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

}


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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract Commission is Ownable {

    address private _wallet;
    uint32 private _commissionRate;
    uint256 private _scaling_factor = 100000;//5 decimals

    event WalletChanged(address indexed previousWallet,address indexed currentWallet);
    event CommissionRateChanged(uint32 indexed previousCommissionRate,
        uint32 indexed currentCommissionRate);
    constructor() {    
        _wallet = 0xEA5320a1a80705c81d72d3DD30c483f2a09CeB6c;
        _commissionRate = 5000;
    }
    modifier _validateCommission(
        uint32 comm
    ) {

        require(comm >= 0 && comm <= 30000, "wrong Commission");
        _;
    }

    function setWallet(address payable wallet) public onlyOwner{    

        require(address(0) != wallet, "It's not an invalid wallet address.");
        emit WalletChanged(_wallet,wallet);
        _wallet = wallet; 
    }    

    function setCommissionRate(uint32 commissionRate) public 
        onlyOwner _validateCommission(commissionRate){    

        emit CommissionRateChanged(_commissionRate,commissionRate);
        _commissionRate = commissionRate;      
    }  

    function commissionInfo() public view  
    returns (
        address walletAddr,
        uint32 commissionRate
    ){

      return (_wallet,_commissionRate);
    }             
    function calculateFee(uint256 _num) public view 
        returns (address receiver,uint256 fee){

        if (_num == 0 || _commissionRate == 0){
          return (_wallet,0);
        }
        fee = SafeMath.div(SafeMath.mul(_num, _commissionRate),_scaling_factor);
        return (_wallet,fee);
    }
}   

pragma solidity ^0.8.0;


enum TokenType {ETH, ERC20}
enum StandType {ERC721,ERC1155}
enum BaseContractType {Contract721,Contract1155,Contract20}


contract ExchangeVcgSale is Authentication,Commission,ReentrancyGuardUpgradeable{

    using Strings for string;
    using Address for address;    
    using SafeMath for *;

    string constant public _name = "Exchange contract as ERC721 NFT exchange with ETH or Vcg ERC20 version 1.1";    
    
    struct NftGoods {
        address _nftContractAddress;
        StandType _contractType;
        uint256 _tokenID;
        uint256 _values;
        address payable _sellerAddress;
        uint256 _expectedAmount;
        uint256 _startTime;
    }
    
    mapping(uint256 => NftGoods) private _saleGoodsAddr;//token ID对应的商品合约地址

    event SellAmountDetail(uint256 indexed goodsID,
            uint256 indexed sellerReceived,
            uint256 indexed creatorReceived,
            uint256  platformReceived);
    
    function _onBuy(NftGoods storage goods, uint256 saleTokenID, uint256 value) internal
            returns(bool) {

        require((saleTokenID == goods._tokenID) 
        && (block.timestamp >= goods._startTime) && (goods._values >= value), "Buy Error.");
        goods._values = goods._values.sub(value);//It worked?
        return _isOnSale(goods);
    }
    function _isOnSale(NftGoods memory goods) internal view returns(bool) {

        return((block.timestamp >= goods._startTime)
        && (goods._values > 0) 
        );
    }
    function _isApprovedOrOwner(address nftContractAddress, StandType contractType, address seller, 
        uint256 tokenId, uint256 value) internal view 
        returns (bool) {

        
        if(contractType == StandType.ERC721)
        {
            address owner = IERC721(nftContractAddress).ownerOf(tokenId);   
            return (seller == owner || 
                IERC721(nftContractAddress).getApproved(tokenId) == seller || 
                IERC721(nftContractAddress).isApprovedForAll(owner, seller));
        }
        else if(contractType == StandType.ERC1155)
        {
            return IVcgERC1155Token(nftContractAddress).isApprovedOrOwner(address(0),seller,tokenId,value);
        }
        else
        {
            revert();
        }
    }
    function _offSale(NftGoods memory goods) internal pure { 

        goods._tokenID = 0;
        goods._values = 0;
        goods._sellerAddress = payable(address(0));
        goods._expectedAmount = 0;
        goods._startTime = 0;        
    }
    
    function _onSale(NftGoods storage goods,address ContractAddress,
        uint256 saleTokenID, uint256 value,address payable sellerAddress,
        uint256 amount, uint256 startTime) internal returns (bool) {  

        require(true == Address.isContract(ContractAddress), 
            "ContractAddress is not a contract address!");

        if(IERC721(ContractAddress).supportsInterface(0x80ac58cd))
        {
            goods._nftContractAddress = ContractAddress;
            goods._contractType = StandType.ERC721;
        }
        else if(IERC1155(ContractAddress).supportsInterface(0x0e89341c))
        {
            goods._nftContractAddress = ContractAddress;
            goods._contractType = StandType.ERC1155;
        }
        else
        {
            revert();
        }
        if(sellerAddress == address(0))
        {
            return false;
        }
        if(goods._contractType == StandType.ERC721){
            require(1 == value, "721 Asset value MUST be 1.");
        }

        if(!_isApprovedOrOwner(goods._nftContractAddress,goods._contractType,
            sellerAddress,saleTokenID,value)) 
        {
            return false;
        }   

        goods._tokenID = saleTokenID;
        goods._values = value;
        goods._sellerAddress = sellerAddress;
        goods._expectedAmount = amount;
        goods._startTime = startTime;      

        return true;
    }  


    function isOnSale(address nftContractaddr,uint256 goodsID) public view returns(bool) {

        NftGoods memory goodsAddress = _saleGoodsAddr[goodsID];
        if( address(0) != goodsAddress._nftContractAddress && _isOnSale(goodsAddress) )
        {
            return true;
        }
        require(goodsAddress._nftContractAddress == nftContractaddr, "nftContractAddr mismatch Goods.");
        return false;
    }   

    function getSaleGoodsInfo(address nftContractaddr,uint256 goodsID) external view 
    returns (address nftContractAddress, StandType, uint256 tokenid, uint256 values,
        TokenType expectedTokenType,address sellerAddress,address expectedTokenAddress,
        uint256 expectedAmount,uint startTime,bool isForSale) {

        NftGoods memory goodsAddress = _saleGoodsAddr[goodsID];
        require(address(0) != goodsAddress._nftContractAddress, "It's not an invalid goods.");
        require(goodsAddress._nftContractAddress == nftContractaddr, "nftContractAddr mismatch Goods.");
        return (goodsAddress._nftContractAddress,goodsAddress._contractType,
        goodsAddress._tokenID,goodsAddress._values,
        TokenType.ETH,address(0),
        goodsAddress._sellerAddress,goodsAddress._expectedAmount,goodsAddress._startTime,true);
    }    

   
    function hasRightToSale(address nftContractaddr,StandType stand,address owner, 
    address targetAddr, uint256 tokenId,uint256 value) public view returns(bool) {

  
        if(stand == StandType.ERC721)
            return (IVcgERC721TokenWithRoyalty(nftContractaddr).isApprovedOrOwner(targetAddr, tokenId));
        else if(stand == StandType.ERC1155)
            return (IVcgERC1155Token(nftContractaddr).isApprovedOrOwner(owner,targetAddr, tokenId,value));
        else
            return false;
    }

    function IsTokenOwner(address nftContractaddr,StandType stand,address targetAddr, uint256 tokenId) public view returns(bool) {

        if(stand == StandType.ERC721){

            if(!IVcgERC721TokenWithRoyalty(nftContractaddr).exists(tokenId)){
                return false;
            }
            
            return (targetAddr == IVcgERC721TokenWithRoyalty(nftContractaddr).ownerOf(tokenId) );
        }
        else if(stand == StandType.ERC1155){
            return IVcgERC1155Token(nftContractaddr).isOwner(targetAddr,tokenId);
        }
        else
            return false;       
    }

 
    function hasEnoughTokenToBuy(address nftContractaddr,address buyer, 
    uint256 goodsID, uint256 value) public view returns(bool) {

        
        if( (address(0) == buyer) 
        )
        {
            return false;
        }

        NftGoods memory goodsAddress = _saleGoodsAddr[goodsID];
        if(address(0) == goodsAddress._nftContractAddress)
        {
            return false;
        }
        require(goodsAddress._nftContractAddress == nftContractaddr, "nftContractAddr mismatch Goods.");
        if(goodsAddress._contractType == StandType.ERC721)
            return buyer.balance >= goodsAddress._expectedAmount;
        else if(goodsAddress._contractType == StandType.ERC1155)
            return buyer.balance >= goodsAddress._expectedAmount*value;
        else
            return false;
    }

    
    function sellNFT(address nftContractAddr,StandType stand,uint256 goodsID,uint256 saleTokenID, 
        uint256 value, TokenType expectedTokenType, address tokenAddress, 
        uint256 amount, uint256 startTime) external {

        bool result;
        require(!Address.isContract(msg.sender),"the sender should be a person, not a contract!");

        require(IsTokenOwner(nftContractAddr,stand,msg.sender, saleTokenID),"the sender isn't the owner of the token id nft!");

        require((expectedTokenType == TokenType.ETH) || (expectedTokenType == TokenType.ERC20),
                "expectedTokenType must be ETH or ERC20 in this version!");

        
        if(startTime < block.timestamp)
        {
            startTime = block.timestamp;
        }
        
        require(hasRightToSale(nftContractAddr,stand,msg.sender,address(this), 
            saleTokenID,value),"the exchange contracct is not the approved of the TOKEN.");

        if( address(0) != _saleGoodsAddr[goodsID]._nftContractAddress )
        {
            require(_saleGoodsAddr[goodsID]._nftContractAddress == nftContractAddr, "nftContractAddr mismatch Goods.");  
            _saleGoodsAddr[goodsID]._expectedAmount = amount;
        }
        else
        {
            NftGoods storage goodsAddress = _saleGoodsAddr[goodsID];
            result = _onSale(goodsAddress,nftContractAddr,saleTokenID,value, payable(msg.sender), 
                amount, startTime);
            require(result, "set goods on sale is failed.");           
        }
    }    

    function cancelSell(address nftContractAddr,uint256 goodsID) external {

        require(!Address.isContract(msg.sender),"the sender should be a person, not a contract!");
        
        NftGoods memory goodsAddress = _saleGoodsAddr[goodsID];
        require(address(0) != goodsAddress._nftContractAddress,"Must be a vaild goods");
        require(goodsAddress._nftContractAddress == nftContractAddr, "nftContractAddr mismatch Goods.");
        require(isOwner()||
        isManager(msg.sender)||
        (goodsAddress._sellerAddress == msg.sender),
        "the sender isn't the owner of the token id nft!");

        delete _saleGoodsAddr[goodsID];
    } 

    function buyNFT(address nftContractAddr,uint256 goodsID,uint256 value) payable external nonReentrant {   

        require(isOnSale(nftContractAddr,goodsID),"The nft token(tokenID) is not on sale.");

        
        NftGoods storage goodsAddress = _saleGoodsAddr[goodsID];

        require(0 != goodsAddress._tokenID, "The token ID isn't on sale status!");
        require(goodsAddress._nftContractAddress == nftContractAddr, "nftContractAddr mismatch Goods.");
        require(msg.sender != goodsAddress._sellerAddress, "the buyer can't be same to the seller.");
        require(hasRightToSale(nftContractAddr,goodsAddress._contractType,
        goodsAddress._sellerAddress,
        address(this), goodsAddress._tokenID,value),
        "the exchange contracct is not the approved of the TOKEN.");

        if(goodsAddress._contractType == StandType.ERC721){
            IVcgERC721TokenWithRoyalty(nftContractAddr).safeTransferFrom(goodsAddress._sellerAddress, msg.sender, goodsAddress._tokenID);

            uint256 amount = goodsAddress._expectedAmount;
            (address creator,uint256 royalty) = IVcgERC721TokenWithRoyalty(nftContractAddr).royaltyInfo(goodsAddress._tokenID,amount);
            (address platform,uint256 fee) = calculateFee(amount);
            require(msg.value == amount, "No enough send token to buy the NFT(tokenID)");
            require(amount > royalty + fee,"No enough Amount to pay except royalty and platform fee");
                
            if(creator != address(0) && royalty >0 && royalty < amount)
            {
                payable(creator).transfer(royalty);
                amount = amount.sub(royalty);
            }      
            if(fee > 0 && fee < amount)
            {
                Address.sendValue(payable(platform),fee);
                amount = amount.sub(fee);
            }
            goodsAddress._sellerAddress.transfer(amount);

            emit SellAmountDetail(goodsID,amount,royalty,fee);
            
            delete _saleGoodsAddr[goodsID];
        }
        else if(goodsAddress._contractType == StandType.ERC1155){
            IVcgERC1155Token(nftContractAddr).safeTransferFrom(goodsAddress._sellerAddress, 
            msg.sender, goodsAddress._tokenID,value,"");

            uint256 amount = goodsAddress._expectedAmount.mul(value);
            (address platform,uint256 fee) = calculateFee(amount);
            require(msg.value == amount, "No enough send token to buy the NFT(tokenID)");
            require(amount > fee,"No enough Amount to pay except platform fee");
            if(fee > 0 && fee < amount)
            {
                Address.sendValue(payable(platform),fee);
                amount = amount.sub(fee);
            }
            goodsAddress._sellerAddress.transfer(amount);
            emit SellAmountDetail(goodsID,amount,0,fee);
            
            bool onSale = _onBuy(goodsAddress,goodsAddress._tokenID,value);
            if(!onSale)
            {
                delete _saleGoodsAddr[goodsID];
            }
        }
    }       

    function destroyContract() external onlyOwner {

        selfdestruct(payable(owner()));
    } 
}