

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


enum TokenType {ETH, ERC20}
enum StandType {ERC721,ERC1155}
contract Goods is Ownable {

    using Strings for string;
    using Address for address;    
    using SafeMath for *;
   
    string constant public _name = "GOODS contract as ERC721 & ERC1155 NFT for sale with version 3.0";

    address private _nftContractAddress;
    StandType public _contractType;
    uint256 public _tokenID;
    uint256 public _values;
    TokenType public _expectedTokenType;
    address payable public _sellerAddress;
    address private _expectedTokenAddress;
    uint256 public _expectedAmount;
    uint private _startTime;
    bool private _isForSale = false;

    constructor(address ContractAddress) {
        require(true == Address.isContract(ContractAddress), "ContractAddress is not a contract address!");

        if(IERC721(ContractAddress).supportsInterface(0x80ac58cd))
        {
            _nftContractAddress = ContractAddress;
            _contractType = StandType.ERC721;
        }
        else if(IERC1155(ContractAddress).supportsInterface(0x0e89341c))
        {
            _nftContractAddress = ContractAddress;
            _contractType = StandType.ERC1155;
        }
        else
        {
            revert();
        }
        
    }  

    function getGoodsInfo() external view returns (address, StandType, uint256, uint256, TokenType,address,address,uint256,uint,bool) {         

        return (_nftContractAddress,_contractType,_tokenID,_values,_expectedTokenType,_sellerAddress,_expectedTokenAddress,_expectedAmount,_startTime,_isForSale);
    }  

    function onSale(uint256 saleTokenID, uint256 value,address payable sellerAddress,TokenType expectedTokenType, address tokenAddress, uint256 amount, uint256 startTime) external onlyOwner returns (bool) {  

        if(sellerAddress == address(0))
        {
            return false;
        }
        if(_contractType == StandType.ERC721){
            require(1 == value, "721 Asset value MUST be 1.");
        }
        if(!isApprovedOrOwner(sellerAddress,saleTokenID,value)) 
        {
            return false;
        }   

        if((expectedTokenType != TokenType.ETH) && (!Address.isContract(tokenAddress)) )
        {
             return false;
        }

        _tokenID = saleTokenID;
        _values = value;
        _expectedTokenType = expectedTokenType;
        _sellerAddress = sellerAddress;
        _expectedTokenAddress = tokenAddress;
        _expectedAmount = amount;
        _startTime = startTime;
        _isForSale = true;        

        return true;
    }  

    function offSale() external onlyOwner{ 

        _tokenID = 0;
        _values = 0;
        _expectedTokenType = TokenType.ETH;
        _sellerAddress = payable(address(0));
        _expectedTokenAddress = address(0);
        _expectedAmount = 0;
        _startTime = 0;        
        _isForSale = false;
    }  

    function isApprovedOrOwner(address seller, uint256 tokenId, uint256 value) public view returns (bool) {

        
        if(_contractType == StandType.ERC721)
        {
            address owner = IERC721(_nftContractAddress).ownerOf(tokenId);

            return (seller == owner || IERC721(_nftContractAddress).getApproved(tokenId) == seller || IERC721(_nftContractAddress).isApprovedForAll(owner, seller));
        }
        else if(_contractType == StandType.ERC1155)
        {
            return IVcgERC1155Token(_nftContractAddress).isApprovedOrOwner(address(0),seller,tokenId,value);
        }
        else
        {
            revert();
        }
    }


    function isOnSale() public view returns(bool) {

        return(_isForSale && (block.timestamp >= _startTime)
        && (_values > 0) 
        );
    }

    function onBuy(uint256 saleTokenID, uint256 value)
    external onlyOwner returns(bool) {

        require((saleTokenID == _tokenID) && (block.timestamp >= _startTime) && (_values >= value), "Buy Error.");
        _values = _values.sub(value);
        return isOnSale();
    }
}


enum BaseContractType {Contract721,Contract1155,Contract20}


contract ExchangeVcgSale is Authentication,Commission{

    using Strings for string;
    using Address for address;    
    using SafeMath for *;

    string constant public _name = "Exchange contract as ERC721 NFT exchange with ETH or Vcg ERC20 version 1.1";    
    
    struct NftPair {
        address nftContractaddr;
        uint256 goodsID;
        bool isUsed;
    }
    mapping(bytes32 => NftPair) private _saleGoodsSource;
    mapping(bytes32 => address) private _saleGoodsAddr;//nft pair对应的商品合约地址
    address private _VcgNftAddress;//Vcg NFT智能合约
    address private _VcgErc20Address;//Vcg ERC20智能合约
    address private _VcgMultiNftAddress;//Vcg 1155 NFT智能合约

    event SellAmountDetail(uint256 indexed goodsID,
            uint256 indexed sellerReceived,
            uint256 indexed creatorReceived,
            uint256  platformReceived);
    function migrationDefaultContract(address contractAddress,BaseContractType t)
    external onlyOwner {

        require(Address.isContract(contractAddress), "the parameter should be Contract  address!" );
        if(t == BaseContractType.Contract721)
        {
            require(IVcgERC721TokenWithRoyalty(contractAddress).isVcgNftToken(contractAddress), "the parameter should be Vcg ERC721Token address!");
            _VcgNftAddress = contractAddress;
        }
        else if(t == BaseContractType.Contract1155)
        {
            require(IVcgERC1155Token(contractAddress).isVcgNftToken(contractAddress), "the third parameter should be Vcg ERC1155Token address!");
            _VcgMultiNftAddress = contractAddress;
        }
        else if(t == BaseContractType.Contract20)
        {
            _VcgErc20Address = contractAddress;
        }
    }

    function keyByNFTPair(address nftContractaddr,uint256 goodsID) internal pure
             returns (bytes32 result) 
     {  

        result =  keccak256(abi.encodePacked(nftContractaddr, goodsID));
     }  

    function _existGoods(address nftContractaddr,uint256 goodsID) internal view
            returns(bool) {

        bytes32 key = keyByNFTPair(nftContractaddr,goodsID);
        return _saleGoodsSource[key].isUsed;
    }
    
    
    function isOnSale(address nftContractaddr,uint256 goodsID) public view returns(bool) {

        bytes32 key = keyByNFTPair(nftContractaddr,goodsID);
        address goodsAddress = _saleGoodsAddr[key];

        if( address(0) != goodsAddress && Goods(goodsAddress).isOnSale() )
        {
            return true;
        }

        return false;
    }   

    function getSaleGoodsInfo(address nftContractaddr,uint256 goodsID) external view 
    returns (address nftContractAddress, StandType, uint256 tokenid, uint256 values, TokenType expectedTokenType,address sellerAddress,address expectedTokenAddress,uint256 expectedAmount,uint startTime,bool isForSale) {

        bytes32 key = keyByNFTPair(nftContractaddr,goodsID);
        address goodsAddress = _saleGoodsAddr[key];

        require(address(0) != goodsAddress, "It's not an invalid goods.");

        return( Goods(goodsAddress).getGoodsInfo() );
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

        bytes32 key = keyByNFTPair(nftContractaddr,goodsID);
        address goodsAddress = _saleGoodsAddr[key];
 
        if(address(0) == goodsAddress)
        {
            return false;
        }
        
        if(TokenType.ETH ==  Goods(goodsAddress)._expectedTokenType() )
        {
            if(Goods(goodsAddress)._contractType() == StandType.ERC721)
                return buyer.balance >= Goods(goodsAddress)._expectedAmount();
            else if(Goods(goodsAddress)._contractType() == StandType.ERC1155)
                return buyer.balance >= (Goods(goodsAddress)._expectedAmount()*value);
            else
                return false;
        }
        else if(TokenType.ERC20 ==  Goods(goodsAddress)._expectedTokenType() )
        {
            if(Goods(goodsAddress)._contractType() == StandType.ERC721)
                return IERC20(_VcgErc20Address).balanceOf(buyer) >= Goods(goodsAddress)._expectedAmount();
            else if(Goods(goodsAddress)._contractType() == StandType.ERC1155)
                return IERC20(_VcgErc20Address).balanceOf(buyer) >= (Goods(goodsAddress)._expectedAmount().mul(value));
            else
                return false;
        }
        else
        {
            return false;
        }           
  
    }

    function sellNFT(address nftContractAddr,StandType stand,uint256 goodsID,uint256 saleTokenID, uint256 value, TokenType expectedTokenType, address tokenAddress, uint256 amount, uint256 startTime) external {

        Goods goods;
        bool result;

        require(!Address.isContract(msg.sender),"the sender should be a person, not a contract!");

        require(IsTokenOwner(nftContractAddr,stand,msg.sender, saleTokenID),"the sender isn't the owner of the token id nft!");

        require((expectedTokenType == TokenType.ETH) || (expectedTokenType == TokenType.ERC20),
                "expectedTokenType must be ETH or ERC20 in this version!");

        if(expectedTokenType == TokenType.ERC20)
        {
            require((tokenAddress == _VcgErc20Address), "the expected token must be Vcg ERC20 token.");
        }
        
        if(startTime < block.timestamp)
        {
            startTime = block.timestamp;
        }
        
        require(hasRightToSale(nftContractAddr,stand,msg.sender,address(this), 
            saleTokenID,value),"the exchange contracct is not the approved of the TOKEN.");

        bytes32 key = keyByNFTPair(nftContractAddr,goodsID);
        
        if( address(0) != _saleGoodsAddr[key] )
        {
            goods = Goods(_saleGoodsAddr[key] );
            result = goods.onSale(saleTokenID,value,payable(msg.sender),expectedTokenType, tokenAddress, amount, startTime);
            require(result, "reset goods on sale is failed.");
        }
        else
        {
            goods = new Goods(nftContractAddr);
            result = goods.onSale(saleTokenID,value, payable(msg.sender), expectedTokenType, tokenAddress, amount, startTime);
            require(result, "set goods on sale is failed.");
            
            _saleGoodsAddr[key] = address(goods);
            _saleGoodsSource[key] = NftPair(nftContractAddr,saleTokenID,true);

        }
    }    

    function cancelSell(address nftContractAddr,uint256 goodsID) external {

        require(!Address.isContract(msg.sender),"the sender should be a person, not a contract!");
        bytes32 key = keyByNFTPair(nftContractAddr,goodsID);
        address goodsAddress = _saleGoodsAddr[key];
        require(address(0) != goodsAddress,"Must be a vaild goods");
        
        require(isOwner()||
        isManager(msg.sender)||
        (Goods(goodsAddress)._sellerAddress() == msg.sender),
        "the sender isn't the owner of the token id nft!");

        _saleGoodsAddr[key] = address(0);
        _saleGoodsSource[key].isUsed = false;
        
    } 

    function buyNFT(address nftContractAddr,uint256 goodsID,uint256 value) payable external {   

        require(isOnSale(nftContractAddr,goodsID),"The nft token(tokenID) is not on sale.");

        
        bytes32 key = keyByNFTPair(nftContractAddr,goodsID);
        address goodsAddress = _saleGoodsAddr[key];
        require(address(0) != goodsAddress, "The token ID isn't on sale status!");

        require(msg.sender != Goods(goodsAddress)._sellerAddress(), "the buyer can't be same to the seller.");
        require(hasRightToSale(nftContractAddr,Goods(goodsAddress)._contractType(),
        Goods(goodsAddress)._sellerAddress(),
        address(this), Goods(goodsAddress)._tokenID(),value),
        "the exchange contracct is not the approved of the TOKEN.");

        if(Goods(goodsAddress)._contractType() == StandType.ERC721){
            IVcgERC721TokenWithRoyalty(nftContractAddr).safeTransferFrom(Goods(goodsAddress)._sellerAddress(), msg.sender, Goods(goodsAddress)._tokenID());

            uint256 amount = Goods(goodsAddress)._expectedAmount();
            (address creator,uint256 royalty) = IVcgERC721TokenWithRoyalty(nftContractAddr).royaltyInfo(Goods(goodsAddress)._tokenID(),amount);
            (address platform,uint256 fee) = calculateFee(amount);

            if(TokenType.ETH == Goods(goodsAddress)._expectedTokenType())
            {
                require(msg.value == amount, "No enough send token to buy the NFT(tokenID)");
                require(amount > royalty + fee,"No enough Amount to pay except royalty and platform fee");
                if(creator != address(0) && royalty >0 && royalty < amount)
                {
                    payable(creator).transfer(royalty);
                    amount = amount.sub(royalty);
                }      
                if(fee > 0 && fee < amount)
                {
                    payable(platform).transfer(fee);
                    amount = amount.sub(fee);
                }
                Goods(goodsAddress)._sellerAddress().transfer(amount);

                emit SellAmountDetail(goodsID,amount,royalty,fee);
            }
            else if(TokenType.ERC20 ==  Goods(goodsAddress)._expectedTokenType() )
            {
                require(IERC20(_VcgErc20Address).allowance(msg.sender, address(this)) >= amount, 
                        "the approved MOZ ERC20 tokens to the contract address should greater than the _expectedValue." );
                if(creator != address(0) && royalty > 0 && royalty < amount)
                {
                    IERC20(_VcgErc20Address).transferFrom(msg.sender, Goods(goodsAddress)._sellerAddress(), amount.sub(royalty));
                    IERC20(_VcgErc20Address).transferFrom(msg.sender, creator, royalty);
                }
                else
                {
                    IERC20(_VcgErc20Address).transferFrom(msg.sender, Goods(goodsAddress)._sellerAddress(), amount);
                }                                   
            }
            _saleGoodsAddr[key] = address(0x0);
        }
        else if(Goods(goodsAddress)._contractType() == StandType.ERC1155){
            IVcgERC1155Token(nftContractAddr).safeTransferFrom(Goods(goodsAddress)._sellerAddress(), msg.sender, Goods(goodsAddress)._tokenID(),value,"");

            uint256 amount = Goods(goodsAddress)._expectedAmount().mul(value);
            (address platform,uint256 fee) = calculateFee(amount);
            if(TokenType.ETH == Goods(goodsAddress)._expectedTokenType())
            {
                require(msg.value == amount, "No enough send token to buy the NFT(tokenID)");
                require(amount > fee,"No enough Amount to pay except platform fee");
                if(fee > 0 && fee < amount)
                {
                    payable(platform).transfer(fee);
                    amount = amount.sub(fee);
                }
                Goods(goodsAddress)._sellerAddress().transfer(amount);
                emit SellAmountDetail(goodsID,amount,0,fee);
            }
            else if(TokenType.ERC20 ==  Goods(goodsAddress)._expectedTokenType() )
            {
                require(IERC20(_VcgErc20Address).allowance(msg.sender, address(this)) >= amount, 
                        "the approved MOZ ERC20 tokens to the contract address should greater than the _expectedValue." );
                IERC20(_VcgErc20Address).transferFrom(msg.sender, Goods(goodsAddress)._sellerAddress(), amount);
            }

            bool onSale = Goods(goodsAddress).onBuy(Goods(goodsAddress)._tokenID(),value);
            if(!onSale)
            {
                _saleGoodsAddr[key] = address(0x0);
            }
        }
    }   

    function getTokenAddress() external view returns (address, address, address){

        return(_VcgNftAddress, _VcgErc20Address, _VcgMultiNftAddress);
    }    

    function destroyContract() external onlyOwner {

        uint256 amount = IERC20(_VcgErc20Address).balanceOf(address(this));
        IERC20(_VcgErc20Address).transfer(owner(), amount);

        selfdestruct(payable(owner()));
    } 
}