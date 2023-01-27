
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
}struct MetadataStruct {

	uint tokenId;
	uint collectionId;
	uint numTraits;
	string description;
	string unRevealedImage;

}// MIT
pragma solidity ^0.8.0;

interface LinkTokenInterface {


  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );


  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );


  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );


  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );


  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;


  function name()
    external
    view
    returns (
      string memory tokenName
    );


  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );


  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );


  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );


  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


}// MIT
pragma solidity ^0.8.0;

contract VRFRequestIDBase {


  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  )
    internal
    pure
    returns (
      uint256
    )
  {

    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {

    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}// MIT
pragma solidity ^0.8.0;



abstract contract VRFConsumerBase is VRFRequestIDBase {

  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  constructor(
    address _vrfCoordinator,
    address _link
  ) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}// MIT
pragma solidity ^0.8.7;


contract metadataAddonContract  {


    function getImage(uint _collectionId, uint _tokenId) external view returns (string memory) {}


    function getMetadata(uint _collectionId, uint _tokenId) external view returns (string memory) {}


}

contract MetadataManager is Ownable, VRFConsumerBase {



    struct Phoenix {
        uint128 hash;
        uint8 level;
        string name;
    }

    struct TraitRarity {
        uint16 rarityRange;
        uint16 index;
    }

    struct MythicInfo {
        string image;
        string name;
    }

    mapping(uint => mapping(uint => address)) propertyAddresses;

    mapping(uint => mapping (uint => uint)) mythicTokens;

    mapping(uint => mapping(uint => uint16[])) PropertyRarityRanges;

    mapping(uint => mapping(uint => TraitRarity[])) PropertyRarities;

    mapping(uint => bool) collectionRevealed;

    mapping(uint => mapping(uint => MythicInfo)) mythicInfoMap;

    mapping(uint => uint) mythicsAdded;

    mapping(uint => uint) totalMythics;

    address[] addonAddresses;

    mapping(address => bool) acceptedAddresses;

    mapping(uint => uint[]) mythicRewardPool;

    string public constant header = '<svg id="phoenix" width="100%" height="100%" version="1.1" viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">';
    string public constant footer = '<style>#phoenix{image-rendering: pixelated;}</style></svg>';

    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;

    uint numPhoenixToReveal;
    uint supplyPoolToGiveaway;
    uint revealingCollectionId;
    bool rewardFromPool;
    uint verifiablyRandomNumber;


    event randomNumberRecieved(uint randomness);



    constructor()  VRFConsumerBase(
                    0xf0d54349aDdcf704F77AE15b96510dEA15cb7952, // VRF Coordinator
                    0x514910771AF9Ca656af840dff83E8264EcF986CA  // LINK Token
                    ) {



        keyHash = 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
        fee = 2 * 10 ** 18; // 0.1 LINK (Varies by network)


    }


    function generateImage(uint[] memory _traits, uint _tokenId, uint _collectionId, uint _numTraits) internal view returns(string memory) {


        uint mythicId = mythicTokens[_collectionId][_tokenId];
        string memory image;

        if (mythicId > 0) {

            MythicInfo memory mythicInfo = mythicInfoMap[_collectionId][mythicId];
            

            if(bytes(mythicInfo.name).length > 0) {
                image = wrapTag(mythicInfo.image);
            } else {
                image = getImage(_numTraits, mythicId - 1, _collectionId);
            }

            return string(abi.encodePacked(header, image, getAdditionalImage(_collectionId, _tokenId), footer));

        } 

        image = header;

        for(uint i = 0; i < _numTraits; i++) {
            image = string(abi.encodePacked(image, getImage(i, _traits[i], _collectionId)));
        }


        return string(abi.encodePacked(image, getAdditionalImage(_collectionId, _tokenId), footer));
    }


    function tokenURI(Phoenix memory _phoenix, MetadataStruct memory _metadataStruct) public view returns (string memory) {


        if(bytes(_phoenix.name).length == 0) {
            _phoenix.name = string(abi.encodePacked('Phoenix #', ImageHelper.toString(_metadataStruct.tokenId)));
        }

        if(collectionRevealed[_metadataStruct.collectionId] == false) {
            return
            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    ImageHelper.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "', _phoenix.name,'", "description": "', _metadataStruct.description, '", "image": "',
                                'data:image/svg+xml;base64,',
                                ImageHelper.encode((abi.encodePacked(header, wrapTag(_metadataStruct.unRevealedImage), footer))),
                                '","attributes": [{"trait_type": "Level", "value": "', ImageHelper.toString(_phoenix.level), '"}]}'
                            )
                        )
                    )
                )
            );
        }

        uint[] memory traits = getTraitsFromHash(_phoenix.hash, _metadataStruct.collectionId, _metadataStruct.numTraits);

        string memory image = ImageHelper.encode(bytes(generateImage(traits, _metadataStruct.tokenId, _metadataStruct.collectionId, _metadataStruct.numTraits)));

        return

            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    ImageHelper.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "', _phoenix.name,'", "description": "', _metadataStruct.description, '", "image": "',
                                'data:image/svg+xml;base64,',
                                image,
                                '",',

                                getAttributes(traits, _metadataStruct.collectionId, _metadataStruct.numTraits, _phoenix.level, _metadataStruct.tokenId),
                                getAdditionalMetadata(_metadataStruct.collectionId, _metadataStruct.tokenId),
                                
                                ']',
                                '}'
                            )
                        )
                    )
                )
            );
    }
    
    function call(address _source, bytes memory _sig) internal view returns (string memory) {
        (bool succ, bytes memory ret)  = _source.staticcall(_sig);
        require(succ, "failed to get data");
        return abi.decode(ret, (string));
    }

    function getImage(uint _propertyIndex, uint _id, uint _collectionId) internal view returns (string memory) {
        address source = propertyAddresses[_collectionId][uint(_propertyIndex)];

        string memory image = call(source, abi.encodeWithSignature(string(abi.encodePacked("trait", ImageHelper.toString(_id), "()")), ""));

        if(bytes(image).length > 0) {
             return wrapTag(image);
        } else {
            return "";
        }

       
    }

    function getTraitName(uint _propertyIndex, uint _id, uint _collectionId) internal view returns (string memory) {
        address source = propertyAddresses[_collectionId][uint(_propertyIndex)];

        return call(source, abi.encodeWithSignature(string(abi.encodePacked("name", ImageHelper.toString(_id), "()")), ""));
    }

    function getPropertyName(uint _propertyIndex,  uint _collectionId) internal view returns (string memory) {
        address source = propertyAddresses[_collectionId][_propertyIndex];

        return call(source, abi.encodeWithSignature("propertyName()", ""));
    }
    
    function wrapTag(string memory uri) internal pure returns (string memory) {
    
        return string(abi.encodePacked('<image x="0" y="0" width="48" height="48" xlink:href="data:image/png;base64,', uri, '"/>'));
    
    }

    function getAttributes(uint[] memory _traits, uint _collectionId, uint _numTraits, uint8 _level, uint _tokenId) internal view returns (string memory) {
       
        string memory attributeString;

        uint mythicId = mythicTokens[_collectionId][_tokenId];

        if (mythicId > 0) {

            MythicInfo memory mythicInfo = mythicInfoMap[_collectionId][mythicId];
            

            if(bytes(mythicInfo.name).length > 0) {
                attributeString = string(abi.encodePacked('{"trait_type": "', getPropertyName(_numTraits, _collectionId), '","value": "', mythicInfo.name,'"}', ",")) ;
            } else {
                attributeString = string(abi.encodePacked(getTraitAttributes(mythicId - 1, _numTraits, _collectionId)));
            }

        } else {
            for(uint i = 0; i < _numTraits; i++) {
                attributeString = string(abi.encodePacked(attributeString, getTraitAttributes(_traits[i], i, _collectionId)));
            }
        }

        return string(abi.encodePacked(
            '"attributes": [',
            attributeString, 
            '{"trait_type": "Level", "value": "', ImageHelper.toString(_level), '"}'));
    }

    function getTraitAttributes(uint _traitId, uint _propertyIndex, uint _collectionId) internal view returns(string memory) {

        string memory traitName = getTraitName(_propertyIndex, _traitId, _collectionId);
        if(bytes(traitName).length == 0) {
            return "";
        }
        return string(abi.encodePacked('{"trait_type": "', getPropertyName(_propertyIndex, _collectionId), '","value": "', traitName,'"}', ","));
    }

    function traitPicker(uint16 _randinput, TraitRarity[] memory _traitRarities) internal pure returns (uint)
    {

        uint minIndex = 0;
        uint maxIndex = _traitRarities.length -1;
        uint midIndex;

        while(minIndex < maxIndex) {

            midIndex = (minIndex + maxIndex) / 2;

            if(minIndex == midIndex) {
                if(_randinput <= _traitRarities[minIndex].rarityRange) {
                    return _traitRarities[minIndex].index;
                }

                return _traitRarities[maxIndex].index;
            }

            if(_randinput <= _traitRarities[midIndex].rarityRange) {
                maxIndex = midIndex;

            } else {
                minIndex = midIndex;
                
            }

        }

        return _traitRarities[midIndex].index;
        
    }

    
    function getTraitsFromHash(uint128 _hash, uint _collectionId, uint _numTraits) public view returns(uint[] memory) {

        uint[] memory traits = new uint[](_numTraits);
        uint16 randomInput;

        for(uint i = 0; i < _numTraits; i++) {

            randomInput = uint16((_hash / 10000**i % 10000));

            traits[i] = traitPicker(randomInput, PropertyRarities[_collectionId][i]);

        }

        return traits;

    }


    function getAdditionalImage(uint _collectionId, uint _tokenId) internal view returns(string memory) {

        string memory images;

        for(uint i = 0; i < addonAddresses.length; i++) {

            abi.encodePacked(images, metadataAddonContract(addonAddresses[i]).getImage(_collectionId, _tokenId));

        }

        return images;

    }

    function getAdditionalMetadata(uint _collectionId, uint _tokenId) internal view returns(string memory) {

        string memory metaData;

        for(uint i = 0; i < addonAddresses.length; i++) {

            if(addonAddresses[i] != address(0)) {

                metaData = string(abi.encodePacked(metaData, metadataAddonContract(addonAddresses[i]).getMetadata(_collectionId, _tokenId)));

            }

        }

        if(bytes(metaData).length > 0) {
            metaData = string(abi.encodePacked(",", metaData));
        }

        return metaData;
    }

    function getRarityIndex(uint _collectionId, uint index) external view returns(uint16[] memory) {
        return PropertyRarityRanges[_collectionId][index];
    }

    function getSpecialToken(uint _collectionId, uint _tokenId) public view returns(uint) {
        return mythicTokens[_collectionId][_tokenId];
    }

    function getPropertyRarities(uint _collectionId, uint _propertyIndex) public view returns(TraitRarity[] memory) {

        require(PropertyRarities[_collectionId][_propertyIndex].length > 0, "Property index out of range");

        return PropertyRarities[_collectionId][_propertyIndex];

    }

    function getRewardPool(uint _collectionId) public view returns(uint[] memory) {
        return mythicRewardPool[_collectionId];
    }



    function setProperty(uint8 _propertyIndex, uint8 _collectionId, address _addr) external onlyOwner {

        propertyAddresses[_collectionId][_propertyIndex] = _addr;     
    }

    function setPropertyRarities(uint16[] calldata rarities, uint collectionId, uint propertyId) external onlyOwner {
  
        PropertyRarityRanges[collectionId][propertyId] = rarities; 
    }

    
    function revealCollection(uint _collectionId, uint _numProperties, uint _totalMythics) external onlyOwner {

        require(collectionRevealed[_collectionId] == false, "Collection already revealed");

        collectionRevealed[_collectionId] = true;

        for(uint i = 0; i < _numProperties; i++) {

            mixUpTraits(_collectionId, i);

        }

        totalMythics[_collectionId] = _totalMythics;

    }

    function mixUpTraits(uint _collectionId, uint _propertyIndex) internal onlyOwner {

        uint hash =  uint256(
                    keccak256(
                        abi.encodePacked(
                            block.timestamp,
                            block.difficulty, _collectionId, _propertyIndex)
                    )    
                );

        uint total = 0;

        uint16[] memory traitRarities = PropertyRarityRanges[_collectionId][_propertyIndex];

        uint tempLength = traitRarities.length;

        uint index = 0;

        require(tempLength > 0, "temp length should be more than zero");

        for(uint j = 0; j < traitRarities.length; j++) {

            index = (hash / ((j + 1) * 100000))  % tempLength;

            total += traitRarities[index];

            PropertyRarities[_collectionId][_propertyIndex].push(TraitRarity(
                uint16(total),
                uint16(index)
            ));

            uint16 last = traitRarities[tempLength - 1];

            traitRarities[index] = last;

            tempLength -= 1;
  
        }

    }

    function setAcceptedAddress(address _acceptedAddress, bool _value) external onlyOwner {

        acceptedAddresses[_acceptedAddress] = _value;

    }

    function setAddonContractAddress(address _addr, uint _index) external onlyOwner {

        require(_index <= addonAddresses.length, "index out of range");

        if(_index == addonAddresses.length) {
            addonAddresses.push(_addr);

        } else {
            addonAddresses[_index] = _addr;
        }

    }

    function resurrect(uint _collectionId, uint _tokenId) external {

        require(acceptedAddresses[msg.sender] == true, "Address cannot call this function");

        require(mythicTokens[_collectionId][_tokenId] == 0, "Mythic tokens refuse to be resurected");

        mythicRewardPool[_collectionId].push(_tokenId);

    }




    function addMythicToPool(MythicInfo calldata _mythicInfo, uint _collectionId) external onlyOwner {

        uint total =  totalMythics[_collectionId];

        mythicInfoMap[_collectionId][total] = _mythicInfo;

        totalMythics[_collectionId] += 1;

    }

    

    function rewardMythics(uint _collectionId, uint _numMythics) external {

        require(verifiablyRandomNumber != 0, "verifiablyRandomNumber has not been set");

        require(acceptedAddresses[msg.sender] == true, "Address cannot call this function");

        uint lastMythic = mythicsAdded[_collectionId];

        uint numInPool = totalMythics[_collectionId] - lastMythic;

        require(numInPool <= _numMythics, "Trying to give away more mythics than exist");

        uint[] memory rewardPool = mythicRewardPool[_collectionId];

        uint tempLength = rewardPool.length;

        require(tempLength >= _numMythics, "More mythics to add than there are tokens in pool to give");

        uint totalMythicsGiven = 0;

        while(totalMythicsGiven < _numMythics) {

            require(tempLength > 0, "Length of reward pool is zero");

            uint randindex = (verifiablyRandomNumber / ((totalMythicsGiven + 1) * 5000)) % tempLength;

            if(mythicTokens[_collectionId][rewardPool[randindex]] == 0) {
                mythicTokens[_collectionId][rewardPool[randindex]] = lastMythic;
                mythicsAdded[_collectionId] += 1;

                lastMythic += 1;
                totalMythicsGiven += 1;
            }

            rewardPool[randindex] = rewardPool[tempLength - 1];

            tempLength -= 1;

        }

        uint[] memory clearedPool;

        mythicRewardPool[_collectionId] = clearedPool;


        verifiablyRandomNumber = 0;


    }

    function revealMythics(uint _numMythic, uint _collectionId, uint _totalSupply, uint _verifiablyRandomNumber) internal {

        uint i = 0;
        uint uniqueChosen = 0;

        uint total = mythicsAdded[_collectionId];
    
        while(uniqueChosen < _numMythic) {

            uint randomInput = (_verifiablyRandomNumber / (_totalSupply**i) % _totalSupply);
            
            if(mythicTokens[_collectionId][randomInput] == 0) {
                uniqueChosen += 1;
                mythicTokens[_collectionId][randomInput] = total;
                total++; 
            }

            i++; 

        }

        mythicsAdded[_collectionId] = total;

    }



    function initiateCallToGiveawayMythics(uint _numMythics, uint _numberInSupply, uint _collectionId, bool _rewardFromResurrection) external onlyOwner {

        require(mythicsAdded[_collectionId] + _numMythics <= totalMythics[_collectionId], "Trying to give away too many mythics than exist");

        numPhoenixToReveal = _numMythics;
        supplyPoolToGiveaway = _numberInSupply;
        revealingCollectionId = _collectionId;
        rewardFromPool = _rewardFromResurrection;
        getRandomNumber();

    }


    function getRandomNumber() internal returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {

        emit randomNumberRecieved(randomness);

        if(rewardFromPool) {
            verifiablyRandomNumber = randomness;
        } else {

            revealMythics(numPhoenixToReveal, revealingCollectionId, supplyPoolToGiveaway, randomness);

        }
    }

}

    


library ImageHelper {


    
    string internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return '';
        
        string memory table = TABLE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)
            
            let tablePtr := add(table, 1)
            
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))
            
            let resultPtr := add(result, 32)
            
            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 3)
               
               let input := mload(dataPtr)
               
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))
               resultPtr := add(resultPtr, 1)
               mstore(resultPtr, shl(248, mload(add(tablePtr, and(        input,  0x3F)))))
               resultPtr := add(resultPtr, 1)
            }
            
            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }
        
        return result;
    }

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

}