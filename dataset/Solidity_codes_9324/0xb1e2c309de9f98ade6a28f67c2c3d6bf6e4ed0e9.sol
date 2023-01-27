

pragma solidity =0.7.6;  
pragma experimental ABIEncoderV2;



abstract contract IDSProxy {

    function execute(address _target, bytes memory _data) public payable virtual returns (bytes32);

    function setCache(address _cacheAddr) public payable virtual returns (bool);

    function owner() public view virtual returns (address);
}  



abstract contract DSGuard {
    function canCall(
        address src_,
        address dst_,
        bytes4 sig
    ) public view virtual returns (bool);

    function permit(
        bytes32 src,
        bytes32 dst,
        bytes32 sig
    ) public virtual;

    function forbid(
        bytes32 src,
        bytes32 dst,
        bytes32 sig
    ) public virtual;

    function permit(
        address src,
        address dst,
        bytes32 sig
    ) public virtual;

    function forbid(
        address src,
        address dst,
        bytes32 sig
    ) public virtual;
}

abstract contract DSGuardFactory {
    function newGuard() public virtual returns (DSGuard guard);
}  



abstract contract DSAuthority {
    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) public view virtual returns (bool);
}  





contract DSAuthEvents {

    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
}

contract DSAuth is DSAuthEvents {

    DSAuthority public authority;
    address public owner;

    constructor() {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public auth {

        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_) public auth {

        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {

        require(isAuthorized(msg.sender, msg.sig), "Not authorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {

        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}  



abstract contract IDFSRegistry {
 
    function getAddr(bytes32 _id) public view virtual returns (address);

    function addNewContract(
        bytes32 _id,
        address _contractAddr,
        uint256 _waitPeriod
    ) public virtual;

    function startContractChange(bytes32 _id, address _newContractAddr) public virtual;

    function approveContractChange(bytes32 _id) public virtual;

    function cancelContractChange(bytes32 _id) public virtual;

    function changeWaitPeriod(bytes32 _id, uint256 _newWaitPeriod) public virtual;
}  



interface IERC20 {

    function totalSupply() external view returns (uint256 supply);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function transfer(address _to, uint256 _value) external returns (bool success);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);


    function approve(address _spender, uint256 _value) external returns (bool success);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    function decimals() external view returns (uint256 digits);


    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}  



library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}  







library SafeERC20 {

    using SafeMath for uint256;
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

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}  



contract AdminVault {

    address public owner;
    address public admin;

    constructor() {
        owner = msg.sender;
        admin = 0x25eFA336886C74eA8E282ac466BdCd0199f85BB9;
    }

    function changeOwner(address _owner) public {

        require(admin == msg.sender, "msg.sender not admin");
        owner = _owner;
    }

    function changeAdmin(address _admin) public {

        require(admin == msg.sender, "msg.sender not admin");
        admin = _admin;
    }

}  








contract AdminAuth {

    using SafeERC20 for IERC20;

    address public constant ADMIN_VAULT_ADDR = 0xCCf3d848e08b94478Ed8f46fFead3008faF581fD;

    AdminVault public constant adminVault = AdminVault(ADMIN_VAULT_ADDR);

    modifier onlyOwner() {

        require(adminVault.owner() == msg.sender, "msg.sender not owner");
        _;
    }

    modifier onlyAdmin() {

        require(adminVault.admin() == msg.sender, "msg.sender not admin");
        _;
    }

    function withdrawStuckFunds(address _token, address _receiver, uint256 _amount) public onlyOwner {

        if (_token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(_receiver).transfer(_amount);
        } else {
            IERC20(_token).safeTransfer(_receiver, _amount);
        }
    }

    function kill() public onlyAdmin {

        selfdestruct(payable(msg.sender));
    }
}  



abstract contract IProxyRegistry {
    function proxies(address _owner) public virtual view returns (address);
    function build(address) public virtual returns (address);
}  







contract DFSProxyRegistry is AdminAuth {

    IProxyRegistry public mcdRegistry = IProxyRegistry(0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4);

    mapping(address => address) public changedOwners;
    mapping(address => address[]) public additionalProxies;

    function changeMcdOwner(address _user, address _proxy) public onlyOwner {

        if (IDSProxy(_proxy).owner() == _user) {
            changedOwners[_user] = _proxy;
        }
    }

    function getMcdProxy(address _user) public view returns (address) {

        address proxyAddr = mcdRegistry.proxies(_user);

        if (changedOwners[_user] != address(0)) {
            return changedOwners[_user];
        }

        return proxyAddr;
    }

    function addAdditionalProxy(address _user, address _proxy) public onlyOwner {

        if (IDSProxy(_proxy).owner() == _user) {
            additionalProxies[_user].push(_proxy);
        }
    }
			
    function getAllProxies(address _user) public view returns (address, address[] memory) {

        return (getMcdProxy(_user), additionalProxies[_user]);
    }
}  







contract DSProxyView {

    DFSProxyRegistry registry = DFSProxyRegistry(0x29474FdaC7142f9aB7773B8e38264FA15E3805ed);

    struct ProxyData {
        address proxy;
        bool correctDSGuardOwner;
        bool isUserOwner;
    }

    function checkDSGuardOwner(address _proxy) public view returns (bool) {

        if (_proxy == address(0)) return false;

        address currAuthority = address(DSAuth(_proxy).authority());

        return DSAuth(currAuthority).owner() == _proxy;
    }

    function isUserProxyOwner(address _user, address _proxy) public view returns (bool) {

        return IDSProxy(_proxy).owner() == _user;
    }

    function getProxiesAndCheckDSGuard(address _user)
        public
        view
        returns (ProxyData[] memory proxies)
    {

        (address mcdProxy, address[] memory otherProxies) = registry.getAllProxies(_user);

        proxies = new ProxyData[](otherProxies.length + 1);

        proxies[0] = ProxyData({
            proxy: mcdProxy,
            correctDSGuardOwner: checkDSGuardOwner(mcdProxy),
            isUserOwner: isUserProxyOwner(_user, mcdProxy)
        });

        for (uint256 i = 0; i < otherProxies.length; ++i) {
            proxies[i + 1] = ProxyData({
                proxy: otherProxies[i],
                correctDSGuardOwner: checkDSGuardOwner(otherProxies[i]),
                isUserOwner: isUserProxyOwner(_user, otherProxies[i])
            });
        }
    }
}