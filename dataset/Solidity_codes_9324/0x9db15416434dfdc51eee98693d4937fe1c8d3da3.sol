
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

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
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
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router02 {

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);


    function factory() external pure returns (address);


    function WETH() external pure returns (address);

}

interface IUniswapV2Factory02 {

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

}// MIT
pragma solidity ^0.8.0;


contract LessLibrary is Ownable {

    address public usd;
    address[] public factoryAddress = new address[](2);

    uint256 private minInvestorBalance = 1000 * 1e18;
    uint256 private votingTime = 5 minutes; //three days
    uint256 private registrationTime = 5 minutes; // one day
    uint256 private minVoterBalance = 500 * 1e18; // minimum number of  tokens to hold to vote
    uint256 private minCreatorStakedBalance = 10000 * 1e18; // minimum number of tokens to hold to launch rocket
    uint8 private feePercent = 2;
    uint256 private usdFee;
    address private uniswapRouter; // uniswapV2 Router
    address payable private lessVault;
    address private devAddress;
    PresaleInfo[] private presaleAddresses; // track all presales created

    mapping(address=> bool) public stablecoinWhitelist;

    mapping(address => bool) private isPresale;
    mapping(bytes32 => bool) private usedSignature;
    mapping(address => bool) private signers; //adresses that can call sign functions

    struct PresaleInfo {
        bytes32 title;
        address presaleAddress;
        string description;
        bool isCertified;
        uint256 openVotingTime;
    }

    modifier onlyDev() {

        require(owner() == msg.sender || msg.sender == devAddress, "onlyDev");
        _;
    }

    modifier onlyPresale() {

        require(isPresale[msg.sender], "Not presale");
        _;
    }

    modifier onlyFactory() {

        require(factoryAddress[0] == msg.sender || factoryAddress[1] == msg.sender, "onlyFactory");
        _;
    }

    modifier factoryIndexCheck(uint8 _index){

        require(_index == 0 || _index == 1, "Invalid index");
        _;
    }

    constructor(address _dev, address payable _vault, address _uniswapRouter, address _usd, address[] memory _stablecoins, uint8 _usdDecimals) {
        require(_dev != address(0) && _vault != address(0) && _usdDecimals > 0, "Wrong params");
        devAddress = _dev;
        lessVault = _vault;
        uniswapRouter = _uniswapRouter;
        usd = _usd;
        usdFee = 1000 * 10 ** _usdDecimals;
        for(uint256 i=0; i <_stablecoins.length; i++){
            stablecoinWhitelist[_stablecoins[i]] = true;
        }
    }

    function setFactoryAddress(address _factory, uint8 _index) external onlyDev factoryIndexCheck(_index){

        require(_factory != address(0), "not 0");
        factoryAddress[_index] = _factory;
    }

    function setUsdFee(uint256 _newAmount) external onlyDev {

        require(_newAmount > 0, "0 amt");
        usdFee = _newAmount;
    }

    function setUsdAddress(address _newAddress) external onlyDev {

        require(_newAddress != address(0), "0 addr");
        usd = _newAddress;
    }

    function addPresaleAddress(
        address _presale,
        bytes32 _title,
        string memory _description,
        bool _type,
        uint256 _openVotingTime
    )
        external
        onlyFactory
        returns (uint256)
    {

        presaleAddresses.push(PresaleInfo(_title, _presale, _description, _type, _openVotingTime));
        isPresale[_presale] = true;
        return presaleAddresses.length - 1;
    }

    function addOrRemoveStaiblecoin(address _stablecoin, bool _isValid) external onlyDev {

        require(_stablecoin != address(0), "Not 0 addr");
        if(_isValid){
            require(!stablecoinWhitelist[_stablecoin], "Wrong param");
        }
        else {
            require(stablecoinWhitelist[_stablecoin], "Wrong param");
        }
        stablecoinWhitelist[_stablecoin] = _isValid;
    }

    function changeDev(address _newDev) external onlyDev {

        require(_newDev != address(0), "Wrong new address");
        devAddress = _newDev;
    }

    function setVotingTime(uint256 _newVotingTime) external onlyDev {

        require(_newVotingTime > 0, "Wrong new time");
        votingTime = _newVotingTime;
    }

    function setRegistrationTime(uint256 _newRegistrationTime) external onlyDev {

        require(_newRegistrationTime > 0, "Wrong new time");
        registrationTime = _newRegistrationTime;
    }

    function setUniswapRouter(address _uniswapRouter) external onlyDev {

        uniswapRouter = _uniswapRouter;
    }

    function setSingUsed(bytes memory _sign, address _presale) external {

        require(isPresale[_presale], "u have no permition");
        usedSignature[keccak256(_sign)] = true;
    }

    function addOrRemoveSigner(address _address, bool _canSign) external onlyDev {

        signers[_address] = _canSign;
    }

    function getPresalesCount() external view returns (uint256) {

        return presaleAddresses.length;
    }

    function getUsdFee() external view returns(uint256, address) {

        return (usdFee, usd);
    }

    function isValidStablecoin(address _stablecoin) external view returns (bool) {

        return stablecoinWhitelist[_stablecoin];
    }

    function getPresaleAddress(uint256 id) external view returns (address) {

        return presaleAddresses[id].presaleAddress;
    }

    function getVotingTime() external view returns(uint256){

        return votingTime;
    }

    function getRegistrationTime() external view returns(uint256){

        return registrationTime;
    }

    function getMinInvestorBalance() external view returns (uint256) {

        return minInvestorBalance;
    }

    function getDev() external view onlyFactory returns (address) {

        return devAddress;
    }

    function getMinVoterBalance() external view returns (uint256) {

        return minVoterBalance;
    }
    function getMinYesVotesThreshold(uint256 totalStakedAmount) external pure returns (uint256) {

        uint256 stakedAmount = totalStakedAmount;
        return stakedAmount / 10;
    }

    function getFactoryAddress(uint8 _index) external view factoryIndexCheck(_index) returns (address) {

        return factoryAddress[_index];
    }

    function getMinCreatorStakedBalance() external view returns (uint256) {

        return minCreatorStakedBalance;
    }

    function getUniswapRouter() external view returns (address) {

        return uniswapRouter;
    }

    function calculateFee(uint256 amount) external view onlyPresale returns(uint256){

        return amount * feePercent / 100;
    }

    function getVaultAddress() external view onlyPresale returns(address payable){

        return lessVault;
    }

    function getArrForSearch() external view returns(PresaleInfo[] memory) {

        return presaleAddresses;
    }
    
    function _verifySigner(bytes32 data, bytes memory signature, uint8 _index)
        public
        view
        factoryIndexCheck(_index)
        returns (bool)
    {

        address messageSigner =
            ECDSA.recover(data, signature);
        require(
            isSigner(messageSigner),
            "Unauthorised signer"
        );
        return true;
    }

    function getSignUsed(bytes memory _sign) external view returns(bool) {

        return usedSignature[keccak256(_sign)];
    }

    function isSigner(address _address) internal view returns (bool) {

        return signers[_address];
    }
}// MIT
pragma solidity ^0.8.0;


library Calculation1 {


    function countAmountOfTokens(
        uint256 _hardCap,
        uint256 _tokenPrice,
        uint256 _liqPrice,
        uint256 _liqPerc,
        uint8 _decimalsToken,
        uint8 _decimalsNativeToken
    ) external pure returns (uint256[] memory) {

        uint256[] memory tokenAmounts = new uint256[](3);
        if (_liqPrice != 0 && _liqPerc != 0) {
            uint256 factor;
            if(_decimalsNativeToken != 18){
                if(_decimalsNativeToken < 18)
                    factor = uint256(10)**uint256(18 - _decimalsNativeToken);
                else
                    factor = uint256(10)**uint256(_decimalsNativeToken - 18);
            }
            else
                factor = 1;
            tokenAmounts[0] = ((_hardCap *
                _liqPerc *
                (uint256(10)**uint256(_decimalsToken)) * factor) / (_liqPrice * 100));
            require(tokenAmounts[0] > 0, "Wrokng");
        }

        tokenAmounts[1] =
            (_hardCap * (uint256(10)**uint256(_decimalsToken))) /
            _tokenPrice;
        tokenAmounts[2] = tokenAmounts[0] + tokenAmounts[1];
        require(tokenAmounts[1] > 0, "Wrong parameters");
        return tokenAmounts;
    }

}