
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


contract LaunchpadV2 is Ownable, ReentrancyGuard {

    event AddCampaign(address contractAddress, CampaignMode mode, address payeeAddress, address platformFeeAddress, uint256 platformFeeRate, uint256 price, uint256 maxSupply, uint256 listingTime, uint256 expirationTime, uint256 maxBatch, uint256 maxPerAddress, address validator);
    event UpdateCampaign(address contractAddress, CampaignMode mode, address payeeAddress, address platformFeeAddress, uint256 platformFeeRate, uint256 price, uint256 maxSupply, uint256 listingTime, uint256 expirationTime, uint256 maxBatch, uint256 maxPerAddress, address validator);
    event Mint(address indexed contractAddress, CampaignMode mode, address userAddress, address payeeAddress, address platformFeeAddress, uint256 size, uint256 fee, uint256 platformFee);

    enum CampaignMode {
        normal,
        whitelisted
    }
    struct Campaign {
        address contractAddress;
        address payeeAddress;
        address platformFeeAddress;
        uint256 platformFeeRate; // 0 %0 - 10000 100%
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

    uint256 public constant INVERSE_BASIS_POINT = 10000;

    function mintWhitelisted(
        address contractAddress,
        uint256 batchSize,
        bytes memory signature
    ) external payable nonReentrant {


        Campaign memory campaign = getCampaign(contractAddress, CampaignMode.whitelisted);
        require(campaign.contractAddress != address(0), "contract not register");

        bytes32 messageHash = keccak256(abi.encodePacked(block.chainid, address(this), contractAddress, msg.sender));
        bytes32 proof = ECDSA.toEthSignedMessageHash(messageHash);
        require(ECDSA.recover(proof, signature) == campaign.validator, "whitelist verification failed");

        mint_(contractAddress, batchSize, CampaignMode.whitelisted);

    }

    function mint(address contractAddress, uint256 batchSize) external payable nonReentrant {

        mint_(contractAddress, batchSize, CampaignMode.normal);
    }

    function mint_(address contractAddress, uint256 batchSize, CampaignMode mode) internal {

        require(contractAddress != address(0), "contract address can't be empty");
        require(batchSize > 0, "batchSize must greater than 0");

        Campaign memory campaign = getCampaign(contractAddress, mode);

        require(campaign.contractAddress != address(0), "contract not register");

        require(batchSize <= campaign.maxBatch, "reach max batch size");
        require(block.timestamp >= campaign.listingTime, "activity not start");
        require(block.timestamp < campaign.expirationTime, "activity ended");
        require(campaign.minted + batchSize <= campaign.maxSupply, "reach campaign max supply");
        require(ILaunchpadNFT(campaign.contractAddress).getLaunchpadSupply() + batchSize <= ILaunchpadNFT(campaign.contractAddress).getMaxLaunchpadSupply(), "reach campaign total max supply");

        if (mode == CampaignMode.normal) {
            require(_mintPerAddressNormal[campaign.contractAddress][msg.sender] + batchSize <= campaign.maxPerAddress, "reach max per address limit");
            _mintPerAddressNormal[contractAddress][msg.sender] = _mintPerAddressNormal[contractAddress][msg.sender] + batchSize;
            _campaignsNormal[contractAddress].minted += batchSize;

        } else {
            require(_mintPerAddressWhitelisted[campaign.contractAddress][msg.sender] + batchSize <= campaign.maxPerAddress, "reach max per address limit");
            _mintPerAddressWhitelisted[contractAddress][msg.sender] = _mintPerAddressWhitelisted[contractAddress][msg.sender] + batchSize;
            _campaignsWhitelisted[contractAddress].minted += batchSize;
        }

        uint256 totalPrice = campaign.price * batchSize;
        require(msg.value >= totalPrice, "value not enough");

        uint256 platformFee = totalPrice * campaign.platformFeeRate / INVERSE_BASIS_POINT;
        uint256 fee = totalPrice - platformFee;
        payable(campaign.payeeAddress).transfer(fee);
        if (platformFee > 0) {
            payable(campaign.platformFeeAddress).transfer(platformFee);
        }

        ILaunchpadNFT(contractAddress).mintTo(msg.sender, batchSize);

        emit Mint(campaign.contractAddress, mode, msg.sender, campaign.payeeAddress, campaign.platformFeeAddress, batchSize, fee, platformFee);
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

        require(userAddress != address(0), "user address invalid");
        if (mode == CampaignMode.normal) {
            mintPerAddress = _mintPerAddressNormal[contractAddress][userAddress];
        } else {
            mintPerAddress = _mintPerAddressWhitelisted[contractAddress][userAddress];
        }
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

    function getLaunchpadSupplyTotal(address contractAddress) external view returns (uint256) {

        return ILaunchpadNFT(contractAddress).getLaunchpadSupply();
    }

    function addCampaign(
        address[] memory addresses,
        CampaignMode mode,
        uint256[] memory values
    ) external onlyOwner {

        require(addresses.length == 4, "addresses size wrong");
        require(values.length == 7, "values size wrong");
        Campaign memory campaign = Campaign(
            addresses[0], // contractAddress_,
            addresses[1], // payeeAddress_,
            addresses[2], // platformFeeAddress_,
            values[0], // platformFeeRate_,
            values[1], // price_,
            values[2], // maxSupply_,
            values[3], // listingTime_,
            values[4], // expirationTime_,
            values[5], // maxBatch_,
            values[6], // maxPerAddress_,
            addresses[3], // validator_,
            0
        );
        addCampaign_(campaign, mode);
    }

    function addCampaign_(
        Campaign memory campaign,
        CampaignMode mode
    ) internal {


        campaignCheck(campaign, mode);

        if (mode == CampaignMode.normal) {
            require(_campaignsNormal[campaign.contractAddress].contractAddress == address(0), "contract address already exist");
        } else {
            require(_campaignsWhitelisted[campaign.contractAddress].contractAddress == address(0), "contract address already exist");
        }

        emit AddCampaign(
            campaign.contractAddress,
            mode,
            campaign.payeeAddress,
            campaign.platformFeeAddress,
            campaign.platformFeeRate,
            campaign.price,
            campaign.maxSupply,
            campaign.listingTime,
            campaign.expirationTime,
            campaign.maxBatch,
            campaign.maxPerAddress,
            campaign.validator
        );

        if (mode == CampaignMode.normal) {
            _campaignsNormal[campaign.contractAddress] = campaign;
        } else {
            _campaignsWhitelisted[campaign.contractAddress] = campaign;
        }
    }

    function updateCampaign(
        address[] memory addresses,
        CampaignMode mode,
        uint256[] memory values
    ) external onlyOwner {

        require(addresses.length == 4, "addresses size wrong");
        require(values.length == 7, "values size wrong");

        address contractAddress = addresses[0];
        uint256 minted;
        if (mode == CampaignMode.normal) {
            require(_campaignsNormal[contractAddress].contractAddress != address(0), "normal contract address not exist");
            minted = _campaignsNormal[contractAddress].minted;
        } else {
            require(_campaignsWhitelisted[contractAddress].contractAddress != address(0), "white-list contract address not exist");
            minted = _campaignsWhitelisted[contractAddress].minted;
        }

        Campaign memory campaign = Campaign(
            addresses[0], // contractAddress_,
            addresses[1], //payeeAddress_,
            addresses[2], //platformFeeAddress_,
            values[0], //platformFeeRate_,
            values[1], //price_,
            values[2], //maxSupply_,
            values[3], //listingTime_,
            values[4], //expirationTime_,
            values[5], // maxBatch_,
            values[6], //maxPerAddress_,
            addresses[3], //validator_,
            minted
        );
        updateCampaign_(campaign, mode);
    }

    function updateCampaign_(Campaign memory campaign, CampaignMode mode) internal {


        campaignCheck(campaign, mode);

        emit UpdateCampaign(campaign.contractAddress, mode, campaign.payeeAddress, campaign.platformFeeAddress, campaign.platformFeeRate, campaign.price, campaign.maxSupply, campaign.listingTime, campaign.expirationTime, campaign.maxBatch, campaign.maxPerAddress, campaign.validator);

        if (mode == CampaignMode.normal) {
            _campaignsNormal[campaign.contractAddress] = campaign;
        } else {
            _campaignsWhitelisted[campaign.contractAddress] = campaign;
        }
    }

    function campaignCheck(Campaign memory campaign, CampaignMode mode) private view {

        require(campaign.contractAddress != address(0), "contract address can't be empty");
        require(campaign.expirationTime > campaign.listingTime, "expiration time must above listing time");
        require(campaign.maxSupply > 0 && campaign.maxSupply <= ILaunchpadNFT(campaign.contractAddress).getMaxLaunchpadSupply(), "campaign max supply invalid");

        if (mode == CampaignMode.whitelisted) {
            require(campaign.validator != address(0), "validator can't be empty");
        }

        require(campaign.payeeAddress != address(0), "payee address can't be empty");
        require(campaign.platformFeeAddress != address(0), "platform fee address can't be empty");
        require(campaign.platformFeeRate >= 0 && campaign.platformFeeRate <= INVERSE_BASIS_POINT, "platform fee rate invalid");
        require(campaign.maxBatch > 0 && campaign.maxBatch <= 10, "max batch invalid");
        require(campaign.maxPerAddress > 0 && campaign.maxPerAddress <= campaign.maxSupply, "max per address invalid");
    }

    function getCampaign(address contractAddress, CampaignMode mode) public view returns (Campaign memory) {

        if (mode == CampaignMode.normal) {
            return _campaignsNormal[contractAddress];
        } else {
            return _campaignsWhitelisted[contractAddress];
        }
    }
}