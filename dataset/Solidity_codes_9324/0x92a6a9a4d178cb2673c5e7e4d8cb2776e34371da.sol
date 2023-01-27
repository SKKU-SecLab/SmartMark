



pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

pragma solidity ^0.8.0;

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

interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}

pragma solidity ^0.8.0;

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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

pragma solidity ^0.8.0;

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

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

pragma solidity ^0.8.0;

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.0;

library Math {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

interface iMetalStaking {
    function _legendsForgeBlocks(uint256) external view returns (uint256);

    function _tigerForgeBlocks(uint256) external view returns (uint256);

    function _cubsForgeBlocks(uint256) external view returns (uint256);

    function _fundaeForgeBlocks(uint256) external view returns (uint256);

    function _azukiForgeBlocks(uint256) external view returns (uint256);

    function _legendsTokenForges(uint256) external view returns (address);

    function _tigerTokenForges(uint256) external view returns (address);

    function _cubsTokenForges(uint256) external view returns (address);

    function _fundaeTokenForges(uint256) external view returns (address);

    function _azukiTokenForges(uint256) external view returns (address);

    function _membershipForgeBlocks(address) external view returns (uint256);

    function membershipForgesOf(address account)
        external
        view
        returns (uint256[] memory);
}

pragma solidity ^0.8.0;

contract LiquidForgeRewards is Ownable, Pausable {
    uint256 public TIGER_DISTRIBUTION_AMOUNT;
    uint256 public FUNDAE_DISTRIBUTION_AMOUNT;
    uint256 public LEGENDS_DISTRIBUTION_AMOUNT;
    uint256 public AZUKI_DISTRIBUTION_AMOUNT;

    mapping(uint256 => bool) public tigerClaimed;
    mapping(uint256 => bool) public fundaeClaimed;
    mapping(uint256 => bool) public legendsClaimed;
    mapping(uint256 => bool) public azukiClaimed;

    mapping(uint256 => uint256) public _newLegendsForgeBlocks;
    mapping(uint256 => uint256) public _newTigerForgeBlocks;
    mapping(uint256 => uint256) public _newCubsForgeBlocks;
    mapping(uint256 => uint256) public _newFundaeForgeBlocks;
    mapping(uint256 => uint256) public _newAzukiForgeBlocks;

    address public legendsAddress;
    address public tigerAddress;
    address public cubsAddress;
    address public fundaeAddress;
    address public azukiAddress;
    address public forgeAddress;

    address public erc20Address;

    uint256 public expiration;
    uint256 public minBlockToClaim;
    uint256 public legendsRate;
    uint256 public tigerRate;
    uint256 public cubsRate;
    uint256 public fundaeRate;
    uint256 public azukiRate;

    uint256 public _totalSupply;

    mapping(address => uint256) private _balances;

    constructor(
        address _legendsAddress,
        address _tigerAddress,
        address _cubsAddress,
        address _fundaeAddress,
        address _azukiAddress,
        address _erc20Address
    ) {
        legendsAddress = _legendsAddress;
        legendsRate = 0;
        tigerAddress = _tigerAddress;
        tigerRate = 0;
        cubsAddress = _cubsAddress;
        cubsRate = 0;
        fundaeAddress = _fundaeAddress;
        fundaeRate = 0;
        azukiAddress = _azukiAddress;
        azukiRate = 0;
        expiration = block.number + 0;
        erc20Address = _erc20Address;
        forgeAddress = 0x78406Ee8e2Ed3D14654150D2aC5dBB67710B3492;
        TIGER_DISTRIBUTION_AMOUNT = 5000000000000000000;
        FUNDAE_DISTRIBUTION_AMOUNT = 5000000000000000000;
        AZUKI_DISTRIBUTION_AMOUNT = 5000000000000000000;
        LEGENDS_DISTRIBUTION_AMOUNT = 25000000000000000000;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function stakeOnBehalfBulk(
        uint256[] calldata _amounts,
        address[] calldata _accounts,
        uint256 totalAmount
    ) external onlyOwner {
        for (uint256 i = 0; i < _amounts.length; i++) {
            address account;
            account = _accounts[i];
            _totalSupply += _amounts[i];
            _balances[_accounts[i]] += _amounts[i];
        }
        IERC20(erc20Address).transferFrom(
            msg.sender,
            address(this),
            totalAmount
        );
    }

    function addressClaim() external {
        require(0 < _balances[msg.sender], "withdraw amount over stake");
        require(
            iMetalStaking(forgeAddress).membershipForgesOf(msg.sender).length >
                0,
            "No Membership Forged"
        );
        uint256 reward = _balances[msg.sender];
        _totalSupply -= _balances[msg.sender];
        _balances[msg.sender] -= _balances[msg.sender];
        IERC20(erc20Address).transfer(msg.sender, reward);
        
    }

    function claimBalanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function revokeBonusReward(uint256[] calldata tokenIds, address nftaddress)
        public
        onlyOwner
    {
        if (nftaddress == legendsAddress) {
            for (uint256 i; i < tokenIds.length; ++i) {
                uint256 tokenId = tokenIds[i];
                if (!legendsClaimed[tokenId]) {
                    legendsClaimed[tokenId] = true;
                }
            }
        }
        if (nftaddress == tigerAddress) {
            for (uint256 i; i < tokenIds.length; ++i) {
                uint256 tokenId = tokenIds[i];
                if (!tigerClaimed[tokenId]) {
                    tigerClaimed[tokenId] = true;
                }
            }
        }
        if (nftaddress == fundaeAddress) {
            for (uint256 i; i < tokenIds.length; ++i) {
                uint256 tokenId = tokenIds[i];
                if (!fundaeClaimed[tokenId]) {
                    fundaeClaimed[tokenId] = true;
                }
            }
        }
        if (nftaddress == azukiAddress) {
            for (uint256 i; i < tokenIds.length; ++i) {
                uint256 tokenId = tokenIds[i];
                if (!azukiClaimed[tokenId]) {
                    azukiClaimed[tokenId] = true;
                }
            }
        }
    }

    

    function setRates(
        uint256 _legendsRate,
        uint256 _cubsRate,
        uint256 _tigerRate,
        uint256 _fundaeRate,
        uint256 _azukiRate,
        uint256 _minBlockToClaim,
        uint256 _expiration
    ) public onlyOwner {
        legendsRate = _legendsRate;
        cubsRate = _cubsRate;
        tigerRate = _tigerRate;
        fundaeRate = _fundaeRate;
        azukiRate = _azukiRate;
        minBlockToClaim = _minBlockToClaim;
        expiration = block.number + _expiration;
    }

    function rewardClaimable(uint256 tokenId, address nftaddress)
        public
        view
        returns (bool)
    {
        uint256 blockCur = Math.min(block.number, expiration);
        if (
            nftaddress == legendsAddress &&
            iMetalStaking(forgeAddress)._legendsForgeBlocks(tokenId) > 0
        ) {
            return (blockCur -
                Math.max(
                    iMetalStaking(forgeAddress)._legendsForgeBlocks(tokenId),
                    _newLegendsForgeBlocks[tokenId]
                ) >
                minBlockToClaim);
        }
        if (
            nftaddress == tigerAddress &&
            iMetalStaking(forgeAddress)._tigerForgeBlocks(tokenId) > 0
        ) {
            return (blockCur -
                Math.max(
                    iMetalStaking(forgeAddress)._tigerForgeBlocks(tokenId),
                    _newTigerForgeBlocks[tokenId]
                ) >
                minBlockToClaim);
        }
        if (
            nftaddress == cubsAddress &&
            iMetalStaking(forgeAddress)._cubsForgeBlocks(tokenId) > 0
        ) {
            return (blockCur -
                Math.max(
                    iMetalStaking(forgeAddress)._cubsForgeBlocks(tokenId),
                    _newCubsForgeBlocks[tokenId]
                ) >
                minBlockToClaim);
        }
        if (
            nftaddress == fundaeAddress &&
            iMetalStaking(forgeAddress)._fundaeForgeBlocks(tokenId) > 0
        ) {
            return (blockCur -
                Math.max(
                    iMetalStaking(forgeAddress)._fundaeForgeBlocks(tokenId),
                    _newFundaeForgeBlocks[tokenId]
                ) >
                minBlockToClaim);
        }
        if (
            nftaddress == azukiAddress &&
            iMetalStaking(forgeAddress)._azukiForgeBlocks(tokenId) > 0
        ) {
            return (blockCur -
                Math.max(
                    iMetalStaking(forgeAddress)._azukiForgeBlocks(tokenId),
                    _newAzukiForgeBlocks[tokenId]
                ) >
                minBlockToClaim);
        }
        return false;
    }

    function oldLegendsForgeBlocks(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        return iMetalStaking(forgeAddress)._legendsForgeBlocks(tokenId);
    }

    function oldLegendsTokenForges(uint256 tokenId)
        public
        view
        returns (address)
    {
        return iMetalStaking(forgeAddress)._legendsTokenForges(tokenId);
    }

    function calculateReward(
        address account,
        uint256 tokenId,
        address nftaddress
    ) public view returns (uint256) {
        if (nftaddress == legendsAddress) {
            uint256 tmp = Math.max(
                iMetalStaking(forgeAddress)._legendsForgeBlocks(tokenId),
                iMetalStaking(forgeAddress)._membershipForgeBlocks(account)
            );
            require(
                Math.min(block.number, expiration) >
                    iMetalStaking(forgeAddress)._legendsForgeBlocks(tokenId),
                "Invalid blocks"
            );
            return
                legendsRate *
                (
                    iMetalStaking(forgeAddress)._legendsTokenForges(tokenId) ==
                        account
                        ? 1
                        : 0
                ) *
                (Math.min(block.number, expiration) -
                    Math.max(tmp, _newLegendsForgeBlocks[tokenId]));
        }
        if (nftaddress == tigerAddress) {
            uint256 tmp = Math.max(
                iMetalStaking(forgeAddress)._tigerForgeBlocks(tokenId),
                iMetalStaking(forgeAddress)._membershipForgeBlocks(account)
            );
            require(
                Math.min(block.number, expiration) >
                    iMetalStaking(forgeAddress)._tigerForgeBlocks(tokenId),
                "Invalid blocks"
            );
            return
                tigerRate *
                (
                    iMetalStaking(forgeAddress)._tigerTokenForges(tokenId) ==
                        account
                        ? 1
                        : 0
                ) *
                (Math.min(block.number, expiration) -
                    Math.max(tmp, _newTigerForgeBlocks[tokenId]));
        }
        if (nftaddress == cubsAddress) {
            uint256 tmp = Math.max(
                iMetalStaking(forgeAddress)._cubsForgeBlocks(tokenId),
                iMetalStaking(forgeAddress)._membershipForgeBlocks(account)
            );
            require(
                Math.min(block.number, expiration) >
                    iMetalStaking(forgeAddress)._cubsForgeBlocks(tokenId),
                "Invalid blocks"
            );
            return
                cubsRate *
                (
                    iMetalStaking(forgeAddress)._cubsTokenForges(tokenId) ==
                        account
                        ? 1
                        : 0
                ) *
                (Math.min(block.number, expiration) -
                    Math.max(tmp, _newCubsForgeBlocks[tokenId]));
        }
        if (nftaddress == azukiAddress) {
            uint256 tmp = Math.max(
                iMetalStaking(forgeAddress)._azukiForgeBlocks(tokenId),
                iMetalStaking(forgeAddress)._membershipForgeBlocks(account)
            );
            require(
                Math.min(block.number, expiration) >
                    iMetalStaking(forgeAddress)._azukiForgeBlocks(tokenId),
                "Invalid blocks"
            );
            return
                azukiRate *
                (
                    iMetalStaking(forgeAddress)._azukiTokenForges(tokenId) ==
                        account
                        ? 1
                        : 0
                ) *
                (Math.min(block.number, expiration) -
                    Math.max(tmp, _newAzukiForgeBlocks[tokenId]));
        }
        if (nftaddress == fundaeAddress) {
            uint256 tmp = Math.max(
                iMetalStaking(forgeAddress)._fundaeForgeBlocks(tokenId),
                iMetalStaking(forgeAddress)._membershipForgeBlocks(account)
            );
            require(
                Math.min(block.number, expiration) >
                    iMetalStaking(forgeAddress)._azukiForgeBlocks(tokenId),
                "Invalid blocks"
            );
            return
                fundaeRate *
                (
                    iMetalStaking(forgeAddress)._fundaeTokenForges(tokenId) ==
                        account
                        ? 1
                        : 0
                ) *
                (Math.min(block.number, expiration) -
                    Math.max(tmp, _newAzukiForgeBlocks[tokenId]));
        }
        return 0;
    }

    function ClaimRewards(uint256[] calldata tokenIds, address nftaddress)
        public
        whenNotPaused
    {
        uint256 reward;
        uint256 blockCur = Math.min(block.number, expiration);

        require(
            iMetalStaking(forgeAddress).membershipForgesOf(msg.sender).length >
                0,
            "No Membership Forged"
        );

        if (nftaddress == legendsAddress) {
            for (uint256 i; i < tokenIds.length; i++) {
                require(
                    IERC721(legendsAddress).ownerOf(tokenIds[i]) == msg.sender
                );
                require(
                    blockCur -
                        Math.max(
                            iMetalStaking(forgeAddress)._legendsForgeBlocks(
                                tokenIds[i]
                            ),
                            _newLegendsForgeBlocks[tokenIds[i]]
                        ) >
                        minBlockToClaim
                );
            }

            for (uint256 i; i < tokenIds.length; i++) {
                reward += calculateReward(
                    msg.sender,
                    tokenIds[i],
                    legendsAddress
                );
                _newLegendsForgeBlocks[tokenIds[i]] = blockCur;
            }

            for (uint256 i; i < tokenIds.length; ++i) {
                uint256 tokenId = tokenIds[i];
                if (!legendsClaimed[tokenId]) {
                    legendsClaimed[tokenId] = true;
                    reward += LEGENDS_DISTRIBUTION_AMOUNT;
                }
            }
        }

        if (nftaddress == tigerAddress) {
            for (uint256 i; i < tokenIds.length; i++) {
                require(
                    IERC721(tigerAddress).ownerOf(tokenIds[i]) == msg.sender
                );
                require(
                    blockCur -
                        Math.max(
                            iMetalStaking(forgeAddress)._tigerForgeBlocks(
                                tokenIds[i]
                            ),
                            _newTigerForgeBlocks[tokenIds[i]]
                        ) >
                        minBlockToClaim
                );
            }

            for (uint256 i; i < tokenIds.length; i++) {
                reward += calculateReward(
                    msg.sender,
                    tokenIds[i],
                    tigerAddress
                );
                _newTigerForgeBlocks[tokenIds[i]] = blockCur;
            }

            for (uint256 i; i < tokenIds.length; ++i) {
                uint256 tokenId = tokenIds[i];
                if (!tigerClaimed[tokenId]) {
                    tigerClaimed[tokenId] = true;
                    reward += TIGER_DISTRIBUTION_AMOUNT;
                }
            }
        }

        if (nftaddress == cubsAddress) {
            for (uint256 i; i < tokenIds.length; i++) {
                require(
                    IERC721(cubsAddress).ownerOf(tokenIds[i]) == msg.sender
                );
                require(
                    blockCur -
                        Math.max(
                            iMetalStaking(forgeAddress)._cubsForgeBlocks(
                                tokenIds[i]
                            ),
                            _newCubsForgeBlocks[tokenIds[i]]
                        ) >
                        minBlockToClaim
                );
            }

            for (uint256 i; i < tokenIds.length; i++) {
                reward += calculateReward(msg.sender, tokenIds[i], cubsAddress);
                _newCubsForgeBlocks[tokenIds[i]] = blockCur;
            }
        }

        if (nftaddress == fundaeAddress) {
            for (uint256 i; i < tokenIds.length; i++) {
                require(
                    IERC721(fundaeAddress).ownerOf(tokenIds[i]) == msg.sender
                );
                require(
                    blockCur -
                        Math.max(
                            iMetalStaking(forgeAddress)._fundaeForgeBlocks(
                                tokenIds[i]
                            ),
                            _newFundaeForgeBlocks[tokenIds[i]]
                        ) >
                        minBlockToClaim
                );
            }

            for (uint256 i; i < tokenIds.length; i++) {
                reward += calculateReward(
                    msg.sender,
                    tokenIds[i],
                    fundaeAddress
                );
                _newFundaeForgeBlocks[tokenIds[i]] = blockCur;
            }

            for (uint256 i; i < tokenIds.length; ++i) {
                uint256 tokenId = tokenIds[i];
                if (!fundaeClaimed[tokenId]) {
                    fundaeClaimed[tokenId] = true;
                    reward += FUNDAE_DISTRIBUTION_AMOUNT;
                }
            }
        }

        if (nftaddress == azukiAddress) {
            for (uint256 i; i < tokenIds.length; i++) {
                require(
                    IERC721(azukiAddress).ownerOf(tokenIds[i]) == msg.sender
                );
                require(
                    blockCur -
                        Math.max(
                            iMetalStaking(forgeAddress)._azukiForgeBlocks(
                                tokenIds[i]
                            ),
                            _newAzukiForgeBlocks[tokenIds[i]]
                        ) >
                        minBlockToClaim
                );
            }
            for (uint256 i; i < tokenIds.length; i++) {
                reward += calculateReward(
                    msg.sender,
                    tokenIds[i],
                    azukiAddress
                );
                _newAzukiForgeBlocks[tokenIds[i]] = blockCur;
            }

            for (uint256 i; i < tokenIds.length; ++i) {
                uint256 tokenId = tokenIds[i];
                if (!azukiClaimed[tokenId]) {
                    azukiClaimed[tokenId] = true;
                    reward += AZUKI_DISTRIBUTION_AMOUNT;
                }
            }
        }

        if (reward > 0) {
            IERC20(erc20Address).transfer(msg.sender, reward);
        }
    }

    function withdrawTokens() external onlyOwner {
        uint256 tokenSupply = IERC20(erc20Address).balanceOf(address(this));
        IERC20(erc20Address).transfer(msg.sender, tokenSupply);
    }
}