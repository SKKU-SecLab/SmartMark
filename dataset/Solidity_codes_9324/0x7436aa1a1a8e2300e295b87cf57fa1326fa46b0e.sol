
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

pragma solidity ^0.8.6;


interface IHero is IERC721 {

    function multiMint() external;

    function setPartner(address _partner, uint256 _limit) external;

    function transferOwnership(address newOwner) external; 

    function partnersLimit(address _partner) external view returns(uint256, uint256);

    function totalSupply() external view returns(uint256);

    function reservedForPartners() external view returns(uint256);

}// MIT

pragma solidity ^0.8.6;

interface IRandom {

    function requestChainLinkEntropy() external returns (bytes32 requestId);

}// MIT

pragma solidity ^0.8.6;

interface IRarity {

    function loadRaritiesBatch(address _contract, uint256[] memory _tokens, uint8[] memory _rarities) external; 

    function getRarity(address _contract, uint256 _tokenId) external view returns(uint8 r);

    function getRarity2(address _contract, uint256 _tokenId) external view returns(uint8 r);

}// MIT
pragma solidity ^0.8.6;



contract HeroesUpgraderV2  is ERC1155Receiver, Ownable {


    enum Rarity {Simple, SimpleUpgraded, Rare, Legendary, F1, F2, F3}
    struct Modification {
        address sourceContract;
        Rarity  sourceRarity;
        address destinitionContract;
        Rarity  destinitionRarity;
        uint256 balanceForUpgrade;
        bool enabled;
    }

    bool internal chainLink;
    address public chainLinkAdapter;
    address internal whiteListBalancer = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public externalStorage;

    mapping(address => mapping(uint256 => Modification)) public enabledModifications;

    mapping(address => bool) public sourceContracts;
    
    mapping(address => mapping(uint256 => Rarity)) public rarity;
    
    event Upgraded(address destinitionContract, uint256 oldHero, uint256 newHero, Rarity newRarity);
    event ModificationChange(address modifierContract, uint256 modifierId);
    

    
    function upgrade(uint256 oldHero, address modifierContract, uint256 modifierId) public virtual{

        require(
            enabledModifications[modifierContract][modifierId].enabled
            , "Unknown modificator"
        );
        require(
            rarity[
              enabledModifications[modifierContract][modifierId].sourceContract
            ][oldHero] == enabledModifications[modifierContract][modifierId].sourceRarity,
            "Cant modify twice or from your rarity"
        );

        require(
            IHero(
               enabledModifications[modifierContract][modifierId].sourceContract
            ).ownerOf(oldHero) == msg.sender,
            "You need own hero for upgrade"
        );
        IERC1155(modifierContract).safeTransferFrom(
            msg.sender,
            address(this),
            modifierId,
            enabledModifications[modifierContract][modifierId].balanceForUpgrade,
            '0'
        );

        (uint256 limit, uint256 minted) =
            IHero(
               enabledModifications[modifierContract][modifierId].destinitionContract
            ).partnersLimit(address(this));
        
        IHero(
            enabledModifications[modifierContract][modifierId].destinitionContract
        ).setPartner(address(this), limit + 1);
        
        
         
        uint256 newToken = IHero(
            enabledModifications[modifierContract][modifierId].destinitionContract
        ).totalSupply();
        
        IHero(
            enabledModifications[modifierContract][modifierId].destinitionContract
        ).multiMint();
        
        IHero(
            enabledModifications[modifierContract][modifierId].destinitionContract
        ).transferFrom(address(this), msg.sender, newToken);

        

        IHero(
            enabledModifications[modifierContract][modifierId].destinitionContract
        ).setPartner(whiteListBalancer, limit);
        IHero(
            enabledModifications[modifierContract][modifierId].destinitionContract
        ).setPartner(whiteListBalancer, limit);
        IHero(
            enabledModifications[modifierContract][modifierId].destinitionContract
        ).setPartner(whiteListBalancer, limit);
        IHero(
            enabledModifications[modifierContract][modifierId].destinitionContract
        ).setPartner(whiteListBalancer, 0);

        
        rarity[
            enabledModifications[modifierContract][modifierId].sourceContract
        ][oldHero] = Rarity.SimpleUpgraded;

        rarity[
            enabledModifications[modifierContract][modifierId].sourceContract
        ][newToken] = enabledModifications[modifierContract][modifierId].destinitionRarity;
        emit Upgraded(
            enabledModifications[modifierContract][modifierId].destinitionContract, 
            oldHero,
            newToken, 
            enabledModifications[modifierContract][modifierId].destinitionRarity
        );
        
        if (chainLink) {
            IRandom(chainLinkAdapter).requestChainLinkEntropy();    
        }
        

    }

    function upgradeBatch(uint256[] memory oldHeroes, address modifierContract, uint256 modifierId) public virtual {

        require(oldHeroes.length <= 10, "Not more then 10");
        for (uint256 i; i < oldHeroes.length; i ++) {
            upgrade(oldHeroes[i], modifierContract, modifierId);
        }
    }


    function getRarity(address _contract, uint256 _tokenId) public view returns(Rarity r) {

        r = rarity[_contract][_tokenId];
        if (externalStorage != address(0)) {
            uint8 extRar = IRarity(externalStorage).getRarity(_contract, _tokenId);
            if (Rarity(extRar) > r) {
                r = Rarity(extRar);
            }
        }
        return r;
    }


    function getRarity2(address _contract, uint256 _tokenId) public view returns(Rarity r) {

        require(sourceContracts[_contract], "Unknown source contract");
        require(
            IHero(_contract).ownerOf(_tokenId) != address(0),
            "Seems like token not exist"
        );
        return getRarity(_contract, _tokenId);
    }


    
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        override
        returns(bytes4)
    {

        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));  
    }    

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        override
        returns(bytes4)
    {

        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256,uint256,bytes)"));  
    }
    
    function setModification(
        address _modifierContract,
        uint256 _modifierId,
        address _sourceContract,
        Rarity  _sourceRarity,
        address _destinitionContract,
        Rarity  _destinitionRarity,
        uint256 _balanceForUpgrade,
        bool    _isEnabled
    ) external onlyOwner {

        require(_modifierContract != address(0), "No zero");
        enabledModifications[_modifierContract][_modifierId].sourceContract = _sourceContract;
        enabledModifications[_modifierContract][_modifierId].sourceRarity = _sourceRarity;
        enabledModifications[_modifierContract][_modifierId].destinitionContract = _destinitionContract;
        enabledModifications[_modifierContract][_modifierId].destinitionRarity = _destinitionRarity;
        enabledModifications[_modifierContract][_modifierId].balanceForUpgrade = _balanceForUpgrade;
        enabledModifications[_modifierContract][_modifierId].enabled = _isEnabled;
        sourceContracts[_sourceContract] = _isEnabled;
        emit ModificationChange(_modifierContract, _modifierId);
    }

    function setModificationState(
        address _modifierContract,
        uint256 _modifierId,
        bool    _isEnabled
    ) external onlyOwner {

        require(_modifierContract != address(0), "No zero");
        enabledModifications[_modifierContract][_modifierId].enabled = _isEnabled;
        sourceContracts[
            enabledModifications[_modifierContract][_modifierId].sourceContract
        ] = _isEnabled;
        emit ModificationChange(_modifierContract, _modifierId);
    }

    function revokeOwnership(address _contract) external onlyOwner {

        IHero(_contract).transferOwnership(owner());
    }

    function setChainLink(bool _isOn) external onlyOwner {

        require(chainLinkAdapter != address(0), "Set adapter address first");
        chainLink = _isOn;
    }

    function setChainLinkAdapter(address _adapter) external onlyOwner {

        chainLinkAdapter = _adapter;
    } 

    function setPartnerProxy(
        address _contract, 
        address _partner, 
        uint256 _newLimit
    ) 
        external 
        onlyOwner 
    {

        IHero(_contract).setPartner(_partner, _newLimit);
    } 

    function setWLBalancer(address _balancer) external onlyOwner {

        require(_balancer != address(0));
        whiteListBalancer = _balancer;
    }

    function loadRaritiesBatch(address _contract, uint256[] memory _tokens, Rarity[] memory _rarities) external onlyOwner {

        require(_contract != address(0), "No Zero Address");
        require(_tokens.length == _rarities.length);
         for (uint256 i; i < _tokens.length; i ++) {
            rarity[_contract][_tokens[i]] = _rarities[i];
        }
    }

    function setExternalStorage(address _storage) external onlyOwner {

        externalStorage = _storage;
    }
}// MIT
pragma solidity ^0.8.6;



contract HeroesUpgraderV3  is HeroesUpgraderV2 {


    bool public writeToExternal;

    
    function upgrade(uint256 oldHero, address modifierContract, uint256 modifierId) public override{

        super.upgrade(oldHero, modifierContract, modifierId);
        if (writeToExternal) {
            uint256 justMintedToken = IHero(
                enabledModifications[modifierContract][modifierId].destinitionContract
            ).totalSupply() - 1;
            uint256[] memory tokens = new uint256[](2);
            uint8[] memory rarities = new uint8[](2);
            tokens[0] = oldHero;
            tokens[1] = justMintedToken;
            rarities[0] = uint8(Rarity.SimpleUpgraded);
            rarities[1] = uint8(enabledModifications[modifierContract][modifierId].destinitionRarity); 

            IRarity(externalStorage).loadRaritiesBatch(
                enabledModifications[modifierContract][modifierId].sourceContract, // Heroes
                tokens,
                rarities
            );
        }

    }

    function upgradeBatch(uint256[] memory oldHeroes, address modifierContract, uint256 modifierId) public override {

        require(oldHeroes.length <= 10, "Not more then 10");
        for (uint256 i; i < oldHeroes.length; i ++) {
            upgrade(oldHeroes[i], modifierContract, modifierId);
        }
    }

    

    function setWriteToExternal(bool _write) external onlyOwner {

        writeToExternal = _write;
    }
}