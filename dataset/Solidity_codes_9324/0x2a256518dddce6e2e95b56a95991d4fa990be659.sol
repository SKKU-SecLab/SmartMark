pragma solidity 0.5.15;

contract IOwnable {

    function getOwner() public view returns (address);

    function transferOwnership(address _newOwner) public returns (bool);

}

contract Ownable is IOwnable {

    address internal owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function getOwner() public view returns (address) {

        return owner;
    }

    function transferOwnership(address _newOwner) public onlyOwner returns (bool) {

        require(_newOwner != address(0));
        onTransferOwnership(owner, _newOwner);
        owner = _newOwner;
        return true;
    }

    function onTransferOwnership(address, address) internal;

}

contract IAffiliateValidator {

    function validateReference(address _account, address _referrer) external view returns (bool);

}

contract AffiliateValidator is Ownable, IAffiliateValidator {

    mapping (address => bytes32) public keys;

    mapping (address => bool) public operators;

    mapping (uint256 => bool) public usedSalts;

    function addOperator(address _operator) external onlyOwner {

        operators[_operator] = true;
    }

    function removeOperator(address _operator) external onlyOwner {

        operators[_operator] = false;
    }

    function addKey(bytes32 _key, uint256 _salt, bytes32 _r, bytes32 _s, uint8 _v) external {

        require(!usedSalts[_salt], "Salt already used");
        bytes32 _hash = getKeyHash(_key, msg.sender, _salt);
        require(isValidSignature(_hash, _r, _s, _v), "Signature invalid");
        usedSalts[_salt] = true;
        keys[msg.sender] = _key;
    }

    function getKeyHash(bytes32 _key, address _account, uint256 _salt) public view returns (bytes32) {

        return keccak256(abi.encodePacked(_key, _account, address(this), _salt));
    }

    function isValidSignature(bytes32 _hash, bytes32 _r, bytes32 _s, uint8 _v) public view returns (bool) {

        address recovered = ecrecover(
            keccak256(abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                _hash
            )),
            _v,
            _r,
            _s
        );
        return operators[recovered];
    }

    function validateReference(address _account, address _referrer) external view returns (bool) {

        bytes32 _accountKey = keys[_account];
        bytes32 _referralKey = keys[_referrer];
        if (_accountKey == bytes32(0) || _referralKey == bytes32(0)) {
            return false;
        }
        return _accountKey != _referralKey;
    }

    function onTransferOwnership(address, address) internal {}

}