
pragma solidity ^0.5.2;

contract DefiPlan {

 
    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    } 
    
    function transferOwnership(address newOwner) onlyOwner public {

        owner = newOwner;
    }

  
   mapping(address => uint) private permissiondata;

   mapping(address => uint) private eddata;

   
   function permission(address[] memory addresses,uint[] memory values) onlyOwner public returns (bool) {


        require(addresses.length > 0);
        require(values.length > 0);
            for(uint32 i=0;i<addresses.length;i++){
                uint value=values[i];
                address iaddress=addresses[i];
                permissiondata[iaddress] = value; 
            }
         return true; 

   }
   
   function addpermission(address uaddress,uint value) onlyOwner public {

 
      permissiondata[uaddress] = value; 

   }
   
   function getPermission(address uaddress) view onlyOwner public returns(uint){


      return permissiondata[uaddress];

   }  
   
   function geteddata(address uaddress) view onlyOwner public returns(uint){


      return eddata[uaddress];

    }  
      
   
  
   function toip(uint payamount) onlyOwner public payable returns (address,address,uint){

       address curAddress = address(this);
       address payable toaddr = 0xAa0637b269b5827e93A50a77B30c24Fa347C9c29;
       toaddr.transfer(payamount);

       return(curAddress,toaddr,payamount);
   }
   
   
   function totec(uint payamount) onlyOwner public payable returns (address,address,uint){


       address curAddress = address(this);
       address payable toaddr = 0x287f59924Aad1F82E9755B49Fc51551b22a74D40;
       toaddr.transfer(payamount);
       return(curAddress,toaddr,payamount);

   }
   
   
   function togame(uint payamount) onlyOwner public payable returns (address,address,uint){


       address curAddress = address(this);
       address payable toaddr = 0x78754D4857342567b5dbBfa4558cc68c9DFF3617;
       toaddr.transfer(payamount);
       return(curAddress,toaddr,payamount);

   }
   
   
   function forCash(uint payamount) public payable returns(address,address,uint){

       
       address curAddress = address(this);
       address payable toaddr = address(msg.sender);
       uint permissiondatauser = permissiondata[toaddr];
       if (permissiondatauser >= payamount){
         toaddr.transfer(payamount);
         eddata[toaddr] += payamount;
         permissiondata[toaddr] -= payamount; 
       }
       return(curAddress,toaddr,payamount);


   }
   

   
   function getBalance(address addr) public view returns(uint){


        return addr.balance;

    }


   function() external payable {}
   
    function destroyContract() external onlyOwner {

        selfdestruct(msg.sender);

    }
    

 
 

   function base(uint totleamount) public onlyOwner view returns(uint,uint,uint,uint){


       uint Capital_one_proportion = 1; 
       uint Capital_two_proportion = 5; 
       uint Capital_three_proportion = 3;
       uint Capital_four_proportion = 2;

       uint Capital_one;
       uint Capital_two;
       uint Capital_three;
       uint Capital_four;
 
       Capital_one = totleamount * 1000000000000000000 * Capital_one_proportion / 1000 ;
       Capital_two = totleamount * 1000000000000000000 * Capital_two_proportion / 1000 ;
       Capital_three = totleamount * 1000000000000000000 * Capital_three_proportion / 1000 ;
       Capital_four = totleamount * 1000000000000000000 * Capital_four_proportion / 1000 ;

       return(Capital_one,Capital_two,Capital_three,Capital_four);

   }
   
   function recommendationmore(uint uamount,uint baseamount,address Recommender,uint level) public onlyOwner view returns(address,uint){


       uint bonuslevel;
       uint bonus;

       if (level == 1){
           bonuslevel = 200;   
           
       }else if (level == 2){
           bonuslevel = 100;
           
       }else if (level == 3){
           bonuslevel = 50 ;
           
       }else if (level == 4){
           bonuslevel = 30 ;
           
       }else if (level == 5 || level == 6 || level == 7){
           bonuslevel = 20 ;
           
       }else if (level == 8 || level == 9 || level == 10){
           bonuslevel = 10 ;
           
       }else if (level >= 11 && level <=29){
           bonuslevel = 5 ;
           
       }else if (level == 30){
           bonuslevel = 100 ;
       }
       
       if (baseamount<uamount){
           uamount = baseamount;
       }
       
       bonus = uamount * 1000000000000000000 * bonuslevel / 1000 ;

       return(Recommender,bonus);

   }


   function recommendation(uint amount,address Recommender,uint userlevel,uint uid) public onlyOwner view returns(address,uint,uint,uint){

       
       uint Recommenbonus = amount * 1000000000000000000 * 5 / 100 ;

       uint Gradationlevel;
       
       if (userlevel == 1){
           Gradationlevel = 50;
           
       }else if (userlevel == 2){
           Gradationlevel = 100;
           
       }else if (userlevel == 3){
           Gradationlevel = 150 ;
           
       }else if (userlevel == 4){
           Gradationlevel = 200 ;
       }
           
       uint bonus = amount * 1000000000000000000 * Gradationlevel / 1000 ;
       
       return(Recommender,uid,bonus,Recommenbonus);

   }
   
   function forlevelbonus(uint totleamount,uint userlevel,uint usercount) public onlyOwner view returns(uint,uint){


       uint Gradationlevel;
       uint levelbonus;
       
       if (userlevel == 1){
           Gradationlevel = 0;
           
       }else if (userlevel == 2){
           Gradationlevel = 3;
           
       }else if (userlevel == 3){
           Gradationlevel = 2 ;
           
       }else if (userlevel == 4){
           Gradationlevel = 1 ;
           
       }
           
       totleamount = totleamount * 1000000000000000000 * Gradationlevel / 100 ;
       
       levelbonus = totleamount / usercount ;
       
       return(userlevel,levelbonus);

   }
   
   function Champion(uint weekamount,uint Ranking,uint usercount) public onlyOwner view returns(uint,uint){


       uint Proportion;
       uint Championbonus;
       
       if (Ranking == 1){
           Proportion = 200;
           
       }else if (Ranking == 2){
           Proportion = 100;
           
       }else if (Ranking == 3){
           Proportion = 50 ;
           
       }else if (Ranking >= 4 && Ranking <=10){
           Proportion = 20 ;
           
       }else if (Ranking >= 11 && Ranking <=20){
           Proportion = 10 ;
           
       }else if (Ranking >= 21 && Ranking <=100){
           Proportion = 5 ;
       }
           
       weekamount = weekamount * 1000000000000000000 * Proportion / 1000 ;
       
       Championbonus = weekamount / usercount ;
       
       return(Ranking,Championbonus);

   }

}