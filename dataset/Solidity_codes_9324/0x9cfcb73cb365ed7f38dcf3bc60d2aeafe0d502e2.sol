
pragma solidity ^0.8.0;


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

interface IMinerManage {


    function setOracleAddress(address _oracleAddress) external;

    function minerAdjustedStoragePowerInTiB(string memory minerId) external view returns(uint256);

    function whiteList(address walletAddress) external returns(bool);

    function minerInfoMap(address walletAddress) external returns(string memory);

    function getMinerList() external view returns(string[] memory);

    function getMinerId(address walletAddress) external view returns(string memory);

}

interface IMiningNFTManage {


    function getMinerIdByTokenId(uint256 _tokenId) external view returns(string memory);

    
}

interface IMiningNFT is IERC1155{


    function getInitialTokenId() external pure returns(uint256);

    function getCurrentTokenId() external view returns(uint256);


    function mint(address account, uint256 amount) external returns(uint256);


    function burn(address account,uint256 tokenId, uint256 amount) external ;

}

interface IFilChainStatOracle {

    function sectorInitialPledge() external view returns(uint256);

    function minerAdjustedPower(string memory _minerId) external view returns(uint256);

    function minerMiningEfficiency(string memory _minerId) external view returns(uint256);

    function minerSectorInitialPledge(string memory _minerId) external view returns(uint256);

    function minerTotalAdjustedPower() external view returns(uint256);

    function avgMiningEfficiency() external view returns(uint256);

    function latest24hBlockReward() external view returns(uint256);

    function rewardAttenuationFactor() external view returns(uint256);

    function networkStoragePower() external view returns(uint256);

    function dailyStoragePowerIncrease() external view returns(uint256);

    function removeMinerAdjustedPower(string memory _minerId) external;

    
}

interface IMiningNFTMintingLimitation {

    function getMinerMintLimitationInTiB(string memory _minerId) external view returns(uint256);

    function checkLimitation(string memory _minerId, uint256 _minerTotalMinted, uint256 _allMinersTotalMinted) external view returns(bool, string memory);

}

contract MiningNFTManage is Ownable{

    using SafeMath for uint256;

    struct TokenInfo{
        string minerId;
        uint256 supply;
        uint256 initialPledgePerTiB;
    }

    mapping(string=>uint256) public mintedAmount; // in TiB
    mapping(string=>uint256[]) minerMintedTokens;
    mapping(uint256=>TokenInfo) public tokenInfoMap;
    mapping(string=>uint256) public minerTotalPledgedAmount;

    uint256 public totalMintedInTiB;
    uint256 public totalSectorInitialPledge; // attoFil/TiB
    
    IMinerManage public minerManage;
    IMiningNFT public miningNFT;
    IFilChainStatOracle public filChainStatOracle;
    IMiningNFTMintingLimitation public miningNFTMintingLimitation;

    event Mint(address indexed account, uint256 indexed tokenId, uint256 amount);
    event Burn(address indexed account, uint256 indexed tokenId, uint256 amount);
    event RemoveToken(address indexed account, string indexed minerId, uint256 tokenId);
    event MiningNftMintingLimitationChanged(address limitation, address newLimitation);
    event MinerManageChanged(address minerManage, address newMinerManage);
    event FilChainStatOracleChanged(address filChainStatOracle, address newFilChainStatOracle);

    constructor(IMinerManage _minerManage, IMiningNFT _miningNFT, IFilChainStatOracle _filChainStatOracle, IMiningNFTMintingLimitation _miningNFTMintingLimitation){
        minerManage = _minerManage;
        miningNFT = _miningNFT;
        filChainStatOracle = _filChainStatOracle;
        miningNFTMintingLimitation = _miningNFTMintingLimitation;
    }
    
    function setMiningNFTMintingLimitation(IMiningNFTMintingLimitation _miningNFTMintingLimitation) public onlyOwner{

        require(address(_miningNFTMintingLimitation) != address(0), "address should not be 0");
        address origin = address(miningNFTMintingLimitation);
        miningNFTMintingLimitation = _miningNFTMintingLimitation;
        emit MiningNftMintingLimitationChanged(origin, address(_miningNFTMintingLimitation));
    }

    function setMinerManage(IMinerManage _minerManage) external onlyOwner{

        require(address(_minerManage) != address(0), "address should not be 0");
        address originMinerManage = address(minerManage);
        minerManage = _minerManage;
        emit MinerManageChanged(originMinerManage, address(_minerManage));
    }

    function setFilChainStatOracle(IFilChainStatOracle _filChainStatOracle) external onlyOwner{

        require(address(_filChainStatOracle) != address(0), "address should not be 0");
        emit FilChainStatOracleChanged(address(filChainStatOracle), address(_filChainStatOracle));
        filChainStatOracle = _filChainStatOracle;
    }

    function getMinerMintedTokensByWalletAddress(address _walletAddress) external view returns(uint256[] memory){

        string memory minerId = minerManage.getMinerId(_walletAddress);
        return minerMintedTokens[minerId];
    }

    function getMinerMintedTokens(string memory _minerId) external view returns(uint256[] memory){

        return minerMintedTokens[_minerId];
    }

    function getMinerIdByTokenId(uint256 _tokenId) external view returns(string memory){

        return tokenInfoMap[_tokenId].minerId;
    }

    function getLastMintedTokenId(string memory _minerId) external view returns(uint256){

        uint256[] memory mintedTokens = minerMintedTokens[_minerId];
        if(mintedTokens.length>0){
            return mintedTokens[mintedTokens.length - 1];
        }else{
            return 0;
        }
    }

    function mint(uint256 _amount) external {

        require(minerManage.whiteList(_msgSender()), "sender not in whitelist");

        string memory minerId = minerManage.getMinerId(_msgSender());
        uint256 minerMintedAmount = mintedAmount[minerId];

        (bool success, string memory message) = miningNFTMintingLimitation.checkLimitation(minerId, minerMintedAmount.add(_amount), totalMintedInTiB.add(_amount));
        require(success, message);

        mintedAmount[minerId] = minerMintedAmount.add(_amount);
        totalMintedInTiB = totalMintedInTiB.add(_amount);

        uint256 newTokenId = miningNFT.mint(_msgSender(), _amount);
        minerMintedTokens[minerId].push(newTokenId);

        uint256 sectorInitialPledge = filChainStatOracle.sectorInitialPledge();
        require(sectorInitialPledge > 0, "sectorInitialPledge should be >0");
        
        tokenInfoMap[newTokenId] = TokenInfo(minerId, _amount, sectorInitialPledge);
        uint256 pledgeAmount = sectorInitialPledge.mul(_amount);
        totalSectorInitialPledge = totalSectorInitialPledge.add(pledgeAmount);
        minerTotalPledgedAmount[minerId] = minerTotalPledgedAmount[minerId].add(pledgeAmount);

        emit Mint(_msgSender(), newTokenId, _amount);
    }

    function burn(uint256 _tokenId, uint256 _amount) external {

        address account = _msgSender();
        require(miningNFT.balanceOf(account, _tokenId)>=_amount, "burn amount exceed balance");
        
        string memory minerId = minerManage.getMinerId(_msgSender());
        mintedAmount[minerId] = mintedAmount[minerId].sub(_amount);
        totalMintedInTiB = totalMintedInTiB.sub(_amount);

        uint256 tokenSectorInitialPledge = tokenInfoMap[_tokenId].initialPledgePerTiB;
        uint256 pledgeAmount = tokenSectorInitialPledge.mul(_amount);
        totalSectorInitialPledge = totalSectorInitialPledge.sub(pledgeAmount);
        minerTotalPledgedAmount[minerId] = minerTotalPledgedAmount[minerId].sub(pledgeAmount);

        miningNFT.burn(account, _tokenId, _amount);
        removeMintedToken(_tokenId);
        emit Burn(account, _tokenId, _amount);
    }

    function removeMintedToken(uint256 _tokenId) internal{

        if(miningNFT.balanceOf(_msgSender(), _tokenId) == 0){
            string memory minerId = minerManage.getMinerId(_msgSender());
            uint256[] storage mintedTokens = minerMintedTokens[minerId];

            for(uint i=0; i<mintedTokens.length; i++){
                if(mintedTokens[i] == _tokenId){
                    mintedTokens[i] = mintedTokens[mintedTokens.length - 1];
                    mintedTokens.pop();
                    emit RemoveToken(_msgSender(), minerId, _tokenId);
                    break;
                }
            }
        }
    }

    function getAvgInitialPledge() public view returns(uint256){

        if(totalMintedInTiB==0) return 0;
        return totalSectorInitialPledge.div(totalMintedInTiB);
    }

    function getMinerTotalPledgeFilAmount(string memory _minerId) public view returns(uint256){

        return minerTotalPledgedAmount[_minerId];
    }
}