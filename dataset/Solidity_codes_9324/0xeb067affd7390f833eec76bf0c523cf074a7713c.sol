
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    function supportsERC165(address account) internal view returns (bool) {

        return
            _supportsERC165Interface(account, type(IERC165).interfaceId) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) && _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
        internal
        view
        returns (bool[] memory)
    {

        bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

        if (supportsERC165(account)) {
            for (uint256 i = 0; i < interfaceIds.length; i++) {
                interfaceIdsSupported[i] = _supportsERC165Interface(account, interfaceIds[i]);
            }
        }

        return interfaceIdsSupported;
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {

        if (!supportsERC165(account)) {
            return false;
        }

        for (uint256 i = 0; i < interfaceIds.length; i++) {
            if (!_supportsERC165Interface(account, interfaceIds[i])) {
                return false;
            }
        }

        return true;
    }

    function _supportsERC165Interface(address account, bytes4 interfaceId) private view returns (bool) {

        bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
        (bool success, bytes memory result) = account.staticcall{gas: 30000}(encodedParams);
        if (result.length < 32) return false;
        return success && abi.decode(result, (bool));
    }
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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
        return verifyCallResult(success, returndata, errorMessage);
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
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library SuperRareContracts {

    address public constant SUPERRARE_REGISTRY = 0x17B0C8564E53f22364A6C8de6F7ca5CE9BEa4e5D;
    address public constant SUPERRARE_V1 = 0x41A322b28D0fF354040e2CbC676F0320d8c8850d;
    address public constant SUPERRARE_V2 = 0xb932a70A57673d89f4acfFBE830E8ed7f75Fb9e0;

}// MIT

pragma solidity ^0.8.0;


interface IManifold {


    function getRoyalties(uint256 tokenId) external view returns (address payable[] memory, uint256[] memory);

}// MIT

pragma solidity ^0.8.0;

interface IRaribleV1 {

    function getFeeBps(uint256 id) external view returns (uint[] memory);

    function getFeeRecipients(uint256 id) external view returns (address payable[] memory);

}


interface IRaribleV2 {

    struct Part {
        address payable account;
        uint96 value;
    }
    function getRaribleV2Royalties(uint256 id) external view returns (Part[] memory);

}// MIT

pragma solidity ^0.8.0;

interface IFoundation {

    function getFees(uint256 tokenId) external view returns (address payable[] memory, uint256[] memory);

}

interface IFoundationTreasuryNode {

    function getFoundationTreasury() external view returns (address payable);

}

interface IFoundationTreasury {

    function isAdmin(address account) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface ISuperRareRegistry {

    function getERC721TokenRoyaltyPercentage(
        address _contractAddress,
        uint256 _tokenId
    ) external view returns (uint8);


    function calculateRoyaltyFee(
        address _contractAddress,
        uint256 _tokenId,
        uint256 _amount
    ) external view returns (uint256);


    function tokenCreator(address _contractAddress, uint256 _tokenId)
        external
        view
        returns (address payable);

}// MIT

pragma solidity ^0.8.0;

interface IEIP2981 {

    function royaltyInfo(uint256 tokenId, uint256 value) external view returns (address, uint256);

}// MIT

pragma solidity ^0.8.0;

interface IZoraMarket {

    struct ZoraDecimal {
        uint256 value;
    }

    struct ZoraBidShares {
        ZoraDecimal prevOwner;
        ZoraDecimal creator;
        ZoraDecimal owner;
    }

    function bidSharesForToken(uint256 tokenId) external view returns (ZoraBidShares memory);

}

interface IZoraMedia {


    function marketContract() external view returns(address);

    function previousTokenOwners(uint256 tokenId) external view returns(address);

    function tokenCreators(uint256 tokenId) external view returns(address);


    function ownerOf(uint256 tokenId) external view returns (address owner);

}

interface IZoraOverride {


    function convertBidShares(address media, uint256 tokenId) external view returns (address payable[] memory, uint256[] memory);


}// MIT

pragma solidity ^0.8.0;

interface IArtBlocksOverride {

    function getRoyalties(address tokenAddress, uint256 tokenId)
        external
        view
        returns (address payable[] memory, uint256[] memory);

}// MIT


pragma solidity ^0.8.0;

interface IKODAV2 {

    function editionOfTokenId(uint256 _tokenId) external view returns (uint256 _editionNumber);


    function artistCommission(uint256 _editionNumber) external view returns (address _artistAccount, uint256 _artistCommission);


    function editionOptionalCommission(uint256 _editionNumber) external view returns (uint256 _rate, address _recipient);

}

interface IKODAV2Override {


    event CreatorRoyaltiesFeeUpdated(uint256 _oldCreatorRoyaltiesFee, uint256 _newCreatorRoyaltiesFee);

    function getKODAV2RoyaltyInfo(address _tokenAddress, uint256 _id, uint256 _amount)
    external
    view
    returns (address payable[] memory, uint256[] memory);


    function updateCreatorRoyalties(uint256 _creatorRoyaltiesFee) external;

}// MIT

pragma solidity ^0.8.0;



interface IRoyaltyEngineV1 is IERC165 {


    function getRoyalty(address tokenAddress, uint256 tokenId, uint256 value) external returns(address payable[] memory recipients, uint256[] memory amounts);


    function getRoyaltyView(address tokenAddress, uint256 tokenId, uint256 value) external view returns(address payable[] memory recipients, uint256[] memory amounts);

}// MIT

pragma solidity ^0.8.0;



interface IRoyaltyRegistry is IERC165 {


     event RoyaltyOverride(address owner, address tokenAddress, address royaltyAddress);

    function setRoyaltyLookupAddress(address tokenAddress, address royaltyAddress) external;


    function getRoyaltyLookupAddress(address tokenAddress) external view returns(address);


    function overrideAllowed(address tokenAddress) external view returns(bool);

}// MIT

pragma solidity ^0.8.0;





contract RoyaltyEngineV1 is ERC165, OwnableUpgradeable, IRoyaltyEngineV1 {

    using AddressUpgradeable for address;

    int16 constant private NONE = -1;
    int16 constant private NOT_CONFIGURED = 0;
    int16 constant private MANIFOLD = 1;
    int16 constant private RARIBLEV1 = 2;
    int16 constant private RARIBLEV2 = 3;
    int16 constant private FOUNDATION = 4;
    int16 constant private EIP2981 = 5;
    int16 constant private SUPERRARE = 6;
    int16 constant private ZORA = 7;
    int16 constant private ARTBLOCKS = 8;
    int16 constant private KNOWNORIGINV2 = 9;

    mapping (address => int16) _specCache;

    address public royaltyRegistry;

    function initialize(address royaltyRegistry_) public initializer {

        __Ownable_init_unchained();
        require(ERC165Checker.supportsInterface(royaltyRegistry_, type(IRoyaltyRegistry).interfaceId));
        royaltyRegistry = royaltyRegistry_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return interfaceId == type(IRoyaltyEngineV1).interfaceId || super.supportsInterface(interfaceId);
    }

    function invalidateCachedRoyaltySpec(address tokenAddress) public {

        address royaltyAddress = IRoyaltyRegistry(royaltyRegistry).getRoyaltyLookupAddress(tokenAddress);
        delete _specCache[royaltyAddress];
    }

    function getCachedRoyaltySpec(address tokenAddress) public view returns(int16) {

        address royaltyAddress = IRoyaltyRegistry(royaltyRegistry).getRoyaltyLookupAddress(tokenAddress);
        return _specCache[royaltyAddress];
    }

    function getRoyalty(address tokenAddress, uint256 tokenId, uint256 value) public override returns(address payable[] memory recipients, uint256[] memory amounts) {

        try this._getRoyaltyAndSpec{gas: 100000}(tokenAddress, tokenId, value) returns (address payable[] memory _recipients, uint256[] memory _amounts, int16 spec, address royaltyAddress, bool addToCache) {
            if (addToCache) _specCache[royaltyAddress] = spec;
            return (_recipients, _amounts);
        } catch {
            revert ("Invalid royalty amount");
        }
    }

    function getRoyaltyView(address tokenAddress, uint256 tokenId, uint256 value) public view override returns(address payable[] memory recipients, uint256[] memory amounts) {
        try this._getRoyaltyAndSpec{gas: 100000}(tokenAddress, tokenId, value) returns (address payable[] memory _recipients, uint256[] memory _amounts, int16, address, bool) {
            return (_recipients, _amounts);
        } catch {
            revert ("Invalid royalty amount");
        }
    }

    function _getRoyaltyAndSpec(address tokenAddress, uint256 tokenId, uint256 value) external view returns(address payable[] memory recipients, uint256[] memory amounts, int16 spec, address royaltyAddress, bool addToCache) {
        require(msg.sender == address(this), "Only Engine");

        royaltyAddress = IRoyaltyRegistry(royaltyRegistry).getRoyaltyLookupAddress(tokenAddress);
        spec = _specCache[royaltyAddress];

        if (spec <= NOT_CONFIGURED && spec > NONE) {
            addToCache = true;

            if (tokenAddress == SuperRareContracts.SUPERRARE_V1 || tokenAddress == SuperRareContracts.SUPERRARE_V2) {
                try ISuperRareRegistry(SuperRareContracts.SUPERRARE_REGISTRY).tokenCreator(tokenAddress, tokenId) returns(address payable creator) {
                    try ISuperRareRegistry(SuperRareContracts.SUPERRARE_REGISTRY).calculateRoyaltyFee(tokenAddress, tokenId, value) returns(uint256 amount) {
                        recipients = new address payable[](1);
                        amounts = new uint256[](1);
                        recipients[0] = creator;
                        amounts[0] = amount;
                        return (recipients, amounts, SUPERRARE, royaltyAddress, addToCache);
                    } catch {}
                } catch {}
            }
            try IEIP2981(royaltyAddress).royaltyInfo(tokenId, value) returns(address recipient, uint256 amount) {
                require(amount < value, "Invalid royalty amount");
                recipients = new address payable[](1);
                amounts = new uint256[](1);
                recipients[0] = payable(recipient);
                amounts[0] = amount;
                return (recipients, amounts, EIP2981, royaltyAddress, addToCache);
            } catch {}
            try IManifold(royaltyAddress).getRoyalties(tokenId) returns(address payable[] memory recipients_, uint256[] memory bps) {
                require(recipients_.length == bps.length);
                return (recipients_, _computeAmounts(value, bps), MANIFOLD, royaltyAddress, addToCache);
            } catch {}
            try IRaribleV2(royaltyAddress).getRaribleV2Royalties(tokenId) returns(IRaribleV2.Part[] memory royalties) {
                recipients = new address payable[](royalties.length);
                amounts = new uint256[](royalties.length);
                uint256 totalAmount;
                for (uint i = 0; i < royalties.length; i++) {
                    recipients[i] = royalties[i].account;
                    amounts[i] = value*royalties[i].value/10000;
                    totalAmount += amounts[i];
                }
                require(totalAmount < value, "Invalid royalty amount");
                return (recipients, amounts, RARIBLEV2, royaltyAddress, addToCache);
            } catch {}
            try IRaribleV1(royaltyAddress).getFeeRecipients(tokenId) returns(address payable[] memory recipients_) {
                recipients_ = IRaribleV1(royaltyAddress).getFeeRecipients(tokenId);
                try IRaribleV1(royaltyAddress).getFeeBps(tokenId) returns (uint256[] memory bps) {
                    require(recipients_.length == bps.length);
                    return (recipients_, _computeAmounts(value, bps), RARIBLEV1, royaltyAddress, addToCache);
                } catch {}
            } catch {}
            try IFoundation(royaltyAddress).getFees(tokenId) returns(address payable[] memory recipients_, uint256[] memory bps) {
                require(recipients_.length == bps.length);
                return (recipients_, _computeAmounts(value, bps), FOUNDATION, royaltyAddress, addToCache);
            } catch {}
            try IZoraOverride(royaltyAddress).convertBidShares(tokenAddress, tokenId) returns(address payable[] memory recipients_, uint256[] memory bps) {
                require(recipients_.length == bps.length);
                return (recipients_, _computeAmounts(value, bps), ZORA, royaltyAddress, addToCache);
            } catch {}
            try IArtBlocksOverride(royaltyAddress).getRoyalties(tokenAddress, tokenId) returns(address payable[] memory recipients_, uint256[] memory bps) {
                require(recipients_.length == bps.length);
                return (recipients_, _computeAmounts(value, bps), ARTBLOCKS, royaltyAddress, addToCache);
            } catch {}
            try IKODAV2Override(royaltyAddress).getKODAV2RoyaltyInfo(tokenAddress, tokenId, value) returns(address payable[] memory _recipients, uint256[] memory _amounts) {
                require(_recipients.length == _amounts.length);
                return (_recipients, _amounts, KNOWNORIGINV2, royaltyAddress, addToCache);
            } catch {}

            return (recipients, amounts, NONE, royaltyAddress, addToCache);
        } else {
            addToCache = false;
            if (spec == NONE) {
                return (recipients, amounts, spec, royaltyAddress, addToCache);
            } else if (spec == MANIFOLD) {
                uint256[] memory bps;
                (recipients, bps) = IManifold(royaltyAddress).getRoyalties(tokenId);
                require(recipients.length == bps.length);
                return (recipients, _computeAmounts(value, bps), spec, royaltyAddress, addToCache);
            } else if (spec == RARIBLEV2) {
                IRaribleV2.Part[] memory royalties;
                royalties = IRaribleV2(royaltyAddress).getRaribleV2Royalties(tokenId);
                recipients = new address payable[](royalties.length);
                amounts = new uint256[](royalties.length);
                uint256 totalAmount;
                for (uint i = 0; i < royalties.length; i++) {
                    recipients[i] = royalties[i].account;
                    amounts[i] = value*royalties[i].value/10000;
                    totalAmount += amounts[i];
                }
                require(totalAmount < value, "Invalid royalty amount");
                return (recipients, amounts, spec, royaltyAddress, addToCache);
            } else if (spec == RARIBLEV1) {
                uint256[] memory bps;
                recipients = IRaribleV1(royaltyAddress).getFeeRecipients(tokenId);
                bps = IRaribleV1(royaltyAddress).getFeeBps(tokenId);
                require(recipients.length == bps.length);
                return (recipients, _computeAmounts(value, bps), spec, royaltyAddress, addToCache);
            } else if (spec == FOUNDATION) {
                uint256[] memory bps;
                (recipients, bps) = IFoundation(royaltyAddress).getFees(tokenId);
                require(recipients.length == bps.length);
                return (recipients, _computeAmounts(value, bps), spec, royaltyAddress, addToCache);
            } else if (spec == EIP2981) {
                (address recipient, uint256 amount) = IEIP2981(royaltyAddress).royaltyInfo(tokenId, value);
                require(amount < value, "Invalid royalty amount");
                recipients = new address payable[](1);
                amounts = new uint256[](1);
                recipients[0] = payable(recipient);
                amounts[0] = amount;
                return (recipients, amounts, spec, royaltyAddress, addToCache);
            } else if (spec == SUPERRARE) {
                address payable creator = ISuperRareRegistry(SuperRareContracts.SUPERRARE_REGISTRY).tokenCreator(tokenAddress, tokenId);
                uint256 amount = ISuperRareRegistry(SuperRareContracts.SUPERRARE_REGISTRY).calculateRoyaltyFee(tokenAddress, tokenId, value);
                recipients = new address payable[](1);
                amounts = new uint256[](1);
                recipients[0] = creator;
                amounts[0] = amount;
                return (recipients, amounts, spec, royaltyAddress, addToCache);
            } else if (spec == ZORA) {
                uint256[] memory bps;
                (recipients, bps) = IZoraOverride(royaltyAddress).convertBidShares(tokenAddress, tokenId);
                require(recipients.length == bps.length);
                return (recipients, _computeAmounts(value, bps), spec, royaltyAddress, addToCache);
            } else if (spec == ARTBLOCKS) {
                uint256[] memory bps;
                (recipients, bps) = IArtBlocksOverride(royaltyAddress).getRoyalties(tokenAddress, tokenId);
                require(recipients.length == bps.length);
                return (recipients, _computeAmounts(value, bps), spec, royaltyAddress, addToCache);
            } else if (spec == KNOWNORIGINV2) {
                (recipients, amounts) = IKODAV2Override(royaltyAddress).getKODAV2RoyaltyInfo(tokenAddress, tokenId, value);
                return (recipients, amounts, spec, royaltyAddress, addToCache);
            }
        }
    }

    function _computeAmounts(uint256 value, uint256[] memory bps) private pure returns(uint256[] memory amounts) {
        amounts = new uint256[](bps.length);
        uint256 totalAmount;
        for (uint i = 0; i < bps.length; i++) {
            amounts[i] = value*bps[i]/10000;
            totalAmount += amounts[i];
        }
        require(totalAmount < value, "Invalid royalty amount");
        return amounts;
    }


}