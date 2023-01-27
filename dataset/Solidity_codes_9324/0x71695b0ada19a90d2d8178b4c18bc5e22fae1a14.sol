pragma solidity >= 0.4.22 <0.9.0;

library console {

	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {

		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {

		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
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
}// UNLICENSED
pragma solidity ^0.8.0;

contract EtherReceiver {


    receive() external payable {}

    fallback() external payable {}

    function getBalance() public view returns (uint256) {

        return address(this).balance;
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
}// UNLICENSED
pragma solidity ^0.8.0;

library FoundationLib {

    uint256 constant RAKE_BPS_V0 = 2000;
}// UNLICENSED
pragma solidity ^0.8.0;



contract Foundation is EtherReceiver, Ownable {

    uint256 m_rake_bps;

    constructor() {
        m_rake_bps = FoundationLib.RAKE_BPS_V0;
    }

    function getOurRakeBps() public view returns (uint256) {

        return m_rake_bps;
    }

    function setRakeBps(uint256 _val) public onlyOwner {

        m_rake_bps = _val;
    }

    function calculateFoundationRakeForSalePrice(uint256 _sale_price)
        public
        view
        returns (uint256)
    {

        return (_sale_price * m_rake_bps) / 10000;
    }

    event FundsWithdrawn(address indexed caller, uint256 amount);

    function withdrawFunds() external payable onlyOwner {

        uint256 amount = getBalance();
        console.log("In[withdrawFunds] amount[%d]", amount);
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "failed withdraw eth");

        emit FundsWithdrawn(msg.sender, amount);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {

    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {

        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}


    uint256[44] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC721URIStorageUpgradeable is Initializable, ERC721Upgradeable {
    function __ERC721URIStorage_init() internal onlyInitializing {
    }

    function __ERC721URIStorage_init_unchained() internal onlyInitializing {
    }
    using StringsUpgradeable for uint256;

    mapping(uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// UNLICENSED
pragma solidity ^0.8.0;



abstract contract IAthleteSponsorshipNftUpgradeable is
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable
{
    uint256 m_token_id;
    mapping(uint256 => uint256) m_token_to_sponsorship_origination;
    mapping(uint256 => bool) m_token_is_upgraded;

    address m_approved_caller;

    function __IAthleteSponsorshipNft_init(
        string memory _name,
        string memory _symbol
    ) internal onlyInitializing {
        __IAthleteSponsorshipNft_init_unchained(_name, _symbol);
    }

    function __IAthleteSponsorshipNft_init_unchained(
        string memory _name,
        string memory _symbol
    ) internal onlyInitializing {
        __ERC721_init(_name, _symbol);
        __Ownable_init();
        m_approved_caller = address(0);
    }

    modifier isValidTokenId(uint256 _id) {
        require(_id > 0, "bad token val");
        require(_exists(_id), "token DNE");
        _;
    }

    modifier allowedCaller() {
        require(
            msg.sender == owner() || msg.sender == m_approved_caller,
            "INVALID CALLER"
        );
        _;
    }

    function setApprovalForCaller(address _operator)
        external
        virtual
        onlyOwner
    {
        console.log(
            "In[setApprovalForCaller] _operator[%s] owner[%s] m_approved_caller[%s]",
            _operator,
            owner(),
            m_approved_caller
        );
        m_approved_caller = _operator;
    }

    function fetchMySponsorshipNfts()
        external
        view
        virtual
        returns (uint256[] memory)
    {
        uint256 token_count = balanceOf(msg.sender);
        console.log(
            "In[fetchMySponsorshipNfts] token_count[%d] msg.sender[%s]",
            token_count,
            msg.sender
        );
        uint256[] memory token_ids = new uint256[](token_count);

        if (token_count == 0) return token_ids;

        uint256 index = 0;
        for (uint256 id = 1; id <= m_token_id; id++) {
            if (ownerOf(id) == msg.sender) {
                token_ids[index] = id;
                index++;
            }
        }
        return token_ids;
    }

    function getTokenCount() external view virtual returns (uint256) {
        return m_token_id;
    }

    function getTokenOwner(uint256 _token_id)
        external
        view
        virtual
        isValidTokenId(_token_id)
        returns (address)
    {
        return ownerOf(_token_id);
    }

    function isSponsorshipUpgraded(uint256 _token_id)
        external
        view
        virtual
        returns (bool)
    {
        return m_token_is_upgraded[_token_id];
    }

    function setSponsorshipUpgraded(uint256 _token_id, bool _val)
        public
        virtual
    {
        m_token_is_upgraded[_token_id] = _val;
    }

    function getTokenOriginationId(uint256 _token_id)
        public
        view
        virtual
        returns (uint256)
    {
        return m_token_to_sponsorship_origination[_token_id];
    }

    function mintSponsorship(
        string calldata _token_uri,
        uint256 _origination_id,
        address _to
    ) public virtual allowedCaller returns (uint256) {
        require(_origination_id > 0, "MINT: BAD ORIG ID");

        m_token_id++;

        m_token_to_sponsorship_origination[m_token_id] = _origination_id;
        m_token_is_upgraded[m_token_id] = false;

        console.log(
            "IN[AthleteSponsorshipNft::initSponsorship] new_token_id[%d] _token_uri[%s] _to[%s]",
            m_token_id,
            _token_uri,
            _to
        );

        _mint(_to, m_token_id);
        assert(ownerOf(m_token_id) == _to);

        _setTokenURI(m_token_id, _token_uri);

        return m_token_id;
    }

    function upgradeSponsorshipUri(
        uint256 _token_id,
        string calldata _signature_uri
    ) public virtual allowedCaller {
        _setTokenURI(_token_id, _signature_uri);
    }

    function burnOnRefund(uint256 _token_id) public virtual allowedCaller {
        _burn(_token_id);
    }

    function getUpgradeEligibleTokens()
        external
        view
        virtual
        returns (uint256[] memory token_ids)
    {
        uint256 eligible_token_count = 0;
        for (uint256 id = 1; id <= m_token_id; id++) {
            if (!m_token_is_upgraded[id]) eligible_token_count++;
        }

        token_ids = new uint256[](eligible_token_count);

        if (eligible_token_count > 0) {
            uint256 index = 0;
            for (uint256 id = 1; id <= m_token_id; id++) {
                if (!m_token_is_upgraded[id]) {
                    token_ids[index] = id;
                    index++;
                }
            }
            assert(index == eligible_token_count);
        }
    }
}// UNLICENSED
pragma solidity ^0.8.0;

library AthleteLib {

    enum Sport {
        None,
        BasketballMens,
        BasketballWomens
    }

    enum PlayerPosition {
        None,
        Guard, // basketball - begin
        Forward,
        Center // basketball - finish
    }

    struct Athlete {
        bytes32 player_name;
        Sport sport;
        uint8 player_number;
        PlayerPosition player_position;
    }
}// UNLICENSED
pragma solidity ^0.8.0;

contract DbToOnChainMapping {

    mapping(uint256 => uint256) internal m_db_to_chain_id;
    mapping(uint256 => uint256) internal m_chain_to_db_id;

    modifier isValidDbId(uint256 _db_id) {

        require(_db_id > 0, "invalid db id");
        _;
    }

    function dbExistsOnChain(uint256 _db_id)
        public
        view
        isValidDbId(_db_id)
        returns (bool)
    {

        return m_db_to_chain_id[_db_id] > 0;
    }

    function addDbToOnChainMapping(uint256 _db_id, uint256 _chain_id)
        public
        isValidDbId(_db_id)
    {

        require(_chain_id > 0, "invalid chain id");
        require(m_db_to_chain_id[_db_id] == 0, "db entry already exists");

        m_db_to_chain_id[_db_id] = _chain_id;
        m_chain_to_db_id[_chain_id] = _db_id;
    }

    function getChainId(uint256 _db_id) public view returns (uint256) {

        return m_db_to_chain_id[_db_id];
    }

    function getDbIdFromChainId(uint256 _chain_id)
        public
        view
        returns (uint256)
    {

        return m_chain_to_db_id[_chain_id];
    }
}// UNLICENSED
pragma solidity ^0.8.0;



contract AthleteMap {

    uint256 m_athlete_id;
    mapping(uint256 => AthleteLib.Athlete) internal m_id_to_athlete;
    DbToOnChainMapping m_athlete_db_to_chain_id;

    constructor() {
        m_athlete_id = 0;
        m_athlete_db_to_chain_id = new DbToOnChainMapping();
    }

    modifier isValidAthleteId(uint256 _athlete_id) {

        require(_athlete_id > 0, "bad ath id");
        require(
            m_id_to_athlete[_athlete_id].sport != AthleteLib.Sport.None,
            "ath id dne"
        );
        _;
    }

    function getAthleteDbIdFromChainId(uint256 _chain_id)
        external
        view
        returns (uint256)
    {

        return m_athlete_db_to_chain_id.getDbIdFromChainId(_chain_id);
    }

    function getAthleteIdFromDbId(uint256 _db_id)
        public
        view
        returns (uint256)
    {

        return m_athlete_db_to_chain_id.getChainId(_db_id);
    }

    function dbAthleteExistsOnChain(uint256 _db_id) public view returns (bool) {

        return m_athlete_db_to_chain_id.dbExistsOnChain(_db_id);
    }

    function addAthlete(
        uint256 _db_id,
        bytes32 _name,
        AthleteLib.Sport _sport,
        uint8 _player_number,
        AthleteLib.PlayerPosition _player_position
    ) public returns (uint256) {

        require(
            !dbAthleteExistsOnChain(_db_id),
            "on-chain entry exists for db id"
        );

        m_athlete_id++;

        m_athlete_db_to_chain_id.addDbToOnChainMapping(_db_id, m_athlete_id);

        m_id_to_athlete[m_athlete_id] = AthleteLib.Athlete({
            player_name: _name,
            sport: _sport,
            player_number: _player_number,
            player_position: _player_position
        });

        return m_athlete_id;
    }

    function getAthleteCount() public view returns (uint256) {

        return m_athlete_id;
    }

    function getAthlete(uint256 _on_chain_id)
        external
        view
        isValidAthleteId(_on_chain_id)
        returns (AthleteLib.Athlete memory)
    {

        return m_id_to_athlete[_on_chain_id];
    }
}// UNLICENSED
pragma solidity ^0.8.0;

library AthleteSponsorshipUtils {

    enum NftType {
        None,
        Weekend1,
        Weekend2,
        Weekend3,
        Origin
    }

    struct SponsorshipRoundInfo {
        uint16 season;
        NftType nft_type;
        bytes32 location;
        uint16 capacity;
        bool is_open;
    }

    struct AthleteSponsorship {
        uint256 athlete_id;
        uint256 round_id;
        uint16 claimed;
        uint256 funds_committed;
        bool funds_claimed_by_athlete;
        bool refund_eligible;
    }

    struct SponsorshipOrigination {
        uint256 price;
        uint256 athlete_sponsorship_id;
        uint16 serial;
    }
}// UNLICENSED
pragma solidity ^0.8.0;



contract SponsorshipRounds {


    uint256 m_id;
    DbToOnChainMapping m_round_db_to_chain_id;

    mapping(uint256 => AthleteSponsorshipUtils.SponsorshipRoundInfo)
        internal m_id_to_round_info;

    mapping(uint256 => mapping(uint256 => mapping(string => mapping(string => uint256))))
        internal m_base_attributes;


    constructor() {
        m_id = 0;
        m_round_db_to_chain_id = new DbToOnChainMapping();
    }

    function isValidRoundChainId(uint256 _chain_id) public view returns (bool) {

        return m_id_to_round_info[_chain_id].season > 0;
    }

    modifier modIsValidRoundChainId(uint256 _chain_id) {

        require(m_id_to_round_info[_chain_id].season > 0, "bad chain id");
        _;
    }


    function getSponsorshipRoundIdFromDbId(uint256 _db_id)
        public
        view
        returns (uint256)
    {

        return m_round_db_to_chain_id.getChainId(_db_id);
    }

    function getRoundDbIdFromChainId(uint256 _chain_id)
        external
        view
        returns (uint256)
    {

        return m_round_db_to_chain_id.getDbIdFromChainId(_chain_id);
    }

    function dbSponsorshipRoundExistsOnChain(uint256 _db_id)
        public
        view
        returns (bool)
    {

        return m_round_db_to_chain_id.dbExistsOnChain(_db_id);
    }

    function getSponsorshipRoundCount() external view returns (uint256) {

        return m_id;
    }

    function closeDbSponsorshipRound(uint256 _db_id) external {

        require(_db_id > 0, "bad db id");
        closeSponsorshipRound(getSponsorshipRoundIdFromDbId(_db_id));
    }

    function closeSponsorshipRound(uint256 _chain_id)
        internal
        modIsValidRoundChainId(_chain_id)
    {

        m_id_to_round_info[_chain_id].is_open = false;
    }

    function initSponsorshipRound(
        uint256 _db_id,
        uint16 _season,
        uint256 _type,
        bytes32 _location,
        uint16 _capacity
    ) public returns (uint256) {

        console.log("In[initSponsorshipRound] entering...");
        if (dbSponsorshipRoundExistsOnChain(_db_id)) {
            uint256 on_chain_id = getSponsorshipRoundIdFromDbId(_db_id);
            assert(m_id_to_round_info[on_chain_id].season > 0);
            console.log(
                "In[initSponsorshipRound] db_id[%d] exists on-chain with id[%d]...returning",
                _db_id,
                on_chain_id
            );
            return on_chain_id;
        }

        AthleteSponsorshipUtils.NftType type_enum = AthleteSponsorshipUtils
            .NftType(_type);
        require(
            type_enum != AthleteSponsorshipUtils.NftType.None,
            "invalid nft type"
        );

        m_id += 1;

        m_id_to_round_info[m_id] = AthleteSponsorshipUtils
            .SponsorshipRoundInfo({
                season: _season,
                nft_type: type_enum,
                capacity: _capacity,
                location: _location,
                is_open: true
            });

        m_round_db_to_chain_id.addDbToOnChainMapping(_db_id, m_id);

        console.log("In[initSponsorshipRound] leaving...new m_id[%d]", m_id);

        console.log("In[initSponsorshipRound] leaving...returning", m_id);

        return m_id;
    }
}// UNLICENSED
pragma solidity ^0.8.0;



contract AthleteSponsorshipMap is AthleteMap, SponsorshipRounds, Ownable {


    uint256 private m_athlete_sponsorship_id;
    mapping(uint256 => AthleteSponsorshipUtils.AthleteSponsorship)
        internal m_id_to_athlete_sponsorship;

    uint256 private m_sponsor_origination_id;
    mapping(uint256 => AthleteSponsorshipUtils.SponsorshipOrigination) m_id_to_sponsorship_origination;

    mapping(uint256 => mapping(uint256 => uint256)) m_sponsor_round_to_athlete_to_athlete_sponsorship;


    constructor() {
        m_athlete_sponsorship_id = 0;
    }


    function isValidSponsorAttributes(uint256 _id) public view returns (bool) {

        return m_id_to_sponsorship_origination[_id].athlete_sponsorship_id > 0;
    }

    modifier modIsValidSponsorAttributesId(uint256 _id) {

        require(isValidSponsorAttributes(_id), "invalid sponsor attributes id");
        _;
    }

    modifier isValidAthleteSponsorshipId(uint256 _id) {

        require(
            m_id_to_athlete_sponsorship[_id].athlete_id > 0,
            "invalid athlete sponsorship id"
        );
        _;
    }



    event InitAthleteSponsorship(uint256 id);


    function getAthleteSponsorshipCount() public view returns (uint256) {

        return m_athlete_sponsorship_id;
    }

    function initAthleteSponsorship(
        uint256 _athlete_id,
        uint256 _sponsorship_round_id,
        uint256 _funds_for_athlete
    )
        internal
        isValidAthleteId(_athlete_id)
        returns (
            uint256 new_athlete_sponsorship_id,
            uint256 new_sponsor_attributes_id
        )
    {

        require(
            m_sponsor_round_to_athlete_to_athlete_sponsorship[
                _sponsorship_round_id
            ][_athlete_id] == 0,
            "sponsorship already exists"
        );
        require(isValidRoundChainId(_sponsorship_round_id), "bad round id");

        m_athlete_sponsorship_id++;

        console.log(
            "IN[ContainerAthlete::initAthleteSponsorship]: _athlete_id[%d] _base_attributes_id[%d] sponsorship_id[%d]",
            _athlete_id,
            _sponsorship_round_id,
            m_athlete_sponsorship_id
        );

        m_id_to_athlete_sponsorship[
            m_athlete_sponsorship_id
        ] = AthleteSponsorshipUtils.AthleteSponsorship({
            athlete_id: _athlete_id,
            round_id: _sponsorship_round_id,
            claimed: 1,
            funds_committed: _funds_for_athlete,
            funds_claimed_by_athlete: false,
            refund_eligible: false
        });

        m_sponsor_origination_id++;

        m_id_to_sponsorship_origination[
            m_sponsor_origination_id
        ] = AthleteSponsorshipUtils.SponsorshipOrigination({
            price: msg.value,
            athlete_sponsorship_id: m_athlete_sponsorship_id,
            serial: 1
        });

        m_sponsor_round_to_athlete_to_athlete_sponsorship[
            _sponsorship_round_id
        ][_athlete_id] = m_athlete_sponsorship_id;

        return (m_athlete_sponsorship_id, m_sponsor_origination_id);
    }

    function getAthleteSponsorshipId(
        uint256 _ath_id,
        uint256 _sponsorship_round_id
    ) public view returns (uint256) {

        return
            m_sponsor_round_to_athlete_to_athlete_sponsorship[
                _sponsorship_round_id
            ][_ath_id];
    }

    function _athleteSponsorshipHasCapacity(uint256 _athlete_sponsorship_id)
        internal
        view
        isValidAthleteSponsorshipId(_athlete_sponsorship_id)
        returns (bool)
    {

        console.log(
            "IN[ContainerAthlete::_athleteSponsorshipHasCapacity]: _athlete_sponsorship_id[%d]",
            _athlete_sponsorship_id
        );

        (uint256 capacity, uint256 claimed) = getAthleteSponsorshipNumbers(
            _athlete_sponsorship_id
        );

        console.log(
            "IN[ContainerAthlete::_athleteSponsorshipHasCapacity]: claimed[%d], capacity[%d]",
            claimed,
            capacity
        );

        return claimed < capacity;
    }

    function addToAthleteSponsorship(
        uint256 _athlete_sponsorship_id,
        uint256 _funds_for_athlete
    )
        internal
        isValidAthleteSponsorshipId(_athlete_sponsorship_id)
        returns (uint256)
    {

        console.log(
            "IN[ContainerAthlete::addToAthleteSponsorship]: _athlete_sponsorship_id[%d] _price[%d]",
            _athlete_sponsorship_id,
            _funds_for_athlete
        );

        require(
            _athleteSponsorshipHasCapacity(_athlete_sponsorship_id),
            "no capacity"
        );
        require(
            m_id_to_round_info[
                m_id_to_athlete_sponsorship[_athlete_sponsorship_id].round_id
            ].is_open,
            "not open"
        );

        AthleteSponsorshipUtils.AthleteSponsorship
            storage sponsorship = m_id_to_athlete_sponsorship[
                _athlete_sponsorship_id
            ];

        console.log(
            "IN[ContainerAthlete::_fanSubmitsSponsorshipForAthlete]: sponsorship: ath_id[%d] claimed[%d] funds_committed[%d]",
            sponsorship.athlete_id,
            sponsorship.claimed,
            sponsorship.funds_committed
        );

        sponsorship.claimed++;

        sponsorship.funds_committed += _funds_for_athlete;

        m_sponsor_origination_id++;

        m_id_to_sponsorship_origination[
            m_sponsor_origination_id
        ] = AthleteSponsorshipUtils.SponsorshipOrigination({
            price: _funds_for_athlete,
            athlete_sponsorship_id: _athlete_sponsorship_id,
            serial: sponsorship.claimed
        });

        console.log(
            "IN[ContainerAthlete::_fanSubmitsSponsorshipForAthlete]: sponsorship (after update): id[%d] claimed[%d] funds_committed[%d]",
            _athlete_sponsorship_id,
            sponsorship.claimed,
            sponsorship.funds_committed
        );

        return m_sponsor_origination_id;
    }

    function getAthleteSponsorship(uint256 _athlete_sponsorship_id)
        external
        view
        returns (AthleteSponsorshipUtils.AthleteSponsorship memory sponsorship)
    {

        return m_id_to_athlete_sponsorship[_athlete_sponsorship_id];
    }

    function getAthleteSponsorshipNumbers(uint256 _athlete_sponsorship_id)
        public
        view
        returns (uint256 capacity, uint256 claimed)
    {

        claimed = 0;
        capacity = 0;
        if (_athlete_sponsorship_id == 0) return (capacity, claimed);

        uint256 round_id = m_id_to_athlete_sponsorship[_athlete_sponsorship_id]
            .round_id;
        if (round_id == 0) return (capacity, claimed);

        claimed = m_id_to_athlete_sponsorship[_athlete_sponsorship_id].claimed;
        capacity = m_id_to_round_info[round_id].capacity;
    }

    function fetchSponsorshipStats()
        external
        view
        returns (uint256[] memory cumulative_sponsorship_funds)
    {

        cumulative_sponsorship_funds = new uint256[](m_athlete_id);

        for (
            uint256 sponsorship_id = 1;
            sponsorship_id <= m_athlete_sponsorship_id;
            sponsorship_id++
        ) {
            AthleteSponsorshipUtils.AthleteSponsorship
                storage ath_sponsorship = m_id_to_athlete_sponsorship[
                    sponsorship_id
                ];

            uint256 ath_id = ath_sponsorship.athlete_id;

            cumulative_sponsorship_funds[ath_id - 1] =
                cumulative_sponsorship_funds[ath_id - 1] +
                ath_sponsorship.funds_committed;
        }
    }

    function setRefundEligible(uint256 _ath_sponsorship_id, bool _val)
        external
        onlyOwner
        isValidAthleteSponsorshipId(_ath_sponsorship_id)
    {

        m_id_to_athlete_sponsorship[_ath_sponsorship_id].refund_eligible = _val;
    }

    function isSponsorshipRefundEligible(uint256 _ath_sponsorship_id)
        external
        view
        returns (bool)
    {

        return m_id_to_athlete_sponsorship[_ath_sponsorship_id].refund_eligible;
    }
}// UNLICENSED
pragma solidity ^0.8.0;


library SponsorshipCreationLib {

    uint256 constant SPONSOR_PRICE_V0 = 0.04 ether;

    struct AthleteInitArgs {
        uint256 db_id;
        bytes32 full_name;
        AthleteLib.Sport sport;
        uint8 number;
        AthleteLib.PlayerPosition position;
    }

    struct SponsorshipRoundInitArgs {
        uint256 db_id;
        uint16 season;
        uint256 round;
        bytes32 location;
        uint16 capacity;
    }

    struct OnChainInitAudit {
        bool init_athlete;
        bool init_sponsorship_round;
        uint16 sponsorship_serial;
    }
}// UNLICENSED
pragma solidity ^0.8.0;


contract SponsorshipCreation is AthleteSponsorshipMap {

    IAthleteSponsorshipNftUpgradeable m_sponsorship_nft;

    constructor(IAthleteSponsorshipNftUpgradeable _sponsorship_nft) {
        m_sponsorship_nft = _sponsorship_nft;
    }


    event OnChainAthleteCreated(
        address indexed sponsor,
        uint256 indexed chain_id,
        AthleteLib.Sport sport,
        bytes32 athlete_name
    );

    event OnChainSponsorshipRoundCreated(
        address indexed sponsor,
        uint256 indexed round,
        uint256 indexed season,
        uint256 chain_id,
        bytes32 location
    );

    event OnChainAthleteSponsorshipCreated(
        address indexed sponsor,
        uint256 indexed sponsorship_chain_id,
        uint256 indexed sponsorship_origination_chain_id,
        uint256 ath_chain_id,
        uint256 rnd_chain_id
    );

    event OnChainAthleteSponsorshipNftCreated(
        address indexed sponsor,
        uint256 indexed token_id,
        uint256 indexed athlete_id,
        uint256 sponsorship_originator_id,
        uint256 round_id
    );



    function doOnChainInitAudit(
        uint256 _db_id_ath,
        uint256 _db_id_sponsorship_round
    ) external view returns (SponsorshipCreationLib.OnChainInitAudit memory) {

        bool init_athlete = !dbAthleteExistsOnChain(_db_id_ath);
        bool init_sponsorship_round = !dbSponsorshipRoundExistsOnChain(
            _db_id_sponsorship_round
        );

        uint16 sponsorship_serial = 1;
        if (!init_athlete && !init_sponsorship_round) {
            uint256 athlete_sponsorship_id = getAthleteSponsorshipId(
                getAthleteIdFromDbId(_db_id_ath),
                getSponsorshipRoundIdFromDbId(_db_id_sponsorship_round)
            );
            require(athlete_sponsorship_id > 0, "bad ath spnsr id");
            sponsorship_serial =
                m_id_to_athlete_sponsorship[athlete_sponsorship_id].claimed +
                1;
        }
        return
            SponsorshipCreationLib.OnChainInitAudit({
                init_athlete: init_athlete,
                init_sponsorship_round: init_sponsorship_round,
                sponsorship_serial: sponsorship_serial
            });
    }

    function buildOnChainAthleteInitStruct(
        uint256 _ath_db_id,
        bytes32 _ath_name,
        AthleteLib.Sport _ath_sport,
        uint8 _ath_number,
        AthleteLib.PlayerPosition _ath_position
    ) external pure returns (SponsorshipCreationLib.AthleteInitArgs memory) {

        return
            SponsorshipCreationLib.AthleteInitArgs({
                db_id: _ath_db_id,
                full_name: _ath_name,
                sport: _ath_sport,
                number: _ath_number,
                position: _ath_position
            });
    }

    function buildOnChainSponsorshipRoundInitStruct(
        uint256 _round_db_id,
        uint16 _sponsorship_season,
        uint256 _sponsorship_round,
        bytes32 _round_location,
        uint16 _capacity
    )
        external
        pure
        returns (SponsorshipCreationLib.SponsorshipRoundInitArgs memory)
    {

        return
            SponsorshipCreationLib.SponsorshipRoundInitArgs({
                db_id: _round_db_id,
                season: _sponsorship_season,
                round: _sponsorship_round,
                location: _round_location,
                capacity: _capacity
            });
    }


    function _mintSponsorshipNft(
        uint256 _sponsorship_origination_id,
        string calldata _token_uri
    ) internal {

        console.log(
            "In[SponsorshipCreation::_mintSponsorshipNft] _sponsorship_holder_id[%d]",
            _sponsorship_origination_id
        );
        uint256 new_token_id = m_sponsorship_nft.mintSponsorship(
            _token_uri,
            _sponsorship_origination_id,
            msg.sender
        );
        assert(m_sponsorship_nft.ownerOf(new_token_id) == msg.sender);

        console.log(
            "In[SponsorshipCreation::_mintSponsorshipNft] new_token_id[%d]",
            new_token_id
        );

        uint256 sponsorship_id = m_id_to_sponsorship_origination[
            _sponsorship_origination_id
        ].athlete_sponsorship_id;

        emit OnChainAthleteSponsorshipNftCreated(
            msg.sender,
            new_token_id,
            m_id_to_athlete_sponsorship[sponsorship_id].athlete_id,
            _sponsorship_origination_id,
            m_id_to_athlete_sponsorship[sponsorship_id].round_id
        );
    }

    function _sponsorCreatesOnChainAthlete(
        SponsorshipCreationLib.AthleteInitArgs calldata _args
    ) private returns (uint256 new_on_chain_ath_id) {

        new_on_chain_ath_id = addAthlete(
            _args.db_id,
            _args.full_name,
            _args.sport,
            _args.number,
            _args.position
        );
        emit OnChainAthleteCreated(
            msg.sender,
            new_on_chain_ath_id,
            _args.sport,
            _args.full_name
        );
    }

    function _sponsorCreatesOnChainSponsorshipRound(
        SponsorshipCreationLib.SponsorshipRoundInitArgs calldata _args
    ) private returns (uint256 on_chain_new_round_id) {

        console.log(
            "In[SponsorshipCreation::sponsorCreatesOnChainSponsorshipRound] _round_db_id[%d] _sponsorship_season[%d] _sponsorship_round[%d]",
            _args.db_id,
            _args.season,
            _args.round
        );
        console.log(
            "In[SponsorshipCreation::sponsorCreatesOnChainSponsorshipRound] capacity[%d]",
            _args.capacity
        );

        on_chain_new_round_id = initSponsorshipRound(
            _args.db_id,
            _args.season,
            _args.round,
            _args.location,
            _args.capacity
        );

        console.log(
            "In[SponsorshipCreation::sponsorCreatesOnChainSponsorshipRound] new_on_chain_id[%d]",
            on_chain_new_round_id
        );

        emit OnChainSponsorshipRoundCreated(
            msg.sender,
            _args.round,
            _args.season,
            on_chain_new_round_id,
            _args.location
        );
    }

    function _sponsorCreatesOnChainAthleteSponsorship(
        uint256 _new_athlete_id,
        uint256 _new_base_attributes_id,
        uint256 _funds_for_athlete
    )
        private
        returns (
            uint256 new_on_chain_ath_sponsorship_id,
            uint256 new_on_chain_origination_id
        )
    {

        console.log(
            "In[SponsorshipCreation::sponsorCreatesOnChainAthleteSponsorship] _new_athlete_id[%d] _new_base_attributes_id[%d]",
            _new_athlete_id,
            _new_base_attributes_id
        );

        (
            new_on_chain_ath_sponsorship_id,
            new_on_chain_origination_id
        ) = initAthleteSponsorship(
            _new_athlete_id,
            _new_base_attributes_id,
            _funds_for_athlete
        );

        console.log(
            "In[SponsorshipCreation::sponsorCreatesOnChainAthleteSponsorship] new_athlete_sponsorship_id[%d] new_sponsor_attributes_id[%d]",
            new_on_chain_ath_sponsorship_id,
            new_on_chain_origination_id
        );

        emit OnChainAthleteSponsorshipCreated(
            msg.sender,
            new_on_chain_ath_sponsorship_id,
            new_on_chain_origination_id,
            _new_athlete_id,
            _new_base_attributes_id
        );
    }

    function sponsorSubmits(
        SponsorshipCreationLib.OnChainInitAudit calldata _init_audit,
        SponsorshipCreationLib.AthleteInitArgs calldata _athlete_args,
        SponsorshipCreationLib.SponsorshipRoundInitArgs calldata _round_args,
        string calldata _token_uri
    ) external payable {

        uint256 on_chain_ath_id = 0;
        uint256 on_chain_round_id = 0;
        uint256 on_chain_origination_id = 0;
        uint256 on_chain_sponsorship_id = 0;
        console.log(
            "In[sponsorSubmits] init_athlete[%s] init_sponsorship_round[%s]",
            _init_audit.init_athlete,
            _init_audit.init_sponsorship_round
        );

        if (_init_audit.init_athlete) {
            on_chain_ath_id = _sponsorCreatesOnChainAthlete(_athlete_args);
        } else {
            on_chain_ath_id = getAthleteIdFromDbId(_athlete_args.db_id);
        }

        if (_init_audit.init_sponsorship_round) {
            on_chain_round_id = _sponsorCreatesOnChainSponsorshipRound(
                _round_args
            );
        } else {
            on_chain_round_id = getSponsorshipRoundIdFromDbId(
                _round_args.db_id
            );
        }
        require(on_chain_ath_id > 0, "invalid ath id");
        require(on_chain_round_id > 0, "invalid round id");

        if (_init_audit.init_athlete || _init_audit.init_sponsorship_round) {
            (
                ,
                on_chain_origination_id
            ) = _sponsorCreatesOnChainAthleteSponsorship(
                on_chain_ath_id,
                on_chain_round_id,
                msg.value
            );
        } else {
            on_chain_sponsorship_id = getAthleteSponsorshipId(
                on_chain_ath_id,
                on_chain_round_id
            );
            on_chain_origination_id = addToAthleteSponsorship(
                on_chain_sponsorship_id,
                msg.value
            );
        }
        require(on_chain_origination_id > 0, "invalid origination id");

        _mintSponsorshipNft(on_chain_origination_id, _token_uri);
    }

    function upgradeSponsorship(
        uint256 _token_id,
        string calldata _signature_uri
    ) external onlyOwner {

        require(_token_id > 0, "bad token");
        require(
            !m_sponsorship_nft.isSponsorshipUpgraded(_token_id),
            "already upgraded"
        );
        require(bytes(_signature_uri).length > 0, "bad uri");

        m_sponsorship_nft.setSponsorshipUpgraded(_token_id, true);

        m_sponsorship_nft.upgradeSponsorshipUri(_token_id, _signature_uri);
    }
}// UNLICENSED
pragma solidity ^0.8.0;


abstract contract IOriginNftUpgradeable is
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable
{
    uint256 m_token_id;
    mapping(uint256 => uint256) m_token_to_athlete;
    mapping(uint256 => uint256) m_athlete_to_token;

    address m_approved_caller;

    function __IOriginNftUpgradeable_init(
        string memory _name,
        string memory _symbol
    ) internal onlyInitializing {
        __IOriginNftUpgradeable_init_unchained(_name, _symbol);
    }

    function __IOriginNftUpgradeable_init_unchained(
        string memory _name,
        string memory _symbol
    ) internal onlyInitializing {
        __ERC721_init(_name, _symbol);
        __Ownable_init();
        m_approved_caller = address(0);
    }

    modifier allowedCaller() {
        require(
            msg.sender == owner() || msg.sender == m_approved_caller,
            "INVALID CALLER"
        );
        _;
    }

    function setApprovalForCaller(address _operator)
        external
        virtual
        onlyOwner
    {
        console.log(
            "In[setApprovalForCaller] _operator[%s] owner[%s] m_approved_caller[%s]",
            _operator,
            owner(),
            m_approved_caller
        );
        m_approved_caller = _operator;
    }

    function getTokenCount() external view virtual returns (uint256) {
        return m_token_id;
    }

    function getAthleteForToken(uint256 _token_id)
        public
        view
        virtual
        returns (uint256)
    {
        return m_token_to_athlete[_token_id];
    }

    event OriginNftMinted(
        address indexed athlete_wallet,
        uint256 indexed athlete_id,
        uint256 indexed token_id
    );

    function mintOriginNft(
        string calldata _signature_uri,
        uint256 _on_chain_ath_id,
        address _athlete
    ) public virtual allowedCaller {
        require(
            m_athlete_to_token[_on_chain_ath_id] == 0,
            "ath already has nft"
        );

        m_token_id++;

        console.log(
            "In[mintOriginNft] _on_chain_ath_id[%d] m_token_id[%d]",
            _on_chain_ath_id,
            m_token_id
        );

        m_token_to_athlete[m_token_id] = _on_chain_ath_id;
        m_athlete_to_token[_on_chain_ath_id] = m_token_id;

        _mint(_athlete, m_token_id);
        assert(ownerOf(m_token_id) == _athlete);

        _setTokenURI(m_token_id, _signature_uri);

        emit OriginNftMinted(_athlete, _on_chain_ath_id, m_token_id);
    }
}// UNLICENSED
pragma solidity ^0.8.0;




contract AthleteNftMarket is
    ReentrancyGuard,
    SponsorshipCreation,
    EtherReceiver
{

    Foundation private m_foundation_contract;

    uint256 private m_sponsorship_price;

    constructor(
        Foundation _foundation_contract,
        IAthleteSponsorshipNftUpgradeable _sponsorship_nft
    ) SponsorshipCreation(_sponsorship_nft) {
        m_foundation_contract = _foundation_contract;

        if (m_sponsorship_price == 0) {
            m_sponsorship_price = SponsorshipCreationLib.SPONSOR_PRICE_V0;
        }
    }

    function setPrice(uint256 _new_price) external onlyOwner {

        m_sponsorship_price = _new_price;
    }

    function getSponsorshipPrice() external view returns (uint256) {

        return m_sponsorship_price;
    }

    function mintOriginNftToOnChainAthlete(
        address _contract_origin_nft,
        string calldata _token_uri,
        uint256 _on_chain_ath_id,
        address _athlete_wallet
    ) external onlyOwner isValidAthleteId(_on_chain_ath_id) {

        console.log(
            "In[mintOriginNftToOnChainAthlete] on_chain_ath_id[%d] _athlete_wallet[%s]",
            _on_chain_ath_id,
            _athlete_wallet
        );

        IOriginNftUpgradeable(_contract_origin_nft).mintOriginNft(
            _token_uri,
            _on_chain_ath_id,
            _athlete_wallet
        );
    }

    event AthleteWithdrawsFunds(
        address indexed athlete_address,
        address indexed origin_nft_address,
        uint256 indexed token_id,
        uint256 amount
    );

    event SponsorshipCommission(
        address indexed athlete,
        uint256 indexed athlete_id,
        uint256 amount
    );

    function athleteWithdrawsFundsUsingOriginNft(
        address _origin_nft,
        uint256 _token_id
    ) public {

        console.log(
            "In[athleteWithdrawsFundsUsingOriginNft] _token_id[%d] msg.sender[%s]",
            _token_id,
            msg.sender
        );

        require(_token_id > 0, "bad tok id");
        uint256 on_chain_ath_id = IOriginNftUpgradeable(_origin_nft)
            .getAthleteForToken(_token_id);
        require(on_chain_ath_id > 0, "bad ath id");

        require(
            IOriginNftUpgradeable(_origin_nft).ownerOf(_token_id) == msg.sender,
            "not owner"
        );

        uint256 total_funds = 0;
        for (uint256 id = 1; id <= getAthleteSponsorshipCount(); id++) {
            if (m_id_to_athlete_sponsorship[id].athlete_id != on_chain_ath_id)
                continue;

            AthleteSponsorshipUtils.AthleteSponsorship
                storage ath_sponsorship = m_id_to_athlete_sponsorship[id];
            if (ath_sponsorship.funds_claimed_by_athlete) continue;

            if (ath_sponsorship.funds_committed == 0) continue;
            uint256 funds_available = ath_sponsorship.funds_committed;

            assert(m_id_to_round_info[ath_sponsorship.round_id].is_open);

            total_funds += funds_available;

            ath_sponsorship.funds_claimed_by_athlete = true;
        }

        require(
            getBalance() >= total_funds,
            "contract without sufficient funds"
        );

        uint256 our_rake = Foundation(m_foundation_contract)
            .calculateFoundationRakeForSalePrice(total_funds);
        assert(our_rake >= 0);
        assert(our_rake < total_funds);
        uint256 funds_for_athlete = total_funds - our_rake;

        {
            (bool sent, ) = payable(msg.sender).call{value: funds_for_athlete}(
                ""
            );
            require(sent, "transfer to ath failed");
        }

        {
            (bool sent, ) = payable(m_foundation_contract).call{
                value: our_rake
            }("");
            require(sent, "transfer to foundation failed");
        }

        emit AthleteWithdrawsFunds(
            msg.sender,
            _origin_nft,
            _token_id,
            total_funds
        );

        emit SponsorshipCommission(msg.sender, on_chain_ath_id, our_rake);
    }

    event SponsorshipRefund(
        uint256 indexed token_id,
        address indexed sponsor,
        uint256 indexed ath_id,
        uint256 price,
        uint256 ath_sponsorship_id,
        uint256 ath_sponsorship_origination_id
    );

    function giveRefundForNonUpgradedSponsorship(uint256 _token_id)
        external
        nonReentrant
    {

        console.log(
            "In[refund] _token_id[%d] msg.sender[%s]",
            _token_id,
            msg.sender
        );

        require(
            m_sponsorship_nft.getTokenOwner(_token_id) == msg.sender,
            "not the owner"
        );
        require(
            !m_sponsorship_nft.isSponsorshipUpgraded(_token_id),
            "token already upgraded"
        );
        uint256 sponsorship_origination_id = m_sponsorship_nft
            .getTokenOriginationId(_token_id);
        require(sponsorship_origination_id > 0, "bad spnsrship orig id");

        console.log(
            "In[refund] sponsorship_origination_id[%d]",
            sponsorship_origination_id
        );

        uint256 sponsorship_price = m_id_to_sponsorship_origination[
            sponsorship_origination_id
        ].price;
        uint256 athlete_sponsorship_id = m_id_to_sponsorship_origination[
            sponsorship_origination_id
        ].athlete_sponsorship_id;

        console.log(
            "In[refund] prc[%d] sponsorship_id[%d]",
            sponsorship_price,
            athlete_sponsorship_id
        );

        require(
            m_id_to_athlete_sponsorship[athlete_sponsorship_id].refund_eligible,
            "not refund eligible"
        );

        assert(
            !m_id_to_athlete_sponsorship[athlete_sponsorship_id]
                .funds_claimed_by_athlete
        );
        assert(
            sponsorship_price <=
                m_id_to_athlete_sponsorship[athlete_sponsorship_id]
                    .funds_committed
        );
        assert(m_id_to_athlete_sponsorship[athlete_sponsorship_id].claimed > 0);

        AthleteSponsorshipUtils.AthleteSponsorship
            storage ath_sponsorship = m_id_to_athlete_sponsorship[
                athlete_sponsorship_id
            ];
        console.log(
            "In[refund] pre-refund state: claimed[%d] funds_committed[%d]",
            ath_sponsorship.claimed,
            ath_sponsorship.funds_committed
        );

        ath_sponsorship.funds_committed -= sponsorship_price;
        m_id_to_athlete_sponsorship[athlete_sponsorship_id].claimed--;

        console.log(
            "In[refund] post-refund state: claimed[%d] funds_committed[%d]",
            ath_sponsorship.claimed,
            ath_sponsorship.funds_committed
        );

        delete m_id_to_sponsorship_origination[sponsorship_origination_id];

        (bool sent, ) = payable(msg.sender).call{value: sponsorship_price}("");
        require(sent, "refund failed");

        m_sponsorship_nft.burnOnRefund(_token_id);

        emit SponsorshipRefund(
            _token_id,
            msg.sender,
            m_id_to_athlete_sponsorship[athlete_sponsorship_id].athlete_id,
            sponsorship_price,
            athlete_sponsorship_id,
            sponsorship_origination_id
        );
    }
}