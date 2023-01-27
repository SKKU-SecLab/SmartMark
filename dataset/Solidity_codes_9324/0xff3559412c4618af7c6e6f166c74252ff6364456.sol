


pragma solidity ^0.6.0;

contract VRFRequestIDBase {


  function makeVRFInputSeed(bytes32 _keyHash, uint256 _userSeed,
    address _requester, uint256 _nonce)
    internal pure returns (uint256)
  {

    return  uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {

    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}


pragma solidity ^0.6.0;

interface LinkTokenInterface {

  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);

}


pragma solidity ^0.6.0;

library SafeMathChainlink {


  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}


pragma solidity ^0.6.0;

abstract contract VRFConsumerBase is VRFRequestIDBase {

  using SafeMathChainlink for uint256;

   
  function fulfillRandomness(bytes32 requestId, uint256 randomness)
    internal virtual;

  function requestRandomness(bytes32 _keyHash, uint256 _fee, uint256 _seed)
    internal returns (bytes32 requestId)
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, _seed));

    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, _seed, address(this), nonces[_keyHash]);

    nonces[_keyHash] = nonces[_keyHash].add(1);
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) public nonces;
  constructor(address _vrfCoordinator, address _link) public {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}



pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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



pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity >=0.6.0 <0.8.0;

abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}



pragma solidity >=0.6.0 <0.8.0;

interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}



pragma solidity >=0.6.2 <0.8.0;

interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}



pragma solidity >=0.6.2 <0.8.0;

interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}


pragma solidity 0.6.6;

contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using SafeMath
    for uint256;
    using Address
    for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string internal _uri;

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    constructor() public {
        _setURI("ipfs://QmV9hwWvs2vsrBV8ewjfQSijFG4PEpJkGhxZBjRia4gyYP/{id}.json");

        _registerInterface(_INTERFACE_ID_ERC1155);

        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    function uri(uint256) external view override returns(string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view override returns(uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
    public
    view
    override
    returns(uint256[] memory) {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            require(accounts[i] != address(0), "ERC1155: batch balance query for the zero address");
            batchBalances[i] = _balances[ids[i]][accounts[i]];
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view override returns(bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
    public
    virtual
    override {

        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
    public
    virtual
    override {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }
          
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        bytes memory data = "";

        address operator = to;

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(address account, uint256 id, uint256 amount) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {

        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
    internal virtual {}


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
    private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns(bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
    private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns(bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns(uint256[] memory) {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

contract EtherCatsFactory is ERC1155 {

    uint256 constant public catsInPool = 9;

    function ratingLookup(uint256 index) internal pure returns(uint256) {

        if (index <= 1275) return 1;
        else if (index <= 2550) return 2;
        else if (index <= 3825) return 3;
        else if (index <= 5100) return 4;
        else if (index <= 6375) return 5;
        else if (index <= 7650) return 6;
        else if (index <= 8925) return 7;
        else if (index <= 10200) return 8;
        else if (index <= 11475) return 9;
        else if (index <= 12750) return 10;
        else if (index <= 14025) return 11;
        else if (index <= 15300) return 12;
        else if (index <= 16575) return 13;
        else if (index <= 17850) return 14;
        else if (index <= 19125) return 15;
        else if (index <= 20400) return 16;
        else if (index <= 21675) return 17;
        else if (index <= 22950) return 18;
        else if (index <= 24225) return 19;
        else if (index <= 25500) return 20;
        else if (index <= 26775) return 21;
        else if (index <= 28050) return 22;
        else if (index <= 29325) return 23;
        else if (index <= 30600) return 24;
        else if (index <= 31875) return 25;
        else if (index <= 33150) return 26;
        else if (index <= 34425) return 27;
        else if (index <= 35700) return 28;
        else if (index <= 36975) return 29;
        else if (index <= 38250) return 30;
        else if (index <= 39525) return 31;
        else if (index <= 40800) return 32;
        else if (index <= 42075) return 33;
        else if (index <= 43350) return 34;
        else if (index <= 44625) return 35;
        else if (index <= 45900) return 36;
        else if (index <= 47175) return 37;
        else if (index <= 48450) return 38;
        else if (index <= 49725) return 39;
        else if (index <= 51000) return 40;
        else if (index <= 52275) return 41;
        else if (index <= 53550) return 42;
        else if (index <= 54825) return 43;
        else if (index <= 56100) return 44;
        else if (index <= 57375) return 45;
        else if (index <= 58650) return 46;
        else if (index <= 59925) return 47;
        else if (index <= 61200) return 48;
        else if (index <= 62475) return 49;
        else if (index <= 63750) return 50;
        else if (index <= 65025) return 51;
        else if (index <= 66300) return 52;
        else if (index <= 67575) return 53;
        else if (index <= 68850) return 54;
        else if (index <= 70125) return 55;
        else if (index <= 71400) return 56;
        else if (index <= 72675) return 57;
        else if (index <= 73950) return 58;
        else if (index <= 75225) return 59;
        else if (index <= 76500) return 60;
        else if (index <= 77775) return 61;
        else if (index <= 79050) return 62;
        else if (index <= 80325) return 63;
        else if (index <= 81600) return 64;
        else if (index <= 82875) return 65;
        else if (index <= 84150) return 66;
        else if (index <= 85425) return 67;
        else if (index <= 86700) return 68;
        else if (index <= 87975) return 69;
        else if (index <= 88900) return 70;
        else if (index <= 89800) return 71;
        else if (index <= 90700) return 72;
        else if (index <= 91600) return 73;
        else if (index <= 92500) return 74;
        else if (index <= 93400) return 75;
        else if (index <= 94300) return 76;
        else if (index <= 95200) return 77;
        else if (index <= 96100) return 78;
        else if (index <= 97000) return 79;
        else if (index <= 97200) return 80;
        else if (index <= 97400) return 81;
        else if (index <= 97600) return 82;
        else if (index <= 97800) return 83;
        else if (index <= 98000) return 84;
        else if (index <= 98200) return 85;
        else if (index <= 98400) return 86;
        else if (index <= 98600) return 87;
        else if (index <= 98800) return 88;
        else if (index <= 99000) return 89;
        else if (index <= 99145) return 90;
        else if (index <= 99285) return 91;
        else if (index <= 99415) return 92;
        else if (index <= 99540) return 93;
        else if (index <= 99660) return 94;
        else if (index <= 99770) return 95;
        else if (index <= 99870) return 96;
        else if (index <= 99960) return 97;
        else if (index <= 99990) return 98;
        else if (index < 99999) return 99;
        else if (index == 99999) return 100;
    }

    function multiplierLookup(uint256 index) internal pure returns(uint256) {

        if (index <= 50) return 1;
        else if (index <= 85) return 2;
        else if (index <= 95) return 3;
        else if (index < 99) return 5;
        else if (index == 99) return 8;
    }

    function mintFiveCats(address buyer, uint256 randomNumberFromChainlink) internal {

        uint256[5] memory cats;
        uint256[5] memory ratings;
        uint256[5] memory multipliers;
        uint256[] memory tokenIDs = new uint256[](5);
        uint256[] memory amounts = new uint256[](5);
        amounts[0] = 1;
        amounts[1] = 1;
        amounts[2] = 1;
        amounts[3] = 1;
        amounts[4] = 1;

        uint256 randomNumber = randomNumberFromChainlink;
        cats[0] = (randomNumber % 10 ** 3 + catsInPool) % catsInPool;
        ratings[0] = ratingLookup((randomNumber % 10 ** 8 / 10 ** 3));
        multipliers[0] = multiplierLookup((randomNumber % 10 ** 10 / 10 ** 8));
        cats[1] = (randomNumber % 10 ** 13 / 10 ** 10) % catsInPool;
        ratings[1] = ratingLookup((randomNumber % 10 ** 18 / 10 ** 13));
        multipliers[1] = multiplierLookup((randomNumber % 10 ** 20 / 10 ** 18));
        cats[2] = (randomNumber % 10 ** 23 / 10 ** 20) % catsInPool;
        ratings[2] = ratingLookup((randomNumber % 10 ** 28 / 10 ** 23));
        multipliers[2] = multiplierLookup((randomNumber % 10 ** 30 / 10 ** 28));
        cats[3] = (randomNumber % 10 ** 33 / 10 ** 30) % catsInPool;
        ratings[3] = ratingLookup((randomNumber % 10 ** 38 / 10 ** 33));
        multipliers[3] = multiplierLookup((randomNumber % 10 ** 40 / 10 ** 38));
        cats[4] = (randomNumber % 10 ** 43 / 10 ** 40) % catsInPool;
        ratings[4] = ratingLookup((randomNumber % 10 ** 48 / 10 ** 43));
        multipliers[4] = multiplierLookup((randomNumber % 10 ** 50 / 10 ** 48));

        for (uint i = 0; i < 5; i++) {
            tokenIDs[i] = (((cats[i] + 1) * 10 ** 4) + (ratings[i] * 10)) + multipliers[i];
        }

        _mintBatch(buyer, tokenIDs, amounts);
    }
}

contract BuyEtherCatsFoundersSeries is VRFConsumerBase, EtherCatsFactory {

    address public contractOwner;
    address payable public receiverAccount;
    uint256 public price;
    bool public forSale;
    bool public permanentlyStop;
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 internal randomResult;

    mapping(bytes32 => address) buyerAddress;

    constructor()
    VRFConsumerBase(
        0xf0d54349aDdcf704F77AE15b96510dEA15cb7952, //VRF Coordinator
        0x514910771AF9Ca656af840dff83E8264EcF986CA //LINK Token
    ) public {
        keyHash = 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
        fee = 2 * 10 ** 18; //2 LINK
        contractOwner = msg.sender;
        receiverAccount = msg.sender;
        price = 0.15 * 10 ** 18;
        forSale = false;
        permanentlyStop = false;
    }

    modifier onlyOwner() {

        require(msg.sender == contractOwner);
        _;
    }
    function getRandomNumber() internal returns(bytes32 requestId) {

        uint256 userProvidedSeed = 0;
        require(LINK.balanceOf(address(this)) > fee, "Not enough LINK - fill contract with faucet");
        requestId = requestRandomness(keyHash, fee, userProvidedSeed);
        buyerAddress[requestId] = msg.sender;
        return requestId;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {

        require(msg.sender == 0xf0d54349aDdcf704F77AE15b96510dEA15cb7952, "Only the VRF Coordinator may call this function.");
        mintFiveCats(buyerAddress[requestId], randomness);

    }

    function mint() payable external {

        if (msg.value == price && forSale == true && permanentlyStop == false) {
            receiverAccount.transfer(msg.value);
            getRandomNumber();
        } else {
            revert();
        }
    }

    function changeSaleState() external onlyOwner {

        forSale = !forSale;
    }

    function permanentlyStopMinting() external onlyOwner {

        if (forSale == false) {
            permanentlyStop = true;
        } else {
            revert();
        }
    }

    function changePrice(uint256 newPrice) external onlyOwner {

        price = newPrice;
    }

    function changeReceivingAccount(address payable newReceivingAddress) external onlyOwner {

        receiverAccount = newReceivingAddress;
    }
    
    function burn(address account, uint256 id, uint256 amount) external {

        require(account == msg.sender, "You can only burn your own tokens.");
        _burn(account, id, amount);
    }
    
    function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) public {

        require(account == msg.sender, "You can only burn your own tokens.");
        _burnBatch(account, ids, amounts);
    }
    
    function setURI(string memory newuri) public onlyOwner {

        _uri = newuri;
    }

    function withdrawLink() public onlyOwner {

    LinkTokenInterface link = LinkTokenInterface(0x514910771AF9Ca656af840dff83E8264EcF986CA);
    require(link.transfer(receiverAccount, link.balanceOf(address(this))), "Unable to transfer");
    }
}