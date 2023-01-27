


pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



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

}


pragma solidity >=0.6.6 <0.9.0;

interface IMarket {


    struct Lending {
        address lender;
        address nftAddress;
        uint256 nftId;
        uint256 pricePerSecond;
        uint64 maxEndTime;
        uint64 minDuration;
        uint64 nonce;
        uint64 version;
    }
    struct Renting {
        address payable renterAddress;
        uint64 startTime;
        uint64 endTime;
    }

    struct Royalty {
        uint256 fee;
        uint256 balance;
        address payable beneficiary;
    }

    struct Credit{
        mapping(uint256=>Lending) lendingMap;
    }

    event CreateLendOrder(address lender,address nftAddress,uint256 nftId,uint64 maxEndTime,uint64 minDuration,uint256 pricePerSecond);
    event CancelLendOrder(address lender,address nftAddress,uint256 nftId);
    event FulfillOrder(address renter,address lender,address nftAddress,uint256 nftId,uint64 startTime,uint64 endTime,uint256 pricePerSecond,uint256 newId);
    event Paused(address account);
    event Unpaused(address account);
    function mintAndCreateLendOrder(
        address resolverAddress,
        uint256 oNftId,
        uint64 maxEndTime,
        uint64 minDuration,
        uint256 pricePerSecond
    ) external ;


    function createLendOrder(
        address nftAddress,
        uint256 nftId,
        uint64 maxEndTime,
        uint64 minDuration,
        uint256 pricePerSecond
    ) external;


    function cancelLendOrder(address nftAddress,uint256 nftId) external;


    function getLendOrder(address nftAddress,uint256 nftId) external view returns (Lending memory lenting);

    
    function fulfillOrder(address nftAddress,uint256 tokenId,uint256 durationId,uint64 startTime,uint64 endTime) external payable returns(uint256 tid);


    function fulfillOrderNow(address nftAddress,uint256 tokenId,uint256 durationId,uint64 duration) external payable returns(uint256 tid);


    function setFee(uint256 fee) external;


    function setMarketBeneficiary(address payable beneficiary) external;


    function claimFee() external;


    function setRoyalty(address nftAddress,uint256 fee) external;


    function setRoyaltyBeneficiary(address nftAddress,address payable beneficiary) external;


    function claimRoyalty(address nftAddress) external;


    function isLendOrderValid(address nftAddress,uint256 nftId) external view returns (bool);


    function setPause(bool v) external;


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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}


pragma solidity 0.8.10;



interface IBaseDoNFT is IERC721Receiver {

    struct Duration{
        uint64 start; 
        uint64 end;
    }

    struct DoNftInfo {
        uint256 oid;
        uint64 nonce;
        EnumerableSet.UintSet durationList;
    }

    event MetadataUpdate(uint256 tokenId);

    event DurationUpdate(uint256 durationId,uint256 tokenId,uint64 start,uint64 end);

    event DurationBurn(uint256[] durationIdList);

    event CheckIn(address opreator,address to,uint256 tokenId,uint256 durationId);

    function init(address address_,string memory name_, string memory symbol_) external;


    function isWrap() external pure returns(bool);


    function mintXNft(uint256 oid) external returns(uint256 tid);


    function mint(uint256 tokenId,uint256 durationId,uint64 start,uint64 end,address to) external returns(uint256 tid);


    function setMaxDuration(uint64 v) external;


    function getDurationIdList(uint256 tokenId) external view returns(uint256[] memory);


    function getDurationListLength(uint256 tokenId) external view returns(uint256);


    function getDoNftInfo(uint256 tokenId) external view returns(uint256 oid, uint256[] memory durationIds,uint64[] memory starts,uint64[] memory ends,uint64 nonce);


    function getNonce(uint256 tokenId) external view returns(uint64);


    function getDuration(uint256 durationId) external view returns(uint64 start, uint64 end);


    function getDurationByIndex(uint256 tokenId,uint256 index) external view returns(uint256 durationId,uint64 start, uint64 end);


    function getXNftId(uint256 originalNftId) external view returns(uint256);


    function isXNft(uint256 tokenId) external view returns(bool);


    function isValidNow(uint256 tokenId) external view returns(bool isValid);


    function getOriginalNftAddress() external view returns(address);


    function getOriginalNftId(uint256 tokenId) external view returns(uint256);


    function checkIn(address to,uint256 tokenId,uint256 durationId) external;


    function getUser(uint256 orignalNftId) external returns(address);


    function exists(uint256 tokenId) external view returns (bool);


    
}


pragma solidity 0.8.10;




interface LandInterface{

    function decodeTokenId(uint value) external view returns (int, int);

}

interface EstateInterface{

    function getEstateSize(uint256 estateId) external view returns (uint256);

    function estateLandIds(uint256 tokenId, uint256 index) external view returns (uint256);

}

interface IDclNft is IERC721 {

    function updateOperator(uint256 tokenId)  external view returns (address);

    function exists(uint256 tokenId) external view returns (bool);

}

interface IDoNFT is IBaseDoNFT, IERC721 {


}

contract MiddleWare{


    function getLandData(address land, address estate, uint256 estId, uint256 _pageNumber, uint256 pageSize) public view returns(int[] memory x, int[] memory y, uint256[] memory landIds, uint256 pageNumber){

        LandInterface landInterface = LandInterface(land);
        EstateInterface estateInterface = EstateInterface(estate);
        uint256 estateSize = estateInterface.getEstateSize(estId);
        uint256 start = _pageNumber * pageSize;
        uint256 end = ( _pageNumber + 1) * pageSize;
        if(end < estateSize){
            pageNumber = _pageNumber + 1;
        }else{
            end = estateSize;
            pageNumber = 0;
        }
        landIds = new uint256[](end - start);
        x = new int[](end - start);
        y = new int[](end - start);
        uint256 count;
        for(uint256 i=start; i<end; i++){
            landIds[count] = estateInterface.estateLandIds(estId, i);
            (int _x, int _y) = landInterface.decodeTokenId(landIds[count]);
            x[count] = _x;
            y[count] = _y;

            count++;
        }
    }

     function getLandOrEstInfo(address nftAddr, uint256 nftId) public  view returns (address owner , address operator) {

        IDclNft dclNft = IDclNft(nftAddr);
        if(dclNft.exists(nftId)){
            owner = dclNft.ownerOf(nftId);
            operator= dclNft.updateOperator(nftId);
        }
    }

    function getDclOperatorByDoNft(address nftAddr, uint256 nftId) public  view returns (address operator) {

        IDoNFT doNft = IDoNFT(nftAddr);
        uint256 oid = doNft.getOriginalNftId(nftId);
        address oNftAddr = doNft.getOriginalNftAddress();
        IDclNft dclNft = IDclNft(oNftAddr);
        operator = dclNft.updateOperator(oid);
    }
    

    function getDoLandOrDoEstInfo(address nftAddr, uint256 nftId, address marketAddr) public view  
        returns (address owner , address operator, uint64 startTime, uint64 endTime, bool isLendOrderValid, uint64 minDuration, uint64 maxEndTime, uint256 pricePerSecond) {


        IDoNFT doNft = IDoNFT(nftAddr);
        if(doNft.exists(nftId)){
            owner = doNft.ownerOf(nftId);
            operator = getDclOperatorByDoNft(nftAddr, nftId);
            (,startTime, endTime)  = doNft.getDurationByIndex(nftId, 0);
            IMarket market = IMarket(marketAddr);
            isLendOrderValid = market.isLendOrderValid(nftAddr, nftId);
            if(isLendOrderValid) {
                IMarket.Lending memory lenting  = market.getLendOrder(nftAddr, nftId);
                pricePerSecond = lenting.pricePerSecond;
                minDuration = lenting.minDuration;
                maxEndTime = lenting.maxEndTime;
            }
        }
    }
}