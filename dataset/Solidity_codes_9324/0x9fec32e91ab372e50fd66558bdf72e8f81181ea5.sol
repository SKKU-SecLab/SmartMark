pragma solidity ^0.6.4;

interface DaiErc20 {

    function transfer(address, uint) external returns (bool);

    function transferFrom(address,address,uint256) external returns (bool);

    function approve(address,uint256) external returns (bool);

    function balanceOf(address) external view returns (uint);

    function allowance(address, address) external view returns (uint);

}


interface PotLike {

    function chi() external view returns (uint256);

    function rho() external view returns (uint256);

    function drip() external returns (uint256);

    function join(uint256) external;

    function exit(uint256) external;

    function pie(address) external view returns (uint256);


}

interface JoinLike {

    function join(address, uint256) external;

    function exit(address, uint256) external;

    function vat() external returns (VatLike);

    function dai() external returns (DaiErc20);


}


interface VatLike {

    function hope(address) external;

    function dai(address) external view returns (uint256);


}

interface cDaiErc20 {

    function mint(uint256) external returns (uint256);

    function redeem(uint) external returns (uint);

    function balanceOf(address) external view returns (uint);

}

pragma solidity ^0.6.4;

contract owned
{


    address public manager;
    
    constructor() public 
	{
	    manager = msg.sender;
	}

    modifier onlyManager()
    {

        require(msg.sender == manager);
        _;
    }
    
    function setManager(address newmanager) external onlyManager
    {

        
        require(newmanager.balance > 0);
        manager = newmanager;
    }
    
}




pragma solidity ^0.6.4;

library mathlib
{

     
    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x);
    }
    
    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x);
    }
    
    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x);
    }
    
}
pragma solidity ^0.6.4;


enum savings {NO, DSR, COMPOUND}

enum escrowstatus {CANCELLED, NOTACTIVATED, ACTIVATED, SETTLED}

enum savestatus {NOTJOINED, JOINED, EXITED}

contract EscrowFactory is owned
{

    
    address constant private dai_ = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    DaiErc20 private daiToken;

    uint public escrowfee;
    
    bool public factorycontractactive;
    
    

    event NewEscrowEvent(address escrowcontractaddress, address indexed escrowpayer, address indexed escrowpayee, uint eventtime);
    
    event NewEscrowEvent(address escrowcontractaddress, address indexed escrowpayer, address indexed escrowpayee, address indexed escrowmoderator, uint eventtime);
    
    constructor() public 
	{
	    escrowfee = 1000000000000000000; //1 DAI
		factorycontractactive = true;
		daiToken = DaiErc20(dai_);
	}


    function setEscrowFee(uint newfee) external onlyManager
    {

        
        require(newfee > 0 && newfee <= 10000000000000000000);
        
        escrowfee = newfee;
    }
    

    function setFactoryContractSwitch() external onlyManager
    {

        
        factorycontractactive = factorycontractactive == true ? false : true;
    }
    
    function createNewEscrow(address escrowpayee, uint escrowamount, uint choice) external 
    {

        
        require(factorycontractactive, "Factory Contract should be Active");
        require(choice>=0 && choice<3,"enum values can be 0,1,2");
        require(msg.sender != escrowpayee,"The Payer & Payee should be different");
        require(escrowamount > 0,"Escrow amount has to be greater than 0");
        
        
        require(daiToken.allowance(msg.sender,address(this)) >= mathlib.add(escrowamount, escrowfee), "daiToken allowance exceeded");
        
        Escrow EscrowContract = (new Escrow) (msg.sender, escrowpayee, escrowamount, choice);
        
        daiToken.transferFrom(msg.sender, address(EscrowContract), escrowamount);
        
        daiToken.transferFrom(msg.sender, manager, escrowfee);
        
        if (choice == uint(savings.DSR))
            {
                EscrowContract.joinDSR();
            }
        else if (choice == uint(savings.COMPOUND))
            {
                EscrowContract.joincDai();
            }
        
        
        emit NewEscrowEvent(address(EscrowContract), msg.sender , escrowpayee , now);
        
    }
    
    function createNewEscrow(address escrowpayee, uint escrowamount, address escrowmoderator, uint escrowmoderatorfee, uint choice) external 
    {

        
        require(factorycontractactive, "Factory Contract should be Active");
        require(choice>=0 && choice<3,"enum values can be 0,1,2");
        require(msg.sender != escrowpayee && msg.sender != escrowmoderator && escrowpayee != escrowmoderator,"The Payer, payee & moderator should be different");
        require(escrowamount > 0,"Escrow amount has to be greater than 0");
    
        uint dailockedinnewescrow = mathlib.add(escrowamount,escrowmoderatorfee);
  
        require(daiToken.allowance(msg.sender,address(this)) >= mathlib.add(dailockedinnewescrow, escrowfee), "daiToken allowance exceeded");
        
        EscrowWithModerator EscrowContract = (new EscrowWithModerator) (msg.sender, escrowpayee, escrowamount, choice, escrowmoderator, escrowmoderatorfee);
        
        daiToken.transferFrom(msg.sender, address(EscrowContract), dailockedinnewescrow);
        
        daiToken.transferFrom(msg.sender, manager, escrowfee);
        
        if (choice == uint(savings.DSR))
            {
                EscrowContract.joinDSR();
            }
        else if (choice == uint(savings.COMPOUND))
            {
                EscrowContract.joincDai();
            }
        
        emit NewEscrowEvent(address(EscrowContract), msg.sender , escrowpayee, escrowmoderator, now);
        
    }
    
}

contract Escrow
{

    savings public savingschoice;
    
    savestatus internal savingsstatus;
    
    escrowstatus public contractstatus;
    
    
    address constant internal join_ = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    address constant internal vat_ = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address constant internal pot_ = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;
    
    address constant internal dai_ = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    
    address constant internal cDai_ = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    
    address immutable internal fact_;
    
    PotLike  internal pot;
    JoinLike internal daiJoin;
    VatLike  internal vat;
    
    DaiErc20  internal daiToken;
    
    cDaiErc20 internal cDaiToken;
    
    uint constant internal RAY = 10 ** 27;
    
    address immutable public escrowpayer;
    address immutable public escrowpayee;
    
    bool public moderatoravailable;
    
    uint immutable public escrowamount;
    uint public escrowsettlementamount;
    
    
    event ContractStatusEvent(escrowstatus cstatus, uint eventtime);

    constructor(address epayer,address epayee, uint eamount, uint choice) public
    {
        require(choice>=0 && choice<3,"enum values can be 0,1,2");
        
        contractstatus = escrowstatus.NOTACTIVATED;
        savingsstatus = savestatus.NOTJOINED;
        
        escrowpayer = epayer;
        escrowpayee = epayee;
        
        moderatoravailable = false;
        
        fact_ = msg.sender;
        
        daiToken = DaiErc20(dai_);
        
        
        if (choice == uint(savings.NO))
        {
            savingschoice = savings.NO;   
        }
        else if (choice == uint(savings.DSR))
        {
            savingschoice = savings.DSR;
            
            daiJoin = JoinLike(join_);
            vat = VatLike(vat_);
            pot = PotLike(pot_);
            
            vat.hope(join_);
            vat.hope(pot_);
            
            
            daiToken.approve(join_, uint(-1));
        }
        else if(choice == uint(savings.COMPOUND))
        {
            savingschoice = savings.COMPOUND;
            cDaiToken = cDaiErc20(cDai_);
            
            
            daiToken.approve(cDai_, uint(-1));
        }
        
        escrowamount = eamount;
        escrowsettlementamount = eamount; //Both are same when contract is created
        
    }
    

    modifier onlyFactory()
    {

        require(msg.sender == fact_, "Only Factory");
        _;
    }
    
    modifier onlyPayer()
    {

        require(msg.sender == escrowpayer, "Only Payer");
        _;
    }
    
    modifier onlyPayee()
    {

        require(msg.sender == escrowpayee, "Only Payee");
        _;
    }
    
    function joinDSR() public onlyFactory
    {

        
        require(savingsstatus == savestatus.NOTJOINED,"Already Joined");
        require(savingschoice == savings.DSR,"Savngs Choice is not DSR");
        uint joinbal = getContractBalance();
        uint chi = (now > pot.rho()) ? pot.drip() : pot.chi();
        daiJoin.join(address(this),joinbal);
        pot.join(mathlib.mul(joinbal, RAY) / chi);
        savingsstatus = savestatus.JOINED;
    }


    function exitAllDSR() internal
    {

        
        require(savingsstatus == savestatus.JOINED, "DSR not Joined or already exited");
        require(savingschoice == savings.DSR,"Savings Choice != savings.DSR");
        if (now > pot.rho()) pot.drip();
        pot.exit(pot.pie(address(this)));
        daiJoin.exit(address(this), daiJoin.vat().dai(address(this)) / RAY);
        savingsstatus = savestatus.EXITED;
    }
    
     function getBalanceDSR() public view returns (uint) 
    {

        
    
        require(savingschoice == savings.DSR,"savingschoice != DSR");
        
        uint pie = pot.pie(address(this));
        uint chi = pot.chi();
        return mathlib.mul(pie,chi) / RAY;
    }
    
    function joincDai() public onlyFactory 
    {

        
        require(savingsstatus == savestatus.NOTJOINED,"Already Joined");
        require(savingschoice == savings.COMPOUND ,"savingschoice != COMPOUND");
        uint joinbal = getContractBalance();
        uint mintResult = cDaiToken.mint(joinbal);
        require(mintResult == 0, "Error creating cDai");
        savingsstatus = savestatus.JOINED;
    }
    
    function exitallcDai() internal
    {

        
        require(savingsstatus == savestatus.JOINED, "COMPOUND not Joined or already exited");
        require(savingschoice == savings.COMPOUND ,"savingschoice != COMPOUND");
        uint cdaibal = getBalancecDai();
        uint redeemResult = cDaiToken.redeem(cdaibal);
        require(redeemResult == 0, "Error Redeeming cDai to Dai");
        savingsstatus = savestatus.EXITED;
    }
    
    function getBalancecDai() public view returns(uint)
    {

        
        require(savingschoice == savings.COMPOUND,"savingschoice != COMPOUND");
        
        return cDaiToken.balanceOf(address(this));
    }
    
  
    function exitsavingsifJoined() internal returns(bool)
    {

        
            if (savingschoice == savings.NO)
            {
                    return true;
            }
            else if (savingschoice == savings.DSR)
            {
                     exitAllDSR();
                     return savingsstatus == savestatus.EXITED ? true : false;
            }
            else if (savingschoice == savings.COMPOUND)
            {
                    exitallcDai();
                    return savingsstatus == savestatus.EXITED ? true : false;
                    
            }
    }
    

    function getContractAddress() external view returns (address)
    {

        return address(this);
    }
    
    function getContractBalance() public view returns(uint)
    {

        
        return daiToken.balanceOf(address(this));
    }
    
    
    function setPayeeActivatedEscrow() external onlyPayee
    {

        
        require(contractstatus == escrowstatus.NOTACTIVATED,"Escrow should be NOT Activated");
        
        contractstatus = escrowstatus.ACTIVATED;
        emit ContractStatusEvent(contractstatus,now);
    }
    

    function setCancelEscrow() external onlyPayer
    {

        
        require(contractstatus == escrowstatus.NOTACTIVATED,"Escrow Should be Not Activated");
        
        require(exitsavingsifJoined() == true , "Savings not exited");
        
        uint fullbalance = getContractBalance();
        
        require(fullbalance > 0 ,"fullbalance should be > 0");
        
        daiToken.transfer(escrowpayer,fullbalance);
        
        contractstatus = escrowstatus.CANCELLED;
        emit ContractStatusEvent(contractstatus,now);
        
    }
    
    function setEscrowSettlementAmount(uint esettlementamount) virtual external onlyPayee
    {

        
        require(contractstatus == escrowstatus.ACTIVATED,"Escrow should be Activated");
        require(esettlementamount > 0 && esettlementamount < escrowamount, "New settlement Amount not correct");
        escrowsettlementamount = esettlementamount;
        
    }
    
    function withdrawFundsFromSavings() virtual external onlyPayer
    {

        
        require(contractstatus == escrowstatus.ACTIVATED || contractstatus == escrowstatus.NOTACTIVATED, "Escrow Cancelled or Settled");
        require(exitsavingsifJoined() == true , "Savings not exited");
        savingschoice = savings.NO;
    }
    
    function releaseFundsToPayee() virtual external onlyPayer
    {

        
        require(contractstatus == escrowstatus.ACTIVATED, "Escrow Should be activated, but not settled");
        
        require(exitsavingsifJoined() == true , "Savings not exited");
        
        uint fullbalance = getContractBalance();
        
        require(fullbalance >= escrowsettlementamount);
        
        uint payeramt =  mathlib.sub(fullbalance,escrowsettlementamount);
        
        daiToken.transfer(escrowpayee,escrowsettlementamount);
         
        if (payeramt > 0)
        {
            daiToken.transfer(escrowpayer,payeramt);
        }
  
        contractstatus = escrowstatus.SETTLED;
        emit ContractStatusEvent(contractstatus,now);
        
    }
    
    function refundFullFundsToPayer() virtual external onlyPayee
    {

        
        require(contractstatus == escrowstatus.ACTIVATED, "Escrow Should be activated, but not settled");
        
        require(exitsavingsifJoined() == true , "Savings not exited");
        
        uint fullbalance = getContractBalance();
        
        require(fullbalance > 0 ,"fullbalance <= 0");
        
        daiToken.transfer(escrowpayer,fullbalance);
         
        contractstatus = escrowstatus.SETTLED; 
        emit ContractStatusEvent(contractstatus,now);
        
    }
    
}

contract EscrowWithModerator is Escrow
{

    
    address immutable public escrowmoderator;
    uint immutable public escrowmoderatorfee;
    
    constructor(address epayer,address epayee, uint eamount, uint choice, address emoderator, uint emoderatorfee) Escrow(epayer, epayee, eamount, choice) public
    {

        moderatoravailable = true;
    
        escrowmoderator = emoderator;
        escrowmoderatorfee = emoderatorfee;
        
        
    }
    
    modifier onlyPayerOrModerator()
    {

        require(msg.sender == escrowpayer || msg.sender == escrowmoderator, "Only Payer or Moderator");
        _;
    }
    
    modifier onlyPayeeOrModerator()
    {

        require(msg.sender == escrowpayee || msg.sender == escrowmoderator, "Only Payee or Moderator");
        _;
    }
    

    function setEscrowSettlementAmount(uint esettlementamount) override external onlyPayeeOrModerator
    {

        
        require(contractstatus == escrowstatus.ACTIVATED,"Escrow should be Activated");
        require(esettlementamount > 0 && esettlementamount < escrowamount ,"escrow settlementamount is incorrect");
        escrowsettlementamount = esettlementamount;
    }
    
    function withdrawFundsFromSavings() override external onlyPayerOrModerator
    {

       
        require(contractstatus == escrowstatus.ACTIVATED || contractstatus == escrowstatus.NOTACTIVATED, "Escrow Cancelled or Settled");
        require(exitsavingsifJoined() == true , "Savings not exited");
        savingschoice = savings.NO;
    }
    
    function releaseFundsToPayee() override external onlyPayerOrModerator
    {

        
        require(contractstatus == escrowstatus.ACTIVATED, "Escrow Should be activated, but not settled");
        
        require(exitsavingsifJoined() == true , "Savings not exited");
        
        uint fullbalance = getContractBalance();
        
        uint minamtrequired = mathlib.add(escrowsettlementamount,escrowmoderatorfee);
        
        require(fullbalance >= minamtrequired);
        
        uint payeramt = mathlib.sub(fullbalance,minamtrequired);
        
        daiToken.transfer(escrowpayee,escrowsettlementamount);
        
        if (escrowmoderatorfee > 0)
        {
            daiToken.transfer(escrowmoderator,escrowmoderatorfee);
        }
        
        if (payeramt > 0)
        {
            daiToken.transfer(escrowpayer,payeramt);
        }
        
        contractstatus = escrowstatus.SETTLED;
        emit ContractStatusEvent(contractstatus,now);
    
    }
    
    function refundFullFundsToPayer() override external onlyPayeeOrModerator
    {

        
        require(contractstatus == escrowstatus.ACTIVATED, "Escrow Should be activated, but not settled");
        
        require(exitsavingsifJoined() == true , "Savings not exited");
        
        uint fullbalance = getContractBalance();
        
        require(fullbalance > 0 , "fullbalance < 0");
        
        if (escrowmoderatorfee > 0)
        {
            if (fullbalance > escrowmoderatorfee)
            {
                uint payeramt = mathlib.sub(fullbalance,escrowmoderatorfee);
                daiToken.transfer(escrowmoderator,escrowmoderatorfee);
                daiToken.transfer(escrowpayer,payeramt);
            }
            else
            {
                daiToken.transfer(escrowmoderator,fullbalance);
            }
        }
        else
        {
             daiToken.transfer(escrowpayer,fullbalance);
        }
        
        contractstatus = escrowstatus.SETTLED;
        emit ContractStatusEvent(contractstatus,now);

    }
    
}
















