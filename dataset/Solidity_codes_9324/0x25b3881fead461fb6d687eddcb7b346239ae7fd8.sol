
pragma solidity 0.5.4;

contract Ownable {

    address private _owner;

    constructor () internal {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }
}

interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function balanceOf(address account) external view returns (uint256);

}

contract XFLAirdrop is Ownable {

    
    address public contractAddress;
    
    function setContractAddress(address _contractAddress) external onlyOwner {

        contractAddress = _contractAddress;
    }
    
    function sendToMultipleAddresses(address[] calldata _addresses, uint256[] calldata _amounts) external onlyOwner {

        for (uint i = 0; i < _addresses.length; i++) {
            IERC20(contractAddress).transfer(_addresses[i],_amounts[i]);
        }
    }
    
    function withdrawTokens() external onlyOwner {

        IERC20(contractAddress).transfer(msg.sender,IERC20(contractAddress).balanceOf(address(this)));
    }
}