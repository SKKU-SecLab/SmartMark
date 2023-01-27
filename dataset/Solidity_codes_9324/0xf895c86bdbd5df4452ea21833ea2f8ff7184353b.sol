



pragma solidity ^0.8.0;

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {

        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {

        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {

        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}




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
}




pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}


pragma solidity 0.8.7;











interface IEgg {

	function mintFromExtentionContract(address _to, uint256 _amount) external;

}

contract DinoFamEggStaking is  Ownable{

    using SafeMath for uint256;
    bool public paused = false;
	IERC721 BBD;
    IERC721 CD;
    IEgg egg;

    uint256 public BADBAYDINO_REWARD = 1 ether;
    uint256 public CAVEDINO_REWARD = 2 ether;
    uint256 public BOTHSTAKED_REWARD = 10 ether;
    uint256 public SPECIALID_REWARD = 10 ether;

    uint256 public specialTokenRange = 12223;
    uint256 public CAVEDINO_SEPERATOR = 10001;

    mapping(uint256 => uint256) public lastClaimTime;
    mapping(uint256 => address) public tokenIdOwners;
    mapping(address => mapping(uint256 => uint256)) public ownerTokenIds;
    mapping(address => uint256) public numberTokensStaked;
    mapping(address => uint256) public _balances;
    mapping(address => bool) public staff;
    
  
   
    modifier onlyAllowedContracts {

        require(staff[msg.sender] || msg.sender == owner());
        _;
    }

    constructor(address _badBabyDinosNFtAddress, address _caveDinosAddress, address _tokenAddress){
		
		BBD = IERC721(_badBabyDinosNFtAddress);
        CD = IERC721(_caveDinosAddress);
        egg = IEgg(_tokenAddress);

	}

    function _makeId(bool isBBD, uint256 _val) internal view returns(uint256){

       if(isBBD){
           return _val;
       }else{
            return _val + CAVEDINO_SEPERATOR;
       }
    }

    function _isIDBbd(uint256 _id) internal view returns(bool){

        return _id < CAVEDINO_SEPERATOR ? true:false;
    }

    function _getId(uint256 _id) internal view returns(uint256){

        return _id<CAVEDINO_SEPERATOR? _id: (_id - CAVEDINO_SEPERATOR);
    }

    function setTokenAddress(address _val) public onlyOwner{

        egg = IEgg(_val);
    }

    

     function setNftAddress(bool _isBBD, address _val) public onlyOwner{

       if(_isBBD){
           BBD = IERC721(_val);
       
       }else{
            CD = IERC721(_val);
       }
    }

    

    function setRewards(bool isBBD, uint256 _amount) public onlyOwner{

        if(isBBD){
                BADBAYDINO_REWARD = _amount;
        }else {
            CAVEDINO_REWARD = _amount;
           }
    }

    function _mint(address user, uint256 amount) internal {

        egg.mintFromExtentionContract(user,amount);
    }

    function _syncTime(address _user, uint256 _time) internal {

        uint256 len = numberTokensStaked[_user]; 
        unchecked {
            for (uint256 i = 0; i < len; ++i) {
                uint256 tid = ownerTokenIds[_user][i];
                lastClaimTime[tid] = _time;
            }
        }
    }
    function stake(uint256[] calldata tokenIds, bool[] calldata isBBDContract ) public  {

        require(!paused, "Contract is paused");
        require(tokenIds.length > 0, "Require More than 1 to stake");

        if(numberTokensStaked[msg.sender] > 0){
             uint256 lastIndex = numberTokensStaked[msg.sender] - 1;
             uint256 tid = ownerTokenIds[msg.sender][lastIndex];
             uint256 lastUpdated = lastClaimTime[tid];
             uint256 oldRewards = getRewardInfo(msg.sender);
             uint256 calRewards = _calculateTokenRewards(block.timestamp, lastUpdated, oldRewards);
             _balances[msg.sender] += calRewards;
             _syncTime(msg.sender, block.timestamp);
        }
       


        for (uint256 i = 0; i < tokenIds.length; ++i) {
            bool isBBDC = isBBDContract[i];
            uint256 tokenId = tokenIds[i];
            uint256 formattedTokenId = _makeId(isBBDC, tokenId);
            address owner;
            if(isBBDC){
                owner  = BBD.ownerOf(tokenId);
            require(
                owner == msg.sender,
                "BBDStaking: you don't own the token on BBD Contract"
            );
            }else{
                 owner = CD.ownerOf(tokenId);
            require(
                owner == msg.sender,
                "BBDStaking: you don't own the token on CD Contract"
            );
            }

            require(
                tokenIdOwners[tokenId] == address(0),
                "StakingERC20: This token is already staked"
            );

            lastClaimTime[formattedTokenId] = block.timestamp;
            tokenIdOwners[formattedTokenId] = owner;
            ownerTokenIds[owner][numberTokensStaked[owner]] = formattedTokenId;
            numberTokensStaked[owner]++;
           if(isBBDC){
                BBD.transferFrom(msg.sender,address(this),tokenId);
           }else{
                CD.transferFrom(msg.sender,address(this),tokenId);
           }
        }
    }

     function overideTranser(address _user, uint256 _id, bool isBBDContract) public onlyOwner{

         if(isBBDContract){
             BBD.transferFrom(
            address(this),
            _user,
            _id
        );
         }else{
               CD.transferFrom(
            address(this),
            _user,
            _id
        );
         }
    }

    function setStaffState(address _address, bool _state) public onlyOwner {

        staff[_address] = _state;
    }

    function togglePause() public onlyOwner {

		paused = !paused;
	}


    	

    function claimRewards(address _user) public {

        uint256 c = getStakingRewards(_user);
        _resetBal(_user);
        _syncTime(_user, block.timestamp);
        _mint(_user, c);
    }

    function unstake(uint256[] calldata tokenIds) public   {

       
       
        
       unchecked {
            for (uint256 i = 0; i < tokenIds.length; ++i) {
           
            uint tokenId = tokenIds[i];
            uint formattedTokenId = _getId(tokenId);
            bool isBBDC = _isIDBbd(tokenId);

            require(
                tokenIdOwners[tokenId] == msg.sender,
                "StakingERC20: You don't own this token"
            );

             uint256 c = getStakingRewardsSingle(tokenId);
            _mint(msg.sender, c);
            tokenIdOwners[tokenId] = address(0);
           for (uint256 j = 0; j < numberTokensStaked[msg.sender]; ++j) {
                    if (ownerTokenIds[msg.sender][j] == tokenId) {
                        uint256 lastIndex = numberTokensStaked[msg.sender] - 1;
                        ownerTokenIds[msg.sender][j] = ownerTokenIds[msg.sender][
                            lastIndex
                        ];
                        delete ownerTokenIds[msg.sender][lastIndex];
                        break;
                    }
                }
            numberTokensStaked[msg.sender]--;
             if(isBBDC){
                BBD.transferFrom(
            address(this),
            msg.sender,
            formattedTokenId
        );
            }else{
                 BBD.transferFrom(
            address(this),
            msg.sender,
            formattedTokenId
        );
        }
    }
       }

       
    }

    function _calculateTokenRewards(
        uint256 currenTime,
        uint256 lastClaimed,
        uint256 reward
    ) internal pure  returns (uint256) {

        return reward.mul(currenTime.sub(lastClaimed)).div(86400);
    }

    function getUserstakedIds(address _user) public view returns (uint256[] memory){

        uint256 len = numberTokensStaked[_user];
        uint256[] memory temp = new uint[](len);
        for (uint256 i = 0; i < len; ++i) {
             temp[i] = ownerTokenIds[_user][i];
        }
        return temp;
    }


    function getStakingRewardsSingle(uint256 tokenId) public view returns (uint256) {

            uint256 lastClaimed = lastClaimTime[tokenId];
            bool isBBDc = _isIDBbd(tokenId);
            if(tokenId >= 10001 && tokenId <= specialTokenRange){
                 return _calculateTokenRewards(block.timestamp, lastClaimed, SPECIALID_REWARD);
            }else{
                 return _calculateTokenRewards(block.timestamp, lastClaimed, isBBDc?BADBAYDINO_REWARD:CAVEDINO_REWARD);
            }
      }
      function decimals() pure internal returns (uint8) {

        return 18;
    }

    
  function setSpecialIdReward(uint256 _val) public onlyOwner{

        SPECIALID_REWARD = _val;
    }

    function setBothStakedReward(uint256 _val) public onlyOwner{

        BOTHSTAKED_REWARD = _val;
    }


    function getTokenReward(uint256 _id) view  internal returns (uint256) {

        bool isBBDc = _isIDBbd(_id);
         if(_id >= 10001 && _id <= specialTokenRange){ 
            return SPECIALID_REWARD;
        }else{
            return isBBDc?BADBAYDINO_REWARD:CAVEDINO_REWARD;
        }
    }


    function getStakingRewards(address _user) public view returns (uint256) {

        uint256 reward =  getRewardInfo(_user);
        if(numberTokensStaked[msg.sender] > 0){
            uint256 lastIndex = numberTokensStaked[msg.sender] - 1;
            uint256 tid = ownerTokenIds[msg.sender][lastIndex];
            uint256 lastUpdated = lastClaimTime[tid];
            uint256 calRewards = _calculateTokenRewards(block.timestamp, lastUpdated, reward);
            uint256 oldBalance = _balances[msg.sender];
            return  calRewards + oldBalance;
        }else{
            return 0;
        }
      }

      function _resetBal(address _user) internal {

          _balances[_user] = 0;
      }


    function getRewardInfo(address _user)
        public
        view
        returns (
            uint256
        )
    {

        uint256 len = numberTokensStaked[_user];
        uint256 babyBabyDinoCount;
        uint256 caveDinoCount;
        uint256 specialIdCount;
        
        unchecked {
            for (uint256 i = 0; i < len; ++i) {

                uint256 tid = ownerTokenIds[_user][i];
           
            if (tid < CAVEDINO_SEPERATOR) {
                    babyBabyDinoCount++;
            } else {
                   if(tid >= 10001 && tid <= specialTokenRange){
                        specialIdCount++;
                    }
                    caveDinoCount++;
                
            }  
        }
        }

            if (babyBabyDinoCount >= caveDinoCount) {
                uint256 bal = babyBabyDinoCount - caveDinoCount;
                if ((bal) == 0) {
                   
                    return calculateRewards(0, 0, babyBabyDinoCount, specialIdCount);
                } else {
                      return calculateRewards(bal, 0, caveDinoCount, specialIdCount);
                }
            } else {
                
                uint256 bal = caveDinoCount - babyBabyDinoCount;
                if ((bal) == 0) {
                    return calculateRewards(0, 0, caveDinoCount, specialIdCount);
                } 
                else if(bal == caveDinoCount){
                 
                    return calculateRewards(0, caveDinoCount, 0, specialIdCount);
                }
                else {
                      return calculateRewards(0, bal, babyBabyDinoCount, specialIdCount);
                }
            } 
    }

     function calculateRewards(uint256 badbabycount, uint256 cavedinocount, uint256 pairs, uint256 specials) public view returns (uint256){

             if(specials > 0 ){
                   if(specials >= cavedinocount){
                        if(pairs == 0){
                              return (badbabycount * BADBAYDINO_REWARD) + (pairs * BOTHSTAKED_REWARD) + (cavedinocount * SPECIALID_REWARD);
                        }else{
                              return (badbabycount * BADBAYDINO_REWARD) + (pairs * BOTHSTAKED_REWARD) + (specials * SPECIALID_REWARD);
                        }
                   }else{
                         uint a = cavedinocount - specials;
                         return (badbabycount * BADBAYDINO_REWARD) + (a * CAVEDINO_REWARD) +  (pairs * BOTHSTAKED_REWARD) + (specials * SPECIALID_REWARD);
                    }
                    }else{
                            return (badbabycount * BADBAYDINO_REWARD) + (cavedinocount * CAVEDINO_REWARD) +  (pairs * BOTHSTAKED_REWARD);
                    }
            }
}