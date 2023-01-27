


pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.8.0;

interface IERC721 is IERC165 {

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


pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}


pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {

        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


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

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {

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
}


pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}


pragma solidity ^0.8.0;

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {

        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {

        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {

        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {

        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {

        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {

        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

}

pragma solidity ^0.8.4;

contract NFTeacket is ERC721 {
    enum TicketType {
        Maker,
        Taker
    }

    enum OptionType {
        CallBuy,
        CallSale,
        PutBuy,
        PutSale
    }

    struct OptionDataMaker {
        uint256 price; // The price of the option
        uint256 strike; // The strike price of the option
        uint256 settlementTimestamp; // The maturity timestamp of the option
        uint256 takerTicketId; // The taker ticket ID of this order
        uint256 nftId; // The nft token ID of the option
        address nftContract; // The smart contract address of the nft
        OptionType optionType; // Type of the option
    }

    struct OptionDataTaker {
        uint256 makerTicketId;
    }

    address public nftea;

    mapping(uint256 => TicketType) _ticketIdToType;

    mapping(uint256 => OptionDataMaker) private _ticketIdToOptionDataMaker;

    mapping(uint256 => OptionDataTaker) private _ticketIdToOptionDataTaker;

    uint256 private _counter;

    modifier onylyFromNFTea() {
        require(msg.sender == nftea, "NFTeacket: not called from nftea");
        _;
    }

    constructor(address _nftea) ERC721("NFTeacket", "NBOT") {
        nftea = _nftea;
    }

    function mintMakerTicket(address to, OptionDataMaker memory data)
        external
        onylyFromNFTea
        returns (uint256 ticketId)
    {
        ticketId = _counter++;
        _safeMint(to, ticketId);
        _ticketIdToOptionDataMaker[ticketId] = data;
        _ticketIdToType[ticketId] = TicketType.Maker;
    }

    function mintTakerTicket(address to, OptionDataTaker memory data)
        public
        onylyFromNFTea
        returns (uint256 ticketId)
    {
        ticketId = _counter++;
        _safeMint(to, ticketId);
        _ticketIdToOptionDataTaker[ticketId] = data;
        _ticketIdToType[ticketId] = TicketType.Taker;
    }

    function ticketIdToType(uint256 ticketId) public view returns (TicketType) {
        require(_exists(ticketId), "NFTeacket: ticket does not exist");
        return _ticketIdToType[ticketId];
    }

    function ticketIdToOptionDataMaker(uint256 ticketId)
        external
        view
        returns (OptionDataMaker memory)
    {
        require(
            ticketIdToType(ticketId) == TicketType.Maker,
            "NFTeacket: Not a maker ticket"
        );
        return _ticketIdToOptionDataMaker[ticketId];
    }

    function ticketIdToOptionDataTaker(uint256 ticketId)
        external
        view
        returns (OptionDataTaker memory)
    {
        require(
            ticketIdToType(ticketId) == TicketType.Taker,
            "NFTeacket: Not a taker ticket"
        );
        return _ticketIdToOptionDataTaker[ticketId];
    }

    function linkMakerToTakerTicket(
        uint256 makerTicketId,
        uint256 takerTicketId
    ) external onylyFromNFTea {
        _ticketIdToOptionDataMaker[makerTicketId].takerTicketId = takerTicketId;
    }

    function burnTicket(uint256 ticketId) external onylyFromNFTea {
        this.ticketIdToType(ticketId) == TicketType.Maker
            ? delete _ticketIdToOptionDataMaker[ticketId]
            : delete _ticketIdToOptionDataTaker[ticketId];

        delete _ticketIdToType[ticketId];

        _burn(ticketId);
    }
}

pragma solidity ^0.8.4;

contract NFTea {
    event OrderCreated(uint256 makerTicketId, NFTeacket.OptionDataMaker data);
    event OrderCancelled(uint256 makerTicketId);
    event OrderFilled(uint256 takerTicketId, NFTeacket.OptionDataTaker data);
    event OptionUsed(uint256 makerTicketId, bool value);

    address public admin;
    address public nfteacket;

    uint256 public maxDelayToClaim;
    uint256 public optionFees;
    uint256 public saleFees;

    modifier onlyAdmin() {
        require(msg.sender == admin, "NFTea: not admin");
        _;
    }

    modifier onlyWhenNFTeacketSet() {
        require(nfteacket != address(0), "NFTea: nfteacket not set");
        _;
    }

    constructor() {
        admin = msg.sender;
        optionFees = 3;
        saleFees = 1;
        maxDelayToClaim = 1 days;
    }

    function changeAdmin(address _admin) external onlyAdmin {
        admin = _admin;
    }

    function setMaxDelayToClaim(uint256 delay) external onlyAdmin {
        maxDelayToClaim = delay;
    }

    function setOptionFees(uint256 fee) external onlyAdmin {
        require(fee < 100, "NFTea: incorret fee value");
        optionFees = fee;
    }

    function setSaleFees(uint256 fee) external onlyAdmin {
        require(fee < 100, "NFTea: incorret fee value");
        saleFees = fee;
    }

    function collectFees() external onlyAdmin {
        _transferEth(msg.sender, address(this).balance);
    }

    function setNFTeacket(address _nfteacket) external onlyAdmin {
        nfteacket = _nfteacket;
    }

    function makeOrder(
        uint256 optionPrice,
        uint256 strikePrice,
        uint256 settlementTimestamp,
        uint256 nftId,
        address nftContract,
        NFTeacket.OptionType optionType
    ) external payable onlyWhenNFTeacketSet {
        require(
            settlementTimestamp > block.timestamp,
            "NFTea: Incorrect timestamp"
        );

        if (optionType == NFTeacket.OptionType.CallBuy) {
            _requireEthSent(optionPrice);
        } else if (optionType == NFTeacket.OptionType.CallSale) {
            _requireEthSent(0);
            _lockNft(nftId, nftContract);
        } else if (optionType == NFTeacket.OptionType.PutBuy) {
            _requireEthSent(optionPrice);
        } else {
            _requireEthSent(strikePrice);
        }

        NFTeacket.OptionDataMaker memory data = NFTeacket.OptionDataMaker({
            price: optionPrice,
            strike: strikePrice,
            settlementTimestamp: settlementTimestamp,
            nftId: nftId,
            nftContract: nftContract,
            takerTicketId: 0,
            optionType: optionType
        });

        uint256 makerTicketId = NFTeacket(nfteacket).mintMakerTicket(
            msg.sender,
            data
        );

        emit OrderCreated(makerTicketId, data);
    }

    function cancelOrder(uint256 makerTicketId) external onlyWhenNFTeacketSet {
        NFTeacket _nfteacket = NFTeacket(nfteacket);

        _requireTicketOwner(msg.sender, makerTicketId);

        NFTeacket.OptionDataMaker memory optionData = _nfteacket
            .ticketIdToOptionDataMaker(makerTicketId);

        require(optionData.takerTicketId == 0, "NFTea: Order already filled");

        if (optionData.optionType == NFTeacket.OptionType.CallBuy) {
            _transferEth(msg.sender, optionData.price);
        } else if (optionData.optionType == NFTeacket.OptionType.CallSale) {
            _transferNft(
                address(this),
                msg.sender,
                optionData.nftId,
                optionData.nftContract
            );
        } else if (optionData.optionType == NFTeacket.OptionType.PutBuy) {
            _transferEth(msg.sender, optionData.price);
        } else {
            _transferEth(msg.sender, optionData.strike);
        }

        _nfteacket.burnTicket(makerTicketId);

        emit OrderCancelled(makerTicketId);
    }

    function fillOrder(uint256 makerTicketId)
        external
        payable
        onlyWhenNFTeacketSet
    {
        NFTeacket _nfteacket = NFTeacket(nfteacket);

        NFTeacket.OptionDataMaker memory optionData = _nfteacket
            .ticketIdToOptionDataMaker(makerTicketId);

        uint256 optionPriceSubFees = (optionData.price * (100 - optionFees)) /
            100;

        require(
            block.timestamp < optionData.settlementTimestamp,
            "NFTea: Obsolete order"
        );

        require(optionData.takerTicketId == 0, "NFTea: Order already filled");

        if (optionData.optionType == NFTeacket.OptionType.CallBuy) {
            _requireEthSent(0);
            _lockNft(optionData.nftId, optionData.nftContract);

            _transferEth(msg.sender, optionPriceSubFees);
        } else if (optionData.optionType == NFTeacket.OptionType.CallSale) {
            _requireEthSent(optionData.price);

            address maker = _nfteacket.ownerOf(makerTicketId);
            _transferEth(maker, optionPriceSubFees);
        } else if (optionData.optionType == NFTeacket.OptionType.PutBuy) {
            _requireEthSent(optionData.strike);

            _transferEth(msg.sender, optionPriceSubFees);
        } else {
            _requireEthSent(optionData.price);

            address maker = _nfteacket.ownerOf(makerTicketId);
            _transferEth(maker, optionPriceSubFees);
        }

        NFTeacket.OptionDataTaker memory data = NFTeacket.OptionDataTaker({
            makerTicketId: makerTicketId
        });

        uint256 takerTicketId = _nfteacket.mintTakerTicket(msg.sender, data);

        _nfteacket.linkMakerToTakerTicket(makerTicketId, takerTicketId);

        emit OrderFilled(takerTicketId, data);
    }

    function useBuyerRightAtMaturity(uint256 ticketId)
        external
        payable
        onlyWhenNFTeacketSet
    {
        NFTeacket _nfteacket = NFTeacket(nfteacket);

        _requireTicketOwner(msg.sender, ticketId);

        NFTeacket.OptionDataMaker memory makerOptionData;
        uint256 makerTicketId;
        address ethReceiver;
        address nftReceiver;
        address nftSender;

        NFTeacket.TicketType ticketType = _nfteacket.ticketIdToType(ticketId);

        if (ticketType == NFTeacket.TicketType.Maker) {
            makerOptionData = _nfteacket.ticketIdToOptionDataMaker(ticketId);

            makerTicketId = ticketId;

            address taker = _nfteacket.ownerOf(makerOptionData.takerTicketId);

            if (makerOptionData.optionType == NFTeacket.OptionType.CallBuy) {
                _requireEthSent(makerOptionData.strike);

                ethReceiver = taker;
                nftSender = address(this);
                nftReceiver = msg.sender;
            } else if (
                makerOptionData.optionType == NFTeacket.OptionType.PutBuy
            ) {
                _requireEthSent(0);

                ethReceiver = msg.sender;
                nftSender = msg.sender;
                nftReceiver = taker;
            } else {
                revert("NFTea: Not a buyer");
            }
        } else {
            NFTeacket.OptionDataTaker memory takerOptionData = _nfteacket
                .ticketIdToOptionDataTaker(ticketId);

            makerOptionData = _nfteacket.ticketIdToOptionDataMaker(
                takerOptionData.makerTicketId
            );

            makerTicketId = takerOptionData.makerTicketId;

            address maker = _nfteacket.ownerOf(takerOptionData.makerTicketId);

            if (makerOptionData.optionType == NFTeacket.OptionType.CallSale) {
                _requireEthSent(makerOptionData.strike);

                ethReceiver = maker;
                nftSender = address(this);
                nftReceiver = msg.sender;
            } else if (
                makerOptionData.optionType == NFTeacket.OptionType.PutSale
            ) {
                _requireEthSent(0);

                ethReceiver = msg.sender;
                nftSender = msg.sender;
                nftReceiver = maker;
            } else {
                revert("NFTea: Not a buyer");
            }
        }

        require(
            block.timestamp >= makerOptionData.settlementTimestamp &&
                block.timestamp <
                makerOptionData.settlementTimestamp + maxDelayToClaim,
            "NFTea: Can't use buyer right"
        );

        uint256 strikePriceSubFees = (makerOptionData.strike *
            (100 - saleFees)) / 100;

        _transferEth(ethReceiver, strikePriceSubFees);
        _transferNft(
            nftSender,
            nftReceiver,
            makerOptionData.nftId,
            makerOptionData.nftContract
        );

        _nfteacket.burnTicket(makerTicketId);
        _nfteacket.burnTicket(makerOptionData.takerTicketId);

        emit OptionUsed(makerTicketId, true);
    }

    function withdrawLockedCollateralAtMaturity(uint256 ticketId)
        external
        onlyWhenNFTeacketSet
    {
        NFTeacket _nfteacket = NFTeacket(nfteacket);

        _requireTicketOwner(msg.sender, ticketId);

        NFTeacket.TicketType ticketType = _nfteacket.ticketIdToType(ticketId);

        NFTeacket.OptionDataMaker memory makerOptionData;
        uint256 makerTicketId;
        bool withdrawSucceed;

        if (ticketType == NFTeacket.TicketType.Maker) {
            makerOptionData = _nfteacket.ticketIdToOptionDataMaker(ticketId);
            makerTicketId = ticketId;

            require(
                block.timestamp >=
                    makerOptionData.settlementTimestamp + maxDelayToClaim,
                "NFTea: Can't withdraw collateral now"
            );

            if (makerOptionData.optionType == NFTeacket.OptionType.CallSale) {
                _transferNft(
                    address(this),
                    msg.sender,
                    makerOptionData.nftId,
                    makerOptionData.nftContract
                );
                withdrawSucceed = true;
            } else if (
                makerOptionData.optionType == NFTeacket.OptionType.PutSale
            ) {
                _transferEth(msg.sender, makerOptionData.strike);
                withdrawSucceed = true;
            } else {
                withdrawSucceed = false;
            }
        } else {
            NFTeacket.OptionDataTaker memory takerOptionData = _nfteacket
                .ticketIdToOptionDataTaker(ticketId);

            makerOptionData = _nfteacket.ticketIdToOptionDataMaker(
                takerOptionData.makerTicketId
            );

            makerTicketId = takerOptionData.makerTicketId;

            require(
                block.timestamp >=
                    makerOptionData.settlementTimestamp + maxDelayToClaim,
                "NFTea: Can't withdraw collateral now"
            );

            if (makerOptionData.optionType == NFTeacket.OptionType.CallBuy) {
                _transferNft(
                    address(this),
                    msg.sender,
                    makerOptionData.nftId,
                    makerOptionData.nftContract
                );
                withdrawSucceed = true;
            } else if (
                makerOptionData.optionType == NFTeacket.OptionType.PutBuy
            ) {
                _transferEth(msg.sender, makerOptionData.strike);
                withdrawSucceed = true;
            } else {
                withdrawSucceed = false;
            }
        }

        if (withdrawSucceed) {
            _nfteacket.burnTicket(makerTicketId);
            _nfteacket.burnTicket(makerOptionData.takerTicketId);

            emit OptionUsed(makerTicketId, false);
        } else {
            revert("NFTea: Not a seller");
        }
    }

    function _requireTicketOwner(address spender, uint256 ticketId)
        private
        view
    {
        address owner = NFTeacket(nfteacket).ownerOf(ticketId);
        require(owner == spender, "NFTea: Not ticket owner");
    }

    function _requireEthSent(uint256 amount) private view {
        require(msg.value == amount, "NFTea: Incorrect sent ETH amount");
    }

    function _lockNft(uint256 nftId, address nftContractAddress) private {
        IERC721 nftContract = IERC721(nftContractAddress);
        address owner = nftContract.ownerOf(nftId);

        require(owner == msg.sender, "NFTea : Not nft owner");

        require(
            address(this) == owner ||
                nftContract.getApproved(nftId) == address(this) ||
                nftContract.isApprovedForAll(owner, address(this)),
            "NFTea : Contract not approved, can't lock nft"
        );

        nftContract.transferFrom(msg.sender, address(this), nftId);
    }

    function _transferNft(
        address from,
        address to,
        uint256 nftId,
        address nft
    ) private {
        IERC721 nftContract = IERC721(nft);
        nftContract.transferFrom(from, to, nftId);
    }

    function _transferEth(address to, uint256 amount) private {
        (bool success, ) = to.call{value: amount}("");
        require(success, "NFTea: Eth transfer failed");
    }
}


pragma solidity ^0.8.4;

contract CustomERC721 is ERC721 {
    uint256 private _counter;

    constructor() ERC721("CustomERC721", "NFK") {}

    function mint(address to) public {
        uint256 tokenId = _counter++;
        _safeMint(to, tokenId);
    }
}