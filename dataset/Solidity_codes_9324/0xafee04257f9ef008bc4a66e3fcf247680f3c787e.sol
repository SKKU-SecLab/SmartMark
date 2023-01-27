pragma solidity ^0.4.23;

interface IERC20Withdraw {

    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);

}
pragma solidity ^0.4.23;

interface IERC721Withdraw {

    function setApprovalForAll(address operator, bool _approved) external;

}
pragma solidity ^0.4.23;


contract CutieAccessControl {


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address ownerAddress;

    address pendingOwnerAddress;

    mapping (address => bool) operatorAddress;

    modifier onlyOwner() {

        require(msg.sender == ownerAddress, "Access denied");
        _;
    }

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwnerAddress, "Access denied");
        _;
    }

    modifier onlyOperator() {

        require(operatorAddress[msg.sender] || msg.sender == ownerAddress, "Access denied");
        _;
    }

    constructor () internal {
        ownerAddress = msg.sender;
    }

    function getOwner() external view returns (address) {

        return ownerAddress;
    }

    function setOwner(address _newOwner) external onlyOwner {

        require(_newOwner != address(0));
        pendingOwnerAddress = _newOwner;
    }

    function getPendingOwner() external view returns (address) {

        return pendingOwnerAddress;
    }

    function claimOwnership() external onlyPendingOwner {

        emit OwnershipTransferred(ownerAddress, pendingOwnerAddress);
        ownerAddress = pendingOwnerAddress;
        pendingOwnerAddress = address(0);
    }

    function isOperator(address _addr) public view returns (bool) {

        return operatorAddress[_addr];
    }

    function setOperator(address _newOperator) public onlyOwner {

        require(_newOperator != address(0));
        operatorAddress[_newOperator] = true;
    }

    function removeOperator(address _operator) public onlyOwner {

        delete(operatorAddress[_operator]);
    }

    function withdraw(address _receiver) external onlyOwner {

        if (address(this).balance > 0) {
            _receiver.transfer(address(this).balance);
        }
    }

    function withdrawERC20(IERC20Withdraw _tokenContract) external onlyOwner {

        uint256 balance = _tokenContract.balanceOf(address(this));
        if (balance > 0) {
            _tokenContract.transfer(msg.sender, balance);
        }
    }

    function approveERC721(IERC721Withdraw _tokenContract) external onlyOwner {

        _tokenContract.setApprovalForAll(msg.sender, true);
    }

}
pragma solidity ^0.4.23;


contract CutiePausable is CutieAccessControl {

  event Pause();
  event Unpause();

  bool public paused = false;


  modifier whenNotPaused() {

    require(!paused);
    _;
  }

  modifier whenPaused() {

    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {

    paused = true;
    emit Pause();
  }

  function unpause() onlyOwner whenPaused public {

    paused = false;
    emit Unpause();
  }
}
pragma solidity ^0.4.23;


contract CutieERC721Metadata is CutiePausable /* is IERC721Metadata */ {

    string public metadataUrlPrefix = "https://blockchaincuties.com/cutie/";
    string public metadataUrlSuffix = ".svg";

    function name() external pure returns (string) {

        return "BlockchainCuties";
    }

    function symbol() external pure returns (string) {

        return "CUTIE";
    }

    function tokenURI(uint256 _tokenId) external view returns (string infoUrl) {

        return
        concat(toSlice(metadataUrlPrefix),
            toSlice(concat(toSlice(uintToString(_tokenId)), toSlice(metadataUrlSuffix))));
    }

    function setMetadataUrl(string _metadataUrlPrefix, string _metadataUrlSuffix) public onlyOwner {

        metadataUrlPrefix = _metadataUrlPrefix;
        metadataUrlSuffix = _metadataUrlSuffix;
    }


    struct slice {
        uint _len;
        uint _ptr;
    }

    function toSlice(string self) internal pure returns (slice) {

        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    function memcpy(uint dest, uint src, uint len) private pure {

        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function concat(slice self, slice other) internal pure returns (string) {

        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }


    function uintToString(uint256 a) internal pure returns (string result) {

        string memory r = "";
        do {
            uint b = a % 10;
            a /= 10;

            string memory c = "";

            if (b == 0) c = "0";
            else if (b == 1) c = "1";
            else if (b == 2) c = "2";
            else if (b == 3) c = "3";
            else if (b == 4) c = "4";
            else if (b == 5) c = "5";
            else if (b == 6) c = "6";
            else if (b == 7) c = "7";
            else if (b == 8) c = "8";
            else if (b == 9) c = "9";

            r = concat(toSlice(c), toSlice(r));
        } while (a > 0);
        result = r;
    }
}
pragma solidity ^0.4.23;

interface ERC721TokenReceiver {

    function onERC721Received(address _from, uint256 _tokenId, bytes data) external returns(bytes4);

}
pragma solidity ^0.4.23;


interface TokenRecipientInterface {

    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;

}
pragma solidity ^0.4.23;


contract BlockchainCutiesToken is CutieERC721Metadata {


    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    struct Cutie {
        uint256 genes;

        uint40 birthTime;

        uint40 cooldownEndTime;

        uint40 momId;
        uint40 dadId;

        uint16 cooldownIndex;

        uint16 generation;

        uint64 optional;
    }

    bytes4 internal constant INTERFACE_SIGNATURE_ERC721Metadata =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('tokenURI(uint256)'));

    bytes4 internal constant INTERFACE_SIGNATURE_ERC721Enumerable =
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('tokenByIndex(uint256)')) ^
        bytes4(keccak256('tokenOfOwnerByIndex(address, uint256)'));

    mapping (uint40 => Cutie) public cuties;

    uint256 total;

    address public gameAddress;

    mapping (uint40 => address) public cutieIndexToOwner;

    mapping (address => uint256) ownershipTokenCount;

    mapping (uint40 => address) public cutieIndexToApproved;

    mapping (address => mapping (address => bool)) public addressToApprovedAll;

    modifier canBeStoredIn40Bits(uint256 _value) {

        require(_value <= 0xFFFFFFFFFF, "Value can't be stored in 40 bits");
        _;
    }

    modifier onlyGame {

        require(msg.sender == gameAddress || msg.sender == ownerAddress, "Access denied");
        _;
    }

    constructor() public {
        paused = true;
    }

    function() external payable {}

    function setup(uint256 _total) external onlyGame whenPaused {

        require(total == 0, "Contract already initialized");
        total = _total;
        paused = false;
    }

    function setGame(address _gameAddress) external onlyOwner {

        gameAddress = _gameAddress;
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {

        return
        interfaceID == 0x6466353c ||
        interfaceID == 0x80ac58cd || // ERC721
        interfaceID == INTERFACE_SIGNATURE_ERC721Metadata ||
        interfaceID == INTERFACE_SIGNATURE_ERC721Enumerable ||
        interfaceID == bytes4(keccak256('supportsInterface(bytes4)'));
    }

    function totalSupply() public view returns (uint256) {

        return total;
    }

    function balanceOf(address _owner) external view returns (uint256) {

        require(_owner != 0x0, "Owner can't be zero address");
        return ownershipTokenCount[_owner];
    }

    function ownerOf(uint256 _cutieId) external view canBeStoredIn40Bits(_cutieId) returns (address owner) {

        owner = cutieIndexToOwner[uint40(_cutieId)];
        require(owner != address(0), "Owner query for nonexistent token");
    }

    function ownerOfCutie(uint256 _cutieId) external view canBeStoredIn40Bits(_cutieId) returns (address) {

        return cutieIndexToOwner[uint40(_cutieId)];
    }

    function tokenByIndex(uint256 _index) external view returns (uint256) {

        require(_index < total);
        return _index - 1;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 cutieId) {

        require(_owner != 0x0, "Owner can't be 0x0");
        uint40 count = 0;
        for (uint40 i = 1; i <= totalSupply(); ++i) {
            if (_isOwner(_owner, i)) {
                if (count == _index) {
                    return i;
                } else {
                    count++;
                }
            }
        }
        revert();
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public whenNotPaused canBeStoredIn40Bits(_tokenId) {

        transferFrom(_from, _to, uint40(_tokenId));

        if (_isContract(_to)) {
            ERC721TokenReceiver(_to).onERC721Received(_from, _tokenId, data);
        }
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external whenNotPaused {

        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public whenNotPaused canBeStoredIn40Bits(_tokenId) {

        require(_to != address(0), "Wrong cutie destination");
        require(_to != address(this), "Wrong cutie destination");

        require(_isApprovedOrOwner(msg.sender, uint40(_tokenId)), "Caller is not owner nor approved");
        require(_isOwner(_from, uint40(_tokenId)), "Wrong cutie owner");

        _transfer(_from, _to, uint40(_tokenId));
    }

    function transfer(address _to, uint256 _cutieId) public whenNotPaused canBeStoredIn40Bits(_cutieId) {

        require(_to != address(0), "Wrong cutie destination");

        require(_isOwner(msg.sender, uint40(_cutieId)), "Caller is not a cutie owner");

        _transfer(msg.sender, _to, uint40(_cutieId));
    }

    function transferBulk(address[] to, uint[] tokens) public whenNotPaused {

        require(to.length == tokens.length);
        for (uint i = 0; i < to.length; i++) {
            transfer(to[i], tokens[i]);
        }
    }

    function transferMany(address to, uint[] tokens) public whenNotPaused {

        for (uint i = 0; i < tokens.length; i++) {
            transfer(to, tokens[i]);
        }
    }

    function approve(address _to, uint256 _cutieId) public whenNotPaused canBeStoredIn40Bits(_cutieId) {

        require(_isOwner(msg.sender, uint40(_cutieId)), "Caller is not a cutie owner");
        require(msg.sender != _to, "Approval to current owner");

        _approve(uint40(_cutieId), _to);

        emit Approval(msg.sender, _to, _cutieId);
    }

    function delegatedApprove(address _from, address _to, uint40 _cutieId) external whenNotPaused onlyGame {

        require(_isOwner(_from, _cutieId), "Wrong cutie owner");
        _approve(_cutieId, _to);
    }

    function approveAndCall(address _spender, uint _tokenId, bytes data) external whenNotPaused returns (bool) {

        approve(_spender, _tokenId);
        TokenRecipientInterface(_spender).receiveApproval(msg.sender, _tokenId, this, data);
        return true;
    }

    function setApprovalForAll(address _operator, bool _approved) external {

        require(_operator != msg.sender, "Approve to caller");

        if (_approved) {
            addressToApprovedAll[msg.sender][_operator] = true;
        } else {
            delete addressToApprovedAll[msg.sender][_operator];
        }
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view canBeStoredIn40Bits(_tokenId) returns (address) {

        require(_tokenId <= total, "Cutie not exists");
        return cutieIndexToApproved[uint40(_tokenId)];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {

        return addressToApprovedAll[_owner][_operator];
    }

    function _isApprovedOrOwner(address spender, uint40 cutieId) internal view returns (bool) {

        require(_exists(cutieId), "Cutie not exists");
        address owner = cutieIndexToOwner[cutieId];
        return (spender == owner || _approvedFor(spender, cutieId) || isApprovedForAll(owner, spender));
    }

    function _isOwner(address _claimant, uint40 _cutieId) internal view returns (bool) {

        return cutieIndexToOwner[_cutieId] == _claimant;
    }

    function _exists(uint40 _cutieId) internal view returns (bool) {

        return cutieIndexToOwner[_cutieId] != address(0);
    }

    function _approve(uint40 _cutieId, address _approved) internal {

        cutieIndexToApproved[_cutieId] = _approved;
    }

    function _approvedFor(address _claimant, uint40 _cutieId) internal view returns (bool) {

        return cutieIndexToApproved[_cutieId] == _claimant;
    }

    function _transfer(address _from, address _to, uint40 _cutieId) internal {


        ownershipTokenCount[_to]++;
        cutieIndexToOwner[_cutieId] = _to;
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            delete cutieIndexToApproved[_cutieId];
        }
        emit Transfer(_from, _to, _cutieId);
    }

    function _isContract(address _account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(_account) }
        return size > 0;
    }

    function restoreCutieToAddress(uint40 _cutieId, address _recipient) external whenNotPaused onlyOperator {

        require(_isOwner(this, _cutieId));
        _transfer(this, _recipient, _cutieId);
    }

    function createCutie(
        address _owner,
        uint40 _momId,
        uint40 _dadId,
        uint16 _generation,
        uint16 _cooldownIndex,
        uint256 _genes,
        uint40 _birthTime
    ) external whenNotPaused onlyGame returns (uint40) {

        Cutie memory _cutie = Cutie({
            genes : _genes,
            birthTime : _birthTime,
            cooldownEndTime : 0,
            momId : _momId,
            dadId : _dadId,
            cooldownIndex : _cooldownIndex,
            generation : _generation,
            optional : 0
        });

        total++;
        uint256 newCutieId256 = total;

        require(newCutieId256 <= 0xFFFFFFFFFF);

        uint40 newCutieId = uint40(newCutieId256);
        cuties[newCutieId] = _cutie;

        _transfer(0, _owner, newCutieId);

        return newCutieId;
    }

    function restoreCutie(
        address owner,
        uint40 id,
        uint256 _genes,
        uint40 _momId,
        uint40 _dadId,
        uint16 _generation,
        uint40 _cooldownEndTime,
        uint16 _cooldownIndex,
        uint40 _birthTime
    ) external whenNotPaused onlyGame {

        require(owner != address(0), "Restore to zero address");
        require(total >= id, "Cutie restore is not allowed");
        require(cuties[id].birthTime == 0, "Cutie overwrite is forbidden");

        Cutie memory cutie = Cutie({
            genes: _genes,
            momId: _momId,
            dadId: _dadId,
            generation: _generation,
            cooldownEndTime: _cooldownEndTime,
            cooldownIndex: _cooldownIndex,
            birthTime: _birthTime,
            optional: 0
        });

        cuties[id] = cutie;
        cutieIndexToOwner[id] = owner;
        ownershipTokenCount[owner]++;
    }

    function getCutie(uint40 _id) external view returns (
        uint256 genes,
        uint40 birthTime,
        uint40 cooldownEndTime,
        uint40 momId,
        uint40 dadId,
        uint16 cooldownIndex,
        uint16 generation
    ) {

        require(_exists(_id), "Cutie not exists");

        Cutie storage cutie = cuties[_id];

        genes = cutie.genes;
        birthTime = cutie.birthTime;
        cooldownEndTime = cutie.cooldownEndTime;
        momId = cutie.momId;
        dadId = cutie.dadId;
        cooldownIndex = cutie.cooldownIndex;
        generation = cutie.generation;
    }

    function getGenes(uint40 _id) external view returns (uint256) {

        return cuties[_id].genes;
    }

    function setGenes(uint40 _id, uint256 _genes) external whenNotPaused onlyGame {

        cuties[_id].genes = _genes;
    }

    function getCooldownEndTime(uint40 _id) external view returns (uint40) {

        return cuties[_id].cooldownEndTime;
    }

    function setCooldownEndTime(uint40 _id, uint40 _cooldownEndTime) external whenNotPaused onlyGame {

        cuties[_id].cooldownEndTime = _cooldownEndTime;
    }

    function getCooldownIndex(uint40 _id) external view returns (uint16) {

        return cuties[_id].cooldownIndex;
    }

    function setCooldownIndex(uint40 _id, uint16 _cooldownIndex) external whenNotPaused onlyGame {

        cuties[_id].cooldownIndex = _cooldownIndex;
    }

    function getGeneration(uint40 _id) external view returns (uint16) {

        return cuties[_id].generation;
    }

    function setGeneration(uint40 _id, uint16 _generation) external whenNotPaused onlyGame {

        cuties[_id].generation = _generation;
    }

    function getOptional(uint40 _id) external view returns (uint64) {

        return cuties[_id].optional;
    }

    function setOptional(uint40 _id, uint64 _optional) external whenNotPaused onlyGame {

        cuties[_id].optional = _optional;
    }
}
