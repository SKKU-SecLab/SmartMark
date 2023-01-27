


pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}



pragma solidity ^0.6.2;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}



pragma solidity ^0.6.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.6.2;

library Address {

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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
}



pragma solidity ^0.6.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;



contract ERC721Sender {


  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  mapping(address => mapping (uint256 => mapping (address => uint256))) public rewards;

  mapping(address => bool) public isCached;
  mapping(address => IERC721Enumerable) public erc721Cache;
  mapping(address => IERC20) public erc20Cache;



  function setRewards(address[] memory erc721Addresses,
                      uint256[] memory tokenIds,
                      address erc20Address,
                      uint256[] memory amounts) public {

    uint256 totalToTransfer = 0;
    if (! isCached[erc20Address]) {
      erc20Cache[erc20Address] = IERC20(erc20Address);
      isCached[erc20Address] = true;
    }
    for (uint256 i = 0; i < erc721Addresses.length; i += 1) {
      if (! isCached[erc721Addresses[i]]) {
        erc721Cache[erc721Addresses[i]] = IERC721Enumerable(erc721Addresses[i]);
        isCached[erc721Addresses[i]] = true;
      }
      uint256 previousRewardAmount = rewards[erc721Addresses[i]][tokenIds[i]][erc20Address];
      rewards[erc721Addresses[i]][tokenIds[i]][erc20Address] = previousRewardAmount.add(amounts[i]);
      totalToTransfer = totalToTransfer.add(amounts[i]);
    }
    erc20Cache[erc20Address].safeTransferFrom(msg.sender, address(this), totalToTransfer);
  }



  function takeRewards(address erc721Address, uint256 tokenId, address erc20Address) public returns (uint256) {

    if (! isCached[erc721Address]) {
        erc721Cache[erc721Address] = IERC721Enumerable(erc721Address);
        isCached[erc721Address] = true;
    }
    if (! isCached[erc20Address]) {
      erc20Cache[erc20Address] = IERC20(erc20Address);
      isCached[erc20Address] = true;
    }

    require(erc721Cache[erc721Address].ownerOf(tokenId) == msg.sender, "Not owner");

    uint256 rewardAmount = rewards[erc721Address][tokenId][erc20Address];
    delete rewards[erc721Address][tokenId][erc20Address];

    erc20Cache[erc20Address].safeTransfer(msg.sender, rewardAmount);

    return(rewardAmount);
  }



  function sendRewards(address[] memory erc721Addresses,
                      uint256[] memory tokenIds,
                      address erc20Address,
                      uint256[] memory amounts) public {

    if (! isCached[erc20Address]) {
      erc20Cache[erc20Address] = IERC20(erc20Address);
      isCached[erc20Address] = true;
    }
    for (uint256 i = 0; i < erc721Addresses.length; i += 1) {
      if (! isCached[erc721Addresses[i]]) {
        erc721Cache[erc721Addresses[i]] = IERC721Enumerable(erc721Addresses[i]);
        isCached[erc721Addresses[i]] = true;
      }
      address erc721Holder = erc721Cache[erc721Addresses[i]].ownerOf(tokenIds[i]);
      erc20Cache[erc20Address].safeTransferFrom(msg.sender, erc721Holder, amounts[i]);
    }
  }

}