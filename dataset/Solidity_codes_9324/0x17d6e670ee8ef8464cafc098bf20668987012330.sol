pragma solidity ^0.7.0;

interface TonUtils {

    struct TonAddress {
        int8 workchain;
        bytes32 address_hash;
    }
    struct TonTxID {
        TonAddress address_;
        bytes32 tx_hash;
        uint64 lt;
    }

  struct SwapData {
        address receiver;
        uint64 amount;
        TonTxID tx;
  }
  struct Signature {
        address signer;
        bytes signature;
  }

}pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;



interface BridgeInterface is TonUtils {

  function voteForMinting(SwapData memory data, Signature[] memory signatures) external;

  function voteForNewOracleSet(int oracleSetHash, address[] memory newOracles, Signature[] memory signatures) external;

  function voteForSwitchBurn(bool newBurnStatus, int nonce, Signature[] memory signatures) external;

  event NewOracleSet(int oracleSetHash, address[] newOracles);
}pragma solidity ^0.7.0;


contract SignatureChecker is TonUtils {


    function checkSignature(bytes32 digest, Signature memory sig) public pure {

          if (sig.signature.length != 65) {
              revert("ECDSA: invalid signature length");
          }

          bytes32 r;
          bytes32 s;
          uint8 v;

          bytes memory signature = sig.signature;

          assembly {
              r := mload(add(signature, 0x20))
              s := mload(add(signature, 0x40))
              v := byte(0, mload(add(signature, 0x60)))
          }

          if (
              uint256(s) >
              0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
          ) {
              revert("ECDSA: invalid signature 's' value");
          }

          if (v != 27 && v != 28) {
              revert("ECDSA: invalid signature 'v' value");
          }
          bytes memory prefix = "\x19Ethereum Signed Message:\n32";
          bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, digest));
          require(ecrecover(prefixedHash, v, r, s) == sig.signer, "Wrong signature");
    }

    function getSwapDataId(SwapData memory data)
        public
        pure
        returns (bytes32 result)
    {

        result = 
            keccak256(
                abi.encode(
                    0xDA7A,
                    data.receiver,
                    data.amount,
                    data.tx.address_.workchain,
                    data.tx.address_.address_hash,
                    data.tx.tx_hash,
                    data.tx.lt                   
                )
            );
    }

    function getNewSetId(int oracleSetHash, address[] memory set)
        public
        pure
        returns (bytes32 result)
    {

        result = 
            keccak256(
                abi.encode(
                    0x5e7,
                    oracleSetHash,
                    set                    
                )
            );
    }

    function getNewBurnStatusId(bool newBurnStatus, int nonce)
        public
        pure
        returns (bytes32 result)
    {

        result =
            keccak256(
                abi.encode(
                    0xB012,
                    newBurnStatus,
                    nonce
                )
            );
    }


}pragma solidity ^0.7.0;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.4;


contract ERC20 is IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
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

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}pragma solidity ^0.7.0;



abstract contract WrappedTON is ERC20, TonUtils {
    bool public allowBurn;

    function mint(SwapData memory sd) internal {
      _mint(sd.receiver, sd.amount);
      emit SwapTonToEth(sd.tx.address_.workchain, sd.tx.address_.address_hash, sd.tx.tx_hash, sd.tx.lt, sd.receiver, sd.amount);
    }

    function burn(uint256 amount, TonAddress memory addr) external {
      require(allowBurn, "Burn is currently disabled");
      _burn(msg.sender, amount);
      emit SwapEthToTon(msg.sender, addr.workchain, addr.address_hash, amount);
    }

    function burnFrom(address account, uint256 amount, TonAddress memory addr) external {
        require(allowBurn, "Burn is currently disabled");
        uint256 currentAllowance = allowance(account,msg.sender);
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(account, msg.sender, currentAllowance - amount);
        _burn(account, amount);
        emit SwapEthToTon(account, addr.workchain, addr.address_hash, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 9;
    }

    event SwapEthToTon(address indexed from, int8 to_wc, bytes32 indexed to_addr_hash, uint256 value);
    event SwapTonToEth(int8 workchain, bytes32 indexed ton_address_hash, bytes32 indexed ton_tx_hash, uint64 lt, address indexed to, uint256 value);
}pragma solidity ^0.7.0;



contract Bridge is SignatureChecker, BridgeInterface, WrappedTON {
    address[] public oraclesSet;
    mapping(address => bool) public isOracle;
    mapping(bytes32 => bool) public finishedVotings;

    constructor (string memory name_, string memory symbol_, address[] memory initialSet) ERC20(name_, symbol_) {
        updateOracleSet(0, initialSet);
    }
    
    function generalVote(bytes32 digest, Signature[] memory signatures) internal {
      require(signatures.length >= 2 * oraclesSet.length / 3, "Not enough signatures");
      require(!finishedVotings[digest], "Vote is already finished");
      uint signum = signatures.length;
      uint last_signer = 0;
      for(uint i=0; i<signum; i++) {
        address signer = signatures[i].signer;
        require(isOracle[signer], "Unauthorized signer");
        uint next_signer = uint(signer);
        require(next_signer > last_signer, "Signatures are not sorted");
        last_signer = next_signer;
        checkSignature(digest, signatures[i]);
      }
      finishedVotings[digest] = true;
    }

    function voteForMinting(SwapData memory data, Signature[] memory signatures) override public {
      bytes32 _id = getSwapDataId(data);
      generalVote(_id, signatures);
      executeMinting(data);
    }

    function voteForNewOracleSet(int oracleSetHash, address[] memory newOracles, Signature[] memory signatures) override  public {
      bytes32 _id = getNewSetId(oracleSetHash, newOracles);
      require(newOracles.length > 2, "New set is too short");
      generalVote(_id, signatures);
      updateOracleSet(oracleSetHash, newOracles);
    }

    function voteForSwitchBurn(bool newBurnStatus, int nonce, Signature[] memory signatures) override public {
      bytes32 _id = getNewBurnStatusId(newBurnStatus, nonce);
      generalVote(_id, signatures);
      allowBurn = newBurnStatus;
    }

    function executeMinting(SwapData memory data) internal {
      mint(data);
    }

    function updateOracleSet(int oracleSetHash, address[] memory newSet) internal {
      uint oldSetLen = oraclesSet.length;
      for(uint i = 0; i < oldSetLen; i++) {
        isOracle[oraclesSet[i]] = false;
      }
      oraclesSet = newSet;
      uint newSetLen = oraclesSet.length;
      for(uint i = 0; i < newSetLen; i++) {
        require(!isOracle[newSet[i]], "Duplicate oracle in Set");
        isOracle[newSet[i]] = true;
      }
      emit NewOracleSet(oracleSetHash, newSet);
    }
    function getFullOracleSet() public view returns (address[] memory) {
        return oraclesSet;
    }
}