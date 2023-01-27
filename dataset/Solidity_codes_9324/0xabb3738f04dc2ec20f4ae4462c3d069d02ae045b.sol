


pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




pragma solidity ^0.8.0;


abstract contract ERC165Storage is ERC165 {
    mapping(bytes4 => bool) private _supportedInterfaces;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId) || _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
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
}




pragma solidity 0.8.4;

interface IKOAccessControlsLookup {

    function hasAdminRole(address _address) external view returns (bool);


    function isVerifiedArtist(uint256 _index, address _account, bytes32[] calldata _merkleProof) external view returns (bool);


    function isVerifiedArtistProxy(address _artist, address _proxy) external view returns (bool);


    function hasLegacyMinterRole(address _address) external view returns (bool);


    function hasContractRole(address _address) external view returns (bool);


    function hasContractOrAdminRole(address _address) external view returns (bool);

}




pragma solidity 0.8.4;


interface IERC2981EditionExtension {


    function hasRoyalties(uint256 _editionId) external view returns (bool);


    function getRoyaltiesReceiver(uint256 _editionId) external view returns (address);

}

interface IERC2981 is IERC165, IERC2981EditionExtension {


    function royaltyInfo(
        uint256 _tokenId,
        uint256 _value
    ) external view returns (
        address _receiver,
        uint256 _royaltyAmount
    );


}




pragma solidity 0.8.4;

interface IKODAV3Minter {


    function mintBatchEdition(uint16 _editionSize, address _to, string calldata _uri) external returns (uint256 _editionId);


    function mintBatchEditionAndComposeERC20s(uint16 _editionSize, address _to, string calldata _uri, address[] calldata _erc20s, uint256[] calldata _amounts) external returns (uint256 _editionId);


    function mintConsecutiveBatchEdition(uint16 _editionSize, address _to, string calldata _uri) external returns (uint256 _editionId);

}




pragma solidity 0.8.4;

interface ITokenUriResolver {


    function tokenURI(uint256 _editionId, uint256 _tokenId) external view returns (string memory);


    function isDefined(uint256 _editionId, uint256 _tokenId) external view returns (bool);

}




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
}




pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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




pragma solidity 0.8.4;

interface IERC2309 {

    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed fromAddress, address indexed toAddress);
}




pragma solidity 0.8.4;


interface IHasSecondarySaleFees is IERC165 {


    event SecondarySaleFees(uint256 tokenId, address[] recipients, uint[] bps);

    function getFeeRecipients(uint256 id) external returns (address payable[] memory);


    function getFeeBps(uint256 id) external returns (uint[] memory);

}




pragma solidity 0.8.4;






interface IKODAV3 is
IERC165, // Contract introspection
IERC721, // Core NFTs
IERC2309, // Consecutive batch mint
IERC2981, // Royalties
IHasSecondarySaleFees // Rariable / Foundation royalties
{


    function getCreatorOfEdition(uint256 _editionId) external view returns (address _originalCreator);


    function getCreatorOfToken(uint256 _tokenId) external view returns (address _originalCreator);


    function getSizeOfEdition(uint256 _editionId) external view returns (uint256 _size);


    function getEditionSizeOfToken(uint256 _tokenId) external view returns (uint256 _size);


    function editionExists(uint256 _editionId) external view returns (bool);


    function isEditionSalesDisabled(uint256 _editionId) external view returns (bool);


    function isSalesDisabledOrSoldOut(uint256 _editionId) external view returns (bool);


    function maxTokenIdOfEdition(uint256 _editionId) external view returns (uint256 _tokenId);


    function getNextAvailablePrimarySaleToken(uint256 _editionId) external returns (uint256 _tokenId);


    function getReverseAvailablePrimarySaleToken(uint256 _editionId) external view returns (uint256 _tokenId);


    function facilitateNextPrimarySale(uint256 _editionId) external returns (address _receiver, address _creator, uint256 _tokenId);


    function facilitateReversePrimarySale(uint256 _editionId) external returns (address _receiver, address _creator, uint256 _tokenId);


    function royaltyAndCreatorInfo(uint256 _editionId, uint256 _value) external returns (address _receiver, address _creator, uint256 _amount);


    function updateURIIfNoSaleMade(uint256 _editionId, string calldata _newURI) external;


    function hasMadePrimarySale(uint256 _editionId) external view returns (bool);


    function isEditionSoldOut(uint256 _editionId) external view returns (bool);


    function toggleEditionSalesDisabled(uint256 _editionId) external;



    function exists(uint256 _tokenId) external view returns (bool);


    function getEditionIdOfToken(uint256 _tokenId) external pure returns (uint256 _editionId);


    function getEditionDetails(uint256 _tokenId) external view returns (address _originalCreator, address _owner, uint16 _size, uint256 _editionId, string memory _uri);


    function hadPrimarySaleOfToken(uint256 _tokenId) external view returns (bool);


}




pragma solidity 0.8.4;







interface ERC998ERC20TopDown {

    event ReceivedERC20(address indexed _from, uint256 indexed _tokenId, address indexed _erc20Contract, uint256 _value);
    event ReceivedERC20ForEdition(address indexed _from, uint256 indexed _editionId, address indexed _erc20Contract, uint256 _value);
    event TransferERC20(uint256 indexed _tokenId, address indexed _to, address indexed _erc20Contract, uint256 _value);

    function balanceOfERC20(uint256 _tokenId, address _erc20Contract) external view returns (uint256);


    function transferERC20(uint256 _tokenId, address _to, address _erc20Contract, uint256 _value) external;


    function getERC20(address _from, uint256 _tokenId, address _erc20Contract, uint256 _value) external;

}

interface ERC998ERC20TopDownEnumerable {

    function totalERC20Contracts(uint256 _tokenId) external view returns (uint256);


    function erc20ContractByIndex(uint256 _tokenId, uint256 _index) external view returns (address);

}

abstract contract TopDownERC20Composable is ERC998ERC20TopDown, ERC998ERC20TopDownEnumerable, ReentrancyGuard, Context {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(uint256 => mapping(address => uint256)) public editionTokenERC20Balances;

    mapping(uint256 => mapping(address => mapping(uint256 => uint256))) public editionTokenERC20TransferAmounts;

    mapping(uint256 => EnumerableSet.AddressSet) ERC20sEmbeddedInEdition;

    mapping(uint256 => EnumerableSet.AddressSet) ERC20sEmbeddedInNft;

    mapping(uint256 => mapping(address => uint256)) public ERC20Balances;

    function balanceOfERC20(uint256 _tokenId, address _erc20Contract) public override view returns (uint256) {
        IKODAV3 koda = IKODAV3(address(this));
        uint256 editionId = koda.getEditionIdOfToken(_tokenId);

        uint256 editionBalance = editionTokenERC20Balances[editionId][_erc20Contract];
        uint256 tokenEditionBalance = editionBalance / koda.getSizeOfEdition(editionId);
        uint256 spentTokens = editionTokenERC20TransferAmounts[editionId][_erc20Contract][_tokenId];
        tokenEditionBalance = tokenEditionBalance - spentTokens;

        return tokenEditionBalance + ERC20Balances[_tokenId][_erc20Contract];
    }

    function transferERC20(uint256 _tokenId, address _to, address _erc20Contract, uint256 _value) external override nonReentrant {
        _prepareERC20LikeTransfer(_tokenId, _to, _erc20Contract, _value);

        IERC20(_erc20Contract).transfer(_to, _value);

        emit TransferERC20(_tokenId, _to, _erc20Contract, _value);
    }

    function getERC20s(address _from, uint256[] calldata _tokenIds, address _erc20Contract, uint256 _totalValue) external {
        uint256 totalTokens = _tokenIds.length;
        require(totalTokens > 0 && _totalValue > 0, "Empty values");

        uint256 valuePerToken = _totalValue / totalTokens;
        for (uint i = 0; i < totalTokens; i++) {
            getERC20(_from, _tokenIds[i], _erc20Contract, valuePerToken);
        }
    }

    function getERC20(address _from, uint256 _tokenId, address _erc20Contract, uint256 _value) public override nonReentrant {
        require(_value > 0, "Value zero");
        require(_from == _msgSender(), "Only owner");

        address spender = _msgSender();
        IERC721 self = IERC721(address(this));

        address owner = self.ownerOf(_tokenId);
        require(
            owner == spender || self.isApprovedForAll(owner, spender) || self.getApproved(_tokenId) == spender,
            "Invalid spender"
        );

        uint256 editionId = IKODAV3(address(this)).getEditionIdOfToken(_tokenId);
        bool editionAlreadyContainsERC20 = ERC20sEmbeddedInEdition[editionId].contains(_erc20Contract);
        bool nftAlreadyContainsERC20 = ERC20sEmbeddedInNft[_tokenId].contains(_erc20Contract);

        if (!editionAlreadyContainsERC20 && !nftAlreadyContainsERC20) {
            ERC20sEmbeddedInNft[_tokenId].add(_erc20Contract);
        }

        ERC20Balances[_tokenId][_erc20Contract] = ERC20Balances[_tokenId][_erc20Contract] + _value;

        IERC20 token = IERC20(_erc20Contract);
        require(token.allowance(_from, address(this)) >= _value, "Exceeds allowance");

        token.transferFrom(_from, address(this), _value);

        emit ReceivedERC20(_from, _tokenId, _erc20Contract, _value);
    }

    function _composeERC20IntoEdition(address _from, uint256 _editionId, address _erc20Contract, uint256 _value) internal nonReentrant {
        require(_value > 0, "Value zero");

        require(!ERC20sEmbeddedInEdition[_editionId].contains(_erc20Contract), "Edition contains ERC20");

        ERC20sEmbeddedInEdition[_editionId].add(_erc20Contract);
        editionTokenERC20Balances[_editionId][_erc20Contract] = editionTokenERC20Balances[_editionId][_erc20Contract] + _value;

        IERC20(_erc20Contract).transferFrom(_from, address(this), _value);

        emit ReceivedERC20ForEdition(_from, _editionId, _erc20Contract, _value);
    }

    function totalERC20Contracts(uint256 _tokenId) override public view returns (uint256) {
        uint256 editionId = IKODAV3(address(this)).getEditionIdOfToken(_tokenId);
        return ERC20sEmbeddedInNft[_tokenId].length() + ERC20sEmbeddedInEdition[editionId].length();
    }

    function erc20ContractByIndex(uint256 _tokenId, uint256 _index) override external view returns (address) {
        uint256 numOfERC20sInNFT = ERC20sEmbeddedInNft[_tokenId].length();
        if (_index >= numOfERC20sInNFT) {
            uint256 editionId =  IKODAV3(address(this)).getEditionIdOfToken(_tokenId);
            return ERC20sEmbeddedInEdition[editionId].at(_index - numOfERC20sInNFT);
        }

        return ERC20sEmbeddedInNft[_tokenId].at(_index);
    }


    function _prepareERC20LikeTransfer(uint256 _tokenId, address _to, address _erc20Contract, uint256 _value) private {
        {
            require(_value > 0, "Value zero");
            require(_to != address(0), "Zero address");

            IERC721 self = IERC721(address(this));

            address owner = self.ownerOf(_tokenId);
            require(
                owner == _msgSender() || self.isApprovedForAll(owner, _msgSender()) || self.getApproved(_tokenId) == _msgSender(),
                "Not owner"
            );
        }

        bool nftContainsERC20 = ERC20sEmbeddedInNft[_tokenId].contains(_erc20Contract);

        IKODAV3 koda = IKODAV3(address(this));
        uint256 editionId = koda.getEditionIdOfToken(_tokenId);
        bool editionContainsERC20 = ERC20sEmbeddedInEdition[editionId].contains(_erc20Contract);
        require(nftContainsERC20 || editionContainsERC20, "No such ERC20");

        require(balanceOfERC20(_tokenId, _erc20Contract) >= _value, "Exceeds balance");

        uint256 editionSize = koda.getSizeOfEdition(editionId);
        uint256 tokenInitialBalance = editionTokenERC20Balances[editionId][_erc20Contract] / editionSize;
        uint256 spentTokens = editionTokenERC20TransferAmounts[editionId][_erc20Contract][_tokenId];
        uint256 editionTokenBalance = tokenInitialBalance - spentTokens;

        if (editionTokenBalance >= _value) {
            editionTokenERC20TransferAmounts[editionId][_erc20Contract][_tokenId] = spentTokens + _value;
        } else if (ERC20Balances[_tokenId][_erc20Contract] >= _value) {
            ERC20Balances[_tokenId][_erc20Contract] = ERC20Balances[_tokenId][_erc20Contract] - _value;
        } else {
            editionTokenERC20TransferAmounts[editionId][_erc20Contract][_tokenId] = spentTokens + editionTokenBalance;
            uint256 amountOfTokensToSpendFromTokenBalance = _value - editionTokenBalance;
            ERC20Balances[_tokenId][_erc20Contract] = ERC20Balances[_tokenId][_erc20Contract] - amountOfTokensToSpendFromTokenBalance;
        }

        if (nftContainsERC20 && ERC20Balances[_tokenId][_erc20Contract] == 0) {
            ERC20sEmbeddedInNft[_tokenId].remove(_erc20Contract);
        }

        if (editionContainsERC20) {
            uint256 allTokensInEditionERC20Balance;
            for (uint i = 0; i < editionSize; i++) {
                uint256 tokenBal = tokenInitialBalance - editionTokenERC20TransferAmounts[editionId][_erc20Contract][editionId + i];
                allTokensInEditionERC20Balance = allTokensInEditionERC20Balance + tokenBal;
            }

            if (allTokensInEditionERC20Balance == 0) {
                ERC20sEmbeddedInEdition[editionId].remove(_erc20Contract);
            }
        }
    }
}




pragma solidity 0.8.4;



abstract contract TopDownSimpleERC721Composable is Context {
    struct ComposedNFT {
        address nft;
        uint256 tokenId;
    }

    mapping(uint256 => ComposedNFT) public kodaTokenComposedNFT;

    mapping(address => mapping(uint256 => uint256)) public composedNFTsToKodaToken;

    event ReceivedChild(address indexed _from, uint256 indexed _tokenId, address indexed _childContract, uint256 _childTokenId);
    event TransferChild(uint256 indexed _tokenId, address indexed _to, address indexed _childContract, uint256 _childTokenId);

    function composeNFTsIntoKodaTokens(uint256[] calldata _kodaTokenIds, address _nft, uint256[] calldata _nftTokenIds) external {
        uint256 totalKodaTokens = _kodaTokenIds.length;
        require(totalKodaTokens > 0 && totalKodaTokens == _nftTokenIds.length, "Invalid list");

        IERC721 nftContract = IERC721(_nft);

        for (uint i = 0; i < totalKodaTokens; i++) {
            uint256 _kodaTokenId = _kodaTokenIds[i];
            uint256 _nftTokenId = _nftTokenIds[i];

            require(
                IERC721(address(this)).ownerOf(_kodaTokenId) == nftContract.ownerOf(_nftTokenId),
                "Owner mismatch"
            );

            kodaTokenComposedNFT[_kodaTokenId] = ComposedNFT(_nft, _nftTokenId);
            composedNFTsToKodaToken[_nft][_nftTokenId] = _kodaTokenId;

            nftContract.transferFrom(_msgSender(), address(this), _nftTokenId);
            emit ReceivedChild(_msgSender(), _kodaTokenId, _nft, _nftTokenId);
        }
    }

    function transferChild(uint256 _kodaTokenId, address _recipient) external {
        require(
            IERC721(address(this)).ownerOf(_kodaTokenId) == _msgSender(),
            "Only KODA owner"
        );

        address nft = kodaTokenComposedNFT[_kodaTokenId].nft;
        uint256 nftId = kodaTokenComposedNFT[_kodaTokenId].tokenId;

        delete kodaTokenComposedNFT[_kodaTokenId];
        delete composedNFTsToKodaToken[nft][nftId];

        IERC721(nft).transferFrom(address(this), _recipient, nftId);

        emit TransferChild(_kodaTokenId, _recipient, nft, nftId);
    }
}




pragma solidity 0.8.4;

contract Konstants {


    uint16 public constant MAX_EDITION_SIZE = 1000;

    function _editionFromTokenId(uint256 _tokenId) internal pure returns (uint256) {

        return (_tokenId / MAX_EDITION_SIZE) * MAX_EDITION_SIZE;
    }
}




pragma solidity 0.8.4;






abstract contract BaseKoda is Konstants, Context, IKODAV3 {

    bytes4 constant internal ERC721_RECEIVED = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));

    event AdminUpdateSecondaryRoyalty(uint256 _secondarySaleRoyalty);
    event AdminUpdateBasisPointsModulo(uint256 _basisPointsModulo);
    event AdminUpdateModulo(uint256 _modulo);
    event AdminEditionReported(uint256 indexed _editionId, bool indexed _reported);
    event AdminArtistAccountReported(address indexed _account, bool indexed _reported);
    event AdminUpdateAccessControls(IKOAccessControlsLookup indexed _oldAddress, IKOAccessControlsLookup indexed _newAddress);

    modifier onlyContract(){
        _onlyContract();
        _;
    }

    function _onlyContract() private view {
        require(accessControls.hasContractRole(_msgSender()), "Must be contract");
    }

    modifier onlyAdmin(){
        _onlyAdmin();
        _;
    }

    function _onlyAdmin() private view {
        require(accessControls.hasAdminRole(_msgSender()), "Must be admin");
    }

    IKOAccessControlsLookup public accessControls;

    mapping(uint256 => bool) public reportedEditionIds;

    mapping(address => bool) public reportedArtistAccounts;

    uint256 public secondarySaleRoyalty = 12_50000; // 12.5% by default

    uint256 public modulo = 100_00000;

    uint256 public basisPointsModulo = 1000;

    constructor(IKOAccessControlsLookup _accessControls) {
        accessControls = _accessControls;
    }

    function reportEditionId(uint256 _editionId, bool _reported) onlyAdmin public {
        reportedEditionIds[_editionId] = _reported;
        emit AdminEditionReported(_editionId, _reported);
    }

    function reportArtistAccount(address _account, bool _reported) onlyAdmin public {
        reportedArtistAccounts[_account] = _reported;
        emit AdminArtistAccountReported(_account, _reported);
    }

    function updateBasisPointsModulo(uint256 _basisPointsModulo) onlyAdmin public {
        require(_basisPointsModulo > 0, "Is zero");
        basisPointsModulo = _basisPointsModulo;
        emit AdminUpdateBasisPointsModulo(_basisPointsModulo);
    }

    function updateModulo(uint256 _modulo) onlyAdmin public {
        require(_modulo > 0, "Is zero");
        modulo = _modulo;
        emit AdminUpdateModulo(_modulo);
    }

    function updateSecondaryRoyalty(uint256 _secondarySaleRoyalty) onlyAdmin public {
        secondarySaleRoyalty = _secondarySaleRoyalty;
        emit AdminUpdateSecondaryRoyalty(_secondarySaleRoyalty);
    }

    function updateAccessControls(IKOAccessControlsLookup _accessControls) public onlyAdmin {
        require(_accessControls.hasAdminRole(_msgSender()), "Must be admin");
        emit AdminUpdateAccessControls(accessControls, _accessControls);
        accessControls = _accessControls;
    }

    function withdrawStuckTokens(address _tokenAddress, uint256 _amount, address _withdrawalAccount) onlyAdmin public {
        IERC20(_tokenAddress).transfer(_withdrawalAccount, _amount);
    }
}




pragma solidity 0.8.4;











contract KnownOriginDigitalAssetV3 is
TopDownERC20Composable,
TopDownSimpleERC721Composable,
BaseKoda,
ERC165Storage,
IKODAV3Minter {


    event EditionURIUpdated(uint256 indexed _editionId);
    event EditionSalesDisabledToggled(uint256 indexed _editionId, bool _oldValue, bool _newValue);
    event SealedEditionMetaDataSet(uint256 indexed _editionId);
    event SealedTokenMetaDataSet(uint256 indexed _tokenId);
    event AdditionalEditionUnlockableSet(uint256 indexed _editionId);
    event AdminRoyaltiesRegistryProxySet(address indexed _royaltiesRegistryProxy);
    event AdminTokenUriResolverSet(address indexed _tokenUriResolver);

    modifier validateEdition(uint256 _editionId) {

        _validateEdition(_editionId);
        _;
    }

    function _validateEdition(uint256 _editionId) private view {

        require(_editionExists(_editionId), "Edition does not exist");
    }

    modifier validateCreator(uint256 _editionId) {

        address creator = getCreatorOfEdition(_editionId);
        require(
            _msgSender() == creator || accessControls.isVerifiedArtistProxy(creator, _msgSender()),
            "Only creator or proxy"
        );
        _;
    }

    string public constant name = "KnownOriginDigitalAsset";

    string public constant symbol = "KODA";

    string public constant version = "3";

    IERC2981 public royaltiesRegistryProxy;

    ITokenUriResolver public tokenUriResolver;

    uint256 public editionPointer;

    struct EditionDetails {
        address creator; // primary edition/token creator
        uint16 editionSize; // onchain edition size
        string uri; // the referenced metadata
    }

    mapping(uint256 => EditionDetails) internal editionDetails;

    mapping(uint256 => address) internal owners;

    mapping(address => uint256) internal balances;

    mapping(uint256 => address) internal approvals;

    mapping(address => mapping(address => bool)) internal operatorApprovals;

    mapping(uint256 => string) public sealedEditionMetaData;

    mapping(uint256 => string) public sealedTokenMetaData;

    mapping(uint256 => bool) public editionSalesDisabled;

    constructor(
        IKOAccessControlsLookup _accessControls,
        IERC2981 _royaltiesRegistryProxy,
        uint256 _editionPointer
    ) BaseKoda(_accessControls) {
        editionPointer = _editionPointer;

        royaltiesRegistryProxy = _royaltiesRegistryProxy;

        _registerInterface(0x80ac58cd);

        _registerInterface(0x5b5e139f);

        _registerInterface(0x2a55205a);

        _registerInterface(0xb7799584);
    }

    function mintBatchEdition(uint16 _editionSize, address _to, string calldata _uri)
    public
    override
    onlyContract
    returns (uint256 _editionId) {

        return _mintBatchEdition(_editionSize, _to, _uri);
    }

    function mintBatchEditionAndComposeERC20s(
        uint16 _editionSize,
        address _to,
        string calldata _uri,
        address[] calldata _erc20s,
        uint256[] calldata _amounts
    ) external
    override
    onlyContract
    returns (uint256 _editionId) {

        uint256 totalErc20s = _erc20s.length;
        require(totalErc20s > 0 && totalErc20s == _amounts.length, "Tokens invalid");

        _editionId = _mintBatchEdition(_editionSize, _to, _uri);

        for (uint i = 0; i < totalErc20s; i++) {
            _composeERC20IntoEdition(_to, _editionId, _erc20s[i], _amounts[i]);
        }
    }

    function _mintBatchEdition(uint16 _editionSize, address _to, string calldata _uri) internal returns (uint256) {

        require(_editionSize > 0 && _editionSize <= MAX_EDITION_SIZE, "Invalid size");

        uint256 start = generateNextEditionNumber();


        balances[_to] = balances[_to] + _editionSize;

        editionDetails[start] = EditionDetails(_to, _editionSize, _uri);

        uint256 end = start + _editionSize;
        for (uint i = start; i < end; i++) {
            emit Transfer(address(0), _to, i);
        }
        return start;
    }

    function mintConsecutiveBatchEdition(uint16 _editionSize, address _to, string calldata _uri)
    public
    override
    onlyContract
    returns (uint256 _editionId) {

        require(_editionSize > 0 && _editionSize <= MAX_EDITION_SIZE, "Invalid size");

        uint256 start = generateNextEditionNumber();


        balances[_to] = balances[_to] + _editionSize;

        editionDetails[start] = EditionDetails(_to, _editionSize, _uri);

        emit ConsecutiveTransfer(start, start + _editionSize, address(0), _to);

        return start;
    }

    function updateURIIfNoSaleMade(uint256 _editionId, string calldata _newURI)
    external
    override
    validateCreator(_editionId) {

        require(
            !hasMadePrimarySale(_editionId) && (!tokenUriResolverActive() || !tokenUriResolver.isDefined(_editionId, 0)),
            "Invalid state"
        );

        editionDetails[_editionId].uri = _newURI;

        emit EditionURIUpdated(_editionId);
    }

    function generateNextEditionNumber() internal returns (uint256) {

        editionPointer = editionPointer + MAX_EDITION_SIZE;
        return editionPointer;
    }

    function editionURI(uint256 _editionId) validateEdition(_editionId) public view returns (string memory) {


        if (tokenUriResolverActive() && tokenUriResolver.isDefined(_editionId, 0)) {
            return tokenUriResolver.tokenURI(_editionId, 0);
        }

        return editionDetails[_editionId].uri;
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {

        require(_exists(_tokenId), "Token does not exist");
        uint256 editionId = _editionFromTokenId(_tokenId);

        if (tokenUriResolverActive() && tokenUriResolver.isDefined(editionId, _tokenId)) {
            return tokenUriResolver.tokenURI(editionId, _tokenId);
        }

        return editionDetails[editionId].uri;
    }

    function tokenUriResolverActive() public view returns (bool) {

        return address(tokenUriResolver) != address(0);
    }

    function editionAdditionalMetaData(uint256 _editionId) public view returns (string memory) {

        return sealedEditionMetaData[_editionId];
    }

    function tokenAdditionalMetaData(uint256 _tokenId) public view returns (string memory) {

        return sealedTokenMetaData[_tokenId];
    }

    function editionAdditionalMetaDataForToken(uint256 _tokenId) public view returns (string memory) {

        uint256 editionId = _editionFromTokenId(_tokenId);
        return sealedEditionMetaData[editionId];
    }

    function getEditionDetails(uint256 _tokenId)
    public
    override
    view
    returns (address _originalCreator, address _owner, uint16 _size, uint256 _editionId, string memory _uri) {

        uint256 editionId = _editionFromTokenId(_tokenId);
        EditionDetails storage edition = editionDetails[editionId];
        return (
        edition.creator,
        _ownerOf(_tokenId, editionId),
        edition.editionSize,
        editionId,
        tokenURI(_tokenId)
        );
    }


    function isEditionSalesDisabled(uint256 _editionId) external view override returns (bool) {

        return editionSalesDisabled[_editionId];
    }

    function isSalesDisabledOrSoldOut(uint256 _editionId) external view override returns (bool) {

        return editionSalesDisabled[_editionId] || isEditionSoldOut(_editionId);
    }

    function toggleEditionSalesDisabled(uint256 _editionId) validateEdition(_editionId) external override {

        address creator = editionDetails[_editionId].creator;

        require(
            creator == _msgSender() || accessControls.hasAdminRole(_msgSender()),
            "Only creator or admin"
        );

        emit EditionSalesDisabledToggled(_editionId, editionSalesDisabled[_editionId], !editionSalesDisabled[_editionId]);

        editionSalesDisabled[_editionId] = !editionSalesDisabled[_editionId];
    }


    function getCreatorOfEdition(uint256 _editionId) public override view returns (address _originalCreator) {

        return _getCreatorOfEdition(_editionId);
    }

    function getCreatorOfToken(uint256 _tokenId) public override view returns (address _originalCreator) {

        return _getCreatorOfEdition(_editionFromTokenId(_tokenId));
    }

    function _getCreatorOfEdition(uint256 _editionId) internal view returns (address _originalCreator) {

        return editionDetails[_editionId].creator;
    }


    function getSizeOfEdition(uint256 _editionId) public override view returns (uint256 _size) {

        return editionDetails[_editionId].editionSize;
    }

    function getEditionSizeOfToken(uint256 _tokenId) public override view returns (uint256 _size) {

        return editionDetails[_editionFromTokenId(_tokenId)].editionSize;
    }


    function editionExists(uint256 _editionId) public override view returns (bool) {

        return _editionExists(_editionId);
    }

    function _editionExists(uint256 _editionId) internal view returns (bool) {

        return editionDetails[_editionId].editionSize > 0;
    }

    function exists(uint256 _tokenId) public override view returns (bool) {

        return _exists(_tokenId);
    }

    function _exists(uint256 _tokenId) internal view returns (bool) {

        return _ownerOf(_tokenId, _editionFromTokenId(_tokenId)) != address(0);
    }

    function maxTokenIdOfEdition(uint256 _editionId) public override view returns (uint256 _tokenId) {

        return _maxTokenIdOfEdition(_editionId);
    }

    function _maxTokenIdOfEdition(uint256 _editionId) internal view returns (uint256 _tokenId) {

        return editionDetails[_editionId].editionSize + _editionId;
    }


    function getEditionIdOfToken(uint256 _tokenId) public override pure returns (uint256 _editionId) {

        return _editionFromTokenId(_tokenId);
    }

    function _royaltyInfo(uint256 _tokenId, uint256 _value) internal view returns (address _receiver, uint256 _royaltyAmount) {

        uint256 editionId = _editionFromTokenId(_tokenId);
        if (royaltyRegistryActive() && royaltiesRegistryProxy.hasRoyalties(editionId)) {
            (_receiver, _royaltyAmount) = royaltiesRegistryProxy.royaltyInfo(editionId, _value);
        } else {
            _receiver = _getCreatorOfEdition(editionId);
            _royaltyAmount = (_value / modulo) * secondarySaleRoyalty;
        }
    }


    function royaltyInfo(uint256 _tokenId, uint256 _value)
    external
    override
    view
    returns (address _receiver, uint256 _royaltyAmount) {

        return _royaltyInfo(_tokenId, _value);
    }

    function royaltyAndCreatorInfo(uint256 _tokenId, uint256 _value)
    external
    view
    override
    returns (address receiver, address creator, uint256 royaltyAmount) {

        address originalCreator = _getCreatorOfEdition(_editionFromTokenId(_tokenId));
        (address _receiver, uint256 _royaltyAmount) = _royaltyInfo(_tokenId, _value);
        return (_receiver, originalCreator, _royaltyAmount);
    }

    function hasRoyalties(uint256 _editionId) validateEdition(_editionId) external override view returns (bool) {

        return royaltyRegistryActive() && royaltiesRegistryProxy.hasRoyalties(_editionId)
        || secondarySaleRoyalty > 0;
    }

    function getRoyaltiesReceiver(uint256 _tokenId) public override view returns (address) {

        uint256 editionId = _editionFromTokenId(_tokenId);
        if (royaltyRegistryActive() && royaltiesRegistryProxy.hasRoyalties(editionId)) {
            return royaltiesRegistryProxy.getRoyaltiesReceiver(editionId);
        }
        return _getCreatorOfEdition(editionId);
    }

    function royaltyRegistryActive() public view returns (bool) {

        return address(royaltiesRegistryProxy) != address(0);
    }


    function getFeeRecipients(uint256 _tokenId) external view override returns (address payable[] memory) {

        address payable[] memory feeRecipients = new address payable[](1);
        feeRecipients[0] = payable(getRoyaltiesReceiver(_tokenId));
        return feeRecipients;
    }

    function getFeeBps(uint256) external view override returns (uint[] memory) {

        uint[] memory feeBps = new uint[](1);
        feeBps[0] = uint(secondarySaleRoyalty) / basisPointsModulo;
        return feeBps;
    }


    function getAllUnsoldTokenIdsForEdition(uint256 _editionId) validateEdition(_editionId) public view returns (uint256[] memory) {

        uint256 maxTokenId = _maxTokenIdOfEdition(_editionId);

        uint256 numOfUnsoldTokens;
        for (uint256 i = _editionId; i < maxTokenId; i++) {
            if (owners[i] == address(0)) {
                numOfUnsoldTokens += 1;
            }
        }

        uint256[] memory unsoldTokens = new uint256[](numOfUnsoldTokens);

        uint256 nextIndex;
        for (uint256 tokenId = _editionId; tokenId < maxTokenId; tokenId++) {
            if (owners[tokenId] == address(0)) {
                unsoldTokens[nextIndex] = tokenId;
                nextIndex += 1;
            }
        }

        return unsoldTokens;
    }

    function facilitateNextPrimarySale(uint256 _editionId)
    public
    view
    override
    returns (address receiver, address creator, uint256 tokenId) {

        require(!editionSalesDisabled[_editionId], "Edition disabled");

        uint256 _tokenId = getNextAvailablePrimarySaleToken(_editionId);
        address _creator = _getCreatorOfEdition(_editionId);

        if (royaltyRegistryActive() && royaltiesRegistryProxy.hasRoyalties(_editionId)) {
            address _receiver = royaltiesRegistryProxy.getRoyaltiesReceiver(_editionId);
            return (_receiver, _creator, _tokenId);
        }

        return (_creator, _creator, _tokenId);
    }

    function getNextAvailablePrimarySaleToken(uint256 _editionId) public override view returns (uint256 _tokenId) {

        uint256 maxTokenId = _maxTokenIdOfEdition(_editionId);

        for (uint256 tokenId = _editionId; tokenId < maxTokenId; tokenId++) {
            if (owners[tokenId] == address(0)) {
                return tokenId;
            }
        }
        revert("Primary market exhausted");
    }

    function getReverseAvailablePrimarySaleToken(uint256 _editionId) public override view returns (uint256 _tokenId) {

        uint256 highestTokenId = _maxTokenIdOfEdition(_editionId) - 1;

        while (highestTokenId >= _editionId) {
            if (owners[highestTokenId] == address(0)) {
                return highestTokenId;
            }
            highestTokenId--;
        }
        revert("Primary market exhausted");
    }

    function facilitateReversePrimarySale(uint256 _editionId)
    public
    view
    override
    returns (address receiver, address creator, uint256 tokenId) {

        require(!editionSalesDisabled[_editionId], "Edition disabled");

        uint256 _tokenId = getReverseAvailablePrimarySaleToken(_editionId);
        address _creator = _getCreatorOfEdition(_editionId);

        if (royaltyRegistryActive() && royaltiesRegistryProxy.hasRoyalties(_editionId)) {
            address _receiver = royaltiesRegistryProxy.getRoyaltiesReceiver(_editionId);
            return (_receiver, _creator, _tokenId);
        }

        return (_creator, _creator, _tokenId);
    }

    function hadPrimarySaleOfToken(uint256 _tokenId) public override view returns (bool) {

        return owners[_tokenId] != address(0);
    }

    function hasMadePrimarySale(uint256 _editionId) validateEdition(_editionId) public override view returns (bool) {

        uint256 maxTokenId = _maxTokenIdOfEdition(_editionId);

        for (uint256 tokenId = _editionId; tokenId < maxTokenId; tokenId++) {
            if (owners[tokenId] != address(0)) {
                return true;
            }
        }
        return false;
    }

    function isEditionSoldOut(uint256 _editionId) validateEdition(_editionId) public override view returns (bool) {

        uint256 maxTokenId = _maxTokenIdOfEdition(_editionId);

        for (uint256 tokenId = _editionId; tokenId < maxTokenId; tokenId++) {
            if (owners[tokenId] == address(0)) {
                return false;
            }
        }

        return true;
    }


    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) override external {

        _safeTransferFrom(_from, _to, _tokenId, _data);

        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) override external {

        _safeTransferFrom(_from, _to, _tokenId, bytes(""));

        emit Transfer(_from, _to, _tokenId);
    }

    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) private {

        _transferFrom(_from, _to, _tokenId);

        uint256 receiverCodeSize;
        assembly {
            receiverCodeSize := extcodesize(_to)
        }
        if (receiverCodeSize > 0) {
            bytes4 selector = IERC721Receiver(_to).onERC721Received(
                _msgSender(),
                _from,
                _tokenId,
                _data
            );
            require(
                selector == ERC721_RECEIVED,
                "Invalid selector"
            );
        }
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) override external {

        _transferFrom(_from, _to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId) private {

        require(_to != address(0), "Invalid to address");

        address owner = _ownerOf(_tokenId, _editionFromTokenId(_tokenId));
        require(owner != address(0), "Invalid owner");
        require(_from == owner, "Owner mismatch");

        address spender = _msgSender();
        address approvedAddress = getApproved(_tokenId);
        require(
            spender == owner // sending to myself
            || isApprovedForAll(owner, spender)  // is approved to send any behalf of owner
            || approvedAddress == spender, // is approved to move this token ID
            "Invalid spender"
        );

        if (approvedAddress != address(0)) {
            approvals[_tokenId] = address(0);
        }

        owners[_tokenId] = _to;

        balances[_from] = balances[_from] - 1;
        balances[_to] = balances[_to] + 1;
    }

    function ownerOf(uint256 _tokenId) override public view returns (address) {

        uint256 editionId = _editionFromTokenId(_tokenId);
        address owner = _ownerOf(_tokenId, editionId);
        require(owner != address(0), "Invalid owner");
        return owner;
    }

    function _ownerOf(uint256 _tokenId, uint256 _editionId) internal view returns (address) {


        address owner = owners[_tokenId];
        if (owner != address(0)) {
            return owner;
        }

        address possibleCreator = _getCreatorOfEdition(_editionId);
        if (possibleCreator != address(0) && (_maxTokenIdOfEdition(_editionId) - 1) >= _tokenId) {
            return possibleCreator;
        }

        return address(0);
    }

    function approve(address _approved, uint256 _tokenId) override external {

        address owner = ownerOf(_tokenId);
        require(_approved != owner, "Approved is owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()), "Invalid sender");
        approvals[_tokenId] = _approved;
        emit Approval(owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) override external {

        operatorApprovals[_msgSender()][_operator] = _approved;
        emit ApprovalForAll(
            _msgSender(),
            _operator,
            _approved
        );
    }

    function balanceOf(address _owner) override external view returns (uint256) {

        require(_owner != address(0), "Invalid owner");
        return balances[_owner];
    }

    function getApproved(uint256 _tokenId) override public view returns (address){

        return approvals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) override public view returns (bool){

        return operatorApprovals[_owner][_operator];
    }

    function batchTransferFrom(address _from, address _to, uint256[] calldata _tokenIds) public {

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            _safeTransferFrom(_from, _to, _tokenIds[i], bytes(""));
            emit Transfer(_from, _to, _tokenIds[i]);
        }
    }

    function consecutiveBatchTransferFrom(address _from, address _to, uint256 _fromTokenId, uint256 _toTokenId) public {

        for (uint256 i = _fromTokenId; i <= _toTokenId; i++) {
            _safeTransferFrom(_from, _to, i, bytes(""));
        }
        emit ConsecutiveTransfer(_fromTokenId, _toTokenId, _from, _to);
    }


    function setRoyaltiesRegistryProxy(IERC2981 _royaltiesRegistryProxy) onlyAdmin public {

        royaltiesRegistryProxy = _royaltiesRegistryProxy;
        emit AdminRoyaltiesRegistryProxySet(address(_royaltiesRegistryProxy));
    }

    function setTokenUriResolver(ITokenUriResolver _tokenUriResolver) onlyAdmin public {

        tokenUriResolver = _tokenUriResolver;
        emit AdminTokenUriResolverSet(address(_tokenUriResolver));
    }


    function composeERC20sAsCreator(uint16 _editionId, address[] calldata _erc20s, uint256[] calldata _amounts)
    external
    validateCreator(_editionId) {

        require(!isEditionSoldOut(_editionId), "Edition soldout");

        uint256 totalErc20s = _erc20s.length;
        require(totalErc20s > 0 && totalErc20s == _amounts.length, "Tokens invalid");

        for (uint i = 0; i < totalErc20s; i++) {
            _composeERC20IntoEdition(_msgSender(), _editionId, _erc20s[i], _amounts[i]);
        }
    }

    function lockInAdditionalMetaData(uint256 _editionId, string calldata _metadata)
    external
    validateCreator(_editionId) {

        require(bytes(sealedEditionMetaData[_editionId]).length == 0, "Already set");
        sealedEditionMetaData[_editionId] = _metadata;
        emit SealedEditionMetaDataSet(_editionId);
    }

    function lockInAdditionalTokenMetaData(uint256 _tokenId, string calldata _metadata) external {

        require(
            _msgSender() == ownerOf(_tokenId) || accessControls.hasContractRole(_msgSender()),
            "Invalid caller"
        );
        require(bytes(sealedTokenMetaData[_tokenId]).length == 0, "Already set");
        sealedTokenMetaData[_tokenId] = _metadata;
        emit SealedTokenMetaDataSet(_tokenId);
    }
}