
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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
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

pragma solidity ^0.8.4;


struct OmegaKey {
	bool active;
	bool removed; // whether a Key is removed by a successful Reward claim
	uint8 order; // Order of the Key will be released
	uint256 keyId; // equal to the Id of the Voxo this Key was assigned to
	address[] owners;
}

struct Player {
	bool active;
	uint256[] keyids; // A Key # is equal to the Voxo's Id it was assigned to
}


contract OKG is Ownable, Pausable {

	using SafeMath for uint256;
	using Address for address;

	mapping(uint256 => OmegaKey) public omegaKeys;
	mapping(address => Player) public players;
	event OmegaKeyReleased(uint256[] OmegaKey, uint8[] order);
	event OmegaKeyRegistered(address indexed Owner, uint256[]  OmegaKey);
	event OmegaKeyRemoved(address indexed Winner, uint256 indexed OmegaKey, uint256 indexed Tier, address[] allOwners);
	event OmegaKeyRestored(address[] oldOwners, uint256 indexed OmegaKey);
	event RewardClaimed(address indexed Winner, uint256 indexed Tier, uint256 Amount);
	event RewardRestored(uint256 indexed Tier, uint256 Amount);
	uint8 public releaseOrder;
	address public nftContract;
	bool public isDiamondRewardClaimed;
	bool public isGoldRewardClaimed;
	bool public isSilverRewardClaimed;
	bool public isBronzeRewardClaimed;


    constructor(address NFT_contract_address) {
    	nftContract = NFT_contract_address;
    }

	modifier isReleased(uint256 _keyId) {

		require(isKey(_keyId), "VOXO: Omega Key not released");
		_;
	}

	modifier whenNotGameOver() {

		require(!isGameOver(), "VOXO: Game Over");
		_;
	}

	modifier isOmegaRewardAmount(uint256 _ethReward) {

		require(isOmegaReward(_ethReward), "VOXO: Reward for this ETH amount does not exist");
		_;
	}

    function pause(bool status) public onlyOwner() {

        if (status) {
            _pause();
        } else {
            _unpause();
        }
    }

	function release(uint256[] calldata _ids) external
		onlyOwner()
		whenNotGameOver()
		whenNotPaused()
	{

		require(!hasDuplicates(_ids), "VOXO: Duplicate Key Ids");
		uint8[] memory _order = new uint8[](_ids.length);
		for (uint i = 0; i < _ids.length; i++) {
			require((_ids[i] != uint(0)), "VOXO: Voxo Id cannot be Zero");
			require(!isKey(_ids[i]), "VOXO: Voxo can only be assigned 1 Omega Key");
			require(!isRemoved(_ids[i]), "VOXO: Voxo cannot be assigned to a removed Omega Key");

		}

		for (uint i = 0; i < _ids.length; i++) {
			releaseOrder++;
			_order[i] = releaseOrder;
			omegaKeys[_ids[i]] = OmegaKey({
				active: true,
				removed: false,
				order: releaseOrder,
				keyId: _ids[i],
				owners: new address[](0)
			});
		}
		emit OmegaKeyReleased(_ids, _order);
	}

	function register(uint256[] calldata _keyIds) external
		whenNotGameOver()
		whenNotPaused()
	{

		require(!hasDuplicates(_keyIds), "VOXO: Duplicate Key Ids");
		IERC721 _token = IERC721(address(nftContract));
		for (uint i = 0; i < _keyIds.length; i++) {
			require((_keyIds[i] != uint(0)), "VOXO: Voxo Id cannot be Zero");
			require(isKey(_keyIds[i]), "VOXO: Omega Key not released");
			require(!isRegistered(_keyIds[i], _msgSender()), "VOXO: Omega Key already registered");
			require(_token.ownerOf(_keyIds[i]) == _msgSender(), "VOXO: You are not the owner of this KeyVoxo");
		}

		for (uint i = 0; i < _keyIds.length; i++) {
			omegaKeys[_keyIds[i]].owners.push(_msgSender());
			if (players[_msgSender()].active) {
				players[_msgSender()].keyids.push(_keyIds[i]);
			} else {
				players[_msgSender()].active = true;
				players[_msgSender()].keyids.push(_keyIds[i]);
			}
		}
		emit OmegaKeyRegistered(_msgSender(), _keyIds);
	}

	function claim(uint256 _ethClaim) public
		whenNotGameOver()
		whenNotPaused()
		isOmegaRewardAmount(_ethClaim)
	{

		require(players[_msgSender()].active, "VOXO: Player does not exist");

		uint256 noKeysRequired;
		if (_ethClaim == uint256(16)) {
			require(!isBronzeRewardClaimed, "VOXO: Bronze Reward already claimed");
			require(players[_msgSender()].keyids.length >= 3, "VOXO: Player Key collection insufficient for this Reward");
			noKeysRequired = 3;
			removeOmegaKeys(noKeysRequired);
			isBronzeRewardClaimed = true;
		}
		if (_ethClaim == uint256(33))  {
			require(!isSilverRewardClaimed, "VOXO: Silver Reward already claimed");
			require(players[_msgSender()].keyids.length >= 4, "VOXO: Player Key collection insufficient for this Reward");
			noKeysRequired = 4;
			removeOmegaKeys(noKeysRequired);
			isSilverRewardClaimed = true;
		}
		if (_ethClaim == uint256(66))  {
			require(!isGoldRewardClaimed, "VOXO: Gold Reward already claimed");
			require(players[_msgSender()].keyids.length >= 6, "VOXO: Player Key collection insufficient for this Reward");
			noKeysRequired = 6;
			removeOmegaKeys(noKeysRequired);
			isGoldRewardClaimed = true;
		}
		if (_ethClaim == uint256(135)) {
			require(!isDiamondRewardClaimed, "VOXO: Diamond Reward already claimed");
			require(players[_msgSender()].keyids.length >= 8, "VOXO: Player Key collection insufficient for this Reward");
			noKeysRequired = 8;
			removeOmegaKeys(noKeysRequired);
			isDiamondRewardClaimed = true;
		}

		emit RewardClaimed(_msgSender(), noKeysRequired, _ethClaim);
	}

	function removeOmegaKeys(uint256 _keys) private {

		for (uint i = 0; i < _keys; i++) {
			uint256 keyToRemove = players[_msgSender()].keyids[0];
			omegaKeys[keyToRemove].active = false;
			omegaKeys[keyToRemove].removed = true;
			address[] memory allOwners = omegaKeys[keyToRemove].owners;
			for (uint j = 0; j < allOwners.length; j++) {
				players[allOwners[j]].keyids = removeKeyFromPlayer(keyToRemove, allOwners[j]);
				if (players[allOwners[j]].keyids.length > 0) {
					players[allOwners[j]].keyids.pop();
				}
			}
			emit OmegaKeyRemoved(_msgSender(), keyToRemove, _keys, allOwners);
		}
	}

	function removeKeyFromPlayer(uint256 _keyId, address _player) internal view returns (uint256[] memory keyids) {

		keyids = players[_player].keyids;
		uint256 index = keyids.length;
		for (uint i = 0; i < index; i++) {
			if (keyids[i] == _keyId) {
				keyids[i] = keyids[index - 1];
				delete keyids[index - 1];
			}
		}
	 }

	function restoreReward(uint256 _ethReward) private
	{

		uint256 noKeysRequired = 0;
		if ((_ethReward == uint256(16)) && (isBronzeRewardClaimed)) {
			isBronzeRewardClaimed = false;
			noKeysRequired = 3;
		}
		if ((_ethReward == uint256(33)) && (isSilverRewardClaimed)) {
			isSilverRewardClaimed = false;
			noKeysRequired = 4;
		}
		if ((_ethReward == uint256(66)) && (isGoldRewardClaimed)) {
			isGoldRewardClaimed = false;
			noKeysRequired = 6;
		}
		if (_ethReward == uint256(135) && (isDiamondRewardClaimed)) {
			isDiamondRewardClaimed = false;
			noKeysRequired = 8;
		}
		emit RewardRestored(noKeysRequired, _ethReward);
	}

	function revertRewardClaim(uint256 _ethReward, uint256[] memory _keyIds, address _disqualifiedPlayer) public
		onlyOwner()
		whenNotPaused()
		isOmegaRewardAmount(_ethReward)
	{

		require(!hasDuplicates(_keyIds), "VOXO: Duplicate Key Ids");
		for (uint j = 0; j < _keyIds.length; j++) {
			require ((omegaKeys[_keyIds[j]].removed && !omegaKeys[_keyIds[j]].active), "VOXO: Omega Key is not removed");
		}
		restoreReward(_ethReward);
		for (uint i = 0; i < _keyIds.length; i++) {
			address[] memory oldOwners;
			omegaKeys[_keyIds[i]].owners = removePlayer(_keyIds[i], _disqualifiedPlayer);
			if (omegaKeys[_keyIds[i]].owners.length > 0) {
				omegaKeys[_keyIds[i]].owners.pop();
				oldOwners = omegaKeys[_keyIds[i]].owners;
			}
			uint8 oldOrder = omegaKeys[_keyIds[i]].order;
			omegaKeys[_keyIds[i]] = OmegaKey({
				active: true,
				removed: false,
				order: oldOrder,
				keyId: _keyIds[i],
				owners: oldOwners
			});
			for(uint k = 0; k < omegaKeys[_keyIds[i]].owners.length; k++) {
				players[omegaKeys[_keyIds[i]].owners[k]].keyids.push(_keyIds[i]);
			}
			emit OmegaKeyRestored(omegaKeys[_keyIds[i]].owners, _keyIds[i]);
		}
	}

	function isKey(uint256 _keyId) public view returns (bool) {

		return omegaKeys[_keyId].active;
	}

	function isRemoved(uint256 _keyId) public view returns (bool) {

		return omegaKeys[_keyId].removed;
	}

	function isOmegaReward(uint256 _ethReward) public pure returns (bool) {

		return (_ethReward == uint256(16)) || (_ethReward == uint256(33)) || (_ethReward == uint256(66)) || (_ethReward == uint256(135));
	}

	function isGameOver() public view returns (bool) {

		return (isDiamondRewardClaimed && isGoldRewardClaimed && isSilverRewardClaimed && isBronzeRewardClaimed);
	}

	function isRegistered(uint256 _keyId, address _owner) public view isReleased(_keyId) returns (bool registered) {

		registered = false;
		for (uint i = 0; i < omegaKeys[_keyId].owners.length; i++) {
			if (omegaKeys[_keyId].owners[i] == _owner) {
				registered = true;
			}
		}
		return registered;
	}

	function getKeyCollection(address _player) public view returns (uint256[] memory) {

		return players[_player].keyids;
	}

	function getKeyCollectionSize(address _player) public view returns (uint256 ) {

		return players[_player].keyids.length;
	}

	function removePlayer(uint256 _keyIds, address _disqualifiedPlayer) internal view returns (address[] memory owners) {

		owners = omegaKeys[_keyIds].owners;
		uint256 index = owners.length;
		for (uint i = 0; i < index; i++) {
			if (owners[i] == _disqualifiedPlayer) {
				owners[i] = owners[index - 1];
				delete owners[index - 1];
			}
		}
	}

	function hasDuplicates(uint256[] memory A) internal pure returns (bool) {

		if (A.length == 0) {
		return false;
		}
		for (uint256 i = 0; i < A.length - 1; i++) {
			for (uint256 j = i + 1; j < A.length; j++) {
				if (A[i] == A[j]) {
				return true;
				}
			}
		}
		return false;
	}
}