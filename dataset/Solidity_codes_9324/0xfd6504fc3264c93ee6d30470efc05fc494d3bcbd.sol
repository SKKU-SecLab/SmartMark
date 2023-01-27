


pragma solidity >=0.6.2 <0.8.0;

library ERC165Checker {

    bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    function supportsERC165(address account) internal view returns (bool) {

        return _supportsERC165Interface(account, _INTERFACE_ID_ERC165) &&
            !_supportsERC165Interface(account, _INTERFACE_ID_INVALID);
    }

    function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {

        return supportsERC165(account) &&
            _supportsERC165Interface(account, interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool[] memory) {

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

        (bool success, bool result) = _callERC165SupportsInterface(account, interfaceId);

        return (success && result);
    }

    function _callERC165SupportsInterface(address account, bytes4 interfaceId)
        private
        view
        returns (bool, bool)
    {

        bytes memory encodedParams = abi.encodeWithSelector(_INTERFACE_ID_ERC165, interfaceId);
        (bool success, bytes memory result) = account.staticcall{ gas: 30000 }(encodedParams);
        if (result.length < 32) return (false, false);
        return (success, abi.decode(result, (bool)));
    }
}


 
pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


 
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
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








contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using SafeMath for uint256;
    using Address for address;

    mapping (uint256 => mapping(address => uint256)) private _balances;

    mapping (address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    constructor (string memory uri_) public {
        _setURI(uri_);

        _registerInterface(_INTERFACE_ID_ERC1155);

        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    function uri(uint256) external view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

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
        override
    {

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
        override
    {

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

    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {

        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] = _balances[id][account].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

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
        internal
        virtual
    { }


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
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
        private
    {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
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

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}


 
pragma solidity >=0.6.0 <0.8.0;



abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() internal {
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }
}


pragma solidity >=0.5.0;

interface IGenFactory {

    event TicketCreated(address indexed caller, address indexed genTicket);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getGenTicket(address) external view returns (uint);

    function genTickets(uint) external view returns (address);

    function genTicketsLength() external view returns (uint);


    function createGenTicket(
        address _underlyingToken, 
        uint256[] memory _numTickets,
        uint256[] memory _ticketSizes,
        uint[] memory _totalTranches,
        uint[] memory _cliffTranches,
        uint[] memory _trancheLength,
        string memory _uri
    ) external returns (address);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}


 
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity 0.6.12;







contract GenTickets is ERC1155, ERC1155Receiver {

    using SafeMath for uint;

    struct GenTicket {
        uint256 numTickets;
        uint256 ticketSize;
        uint totalTranches;
        uint cliffTranches;
        uint trancheLength;
    }

    address public underlyingToken;
    mapping(uint256 => GenTicket) public genTickets;
    uint public numTicketTypes;
    IGenFactory public factory;
    address public issuer;
    bool public active = false;
    uint256 public balanceNeeded = 0;
    uint public TGE = type(uint).max;

    bytes private constant VALIDATOR = bytes('JC');
    constructor (
        address _underlyingToken,
        uint256[] memory _numTickets,
        uint256[] memory _ticketSizes,
        uint[] memory _totalTranches,
        uint[] memory _cliffTranches,
        uint[] memory _trancheLength,
        string memory _uri,
        IGenFactory _factory,
        address _issuer
    ) 
        public 
        ERC1155(_uri)
    {
        underlyingToken = _underlyingToken;
        factory = _factory;
        issuer = _issuer;

         for (uint i = 0; i < 50; i++){
            if (_numTickets.length == i){
                numTicketTypes = i;
                break;
            }
            
            balanceNeeded += _numTickets[i].mul(_ticketSizes[i]);
            genTickets[i] = GenTicket(_numTickets[i], _ticketSizes[i], _totalTranches[i], _cliffTranches[i], _trancheLength[i]);
        }
    }

    function owner() public view virtual returns (address) {

        return issuer;
    }

    function updateTGE(uint timestamp) external {

        require(msg.sender == issuer, "GenTickets: Only issuer can update TGE");
        require(getBlockTimestamp() < TGE, "GenTickets: TGE already occurred");
        require(getBlockTimestamp() < timestamp, "GenTickets: New TGE must be in the future");

        TGE = timestamp;
    }

    function issue(address _to) external {

        require(msg.sender == issuer, "GenTickets: Only issuer can issue the tokens");
        require(!active, "GenTickets: Token is already active");
        IERC20(underlyingToken).transferFrom(msg.sender, address(this), balanceNeeded);

        address feeTo = factory.feeTo();
        bytes memory data;
        for (uint i = 0; i < 50; i++){
            if (numTicketTypes == i){
                break;
            }

            GenTicket memory ticketType = genTickets[i];
            
            uint256 feeAmount = 0;
            if (feeTo != address(0)) {
                feeAmount = ticketType.numTickets.div(100);
                if (feeAmount == 0) {
                    feeAmount = 1;
                }
                _mint(feeTo, i, feeAmount, data);
            }

            _mint(_to, i, ticketType.numTickets - feeAmount, data);
        }

        active = true;
    }

    function redeemTicket(address _to, uint _id, uint _amount) public {

        uint tier = _id.mod(numTicketTypes);
        GenTicket memory ticketType = genTickets[tier];

        require(getBlockTimestamp() > (ticketType.trancheLength).mul(ticketType.cliffTranches).add(TGE), "GenTickets: Ticket is still within cliff period");
        uint tranche = _id.div(numTicketTypes);
        uint actualTranche;
        if (tranche <= ticketType.cliffTranches){
            actualTranche = 0;
        } else{
            actualTranche = tranche.sub(ticketType.cliffTranches);
        }
        
        require(getBlockTimestamp() > ticketType.trancheLength.mul(ticketType.cliffTranches).add(ticketType.trancheLength.mul(actualTranche)).add(TGE), "GenTickets: Tokens for this ticket are being vested");
        require(tranche < ticketType.totalTranches, "GenTickets: Ticket has redeemed all tokens");
        
        uint eligibleTraches =0;
        if (ticketType.trancheLength >= 1){
            eligibleTraches = (getBlockTimestamp().sub((ticketType.trancheLength).mul(ticketType.cliffTranches).add(TGE))).div(ticketType.trancheLength); //3.58//3
            if (eligibleTraches <= 0 && ticketType.cliffTranches == 0 ) {
                eligibleTraches = 1;
            }else if (eligibleTraches.add(ticketType.cliffTranches) >= ticketType.totalTranches) {
                eligibleTraches = (ticketType.totalTranches.sub(ticketType.cliffTranches));
                } else {
                    if (eligibleTraches < 0 && ticketType.cliffTranches > 0) {
                        eligibleTraches = 0;
                    } else {
                    eligibleTraches += 1;
                    }
                }
        }else {
            eligibleTraches = 1;
        }
        uint availableToClaim = (ticketType.ticketSize).div((ticketType.totalTranches).sub(ticketType.cliffTranches));
        uint averageTokensAvailableToClaim = availableToClaim.mul(_amount);
        
        uint redeemedTokens;
        if (actualTranche >= 1){
            redeemedTokens  = averageTokensAvailableToClaim.mul(actualTranche);
        } else{
            redeemedTokens =0;
        }

        uint tokens;
        if (eligibleTraches.mul(averageTokensAvailableToClaim) > redeemedTokens){
            tokens = eligibleTraches.mul(averageTokensAvailableToClaim).sub(redeemedTokens);
        } else {
            tokens =0;
        }

        safeTransferFrom(address(msg.sender), address(this), _id, _amount, VALIDATOR);

        IERC20(underlyingToken).transfer(_to, tokens);
        bytes memory data;
        _mint(_to, _id.add(numTicketTypes.mul((eligibleTraches.add(ticketType.cliffTranches)).sub(tranche))), _amount, data);
    }

    function getBlockTimestamp() internal view returns (uint) {

        return block.timestamp;
    }

    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data) override external returns(bytes4) {

        if(keccak256(_data) == keccak256(VALIDATOR)){
            return 0xf23a6e61;
        }
    }

    function onERC1155BatchReceived(address _operator, address _from, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) override external returns(bytes4) {

        if(keccak256(_data) == keccak256(VALIDATOR)){
            return 0xbc197c81;
        }
    }
}


pragma solidity 0.6.12;





contract GenFactory is IGenFactory {

    using SafeMath for uint;
    
    address public override feeTo;
    
    address public override feeToSetter;
    
    address[] public override genTickets;
    
    mapping(address => uint) public override getGenTicket;
    
    event TicketCreated(address indexed caller, address indexed genTicket);
    
    function genTicketsLength() external override view returns (uint) {

        return genTickets.length;
    }
    
    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function createGenTicket(
        address _underlyingToken, 
        uint256[] memory _numTickets,
        uint256[] memory _ticketSizes,
        uint[] memory _totalTranches,
        uint[] memory _cliffTranches,
        uint[] memory _trancheLength,
        string memory _uri
    ) external override returns (address) {

        require(_numTickets.length < 10, 'GenFactory: MAX NUMBER OF TICKETS');
        require(_numTickets.length == _ticketSizes.length && 
        _ticketSizes.length == _totalTranches.length &&
        _totalTranches.length == _cliffTranches.length &&
        _cliffTranches.length == _trancheLength.length, 'GenFactory: ARRAY SIZE MISMATCH');

        uint numTicketTypes;
        uint balanceNeeded;
        for (uint i = 0; i < 50; i++) {
            if (_numTickets.length == i){
                numTicketTypes = i;
                break;
            }
            balanceNeeded += _numTickets[i].mul(_ticketSizes[i]);
        }
        require(IERC20(_underlyingToken).balanceOf(msg.sender) >= balanceNeeded, "GenFactory: The underlying tokens attempted to lock is more than the balance");

        GenTickets gt = new GenTickets(_underlyingToken, _numTickets, _ticketSizes, _totalTranches, _cliffTranches, _trancheLength, _uri, this, msg.sender);
        getGenTicket[address(gt)] = genTickets.length;
        genTickets.push(address(gt));
        emit TicketCreated(msg.sender, address(gt));
        
        return address(gt);
    }
    
    function setFeeTo(address _feeTo) external override {

        require(msg.sender == feeToSetter, 'GenFactory: FORBIDDEN');
        feeTo = _feeTo;
    }
    
    function setFeeToSetter(address _feeToSetter) external override {

        require(msg.sender == feeToSetter, 'GenFactory: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}