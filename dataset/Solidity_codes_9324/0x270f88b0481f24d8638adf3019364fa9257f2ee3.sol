
pragma solidity 0.4.23;


contract IICOInfo {

  function estimate(uint256 _wei) public constant returns (uint tokens);

  function purchasedTokenBalanceOf(address addr) public constant returns (uint256 tokens);

  function isSaleActive() public constant returns (bool active);

}


contract IMintableToken {

    function mint(address _to, uint256 _amount);

}



pragma solidity ^0.4.18;

contract OraclizeI {

    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);

    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);

    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);

    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);

    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);

    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);

    function getPrice(string _datasource) public returns (uint _dsprice);

    function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);

    function setProofType(byte _proofType) external;

    function setCustomGasPrice(uint _gasPrice) external;

    function randomDS_getSessionPubKeyHash() external constant returns(bytes32);

}
contract OraclizeAddrResolverI {

    function getAddress() public returns (address _addr);

}
contract usingOraclize {

    uint constant day = 60*60*24;
    uint constant week = 60*60*24*7;
    uint constant month = 60*60*24*30;
    byte constant proofType_NONE = 0x00;
    byte constant proofType_TLSNotary = 0x10;
    byte constant proofType_Android = 0x20;
    byte constant proofType_Ledger = 0x30;
    byte constant proofType_Native = 0xF0;
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;

    OraclizeI oraclize;
    modifier oraclizeAPI {

        if((address(OAR)==0)||(getCodeSize(address(OAR))==0))
            oraclize_setNetwork(networkID_auto);

        if(address(oraclize) != OAR.getAddress())
            oraclize = OraclizeI(OAR.getAddress());

        _;
    }
    modifier coupon(string code){

        oraclize = OraclizeI(OAR.getAddress());
        _;
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){

      return oraclize_setNetwork();
      networkID; // silence the warning and remain backwards compatible
    }
    function oraclize_setNetwork() internal returns(bool){

        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet
            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
            oraclize_setNetworkName("eth_mainnet");
            return true;
        }
        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet
            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
            oraclize_setNetworkName("eth_ropsten3");
            return true;
        }
        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet
            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
            oraclize_setNetworkName("eth_kovan");
            return true;
        }
        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet
            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
            oraclize_setNetworkName("eth_rinkeby");
            return true;
        }
        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge
            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
            return true;
        }
        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide
            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
            return true;
        }
        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity
            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
            return true;
        }
        return false;
    }

    function __callback(bytes32 myid, string result) public {

        __callback(myid, result, new bytes(0));
    }
    function __callback(bytes32 myid, string result, bytes proof) public {

      return;
      myid; result; proof; // Silence compiler warnings
    }

    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){

        return oraclize.getPrice(datasource);
    }

    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){

        return oraclize.getPrice(datasource, gaslimit);
    }

    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(0, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(timestamp, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(0, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_cbAddress() oraclizeAPI internal returns (address){

        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {

        return oraclize.setProofType(proofP);
    }
    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {

        return oraclize.setCustomGasPrice(gasPrice);
    }

    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){

        return oraclize.randomDS_getSessionPubKeyHash();
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {

        assembly {
            _size := extcodesize(_addr)
        }
    }

    function parseAddr(string _a) internal pure returns (address){

        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }

    function strCompare(string _a, string _b) internal pure returns (int) {

        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

    function indexOf(string _haystack, string _needle) internal pure returns (int) {

        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if(h.length < 1 || n.length < 1 || (n.length > h.length))
            return -1;
        else if(h.length > (2**128 -1))
            return -1;
        else
        {
            uint subindex = 0;
            for (uint i = 0; i < h.length; i ++)
            {
                if (h[i] == n[0])
                {
                    subindex = 1;
                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])
                    {
                        subindex++;
                    }
                    if(subindex == n.length)
                        return int(i);
                }
            }
            return -1;
        }
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {

        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal pure returns (string) {

        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal pure returns (string) {

        return strConcat(_a, _b, "", "", "");
    }

    function parseInt(string _a) internal pure returns (uint) {

        return parseInt(_a, 0);
    }

    function parseInt(string _a, uint _b) internal pure returns (uint) {

        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                if (decimals){
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mint *= 10**_b;
        return mint;
    }

    function uint2str(uint i) internal pure returns (string){

        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    function stra2cbor(string[] arr) internal pure returns (bytes) {

            uint arrlen = arr.length;

            uint outputlen = 0;
            bytes[] memory elemArray = new bytes[](arrlen);
            for (uint i = 0; i < arrlen; i++) {
                elemArray[i] = (bytes(arr[i]));
                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types
            }
            uint ctr = 0;
            uint cborlen = arrlen + 0x80;
            outputlen += byte(cborlen).length;
            bytes memory res = new bytes(outputlen);

            while (byte(cborlen).length > ctr) {
                res[ctr] = byte(cborlen)[ctr];
                ctr++;
            }
            for (i = 0; i < arrlen; i++) {
                res[ctr] = 0x5F;
                ctr++;
                for (uint x = 0; x < elemArray[i].length; x++) {
                    if (x % 23 == 0) {
                        uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
                        elemcborlen += 0x40;
                        uint lctr = ctr;
                        while (byte(elemcborlen).length > ctr - lctr) {
                            res[ctr] = byte(elemcborlen)[ctr - lctr];
                            ctr++;
                        }
                    }
                    res[ctr] = elemArray[i][x];
                    ctr++;
                }
                res[ctr] = 0xFF;
                ctr++;
            }
            return res;
        }

    function ba2cbor(bytes[] arr) internal pure returns (bytes) {

            uint arrlen = arr.length;

            uint outputlen = 0;
            bytes[] memory elemArray = new bytes[](arrlen);
            for (uint i = 0; i < arrlen; i++) {
                elemArray[i] = (bytes(arr[i]));
                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types
            }
            uint ctr = 0;
            uint cborlen = arrlen + 0x80;
            outputlen += byte(cborlen).length;
            bytes memory res = new bytes(outputlen);

            while (byte(cborlen).length > ctr) {
                res[ctr] = byte(cborlen)[ctr];
                ctr++;
            }
            for (i = 0; i < arrlen; i++) {
                res[ctr] = 0x5F;
                ctr++;
                for (uint x = 0; x < elemArray[i].length; x++) {
                    if (x % 23 == 0) {
                        uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
                        elemcborlen += 0x40;
                        uint lctr = ctr;
                        while (byte(elemcborlen).length > ctr - lctr) {
                            res[ctr] = byte(elemcborlen)[ctr - lctr];
                            ctr++;
                        }
                    }
                    res[ctr] = elemArray[i][x];
                    ctr++;
                }
                res[ctr] = 0xFF;
                ctr++;
            }
            return res;
        }


    string oraclize_network_name;
    function oraclize_setNetworkName(string _network_name) internal {

        oraclize_network_name = _network_name;
    }

    function oraclize_getNetworkName() internal view returns (string) {

        return oraclize_network_name;
    }

    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){

        require((_nbytes > 0) && (_nbytes <= 32));
        _delay *= 10; 
        bytes memory nbytes = new bytes(1);
        nbytes[0] = byte(_nbytes);
        bytes memory unonce = new bytes(32);
        bytes memory sessionKeyHash = new bytes(32);
        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();
        assembly {
            mstore(unonce, 0x20)
            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))
            mstore(sessionKeyHash, 0x20)
            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)
        }
        bytes memory delay = new bytes(32);
        assembly { 
            mstore(add(delay, 0x20), _delay) 
        }
        
        bytes memory delay_bytes8 = new bytes(8);
        copyBytes(delay, 24, 8, delay_bytes8, 0);

        bytes[4] memory args = [unonce, nbytes, sessionKeyHash, delay];
        bytes32 queryId = oraclize_query("random", args, _customGasLimit);
        
        bytes memory delay_bytes8_left = new bytes(8);
        
        assembly {
            let x := mload(add(delay_bytes8, 0x20))
            mstore8(add(delay_bytes8_left, 0x27), div(x, 0x100000000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x26), div(x, 0x1000000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x25), div(x, 0x10000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x24), div(x, 0x100000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x23), div(x, 0x1000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x22), div(x, 0x10000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x21), div(x, 0x100000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x20), div(x, 0x1000000000000000000000000000000000000000000000000))

        }
        
        oraclize_randomDS_setCommitment(queryId, keccak256(delay_bytes8_left, args[1], sha256(args[0]), args[2]));
        return queryId;
    }
    
    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {

        oraclize_randomDS_args[queryId] = commitment;
    }

    mapping(bytes32=>bytes32) oraclize_randomDS_args;
    mapping(bytes32=>bool) oraclize_randomDS_sessionKeysHashVerified;

    function verifySig(bytes32 tosignh, bytes dersig, bytes pubkey) internal returns (bool){

        bool sigok;
        address signer;

        bytes32 sigr;
        bytes32 sigs;

        bytes memory sigr_ = new bytes(32);
        uint offset = 4+(uint(dersig[3]) - 0x20);
        sigr_ = copyBytes(dersig, offset, 32, sigr_, 0);
        bytes memory sigs_ = new bytes(32);
        offset += 32 + 2;
        sigs_ = copyBytes(dersig, offset+(uint(dersig[offset-1]) - 0x20), 32, sigs_, 0);

        assembly {
            sigr := mload(add(sigr_, 32))
            sigs := mload(add(sigs_, 32))
        }


        (sigok, signer) = safer_ecrecover(tosignh, 27, sigr, sigs);
        if (address(keccak256(pubkey)) == signer) return true;
        else {
            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);
            return (address(keccak256(pubkey)) == signer);
        }
    }

    function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes proof, uint sig2offset) internal returns (bool) {

        bool sigok;

        bytes memory sig2 = new bytes(uint(proof[sig2offset+1])+2);
        copyBytes(proof, sig2offset, sig2.length, sig2, 0);

        bytes memory appkey1_pubkey = new bytes(64);
        copyBytes(proof, 3+1, 64, appkey1_pubkey, 0);

        bytes memory tosign2 = new bytes(1+65+32);
        tosign2[0] = byte(1); //role
        copyBytes(proof, sig2offset-65, 65, tosign2, 1);
        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";
        copyBytes(CODEHASH, 0, 32, tosign2, 1+65);
        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);

        if (sigok == false) return false;


        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";

        bytes memory tosign3 = new bytes(1+65);
        tosign3[0] = 0xFE;
        copyBytes(proof, 3, 65, tosign3, 1);

        bytes memory sig3 = new bytes(uint(proof[3+65+1])+2);
        copyBytes(proof, 3+65, sig3.length, sig3, 0);

        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);

        return sigok;
    }

    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {

        require((_proof[0] == "L") && (_proof[1] == "P") && (_proof[2] == 1));

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        require(proofVerified);

        _;
    }

    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string _result, bytes _proof) internal returns (uint8){

        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) return 1;

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        if (proofVerified == false) return 2;

        return 0;
    }

    function matchBytes32Prefix(bytes32 content, bytes prefix, uint n_random_bytes) internal pure returns (bool){

        bool match_ = true;
        
        require(prefix.length == n_random_bytes);

        for (uint256 i=0; i< n_random_bytes; i++) {
            if (content[i] != prefix[i]) match_ = false;
        }

        return match_;
    }

    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){


        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;
        bytes memory keyhash = new bytes(32);
        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);
        if (!(keccak256(keyhash) == keccak256(sha256(context_name, queryId)))) return false;

        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);
        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);

        if (!matchBytes32Prefix(sha256(sig1), result, uint(proof[ledgerProofLength+32+8]))) return false;

        bytes memory commitmentSlice1 = new bytes(8+1+32);
        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);

        bytes memory sessionPubkey = new bytes(64);
        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;
        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);

        bytes32 sessionPubkeyHash = sha256(sessionPubkey);
        if (oraclize_randomDS_args[queryId] == keccak256(commitmentSlice1, sessionPubkeyHash)){ //unonce, nbytes and sessionKeyHash match
            delete oraclize_randomDS_args[queryId];
        } else return false;


        bytes memory tosign1 = new bytes(32+8+1+32);
        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);
        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) return false;

        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){
            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);
        }

        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];
    }

    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal pure returns (bytes) {

        uint minLength = length + toOffset;

        require(to.length >= minLength); // Should be a better way?

        uint i = 32 + fromOffset;
        uint j = 32 + toOffset;

        while (i < (32 + fromOffset + length)) {
            assembly {
                let tmp := mload(add(from, i))
                mstore(add(to, j), tmp)
            }
            i += 32;
            j += 32;
        }

        return to;
    }

    function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {


        bool ret;
        address addr;

        assembly {
            let size := mload(0x40)
            mstore(size, hash)
            mstore(add(size, 32), v)
            mstore(add(size, 64), r)
            mstore(add(size, 96), s)

            ret := call(3000, 1, 0, size, 128, size, 32)
            addr := mload(size)
        }

        return (ret, addr);
    }

    function ecrecovery(bytes32 hash, bytes sig) internal returns (bool, address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (sig.length != 65)
          return (false, 0);

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))

            v := byte(0, mload(add(sig, 96)))

        }

        if (v < 27)
          v += 27;

        if (v != 27 && v != 28)
            return (false, 0);

        return safer_ecrecover(hash, v, r, s);
    }

}







pragma solidity ^0.4.15;


contract multiowned {



    struct MultiOwnedOperationPendingState {
        uint yetNeeded;

        uint ownersDone;

        uint index;
    }


    event Confirmation(address owner, bytes32 operation);
    event Revoke(address owner, bytes32 operation);
    event FinalConfirmation(address owner, bytes32 operation);

    event OwnerChanged(address oldOwner, address newOwner);
    event OwnerAdded(address newOwner);
    event OwnerRemoved(address oldOwner);

    event RequirementChanged(uint newRequirement);


    modifier onlyowner {

        require(isOwner(msg.sender));
        _;
    }
    modifier onlymanyowners(bytes32 _operation) {

        if (confirmAndCheck(_operation)) {
            _;
        }
    }

    modifier validNumOwners(uint _numOwners) {

        require(_numOwners > 0 && _numOwners <= c_maxOwners);
        _;
    }

    modifier multiOwnedValidRequirement(uint _required, uint _numOwners) {

        require(_required > 0 && _required <= _numOwners);
        _;
    }

    modifier ownerExists(address _address) {

        require(isOwner(_address));
        _;
    }

    modifier ownerDoesNotExist(address _address) {

        require(!isOwner(_address));
        _;
    }

    modifier multiOwnedOperationIsActive(bytes32 _operation) {

        require(isOperationActive(_operation));
        _;
    }


    function multiowned(address[] _owners, uint _required)
        public
        validNumOwners(_owners.length)
        multiOwnedValidRequirement(_required, _owners.length)
    {

        assert(c_maxOwners <= 255);

        m_numOwners = _owners.length;
        m_multiOwnedRequired = _required;

        for (uint i = 0; i < _owners.length; ++i)
        {
            address owner = _owners[i];
            require(0 != owner && !isOwner(owner) /* not isOwner yet! */);

            uint currentOwnerIndex = checkOwnerIndex(i + 1 /* first slot is unused */);
            m_owners[currentOwnerIndex] = owner;
            m_ownerIndex[owner] = currentOwnerIndex;
        }

        assertOwnersAreConsistent();
    }

    function changeOwner(address _from, address _to)
        external
        ownerExists(_from)
        ownerDoesNotExist(_to)
        onlymanyowners(keccak256(msg.data))
    {

        assertOwnersAreConsistent();

        clearPending();
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_from]);
        m_owners[ownerIndex] = _to;
        m_ownerIndex[_from] = 0;
        m_ownerIndex[_to] = ownerIndex;

        assertOwnersAreConsistent();
        OwnerChanged(_from, _to);
    }

    function addOwner(address _owner)
        external
        ownerDoesNotExist(_owner)
        validNumOwners(m_numOwners + 1)
        onlymanyowners(keccak256(msg.data))
    {

        assertOwnersAreConsistent();

        clearPending();
        m_numOwners++;
        m_owners[m_numOwners] = _owner;
        m_ownerIndex[_owner] = checkOwnerIndex(m_numOwners);

        assertOwnersAreConsistent();
        OwnerAdded(_owner);
    }

    function removeOwner(address _owner)
        external
        ownerExists(_owner)
        validNumOwners(m_numOwners - 1)
        multiOwnedValidRequirement(m_multiOwnedRequired, m_numOwners - 1)
        onlymanyowners(keccak256(msg.data))
    {

        assertOwnersAreConsistent();

        clearPending();
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_owner]);
        m_owners[ownerIndex] = 0;
        m_ownerIndex[_owner] = 0;
        reorganizeOwners();

        assertOwnersAreConsistent();
        OwnerRemoved(_owner);
    }

    function changeRequirement(uint _newRequired)
        external
        multiOwnedValidRequirement(_newRequired, m_numOwners)
        onlymanyowners(keccak256(msg.data))
    {

        m_multiOwnedRequired = _newRequired;
        clearPending();
        RequirementChanged(_newRequired);
    }

    function getOwner(uint ownerIndex) public constant returns (address) {

        return m_owners[ownerIndex + 1];
    }

    function getOwners() public constant returns (address[]) {

        address[] memory result = new address[](m_numOwners);
        for (uint i = 0; i < m_numOwners; i++)
            result[i] = getOwner(i);

        return result;
    }

    function isOwner(address _addr) public constant returns (bool) {

        return m_ownerIndex[_addr] > 0;
    }

    function amIOwner() external constant onlyowner returns (bool) {

        return true;
    }

    function revoke(bytes32 _operation)
        external
        multiOwnedOperationIsActive(_operation)
        onlyowner
    {

        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);
        var pending = m_multiOwnedPending[_operation];
        require(pending.ownersDone & ownerIndexBit > 0);

        assertOperationIsConsistent(_operation);

        pending.yetNeeded++;
        pending.ownersDone -= ownerIndexBit;

        assertOperationIsConsistent(_operation);
        Revoke(msg.sender, _operation);
    }

    function hasConfirmed(bytes32 _operation, address _owner)
        external
        constant
        multiOwnedOperationIsActive(_operation)
        ownerExists(_owner)
        returns (bool)
    {

        return !(m_multiOwnedPending[_operation].ownersDone & makeOwnerBitmapBit(_owner) == 0);
    }


    function confirmAndCheck(bytes32 _operation)
        private
        onlyowner
        returns (bool)
    {

        if (512 == m_multiOwnedPendingIndex.length)
            clearPending();

        var pending = m_multiOwnedPending[_operation];

        if (! isOperationActive(_operation)) {
            pending.yetNeeded = m_multiOwnedRequired;
            pending.ownersDone = 0;
            pending.index = m_multiOwnedPendingIndex.length++;
            m_multiOwnedPendingIndex[pending.index] = _operation;
            assertOperationIsConsistent(_operation);
        }

        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);
        if (pending.ownersDone & ownerIndexBit == 0) {
            assert(pending.yetNeeded > 0);
            if (pending.yetNeeded == 1) {
                delete m_multiOwnedPendingIndex[m_multiOwnedPending[_operation].index];
                delete m_multiOwnedPending[_operation];
                FinalConfirmation(msg.sender, _operation);
                return true;
            }
            else
            {
                pending.yetNeeded--;
                pending.ownersDone |= ownerIndexBit;
                assertOperationIsConsistent(_operation);
                Confirmation(msg.sender, _operation);
            }
        }
    }

    function reorganizeOwners() private {

        uint free = 1;
        while (free < m_numOwners)
        {
            while (free < m_numOwners && m_owners[free] != 0) free++;

            while (m_numOwners > 1 && m_owners[m_numOwners] == 0) m_numOwners--;

            if (free < m_numOwners && m_owners[m_numOwners] != 0 && m_owners[free] == 0)
            {
                m_owners[free] = m_owners[m_numOwners];
                m_ownerIndex[m_owners[free]] = free;
                m_owners[m_numOwners] = 0;
            }
        }
    }

    function clearPending() private onlyowner {

        uint length = m_multiOwnedPendingIndex.length;
        for (uint i = 0; i < length; ++i) {
            if (m_multiOwnedPendingIndex[i] != 0)
                delete m_multiOwnedPending[m_multiOwnedPendingIndex[i]];
        }
        delete m_multiOwnedPendingIndex;
    }

    function checkOwnerIndex(uint ownerIndex) private pure returns (uint) {

        assert(0 != ownerIndex && ownerIndex <= c_maxOwners);
        return ownerIndex;
    }

    function makeOwnerBitmapBit(address owner) private constant returns (uint) {

        uint ownerIndex = checkOwnerIndex(m_ownerIndex[owner]);
        return 2 ** ownerIndex;
    }

    function isOperationActive(bytes32 _operation) private constant returns (bool) {

        return 0 != m_multiOwnedPending[_operation].yetNeeded;
    }


    function assertOwnersAreConsistent() private constant {

        assert(m_numOwners > 0);
        assert(m_numOwners <= c_maxOwners);
        assert(m_owners[0] == 0);
        assert(0 != m_multiOwnedRequired && m_multiOwnedRequired <= m_numOwners);
    }

    function assertOperationIsConsistent(bytes32 _operation) private constant {

        var pending = m_multiOwnedPending[_operation];
        assert(0 != pending.yetNeeded);
        assert(m_multiOwnedPendingIndex[pending.index] == _operation);
        assert(pending.yetNeeded <= m_multiOwnedRequired);
    }



    uint constant c_maxOwners = 250;

    uint public m_multiOwnedRequired;


    uint public m_numOwners;

    address[256] internal m_owners;

    mapping(address => uint) internal m_ownerIndex;


    mapping(bytes32 => MultiOwnedOperationPendingState) internal m_multiOwnedPending;
    bytes32[] internal m_multiOwnedPendingIndex;
}


library SafeMath {

  function mul(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract EthPriceDependent is usingOraclize, multiowned {


    using SafeMath for uint256;

    event NewOraclizeQuery(string description);
    event NewETHPrice(uint price);
    event ETHPriceOutOfBounds(uint price);

    function EthPriceDependent(address[] _initialOwners,  uint _consensus, bool _production)
        public
        multiowned(_initialOwners, _consensus)
    {

        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        if (!_production) {
            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
        } else {
            updateETHPriceInCents();
        }
    }

    function updateETHPriceInCents() public payable {

        if ( !updateRequestExpired() ) {
            NewOraclizeQuery("Oraclize request fail. Previous one still pending");
        } else if (oraclize_getPrice("URL") > this.balance) {
            NewOraclizeQuery("Oraclize request fail. Not enough ether");
        } else {
            oraclize_query(
                m_ETHPriceUpdateInterval,
                "URL",
                "json(https://api.coinmarketcap.com/v1/ticker/ethereum/?convert=USD).0.price_usd",
                m_callbackGas
            );
            m_ETHPriceLastUpdateRequest = getTime();
            NewOraclizeQuery("Oraclize query was sent");
        }
    }

    function __callback(bytes32 myid, string result, bytes proof) public {

        require(msg.sender == oraclize_cbAddress());

        uint newPrice = parseInt(result).mul(100);

        if (newPrice >= m_ETHPriceLowerBound && newPrice <= m_ETHPriceUpperBound) {
            m_ETHPriceInCents = newPrice;
            m_ETHPriceLastUpdate = getTime();
            NewETHPrice(m_ETHPriceInCents);
        } else {
            ETHPriceOutOfBounds(newPrice);
        }
        updateETHPriceInCents();
    }

    function setETHPriceUpperBound(uint _price)
        external
        onlymanyowners(keccak256(msg.data))
    {

        m_ETHPriceUpperBound = _price;
    }

    function setETHPriceLowerBound(uint _price)
        external
        onlymanyowners(keccak256(msg.data))
    {

        m_ETHPriceLowerBound = _price;
    }

    function setETHPriceManually(uint _price)
        external
        onlymanyowners(keccak256(msg.data))
    {

        require( priceExpired() || updateRequestExpired() );
        m_ETHPriceInCents = _price;
        m_ETHPriceLastUpdate = getTime();
        NewETHPrice(m_ETHPriceInCents);
    }

    function topUp() external payable {

    }

    function setOraclizeGasPrice(uint _gasPrice)
        external
        onlymanyowners(keccak256(msg.data))
    {

        oraclize_setCustomGasPrice(_gasPrice);
    }

    function setOraclizeGasLimit(uint _callbackGas)
        external
        onlymanyowners(keccak256(msg.data))
    {

        m_callbackGas = _callbackGas;
    }

    function priceExpired() public view returns (bool) {

        return (getTime() > m_ETHPriceLastUpdate + 2 * m_ETHPriceUpdateInterval);
    }

    function updateRequestExpired() public view returns (bool) {

        return ( (getTime() + m_leeway) >= (m_ETHPriceLastUpdateRequest + m_ETHPriceUpdateInterval) );
    }

    function getTime() internal view returns (uint) {

        return now;
    }


    uint public m_ETHPriceInCents = 0;
    uint public m_ETHPriceLastUpdate;
    uint public m_ETHPriceLastUpdateRequest;

    uint public m_ETHPriceLowerBound = 100;
    uint public m_ETHPriceUpperBound = 100000000;

    uint public m_ETHPriceUpdateInterval = 60*60*1;

    uint public m_leeway = 900; // 15 minutes is the limit for miners

    uint public m_callbackGas = 200000;
}


contract EthPriceDependentForICO is EthPriceDependent {


    function priceExpired() public view returns (bool) {

        return false;
    }

    uint public m_ETHPriceLifetime = 60*60*12;
}


interface IBoomstarterToken {

    function changeOwner(address _from, address _to) external;

    function addOwner(address _owner) external;

    function removeOwner(address _owner) external;

    function changeRequirement(uint _newRequired) external;

    function getOwner(uint ownerIndex) public view returns (address);

    function getOwners() public view returns (address[]);

    function isOwner(address _addr) public view returns (bool);

    function amIOwner() external view returns (bool);

    function revoke(bytes32 _operation) external;

    function hasConfirmed(bytes32 _operation, address _owner) external view returns (bool);


    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);


    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);


    function name() public view returns (string);

    function symbol() public view returns (string);

    function decimals() public view returns (uint8);


    function burn(uint256 _amount) public returns (bool);


    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public;


    function setSale(address account, bool isSale) external;

    function switchToNextSale(address _newSale) external;

    function thaw() external;

    function disablePrivileged() external;


}





pragma solidity ^0.4.15;



contract MultiownedControlled is multiowned {


    event ControllerSet(address controller);
    event ControllerRetired(address was);
    event ControllerRetiredForever(address was);


    modifier onlyController {

        require(msg.sender == m_controller);
        _;
    }



    function MultiownedControlled(address[] _owners, uint _signaturesRequired, address _controller)
        public
        multiowned(_owners, _signaturesRequired)
    {

        m_controller = _controller;
        ControllerSet(m_controller);
    }

    function setController(address _controller) external onlymanyowners(keccak256(msg.data)) {

        require(m_attaching_enabled);
        m_controller = _controller;
        ControllerSet(m_controller);
    }

    function detachController() external onlyController {

        address was = m_controller;
        m_controller = address(0);
        ControllerRetired(was);
    }

    function detachControllerForever() external onlyController {

        assert(m_attaching_enabled);
        address was = m_controller;
        m_controller = address(0);
        m_attaching_enabled = false;
        ControllerRetiredForever(was);
    }



    address public m_controller;

    bool public m_attaching_enabled = true;
}





pragma solidity ^0.4.15;


contract ArgumentsChecker {


    modifier payloadSizeIs(uint size) {

       require(msg.data.length == size + 4 /* function selector */);
       _;
    }

    modifier validAddress(address addr) {

        require(addr != address(0));
        _;
    }
}


contract ReentrancyGuard {


  bool private rentrancy_lock = false;

  modifier nonReentrant() {

    require(!rentrancy_lock);
    rentrancy_lock = true;
    _;
    rentrancy_lock = false;
  }

}


contract FundsRegistry is ArgumentsChecker, MultiownedControlled, ReentrancyGuard {

    using SafeMath for uint256;

    enum State {
        GATHERING,
        REFUNDING,
        SUCCEEDED
    }

    event StateChanged(State _state);
    event Invested(address indexed investor, uint etherInvested, uint tokensReceived);
    event EtherSent(address indexed to, uint value);
    event RefundSent(address indexed to, uint value);


    modifier requiresState(State _state) {

        require(m_state == _state);
        _;
    }



    function FundsRegistry(
        address[] _owners,
        uint _signaturesRequired,
        address _controller,
        address _token
    )
        MultiownedControlled(_owners, _signaturesRequired, _controller)
    {

        m_token = IBoomstarterToken(_token);
    }

    function changeState(State _newState)
        external
        onlyController
    {

        assert(m_state != _newState);

        if (State.GATHERING == m_state) {   assert(State.REFUNDING == _newState || State.SUCCEEDED == _newState); }
        else assert(false);

        m_state = _newState;
        StateChanged(m_state);
    }

    function invested(address _investor, uint _tokenAmount)
        external
        payable
        onlyController
        requiresState(State.GATHERING)
    {

        uint256 amount = msg.value;
        require(0 != amount);
        assert(_investor != m_controller);

        if (0 == m_weiBalances[_investor])
            m_investors.push(_investor);

        totalInvested = totalInvested.add(amount);
        m_weiBalances[_investor] = m_weiBalances[_investor].add(amount);
        m_tokenBalances[_investor] = m_tokenBalances[_investor].add(_tokenAmount);

        Invested(_investor, amount, _tokenAmount);
    }

    function sendEther(address to, uint value)
        external
        validAddress(to)
        onlymanyowners(keccak256(msg.data))
        requiresState(State.SUCCEEDED)
    {

        require(value > 0 && this.balance >= value);
        to.transfer(value);
        EtherSent(to, value);
    }

    function sendTokens(address to, uint value)
        external
        validAddress(to)
        onlymanyowners(keccak256(msg.data))
        requiresState(State.REFUNDING)
    {

        require(value > 0 && m_token.balanceOf(this) >= value);
        m_token.transfer(to, value);
    }

    function withdrawPayments()
        external
        nonReentrant
        requiresState(State.REFUNDING)
    {

        address payee = msg.sender;
        uint payment = m_weiBalances[payee];
        uint tokens = m_tokenBalances[payee];

        require(payment != 0);
        require(this.balance >= payment);
        require(m_token.allowance(payee, this) >= m_tokenBalances[payee]);

        totalInvested = totalInvested.sub(payment);
        m_weiBalances[payee] = 0;
        m_tokenBalances[payee] = 0;

        m_token.transferFrom(payee, this, tokens);

        payee.transfer(payment);
        RefundSent(payee, payment);
    }

    function getInvestorsCount() external constant returns (uint) { return m_investors.length; }



    uint256 public totalInvested;

    State public m_state = State.GATHERING;

    mapping(address => uint256) public m_weiBalances;

    mapping(address => uint256) public m_tokenBalances;

    address[] public m_investors;

    IBoomstarterToken public m_token;
}


contract BoomstarterICO is ArgumentsChecker, ReentrancyGuard, EthPriceDependentForICO, IICOInfo, IMintableToken {


    enum IcoState { INIT, ACTIVE, PAUSED, FAILED, SUCCEEDED }

    event StateChanged(IcoState _state);
    event FundTransfer(address backer, uint amount, bool isContribution);


    modifier requiresState(IcoState _state) {

        require(m_state == _state);
        _;
    }

    modifier timedStateChange(address client, uint payment, bool refundable) {

        if (IcoState.INIT == m_state && getTime() >= getStartTime())
            changeState(IcoState.ACTIVE);

        if (IcoState.ACTIVE == m_state && getTime() >= getFinishTime()) {
            finishICO();

            if (refundable && payment > 0)
                client.transfer(payment);
        } else {
            _;
        }
    }

    modifier fundsChecker(address client, uint payment, bool refundable) {

        uint atTheBeginning = m_funds.balance;
        if (atTheBeginning < m_lastFundsAmount) {
            changeState(IcoState.PAUSED);
            if (refundable && payment > 0)
                client.transfer(payment);     // we cant throw (have to save state), so refunding this way
        } else {
            _;

            if (m_funds.balance < atTheBeginning) {
                changeState(IcoState.PAUSED);
            } else {
                m_lastFundsAmount = m_funds.balance;
            }
        }
    }

    function estimate(uint256 _wei) public view returns (uint tokens) {

        uint amount;
        (amount, ) = estimateTokensWithActualPayment(_wei);
        return amount;
    }

    function isSaleActive() public view returns (bool active) {

        return m_state == IcoState.ACTIVE && !priceExpired();
    }

    function purchasedTokenBalanceOf(address addr) public view returns (uint256 tokens) {

        return m_token.balanceOf(addr);
    }

    function estimateTokensWithActualPayment(uint256 _payment) public view returns (uint amount, uint actualPayment) {

        uint tokens = _payment.mul(m_ETHPriceInCents).div(getPrice());

        if (tokens.add(m_currentTokensSold) > c_maximumTokensSold) {
            tokens = c_maximumTokensSold.sub( m_currentTokensSold );
            _payment = getPrice().mul(tokens).div(m_ETHPriceInCents);
        }

        if (_payment.mul(m_ETHPriceInCents).div(1 ether) >= 5000000) {
            tokens = tokens.add(tokens.div(5));
            if (tokens.add(m_currentTokensSold) > c_maximumTokensSold) {
                tokens = c_maximumTokensSold.sub(m_currentTokensSold);
            }
        }

        return (tokens, _payment);
    }



    function BoomstarterICO(
        address[] _owners,
        address _token,
        uint _updateInterval,
        bool _production
    )
        public
        payable
        EthPriceDependent(_owners, 2, _production)
        validAddress(_token)
    {

        require(3 == _owners.length);

        m_token = IBoomstarterToken(_token);
        m_deployer = msg.sender;
        m_ETHPriceUpdateInterval = _updateInterval;
        oraclize_setCustomGasPrice(40000000);
    }

    function init(address _funds, address _tokenDistributor, uint _previouslySold)
        external
        validAddress(_funds)
        validAddress(_tokenDistributor)
        onlymanyowners(keccak256(msg.data))
    {

        require(m_funds == address(0));
        m_funds = FundsRegistry(_funds);

        c_maximumTokensSold = m_token.balanceOf(this).sub( m_token.totalSupply().div(4) );

        if (_previouslySold < c_softCapUsd)
            c_softCapUsd = c_softCapUsd.sub(_previouslySold);
        else
            c_softCapUsd = 0;

        m_tokenDistributor = _tokenDistributor;
    }



    function() payable {
        require(0 == msg.data.length);
        buy();  // only internal call here!
    }

    function buy() public payable {     // dont mark as external!

        internalBuy(msg.sender, msg.value, true);
    }

    function mint(address client, uint256 ethers) public {

        nonEtherBuy(client, ethers);
    }


    function nonEtherBuy(address client, uint etherEquivalentAmount)
        public
    {

        require(msg.sender == m_nonEtherController);
        require(etherEquivalentAmount <= 70000 ether);
        internalBuy(client, etherEquivalentAmount, false);
    }

    function internalBuy(address client, uint payment, bool refundable)
        internal
        nonReentrant
        timedStateChange(client, payment, refundable)
        fundsChecker(client, payment, refundable)
    {

        require( !priceExpired() );
        require(m_state == IcoState.ACTIVE || m_state == IcoState.INIT && isOwner(client) /* for final test */);

        require((payment.mul(m_ETHPriceInCents)).div(1 ether) >= c_MinInvestmentInCents);


        uint actualPayment = payment;
        uint amount;

        (amount, actualPayment) = estimateTokensWithActualPayment(payment);


        m_currentUsdAccepted = m_currentUsdAccepted.add( actualPayment.mul(m_ETHPriceInCents).div(1 ether) );
        m_currentTokensSold = m_currentTokensSold.add( amount );

        m_token.transfer(client, amount);

        assert(m_currentTokensSold <= c_maximumTokensSold);

        if (refundable) {
            m_funds.invested.value(actualPayment)(client, amount);
            FundTransfer(client, actualPayment, true);
        }

        if (payment.sub(actualPayment) > 0) {
            assert(c_maximumTokensSold == m_currentTokensSold);
            finishICO();

            client.transfer(payment.sub(actualPayment));
        } else if (c_maximumTokensSold == m_currentTokensSold) {
            finishICO();
        }
    }



    function getPrice() public view returns (uint) {

        for (uint i = c_priceChangeDates.length - 2; i > 0; i--) {
            if (getTime() >= c_priceChangeDates[i]) {
              return c_tokenPrices[i];
            }
        }
        return c_tokenPrices[0];
    }

    function getStartTime() public view returns (uint) {

        return c_priceChangeDates[0];
    }

    function getFinishTime() public view returns (uint) {

        return c_priceChangeDates[c_priceChangeDates.length - 1];
    }



    function pause()
        external
        timedStateChange(address(0), 0, true)
        requiresState(IcoState.ACTIVE)
        onlyowner
    {

        changeState(IcoState.PAUSED);
    }

    function unpause()
        external
        timedStateChange(address(0), 0, true)
        requiresState(IcoState.PAUSED)
        onlymanyowners(keccak256(msg.data))
    {

        changeState(IcoState.ACTIVE);
        checkTime();
    }

    function withdrawTokens(address _to, uint _amount)
        external
        validAddress(_to)
        requiresState(IcoState.FAILED)
        onlymanyowners(keccak256(msg.data))
    {

        require((_amount > 0) && (m_token.balanceOf(this) >= _amount));
        m_token.transfer(_to, _amount);
    }

    function setFundsRegistry(address _funds)
        external
        validAddress(_funds)
        timedStateChange(address(0), 0, true)
        requiresState(IcoState.PAUSED)
        onlymanyowners(keccak256(msg.data))
    {

        m_funds = FundsRegistry(_funds);
    }

    function setNonEtherController(address _controller)
        external
        validAddress(_controller)
        timedStateChange(address(0), 0, true)
        onlymanyowners(keccak256(msg.data))
    {

        m_nonEtherController = _controller;
    }

    function getNonEtherController()
        public
        view
        returns (address)
    {

        return m_nonEtherController;
    }

    function checkTime()
        public
        timedStateChange(address(0), 0, true)
        onlyowner
    {

    }

    function applyHotFix(address newICO)
        public
        validAddress(newICO)
        requiresState(IcoState.PAUSED)
        onlymanyowners(keccak256(msg.data))
    {

        EthPriceDependent next = EthPriceDependent(newICO);
        next.topUp.value(this.balance)();
        m_token.transfer(newICO, m_token.balanceOf(this));
    }

    function withdrawEther(address to)
        public
        validAddress(to)
        onlymanyowners(keccak256(msg.data))
    {

        to.transfer(this.balance);
    }



    function finishICO() private {

        if (m_currentUsdAccepted < c_softCapUsd) {
            changeState(IcoState.FAILED);
        } else {
            changeState(IcoState.SUCCEEDED);
        }
    }

    function changeState(IcoState _newState) private {

        assert(m_state != _newState);

        if (IcoState.INIT == m_state) {
            assert(IcoState.ACTIVE == _newState);
        } else if (IcoState.ACTIVE == m_state) {
            assert(
                IcoState.PAUSED == _newState ||
                IcoState.FAILED == _newState ||
                IcoState.SUCCEEDED == _newState
            );
        } else if (IcoState.PAUSED == m_state) {
            assert(IcoState.ACTIVE == _newState || IcoState.FAILED == _newState);
        } else {
            assert(false);
        }

        m_state = _newState;
        StateChanged(m_state);

        if (IcoState.SUCCEEDED == m_state) {
            onSuccess();
        } else if (IcoState.FAILED == m_state) {
            onFailure();
        }
    }

    function onSuccess() private {

        m_funds.changeState(FundsRegistry.State.SUCCEEDED);
        m_funds.detachController();

        m_token.transfer(m_tokenDistributor, m_token.balanceOf(this));
    }

    function onFailure() private {

        m_funds.changeState(FundsRegistry.State.REFUNDING);
        m_funds.detachController();
    }



    uint[] public c_priceChangeDates = [
        getTime(),  // deployment date: $0.8
        1534107600, // August 13th 2018, 00:00:00 (GMT +3): $1
        1534712400, // August 20th 2018, 00:00:00 (GMT +3): $1.2
        1535317200, // August 27th 2018, 00:00:00 (GMT +3): $1.4
        1535922000, // September 3rd 2018, 00:00:00 (GMT +3): $1.6
        1536526800, // September 10th 2018, 00:00:00 (GMT +3): $1.8
        1537131600, // September 17th 2018, 00:00:00 (GMT +3): $2
        1538341199  // finish: September 30th 2018, 23:59:59 (GMT +3)
    ];

    uint[] public c_tokenPrices = [
        80,  // $0.8
        100, // $1
        120, // $1.2
        140, // $1.4
        160, // $1.6
        180, // $1.8
        200  // $2
    ];

    IcoState public m_state = IcoState.INIT;

    IBoomstarterToken public m_token;

    address public m_tokenDistributor;

    FundsRegistry public m_funds;

    address public m_nonEtherController;

    uint public m_lastFundsAmount;

    uint public c_MinInvestmentInCents = 500; // $5

    uint public m_currentTokensSold;

    uint public c_maximumTokensSold;

    uint public m_currentUsdAccepted;

    uint public c_softCapUsd = 300000000; // $3000000

    address public m_deployer;

}