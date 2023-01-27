
pragma solidity ^0.6.2;


contract FundSummary {

    
    address _owner;     // 资金汇总目标地址
    mapping(address => bool) _erc20ContractAddressManager;  // 支持资产汇总的ERC20合约地址
    mapping(address => bool) _sendTransferAddress;  // 可以发起批量转账的地址
    
    constructor(address owner,address usdtContractAddress,address cnhcContractAddress,address sendTransferAddress) public{
        _owner = owner;
        _erc20ContractAddressManager[usdtContractAddress] = true;
        _erc20ContractAddressManager[cnhcContractAddress] = true;
        _sendTransferAddress[sendTransferAddress] = true;
    }
    function batchTransfer(address contractAddress,address user1) public onlyTransferAddress{

        require(_erc20ContractAddressManager[contractAddress],"erc20 contract address error");
        ERC20 erc20 = ERC20(contractAddress);
        batchTransfer(erc20,user1);
    }
    function batchTransfer(address contractAddress,address user1,address user2) public onlyTransferAddress{

        require(_erc20ContractAddressManager[contractAddress],"erc20 contract address error");
        ERC20 erc20 = ERC20(contractAddress);
        batchTransfer(erc20,user1);
        batchTransfer(erc20,user2);
    }
    function batchTransfer(address contractAddress,address user1,address user2,address user3) public onlyTransferAddress{

        require(_erc20ContractAddressManager[contractAddress],"erc20 contract address error");
        ERC20 erc20 = ERC20(contractAddress);
        batchTransfer(erc20,user1);
        batchTransfer(erc20,user2);
        batchTransfer(erc20,user3);
    }
    function batchTransfer(address contractAddress,address user1,address user2,address user3,address user4) public onlyTransferAddress{

        require(_erc20ContractAddressManager[contractAddress],"erc20 contract address error");
        ERC20 erc20 = ERC20(contractAddress);
        batchTransfer(erc20,user1);
        batchTransfer(erc20,user2);
        batchTransfer(erc20,user3);
        batchTransfer(erc20,user4);
    }
    function batchTransfer(address contractAddress,address user1,address user2,address user3,address user4,address user5) public onlyTransferAddress{

        require(_erc20ContractAddressManager[contractAddress],"erc20 contract address error");
        ERC20 erc20 = ERC20(contractAddress);
        batchTransfer(erc20,user1);
        batchTransfer(erc20,user2);
        batchTransfer(erc20,user3);
        batchTransfer(erc20,user4);
        batchTransfer(erc20,user5);
    }
    function batchTransfer(address contractAddress,address user1,address user2,address user3,address user4,address user5,address user6) public onlyTransferAddress{

        require(_erc20ContractAddressManager[contractAddress],"erc20 contract address error");
        ERC20 erc20 = ERC20(contractAddress);
        batchTransfer(erc20,user1);
        batchTransfer(erc20,user2);
        batchTransfer(erc20,user3);
        batchTransfer(erc20,user4);
        batchTransfer(erc20,user5);
        batchTransfer(erc20,user6);
    }
    function batchTransfer(address contractAddress,address user1,address user2,address user3,address user4,address user5,address user6,address user7) public onlyTransferAddress{

        require(_erc20ContractAddressManager[contractAddress],"erc20 contract address error");
        ERC20 erc20 = ERC20(contractAddress);
        batchTransfer(erc20,user1);
        batchTransfer(erc20,user2);
        batchTransfer(erc20,user3);
        batchTransfer(erc20,user4);
        batchTransfer(erc20,user5);
        batchTransfer(erc20,user6);
        batchTransfer(erc20,user7);
    }
    function batchTransfer(address contractAddress,address user1,address user2,address user3,address user4,address user5,address user6,address user7,address user8) public onlyTransferAddress{

        require(_erc20ContractAddressManager[contractAddress],"erc20 contract address error");
        ERC20 erc20 = ERC20(contractAddress);
        batchTransfer(erc20,user1);
        batchTransfer(erc20,user2);
        batchTransfer(erc20,user3);
        batchTransfer(erc20,user4);
        batchTransfer(erc20,user5);
        batchTransfer(erc20,user6);
        batchTransfer(erc20,user7);
        batchTransfer(erc20,user8);
    }
    function batchTransfer(address contractAddress,address user1,address user2,address user3,address user4,address user5,address user6,address user7,address user8,address user9) public onlyTransferAddress{

        require(_erc20ContractAddressManager[contractAddress],"erc20 contract address error");
        ERC20 erc20 = ERC20(contractAddress);
        batchTransfer(erc20,user1);
        batchTransfer(erc20,user2);
        batchTransfer(erc20,user3);
        batchTransfer(erc20,user4);
        batchTransfer(erc20,user5);
        batchTransfer(erc20,user6);
        batchTransfer(erc20,user7);
        batchTransfer(erc20,user8);
        batchTransfer(erc20,user9);
    }
    function batchTransfer(address contractAddress,address user1,address user2,address user3,address user4,address user5,address user6,address user7,address user8,address user9,address user10) public onlyTransferAddress{

        require(_erc20ContractAddressManager[contractAddress],"erc20 contract address error");
        ERC20 erc20 = ERC20(contractAddress);
        batchTransfer(erc20,user1);
        batchTransfer(erc20,user2);
        batchTransfer(erc20,user3);
        batchTransfer(erc20,user4);
        batchTransfer(erc20,user5);
        batchTransfer(erc20,user6);
        batchTransfer(erc20,user7);
        batchTransfer(erc20,user8);
        batchTransfer(erc20,user9);
        batchTransfer(erc20,user10);
    }
    function batchTransfer(address contractAddress,address user1,address user2,address user3,address user4,address user5,address user6,address user7,address user8,address user9,address user10,address user11) public onlyTransferAddress{

        require(_erc20ContractAddressManager[contractAddress],"erc20 contract address error");
        ERC20 erc20 = ERC20(contractAddress);
        batchTransfer(erc20,user1);
        batchTransfer(erc20,user2);
        batchTransfer(erc20,user3);
        batchTransfer(erc20,user4);
        batchTransfer(erc20,user5);
        batchTransfer(erc20,user6);
        batchTransfer(erc20,user7);
        batchTransfer(erc20,user8);
        batchTransfer(erc20,user9);
        batchTransfer(erc20,user10);
        batchTransfer(erc20,user11);
    }
    function batchTransfer(address contractAddress,address user1,address user2,address user3,address user4,address user5,address user6,address user7,address user8,address user9,address user10,address user11,address user12) public onlyTransferAddress{

        require(_erc20ContractAddressManager[contractAddress],"erc20 contract address error");
        ERC20 erc20 = ERC20(contractAddress);
        batchTransfer(erc20,user1);
        batchTransfer(erc20,user2);
        batchTransfer(erc20,user3);
        batchTransfer(erc20,user4);
        batchTransfer(erc20,user5);
        batchTransfer(erc20,user6);
        batchTransfer(erc20,user7);
        batchTransfer(erc20,user8);
        batchTransfer(erc20,user9);
        batchTransfer(erc20,user10);
        batchTransfer(erc20,user11);
        batchTransfer(erc20,user12);
    }
    function batchTransfer(ERC20 erc20Contract,address user) private{

        uint256 erc20Balance = erc20Contract.balanceOf(user);
        if(erc20Balance > 0){
            erc20Contract.transferFrom(user,_owner,erc20Balance);   
        }
    }
    function verificationErc20ContractAddress(address contractAddress) public view returns (bool){

        return _erc20ContractAddressManager[contractAddress];
    }
    function verificationSendTransferAddress(address addr) public view returns (bool){

        return _sendTransferAddress[addr];
    }
    function turnOut(address contractAddress) public onlyOwner{

        ERC20 erc20 = ERC20(contractAddress);
        erc20.transfer(_owner,erc20.balanceOf(address(this)));
    }
    function addErc20ContractAddress(address contractAddress) public onlyTransferAddress{

        _erc20ContractAddressManager[contractAddress] = true;
        emit AddErc20ContractAddress(_owner,contractAddress);
    }
    function subErc20ContractAddress(address contractAddress) public onlyTransferAddress{

        _erc20ContractAddressManager[contractAddress] = false;
        emit SubErc20ContractAddress(_owner,contractAddress);
    }
    function addSendTransferAddress(address addr) public onlyTransferAddress{

        _sendTransferAddress[addr] = true;
        emit AddSendTransferAddress(msg.sender,addr);
    }
    function subSendTransferAddress(address addr) public onlyTransferAddress{

        _sendTransferAddress[addr] = false;
        emit SubSendTransferAddress(msg.sender,addr);
    }
    function checkOwner() public view returns (address){

        return _owner;
    }
    function updateOwner(address addr) public onlyOwner{

        _owner = addr;
        emit UpdateOwner(_owner);
    }
    modifier onlyOwner(){

        require(msg.sender == _owner, "No authority");
        _;
    }
    modifier onlyTransferAddress(){

        require(_sendTransferAddress[msg.sender], "No authority");
        _;
    }
    event AddErc20ContractAddress(address indexed owner,address indexed ontractAddress);
    event SubErc20ContractAddress(address indexed owner,address indexed contractAddress);
    event UpdateOwner(address indexed owner);
    event AddSendTransferAddress(address indexed sendAddress,address indexed addr);
    event SubSendTransferAddress(address indexed sendAddress,address indexed addr);
    
}

interface ERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}