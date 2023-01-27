pragma solidity ^0.8.0;


interface ICryptoFoxesOrigins {

    function getStackingToken(uint256 tokenId) external view returns(uint256);

    function _currentTime(uint256 _currentTimestamp) external view returns(uint256);

}// MIT
pragma solidity ^0.8.0;


interface ICryptoFoxesStakingStruct {


    struct Staking {
        uint8 slotIndex;
        uint16 tokenId;
        uint16 origin;
        uint64 timestampV2;
        address owner;
    }

    struct Origin{
        uint8 maxSlots;
        uint16[] stacked;
    }

}// MIT
pragma solidity ^0.8.0;


interface ICryptoFoxesStakingV2 is ICryptoFoxesStakingStruct  {

    function getFoxesV2(uint16 _tokenId) external view returns(Staking memory);

    function getOriginMaxSlot(uint16 _tokenIdOrigin) external view returns(uint8);

    function getStakingTokenV2(uint16 _tokenId) external view returns(uint256);

    function getV2ByOrigin(uint16 _tokenIdOrigin) external view returns(Staking[] memory);

    function getOriginByV2(uint16 _tokenId) external view returns(uint16);

    function unlockSlot(uint16 _tokenId, uint8 _count) external;

    function _currentTime(uint256 _currentTimestamp) external view returns(uint256);

}// MIT
pragma solidity ^0.8.0;


interface ICryptoFoxesCalculationOrigin {

    function calculationRewards(address _contract, uint256[] calldata _tokenIds, uint256 _currentTimestamp) external view returns(uint256);

    function claimRewards(address _contract, uint256[] calldata _tokenIds, address _owner) external;

}// MIT
pragma solidity ^0.8.0;


interface ICryptoFoxesCalculationV2 {

    function calculationRewardsV2(address _contract, uint16[] calldata _tokenIds, uint256 _currentTimestamp) external view returns(uint256);

    function claimRewardsV2(address _contract, uint16[] calldata _tokenIds, address _owner) external;

    function claimMoveRewardsOrigin(address _contract, uint16 _tokenId, address _ownerOrigin) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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
}// MIT

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
}// MIT
pragma solidity ^0.8.0;


interface ICryptoFoxesSteak {

    function addRewards(address _to, uint256 _amount) external;

    function withdrawRewards(address _to) external;

    function isPaused() external view returns(bool);

    function dateEndRewards() external view returns(uint256);

}// MIT
pragma solidity ^0.8.0;



abstract contract CryptoFoxesAllowed is Ownable {

    mapping (address => bool) public allowedContracts;

    modifier isFoxContract() {
        require(allowedContracts[_msgSender()] == true, "Not allowed");
        _;
    }
    
    modifier isFoxContractOrOwner() {
        require(allowedContracts[_msgSender()] == true || _msgSender() == owner(), "Not allowed");
        _;
    }

    function setAllowedContract(address _contract, bool _allowed) public onlyOwner {
        allowedContracts[_contract] = _allowed;
    }

}// MIT
pragma solidity ^0.8.0;



abstract contract CryptoFoxesUtility is Ownable,CryptoFoxesAllowed, ICryptoFoxesSteak {
    using SafeMath for uint256;

    uint256 public endRewards = 0;
    ICryptoFoxesSteak public cryptofoxesSteak;
    bool public disablePublicFunctions = false;

    function setCryptoFoxesSteak(address _contract) public onlyOwner {
        cryptofoxesSteak = ICryptoFoxesSteak(_contract);
        setAllowedContract(_contract, true);
        synchroEndRewards();
    }
    function _addRewards(address _to, uint256 _amount) internal {
        cryptofoxesSteak.addRewards(_to, _amount);
    }
    function addRewards(address _to, uint256 _amount) public override isFoxContract  {
        _addRewards(_to, _amount);
    }
    function withdrawRewards(address _to) public override isFoxContract {
        cryptofoxesSteak.withdrawRewards(_to);
    }
    function _withdrawRewards(address _to) internal {
        cryptofoxesSteak.withdrawRewards(_to);
    }
    function isPaused() public view override returns(bool){
        return cryptofoxesSteak.isPaused();
    }
    function synchroEndRewards() public {
        endRewards = cryptofoxesSteak.dateEndRewards();
    }
    function dateEndRewards() public view override returns(uint256){
        require(endRewards > 0, "End Rewards error");
        return endRewards;
    }
    function _currentTime(uint256 _currentTimestamp) public view virtual returns (uint256) {
        return min(_currentTimestamp, dateEndRewards());
    }
    function min(uint256 a, uint256 b) public pure returns (uint256){
        return a > b ? b : a;
    }
    function max(uint256 a, uint256 b) public pure returns (uint256){
        return a > b ? a : b;
    }
    function setDisablePublicFunctions(bool _toggle) public isFoxContractOrOwner{
        disablePublicFunctions = _toggle;
    }
}// MIT

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
}// MIT
pragma solidity ^0.8.0;



contract CryptoFoxesCalculationV2 is Ownable, ICryptoFoxesCalculationV2, ICryptoFoxesStakingStruct, ICryptoFoxesCalculationOrigin, CryptoFoxesUtility, ReentrancyGuard {

    uint256 public constant BASE_RATE_ORIGIN = 6 * 10**18;
    uint256 public constant BASE_RATE_V2 = 1 * 10**18;
    uint256 public BONUS_MAX_OWNED = 2; // 0.2

    address public cryptoFoxesOrigin;
    address public cryptoFoxesStakingV2;

    function setCryptoFoxesOrigin(address _contract) public onlyOwner{

        if(cryptoFoxesOrigin != address(0)) {
            setAllowedContract(cryptoFoxesOrigin, false);
        }
        setAllowedContract(_contract, true);
        cryptoFoxesOrigin = _contract;
    }

    function setCryptoFoxesStakingV2(address _contract) public onlyOwner{

        if(cryptoFoxesStakingV2 != address(0)) {
            setAllowedContract(cryptoFoxesStakingV2, false);
        }
        setAllowedContract(_contract, true);
        cryptoFoxesStakingV2 = _contract;
    }

    function calculationRewards(address _contract, uint256[] memory _tokenIds, uint256 _currentTimestamp) public override view returns(uint256){


        if(_tokenIds.length <= 0){ return 0; }

        address ownerOrigin = IERC721(_contract).ownerOf(_tokenIds[0]);
        uint256 _currentTime = ICryptoFoxesOrigins(_contract)._currentTime(_currentTimestamp);

        uint256 totalRewards = 0;

        unchecked {
            for (uint8 i = 0; i < _tokenIds.length; i++) {
                if(_tokenIds[i] > 1000) continue;
                for (uint8 j = 0; j < i; j++) {
                    require(_tokenIds[j] != _tokenIds[i], "Duplicate id");
                }

                uint256 stackTime = ICryptoFoxesOrigins(_contract).getStackingToken(_tokenIds[i]);
                stackTime = stackTime == 0 ? block.timestamp - 5 days : stackTime;
                if (_currentTime > stackTime) {
                    totalRewards += (_currentTime - stackTime) * BASE_RATE_ORIGIN;
                }

                uint8 maxSlotsOrigin = ICryptoFoxesStakingV2(cryptoFoxesStakingV2).getOriginMaxSlot(uint16(_tokenIds[i]));
                Staking[] memory foxesV2 = ICryptoFoxesStakingV2(cryptoFoxesStakingV2).getV2ByOrigin(uint16(_tokenIds[i]));
                uint256 numberTokensOwner = 0;
                uint256 calculation = 0;
                for(uint8 k = 0; k < foxesV2.length; k++){
                    calculation += (_currentTime - max(stackTime, foxesV2[k].timestampV2) ) * BASE_RATE_V2;

                    if(ownerOrigin == foxesV2[k].owner){
                        numberTokensOwner += 1;
                    }
                }

                totalRewards += calculation;

                if(numberTokensOwner == foxesV2.length && numberTokensOwner == maxSlotsOrigin){
                    totalRewards += calculation * BONUS_MAX_OWNED / 10;
                }
            }
        }

        return totalRewards / 86400;
    }

    function claimRewards(address _contract, uint256[] memory _tokenIds, address _owner) public override isFoxContract nonReentrant {

        require(!isPaused(), "Contract paused");

        uint256 reward = calculationRewards(_contract, _tokenIds, block.timestamp);
        _addRewards(_owner, reward);
        _withdrawRewards(_owner);
    }

    function calculationRewardsV2(address _contract, uint16[] memory _tokenIds, uint256 _currentTimestamp) public override view returns(uint256){

        uint256 _currentTime = ICryptoFoxesStakingV2(_contract)._currentTime(_currentTimestamp);
        uint256 totalSeconds = 0;
        unchecked {
            for (uint8 i = 0; i < _tokenIds.length; i++) {

                for (uint16 j = 0; j < i; j++) {
                    require(_tokenIds[j] != _tokenIds[i], "Duplicate id");
                }

                uint256 stackTime = ICryptoFoxesStakingV2(_contract).getStakingTokenV2(_tokenIds[i]);

                if (_currentTime > stackTime) {
                    totalSeconds += _currentTime - stackTime;
                }
            }
        }

        return (BASE_RATE_V2 * totalSeconds) / 86400;
    }

    function claimRewardsV2(address _contract, uint16[] memory _tokenIds, address _owner) public override isFoxContract nonReentrant {

        require(!isPaused(), "Contract paused");

        uint256 rewardV2 = 0;
        uint256 _currentTime = ICryptoFoxesStakingV2(_contract)._currentTime(block.timestamp);

        unchecked {
            for (uint8 i = 0; i < _tokenIds.length; i++) {

                uint256 stackTimeV2 = ICryptoFoxesStakingV2(_contract).getStakingTokenV2(_tokenIds[i]);

                uint16 origin = ICryptoFoxesStakingV2(_contract).getOriginByV2( _tokenIds[i] );
                uint256 stackTimeOrigin = ICryptoFoxesOrigins(cryptoFoxesOrigin).getStackingToken(origin);
                address ownerOrigin = IERC721(cryptoFoxesOrigin).ownerOf( origin );

                if (_currentTime > stackTimeV2) {
                    rewardV2 += (BASE_RATE_V2 * (_currentTime - stackTimeV2)) / 86400;
                    _addRewards(ownerOrigin, (BASE_RATE_V2 * (_currentTime - max(stackTimeOrigin, stackTimeV2) )) / 86400);
                }
            }
        }

        _addRewards(_owner, rewardV2);
        _withdrawRewards(_owner);
    }

    function claimMoveRewardsOrigin(address _contract, uint16 _tokenId, address _ownerOrigin) public override isFoxContract nonReentrant {

        uint256 _currentTime = ICryptoFoxesStakingV2(_contract)._currentTime(block.timestamp);

        uint16 origin = ICryptoFoxesStakingV2(_contract).getOriginByV2( _tokenId );
        Staking memory foxesV2 = ICryptoFoxesStakingV2(_contract).getFoxesV2( _tokenId );
        uint256 stackTimeOrigin = ICryptoFoxesOrigins(cryptoFoxesOrigin).getStackingToken(origin);
        uint256 stackTimeV2 = ICryptoFoxesStakingV2(_contract).getStakingTokenV2(_tokenId);

        _addRewards(foxesV2.owner, (BASE_RATE_V2 * (_currentTime - stackTimeV2 )) / 86400);
        _addRewards(_ownerOrigin, (BASE_RATE_V2 * (_currentTime - max(stackTimeOrigin, stackTimeV2) )) / 86400);
    }

    function calculationOriginDay(uint16 _tokenId) public view returns(uint256){


        address ownerOrigin = IERC721(cryptoFoxesOrigin).ownerOf(uint256(_tokenId));
        uint8 maxSlotsOrigin = ICryptoFoxesStakingV2(cryptoFoxesStakingV2).getOriginMaxSlot(uint16(_tokenId));
        Staking[] memory foxesV2 = ICryptoFoxesStakingV2(cryptoFoxesStakingV2).getV2ByOrigin(uint16(_tokenId));

        uint256 numberTokensOwner = 0;
        uint256 calculationV2 = 0;

        for(uint8 k = 0; k < foxesV2.length; k++){

            calculationV2 += BASE_RATE_V2;

            if(ownerOrigin == foxesV2[k].owner){
                numberTokensOwner += 1;
            }
        }
        if(numberTokensOwner == foxesV2.length && numberTokensOwner == maxSlotsOrigin){
            calculationV2 += calculationV2 * BONUS_MAX_OWNED / 10;
        }

        return BASE_RATE_ORIGIN + calculationV2;
    }
}