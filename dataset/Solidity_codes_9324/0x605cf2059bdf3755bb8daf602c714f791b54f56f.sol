
pragma experimental ABIEncoderV2;
pragma solidity 0.8.0;


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


interface IERC721 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}


interface IERC1155  {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}


contract SwapContract {


  struct Swap {
      
       string swapID; 
       address payable openTrader;
       address payable closeTrader;
       uint[] swapChoice;    // 0: ether, 1: erc20, 2:erc721, 3: erc1155
       address[] contractAddress;
       uint256[] swapValue;
       uint[] trader;  // 1: openTrader, 2: closeTrader
       uint256 States;  // 1: open, 2: closed, 3: expired
       uint256 swapDate;
       mapping (address => uint256) ERC1155Value;  
     
  }

  mapping (string => Swap) private swaps;
  string[] private swapList;


   constructor()  {
       
   }
   
  
  function openERC20(string memory _swapID, uint256 _openValueERC20, address _openContractAddress, address payable _closeTrader) public {

       
             IERC20 openERC20Contract = IERC20(_openContractAddress);
             openERC20Contract.transferFrom(msg.sender, address(this), _openValueERC20);
             bytes memory identifiant = bytes(swaps[_swapID].swapID);

        if(identifiant.length == 0) {
             swaps[_swapID].swapID = _swapID;
      
      swaps[_swapID].openTrader = payable(msg.sender);
      
      swaps[_swapID].closeTrader = _closeTrader;
      swaps[_swapID].States = 1;
       swapList.push(_swapID);
        }
      swaps[_swapID].swapChoice.push(1);
      
      swaps[_swapID].contractAddress.push(_openContractAddress);
      
      swaps[_swapID].swapValue.push(_openValueERC20);
      
      swaps[_swapID].trader.push(1);
      
  }
  
   function openERC721(string memory _swapID, uint256 _openIdERC721, address _openContractAddress, address payable _closeTrader) public {

       
             IERC721 openERC721Contract = IERC721(_openContractAddress);
             openERC721Contract.transferFrom(msg.sender, address(this), _openIdERC721);
             bytes memory identifiant = bytes(swaps[_swapID].swapID);

        if(identifiant.length == 0) {
                  swaps[_swapID].swapID = _swapID;
      
      swaps[_swapID].openTrader = payable(msg.sender);
      
      swaps[_swapID].closeTrader = _closeTrader;
      swaps[_swapID].States = 1;
       swapList.push(_swapID);
        }

      
      swaps[_swapID].swapChoice.push(2);
      
      swaps[_swapID].contractAddress.push(_openContractAddress);
      
      swaps[_swapID].swapValue.push(_openIdERC721);
      
      swaps[_swapID].trader.push(1);
      
      
  }
   
   
   function openERC1155(string memory _swapID, uint256 _openValueERC1155, uint256 _openIdERC1155, address _openContractAddress, address payable  _closeTrader, bytes calldata _data) public {

       
              IERC1155  openERC1155Contract = IERC1155(_openContractAddress);
             openERC1155Contract.safeTransferFrom(msg.sender, address(this),_openIdERC1155, _openValueERC1155, _data);
            bytes memory identifiant = bytes(swaps[_swapID].swapID);

        if(identifiant.length == 0) {
             swaps[_swapID].swapID = _swapID;
      
      swaps[_swapID].openTrader = payable(msg.sender);
      
      swaps[_swapID].closeTrader = _closeTrader;
       swaps[_swapID].States = 1;
        swapList.push(_swapID);
        }
     
      
      swaps[_swapID].swapChoice.push(3);
      
      swaps[_swapID].contractAddress.push(_openContractAddress);
      
      swaps[_swapID].swapValue.push(_openIdERC1155);
      
      swaps[_swapID].ERC1155Value[_openContractAddress] = _openValueERC1155;
      
      swaps[_swapID].trader.push(1);
      
     
   
    
      
  }
   
  
   function closeERC20(string memory _swapID, uint256 _closeValueERC20, address _closeContractAddress) public  {

       
       
        IERC20 closeERC20Contract = IERC20(_closeContractAddress);
        
        closeERC20Contract.transferFrom(msg.sender, address(this), _closeValueERC20);
        
        swaps[_swapID].swapChoice.push(1);
      
        swaps[_swapID].contractAddress.push(_closeContractAddress);
      
        swaps[_swapID].swapValue.push(_closeValueERC20);
        
        swaps[_swapID].trader.push(2);
        swaps[_swapID].States = 2;
        

  }
  
   function closeER721(string memory _swapID, uint256 _closeIdERC721, address _closeContractAddress) public  {

       
           IERC721 closeERC721Contract = IERC721(_closeContractAddress);
           
           closeERC721Contract.transferFrom(swaps[_swapID].closeTrader, address(this), _closeIdERC721);
           
           swaps[_swapID].swapChoice.push(2);
      
           swaps[_swapID].contractAddress.push(_closeContractAddress);
      
           swaps[_swapID].swapValue.push(_closeIdERC721);
           
           swaps[_swapID].trader.push(2);
           swaps[_swapID].States = 2;
        
  }
   
    function closeERC1155(string memory _swapID, uint256 _closeIdERC1155, uint256 _closeValueERC1155, address _closeContractAddress, bytes calldata _data) public  {

       
           IERC1155 closeERC1155Contract = IERC1155(_closeContractAddress);
           
           closeERC1155Contract.safeTransferFrom(swaps[_swapID].closeTrader,address(this), _closeIdERC1155, _closeValueERC1155, _data);
           
           swaps[_swapID].swapChoice.push(3);
      
           swaps[_swapID].contractAddress.push(_closeContractAddress);
      
           swaps[_swapID].swapValue.push(_closeIdERC1155);
      
           swaps[_swapID].ERC1155Value[_closeContractAddress] = _closeValueERC1155;
           
           swaps[_swapID].trader.push(2);
           swaps[_swapID].States = 2;
      
  }
  
  function finalClose(string memory _swapID, bytes calldata _data) public  {

     
      
        for(uint256 i=0; i<swaps[_swapID].swapChoice.length; i++) {
                 if(swaps[_swapID].swapChoice[i] == 1) {
                       IERC20 closeERC20Contract = IERC20(swaps[_swapID].contractAddress[i]);
                   if(swaps[_swapID].trader[i] == 1) {
                       
                        closeERC20Contract.transfer(swaps[_swapID].closeTrader, swaps[_swapID].swapValue[i]);
                        
                   } else if(swaps[_swapID].trader[i] == 2) {
                       
                        closeERC20Contract.transfer(swaps[_swapID].openTrader, swaps[_swapID].swapValue[i]);
                        
                   }
            
           
                 } else if(swaps[_swapID].swapChoice[i] == 2) {
                         IERC721 closeERC721Contract = IERC721(swaps[_swapID].contractAddress[i]);
                            if(swaps[_swapID].trader[i] == 1) {
                                
                              closeERC721Contract.transferFrom(address(this), swaps[_swapID].closeTrader, swaps[_swapID].swapValue[i]);
              
                          } else if(swaps[_swapID].trader[i] == 2) {
                              closeERC721Contract.transferFrom(address(this), swaps[_swapID].openTrader, swaps[_swapID].swapValue[i]);
                             }
                 } else if(swaps[_swapID].swapChoice[i] == 3) {
                     
          uint256 value = swaps[_swapID].ERC1155Value[swaps[_swapID].contractAddress[i]];
          IERC1155 closeERC1155Contract = IERC1155(swaps[_swapID].contractAddress[i]);
           if(swaps[_swapID].trader[i] == 1) {
               
                         closeERC1155Contract.safeTransferFrom(address(this), swaps[_swapID].closeTrader, swaps[_swapID].swapValue[i], value, _data);

           } else if(swaps[_swapID].trader[i] == 2) {
               
                         closeERC1155Contract.safeTransferFrom(address(this), swaps[_swapID].openTrader, swaps[_swapID].swapValue[i], value, _data);
           }
          
      }
        }
          swaps[_swapID].swapDate = block.timestamp;
          swaps[_swapID].States = 3;
  
  }


function expire(string memory _swapID, bytes calldata _data) public payable {

     
      
        for(uint256 i=0; i<swaps[_swapID].swapChoice.length; i++) {
            
                  if(swaps[_swapID].swapChoice[i] == 0) {
                       if(swaps[_swapID].trader[i] == 1) {
                           
                           address payable openTraderr = swaps[_swapID].openTrader;
       
                           openTraderr.transfer(msg.value);
                           
                       } else if(swaps[_swapID].trader[i] == 2) { 
                           
                           address payable closeTraderr = swaps[_swapID].closeTrader;
       
                           closeTraderr.transfer(msg.value);
                           
                       }
                     
                      
                  } else if(swaps[_swapID].swapChoice[i] == 1) {
                       IERC20 closeERC20Contract = IERC20(swaps[_swapID].contractAddress[i]);
                   if(swaps[_swapID].trader[i] == 1) {
                       
                        closeERC20Contract.transfer(swaps[_swapID].openTrader, swaps[_swapID].swapValue[i]);
                        
                   } else if(swaps[_swapID].trader[i] == 2) {
                       
                        closeERC20Contract.transfer(swaps[_swapID].closeTrader, swaps[_swapID].swapValue[i]);
                        
                   }
            
           
                 } else if(swaps[_swapID].swapChoice[i] == 2) {
                         IERC721 closeERC721Contract = IERC721(swaps[_swapID].contractAddress[i]);
                            if(swaps[_swapID].trader[i] == 1) {
                                
                              closeERC721Contract.transferFrom(address(this), swaps[_swapID].openTrader, swaps[_swapID].swapValue[i]);
              
                          } else if(swaps[_swapID].trader[i] == 2) {
                  
                              closeERC721Contract.transferFrom(address(this), swaps[_swapID].closeTrader, swaps[_swapID].swapValue[i]);
                  
                             }
   


                 } else if(swaps[_swapID].swapChoice[i] == 3) {
                     
          uint256 value = swaps[_swapID].ERC1155Value[swaps[_swapID].contractAddress[i]];
          IERC1155 closeERC1155Contract = IERC1155(swaps[_swapID].contractAddress[i]);
           if(swaps[_swapID].trader[i] == 1) {
               
                         closeERC1155Contract.safeTransferFrom(address(this), swaps[_swapID].openTrader, swaps[_swapID].swapValue[i], value, _data);

           } else if(swaps[_swapID].trader[i] == 2) {
               
                         closeERC1155Contract.safeTransferFrom(address(this), swaps[_swapID].closeTrader, swaps[_swapID].swapValue[i], value, _data);

           }
          
          
          
      }
        }

          swaps[_swapID].States = 4;
  
  }


   function getSwapList() public view returns (uint256) {

       return swapList.length;
       
   }
   function getSwapsId() public view returns (string [] memory ) {

     return swapList;
   }
 
   function checkSwap(string memory _swapID) public view returns (string memory swapId, address closeTrader, address openTrader, uint256 States, uint256 date) {

   return (swaps[_swapID].swapID, swaps[_swapID].closeTrader, swaps[_swapID].openTrader, swaps[_swapID].States, swaps[_swapID].swapDate);
  }
  
   function gettrCaSvSc(string memory _swapID)public view returns( uint  [] memory, address  [] memory, uint256  [] memory, uint  [] memory){

    return (swaps[_swapID].trader, swaps[_swapID].contractAddress, swaps[_swapID].swapValue, swaps[_swapID].swapChoice);
}
function getValERC11(string memory _swapID, address contractAddress) public view returns(uint256) {

    
    return(swaps[_swapID].ERC1155Value[contractAddress]);
}


   
}