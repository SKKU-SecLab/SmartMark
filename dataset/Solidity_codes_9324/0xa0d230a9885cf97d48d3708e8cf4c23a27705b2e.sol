

pragma solidity ^0.5.6;
pragma experimental ABIEncoderV2;
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

    constructor() internal {
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

contract IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4);

}

contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {

        return this.onERC721Received.selector;
    }
}

interface IMintable {

    function getApproved(uint256 tokenId) external returns (address operator);


    function isApprovedForAll(address owner, address operator) external returns (bool);


    function tokenURI(uint256 tokenId) external returns (string memory);


    function approve(address _to, uint256 _tokenId) external;


    function transfer(address _to, uint256 _tokenId) external;


    function burn(uint256 tokenId) external;


    function mint(string calldata _tokenURI, uint256 _royality) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

}

interface IBrokerV2 {

    struct Asset {
        uint256 _tokenID;
        uint256 _startingPrice;
        uint256 _auctionType;
        uint256 _buyPrice;
        uint256 _startingTime;
        uint256 _closingTime;
        address _mintableToken;
        address _erc20Token;
    }

    struct Pair {
        uint256 tokenID;
        address _mintableToken;
    }

    function bid(
        uint256 tokenID,
        address _mintableToken,
        uint256 amount
    ) external payable;


    function collect(uint256 tokenID, address _mintableToken, bool isNotClubare) external;


    function buy(uint256 tokenID, address _mintableToken, bool isNotClubare) external payable;


    function putOnSale(
        uint256 _tokenID,
        uint256 _startingPrice,
        uint256 _auctionType,
        uint256 _buyPrice,
        uint256 _startingTime,
        uint256 _closingTime,
        address _mintableToken,
        address _erc20Token
    ) external;


    function updatePrice(
        uint256 tokenID,
        address _mintableToken,
        uint256 _newPrice,
        address _erc20Token
    ) external;


    function putSaleOff(uint256 tokenID, address _mintableToken) external;


    function makeAnOffer(
        uint256 tokenID,
        address _mintableToken,
        address _erc20Token,
        uint256 amount
    ) external payable;


    function accpetOffer(
        uint256 tokenID,
        address _mintableToken,
        address _erc20Token, 
        bool isNotClubare
    ) external payable;


    function revertOffer(
        address _mintableToken,
        uint256 tokenID,
        address _erc20Token
    ) external payable;


    function revertAll(address _mintableToken, uint256 tokenID) external;

    
    function batchListing(Asset[] calldata _assets) external;


    function batchDelisting(Pair[] calldata _pairs) external;

    
    function setAddress(address _weth, address _stakeaddress) external;


}

interface IERC20 {

    function approve(address spender, uint256 value) external;


    function decreaseApproval(address _spender, uint256 _subtractedValue)
        external;


    function increaseApproval(address spender, uint256 addedValue) external;


    function transfer(address to, uint256 value) external;


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;


    function increaseAllowance(address spender, uint256 addedValue) external;


    function decreaseAllowance(address spender, uint256 subtractedValue)
        external;


    function balanceOf(address who) external view returns (uint256);

}

contract AdminManager is Ownable, ERC721Holder {

    address[] public admins;

    struct FunctionNames {
        string approve;
        string transfer;
        string burn;
        string mint;
        string safeTransferFrom;
        string transferFrom;
        string putOnSale;
        string buy;
        string bid;
        string collect;
        string updatePrice;
        string putSaleOff;
        string makeAnOffer;
        string accpetOffer;
        string revertOffer;
        string revertAll;
        string erc20Approve;
        string erc20DecreaseApproval;
        string erc20IncreaseApproval;
        string erc20Transfer;
        string erc20TransferFrom;
        string erc20IncreaseAllowance;
        string erc20DecreaseAllowance;
        string batchListing;
        string batchDelisting;
        string setAddress;
    }

    FunctionNames functionNames =
        FunctionNames(
            "ERC721:approve",
            "ERC721:transfer",
            "ERC721:burn",
            "ERC721:mint",
            "ERC721:safeTransferFrom",
            "ERC721:transferFrom",
            "Broker:putOnSale",
            "Broker:buy",
            "Broker:bid",
            "Broker:collect",
            "Broker:updatePrice",
            "Broker:putSaleOff",
            "Broker:makeAnOffer",
            "Broker:accpetOffer",
            "Broker:revertOffer",
            "Broker:revertAll",
            "Broker:batchListing",
            "Broker:batchDelisting",
            "Broker:setAddress",
            "ERC20:approve",
            "ERC20:decreaseApproval",
            "ERC20:increaseApproval",
            "ERC20:transfer",
            "ERC20:transferFrom",
            "ERC20:increaseAllowance",
            "ERC20:decreaseAllowance"
        );

    IBrokerV2 broker;

    event NFTBurned(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed admin,
        uint256 time,
        string tokenURI
    );
    event AdminRemoved(address admin, uint256 time);
    event AdminAdded(address admin, uint256 time);

    event AdminActionPerformed(
        address indexed admin,
        address indexed contractAddress,
        string indexed functionName,
        address collectionAddress,
        uint256 tokenId
    );

    constructor(address _broker) public {
        transferOwnership(msg.sender);
        broker = IBrokerV2(_broker);
    }

    function adminExist(address _sender) public view returns (bool) {

        for (uint256 i = 0; i < admins.length; i++) {
            if (_sender == admins[i]) {
                return true;
            }
        }
        return false;
    }

    modifier adminOnly() {

        require(adminExist(msg.sender), "AdminManager: admin only.");
        _;
    }

    modifier adminAndOwnerOnly() {

        require(
            adminExist(msg.sender) || isOwner(),
            "AdminManager: admin and owner only."
        );
        _;
    }

    function addAdmin(address admin) public onlyOwner {

        if (!adminExist(admin)) {
            admins.push(admin);
        } else {
            revert("admin already in list");
        }

        emit AdminAdded(admin, block.timestamp);
    }

    function getAdmins() public view returns (address[] memory) {

        return admins;
    }

    function removeAdmin(address admin) public onlyOwner {

        for (uint256 i = 0; i < admins.length; i++) {
            if (admins[i] == admin) {
                admins[admins.length - 1] = admins[i];
                admins.pop();
                break;
            }
        }
        emit AdminRemoved(admin, block.timestamp);
    }

    function burnNFT(address collection, uint256 tokenId)
        public
        adminAndOwnerOnly
    {

        IMintable NFTToken = IMintable(collection);

        string memory tokenURI = NFTToken.tokenURI(tokenId);
        require(
            NFTToken.getApproved(tokenId) == address(this),
            "Token not apporove for burn"
        );
        NFTToken.burn(tokenId);
        emit NFTBurned(
            collection,
            tokenId,
            msg.sender,
            block.timestamp,
            tokenURI
        );
    }

    function erc721Approve(
        address _ERC721Address,
        address _to,
        uint256 _tokenId
    ) public adminAndOwnerOnly {

        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.approve,
            _ERC721Address,
            _tokenId
        );
        return erc721.approve(_to, _tokenId);
    }

    function erc721Transfer(
        address _ERC721Address,
        address _to,
        uint256 _tokenId
    ) public adminAndOwnerOnly {

        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.transfer,
            _ERC721Address,
            _tokenId
        );
        return erc721.transfer(_to, _tokenId);
    }

    function erc721Burn(address _ERC721Address, uint256 tokenId)
        public
        adminAndOwnerOnly
    {

        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.burn,
            _ERC721Address,
            tokenId
        );
        return erc721.burn(tokenId);
    }

    function erc721Mint(
        address _ERC721Address,
        string memory tokenURI,
        uint256 _royality
    ) public adminAndOwnerOnly {

        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.mint,
            _ERC721Address,
            0
        );
        return erc721.mint(tokenURI, _royality);
    }

    function erc721SafeTransferFrom(
        address _ERC721Address,
        address from,
        address to,
        uint256 tokenId
    ) public adminAndOwnerOnly {

        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.safeTransferFrom,
            _ERC721Address,
            tokenId
        );
        return erc721.safeTransferFrom(from, to, tokenId);
    }

    function erc721SafeTransferFrom(
        address _ERC721Address,
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public adminAndOwnerOnly {

        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.safeTransferFrom,
            _ERC721Address,
            tokenId
        );
        return erc721.safeTransferFrom(from, to, tokenId, _data);
    }

    function erc721TransferFrom(
        address _ERC721Address,
        address from,
        address to,
        uint256 tokenId
    ) public adminAndOwnerOnly {

        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.transferFrom,
            _ERC721Address,
            tokenId
        );
        return erc721.transferFrom(from, to, tokenId);
    }

    function bid(
        uint256 tokenID,
        address _mintableToken,
        uint256 amount
    ) public payable adminAndOwnerOnly {

        broker.bid.value(msg.value)(tokenID, _mintableToken, amount);
        emit AdminActionPerformed(
            msg.sender,
            address(broker),
            functionNames.bid,
            _mintableToken,
            tokenID
        );
    }

    function collect(uint256 tokenID, address _mintableToken, bool isNotClubare)
        public
        adminAndOwnerOnly
    {

        broker.collect(tokenID, _mintableToken, isNotClubare);
        emit AdminActionPerformed(
            msg.sender,
            address(broker),
            functionNames.collect,
            _mintableToken,
            tokenID
        );
    }

    function buy(uint256 tokenID, address _mintableToken, bool isNotClubare)
        public
        payable
        adminAndOwnerOnly
    {

        broker.buy.value(msg.value)(tokenID, _mintableToken, isNotClubare);
        emit AdminActionPerformed(
            msg.sender,
            address(broker),
            functionNames.buy,
            _mintableToken,
            tokenID
        );
    }

    function putOnSale(
        uint256 _tokenID,
        uint256 _startingPrice,
        uint256 _auctionType,
        uint256 _buyPrice,
        uint256 _startingTime,
        uint256 _closingTime,
        address _mintableToken,
        address _erc20Token
    ) public adminAndOwnerOnly {

        broker.putOnSale(
            _tokenID,
            _startingPrice,
            _auctionType,
            _buyPrice,
            _startingTime,
            _closingTime,
            _mintableToken,
            _erc20Token
        );
        emit AdminActionPerformed(
            msg.sender,
            address(broker),
            functionNames.putOnSale,
            _mintableToken,
            _tokenID
        );
    }

    function updatePrice(
        uint256 tokenID,
        address _mintableToken,
        uint256 _newPrice,
        address _erc20Token
    ) public adminAndOwnerOnly {

        broker.updatePrice(tokenID, _mintableToken, _newPrice, _erc20Token);
        emit AdminActionPerformed(
            msg.sender,
            address(broker),
            functionNames.updatePrice,
            _mintableToken,
            tokenID
        );
    }

    function putSaleOff(uint256 tokenID, address _mintableToken)
        public
        adminAndOwnerOnly
    {

        broker.putSaleOff(tokenID, _mintableToken);
        emit AdminActionPerformed(
            msg.sender,
            address(broker),
            functionNames.putSaleOff,
            _mintableToken,
            tokenID
        );
    }

    function makeAnOffer(
        uint256 tokenID,
        address _mintableToken,
        address _erc20Token,
        uint256 amount
    ) public payable adminAndOwnerOnly {

        broker.makeAnOffer(tokenID, _mintableToken, _erc20Token, amount);
        emit AdminActionPerformed(
            msg.sender,
            address(broker),
            functionNames.makeAnOffer,
            _mintableToken,
            tokenID
        );
    }

    function accpetOffer(
        uint256 tokenID,
        address _mintableToken,
        address _erc20Token,
        bool isNotClubare
    ) public payable adminAndOwnerOnly {

        broker.accpetOffer(tokenID, _mintableToken, _erc20Token, isNotClubare);
        emit AdminActionPerformed(
            msg.sender,
            address(broker),
            functionNames.accpetOffer,
            _mintableToken,
            tokenID
        );
    }

    function revertOffer(
        uint256 tokenID,
        address _mintableToken,
        address _erc20Token
    ) public payable adminAndOwnerOnly {

        broker.revertOffer(_mintableToken,tokenID, _erc20Token);
        emit AdminActionPerformed(
            msg.sender,
            address(broker),
            functionNames.revertOffer,
            _mintableToken,
            tokenID
        );
    }

    function revertAll(uint256 tokenID, address _mintableToken)
        public
        adminAndOwnerOnly
    {

        broker.revertAll(_mintableToken,tokenID);
        emit AdminActionPerformed(
            msg.sender,
            address(broker),
            functionNames.revertAll,
            _mintableToken,
            tokenID
        );
    }

    function erc20Approve(
        address _erc20,
        address spender,
        uint256 value
    ) public adminAndOwnerOnly {

        IERC20 erc20 = IERC20(_erc20);
        erc20.approve(spender, value);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20Approve,
            spender,
            value
        );
    }

    function erc20DecreaseApproval(
        address _erc20,
        address _spender,
        uint256 _subtractedValue
    ) public adminAndOwnerOnly {

        IERC20 erc20 = IERC20(_erc20);
        erc20.decreaseApproval(_spender, _subtractedValue);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20DecreaseAllowance,
            _spender,
            _subtractedValue
        );
    }

    function erc20IncreaseApproval(
        address _erc20,
        address spender,
        uint256 addedValue
    ) public adminAndOwnerOnly {

        IERC20 erc20 = IERC20(_erc20);
        erc20.increaseApproval(spender, addedValue);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20IncreaseApproval,
            spender,
            addedValue
        );
    }

    function erc20Transfer(
        address _erc20,
        address to,
        uint256 value
    ) public adminAndOwnerOnly {

        IERC20 erc20 = IERC20(_erc20);
        erc20.transfer(to, value);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20Transfer,
            to,
            value
        );
    }

    function erc20TransferFrom(
        address _erc20,
        address from,
        address to,
        uint256 value
    ) public adminAndOwnerOnly {

        IERC20 erc20 = IERC20(_erc20);
        erc20.transferFrom(from, to, value);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20TransferFrom,
            to,
            value
        );
    }

    function erc20IncreaseAllowance(
        address _erc20,
        address spender,
        uint256 addedValue
    ) public adminAndOwnerOnly {

        IERC20 erc20 = IERC20(_erc20);
        erc20.increaseAllowance(spender, addedValue);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20IncreaseAllowance,
            spender,
            addedValue
        );
    }

    function erc20DecreaseAllowance(
        address _erc20,
        address spender,
        uint256 subtractedValue
    ) public adminAndOwnerOnly {

        IERC20 erc20 = IERC20(_erc20);
        erc20.decreaseAllowance(spender, subtractedValue);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20DecreaseAllowance,
            spender,
            subtractedValue
        );
    }

    function() external payable {}

    function withdraw() public onlyOwner {

        msg.sender.transfer(address(this).balance);
    }

    function withdrawERC20(address _erc20Token) public onlyOwner {

        IERC20 erc20Token = IERC20(_erc20Token);
        erc20Token.transfer(msg.sender, erc20Token.balanceOf(address(this)));
    }
}