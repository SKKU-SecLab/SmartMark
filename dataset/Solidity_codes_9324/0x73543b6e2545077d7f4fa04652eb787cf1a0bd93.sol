
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

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT
pragma solidity ^0.8.0;


interface ICollection721 {

    function isOwnerOfBatch(uint256[] calldata tokenIds_, address address_) external view returns (bool);

    function ownerOf(uint256 tokenId) external view returns (address);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

}

interface IMintPass {

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

}

interface IToken {

    function add(address wallet, uint256 amount) external;

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mintTokens(address to, uint256 amount) external;

}

interface IGameStats {

    function getLevelBoosts(address collection, uint256[] calldata tokenIds) external view returns (uint256[] memory);

    function getLevelBoost(address collection, uint256 tokenId) external view returns (uint256);

    function getLevel(address collection, uint256 tokenId) external returns (uint256);

    function setTokensData(
        address collection,
        uint256[] calldata tokenIds,
        uint256[] calldata levels,
        bool[] calldata factions,
        bool[] calldata elites
    ) external;

    function isUnStakeClaimSuccessful(
        address collection,
        uint256 tokenId,
        uint256 amount,
        uint256 stakeType
    ) external returns (bool);

    function setStakedTokenData(
        address collection,
        address owner,
        uint256 stakeType,
        uint256[] calldata tokenIds
    ) external;

    function unsetStakedTokenData(
        address collection,
        uint256[] calldata tokenIds
    ) external;

}

contract BloodShedBearsStaking is Ownable, Pausable {

    struct CollectionSettings {
        bool hasLevel;
        uint256 baseYieldRate;
    }

    struct StakeData {
        uint256 stakeType;
        uint256 claimDate;
        uint256 houseTokenId;
    }

    struct HouseEnrol {
        uint256 enrolDate;
        uint256 tokenId;
    }

    struct UnStakeSelection {
        address collectionAddress;
        uint256[] tokens;
    }

    struct StakeSelection {
        uint256 targetHouse;
        uint256 stakeType;
        address collectionAddress;
        uint256[] tokens;
        uint256[] levels;
        bool[] factions;
        bool[] elites;
        bytes[] signatures;
    }

    struct StakedTokens {
        uint256 tokenId;
        uint256 stakeType;
        uint256 claimDate;
        uint256 houseTokenId;
    }

    address private signerAddress;

    mapping(string => address) public contractsAddressesMap;
    mapping(string => uint256) public stakeTypesVariables;

    mapping(address => mapping(address => uint256[])) public stakedTokensByWallet;
    mapping(address => mapping(uint256 => StakeData)) public stakedTokensData;

    uint256 public treeHouseBoost = 30;
    mapping(uint256 => mapping(address => HouseEnrol[])) public treeHousesEnrolments;

    mapping(address => CollectionSettings) public collectionsSettings;
    address[] public collections;

    mapping(address => uint256) public partnerCollectionYield;
    mapping(address => mapping(uint256 => bool)) public claimedPartnerTokens;

    mapping(address => uint256) public walletsStakedPasses;
    mapping(address => uint256) public passesStakeDate;

    function addCollectionSettings(
        CollectionSettings[] calldata settings_,
        address[] calldata collections_
    ) external onlyOwner {

        for (uint256 i = 0; i < collections_.length; ++i) {
            CollectionSettings storage cs = collectionsSettings[collections_[i]];
            cs.baseYieldRate = settings_[i].baseYieldRate;
            cs.hasLevel = settings_[i].hasLevel;
        }
        collections = collections_;
    }

    function setTreeHouseBoost(uint256 boost_) external onlyOwner {

        treeHouseBoost = boost_;
    }

    function setSignerAddress(address signerAddress_) external onlyOwner {

        signerAddress = signerAddress_;
    }

    function setContractAddressesKeys(
        string[] calldata keys_,
        address[] calldata collections_
    ) external onlyOwner {

        for (uint i = 0; i < keys_.length; ++i) {
            contractsAddressesMap[keys_[i]] = collections_[i];
        }
    }

    function setStakeTypesKeys(
        string[] calldata keys_,
        uint256[] calldata stakeTypesIndexes_
    ) external onlyOwner {

        for (uint256 i = 0; i < keys_.length; ++i) {
            stakeTypesVariables[keys_[i]] = stakeTypesIndexes_[i];
        }
    }

    function setPartnerProjectsYielding(
        address[] calldata addresses_,
        uint256[] calldata yieldingAmounts_
    ) external onlyOwner {

        for (uint256 i = 0; i <  addresses_.length; ++i) {
            partnerCollectionYield[addresses_[i]] = yieldingAmounts_[i];
        }
    }

    function _moveTokenInTheListStake(
        uint256[] storage list,
        uint256 tokenId
    ) internal {

        uint256 foundIndex;
        uint256 i;
        for (; i < list.length; ++i) {
            if (list[i] == tokenId) {
                foundIndex = i;
                break;
            }
        }

        require(i != list.length, "NOT OWNED");

        if (foundIndex != list.length - 1) {
            uint256 t = list[foundIndex];
            list[foundIndex] = list[list.length - 1];
            list[list.length - 1] = t;
        }
    }

    function _moveTokenInTheListHouse(
        HouseEnrol[] storage list,
        uint256 tokenId
    ) internal  {

        uint256 foundIndex;
        uint256 i;
        for (; i < list.length; ++i) {
            if (list[i].tokenId == tokenId) {
                foundIndex = i;
                break;
            }
        }

        require(i != list.length, "NOT OWNED");

        if (foundIndex != list.length - 1) {
            HouseEnrol memory he = list[foundIndex];
            list[foundIndex] = list[list.length - 1];
            list[list.length - 1] = he;
        }
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns(bytes4) {

        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns (bytes4) {

        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function _validateMultipleSignature(
        StakeSelection[] calldata selections_
    ) internal {

        for (uint256 i = 0; i < selections_.length; i++) {
            if (selections_[i].signatures.length == 0) {
                continue;
            }

            bool isValid = true;

            for (uint256 j = 0; j < selections_[i].tokens.length; j++) {
                bytes32 dataHash = keccak256(abi.encodePacked(
                        selections_[i].collectionAddress,
                        selections_[i].tokens[j],
                        selections_[i].levels[j],
                        selections_[i].elites[j],
                        selections_[i].factions[j]
                    ));

                bytes32 message = ECDSA.toEthSignedMessageHash(dataHash);
                address receivedAddress = ECDSA.recover(message, selections_[i].signatures[j]);
                isValid = isValid && (receivedAddress != address(0) && receivedAddress == signerAddress);
            }

            require(isValid);

            IGameStats(contractsAddressesMap["gameStats"]).setTokensData(
                selections_[i].collectionAddress,
                selections_[i].tokens,
                selections_[i].levels,
                selections_[i].factions,
                selections_[i].elites
            );
        }
    }


    function stakePasses(
        uint256 amount_,
        bool withdrawCurrentYield
    ) external whenNotPaused {

        require(IMintPass(contractsAddressesMap["mintPass"]).balanceOf(msg.sender, 0) >= amount_);

        if (walletsStakedPasses[msg.sender] != 0) {
            if (withdrawCurrentYield) {
                withdrawPassesYield();
            } else {
                transferPassesYieldIntoInternalWallet(msg.sender);
            }
        } else {
            passesStakeDate[msg.sender] = block.timestamp;
        }

        walletsStakedPasses[msg.sender] += amount_;
        IMintPass(contractsAddressesMap["mintPass"]).safeTransferFrom(msg.sender, address(this), 0, amount_, "");
    }

    function unStakePasses(bool withdraw) external whenNotPaused  {

        if (withdraw) {
            withdrawPassesYield();
        } else {
            transferPassesYieldIntoInternalWallet(msg.sender);
        }

        IMintPass(contractsAddressesMap["mintPass"]).safeTransferFrom(address(this), msg.sender, 0, walletsStakedPasses[msg.sender], "");

        walletsStakedPasses[msg.sender] = 0;
    }

    function withdrawPassesYield() public whenNotPaused {

        IToken(contractsAddressesMap["token"]).mintTokens(msg.sender, _claimMetaPassEarning(msg.sender));
    }

    function transferPassesYieldIntoInternalWallet(address wallet_) public whenNotPaused {

        IToken(contractsAddressesMap["token"]).add(wallet_, _claimMetaPassEarning(msg.sender));
    }

    function _claimMetaPassEarning(address wallet_) internal returns (uint256) {

        uint256 amount = calculateMetaPassesYield(wallet_);
        passesStakeDate[wallet_] = block.timestamp;

        return amount;
    }

    function calculateMetaPassesYield(address wallet_) public view returns (uint256) {

        return (block.timestamp - passesStakeDate[wallet_]) *
            walletsStakedPasses[wallet_] *
            collectionsSettings[contractsAddressesMap["mintPass"]].baseYieldRate / 1 days;
    }


    function claimPartnerTokens(
        address collection_,
        uint256[] calldata tokenIds_,
        bool withdrawYield
    ) external whenNotPaused {

        require(partnerCollectionYield[collection_] != 0);
        for (uint256 i = 0; i < tokenIds_.length; ++i) {
            require(ICollection721(collection_).ownerOf(tokenIds_[i]) == msg.sender);
            claimedPartnerTokens[collection_][tokenIds_[i]] = true;
        }
        if (withdrawYield) {
            IToken(contractsAddressesMap["token"]).mintTokens(msg.sender, partnerCollectionYield[collection_] * tokenIds_.length);
        } else {
            IToken(contractsAddressesMap["token"]).add(msg.sender, partnerCollectionYield[collection_] * tokenIds_.length);
        }
    }


    function _getHouseOccupancy(uint256 houseId) internal view returns (uint256) {

        uint256 occupancy = 0;

        for (uint256 i = 0; i < collections.length; ++i) {
            occupancy += treeHousesEnrolments[houseId][collections[i]].length;
        }

        return occupancy;
    }

    function isOwner(address wallet_, address collection_, uint256 tokenId_) public view returns (bool) {

        for (uint256 i = 0; i <  stakedTokensByWallet[wallet_][collection_].length; ++i) {
            if (stakedTokensByWallet[wallet_][collection_][i] == tokenId_) {
                return true;
            }
        }

        return false;
    }

    function stakeTokens(StakeSelection[] calldata selections_) external whenNotPaused {

        _validateMultipleSignature(selections_);

        for (uint256 i = 0; i < selections_.length; ++i) {
            require(ICollection721(selections_[i].collectionAddress).isOwnerOfBatch(selections_[i].tokens, msg.sender));

            if (selections_[i].collectionAddress == contractsAddressesMap["tokenGenerator"]) {
                require(selections_[i].stakeType == stakeTypesVariables["treeHouse"]);
            }

            if (selections_[i].collectionAddress == contractsAddressesMap["treeHouse"]) {
                require(selections_[i].stakeType == stakeTypesVariables["home"]);
            }

            bool stack = selections_[i].stakeType == stakeTypesVariables["treeHouse"];

            if (stack) {
                require(isOwner(msg.sender, contractsAddressesMap["treeHouse"], selections_[i].targetHouse));
                require(
                    selections_[i].tokens.length + _getHouseOccupancy(selections_[i].targetHouse)
                    <= IGameStats(contractsAddressesMap["gameStats"]).getLevel(
                            contractsAddressesMap["treeHouse"],
                            selections_[i].targetHouse
                ));
            }

            for (uint256 j = 0; j < selections_[i].tokens.length; ++j) {
                _enterStakeStance(
                    selections_[i].collectionAddress,
                    selections_[i].tokens[j],
                    selections_[i].stakeType,
                    false
                );

                if (stack) {
                    _enterStackStance(
                        selections_[i].collectionAddress,
                        selections_[i].tokens[j],
                        selections_[i].targetHouse
                    );
                }
                ICollection721(selections_[i].collectionAddress)
                    .safeTransferFrom(msg.sender, address(this), selections_[i].tokens[j]);
            }

            IGameStats(contractsAddressesMap["gameStats"]).setStakedTokenData(
                selections_[i].collectionAddress,
                msg.sender,
                selections_[i].stakeType,
                selections_[i].tokens
            );

            delete stack;
        }
    }

    function _enterStakeStance(
        address collection_,
        uint256 tokenId_,
        uint256 stakeType_,
        bool skipPushing
    ) internal {

        if (!skipPushing) {
            stakedTokensByWallet[msg.sender][collection_].push(tokenId_);
        }
        StakeData storage stake = stakedTokensData[collection_][tokenId_];
        stake.stakeType = stakeType_;
        stake.claimDate = block.timestamp;
    }

    function _enterStackStance(
        address collection_,
        uint256 tokenId_,
        uint256 treeHouseId_
    ) internal {

        treeHousesEnrolments[treeHouseId_][collection_].push(HouseEnrol({
            enrolDate : block.timestamp,
            tokenId: tokenId_
        }));
        stakedTokensData[collection_][tokenId_].houseTokenId = treeHouseId_;
    }

    function unStakeTokens(UnStakeSelection[] calldata selections_) external whenNotPaused {

        uint256 totalAccumulatedYield;
        for (uint256 i = 0; i < selections_.length; ++i) {
            totalAccumulatedYield += _exitStakeStanceMany(
                selections_[i].collectionAddress,
                selections_[i].tokens,
                true,
                true,
                false
            );

            IGameStats(contractsAddressesMap["gameStats"]).unsetStakedTokenData(
                selections_[i].collectionAddress,
                selections_[i].tokens
            );
        }

        IToken(contractsAddressesMap["token"]).add(msg.sender, totalAccumulatedYield);
    }

    function _exitStakeStanceMany(
        address collection_,
        uint256[] calldata tokenIds_,
        bool transferTokens,
        bool updateClaimDate,
        bool skipPopping
    ) internal returns(uint256) {

        uint256 yieldedAmount;

        uint256[] memory levelBoosts;

        if(collectionsSettings[collection_].hasLevel) {
            levelBoosts = IGameStats(contractsAddressesMap["gameStats"]).getLevelBoosts(collection_, tokenIds_);
        } else {
            levelBoosts = new uint256[](tokenIds_.length);
        }

        for (uint256 i = 0; i < tokenIds_.length; ++i) {
            require(isOwner(msg.sender, collection_, tokenIds_[i]));

            yieldedAmount += _getYield(collection_, tokenIds_[i], levelBoosts[i], updateClaimDate);

            _exitStakeStance(collection_, tokenIds_[i], skipPopping);

            if (transferTokens) {
                ICollection721(collection_).safeTransferFrom(address(this), msg.sender, tokenIds_[i]);
            }
        }

        delete levelBoosts;

        return yieldedAmount;
    }

    function _exitStakeStance(
        address collection_,
        uint256 tokenId_,
        bool skipPopping
    ) internal {

        if (collection_ == contractsAddressesMap["treeHouse"]) {
            require(_getHouseOccupancy(tokenId_) == 0);
        }

        if (!skipPopping) {
            _moveTokenInTheListStake(stakedTokensByWallet[msg.sender][collection_], tokenId_);
            stakedTokensByWallet[msg.sender][collection_].pop();
        }

        if (stakedTokensData[collection_][tokenId_].stakeType == stakeTypesVariables["treeHouse"]) {
            _exitStackStance(collection_, tokenId_);
        }

        delete stakedTokensData[collection_][tokenId_];
    }

    function _exitStackStance(
        address collection_,
        uint256 tokenId_
    ) internal {

        _moveTokenInTheListHouse(
            treeHousesEnrolments[stakedTokensData[collection_][tokenId_].houseTokenId][collection_],
            tokenId_
        );
        treeHousesEnrolments[stakedTokensData[collection_][tokenId_].houseTokenId][collection_].pop();
    }

    function moveIntoDifferentStake(StakeSelection[] calldata selections_) external whenNotPaused {

        uint256 totalAccumulatedYield;
        for (uint256 i = 0; i < selections_.length; ++i) {
            totalAccumulatedYield += _exitStakeStanceMany(
                selections_[i].collectionAddress,
                selections_[i].tokens,
                false,
                false,
                true
            );

            IGameStats(contractsAddressesMap["gameStats"]).unsetStakedTokenData(
                selections_[i].collectionAddress,
                selections_[i].tokens
            );

            require(selections_[i].collectionAddress != contractsAddressesMap["tokenGenerator"]);
            require(selections_[i].collectionAddress != contractsAddressesMap["treeHouse"]);

            bool stack = selections_[i].stakeType == stakeTypesVariables["treeHouse"];

            if (stack) {
                require(isOwner(msg.sender, contractsAddressesMap["treeHouse"], selections_[i].targetHouse));
                require(
                    selections_[i].tokens.length + _getHouseOccupancy(selections_[i].targetHouse)
                    <= IGameStats(contractsAddressesMap["gameStats"])
                        .getLevel(contractsAddressesMap["treeHouse"], selections_[i].targetHouse)
                );
            }
            for (uint256 j = 0; j < selections_[i].tokens.length; ++j) {
                _enterStakeStance(
                    selections_[i].collectionAddress,
                    selections_[i].tokens[j],
                    selections_[i].stakeType,
                    true
                );
                if (stack) {
                    _enterStackStance(
                        selections_[i].collectionAddress,
                        selections_[i].tokens[j],
                        selections_[i].targetHouse
                    );
                }
            }

            IGameStats(contractsAddressesMap["gameStats"]).setStakedTokenData(
                selections_[i].collectionAddress,
                msg.sender,
                selections_[i].stakeType,
                selections_[i].tokens
            );
        }

        IToken(contractsAddressesMap["token"]).add(msg.sender, totalAccumulatedYield);

        delete totalAccumulatedYield;
    }


    function _getYield(
        address collection_,
        uint256 tokenId_,
        uint256 tokenLevelBoost,
        bool updateClaimField
    ) internal returns (uint256) {

        uint256 yield = collectionsSettings[collection_].baseYieldRate *
        (block.timestamp - stakedTokensData[collection_][tokenId_].claimDate) / 1 days;

        if (stakedTokensData[collection_][tokenId_].stakeType == stakeTypesVariables["training"]) {
            yield = yield / 2;
        }

        if (collectionsSettings[collection_].hasLevel) {
            yield += yield * tokenLevelBoost / 100;
        }

        if (stakedTokensData[collection_][tokenId_].stakeType == stakeTypesVariables["treeHouse"]) {

            HouseEnrol[] storage houseEnrols = treeHousesEnrolments[stakedTokensData[collection_][tokenId_].houseTokenId][collection_];

            uint256 foundIndex;
            uint256 i;
            for (; i < houseEnrols.length; ++i) {
                if (houseEnrols[i].tokenId == tokenId_) {
                    foundIndex = i;
                    break;
                }
            }

            require(i != houseEnrols.length, "NOT OWNED");

            yield += (block.timestamp - houseEnrols[foundIndex].enrolDate) *
                collectionsSettings[collection_].baseYieldRate *
                treeHouseBoost /
                100 days;

            if (updateClaimField) {
                houseEnrols[foundIndex].enrolDate = block.timestamp;
            }
        }

        if (
            stakedTokensData[collection_][tokenId_].stakeType != stakeTypesVariables["training"] &&
            (
                collection_ == contractsAddressesMap["gen0"] ||
                collection_ == contractsAddressesMap["gen1"]
            )
        ) {
            if (
                !IGameStats(contractsAddressesMap["gameStats"])
                    .isUnStakeClaimSuccessful(
                        collection_,
                        tokenId_,
                        yield,
                        stakedTokensData[collection_][tokenId_].stakeType)
            ) {
                yield = 0;
            }
        }

        if (updateClaimField) {
            stakedTokensData[collection_][tokenId_].claimDate = block.timestamp;
        }

        return yield;
    }

    function claimYield(
        address collection_,
        uint256[] memory tokenIds_
    ) external whenNotPaused returns (uint256) {


        uint256 amount;
        uint256[] memory levelBoosts;

        if(collectionsSettings[collection_].hasLevel) {
            levelBoosts = IGameStats(contractsAddressesMap["gameStats"]).getLevelBoosts(collection_, tokenIds_);
        } else {
            levelBoosts = new uint256[](tokenIds_.length);
        }

        for (uint256 i = 0; i <  tokenIds_.length; ++i) {
            require(isOwner(msg.sender, collection_, tokenIds_[i]));
            amount += _getYield(collection_, tokenIds_[i], levelBoosts[i], true);
        }

        IToken(contractsAddressesMap["token"]).add(msg.sender, amount);

        delete levelBoosts;

        return amount;
    }


    function claimYieldForAll() external whenNotPaused {

        uint256 totalYield;
        for (uint256 i = 0; i < collections.length; ++i) {
            if (stakedTokensByWallet[msg.sender][collections[i]].length > 0) {

                uint256[] memory levelBoosts;

                if(collectionsSettings[collections[i]].hasLevel) {
                    levelBoosts = IGameStats(contractsAddressesMap["gameStats"]).getLevelBoosts(collections[i], stakedTokensByWallet[msg.sender][collections[i]]);
                } else {
                    levelBoosts = new uint256[](stakedTokensByWallet[msg.sender][collections[i]].length);
                }

                for (uint256 j = 0; j < stakedTokensByWallet[msg.sender][collections[i]].length; ++j) {
                    totalYield += _getYield(
                        collections[i],
                        stakedTokensByWallet[msg.sender][collections[i]][j],
                        levelBoosts[j],
                        true
                    );
                }
            }
        }

        IToken(contractsAddressesMap["token"]).add(msg.sender, totalYield);

        delete totalYield;
    }

    function calculateYieldSafe(address collection_, uint256[] memory tokenIds_) public view returns(uint256) {

        uint256 totalYield;
        for (uint256 i = 0; i < tokenIds_.length; ++i) {
            totalYield += _getYieldSafe(collection_, tokenIds_[i]);
        }

        return totalYield;
    }

    function calculateYieldForAll(address wallet_) external view returns(uint256) {

        uint256 totalYield;

        for (uint256 i = 0; i < collections.length; ++i) {
            if (stakedTokensByWallet[wallet_][collections[i]].length > 0) {
               totalYield += calculateYieldSafe(collections[i], stakedTokensByWallet[wallet_][collections[i]]);
            }
        }

        return totalYield;
    }

    function _getYieldSafe(
        address collection_,
        uint256 tokenId_
    ) internal view returns (uint256) {

        uint256 yield = collectionsSettings[collection_].baseYieldRate *
        (block.timestamp - stakedTokensData[collection_][tokenId_].claimDate) / 1 days;

        if (stakedTokensData[collection_][tokenId_].stakeType == stakeTypesVariables["training"]) {
            yield = yield / 2;
        }

        if (collectionsSettings[collection_].hasLevel) {
            yield += yield * IGameStats(contractsAddressesMap["gameStats"]).getLevelBoost(collection_, tokenId_) / 100;
        }

        if (stakedTokensData[collection_][tokenId_].stakeType == stakeTypesVariables["treeHouse"]) {

            HouseEnrol[] storage houseEnrols = treeHousesEnrolments[stakedTokensData[collection_][tokenId_].houseTokenId][collection_];

            uint256 foundIndex;
            uint256 i;
            for (; i < houseEnrols.length; ++i) {
                if (houseEnrols[i].tokenId == tokenId_) {
                    foundIndex = i;
                    break;
                }
            }

            require(i != houseEnrols.length, "NOT OWNED");

            yield +=
            (block.timestamp - houseEnrols[foundIndex].enrolDate) *
            collectionsSettings[collection_].baseYieldRate *
            treeHouseBoost /
            100 days;
        }

        return yield;
    }

    function getStakedTokens(address wallet_, address collection_) external view returns (StakedTokens[] memory) {

        StakedTokens[] memory stakedTokens = new StakedTokens[](stakedTokensByWallet[wallet_][collection_].length);

        for (uint256 i = 0; i < stakedTokensByWallet[wallet_][collection_].length; ++i) {
            stakedTokens[i].tokenId = stakedTokensByWallet[wallet_][collection_][i];
            stakedTokens[i].stakeType = stakedTokensData[collection_][stakedTokensByWallet[wallet_][collection_][i]].stakeType;
            stakedTokens[i].claimDate = stakedTokensData[collection_][stakedTokensByWallet[wallet_][collection_][i]].claimDate;
            stakedTokens[i].houseTokenId = stakedTokensData[collection_][stakedTokensByWallet[wallet_][collection_][i]].houseTokenId;
        }

        return stakedTokens;
    }

}