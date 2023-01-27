
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
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.1;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8;

contract StrategicSale is Ownable {

  using SafeERC20 for IERC20;

  mapping(address => bool) public authTokens;

  address public immutable aten; //Mainnet 0x86cEB9FA7f5ac373d275d328B7aCA1c05CFb0283;

  mapping(address => uint256) public presales;
  address[] private buyers;
  uint128 public constant ATEN_ICO_PRICE = 50;
  uint128 public constant PRICE_DIVISOR = 10000;
  uint256 public tokenSold = 0;
  uint256 public dateStartVesting = 0;
  mapping(uint16 => uint256) public distributeIndex;
  mapping(address => uint256) private whitelist;

  uint8[] public distributionToken = [
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5
  ];
  mapping(uint8 => bool) private claimed;

  bool public activeSale = false;

  event Prebuy(address indexed from, uint256 amount);

  constructor(
    address distributeToken,
    address[] memory tokens
  ) {
    for (uint256 i = 0; i < tokens.length; i++) {
      authTokens[tokens[i]] = true;
    }
    aten = distributeToken;
  }

  function startSale(bool isActive) external onlyOwner {

    activeSale = isActive;
  }

  function startVesting() external onlyOwner {

    dateStartVesting = block.timestamp;
  }

  function buy(uint256 amount, address token) external payable {

    require(activeSale, "Sale is not active");
    require(authTokens[token] == true, "Token not approved for this ICO");
    IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    amount = (amount * 10**18) / (10**IERC20Metadata(token).decimals());
    uint256 atenSold = (amount *
      10**IERC20Metadata(aten).decimals() *
      PRICE_DIVISOR) /
      1 ether /
      ATEN_ICO_PRICE;
    uint256 allowed = whitelist[msg.sender] - presales[msg.sender];
    require(atenSold <= allowed, "Not enough whitelisted tokens");
    tokenSold += atenSold;
    if (presales[msg.sender] == 0) {
      buyers.push(msg.sender);
    }
    presales[msg.sender] += atenSold;
    emit Prebuy(msg.sender, atenSold);
  }

  function whitelistAddresses(
    address[] calldata _tos,
    uint256[] calldata _amounts
  ) external onlyOwner {

    require(_tos.length == _amounts.length, "Arguments length mismatch");
    for (uint256 i = 0; i < _tos.length; i++) {
      require(_amounts[i] > 0, "Amount must be greater than 0");
      whitelist[_tos[i]] = _amounts[i];
    }
  }

  function withdraw(address[] calldata tokens, address to) external onlyOwner {

    bool doneDistribute = true;
    for (uint8 i = 0; i < distributionToken.length; i++) {
      if (claimed[i] == false) doneDistribute = false;
    }
    for (uint256 i = 0; i < tokens.length; i++) {
      if (tokens[i] == aten) {
        IERC20(aten).safeTransfer(
          to,
          IERC20(aten).balanceOf(address(this)) -
            (doneDistribute ? 0 : tokenSold)
        );
      } else {
        IERC20(tokens[i]).safeTransfer(
          to,
          IERC20(tokens[i]).balanceOf(address(this))
        );
      }
    }
    if (address(this).balance > 0) {
      to.call{ value: address(this).balance }("");
    }
  }

  function distribute(uint8 month) external {

    require(dateStartVesting > 0, "Vesting not active");
    require(month <= monthIndex(), "Month not available");
    require(claimed[month] == false, "Already distributed");

    uint256 indexLimit = buyers.length > 300
      ? distributeIndex[month] + 300
      : buyers.length;
    indexLimit = indexLimit > buyers.length ? buyers.length : indexLimit;
    for (uint256 index = distributeIndex[month]; index < indexLimit; index++) {
      uint256 amount = (presales[buyers[index]] * distributionToken[month]) /
        100;
      if (amount > 0) {
        IERC20(aten).safeTransfer(buyers[index], amount);
      }
      distributeIndex[month] = index;
    }
    if (distributeIndex[month] == buyers.length - 1) {
      claimed[month] = true;
    }
  }
 
  function monthIndex() public view returns (uint8) {

    return uint8((block.timestamp - dateStartVesting) / 30 days);
  }

  function available(uint8 month) public view returns (uint8) {

    uint8 mi = month == 0 ? monthIndex() : month;
    return claimed[mi] ? 0 : distributionToken[mi];
  }

  function changeAddress(address newTo) external {

    require(presales[msg.sender] > 0, "No tokens to change");
    uint256 amount = presales[msg.sender];
    presales[newTo] = amount;
    presales[msg.sender] = 0;
    buyers.push(newTo);
    emit Prebuy(newTo, amount);
  }
}