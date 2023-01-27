



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




pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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


pragma solidity 0.8.7;









interface INFT {
	function balanceOG(address _user) external view returns(uint256);
}

interface ICoinV1 {
	function burn(address _from, uint256 _amount)  external;
}


contract TUSKCOINV2 is ERC20("TUSKCOINV2", "TUSKCOINV2"), Ownable{
	using SafeMath for uint256;
	bool paused = false;
	uint256 swapBonus = 5; //in percent
	uint256 dailyBaseReward = 2 ether;
	uint256 rewardInterwal = 8600;

	mapping(address => uint256) public rewards;
    mapping(address => bool) public staff;
	mapping(address => uint256) public contractBalanceOf; 

	IERC20 v1Coin;
	ICoinV1 v1CoinContract ;
	IERC721 nft; 

	 struct UserInfo {
        uint256[] stakedTokens;
		
        mapping(uint256 => uint256) stakedDate;
        uint256 amountStaked;
        mapping(uint256 => uint256) lastRewardUpdated;
		mapping(uint256 => uint256) bonus;
    }

	struct BonusProofs {
        bytes32[] proof;
    }

    mapping(address => UserInfo) public stakeUserInfo;

    mapping(uint256 => address) public tokenOwners;

	

	bytes32 private stakingRoot;





	modifier onlyAllowedContracts {
        require(staff[msg.sender] || msg.sender == owner());
        _;
    }

	event Eswapv1(address indexed _from,uint _value);
	event EwithdrawToWallet(address indexed _from, uint _value);
	event EdepositToContract(address indexed _from, uint _value);
	event EtransferInternalAccounts(address indexed _from,address indexed _to, uint _value);
	event Epay(address indexed _from, address indexed _contract, uint _value);
	event Estake(address indexed _from, uint indexed _nftId);
	event EunStake(address indexed _from, uint indexed _nftId);

	constructor(address _v1Address, address _nftAddress){
		v1Coin= IERC20(_v1Address); 
		v1CoinContract = ICoinV1(_v1Address);
		nft = IERC721(_nftAddress);

		 _mint(msg.sender, 3650000 * 10 ** decimals());
	}

	

	 function swapv1() public {
		 require(!paused, "Contract is paused");
		 uint256 balance = v1Coin.balanceOf(msg.sender);
		
		 uint256 mintableWithBonus = balance * ((100 + swapBonus) / 100);
		 contractBalanceOf[msg.sender] = contractBalanceOf[msg.sender].add(mintableWithBonus);

		 v1CoinContract.burn(msg.sender, balance);

		 emit Eswapv1(msg.sender, balance);
	}

	function withdrawToWallet(uint256 _amount) public {
		require(!paused, "Contract is paused");

		uint256 balance = getCombinedAccountBalance(msg.sender);
		require(_amount <= balance, "You dont have enough tokens to withdraw this balance");
		_mint(msg.sender, _amount);

		contractBalanceOf[msg.sender] = 0; 
		_updateLastUpdated(msg.sender);

		emit EwithdrawToWallet(msg.sender, _amount);
	}

	function depositToContract(uint256 _amount) public {
		require(!paused, "Contract is paused");
		require(_amount <= balanceOf(msg.sender), "You dont have enough tokens to deposit");
		_burn(msg.sender, _amount);
		contractBalanceOf[msg.sender] = contractBalanceOf[msg.sender].add(_amount);
		emit EdepositToContract(msg.sender, _amount);
	}

	function transferInternalAccounts(address _to, uint256 _amount) public {
		 require(!paused, "Contract is paused");
			uint256 cBalance = getCombinedAccountBalance(msg.sender);
			require(_amount <= cBalance, "You do not have enough tokens to tranfer");
			contractBalanceOf[_to] = contractBalanceOf[_to].add(_amount);
			uint256 updatedVal = cBalance - _amount;
			contractBalanceOf[msg.sender] = updatedVal;
			_updateLastUpdated(msg.sender);
			emit EtransferInternalAccounts(msg.sender,_to, _amount);
	}

	function bankerErrorFix(address _account, uint256 _amount, bool _deposit) public onlyAllowedContracts {
			if(_deposit){
				contractBalanceOf[_account] = contractBalanceOf[_account].add(_amount);
			}else{
				require(_amount < contractBalanceOf[_account], "Account will go minus");
           		contractBalanceOf[_account] = contractBalanceOf[_account].sub(_amount);
			}
	}
	
	function pay(address _spender,uint256 _amount) public onlyAllowedContracts{
		 require(!paused, "Contract is paused");

			 uint256 walletBalance = balanceOf(_spender); 
			uint256 cBalance = getCombinedAccountBalance(_spender);
			uint256 total = cBalance + walletBalance ;

			require(_amount <= total, "Not enough tokens to spend");
			if(_amount <  cBalance){
				uint256 aBalance = cBalance - _amount; 
				contractBalanceOf[_spender] = aBalance; 
				_updateLastUpdated(_spender);
			}else {
				uint256 amountToBurn = _amount - cBalance;
				contractBalanceOf[_spender] = 0; 
				_updateLastUpdated(_spender);
				_burn(_spender, amountToBurn);
			}
			emit Epay(_spender, msg.sender, _amount);
	}


	  function stake(uint256 _id, uint256 _bonus, bytes32[] calldata _proof) public {
        _stake(msg.sender, _id, _bonus,_proof);
    }

	function getStakedNftIds(address _account) public view returns(uint256[] memory) {
		 UserInfo storage user = stakeUserInfo[_account];
		 uint256[] memory  stakedNfts = user.stakedTokens;
		 return stakedNfts;
	}

	function getStakedDate(address _account, uint256 _id) public view returns(uint256) {
		 UserInfo storage user = stakeUserInfo[_account];
		 return user.stakedDate[_id];
	}

	function getStakedLastRewardUpdated(address _account, uint256 _id) public view returns(uint256) {
		 UserInfo storage user = stakeUserInfo[_account];
		 return user.lastRewardUpdated[_id];
	}

	function getStakedBonus(address _account, uint256 _id) public view returns(uint256) {
		 UserInfo storage user = stakeUserInfo[_account];
		 return user.bonus[_id];
	}

    function batchStake(uint256[] memory _ids, uint256[] memory _bonuses, BonusProofs[] calldata proofs ) public {
		uint256 len = _ids.length;
        for (uint256 i = 0; i < len; ++i) {
            _stake(msg.sender, _ids[i],  _bonuses[i], proofs[i].proof);
        }
    }

    function unstake(address _user, uint256 _id) public {
		updatePendingBalanceToAccountBalance(_user);
        _unstake(_user, _id);
    }

    function batchUnstake(address _user, uint256[] memory _ids) public {
		uint256 len = _ids.length;
		updatePendingBalanceToAccountBalance(_user);
        for (uint256 i = 0; i < len; ++i) {
            _unstake(_user, _ids[i]);
        }
		
    }


	function _stake(
        address _user,
        uint256 _id,
		uint256 _bonus,
		bytes32[] calldata proof
    ) internal {
		 require(!paused, "Contract is paused");

		require(
                    _verify(_leaf(_id,_bonus), proof),
                    "Invalid proof"
                );


        UserInfo storage user = stakeUserInfo[_user];

        nft.transferFrom(
            _user,
            address(this),
            _id
        );

        user.amountStaked += 1;
        user.stakedDate[_id] = block.timestamp;
        user.stakedTokens.push(_id);
		user.bonus[_id] = _bonus;
        tokenOwners[_id] = _user;
		emit Estake(_user,_id);
    }

     

     function _unstake(address _user, uint256 _id) internal {
	
        UserInfo storage user = stakeUserInfo[_user];

        require(
            tokenOwners[_id] == _user,
            "Sender doesn't owns this token"
        );
         _removeElement(user.stakedTokens, _id);
        user.amountStaked -= 1;
		user.bonus[_id] = 0;
        delete tokenOwners[_id];
        if (user.stakedTokens.length == 0) {
            delete stakeUserInfo[_user];
        }

       nft.transferFrom(
            address(this),
            _user,
            _id
        );
		
		emit EunStake(_user, _id);
    }


	function updatePendingBalanceToAccountBalance(address _user) internal {
		uint256 currentBalance = getCombinedAccountBalance(_user);
		contractBalanceOf[_user] = currentBalance; 
		_updateLastUpdated(_user);
	}
	

    function _updateLastUpdated(address _user) internal {
        UserInfo storage user = stakeUserInfo[_user];
        for (uint256 i; i < user.stakedTokens.length; i++) {
			uint256 _nftId = user.stakedTokens[i];
            user.lastRewardUpdated[_nftId] = block.timestamp;
        }
    }

	function getStakingRewards(address _user) public view returns (uint256) {
		  uint256 time = block.timestamp;
          uint256 claimableRewards;
          UserInfo storage user = stakeUserInfo[_user];

            for(uint256 i =0; i < user.stakedTokens.length; i++){
                uint256 _nftId = user.stakedTokens[i] ;

				 if (user.lastRewardUpdated[_nftId] == 0) {
					  if (user.stakedDate[user.stakedTokens[i]] == 0) {
                        claimableRewards += 0;
                    }else{
						 uint256 rewardForNftStaked = (dailyBaseReward + user.bonus[_nftId])
                            .mul(
                                time.sub(user.stakedDate[user.stakedTokens[i]])
                            )
                            .div(rewardInterwal);
						claimableRewards += rewardForNftStaked;
					}
				 }else{
						 uint256 rewardForNftStaked = (dailyBaseReward + user.bonus[_nftId])
                            .mul(
                                time.sub(user.lastRewardUpdated[_nftId])
                            )
                            .div(rewardInterwal);
						claimableRewards += rewardForNftStaked;
				 }
            }
			return claimableRewards;
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

 
	

	function getCombinedAccountBalance(address _account) public view returns (uint256) {
		uint256 sBalance = getStakingRewards(_account);
		uint256 cBalance = contractBalanceOf[_account];
		return  sBalance + cBalance;
	}

	function getContractAccountBalance() public view returns (uint256) {
		uint256 cBalance = contractBalanceOf[msg.sender];
		return cBalance;
	}

	
	function setSwapBonus(uint256 _val) public onlyOwner {
		swapBonus = _val;
	}
	
	function setRewardInterwal(uint256 _val) public onlyOwner{
		rewardInterwal = _val;
	}

    function setStaffState(address _address, bool _state) public onlyOwner {
        staff[_address] = _state;
    }

	function togglePause() public onlyOwner {
		paused = !paused;
	}


	function burn(address _from, uint256 _amount) onlyAllowedContracts external {
		_burn(_from, _amount);
	}

	 function _verify(
        bytes32 _leafNode,
        bytes32[] memory proof
    ) internal view returns (bool) {
        return MerkleProof.verify(proof, stakingRoot, _leafNode);
    }

    function _leaf(uint256 _nftId, uint256 _bonus ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_nftId,_bonus));
    }

	 function setStakingRoot(bytes32 _root) public onlyOwner {
        stakingRoot = _root;
    }

}