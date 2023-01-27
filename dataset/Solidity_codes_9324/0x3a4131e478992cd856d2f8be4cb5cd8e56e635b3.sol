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

contract Affiliates {
    mapping (address => bytes32) public fingerprints;

    mapping (address => address) public referrals;

    mapping (address => bool) public affiliateValidators;

    function createAffiliateValidator() public returns (AffiliateValidator) {
        AffiliateValidator _affiliateValidator = new AffiliateValidator();
        _affiliateValidator.transferOwnership(msg.sender);
        affiliateValidators[address(_affiliateValidator)] = true;
        return _affiliateValidator;
    }

    function setFingerprint(bytes32 _fingerprint) external {
        fingerprints[msg.sender] = _fingerprint;
    }

    function setReferrer(address _referrer) external {
        require(msg.sender != _referrer);

        if (referrals[msg.sender] != address(0)) {
            return;
        }

        referrals[msg.sender] = _referrer;
    }

    function getAccountFingerprint(address _account) external view returns (bytes32) {
        return fingerprints[_account];
    }

    function getReferrer(address _account) external view returns (address) {
        return referrals[_account];
    }

    function getAndValidateReferrer(address _account, IAffiliateValidator _affiliateValidator) external view returns (address) {
        address _referrer = referrals[_account];
        if (_referrer == address(0) || _account == _referrer) {
            return address(0);
        }
        if (_affiliateValidator == IAffiliateValidator(0)) {
            return _referrer;
        }
        bool _success = _affiliateValidator.validateReference(_account, _referrer);
        if (!_success) {
            return address(0);
        }
        return _referrer;
    }
}