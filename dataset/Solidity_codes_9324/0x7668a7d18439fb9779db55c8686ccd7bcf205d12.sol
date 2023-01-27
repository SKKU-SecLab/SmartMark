


pragma solidity ^0.5.5;


contract IOwnable {


    function transferOwnership1(address newOwner)
        public;


    function transferOwnership2(address newOwner)
        public;

}



pragma solidity ^0.5.5;



contract Ownable is
    IOwnable
{

    address public owner1;
    address public owner2;

    constructor ()
        public
    {
        owner1 = msg.sender;
        owner2 = msg.sender;
    }

    modifier onlyOwner() {

        require(
            (msg.sender == owner1) || (msg.sender == owner2),
            "ONLY_CONTRACT_OWNER"
        );
        _;
    }

    function transferOwnership1(address newOwner)
        public
        onlyOwner
    {

        if (newOwner != address(0)) {
            owner1 = newOwner;
        }
    }

    function transferOwnership2(address newOwner)
        public
        onlyOwner
    {

        if (newOwner != address(0)) {
            owner2 = newOwner;
        }
    }

}



pragma solidity ^0.5.5;
pragma experimental ABIEncoderV2;



contract Registry is
    Ownable
{



    bool public paused = false;




    address[] private registrants;

    mapping (address => bool) public isWhitelisted;

    mapping (address => uint) public registrantTimestamp;

    mapping (address => address) private registrantToReferrer;

    mapping (address => address[]) private referrerToRegistrants;

    struct ContentIdStruct {
        string contentId;
    }
    mapping (address => ContentIdStruct[]) private addressToContentIds;

    mapping (string => address) private contentIdToAddress;



    constructor ()
        public
    {

    }




    modifier whenNotPaused() {

        require(!paused);
        _;
    }

    modifier whenPaused {

        require(paused);
        _;
    }

    function pause() external onlyOwner whenNotPaused {

        paused = true;
    }

    function unpause() public onlyOwner whenPaused {

        paused = false;
    }




    function adminUpdate(
        address target,
        string memory contentId,
        bool isApproved
    )
        public
        onlyOwner
        whenNotPaused
    {


        address previousOwner = contentIdToAddress[contentId];

        if (previousOwner != target) {

            if (previousOwner != 0x0000000000000000000000000000000000000000) {
                adminRemoveContentIdFromAddress(previousOwner, contentId);
            }

            addressToContentIds[target].push( ContentIdStruct(contentId) );
            contentIdToAddress[contentId] = target;

        }

        if (!hasRegistered(target)) {
            registrants.push(target);
            registrantTimestamp[target] = block.timestamp;
        }

        isWhitelisted[target] = isApproved;

    }


    function adminUpdateWithReferrer(
        address target,
        string memory contentId,
        bool isApproved,
        address referrer
    )
        public
        onlyOwner
        whenNotPaused
    {


        require(
            isWhitelisted[referrer],
            'INVALID_REFERRER'
        );

        adminUpdate(target, contentId, isApproved);

        adminUpdateReferrer(target, referrer);

    }


    function adminUpdateReferrer(
        address registrant,
        address referrer
    )
        public
        onlyOwner
        whenNotPaused
    {


        require(
            hasRegistered(registrant),
            'INVALID_REGISTRANT'
        );

        require(
            isWhitelisted[referrer],
            'INVALID_REFERRER'
        );

        require(
            registrant != referrer,
            'INVALID_REFERRER'
        );

        require(
            registrantToReferrer[registrant] != referrer,
            'REFERRER_UPDATE_IS_REDUNDANT'
        );

        address previousReferrer = registrantToReferrer[registrant];

        if (previousReferrer != 0x0000000000000000000000000000000000000000) {
            address[] memory a = referrerToRegistrants[previousReferrer];
            for (uint i = 0; i < a.length; i++) {
                if (a[i] == registrant) {
                    referrerToRegistrants[previousReferrer][i] = 0x0000000000000000000000000000000000000000;
                }
            }
        }

        registrantToReferrer[registrant] = referrer;
        referrerToRegistrants[referrer].push(registrant);

    }

    function adminUpdateWhitelistStatus(
        address target,
        bool isApproved
    )
        external
        onlyOwner
        whenNotPaused
    {


        require(
            isApproved != isWhitelisted[target],
            'NO_STATUS_UPDATE_REQUIRED'
        );

        if (isApproved == true) {
            require(
                getNumContentIds(target) > 0,
                'ADDRESS_HAS_NO_ASSOCIATED_CONTENT_IDS'
            );
        }

        isWhitelisted[target] = isApproved;

    }

    function adminRemoveContentIdFromAddress(
        address target,
        string memory contentId
    )
        public
        onlyOwner
        whenNotPaused
    {


        require(
            contentIdToAddress[contentId] == target,
            'CONTENT_ID_DOES_NOT_BELONG_TO_ADDRESS'
        );

        contentIdToAddress[contentId] = address(0x0000000000000000000000000000000000000000);

        ContentIdStruct[] memory m = addressToContentIds[target];
        for (uint i = 0; i < m.length; i++) {
            if (stringsMatch(contentId, m[i].contentId)) {
                addressToContentIds[target][i] = ContentIdStruct('');
            }
        }

        if (getNumContentIds(target) == 0) {
            isWhitelisted[target] = false;
        }

    }

    function adminRemoveAllContentIdsFromAddress(
        address target
    )
        public
        onlyOwner
        whenNotPaused
    {


        ContentIdStruct[] memory m = addressToContentIds[target];
        for (uint i = 0; i < m.length; i++) {
            addressToContentIds[target][i] = ContentIdStruct('');
        }

        isWhitelisted[target] = false;

    }




    function adminGetAddressByContentId(
        string calldata contentId
    )
        external
        view
        onlyOwner
        returns (address target)
    {


        return contentIdToAddress[contentId];

    }

    function adminGetContentIdsByAddress(
        address target
    )
        external
        view
        onlyOwner
        returns (string[] memory)
    {


        ContentIdStruct[] memory m = addressToContentIds[target];
        string[] memory r = new string[](m.length);

        for (uint i = 0; i < m.length; i++) {
            r[i] =  m[i].contentId;
        }

        return r;

    }


    function adminGetRegistrantByIndex (
        uint index
    )
        external
        view
        returns (address)
    {

        return registrants[index];

    }




    function hasRegistered (
        address target
    )
        public
        view
        returns(bool)
    {

        bool _hasRegistered = false;
        for (uint i=0; i<registrants.length; i++) {
            if (registrants[i] == target) {
                return _hasRegistered = true;
            }
        }

    }

    function getRegistrantCount ()
        external
        view
        returns (uint)
    {

        return registrants.length;

    }

    function getRegistrantByIndex (
        uint index
    )
        external
        view
        returns (address)
    {

        address target = registrants[index];

        require(
            isWhitelisted[target],
            'INVALID_ADDRESS'
        );

        return target;
    }

    function getRegistrantToReferrer(address registrant)
        external
        view
        returns (address)
    {


        return registrantToReferrer[registrant];

    }

    function getReferrerToRegistrants(address referrer)
        external
        view
        returns (address[] memory)
    {


        return referrerToRegistrants[referrer];

    }

    function getContentIdsByAddress(
        address target
    )
        external
        view
        returns (string[] memory)
    {


        require(
            isWhitelisted[target],
            'INVALID_ADDRESS'
        );

        ContentIdStruct[] memory m = addressToContentIds[target];
        string[] memory r = new string[](m.length);

        for (uint i = 0; i < m.length; i++) {
            r[i] =  m[i].contentId;
        }

        return r;

    }

    function getAddressByContentId(
        string calldata contentId
    )
        external
        view
        returns (address)
    {


        address target = contentIdToAddress[contentId];

        require(
            isWhitelisted[target],
            'INVALID_ADDRESS'
        );

        return target;
    }




    function removeContentIdFromAddress(
        string calldata contentId
    )
        external
        whenNotPaused
    {


        require(
            isWhitelisted[msg.sender],
            'INVALID_SENDER'
        );

        require(
            contentIdToAddress[contentId] == msg.sender,
            'CONTENT_ID_DOES_NOT_BELONG_TO_SENDER'
        );

        contentIdToAddress[contentId] = address(0x0000000000000000000000000000000000000000);

        ContentIdStruct[] memory m = addressToContentIds[msg.sender];
        for (uint i = 0; i < m.length; i++) {
            if (stringsMatch(contentId, m[i].contentId)) {
                addressToContentIds[msg.sender][i] = ContentIdStruct('');
            }
        }

        if (getNumContentIds(msg.sender) == 0) {
            isWhitelisted[msg.sender] = false;
        }

    }

    function removeAllContentIdsFromAddress(
        address target
    )
        external
        whenNotPaused
    {


        require(
            isWhitelisted[msg.sender],
            'INVALID_SENDER'
        );

        require(
            target == msg.sender,
            'INVALID_SENDER'
        );

        ContentIdStruct[] memory m = addressToContentIds[target];
        for (uint i = 0; i < m.length; i++) {
            addressToContentIds[target][i] = ContentIdStruct('');
        }

        isWhitelisted[target] = false;

    }






    function isContentIdRegisteredToCaller(
        uint32 federationId,
        string memory contentId
    )
        public
        view
        returns (bool)
    {


        require(federationId > 0, 'INVALID_FEDERATION_ID');

        require(
            isWhitelisted[tx.origin],
            'INVALID_SENDER'
        );

        address registrantAddress = contentIdToAddress[contentId];

        require(
            registrantAddress == tx.origin,
            'INVALID_SENDER'
        );

        return true;

    }

    function isMinter(
        uint32 federationId,
        address account
    )
        public
        view
        returns (bool)
    {


        require(federationId > 0, 'INVALID_FEDERATION_ID');

        require(
            isWhitelisted[account],
            'INVALID_MINTER'
        );

        return true;

    }

    function isAuthorizedTransferFrom(
        uint32 federationId,
        address from,
        address to,
        uint256 tokenId,
        address minter,
        address owner
    )
        public
        view
        returns (bool)
    {


        require(federationId > 0, 'INVALID_FEDERATION_ID');

        require(
            isWhitelisted[minter],
            'INVALID_TRANSFER_MINTER'
        );

        require(
            tokenId > 0,
            'INVALID_TOKEN_ID'
        );

        require(
            from != to,
            'INVALID_TRANSFER'
        );

        require(
            owner != address(0),
            'INVALID_TRANSFER'
        );

        return true;

    }




    function stringsMatch (
        string memory a,
        string memory b
    )
        private
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
    }


    function getNumContentIds (
        address target
    )
        private
        view
        returns (uint16)
    {

        ContentIdStruct[] memory m = addressToContentIds[target];
        uint16 counter = 0;
        for (uint i = 0; i < m.length; i++) {
            if (!stringsMatch('', m[i].contentId)) {
                counter++;
            }
        }

        return counter;

    }




    function() external payable {
        require(
            msg.sender == address(0)
        );
    }


}