
pragma solidity 0.5.17;

contract AvastarTypes {


    enum Generation {
        ONE,
        TWO,
        THREE,
        FOUR,
        FIVE
    }

    enum Series {
        PROMO,
        ONE,
        TWO,
        THREE,
        FOUR,
        FIVE
    }

    enum Wave {
        PRIME,
        REPLICANT
    }

    enum Gene {
        SKIN_TONE,
        HAIR_COLOR,
        EYE_COLOR,
        BG_COLOR,
        BACKDROP,
        EARS,
        FACE,
        NOSE,
        MOUTH,
        FACIAL_FEATURE,
        EYES,
        HAIR_STYLE
    }

    enum Gender {
        ANY,
        MALE,
        FEMALE
    }

    enum Rarity {
        COMMON,
        UNCOMMON,
        RARE,
        EPIC,
        LEGENDARY
    }

    struct Trait {
        uint256 id;
        Generation generation;
        Gender gender;
        Gene gene;
        Rarity rarity;
        uint8 variation;
        Series[] series;
        string name;
        string svg;

    }

    struct Prime {
        uint256 id;
        uint256 serial;
        uint256 traits;
        bool[12] replicated;
        Generation generation;
        Series series;
        Gender gender;
        uint8 ranking;
    }

    struct Replicant {
        uint256 id;
        uint256 serial;
        uint256 traits;
        Generation generation;
        Gender gender;
        uint8 ranking;
    }

    struct Avastar {
        uint256 id;
        uint256 serial;
        uint256 traits;
        Generation generation;
        Wave wave;
    }

    struct Attribution {
        Generation generation;
        string artist;
        string infoURI;
    }

}


pragma solidity 0.5.17;


contract IAvastarTeleporter is AvastarTypes {


    function isAvastarTeleporter() external pure returns (bool);


    function tokenURI(uint _tokenId)
    external view
    returns (string memory uri);


    function getAvastarWaveByTokenId(uint256 _tokenId)
    external view
    returns (Wave wave);


    function getPrimeByTokenId(uint256 _tokenId)
    external view
    returns (
        uint256 tokenId,
        uint256 serial,
        uint256 traits,
        Generation generation,
        Series series,
        Gender gender,
        uint8 ranking
    );


    function getReplicantByTokenId(uint256 _tokenId)
    external view
    returns (
        uint256 tokenId,
        uint256 serial,
        uint256 traits,
        Generation generation,
        Gender gender,
        uint8 ranking
    );


    function getTraitInfoById(uint256 _traitId)
    external view
    returns (
        uint256 id,
        Generation generation,
        Series[] memory series,
        Gender gender,
        Gene gene,
        Rarity rarity,
        uint8 variation,
        string memory name
    );



    function getTraitNameById(uint256 _traitId)
    external view
    returns (string memory name);


    function getTraitIdByGenerationGeneAndVariation(
        Generation _generation,
        Gene _gene,
        uint8 _variation
    )
    external view
    returns (uint256 traitId);


    function getAttributionByGeneration(Generation _generation)
    external view
    returns (
        string memory attribution
    );


    function mintPrime(
        address _owner,
        uint256 _traits,
        Generation _generation,
        Series _series,
        Gender _gender,
        uint8 _ranking
    )
    external
    returns (uint256, uint256);


    function mintReplicant(
        address _owner,
        uint256 _traits,
        Generation _generation,
        Gender _gender,
        uint8 _ranking
    )
    external
    returns (uint256, uint256);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function totalSupply() public view returns (uint256 count);

}


pragma solidity 0.5.17;

contract AvastarBase {


    function uintToStr(uint _i)
    internal pure
    returns (string memory result) {

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
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        result = string(bstr);
    }

    function strConcat(string memory _a, string memory _b)
    internal pure
    returns(string memory result) {

        result = string(abi.encodePacked(bytes(_a), bytes(_b)));
    }

}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity 0.5.17;



contract AccessControl {


    using SafeMath for uint256;
    using SafeMath for uint16;
    using Roles for Roles.Role;

    Roles.Role private admins;
    Roles.Role private minters;
    Roles.Role private owners;

    constructor() public {
        admins.add(msg.sender);
    }

    event ContractPaused();

    event ContractUnpaused();

    event ContractUpgrade(address newContract);


    bool public paused = true;
    bool public upgraded = false;
    address public newContractAddress;

    modifier onlyMinter() {

        require(minters.has(msg.sender));
        _;
    }

    modifier onlyOwner() {

        require(owners.has(msg.sender));
        _;
    }

    modifier onlySysAdmin() {

        require(admins.has(msg.sender));
        _;
    }

    modifier whenNotPaused() {

        require(!paused);
        _;
    }

    modifier whenPaused() {

        require(paused);
        _;
    }

    modifier whenNotUpgraded() {

        require(!upgraded);
        _;
    }

    function upgradeContract(address _newAddress) external onlySysAdmin whenPaused whenNotUpgraded {

        require(_newAddress != address(0));
        upgraded = true;
        newContractAddress = _newAddress;
        emit ContractUpgrade(_newAddress);
    }

    function addMinter(address _minterAddress) external onlySysAdmin {

        minters.add(_minterAddress);
        require(minters.has(_minterAddress));
    }

    function addOwner(address _ownerAddress) external onlySysAdmin {

        owners.add(_ownerAddress);
        require(owners.has(_ownerAddress));
    }

    function addSysAdmin(address _sysAdminAddress) external onlySysAdmin {

        admins.add(_sysAdminAddress);
        require(admins.has(_sysAdminAddress));
    }

    function stripRoles(address _address) external onlyOwner {

        require(msg.sender != _address);
        bool stripped = false;
        if (admins.has(_address)) {
            admins.remove(_address);
            stripped = true;
        }
        if (minters.has(_address)) {
            minters.remove(_address);
            stripped = true;
        }
        if (owners.has(_address)) {
            owners.remove(_address);
            stripped = true;
        }
        require(stripped == true);
    }

    function pause() external onlySysAdmin whenNotPaused {

        paused = true;
        emit ContractPaused();
    }

    function unpause() external onlySysAdmin whenPaused whenNotUpgraded {

        paused = false;
        emit ContractUnpaused();
    }

}


pragma solidity 0.5.17;





contract AvastarMetadata is AvastarBase, AvastarTypes, AccessControl {


    string public constant INVALID_TOKEN_ID = "Invalid Token ID";

    event TeleporterContractSet(address contractAddress);

    event TokenUriBaseSet(string tokenUriBase);

    event MediaUriBaseSet(string mediaUriBase);

    event ViewUriBaseSet(string viewUriBase);

    IAvastarTeleporter private teleporterContract ;

    string internal tokenUriBase;

    string private mediaUriBase;

    string private viewUriBase;

    function setTeleporterContract(address _address) external onlySysAdmin whenPaused whenNotUpgraded {


        IAvastarTeleporter candidateContract = IAvastarTeleporter(_address);

        require(candidateContract.isAvastarTeleporter());

        teleporterContract = IAvastarTeleporter(_address);

        emit TeleporterContractSet(_address);
    }

    function isAvastarMetadata() external pure returns (bool) {return true;}


    function setTokenUriBase(string calldata _tokenUriBase)
    external onlySysAdmin whenPaused whenNotUpgraded
    {

        tokenUriBase = _tokenUriBase;

        emit TokenUriBaseSet(_tokenUriBase);
    }

    function setMediaUriBase(string calldata _mediaUriBase)
    external onlySysAdmin whenPaused whenNotUpgraded
    {

        mediaUriBase = _mediaUriBase;

        emit MediaUriBaseSet(_mediaUriBase);
    }

    function setViewUriBase(string calldata _viewUriBase)
    external onlySysAdmin whenPaused whenNotUpgraded
    {

        viewUriBase = _viewUriBase;

        emit ViewUriBaseSet(_viewUriBase);
    }

    function viewURI(uint _tokenId)
    public view
    returns (string memory uri)
    {

        require(_tokenId < teleporterContract.totalSupply(), INVALID_TOKEN_ID);
        uri = strConcat(viewUriBase, uintToStr(_tokenId));
    }

    function mediaURI(uint _tokenId)
    public view
    returns (string memory uri)
    {

        require(_tokenId < teleporterContract.totalSupply(), INVALID_TOKEN_ID);
        uri = strConcat(mediaUriBase, uintToStr(_tokenId));
    }

    function tokenURI(uint _tokenId)
    external view
    returns (string memory uri)
    {

        require(_tokenId < teleporterContract.totalSupply(), INVALID_TOKEN_ID);
        uri = strConcat(tokenUriBase, uintToStr(_tokenId));
    }

    function getAvastarMetadata(uint256 _tokenId)
    external view
    returns (string memory metadata) {


        require(_tokenId < teleporterContract.totalSupply(), INVALID_TOKEN_ID);

        uint256 id;
        uint256 serial;
        uint256 traits;
        Generation generation;
        Wave wave;
        Series series;
        Gender gender;
        uint8 ranking;
        string memory attribution;

        wave = teleporterContract.getAvastarWaveByTokenId(_tokenId);

        if (wave == Wave.PRIME) {
            (id, serial, traits, generation, series, gender, ranking) = teleporterContract.getPrimeByTokenId(_tokenId);
        } else {
            (id, serial, traits, generation, gender, ranking)  = teleporterContract.getReplicantByTokenId(_tokenId);
        }

        attribution = teleporterContract.getAttributionByGeneration(generation);
        attribution = strConcat('Original art by: ', attribution);

        metadata = strConcat('{\n  "name": "Avastar #', uintToStr(uint256(id)));
        metadata = strConcat(metadata, '",\n');

        metadata = strConcat(metadata, '  "description": "Generation ');
        metadata = strConcat(metadata, uintToStr(uint8(generation) + 1));

        if (wave == Wave.PRIME && series != Series.PROMO) {
            metadata = strConcat(metadata, ' Series ');
            metadata = strConcat(metadata, uintToStr(uint8(series)));
        }

        if (gender == Gender.MALE) {
            metadata = strConcat(metadata, ' Male ');
        }
        else if (gender == Gender.FEMALE) {
            metadata = strConcat(metadata, ' Female ');
        }
        else {
            metadata = strConcat(metadata, ' Non-Binary ');
        }

        if (wave == Wave.PRIME && series == Series.PROMO) {
            metadata = strConcat(metadata, (serial <100) ? 'Founder. ' : 'Exclusive. ');
        } else {
            metadata = strConcat(metadata, (wave == Wave.PRIME) ? 'Prime. ' : 'Replicant. ');
        }
        metadata = strConcat(metadata, attribution);
        metadata = strConcat(metadata, '",\n');

        metadata = strConcat(metadata, '  "external_url": "');
        metadata = strConcat(metadata, viewURI(_tokenId));
        metadata = strConcat(metadata, '",\n');

        metadata = strConcat(metadata, '  "image": "');
        metadata = strConcat(metadata, mediaURI(_tokenId));
        metadata = strConcat(metadata, '",\n');

        metadata = strConcat(metadata, '  "attributes": [\n');

        metadata = strConcat(metadata, '    {\n');
        metadata = strConcat(metadata, '      "trait_type": "gender",\n');
        metadata = strConcat(metadata, '      "value": "');
        
        if (gender == Gender.MALE) {
            metadata = strConcat(metadata, 'male"');
        }
        else if (gender == Gender.FEMALE) {
            metadata = strConcat(metadata, 'female"');
        }
        else {
            metadata = strConcat(metadata, 'non-binary"');
        }

        metadata = strConcat(metadata, '\n    },\n');

        metadata = strConcat(metadata, '    {\n');
        metadata = strConcat(metadata, '      "trait_type": "wave",\n');
        metadata = strConcat(metadata, '      "value": "');
        metadata = strConcat(metadata, (wave == Wave.PRIME) ? 'prime"' : 'replicant"');
        metadata = strConcat(metadata, '\n    },\n');

        metadata = strConcat(metadata, '    {\n');
        metadata = strConcat(metadata, '      "display_type": "number",\n');
        metadata = strConcat(metadata, '      "trait_type": "generation",\n');
        metadata = strConcat(metadata, '      "value": ');
        metadata = strConcat(metadata, uintToStr(uint8(generation) + 1));
        metadata = strConcat(metadata, '\n    },\n');

        if (wave == Wave.PRIME) {
            metadata = strConcat(metadata, '    {\n');
            metadata = strConcat(metadata, '      "display_type": "number",\n');
            metadata = strConcat(metadata, '      "trait_type": "series",\n');
            metadata = strConcat(metadata, '      "value": ');
            metadata = strConcat(metadata, uintToStr(uint8(series)));
            metadata = strConcat(metadata, '\n    },\n');
        }

        metadata = strConcat(metadata, '    {\n');
        metadata = strConcat(metadata, '      "display_type": "number",\n');
        metadata = strConcat(metadata, '      "trait_type": "serial",\n');
        metadata = strConcat(metadata, '      "value": ');
        metadata = strConcat(metadata, uintToStr(serial));
        metadata = strConcat(metadata, '\n    },\n');

        metadata = strConcat(metadata, '    {\n');
        metadata = strConcat(metadata, '      "display_type": "number",\n');
        metadata = strConcat(metadata, '      "trait_type": "ranking",\n');
        metadata = strConcat(metadata, '      "value": ');
        metadata = strConcat(metadata, uintToStr(ranking));
        metadata = strConcat(metadata, '\n    },\n');

        metadata = strConcat(metadata, '    {\n');
        metadata = strConcat(metadata, '      "trait_type": "level",\n');
        metadata = strConcat(metadata, '      "value": "');
        metadata = strConcat(metadata, getRankingLevel(ranking));
        metadata = strConcat(metadata, '"\n    },\n');

        metadata = strConcat(metadata, assembleTraitMetadata(generation, traits));

        metadata = strConcat(metadata, '  ]\n}');

    }

    function getRankingLevel(uint8 ranking)
    internal pure
    returns (string memory level) {

        require(ranking >0 && ranking <=100);
        uint8[4] memory breaks = [33, 41, 50, 60];
        if (ranking < breaks[0]) {level = "Common";}
        else if (ranking < breaks[1]) {level = "Uncommon";}
        else if (ranking < breaks[2]) {level = "Rare";}
        else if (ranking < breaks[3]) {level = "Epic";}
        else {level = "Legendary";}
    }

    function assembleTraitMetadata(Generation _generation, uint256 _traitHash)
    internal view
    returns (string memory metadata)
    {

        require(_traitHash > 0);
        uint256 slotConst = 256;
        uint256 slotMask = 255;
        uint256 bitMask;
        uint256 slottedValue;
        uint256 slotMultiplier;
        uint256 variation;
        uint256 traitId;

        for (uint8 slot = 0; slot <= uint8(Gene.HAIR_STYLE); slot++){
            slotMultiplier = uint256(slotConst**slot);  // Create slot multiplier
            bitMask = slotMask * slotMultiplier;        // Create bit mask for slot
            slottedValue = _traitHash & bitMask;        // Extract slotted value from hash
            if (slottedValue > 0) {
                variation = (slot > 0)                  // Extract variation from slotted value
                ? slottedValue / slotMultiplier
                : slottedValue;
                if (variation > 0) {
                    traitId = teleporterContract.getTraitIdByGenerationGeneAndVariation(_generation, Gene(slot), uint8(variation));
                    metadata = strConcat(metadata, '    {\n');
                    metadata = strConcat(metadata, '      "trait_type": "');
                    if (slot == uint8(Gene.SKIN_TONE)) {
                        metadata = strConcat(metadata, 'skin_tone');
                    } else if (slot == uint8(Gene.HAIR_COLOR)) {
                        metadata = strConcat(metadata, 'hair_color');
                    } else if (slot == uint8(Gene.EYE_COLOR)) {
                        metadata = strConcat(metadata, 'eye_color');
                    } else if (slot == uint8(Gene.BG_COLOR)) {
                        metadata = strConcat(metadata, 'background_color');
                    } else if (slot == uint8(Gene.BACKDROP)) {
                        metadata = strConcat(metadata, 'backdrop');
                    } else if (slot == uint8(Gene.EARS)) {
                        metadata = strConcat(metadata, 'ears');
                    } else if (slot == uint8(Gene.FACE)) {
                        metadata = strConcat(metadata, 'face');
                    } else if (slot == uint8(Gene.NOSE)) {
                        metadata = strConcat(metadata, 'nose');
                    } else if (slot == uint8(Gene.MOUTH)) {
                        metadata = strConcat(metadata, 'mouth');
                    } else if (slot == uint8(Gene.FACIAL_FEATURE)) {
                        metadata = strConcat(metadata, 'facial_feature');
                    } else if (slot == uint8(Gene.EYES)) {
                        metadata = strConcat(metadata, 'eyes');
                    } else if (slot == uint8(Gene.HAIR_STYLE)) {
                        metadata = strConcat(metadata, 'hair_style');
                    }
                    metadata = strConcat(metadata, '",\n');
                    metadata = strConcat(metadata, '      "value": "');
                    metadata = strConcat(metadata, teleporterContract.getTraitNameById(traitId));
                    metadata = strConcat(metadata, '"\n    }');
                    if (slot < uint8(Gene.HAIR_STYLE))  metadata = strConcat(metadata, ',');
                    metadata = strConcat(metadata, '\n');

                }
            }
        }
    }

}