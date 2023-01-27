interface IERC20{

         
    function transfer(address recipient, uint256 amount) external;

    
}

abstract contract OMS { //Orcania Management Standard

    address private _owner;
    mapping(address => bool) private _manager;

    event OwnershipTransfer(address indexed newOwner);
    event SetManager(address indexed manager, bool state);

    receive() external payable {}

    constructor() {
        _owner = msg.sender;
        _manager[msg.sender] = true;

        emit SetManager(msg.sender, true);
    }

    modifier Owner() {
        require(msg.sender == _owner, "OMS: NOT_OWNER");
        _;  
    }

    modifier Manager() {
      require(_manager[msg.sender], "OMS: MOT_MANAGER");
      _;  
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function manager(address user) external view returns(bool) {
        return _manager[user];
    }

    
    function setNewOwner(address user) external Owner {
        _owner = user;
        emit OwnershipTransfer(user);
    }

    function setManager(address user, bool state) external Owner {
        _manager[user] = state;
        emit SetManager(user, state);
    }

    
    function withdraw(address payable to, uint256 value) external Manager {
        require(to.send(value), "OMS: ISSUE_SENDING_FUNDS");    
    }

    function withdrawERC20(address token, address to, uint256 value) external Manager {
        IERC20(token).transfer(to, value);   
    }

}// Developed by Orcania (https://orcania.io/)
pragma solidity =0.7.6;



interface IERC721 {


    function balanceOf(address _owner) external view returns (uint256);


    function adminMint(address to, uint256 amount) external;


}

interface IERC1155 {


    function adminMint(address user, uint256 amount, uint256 id) external;


}

contract HeelsClaim is OMS { 

    IERC721 immutable DAW = IERC721(0xF1268733C6FB05EF6bE9cF23d24436Dcd6E0B35E);
    IERC721 immutable Heels = IERC721(0xB1444F1d64B5920e8a5c3B62F57808a68bD9b6e9);
    IERC1155 immutable HeelsSpecial = IERC1155(0xa9Bcc11a59b9085a426155418c511d7a8605835B);

    mapping(address => uint256) private _heels; //how many heels this address gets
    mapping(address => bool) private _claimed; //If user claimed or not

    uint256 private dawHeelsMints;


    function heels(address user) external view returns(uint256) {

        if(_claimed[user]) {return 0;}
        else if(_heels[user] > 0) {return (_heels[user] * 2) + 1;}
        else if(DAW.balanceOf(user) != 0) {return 1;}
        else {return 0;}
    }

    function hasToClaim(address user) external view returns(bool) {

        if(_claimed[user]) {return false;}

        if(_heels[user] > 0) {return true;}
        if(DAW.balanceOf(user) > 0) {return true;}
    }

    function claimed(address user) external view returns(bool) {

        return _claimed[user];
    }
    

    function setHeels(address[] calldata users) external Manager{

        uint256 length = users.length;

        for(uint256 t; t < length; ++t) {
            ++_heels[users[t]];
        }

    }

    function claim() external {

        require(!_claimed[msg.sender], "ALREADY_CLAIMED");

        uint256 heels = _heels[msg.sender];
        if(heels > 0) {
            Heels.adminMint(msg.sender, heels);
            HeelsSpecial.adminMint(msg.sender, heels, 0);

            if(dawHeelsMints++ < 333) {
                HeelsSpecial.adminMint(msg.sender, 1, 1); //DAW edition
            }
        }
        else if(DAW.balanceOf(msg.sender) > 0) {
            if(dawHeelsMints++ < 333) {
                HeelsSpecial.adminMint(msg.sender, 1, 1); //DAW edition
            }
        }

        _claimed[msg.sender] = true;
    }
}
