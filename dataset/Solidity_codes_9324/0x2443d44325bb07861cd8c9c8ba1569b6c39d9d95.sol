


pragma solidity ^0.5.0;


interface IMiniMeLike {

    function generateTokens(address _owner, uint _amount) external returns (bool);

}



pragma solidity ^0.5.0;


interface ITokenController {

    function proxyPayment(address _owner) external payable returns (bool);


    function onTransfer(address _from, address _to, uint _amount) external returns (bool);


    function onApprove(address _owner, address _spender, uint _amount) external returns (bool);

}



pragma solidity 0.5.17;




contract ANTController is ITokenController {

    string private constant ERROR_NOT_MINTER = "ANTC_SENDER_NOT_MINTER";
    string private constant ERROR_NOT_ANT = "ANTC_SENDER_NOT_ANT";

    IMiniMeLike public ant;
    address public minter;

    event ChangedMinter(address indexed minter);

    modifier onlyMinter {

        require(msg.sender == minter, ERROR_NOT_MINTER);
        _;
    }

    constructor(IMiniMeLike _ant, address _minter) public {
        ant = _ant;
        _changeMinter(_minter);
    }

    function generateTokens(address _owner, uint256 _amount) external onlyMinter returns (bool) {

        return ant.generateTokens(_owner, _amount);
    }

    function changeMinter(address _newMinter) external onlyMinter {

        _changeMinter(_newMinter);
    }


    function proxyPayment(address /* _owner */) external payable returns (bool) {

        require(msg.sender == address(ant), ERROR_NOT_ANT);
        return false;
    }

    function onTransfer(address /* _from */, address /* _to */, uint /* _amount */) external returns (bool) {

        return true;
    }

    function onApprove(address /* _owner */, address /* _spender */, uint /* _amount */) external returns (bool) {

        return true;
    }


    function _changeMinter(address _newMinter) internal {

        minter = _newMinter;
        emit ChangedMinter(_newMinter);
    }
}