pragma solidity ^0.4.23;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}pragma solidity ^0.4.23;


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}pragma solidity ^0.4.23;




contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

}pragma solidity ^0.4.23;



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);


  function transferFrom(address from, address to, uint256 value)
    public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}pragma solidity ^0.4.23;



contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {

    return allowed[_owner][_spender];
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {

    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {

    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}pragma solidity ^0.4.23;


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}pragma solidity ^0.4.23;



contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {

    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {

    require(msg.sender == owner);
    _;
  }

  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {

    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  function finishMinting() onlyOwner canMint public returns (bool) {

    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}/**
 * Copyright (C) 2018  Smartz, LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).
 */

pragma solidity ^0.4.23;


contract MerkleAirdrop {


    address owner;
    bytes32 public merkleRoot;
    bool public cancelable;
    MintableToken tokenContract;
    mapping (address => bool) spent;

    event AirdropTransfer(address addr, uint256 num);
    event OwnershipTransferred(address previousOwner, address newOwner);

    modifier isCancelable() {

        require(cancelable, 'forbidden action');
        _;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    constructor(address _tokenContract, bytes32 _merkleRoot, bool _cancelable) public {
        owner = msg.sender;
        tokenContract = MintableToken(_tokenContract);
        merkleRoot = _merkleRoot;
        cancelable = _cancelable;
    }


    function setRoot(bytes32 _merkleRoot) public onlyOwner {

        merkleRoot = _merkleRoot;
    }

    function getOwner() public view returns (address) {

        return owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

	function contractTokenBalance() public view returns(uint) {

		return tokenContract.balanceOf(address(this));
	}

    function claim_rest_of_tokens_and_selfdestruct() public isCancelable onlyOwner returns(bool) {

        require(tokenContract.balanceOf(address(this)) >= 0);
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
        selfdestruct(owner);
        return true;
    }

    function getTokensByMerkleProof(bytes32[] _proof, address _who, uint256 _amount) public returns(bool) {

        require(spent[_who] != true, "You can claim tokens only once.");
        require(_amount > 0, "Amount should be > 0");

        if (!checkProof(_proof, leaf_from_address_and_num_tokens(_who, _amount))) {
            return false;
        }

        spent[_who] = true;

        if (tokenContract.transfer(_who, _amount) == true) {
            emit AirdropTransfer(_who, _amount);
            return true;
        }
        require(false, "Transfer failed!");
    }

    function addressToAsciiString(address x) internal pure returns (string) {

        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        return string(s);
    }

    function char(byte b) internal pure returns (byte c) {

        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }

    function uintToStr(uint i) internal pure returns (string){

        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    function leaf_from_address_and_num_tokens(address _a, uint256 _n) internal pure returns(bytes32 ) {

        string memory prefix = "0x";
        string memory space = " ";

        bytes memory _ba = bytes(prefix);
        bytes memory _bb = bytes(addressToAsciiString(_a));
        bytes memory _bc = bytes(space);
        bytes memory _bd = bytes(uintToStr(_n));
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];

        return bytes32(keccak256(abi.encodePacked(abcde)));
    }

    function checkProof(bytes32[] proof, bytes32 hash) internal view returns (bool) {

        bytes32 el;
        bytes32 h = hash;

        for (uint i = 0; i <= proof.length - 1; i += 1) {
            el = proof[i];

            if (h < el) {
                h = keccak256(abi.encodePacked(h, el));
            } else {
                h = keccak256(abi.encodePacked(el, h));
            }
        }
        return h == merkleRoot;
    }
}