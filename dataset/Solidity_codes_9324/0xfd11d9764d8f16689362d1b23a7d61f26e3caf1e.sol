



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
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


pragma solidity 0.8.7;










contract InulandStaking is ERC20("INUS", "INUS"), Ownable {
    using SafeMath for uint256;
    using Address for address;
   

    struct UserInfo {
        uint256[] stakedTokens;
        mapping(uint256 => uint256) lockedDays;
        mapping(uint256 => uint256) stakedDate;
          mapping(uint256 => uint256) miningPower;
        uint256 amountStaked;
        mapping(uint256 => uint256) lastRewardUpdated;
    }

    struct MintingPowerProofs {
        bytes32[] proof;
    }

    mapping(address => UserInfo) public stakeUserInfo;

    mapping(uint256 => address) public tokenOwners;

    address InulandCollectionAddress;
    address private contractExtension;

    uint256 dailyReward = 1 ether;
    uint256[] boosters = [102, 104, 105, 106, 107, 108, 109];
    uint256 rewardInterwal = 86400;

    bytes32 private miningPowerRoot;

    modifier onlyExtensionContract() {
        require(msg.sender == contractExtension);
        _;
    }


    function _verify(
        bytes32 _leafNode,
        bytes32[] memory proof
    ) internal view returns (bool) {
        return MerkleProof.verify(proof, miningPowerRoot, _leafNode);
    }

    function _leaf(uint256[] memory miningLeaf) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(miningLeaf));
    }

    

    function setMiningPowerRoot(bytes32 _root) public onlyOwner {
        miningPowerRoot = _root;
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }

    function setRewardInterval(uint256 _interval) public onlyOwner{
        rewardInterwal = _interval;
    }

    function setContractExtension(address _contractExtenstion)
        public
        onlyOwner
    {
        contractExtension = _contractExtenstion;
    }

    function mintFromExtentionContract(address _to, uint256 _amount)
        external
        onlyExtensionContract
    {
        _mint(_to, _amount);
    }

    function burnFromExtentionContract(address _to, uint256 _amount)
        external
        onlyExtensionContract
    {
        _burn(_to, _amount);
    }

    constructor(address _inulandCollectionAddress) {
        InulandCollectionAddress = _inulandCollectionAddress;
    }

  

    function setBooster(uint256[] memory _booster) public onlyOwner {
        boosters = _booster;
    }

    function setDailyReward(uint256 _dailyReward) public onlyOwner {
        dailyReward = _dailyReward;
    }

    function stake(uint256 _id, uint256 _lockedDays, uint256 _miningPower, bytes32[] calldata _proof) public {
        _stake(msg.sender, _id, _lockedDays,_miningPower, _proof);
    }

    function batchStake(uint256[] memory _ids, uint256 _lockedDays, uint256[] memory _miningPower, MintingPowerProofs[] calldata proofs) public {
        for (uint256 i = 0; i < _ids.length; ++i) {
            _stake(msg.sender, _ids[i], _lockedDays, _miningPower[i], proofs[i].proof);
        }
    }

    function unstake(uint256 _id) public {
        _unstake(msg.sender, _id);
    }

    function batchUnstake(uint256[] memory _ids) public {
        for (uint256 i = 0; i < _ids.length; ++i) {
            _unstake(msg.sender, _ids[i]);
        }
    }

    

    function claimRewards() public {
        uint256 rewards = getStakingRewards(msg.sender);
        _mint(msg.sender, rewards);
        _updateLastUpdated(msg.sender);
    }

    function _updateLastUpdated(address _user) internal {
        UserInfo storage user = stakeUserInfo[_user];
        for (uint256 i; i < user.stakedTokens.length; i++) {
            user.lastRewardUpdated[user.stakedTokens[i]] = block.timestamp;
        }
    }

    function getMiningPower(address _user, uint256 _tokenId) public  view returns (uint256){
         UserInfo storage user = stakeUserInfo[_user];
         return user.miningPower[_tokenId];
    }

    function getStakingRewards(address _user) public view returns (uint256) {
        uint256 time = block.timestamp;
        UserInfo storage user = stakeUserInfo[_user];
        uint256 clamableRewards;
        for (uint256 i; i < user.stakedTokens.length; i++) {
            if (user.stakedTokens[i] != 0) {
                uint256 nftMiningPower = user.miningPower[user.stakedTokens[i]];
                if (user.lastRewardUpdated[user.stakedTokens[i]] == 0) {
                    if (user.stakedDate[user.stakedTokens[i]] == 0) {
                        clamableRewards += 0;
                    } else {
                        uint256 normalReward = dailyReward
                            .mul(
                                time.sub(user.stakedDate[user.stakedTokens[i]])
                            )
                            .div(rewardInterwal)
                            .mul(nftMiningPower);
                        if (user.lockedDays[user.stakedTokens[i]] == 14) {
                            clamableRewards += (normalReward * 112) / 100;
                        } else if (
                            user.lockedDays[user.stakedTokens[i]] == 30
                        ) {
                            clamableRewards += (normalReward * 140) / 100;
                        } else if (
                            user.lockedDays[user.stakedTokens[i]] == 60
                        ) {
                            clamableRewards += (normalReward * 180) / 100;
                        } else if (
                            user.lockedDays[user.stakedTokens[i]] == 90
                        ) {
                            clamableRewards += (normalReward * 200) / 100;
                        } else {
                            clamableRewards += (normalReward * 112) / 100;
                        }
                    }
                } else {
                    uint256 normalReward = dailyReward
                        .mul(
                            time.sub(
                                user.lastRewardUpdated[user.stakedTokens[i]]
                            )
                        )
                        .div(rewardInterwal);
                    if (user.lockedDays[user.stakedTokens[i]] == 14) {
                        clamableRewards += (normalReward * 112) / 100;
                    } else if (user.lockedDays[user.stakedTokens[i]] == 30) {
                        clamableRewards += (normalReward * 140) / 100;
                    } else if (user.lockedDays[user.stakedTokens[i]] == 60) {
                        clamableRewards += (normalReward * 180) / 100;
                    } else if (user.lockedDays[user.stakedTokens[i]] == 90) {
                        clamableRewards += (normalReward * 200) / 100;
                    } else {
                        clamableRewards += (normalReward * 112) / 100;
                    }
                }
            }
        }

        if (user.amountStaked >= 35) {
            clamableRewards = clamableRewards.mul(boosters[6]).div(100);
        } else if (user.amountStaked >= 30) {
            clamableRewards = clamableRewards.mul(boosters[5]).div(100);
        } else if (user.amountStaked >= 25) {
            clamableRewards = clamableRewards.mul(boosters[4]).div(100);
        } else if (user.amountStaked >= 20) {
            clamableRewards = clamableRewards.mul(boosters[3]).div(100);
        } else if (user.amountStaked >= 15) {
            clamableRewards = clamableRewards.mul(boosters[2]).div(100);
        } else if (user.amountStaked >= 10) {
            clamableRewards = clamableRewards.mul(boosters[1]).div(100);
        } else if (user.amountStaked >= 5) {
            clamableRewards = clamableRewards.mul(boosters[0]).div(100);
        }

        return clamableRewards;
    }
    function testVerify( bytes32[] calldata proof, uint256 id, uint256 power) public view {
      uint256[] memory t = new uint256[](2);
          t[0] = id;
          t[1] = power;
             require(
                    _verify(_leaf(t), proof),
                    "Invalid proof"
                );
    }

    function _stake(
        address _user,
        uint256 _id,
        uint256 _lockedDays,
        uint256 _miningPower,
        bytes32[] calldata proof
    ) internal {
         uint256[] memory t = new uint256[](2);

        UserInfo storage user = stakeUserInfo[_user];
        t[0] = _id;
        t[1] = _miningPower;
         require(
                    _verify(_leaf(t), proof),
                    "Invalid Mining Data proof"
                );

        IERC721(InulandCollectionAddress).transferFrom(
            _user,
            address(this),
            _id
        );
        user.miningPower[_id] = _miningPower;
        user.amountStaked += 1;
        user.stakedDate[_id] = block.timestamp;
        user.lockedDays[_id] = _lockedDays;
        user.stakedTokens.push(_id);
        tokenOwners[_id] = _user;
    }

    function whenUnstake(address _user, uint256 _id) public  view returns (bool,uint256){
         UserInfo storage user = stakeUserInfo[_user];
            if( block.timestamp > (user.stakedDate[_id] + (user.lockedDays[_id] * rewardInterwal)) ){
                return (true, block.timestamp - (user.stakedDate[_id] + (user.lockedDays[_id] * rewardInterwal)));
            }else{
                return (true, block.timestamp - (user.stakedDate[_id] + (user.lockedDays[_id] * rewardInterwal)));
            }
    }

    function _unstake(address _user, uint256 _id) internal {
        UserInfo storage user = stakeUserInfo[_user];

        require(
            tokenOwners[_id] == _user,
            "Inuland._unstake: Sender doesn't owns this token"
        );
        require( block.timestamp > (user.stakedDate[_id] + (user.lockedDays[_id] * rewardInterwal)), "You cant Unstake right now");
        _removeElement(user.stakedTokens, _id);
        user.amountStaked -= 1;
        delete tokenOwners[_id];

        if (user.stakedTokens.length == 0) {
            delete stakeUserInfo[_user];
        }

        IERC721(InulandCollectionAddress).transferFrom(
            address(this),
            _user,
            _id
        );
    }


    function getUserInfo(address _user) public view returns (uint256[] memory) {
        UserInfo storage user = stakeUserInfo[_user];

        return (user.stakedTokens);
    }

    function getLockedDays(uint256 _id) public view returns (uint256) {
        UserInfo storage user = stakeUserInfo[tokenOwners[_id]];
        return user.lockedDays[_id];
    }

    function getStakedDate(uint256 _id) public view returns (uint256) {
        UserInfo storage user = stakeUserInfo[tokenOwners[_id]];
        return user.stakedDate[_id];
    }

     function _removeElement(uint256[] storage _array, uint256 _element) internal {
        for (uint256 i; i < _array.length; i++) {
            if (_array[i] == _element) {
                _array[i] = _array[_array.length - 1];
                _array.pop();
                break;
            }
        }
    }
}