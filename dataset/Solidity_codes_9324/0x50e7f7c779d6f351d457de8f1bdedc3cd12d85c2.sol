
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

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}//MIT
pragma solidity 0.8.14;

contract BrightBundles is Ownable, ReentrancyGuard
{


    struct Bundle
    {
        string Name; 
        uint PriceBrightList; 
        uint PricePublic; 
        uint[] StartingIndexes; 
        uint[] EndingIndexes; 
        uint PurchaseableAmount; 
        uint PurchaseableAmountBrightList; 
        uint PurchaseableAmountPublic; 
        address[] ContractAddresses; 
        address Operator; 
        bytes32 Root; 
        bool ActivePublic; 
        bool ActiveBrightList; 
        bool AllowMultiplePurchases; 
    }


    mapping(uint => Bundle) public Bundles;
    mapping(uint => uint) public BundleProceeds;
    mapping(address => bytes32) public BRTOperators;
    mapping(uint => mapping(address => bool)) public BundlePurchased;
    mapping(uint => mapping(address => uint)) public PurchasedAmountBrightList;
    mapping(uint => mapping(address => uint)) public PurchasedAmountPublic;


    event BundlePurchaseEventBrightList(
        address indexed recipientAddress, 
        uint indexed BundleIndex, 
        uint amount
    );

    event BundlePurchaseEvent(
        address indexed recipientAddress, 
        uint indexed BundleIndex, 
        uint amount
    );

    event BundleStarted(
        string Name,
        address[] ContractAddresses, 
        bytes32 RootHash, 
        address Operator, 
        bool ActivePublic,
        bool ActiveBrightList,
        bool AllowMultiplePurchases
    );

    event BundlesStarted(Bundle BundleInstance);

    event BundlesEnded(uint[] BundleIndexes);
    event BundleChangedNames(uint[] BundleIndexes, string[] NewNames);
    event BundleChangedStartingIndexes(uint indexed BundleIndex, uint[] OldStartingIndexes, uint[] NewStartingIndexes);
    event BundleChangedEndingIndexes(uint indexed BundleIndex, uint[] OldEndingIndexes, uint[] NewEndingIndexes);
    event BundleChangedAllocationsPublic(uint[] BundleIndexes, uint[] NewAllocations);
    event BundleChangedAllocationsBrightList(uint[] BundleIndexes, uint[] NewAllocations);
    event BundleChangedPricesBrightList(uint[] BundleIndexes, uint[] NewPrices);
    event BundleChangedPricesPublic(uint[] BundleIndexes, uint[] NewPrices); 
    event BundleChangedERC_TYPE(uint indexed BundleIndex, uint OLD_ERC_TYPE, uint NEW_ERC_TYPE);
    event BundleChangedContracts(uint indexed BundleIndex, address[] OldContracts, address[] NewContracts);
    event BundleChangedRoots(uint[] BundleIndexes, bytes32[] NewRoots);
    event BundleChangedOperators(uint[] indexed BundleIndexes, address[] NewOperators);
    event BundleChangedActiveStatesPublic(uint[] BundleIndexes, bool[] States);
    event BundleChangedActiveStatesBrightList(uint[] BundleIndexes, bool[] States);
    event BundleChangedPurchaseableAmounts(uint[] BundleIndexes, uint[] Amounts);
    event BundleChangedAllowMultiplePurchases(uint[] BundleIndexes, bool[] States);

    event OperatorAdded(address Operator);
    event OperatorRemoved(address Operator);

    uint public UniqueBundleIndex;

    bytes32 private immutable _OPERATOR = keccak256("OPERATOR");
    bytes32 private immutable _DEACTIVATED = 0x0;
    address public immutable _BRTMULTISIG = 0xB96E81f80b3AEEf65CB6d0E280b15FD5DBE71937;

    constructor() 
    { 
        BRTOperators[0x5778B0B140Fa7a62B96c193cC8621e6E96c088A5] = _OPERATOR; //brougkr
        BRTOperators[0x18B7511938FBe2EE08ADf3d4A24edB00A5C9B783] = _OPERATOR; //phil.brightmoments.eth
        BRTOperators[0xbf001FF749b7E793bbb1A612d09124470b9179A7] = _OPERATOR; //future
        _transferOwnership(_BRTMULTISIG);
    } 


    function BundlePurchase(uint BundleIndex, uint Amount) public payable nonReentrant
    { 

        require(Bundles[BundleIndex].ActivePublic, "BrightBundles: Requested Bundle Is Not Available For Public Purchases");
        require(
            PurchasedAmountPublic[BundleIndex][msg.sender] + Amount <= Bundles[BundleIndex].PurchaseableAmountPublic,
            "BrightBundles: User Has Used Up All Of Public Allocation For This Bundle Index"
        );
        if(!Bundles[BundleIndex].AllowMultiplePurchases) { require(!BundlePurchased[BundleIndex][msg.sender], "BrightBundles: User Has Already Purchased This Bundle Index"); }
        require(msg.value == Bundles[BundleIndex].PricePublic * Amount && Amount > 0, "BrightBundles: Incorrect Ether Amount Or Token Amount Sent For Purchase");
        if(!BundlePurchased[BundleIndex][msg.sender]) { BundlePurchased[BundleIndex][msg.sender] = true; }
        PurchasedAmountPublic[BundleIndex][msg.sender] += Amount;
        for(uint x; x < Amount; x++)
        {
            for(uint y; y < Bundles[BundleIndex].ContractAddresses.length; y++)
            {
                IERC721(Bundles[BundleIndex].ContractAddresses[y]).transferFrom(
                    Bundles[BundleIndex].Operator, 
                    msg.sender, 
                    Bundles[BundleIndex].StartingIndexes[y]
                );
                Bundles[BundleIndex].StartingIndexes[y]++;
            }
        }
        BundleProceeds[BundleIndex] += msg.value;
        emit BundlePurchaseEvent(msg.sender, BundleIndex, Amount);
    }

    function BundlePurchaseBrightList(uint BundleIndex, uint Amount, bytes32[] calldata Proof) public payable nonReentrant
    {

        require(Bundles[BundleIndex].ActiveBrightList, "BrightBundles: Requested Bundle Is Not Available For BrightList Purchases");
        require(msg.value == Bundles[BundleIndex].PriceBrightList * Amount && Amount > 0, "BrightBundles: Incorrect Ether Amount Or Token Amount Sent For Purchase");
        require(viewBrightListAllocation(msg.sender, BundleIndex, Proof), "BrightBundles: User Is Not On BrightList");
        require(
            PurchasedAmountBrightList[BundleIndex][msg.sender] + Amount <= Bundles[BundleIndex].PurchaseableAmountBrightList,
            "BrightBundles: User Has Used Up All BrightList Allocation For This Bundle Index"
        );
        if(!Bundles[BundleIndex].AllowMultiplePurchases) { require(!BundlePurchased[BundleIndex][msg.sender], "BrightBundles: User Has Already Purchased This Bundle Index"); }
        if(!BundlePurchased[BundleIndex][msg.sender]) { BundlePurchased[BundleIndex][msg.sender] = true; }
        PurchasedAmountBrightList[BundleIndex][msg.sender] += Amount;    
        for(uint x; x < Amount; x++)
        {
            for(uint y; y < Bundles[BundleIndex].ContractAddresses.length; y++)
            {
                IERC721(Bundles[BundleIndex].ContractAddresses[y]).transferFrom(
                    Bundles[BundleIndex].Operator, 
                    msg.sender, 
                    Bundles[BundleIndex].StartingIndexes[y]
                );
                Bundles[BundleIndex].StartingIndexes[y]++;
            }
        }
        BundleProceeds[BundleIndex] += msg.value;
        emit BundlePurchaseEventBrightList(msg.sender, BundleIndex, Amount);
    }


    function _StartBundle(Bundle memory NewBundleInstance) external onlyBRTOperator
    {

        UniqueBundleIndex++; 

        Bundles[UniqueBundleIndex].Name = NewBundleInstance.Name;
        Bundles[UniqueBundleIndex].PriceBrightList = NewBundleInstance.PriceBrightList;
        Bundles[UniqueBundleIndex].PricePublic = NewBundleInstance.PricePublic;
        Bundles[UniqueBundleIndex].StartingIndexes = NewBundleInstance.StartingIndexes;
        Bundles[UniqueBundleIndex].EndingIndexes = NewBundleInstance.EndingIndexes;
        Bundles[UniqueBundleIndex].PurchaseableAmount = NewBundleInstance.PurchaseableAmount;
        Bundles[UniqueBundleIndex].PurchaseableAmountBrightList = NewBundleInstance.PurchaseableAmountBrightList;
        Bundles[UniqueBundleIndex].PurchaseableAmountPublic = NewBundleInstance.PurchaseableAmountPublic;
        Bundles[UniqueBundleIndex].ContractAddresses = NewBundleInstance.ContractAddresses;
        Bundles[UniqueBundleIndex].Operator = NewBundleInstance.Operator;
        Bundles[UniqueBundleIndex].Root = NewBundleInstance.Root;
        Bundles[UniqueBundleIndex].ActivePublic = NewBundleInstance.ActivePublic;
        Bundles[UniqueBundleIndex].ActiveBrightList = NewBundleInstance.ActiveBrightList;
        Bundles[UniqueBundleIndex].AllowMultiplePurchases = NewBundleInstance.AllowMultiplePurchases;
        
        emit BundleStarted(
            Bundles[UniqueBundleIndex].Name,
            Bundles[UniqueBundleIndex].ContractAddresses, 
            Bundles[UniqueBundleIndex].Root, 
            Bundles[UniqueBundleIndex].Operator, 
            Bundles[UniqueBundleIndex].ActivePublic,
            Bundles[UniqueBundleIndex].ActiveBrightList,
            Bundles[UniqueBundleIndex].AllowMultiplePurchases
        );
    }

    function _StartBundles(Bundle[] memory NewBundleInstances) external onlyBRTOperator   
    {

        for(uint BundleIndex; BundleIndex < NewBundleInstances.length; BundleIndex++)
        {  
            UniqueBundleIndex++; 

            Bundles[UniqueBundleIndex].Name = NewBundleInstances[BundleIndex].Name;
            Bundles[UniqueBundleIndex].PriceBrightList = NewBundleInstances[BundleIndex].PriceBrightList;
            Bundles[UniqueBundleIndex].PricePublic = NewBundleInstances[BundleIndex].PricePublic;
            Bundles[UniqueBundleIndex].PurchaseableAmount = NewBundleInstances[BundleIndex].PurchaseableAmount;
            Bundles[UniqueBundleIndex].PurchaseableAmountBrightList = NewBundleInstances[BundleIndex].PurchaseableAmountBrightList;
            Bundles[UniqueBundleIndex].PurchaseableAmountPublic = NewBundleInstances[BundleIndex].PurchaseableAmountPublic;
            Bundles[UniqueBundleIndex].ContractAddresses = NewBundleInstances[BundleIndex].ContractAddresses;
            Bundles[UniqueBundleIndex].Operator = NewBundleInstances[BundleIndex].Operator;
            Bundles[UniqueBundleIndex].Root = NewBundleInstances[BundleIndex].Root;
            Bundles[UniqueBundleIndex].StartingIndexes = NewBundleInstances[BundleIndex].StartingIndexes;
            Bundles[UniqueBundleIndex].EndingIndexes = NewBundleInstances[BundleIndex].EndingIndexes;
            Bundles[UniqueBundleIndex].ActivePublic = NewBundleInstances[BundleIndex].ActivePublic;
            Bundles[UniqueBundleIndex].ActiveBrightList = NewBundleInstances[BundleIndex].ActiveBrightList;
            Bundles[UniqueBundleIndex].AllowMultiplePurchases = NewBundleInstances[BundleIndex].AllowMultiplePurchases;
        }
        emit BundlesStarted(Bundles[UniqueBundleIndex]);
    }

    function _ChangeBundleNames(uint[] calldata BundleIndexes, string[] memory Names) external onlyBRTOperator 
    { 

        for(uint i; i < BundleIndexes.length; i++)
        {
            Bundles[BundleIndexes[i]].Name = Names[i];  
        }
        emit BundleChangedNames(BundleIndexes, Names);
    }
    
    function _ChangeBundleStartingIndexes(uint BundleIndex, uint[] calldata Indexes) external onlyBRTOperator 
    { 

        uint[] memory OldStartingIndexes = Bundles[BundleIndex].StartingIndexes;
        Bundles[BundleIndex].StartingIndexes = Indexes; 
        emit BundleChangedStartingIndexes(BundleIndex, OldStartingIndexes, Indexes);
    }

    function _ChangeBundleEndingIndexes(uint BundleIndex, uint[] calldata Indexes) external onlyBRTOperator 
    { 

        uint[] memory OldEndingIndexes = Bundles[BundleIndex].EndingIndexes;
        Bundles[BundleIndex].EndingIndexes = Indexes; 
        emit BundleChangedEndingIndexes(BundleIndex, OldEndingIndexes, Indexes);
    }

    function _ChangeBundleAllocationsPublic(uint[] calldata BundleIndexes, uint[] calldata Amounts) external onlyBRTOperator 
    {

        for(uint i; i < BundleIndexes.length; i++)
        {
            Bundles[BundleIndexes[i]].PurchaseableAmountPublic = Amounts[i]; 
        }
        emit BundleChangedAllocationsPublic(BundleIndexes, Amounts);
    }
    
    function _ChangeBundleAllocationsBrightList(uint[] calldata BundleIndexes, uint[] calldata Amounts) external onlyBRTOperator 
    {

        for(uint i; i < BundleIndexes.length; i++)
        {
            Bundles[BundleIndexes[i]].PurchaseableAmountBrightList = Amounts[i]; 
        }
        emit BundleChangedAllocationsBrightList(BundleIndexes, Amounts);
    }

    function _ChangeBundlePricesPublic(uint[] calldata BundleIndexes, uint[] calldata Prices) external onlyBRTOperator 
    { 

        for(uint i; i < BundleIndexes.length; i++)
        {
            Bundles[BundleIndexes[i]].PricePublic = Prices[i];
        }
        emit BundleChangedPricesPublic(BundleIndexes, Prices);
    }

    function _ChangeBundlePricesBrightList(uint[] calldata BundleIndexes, uint[] calldata Prices) external onlyBRTOperator 
    {

        for(uint i; i < BundleIndexes.length; i++)
        {
            Bundles[BundleIndexes[i]].PriceBrightList = Prices[i]; 
        }
        emit BundleChangedPricesBrightList(BundleIndexes, Prices);
    }

    function _ChangeBundlePurchaseableAmounts(uint[] calldata BundleIndexes, uint[] calldata Amounts) external onlyBRTOperator 
    {

        for(uint i; i < BundleIndexes.length; i++)
        {
            Bundles[BundleIndexes[i]].PurchaseableAmount = Amounts[i]; 
        }
        emit BundleChangedPurchaseableAmounts(BundleIndexes, Amounts);
    }

    function _ChangeBundleContracts(uint BundleIndex, address[] calldata Contracts) external onlyBRTOperator 
    { 

        address[] memory OldContracts = Bundles[BundleIndex].ContractAddresses;
        Bundles[BundleIndex].ContractAddresses = Contracts; 
        emit BundleChangedContracts(BundleIndex, OldContracts, Contracts);
    }

    function _ChangeBundleOperators(uint[] calldata BundleIndexes, address[] calldata Operators) external onlyBRTOperator 
    { 

        for(uint i; i < BundleIndexes.length; i++)
        {
            Bundles[BundleIndexes[i]].Operator = Operators[i]; 
            emit BundleChangedOperators(BundleIndexes, Operators);
        }
    }

    function _ChangeBundleRoots(uint[] calldata BundleIndexes, bytes32[] calldata RootHashes) external onlyBRTOperator 
    { 

        for(uint i; i < BundleIndexes.length; i++)
        {
            Bundles[BundleIndexes[i]].Root = RootHashes[i]; 
        }
        emit BundleChangedRoots(BundleIndexes, RootHashes);
    }

    function _ChangeBundleActiveStatesBrightList(uint[] calldata BundleIndexes, bool[] calldata States) external onlyBRTOperator 
    { 

        require(BundleIndexes.length == States.length, "Arrays Must Be Equal Length");
        for(uint i; i < BundleIndexes.length; i++)
        {
            Bundles[BundleIndexes[i]].ActiveBrightList = States[i];
        }
        emit BundleChangedActiveStatesBrightList(BundleIndexes, States);
    }

    function _ChangeBundleActiveStatesPublic(uint[] calldata BundleIndexes, bool[] calldata States) external onlyBRTOperator 
    { 

        require(BundleIndexes.length == States.length, "Arrays Must Be Equal Length");
        for(uint i; i < BundleIndexes.length; i++)
        {
            Bundles[BundleIndexes[i]].ActivePublic = States[i];
        }
        emit BundleChangedActiveStatesPublic(BundleIndexes, States);
    }

    function _ChangeBundleAllowMultiplePurchases(uint[] calldata BundleIndexes, bool[] calldata States) external onlyBRTOperator 
    { 

        require(BundleIndexes.length == States.length, "Arrays Must Be Equal Length");
        for(uint i; i < BundleIndexes.length; i++)
        {
            Bundles[BundleIndexes[i]].AllowMultiplePurchases = States[i];
        }
        emit BundleChangedAllowMultiplePurchases(BundleIndexes, States);
    }

    function _EndBundles(uint[] calldata BundleIndexes) external onlyBRTOperator 
    {

        for(uint i; i < BundleIndexes.length; i++)
        {
            Bundles[BundleIndexes[i]].ActivePublic = false; 
            Bundles[BundleIndexes[i]].ActiveBrightList = false;
        }
        emit BundlesEnded(BundleIndexes);
    }


    function __OperatorAdd(address Operator) external onlyOwner 
    { 

        BRTOperators[Operator] = _OPERATOR; 
        emit OperatorAdded(Operator);
    }

    function __OperatorRemove(address Operator) external onlyOwner 
    { 

        BRTOperators[Operator] = _DEACTIVATED; 
        emit OperatorRemoved(Operator);    
    }

    function __Withdraw() external onlyOwner 
    {

        uint balance = address(this).balance;
        require(balance > 0, "Insufficient Balance"); 
        payable(owner()).transfer(balance); 
    }

    function __WithdrawToAddress(address payable Recipient) external onlyOwner 
    {

        uint balance = address(this).balance;
        require(balance > 0, "Insufficient Ether To Withdraw");
        (bool Success, ) = Recipient.call{value: balance}("");
        require(Success, "Unable to Withdraw, Recipient May Have Reverted");
    }

    function __WithdrawAmountToAddress(address payable Recipient, uint Amount) external onlyOwner
    {

        require(Amount > 0 && Amount <= address(this).balance, "Invalid Amount");
        (bool Success, ) = Recipient.call{value: Amount}("");
        require(Success, "Unable to Withdraw, Recipient May Have Reverted");
    }

    function __WithdrawBundleProceeds(uint BundleIndex) external onlyOwner
    {

        uint Amount = BundleProceeds[BundleIndex];
        require(Amount > 0 && Amount <= address(this).balance, "Insufficient Balance");
        BundleProceeds[BundleIndex] = 0;
        (bool Success, ) = owner().call{value: Amount}("");
        require(Success, "Unable to Withdraw, Recipient May Have Reverted");
    }

    function __WithdrawBundleProceedsToAddress(address payable Recipient, uint BundleIndex) external onlyOwner
    {

        uint Amount = BundleProceeds[BundleIndex];
        require(Amount > 0 && Amount <= address(this).balance, "Insufficient Balance");
        BundleProceeds[BundleIndex] = 0;
        (bool Success, ) = Recipient.call{value: Amount}("");
        require(Success, "Unable to Withdraw, Recipient May Have Reverted");
    }
    
    function __WithdrawERC20ToAddress(address Recipient, address ContractAddress) external onlyOwner
    {

        IERC20 ERC20 = IERC20(ContractAddress);
        ERC20.transferFrom(address(this), Recipient, ERC20.balanceOf(address(this)));
    }

    
    function viewBrightListAllocation(address Recipient, uint BundleIndex, bytes32[] memory Proof) public view returns(bool)
    { 

        bytes32 Leaf = keccak256(abi.encodePacked(Recipient));
        return MerkleProof.verify(Proof, Bundles[BundleIndex].Root, Leaf);
    }

    function viewBundleState(uint BundleIndex) public view returns(Bundle memory) { return Bundles[BundleIndex]; }


    function viewBundleStates(uint[] calldata BundleIndexes) public view returns(Bundle[] memory) 
    {

        Bundle[] memory BundleStates = new Bundle[](BundleIndexes.length);
        for (uint i; i < BundleIndexes.length; i++) 
        {
            Bundle storage saleInstance = Bundles[BundleIndexes[i]];
            BundleStates[i] = saleInstance;
        }
        return BundleStates;
    }


    modifier onlyBRTOperator
    {

        require(BRTOperators[msg.sender] == _OPERATOR, "User Is Not A Valid BRT Operator");
        _;
    }
}