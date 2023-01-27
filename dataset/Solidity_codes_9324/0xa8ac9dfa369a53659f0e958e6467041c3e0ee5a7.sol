
pragma solidity ^0.8.0;

interface ITokenFactory {

    function createToken(
        uint256 _supply,
        address _receiver,
        address _settingOperator,
        bool _needTime,
        bool _erc20
    ) external returns(uint256);

    
    function createToken(
        uint256 _supply,
        address _receiver,
        address _settingOperator,
        bool _needTime,
        string calldata _uri,
        bool _erc20
    ) external returns(uint256);


    function createTokenWithRecording(
        uint256 _supply,
        uint256 _supplyOfRecording,
        address _receiver,
        address _settingOperator,
        bool _needTime,
        address _recordingOperator,
        bool _erc20
    ) external returns(uint256);


    function createTokenWithRecording(
        uint256 _supply,
        uint256 _supplyOfRecording,
        address _receiver,
        address _settingOperator,
        bool _needTime,
        address _recordingOperator,
        string calldata _uri,
        bool _erc20,
        bool _mapNft
    ) external returns(uint256);

    
    function setTimeInterval(
        uint256 _tokenId,
        uint128 _startTime,
        uint128 _endTime
    ) external;


    function holdingTimeOf(
        address _owner,
        uint256 _tokenId
    ) external view returns(uint256);


    function recordingHoldingTimeOf(
        address _owner,
        uint256 _tokenId
    ) external view returns(uint256);


    function setERC20Attribute(
        uint256 _tokenId,
        string memory _name,
        string memory _symbol,
        uint8 decimals
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Metadata /* is ERC721 */ {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 _tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

interface IERC1155Metadata {

    function uri(uint256 _id) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

interface IERC1155 /* is ERC165 */ {

    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _tokenId, uint256 _value);

    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _tokenIds, uint256[] _values);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    event URI(string _value, uint256 indexed _tokenId);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, uint256 _value, bytes calldata _data) external;


    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _tokenIds, uint256[] calldata _values, bytes calldata _data) external;


    function setApprovalForAll(address _operator, bool _approved) external;


    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _tokenIds) external view returns (uint256[] memory);


    function balanceOf(address _owner, uint256 _tokenId) external view returns (uint256);


    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC1155TokenReceiver {

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) external returns(bytes4);


    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external returns(bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC165 {


    function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 {


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function setApprovalForAll(address operator, bool _approved) external;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    
    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address recipient, uint256 amount) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;


interface IERC20Adapter is IERC20 {

    function emitTransfer(
        address _from,
        address _to,
        uint256 _value
    ) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        return msg.data;
    }
}// MIT

pragma solidity 0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
}// MIT

pragma solidity 0.8.1;


contract ERC1155ERC721 is IERC165, IERC1155, IERC721, Context {

    using Address for address;
    
    mapping(uint256 => uint256) internal _totalSupply;
    mapping(address => mapping(uint256 => uint256)) internal _ftBalances;
    mapping(address => uint256) internal _nftBalances;
    mapping(uint256 => address) internal _nftOwners;
    mapping(uint256 => address) internal _nftOperators;
    mapping(address => mapping(uint256 => uint256)) internal _recordingBalances;
    mapping(uint256 => address) internal _recordingOperators;
    mapping(address => mapping(address => bool)) internal _operatorApproval;
    mapping(uint256 => address) internal _settingOperators;
    mapping(uint256 => uint256) internal _timeInterval;
    mapping(address => mapping(uint256 => uint256)) internal _lastUpdateAt;
    mapping(address => mapping(uint256 => uint256)) internal _holdingTime;
    mapping(address => mapping(uint256  => uint256)) internal _recordingLastUpdateAt;
    mapping(address => mapping(uint256  => uint256)) internal _recordingHoldingTime;
    
    bytes4 constant private ERC1155_ACCEPTED = 0xf23a6e61;
    bytes4 constant private ERC1155_BATCH_ACCEPTED = 0xbc197c81;
    bytes4 constant private ERC721_ACCEPTED = 0x150b7a02;
    bytes4 constant private INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;
    bytes4 constant private INTERFACE_SIGNATURE_ERC1155 = 0xd9b67a26;
    bytes4 constant private INTERFACE_SIGNATURE_ERC1155Receiver = 0x4e2312e0;
    bytes4 constant private INTERFACE_SIGNATURE_ERC721 = 0x80ac58cd;

    uint256 private constant IS_NFT = 1 << 255;
    uint256 internal constant NEED_TIME = 1 << 254;
    uint256 private idNonce;
    
    
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    
    event RecordingTransferSingle(address _operator, address indexed _from, address indexed _to, uint256 indexed _tokenId, uint256 _value);
    
    event TimeInterval(uint256 indexed _tokenId, uint256 _startTime, uint256 _endTime);

    modifier AuthorizedTransfer(
        address _operator,
        address _from,
        uint _tokenId
    ) {

        require(
            _from == _operator ||
            _nftOperators[_tokenId] == _operator ||
            _operatorApproval[_from][_operator],
            "Not authorized"
        );
        _;
    }

    
    function settingOperatorOf(uint256 _tokenId)
        external
        view
        returns (address)
    {

        return _settingOperators[_tokenId];
    }

    function recordingOperatorOf(uint256 _tokenId)
        external
        view
        returns (address)
    {

        return _recordingOperators[_tokenId];
    }

    function timeIntervalOf(uint256 _tokenId)
        external
        view
        returns (uint256, uint256)
    {

        uint256 startTime = uint256(uint128(_timeInterval[_tokenId]));
        uint256 endTime = uint256(_timeInterval[_tokenId] >> 128);
        return (startTime, endTime);
    }

    
    function supportsInterface(
        bytes4 _interfaceId
    )
        public
        pure
        virtual
        override
        returns (bool)
    {

        if (_interfaceId == INTERFACE_SIGNATURE_ERC165 ||
            _interfaceId == INTERFACE_SIGNATURE_ERC1155 || 
            _interfaceId == INTERFACE_SIGNATURE_ERC721) {
            return true;
        }
        return false;
    }
    

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _value,
        bytes calldata _data
    ) 
        external
        override
        AuthorizedTransfer(_msgSender(), _from, _tokenId)
    {

        require(_to != address(0x0), "_to must be non-zero.");
        if (_tokenId & IS_NFT > 0) {
            if (_value > 0) {
                require(_value == 1, "NFT amount more than 1");
                safeTransferFrom(_from, _to, _tokenId, _data);
            }
            return;
        }

        if (_tokenId & NEED_TIME > 0) {
           _updateHoldingTime(_from, _tokenId);
           _updateHoldingTime(_to, _tokenId);
        }
        _transferFrom(_from, _to, _tokenId, _value);

        if (_to.isContract()) {
            require(_checkReceivable(_msgSender(), _from, _to, _tokenId, _value, _data, false, false),
                    "Transfer rejected");
        }
    }
    
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _tokenIds,
        uint256[] calldata _values,
        bytes calldata _data
    )
        external
        override
    {

        require(_to != address(0x0), "_to must be non-zero.");
        require(_tokenIds.length == _values.length, "Array length must match.");
        bool authorized = _from == _msgSender() || _operatorApproval[_from][_msgSender()];
            
        _batchUpdateHoldingTime(_from, _tokenIds);
        _batchUpdateHoldingTime(_to, _tokenIds);
        _batchTransferFrom(_from, _to, _tokenIds, _values, authorized);
        
        if (_to.isContract()) {
            require(_checkBatchReceivable(_msgSender(), _from, _to, _tokenIds, _values, _data),
                    "BatchTransfer rejected");
        }
    }
    
    
    function balanceOf(
        address _owner,
        uint256 _tokenId
    )
        public
        view
        virtual
        override
        returns (uint256) 
    {

        if (_tokenId & IS_NFT > 0) {
            if (_ownerOf(_tokenId) == _owner)
                return 1;
            else
                return 0;
        }
        return _ftBalances[_owner][_tokenId];
    }
    
    function balanceOfBatch(
        address[] calldata _owners,
        uint256[] calldata _tokenIds
    )
        external
        view
        override
        returns (uint256[] memory)
    {

        require(_owners.length == _tokenIds.length, "Array lengths should match");

        uint256[] memory balances_ = new uint256[](_owners.length);
        for (uint256 i = 0; i < _owners.length; ++i) {
            balances_[i] = balanceOf(_owners[i], _tokenIds[i]);
        }

        return balances_;
    }

    function setApprovalForAll(
        address _operator,
        bool _approved
    )
        external
        override(IERC1155, IERC721)
    {

        _operatorApproval[_msgSender()][_operator] = _approved;
        emit ApprovalForAll(_msgSender(), _operator, _approved);
    }
    
    function isApprovedForAll(
        address _owner,
        address _operator
    ) 
        external
        view
        override(IERC1155, IERC721)
        returns (bool) 
    {

        return _operatorApproval[_owner][_operator];
    }


    function balanceOf(address _owner) 
        external
        view
        override
        returns (uint256) 
    {

        return _nftBalances[_owner];
    }
    

    function ownerOf(uint256 _tokenId)
        external
        view
        override
        returns (address) 
    {

        address owner = _ownerOf(_tokenId);
        require(owner != address(0), "Not nft or not exist");
        return owner;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) 
        external
        override
    {

        safeTransferFrom(_from, _to, _tokenId, "");
    }
    
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    )
        public
        override
        AuthorizedTransfer(_msgSender(), _from, _tokenId)
    {

        require(_to != address(0), "_to must be non-zero");
        require(_nftOwners[_tokenId] == _from, "Not owner or it's not nft");
        
        if (_tokenId & NEED_TIME > 0) {
           _updateHoldingTime(_from, _tokenId);
           _updateHoldingTime(_to, _tokenId);
        }
        _transferFrom(_from, _to, _tokenId, 1);
        
        if (_to.isContract()) {
            require(_checkReceivable(_msgSender(), _from, _to, _tokenId, 1, _data, true, true),
                    "Transfer rejected");
        }
    }
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) 
        external
        override
        AuthorizedTransfer(_msgSender(), _from, _tokenId)
    {

        require(_to != address(0), "_to must be non-zero");
        require(_nftOwners[_tokenId] == _from, "Not owner or it's not nft");
                
        if (_tokenId & NEED_TIME > 0) {
           _updateHoldingTime(_from, _tokenId);
           _updateHoldingTime(_to, _tokenId);
        }
        _transferFrom(_from, _to, _tokenId, 1);

        if (_to.isContract()) {
            require(_checkReceivable(_msgSender(), _from, _to, _tokenId, 1, "", true, false),
                    "Transfer rejected");
        }
    }
    
    function approve(
        address _to,
        uint256 _tokenId
    )
        external
        override 
    {

        address owner = _nftOwners[_tokenId];
        require(owner == _msgSender() || _operatorApproval[owner][_msgSender()],
                "Not authorized or not a nft");
        _nftOperators[_tokenId] = _to;
        emit Approval(owner, _to, _tokenId);
    }
    
    function getApproved(uint256 _tokenId) 
        external
        view
        override
        returns (address) 
    {

        require(_tokenId & IS_NFT > 0, "Not a nft");
        return _nftOperators[_tokenId];
    }

    
    function recordingTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _value
    ) 
        external
    {

        require(_msgSender() == _recordingOperators[_tokenId], "Not authorized");
        require(_to != address(0), "_to must be non-zero");

       _updateRecordingHoldingTime(_from, _tokenId);
       _updateRecordingHoldingTime(_to, _tokenId);
        _recordingTransferFrom(_from, _to, _tokenId, _value);
    }
    
    function recordingBalanceOf(
        address _owner,
        uint256 _tokenId
    ) 
        public 
        view
        returns (uint256)
    {

        return _recordingBalances[_owner][_tokenId];
    }
    

    function _updateHoldingTime(
        address _owner,
        uint256 _tokenId
    )
        internal
    {

        require(_tokenId & NEED_TIME > 0, "Doesn't support this token");

        _holdingTime[_owner][_tokenId] += _calcHoldingTime(_owner, _tokenId);
        _lastUpdateAt[_owner][_tokenId] = block.timestamp;
    }

    function _batchUpdateHoldingTime(
        address _owner,
        uint256[] memory _tokenIds
    )
        internal
    {

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            if (_tokenIds[i] & NEED_TIME > 0)
               _updateHoldingTime(_owner, _tokenIds[i]);
        }
    }
    
    function _updateRecordingHoldingTime(
        address _owner,
        uint256 _tokenId
    )
        internal
    {

        _recordingHoldingTime[_owner][_tokenId] += _calcRecordingHoldingTime(_owner, _tokenId);
        _recordingLastUpdateAt[_owner][_tokenId] = block.timestamp;
    }


    function _calcHoldingTime(
        address _owner,
        uint256 _tokenId
    )
        internal
        view
        returns (uint256)
    {

        uint256 lastTime = _lastUpdateAt[_owner][_tokenId];
        uint256 startTime = uint256(uint128(_timeInterval[_tokenId]));
        uint256 endTime = uint256(_timeInterval[_tokenId] >> 128);
        uint256 balance = balanceOf(_owner, _tokenId);

        if (balance == 0)
            return 0;
        if (startTime == 0 || startTime >= block.timestamp)
            return 0;
        if (lastTime >= endTime)
            return 0;
        if (lastTime < startTime)
            lastTime = startTime;

        if (block.timestamp > endTime)
            return balance * (endTime - lastTime);
        else
            return balance * (block.timestamp - lastTime);
    }

    function _calcRecordingHoldingTime(
        address _owner,
        uint256 _tokenId
    )
        internal
        view
        returns (uint256)
    {

        uint256 lastTime = _recordingLastUpdateAt[_owner][_tokenId];
        uint256 startTime = uint256(uint128(_timeInterval[_tokenId]));
        uint256 endTime = uint256(_timeInterval[_tokenId] >> 128);
        uint256 balance = recordingBalanceOf(_owner, _tokenId);

        if (balance == 0)
            return 0;
        if (startTime == 0 || startTime >= block.timestamp)
            return 0;
        if (lastTime >= endTime)
            return 0;
        if (lastTime < startTime)
            lastTime = startTime;

        if (block.timestamp > endTime)
            return balance * (endTime - lastTime);
        else
            return balance * (block.timestamp - lastTime);
    }

    function _setTime(
        uint256 _tokenId,
        uint128 _startTime,
        uint128 _endTime
    )
        internal
    {

        uint256 timeInterval = _startTime + (uint256(_endTime) << 128);
        _timeInterval[_tokenId] = timeInterval;

        emit TimeInterval(_tokenId, uint256(_startTime), uint256(_endTime));
    }

    function _recordingTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _value
    )
        internal
    {

        _recordingBalances[_from][_tokenId] -= _value;
        _recordingBalances[_to][_tokenId] += _value;
        emit RecordingTransferSingle(_msgSender(), _from, _to, _tokenId, _value);
    }
    
    function _batchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _tokenIds,
        uint256[] memory _values,
        bool authorized
    ) 
        internal
    {

        uint256 numNFT;
        
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            if (_values[i] > 0) {
                if (_tokenIds[i] & IS_NFT > 0) {
                    require(_values[i] == 1, "NFT amount is not 1");
                    require(_nftOwners[_tokenIds[i]] == _from, "_from is not owner");
                    require(_nftOperators[_tokenIds[i]] == _msgSender() || authorized, "Not authorized");
                    numNFT++;
                    _nftOwners[_tokenIds[i]] = _to;
                    _nftOperators[_tokenIds[i]] = address(0);
                    emit Transfer(_from, _to, _tokenIds[i]);
                } else {
                    require(authorized, "Not authorized");
                    _ftBalances[_from][_tokenIds[i]] -= _values[i];
                    _ftBalances[_to][_tokenIds[i]] += _values[i];
                }
            }
        }
        _nftBalances[_from] -= numNFT;
        _nftBalances[_to] += numNFT;

        emit TransferBatch(_msgSender(), _from, _to, _tokenIds, _values);
    }
    
    function _mint(
        uint256 _supply,
        address _receiver,
        address _settingOperator,
        bool _needTime,
        bytes memory _data
    )
        internal
        returns (uint256)
    {

        uint256 tokenId = ++idNonce;
        if (_needTime)
            tokenId |= NEED_TIME;

        if (_supply == 1) {
            tokenId |= IS_NFT;
            _nftBalances[_receiver]++;
            _nftOwners[tokenId] = _receiver;
            emit Transfer(address(0), _receiver, tokenId);
        } else {
            _ftBalances[_receiver][tokenId] += _supply;
        }

        _totalSupply[tokenId] += _supply;
        _settingOperators[tokenId] = _settingOperator;
        
        emit TransferSingle(_msgSender(), address(0), _receiver, tokenId, _supply);
        
        if (_receiver.isContract()) {
            require(_checkReceivable(_msgSender(), address(0), _receiver, tokenId, _supply, _data, false, false),
                    "Transfer rejected");
        }
        return tokenId;
    }
    
    function _mintCopy(
        uint256 _tokenId,
        uint256 _supply,
        address _recordingOperator
    )
        internal
    {

        _recordingBalances[_recordingOperator][_tokenId] += _supply;
        _recordingOperators[_tokenId] = _recordingOperator;
        emit RecordingTransferSingle(_msgSender(), address(0), _recordingOperator, _tokenId, _supply);
    }
    
    function _checkReceivable(
        address _operator,
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _value,
        bytes memory _data,
        bool _erc721erc20,
        bool _erc721safe
    )
        internal
        returns (bool)
    {

        if (_erc721erc20 && !_checkIsERC1155Receiver(_to)) {
            if (_erc721safe)
                return _checkERC721Receivable(_operator, _from, _to, _tokenId, _data);
            else
                return true;
        }
        return _checkERC1155Receivable(_operator, _from, _to, _tokenId, _value, _data);
    }
    
    function _checkERC1155Receivable(
        address _operator,
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _value,
        bytes memory _data
    )
        internal
        returns (bool)
    {

        return (IERC1155TokenReceiver(_to).onERC1155Received(_operator, _from, _tokenId, _value, _data) == ERC1155_ACCEPTED);
    }
    
    function _checkERC721Receivable(
        address _operator,
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    )
        internal
        returns (bool)
    {

        return (IERC721Receiver(_to).onERC721Received(_operator, _from, _tokenId, _data) == ERC721_ACCEPTED);
    }
    
    function _checkIsERC1155Receiver(address _to) 
        internal
        returns (bool)
    {

        (bool success, bytes memory data) = _to.call(
            abi.encodeWithSelector(IERC165.supportsInterface.selector, INTERFACE_SIGNATURE_ERC1155Receiver));
        if (!success)
            return false;
        bool result = abi.decode(data, (bool));
        return result;
    }
    
    function _checkBatchReceivable(
        address _operator,
        address _from,
        address _to,
        uint256[] memory _tokenIds,
        uint256[] memory _values,
        bytes memory _data
    )
        internal
        returns (bool)
    {

        return (IERC1155TokenReceiver(_to).onERC1155BatchReceived(_operator, _from, _tokenIds, _values, _data)
                == ERC1155_BATCH_ACCEPTED);
    }
    
    function _ownerOf(uint256 _tokenId)
        internal
        view
        returns (address)
    {

        return _nftOwners[_tokenId]; 
    }
    
    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _value
    )
        internal
        virtual
    {

        if (_tokenId & IS_NFT > 0) {
            if (_value > 0) {
                require(_value == 1, "NFT amount more than 1");
                _nftOwners[_tokenId] = _to;
                _nftBalances[_from]--;
                _nftBalances[_to]++;
                _nftOperators[_tokenId] = address(0);
                
                emit Transfer(_from, _to, _tokenId);
            }
        } else {
            if (_value > 0) {
                _ftBalances[_from][_tokenId] -= _value;
                _ftBalances[_to][_tokenId] += _value;
            }
        }
        
        emit TransferSingle(_msgSender(), _from, _to, _tokenId, _value);
    }
}// MIT

pragma solidity 0.8.1;


contract ERC1155ERC721Metadata is ERC1155ERC721, IERC721Metadata, IERC1155Metadata {

    mapping(uint256 => string) internal _tokenURI;

    bytes4 constant private INTERFACE_SIGNATURE_ERC1155Metadata = 0x0e89341c;
    bytes4 constant private INTERFACE_SIGNATURE_ERC721Metadata = 0x5b5e139f;
    
    function supportsInterface(
        bytes4 _interfaceId
    )
        public
        pure
        virtual
        override
        returns (bool)
    {

        if (_interfaceId == INTERFACE_SIGNATURE_ERC1155Metadata ||
            _interfaceId == INTERFACE_SIGNATURE_ERC721Metadata) {
            return true;
        } else {
            return super.supportsInterface(_interfaceId);
        }
    }

    function uri(uint256 _tokenId)
        external
        view
        override
        returns (string memory)
    {

       return _tokenURI[_tokenId]; 
    }

    function name()
        external
        pure
        override
        returns (string memory)
    {

        return "DigiQuick";
    }

    function symbol()
        external
        pure
        override
        returns (string memory)
    {

        return "DQ";
    }

    function tokenURI(uint256 _tokenId)
        external
        view
        override
        returns (string memory)
    {

        require(_nftOwners[_tokenId] != address(0), "Nft not exist");
        return _tokenURI[_tokenId];
    }

    function _setTokenURI(
        uint256 _tokenId,
        string memory _uri
    )
        internal
    {

        _tokenURI[_tokenId] = _uri;
    }
}// MIT

pragma solidity 0.8.1;


contract ERC1155ERC721WithAdapter is
    ERC1155ERC721
{

    using Address for address;

    mapping(uint256 => address) internal _adapters;
    address public template;

    event NewAdapter(uint256 indexed _tokenId, address indexed _adapter);

    constructor() {
        template = address(new ERC20Adapter());
    }

    function totalSupply(uint256 _tokenId)
        external
        view
        returns (uint256)
    {

        return _totalSupply[_tokenId];
    }

    function getAdapter(uint256 _tokenId)
        external
        view
        returns (address)
    {

        return _adapters[_tokenId];  
    }

    function transferByAdapter(
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _value
    )
        external
    {

        require(_adapters[_tokenId] == msg.sender, "Not adapter");

        if (_tokenId & NEED_TIME > 0) {
            _updateHoldingTime(_from, _tokenId);
            _updateHoldingTime(_to, _tokenId);
        }
        _transferFrom(_from, _to, _tokenId, _value);

        if (_to.isContract()) {
            require(
                _checkReceivable(msg.sender, _from, _to, _tokenId, _value, "", true, false),
                "Transfer rejected"
            );
        }
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _value
    )
        internal
        virtual
        override
    {

        super._transferFrom(_from, _to, _tokenId, _value);
        address adapter = _adapters[_tokenId];
        if (adapter != address(0))
            ERC20Adapter(adapter).emitTransfer(_from, _to, _value);
    }


    function _setERC20Attribute(
        uint256 _tokenId,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    )
        internal
    {

        address adapter = _adapters[_tokenId];
        ERC20Adapter(adapter).setAttribute(_name, _symbol, _decimals);
    }

    function _createAdapter(uint256 _tokenId)
        internal
    {

        address adapter = _createClone(template);
        _adapters[_tokenId] = adapter;
        ERC20Adapter(adapter).initialize(_tokenId);
        emit NewAdapter(_tokenId, adapter);
    }

    function _createClone(address target)
        internal
        returns (address result)
    {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
                mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
                mstore(add(clone, 0x14), targetBytes)
                mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
                result := create(0, clone, 0x37)
        }
    }
}

contract ERC20Adapter is IERC20Adapter {

    mapping(address => mapping(address => uint256)) private _allowances;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public tokenId;
    ERC1155ERC721WithAdapter public entity;

    function initialize(uint256 _tokenId)
       external
    {

        require(address(entity) == address(0), "Already initialized");
        entity = ERC1155ERC721WithAdapter(msg.sender);
        tokenId = _tokenId;
    }

    function setAttribute(
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals
    )
        external
    {

        require(msg.sender == address(entity), "Not entity");
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function totalSupply()
       external
       view
       override
       returns (uint256)
    {

        return entity.totalSupply(tokenId);
    }

    function balanceOf(address owner)
        external
        view
        override
        returns (uint256)
    {

        return entity.balanceOf(owner, tokenId);
    }

    function allowance(
        address _owner,
        address _spender
    )
        external
        view
        override
        returns (uint256)
    {

        return _allowances[_owner][_spender];
    }

    function approve(
        address _spender,
        uint256 _value
    )
        external
        override
        returns (bool)
    {

        require(_spender != address(0), "Approve to zero address"); 
        _approve(msg.sender, _spender, _value); 
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        override
        returns (bool)
    {

        require(_to != address(0), "_to must be non-zero");

        _approve(_from, msg.sender, _allowances[_from][msg.sender] - _value);
        _transfer(_from, _to, _value);
        return true;
    }


    function transfer(
        address _to,
        uint256 _value
    )
        external
        override
        returns (bool)
    {

        require(_to != address(0), "_to must be non-zero");

        _transfer(msg.sender, _to, _value);
        return true;
    }

    function emitTransfer(
        address _from,
        address _to,
        uint256 _value
    )
        external
        override
    {

        require(msg.sender == address(entity), "Not entity");

        emit Transfer(_from, _to, _value);
    }
    
    function _approve(
        address _owner,
        address _spender,
        uint256 _value
    )
        internal
    {

        _allowances[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    )
        internal
    {

        entity.transferByAdapter(_from, _to, tokenId, _value);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract IRelayRecipient {

    function isTrustedForwarder(address forwarder) public virtual view returns(bool);

    function _msgSender() internal virtual view returns (address payable);

    function _msgData() internal virtual view returns (bytes memory);

    function versionRecipient() external virtual view returns (string memory);
}// MIT

pragma solidity 0.8.1;


abstract contract BaseRelayRecipient is IRelayRecipient {

    address public trustedForwarder;

    function isTrustedForwarder(address forwarder) public override view returns(bool) {
        return forwarder == trustedForwarder;
    }

    function _msgSender() internal override virtual view returns (address payable ret) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            assembly {
                ret := shr(96,calldataload(sub(calldatasize(),20)))
            }
        } else {
            return payable(msg.sender);
        }
    }

    function _msgData() internal override virtual view returns (bytes memory ret) {
        if (msg.data.length >= 20 && isTrustedForwarder(msg.sender)) {
            return msg.data[0:msg.data.length-20];
        } else {
            return msg.data;
        }
    }
}// MIT

pragma solidity 0.8.1;


contract TokenFactory is
    ITokenFactory,
    ERC1155ERC721Metadata,
    ERC1155ERC721WithAdapter,
    BaseRelayRecipient
{

    constructor (address _trustedForwarder) {
        trustedForwarder = _trustedForwarder;
    }

    event TokenMapId(uint256 indexed _tokenId, uint256 indexed _tokenMapId);

    function supportsInterface(bytes4 _interfaceId)
        public
        pure
        override(ERC1155ERC721Metadata, ERC1155ERC721)
        returns (bool)
    {

        return super.supportsInterface(_interfaceId);
    }

    function holdingTimeOf(
        address _owner,
        uint256 _tokenId
    )
        external
        view
        override
        returns (uint256)
    {

        require(_tokenId & NEED_TIME > 0, "Doesn't support this token");
        
        return _holdingTime[_owner][_tokenId] + _calcHoldingTime(_owner, _tokenId);
    }

    function recordingHoldingTimeOf(
        address _owner,
        uint256 _tokenId
    )
        external
        view
        override
        returns (uint256)
    {

        return _recordingHoldingTime[_owner][_tokenId] + _calcRecordingHoldingTime(_owner, _tokenId);
    }

    function createToken(
        uint256 _supply,
        address _receiver,
        address _settingOperator,
        bool _needTime,
        bool _erc20
    )
        public 
        override
        returns (uint256)
    {

        uint256 tokenId = _mint(_supply, _receiver, _settingOperator, _needTime, "");
        if (_erc20)
            _createAdapter(tokenId);
        return tokenId;
    }
    
    function createToken(
        uint256 _supply,
        address _receiver,
        address _settingOperator,
        bool _needTime,
        string calldata _uri,
        bool _erc20
    )
        external
        override
        returns (uint256)
    {

        uint256 tokenId = createToken(_supply, _receiver, _settingOperator, _needTime, _erc20);
        _setTokenURI(tokenId, _uri);
        return tokenId;
    }

    function createTokenWithRecording(
        uint256 _supply,
        uint256 _supplyOfRecording,
        address _receiver,
        address _settingOperator,
        bool _needTime,
        address _recordingOperator,
        bool _erc20
    )
        public
        override
        returns (uint256)
    {

        uint256 tokenId = createToken(_supply, _receiver, _settingOperator, _needTime, _erc20);
        _mintCopy(tokenId, _supplyOfRecording, _recordingOperator);
        return tokenId;
    }

    function createTokenWithRecording(
        uint256 _supply,
        uint256 _supplyOfRecording,
        address _receiver,
        address _settingOperator,
        bool _needTime,
        address _recordingOperator,
        string calldata _uri,
        bool _erc20,
        bool _mapNft
    )
        external
        override
        returns (uint256)
    {

        uint256 tokenId = createToken(_supply, _receiver, _settingOperator, _needTime, _erc20);
        if (_mapNft) {
            uint256 tokenMapId = createToken(1, _receiver, _settingOperator, false, false);
            _setTokenURI(tokenMapId, _uri);
            emit TokenMapId(tokenId, tokenMapId);
        }
        _mintCopy(tokenId, _supplyOfRecording, _recordingOperator);
        _setTokenURI(tokenId, _uri);
        return 0;
    }
    
    function setTimeInterval(
        uint256 _tokenId,
        uint128 _startTime,
        uint128 _endTime
    )
        external
        override
    {

        require(_msgSender() == _settingOperators[_tokenId], "Not authorized");
        require(_startTime >= block.timestamp, "Time smaller than now");
        require(_endTime > _startTime, "End greater than start");
        require(_timeInterval[_tokenId] == 0, "Already set");

        _setTime(_tokenId, _startTime, _endTime);
    }
    
    function setERC20Attribute(
        uint256 _tokenId,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    )
        external
        override
    {

        require(_msgSender() == _settingOperators[_tokenId], "Not authorized");
        require(_adapters[_tokenId] != address(0), "No adapter found");

        _setERC20Attribute(_tokenId, _name, _symbol, _decimals);
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _value
    )
        internal
        override(ERC1155ERC721, ERC1155ERC721WithAdapter)
    {

        super._transferFrom(_from, _to, _tokenId, _value);
    }

    function versionRecipient()
        external
        override
        virtual
        view
        returns (string memory)
    {

        return "2.1.0";
    }

    function _msgSender()
        internal
        override(Context, BaseRelayRecipient)
        view
        returns (address payable)
    {

        return BaseRelayRecipient._msgSender();
    }
    
    function _msgData()
        internal
        override(Context, BaseRelayRecipient)
        view
        returns (bytes memory)
    {

        return BaseRelayRecipient._msgData();
    }
}