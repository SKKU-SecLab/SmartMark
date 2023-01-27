
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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

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

}// MIT

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
}// MIT
pragma solidity ^0.8.6;

contract SignatureVerify{


    function getEthSignedMessageHash(bytes32 _messageHash)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) internal pure returns (address) {

        require(_signature.length == 65, "invalid signature length");
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
}// MIT
pragma solidity ^0.8.4;

interface Ierc20 {

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);

}// MIT

pragma solidity ^0.8.6;

interface IUniqRedeem {

    event Redeemed(
        address indexed _contractAddress,
        uint256 indexed _tokenId,
        address indexed _redeemerAddress,
        string _redeemerName,
        uint256[] _purposes
    );

    function isTokenRedeemedForPurpose(
        address _address,
        uint256 _tokenId,
        uint256 _purpose
    ) external view returns (bool);


    function getMessageHash(
        address[] memory _tokenContracts,
        uint256[] memory _tokenIds,
        uint256[] memory _purposes,
        uint256 _price,
        address _paymentTokenAddress,
        uint256 _timestamp
    ) external pure returns (bytes32);


    function redeemManyTokens(
        address[] memory _tokenContracts,
        uint256[] memory _tokenIds,
        uint256[] memory _purposes,
        string memory _redeemerName,
        uint256 _price,
        address _paymentTokenAddress,
        bytes memory _signature,
        uint256 _timestamp
    ) external payable;


    function redeemTokenForPurposes(
        address _tokenContract,
        uint256 _tokenId,
        uint256[] memory _purposes,
        string memory _redeemerName,
        uint256 _price,
        address _paymentTokenAddress,
        bytes memory _signature,
        uint256 _timestamp
    ) external payable;


    function setTransactionOffset(uint256 _newOffset) external;


    function setStatusesForTokens(
        address[] memory _tokenAddresses,
        uint256[] memory _tokenIds,
        uint256[] memory _purposes,
        bool[] memory isRedeemed
    ) external;


    function withdrawERC20(address _address) external;


    function withdrawETH() external;

}// MIT

pragma solidity ^0.8.6;


interface IUniqRedeemV2 is IUniqRedeem {

    function redeemTokensAsAdmin(
        address[] memory _tokenContracts,
        uint256[] memory _tokenIds,
        uint256[] memory _purposes,
        string[] memory _redeemerName
    ) external;


    function redeemTokenForPurposesAsAdmin(
        address _tokenContract,
        uint256 _tokenId,
        uint256[] memory _purposes,
        string memory _redeemerName
    ) external;

}// MIT

pragma solidity ^0.8.6;


contract UniqRedeemV2 is Ownable, SignatureVerify {

    modifier ownerOrProxy() {

        require(
            owner() == msg.sender || _paymentProxy == msg.sender,
            "Only owner or proxy allowed"
        );
        _;
    }

    event Redeemed(
        address indexed _contractAddress,
        uint256 indexed _tokenId,
        address indexed _redeemerAddress,
        string _redeemerName,
        uint256[] _purposes
    );

    uint256 internal _transactionOffset;
    IUniqRedeem internal _oldRedeem;
    address internal _paymentProxy;

    function paymentProxy() external view returns (address) {

        return _paymentProxy;
    }

    function setPaymentProxy(address _newProxy) external onlyOwner {

        _paymentProxy = _newProxy;
    }

    mapping(address => mapping(uint256 => mapping(uint256 => bool)))
        internal _isTokenRedeemedForPurpose;

    function isTokenRedeemedForPurpose(
        address _address,
        uint256 _tokenId,
        uint256 _purpose
    ) external view returns (bool) {

        return (_isTokenRedeemedForPurpose[_address][_tokenId][_purpose] ||
            _oldRedeem.isTokenRedeemedForPurpose(_address, _tokenId, _purpose));
    }

    function getMessageHash(
        address[] memory _tokenContracts,
        uint256[] memory _tokenIds,
        uint256[] memory _purposes,
        uint256 _price,
        address _paymentTokenAddress,
        uint256 _timestamp
    ) public pure returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    _tokenContracts,
                    _tokenIds,
                    _purposes,
                    _price,
                    _paymentTokenAddress,
                    _timestamp
                )
            );
    }

    function verifySignature(
        address[] memory _tokenContracts,
        uint256[] memory _tokenIds,
        uint256[] memory _purposes,
        uint256 _price,
        address _paymentTokenAddress,
        bytes memory _signature,
        uint256 _timestamp
    ) internal view returns (bool) {

        bytes32 messageHash = getMessageHash(
            _tokenContracts,
            _tokenIds,
            _purposes,
            _price,
            _paymentTokenAddress,
            _timestamp
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, _signature) == owner();
    }

    function redeemManyTokens(
        address[] memory _tokenContracts,
        uint256[] memory _tokenIds,
        uint256[] memory _purposes,
        string memory _redeemerName,
        uint256 _price,
        address _paymentTokenAddress,
        bytes memory _signature,
        uint256 _timestamp
    ) external payable {

        require(
            _tokenContracts.length == _tokenIds.length &&
                _tokenIds.length == _purposes.length,
            "Array length mismatch"
        );
        require(
            _timestamp + _transactionOffset >= block.timestamp,
            "Transaction timed out"
        );
        require(
            verifySignature(
                _tokenContracts,
                _tokenIds,
                _purposes,
                _price,
                _paymentTokenAddress,
                _signature,
                _timestamp
            ),
            "Signature mismatch"
        );
        uint256 len = _tokenContracts.length;
        for (uint256 i = 0; i < len; i++) {
            require(
                !_isTokenRedeemedForPurpose[_tokenContracts[i]][_tokenIds[i]][
                    _purposes[i]
                ] &&
                    !_oldRedeem.isTokenRedeemedForPurpose(
                        _tokenContracts[i],
                        _tokenIds[i],
                        _purposes[i]
                    ),
                "Can't be redeemed again"
            );
            IERC721 token = IERC721(_tokenContracts[i]);
            require(
                token.ownerOf(_tokenIds[i]) == msg.sender,
                "Redeemee needs to own this token"
            );
            _isTokenRedeemedForPurpose[_tokenContracts[i]][_tokenIds[i]][
                _purposes[i]
            ] = true;
            uint256[] memory purpose = new uint256[](1);
            purpose[0] = _purposes[i];
            emit Redeemed(
                _tokenContracts[i],
                _tokenIds[0],
                msg.sender,
                _redeemerName,
                purpose
            );
        }
        if (_price != 0) {
            if (_paymentTokenAddress == address(0)) {
                require(msg.value >= _price, "Not enough ether");
                if (_price < msg.value) {
                    payable(msg.sender).transfer(msg.value - _price);
                }
            } else {
                require(
                    IERC20(_paymentTokenAddress).transferFrom(
                        msg.sender,
                        address(this),
                        _price
                    )
                );
            }
        }
    }

    function redeemTokenForPurposes(
        address _tokenContract,
        uint256 _tokenId,
        uint256[] memory _purposes,
        string memory _redeemerName,
        uint256 _price,
        address _paymentTokenAddress,
        bytes memory _signature,
        uint256 _timestamp
    ) external payable {

        uint256 len = _purposes.length;
        require(
            _timestamp + _transactionOffset >= block.timestamp,
            "Transaction timed out"
        );
        address[] memory _tokenContracts = new address[](len);
        uint256[] memory _tokenIds = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            _tokenContracts[i] = _tokenContract;
            _tokenIds[i] = _tokenId;
            require(
                !_isTokenRedeemedForPurpose[_tokenContract][_tokenId][
                    _purposes[i]
                ] &&
                    !_oldRedeem.isTokenRedeemedForPurpose(
                        _tokenContract,
                        _tokenId,
                        _purposes[i]
                    ),
                "Can't be claimed again"
            );
            IERC721 token = IERC721(_tokenContract);
            require(
                token.ownerOf(_tokenId) == msg.sender,
                "Claimer needs to own this token"
            );
            _isTokenRedeemedForPurpose[_tokenContract][_tokenId][
                _purposes[i]
            ] = true;
        }
        require(
            verifySignature(
                _tokenContracts,
                _tokenIds,
                _purposes,
                _price,
                _paymentTokenAddress,
                _signature,
                _timestamp
            ),
            "Signature mismatch"
        );
        if (_price != 0) {
            if (_paymentTokenAddress == address(0)) {
                require(msg.value >= _price, "Not enough ether");
                if (_price < msg.value) {
                    payable(msg.sender).transfer(msg.value - _price);
                }
            } else {
                require(
                    IERC20(_paymentTokenAddress).transferFrom(
                        msg.sender,
                        address(this),
                        _price
                    )
                );
            }
        }
        emit Redeemed(
            _tokenContract,
            _tokenId,
            msg.sender,
            _redeemerName,
            _purposes
        );
    }

    constructor(IUniqRedeem _oldRedeemAddress) {
        _transactionOffset = 2 hours;
        _oldRedeem = _oldRedeemAddress;
    }

    function setTransactionOffset(uint256 _newOffset) external onlyOwner {

        _transactionOffset = _newOffset;
    }

    function redeemTokensAsAdmin(
        address[] memory _tokenContracts,
        uint256[] memory _tokenIds,
        uint256[] memory _purposes,
        string[] memory _redeemerName
    ) external ownerOrProxy {

        require(
            _tokenContracts.length == _tokenIds.length &&
                _tokenIds.length == _purposes.length,
            "Array length mismatch"
        );
        uint256 len = _tokenContracts.length;
        for (uint256 i = 0; i < len; i++) {
            require(
                !_isTokenRedeemedForPurpose[_tokenContracts[i]][_tokenIds[i]][
                    _purposes[i]
                ] &&
                    !_oldRedeem.isTokenRedeemedForPurpose(
                        _tokenContracts[i],
                        _tokenIds[i],
                        _purposes[i]
                    ),
                "Can't be redeemed again"
            );
            _isTokenRedeemedForPurpose[_tokenContracts[i]][_tokenIds[i]][
                _purposes[i]
            ] = true;
            uint256[] memory purpose = new uint256[](1);
            purpose[0] = _purposes[i];
            emit Redeemed(
                _tokenContracts[i],
                _tokenIds[i],
                msg.sender,
                _redeemerName[i],
                purpose
            );
        }
    }

    function redeemTokenForPurposesAsAdmin(
        address _tokenContract,
        uint256 _tokenId,
        uint256[] memory _purposes,
        string memory _redeemerName
    ) external {

        uint256 len = _purposes.length;
        address[] memory _tokenContracts = new address[](len);
        uint256[] memory _tokenIds = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            _tokenContracts[i] = _tokenContract;
            _tokenIds[i] = _tokenId;
            require(
                !_isTokenRedeemedForPurpose[_tokenContract][_tokenId][
                    _purposes[i]
                ] &&
                    !_oldRedeem.isTokenRedeemedForPurpose(
                        _tokenContract,
                        _tokenId,
                        _purposes[i]
                    ),
                "Can't be claimed again"
            );
            IERC721 token = IERC721(_tokenContract);
            require(
                token.ownerOf(_tokenId) == msg.sender,
                "Claimer needs to own this token"
            );
            _isTokenRedeemedForPurpose[_tokenContract][_tokenId][
                _purposes[i]
            ] = true;
        }
        emit Redeemed(
            _tokenContract,
            _tokenId,
            msg.sender,
            _redeemerName,
            _purposes
        );
    }

    function setStatusesForTokens(
        address[] memory _tokenAddresses,
        uint256[] memory _tokenIds,
        uint256[] memory _purposes,
        bool[] memory isRedeemed
    ) external ownerOrProxy {

        uint256 len = _tokenAddresses.length;
        require(
            len == _tokenIds.length &&
                len == _purposes.length &&
                len == isRedeemed.length,
            "Arrays lengths mismatch"
        );
        for (uint256 i = 0; i < len; i++) {
            _isTokenRedeemedForPurpose[_tokenAddresses[i]][_tokenIds[i]][
                _purposes[i]
            ] = isRedeemed[i];
        }
    }

    function withdrawERC20(address _address) external onlyOwner {

        uint256 val = IERC20(_address).balanceOf(address(this));
        Ierc20(_address).transfer(msg.sender, val);
    }

    function withdrawETH() external onlyOwner {

        require(payable(msg.sender).send(address(this).balance));
    }


    receive() external payable {}
}