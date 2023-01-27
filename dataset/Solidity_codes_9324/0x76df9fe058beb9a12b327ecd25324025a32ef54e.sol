


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

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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



pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}



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
}



pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

contract VirgoInstantLiquidity is Ownable, Pausable, ReentrancyGuard {

    using SafeMath for uint256;
    using Address for address;
    using Address for address payable;

    string public constant name = 'VirgoInstantLiquidity';
    string public constant version = 'V1';
    bytes32 public DOMAIN_SEPARATOR;

    address public operator;
    address public nftOwner; 
    mapping(address => bool) public managers;  
    mapping(address => uint256) public managerIndexes;  
    uint256 private constant signCount = 3;   
    uint256 private constant signedCount = 2;    

    modifier isManager{        

        require(managers[_msgSender()], "caller is not manager"); 
        _;
    }

    event SellERC721Fail(address indexed seller, address indexed tokenAddress, uint256 indexed tokenId);
    event SellERC1155Fail(address indexed seller, address indexed tokenAddress, uint256 indexed tokenId, uint256 amounts);
    event BuyERC721Fail(address indexed buyer, address indexed tokenAddress, uint256 indexed tokenId);
    event BuyERC1155Fail(address indexed buyer, address indexed tokenAddress, uint256 indexed tokenId, uint256 amounts);  
    event EthRecordCreated(address from, address to, uint amount, uint ethRecordId);
    event WithdrawETH(address indexed recipient, uint256 amount); 
    event UpdateOperator(address indexed operatorAddress);
    event UpdateNFTOwner(address nftOwnerAddress);
    event Delegate(address from, address to);
    event CloseTransactions(uint256 ethRecordId);
    event OrderInfo(uint256 indexed orderId, uint256 indexed tradeType);

    bytes32 private constant ERC721DETAILS_TYPEHASH = 0xa22e8bf7e119b195a6f04ed0c21241bcc24983bba105b07664defc2dc7e92612;
    bytes32 private constant ERC1155DETAILS_TYPEHASH = 0x74f52a5cd1c2e6f4a7c9e679c7e7f1461ce7b3ef57b04c3546269aa80338d6f9;
    bytes32 private constant SELLNFTSFORETH_TYPEHASH = 0xb73baae7c9bec1201806782a92848dc25312dc35645cbdc8088ac1c5c9ab35c7;
    bytes32 private constant BUYNFTSFORETH_TYPEHASH = 0x89138277441e31c4f31b04b4d83b8b8048482d6fff3b13a35eb1baa840a245f4;
    

    struct ERC721Details {
        address tokenAddr;        
        uint256[] ids;
        uint256[] price;
    }

    struct ERC1155Details {
        address tokenAddr;
        uint256[] ids;
        uint256[] amounts;
        uint256[] unitPrice;
    }

    struct EthRecord {        
        address from;
        address to;
        uint256 amount;
        uint256 signatureCount;
        bool isEnd;
        mapping (uint256 => bool) signatures;   //get sign status according to manager index number 
    }

    struct RoleUpdateRecord {
        address to;
        uint256 signatureCount;
        bool isUpdating;
        mapping (uint256 => bool) signatures;   //get sign status according to manager index number 
    }    

    mapping (uint256 => EthRecord) private ethRecords;
    uint256[] private pendingEthRecords;     
    uint256 private ethRecordNum;    
    RoleUpdateRecord private operatorRecord;
    RoleUpdateRecord private nftOwnerRecord;

    constructor(address[] memory _managers, address _operator, address _nftOwner) {        
        require(_managers.length == signCount, "Invalid manager address count");  
        require(_operator!= address(0) && !_operator.isContract(), "Invalid  operator address");    
        require(_nftOwner!= address(0) && !_nftOwner.isContract(), "Invalid nftowner address");         
        for (uint256 i = 0; i < _managers.length; i++) {
            require(!_managers[i].isContract(), "Invalid manager address");
            require(!managers[_managers[i]], "Repeated manager address");
            managers[_managers[i]] = true;
            managerIndexes[_managers[i]] = i + 1;
        }  
        operator = _operator;
        nftOwner = _nftOwner;              
        _setDomainSeperator();
    }

    function _setDomainSeperator() internal {

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes(version)),                
                bytes32(getChainId()),                             
                address(this) 
            )
        );        
    }

    function getDomainSeperator() public view returns (bytes32) {

        return DOMAIN_SEPARATOR;
    }

    function getChainId() public view returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }   
   

    function updateOperator(address _operatorAddress) external isManager {

        require(_operatorAddress!= address(0) && !_operatorAddress.isContract() && _operatorAddress != operator, "You can not change operator to zero address or contract based address or same  operator address");

        if (!operatorRecord.isUpdating) {
            operatorRecord.to = _operatorAddress;
            operatorRecord.signatureCount = 1;            
            operatorRecord.isUpdating = true;
            operatorRecord.signatures[managerIndexes[_msgSender()]] = true;
        } 
        else {
            require(_operatorAddress == operatorRecord.to,"The new operator address you signed is not requested!");
            require(!operatorRecord.signatures[managerIndexes[_msgSender()]],"You have signed!");
            operatorRecord.signatures[managerIndexes[_msgSender()]] = true;
            operatorRecord.signatureCount+=1;    
            if(operatorRecord.signatureCount >= signedCount){       
                operator = _operatorAddress;
                emit UpdateOperator(_operatorAddress);
                _clearOperatorRecord();
            }
        }        
    }

    function cancelUpdateOperator() external isManager {

         _clearOperatorRecord();
    }

    function updateNFTOwner(address _nftOwnerAddress) external isManager {

        require(_nftOwnerAddress!= address(0) && !_nftOwnerAddress.isContract() && _nftOwnerAddress != nftOwner, "You can not change nft ownerAddress to zero address or contract based address or same nftowner address");

        if (!nftOwnerRecord.isUpdating) {
            nftOwnerRecord.to = _nftOwnerAddress;
            nftOwnerRecord.signatureCount = 1;            
            nftOwnerRecord.isUpdating = true;
            nftOwnerRecord.signatures[managerIndexes[_msgSender()]] = true;
        } 
        else {
            require(_nftOwnerAddress == nftOwnerRecord.to,"The new nftowner address you signed is not requested!");
            require(!nftOwnerRecord.signatures[managerIndexes[_msgSender()]],"You have signed!");
            nftOwnerRecord.signatures[managerIndexes[_msgSender()]] = true;
            nftOwnerRecord.signatureCount+=1;    
            if(nftOwnerRecord.signatureCount >= signedCount){       
                nftOwner = _nftOwnerAddress;
                emit UpdateNFTOwner(_nftOwnerAddress);
                _clearNFTOwnerRecord();
            }
        }  
    }

    function cancelUpdateNFTOwner() external isManager {

         _clearNFTOwnerRecord();
    }

    function _clearOperatorRecord() internal {

        operatorRecord.to = address(0);
        operatorRecord.signatureCount = 0;
        operatorRecord.isUpdating = false;
        for (uint256 i = 0; i < signCount; i++) {
            operatorRecord.signatures[i+1] = false;
        }
    }

    function _clearNFTOwnerRecord() internal {

        nftOwnerRecord.to = address(0);
        nftOwnerRecord.signatureCount = 0;
        nftOwnerRecord.isUpdating = false;
        for (uint256 i = 0; i < signCount; i++) {
            nftOwnerRecord.signatures[i+1] = false;
        }
    }

    function getOperatorRecord() external view isManager returns(        
        address _to,
        uint256 _signatureCount,
        bool _isUpdating
        )
    {            

        _to = operatorRecord.to;
        _signatureCount = operatorRecord.signatureCount;
        _isUpdating = operatorRecord.isUpdating;
    }    

    function getNFTOwnerRecord() external view isManager returns(        
        address _to,
        uint256 _signatureCount,
        bool _isUpdating
        )
    {            

        _to = nftOwnerRecord.to;
        _signatureCount = nftOwnerRecord.signatureCount;
        _isUpdating = nftOwnerRecord.isUpdating;
    }    
    

    function getBalance() public view returns(uint){

        return address(this).balance;
    }

    function getBlockTimestamp() public view returns(uint){

        return block.timestamp;
    }

    function deposit() public payable{}


    function _hash(
        ERC721Details memory _erc721Detail
    ) internal pure returns (bytes32) {

        return keccak256(abi.encode(
                ERC721DETAILS_TYPEHASH,
                _erc721Detail.tokenAddr,
                keccak256(abi.encodePacked(_erc721Detail.ids)),
                keccak256(abi.encodePacked(_erc721Detail.price))
            )
        );
    }

    function _hash(
        ERC1155Details memory _erc1155Detail
    ) internal pure returns (bytes32) {

        return keccak256(abi.encode(
                ERC1155DETAILS_TYPEHASH,
                _erc1155Detail.tokenAddr,
                keccak256(abi.encodePacked(_erc1155Detail.ids)),
                keccak256(abi.encodePacked(_erc1155Detail.amounts)),
                keccak256(abi.encodePacked(_erc1155Detail.unitPrice))
            )
        );
    }

    function _getMessageHash(
        bytes32 _typeHash,  
        ERC721Details[] memory _erc721Details,
        ERC1155Details[] memory _erc1155Details, 
        uint256 _totalPrice,
        uint256 _deadline,
        uint256 _orderId
    ) internal pure returns (bytes32) {   


        bytes32[] memory erc721Data = new bytes32[](_erc721Details.length);
        bytes32[] memory erc1155Data = new bytes32[](_erc1155Details.length);

        for (uint256 i = 0; i < _erc721Details.length; i++) {
            erc721Data[i] = _hash(_erc721Details[i]);
        }

        for (uint256 i = 0; i < _erc1155Details.length; i++) {
            erc1155Data[i] = _hash(_erc1155Details[i]);
        }

        return keccak256(abi.encode(_typeHash,  
                                    keccak256(abi.encodePacked(erc721Data)), 
                                    keccak256(abi.encodePacked(erc1155Data)),  
                                    _totalPrice,
                                    _deadline,
                                    _orderId));
               
    }

    function _getSignedMessageHash(bytes32 _messageHash)
        internal
        view
        returns (bytes32)
    {       

        return
            keccak256(
                abi.encodePacked('\x19\x01', DOMAIN_SEPARATOR, _messageHash)
            );               
    }
    

    function _verify(        
        bytes32 _typeHash,
        ERC721Details[] memory _erc721Details,
        ERC1155Details[] memory _erc1155Details,  
        uint256 _totalPrice,
        uint256 _deadline,
        uint256 _orderId,
        bytes memory signature
    ) internal view returns (bool) {

        bytes32 messageHash = _getMessageHash(_typeHash, _erc721Details, _erc1155Details, _totalPrice, _deadline, _orderId);
        bytes32 ethSignedMessageHash = _getSignedMessageHash(messageHash);

        return _recoverSigner(ethSignedMessageHash, signature) == operator;
    }

    function _recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        internal
        pure
        returns (address)
    {

        (bytes32 r, bytes32 s, uint8 v) = _splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _splitSignature(bytes memory sig)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {

        require(sig.length == 65, "invalid signature length");

        assembly {

            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

    }
   

    function sellNFTsForETH( 
            ERC721Details[] calldata _erc721Details, 
            ERC1155Details[] calldata _erc1155Details,             
            uint256 _totalPrice,          
            uint256 _deadline,
            uint256 _orderId,
            bytes calldata _signature
    ) external nonReentrant whenNotPaused{

        require(_deadline >= block.timestamp, 'Trade expired');        
        require(_totalPrice > 0, 'Price must be granter than zero');
        require(getBalance() >= _totalPrice, 'The liquidity pool is full');   
        require(_msgSender() != nftOwner, "Seller can not be nftOwner");        
        require(_verify(            
            SELLNFTSFORETH_TYPEHASH,             
            _erc721Details, 
            _erc1155Details, 
            _totalPrice,             
            _deadline, 
            _orderId,
            _signature), 'INVALID_SIGNATURE');

        uint256 _ethAmount = 0;
            
        for (uint256 i = 0; i < _erc721Details.length; i++) {
            for (uint256 j = 0; j < _erc721Details[i].ids.length; j++) {
                  uint256 _tokenId = _erc721Details[i].ids[j];
                  if (IERC721(_erc721Details[i].tokenAddr).ownerOf(_tokenId) == _msgSender()) {                        
                        IERC721(_erc721Details[i].tokenAddr).safeTransferFrom(
                              _msgSender(),
                              nftOwner,                              
                              _tokenId
                        );
                        _ethAmount = _ethAmount.add(_erc721Details[i].price[j]);
                  }
                  else
                    emit SellERC721Fail(_msgSender(), _erc721Details[i].tokenAddr, _erc721Details[i].ids[j]);                  
            }
        }

        for (uint256 i = 0; i < _erc1155Details.length; i++) {
            for (uint256 j = 0; j < _erc1155Details[i].ids.length; j++) {  
                uint256 _tokenId = _erc1155Details[i].ids[j]; 
                uint256 _amounts =  _erc1155Details[i].amounts[j]; 
                uint256 _price = _erc1155Details[i].unitPrice[j];                   
                uint256 _balanceOf = IERC1155(_erc1155Details[i].tokenAddr).balanceOf(_msgSender(), _tokenId); 
                if (_balanceOf >= _amounts) {

                    IERC1155(_erc1155Details[i].tokenAddr).safeTransferFrom(
                        _msgSender(),
                        nftOwner,
                        _tokenId,
                        _amounts,
                        ""
                    );
                    _ethAmount = _ethAmount.add(_price.mul(_amounts));
                }    
                else if (_balanceOf > 0) {
                    IERC1155(_erc1155Details[i].tokenAddr).safeTransferFrom(
                        _msgSender(),
                        nftOwner,
                        _tokenId,
                        _balanceOf,
                        ""
                    );
                    _ethAmount = _ethAmount.add(_price.mul(_balanceOf));
                    emit SellERC1155Fail(_msgSender(), _erc1155Details[i].tokenAddr, _tokenId, _amounts.sub(_balanceOf));
                }
                else 
                    emit SellERC1155Fail(_msgSender(), _erc1155Details[i].tokenAddr, _tokenId, _amounts);
            }
        }        

        payable(_msgSender()).sendValue(_ethAmount);
        emit OrderInfo(_orderId, 0);
    } 
    

    function buyNFTsForETH(              
        ERC721Details[] calldata _erc721Details, 
        ERC1155Details[] calldata _erc1155Details, 
        uint256 _totalPrice, 
        uint256 _deadline, 
        uint256 _orderId,
        bytes calldata _signature
    ) external payable nonReentrant whenNotPaused {

        require(_deadline >= block.timestamp, 'Trade expired');    
        require(_totalPrice > 0, 'Price must be granter than zero');
        require(msg.value >= _totalPrice, "Less than listing price");   
        require(_msgSender() != nftOwner, "Buyer can not be nftOwner");     
        require(_verify(             
            BUYNFTSFORETH_TYPEHASH,
            _erc721Details, 
            _erc1155Details, 
            _totalPrice, 
            _deadline, 
            _orderId,
            _signature), 'INVALID_SIGNATURE');

        uint256 _ethAmount = msg.value;

        for (uint256 i = 0; i < _erc721Details.length; i++) {
            bool _isApproved = IERC721(_erc721Details[i].tokenAddr).isApprovedForAll(nftOwner, address(this));            
            for (uint256 j = 0; j < _erc721Details[i].ids.length; j++) {
                  uint256 _tokenId = _erc721Details[i].ids[j];
                  if (IERC721(_erc721Details[i].tokenAddr).ownerOf(_tokenId) == nftOwner && _isApproved &&                         
                        _ethAmount >= _erc721Details[i].price[j]) {
                        IERC721(_erc721Details[i].tokenAddr).safeTransferFrom(                              
                              nftOwner,
                              _msgSender(),                              
                              _tokenId
                        );
                        _ethAmount = _ethAmount.sub(_erc721Details[i].price[j]);
                  }
                  else
                    emit BuyERC721Fail(_msgSender(), _erc721Details[i].tokenAddr, _tokenId);                  
            }
        }
        

        for (uint256 i = 0; i < _erc1155Details.length; i++) {
            bool _isApproved =  IERC1155(_erc1155Details[i].tokenAddr).isApprovedForAll(nftOwner, address(this));  
            for (uint256 j = 0; j < _erc1155Details[i].ids.length; j++) { 
                uint256 _tokenId = _erc1155Details[i].ids[j]; 
                uint256 _amounts =  _erc1155Details[i].amounts[j]; 
                uint256 _price = _erc1155Details[i].unitPrice[j];                   
                uint256 _balanceOf = IERC1155(_erc1155Details[i].tokenAddr).balanceOf(nftOwner, _tokenId); 
                                
                if (_balanceOf >= _amounts && _isApproved && _ethAmount >= _price.mul(_amounts)) {
                    IERC1155(_erc1155Details[i].tokenAddr).safeTransferFrom(                        
                        nftOwner,
                        _msgSender(),
                        _tokenId,
                        _amounts,
                        ""
                    );
                    _ethAmount = _ethAmount.sub(_price.mul(_amounts));
                }    
                else if (_balanceOf > 0 && _isApproved && _ethAmount >= _price.mul(_balanceOf)) {
                    IERC1155(_erc1155Details[i].tokenAddr).safeTransferFrom(                        
                        nftOwner,
                        _msgSender(),
                        _tokenId,
                        _balanceOf,
                        ""
                    );
                    _ethAmount = _ethAmount.sub(_price.mul(_balanceOf));
                    emit BuyERC1155Fail(_msgSender(), _erc1155Details[i].tokenAddr, _tokenId, 
                    _amounts.sub(_balanceOf));
                }
                else 
                    emit BuyERC1155Fail(_msgSender(), _erc1155Details[i].tokenAddr, _tokenId, 
                    _amounts);
            }        
        }
        
        if (_ethAmount > 0)
            payable(_msgSender()).sendValue(_ethAmount);
        emit OrderInfo(_orderId, 1);    
    }   

    function isApprovedForAll(address[] calldata _nftAddress, bool[] calldata _isERC721) external view returns (bool[] memory) {

        require(_nftAddress.length == _isERC721.length, "_nftAddress and _isERC721 length mismatch");
        bool[] memory batchStatuses = new bool[](_nftAddress.length);

        for (uint256 i = 0; i < _nftAddress.length; i++) {
            if (_isERC721[i]) 
                batchStatuses[i] = IERC721(_nftAddress[i]).isApprovedForAll(_msgSender(), address(this));           
            else 
                batchStatuses[i] = IERC1155(_nftAddress[i]).isApprovedForAll(_msgSender(), address(this)); 
       }
       return batchStatuses;
    }


    function supportsInterface(bytes4 _interfaceId)
        external
        virtual
        view
        returns (bool)
    {

        return _interfaceId == this.supportsInterface.selector;
    }

    receive() external payable {}
    

    function requestWithdrawETH(address _recipient, uint256 _amount) external{

        require(managers[_msgSender()], "Only manager can withdraw eth!");
        require(_recipient != address(0), "Transfer to the zero address");
        require(address(this).balance >= _amount,"Insufficient Balance");

        uint256 ethRecordId = ethRecordNum++;  
        EthRecord storage ethRecord =ethRecords[ethRecordId];
        ethRecord.from = _msgSender();      
        ethRecord.to = _recipient;
        ethRecord.amount = _amount;
        ethRecord.signatureCount = 1;
        ethRecord.signatures[managerIndexes[_msgSender()]] = true;
        ethRecord.isEnd = false;
        pendingEthRecords.push(ethRecordId);
        emit EthRecordCreated(_msgSender(), _recipient, _amount, ethRecordId);
    }   

    function getPendingWithdraws() public isManager view returns(uint256[] memory){    

        return pendingEthRecords;
    }

    function getWithdrawInfo(uint256 _ethRecordId) external isManager view returns(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _signatureCount,
        bool _isEnd
        )
    {    

        _from = ethRecords[_ethRecordId].from;
        _to = ethRecords[_ethRecordId].to;
        _amount = ethRecords[_ethRecordId].amount;
        _signatureCount = ethRecords[_ethRecordId].signatureCount;
        _isEnd = ethRecords[_ethRecordId].isEnd;
    }    

    function delegate(address _delegateTo) external isManager{  

        require(_delegateTo != address(0), "You can not delegate to the zero address");
        require(_delegateTo !=_msgSender(),"You can not delegate to yourself");
        require(!managers[_delegateTo],"You can not delegate to other manager");
        managers[_delegateTo] = true;  
        managerIndexes[_delegateTo] = managerIndexes[_msgSender()];
        managers[_msgSender()] = false;
        managerIndexes[_msgSender()] = 0;
        emit Delegate(_msgSender(), _delegateTo);
    }

    function signEthRecord(uint256 _ethRecordId) external isManager{

        EthRecord storage ethRecord = ethRecords[_ethRecordId];
        require(!ethRecord.isEnd, "This transaction is closed");
        require(ethRecord.from != _msgSender(), "You can not sign the transaction you request");
        require(!ethRecord.signatures[managerIndexes[_msgSender()]],"You have signed the transaction!");
        ethRecord.signatures[managerIndexes[_msgSender()]] = true;
        ethRecord.signatureCount+=1;       
        if(ethRecord.signatureCount >= signedCount ){       
            require(address(this).balance >= ethRecord.amount, "Insufficient Balance"); 
            payable(ethRecord.to).sendValue(ethRecord.amount); 
            emit WithdrawETH(ethRecord.to, ethRecord.amount);
            closeTransactions(_ethRecordId);
        }
    }

    function closeTransactions(uint256 _ethRecordId) public isManager{        

        require(!ethRecords[_ethRecordId].isEnd, "This transaction is closed");
        uint256 temp = 0;
        for(uint256 i = 0; i< pendingEthRecords.length; i++){
            if(1 == temp){
                pendingEthRecords[i-1] = pendingEthRecords[i];
            }else if(_ethRecordId == pendingEthRecords[i]){
                temp = 1;
            }
        }
        require(temp == 1, "The _ethRecordId does not exist.");
        delete pendingEthRecords[pendingEthRecords.length - 1];
        pendingEthRecords.pop();
        ethRecords[_ethRecordId].isEnd = true;   
        emit CloseTransactions(_ethRecordId);
    }

    function pause() external isManager whenNotPaused {

        _pause();
    }

    function unpause() external isManager whenPaused {

        _unpause();
    }    
}