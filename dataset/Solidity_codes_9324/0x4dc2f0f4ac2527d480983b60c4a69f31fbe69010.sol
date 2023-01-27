
pragma solidity ^0.8.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address previousOwner, address newOwner);

    function owner() external view returns (address) {

        return _owner;
    }

    function setOwner(address newOwner) internal {

        _owner = newOwner;
    }

    modifier onlyOwner() {

        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        setOwner(newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

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
}//MIT
pragma solidity ^0.8.0;


interface IERC20Decimals {

    function decimals() external view returns (uint8);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

}


contract Exchanger is Initializable, Ownable {

    address[] public purchasedTokens;
    address public selledToken;
    address public beneficiary;

    uint ratePur;
    uint rateSel;
    
    mapping (address => bool) public isPurchased;

    function initialize(address[] memory _purchasedTokens, address _selledToken, address _beneficiary, uint256 _ratePur, uint256 _rateSel) external initializer {

        setOwner(msg.sender);

        require(_selledToken != address(0), "zero vesting proxy token address");
        require(_beneficiary != address(0), "zero beneficiary address");
        for (uint i = 0 ; i < _purchasedTokens.length; i++) {
            addPurchasedToken(_purchasedTokens[i]);
        }
        selledToken = _selledToken;
        beneficiary = _beneficiary;

        ratePur = _ratePur;
        rateSel = _rateSel;
    }

    function buy(address _token, uint amount) public {        

        require(isPurchased[_token], "(buy) the token is not purchased");
        require(amount > 0, "(buy) zero amount");
        (uint purAmount, uint selAmount) = prices(_token, amount);
        require(selAmount > 0, "(buy) zero contribution");
        require(IERC20Upgradeable(_token).allowance(msg.sender, address(this)) >= purAmount, "(buy) not approved token amount");

        IERC20Decimals(_token).transferFrom(msg.sender, beneficiary, purAmount);
        IERC20Upgradeable(selledToken).transfer(msg.sender, selAmount);
    }

    function balance(address _token) public view returns(uint256) {

        return IERC20Upgradeable(_token).balanceOf(address(this));
    }

    function prices(address token, uint selAmount) public view returns(uint _purchasedToken, uint _selAmount) {

        uint256 _selDecimalCorrection = 10**IERC20Decimals(selledToken).decimals();
        uint256 _purDecimalCorrection = 10**IERC20Decimals(token).decimals();

        _purchasedToken = selAmount * ratePur / (rateSel * _selDecimalCorrection / _purDecimalCorrection);
        _selAmount = _purchasedToken * (rateSel * _selDecimalCorrection / _purDecimalCorrection) / ratePur;
    }
    
    function getRateFromUSDT(address token, uint usdtAmount) public view returns(uint) {

        uint256 _selDecimalCorrection = 10**IERC20Decimals(selledToken).decimals();
        uint256 _purDecimalCorrection = 10**IERC20Decimals(token).decimals();

        uint _sellingAmount = usdtAmount * (rateSel * _selDecimalCorrection / _purDecimalCorrection) /ratePur;
        return _sellingAmount;
    }

    function getPurchasedTokens() public view returns(address[] memory) {

        return purchasedTokens;
    }

    function updateRate(uint _ratePur, uint _rateSel) public onlyOwner {

        ratePur = _ratePur;
        rateSel = _rateSel;
    }

    function updateToken(address token) public onlyOwner {

        require(token != address(0), "zero address of the token");
        selledToken = token;
    }

    function updateBeneficiary(address _beneficiary) public onlyOwner {

        beneficiary = _beneficiary;
    }

    function withdrawERC20(address token, uint amount) public onlyOwner {

        require(IERC20Upgradeable(token).balanceOf(address(this)) >= amount, "insufficient balance");
        IERC20Upgradeable(token).transfer(msg.sender, amount);
    }

    function addPurchasedToken(address _token) public onlyOwner {

        require(_token != address(0), "(addPurchasedToken) zero purchased token address");
        require(!isPurchased[_token], "(addPurchasedToken) the already purchased token");
        purchasedTokens.push(_token);
        isPurchased[_token] = true;
    }

    function removePurchasedToken(address _token) public onlyOwner {

        require(isPurchased[_token], "(removePurchasedToken) not purchased token");
        address[] storage tokens = purchasedTokens;
        deleteAddressFromArray(tokens, _token);
        isPurchased[_token] = false;
    }

    function deleteAddressFromArray(address[] storage _array, address _address) private {

        for (uint i = 0; i < _array.length; i++) {
            if (_array[i] == _address) {
                address temp = _array[_array.length-1];
                _array[_array.length-1] = _address;
                _array[i] = temp;
            }
        }

        _array.pop();
    }
}