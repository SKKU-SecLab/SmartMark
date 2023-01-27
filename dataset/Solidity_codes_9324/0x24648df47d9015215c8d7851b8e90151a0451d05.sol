
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


contract UniqClaimingByAdmin is Ownable {



    uint256 internal _standardClaimingPrice;

    uint256 internal _standardOwnerChangingPrice;

    uint256 internal _standardPriceForVerification;

    address internal _ERC20tokenAddress;


    mapping(address => bool) internal _acceptedContracts;

    mapping(address => uint256) internal _pricesForClaiming;

    mapping(address => uint256) internal _pricesForOwnerChanging;

    mapping(address => bool) internal _isBurnable;


    mapping(address => mapping(uint256 => bool)) internal _isTokenClaimed;

    mapping(address => uint256[]) internal _claimedIds;

    mapping(address => mapping(uint256 => mapping(uint256 => address)))
        internal _ownersAddresses;

    mapping(address => mapping(uint256 => uint256)) internal _ownersCount;


    mapping(uint256 => bool) internal _isNonceRedeemed;

    mapping(address => string) internal _addressesOwners;

    mapping(address => bool) internal _isAddressesOwnerVerified;


    event Claim(
        address indexed _contractAddress,
        address indexed _claimer,
        uint256 indexed _tokenId,
        bytes _verificationStatus,
        string _claimersName
    );

    event ChangeOwner(
        address indexed _contractAddress,
        uint256 indexed _id,
        address _newOwner,
        address indexed _prevOwner,
        string _newOwnersName
    );

    event PayedForClaim(
        address indexed _claimer,
        address indexed _contractAddress,
        uint256 indexed _tokenId
    );

    event RequestedVerification(address indexed _requester, string _name);


    function isTokenClaimed(address _address, uint256 _tokenId)
        external
        view
        returns (bool)
    {

        return _isTokenClaimed[_address][_tokenId];
    }

    function isContractAuthorized(address _address)
        external
        view
        returns (bool)
    {

        return _acceptedContracts[_address];
    }

    function getLastOwnerOf(address _address, uint256 _id)
        external
        view
        returns (
            address,
            string memory,
            bool
        )
    {

        uint256 len = _ownersCount[_address][_id] - 1;
        address ownerAddress = _ownersAddresses[_address][_id][len];
        return (
            ownerAddress,
            _addressesOwners[ownerAddress],
            _isAddressesOwnerVerified[ownerAddress]
        );
    }

    function isNonceRedeemed(uint256 _nonce) external view returns (bool) {

        return _isNonceRedeemed[_nonce];
    }

    function getOwnersCountOfToken(address _address, uint256 _id)
        external
        view
        returns (uint256)
    {

        return (_ownersCount[_address][_id]);
    }

    function getAddressOwnerInfo(address _address)
        external
        view
        returns (string memory, bool)
    {

        bytes memory bts = bytes(_addressesOwners[_address]);
        require(bts.length != 0, "Address not used yet");
        return (
            _addressesOwners[_address],
            _isAddressesOwnerVerified[_address]
        );
    }

    function getOwnerOfTokenByPosition(
        address _address,
        uint256 _id,
        uint256 _position
    ) external view returns (address, string memory) {

        address ownerAddress = _ownersAddresses[_address][_id][_position];
        return (ownerAddress, _addressesOwners[ownerAddress]);
    }

    function getAllTokenHoldersNamesHistory(address _address, uint256 _id)
        external
        view
        returns (string[] memory)
    {

        uint256 len = _ownersCount[_address][_id];
        if (len == 0) {
            return new string[](0);
        }
        string[] memory res = new string[](len);
        uint256 index;
        for (index = 0; index < len; index++) {
            res[index] = _addressesOwners[
                _ownersAddresses[_address][_id][index]
            ];
        }
        return res;
    }

    function getAllTokenHoldersAddressesHistory(address _address, uint256 _id)
        external
        view
        returns (address[] memory)
    {

        uint256 len = _ownersCount[_address][_id];
        if (len == 0) {
            return new address[](0);
        }
        address[] memory res = new address[](len);
        uint256 index;
        for (index = 0; index < len; index++) {
            res[index] = _ownersAddresses[_address][_id][index];
        }
        return res;
    }

    function getClaimedIdsOfCollection(address _address)
        external
        view
        returns (uint256[] memory)
    {

        uint256 len = _claimedIds[_address].length;
        if (len == 0) {
            return new uint256[](0);
        }
        uint256[] memory res = new uint256[](len);
        uint256 index;
        for (index = 0; index < len; index++) {
            res[index] = _claimedIds[_address][index];
        }
        return res;
    }

    function getClaimedCountOf(address _address)
        external
        view
        returns (uint256)
    {

        return _claimedIds[_address].length;
    }

    function getStandardClaimingPrice() external view returns (uint256) {

        return _standardClaimingPrice;
    }

    function getClaimingPriceForContract(address _address)
        external
        view
        returns (uint256)
    {

        return
            _getCorrectPrice(
                _pricesForClaiming[_address],
                _standardClaimingPrice
            );
    }

    function getChangeOwnerPriceForContract(address _address)
        external
        view
        returns (uint256)
    {

        return
            _getCorrectPrice(
                _pricesForOwnerChanging[_address],
                _standardOwnerChangingPrice
            );
    }

    function getPriceForVerification() external view returns (uint256) {

        return _standardPriceForVerification;
    }

    function isBurnable(address _address) external view returns (bool) {

        return _isBurnable[_address];
    }

    function getPriceForMintAndVerify(address _contractAddress)
        external
        view
        returns (uint256)
    {

        uint256 claimingPrice = _getCorrectPrice(
            _pricesForClaiming[_contractAddress],
            _standardClaimingPrice
        );
        uint256 sumPrice = claimingPrice + _standardPriceForVerification;
        return sumPrice;
    }


    function getMessageHashForOwnerChange(
        address _address,
        string memory _claimersName,
        uint256 _nonce
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(_address, _claimersName, _nonce));
    }

    function payForClaim(address _contractAddress, uint256 _tokenId) external {

        require(
            _acceptedContracts[_contractAddress],
            "Contract address is not authorized"
        );
        uint256 claimingPrice = _getCorrectPrice(
            _pricesForClaiming[_contractAddress],
            _standardClaimingPrice
        );
        if (claimingPrice != 0) {
            IERC20 nativeToken = IERC20(_ERC20tokenAddress);
            require(
                nativeToken.transferFrom(
                    msg.sender,
                    address(this),
                    claimingPrice
                )
            );
        }
        emit PayedForClaim(msg.sender, _contractAddress, _tokenId);
    }

    function claimByAdmin(
        address _contractAddress,
        uint256 _tokenId,
        string memory _claimersName,
        bool _isVerified,
        address _claimer,
        string memory _verifyStatus
    ) external onlyOwner {

        require(
            _acceptedContracts[_contractAddress],
            "Contract address is not authorized"
        );
        require(
            !_isTokenClaimed[_contractAddress][_tokenId],
            "Can't be claimed again"
        );
        IERC721 token = IERC721(_contractAddress);
        require(
            token.ownerOf(_tokenId) == _claimer,
            "Claimer needs to own this token"
        );

        if (_isBurnable[_contractAddress]) {
            IERC721Burnable(_contractAddress).burn(_tokenId);
        } else {
            token.transferFrom(_claimer, address(this), _tokenId);
        }

        _isTokenClaimed[_contractAddress][_tokenId] = true;
        _claimedIds[_contractAddress].push(_tokenId);
        _ownersAddresses[_contractAddress][_tokenId][0] = _claimer;

        if (!_isAddressesOwnerVerified[_claimer]) {
            _addressesOwners[_claimer] = _claimersName;
            _isAddressesOwnerVerified[_claimer] = _isVerified;
        }


        _ownersCount[_contractAddress][_tokenId]++;
        emit Claim(_contractAddress, _claimer, _tokenId, bytes(_verifyStatus), _claimersName);
    }

    function changeOwner(
        address _contractAddress,
        uint256 _tokenId,
        string memory _newOwnersName,
        address _newOwnerAddress
    ) external {

        require(_isTokenClaimed[_contractAddress][_tokenId], "Not claimed yet");

        uint256 len = _ownersCount[_contractAddress][_tokenId];
        address ownerAddress = _ownersAddresses[_contractAddress][_tokenId][
            len - 1
        ];

        require(ownerAddress == msg.sender, "Not owner");

        uint256 changingPrice = _getCorrectPrice(
            _pricesForOwnerChanging[_contractAddress],
            _standardOwnerChangingPrice
        );
        if (changingPrice != 0) {
            IERC20 nativeToken = IERC20(_ERC20tokenAddress);
            require(
                nativeToken.transferFrom(
                    msg.sender,
                    address(this),
                    changingPrice
                )
            );
        }
        _ownersAddresses[_contractAddress][_tokenId][len] = _newOwnerAddress;

        if (!_isAddressesOwnerVerified[_newOwnerAddress]) {
            _addressesOwners[_newOwnerAddress] = _newOwnersName;
        }

        _ownersCount[_contractAddress][_tokenId]++;
        emit ChangeOwner(
            _contractAddress,
            _tokenId,
            _newOwnerAddress,
            msg.sender,
            _newOwnersName
        );
    }

    function verifyOwner(
        string memory _claimersName,
        uint256 _nonce,
        bytes memory _signature
    ) external {

        require(
            verifySignForAuthOwner(
                msg.sender,
                _claimersName,
                _nonce,
                _signature
            ),
            "Signature is not valid"
        );
        require(!_isNonceRedeemed[_nonce], "Nonce redeemed");
        _addressesOwners[msg.sender] = _claimersName;
        _isAddressesOwnerVerified[msg.sender] = true;
        _isNonceRedeemed[_nonce] = true;
    }

    function requestVerification(string memory _nameToVerify) external {

        IERC20 nativeToken = IERC20(_ERC20tokenAddress);
        require(
            nativeToken.transferFrom(
                msg.sender,
                address(this),
                _standardPriceForVerification
            )
        );
        require(
            !_isAddressesOwnerVerified[msg.sender],
            "Address is already verified"
        );
        _addressesOwners[msg.sender] = _nameToVerify;
        emit RequestedVerification(msg.sender, _nameToVerify);
    }

    function payForClaimAndVerification(
        string memory _nameToVerify,
        address _contractAddress,
        uint256 _tokenId
    ) external {

        require(
            !_isAddressesOwnerVerified[msg.sender],
            "Address is already verified"
        );
        require(
            _acceptedContracts[_contractAddress],
            "Contract address is not authorized"
        );
        IERC20 nativeToken = IERC20(_ERC20tokenAddress);

        uint256 claimingPrice = _getCorrectPrice(
            _pricesForClaiming[_contractAddress],
            _standardClaimingPrice
        );
        uint256 sumPrice = claimingPrice + _standardPriceForVerification;

        if (sumPrice > 0) {
            require(
                nativeToken.transferFrom(msg.sender, address(this), sumPrice)
            );
        }

        _addressesOwners[msg.sender] = _nameToVerify;

        emit PayedForClaim(msg.sender, _contractAddress, _tokenId);
        emit RequestedVerification(msg.sender, _nameToVerify);
    }

    constructor(
        uint256 _standardPriceForClaiming,
        uint256 _standardVerificationPrice,
        uint256 _standardPriceForOwnerChanging,
        address _nativeTokenAddress
    ) {
        _standardClaimingPrice = _standardPriceForClaiming;
        _standardPriceForVerification = _standardVerificationPrice;
        _standardOwnerChangingPrice = _standardPriceForOwnerChanging;
        _ERC20tokenAddress = _nativeTokenAddress;
    }

    function setVerificationPrice(uint256 _newPrice) external onlyOwner {

        _standardPriceForVerification = _newPrice;
    }

    function verifyByAdmin(
        address _userAddress,
        string memory _newName,
        bool _isVerifyed
    ) external onlyOwner {

        _addressesOwners[_userAddress] = _newName;
        _isAddressesOwnerVerified[_userAddress] = _isVerifyed;
    }

    function setErc20Token(address _contractAddress) external onlyOwner {

        _ERC20tokenAddress = _contractAddress;
    }

    function setContractAtributes(
        address _address,
        bool _enable,
        uint256 _claimingPrice,
        uint256 _changeOwnerPrice,
        bool _isBurnble
    ) external onlyOwner {

        _acceptedContracts[_address] = _enable;
        _pricesForClaiming[_address] = _claimingPrice;
        _pricesForOwnerChanging[_address] = _changeOwnerPrice;
        _isBurnable[_address] = _isBurnble;
    }

    function editStandardClaimingPrice(uint256 _price) external onlyOwner {

        _standardClaimingPrice = _price;
    }

    function editStandardChangeOwnerPrice(uint256 _price) external onlyOwner {

        _standardOwnerChangingPrice = _price;
    }

    function withdrawERC20(address _address) external onlyOwner {

        uint256 val = IERC20(_address).balanceOf(address(this));
        Ierc20(_address).transfer(msg.sender, val);
    }

    function changeOwnerByAdmin(
        address _address,
        uint256 _id,
        address _newOwnerAddress,
        string memory _newOwnersName,
        bool _verificationStatus
    ) external onlyOwner {

        require(_isTokenClaimed[_address][_id], "Not claimed yet");
        uint256 len = _ownersCount[_address][_id];
        _ownersAddresses[_address][_id][len] = _newOwnerAddress;
        _addressesOwners[_newOwnerAddress] = _newOwnersName;
        _isAddressesOwnerVerified[_newOwnerAddress] = _verificationStatus;
        emit ChangeOwner(
            _address,
            _id,
            _newOwnerAddress,
            address(0),
            _newOwnersName
        );
    }


    function _getCorrectPrice(uint256 _priceForContract, uint256 _standardPrice)
        internal
        pure
        returns (uint256)
    {

        if (_priceForContract == 1) {
            return _standardPrice;
        } else return _priceForContract;
    }

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

    function verifySignForAuthOwner(
        address _address,
        string memory _claimersName,
        uint256 _nonce,
        bytes memory _signature
    ) internal view returns (bool) {

        bytes32 messageHash = getMessageHashForOwnerChange(
            _address,
            _claimersName,
            _nonce
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, _signature) == owner();
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
}

interface Ierc20 {

    function transfer(address, uint256) external;

}

interface IERC721Burnable {

    function burn(uint256) external;

}