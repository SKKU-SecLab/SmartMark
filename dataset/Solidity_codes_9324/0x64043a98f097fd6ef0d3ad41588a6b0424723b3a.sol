





pragma solidity >=0.5.12;

interface TokenLike {

  function transferFrom(address from, address to, uint256 amount) external returns (bool);

  function approve(address to, uint256 amount) external returns (bool);

  function balanceOf(address to) external returns (uint);

  function join(address to, uint256 amount) external;

  function exit(address from, uint256 amount) external;

}

interface Uniswappy {

    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_tokens,
                uint256 deadline, address recipient) external returns (uint256);

}

contract Dach {

  TokenLike public constant dai = TokenLike(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  TokenLike public constant chai = TokenLike(0x06AF07097C9Eeb7fD685c692751D5C66dB49c215);
  Uniswappy public constant daiUniswap = Uniswappy(0x2a1530C4C41db0B0b2bB646CB5Eb1A67b7158667);
  Uniswappy public constant chaiUniswap = Uniswappy(0x6C3942B383bc3d0efd3F36eFa1CBE7C8E12C8A2B);
  
  mapping (address => uint256) public nonces;
  string public constant version = "1";
  string public constant name = "Dai Automated Clearing House";

  bytes32 constant public DOMAIN_SEPARATOR = 0x12941727324f08818b6823ad59845bef3c6e4139428eb3fd9490efeb9d088969;

  bytes32 constant public DAICHEQUE_TYPEHASH = 0x2d4b89f08cf38e73f267d45cf655caeec6ec2d1958ff3f7c04bc93b285692ba0;

  bytes32 constant public DAISWAP_TYPEHASH = 0x569d16faba32239b19edb6a011b30ad0035ca192ef2f179c46edfb1d50280084;

  bytes32 constant public CHAIJOIN_TYPEHASH = 0x9b0767889629ab3e37d797178aba3047e96d19239c5977f2c56ea8da3275cb05;

  bytes32 constant public CHAICHEQUE_TYPEHASH = 0x77ae2fa9d8312ad1d4a645b9102258e9fc5e64280c2198da01c426cbcc966fb1;

  bytes32 constant public CHAISWAP_TYPEHASH = 0x7cf3e6fd2031b292afffa62c2dbc5e4212855cadd6455a36bed415f2b8246a47;

  bytes32 constant public CHAIEXIT_TYPEHASH = 0x69fa4cd566f89a9c8d4e3ca437a7fbc893137962cb1b036c59ceeb1415c58c01;
 
  constructor() public {
    dai.approve(address(chai), uint(-1));
    dai.approve(address(daiUniswap), uint(-1));
    chai.approve(address(chaiUniswap), uint(-1));
  }

  function digest(bytes32 hash, address src, address dst, uint amount, uint fee,
                  uint nonce, uint expiry, address relayer) internal view returns (bytes32) {

    return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR,
                                      keccak256(abi.encode(hash, src, dst, amount, fee, nonce, expiry, relayer))
                                      )
                     );
  }

  function digest(bytes32 hash, address src, uint amount, uint min_eth, uint fee,
                  uint nonce, uint expiry, address relayer) internal view returns (bytes32) {

    return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR,
                                      keccak256(abi.encode(hash, src, amount, min_eth, fee, nonce, expiry, relayer))
                                      )
                     );
  }


  function daiCheque(address sender, address receiver, uint amount, uint fee, uint nonce,
                     uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s) public {

    require(sender != address(0) && sender == ecrecover(digest(DAICHEQUE_TYPEHASH, sender, receiver,
                                       amount, fee, nonce, expiry, relayer), v, r, s), "invalid cheque");
    require(nonce  == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "cheque expired");
    dai.transferFrom(sender, relayer, fee);
    dai.transferFrom(sender, receiver, amount);
  }

  function daiSwap(address sender, uint amount, uint min_eth, uint fee, uint nonce,
                   uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s) public returns (uint256) {

    require(sender != address(0) && sender == ecrecover(digest(DAISWAP_TYPEHASH, sender, amount,
                                       min_eth, fee, nonce, expiry, relayer), v, r, s), "invalid swap");
    require(nonce == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "swap expired");
    dai.transferFrom(sender, address(this), amount);
    dai.transferFrom(sender, relayer, fee);
    return daiUniswap.tokenToEthTransferInput(amount, min_eth, now, sender);
  }

  function joinChai(address sender, address receiver, uint amount, uint fee, uint nonce,
                    uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s) public {

    require(sender != address(0) && sender == ecrecover(digest(CHAIJOIN_TYPEHASH, sender, receiver,
                                       amount, fee, nonce, expiry, relayer), v, r, s), "invalid join");
    require(nonce == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "join expired");
    dai.transferFrom(sender, address(this), amount);
    dai.transferFrom(sender, relayer, fee);
    chai.join(receiver, amount);
  }


  function chaiCheque(address sender, address receiver, uint amount, uint fee, uint nonce,
                      uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s) public {

    require(sender != address(0) && sender == ecrecover(digest(CHAICHEQUE_TYPEHASH, sender, receiver,
                                       amount, fee, nonce, expiry, relayer), v, r, s), "invalid cheque");
    require(nonce  == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "cheque expired");
    chai.transferFrom(sender, relayer, fee);
    chai.transferFrom(sender, receiver, amount);
  }

  function chaiSwap(address sender, uint amount, uint min_eth, uint fee, uint nonce,
                    uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s) public returns (uint256) {

    require(sender != address(0) && sender == ecrecover(digest(CHAISWAP_TYPEHASH, sender, amount,
                                       min_eth, fee, nonce, expiry, relayer), v, r, s), "invalid swap");
    require(nonce == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "swap expired");
    chai.transferFrom(sender, address(this), amount);
    chai.transferFrom(sender, relayer, fee);
    return chaiUniswap.tokenToEthTransferInput(amount, min_eth, now, sender);
  }

  function exitChai(address sender, address receiver, uint amount, uint fee, uint nonce,
                    uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s) public {

    require(sender != address(0) && sender == ecrecover(digest(CHAIEXIT_TYPEHASH, sender, receiver,
                                       amount, fee, nonce, expiry, relayer), v, r, s), "invalid exit");
    require(nonce == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "exit expired");
    chai.exit(sender, amount);
    dai.transferFrom(address(this), receiver, dai.balanceOf(address(this)));
    chai.transferFrom(sender, relayer, fee);
  }
}