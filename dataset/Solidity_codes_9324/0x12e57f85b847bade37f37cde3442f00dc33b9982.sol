
pragma solidity =0.7.6;
pragma experimental ABIEncoderV2;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function add(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction underflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function mul(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library LibGovStorage {

    struct Voted {
        uint96 votes;
        bool support;
    }

    struct Proposal {
        mapping(address => Voted) voted;
        address proposalContract;
        address proposer;
        uint64 endTime;
        bool executed;
        bool stuck;
        uint96 againstVotes;
        uint96 forVotes;
    }


    struct GovernanceStorage {
        mapping(address => uint96) balances;
        mapping(address => mapping(address => uint96)) approved;
        uint96 totalSupplyCap;
        uint96 totalSupply;
        address loveMinter;
        address loveBoat;
        uint256 mintingAllowedAfter;
        mapping(uint256 => Proposal) proposals;
        mapping(address => uint24[]) votedProposalIds;
        uint24 proposalCount;
        uint8 proposalThresholdDivisor;
        uint16 minimumVotingTime;
        uint16 maximumVotingTime;
        uint8 quorumDivisor;
        uint8 proposerAwardDivisor;
        uint8 voterAwardDivisor;
        uint8 voteAwardCapDivisor;
    }

    function governanceStorage() internal pure returns (GovernanceStorage storage ds) {

        bytes32 position = keccak256("governance.token.diamond.governance");
        assembly {
            ds.slot := position
        }
    }
}

library LibDiamond {

    bytes32 internal constant DIAMOND_STORAGE_POSITION = keccak256("diamond.standard.diamond.storage");

    struct DiamondStorage {
        mapping(bytes4 => bytes32) facets;
        mapping(uint256 => bytes32) selectorSlots;
        uint16 selectorCount;
        mapping(bytes4 => bool) supportedInterfaces;
        address contractOwner;
    }

    function diamondStorage() internal pure returns (DiamondStorage storage ds) {

        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setContractOwner(address _newOwner) internal {

        DiamondStorage storage ds = diamondStorage();
        address previousOwner = ds.contractOwner;
        ds.contractOwner = _newOwner;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }

    function contractOwner() internal view returns (address contractOwner_) {

        contractOwner_ = diamondStorage().contractOwner;
    }

    function enforceIsContractOwner() internal view {

        require(msg.sender == diamondStorage().contractOwner, "LibDiamond: Must be contract owner");
    }

    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    bytes32 internal constant CLEAR_ADDRESS_MASK = bytes32(uint256(0xffffffffffffffffffffffff));
    bytes32 internal constant CLEAR_SELECTOR_MASK = bytes32(uint256(0xffffffff << 224));

    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {

        DiamondStorage storage ds = diamondStorage();
        uint256 originalSelectorCount = ds.selectorCount;
        uint256 selectorCount = originalSelectorCount;
        bytes32 selectorSlot;
        if (selectorCount & 7 > 0) {
            selectorSlot = ds.selectorSlots[selectorCount >> 3];
        }
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            (selectorCount, selectorSlot) = addReplaceRemoveFacetSelectors(
                selectorCount,
                selectorSlot,
                _diamondCut[facetIndex].facetAddress,
                _diamondCut[facetIndex].action,
                _diamondCut[facetIndex].functionSelectors
            );
        }
        if (selectorCount != originalSelectorCount) {
            ds.selectorCount = uint16(selectorCount);
        }
        if (selectorCount & 7 > 0) {
            ds.selectorSlots[selectorCount >> 3] = selectorSlot;
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        initializeDiamondCut(_init, _calldata);
    }

    function addReplaceRemoveFacetSelectors(
        uint256 _selectorCount,
        bytes32 _selectorSlot,
        address _newFacetAddress,
        IDiamondCut.FacetCutAction _action,
        bytes4[] memory _selectors
    ) internal returns (uint256, bytes32) {

        DiamondStorage storage ds = diamondStorage();
        require(_selectors.length > 0, "LibDiamondCut: No selectors in facet to cut");
        if (_action == IDiamondCut.FacetCutAction.Add) {
            enforceHasContractCode(_newFacetAddress, "LibDiamondCut: Add facet has no code");
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                bytes4 selector = _selectors[selectorIndex];
                bytes32 oldFacet = ds.facets[selector];
                require(address(bytes20(oldFacet)) == address(0), "LibDiamondCut: Can't add function that already exists");
                ds.facets[selector] = bytes20(_newFacetAddress) | bytes32(_selectorCount);
                uint256 selectorInSlotPosition = (_selectorCount & 7) << 5;
                _selectorSlot =
                    (_selectorSlot & ~(CLEAR_SELECTOR_MASK >> selectorInSlotPosition)) |
                    (bytes32(selector) >> selectorInSlotPosition);
                if (selectorInSlotPosition == 224) {
                    ds.selectorSlots[_selectorCount >> 3] = _selectorSlot;
                    _selectorSlot = 0;
                }
                _selectorCount++;
            }
        } else if (_action == IDiamondCut.FacetCutAction.Replace) {
            enforceHasContractCode(_newFacetAddress, "LibDiamondCut: Replace facet has no code");
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                bytes4 selector = _selectors[selectorIndex];
                bytes32 oldFacet = ds.facets[selector];
                address oldFacetAddress = address(bytes20(oldFacet));
                require(oldFacetAddress != address(this), "LibDiamondCut: Can't replace immutable function");
                require(oldFacetAddress != _newFacetAddress, "LibDiamondCut: Can't replace function with same function");
                require(oldFacetAddress != address(0), "LibDiamondCut: Can't replace function that doesn't exist");
                ds.facets[selector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(_newFacetAddress);
            }
        } else if (_action == IDiamondCut.FacetCutAction.Remove) {
            require(_newFacetAddress == address(0), "LibDiamondCut: Remove facet address must be address(0)");
            uint256 selectorSlotCount = _selectorCount >> 3;
            uint256 selectorInSlotIndex = _selectorCount & 7;
            for (uint256 selectorIndex; selectorIndex < _selectors.length; selectorIndex++) {
                if (_selectorSlot == 0) {
                    selectorSlotCount--;
                    _selectorSlot = ds.selectorSlots[selectorSlotCount];
                    selectorInSlotIndex = 7;
                } else {
                    selectorInSlotIndex--;
                }
                bytes4 lastSelector;
                uint256 oldSelectorsSlotCount;
                uint256 oldSelectorInSlotPosition;
                {
                    bytes4 selector = _selectors[selectorIndex];
                    bytes32 oldFacet = ds.facets[selector];
                    require(address(bytes20(oldFacet)) != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
                    require(address(bytes20(oldFacet)) != address(this), "LibDiamondCut: Can't remove immutable function");
                    lastSelector = bytes4(_selectorSlot << (selectorInSlotIndex << 5));
                    if (lastSelector != selector) {
                        ds.facets[lastSelector] = (oldFacet & CLEAR_ADDRESS_MASK) | bytes20(ds.facets[lastSelector]);
                    }
                    delete ds.facets[selector];
                    uint256 oldSelectorCount = uint16(uint256(oldFacet));
                    oldSelectorsSlotCount = oldSelectorCount >> 3;
                    oldSelectorInSlotPosition = (oldSelectorCount & 7) << 5;
                }
                if (oldSelectorsSlotCount != selectorSlotCount) {
                    bytes32 oldSelectorSlot = ds.selectorSlots[oldSelectorsSlotCount];
                    oldSelectorSlot =
                        (oldSelectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                    ds.selectorSlots[oldSelectorsSlotCount] = oldSelectorSlot;
                } else {
                    _selectorSlot =
                        (_selectorSlot & ~(CLEAR_SELECTOR_MASK >> oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                }
                if (selectorInSlotIndex == 0) {
                    delete ds.selectorSlots[selectorSlotCount];
                    _selectorSlot = 0;
                }
            }
            _selectorCount = selectorSlotCount * 8 + selectorInSlotIndex;
        } else {
            revert("LibDiamondCut: Incorrect FacetCutAction");
        }
        return (_selectorCount, _selectorSlot);
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {

        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but_calldata is not empty");
        } else {
            require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
            if (_init != address(this)) {
                enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
            }
            (bool success, bytes memory error) = _init.delegatecall(_calldata);
            if (!success) {
                if (error.length > 0) {
                    revert(string(error));
                } else {
                    revert("LibDiamondCut: _init function reverted");
                }
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {

        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}

interface IDiamondLoupe {


    struct Facet {
        address facetAddress;
        bytes4[] functionSelectors;
    }

    function facets() external view returns (Facet[] memory facets_);


    function facetFunctionSelectors(address _facet) external view returns (bytes4[] memory facetFunctionSelectors_);


    function facetAddresses() external view returns (address[] memory facetAddresses_);


    function facetAddress(bytes4 _functionSelector) external view returns (address facetAddress_);

}

interface IERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}

interface IDiamondCut {

    enum FacetCutAction {Add, Replace, Remove}

    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;


    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}

contract DiamondCutFacet is IDiamondCut {

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {

        LibDiamond.enforceIsContractOwner();
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 originalSelectorCount = ds.selectorCount;
        uint256 selectorCount = originalSelectorCount;
        bytes32 selectorSlot;
        if (selectorCount & 7 > 0) {
            selectorSlot = ds.selectorSlots[selectorCount >> 3];
        }
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            (selectorCount, selectorSlot) = LibDiamond.addReplaceRemoveFacetSelectors(
                selectorCount,
                selectorSlot,
                _diamondCut[facetIndex].facetAddress,
                _diamondCut[facetIndex].action,
                _diamondCut[facetIndex].functionSelectors
            );
        }
        if (selectorCount != originalSelectorCount) {
            ds.selectorCount = uint16(selectorCount);
        }
        if (selectorCount & 7 > 0) {
            ds.selectorSlots[selectorCount >> 3] = selectorSlot;
        }
        emit DiamondCut(_diamondCut, _init, _calldata);
        LibDiamond.initializeDiamondCut(_init, _calldata);
    }
}

contract DiamondLoupe is IDiamondLoupe, IERC165 {


    function facets() external view override returns (Facet[] memory facets_) {

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        facets_ = new Facet[](ds.selectorCount);
        uint8[] memory numFacetSelectors = new uint8[](ds.selectorCount);
        uint256 numFacets;
        uint256 selectorIndex;
        for (uint256 slotIndex; selectorIndex < ds.selectorCount; slotIndex++) {
            bytes32 slot = ds.selectorSlots[slotIndex];
            for (uint256 selectorSlotIndex; selectorSlotIndex < 8; selectorSlotIndex++) {
                selectorIndex++;
                if (selectorIndex > ds.selectorCount) {
                    break;
                }
                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));
                address facetAddress_ = address(bytes20(ds.facets[selector]));
                bool continueLoop = false;
                for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
                    if (facets_[facetIndex].facetAddress == facetAddress_) {
                        facets_[facetIndex].functionSelectors[numFacetSelectors[facetIndex]] = selector;
                        require(numFacetSelectors[facetIndex] < 255);
                        numFacetSelectors[facetIndex]++;
                        continueLoop = true;
                        break;
                    }
                }
                if (continueLoop) {
                    continueLoop = false;
                    continue;
                }
                facets_[numFacets].facetAddress = facetAddress_;
                facets_[numFacets].functionSelectors = new bytes4[](ds.selectorCount);
                facets_[numFacets].functionSelectors[0] = selector;
                numFacetSelectors[numFacets] = 1;
                numFacets++;
            }
        }
        for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
            uint256 numSelectors = numFacetSelectors[facetIndex];
            bytes4[] memory selectors = facets_[facetIndex].functionSelectors;
            assembly {
                mstore(selectors, numSelectors)
            }
        }
        assembly {
            mstore(facets_, numFacets)
        }
    }

    function facetFunctionSelectors(address _facet) external view override returns (bytes4[] memory _facetFunctionSelectors) {

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        uint256 numSelectors;
        _facetFunctionSelectors = new bytes4[](ds.selectorCount);
        uint256 selectorIndex;
        for (uint256 slotIndex; selectorIndex < ds.selectorCount; slotIndex++) {
            bytes32 slot = ds.selectorSlots[slotIndex];
            for (uint256 selectorSlotIndex; selectorSlotIndex < 8; selectorSlotIndex++) {
                selectorIndex++;
                if (selectorIndex > ds.selectorCount) {
                    break;
                }
                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));
                address facet = address(bytes20(ds.facets[selector]));
                if (_facet == facet) {
                    _facetFunctionSelectors[numSelectors] = selector;
                    numSelectors++;
                }
            }
        }
        assembly {
            mstore(_facetFunctionSelectors, numSelectors)
        }
    }

    function facetAddresses() external view override returns (address[] memory facetAddresses_) {

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        facetAddresses_ = new address[](ds.selectorCount);
        uint256 numFacets;
        uint256 selectorIndex;
        for (uint256 slotIndex; selectorIndex < ds.selectorCount; slotIndex++) {
            bytes32 slot = ds.selectorSlots[slotIndex];
            for (uint256 selectorSlotIndex; selectorSlotIndex < 8; selectorSlotIndex++) {
                selectorIndex++;
                if (selectorIndex > ds.selectorCount) {
                    break;
                }
                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));
                address facetAddress_ = address(bytes20(ds.facets[selector]));
                bool continueLoop = false;
                for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
                    if (facetAddress_ == facetAddresses_[facetIndex]) {
                        continueLoop = true;
                        break;
                    }
                }
                if (continueLoop) {
                    continueLoop = false;
                    continue;
                }
                facetAddresses_[numFacets] = facetAddress_;
                numFacets++;
            }
        }
        assembly {
            mstore(facetAddresses_, numFacets)
        }
    }

    function facetAddress(bytes4 _functionSelector) external view override returns (address facetAddress_) {

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        facetAddress_ = address(bytes20(ds.facets[_functionSelector]));
    }

    function supportsInterface(bytes4 _interfaceId) external view override returns (bool) {

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.supportedInterfaces[_interfaceId];
    }
}

contract LoveToken {

    function name() public pure returns (string memory) {

        return "Love";
    }

    function symbol() public pure returns (string memory) {

        return "LOVE";
    }

    function decimals() public pure returns (uint8) {

        return 18;
    }

    function totalSupply() external view returns (uint256) {

        return LibGovStorage.governanceStorage().totalSupply;
    }

    function balanceOf(address _account) external view returns (uint256) {

        return LibGovStorage.governanceStorage().balances[_account];
    }

    uint32 public constant minimumTimeBetweenMints = 1 days * 365;

    uint8 public constant mintCap = 2;

    event MinterChanged(address loveMinter, address newMinter);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function mintingAllowedAfter() public view returns (uint256) {

        return LibGovStorage.governanceStorage().mintingAllowedAfter;
    }

    function setMinter(address _loveMinter) external {

        require(msg.sender == LibGovStorage.governanceStorage().loveMinter, "Love:setMinter: only the minter can change the minter address");

        emit MinterChanged(LibGovStorage.governanceStorage().loveMinter, _loveMinter);
        LibGovStorage.governanceStorage().loveMinter = _loveMinter;
    }

    function mint(address _dst, uint256 _rawAmount) external {

        require(msg.sender == LibGovStorage.governanceStorage().loveMinter, "Love:mint: only the minter can mint");
        require(block.timestamp >= LibGovStorage.governanceStorage().mintingAllowedAfter, "Love:mint: minting not allowed yet");
        require(_dst != address(0), "Love:mint: cannot transfer to the zero address");

        LibGovStorage.governanceStorage().mintingAllowedAfter = SafeMath.add(block.timestamp, minimumTimeBetweenMints);

        uint96 amount = safe96(_rawAmount, "Love:mint: amount exceeds 96 bits");
        require(
            amount <= SafeMath.div(SafeMath.mul(LibGovStorage.governanceStorage().totalSupply, mintCap), 100),
            "Love:mint: exceeded mint cap"
        );
        LibGovStorage.governanceStorage().totalSupply = safe96(
            SafeMath.add(LibGovStorage.governanceStorage().totalSupply, amount),
            "Love:mint: totalSupply exceeds 96 bits"
        );

        LibGovStorage.governanceStorage().balances[_dst] = add96(
            LibGovStorage.governanceStorage().balances[_dst],
            amount,
            "Love:mint: transfer amount overflows"
        );
        emit Transfer(address(0), _dst, amount);
    }

    function transfer(address _to, uint256 _value) external returns (bool) {

        uint96 value = safe96(_value, "Love:transfer: value exceeds 96 bits");
        _transferFrom(msg.sender, _to, value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _rawValue
    ) external returns (bool) {

        address spender = msg.sender;
        uint96 spenderAllowance = LibGovStorage.governanceStorage().approved[_from][spender];
        uint96 value = safe96(_rawValue, "Love: value exceeds 96 bits");

        if (spender != _from && spenderAllowance != type(uint96).max) {
            uint96 newSpenderAllowance = sub96(spenderAllowance, value, "Love:transferFrom: value exceeds spenderAllowance");
            LibGovStorage.governanceStorage().approved[_from][spender] = newSpenderAllowance;
            emit Approval(_from, spender, newSpenderAllowance);
        }

        _transferFrom(_from, _to, value);
        return true;
    }

    function _transferFrom(
        address _from,
        address _to,
        uint96 _value
    ) internal {

        require(_from != address(0), "Love:_transferFrom: transfer from the zero address");
        require(_to != address(0), "Love:_transferFrom: transfer to the zero address");
        require(_value <= LibGovStorage.governanceStorage().balances[_from], "Love:_transferFrom: transfer amount exceeds balance");
        LibGovStorage.governanceStorage().balances[_from] = sub96(
            LibGovStorage.governanceStorage().balances[_from],
            _value,
            "Love:_transferFrom: value exceeds balance"
        );
        LibGovStorage.governanceStorage().balances[_to] = add96(
            LibGovStorage.governanceStorage().balances[_to],
            _value,
            "Love:_transferFrom: value overflows"
        );
        emit Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _rawValue) external returns (bool success) {

        uint96 value = safe96(_rawValue, "Love: value exceeds 96 bits");
        LibGovStorage.governanceStorage().approved[msg.sender][_spender] = value;
        emit Approval(msg.sender, _spender, value);
        success = true;
    }

    function safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe96(uint256 n, string memory errorMessage) internal pure returns (uint96) {

        require(n < 2**96, errorMessage);
        return uint96(n);
    }

    function add96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {

        uint96 c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub96(
        uint96 a,
        uint96 b,
        string memory errorMessage
    ) internal pure returns (uint96) {

        require(b <= a, errorMessage);
        return a - b;
    }
}

contract DiamondLove {

    event MinterChanged(address loveMinter, address newMinter);

    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor() {
        LibGovStorage.GovernanceStorage storage gs = LibGovStorage.governanceStorage();
        gs.totalSupplyCap = 100_000_000e18;
        gs.totalSupply = 1_000_000e18;
        gs.loveMinter = 0x287300059f50850d098b974AbE59106c4F52c989; // Initial address with the permission to mint Love tokens.
        emit MinterChanged(address(0), gs.loveMinter);
        gs.loveBoat = 0x287300059f50850d098b974AbE59106c4F52c989; // The address the token genesis minting will be sent to.

        gs.mintingAllowedAfter = block.timestamp + (1 days * 365);

        gs.balances[gs.loveBoat] = gs.totalSupply;
        emit Transfer(address(0), gs.loveBoat, gs.balances[gs.loveBoat]);

        LibDiamond.setContractOwner(0x287300059f50850d098b974AbE59106c4F52c989);

        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        DiamondLoupe diamondLoupe = new DiamondLoupe();
        LoveToken loveToken = new LoveToken();

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);

        bytes4[] memory funcSDiamondCut = new bytes4[](1);
        funcSDiamondCut[0] = DiamondCutFacet.diamondCut.selector;

        cut[0] = IDiamondCut.FacetCut(address(diamondCutFacet), IDiamondCut.FacetCutAction.Add, funcSDiamondCut);

        bytes4[] memory funcSDiamondLoupe = new bytes4[](5);
        funcSDiamondLoupe[0] = IDiamondLoupe.facetFunctionSelectors.selector;
        funcSDiamondLoupe[1] = IDiamondLoupe.facets.selector;
        funcSDiamondLoupe[2] = IDiamondLoupe.facetAddress.selector;
        funcSDiamondLoupe[3] = IDiamondLoupe.facetAddresses.selector;
        funcSDiamondLoupe[4] = IERC165.supportsInterface.selector;

        cut[1] = IDiamondCut.FacetCut(address(diamondLoupe), IDiamondCut.FacetCutAction.Add, funcSDiamondLoupe);

        bytes4[] memory funcSLoveToken = new bytes4[](11);
        funcSLoveToken[0] = LoveToken.name.selector;
        funcSLoveToken[1] = LoveToken.symbol.selector;
        funcSLoveToken[2] = LoveToken.decimals.selector;
        funcSLoveToken[3] = LoveToken.totalSupply.selector;
        funcSLoveToken[4] = LoveToken.balanceOf.selector;
        funcSLoveToken[5] = LoveToken.mintingAllowedAfter.selector;
        funcSLoveToken[6] = LoveToken.setMinter.selector;
        funcSLoveToken[7] = LoveToken.mint.selector;
        funcSLoveToken[8] = LoveToken.transfer.selector;
        funcSLoveToken[9] = LoveToken.transferFrom.selector;
        funcSLoveToken[10] = LoveToken.approve.selector;

        cut[2] = IDiamondCut.FacetCut(address(loveToken), IDiamondCut.FacetCutAction.Add, funcSLoveToken);

        LibDiamond.diamondCut(cut, address(0), new bytes(0));

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
    }

    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
        address facet = address(bytes20(ds.facets[msg.sig]));
        require(facet != address(0), "DiamondLove: Function does not exist");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    receive() external payable {}
}