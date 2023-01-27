pragma solidity 0.8.7;

interface ERC20 {

	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);




	function totalSupply() external view returns (uint256);


	function balanceOf(address _owner) external view returns (uint256 balance);


	function transfer(address _to, uint256 _value) external returns (bool success);


	function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);


	function approve(address _spender, uint256 _value) external returns (bool success);


	function allowance(address _owner, address _spender) external view returns (uint256 remaining);

}// MIT
pragma solidity 0.8.7;

interface ERC165 {

	function supportsInterface(bytes4 interfaceID) external view returns (bool);

}// MIT
pragma solidity 0.8.7;


interface ERC1363 is ERC20, ERC165  {


	function transferAndCall(address to, uint256 value) external returns (bool);


	function transferAndCall(address to, uint256 value, bytes memory data) external returns (bool);


	function transferFromAndCall(address from, address to, uint256 value) external returns (bool);



	function transferFromAndCall(address from, address to, uint256 value, bytes memory data) external returns (bool);


	function approveAndCall(address spender, uint256 value) external returns (bool);


	function approveAndCall(address spender, uint256 value, bytes memory data) external returns (bool);

}

interface ERC1363Receiver {


	function onTransferReceived(address operator, address from, uint256 value, bytes memory data) external returns (bytes4);

}

interface ERC1363Spender {


	function onApprovalReceived(address owner, uint256 value, bytes memory data) external returns (bytes4);

}// MIT
pragma solidity 0.8.7;

interface EIP2612 {

	function DOMAIN_SEPARATOR() external view returns (bytes32);


	function nonces(address owner) external view returns (uint);


	function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

}// MIT
pragma solidity 0.8.7;

interface EIP3009 {

	event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);

	event AuthorizationCanceled(address indexed authorizer, bytes32 indexed nonce);

	function authorizationState(
		address authorizer,
		bytes32 nonce
	) external view returns (bool);


	function transferWithAuthorization(
		address from,
		address to,
		uint256 value,
		uint256 validAfter,
		uint256 validBefore,
		bytes32 nonce,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;


	function receiveWithAuthorization(
		address from,
		address to,
		uint256 value,
		uint256 validAfter,
		uint256 validBefore,
		bytes32 nonce,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;


	function cancelAuthorization(
		address authorizer,
		bytes32 nonce,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;

}// MIT
pragma solidity 0.8.7;

contract AccessControl {

	uint256 public constant ROLE_ACCESS_MANAGER = 0x8000000000000000000000000000000000000000000000000000000000000000;

	uint256 private constant FULL_PRIVILEGES_MASK = type(uint256).max; // before 0.8.0: uint256(-1) overflows to 0xFFFF...

	mapping(address => uint256) public userRoles;

	event RoleUpdated(address indexed _by, address indexed _to, uint256 _requested, uint256 _actual);

	constructor() {
		userRoles[msg.sender] = FULL_PRIVILEGES_MASK;
	}

	function features() public view returns(uint256) {

		return userRoles[address(this)];
	}

	function updateFeatures(uint256 _mask) public {

		updateRole(address(this), _mask);
	}

	function updateRole(address operator, uint256 role) public {

		require(isSenderInRole(ROLE_ACCESS_MANAGER), "access denied");

		userRoles[operator] = evaluateBy(msg.sender, userRoles[operator], role);

		emit RoleUpdated(msg.sender, operator, role, userRoles[operator]);
	}

	function evaluateBy(address operator, uint256 target, uint256 desired) public view returns(uint256) {

		uint256 p = userRoles[operator];

		target |= p & desired;
		target &= FULL_PRIVILEGES_MASK ^ (p & (FULL_PRIVILEGES_MASK ^ desired));

		return target;
	}

	function isFeatureEnabled(uint256 required) public view returns(bool) {

		return __hasRole(features(), required);
	}

	function isSenderInRole(uint256 required) public view returns(bool) {

		return isOperatorInRole(msg.sender, required);
	}

	function isOperatorInRole(address operator, uint256 required) public view returns(bool) {

		return __hasRole(userRoles[operator], required);
	}

	function __hasRole(uint256 actual, uint256 required) internal pure returns(bool) {

		return actual & required == required;
	}
}// MIT
pragma solidity 0.8.7;

library AddressUtils {


	function isContract(address addr) internal view returns (bool) {

		uint256 size = 0;

		assembly {
			size := extcodesize(addr)
		}

		return size > 0;
	}
}// MIT
pragma solidity 0.8.7;

library ECDSA {

	function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

		bytes32 r;
		bytes32 s;
		uint8 v;

		if (signature.length == 65) {
			assembly {
				r := mload(add(signature, 0x20))
				s := mload(add(signature, 0x40))
				v := byte(0, mload(add(signature, 0x60)))
			}
		}
		else if (signature.length == 64) {
			assembly {
				let vs := mload(add(signature, 0x40))
				r := mload(add(signature, 0x20))
				s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
				v := add(shr(255, vs), 27)
			}
		}
		else {
			revert("invalid signature length");
		}

		return recover(hash, v, r, s);
	}

	function recover(
		bytes32 hash,
		uint8 v,
		bytes32 r,
		bytes32 s
	) internal pure returns (address) {

		require(
			uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
			"invalid signature 's' value"
		);
		require(v == 27 || v == 28, "invalid signature 'v' value");

		address signer = ecrecover(hash, v, r, s);
		require(signer != address(0), "invalid signature");

		return signer;
	}

	function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

		return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
	}

	function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

		return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
	}
}// MIT
pragma solidity 0.8.7;


contract AliERC20v2 is ERC1363, EIP2612, EIP3009, AccessControl {

	uint256 public constant TOKEN_UID = 0x8d4fb97da97378ef7d0ad259aec651f42bd22c200159282baa58486bb390286b;

	string public constant name = "Artificial Liquid Intelligence Token";

	string public constant symbol = "ALI";

	uint8 public constant decimals = 18;

	uint256 public override totalSupply; // is set to 10 billion * 10^18 in the constructor

	mapping(address => uint256) private tokenBalances;

	mapping(address => address) public votingDelegates;

	struct KV {
		uint64 k;

		uint192 v;
	}

	mapping(address => KV[]) public votingPowerHistory;

	KV[] public totalSupplyHistory;

	mapping(address => uint256) public override nonces;

	mapping(address => mapping(bytes32 => bool)) private usedNonces;

	mapping(address => mapping(address => uint256)) private transferAllowances;

	uint32 public constant FEATURE_TRANSFERS = 0x0000_0001;

	uint32 public constant FEATURE_TRANSFERS_ON_BEHALF = 0x0000_0002;

	uint32 public constant FEATURE_UNSAFE_TRANSFERS = 0x0000_0004;

	uint32 public constant FEATURE_OWN_BURNS = 0x0000_0008;

	uint32 public constant FEATURE_BURNS_ON_BEHALF = 0x0000_0010;

	uint32 public constant FEATURE_DELEGATIONS = 0x0000_0020;

	uint32 public constant FEATURE_DELEGATIONS_ON_BEHALF = 0x0000_0040;

	uint32 public constant FEATURE_ERC1363_TRANSFERS = 0x0000_0080;

	uint32 public constant FEATURE_ERC1363_APPROVALS = 0x0000_0100;

	uint32 public constant FEATURE_EIP2612_PERMITS = 0x0000_0200;

	uint32 public constant FEATURE_EIP3009_TRANSFERS = 0x0000_0400;

	uint32 public constant FEATURE_EIP3009_RECEPTIONS = 0x0000_0800;

	uint32 public constant ROLE_TOKEN_CREATOR = 0x0001_0000;

	uint32 public constant ROLE_TOKEN_DESTROYER = 0x0002_0000;

	uint32 public constant ROLE_ERC20_RECEIVER = 0x0004_0000;

	uint32 public constant ROLE_ERC20_SENDER = 0x0008_0000;

	bytes32 public constant DOMAIN_TYPEHASH = 0x8cad95687ba82c2ce50e74f7b754645e5117c3a5bec8151c0726d5857980a866;

	bytes32 public immutable override DOMAIN_SEPARATOR;

	bytes32 public constant DELEGATION_TYPEHASH = 0xff41620983935eb4d4a3c7384a066ca8c1d10cef9a5eca9eb97ca735cd14a755;

	bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

	bytes32 public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;

	bytes32 public constant RECEIVE_WITH_AUTHORIZATION_TYPEHASH = 0xd099cc98ef71107a616c4f0f941f04c322d8e254fe26b3c6668db87aae413de8;

	bytes32 public constant CANCEL_AUTHORIZATION_TYPEHASH = 0x158b0a9edf7a828aad02f63cd515c68ef2f50ba807396f6d12842833a1597429;

	event Minted(address indexed by, address indexed to, uint256 value);

	event Burnt(address indexed by, address indexed from, uint256 value);

	event Transfer(address indexed by, address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 oldValue, uint256 value);

	event DelegateChanged(address indexed source, address indexed from, address indexed to);

	event VotingPowerChanged(address indexed by, address indexed target, uint256 fromVal, uint256 toVal);

	constructor(address _initialHolder) {
		require(_initialHolder != address(0), "_initialHolder not set (zero address)");

		DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes("AliERC20v2")), block.chainid, address(this)));

		mint(_initialHolder, 10_000_000_000e18);
	}

	function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {

		return interfaceId == type(ERC165).interfaceId
		    || interfaceId == type(ERC20).interfaceId
		    || interfaceId == type(ERC1363).interfaceId
		    || interfaceId == type(EIP2612).interfaceId
		    || interfaceId == type(EIP3009).interfaceId;
	}


	function transferAndCall(address _to, uint256 _value) public override returns (bool) {

		return transferFromAndCall(msg.sender, _to, _value);
	}

	function transferAndCall(address _to, uint256 _value, bytes memory _data) public override returns (bool) {

		return transferFromAndCall(msg.sender, _to, _value, _data);
	}

	function transferFromAndCall(address _from, address _to, uint256 _value) public override returns (bool) {

		return transferFromAndCall(_from, _to, _value, "");
	}

	function transferFromAndCall(address _from, address _to, uint256 _value, bytes memory _data) public override returns (bool) {

		require(isFeatureEnabled(FEATURE_ERC1363_TRANSFERS), "ERC1363 transfers are disabled");

		unsafeTransferFrom(_from, _to, _value);

		_notifyTransferred(_from, _to, _value, _data, false);

		return true;
	}

	function approveAndCall(address _spender, uint256 _value) public override returns (bool) {

		return approveAndCall(_spender, _value, "");
	}

	function approveAndCall(address _spender, uint256 _value, bytes memory _data) public override returns (bool) {

		require(isFeatureEnabled(FEATURE_ERC1363_APPROVALS), "ERC1363 approvals are disabled");

		approve(_spender, _value);

		_notifyApproved(_spender, _value, _data);

		return true;
	}

	function _notifyTransferred(address _from, address _to, uint256 _value, bytes memory _data, bool allowEoa) private {

		if (!AddressUtils.isContract(_to)) {
			require(allowEoa, "EOA recipient");

			return;
		}

		bytes4 response = ERC1363Receiver(_to).onTransferReceived(msg.sender, _from, _value, _data);

		require(response == ERC1363Receiver(_to).onTransferReceived.selector, "invalid onTransferReceived response");
	}

	function _notifyApproved(address _spender, uint256 _value, bytes memory _data) private {

		require(AddressUtils.isContract(_spender), "EOA spender");

		bytes4 response = ERC1363Spender(_spender).onApprovalReceived(msg.sender, _value, _data);

		require(response == ERC1363Spender(_spender).onApprovalReceived.selector, "invalid onApprovalReceived response");
	}


	function balanceOf(address _owner) public view override returns (uint256 balance) {

		return tokenBalances[_owner];
	}

	function transfer(address _to, uint256 _value) public override returns (bool success) {

		return transferFrom(msg.sender, _to, _value);
	}

	function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {

		if(isFeatureEnabled(FEATURE_UNSAFE_TRANSFERS)
			|| isOperatorInRole(_to, ROLE_ERC20_RECEIVER)
			|| isSenderInRole(ROLE_ERC20_SENDER)) {
			unsafeTransferFrom(_from, _to, _value);
		}
		else {
			safeTransferFrom(_from, _to, _value, "");
		}

		return true;
	}

	function safeTransferFrom(address _from, address _to, uint256 _value, bytes memory _data) public returns (bool) {

		unsafeTransferFrom(_from, _to, _value);

		_notifyTransferred(_from, _to, _value, _data, true);

		return true;
	}

	function unsafeTransferFrom(address _from, address _to, uint256 _value) public {

		__transferFrom(msg.sender, _from, _to, _value);
	}

	function __transferFrom(address _by, address _from, address _to, uint256 _value) private {

		require(_from == _by && isFeatureEnabled(FEATURE_TRANSFERS)
		     || _from != _by && isFeatureEnabled(FEATURE_TRANSFERS_ON_BEHALF),
		        _from == _by? "transfers are disabled": "transfers on behalf are disabled");

		require(_from != address(0), "transfer from the zero address");

		require(_to != address(0), "transfer to the zero address");

		require(_from != _to, "sender and recipient are the same (_from = _to)");

		require(_to != address(this), "invalid recipient (transfer to the token smart contract itself)");

		if(_value == 0) {
			emit Transfer(_from, _to, _value);

			return;
		}


		if(_from != _by) {
			uint256 _allowance = transferAllowances[_from][_by];

			require(_allowance >= _value, "transfer amount exceeds allowance");

			if(_allowance < type(uint256).max) {
				_allowance -= _value;

				transferAllowances[_from][_by] = _allowance;

				emit Approval(_from, _by, _allowance + _value, _allowance);

				emit Approval(_from, _by, _allowance);
			}
		}

		require(tokenBalances[_from] >= _value, "transfer amount exceeds balance");

		tokenBalances[_from] -= _value;

		tokenBalances[_to] += _value;

		__moveVotingPower(_by, votingDelegates[_from], votingDelegates[_to], _value);

		emit Transfer(_by, _from, _to, _value);

		emit Transfer(_from, _to, _value);
	}

	function approve(address _spender, uint256 _value) public override returns (bool success) {

		__approve(msg.sender, _spender, _value);

		return true;
	}

	function __approve(address _owner, address _spender, uint256 _value) private {

		require(_spender != address(0), "approve to the zero address");

		uint256 _oldValue = transferAllowances[_owner][_spender];

		transferAllowances[_owner][_spender] = _value;

		emit Approval(_owner, _spender, _oldValue, _value);

		emit Approval(_owner, _spender, _value);
	}

	function allowance(address _owner, address _spender) public view override returns (uint256 remaining) {

		return transferAllowances[_owner][_spender];
	}



	function increaseAllowance(address _spender, uint256 _value) public returns (bool) {

		uint256 currentVal = transferAllowances[msg.sender][_spender];

		unchecked {
			require(currentVal + _value > currentVal, "zero value approval increase or arithmetic overflow");
		}

		return approve(_spender, currentVal + _value);
	}

	function decreaseAllowance(address _spender, uint256 _value) public returns (bool) {

		uint256 currentVal = transferAllowances[msg.sender][_spender];

		require(_value > 0, "zero value approval decrease");

		require(currentVal >= _value, "ERC20: decreased allowance below zero");

		return approve(_spender, currentVal - _value);
	}



	function mint(address _to, uint256 _value) public {

		require(isSenderInRole(ROLE_TOKEN_CREATOR), "access denied");

		require(_to != address(0), "zero address");

		unchecked {
			require(totalSupply + _value > totalSupply, "zero value or arithmetic overflow");
		}

		require(totalSupply + _value <= type(uint192).max, "total supply overflow (uint192)");

		totalSupply += _value;

		tokenBalances[_to] += _value;

		__updateHistory(totalSupplyHistory, add, _value);

		__moveVotingPower(msg.sender, address(0), votingDelegates[_to], _value);

		emit Minted(msg.sender, _to, _value);

		emit Transfer(msg.sender, address(0), _to, _value);

		emit Transfer(address(0), _to, _value);
	}

	function burn(address _from, uint256 _value) public {

		if(!isSenderInRole(ROLE_TOKEN_DESTROYER)) {
			require(_from == msg.sender && isFeatureEnabled(FEATURE_OWN_BURNS)
			     || _from != msg.sender && isFeatureEnabled(FEATURE_BURNS_ON_BEHALF),
			        _from == msg.sender? "burns are disabled": "burns on behalf are disabled");

			if(_from != msg.sender) {
				uint256 _allowance = transferAllowances[_from][msg.sender];

				require(_allowance >= _value, "burn amount exceeds allowance");

				if(_allowance < type(uint256).max) {
					_allowance -= _value;

					transferAllowances[_from][msg.sender] = _allowance;

					emit Approval(msg.sender, _from, _allowance + _value, _allowance);

					emit Approval(_from, msg.sender, _allowance);
				}
			}
		}


		require(_value != 0, "zero value burn");

		require(_from != address(0), "burn from the zero address");

		require(tokenBalances[_from] >= _value, "burn amount exceeds balance");

		tokenBalances[_from] -= _value;

		totalSupply -= _value;

		__updateHistory(totalSupplyHistory, sub, _value);

		__moveVotingPower(msg.sender, votingDelegates[_from], address(0), _value);

		emit Burnt(msg.sender, _from, _value);

		emit Transfer(msg.sender, _from, address(0), _value);

		emit Transfer(_from, address(0), _value);
	}



	function permit(address _owner, address _spender, uint256 _value, uint256 _exp, uint8 v, bytes32 r, bytes32 s) public override {

		require(isFeatureEnabled(FEATURE_EIP2612_PERMITS), "EIP2612 permits are disabled");

		address signer = __deriveSigner(abi.encode(PERMIT_TYPEHASH, _owner, _spender, _value, nonces[_owner]++, _exp), v, r, s);

		require(signer == _owner, "invalid signature");
		require(block.timestamp < _exp, "signature expired");

		__approve(_owner, _spender, _value);
	}



	function authorizationState(address _authorizer, bytes32 _nonce) public override view returns (bool) {

		return usedNonces[_authorizer][_nonce];
	}

	function transferWithAuthorization(
		address _from,
		address _to,
		uint256 _value,
		uint256 _validAfter,
		uint256 _validBefore,
		bytes32 _nonce,
		uint8 v,
		bytes32 r,
		bytes32 s
	) public override {

		require(isFeatureEnabled(FEATURE_EIP3009_TRANSFERS), "EIP3009 transfers are disabled");

		address signer = __deriveSigner(abi.encode(TRANSFER_WITH_AUTHORIZATION_TYPEHASH, _from, _to, _value, _validAfter, _validBefore, _nonce), v, r, s);

		require(signer == _from, "invalid signature");
		require(block.timestamp > _validAfter, "signature not yet valid");
		require(block.timestamp < _validBefore, "signature expired");

		__useNonce(_from, _nonce, false);

		__transferFrom(signer, _from, _to, _value);
	}

	function receiveWithAuthorization(
		address _from,
		address _to,
		uint256 _value,
		uint256 _validAfter,
		uint256 _validBefore,
		bytes32 _nonce,
		uint8 v,
		bytes32 r,
		bytes32 s
	) public override {

		require(isFeatureEnabled(FEATURE_EIP3009_RECEPTIONS), "EIP3009 receptions are disabled");

		address signer = __deriveSigner(abi.encode(RECEIVE_WITH_AUTHORIZATION_TYPEHASH, _from, _to, _value, _validAfter, _validBefore, _nonce), v, r, s);

		require(signer == _from, "invalid signature");
		require(block.timestamp > _validAfter, "signature not yet valid");
		require(block.timestamp < _validBefore, "signature expired");
		require(_to == msg.sender, "access denied");

		__useNonce(_from, _nonce, false);

		__transferFrom(signer, _from, _to, _value);
	}

	function cancelAuthorization(
		address _authorizer,
		bytes32 _nonce,
		uint8 v,
		bytes32 r,
		bytes32 s
	) public override {

		address signer = __deriveSigner(abi.encode(CANCEL_AUTHORIZATION_TYPEHASH, _authorizer, _nonce), v, r, s);

		require(signer == _authorizer, "invalid signature");

		__useNonce(_authorizer, _nonce, true);
	}

	function __deriveSigner(bytes memory abiEncodedTypehash, uint8 v, bytes32 r, bytes32 s) private view returns(address) {

		bytes32 hashStruct = keccak256(abiEncodedTypehash);

		bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hashStruct));

		address signer = ECDSA.recover(digest, v, r, s);

		return signer;
	}

	function __useNonce(address _authorizer, bytes32 _nonce, bool _cancellation) private {

		require(!usedNonces[_authorizer][_nonce], "invalid nonce");

		usedNonces[_authorizer][_nonce] = true;

		if(_cancellation) {
			emit AuthorizationCanceled(_authorizer, _nonce);
		}
		else {
			emit AuthorizationUsed(_authorizer, _nonce);
		}
	}



	function votingPowerOf(address _of) public view returns (uint256) {

		KV[] storage history = votingPowerHistory[_of];

		return history.length == 0? 0: history[history.length - 1].v;
	}

	function votingPowerAt(address _of, uint256 _blockNum) public view returns (uint256) {

		require(_blockNum < block.number, "block not yet mined"); // Compound msg not yet determined

		return __binaryLookup(votingPowerHistory[_of], _blockNum);
	}

	function votingPowerHistoryOf(address _of) public view returns(KV[] memory) {

		return votingPowerHistory[_of];
	}

	function votingPowerHistoryLength(address _of) public view returns(uint256) {

		return votingPowerHistory[_of].length;
	}

	function totalSupplyAt(uint256 _blockNum) public view returns(uint256) {

		require(_blockNum < block.number, "block not yet mined");

		return __binaryLookup(totalSupplyHistory, _blockNum);
	}

	function entireSupplyHistory() public view returns(KV[] memory) {

		return totalSupplyHistory;
	}

	function totalSupplyHistoryLength() public view returns(uint256) {

		return totalSupplyHistory.length;
	}

	function delegate(address _to) public {

		require(isFeatureEnabled(FEATURE_DELEGATIONS), "delegations are disabled");
		__delegate(msg.sender, _to);
	}

	function __delegate(address _from, address _to) private {

		address _fromDelegate = votingDelegates[_from];

		uint256 _value = tokenBalances[_from];

		votingDelegates[_from] = _to;

		__moveVotingPower(_from, _fromDelegate, _to, _value);

		emit DelegateChanged(_from, _fromDelegate, _to);
	}

	function delegateWithAuthorization(address _to, bytes32 _nonce, uint256 _exp, uint8 v, bytes32 r, bytes32 s) public {

		require(isFeatureEnabled(FEATURE_DELEGATIONS_ON_BEHALF), "delegations on behalf are disabled");

		address signer = __deriveSigner(abi.encode(DELEGATION_TYPEHASH, _to, _nonce, _exp), v, r, s);

		require(block.timestamp < _exp, "signature expired"); // Compound msg

		__useNonce(signer, _nonce, false);

		__delegate(signer, _to);
	}

	function __moveVotingPower(address _by, address _from, address _to, uint256 _value) private {

		if(_from == _to || _value == 0) {
			return;
		}

		if(_from != address(0)) {
			KV[] storage _h = votingPowerHistory[_from];

			(uint256 _fromVal, uint256 _toVal) = __updateHistory(_h, sub, _value);

			emit VotingPowerChanged(_by, _from, _fromVal, _toVal);
		}

		if(_to != address(0)) {
			KV[] storage _h = votingPowerHistory[_to];

			(uint256 _fromVal, uint256 _toVal) = __updateHistory(_h, add, _value);

			emit VotingPowerChanged(_by, _to, _fromVal, _toVal);
		}
	}

	function __updateHistory(
		KV[] storage _h,
		function(uint256,uint256) pure returns(uint256) op,
		uint256 _delta
	) private returns(uint256 _fromVal, uint256 _toVal) {

		_fromVal = _h.length == 0? 0: _h[_h.length - 1].v;
		_toVal = op(_fromVal, _delta);

		if(_h.length != 0 && _h[_h.length - 1].k == block.number) {
			_h[_h.length - 1].v = uint192(_toVal);
		}
		else {
			_h.push(KV(uint64(block.number), uint192(_toVal)));
		}
	}

	function __binaryLookup(KV[] storage _h, uint256 _k) private view returns(uint256) {

		if(_h.length == 0) {
			return 0;
		}

		if(_h[_h.length - 1].k <= _k) {
			return _h[_h.length - 1].v;
		}

		if(_h[0].k > _k) {
			return 0;
		}

		uint256 i = 0;

		uint256 j = _h.length - 1;

		while(j > i) {
			uint256 k = j - (j - i) / 2;

			KV memory kv = _h[k];

			if(kv.k == _k) {
				return kv.v;
			}
			else if (kv.k < _k) {
				i = k;
			}
			else {
				j = k - 1;
			}
		}

		return _h[i].v;
	}

	function add(uint256 a, uint256 b) private pure returns(uint256) {

		return a + b;
	}

	function sub(uint256 a, uint256 b) private pure returns(uint256) {

		return a - b;
	}


}