
pragma solidity ^0.8.0;

interface GeneralERC20 {

	function transfer(address to, uint256 amount) external;

	function transferFrom(address from, address to, uint256 amount) external;

	function approve(address spender, uint256 amount) external;

	function balanceOf(address spender) external view returns (uint);

	function allowance(address owner, address spender) external view returns (uint);

}

library SafeERC20 {

	function checkSuccess()
		private
		pure
		returns (bool)
	{

		uint256 returnValue = 0;

		assembly {
			switch returndatasize()

			case 0x0 {
				returnValue := 1
			}

			case 0x20 {
				returndatacopy(0x0, 0x0, 0x20)

				returnValue := mload(0x0)
			}

			default { }
		}

		return returnValue != 0;
	}

	function transfer(address token, address to, uint256 amount) internal {

		GeneralERC20(token).transfer(to, amount);
		require(checkSuccess(), "SafeERC20: transfer failed");
	}

	function transferFrom(address token, address from, address to, uint256 amount) internal {

		GeneralERC20(token).transferFrom(from, to, amount);
		require(checkSuccess(), "SafeERC20: transferFrom failed");
	}

	function approve(address token, address spender, uint256 amount) internal {

		GeneralERC20(token).approve(spender, amount);
		require(checkSuccess(), "SafeERC20: approve failed");
	}
}

library SignatureValidator {

	enum SignatureMode {
		NO_SIG,
		EIP712,
		GETH,
		TREZOR,
		ADEX
	}

	function recoverAddr(bytes32 hash, bytes32[3] memory signature) internal pure returns (address) {

		SignatureMode mode = SignatureMode(uint8(signature[0][0]));

		if (mode == SignatureMode.NO_SIG) {
			return address(0x0);
		}

		uint8 v = uint8(signature[0][1]);

		if (mode == SignatureMode.GETH) {
			hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
		} else if (mode == SignatureMode.TREZOR) {
			hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n\x20", hash));
		} else if (mode == SignatureMode.ADEX) {
			hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n108By signing this message, you acknowledge signing an AdEx bid with the hash:\n", hash));
		}

		return ecrecover(hash, v, signature[1], signature[2]);
	}

	function isValid(bytes32 hash, address signer, bytes32[3] memory signature) internal pure returns (bool) {

		return recoverAddr(hash, signature) == signer;
	}

	function recoverAddrBytes(bytes32 hash, bytes memory signature) internal pure returns (address) {

		require(signature.length == 65, "SignatureValidator: invalid signature length");

		bytes32 r;
		bytes32 s;
		uint8 v;
		assembly {
			r := mload(add(signature, 0x20))
			s := mload(add(signature, 0x40))
			v := byte(0, mload(add(signature, 0x60)))
		}

		require(
			uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
			"SignatureValidator: invalid signature 's' value"
		);
		require(v == 27 || v == 28, "SignatureValidator: invalid signature 'v' value");
		hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
		return ecrecover(hash, v, r, s);
	}
}


contract Identity {


	mapping (address => bool) public privileges;
	uint public nonce = 0;

	event LogPrivilegeChanged(address indexed addr, bool priv);

	struct Transaction {
		address identityContract;
		uint nonce;
		address feeTokenAddr;
		uint feeAmount;
		address to;
		uint value;
		bytes data;
	}

	constructor(address[] memory addrs) {
		uint len = addrs.length;
		for (uint i=0; i<len; i++) {
			privileges[addrs[i]] = true;
			emit LogPrivilegeChanged(addrs[i], true);
		}
	}

	receive() external payable {}

	fallback() external payable {}

	function setAddrPrivilege(address addr, bool priv)
		external
	{

		require(msg.sender == address(this), 'ONLY_IDENTITY_CAN_CALL');
		privileges[addr] = priv;
		emit LogPrivilegeChanged(addr, priv);
	}

	function tipMiner(uint amount)
		external
	{

		require(msg.sender == address(this), 'ONLY_IDENTITY_CAN_CALL');
		executeCall(block.coinbase, amount, new bytes(0));
	}

	function execute(Transaction[] memory txns, bytes32[3][] memory signatures)
		public
	{

		require(txns.length > 0, 'MUST_PASS_TX');
		address feeTokenAddr = txns[0].feeTokenAddr;
		uint feeAmount = 0;
		uint len = txns.length;
		for (uint i=0; i<len; i++) {
			Transaction memory txn = txns[i];
			require(txn.identityContract == address(this), 'TRANSACTION_NOT_FOR_CONTRACT');
			require(txn.feeTokenAddr == feeTokenAddr, 'EXECUTE_NEEDS_SINGLE_TOKEN');
			require(txn.nonce == nonce, 'WRONG_NONCE');

			bytes32 hash = keccak256(abi.encode(txn.identityContract, txn.nonce, txn.feeTokenAddr, txn.feeAmount, txn.to, txn.value, txn.data));
			address signer = SignatureValidator.recoverAddr(hash, signatures[i]);

			require(privileges[signer] == true, 'INSUFFICIENT_PRIVILEGE_TRANSACTION');

			nonce = nonce + 1;
			feeAmount = feeAmount + txn.feeAmount;

			executeCall(txn.to, txn.value, txn.data);
			require(privileges[signer] == true, 'PRIVILEGE_NOT_DOWNGRADED');
		}
		if (feeAmount > 0) {
			SafeERC20.transfer(feeTokenAddr, msg.sender, feeAmount);
		}
	}

	function executeBySender(Transaction[] memory txns)
		public
	{

		require(privileges[msg.sender] == true || msg.sender == address(this), 'INSUFFICIENT_PRIVILEGE_SENDER');
		uint len = txns.length;
		for (uint i=0; i<len; i++) {
			Transaction memory txn = txns[i];
			executeCall(txn.to, txn.value, txn.data);
		}
		require(privileges[msg.sender] == true, 'PRIVILEGE_NOT_DOWNGRADED');
	}

	function executeCall(address to, uint256 value, bytes memory data)
		internal
	{

		assembly {
			let result := call(gas(), to, value, add(data, 0x20), mload(data), 0, 0)

			switch result case 0 {
				let size := returndatasize()
				let ptr := mload(0x40)
				returndatacopy(ptr, 0, size)
				revert(ptr, size)
			}
			default {}
		}
	}

	function isValidSignature(bytes32 hash, bytes calldata signature) external view returns (bytes4) {

		if (privileges[SignatureValidator.recoverAddrBytes(hash, signature)]) {
			return 0x1626ba7e;
		} else {
			return 0xffffffff;
		}
	}
}