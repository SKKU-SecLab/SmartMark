


pragma solidity ^0.8.4;


contract CloneFactory {

    function createClone(address target) internal returns (address result) {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }

    function isClone(address target, address query)
        internal
        view
        returns (bool result)
    {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000
            )
            mstore(add(clone, 0xa), targetBytes)
            mstore(
                add(clone, 0x1e),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )

            let other := add(clone, 0x40)
            extcodecopy(query, other, 0, 0x2d)
            result := and(
                eq(mload(clone), mload(other)),
                eq(mload(add(clone, 0xd)), mload(add(other, 0xd)))
            )
        }
    }
}



pragma solidity ^0.8.4;

interface IRicardianLLC {

    function mintLLC(address to) external payable;

}



pragma solidity ^0.8.4;

abstract contract ERC1155 {

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);


    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    mapping(address => mapping(address => bool)) public isApprovedForAll;


    function uri(uint256 id) public view virtual returns (string memory);


    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        require(
            msg.sender == from || isApprovedForAll[from][msg.sender],
            "NOT_AUTHORIZED"
        );

        balanceOf[from][id] -= amount;
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, from, to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(
                    msg.sender,
                    from,
                    id,
                    amount,
                    data
                ) == ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender],
            "NOT_AUTHORIZED"
        );

        for (uint256 i = 0; i < idsLength; ) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            balanceOf[from][id] -= amount;
            balanceOf[to][id] += amount;

            unchecked {
                i++;
            }
        }

        emit TransferBatch(msg.sender, from, to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(
                    msg.sender,
                    from,
                    ids,
                    amounts,
                    data
                ) == ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function balanceOfBatch(address[] memory owners, uint256[] memory ids)
        public
        view
        virtual
        returns (uint256[] memory balances)
    {
        uint256 ownersLength = owners.length; // Saves MLOADs.

        require(ownersLength == ids.length, "LENGTH_MISMATCH");

        balances = new uint256[](owners.length);

        unchecked {
            for (uint256 i = 0; i < ownersLength; i++) {
                balances[i] = balanceOf[owners[i]][ids[i]];
            }
        }
    }


    function supportsInterface(bytes4 interfaceId)
        public
        pure
        virtual
        returns (bool)
    {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0xd9b67a26 || // ERC165 Interface ID for ERC1155
            interfaceId == 0x0e89341c; // ERC165 Interface ID for ERC1155MetadataURI
    }


    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal {
        balanceOf[to][id] += amount;

        emit TransferSingle(msg.sender, address(0), to, id, amount);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155Received(
                    msg.sender,
                    address(0),
                    id,
                    amount,
                    data
                ) == ERC1155TokenReceiver.onERC1155Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[to][ids[i]] += amounts[i];

            unchecked {
                i++;
            }
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);

        require(
            to.code.length == 0
                ? to != address(0)
                : ERC1155TokenReceiver(to).onERC1155BatchReceived(
                    msg.sender,
                    address(0),
                    ids,
                    amounts,
                    data
                ) == ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _batchBurn(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal {
        uint256 idsLength = ids.length; // Saves MLOADs.

        require(idsLength == amounts.length, "LENGTH_MISMATCH");

        for (uint256 i = 0; i < idsLength; ) {
            balanceOf[from][ids[i]] -= amounts[i];

            unchecked {
                i++;
            }
        }

        emit TransferBatch(msg.sender, from, address(0), ids, amounts);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal {
        balanceOf[from][id] -= amount;

        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }
}

interface ERC1155TokenReceiver {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external returns (bytes4);

}




pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}



pragma solidity ^0.8.4;




contract Club is ERC1155 {

    using Counters for Counters.Counter;
    using SafeMath for uint256;

    string public name;
    string public symbol;
    string public docs;
    address public safeAddress;
    address public referralAddress;
    address internal coterieAddress;
    uint256 public maxMembers;

    Counters.Counter public memberCounter;
    Counters.Counter public tokenCounter;

    mapping(address => bool) public members;
    mapping(uint256 => Token) public tokens;

    bool internal locked;

    struct Token {
        uint256 mintPrice;
        uint256 startTime;
        uint256 endTime;
        string ipfsCID;
        uint256 maximum;
        uint256 minted;
        uint256 maxAmount;
        bool exists;
    }

    event Minted(address who, uint256 tokenIndex, uint256 amount);
    event Withdrew(uint256 amountSentToSafe, uint256 percentageFee);
    event Kicked(address who);
    event Joined(address who);

    error UnknownToken();
    error AlreadyInitialized();
    error NotEnoughFunds();
    error NotMember();

    modifier onlySafe() {

        require(
            msg.sender == safeAddress,
            "Only the safe can call this function"
        );
        _;
    }

    modifier onlyCoterie() {

        require(
            msg.sender == coterieAddress,
            "Only coterie can call this function"
        );
        _;
    }

    modifier onTime(uint256 startTime, uint256 endTime) {

        require(startTime < endTime, "Start time must be before end time");
        require(startTime > 0 && endTime > 0, "Time window cannot be 0");
        _;
    }

    modifier inMemberLimits(uint256 _maxMembers, string memory _docs) {

        if (bytes(_docs).length == 0) {
            require(_maxMembers > 0, "Max members must be greater than 0");
            require(_maxMembers <= 100, "Max members must be less than 100");
        } else {
            require(_maxMembers > 0, "Max members must be greater than 0");
        }
        _;
    }

    function _kick(address to) internal {

        if (!members[to]) revert NotMember();

        for (uint256 i = 0; i < tokenCounter.current(); i++) {
            if (balanceOf[to][i] > 0) {
                balanceOf[to][i] = 0;
            }
        }

        memberCounter.decrement();
        members[to] = false;

        emit Kicked(to);
    }

    function _getTokenValues(address to) internal view returns (uint256) {

        if (!members[to]) revert NotMember();

        uint256 total = 0;

        for (uint256 i = 0; i < tokenCounter.current(); i++) {
            if (balanceOf[to][i] > 0) {
                total = total.add(balanceOf[to][i].mul(tokens[i].mintPrice));
            }
        }

        return total;
    }

    function _addMember(address to) internal {

        require(!members[to], "Member already exists");

        members[to] = true;
        memberCounter.increment();

        emit Joined(to);
    }

    function setCoterieAddress(address _coterieAddress) external onlyCoterie {

        coterieAddress = _coterieAddress;
    }

    function init(
        string memory _clubName,
        string memory _tokenSymbol,
        string memory _docs,
        uint256 _maxMembers,
        address _safeAddress,
        address _referralAddress
    ) external inMemberLimits(_maxMembers, _docs) {

        if (safeAddress != address(0)) revert AlreadyInitialized();
        require(
            _safeAddress != _referralAddress,
            "Safe address cannot be the same as referral address"
        );

        name = _clubName;
        symbol = _tokenSymbol;
        docs = _docs;
        safeAddress = _safeAddress;
        referralAddress = _referralAddress;
        maxMembers = _maxMembers;
        coterieAddress = 0x7c5252031d236d5A17db832Fc8367e6850a3b4FB;
    }

    function createFundingRound(
        uint256 mintPrice,
        uint256 startTime,
        uint256 endTime,
        uint256 maximum,
        uint256 maxAmount,
        string memory ipfsCID
    ) external onlySafe onTime(startTime, endTime) {

        Token storage token = tokens[tokenCounter.current()];
        token.mintPrice = mintPrice;
        token.startTime = startTime;
        token.endTime = endTime;
        token.ipfsCID = ipfsCID;
        token.maximum = maximum;
        token.minted = 0;
        token.maxAmount = maxAmount;
        token.exists = true;

        tokenCounter.increment();
    }

    function editFundingRound(
        uint256 id,
        uint256 mintPrice,
        uint256 startTime,
        uint256 endTime
    ) external onlySafe onTime(startTime, endTime) {

        if (!tokens[id].exists) revert UnknownToken();

        tokens[id].mintPrice = mintPrice;
        tokens[id].startTime = startTime;
        tokens[id].endTime = endTime;
    }

    function editTokenMintMaximum(uint256 id, uint256 maximum)
        external
        onlySafe
    {

        if (!tokens[id].exists) revert UnknownToken();

        tokens[id].maximum = maximum;
    }

    function editTokenMaxAmount(uint256 id, uint256 maxAmount)
        external
        onlySafe
    {

        if (!tokens[id].exists) revert UnknownToken();

        tokens[id].maxAmount = maxAmount;
    }

    function editTokenIPFS(uint256 id, string memory ipfsCID)
        external
        onlySafe
    {

        if (!tokens[id].exists) revert UnknownToken();

        tokens[id].ipfsCID = ipfsCID;
    }

    function editMaximumMembers(uint256 _maxMembers)
        external
        onlySafe
        inMemberLimits(_maxMembers, docs)
    {

        maxMembers = _maxMembers;
    }

    function mint(uint256 tokenIndex, uint256 amount) external payable {

        if (!tokens[tokenIndex].exists) revert UnknownToken();
        if (tokens[tokenIndex].maxAmount > 0) {
            require(
                amount <=
                    tokens[tokenIndex].maxAmount.sub(
                        balanceOf[msg.sender][tokenIndex]
                    ),
                "Cannot mint over max amount"
            );
        }
        require(amount > 0, "Amount must be greater than 0");
        require(
            block.timestamp > tokens[tokenIndex].startTime &&
                block.timestamp < tokens[tokenIndex].endTime,
            "time window closed"
        );
        if (msg.value < amount.mul(tokens[tokenIndex].mintPrice))
            revert NotEnoughFunds();
        if (tokens[tokenIndex].maximum > 0) {
            require(
                tokens[tokenIndex].minted.add(amount) <=
                    tokens[tokenIndex].maximum,
                "Maximum amount of tokens minted"
            );
        }

        if (!members[msg.sender]) {
            if (memberCounter.current() >= maxMembers) revert("Club is full");
            members[msg.sender] = true;
            memberCounter.increment();

            emit Joined(msg.sender);
        }

        _mint(msg.sender, tokenIndex, amount, "");
        tokens[tokenIndex].minted = tokens[tokenIndex].minted.add(amount);

        emit Minted(msg.sender, tokenIndex, amount);
    }

    function withdraw() external onlySafe {

        require(safeAddress != address(0), "Club not initialized");
        require(address(this).balance > 0, "No funds to withdraw");

        uint256 balance = address(this).balance;
        uint256 rate = 500;

        if (balance >= 50 ether && balance < 85 ether) {
            rate = 425;
        } else if (balance >= 85 ether && balance < 100 ether) {
            rate = 385;
        } else if (balance >= 100 ether && balance < 250 ether) {
            rate = 325;
        } else if (balance >= 250 ether && balance < 500 ether) {
            rate = 250;
        } else if (balance >= 500 ether) {
            rate = 200;
        }

        uint256 coterieFee = address(this).balance.mul(rate).div(10000);
        uint256 referralFee = 0;

        if (referralAddress != address(0)) {
            referralFee = coterieFee.div(10);
            (bool referralSuccess, ) = referralAddress.call{value: referralFee}(
                ""
            );
            if (!referralSuccess) {
                revert("referral address failed to receive funds");
            }
        }

        (bool coterieSuccess, ) = coterieAddress.call{
            value: coterieFee.sub(referralFee)
        }("");
        if (!coterieSuccess) {
            revert("Coterie address failed to receive funds");
        }

        uint256 amountSentToSafe = address(this).balance;

        (bool safeSuccess, ) = safeAddress.call{value: amountSentToSafe}("");
        if (!safeSuccess) {
            revert("Safe address failed to receive funds");
        }

        emit Withdrew(amountSentToSafe, rate);
    }

    function kick(address to) external payable onlySafe {

        uint256 totalEtherToReturn = _getTokenValues(to);

        if (msg.value < totalEtherToReturn) revert NotEnoughFunds();

        _kick(to);

        (bool success, ) = to.call{value: totalEtherToReturn}("");
        if (!success) {
            revert("Failed to send funds to kicked member");
        }
    }

    function kickMultiple(address[] calldata to) external payable onlySafe {

        require(to.length > 0, "No members to kick");
        require(
            to.length <= memberCounter.current(),
            "Too many addresses provided"
        );
        require(msg.value > 0, "No ether was sent");

        int256 balance = int256(msg.value);

        for (uint256 i = 0; i < to.length; i++) {
            uint256 etherToReturn = _getTokenValues(to[i]);
            balance = balance - int256(etherToReturn);

            if (balance < 0) revert NotEnoughFunds();

            _kick(to[i]);

            (bool success, ) = to[i].call{value: etherToReturn}("");
            if (!success) {
                revert("Failed to send funds to kicked member");
            }
        }
    }

    function addMember(address to) public onlySafe {

        require(memberCounter.current() < maxMembers, "Club is full");

        _addMember(to);
    }

    function addMembers(address[] calldata to) external onlySafe {

        require(to.length > 0, "No members to add");
        require(
            to.length.add(memberCounter.current()) <= maxMembers,
            "Too many addresses provided"
        );

        for (uint256 i = 0; i < to.length; i++) {
            _addMember(to[i]);
        }
    }

    function uri(uint256 id) public view override returns (string memory) {

        if (!tokens[id].exists) revert UnknownToken();

        return string(abi.encodePacked("ipfs://", tokens[id].ipfsCID));
    }
}



pragma solidity ^0.8.4;




contract ClubCreator is CloneFactory {

    address immutable masterClub;
    IRicardianLLC immutable ricardianLLC;

    mapping(address => Club) public clubs;

    event ClubCreated(
        address clubAddress,
        string clubName,
        string tokenSymbol,
        string docs,
        uint256 maxMembers,
        address safeAddress,
        address referalAddress
    );

    constructor(address _masterClub, IRicardianLLC _ricardianLLC) {
        masterClub = _masterClub;
        ricardianLLC = _ricardianLLC;
    }

    function createClub(
        string memory _clubName,
        string memory _tokenSymbol,
        string memory _docs,
        uint256 _maxMembers,
        address _safeAddress,
        address _referalAddress
    ) external {

        require(clubs[_safeAddress] == Club(address(0)), "Club already exists");

        Club club = Club(createClone(masterClub));
        club.init(
            _clubName,
            _tokenSymbol,
            _docs,
            _maxMembers,
            _safeAddress,
            _referalAddress
        );

        if (bytes(_docs).length == 0) {
            ricardianLLC.mintLLC(_safeAddress);
        }

        clubs[_safeAddress] = club;

        emit ClubCreated(
            address(club),
            _clubName,
            _tokenSymbol,
            _docs,
            _maxMembers,
            _safeAddress,
            _referalAddress
        );
    }
}