

pragma solidity 0.5.0;

interface Token {


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);


    function balanceOf(address _who) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

}

contract HGetMultipleBalances {


    mapping (uint256 => address) private inLine;
    uint256 public numTokens = 0;

    function addTokenAddress(
        address _token
        )
        external
    {

        ++numTokens;
        require (inLine[numTokens] == address(0));
        inLine[numTokens] = _token;
    }

    function numberToAddress(
        uint256 _number,
        address _token
        )
        external
    {

        require (inLine[_number] == address(0));
        inLine[_number] = _token;
    }

    function getBalance(
        address _token,
        address _who
        )
        external
        view
        returns (uint256 amount)
    {

        amount = Token(_token).balanceOf(_who);
    }

    function getMultiBalancesWithNumber(
        uint[] calldata _tokenNumbers,
        address _who
        )
        external
        view
        returns (
            uint256[] memory balances,
            address[] memory tokenAddresses
        )
    {

        uint256 length = _tokenNumbers.length;
        balances = new uint256[](length);
        tokenAddresses = new address[](length);
        for (uint256 i = 1; i <= length; i++) {
            address targetToken = getAddressFromNumber(i);
            Token token = Token(targetToken);
            uint256 amount = token.balanceOf(_who);
            if (amount == 0) continue;
            balances[i] = amount;
            tokenAddresses[i] = targetToken;
        }
    }

    function getMultiBalances(
        address _who
        )
        external
        view
        returns (
            uint256[] memory balances,
            address[] memory tokenAddresses
        )
    {

        uint256 length = numTokens;
        balances = new uint256[](length);
        tokenAddresses = new address[](length);
        for (uint256 i = 1; i <= length; i++) {
            address targetToken = getAddressFromNumber(i);
            Token token = Token(targetToken);
            uint256 amount = token.balanceOf(_who);
            if (amount == 0) continue;
            balances[i] = amount;
            tokenAddresses[i] = targetToken;
        }
    }

    function getMultiBalancesFromAddresses(
        address[] calldata _tokenAddresses,
        address _who)
        external
        view
        returns (uint256[] memory balances)
    {

        uint256 length = _tokenAddresses.length;
        balances = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            address targetToken = _tokenAddresses[i];
            Token token = Token(targetToken);
            uint256 amount = token.balanceOf(_who);
            balances[i] = amount;
        }
    }

    function getMultiBalancesAndAddressesFromAddresses(
        address[] calldata _tokenAddresses,
        address _who)
        external
        view
        returns (
            uint256[] memory balances,
            address[] memory tokenAddresses
        )
    {

        uint256 length = _tokenAddresses.length;
        balances = new uint256[](length);
        tokenAddresses = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            address targetToken = _tokenAddresses[i];
            Token token = Token(targetToken);
            uint256 amount = token.balanceOf(_who);
            balances[i] = amount;
            tokenAddresses[i] = targetToken;
        }
    }
    
    function getPositiveBalancesAndAddressesFromAddresses(
        address[] calldata _tokenAddresses,
        address _who)
        external
        view
        returns (
            uint256[] memory balances,
            address[] memory tokenAddresses
        )
    {

        uint256 length = _tokenAddresses.length;
        balances = new uint256[](length);
        tokenAddresses = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            address targetToken = _tokenAddresses[i];
            Token token = Token(targetToken);
            uint256 amount = token.balanceOf(_who);
            if (amount == 0) continue;
            balances[i] = amount;
            tokenAddresses[i] = targetToken;
        }
    }

    function getAddressFromNumber(
        uint256 _number)
        internal
        view
        returns (address)
    {

        return(inLine[_number]);
    }
}