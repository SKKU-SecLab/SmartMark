
pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.6.0 <0.8.0;

library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        console.log("(token.allowance(address(this), spender)", (token.allowance(address(this), spender)));
        console.log("value", value);
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// BUSL-1.1

pragma solidity 0.7.6;
pragma abicoder v2;

interface IAMM {

    struct Pair {
        address tokenAddress; // first is always PT
        uint256[2] weights;
        uint256[2] balances;
        bool liquidityIsInitialized;
    }

    function finalize() external;


    function switchPeriod() external;


    function togglePauseAmm() external;


    function withdrawExpiredToken(address _user, uint256 _lpTokenId) external;


    function getExpiredTokensInfo(address _user, uint256 _lpTokenId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function swapExactAmountIn(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenAmountIn,
        uint256 _tokenOut,
        uint256 _minAmountOut,
        address _to
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);


    function swapExactAmountOut(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _maxAmountIn,
        uint256 _tokenOut,
        uint256 _tokenAmountOut,
        address _to
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);


    function createLiquidity(uint256 _pairID, uint256[2] memory _tokenAmounts) external;


    function addLiquidity(
        uint256 _pairID,
        uint256 _poolAmountOut,
        uint256[2] memory _maxAmountsIn
    ) external;


    function removeLiquidity(
        uint256 _pairID,
        uint256 _poolAmountIn,
        uint256[2] memory _minAmountsOut
    ) external;


    function joinSwapExternAmountIn(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenAmountIn,
        uint256 _minPoolAmountOut
    ) external returns (uint256 poolAmountOut);


    function joinSwapPoolAmountOut(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _poolAmountOut,
        uint256 _maxAmountIn
    ) external returns (uint256 tokenAmountIn);


    function exitSwapPoolAmountIn(
        uint256 _pairID,
        uint256 _tokenOut,
        uint256 _poolAmountIn,
        uint256 _minAmountOut
    ) external returns (uint256 tokenAmountOut);


    function exitSwapExternAmountOut(
        uint256 _pairID,
        uint256 _tokenOut,
        uint256 _tokenAmountOut,
        uint256 _maxPoolAmountIn
    ) external returns (uint256 poolAmountIn);


    function setSwappingFees(uint256 _swapFee) external;


    function calcOutAndSpotGivenIn(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenAmountIn,
        uint256 _tokenOut,
        uint256 _minAmountOut
    ) external view returns (uint256 tokenAmountOut, uint256 spotPriceAfter);


    function calcInAndSpotGivenOut(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _maxAmountIn,
        uint256 _tokenOut,
        uint256 _tokenAmountOut
    ) external view returns (uint256 tokenAmountIn, uint256 spotPriceAfter);


    function getSpotPrice(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenOut
    ) external view returns (uint256);


    function getFutureAddress() external view returns (address);


    function getPTAddress() external view returns (address);


    function getUnderlyingOfIBTAddress() external view returns (address);


    function getFYTAddress() external view returns (address);


    function getPTWeightInPair() external view returns (uint256);


    function getPairWithID(uint256 _pairID) external view returns (Pair memory);


    function getLPTokenId(
        uint256 _ammId,
        uint256 _periodIndex,
        uint256 _pairID
    ) external pure returns (uint256);


    function ammId() external returns (uint64);

}// BUSL-1.1

pragma solidity 0.7.6;


interface IERC20 is IERC20Upgradeable {

    function name() external returns (string memory);


    function symbol() external returns (string memory);


    function decimals() external view returns (uint8);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// BUSL-1.1

pragma solidity 0.7.6;


interface IERC1155 is IERC165Upgradeable {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


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


    function grantRole(bytes32 role, address account) external;


    function MINTER_ROLE() external view returns (bytes32);


    function mint(
        address to,
        uint64 _ammId,
        uint64 _periodIndex,
        uint32 _pairId,
        uint256 amount,
        bytes memory data
    ) external returns (uint256 id);


    function burnFrom(
        address account,
        uint256 id,
        uint256 value
    ) external;

}// BUSL-1.1


pragma solidity ^0.7.6;

interface ILPToken is IERC1155 {

    function amms(uint64 _ammId) external view returns (address);


    function getAMMId(uint256 _id) external pure returns (uint64);


    function getPeriodIndex(uint256 _id) external pure returns (uint64);


    function getPairId(uint256 _id) external pure returns (uint32);

}// BUSL-1.1

pragma solidity 0.7.6;


interface IPT is IERC20 {

    function burn(uint256 amount) external;


    function mint(address to, uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;


    function pause() external;


    function unpause() external;


    function recordedBalanceOf(address account) external view returns (uint256);


    function balanceOf(address account) external view override returns (uint256);


    function futureVault() external view returns (address);

}// BUSL-1.1

pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

interface IRegistry {

    function initialize(address _admin) external;


    function setTreasury(address _newTreasury) external;


    function setController(address _newController) external;


    function setAPW(address _newAPW) external;


    function setProxyFactory(address _proxyFactory) external;


    function setPTLogic(address _PTLogic) external;


    function setFYTLogic(address _FYTLogic) external;


    function setMathsUtils(address _mathsUtils) external;


    function setNamingUtils(address _namingUtils) external;


    function getControllerAddress() external view returns (address);


    function getTreasuryAddress() external view returns (address);


    function getTokensFactoryAddress() external view returns (address);


    function getDAOAddress() external returns (address);


    function getAPWAddress() external view returns (address);


    function getAMMFactoryAddress() external view returns (address);


    function getTokenFactoryAddress() external view returns (address);


    function getProxyFactoryAddress() external view returns (address);


    function getPTLogicAddress() external view returns (address);


    function getFYTLogicAddress() external view returns (address);


    function getAMMLogicAddress() external view returns (address);


    function getAMMLPTokenLogicAddress() external view returns (address);


    function getMathsUtils() external view returns (address);


    function getNamingUtils() external view returns (address);


    function addFuture(address _future) external;


    function removeFuture(address _future) external;


    function isRegisteredFuture(address _future) external view returns (bool);


    function isRegisteredAMM(address _ammAddress) external view returns (bool);


    function getFutureAt(uint256 _index) external view returns (address);


    function futureCount() external view returns (uint256);

}// BUSL-1.1

pragma solidity 0.7.6;

interface IFutureWallet {

    function initialize(address _futureAddress, address _adminAddress) external;


    function registerExpiredFuture(uint256 _amount) external;


    function redeemYield(uint256 _periodIndex) external;


    function getRedeemableYield(uint256 _periodIndex, address _tokenHolder) external view returns (uint256);


    function getFutureAddress() external view returns (address);


    function getIBTAddress() external view returns (address);

}// BUSL-1.1

pragma solidity 0.7.6;


interface IFutureVault {

    event NewPeriodStarted(uint256 _newPeriodIndex);
    event FutureWalletSet(address _futureWallet);
    event RegistrySet(IRegistry _registry);
    event FundsDeposited(address _user, uint256 _amount);
    event FundsWithdrawn(address _user, uint256 _amount);
    event PTSet(IPT _pt);
    event LiquidityTransfersPaused();
    event LiquidityTransfersResumed();
    event DelegationCreated(address _delegator, address _receiver, uint256 _amount);
    event DelegationRemoved(address _delegator, address _receiver, uint256 _amount);

    function PERIOD_DURATION() external view returns (uint256);


    function PLATFORM_NAME() external view returns (string memory);


    function startNewPeriod() external;


    function updateUserState(address _user) external;


    function claimFYT(address _user, uint256 _amount) external;


    function deposit(address _user, uint256 _amount) external;


    function withdraw(address _user, uint256 _amount) external;


    function createFYTDelegationTo(
        address _delegator,
        address _receiver,
        uint256 _amount
    ) external;


    function withdrawFYTDelegationFrom(
        address _delegator,
        address _receiver,
        uint256 _amount
    ) external;



    function getTotalDelegated(address _delegator) external view returns (uint256 totalDelegated);


    function getNextPeriodIndex() external view returns (uint256);


    function getCurrentPeriodIndex() external view returns (uint256);


    function getClaimablePT(address _user) external view returns (uint256);


    function getUserEarlyUnlockablePremium(address _user)
        external
        view
        returns (uint256 premiumLocked, uint256 amountRequired);


    function getUnlockableFunds(address _user) external view returns (uint256);


    function getClaimableFYTForPeriod(address _user, uint256 _periodIndex) external view returns (uint256);


    function getUnrealisedYieldPerPT() external view returns (uint256);


    function getPTPerAmountDeposited(uint256 _amount) external view returns (uint256);


    function getPremiumPerUnderlyingDeposited(uint256 _amount) external view returns (uint256);


    function getTotalUnderlyingDeposited() external view returns (uint256);


    function getYieldOfPeriod(uint256 _periodID) external view returns (uint256);


    function getControllerAddress() external view returns (address);


    function getFutureWalletAddress() external view returns (address);


    function getIBTAddress() external view returns (address);


    function getPTAddress() external view returns (address);


    function getFYTofPeriod(uint256 _periodIndex) external view returns (address);


    function isTerminated() external view returns (bool);


    function getPerformanceFeeFactor() external view returns (uint256);



    function harvestRewards() external;


    function redeemAllVaultRewards() external;


    function redeemVaultRewards(address _rewardToken) external;


    function addRewardsToken(address _token) external;


    function isRewardToken(address _token) external view returns (bool);


    function getRewardTokenAt(uint256 _index) external view returns (address);


    function getRewardTokensCount() external view returns (uint256);


    function getRewardsRecipient() external view returns (address);


    function setRewardRecipient(address _recipient) external;



    function setFutureWallet(IFutureWallet _futureWallet) external;


    function setRegistry(IRegistry _registry) external;


    function pauseLiquidityTransfers() external;


    function resumeLiquidityTransfers() external;


    function convertIBTToUnderlying(uint256 _amount) external view returns (uint256);


    function convertUnderlyingtoIBT(uint256 _amount) external view returns (uint256);

}// BUSL-1.1

pragma solidity 0.7.6;

interface IController {


    function STARTING_DELAY() external view returns (uint256);



    function setPeriodStartingDelay(uint256 _startingDelay) external;


    function setNextPeriodSwitchTimestamp(uint256 _periodDuration, uint256 _nextPeriodTimestamp) external;



    function deposit(address _futureVault, uint256 _amount) external;


    function withdraw(address _futureVault, uint256 _amount) external;


    function claimFYT(address _futureVault) external;


    function getRegistryAddress() external view returns (address);


    function getFutureIBTSymbol(
        string memory _ibtSymbol,
        string memory _platform,
        uint256 _periodDuration
    ) external pure returns (string memory);


    function getFYTSymbol(string memory _ptSymbol, uint256 _periodDuration) external view returns (string memory);


    function getPeriodIndex(uint256 _periodDuration) external view returns (uint256);


    function getNextPeriodStart(uint256 _periodDuration) external view returns (uint256);


    function getNextPerformanceFeeFactor(address _futureVault) external view returns (uint256);


    function getCurrentPerformanceFeeFactor(address _futureVault) external view returns (uint256);


    function getDurations() external view returns (uint256[] memory);


    function registerNewFutureVault(address _futureVault) external;


    function unregisterFutureVault(address _futureVault) external;


    function startFuturesByPeriodDuration(uint256 _periodDuration) external;


    function getFuturesWithDuration(uint256 _periodDuration) external view returns (address[] memory);


    function claimSelectedFYTS(address _user, address[] memory _futureVaults) external;


    function getRoleMember(bytes32 role, uint256 index) external view returns (address); // OZ ACL getter


    function isDepositsPaused(address _futureVault) external view returns (bool);


    function isWithdrawalsPaused(address _futureVault) external view returns (bool);


    function isFutureSetToBeTerminated(address _futureVault) external view returns (bool);

}// BUSL-1.1

pragma solidity ^0.7.6;

library AMMMathsUtils {

    uint256 internal constant UNIT = 10**18;
    uint256 internal constant MIN_POW_BASE = 1 wei;
    uint256 internal constant MAX_POW_BASE = (2 * UNIT) - 1 wei;
    uint256 internal constant POW_PRECISION = UNIT / 10**10;

    function powi(uint256 a, uint256 n) internal pure returns (uint256) {

        uint256 z = n % 2 != 0 ? a : UNIT;
        for (n /= 2; n != 0; n /= 2) {
            a = div(mul(a, a), UNIT);
            if (n % 2 != 0) {
                z = div(mul(z, a), UNIT);
            }
        }
        return z;
    }

    function pow(uint256 base, uint256 exp) internal pure returns (uint256) {

        require(base >= MIN_POW_BASE, "ERR_POW_BASE_TOO_LOW");
        require(base <= MAX_POW_BASE, "ERR_POW_BASE_TOO_HIGH");
        uint256 whole = mul(div(exp, UNIT), UNIT);
        uint256 remain = sub(exp, whole);
        uint256 wholePow = powi(base, div(whole, UNIT));
        if (remain == 0) {
            return wholePow;
        }
        uint256 partialResult = powApprox(base, remain, POW_PRECISION);
        return div(mul(wholePow, partialResult), UNIT);
    }

    function subSign(uint256 a, uint256 b) internal pure returns (uint256, bool) {

        return (a >= b) ? (a - b, false) : (b - a, true);
    }

    function powApprox(
        uint256 base,
        uint256 exp,
        uint256 precision
    ) internal pure returns (uint256) {

        uint256 a = exp;
        (uint256 x, bool xneg) = subSign(base, UNIT);
        uint256 term = UNIT;
        uint256 sum = term;
        bool negative = false;
        for (uint256 i = 1; term >= precision; ++i) {
            uint256 bigK = mul(i, UNIT);
            (uint256 c, bool cneg) = subSign(a, sub(bigK, UNIT));
            term = div(mul(term, div(mul(c, x), UNIT)), UNIT);
            term = div(mul(UNIT, term), bigK);
            if (term == 0) break;
            if (xneg) negative = !negative;
            if (cneg) negative = !negative;
            if (negative) {
                sum = sub(sum, term);
            } else {
                sum = add(sum, term);
            }
        }
        return sum;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "AMMMaths: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "AMMMaths: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "AMMMaths: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "AMMMaths: division by zero");
        return a / b;
    }
}

library AMMMaths {

    using AMMMathsUtils for uint256;
    uint256 internal constant UNIT = 10**18;
    uint256 internal constant SQUARED_UNIT = UNIT * UNIT;
    uint256 internal constant EXIT_FEE = 0;
    uint256 internal constant ZERO_256 = uint256(0);
    uint256 internal constant MAX_IN_RATIO = UNIT / 2;
    uint256 internal constant MAX_OUT_RATIO = (UNIT / 3) + 1 wei;

    function calcOutGivenIn(
        uint256 _tokenBalanceIn,
        uint256 _tokenWeightIn,
        uint256 _tokenBalanceOut,
        uint256 _tokenWeightOut,
        uint256 _tokenAmountIn,
        uint256 _swapFee
    ) internal pure returns (uint256) {

        return
            calcOutGivenIn(
                _tokenBalanceIn,
                _tokenWeightIn,
                _tokenBalanceOut,
                _tokenWeightOut,
                _tokenAmountIn,
                _swapFee,
                UNIT
            );
    }

    function calcOutGivenIn(
        uint256 _tokenBalanceIn,
        uint256 _tokenWeightIn,
        uint256 _tokenBalanceOut,
        uint256 _tokenWeightOut,
        uint256 _tokenAmountIn,
        uint256 _swapFee,
        uint256 _slippageFactor
    ) internal pure returns (uint256) {

        uint256 slippageBase = UNIT.mul(UNIT).div(_slippageFactor);
        uint256 weightRatio = slippageBase.mul(_tokenWeightIn).div(_tokenWeightOut);
        uint256 adjustedIn = _tokenAmountIn.mul(UNIT.sub(_swapFee)).div(UNIT);
        uint256 y = UNIT.mul(_tokenBalanceIn).div(_tokenBalanceIn.add(adjustedIn));
        uint256 bar = UNIT.sub(AMMMathsUtils.pow(y, weightRatio));
        return _tokenBalanceOut.mul(bar).div(UNIT);
    }

    function calcInGivenOut(
        uint256 _tokenBalanceIn,
        uint256 _tokenWeightIn,
        uint256 _tokenBalanceOut,
        uint256 _tokenWeightOut,
        uint256 _tokenAmountOut,
        uint256 _swapFee
    ) internal pure returns (uint256) {

        return
            calcInGivenOut(
                _tokenBalanceIn,
                _tokenWeightIn,
                _tokenBalanceOut,
                _tokenWeightOut,
                _tokenAmountOut,
                _swapFee,
                UNIT
            );
    }

    function calcInGivenOut(
        uint256 _tokenBalanceIn,
        uint256 _tokenWeightIn,
        uint256 _tokenBalanceOut,
        uint256 _tokenWeightOut,
        uint256 _tokenAmountOut,
        uint256 _swapFee,
        uint256 _slippageFactor
    ) internal pure returns (uint256) {

        uint256 slippageBase = UNIT.mul(UNIT).div(_slippageFactor);
        uint256 weightRatio = slippageBase.mul(_tokenWeightOut).div(_tokenWeightIn);
        uint256 y = UNIT.mul(_tokenBalanceOut).div(_tokenBalanceOut.sub(_tokenAmountOut));
        uint256 foo = AMMMathsUtils.pow(y, weightRatio).sub(UNIT);
        return _tokenBalanceIn.mul(foo).div(UNIT.sub(_swapFee));
    }

    function calcPoolOutGivenSingleIn(
        uint256 _tokenBalanceIn,
        uint256 _tokenWeightIn,
        uint256 _poolSupply,
        uint256 _totalWeight,
        uint256 _tokenAmountIn,
        uint256 _swapFee
    ) internal pure returns (uint256) {

        uint256 normalizedWeight = UNIT.mul(_tokenWeightIn).div(_totalWeight);
        uint256 zaz = (UNIT.sub(normalizedWeight)).mul(_swapFee).div(UNIT);
        uint256 tokenAmountInAfterFee = _tokenAmountIn.mul(UNIT.sub(zaz)).div(UNIT);
        uint256 newTokenBalanceIn = _tokenBalanceIn.add(tokenAmountInAfterFee);
        uint256 tokenInRatio = UNIT.mul(newTokenBalanceIn).div(_tokenBalanceIn);
        uint256 poolRatio = AMMMathsUtils.pow(tokenInRatio, normalizedWeight);
        uint256 newPoolSupply = poolRatio.mul(_poolSupply).div(UNIT);
        return newPoolSupply.sub(_poolSupply);
    }

    function calcSingleInGivenPoolOut(
        uint256 tokenBalanceIn,
        uint256 tokenWeightIn,
        uint256 poolSupply,
        uint256 totalWeight,
        uint256 poolAmountOut,
        uint256 swapFee
    ) internal pure returns (uint256 tokenAmountIn) {

        uint256 normalizedWeight = UNIT.mul(tokenWeightIn).div(totalWeight);
        uint256 newPoolSupply = poolSupply.add(poolAmountOut);
        uint256 poolRatio = UNIT.mul(newPoolSupply).div(poolSupply);

        uint256 boo = UNIT.mul(UNIT).div(normalizedWeight);
        uint256 tokenInRatio = AMMMathsUtils.pow(poolRatio, boo);
        uint256 newTokenBalanceIn = tokenInRatio.mul(tokenBalanceIn).div(UNIT);
        uint256 tokenAmountInAfterFee = newTokenBalanceIn.sub(tokenBalanceIn);
        uint256 zar = (UNIT.sub(normalizedWeight)).mul(swapFee).div(UNIT);
        tokenAmountIn = UNIT.mul(tokenAmountInAfterFee).div(UNIT.sub(zar));
        return tokenAmountIn;
    }

    function calcSpotPrice(
        uint256 _tokenBalanceIn,
        uint256 _tokenWeightIn,
        uint256 _tokenBalanceOut,
        uint256 _tokenWeightOut,
        uint256 _swapFee
    ) internal pure returns (uint256) {

        uint256 numer = UNIT.mul(_tokenBalanceIn).div(_tokenWeightIn);
        uint256 denom = UNIT.mul(_tokenBalanceOut).div(_tokenWeightOut);
        uint256 ratio = UNIT.mul(numer).div(denom);
        uint256 scale = UNIT.mul(UNIT).div(UNIT.sub(_swapFee));
        return ratio.mul(scale).div(UNIT);
    }

    function calcSingleOutGivenPoolIn(
        uint256 _tokenBalanceOut,
        uint256 _tokenWeightOut,
        uint256 _poolSupply,
        uint256 _totalWeight,
        uint256 _poolAmountIn,
        uint256 _swapFee
    ) internal pure returns (uint256) {

        uint256 normalizedWeight = UNIT.mul(_tokenWeightOut).div(_totalWeight);
        uint256 poolAmountInAfterExitFee = _poolAmountIn.mul(UNIT.sub(EXIT_FEE)).div(UNIT);
        uint256 newPoolSupply = _poolSupply.sub(poolAmountInAfterExitFee);
        uint256 poolRatio = UNIT.mul(newPoolSupply).div(_poolSupply);

        uint256 tokenOutRatio = AMMMathsUtils.pow(poolRatio, UNIT.mul(UNIT).div(normalizedWeight));
        uint256 newTokenBalanceOut = tokenOutRatio.mul(_tokenBalanceOut).div(UNIT);

        uint256 tokenAmountOutBeforeSwapFee = _tokenBalanceOut.sub(newTokenBalanceOut);

        uint256 zaz = (UNIT.sub(normalizedWeight)).mul(_swapFee).div(UNIT);
        return tokenAmountOutBeforeSwapFee.mul(UNIT.sub(zaz)).div(UNIT);
    }

    function calcPoolInGivenSingleOut(
        uint256 _tokenBalanceOut,
        uint256 _tokenWeightOut,
        uint256 _poolSupply,
        uint256 _totalWeight,
        uint256 _tokenAmountOut,
        uint256 _swapFee
    ) internal pure returns (uint256) {

        uint256 normalizedWeight = UNIT.mul(_tokenWeightOut).div(_totalWeight);
        uint256 zoo = UNIT.sub(normalizedWeight);
        uint256 zar = zoo.mul(_swapFee).div(UNIT);
        uint256 tokenAmountOutBeforeSwapFee = UNIT.mul(_tokenAmountOut).div(UNIT.sub(zar));

        uint256 newTokenBalanceOut = _tokenBalanceOut.sub(tokenAmountOutBeforeSwapFee);
        uint256 tokenOutRatio = UNIT.mul(newTokenBalanceOut).div(_tokenBalanceOut);

        uint256 poolRatio = AMMMathsUtils.pow(tokenOutRatio, normalizedWeight);
        uint256 newPoolSupply = poolRatio.mul(_poolSupply).div(UNIT);
        uint256 poolAmountInAfterExitFee = _poolSupply.sub(newPoolSupply);

        return UNIT.mul(poolAmountInAfterExitFee).div(UNIT.sub(EXIT_FEE));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSetUpgradeable {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// BUSL-1.1

pragma solidity 0.7.6;

contract RoleCheckable is Initializable {


    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    bytes32 internal constant ADMIN_ROLE = 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775;
    mapping(bytes32 => RoleData) private _roles;

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
        bytes32 adminRole;
    }

    function grantRole(bytes32 role, address account) external virtual {

        require(hasRole(_roles[role].adminRole, msg.sender), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external virtual {

        require(hasRole(_roles[role].adminRole, msg.sender), "AccessControl: sender must be an admin to revoke");

        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, msg.sender);
        }
    }

    function _setupRole(bytes32 role, address account) internal virtual {

        _grantRole(role, account);
    }

    function _grantRole(bytes32 role, address account) internal {

        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {

        return _roles[role].members.contains(account);
    }

    modifier isAdmin() {

        require(hasRole(ADMIN_ROLE, msg.sender), "RoleCheckable: Caller should be ADMIN");
        _;
    }
}// BUSL-1.1

pragma solidity ^0.7.6;

contract AMM is IAMM, RoleCheckable {

    using AMMMathsUtils for uint256;
    using SafeERC20Upgradeable for IERC20;

    bytes4 public constant ERC1155_ERC165 = 0xd9b67a26;

    bytes32 internal constant ROUTER_ROLE = 0x7a05a596cb0ce7fdea8a1e1ec73be300bdb35097c944ce1897202f7a13122eb2;

    uint64 public override ammId;

    IFutureVault private futureVault;
    uint256 public swapFee;

    IERC20 private ibt;
    IERC20 private pt;
    IERC20 private underlyingOfIBT;
    IERC20 private fyt;

    address internal feesRecipient;

    ILPToken private poolTokens;

    uint256 private constant BASE_WEIGHT = 5 * 10**17;

    enum AMMGlobalState { Created, Activated, Paused }
    AMMGlobalState private state;

    uint256 public currentPeriodIndex;
    uint256 public lastBlockYieldRecorded;
    uint256 public lastYieldRecorded;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    mapping(uint256 => mapping(uint256 => uint256)) private poolToUnderlyingAtPeriod;
    mapping(uint256 => uint256) private generatedYieldAtPeriod;
    mapping(uint256 => uint256) private underlyingSavedPerPeriod;
    mapping(uint256 => mapping(uint256 => uint256)) private totalLPSupply;

    mapping(uint256 => Pair) private pairs;
    mapping(address => uint256) private tokenToPairID;

    event AMMStateChanged(AMMGlobalState _newState);
    event PairCreated(uint256 indexed _pairID, address _token);
    event LiquidityCreated(address _user, uint256 _pairID);
    event PoolJoined(address _user, uint256 _pairID, uint256 _poolTokenAmount);
    event PoolExited(address _user, uint256 _pairID, uint256 _poolTokenAmount);
    event LiquidityIncreased(address _from, uint256 _pairID, uint256 _tokenID, uint256 _amount);
    event LiquidityDecreased(address _to, uint256 _pairID, uint256 _tokenID, uint256 _amount);
    event Swapped(
        address _user,
        uint256 _pairID,
        uint256 _tokenInID,
        uint256 _tokenOutID,
        uint256 _tokenAmountIn,
        uint256 _tokenAmountOut,
        address _to
    );
    event PeriodSwitched(uint256 _newPeriodIndex);
    event WeightUpdated(address _token, uint256[2] _newWeights);
    event ExpiredTokensWithdrawn(address _user, uint256 _amount);
    event SwappingFeeSet(uint256 _swapFee);


    function initialize(
        uint64 _ammId,
        address _underlyingOfIBTAddress,
        address _futureVault,
        ILPToken _poolTokens,
        address _admin,
        address _feesRecipient,
        address _router
    ) public virtual initializer {

        require(_poolTokens.supportsInterface(ERC1155_ERC165), "AMM: Interface not supported");
        require(_underlyingOfIBTAddress != address(0), "AMM: Invalid underlying address");
        require(_futureVault != address(0), "AMM: Invalid future address");
        require(_admin != address(0), "AMM: Invalid admin address");
        require(_feesRecipient != address(0), "AMM: Invalid fees recipient address");

        ammId = _ammId;
        poolTokens = _poolTokens;
        feesRecipient = _feesRecipient;
        futureVault = IFutureVault(_futureVault);
        ibt = IERC20(futureVault.getIBTAddress());

        address _ptAddress = futureVault.getPTAddress();

        underlyingOfIBT = IERC20(_underlyingOfIBTAddress);
        pt = IERC20(_ptAddress);

        tokenToPairID[_ptAddress] = 0;
        _createPair(AMMMaths.ZERO_256, _underlyingOfIBTAddress);
        _status = _NOT_ENTERED;
        _setupRole(ADMIN_ROLE, _admin);
        _setupRole(ROUTER_ROLE, _router);

        state = AMMGlobalState.Created; // waiting to be finalized
    }

    function _createPair(uint256 _pairID, address _tokenAddress) internal {

        pairs[_pairID] = Pair({
            tokenAddress: _tokenAddress,
            weights: [BASE_WEIGHT, BASE_WEIGHT],
            balances: [AMMMaths.ZERO_256, AMMMaths.ZERO_256],
            liquidityIsInitialized: false
        });
        tokenToPairID[_tokenAddress] = _pairID;
        emit PairCreated(_pairID, _tokenAddress);
    }

    function togglePauseAmm() external override isAdmin {

        require(state != AMMGlobalState.Created, "AMM: Not Initialized");
        state = state == AMMGlobalState.Activated ? AMMGlobalState.Paused : AMMGlobalState.Activated;
        emit AMMStateChanged(state);
    }

    function finalize() external override isAdmin {

        require(state == AMMGlobalState.Created, "AMM: Already Finalized");
        currentPeriodIndex = futureVault.getCurrentPeriodIndex();
        require(currentPeriodIndex >= 1, "AMM: Invalid period ID");

        address fytAddress = futureVault.getFYTofPeriod(currentPeriodIndex);
        fyt = IERC20(fytAddress);

        _createPair(uint256(1), fytAddress);

        state = AMMGlobalState.Activated;
        emit AMMStateChanged(AMMGlobalState.Activated);
    }

    function switchPeriod() external override {

        ammIsActive();
        require(futureVault.getCurrentPeriodIndex() > currentPeriodIndex, "AMM: Invalid period index");
        _renewUnderlyingPool();
        _renewFYTPool();
        generatedYieldAtPeriod[currentPeriodIndex] = futureVault.getYieldOfPeriod(currentPeriodIndex);
        currentPeriodIndex = futureVault.getCurrentPeriodIndex();
        emit PeriodSwitched(currentPeriodIndex);
    }

    function _renewUnderlyingPool() internal {

        underlyingSavedPerPeriod[currentPeriodIndex] = pairs[0].balances[1];
        uint256 oldIBTBalance = ibt.balanceOf(address(this));
        uint256 ptBalance = pairs[0].balances[0];
        if (ptBalance != 0) {
            IController(futureVault.getControllerAddress()).withdraw(address(futureVault), ptBalance);
        }
        _saveExpiredIBTs(0, ibt.balanceOf(address(this)).sub(oldIBTBalance), currentPeriodIndex);
        _resetPair(0);
    }

    function _renewFYTPool() internal {

        address fytAddress = futureVault.getFYTofPeriod(futureVault.getCurrentPeriodIndex());
        pairs[1].tokenAddress = fytAddress;
        fyt = IERC20(fytAddress);
        uint256 oldIBTBalance = ibt.balanceOf(address(this));
        uint256 ptBalance = pairs[1].balances[0];
        if (ptBalance != 0) {
            IFutureWallet(futureVault.getFutureWalletAddress()).redeemYield(currentPeriodIndex); // redeem ibt from expired ibt
            IController(futureVault.getControllerAddress()).withdraw(address(futureVault), ptBalance); // withdraw current pt and generated fyt
        }
        _saveExpiredIBTs(1, ibt.balanceOf(address(this)).sub(oldIBTBalance), currentPeriodIndex);
        _resetPair(1);
    }

    function _resetPair(uint256 _pairID) internal {

        pairs[_pairID].balances = [uint256(0), uint256(0)];
        pairs[_pairID].weights = [BASE_WEIGHT, BASE_WEIGHT];
        pairs[_pairID].liquidityIsInitialized = false;
    }

    function _saveExpiredIBTs(
        uint256 _pairID,
        uint256 _ibtGenerated,
        uint256 _periodID
    ) internal {

        poolToUnderlyingAtPeriod[_pairID][_periodID] = futureVault.convertIBTToUnderlying(_ibtGenerated);
    }

    function _updateWeightsFromYieldAtBlock() internal {

        (uint256 newUnderlyingWeight, uint256 yieldRecorded) = _getUpdatedUnderlyingWeightAndYield();
        if (newUnderlyingWeight != pairs[0].weights[1]) {
            lastYieldRecorded = yieldRecorded;
            lastBlockYieldRecorded = block.number;
            pairs[0].weights = [AMMMaths.UNIT - newUnderlyingWeight, newUnderlyingWeight];

            emit WeightUpdated(pairs[0].tokenAddress, pairs[0].weights);
        }
    }

    function getPTWeightInPair() external view override returns (uint256) {

        (uint256 newUnderlyingWeight, ) = _getUpdatedUnderlyingWeightAndYield();
        return AMMMaths.UNIT - newUnderlyingWeight;
    }

    function _getUpdatedUnderlyingWeightAndYield() internal view returns (uint256, uint256) {

        uint256 inverseSpotPrice = (AMMMaths.SQUARED_UNIT).div(getSpotPrice(0, 1, 0));
        uint256 yieldRecorded = futureVault.convertIBTToUnderlying(futureVault.getUnrealisedYieldPerPT());
        if (lastBlockYieldRecorded != block.number && lastYieldRecorded != yieldRecorded) {
            uint256 newSpotPrice =
                ((AMMMaths.UNIT + yieldRecorded).mul(AMMMaths.SQUARED_UNIT)).div(
                    ((AMMMaths.UNIT + lastYieldRecorded).mul(inverseSpotPrice))
                );
            if (newSpotPrice < AMMMaths.UNIT) {
                uint256[2] memory balances = pairs[0].balances;
                uint256 newUnderlyingWeight =
                    balances[1].mul(AMMMaths.UNIT).div(balances[1].add(balances[0].mul(newSpotPrice).div(AMMMaths.UNIT)));
                return (newUnderlyingWeight, yieldRecorded);
            }
        }
        return (pairs[0].weights[1], yieldRecorded);
    }


    function withdrawExpiredToken(address _user, uint256 _lpTokenId) external override {

        nonReentrant();
        _withdrawExpiredToken(_user, _lpTokenId);
        _status = _NOT_ENTERED;
    }

    function _withdrawExpiredToken(address _user, uint256 _lpTokenId) internal {

        (uint256 redeemableTokens, uint256 lastPeriodId, uint256 pairId) = getExpiredTokensInfo(_user, _lpTokenId);
        require(redeemableTokens > 0, "AMM: no redeemable token");
        uint256 userTotal = poolTokens.balanceOf(_user, _lpTokenId);
        uint256 tokenSupply = totalLPSupply[pairId][lastPeriodId];

        totalLPSupply[pairId][lastPeriodId] = totalLPSupply[pairId][lastPeriodId].sub(userTotal);
        poolTokens.burnFrom(_user, _lpTokenId, userTotal);

        if (pairId == 0) {
            uint256 userUnderlyingAmount = underlyingSavedPerPeriod[lastPeriodId].mul(userTotal).div(tokenSupply);
            underlyingOfIBT.safeTransfer(_user, userUnderlyingAmount);
        }
        ibt.safeTransfer(_user, redeemableTokens);

        emit ExpiredTokensWithdrawn(_user, redeemableTokens);
    }

    function getExpiredTokensInfo(address _user, uint256 _lpTokenId)
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        require(poolTokens.getAMMId(_lpTokenId) == ammId, "AMM: invalid amm id");
        uint256 pairID = poolTokens.getPairId(_lpTokenId);
        require(pairID < 2, "AMM: invalid pair id");
        uint256 periodIndex = poolTokens.getPeriodIndex(_lpTokenId);
        require(periodIndex <= currentPeriodIndex, "AMM: invalid period id");
        if (periodIndex == 0 || periodIndex == currentPeriodIndex) return (0, periodIndex, pairID);
        uint256 redeemable =
            poolTokens
                .balanceOf(_user, getLPTokenId(ammId, periodIndex, pairID))
                .mul(poolToUnderlyingAtPeriod[pairID][periodIndex])
                .div(totalLPSupply[pairID][periodIndex]);
        for (uint256 i = periodIndex.add(1); i < currentPeriodIndex; i++) {
            redeemable = redeemable
                .mul(AMMMaths.UNIT.add(futureVault.convertIBTToUnderlying(generatedYieldAtPeriod[i])))
                .div(AMMMaths.UNIT);
        }
        return (
            futureVault.convertUnderlyingtoIBT(
                redeemable.add(
                    redeemable.mul(futureVault.convertIBTToUnderlying(futureVault.getUnrealisedYieldPerPT())).div(
                        AMMMaths.UNIT
                    )
                )
            ),
            periodIndex,
            pairID
        );
    }

    function _getRedeemableExpiredTokens(address _user, uint256 _lpTokenId) internal view returns (uint256) {}


    function swapExactAmountIn(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenAmountIn,
        uint256 _tokenOut,
        uint256 _minAmountOut,
        address _to
    ) external override returns (uint256 tokenAmountOut, uint256 spotPriceAfter) {

        nonReentrant();
        samePeriodIndex();
        onlyRouter();
        ammIsActive();
        pairLiquidityIsInitialized(_pairID);
        tokenIdsAreValid(_tokenIn, _tokenOut);
        _updateWeightsFromYieldAtBlock();

        (tokenAmountOut, spotPriceAfter) = calcOutAndSpotGivenIn(
            _pairID,
            _tokenIn,
            _tokenAmountIn,
            _tokenOut,
            _minAmountOut
        );

        _pullToken(msg.sender, _pairID, _tokenIn, _tokenAmountIn);
        _pushToken(_to, _pairID, _tokenOut, tokenAmountOut);
        emit Swapped(msg.sender, _pairID, _tokenIn, _tokenOut, _tokenAmountIn, tokenAmountOut, _to);
        _status = _NOT_ENTERED;
        return (tokenAmountOut, spotPriceAfter);
    }

    function calcOutAndSpotGivenIn(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenAmountIn,
        uint256 _tokenOut,
        uint256 _minAmountOut
    ) public view override returns (uint256 tokenAmountOut, uint256 spotPriceAfter) {

        tokenIdsAreValid(_tokenIn, _tokenOut);
        uint256[2] memory balances = pairs[_pairID].balances;
        uint256[2] memory weights = pairs[_pairID].weights;
        require(weights[_tokenIn] > 0 && weights[_tokenOut] > 0, "AMM: Invalid token address");

        uint256 spotPriceBefore =
            AMMMaths.calcSpotPrice(balances[_tokenIn], weights[_tokenIn], balances[_tokenOut], weights[_tokenOut], swapFee);

        tokenAmountOut = AMMMaths.calcOutGivenIn(
            balances[_tokenIn],
            weights[_tokenIn],
            balances[_tokenOut],
            weights[_tokenOut],
            _tokenAmountIn,
            swapFee
        );
        require(tokenAmountOut >= _minAmountOut, "AMM: Min amount not reached");

        spotPriceAfter = AMMMaths.calcSpotPrice(
            balances[_tokenIn].add(_tokenAmountIn),
            weights[_tokenIn],
            balances[_tokenOut].sub(tokenAmountOut),
            weights[_tokenOut],
            swapFee
        );
        require(spotPriceAfter >= spotPriceBefore, "AMM: Math approximation error");
    }

    function swapExactAmountOut(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _maxAmountIn,
        uint256 _tokenOut,
        uint256 _tokenAmountOut,
        address _to
    ) external override returns (uint256 tokenAmountIn, uint256 spotPriceAfter) {

        nonReentrant();
        samePeriodIndex();
        onlyRouter();
        ammIsActive();
        pairLiquidityIsInitialized(_pairID);
        tokenIdsAreValid(_tokenIn, _tokenOut);
        _updateWeightsFromYieldAtBlock();

        (tokenAmountIn, spotPriceAfter) = calcInAndSpotGivenOut(_pairID, _tokenIn, _maxAmountIn, _tokenOut, _tokenAmountOut);

        _pullToken(msg.sender, _pairID, _tokenIn, tokenAmountIn);
        _pushToken(_to, _pairID, _tokenOut, _tokenAmountOut);
        emit Swapped(msg.sender, _pairID, _tokenIn, _tokenOut, tokenAmountIn, _tokenAmountOut, _to);
        _status = _NOT_ENTERED;
        return (tokenAmountIn, spotPriceAfter);
    }

    function calcInAndSpotGivenOut(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _maxAmountIn,
        uint256 _tokenOut,
        uint256 _tokenAmountOut
    ) public view override returns (uint256 tokenAmountIn, uint256 spotPriceAfter) {

        tokenIdsAreValid(_tokenIn, _tokenOut);
        uint256 inTokenBalance = pairs[_pairID].balances[_tokenIn];
        uint256 outTokenBalance = pairs[_pairID].balances[_tokenOut];
        uint256 tokenWeightIn = pairs[_pairID].weights[_tokenIn];
        uint256 tokenWeightOut = pairs[_pairID].weights[_tokenOut];
        require(tokenWeightIn > 0 && tokenWeightOut > 0, "AMM: Invalid token address");

        uint256 spotPriceBefore =
            AMMMaths.calcSpotPrice(inTokenBalance, tokenWeightIn, outTokenBalance, tokenWeightOut, swapFee);

        tokenAmountIn = AMMMaths.calcInGivenOut(
            inTokenBalance,
            tokenWeightIn,
            outTokenBalance,
            tokenWeightOut,
            _tokenAmountOut,
            swapFee
        );
        require(tokenAmountIn <= _maxAmountIn, "AMM: Max amount in reached");

        spotPriceAfter = AMMMaths.calcSpotPrice(
            inTokenBalance.add(tokenAmountIn),
            tokenWeightIn,
            outTokenBalance.sub(_tokenAmountOut),
            tokenWeightOut,
            swapFee
        );
        require(spotPriceAfter >= spotPriceBefore, "AMM: Math approximation error");
    }

    function joinSwapExternAmountIn(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenAmountIn,
        uint256 _minPoolAmountOut
    ) external override returns (uint256 poolAmountOut) {

        nonReentrant();
        samePeriodIndex();
        ammIsActive();
        pairLiquidityIsInitialized(_pairID);

        require(_tokenIn < 2, "AMM: Invalid Token Id");
        _updateWeightsFromYieldAtBlock();

        Pair memory pair = pairs[_pairID];

        uint256 inTokenBalance = pair.balances[_tokenIn];
        uint256 tokenWeightIn = pair.weights[_tokenIn];

        require(tokenWeightIn > 0, "AMM: Invalid token address");
        require(_tokenAmountIn <= inTokenBalance.mul(AMMMaths.MAX_IN_RATIO) / AMMMaths.UNIT, "AMM: Max in ratio reached");

        poolAmountOut = AMMMaths.calcPoolOutGivenSingleIn(
            inTokenBalance,
            tokenWeightIn,
            totalLPSupply[_pairID][currentPeriodIndex],
            AMMMaths.UNIT,
            _tokenAmountIn,
            swapFee
        );

        require(poolAmountOut >= _minPoolAmountOut, "AMM: Min amount not reached");

        _pullToken(msg.sender, _pairID, _tokenIn, _tokenAmountIn);
        _joinPool(msg.sender, poolAmountOut, _pairID);
        _status = _NOT_ENTERED;
        return poolAmountOut;
    }

    function joinSwapPoolAmountOut(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _poolAmountOut,
        uint256 _maxAmountIn
    ) external override returns (uint256 tokenAmountIn) {

        nonReentrant();
        samePeriodIndex();
        ammIsActive();
        pairLiquidityIsInitialized(_pairID);
        require(_tokenIn < 2, "AMM: Invalid Token Id");
        _updateWeightsFromYieldAtBlock();
        Pair memory pair = pairs[_pairID];

        uint256 inTokenBalance = pair.balances[_tokenIn];
        uint256 tokenWeightIn = pair.weights[_tokenIn];

        require(tokenWeightIn > 0, "AMM: Invalid token address");
        tokenAmountIn = AMMMaths.calcSingleInGivenPoolOut(
            inTokenBalance,
            tokenWeightIn,
            totalLPSupply[_pairID][currentPeriodIndex],
            AMMMaths.UNIT,
            _poolAmountOut,
            swapFee
        );

        require(tokenAmountIn <= inTokenBalance.mul(AMMMaths.MAX_IN_RATIO) / AMMMaths.UNIT, "AMM: Max in ratio reached");
        require(tokenAmountIn != 0, "AMM: Math approximation error");
        require(tokenAmountIn <= _maxAmountIn, "AMM: Max amount in reached");

        _pullToken(msg.sender, _pairID, _tokenIn, tokenAmountIn);
        _joinPool(msg.sender, _poolAmountOut, _pairID);
        _status = _NOT_ENTERED;
        return tokenAmountIn;
    }

    function exitSwapPoolAmountIn(
        uint256 _pairID,
        uint256 _tokenOut,
        uint256 _poolAmountIn,
        uint256 _minAmountOut
    ) external override returns (uint256 tokenAmountOut) {

        nonReentrant();
        samePeriodIndex();
        ammIsActive();
        pairLiquidityIsInitialized(_pairID);
        require(_tokenOut < 2, "AMM: Invalid Token Id");

        _updateWeightsFromYieldAtBlock();
        Pair memory pair = pairs[_pairID];

        uint256 outTokenBalance = pair.balances[_tokenOut];
        uint256 tokenWeightOut = pair.weights[_tokenOut];
        require(tokenWeightOut > 0, "AMM: Invalid token address");

        tokenAmountOut = AMMMaths.calcSingleOutGivenPoolIn(
            outTokenBalance,
            tokenWeightOut,
            totalLPSupply[_pairID][currentPeriodIndex],
            AMMMaths.UNIT,
            _poolAmountIn,
            swapFee
        );

        require(tokenAmountOut <= outTokenBalance.mul(AMMMaths.MAX_OUT_RATIO) / AMMMaths.UNIT, "AMM: Max out ratio reached");
        require(tokenAmountOut >= _minAmountOut, "AMM: Min amount not reached");

        _exitPool(msg.sender, _poolAmountIn, _pairID);
        _pushToken(msg.sender, _pairID, _tokenOut, tokenAmountOut);
        _status = _NOT_ENTERED;
        return tokenAmountOut;
    }

    function exitSwapExternAmountOut(
        uint256 _pairID,
        uint256 _tokenOut,
        uint256 _tokenAmountOut,
        uint256 _maxPoolAmountIn
    ) external override returns (uint256 poolAmountIn) {

        nonReentrant();
        samePeriodIndex();
        ammIsActive();
        pairLiquidityIsInitialized(_pairID);
        require(_tokenOut < 2, "AMM: Invalid Token Id");

        _updateWeightsFromYieldAtBlock();
        Pair memory pair = pairs[_pairID];

        uint256 outTokenBalance = pair.balances[_tokenOut];
        uint256 tokenWeightOut = pair.weights[_tokenOut];
        require(tokenWeightOut > 0, "AMM: Invalid token address");
        require(
            _tokenAmountOut <= outTokenBalance.mul(AMMMaths.MAX_OUT_RATIO) / AMMMaths.UNIT,
            "AMM: Max out ratio reached"
        );

        poolAmountIn = AMMMaths.calcPoolInGivenSingleOut(
            outTokenBalance,
            tokenWeightOut,
            totalLPSupply[_pairID][currentPeriodIndex],
            AMMMaths.UNIT,
            _tokenAmountOut,
            swapFee
        );

        require(poolAmountIn != 0, "AMM: Math approximation error");
        require(poolAmountIn <= _maxPoolAmountIn, "AMM: Max amount is reached");

        _exitPool(msg.sender, poolAmountIn, _pairID);
        _pushToken(msg.sender, _pairID, _tokenOut, _tokenAmountOut);
        _status = _NOT_ENTERED;
        return poolAmountIn;
    }


    function createLiquidity(uint256 _pairID, uint256[2] memory _tokenAmounts) external override {

        nonReentrant();
        ammIsActive();
        require(!pairs[_pairID].liquidityIsInitialized, "AMM: Liquidity already present");
        require(_tokenAmounts[0] != 0 && _tokenAmounts[1] != 0, "AMM: Tokens Liquidity not exists");
        _pullToken(msg.sender, _pairID, 0, _tokenAmounts[0]);
        _pullToken(msg.sender, _pairID, 1, _tokenAmounts[1]);
        _joinPool(msg.sender, AMMMaths.UNIT, _pairID);
        pairs[_pairID].liquidityIsInitialized = true;
        emit LiquidityCreated(msg.sender, _pairID);
        _status = _NOT_ENTERED;
    }

    function _pullToken(
        address _sender,
        uint256 _pairID,
        uint256 _tokenID,
        uint256 _amount
    ) internal {

        address _tokenIn = _tokenID == 0 ? address(pt) : pairs[_pairID].tokenAddress;
        pairs[_pairID].balances[_tokenID] = pairs[_pairID].balances[_tokenID].add(_amount);
        IERC20(_tokenIn).safeTransferFrom(_sender, address(this), _amount);
        emit LiquidityIncreased(_sender, _pairID, _tokenID, _amount);
    }

    function _pushToken(
        address _recipient,
        uint256 _pairID,
        uint256 _tokenID,
        uint256 _amount
    ) internal {

        address _tokenIn = _tokenID == 0 ? address(pt) : pairs[_pairID].tokenAddress;
        pairs[_pairID].balances[_tokenID] = pairs[_pairID].balances[_tokenID].sub(_amount);
        IERC20(_tokenIn).safeTransfer(_recipient, _amount);
        emit LiquidityDecreased(_recipient, _pairID, _tokenID, _amount);
    }

    function addLiquidity(
        uint256 _pairID,
        uint256 _poolAmountOut,
        uint256[2] memory _maxAmountsIn
    ) external override {

        nonReentrant();
        samePeriodIndex();
        ammIsActive();
        pairLiquidityIsInitialized(_pairID);
        require(_poolAmountOut != 0, "AMM: Amount cannot be 0");
        _updateWeightsFromYieldAtBlock();

        uint256 poolTotal = totalLPSupply[_pairID][currentPeriodIndex];

        for (uint256 i; i < 2; i++) {
            uint256 amountIn = _computeAmountWithShares(pairs[_pairID].balances[i], _poolAmountOut, poolTotal);
            require(amountIn != 0, "AMM: Math approximation error");
            require(amountIn <= _maxAmountsIn[i], "AMM: Max amount in reached");
            _pullToken(msg.sender, _pairID, i, amountIn);
        }
        _joinPool(msg.sender, _poolAmountOut, _pairID);
        _status = _NOT_ENTERED;
    }

    function removeLiquidity(
        uint256 _pairID,
        uint256 _poolAmountIn,
        uint256[2] memory _minAmountsOut
    ) external override {

        nonReentrant();
        ammIsActive();
        pairLiquidityIsInitialized(_pairID);
        require(_poolAmountIn != 0, "AMM: Amount cannot be 0");
        if (futureVault.getCurrentPeriodIndex() == currentPeriodIndex) {
            _updateWeightsFromYieldAtBlock();
        }

        uint256 poolTotal = totalLPSupply[_pairID][currentPeriodIndex];

        for (uint256 i; i < 2; i++) {
            uint256 amountOut = _computeAmountWithShares(pairs[_pairID].balances[i], _poolAmountIn, poolTotal);
            require(amountOut != 0, "AMM: Math approximation error");
            require(amountOut >= _minAmountsOut[i], "AMM: Min amount not reached");
            _pushToken(msg.sender, _pairID, i, amountOut.mul(AMMMaths.UNIT.sub(AMMMaths.EXIT_FEE)).div(AMMMaths.UNIT));
        }
        _exitPool(msg.sender, _poolAmountIn, _pairID);
        _status = _NOT_ENTERED;
    }

    function _joinPool(
        address _user,
        uint256 _amount,
        uint256 _pairID
    ) internal {

        poolTokens.mint(_user, ammId, uint64(currentPeriodIndex), uint32(_pairID), _amount, bytes(""));
        totalLPSupply[_pairID][currentPeriodIndex] = totalLPSupply[_pairID][currentPeriodIndex].add(_amount);
        emit PoolJoined(_user, _pairID, _amount);
    }

    function _exitPool(
        address _user,
        uint256 _amount,
        uint256 _pairID
    ) internal {

        uint256 lpTokenId = getLPTokenId(ammId, currentPeriodIndex, _pairID);

        uint256 exitFee = _amount.mul(AMMMaths.EXIT_FEE).div(AMMMaths.UNIT);
        uint256 userAmount = _amount.sub(exitFee);
        poolTokens.burnFrom(_user, lpTokenId, userAmount);
        poolTokens.safeTransferFrom(_user, feesRecipient, lpTokenId, exitFee, "");

        totalLPSupply[_pairID][currentPeriodIndex] = totalLPSupply[_pairID][currentPeriodIndex].sub(userAmount);
        emit PoolExited(_user, _pairID, _amount);
    }

    function setSwappingFees(uint256 _swapFee) external override isAdmin {

        require(_swapFee < AMMMaths.UNIT, "AMM: Fee must be < 1");
        swapFee = _swapFee;
        emit SwappingFeeSet(_swapFee);
    }

    function rescueFunds(IERC20 _token, address _recipient) external isAdmin {

        uint256 pairId = tokenToPairID[address(_token)];
        bool istokenPresent = false;
        if (pairId == 0) {
            if (_token == pt || address(_token) == pairs[0].tokenAddress) {
                istokenPresent = true;
            }
        } else {
            istokenPresent = true;
        }
        require(!istokenPresent, "AMM: Token is present");
        uint256 toRescue = _token.balanceOf(address(this));
        require(toRescue > 0, "AMM: No funds to rescue");
        _token.safeTransfer(_recipient, toRescue);
    }

    function _computeAmountWithShares(
        uint256 _amount,
        uint256 _sharesAmount,
        uint256 _sharesTotalAmount
    ) internal pure returns (uint256) {

        return _sharesAmount.mul(_amount).div(_sharesTotalAmount);
    }


    function getSpotPrice(
        uint256 _pairID,
        uint256 _tokenIn,
        uint256 _tokenOut
    ) public view override returns (uint256) {

        return
            AMMMaths.calcSpotPrice(
                pairs[_pairID].balances[_tokenIn],
                pairs[_pairID].weights[_tokenIn],
                pairs[_pairID].balances[_tokenOut],
                pairs[_pairID].weights[_tokenOut],
                swapFee
            );
    }

    function getAMMState() external view returns (AMMGlobalState) {

        return state;
    }

    function getFutureAddress() external view override returns (address) {

        return address(futureVault);
    }

    function getPTAddress() external view override returns (address) {

        return address(pt);
    }

    function getUnderlyingOfIBTAddress() external view override returns (address) {

        return address(underlyingOfIBT);
    }

    function getIBTAddress() external view returns (address) {

        return address(ibt);
    }

    function getFYTAddress() external view override returns (address) {

        return address(fyt);
    }

    function getPoolTokenAddress() external view returns (address) {

        return address(poolTokens);
    }

    function getPairWithID(uint256 _pairID) external view override returns (Pair memory) {

        return pairs[_pairID];
    }

    function getTotalSupplyWithTokenId(uint256 _tokenId) external view returns (uint256) {

        uint256 pairId = poolTokens.getPairId(_tokenId);
        uint256 periodId = poolTokens.getPeriodIndex(_tokenId);
        return totalLPSupply[pairId][periodId];
    }

    function getPairIDForToken(address _tokenAddress) external view returns (uint256) {

        if (tokenToPairID[_tokenAddress] == 0)
            require(pairs[0].tokenAddress == _tokenAddress || _tokenAddress == address(pt), "AMM: invalid token address");
        return tokenToPairID[_tokenAddress];
    }

    function getLPTokenId(
        uint256 _ammId,
        uint256 _periodIndex,
        uint256 _pairID
    ) public pure override returns (uint256) {

        return (_ammId << 192) | (_periodIndex << 128) | (_pairID << 96);
    }


    function ammIsActive() private view {

        require(state == AMMGlobalState.Activated, "AMM: AMM not active");
    }

    function pairLiquidityIsInitialized(uint256 _pairID) private view {

        require(pairs[_pairID].liquidityIsInitialized, "AMM: Pair not active");
    }

    function onlyRouter() private view {

        require(hasRole(ROUTER_ROLE, msg.sender), "AMM: Caller should be ROUTER");
    }

    function samePeriodIndex() private view {

        require(futureVault.getCurrentPeriodIndex() == currentPeriodIndex, "AMM: Period index not same");
    }

    function nonReentrant() private {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function tokenIdsAreValid(uint256 _tokenIdInd, uint256 _tokenIdOut) private pure {

        require(_tokenIdInd < 2 && _tokenIdOut < 2 && _tokenIdInd != _tokenIdOut, "AMM: Invalid Token ID");
    }
}