pragma solidity 0.6.6;


contract VersionControlStoragePublic {

    address[] public code;
}


contract VCProxyData {

    address internal vc; //Version Control Smart Contract Address
    uint256 internal version; //The index of our logic code in the Version Control array.
}


contract VCProxy is VCProxyData {

    constructor(uint256 _version, address _vc) public {
        version = _version;
        vc = _vc;
    }

    fallback () virtual external payable {

        address addr = VersionControlStoragePublic(vc).code(version);
        assembly {
            let freememstart := mload(0x40)
            calldatacopy(freememstart, 0, calldatasize())
            let success := delegatecall(not(0), addr, freememstart, calldatasize(), freememstart, 0)
            returndatacopy(freememstart, 0, returndatasize())
            switch success
            case 0 { revert(freememstart, returndatasize()) }
            default { return(freememstart, returndatasize()) }
        }
    }

    
    receive() virtual external payable{
       require(false, "Do not send me Eth without a reason");
    }
}// © Copyright 2020. Patent pending. All rights reserved. Perpetual Altruism Ltd.
pragma solidity 0.6.6;

interface ERC2665 /* is ERC165, is ERC721 but overide it's Design by contract specifications */ {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);


    function ownerOf(uint256 _tokenId) external view returns (address);


    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;


    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;


    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;


    function approve(address _approved, uint256 _tokenId) external payable;


    function setApprovalForAll(address _operator, bool _approved) external;


    function getApproved(uint256 _tokenId) external view returns (address);


    function isApprovedForAll(address _owner, address _operator) external view returns (bool);


    function getTransferFee(uint256 _tokenId) external view returns (uint256);


    function getTransferFee(uint256 _tokenId, string calldata _currencySymbol) external view returns (uint256);


}


interface ERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}

interface ERC2665TokenReceiver {

    function onERC2665Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);

}

interface ERC721Metadata /* is ERC721 */ {

    function name() external view returns(string memory _name);


    function symbol() external view returns(string memory _symbol);


    function tokenURI(uint256 _tokenId) external view returns(string memory);

}

interface ERC721Enumerable /* is ERC721 */ {

    function totalSupply() external view returns (uint256);


    function tokenByIndex(uint256 _index) external view returns (uint256);


    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);

}

contract ERC2665HeaderV1 {

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId);

    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId);

    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved);
}

contract ERC2665StorageInternalV1 {

    address payable internal auctionHouse;
    address internal indexCry;

    mapping(address => bool) internal isACryptograph;

    mapping(address => uint256) internal balanceOfVar;

    uint256 internal totalSupplyVar;
    mapping(uint256 => address) internal index2665ToAddress;

    mapping(address => uint256[]) internal indexedOwnership; //[Owner][index] = cryptographID
    mapping(uint256 => uint256) internal cryptographPositionInOwnershipArray; // [cryptographID] = index
    mapping(uint256 => uint256) internal lastSoldFor; //Value last sold on the cryptograph platform
    mapping(uint256 => uint256) internal transferFees; //Pending transfer fee
    mapping(uint256 => bool) internal transferFeePrepaid; //Have the next transfer fee be prepaid ?
    mapping(uint256 => address) public approvedTransferAddress; //Address allowed to Transfer a token
    mapping(address => mapping(address => bool)) internal approvedOperator; //Approved operators mapping

}

contract ERC2665StoragePublicV1 {

    address payable public auctionHouse;
    address public indexCry;

    mapping(address => bool) public isACryptograph;

    mapping(address => uint256) public balanceOfVar;

    uint256 public totalSupplyVar;
    mapping(uint256 => address) public index2665ToAddress;

    mapping(address => uint256[]) public indexedOwnership; //[Owner][index] = cryptographID
    mapping(uint256 => uint256) public cryptographPositionInOwnershipArray; // [cryptographID] = index
    mapping(uint256 => uint256) public lastSoldFor; // Value last sold on the cryptograph platform
    mapping(uint256 => uint256) public transferFees; // Pending transfer fee
    mapping(uint256 => bool) public transferFeePrepaid; //Have the next transfer fee be prepaid ?
    mapping(uint256 => address) public approvedTransferAddress; //Address allowed to Transfer a token
    mapping(address => mapping(address => bool)) public approvedOperator; //Approved operators mapping
}
pragma solidity 0.6.6;

contract ERC2665StorageInternalV2 {

    address payable internal auctionHouse;
    address internal indexCry;

    mapping(address => bool) internal isACryptograph;

    mapping(address => uint256) internal balanceOfVar;

    uint256 internal totalSupplyVar;
    mapping(uint256 => address) internal index2665ToAddress;

    mapping(address => uint256[]) internal indexedOwnership; //[Owner][index] = cryptographID
    mapping(uint256 => uint256) internal cryptographPositionInOwnershipArray; // [cryptographID] = index
    mapping(uint256 => uint256) internal lastSoldFor; //Value last sold on the cryptograph platform
    mapping(uint256 => uint256) internal transferFees; //Pending transfer fee
    mapping(uint256 => bool) internal transferFeePrepaid; //Have the next transfer fee be prepaid ?
    mapping(uint256 => address) internal approvedTransferAddress; //Address allowed to Transfer a token
    mapping(address => mapping(address => bool)) internal approvedOperator; //Approved operators mapping
	
	address internal contractWETH; // The address of the Wrapped ETH ERC-20 token accepted as payment instead of ETH

}

contract ERC2665StoragePublicV2 {

    address payable public auctionHouse;
    address public indexCry;

    mapping(address => bool) public isACryptograph;

    mapping(address => uint256) public balanceOfVar;

    uint256 public totalSupplyVar;
    mapping(uint256 => address) public index2665ToAddress;

    mapping(address => uint256[]) public indexedOwnership; //[Owner][index] = cryptographID
    mapping(uint256 => uint256) public cryptographPositionInOwnershipArray; // [cryptographID] = index
    mapping(uint256 => uint256) public lastSoldFor; // Value last sold on the cryptograph platform
    mapping(uint256 => uint256) public transferFees; // Pending transfer fee
    mapping(uint256 => bool) public transferFeePrepaid; //Have the next transfer fee be prepaid ?
    mapping(uint256 => address) public approvedTransferAddress; //Address allowed to Transfer a token
    mapping(address => mapping(address => bool)) public approvedOperator; //Approved operators mapping
	
	address public contractWETH; // The address of the Wrapped ETH ERC-20 token accepted as payment instead of ETH
}
pragma solidity 0.6.6;


contract TheCryptographHeaderV1 {

    event Named(string name);
    event MediaHash(string mediaHash);
    event MediaUrl(string mediaUrl);
    event Transferred(address indexed previousOwner, address indexed newOwner);
    event Marked (address indexed Marker, string indexed Mark);
    event Renatus(uint256 endtime);
}


contract TheCryptographStorageInternalV1 {


    string internal name; //The name of this cryptograph
    string internal creator; //The creator of this cryptograph
    string internal mediaHash; //The hash of the cryptograph media
    string internal mediaUrl; //An url where the cryptograph media is accessible
    uint256 internal serial; //The serial number of this cryptograph (position in the index)
    uint256 internal issue; //The numbered minting of this specific cryptograph.
    bool internal hasCurrentOwnerMarked; //Each subsequent owner can only leave its mark once
    string[] internal marks; //Each owner can leave its mark on the cryptograph
    address[] internal markers; //List of owners that have left a mark

    address internal owner; //The current owner of the cryptograph

    address internal myAuction; //Address of the running auction associated with this Cryptograph
    bool internal official; //Are we an official cryptograph ?

    uint256 internal lastOwnerInteraction; //When was the last time the owner interacted with the cryptograph ?
    uint256 internal renatusTimeStamp; //When was the last time someone wanted to check if the owner was still owning it's private key ?

}


contract TheCryptographStoragePublicV1 {


    string public name; //The name of this cryptograph
    string public creator; //The creator of this cryptograph
    string public mediaHash; //The hash of the cryptograph media
    string public mediaUrl; //An url where the cryptograph media is accessible
    uint256 public serial; //The serial number of this cryptograph (position in the index)
    uint256 public issue;
    bool public hasCurrentOwnerMarked; //Each subsequent owner can only leave its mark once
    string[] public marks; //Each owner can leave its mark on the cryptograph
    address[] public markers; //List of owners that have left a mark

    address public owner; //The current owner of the cryptograph

    address public myAuction; //Address of the running auction associated with this Cryptograph
    bool public official; //Are we an official cryptograph ?

    uint256 public lastOwnerInteraction; //When was the last time the owner interacted with the cryptograph ?
    uint256 public renatusTimeStamp; //When was the last time someone wanted to check if the owner was still owning it's private key ?

}

pragma solidity 0.6.6;

contract CryptographFactoryHeaderV1 {

    event CryptographCreated(uint256 indexed cryptographIssue, address indexed cryptographAddress, bool indexed official);
    event CryptographEditionAdded(uint256 indexed cryptographIssue, uint256 indexed editionSize, bool indexed official);
    event CryptographEditionMinted(uint256 indexed cryptographIssue, uint256 indexed editionIssue, address cryptographAddress, bool indexed official);
}


contract CryptographFactoryStorageInternalV1 {


    bool internal initialized; //A bool controlling if we have been initialized or not

    address internal officialPublisher; //The address that is allowed to publish the official (i.e. non-community) cryptographs

    address internal targetVC; //Address of the version control that the Cryptograph should use (potentially different than ours)
    address internal targetAuctionHouse; //Address of the Auction house used by Cryptograph
    address internal targetIndex; //Address of the Cryptograph library storing both fan made and public cryptographs

    uint256 internal targetCryLogicVersion; //Which version of the logic code in the Version Control array the cryptographs should use
    uint256 internal targetAuctionLogicVersion;
    uint256 internal targetAuctionBidLogicVersion;
    uint256 internal targetMintingAuctionLogicVersion;

    mapping (address => uint256) internal mintingAuctionSupply; //How much token can be created by each MintingAuction

    bool internal communityMintable;

}


contract CryptographFactoryStoragePublicV1 {


    bool public initialized; //A bool controlling if we have been initialized or not

    address public officialPublisher; //The address that is allowed to publish the non-community cryptographs

    address public targetVC; //Address of the version control the cryptographs should use
    address public targetAuctionHouse; //Address of the Auction house used by cryptograph
    address public targetIndex; //Address of the Cryptograph library storing both fan made and public cryptographs

    uint256 public targetCryLogicVersion; //Which version of the logic code in the Version Control array the cryptographs should use
    uint256 public targetAuctionLogicVersion; //Which version of the logic code in the Version Control array the Single Auction should use
    uint256 public targetAuctionBidLogicVersion;
    uint256 public targetMintingAuctionLogicVersion;

    mapping (address => uint256) public mintingAuctionSupply; //How much token can be created by each MintingAuction

    bool public communityMintable;
}// © Copyright 2020. Patent pending. All rights reserved. Perpetual Altruism Ltd.
pragma solidity 0.6.6;

contract AuctionHouseHeaderV1 {


    event Deposit(uint256 indexed amount, address indexed beneficiary, address indexed contributor, address origin);

    event UserWithdrawal(uint256 indexed amount, address indexed account);

    event UserBid(address indexed auction, uint256 indexed bidValue, address indexed bidder);

    event UserCancelledBid(address indexed auction, address indexed bidder);

    event UserWin(address indexed auction, uint256 indexed bidValue, address indexed bidder);

    event UserSell(address indexed auction);

    event UserSellingPriceAdjust(address indexed auction, uint256 indexed value);
}


contract AuctionHouseStorageInternalV1 {

    bool internal initialized; //Bool to check if the index have been initialized
    address internal factory; //The factory smart contract (proxy) that will publish the cryptographs
    address internal index; //The index smart contract that maps cryptographs and their auctions
    mapping (address => uint) internal pendingWithdrawals;  //How much money each user owns on the smart contract

    address internal ERC2665Lieutenant;
    address internal kycContract;
}


contract AuctionHouseStoragePublicV1 {

    bool public initialized; //Bool to check if the index have been initialized
    address public factory; //The factory smart contract (proxy) that will publish the cryptographs
    address public index; //The index smart contract that maps cryptographs and their auctions
    mapping (address => uint) public pendingWithdrawals;  //How much money each user owns on the smart contract

    address public ERC2665Lieutenant;
    address public kycContract;

}// © Copyright 2020. Patent pending. All rights reserved. Perpetual Altruism Ltd.
pragma solidity 0.6.6;


contract ERC2665LogicV1 is VCProxyData, ERC2665HeaderV1, ERC2665StoragePublicV1 {


    constructor() public {
    }

    function init(address _auctionHouse, address _indexCry) external{

        require(auctionHouse == address(0), "Already initialized");
        auctionHouse = payable(_auctionHouse);
        indexCry = _indexCry;
    }

    function transferACryptograph(address _from, address _to, address _cryptograph, uint256 _lastSoldFor ) external {

        require((msg.sender == auctionHouse), "Only the cryptograph auction house smart contract can call this function");
        transferACryptographInternal(_from, _to, _cryptograph, _lastSoldFor);
    }


    function MintACryptograph(address _newCryptograph) external {

        require((msg.sender == indexCry), "Only the cryptograph index smart contract can call this function");
        index2665ToAddress[totalSupplyVar] = _newCryptograph;
        totalSupplyVar++;
        balanceOfVar[address(0)] = balanceOfVar[address(0)] + 1;
        isACryptograph[_newCryptograph] = true;

    }

    function supportsInterface(bytes4 interfaceID) external pure returns(bool) {


        return (
            interfaceID == 0x80ac58cd || //ERC721
            interfaceID == 0x5b5e139f || //metadata extension
            interfaceID == 0x780e9d63 || //enumeration extension
            interfaceID == 0x509ffea4 //ERC2665
        );
        
    }

    function balanceOf(address _owner) external view returns (uint256){

        require(_owner != address(0), "ERC721 NFTs assigned to the zero address are considered invalid");
        return balanceOfVar[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address){

        require(isACryptograph[address(_tokenId)], "_tokenId is not a Valid Cryptograph");
        address retour = TheCryptographLogicV1(address(_tokenId)).owner();
        require(retour != address(0),
            "ERC721 NFTs assigned to the zero address are considered invalid");
        return retour;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable{

        transferFromInternal(_from, _to, _tokenId, msg.sender, msg.value);

        require(_to != address(0));
        if(isContract(_to)){
            require(ERC2665TokenReceiver(_to).onERC2665Received(msg.sender, _from, _tokenId, data) == bytes4(0xac3cf292));
        }
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{

        transferFromInternal(_from, _to, _tokenId, msg.sender, msg.value);

        require(_to != address(0));
        if(isContract(_to)){
            require(ERC2665TokenReceiver(_to).onERC2665Received(msg.sender, _from, _tokenId, "") ==  bytes4(0xac3cf292));
        }
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable{

        transferFromInternal(_from, _to, _tokenId, msg.sender, msg.value);
    }



    function approve(address _approved, uint256 _tokenId) external payable{


        address owner = TheCryptographLogicV1(address(_tokenId)).owner();
        require(msg.sender == owner || approvedOperator[owner][msg.sender], "Only the owner or an operator can approve a token transfer");
        require(isACryptograph[address(_tokenId)], "_tokenId is not a Valid Cryptograph");

        TheCryptographLogicV1(address(_tokenId)).renatus();

        uint256 leftover = msg.value;

        if(leftover >= transferFees[_tokenId]){

            leftover =  leftover - transferFees[_tokenId];
            transferFees[_tokenId] = 0;
            
            if(leftover >= (lastSoldFor[_tokenId] * 15 /100)){
                leftover = leftover -  (lastSoldFor[_tokenId] * 15 /100);
                transferFeePrepaid[_tokenId] = true;
            }

        }

        AuctionHouseLogicV1(auctionHouse).approveERC2665{value: msg.value - leftover }(address(_tokenId), msg.sender, _approved);

        if(leftover != 0){
            (bool trashBool, ) = msg.sender.call{value:leftover}("");
            require(trashBool, "Could not send the leftover money back");
        }

        approvedTransferAddress[_tokenId] = _approved; 

        emit Approval(msg.sender, _approved, _tokenId);

    }

    function setApprovalForAll(address _operator, bool _approved) external {

        approvedOperator[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address){

        require(isACryptograph[address(_tokenId)], "_tokenId is not a Valid Cryptograph");

        return approvedTransferAddress[_tokenId];
    }
  
    function isApprovedForAll(address _owner, address _operator) external view returns (bool){

        return approvedOperator[_owner][_operator];
    }

    function getTransferFee(uint256 _tokenId) external view returns (uint256){

        return transferFees[_tokenId];
    }


    function getTransferFee(uint256 _tokenId, string calldata _currencySymbol) external view returns (uint256){

        if(bytes32(0xaaaebeba3810b1e6b70781f14b2d72c1cb89c0b2b320c43bb67ff79f562f5ff4) == keccak256(bytes(_currencySymbol))){
            return transferFees[_tokenId];
        } else {
            return 0;
        }
    }


    function name() external pure returns(string memory _name){

        return "Cryptograph";
    }

    function symbol() external pure returns(string memory _symbol){

        return "Cryptograph";
    }

    function tokenURI(uint256 _tokenId) external view returns(string memory){

        require(isACryptograph[address(_tokenId)], "_tokenId is not a Valid Cryptograph");
   
        return string(abi.encodePacked("https://cryptograph.co/tokenuri/", addressToString(address(_tokenId))));
    }


    function totalSupply() external view returns (uint256){

        return totalSupplyVar;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256){

        require(_index < totalSupplyVar, "index >= totalSupply()");
        return uint256(index2665ToAddress[_index]);
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256){

        require(_owner != address(0), "_owner == 0");
        require(_index < balanceOfVar[_owner], "_index >= balanceOf(_owner)");

        return indexedOwnership[_owner][_index];
    }

    function addressFromTokenId(uint256 _tokenId) external pure returns (address){

            return address(_tokenId);
    }

    function tokenIdFromAddress(address _tokenAddress) external pure returns (uint256){

            return uint256(_tokenAddress);
    }

    function renatus(uint256 _tokenId) public {

        require(isACryptograph[address(_tokenId)], "renatus need to be called for a Valid Cryptograph");

        address owner = TheCryptographLogicV1(address(_tokenId)).owner();
        require(approvedOperator[owner][msg.sender] || owner == msg.sender);

        TheCryptographLogicV1(address(_tokenId)).renatus();
    }

    function triggerRenatus() public{

        require(isACryptograph[msg.sender], "Only the token itself can notify us of a renatus hapenning");
        emit Transfer(TheCryptographLogicV1(address(msg.sender)).owner(), address(0), uint256(msg.sender));
    }
    
    function transferACryptographInternal(address _from, address _to, address _cryptograph, uint256 _lastSoldFor) internal{


         require(isACryptograph[_cryptograph], 
            "Only minted cryptogrtaphs can be transferred");

        if(_lastSoldFor != lastSoldFor[uint256(_cryptograph)]){
            lastSoldFor[uint256(_cryptograph)] = _lastSoldFor;
        }

        if(!transferFeePrepaid[uint256(_cryptograph)]){
            transferFees[uint256(_cryptograph)] = (_lastSoldFor * 15) / 100; //15% transfer fee
        } else {
            transferFees[uint256(_cryptograph)] = 0;
        }
        transferFeePrepaid[uint256(_cryptograph)] = false;
  

        approvedTransferAddress[uint256(_cryptograph)] = address(0);


        emit Transfer(_from, _to, uint256(_cryptograph));

        uint256 posInArray;

        if(_from != address(0x0)){

            if(balanceOfVar[_from] != 1){


                posInArray = cryptographPositionInOwnershipArray[uint256(_cryptograph)];

                indexedOwnership[_from][posInArray] = indexedOwnership[_from][balanceOfVar[_from]-1];

                cryptographPositionInOwnershipArray[indexedOwnership[_from][posInArray]] = posInArray;

                delete indexedOwnership[_from][balanceOfVar[_from]-1];

            }  else {
                delete indexedOwnership[_from][0];
            }
        }

        posInArray = balanceOfVar[_to];

        if(_to != address(0x0)){

            if(indexedOwnership[_to].length < posInArray + 1){
                indexedOwnership[_to].push(uint256(_cryptograph));
            } else {
                indexedOwnership[_to][posInArray] = uint256(_cryptograph);
            }

            cryptographPositionInOwnershipArray[uint256(_cryptograph)] = posInArray;
        }

        balanceOfVar[_from] = balanceOfVar[_from] - 1;
        balanceOfVar[_to] = balanceOfVar[_to] + 1;

    }


    function transferFromInternal(address _from, address _to, uint256 _tokenId, address _sender, uint256 _value) internal{


        require(_value >= transferFees[_tokenId], 
            "The transfer fee must be paid");

        address owner = TheCryptographLogicV1(address(_tokenId)).owner();
        require(owner == _from,
            "The owner of the token and _from did not match");

        require(_sender == owner || approvedOperator[owner][_sender] || approvedTransferAddress[_tokenId] == _sender, "The caller is not allowed to transfer the token");

        uint256 leftover = _value - transferFees[_tokenId];

        transferACryptographInternal(_from, _to, address(_tokenId), lastSoldFor[_tokenId]);

        AuctionHouseLogicV1(auctionHouse).transferERC2665{value:  _value - leftover}(address(_tokenId), _sender, _to);

        if(leftover >= transferFees[_tokenId]){
            leftover =  leftover - transferFees[_tokenId];
            transferFees[_tokenId] = 0;
        }

        if(leftover != 0){
            (bool trashBool, ) = _sender.call{value:leftover}("");
            require(trashBool, "Could not send the leftover money back");
        }
    }


    function addressToString(address _addr) internal pure returns(string memory)
    {

        bytes32 addr32 = bytes32(uint256(_addr)); //Put the address 20 byte address in a bytes32 word
        bytes memory alphabet = "0123456789abcdef";  //What are our allowed characters ?

        bytes memory str = new bytes(42);

        str[0] = '0';
        str[1] = 'x';

        for (uint256 i = 0; i < 20; i++) { //iterating over the actual address

            str[2+i*2] = alphabet[uint8(addr32[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(addr32[i + 12] & 0x0f)];
        }
        return string(str);
    }

    function isContract(address _address) internal view returns(bool){

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(_address) }
        return (codehash != accountHash && codehash != 0x0);
    }
}
pragma solidity 0.6.6;

contract SingleAuctionHeaderV1 {

    event BidAccepted(uint256 bidValue, address indexed bidder);
    event Payout(uint256 amount, address indexed beneficiary, address indexed contributor);
    event BidCancelled(uint256 bidValue, uint256 ethReturned, address indexed bidder);
    event SaleStarted(address indexed seller, uint256 hammerTime, uint256 hammerBlock);
    event SellingPriceAdjusted(address indexed seller, uint256 amount);
    event Win(address indexed buyer, address indexed seller, uint256 bidValue);
}


contract SingleAuctionStorageInternalV1 {


    uint256 internal versionBid;


    mapping (address => uint) internal currentBids;

    mapping (address => uint) internal duePayout; //How much the bidder make

    address internal highestBidder;

    uint256 internal unsettledPayouts;

    uint256 internal startingPrice;

    uint256 internal sellingPrice;

    mapping (address => address) internal bidLinks;



    uint256 internal bid_Decimals; //100k, or 100%
    uint256 internal bid_incMax; //10k, or 10%
    uint256 internal bid_incMin; //1k, or 1%
    uint256 internal bid_stepMin; // 10.5k, or 10.5%
    uint256 internal bid_cutOthers; // 500, or 0.5%

    uint256 internal bid_multiplier; //Will be divided by 100 for the calulations. 100 means that doubling the bid leads to 1% extra return

    uint256 internal sale_fee; //Proportion of the bid_Decimals taken as a selling fee. 10% = 10k



    address internal publisher; //The address of the publisher of the cryptograph. Can edit media url and hash.
    address internal charity; //The address to which the chartity cut is being sent to. No special rights.
    address internal thirdParty; //The address of any third party taking a cut. No special rights.
    address internal perpertualAltruism;

    uint256 internal publisherCut;
    uint256 internal charityCut;
    uint256 internal thirdPartyCut;
    uint256 internal perpetualAltruismCut;

    uint256 internal startTime; //The start date of the initial auction
    uint256 internal endTime; //The end date of the initial auction

    uint256 internal hammerBlockDuration; //The minium number of blocks for which other bidder can come in after a winning offer
    uint256 internal hammerTimeDuration; //The  number of seconds for which other bidder can come in after a winning offer
    uint256 internal hammerBlock; //The block number after which a winning offer can claim a cryptograph
    uint256 internal hammerTime; //The date after which a winning offer can claim a cryptograph

    address internal auctionHouse; //The address of the auction house
    address internal myCryptograph; //The address of the Cryptograph I'm administrating
    address internal cryFactory; //The address of the cryptograph Factory

    bool internal initialized;
    bool internal isBeingERC2665Approved; //If set to true, a potential new owner has been approved in ERC2665

}


contract SingleAuctionStoragePublicV1 {


    uint256 internal versionBid;


    mapping (address => uint) public currentBids;

    mapping (address => uint) public duePayout; //How much the bidder make

    address public highestBidder;

    uint256 public unsettledPayouts;

    uint256 public startingPrice;

    uint256 public sellingPrice;

    mapping (address => address) public bidLinks;



    uint256 public bid_Decimals; //100k, or 100%
    uint256 public bid_incMax; //10k, or 10%
    uint256 public bid_incMin; //1k, or 1%
    uint256 public bid_stepMin; // 10.5k, or 10.5%
    uint256 public bid_cutOthers; // 500, or 0.5%

    uint256 public bid_multiplier; //Will be divided by 100 for the calulations. 100 mean that doubling the bid mean 1% extra return

    uint256 public sale_fee; //Proportion of the bid_Decimals taken as a selling fee. 10% = 10k


    address public publisher; //The address of the publisher of the cryptograph. Can edit media url and hash.
    address public charity; //The address to which the chartity cut is being sent to
    address public thirdParty; //The address of any third party taking a cut
    address public perpertualAltruism; //The perpetual altruism address

    uint256 public publisherCut;
    uint256 public charityCut;
    uint256 public thirdPartyCut;
    uint256 public perpetualAltruismCut;

    uint256 public startTime; //The start date of the initial auction
    uint256 public endTime; //The end date of the initial auction

    uint256 public hammerBlockDuration; //The minium number of blocks for which other bidder can come in after a winning offer
    uint256 public hammerTimeDuration; //The  number of seconds for which other bidder can come in after a winning offer
    uint256 public hammerBlock; //The block number after which a winning offer can claim a cryptograph
    uint256 public hammerTime; //The date after which a winning offer can claim a cryptograph

    address public auctionHouse; //The address of the auction house
    address public myCryptograph; //The address of the Cryptograph I'm administrating
    address public cryFactory; //The address of the cryptograph Factory

    bool public initialized;
    bool public isBeingERC2665Approved; //If set to true, a potential new owner has been approved in ERC2665
}

pragma solidity 0.6.6;

contract CryptographIndexHeaderV1 {

}

contract CryptographIndexStorageInternalV1 {

    bool internal initialized; //Bool to check if the index has been initialized
    address internal factory; //The factory smart contract (proxy) that will publish the cryptographs
    address[] internal cryptographs;
    address[] internal communityCryptographs;
    mapping (address => uint) internal editionSizes; //Set to 0 if unique (not edition)
    mapping (address => uint) internal cryptographType; //0 = Unique, 1 = Edition, 2 = Minting
    uint256 internal indexerLogicCodeIndex; //The index in the Version Control of the logic code

    address internal ERC2665Lieutenant;
}

contract CryptographIndexStoragePublicV1 {

    bool public initialized; //Bool to check if the index has been initialized
    address public factory; //The factory smart contract (proxy) that will publish the cryptographs
    address[] public cryptographs;
    address[] public communityCryptographs;
    mapping (address => uint) public editionSizes; //Set to 0 if unique (not edition)
    mapping (address => uint) public cryptographType; //0 = Unique, 1 = Edition, 2 = Minting
    uint256 public indexerLogicCodeIndex; //The index in the VC of the logic code

    address public ERC2665Lieutenant;
}

pragma solidity 0.6.6;

contract EditionIndexerHeaderV1 {

}


contract EditionIndexerStorageInternalV1 {

    bool internal initialized; //Bool to check if the indexer have been initialized
    address internal minter; //The address of the minter, the only person allowed to add new cryptographs
    address internal index; //The address of the index, the only address allowed to interact with the publishing functions
    uint256 internal editionSize; //The total amount of cryptographs to be minted in this edition
    address[] internal cryptographs;
}


contract EditionIndexerStoragePublicV1 {

    bool public initialized; //Bool to check if the index has been initialized
    address public minter; //The address of the minter, only person allowed to add new cryptographs
    address public index; //The address of the index, only address allowed to interact with the publishing functions
    uint256 public editionSize; //The total amount of cryptographs to be minted in this edition
    address[] public cryptographs;
}

pragma solidity 0.6.6;


contract EditionIndexerProxiedV1 is VCProxy, EditionIndexerHeaderV1, EditionIndexerStorageInternalV1  {


    constructor(uint256 _version, address _vc)  public
    VCProxy(_version, _vc) //Calls the VC proxy constructor so that we know where our logic code is
    {
    }


}



pragma solidity 0.6.6;


contract EditionIndexerLogicV1 is VCProxyData, EditionIndexerHeaderV1, EditionIndexerStoragePublicV1  {


    constructor() public
    {
    }

    modifier restrictedToIndex(){

        require((msg.sender == index), "Only the cryptograph index smart contract can call this function");
        _;
    }

    function init(address _index, address _minter, uint256 _editionSize) external returns(bool){

        require(!initialized, "This Edition Indexer has already been initialized");
        index = _index;
        minter = _minter;
        editionSize = _editionSize;
        initialized = true;
        cryptographs.push(address(0x0)); //There is no cryptograph edition with serial 0
        return true;
    }

    function init0(address _index, address _minter, uint256 _editionSize) external returns(bool){

        require(!initialized, "This Edition Indexer has already been initialized");
        index = _index;
        minter = _minter;
        editionSize = _editionSize;
        initialized = true;
        return true;
    }

    function insertACryptograph(address _cryptograph, address _minter) external restrictedToIndex() returns(uint){

        require(cryptographs.length <= editionSize, "The full amount of Cryptographs for this edition has been published");
        require(_minter == minter, "Only the publisher can mint new Cryptographs for this edition");
        cryptographs.push(_cryptograph);
        return (cryptographs.length - 1); //Inserting the cryptograph and returning the position in the array
    }

    function insertACryptographAt(address _cryptograph, uint256 _index) external restrictedToIndex(){


        if(cryptographs.length <= _index){
            while(cryptographs.length <= _index){
                cryptographs.push();
            }
        }
        cryptographs[_index] = _cryptograph; //Inserting the cryptograph
    }

}

pragma solidity 0.6.6;


contract CryptographIndexLogicV1 is VCProxyData, CryptographIndexHeaderV1, CryptographIndexStoragePublicV1  {


    constructor() public
    {
    }

    modifier restrictedToFactory(){

        require((msg.sender == factory), "Only the cryptograph factory smart contract can call this function");
        _;
    }

    function init(address _factory, uint256 _indexerLogicCodeIndex, address _ERC2665Lieutenant) external returns(bool){

        require(!initialized, "The cryptograph index has already been initialized");
        factory = _factory;
        indexerLogicCodeIndex = _indexerLogicCodeIndex;
        initialized = true;
        cryptographs.push(address(0x0));
        communityCryptographs.push(address(0x0));
        ERC2665Lieutenant = _ERC2665Lieutenant;
        return true;
    }


    function insertACryptograph(address _cryptograph) external restrictedToFactory() returns(uint){


        ERC2665LogicV1(ERC2665Lieutenant).MintACryptograph(_cryptograph);
        cryptographs.push(_cryptograph);
        return (cryptographs.length - 1); //Inserting the cryptograph and returning the position in the array
    }


    function insertACommunityCryptograph(address _communityCryptograph) external restrictedToFactory() returns(uint){


        ERC2665LogicV1(ERC2665Lieutenant).MintACryptograph(_communityCryptograph);

        communityCryptographs.push(_communityCryptograph);
        return (communityCryptographs.length - 1); //Inserting the community cryptograph and returning new position in array
    }


    function createAnEdition(address _minter, uint256 _editionSize) external restrictedToFactory() returns(uint){

        require(_minter != address(0) && _editionSize != 0,
            "Minter address and edition size must be greater than 0"
        );

        EditionIndexerProxiedV1 _proxied = new EditionIndexerProxiedV1(indexerLogicCodeIndex, vc);

        EditionIndexerLogicV1(address(_proxied)).init(address(this), _minter, _editionSize);

        editionSizes[address(_proxied)] = _editionSize;

        cryptographType[address(_proxied)] = 1;

        cryptographs.push(address(_proxied));
        return (cryptographs.length - 1);
    }


    function createAGGBMA(address _minter, uint256 _editionSize) external restrictedToFactory() returns(uint){

        require(_minter != address(0) && _editionSize != 0,
            "Minter address and edition size must be greater than 0"
        );

        EditionIndexerProxiedV1 _proxied = new EditionIndexerProxiedV1(indexerLogicCodeIndex, vc);

        EditionIndexerLogicV1(address(_proxied)).init0(address(this), _minter, _editionSize+1);

        editionSizes[address(_proxied)] = _editionSize;

        cryptographType[address(_proxied)] = 1;

        cryptographs.push(address(_proxied));
        return (cryptographs.length - 1);
    }


    function createACommunityEdition(address _minter, uint256 _editionSize) external restrictedToFactory() returns(uint){

        EditionIndexerProxiedV1 _proxied = new EditionIndexerProxiedV1(indexerLogicCodeIndex, vc);

        EditionIndexerLogicV1(address(_proxied)).init(address(this), _minter, _editionSize);

        editionSizes[address(_proxied)] = _editionSize;

        cryptographType[address(_proxied)] = 1;

        communityCryptographs.push(address(_proxied));
        return (communityCryptographs.length - 1);
    }


    function createACommunityGGBMA(address _minter, uint256 _editionSize) external restrictedToFactory() returns(uint){

        EditionIndexerProxiedV1 _proxied = new EditionIndexerProxiedV1(indexerLogicCodeIndex, vc);

        EditionIndexerLogicV1(address(_proxied)).init0(address(this), _minter, _editionSize+1); //One more for the prototype

        editionSizes[address(_proxied)] = _editionSize;

        cryptographType[address(_proxied)] = 1;

        communityCryptographs.push(address(_proxied));
        return (communityCryptographs.length - 1);
    }


    function mintAnEdition(
        address _minter,
        uint256 _cryptographIssue,
        bool _isOfficial,
        address _cryptograph
    ) external restrictedToFactory() returns(uint){



        ERC2665LogicV1(ERC2665Lieutenant).MintACryptograph(_cryptograph);

        cryptographType[_cryptograph] = 1;

        if(_isOfficial){
            uint256 edIdx = EditionIndexerLogicV1(cryptographs[_cryptographIssue]).insertACryptograph(_cryptograph, _minter);
            return edIdx;
        } else {
            uint256 edIdx = EditionIndexerLogicV1(communityCryptographs[_cryptographIssue]).insertACryptograph(_cryptograph, _minter);
            return edIdx;
        }
    }


    function mintAnEditionAt(
        uint256 _cryptographIssue,
        uint256 _cryptographSerial,
        bool _isOfficial,
        address _cryptograph
    ) external restrictedToFactory(){



        ERC2665LogicV1(ERC2665Lieutenant).MintACryptograph(_cryptograph);

        cryptographType[_cryptograph] = 1;

        if(_isOfficial){
            EditionIndexerLogicV1(cryptographs[_cryptographIssue]).insertACryptographAt(_cryptograph, _cryptographSerial);
        } else {
            EditionIndexerLogicV1(communityCryptographs[_cryptographIssue]).insertACryptographAt(_cryptograph, _cryptographSerial);
        }
    }


    function getCryptograph(uint256 _cryptographIssue, bool _isOfficial, uint256 _editionSerial) external view returns(address){

        if(_isOfficial){
            if(cryptographType[address(cryptographs[_cryptographIssue])] == 0){
                return(address(cryptographs[_cryptographIssue]));
            } else {
                return(address(EditionIndexerLogicV1(cryptographs[_cryptographIssue]).cryptographs(_editionSerial)));
            }
        } else {
            if(cryptographType[address(communityCryptographs[_cryptographIssue])] == 0){
                return(address(communityCryptographs[_cryptographIssue]));
            } else {
                return(address(EditionIndexerLogicV1(communityCryptographs[_cryptographIssue]).cryptographs(_editionSerial)));
            }
        }
    }

}

pragma solidity 0.6.6;


contract TheCryptographProxiedV1 is VCProxy, TheCryptographHeaderV1, TheCryptographStorageInternalV1  {


    constructor(uint256 _version, address _vc)  public
    VCProxy(_version, _vc) //Call the VC proxy constructor so that we know where our logic code is
    {
    }


}




pragma solidity 0.6.6;


contract SingleAuctionProxiedV1 is VCProxy, SingleAuctionHeaderV1, SingleAuctionStorageInternalV1  {


    constructor(uint256 _version, address _vc, uint256 _versionBid)  public
    VCProxy(_version, _vc) //Call the VC proxy constructor so that we know where our logic code is
    {
        versionBid = _versionBid;
    }

    function bid(uint256 , address) external payable {


        address addr = VersionControlStoragePublic(vc).code(versionBid);
        assembly {
            let freememstart := mload(0x40)
            calldatacopy(freememstart, 0, calldatasize())
            let success := delegatecall(not(0), addr, freememstart, calldatasize(), freememstart, 0)
            returndatacopy(freememstart, 0, returndatasize())
            switch success
            case 0 { revert(freememstart, returndatasize()) }
            default { return(freememstart, returndatasize()) }
        }
    }


}


pragma solidity 0.6.6;

contract MintingAuctionHeaderV1 {

    event BidAccepted(uint256 bidValue, address bidder);
    event Payout(uint256 amount, address beneficiary, address contributor);
    event BidCancelled(uint256 bidValue, uint256 ethReturned, address bidder);
    event SaleStarted(address seller, uint256 hammerTime, uint256 hammerBlock);
    event SellingPriceAdjusted(address seller, uint256 amount);
    event Win(address buyer, address seller, uint256 bidValue);
}


contract MintingAuctionStorageInternalV1 {



    mapping (address => uint) internal currentBids;

    mapping (address => uint) internal duePayout; //How much the bidder make

    address internal highestBidder;

    uint256 internal unsettledPayouts;

    uint256 internal startingPrice;

    uint256 internal sellingPrice;



    uint256 internal bid_Decimals; //100k, or 100%
    uint256 internal bid_incMax; //4.5k, or 4.5%
    uint256 internal bid_incMin; //1k, or 1%
    uint256 internal bid_stepMin; //5k, or 5%
    uint256 internal bid_cutOthers; // 500, or 0.5%

    uint256 internal bid_multiplier; //Will be divided by 100 for the calulations. 100 mean that doubling the bid mean 1% extra return


    address internal publisher; //The address of the publisher of the cryptograph. Can edit media url and hash.
    address internal charity; //The address to which the chartity cut is being sent to
    address internal thirdParty; //The address of any third party taking a cut
    address internal perpertualAltruism; //The perpetual altruism address

    uint256 internal publisherCut;
    uint256 internal charityCut;
    uint256 internal thirdPartyCut;
    uint256 internal perpetualAltruismCut;

    uint256 internal startTime; //The start date of the initial auction
    uint256 internal endTime; //The end date of the initial auction

    address internal auctionHouse; //The address of the auction house
    address internal myCryptograph; //The address of the Cryptograph I'm administrating
    address internal cryFactory; //The address of the cryptograph Factory

    bool internal initialized;

    mapping (address => address) internal bidLinks;

    address internal initiator; //We keep the address of our initator for future minting

    uint256 internal numberOfBids; //Current number of standing bids
    uint256 internal maxSupply; //Maximum number of bid to keep
    address internal tailBidder; //The address of the current bottom bidder
}


contract MintingAuctionStoragePublicV1 {


    mapping (address => uint) public currentBids;

    mapping (address => uint) public duePayout; //How much the bidder make

    address public highestBidder;

    uint256 public unsettledPayouts;

    uint256 public startingPrice;

    uint256 public sellingPrice;



    uint256 public bid_Decimals; //100k, or 100%
    uint256 public bid_incMax; //4.5k, or 4.5%
    uint256 public bid_incMin; //1k, or 1%
    uint256 public bid_stepMin; //5k, or 5%
    uint256 public bid_cutOthers; // 500, or 0.5%

    uint256 public bid_multiplier; //Will be divided by 100 for the calulations. 100 mean that doubling the bid mean 1% extra return


    address public publisher; //The address of the publisher of the cryptograph. Can edit media url and hash.
    address public charity; //The address to which the chartity cut is being sent to
    address public thirdParty; //The address of any third party taking a cut
    address public perpertualAltruism; //The perpetual altruism address

    uint256 public publisherCut;
    uint256 public charityCut;
    uint256 public thirdPartyCut;
    uint256 public perpetualAltruismCut;

    uint256 public startTime; //The start date of the initial auction
    uint256 public endTime; //The end date of the initial auction

    address public auctionHouse; //The address of the auction house
    address public myCryptograph; //The address of the Cryptograph I'm administrating
    address public cryFactory; //The address of the cryptograph Factory

    bool public initialized;

    mapping (address => address) public bidLinks;

    address public initiator; //We keep the address of our initator for future minting

    uint256 public numberOfBids; //Current number of standing bids
    uint256 public maxSupply; //Maximum number of bids to keep
    address public tailBidder; //The address of the current bottom bidder

}

pragma solidity 0.6.6;

contract CryptographInitiator{

    address public owner; // The desired owner of the Cryptograph
    string public name; // The desired name of the Cryptograph
    string public creator; // The desired creatpr of the Cryptograph
    uint256 public auctionStartTime; //The desired unix (seconds) timestamp at which the initial auction should start
    uint256 public auctionSecondsDuration; // The duration in seconds of the initial auction
    address public publisher; // The address of the publisher. Can edit media url and hash for a cryptograph.
    uint256 public publisherCut; // How much out of 100k parts of profits should the publisher get. e.g. publisherCut = 25000 means 1/4
    address public charity; // The address of the charity
    uint256 public charityCut; // The charity cut out of 100k
    address public thirdParty; // The address of a third party
    uint256 public thirdPartyCut; // The third party cut out of 100k
    uint256 public perpetualAltruismCut; // Will always be set to 25k except very special occasions.
    uint256 public maxSupply; // How many of these cryptographs should be minted maximum
    uint256 public startingPrice; // The Starting price of the auction
    uint256 public cryptographIssue; // The desired issue of the cryptograph (only for editions)
    string public mediaHash; // The desired media hash of the cryptograph
    string public mediaUrl; // The desired media url of the cryptograph

    constructor (
                string memory _name,
                uint256 _auctionStartTime,
                uint256 _auctionSecondsDuration,
                address _publisher,
                uint256 _publisherCut,
                address _charity,
                uint256 _charityCut,
                address _thirdParty,
                uint256 _thirdPartyCut,
                uint256 _perpetualAltruismCut,
                uint256 _maxSupply,
                uint256 _startingPrice,
                uint256 _cryptographIssue
    ) public{
        owner = msg.sender;
        name = _name;
        auctionStartTime = _auctionStartTime;
        auctionSecondsDuration = _auctionSecondsDuration;
        publisher = _publisher;
        publisherCut = _publisherCut;
        charity = _charity;
        charityCut = _charityCut;
        thirdParty = _thirdParty;
        thirdPartyCut = _thirdPartyCut;
        perpetualAltruismCut = _perpetualAltruismCut;
        maxSupply = _maxSupply;
        startingPrice = _startingPrice;
        cryptographIssue = _cryptographIssue;

    }

    modifier restrictedToOwner(){

        require((msg.sender == owner), "Only the creator of this Contract can modify its memory");
        _;
    }

    function setName(string calldata _name) external restrictedToOwner(){

        name = _name;
    }

    function setAuctionStartTime(uint256 _auctionStartTime) external restrictedToOwner(){

        auctionStartTime = _auctionStartTime;
    }

    function setAuctionSecondsDuration(uint256 _auctionSecondsDuration) external restrictedToOwner(){

        auctionSecondsDuration = _auctionSecondsDuration;
    }

    function setPublisher(address _publisher) external restrictedToOwner(){

        publisher = _publisher;
    }

    function setPublisherCut(uint256 _publisherCut) external restrictedToOwner(){

        publisherCut = _publisherCut;
    }

    function setCharity(address _charity) external restrictedToOwner(){

        charity = _charity;
    }

    function setCharityCut(uint256 _charityCut) external restrictedToOwner(){

        charityCut = _charityCut;
    }

    function setThirdParty(address _thirdParty) external restrictedToOwner(){

        thirdParty = _thirdParty;
    }

    function setThirdPartyCut(uint256 _thirdPartyCut) external restrictedToOwner(){

        thirdPartyCut = _thirdPartyCut;
    }

    function setPerpetualAltruismCut(uint256 _perpetualAltruismCut) external restrictedToOwner(){

        perpetualAltruismCut = _perpetualAltruismCut;
    }

    function setMaxSupply(uint256 _maxSupply) external restrictedToOwner(){

        maxSupply = _maxSupply;
    }

    function setStartingPrice(uint256 _startingPrice) external restrictedToOwner(){

        startingPrice = _startingPrice;
    }

    function setCryptographIssue(uint256 _cryptographIssue) external restrictedToOwner(){

        cryptographIssue = _cryptographIssue;
    }

    function setMediaHash(string calldata _mediahash) external restrictedToOwner(){

        mediaHash = _mediahash;
    }

    function setMediaUrl(string calldata _mediaUrl) external restrictedToOwner(){

        mediaUrl = _mediaUrl;
    }

    function setCreator(string calldata _creator) external restrictedToOwner(){

        creator = _creator;
    }

}// © Copyright 2020. Patent pending. All rights reserved. Perpetual Altruism Ltd.
pragma solidity 0.6.6;

contract BidLink{


    address public mintingAuction; //The Minting auction the BidLink is associated with
    address public bidder; //Our bidder
    uint256 public bidAmount; //How big is our bid
    address public above;  //BidLink with a bigger bid
    address public below;  //BidLink with a smaller bid

    modifier restrictedToAuction(){

        require((msg.sender == mintingAuction), "Only the auction contract can call this function");
        _;
    }

    constructor (address _bidder, uint256 _bidAmount) public
    {
        mintingAuction = msg.sender;
        bidder = _bidder;
        bidAmount = _bidAmount;
    }

    function reset(address _bidder, uint256 _bidAmount) external restrictedToAuction(){

        delete above;
        delete below;
        bidder = _bidder;
        bidAmount = _bidAmount;
    }

    function setBidAmount(uint256 _bidAmount) external restrictedToAuction(){

        bidAmount = _bidAmount;
    }

    function setAbove(address _above) external restrictedToAuction(){

        above = _above;
    }

    function setBelow(address _below) external restrictedToAuction(){

        below = _below;
    }

}
pragma solidity 0.6.6;



contract MintingAuctionLogicV1 is VCProxyData, MintingAuctionHeaderV1, MintingAuctionStoragePublicV1 {


    constructor() public
    {
    }

    modifier restrictedToAuctionHouse(){

        require((msg.sender == auctionHouse), "Only the auction house smart contract can call this function");
        _;
    }

    function initAuction(
            address _myCryptograph,
            address _cryInitiator,
            bool _initialize
        ) public {


        require(!initialized, "This auction is already initialized");
        initialized = _initialize; //Are we locking ?

        require(auctionHouse == address(0) || msg.sender == cryFactory,"Only Perpetual altruism can change a yet to be locked auction");
        cryFactory = msg.sender;


        startingPrice = CryptographInitiator(_cryInitiator).startingPrice(); //The first bid that needs to be outbid is 1 Wei
        sellingPrice = 0; //A newly minted Cryptograph does not have an owner willing to sell

        bid_Decimals = 100000;  //100k, or 100%
        bid_incMax = 10000; //10k, or 10%
        bid_incMin = 1000; //1k, or 1%
        bid_stepMin = 10500; //10.5k, or 10.5%
        bid_cutOthers = 500; // 500, or 0.5%
        bid_multiplier = 9000; //9000 = Doubling bid yield max gain (1%+9% = 10%)

        perpertualAltruism = CryptographFactoryStoragePublicV1(cryFactory).officialPublisher();
        perpetualAltruismCut = CryptographInitiator(_cryInitiator).perpetualAltruismCut();
        publisher = CryptographInitiator(_cryInitiator).publisher();
        publisherCut = CryptographInitiator(_cryInitiator).publisherCut();
        charity = CryptographInitiator(_cryInitiator).charity();
        charityCut = CryptographInitiator(_cryInitiator).charityCut();
        thirdParty = CryptographInitiator(_cryInitiator).thirdParty();
        thirdPartyCut = CryptographInitiator(_cryInitiator).thirdPartyCut();
        maxSupply = CryptographInitiator(_cryInitiator).maxSupply();


        startTime = CryptographInitiator(_cryInitiator).auctionStartTime();
        endTime = CryptographInitiator(_cryInitiator).auctionStartTime() + CryptographInitiator(_cryInitiator).auctionSecondsDuration();

        auctionHouse = CryptographFactoryStoragePublicV1(cryFactory).targetAuctionHouse();
        myCryptograph = _myCryptograph;
        initiator = _cryInitiator;
    }

    function lock() external{

        require(msg.sender == cryFactory, "Only Perpetual altruism can lock the initialization");
        initialized = true;
    }

    function bid(uint256 _newBidAmount, address _newBidder) external payable restrictedToAuctionHouse(){



        require(initialized, "This auction has not been properly set up yet");
        require(_newBidAmount == msg.value + currentBids[_newBidder], "Amount of money sent incorrect"); //Also protects from self-underbiding
        require(numberOfBids != maxSupply || currentBids[tailBidder] < _newBidAmount, "Your bid is lower than the lowest bid");

        require( //Either fresh bid OR meeting the standing bid * the step OR below highest bidder
                    ( (highestBidder == address(0)) && startingPrice <= _newBidAmount ) ||
                    ( (highestBidder != address(0)) && (currentBids[highestBidder] * (bid_Decimals + bid_stepMin) <= (_newBidAmount * bid_Decimals) )) ||
                    (  (highestBidder != address(0)) && (currentBids[highestBidder] >= _newBidAmount) ),
                "New bid amount does not meet an authorized amount");


        require(now >= startTime, "You can only bid once the initial auction has started");
        require(now < endTime, "GGMBA do not allow bidding past the ending time");

        emit BidAccepted(_newBidAmount, _newBidder);


        uint256 duePay;
        if((currentBids[highestBidder] < _newBidAmount)){
            duePay = (_newBidAmount * bid_cutOthers)/bid_Decimals;
            unsettledPayouts += duePay;
            distributeStakeholdersPayouts(duePay, _newBidder);
            if(highestBidder != address(0)){
                duePay = duePayout[highestBidder];
                if(duePay != 0){
                    unsettledPayouts += duePay;
                    emit Payout(duePay,  highestBidder,  _newBidder);
                    AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: duePay }(highestBidder, _newBidder);
                }
            }


            calculateReward(_newBidAmount, _newBidder);
        }

        uint256 toSend;

        if(currentBids[_newBidder] != 0){

            BidLink(bidLinks[_newBidder]).setBidAmount(_newBidAmount); //Updating our bid amount

            if( BidLink(bidLinks[_newBidder]).above() != address(0x0)){
                BidLink(BidLink(bidLinks[_newBidder]).above()).setBelow(BidLink(bidLinks[_newBidder]).below()); //Unlinking above us
            }

            if( BidLink(bidLinks[_newBidder]).below() != address(0x0)){
                BidLink(BidLink(bidLinks[_newBidder]).below()).setAbove(BidLink(bidLinks[_newBidder]).above()); //Unlinking below us
            }
            emit BidCancelled(currentBids[_newBidder], currentBids[_newBidder], _newBidder); //Emitting the event

        } else {
            bidLinks[_newBidder] = address(new BidLink(_newBidder, _newBidAmount));

            if(numberOfBids == maxSupply && maxSupply != 0){
                toSend = currentBids[tailBidder];
                currentBids[tailBidder] = 0;
                if(toSend != 0){
                    emit BidCancelled(toSend, toSend, tailBidder);
                    AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(tailBidder, tailBidder);
                }
                BidLink(BidLink(bidLinks[tailBidder]).above()).setBelow(address(0x0)); //Unlinking
                tailBidder = BidLink(BidLink(bidLinks[tailBidder]).above()).bidder(); //Updating the tail


            } else {
                numberOfBids++;
            }
        }



        currentBids[_newBidder] = _newBidAmount; //Set the amount of the bid

        address currentLink = bidLinks[highestBidder];

        if(currentLink == address(0x0)){
            tailBidder = _newBidder; //We are the only bidder = we are also the lowest bidder
        } else {
            while( BidLink(currentLink).below() != address(0x0) && BidLink(BidLink(currentLink).below()).bidAmount() >= _newBidAmount){
                    currentLink = BidLink(currentLink).below(); //Browse the chain
            }
        }

        if(currentBids[highestBidder] < _newBidAmount){
            highestBidder = _newBidder; //We are the highest bidder
            BidLink(bidLinks[_newBidder]).setBelow(currentLink); //Setting ourselves as above the old head
            if(currentLink != address(0x0)){    //Only if there is a previous head
                BidLink(currentLink).setAbove(bidLinks[_newBidder]); //Setting the old head as below us
            }
        } else { //Normally inserting ourself in the chain
            BidLink(bidLinks[_newBidder]).setAbove(currentLink); //Above us is the current link
            BidLink(bidLinks[_newBidder]).setBelow(BidLink(currentLink).below()); //Below us is the previous tail of the current link
            if(BidLink(bidLinks[_newBidder]).below() != address(0x0)){  //If we have a new tail
                BidLink(BidLink(bidLinks[_newBidder]).below()).setAbove(bidLinks[_newBidder]); //We are above our new tail
            } else {
                tailBidder = _newBidder;
            }
            BidLink(BidLink(bidLinks[_newBidder]).above()).setBelow(bidLinks[_newBidder]); //Our new head has us as a tail
        }


    }

    function win(address _newOwner) external restrictedToAuctionHouse() view returns(uint){

        require(currentBids[_newOwner] != 0, "You don't have any active bid on this auction");
        require(now > endTime, "The initial auction is not over yet");

        return 1;
    }

    function distributeBid(address _newOwner) external restrictedToAuctionHouse(){


         if(_newOwner == highestBidder){
            distributeStakeholdersPayouts(currentBids[highestBidder] - unsettledPayouts, _newOwner); //Payouts are deduced from the highest bid
        } else {
            distributeStakeholdersPayouts(currentBids[_newOwner], _newOwner);
        }

        currentBids[_newOwner] = 0;
    }

    function distributeStakeholdersPayouts(uint256 _amount, address _contributor) internal{

        uint256 toDistribute = _amount;
        uint256 toSend;

        toSend = (charityCut * _amount) / bid_Decimals;
        toDistribute -= toSend;
        if(toSend != 0){
            emit Payout(toSend,  charity,  _contributor);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(charity, _contributor);
        }

        toSend = (publisherCut * _amount) / bid_Decimals;
        toDistribute -= toSend;
        if(toSend != 0){
            emit Payout(toSend,  publisher,  _contributor);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(publisher, _contributor);
        }

        toSend = (thirdPartyCut * _amount) / bid_Decimals;
        toDistribute -= toSend;
        if(toSend != 0){
            emit Payout(toSend,  thirdParty,  _contributor);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(thirdParty, _contributor);
        }

        toSend = toDistribute;
        if(toSend != 0){
            emit Payout(toSend,  perpertualAltruism,  _contributor);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(perpertualAltruism, _contributor);
        }
    }

    function calculateReward(uint256 _newBid, address _bidder) internal{



        uint256 baseBid = currentBids[highestBidder] * (bid_Decimals + bid_stepMin) / bid_Decimals;
        if(baseBid == 0){
            baseBid = startingPrice;

            if(baseBid == 0){
                baseBid = 1;
            }
        }

        uint256 decimaledRatio = ((bid_Decimals * bid_multiplier * (_newBid - baseBid) ) / baseBid) + bid_incMin * bid_Decimals;

        if(decimaledRatio > (bid_Decimals * bid_incMax)){
            decimaledRatio = bid_Decimals * bid_incMax;
        }

        duePayout[_bidder] = (_newBid * decimaledRatio)/(bid_Decimals*bid_Decimals);
    }
}
pragma solidity 0.6.6;


contract MintingAuctionProxiedV1 is VCProxy, MintingAuctionHeaderV1, MintingAuctionStorageInternalV1  {


    constructor(uint256 _version, address _vc)  public
    VCProxy(_version, _vc) //Call the VC proxy constructor so that we know where our logic code is
    {
    }

}

pragma solidity 0.6.6;


contract CryptographFactoryLogicV1 is VCProxyData, CryptographFactoryHeaderV1, CryptographFactoryStoragePublicV1 {


    constructor() public
    {
    }

    function init(
        address _officialPublisher,
        address _targetVC,
        address _targetAuctionHouse,
        address _targetIndex,
        uint256 _targetCryLogicVersion,
        uint256 _targetAuctionLogicVersion,
        uint256 _targetAuctionBidLogicVersion,
        uint256 _targetMintingAuctionLogicVersion
    ) external {


        require(!initialized, "The Cryptograph Factory has already been initialized");
        initialized = true;
        officialPublisher = _officialPublisher;
        targetVC = _targetVC;
        targetAuctionHouse = _targetAuctionHouse;
        targetIndex = _targetIndex;
        targetCryLogicVersion = _targetCryLogicVersion;
        targetAuctionLogicVersion = _targetAuctionLogicVersion;
        targetAuctionBidLogicVersion = _targetAuctionBidLogicVersion;
        targetMintingAuctionLogicVersion = _targetMintingAuctionLogicVersion;
        communityMintable = false;
    }

    function createCryptograph (address _cryInitiator) external returns (uint256){

        bool offi = msg.sender == officialPublisher;

        require(communityMintable || offi, "Community Cryptographs can't be created at the moment");

        address newCryptographProxied;
        address newSingleAuctionProxiedV1;
        (newCryptographProxied, newSingleAuctionProxiedV1) = instanceCryptograph(_cryInitiator, offi);

        uint256 _issue;
        if(offi){
            _issue = CryptographIndexLogicV1(targetIndex).insertACryptograph(newCryptographProxied);
        } else {
            _issue = CryptographIndexLogicV1(targetIndex).insertACommunityCryptograph(newCryptographProxied);
        }

        TheCryptographLogicV1(newCryptographProxied).initCry(
                _issue, 0, offi, newSingleAuctionProxiedV1, _cryInitiator, address(0)
            );

        TheCryptographLogicV1(newCryptographProxied).setMediaHash(
            CryptographInitiator(_cryInitiator).mediaHash()
        );
        TheCryptographLogicV1(newCryptographProxied).setMediaUrl(
            CryptographInitiator(_cryInitiator).mediaUrl()
        );

        emit CryptographCreated(_issue, newCryptographProxied, offi);
        return _issue;
    }

    function createEdition(uint256 _editionSize) external returns (uint256){


        uint256 _issue;

        bool offi = msg.sender == officialPublisher;

        require(communityMintable || offi, "community Cryptographs can't be created at the moment");

        if(offi){
            _issue = CryptographIndexLogicV1(targetIndex).createAnEdition(msg.sender, _editionSize);
        } else {
            _issue = CryptographIndexLogicV1(targetIndex).createACommunityEdition(msg.sender, _editionSize);
        }
        emit CryptographEditionAdded(_issue, _editionSize, offi);
        return _issue;
    }

    function mintEdition (address _cryInitiator) external returns (uint256){

        bool offi = msg.sender == officialPublisher;

        uint256 _issue = CryptographInitiator(_cryInitiator).cryptographIssue();

        require(
            CryptographIndexLogicV1(targetIndex).getCryptograph(_issue, offi, 0) == address(0x0),
            "Can't manually mint a GGBMA");

        address newCryptographProxied;
        address newSingleAuctionProxiedV1;
        (newCryptographProxied, newSingleAuctionProxiedV1) = instanceCryptograph(_cryInitiator, offi);

        uint256 _editionSerial;
        _editionSerial = CryptographIndexLogicV1(targetIndex).mintAnEdition(
            msg.sender,
            _issue,
            offi,
            address(newCryptographProxied)
        );

        TheCryptographLogicV1(address(newCryptographProxied)).initCry(
            _issue, _editionSerial, offi, address(newSingleAuctionProxiedV1), _cryInitiator, address(0)
        );
        emit CryptographEditionMinted(
            _issue,
            _editionSerial,
            newCryptographProxied,
            offi
        );

        TheCryptographLogicV1(newCryptographProxied).setMediaHash(
            CryptographInitiator(_cryInitiator).mediaHash()
        );
        TheCryptographLogicV1(newCryptographProxied).setMediaUrl(
            CryptographInitiator(_cryInitiator).mediaUrl()
        );

        return _editionSerial;
    }


    function reInitCryptograph(address _CryptographToEdit, address _cryInitiator)  external {

        require(msg.sender == officialPublisher, "Only official Cryptographs can be edited after serial # reservation");
        TheCryptographLogicV1(_CryptographToEdit).initCry(
            TheCryptographLogicV1(_CryptographToEdit).issue(),
            TheCryptographLogicV1(_CryptographToEdit).serial(),
            true,
            TheCryptographLogicV1(_CryptographToEdit).myAuction(),
            _cryInitiator,
            address(0)
        );
    }


    function reInitAuction(
        address _auctionToEdit,
        address _cryInitiator,
        bool _lock
    ) external {

        require(msg.sender == officialPublisher, "Only PA can reinit auctions");

        SingleAuctionLogicV1(_auctionToEdit).initAuction(
            SingleAuctionLogicV1(_auctionToEdit).myCryptograph(),
            _cryInitiator,
            _lock
        );
    }

    function lockAuction(uint256 _cryptographIssue, uint256 _editionSerial) external {

        require(msg.sender == officialPublisher, "Only Perpetual Altruism can lock an auction");
        SingleAuctionLogicV1(
            TheCryptographLogicV1(
                CryptographIndexLogicV1(targetIndex).getCryptograph(
                    _cryptographIssue, true, _editionSerial)
            ).myAuction()
        ).lock();
    }

    function setMediaHash(uint256 _cryptographIssue, uint256 _editionSerial, string calldata _mediaHash) external{

        TheCryptographLogicV1 _cry = TheCryptographLogicV1(CryptographIndexLogicV1(targetIndex).getCryptograph(
                    _cryptographIssue, true, _editionSerial)
            );
        require(msg.sender == SingleAuctionLogicV1(_cry.myAuction()).publisher(),
            "Only the publisher of a Cryptograph can edit its media hash"
        );

        _cry.setMediaHash(_mediaHash);
    }

    function setMediaUrl(uint256 _cryptographIssue, uint256 _editionSerial, string calldata _mediaUrl) external{

        TheCryptographLogicV1 _cry = TheCryptographLogicV1(CryptographIndexLogicV1(targetIndex).getCryptograph(
                    _cryptographIssue, true, _editionSerial)
            );
        require(msg.sender == SingleAuctionLogicV1(_cry.myAuction()).publisher(), "Only the publisher of a Cryptograph can edit its media URL");

        _cry.setMediaUrl(_mediaUrl);
    }

    function instanceCryptograph( address _cryInitiator, bool _official) internal returns (address, address){


        TheCryptographProxiedV1 newCryptographProxied = new TheCryptographProxiedV1(targetCryLogicVersion, targetVC);

        SingleAuctionProxiedV1 newSingleAuctionProxiedV1 = new SingleAuctionProxiedV1(targetAuctionLogicVersion, targetVC, targetAuctionBidLogicVersion);

        SingleAuctionLogicV1(address(newSingleAuctionProxiedV1)).initAuction(
            address(newCryptographProxied),
            _cryInitiator,
            !_official //Will lock the auction setup if not an official Cryptograph
        );


        if(!_official){
                assert(SingleAuctionLogicV1(address(newSingleAuctionProxiedV1)).perpetualAltruismCut() >= 25000);
            }

        assert(
            SingleAuctionLogicV1(address(newSingleAuctionProxiedV1)).perpetualAltruismCut() +
            SingleAuctionLogicV1(address(newSingleAuctionProxiedV1)).publisherCut() +
            SingleAuctionLogicV1(address(newSingleAuctionProxiedV1)).charityCut() +
            SingleAuctionLogicV1(address(newSingleAuctionProxiedV1)).thirdPartyCut() == 100000
            );

        assert(SingleAuctionLogicV1(address(newSingleAuctionProxiedV1)).startTime() <=
        SingleAuctionLogicV1(address(newSingleAuctionProxiedV1)).endTime());

        return (address(newCryptographProxied), address(newSingleAuctionProxiedV1));

    }



    function createGGBMA (address _cryInitiator) external returns (uint256){

        require(false, "GGBMA creation is disabled for launch, they will need an update approved by the senate");

        uint256 _issue; //The issue # we will get

        bool offi = msg.sender == officialPublisher;

        require(communityMintable || offi, "community Cryptographs can't be created at the moment");

        if(offi){
            _issue = CryptographIndexLogicV1(targetIndex).createAGGBMA(msg.sender, CryptographInitiator(_cryInitiator).maxSupply());
        } else {
            _issue = CryptographIndexLogicV1(targetIndex).createACommunityGGBMA(msg.sender, CryptographInitiator(_cryInitiator).maxSupply());
        }
        emit CryptographEditionAdded(_issue, CryptographInitiator(_cryInitiator).maxSupply(), offi);

        address newCryptographProxied;
        address newMintingAuctionProxiedV1;
        (newCryptographProxied, newMintingAuctionProxiedV1) = instanceCryptographGGBMA(_cryInitiator, _issue);


        CryptographIndexLogicV1(targetIndex).mintAnEditionAt(
            _issue,
            0,
            offi,
            address(newCryptographProxied)
        );

        emit CryptographCreated(_issue, newCryptographProxied, offi);
        mintingAuctionSupply[newMintingAuctionProxiedV1] = CryptographInitiator(_cryInitiator).maxSupply();

        return _issue;
    }

    function instanceCryptographGGBMA(address _cryInitiator, uint256 _issue) internal returns (address, address){



        bool _official; //Set to false by default
        if(msg.sender == officialPublisher){
            _official = true;
        }

        require(communityMintable || _official, "community Cryptographs can't be created at the moment");

        address newCryptographProxied = address(new TheCryptographProxiedV1(targetCryLogicVersion, targetVC));

        address newMintingAuctionProxiedV1 = address(new MintingAuctionProxiedV1(targetMintingAuctionLogicVersion, targetVC));


        TheCryptographLogicV1(address(newCryptographProxied)).initCry(
                _issue, 0, _official, newMintingAuctionProxiedV1, _cryInitiator, address(0)
            );

        MintingAuctionLogicV1(address(newMintingAuctionProxiedV1)).initAuction(
            newCryptographProxied,
            _cryInitiator,
            !_official //Will lock the auction setup if not an official Cryptograph
        );

        TheCryptographLogicV1(newCryptographProxied).setMediaHash(
            CryptographInitiator(_cryInitiator).mediaHash()
        );
        TheCryptographLogicV1(newCryptographProxied).setMediaUrl(
            CryptographInitiator(_cryInitiator).mediaUrl()
        );

        if(!_official){
                assert(MintingAuctionLogicV1(address(newMintingAuctionProxiedV1)).perpetualAltruismCut() >= 25000);
            }

        assert(
            MintingAuctionLogicV1(address(newMintingAuctionProxiedV1)).perpetualAltruismCut() +
            MintingAuctionLogicV1(address(newMintingAuctionProxiedV1)).publisherCut() +
            MintingAuctionLogicV1(address(newMintingAuctionProxiedV1)).charityCut() +
            MintingAuctionLogicV1(address(newMintingAuctionProxiedV1)).thirdPartyCut() == 100000
            );

        assert(MintingAuctionLogicV1(address(newMintingAuctionProxiedV1)).startTime() <=
            MintingAuctionLogicV1(address(newMintingAuctionProxiedV1)).endTime());


        return (address(newCryptographProxied), address(newMintingAuctionProxiedV1));
    }

    function mintGGBMA(uint256 _issue, bool _isOfficial, address _winner) external returns(bool){

        require(msg.sender == targetAuctionHouse, "Only the auction house can ask the factory to mint new copies for a GGBMA");

        address _ggbma = TheCryptographLogicV1(
                CryptographIndexLogicV1(targetIndex).getCryptograph(_issue, _isOfficial, 0)
            ).myAuction();

        uint256 positionInAuction; //0

        address currentLink = MintingAuctionLogicV1(_ggbma).bidLinks(MintingAuctionLogicV1(_ggbma).highestBidder());
        bool stop = currentLink == address(0x0); //Do not even enter the loop if there is no highest bidder
        while(!stop){
            if(BidLink(currentLink).bidder() == _winner){
                positionInAuction++; //Increasing the count (serial # start at 1 while counter start at 0)
                stop = true;
            } else if(BidLink(currentLink).below() == address(0x0)){ //Checking if we have reached the bottom
                positionInAuction = 0; //We were not a bidder...
                stop = true;
            } else {
                positionInAuction++;
                currentLink = BidLink(currentLink).below();
            }
        }

        require(positionInAuction != 0, "Could not find your bid in this auction");

        require(MintingAuctionLogicV1(_ggbma).currentBids(_winner) != 0, "You already minted your cryptograph");


        address newCryptographProxied;
        address newSingleAuctionProxiedV1;
        address initiator = MintingAuctionLogicV1(_ggbma).initiator();

        (newCryptographProxied, newSingleAuctionProxiedV1) = instanceCryptograph(initiator, _isOfficial);

        CryptographIndexLogicV1(targetIndex).mintAnEditionAt(
            _issue, // Issue #
            positionInAuction, // Serial #
            _isOfficial,
            address(newCryptographProxied)
        );

        TheCryptographLogicV1(newCryptographProxied).initCry(
                _issue, positionInAuction, _isOfficial, newSingleAuctionProxiedV1, initiator, _winner
            );

        TheCryptographLogicV1(newCryptographProxied).setMediaHash(
            CryptographInitiator(initiator).mediaHash()
        );
        TheCryptographLogicV1(newCryptographProxied).setMediaUrl(
            CryptographInitiator(initiator).mediaUrl()
        );

        SingleAuctionLogicV1(newSingleAuctionProxiedV1).lock();
    }

    function setCommunityMintable(bool _communityMintable) external {


        require(msg.sender == officialPublisher, "Only Perpetual Altruism can set communityMintable");

        communityMintable = _communityMintable;
    }
}
pragma solidity 0.6.6;


contract CryptographKYCHeaderV1 {


    event KYCed(address indexed _user, bool indexed _isValid);

    event PriceLimit(uint256 indexed _newPrice);
}



contract CryptographKYCStorageInternalV1 {


    address internal perpetualAltruism;

    mapping(address => bool) internal authorizedOperators;

    uint256 internal priceLimit;

    mapping(address => bool) internal kycUsers;

}

contract CryptographKYCStoragePublicV1 {


    address public perpetualAltruism;

    mapping(address => bool) public authorizedOperators;

    uint256 public priceLimit;

    mapping(address => bool) public kycUsers;
}// © Copyright 2020. Patent pending. All rights reserved. Perpetual Altruism Ltd.
pragma solidity 0.6.6;


contract CryptographKYCLogicV1 is VCProxyData, CryptographKYCHeaderV1, CryptographKYCStoragePublicV1  {


    constructor() public
    {
    }

    modifier restrictedToOperators(){

        require((msg.sender == perpetualAltruism || authorizedOperators[msg.sender]), "Only operators can call this function");
        _;
    }

    function init() external {

        require(perpetualAltruism == address(0), "Already initalized");
        perpetualAltruism = msg.sender;
        priceLimit = uint256(0) - uint256(1);
        emit PriceLimit(priceLimit);
    }

    function setOperator(address _operator, bool _operating) external restrictedToOperators(){

        authorizedOperators[_operator] = _operating;
    }


    function setPriceLimit(uint256 _newPrice) external restrictedToOperators(){

        priceLimit = _newPrice;
        emit PriceLimit(_newPrice);
    }

    function setKyc(address _user, bool _kyc) external restrictedToOperators(){

        kycUsers[_user] = _kyc;
        emit KYCed(_user, _kyc);
    }


    function checkKyc(address _user, uint256 _amount) external view returns(bool){

        return (_amount <= priceLimit || kycUsers[_user]);
    }

}// © Copyright 2020. Patent pending. All rights reserved. Perpetual Altruism Ltd.
pragma solidity 0.6.6;



contract AuctionHouseLogicV1 is VCProxyData, AuctionHouseHeaderV1, AuctionHouseStoragePublicV1 {


    constructor() public
    {
    }

    modifier restrictedToFactory(){

        require((msg.sender == factory), "Only the Cryptograph Factory smart contract can call this function");
        _;
    }

    fallback() external payable {
        pendingWithdrawals[msg.sender] += msg.value;
        emit Deposit(msg.value,msg.sender, msg.sender, msg.sender);
    }

    receive() external payable{
        pendingWithdrawals[msg.sender] += msg.value;
        emit Deposit(msg.value,msg.sender, msg.sender, msg.sender);
    }

    function init(address _factory, address _index, address _ERC2665Lieutenant, address _kycContract) external {

        require((initialized == false), "The Auction House has already been initialized");
        require(_factory != address(0), "_factory should be != 0x0");
        require(_index != address(0), "_index should be != 0x0");
        require(_ERC2665Lieutenant != address(0), "_ERC2665Lieutenant should be != 0x0");
        require(_kycContract != address(0), "_kycContract should be != 0x0");
        
        initialized = true;
        factory = _factory;
        index = _index;
        ERC2665Lieutenant = _ERC2665Lieutenant;
        kycContract = _kycContract;
    }

    function addFundsFor(address _account, address _contributor) external payable{

        pendingWithdrawals[_account] += msg.value;
        emit Deposit(msg.value, _account, _contributor, msg.sender);
    }

    function withdraw() external {


        uint256 amount = pendingWithdrawals[msg.sender];

        pendingWithdrawals[msg.sender] = 0;

        emit UserWithdrawal(amount, msg.sender);

        msg.sender.transfer(amount);
    }

    function bid(
        uint256 _cryptographIssue,
        bool _isOfficial,
        uint256 _editionSerial,
        uint256 _newBidAmount,
        uint256 _previousStandingBidAmount
    ) external payable{


        require(CryptographKYCLogicV1(kycContract).checkKyc(msg.sender, _newBidAmount),
            "Bid above a specific amount requires the bidder to be KYCed");

        SingleAuctionLogicV1 _auc = SingleAuctionLogicV1(
            TheCryptographLogicV1(
                CryptographIndexLogicV1(index).getCryptograph(_cryptographIssue, _isOfficial, _editionSerial)
            ).myAuction()
        );

        require(_auc.currentBids(_auc.highestBidder()) == _previousStandingBidAmount,
            "bid not accepted: current highest standing bid is different than the one specified");

        pendingWithdrawals[msg.sender] += msg.value;

        require(pendingWithdrawals[msg.sender] + _auc.currentBids(msg.sender) >= _newBidAmount, "bid not accepted: Not enough ether was sent");

        uint256 toSend = _newBidAmount - _auc.currentBids(msg.sender);

        pendingWithdrawals[msg.sender] -= toSend;

        emit UserBid(address(_auc), _newBidAmount, msg.sender);

        _auc.bid{value: toSend }(_newBidAmount, msg.sender);
    }

    function getHighestBid(uint256 _cryptographIssue, bool _isOfficial, uint256 _editionSerial) external view returns(uint256){

        SingleAuctionLogicV1 _auc = SingleAuctionLogicV1(
            TheCryptographLogicV1(
                CryptographIndexLogicV1(index).getCryptograph(_cryptographIssue, _isOfficial, _editionSerial)
            ).myAuction()
        );
        return _auc.currentBids(_auc.highestBidder());
    }

    function cancelBid(uint256 _cryptographIssue, bool _isOfficial, uint256 _editionSerial) external{


        SingleAuctionLogicV1 _auc = SingleAuctionLogicV1(
            TheCryptographLogicV1(
                CryptographIndexLogicV1(index).getCryptograph(_cryptographIssue, _isOfficial, _editionSerial)
            ).myAuction()
        );

        emit UserCancelledBid(address(_auc), msg.sender);

        _auc.cancelBid(msg.sender);
    }

    function win(uint256 _cryptographIssue, bool _isOfficial, uint256 _editionSerial) external{


        TheCryptographLogicV1 _cry = TheCryptographLogicV1(
                CryptographIndexLogicV1(index).getCryptograph(_cryptographIssue, _isOfficial, _editionSerial)
            );

        SingleAuctionLogicV1 _auc = SingleAuctionLogicV1(_cry.myAuction());

        emit UserWin(address(_auc), _auc.currentBids(_auc.highestBidder()), _auc.highestBidder());

        ERC2665LogicV1(ERC2665Lieutenant).transferACryptograph(_cry.owner(), _auc.highestBidder(), address(_cry), _auc.currentBids(_auc.highestBidder()));

        if(!(_auc.win(_auc.highestBidder()) == 0)){
            CryptographFactoryLogicV1(factory).mintGGBMA(_cryptographIssue, _isOfficial, _auc.highestBidder()); //Minting in the case of GGBMA
            MintingAuctionLogicV1(address(_auc)).distributeBid(_auc.highestBidder()); //Distributing the money
        }
    }

    function setSellingPrice(uint256 _cryptographIssue, bool _isOfficial, uint256 _editionSerial, uint256 _newSellingPrice) external{


        SingleAuctionLogicV1 _auc = SingleAuctionLogicV1(
            TheCryptographLogicV1(
                CryptographIndexLogicV1(index).getCryptograph(_cryptographIssue, _isOfficial, _editionSerial)
            ).myAuction()
        );

        emit UserSellingPriceAdjust(address(_auc), _newSellingPrice);

        _auc.setSellingPrice(msg.sender, _newSellingPrice);
    }

    function transferERC2665(address _cryptograph, address _contributor, address _to) external payable{

        require(msg.sender == ERC2665Lieutenant, "Only the ERC2665Lieutenant can call this function");
        SingleAuctionLogicV1(TheCryptographLogicV1(_cryptograph).myAuction()).transferERC2665{value:msg.value}(_contributor, _to);
    }

    function approveERC2665(address _cryptograph, address _contributor, address _approvedAddress) external payable{

        require(msg.sender == ERC2665Lieutenant, "Only the ERC2665Lieutenant can call this function");
        SingleAuctionLogicV1(TheCryptographLogicV1(_cryptograph).myAuction()).approveERC2665{value:msg.value}(_contributor, _approvedAddress);
    }

}

pragma solidity 0.6.6;

contract BidLinkSimple{


    address public auction; //The Minting auction the BidLink is associated with
    address public bidder; //Our bidder
    address public above;  //BidLink with a bigger bid
    address public below;  //BidLink with a smaller bid

    modifier restrictedToAuction(){

        require((msg.sender == auction), "Only the auction contract can call this function");
        _;
    }

    constructor (address _bidder) public
    {
        auction = msg.sender;
        bidder = _bidder;
    }

    function reset(address _bidder) external restrictedToAuction(){

        delete above;
        delete below;
        bidder = _bidder;
    }

    function setAbove(address _above) external restrictedToAuction(){

        above = _above;
    }

    function setBelow(address _below) external restrictedToAuction(){

        below = _below;
    }

}
pragma solidity 0.6.6;



contract SingleAuctionLogicV1 is VCProxyData, SingleAuctionHeaderV1, SingleAuctionStoragePublicV1  {


    constructor () public
    {
    }

    modifier restrictedToAuctionHouse(){

        require((msg.sender == auctionHouse), "Only the auction house smart contract can call this function");
        _;
    }

    function initAuction(
            address _myCryptograph,
            address _cryInitiator,
            bool _initialize
        ) public {


        require(!initialized, "This auction is already initialized");
        initialized = _initialize; //Are we locking ?

        require(auctionHouse == address(0) || msg.sender == cryFactory,"Only Perpetual altruism can change a yet to be locked auction");
        cryFactory = msg.sender;


        startingPrice = CryptographInitiator(_cryInitiator).startingPrice(); //The first bid that need to be outbid is 1 Wei
        sellingPrice = 0; //A newly minted cryptograph doesn't have an owner willing to sell

        bid_Decimals = 100000;  //100k, or 100%
        bid_incMax = 10000; //10k, or 10%
        bid_incMin = 1000; //1k, or 1%
        bid_stepMin = 10500; //10.5k, or 10.5%
        bid_cutOthers = 500; // 500, or 0.5%
        bid_multiplier = 11120; // 9000 = Doubling step min bid yield max gain (1%+9% = 10%). 

        sale_fee = 10000; //10k, or 10%

        perpertualAltruism = CryptographFactoryStoragePublicV1(cryFactory).officialPublisher();
        perpetualAltruismCut = CryptographInitiator(_cryInitiator).perpetualAltruismCut();
        publisher = CryptographInitiator(_cryInitiator).publisher();
        publisherCut = CryptographInitiator(_cryInitiator).publisherCut();
        charity = CryptographInitiator(_cryInitiator).charity();
        charityCut = CryptographInitiator(_cryInitiator).charityCut();
        thirdParty = CryptographInitiator(_cryInitiator).thirdParty();
        thirdPartyCut = CryptographInitiator(_cryInitiator).thirdPartyCut();

        startTime = CryptographInitiator(_cryInitiator).auctionStartTime();
        endTime = CryptographInitiator(_cryInitiator).auctionStartTime() + CryptographInitiator(_cryInitiator).auctionSecondsDuration();

        hammerBlockDuration = 10; //Minimum 10 blocks
        hammerTimeDuration = 36*60*60; //The new perpetual auction will last for 36 hours at least
        delete hammerBlock;
        delete hammerTime;

        auctionHouse = CryptographFactoryStoragePublicV1(cryFactory).targetAuctionHouse();
        myCryptograph = _myCryptograph;
    }

    function lock() external{

        require(msg.sender == cryFactory, "Only Perpetual altruism can lock the initialization");
        initialized = true;
    }

    function bid(uint256 _newBidAmount, address _newBidder) external payable restrictedToAuctionHouse(){

    }

    function cancelBid(address _bidder) external restrictedToAuctionHouse(){


        require(currentBids[_bidder] != 0, "Can't cancel a bid that does not exist");

        require(TheCryptographLogicV1(myCryptograph).owner() != address(0), "Bids cannot be manually cancelled during the initial auction");

        require(hammerTime == 0 || _bidder != highestBidder, "The highest bid cannot be cancelled once a seller accepted a sale");

        uint256 toSend = currentBids[_bidder];

        if(_bidder == highestBidder ){
            toSend -= unsettledPayouts;
            unsettledPayouts = 0;

            address _linkHighest = BidLinkSimple(bidLinks[_bidder]).below();
            if(_linkHighest != address(0x0)){
                highestBidder = BidLinkSimple(_linkHighest).bidder();
            } else {
                delete highestBidder;
            }
        }

        emit BidCancelled(currentBids[_bidder], toSend, _bidder);

        currentBids[_bidder] = 0;
        duePayout[_bidder] = 0;


        if( BidLinkSimple(bidLinks[_bidder]).above() != address(0x0)){
            BidLinkSimple(BidLinkSimple(bidLinks[_bidder]).above()).setBelow(BidLinkSimple(bidLinks[_bidder]).below()); //Unlinking above us
        }

        if( BidLinkSimple(bidLinks[_bidder]).below() != address(0x0)){
            BidLinkSimple(BidLinkSimple(bidLinks[_bidder]).below()).setAbove(BidLinkSimple(bidLinks[_bidder]).above()); //Unlinking below us
        }

        AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(_bidder, _bidder);

    }

    function setSellingPrice(address _seller, uint256 _sellPrice) external restrictedToAuctionHouse(){


        require(!isBeingERC2665Approved, "You can't auction a cryptograph that a third party can reclaim");

        require(_seller == TheCryptographLogicV1(myCryptograph).owner(), "The seller can only be the owner");
        require(hammerTime == 0, "A sale is already in progress");

        sellingPrice = _sellPrice;

        emit SellingPriceAdjusted(_seller, _sellPrice);

        if(currentBids[highestBidder] >= _sellPrice && _sellPrice != 0){ //Start a sale if the selling price is already met by the highest bidder
            hammerTime = now + hammerTimeDuration;
            hammerBlock = block.number + hammerBlockDuration;
            emit SaleStarted(_seller, hammerTime, hammerBlock);
        }

        TheCryptographLogicV1(myCryptograph).renatus();

    }

    function win(address _newOwner) external restrictedToAuctionHouse() returns(uint){


        require(_newOwner == highestBidder, "Only the highest bidder can win the Cryptograph");
     
        if(startingPrice != 1){
            startingPrice = 1;
        }

        emit Win(_newOwner, TheCryptographLogicV1(myCryptograph).owner(), currentBids[highestBidder]);

        uint256 toSend;

        if(TheCryptographLogicV1(myCryptograph).owner() == address(0)){
            require(now > endTime, "The initial auction is not over yet");

            distributeStakeholdersPayouts(currentBids[highestBidder] - unsettledPayouts, _newOwner);

        } else {

            require(hammerTime != 0, "No sales are happening right now");
            require(now > hammerTime, "Not enough time has elapsed since the seller accepted the sale");
            require(block.number > hammerBlock, "Not enough blocks have been mined since the seller accepted the sale");

            delete hammerBlock; //Reset the minimal sale block
            delete hammerTime; //Reset the minmimal sale time

            toSend = ((currentBids[highestBidder] - unsettledPayouts ) * sale_fee) / bid_Decimals;
            distributeStakeholdersPayouts(toSend, _newOwner);

            toSend = currentBids[highestBidder] - unsettledPayouts - toSend;
            emit Payout(toSend, TheCryptographLogicV1(myCryptograph).owner(), _newOwner);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(TheCryptographLogicV1(myCryptograph).owner(), _newOwner);
        }

        delete unsettledPayouts; //Reset the payouts


        currentBids[_newOwner] = 0;
        duePayout[_newOwner] = 0;

        address _linkHighest = BidLinkSimple(bidLinks[highestBidder]).below();

        delete bidLinks[highestBidder];

        if(_linkHighest != address(0x0)){
            highestBidder = BidLinkSimple(_linkHighest).bidder();
            BidLinkSimple(_linkHighest).setAbove(address(0x0)); //Our below neighbor is the new highest bidder
        } else {
            delete highestBidder;
        }


        sellingPrice = 0;
        emit SellingPriceAdjusted(_newOwner, 0);

        TheCryptographLogicV1(myCryptograph).transfer(_newOwner);

        return 0;
    }

    function distributeStakeholdersPayouts(uint256 _amount, address _contributor) internal{

        uint256 toDistribute = _amount;
        uint256 toSend;

        toSend = (charityCut * _amount) / bid_Decimals;
        toDistribute -= toSend;
        if(toSend != 0){
            emit Payout(toSend,  charity,  _contributor);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(charity, _contributor);
        }

        toSend = (publisherCut * _amount) / bid_Decimals;
        toDistribute -= toSend;
        if(toSend != 0){
            emit Payout(toSend,  publisher,  _contributor);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(publisher, _contributor);
        }

        toSend = (thirdPartyCut * _amount) / bid_Decimals;
        toDistribute -= toSend;
        if(toSend != 0){
            emit Payout(toSend,  thirdParty,  _contributor);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(thirdParty, _contributor);
        }

        toSend = toDistribute;
        if(toSend != 0){
            emit Payout(toSend,  perpertualAltruism,  _contributor);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(perpertualAltruism, _contributor);
        }
    }

    function calculateReward(uint256 _newBid, address _bidder) internal{



        uint256 baseBid = currentBids[highestBidder] * (bid_Decimals + bid_stepMin) / bid_Decimals;
        if(baseBid == 0){
            baseBid = startingPrice;

            if(baseBid == 0){
                baseBid = 1;
            }
        }

        uint256 decimaledRatio = ((bid_Decimals * bid_multiplier * (_newBid - baseBid) ) / baseBid) + bid_incMin * bid_Decimals;

        if(decimaledRatio > (bid_Decimals * bid_incMax)){
            decimaledRatio = bid_Decimals * bid_incMax;
        }

        duePayout[_bidder] = (_newBid * decimaledRatio)/(bid_Decimals*bid_Decimals);
    }

    function renatus() external{


        require(msg.sender == myCryptograph, "Only callable by the paired Cryptograph");

        delete hammerBlock; //Reset the minimal sale block
        delete hammerTime; //Reset the minmimal sale time
        delete sellingPrice; //Reset the selling price

        endTime = now + 60*60*24*14 + endTime - startTime;
        startTime = now + 60*60*24*14;

        TheCryptographLogicV1(myCryptograph).transfer(address(0));
    }

    function transferERC2665(address _contributor, address _to) external payable restrictedToAuctionHouse() {


         if(msg.value != 0){
            distributeStakeholdersPayouts(msg.value, _contributor);
        }

        require(hammerTime == 0, "Can't transfer a cryptograph under sale");
   
        if(sellingPrice != 0){
            sellingPrice = 0;
            emit SellingPriceAdjusted(_contributor, 0);
        }

        TheCryptographLogicV1(myCryptograph).transfer(_to);

        isBeingERC2665Approved = false;

    }

    
    function approveERC2665(address _contributor, address _approvedAddress) external payable restrictedToAuctionHouse(){


        if(msg.value != 0){
            distributeStakeholdersPayouts(msg.value, _contributor);
        }
      

        require(hammerTime == 0, "Can't approve a cryptograph under sale");

        if(sellingPrice != 0){
            sellingPrice = 0;
            emit SellingPriceAdjusted(_contributor, 0);
        }
        
        if(_approvedAddress == address(0) || _approvedAddress == TheCryptographLogicV1(myCryptograph).owner()){
            isBeingERC2665Approved = false;
        } else {
            isBeingERC2665Approved = true;
        }

    }

}

pragma solidity 0.6.6;



contract TheCryptographLogicV1 is VCProxyData, TheCryptographHeaderV1, TheCryptographStoragePublicV1 {


    constructor()public{
    }

    modifier restrictedToFactory() {

        require(SingleAuctionLogicV1(myAuction).cryFactory() == msg.sender, "Only callable by the factory");
        _;
    }

    function initCry(
        uint256 _issue, uint256 _serial, bool _official, address _myAuction, address _cryInitiator, address _owner) external {


        require(
            myAuction == address(0) ||
            (
                official &&
                !hasCurrentOwnerMarked &&
                SingleAuctionLogicV1(myAuction).cryFactory() == msg.sender &&
                SingleAuctionLogicV1(myAuction).startTime() > now),
            "This Cryptograph has already been initialized");

        name = CryptographInitiator(_cryInitiator).name();
        creator = CryptographInitiator(_cryInitiator).creator();

        emit Named(name);

        mediaHash = CryptographInitiator(_cryInitiator).mediaHash();
        emit MediaHash(mediaHash);

        mediaUrl = CryptographInitiator(_cryInitiator).mediaUrl();
        emit MediaUrl(mediaUrl);

        serial = _serial;
        issue = _issue;

        official = _official;

        owner = _owner;

        myAuction = _myAuction;

    }

    function setMediaHash(string calldata _mediaHash) external restrictedToFactory() {

        mediaHash = _mediaHash;
        emit MediaHash(_mediaHash);
    }

    function setMediaUrl(string calldata _mediaUrl)external restrictedToFactory() {

        mediaUrl = _mediaUrl;
        emit MediaUrl(_mediaUrl);
    }

    function transfer(address _newOwner) external {

        require(msg.sender == myAuction, "The auction is the only way to set a new owner");
        emit Transferred(owner, _newOwner);
        owner = _newOwner;
        hasCurrentOwnerMarked = false;

        lastOwnerInteraction = now;
        renatusTimeStamp = 0;
    }

    function mark(string calldata _mark) external {

        require(msg.sender == owner, "Only the owner can set a mark on a cryptograph");
        require(!hasCurrentOwnerMarked, "The cryptograph has already been marked by the owner");
        require(bytes(_mark).length <= 3, "You can only inscribe at most 3 characters at a time"); //In Utf8, strlenght <= bytelength.

        hasCurrentOwnerMarked = true; //Setting the current owner has having marked

        marks.push(_mark); //Inscribing the mark
        markers.push(owner); //Associating the owner

        emit Marked(owner, _mark); //Emitting the event

        lastOwnerInteraction = now;
        renatusTimeStamp = 0;
    }

    function renatus() external {

        if (msg.sender == owner ||
            msg.sender == myAuction ||
            msg.sender == SingleAuctionLogicV1(myAuction).publisher() ||
            msg.sender == AuctionHouseStoragePublicV1(SingleAuctionLogicV1(myAuction).auctionHouse()).ERC2665Lieutenant()) {
            lastOwnerInteraction = now; //If the owner/operator/Pa call, reset the renatus call
            renatusTimeStamp = 0;
            emit Renatus(0);
        } else {
            require(now >= lastOwnerInteraction + 60 * 60 * 24 * 366 * 5, "Five years have not yet elapsed since last owner interaction");

            if (renatusTimeStamp == 0) {
                renatusTimeStamp = now + 60 * 60 * 24 * 31;
                emit Renatus(renatusTimeStamp);
            } else {
                require(now > renatusTimeStamp, "31 days since renatus was called have not elapsed yet");

                SingleAuctionLogicV1(myAuction).renatus();

                ERC2665LogicV1(AuctionHouseStoragePublicV1(SingleAuctionLogicV1(myAuction).auctionHouse()).ERC2665Lieutenant()).triggerRenatus();
                hasCurrentOwnerMarked = true; //Prevent publisher meddling
            }
        }
    }

}
pragma solidity 0.6.6;


contract ERC20Generic {


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    string public name; // Returns the name of the token - e.g. "MyToken".
    string public symbol; // Returns the symbol of the token. E.g. “HIX”.
    uint8 public decimals; // Returns the number of decimals the token uses - e.g. 8, means to divide the token amount by 100000000 to get its user representation.
    uint256 public totalSupply; //Returns the total token supply.
    mapping(address => uint256) public balanceOf; //Returns the account balance of another account with address _owner.
    mapping(address => mapping(address => uint256)) public individualAllowance; // Mapping of allowance per owner/spender

    function transfer(address _to, uint256 _value) public returns (bool success){

        require(balanceOf[msg.sender] >= _value, "msg.sender balance is too low");
        balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){

        require(balanceOf[_from] >= _value, "_from balance is too low");
        require(individualAllowance[_from][msg.sender] >= _value || msg.sender == _from, "msg.sender allowance with _from is too low");
        individualAllowance[_from][msg.sender] = individualAllowance[_from][msg.sender] - _value;
        balanceOf[_from] = balanceOf[_from] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){

        individualAllowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining){

        return individualAllowance[_owner][_spender];
    }

    function mint( uint256 _value) public {

        balanceOf[msg.sender] = balanceOf[msg.sender] + _value;
    }

}// © Copyright 2020. Patent pending. All rights reserved. Perpetual Altruism Ltd.
pragma solidity 0.6.6;


contract ERC2665LogicV2 is VCProxyData, ERC2665HeaderV1, ERC2665StoragePublicV2 {


    constructor() public {
    }

    function init(address _auctionHouse, address _indexCry) external{

        require(auctionHouse == address(0), "Already initialized");
        auctionHouse = payable(_auctionHouse);
        indexCry = _indexCry;
    }
	
	function setWeth(address _wethContract) external{

		address publisher = CryptographFactoryStoragePublicV1(address(CryptographIndexStoragePublicV1(indexCry).factory())).officialPublisher();
		require(msg.sender == publisher);
		
		contractWETH = _wethContract;
	}

    function transferACryptograph(address _from, address _to, address _cryptograph, uint256 _lastSoldFor ) external {

        require((msg.sender == auctionHouse), "Only the cryptograph auction house smart contract can call this function");
        transferACryptographInternal(_from, _to, _cryptograph, _lastSoldFor);
    }


    function MintACryptograph(address _newCryptograph) external {

        require((msg.sender == indexCry), "Only the cryptograph index smart contract can call this function");
        index2665ToAddress[totalSupplyVar] = _newCryptograph;
        totalSupplyVar++;
        balanceOfVar[address(0)] = balanceOfVar[address(0)] + 1;
        isACryptograph[_newCryptograph] = true;

    }

    function supportsInterface(bytes4 interfaceID) external pure returns(bool) {


        return (
            interfaceID == 0x80ac58cd || //ERC721
            interfaceID == 0x5b5e139f || //metadata extension
            interfaceID == 0x780e9d63 || //enumeration extension
            interfaceID == 0x509ffea4 //ERC2665
        );
        
    }

    function balanceOf(address _owner) external view returns (uint256){

        require(_owner != address(0), "ERC721 NFTs assigned to the zero address are considered invalid");
        return balanceOfVar[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address){

        require(isACryptograph[address(_tokenId)], "_tokenId is not a Valid Cryptograph");
        address retour = TheCryptographLogicV1(address(_tokenId)).owner();
        require(retour != address(0),
            "ERC721 NFTs assigned to the zero address are considered invalid");
        return retour;
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable{

        transferFromInternal(_from, _to, _tokenId, msg.sender, msg.value);

        require(_to != address(0));
        if(isContract(_to)){
            require(ERC2665TokenReceiver(_to).onERC2665Received(msg.sender, _from, _tokenId, data) == bytes4(0xac3cf292));
        }
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{

        transferFromInternal(_from, _to, _tokenId, msg.sender, msg.value);

        require(_to != address(0));
        if(isContract(_to)){
            require(ERC2665TokenReceiver(_to).onERC2665Received(msg.sender, _from, _tokenId, "") ==  bytes4(0xac3cf292));
        }
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable{

        transferFromInternal(_from, _to, _tokenId, msg.sender, msg.value);
    }



    function approve(address _approved, uint256 _tokenId) external payable{


        address owner = TheCryptographLogicV1(address(_tokenId)).owner();
        require(msg.sender == owner || approvedOperator[owner][msg.sender], "Only the owner or an operator can approve a token transfer");
        require(isACryptograph[address(_tokenId)], "_tokenId is not a Valid Cryptograph");

        TheCryptographLogicV1(address(_tokenId)).renatus();

        uint256 leftover = msg.value;

        if(leftover >= transferFees[_tokenId]){

            leftover =  leftover - transferFees[_tokenId];
            transferFees[_tokenId] = 0;
            
            if(leftover >= (lastSoldFor[_tokenId] * 15 /100)){
                leftover = leftover -  (lastSoldFor[_tokenId] * 15 /100);
                transferFeePrepaid[_tokenId] = true;
            }

        }

        AuctionHouseLogicV1(auctionHouse).approveERC2665{value: msg.value - leftover }(address(_tokenId), msg.sender, _approved);

        if(leftover != 0){
            (bool trashBool, ) = msg.sender.call{value:leftover}("");
            require(trashBool, "Could not send the leftover money back");
        }

        approvedTransferAddress[_tokenId] = _approved; 

        emit Approval(msg.sender, _approved, _tokenId);

    }

    function setApprovalForAll(address _operator, bool _approved) external {

        approvedOperator[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address){

        require(isACryptograph[address(_tokenId)], "_tokenId is not a Valid Cryptograph");

        return approvedTransferAddress[_tokenId];
    }
  
    function isApprovedForAll(address _owner, address _operator) external view returns (bool){

        return approvedOperator[_owner][_operator];
    }

    function getTransferFee(uint256 _tokenId) external view returns (uint256){

        return transferFees[_tokenId];
    }

    function getTransferFee(uint256 _tokenId, string calldata _currencySymbol) external view returns (uint256){

        if(keccak256(bytes(_currencySymbol)) == bytes32(0xaaaebeba3810b1e6b70781f14b2d72c1cb89c0b2b320c43bb67ff79f562f5ff4) ||
            keccak256(bytes("WETH")) == bytes32(0x0f8a193ff464434486c0daf7db2a895884365d2bc84ba47a68fcf89c1b14b5b8)
        ){
            return transferFees[_tokenId];
        } else {
            return 0;
        }
    }


    function name() external pure returns(string memory _name){

        return "Cryptograph";
    }

    function symbol() external pure returns(string memory _symbol){

        return "Cryptograph";
    }

    function tokenURI(uint256 _tokenId) external view returns(string memory){

        require(isACryptograph[address(_tokenId)], "_tokenId is not a Valid Cryptograph");
   
        return string(abi.encodePacked("https://cryptograph.co/tokenuri/", addressToString(address(_tokenId))));
    }


    function totalSupply() external view returns (uint256){

        return totalSupplyVar;
    }

    function tokenByIndex(uint256 _index) external view returns (uint256){

        require(_index < totalSupplyVar, "index >= totalSupply()");
        return uint256(index2665ToAddress[_index]);
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256){

        require(_owner != address(0), "_owner == 0");
        require(_index < balanceOfVar[_owner], "_index >= balanceOf(_owner)");

        return indexedOwnership[_owner][_index];
    }

    function addressFromTokenId(uint256 _tokenId) external pure returns (address){

            return address(_tokenId);
    }

    function tokenIdFromAddress(address _tokenAddress) external pure returns (uint256){

            return uint256(_tokenAddress);
    }

    function renatus(uint256 _tokenId) public {

        require(isACryptograph[address(_tokenId)], "renatus need to be called for a Valid Cryptograph");

        address owner = TheCryptographLogicV1(address(_tokenId)).owner();
        require(approvedOperator[owner][msg.sender] || owner == msg.sender);

        TheCryptographLogicV1(address(_tokenId)).renatus();
    }

    function triggerRenatus() public{

        require(isACryptograph[msg.sender], "Only the token itself can notify us of a renatus hapenning");
        emit Transfer(TheCryptographLogicV1(address(msg.sender)).owner(), address(0), uint256(msg.sender));
    }
    
    function transferACryptographInternal(address _from, address _to, address _cryptograph, uint256 _lastSoldFor) internal{


         require(isACryptograph[_cryptograph], 
            "Only minted cryptogrtaphs can be transferred");

        if(_lastSoldFor != lastSoldFor[uint256(_cryptograph)]){
            lastSoldFor[uint256(_cryptograph)] = _lastSoldFor;
        }

        if(!transferFeePrepaid[uint256(_cryptograph)]){
            transferFees[uint256(_cryptograph)] = (_lastSoldFor * 15) / 100; //15% transfer fee
        } else {
            transferFees[uint256(_cryptograph)] = 0;
        }
        transferFeePrepaid[uint256(_cryptograph)] = false;
  

        approvedTransferAddress[uint256(_cryptograph)] = address(0);


        emit Transfer(_from, _to, uint256(_cryptograph));

        uint256 posInArray;

        if(_from != address(0x0)){

            if(balanceOfVar[_from] != 1){


                posInArray = cryptographPositionInOwnershipArray[uint256(_cryptograph)];

                indexedOwnership[_from][posInArray] = indexedOwnership[_from][balanceOfVar[_from]-1];

                cryptographPositionInOwnershipArray[indexedOwnership[_from][posInArray]] = posInArray;

                delete indexedOwnership[_from][balanceOfVar[_from]-1];

            }  else {
                delete indexedOwnership[_from][0];
            }
        }

        posInArray = balanceOfVar[_to];

        if(_to != address(0x0)){

            if(indexedOwnership[_to].length < posInArray + 1){
                indexedOwnership[_to].push(uint256(_cryptograph));
            } else {
                indexedOwnership[_to][posInArray] = uint256(_cryptograph);
            }

            cryptographPositionInOwnershipArray[uint256(_cryptograph)] = posInArray;
        }

        balanceOfVar[_from] = balanceOfVar[_from] - 1;
        balanceOfVar[_to] = balanceOfVar[_to] + 1;

    }


    function transferFromInternal(address _from, address _to, uint256 _tokenId, address _sender, uint256 _value) internal{



        address owner = TheCryptographLogicV1(address(_tokenId)).owner();
        require(owner == _from,
            "The owner of the token and _from did not match");
    
        if(transferFees[_tokenId] != 0){ //Only collect fees if there is one to pay
            if(_value != 0){
                require(_value >= transferFees[_tokenId], "The transfer fee must be paid");
            } else {
                address publisher = CryptographFactoryStoragePublicV1(address(CryptographIndexStoragePublicV1(indexCry).factory())).officialPublisher();

                ERC20Generic(contractWETH).transferFrom(owner, publisher, transferFees[_tokenId]);

                transferFees[_tokenId] = 0;
            }
        }


        require(_sender == owner || approvedOperator[owner][_sender] || approvedTransferAddress[_tokenId] == _sender, "The caller is not allowed to transfer the token");

        uint256 leftover = _value - transferFees[_tokenId];

        transferACryptographInternal(_from, _to, address(_tokenId), lastSoldFor[_tokenId]);

        AuctionHouseLogicV1(auctionHouse).transferERC2665{value:  _value - leftover}(address(_tokenId), _sender, _to);

        if(leftover >= transferFees[_tokenId]){
            leftover =  leftover - transferFees[_tokenId];
            transferFees[_tokenId] = 0;
        }

        if(leftover != 0){
            (bool trashBool, ) = _sender.call{value:leftover}("");
            require(trashBool, "Could not send the leftover money back");
        }
    }


    function addressToString(address _addr) internal pure returns(string memory)
    {

        bytes32 addr32 = bytes32(uint256(_addr)); //Put the address 20 byte address in a bytes32 word
        bytes memory alphabet = "0123456789abcdef";  //What are our allowed characters ?

        bytes memory str = new bytes(42);

        str[0] = '0';
        str[1] = 'x';

        for (uint256 i = 0; i < 20; i++) { //iterating over the actual address

            str[2+i*2] = alphabet[uint8(addr32[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(addr32[i + 12] & 0x0f)];
        }
        return string(str);
    }

    function isContract(address _address) internal view returns(bool){

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(_address) }
        return (codehash != accountHash && codehash != 0x0);
    }

}
pragma solidity 0.6.6;


contract AuctionHouseEmptyV1 is VCProxyData, AuctionHouseHeaderV1, AuctionHouseStoragePublicV1 {



}// © Copyright 2020. Patent pending. All rights reserved. Perpetual Altruism Ltd.
pragma solidity 0.6.6;


contract AuctionHouseProxiedV1 is VCProxy, AuctionHouseHeaderV1, AuctionHouseStorageInternalV1  {


    constructor(uint256 _version, address _vc)  public
    VCProxy(_version, _vc) //Call the VC proxy constructor so that this contract know where it's logic code is
    {
    }
}



pragma solidity 0.6.6;


contract CryptographFactoryProxiedV1 is VCProxy, CryptographFactoryHeaderV1, CryptographFactoryStorageInternalV1  {


    constructor(uint256 _version, address _vc)  public
    VCProxy(_version, _vc) //Call the VC proxy constructor so that we know where our logic code is
    {
    }


}



pragma solidity 0.6.6;


contract CryptographIndexProxiedV1 is VCProxy, CryptographIndexHeaderV1, CryptographIndexStorageInternalV1  {


    constructor(uint256 _version, address _vc)  public
    VCProxy(_version, _vc) //Call the VC proxy constructor so that we know where our logic code is
    {
    }


}



pragma solidity 0.6.6;


contract CryptographKYCProxiedV1 is VCProxy, CryptographKYCHeaderV1, CryptographKYCStorageInternalV1  {


    constructor(uint256 _version, address _vc)  public
    VCProxy(_version, _vc) //Calls the VC proxy constructor so that we know where our logic code is
    {
    }



}



pragma solidity 0.6.6;


contract ERC2665ProxiedV1 is VCProxy, ERC2665HeaderV1, ERC2665StorageInternalV1 {


    constructor(uint256 _version, address _vc)public
    VCProxy(_version, _vc) //Calls the VC proxy constructor so that we know where our logic code is
    {
    }


}
pragma solidity >=0.4.25 <0.7.0;


contract Migrations {

    address public owner;
    uint256 public last_completed_migration;

    modifier restricted() {

        if (msg.sender == owner) _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setCompleted(uint256 completed) public restricted {

        last_completed_migration = completed;
    }

    function upgrade(address new_address) public restricted {

        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}// © Copyright 2020. Patent pending. All rights reserved. Perpetual Altruism Ltd.
pragma solidity 0.6.6;

contract SenateHeaderV1 {

    event AddedLogicCodeToVC(address law); //A new logic code address (law) was added to the available pool
    event RemovedLogicCodeToVC(address law); //A logic code address (law) was removed from the available pool
    event NewLawProposal(uint256 lawIndex, address law, uint256 enactionTime, bool revokeLaw, bool stateOfEmergency); //A new law proposal to vote on
    event EnactProposal(uint256 lawIndex, address law, uint256 enactionTime, bool revokeLaw, bool stateOfEmergency); //The lawmaker applied a proposal
    event Voted(bool vote, uint256 lawIndex, uint256 issueNumber, uint256 SerialNumber); //Emitted when a token holder vote on a low
    event DemocracyOn(); //Enable voting before adding new laws
    event DemocracyOff(); //Give back the ability to the lawmaker to add any law without a vote
}


contract SenateStorageInternalV1 {


    bool internal democracy; //A bool controlling if address addition/removal is subject to vote
    mapping (address => bool) internal laws; //The list of allowed smart contract addresses for use in the Version Control
    address internal lawmaker; //Address allowed to sumbmit new address to be voted upon.
    address[] internal lawPropositions; //List of proposed laws to be voted upon
    address internal cryptographIndex; //The cryptograph index address
    uint256 internal totalLaws; //The total number of published laws

}


contract SenateStorageExternalV1 {


    bool public democracy; //A bool controlling if address addition/removal is subject to vote
    mapping(address => bool) public laws; //The list of allowed smart contract addresses for use in the VC
    address public lawmaker; //Address allowed to sumbmit new address to be voted upon.
    address[] public lawPropositions; //List of proposed laws to be voted upon
    address public cryptographIndex; //The cryptograph index address
    uint256 public totalLaws; //The total number of published laws
}

pragma solidity 0.6.6;


contract SenateLogicV1 is VCProxyData, SenateHeaderV1, SenateStorageExternalV1  {


    constructor() public
    {
    }

    modifier restrictedToLawmaker(){

        require(msg.sender == lawmaker, "Only the lawmaker can call this function");
        _;
    }

    function init(address _cryptographIndex) external {

        require (cryptographIndex == address(0x0), "The senate has already been initialized");
        cryptographIndex = _cryptographIndex;
    }

    function isAddressAllowed(address _candidateAddress) external view returns(bool){

        bool retour = laws[_candidateAddress];
        return retour;
    }

    function quaranteNeufTrois(address _candidateAddress, bool _allowed) external restrictedToLawmaker() {

        require(!democracy, "Democracy is enforced, new addresses must be subject to approval by the senate");
        laws[_candidateAddress] = _allowed;
        if(!_allowed){ //Are we deleting a law ?
                laws[_candidateAddress] = false;
                emit RemovedLogicCodeToVC(_candidateAddress); //emit the event
            } else { //We are adding a law
                laws[_candidateAddress] = true;
                emit AddedLogicCodeToVC(_candidateAddress); //emit the event
            }
    }

    function powerToThePeople() external restrictedToLawmaker(){

        require(!democracy, "Democracy is already in place");
        democracy = true; //https://youtu.be/T-TGPhVC0AE?t=11
        emit DemocracyOn(); //Emitting the event
    }

    function submitNewLaw(address _law, uint256 _duration, bool _revokeLaw, bool _stateOfEmergency) external restrictedToLawmaker() returns (uint256) {

        lawPropositions.push(address(new LawProposition(_law, _duration, _revokeLaw, _stateOfEmergency)));
        emit NewLawProposal(lawPropositions.length - 1, _law, now + _duration, _revokeLaw, _stateOfEmergency);
        totalLaws = lawPropositions.length;
        return totalLaws;
    }

    function VoteOnLaw(bool _vote, uint256 _lawIndex, uint256 _cryptographIssue, uint256 _editionSerial) external{


        require((_editionSerial == 1 || _editionSerial == 0 ), "Only the first serial of each edition is allowed to vote");

        address _cry = CryptographIndexLogicV1(cryptographIndex).getCryptograph(_cryptographIssue, true, _editionSerial);

        require(
            TheCryptographLogicV1(address(uint160(_cry))).owner() == msg.sender,
            "You are not an owner allowed to vote"
        );

        LawProposition(lawPropositions[_lawIndex]).vote(_vote, _cry);

        emit Voted(_vote, _lawIndex, _cryptographIssue, _editionSerial);
    }

    function EnactLaw(uint256 _lawIndex) external restrictedToLawmaker(){

        LawProposition _lawProp = LawProposition(lawPropositions[_lawIndex]);
        _lawProp.enactable(); //Checks are made internally by the LawPropostion

        emit EnactProposal(_lawIndex, _lawProp.law(), _lawProp.enactionTime(), _lawProp.revokeLaw(), _lawProp.stateOfEmergency());

        if(_lawProp.stateOfEmergency()){ //Dying with thunderous applause
            democracy = false; //BETTER DEAD THAN RED
            emit DemocracyOff(); // I am the senate
        } else {
            if(_lawProp.revokeLaw()){ //Are we deleting a law ?
                laws[_lawProp.law()] = false;
                emit RemovedLogicCodeToVC(_lawProp.law()); //emit the event
            } else { //We are adding a law
                laws[_lawProp.law()] = true;
                emit AddedLogicCodeToVC(_lawProp.law()); //emit the event
            }
        }
    }

}


contract LawProposition {


    address public senate; //The address of the senate
    mapping (address => bool) public tokenWhoVoted; //A mapping storing every token that has voted on this law
    address public law; //The address of a smart contract logic code to be potentially used in the VC
    uint256 public enactionTime; //A timestamp storing the earliest time at which the lawmaker can enact the law
    bool public revokeLaw; //A bool true if the proposed smart contract address should be removed instead of added to the VC address pool
    bool public stateOfEmergency; //A boolean indicating whether or not democracy shall be revoked in the senate once this law passes
    uint256 public yesCount; //Number of tokens who voted yes
    uint256 public noCount; //Number of tokens who voted no

    modifier restrictedToSenate(){

        require((msg.sender == senate), "Only callable by senate/Can't vote anymore");
        _;
    }

    constructor(address _law, uint256 _duration, bool _revokeLaw, bool _stateOfEmergency) public
    {
        require (_duration >= 60*60*24, "Voting should last at least 24 hours");
        require (_duration <= 60*60*24*366, "Voting should last maximum a year");

        senate = msg.sender;

        law = _law;
        revokeLaw = _revokeLaw;
        stateOfEmergency = _stateOfEmergency;
        enactionTime = now + _duration;

    }

    function vote(bool _vote, address _token)  external restrictedToSenate(){


        require(!tokenWhoVoted[_token], "This token already cast a vote");

        tokenWhoVoted[_token] = true;

        if(_vote){
            yesCount++;
        } else {
            noCount++;
        }

    }

    function enactable()  external restrictedToSenate(){

        require(enactionTime < now, "It is too early to enact the law");
        require(noCount <= yesCount, "Too many voters oppose the law");
        senate = address(0x0); //Disable voting/enacting laws
    }


}// © Copyright 2020. Patent pending. All rights reserved. Perpetual Altruism Ltd.
pragma solidity 0.6.6;


contract SenateProxiedV1 is VCProxy, SenateHeaderV1, SenateStorageInternalV1  {


    constructor(uint256 _version, address _vc)  public
    VCProxy(_version, _vc) //Call the VC proxy constructor so that we know where our logic code is
    {
        lawmaker = msg.sender; //Only the creator of this smart contract will be able to submit new addresses to be voted on
    }


}


pragma solidity 0.6.6;



contract SingleAuctionBidLogicV1 is VCProxyData, SingleAuctionHeaderV1, SingleAuctionStorageInternalV1  {


    modifier restrictedToAuctionHouse(){

        require((msg.sender == auctionHouse), "Only the auction house smart contract can call this function");
        _;
    }


    function bid(uint256 _newBidAmount, address _newBidder) external payable restrictedToAuctionHouse(){



        require(initialized, "This auction has not been properly setup yet");

        require(_newBidAmount == msg.value + currentBids[_newBidder], "Amount of money sent incorrect");

        require( //Either fresh bid or meeting the standing bid * the step
            ((highestBidder == address(0)) && startingPrice <= _newBidAmount) ||
            ( (highestBidder != address(0)) && (currentBids[highestBidder] * (bid_Decimals + bid_stepMin) <= (_newBidAmount * bid_Decimals) )),
            "New bid amount does not meet the minimal new bid amount");


        require(now >= startTime, "You can only bid once the initial auction has started");

        require((now < endTime && TheCryptographLogicV1(myCryptograph).owner() == address(0x0)) ||
        (TheCryptographLogicV1(myCryptograph).owner() != address(0x0) && (hammerTime == 0 || now < hammerTime)),
        "The auction is over, the bid was rejected");

        if(endTime < now + 600 && TheCryptographLogicV1(myCryptograph).owner() == address(0x0)){
            endTime = now + 600;
        }

        if(hammerTime != 0 && now + 600 > hammerTime){
            hammerTime = now + 600; //Extend the hammertime auction by 600s
            hammerBlock = block.number + 4; //Extend the number of minimum elapsed block by 4
        }


        emit BidAccepted(_newBidAmount, _newBidder);


        uint256 duePay;

        if(!(highestBidder == address(0) && TheCryptographLogicV1(myCryptograph).owner() != address(0))){
            duePay = (_newBidAmount * bid_cutOthers)/bid_Decimals;
            unsettledPayouts += duePay;
            distributeStakeholdersPayouts(duePay, _newBidder);
        }

        duePay = duePayout[highestBidder];
        if(duePay != 0){
            unsettledPayouts += duePay;
            emit Payout(duePay,  highestBidder,  _newBidder);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: duePay }(highestBidder, _newBidder);
        }


        calculateReward(_newBidAmount, _newBidder);

        uint256 toSend;

        if ( hammerTime != 0 || TheCryptographLogicV1(myCryptograph).owner() == address(0)) { //Ongoing sale
            
            if(highestBidder != _newBidder){
                toSend = currentBids[highestBidder];
                if(toSend != 0){ //For the case of the first ever bid on an auction : address 0x0 is not cancelling anything...
                    emit BidCancelled(toSend, toSend, highestBidder);
                    AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(highestBidder, highestBidder);
                    delete currentBids[highestBidder];
                    delete duePayout[highestBidder];
                }
            }
        }

            
        if(currentBids[_newBidder] != 0){
            emit BidCancelled(currentBids[_newBidder], 0, _newBidder);

            if( BidLinkSimple(bidLinks[_newBidder]).above() != address(0x0)){
                  BidLinkSimple(BidLinkSimple(bidLinks[_newBidder]).above()).setBelow(BidLinkSimple(bidLinks[_newBidder]).below()); //Unlinking above us
            }

            if(highestBidder != _newBidder){
                if( BidLinkSimple(bidLinks[_newBidder]).below() != address(0x0)){
                    BidLinkSimple(BidLinkSimple(bidLinks[_newBidder]).below()).setAbove(BidLinkSimple(bidLinks[_newBidder]).above()); //Unlinking below us
                }
            }
        }
        


        if(bidLinks[_newBidder] == address(0x0)){
            bidLinks[_newBidder] = address(new BidLinkSimple(_newBidder));
        }

        if(_newBidder != highestBidder){

            BidLinkSimple(bidLinks[_newBidder]).setAbove(address(0x0));

            if( hammerTime == 0 && TheCryptographLogicV1(myCryptograph).owner() != address(0)){ //We did not cancel the previous highest bidder
                BidLinkSimple(bidLinks[_newBidder]).setBelow(bidLinks[highestBidder]);

                if(highestBidder != address(0x0)){
                    BidLinkSimple(bidLinks[highestBidder]).setAbove(bidLinks[_newBidder]);
                }

            } else { //We just cancelled the previous highest bidder

                if(highestBidder != address(0x0)){

                    BidLinkSimple(bidLinks[_newBidder]).setBelow(BidLinkSimple(bidLinks[highestBidder]).below());

                    if(BidLinkSimple(bidLinks[highestBidder]).below() != address(0x0)){
                       BidLinkSimple(BidLinkSimple(bidLinks[highestBidder]).below()).setAbove(bidLinks[_newBidder]);
                    }


                } else {
                    BidLinkSimple(bidLinks[_newBidder]).setBelow(address(0x0));
                }
            }
        }

        currentBids[_newBidder] = _newBidAmount;
        highestBidder = _newBidder; //We are the new highest bidder


        if( sellingPrice != 0 && _newBidAmount >= sellingPrice && hammerTime == 0){
            hammerTime = now + hammerTimeDuration;
            hammerBlock = block.number + hammerBlockDuration;
            emit SaleStarted(_newBidder, hammerTime, hammerBlock);
        }
    }

    function distributeStakeholdersPayouts(uint256 _amount, address _contributor) internal{

        uint256 toDistribute = _amount;
        uint256 toSend;

        toSend = (charityCut * _amount) / bid_Decimals;
        toDistribute -= toSend;
        if(toSend != 0){
            emit Payout(toSend,  charity,  _contributor);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(charity, _contributor);
        }

        toSend = (publisherCut * _amount) / bid_Decimals;
        toDistribute -= toSend;
        if(toSend != 0){
            emit Payout(toSend,  publisher,  _contributor);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(publisher, _contributor);
        }

        toSend = (thirdPartyCut * _amount) / bid_Decimals;
        toDistribute -= toSend;
        if(toSend != 0){
            emit Payout(toSend,  thirdParty,  _contributor);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(thirdParty, _contributor);
        }

        toSend = toDistribute;
        if(toSend != 0){
            emit Payout(toSend,  perpertualAltruism,  _contributor);
            AuctionHouseLogicV1(address(uint160(auctionHouse))).addFundsFor{value: toSend }(perpertualAltruism, _contributor);
        }
    }

    function calculateReward(uint256 _newBid, address _bidder) internal{



        uint256 baseBid = currentBids[highestBidder] * (bid_Decimals + bid_stepMin) / bid_Decimals;
        if(baseBid == 0){
            baseBid = startingPrice;

            if(baseBid == 0){
                baseBid = 1;
            }
        }

        uint256 decimaledRatio = ((bid_Decimals * bid_multiplier * (_newBid - baseBid) ) / baseBid) + bid_incMin * bid_Decimals;

        if(decimaledRatio > (bid_Decimals * bid_incMax)){
            decimaledRatio = bid_Decimals * bid_incMax;
        }

        duePayout[_bidder] = (_newBid * decimaledRatio)/(bid_Decimals*bid_Decimals);
    }

}

pragma solidity 0.6.6;


contract VersionControlHeaderV1 {

    event VCChangedVersion(uint256 index, address oldCode, address newCode);
    event VCCAddedVersion(uint256 index, address newCode);
}


contract VersionControlStorageInternalV1 {

    address[] public code; //Public to shortcut lookups to it in proxy calls
    address internal controller;
    address internal senate;
}


contract VersionControlStoragePublicV1 {

    address[] public code; //Public for ABI reasons, should be internal for strict gas saving
    address public controller;
    address public senate;
}

pragma solidity 0.6.6;


contract VersionControlLogicV1 is VCProxyData, VersionControlHeaderV1, VersionControlStoragePublicV1  {


    constructor() public {
    }

    modifier restrictedToController(){

        require(msg.sender == controller, "Only the controller can call this function");
        _;
    }

    function setVersion(uint256 _version, address _code) public restrictedToController(){ //Need to be restricted to PA only

        bool authorization = senate == address(0x0); //We check if the senate is set
        if(!authorization){ //If the senate is set, ask for authorization
            authorization = SenateLogicV1(senate).isAddressAllowed(_code);
        }
        require(authorization, "The senate -voting smart contract- did not allow this address to be used");
        emit VCChangedVersion(_version, code[_version], _code);
        code[_version] = _code;
    }

    function pushVersion(address _code) public restrictedToController() returns (uint256){ //Need to be restricted to PA only

        bool authorization = senate == address(0x0); //We check if the senate is set
        if(!authorization){ //If the senate is set, ask for authorization
            authorization = SenateLogicV1(senate).isAddressAllowed(_code);
        }
        require(authorization, "The senate -voting smart contract- did not allow this address to be pushed");
        code.push(_code);
        uint256 index = code.length - 1;
        emit VCCAddedVersion(index, _code);
        return index;
    }

    function codeLength() external view returns (uint256){

        return code.length;
    }

    function setSenate (address _senate) public restrictedToController(){
        require(senate == address(0x0), "The senate address has already been set");
        senate = _senate;
    }

}// © Copyright 2020. Patent pending. All rights reserved. Perpetual Altruism Ltd.
pragma solidity 0.6.6;


contract VersionControlProxiedV1 is VCProxy, VersionControlHeaderV1, VersionControlStorageInternalV1  {


    constructor(address _vc)  public
    VCProxy(0, _vc) //Call the VC proxy constructor with 0 as index paramter
    {
        controller = msg.sender;
        code.push(_vc); //Push the address of the VC logic code at index 0
        emit VCCAddedVersion(0, _vc); //Fire relevant push event
    }


    fallback () external payable override{
        address addr = code[version];
        assembly{
            let freememstart := mload(0x40)
            calldatacopy(freememstart, 0, calldatasize())
            let success := delegatecall(not(0), addr, freememstart, calldatasize(), freememstart, 0)
            returndatacopy(freememstart, 0, returndatasize())
            switch success
            case 0 { revert(freememstart, returndatasize()) }
            default { return(freememstart, returndatasize()) }
        }
    }
   
}


