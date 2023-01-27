
pragma solidity ^0.8.0;

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

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

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

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}

interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

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

library Strings {

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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {

    using Address for address;
    using Strings for uint256;

    string internal _name;

    string private _symbol;

    string private _tokenBaseURI;

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

        return _tokenBaseURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {

        _tokenBaseURI = baseURI_;
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

        _setApprovalForAll(_msgSender(), operator, approved);
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

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
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
                return retval == IERC721Receiver.onERC721Received.selector;
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

interface Token is IERC20 {
    function burn(address account, uint256 amount) external returns (bool);
}

interface Collection is IERC721 {
    function getTokenClanId(uint256 id) external view returns (uint8);
}

contract Staking is IERC721Receiver, Ownable {
    struct Staker {
        uint256 islApes;
        uint256 genApes;
        uint256[] islApeIDs;
        uint256[] genApeIDs;
        uint256 multiplier;
        uint256 rewarded;
        uint256 recent;
    }

    uint256 public _rate = 5 ether;
    uint256 public _multiplier = 10;
    uint256 public _pack = 2;

    mapping(address => Staker) private _stakingDetails;

    uint256 private _totalStakedIslApes;
    uint256 private _totalStakedGenApes;
    uint256 private _totalStakedRewards;

    address public immutable _APE_ONLY_ISLAND_COLLECTION_CA;
    address public immutable _GENESIS_APE_ONLY_CA;

    address public _APE_ONLY_ISLAND_TOKEN_CA;

    event Staked(address indexed account, uint256 id);

    event Unstaked(address indexed account, uint256 id);

    event Rewarded(address indexed account, uint256 amount);

    event Funded(address indexed account, uint256 amount);

    constructor() {
        _APE_ONLY_ISLAND_TOKEN_CA = 0x3aF3eeC33fE5B1af5cE4E1F3BA32e64Ab78912B2;
        _APE_ONLY_ISLAND_COLLECTION_CA = 0x260428e36989ee6c6829F8a6E361cba99C7a8447;
        _GENESIS_APE_ONLY_CA = 0xf1e0bEcA4eac65F902466881CDfDD0099D91e47b;
    }

    function setTokenAddress(address token) external onlyOwner returns (bool) {
        _APE_ONLY_ISLAND_TOKEN_CA = token;
        return true;
    }

    function stakeWithMultiplier(
        uint256 packs,
        uint256[] calldata islApes,
        uint256[] calldata genApes
    ) external returns (bool) {
        address account = _msgSender();
        uint256 minimum = _pack * packs;

        require(
            _totalStakedRewards > 0,
            "Staking: no staking rewards available"
        );

        require(
            packs > 0,
            "Staking: minimum argument of island apes not valid"
        );

        require(
            IERC721(_APE_ONLY_ISLAND_COLLECTION_CA).balanceOf(account) >=
                minimum,
            "Staking: minimum of island apes for pack size not found"
        );

        uint256 islApesLength = islApes.length;
        uint256 genApesLength = genApes.length;

        require(
            genApesLength <= islApesLength,
            "Staking: genesis ape length must not be larger than island ape length"
        );

        require(
            islApesLength == minimum,
            "Staking: minimum of island apes for pack size not found"
        );

        require(
            _stakingDetails[account].islApes == 0,
            "Staking: account must unstake to stake"
        );

        uint8 packsClan = getClanId(islApes[0]);

        for (uint256 i = 0; i < islApesLength; i++) {
            require(
                IERC721(_APE_ONLY_ISLAND_COLLECTION_CA).ownerOf(islApes[i]) ==
                    account,
                "Staking: account must be the owner of all island ape <ID> inputs"
            );

            require(
                packsClan == getClanId(islApes[i]),
                "Staking: all apes have to be from same clan"
            );

            IERC721(_APE_ONLY_ISLAND_COLLECTION_CA).transferFrom(
                account,
                address(this),
                islApes[i]
            );
            _stakingDetails[account].islApeIDs.push(islApes[i]);
            emit Staked(account, islApes[i]);
        }

        for (uint256 i = 0; i < genApesLength; i++) {
            require(
                IERC721(_GENESIS_APE_ONLY_CA).ownerOf(genApes[i]) == account,
                "Staking: account must be the owner of all genesis ape <ID> inputs"
            );

            IERC721(_GENESIS_APE_ONLY_CA).transferFrom(
                account,
                address(this),
                genApes[i]
            );
            _stakingDetails[account].genApeIDs.push(genApes[i]);
            emit Staked(account, genApes[i]);
        }

        _stakingDetails[account].islApes += islApesLength;
        _stakingDetails[account].genApes += genApesLength;

        _stakingDetails[account].multiplier = _multiplier * genApesLength;
        _stakingDetails[account].recent = block.timestamp;

        _totalStakedIslApes += islApesLength;
        _totalStakedGenApes += genApesLength;

        return true;
    }

    function stake(uint256 packs, uint256[] calldata islApes)
        external
        returns (bool)
    {
        address account = _msgSender();
        uint256 minimum = _pack * packs;

        require(
            _totalStakedRewards > 0,
            "Staking: no staking rewards available"
        );

        require(
            IERC721(_APE_ONLY_ISLAND_COLLECTION_CA).balanceOf(account) >=
                minimum,
            "Staking: minimum of island apes for pack size not found"
        );

        uint256 islApesLength = islApes.length;

        require(
            islApesLength == minimum,
            "Staking: input of island apes and minimum must match"
        );

        require(
            _stakingDetails[account].islApes == 0,
            "Staking: account must unstake to stake"
        );

        uint8 packsClan = getClanId(islApes[0]);

        for (uint256 i = 0; i < islApesLength; i++) {
            require(
                packsClan == getClanId(islApes[i]),
                "Staking: all apes have to be from same clan"
            );

            require(
                IERC721(_APE_ONLY_ISLAND_COLLECTION_CA).ownerOf(islApes[i]) ==
                    account,
                "Staking: account must be the owner of all island ape <ID> inputs"
            );

            IERC721(_APE_ONLY_ISLAND_COLLECTION_CA).safeTransferFrom(
                account,
                address(this),
                islApes[i]
            );
            _stakingDetails[account].islApeIDs.push(islApes[i]);
            emit Staked(account, islApes[i]);
        }

        _stakingDetails[account].islApes += islApesLength;
        _stakingDetails[account].recent = block.timestamp;
        _totalStakedIslApes += islApesLength;
        return true;
    }

    function unstake() external returns (bool) {
        address account = _msgSender();

        require(
            _stakingDetails[account].islApes > 0,
            "Staking: no staked island apes found"
        );

        uint256 islApes = _stakingDetails[account].islApes;
        uint256[] memory islApeIDs = _stakingDetails[account].islApeIDs;

        uint256 genApes = _stakingDetails[account].genApes;
        uint256[] memory genApeIDs = _stakingDetails[account].genApeIDs;

        if (getAccountRewardsAvailable(account) > 0) reward();

        delete _stakingDetails[account].islApes;
        delete _stakingDetails[account].genApes;
        delete _stakingDetails[account].islApeIDs;
        delete _stakingDetails[account].genApeIDs;
        delete _stakingDetails[account].multiplier;

        for (uint256 i = 0; i < islApes; i++) {
            ERC721(_APE_ONLY_ISLAND_COLLECTION_CA).safeTransferFrom(
                address(this),
                account,
                islApeIDs[i]
            );
            emit Unstaked(account, islApeIDs[i]);
        }

        for (uint256 i = 0; i < genApes; i++) {
            ERC721(_GENESIS_APE_ONLY_CA).safeTransferFrom(
                address(this),
                account,
                genApeIDs[i]
            );
            emit Unstaked(account, genApeIDs[i]);
        }

        _totalStakedIslApes -= islApes;
        _totalStakedGenApes -= genApes;
        return true;
    }

    function fund(uint256 amount) external returns (bool) {
        require(amount > 0, "Staking: must be a valid amount");

        address account = _msgSender();

        require(
            IERC20(_APE_ONLY_ISLAND_TOKEN_CA).balanceOf(account) >= amount,
            "Staking: no island tokens found"
        );

        require(
            IERC20(_APE_ONLY_ISLAND_TOKEN_CA).transferFrom(
                account,
                address(this),
                amount
            ),
            "Staking: transfer of staked rewards failed"
        );

        _totalStakedRewards += amount;

        emit Funded(account, amount);
        return true;
    }

    function emergencyUnstake() external returns (bool) {
        address account = _msgSender();

        require(
            _stakingDetails[account].islApes > 0,
            "Staking: no staked island apes found"
        );

        uint256 islApes = _stakingDetails[account].islApes;
        uint256[] memory islApeIDs = _stakingDetails[account].islApeIDs;

        uint256 genApes = _stakingDetails[account].genApes;
        uint256[] memory genApeIDs = _stakingDetails[account].genApeIDs;

        delete _stakingDetails[account].islApes;
        delete _stakingDetails[account].genApes;
        delete _stakingDetails[account].islApeIDs;
        delete _stakingDetails[account].genApeIDs;
        delete _stakingDetails[account].multiplier;

        for (uint256 i = 0; i < islApes; i++) {
            ERC721(_APE_ONLY_ISLAND_COLLECTION_CA).safeTransferFrom(
                address(this),
                account,
                islApeIDs[i]
            );
            emit Unstaked(account, islApeIDs[i]);
        }

        for (uint256 i = 0; i < genApes; i++) {
            ERC721(_GENESIS_APE_ONLY_CA).safeTransferFrom(
                address(this),
                account,
                genApeIDs[i]
            );
            emit Unstaked(account, genApeIDs[i]);
        }

        _totalStakedIslApes -= islApes;
        _totalStakedGenApes -= genApes;
        return true;
    }

    function emergencyWithdraw() external onlyOwner returns (bool) {
        address account = _msgSender();

        require(
            _totalStakedRewards > 0,
            "Staking: no staking rewards available"
        );

        require(
            Token(_APE_ONLY_ISLAND_TOKEN_CA).transfer(
                account,
                _totalStakedRewards
            ),
            "Staking: transfer of staked rewards failed"
        );

        delete _totalStakedRewards;

        return true;
    }

    function setRewardRate(uint256 amount) external onlyOwner returns (bool) {
        _rate = amount;
        return true;
    }

    function setRewardMultiplier(uint256 amount)
        external
        onlyOwner
        returns (bool)
    {
        _multiplier = amount;
        return true;
    }

    function setPackSize(uint256 amount) external onlyOwner returns (bool) {
        _rate = amount;
        return true;
    }

    function getRewardRate() external view returns (uint256) {
        return _rate;
    }

    function getGenesisMultiplier() external view returns (uint256) {
        return _multiplier;
    }

    function getPackSize() external view returns (uint256) {
        return _pack;
    }

    function getTotalStakedGenesisApes() external view returns (uint256) {
        return _totalStakedGenApes;
    }

    function getTotalStakedIslandApes() external view returns (uint256) {
        return _totalStakedIslApes;
    }

    function getTotalStakedRewards() external view returns (uint256) {
        return _totalStakedRewards;
    }

    function getAccountStakedIslandApes(address account)
        external
        view
        returns (uint256)
    {
        return _stakingDetails[account].islApes;
    }

    function getAccountStakedGenesisApes(address account)
        external
        view
        returns (uint256)
    {
        return _stakingDetails[account].genApes;
    }

    function getAccountStakedIslandApeIDs(address account)
        external
        view
        returns (uint256[] memory)
    {
        return _stakingDetails[account].islApeIDs;
    }

    function getAccountStakedGenesisApeIDs(address account)
        external
        view
        returns (uint256[] memory)
    {
        return _stakingDetails[account].genApeIDs;
    }

    function getAccountReward(address account) external view returns (uint256) {
        return _stakingDetails[account].rewarded;
    }

    function getAccountMultiplier(address account)
        external
        view
        returns (uint256)
    {
        return _stakingDetails[account].multiplier;
    }

    function getAccountRecentActivity(address account)
        external
        view
        returns (uint256)
    {
        return _stakingDetails[account].recent;
    }

    function reward() public returns (bool) {
        address account = _msgSender();

        require(_totalStakedRewards > 0, "Staking: no rewards available");

        uint256 rewards = getAccountRewardsAvailable(account);

        require(rewards > 0, "Staking: no rewards earned");

        _stakingDetails[account].rewarded += rewards;
        _stakingDetails[account].recent = block.timestamp;

        require(
            IERC20(_APE_ONLY_ISLAND_TOKEN_CA).transfer(account, rewards),
            "Staking: transfer of rewards failed"
        );

        _totalStakedRewards -= rewards;

        emit Rewarded(account, rewards);
        return true;
    }

    function getAccountRewardsAvailable(address account)
        public
        view
        returns (uint256)
    {
        if (_totalStakedRewards > 0) {
            uint256 start = _stakingDetails[account].recent;
            uint256 duration;

            if (block.timestamp - start >= 86400) {
                duration = (block.timestamp - start) / 86400;
                return getAccountRewardsEstimatedDaily(account) * duration;
            }
        }
        return 0;
    }

    function getAccountRewardsEstimatedDaily(address account)
        public
        view
        returns (uint256)
    {
        uint256 staked = _stakingDetails[account].islApes;
        uint256 multiplier = _stakingDetails[account].multiplier;
        uint256 reward = _rate * staked;

        return reward + ((reward * multiplier) / 100);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function getClanId(uint256 apeId) private view returns (uint8) {
        return Collection(_APE_ONLY_ISLAND_COLLECTION_CA).getTokenClanId(apeId);
    }
}