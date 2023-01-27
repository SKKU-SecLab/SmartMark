


pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}







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
}







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






library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}






interface ITccERC721  {


    function totalSupply() external view returns(uint256);


    function tokenCount() external view returns(uint256);


    function createCollectible(uint256 _number, address to) external;

}










contract TccBuyer is Ownable {


    using SafeMath for uint256;
    using ECDSA for bytes32;

    address public noreERC721Address;
    address public efnERC721Address;
    address public drinkChampsERC721Address;

    ITccERC721 private _noreContract;
    ITccERC721 private _efnContract;
    ITccERC721 private _drinkChampsContract;
    mapping (address => uint256) public amountCollected;
    mapping (address => bool) public airdropped;

    bool public saleOn = false;

    uint256 public price = 5 * 10 ** 16; // 0.05 ETH
    uint256 private nonce;
    uint256 public maxAirdrop = 30;
    uint256 public airdropCount = 0;
    uint256 public buyCount = 0;

    ITccERC721[] availableContracts;
    enum Collection{NORE, EFN, DRINKCHAMPS}

    event WithdrawnToOwner(address _operator, uint256 _ethWei);
    event WithdrawnToEntities(address _operator, uint256 _ethWei);
    event SaleChanged(bool _saleIsOn);
    event NftBought(address indexed _from, uint256 _quantity);
    event NftAirdropped(address indexed _from, uint256 _quantity);

        uint256 private CELEBRITY_RATE = 400;
        uint256 private MAIN_RATE = 315;
        uint256 private TEAM_RATE = 235;
        uint256 private PARTNER_RATE = 50;

        address payable public noreCelebrityAddress = payable(0x6d4FBA93638175e476D24a364b51687C7D12e4CE);
        address payable public efnCelebrityAddress = payable(0xA706D17E412298b0d363B63285cCe5108517Fea1);
        address payable public drinkChampsCelebrityAddress = payable(0x6d4FBA93638175e476D24a364b51687C7D12e4CE);

        address payable public mainAddress = payable(0xd6d4d7FAf57f22830d978f793d033d115E605962);
        address payable public teamAddress = payable(0x07D409e34786467F335fF8b7A69e300Effe7E2cf);
        address payable public partnerAddress = payable(0x6d4FBA93638175e476D24a364b51687C7D12e4CE);


    constructor(
        address _noreERC721Address,
        address _efnERC721Address,
        address _drinkChampsERC721Address
    ) {
        noreERC721Address = _noreERC721Address;
        efnERC721Address = _efnERC721Address;
        drinkChampsERC721Address = _drinkChampsERC721Address;

        _noreContract = ITccERC721(noreERC721Address);
        _efnContract = ITccERC721(efnERC721Address);
        _drinkChampsContract = ITccERC721(drinkChampsERC721Address);

        availableContracts.push(_noreContract);
        availableContracts.push(_efnContract);
        availableContracts.push(_drinkChampsContract);
    }

    modifier saleIsOn() {

        require(saleOn, "cannot purchase as the sale is off");
        _;
    }

    modifier isClaimedAuthorized(uint256 quantity, bytes memory signature) {

        require(verifySignature(quantity, signature) == owner(), "caller not authorized to get airdrop");
        _;
    }

    function setPrice(uint256 newPrice) public onlyOwner {

        require(newPrice > 0, 'TccBuyer: price must be > 0');
        price = newPrice;
    }

    function setAirdropSupply(uint256 newMaxAirdrop) public onlyOwner {

        require(newMaxAirdrop >= 0, 'TccBuyer: newAirdropSupply must be >= 0');
        maxAirdrop = newMaxAirdrop;
    }

    function activateSale() public onlyOwner {

        saleOn = true;
        emit SaleChanged(saleOn);
    }

    function deactivateSale() public onlyOwner {

        saleOn = false;
        emit SaleChanged(saleOn);
    }

    function setPaymentRecipients(
        address _noreCelebrityAddress,
        address _efnCelebrityAddress,
        address _drinkChampsCelebrityAddress,
        address _mainAddress,
        address _teamAddress,
        address _partnerAddress
    ) external onlyOwner {

        noreCelebrityAddress = payable(_noreCelebrityAddress);
        efnCelebrityAddress = payable(_efnCelebrityAddress);
        drinkChampsCelebrityAddress = payable(_drinkChampsCelebrityAddress);
        mainAddress = payable(_mainAddress);
        teamAddress = payable(_teamAddress);
        partnerAddress = payable(_partnerAddress);

    }

    function buyToken(uint256 quantity) external payable saleIsOn {

        require(msg.value == price * quantity, "TccBuyer: not the right amount of ETH sent");
        require(checkIfAvailableToMint(quantity + (maxAirdrop - airdropCount)), "the quantity exceed the supply");
        randomMint(quantity, true);
        buyCount += quantity;
        emit NftBought(_msgSender(), quantity);
    }

    function claimAirdrop(uint256 quantity, bytes memory signature) external saleIsOn isClaimedAuthorized(quantity, signature) {

        require(!airdropped[msg.sender], "caller already got airdropped");
        require((quantity + airdropCount) <= maxAirdrop, "quantity requested the exceed max airdrop");
        randomMint(quantity, false);
        airdropped[msg.sender] = true;
        airdropCount += quantity;
        emit NftAirdropped(_msgSender(), quantity);
    }

    function checkIfAirdropped(address airDropAddress) public view returns(bool) {

        return airdropped[airDropAddress];
    }

    function randomMint(uint256 quantity, bool bought) internal {

        require(checkIfAvailableToMint(quantity), "the quantity exceed the supply");
        for(uint i = 0; i < quantity; i++) {
            setAvailableContracts();
            require(availableContracts.length > 0, "can't mint in any contracts");
            ITccERC721 stage2ERC721 = availableContracts[randomNumber()];
            stage2ERC721.createCollectible(1, _msgSender());
            if(bought) {
                amountCollected[address(stage2ERC721)] += price;
            }
            nonce++;
        }
    }

    function verifySignature(uint256 quantity, bytes memory signature) internal view returns(address) {

        return keccak256(abi.encodePacked(address(this), msg.sender, quantity))
        .toEthSignedMessageHash()
        .recover(signature);
    }

    function withdrawToOwner() external onlyOwner {

        uint256 _amount = address(this).balance;
        require(_amount > 0, "No ETH to Withdraw");
        payable(_msgSender()).transfer(_amount);

        emit WithdrawnToOwner(_msgSender(), _amount);
    }

    function checkIfAvailableToMint(uint256 quantity) public view returns(bool) {

        uint _totalMinted;
        uint _maxSupply;
        for (uint i = 0; i < availableContracts.length; i++) {
            _totalMinted += availableContracts[i].tokenCount();
            _maxSupply += availableContracts[i].totalSupply();
        }
        return _totalMinted + quantity <= _maxSupply;
    }

    function setAvailableContracts() internal {

        for (uint i = 0; i < availableContracts.length; i++) {
            if(availableContracts[i].tokenCount() + 1 > availableContracts[i].totalSupply()) {
                availableContracts[i] = availableContracts[availableContracts.length - 1];
                availableContracts.pop();
            }
        }
    }

    function randomNumber() internal view returns (uint8) {

        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, nonce))) % availableContracts.length);
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {

        recipient.transfer(amount);
    }

    function tokenCount() external view returns (uint) {

        return _noreContract.tokenCount() + _efnContract.tokenCount() + _drinkChampsContract.tokenCount();
    }

    function totalSupply() external view returns (uint) {

        return _noreContract.totalSupply() + _efnContract.totalSupply() + _drinkChampsContract.totalSupply();
    }

    function withdrawToEntities() external onlyOwner {

        if(address(this).balance > 0) {
            multiSend();
        }
    }

    function multiSend() internal {


        uint256 noreContractBalance = amountCollected[noreERC721Address];
        uint256 efnContractBalance = amountCollected[efnERC721Address];
        uint256 drinkChampsContractBalance = amountCollected[drinkChampsERC721Address];
        uint256 totalBalance = address(this).balance;

        require(totalBalance == noreContractBalance + efnContractBalance + drinkChampsContractBalance, "problem in total amount to distribute");

        uint256 _noreCelebrityBalance = 0;
        uint256 _efnCelebrityBalance = 0;
        uint256 _drinkChampsCelebrityBalance = 0;
        uint256 _mainBalance = 0;
        uint256 _teamBalance = 0;
        uint256 _partnerBalance = 0;

        if(noreContractBalance > 0) {
            _noreCelebrityBalance += noreContractBalance.mul(CELEBRITY_RATE).div(1000);

            _mainBalance += noreContractBalance.mul(MAIN_RATE).div(1000);
            _teamBalance += noreContractBalance.mul(TEAM_RATE).div(1000);
            _partnerBalance += noreContractBalance.mul(PARTNER_RATE).div(1000);
        }

        if(efnContractBalance > 0) {
            _efnCelebrityBalance += efnContractBalance.mul(CELEBRITY_RATE).div(1000);

            _mainBalance += efnContractBalance.mul(MAIN_RATE).div(1000);
            _teamBalance += efnContractBalance.mul(TEAM_RATE).div(1000);
            _partnerBalance += efnContractBalance.mul(PARTNER_RATE).div(1000);
        }

        if(drinkChampsContractBalance > 0) {
            _drinkChampsCelebrityBalance += drinkChampsContractBalance.mul(CELEBRITY_RATE).div(1000);

            _mainBalance += drinkChampsContractBalance.mul(MAIN_RATE).div(1000);
            _teamBalance += drinkChampsContractBalance.mul(TEAM_RATE).div(1000);
            _partnerBalance += drinkChampsContractBalance.mul(PARTNER_RATE).div(1000);
        }

        transferToAddressETH(noreCelebrityAddress, _noreCelebrityBalance);
        transferToAddressETH(efnCelebrityAddress, _efnCelebrityBalance);
        transferToAddressETH(drinkChampsCelebrityAddress, _drinkChampsCelebrityBalance);
        transferToAddressETH(mainAddress, _mainBalance);
        transferToAddressETH(teamAddress, _teamBalance);
        transferToAddressETH(partnerAddress, _partnerBalance);

        amountCollected[noreERC721Address] -= noreContractBalance;
        amountCollected[efnERC721Address] -= efnContractBalance;
        amountCollected[drinkChampsERC721Address] -= drinkChampsContractBalance;

        emit WithdrawnToEntities(_msgSender(), totalBalance);
    }
}