
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


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

}


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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
}


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

interface IFILST is IERC20{

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;

}

interface IFILSTPool {

    function accrue(string memory miner) external;

}

interface IMiningNFT is IERC1155{


    function getInitialTokenId() external pure returns(uint256);

    function getCurrentTokenId() external view returns(uint256);


    function mint(address account, uint256 amount) external returns(uint256);


    function burn(address account,uint256 tokenId, uint256 amount) external ;

}

interface IMiningNFTManage {


    function getMinerIdByTokenId(uint256 _tokenId) external view returns(string memory);

    
}


library StringUtil {

    
    function equal(string memory a, string memory b) internal pure returns(bool){

        return equal(bytes(a),bytes(b));
    }

    function equal(bytes memory a, bytes memory b) internal pure returns(bool){

        return keccak256(a) == keccak256(b);
    }
    
    function notEmpty(string memory a) internal pure returns(bool){

        return bytes(a).length > 0;
    }

}

interface IPriceConverter {

    function convertFromFilstToDFLAmount(uint _filstAmount) external view returns(uint);

}

contract FILSTManage is Ownable,IERC1155Receiver,ERC165,ReentrancyGuard{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using StringUtil for string;

    uint256 public mintFeeRatio = 50; // default: 50/1000=5%
    uint256 public constant MINT_FEE_DENOMINATOR = 1000;
    uint256 constant FILST_DECIMALS = 1e18;
    uint256 constant MNFT_TO_FILST_RATIO = 1024; // 1 FILST token represents 1 GiB storage power
    bytes constant MINT = bytes("MINT");

    IFILST public filst;
    IMiningNFTManage public miningNFTManage;
    IMiningNFT public miningNFT;
    IFILSTPool public filstPool;
    IERC20 public dfl;
    IPriceConverter public priceConverter;

    IERC20 public usdtToken;
    uint256 public cumulatedFee;
    
    uint256 public totalStakedMiningNftAmount;
    mapping(string=>uint256) public minerStakedMiningNftAmount;

    mapping(string=>uint256) public minerMintedFilstAmount;
    string[] public mintedMinerList;

    event Minted(address indexed sender, address indexed recipient, uint256 indexed tokenId, uint256 filstAmount);
    event Burned(address indexed account, uint256 tokenId, uint256 filstAmount);
    event MiningNFTManageChanged(address originalMiningNFTManage, address newMiningNFTManage);
    event FilstPoolChanged(address originalFilstPool, address newFilstPool);
    event MintFeeRatioChanged(uint256 originalFeeRatio, uint256 newFeeRatio);
    event PriceConverterChanged(address originalConverter, address newConverter);
    event Transfer(address from, address to, uint256 value);

    constructor(IMiningNFTManage _miningNFTManage,IMiningNFT _miningNFT, IFILST _filst, IERC20 _dfl, IERC20 _usdtToken, IPriceConverter _priceConverter){
        miningNFTManage = _miningNFTManage;
        filst = _filst;
        miningNFT = _miningNFT;
        dfl = _dfl;
        usdtToken = _usdtToken;
        priceConverter = _priceConverter;
    }

    function setPriceConverter(IPriceConverter _priceConverter) public onlyOwner{

        require(address(_priceConverter) != address(0), "address should not be 0");
        address original = address(priceConverter);
        priceConverter = _priceConverter;
        emit PriceConverterChanged(original, address(_priceConverter));
    }    

    function setMiningNFTManage(IMiningNFTManage _miningNFTManage) public onlyOwner{

        require(address(_miningNFTManage) != address(0), "address should not be 0");
        address original = address(miningNFTManage);
        miningNFTManage = _miningNFTManage;
        emit MiningNFTManageChanged(original, address(_miningNFTManage));
    }

    function setFilstPool(IFILSTPool _filstPool) public onlyOwner{

        require(address(_filstPool) != address(0), "address should not be 0");
        address original = address(filstPool);
        filstPool = _filstPool;
        emit FilstPoolChanged(original, address(_filstPool));
    }

    function setMintFeeRatio(uint256 _mintFeeRatio) public onlyOwner{

        require(_mintFeeRatio>0, "value should be >0");
        uint256 originalFeeRatio = mintFeeRatio;
        mintFeeRatio = _mintFeeRatio;
        emit MintFeeRatioChanged(originalFeeRatio, _mintFeeRatio);
    }

    function getMintedMinerList() external view returns(string[] memory){

        return mintedMinerList;
    }

    function getTotalMintedAmount() external view returns (uint) {

        return filst.totalSupply();
    }

    function getMintedAmount(string memory _minerId) public view returns(uint256){

        uint256 amount = minerMintedFilstAmount[_minerId];
        return amount;
    }

    function mint(address _recipient, uint256 _tokenId, uint256 _nftAmount) external nonReentrant{


        uint256 nftBalance = miningNFT.balanceOf(_msgSender(), _tokenId);
        require(nftBalance >= _nftAmount, "exceed mining NFT balance");
        
        uint256 filstAmountToMint = _nftAmount.mul(MNFT_TO_FILST_RATIO).mul(FILST_DECIMALS);

        uint256 mintFee = getMintFee(filstAmountToMint);
        require(mintFee > 0, "invalid fee amount");

        uint256 dflBalance = dfl.balanceOf(_msgSender());
        require(mintFee <= dflBalance, "DFL: insufficient mint fee");

        cumulatedFee = cumulatedFee.add(mintFee);
        dfl.safeTransferFrom(_msgSender(), address(this), mintFee);

        miningNFT.safeTransferFrom(_msgSender(), address(this), _tokenId, _nftAmount, MINT);
        
        string memory minerId = miningNFTManage.getMinerIdByTokenId(_tokenId);
        require(minerId.notEmpty(), "miner id not found");
        filstPool.accrue(minerId);

        if(minerMintedFilstAmount[minerId] == 0){
            mintedMinerList.push(minerId);
        }
        minerMintedFilstAmount[minerId] = minerMintedFilstAmount[minerId].add(filstAmountToMint);
        addStakedMiningNFTAmount(minerId, _nftAmount);
        
        filst.mint(_recipient, filstAmountToMint);
        
        emit Minted(_msgSender(), _recipient, _tokenId, filstAmountToMint);
    }

    function getMintFee(uint256 _filstAmount) public view returns(uint256){

        uint256 feeBase = _filstAmount.mul(mintFeeRatio).div(MINT_FEE_DENOMINATOR);
        uint256 mintFee = priceConverter.convertFromFilstToDFLAmount(feeBase);
        return mintFee;
    }

    function burn(string memory _minerId, uint256 _tokenId, uint256 _amount) external {

        require(_minerId.notEmpty(), "minerId should not be empty");
        require(_tokenId>0, "tokenId should not be 0");
        require(miningNFTManage.getMinerIdByTokenId(_tokenId).equal(_minerId), "minerId and mining NFT tokenId not matched");
        
        address account = _msgSender();
        require(filst.balanceOf(account) >= _amount, "burn amount exceed account balance");
        require(minerMintedFilstAmount[_minerId] >= _amount, "burn amount exceed miner minted amount");

        filstPool.accrue(_minerId);

        minerMintedFilstAmount[_minerId] = minerMintedFilstAmount[_minerId].sub(_amount);

        removeMintedMinerIdFromList(_minerId);

        filst.burn(account, _amount);
        
        emit Burned(account, _tokenId, _amount);
    }

    function getFilstMintedAmountByNftTokenId(uint256 _tokenId) public view returns(uint256){

        return miningNFT.balanceOf(address(this), _tokenId).mul(MNFT_TO_FILST_RATIO).mul(10**IERC20Metadata(address(filst)).decimals());
    }

    function getFilstMintedAmountByNftTokenIdBatch(uint256[] calldata _tokenIds) public view returns(uint256[] memory){

        uint256[] memory amountList = new uint256[](_tokenIds.length);
        for(uint i=0; i<_tokenIds.length; i++){
            amountList[i] = getFilstMintedAmountByNftTokenId(_tokenIds[i]);
        }
        return amountList;
    }

    function removeMintedMinerIdFromList(string memory _minerId) internal{

        if(minerMintedFilstAmount[_minerId] == 0){
            for(uint i=0; i<mintedMinerList.length; i++){
                if(mintedMinerList[i].equal(_minerId)){
                    mintedMinerList[i] = mintedMinerList[mintedMinerList.length - 1];
                    mintedMinerList.pop();
                    return;
                }
            }
        }
    }

    function addStakedMiningNFTAmount(string memory minerId, uint256 _nftAmount) internal {

        minerStakedMiningNftAmount[minerId] = minerStakedMiningNftAmount[minerId].add(_nftAmount);
        totalStakedMiningNftAmount = totalStakedMiningNftAmount.add(_nftAmount);
    }

    function transfer(address _to, uint256 _value) public onlyOwner{

        dfl.safeTransfer(_to, _value);
        emit Transfer(address(this), _to, _value);
    }

    function onERC1155Received(address operator,address from,uint256 id,uint256 value,bytes calldata data) external override returns(bytes4){

        if(StringUtil.equal(MINT, data)){
            return this.onERC1155Received.selector;
        }else{
            return bytes4(0);
        }
    }

    function onERC1155BatchReceived(address operator,address from,uint256[] calldata ids,uint256[] calldata values,bytes calldata data) external override returns(bytes4){

        if(StringUtil.equal(MINT, data)){
            return this.onERC1155BatchReceived.selector;
        }else{
            return bytes4(0);
        }
    }

}