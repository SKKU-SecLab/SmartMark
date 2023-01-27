
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

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

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}// MIT
pragma solidity 0.8.2;


interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender, address recipient, uint256 amount
    ) external returns (bool);

}

interface IERC721 {

    function safeTransferFrom(
        address from, address to, uint256 tokenId
    ) external;

}

interface IERC1155 {

    function safeTransferFrom(
        address from, address to, uint256 id, uint256 amount, bytes calldata data
    ) external;

}


contract owned {

    address public manager;
    address public feeRecipient;
    bytes32 public currentSecretKey;

    constructor() {
        manager = msg.sender;
		feeRecipient = msg.sender;
    }
    
   modifier onlyManager() {

        require(msg.sender == manager, "Only Manager can execute this function");
        _;
    }
    
    function changeVaultManager(address _newManager)  public onlyManager {

        manager = _newManager;
    }
        
    event changeSecretKeyValue(string indexed value);
    function changeSecretKey (string memory _newSecretKey) public onlyManager {
        currentSecretKey = keccak256(abi.encodePacked(_newSecretKey));
        emit changeSecretKeyValue("Secret Key Changed.");
    }
    
    function changeFeeRecipient(address _newFeeRecipient) public onlyManager {

        feeRecipient = _newFeeRecipient;
    }
    function withdrawCollectedETH() public onlyManager {

        (bool success, ) = feeRecipient.call{value: address(this).balance}("");
        require(success, "Failed to send Ether");
    }
    
}

contract ZUZVaultV1 is owned, ERC721Holder, ERC1155Holder {

    
    struct TokenInfo {
        address tokenAddress;
        address tokenOwner;
        string tokenType;
        bool isLiquidityToken;
        uint tokenId;
        uint tokenAmount;
        uint lockTime;
        uint unlockTime;
        bool withdrawn;
    }
    uint256 public lastDepositId;
    mapping (uint256 => TokenInfo) public TokenInfoTable;
    mapping (address => uint[]) public depositsByCurrentUser;
    mapping (address => mapping(address => uint)) public totalTokensLockedByUser;

    
    function lockTokens(
        address _tokenAddress, string memory _tokenType, 
        bool _isLiquidityToken, uint _tokenId, uint256 _tokenAmount, uint _percentFee,
        string memory _paymentMethod, address _serviceFeeToken, uint _serviceFee,
        uint _unlockTime,string memory _secretKey
    ) public payable {

        require(currentSecretKey == keccak256(abi.encodePacked(_secretKey)), "Secure Key is wrong");
  
        uint fiftyYears = block.timestamp + 1576800000;
        require(_unlockTime < fiftyYears, 'Maximum lock period is 50 years');
        
        if(_percentFee > 0) IERC20(_tokenAddress).transferFrom(msg.sender, feeRecipient, _percentFee);
        if(keccak256(abi.encodePacked(_paymentMethod)) ==  keccak256(abi.encodePacked("eth"))) {
            require(msg.value >= _serviceFee, "Service Fee in ETH is less than required");
        }
        else if(keccak256(abi.encodePacked(_paymentMethod)) ==  keccak256(abi.encodePacked("other"))) {
            IERC20(_serviceFeeToken).transferFrom(msg.sender, feeRecipient, _serviceFee);
        }
        else {
            require(false, "Unknown Payment method used");
        }
    
        
        if(keccak256(abi.encodePacked(_tokenType)) ==  keccak256(abi.encodePacked("erc20"))) {
            IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _tokenAmount);
        }
        else if(keccak256(abi.encodePacked(_tokenType)) ==  keccak256(abi.encodePacked("erc721"))) {
            IERC721(_tokenAddress).safeTransferFrom(msg.sender, address(this), _tokenId);
        }
        else if(keccak256(abi.encodePacked(_tokenType)) ==  keccak256(abi.encodePacked("erc1155"))) {
             IERC1155(_tokenAddress).safeTransferFrom(
                msg.sender, address(this), _tokenId, _tokenAmount, '0x'
            );
        }
        else {
            require(false, "TokenType is not supported");
        }
        
        totalTokensLockedByUser[msg.sender][_tokenAddress] += _tokenAmount;
        
        uint _id = ++lastDepositId;
        TokenInfoTable[_id].tokenAddress = _tokenAddress;
        TokenInfoTable[_id].tokenOwner = msg.sender;
        TokenInfoTable[_id].tokenType = _tokenType;
        TokenInfoTable[_id].isLiquidityToken = _isLiquidityToken;
        TokenInfoTable[_id].tokenId = _tokenId;
        TokenInfoTable[_id].tokenAmount = _tokenAmount;
        TokenInfoTable[_id].lockTime = block.timestamp;
        TokenInfoTable[_id].unlockTime = _unlockTime;
        TokenInfoTable[_id].withdrawn = false;
        
        depositsByCurrentUser[msg.sender].push(_id);
    }
    
    
    function withdrawTokens(uint _id) public {

        require(msg.sender == TokenInfoTable[_id].tokenOwner, 'Only Token Owner can withdraw tokens');
        require(block.timestamp >= TokenInfoTable[_id].unlockTime, 'Unlock time is still in future');
        require(TokenInfoTable[_id].withdrawn == false, 'Tokens are already withdrawn');
        
        string memory _tokenType = TokenInfoTable[_id].tokenType;
        if(keccak256(abi.encodePacked(_tokenType)) ==  keccak256(abi.encodePacked("erc20"))) {
            IERC20(TokenInfoTable[_id].tokenAddress).transfer(TokenInfoTable[_id].tokenOwner, TokenInfoTable[_id].tokenAmount);
        }
        else if(keccak256(abi.encodePacked(_tokenType)) ==  keccak256(abi.encodePacked("erc721"))) {
            IERC721(TokenInfoTable[_id].tokenAddress).safeTransferFrom(address(this), TokenInfoTable[_id].tokenOwner, TokenInfoTable[_id].tokenId);
        }
        else if(keccak256(abi.encodePacked(_tokenType)) ==  keccak256(abi.encodePacked("erc1155"))) {
            IERC1155(TokenInfoTable[_id].tokenAddress).safeTransferFrom(
                address(this), TokenInfoTable[_id].tokenOwner, TokenInfoTable[_id].tokenId, TokenInfoTable[_id].tokenAmount, '0x'
            );
        }
        TokenInfoTable[_id].withdrawn = true;
        
        totalTokensLockedByUser[TokenInfoTable[_id].tokenOwner][TokenInfoTable[_id].tokenAddress] -= TokenInfoTable[_id].tokenAmount;
    }
    
    
    function getTokenBalanceByAddress(address _userAddress, address _tokenAddress) view public returns (uint)
    {

       return totalTokensLockedByUser[_userAddress][_tokenAddress];
    }
    
    function getDepositDetails(uint256 _id) view public returns (TokenInfo memory)
    {

        return TokenInfoTable[_id];
    }
    
    function getDepositsByUserAddress(address _currentUser) view public returns (uint[] memory)
    {

        return depositsByCurrentUser[_currentUser];
    }
}