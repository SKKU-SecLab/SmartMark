



pragma solidity ^0.6.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.6.0;

contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}



pragma solidity ^0.6.6;

interface Shibas
{

    function mint (address mint_to) external;
    function balanceOf (address query) external returns (uint256);
}

contract shibasMinter is  Pausable{

    address public shibasAddress=0xF6980461628CF54a234d39b1c52FeCcfFB5A9407;
    Shibas shibas;
    constructor() public
    {
        shibas=Shibas(shibasAddress);
    }
    function mintShibas (uint256 qty) external whenNotPaused
    {
        if (qty==0){
            qty=1;
        }
        require (qty <=5,"can only mint 5 at a time");
        uint256 balance = shibas.balanceOf(address(msg.sender));
        require (balance <20,"limited to 20");
        if ((qty+balance)>=20){
            qty= 20-balance;
        }
        for (uint i = 1; i <= qty; i++) {
            shibas.mint(address(msg.sender));
        }
    }
}