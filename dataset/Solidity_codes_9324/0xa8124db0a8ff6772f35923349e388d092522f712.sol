
pragma solidity 0.6.2;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

contract ContextUpgradeSafe is Initializable {


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




 
interface IProcessor {

  
  function register(string calldata _name, string calldata _symbol, uint8 _decimals) external;

  function canTransfer(address _from, address _to, uint256 _amount) external view returns (bool, uint256, uint256);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address _owner) external view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value) 
    external returns (bool, address, uint256);

  function approve(address _owner, address _spender, uint256 _value) external;

  function allowance(address _owner, address _spender) external view returns (uint256);

  function increaseApproval(address _owner, address _spender, uint _addedValue) external;

  function decreaseApproval(address _owner, address _spender, uint _subtractedValue) external;

  function seize(address _caller, address _account, uint256 _value) external;

  function mint(address _caller, address _to, uint256 _amount) external;

  function burn(address _caller, address _from, uint256 _amount) external;

}




interface IRulable {

  function rule(uint256 ruleId) external view returns (uint256, uint256);

  function rules() external view returns (uint256[] memory, uint256[] memory);


  function canTransfer(address _from, address _to, uint256 _amount) external view returns (bool, uint256, uint256);


  function setRules(
    uint256[] calldata _rules, 
    uint256[] calldata _rulesParams
  ) external;

  event RulesChanged(uint256[] newRules, uint256[] newRulesParams);
}





interface ISuppliable {

  function isSupplier(address _supplier) external view returns (bool);

  function addSupplier(address _supplier) external;

  function removeSupplier(address _supplier) external;


  event SupplierAdded(address indexed supplier);
  event SupplierRemoved(address indexed supplier);
}


 
interface IMintable {

  function mint(address _to, uint256 _amount) external;

  function burn(address _from, uint256 _amount) external;

 
  event Mint(address indexed to, uint256 amount);
  event Burn(address indexed from, uint256 amount);
}


interface IBulkTransferable {

  function bulkTransfer(address[] calldata _to, uint256[] calldata _values) external;

  function bulkTransferFrom(address _from, address[] calldata _to, uint256[] calldata _values) external;

}/*
    Copyright (c) 2019 Mt Pelerin Group Ltd

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License version 3
    as published by the Free Software Foundation with the addition of the
    following permission added to Section 15 as permitted in Section 7(a):
    FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY
    MT PELERIN GROUP LTD. MT PELERIN GROUP LTD DISCLAIMS THE WARRANTY OF NON INFRINGEMENT
    OF THIRD PARTY RIGHTS

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Affero General Public License for more details.
    You should have received a copy of the GNU Affero General Public License
    along with this program; if not, see http://www.gnu.org/licenses or write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA, 02110-1301 USA, or download the license from the following URL:
    https://www.gnu.org/licenses/agpl-3.0.fr.html

    The interactive user interfaces in modified source and object code versions
    of this program must display Appropriate Legal Notices, as required under
    Section 5 of the GNU Affero General Public License.

    You can be released from the requirements of the license by purchasing
    a commercial license. Buying such a license is mandatory as soon as you
    develop commercial activities involving Mt Pelerin Group Ltd software without
    disclosing the source code of your own applications.
    These activities include: offering paid services based/using this product to customers,
    using this product in any application, distributing this product with a closed
    source product.

    For more information, please contact Mt Pelerin Group Ltd at this
    address: [email protected]
*/


interface IERC2612 {

  function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

}



 
interface IERC3009 {

  function transferWithAuthorization(
    address from,
    address to,
    uint256 value,
    uint256 validAfter,
    uint256 validBefore,
    bytes32 nonce,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

 
  event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
  event AuthorizationCanceled(
      address indexed authorizer,
      bytes32 indexed nonce
  );

  enum AuthorizationState { Unused, Used, Canceled }
}



interface IERC20Detailed {

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);


  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC677Receiver {

  function onTokenTransfer(address from, uint256 amount, bytes calldata data) external returns (bool);

}

interface IAdministrable {

  function isAdministrator(address _administrator) external view returns (bool);

  function addAdministrator(address _administrator) external;

  function removeAdministrator(address _administrator) external;


  event AdministratorAdded(address indexed administrator);
  event AdministratorRemoved(address indexed administrator);
}

interface IGovernable {

  function realm() external view returns (address);

  function setRealm(address _realm) external;


  function isRealmAdministrator(address _administrator) external view returns (bool);

  function addRealmAdministrator(address _administrator) external;

  function removeRealmAdministrator(address _administrator) external;


  function trustedIntermediaries() external view returns (address[] memory);

  function setTrustedIntermediaries(address[] calldata _trustedIntermediaries) external;


  event TrustedIntermediariesChanged(address[] newTrustedIntermediaries);
  event RealmChanged(address newRealm);
  event RealmAdministratorAdded(address indexed administrator);
  event RealmAdministratorRemoved(address indexed administrator);
}



interface IPriceable {

  function priceOracle() external view returns (IPriceOracle);

  function setPriceOracle(IPriceOracle _priceOracle) external;

  function convertTo(
    uint256 _amount, string calldata _currency, uint8 maxDecimals
  ) external view returns(uint256);


  event PriceOracleChanged(address indexed newPriceOracle);
}




interface IPriceOracle {


  struct Price {
    uint256 price;
    uint8 decimals;
    uint256 lastUpdated;
  }

  function setPrice(bytes32 _currency1, bytes32 _currency2, uint256 _price, uint8 _decimals) external;

  function setPrices(bytes32[] calldata _currency1, bytes32[] calldata _currency2, uint256[] calldata _price, uint8[] calldata _decimals) external;

  function getPrice(bytes32 _currency1, bytes32 _currency2) external view returns (uint256, uint8);

  function getPrice(string calldata _currency1, string calldata _currency2) external view returns (uint256, uint8);

  function getLastUpdated(bytes32 _currency1, bytes32 _currency2) external view returns (uint256);

  function getDecimals(bytes32 _currency1, bytes32 _currency2) external view returns (uint8);


  event PriceSet(bytes32 indexed currency1, bytes32 indexed currency2, uint256 price, uint8 decimals, uint256 updateDate);
}/*
    Copyright (c) 2019 Mt Pelerin Group Ltd

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License version 3
    as published by the Free Software Foundation with the addition of the
    following permission added to Section 15 as permitted in Section 7(a):
    FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY
    MT PELERIN GROUP LTD. MT PELERIN GROUP LTD DISCLAIMS THE WARRANTY OF NON INFRINGEMENT
    OF THIRD PARTY RIGHTS

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Affero General Public License for more details.
    You should have received a copy of the GNU Affero General Public License
    along with this program; if not, see http://www.gnu.org/licenses or write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA, 02110-1301 USA, or download the license from the following URL:
    https://www.gnu.org/licenses/agpl-3.0.fr.html

    The interactive user interfaces in modified source and object code versions
    of this program must display Appropriate Legal Notices, as required under
    Section 5 of the GNU Affero General Public License.

    You can be released from the requirements of the license by purchasing
    a commercial license. Buying such a license is mandatory as soon as you
    develop commercial activities involving Mt Pelerin Group Ltd software without
    disclosing the source code of your own applications.
    These activities include: offering paid services based/using this product to customers,
    using this product in any application, distributing this product with a closed
    source product.

    For more information, please contact Mt Pelerin Group Ltd at this
    address: [email protected]
*/



interface ISeizable {

  function isSeizer(address _seizer) external view returns (bool);

  function addSeizer(address _seizer) external;

  function removeSeizer(address _seizer) external;


  event SeizerAdded(address indexed seizer);
  event SeizerRemoved(address indexed seizer);

  function seize(address _account, uint256 _value) external;

  event Seize(address account, uint256 amount);
}

library ECRecover {

    function recover(
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            revert("ECRecover: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECRecover: invalid signature 'v' value");
        }

        address signer = ecrecover(digest, v, r, s);
        require(signer != address(0), "ECRecover: invalid signature");

        return signer;
    }
}/**
 * MIT
 *
 * Copyright (c) 2018-2020 CENTRE SECZ
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


library EIP712 {

    function makeDomainSeparator(string memory name, string memory version)
        internal
        view
        returns (bytes32)
    {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return
            keccak256(
                abi.encode(
                    0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                    keccak256(bytes(name)),
                    keccak256(bytes(version)),
                    chainId,
                    address(this)
                )
            );
    }

    function recover(
        bytes32 domainSeparator,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes memory typeHashAndData
    ) internal pure returns (address) {

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(typeHashAndData)
            )
        );
        return ECRecover.recover(digest, v, r, s);
    }
}/*
    Copyright (c) 2016-2019 zOS Global Limited

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {



        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);

    }


    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
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



contract BridgeERC20 is Initializable, OwnableUpgradeSafe, IAdministrable, IGovernable, IPriceable, IERC20Detailed {

  using Roles for Roles.Role;
  using SafeMath for uint256;

  event ProcessorChanged(address indexed newProcessor);

  IProcessor internal _processor;
  Roles.Role internal _administrators;
  Roles.Role internal _realmAdministrators;
  address[] internal _trustedIntermediaries;
  address internal _realm;
  IPriceOracle internal _priceOracle;

  function initialize(address owner, IProcessor newProcessor) public virtual initializer {

    __Ownable_init();
    transferOwnership(owner);
    _processor = newProcessor;
    _realm = address(this);
    emit ProcessorChanged(address(newProcessor));
    emit RealmChanged(address(this));
  }

  modifier hasProcessor() {

    require(address(_processor) != address(0), "PR01");
    _;
  }

  modifier onlyAdministrator() {

    require(owner() == _msgSender() || isAdministrator(_msgSender()), "AD01");
    _;
  }

  function isAdministrator(address _administrator) public override view returns (bool) {

    return _administrators.has(_administrator);
  }

  function addAdministrator(address _administrator) public override onlyOwner {

    _administrators.add(_administrator);
    emit AdministratorAdded(_administrator);
  }

  function removeAdministrator(address _administrator) public override onlyOwner {

    _administrators.remove(_administrator);
    emit AdministratorRemoved(_administrator);
  }

  function realm() public override view returns (address) {

    return _realm;
  }

  function setRealm(address newRealm) public override onlyAdministrator {

    BridgeERC20 king = BridgeERC20(newRealm);
    require(king.owner() == _msgSender() || king.isRealmAdministrator(_msgSender()), "KI01");
    _realm = newRealm;
    emit RealmChanged(newRealm);
  }

  function trustedIntermediaries() public override view returns (address[] memory) {

    return _trustedIntermediaries;
  }

  function setTrustedIntermediaries(address[] calldata newTrustedIntermediaries) external override onlyAdministrator {

    _trustedIntermediaries = newTrustedIntermediaries;
    emit TrustedIntermediariesChanged(newTrustedIntermediaries);
  }

  function isRealmAdministrator(address _administrator) public override view returns (bool) {

    return _realmAdministrators.has(_administrator);
  }

  function addRealmAdministrator(address _administrator) public override onlyAdministrator {

    _realmAdministrators.add(_administrator);
    emit RealmAdministratorAdded(_administrator);
  }

  function removeRealmAdministrator(address _administrator) public override onlyAdministrator {

    _realmAdministrators.remove(_administrator);
    emit RealmAdministratorRemoved(_administrator);
  }

  function priceOracle() public override view returns (IPriceOracle) {

    return _priceOracle;
  }

  function setPriceOracle(IPriceOracle newPriceOracle) public override onlyAdministrator {

    _priceOracle = newPriceOracle;
    emit PriceOracleChanged(address(newPriceOracle));
  }

  function convertTo(
    uint256 _amount, string calldata _currency, uint8 maxDecimals
  ) 
    external override hasProcessor view returns(uint256) 
  {

    require(address(_priceOracle) != address(0), "PO03");
    uint256 amountToConvert = _amount;
    uint256 xrate;
    uint8 xrateDecimals;
    uint8 tokenDecimals = _processor.decimals();
    (xrate, xrateDecimals) = _priceOracle.getPrice(_processor.symbol(), _currency);
    if (xrateDecimals > maxDecimals) {
      xrate = xrate.div(10**uint256(xrateDecimals - maxDecimals));
      xrateDecimals = maxDecimals;
    }
    if (tokenDecimals > maxDecimals) {
      amountToConvert = amountToConvert.div(10**uint256(tokenDecimals - maxDecimals));
      tokenDecimals = maxDecimals;
    }
    return amountToConvert.mul(xrate).mul(10**uint256((2*maxDecimals)-xrateDecimals-tokenDecimals));
  }

  function setProcessor(IProcessor newProcessor) public onlyAdministrator {

    _processor = newProcessor;
    emit ProcessorChanged(address(newProcessor));
  }

  function processor() public view returns (IProcessor) {

    return _processor;
  }

  function name() public override view hasProcessor returns (string memory) {

    return _processor.name();
  }

  function symbol() public override view hasProcessor returns (string memory) {

    return _processor.symbol();
  }

  function decimals() public override view hasProcessor returns (uint8) {

    return _processor.decimals();
  }

  function totalSupply() public override view hasProcessor returns (uint256) {

    return _processor.totalSupply();
  }

  function transfer(address _to, uint256 _value) public override hasProcessor 
    returns (bool) 
  {

    bool success;
    address updatedTo;
    uint256 updatedAmount;
    (success, updatedTo, updatedAmount) = _transferFrom(
      _msgSender(), 
      _to, 
      _value
    );
    return true;
  }

  function transferAndCall(address _to, uint256 _value, bytes calldata data) external hasProcessor returns (bool)
  {

    bool success;
    address updatedTo;
    uint256 updatedAmount;
    (success, updatedTo, updatedAmount) = _transferFrom(
      _msgSender(), 
      _to, 
      _value
    );
    if (success && _to == updatedTo) {
      success = IERC677Receiver(updatedTo).onTokenTransfer(_msgSender(), updatedAmount, data);
    }
    return true;
  }

  function balanceOf(address _owner) public override view hasProcessor 
    returns (uint256) 
  {

    return _processor.balanceOf(_owner);
  }


  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    override
    hasProcessor
    returns (bool)
  {

    require(_value <= _processor.allowance(_from, _msgSender()), "AL01"); 
    bool success;
    address updatedTo;
    uint256 updatedAmount;
    (success, updatedTo, updatedAmount) = _transferFrom(
      _from, 
      _to, 
      _value
    );
    _processor.decreaseApproval(_from, _msgSender(), updatedAmount);
    return true;
  }

  function approve(address _spender, uint256 _value) public override hasProcessor returns (bool)
  {

    _approve(_msgSender(), _spender, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    override
    view
    hasProcessor
    returns (uint256)
  {

    return _processor.allowance(_owner, _spender);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    hasProcessor
  {

    _increaseApproval(_msgSender(), _spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    hasProcessor
  {

    _decreaseApproval(_msgSender(), _spender, _subtractedValue);
  }

  function _transferFrom(address _from, address _to, uint256 _value) internal returns (bool _success, address _updatedTo, uint256 _updatedAmount) {

    (_success, _updatedTo, _updatedAmount) = _processor.transferFrom(
      _from, 
      _to, 
      _value
    );
    emit Transfer(_from, _updatedTo, _updatedAmount);
    return (_success, _updatedTo, _updatedAmount);
  }

  function _approve(address _owner, address _spender, uint256 _value) internal {

    _processor.approve(_owner, _spender, _value);
    emit Approval(_owner, _spender, _value);
  }

  function _increaseApproval(address _owner, address _spender, uint _addedValue) internal {

    _processor.increaseApproval(_owner, _spender, _addedValue);
    uint256 allowed = _processor.allowance(_owner, _spender);
    emit Approval(_owner, _spender, allowed);
  }

  function _decreaseApproval(address _owner, address _spender, uint _subtractedValue) internal {

    _processor.decreaseApproval(_owner, _spender, _subtractedValue);
    uint256 allowed = _processor.allowance(_owner, _spender);
    emit Approval(_owner, _spender, allowed);
  }

  uint256[50] private ______gap;
}






contract SeizableBridgeERC20 is Initializable, ISeizable, BridgeERC20 {

  using Roles for Roles.Role;
  
  Roles.Role internal _seizers;

  function initialize(
    address owner, 
    IProcessor processor
  ) 
    public override initializer 
  {

    BridgeERC20.initialize(owner, processor);
  }

  modifier onlySeizer() {

    require(isSeizer(_msgSender()), "SE02");
    _;
  }

  function isSeizer(address _seizer) public override view returns (bool) {

    return _seizers.has(_seizer);
  }

  function addSeizer(address _seizer) public override onlyAdministrator {

    _seizers.add(_seizer);
    emit SeizerAdded(_seizer);
  }

  function removeSeizer(address _seizer) public override onlyAdministrator {

    _seizers.remove(_seizer);
    emit SeizerRemoved(_seizer);
  }

  function seize(address _account, uint256 _value)
    public override onlySeizer hasProcessor
  {

    _processor.seize(_msgSender(), _account, _value);
    emit Seize(_account, _value);
    emit Transfer(_account, _msgSender(), _value); 
  }

  uint256[49] private ______gap;
}

contract BridgeToken is Initializable, IRulable, ISuppliable, IMintable, IERC2612, IERC3009, IBulkTransferable, SeizableBridgeERC20 {

  using Roles for Roles.Role;
  using SafeMath for uint256;
  
  bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9; // = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")
  bytes32 public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267; // = keccak256("TransferWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
  bytes32 public constant APPROVE_WITH_AUTHORIZATION_TYPEHASH = 0x808c10407a796f3ef2c7ea38c0638ea9d2b8a1c63e3ca9e1f56ce84ae59df73c; // = keccak256("ApproveWithAuthorization(address owner,address spender,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
  bytes32 public constant INCREASE_APPROVAL_WITH_AUTHORIZATION_TYPEHASH = 0x9a42d39fe98978ff30e5bb6104a6ce6f70ac074c10013f1bce9743e2dccce41b; // = keccak256("IncreaseApprovalWithAuthorization(address owner,address spender,uint256 increment,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
  bytes32 public constant DECREASE_APPROVAL_WITH_AUTHORIZATION_TYPEHASH = 0x604bdf0208a879f7d9fa63ff2f539804aaf6f7876eaa13d531bdc957f1c0284f; // = keccak256("DecreaseApprovalWithAuthorization(address owner,address spender,uint256 decrement,uint256 validAfter,uint256 validBefore,bytes32 nonce)")
  bytes32 public constant CANCEL_AUTHORIZATION_TYPEHASH = 0x158b0a9edf7a828aad02f63cd515c68ef2f50ba807396f6d12842833a1597429; // = keccak256("CancelAuthorization(address authorizer,bytes32 nonce)")

  Roles.Role internal _suppliers;
  uint256[] internal _rules;
  uint256[] internal _rulesParams;
  string internal _contact; // DEPRECATED - Not removed for proxy compatibility: https://docs.openzeppelin.com/sdk/2.5/writing-contracts.html#modifying-your-contracts
  bytes32 public DOMAIN_SEPARATOR;
  mapping(address => uint256) public nonces;
  mapping(address => mapping(bytes32 => AuthorizationState)) public authorizationStates;

  function initialize(
    address owner,
    IProcessor processor,
    string memory name,
    string memory symbol,
    uint8 decimals,
    address[] memory trustedIntermediaries
  ) 
  
  public virtual initializer 
  {

    SeizableBridgeERC20.initialize(owner, processor);
    processor.register(name, symbol, decimals);
    _trustedIntermediaries = trustedIntermediaries;
    emit TrustedIntermediariesChanged(trustedIntermediaries);
    _upgradeToV2();
  }

  modifier onlySupplier() {

    require(isSupplier(_msgSender()), "SU01");
    _;
  }

  function upgradeToV2() public onlyOwner {

    _upgradeToV2();
  }

  function isSupplier(address _supplier) public override view returns (bool) {

    return _suppliers.has(_supplier);
  }

  function addSupplier(address _supplier) public override onlyAdministrator {

    _suppliers.add(_supplier);
    emit SupplierAdded(_supplier);
  }

  function removeSupplier(address _supplier) public override onlyAdministrator {

    _suppliers.remove(_supplier);
    emit SupplierRemoved(_supplier);
  }  

  function mint(address _to, uint256 _amount)
    public override onlySupplier hasProcessor
  {

    _processor.mint(_msgSender(), _to, _amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
  }

  function burn(address _from, uint256 _amount)
    public override onlySupplier hasProcessor 
  {

    _processor.burn(_msgSender(), _from, _amount);
    emit Burn(_from, _amount);
    emit Transfer(_from, address(0), _amount);
  }

  function rules() public override view returns (uint256[] memory, uint256[] memory) {

    return (_rules, _rulesParams);
  }
  
  function rule(uint256 ruleId) public override view returns (uint256, uint256) {

    require(ruleId < _rules.length, "RE01");
    return (_rules[ruleId], _rulesParams[ruleId]);
  }

  function canTransfer(
    address _from, address _to, uint256 _amount
  ) 
    public override hasProcessor view returns (bool, uint256, uint256) 
  {

    return _processor.canTransfer(_from, _to, _amount);
  }

  function setRules(
    uint256[] calldata newRules, 
    uint256[] calldata newRulesParams
  ) 
    external override onlyAdministrator
  {

    require(newRules.length == newRulesParams.length, "RU01");
    _rules = newRules;
    _rulesParams = newRulesParams;
    emit RulesChanged(_rules, _rulesParams);
  }

  function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override hasProcessor {

      require(deadline >= block.timestamp, "EX01");

      bytes memory data = abi.encode(
        PERMIT_TYPEHASH,
        owner,
        spender,
        value,
        nonces[owner]++,
        deadline
      );
      require(
        EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == owner,
        "SI01"
      );

      _approve(owner, spender, value);
  }

  function transferWithAuthorization(
    address from,
    address to,
    uint256 value,
    uint256 validAfter,
    uint256 validBefore,
    bytes32 nonce,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override hasProcessor {

    _requireValidAuthorization(from, nonce, validAfter, validBefore);

    bytes memory data = abi.encode(
      TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
      from,
      to,
      value,
      validAfter,
      validBefore,
      nonce
    );
    require(
      EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == from,
      "SI01"
    );

    _markAuthorizationAsUsed(from, nonce);
    _transferFrom(from, to, value);
  }

  function approveWithAuthorization(
    address owner,
    address spender,
    uint256 value,
    uint256 validAfter,
    uint256 validBefore,
    bytes32 nonce,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external hasProcessor {

    _requireValidAuthorization(owner, nonce, validAfter, validBefore);

    bytes memory data = abi.encode(
      APPROVE_WITH_AUTHORIZATION_TYPEHASH,
      owner,
      spender,
      value,
      validAfter,
      validBefore,
      nonce
    );
    require(
      EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == owner,
      "SI01"
    );

    _markAuthorizationAsUsed(owner, nonce);
    _approve(owner, spender, value);
  }

  function increaseApprovalWithAuthorization(
    address owner,
    address spender,
    uint256 increment,
    uint256 validAfter,
    uint256 validBefore,
    bytes32 nonce,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external hasProcessor {

    _requireValidAuthorization(owner, nonce, validAfter, validBefore);

    bytes memory data = abi.encode(
      INCREASE_APPROVAL_WITH_AUTHORIZATION_TYPEHASH,
      owner,
      spender,
      increment,
      validAfter,
      validBefore,
      nonce
    );
    require(
      EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == owner,
      "SI01"
    );

    _markAuthorizationAsUsed(owner, nonce);
    _increaseApproval(owner, spender, increment);
  }

  function decreaseApprovalWithAuthorization(
    address owner,
    address spender,
    uint256 decrement,
    uint256 validAfter,
    uint256 validBefore,
    bytes32 nonce,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external hasProcessor {

    _requireValidAuthorization(owner, nonce, validAfter, validBefore);

    bytes memory data = abi.encode(
      DECREASE_APPROVAL_WITH_AUTHORIZATION_TYPEHASH,
      owner,
      spender,
      decrement,
      validAfter,
      validBefore,
      nonce
    );
    require(
      EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == owner,
      "SI01"
    );

    _markAuthorizationAsUsed(owner, nonce);
    _decreaseApproval(owner, spender, decrement);
  }

  function cancelAuthorization(
    address authorizer,
    bytes32 nonce,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external {

    _requireUnusedAuthorization(authorizer, nonce);

    bytes memory data = abi.encode(
      CANCEL_AUTHORIZATION_TYPEHASH,
      authorizer,
      nonce
    );
    require(
      EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == authorizer,
      "SI01"
    );

    authorizationStates[authorizer][nonce] = AuthorizationState.Canceled;
    emit AuthorizationCanceled(authorizer, nonce);
  }

  function _requireUnusedAuthorization(address authorizer, bytes32 nonce) internal view {

    require(
      authorizationStates[authorizer][nonce] == AuthorizationState.Unused,
      "EX03"
    );
  }

  function _requireValidAuthorization(
    address authorizer,
    bytes32 nonce,
    uint256 validAfter,
    uint256 validBefore
  ) internal view {

    require(
      block.timestamp > validAfter,
      "EX02"
    );
    require(block.timestamp < validBefore, "EX01");
    _requireUnusedAuthorization(authorizer, nonce);
  }

  function _markAuthorizationAsUsed(address authorizer, bytes32 nonce) internal { 

    authorizationStates[authorizer][nonce] = AuthorizationState.Used;
    emit AuthorizationUsed(authorizer, nonce);
  }

  function bulkTransfer(address[] calldata _to, uint256[] calldata _values) external override hasProcessor  
  {

    require(_to.length == _values.length, "BK01");
    for (uint256 i = 0; i < _to.length; i++) {
      _transferFrom(_msgSender(), _to[i], _values[i]);
    }
  }

  function bulkTransferFrom(address _from, address[] calldata _to, uint256[] calldata _values) external override hasProcessor  
  {

    require(_to.length == _values.length, "BK01");
    uint256 _totalValue = 0;
    uint256 _totalTransfered = 0;
    for (uint256 i = 0; i < _to.length; i++) {
      _totalValue = _totalValue.add(_values[i]);
    }
    require(_totalValue <= _processor.allowance(_from, _msgSender()), "AL01"); 
    for (uint256 i = 0; i < _to.length; i++) {
      bool success;
      address updatedTo;
      uint256 updatedAmount;
      (success, updatedTo, updatedAmount) = _transferFrom(_from, _to[i], _values[i]);
      _totalTransfered = _totalTransfered.add(updatedAmount);
    }
    _processor.decreaseApproval(_from, _msgSender(), _totalTransfered);
  }

  function _upgradeToV2() internal {

    DOMAIN_SEPARATOR = EIP712.makeDomainSeparator(_processor.name(), "2");
  }

  uint256[47] private ______gap;
}/*
    Copyright (c) 2019 Mt Pelerin Group Ltd

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License version 3
    as published by the Free Software Foundation with the addition of the
    following permission added to Section 15 as permitted in Section 7(a):
    FOR ANY PART OF THE COVERED WORK IN WHICH THE COPYRIGHT IS OWNED BY
    MT PELERIN GROUP LTD. MT PELERIN GROUP LTD DISCLAIMS THE WARRANTY OF NON INFRINGEMENT
    OF THIRD PARTY RIGHTS

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Affero General Public License for more details.
    You should have received a copy of the GNU Affero General Public License
    along with this program; if not, see http://www.gnu.org/licenses or write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA, 02110-1301 USA, or download the license from the following URL:
    https://www.gnu.org/licenses/agpl-3.0.fr.html

    The interactive user interfaces in modified source and object code versions
    of this program must display Appropriate Legal Notices, as required under
    Section 5 of the GNU Affero General Public License.

    You can be released from the requirements of the license by purchasing
    a commercial license. Buying such a license is mandatory as soon as you
    develop commercial activities involving Mt Pelerin Group Ltd software without
    disclosing the source code of your own applications.
    These activities include: offering paid services based/using this product to customers,
    using this product in any application, distributing this product with a closed
    source product.

    For more information, please contact Mt Pelerin Group Ltd at this
    address: [email protected]
*/



contract ShareBridgeToken is Initializable, BridgeToken {

  event TokenizedShares(uint256 tokenizedShares);

  event BoardResolutionDocumentSet(bytes32 boardResolutionDocumentHash);

  uint256 public constant VERSION = 3;
  
  uint16 public tokenizedSharePercentage; // DEPRECATED - Not removed for proxy compatibility: https://docs.openzeppelin.com/sdk/2.5/writing-contracts.html#modifying-your-contracts
  address public votingSession; // DEPRECATED - Not removed for proxy compatibility: https://docs.openzeppelin.com/sdk/2.5/writing-contracts.html#modifying-your-contracts
  string public boardResolutionDocumentUrl;
  bytes32 public boardResolutionDocumentHash;
  string public terms;
  uint256 public tokenizedShares;

  function initialize(
    address owner,
    IProcessor processor,
    string memory name,
    string memory symbol,
    address[] memory trustedIntermediaries,
    uint256 _tokenizedShares
  )
    public initializer
  {

    BridgeToken.initialize(
      owner,
      processor,
      name,
      symbol,
      0,
      trustedIntermediaries
    );
    tokenizedShares = _tokenizedShares;
    emit TokenizedShares(tokenizedShares);
  }

  function setTokenizedShares(uint256 _tokenizedShares) public onlyAdministrator {

    tokenizedShares = _tokenizedShares;
    emit TokenizedShares(tokenizedShares);
  }

  function setTerms(string calldata _terms) external onlyAdministrator {

    terms = _terms;
  }

  function setBoardResolutionDocument(string calldata _boardResolutionDocumentUrl, bytes32 _boardResolutionDocumentHash) external onlyAdministrator {

    boardResolutionDocumentUrl = _boardResolutionDocumentUrl;
    boardResolutionDocumentHash = _boardResolutionDocumentHash;
    emit BoardResolutionDocumentSet(_boardResolutionDocumentHash);
  }

  uint256[50] private ______gap;
}