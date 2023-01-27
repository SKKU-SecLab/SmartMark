

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
}

pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

pragma solidity ^0.8.0;

interface LinkTokenInterface {

    function allowance(address owner, address spender) external view returns (uint256 remaining);


    function approve(address spender, uint256 value) external returns (bool success);


    function balanceOf(address owner) external view returns (uint256 balance);


    function decimals() external view returns (uint8 decimalPlaces);


    function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);


    function increaseApproval(address spender, uint256 subtractedValue) external;


    function name() external view returns (string memory tokenName);


    function symbol() external view returns (string memory tokenSymbol);


    function totalSupply() external view returns (uint256 totalTokensIssued);


    function transfer(address to, uint256 value) external returns (bool success);


    function transferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool success);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool success);

}

pragma solidity ^0.8.0;

contract VRFRequestIDBase {

    function makeVRFInputSeed(
        bytes32 _keyHash,
        uint256 _userSeed,
        address _requester,
        uint256 _nonce
    ) internal pure returns (uint256) {

        return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
    }

    function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
    }
}

pragma solidity ^0.8.0;

abstract contract VRFConsumerBase is VRFRequestIDBase {
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;

    uint256 private constant USER_SEED_PLACEHOLDER = 0;

    function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {
        LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
        uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
        nonces[_keyHash] = nonces[_keyHash] + 1;
        return makeRequestId(_keyHash, vRFSeed);
    }

    LinkTokenInterface internal immutable LINK;
    address private immutable vrfCoordinator;

    mapping(bytes32 => uint256) /* keyHash */ /* nonce */
    private nonces;

    constructor(address _vrfCoordinator, address _link) {
        vrfCoordinator = _vrfCoordinator;
        LINK = LinkTokenInterface(_link);
    }

    function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
        require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
        fulfillRandomness(requestId, randomness);
    }
}

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
}

interface IToken {

    function add(address wallet, uint256 amount) external;

    function spend(address wallet, uint256 amount) external;

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mintTokens(address to, uint256 amount) external;

    function getWalletBalance(address wallet) external returns (uint256);

}

interface IStakingContract {

    function ownerOf(address collection, uint256 token) external returns (address);

}

pragma solidity ^0.8.0;

contract GameStats is Ownable, VRFConsumerBase, Pausable {

    using EnumerableSet for EnumerableSet.Bytes32Set;

    struct TokenSelection {
        address collectionAddress;
        uint256[] tokens;
    }

    struct ImpactType {
        uint256 boost;
        uint256 riskReduction;
    }

    struct TokenData {
        bool isElite;
        bool faction;
        uint256 level;
        uint256 levelEnrolDate;
        uint256 stakeType;
        address owner;
    }

    mapping(bytes32 => TokenData) tokenDataEncoded;
    EnumerableSet.Bytes32Set redElites;
    EnumerableSet.Bytes32Set blueElites;

    uint256 houseUpgradeCost = 1000000000 ether;

    uint256 public treeHouseRisk = 25;
    uint256 public tokenGeneratorRisk = 25;

    uint256 public HOUSE_CAP = 5;
    uint256 public LEVEL_CAP = 1000;
    uint256 public BASE_RISK = 50;
    uint256 public HOME_STAKE = 1;
    uint256 public TREE_HOUSE_STAKE = 2;

    mapping(string => address) public contractsAddressesMap;

    uint256[] public levelMilestones;
    mapping(uint256 => ImpactType) public levelImpacts;

    mapping(uint256 => ImpactType) public stakeTypeImpacts;

    uint256 private vrfFee;
    bytes32 private vrfKeyHash;

    uint256 private seed;


    mapping(address => bool) public authorisedAddresses;

    modifier authorised() {

        require(authorisedAddresses[msg.sender], "The token contract is not authorised");
        _;
    }

    event SeedFulfilled();

    event BLDStolen(address to, uint256 amount);

    constructor(
        address vrfCoordinatorAddr_,
        address linkTokenAddr_,
        bytes32 vrfKeyHash_,
        uint256 fee_
    ) VRFConsumerBase(vrfCoordinatorAddr_, linkTokenAddr_) {
        vrfKeyHash = vrfKeyHash_;
        vrfFee = fee_;
    }

    function setCollectionsKeys(
        string[] calldata keys_,
        address[] calldata collections_
    ) external onlyOwner {

        for (uint i = 0; i < keys_.length; ++i) {
            contractsAddressesMap[keys_[i]] = collections_[i];
        }
    }

    function setLevelImpacts(uint256[] memory milestones_, ImpactType[] calldata impacts_) external onlyOwner {


        require(milestones_.length == impacts_.length, "INVALID LENGTH");

        levelMilestones = milestones_;

        for (uint256 i = 0; i < milestones_.length; i++) {
            ImpactType storage levelImpact = levelImpacts[milestones_[i]];
            levelImpact.boost = impacts_[i].boost;
            levelImpact.riskReduction = impacts_[i].riskReduction;
        }
    }

    function setStakeTypeImpacts(uint256[] calldata stakeTypes_, ImpactType[] calldata impacts_) external onlyOwner {


        require(stakeTypes_.length == impacts_.length, "INVALID LENGTH");

        for (uint256 i = 0; i < stakeTypes_.length; i++) {
            ImpactType storage levelImpact = stakeTypeImpacts[stakeTypes_[i]];
            levelImpact.boost = impacts_[i].boost;
            levelImpact.riskReduction = impacts_[i].riskReduction;
        }
    }

    function setAuthorised(address[] calldata addresses_, bool[] calldata authorisations_) external onlyOwner {

        for (uint256 i = 0; i < addresses_.length; ++i) {
            authorisedAddresses[addresses_[i]] = authorisations_[i];
        }
    }

    function setHouseUpgradeCost(uint256 houseUpgradeCost_) external onlyOwner {

        houseUpgradeCost = houseUpgradeCost_;
    }

    function setTokensData(
        address collection_,
        uint256[] calldata tokenIds_,
        uint256[] calldata levels_,
        bool[] calldata factions_,
        bool[] calldata elites_
    ) external authorised {


        for (uint256 i = 0; i < tokenIds_.length; i++) {
            bytes32 tokenKey = getTokenKey(collection_, tokenIds_[i]);
            TokenData storage tokenData = tokenDataEncoded[tokenKey];
            if (tokenData.level == 0) {
                tokenData.faction = factions_[i];
                tokenData.isElite = elites_[i];
                tokenData.level = levels_[i];
            }
        }
    }

    function setStakedTokenData(
        address collection_,
        address owner_,
        uint256 stakeType_,
        uint256[] calldata tokenIds_
    ) external authorised {

        for (uint256 i = 0; i < tokenIds_.length; i++) {
            bytes32 tokenKey = getTokenKey(collection_, tokenIds_[i]);
            TokenData storage tokenData = tokenDataEncoded[tokenKey];

            tokenData.owner = owner_;

            if (tokenData.isElite) {
                if (tokenData.faction) {
                    blueElites.add(tokenKey);
                } else {
                    redElites.add(tokenKey);
                }
            }

            tokenData.stakeType = stakeType_;
            tokenData.levelEnrolDate = block.timestamp;
        }
    }

    function unsetStakedTokenData(
        address collection_,
        uint256[] calldata tokenIds_
    ) external authorised {


        for (uint256 i = 0; i < tokenIds_.length; i++) {

            bytes32 tokenKey = getTokenKey(collection_, tokenIds_[i]);
            TokenData storage tokenData = tokenDataEncoded[tokenKey];

            if (tokenData.isElite) {
                if (tokenData.faction) {
                    blueElites.remove(tokenKey);
                } else {
                    redElites.remove(tokenKey);
                }
            }

            _claimLevelForToken(collection_, tokenIds_[i]);

            tokenData.stakeType = 0;

        }
    }


    function getTokenKey(address collection_, uint256 tokenId_) public pure returns (bytes32) {

        return keccak256(abi.encode(collection_, tokenId_));
    }

    function getLevel(address collection_, uint256 tokenId_) public view returns (uint256) {

        return tokenDataEncoded[getTokenKey(collection_, tokenId_)].level;
    }

    function getLevels(
        address collection_,
        uint256[] calldata tokenIds_
    ) external view returns (uint256[] memory) {

        uint256[] memory levels = new uint256[](tokenIds_.length);

        for (uint256 i = 0; i < tokenIds_.length; ++i) {
            levels[i] = getLevel(collection_, tokenIds_[i]);
        }

        return levels;
    }

    function getLevelBoosts(
        address collection_,
        uint256[] calldata tokenIds_
    ) external view returns (uint256[] memory) {

        uint256[] memory levelBoosts = new uint256[](tokenIds_.length);

        for (uint256 i = 0; i < tokenIds_.length; ++i) {
            bytes32 tokenKey = getTokenKey(collection_, tokenIds_[i]);
            for (uint256 j = levelMilestones.length - 1; j >= 0; --j) {
                if (tokenDataEncoded[tokenKey].level >= levelMilestones[j]) {
                    levelBoosts[i] = levelImpacts[levelMilestones[j]].boost;
                    break;
                }
            }
        }
        return levelBoosts;
    }

    function getLevelBoost(address collection, uint256 tokenId) external view returns (uint256) {

        uint256 levelBoost;
        bytes32 tokenKey = getTokenKey(collection, tokenId);
        for (uint256 j = levelMilestones.length - 1; j >= 0; --j) {
            if (tokenDataEncoded[tokenKey].level >= levelMilestones[j]) {
                levelBoost = levelImpacts[levelMilestones[j]].boost;
                break;
            }
        }

        return levelBoost;
    }

    function claimLevel(TokenSelection[] calldata tokensSelection_) public {

        for (uint256 i = 0; i < tokensSelection_.length; ++i) {
            for (uint256 j = 0; j < tokensSelection_[i].tokens.length; ++j) {
                bytes32 tokenKey = getTokenKey(
                    tokensSelection_[i].collectionAddress,
                    tokensSelection_[i].tokens[j]
                );

                require(tokenDataEncoded[tokenKey].owner == msg.sender);
                _claimLevelForToken(tokensSelection_[i].collectionAddress, tokensSelection_[i].tokens[j]);
            }
        }
    }

    function _claimLevelForToken(address collection_, uint256 tokenId_) internal {


        bytes32 tokenKey = getTokenKey(collection_, tokenId_);
        if (
            tokenDataEncoded[tokenKey].stakeType == TREE_HOUSE_STAKE ||
            tokenDataEncoded[tokenKey].stakeType == HOME_STAKE ||
            tokenDataEncoded[tokenKey].stakeType == 0
        ) {
            return;
        }

        if (
            collection_ != contractsAddressesMap["gen0"] &&
            collection_ != contractsAddressesMap["gen1"]
        ) {
            return;
        }


        if (tokenDataEncoded[tokenKey].level != LEVEL_CAP) {

            uint256 levelYield = (block.timestamp - tokenDataEncoded[tokenKey].levelEnrolDate) /
                (stakeTypeImpacts[tokenDataEncoded[tokenKey].stakeType].boost * 1 days);


            if (tokenDataEncoded[tokenKey].level + levelYield > LEVEL_CAP) {
                tokenDataEncoded[tokenKey].level = LEVEL_CAP;
            } else {
                tokenDataEncoded[tokenKey].level += levelYield;
            }

            delete levelYield;

            tokenDataEncoded[tokenKey].levelEnrolDate = block.timestamp;
        }

        delete tokenKey;
    }

    function isClaimSuccessful(
        address collection_,
        uint256 tokenId,
        uint256 amount_,
        uint256 stakeType_
    ) external returns (bool) {


        uint256 risk;

        bool isBearCollection =
            collection_ == contractsAddressesMap["gen0"]
            || collection_ == contractsAddressesMap["gen1"];

        if (isBearCollection) {
            risk = BASE_RISK * 100;

            for (uint256 j = levelMilestones.length - 1; j >= 0; --j) {
                if (tokenDataEncoded[getTokenKey(collection_, tokenId)].level >= levelMilestones[j]) {
                    risk -= levelImpacts[levelMilestones[j]].riskReduction;
                    break;
                }
            }

            risk = risk / stakeTypeImpacts[stakeType_].riskReduction / 100;

            risk = risk < 10 ? 10 : risk;
        } else {
            if (collection_ == contractsAddressesMap["tokenGenerator"]) {
                risk = tokenGeneratorRisk;
            } else if (collection_ == contractsAddressesMap["treeHouse"]) {
                risk = treeHouseRisk;
            }
        }

        bool didLose = _didLoseClaimAmount(risk, tokenId, amount_);
        if (didLose) {
            bool winningFaction;
            if (isBearCollection) {
                winningFaction = !tokenDataEncoded[getTokenKey(collection_, tokenId)].faction;
            } else {
                winningFaction = _getFaction(tokenId);
            }

            address winner = pickWinnerFromElites(
                winningFaction,
                tokenId
            );

            if (winner != address(0)) {
                emit BLDStolen(winner, amount_);
                IToken(contractsAddressesMap["token"]).add(winner, amount_);
            } else {
                didLose = false;
            }
        }

        delete isBearCollection;

        return !didLose;
    }

    function _didLoseClaimAmount(uint256 risk_, uint256 tokenId_, uint256 amount_) internal view returns (bool) {

        return uint256(
            keccak256(
                abi.encodePacked(
                    seed,
                    tokenId_,
                    amount_,
                    tx.origin,
                    blockhash(block.number - 1),
                    block.timestamp)
            )
        ) % 100 < risk_;
    }

    function pickWinnerFromElites(bool faction_, uint256 tokenId) public view returns (address) {

        if (faction_) {
            return _pickWinnerFromElitesBySide(blueElites, tokenId);
        } else {
            return _pickWinnerFromElitesBySide(redElites, tokenId);
        }
    }

    function _pickWinnerFromElitesBySide(
        EnumerableSet.Bytes32Set storage elites_,
        uint256 tokenId
    ) internal view returns (address) {


        if(elites_.length() == 0) {
            return address(0);
        }

        uint256 index = _getRandom(elites_.length(), tokenId);

        return tokenDataEncoded[elites_.at(index)].owner;
    }

    function _getRandom(uint256 len, uint256 tokenId) internal view returns (uint256) {

        return uint256(
            keccak256(
                abi.encodePacked(
                    seed,
                    tokenId,
                    tx.origin,
                    blockhash(block.number - 1),
                    block.timestamp
                )
            )
        ) % len;
    }

    function _getFaction(uint256 tokenId) internal view returns (bool) {

        return uint256(
            keccak256(
                abi.encodePacked(
                    seed,
                    tokenId,
                    tx.origin,
                    blockhash(block.number - 1),
                    block.timestamp
                )
            )
        ) & 1 == 1;
    }

    function initSeedGeneration() public onlyOwner returns (bytes32 requestId) {

        require(LINK.balanceOf(address(this)) >= vrfFee, "Not enough LINK");
        return requestRandomness(vrfKeyHash, vrfFee);
    }

    function fulfillRandomness(bytes32, uint256 randomness) internal override {

        seed = randomness;
        emit SeedFulfilled();
    }

    function upgradeHouseSize(uint256 tokenId_, uint256 upgrade_) external {


        require(tokenDataEncoded[getTokenKey(contractsAddressesMap["treeHouse"], tokenId_)].level + upgrade_ <= HOUSE_CAP);
        require(tokenDataEncoded[getTokenKey(contractsAddressesMap["treeHouse"], tokenId_)].owner == msg.sender);
        require(IToken(contractsAddressesMap["token"]).getWalletBalance(msg.sender) >= houseUpgradeCost * upgrade_);

        IToken(contractsAddressesMap["token"]).spend(msg.sender, houseUpgradeCost * upgrade_);

        tokenDataEncoded[getTokenKey(contractsAddressesMap["treeHouse"], tokenId_)].level += upgrade_;
    }

    function addLevel(address collection_, uint256 tokenId_, uint256 levelIncrease_) external authorised {

        tokenDataEncoded[getTokenKey(collection_, tokenId_)].level += levelIncrease_;
    }

    function setLevel(address collection_, uint256 tokenId_, uint256 levelIncrease_) external authorised {

        tokenDataEncoded[getTokenKey(collection_, tokenId_)].level = levelIncrease_;
    }

    function setEliteStatus(address collection_, uint256 tokenId_) external authorised {


        bytes32 tokenKey = getTokenKey(collection_, tokenId_);

        require(!tokenDataEncoded[tokenKey].isElite);
        require(tokenDataEncoded[tokenKey].stakeType == 0);

        tokenDataEncoded[tokenKey].isElite = true;

        delete tokenKey;
    }

    function setHousesLevels(uint256[] calldata tokenIds_, uint256[] calldata levels_) external authorised {

        for (uint256 i = 0; i < tokenIds_.length; ++i) {
            tokenDataEncoded[getTokenKey(contractsAddressesMap["treeHouse"], tokenIds_[i])].level = levels_[i];
        }
    }

    function calculateLevels(
        address collection,
        uint256[] calldata tokenIds_
    ) external view returns (uint256[] memory) {

        uint256[] memory expectedLevels = new uint256[](tokenIds_.length);

        for (uint256 i = 0; i < tokenIds_.length; ++i) {
            expectedLevels[i] = calculateLevel(collection, tokenIds_[i]);
        }

        return expectedLevels;
    }

    function calculateLevel(address collection_, uint256 tokenId_) public view returns (uint256) {


        bytes32 tokenKey = getTokenKey(collection_, tokenId_);

        if (
            tokenDataEncoded[tokenKey].stakeType == TREE_HOUSE_STAKE ||
            tokenDataEncoded[tokenKey].stakeType == HOME_STAKE ||
            tokenDataEncoded[tokenKey].stakeType == 0
        ) {
            return tokenDataEncoded[tokenKey].level;
        }

        if (
            collection_ != contractsAddressesMap["gen0"] &&
            collection_ != contractsAddressesMap["gen1"]
        ) {
            return tokenDataEncoded[tokenKey].level;
        }

        if (tokenDataEncoded[tokenKey].level == LEVEL_CAP) {
            return LEVEL_CAP;
        }

        uint256 levelYield = (block.timestamp - tokenDataEncoded[tokenKey].levelEnrolDate) /

        (stakeTypeImpacts[tokenDataEncoded[tokenKey].stakeType].boost * 1 days);


        if (tokenDataEncoded[tokenKey].level + levelYield > LEVEL_CAP) {
            return LEVEL_CAP;
        }

        return tokenDataEncoded[tokenKey].level + levelYield;
    }

    function setTokenGeneratorRisk(uint256 risk_) external onlyOwner {

        tokenGeneratorRisk = risk_;
    }

    function setTreeHouseRisk(uint256 risk_) external onlyOwner {

        treeHouseRisk = risk_;
    }

}