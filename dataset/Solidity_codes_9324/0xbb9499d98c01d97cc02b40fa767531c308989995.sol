
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

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


interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}// MIT

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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
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
}// MIT

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

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
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
}//MIT
pragma solidity ^0.8.0;


contract BCRAvatar is Ownable, ERC20 {
	struct AvatarNFT {
		address nft;
		uint256 tokenId;
		bool isERC721;
	}

	event AvatarCreated(address indexed account, string avatarURI);
	event AvatarUpdated(address indexed account, string avatarURI);
	event ProfileCreated(address indexed account, string profileURI);
	event ProfileUpdated(address indexed account, string profileURI);
	event NFTRegistered(address indexed account);
	event NFTDeRegistered(address indexed account);
	event ContractAvatarCreated(address indexed account, string avatarURI);
	event ContractAvatarUpdated(address indexed account, string avatarURI);
	event ContractProfileCreated(address indexed account, string profileURI);
	event ContractProfileUpdated(address indexed account, string profileURI);
	event ServiceDonated(address indexed account, uint256 amount);

	string public baseURI = "https://ipfs.io/ipfs/";
	mapping(address => uint256) private donations;
	mapping(address => string) private avatars;
	mapping(address => string) private profiles;
	mapping(address => AvatarNFT) public avatarNFTs;
	mapping(address => bool) public contracts;

	constructor() ERC20("Blockchain Registered Avatar", "BCRA") {}

	function getAvatar(address account) public view returns (string memory) {
		if (avatarNFTs[account].nft != address(0)) {
			address nft = avatarNFTs[account].nft;
			uint256 tokenId = avatarNFTs[account].tokenId;
			if (avatarNFTs[account].isERC721) {
				if (IERC721(nft).ownerOf(tokenId) == account) {
					return IERC721Metadata(nft).tokenURI(tokenId);
				}
			} else {
				if (IERC1155(nft).balanceOf(account, tokenId) > 0) {
					return IERC1155MetadataURI(nft).uri(tokenId);
				}
			}
		}
		if (bytes(avatars[account]).length > 0) {
			return string(abi.encodePacked(baseURI, avatars[account]));
		} else {
			return "";
		}
	}

	function setAvatar(string memory avatarHash) public {
		bool notCreated = bytes(avatars[msg.sender]).length == 0;
		avatars[msg.sender] = avatarHash;
		if (notCreated) {
			emit AvatarCreated(msg.sender, getAvatar(msg.sender));
		} else {
			emit AvatarUpdated(msg.sender, getAvatar(msg.sender));
		}
	}

	function getProfile(address account) public view returns (string memory) {
		if (bytes(profiles[account]).length > 0) {
			return string(abi.encodePacked(baseURI, profiles[account]));
		} else {
			return "";
		}
	}

	function setProfile(string memory profileHash) public {
		bool notCreated = bytes(profiles[msg.sender]).length == 0;
		profiles[msg.sender] = profileHash;
		if (notCreated) {
			emit ProfileCreated(msg.sender, getProfile(msg.sender));
		} else {
			emit ProfileUpdated(msg.sender, getProfile(msg.sender));
		}
	}

	function registerNFT(
		address nft,
		uint256 tokenId,
		bool isERC721
	) public {
		if (isERC721) {
			require(IERC721(nft).ownerOf(tokenId) == msg.sender, "Owner invalid");
		} else {
			require(IERC1155(nft).balanceOf(msg.sender, tokenId) > 0, "Balance insufficient");
		}
		avatarNFTs[msg.sender] = AvatarNFT(nft, tokenId, isERC721);
		emit NFTRegistered(msg.sender);
	}

	function deRegisterNFT() public {
		require(avatarNFTs[msg.sender].nft != address(0), "NFT not registered");
		delete avatarNFTs[msg.sender];
		emit NFTDeRegistered(msg.sender);
	}

	function setContractAvatar(address account, string memory avatarHash) public onlyOwner {
		require(Address.isContract(account), "Contract invalid");
		bool notCreated = bytes(avatars[account]).length == 0;
		avatars[account] = avatarHash;
		if (notCreated) {
			contracts[account] = true;
			emit ContractAvatarCreated(account, getAvatar(account));
		} else {
			emit ContractAvatarUpdated(account, getAvatar(account));
		}
	}

	function setOwnableContractAvatar(address account, string memory avatarHash) public {
		require(Ownable(account).owner() == msg.sender, "Owner invalid");
		bool notCreated = bytes(avatars[account]).length == 0;
		avatars[account] = avatarHash;
		if (notCreated) {
			contracts[account] = true;
			emit ContractAvatarCreated(account, getAvatar(account));
		} else {
			emit ContractAvatarUpdated(account, getAvatar(account));
		}
	}

	function setContractProfile(address account, string memory profileHash) public onlyOwner {
		require(Address.isContract(account), "Contract invalid");
		bool notCreated = bytes(profiles[account]).length == 0;
		profiles[account] = profileHash;
		if (notCreated) {
			contracts[account] = true;
			emit ContractProfileCreated(account, getProfile(account));
		} else {
			emit ContractProfileUpdated(account, getProfile(account));
		}
	}

	function setOwnableContractProfile(address account, string memory profileHash) public {
		require(Ownable(account).owner() == msg.sender, "Owner invalid");
		bool notCreated = bytes(profiles[account]).length == 0;
		profiles[account] = profileHash;
		if (notCreated) {
			contracts[account] = true;
			emit ContractProfileCreated(account, getProfile(account));
		} else {
			emit ContractProfileUpdated(account, getProfile(account));
		}
	}

	function donate() public payable {
		require(msg.value > 0, "Donation insufficient");
		super._mint(msg.sender, msg.value);
		donations[msg.sender] += msg.value;
		emit ServiceDonated(msg.sender, msg.value);
	}

	function withdraw() public onlyOwner {
		require(address(this).balance > 0, "Amount insufficient");
		payable(owner()).transfer(address(this).balance);
	}
}