



interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}





library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}



contract LinkdropStorage {


    address public owner;

    address payable public linkdropMaster;

    uint public version;

    uint public chainId;

    mapping (address => bool) public isLinkdropSigner;

    mapping (address => address) public claimedTo;

    mapping (address => bool) internal _canceled;

    bool public initialized;

    bool internal _paused;

    address payable public constant feeReceiver = 0xbE9ad35449A5822B0863D2DeB3147c2a42e07C06;
    uint256 public constant sponsoredFeeAmount = 0.02 ether; // per sponsored claim
    
    event Canceled(address linkId);
    event Claimed(address indexed linkId, uint ethAmount, address indexed token, uint tokenAmount, address receiver);
    event ClaimedERC721(address indexed linkId, uint ethAmount, address indexed nft, uint tokenId, address receiver);
    event ClaimedERC1155(address indexed linkId, uint ethAmount, address indexed nft, uint tokenId, uint tokenAmount, address receiver);    
    event Paused();
    event Unpaused();
    event AddedSigningKey(address linkdropSigner);
    event RemovedSigningKey(address linkdropSigner);

}



interface ILinkdropCommon {


    function initialize
    (
        address _owner,
        address payable _linkdropMaster,
        uint _version,
        uint _chainId
    )
    external returns (bool);

    function isClaimedLink(address _linkId) external view returns (bool);

    function isCanceledLink(address _linkId) external view returns (bool);

    function paused() external view returns (bool);

    function cancel(address _linkId) external  returns (bool);

    function withdraw() external returns (bool);

    function pause() external returns (bool);

    function unpause() external returns (bool);

    function addSigner(address _linkdropSigner) external payable returns (bool);

    function removeSigner(address _linkdropSigner) external returns (bool);

    function destroy() external;

    function getMasterCopyVersion() external view returns (uint);

    function verifyReceiverSignature( address _linkId,
                                      address _receiver,
                                      bytes calldata _signature
                                      )  external view returns (bool);

    receive() external payable;

}






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



interface ILinkdropERC1155 {


    function verifyLinkdropSignerSignatureERC1155
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes calldata _signature
    )
    external view returns (bool);

    function checkClaimParamsERC1155
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _tokenAmount,        
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address _receiver,
        bytes calldata _receiverSignature
     )
    external view returns (bool);

    function claimERC1155
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature
    )
    external returns (bool);

}






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



interface ILinkdropERC721 {


    function verifyLinkdropSignerSignatureERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        bytes calldata _signature
    )
    external view returns (bool);

    function verifyReceiverSignatureERC721
    (
        address _linkId,
	    address _receiver,
		bytes calldata _signature
    )
    external view returns (bool);

    function checkClaimParamsERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address _receiver,
        bytes calldata _receiverSignature
    )
    external view returns (bool);

    function claimERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature
    )
    external returns (bool);

}




contract LinkdropCommon is ILinkdropCommon, LinkdropStorage {


    function initialize
    (
        address _owner,
        address payable _linkdropMaster,
        uint _version,
        uint _chainId
    )
    public
    override      
    returns (bool)
    {
        require(!initialized, "LINKDROP_PROXY_CONTRACT_ALREADY_INITIALIZED");
        owner = _owner;
        linkdropMaster = _linkdropMaster;
        isLinkdropSigner[linkdropMaster] = true;
        version = _version;
        chainId = _chainId;
        initialized = true;
        return true;
    }

    modifier onlyLinkdropMaster() {

        require(msg.sender == linkdropMaster, "ONLY_LINKDROP_MASTER");
        _;
    }

    modifier onlyLinkdropMasterOrFactory() {

        require (msg.sender == linkdropMaster || msg.sender == owner, "ONLY_LINKDROP_MASTER_OR_FACTORY");
        _;
    }

    modifier onlyFactory() {

        require(msg.sender == owner, "ONLY_FACTORY");
        _;
    }

    modifier whenNotPaused() {

        require(!paused(), "LINKDROP_PROXY_CONTRACT_PAUSED");
        _;
    }

    function isClaimedLink(address _linkId) public override view returns (bool) {

        return claimedTo[_linkId] != address(0);
    }

    function isCanceledLink(address _linkId) public override view returns (bool) {

        return _canceled[_linkId];
    }

    function paused() public override view returns (bool) {

        return _paused;
    }

    function cancel(address _linkId) external override onlyLinkdropMaster returns (bool) {

        require(!isClaimedLink(_linkId), "LINK_CLAIMED");
        _canceled[_linkId] = true;
        emit Canceled(_linkId);
        return true;
    }

    function withdraw() external override onlyLinkdropMaster returns (bool) {

        linkdropMaster.transfer(address(this).balance);
        return true;
    }

    function pause() external override onlyLinkdropMaster whenNotPaused returns (bool) {

        _paused = true;
        emit Paused();
        return true;
    }

    function unpause() external override onlyLinkdropMaster returns (bool) {

        require(paused(), "LINKDROP_CONTRACT_ALREADY_UNPAUSED");
        _paused = false;
        emit Unpaused();
        return true;
    }

    function addSigner(address _linkdropSigner) external override payable onlyLinkdropMasterOrFactory returns (bool) {

        require(_linkdropSigner != address(0), "INVALID_LINKDROP_SIGNER_ADDRESS");
        isLinkdropSigner[_linkdropSigner] = true;
        return true;
    }

    function removeSigner(address _linkdropSigner) external override onlyLinkdropMaster returns (bool) {

        require(_linkdropSigner != address(0), "INVALID_LINKDROP_SIGNER_ADDRESS");
        isLinkdropSigner[_linkdropSigner] = false;
        return true;
    }

    function destroy() external override onlyLinkdropMasterOrFactory {

        selfdestruct(linkdropMaster);
    }

    function getMasterCopyVersion() external override view returns (uint) {

        return version;
    }


    function verifyReceiverSignature
    (
        address _linkId,
        address _receiver,
        bytes memory _signature
    )
    public view
    override       
    returns (bool)
    {
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(_receiver)));
        address signer = ECDSA.recover(prefixedHash, _signature);
        return signer == _linkId;
    }
    
    receive() external override payable {}    
}



interface ILinkdropERC20 {


    function verifyLinkdropSignerSignature
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes calldata _signature
    )
    external view returns (bool);

    function checkClaimParams
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address _receiver,
        bytes calldata _receiverSignature
    )
    external view returns (bool);

    function claim
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature
    )
    external returns (bool);

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




contract LinkdropERC1155 is ILinkdropERC1155, LinkdropCommon {

    using SafeMath for uint;
    function verifyLinkdropSignerSignatureERC1155
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes memory _signature
    )
    public view
    override       
    returns (bool)
    {
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash
        (
            keccak256
            (
                abi.encodePacked
                (
                    _weiAmount,
                    _nftAddress,
                    _tokenId,
                    _tokenAmount,
                    _expiration,
                    version,
                    chainId,
                    _linkId,
                    address(this)
                )
            )
        );
        address signer = ECDSA.recover(prefixedHash, _signature);
        return isLinkdropSigner[signer];
    }


    function checkClaimParamsERC1155
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes memory _linkdropSignerSignature,
        address _receiver,
        bytes memory _receiverSignature
    )
    public view
    override       
    whenNotPaused
    returns (bool)
    {
        require(_nftAddress != address(0), "INVALID_NFT_ADDRESS");

        require(isClaimedLink(_linkId) == false, "LINK_CLAIMED");

        require(isCanceledLink(_linkId) == false, "LINK_CANCELED");

        require(_expiration >= now, "LINK_EXPIRED");

        require(address(this).balance >= _weiAmount, "INSUFFICIENT_ETHERS");

        require(IERC1155(_nftAddress).balanceOf(linkdropMaster, _tokenId) >= _tokenAmount, "LINKDROP_MASTER_DOES_NOT_HAVE_ENOUGH_TOKENS");

        require
        (
            verifyLinkdropSignerSignatureERC1155
            (
                _weiAmount,
                _nftAddress,
                _tokenId,
                _tokenAmount,
                _expiration,
                _linkId,
                _linkdropSignerSignature
            ),
            "INVALID_LINKDROP_SIGNER_SIGNATURE"
        );

        require
        (
            verifyReceiverSignature(_linkId, _receiver, _receiverSignature),
            "INVALID_RECEIVER_SIGNATURE"
        );

        return true;
    }

    function claimERC1155
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature
    )
    external
    override 
    whenNotPaused
    returns (bool)
    {

        require
        (
            checkClaimParamsERC1155
            (
                _weiAmount,
                _nftAddress,
                _tokenId,
                _tokenAmount,
                _expiration,                
                _linkId,
                _linkdropSignerSignature,
                _receiver,
                _receiverSignature
            ),
            "INVALID_CLAIM_PARAMS"
        );

        claimedTo[_linkId] = _receiver;

        require(_transferFundsERC1155(_weiAmount, _nftAddress, _tokenId, _tokenAmount, _receiver), "TRANSFER_FAILED");

        emit ClaimedERC1155(_linkId, _weiAmount, _nftAddress, _tokenId, _tokenAmount, _receiver);

        return true;
    }

    function _transferFundsERC1155
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _tokenAmount,
        address payable _receiver
    )
    internal returns (bool) {
      if (tx.origin != _receiver) { 
        feeReceiver.transfer(sponsoredFeeAmount);
      }
      
      if (_weiAmount > 0) {
        _receiver.transfer(_weiAmount);
      }
      
      IERC1155(_nftAddress).safeTransferFrom(linkdropMaster, _receiver, _tokenId, _tokenAmount, new bytes(0));
      
      return true;
    }

}




contract LinkdropERC721 is ILinkdropERC721, LinkdropCommon {

    using SafeMath for uint;
    function verifyLinkdropSignerSignatureERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        bytes memory _signature
    )
    public view
    override       
    returns (bool)
    {
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash
        (
            keccak256
            (
                abi.encodePacked
                (
                    _weiAmount,
                    _nftAddress,
                    _tokenId,
                    _expiration,
                    version,
                    chainId,
                    _linkId,
                    address(this)
                )
            )
        );
        address signer = ECDSA.recover(prefixedHash, _signature);
        return isLinkdropSigner[signer];
    }

    function verifyReceiverSignatureERC721
    (
        address _linkId,
        address _receiver,
        bytes memory _signature
    )
    public view
    override       
    returns (bool)
    {
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(_receiver)));
        address signer = ECDSA.recover(prefixedHash, _signature);
        return signer == _linkId;
    }

    function checkClaimParamsERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        bytes memory _linkdropSignerSignature,
        address _receiver,
        bytes memory _receiverSignature
    )
    public view
    override       
    whenNotPaused
    returns (bool)
    {
        require(_nftAddress != address(0), "INVALID_NFT_ADDRESS");

        require(isClaimedLink(_linkId) == false, "LINK_CLAIMED");

        require(isCanceledLink(_linkId) == false, "LINK_CANCELED");

        require(_expiration >= now, "LINK_EXPIRED");

        require(address(this).balance >= _weiAmount, "INSUFFICIENT_ETHERS");

        require(IERC721(_nftAddress).ownerOf(_tokenId) == linkdropMaster, "LINKDROP_MASTER_DOES_NOT_OWN_TOKEN_ID");

        require
        (
            verifyLinkdropSignerSignatureERC721
            (
                _weiAmount,
                _nftAddress,
                _tokenId,
                _expiration,
                _linkId,
                _linkdropSignerSignature
            ),
            "INVALID_LINKDROP_SIGNER_SIGNATURE"
        );

        require
        (
            verifyReceiverSignatureERC721(_linkId, _receiver, _receiverSignature),
            "INVALID_RECEIVER_SIGNATURE"
        );

        return true;
    }

    function claimERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature
    )
    external
    override 
    onlyFactory
    whenNotPaused
    returns (bool)
    {

        require
        (
            checkClaimParamsERC721
            (
                _weiAmount,
                _nftAddress,
                _tokenId,
                _expiration,
                _linkId,
                _linkdropSignerSignature,
                _receiver,
                _receiverSignature
            ),
            "INVALID_CLAIM_PARAMS"
        );

        claimedTo[_linkId] = _receiver;

        require(_transferFundsERC721(_weiAmount, _nftAddress, _tokenId, _receiver), "TRANSFER_FAILED");

        emit ClaimedERC721(_linkId, _weiAmount, _nftAddress, _tokenId, _receiver);

        return true;
    }

    function _transferFundsERC721
    (
        uint _weiAmount,
        address _nftAddress,
        uint _tokenId,
        address payable _receiver
    )
    internal returns (bool)
    {

      if (tx.origin != _receiver) { 
        feeReceiver.transfer(sponsoredFeeAmount);
      }
      
      if (_weiAmount > 0) {
        _receiver.transfer(_weiAmount);
      }

      IERC721(_nftAddress).transferFrom(linkdropMaster, _receiver, _tokenId);
      
      return true;
    }

}




contract LinkdropERC20 is ILinkdropERC20, LinkdropCommon {

  
    using SafeMath for uint;
    
    function verifyLinkdropSignerSignature
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes memory _signature
    )
    public view
      override 
    returns (bool)
    {
        bytes32 prefixedHash = ECDSA.toEthSignedMessageHash
        (
            keccak256
            (
                abi.encodePacked
                (
                    _weiAmount,
                    _tokenAddress,
                    _tokenAmount,
                    _expiration,
                    version,
                    chainId,
                    _linkId,
                    address(this)
                )
            )
        );
        address signer = ECDSA.recover(prefixedHash, _signature);
        return isLinkdropSigner[signer];
    }


    function checkClaimParams
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes memory _linkdropSignerSignature,
        address _receiver,
        bytes memory _receiverSignature
     )
    public view
    override       
    whenNotPaused
    returns (bool)
    {
        if (_tokenAmount > 0) {
            require(_tokenAddress != address(0), "INVALID_TOKEN_ADDRESS");
        }

        require(isClaimedLink(_linkId) == false, "LINK_CLAIMED");

        require(isCanceledLink(_linkId) == false, "LINK_CANCELED");

        require(_expiration >= now, "LINK_EXPIRED");

        require(address(this).balance >= _weiAmount, "INSUFFICIENT_ETHERS");

        if (_tokenAddress != address(0)) {
            require
            (
                IERC20(_tokenAddress).balanceOf(linkdropMaster) >= _tokenAmount,
                "INSUFFICIENT_TOKENS"
            );

            require
            (
                IERC20(_tokenAddress).allowance(linkdropMaster, address(this)) >= _tokenAmount, "INSUFFICIENT_ALLOWANCE"
            );
        }

        require
        (
            verifyLinkdropSignerSignature
            (
                _weiAmount,
                _tokenAddress,
                _tokenAmount,
                _expiration,
                _linkId,
                _linkdropSignerSignature
            ),
            "INVALID_LINKDROP_SIGNER_SIGNATURE"
        );

        require
        (
            verifyReceiverSignature(_linkId, _receiver, _receiverSignature),
            "INVALID_RECEIVER_SIGNATURE"
        );

        return true;
    }

    function claim
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        uint _expiration,
        address _linkId,
        bytes calldata _linkdropSignerSignature,
        address payable _receiver,
        bytes calldata _receiverSignature
    )
    external
    override       
    onlyFactory
    whenNotPaused
    returns (bool)
    {

        require
        (
            checkClaimParams
            (
                _weiAmount,
                _tokenAddress,
                _tokenAmount,
                _expiration,
                _linkId,
                _linkdropSignerSignature,
                _receiver,
                _receiverSignature
            ),
            "INVALID_CLAIM_PARAMS"
        );

        claimedTo[_linkId] = _receiver;

        require(_transferFunds(_weiAmount, _tokenAddress, _tokenAmount, _receiver), "TRANSFER_FAILED");

        emit Claimed(_linkId, _weiAmount, _tokenAddress, _tokenAmount, _receiver);

        return true;
    }

    function _transferFunds
    (
        uint _weiAmount,
        address _tokenAddress,
        uint _tokenAmount,
        address payable _receiver
    )
    internal returns (bool)
    {

      if (tx.origin != _receiver) { 
        feeReceiver.transfer(sponsoredFeeAmount);
      }
      
        if (_weiAmount > 0) {
            _receiver.transfer(_weiAmount);
        }

        if (_tokenAmount > 0) {
            IERC20(_tokenAddress).transferFrom(linkdropMaster, _receiver, _tokenAmount);
        }

        return true;
    }

}

pragma solidity >=0.6.0 <0.8.0;


contract LinkdropMastercopy is LinkdropERC20, LinkdropERC721, LinkdropERC1155 {


}