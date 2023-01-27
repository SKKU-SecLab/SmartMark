pragma solidity 0.6.5;


library SigUtil {

    function recover(bytes32 hash, bytes memory sig) internal pure returns (address recovered) {

        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28);

        recovered = ecrecover(hash, v, r, s);
        require(recovered != address(0));
    }

    function recoverWithZeroOnFailure(bytes32 hash, bytes memory sig) internal pure returns (address) {

        if (sig.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    function prefixed(bytes32 hash) internal pure returns (bytes memory) {

        return abi.encodePacked("\x19Ethereum Signed Message:\n32", hash);
    }
}pragma solidity 0.6.5;


library SafeMathWithRequire {

    using SafeMathWithRequire for uint256;

    uint256 constant DECIMALS_18 = 1000000000000000000;
    uint256 constant DECIMALS_12 = 1000000000000;
    uint256 constant DECIMALS_9 = 1000000000;
    uint256 constant DECIMALS_6 = 1000000;

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }

        c = a * b;
        require(c / a == b, "overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "divbyzero");
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "undeflow");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;
        require(c >= a, "overflow");
        return c;
    }

    function sqrt6(uint256 a) internal pure returns (uint256 c) {

        a = a.mul(DECIMALS_12);
        uint256 tmp = a.add(1) / 2;
        c = a;
        while (tmp < c) {
            c = tmp;
            tmp = ((a / tmp) + tmp) / 2;
        }
    }

    function sqrt3(uint256 a) internal pure returns (uint256 c) {

        a = a.mul(DECIMALS_6);
        uint256 tmp = a.add(1) / 2;
        c = a;
        while (tmp < c) {
            c = tmp;
            tmp = ((a / tmp) + tmp) / 2;
        }
    }

    function cbrt6(uint256 a) internal pure returns (uint256 c) {

        a = a.mul(DECIMALS_18);
        uint256 tmp = a.add(2) / 3;
        c = a;
        while (tmp < c) {
            c = tmp;
            uint256 tmpSquare = tmp**2;
            require(tmpSquare > tmp, "overflow");
            tmp = ((a / tmpSquare) + (tmp * 2)) / 3;
        }
        return c;
    }

    function cbrt3(uint256 a) internal pure returns (uint256 c) {

        a = a.mul(DECIMALS_9);
        uint256 tmp = a.add(2) / 3;
        c = a;
        while (tmp < c) {
            c = tmp;
            uint256 tmpSquare = tmp**2;
            require(tmpSquare > tmp, "overflow");
            tmp = ((a / tmpSquare) + (tmp * 2)) / 3;
        }
        return c;
    }

    function rt6_3(uint256 a) internal pure returns (uint256 c) {

        a = a.mul(DECIMALS_18);
        uint256 tmp = a.add(5) / 6;
        c = a;
        while (tmp < c) {
            c = tmp;
            uint256 tmpFive = tmp**5;
            require(tmpFive > tmp, "overflow");
            tmp = ((a / tmpFive) + (tmp * 5)) / 6;
        }
    }
}pragma solidity 0.6.5;


contract Admin {

    address internal _admin;

    event AdminChanged(address oldAdmin, address newAdmin);

    function getAdmin() external view returns (address) {

        return _admin;
    }

    function changeAdmin(address newAdmin) external {

        require(msg.sender == _admin, "only admin can change admin");
        emit AdminChanged(_admin, newAdmin);
        _admin = newAdmin;
    }

    modifier onlyAdmin() {

        require(msg.sender == _admin, "only admin allowed");
        _;
    }
}//MIT
pragma solidity 0.6.5; // TODO: update once upgrade is complete


contract AuthValidator is Admin {

    address public _signingAuthWallet;

    event SigningWallet(address indexed signingWallet);

    constructor(address adminWallet, address initialSigningWallet) public {
        _admin = adminWallet;
        _updateSigningAuthWallet(initialSigningWallet);
    }

    function updateSigningAuthWallet(address newSigningWallet) external onlyAdmin {

        _updateSigningAuthWallet(newSigningWallet);
    }

    function _updateSigningAuthWallet(address newSigningWallet) internal {

        require(newSigningWallet != address(0), "INVALID_SIGNING_WALLET");
        _signingAuthWallet = newSigningWallet;
        emit SigningWallet(newSigningWallet);
    }

    function isAuthValid(bytes memory signature, bytes32 hashedData) public view returns (bool) {

        address signer = SigUtil.recover(keccak256(SigUtil.prefixed(hashedData)), signature);
        return signer == _signingAuthWallet;
    }
}