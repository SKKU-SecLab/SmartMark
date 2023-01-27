



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

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

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




abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
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



pragma solidity ^0.8.9;

interface IStandarERC721 {

    function mint(address _to, uint256 _tokenId) external;

}



pragma solidity ^0.8.9;

interface IStandarERC1155 {

    function mint(address to, uint256 id, uint256 amount, bytes memory data) external;

}



pragma solidity >0.5.0 <0.9.0;

interface ICrossDomainMessenger {


    event SentMessage(
        address indexed target,
        address sender,
        bytes message,
        uint256 messageNonce,
        uint256 gasLimit,
        uint256 chainId
    );
    event RelayedMessage(bytes32 indexed msgHash);
    event FailedRelayedMessage(bytes32 indexed msgHash);


    function xDomainMessageSender() external view returns (address);


    
    function sendMessage(
        address _target,
        bytes calldata _message,
        uint32 _gasLimit
    ) external payable;



    function sendMessageViaChainId(
        uint256 _chainId,
        address _target,
        bytes calldata _message,
        uint32 _gasLimit
    ) external payable;


}





contract CrossDomainEnabled {


    address public messenger;



    constructor(address _messenger) {
        messenger = _messenger;
    }


    modifier onlyFromCrossDomainAccount(address _sourceDomainAccount) {

        require(
            msg.sender == address(getCrossDomainMessenger()),
            "OVM_XCHAIN: messenger contract unauthenticated"
        );

        require(
            getCrossDomainMessenger().xDomainMessageSender() == _sourceDomainAccount,
            "OVM_XCHAIN: wrong sender of cross-domain message"
        );

        _;
    }


    function getCrossDomainMessenger() internal virtual returns (ICrossDomainMessenger) {

        return ICrossDomainMessenger(messenger);
    }

    function sendCrossDomainMessage(
        address _crossDomainTarget,
        uint32 _gasLimit,
        bytes memory _message,
        uint256 fee
    )
        internal
    {

        getCrossDomainMessenger().sendMessage{value:fee}(_crossDomainTarget, _message, _gasLimit);
    }

    function sendCrossDomainMessageViaChainId(
        uint256 _chainId,
        address _crossDomainTarget,
        uint32 _gasLimit,
        bytes memory _message,
        uint256 fee
    ) internal {

        getCrossDomainMessenger().sendMessageViaChainId{value:fee}(_chainId, _crossDomainTarget, _message, _gasLimit);
    }
}



pragma solidity ^0.8.9;

interface ICrollDomain {

    function finalizeDeposit(address _nft, address _from, address _to, uint256 _id, uint256 _amount, uint8 nftStandard) external;

}



pragma solidity ^0.8.9;

interface ICrollDomainConfig {

    function configNFT(address L1NFT, address L2NFT, uint256 originNFTChainId) external;

}



pragma solidity ^0.8.9;

interface CommonEvent {

  
  event EVENT_SET(
        address indexed _deposit,
        address indexed _bridge
    );

    event CONFIT_NFT(
        address indexed _localNFT,
        address indexed _destNFT,
        uint256 _chainID
    );
    
    event DEPOSIT_TO(
        address _nft,
        address _from,
        address _to,
        uint256 _tokenID,
        uint256 _amount,
        uint8 nftStandard
    );
    
    event FINALIZE_DEPOSIT(
        address _nft,
        address _from,
        address _to,
        uint256 _tokenID,
        uint256 _amount,
        uint8 nftStandard
    );

    event DEPOSIT_FAILED(
        address _nft,
        address _from,
        address _to,
        uint256 _tokenID,
        uint256 _amount,
        uint8 nftStandard
    );


    event ROLLBACK(
        address _nft,
        address _from,
        address _to,
        uint256 _tokenID,
        uint256 _amount,
        uint8 nftStandard
    );
}



pragma solidity ^0.8.9;

interface INFTDeposit {


    function withdrawERC721(
        address _nft, 
        address _to, 
        uint256 _tokenId
    )
        external;


    function withdrawERC1155(
        address _nft, 
        address _to, 
        uint256 _tokenId, 
        uint256 _amount
    ) 
        external;

}



pragma solidity ^0.8.9;

interface iMVM_DiscountOracle{


    function setDiscount(
        uint256 _discount
    ) external;

    
    function setMinL2Gas(
        uint256 _minL2Gas
    ) external;

    
    function setWhitelistedXDomainSender(
        address _sender,
        bool _isWhitelisted
    ) external;

    
    function isXDomainSenderAllowed(
        address _sender
    ) view external returns(bool);

    
    function setAllowAllXDomainSenders(
        bool _allowAllXDomainSenders
    ) external;

    
    function getMinL2Gas() view external returns(uint256);

    function getDiscount() view external returns(uint256);

    function processL2SeqGas(address sender, uint256 _chainId) external payable;

}



pragma solidity ^0.8.9;

interface iLib_AddressManager {


    function getAddress(string memory _name) external view returns (address);


}



pragma solidity ^0.8.0;






contract L1NFTBridge is CrossDomainEnabled, AccessControl, CommonEvent {


    bytes32 public constant NFT_FACTORY_ROLE = keccak256("NFT_FACTORY_ROLE");
    bytes32 public constant ROLLBACK_ROLE = keccak256("ROLLBACK_ROLE");

    address public destNFTBridge;
    
    address public localNFTDeposit;
    
    address public addressManager;
    
    iMVM_DiscountOracle public oracle;

    uint256 public DEST_CHAINID = 1088;

    function getChainID() internal view returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    enum nftenum {
        ERC721,
        ERC1155
    }

    function setL2ChainID(uint256 chainID) public onlyRole(DEFAULT_ADMIN_ROLE) {

        DEST_CHAINID = chainID;
    }

    mapping(address => address) public clone;
    mapping(address => bool) public isOrigin;

    mapping(address => mapping( uint256 => bool )) public isDeposit;
    mapping(address => mapping( uint256 => address )) public depositUser;

    modifier onlyEOA() {

        require(!Address.isContract(msg.sender), "Account not EOA");
        _;
    }
    
    constructor(address _owner, address _nftFactory, address _rollback, address _addressManager, address _localMessenger) CrossDomainEnabled(_localMessenger) {
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(NFT_FACTORY_ROLE, _nftFactory);
        _setupRole(ROLLBACK_ROLE, _rollback);

        addressManager = _addressManager;
        oracle = iMVM_DiscountOracle(iLib_AddressManager(addressManager).getAddress('MVM_DiscountOracle'));
    }
    
    function set(address _localNFTDeposit, address _destNFTBridge) public onlyRole(DEFAULT_ADMIN_ROLE){

        
        require(destNFTBridge == address(0), "Already configured.");

        localNFTDeposit = _localNFTDeposit;
        destNFTBridge = _destNFTBridge;
        
        emit EVENT_SET(localNFTDeposit, destNFTBridge);
    }
    
    function configNFT(address localNFT, address destNFT, uint256 originNFTChainId, uint32 destGasLimit) external payable onlyRole(NFT_FACTORY_ROLE) {


        uint256 localChainId = getChainID();

        require((originNFTChainId == DEST_CHAINID || originNFTChainId == localChainId), "ChainId not supported");

        require(clone[localNFT] == address(0), "NFT already configured.");

        uint32 minGasLimit = uint32(oracle.getMinL2Gas());
        if (destGasLimit < minGasLimit) {
            destGasLimit = minGasLimit;
        }
        require(destGasLimit * oracle.getDiscount() <= msg.value, string(abi.encodePacked("insufficient fee supplied. send at least ", uint2str(destGasLimit * oracle.getDiscount()))));

        clone[localNFT] = destNFT;

        isOrigin[localNFT] = false;
        if(localChainId == originNFTChainId){
            isOrigin[localNFT] = true;
        }

        bytes memory message = abi.encodeWithSelector(
            ICrollDomainConfig.configNFT.selector,
            localNFT,
            destNFT,
            originNFTChainId
        );
        
        sendCrossDomainMessageViaChainId(
            DEST_CHAINID,
            destNFTBridge,
            destGasLimit,
            message,
            msg.value
        );

         emit CONFIT_NFT(localNFT, destNFT, originNFTChainId);
    }

    function depositTo(address localNFT, address destTo, uint256 id,  nftenum nftStandard, uint32 destGasLimit) external onlyEOA() payable {

       
        require(clone[localNFT] != address(0), "NFT not config.");

        require(isDeposit[localNFT][id] == false, "Don't redeposit.");

        uint32 minGasLimit = uint32(oracle.getMinL2Gas());
        if (destGasLimit < minGasLimit) {
            destGasLimit = minGasLimit;
        }
        
        require(destGasLimit * oracle.getDiscount() <= msg.value, string(abi.encodePacked("insufficient fee supplied. send at least ", uint2str(destGasLimit * oracle.getDiscount()))));
        
        uint256 amount = 0;
       
        if(nftenum.ERC721 == nftStandard) {
            IERC721(localNFT).safeTransferFrom(msg.sender, localNFTDeposit, id);
        }
       
        if(nftenum.ERC1155 == nftStandard) {
            amount = IERC1155(localNFT).balanceOf(msg.sender, id);
            require(amount == 1, "Not an NFT token.");
            IERC1155(localNFT).safeTransferFrom(msg.sender, localNFTDeposit, id, amount, "");
        }
       
        _depositStatus(localNFT, id, msg.sender, true);
    
        address destNFT = clone[localNFT];
    
        _messenger(DEST_CHAINID, destNFT, msg.sender, destTo, id, amount, uint8(nftStandard), destGasLimit);

        emit DEPOSIT_TO(destNFT, msg.sender, destTo, id, amount, uint8(nftStandard));
    }

    function _depositStatus(address _nft, uint256 _id, address _user, bool _isDeposit) internal {

       isDeposit[_nft][_id] = _isDeposit;
       depositUser[_nft][_id] = _user;
    }
    
    function _messenger(uint256 chainId, address destNFT, address from, address destTo, uint256 id, uint256 amount, uint8 nftStandard, uint32 destGasLimit) internal {


        bytes memory message =  abi.encodeWithSelector(
            ICrollDomain.finalizeDeposit.selector,
            destNFT,
            from,
            destTo,
            id,
            amount,
            nftStandard
        );
        
        sendCrossDomainMessageViaChainId(
            chainId,
            destNFTBridge,
            destGasLimit,
            message,
            msg.value
        );
    }
    
    function finalizeDeposit(address _localNFT, address _destFrom, address _localTo, uint256 id, uint256 _amount, nftenum nftStandard) external onlyFromCrossDomainAccount(destNFTBridge) {

        
        if(nftenum.ERC721 == nftStandard) {
            if(isDeposit[_localNFT][id]){
                INFTDeposit(localNFTDeposit).withdrawERC721(_localNFT, _localTo, id);
            }else{
                if(isOrigin[_localNFT]){
                    emit DEPOSIT_FAILED(_localNFT, _destFrom, _localTo, id, _amount, uint8(nftStandard));
                }else{
                    IStandarERC721(_localNFT).mint(_localTo, id);
                }
            }
        }

        if(nftenum.ERC1155 == nftStandard) {
            if(isDeposit[_localNFT][id]){
                INFTDeposit(localNFTDeposit).withdrawERC1155(_localNFT, _localTo, id, _amount);
            }else{
                if(isOrigin[_localNFT]){
                    emit DEPOSIT_FAILED(_localNFT, _destFrom, _localTo, id, _amount, uint8(nftStandard));   
                }else{
                    IStandarERC1155(_localNFT).mint(_localTo, id, _amount, "");
                }
            }
        }
    
        _depositStatus(_localNFT, id, address(0), false);

        emit FINALIZE_DEPOSIT(_localNFT, _destFrom, _localTo, id, _amount, uint8(nftStandard));
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function rollback(nftenum nftStandard, address _localNFT, uint256[] memory ids) public onlyRole(ROLLBACK_ROLE) {

        
        for( uint256 index; index < ids.length; index++ ){
            
            uint256 id = ids[index];

            address _depositUser = depositUser[_localNFT][id];

            require(isDeposit[_localNFT][id], "Not Deposited");
            
            require(_depositUser != address(0), "user can not be zero address.");
            
            uint256 amount = 0;

            if(nftenum.ERC721 == nftStandard) {
                INFTDeposit(localNFTDeposit).withdrawERC721(_localNFT, _depositUser, id);
            }else{
                amount = 1;
                INFTDeposit(localNFTDeposit).withdrawERC1155(_localNFT, _depositUser, id, amount);
            }
    
            _depositStatus(_localNFT, id, address(0), false);

            emit ROLLBACK(_localNFT, localNFTDeposit, _depositUser, id, amount, uint8(nftStandard));
        }
    }
}