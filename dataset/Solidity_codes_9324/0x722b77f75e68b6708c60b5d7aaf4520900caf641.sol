
pragma solidity ^0.5.0;


contract Context {

    constructor() internal {}


    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC721 {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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


    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IERC1155 {


    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _amount
    );

    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _amounts
    );

    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    event URI(string _amount, uint256 indexed _id);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes calldata _data
    ) external;


    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        bytes calldata _data
    ) external;


    function balanceOf(address _owner, uint256 _id)
        external
        view
        returns (uint256);


    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address _operator, bool _approved) external;


    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool);

}

interface IERC1155Metadata {


    function uri(uint256 _id) external view returns (string memory);

}

library Strings {

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d,
        string memory _e
    ) internal pure returns (string memory) {

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde =
            new string(
                _ba.length + _bb.length + _bc.length + _bd.length + _be.length
            );
        bytes memory babcde = bytes(abcde);
        uint256 k = 0;
        for (uint256 i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (uint256 i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (uint256 i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (uint256 i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (uint256 i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c,
        string memory _d
    ) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(
        string memory _a,
        string memory _b,
        string memory _c
    ) internal pure returns (string memory) {

        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b)
        internal
        pure
        returns (string memory)
    {

        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {

        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath#mul: OVERFLOW");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath#sub: UNDERFLOW");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath#add: OVERFLOW");

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;

        bytes32 accountHash =
            0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

contract BondlySwap is Ownable {

    using Strings for string;
    using SafeMath for uint256;
    using Address for address;

    enum TokenType {T20, T1155, T721}

    enum SwapType {TimedSwap, FixedSwap}

    struct Collection {
        address[] cardContractAddrs;
        uint256[] cardTokenIds; // amount for T20
        TokenType[] tokenTypes;
        uint256 nLength;
        address collectionOwner;
    }

    struct BSwap {
        uint256 totalAmount;
        uint256 currentAmount;
        Collection maker;
        bool isPrivate;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        SwapType swapType;
        Collection target;
        uint256 nAllowedBiddersLength;
        mapping(address => bool) allowedBidders;
    }

    mapping(uint256 => BSwap) private listings;
    uint256 public listIndex;

    uint256 public platformFee;
    address payable public feeCollector;
    uint256 public t20Fee;

    address private originCreator;

    mapping(address => bool) public whitelist;

    mapping(address => bool) public supportTokens;

    bool private emergencyStop;

    event AddedNewToken(address indexed tokenAddress);
    event BatchAddedNewToken(address[] tokenAddress);
    event NFTListed(uint256 listId, address indexed lister);
    event ListVisibilityChanged(uint256 listId, bool isPrivate);
    event ListEndTimeChanged(uint256 listId, uint256 endTime);
    event NFTSwapped(uint256 listId, address indexed buyer, uint256 count);
    event NFTClosed(uint256 listId, address indexed closer);

    event WhiteListAdded(address indexed addr);
    event WhiteListRemoved(address indexed addr);
    event BatchWhiteListAdded(address[] addr);
    event BatchWhiteListRemoved(address[] addr);

    constructor() public {
        originCreator = msg.sender;
        emergencyStop = false;
        listIndex = 0;

        platformFee = 1;
        feeCollector = msg.sender;
        t20Fee = 5;
    }

    modifier onlyNotEmergency() {

        require(emergencyStop == false, "BSwap: emergency stop");
        _;
    }

    modifier onlyValidList(uint256 listId) {

        require(listIndex >= listId, "Bswap: list not found");
        _;
    }

    modifier onlyListOwner(uint256 listId) {

        require(
            listings[listId].maker.collectionOwner == msg.sender || isOwner(),
            "Bswap: not your list"
        );
        _;
    }

    function _addNewToken(address contractAddr)
        public
        onlyOwner
        returns (bool)
    {

        require(
            supportTokens[contractAddr] == false,
            "BSwap: already supported"
        );
        supportTokens[contractAddr] = true;

        emit AddedNewToken(contractAddr);
        return true;
    }

    function _batchAddNewToken(address[] memory contractAddrs)
        public
        onlyOwner
        returns (bool)
    {

        for (uint256 i = 0; i < contractAddrs.length; i++) {
            require(
                supportTokens[contractAddrs[i]] == false,
                "BSwap: already supported"
            );
            supportTokens[contractAddrs[i]] = true;
        }

        emit BatchAddedNewToken(contractAddrs);
        return true;
    }

    function _sendToken(
        TokenType tokenType,
        address contractAddr,
        uint256 tokenId,
        address from,
        address to
    ) internal {

        if (tokenType == TokenType.T1155) {
            IERC1155(contractAddr).safeTransferFrom(from, to, tokenId, 1, "");
        } else if (tokenType == TokenType.T721) {
            IERC721(contractAddr).safeTransferFrom(from, to, tokenId, "");
        } else {
            IERC20(contractAddr).transferFrom(from, to, tokenId);
        }
    }

    function createSwap(
        uint256[] memory arrTokenTypes,
        address[] memory arrContractAddr,
        uint256[] memory arrTokenIds,
        uint256 swapType,
        uint256 endTime,
        bool _isPrivate,
        address[] memory bidders,
        uint256 batchCount
    ) public payable onlyNotEmergency {

        bool isWhitelisted = false;

        require(
            arrContractAddr.length == arrTokenIds.length &&
                arrTokenIds.length == arrTokenTypes.length,
            "BSwap: array lengths are different"
        );
        require(
            arrContractAddr.length > 1,
            "BSwap: expected more than 1 desire"
        );
        require(batchCount >= 1, "BSwap: expected more than 1 count");
        for (uint256 i = 0; i < arrTokenTypes.length; i++) {
            require(
                supportTokens[arrContractAddr[i]] == true,
                "BSwap: not supported"
            );

            if (isWhitelisted == false) {
                isWhitelisted = whitelist[arrContractAddr[i]];
            }

            if (i == 0) {
                if (arrTokenTypes[i] == uint256(TokenType.T1155)) {
                    IERC1155 _t1155Contract = IERC1155(arrContractAddr[i]);
                    require(
                        _t1155Contract.balanceOf(msg.sender, arrTokenIds[i]) >=
                            batchCount,
                        "BSwap: Do not have nft"
                    );
                    require(
                        _t1155Contract.isApprovedForAll(
                            msg.sender,
                            address(this)
                        ) == true,
                        "BSwap: Must be approved"
                    );
                } else if (arrTokenTypes[i] == uint256(TokenType.T721)) {
                    IERC721 _t721Contract = IERC721(arrContractAddr[i]);
                    require(
                        _t721Contract.ownerOf(arrTokenIds[i]) == msg.sender,
                        "BSwap: Do not have nft"
                    );
                    require(
                        batchCount == 1,
                        "BSwap: Don't support T721 Batch Swap"
                    );
                    require(
                        _t721Contract.isApprovedForAll(
                            msg.sender,
                            address(this)
                        ) == true,
                        "BSwap: Must be approved"
                    );
                }
            }
        }

        if (isWhitelisted == false) {
            uint256 _fee = msg.value;
            require(_fee >= platformFee.mul(10**16), "BSwap: out of fee");

            feeCollector.transfer(_fee);
        }

        address _makerContract = arrContractAddr[0];
        uint256 _makerTokenId = arrTokenIds[0];
        TokenType _makerTokenType = TokenType(arrTokenTypes[0]);

        Collection memory _maker;
        _maker.nLength = 1;
        _maker.collectionOwner = msg.sender;
        _maker.cardContractAddrs = new address[](1);
        _maker.cardTokenIds = new uint256[](1);
        _maker.tokenTypes = new TokenType[](1);
        _maker.cardContractAddrs[0] = _makerContract;
        _maker.cardTokenIds[0] = _makerTokenId;
        _maker.tokenTypes[0] = _makerTokenType;

        Collection memory _target;
        uint256 _targetLength = arrTokenTypes.length - 1;
        _target.nLength = _targetLength;
        _target.collectionOwner = address(0);
        _target.cardContractAddrs = new address[](_targetLength);
        _target.cardTokenIds = new uint256[](_targetLength);
        _target.tokenTypes = new TokenType[](_targetLength);
        for (uint256 i = 0; i < _targetLength; i++) {
            _target.cardContractAddrs[i] = arrContractAddr[i + 1];
            _target.cardTokenIds[i] = arrTokenIds[i + 1];
            _target.tokenTypes[i] = TokenType(arrTokenTypes[i + 1]);
        }

        uint256 _id = _getNextListID();
        _incrementListId();
        BSwap storage list = listings[_id];

        list.totalAmount = batchCount;
        list.currentAmount = batchCount;
        list.maker = _maker;
        list.target = _target;
        list.isPrivate = _isPrivate;
        list.startTime = block.timestamp;
        list.endTime = block.timestamp + endTime;
        list.isActive = true;
        list.swapType = SwapType(swapType);
        list.nAllowedBiddersLength = bidders.length;
        for (uint256 i = 0; i < bidders.length; i++) {
            list.allowedBidders[bidders[i]] = true;
        }

        emit NFTListed(_id, msg.sender);
    }

    function swapNFT(uint256 listId, uint256 batchCount)
        public
        payable
        onlyValidList(listId)
        onlyNotEmergency
    {

        require(batchCount >= 1, "BSwap: expected more than 1 count");

        BSwap storage list = listings[listId];
        Collection memory _target = list.target;
        Collection memory _maker = list.maker;
        address lister = _maker.collectionOwner;

        bool isWhitelisted = false;

        require(
            list.isActive == true && list.currentAmount > 0,
            "BSwap: list is closed"
        );
        require(
            list.currentAmount >= batchCount,
            "BSwap: exceed current supply"
        );
        require(
            list.swapType == SwapType.FixedSwap ||
                list.endTime > block.timestamp,
            "BSwap: time is over"
        );
        require(
            list.isPrivate == false || list.allowedBidders[msg.sender] == true,
            "Bswap: not whiltelisted"
        );

        for (uint256 i = 0; i < _target.tokenTypes.length; i++) {
            if (isWhitelisted == false) {
                isWhitelisted = whitelist[_target.cardContractAddrs[i]];
            }

            if (_target.tokenTypes[i] == TokenType.T1155) {
                IERC1155 _t1155Contract =
                    IERC1155(_target.cardContractAddrs[i]);
                require(
                    _t1155Contract.balanceOf(
                        msg.sender,
                        _target.cardTokenIds[i]
                    ) > 0,
                    "BSwap: Do not have nft"
                );
                require(
                    _t1155Contract.isApprovedForAll(
                        msg.sender,
                        address(this)
                    ) == true,
                    "BSwap: Must be approved"
                );
                _t1155Contract.safeTransferFrom(
                    msg.sender,
                    lister,
                    _target.cardTokenIds[i],
                    batchCount,
                    ""
                );
            } else if (_target.tokenTypes[i] == TokenType.T721) {
                IERC721 _t721Contract = IERC721(_target.cardContractAddrs[i]);
                require(
                    batchCount == 1,
                    "BSwap: Don't support T721 Batch Swap"
                );
                require(
                    _t721Contract.ownerOf(_target.cardTokenIds[i]) ==
                        msg.sender,
                    "BSwap: Do not have nft"
                );
                require(
                    _t721Contract.isApprovedForAll(msg.sender, address(this)) ==
                        true,
                    "BSwap: Must be approved"
                );
                _t721Contract.safeTransferFrom(
                    msg.sender,
                    lister,
                    _target.cardTokenIds[i],
                    ""
                );
            } else {
                IERC20 _t20Contract = IERC20(_target.cardContractAddrs[i]);
                uint256 tokenAmount = _target.cardTokenIds[i].mul(batchCount);
                require(
                    _t20Contract.balanceOf(msg.sender) >= tokenAmount,
                    "BSwap: Do not enough funds"
                );
                require(
                    _t20Contract.allowance(msg.sender, address(this)) >=
                        tokenAmount,
                    "BSwap: Must be approved"
                );

                uint256 amountToPlatform = tokenAmount.mul(t20Fee).div(100);
                uint256 amountToLister = tokenAmount.sub(amountToPlatform);
                _t20Contract.transferFrom(
                    msg.sender,
                    feeCollector,
                    amountToPlatform
                );
                _t20Contract.transferFrom(msg.sender, lister, amountToLister);
            }
        }

        if (isWhitelisted == false) {
            isWhitelisted = whitelist[_maker.cardContractAddrs[0]];
        }

        if (isWhitelisted == false) {
            uint256 _fee = msg.value;
            require(_fee >= platformFee.mul(10**16), "BSwap: out of fee");

            feeCollector.transfer(_fee);
        }

        _sendToken(
            _maker.tokenTypes[0],
            _maker.cardContractAddrs[0],
            _maker.cardTokenIds[0],
            lister,
            msg.sender
        );

        list.currentAmount = list.currentAmount.sub(batchCount);
        if (list.currentAmount == 0) {
            list.isActive = false;
        }

        emit NFTSwapped(listId, msg.sender, batchCount);
    }

    function closeList(uint256 listId)
        public
        onlyValidList(listId)
        onlyListOwner(listId)
        returns (bool)
    {

        BSwap storage list = listings[listId];
        list.isActive = false;

        emit NFTClosed(listId, msg.sender);
        return true;
    }

    function setVisibility(uint256 listId, bool _isPrivate)
        public
        onlyValidList(listId)
        onlyListOwner(listId)
        returns (bool)
    {

        BSwap storage list = listings[listId];
        list.isPrivate = _isPrivate;

        emit ListVisibilityChanged(listId, _isPrivate);
        return true;
    }

    function increaseEndTime(uint256 listId, uint256 amount)
        public
        onlyValidList(listId)
        onlyListOwner(listId)
        returns (bool)
    {

        BSwap storage list = listings[listId];
        list.endTime = list.endTime.add(amount);

        emit ListEndTimeChanged(listId, list.endTime);
        return true;
    }

    function decreaseEndTime(uint256 listId, uint256 amount)
        public
        onlyValidList(listId)
        onlyListOwner(listId)
        returns (bool)
    {

        BSwap storage list = listings[listId];
        require(
            list.endTime.sub(amount) > block.timestamp,
            "BSwap: can't revert time"
        );
        list.endTime = list.endTime.sub(amount);

        emit ListEndTimeChanged(listId, list.endTime);
        return true;
    }

    function addWhiteListAddress(address addr) public onlyOwner returns (bool) {

        whitelist[addr] = true;

        emit WhiteListAdded(addr);
        return true;
    }

    function batchAddWhiteListAddress(address[] memory addr)
        public
        onlyOwner
        returns (bool)
    {

        for (uint256 i = 0; i < addr.length; i++) {
            whitelist[addr[i]] = true;
        }

        emit BatchWhiteListAdded(addr);
        return true;
    }

    function removeWhiteListAddress(address addr)
        public
        onlyOwner
        returns (bool)
    {

        whitelist[addr] = false;

        emit WhiteListRemoved(addr);
        return true;
    }

    function batchRemoveWhiteListAddress(address[] memory addr)
        public
        onlyOwner
        returns (bool)
    {

        for (uint256 i = 0; i < addr.length; i++) {
            whitelist[addr[i]] = false;
        }

        emit BatchWhiteListRemoved(addr);
        return true;
    }

    function _setPlatformFee(uint256 _fee) public onlyOwner returns (uint256) {

        platformFee = _fee;
        return platformFee;
    }

    function _setFeeCollector(address payable addr)
        public
        onlyOwner
        returns (bool)
    {

        feeCollector = addr;
        return true;
    }

    function _setT20Fee(uint256 _fee) public onlyOwner returns (uint256) {

        t20Fee = _fee;
        return t20Fee;
    }

    function getOfferingTokens(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (
            TokenType[] memory,
            address[] memory,
            uint256[] memory
        )
    {

        BSwap storage list = listings[listId];
        Collection memory maker = list.maker;
        address[] memory cardContractAddrs =
            new address[](maker.cardContractAddrs.length);
        TokenType[] memory tokenTypes =
            new TokenType[](maker.tokenTypes.length);
        uint256[] memory cardTokenIds =
            new uint256[](maker.cardTokenIds.length);
        for (uint256 i = 0; i < maker.cardContractAddrs.length; i++) {
            cardContractAddrs[i] = maker.cardContractAddrs[i];
            tokenTypes[i] = maker.tokenTypes[i];
            cardTokenIds[i] = maker.cardTokenIds[i];
        }
        return (tokenTypes, cardContractAddrs, cardTokenIds);
    }

    function getDesiredTokens(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (
            TokenType[] memory,
            address[] memory,
            uint256[] memory
        )
    {

        BSwap storage list = listings[listId];
        Collection memory target = list.target;
        address[] memory cardContractAddrs =
            new address[](target.cardContractAddrs.length);
        TokenType[] memory tokenTypes =
            new TokenType[](target.tokenTypes.length);
        uint256[] memory cardTokenIds =
            new uint256[](target.cardTokenIds.length);
        for (uint256 i = 0; i < target.cardContractAddrs.length; i++) {
            cardContractAddrs[i] = target.cardContractAddrs[i];
            tokenTypes[i] = target.tokenTypes[i];
            cardTokenIds[i] = target.cardTokenIds[i];
        }
        return (tokenTypes, cardContractAddrs, cardTokenIds);
    }

    function isAvailable(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (bool)
    {

        BSwap storage list = listings[listId];
        Collection memory maker = list.maker;
        address lister = maker.collectionOwner;
        for (uint256 i = 0; i < maker.cardContractAddrs.length; i++) {
            if (maker.tokenTypes[i] == TokenType.T1155) {
                IERC1155 _t1155Contract = IERC1155(maker.cardContractAddrs[i]);
                if (
                    _t1155Contract.balanceOf(lister, maker.cardTokenIds[i]) == 0
                ) {
                    return false;
                }
            } else if (maker.tokenTypes[i] == TokenType.T721) {
                IERC721 _t721Contract = IERC721(maker.cardContractAddrs[i]);
                if (_t721Contract.ownerOf(maker.cardTokenIds[i]) != lister) {
                    return false;
                }
            }
        }

        return true;
    }

    function isWhitelistedToken(address addr)
        public
        view
        returns (bool)
    {

        return whitelist[addr];
    }

    function isSupportedToken(address addr)
        public
        view
        returns (bool)
    {

        return supportTokens[addr];
    }

    function isAcive(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (bool)
    {

        BSwap memory list = listings[listId];

        return
            list.isActive &&
            (list.swapType == SwapType.FixedSwap ||
                list.endTime > block.timestamp);
    }

    function isPrivate(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (bool)
    {

        return listings[listId].isPrivate;
    }

    function getSwapType(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (uint256)
    {

        return uint256(listings[listId].swapType);
    }

    function getEndingTime(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (uint256)
    {

        return listings[listId].endTime;
    }

    function getTotalAmount(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (uint256)
    {

        return listings[listId].totalAmount;
    }

    function getCurrentAmount(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (uint256)
    {

        return listings[listId].currentAmount;
    }

    function getStartTime(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (uint256)
    {

        return listings[listId].startTime;
    }

    function getPeriod(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (uint256)
    {

        if (listings[listId].endTime <= block.timestamp) return 0;

        return listings[listId].endTime.sub(block.timestamp);
    }

    function isAllowedForList(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (bool)
    {

        return listings[listId].allowedBidders[msg.sender];
    }

    function getOwnerOfList(uint256 listId)
        public
        view
        onlyValidList(listId)
        returns (address)
    {

        return listings[listId].maker.collectionOwner;
    }

    function _getNextListID() private view returns (uint256) {

        return listIndex.add(1);
    }

    function _incrementListId() private {

        listIndex = listIndex.add(1);
    }

    function transferERC20(address erc20) public {

        require(msg.sender == originCreator, "BSwap: you are not admin");
        uint256 amount = IERC20(erc20).balanceOf(address(this));
        IERC20(erc20).transfer(msg.sender, amount);
    }

    function transferETH() public {

        require(msg.sender == originCreator, "BSwap: you are not admin");
        msg.sender.transfer(address(this).balance);
    }
}