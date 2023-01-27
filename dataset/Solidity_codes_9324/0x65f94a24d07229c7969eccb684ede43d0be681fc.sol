
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
}// MIT

pragma solidity ^0.8.0;


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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
}//Unlicense
pragma solidity ^0.8.0;

interface ILaunchpadNFT {

    function getMaxLaunchpadSupply() external view returns (uint256);

    function getLaunchpadSupply() external view returns (uint256);

    function mintTo(address to, uint256 size) external;

}//Unlicense
pragma solidity ^0.8.0;


contract Launchpad is Ownable, ReentrancyGuard {

    event AddCampaign(address contractAddress, CampaignMode mode, address payeeAddress, uint256 price, uint256 maxSupply, uint256 listingTime, uint256 expirationTime, uint256 maxBatch, uint256 maxPerAddress, address validator);
    event UpdateCampaign(address contractAddress, CampaignMode mode, address payeeAddress, uint256 price, uint256 maxSupply, uint256 listingTime, uint256 expirationTime, uint256 maxBatch, uint256 maxPerAddress, address validator);
    event Mint(address indexed contractAddress, CampaignMode mode, address userAddress, address payeeAddress, uint256 size, uint256 price);

    enum CampaignMode {
        normal,
        whitelisted
    }
    struct Campaign {
        address contractAddress;
        address payeeAddress;
        uint256 price; // wei
        uint256 maxSupply;
        uint256 listingTime;
        uint256 expirationTime;
        uint256 maxBatch;
        uint256 maxPerAddress;
        address validator; // only for whitelisted
        uint256 minted;
    }

    mapping(address => Campaign) private _campaignsNormal;
    mapping(address => Campaign) private _campaignsWhitelisted;

    mapping(address => mapping(address => uint256)) private _mintPerAddressNormal;
    mapping(address => mapping(address => uint256)) private _mintPerAddressWhitelisted;

    function mintWhitelisted(
        address contractAddress,
        uint256 batchSize,
        bytes memory signature
    ) external payable nonReentrant {

        require(contractAddress != address(0), "contract address can't be empty");
        require(batchSize > 0, "batchSize must greater than 0");
        Campaign memory campaign = _campaignsWhitelisted[contractAddress];
        require(campaign.contractAddress != address(0), "contract not register");

        bytes32 messageHash = keccak256(abi.encodePacked(block.chainid, address(this), contractAddress, msg.sender));
        bytes32 proof = ECDSA.toEthSignedMessageHash(messageHash);
        require(ECDSA.recover(proof, signature) == campaign.validator, "whitelist verification failed");

        require(batchSize <= campaign.maxBatch, "reach max batch size");
        require(block.timestamp >= campaign.listingTime, "activity not start");
        require(block.timestamp < campaign.expirationTime, "activity ended");
        require(_mintPerAddressWhitelisted[contractAddress][msg.sender] + batchSize <= campaign.maxPerAddress, "reach max per address limit");
        require(campaign.minted + batchSize <= campaign.maxSupply, "reach campaign max supply");
        uint256 totalPrice = campaign.price * batchSize;
        require(msg.value >= totalPrice, "value not enough");

        _mintPerAddressWhitelisted[contractAddress][msg.sender] = _mintPerAddressWhitelisted[contractAddress][msg.sender] + batchSize;

        payable(campaign.payeeAddress).transfer(totalPrice);
        ILaunchpadNFT(contractAddress).mintTo(msg.sender, batchSize);
        _campaignsWhitelisted[contractAddress].minted += batchSize;

        emit Mint(campaign.contractAddress, CampaignMode.whitelisted, msg.sender, campaign.payeeAddress, batchSize, campaign.price);
        uint256 valueLeft = msg.value - totalPrice;
        if (valueLeft > 0) {
            payable(_msgSender()).transfer(valueLeft);
        }
    }

    function mint(address contractAddress, uint256 batchSize) external payable nonReentrant {

        require(contractAddress != address(0), "contract address can't be empty");
        require(batchSize > 0, "batchSize must greater than 0");
        Campaign memory campaign = _campaignsNormal[contractAddress];
        require(campaign.contractAddress != address(0), "contract not register");

        require(batchSize <= campaign.maxBatch, "reach max batch size");
        require(block.timestamp >= campaign.listingTime, "activity not start");
        require(block.timestamp < campaign.expirationTime, "activity ended");
        require(_mintPerAddressNormal[contractAddress][msg.sender] + batchSize <= campaign.maxPerAddress, "reach max per address limit");
        require(campaign.minted + batchSize <= campaign.maxSupply, "reach campaign max supply");
        uint256 totalPrice = campaign.price * batchSize;
        require(msg.value >= totalPrice, "value not enough");

        _mintPerAddressNormal[contractAddress][msg.sender] = _mintPerAddressNormal[contractAddress][msg.sender] + batchSize;

        payable(campaign.payeeAddress).transfer(totalPrice);
        ILaunchpadNFT(contractAddress).mintTo(msg.sender, batchSize);
        _campaignsNormal[contractAddress].minted += batchSize;

        emit Mint(campaign.contractAddress, CampaignMode.normal, msg.sender, campaign.payeeAddress, batchSize, campaign.price);
        uint256 valueLeft = msg.value - totalPrice;
        if (valueLeft > 0) {
            payable(_msgSender()).transfer(valueLeft);
        }
    }

    function getMintPerAddress(
        address contractAddress,
        CampaignMode mode,
        address userAddress
    ) external view returns (uint256 mintPerAddress) {

        Campaign memory campaign;
        if (mode == CampaignMode.normal) {
            campaign = _campaignsNormal[contractAddress];
            mintPerAddress = _mintPerAddressNormal[contractAddress][msg.sender];
        } else {
            campaign = _campaignsWhitelisted[contractAddress];
            mintPerAddress = _mintPerAddressWhitelisted[contractAddress][msg.sender];
        }

        require(campaign.contractAddress != address(0), "contract address invalid");
        require(userAddress != address(0), "user address invalid");
    }

    function getLaunchpadMaxSupply(address contractAddress, CampaignMode mode) external view returns (uint256) {

        if (mode == CampaignMode.normal) {
            return _campaignsNormal[contractAddress].maxSupply;
        } else {
            return _campaignsWhitelisted[contractAddress].maxSupply;
        }
    }

    function getLaunchpadSupply(address contractAddress, CampaignMode mode) external view returns (uint256) {

        if (mode == CampaignMode.normal) {
            return _campaignsNormal[contractAddress].minted;
        } else {
            return _campaignsWhitelisted[contractAddress].minted;
        }
    }

    function addCampaign(
        address contractAddress_,
        CampaignMode mode,
        address payeeAddress_,
        uint256 price_,
        uint256 listingTime_,
        uint256 expirationTime_,
        uint256 maxSupply_,
        uint256 maxBatch_,
        uint256 maxPerAddress_,
        address validator_
    ) external onlyOwner {

        require(contractAddress_ != address(0), "contract address can't be empty");
        require(expirationTime_ > listingTime_, "expiration time must above listing time");

        Campaign memory campaign;
        uint256 maxSupplyRest;
        if (mode == CampaignMode.normal) {
            campaign = _campaignsNormal[contractAddress_];
            maxSupplyRest = ILaunchpadNFT(contractAddress_).getMaxLaunchpadSupply() - _campaignsWhitelisted[contractAddress_].maxSupply;
        } else {
            campaign = _campaignsWhitelisted[contractAddress_];
            maxSupplyRest = ILaunchpadNFT(contractAddress_).getMaxLaunchpadSupply() - _campaignsNormal[contractAddress_].maxSupply;
            require(validator_ != address(0), "validator can't be empty");
        }

        require(campaign.contractAddress == address(0), "contract address already exist");

        require(payeeAddress_ != address(0), "payee address can't be empty");
        require(maxBatch_ > 0, "max batch invalid");
        require(maxPerAddress_ > 0, "max per address can't be 0");
        require(maxSupply_ <= maxSupplyRest, "max supply is exceeded");
        require(maxSupply_ > 0, "max supply can't be 0");

        emit AddCampaign(contractAddress_, mode, payeeAddress_, price_, maxSupply_, listingTime_, expirationTime_, maxBatch_, maxPerAddress_, validator_);
        campaign = Campaign(contractAddress_, payeeAddress_, price_, maxSupply_, listingTime_, expirationTime_, maxBatch_, maxPerAddress_, validator_, 0);
        if (mode == CampaignMode.normal) {
            _campaignsNormal[contractAddress_] = campaign;
        } else {
            _campaignsWhitelisted[contractAddress_] = campaign;
        }
    }

    function updateCampaign(
        address contractAddress_,
        CampaignMode mode,
        address payeeAddress_,
        uint256 price_,
        uint256 listingTime_,
        uint256 expirationTime_,
        uint256 maxSupply_,
        uint256 maxBatch_,
        uint256 maxPerAddress_,
        address validator_
    ) external onlyOwner {

        Campaign memory campaign;
        uint256 maxSupplyRest;
        require(contractAddress_ != address(0), "contract address can't be empty");
        require(expirationTime_ > listingTime_, "expiration time must above listing time");

        if (mode == CampaignMode.normal) {
            maxSupplyRest = ILaunchpadNFT(contractAddress_).getMaxLaunchpadSupply() - _campaignsWhitelisted[contractAddress_].maxSupply;
            campaign = _campaignsNormal[contractAddress_];
        } else {
            campaign = _campaignsWhitelisted[contractAddress_];
            maxSupplyRest = ILaunchpadNFT(contractAddress_).getMaxLaunchpadSupply() - _campaignsNormal[contractAddress_].maxSupply;
            require(validator_ != address(0), "validator can't be empty");
        }

        require(campaign.contractAddress != address(0), "contract address not exist");

        require(payeeAddress_ != address(0), "payee address can't be empty");
        require(maxBatch_ > 0, "max batch invalid");
        require(maxPerAddress_ > 0, "max per address can't be 0");
        require(maxSupply_ <= maxSupplyRest, "max supply is exceeded");
        require(maxSupply_ > 0, "max supply can't be 0");
        emit UpdateCampaign(contractAddress_, mode, payeeAddress_, price_, maxSupply_, listingTime_, expirationTime_, maxBatch_, maxPerAddress_, validator_);
        campaign = Campaign(contractAddress_, payeeAddress_, price_, maxSupply_, listingTime_, expirationTime_, maxBatch_, maxPerAddress_, validator_, campaign.minted);

        if (mode == CampaignMode.normal) {
            _campaignsNormal[contractAddress_] = campaign;
        } else {
            _campaignsWhitelisted[contractAddress_] = campaign;
        }
    }

    function getCampaign(address contractAddress, CampaignMode mode) external view returns (Campaign memory) {

        if (mode == CampaignMode.normal) {
            return _campaignsNormal[contractAddress];
        } else {
            return _campaignsWhitelisted[contractAddress];
        }
    }
}